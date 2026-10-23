import { useEffect, useMemo, useState } from "react";
import {
  ArrowLeft,
  ArrowRight,
  Check,
  CheckCheck,
  FolderPlus,
  ExternalLink,
  Eye,
  EyeOff,
  RotateCcw,
  Volume2,
  ChevronLeft,
  ChevronRight,
  Layers, ListChecks, Headphones, TextCursorInput, Shuffle, Pencil,
} from "lucide-react";
import { apply, change, getProfile } from "./storage";
import {
  fresh,
  localDate,
  rate,
  reviewOperations,
  shuffle,
  type Rating,
  type Word,
  conciseSense,
  shortMeaning,
} from "./model";
import {
  Badge,
  Button,
  Choice,
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
const quizDetails: Record<Kind, [string, string]> = {
  recognize: ["Xem từ và ghi nhớ nghĩa", "Review words and meanings"],
  choice: ["Chọn đáp án đúng", "Pick the correct meaning"],
  listen: ["Nghe phát âm, gõ lại từ", "Listen and type the word"],
  context: ["Hoàn thành câu ví dụ", "Complete the example sentence"],
  anagram: ["Ghép các chữ thành từ", "Put letters in the right order"],
  reverse: ["Nhìn nghĩa, viết lại từ", "Type the word from its meaning"],
};
const quizIcons = { recognize: Layers, choice: ListChecks, listen: Headphones, context: TextCursorInput, anagram: Shuffle, reverse: Pencil };
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
      <div className="quiz-choices">
        {Object.entries(labels).map(([key, label]) => {
          const Icon = quizIcons[key as Kind];
          return (
          <Choice key={key} label={t(...label)} description={t(...quizDetails[key as Kind])} icon={<Icon size={20} />}
              checked={selected.includes(key as Kind)}
              onChange={() =>
                setSelected((s) =>
                  s.includes(key as Kind)
                    ? s.filter((k) => k !== key)
                    : [...s, key as Kind],
                )
              }
            />
        );})}
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
    if (history.state?.eledLesson) history.replaceState({ ...history.state, eledLesson: { ...history.state.eledLesson, index } }, "");
    if (word) {
      localStorage.setItem(
        "eled.session",
        JSON.stringify({
          words: words.map((w) => w.word.toLowerCase()),
          index,
          kinds,
          title,
          time: Date.now(),
        }),
      );
      change("history", word.word.toLowerCase(), Date.now());
    }
  }, [index]);
  function next(rating: Rating) {
    const key = word.word.toLowerCase();
    apply(reviewOperations(getProfile(), key, rating));
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
          <h1>{title ?? (kinds.some((k) => k !== "recognize") ? "Quiz" : t("Học từ", "Study"))}</h1>
          <strong>
            {index + 1} / {words.length}
          </strong>
        </div>
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
  const [meaningVisible, setMeaningVisible] = useState(
    () => localStorage.getItem("eled.hide-meaning") !== "true",
  );
  const [checked, setChecked] = useState<boolean | null>(null);
  const [defs, setDefs] = useState<{ definition: string; example: string }[]>(
    [],
  );
  const [vi, setVi] = useState(false);
  const [translated, setTranslated] = useState<string[]>([]);
  const [translating, setTranslating] = useState(false);
  const [translationError, setTranslationError] = useState(false);
  const [translationAttempt, setTranslationAttempt] = useState(0);
  const [letters, setLetters] = useState<number[]>([]);
  // Khi đang "luôn ẩn nghĩa", mỗi thẻ được lật riêng mà không đổi lựa chọn chung.
  const [revealed, setRevealed] = useState(false);
  const shown = meaningVisible || revealed;
  const p = useProfile();
  const hardDays = rate(p.srs[word.word.toLowerCase()] ?? fresh(word.word), "hard").i;
  useEffect(() => {
    if (kind !== "recognize") return;
    const onKey = (e: KeyboardEvent) => {
      if (e.metaKey || e.ctrlKey || e.altKey || e.repeat) return;
      if (e.target instanceof Element && e.target.closest("input, textarea, select, [contenteditable], .modal")) return;
      if (e.key === " " && !shown) setRevealed(true);
      else if (e.key === "1") onRate("again");
      else if (e.key === "2") onRate("hard");
      else if (e.key === "3") onRate("easy");
      else if (e.key === "ArrowLeft" && onPrevious) onPrevious();
      else if (e.key === "ArrowRight") onNext();
      else return;
      e.preventDefault();
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [kind, shown, onRate, onPrevious, onNext]);
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
    setDefs([]);
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
    const controller = new AbortController();
    setTranslating(true);
    setTranslationError(false);
    setTranslated([]);
    fetch("/api/eled/translate", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ texts: defs.map(d => d.definition) }),
      signal: controller.signal,
    })
      .then(async response => {
        if (!response.ok) throw new Error("Translation unavailable");
        const result = await response.json();
        if (!Array.isArray(result.translations) || result.translations.length !== defs.length ||
          result.translations.some((text: unknown) => typeof text !== "string" || !text.trim())) {
          throw new Error("Invalid translation");
        }
        if (!controller.signal.aborted) setTranslated(result.translations);
      })
      .catch(() => {
        if (!controller.signal.aborted) setTranslationError(true);
      })
      .finally(() => {
        if (!controller.signal.aborted) setTranslating(false);
      });
    return () => controller.abort();
  }, [vi, defs, translationAttempt]);
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
        {kind !== "recognize" && <div className="word-badges">
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
        </div>}
        {kind === "recognize" ? (
          <>
            <div className="flashcard-top">
              <div className="flashcard-tags">
                {word.levels.map((l) => (
                  <Badge key={l}>{l}</Badge>
                ))}
                {word.pos && <span>{word.pos}</span>}
              </div>
              <div className="flashcard-tools">
                <IconButton
                  label={t("Thêm vào bộ sưu tập", "Add to collection")}
                  onClick={onCollection}
                >
                  <FolderPlus size={18} />
                </IconButton>
                <button
                  type="button"
                  className="icon-btn"
                  aria-label={meaningVisible ? t("Luôn ẩn nghĩa", "Always hide meaning") : t("Luôn hiện nghĩa", "Always show meaning")}
                  title={meaningVisible ? t("Luôn ẩn nghĩa", "Always hide meaning") : t("Luôn hiện nghĩa", "Always show meaning")}
                  aria-pressed={!meaningVisible}
                  onClick={() => {
                    setMeaningVisible(!meaningVisible);
                    setRevealed(false);
                    localStorage.setItem("eled.hide-meaning", String(meaningVisible));
                  }}
                >
                  {meaningVisible ? <EyeOff size={18} /> : <Eye size={18} />}
                </button>
                {word.url && (
                  <a
                    className="icon-btn"
                    href={word.url}
                    target="_blank"
                    rel="noreferrer"
                    aria-label="Oxford Learner’s Dictionaries"
                  >
                    <ExternalLink size={18} />
                  </a>
                )}
              </div>
            </div>
            <div className="flashcard-head">
              <h1>{word.word}</h1>
              <button
                type="button"
                className="flashcard-sound"
                aria-label={t("Nghe phát âm", "Play pronunciation")}
                onClick={() => speak(word.word, word)}
              >
                <Volume2 size={18} />
                {word.ipa && <span className="ipa-text">{word.ipa}</span>}
              </button>
            </div>
          </>
        ) : kind === "choice" ? (
          <>
            <div className="word-title">
              <h1>{word.word}</h1>
            </div>
            <div className="pronunciation-row">
              <p className="ipa ipa-text">{word.ipa}</p>
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
                : shortMeaning(word)}
            </h2>
            {kind === "context" && (
              <p className="muted">
                {t("Điền từ tiếng Anh phù hợp.", "Fill in the English word.")}
              </p>
            )}
          </>
        )}
        {kind === "recognize" && !shown && (
          <button type="button" className="flashcard-reveal" onClick={() => setRevealed(true)}>
            <Eye size={20} />
            <span>{t("Chạm để xem nghĩa", "Tap to reveal meaning")}</span>
            <kbd>Space</kbd>
          </button>
        )}
        {kind === "recognize" && shown && (
          <div className="flashcard-meaning">
            {word.senses?.length ? <div className="flashcard-senses">
              {word.senses.map(s => <div key={s.pos}>
                <span>{s.pos}</span>
                <p>{conciseSense(s.meanings[0] ?? "", 1)}</p>
                {/* Nghĩa đầy đủ hiện luôn, ngay dưới nghĩa cốt lõi. */}
                {s.meanings
                  .filter((meaning, i) => i > 0 || meaning !== conciseSense(meaning, 1))
                  .map((meaning, i) => <small key={i}>{meaning}</small>)}
              </div>)}
            </div> : <p className="flashcard-translation">{word.translation}</p>}
            {defs.length > 0 && (
              <div className="definitions" aria-busy={vi && translating}>
                <div className="definition-lang" role="group" aria-label={t("Ngôn ngữ định nghĩa", "Definition language")}>
                  <span>Oxford</span>
                  <button type="button" aria-pressed={!vi} onClick={() => setVi(false)}>English</button>
                  <button type="button" aria-pressed={vi} onClick={() => setVi(true)}>Tiếng Việt</button>
                </div>
                {vi && translating && <p role="status">{t("Đang dịch…", "Translating…")}</p>}
                {vi && translationError && <div role="alert">
                  <p>{t("Chưa dịch được định nghĩa. Vui lòng thử lại.", "Could not translate definitions. Please retry.")}</p>
                  <button type="button" className="translation-retry" onClick={() => setTranslationAttempt(n => n + 1)}>{t("Thử lại", "Retry")}</button>
                </div>}
                {defs.map((d, i) => (
                  <div key={i}>
                    <p>{vi ? (translated[i] ?? d.definition) : d.definition}</p>
                    {d.example && <blockquote>“{d.example}”</blockquote>}
                  </div>
                ))}
              </div>
            )}
          </div>
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
                {shortMeaning(w)}
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
            <p>{shortMeaning(word)}</p>
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
        <div className="ratings-block">
          <p className="ratings-question" id="ratings-question">{t("Bạn nhớ từ này đến đâu?", "How well do you know this word?")}</p>
          <div className="ratings" role="group" aria-labelledby="ratings-question">
            <button className="rating again" onClick={() => onRate("again")}>
              <span>{t("Chưa nhớ", "Forgot")}</span>
              <small>{t("Ôn lại ngày mai", "Review tomorrow")}</small>
              <kbd>1</kbd>
            </button>
            <button className="rating hard" onClick={() => onRate("hard")}>
              <span>{t("Nhớ mang máng", "Vaguely")}</span>
              <small>{hardDays <= 1 ? t("Ôn lại ngày mai", "Review tomorrow") : t(`Ôn lại sau ${hardDays} ngày`, `Review in ${hardDays} days`)}</small>
              <kbd>2</kbd>
            </button>
            <button className="rating easy" onClick={() => onRate("easy")}>
              <span>{t("Đã thuộc", "Know it")}</span>
              <small>{t("Không ôn nữa", "Stop reviewing")}</small>
              <kbd>3</kbd>
            </button>
          </div>
        </div>
      )}
      {kind === "recognize" && (
        <nav className="flashcard-nav" aria-label={t("Chuyển từ", "Word navigation")}>
          <button type="button" disabled={!onPrevious} onClick={onPrevious}>
            <ChevronLeft size={18} />
            {t("Từ trước", "Previous")}
          </button>
          <button type="button" onClick={onNext}>
            {t("Bỏ qua", "Skip")}
            <ChevronRight size={18} />
          </button>
        </nav>
      )}
    </>
  );
}
