import {
  lazy,
  Suspense,
  useEffect,
  useMemo,
  useState,
  useSyncExternalStore,
} from "react";
import {
  ArrowRight,
  BookOpen,
  CalendarDays,
  Check,
  ChevronRight,
  Cloud,
  Flame,
  FolderHeart,
  Grid2X2,
  History,
  Home,
  Layers,
  Mic,
  Search,
  Settings as SettingsIcon,
  Sparkles,
  Timer,
  Zap,
  ArrowLeft,
  Bell,
  Grip,
  Puzzle,
  TrendingUp,
  Bookmark,
  Play,
} from "lucide-react";
import { apply, change, read } from "./storage";
import nickJudyImage from "./assets/nick-judy.png";
import { legacyEasyOperations, localDate, shuffle, streak, todaySession, type Word } from "./model";
import {
  Badge,
  Button,
  Empty,
  go,
  IconButton,
  Loading,
  Modal,
  useHash,
  useProfile,
  useText,
} from "./ui";
import { Lesson, QuizPicker } from "./Lesson";
import * as api from "./api";
import { navigate, navigateBack } from "./navigation";
const Library = lazy(() =>
  import("./Library").then((m) => ({ default: m.Library })),
);
const Settings = lazy(() =>
  import("./Settings").then((m) => ({ default: m.Settings })),
);
const Speaking = lazy(() =>
  import("./Speaking").then((m) => ({ default: m.Speaking })),
);
const MatchGame = lazy(() =>
  import("./Games").then((m) => ({ default: m.MatchGame })),
);
type Session = {
  words: Word[];
  kinds?: Parameters<typeof Lesson>[0]["kinds"];
  initial?: number;
  title?: string;
};
export default function App() {
  const p = useProfile();
  const t = useText();
  const path = useHash();
  const [words, setWords] = useState<Word[]>([]);
  const [error, setError] = useState("");
  const [session, setSession] = useState<Session | null>(null);
  const [quiz, setQuiz] = useState(false);
  const [game, setGame] = useState<"match" | "speed" | null>(null);
  const [welcome, setWelcome] = useState(!p.settings.onboarded);
  useEffect(() => {
    const recovered = legacyEasyOperations(p);
    if (recovered.length) apply(recovered);
  }, [p]);
  useSyncExternalStore(
    api.subscribeAuth,
    () => `${api.user?.uid ?? ""}:${api.status}`,
  );
  useEffect(() => {
    setQuiz(path === "/quiz");
    setGame(path === "/match" ? "match" : path === "/speed" ? "speed" : null);
    if (path !== "/lesson") setSession(null);
    else if (words.length) {
      const saved = history.state?.eledLesson;
      if (saved?.keys) {
        const byKey = new Map(words.map(w => [w.word.toLowerCase(), w]));
        const list = saved.keys.map((key: string) => byKey.get(key)).filter(Boolean) as Word[];
        setSession({ words: list, title: saved.title, kinds: saved.kinds, initial: saved.index || 0 });
      } else navigate("/", {}, true);
    }
  }, [path, words]);
  useEffect(() => {
    let worker = new Worker(
      new URL("./vocabulary.worker.ts", import.meta.url),
      { type: "module" },
    );
    worker.onmessage = (e) => {
      if (e.data.error) setError(e.data.error);
      else setWords(e.data.words);
      worker.terminate();
    };
    worker.onerror = () =>
      setError(
        t(
          "Không tải được từ vựng. Hãy tải lại trang.",
          "Vocabulary could not load. Please reload.",
        ),
      );
    worker.postMessage(null);
    api.initAuth().catch(() => {});
    return () => worker.terminate();
  }, []);
  useEffect(() => {
    const media = matchMedia("(prefers-color-scheme: dark)");
    const update = () => {
      document.documentElement.classList.toggle(
        "dark",
        p.settings.theme === "dark" ||
          ((p.settings.theme ?? "system") === "system" && media.matches),
      );
      document.documentElement.lang = p.settings.language ?? "vi";
    };
    update();
    media.addEventListener("change", update);
    return () => media.removeEventListener("change", update);
  }, [p.settings.theme, p.settings.language]);
  const categories = useMemo(
    () =>
      [
        ...new Set(
          words.flatMap((w) => w.topics.map((t) => t.split(" - ")[0])),
        ),
      ].sort(),
    [words],
  );
  const today = useMemo(() => todaySession(words, p), [words, p]);
  const gamePool = useMemo(() => {
    const levels: string[] = p.settings.levels ?? ["A1", "A2", "B1"];
    return words.filter(
      (w) => !p.known[w.word.toLowerCase()] && (!levels.length || w.levels.some((l) => levels.includes(l))),
    );
  }, [words, p.settings.levels, p.known]);
  const start = (list: Word[], title?: string) => {
    const eligible = list.length === 1 ? list : list.filter(w => !p.known[w.word.toLowerCase()]);
    if (eligible.length) {
      setSession({ words: eligible, title });
      navigate("/lesson", { eledLesson: { keys: eligible.map(w => w.word.toLowerCase()), title, index: 0 } });
      window.scrollTo({ top: 0 });
    }
  };
  const titles: Record<string, string> = {
    "/browse": t("Duyệt", "Browse"),
    "/library": t("Tìm kiếm", "Search"),
    "/levels": t("Cấp độ", "Levels"),
    "/topics": t("Chủ đề", "Topics"),
    "/known": t("Từ đã biết", "Known words"),
    "/history": t("Thông báo", "Notifications"),
    "/collections": t("Bộ sưu tập", "Collections"),
    "/speaking": "Speaking",
    "/settings": t("Cài đặt", "Settings"),
    "/settings/appearance": t("Giao diện", "Appearance"),
    "/settings/language": t("Ngôn ngữ", "Language"),
    "/settings/learning": t("Tuỳ chỉnh từ vựng", "Learning preferences"),
    "/settings/notifications": t("Cài đặt thông báo", "Notification settings"),
    "/settings/voice": t("Giọng đọc Speaking", "Speaking voice"),
    "/settings/account": t("Tài khoản", "Account"),
    "/settings/data": t("Dữ liệu", "Data"),
    "/settings/help": t("Trợ giúp", "Help"),
    "/settings/about": t("Giới thiệu", "About"),
  };
  const back = () =>
    navigateBack(
      path.startsWith("/settings/")
        ? "/settings"
        : [
              "/levels",
              "/topics",
              "/known",
              "/collections",
              "/speaking",
            ].includes(path)
          ? "/browse"
          : "/",
    );
  return (
    <div className={`app-shell original-app eled-layout ${session || game ? "eled-focus" : ""}`}>
      {!session && !game && <EledNav path={path} t={t} />}
      {!session && !game && (
        <header className={`topbar ${path === "/" ? "home-topbar" : ""}`}>
          <div className="appbar-title">
            {path !== "/" && (
              <IconButton label={t("Quay lại", "Back")} onClick={back}>
                <ArrowLeft size={24} />
              </IconButton>
            )}
            {path === "/" ? (
              <a href="#/" className="brand" aria-label="VNLab English Learning">
                <img src="/logo.svg" alt="" className="brand-logo brand-logo-light" />
                <img src="/logo-dark.svg" alt="" className="brand-logo brand-logo-dark" />
                <span>English Learning</span>
              </a>
            ) : (
              <h1>{titles[path] ?? "English Learning"}</h1>
            )}
          </div>
          <div className="appbar-actions">
            {/* Điều hướng chính nằm ở sidebar (màn rộng) và thanh tab dưới (điện thoại), như VNLab Stock. */}
            {!path.startsWith("/settings") && (
              <IconButton
                className="topbar-settings"
                label={t("Cài đặt", "Settings")}
                onClick={() => go(path === "/history" ? "/settings/notifications" : "/settings")}
              >
                <SettingsIcon size={24} />
              </IconButton>
            )}
          </div>
        </header>
      )}
      <main
        key={path}
        className={`${path === "/" ? "home-page" : "sub-page"} ${session ? "lesson-page" : ""}`}
      >
        {session ? (
          <Lesson {...session} all={words} onClose={() => navigateBack("/")} />
        ) : game ? (
          <Suspense fallback={<Loading />}>
            <MatchGame
              words={gamePool}
              speed={game === "speed"}
              onClose={() => navigateBack("/")}
            />
          </Suspense>
        ) : (
          <Suspense fallback={<Loading />}>
            {path.startsWith("/settings") ? (
              <Settings
                categories={categories}
                section={path.split("/")[2] ?? ""}
              />
            ) : path === "/speaking" ? (
              <Speaking />
            ) : !words.length ? (
              <div className="initial-loading">
                {error ? (
                  <>
                    <p role="alert">{error}</p>
                    <Button onClick={() => location.reload()}>
                      {t("Thử lại", "Try again")}
                    </Button>
                  </>
                ) : (
                  <Loading />
                )}
              </div>
            ) : path === "/browse" ? (
              <Browse
                words={words}
                onResume={() => {
                  const saved = read<any>("eled.session", null);
                  if (saved) {
                    const byKey = new Map(
                      words.map((w) => [w.word.toLowerCase(), w]),
                    );
                    const list = saved.words
                      .map((k: string) => byKey.get(k))
                      .filter(Boolean);
                    if (list.length) {
                      setSession({
                        words: list,
                        kinds: saved.kinds,
                        initial: Math.min(saved.index, list.length - 1),
                      });
                      navigate("/lesson", { eledLesson: { keys: saved.words, kinds: saved.kinds, index: Math.min(saved.index, list.length - 1) } });
                    }
                  }
                }}
              />
            ) : [
                "/library",
                "/levels",
                "/topics",
                "/known",
                "/history",
                "/collections",
              ].includes(path) ? (
              <Library
                key={path}
                words={words}
                mode={
                  path === "/known"
                    ? "known"
                    : path === "/history"
                      ? "history"
                      : path === "/collections"
                        ? "collections"
                        : "all"
                }
                view={
                  path === "/levels"
                    ? "levels"
                    : path === "/topics"
                      ? "topics"
                      : "search"
                }
                onLearn={start}
              />
            ) : (
              <HomeView
                words={words}
                today={today}
                onStart={() => start(today)}
                onQuiz={() => go("/quiz")}
                onMatch={() => go("/match")}
                onSpeed={() => go("/speed")}
              />
            )}
          </Suspense>
        )}
      </main>
      {quiz && (
        <QuizPicker
          onClose={() => navigateBack("/")}
          onStart={(kinds) => {
            setQuiz(false);
            const list = shuffle(gamePool.filter(w => !p.known[w.word.toLowerCase()])).slice(0, 10);
            setSession({ words: list, kinds });
            navigate("/lesson", { eledLesson: { keys: list.map(w => w.word.toLowerCase()), kinds, index: 0 } }, true);
          }}
        />
      )}
      {welcome && (
        <Modal
          title={t("Chào mừng đến English Learning", "Welcome to English Learning")}
          onClose={() => {
            setWelcome(false);
            change("settings", "onboarded", true);
          }}
        >
          <div className="welcome-icon">
            <Sparkles size={32} />
          </div>
          <h2>
            {t("Học thông minh, không cần vất vả", "Learn smarter, not harder")}
          </h2>
          <p>
            {t(
              "English Learning sử dụng phương pháp lặp lại ngắt quãng — bạn sẽ thấy lại mỗi từ ngay trước khi quên. Hàng trăm từ sẽ nhớ được chỉ với vài phút mỗi ngày.",
              "English Learning uses spaced repetition — you see each word again just before you forget it. Remember hundreds of words with a few minutes a day.",
            )}
          </p>
          <Button
            onClick={() => {
              setWelcome(false);
              change("settings", "onboarded", true);
            }}
          >
            {t("Bắt đầu khám phá", "Let’s get started")}
          </Button>
        </Modal>
      )}
    </div>
  );
}
function HomeView({
  words,
  today,
  onStart,
  onQuiz,
  onMatch,
  onSpeed,
}: {
  words: Word[];
  today: Word[];
  onStart: () => void;
  onQuiz: () => void;
  onMatch: () => void;
  onSpeed: () => void;
}) {
  const p = useProfile();
  const t = useText();
  const active = Object.keys(p.activity).length > 0;
  const days = streak(p.activity);
  const reviewed = today.filter((w) => !!p.srs[w.word.toLowerCase()]).length;
  const games = [
    {
      title: "Quiz",
      subtitle: t(
        "Sáu kiểu bài tập, không tính lịch ôn",
        "Six exercise types, outside your review schedule",
      ),
      icon: BookOpen,
      className: "quiz",
      action: onQuiz,
    },
    {
      title: t("Ghép cặp", "Matching pairs"),
      subtitle: t("Ghép từ với nghĩa", "Match words and meanings"),
      icon: Puzzle,
      className: "match",
      action: onMatch,
    },
    {
      title: t("Match tốc độ", "Speed match"),
      subtitle: t(
        "Ghép càng nhiều càng tốt trong 30s",
        "Match as many as possible in 30s",
      ),
      icon: Timer,
      className: "speed",
      action: onSpeed,
    },
  ];
  return (
    <>
      <div className="page-heading today-heading">
        <div>
          <span className="eyebrow">
            {new Intl.DateTimeFormat(
              p.settings.language === "en" ? "en-US" : "vi-VN",
              { weekday: "long", day: "numeric", month: "long" },
            ).format(new Date())}
          </span>
          <h1>{t("Hôm nay", "Today")}</h1>
        </div>
      </div>
      <section className="session-card">
        <div className="session-icon">
          <Zap size={26} fill="currentColor" />
        </div>
        <div className="session-copy">
          <span>{t("Phiên hôm nay", "Today’s session")}</span>
          <h2>
            {today.length} {t("từ", "words")}
          </h2>
        </div>
        <div className="session-badges">
          <Badge>
            {reviewed} {t("ôn", "review")}
          </Badge>
          {today.length - reviewed > 0 && (
            <Badge>
              {today.length - reviewed} {t("mới", "new")}
            </Badge>
          )}
        </div>
        <Button disabled={!today.length} onClick={onStart}>
          <Play size={20} fill="currentColor" aria-hidden="true" />
          {today.length
            ? t("Bắt đầu", "Start")
            : t("Đã hoàn thành hôm nay", "All caught up today")}
        </Button>
      </section>
      <div className="game-grid">
        {games.map((g) => (
          <button
            key={g.className}
            className={"game-card " + g.className}
            onClick={g.action}
          >
            <div className="tile-icon">
              <g.icon size={22} />
            </div>
            <div>
              <h3>{g.title}</h3>
              <p>{g.subtitle}</p>
            </div>
            <ChevronRight size={24} />
          </button>
        ))}
      </div>
      <div className="stats-grid">
        {[
          {
            value: Object.values(p.known).filter(Boolean).length,
            label: t("Đã biết", "Known"),
            icon: Check,
            path: "/known",
          },
          {
            value: Math.min(
              200,
              words.filter(
                (w) =>
                  !p.known[w.word.toLowerCase()] &&
                  !p.srs[w.word.toLowerCase()],
              ).length,
            ),
            label: t("Cần học", "To learn"),
            icon: PlusSymbol,
            path: "/levels",
          },
        ].map((stat) => (
          <button
            key={stat.path}
            className="stat card"
            onClick={() => go(stat.path)}
          >
            <span className="stat-icon">
              <stat.icon />
            </span>
            <strong>{stat.value}</strong>
            <span>{stat.label}</span>
          </button>
        ))}
      </div>
      {active && (
        <section className="card activity">
          <div className="row">
            <span className="stat-icon">
              <Flame size={20} />
            </span>
            <div>
              <p>{t("Chuỗi ngày học", "Learning streak")}</p>
              <h2>
                {days} {t("ngày liên tiếp", "consecutive days")}
              </h2>
            </div>
          </div>
          <div className="activity-days">
            {Array.from({ length: 28 }, (_, i) => {
              const d = new Date();
              d.setDate(d.getDate() - 27 + i);
              const key = localDate(d);
              return (
                <span
                  key={key}
                  className={p.activity[key] ? "done" : ""}
                  title={key}
                />
              );
            })}
          </div>
        </section>
      )}
    </>
  );
}
function Browse({ words, onResume }: { words: Word[]; onResume: () => void }) {
  const p = useProfile();
  const t = useText();
  const cards = [
    {
      path: "/levels",
      title: t("Cấp độ", "Levels"),
      subtitle: t("Học từ vựng từ A1 đến C1", "Learn vocabulary from A1 to C1"),
      color: "sage",
      icon: TrendingUp,
      count: words.length,
    },
    {
      path: "/collections",
      title: t("Bộ sưu tập", "Collections"),
      subtitle: t("Danh sách từ của bạn", "Your word lists"),
      color: "sand",
      icon: Bookmark,
      count: Object.keys(p.collections).length,
    },
    {
      path: "/topics",
      title: t("Chủ đề", "Topics"),
      subtitle: t(
        "Theo nhóm: động vật, du lịch…",
        "By topic: animals, travel…",
      ),
      color: "blush",
      icon: Grid2X2,
      count: new Set(
        words.flatMap((w) => w.topics.map((t) => t.split(" - ")[0])),
      ).size,
    },
    {
      path: "/known",
      title: t("Từ đã biết", "Known words"),
      subtitle: t(
        "Ôn lại những từ bạn đã thuộc",
        "Review words you already know",
      ),
      color: "coral",
      icon: Check,
      count: Object.values(p.known).filter(Boolean).length,
    },
  ];
  const tile = (c: (typeof cards)[number]) => (
    <button
      key={c.path}
      className={"browse-card card " + c.color}
      onClick={() => go(c.path)}
    >
      <div className="row between">
        <span className="tile-icon">
          <c.icon size={24} />
        </span>
        <Badge>{c.count.toLocaleString()}</Badge>
      </div>
      <h2>{c.title}</h2>
      <p>{c.subtitle}</p>
      <ChevronRight size={22} />
    </button>
  );
  return (
    <section className="browse-page">
      <img className="browse-plant" src={nickJudyImage} alt="" decoding="async" />
      <div className="browse-heading">
        <p>{t("Chọn chế độ", "Choose a mode")}</p>
        <h1>
          {t(
            "Hôm nay bạn muốn\nhọc thế nào?",
            "How would you like to learn today?",
          )}
        </h1>
      </div>
      {read("eled.session", null) && (
        <button className="resume card row between" onClick={onResume}>
          <Layers size={22} />
          <span>{t("Tiếp tục học", "Continue learning")}</span>
          <ChevronRight size={22} />
        </button>
      )}
      <div className="browse-grid">
        <div>{cards.slice(0, 2).map(tile)}</div>
        <div>{cards.slice(2).map(tile)}</div>
      </div>
      <button
        className="speaking-link card coral"
        onClick={() => go("/speaking")}
      >
        <span className="tile-icon">
          <Mic size={22} />
        </span>
        <div>
          <h2>Speaking</h2>
          <p>
            {t(
              "Luyện nói với bài mẫu",
              "Practise speaking with sample answers",
            )}
          </p>
        </div>
        <ChevronRight size={22} />
      </button>
    </section>
  );
}
function PlusSymbol() {
  return <span style={{ fontSize: 25, lineHeight: 1 }}>+</span>;
}

