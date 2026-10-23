import { useMemo, useState } from "react";
import { Check, Search, Sparkles } from "lucide-react";
import { change } from "./storage";
import { topicList, type Word } from "./model";
import { topicGroupLabel, topicLabel } from "./topics";
import { Modal, useProfile, useText } from "./ui";

/** Chọn chủ đề cho từ mới của phiên hôm nay; "Tự động" theo thứ tự đề xuất. */
export function TopicPicker({
  words,
  current,
  onClose,
}: {
  words: Word[];
  current?: string;
  onClose: () => void;
}) {
  const t = useText();
  const p = useProfile();
  const vi = p.settings.language !== "en";
  const focus: string | undefined = p.settings.focusTopic;
  const [query, setQuery] = useState("");
  // Liệt kê theo thứ tự đề xuất (bỏ qua chủ đề đang chọn) để danh sách không nhảy chỗ.
  const list = useMemo(
    () => topicList(words, { ...p, settings: { ...p.settings, focusTopic: undefined } }),
    [words, p],
  );
  const groups = useMemo(() => {
    const q = query.trim().toLowerCase();
    const out = new Map<string, typeof list>();
    for (const item of list) {
      const names = [...topicLabel(item.topic, vi), ...topicLabel(item.topic, !vi)].join(" ").toLowerCase();
      if (q && !names.includes(q)) continue;
      out.set(item.group, [...(out.get(item.group) ?? []), item]);
    }
    return [...out];
  }, [list, query, vi]);
  const pick = (topic: string | null) => {
    change("settings", "focusTopic", topic);
    onClose();
  };
  return (
    <Modal title={t("Chọn chủ đề", "Choose a topic")} onClose={onClose}>
      <div className="topic-search">
        <Search size={18} aria-hidden="true" />
        <input
          type="search"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder={t("Tìm chủ đề…", "Search topics…")}
          aria-label={t("Tìm chủ đề", "Search topics")}
        />
      </div>
      <div className="topic-list">
        {!query && (
          <button
            type="button"
            className={`topic-row topic-auto ${!focus ? "is-selected" : ""}`}
            aria-pressed={!focus}
            onClick={() => pick(null)}
          >
            <Sparkles size={18} aria-hidden="true" />
            <span>
              <strong>{t("Tự động", "Automatic")}</strong>
              <small>{t("Đi lần lượt từ chủ đề dễ đến khó", "Go through topics from easy to hard")}</small>
            </span>
            {!focus && <Check size={18} aria-hidden="true" />}
          </button>
        )}
        {groups.map(([group, items]) => (
          <section key={group}>
            <h3>{topicGroupLabel(group, vi)}</h3>
            {items.map((item) => {
              const done = item.remaining === 0;
              const selected = item.topic === focus;
              return (
                <button
                  key={item.topic}
                  type="button"
                  className={`topic-row ${selected ? "is-selected" : ""}`}
                  aria-pressed={selected}
                  disabled={done}
                  onClick={() => pick(item.topic)}
                >
                  <span>
                    <strong>{topicLabel(item.topic, vi)[1]}</strong>
                    <small>
                      {done
                        ? t("Đã học hết", "All learned")
                        : t(`Còn ${item.remaining}/${item.total} từ mới`, `${item.remaining}/${item.total} new words left`)}
                      {item.topic === current && !done && <b>{t(" · đang học", " · current")}</b>}
                    </small>
                  </span>
                  <span className="topic-meter" aria-hidden="true">
                    <span style={{ width: `${((item.total - item.remaining) / item.total) * 100}%` }} />
                  </span>
                  {selected && <Check size={18} aria-hidden="true" />}
                </button>
              );
            })}
          </section>
        ))}
        {!groups.length && <p className="muted">{t("Không có chủ đề phù hợp.", "No matching topics.")}</p>}
      </div>
    </Modal>
  );
}
