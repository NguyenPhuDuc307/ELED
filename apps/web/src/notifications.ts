import { account, apply, getProfile, subscribe, read } from "./storage";
export interface NotificationSettings {
  enabled: boolean; interval: number; count: number; start: string; end: string; timezone: string;
}
const CONFIG = "eled.browser-reminders.v1";
const DEVICE = "eled.push-device.v1";
const OWNER = "eled.push-owner.v1";
let boundAccount: string | null = null;
let historyBusy = false;
export function notificationSettings(): NotificationSettings {
  return read(CONFIG, { enabled: false, interval: 30, count: 1, start: "09:00", end: "19:00", timezone: Intl.DateTimeFormat().resolvedOptions().timeZone });
}
export function pushSupported() { return isSecureContext && "Notification" in window && "serviceWorker" in navigator && "PushManager" in window; }
export function needsHomeScreen() {
  return /iPad|iPhone|iPod/.test(navigator.userAgent) || (navigator.platform === "MacIntel" && navigator.maxTouchPoints > 1);
}
function deviceToken() {
  let value = read<string | null>(DEVICE, null);
  if (!value) {
    value = [...crypto.getRandomValues(new Uint8Array(32))].map(n => n.toString(16).padStart(2, "0")).join("");
    localStorage.setItem(DEVICE, JSON.stringify(value));
  }
  return value;
}
async function request(path: string, method = "GET", body?: unknown) {
  const response = await fetch("/api/eled/push/" + path, { method,
    keepalive: path === "exclude",
    headers: { "Content-Type": "application/json", "X-Eled-Device": deviceToken() },
    body: body ? JSON.stringify(body) : undefined });
  if (!response.ok) throw new Error(response.status === 429 ? "Thao tác quá nhanh. Hãy thử lại sau một phút. / Please wait one minute." : "Không kết nối được dịch vụ thông báo. Hãy thử lại. / Notification service unavailable.");
  return response.json();
}
export async function pushRegistration() {
  await navigator.serviceWorker.register("/notifications-sw.js", { scope: "/", updateViaCache: "none" });
  return navigator.serviceWorker.ready;
}
function schedulePayload(s: NotificationSettings) {
  const p = getProfile();
  return { ...s, levels: p.settings.levels ?? ["A1", "A2", "B1"], topics: p.settings.topics ?? [],
    excluded: Object.keys(p.known).filter(k => p.known[k]), language: p.settings.language === "en" ? "en" : "vi" };
}
export async function saveNotifications(s: NotificationSettings, askPermission = false) {
  if (!askPermission && notificationSettings().enabled && read<string | null>(OWNER, null) !== account) {
    await disableNotifications();
    throw new Error("Bật lại thông báo cho tài khoản này. / Enable notifications for this account.");
  }
  if (!pushSupported()) throw new Error("Trình duyệt chưa hỗ trợ Web Push. / Web Push is unavailable.");
  // Ask synchronously within the button gesture, before network requests.
  if (askPermission && Notification.permission !== "granted") {
    const permission = await Notification.requestPermission();
    if (permission !== "granted") throw new Error("Chưa được cấp quyền. Hãy cho phép thông báo trong cài đặt trình duyệt. / Allow notifications in browser settings.");
  }
  if (Notification.permission !== "granted") throw new Error("Quyền thông báo đang bị tắt. / Notification permission is off.");
  if (s.start === s.end) throw new Error("Giờ bắt đầu và kết thúc phải khác nhau. / Start and end must differ.");
  const registration = await pushRegistration();
  let subscription = await registration.pushManager.getSubscription();
  if (!subscription) {
    const response = await fetch("/api/eled/push/key");
    if (!response.ok) throw new Error("Không tải được cấu hình thông báo. / Could not load push settings.");
    const { publicKey } = await response.json();
    if (!publicKey) throw new Error("Server chưa sẵn sàng gửi thông báo. / Push is not configured.");
    const key = Uint8Array.from(atob(publicKey.replace(/-/g, "+").replace(/_/g, "/")), c => c.charCodeAt(0));
    try {
      subscription = await registration.pushManager.subscribe({ userVisibleOnly: true, applicationServerKey: key });
    } catch {
      throw new Error("Không đăng ký được Web Push. Hãy kiểm tra quyền thông báo của trình duyệt/hệ điều hành rồi thử lại. Trên iPhone/iPad, mở English Learning từ Màn hình chính. / Could not register Web Push. Check browser and OS permissions, then retry.");
    }
  }
  const result = await request("subscription", "POST", { subscription: subscription.toJSON(), settings: schedulePayload(s) });
  localStorage.setItem(CONFIG, JSON.stringify({ ...s, enabled: true }));
  localStorage.setItem(OWNER, JSON.stringify(account));
  boundAccount = account;
  return result;
}
export async function disableNotifications() {
  const previous = notificationSettings();
  // Unsubscribe even if the network is down, so this browser stops receiving pushes.
  const registration = await navigator.serviceWorker.getRegistration("/");
  const subscription = await registration?.pushManager.getSubscription();
  if (subscription) await subscription.unsubscribe();
  localStorage.setItem(CONFIG, JSON.stringify({ ...previous, enabled: false }));
  await request("subscription", "DELETE");
}
export async function testNotification() { return request("test", "POST"); }
export async function notificationStatus() { return request("status"); }
async function refreshHistory() {
  if (!notificationSettings().enabled || historyBusy || !navigator.onLine || boundAccount !== account) return;
  historyBusy = true;
  const currentAccount = account;
  try {
    const result = await notificationStatus();
    if (currentAccount !== account) return;
    if (!result.active) {
      localStorage.setItem(CONFIG, JSON.stringify({ ...notificationSettings(), enabled: false }));
      return;
    }
    const p = getProfile();
    const history = new Map<string, number>();
    for (const entry of result.history || []) for (const word of entry.words)
      if ((p.history[word] || 0) < entry.sentAt) history.set(word, Math.max(history.get(word) || 0, entry.sentAt));
    if (history.size) apply([...history].map(([key, value]) => ({ section: "history", key, value })));
  } catch { /* Retry on focus or next successful push. */ }
  finally { historyBusy = false; }
}
export function initNotifications() {
  if (!pushSupported()) return;
  boundAccount = read<string | null>(OWNER, null);
  let timer: ReturnType<typeof setTimeout>;
  let known = getProfile().known;
  subscribe(() => {
    const nextKnown = getProfile().known;
    const added = Object.keys(nextKnown).filter(key => nextKnown[key] && !known[key]);
    known = nextKnown;
    if (added.length && notificationSettings().enabled && boundAccount === account) {
      // Small keepalive requests survive closing the tab immediately after rating Easy.
      for (let i = 0; i < added.length; i += 50) void request("exclude", "POST", { words: added.slice(i, i + 50) }).catch(() => {});
    }
    clearTimeout(timer);
    timer = setTimeout(async () => {
      if (!notificationSettings().enabled) return;
      // A shared browser must never carry one account's reminders to the next.
      if (boundAccount !== account) { await disableNotifications().catch(() => {}); return; }
      if (Notification.permission !== "granted") { await disableNotifications().catch(() => {}); return; }
      await saveNotifications(notificationSettings()).catch(() => {});
    }, 300);
  });
  if (notificationSettings().enabled) {
    if (Notification.permission !== "granted") void disableNotifications().catch(() => {});
    else void saveNotifications(notificationSettings()).then(refreshHistory).catch(() => {});
  }
  window.addEventListener("focus", () => void refreshHistory());
  window.addEventListener("online", () => {
    if (notificationSettings().enabled) void saveNotifications(notificationSettings()).then(refreshHistory).catch(() => {});
  });
  navigator.serviceWorker.addEventListener("message", event => { if (event.data?.type === "eled-push") void refreshHistory(); });
}
