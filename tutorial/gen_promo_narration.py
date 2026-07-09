"""Generate short punchy narration for 60s promo video."""
import os, json, requests, time

BASE = os.path.dirname(__file__)
NARR_DIR = os.path.join(BASE, "narration_promo")
os.makedirs(NARR_DIR, exist_ok=True)

env_path = os.path.join(os.path.expanduser("~"), "video-use", ".env")
api_key = None
with open(env_path) as f:
    for line in f:
        if "API_KEY=" in line and not api_key:
            api_key = line.strip().split("=", 1)[1]

VOICE = "pNInz6obpgDQGcFmaJgB"  # Adam - male cinematic

# Short punchy lines for promo
LINES = [
    ("promo_01", "Eight math modules. One app."),
    ("promo_02", "Derivatives. Limits. Geometry. Inequalities."),
    ("promo_03", "Step by step solutions. LaTeX rendered."),
    ("promo_04", "Works completely offline."),
    ("promo_05", "Built for BSCS students."),
    ("promo_06", "MathCalcu. Math doesn't have to be hard."),
]

def generate(text, output_path):
    url = f"https://api.elevenlabs.io/v1/text-to-speech/{VOICE}"
    headers = {"xi-api-key": api_key, "Content-Type": "application/json", "Accept": "audio/mpeg"}
    data = {"text": text, "model_id": "eleven_turbo_v2_5",
            "voice_settings": {"stability": 0.5, "similarity_boost": 0.75, "style": 0.3}}
    resp = requests.post(url, json=data, headers=headers, timeout=60)
    if resp.status_code != 200:
        print(f"  ERROR {resp.code}: {resp.text[:200]}")
        return False
    with open(output_path, "wb") as f:
        f.write(resp.content)
    return True

for name, text in LINES:
    out = os.path.join(NARR_DIR, f"{name}.mp3")
    if os.path.exists(out):
        print(f"{name}: EXISTS")
        continue
    print(f"{name}: {text}")
    ok = generate(text, out)
    print(f"  {'OK' if ok else 'FAIL'}")
    time.sleep(0.3)

# Get durations
import subprocess
print("\nDurations:")
for name, _ in LINES:
    p = os.path.join(NARR_DIR, f"{name}.mp3")
    if os.path.exists(p):
        r = subprocess.run(["ffprobe","-v","quiet","-show_entries","format=duration",
                           "-of","default=noprint_wrappers=1:nokey=1",p], capture_output=True, text=True)
        print(f"  {name}: {float(r.stdout.strip()):.2f}s")
