import { useDeferredValue, useMemo, useState } from "react";
import {
  BookOpen,
  Check,
  FolderPlus,
  Plus,
  Search,
  Trash2,
  X,
  ChevronRight,
} from "lucide-react";
import { change, getProfile, apply } from "./storage";
import type { Word } from "./model";
import {
  Badge,
  Button,
  Empty,
  IconButton,
  Modal,
  Sound,
  useProfile,
  useText,
} from "./ui";
export function Library({
  words,
  mode = "all",
  view = "search",
  onLearn,
}: {
  words: Word[];
  mode?: "all" | "known" | "history" | "collections";
  view?: "search" | "levels" | "topics";
  onLearn: (words: Word[], title?: string) => void;
}) {
  const p = useProfile();
  const t = useText();
  const [query, setQuery] = useState("");
  const deferred = useDeferredValue(query);
  const [level, setLevel] = useState("");
  const [selectedLevels, setSelectedLevels] = useState(["A1"]);
  const [pos, setPos] = useState("");
  const [subtopic, setSubtopic] = useState("");
  const [topic, setTopic] = useState("");
  const [limit, setLimit] = useState(60);
  const [collection, setCollection] = useState<string | null>(null);
  const [create, setCreate] = useState(false);
  const [name, setName] = useState("");
  const [bulk, setBulk] = useState(false);
  const [raw, setRaw] = useState("");
  const [error, setError] = useState("");
  const categories = useMemo(
    () =>
      [
        ...new Set(
          words.flatMap((w) => w.topics.map((t) => t.split(" - ")[0])),
        ),
      ].sort(),
    [words],
  );
  const byWord = useMemo(
    () => new Map(words.map((w) => [w.word.toLowerCase(), w])),
    [words],
  );
  const filtered = useMemo(() => {
    let pool = words;
    if (mode === "known")
      pool = words.filter((w) => p.known[w.word.toLowerCase()]);
    if (mode === "history")
      pool = words
        .filter((w) => p.history[w.word.toLowerCase()])
        .sort(
          (a, b) =>
            p.history[b.word.toLowerCase()] - p.history[a.word.toLowerCase()],
        );
    if (mode === "collections" && collection)
      pool = (p.collections[collection] ?? []).map(
        (w) =>
          byWord.get(w) || {
            word: w,
            translation: p.custom[w] ?? "",
            pos: "",
            ipa: "",
            audio: "",
            url: "",
            levels: [],
            topics: [],
          },
      );
    const q = deferred.trim().toLowerCase();
    return pool.filter(
      (w) =>
        (!q ||
          w.word.toLowerCase().includes(q) ||
          w.translation.toLowerCase().includes(q)) &&
        (!level || w.levels.includes(level)) &&
        (!topic || w.topics.some((t) => t.startsWith(topic + " - "))),
    );
  }, [words, p, deferred, level, topic, collection, mode]);
  const title =
    mode === "known"
      ? t("Từ đã biết", "Known words")
      : mode === "history"
        ? t("Lịch sử", "History")
        : mode === "collections"
          ? (collection ?? t("Bộ sưu tập", "Collections"))
          : t("Thư viện từ vựng", "Vocabulary library");
  async function importWords() {
    if (!collection) return;
    const list = [
      ...new Set(
        raw
          .split(/[\n,;]+/)
          .map((w) => w.trim().toLowerCase())
          .filter(Boolean),
      ),
    ];
    if (!list.length) {
      setError(t("Nhập ít nhất một từ.", "Enter at least one word."));
      return;
    }
    const custom = list.filter((w) => !byWord.has(w) && !p.custom[w]);
    try {
      const translations = await Promise.all(
        custom.map(async (word) => {
          const r = await fetch(
            "https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=vi&dt=t&q=" +
              encodeURIComponent(word),
          );
          const j = await r.json();
          return {
            section: "custom" as const,
            key: word,
            value: j[0].map((s: any[]) => s[0]).join(""),
          };
        }),
      );
      apply([
        ...translations,
        {
          section: "collections",
          key: collection,
          value: [...new Set([...(p.collections[collection] ?? []), ...list])],
        },
      ]);
      setRaw("");
      setBulk(false);
    } catch {
      setError(
        t(
          "Không dịch được từ mới. Thử lại khi có mạng.",
          "Could not translate new words. Please try again online.",
        ),
      );
    }
  }
  const dayGrid = (pool: Word[]) => (
    <div className="day-grid">
      {!pool.length && <Empty>{t("Không có từ cần học ở cấp độ này.", "No words to study at this level.")}</Empty>}
      {Array.from({ length: Math.ceil(pool.length / 20) }, (_, i) => {
        const list = pool.slice(i * 20, i * 20 + 20);
        const learned = list.filter((w) => p.known[w.word.toLowerCase()] || p.srs[w.word.toLowerCase()]).length;
        return (
          <button
            key={i}
            className={"card day-card level-" + (list[0]?.levels[0] ?? "A1")}
            onClick={() =>
              onLearn(list, t("Ngày " + (i + 1), "Day " + (i + 1)))
            }
          >
            <div className="day-card-heading">
              <h2>{t("Ngày " + (i + 1), "Day " + (i + 1))}</h2>
              <BookOpen size={17} aria-hidden="true" />
            </div>
            <p className="day-preview">{list.slice(0, 3).map((w) => w.word).join(" · ")}</p>
            <div className="day-progress">
              <span>{learned ? t(`${learned}/${list.length} đã học`, `${learned}/${list.length} studied`) : t("Chưa bắt đầu", "Not started")}</span>
              <progress value={learned} max={list.length} aria-label={t("Tiến độ ngày học", "Day progress")} />
            </div>
            <div className="row between">
              <span>
                {list.length} {t("từ", "words")}
              </span>
              <ChevronRight size={20} />
            </div>
          </button>
        );
      })}
    </div>
  );
  if (view === "levels") {
    const pool = words.filter(
      (w) =>
        !p.known[w.word.toLowerCase()] &&
        w.levels.some((l) => selectedLevels.includes(l)) &&
        (!pos || w.pos.toLowerCase().includes(pos)),
    );
    return (
      <section className="levels-page">
        <div className="level-tabs">
          {["A1", "A2", "B1", "B2", "C1"].map((l) => (
            <button
              key={l}
              className={selectedLevels.includes(l) ? "active" : ""}
              onClick={() =>
                setSelectedLevels((levels) =>
                  levels.includes(l)
                    ? levels.length === 1
                      ? levels
                      : levels.filter((k) => k !== l)
                    : [...levels, l],
                )
              }
            >
              {l}
            </button>
          ))}
        </div>
        <div className="pos-tabs">
          {["", "noun", "verb", "adjective", "adverb"].map((k) => (
            <button
              key={k}
              className={pos === k ? "active" : ""}
              onClick={() => setPos(k)}
            >
              {k || t("Tất cả", "All")}
            </button>
          ))}
        </div>
        {dayGrid(pool)}
      </section>
    );
  }
  const topicWords = words.filter(w => !level || w.levels.includes(level));
  const topicLevelFilter = (
    <div className="level-tabs" role="group" aria-label={t("Lọc cấp độ", "Filter by level")}>
      {["", "A1", "A2", "B1", "B2", "C1"].map(value => (
        <button key={value} className={level === value ? "active" : ""}
          aria-pressed={level === value} onClick={() => setLevel(value)}>
          {value || t("Tất cả", "All")}
        </button>
      ))}
    </div>
  );
  if (view === "topics" && topic) {
    const leaves = [
      ...new Set(
        words.flatMap((w) =>
          w.topics.filter((k) => k.startsWith(topic + " - ")),
        ),
      ),
    ].sort();
    if (!subtopic)
      return (
        <section>
          {topicLevelFilter}
          <button className="text-btn" onClick={() => setTopic("")}>
            ‹ {topic.replaceAll("_", " ")}
          </button>
          <div className="topic-grid">
            {leaves.map((leaf, i) => (
              <button
                className={
                  "card level-" + ["A1", "A2", "B1", "B2", "C1"][i % 5]
                }
                key={leaf}
                onClick={() => setSubtopic(leaf)}
              >
                <h2>
                  {leaf.split(" - ").slice(1).join(" - ").replaceAll("_", " ")}
                </h2>
                <p>
                  {topicWords.filter((w) => w.topics.includes(leaf)).length}{" "}
                  {t("từ", "words")}
                </p>
              </button>
            ))}
          </div>
        </section>
      );
    return (
      <section>
        {topicLevelFilter}
        <button className="text-btn" onClick={() => setSubtopic("")}>
          ‹ {subtopic.split(" - ").slice(1).join(" - ").replaceAll("_", " ")}
        </button>
        {dayGrid(
          topicWords.filter(
            (w) =>
              w.topics.includes(subtopic) && !p.known[w.word.toLowerCase()],
          ),
        )}
      </section>
    );
  }
  if (view === "topics" && !topic)
    return (
      <section>
      {topicLevelFilter}
      <div className="topic-grid">
        {categories.map((c, i) => (
          <button
            className={"card level-" + ["A1", "A2", "B1", "B2", "C1"][i % 5]}
            key={c}
            onClick={() => setTopic(c)}
          >
            <h2>{c.replaceAll("_", " ")}</h2>
            <p>
              {
                topicWords.filter((w) =>
                  w.topics.some((t) => t.startsWith(c + " - ")),
                ).length
              }{" "}
              {t("từ", "words")}
            </p>
          </button>
        ))}
      </div>
      </section>
    );
  return (
    <section
      className={
        "library-page library-" +
        view +
        (mode === "all" && view === "search" && !query.trim()
          ? " is-empty-search"
          : "")
      }
    >
      <div className="page-heading">
        <div>
          <span className="eyebrow">ENGLISH LEARNING LIBRARY</span>
          <h1>{title}</h1>
          {(level || topic) && (
            <button
              className="text-btn"
              onClick={() => {
                setLevel("");
                setTopic("");
              }}
            >
              {level || topic.replaceAll("_", " ")} · {t("Đổi", "Change")}
            </button>
          )}
        </div>
        {mode === "collections" && !collection && (
          <Button onClick={() => setCreate(true)}>
            <Plus size={18} />
            {t("Tạo mới", "Create")}
          </Button>
        )}
        {collection && (
          <IconButton
            label={t("Đóng bộ sưu tập", "Close collection")}
            onClick={() => setCollection(null)}
          >
            <X />
          </IconButton>
        )}
      </div>
      {mode === "collections" && !collection ? (
        <>
          <p className="muted">
            {t(
              "Những từ bạn muốn dành thêm thời gian.",
              "Words you want to spend more time with.",
            )}
          </p>
          <div className="collection-grid">
            {Object.entries(p.collections).map(([name, items]) => (
              <article className="card" key={name}>
                <button
                  className="collection-open"
                  onClick={() => setCollection(name)}
                >
                  <FolderPlus size={28} />
                  <h2>{name}</h2>
                  <span>
                    {items.length} {t("từ", "words")}
                  </span>
                </button>
                <div className="row">
                  <Button
                    secondary
                    disabled={!items.length}
                    onClick={() =>
                      onLearn(
                        items.map(
                          (w) =>
                            byWord.get(w) || {
                              word: w,
                              translation: p.custom[w] ?? "",
                              pos: "",
                              ipa: "",
                              audio: "",
                              url: "",
                              levels: [],
                              topics: [],
                            },
                        ),
                      )
                    }
                  >
                    {t("Học", "Learn")}
                  </Button>
                  <IconButton
                    label={t("Xóa bộ sưu tập", "Delete collection")}
                    onClick={() => {
                      if (
                        confirm(
                          t(
                            "Xóa bộ sưu tập này? Từ đã biết và tiến độ vẫn được giữ.",
                            "Delete this collection? Known words and progress are kept.",
                          ),
                        )
                      )
                        change("collections", name, null);
                    }}
                  >
                    <Trash2 size={18} />
                  </IconButton>
                </div>
              </article>
            ))}
          </div>
          {!Object.keys(p.collections).length && (
            <Empty>
              {t(
                "Chưa có bộ sưu tập. Tạo bộ đầu tiên để thêm từ.",
                "No collections yet. Create your first one to add words.",
              )}
            </Empty>
          )}
        </>
      ) : (
        <>
          <div className="filters">
            <label className="search-box">
              <Search size={19} />
              <input
                aria-label={t("Tìm kiếm từ vựng", "Search vocabulary")}
                placeholder={t(
                  "Tìm từ hoặc nghĩa…",
                  "Search words or meanings…",
                )}
                value={query}
                onChange={(e) => {
                  setQuery(e.target.value);
                  setLimit(60);
                }}
              />
              {query && (
                <button aria-label="Clear search" onClick={() => setQuery("")}>
                  <X size={17} />
                </button>
              )}
            </label>
            {mode === "all" && (
              <div className="row">
                <select
                  aria-label={t("Cấp độ", "Level")}
                  value={level}
                  onChange={(e) => {
                    setLevel(e.target.value);
                    setLimit(60);
                  }}
                >
                  <option value="">{t("Mọi cấp độ", "All levels")}</option>
                  {["A1", "A2", "B1", "B2", "C1"].map((l) => (
                    <option key={l}>{l}</option>
                  ))}
                </select>
                <select
                  aria-label={t("Chủ đề", "Topic")}
                  value={topic}
                  onChange={(e) => {
                    setTopic(e.target.value);
                    setLimit(60);
                  }}
                >
                  <option value="">{t("Mọi chủ đề", "All topics")}</option>
                  {categories.map((c) => (
                    <option key={c} value={c}>
                      {c.replaceAll("_", " ")}
                    </option>
                  ))}
                </select>
              </div>
            )}
          </div>
          {mode === "all" && view === "search" && !query.trim() && (
            <div className="search-prompt">
              <Search size={48} />
              <h2>{t("Tìm trong toàn bộ từ vựng", "Search all vocabulary")}</h2>
              <p>
                {t(
                  "Nhập một từ hoặc nghĩa để bắt đầu.",
                  "Enter a word or meaning to get started.",
                )}
              </p>
            </div>
          )}
          <div className="row between results-summary">
            <span className="muted">
              {filtered.length.toLocaleString()} {t("từ", "words")}
            </span>
            {collection ? (
              <Button secondary onClick={() => setBulk(true)}>
                <Plus size={16} />
                {t("Thêm từ", "Add words")}
              </Button>
            ) : (
              <Button
                secondary
                disabled={!filtered.length}
                onClick={() => onLearn(filtered.slice(0, 20))}
              >
                <BookOpen size={16} />
                {t("Học các từ này", "Study these words")}
              </Button>
            )}
          </div>
          <div className="word-list">
            {filtered.slice(0, limit).map((w) => (
              <div className="word-row" key={w.word}>
                <button className="word-open" onClick={() => onLearn([w])}>
                  <strong>{w.word}</strong>
                  <span className="muted ipa-text">{w.ipa}</span>
                  <span>{w.translation}</span>
                </button>
                <div className="word-tools">
                  {w.levels[0] && <Badge>{w.levels[0]}</Badge>}
                  <Sound word={w} />
                  {collection ? (
                    <IconButton
                      label={t(
                        "Bỏ từ khỏi bộ sưu tập",
                        "Remove from collection",
                      )}
                      onClick={() =>
                        change(
                          "collections",
                          collection,
                          p.collections[collection].filter(
                            (k) => k !== w.word.toLowerCase(),
                          ),
                        )
                      }
                    >
                      <X size={17} />
                    </IconButton>
                  ) : (
                    <IconButton
                      label={
                        p.known[w.word.toLowerCase()]
                          ? t("Đánh dấu chưa biết", "Mark unknown")
                          : t("Đánh dấu đã biết", "Mark known")
                      }
                      className={
                        p.known[w.word.toLowerCase()] ? "selected" : ""
                      }
                      onClick={() =>
                        change(
                          "known",
                          w.word.toLowerCase(),
                          !p.known[w.word.toLowerCase()],
                        )
                      }
                    >
                      <Check size={18} />
                    </IconButton>
                  )}
                </div>
              </div>
            ))}
          </div>
          {filtered.length > limit && (
            <Button
              secondary
              className="load-more"
              onClick={() => setLimit((n) => n + 60)}
            >
              {t("Xem thêm", "Show more")}
            </Button>
          )}
          {!filtered.length && (
            <Empty>
              {t("Không tìm thấy từ phù hợp.", "No matching words.")}
            </Empty>
          )}
        </>
      )}
      {create && (
        <Modal
          title={t("Tạo bộ sưu tập", "Create collection")}
          onClose={() => setCreate(false)}
        >
          <form
            onSubmit={(e) => {
              e.preventDefault();
              if (name.trim() && !p.collections[name.trim()]) {
                change("collections", name.trim(), []);
                setCollection(name.trim());
                setCreate(false);
                setName("");
              }
            }}
          >
            <label>
              {t("Tên bộ sưu tập", "Collection name")}
              <input
                value={name}
                maxLength={100}
                required
                onChange={(e) => setName(e.target.value)}
                autoFocus
              />
            </label>
            {p.collections[name.trim()] && (
              <p role="alert">
                {t("Tên này đã tồn tại.", "This name already exists.")}
              </p>
            )}
            <Button
              type="submit"
              disabled={!name.trim() || !!p.collections[name.trim()]}
            >
              {t("Tạo bộ sưu tập", "Create collection")}
            </Button>
          </form>
        </Modal>
      )}
      {bulk && (
        <Modal
          title={t("Thêm từ hàng loạt", "Add words in bulk")}
          onClose={() => setBulk(false)}
        >
          <p>
            {t(
              "Mỗi từ một dòng, hoặc phân cách bằng dấu phẩy. Từ ngoài thư viện sẽ được dịch tự động.",
              "One word per line, or separated by commas. Words outside the library are translated automatically.",
            )}
          </p>
          <textarea
            aria-label={t("Danh sách từ", "Word list")}
            value={raw}
            onChange={(e) => setRaw(e.target.value)}
            rows={8}
          />
          {error && <p role="alert">{error}</p>}
          <Button onClick={importWords}>
            {t("Thêm vào bộ sưu tập", "Add to collection")}
          </Button>
        </Modal>
      )}
    </section>
  );
}
