"""MathCalcu Promo v6 — Correct features, no overlaps, proper spacing."""
import os, subprocess, json, math, shutil
from PIL import Image, ImageDraw, ImageFont

BASE = os.path.dirname(__file__)
FRAMES_DIR = os.path.join(BASE, "promo_frames_v6")
NARR_DIR = os.path.join(BASE, "narration_promo")
OUTPUT = os.path.join(BASE, "mathcalcu_promo_v6.mp4")
LOGO_PATH = os.path.join(BASE, "..", "assets", "images", "app_icon.png")
os.makedirs(FRAMES_DIR, exist_ok=True)

W, H = 1920, 1080
FPS = 30

# Real app colors
SURFACE = (10, 10, 15)
CARD = (18, 18, 26)
CARD2 = (13, 13, 20)
TEXT1 = (232, 232, 240)
TEXT2 = (150, 150, 170)
ACCENT = (108, 99, 255)
GOLD = (255, 215, 0)

# Module colors (exact from codebase)
C_INEQ = (108, 99, 255)      # Purple
C_SLOPE = (0, 194, 255)      # Cyan
C_MID = (233, 236, 239)      # Silver
C_DIST = (78, 205, 196)      # Teal
C_PSLP = (168, 85, 247)      # Electric purple
C_2PT = (245, 158, 11)       # Amber
C_YINT = (16, 185, 129)      # Emerald
C_PAR = (6, 182, 212)        # Cyan
C_CIRC = (6, 182, 212)       # Cyan
# Finals colors
C_DERIV = (255, 209, 102)    # Soft yellow
C_SLOPED = (239, 71, 111)    # Rose
C_LIM = (255, 176, 32)       # Amber
C_LIMINF = (255, 107, 53)    # Deep orange

LOGO = None
if os.path.exists(LOGO_PATH):
    try: LOGO = Image.open(LOGO_PATH).convert("RGBA")
    except: pass

def gf(sz, b=False):
    for p in ["C:/Windows/Fonts/segoeuib.ttf" if b else "C:/Windows/Fonts/segoeui.ttf",
              "C:/Windows/Fonts/arialbd.ttf" if b else "C:/Windows/Fonts/arial.ttf"]:
        if os.path.exists(p):
            try: return ImageFont.truetype(p, sz)
            except: pass
    return ImageFont.load_default()

def ease(t): return max(0, min(1, 1-(1-t)**3))
def ease_back(t):
    c1=1.70158; c3=c1+1
    return max(0, min(1, 1+c3*(t-1)**3+c1*(t-1)**2))
def lerp(a, b, t): return a + (b - a) * t

def rr(d, xy, r, fill, outline=None, w=2):
    d.rounded_rectangle(xy, r, fill=fill, outline=outline, width=w)

