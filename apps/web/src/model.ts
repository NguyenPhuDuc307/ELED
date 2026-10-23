export interface Word {
  word: string;
  translation: string;
  pos: string;
  ipa: string;
  audio: string;
  url: string;
  levels: string[];
  topics: string[];
  senses?: { pos: string; meanings: string[] }[];
}
export interface WordState {
  w: string;
  s: "fresh" | "learning" | "reviewing" | "mastered";
  e: number;
  i: number;
  r: number;
  d: number;
  l: number;
  t: number;
  p: number;
}
export type Rating = "again" | "hard" | "good" | "easy";
export interface SpeakingSet {
  id: string;
  topic: string;
  createdMs: number;
  items: { q: string; a: string; s: string[] }[];
}
export interface Profile {
  known: Record<string, boolean>;
  collections: Record<string, string[]>;
  srs: Record<string, WordState>;
  settings: Record<string, any>;
  speaking: Record<string, SpeakingSet>;
  custom: Record<string, string>;
  history: Record<string, number>;
  activity: Record<string, boolean>;
  /** Điểm cao nhất của từng bài ngữ pháp: b câu đúng / n câu, t = lúc làm. */
  grammar: Record<string, GrammarScore>;
  /** Câu ngữ pháp làm sai cần ôn, khoá "<bài>:<số thứ tự câu>". */
  grammarReview: Record<string, GrammarReview>;
}
/** d = lúc đến hạn ôn (ms), s = số lần đúng liên tiếp khi ôn. */
export interface GrammarReview {
  d: number;
  s: number;
}
export interface GrammarScore {
  b: number;
  n: number;
  t: number;
}
export type Operation = { section: keyof Profile; key: string; value: any };
export const emptyProfile = (): Profile => ({
  known: {},
  collections: {},
  srs: {},
  settings: {},
  speaking: {},
  custom: {},
  history: {},
  activity: {},
  grammar: {},
  grammarReview: {},
});
export function fresh(word: string): WordState {
  return {
    w: word.toLowerCase(),
    s: "fresh",
    e: 2.5,
    i: 0,
    r: 0,
    d: 0,
    l: 0,
    t: 0,
    p: 0,
  };
}
export function rate(
  state: WordState,
  rating: Rating,
  now = Date.now(),
): WordState {
  const s = { ...state, l: now, t: state.t + 1 };
  if (rating === "again") {
    s.e = Math.max(1.3, s.e - 0.2);
    s.i = 1;
    s.r = 0;
    s.s = "learning";
    if (["reviewing", "mastered"].includes(state.s)) s.p++;
  }
  if (rating === "hard") {
    s.e = Math.max(1.3, s.e - 0.15);
    s.i = Math.max(1, Math.round(s.i * 1.2));
    s.r++;
    s.s = s.r >= 2 ? "reviewing" : "learning";
  }
  if (rating === "good" || rating === "easy") {
    if (rating === "easy") {
      s.e = Math.min(3, s.e + 0.15);
      s.i = s.r === 0 ? 4 : Math.max(1, Math.round(s.i * s.e * 1.3));
    } else
      s.i = s.r === 0 ? 1 : s.r === 1 ? 4 : Math.max(1, Math.round(s.i * s.e));
    s.r++;
    s.s = s.i >= 60 ? "mastered" : s.i >= 4 ? "reviewing" : "learning";
  }
  s.d = now + s.i * 86400000;
  return s;
}
export function localDate(date = new Date()) {
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}-${String(date.getDate()).padStart(2, "0")}`;
}
export function reviewOperations(profile: Profile, word: string, rating: Rating, now = Date.now()): Operation[] {
  const key = word.toLowerCase();
  const state = rate(profile.srs[key] ?? fresh(key), rating, now);
  return [
    { section: "srs", key, value: rating === "easy" ? { ...state, s: "mastered", i: 365, d: now + 365 * 86400000 } : state },
    ...(rating === "easy" ? [{ section: "known" as const, key, value: true }] : []),
    { section: "activity", key: localDate(new Date(now)), value: true },
  ];
}
// Ease starts at 2.5 and only Easy can increase it. Recover provable past Easy choices.
export function legacyEasyOperations(profile: Profile): Operation[] {
  return Object.entries(profile.srs).filter(([key, s]) => s.e > 2.5 && !profile.known[key]).map(([key]) => ({ section: "known", key, value: true }));
}
export function streak(activity: Profile["activity"]) {
  let n = 0;
  const day = new Date();
  if (!activity[localDate(day)]) day.setDate(day.getDate() - 1);
  while (activity[localDate(day)]) {
    n++;
    day.setDate(day.getDate() - 1);
  }
  return n;
}
export function todaySession(words: Word[], profile: Profile) {
  return todayPlan(words, profile).words;
}
const levelOrder = ["A1", "A2", "B1", "B2", "C1", "C2"];
const levelRank = (w: Word) =>
  Math.min(...w.levels.map((l) => levelOrder.indexOf(l)).filter((n) => n >= 0), levelOrder.length);
export interface TopicInfo {
  topic: string;
  group: string;
  total: number;
  remaining: number;
}
function eligibleWords(words: Word[], profile: Profile) {
  const levels: string[] = profile.settings.levels ?? ["A1", "A2", "B1"];
  const topics: string[] = profile.settings.topics ?? [];
  return words.filter(
    (w) =>
      !profile.known[w.word.toLowerCase()] &&
      (!levels.length || w.levels.some((l) => levels.includes(l))) &&
      (!topics.length ||
        w.topics.some((t) => topics.some((p) => t.startsWith(p)))),
  );
}
/**
 * Thứ tự học các chủ đề: nhóm dễ trước, trong nhóm chủ đề dễ trước. Tính trên mọi từ
 * đủ điều kiện (không chỉ từ chưa học) để thứ tự không đổi theo tiến độ. Chủ đề người
 * dùng chọn (`settings.focusTopic`) được đưa lên đầu, kéo theo cả nhóm của nó.
 */
function topicOrder(eligible: Word[], profile: Profile) {
  const topics: string[] = profile.settings.topics ?? [];
  const focus: string | undefined = profile.settings.focusTopic;
  const average = (list: Word[]) => list.reduce((s, w) => s + levelRank(w), 0) / list.length;
  const byTopic = new Map<string, Word[]>();
  for (const w of eligible)
    for (const t of w.topics) {
      if (topics.length && !topics.some((p) => t.startsWith(p))) continue;
      byTopic.set(t, [...(byTopic.get(t) ?? []), w]);
    }
  const byGroup = new Map<string, string[]>();
  for (const t of byTopic.keys()) {
    const g = t.split(" - ")[0];
    byGroup.set(g, [...(byGroup.get(g) ?? []), t]);
  }
  const groupLevel = new Map([...byGroup].map(([g, ts]) => [g, average(ts.flatMap((t) => byTopic.get(t)!))]));
  const topicLevel = new Map([...byTopic].map(([t, ws]) => [t, average(ws)]));
  const first = (a: boolean, b: boolean) => Number(b) - Number(a);
  const focusGroup = focus && byTopic.has(focus) ? focus.split(" - ")[0] : undefined;
  const order = [...byGroup.keys()]
    .sort((a, b) => first(a === focusGroup, b === focusGroup) || groupLevel.get(a)! - groupLevel.get(b)! || a.localeCompare(b))
    .flatMap((g) => byGroup.get(g)!.sort((a, b) => first(a === focus, b === focus) || topicLevel.get(a)! - topicLevel.get(b)! || a.localeCompare(b)));
  return { order, byTopic };
}
/** Các chủ đề theo thứ tự học, kèm số từ chưa học, cho màn chọn chủ đề. */
export function topicList(words: Word[], profile: Profile): TopicInfo[] {
  const { order, byTopic } = topicOrder(eligibleWords(words, profile), profile);
  return order.map((topic) => {
    const list = byTopic.get(topic)!;
    return {
      topic,
      group: topic.split(" - ")[0],
      total: list.length,
      remaining: list.filter((w) => !profile.srs[w.word.toLowerCase()]).length,
    };
  });
}
/**
 * Phiên hôm nay: từ đến hạn ôn trước, rồi từ mới gom theo chủ đề (xem topicOrder):
 * học hết một chủ đề mới sang chủ đề kế, không nhảy lung tung giữa các lần mở app.
 * Từ không thuộc chủ đề nào (a, about, the…) vẫn cần học: chen vài từ mỗi phiên.
 */
export function todayPlan(words: Word[], profile: Profile): { words: Word[]; topic?: string } {
  const eligible = eligibleWords(words, profile);
  const due = eligible
    .filter((w) => {
      const s = profile.srs[w.word.toLowerCase()];
      return s && s.d > 0 && s.d <= Date.now();
    })
    .sort(
      (a, b) =>
        profile.srs[a.word.toLowerCase()].d -
        profile.srs[b.word.toLowerCase()].d,
    )
    .slice(0, 20);
  const limit = Math.min(10, 20 - due.length);
  const isNew = (w: Word) => !profile.srs[w.word.toLowerCase()];
  const unseen = eligible.filter(isNew);
  if (limit <= 0 || !unseen.length) return { words: due };

  const { order, byTopic } = topicOrder(eligible, profile);
  const easiest = (list: Word[]) => [...list].sort((a, b) => levelRank(a) - levelRank(b));
  const common = easiest(unseen.filter((w) => !w.topics.length));
  const picked = new Set<Word>();
  // Dành tối đa 2 chỗ cho từ thông dụng không chủ đề; phần còn lại theo chủ đề.
  const topicSlots = limit - Math.min(2, common.length);
  let topic: string | undefined;
  for (const t of order) {
    if (picked.size >= topicSlots) break;
    const fresh = easiest(byTopic.get(t)!.filter((w) => isNew(w) && !picked.has(w)));
    if (!fresh.length) continue;
    topic ??= t;
    for (const w of fresh.slice(0, topicSlots - picked.size)) picked.add(w);
  }
  for (const w of [...common, ...easiest(unseen)]) {
    if (picked.size >= limit) break;
    picked.add(w);
  }
  return { words: [...due, ...picked], topic };
}
export function shuffle<T>(list: T[]): T[] {
  return [...list].sort(() => Math.random() - 0.5);
}
export function parseSpeaking(raw: string, title = ""): SpeakingSet {
  const lines = raw
    .replace(/\r/g, "")
    .split("\n")
    .map((l) => l.trim())
    .filter(Boolean);
  const items: SpeakingSet["items"] = [];
  let q = "",
    a: string[] = [];
  let topic = title;
  const flush = () => {
    if (q) {
      const answer = a.join(" ");
      items.push({
        q,
        a: answer,
        s: answer.match(/[^.!?]+[.!?]+|[^.!?]+$/g)?.map((s) => s.trim()) ?? [],
      });
    }
  };
  for (const line of lines) {
    if (line.endsWith("?")) {
      flush();
      q = line;
      a = [];
    } else if (q) a.push(line);
    else if (!title) topic += (topic ? " " : "") + line;
  }
  flush();
  if (!items.length)
    throw new Error("Thêm câu hỏi kết thúc bằng ? và câu trả lời ở dòng dưới.");
  return {
    id: crypto.randomUUID(),
    topic: topic || "Speaking",
    items,
    createdMs: Date.now(),
  };
}
export function speakingScore(target: string, spoken: string) {
  const a = target.toLowerCase().match(/[a-z]+(?:'[a-z]+)?/g) ?? [];
  const b = spoken.toLowerCase().match(/[a-z]+(?:'[a-z]+)?/g) ?? [];
  const dp = Array.from(
    { length: a.length + 1 },
    () => new Uint16Array(b.length + 1),
  );
  for (let i = 1; i <= a.length; i++)
    for (let j = 1; j <= b.length; j++)
      dp[i][j] =
        a[i - 1] === b[j - 1]
          ? dp[i - 1][j - 1] + 1
          : Math.max(dp[i - 1][j], dp[i][j - 1]);
  return a.length ? Math.round((dp[a.length][b.length] / a.length) * 100) : 0;
}

// ---- Nghĩa gọn -----------------------------------------------------------
// Nguồn (Wiktionary) gom nhiều cách nói và cả câu giải thích vào một nghĩa:
// "đu đưa, đong đưa, đung đưa, lúc lắc, vung vẩy; lắc, lay, khuấy, đi…". Từ loại
// đã hiện riêng nên chỉ cần phần cốt lõi: trước dấu ";" và tối đa vài cách nói.
const POS_ABBR: Record<string, string> = {
  noun: "n.", verb: "v.", adjective: "adj.", adverb: "adv.", preposition: "prep.", pronoun: "pron.",
  conjunction: "conj.", determiner: "det.", interjection: "interj.", "modal verb": "modal", "auxiliary verb": "aux.",
  number: "num.", exclamation: "exclam.",
};
export const posAbbr = (pos: string) => POS_ABBR[pos] ?? `${pos}.`;

/** Một nghĩa, bỏ phần sau ";" và giữ tối đa `max` cách nói cách nhau bằng dấu phẩy (không cắt trong ngoặc). */
export function conciseSense(text: string, max = 3): string {
  const head = text.split(/\s*;\s*/)[0].trim();
  const parts: string[] = [];
  let depth = 0, cur = "";
  for (const ch of head) {
    if (ch === "(" || ch === "[") depth++;
    if (ch === ")" || ch === "]") depth = Math.max(0, depth - 1);
    if (ch === "," && depth === 0) { parts.push(cur.trim()); cur = ""; } else cur += ch;
  }
  if (cur.trim()) parts.push(cur.trim());
  return parts.slice(0, max).join(", ") || text;
}

/**
 * Nghĩa ngắn cho quiz, danh sách, đáp án: mỗi từ loại một nghĩa chính đã rút gọn;
 * có `pos` thì chỉ lấy đúng từ loại đó. Từ tự thêm (không có senses) giữ nguyên.
 */
export function shortMeaning(w: Pick<Word, "translation" | "senses">, pos?: string): string {
  const senses = w.senses?.filter((s) => s.meanings.length) ?? [];
  if (!senses.length) return w.translation;
  const pick = pos ? senses.filter((s) => s.pos === pos) : senses;
  const list = pick.length ? pick : senses;
  return list.map((s) => `${list.length > 1 ? `${posAbbr(s.pos)} ` : ""}${conciseSense(s.meanings[0], 1)}`).join(" · ");
}
