import test from "node:test";
import assert from "node:assert/strict";
import { grammarGroups, grammarUnits, normalizeAnswer } from "./grammar/index";

test("Grammar units are well-formed: unique ids, known groups, valid exercises", () => {
  const ids = new Set<string>();
  const groups = new Set(grammarGroups.map((g) => g.id));
  for (const u of grammarUnits) {
    assert.ok(!ids.has(u.id), `duplicate id ${u.id}`);
    ids.add(u.id);
    assert.ok(groups.has(u.group), `${u.id}: unknown group`);
    assert.ok(u.rules.length >= 3 && u.exercises.length === 10, `${u.id}: rules/exercises count`);
    for (const r of u.rules)
      for (const e of r.examples) assert.equal((e.en.match(/\*\*/g) ?? []).length % 2, 0, `${u.id}: unbalanced ** in ${e.en}`);
    for (const e of u.exercises) {
      assert.ok(e.explain.trim(), `${u.id}: missing explanation`);
      if (e.type === "choice") {
        assert.ok(e.answer >= 0 && e.answer < e.options.length, `${u.id}: answer index ${e.q}`);
        assert.equal(new Set(e.options).size, e.options.length, `${u.id}: duplicate option ${e.q}`);
      } else {
        assert.equal(e.q.split("___").length, 2, `${u.id}: fill needs exactly one blank: ${e.q}`);
        assert.ok(e.answers.length, `${u.id}: fill has no answers`);
      }
    }
  }
  assert.equal(grammarUnits.length, 21);
});

test("Typed answers are compared leniently", () => {
  assert.equal(normalizeAnswer("  Has   Risen. "), "has risen");
  assert.equal(normalizeAnswer("doesn’t drink"), "doesn't drink");
});

test("Missed questions follow a 1 → 3 → 7 day review ladder and leave after three correct", async () => {
  const { nextReview } = await import("./grammar/index");
  const day = 86400000;
  const missed = nextReview(undefined, false, 0)!;
  assert.deepEqual(missed, { d: day, s: 0 });
  assert.equal(nextReview(undefined, true, 0), undefined);
  const once = nextReview(missed, true, day)!;
  assert.deepEqual(once, { d: day + 3 * day, s: 1 });
  const twice = nextReview(once, true, 4 * day)!;
  assert.deepEqual(twice, { d: 11 * day, s: 2 });
  assert.equal(nextReview(twice, true, 11 * day), null);
  assert.deepEqual(nextReview(twice, false, 11 * day), { d: 12 * day, s: 0 });
});

test("Placement results steer the recommended unit; review items resolve to exercises", async () => {
  const { recommendedUnit, placementItems, placementKey, reviewItems, mixedItems } = await import("./grammar/index");
  assert.equal(placementItems(grammarUnits).length, grammarUnits.length);
  const [first, , third] = grammarUnits;
  assert.equal(recommendedUnit(grammarUnits, {})?.id, first.id);
  const scores = { [placementKey(third.id)]: { b: 0, n: 1, t: 1 }, [placementKey(first.id)]: { b: 1, n: 1, t: 1 } };
  assert.equal(recommendedUnit(grammarUnits, scores)?.id, third.id);
  scores[third.id] = { b: 9, n: 10, t: 2 };
  assert.equal(recommendedUnit(grammarUnits, scores)?.id, first.id);
  const items = reviewItems(grammarUnits, { [`${third.id}:2`]: { d: 5, s: 0 }, "gone-unit:1": { d: 1, s: 0 }, [`${first.id}:0`]: { d: 99, s: 0 } }, 10);
  assert.deepEqual(items.map((i) => [i.unit.id, i.index]), [[third.id, 2]]);
  const mixed = mixedItems(grammarUnits, { [third.id]: { b: 5, n: 10, t: 1 } });
  assert.equal(mixed.length, 10);
  assert.ok(mixed.every((i) => i.unit.id === third.id));
});
