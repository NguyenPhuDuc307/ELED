import { test } from "node:test";
import assert from "node:assert/strict";
import { applyOperations, emptyProfile, validateOperations } from "./profile";
test("Per-key changes preserve other devices progress and allow explicit deletion", () => {
  const p = emptyProfile();
  p.collections.Work = ["job"];
  p.known.hello = true;
  const next = applyOperations(
    p,
    validateOperations([
      { section: "known", key: "world", value: true },
      { section: "collections", key: "Work", value: null },
    ]),
  );
  assert.deepEqual(next.known, { hello: true, world: true });
  assert.deepEqual(next.collections, {});
  assert.deepEqual(p.collections, { Work: ["job"] });
});
test("Rejects prototype keys, invalid SRS and unknown sections", () => {
  for (const op of [
    { section: "known", key: "__proto__", value: true },
    { section: "password", key: "a", value: true },
    { section: "srs", key: "hi", value: {} },
  ])
    assert.throws(() => validateOperations([op]));
});

test("the web app's chosen topic setting is accepted", () => {
  assert.doesNotThrow(() => validateOperations([{ section: "settings", key: "focusTopic", value: "Animals - Pets" }]));
  assert.doesNotThrow(() => validateOperations([{ section: "settings", key: "focusTopic", value: null }]));
  assert.throws(() => validateOperations([{ section: "settings", key: "focusTopic", value: 3 }]));
});
