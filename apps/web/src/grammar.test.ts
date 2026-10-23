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
