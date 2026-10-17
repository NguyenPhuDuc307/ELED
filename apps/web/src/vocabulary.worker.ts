/// <reference lib="webworker" />
self.onmessage = async () => {
  try {
    const response = await fetch("/api/eled/vocabulary", { cache: "no-cache" });
    if (!response.ok) throw new Error("Không tải được dữ liệu từ vựng");
    const rows = await response.json();
    self.postMessage({
      words: rows.map((r: any[]) => ({
        word: r[0],
        translation: r[1],
        pos: r[2],
        ipa: r[3],
        audio: r[4],
        url: r[5],
        levels: r[6],
        topics: r[7],
        senses: r[8]?.map((s: [string, string[]]) => ({ pos: s[0], meanings: s[1] })),
      })),
    });
  } catch (e) {
    self.postMessage({ error: (e as Error).message });
  }
};
