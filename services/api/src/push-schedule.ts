export interface ReminderSettings {
  interval: number;
  count: number;
  start: string;
  end: string;
  timezone: string;
  levels: string[];
  topics: string[];
  excluded: string[];
  language: "vi" | "en";
}
export const intervals = [1, 10, 15, 20, 25, 30, 60, 120, 180];
export function validateReminder(value: any): ReminderSettings {
  if (!value || !intervals.includes(value.interval) || !Number.isInteger(value.count) || value.count < 1 || value.count > 5)
    throw new Error("Invalid reminder frequency or word count");
  for (const key of ["start", "end"])
    if (typeof value[key] !== "string" || !/^([01]\d|2[0-3]):[0-5]\d$/.test(value[key])) throw new Error("Invalid active hours");
  if (value.start === value.end) throw new Error("Start and end times must differ");
  if (typeof value.timezone !== "string" || value.timezone.length > 80) throw new Error("Invalid timezone");
  new Intl.DateTimeFormat("en", { timeZone: value.timezone }).format();
  for (const [key, limit] of [["levels", 5], ["topics", 100], ["excluded", 50000]] as const)
    if (!Array.isArray(value[key]) || value[key].length > limit || value[key].some((s: unknown) => typeof s !== "string" || s.length > 512))
      throw new Error("Invalid vocabulary filters");
  if (value.levels.some((l: string) => !["A1", "A2", "B1", "B2", "C1"].includes(l))) throw new Error("Invalid level");
  return { interval: value.interval, count: value.count, start: value.start, end: value.end, timezone: value.timezone,
    levels: value.levels, topics: value.topics, excluded: value.excluded, language: value.language === "en" ? "en" : "vi" };
}
const clocks = new Map<string, Intl.DateTimeFormat>();
/** "HH:MM" on the device's local clock (formatter cached: nextReminder calls this per minute walked). */
function localTime(date: Date, timeZone: string): string {
  let f = clocks.get(timeZone);
  if (!f) clocks.set(timeZone, (f = new Intl.DateTimeFormat("en-GB", { timeZone, hour: "2-digit", minute: "2-digit", hourCycle: "h23" })));
  return f.format(date);
}
const minutesOf = (hhmm: string) => Number(hhmm.slice(0, 2)) * 60 + Number(hhmm.slice(3, 5));
export function inActiveHours(date: Date, s: ReminderSettings): boolean {
  const local = localTime(date, s.timezone);
  return s.start < s.end ? local >= s.start && local < s.end : local >= s.start || local < s.end;
}
/**
 * Reminders land on the local clock grid start + k·interval (start 09:00, every 60 min ->
 * 09:00, 10:00…), not "last send + interval": the scheduler ticks every 15 s, so adding the
 * interval to the actual send time drifted to 09:59, 10:59… Walks real minutes, so DST is safe.
 */
export function nextReminder(now: Date, s: ReminderSettings): Date {
  const start = minutesOf(s.start);
  let t = new Date(now.getTime());
  t.setUTCSeconds(0, 0);
  for (let i = 0; i < 3 * 24 * 60; i++) {
    t = new Date(t.getTime() + 60000);
    if (!inActiveHours(t, s)) continue;
    if ((minutesOf(localTime(t, s.timezone)) - start + 1440) % 1440 % s.interval === 0) return t;
  }
  return t;
}
export function validatePushSubscription(value: any) {
  if (!value || typeof value.endpoint !== "string" || value.endpoint.length > 4096) throw new Error("Invalid subscription");
  const url = new URL(value.endpoint);
  const allowed = url.hostname === "fcm.googleapis.com" || url.hostname === "updates.push.services.mozilla.com" ||
    url.hostname.endsWith(".push.services.mozilla.com") || url.hostname === "web.push.apple.com" ||
    url.hostname.endsWith(".notify.windows.com");
  if (!allowed || url.protocol !== "https:" || url.username || url.password || (url.port && url.port !== "443")) throw new Error("Unsupported push endpoint");
  if (!value.keys || !/^[A-Za-z0-9_-]{87}=?$/.test(value.keys.p256dh) || !/^[A-Za-z0-9_-]{22}(==)?$/.test(value.keys.auth))
    throw new Error("Invalid push encryption keys");
  return { endpoint: url.href, keys: { p256dh: value.keys.p256dh, auth: value.keys.auth } };
}
export function selectReminderWords(vocabulary: any[][], s: ReminderSettings, offset: number) {
  const excluded = new Set(s.excluded);
  const words = vocabulary.filter(w => w[1] && !excluded.has(String(w[0]).toLowerCase()) &&
    (!s.levels.length || w[6].some((l: string) => s.levels.includes(l))) &&
    (!s.topics.length || w[7].some((t: string) => s.topics.includes(t.split(" - ")[0]))));
  return Array.from({ length: Math.min(s.count, words.length) }, (_, i) => words[(offset + i) % words.length]);
}
export function reminderPayload(words: any[][], language: string, test = false) {
  const body = test ? (language === "en" ? "Browser notifications are working. Your learning reminders are ready." : "Thông báo trình duyệt đã sẵn sàng. ELED sẽ nhắc bạn học theo lịch đã đặt.") :
    words.map(w => `${w[0]} ${w[3] || ""}\n${reminderMeaning(w)}`).join("\n\n");
  return { title: test ? "ELED · " + (language === "en" ? "Test notification" : "Thông báo thử") : "ELED · " + (language === "en" ? "Vocabulary reminder" : "Nhắc học từ vựng"),
    body: body.slice(0, 1200), url: "/#/history", tag: test ? "eled-test" : "eled-vocabulary", words: words.map(w => String(w[0]).toLowerCase()), sentAt: Date.now() };
}

// Thông báo chỉ có vài dòng: mỗi từ loại một nghĩa cốt lõi (trước ";", tối đa 3 cách nói),
// cùng quy tắc với shortMeaning() ở apps/web/src/model.ts. Không có senses thì giữ w[1].
const POS_ABBR: Record<string, string> = { noun: "n.", verb: "v.", adjective: "adj.", adverb: "adv.", preposition: "prep.", pronoun: "pron.", conjunction: "conj.", determiner: "det." };
function conciseSense(text: string) {
  const parts: string[] = [];
  let depth = 0, cur = "";
  for (const ch of String(text).split(/\s*;\s*/)[0]) {
    if (ch === "(" || ch === "[") depth++;
    if (ch === ")" || ch === "]") depth = Math.max(0, depth - 1);
    if (ch === "," && depth === 0) { parts.push(cur.trim()); cur = ""; } else cur += ch;
  }
  if (cur.trim()) parts.push(cur.trim());
  return parts.slice(0, 3).join(", ") || String(text);
}
export function reminderMeaning(w: any[]): string {
  const senses = (Array.isArray(w[8]) ? w[8] : []).filter((s: any) => Array.isArray(s?.[1]) && s[1].length);
  if (!senses.length) return String(w[1] ?? "");
  return senses.map((s: any) => `${senses.length > 1 ? `${POS_ABBR[s[0]] ?? `${s[0]}.`} ` : ""}${conciseSense(s[1][0])}`).join(" · ");
}
