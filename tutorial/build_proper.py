"""Build MathCalcu tutorial using video-use proper workflow.

This script:
1. Creates overlay animation clips for each scene
2. Builds an EDL (Edit Decision List)
3. Uses render.py for proper composition with grades and audio fades
"""
import os, subprocess, json, math, random
from PIL import Image, ImageDraw, ImageFont

BASE = os.path.dirname(__file__)
OVERLAY_DIR = os.path.join(BASE, "overlays")
EDIT_DIR = os.path.join(BASE, "edit")
os.makedirs(OVERLAY_DIR, exist_ok=True)
os.makedirs(EDIT_DIR, exist_ok=True)

W, H, FPS = 1920, 1080, 30
VIDEO_USE = os.path.join(os.path.expanduser("~"), "video-use")
HELPERS = os.path.join(VIDEO_USE, "helpers")

# Theme
BG_DARK=(12,12,28); SURFACE=(22,22,50); CARD=(28,28,60); CARD2=(35,35,70)
CYAN=(0,220,255); PURPLE=(120,80,255); CORAL=(255,100,80); SKY=(100,200,255)
GOLD=(255,215,0); LIME=(100,255,100); MAGENTA=(255,50,150); WHITE=(255,255,255)
GRAY=(160,170,200); RED=(255,60,60)

LOGO_PATH = os.path.join(BASE, "..", "assets", "images", "app_icon.png")
LOGO = None
if os.path.exists(LOGO_PATH):
    try: LOGO = Image.open(LOGO_PATH).convert("RGBA").resize((200,200), Image.LANCZOS)
    except: pass

def gf(sz, b=False):
    p = "C:/Windows/Fonts/segoeuib.ttf" if b else "C:/Windows/Fonts/segoeui.ttf"
    try: return ImageFont.truetype(p, sz)
    except: return ImageFont.load_default()

def ease(t): return 1-(1-t)**3

