// Kiểu dữ liệu cho các bài ngữ pháp IELTS. Nội dung giải thích bằng tiếng Việt,
// câu ví dụ và bài tập bằng tiếng Anh.

export type GrammarGroup = "foundation" | "complex" | "task1" | "advanced";

export interface GrammarExample {
  /** Câu tiếng Anh. Bọc phần cần chú ý trong **…** để tô đậm. */
  en: string;
  /** Bản dịch tiếng Việt tự nhiên. */
  vi: string;
}

export interface GrammarRule {
  /** Tên quy tắc ngắn, tiếng Việt (có thể kèm thuật ngữ tiếng Anh trong ngoặc). */
  title: string;
  /** Giải thích 1–3 câu tiếng Việt: dùng khi nào, vì sao. */
  body: string;
  /** Công thức, ví dụ "S + have/has + V3". Bỏ trống nếu không có công thức. */
  form?: string;
  examples: GrammarExample[];
}

export interface IeltsTip {
  /** Phần thi áp dụng. */
  part: "Writing Task 1" | "Writing Task 2" | "Speaking" | "Writing" | "Chung";
  /** Mẹo tiếng Việt, cụ thể, gắn với tiêu chí Grammatical Range and Accuracy. */
  tip: string;
  /** Câu mẫu tiếng Anh minh hoạ, văn phong bài thi. */
  example?: string;
}

export interface CommonMistake {
  wrong: string;
  right: string;
  /** Vì sao sai, tiếng Việt, một câu. */
  note: string;
}

export type GrammarExercise =
  | {
      type: "choice";
      /** Câu hỏi. Dùng "___" cho chỗ trống. Có thể là câu dẫn tiếng Việt khi chọn câu đúng. */
      q: string;
      options: string[];
      /** Chỉ số đáp án đúng trong options. */
      answer: number;
      /** Giải thích tiếng Việt vì sao đúng (và vì sao phương án dễ nhầm sai). */
      explain: string;
    }
  | {
      type: "fill";
      /** Câu tiếng Anh có đúng một "___". */
      q: string;
      /** Gợi ý trong ngoặc, thường là động từ gốc: "(go)". */
      hint?: string;
      /** Mọi đáp án chấp nhận được (so khớp không phân biệt hoa thường, bỏ khoảng trắng thừa). */
      answers: string[];
      explain: string;
    };

export interface GrammarUnit {
  /** kebab-case, duy nhất, ổn định (lưu tiến độ theo id này). */
  id: string;
  group: GrammarGroup;
  /** Band IELTS mà chủ điểm này giúp đạt tới. */
  band: "5.0" | "6.0" | "7.0";
  /** Tên tiếng Việt. */
  title: string;
  /** Tên tiếng Anh. */
  en: string;
  /** 1–2 câu tiếng Việt: bài này giải quyết gì, quan trọng thế nào với IELTS. */
  summary: string;
  rules: GrammarRule[];
  ielts: IeltsTip[];
  mistakes: CommonMistake[];
  exercises: GrammarExercise[];
}
