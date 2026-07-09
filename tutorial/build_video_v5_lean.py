"""MathCalcu tutorial — lean version, 15 FPS, fast render."""
import os, subprocess, json, math, shutil, random
from PIL import Image, ImageDraw, ImageFont

BASE = os.path.dirname(__file__)
FRAMES_DIR = os.path.join(BASE, "frames")
NARRATION_DIR = os.path.join(BASE, "narration")
OUTPUT = os.path.join(BASE, "mathcalcu_tutorial.mp4")
LOGO_PATH = os.path.join(BASE, "..", "assets", "images", "app_icon.png")
os.makedirs(FRAMES_DIR, exist_ok=True)

W, H = 1920, 1080
FPS = 15  # Reduced from 30

# Theme
BG_DARK = (12, 12, 28); SURFACE = (22, 22, 50); CARD = (28, 28, 60); CARD2 = (35, 35, 70)
CYAN = (0, 220, 255); PURPLE = (120, 80, 255); PURPLE_L = (170, 130, 255)
TEAL = (0, 200, 220); MAGENTA = (255, 50, 150); LIME = (100, 255, 100)
CORAL = (255, 100, 80); SKY = (100, 200, 255); GOLD = (255, 215, 0)
MINT = (0, 255, 180); WHITE = (255, 255, 255); GRAY = (160, 170, 200)
RED = (255, 60, 60); GREEN = (0, 220, 100)

LOGO = None
if os.path.exists(LOGO_PATH):
    try: LOGO = Image.open(LOGO_PATH).convert("RGBA").resize((200, 200), Image.LANCZOS)
    except: pass

def gf(sz, b=False):
    for p in ["C:/Windows/Fonts/segoeuib.ttf" if b else "C:/Windows/Fonts/segoeui.ttf"]:
        if os.path.exists(p):
            try: return ImageFont.truetype(p, sz)
            except: pass
    return ImageFont.load_default()

def grad(d):
    for y in range(H):
        t = y/H
        c = tuple(int(BG_DARK[i]*(1-t)+(25,15,55)[i]*t) for i in range(3))
        d.line([(0,y),(W,y)], fill=c)

def rr(d, xy, r, fill, outline=None, w=2):
    x0,y0,x1,y1 = xy
    d.rectangle([x0+r,y0,x1-r,y1], fill=fill)
    d.rectangle([x0,y0+r,x1,y1-r], fill=fill)
    for cx,cy,sa,ea in [(x0,y0,180,270),(x1-2*r,y0,270,360),(x0,y1-2*r,90,180),(x1-2*r,y1-2*r,0,90)]:
        d.pieslice([cx,cy,cx+2*r,cy+2*r], sa, ea, fill=fill)
    if outline: d.rounded_rectangle(xy, r, outline=outline, width=w)

def ease(t): return 1-(1-t)**3
def ease_back(t):
    c1=1.70158; c3=c1+1; return 1+c3*(t-1)**3+c1*(t-1)**2

