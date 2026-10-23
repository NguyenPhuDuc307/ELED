export const sections = [
  "known",
  "collections",
  "srs",
  "settings",
  "speaking",
  "custom",
  "history",
  "activity",
  "grammar",
] as const;
export type Section = (typeof sections)[number];
export type Profile = Record<Section, Record<string, unknown>>;
export interface Operation {
  section: Section;
  key: string;
  value: unknown;
}
export function emptyProfile(): Profile {
  return Object.fromEntries(sections.map((s) => [s, {}])) as Profile;
}
export function validateOperations(input: unknown): Operation[] {
  if (!Array.isArray(input) || input.length > 500)
    throw new Error("Expected at most 500 changes");
  for (const op of input) {
    if (
      !op ||
      !sections.includes(op.section) ||
      typeof op.key !== "string" ||
      !op.key.length ||
      op.key.length > 512 ||
      ["__proto__"].includes(op.key)
    )
      throw new Error("Invalid change key");
    if (op.value === undefined) throw new Error("Missing value");
    if (op.value === null) continue;
    switch (op.section) {
      case "known":
      case "activity":
        if (typeof op.value !== "boolean") throw new Error("Expected boolean");
        break;
      case "collections":
        if (
          !Array.isArray(op.value) ||
          op.value.length > 50000 ||
          op.value.some((w: unknown) => typeof w !== "string" || w.length > 512)
        )
          throw new Error("Invalid collection");
        break;
      case "srs":
        if (
          typeof op.value !== "object" ||
          typeof op.value.w !== "string" ||
          !["fresh", "learning", "reviewing", "mastered"].includes(
            op.value.s,
          ) ||
          ["e", "i", "r", "d", "l", "t", "p"].some(
            (k) =>
              typeof op.value[k] !== "number" ||
              !Number.isFinite(op.value[k]) ||
              op.value[k] < 0,
          )
        )
          throw new Error("Invalid progress");
        break;
      case "grammar":
        if (
          typeof op.value !== "object" ||
          ["b", "n", "t"].some(
            (k) =>
              typeof (op.value as any)[k] !== "number" ||
              !Number.isFinite((op.value as any)[k]) ||
              (op.value as any)[k] < 0,
          )
        )
          throw new Error("Invalid grammar score");
        break;
      case "history":
        if (typeof op.value !== "number" || !Number.isFinite(op.value))
          throw new Error("Invalid history");
        break;
      case "custom":
        if (typeof op.value !== "string" || op.value.length > 10000)
          throw new Error("Invalid custom word");
        break;
      case "speaking":
        if (
          typeof op.value !== "object" ||
          typeof op.value.topic !== "string" ||
          !Array.isArray(op.value.items) ||
          op.value.items.length > 1000 ||
          op.value.items.some(
            (i: unknown) =>
              !i ||
              typeof i !== "object" ||
              typeof (i as any).q !== "string" ||
              typeof (i as any).a !== "string",
          )
        )
          throw new Error("Invalid speaking set");
        break;
      case "settings":
        if (
          ![
            "levels",
            "topics",
            "theme",
            "language",
            "accent",
            "voice",
            "onboarded",
            "firebaseImported",
            "flutterImported",
            "focusTopic",
          ].includes(op.key)
        )
          throw new Error("Invalid setting");
        if (
          ["levels", "topics"].includes(op.key) &&
          (!Array.isArray(op.value) ||
            op.value.some((v: unknown) => typeof v !== "string"))
        )
          throw new Error("Invalid filter");
        if (
          op.key === "theme" &&
          !["system", "light", "dark"].includes(op.value)
        )
          throw new Error("Invalid theme");
        if (op.key === "language" && !["vi", "en"].includes(op.value))
          throw new Error("Invalid language");
        if (op.key === "focusTopic" && (typeof op.value !== "string" || op.value.length > 512))
          throw new Error("Invalid topic");
        break;
    }
    if (JSON.stringify(op.value).length > 2000000)
      throw new Error("Change too large");
  }
  return input;
}
export function applyOperations(
  profile: Profile,
  operations: Operation[],
): Profile {
  const next = structuredClone(profile);
  for (const op of operations) {
    if (op.value === null) delete next[op.section][op.key];
    else next[op.section][op.key] = op.value;
  }
  return next;
}
