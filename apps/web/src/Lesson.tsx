import { useEffect, useMemo, useState } from "react";
import {
  ArrowLeft,
  ArrowRight,
  Check,
  CheckCheck,
  FolderPlus,
  ExternalLink,
  RotateCcw,
  Volume2,
  CheckCircle2,
  ChevronLeft,
  ChevronRight,
} from "lucide-react";
import { change, getProfile } from "./storage";
import {
  fresh,
  localDate,
  rate,
  shuffle,
  type Rating,
  type Word,
} from "./model";
import {
  Badge,
  Button,
  IconButton,
  Modal,
  Sound,
  speak,
  useProfile,
  useText,
} from "./ui";
type Kind =
  | "recognize"
  | "choice"
  | "listen"
  | "context"
  | "anagram"
  | "reverse";
const labels: Record<Kind, [string, string]> = {
  recognize: ["Thẻ từ", "Flashcard"],
  choice: ["Chọn nghĩa", "Multiple choice"],
  listen: ["Nghe và viết", "Listen and type"],
  context: ["Điền vào ngữ cảnh", "Fill in context"],
  anagram: ["Sắp xếp chữ", "Anagram"],
  reverse: ["Viết từ tiếng Anh", "Reverse typing"],
};
export function QuizPicker({
  onStart,
  onClose,
}: {
  onStart: (k: Kind[]) => void;
  onClose: () => void;
}) {
  const t = useText();
  const [selected, setSelected] = useState<Kind[]>([
    "choice",
    "listen",
    "context",
    "anagram",
    "reverse",
  ]);
  return (
    <Modal title="Quiz" onClose={onClose}>
      <p className="muted">
        {t(
          "Chọn các kiểu bài tập cho phiên này.",
          "Choose exercise types for this session.",
        )}
      </p>
      <div className="stack">
        {Object.entries(labels).map(([key, label]) => (
          <label className="check-row" key={key}>
            <input
              type="checkbox"
              checked={selected.includes(key as Kind)}
              onChange={() =>
                setSelected((s) =>
                  s.includes(key as Kind)
                    ? s.filter((k) => k !== key)
                    : [...s, key as Kind],
                )
              }
            />
            {t(...label)}
          </label>
        ))}
      </div>
      <Button disabled={!selected.length} onClick={() => onStart(selected)}>
        {t("Bắt đầu Quiz", "Start quiz")}
      </Button>
    </Modal>
  );
}
export function Lesson({
  words,
  all,
  onClose,
  kinds = ["recognize"],
  initial = 0,
  title,
}: {
  words: Word[];
  all: Word[];
  onClose: () => void;
  kinds?: Kind[];
  initial?: number;
  title?: string;
}) {
  const t = useText();
  const p = useProfile();
  const [index, setIndex] = useState(initial);
  const [rated, setRated] = useState(0);
  const [collection, setCollection] = useState(false);
  const word = words[index];
  const finish = () => {
    localStorage.removeItem("eled.session");
    onClose();
  };
  useEffect(() => {
    if (word) {
      localStorage.setItem(
        "eled.session",
        JSON.stringify({
          words: words.map((w) => w.word.toLowerCase()),
          index,
          kinds,
          time: Date.now(),
        }),
      );
      change("history", word.word.toLowerCase(), Date.now());
    }
  }, [index]);
  function next(rating: Rating) {
    const key = word.word.toLowerCase();
    change("srs", key, rate(p.srs[key] ?? fresh(key), rating));
    change("activity", localDate(), true);
    setRated((n) => n + 1);
    setIndex((i) => i + 1);
  }
  if (!word)
    return (
      <div className="results card">
        <div className="celebration">
          <CheckCheck size={44} />
        </div>
        <h1>{t("Hoàn thành!", "Session complete!")}</h1>
        <p>
          {t(
            `Bạn vừa ôn ${rated} từ. Hẹn gặp lại ngày mai.`,
            `You reviewed ${rated} words. See you tomorrow.`,
          )}
        </p>
        <Button onClick={finish}>{t("Về hôm nay", "Back to today")}</Button>
      </div>
    );
  return (
    <section className="lesson">
      <header className="lesson-header">
        <IconButton label={t("Quay lại", "Back")} onClick={onClose}>
          <ArrowLeft />
        </IconButton>
        <div>
          <h1>{title ?? t("Tìm kiếm", "Search")}</h1>
          <strong>
            {index + 1} / {words.length}
          </strong>
        </div>
        <IconButton
          label={t("Tôi đã biết từ này", "I already know this word")}
          onClick={() => {
            change("known", word.word.toLowerCase(), true);
            change("srs", word.word.toLowerCase(), {
              ...fresh(word.word),
              s: "mastered",
              i: 365,
              r: 5,
              d: Date.now() + 365 * 86400000,
              l: Date.now(),
              t: 1,
            });
            setIndex((i) => i + 1);
          }}
        >
          <CheckCircle2 size={24} />
        </IconButton>
      </header>
      <div className="progress">
        <div style={{ width: `${(index / words.length) * 100}%` }} />
      </div>
      <Exercise
        key={index}
        word={word}
        all={all}
        kind={kinds[index % kinds.length]}
        onRate={next}
        onPrevious={index > 0 ? () => setIndex((i) => i - 1) : undefined}
        onNext={
          index < words.length - 1 ? () => setIndex((i) => i + 1) : finish
        }
        onCollection={() => setCollection(true)}
      />
      {collection && (
        <Modal
          title={t("Thêm vào bộ sưu tập", "Add to collection")}
          onClose={() => setCollection(false)}
        >
          {!Object.keys(p.collections).length && (
            <p>
              {t(
                "Tạo bộ sưu tập trong mục Bộ sưu tập trước.",
                "Create a collection from the Collections page first.",
              )}
            </p>
          )}
          {Object.entries(p.collections).map(([name, items]) => (
            <Button
              key={name}
              secondary
              onClick={() => {
                change("collections", name, [
                  ...new Set([...items, word.word.toLowerCase()]),
                ]);
                setCollection(false);
              }}
            >
              {name}
            </Button>
          ))}
        </Modal>
      )}
    </section>
  );
}
function Exercise({
  word,
  all,
  kind,
  onRate,
  onPrevious,
  onNext,
  onCollection,
}: {
  word: Word;
  all: Word[];
  kind: Kind;
  onRate: (r: Rating) => void;
  onPrevious?: () => void;
  onNext: () => void;
  onCollection: () => void;
}) {
  const t = useText();
  const [answer, setAnswer] = useState("");
  const [checked, setChecked] = useState<boolean | null>(null);
  const [defs, setDefs] = useState<{ definition: string; example: string }[]>(
    [],
  );
  const [vi, setVi] = useState(false);
  const [translated, setTranslated] = useState<string[]>([]);
  const [letters, setLetters] = useState<number[]>([]);
  const p = useProfile();
  const choices = useMemo(
    () =>
      shuffle([
        word,
        ...shuffle(
          all.filter(
            (w) => w.word !== word.word && w.translation !== word.translation,
          ),
        ).slice(0, 3),
      ]),
    [word],
  );
  const scrambled = useMemo(
    () => shuffle([...word.word].map((c, i) => ({ c, i }))),
    [word],
  );
  useEffect(() => {
    const c = new AbortController();
    const key = "eled.def." + word.word;
    const cached = localStorage.getItem(key);
    if (cached) {
      try {
        setDefs(JSON.parse(cached));
      } catch {}
    } else if (word.url) {
      const path = new URL(word.url).pathname;
      if (path.startsWith("/definition/english/"))
        fetch("/api/oxford" + path, { signal: c.signal })
          .then((r) => (r.ok ? r.text() : ""))
          .then((html) => {
            if (!html) return;
            const doc = new DOMParser().parseFromString(html, "text/html");
            const entries = [...doc.querySelectorAll(".sense")]
              .slice(0, 4)
              .map((s) => ({
                definition: s.querySelector(".def")?.textContent ?? "",
                example: s.querySelector(".x")?.textContent ?? "",
              }))
              .filter((d) => d.definition);
            if (entries.length) {
              setDefs(entries);
              localStorage.setItem(key, JSON.stringify(entries));
            }
          })
          .catch(() => {});
    }
    if (kind === "listen") speak(word.word, word);
    return () => {
      c.abort();
      speechSynthesis.cancel();
    };
  }, [word]);
  useEffect(() => {
    if (!vi || !defs.length) return;
    let cancelled = false;
    Promise.all(
      defs.map(async (d) => {
        const r = await fetch(
          "https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=vi&dt=t&q=" +
            encodeURIComponent(d.definition),
        );
        if (!r.ok) return d.definition;
        const j = await r.json();
        return j[0].map((s: any[]) => s[0]).join("");
      }),
    )
      .then((result) => {
        if (!cancelled) setTranslated(result);
      })
      .catch(() => {});
    return () => {
      cancelled = true;
    };
  }, [vi, defs]);
  const check = (value = answer) =>
    setChecked(
      value.toLowerCase().replace(/[^a-z0-9]/g, "") ===
        word.word.toLowerCase().replace(/[^a-z0-9]/g, ""),
    );
  return (
    <>
      <div className="exercise-label">
        <Badge>{t(...labels[kind])}</Badge>
      </div>
      <article
        className={`word-card card exercise-${kind} level-${word.levels[0] ?? "A1"}`}
      >
        <div className="word-badges">
          {word.levels.map((l) => (
            <Badge key={l}>{l}</Badge>
          ))}
          <span className="muted">{word.pos}</span>
          <IconButton
            label={t("Thêm vào bộ sưu tập", "Add to collection")}
            onClick={onCollection}
          >
            <FolderPlus size={18} />
          </IconButton>
        </div>
        {kind === "recognize" || kind === "choice" ? (
          <>
            <div className="word-title">
              <h1>{word.word}</h1>
            </div>
            <div className="pronunciation-row">
              <p className="ipa">{word.ipa}</p>
              <Sound word={word} />
              {word.url && (
                <a
                  className="icon-btn"
                  href={word.url}
                  target="_blank"
                  rel="noreferrer"
                  aria-label="Oxford"
                >
                  <ExternalLink size={20} />
                </a>
              )}
            </div>
          </>
        ) : kind === "listen" ? (
          <div className="listen-prompt">
            <IconButton
              label={t("Nghe từ", "Listen to word")}
              onClick={() => speak(word.word, word)}
            >
              <Volume2 size={40} />
            </IconButton>
            <h2>{t("Bạn nghe được từ gì?", "What word do you hear?")}</h2>
          </div>
        ) : (
          <>
            <h2>
              {kind === "context" && defs[0]?.example
                ? defs[0].example.replace(
                    new RegExp(
                      word.word.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"),
                      "gi",
                    ),
                    "_____",
                  )
                : word.translation}
            </h2>
            {kind === "context" && (
              <p className="muted">
                {t("Điền từ tiếng Anh phù hợp.", "Fill in the English word.")}
              </p>
            )}
          </>
        )}
        {kind === "recognize" && (
          <>
            <h2 className="meaning">{word.translation}</h2>
            {defs.length > 0 && (
              <div className="definitions">
                {defs.map((d, i) => (
                  <div key={i}>
                    <p>{vi ? (translated[i] ?? d.definition) : d.definition}</p>
                    {d.example && <blockquote>“{d.example}”</blockquote>}
                  </div>
                ))}
              </div>
            )}
          </>
        )}
        {kind === "choice" && (
          <div className="choices">
            {choices.map((w) => (
              <button
                key={w.word}
                disabled={checked !== null}
                className={`choice ${checked !== null && w.word === word.word ? "correct" : ""} ${checked === false && answer === w.word ? "incorrect" : ""}`}
                onClick={() => {
                  setAnswer(w.word);
                  setChecked(w.word === word.word);
                }}
              >
                {w.translation}
              </button>
            ))}
          </div>
        )}
        {kind === "anagram" && (
          <>
            <div className="answer-letters" aria-live="polite">
              {letters
                .map((id) => scrambled.find((x) => x.i === id)?.c)
                .join("") || "…"}
            </div>
            <div className="letter-tray">
              {scrambled.map(({ c, i }) => (
                <button
                  key={i}
                  disabled={letters.includes(i) || checked !== null}
                  onClick={() => {
                    const next = [...letters, i];
                    setLetters(next);
                    setAnswer(
                      next
                        .map((id) => scrambled.find((x) => x.i === id)?.c)
                        .join(""),
                    );
                  }}
                >
                  {c}
                </button>
              ))}
            </div>
            <button
              className="text-btn"
              onClick={() => {
                setLetters([]);
                setAnswer("");
                setChecked(null);
              }}
            >
              <RotateCcw size={14} />
              {t("Làm lại", "Reset")}
            </button>
          </>
        )}
        {["listen", "context", "reverse"].includes(kind) && (
          <form
            onSubmit={(e) => {
              e.preventDefault();
              check();
            }}
          >
            <label className="sr-only" htmlFor="answer">
              {t("Câu trả lời", "Your answer")}
            </label>
            <input
              id="answer"
              autoComplete="off"
              autoCapitalize="off"
              value={answer}
              onChange={(e) => setAnswer(e.target.value)}
              placeholder={t("Nhập từ tiếng Anh…", "Type the English word…")}
              disabled={checked !== null}
              autoFocus
            />
            <Button type="submit" disabled={!answer.trim() || checked !== null}>
              {t("Kiểm tra", "Check answer")}
            </Button>
          </form>
        )}
        {kind === "anagram" && checked === null && (
          <Button disabled={!answer} onClick={() => check()}>
            {t("Kiểm tra", "Check answer")}
          </Button>
        )}
        {checked !== null && (
          <div
            role="status"
            className={`feedback ${checked ? "success" : "failure"}`}
          >
            <strong>
              {checked
                ? t("Chính xác!", "Correct!")
                : t("Đáp án đúng: ", "Correct answer: ") + word.word}
            </strong>
            <p>{word.translation}</p>
            <Button onClick={() => onRate(checked ? "good" : "again")}>
              {t("Tiếp tục", "Continue")}
              <ArrowRight size={16} />
            </Button>
          </div>
        )}
        {word.url && (
          <a
            className="dictionary"
            href={word.url}
            target="_blank"
            rel="noreferrer"
          >
            Oxford Learner’s Dictionaries <ExternalLink size={13} />
          </a>
        )}
      </article>
      {kind === "recognize" && (
        <div className="ratings">
          <button className="rating again" onClick={() => onRate("again")}>
            <RotateCcw size={18} />
            {t("Lại", "Again")}
            <small>1 {t("ngày", "day")}</small>
          </button>
          <button className="rating hard" onClick={() => onRate("hard")}>
            {t("Khó", "Hard")}
            <small>
              {
                rate(p.srs[word.word.toLowerCase()] ?? fresh(word.word), "hard")
                  .i
              }{" "}
              {t("ngày", "days")}
            </small>
          </button>
          <button className="rating easy" onClick={() => onRate("easy")}>
            <Check size={18} />
            {t("Dễ", "Easy")}
            <small>
              {
                rate(p.srs[word.word.toLowerCase()] ?? fresh(word.word), "easy")
                  .i
              }{" "}
              {t("ngày", "days")}
            </small>
          </button>
        </div>
      )}
      {kind === "recognize" && (
        <div className="definition-controls">
          <IconButton
            label={t("Từ trước", "Previous word")}
            disabled={!onPrevious}
            onClick={onPrevious}
          >
            <ChevronLeft size={20} />
          </IconButton>
          <div>
            <span>{t("Định nghĩa", "Definitions")}</span>
            <button
              className={!vi ? "active" : ""}
              onClick={() => setVi(false)}
            >
              English
            </button>
            <button className={vi ? "active" : ""} onClick={() => setVi(true)}>
              Tiếng Việt
            </button>
          </div>
          <IconButton label={t("Từ tiếp theo", "Next word")} onClick={onNext}>
            <ChevronRight size={20} />
          </IconButton>
        </div>
      )}
    </>
  );
}