def draw_student(d, x, y, s=1.0, pose="stand", f=0, shirt=CYAN):
    skin=(255,220,180); hair=(50,35,25); pants=(40,40,70); shoes=(35,35,35); eye=(25,25,25); cheek=(255,140,140)
    wb = math.sin(f*0.3)*4*s if pose=="walk" else 0
    ww = math.sin(f*0.4)*14 if pose=="wave" else 0
    cy = y+wb
    la1 = math.sin(f*0.3)*20 if pose=="walk" else 0
    la2 = -la1 if pose=="walk" else 0
    for lx,la in [(-8*s,la1),(8*s,la2)]:
        ex=x+lx+math.sin(math.radians(la))*10*s
        d.line([(x+lx,cy+30*s),(ex,cy+52*s)], fill=pants, width=int(6*s))
        d.ellipse([ex-4*s,cy+50*s,ex+4*s,cy+56*s], fill=shoes)
    rr(d, [x-12*s,cy-5*s,x+12*s,cy+32*s], int(6*s), shirt)
    if pose=="point":
        d.line([(x+12*s,cy+5*s),(x+32*s,cy-8*s)], fill=shirt, width=int(5*s))
        d.ellipse([x+30*s-3*s,cy-11*s,x+30*s+5*s,cy-5*s], fill=skin)
    elif pose=="think":
        d.line([(x+12*s,cy+5*s),(x+14*s,cy-16*s)], fill=shirt, width=int(5*s))
        d.ellipse([x+11*s,cy-20*s,x+17*s,cy-14*s], fill=skin)
    elif pose=="excited":
        for dx in [-1,1]:
            d.line([(x+dx*12*s,cy+5*s),(x+dx*24*s,cy-22*s)], fill=shirt, width=int(5*s))
            d.ellipse([x+dx*22*s-3*s,cy-26*s,x+dx*22*s+5*s,cy-20*s], fill=skin)
    elif pose=="wave":
        d.line([(x+12*s,cy+5*s),(x+24*s,cy+ww-12*s)], fill=shirt, width=int(5*s))
        d.ellipse([x+21*s,cy+ww-16*s,x+27*s,cy+ww-10*s], fill=skin)
    else:
        d.line([(x+12*s,cy+5*s),(x+16*s,cy+20*s)], fill=shirt, width=int(5*s))
    d.ellipse([x-14*s,cy-35*s,x+14*s,cy-5*s], fill=skin)
    d.arc([x-15*s,cy-40*s,x+15*s,cy-15*s], 180, 360, fill=hair, width=int(8*s))
    d.ellipse([x-15*s,cy-38*s,x+15*s,cy-25*s], fill=hair)
    ey=cy-22*s
    for dx in [-6,6]:
        d.ellipse([x+dx*s-2*s,ey-2*s,x+dx*s+2*s,ey+2*s], fill=eye)
        d.ellipse([x+dx*s-1*s,ey-1*s,x+dx*s+1*s,ey+1*s], fill=WHITE)
    d.ellipse([x-13*s,ey+4*s,x-7*s,ey+8*s], fill=cheek)
    d.ellipse([x+7*s,ey+4*s,x+13*s,ey+8*s], fill=cheek)
    if pose=="think": d.ellipse([x-2*s,cy-14*s,x+2*s,cy-12*s], fill=eye)
    else: d.arc([x-4*s,cy-17*s,x+4*s,cy-12*s], 0, 180, fill=eye, width=int(2*s))

def draw_phone(d, px, py, pw, ph, accent=CYAN):
    for i in range(10):
        d.rounded_rectangle([px+i+2, py+i+2, px+pw+i+2, py+ph+i+2], 30, fill=(0,0,0))
    rr(d, [px,py,px+pw,py+ph], 30, SURFACE, outline=accent, w=2)

