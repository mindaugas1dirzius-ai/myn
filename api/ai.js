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
    const { action, category, secretWord, question, difficulty } = body;

    let systemPrompt = '';
    let userMessage = '';

    if (action === 'pickWord') {
      // AI sugalvoja žodį pagal kategoriją ir sunkumą
      const examplesEasy = {
        'Daiktas': 'stalas, knyga, kėdė, kamuolys, batai, kepurė, šaukštas, puodelis',
        'Gyvūnas': 'katė, šuo, arklys, kiškis, meška, žuvis, varlė, bitė',
        'Veikėjas': 'gydytojas, mokytojas, virėjas, policininkas, ugniagesys',
        'Vieta': 'mokykla, parkas, parduotuvė, miškas, jūra, namas',
        'Veiksmas': 'bėgti, miegoti, valgyti, šokti, plaukti, juoktis'
      };
      const examplesHard = {
        'Daiktas': 'mikroskopas, kompasas, teleskopas, termometras, parašiutas, akordeonas',
        'Gyvūnas': 'kengūra, pingvinas, krokodilas, povas, ežiukas, šikšnosparnis, koala',
        'Veikėjas': 'archeologas, dirigentas, vulkanologas, žurnalistas, architektas',
        'Vieta': 'observatorija, vulkanas, oranžerija, švyturys, katedra, uostas',
        'Veiksmas': 'šnabždėti, vairuoti, slidinėti, fotografuoti, dirigentauti, žongliruoti'
      };
      const isHard = difficulty === 'sunku';
      const examples = isHard ? examplesHard : examplesEasy;

      // Atsitiktinis "sėklos" skaičius kad AI rinktųsi skirtingai
      const seed = Math.floor(Math.random() * 1000);

      if (isHard) {
        systemPrompt = `Tu esi žaidimo "20 klausimų" vedėjas. Sugalvok VIENĄ sudėtingesnį, bet visiems žinomą lietuvišką žodį.

SVARBU:
- Žodis turi būti TIKRAS, egzistuojantis lietuvių kalbos žodis
- Sudėtingesnis, bet vis tiek visiems suprantamas (ne specialistų terminas)
- Toks, kurį žino daugumas suaugusiųjų ir paauglių
- GRIEŽTAI DRAUDŽIAMA kartoti šiuos žodžius: ${examples[category] || ''}
- Rink KAŽ KĄ NAUJĄ ir netikėtą — ne tipinį atsakymą
- Vardininko linksniu, vienaskaita, mažosiomis raidėmis
- Atsitiktinis skaičius (ignoruok): ${seed}

Atsakyk TIK tuo vienu žodžiu, be jokio papildomo teksto.`;
      } else {
        systemPrompt = `Tu esi žaidimo "20 klausimų" vedėjas. Sugalvok VIENĄ paprastą, visiems žinomą lietuvišką žodį.

GRIEŽTAI SVARBU:
- Žodis turi būti TIKRAS, dažnai vartojamas lietuvių kalbos žodis
- PAPRASTAS — toks, kurį žino kiekvienas
- GRIEŽTAI DRAUDŽIAMA rinktis šiuos žodžius: ${examples[category] || ''}
- Rink KAŽ KĄ KITA — netikėtą, įdomų, bet vis tiek paprastą
- Vardininko linksniu, vienaskaita, mažosiomis raidėmis
- Atsitiktinis skaičius (ignoruok): ${seed}

Atsakyk TIK tuo vienu žodžiu, be jokio papildomo teksto.`;
      }
      userMessage = `Kategorija: ${category}. Sugalvok vieną žodį iš šios kategorijos. NEGALIMA rinktis: ${examples[category] || ''}. Rink ką nors visiškai kitą ir netikėtą!`;
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
        model: 'claude-sonnet-4-6',
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
