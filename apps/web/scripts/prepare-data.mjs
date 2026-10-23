import { readdir, readFile, writeFile, mkdir } from "node:fs/promises";
import { resolve, join } from "node:path";
const root = resolve(import.meta.dirname, "../../..");
async function files(path) {
  const out = [];
  for (const e of await readdir(path, { withFileTypes: true })) {
    if (e.isDirectory()) out.push(...(await files(join(path, e.name))));
    else if (e.name.endsWith(".csv")) out.push(join(path, e.name));
  }
  return out.sort();
}
function fields(line) {
  const out = [];
  let value = "",
    quoted = false;
  for (let i = 0; i < line.length; i++) {
    const c = line[i];
    if (c === '"') {
      if (quoted && line[i + 1] === '"') {
        value += '"';
        i++;
      } else quoted = !quoted;
    } else if (c === "," && !quoted) {
      out.push(value.trim());
      value = "";
    } else value += c;
  }
  out.push(value.trim());
  return out;
}
const vocabulary = new Map();
const meanings = JSON.parse(await readFile(join(root, "assets/lexicon/meanings.json"), "utf8"));
// Editorial meanings must win even when the raw dictionary is regenerated.
const reviewed = JSON.parse(await readFile(join(root, "assets/lexicon/reviewed.json"), "utf8"));
for (const [word, groups] of Object.entries(reviewed)) {
  meanings[word] = { ...(meanings[word] || {}), ...groups };
}
const fallbackMeanings = new Map();
const normalizePos = (pos) => ["indefinite article", "definite article"].includes(pos) ? "determiner" : pos === "ordinal number" ? "number" : pos;
for (const file of await files(join(root, "assets/data"))) {
  const relative = file.slice(join(root, "assets/data").length + 1);
  const parts = relative.split("/");
  const topic =
    parts[0] === "topic"
      ? parts
          .slice(1)
          .join(" - ")
          .replace(/\.csv$/, "")
      : "";
  for (const line of (await readFile(file, "utf8")).split("\n").slice(1)) {
    if (!line.trim()) continue;
    const r = fields(line);
    if (r.length < 7 || !r[3]) continue;
    const key = r[3].toLowerCase();
    if (!fallbackMeanings.has(key)) fallbackMeanings.set(key, new Map());
    for (const pos of r[5].split(/[;,]/).map(p => normalizePos(p.trim())).filter(Boolean)) {
      if (!fallbackMeanings.get(key).has(pos)) fallbackMeanings.get(key).set(pos, r[4]);
    }
    const existing = vocabulary.get(key);
    const levels = [...new Set(r[2].match(/[ABC][12]/g) || [])];
    if (existing) {
      existing[6] = [...new Set([...existing[6], ...levels])];
      if (topic && !existing[7].includes(topic)) existing[7].push(topic);
      for (const i of [1, 2])
        if (
          r[i === 1 ? 4 : 5] &&
          !existing[i].toLowerCase().includes(r[i === 1 ? 4 : 5].toLowerCase())
        )
          existing[i] += "; " + r[i === 1 ? 4 : 5];
      if (!existing[4]) existing[4] = r[7] || "";
    } else
      vocabulary.set(key, [
        r[3],
        r[4],
        r[5],
        r[6],
        r[7] || "",
        r[1],
        levels,
        topic ? [topic] : [],
      ]);
  }
}
const dir = resolve(import.meta.dirname, "../public");
const shortPos = { noun: "n.", adjective: "adj.", verb: "v.", adverb: "adv.", preposition: "prep.", pronoun: "pron.", determiner: "det.", conjunction: "conj.", exclamation: "interj.", "modal verb": "modal v.", "phrasal verb": "phr. v." };
for (const [key, row] of vocabulary) {
  const matched = meanings[key];
  if (!matched) continue;
  const groups = [...fallbackMeanings.get(key)].map(([pos, old]) => [pos, matched[pos] || [old]]);
  row[8] = groups;
  row[1] = groups.map(([pos, glosses]) => (groups.length > 1 ? (shortPos[pos] || pos) + " " : "") + glosses[0]).join(" · ");
}
await mkdir(dir, { recursive: true });
await writeFile(
  join(dir, "vocabulary.json"),
  JSON.stringify([...vocabulary.values()]),
);
await writeFile(join(dir, "meanings-source.json"), JSON.stringify({ source: "Vietnamese Wiktionary via Kaikki/Wiktextract", license: "CC BY-SA 4.0", modified: true, meanings }));
console.log(`Prepared ${vocabulary.size} unique words`);
