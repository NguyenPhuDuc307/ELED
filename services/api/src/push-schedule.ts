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
export function inActiveHours(date: Date, s: ReminderSettings): boolean {
  const local = new Intl.DateTimeFormat("en-GB", { timeZone: s.timezone, hour: "2-digit", minute: "2-digit", hourCycle: "h23" }).format(date);
  return s.start < s.end ? local >= s.start && local < s.end : local >= s.start || local < s.end;
}
export function nextReminder(now: Date, s: ReminderSettings): Date {
  let next = new Date(now.getTime() + s.interval * 60000);
  if (inActiveHours(next, s)) return next;
  next.setUTCSeconds(0, 0);
  // Walk real minutes, including DST changes, until this device's local active window.
  for (let i = 0; i < 48 * 60 && !inActiveHours(next, s); i++) next = new Date(next.getTime() + 60000);
  return next;
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
    words.map(w => `${w[0]} ${w[3] || ""}\n${w[1]}`).join("\n\n");
  return { title: test ? "ELED · " + (language === "en" ? "Test notification" : "Thông báo thử") : "ELED · " + (language === "en" ? "Vocabulary reminder" : "Nhắc học từ vựng"),
    body: body.slice(0, 1200), url: "/#/history", tag: test ? "eled-test" : "eled-vocabulary", words: words.map(w => String(w[0]).toLowerCase()), sentAt: Date.now() };
}
