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
    const { action, category, secretWord, question, history } = req.body;

    let systemPrompt = '';
    let userMessage = '';

    if (action === 'pickWord') {
      // AI sugalvoja žodį pagal kategoriją
      systemPrompt = `Tu esi žaidimo "20 klausimų" vedėjas. Tavo užduotis — sugalvoti vieną konkretų lietuvišką žodį pagal nurodytą kategoriją. Žodis turi būti gerai žinomas, nei per lengvas, nei per sunkus atspėti. Atsakyk TIK tuo vienu žodžiu, mažosiomis raidėmis, be jokio papildomo teksto, be taško.`;
      userMessage = `Kategorija: ${category}. Sugalvok žodį.`;
    } else if (action === 'answer') {
      // AI atsako į žaidėjo klausimą
      systemPrompt = `Tu žaidi "20 klausimų". Tu sugalvojai slaptą žodį: "${secretWord}" (kategorija: ${category}). Žaidėjas užduoda klausimus ir bando atspėti žodį.

Tavo užduotis — atsakyti į žaidėjo klausimą TIK vienu iš šių variantų:
- "TAIP" — jei atsakymas teigiamas
- "NE" — jei atsakymas neigiamas
- "GALI BŪTI" — jei priklauso nuo aplinkybių arba iš dalies
- "ATSPĖJOTE" — jei žaidėjas teisingai įvardijo slaptą žodį "${secretWord}"

Atsakyk TIK vienu iš šių keturių variantų, be jokio papildomo teksto. Būk sąžiningas ir tikslus.`;
      userMessage = `Klausimas: ${question}`;
    }

    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01'
      },
      body: JSON.stringify({
        model: 'claude-sonnet-4-20250514',
        max_tokens: 100,
        system: systemPrompt,
        messages: [{ role: 'user', content: userMessage }]
      })
    });

    if (!response.ok) {
      const errText = await response.text();
      return res.status(500).json({ error: 'Claude API klaida: ' + errText });
    }

    const data = await response.json();
    const text = data.content?.map(c => c.text || '').join('').trim();

    return res.status(200).json({ result: text });
  } catch (err) {
    return res.status(500).json({ error: String(err) });
  }
}
