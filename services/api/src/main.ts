import "reflect-metadata";
import {
  BadRequestException,
  Body,
  CanActivate,
  Controller,
  ExecutionContext,
  Get,
  Injectable,
  Module,
  Patch,
  Req,
  Res,
  ServiceUnavailableException,
  UnauthorizedException,
  UseGuards,
} from "@nestjs/common";
import { NestFactory } from "@nestjs/core";
import { initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { Pool } from "pg";
import { readFile } from "node:fs/promises";
import { createHash } from "node:crypto";
import type { Request, Response } from "express";
import { applyOperations, emptyProfile, validateOperations } from "./profile";
if (
  process.env.NODE_ENV === "production" &&
  process.env.FIREBASE_AUTH_EMULATOR_HOST
)
  throw new Error("Auth emulator must not be enabled in production");
initializeApp({ projectId: process.env.FIREBASE_PROJECT_ID || "eled-aaf5c" });
let vocabularyJson = "[]";
let vocabularyEtag = "";
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 5,
  connectionTimeoutMillis: 5000,
  statement_timeout: 10000,
});
type AuthRequest = Request & { firebaseUid: string };
@Injectable()
class FirebaseGuard implements CanActivate {
  async canActivate(context: ExecutionContext) {
    const req = context.switchToHttp().getRequest<AuthRequest>();
    const match = /^Bearer (\S+)$/.exec(req.headers.authorization || "");
    if (!match) throw new UnauthorizedException("Sign in to sync progress");
    try {
      const token = await getAuth().verifyIdToken(match[1]);
      req.firebaseUid = token.uid;
      return true;
    } catch {
      throw new UnauthorizedException(
        "Your session expired. Please sign in again.",
      );
    }
  }
}
@Controller("api/eled")
class EledController {
  @Get("health") async health() {
    try {
      await pool.query("SELECT 1");
      return { status: "ok" };
    } catch {
      throw new ServiceUnavailableException();
    }
  }
  @Get("vocabulary")
  getVocabulary(@Req() req: Request, @Res() res: Response) {
    res.setHeader("Cache-Control", "public, max-age=3600, must-revalidate");
    res.setHeader("ETag", vocabularyEtag);
    if (req.headers["if-none-match"] === vocabularyEtag) {
      res.status(304).end();
      return;
    }
    res.type("application/json").send(vocabularyJson);
  }
  @Get("profile")
  @UseGuards(FirebaseGuard)
  async getProfile(
    @Req() req: AuthRequest,
    @Res({ passthrough: true }) res: Response,
  ) {
    res.setHeader("Cache-Control", "no-store");
    const result = await pool.query(
      "SELECT data,revision FROM eled_profiles WHERE uid=$1",
      [req.firebaseUid],
    );
    return result.rows[0] || { data: emptyProfile(), revision: 0 };
  }
  @Patch("profile")
  @UseGuards(FirebaseGuard)
  async patchProfile(
    @Req() req: AuthRequest,
    @Body() body: unknown,
    @Res({ passthrough: true }) res: Response,
  ) {
    let ops;
    try {
      ops = validateOperations((body as { operations: unknown })?.operations);
    } catch (e) {
      throw new BadRequestException((e as Error).message);
    }
    const client = await pool.connect();
    try {
      await client.query("BEGIN");
      await client.query(
        "INSERT INTO eled_profiles(uid,data) VALUES($1,$2) ON CONFLICT DO NOTHING",
        [req.firebaseUid, emptyProfile()],
      );
      const current = await client.query(
        "SELECT data FROM eled_profiles WHERE uid=$1 FOR UPDATE",
        [req.firebaseUid],
      );
      const next = applyOperations(
        { ...emptyProfile(), ...current.rows[0].data },
        ops,
      );
      if (Buffer.byteLength(JSON.stringify(next)) > 8000000)
        throw new BadRequestException("Account data exceeds the 8 MB limit");
      const updated = await client.query(
        "UPDATE eled_profiles SET data=$2,revision=revision+1,updated_at=now() WHERE uid=$1 RETURNING data,revision",
        [req.firebaseUid, next],
      );
      await client.query("COMMIT");
      res.setHeader("Cache-Control", "no-store");
      return updated.rows[0];
    } catch (e) {
      await client.query("ROLLBACK");
      throw e;
    } finally {
      client.release();
    }
  }
}
@Module({ controllers: [EledController], providers: [FirebaseGuard] })
class AppModule {}
async function main() {
  await pool.query(
    `CREATE TABLE IF NOT EXISTS eled_profiles(uid varchar(128) PRIMARY KEY,data jsonb NOT NULL,revision integer NOT NULL DEFAULT 0,updated_at timestamptz NOT NULL DEFAULT now())`,
  );
  await pool.query(
    `CREATE TABLE IF NOT EXISTS eled_vocabulary(word_key text PRIMARY KEY,payload jsonb NOT NULL,sort_order integer NOT NULL)`,
  );
  const seed = await readFile(
    process.env.VOCABULARY_SEED_PATH || "/app/vocabulary.json",
    "utf8",
  );
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    await client.query(
      `INSERT INTO eled_vocabulary(word_key,payload,sort_order)
   SELECT lower(value->>0),value,ordinality FROM jsonb_array_elements($1::jsonb) WITH ORDINALITY
   ON CONFLICT(word_key) DO UPDATE SET payload=EXCLUDED.payload,sort_order=EXCLUDED.sort_order`,
      [seed],
    );
    await client.query("COMMIT");
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
  const dictionary = await pool.query(
    "SELECT payload FROM eled_vocabulary ORDER BY sort_order",
  );
  vocabularyJson = JSON.stringify(dictionary.rows.map((row) => row.payload));
  vocabularyEtag =
    '"' + createHash("sha256").update(vocabularyJson).digest("hex") + '"';
  const app = await NestFactory.create(AppModule, { bodyParser: false });
  const { json } = await import("express");
  app.use(json({ limit: "6mb" }));
  app.enableShutdownHooks();
  await app.listen(3200, "0.0.0.0");
}
main().catch((e) => {
  console.error("ELED API startup failed:", e.message);
  process.exit(1);
});
