"""Generate persuasive narration for MathCalcu promo — no music needed."""
import os, requests

NARR_DIR = os.path.join(os.path.dirname(__file__), "narration_promo")
os.makedirs(NARR_DIR, exist_ok=True)

API_KEY = "sk_d3bee5ebdb0fc6d937c799d43e62efafff8d1ecfb308d1c0"
VOICE_ID = "pNInz6obpgDQGcFmaJgB"
BASE_URL = "https://api.elevenlabs.io/v1/text-to-speech"

NARRATION = {
    "s01_hook": "What if I told you there's an app that solves every calculus problem you'll face in your BSCS journey?",
    
    "s02_problem": "You're staring at your homework. Derivatives. Limits. Inequalities. Your textbook gives you the formula but not the understanding. You're stuck. And the exam is tomorrow.",
    
    "s03_reveal": "This is MathCalcu. Built by BSCS students, for BSCS students. Thirteen powerful modules that don't just give you the answer. They show you how to think.",
    
    "s04_keyboard": "Type any expression with a custom math keyboard. Pi. Square root. Sine. Cosine. Logarithms. Everything you need, right at your fingertips. No more fumbling with your phone's regular keyboard.",
    
    "s05_derivatives": "Derivatives? We've got you. Chain rule. Product rule. Quotient rule. Power rule. Every trigonometric function. Every inverse. Every hyperbolic. You type the problem. We show you every single step. With LaTeX rendered solutions that look like they came straight from a research paper.",
    
    "s06_limits": "Evaluating limits used to mean guessing which method to use. Not anymore. MathCalcu automatically detects whether you need substitution, factoring, least common denominator, or conjugate multiplication. Then walks you through it.",
    
    "s07_inequalities": "Eight types of inequalities. Strict. Non strict. Absolute value. Quadratic. Rational. Radical. Each one with its own solving algorithm. Each one broken down step by step.",
    
    "s08_geometry": "Circles. Distance. Midpoint. Slope. Point slope form. Two point form. Y intercept. Parallel and perpendicular lines. Every analytic geometry topic you need, with real-time graphing so you can see the math come alive.",
    
    "s09_graphing": "Watch your equations come to life. Plot circles. Draw lines. Shade inequality regions. See exactly where the center is. See exactly where the line crosses the axis. MathCalcu makes abstract concepts concrete.",
    
    "s10_stepbystep": "Every solution is broken into numbered steps. Each step tells you exactly which rule is being applied. Nothing is hidden. Nothing is skipped. You don't just get the answer. You understand why.",
    
    "s11_activation": "Getting started takes ten seconds. Enter the activation code from your instructor. That's it. All thirteen modules unlock instantly. No subscription. No in-app purchases. No hidden fees.",
    
    "s12_theme": "Dark mode for late night study sessions. Light mode for the classroom. Toggle anytime. Your preference saves automatically.",
    
    "s13_offline": "Here's the best part. MathCalcu works completely offline. No internet needed. No data collection. No tracking. Your math problems stay on your device. Study anywhere. Anytime. Even without Wi-Fi.",
    
    "s14_platform": "And it works everywhere. Android. iOS. Web. Desktop. One app. Every platform. Built with Flutter so it runs smooth on whatever device you have.",
    
    "s15_cta": "MathCalcu is open source on GitHub. Star it. Share it with your classmates. Because when one person gets better at math, the whole class gets better. Link in the description.",
    
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
