"""Generate all v7 narration clips."""
import os, requests

NARR_DIR = os.path.join(os.path.dirname(__file__), "narration_promo")
os.makedirs(NARR_DIR, exist_ok=True)

API_KEY = "sk_d3bee5ebdb0fc6d937c799d43e62efafff8d1ecfb308d1c0"
VOICE_ID = "pNInz6obpgDQGcFmaJgB"
BASE_URL = "https://api.elevenlabs.io/v1/text-to-speech"

NARRATION = {
    "s01_hook": "MathCalcu. The math solver built for Bachelor of Science in Computer Science students.",
    "s02_problem": "Calculus problems got you stuck? Derivatives, limits, circles, inequalities. Your textbook isn't helping. There is a better way.",
    "s03_reveal": "Meet MathCalcu. Thirteen modules covering everything from midterms to finals. Built by BSCS students who understand the struggle.",
    "s04_keyboard": "Custom math keyboard with everything you need. Pi, square root, exponents. Sine, cosine, tangent. Logarithms, absolute value. Type naturally and get results as you go.",
    "s05_derivatives": "Derivatives module. Supports chain rule, product rule, quotient rule, power rule. All six trigonometric functions. Inverse trig, hyperbolic, logarithmic, and exponential. Every step shown with LaTeX rendering.",
    "s06_limits": "Evaluating limits. Four methods built in. Direct substitution. Factoring. Least common denominator. And conjugate multiplication. The app detects the right method automatically.",
    "s07_inequalities": "Eight types of inequalities. Strict, non strict, absolute value, continued, simple, rational, quadratic, and radical. Each type has its own solving algorithm.",
    "s08_geometry": "Circles module. Convert between standard form, general form, and center radius form. Input any equation and get center, radius, and all three forms. Distance, midpoint, slope, point slope, two point, y intercept, parallel and perpendicular lines.",
    "s09_graphing": "Real time graphing powered by FL Chart. Plot circles, lines, and inequalities. See shaded regions, center points, and slopes on an interactive coordinate plane.",
    "s10_stepbystep": "Every solution broken into numbered steps. Each step identifies the rule being applied. Intermediate work shown explicitly. Nothing skipped. Same format as academic research papers.",
    "s11_activation": "One time activation. Enter your nine character code from your instructor. Course specific access. All thirteen modules unlock instantly.",
    "s12_theme": "Dark and light modes. Toggle anytime. Your preference saves automatically. Choose what works best for you.",
    "s13_offline": "One hundred percent offline. No internet required. No API calls. No waiting. All computation runs on your device. Midterm and finals modules included.",
    "s14_platform": "Cross platform. Android, iOS, web, and desktop. One codebase built with Flutter. Write once, run anywhere.",
    "s15_cta": "MathCalcu. Built by BSCS students, for BSCS students. Thirteen modules. Step by step solutions. Graphing. LaTeX rendering. Star it on GitHub. Share with your classmates.",
    "s16_close": "Math doesn't have to be hard. MathCalcu makes it visual.",
}

for name, text in NARRATION.items():
    path = os.path.join(NARR_DIR, f"{name}.mp3")
    print(f"  {name}: ", end="")
    resp = requests.post(
        f"{BASE_URL}/{VOICE_ID}",
        headers={"xi-api-key": API_KEY, "Content-Type": "application/json"},
        json={"text": text, "model_id": "eleven_turbo_v2_5", "voice_settings": {
            "stability": 0.5, "similarity_boost": 0.75, "style": 0.3, "use_speaker_boost": True
        }}
    )
    if resp.status_code == 200:
        with open(path, "wb") as f:
            f.write(resp.content)
        print("OK")
    else:
        print(f"ERROR {resp.status_code}")

print("\nDone!")
