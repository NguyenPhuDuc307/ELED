import { useEffect, useRef, useState, useSyncExternalStore } from "react";
import {
  Cloud,
  Download,
  LogIn,
  LogOut,
  RefreshCw,
  Upload,
  CheckCircle,
  AlertCircle,
  Palette,
  Languages,
  Settings2,
  AudioLines,
  User,
  HelpCircle,
  Info,
  ChevronRight,
  ExternalLink,
} from "lucide-react";
import { change, downloadBackup, importBackup } from "./storage";
import * as api from "./api";
import { Button, Badge, useProfile, useText, go } from "./ui";
export function Settings({
  categories,
  section = "",
}: {
  categories: string[];
  section?: string;
}) {
  const p = useProfile();
  const t = useText();
  useSyncExternalStore(
    api.subscribeAuth,
    () => `${api.user?.uid ?? ""}:${api.status}`,
  );
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState("");
  const [voices, setVoices] = useState<SpeechSynthesisVoice[]>([]);
  const input = useRef<HTMLInputElement>(null);
  useEffect(() => {
    const fn = () =>
      setVoices(
        speechSynthesis.getVoices().filter((v) => v.lang.startsWith("en")),
      );
    fn();
    speechSynthesis.addEventListener("voiceschanged", fn);
    return () => speechSynthesis.removeEventListener("voiceschanged", fn);
  }, []);
  async function run(fn: () => Promise<unknown>, success = "") {
    setBusy(true);
    setError("");
    try {
      await fn();
      if (success) setMessage(success);
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setBusy(false);
    }
  }
  const levels: string[] = p.settings.levels ?? ["A1", "A2", "B1"];
  const topics: string[] = p.settings.topics ?? [];
  if (!section) {
    const items = [
      {
        key: "appearance",
        icon: Palette,
        title: t("Giao diện", "Appearance"),
        subtitle:
          p.settings.theme === "dark"
            ? t("Tối", "Dark")
            : p.settings.theme === "light"
              ? t("Sáng", "Light")
              : t("Hệ thống", "System"),
      },
      {
        key: "language",
        icon: Languages,
        title: t("Ngôn ngữ", "Language"),
        subtitle:
          p.settings.language === "en"
            ? "English"
            : t("Theo hệ thống", "System"),
      },
      {
        key: "learning",
        icon: Settings2,
        title: t("Tuỳ chỉnh từ vựng", "Learning preferences"),
        subtitle: t("Cấp độ và chủ đề", "Levels and topics"),
      },
      {
        key: "voice",
        icon: AudioLines,
        title: t("Giọng đọc Speaking", "Speaking voice"),
        subtitle: t(
          "Chọn giọng vùng và giới tính cho TTS",
          "Choose a speaking voice and accent",
        ),
      },
      {
        key: "data",
        icon: User,
        title: t("Dữ liệu", "Data"),
        subtitle:
          api.user?.email ?? t("Sao lưu và đặt lại", "Backup and restore"),
      },
      {
        key: "help",
        icon: HelpCircle,
        title: t("Trợ giúp", "Help"),
        subtitle: t("Phiên bản và đóng góp", "Version and feedback"),
      },
      {
        key: "about",
        icon: Info,
        title: t("Giới thiệu", "About"),
        subtitle: t("Phiên bản và đóng góp", "Version and feedback"),
      },
    ];
    return (
      <div className="settings-hub">
        {items.map((item) => (
          <button
            className="card settings-category"
            key={item.key}
            onClick={() => go("/settings/" + item.key)}
          >
            <span className="category-icon">
              <item.icon size={24} />
            </span>
            <span>
              <strong>{item.title}</strong>
              <small>{item.subtitle}</small>
            </span>
            <ChevronRight size={24} />
          </button>
        ))}
      </div>
    );
  }
  if (section === "help")
    return (
      <section className="card help-page">
        <h2>{t("Học cùng ELED", "Learning with ELED")}</h2>
        <p>
          {t(
            "Bắt đầu phiên học mỗi ngày. Chọn Lại, Khó hoặc Dễ để ELED điều chỉnh lịch ôn cho bạn.",
            "Start a daily session. Choose Again, Hard or Easy to adjust your review schedule.",
          )}
        </p>
        <h3>{t("Bộ sưu tập & Speaking", "Collections & Speaking")}</h3>
        <p>
          {t(
            "Mở Duyệt để tìm từ theo cấp độ, chủ đề, tạo bộ sưu tập hoặc nhập bài nói mẫu.",
            "Open Browse to find words by level or topic, create collections or import speaking samples.",
          )}
        </p>
      </section>
    );
  return (
    <section className={"settings-detail settings-section-" + section}>
      <div className="page-heading">
        <div>
          <span className="eyebrow">MAKE IT YOURS</span>
          <h1>{t("Cài đặt", "Settings")}</h1>
        </div>
      </div>
      <div className="settings-grid">
        <article className="card">
          <h2>{t("Tài khoản & đồng bộ", "Account & sync")}</h2>
          <p className="muted">
            {t(
              "Đăng nhập để lưu tiến độ và tiếp tục học trên thiết bị khác.",
              "Sign in to save your progress and continue on another device.",
            )}
          </p>
          {api.user ? (
            <>
              <div className="account">
                <div className="avatar">{api.user.name.charAt(0) || "E"}</div>
                <div>
                  <strong>{api.user.name}</strong>
                  <p>{api.user.email}</p>
                </div>
              </div>
              <p className="sync-status">
                {api.status === "error" ? (
                  <AlertCircle size={16} />
                ) : (
                  <Cloud size={16} />
                )}{" "}
                {api.status === "syncing"
                  ? t("Đang đồng bộ…", "Syncing…")
                  : api.status === "error"
                    ? t(
                        "Chưa đồng bộ được. Dữ liệu vẫn lưu trên máy.",
                        "Sync unavailable. Your data is saved on this device.",
                      )
                    : t("Đã đồng bộ", "Synced")}
              </p>
              <div className="row">
                <Button secondary disabled={busy} onClick={() => run(api.sync)}>
                  <RefreshCw size={16} />
                  {t("Đồng bộ ngay", "Sync now")}
                </Button>
                <Button
                  secondary
                  disabled={busy}
                  onClick={() => run(api.logout)}
                >
                  <LogOut size={16} />
                  {t("Đăng xuất", "Sign out")}
                </Button>
              </div>
              {!p.settings.firebaseImported && (
                <div className="migration">
                  <h3>
                    {t("Bạn đã dùng ELED trước đây?", "Used ELED before?")}
                  </h3>
                  <p>
                    {t(
                      "Nhập từ đã biết và bộ sưu tập từ phiên bản ELED trước. Dữ liệu nguồn được giữ nguyên.",
                      "Import known words and collections from the previous version of ELED. Your original data is preserved.",
                    )}
                  </p>
                  <Button
                    secondary
                    disabled={busy}
                    onClick={() =>
                      run(
                        api.importLegacyFirebase,
                        t("Đã nhập dữ liệu cũ.", "Previous data imported."),
                      )
                    }
                  >
                    {t(
                      "Nhập dữ liệu tài khoản cũ",
                      "Import previous account data",
                    )}
                  </Button>
                </div>
              )}
            </>
          ) : (
            <>
              <Button disabled={busy} onClick={() => run(api.login)}>
                <LogIn size={17} />
                {t("Đăng nhập bằng Google", "Sign in with Google")}
              </Button>
              <p className="muted">
                {t(
                  "Bạn vẫn có thể học khi chưa đăng nhập. Tiến độ sẽ lưu trên trình duyệt này.",
                  "You can study without signing in. Progress stays in this browser.",
                )}
              </p>
            </>
          )}
          {error && (
            <p role="alert" className="error">
              {error}
            </p>
          )}
          {message && (
            <p role="status" className="success-text">
              {message}
            </p>
          )}
        </article>
        <article className="card">
          <h2>{t("Giao diện & ngôn ngữ", "Appearance & language")}</h2>
          <label>
            {t("Giao diện", "Theme")}
            <select
              value={p.settings.theme ?? "system"}
              onChange={(e) => change("settings", "theme", e.target.value)}
            >
              <option value="system">{t("Theo hệ thống", "System")}</option>
              <option value="light">{t("Sáng", "Light")}</option>
              <option value="dark">{t("Tối", "Dark")}</option>
            </select>
          </label>
          <label>
            {t("Ngôn ngữ", "Language")}
            <select
              value={p.settings.language ?? "vi"}
              onChange={(e) => change("settings", "language", e.target.value)}
            >
              <option value="vi">Tiếng Việt</option>
              <option value="en">English</option>
            </select>
          </label>
        </article>
        <article className="card">
          <h2>{t("Từ vựng trong phiên học", "Session vocabulary")}</h2>
          <p className="muted">
            {t(
              "Chọn cấp độ và chủ đề cho các từ mới mỗi ngày.",
              "Choose the levels and topics for your daily new words.",
            )}
          </p>
          <div className="level-options">
            {["A1", "A2", "B1", "B2", "C1"].map((l) => (
              <label key={l}>
                <input
                  type="checkbox"
                  checked={levels.includes(l)}
                  onChange={() =>
                    change(
                      "settings",
                      "levels",
                      levels.includes(l)
                        ? levels.filter((k) => k !== l)
                        : [...levels, l],
                    )
                  }
                />
                {l}
              </label>
            ))}
          </div>
          <label>
            {t("Chủ đề", "Topics")}
            <select
              multiple
              className="topics-select"
              value={topics}
              onChange={(e) =>
                change(
                  "settings",
                  "topics",
                  [...e.target.selectedOptions].map((o) => o.value),
                )
              }
            >
              {categories.map((c) => (
                <option key={c} value={c}>
                  {c.replaceAll("_", " ")}
                </option>
              ))}
            </select>
          </label>
          <button
            className="text-btn"
            onClick={() => change("settings", "topics", [])}
          >
            {t("Tất cả chủ đề", "All topics")}
          </button>
        </article>
        <article className="card">
          <h2>{t("Giọng đọc", "Speaking voice")}</h2>
          <label>
            {t("Giọng vùng", "Accent")}
            <select
              value={p.settings.accent ?? "us"}
              onChange={(e) => change("settings", "accent", e.target.value)}
            >
              <option value="us">English (US)</option>
              <option value="uk">English (UK)</option>
            </select>
          </label>
          <label>
            {t("Giọng đọc trên thiết bị", "Device voice")}
            <select
              value={p.settings.voice ?? ""}
              onChange={(e) => change("settings", "voice", e.target.value)}
            >
              <option value="">{t("Mặc định", "Default")}</option>
              {voices.map((v) => (
                <option key={v.name + v.lang} value={v.name}>
                  {v.name} · {v.lang}
                </option>
              ))}
            </select>
          </label>
          <p className="muted">
            {t(
              "Giọng đọc và nhận diện giọng nói phụ thuộc trình duyệt.",
              "Available voices and speech recognition depend on your browser.",
            )}
          </p>
        </article>
        <article className="card">
          <h2>{t("Sao lưu", "Backup")}</h2>
          <p className="muted">
            {t(
              "Xuất toàn bộ tiến độ, bộ sưu tập và bài nói. Hỗ trợ nhập bản sao lưu JSON từ app cũ.",
              "Export all progress, collections and speaking sets. JSON backups from the original app are supported.",
            )}
          </p>
          <div className="row">
            <Button secondary onClick={downloadBackup}>
              <Download size={17} />
              {t("Xuất JSON", "Export JSON")}
            </Button>
            <Button secondary onClick={() => input.current?.click()}>
              <Upload size={17} />
              {t("Nhập JSON", "Import JSON")}
            </Button>
          </div>
          <input
            ref={input}
            hidden
            type="file"
            accept=".json,application/json"
            onChange={async (e) => {
              try {
                const file = e.target.files?.[0];
                if (file) {
                  if (file.size > 8000000) throw new Error("Tệp lớn hơn 8 MB");
                  importBackup(JSON.parse(await file.text()));
                  setMessage(t("Đã nhập bản sao lưu.", "Backup imported."));
                }
              } catch (error) {
                setError((error as Error).message);
              }
              e.target.value = "";
            }}
          />
        </article>
        <article className="card">
          <h2>ELED</h2>
          <Badge>English Learning Every Day</Badge>
          <p>
            {t("Một ít tiếng Anh, mỗi ngày.", "A little English, every day.")}
          </p>
          <p className="muted">
            {t(
              "Học theo lịch ôn cá nhân, lưu những từ yêu thích và luyện nói mỗi ngày. Thông báo nền và widget có trên app điện thoại.",
              "Follow your review schedule, save favourite words and practise speaking every day. Background reminders and home widgets are available in the mobile app.",
            )}
          </p>
          <a
            href="https://github.com/NguyenPhuDuc307/ELED/releases"
            target="_blank"
            rel="noreferrer"
          >
            {t("Tải ứng dụng điện thoại", "Get the mobile app")} <ExternalLink size={14} aria-hidden="true" />
          </a>
        </article>
      </div>
    </section>
  );
}
