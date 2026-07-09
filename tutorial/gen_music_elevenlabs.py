"""Generate background music using ElevenLabs sound effects API."""
import os, json, requests, subprocess, time

BASE = os.path.dirname(__file__)
MUSIC_DIR = os.path.join(BASE, "music")
os.makedirs(MUSIC_DIR, exist_ok=True)

env_path = os.path.join(os.path.expanduser("~"), "video-use", ".env")
api_key = None
with open(env_path) as f:
    for line in f:
        if "API_KEY=" in line and not api_key:
            api_key = line.strip().split("=", 1)[1]

# Try ElevenLabs sound effects / music generation
# Method 1: Use their sound generation endpoint
def try_elevenlabs_sfx():
    """Try generating ambient electronic music via ElevenLabs."""
    url = "https://api.elevenlabs.io/v1/sound-generation"
    headers = {
        "xi-api-key": api_key,
        "Content-Type": "application/json",
        "Accept": "audio/mpeg"
    }
    prompts = [
        "ambient electronic background music for tech product video, cinematic, modern, upbeat, soft synthesizer, steady beat, professional",
        "soft corporate background music, electronic, ambient, clean, modern tech advertisement, gentle pulse",
    ]
    
    for i, prompt in enumerate(prompts):
        print(f"  Trying prompt {i+1}...")
        data = {
            "text": prompt,
            "duration_seconds": 120,
            "prompt_influence": 0.5
        }
        try:
            resp = requests.post(url, json=data, headers=headers, timeout=120)
            if resp.status_code == 200:
                out = os.path.join(MUSIC_DIR, f"elevenlabs_music_{i}.mp3")
                with open(out, "wb") as f:
                    f.write(resp.content)
                sz = os.path.getsize(out) / 1024
                print(f"    OK: {sz:.0f} KB")
                return out
            else:
                print(f"    Status {resp.status_code}: {resp.text[:150]}")
        except Exception as e:
            print(f"    Error: {e}")
        time.sleep(1)
    return None

# Method 2: Try the newer /v1/music-generation endpoint
def try_elevenlabs_music():
    """Try the music generation endpoint."""
    url = "https://api.elevenlabs.io/v1/music-generation"
    headers = {
        "xi-api-key": api_key,
        "Content-Type": "application/json",
        "Accept": "audio/mpeg"
    }
    data = {
        "prompt": "ambient electronic background music, soft synthesizer, steady beat, modern tech product advertisement, cinematic, clean, professional, upbeat but not aggressive",
        "seconds": 120
    }
    try:
        print("  Trying /v1/music-generation...")
        resp = requests.post(url, json=data, headers=headers, timeout=120)
        if resp.status_code == 200:
            out = os.path.join(MUSIC_DIR, "elevenlabs_music.mp3")
            with open(out, "wb") as f:
                f.write(resp.content)
            sz = os.path.getsize(out) / 1024
            print(f"    OK: {sz:.0f} KB")
            return out
        else:
            print(f"    Status {resp.status_code}: {resp.text[:200]}")
    except Exception as e:
        print(f"    Error: {e}")
    return None

# Method 3: Use pip package for music generation
def try_pip_music():
    """Try using music-gen or audiocraft if installed."""
    try:
        import torch
        from audiocraft.models import MusicGen
        print("  Using audiocraft MusicGen...")
        model = MusicGen.get_pretrained('facebook/musicgen-small')
        model.set_generation_params(duration=120)
        wav = model.generate(['ambient electronic background music for tech advertisement'])
        import scipy.io.wavfile as wavfile
        out = os.path.join(MUSIC_DIR, "musicgen_bg.wav")
        wavfile.write(out, 32000, wav[0].cpu().numpy())
        print(f"    OK")
        return out
    except ImportError:
        print("  audiocraft not installed")
    except Exception as e:
        print(f"  audiocraft error: {e}")
    return None

print("=== Generating Background Music ===\n")

# Try each method
result = try_elevenlabs_music()
if not result:
    result = try_elevenlabs_sfx()
if not result:
    result = try_pip_music()

if result:
    # Get duration
    r = subprocess.run(["ffprobe","-v","quiet","-show_entries","format=duration",
                       "-of","default=noprint_wrappers=1:nokey=1",result],
                       capture_output=True, text=True)
    dur = float(r.stdout.strip()) if r.stdout.strip() else 0
    print(f"\nFinal music: {result} ({dur:.1f}s)")
else:
    print("\nNo music generation method worked.")
    print("Trying to download a royalty-free track...")
    
    # Try downloading from a free source
    music_url = "https://cdn.pixabay.com/audio/2024/11/29/audio_febc0d5c8b.mp3"
    try:
        resp = requests.get(music_url, timeout=30)
        if resp.status_code == 200:
            out = os.path.join(MUSIC_DIR, "pixabay_bg.mp3")
            with open(out, "wb") as f:
                f.write(resp.content)
            print(f"  Downloaded: {out}")
    except Exception as e:
        print(f"  Download failed: {e}")
