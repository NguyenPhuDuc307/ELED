import { test } from "node:test";
import assert from "node:assert/strict";
import {
  conciseSense,
  emptyProfile,
  fresh,
  localDate,
  parseSpeaking,
  rate,
  speakingScore,
  todaySession,
  type Word,
  shortMeaning,
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

test('Easy marks a word known and removes it from future sessions; other ratings do not', async () => {
  const { reviewOperations, legacyEasyOperations } = await import('./model');
  const p = emptyProfile();
  const ops = reviewOperations(p, 'Hello', 'easy', 100);
  for (const op of ops) (p[op.section] as any)[op.key] = op.value;
  assert.equal(p.known.hello, true);
  assert.equal(p.srs.hello.s, 'mastered');
  const word: Word = { word: 'Hello', translation: 'xin chào', pos: '', ipa: '', audio: '', url: '', levels: ['A1'], topics: [] };
  assert.deepEqual(todaySession([word], p), []);
  assert.ok(!reviewOperations(emptyProfile(), 'hello', 'hard').some(op => op.section === 'known'));
  const legacy = emptyProfile();
  legacy.srs.easy = rate(fresh('easy'), 'easy');
  legacy.srs.good = rate(fresh('good'), 'good');
  assert.deepEqual(legacyEasyOperations(legacy).map(op => op.key), ['easy']);
});

test("Meanings are trimmed to the core sense per part of speech", () => {
  assert.equal(conciseSense("đu đưa, đong đưa, đung đưa, lúc lắc, vung vẩy; lắc, lay, khuấy"), "đu đưa, đong đưa, đung đưa");
  assert.equal(conciseSense("một; một cái, một người (mạo từ bất định)"), "một");
  // Dấu phẩy trong ngoặc không bị cắt.
  assert.equal(conciseSense("mùi (hương, vị), hơi"), "mùi (hương, vị), hơi");
  const swing = {
    translation: "v. đu đưa, đong đưa… · n. sự đu đưa…",
    senses: [
      { pos: "verb", meanings: ["đu đưa, đong đưa, đung đưa, lúc lắc, vung vẩy; lắc, lay", "vung"] },
      { pos: "noun", meanings: ["sự đu đưa, sự lúc lắc; độ đu đưa, độ lắc"] },
    ],
  };
  assert.equal(shortMeaning(swing), "v. đu đưa, đong đưa, đung đưa · n. sự đu đưa, sự lúc lắc");
  assert.equal(shortMeaning(swing, "noun"), "sự đu đưa, sự lúc lắc");
  // Từ tự thêm không có senses: giữ nguyên nghĩa người dùng nhập.
  assert.equal(shortMeaning({ translation: "nghĩa của tôi, rất dài; giữ nguyên" }), "nghĩa của tôi, rất dài; giữ nguyên");
});
