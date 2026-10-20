import { BadRequestException, Body, Controller, Post, ServiceUnavailableException } from "@nestjs/common";

const cache = new Map<string, string>();
const pending = new Map<string, Promise<string>>();

async function translate(text: string, target: "vi" | "en", source: "en" | "auto"): Promise<string> {
  const key = `${source}:${target}:${text}`;
  const cached = cache.get(key);
  if (cached) return cached;
  const running = pending.get(key);
  if (running) return running;
  if (pending.size >= 16) throw new ServiceUnavailableException("Translation busy");
  const request = (async () => {
    try {
      const url = new URL("https://translate.googleapis.com/translate_a/single");
      url.search = new URLSearchParams({ client: "gtx", sl: source, tl: target, dt: "t", q: text }).toString();
      const response = await fetch(url, { signal: AbortSignal.timeout(12000) });
      if (!response.ok) throw new Error(`Translation provider returned ${response.status}`);
      const data = await response.json() as unknown;
      if (!Array.isArray(data) || !Array.isArray(data[0])) throw new Error("Invalid translation");
      const result = data[0].map((part: unknown) => Array.isArray(part) && typeof part[0] === "string" ? part[0] : "").join("").trim();
      if (!result) throw new Error("Empty translation");
      if (cache.size >= 2000) cache.delete(cache.keys().next().value!);
      cache.set(key, result);
      return result;
    } catch (error) {
      console.warn("Translation request failed", error instanceof Error ? error.message : "Unknown provider error");
      throw new ServiceUnavailableException("Translation unavailable. Please retry.");
    } finally {
      pending.delete(key);
    }
  })();
  pending.set(key, request);
  return request;
}

@Controller("api/eled")
export class TranslationController {
  @Post("translate")
  async translate(@Body() body: unknown) {
    const input = body as { texts?: unknown; target?: unknown } | null;
    const texts = input?.texts;
    if (input?.target !== undefined && input.target !== "en" && input.target !== "vi") {
      throw new BadRequestException("Target must be en or vi");
    }
    const target = input?.target === "en" ? "en" : "vi";
    const source = input?.target === undefined ? "en" : "auto";
    if (!Array.isArray(texts) || texts.length < 1 || texts.length > 4 ||
      texts.some(text => typeof text !== "string" || !text.trim() || text.length > 2000)) {
      throw new BadRequestException("Expected one to four definitions");
    }
    return { translations: await Promise.all(texts.map(text => translate(text.trim(), target, source))) };
  }
}
