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
  ClipboardCheck,
  History,
  Lightbulb,
  RotateCcw,
  Shuffle,
  Volume2,
} from "lucide-react";
import { apply } from "./storage";
import { localDate, type Operation } from "./model";
import {
  grammarGroups,
  grammarUnits,
  itemKey,
  mixedItems,
  needsStudy,
  nextReview,
  normalizeAnswer,
  PASS_RATIO,
  placementItems,
  placementKey,
  recommendedUnit,
  reviewItems,
  shuffled,
  unitScore,
  type GrammarExercise,
  type GrammarUnit,
  type PracticeItem,
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
const answerOf = (e: GrammarExercise) => (e.type === "choice" ? e.options[e.answer] : e.answers[0]);

type Mode = "unit" | "test" | "review" | "mixed";

/** /grammar, /grammar/test|review|mixed, /grammar/<id>, /grammar/<id>/practice */
export function Grammar({ path }: { path: string }) {
  const p = useProfile();
  const t = useText();
  const [, , id, sub] = path.split("/");
  if (id === "test")
    return <PracticeSession key={path} mode="test" title={t("Kiểm tra xếp lộ trình", "Placement check")} items={() => placementItems(grammarUnits)} />;
  if (id === "review")
    return <PracticeSession key={path} mode="review" title={t("Ôn câu sai", "Review mistakes")} items={() => shuffled(reviewItems(grammarUnits, p.grammarReview ?? {})).slice(0, 20)} />;
  if (id === "mixed")
    return <PracticeSession key={path} mode="mixed" title={t("Đề tổng hợp", "Mixed practice")} items={() => mixedItems(grammarUnits, p.grammar ?? {})} />;
  const unit = grammarUnits.find((u) => u.id === id);
  if (id && !unit) return <Empty>{t("Không tìm thấy bài ngữ pháp này.", "Grammar unit not found.")}</Empty>;
  if (unit && sub === "practice")
    return (
      <PracticeSession
        key={path}
        mode="unit"
        unit={unit}
        title={p.settings.language === "en" ? unit.en : unit.title}
        items={() => shuffled(unit.exercises.map((exercise, index) => ({ unit, index, exercise })))}
      />
    );
  if (unit) return <GrammarLesson key={unit.id} unit={unit} />;
  return <GrammarHome />;
}

function GrammarHome() {
  const t = useText();
  const p = useProfile();
  const vi = p.settings.language !== "en";
  const scores = p.grammar ?? {};
  const passed = grammarUnits.filter((u) => unitScore(scores, u.id)?.passed).length;
  const next = recommendedUnit(grammarUnits, scores);
  const tested = grammarUnits.some((u) => scores[placementKey(u.id)]);
  const pending = reviewItems(grammarUnits, p.grammarReview ?? {}, Date.now(), false).length;
  const due = reviewItems(grammarUnits, p.grammarReview ?? {}).length;
  const studied = grammarUnits.some((u) => scores[u.id]);
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
        {next && (
          <Button onClick={() => go(`/grammar/${next.id}`)}>
            {passed || tested ? t("Học tiếp", "Continue") : t("Bắt đầu", "Start")}: {vi ? next.title : next.en}
            <ArrowRight size={16} />
          </Button>
        )}
      </div>

      <div className="grammar-actions">
        {!tested && (
          <ActionCard
            icon={<ClipboardCheck size={20} />}
            title={t("Kiểm tra xếp lộ trình", "Placement check")}
            text={t(`${grammarUnits.length} câu, khoảng 5 phút: biết ngay bài nào cần học, bài nào đã vững.`, `${grammarUnits.length} questions, about 5 minutes: see which units you need.`)}
            onClick={() => go("/grammar/test")}
            highlight
          />
        )}
        {pending > 0 && (
          <ActionCard
            icon={<History size={20} />}
            title={t("Ôn câu sai", "Review mistakes")}
            text={
              due
                ? t(`${due} câu đến hạn ôn hôm nay.`, `${due} due today.`)
                : t(`${pending} câu đang chờ, chưa đến hạn.`, `${pending} waiting, none due yet.`)
            }
            onClick={due ? () => go("/grammar/review") : undefined}
            highlight={due > 0}
            count={due || undefined}
          />
        )}
        <ActionCard
          icon={<Shuffle size={20} />}
          title={t("Đề tổng hợp", "Mixed practice")}
          text={studied ? t("10 câu ngẫu nhiên từ các bài bạn đã học.", "10 random questions from units you have studied.") : t("10 câu ngẫu nhiên từ mọi bài.", "10 random questions from all units.")}
          onClick={() => go("/grammar/mixed")}
        />
        {tested && (
          <ActionCard
            icon={<ClipboardCheck size={20} />}
            title={t("Làm lại bài kiểm tra", "Retake placement check")}
            text={t("Cập nhật lộ trình sau một thời gian học.", "Refresh your path after some study.")}
            onClick={() => go("/grammar/test")}
          />
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
                const s = unitScore(scores, u.id);
                const weak = needsStudy(scores, u.id);
                return (
                  <button key={u.id} type="button" className="grammar-unit-card" onClick={() => go(`/grammar/${u.id}`)}>
                    <span className={`grammar-status ${s?.passed ? "passed" : s ? "tried" : weak ? "weak" : ""}`} aria-hidden="true">
                      {s?.passed ? <Check size={16} /> : <BookOpenCheck size={16} />}
                    </span>
                    <span>
                      <strong>{vi ? u.title : u.en}</strong>
                      <small>
                        {vi ? u.en : u.title}
                        {s && ` · ${s.b}/${s.n}`}
                      </small>
                    </span>
                    {weak && <span className="grammar-tag">{t("Nên học", "Study")}</span>}
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

function ActionCard({
  icon,
  title,
  text,
  onClick,
  highlight,
  count,
}: {
  icon: ReactNode;
  title: string;
  text: string;
  onClick?: () => void;
  highlight?: boolean;
  count?: number;
}) {
  return (
    <button type="button" className={`grammar-action ${highlight ? "highlight" : ""}`} onClick={onClick} disabled={!onClick}>
      <span className="grammar-action-icon" aria-hidden="true">
        {icon}
        {count ? <b>{count}</b> : null}
      </span>
      <span>
        <strong>{title}</strong>
        <small>{text}</small>
      </span>
      {onClick && <ChevronRight size={18} aria-hidden="true" />}
    </button>
  );
}

function GrammarLesson({ unit }: { unit: GrammarUnit }) {
  const t = useText();
  const p = useProfile();
  const vi = p.settings.language !== "en";
  const s = unitScore(p.grammar ?? {}, unit.id);
  const weak = needsStudy(p.grammar ?? {}, unit.id);
  return (
    <article className="grammar-page grammar-lesson">
      <div className="grammar-lesson-head">
        <Badge>Band {unit.band}+</Badge>
        {weak && <span className="grammar-tag">{t("Bài kiểm tra: nên học", "Placement: study this")}</span>}
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

/** Một lượt làm bài: luyện một bài, kiểm tra xếp lộ trình, ôn câu sai hoặc đề tổng hợp. */
function PracticeSession({
  mode,
  title,
  items: makeItems,
  unit,
}: {
  mode: Mode;
  title: string;
  items: () => PracticeItem[];
  unit?: GrammarUnit;
}) {
  const t = useText();
  const p = useProfile();
  // Chốt danh sách câu hỏi khi mở; lưu kết quả không được làm đề tự đổi giữa chừng.
  const [round, setRound] = useState(0);
  const items = useMemo(makeItems, [round]);
  const [index, setIndex] = useState(0);
  const [results, setResults] = useState<boolean[]>([]);
  const backTo = unit ? `/grammar/${unit.id}` : "/grammar";
  const item = items[index];

  if (!items.length)
    return (
      <section className="grammar-page grammar-result card">
        <h1>{t("Không có câu nào để ôn", "Nothing to review")}</h1>
        <p className="muted">{t("Các câu làm sai sẽ quay lại đây khi đến hạn ôn.", "Questions you miss come back here when they are due.")}</p>
        <div className="grammar-result-actions">
          <Button onClick={() => navigateBack("/grammar")}>{t("Về trang Ngữ pháp", "Back to Grammar")}</Button>
        </div>
      </section>
    );

  function finish(all: boolean[]) {
    const now = Date.now();
    const ops: Operation[] = [{ section: "activity", key: localDate(), value: true }];
    const correct = all.filter(Boolean).length;
    if (mode === "test") {
      items.forEach((it, i) => ops.push({ section: "grammar", key: placementKey(it.unit.id), value: { b: all[i] ? 1 : 0, n: 1, t: now } }));
    } else {
      const review = p.grammarReview ?? {};
      items.forEach((it, i) => {
        const key = itemKey(it.unit.id, it.index);
        const next = nextReview(review[key], all[i], now);
        if (next !== undefined) ops.push({ section: "grammarReview", key, value: next });
      });
    }
    if (mode === "unit" && unit) {
      const best = p.grammar?.[unit.id];
      if (!best || correct / items.length >= best.b / best.n)
        ops.push({ section: "grammar", key: unit.id, value: { b: correct, n: items.length, t: now } });
    }
    apply(ops);
  }
  function advance() {
    if (index + 1 >= items.length) finish(results);
    setIndex(index + 1);
  }
  function restart() {
    setRound((r) => r + 1);
    setIndex(0);
    setResults([]);
  }

  if (!item)
    return <SessionResult mode={mode} unit={unit} items={items} results={results} onRestart={restart} backTo={backTo} />;

  return (
    <section className="grammar-page grammar-practice">
      <header className="lesson-header">
        <IconButton label={t("Quay lại", "Back")} onClick={() => navigateBack(backTo)}>
          <ArrowLeft />
        </IconButton>
        <div>
          <h1>{title}</h1>
          <strong>
            {index + 1} / {items.length}
          </strong>
        </div>
      </header>
      <div className="progress">
        <div style={{ width: `${(index / items.length) * 100}%` }} />
      </div>
      {mode !== "unit" && (
        <p className="grammar-question-unit">{p.settings.language === "en" ? item.unit.en : item.unit.title}</p>
      )}
      <Question
        key={`${round}-${index}`}
        exercise={item.exercise}
        onAnswered={(ok) => setResults((r) => [...r, ok])}
        onNext={advance}
        last={index + 1 === items.length}
        showExplanation={mode !== "test"}
      />
    </section>
  );
}

function SessionResult({
  mode,
  unit,
  items,
  results,
  onRestart,
  backTo,
}: {
  mode: Mode;
  unit?: GrammarUnit;
  items: PracticeItem[];
  results: boolean[];
  onRestart: () => void;
  backTo: string;
}) {
  const t = useText();
  const p = useProfile();
  const vi = p.settings.language !== "en";
  const correct = results.filter(Boolean).length;
  const total = items.length;
  const passed = correct / total >= PASS_RATIO;
  const wrong = items.filter((_, i) => !results[i]);
  const nextUnit = unit ? grammarUnits[grammarUnits.indexOf(unit) + 1] : undefined;
  const recommended = recommendedUnit(grammarUnits, p.grammar ?? {});

  if (mode === "test") {
    const weak = wrong.map((it) => it.unit);
    return (
      <section className="grammar-page grammar-result card">
        <div className={`grammar-result-score ${passed ? "passed" : ""}`}>
          {correct}/{total}
        </div>
        <h1>{t("Lộ trình của bạn", "Your study path")}</h1>
        <p className="muted">
          {weak.length
            ? t(`Có ${weak.length} chủ điểm bạn nên học. Các bài này được đánh dấu "Nên học" trong danh sách.`, `${weak.length} units to study. They are marked "Study" in the list.`)
            : t("Bạn trả lời đúng hết. Hãy luyện các bài nâng cao để giữ phong độ.", "All correct. Practise the advanced units to stay sharp.")}
        </p>
        {weak.length > 0 && (
          <ul className="grammar-weak-list">
            {weak.map((u) => (
              <li key={u.id}>
                <button type="button" onClick={() => go(`/grammar/${u.id}`)}>
                  <span>{vi ? u.title : u.en}</span>
                  <Badge>Band {u.band}+</Badge>
                  <ChevronRight size={16} aria-hidden="true" />
                </button>
              </li>
            ))}
          </ul>
        )}
        <div className="grammar-result-actions">
          {recommended && (
            <Button onClick={() => go(`/grammar/${recommended.id}`)}>
              {t("Bắt đầu", "Start")}: {vi ? recommended.title : recommended.en}
              <ArrowRight size={16} />
            </Button>
          )}
          <Button secondary onClick={() => navigateBack("/grammar")}>
            {t("Về trang Ngữ pháp", "Back to Grammar")}
          </Button>
        </div>
      </section>
    );
  }

  return (
    <section className="grammar-page grammar-result card">
      <div className={`grammar-result-score ${passed ? "passed" : ""}`}>
        {correct}/{total}
      </div>
      <h1>
        {mode === "review"
          ? t("Đã ôn xong", "Review done")
          : passed
            ? t("Làm tốt lắm!", "Well done!")
            : t("Cần ôn thêm một chút", "Needs a little more practice")}
      </h1>
      <p className="muted">
        {mode === "unit" && !passed
          ? t(`Đạt từ ${Math.ceil(total * PASS_RATIO)}/${total} để hoàn thành bài. `, `Score ${Math.ceil(total * PASS_RATIO)}/${total} to complete the unit. `)
          : ""}
        {wrong.length
          ? t("Các câu sai sẽ quay lại trong mục Ôn câu sai sau 1 ngày.", "Missed questions come back in Review mistakes tomorrow.")
          : mode === "review"
            ? t("Câu đúng sẽ giãn dần lịch ôn; đúng 3 lần liên tiếp là xong.", "Correct answers are spaced further apart; three in a row and they're done.")
            : t("Thử áp dụng ngay trong bài viết hoặc câu trả lời Speaking tiếp theo.", "Try it in your next essay or Speaking answer.")}
      </p>
      {wrong.length > 0 && (
        <ol className="grammar-review">
          {wrong.map((it) => (
            <li key={itemKey(it.unit.id, it.index)}>
              {mode !== "unit" && <span className="grammar-review-unit">{vi ? it.unit.title : it.unit.en}</span>}
              <p lang="en">{it.exercise.q.replace("___", "_____")}</p>
              <strong lang="en">{answerOf(it.exercise)}</strong>
              <small>{it.exercise.explain}</small>
            </li>
          ))}
        </ol>
      )}
      <div className="grammar-result-actions">
        {mode !== "review" && (
          <Button secondary onClick={onRestart}>
            <RotateCcw size={16} />
            {mode === "mixed" ? t("Đề khác", "New set") : t("Làm lại", "Try again")}
          </Button>
        )}
        {mode === "unit" && passed && nextUnit ? (
          <Button onClick={() => go(`/grammar/${nextUnit.id}`)}>
            {t("Bài tiếp", "Next unit")}: {vi ? nextUnit.title : nextUnit.en}
            <ArrowRight size={16} />
          </Button>
        ) : (
          <Button onClick={() => navigateBack(backTo)}>
            {mode === "unit" ? t("Xem lại bài học", "Review the lesson") : t("Về trang Ngữ pháp", "Back to Grammar")}
          </Button>
        )}
      </div>
    </section>
  );
}

function Question({
  exercise,
  onAnswered,
  onNext,
  last,
  showExplanation,
}: {
  exercise: GrammarExercise;
  onAnswered: (ok: boolean) => void;
  onNext: () => void;
  last: boolean;
  showExplanation: boolean;
}) {
  const t = useText();
  const [picked, setPicked] = useState<number | null>(null);
  const [text, setText] = useState("");
  const [result, setResult] = useState<boolean | null>(null);
  // Xáo phương án mỗi lần làm để không học thuộc vị trí đáp án.
  const order = useMemo(() => (exercise.type === "choice" ? shuffled(exercise.options.map((_, i) => i)) : []), [exercise]);
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
          {order.map((i) => (
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
              {exercise.options[i]}
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
          <strong>{result ? t("Chính xác!", "Correct!") : t("Chưa đúng. Đáp án: ", "Not quite. Answer: ") + answerOf(exercise)}</strong>
          {showExplanation && <p>{exercise.explain}</p>}
          <Button onClick={onNext}>
            {last ? t("Xem kết quả", "See results") : t("Câu tiếp", "Next")}
            <ArrowRight size={16} />
          </Button>
        </div>
      )}
    </div>
  );
}
