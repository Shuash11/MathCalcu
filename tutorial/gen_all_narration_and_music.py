"""Generate narration for ALL scenes + background music."""
import os, json, requests, time, subprocess, struct, wave, math

BASE = os.path.dirname(__file__)
NARR_DIR = os.path.join(BASE, "narration_promo")
MUSIC_DIR = os.path.join(BASE, "music")
os.makedirs(NARR_DIR, exist_ok=True)
os.makedirs(MUSIC_DIR, exist_ok=True)

env_path = os.path.join(os.path.expanduser("~"), "video-use", ".env")
api_key = None
with open(env_path) as f:
    for line in f:
        if "API_KEY=" in line and not api_key:
            api_key = line.strip().split("=", 1)[1]

VOICE = "pNInz6obpgDQGcFmaJgB"

# ALL narration lines for every scene
ALL_LINES = [
    # Scene 1: Hook (0-3s)
    ("promo_00.mp3", "There's a better way."),
    # Scene 2: Problem (3-6s)
    ("promo_09.mp3", "Calculus problems. Your textbook is not helping."),
    # Scene 3: App Reveal (6-10s)
    ("promo_07.mp3", "MathCalcu."),
    # Scene 4: Modules (10-15s)
    ("promo_01.mp3", "Eight math modules. One app."),
    # Scene 5: Derivatives (15-20s)
    ("promo_02.mp3", "Derivatives. Limits. Geometry. Inequalities."),
    # Scene 6: Limits (20-25s)
    ("promo_03.mp3", "Step by step solutions. LaTeX rendered."),
    # Scene 7: Geometry (25-30s)
    ("promo_10.mp3", "Circles. Distance. Slope. All with graphing."),
    # Scene 8: Offline (30-33s)
    ("promo_04.mp3", "Works completely offline."),
    # Scene 9: LaTeX (33-37s)
    ("promo_11.mp3", "Every formula rendered in LaTeX. Academic precision."),
    # Scene 10: Cross-Platform (37-41s)
    ("promo_05.mp3", "Built for BSCS students."),
    # Scene 11: CTA (41-50s)
    ("promo_06.mp3", "MathCalcu. Math doesn't have to be hard."),
    # Scene 12: Close (50-55s)
    ("promo_08.mp3", "Eight modules. One app. Step by step. Offline powered."),
]

def generate_tts(text, output_path):
    url = f"https://api.elevenlabs.io/v1/text-to-speech/{VOICE}"
    headers = {"xi-api-key": api_key, "Content-Type": "application/json", "Accept": "audio/mpeg"}
    data = {"text": text, "model_id": "eleven_turbo_v2_5",
            "voice_settings": {"stability": 0.5, "similarity_boost": 0.75, "style": 0.3}}
    resp = requests.post(url, json=data, headers=headers, timeout=60)
    if resp.status_code == 200:
        with open(output_path, "wb") as f:
            f.write(resp.content)
        return True
    print(f"  ERROR {resp.status_code}: {resp.text[:100]}")
    return False

def get_dur(path):
    r = subprocess.run(["ffprobe","-v","quiet","-show_entries","format=duration",
                       "-of","default=noprint_wrappers=1:nokey=1",path],
                       capture_output=True, text=True)
    return float(r.stdout.strip())

# Generate missing narration
print("=== Generating Narration ===")
for name, text in ALL_LINES:
    out = os.path.join(NARR_DIR, name)
    if os.path.exists(out):
        sz = os.path.getsize(out)
        if sz > 1000:
            print(f"  {name}: EXISTS ({sz//1024}KB)")
            continue
    print(f"  {name}: {text}")
    ok = generate_tts(text, out)
    print(f"    {'OK' if ok else 'FAIL'}")
    time.sleep(0.3)

# Generate background music using ffmpeg synthesis
print("\n=== Generating Background Music ===")
music_path = os.path.join(MUSIC_DIR, "bg_music.wav")
target_dur = 58  # slightly longer than video

# Create a simple electronic beat with bass + hi-hat + pad
# Using ffmpeg's sine wave generators and filters
cmd = [
    "ffmpeg", "-y",
    # Bass line (low sine wave with rhythm)
    "-f", "lavfi", "-i",
    f"sine=frequency=80:duration={target_dur}:sample_rate=44100",
    # Pad (ambient chord)
    "-f", "lavfi", "-i",
    f"sine=frequency=220:duration={target_dur}:sample_rate=44100",
    "-f", "lavfi", "-i",
    f"sine=frequency=277:duration={target_dur}:sample_rate=44100",
    "-f", "lavfi", "-i",
    f"sine=frequency=330:duration={target_dur}:sample_rate=44100",
    # Hi-hat (high freq)
    "-f", "lavfi", "-i",
    f"sine=frequency=8000:duration={target_dur}:sample_rate=44100",
    "-filter_complex",
    # Bass: volume pulse at 120 BPM
    f"[0:a]volume='0.3*abs(sin(2*PI*t*2))':eval=frame[bass];"
    # Pad: soft ambient
    f"[1:a][2:a][3:a]amix=inputs=3:duration=first,volume=0.08[pad];"
    # Hi-hat: rhythmic clicks
    f"[4:a]volume='0.15*abs(sin(2*PI*t*4))^8':eval=frame[hh];"
    # Mix all
    f"[bass][pad][hh]amix=inputs=3:duration=first:dropout_transition=0,"
    f"afade=t=in:d=2,afade=t=out:st={target_dur-3}:d=3[out]",
    "-map", "[out]",
    "-c:a", "pcm_s16le", music_path
]

print("  Synthesizing beat...")
r = subprocess.run(cmd, capture_output=True, text=True)
if r.returncode == 0:
    dur = get_dur(music_path)
    print(f"  Music OK: {dur:.1f}s")
else:
    print(f"  Music error: {r.stderr[-300:]}")

print("\n=== All narration + music ready ===")
