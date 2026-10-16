import { emptyProfile, fresh, type Operation, type Profile } from "./model";
export const CACHE_KEY = "eled.profile.v2";
const PENDING_KEY = "eled.pending.v2";
const ACCOUNT_KEY = "eled.account.v2";
function normalize(p: Profile): Profile {
  return Object.fromEntries(
    Object.entries(p).map(([section, values]) => [
      section,
      Object.assign(Object.create(null), values),
    ]),
  ) as Profile;
}
let profile = normalize(load());
let version = 0;
const listeners = new Set<() => void>();
export let pending: Operation[] = read(PENDING_KEY, []);
export let account: string | null = read(ACCOUNT_KEY, null);
export function read<T>(key: string, fallback: T): T {
  try {
    const value = localStorage.getItem(key);
    return value ? JSON.parse(value) : fallback;
  } catch {
    return fallback;
  }
}
function flutter<T>(key: string, fallback: T): T {
  let value = read<any>("flutter." + key, fallback);
  if (typeof value === "string") {
    try {
      value = JSON.parse(value);
    } catch {}
  }
  return value as T;
}
function load(): Profile {
  const existing = read<Profile | null>(CACHE_KEY, null);
  if (existing) return { ...emptyProfile(), ...existing };
  const p = emptyProfile();
  const known = flutter<string[]>("knownWords", []);
  p.known = Object.fromEntries(known.map((w) => [w.toLowerCase(), true]));
  p.collections = flutter("user_collections_data", {});
  p.srs = flutter("srsStates", {});
  p.custom = flutter("customWordTranslations", {});
  p.settings = {
    levels: flutter("selectedPopularity", ["A1", "A2", "B1"]),
    topics: flutter("selectedTopics", []),
    theme: flutter("themeMode", "system"),
    language: flutter("appLocale", "vi"),
    accent: flutter("ttsAccent", "us"),
    onboarded: flutter("onboardedV1", false),
    flutterImported: true,
  };
  for (const s of flutter<any[]>("speakingSets", [])) p.speaking[s.id] = s;
  for (const d of flutter<any>("streakState", {}).activeDays ?? [])
    p.activity[d] = true;
  flutter<string[]>("notificationHistory", []).forEach(
    (w, i) => (p.history[w.split("|")[0].toLowerCase()] = Date.now() - i),
  );
  if (!flutter("srsKnownWordsMigrated", false))
    for (const word of known)
      if (!p.srs[word])
        p.srs[word] = {
          ...fresh(word),
          s: "reviewing",
          i: 7,
          r: 2,
          d: Date.now() + 7 * 86400000,
          l: Date.now(),
          t: 1,
        };
  localStorage.setItem(CACHE_KEY, JSON.stringify(p));
  return p;
}
export function getProfile() {
  return profile;
}
export function subscribe(listener: () => void) {
  listeners.add(listener);
  return () => {
    listeners.delete(listener);
  };
}
export function snapshot() {
  return version;
}
function emit() {
  profile = normalize(profile);
  localStorage.setItem(CACHE_KEY, JSON.stringify(profile));
  version++;
  listeners.forEach((fn) => fn());
}
let notifySync: () => void = () => {};
export function onChange(fn: () => void) {
  notifySync = fn;
}
export function change(section: keyof Profile, key: string, value: any) {
  apply([{ section, key, value }]);
}
export function apply(ops: Operation[], enqueue = true) {
  profile = normalize(structuredClone(profile));
  for (const op of ops) {
    const part = profile[op.section] as Record<string, any>;
    if (op.value === null) delete part[op.key];
    else part[op.key] = op.value;
  }
  if (enqueue) {
    pending.push(...ops);
    localStorage.setItem(PENDING_KEY, JSON.stringify(pending));
  }
  emit();
  if (enqueue) notifySync();
}
export function setPending(ops: Operation[]) {
  pending = ops;
  localStorage.setItem(PENDING_KEY, JSON.stringify(pending));
}
export function allOperations(p = profile): Operation[] {
  return Object.entries(p).flatMap(([section, values]) =>
    Object.entries(values).map(([key, value]) => ({
      section: section as keyof Profile,
      key,
      value,
    })),
  );
}
export function acceptRemote(remote: Profile) {
  const currentPending = [...pending];
  profile = normalize({ ...emptyProfile(), ...remote });
  apply(currentPending, false);
}
export function bindAccount(uid: string) {
  if (account && account !== uid) {
    profile = emptyProfile();
    setPending([]);
    emit();
  }
  if (!account) setPending(allOperations());
  account = uid;
  localStorage.setItem(ACCOUNT_KEY, JSON.stringify(uid));
}
export function detachAccount() {
  profile = emptyProfile();
  account = null;
  setPending([]);
  localStorage.removeItem(ACCOUNT_KEY);
  emit();
}
export function importBackup(raw: unknown) {
  if (!raw || typeof raw !== "object")
    throw new Error("Tệp sao lưu không hợp lệ");
  const b = raw as any;
  const ops: Operation[] = [];
  if (b.data) {
    for (const op of allOperations({ ...emptyProfile(), ...b.data }))
      ops.push(op);
  } else {
    if (
      !Array.isArray(b.knownWords) ||
      !b.collections ||
      typeof b.collections !== "object"
    )
      throw new Error("Tệp sao lưu không hợp lệ");
    for (const w of b.knownWords) {
      if (typeof w !== "string") throw new Error("Từ không hợp lệ");
      ops.push({ section: "known", key: w.toLowerCase(), value: true });
    }
    for (const [name, words] of Object.entries(b.collections)) {
      if (!Array.isArray(words) || words.some((w) => typeof w !== "string"))
        throw new Error("Bộ sưu tập không hợp lệ");
      ops.push({
        section: "collections",
        key: name,
        value: [...new Set([...(profile.collections[name] ?? []), ...words])],
      });
    }
  }
  for (const op of ops) {
    if (
      !Object.keys(emptyProfile()).includes(op.section) ||
      op.key === "__proto__"
    )
      throw new Error("Tệp không hợp lệ");
    const v = op.value;
    if (
      (op.section === "known" || op.section === "activity") &&
      typeof v !== "boolean"
    )
      throw new Error("Dữ liệu đánh dấu không hợp lệ");
    if (
      op.section === "collections" &&
      (!Array.isArray(v) || v.some((w) => typeof w !== "string"))
    )
      throw new Error("Bộ sưu tập không hợp lệ");
    if (
      op.section === "srs" &&
      (!v ||
        typeof v.w !== "string" ||
        !["fresh", "learning", "reviewing", "mastered"].includes(v.s) ||
        ["e", "i", "r", "d", "l", "t", "p"].some(
          (k) => typeof v[k] !== "number" || !Number.isFinite(v[k]) || v[k] < 0,
        ))
    )
      throw new Error("Tiến độ không hợp lệ");
    if (
      op.section === "speaking" &&
      (!v ||
        typeof v.topic !== "string" ||
        !Array.isArray(v.items) ||
        v.items.some(
          (i: any) =>
            typeof i.q !== "string" ||
            typeof i.a !== "string" ||
            !Array.isArray(i.s),
        ))
    )
      throw new Error("Bài nói không hợp lệ");
    if (op.section === "custom" && typeof v !== "string")
      throw new Error("Từ tùy chỉnh không hợp lệ");
    if (
      op.section === "history" &&
      (typeof v !== "number" || !Number.isFinite(v))
    )
      throw new Error("Lịch sử không hợp lệ");
  }
  apply(ops);
  return ops.length;
}
export function downloadBackup() {
  const blob = new Blob(
    [
      JSON.stringify(
        {
          version: "2",
          exportedAt: new Date().toISOString(),
          knownWords: Object.keys(profile.known).filter(
            (w) => profile.known[w],
          ),
          collections: profile.collections,
          data: profile,
        },
        null,
        2,
      ),
    ],
    { type: "application/json" },
  );
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = `eled-backup-${new Date().toISOString().slice(0, 10)}.json`;
  a.click();
  setTimeout(() => URL.revokeObjectURL(url), 1000);
}
