"""MathCalcu tutorial v5 — Full 9-segment video from official script."""
import os, subprocess, json, math, shutil, random
from PIL import Image, ImageDraw, ImageFont

BASE = os.path.dirname(__file__)
FRAMES_DIR = os.path.join(BASE, "frames")
NARRATION_DIR = os.path.join(BASE, "narration")
OUTPUT = os.path.join(BASE, "mathcalcu_tutorial.mp4")
LOGO_PATH = os.path.join(BASE, "..", "assets", "images", "app_icon.png")
os.makedirs(FRAMES_DIR, exist_ok=True)

W, H = 1920, 1080
FPS = 30

# ── Theme ──
BG_DARK = (12, 12, 28); BG_MID = (18, 18, 42); SURFACE = (22, 22, 50)
CARD = (28, 28, 60); CARD2 = (35, 35, 70)
CYAN = (0, 220, 255); PURPLE = (120, 80, 255); PURPLE_LIGHT = (170, 130, 255)
TEAL = (0, 200, 220); MAGENTA = (255, 50, 150); LIME = (100, 255, 100)
CORAL = (255, 100, 80); SKY = (100, 200, 255); GOLD = (255, 215, 0)
MINT = (0, 255, 180); WHITE = (255, 255, 255); GRAY = (160, 170, 200)
RED = (255, 60, 60); GREEN = (0, 220, 100)

LOGO = None
if os.path.exists(LOGO_PATH):
    try: LOGO = Image.open(LOGO_PATH).convert("RGBA").resize((200, 200), Image.LANCZOS)
    except: pass

def gf(size, bold=False):
    for p in ["C:/Windows/Fonts/segoeuib.ttf" if bold else "C:/Windows/Fonts/segoeui.ttf",
              "C:/Windows/Fonts/arialbd.ttf" if bold else "C:/Windows/Fonts/arial.ttf"]:
        if os.path.exists(p):
            try: return ImageFont.truetype(p, size)
            except: pass
    return ImageFont.load_default()

def gradient_fun(draw, c1=BG_DARK, c2=(25, 15, 55), c3=(10, 30, 50)):
    for y in range(H):
        t = y/H
        if t < 0.5: c = tuple(int(c1[i]*(1-t*2)+c2[i]*(t*2)) for i in range(3))
        else: c = tuple(int(c2[i]*(1-(t-0.5)*2)+c3[i]*((t-0.5)*2)) for i in range(3))
        draw.line([(0,y),(W,y)], fill=c)

def gradient_dark(draw):
    for y in range(H):
        t = y/H
        c = tuple(int(BG_DARK[i]*(1-t)+BG_MID[i]*t) for i in range(3))
        draw.line([(0,y),(W,y)], fill=c)

def rrect(draw, xy, r, fill, outline=None, w=2):
    x0,y0,x1,y1 = xy
    draw.rectangle([x0+r,y0,x1-r,y1], fill=fill)
    draw.rectangle([x0,y0+r,x1,y1-r], fill=fill)
    for cx,cy,sa,ea in [(x0,y0,180,270),(x1-2*r,y0,270,360),(x0,y1-2*r,90,180),(x1-2*r,y1-2*r,0,90)]:
        draw.pieslice([cx,cy,cx+2*r,cy+2*r], sa, ea, fill=fill)
    if outline: draw.rounded_rectangle(xy, r, outline=outline, width=w)

def ease(t): return 1-(1-t)**3
def ease_back(t):
    c1=1.70158; c3=c1+1; return 1+c3*(t-1)**3+c1*(t-1)**2
def ease_bounce(t):
    if t<1/2.75: return 7.5625*t*t
    elif t<2/2.75: t-=1.5/2.75; return 7.5625*t*t+0.75
    elif t<2.5/2.75: t-=2.25/2.75; return 7.5625*t*t+0.9375
    else: t-=2.625/2.75; return 7.5625*t*t+0.984375
def lerp(a,b,t): return a+(b-a)*t

def draw_confetti(d, f, count=30):
    random.seed(42)
    for i in range(count):
        x = random.randint(0, W)
        y = (random.randint(0, H) + f * (2 + i%3)) % (H + 40) - 20
        colors = [CYAN, PURPLE, MAGENTA, LIME, GOLD, CORAL, SKY, MINT]
        c = colors[i % len(colors)]
        sz = random.randint(4, 12)
        d.ellipse([x-sz, y-sz, x+sz, y+sz], fill=c)

def draw_stars(d, f, count=15):
    random.seed(99)
    for i in range(count):
        x = random.randint(50, W-50)
        y = random.randint(50, H-50)
        phase = f*0.1 + i*0.5
        brightness = int(40 + 30*math.sin(phase))
        sz = int(3 + 2*math.sin(phase))
        d.ellipse([x-sz, y-sz, x+sz, y+sz], fill=(brightness, brightness, brightness+20))

