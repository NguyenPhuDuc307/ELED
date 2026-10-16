import {
  change,
  getProfile,
  pending,
  setPending,
  bindAccount,
  detachAccount,
  acceptRemote,
  onChange,
  read,
} from "./storage";
import type { Profile } from "./model";
let currentUser: any = null;
let busy = false;
let timer: ReturnType<typeof setTimeout>;
let poll: ReturnType<typeof setInterval>;
export let status: "local" | "syncing" | "synced" | "error" = "local";
export let user: {
  uid: string;
  name: string;
  email: string;
  photo: string;
} | null = null;
const listeners = new Set<() => void>();
export function subscribeAuth(fn: () => void) {
  listeners.add(fn);
  return () => {
    listeners.delete(fn);
  };
}
function emit() {
  listeners.forEach((fn) => fn());
}
async function request(
  method = "GET",
  operations?: unknown,
  signingUser = currentUser,
) {
  const token = await signingUser.getIdToken();
  const response = await fetch("/api/eled/profile", {
    method,
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
    body: operations ? JSON.stringify({ operations }) : undefined,
  });
  if (!response.ok) throw new Error(`Sync failed (${response.status})`);
  return response.json();
}
export async function sync() {
  if (!currentUser || busy || !navigator.onLine) return;
  const signingUser = currentUser;
  const uid = signingUser.uid;
  busy = true;
  status = "syncing";
  emit();
  try {
    while (pending.length) {
      const batch = pending.slice(0, 300);
      await request("PATCH", batch, signingUser);
      if (currentUser?.uid !== uid) return;
      setPending(pending.slice(batch.length));
    }
    const remote = await request("GET", undefined, signingUser);
    if (currentUser?.uid !== uid) return;
    acceptRemote(remote.data);
    status = "synced";
  } catch (e) {
    if (currentUser?.uid === uid) status = "error";
    console.warn("Progress sync:", (e as Error).message);
  } finally {
    busy = false;
    emit();
    if (currentUser && currentUser.uid !== uid) scheduleSync();
  }
}
export function scheduleSync() {
  clearTimeout(timer);
  timer = setTimeout(sync, 500);
}
onChange(scheduleSync);
window.addEventListener("online", sync);
let sdk: typeof import("./firebase") | null = null;
export async function initAuth() {
  sdk = await import("./firebase");
  sdk.observe(async (u) => {
    clearInterval(poll);
    currentUser = u;
    user = u
      ? {
          uid: u.uid,
          name: u.displayName ?? "",
          email: u.email ?? "",
          photo: u.photoURL ?? "",
        }
      : null;
    if (u) {
      bindAccount(u.uid);
      await sync();
      poll = setInterval(sync, 30000);
    } else status = "local";
    emit();
  });
}
export async function login() {
  sdk ??= await import("./firebase");
  await sdk.login();
}
export async function logout() {
  await sync();
  if (pending.length)
    throw new Error("Chưa đồng bộ xong. Hãy thử lại khi có mạng.");
  sdk ??= await import("./firebase");
  await sdk.logout();
  detachAccount();
}
// Read the former Firebase data once on explicit import; all future writes use
// PostgreSQL. Firebase is otherwise used exclusively for identity.
export async function importLegacyFirebase() {
  if (!currentUser) throw new Error("Đăng nhập trước khi chuyển dữ liệu");
  sdk ??= await import("./firebase");
  const legacy = await sdk.readLegacy(currentUser.uid);
  const p = getProfile();
  for (const word of legacy.knownWords ?? [])
    if (!p.known[word]) change("known", word.toLowerCase(), true);
  for (const [name, words] of Object.entries(legacy.collections))
    change("collections", name, [
      ...new Set([...(p.collections[name] ?? []), ...words]),
    ]);
  if (legacy.settings) {
    const s = legacy.settings;
    if (s.selectedPopularity)
      change("settings", "levels", s.selectedPopularity);
    if (s.selectedTopics) change("settings", "topics", s.selectedTopics);
    if (s.themeMode) change("settings", "theme", s.themeMode);
  }
  change("settings", "firebaseImported", true);
  await sync();
}