// Điều hướng chính, cùng bố cục với VNLab Stock: sidebar navy ở màn rộng, thanh tab
// kính mờ ở đáy trên điện thoại. Ẩn khi đang học / chơi để tập trung.
const NAV_ITEMS = [
  { to: "/", vi: "Hôm nay", en: "Today", icon: Home, also: [] as string[] },
  { to: "/library", vi: "Tìm kiếm", en: "Search", icon: Search, also: [] },
  { to: "/browse", vi: "Duyệt", en: "Browse", icon: Grip, also: ["/levels", "/topics", "/known", "/collections"] },
  { to: "/speaking", vi: "Speaking", en: "Speaking", icon: Mic, also: [] },
  { to: "/history", vi: "Thông báo", en: "Notifications", icon: Bell, also: [] },
];
function EledNav({ path, t }: { path: string; t: (vi: string, en: string) => string }) {
  const active = (i: (typeof NAV_ITEMS)[number]) => path === i.to || i.also.includes(path);
  return (
    <>
      <aside className="eled-side">
        <a href="#/" className="eled-side-brand" aria-label="VNLab English Learning">
          <img src="/logo-dark.svg" alt="" />
          <span><small>VNLAB</small>English Learning</span>
        </a>
        <nav>
          {NAV_ITEMS.map((i) => (
            <button key={i.to} type="button" className={`eled-side-link ${active(i) ? "active" : ""}`} onClick={() => go(i.to)}>
              <i.icon size={18} />{t(i.vi, i.en)}
            </button>
          ))}
        </nav>
        <button type="button" className={`eled-side-link eled-side-settings ${path.startsWith("/settings") ? "active" : ""}`} onClick={() => go("/settings")}>
          <SettingsIcon size={18} />{t("Cài đặt", "Settings")}
        </button>
      </aside>
      <nav className="eled-tabs" aria-label={t("Điều hướng chính", "Main navigation")}>
        {NAV_ITEMS.map((i) => (
          <button key={i.to} type="button" className={`eled-tab ${active(i) ? "active" : ""}`} onClick={() => go(i.to)} aria-current={active(i) ? "page" : undefined}>
            <i.icon size={20} strokeWidth={active(i) ? 2.4 : 1.9} />{t(i.vi, i.en)}
          </button>
        ))}
      </nav>
    </>
  );
}
