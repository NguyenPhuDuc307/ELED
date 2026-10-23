import { Fragment, useMemo, useState, type ReactNode } from "react";
import {
  AlertTriangle,
  ArrowLeft,
  ArrowRight,
  BookOpenCheck,
  Check,
  ChevronRight,
  CircleCheck,
  CircleX,
  Lightbulb,
  RotateCcw,
  Volume2,
} from "lucide-react";
import { apply } from "./storage";
import { localDate } from "./model";
import {
  grammarGroups,
  grammarUnits,
  normalizeAnswer,
  PASS_RATIO,
  type GrammarExercise,
  type GrammarUnit,
} from "./grammar/index";
import { Badge, Button, Empty, IconButton, go, speak, useProfile, useText } from "./ui";
import { navigateBack } from "./navigation";

/** Tô đậm phần nằm giữa **…** trong câu ví dụ. */
function Marked({ text }: { text: string }) {
  return (
    <>
      {text.split(/\*\*(.+?)\*\*/g).map((part, i) =>
        i % 2 ? <strong key={i}>{part}</strong> : <Fragment key={i}>{part}</Fragment>,
      )}
    </>
  );
}
const plain = (text: string) => text.replaceAll("**", "");

/** /grammar, /grammar/<id>, /grammar/<id>/practice */
export function Grammar({ path }: { path: string }) {
  const [, , id, mode] = path.split("/");
  const unit = grammarUnits.find((u) => u.id === id);
  if (id && !unit) return <Empty>Không tìm thấy bài ngữ pháp này.</Empty>;
  if (unit && mode === "practice") return <GrammarPractice key={unit.id} unit={unit} />;
  if (unit) return <GrammarLesson key={unit.id} unit={unit} />;
  return <GrammarHome />;
}

function scoreOf(p: ReturnType<typeof useProfile>, id: string) {
  const s = p.grammar?.[id];
  return s ? { ...s, passed: s.b / s.n >= PASS_RATIO } : undefined;
}

function GrammarHome() {
  const t = useText();
  const p = useProfile();
  const vi = p.settings.language !== "en";
  const passed = grammarUnits.filter((u) => scoreOf(p, u.id)?.passed).length;
  const nextUnit = grammarUnits.find((u) => !scoreOf(p, u.id)?.passed);
  return (
    <section className="grammar-page">
      <div className="page-heading">
        <div>
          <span className="eyebrow">IELTS GRAMMAR</span>
          <h1>{t("Ngữ pháp", "Grammar")}</h1>
        </div>
      </div>
      <p className="muted grammar-intro">
        {t(
          "Các chủ điểm ngữ pháp chấm trong tiêu chí Grammatical Range and Accuracy của IELTS, từ nền tảng đến band 7+. Mỗi bài có quy tắc, mẹo dùng trong bài thi, lỗi hay gặp và 10 câu luyện tập.",
          "The grammar assessed under IELTS Grammatical Range and Accuracy, from the basics to band 7+. Each unit has rules, exam tips, common mistakes and 10 practice questions.",
        )}
      </p>
      <div className="grammar-overview card">
        <div>
          <span>{t("Đã nắm vững", "Mastered")}</span>
          <strong>
            {passed}/{grammarUnits.length} {t("bài", "units")}
          </strong>
        </div>
        <div className="grammar-meter" aria-hidden="true">
          <span style={{ width: `${(passed / grammarUnits.length) * 100}%` }} />
        </div>
        {nextUnit && (
          <Button onClick={() => go(`/grammar/${nextUnit.id}`)}>
            {passed ? t("Học tiếp", "Continue") : t("Bắt đầu", "Start")}: {vi ? nextUnit.title : nextUnit.en}
            <ArrowRight size={16} />
          </Button>
        )}
      </div>
      {grammarGroups.map((g) => {
        const units = grammarUnits.filter((u) => u.group === g.id);
        if (!units.length) return null;
        return (
          <section key={g.id} className="grammar-group">
            <header>
              <h2>{vi ? g.vi : g.en}</h2>
              <Badge>Band {g.band}+</Badge>
            </header>
            <p className="muted">{t(...g.about)}</p>
            <div className="grammar-units">
              {units.map((u) => {
                const s = scoreOf(p, u.id);
                return (
                  <button key={u.id} type="button" className="grammar-unit-card" onClick={() => go(`/grammar/${u.id}`)}>
                    <span className={`grammar-status ${s?.passed ? "passed" : s ? "tried" : ""}`} aria-hidden="true">
                      {s?.passed ? <Check size={16} /> : <BookOpenCheck size={16} />}
                    </span>
                    <span>
                      <strong>{vi ? u.title : u.en}</strong>
                      <small>
                        {vi ? u.en : u.title}
                        {s && ` · ${s.b}/${s.n}`}
                      </small>
                    </span>
                    <ChevronRight size={18} aria-hidden="true" />
                  </button>
                );
              })}
            </div>
          </section>
        );
      })}
    </section>
  );
}

