"""Generate voiceover narration for each slide using ElevenLabs API."""
import os
import json
import requests

API_KEY = "sk_d3bee5ebdb0fc6d937c799d43e62efafff8d1ecfb308d1c0"
BASE_URL = "https://api.elevenlabs.io/v1"
OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "narration")
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Narration script per slide
narration = {
    "01_title": "Welcome to MathCalcu, a powered math system for calculus and analytic geometry. All computations run offline, with step by step solutions.",
    "02_features": "MathCalcu covers derivatives, slope, limits, inequalities, circles, distance, and more. Let's explore the key features.",
    "03_derivatives": "The derivatives solver supports symbolic differentiation. Enter any expression, and MathCalcu shows each step: the problem statement, the rule applied, the differentiation, and the final answer. It handles power, product, quotient, chain, trigonometric, logarithmic, and hyperbolic functions.",
    "04_slope": "Find the slope at any point using derivatives. MathCalcu handles explicit, implicit, and parametric equations. It differentiates, substitutes the value, and gives you the slope, tangent line, and normal line.",
    "05_limits": "Evaluating limits is easy. MathCalcu supports four methods: substitution, factoring, least common denominator, and conjugate. It also handles limits at infinity for rational, radical, and trigonometric forms.",
    "06_more": "Beyond calculus, MathCalcu solves inequalities, circles, distance and midpoint problems, and slope intercept equations. A complete toolkit for math students.",
    "07_title": "Try MathCalcu today. Available on Android, iOS, Web, and Desktop. All computations run offline with no internet required.",
}

# Get available voices
def get_voice():
    resp = requests.get(f"{BASE_URL}/voices", headers={"xi-api-key": API_KEY})
    voices = resp.json()["voices"]
    # Use a clean, professional voice
    for v in voices:
        if "Rachel" in v["name"] or "Bella" in v["name"] or "Antoni" in v["name"]:
            return v["voice_id"]
    return voices[0]["voice_id"]

def generate_audio(text, voice_id, output_path):
    resp = requests.post(
        f"{BASE_URL}/text-to-speech/{voice_id}",
        headers={
            "xi-api-key": API_KEY,
            "Content-Type": "application/json",
        },
        json={
            "text": text,
            "model_id": "eleven_turbo_v2_5",
            "voice_settings": {
                "stability": 0.5,
                "similarity_boost": 0.75,
            },
        },
    )
    if resp.status_code == 200:
        with open(output_path, "wb") as f:
            f.write(resp.content)
        return True
    else:
        print(f"Error for {output_path}: {resp.status_code} - {resp.text[:200]}")
        return False

if __name__ == "__main__":
    voice_id = get_voice()
    print(f"Using voice: {voice_id}")
    
    for slide_name, text in narration.items():
        out = os.path.join(OUTPUT_DIR, f"{slide_name}.mp3")
        print(f"Generating: {slide_name}...")
        if generate_audio(text, voice_id, out):
            size = os.path.getsize(out) / 1024
            print(f"  OK ({size:.0f} KB)")
        else:
            print(f"  FAILED")
    
    print(f"\nAll narration files in {OUTPUT_DIR}")
