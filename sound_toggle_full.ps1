# MINA - Garso on/off mygtukas (JS + CSS)
# Paleisk si faila is MYN aplanko

Write-Host "=== MINA: Garso mygtukas ===" -ForegroundColor Cyan

# ── App.js pakeitimai ────────────────────────────────────────────────────────

$appPath = "src\App.js"
$content = Get-Content $appPath -Raw -Encoding UTF8

if ($content -match "soundEnabled") {
    Write-Host "[SKIP] App.js - jau prideta" -ForegroundColor Yellow
} else {
    # 1. Garso globalus kintamasis
    $oldPlaySound = "const playSound = (type) => {"
    $newPlaySound = "let _soundEnabled = localStorage.getItem('soundEnabled') !== 'false';

const playSound = (type) => {
  if (!_soundEnabled) return;"

    $content = $content.Replace($oldPlaySound, $newPlaySound)

    # 2. soundOn state GameScreen'e
    $oldState = "  const [chatInput, setChatInput] = React.useState('');"
    $newState = "  const [chatInput, setChatInput] = React.useState('');
  const [soundOn, setSoundOn] = React.useState(() => localStorage.getItem('soundEnabled') !== 'false');"

    $content = $content.Replace($oldState, $newState)

    # 3. Mygtukas headeryje šalia voice
    $oldVoiceBtn = "          <button
            className={``btn-voice `${voiceActive ? 'voice-on' : ''}`}
            onClick={onVoiceToggle}
            title={voiceActive ? 'Išjungti balsą' : 'Įjungti balsą'}
          >
            <span className=""voice-icon"">{voiceActive ? '🔴' : '🎙️'}</span>
          </button>"

    $newVoiceBtn = "          <button
            className=""btn-sound""
            onClick={() => {
              const next = !soundOn;
              setSoundOn(next);
              _soundEnabled = next;
              localStorage.setItem('soundEnabled', String(next));
              if (next) playSound('click');
            }}
            title={soundOn ? 'Išjungti garsą' : 'Įjungti garsą'}
          >
            <span>{soundOn ? '🔊' : '🔇'}</span>
          </button>
          <button
            className={``btn-voice `${voiceActive ? 'voice-on' : ''}`}
            onClick={onVoiceToggle}
            title={voiceActive ? 'Išjungti balsą' : 'Įjungti balsą'}
          >
            <span className=""voice-icon"">{voiceActive ? '🔴' : '🎙️'}</span>
          </button>"

    $content = $content.Replace($oldVoiceBtn, $newVoiceBtn)

    Set-Content $appPath $content -Encoding UTF8
    Write-Host "[OK] src/App.js" -ForegroundColor Green
}

# ── App.css pakeitimai ───────────────────────────────────────────────────────

$cssPath = "src\App.css"
$cssContent = Get-Content $cssPath -Raw -Encoding UTF8

if ($cssContent -match "btn-sound") {
    Write-Host "[SKIP] App.css - jau prideta" -ForegroundColor Yellow
} else {
    $newCss = @"

/* ── Garso mygtukas ─────────────────────────────────── */
.btn-sound {
  background: rgba(255,255,255,0.08);
  border: 1px solid rgba(255,255,255,0.15);
  border-radius: 10px;
  color: #fff;
  font-size: 18px;
  width: 38px;
  height: 38px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: background 0.2s, transform 0.1s;
  padding: 0;
}
.btn-sound:hover {
  background: rgba(255,255,255,0.18);
  transform: scale(1.08);
}
.btn-sound:active {
  transform: scale(0.94);
}
"@
    $cssContent = $cssContent + $newCss
    Set-Content $cssPath $cssContent -Encoding UTF8
    Write-Host "[OK] src/App.css" -ForegroundColor Green
}

Write-Host ""
Write-Host "Viskas atlikta! Dabar:" -ForegroundColor Cyan
Write-Host "  git add -A" -ForegroundColor White
Write-Host "  git commit -m ""feat: garso on/off mygtukas""" -ForegroundColor White
Write-Host "  git push ..." -ForegroundColor White
