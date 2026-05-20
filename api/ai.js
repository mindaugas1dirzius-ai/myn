// Vercel serverless function — kalbasi su Claude API
// Saugiai naudoja ANTHROPIC_API_KEY iš Environment Variables

export default async function handler(req, res) {
  // CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  const apiKey = process.env.ANTHROPIC_API_KEY;
  if (!apiKey) return res.status(500).json({ error: 'API raktas nesukonfigūruotas' });

  try {
    // Saugus body parsinimas (Vercel kartais negrąžina req.body)
    let body = req.body;
    if (typeof body === 'string') {
      try { body = JSON.parse(body); } catch (e) { body = {}; }
    }
    if (!body || typeof body !== 'object') body = {};
    const { action, category, secretWord, question } = body;

    let systemPrompt = '';
    let userMessage = '';

    if (action === 'pickWord') {
      // AI sugalvoja žodį pagal kategoriją
      const examples = {
        'Daiktas': 'pvz: stalas, telefonas, knyga, šaukštas, dviratis, laikrodis, kėdė, puodelis',
        'Gyvūnas': 'pvz: katė, dramblys, pingvinas, voras, arklys, delfinas, lapė, pelėda',
        'Veikėjas': 'pvz: gydytojas, mokytojas, ugniagesys, policininkas, virėjas, pilotas',
        'Vieta': 'pvz: mokykla, paplūdimys, ligoninė, biblioteka, parkas, oro uostas',
        'Veiksmas': 'pvz: bėgti, miegoti, plaukti, valgyti, šokti, dainuoti, skaityti'
      };
      systemPrompt = `Tu esi žaidimo "20 klausimų" vedėjas. Sugalvok VIENĄ paprastą, kasdienį, visiems gerai žinomą lietuvišką žodį pagal kategoriją.

SVARBU:
- Žodis turi būti TIKRAS, egzistuojantis lietuvių kalbos žodis
- Paprastas ir kasdienis — toks, kurį žino kiekvienas vaikas
- Vardininko linksniu (pvz. "stalas", NE "stalo")
- Vienaskaita
- Mažosiomis raidėmis

Atsakyk TIK tuo vienu žodžiu, be jokio papildomo teksto, be taško, be kabučių.`;
      userMessage = `Kategorija: ${category}. ${examples[category] || ''}. Sugalvok vieną tokį žodį.`;
    } else if (action === 'answer') {
      // AI atsako į žaidėjo klausimą — su mąstymu ir istorija
      const history = Array.isArray(body.history) ? body.history : [];
      let historyText = '';
      if (history.length > 0) {
        historyText = '\n\nANKSTESNI KLAUSIMAI IR TAVO ATSAKYMAI (privalai būti nuoseklus su jais):\n' +
          history.map((h, i) => `${i + 1}. "${h.question}" → ${h.answer}`).join('\n');
      }
      systemPrompt = `Tu žaidi žaidimą "20 klausimų". Tu sugalvojai slaptą žodį: "${secretWord}" (kategorija: ${category}). Žaidėjas užduoda klausimus apie šį žodį ir bando jį atspėti.

Tavo užduotis — TEISINGAI, SĄŽININGAI ir NUOSEKLIAI atsakyti į žaidėjo klausimą apie žodį "${secretWord}".

Pirmiausia pagalvok: ar teiginys/klausimas tinka žodžiui "${secretWord}"? Patikrink ankstesnius savo atsakymus, kad neprieštarautum sau. Tada nuspręsk atsakymą.${historyText}

Atsakyk JSON formatu (be jokio kito teksto):
{"mintis": "trumpas paaiškinimas kodėl", "atsakymas": "TAIP" arba "NE" arba "GALI BŪTI" arba "ATSPĖJOTE"}

Taisyklės:
- "TAIP" — teiginys teisingas žodžiui "${secretWord}"
- "NE" — teiginys neteisingas
- "GALI BŪTI" — tik jei tikrai priklauso nuo aplinkybių
- "ATSPĖJOTE" — TIK jei žaidėjas tiesiogiai pasakė patį žodį "${secretWord}" arba labai artimą sinonimą

SVARBU: Būk NUOSEKLUS. Jei anksčiau pasakei kad žodis "lengvas", tai negali vėliau sakyti kad "sunkus". Jei klausia tą patį du kartus — atsakyk vienodai. Būk logiškas: jei žodis "${secretWord}" yra mažas ir lengvas daiktas, tai jį galima pakelti.`;
      userMessage = `Žaidėjo klausimas/spėjimas: ${question}`;
    }

    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01'
      },
      body: JSON.stringify({
        model: 'claude-haiku-4-5',
        max_tokens: 300,
        system: systemPrompt,
        messages: [{ role: 'user', content: userMessage }]
      })
    });

    if (!response.ok) {
      const errText = await response.text();
      return res.status(500).json({ error: 'Claude API klaida: ' + errText });
    }

    const data = await response.json();
    let text = data.content?.map(c => c.text || '').join('').trim();

    // Jei atsakymas JSON formatu — ištraukiam tik "atsakymas"
    if (action === 'answer' && text) {
      try {
        const jsonMatch = text.match(/\{[\s\S]*\}/);
        if (jsonMatch) {
          const parsed = JSON.parse(jsonMatch[0]);
          if (parsed.atsakymas) text = parsed.atsakymas;
        }
      } catch (e) { /* paliekam tekstą kaip yra */ }
    }

    return res.status(200).json({ result: text });
  } catch (err) {
    return res.status(500).json({ error: String(err) });
  }
}
