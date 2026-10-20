import "reflect-metadata";
import { test } from "node:test";
import assert from "node:assert/strict";
import { TranslationController } from "./translation";

test("Translation validates input, parses provider output, caches successes and permits retry after failure", async () => {
  const controller = new TranslationController();
  await assert.rejects(controller.translate({ texts: [""] }));
  await assert.rejects(controller.translate({ texts: ["hello"], target: "fr" }));
  await assert.rejects(controller.translate({ texts: Array(5).fill("definition") }));
  const original = globalThis.fetch;
  let calls = 0;
  globalThis.fetch = (async (input: URL) => {
    calls++;
    assert.equal(input.hostname, "translate.googleapis.com");
    assert.equal(input.searchParams.get("tl"), "vi");
    return new Response(JSON.stringify([[["Có chất lượng cao.", "Of high quality."]]]));
  }) as typeof fetch;
  try {
    assert.deepEqual(await controller.translate({ texts: ["Of high quality."] }), { translations: ["Có chất lượng cao."] });
    await controller.translate({ texts: ["Of high quality."] });
    assert.equal(calls, 1);
    globalThis.fetch = (async (input: URL) => {
      assert.equal(input.searchParams.get("tl"), "en");
      assert.equal(input.searchParams.get("sl"), "auto");
      return new Response(JSON.stringify([[["High quality."]]]));
    }) as typeof fetch;
    assert.deepEqual(await controller.translate({ texts: ["Of high quality."], target: "en" }), { translations: ["High quality."] });
    // The target-language cache must not replace the original definition translation.
    assert.deepEqual(await controller.translate({ texts: ["Of high quality."] }), { translations: ["Có chất lượng cao."] });
    globalThis.fetch = (async () => new Response("unavailable", { status: 503 })) as typeof fetch;
    await assert.rejects(controller.translate({ texts: ["Retry definition"] }));
    globalThis.fetch = (async () => new Response(JSON.stringify([[["Thử lại."]]]))) as typeof fetch;
    assert.deepEqual(await controller.translate({ texts: ["Retry definition"] }), { translations: ["Thử lại."] });
  } finally { globalThis.fetch = original; }
});