def draw_logo(d, cx, cy, sz=100):
    sz = max(10, int(sz))
    if LOGO:
        logo = LOGO.resize((sz, sz), Image.LANCZOS)
        d._image.paste(logo, (cx-sz//2, cy-sz//2), logo)

def draw_phone(d, px, py, pw, ph):
    for i in range(6, 0, -1):
        a = int(25*(1-i/6))
        rr(d, [px-i*2, py-i*2, px+pw+i*2, py+ph+i*2], 30, (a,a,a))
    rr(d, [px, py, px+pw, py+ph], 28, (25,25,35), outline=(50,50,65), w=2)
    rr(d, [px+6, py+30, px+pw-6, py+ph-6], 4, SURFACE)
    rr(d, [px+pw//2-30, py+5, px+pw//2+30, py+18], 8, (30,30,40))

def ctext(d, y, text, fill, size, cx=W//2):
    f = gf(size, True)
    d.text((cx+2, y+2), text, fill=(0,0,0), font=f, anchor="mt")
    d.text((cx, y), text, fill=fill, font=f, anchor="mt")

def draw_bg(d):
    for y in range(H):
        t = y/H
        c = tuple(int(SURFACE[i]*(1-t)+(15,15,25)[i]*t) for i in range(3))
        d.line([(0,y),(W,y)], fill=c)

def draw_card(d, x, y, w, h, accent=None, outline_w=1):
    o = (*accent, 60) if accent else (50,50,70)
    rr(d, [x, y, x+w, y+h], 12, CARD, outline=o, w=outline_w)

# ═══════════════════════════════════════════════════════
# SCENES — proper spacing, no overlaps
# ═══════════════════════════════════════════════════════

def scene_hook(f):
    img = Image.new("RGB", (W, H), (0,0,0)); d = ImageDraw.Draw(img)
    if f < 15: pass
    elif f < 20:
        intensity = 1-(f-15)/5
        img = Image.blend(img, Image.new("RGB",(W,H),(255,255,255)), intensity*0.3)
        d = ImageDraw.Draw(img)
    elif f < 50:
        t = ease_back(min(1,(f-20)/15))
        sz = int(80*t)
        if sz > 10: ctext(d, H//2-30, "MATHCALCU", ACCENT, sz)
        if f > 35: ctext(d, H//2+60, "MATH SOLVER FOR BSCS", TEXT2, 28)
    else:
        ctext(d, H//2-30, "MATHCALCU", ACCENT, 80)
        ctext(d, H//2+60, "MATH SOLVER FOR BSCS", TEXT2, 28)
    return img

def scene_problem(f):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    ctext(d, 100, "CALCULUS PROBLEMS?", (255,80,80), 52)
    if f > 10:
        draw_card(d, W//2-350, 220, 700, 140, (255,100,80), 2)
        ctext(d, 250, "f(x) = sin(x^2) + ln(cos(x))", TEXT1, 26)
        ctext(d, 300, "Find the derivative...", TEXT2, 18)
    if f > 30:
        ctext(d, 460, "Your textbook is not helping.", TEXT2, 22)
        ctext(d, 520, "There is a better way.", ACCENT, 30)
    return img

def scene_app_reveal(f):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    cx, cy = W//2, H//2
    ph_y = int(lerp(-600, cy-300, ease_back(min(1,f/25)))) if f < 25 else cy-300
    draw_phone(d, cx-130, ph_y, 260, 580)
    rr(d, [cx-118, ph_y+30, cx+118, ph_y+65], 0, ACCENT)
    d.text((cx, ph_y+47), "MathCalc", fill=TEXT1, font=gf(16, True), anchor="mm")
    if f > 15:
        modules = [("Ineq",C_INEQ),("Slope",C_SLOPE),("Midpt",C_MID),("Dist",C_DIST),
                   ("P-Slp",C_PSLP),("2-Pt",C_2PT),("Y-Int",C_YINT),("Circ",C_CIRC)]
        for i,(n,c) in enumerate(modules):
            row, col = divmod(i, 2)
            ct = ease_back(min(1,(f-15-i*3)/10))
            mx = cx-115+col*120
            my = ph_y+80+row*55
            w, h = int(110*ct), int(45*ct)
            if w > 30:
                rr(d, [mx,my,mx+w,my+h], 8, CARD, outline=(*c,60), w=1)
                if ct > 0.7: d.text((mx+w//2,my+h//2), n, fill=c, font=gf(10, True), anchor="mm")
    if f > 35:
        t = ease(min(1,(f-35)/15))
        ctext(d, ph_y+600, "MathCalcu", TEXT1, int(36*t))
        if f > 45: ctext(d, ph_y+650, "Powered Math System for BSCS", TEXT2, int(18*t))
    return img

def scene_modules(f):
    """Show ALL modules — Mid Term + Finals."""
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    
    # Title
    ctext(d, 30, "MID TERM MODULES", ACCENT, 36)
    
    # 3 columns, proper spacing
    mid_modules = [
        ("Inequalities", "8 types: Strict, Non-strict,\nAbsolute, Rational, Quadratic...", C_INEQ),
        ("Slope", "Find slope between\ntwo points", C_SLOPE),
        ("Distance", "Distance between\npoints (1D & 2D)", C_DIST),
        ("Midpoint", "Center point\nbetween coords", C_MID),
        ("Point-Slope", "y - y1 = m(x - x1)\nLine equations", C_PSLP),
        ("Two-Point", "Slope from two\ncoordinate points", C_2PT),
        ("Y-Intercept", "Where line crosses\nY-axis", C_YINT),
        ("Parallel / Perp", "Compare two lines\nand their relationship", C_PAR),
        ("Circles", "Standard, General,\nCenter-Radius forms", C_CIRC),
    ]
    
    cols, rows = 3, 3
    cw, ch = 340, 90
    gx, gy = 30, 20
    grid_w = cols*cw + (cols-1)*gx
    sx = (W - grid_w)//2
    sy = 85
    
    for i, (name, sub, color) in enumerate(mid_modules):
        row, col = divmod(i, cols)
        delay = i * 5
        if f < delay: continue
        t = ease_back(min(1, (f-delay)/10))
        mx = sx + col*(cw+gx)
        my = sy + row*(ch+gy)
        draw_card(d, mx, my, cw, ch, color)
        # Icon
        rr(d, [mx+10, my+10, mx+50, my+50], 10, (*color, 25))
        d.text((mx+30, my+30), name[0], fill=color, font=gf(18, True), anchor="mm")
        # Text
        d.text((mx+62, my+14), name, fill=TEXT1, font=gf(15, True))
        lines = sub.split("\n")
        for li, line in enumerate(lines):
            d.text((mx+62, my+38+li*16), line, fill=TEXT2, font=gf(11))
    
    # Finals section
    if f > 60:
        ft = ease(min(1,(f-60)/15))
        fy = sy + 3*(ch+gy) + 20
        ctext(d, fy, "FINALS MODULES", GOLD, 30)
        
        finals = [
            ("Derivatives", "Power, Product,\nQuotient, Chain rules", C_DERIV),
            ("Slope via Derivative", "Tangent line slope\nat a point", C_SLOPED),
            ("Evaluating Limits", "4 methods: Substitution,\nConjugate, Factoring, LCD", C_LIM),
            ("Limits at Infinity", "Horizontal asymptotes\nand end behavior", C_LIMINF),
        ]
        
        fw, fh = 380, 80
        fgx = 30
        fsx = (W - 4*fw - 3*fgx)//2
        fsy = fy + 50
        
        for i, (name, sub, color) in enumerate(finals):
            if f > 70+i*8:
                t = ease_back(min(1,(f-70-i*8)/10))
                fx = fsx + i*(fw+fgx)
                draw_card(d, fx, fsy, fw, fh, color)
                rr(d, [fx+10, fsy+10, fx+50, fsy+50], 10, (*color, 25))
                d.text((fx+30, fsy+30), name[0], fill=color, font=gf(18, True), anchor="mm")
                d.text((fx+62, fsy+12), name, fill=TEXT1, font=gf(14, True))
                lines = sub.split("\n")
                for li, line in enumerate(lines):
                    d.text((fx+62, fsy+34+li*15), line, fill=TEXT2, font=gf(11))
    return img

def scene_derivatives(f):
    """Derivatives module — realistic app UI."""
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    
    # Phone on left
    px, py, pw, ph = 80, 50, 320, 880
    draw_phone(d, px, py, pw, ph)
    rr(d, [px+6, py+30, px+pw-6, py+65], 0, C_DERIV)
    d.text((px+20, py+47), "<", fill=TEXT1, font=gf(18), anchor="mm")
    d.text((px+pw//2, py+47), "Derivatives", fill=TEXT1, font=gf(16, True), anchor="mm")
    
    # Input
    expr = "sin(x^2) + ln(cos(x))"
    n = min(len(expr), max(0, (f-10)*2))
    rr(d, [px+15, py+80, px+pw-15, py+130], 10, CARD2, outline=(50,50,70), w=1)
    if n > 0: d.text((px+30, py+95), expr[:n], fill=TEXT1, font=gf(16))
    else: d.text((px+30, py+95), "Enter expression...", fill=TEXT2, font=gf(16))
    
    # Solve button
    if f > 40:
        rr(d, [px+15, py+145, px+pw-15, py+190], 10, C_DERIV)
        d.text((px+pw//2, py+167), "SOLVE", fill=SURFACE, font=gf(16, True), anchor="mm")
    
    # Result steps
    if f > 60:
        steps = [
            ("Original", "sin(x^2) + ln(cos(x))", 1),
            ("Chain Rule on sin(x^2)", "cos(x^2) * 2x", 2),
            ("Chain Rule on ln(cos(x))", "-tan(x)", 3),
            ("Final Answer", "f'(x) = 2x*cos(x^2) - tan(x)", 4),
        ]
        for i, (title, content, num) in enumerate(steps):
            sd = 60 + i * 12
            if f > sd:
                sy = py + 210 + i * 65
                draw_card(d, px+15, sy, pw-30, 55, C_DERIV)
                rr(d, [px+25, sy+10, px+50, sy+35], 8, C_DERIV)
                d.text((px+37, sy+22), str(num), fill=SURFACE, font=gf(12, True), anchor="mm")
                d.text((px+60, sy+10), title, fill=C_DERIV, font=gf(13, True))
                d.text((px+60, sy+32), content, fill=TEXT1, font=gf(12))
    
    # Right side — features
    rx = px + pw + 80
    ctext(d, 60, "DERIVATIVES", C_DERIV, 42)
    
    features = [
        ("Rules Detected", ["Chain Rule", "Power Rule", "Product Rule", "Quotient Rule", "All 6 Trig Functions", "Log & Exponential"], C_DERIV),
        ("LaTeX Rendered", ["Every step shown in LaTeX", "Same format as research papers"], C_PSLP),
    ]
    
    fy = 130
    for title, items, color in features:
        draw_card(d, rx, fy, 650, 30+len(items)*28, color)
        d.text((rx+20, fy+12), title, fill=color, font=gf(18, True))
        for i, item in enumerate(items):
            d.text((rx+30, fy+42+i*28), f"  {item}", fill=TEXT1, font=gf(14))
        fy += 50 + len(items)*28
    
    # Rules badges
    if f > 80:
        fy += 20
        d.text((rx, fy), "Power, Product, Quotient, Chain", fill=TEXT2, font=gf(14))
        d.text((rx, fy+25), "All 6 Trig, Inverse Trig, Hyperbolic", fill=TEXT2, font=gf(14))
        d.text((rx, fy+50), "Log, Exponential, Square Root", fill=TEXT2, font=gf(14))
    
    return img

def scene_limits(f):
    """Limits module — 4 methods."""
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    px, py, pw, ph = 80, 50, 320, 880
    draw_phone(d, px, py, pw, ph)
    rr(d, [px+6, py+30, px+pw-6, py+65], 0, C_LIM)
    d.text((px+20, py+47), "<", fill=TEXT1, font=gf(18), anchor="mm")
    d.text((px+pw//2, py+47), "Evaluating Limits", fill=TEXT1, font=gf(14, True), anchor="mm")
    
    methods = [
        ("1. Substitution", "Direct plug-in", C_SLOPE),
        ("2. Factoring", "Remove indeterminate", C_DIST),
        ("3. LCD", "Complex fractions", C_2PT),
        ("4. Conjugate", "Radical expressions", C_PSLP),
    ]
    for i, (name, desc, color) in enumerate(methods):
        if f > i*10:
            mt = ease_back(min(1,(f-i*10)/10))
            my = py + 80 + i * 65
            draw_card(d, px+15, my, pw-30, 55, color)
            d.text((px+30, my+10), name, fill=color, font=gf(14, True))
            d.text((px+30, my+32), desc, fill=TEXT2, font=gf(11))
    
    # Right side demos
    rx = px + pw + 80
    ctext(d, 60, "4 METHODS", C_LIM, 42)
    
    demos = [
        ("By Substitution", "lim(x->2) x^2 + 3x = 10", "Direct plug-in works!", C_SLOPE),
        ("By Factoring", "lim(x->2) (x^2-4)/(x-2) = 4", "Factor, cancel, substitute", C_DIST),
    ]
    
    dy = 140
    for title, eq, note, color in demos:
        if f > 50 + demos.index((title,eq,note,color))*20:
            draw_card(d, rx, dy, 650, 120, color)
            d.text((rx+20, dy+12), title, fill=color, font=gf(18, True))
            d.text((rx+20, dy+45), eq, fill=TEXT1, font=gf(16))
            d.text((rx+20, dy+80), note, fill=TEXT2, font=gf(13))
            dy += 140
    
    return img

def scene_geometry(f):
    """Geometry — Circles, Distance, Midpoint, Slope, Inequalities."""
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    ctext(d, 30, "ANALYTIC GEOMETRY", C_CIRC, 44)
    
    features = [
        ("Circles", "Center, Radius, Standard & General form\nInput: x^2+y^2-6x+4y-3=0\nOutput: Center(3,-2), Radius=4", C_CIRC, 0),
        ("Distance & Midpoint", "1D: |x2 - x1|\n2D: sqrt((x2-x1)^2 + (y2-y1)^2)\nWith graphing support", C_DIST, 15),
        ("Slope & Intercept", "Two-point slope\nPoint-slope, Slope-intercept\nParallel & Perpendicular", C_SLOPE, 30),
        ("Inequalities", "8 types: Strict, Non-strict,\nAbsolute, Continued, Simple,\nRational, Quadratic, Radical", C_INEQ, 45),
    ]
    
    card_w, card_h = 850, 130
    sx = (W - card_w) // 2
    sy = 100
    
    for i, (name, desc, color, delay) in enumerate(features):
        if f > delay:
            t = ease_back(min(1,(f-delay)/10))
            fy = sy + i * (card_h + 25)
            # Slide from left
            x_off = int(lerp(-100, 0, t))
            draw_card(d, sx+x_off, fy, card_w, card_h, color, 2)
            # Title
            d.text((sx+25+x_off, fy+15), name, fill=color, font=gf(22, True))
            # Description lines
            lines = desc.split("\n")
            for li, line in enumerate(lines):
                d.text((sx+25+x_off, fy+50+li*22), line, fill=TEXT1, font=gf(14))
    
    return img

def scene_offline(f):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    cy = H//2
    ctext(d, cy-140, "100% OFFLINE", C_DIST, 64)
    ctext(d, cy-50, "No internet required", TEXT2, 28)
    ctext(d, cy, "No API calls. No waiting.", TEXT2, 22)
    ctext(d, cy+50, "All modules run on-device", TEXT1, 24)
    ctext(d, cy+110, "Mid Term + Finals", ACCENT, 20)
    return img

def scene_latex(f):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    cx = W//2
    ctext(d, 80, "LaTeX RENDERED", C_PSLP, 52)
    
    # Before
    draw_card(d, cx-420, 180, 380, 180, TEXT2, 2)
    d.text((cx-400, 200), "Plain Text:", fill=TEXT2, font=gf(14))
    d.text((cx-400, 240), "x^2 + y^2 = r^2", fill=TEXT1, font=gf(22))
    d.text((cx-400, 280), "f'(x) = 2x*cos(x^2)", fill=TEXT1, font=gf(18))
    d.text((cx-400, 320), "y = mx + b", fill=TEXT1, font=gf(18))
    
    if f > 20: ctext(d, 270, ">>", ACCENT, 40)
    
    # After
    if f > 25:
        t = ease_back(min(1,(f-25)/12))
        draw_card(d, cx+40, 180, 380, 180, C_PSLP, int(2*t+1))
        d.text((cx+60, 200), "LaTeX (flutter_math_fork):", fill=C_PSLP, font=gf(14))
        d.text((cx+60, 240), "x^2 + y^2 = r^2", fill=TEXT1, font=gf(28, True))
        d.text((cx+60, 280), "f'(x) = 2x*cos(x^2)", fill=TEXT1, font=gf(22, True))
        d.text((cx+60, 320), "y = mx + b", fill=TEXT1, font=gf(22, True))
    
    ctext(d, 420, "Used in step-by-step solutions", TEXT2, 18)
    ctext(d, 460, "Same format as academic research papers", TEXT2, 18)
    return img

def scene_platform(f):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    ctext(d, 60, "CROSS-PLATFORM", C_SLOPE, 52)
    
    devices = [
        ("Android", 150, C_DIST), ("iOS", 530, C_SLOPE),
        ("Web", 910, C_2PT), ("Desktop", 1290, C_PSLP),
    ]
    for i, (name, dx, color) in enumerate(devices):
        if f > i*12:
            dt = ease_back(min(1,(f-i*12)/10))
            dy = int(lerp(100, 200, dt))
            if i < 2: draw_phone(d, dx, dy, 140, 280)
            elif i == 2:
                draw_card(d, dx, dy, 220, 160, color, 2)
                rr(d, [dx+80, dy+160, dx+140, dy+175], 3, color)
            else:
                draw_card(d, dx, dy, 220, 150, color, 2)
                rr(d, [dx+70, dy+150, dx+150, dy+165], 3, color)
            d.text((dx+70, dy+310), name, fill=color, font=gf(20, True), anchor="mt")
    
    ctext(d, 550, "ONE CODEBASE. EVERYWHERE.", TEXT1, 28)
    ctext(d, 600, "Built with Flutter", TEXT2, 18)
    
    # Additional features
    if f > 50:
        feats = ["Custom Math Keyboard", "Auto-solve on type", "Step-by-step solutions",
                 "Graphing support", "Dark/Light mode", "Fraction support"]
        for i, feat in enumerate(feats):
            if f > 55+i*5:
                col = i % 3
                row = i // 3
                fx = 300 + col * 450
                fy = 660 + row * 50
                d.text((fx, fy), f"  {feat}", fill=TEXT1, font=gf(16))
                d.ellipse([fx, fy+5, fx+10, fy+15], fill=C_SLOPE)
    
    return img

def scene_cta(f):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img)
    for y in range(H):
        t = y/H
        r=int(ACCENT[0]*(1-t)); g=int(ACCENT[1]*(1-t)+80*t); b=int(ACCENT[2]*(1-t)+160*t)
        d.line([(0,y),(W,y)], fill=(r,g,b))
    cx, cy = W//2, H//2
    if f < 25:
        t = ease_back(min(1,f/20))
        draw_logo(d, cx, int(lerp(-250,cy-180,t)), int(120*t))
    else:
        draw_logo(d, cx, cy-180, 120)
    if f > 10: ctext(d, cy-40, "MathCalcu", TEXT1, int(64*ease(min(1,(f-10)/15))))
    if f > 25: ctext(d, cy+40, "Built by BSCS students, for BSCS students", (200,200,220), int(22*ease(min(1,(f-25)/10))))
    if f > 50:
        rr(d, [cx-220, cy+100, cx+220, cy+160], 30, TEXT1, outline=GOLD, w=2)
        d.text((cx, cy+130), "Star on GitHub", fill=(30,30,40), font=gf(20,True), anchor="mm")
        d.text((cx, cy+200), "github.com/Shuash11/MathCalcu", fill=(180,180,200), font=gf(16), anchor="mt")
    if f > 70: ctext(d, cy+260, "Share with your classmates", TEXT1, 22)
    return img

def scene_close(f):
    img = Image.new("RGB", (W, H), (0,0,0)); d = ImageDraw.Draw(img)
    if f < 35:
        t = ease(min(1,f/15)); c = int(255*t)
        ctext(d, H//2, "Math doesn't have to be hard.", (c,c,c), 42)
    elif f < 70:
        ctext(d, H//2, "Math doesn't have to be hard.", TEXT1, 42)
        if f > 50:
            t = 1-ease(min(1,(f-50)/20)); c = int(255*t)
            ctext(d, H//2, "Math doesn't have to be hard.", (c,c,c), 42)
    return img

# ═══════════════════════════════════════════════════════
# BUILD
# ═══════════════════════════════════════════════════════

def get_dur(path):
    r = subprocess.run(["ffprobe","-v","quiet","-show_entries","format=duration",
                       "-of","default=noprint_wrappers=1:nokey=1",path],
                       capture_output=True, text=True)
    return float(r.stdout.strip())

SCENES = [
    ("01_hook",       scene_hook,        3,  "s01_hook.mp3"),
    ("02_problem",    scene_problem,     5,  "s02_problem.mp3"),
    ("03_reveal",     scene_app_reveal,  6,  "s03_reveal.mp3"),
    ("04_modules",    scene_modules,     15, "s04_modules.mp3"),
    ("05_derivatives",scene_derivatives, 13, "s05_derivatives.mp3"),
    ("06_limits",     scene_limits,      10, "s06_limits.mp3"),
    ("07_geometry",   scene_geometry,    12, "s07_geometry.mp3"),
    ("08_offline",    scene_offline,     6,  "s08_offline.mp3"),
    ("09_latex",      scene_latex,       8,  "s09_latex.mp3"),
    ("10_platform",   scene_platform,    8,  "s10_platform.mp3"),
    ("11_cta",        scene_cta,         17, "s11_cta.mp3"),
    ("12_close",      scene_close,       7,  "s12_close.mp3"),
]

print("Building promo v6 (correct features, no overlaps)...")
seg_files = []

for sname, sfunc, dur, narr in SCENES:
    print(f"  {sname}: {dur}s", end="")
    nf = dur * FPS
    sdir = os.path.join(FRAMES_DIR, sname)
    os.makedirs(sdir, exist_ok=True)
    
    for i in range(nf):
        frame = sfunc(f=i)
        if i < 4: frame = Image.blend(Image.new("RGB",(W,H)), frame, ease(i/4))
        elif i >= nf-4: frame = Image.blend(Image.new("RGB",(W,H)), frame, ease((nf-i)/4))
        frame.save(os.path.join(sdir, f"frame_{i:06d}.png"))
    
    seg_mp4 = os.path.join(BASE, f"_seg_{sname}.mp4")
    narr_path = os.path.join(NARR_DIR, narr)
    
    if os.path.exists(narr_path):
        narr_dur = get_dur(narr_path)
        padded = os.path.join(BASE, f"_padded_{sname}.wav")
        if narr_dur > dur:
            subprocess.run(["ffmpeg","-y","-i",narr_path,"-t",str(dur),
                           "-c:a","pcm_s16le",padded], capture_output=True)
        else:
            silence = max(0, dur - narr_dur)
            subprocess.run(["ffmpeg","-y","-i",narr_path,
                "-f","lavfi","-i",f"anullsrc=r=44100:cl=stereo:d={silence}",
                "-filter_complex","[0:a][1:a]concat=n=2:v=0:a=1[out]",
                "-map","[out]","-c:a","pcm_s16le",padded], capture_output=True)
        cmd = ["ffmpeg","-y","-framerate",str(FPS),
               "-i",os.path.join(sdir,"frame_%06d.png"),
               "-i",padded,"-c:v","libx264","-t",str(dur),
               "-c:a","aac","-b:a","192k",
               "-pix_fmt","yuv420p","-r",str(FPS),seg_mp4]
    else:
        cmd = ["ffmpeg","-y","-framerate",str(FPS),
               "-i",os.path.join(sdir,"frame_%06d.png"),
               "-f","lavfi","-i","anullsrc=r=44100:cl=stereo",
               "-c:v","libx264","-t",str(dur),
               "-c:a","aac","-b:a","128k",
               "-pix_fmt","yuv420p","-r",str(FPS),seg_mp4]
    
    r = subprocess.run(cmd, capture_output=True, text=True)
    actual = get_dur(seg_mp4) if r.returncode == 0 else 0
    seg_files.append(seg_mp4)
    print(f" -> {actual:.1f}s")

# Concat
print("\nConcatenating...")
cl = os.path.join(BASE,"_concat_v6.txt")
with open(cl,"w") as f:
    for s in seg_files: f.write(f"file '{s}'\n")

concat_out = os.path.join(BASE, "mathcalcu_promo_v6.mp4")
subprocess.run(["ffmpeg","-y","-f","concat","-safe","0","-i",cl,
    "-c:v","libx264","-c:a","aac","-b:a","192k",
    "-pix_fmt","yuv420p","-movflags","+faststart",concat_out], capture_output=True)

# Mix with music
print("Mixing music...")
music = os.path.join(BASE,"music","elevenlabs_bg_looped.wav")
final = os.path.join(BASE,"mathcalcu_promo_final.mp4")
subprocess.run(["ffmpeg","-y","-i",concat_out,"-i",music,
    "-filter_complex","[0:a]volume=1.0[vo];[1:a]volume=0.45[bg];[vo][bg]amix=inputs=2:duration=first:dropout_transition=0[a]",
    "-map","0:v","-map","[a]","-c:v","copy","-c:a","aac","-b:a","192k",
    "-shortest","-movflags","+faststart",final], capture_output=True)

sz = os.path.getsize(final)/(1024*1024)
dur = get_dur(final)
print(f"\nDONE! {sz:.1f} MB, {dur:.1f}s")

# Cleanup
for s in seg_files:
    if os.path.exists(s): os.remove(s)
for sname,_,_,_ in SCENES:
    d = os.path.join(FRAMES_DIR, sname)
    if os.path.isdir(d): shutil.rmtree(d)
    p = os.path.join(BASE, f"_padded_{sname}.wav")
    if os.path.exists(p): os.remove(p)
if os.path.exists(cl): os.remove(cl)
if os.path.isdir(FRAMES_DIR): shutil.rmtree(FRAMES_DIR)
if os.path.exists(concat_out): os.remove(concat_out)

copy_to = os.path.join(os.path.expanduser("~"),"Downloads","mathcalcu_promo_final.mp4")
shutil.copy2(final, copy_to)
print(f"Copied to {copy_to}")
