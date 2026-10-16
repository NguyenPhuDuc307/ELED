import { useEffect, useState } from "react";
import { ArrowLeft, Mic, Plus, Square, Trash2 } from "lucide-react";
import { change } from "./storage";
import { parseSpeaking, speakingScore, type SpeakingSet } from "./model";
import {
  Button,
  Empty,
  IconButton,
  Modal,
  Sound,
  useProfile,
  useText,
} from "./ui";
export function Speaking() {
  const p = useProfile();
  const t = useText();
  const [selected, setSelected] = useState<string | null>(null);
  const [adding, setAdding] = useState(false);
  const [raw, setRaw] = useState("");
  const [title, setTitle] = useState("");
  const [error, setError] = useState("");
  const set = selected ? p.speaking[selected] : null;
  return (
    <section>
      <div className="page-heading">
        <div>
          <span className="eyebrow">SPEAK A LITTLE, EVERY DAY</span>
          <h1>{set?.topic ?? "Speaking"}</h1>
        </div>
        {set ? (
          <IconButton
            label={t("Quay lại", "Back")}
            onClick={() => setSelected(null)}
          >
            <ArrowLeft />
          </IconButton>
        ) : (
          <Button onClick={() => setAdding(true)}>
            <Plus size={17} />
            {t("Thêm bài", "Add set")}
          </Button>
        )}
      </div>
      {set ? (
        <SpeakingPractice set={set} />
      ) : (
        <>
          <p className="muted">
            {t(
              "Nhập bài nói mẫu của bạn để luyện nghe, nhắc lại và ghi âm.",
              "Import your speaking samples to listen, shadow and practise.",
            )}
          </p>
          <div className="collection-grid">
            {Object.values(p.speaking)
              .sort((a, b) => b.createdMs - a.createdMs)
              .map((s) => (
                <div className="card" key={s.id}>
                  <button
                    className="collection-open"
                    onClick={() => setSelected(s.id)}
                  >
                    <Mic />
                    <h2>{s.topic}</h2>
                    <span>
                      {s.items.length} {t("câu hỏi", "questions")}
                    </span>
                  </button>
                  <div className="row">
                    <Button secondary onClick={() => setSelected(s.id)}>
                      {t("Luyện tập", "Practise")}
                    </Button>
                    <IconButton
                      label={t("Xóa bài", "Delete set")}
                      onClick={() => {
                        if (
                          confirm(
                            t("Xóa bài nói này?", "Delete this speaking set?"),
                          )
                        )
                          change("speaking", s.id, null);
                      }}
                    >
                      <Trash2 size={18} />
                    </IconButton>
                  </div>
                </div>
              ))}
          </div>
          {!Object.keys(p.speaking).length && (
            <Empty>
              {t(
                "Chưa có bài nói. Thêm một đoạn hỏi–đáp để bắt đầu.",
                "No speaking sets. Add a question and answer sample to begin.",
              )}
            </Empty>
          )}
        </>
      )}
      {adding && (
        <Modal
          title={t("Nhập bài Speaking", "Import speaking sample")}
          onClose={() => setAdding(false)}
        >
          <form
            onSubmit={(e) => {
              e.preventDefault();
              try {
                const set = parseSpeaking(raw, title);
                change("speaking", set.id, set);
                setAdding(false);
                setSelected(set.id);
                setRaw("");
                setTitle("");
              } catch (e) {
                setError((e as Error).message);
              }
            }}
          >
            <label>
              {t("Chủ đề", "Topic")}
              <input value={title} onChange={(e) => setTitle(e.target.value)} />
            </label>
            <label>
              {t(
                "Nội dung: câu hỏi kết thúc bằng ?, câu trả lời ở dòng sau",
                "Content: questions end with ?, answers on following lines",
              )}
              <textarea
                value={raw}
                required
                rows={10}
                placeholder={
                  "Hobbies\nWhat do you enjoy doing?\nI enjoy reading books in my free time."
                }
                onChange={(e) => setRaw(e.target.value)}
              />
            </label>
            {error && <p role="alert">{error}</p>}
            <Button type="submit">
              {t("Lưu bài nói", "Save speaking set")}
            </Button>
          </form>
        </Modal>
      )}
    </section>
  );
}
function SpeakingPractice({ set }: { set: SpeakingSet }) {
  const t = useText();
  const [index, setIndex] = useState(0);
  const [mode, setMode] = useState("shadow");
  const [hidden, setHidden] = useState(false);
  const [transcript, setTranscript] = useState("");
  const [listening, setListening] = useState(false);
  const [error, setError] = useState("");
  const [recognition, setRecognition] = useState<any>(null);
  const item = set.items[index];
  useEffect(
    () => () => {
      recognition?.abort();
      speechSynthesis.cancel();
    },
    [recognition],
  );
  function record() {
    const Constructor =
      (window as any).SpeechRecognition ||
      (window as any).webkitSpeechRecognition;
    if (!Constructor) {
      setError(
        t(
          "Trình duyệt chưa hỗ trợ nhận diện giọng nói. Hãy thử Chrome hoặc nhập lời bạn nói bên dưới.",
          "Speech recognition is unavailable. Try Chrome or type your transcript below.",
        ),
      );
      return;
    }
    const r = new Constructor();
    r.lang = "en-US";
    r.continuous = true;
    r.interimResults = true;
    r.onresult = (e: any) =>
      setTranscript([...e.results].map((r: any) => r[0].transcript).join(" "));
    r.onend = () => setListening(false);
    r.onerror = (e: any) => {
      setListening(false);
      setError(
        e.error === "not-allowed"
          ? t("Cần cho phép truy cập micro.", "Please allow microphone access.")
          : e.error,
      );
    };
    setRecognition(r);
    r.start();
    setListening(true);
    setError("");
  }
  return (
    <div className="speaking-practice">
      <div className="row">
        <select
          aria-label="Question"
          value={index}
          onChange={(e) => {
            setIndex(+e.target.value);
            setTranscript("");
          }}
        >
          {set.items.map((item, i) => (
            <option key={i} value={i}>
              {i + 1}. {item.q}
            </option>
          ))}
        </select>
        <select
          aria-label="Practice mode"
          value={mode}
          onChange={(e) => setMode(e.target.value)}
        >
          <option value="shadow">Shadowing</option>
          <option value="sentence">
            {t("Từng câu", "Sentence by sentence")}
          </option>
          <option value="recall">{t("Nhớ lại", "Recall")}</option>
        </select>
      </div>
      <article className="card">
        <div className="row between">
          <h2>{item.q}</h2>
          <Sound text={item.q} />
        </div>
        {mode === "sentence" ? (
          item.s.map((s, i) => (
            <div className="sentence" key={i}>
              <p>{s}</p>
              <Sound text={s} />
            </div>
          ))
        ) : (
          <>
            <div className="row">
              <Button secondary onClick={() => setHidden((h) => !h)}>
                {hidden || mode === "recall"
                  ? t("Hiện / ẩn bài mẫu", "Show / hide sample")
                  : t("Ẩn bài mẫu", "Hide sample")}
              </Button>
              <Sound text={item.a} />
            </div>
            {!hidden && mode !== "recall" && (
              <p className="speaking-answer">{item.a}</p>
            )}
            {mode === "recall" && hidden && (
              <p className="speaking-answer">{item.a}</p>
            )}
          </>
        )}
      </article>
      <div className="card">
        <h3>{t("Lượt của bạn", "Your turn")}</h3>
        <Button
          onClick={() =>
            listening ? (recognition.stop(), setListening(false)) : record()
          }
        >
          {listening ? <Square size={17} /> : <Mic size={17} />}{" "}
          {listening
            ? t("Dừng ghi", "Stop recording")
            : t("Bắt đầu nói", "Start speaking")}
        </Button>
        {error && (
          <p role="alert" className="error">
            {error}
          </p>
        )}
        <label>
          {t("Lời bạn nói", "Your transcript")}
          <textarea
            value={transcript}
            onChange={(e) => setTranscript(e.target.value)}
            rows={4}
          />
        </label>
        {transcript && (
          <p className="score">
            {speakingScore(item.a, transcript)}%{" "}
            <span>{t("từ khớp với bài mẫu", "words match the sample")}</span>
          </p>
        )}
      </div>
    </div>
  );
}
