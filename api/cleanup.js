import { createClient } from '@supabase/supabase-js';

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).end();

  const { roomId, playerId } = req.body || {};
  if (!roomId || !playerId) return res.status(400).json({ error: 'Missing params' });

  const sb = createClient(
    process.env.REACT_APP_SUPABASE_URL,
    process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.REACT_APP_SUPABASE_ANON_KEY
  );

  const { data: player } = await sb.from('players').select('id').eq('id', playerId).eq('room_id', roomId).single();
  if (!player) return res.status(403).json({ error: 'Player not found in room' });

  await sb.from('players').delete().eq('id', playerId).eq('room_id', roomId);

  const { data: remaining } = await sb.from('players').select('id').eq('room_id', roomId);
  if (!remaining || remaining.length === 0) {
    await sb.from('rooms').delete().eq('id', roomId);
  }

  return res.status(200).json({ ok: true });
}
