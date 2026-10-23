import type { GrammarReview, GrammarScore } from "../model";
import type { GrammarExercise, GrammarUnit } from "./types";

const DAY = 86400000;
/** Khoảng ôn sau mỗi lần đúng liên tiếp; đúng đủ số lần này thì câu ra khỏi danh sách ôn. */
export const REVIEW_STEPS = [1, 3, 7];
export const PASS_RATIO = 0.8;

export interface PracticeItem {
  unit: GrammarUnit;
  index: number;
  exercise: GrammarExercise;
}
export const itemKey = (unitId: string, index: number) => `${unitId}:${index}`;

/**
 * Lịch ôn câu sai kiểu Leitner: sai thì ôn lại sau 1 ngày và đếm lại từ đầu; đúng thì
 * giãn dần 3 → 7 ngày; đúng đủ 3 lần liên tiếp thì bỏ khỏi danh sách (trả về null).
 * Câu chưa từng sai mà làm đúng thì không cần ghi gì (undefined).
 */
export function nextReview(state: GrammarReview | undefined, correct: boolean, now = Date.now()): GrammarReview | null | undefined {
  if (!correct) return { d: now + REVIEW_STEPS[0] * DAY, s: 0 };
  if (!state) return undefined;
  const s = state.s + 1;
  return s >= REVIEW_STEPS.length ? null : { d: now + REVIEW_STEPS[s] * DAY, s };
}

export function reviewItems(units: GrammarUnit[], review: Record<string, GrammarReview>, now = Date.now(), dueOnly = true): PracticeItem[] {
  const byId = new Map(units.map((u) => [u.id, u]));
  return Object.entries(review)
    .filter(([, r]) => !dueOnly || r.d <= now)
    .sort((a, b) => a[1].d - b[1].d)
    .flatMap(([key]) => {
      const at = key.lastIndexOf(":");
      const unit = byId.get(key.slice(0, at));
      const index = Number(key.slice(at + 1));
      const exercise = unit?.exercises[index];
      return unit && exercise ? [{ unit, index, exercise }] : [];
    });
}

/** Bài kiểm tra xếp lộ trình: câu trắc nghiệm đầu tiên của mỗi bài. */
export function placementItems(units: GrammarUnit[]): PracticeItem[] {
  return units.flatMap((unit) => {
    const index = unit.exercises.findIndex((e) => e.type === "choice");
    return index < 0 ? [] : [{ unit, index, exercise: unit.exercises[index] }];
  });
}
export const placementKey = (unitId: string) => `test:${unitId}`;

export function unitScore(scores: Record<string, GrammarScore>, unitId: string) {
  const s = scores[unitId];
  return s ? { ...s, passed: s.b / s.n >= PASS_RATIO } : undefined;
}
/** "Chưa nắm" theo bài kiểm tra: làm sai câu của bài đó và chưa luyện đạt. */
export function needsStudy(scores: Record<string, GrammarScore>, unitId: string) {
  const test = scores[placementKey(unitId)];
  return !!test && test.b < test.n && !unitScore(scores, unitId)?.passed;
}
/** Bài nên học tiếp: ưu tiên bài kiểm tra cho thấy chưa nắm, rồi đến bài chưa đạt theo thứ tự. */
export function recommendedUnit(units: GrammarUnit[], scores: Record<string, GrammarScore>) {
  return units.find((u) => needsStudy(scores, u.id)) ?? units.find((u) => !unitScore(scores, u.id)?.passed);
}

/** Đề tổng hợp: lấy ngẫu nhiên từ các bài đã luyện (hoặc mọi bài nếu chưa luyện bài nào). */
export function mixedItems(units: GrammarUnit[], scores: Record<string, GrammarScore>, count = 10, random = Math.random): PracticeItem[] {
  const studied = units.filter((u) => scores[u.id]);
  const pool = (studied.length ? studied : units).flatMap((unit) => unit.exercises.map((exercise, index) => ({ unit, index, exercise })));
  return shuffled(pool, random).slice(0, count);
}

export function shuffled<T>(list: T[], random = Math.random): T[] {
  const out = [...list];
  for (let i = out.length - 1; i > 0; i--) {
    const j = Math.floor(random() * (i + 1));
    [out[i], out[j]] = [out[j], out[i]];
  }
  return out;
}
