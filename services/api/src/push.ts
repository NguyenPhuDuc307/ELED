import { BadRequestException, Body, Controller, Delete, Get, Headers, Post, Req, Res, ServiceUnavailableException, UnauthorizedException, HttpException } from "@nestjs/common";
import { createHash } from "node:crypto";
import type { Pool } from "pg";
import webpush from "web-push";
import type { Request, Response } from "express";
import { inActiveHours, nextReminder, reminderPayload, selectReminderWords, validatePushSubscription, validateReminder, type ReminderSettings } from "./push-schedule";
let db: Pool;
let vocabulary: any[][] = [];
const configured = () => !!(process.env.VAPID_PUBLIC_KEY && process.env.VAPID_PRIVATE_KEY);
function deviceId(token: string) {
  if (!/^[a-f0-9]{64}$/.test(token || "")) throw new UnauthorizedException("Invalid device token");
  return createHash("sha256").update(token).digest("hex");
}
const requests = new Map<string, { at: number; count: number }>();
function limit(id: string, max = 30) {
  const now = Date.now();
  for (const [key, item] of requests) if (now - item.at > 60000) requests.delete(key);
  const entry = requests.get(id) || { at: now, count: 0 };
  if (++entry.count > max) throw new HttpException("Please wait before trying again", 429);
  requests.set(id, entry);
}
function requireConfigured() { if (!configured()) throw new ServiceUnavailableException("Push notifications are not configured"); }
@Controller("api/eled/push")
export class PushController {
  @Post("exclude") async exclude(@Headers("x-eled-device") token: string, @Body() body: any) {
    const words = body?.words;
    if (!Array.isArray(words) || words.length > 500 || words.some((w: unknown) => typeof w !== "string" || w.length > 512)) throw new BadRequestException("Invalid known words");
    await db.query(`UPDATE eled_push_devices SET settings=jsonb_set(settings,'{excluded}',
      (SELECT COALESCE(jsonb_agg(word),'[]'::jsonb) FROM
        (SELECT DISTINCT value AS word FROM jsonb_array_elements(settings->'excluded' || $2::jsonb)) x))
      WHERE device_id=$1`, [deviceId(token), JSON.stringify(words)]);
    return { ok: true };
  }
  @Get("key") key(@Res({ passthrough: true }) res: Response) {
    res.setHeader("Cache-Control", "no-store");
    return { publicKey: configured() ? process.env.VAPID_PUBLIC_KEY : null };
  }
  @Post("subscription") async save(@Headers("x-eled-device") token: string, @Body() body: any, @Req() req: Request) {
    requireConfigured();
    const id = deviceId(token);
    limit("save:" + (req.ip || ""), 60);
    let subscription, settings;
    try { subscription = validatePushSubscription(body?.subscription); settings = validateReminder(body?.settings); }
    catch { throw new BadRequestException("Invalid subscription or reminder settings"); }
    const next = nextReminder(new Date(), settings);
    try {
      const result = await db.query(`INSERT INTO eled_push_devices(device_id,endpoint,subscription,settings,next_at)
        VALUES($1,$2,$3,$4,$5) ON CONFLICT(device_id) DO UPDATE SET endpoint=EXCLUDED.endpoint,
        subscription=EXCLUDED.subscription,settings=EXCLUDED.settings,updated_at=now(),
        next_at=CASE WHEN eled_push_devices.settings->>'interval'=EXCLUDED.settings->>'interval'
          AND eled_push_devices.settings->>'start'=EXCLUDED.settings->>'start'
          AND eled_push_devices.settings->>'end'=EXCLUDED.settings->>'end'
          AND eled_push_devices.settings->>'timezone'=EXCLUDED.settings->>'timezone'
          THEN eled_push_devices.next_at ELSE EXCLUDED.next_at END RETURNING next_at`,
        [id, subscription.endpoint, subscription, settings, next]);
      return { nextAt: result.rows[0].next_at };
    } catch (e: any) { if (e.code === "23505") throw new BadRequestException("Subscription already belongs to another device"); throw e; }
  }
  @Delete("subscription") async remove(@Headers("x-eled-device") token: string) {
    await db.query("DELETE FROM eled_push_devices WHERE device_id=$1", [deviceId(token)]);
    return { ok: true };
  }
  @Get("status") async status(@Headers("x-eled-device") token: string, @Res({ passthrough: true }) res: Response) {
    res.setHeader("Cache-Control", "no-store");
    const result = await db.query("SELECT next_at,last_error,history FROM eled_push_devices WHERE device_id=$1", [deviceId(token)]);
    const row = result.rows[0];
    return { active: !!row, nextAt: row?.next_at, error: row?.last_error, history: row?.history || [] };
  }
  @Post("test") async test(@Headers("x-eled-device") token: string) {
    requireConfigured();
    const id = deviceId(token);
    limit("test:" + id, 3);
    const row = (await db.query("SELECT * FROM eled_push_devices WHERE device_id=$1", [id])).rows[0];
    if (!row) throw new BadRequestException("Enable notifications first");
    const ok = await deliver(row, true);
    if (!ok) throw new ServiceUnavailableException("Browser push service could not accept the notification. Try enabling again.");
    return { accepted: true };
  }
}
async function deliver(row: any, test = false) {
  // Re-read immediately before sending: a word may have been marked known after job claim.
  row = (await db.query("SELECT * FROM eled_push_devices WHERE device_id=$1", [row.device_id])).rows[0];
  if (!row) return false;
  const settings = row.settings as ReminderSettings;
  const words = test ? [] : selectReminderWords(vocabulary, settings, row.word_offset);
  if (!test && !words.length) return true;
  try {
    await webpush.sendNotification(row.subscription, JSON.stringify(reminderPayload(words, settings.language, test)), {
      TTL: Math.min(settings.interval * 60, 3600), urgency: "normal", timeout: 10000,
    });
    const entry = { words: words.map(w => String(w[0]).toLowerCase()), sentAt: Date.now() };
    await db.query(`UPDATE eled_push_devices SET last_error=NULL,word_offset=word_offset+$2,
      history=CASE WHEN $3::boolean THEN history ELSE
        (SELECT COALESCE(jsonb_agg(value),'[]'::jsonb) FROM
          (SELECT value FROM jsonb_array_elements($4::jsonb || history) WITH ORDINALITY ORDER BY ordinality LIMIT 200) h) END
      WHERE device_id=$1`, [row.device_id, words.length, test, JSON.stringify([entry])]);
    return true;
  } catch (e: any) {
    if ([404, 410].includes(e.statusCode)) await db.query("DELETE FROM eled_push_devices WHERE device_id=$1", [row.device_id]);
    else {
      let reason = "";
      try { reason = JSON.parse(e.body).reason || ""; } catch { /* No provider detail. */ }
      if (!/^[A-Za-z0-9_]{1,80}$/.test(reason)) reason = "";
      const detail = Number.isInteger(e.statusCode) ? ` (${e.statusCode}${reason ? ": " + reason : ""})` : "";
      await db.query("UPDATE eled_push_devices SET last_error=$2 WHERE device_id=$1", [row.device_id, "Push service temporarily unavailable" + detail]);
    }
    return false;
  }
}
let ticking = false;
export async function runPushTick(now = new Date()) {
  if (ticking || !configured()) return;
  ticking = true;
  try {
    // A transaction claims each due device; other API instances skip locked rows.
    for (let i = 0; i < 100; i++) {
      const client = await db.connect();
      let row;
      try {
        await client.query("BEGIN");
        row = (await client.query("SELECT * FROM eled_push_devices WHERE next_at <= $1 ORDER BY next_at FOR UPDATE SKIP LOCKED LIMIT 1", [now])).rows[0];
        if (row) await client.query("UPDATE eled_push_devices SET next_at=$2 WHERE device_id=$1", [row.device_id, nextReminder(now, row.settings)]);
        await client.query("COMMIT");
      } catch (e) { await client.query("ROLLBACK"); throw e; }
      finally { client.release(); }
      if (!row) break;
      // Delayed jobs never send reminders outside the device's active hours.
      if (inActiveHours(now, row.settings)) await deliver(row);
    }
  } finally { ticking = false; }
}
export async function initPush(pool: Pool, words: any[][]) {
  db = pool;
  vocabulary = words;
  await db.query(`CREATE TABLE IF NOT EXISTS eled_push_devices(
    device_id text PRIMARY KEY,endpoint text UNIQUE NOT NULL,subscription jsonb NOT NULL,settings jsonb NOT NULL,
    next_at timestamptz NOT NULL,word_offset integer NOT NULL DEFAULT 0,history jsonb NOT NULL DEFAULT '[]',
    last_error text,updated_at timestamptz NOT NULL DEFAULT now())`);
  await db.query("CREATE INDEX IF NOT EXISTS eled_push_due ON eled_push_devices(next_at)");
  if (configured()) {
    webpush.setVapidDetails(process.env.VAPID_SUBJECT || "https://eled.vnlab.id.vn", process.env.VAPID_PUBLIC_KEY!, process.env.VAPID_PRIVATE_KEY!);
    setInterval(() => runPushTick().catch(() => console.error("Push scheduler failed")), 15000).unref();
    // Expired or abandoned device subscriptions do not remain indefinitely.
    await db.query("DELETE FROM eled_push_devices WHERE updated_at < now() - interval '180 days'");
    // Schedules saved before reminders were aligned to the clock grid drifted (09:59…); realign them.
    const now = new Date();
    for (const row of (await db.query("SELECT device_id,settings,next_at FROM eled_push_devices")).rows) {
      const aligned = nextReminder(new Date(Math.max(now.getTime(), new Date(row.next_at).getTime()) - 60000), row.settings);
      if (aligned.getTime() !== new Date(row.next_at).getTime())
        await db.query("UPDATE eled_push_devices SET next_at=$2 WHERE device_id=$1", [row.device_id, aligned]);
    }
  }
}
