import { useEffect, useMemo, useState } from "react";
import { ArrowLeft, Timer, Trophy } from "lucide-react";
import { shuffle, type Word } from "./model";
import { Button, IconButton, useText } from "./ui";
export function MatchGame({
  words,
  speed = false,
  onClose,
}: {
  words: Word[];
  speed?: boolean;
  onClose: () => void;
}) {
  const t = useText();
  const [round, setRound] = useState(0);
  const [selected, setSelected] = useState<string | null>(null);
  const [matched, setMatched] = useState<string[]>([]);
  const [wrong, setWrong] = useState<string | null>(null);
  const [score, setScore] = useState(0);
  const [seconds, setSeconds] = useState(30);
  const [finished, setFinished] = useState(false);
  const pool = useMemo(
    () => shuffle(words.filter((w) => w.translation)).slice(0, 5),
    [words, round],
  );
  const meanings = useMemo(() => shuffle(pool), [pool]);
  useEffect(() => {
    if (!speed || finished) return;
    const id = setInterval(
      () =>
        setSeconds((s) => {
          if (s <= 1) {
            setFinished(true);
            return 0;
          }
          return s - 1;
        }),
      1000,
    );
    return () => clearInterval(id);
  }, [speed, finished]);
  function choose(word: Word) {
    if (!selected || matched.includes(word.word)) return;
    if (selected === word.word) {
      const next = [...matched, word.word];
      setMatched(next);
      setScore((s) => s + 1);
      setSelected(null);
      if (next.length === pool.length) {
        if (speed) {
          setTimeout(() => {
            setRound((n) => n + 1);
            setMatched([]);
          }, 250);
        } else setFinished(true);
      }
    } else {
      setWrong(word.word);
      setTimeout(() => setWrong(null), 450);
      setSelected(null);
    }
  }
  return (
    <section className="game">
      <header className="lesson-header">
        <IconButton label={t("Quay lại", "Back")} onClick={onClose}>
          <ArrowLeft />
        </IconButton>
        <h1>
          {speed
            ? t("Match tốc độ", "Speed match")
            : t("Ghép cặp", "Matching pairs")}
        </h1>
        {speed && <BadgeTimer value={seconds} />}
      </header>
      {finished ? (
        <div className="results card">
          <Trophy size={44} />
          <h2>{t("Làm tốt lắm!", "Well done!")}</h2>
          <p>
            {score} {t("cặp chính xác", "correct pairs")}
          </p>
          <Button
            onClick={() => {
              setRound((n) => n + 1);
              setMatched([]);
              setScore(0);
              setSeconds(30);
              setFinished(false);
            }}
          >
            {t("Chơi lại", "Play again")}
          </Button>
          <Button secondary onClick={onClose}>
            {t("Về hôm nay", "Back to today")}
          </Button>
        </div>
      ) : (
        <>
          <p className="muted">
            {t(
              "Chọn một từ, rồi chọn nghĩa phù hợp.",
              "Choose a word, then its matching meaning.",
            )}
          </p>
          <div className="match-columns">
            <div>
              {pool.map((w) => (
                <button
                  key={w.word}
                  className={`${selected === w.word ? "chosen" : ""} ${matched.includes(w.word) ? "matched" : ""}`}
                  disabled={matched.includes(w.word)}
                  onClick={() => setSelected(w.word)}
                >
                  {w.word}
                </button>
              ))}
            </div>
            <div>
              {meanings.map((w) => (
                <button
                  key={w.word}
                  className={`${matched.includes(w.word) ? "matched" : ""} ${wrong === w.word ? "wrong" : ""}`}
                  disabled={matched.includes(w.word)}
                  onClick={() => choose(w)}
                >
                  {w.translation}
                </button>
              ))}
            </div>
          </div>
          <p className="muted">
            {score} {t("cặp đã ghép", "pairs matched")}
          </p>
        </>
      )}
    </section>
  );
}
function BadgeTimer({ value }: { value: number }) {
  return (
    <span className="timer">
      <Timer size={18} />
      {value}s
    </span>
  );
}
