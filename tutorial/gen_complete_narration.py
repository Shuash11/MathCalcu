"""Generate COMPLETE narration for every scene — continuous flow, no gaps."""
import os, json, requests, time, subprocess

BASE = os.path.dirname(__file__)
NARR_DIR = os.path.join(BASE, "narration_promo")
os.makedirs(NARR_DIR, exist_ok=True)

env_path = os.path.join(os.path.expanduser("~"), "video-use", ".env")
api_key = None
with open(env_path) as f:
    for line in f:
        if "API_KEY=" in line and not api_key:
            api_key = line.strip().split("=", 1)[1]

VOICE = "pNInz6obpgDQGcFmaJgB"

# COMPLETE narration — each fills its scene duration
SCENES = [
    # Scene 1: Hook (3s) — short dramatic line
    ("s01_hook", "There's a better way.", 3),
    # Scene 2: Problem (3s) — set up the pain
    ("s02_problem", "You have a calculus exam tomorrow. Your textbook is useless. Your notes make no sense.", 3),
    # Scene 3: App Reveal (4s) — introduce the app
    ("s03_reveal", "Meet MathCalcu. The math solver built for computer science students.", 4),
    # Scene 4: Modules (5s) — list all 8
    ("s04_modules", "Eight specialized modules. Derivatives, slope, limits at a point, limits at infinity, inequalities, circles, distance and midpoint, and slope intercept. Everything you need, nothing you don't.", 5),
    # Scene 5: Derivatives (5s) — deep dive
    ("s05_derivatives", "Derivatives made easy. Type any expression. The chain rule, power rule, product rule, quotient rule. MathCalcu handles them all. Step by step. Every time.", 5),
    # Scene 6: Limits (5s) — four methods
    ("s06_limits", "Four methods for limits. Substitution, factoring, LCD, and conjugate. MathCalcu knows which one to use. Just type and solve.", 5),
    # Scene 7: Geometry (5s) — geometry features
    ("s07_geometry", "Analytic geometry. Circles with center and radius. Distance and midpoint between any two points. Slope and line equations. All with live graphing support.", 5),
    # Scene 8: Offline (3s) — key feature
    ("s08_offline", "Everything runs one hundred percent offline. No internet needed. No waiting. Just math.", 3),
    # Scene 9: LaTeX (4s) — rendering
    ("s09_latex", "Every solution rendered in LaTeX. Academic precision. Same format used in research papers and textbooks.", 4),
    # Scene 10: Cross-platform (4s) — platforms
    ("s10_platform", "Built with Flutter. Android, iOS, web, and desktop. One codebase. One app. Everywhere you study.", 4),
    # Scene 11: CTA (9s) — call to action
    ("s11_cta", "MathCalcu. Eight modules. Offline powered. Step by step solutions. Built by BSCS students, for every BSCS student. Star it on GitHub. Share it with your classmates. Math doesn't have to be hard.", 9),
    # Scene 12: Close (5s) — final message
    ("s12_close", "MathCalcu. Made for you. Made for BSCS. Download it now. Start solving.", 5),
]

def generate(text, output_path):
    url = f"https://api.elevenlabs.io/v1/text-to-speech/{VOICE}"
    headers = {"xi-api-key": api_key, "Content-Type": "application/json", "Accept": "audio/mpeg"}
    data = {"text": text, "model_id": "eleven_turbo_v2_5",
            "voice_settings": {"stability": 0.5, "similarity_boost": 0.75, "style": 0.3}}
    resp = requests.post(url, json=data, headers=headers, timeout=60)
    if resp.status_code == 200:
        with open(output_path, "wb") as f:
            f.write(resp.content)
        return True
    print(f"    ERROR {resp.status_code}: {resp.text[:100]}")
    return False

def get_dur(path):
    r = subprocess.run(["ffprobe","-v","quiet","-show_entries","format=duration",
                       "-of","default=noprint_wrappers=1:nokey=1",path],
                       capture_output=True, text=True)
    return float(r.stdout.strip())

print("Generating complete narration...\n")
for name, text, target_dur in SCENES:
    out = os.path.join(NARR_DIR, f"{name}.mp3")
    # Always regenerate to ensure quality
    print(f"  {name} ({target_dur}s): {text[:60]}...")
    ok = generate(text, out)
    if ok:
        actual = get_dur(out)
        print(f"    OK ({actual:.1f}s)")
    else:
        print(f"    FAIL")
    time.sleep(0.3)

# Also generate background music — better quality electronic beat
print("\nGenerating background music...")
music_dir = os.path.join(BASE, "music")
os.makedirs(music_dir, exist_ok=True)
music_path = os.path.join(music_dir, "bg_music_v2.wav")

# Generate a more musical beat with layered tones
cmd = [
    "ffmpeg", "-y",
    # Bass kick (80Hz, rhythmic)
    "-f", "lavfi", "-i", f"sine=frequency=80:duration=58:sample_rate=44100",
    # Snare/hi-hat (noise-like)
    "-f", "lavfi", "-i", f"sine=frequency=200:duration=58:sample_rate=44100",
    # Pad chord C major (C4=262, E4=330, G4=392)
    "-f", "lavfi", "-i", f"sine=frequency=262:duration=58:sample_rate=44100",
    "-f", "lavfi", "-i", f"sine=frequency=330:duration=58:sample_rate=44100",
    "-f", "lavfi", "-i", f"sine=frequency=392:duration=58:sample_rate=44100",
    # High ambient
    "-f", "lavfi", "-i", f"sine=frequency=523:duration=58:sample_rate=44100",
    "-filter_complex",
    # Bass: pulsing at 120BPM
    "[0:a]volume='0.4*max(0,1-4*mod(t*2,1))':eval=frame[bass];"
    # Snare: sharp hits
    "[1:a]volume='0.2*max(0,1-8*mod(t*4+0.5,1))':eval=frame[snare];"
    # Pad: soft sustained chord
    "[2:a][3:a][4:a]amix=inputs=3:duration=first,volume=0.06[pad];"
    # High ambient
    "[5:a]volume='0.03+0.02*sin(2*PI*t*0.1)':eval=frame[high];"
    # Mix all with fade
    "[bass][snare][pad][high]amix=inputs=4:duration=first:dropout_transition=0,"
    "afade=t=in:d=2,afade=t=out:st=55:d=3[out]",
    "-map", "[out]", "-c:a", "pcm_s16le", music_path
]
r = subprocess.run(cmd, capture_output=True, text=True)
if r.returncode == 0:
    dur = get_dur(music_path)
    print(f"  Music OK: {dur:.1f}s")
else:
    print(f"  Music error: {r.stderr[-200:]}")

print("\nAll narration + music generated!")
