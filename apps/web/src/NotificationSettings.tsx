import { useEffect, useState } from "react";
import { Bell, BellOff, Clock3, Send } from "lucide-react";
import { Button, Choice, useText } from "./ui";
import { disableNotifications, needsHomeScreen, notificationSettings, notificationStatus, pushSupported, saveNotifications, testNotification } from "./notifications";
export function BrowserNotificationSettings() {
  const t = useText();
  const [settings, setSettings] = useState(notificationSettings);
  const [enabled, setEnabled] = useState(settings.enabled);
  const [permission, setPermission] = useState("Notification" in window ? Notification.permission : "unsupported");
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState("");
  const [message, setMessage] = useState("");
  const [nextAt, setNextAt] = useState<string | null>(null);
  const supported = pushSupported();
  useEffect(() => {
    const refresh = () => {
      setPermission("Notification" in window ? Notification.permission : "unsupported");
      if (notificationSettings().enabled) notificationStatus().then(s => {
        setEnabled(s.active);
        setNextAt(s.nextAt || null);
        if (s.error) setError(t("Lần gửi gần nhất chưa thành công. Hãy gửi thử hoặc bật lại thông báo.", "Last delivery failed. Try a test notification or enable again."));
      }).catch(() => {});
    };
    refresh(); window.addEventListener("focus", refresh);
    return () => window.removeEventListener("focus", refresh);
  }, []);
  async function enableOrSave() {
    setBusy(true); setError(""); setMessage("");
    try {
      const result = await saveNotifications({ ...settings, enabled: true }, !enabled);
      setEnabled(true); setSettings(s => ({ ...s, enabled: true })); setNextAt(result.nextAt);
      setMessage(t("Đã lưu lịch nhắc học trên trình duyệt này.", "Reminder schedule saved for this browser."));
    } catch (e) { setError((e as Error).message); }
    finally { setPermission("Notification" in window ? Notification.permission : "unsupported"); setBusy(false); }
  }
  async function disable() {
    setBusy(true); setError(""); setMessage("");
    try { await disableNotifications(); setMessage(t("Đã tắt thông báo trên trình duyệt này.", "Notifications disabled for this browser.")); }
    catch (e) { setError((e as Error).message); }
    finally { setEnabled(false); setSettings(s => ({ ...s, enabled: false })); setNextAt(null); setBusy(false); }
  }
  return <section className="notification-settings">
    <article className="card notification-intro">
      <div className="notification-title"><span className="notification-symbol"><Bell size={24} /></span><div><h2>{t("Nhắc học từ vựng", "Vocabulary reminders")}</h2><p>{t("Nhận từ, IPA và nghĩa ngay trong thông báo trình duyệt.", "Receive words, IPA and meanings in browser notifications.")}</p></div></div>
      <Choice label={t("Thông báo trên trình duyệt này", "Notifications on this browser")}
        description={enabled && permission === "granted" ? t("Đang bật", "Enabled") : permission === "denied" ? t("Bị chặn trong cài đặt trình duyệt", "Blocked in browser settings") : t("Đang tắt", "Disabled")}
        icon={enabled ? <Bell size={20} /> : <BellOff size={20} />} checked={enabled && permission === "granted"}
        onChange={() => { if (!busy && supported) void (enabled ? disable() : enableOrSave()); }} />
      {!supported && <p className="notification-note" role="status">{t("Trình duyệt này chưa hỗ trợ Web Push. Hãy dùng trình duyệt hỗ trợ thông báo trên HTTPS.", "Web Push is unavailable. Use a supported browser over HTTPS.")}</p>}
      {needsHomeScreen() && <p className="notification-note">{t("Trên iPhone/iPad: mở English Learning bằng Safari, chọn Chia sẻ → Thêm vào Màn hình chính. Mở English Learning từ biểu tượng đó rồi bật thông báo (iOS/iPadOS 16.4 trở lên).", "On iPhone/iPad: open English Learning in Safari, choose Share → Add to Home Screen, then open its icon to enable notifications (iOS/iPadOS 16.4 or later).")}</p>}
      {permission === "denied" && <p className="notification-note">{t("Bạn đã chặn quyền thông báo. Mở cài đặt quyền của trang eled.vnlab.id.vn trong trình duyệt để cho phép lại, rồi bật thông báo tại đây.", "Notifications are blocked. Allow them in the browser permissions for eled.vnlab.id.vn, then enable here.")}</p>}
    </article>
    <article className="card notification-schedule">
      <h2><Clock3 size={20} />{t("Lịch nhắc học", "Reminder schedule")}</h2>
      <p className="muted">{t("Thông báo dùng cấp độ và chủ đề đã chọn, bỏ qua từ đã biết. Lịch chỉ áp dụng cho trình duyệt này.", "Reminders use your selected levels and topics and skip known words. This schedule applies only to this browser.")}</p>
      <div className="notification-fields">
        <label>{t("Nhắc mỗi", "Remind every")}<select aria-label={t("Nhắc mỗi", "Remind every")} value={settings.interval} disabled={busy} onChange={e => setSettings(s => ({ ...s, interval: Number(e.target.value) }))}>
          {[1,10,15,20,25,30,60,120,180].map(n => <option value={n} key={n}>{n < 60 ? t(`${n} phút`, `${n} minute${n === 1 ? "" : "s"}`) : t(`${n / 60} giờ`, `${n / 60} hour${n === 60 ? "" : "s"}`)}</option>)}
        </select></label>
        <label>{t("Số từ mỗi lần", "Words per reminder")}<select aria-label={t("Số từ mỗi lần", "Words per reminder")} value={settings.count} disabled={busy} onChange={e => setSettings(s => ({ ...s, count: Number(e.target.value) }))}>{[1,2,3,4,5].map(n => <option value={n} key={n}>{n} {t("từ", "word(s)")}</option>)}</select></label>
        <label>{t("Từ", "From")}<input aria-label={t("Từ", "From")} type="time" value={settings.start} disabled={busy} onChange={e => setSettings(s => ({ ...s, start: e.target.value }))} required /></label>
        <label>{t("Đến", "Until")}<input aria-label={t("Đến", "Until")} type="time" value={settings.end} disabled={busy} onChange={e => setSettings(s => ({ ...s, end: e.target.value }))} required /></label>
      </div>
      <p className="field-hint">{t("Múi giờ", "Timezone")}: {settings.timezone}. {t("Không gửi ngoài khung giờ đã chọn.", "No reminders outside these hours.")}</p>
      {nextAt && enabled && <p className="notification-next">{t("Lần nhắc tiếp theo", "Next reminder")}: {new Date(nextAt).toLocaleString(undefined, { timeZone: settings.timezone, hour: "2-digit", minute: "2-digit", day: "2-digit", month: "2-digit" })}</p>}
      <div className="notification-actions"><Button disabled={busy || !supported} onClick={enableOrSave}>{busy ? t("Đang lưu…", "Saving…") : enabled ? t("Lưu lịch nhắc", "Save schedule") : t("Bật thông báo & lưu lịch", "Enable & save schedule")}</Button>
      <Button secondary disabled={busy || !enabled || permission !== "granted"} onClick={async () => {
        setBusy(true); setError(""); setMessage("");
        try { await testNotification(); setMessage(t("Đã gửi thông báo thử đến trình duyệt. Nếu chưa thấy, kiểm tra chế độ Không làm phiền và quyền thông báo của hệ điều hành.", "Test notification sent. If it does not appear, check Do Not Disturb and OS notification permissions.")); }
        catch (e) { setError((e as Error).message); } finally { setBusy(false); }
      }}><Send size={17} />{t("Gửi thông báo thử", "Send test notification")}</Button></div>
      <p className="notification-note">{t("Server gửi Web Push khi tab đã đóng. Thông báo có thể đến chậm nếu thiết bị mất mạng, trình duyệt bị hệ điều hành dừng hoặc đang bật Không làm phiền.", "The server sends Web Push even with the tab closed. Delivery may be delayed by offline devices, OS restrictions or Do Not Disturb.")}</p>
    </article>
    {error && <p role="alert" className="error notification-feedback">{error}</p>}
    {message && <p role="status" className="success-text notification-feedback">{message}</p>}
  </section>;
}