def draw_logo(d, cx, cy, sz=100):
    if LOGO:
        logo = LOGO.resize((sz, sz), Image.LANCZOS)
        d._image.paste(logo, (cx - sz//2, cy - sz//2), logo)
    else:
        rr(d, [cx-50, cy-50, cx+50, cy+50], 15, CYAN)
        d.text((cx, cy), "∫", fill=WHITE, font=gf(60,True), anchor="mm")

# ═══════════════════════════════════════════════════════
# SCENES (lean versions)
# ═══════════════════════════════════════════════════════

def s_hook(f):
    img = Image.new("RGB", (W,H)); d = ImageDraw.Draw(img); grad(d)
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
        draw_student(d, cx, cy-20, s=2.5, pose="think", f=f, shirt=PURPLE)
        for i, (prob, ox, oy, c) in enumerate([("dy/dx = ?",-180,-60,GOLD),("lim ...",180,-40,MAGENTA),("∫ ... dx",-160,60,PURPLE_L)]):
            if f > 75+i*8:
                bx, by = cx+int(ox*ease(min(1,(f-75-i*8)/10))), cy+int(oy*ease(min(1,(f-75-i*8)/10)))
                rr(d, [bx-70, by-15, bx+70, by+15], 8, CARD, outline=c, w=2)
                d.text((bx, by), prob, fill=c, font=gf(15), anchor="mm")
    else:
        for i in range(40):
            random.seed(42)
            px = random.randint(0,W); py = (random.randint(0,H)+f*3)%(H+40)-20
            d.ellipse([px-4,py-4,px+4,py+4], fill=[CYAN,PURPLE,MAGENTA,LIME,GOLD,CORAL][i%6])
        b = ease_back(min(1,(f-120)/15))
        d.text((cx, cy-40), "MATHCALCU", fill=CYAN, font=gf(max(10,int(64*b)),True), anchor="mm")
        d.text((cx, cy+60), "HAS ENTERED THE CHAT", fill=WHITE, font=gf(32,True), anchor="mm")
        draw_logo(d, cx, cy-180, max(10,int(100*b)))
    return img

def s_intro(f):
    img = Image.new("RGB", (W,H)); d = ImageDraw.Draw(img); grad(d)
    cx, cy = W//2, H//2
    if f > 5: d.text((cx, 50), "Meet MathCalcu", fill=WHITE, font=gf(48,True), anchor="mm")
    if f > 10: d.text((cx, 100), "Flutter-powered math solver for BSCS students", fill=CYAN, font=gf(20), anchor="mm")
    if f > 15:
        px, py, pw, ph = cx-220, 150, 440, 780
        draw_phone(d, px, py, pw, ph, CYAN)
        rr(d, [px+15, py+40, px+pw-15, py+80], 8, CYAN)
        d.text((px+pw//2, py+60), "MathCalcu", fill=WHITE, font=gf(20,True), anchor="mm")
        mods = [("Derivatives",CYAN),("Slope",LIME),("Limits",PURPLE),("∞ Limits",MAGENTA),("Ineq.",GOLD),("Circles",CORAL),("Distance",SKY),("Slope-Int",MINT)]
        for i,(n,c) in enumerate(mods):
            md = 20+i*5
            if f > md:
                r,c2 = divmod(i,2)
                mx,my = px+20+c2*200, py+100+r*100
                rr(d, [mx,my,mx+180,my+80], 8, CARD, outline=c, w=2)
                d.text((mx+90,my+30), n, fill=c, font=gf(14,True), anchor="mm")
    rx = cx+280
    if f > 30:
        d.text((rx, 180), "8 Modules", fill=WHITE, font=gf(28,True))
        for i,(item,c) in enumerate([("📐 Derivatives",CYAN),("📈 Slope",LIME),("∞ Limits",PURPLE),("⚖️ Inequalities",GOLD),("⭕ Circles",CORAL),("📏 Distance",SKY),("➖ Slope-Int",MINT)]):
            if f > 40+i*4: d.text((rx, 230+i*40), item, fill=c, font=gf(18))
    if f > 80: d.text((cx, H-70), "Built by BSCS students, FOR BSCS students", fill=GRAY, font=gf(20), anchor="mm")
    return img

def s_derivatives(f):
    img = Image.new("RGB", (W,H)); d = ImageDraw.Draw(img); grad(d)
    cx, cy = W//2, H//2
    if f > 3: d.text((cx, 40), "Derivatives Made Easy", fill=WHITE, font=gf(42,True), anchor="mm")
    px, py, pw, ph = 120, 110, 420, 900
    draw_phone(d, px, py, pw, ph, PURPLE)
    rr(d, [px+15, py+40, px+pw-15, py+80], 8, PURPLE)
    d.text((px+pw//2, py+60), "Derivatives", fill=WHITE, font=gf(18,True), anchor="mm")
    rr(d, [px+20, py+95, px+pw-20, py+140], 10, CARD, outline=PURPLE, w=2)
    expr = "sin(x²) + ln(cos(x))"
    n = min(len(expr), f//2+1) if f<30 else len(expr)
    d.text((px+35, py+108), expr[:n], fill=WHITE, font=gf(16))
    if f > 35:
        rr(d, [px+20, py+155, px+pw-20, py+225], 10, CARD)
        d.text((px+35, py+168), "f'(x) =", fill=GRAY, font=gf(14))
        d.text((px+35, py+192), "2x·cos(x²) - tan(x)", fill=CYAN, font=gf(16,True))
    if f > 45:
        sy = py+250
        for i,(t,v) in enumerate([("Chain Rule on sin(x²)","cos(x²)·2x"),("Chain Rule on ln(cos(x))","-sin(x)/cos(x)"),("Simplify","2x·cos(x²) - tan(x)")]):
            sd = 50+i*10
            if f > sd:
                p = min(1,(f-sd)/8)
                sl = int(20*(1-ease(p)))
                d.ellipse([px+38+sl,sy,px+52+sl,sy+14], fill=PURPLE)
                d.text((px+45+sl,sy+7), str(i+1), fill=WHITE, font=gf(9,True), anchor="mm")
                d.text((px+60+sl,sy), t, fill=WHITE, font=gf(12,True))
                rr(d, [px+60+sl,sy+18,px+pw-25,sy+38], 6, CARD2)
                d.text((px+70+sl,sy+22), v, fill=GRAY, font=gf(11))
                sy += 50
    rx = px+pw+60
    if f > 60:
        d.text((rx, 140), "Rapid Demo", fill=WHITE, font=gf(24,True))
        for i,(e,a) in enumerate([("x³-2x+5","3x²-2"),("e^(2x)","2·e^(2x)"),("(x+1)/(x-1)","-2/(x-1)²")]):
            dd = 65+i*15
            if f > dd:
                p = min(1,(f-dd)/10)
                sl = int(20*(1-ease(p)))
                dy = 190+i*70
                rr(d, [rx+sl,dy,rx+450+sl,dy+55], 8, CARD, outline=CYAN, w=2)
                d.text((rx+15+sl,dy+8), e, fill=WHITE, font=gf(15,True))
                d.text((rx+15+sl,dy+32), "→ "+a, fill=LIME, font=gf(13))
    if f > 80:
        d.text((rx, 420), "Rules:", fill=WHITE, font=gf(20,True))
        for i,r in enumerate(["Power Rule","Chain Rule","Product & Quotient","All 6 Trig","Inverse Trig & Hyperbolic","Log & Exponential","Square Root & Abs Value"]):
            if f > 85+i*5: d.text((rx, 460+i*28), "✅ "+r, fill=LIME, font=gf(15))
    return img

def s_quiz1(f):
    img = Image.new("RGB", (W,H)); d = ImageDraw.Draw(img); grad(d)
    cx, cy = W//2, H//2
    for i in range(30):
        random.seed(42)
        px = random.randint(0,W); py = (random.randint(0,H)+f*3)%(H+40)-20
        d.ellipse([px-4,py-4,px+4,py+4], fill=[CYAN,PURPLE,MAGENTA,LIME,GOLD,CORAL][i%6])
    d.text((cx, 50), "⚡ QUIZ BREAK ⚡", fill=GOLD, font=gf(48,True), anchor="mm")
    if f > 15:
        rr(d, [cx-400,120,cx+400,350], 14, CARD, outline=CORAL, w=3)
        d.text((cx, 150), "Q1: What rule for sin(x²)?", fill=WHITE, font=gf(24,True), anchor="mm")
        for i,(o,c) in enumerate([("A) Product",CORAL),("B) Chain",LIME),("C) Quotient",GOLD),("D) Power",SKY)]):
            d.text((cx-350+(i%2)*370, 200+(i//2)*55), o, fill=c, font=gf(18))
        t = max(0,5-int((f-15)/8))
        if t>0: d.text((cx,320), str(t), fill=RED, font=gf(40,True), anchor="mm")
        if f > 60:
            rr(d, [cx-150,310,cx+150,350], 8, LIME)
            d.text((cx,330), "B) Chain Rule!", fill=WHITE, font=gf(20,True), anchor="mm")
    if f > 75:
        rr(d, [cx-400,390,cx+400,620], 14, CARD, outline=PURPLE, w=3)
        d.text((cx, 420), "Q2: d/dx of e^(2x)?", fill=WHITE, font=gf(24,True), anchor="mm")
        for i,(o,c) in enumerate([("A) e^(2x)",CORAL),("B) 2·e^(2x)",LIME),("C) e^(2x)+2",GOLD),("D) 2x·e^x",SKY)]):
            d.text((cx-350+(i%2)*370, 470+(i//2)*55), o, fill=c, font=gf(18))
        t2 = max(0,5-int((f-75)/8))
        if t2>0: d.text((cx,590), str(t2), fill=RED, font=gf(40,True), anchor="mm")
        if f > 120:
            rr(d, [cx-150,580,cx+150,620], 8, LIME)
            d.text((cx,600), "B) 2·e^(2x)!", fill=WHITE, font=gf(20,True), anchor="mm")
    if f > 140: d.text((cx, H-80), "Drop your score in the comments!", fill=GRAY, font=gf(20), anchor="mm")
    return img

def s_limits(f):
    img = Image.new("RGB", (W,H)); d = ImageDraw.Draw(img); grad(d)
    cx, cy = W//2, H//2
    if f > 3: d.text((cx, 40), "Evaluating Limits", fill=WHITE, font=gf(42,True), anchor="mm")
    methods = [("1 Substitution",CYAN),("2 Factoring",LIME),("3 LCD",GOLD),("4 Conjugate",CORAL)]
    for i,(m,c) in enumerate(methods):
        md = 10+i*5
        if f > md:
            p = min(1,(f-md)/8)
            sl = int(20*(1-ease(p)))
            mx = 100+i*420
            rr(d, [mx+sl,100,mx+380+sl,150], 8, CARD, outline=c, w=2)
            d.text((mx+190+sl,125), m, fill=c, font=gf(18,True), anchor="mm")
    if f > 40:
        rr(d, [150,180,600,320], 10, CARD, outline=CYAN, w=2)
        d.text((170,200), "lim(x→2) x²+3x", fill=WHITE, font=gf(16,True))
        d.text((170,240), "= 4+6 = 10", fill=LIME, font=gf(16,True))
    if f > 70:
        rr(d, [1100,180,1700,320], 10, CARD, outline=LIME, w=2)
        d.text((1120,200), "lim(x→2) (x²-4)/(x-2)", fill=WHITE, font=gf(16,True))
        d.text((1120,240), "= (x+2) → 4", fill=LIME, font=gf(16,True))
    if f > 100:
        rr(d, [cx-350,370,cx+350,510], 10, CARD, outline=PURPLE, w=2)
        d.text((cx,395), "lim(x→∞) (3x²+2)/(x²-1)", fill=WHITE, font=gf(16,True), anchor="mm")
        d.text((cx,440), "= 3", fill=LIME, font=gf(20,True), anchor="mm")
    if f > 130: d.text((cx, H-80), "Rational, Radical, Trig forms all supported", fill=GRAY, font=gf(18), anchor="mm")
    return img

def s_geometry(f):
    img = Image.new("RGB", (W,H)); d = ImageDraw.Draw(img); grad(d)
    cx, cy = W//2, H//2
    if f > 3: d.text((cx, 40), "📐 Analytic Geometry", fill=WHITE, font=gf(42,True), anchor="mm")
    if f > 15:
        rr(d, [80,110,600,330], 10, CARD, outline=CORAL, w=2)
        d.text((340,130), "⭕ Circles", fill=CORAL, font=gf(22,True), anchor="mm")
        d.text((100,170), "x²+y²-6x+4y-3=0", fill=WHITE, font=gf(14))
        d.text((100,200), "Center: (3, -2)  Radius: 4", fill=LIME, font=gf(16,True))
        d.text((100,240), "(x-3)²+(y+2)²=16", fill=CYAN, font=gf(14))
    if f > 50:
        rr(d, [620,110,1140,330], 10, CARD, outline=SKY, w=2)
        d.text((880,130), "📏 Distance & Midpoint", fill=SKY, font=gf(22,True), anchor="mm")
        d.text((640,170), "A(1,2)  B(4,6)", fill=WHITE, font=gf(14))
        d.text((640,200), "Distance: 5  Midpoint: (2.5,4)", fill=LIME, font=gf(16,True))
    if f > 85:
        rr(d, [1160,110,1680,330], 10, CARD, outline=MINT, w=2)
        d.text((1420,130), "➖ Slope & Intercept", fill=MINT, font=gf(22,True), anchor="mm")
        d.text((1180,170), "(2,3) & (5,9)", fill=WHITE, font=gf(14))
        d.text((1180,200), "Slope: 2  y = 2x-1", fill=LIME, font=gf(16,True))
    if f > 120:
        rr(d, [cx-350,380,cx+350,500], 10, CARD, outline=GOLD, w=2)
        d.text((cx,405), "⚖️ |x-2| < 5 → -3 < x < 7", fill=GOLD, font=gf(18,True), anchor="mm")
        d.text((cx,445), "Linear, Quadratic, Rational, Radical", fill=GRAY, font=gf(14), anchor="mm")
    if f > 150: d.text((cx, H-80), "All modules with graphing support", fill=GRAY, font=gf(18), anchor="mm")
    return img

def s_quiz2(f):
    img = Image.new("RGB", (W,H)); d = ImageDraw.Draw(img); grad(d)
    cx, cy = W//2, H//2
    for i in range(30):
        random.seed(42)
        px = random.randint(0,W); py = (random.randint(0,H)+f*3)%(H+40)-20
        d.ellipse([px-4,py-4,px+4,py+4], fill=[CYAN,PURPLE,MAGENTA,LIME,GOLD,CORAL][i%6])
    d.text((cx, 50), "⚡ QUIZ #2 ⚡", fill=GOLD, font=gf(48,True), anchor="mm")
    if f > 15:
        rr(d, [cx-400,120,cx+400,350], 14, CARD, outline=CORAL, w=3)
        d.text((cx, 150), "Q3: Center of (x-3)²+(y+2)²=16?", fill=WHITE, font=gf(22,True), anchor="mm")
        for i,(o,c) in enumerate([("(3,2)",CORAL),("(-3,2)",LIME),("(3,-2)",GOLD),("(-3,-2)",SKY)]):
            d.text((cx-350+(i%2)*370, 200+(i//2)*55), o, fill=c, font=gf(18))
        if f > 55: d.text((cx,320), "C) (3,-2)!", fill=LIME, font=gf(22,True), anchor="mm")
    if f > 70:
        rr(d, [cx-400,390,cx+400,620], 14, CARD, outline=PURPLE, w=3)
        d.text((cx, 420), "Q4: lim(x→2) (x²-4)/(x-2)?", fill=WHITE, font=gf(22,True), anchor="mm")
        for i,(o,c) in enumerate([("Undefined",CORAL),("0",LIME),("2",GOLD),("4",SKY)]):
            d.text((cx-350+(i%2)*370, 470+(i//2)*55), o, fill=c, font=gf(18))
        if f > 110: d.text((cx,590), "D) 4!", fill=LIME, font=gf(22,True), anchor="mm")
    if f > 130:
        rr(d, [cx-250,H-110,cx+250,H-50], 10, CARD, outline=GOLD, w=3)
        d.text((cx,H-90), "BONUS: d/dx of x³-2x+5 at x=1?", fill=GOLD, font=gf(16,True), anchor="mm")
        d.text((cx,H-65), "Drop answer in comments! 👇", fill=GRAY, font=gf(14), anchor="mm")
    return img

def s_facts(f):
    img = Image.new("RGB", (W,H)); d = ImageDraw.Draw(img); grad(d)
    cx, cy = W//2, H//2
    d.text((cx, 40), "💡 Fun Facts", fill=GOLD, font=gf(42,True), anchor="mm")
    facts = [
        ("📱 Built with Flutter","One codebase → Android, iOS, Web, Desktop",CYAN),
        ("🧮 Derivative","Latin 'derivare' — to lead away from",CORAL),
        ("📝 LaTeX Rendering","Same system used in academic papers",PURPLE),
        ("∞ Limits","Newton & Leibniz, 17th century",LIME),
        ("🌐 100% Offline","All 8 modules, no internet needed",GOLD),
        ("📐 Analytic Geometry","Descartes, 1637 — Cartesian coordinates",SKY),
    ]
    for i,(t,desc,c) in enumerate(facts):
        fd = 15+i*25
        if f > fd:
            p = min(1,(f-fd)/15)
            fy = 110+i*120
            rr(d, [cx-350,fy,cx+350,fy+100], 12, CARD, outline=c, w=2)
            d.text((cx-320,fy+12), t, fill=c, font=gf(20,True))
            d.text((cx-320,fy+48), desc, fill=GRAY, font=gf(15))
    return img

def s_outro(f):
    img = Image.new("RGB", (W,H)); d = ImageDraw.Draw(img); grad(d)
    cx, cy = W//2, H//2
    for i in range(50):
        random.seed(42)
        px = random.randint(0,W); py = (random.randint(0,H)+f*3)%(H+40)-20
        d.ellipse([px-5,py-5,px+5,py+5], fill=[CYAN,PURPLE,MAGENTA,LIME,GOLD,CORAL][i%6])
    draw_logo(d, cx, cy-200, max(10,int(120+10*math.sin(f*0.1))))
    d.text((cx, cy-80), "MathCalcu", fill=WHITE, font=gf(64,True), anchor="mm")
    d.text((cx, cy-10), "Built by BSCS students", fill=CYAN, font=gf(22), anchor="mm")
    if f > 15:
        for i,(feat,c) in enumerate([("Derivatives",CYAN),("Limits",PURPLE),("Geometry",CORAL)]):
            fd = 20+i*5
            if f > fd:
                fx = cx-300+i*250
                rr(d, [fx,cy+50,fx+220,cy+100], 8, CARD, outline=c, w=2)
                d.text((fx+110,cy+75), feat, fill=c, font=gf(16,True), anchor="mm")
    if f > 40: d.text((cx, cy+150), "⭐ Star us on GitHub", fill=GOLD, font=gf(24,True), anchor="mm")
    if f > 50: d.text((cx, cy+190), "github.com/Shuash11/MathCalcu", fill=GRAY, font=gf(18), anchor="mm")
    if f > 60: d.text((cx, cy+240), "Share with a classmate 📲", fill=WHITE, font=gf(20), anchor="mm")
    if f > 75:
        d.text((cx, cy+290), "Math doesn't have to be hard.", fill=GRAY, font=gf(22), anchor="mm")
        d.text((cx, cy+325), "MathCalcu makes sure of that.", fill=CYAN, font=gf(24,True), anchor="mm")
    if f > 10: draw_student(d, cx, cy+400, s=1.5, pose="excited", f=f, shirt=CYAN)
    return img

# ═══════════════════════════════════════════════════════
# BUILD
# ═══════════════════════════════════════════════════════

def get_dur(path):
    r = subprocess.run(["ffprobe","-v","quiet","-print_format","json","-show_format",path], capture_output=True, text=True)
    return float(json.loads(r.stdout)["format"]["duration"])

scenes = [
    ("01_hook", s_hook), ("02_intro", s_intro), ("03_derivatives", s_derivatives),
    ("04_quiz1", s_quiz1), ("05_limits", s_limits), ("06_geometry", s_geometry),
    ("07_quiz2", s_quiz2), ("08_facts", s_facts), ("09_outro", s_outro),
]

frame_idx = 0; seg_info = []
for sname, sfunc in scenes:
    apath = os.path.join(NARRATION_DIR, f"{sname}.mp3")
    dur = get_dur(apath) if os.path.exists(apath) else 5.0
    nf = int((dur+1.0)*FPS)
    print(f"Rendering {sname}: {dur:.1f}s ({nf} frames)")
    for i in range(nf):
        frame = sfunc(f=i)
        ff = 10
        if i < ff:
            frame = Image.blend(Image.new("RGB",(W,H)), frame, ease(i/ff))
        elif i >= nf-ff:
            frame = Image.blend(Image.new("RGB",(W,H)), frame, ease((nf-i)/ff))
        frame.save(os.path.join(FRAMES_DIR, f"frame_{frame_idx:06d}.png"))
        frame_idx += 1
    seg_info.append((sname, nf))

print(f"\nTotal: {frame_idx} frames ({frame_idx/FPS:.1f}s)")
print("\nBuilding segments...")
segs = []; offset = 0
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
    if os.path.exists(apath): cmd += ["-i",apath,"-c:v","libx264","-t",str(ds),"-c:a","aac","-b:a","192k","-shortest"]
    else: cmd += ["-c:v","libx264","-t",str(ds)]
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
cmd = ["ffmpeg","-y","-f","concat","-safe","0","-i",cl,"-c:v","libx264","-c:a","aac","-b:a","192k","-pix_fmt","yuv420p","-movflags","+faststart",OUTPUT]
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
