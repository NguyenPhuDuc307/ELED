import { test } from "node:test";
import assert from "node:assert/strict";
import {
  emptyProfile,
  fresh,
  localDate,
  parseSpeaking,
  rate,
  speakingScore,
  todaySession,
  type Word,
} from "./model";
test("SRS matches the existing mobile schedule and retains lapse history", () => {
  const first = rate(fresh("Hello"), "easy", 100);
  assert.equal(first.i, 4);
  assert.equal(first.e, 2.65);
  assert.equal(first.s, "reviewing");
  assert.equal(first.d, 345600100);
  const lapse = rate(first, "again", 200);
  assert.equal(lapse.p, 1);
  assert.equal(lapse.r, 0);
  assert.equal(lapse.i, 1);
});
test("Sessions prioritize due words, exclude known, filter levels, cap new words at ten", () => {
  const words: Word[] = Array.from({ length: 25 }, (_, i) => ({
    word: "word" + i,
    translation: "meaning",
    pos: "",
    ipa: "",
    audio: "",
    url: "",
    levels: [i === 24 ? "C1" : "A1"],
    topics: [],
  }));
  const p = emptyProfile();
  p.known.word0 = true;
  p.srs.word1 = { ...fresh("word1"), d: 1, t: 1 };
  const session = todaySession(words, p);
  assert.equal(session[0].word, "word1");
  assert.equal(session.length, 11);
  assert.ok(!session.some((w) => ["word0", "word24"].includes(w.word)));
});
test("Speaking import and order-sensitive scoring preserve answer text", () => {
  const s = parseSpeaking(
    "Hobbies\nWhat do you like?\nI like books. They are fun!",
  );
  assert.equal(s.topic, "Hobbies");
  assert.equal(s.items[0].s.length, 2);
  assert.equal(
    speakingScore("I really enjoy reading", "really enjoy reading"),
    75,
  );
});
