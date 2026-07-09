"""Generate narration with midterm + final info."""
import os, requests

API_KEY = "sk_d3bee5ebdb0fc6d937c799d43e62efafff8d1ecfb308d1c0"
BASE_URL = "https://api.elevenlabs.io/v1"
OUT = os.path.join(os.path.dirname(__file__), "narration")
os.makedirs(OUT, exist_ok=True)

scenes = {
    "01_title": "MathCalcu. The smartest way to learn math. Built for both midterm and final exams. Step by step solutions that actually make sense. Works completely offline. And it's free.",
    
    "02_pain": "Struggling with calculus? Confused by derivatives, limits, and slopes? Whether it's midterm or final week, MathCalcu has you covered.",
    
    "03_solution": "Meet MathCalcu. Enter any function, tap solve, and get the full step by step solution. Covers all midterm topics: derivatives, limits, and slope. Plus all final topics: inequalities, circles, distance, and midpoint. Works offline. And it's completely free.",
    
    "04_derivatives": "Let's try a real example. Enter sine of x squared plus natural log of cosine of x. MathCalcu applies the chain rule, simplifies, and gives you the answer. It supports power rule, product rule, quotient rule, chain rule, all six trig functions, logarithms, exponentials, inverse trig, and hyperbolic functions. Everything you need for both midterm and finals.",
    
    "05_slope_limits": "Need to find slope at a point? MathCalcu handles explicit, implicit, and parametric equations. Just enter the function and the x value. For limits, choose from substitution, factoring, least common denominator, or conjugate. It also handles limits at infinity. Plus inequalities, circles, distance, and midpoint for your final exam.",
    
    "06_cta": "Start solving today. Available on Android, iOS, web, and desktop. Covers midterm and final topics. Over six topics. One hundred percent offline. Free forever.",
}

def get_voice():
    r = requests.get(f"{BASE_URL}/voices", headers={"xi-api-key": API_KEY})
    for v in r.json()["voices"]:
        if "Rachel" in v["name"] or "Bella" in v["name"] or "Antoni" in v["name"]:
            return v["voice_id"]
    return r.json()["voices"][0]["voice_id"]

def generate(text, voice_id, path):
    r = requests.post(
        f"{BASE_URL}/text-to-speech/{voice_id}",
        headers={"xi-api-key": API_KEY, "Content-Type": "application/json"},
        json={"text": text, "model_id": "eleven_turbo_v2_5",
              "voice_settings": {"stability": 0.5, "similarity_boost": 0.75}},
    )
    if r.status_code == 200:
        with open(path, "wb") as f: f.write(r.content)
        return True
    print(f"  Error {r.status_code}: {r.text[:200]}")
    return False

if __name__ == "__main__":
    vid = get_voice()
    print(f"Voice: {vid}")
    for name, text in scenes.items():
        path = os.path.join(OUT, f"{name}.mp3")
        print(f"{name}: ", end="", flush=True)
        if generate(text, vid, path):
            sz = os.path.getsize(path)/1024
            print(f"OK ({sz:.0f} KB)")
        else:
            print("FAILED")
    print("Done!")