function GrammarLesson({ unit }: { unit: GrammarUnit }) {
  const t = useText();
  const p = useProfile();
  const vi = p.settings.language !== "en";
  const s = scoreOf(p, unit.id);
  return (
    <article className="grammar-page grammar-lesson">
      <div className="grammar-lesson-head">
        <Badge>Band {unit.band}+</Badge>
      </div>
      <h1>{vi ? unit.title : unit.en}</h1>
      <p className="grammar-en">{vi ? unit.en : unit.title}</p>
      <p className="grammar-summary">{unit.summary}</p>

      {unit.rules.map((r, i) => (
        <section key={i} className="grammar-rule card">
          <h2>
            <span>{i + 1}</span>
            {r.title}
          </h2>
          <p>{r.body}</p>
          {r.form && <code className="grammar-form">{r.form}</code>}
          <ul className="grammar-examples">
            {r.examples.map((e, j) => (
              <li key={j}>
                <button type="button" aria-label={t("Nghe câu này", "Play this sentence")} onClick={() => speak(plain(e.en))}>
                  <Volume2 size={16} />
                </button>
                <div>
                  <p lang="en">
                    <Marked text={e.en} />
                  </p>
                  <small>{e.vi}</small>
                </div>
              </li>
            ))}
          </ul>
        </section>
      ))}

      {unit.ielts.length > 0 && (
        <Callout icon={<Lightbulb size={18} />} title={t("Dùng trong bài thi IELTS", "Using it in IELTS")} tone="tip">
          {unit.ielts.map((tip, i) => (
            <div key={i} className="grammar-tip">
              <Badge>{tip.part}</Badge>
              <p>{tip.tip}</p>
              {tip.example && (
                <blockquote lang="en">
                  <Marked text={tip.example} />
                </blockquote>
              )}
            </div>
          ))}
        </Callout>
      )}

      {unit.mistakes.length > 0 && (
        <Callout icon={<AlertTriangle size={18} />} title={t("Lỗi hay gặp", "Common mistakes")} tone="warn">
          {unit.mistakes.map((m, i) => (
            <div key={i} className="grammar-mistake">
              <p className="wrong" lang="en">
                <CircleX size={16} aria-label={t("Sai", "Wrong")} />
                <span>{plain(m.wrong)}</span>
              </p>
              <p className="right" lang="en">
                <CircleCheck size={16} aria-label={t("Đúng", "Right")} />
                <span>
                  <Marked text={m.right} />
                </span>
              </p>
              <small>{m.note}</small>
            </div>
          ))}
        </Callout>
      )}

      <div className="grammar-practice-bar">
        <span>
          {s
            ? t(`Điểm cao nhất: ${s.b}/${s.n}`, `Best score: ${s.b}/${s.n}`)
            : t(`${unit.exercises.length} câu luyện tập`, `${unit.exercises.length} practice questions`)}
        </span>
        <Button onClick={() => go(`/grammar/${unit.id}/practice`)}>
          {s ? t("Luyện lại", "Practise again") : t("Luyện tập", "Practise")}
          <ArrowRight size={16} />
        </Button>
      </div>
    </article>
  );
}

