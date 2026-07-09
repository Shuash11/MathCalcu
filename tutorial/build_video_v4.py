"""MathCalcu tutorial v4 — real logo, fun colors, confetti, smooth transitions."""
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

# ── FUN Theme (cyan + purple from real logo) ──
BG_DARK = (12, 12, 28)
BG_MID = (18, 18, 42)
SURFACE = (22, 22, 50)
CARD = (28, 28, 60)
CARD2 = (35, 35, 70)

# Real logo colors
CYAN = (0, 220, 255)
CYAN_DARK = (0, 160, 200)
PURPLE = (120, 80, 255)
PURPLE_LIGHT = (170, 130, 255)
TEAL = (0, 200, 220)

# Fun accent colors
MAGENTA = (255, 50, 150)
LIME = (100, 255, 100)
CORAL = (255, 100, 80)
SKY = (100, 200, 255)
GOLD = (255, 215, 0)
MINT = (0, 255, 180)

WHITE = (255, 255, 255)
GRAY = (160, 170, 200)

# Load real logo
LOGO = None
if os.path.exists(LOGO_PATH):
    try:
        LOGO = Image.open(LOGO_PATH).convert("RGBA")
        LOGO = LOGO.resize((200, 200), Image.LANCZOS)
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
        if t < 0.5:
            c = tuple(int(c1[i]*(1-t*2)+c2[i]*(t*2)) for i in range(3))
        else:
            c = tuple(int(c2[i]*(1-(t-0.5)*2)+c3[i]*((t-0.5)*2)) for i in range(3))
        draw.line([(0,y),(W,y)], fill=c)

def rrect(draw, xy, r, fill, outline=None, w=2):
    x0,y0,x1,y1 = xy
    draw.rectangle([x0+r,y0,x1-r,y1], fill=fill)
    draw.rectangle([x0,y0+r,x1,y1-r], fill=fill)
    for cx,cy,sa,ea in [(x0,y0,180,270),(x1-2*r,y0,270,360),(x0,y1-2*r,90,180),(x1-2*r,y1-2*r,0,90)]:
        draw.pieslice([cx,cy,cx+2*r,cy+2*r], sa, ea, fill=fill)
    if outline:
        draw.rounded_rectangle(xy, r, outline=outline, width=w)

def ease(t): return 1-(1-t)**3
def ease_back(t):
    c1=1.70158; c3=c1+1
    return 1+c3*(t-1)**3+c1*(t-1)**2
def ease_bounce(t):
    if t<1/2.75: return 7.5625*t*t
    elif t<2/2.75: t-=1.5/2.75; return 7.5625*t*t+0.75
    elif t<2.5/2.75: t-=2.25/2.75; return 7.5625*t*t+0.9375
    else: t-=2.625/2.75; return 7.5625*t*t+0.984375

def lerp(a,b,t): return a+(b-a)*t

# ── CONFETTI / FUN ELEMENTS ──
def draw_confetti(d, f, count=30):
    random.seed(42)
    for i in range(count):
        x = random.randint(0, W)
        y = (random.randint(0, H) + f * (2 + i%3)) % (H + 40) - 20
        colors = [CYAN, PURPLE, MAGENTA, LIME, GOLD, CORAL, SKY, MINT]
        c = colors[i % len(colors)]
        sz = random.randint(4, 12)
        rot = f * (1 + i%3)
        d.ellipse([x-sz, y-sz, x+sz, y+sz], fill=c)

def draw_stars(d, f, count=15):
    random.seed(99)
    for i in range(count):
        x = random.randint(50, W-50)
        y = random.randint(50, H-50)
        phase = f*0.1 + i*0.5
        brightness = int(40 + 30*math.sin(phase))
        sz = int(3 + 2*math.sin(phase))
        c = (brightness, brightness, brightness+20)
        d.ellipse([x-sz, y-sz, x+sz, y+sz], fill=c)