def draw_logo(d, cx, cy, sz=100):
    if LOGO:
        logo = LOGO.resize((sz,sz), Image.LANCZOS)
        d._image.paste(logo, (cx-sz//2, cy-sz//2), logo)

def render_overlay(name, frames_func, duration_s, narration_path=None):
    """Render animation to overlay MP4 with alpha or black background."""
    out_path = os.path.join(OVERLAY_DIR, f"{name}.mp4")
    nf = int(duration_s * FPS)
    
    frames_dir = os.path.join(OVERLAY_DIR, f"{name}_frames")
    os.makedirs(frames_dir, exist_ok=True)
    
    for i in range(nf):
        frame = frames_func(f=i)
        frame.save(os.path.join(frames_dir, f"frame_{i:06d}.png"))
    
    cmd = ["ffmpeg", "-y", "-framerate", str(FPS), "-i", os.path.join(frames_dir, "frame_%06d.png")]
    if narration_path and os.path.exists(narration_path):
        cmd += ["-i", narration_path, "-c:v", "libx264", "-t", str(duration_s), "-c:a", "aac", "-b:a", "192k", "-shortest"]
    else:
        cmd += ["-c:v", "libx264", "-t", str(duration_s)]
    cmd += ["-pix_fmt", "yuv420p", "-r", str(FPS), out_path]
    
    r = subprocess.run(cmd, capture_output=True, text=True)
    
    # Cleanup frames
    import shutil
    shutil.rmtree(frames_dir, ignore_errors=True)
    
    return out_path if r.returncode == 0 else None

# ═══════════════════════════════════════════════════════
# SCENE GENERATORS
# ═══════════════════════════════════════════════════════

def gen_hook(f):
    img = Image.new("RGB", (W,H))
    d = ImageDraw.Draw(img)
    for y in range(H):
        t = y/H
        c = tuple(int(BG_DARK[i]*(1-t)+(25,15,55)[i]*t) for i in range(3))
        d.line([(0,y),(W,y)], fill=c)
    
    cx, cy = W//2, H//2
    if f < 30:
        d.text((cx, cy-40), "Tomorrow:", fill=GRAY, font=gf(36), anchor="mm")
        d.text((cx, cy+20), "MATH EXAM", fill=RED, font=gf(64,True), anchor="mm")
        d.text((cx, cy+100), "📚", fill=WHITE, font=gf(48), anchor="mm")
    elif f < 75:
        sz = int(28 + 16*ease(min(1,(f-30)/30)))
        d.text((cx, cy-30), "f(x) = sin(x²) + ln(cos(x))", fill=CORAL, font=gf(sz,True), anchor="mm")
        d.text((cx, cy+80), "Find the derivative...", fill=GRAY, font=gf(24), anchor="mm")
    elif f < 120:
        d.text((cx, cy), "😰", fill=WHITE, font=gf(120), anchor="mm")
        for i, (prob, ox, oy, c) in enumerate([("dy/dx = ?",-180,-60,GOLD),("lim ...",180,-40,MAGENTA),("∫ ... dx",-160,60,PURPLE)]):
            if f > 75+i*8:
                bx, by = cx+int(ox*ease(min(1,(f-75-i*8)/10))), cy+int(oy*ease(min(1,(f-75-i*8)/10)))
                d.rounded_rectangle([bx-70, by-15, bx+70, by+15], 8, fill=CARD, outline=c, width=2)
                d.text((bx, by), prob, fill=c, font=gf(15), anchor="mm")
    else:
        for i in range(40):
            random.seed(42)
            px = random.randint(0,W); py = (random.randint(0,H)+f*3)%(H+40)-20
            d.ellipse([px-4,py-4,px+4,py+4], fill=[CYAN,PURPLE,MAGENTA,LIME,GOLD,CORAL][i%6])
        b = ease(min(1,(f-120)/15))
        d.text((cx, cy-40), "MATHCALCU", fill=CYAN, font=gf(max(10,int(64*b)),True), anchor="mm")
        d.text((cx, cy+60), "HAS ENTERED THE CHAT", fill=WHITE, font=gf(32,True), anchor="mm")
        draw_logo(d, cx, cy-180, max(10,int(100*b)))
    return img

def gen_intro(f):
    img = Image.new("RGB", (W,H))
    d = ImageDraw.Draw(img)
    for y in range(H):
        t = y/H
        c = tuple(int(BG_DARK[i]*(1-t)+(25,15,55)[i]*t) for i in range(3))
        d.line([(0,y),(W,y)], fill=c)
    cx, cy = W//2, H//2
    if f > 5: d.text((cx, 50), "Meet MathCalcu", fill=WHITE, font=gf(48,True), anchor="mm")
    if f > 10: d.text((cx, 100), "Flutter-powered math solver", fill=CYAN, font=gf(20), anchor="mm")
    if f > 15:
        px, py, pw, ph = cx-220, 150, 440, 780
        d.rounded_rectangle([px+10,py+10,px+pw+10,py+ph+10], 30, fill=(0,0,0))
        d.rounded_rectangle([px,py,px+pw,py+ph], 30, fill=SURFACE, outline=CYAN, width=2)
        d.rounded_rectangle([px+15,py+40,px+pw-15,py+80], 8, fill=CYAN)
        d.text((px+pw//2, py+60), "MathCalcu", fill=WHITE, font=gf(20,True), anchor="mm")
        mods = [("Derivatives",CYAN),("Slope",LIME),("Limits",PURPLE),("∞ Limits",MAGENTA),("Ineq.",GOLD),("Circles",CORAL),("Distance",SKY),("Slope-Int",LIME)]
        for i,(n,c) in enumerate(mods):
            md = 20+i*5
            if f > md:
                r,c2 = divmod(i,2)
                mx,my = px+20+c2*200, py+100+r*100
                d.rounded_rectangle([mx,my,mx+180,my+80], 8, fill=CARD, outline=c, width=2)
                d.text((mx+90,my+30), n, fill=c, font=gf(14,True), anchor="mm")
    return img

def gen_derivatives(f):
    img = Image.new("RGB", (W,H))
    d = ImageDraw.Draw(img)
    for y in range(H):
        t = y/H
        c = tuple(int(BG_DARK[i]*(1-t)+(25,15,55)[i]*t) for i in range(3))
        d.line([(0,y),(W,y)], fill=c)
    cx, cy = W//2, H//2
    if f > 3: d.text((cx, 40), "Derivatives Made Easy", fill=WHITE, font=gf(42,True), anchor="mm")
    px, py, pw, ph = 120, 110, 420, 900
    d.rounded_rectangle([px+10,py+10,px+pw+10,py+ph+10], 30, fill=(0,0,0))
    d.rounded_rectangle([px,py,px+pw,py+ph], 30, fill=SURFACE, outline=PURPLE, width=2)
    d.rounded_rectangle([px+15,py+40,px+pw-15,py+80], 8, fill=PURPLE)
    d.text((px+pw//2, py+60), "Derivatives", fill=WHITE, font=gf(18,True), anchor="mm")
    d.rounded_rectangle([px+20,py+95,px+pw-20,py+140], 10, fill=CARD, outline=PURPLE, width=2)
    expr = "sin(x²) + ln(cos(x))"
    n = min(len(expr), f//2+1) if f<30 else len(expr)
    d.text((px+35, py+108), expr[:n], fill=WHITE, font=gf(16))
    if f > 35:
        d.rounded_rectangle([px+20,py+155,px+pw-20,py+225], 10, fill=CARD)
        d.text((px+35, py+168), "f'(x) =", fill=GRAY, font=gf(14))
        d.text((px+35, py+192), "2x·cos(x²) - tan(x)", fill=CYAN, font=gf(16,True))
    return img

def gen_quiz1(f):
    img = Image.new("RGB", (W,H))
    d = ImageDraw.Draw(img)
    for y in range(H):
        t = y/H
        c = tuple(int(BG_DARK[i]*(1-t)+(25,15,55)[i]*t) for i in range(3))
        d.line([(0,y),(W,y)], fill=c)
    cx, cy = W//2, H//2
    for i in range(30):
        random.seed(42)
        px = random.randint(0,W); py = (random.randint(0,H)+f*3)%(H+40)-20
        d.ellipse([px-4,py-4,px+4,py+4], fill=[CYAN,PURPLE,MAGENTA,LIME,GOLD,CORAL][i%6])
    d.text((cx, 50), "⚡ QUIZ BREAK ⚡", fill=GOLD, font=gf(48,True), anchor="mm")
    if f > 15:
        d.rounded_rectangle([cx-400,120,cx+400,350], 14, fill=CARD, outline=CORAL, width=3)
        d.text((cx, 150), "Q1: What rule for sin(x²)?", fill=WHITE, font=gf(24,True), anchor="mm")
        for i,(o,c) in enumerate([("A) Product",CORAL),("B) Chain",LIME),("C) Quotient",GOLD),("D) Power",SKY)]):
            d.text((cx-350+(i%2)*370, 200+(i//2)*55), o, fill=c, font=gf(18))
    if f > 60:
        d.rounded_rectangle([cx-150,310,cx+150,350], 8, fill=LIME)
        d.text((cx,330), "B) Chain Rule!", fill=WHITE, font=gf(20,True), anchor="mm")
    return img

def gen_limits(f):
    img = Image.new("RGB", (W,H))
    d = ImageDraw.Draw(img)
    for y in range(H):
        t = y/H
        c = tuple(int(BG_DARK[i]*(1-t)+(25,15,55)[i]*t) for i in range(3))
        d.line([(0,y),(W,y)], fill=c)
    cx, cy = W//2, H//2
    if f > 3: d.text((cx, 40), "Evaluating Limits", fill=WHITE, font=gf(42,True), anchor="mm")
    methods = [("1 Substitution",CYAN),("2 Factoring",LIME),("3 LCD",GOLD),("4 Conjugate",CORAL)]
    for i,(m,c) in enumerate(methods):
        md = 10+i*5
        if f > md:
            p = min(1,(f-md)/8)
            sl = int(20*(1-ease(p)))
            mx = 100+i*420
            d.rounded_rectangle([mx+sl,100,mx+380+sl,150], 8, fill=CARD, outline=c, width=2)
            d.text((mx+190+sl,125), m, fill=c, font=gf(18,True), anchor="mm")
    if f > 40:
        d.rounded_rectangle([150,180,600,320], 10, fill=CARD, outline=CYAN, width=2)
        d.text((170,200), "lim(x→2) x²+3x", fill=WHITE, font=gf(16,True))
        d.text((170,240), "= 4+6 = 10", fill=LIME, font=gf(16,True))
    return img

def gen_geometry(f):
    img = Image.new("RGB", (W,H))
    d = ImageDraw.Draw(img)
    for y in range(H):
        t = y/H
        c = tuple(int(BG_DARK[i]*(1-t)+(25,15,55)[i]*t) for i in range(3))
        d.line([(0,y),(W,y)], fill=c)
    cx, cy = W//2, H//2
    if f > 3: d.text((cx, 40), "📐 Analytic Geometry", fill=WHITE, font=gf(42,True), anchor="mm")
    if f > 15:
        d.rounded_rectangle([80,110,600,330], 10, fill=CARD, outline=CORAL, width=2)
        d.text((340,130), "⭕ Circles", fill=CORAL, font=gf(22,True), anchor="mm")
        d.text((100,170), "x²+y²-6x+4y-3=0", fill=WHITE, font=gf(14))
        d.text((100,200), "Center: (3, -2)  Radius: 4", fill=LIME, font=gf(16,True))
    if f > 50:
        d.rounded_rectangle([620,110,1140,330], 10, fill=CARD, outline=SKY, width=2)
        d.text((880,130), "📏 Distance & Midpoint", fill=SKY, font=gf(22,True), anchor="mm")
        d.text((640,170), "A(1,2)  B(4,6)", fill=WHITE, font=gf(14))
        d.text((640,200), "Distance: 5  Midpoint: (2.5,4)", fill=LIME, font=gf(16,True))
    return img

def gen_quiz2(f):
    img = Image.new("RGB", (W,H))
    d = ImageDraw.Draw(img)
    for y in range(H):
        t = y/H
        c = tuple(int(BG_DARK[i]*(1-t)+(25,15,55)[i]*t) for i in range(3))
        d.line([(0,y),(W,y)], fill=c)
    cx, cy = W//2, H//2
    for i in range(30):
        random.seed(42)
        px = random.randint(0,W); py = (random.randint(0,H)+f*3)%(H+40)-20
        d.ellipse([px-4,py-4,px+4,py+4], fill=[CYAN,PURPLE,MAGENTA,LIME,GOLD,CORAL][i%6])
    d.text((cx, 50), "⚡ QUIZ #2 ⚡", fill=GOLD, font=gf(48,True), anchor="mm")
    if f > 15:
        d.rounded_rectangle([cx-400,120,cx+400,350], 14, fill=CARD, outline=CORAL, width=3)
        d.text((cx, 150), "Q3: Center of (x-3)²+(y+2)²=16?", fill=WHITE, font=gf(22,True), anchor="mm")
    return img

def gen_facts(f):
    img = Image.new("RGB", (W,H))
    d = ImageDraw.Draw(img)
    for y in range(H):
        t = y/H
        c = tuple(int(BG_DARK[i]*(1-t)+(25,15,55)[i]*t) for i in range(3))
        d.line([(0,y),(W,y)], fill=c)
    cx, cy = W//2, H//2
    d.text((cx, 40), "💡 Fun Facts", fill=GOLD, font=gf(42,True), anchor="mm")
    facts = [
        ("Built with Flutter","One codebase → Android, iOS, Web, Desktop",CYAN),
        ("Derivative","Latin derivare - to lead away from",CORAL),
        ("LaTeX Rendering","Same system used in academic papers",PURPLE),
        ("Limits","Newton and Leibniz, 17th century",LIME),
        ("100% Offline","All 8 modules, no internet needed",GOLD),
        ("Analytic Geometry","Descartes 1637 - Cartesian coordinates",SKY),
    ]
    for i,(t,desc,c) in enumerate(facts):
        fd=15+i*25
        if f>fd:
            fy=110+i*120
            d.rounded_rectangle([cx-350,fy,cx+350,fy+100], 12, fill=CARD, outline=c, width=2)
            d.text((cx-320,fy+12),t,fill=c,font=gf(20,True))
            d.text((cx-320,fy+48),desc,fill=GRAY,font=gf(15))
    return img

def gen_outro(f):
    img = Image.new("RGB", (W,H))
    d = ImageDraw.Draw(img)
    for y in range(H):
        t = y/H
        c = tuple(int(BG_DARK[i]*(1-t)+(25,15,55)[i]*t) for i in range(3))
        d.line([(0,y),(W,y)], fill=c)
    cx, cy = W//2, H//2
    for i in range(50):
        random.seed(42)
        px = random.randint(0,W); py = (random.randint(0,H)+f*3)%(H+40)-20
        d.ellipse([px-5,py-5,px+5,py+5], fill=[CYAN,PURPLE,MAGENTA,LIME,GOLD,CORAL][i%6])
    draw_logo(d, cx, cy-200, max(10,int(120+10*math.sin(f*0.1))))
    d.text((cx, cy-80), "MathCalcu", fill=WHITE, font=gf(64,True), anchor="mm")
    d.text((cx, cy-10), "Built by BSCS students", fill=CYAN, font=gf(22), anchor="mm")
    if f>40: d.text((cx, cy+150), "⭐ Star us on GitHub", fill=GOLD, font=gf(24,True), anchor="mm")
    if f>50: d.text((cx, cy+190), "github.com/Shuash11/MathCalcu", fill=GRAY, font=gf(18), anchor="mm")
    if f>75:
        d.text((cx, cy+290), "Math does not have to be hard.", fill=GRAY, font=gf(22), anchor="mm")
        d.text((cx, cy+325), "MathCalcu makes sure of that.", fill=CYAN, font=gf(24,True), anchor="mm")
    return img

# ═══════════════════════════════════════════════════════
# BUILD ALL OVERLAYS
# ═══════════════════════════════════════════════════════

NARR_DIR = os.path.join(BASE, "narration")
def get_dur(path):
    r = subprocess.run(["ffprobe","-v","quiet","-print_format","json","-show_format",path], capture_output=True, text=True)
    return float(json.loads(r.stdout)["format"]["duration"])

scenes = [
    ("01_hook", gen_hook),
    ("02_intro", gen_intro),
    ("03_derivatives", gen_derivatives),
    ("04_quiz1", gen_quiz1),
    ("05_limits", gen_limits),
    ("06_geometry", gen_geometry),
    ("07_quiz2", gen_quiz2),
    ("08_facts", gen_facts),
    ("09_outro", gen_outro),
]

print("Building overlay clips...")
clips = []
for name, gen_func in scenes:
    apath = os.path.join(NARR_DIR, f"{name}.mp3")
    dur = get_dur(apath) if os.path.exists(apath) else 5.0
    print(f"  {name}: {dur:.1f}s")
    out = render_overlay(name, gen_func, dur+1.0, apath)
    if out:
        clips.append({"name": name, "path": out, "duration": dur+1.0})
        print(f"    OK")
    else:
        print(f"    FAILED")

# ═══════════════════════════════════════════════════════
# BUILD EDL
# ═══════════════════════════════════════════════════════

print("\nBuilding EDL...")
edl = {
    "version": 1,
    "sources": {},
    "ranges": [],
    "grade": "none",
    "overlays": [],
    "total_duration_s": 0
}

offset = 0
for clip in clips:
    edl["sources"][clip["name"]] = clip["path"]
    edl["ranges"].append({
        "source": clip["name"],
        "start": 0,
        "end": clip["duration"],
        "beat": clip["name"],
        "quote": "",
        "reason": "Scene segment"
    })
    edl["total_duration_s"] += clip["duration"]
    offset += clip["duration"]

edl_path = os.path.join(EDIT_DIR, "edl.json")
with open(edl_path, "w") as f:
    json.dump(edl, f, indent=2)

print(f"EDL saved: {edl_path}")
print(f"Total duration: {edl['total_duration_s']:.1f}s")

# ═══════════════════════════════════════════════════════
# USE RENDER.PY
# ═══════════════════════════════════════════════════════

print("\nComposing with render.py...")
output = os.path.join(BASE, "mathcalcu_tutorial.mp4")
cmd = [
    sys.executable if hasattr(sys, 'executable') else 'python',
    os.path.join(HELPERS, "render.py"),
    edl_path,
    "-o", output,
    "--no-subtitles"
]

r = subprocess.run(cmd, capture_output=True, text=True)
if r.returncode == 0:
    sz = os.path.getsize(output)/(1024*1024)
    print(f"\nDONE! {sz:.1f} MB")
else:
    print(f"render.py failed, falling back to manual concat...")
    # Fallback: manual concat with ffmpeg
    cl_path = os.path.join(BASE, "_cl.txt")
    with open(cl_path, "w") as f:
        for clip in clips:
            f.write(f"file '{clip['path']}'\n")
    subprocess.run(["ffmpeg", "-y", "-f", "concat", "-safe", "0", "-i", cl_path,
                    "-c:v", "libx264", "-c:a", "aac", "-b:a", "192k",
                    "-pix_fmt", "yuv420p", "-movflags", "+faststart", output])
    os.remove(cl_path)
    sz = os.path.getsize(output)/(1024*1024)
    print(f"\nDONE (fallback)! {sz:.1f} MB")

# Cleanup
for clip in clips:
    if os.path.exists(clip["path"]):
        os.remove(clip["path"])