function Callout({ icon, title, tone, children }: { icon: ReactNode; title: string; tone: "tip" | "warn"; children: ReactNode }) {
  return (
    <section className={`grammar-callout ${tone}`}>
      <h2>
        {icon}
        {title}
      </h2>
      {children}
    </section>
  );
}

function GrammarPractice({ unit }: { unit: GrammarUnit }) {
  const t = useText();
  const p = useProfile();
  const vi = p.settings.language !== "en";
  const [index, setIndex] = useState(0);
  const [correct, setCorrect] = useState(0);
  const [wrong, setWrong] = useState<number[]>([]);
  const [round, setRound] = useState(0);
  const exercise = unit.exercises[index];
  const total = unit.exercises.length;
  const nextUnit = grammarUnits[grammarUnits.indexOf(unit) + 1];

  function answered(ok: boolean) {
    if (ok) setCorrect((n) => n + 1);
    else setWrong((w) => [...w, index]);
  }
  function advance() {
    if (index + 1 < total) {
      setIndex(index + 1);
      return;
    }
    const best = p.grammar?.[unit.id];
    const ops = [{ section: "activity" as const, key: localDate(), value: true }];
    if (!best || correct / total >= best.b / best.n)
      apply([...ops, { section: "grammar", key: unit.id, value: { b: correct, n: total, t: Date.now() } }]);
    else apply(ops);
    setIndex(total);
  }
  function restart() {
    setIndex(0);
    setCorrect(0);
    setWrong([]);
    setRound((r) => r + 1);
  }

  if (!exercise) {
    const passed = correct / total >= PASS_RATIO;
    return (
      <section className="grammar-page grammar-result card">
        <div className={`grammar-result-score ${passed ? "passed" : ""}`}>
          {correct}/{total}
        </div>
        <h1>{passed ? t("Bạn đã nắm bài này!", "You've got this unit!") : t("Cần ôn thêm một chút", "Needs a little more practice")}</h1>
        <p className="muted">
          {passed
            ? t("Thử áp dụng ngay trong bài viết hoặc câu trả lời Speaking tiếp theo.", "Try it in your next essay or Speaking answer.")
            : t(`Đạt từ ${Math.ceil(total * PASS_RATIO)}/${total} để hoàn thành. Xem lại các câu sai bên dưới.`, `Score ${Math.ceil(total * PASS_RATIO)}/${total} or more to complete it. Review your mistakes below.`)}
        </p>
        {wrong.length > 0 && (
          <ol className="grammar-review">
            {wrong.map((i) => {
              const e = unit.exercises[i];
              return (
                <li key={i}>
                  <p lang="en">{e.q.replace("___", "_____")}</p>
                  <strong lang="en">{e.type === "choice" ? e.options[e.answer] : e.answers[0]}</strong>
                  <small>{e.explain}</small>
                </li>
              );
            })}
          </ol>
        )}
        <div className="grammar-result-actions">
          <Button secondary onClick={restart}>
            <RotateCcw size={16} />
            {t("Làm lại", "Try again")}
          </Button>
          {passed && nextUnit ? (
            <Button onClick={() => go(`/grammar/${nextUnit.id}`)}>
              {t("Bài tiếp", "Next unit")}: {vi ? nextUnit.title : nextUnit.en}
              <ArrowRight size={16} />
            </Button>
          ) : (
            <Button onClick={() => navigateBack(`/grammar/${unit.id}`)}>{t("Xem lại bài học", "Review the lesson")}</Button>
          )}
        </div>
      </section>
    );
  }

  return (
    <section className="grammar-page grammar-practice">
      <header className="lesson-header">
        <IconButton label={t("Quay lại", "Back")} onClick={() => navigateBack(`/grammar/${unit.id}`)}>
          <ArrowLeft />
        </IconButton>
        <div>
          <h1>{vi ? unit.title : unit.en}</h1>
          <strong>
            {index + 1} / {total}
          </strong>
        </div>
      </header>
      <div className="progress">
        <div style={{ width: `${(index / total) * 100}%` }} />
      </div>
      <Question key={`${round}-${index}`} exercise={exercise} onAnswered={answered} onNext={advance} last={index + 1 === total} />
    </section>
  );
}

