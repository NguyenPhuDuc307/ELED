import { test } from "node:test";
import assert from "node:assert/strict";
const values = new Map<string, string>();
Object.defineProperty(globalThis, "localStorage", {
  value: {
    getItem: (key: string) => values.get(key) ?? null,
    setItem: (key: string, value: string) => values.set(key, value),
    removeItem: (key: string) => values.delete(key),
  },
});
values.set("flutter.knownWords", JSON.stringify(["above"]));
values.set(
  "flutter.user_collections_data",
  JSON.stringify(JSON.stringify({ Work: ["job"] })),
);
values.set(
  "flutter.srsStates",
  JSON.stringify(
    JSON.stringify({
      hello: {
        w: "hello",
        s: "reviewing",
        e: 2.5,
        i: 4,
        r: 2,
        d: 9000,
        l: 1000,
        t: 2,
        p: 0,
      },
    }),
  ),
);
values.set("flutter.appLocale", JSON.stringify("en"));
const store = await import("./storage");
test("Reads both SharedPreferences JSON layers without changing legacy keys", () => {
  const p = store.getProfile();
  assert.equal(p.known.above, true);
  assert.deepEqual(p.collections.Work, ["job"]);
  assert.equal(p.srs.hello.d, 9000);
  assert.equal(p.settings.language, "en");
  assert.ok(values.has("flutter.user_collections_data"));
  assert.equal(p.known.constructor, undefined);
});
test("Remote updates preserve unsent local edits", () => {
  store.change("known", "constructor", true);
  const remote = { ...store.getProfile(), known: { world: true } };
  store.acceptRemote(remote);
  assert.equal(store.getProfile().known.world, true);
  assert.equal(store.getProfile().known.constructor, true);
});
test("Switching accounts clears private data and pending operations", () => {
  store.bindAccount("first-user");
  store.change("collections", "Private", ["hello"]);
  store.bindAccount("second-user");
  assert.equal(Object.keys(store.getProfile().collections).length, 0);
  assert.equal(store.pending.length, 0);
});
