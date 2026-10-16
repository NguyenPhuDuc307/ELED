export interface Word {
  word: string;
  translation: string;
  pos: string;
  ipa: string;
  audio: string;
  url: string;
  levels: string[];
  topics: string[];
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
  const levels: string[] = profile.settings.levels ?? ["A1", "A2", "B1"];
  const topics: string[] = profile.settings.topics ?? [];
  const eligible = words.filter(
    (w) =>
      !profile.known[w.word.toLowerCase()] &&
      (!levels.length || w.levels.some((l) => levels.includes(l))) &&
      (!topics.length ||
        w.topics.some((t) => topics.some((p) => t.startsWith(p)))),
  );
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
  return [
    ...due,
    ...eligible
      .filter((w) => !profile.srs[w.word.toLowerCase()])
      .slice(0, Math.min(10, 20 - due.length)),
  ];
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
