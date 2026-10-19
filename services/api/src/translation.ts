import { BadRequestException, Body, Controller, Post, ServiceUnavailableException } from "@nestjs/common";

const cache = new Map<string, string>();
const pending = new Map<string, Promise<string>>();

async function translate(text: string): Promise<string> {
  const cached = cache.get(text);
  if (cached) return cached;
  const running = pending.get(text);
  if (running) return running;
  if (pending.size >= 16) throw new ServiceUnavailableException("Translation busy");
  const request = (async () => {
    try {
      const url = new URL("https://translate.googleapis.com/translate_a/single");
      url.search = new URLSearchParams({ client: "gtx", sl: "en", tl: "vi", dt: "t", q: text }).toString();
      const response = await fetch(url, { signal: AbortSignal.timeout(12000) });
      if (!response.ok) throw new Error("Translation unavailable");
      const data = await response.json() as unknown;
      if (!Array.isArray(data) || !Array.isArray(data[0])) throw new Error("Invalid translation");
      const result = data[0].map((part: unknown) => Array.isArray(part) && typeof part[0] === "string" ? part[0] : "").join("").trim();
      if (!result) throw new Error("Empty translation");
      if (cache.size >= 2000) cache.delete(cache.keys().next().value!);
      cache.set(text, result);
      return result;
    } catch {
      throw new ServiceUnavailableException("Translation unavailable. Please retry.");
    } finally {
      pending.delete(text);
    }
  })();
  pending.set(text, request);
  return request;
}

@Controller("api/eled")
export class TranslationController {
  @Post("translate")
  async translate(@Body() body: unknown) {
    const texts = (body as { texts?: unknown } | null)?.texts;
    if (!Array.isArray(texts) || texts.length < 1 || texts.length > 4 ||
      texts.some(text => typeof text !== "string" || !text.trim() || text.length > 2000)) {
      throw new BadRequestException("Expected one to four definitions");
    }
    return { translations: await Promise.all(texts.map(text => translate(text))) };
  }
}
