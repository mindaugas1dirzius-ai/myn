"""
gen_sounds.py — sugeneruoja ORIGINALIUS garso efektus (WAV) žaidimui.

KODĖL patys generuojam: jokių autorinių teisių / licencijų problemų —
100% saugu Google Play. Garsai trumpi (mažai KB), maloniai suderinti.

Efektai:
  tap.wav     — mygtuko paspaudimas (trumpas, subtilus „tap")
  swoosh.wav  — naujo klausimo atsiradimas (švelnus kylantis tonas)
  correct.wav — teisingas atsakymas (linksmas dviejų tonų „ding" ↑)
  wrong.wav   — klaidingas (žemas, trumpas „buzz" ↓)
  points.wav  — taškų skaičiavimas (tylus aukštas blyptelėjimas)
  win.wav     — partijos pabaiga (mažas pergalės arpedžio)

Paleidimas:  python tools/gen_sounds.py
"""
import math
import os
import struct
import wave

SR = 44100  # diskretizacija
OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "sounds")


def _write(name, samples):
    os.makedirs(OUT, exist_ok=True)
    path = os.path.join(OUT, name)
    with wave.open(path, "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)  # 16-bit
        w.setframerate(SR)
        frames = b"".join(struct.pack("<h", int(max(-1, min(1, s)) * 32767)) for s in samples)
        w.writeframes(frames)
    print(f"  {name}: {len(samples)} samples ({os.path.getsize(path)} B)")


def tone(freq, ms, vol=0.5, attack_ms=3, release_ms=30, wave_type="sine"):
    """Vienas tonas su minkštu užderinimu/atleidimu (be spragsėjimo)."""
    n = int(SR * ms / 1000)
    a = int(SR * attack_ms / 1000)
    r = int(SR * release_ms / 1000)
    out = []
    for i in range(n):
        t = i / SR
        if wave_type == "sine":
            v = math.sin(2 * math.pi * freq * t)
        elif wave_type == "square":
            v = 1.0 if math.sin(2 * math.pi * freq * t) >= 0 else -1.0
        elif wave_type == "tri":
            v = 2 / math.pi * math.asin(math.sin(2 * math.pi * freq * t))
        else:
            v = math.sin(2 * math.pi * freq * t)
        # apvalkalas (envelope)
        env = 1.0
        if i < a:
            env = i / a
        elif i > n - r:
            env = max(0.0, (n - i) / r)
        out.append(v * vol * env)
    return out


def sweep(f0, f1, ms, vol=0.4, release_ms=40):
    """Tonas, slenkantis nuo f0 iki f1 (swoosh)."""
    n = int(SR * ms / 1000)
    r = int(SR * release_ms / 1000)
    out = []
    phase = 0.0
    for i in range(n):
        frac = i / n
        f = f0 + (f1 - f0) * frac
        phase += 2 * math.pi * f / SR
        v = math.sin(phase)
        env = 1.0
        if i > n - r:
            env = max(0.0, (n - i) / r)
        # taip pat švelnus įžanginis užderinimas
        if i < int(SR * 0.004):
            env *= i / (SR * 0.004)
        out.append(v * vol * env)
    return out


def mix(*tracks):
    """Sudeda kelis tonus (su persidengimu) į vieną; ribojam, kad neperšoktų."""
    length = max(len(t) for t in tracks)
    out = [0.0] * length
    for t in tracks:
        for i, s in enumerate(t):
            out[i] += s
    return [max(-1, min(1, s)) for s in out]


def pad(samples, ms):
    """Tyla pradžioje (atidėjimui), kad tonai eitų vienas po kito."""
    return [0.0] * int(SR * ms / 1000) + samples


def main():
    # tap: trumpas aukštas, labai subtilus
    _write("tap.wav", tone(900, 45, vol=0.32, release_ms=35, wave_type="tri"))

    # swoosh: naujo klausimo atsiradimas — švelnus kilimas
    _write("swoosh.wav", sweep(420, 900, 160, vol=0.28))

    # correct: du kylantys tonai (E5 → A5) — linksma
    correct = tone(659, 110, vol=0.42, release_ms=40) + tone(880, 150, vol=0.45, release_ms=60)
    _write("correct.wav", correct)

    # wrong: ŠVELNUS krentantis „ne tas" — du minkšti sine tonai (G4 → D4),
    # tylesni ir trumpesni nei aštrus square „buzz" (kad neerzintų vaiko).
    wrong = (tone(392, 110, vol=0.30, release_ms=50, wave_type="sine") +
             tone(294, 150, vol=0.28, release_ms=90, wave_type="sine"))
    _write("wrong.wav", wrong)

    # points: tylus aukštas blyptelėjimas (taškų tiksėjimui)
    _write("points.wav", tone(1500, 28, vol=0.22, release_ms=20, wave_type="tri"))

    # win: mažas pergalės arpedžio C5-E5-G5-C6
    win = (tone(523, 110, vol=0.4) +
           tone(659, 110, vol=0.4) +
           tone(784, 110, vol=0.4) +
           tone(1046, 240, vol=0.5, release_ms=120))
    _write("win.wav", win)


if __name__ == "__main__":
    print("Generuojami garsai:", os.path.abspath(OUT))
    main()
    print("Baigta.")
