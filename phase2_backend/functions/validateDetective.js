/**
 * validateDetective — 🕵️ Detektyvo bylų struktūros tikrintojas (plano §4.4).
 * Paleidimas: node validateDetective.js
 * Tikrina (kiekvienai bylai, kiekvienai kalbai):
 *  - "both" atsakymas privalo turėti note;
 *  - v2 bylos (≥30 kl.): lygiai po 10 kiekvieno lygio; senos: po 4;
 *  - board: lygiai 30, emoji kiekis sutampa, žodis lentoje LYGIAI 1 kartą;
 *  - klausimo tekste nėra paties žodžio (atsakymo nutekėjimas);
 *  - LT tekstuose nėra U+201C kabučių (TS spąstai) — tik „..." (U+201E/201D).
 */
const fs = require("fs");
const src = fs.readFileSync("src/detectiveContent.ts", "utf8");

// Grubus TS→JSON: išimam tik DETECTIVE_CASES masyvo literalą per eval sandbox.
const m = src.match(/DETECTIVE_CASES[^=]*=\s*(\[[\s\S]*?\n\]);/);
if (!m) { console.error("Nerastas DETECTIVE_CASES"); process.exit(1); }
// eslint-disable-next-line no-eval
const cases = eval(m[1]);

let errors = 0;
const err = (msg) => { console.error("❌ " + msg); errors++; };

for (const c of cases) {
  for (const [lang, t] of Object.entries(c.texts)) {
    const tag = `${c.id}/${lang}`;
    const qs = t.questions || [];
    const word = (t.word || "").toLowerCase();

    // Lygiai
    const n1 = qs.filter((q) => q.t === 1).length;
    const n2 = qs.filter((q) => q.t === 2).length;
    const n3 = qs.filter((q) => q.t === 3).length;
    const per = qs.length >= 30 ? 10 : 4;
    if (n1 !== per || n2 !== per || n3 !== per) {
      err(`${tag}: lygiai ${n1}/${n2}/${n3}, tikėtasi po ${per}`);
    }

    for (const q of qs) {
      if (q.a === "both" && (!q.note || !q.note.trim())) {
        err(`${tag}: "both" be note — „${q.q}"`);
      }
      if (q.q.toLowerCase().includes(word)) {
        err(`${tag}: žodis klausime — „${q.q}"`);
      }
      if (lang === "lt" && /[“]/.test(q.q + (q.note || ""))) {
        err(`${tag}: U+201C kabutė — „${q.q}"`);
      }
    }

    if (t.board) {
      if (t.board.length !== 30) err(`${tag}: board ${t.board.length} ≠ 30`);
      if (!t.boardEmoji || t.boardEmoji.length !== t.board.length) {
        err(`${tag}: boardEmoji kiekis nesutampa`);
      }
      const hits = t.board.filter(
        (w) => w.toLowerCase() === word
      ).length;
      if (hits !== 1) err(`${tag}: žodis lentoje ${hits} kartų (turi 1)`);
      const uniq = new Set(t.board.map((w) => w.toLowerCase()));
      if (uniq.size !== t.board.length) err(`${tag}: lentoje dublikatų`);
    }
    if (t.sos && lang === "lt" && /[“]/.test(t.sos)) {
      err(`${tag}: U+201C SOS tekste`);
    }
  }
}

console.log(errors === 0
  ? `✅ VISOS ${cases.length} BYLOS TVARKINGOS`
  : `❌ KLAIDŲ: ${errors}`);
process.exit(errors === 0 ? 0 : 1);
