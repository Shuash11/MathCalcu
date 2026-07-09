"""Generate all narration clips for v7 and rebuild video with matched durations."""
import os, subprocess, requests, shutil, math
from PIL import Image, ImageDraw, ImageFont

BASE = os.path.dirname(__file__)
NARR_DIR = os.path.join(BASE, "narration_promo")
FRAMES_DIR = os.path.join(BASE, "promo_frames_v7")
os.makedirs(NARR_DIR, exist_ok=True)

API_KEY = "sk_d3bee5ebdb0fc6d937c799d43e62efafff8d1ecfb308d1c0"
VOICE_ID = "pNInz6obpgDQGcFmaJgB"
BASE_URL = "https://api.elevenlabs.io/v1/text-to-speech"
LOGO_PATH = os.path.join(BASE, "..", "assets", "images", "app_icon.png")

W, H = 1920, 1080
FPS = 30

# ═══════════════════════════════════════════════════════════════
# NARRATION TEXT — each scene gets a custom script
# ═══════════════════════════════════════════════════════════════
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

def generate_narration(text, output_path):
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
    print(f"  ERROR {resp.status_code}: {resp.text[:100]}")
    return False

def get_dur(path):
    r = subprocess.run(["ffprobe", "-v", "quiet", "-show_entries", "format=duration",
                       "-of", "default=noprint_wrappers=1:nokey=1", path],
                       capture_output=True, text=True)
    try: return float(r.stdout.strip())
    except: return 0

# ═══════════════════════════════════════════════════════════════
# STEP 1: Generate all narration clips
# ═══════════════════════════════════════════════════════════════
print("Step 1: Generating narration clips...")
for name, text in NARRATION.items():
    path = os.path.join(NARR_DIR, f"{name}.mp3")
    print(f"  {name}: ", end="")
    if generate_narration(text, path):
        dur = get_dur(path)
        print(f"OK ({dur:.1f}s)")
    else:
        print("FAILED")

# Get actual durations
print("\nNarration durations:")
scene_durs = {}
for name in NARRATION:
    path = os.path.join(NARR_DIR, f"{name}.mp3")
    if os.path.exists(path):
        dur = get_dur(path)
        scene_durs[name] = dur
        print(f"  {name}: {dur:.1f}s")

# ═══════════════════════════════════════════════════════════════
# STEP 2: Build video with MATCHED durations
# ═══════════════════════════════════════════════════════════════
print("\nStep 2: Building video frames...")

# Import all scene functions from build_promo_v7
import importlib.util
spec = importlib.util.spec_from_file_location("v7", os.path.join(BASE, "build_promo_v7.py"))
v7 = importlib.util.module_from_spec(spec)
spec.loader.exec_module(v7)

SCENE_LIST = [
    ("01_hook",          v7.scene_hook,          "s01_hook"),
    ("02_problem",       v7.scene_problem,       "s02_problem"),
    ("03_reveal",        v7.scene_app_reveal,    "s03_reveal"),
    ("04_keyboard",      v7.scene_keyboard,      "s04_keyboard"),
    ("05_derivatives",   v7.scene_derivatives,   "s05_derivatives"),
    ("06_limits",        v7.scene_limits,        "s06_limits"),
    ("07_inequalities",  v7.scene_inequalities,  "s07_inequalities"),
    ("08_geometry",      v7.scene_geometry,      "s08_geometry"),
    ("09_graphing",      v7.scene_graphing,      "s09_graphing"),
    ("10_stepbystep",    v7.scene_stepbystep,    "s10_stepbystep"),
    ("11_activation",    v7.scene_activation,    "s11_activation"),
    ("12_theme",         v7.scene_theme,         "s12_theme"),
    ("13_offline",       v7.scene_offline,       "s13_offline"),
    ("14_platform",      v7.scene_platform,      "s14_platform"),
    ("15_cta",           v7.scene_cta,           "s15_cta"),
    ("16_close",         v7.scene_close,         "s16_close"),
]

seg_files = []

