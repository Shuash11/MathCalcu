"""Generate narration for new v7 scenes + rename existing clips."""
import os, subprocess, requests

NARR_DIR = os.path.join(os.path.dirname(__file__), "narration_promo")
os.makedirs(NARR_DIR, exist_ok=True)

API_KEY = "sk_d3bee5ebdb0fc6d937c799d43e62efafff8d1ecfb308d1c0"
VOICE_ID = "pNInz6obpgDQGcFmaJgB"
BASE_URL = "https://api.elevenlabs.io/v1/text-to-speech"

# New narration text for v7 scenes
NEW_NARRATION = {
    "s04_keyboard": "Custom math keyboard. Every symbol you need, from pi and square root to trigonometric functions. Type expressions naturally with dedicated keys for sine, cosine, tangent, logarithms, and absolute value. Auto-solve as you type.",
    
    "s07_inequalities": "Eight types of inequalities. Strict and non-strict. Absolute value, continued, simple, rational, quadratic, and radical. Each type has its own solving algorithm with step-by-step breakdown.",
    
    "s09_graphing": "Real-time graphing powered by FL Chart. Plot circles, lines, and inequalities visually. See center points, radius, slope, and shaded regions. Interactive coordinate plane with axis labels.",
    
    "s10_stepbystep": "Every solution is broken down into numbered steps. Each step identifies the rule being applied, shows the intermediate work, and leads to the final answer. Nothing is skipped.",
    
    "s11_activation": "One-time activation. Enter your nine-character code given by your instructor. Course-specific access for authorized BSCS students only. Unlock all thirteen modules instantly.",
    
    "s12_theme": "Dark and light modes. Toggle between themes anytime. Your preference is saved and persists across sessions. Choose the look that works best for you.",
}

# Rename existing files for v7 scene order
RENAME_MAP = {
    "s07_geometry.mp3": "s08_geometry.mp3",
    "s08_offline.mp3": "s13_offline.mp3",
    "s10_platform.mp3": "s14_platform.mp3",
    "s11_cta.mp3": "s15_cta.mp3",
    "s12_close.mp3": "s16_close.mp3",
}

def generate_narration(text, output_path):
    """Generate TTS via ElevenLabs."""
    resp = requests.post(
        f"{BASE_URL}/{VOICE_ID}",
        headers={"xi-api-key": API_KEY, "Content-Type": "application/json"},
        json={"text": text, "model_id": "eleven_turbo_v2_5", "voice_settings": {
            "stability": 0.5, "similarity_boost": 0.75, "style": 0.3, "use_speaker_boost": True
        }}
    )
    if resp.status_code == 200:
        with open(output_path, "wb") as f:
            f.write(resp.content)
        return True
    else:
        print(f"  ERROR {resp.status_code}: {resp.text[:100]}")
        return False

print("=== Generating new narration clips ===")
for name, text in NEW_NARRATION.items():
    path = os.path.join(NARR_DIR, f"{name}.mp3")
    if os.path.exists(path):
        print(f"  {name}: already exists, skipping")
        continue
    print(f"  {name}: generating...", end=" ")
    if generate_narration(text, path):
        size = os.path.getsize(path) / 1024
        print(f"OK ({size:.0f} KB)")
    else:
        print("FAILED")

print("\n=== Renaming existing clips ===")
for old, new in RENAME_MAP.items():
    old_path = os.path.join(NARR_DIR, old)
    new_path = os.path.join(NARR_DIR, new)
    if os.path.exists(old_path) and not os.path.exists(new_path):
        os.rename(old_path, new_path)
        print(f"  {old} -> {new}")
    elif os.path.exists(new_path):
        print(f"  {new}: already exists, skipping")
    else:
        print(f"  {old}: not found, skipping")

print("\nDone!")
