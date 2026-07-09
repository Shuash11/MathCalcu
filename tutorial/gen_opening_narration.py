"""Generate opening narration clips."""
import os, json, requests, time, subprocess

BASE = os.path.dirname(__file__)
NARR_DIR = os.path.join(BASE, "narration_promo")

env_path = os.path.join(os.path.expanduser("~"), "video-use", ".env")
api_key = None
with open(env_path) as f:
    for line in f:
        if "API_KEY=" in line and not api_key:
            api_key = line.strip().split("=", 1)[1]

VOICE = "pNInz6obpgDQGcFmaJgB"

LINES = [
    ("promo_00.mp3", "There's a better way."),
    ("promo_07.mp3", "MathCalcu."),
    ("promo_08.mp3", "Eight modules. One app. Step by step. Offline powered."),
]

for name, text in LINES:
    out = os.path.join(NARR_DIR, name)
    if os.path.exists(out):
        print(f"{name}: EXISTS")
        continue
    print(f"{name}: {text}")
    url = f"https://api.elevenlabs.io/v1/text-to-speech/{VOICE}"
    headers = {"xi-api-key": api_key, "Content-Type": "application/json", "Accept": "audio/mpeg"}
    data = {"text": text, "model_id": "eleven_turbo_v2_5",
            "voice_settings": {"stability": 0.5, "similarity_boost": 0.75, "style": 0.3}}
    resp = requests.post(url, json=data, headers=headers, timeout=60)
    if resp.status_code == 200:
        with open(out, "wb") as f:
            f.write(resp.content)
        print(f"  OK")
    else:
        print(f"  FAIL: {resp.text[:100]}")
    time.sleep(0.3)

print("\nDurations:")
for name, _ in LINES:
    p = os.path.join(NARR_DIR, name)
    if os.path.exists(p):
        r = subprocess.run(["ffprobe","-v","quiet","-show_entries","format=duration",
                           "-of","default=noprint_wrappers=1:nokey=1",p], capture_output=True, text=True)
        print(f"  {name}: {float(r.stdout.strip()):.2f}s")
