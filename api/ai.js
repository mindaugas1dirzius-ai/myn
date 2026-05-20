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
      systemPrompt = `Tu esi žaidimo "20 klausimų" vedėjas. Tavo užduotis — sugalvoti vieną konkretų lietuvišką žodį pagal nurodytą kategoriją. Žodis turi būti gerai žinomas, nei per lengvas, nei per sunkus atspėti. Atsakyk TIK tuo vienu žodžiu, mažosiomis raidėmis, be jokio papildomo teksto, be taško.`;
      userMessage = `Kategorija: ${category}. Sugalvok žodį.`;
    } else if (action === 'answer') {
      // AI atsako į žaidėjo klausimą — su mąstymu
      systemPrompt = `Tu žaidi žaidimą "20 klausimų". Tu sugalvojai slaptą žodį: "${secretWord}" (kategorija: ${category}). Žaidėjas užduoda klausimus apie šį žodį ir bando jį atspėti.

Tavo užduotis — TEISINGAI ir SĄŽININGAI atsakyti į žaidėjo klausimą apie žodį "${secretWord}".

Pirmiausia trumpai pagalvok: ar teiginys/klausimas tinka žodžiui "${secretWord}"? Tada nuspręsk atsakymą.

Atsakyk JSON formatu (be jokio kito teksto):
{"mintis": "trumpas paaiškinimas kodėl", "atsakymas": "TAIP" arba "NE" arba "GALI BŪTI" arba "ATSPĖJOTE"}

Taisyklės:
- "TAIP" — teiginys teisingas žodžiui "${secretWord}"
- "NE" — teiginys neteisingas
- "GALI BŪTI" — tik jei tikrai priklauso nuo aplinkybių
- "ATSPĖJOTE" — TIK jei žaidėjas tiesiogiai pasakė patį žodį "${secretWord}" arba labai artimą sinonimą

Būk tikslus ir logiškas. Jei žaidėjas klausia "ar tai didesnis už šunį?" — pagalvok apie realų "${secretWord}" dydį ir atsakyk teisingai.`;
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