for sname, sfunc, narr_key in SCENE_LIST:
    narr_dur = scene_durs.get(narr_key, 5)
    # Add 1.5s padding for breathing room
    dur = narr_dur + 1.5
    dur = max(dur, 3)  # minimum 3s
    
    print(f"  {sname}: narration={narr_dur:.1f}s, scene={dur:.1f}s", end="")
    
    nf = int(dur * FPS)
    sdir = os.path.join(FRAMES_DIR, sname)
    os.makedirs(sdir, exist_ok=True)
    
    for i in range(nf):
        frame = sfunc(f=i)
        if i < 4:
            frame = Image.blend(Image.new("RGB", (W, H)), frame, v7.ease(i / 4))
        elif i >= nf - 4:
            frame = Image.blend(Image.new("RGB", (W, H)), frame, v7.ease((nf - i) / 4))
        frame.save(os.path.join(sdir, f"frame_{i:06d}.png"))
    
    seg_mp4 = os.path.join(BASE, f"_seg_{sname}.mp4")
    narr_path = os.path.join(NARR_DIR, f"{narr_key}.mp3")
    
    if os.path.exists(narr_path):
        padded = os.path.join(BASE, f"_padded_{sname}.wav")
        actual_narr = get_dur(narr_path)
        silence = max(0, dur - actual_narr)
        subprocess.run(["ffmpeg", "-y", "-i", narr_path,
            "-f", "lavfi", "-i", f"anullsrc=r=44100:cl=stereo:d={silence}",
            "-filter_complex", "[0:a][1:a]concat=n=2:v=0:a=1[out]",
            "-map", "[out]", "-c:a", "pcm_s16le", padded], capture_output=True)
        cmd = ["ffmpeg", "-y", "-framerate", str(FPS),
               "-i", os.path.join(sdir, "frame_%06d.png"),
               "-i", padded, "-c:v", "libx264", "-t", str(dur),
               "-c:a", "aac", "-b:a", "192k",
               "-pix_fmt", "yuv420p", "-r", str(FPS), seg_mp4]
    else:
        cmd = ["ffmpeg", "-y", "-framerate", str(FPS),
               "-i", os.path.join(sdir, "frame_%06d.png"),
               "-f", "lavfi", "-i", "anullsrc=r=44100:cl=stereo",
               "-c:v", "libx264", "-t", str(dur),
               "-c:a", "aac", "-b:a", "128k",
               "-pix_fmt", "yuv420p", "-r", str(FPS), seg_mp4]
    
    r = subprocess.run(cmd, capture_output=True, text=True)
    actual = get_dur(seg_mp4) if r.returncode == 0 else 0
    seg_files.append(seg_mp4)
    print(f" -> {actual:.1f}s")

# Concat
print("\nConcatenating...")
cl = os.path.join(BASE, "_concat_v7b.txt")
with open(cl, "w") as f:
    for s in seg_files:
        f.write(f"file '{s}'\n")

concat_out = os.path.join(BASE, "mathcalcu_promo_v7b.mp4")
subprocess.run(["ffmpeg", "-y", "-f", "concat", "-safe", "0", "-i", cl,
    "-c:v", "libx264", "-c:a", "aac", "-b:a", "192k",
    "-pix_fmt", "yuv420p", "-movflags", "+faststart", concat_out], capture_output=True)

# Mix with music
print("Mixing music...")
music = os.path.join(BASE, "music", "elevenlabs_bg_looped.wav")
final = os.path.join(BASE, "mathcalcu_promo_final.mp4")
subprocess.run(["ffmpeg", "-y", "-i", concat_out, "-i", music,
    "-filter_complex", "[0:a]volume=1.0[vo];[1:a]volume=0.45[bg];[vo][bg]amix=inputs=2:duration=first:dropout_transition=0[a]",
    "-map", "0:v", "-map", "[a]", "-c:v", "copy", "-c:a", "aac", "-b:a", "192k",
    "-shortest", "-movflags", "+faststart", final], capture_output=True)

sz = os.path.getsize(final) / (1024 * 1024)
dur = get_dur(final)
print(f"\nDONE! {sz:.1f} MB, {dur:.1f}s")

# Cleanup
for s in seg_files:
    if os.path.exists(s): os.remove(s)
for sname, _, _ in SCENE_LIST:
    d = os.path.join(FRAMES_DIR, sname)
    if os.path.isdir(d): shutil.rmtree(d)
    p = os.path.join(BASE, f"_padded_{sname}.wav")
    if os.path.exists(p): os.remove(p)
if os.path.exists(cl): os.remove(cl)
if os.path.isdir(FRAMES_DIR): shutil.rmtree(FRAMES_DIR)
if os.path.exists(concat_out): os.remove(concat_out)

copy_to = os.path.join(os.path.expanduser("~"), "Downloads", "mathcalcu_promo_final.mp4")
shutil.copy2(final, copy_to)
print(f"Copied to {copy_to}")