def draw_logo(d, cx, cy, size=100):
    if LOGO:
        logo = LOGO.resize((size, size), Image.LANCZOS)
        d._image.paste(logo, (cx - size//2, cy - size//2), logo)
    else:
        rrect(d, [cx-50, cy-50, cx+50, cy+50], 15, CYAN)
        d.text((cx, cy), "∫", fill=WHITE, font=gf(60,True), anchor="mm")

def draw_student_fun(draw, x, y, s=1.0, pose="stand", f=0, shirt_color=CYAN):
    skin=(255,220,180); hair=(50,35,25); shirt=shirt_color; pants=(40,40,70); shoes=(35,35,35); eye=(25,25,25); cheek=(255,140,140)
    wb = math.sin(f*0.3)*4*s if pose=="walk" else 0
    ww = math.sin(f*0.4)*14 if pose=="wave" else 0
    cy = y+wb
    if pose=="walk": la1=math.sin(f*0.3)*20; la2=-la1
    else: la1=la2=0
    for lx,la in [(-8*s,la1),(8*s,la2)]:
        ex=x+lx+math.sin(math.radians(la))*10*s
        draw.line([(x+lx,cy+30*s),(ex,cy+52*s)], fill=pants, width=int(6*s))
        draw.ellipse([ex-4*s,cy+50*s,ex+4*s,cy+56*s], fill=shoes)
    rrect(draw, [x-12*s,cy-5*s,x+12*s,cy+32*s], int(6*s), shirt)
    if pose=="point":
        draw.line([(x+12*s,cy+5*s),(x+32*s,cy-8*s)], fill=shirt, width=int(5*s))
        draw.ellipse([x+30*s-3*s,cy-11*s,x+30*s+5*s,cy-5*s], fill=skin)
        draw.line([(x-12*s,cy+5*s),(x-16*s,cy+20*s)], fill=shirt, width=int(5*s))
    elif pose=="think":
        draw.line([(x+12*s,cy+5*s),(x+14*s,cy-16*s)], fill=shirt, width=int(5*s))
        draw.ellipse([x+11*s,cy-20*s,x+17*s,cy-14*s], fill=skin)
        draw.line([(x-12*s,cy+5*s),(x-16*s,cy+20*s)], fill=shirt, width=int(5*s))
    elif pose=="excited":
        for dx in [-1,1]:
            draw.line([(x+dx*12*s,cy+5*s),(x+dx*24*s,cy-22*s)], fill=shirt, width=int(5*s))
            draw.ellipse([x+dx*22*s-3*s,cy-26*s,x+dx*22*s+5*s,cy-20*s], fill=skin)
    elif pose=="wave":
        draw.line([(x+12*s,cy+5*s),(x+24*s,cy+ww-12*s)], fill=shirt, width=int(5*s))
        draw.ellipse([x+21*s,cy+ww-16*s,x+27*s,cy+ww-10*s], fill=skin)
        draw.line([(x-12*s,cy+5*s),(x-16*s,cy+20*s)], fill=shirt, width=int(5*s))
    else:
        draw.line([(x+12*s,cy+5*s),(x+16*s,cy+20*s)], fill=shirt, width=int(5*s))
        draw.line([(x-12*s,cy+5*s),(x-16*s,cy+20*s)], fill=shirt, width=int(5*s))
    draw.ellipse([x-14*s,cy-35*s,x+14*s,cy-5*s], fill=skin)
    draw.arc([x-15*s,cy-40*s,x+15*s,cy-15*s], 180, 360, fill=hair, width=int(8*s))
    draw.ellipse([x-15*s,cy-38*s,x+15*s,cy-25*s], fill=hair)
    ey=cy-22*s
    if pose=="excited":
        draw.arc([x-9*s,ey-3*s,x-3*s,ey+3*s], 200, 340, fill=eye, width=int(2*s))
        draw.arc([x+3*s,ey-3*s,x+9*s,ey+3*s], 200, 340, fill=eye, width=int(2*s))
    elif pose=="think":
        draw.ellipse([x-8*s,ey-2*s,x-4*s,ey+2*s], fill=eye)
        draw.ellipse([x+4*s,ey-4*s,x+8*s,ey], fill=eye)
    else:
        for dx in [-6,6]:
            draw.ellipse([x+dx*s-2*s,ey-2*s,x+dx*s+2*s,ey+2*s], fill=eye)
            draw.ellipse([x+dx*s-1*s,ey-1*s,x+dx*s+1*s,ey+1*s], fill=WHITE)
    draw.ellipse([x-13*s,ey+4*s,x-7*s,ey+8*s], fill=cheek)
    draw.ellipse([x+7*s,ey+4*s,x+13*s,ey+8*s], fill=cheek)
    if pose=="excited": draw.arc([x-4*s,cy-16*s,x+4*s,cy-10*s], 0, 180, fill=eye, width=int(2*s))
    elif pose=="think": draw.ellipse([x-2*s,cy-14*s,x+2*s,cy-12*s], fill=eye)
    else: draw.arc([x-4*s,cy-17*s,x+4*s,cy-12*s], 0, 180, fill=eye, width=int(2*s))
    if pose in ["think","point"]:
        rrect(draw, [x-11*s,ey-4*s,x-1*s,ey+4*s], int(2*s), fill=SURFACE, outline=GRAY, w=int(1.5*s))
        rrect(draw, [x+1*s,ey-4*s,x+11*s,ey+4*s], int(2*s), fill=SURFACE, outline=GRAY, w=int(1.5*s))
        draw.line([(x-1*s,ey),(x+1*s,ey)], fill=GRAY, width=int(1*s))

def draw_phone_fun(draw, px, py, pw, ph, accent=CYAN):
    for i in range(12):
        draw.rounded_rectangle([px+i+2, py+i+2, px+pw+i+2, py+ph+i+2], 30, fill=(0,0,0))
    rrect(draw, [px,py,px+pw,py+ph], 30, SURFACE, outline=accent, w=2)
    rrect(draw, [px+pw//2-50, py+8, px+pw//2+50, py+28], 10, (8,8,18))

# ═══════════════════════════════════════════════════════
# SEGMENT 1 — COLD OPEN / HOOK
# ═══════════════════════════════════════════════════════
def scene_hook(f):
    img = Image.new("RGB", (W,H)); d = ImageDraw.Draw(img)
    cx, cy = W//2, H//2
    
    if f < 60:
        # Black screen with ticking text
        gradient_dark(d)
        draw_stars(d, f, 10)
        t = min(1.0, f/30)
        d.text((cx, cy-40), "Tomorrow:", fill=GRAY, font=gf(36), anchor="mm")
        d.text((cx, cy+20), "MATH EXAM", fill=RED, font=gf(64,True), anchor="mm")
        d.text((cx, cy+100), "📚", fill=WHITE, font=gf(48), anchor="mm")
    elif f < 120:
        # Scary equation zoom
        gradient_dark(d)
        draw_stars(d, f, 10)
        phase = (f-60)/60
        sz = int(28 + 16*ease(phase))
        d.text((cx, cy-30), "f(x) = sin(x²) + ln(cos(x))", fill=CORAL, font=gf(sz,True), anchor="mm")
        d.text((cx, cy+80), "Find the derivative...", fill=GRAY, font=gf(24), anchor="mm")
    elif f < 210:
        # Stressed student + problem bubbles
        gradient_fun(d, (25,10,25), (35,15,40), (20,8,30))
        draw_stars(d, f, 12)
        draw_student_fun(d, cx, cy-20, s=2.5, pose="think", f=f, shirt_color=PURPLE)
        problems = [("f(x) = x³·sin(x²)", -200, -80, CORAL), ("dy/dx = ?", 200, -60, GOLD),
                     ("lim(x→∞) ...", -180, 70, MAGENTA), ("∫ ... dx", 220, 90, PURPLE_LIGHT)]
        for i, (prob, ox, oy, color) in enumerate(problems):
            delay = 15 + i*10
            if f > 60+delay:
                p = min(1.0, (f-60-delay)/12)
                bx, by = cx+int(ox*ease(p)), cy+int(oy*ease(p))
                rrect(d, [bx-80, by-18, bx+80, by+18], 10, CARD, outline=color, w=2)
                d.text((bx, by), prob, fill=color, font=gf(16), anchor="mm")
    else:
        # MATHCALCU HAS ENTERED THE CHAT
        gradient_fun(d, (10,15,40), (20,10,50), (5,20,45))
        draw_confetti(d, f-210, 50)
        phase = min(1.0, (f-210)/20)
        b = ease_back(phase)
        sz = int(64 * b)
        d.text((cx, cy-40), "MATHCALCU", fill=CYAN, font=gf(sz,True), anchor="mm")
        d.text((cx, cy+60), "HAS ENTERED THE CHAT", fill=WHITE, font=gf(32,True), anchor="mm")
        draw_logo(d, cx, cy-180, max(10, int(100*b)))
    
    return img

# ═══════════════════════════════════════════════════════
# SEGMENT 2 — APP INTRODUCTION
# ═══════════════════════════════════════════════════════
def scene_intro(f):
    img = Image.new("RGB", (W,H)); d = ImageDraw.Draw(img); gradient_fun(d)
    draw_stars(d, f, 15)
    cx, cy = W//2, H//2
    
    # Title
    if f > 10:
        d.text((cx, 60), "Meet MathCalcu", fill=WHITE, font=gf(48,True), anchor="mm")
        d.text((cx, 110), "Flutter-powered math solver for BSCS students", fill=CYAN, font=gf(22), anchor="mm")
    
    # Phone with home screen
    if f > 20:
        px, py, pw, ph = cx-220, 160, 440, 780
        draw_phone_fun(d, px, py, pw, ph, CYAN)
        rrect(d, [px+15, py+40, px+pw-15, py+80], 8, CYAN)
        d.text((px+pw//2, py+60), "MathCalcu", fill=WHITE, font=gf(20,True), anchor="mm")
        
        # Module icons pop in
        modules = [("Derivatives",CYAN),("Slope",LIME),("Limits",PURPLE),("Limits ∞",MAGENTA),
                    ("Inequalities",GOLD),("Circles",CORAL),("Distance",SKY),("Slope-Int",MINT)]
        for i, (name, color) in enumerate(modules):
            md = 30 + i*6
            if f > md:
                row, col = divmod(i, 2)
                mx = px+20+col*200
                my = py+100+row*100
                p = min(1.0, (f-md)/10)
                sc = ease_back(p)
                rrect(d, [mx, my, mx+180, my+80], 10, CARD, outline=color, w=2)
                d.text((mx+90, my+30), name, fill=color, font=gf(14,True), anchor="mm")
        
        # Features overlay
        if f > 90:
            rrect(d, [px+20, py+ph-100, px+pw-20, py+ph-40], 8, CARD2)
            d.text((px+pw//2, py+ph-70), "100% Offline | Step-by-Step | LaTeX", fill=CYAN, font=gf(14,True), anchor="mm")
    
    # Right side benefits
    rx = cx + 280
    if f > 40:
        d.text((rx, 180), "8 Powerful Modules", fill=WHITE, font=gf(28,True))
        items = [("📐 Derivatives",CYAN),("📈 Slope",LIME),("∞ Limits",PURPLE),("⚖️ Inequalities",GOLD),
                  ("⭕ Circles",CORAL),("📏 Distance",SKY),("➖ Slope-Intercept",MINT)]
        for i, (item, color) in enumerate(items):
            id = 50 + i*5
            if f > id:
                p = min(1.0, (f-id)/10)
                sl = int(20*(1-ease(p)))
                iy = 230 + i*40
                d.text((rx+sl, iy), item, fill=color, font=gf(18))
    
    # Bottom text
    if f > 100:
        d.text((cx, H-80), "Built by BSCS students, FOR BSCS students", fill=GRAY, font=gf(20), anchor="mm")
    
    return img

# ═══════════════════════════════════════════════════════
# SEGMENT 3 — DERIVATIVES TUTORIAL
# ═══════════════════════════════════════════════════════
def scene_derivatives(f):
    img = Image.new("RGB", (W,H)); d = ImageDraw.Draw(img); gradient_fun(d)
    draw_stars(d, f, 12)
    
    if f > 5:
        d.text((W//2, 40), "Derivatives Made Easy", fill=WHITE, font=gf(42,True), anchor="mm")
        d.text((W//2, 85), "Step by step — from input to final answer", fill=CYAN, font=gf(20), anchor="mm")
    
    # Phone
    px, py, pw, ph = 120, 120, 420, 900
    draw_phone_fun(d, px, py, pw, ph, PURPLE)
    rrect(d, [px+15, py+40, px+pw-15, py+80], 8, PURPLE)
    d.text((px+pw//2, py+60), "Derivatives", fill=WHITE, font=gf(18,True), anchor="mm")
    
    # Input typing
    rrect(d, [px+20, py+95, px+pw-20, py+140], 10, CARD, outline=PURPLE, w=2)
    expr = "sin(x²) + ln(cos(x))"
    n = min(len(expr), f//2+1) if f<40 else len(expr)
    d.text((px+35, py+108), expr[:n], fill=WHITE, font=gf(16))
    
    # Answer
    if f > 45:
        rrect(d, [px+20, py+155, px+pw-20, py+225], 10, CARD)
        d.text((px+35, py+168), "f'(x) =", fill=GRAY, font=gf(14))
        d.text((px+35, py+192), "2x·cos(x²) - tan(x)", fill=CYAN, font=gf(16,True))
    
    # Steps
    if f > 60:
        sy = py + 250
        steps = [("Chain Rule on sin(x²)","cos(x²)·2x"),("Chain Rule on ln(cos(x))","-sin(x)/cos(x)"),("Simplify","2x·cos(x²) - tan(x)")]
        for i, (title, formula) in enumerate(steps):
            sd = 70+i*15
            if f > sd:
                p = min(1.0, (f-sd)/12)
                sl = int(20*(1-ease(p)))
                d.ellipse([px+38+sl, sy, px+52+sl, sy+14], fill=PURPLE)
                d.text((px+45+sl, sy+7), str(i+1), fill=WHITE, font=gf(9,True), anchor="mm")
                if i<2: d.line([(px+45+sl,sy+14),(px+45+sl,sy+38)], fill=(50,50,80), width=1)
                d.text((px+60+sl, sy), title, fill=WHITE, font=gf(12,True))
                rrect(d, [px+60+sl, sy+18, px+pw-25, sy+38], 6, CARD2)
                d.text((px+70+sl, sy+22), formula, fill=GRAY, font=gf(11))
                sy += 52
    
    # Rapid demo
    if f > 150:
        demos = [("x³ - 2x + 5","3x² - 2"),("e^(2x)","2·e^(2x)"),("(x+1)/(x-1)","-2/(x-1)²")]
        rx = px + pw + 60
        d.text((rx, 160), "Rapid Demo", fill=WHITE, font=gf(28,True))
        for i, (expr, ans) in enumerate(demos):
            dd = 160 + i*25
            if f > dd:
                p = min(1.0, (f-dd)/15)
                sl = int(30*(1-ease(p)))
                dy = 220 + i*80
                rrect(d, [rx+sl, dy, rx+500+sl, dy+65], 10, CARD, outline=CYAN, w=2)
                d.text((rx+20+sl, dy+8), expr, fill=WHITE, font=gf(16,True))
                d.text((rx+20+sl, dy+35), "→ " + ans, fill=LIME, font=gf(14))
    
    # Rules callout
    rx2 = px + pw + 60
    if f > 200:
        d.text((rx2, 500), "Rules MathCalcu Knows:", fill=WHITE, font=gf(22,True))
        rules = ["Power Rule","Chain Rule","Product & Quotient","All 6 Trig Functions",
                  "Inverse Trig & Hyperbolic","Log & Exponential","Square Root & Abs Value"]
        for i, rule in enumerate(rules):
            rd = 210 + i*8
            if f > rd:
                p = min(1.0, (f-rd)/10)
                sl = int(20*(1-ease(p)))
                ry = 540 + i*30
                d.text((rx2+sl, ry), "✅ " + rule, fill=LIME, font=gf(16))
    
    return img

# ═══════════════════════════════════════════════════════
# SEGMENT 4 — QUIZ BREAK 1
# ═══════════════════════════════════════════════════════
def scene_quiz1(f):
    img = Image.new("RGB", (W,H)); d = ImageDraw.Draw(img)
    gradient_fun(d, (15,10,40), (25,15,55), (10,8,35))
    draw_confetti(d, f, 40)
    cx, cy = W//2, H//2
    
    # Header
    d.text((cx, 60), "⚡ QUIZ BREAK ⚡", fill=GOLD, font=gf(48,True), anchor="mm")
    
    # Question 1
    if f > 30:
        rrect(d, [cx-400, 130, cx+400, 380], 16, CARD, outline=CORAL, w=3)
        d.text((cx, 160), "Q1: What rule to differentiate sin(x²)?", fill=WHITE, font=gf(24,True), anchor="mm")
        opts = [("A) Product Rule",CORAL),("B) Chain Rule",LIME),("C) Quotient Rule",GOLD),("D) Power Rule",SKY)]
        for i, (opt, color) in enumerate(opts):
            ox = cx-350 + (i%2)*380
            oy = 210 + (i//2)*60
            d.text((ox, oy), opt, fill=color, font=gf(18))
        
        # Timer
        timer = max(0, 5 - int((f-30)/12))
        if timer > 0:
            d.text((cx, 350), str(timer), fill=RED, font=gf(40,True), anchor="mm")
        
        # Answer reveal
        if f > 100:
            rrect(d, [cx-200, 340, cx+200, 380], 10, LIME)
            d.text((cx, 360), "B) Chain Rule!", fill=WHITE, font=gf(22,True), anchor="mm")
    
    # Question 2
    if f > 130:
        rrect(d, [cx-400, 420, cx+400, 670], 16, CARD, outline=PURPLE, w=3)
        d.text((cx, 450), "Q2: What is d/dx of e^(2x)?", fill=WHITE, font=gf(24,True), anchor="mm")
        opts2 = [("A) e^(2x)",CORAL),("B) 2·e^(2x)",LIME),("C) e^(2x)+2",GOLD),("D) 2x·e^x",SKY)]
        for i, (opt, color) in enumerate(opts2):
            ox = cx-350 + (i%2)*380
            oy = 500 + (i//2)*60
            d.text((ox, oy), opt, fill=color, font=gf(18))
        
        timer2 = max(0, 5 - int((f-130)/12))
        if timer2 > 0:
            d.text((cx, 640), str(timer2), fill=RED, font=gf(40,True), anchor="mm")
        
        if f > 200:
            rrect(d, [cx-200, 620, cx+200, 660], 10, LIME)
            d.text((cx, 640), "B) 2·e^(2x)!", fill=WHITE, font=gf(22,True), anchor="mm")
    
    # Score
    if f > 230:
        d.text((cx, H-100), "How'd you do? Drop your score in the comments!", fill=GRAY, font=gf(20), anchor="mm")
    
    return img

# ═══════════════════════════════════════════════════════
# SEGMENT 5 — LIMITS TUTORIAL
# ═══════════════════════════════════════════════════════
def scene_limits(f):
    img = Image.new("RGB", (W,H)); d = ImageDraw.Draw(img); gradient_fun(d)
    draw_stars(d, f, 12)
    cx = W//2
    
    if f > 5:
        d.text((cx, 40), "Evaluating Limits", fill=WHITE, font=gf(42,True), anchor="mm")
        d.text((W//2, 85), "4 methods — Substitution, Factoring, LCD, Conjugate", fill=PURPLE, font=gf(20), anchor="mm")
    
    # Method callout
    methods = [("1️⃣ Substitution",CYAN),("2️⃣ Factoring",LIME),("3️⃣ LCD",GOLD),("4️⃣ Conjugate",CORAL)]
    for i, (m, color) in enumerate(methods):
        md = 20 + i*8
        if f > md:
            p = min(1.0, (f-md)/10)
            sl = int(30*(1-ease(p)))
            mx = 100 + i*420
            rrect(d, [mx+sl, 120, mx+380+sl, 170], 10, CARD, outline=color, w=2)
            d.text((mx+190+sl, 145), m, fill=color, font=gf(18,True), anchor="mm")
    
    # Demo 1: Substitution
    if f > 60:
        d.text((400, 210), "Demo: Substitution", fill=WHITE, font=gf(24,True), anchor="mm")
        rrect(d, [150, 250, 650, 400], 12, CARD, outline=CYAN, w=2)
        d.text((170, 270), "lim(x→2) x² + 3x", fill=WHITE, font=gf(18,True))
        d.text((170, 310), "= (2)² + 3(2)", fill=GRAY, font=gf(16))
        d.text((170, 350), "= 4 + 6 = 10", fill=LIME, font=gf(18,True))
    
    # Demo 2: Factoring
    if f > 120:
        d.text((1400, 210), "Demo: Factoring", fill=WHITE, font=gf(24,True), anchor="mm")
        rrect(d, [1100, 250, 1700, 430], 12, CARD, outline=LIME, w=2)
        d.text((1120, 270), "lim(x→2) (x²-4)/(x-2)", fill=WHITE, font=gf(18,True))
        d.text((1120, 310), "= (x+2)(x-2)/(x-2)", fill=GRAY, font=gf(16))
        d.text((1120, 350), "= x+2 → 4", fill=LIME, font=gf(18,True))
    
    # Demo 3: Limits at Infinity
    if f > 180:
        d.text((cx, 470), "Limits at Infinity", fill=WHITE, font=gf(24,True), anchor="mm")
        rrect(d, [cx-350, 510, cx+350, 660], 12, CARD, outline=PURPLE, w=2)
        d.text((cx, 540), "lim(x→∞) (3x²+2)/(x²-1)", fill=WHITE, font=gf(18,True), anchor="mm")
        d.text((cx, 580), "Divide by x² → 3", fill=GRAY, font=gf(16), anchor="mm")
        d.text((cx, 620), "= 3", fill=LIME, font=gf(22,True), anchor="mm")
    
    # Bottom
    if f > 220:
        d.text((cx, H-100), "Rational, Radical, and Trig forms all supported", fill=GRAY, font=gf(18), anchor="mm")
    
    return img

# ═══════════════════════════════════════════════════════
# SEGMENT 6 — ANALYTIC GEOMETRY
# ═══════════════════════════════════════════════════════
def scene_geometry(f):
    img = Image.new("RGB", (W,H)); d = ImageDraw.Draw(img); gradient_fun(d)
    draw_stars(d, f, 12)
    cx, cy = W//2, H//2
    
    if f > 5:
        d.text((cx, 40), "📐 Analytic Geometry", fill=WHITE, font=gf(42,True), anchor="mm")
        d.text((cx, 85), "Circles, Distance, Midpoint, Slope & Inequalities", fill=CORAL, font=gf(20), anchor="mm")
    
    # Circles
    if f > 20:
        rrect(d, [80, 130, 600, 380], 12, CARD, outline=CORAL, w=2)
        d.text((340, 150), "⭕ Circles", fill=CORAL, font=gf(22,True), anchor="mm")
        d.text((100, 190), "Input: x²+y²-6x+4y-3=0", fill=WHITE, font=gf(16))
        d.text((100, 225), "Center: (3, -2)", fill=CYAN, font=gf(18,True))
        d.text((100, 260), "Radius: 4", fill=LIME, font=gf(18,True))
        d.text((100, 295), "Standard: (x-3)²+(y+2)²=16", fill=GOLD, font=gf(14))
        d.text((100, 330), "Graph drawn automatically", fill=GRAY, font=gf(14))
    
    # Distance & Midpoint
    if f > 80:
        rrect(d, [620, 130, 1140, 380], 12, CARD, outline=SKY, w=2)
        d.text((880, 150), "📏 Distance & Midpoint", fill=SKY, font=gf(22,True), anchor="mm")
        d.text((640, 190), "A = (1, 2)  |  B = (4, 6)", fill=WHITE, font=gf(16))
        d.text((640, 230), "Distance: 5 units", fill=LIME, font=gf(18,True))
        d.text((640, 270), "Midpoint: (2.5, 4)", fill=CYAN, font=gf(18,True))
        d.text((640, 310), "Graph with plotted points", fill=GRAY, font=gf(14))
    
    # Slope & Intercept
    if f > 140:
        rrect(d, [1160, 130, 1680, 380], 12, CARD, outline=MINT, w=2)
        d.text((1420, 150), "➖ Slope & Intercept", fill=MINT, font=gf(22,True), anchor="mm")
        d.text((1180, 190), "Points: (2,3) & (5,9)", fill=WHITE, font=gf(16))
        d.text((1180, 230), "Slope: m = 2", fill=LIME, font=gf(18,True))
        d.text((1180, 270), "Equation: y = 2x - 1", fill=CYAN, font=gf(18,True))
        d.text((1180, 310), "Parallel/Perp supported", fill=GRAY, font=gf(14))
    
    # Inequalities
    if f > 200:
        rrect(d, [cx-350, 420, cx+350, 580], 12, CARD, outline=GOLD, w=2)
        d.text((cx, 445), "⚖️ Inequalities", fill=GOLD, font=gf(22,True), anchor="mm")
        d.text((cx-300, 490), "|x - 2| < 5", fill=WHITE, font=gf(18,True))
        d.text((cx-300, 530), "Solution: -3 < x < 7", fill=LIME, font=gf(18,True))
        d.text((cx+50, 490), "Number line visualization", fill=GRAY, font=gf(16))
        d.text((cx+50, 530), "Linear, Quadratic, Rational", fill=GRAY, font=gf(14))
    
    if f > 250:
        d.text((cx, H-80), "All modules with graphing support", fill=GRAY, font=gf(18), anchor="mm")
    
    return img

# ═══════════════════════════════════════════════════════
# SEGMENT 7 — QUIZ BREAK 2
# ═══════════════════════════════════════════════════════
def scene_quiz2(f):
    img = Image.new("RGB", (W,H)); d = ImageDraw.Draw(img)
    gradient_fun(d, (15,10,40), (25,15,55), (10,8,35))
    draw_confetti(d, f, 40)
    cx, cy = W//2, H//2
    
    d.text((cx, 60), "⚡ QUIZ BREAK #2 ⚡", fill=GOLD, font=gf(48,True), anchor="mm")
    
    # Question 3
    if f > 20:
        rrect(d, [cx-400, 130, cx+400, 380], 16, CARD, outline=CORAL, w=3)
        d.text((cx, 160), "Q3: Center of (x-3)²+(y+2)²=16?", fill=WHITE, font=gf(24,True), anchor="mm")
        opts = [("A) (3, 2)",CORAL),("B) (-3, 2)",LIME),("C) (3, -2)",GOLD),("D) (-3, -2)",SKY)]
        for i, (opt, color) in enumerate(opts):
            ox = cx-350 + (i%2)*380
            oy = 210 + (i//2)*60
            d.text((ox, oy), opt, fill=color, font=gf(18))
        timer = max(0, 5 - int((f-20)/12))
        if timer > 0: d.text((cx, 350), str(timer), fill=RED, font=gf(40,True), anchor="mm")
        if f > 90:
            rrect(d, [cx-200, 340, cx+200, 380], 10, LIME)
            d.text((cx, 360), "C) (3, -2)!", fill=WHITE, font=gf(22,True), anchor="mm")
    
    # Question 4
    if f > 120:
        rrect(d, [cx-400, 420, cx+400, 670], 16, CARD, outline=PURPLE, w=3)
        d.text((cx, 450), "Q4: lim(x→2) (x²-4)/(x-2)?", fill=WHITE, font=gf(24,True), anchor="mm")
        opts2 = [("A) Undefined",CORAL),("B) 0",LIME),("C) 2",GOLD),("D) 4",SKY)]
        for i, (opt, color) in enumerate(opts2):
            ox = cx-350 + (i%2)*380
            oy = 500 + (i//2)*60
            d.text((ox, oy), opt, fill=color, font=gf(18))
        timer2 = max(0, 5 - int((f-120)/12))
        if timer2 > 0: d.text((cx, 640), str(timer2), fill=RED, font=gf(40,True), anchor="mm")
        if f > 190:
            rrect(d, [cx-200, 620, cx+200, 660], 10, LIME)
            d.text((cx, 640), "D) 4!", fill=WHITE, font=gf(22,True), anchor="mm")
    
    # Bonus
    if f > 220:
        rrect(d, [cx-300, H-130, cx+300, H-50], 12, CARD, outline=GOLD, w=3)
        d.text((cx, H-110), "BONUS: d/dx of x³-2x+5 at x=1?", fill=GOLD, font=gf(18,True), anchor="mm")
        d.text((cx, H-75), "Drop your answer in the comments! 👇", fill=GRAY, font=gf(16), anchor="mm")
    
    return img

# ═══════════════════════════════════════════════════════
# SEGMENT 8 — FUN FACTS
# ═══════════════════════════════════════════════════════
def scene_facts(f):
    img = Image.new("RGB", (W,H)); d = ImageDraw.Draw(img); gradient_fun(d)
    draw_stars(d, f, 15)
    cx, cy = W//2, H//2
    
    d.text((cx, 50), "💡 Fun Facts", fill=GOLD, font=gf(42,True), anchor="mm")
    
    facts = [
        ("📱 Built with Flutter", "One codebase → Android, iOS, Web, Desktop", CYAN),
        ("🧮 Derivative", "Latin 'derivare' — to lead away from", CORAL),
        ("📝 LaTeX Rendering", "Same system used in academic papers", PURPLE),
        ("∞ Limits", "Developed by Newton & Leibniz in the 17th century", LIME),
        ("🌐 100% Offline", "All 8 modules, no internet required", GOLD),
        ("📐 Analytic Geometry", "Invented by René Descartes in 1637", SKY),
    ]
    
    for i, (title, desc, color) in enumerate(facts):
        fd = 30 + i*35
        if f > fd:
            p = min(1.0, (f-fd)/20)
            b = ease_back(p)
            fy = 120 + i*130
            rrect(d, [cx-350, fy, cx+350, fy+110], 14, CARD, outline=color, w=2)
            d.text((cx-320, fy+15), title, fill=color, font=gf(22,True))
            d.text((cx-320, fy+55), desc, fill=GRAY, font=gf(16))
    
    return img

# ═══════════════════════════════════════════════════════
# SEGMENT 9 — CTA / OUTRO
# ═══════════════════════════════════════════════════════
def scene_outro(f):
    img = Image.new("RGB", (W,H)); d = ImageDraw.Draw(img)
    gradient_fun(d, (10,15,40), (20,10,50), (5,20,45))
    draw_confetti(d, f, 60)
    draw_stars(d, f, 20)
    cx, cy = W//2, H//2
    
    # Logo
    draw_logo(d, cx, cy-200, max(10, int(120 + 10*math.sin(f*0.1))))
    
    # Title
    d.text((cx, cy-80), "MathCalcu", fill=WHITE, font=gf(64,True), anchor="mm")
    d.text((cx, cy-10), "Built by BSCS students who know the struggle", fill=CYAN, font=gf(22), anchor="mm")
    
    # Features
    if f > 20:
        features = [("Derivatives",CYAN),("Limits",PURPLE),("Analytic Geometry",CORAL)]
        for i, (feat, color) in enumerate(features):
            fd = 30 + i*8
            if f > fd:
                p = min(1.0, (f-fd)/10)
                sl = int(20*(1-ease(p)))
                fx = cx-300 + i*250
                rrect(d, [fx+sl, cy+50, fx+220+sl, cy+100], 10, CARD, outline=color, w=2)
                d.text((fx+110+sl, cy+75), feat, fill=color, font=gf(16,True), anchor="mm")
    
    # CTA
    if f > 60:
        d.text((cx, cy+150), "⭐ Star us on GitHub", fill=GOLD, font=gf(24,True), anchor="mm")
        d.text((cx, cy+195), "github.com/Shuash11/MathCalcu", fill=GRAY, font=gf(18), anchor="mm")
    
    if f > 80:
        d.text((cx, cy+250), "Share this with a classmate who needs it 📲", fill=WHITE, font=gf(20), anchor="mm")
    
    if f > 100:
        d.text((cx, cy+310), "Math doesn't have to be hard.", fill=GRAY, font=gf(22), anchor="mm")
        d.text((cx, cy+345), "MathCalcu makes sure of that.", fill=CYAN, font=gf(24,True), anchor="mm")
    
    # Student
    if f > 15:
        draw_student_fun(d, cx, cy+400, s=1.5, pose="excited", f=f, shirt_color=CYAN)
    
    return img

# ═══════════════════════════════════════════════════════
# BUILD
# ═══════════════════════════════════════════════════════

def get_dur(path):
    r = subprocess.run(["ffprobe","-v","quiet","-print_format","json","-show_format",path], capture_output=True, text=True)
    return float(json.loads(r.stdout)["format"]["duration"])

scenes = [
    ("01_hook", scene_hook),
    ("02_intro", scene_intro),
    ("03_derivatives", scene_derivatives),
    ("04_quiz1", scene_quiz1),
    ("05_limits", scene_limits),
    ("06_geometry", scene_geometry),
    ("07_quiz2", scene_quiz2),
    ("08_facts", scene_facts),
    ("09_outro", scene_outro),
]

frame_idx = 0
seg_info = []

for sname, sfunc in scenes:
    apath = os.path.join(NARRATION_DIR, f"{sname}.mp3")
    dur = get_dur(apath) if os.path.exists(apath) else 5.0
    nf = int((dur+1.0)*FPS)
    print(f"Rendering {sname}: {dur:.1f}s ({nf} frames)")
    
    for i in range(nf):
        frame = sfunc(f=i)
        fade_frames = 15
        if i < fade_frames:
            a = ease(i/fade_frames)
            black = Image.new("RGB", (W,H))
            frame = Image.blend(black, frame, a)
        elif i >= nf-fade_frames:
            a = ease((nf-i)/fade_frames)
            black = Image.new("RGB", (W,H))
            frame = Image.blend(black, frame, a)
        frame.save(os.path.join(FRAMES_DIR, f"frame_{frame_idx:06d}.png"))
        frame_idx += 1
    seg_info.append((sname, nf))

print(f"\nTotal: {frame_idx} frames ({frame_idx/FPS:.1f}s)")

print("\nBuilding segments...")
segs = []
offset = 0
for sname, nf in seg_info:
    apath = os.path.join(NARRATION_DIR, f"{sname}.mp3")
    sdir = os.path.join(BASE, f"_sf_{sname}")
    os.makedirs(sdir, exist_ok=True)
    for i in range(nf):
        src = os.path.join(FRAMES_DIR, f"frame_{offset+i:06d}.png")
        dst = os.path.join(sdir, f"frame_{i:06d}.png")
        if os.path.exists(src): os.rename(src, dst)
    seg_mp4 = os.path.join(BASE, f"_seg_{sname}.mp4")
    ds = nf/FPS
    cmd = ["ffmpeg","-y","-framerate",str(FPS),"-i",os.path.join(sdir,"frame_%06d.png")]
    if os.path.exists(apath):
        cmd += ["-i",apath,"-c:v","libx264","-t",str(ds),"-c:a","aac","-b:a","192k","-shortest"]
    else:
        cmd += ["-c:v","libx264","-t",str(ds)]
    cmd += ["-pix_fmt","yuv420p","-r",str(FPS),seg_mp4]
    print(f"  {sname}: {ds:.1f}s")
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode == 0: segs.append(seg_mp4)
    else: print(f"    ERR: {r.stderr[-200:]}")
    offset += nf

print("\nConcatenating...")
cl = os.path.join(BASE,"_cl.txt")
with open(cl,"w") as f:
    for s in segs: f.write(f"file '{s}'\n")

cmd = ["ffmpeg","-y","-f","concat","-safe","0","-i",cl,
       "-c:v","libx264","-c:a","aac","-b:a","192k",
       "-pix_fmt","yuv420p","-movflags","+faststart",OUTPUT]
r = subprocess.run(cmd, capture_output=True, text=True)
if r.returncode == 0:
    sz = os.path.getsize(OUTPUT)/(1024*1024)
    print(f"\nDONE! {sz:.1f} MB")
else:
    print(f"Error: {r.stderr[-400:]}")

for s in segs:
    if os.path.exists(s): os.remove(s)
for sname,_ in seg_info:
    d = os.path.join(BASE,f"_sf_{sname}")
    if os.path.isdir(d): shutil.rmtree(d)
if os.path.exists(cl): os.remove(cl)
if os.path.isdir(FRAMES_DIR): shutil.rmtree(FRAMES_DIR)
