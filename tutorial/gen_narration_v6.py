"""Generate narration for the new 8-scene MathCalcu promo video."""
import os, json, requests, time

BASE = os.path.dirname(__file__)
NARRATION_DIR = os.path.join(BASE, "narration")
os.makedirs(NARRATION_DIR, exist_ok=True)

# Load API key
env_path = os.path.join(os.path.expanduser("~"), "video-use", ".env")
api_key = None
with open(env_path) as f:
    for line in f:
        if line.startswith("ELEVENLABS_API_KEY="):
            api_key = line.strip().split("=", 1)[1]
        elif line.startswith("API_KEY=") and not api_key:
            api_key = line.strip().split("=", 1)[1]

if not api_key:
    raise RuntimeError("No API key found in .env")

# Voice IDs
MALE_CINEMATIC = "pNInz6obpgDQGcFmaJgB"  # Adam
FEMALE_EDUCATIONAL = "21m00Tcm4TlvDq8ikWAM"  # Rachel

# Scene narration lines — each scene can have multiple lines that get concatenated
SCENES = {
    "s01_cold_open": {
        "voice": MALE_CINEMATIC,
        "lines": [
            "There's a better way."
        ]
    },
    "s02_app_reveal": {
        "voice": MALE_CINEMATIC,
        "lines": [
            "MathCalcu is a Flutter-powered math solver designed specifically for BSCS students. "
            "Eight modules. Complete offline support. Step-by-step solutions with LaTeX rendering — "
            "built for the way you study."
        ]
    },
    "s03_module_showcase": {
        "voice": MALE_CINEMATIC,
        "lines": [
            "Eight specialized modules, each built to solve a specific area of your BSCS mathematics coursework. "
            "Derivatives. Limits. Analytic Geometry. Inequalities. "
            "Everything in one place — nothing extra, nothing missing."
        ]
    },
    "s04_derivatives": {
        "voice": MALE_CINEMATIC,
        "lines": [
            "Let's start with Derivatives — the heart of Calculus 1.",
            "Type your expression in plain notation — MathCalcu reads it exactly as you'd write it by hand.",
            "Tap Solve.",
            "The app identifies your expression, names the rule it needs — Chain Rule here — "
            "and walks you through every step. Problem statement. Rule identification. Application. "
            "Simplification. Final answer. All formatted in LaTeX, the same standard used in academic research.",
            "And it doesn't stop at one type. Power, Product, Quotient, Chain — all six trig functions, "
            "exponentials, logarithms, inverse trig, hyperbolic — MathCalcu handles them all."
        ]
    },
    "s05_limits": {
        "voice": MALE_CINEMATIC,
        "lines": [
            "Limits. MathCalcu solves them four ways — and knows which one to use.",
            "Direct substitution when it works. Factoring to eliminate the indeterminate form. "
            "LCD for complex fractions. And the conjugate method for radical expressions.",
            "For limits at infinity, it divides by the dominant power and walks you through "
            "which terms survive — and why."
        ]
    },
    "s06_geometry": {
        "voice": MALE_CINEMATIC,
        "lines": [
            "MathCalcu doesn't stop at calculus. The Analytic Geometry modules cover circles — "
            "giving you center, radius, standard form, general form, and a live graph. "
            "Distance and midpoint between two points, visualized instantly. "
            "Slope and line equations from two points — including parallel and perpendicular variants. "
            "And inequality solving across all types, with the answer displayed on a number line."
        ]
    },
    "s07_power_features": {
        "voice": MALE_CINEMATIC,
        "lines": [
            "Everything runs offline — no internet required after install. "
            "Every solution is rendered in LaTeX for clarity and precision. "
            "And because it's built with Flutter, MathCalcu runs natively on Android, iOS, Web, and Desktop — "
            "one app, everywhere you study."
        ]
    },
    "s08_closing": {
        "voice": MALE_CINEMATIC,
        "lines": [
            "MathCalcu. Eight modules. Offline-powered. Step-by-step. "
            "Built by BSCS students — for every BSCS student.",
            "Available on GitHub. Star it, fork it, share it.",
            "Math doesn't have to be hard."
        ]
    }
}

def generate_line(text, voice_id, output_path):
    """Generate a single narration line via ElevenLabs API."""
    url = f"https://api.elevenlabs.io/v1/text-to-speech/{voice_id}"
    headers = {
        "xi-api-key": api_key,
        "Content-Type": "application/json",
        "Accept": "audio/mpeg"
    }
    data = {
        "text": text,
        "model_id": "eleven_turbo_v2_5",
        "voice_settings": {
            "stability": 0.5,
            "similarity_boost": 0.75,
            "style": 0.3,
            "use_speaker_boost": True
        }
    }
    resp = requests.post(url, json=data, headers=headers, timeout=60)
    if resp.status_code != 200:
        print(f"  ERROR {resp.status_code}: {resp.text[:200]}")
        return False
    with open(output_path, "wb") as f:
        f.write(resp.content)
    return True

def main():
    for scene_name, info in SCENES.items():
        print(f"\n{'='*50}")
        print(f"Scene: {scene_name}")
        voice_label = "Male cinematic" if info["voice"] == MALE_CINEMATIC else "Female educational"
        print(f"Voice: {voice_label}")
        
        for i, line in enumerate(info["lines"]):
            out_path = os.path.join(NARRATION_DIR, f"{scene_name}_{i:02d}.mp3")
            if os.path.exists(out_path):
                sz = os.path.getsize(out_path) / 1024
                print(f"  Line {i}: EXISTS ({sz:.0f} KB)")
                continue
            print(f"  Line {i}: Generating...")
            print(f"    Text: {line[:80]}...")
            ok = generate_line(line, info["voice"], out_path)
            if ok:
                sz = os.path.getsize(out_path) / 1024
                print(f"    OK ({sz:.0f} KB)")
            else:
                print(f"    FAILED")
            time.sleep(0.5)  # Rate limit
    
    print(f"\n{'='*50}")
    print("Done! All narration files generated.")

if __name__ == "__main__":
    main()
