"""Generate narration for all 9 segments from the official script."""
import os, requests

API_KEY = "sk_d3bee5ebdb0fc6d937c799d43e62efafff8d1ecfb308d1c0"
BASE_URL = "https://api.elevenlabs.io/v1"
OUT = os.path.join(os.path.dirname(__file__), "narration")
os.makedirs(OUT, exist_ok=True)

segments = {
    # Segment 1 - Cold Open / Hook
    "01_hook": "You have a calculus exam tomorrow... and you don't know how to find the derivative of sin of x squared plus natural log of cosine of x. What do you do? MathCalcu has entered the chat.",
    
    # Segment 2 - App Introduction
    "02_intro": "Meet MathCalcu. A Flutter-powered math solver built specifically for BSCS students. Whether you're dealing with derivatives, evaluating limits, graphing circles, or solving inequalities, this app has you covered. And the best part? It works completely offline. No Wi-Fi needed, no excuses. Eight powerful math modules. Built by BSCS students, for BSCS students.",
    
    # Segment 3 - Derivatives Tutorial
    "03_derivatives": "Let's start with the big one, derivatives. This is where MathCalcu really shines. Let me show you how to differentiate a composite function step by step. Open the Derivatives module. You'll see a clean input field, no complicated menus, no setup. Type your function in plain text, just like you'd type it in a search bar. You can use sin, cos, ln, e, x squared, all supported. Hit solve and watch the magic happen. Step one, the Problem Statement. MathCalcu clearly displays your original function. Step two, Identify the Rule. For this expression, it recognizes the Chain Rule and Sum Rule. It even shows the formula in beautiful LaTeX format. Step three, Apply Differentiation. It shows you exactly how the derivative is being computed, term by term. Step four, Simplification. And finally, the Final Answer. f prime of x equals, and there it is. Polynomial? Nailed it. Exponential? Done. Quotient? No problem.",
    
    # Segment 4 - Quiz Break 1
    "04_quiz1": "Alright, let's see if you were paying attention. Here's a quick math quiz. No calculators, or wait, actually you have MathCalcu so I can't stop you. Question one. What rule do you use to differentiate sin of x squared? A, Product Rule. B, Chain Rule. C, Quotient Rule. D, Power Rule. The answer is B, Chain Rule. Because sin of x squared is a composite function. The outer function is sin, the inner function is x squared. Question two. What is the derivative of e to the 2x? A, e to the 2x. B, 2 times e to the 2x. C, e to the 2x plus 2. D, 2x times e to the x. The answer is B, 2 times e to the 2x. By the Chain Rule, multiply by the derivative of the exponent, which is 2.",
    
    # Segment 5 - Limits Tutorial
    "05_limits": "Next up, limits. One of the most confusing topics in Calculus 1. But MathCalcu handles it four different ways. Substitution, Factoring, Least Common Denominator, and Conjugate Method. Let's start simple. Find the limit of x squared plus 3x as x approaches 2. Direct substitution, plug in x equals 2 and you're done. Easy. But what if you get 0 over 0? That's an indeterminate form, and that's where factoring comes in. The app factors the numerator, cancels the common term, and evaluates. No guessing, no shortcuts, real algebra. What about limits as x approaches infinity? MathCalcu handles rational, radical, and even trig forms. Divide everything by the highest power of x and you get 3. The app walks you through each step.",
    
    # Segment 6 - Analytic Geometry
    "06_geometry": "MathCalcu isn't just calculus. It also covers Analytic Geometry. Circles, distances, midpoints, slopes, all with graphing support. Let's say you need to find the center, radius, and standard form of a circle given in general form. Center, radius, both forms, all calculated instantly. And it even graphs it for you. Two points on a graph. What's the distance between them? What's the midpoint? Distance, 5 units. Midpoint, 2.5 comma 4. And here's the graph showing both points and the line connecting them. Need to find the equation of a line through two points? Or a parallel or perpendicular line? MathCalcu does that too. Slope is 2, equation is y equals 2x minus 1. Clean, fast, accurate. And for inequalities, linear, quadratic, rational, radical, absolute value, just type it in. Absolute value inequality solved, with the answer shown on a number line. That's clarity.",
    
    # Segment 7 - Quiz Break 2
    "07_quiz2": "Round two. These are a little trickier. Let's go. Question three. What is the center of the circle x minus 3 squared plus y plus 2 squared equals 16? A, 3 comma 2. B, negative 3 comma 2. C, 3 comma negative 2. D, negative 3 comma negative 2. The answer is C, 3 comma negative 2. The center is h comma k from the standard form. So h equals 3, k equals negative 2. Watch the sign on the k. Question four. The limit of x squared minus 4 over x minus 2 as x approaches 2 is? A, Undefined. B, 0. C, 2. D, 4. The answer is D, 4. Factor x squared minus 4 into x plus 2 times x minus 2. Cancel x minus 2. Substitute x equals 2 and you get 2 plus 2 equals 4.",
    
    # Segment 8 - Fun Facts
    "08_facts": "Before we wrap up, here are some quick facts about MathCalcu and about the math it solves. MathCalcu was built with Flutter, meaning one codebase runs on Android, iOS, Web, and Desktop. Did you know? The word derivative comes from the Latin derivare meaning to lead away from. In math, it describes how a function leads away from its value. MathCalcu uses LaTeX rendering, the same typesetting system used in academic research papers. The concept of a limit was developed in the 17th century by Newton and Leibniz, the same people who invented Calculus. The app works 100% offline. All 8 math modules, all solvers, all steps, no internet required. Analytic Geometry was invented by Rene Descartes in 1637. That's why coordinates are called Cartesian, after him.",
    
    # Segment 9 - CTA / Outro
    "09_outro": "MathCalcu, built by BSCS students who know the struggle. Derivatives, limits, analytic geometry, all solved, step by step, with LaTeX precision, completely offline. Whether you're reviewing for an exam, checking your homework, or just learning the concepts for the first time, this app has your back. Star the GitHub repo, share this video with your classmates, and drop a comment below with your quiz score. Math doesn't have to be hard. MathCalcu makes sure of that.",
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
    for name, text in segments.items():
        path = os.path.join(OUT, f"{name}.mp3")
        print(f"{name}: ", end="", flush=True)
        if generate(text, vid, path):
            sz = os.path.getsize(path)/1024
            print(f"OK ({sz:.0f} KB)")
        else:
            print("FAILED")
    print("Done!")
