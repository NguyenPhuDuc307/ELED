import type { GrammarGroup, GrammarUnit } from "./types";
import { foundation } from "./foundation";
import { complex } from "./complex";
import { task1 } from "./task1";
import { advanced } from "./advanced";

export type { GrammarUnit, GrammarExercise, GrammarGroup } from "./types";

export const grammarGroups: { id: GrammarGroup; band: string; vi: string; en: string; about: [string, string] }[] = [
  {
    id: "foundation",
    band: "5.0",
    vi: "Nền tảng",
    en: "Foundations",
    about: ["Thì, mạo từ, hoà hợp chủ – vị: nắm chắc để không mất điểm vì lỗi cơ bản.", "Tenses, articles and agreement: the accuracy every band needs."],
  },
  {
    id: "complex",
    band: "6.0",
    vi: "Câu phức",
    en: "Complex sentences",
    about: ["Mệnh đề, câu điều kiện, bị động, từ nối: cần cho band 6 trở lên.", "Clauses, conditionals, passives and linking: needed for band 6+."],
  },
  {
    id: "task1",
    band: "6.0",
    vi: "Writing Task 1 & lập luận",
    en: "Task 1 & arguments",
    about: ["So sánh, mô tả xu hướng, số liệu và mệnh đề danh từ.", "Comparisons, trends, figures and noun clauses."],
  },
  {
    id: "advanced",
    band: "7.0",
    vi: "Nâng cao",
    en: "Advanced",
    about: ["Cấu trúc học thuật cho band 7+: dùng đúng và tự nhiên, đừng gượng ép.", "Academic structures for band 7+: accurate and natural, never forced."],
  },
];

export const grammarUnits: GrammarUnit[] = [...foundation, ...complex, ...task1, ...advanced];

/** Đạt từ 80% trở lên thì coi như đã nắm bài. */
export const PASS_RATIO = 0.8;

export function normalizeAnswer(text: string) {
  return text
    .toLowerCase()
    .replace(/[‘’]/g, "'")
    .replace(/\s+/g, " ")
    .trim()
    .replace(/[.!?]+$/, "")
    .trim();
}
