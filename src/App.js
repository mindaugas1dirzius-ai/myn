import React, { useState, useEffect, useRef, useCallback } from 'react';
import { supabase, generateRoomCode, generatePlayerId } from './lib/supabase';
import './App.css';

const ANSWERS = [
  { key: 'taip', label: 'TAIP', icon: '✓', color: '#22c55e' },
  { key: 'ne', label: 'NE', icon: '✗', color: '#ef4444' },
  { key: 'gali_buti', label: 'GALI BŪTI', icon: '~', color: '#f59e0b' },
  { key: 'yra', label: 'YRA', icon: '!', color: '#6366f1' },
];

const CATEGORIES = ['Daiktas', 'Gyvūnas', 'Veikėjas', 'Vieta', 'Veiksmas'];

// Sukuria gražų gradiento paveikslą su žodžio inicialu (veikia visada, be interneto)
const wordImage = (word, category) => {
  const w = (word || '?').trim();
  const initial = w[0] ? w[0].toUpperCase() : '?';
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="400" height="300">
    <defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#00b4ff"/><stop offset="0.5" stop-color="#7b2fff"/>
      <stop offset="1" stop-color="#d400ff"/></linearGradient></defs>
    <rect width="400" height="300" fill="#0a0a1a"/>
    <circle cx="200" cy="130" r="80" fill="url(#g)" opacity="0.25"/>
    <text x="200" y="160" font-family="Arial" font-size="90" font-weight="900"
      fill="url(#g)" text-anchor="middle">${initial}</text>
    <text x="200" y="240" font-family="Arial" font-size="28" font-weight="700"
      fill="#f0f4ff" text-anchor="middle">${w}</text>
  </svg>`;
  return 'data:image/svg+xml;base64,' + btoa(unescape(encodeURIComponent(svg)));
};

export default function App() {
  const [screen, setScreen] = useState('home'); // home, create, join, lobby, game, guessed
  const [playerName, setPlayerName] = useState(() => localStorage.getItem('playerName') || '');
  const [playerId, setPlayerId] = useState(() => {
    let id = localStorage.getItem('playerId');
    if (!id) { id = generatePlayerId(); localStorage.setItem('playerId', id); }
    return id;
  });
  const [roomCode, setRoomCode] = useState('');
  const [room, setRoom] = useState(null);
  const [players, setPlayers] = useState([]);
  const [questions, setQuestions] = useState([]);
  const [myQuestion, setMyQuestion] = useState('');
  const [secretWord, setSecretWord] = useState('');
  const [secretCategory, setSecretCategory] = useState('Daiktas');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [voiceActive, setVoiceActive] = useState(false);
  const [pendingQuestion, setPendingQuestion] = useState(null);

  // AI game state
  const [aiCategory, setAiCategory] = useState('Daiktas');
  const [aiDifficulty, setAiDifficulty] = useState('lengva');
  const [aiSecretWord, setAiSecretWord] = useState('');
  const [aiQuestions, setAiQuestions] = useState([]); // {question, answer}
  const [aiInput, setAiInput] = useState('');
  const [aiThinking, setAiThinking] = useState(false);
  const [aiWon, setAiWon] = useState(false);
  const [aiSurrendered, setAiSurrendered] = useState(false);

  const subscriptionsRef = useRef([]);
  const questionsEndRef = useRef(null);
  const peerConnectionsRef = useRef({});
  const localStreamRef = useRef(null);
  const signalingChannelRef = useRef(null);

  const isHost = room?.host_id === playerId;

  useEffect(() => {
    // Scroll only inside the questions list, not the whole page (better on mobile)
    const el = questionsEndRef.current;
    if (el && el.parentElement) {
      el.parentElement.scrollTop = el.parentElement.scrollHeight;
    }
  }, [questions]);

  // ── Polling fallback: refresh data every 2s while in a room ──────────────
  // This ensures sync works even if Supabase realtime is unreliable.
  useEffect(() => {
    if (!roomCode || (screen !== 'lobby' && screen !== 'game')) return;
    const poll = async () => {
      const { data: r } = await supabase.from('rooms').select('*').eq('id', roomCode).single();
      if (r) setRoom(r);
      const { data: pData } = await supabase.from('players').select('*').eq('room_id', roomCode).order('joined_at');
      if (pData) setPlayers(pData);
      const { data: qData } = await supabase.from('questions').select('*').eq('room_id', roomCode).order('created_at');
      if (qData) {
        setQuestions(qData);
        const unanswered = qData.find(q => !q.answer);
        setPendingQuestion(unanswered || null);
      }
    };
    const interval = setInterval(poll, 2000);
    return () => clearInterval(interval);
  }, [roomCode, screen]);

  const cleanup = useCallback(() => {
    subscriptionsRef.current.forEach(s => supabase.removeChannel(s));
    subscriptionsRef.current = [];
    localStreamRef.current?.getTracks().forEach(t => t.stop());
    Object.values(peerConnectionsRef.current).forEach(pc => pc.close());
    peerConnectionsRef.current = {};
  }, []);

  useEffect(() => () => cleanup(), [cleanup]);

  // ── Voice chat helpers ───────────────────────────────────────────────────
  const startVoice = async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      localStreamRef.current = stream;
      setVoiceActive(true);
      // Broadcast offer to others via Supabase broadcast
      const channel = supabase.channel(`voice:${room.id}`, {
        config: { broadcast: { self: false } }
      });
      signalingChannelRef.current = channel;

      channel.on('broadcast', { event: 'signal' }, async ({ payload }) => {
        if (payload.to !== playerId) return;
        const { from, type, data } = payload;

        if (type === 'offer') {
          const pc = createPC(from, stream);
          await pc.setRemoteDescription(data);
          const answer = await pc.createAnswer();
          await pc.setLocalDescription(answer);
          channel.send({ type: 'broadcast', event: 'signal', payload: { from: playerId, to: from, type: 'answer', data: answer } });
        } else if (type === 'answer') {
          await peerConnectionsRef.current[from]?.setRemoteDescription(data);
        } else if (type === 'ice') {
          await peerConnectionsRef.current[from]?.addIceCandidate(data);
        }
      });

      await channel.subscribe();

      // Send offer to each existing player
      players.filter(p => p.id !== playerId).forEach(async p => {
        const pc = createPC(p.id, stream);
        const offer = await pc.createOffer();
        await pc.setLocalDescription(offer);
        channel.send({ type: 'broadcast', event: 'signal', payload: { from: playerId, to: p.id, type: 'offer', data: offer } });
      });
    } catch (e) {
      setError('Nepavyko įjungti mikrofono: ' + e.message);
    }
  };

  const createPC = (remoteId, stream) => {
    const pc = new RTCPeerConnection({ iceServers: [{ urls: 'stun:stun.l.google.com:19302' }] });
    stream.getTracks().forEach(t => pc.addTrack(t, stream));
    pc.onicecandidate = e => {
      if (e.candidate) signalingChannelRef.current?.send({
        type: 'broadcast', event: 'signal',
        payload: { from: playerId, to: remoteId, type: 'ice', data: e.candidate }
      });
    };
    pc.ontrack = e => {
      const audio = new Audio();
      audio.srcObject = e.streams[0];
      audio.play().catch(() => {});
    };
    peerConnectionsRef.current[remoteId] = pc;
    return pc;
  };

  const stopVoice = () => {
    localStreamRef.current?.getTracks().forEach(t => t.stop());
    localStreamRef.current = null;
    signalingChannelRef.current && supabase.removeChannel(signalingChannelRef.current);
    Object.values(peerConnectionsRef.current).forEach(pc => pc.close());
    peerConnectionsRef.current = {};
    setVoiceActive(false);
  };

  // ── Subscribe to room data ───────────────────────────────────────────────
  const subscribeToRoom = useCallback((rId) => {
    const roomSub = supabase.channel(`room:${rId}`)
      .on('postgres_changes', { event: '*', schema: 'public', table: 'rooms', filter: `id=eq.${rId}` },
        ({ new: r }) => { if (r) setRoom(r); })
      .on('postgres_changes', { event: '*', schema: 'public', table: 'players', filter: `room_id=eq.${rId}` },
        async () => {
          const { data } = await supabase.from('players').select('*').eq('room_id', rId).order('joined_at');
          if (data) setPlayers(data);
        })
      .on('postgres_changes', { event: '*', schema: 'public', table: 'questions', filter: `room_id=eq.${rId}` },
        async () => {
          const { data } = await supabase.from('questions').select('*').eq('room_id', rId).order('created_at');
          if (data) {
            setQuestions(data);
            const unanswered = data.find(q => !q.answer);
            setPendingQuestion(unanswered || null);
          }
        })
      .subscribe();

    subscriptionsRef.current.push(roomSub);
  }, []);

  // ── Actions ──────────────────────────────────────────────────────────────
  const saveName = () => {
    if (!playerName.trim()) return;
    localStorage.setItem('playerName', playerName.trim());
  };

  const createRoom = async () => {
    if (!playerName.trim() || !secretWord.trim()) { setError('Užpildyk visus laukus!'); return; }
    setLoading(true); setError('');
    saveName();
    // Always generate fresh playerId for a new game (avoids duplicate key error)
    const freshId = generatePlayerId();
    localStorage.setItem('playerId', freshId);
    setPlayerId(freshId);
    const code = generateRoomCode();
    const { error: e1 } = await supabase.from('rooms').insert({
      id: code, secret_word: secretWord.trim(), secret_category: secretCategory,
      host_id: freshId, status: 'waiting'
    });
    if (e1) { setError(e1.message); setLoading(false); return; }
    const { error: e2 } = await supabase.from('players').insert({
      id: freshId, room_id: code, name: playerName.trim(), is_host: true
    });
    if (e2) { setError(e2.message); setLoading(false); return; }
    const { data: r } = await supabase.from('rooms').select('*').eq('id', code).single();
    setRoom(r); setRoomCode(code);
    // Fetch initial data
    const { data: pData } = await supabase.from('players').select('*').eq('room_id', code).order('joined_at');
    if (pData) setPlayers(pData);
    subscribeToRoom(code);
    setLoading(false); setScreen('lobby');
  };

  const joinRoom = async () => {
    if (!playerName.trim() || !roomCode.trim()) { setError('Užpildyk visus laukus!'); return; }
    setLoading(true); setError('');
    saveName();
    const code = roomCode.toUpperCase().trim();
    const { data: r } = await supabase.from('rooms').select('*').eq('id', code).single();
    if (!r) { setError('Kambarys nerastas!'); setLoading(false); return; }
    if (r.status === 'finished') { setError('Žaidimas jau baigtas!'); setLoading(false); return; }
    // Always generate fresh playerId for joining (avoids duplicate key error)
    const freshId = generatePlayerId();
    localStorage.setItem('playerId', freshId);
    setPlayerId(freshId);
    await supabase.from('players').insert({ id: freshId, room_id: code, name: playerName.trim(), is_host: false });
    setRoom(r); setRoomCode(code);
    // Fetch initial data
    const { data: pData } = await supabase.from('players').select('*').eq('room_id', code).order('joined_at');
    if (pData) setPlayers(pData);
    const { data: qData } = await supabase.from('questions').select('*').eq('room_id', code).order('created_at');
    if (qData) {
      setQuestions(qData);
      const unanswered = qData.find(q => !q.answer);
      setPendingQuestion(unanswered || null);
    }
    subscribeToRoom(code);
    setLoading(false);
    setScreen(r.status === 'waiting' ? 'lobby' : 'game');
  };

  const startGame = async () => {
    const otherPlayers = players.filter(p => p.id !== playerId);
    if (otherPlayers.length === 0) { setError('Reikia bent vieno žaidėjo!'); return; }
    const firstQuestioner = otherPlayers[0].id;
    await supabase.from('rooms').update({ status: 'playing', current_questioner: firstQuestioner }).eq('id', room.id);
    setScreen('game');
  };

  const sendQuestion = async () => {
    if (!myQuestion.trim()) return;
    if (pendingQuestion) { setError('Palaukite, kol bus atsakytas ankstesnis klausimas!'); return; }
    await supabase.from('questions').insert({
      room_id: room.id, player_id: playerId,
      player_name: players.find(p => p.id === playerId)?.name || 'Nežinomas',
      question: myQuestion.trim()
    });
    setMyQuestion('');
  };

  const answerQuestion = async (answer) => {
    if (!pendingQuestion) return;
    await supabase.from('questions').update({ answer }).eq('id', pendingQuestion.id);

    // Next questioner
    const others = players.filter(p => p.id !== playerId);
    const currentIdx = others.findIndex(p => p.id === room.current_questioner);
    const nextQuestioner = others[(currentIdx + 1) % others.length]?.id || others[0]?.id;
    const newQuestionsLeft = room.questions_left - 1;

    if (newQuestionsLeft <= 0) {
      await supabase.from('rooms').update({ status: 'finished', questions_left: 0, current_questioner: nextQuestioner }).eq('id', room.id);
    } else {
      await supabase.from('rooms').update({ questions_left: newQuestionsLeft, current_questioner: nextQuestioner }).eq('id', room.id);
    }
    setPendingQuestion(null);
  };

  const markGuessed = async () => {
    await supabase.from('rooms').update({ status: 'guessed' }).eq('id', room.id);
  };

  // ── AI game functions ────────────────────────────────────────────────────
  const startAiGame = async () => {
    setError(''); setLoading(true);
    setAiQuestions([]); setAiWon(false); setAiSurrendered(false); setAiInput('');
    try {
      const resp = await fetch('/api/ai', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'pickWord', category: aiCategory, difficulty: aiDifficulty })
      });
      const data = await resp.json();
      if (data.error) { setError(data.error); setLoading(false); return; }
      setAiSecretWord((data.result || '').trim());
      setScreen('aigame');
    } catch (e) {
      setError('Nepavyko susisiekti su AI: ' + String(e));
    }
    setLoading(false);
  };

  const askAi = async () => {
    if (!aiInput.trim() || aiThinking || aiWon) return;
    const q = aiInput.trim();
    setAiInput('');
    setAiThinking(true);
    // Add question with no answer yet
    setAiQuestions(prev => [...prev, { question: q, answer: null }]);
    try {
      // Send full history so AI stays consistent with previous answers
      const history = aiQuestions
        .filter(item => item.answer)
        .map(item => ({ question: item.question, answer: item.answer }));
      const resp = await fetch('/api/ai', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'answer', category: aiCategory,
          secretWord: aiSecretWord, question: q, history
        })
      });
      const data = await resp.json();
      let answer = (data.result || 'GALI BŪTI').toUpperCase().trim();
      // Normalize
      if (answer.includes('ATSP')) answer = 'ATSPĖJOTE';
      else if (answer.includes('TAIP')) answer = 'TAIP';
      else if (answer.startsWith('NE')) answer = 'NE';
      else answer = 'GALI BŪTI';
      setAiQuestions(prev => prev.map((item, i) =>
        i === prev.length - 1 ? { ...item, answer } : item
      ));
      if (answer === 'ATSPĖJOTE') setAiWon(true);
    } catch (e) {
      setAiQuestions(prev => prev.map((item, i) =>
        i === prev.length - 1 ? { ...item, answer: 'GALI BŪTI' } : item
      ));
    }
    setAiThinking(false);
  };

  // ── Render ───────────────────────────────────────────────────────────────
  useEffect(() => {
    if (room?.status === 'playing' && screen === 'lobby') setScreen('game');
    if (room?.status === 'guessed' && screen === 'game') setScreen('guessed');
    if (room?.status === 'finished' && screen === 'game') setScreen('finished');
  }, [room?.status, screen]);

  if (screen === 'home') return <HomeScreen
    playerName={playerName} setPlayerName={setPlayerName}
    onCreate={() => setScreen('create')} onJoin={() => setScreen('join')}
    onPlayAI={() => setScreen('aisetup')} />;

  if (screen === 'aisetup') return <AiSetupScreen
    aiCategory={aiCategory} setAiCategory={setAiCategory}
    aiDifficulty={aiDifficulty} setAiDifficulty={setAiDifficulty}
    onBack={() => setScreen('home')} onStart={startAiGame}
    loading={loading} error={error} />;

  if (screen === 'aigame') return <AiGameScreen
    aiCategory={aiCategory} aiSecretWord={aiSecretWord}
    aiQuestions={aiQuestions} aiInput={aiInput} setAiInput={setAiInput}
    aiThinking={aiThinking} aiWon={aiWon} aiSurrendered={aiSurrendered}
    onAsk={askAi} onSurrender={() => setAiSurrendered(true)}
    onPlayAgain={() => { setAiQuestions([]); setAiWon(false); setAiSurrendered(false); setScreen('aisetup'); }}
    onHome={() => setScreen('home')} />;

  if (screen === 'create') return <CreateScreen
    playerName={playerName} setPlayerName={setPlayerName}
    secretWord={secretWord} setSecretWord={setSecretWord}
    secretCategory={secretCategory} setSecretCategory={setSecretCategory}
    onBack={() => setScreen('home')} onCreate={createRoom}
    loading={loading} error={error} />;

  if (screen === 'join') return <JoinScreen
    playerName={playerName} setPlayerName={setPlayerName}
    roomCode={roomCode} setRoomCode={setRoomCode}
    onBack={() => setScreen('home')} onJoin={joinRoom}
    loading={loading} error={error} />;

  if (screen === 'lobby') return <LobbyScreen
    room={room} players={players} isHost={isHost}
    roomCode={roomCode} onStart={startGame} error={error} />;

  if (screen === 'game') return <GameScreen
    room={room} players={players} questions={questions}
    playerId={playerId}
    pendingQuestion={pendingQuestion}
    myQuestion={myQuestion} setMyQuestion={setMyQuestion}
    onSendQuestion={sendQuestion} onAnswer={answerQuestion}
    onGuessed={markGuessed}
    voiceActive={voiceActive}
    onVoiceToggle={() => voiceActive ? stopVoice() : startVoice()}
    questionsEndRef={questionsEndRef} />;

  if (screen === 'guessed') return <GuessedScreen
    room={room}
    onPlayAgain={() => { cleanup(); setScreen('home'); setRoom(null); setQuestions([]); }} />;

  if (screen === 'finished') return <FinishedScreen
    room={room}
    onPlayAgain={() => { cleanup(); setScreen('home'); setRoom(null); setQuestions([]); }} />;

  return null;
}

// ═══════════════════════════════════════════════════════════════════════════
// SCREENS
// ═══════════════════════════════════════════════════════════════════════════

function HomeScreen({ playerName, setPlayerName, onCreate, onJoin, onPlayAI }) {
  return (
    <div className="screen home-screen">
      <div className="home-hero">
        <div className="myn-logo">
          <div className="myn-logo-mark">MINA</div>
          <div className="myn-logo-name">One word can destroy everything</div>
          <div className="myn-logo-tagline">Emocija &gt; Logika</div>
        </div>
        <div className="orb-ring">
          <div className="orb-core">?</div>
        </div>
      </div>
      <div className="home-form">
        <input
          className="input-field" placeholder="Tavo vardas"
          value={playerName} onChange={e => setPlayerName(e.target.value)}
          maxLength={20} autoFocus
        />
        <button className="btn btn-primary" onClick={onCreate} disabled={!playerName.trim()}>
          Kurti kambarį
        </button>
        <button className="btn btn-secondary" onClick={onJoin} disabled={!playerName.trim()}>
          Prisijungti
        </button>
        <button className="btn btn-ai" onClick={onPlayAI} disabled={!playerName.trim()}>
          🤖 Žaisti su AI
        </button>
      </div>
    </div>
  );
}

function CreateScreen({ playerName, setPlayerName, secretWord, setSecretWord, secretCategory, setSecretCategory, onBack, onCreate, loading, error }) {
  return (
    <div className="screen">
      <div className="screen-header">
        <button className="btn-back" onClick={onBack}>←</button>
        <h2>Naujas žaidimas</h2>
      </div>
      <div className="form-section">
        <label className="field-label">Tavo vardas</label>
        <input className="input-field" value={playerName} onChange={e => setPlayerName(e.target.value)} maxLength={20} />
      </div>
      <div className="form-section">
        <label className="field-label">Slaptas žodis / vardas</label>
        <input
          className="input-field secret-input"
          placeholder="Pvz: katė, Eiffelio bokštas..."
          value={secretWord} onChange={e => setSecretWord(e.target.value)}
          maxLength={50} type="text" autoComplete="off"
        />
        <p className="field-hint">Kiti žaidėjai to nematys!</p>
      </div>
      <div className="form-section">
        <label className="field-label">Kategorija</label>
        <div className="category-chips">
          {CATEGORIES.map(c => (
            <button key={c}
              className={`chip ${secretCategory === c ? 'chip-active' : ''}`}
              onClick={() => setSecretCategory(c)}>{c}</button>
          ))}
        </div>
      </div>
      {error && <p className="error-text">{error}</p>}
      <button className="btn btn-primary" onClick={onCreate} disabled={loading || !secretWord.trim()}>
        {loading ? 'Kuriama...' : 'Sukurti kambarį'}
      </button>
    </div>
  );
}

function JoinScreen({ playerName, setPlayerName, roomCode, setRoomCode, onBack, onJoin, loading, error }) {
  return (
    <div className="screen">
      <div className="screen-header">
        <button className="btn-back" onClick={onBack}>←</button>
        <h2>Prisijungti</h2>
      </div>
      <div className="form-section">
        <label className="field-label">Tavo vardas</label>
        <input className="input-field" value={playerName} onChange={e => setPlayerName(e.target.value)} maxLength={20} />
      </div>
      <div className="form-section">
        <label className="field-label">Kambario kodas</label>
        <input
          className="input-field code-input"
          placeholder="XXXXXX"
          value={roomCode} onChange={e => setRoomCode(e.target.value.toUpperCase())}
          maxLength={6}
        />
      </div>
      {error && <p className="error-text">{error}</p>}
      <button className="btn btn-primary" onClick={onJoin} disabled={loading || roomCode.length < 4}>
        {loading ? 'Jungiamasi...' : 'Prisijungti'}
      </button>
    </div>
  );
}

function LobbyScreen({ room, players, isHost, roomCode, onStart, error }) {
  const [copied, setCopied] = useState(false);
  const copy = () => {
    navigator.clipboard.writeText(roomCode);
    setCopied(true); setTimeout(() => setCopied(false), 2000);
  };
  return (
    <div className="screen lobby-screen">
      <div className="screen-header center">
        <h2>Laukiama žaidėjų</h2>
      </div>
      <div className="room-code-card" onClick={copy}>
        <p className="room-code-label">Kambario kodas</p>
        <p className="room-code">{roomCode}</p>
        <p className="room-code-hint">{copied ? '✓ Nukopijuota!' : 'Paspausk nukopijuoti'}</p>
      </div>
      <div className="players-list">
        {players.map(p => (
          <div key={p.id} className="player-row">
            <div className="player-avatar">{p.name[0].toUpperCase()}</div>
            <span className="player-name">{p.name}</span>
            {p.is_host && <span className="badge">Šeimininkas</span>}
          </div>
        ))}
      </div>
      {isHost && (
        <>
          {error && <p className="error-text">{error}</p>}
          <button className="btn btn-primary" onClick={onStart} disabled={players.length < 2}>
            {players.length < 2 ? 'Laukiama žaidėjų...' : 'Pradėti žaidimą!'}
          </button>
        </>
      )}
      {!isHost && <p className="waiting-text">Laukiama kol šeimininkas pradės žaidimą...</p>}
    </div>
  );
}

function GameScreen({
  room, players, questions, playerId,
  pendingQuestion, myQuestion, setMyQuestion,
  onSendQuestion, onAnswer, onGuessed,
  voiceActive, onVoiceToggle, questionsEndRef
}) {
  const currentQuestioner = players.find(p => p.id === room?.current_questioner);
  const isMyTurnToAsk = room?.current_questioner === playerId && !pendingQuestion;
  const iAmHost = room?.host_id === playerId;

  return (
    <div className="screen game-screen">
      <div className="game-header">
        <div className="game-meta">
          <span className="questions-left">
            <strong>{room?.questions_left}</strong>
            <small>liko</small>
          </span>
          <span className="category-badge">{room?.secret_category}</span>
        </div>
        <span className="game-header-logo">MINA</span>
        <div className="game-actions">
          <button
            className={`btn-voice ${voiceActive ? 'voice-on' : ''}`}
            onClick={onVoiceToggle}
            title={voiceActive ? 'Išjungti balsą' : 'Įjungti balsą'}
          >
            {voiceActive ? '🎙' : '🎙'}
          </button>
          {iAmHost && (
            <button className="btn-guessed" onClick={onGuessed}>
              Atspėta! 🎉
            </button>
          )}
        </div>
      </div>

      {iAmHost && (
        <div className="secret-hint">
          <span>Tavo žodis: </span>
          <strong>{room?.secret_word}</strong>
        </div>
      )}

      <div className="questions-feed">
        {questions.length === 0 && (
          <div className="empty-feed">
            <div className="empty-icon">?</div>
            <p>Dar nėra klausimų.<br />
              {isMyTurnToAsk ? 'Tavo eilė klausti!' : `${currentQuestioner?.name || '...'} klausinėja`}
            </p>
          </div>
        )}
        {questions.map(q => (
          <div key={q.id} className={`question-bubble ${q.player_id === playerId ? 'my-question' : ''}`}>
            <div className="question-meta">
              <span className="q-name">{q.player_id === playerId ? 'Tu' : q.player_name}</span>
              {q.answer && <span className={`answer-badge answer-${q.answer}`}>
                {ANSWERS.find(a => a.key === q.answer)?.label}
              </span>}
            </div>
            <p className="q-text">{q.question}</p>
            {!q.answer && iAmHost && (
              <div className="answer-buttons">
                {ANSWERS.map(a => (
                  <button key={a.key}
                    className="answer-btn"
                    style={{ '--answer-color': a.color }}
                    onClick={() => onAnswer(a.key)}>
                    {a.label}
                  </button>
                ))}
              </div>
            )}
          </div>
        ))}
        <div ref={questionsEndRef} />
      </div>

      {!iAmHost && (
        <div className="question-input-area">
          {pendingQuestion ? (
            <div className="waiting-answer">
              <div className="pulse-dot" />
              <span>Laukiama atsakymo...</span>
            </div>
          ) : isMyTurnToAsk ? (
            <div className="my-turn-input">
              <div className="turn-indicator">Tavo eilė!</div>
              <div className="input-row">
                <input
                  className="input-field question-input"
                  placeholder="Užduok klausimą..."
                  value={myQuestion}
                  onChange={e => setMyQuestion(e.target.value)}
                  onKeyDown={e => e.key === 'Enter' && onSendQuestion()}
                  maxLength={120}
                  autoFocus
                />
                <button className="btn-send" onClick={onSendQuestion} disabled={!myQuestion.trim()}>
                  →
                </button>
              </div>
            </div>
          ) : (
            <div className="others-turn">
              <span>{currentQuestioner?.name || '...'} klausinėja...</span>
            </div>
          )}
        </div>
      )}

      {iAmHost && !pendingQuestion && (
        <div className="host-waiting">
          <span>{currentQuestioner?.name || '...'} klausinėja...</span>
        </div>
      )}
    </div>
  );
}

// ── AI žaidimo ekranai ──────────────────────────────────────────────────
function AiSetupScreen({ aiCategory, setAiCategory, aiDifficulty, setAiDifficulty, onBack, onStart, loading, error }) {
  return (
    <div className="screen">
      <div className="screen-header">
        <button className="btn-back" onClick={onBack}>←</button>
        <h2>🤖 Žaisti su AI</h2>
      </div>
      <p className="ai-intro">
        AI sugalvos slaptą žodį. Tu klausinėji, AI atsako TAIP / NE / GALI BŪTI.
        Bandyk atspėti!
      </p>
      <div className="form-section">
        <label className="field-label">Kategorija</label>
        <div className="category-chips">
          {CATEGORIES.map(c => (
            <button key={c}
              className={`chip ${aiCategory === c ? 'chip-active' : ''}`}
              onClick={() => setAiCategory(c)}>{c}</button>
          ))}
        </div>
      </div>
      <div className="form-section">
        <label className="field-label">Sunkumas</label>
        <div className="category-chips">
          <button
            className={`chip ${aiDifficulty === 'lengva' ? 'chip-active' : ''}`}
            onClick={() => setAiDifficulty('lengva')}>😊 Lengva</button>
          <button
            className={`chip ${aiDifficulty === 'sunku' ? 'chip-active' : ''}`}
            onClick={() => setAiDifficulty('sunku')}>🔥 Sunku</button>
        </div>
        {error && <p className="error-text">{error}</p>}
        <button className="btn btn-primary" onClick={onStart} disabled={loading}>
          {loading ? 'AI galvoja žodį...' : 'Pradėti žaidimą'}
        </button>
      </div>
    </div>
  );
}

function AiGameScreen({
  aiCategory, aiSecretWord, aiQuestions, aiInput, setAiInput,
  aiThinking, aiWon, aiSurrendered, onAsk, onSurrender, onPlayAgain, onHome
}) {
  const feedRef = useRef(null);
  useEffect(() => {
    if (feedRef.current) feedRef.current.scrollTop = feedRef.current.scrollHeight;
  }, [aiQuestions]);

  const left = 20 - aiQuestions.length;

  if (aiWon) {
    const imageUrl = wordImage(aiSecretWord, aiCategory);
    return (
      <div className="screen guessed-screen">
        <div className="confetti-header">
          <div className="big-emoji">🎉</div>
          <h2>Atspėjai!</h2>
        </div>
        <div className="revealed-card">
          <img src={imageUrl} alt={aiSecretWord} className="revealed-image" />
          <div className="revealed-info">
            <span className="revealed-category">{aiCategory}</span>
            <h2 className="revealed-word">{aiSecretWord}</h2>
            <p className="guessed-sub">Klausimų panaudota: {aiQuestions.length}</p>
          </div>
        </div>
        <button className="btn btn-primary" onClick={onPlayAgain}>Žaisti dar kartą</button>
        <button className="btn btn-secondary" onClick={onHome}>Į pradžią</button>
      </div>
    );
  }

  const lost = left <= 0;
  if (lost || aiSurrendered) {
    return (
      <div className="screen guessed-screen">
        <div className="confetti-header">
          <div className="big-emoji">{aiSurrendered ? '🏳️' : '😅'}</div>
          <h2>{aiSurrendered ? 'Pasidavei!' : 'Klausimai baigėsi!'}</h2>
        </div>
        <div className="revealed-card">
          <img src={wordImage(aiSecretWord, aiCategory)} alt={aiSecretWord} className="revealed-image" />
          <div className="revealed-info">
            <span className="revealed-category">{aiCategory}</span>
            <h2 className="revealed-word">{aiSecretWord}</h2>
            <p className="guessed-sub">AI buvo sugalvojęs šį žodį</p>
          </div>
        </div>
        <button className="btn btn-primary" onClick={onPlayAgain}>Bandyti dar kartą</button>
        <button className="btn btn-secondary" onClick={onHome}>Į pradžią</button>
      </div>
    );
  }

  return (
    <div className="screen game-screen">
      <div className="game-header">
        <div className="game-meta">
          <span className="questions-left">
            <strong>{left}</strong>
            <small>liko</small>
          </span>
          <span className="category-badge">{aiCategory}</span>
        </div>
        <span className="game-header-logo">MINA</span>
        <div className="game-actions">
          <button className="btn-guessed" onClick={onHome}>✕</button>
        </div>
      </div>

      <div className="secret-hint ai-hint">
        <span>🤖 AI sugalvojo žodį — klausinėk ir spėk!</span>
      </div>

      <div className="questions-feed" ref={feedRef}>
        {aiQuestions.length === 0 && (
          <div className="empty-feed ai-empty">
            <div className="ai-orb-big">
              <div className="ai-orb-core">🤖</div>
            </div>
            <p className="ai-empty-title">Laukiame jūsų klausimų</p>
            <div className="suggestion-chips">
              {[
                { icon: '🔍', text: 'Ar tai gyva?' },
                { icon: '📏', text: 'Ar tai didelis?' },
                { icon: '🏠', text: 'Ar tai galima rasti namuose?' },
                { icon: '✋', text: 'Ar tai galima paimti į rankas?' }
              ].map(s => (
                <button key={s.text} className="suggestion-chip"
                  onClick={() => setAiInput(s.text)}>
                  <span className="chip-icon">{s.icon}</span>
                  <span>{s.text}</span>
                </button>
              ))}
            </div>
          </div>
        )}
        {aiQuestions.map((q, i) => (
          <div key={i} className="question-bubble my-question">
            <div className="question-meta">
              <span className="q-name">Tu</span>
              {q.answer && <span className={`answer-badge answer-${
                q.answer === 'TAIP' ? 'taip' :
                q.answer === 'NE' ? 'ne' :
                q.answer === 'ATSPĖJOTE' ? 'taip' : 'gali_buti'
              }`}>{q.answer}</span>}
            </div>
            <p className="q-text">{q.question}</p>
            {!q.answer && (
              <div className="waiting-answer" style={{ marginTop: 8 }}>
                <span className="typing-dots"><span></span><span></span><span></span></span>
                <span>AI galvoja...</span>
              </div>
            )}
          </div>
        ))}
      </div>

      <div className="question-input-area">
        <div className="my-turn-input">
          <div className="input-row">
            <input
              className="input-field question-input"
              placeholder="Užduok klausimą AI..."
              value={aiInput}
              onChange={e => setAiInput(e.target.value)}
              onKeyDown={e => e.key === 'Enter' && onAsk()}
              maxLength={120}
              disabled={aiThinking}
              autoFocus
            />
            <button className="btn-send" onClick={onAsk} disabled={!aiInput.trim() || aiThinking}>
              →
            </button>
          </div>
          <button className="btn-surrender" onClick={onSurrender} disabled={aiThinking}>
            🏳️ Pasiduodu — parodyk žodį
          </button>
        </div>
      </div>
    </div>
  );
}

function GuessedScreen({ room, onPlayAgain }) {
  const imageUrl = room?.secret_image_url ||
    wordImage(room?.secret_word, room?.secret_category);

  return (
    <div className="screen guessed-screen">
      <div className="confetti-header">
        <div className="big-emoji">🎉</div>
        <h1>Atspėta!</h1>
        <p className="guessed-sub">Sveikiname!</p>
      </div>
      <div className="revealed-card">
        <img
          src={imageUrl}
          alt={room?.secret_word}
          className="revealed-image"
        />
        <div className="revealed-info">
          <span className="revealed-category">{room?.secret_category}</span>
          <h2 className="revealed-word">{room?.secret_word}</h2>
        </div>
      </div>
      <button className="btn btn-primary" onClick={onPlayAgain}>Žaisti dar kartą</button>
    </div>
  );
}

function FinishedScreen({ room, onPlayAgain }) {
  const imageUrl = room?.secret_image_url ||
    wordImage(room?.secret_word, room?.secret_category);
  return (
    <div className="screen guessed-screen">
      <div className="confetti-header">
        <div className="big-emoji">😅</div>
        <h1>Klausimai baigėsi!</h1>
        <p className="guessed-sub">Nebuvo atspėta. Tai buvo...</p>
      </div>
      <div className="revealed-card">
        <img src={imageUrl} alt={room?.secret_word} className="revealed-image" />
        <div className="revealed-info">
          <span className="revealed-category">{room?.secret_category}</span>
          <h2 className="revealed-word">{room?.secret_word}</h2>
        </div>
      </div>
      <button className="btn btn-primary" onClick={onPlayAgain}>Žaisti dar kartą</button>
    </div>
  );
}