def draw_logo(d, cx, cy, size=100):
    if LOGO:
        logo = LOGO.resize((size, size), Image.LANCZOS)
        d._image.paste(logo, (cx - size//2, cy - size//2), logo)
    else:
        # Fallback: draw stylized icon
        rrect(d, [cx-50, cy-50, cx+50, cy+50], 15, CYAN)
        d.text((cx, cy), "∫", fill=WHITE, font=gf(60,True), anchor="mm")

def draw_student_fun(draw, x, y, s=1.0, pose="stand", f=0, shirt_color=CYAN):
    skin=(255,220,180); hair=(50,35,25); shirt=shirt_color; pants=(40,40,70); shoes=(35,35,35); eye=(25,25,25); cheek=(255,140,140)
    wb = math.sin(f*0.3)*4*s if pose=="walk" else 0
    ww = math.sin(f*0.4)*14 if pose=="wave" else 0
    cy = y+wb
    if pose=="walk":
        la1=math.sin(f*0.3)*20; la2=-la1
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
    nw = 100
    rrect(draw, [px+pw//2-nw//2, py+8, px+pw//2+nw//2, py+28], 10, (8,8,18))

# ═══════════════════════════════════════════════════════
# SCENES
# ═══════════════════════════════════════════════════════

def scene_title(f):
    img = Image.new("RGB", (W,H)); d = ImageDraw.Draw(img); gradient_fun(d)
    draw_stars(d, f, 20)
    cx, cy = W//2, H//2-60
    
    # Logo bounce in
    b = ease_back(min(1.0, f/25)) if f<25 else 1.0
    logo_size = max(10, int(160 * b))
    logo_y = int(cy - 40 + (1-b)*-80)
    
    # Glow behind logo
    if f > 10:
        glow_r = int(80 + 10*math.sin(f*0.1))
        for i in range(glow_r, 0, -3):
            d.ellipse([cx-i, logo_y-i, cx+i, logo_y+i], fill=(0,180,220))
    
    draw_logo(d, cx, logo_y, logo_size)
    
    # Title typewriter
    title = "MathCalcu"
    n = min(len(title), f//2+1) if f<30 else len(title)
    d.text((W//2, cy+110), title[:n], fill=WHITE, font=gf(68,True), anchor="mm")
    
    # Subtitle
    if f > 35:
        d.text((W//2, cy+170), "The Smartest Way to Learn Math", fill=CYAN, font=gf(30), anchor="mm")
    if f > 55:
        d.text((W//2, cy+210), "Step-by-step solutions  •  Works offline  •  Free", fill=GRAY, font=gf(22), anchor="mm")
    
    # Student walks in
    if f > 40:
        cx_c = min(280, 30+(f-40)*7)
        draw_student_fun(d, cx_c, cy+80, s=1.5, pose="wave", f=f, shirt_color=CYAN)
    
    # Confetti
    if f > 50:
        draw_confetti(d, f-50, 25)
    
    return img

def scene_pain_point(f):
    img = Image.new("RGB", (W,H)); d = ImageDraw.Draw(img); gradient_fun(d, (20,10,30), (30,15,45), (15,10,35))
    draw_stars(d, f, 15)
    cx, cy = W//2, H//2
    
    # Headline
    if f > 10:
        d.text((cx, 100), "Struggling with Calculus?", fill=CORAL, font=gf(46,True), anchor="mm")
        d.text((cx, 155), "Confused by derivatives, limits, and slopes?", fill=GRAY, font=gf(24), anchor="mm")
    
    # Frustrated student
    if f > 5:
        draw_student_fun(d, cx, cy-30, s=2.2, pose="think", f=f, shirt_color=PURPLE)
    
    # Problem bubbles
    problems = [
        ("f(x) = x³·sin(x²)", -220, -80, CORAL),
        ("lim(x→∞) ...", 220, -60, MAGENTA),
        ("dy/dx = ?", -200, 70, GOLD),
        ("∫ ... dx", 240, 90, PURPLE_LIGHT),
    ]
    for i, (prob, ox, oy, color) in enumerate(problems):
        delay = 20 + i*8
        if f > delay:
            p = min(1.0, (f-delay)/15)
            a = ease(p)
            bx, by = cx+int(ox*a), cy+int(oy*a)
            rrect(d, [bx-80, by-18, bx+80, by+18], 10, CARD, outline=color, w=2)
            d.text((bx, by), prob, fill=color, font=gf(16), anchor="mm")
    
    # Bottom text
    if f > 50:
        d.text((cx, H-100), "What if there was a better way?", fill=WHITE, font=gf(30,True), anchor="mm")
    
    return img

def scene_solution(f):
    img = Image.new("RGB", (W,H)); d = ImageDraw.Draw(img); gradient_fun(d, (10,15,35), (15,20,45), (8,18,38))
    draw_stars(d, f, 18)
    cx, cy = W//2, H//2
    
    # Big reveal
    if f > 5:
        d.text((cx, 80), "Meet MathCalcu", fill=WHITE, font=gf(56,True), anchor="mm")
        d.text((cx, 130), "Your personal calculus tutor — Midterm & Final ready", fill=CYAN, font=gf(22), anchor="mm")
    
    # Phone mockup
    if f > 15:
        px, py, pw, ph = cx-220, 170, 440, 780
        draw_phone_fun(d, px, py, pw, ph, CYAN)
        
        # App header
        rrect(d, [px+15, py+40, px+pw-15, py+80], 8, (0,180,220))
        d.text((px+pw//2, py+60), "MathCalcu", fill=WHITE, font=gf(20,True), anchor="mm")
        
        d.text((px+30, py+100), "Differentiate", fill=WHITE, font=gf(22,True))
        d.text((px+30, py+128), "Enter any function", fill=GRAY, font=gf(13))
        
        # Input
        rrect(d, [px+20, py+155, px+pw-20, py+200], 10, CARD, outline=CYAN, w=2)
        d.text((px+40, py+168), "x³ - 2x + 5", fill=WHITE, font=gf(18))
        
        # Button
        rrect(d, [px+20, py+215, px+pw-20, py+255], 10, CYAN)
        d.text((px+pw//2, py+235), "Solve", fill=WHITE, font=gf(18,True), anchor="mm")
        
        # Answer
        if f > 35:
            rrect(d, [px+20, py+275, px+pw-20, py+345], 10, CARD)
            d.text((px+40, py+290), "Answer", fill=LIME, font=gf(13,True))
            d.text((px+40, py+315), "f'(x) = 3x² - 2", fill=WHITE, font=gf(20,True))
            d.line([(px+40,py+340),(px+230,py+340)], fill=CYAN, width=2)
        
        # Steps
        steps = [("1","Problem","f(x) = x³ - 2x + 5"),("2","Rule","Power: d/dx[xⁿ] = n·xⁿ⁻¹"),("3","Result","f'(x) = 3x² - 2")]
        sy = py + 370
        for i, (num, lbl, val) in enumerate(steps):
            sd = 45 + i*10
            if f > sd:
                p = min(1.0, (f-sd)/12)
                sl = int(25*(1-ease(p)))
                d.ellipse([px+38+sl, sy, px+54+sl, sy+16], fill=CYAN if i==2 else (50,50,80))
                d.text((px+46+sl, sy+8), num, fill=WHITE, font=gf(10,True), anchor="mm")
                if i<2: d.line([(px+46+sl,sy+16),(px+46+sl,sy+40)], fill=(50,50,80), width=1)
                d.text((px+65+sl, sy), lbl, fill=WHITE, font=gf(12,True))
                rrect(d, [px+65+sl, sy+18, px+pw-25, sy+38], 6, CARD2)
                d.text((px+75+sl, sy+22), val, fill=GRAY, font=gf(11))
                sy += 52
    
    # Right side: benefits
    rx = cx + 280
    if f > 25:
        benefits = [
            ("Midterm Topics", "Derivatives, Limits, Slope", CYAN),
            ("Final Topics", "Inequalities, Circles, Distance", LIME),
            ("Works Offline", "No internet needed ever", GOLD),
            ("Instant Results", "Solve in milliseconds", CORAL),
        ]
        d.text((rx, 180), "Why Students Love It", fill=WHITE, font=gf(32,True))
        for i, (title, desc, color) in enumerate(benefits):
            bd = 30 + i*10
            if f > bd:
                p = min(1.0, (f-bd)/15)
                sl = int(40*(1-ease(p)))
                by = 240 + i*100
                rrect(d, [rx+sl, by, rx+440+sl, by+80], 12, CARD, outline=color, w=2)
                d.ellipse([rx+15+sl, by+15, rx+50+sl, by+50], fill=color)
                d.text((rx+32+sl, by+32), "✓", fill=WHITE, font=gf(18,True), anchor="mm")
                d.text((rx+65+sl, by+12), title, fill=WHITE, font=gf(20,True))
                d.text((rx+65+sl, by+42), desc, fill=GRAY, font=gf(14))
    
    # Student excited
    if f > 20:
        draw_student_fun(d, rx+200, H-100, s=1.3, pose="excited", f=f, shirt_color=CYAN)
    
    # Confetti
    if f > 40:
        draw_confetti(d, f-40, 20)
    
    return img

def scene_derivatives(f):
    img = Image.new("RGB", (W,H)); d = ImageDraw.Draw(img); gradient_fun(d)
    draw_stars(d, f, 12)
    
    if f > 5:
        d.text((W//2, 45), "Derivatives Made Easy", fill=WHITE, font=gf(42,True), anchor="mm")
        d.text((W//2, 90), "Enter any expression — get the full solution", fill=CYAN, font=gf(22), anchor="mm")
    
    # Phone
    px, py, pw, ph = 120, 130, 420, 900
    draw_phone_fun(d, px, py, pw, ph, PURPLE)
    
    # Header
    rrect(d, [px+15, py+40, px+pw-15, py+80], 8, PURPLE)
    d.text((px+pw//2, py+60), "Derivatives", fill=WHITE, font=gf(18,True), anchor="mm")
    
    # Input
    rrect(d, [px+20, py+95, px+pw-20, py+140], 10, CARD, outline=PURPLE, w=2)
    expr = "sin(x²) + ln(cos(x))"
    n = min(len(expr), f//2+1) if f<40 else len(expr)
    d.text((px+35, py+108), expr[:n], fill=WHITE, font=gf(16))
    
    # Answer
    if f > 45:
        rrect(d, [px+20, py+155, px+pw-20, py+230], 10, CARD)
        d.text((px+35, py+170), "f'(x) =", fill=GRAY, font=gf(14))
        d.text((px+35, py+195), "2x·cos(x²) - sin(x)/cos(x)", fill=CYAN, font=gf(16,True))
    
    # Steps
    if f > 55:
        sy = py + 255
        steps = [("Chain Rule on sin(x²)","d/dx[sin(u)] = cos(u)·u'"),("Chain Rule on ln(cos(x))","d/dx[ln(u)] = u'/u"),("Simplify","2x·cos(x²) - tan(x)")]
        for i, (title, formula) in enumerate(steps):
            sd = 60+i*12
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
    
    # Rules
    rx = px + pw + 80
    d.text((rx, 160), "8 Supported Rules", fill=WHITE, font=gf(32,True))
    rules = [
        ("Power Rule","d/dx[xⁿ] = n·xⁿ⁻¹",CYAN),("Product Rule","(fg)' = f'g + fg'",LIME),
        ("Quotient Rule","(f/g)' = (f'g-fg')/g²",GOLD),("Chain Rule","d/dx[f(g(x))] = f'(g(x))·g'(x)",CORAL),
        ("Trig Functions","sin, cos, tan, csc, sec, cot",MAGENTA),("Log & Exp","ln(x), eˣ, logₐ(x)",SKY),
        ("Inverse Trig","arcsin, arccos, arctan...",PURPLE_LIGHT),("Hyperbolic","sinh, cosh, tanh...",MINT),
    ]
    for i, (name, formula, color) in enumerate(rules):
        rd = 15+i*5
        if f > rd:
            p = min(1.0, (f-rd)/12)
            sl = int(30*(1-ease(p)))
            ry = 220+i*60
            rrect(d, [rx+sl, ry, rx+480+sl, ry+50], 10, CARD, outline=color, w=1)
            d.text((rx+20+sl, ry+6), name, fill=color, font=gf(17,True))
            d.text((rx+20+sl, ry+28), formula, fill=GRAY, font=gf(13))
    
    return img

def scene_slope_limits(f):
    img = Image.new("RGB", (W,H)); d = ImageDraw.Draw(img); gradient_fun(d, (10,20,35), (18,15,45), (8,12,32))
    draw_stars(d, f, 15)
    
    cx = W//2
    
    # Left: Slope
    d.text((400, 45), "Find Slope at Any Point", fill=WHITE, font=gf(36,True), anchor="mm")
    
    px1, py1 = 100, 90
    pw1, ph1 = 560, 460
    rrect(d, [px1, py1, px1+pw1, py1+ph1], 16, CARD, outline=CYAN, w=2)
    
    slope_steps = [("Given:","y = x³ - 2x + 1 at x = 2"),("Differentiate:","y' = 3x² - 2"),("Substitute:","y' = 3(2)² - 2 = 10"),("Slope:","m = 10")]
    sy = py1 + 20
    for i, (lbl, val) in enumerate(slope_steps):
        sd = 10+i*10
        if f > sd:
            p = min(1.0, (f-sd)/12)
            sl = int(20*(1-ease(p)))
            is_result = i==3
            d.ellipse([px1+28+sl, sy, px1+44+sl, sy+16], fill=CYAN if is_result else (50,50,80))
            d.text((px1+36+sl, sy+8), str(i+1), fill=WHITE, font=gf(10,True), anchor="mm")
            if i<3: d.line([(px1+36+sl,sy+16),(px1+36+sl,sy+44)], fill=(50,50,80), width=1)
            d.text((px1+55+sl, sy), lbl, fill=CYAN if is_result else WHITE, font=gf(14,True))
            rrect(d, [px1+55+sl, sy+20, px1+pw1-20, sy+42], 6, CARD2)
            d.text((px1+65+sl, sy+24), val, fill=GRAY, font=gf(13))
            sy += 58
    
    d.text((px1+20, py1+260), "Supports:", fill=WHITE, font=gf(14,True))
    for i, eq in enumerate(["Explicit: y = f(x)","Implicit: F(x,y) = 0","Parametric: x(t), y(t)"]):
        d.text((px1+30, py1+285+i*28), "•  " + eq, fill=GRAY, font=gf(13))
    
    # Right: Limits
    d.text((1420, 45), "Evaluate Any Limit", fill=WHITE, font=gf(36,True), anchor="mm")
    
    px2, py2 = 1100, 90
    pw2, ph2 = 560, 460
    rrect(d, [px2, py2, px2+pw2, py2+ph2], 16, CARD, outline=PURPLE, w=2)
    
    methods = [("Substitution","Plug in directly",CYAN),("Factoring","Factor & cancel",LIME),("LCD","Multiply by LCD",GOLD),("Conjugate","Multiply by conjugate",CORAL)]
    for i, (name, desc, color) in enumerate(methods):
        md = 15+i*8
        if f > md:
            p = min(1.0, (f-md)/12)
            sl = int(30*(1-ease(p)))
            my = py2+20+i*70
            rrect(d, [px2+20+sl, my, px2+pw2-20+sl, my+55], 10, CARD2, outline=color, w=1)
            d.text((px2+40+sl, my+8), name, fill=color, font=gf(18,True))
            d.text((px2+40+sl, my+34), desc, fill=GRAY, font=gf(14))
    
    d.text((px2+20, py2+310), "Also Handles:", fill=WHITE, font=gf(16,True))
    for i, e in enumerate(["Limits at Infinity","Rational, Radical, Trig forms"]):
        d.text((px2+30, py2+340+i*26), "•  " + e, fill=GRAY, font=gf(14))
    
    # Bottom
    if f > 50:
        d.text((cx, H-170), "And Even More...", fill=WHITE, font=gf(30,True), anchor="mm")
        more = [("Inequalities","Linear, Quadratic, Rational",CYAN),("Circles","Center, Radius, General Form",LIME),("Distance","Between Two Points",GOLD),("Midpoint","Find the Middle Point",CORAL)]
        for i, (name, desc, color) in enumerate(more):
            mx = 180 + i*420
            rrect(d, [mx, H-140, mx+380, H-55], 12, CARD, outline=color, w=2)
            d.text((mx+20, H-130), name, fill=color, font=gf(19,True))
            d.text((mx+20, H-100), desc, fill=GRAY, font=gf(14))
    
    draw_student_fun(d, cx, H-190, s=1.1, pose="point", f=f, shirt_color=PURPLE)
    return img

def scene_cta(f):
    img = Image.new("RGB", (W,H)); d = ImageDraw.Draw(img); gradient_fun(d, (10,15,40), (20,10,50), (5,20,45))
    draw_confetti(d, f, 50)
    draw_stars(d, f, 20)
    
    cx, cy = W//2, H//2
    
    # Logo
    draw_logo(d, cx, cy-180, max(10, int(120 + 10*math.sin(f*0.1))))
    
    d.text((cx, cy-60), "Start Solving Today", fill=WHITE, font=gf(60,True), anchor="mm")
    d.text((cx, cy+10), "Midterm & Final topics covered — Join thousands of students", fill=GRAY, font=gf(24), anchor="mm")
    
    # Platform badges
    platforms = [("Android",LIME),("iOS",GRAY),("Web",CYAN),("Desktop",CORAL)]
    bw = 170
    total = len(platforms)*bw + (len(platforms)-1)*25
    sx = cx - total//2
    
    for i, (p, color) in enumerate(platforms):
        pd = 15+i*4
        if f > pd:
            b = ease_bounce(min(1.0, (f-pd)/20))
            yoff = int((1-b)*50)
            x = sx+i*(bw+25)
            rrect(d, [x, cy+60+yoff, x+bw, cy+120+yoff], 12, color)
            d.text((x+bw//2, cy+90+yoff), p, fill=WHITE, font=gf(22,True), anchor="mm")
    
    # Stats
    if f > 30:
        stats = [("6+","Topics"),("Midterm+Final","Exam Ready"),("100%","Offline"),("Free","Forever")]
        for i, (val, lbl) in enumerate(stats):
            sx_s = cx-300+i*200
            d.text((sx_s, cy+170), val, fill=CYAN, font=gf(36,True), anchor="mm")
            d.text((sx_s, cy+210), lbl, fill=GRAY, font=gf(16), anchor="mm")
    
    # Student
    if f > 10:
        draw_student_fun(d, cx, cy+280, s=1.6, pose="excited", f=f, shirt_color=CYAN)
    
    return img

# ═══════════════════════════════════════════════════════
# BUILD
# ═══════════════════════════════════════════════════════

def get_dur(path):
    r = subprocess.run(["ffprobe","-v","quiet","-print_format","json","-show_format",path], capture_output=True, text=True)
    return float(json.loads(r.stdout)["format"]["duration"])

scenes = [
    ("01_title", scene_title),
    ("02_pain", scene_pain_point),
    ("03_solution", scene_solution),
    ("04_derivatives", scene_derivatives),
    ("05_slope_limits", scene_slope_limits),
    ("06_cta", scene_cta),
]

frame_idx = 0
seg_info = []

for sname, sfunc in scenes:
    apath = os.path.join(NARRATION_DIR, f"{sname}.mp3")
    if not os.path.exists(apath):
        alt_map = {"02_pain":"02_features","03_solution":"02_features","05_slope_limits":"04_slope","06_cta":"07_title"}
        apath = os.path.join(NARRATION_DIR, f"{alt_map.get(sname, sname)}.mp3")
    
    dur = get_dur(apath) if os.path.exists(apath) else 5.0
    nf = int((dur+1.0)*FPS)
    
    print(f"Rendering {sname}: {dur:.1f}s ({nf} frames)")
    
    for i in range(nf):
        frame = sfunc(f=i)
        
        # Smooth fade
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
    if not os.path.exists(apath):
        alt_map = {"02_pain":"02_features","03_solution":"02_features","05_slope_limits":"04_slope","06_cta":"07_title"}
        apath = os.path.join(NARRATION_DIR, f"{alt_map.get(sname, sname)}.mp3")
    
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