function Question({
  exercise,
  onAnswered,
  onNext,
  last,
}: {
  exercise: GrammarExercise;
  onAnswered: (ok: boolean) => void;
  onNext: () => void;
  last: boolean;
}) {
  const t = useText();
  const [picked, setPicked] = useState<number | null>(null);
  const [text, setText] = useState("");
  const [result, setResult] = useState<boolean | null>(null);
  const [before, after] = useMemo(() => {
    const at = exercise.q.indexOf("___");
    return at < 0 ? [exercise.q, null] : [exercise.q.slice(0, at), exercise.q.slice(at + 3)];
  }, [exercise]);

  function settle(ok: boolean) {
    setResult(ok);
    onAnswered(ok);
  }
  const blank =
    exercise.type === "fill" && result !== null ? (
      <span className={`grammar-blank filled ${result ? "ok" : "bad"}`}>{text.trim() || "…"}</span>
    ) : exercise.type === "choice" && picked !== null ? (
      <span className={`grammar-blank filled ${result ? "ok" : "bad"}`}>{exercise.options[picked]}</span>
    ) : (
      <span className="grammar-blank" aria-label={t("chỗ trống", "blank")} />
    );

  return (
    <div className="grammar-question card">
      <p className="grammar-question-label">
        {exercise.type === "choice" ? t("Chọn đáp án đúng", "Choose the correct answer") : t("Điền vào chỗ trống", "Fill in the blank")}
      </p>
      <p className="grammar-question-text" lang="en">
        {before}
        {after !== null && (
          <>
            {blank}
            {after}
          </>
        )}
      </p>
      {exercise.type === "choice" ? (
        <div className="grammar-options">
          {exercise.options.map((o, i) => (
            <button
              key={i}
              type="button"
              lang="en"
              disabled={result !== null}
              className={`choice ${result !== null && i === exercise.answer ? "correct" : ""} ${result === false && i === picked ? "incorrect" : ""}`}
              onClick={() => {
                setPicked(i);
                settle(i === exercise.answer);
              }}
            >
              {o}
            </button>
          ))}
        </div>
      ) : (
        <form
          className="grammar-fill"
          onSubmit={(e) => {
            e.preventDefault();
            if (result !== null || !text.trim()) return;
            settle(exercise.answers.some((a) => normalizeAnswer(a) === normalizeAnswer(text)));
          }}
        >
          {exercise.hint && <span className="grammar-hint">{exercise.hint}</span>}
          <input
            value={text}
            onChange={(e) => setText(e.target.value)}
            disabled={result !== null}
            autoComplete="off"
            autoCapitalize="off"
            autoCorrect="off"
            spellCheck={false}
            lang="en"
            placeholder={t("Nhập đáp án…", "Type your answer…")}
            aria-label={t("Đáp án", "Answer")}
            autoFocus
          />
          {result === null && (
            <Button type="submit" disabled={!text.trim()}>
              {t("Kiểm tra", "Check")}
            </Button>
          )}
        </form>
      )}
      {result !== null && (
        <div role="status" className={`feedback ${result ? "success" : "failure"}`}>
          <strong>
            {result
              ? t("Chính xác!", "Correct!")
              : t("Chưa đúng. Đáp án: ", "Not quite. Answer: ") +
                (exercise.type === "choice" ? exercise.options[exercise.answer] : exercise.answers[0])}
          </strong>
          <p>{exercise.explain}</p>
          <Button onClick={onNext}>
            {last ? t("Xem kết quả", "See results") : t("Câu tiếp", "Next")}
            <ArrowRight size={16} />
          </Button>
        </div>
      )}
    </div>
  );
}
