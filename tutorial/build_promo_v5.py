"""MathCalcu Promo v5 — Realistic app UI mockups matching actual design."""
import os, subprocess, json, math, shutil, random
from PIL import Image, ImageDraw, ImageFont

BASE = os.path.dirname(__file__)
FRAMES_DIR = os.path.join(BASE, "promo_frames_v5")
NARR_DIR = os.path.join(BASE, "narration_promo")
OUTPUT = os.path.join(BASE, "mathcalcu_promo_v5.mp4")
LOGO_PATH = os.path.join(BASE, "..", "assets", "images", "app_icon.png")
os.makedirs(FRAMES_DIR, exist_ok=True)

W, H = 1920, 1080
FPS = 30

# Real app colors from theme_provider.dart
SURFACE = (10, 10, 15)        # #0A0A0F
CARD = (18, 18, 26)           # #12121A
CARD2 = (13, 13, 20)          # #0D0D14
TEXT1 = (232, 232, 240)       # #E8E8F0
TEXT2 = (232, 232, 240, 102)  # rgba(232,232,240,0.4)
ACCENT = (108, 99, 255)      # #6C63FF
GOLD = (255, 215, 0)

# Module accent colors from module_registry.dart
MOD_INEQUALITY = (108, 99, 255)   # Purple
MOD_SLOPE = (0, 194, 255)         # Cyan
MOD_MIDPOINT = (233, 236, 239)    # Silver
MOD_DISTANCE = (78, 205, 196)     # Teal
MOD_POINT_SLOPE = (168, 85, 247)  # Electric purple
MOD_TWO_POINT = (245, 158, 11)    # Amber
MOD_Y_INTERCEPT = (16, 185, 129)  # Emerald
MOD_PARALLEL = (6, 182, 212)      # Cyan
MOD_CIRCLE = (6, 182, 212)        # Cyan

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
    else:
        rr(d, [cx-50, cy-50, cx+50, cy+50], 15, ACCENT)
        d.text((cx, cy), "f", fill=TEXT1, font=gf(60, True), anchor="mm")

def draw_phone(d, px, py, pw, ph):
    """Draw realistic phone frame."""
    # Shadow
    for i in range(8, 0, -1):
        alpha = int(30 * (1 - i/8))
        rr(d, [px-i*2, py-i*2, px+pw+i*2, py+ph+i*2], 35, (alpha, alpha, alpha))
    # Phone body
    rr(d, [px, py, px+pw, py+ph], 30, (25, 25, 35), outline=(50, 50, 65), w=2)
    # Screen
    rr(d, [px+8, py+35, px+pw-8, py+ph-8], 5, SURFACE)
    # Notch
    rr(d, [px+pw//2-35, py+6, px+pw//2+35, py+22], 10, (30, 30, 40))

def ctext(d, y, text, fill, size, cx=W//2):
    f = gf(size, True)
    d.text((cx+2, y+2), text, fill=(0,0,0), font=f, anchor="mt")
    d.text((cx, y), text, fill=fill, font=f, anchor="mt")

def draw_bg(d):
    for y in range(H):
        t = y / H
        c = tuple(int(SURFACE[i]*(1-t) + (15,15,25)[i]*t) for i in range(3))
        d.line([(0, y), (W, y)], fill=c)

def draw_module_card(d, x, y, w, h, icon_text, label, subtitle, accent, scale=1.0):
    """Draw a realistic module card matching the app."""
    sw, sh = int(w*scale), int(h*scale)
    sx, sy = x + (w-sw)//2, y + (h-sh)//2
    # Card
    rr(d, [sx, sy, sx+sw, sy+sh], 16, CARD, outline=(*accent, 80), w=1)
    # Icon circle
    icon_r = int(22 * scale)
    icon_cx, icon_cy = sx + 35, sy + sh//2
    rr(d, [icon_cx-icon_r, icon_cy-icon_r, icon_cx+icon_r, icon_cy+icon_r],
       icon_r, (*accent, 30))
    d.text((icon_cx, icon_cy), icon_text, fill=accent, font=gf(int(18*scale), True), anchor="mm")
    # Label
    d.text((sx + 70, sy + int(18*scale)), label, fill=TEXT1, font=gf(int(16*scale), True))
    # Subtitle
    d.text((sx + 70, sy + int(42*scale)), subtitle, fill=(*TEXT2[:3],), font=gf(int(11*scale)))
    return (sx, sy, sw, sh)

def draw_input_field(d, x, y, w, h, text, placeholder="", cursor=True, f=0):
    """Draw realistic input field."""
    rr(d, [x, y, x+w, y+h], 12, CARD2, outline=(50, 50, 70), w=1)
    if text:
        d.text((x+16, y+12), text, fill=TEXT1, font=gf(18))
    elif placeholder:
        d.text((x+16, y+12), placeholder, fill=(*TEXT2[:3],), font=gf(18))
    # Cursor
    if cursor and text and f % 30 < 15:
        tw = d.textlength(text, font=gf(18))
        d.line([(x+16+tw+2, y+10), (x+16+tw+2, y+h-10)], fill=ACCENT, width=2)

def draw_button(d, x, y, w, h, text, color=ACCENT):
    """Draw realistic button."""
    rr(d, [x, y, x+w, y+h], 12, color)
    d.text((x+w//2, y+h//2), text, fill=TEXT1, font=gf(16, True), anchor="mm")

def draw_step_card(d, x, y, w, h, title, content, accent, step_num=None):
    """Draw solution step card."""
    rr(d, [x, y, x+w, y+h], 10, CARD, outline=(*accent, 60), w=1)
    if step_num is not None:
        rr(d, [x+12, y+12, x+36, y+36], 12, accent)
        d.text((x+24, y+24), str(step_num), fill=TEXT1, font=gf(12, True), anchor="mm")
        tx = x + 48
    else:
        tx = x + 16
    d.text((tx, y+12), title, fill=accent, font=gf(14, True))
    d.text((x+16, y+38), content, fill=TEXT1, font=gf(13))

# ═══════════════════════════════════════════════════════
# SCENES — Realistic app UI
# ═══════════════════════════════════════════════════════

def scene_hook(f):
    img = Image.new("RGB", (W, H), (0,0,0)); d = ImageDraw.Draw(img)
    if f < 15: pass
    elif f < 20:
        intensity = 1 - (f-15)/5
        overlay = Image.new("RGB", (W, H), (255,255,255))
        img = Image.blend(img, overlay, intensity*0.4)
        d = ImageDraw.Draw(img)
    elif f < 50:
        t = ease_back(min(1,(f-20)/15))
        sz = int(80*t)
        if sz > 10: ctext(d, H//2-30, "MATHCALCU", ACCENT, sz)
        if f > 35: ctext(d, H//2+60, "MATH SOLVER FOR BSCS", (150,150,170), 28)
    else:
        ctext(d, H//2-30, "MATHCALCU", ACCENT, 80)
        ctext(d, H//2+60, "MATH SOLVER FOR BSCS", (150,150,170), 28)
    return img

def scene_problem(f):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    ctext(d, 80, "CALCULUS PROBLEMS?", (255,80,80), 52)
    if f > 10:
        rr(d, [W//2-350, 220, W//2+350, 360], 16, CARD, outline=(255,100,80), w=2)
        ctext(d, 250, "f(x) = sin(x^2) + ln(cos(x))", TEXT1, 26)
        ctext(d, 300, "Find the derivative...", (150,150,170), 18)
    if f > 30:
        ctext(d, 440, "Your textbook is not helping.", (150,150,170), 22)
        ctext(d, 500, "There is a better way.", ACCENT, 30)
    return img

def scene_app_reveal(f):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    cx, cy = W//2, H//2
    # Phone drops in
    ph_y = int(lerp(-600, cy-300, ease_back(min(1,f/25)))) if f < 25 else cy-300
    draw_phone(d, cx-130, ph_y, 260, 580)
    # App header in phone
    rr(d, [cx-118, ph_y+35, cx+118, ph_y+75], 0, ACCENT)
    d.text((cx, ph_y+55), "MathCalcu", fill=TEXT1, font=gf(18, True), anchor="mm")
    # Module cards in phone (2 columns)
    modules = [
        ("Ineq", MOD_INEQUALITY), ("Slope", MOD_SLOPE),
        ("Midpt", MOD_MIDPOINT), ("Dist", MOD_DISTANCE),
        ("P-Slp", MOD_POINT_SLOPE), ("2-Pt", MOD_TWO_POINT),
        ("Y-Int", MOD_Y_INTERCEPT), ("Circ", MOD_CIRCLE),
    ]
    if f > 15:
        for i, (name, color) in enumerate(modules):
            row, col = divmod(i, 2)
            card_t = ease_back(min(1,(f-15-i*3)/10))
            mx = cx - 115 + col * 120
            my = ph_y + 90 + row * 60
            w, h = int(110*card_t), int(50*card_t)
            if w > 30:
                rr(d, [mx, my, mx+w, my+h], 8, CARD, outline=(*color, 80), w=1)
                if card_t > 0.7:
                    d.text((mx+w//2, my+h//2), name, fill=color, font=gf(11, True), anchor="mm")
    # App name below phone
    if f > 30:
        t = ease(min(1,(f-30)/15))
        ctext(d, ph_y+610, "MathCalcu", TEXT1, int(36*t))
        if f > 40:
            ctext(d, ph_y+660, "Powered Math System for BSCS", (150,150,170), int(18*t))
    return img

def scene_modules(f):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    ctext(d, 40, "8 SPECIALIZED MODULES", ACCENT, 44)
    
    modules_data = [
        ("Inequalities", "Strict, Non-strict, Absolute", MOD_INEQUALITY),
        ("Slope", "Find slope between two points", MOD_SLOPE),
        ("Midpoint", "Center point between coords", MOD_MIDPOINT),
        ("Distance", "Calculate distance between pts", MOD_DISTANCE),
        ("Point-Slope", "y - y1 = m(x - x1)", MOD_POINT_SLOPE),
        ("Two-Point", "Slope from two coordinates", MOD_TWO_POINT),
        ("Y-Intercept", "Where line crosses Y-axis", MOD_Y_INTERCEPT),
        ("Circles", "Standard, General, Center-Radius", MOD_CIRCLE),
    ]
    
    cw, ch = 400, 80
    gap = 15
    cols = 2
    grid_w = cols * cw + (cols-1) * gap
    sx = (W - grid_w) // 2
    sy = 110
    
    for i, (label, sub, color) in enumerate(modules_data):
        row, col = divmod(i, cols)
        delay = i * 5
        if f < delay: continue
        t = ease_back(min(1, (f-delay)/12))
        mx = sx + col * (cw + gap)
        my = sy + row * (ch + gap)
        # Card
        rr(d, [mx, my, mx+cw, my+ch], 12, CARD, outline=(*color, 60), w=1)
        # Icon
        rr(d, [mx+12, my+12, mx+52, my+52], 10, (*color, 25))
        d.text((mx+32, my+32), label[0], fill=color, font=gf(20, True), anchor="mm")
        # Text
        d.text((mx+65, my+15), label, fill=TEXT1, font=gf(16, True))
        d.text((mx+65, my+40), sub, fill=(150,150,170), font=gf(12))
    return img

def scene_derivatives(f):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    # Phone mockup showing derivatives screen
    px, py, pw, ph = W//2-150, 60, 300, 850
    draw_phone(d, px, py, pw, ph)
    
    # Header
    rr(d, [px+8, py+35, px+pw-8, py+75], 0, ACCENT)
    d.text((px+pw//2, py+55), "Derivatives", fill=TEXT1, font=gf(16, True), anchor="mm")
    
    # Back arrow
    d.text((px+20, py+55), "<", fill=TEXT1, font=gf(20), anchor="mm")
    
    # Input field
    expr = "sin(x^2) + ln(cos(x))"
    n = min(len(expr), max(0, (f-10)*2))
    draw_input_field(d, px+15, py+90, pw-30, 50, expr[:n], "Enter expression...", f=f)
    
    # Solve button
    if f > 40:
        draw_button(d, px+15, py+155, pw-30, 45, "SOLVE")
    
    # Result
    if f > 60:
        rt = ease(min(1,(f-60)/15))
        # Result card
        rr(d, [px+15, py+220, px+pw-15, py+520], 12, CARD, outline=(*MOD_INEQUALITY, 60), w=1)
        d.text((px+30, py+240), "f'(x) =", fill=(150,150,170), font=gf(14))
        d.text((px+30, py+270), "2x*cos(x^2) - tan(x)", fill=TEXT1, font=gf(18, True))
        
        # Steps
        steps = [
            ("Chain Rule on sin(x^2)", "cos(x^2) * 2x", 1),
            ("Chain Rule on ln(cos(x))", "-sin(x)/cos(x) = -tan(x)", 2),
            ("Combine", "2x*cos(x^2) - tan(x)", 3),
        ]
        for i, (title, content, num) in enumerate(steps):
            sd = 70 + i * 15
            if f > sd:
                sy = py + 320 + i * 60
                draw_step_card(d, px+20, sy, pw-40, 50, title, content, ACCENT, num)
    
    # Rules on right side
    if f > 50:
        rx = px + pw + 60
        ctext(d, 100, "RULES DETECTED", ACCENT, 28)
        rules = ["Chain Rule", "Power Rule", "Product Rule", "Quotient Rule", "All 6 Trig", "Log & Exp"]
        for i, rule in enumerate(rules):
            if f > 55 + i * 8:
                ry = 160 + i * 55
                rr(d, [rx, ry, rx+500, ry+42], 10, CARD, outline=(*MOD_SLOPE, 40), w=1)
                d.text((rx+16, ry+12), rule, fill=MOD_SLOPE, font=gf(16, True))
    
    return img

def scene_limits(f):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    px, py, pw, ph = W//2-150, 60, 300, 850
    draw_phone(d, px, py, pw, ph)
    
    rr(d, [px+8, py+35, px+pw-8, py+75], 0, ACCENT)
    d.text((px+pw//2, py+55), "Evaluating Limits", fill=TEXT1, font=gf(16, True), anchor="mm")
    d.text((px+20, py+55), "<", fill=TEXT1, font=gf(20), anchor="mm")
    
    # 4 method cards
    methods = [
        ("By Substitution", "Direct plug-in", MOD_SLOPE),
        ("By Factoring", "Remove indeterminate", MOD_DISTANCE),
        ("By LCD", "Complex fractions", MOD_TWO_POINT),
        ("By Conjugate", "Radical expressions", MOD_POINT_SLOPE),
    ]
    for i, (name, desc, color) in enumerate(methods):
        md = i * 12
        if f > md:
            mt = ease_back(min(1,(f-md)/10))
            my = py + 90 + i * 75
            rr(d, [px+15, my, px+pw-15, my+65], 10, CARD, outline=(*color, 60), w=1)
            d.text((px+30, my+12), name, fill=color, font=gf(14, True))
            d.text((px+30, my+36), desc, fill=(150,150,170), font=gf(11))
    
    # Right side: demo
    if f > 50:
        rx = px + pw + 60
        rr(d, [rx, 150, rx+550, 350], 12, CARD, outline=(*MOD_SLOPE, 60), w=1)
        d.text((rx+20, 170), "By Substitution", fill=MOD_SLOPE, font=gf(18, True))
        d.text((rx+20, 210), "lim(x->2) x^2 + 3x", fill=TEXT1, font=gf(16))
        d.text((rx+20, 260), "= 4 + 6 = 10", fill=MOD_DISTANCE, font=gf(20, True))
        d.text((rx+20, 300), "Direct plug-in works!", fill=(150,150,170), font=gf(13))
    
    if f > 70:
        rx = px + pw + 60
        rr(d, [rx, 380, rx+550, 580], 12, CARD, outline=(*MOD_DISTANCE, 60), w=1)
        d.text((rx+20, 400), "By Factoring", fill=MOD_DISTANCE, font=gf(18, True))
        d.text((rx+20, 440), "lim(x->2) (x^2-4)/(x-2)", fill=TEXT1, font=gf(16))
        d.text((rx+20, 490), "= lim(x->2) (x+2) = 4", fill=MOD_DISTANCE, font=gf(20, True))
    
    return img

def scene_geometry(f):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    ctext(d, 40, "ANALYTIC GEOMETRY", MOD_CIRCLE, 44)
    
    # Left: circles screen mockup
    px, py, pw, ph = 100, 100, 350, 700
    draw_phone(d, px, py, pw, ph)
    rr(d, [px+8, py+35, px+pw-8, py+75], 0, MOD_CIRCLE)
    d.text((px+pw//2, py+55), "Circles", fill=TEXT1, font=gf(16, True), anchor="mm")
    
    # Input
    draw_input_field(d, px+15, py+90, pw-30, 45, "x^2+y^2-6x+4y-3=0", f=f)
    
    # Results
    if f > 30:
        results = [
            ("Center", "(3, -2)", MOD_CIRCLE),
            ("Radius", "4", MOD_DISTANCE),
            ("Standard", "(x-3)^2+(y+2)^2=16", MOD_SLOPE),
        ]
        for i, (label, val, color) in enumerate(results):
            ry = py + 155 + i * 55
            rr(d, [px+15, ry, px+pw-15, ry+45], 8, CARD, outline=(*color, 60), w=1)
            d.text((px+30, ry+12), label, fill=(150,150,170), font=gf(12))
            d.text((px+30, ry+30), val, fill=color, font=gf(14, True))
    
    # Right side: other features
    features = [
        ("Distance & Midpoint", "A(1,2) to B(4,6) = 5 units", MOD_DISTANCE),
        ("Slope & Intercept", "(2,3) to (5,9) -> y = 2x - 1", MOD_Y_INTERCEPT),
        ("Inequalities", "|x - 2| < 5 -> -3 < x < 7", MOD_INEQUALITY),
    ]
    for i, (title, desc, color) in enumerate(features):
        if f > 40 + i * 15:
            ft = ease_back(min(1,(f-40-i*15)/10))
            fx = 600
            fy = int(lerp(150, 180+i*150, ft))
            rr(d, [fx, fy, fx+600, fy+120], 12, CARD, outline=(*color, 60), w=1)
            d.text((fx+20, fy+15), title, fill=color, font=gf(18, True))
            d.text((fx+20, fy+50), desc, fill=(150,150,170), font=gf(14))
    return img

def scene_offline(f):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    cy = H//2
    ctext(d, cy-120, "100% OFFLINE", MOD_DISTANCE, 64)
    ctext(d, cy-30, "No internet required", (150,150,170), 28)
    ctext(d, cy+20, "No API calls", (150,150,170), 22)
    ctext(d, cy+60, "No waiting", (150,150,170), 22)
    ctext(d, cy+120, "All 8 modules on-device", TEXT1, 24)
    return img

def scene_latex(f):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    cx = W//2
    ctext(d, 100, "LaTeX RENDERED", MOD_POINT_SLOPE, 52)
    
    # Before/after comparison
    # Plain text
    rr(d, [cx-420, 200, cx-20, 350], 12, CARD, outline=(80,80,100), w=2)
    d.text((cx-400, 220), "Plain Text:", fill=(150,150,170), font=gf(14))
    d.text((cx-400, 260), "x^2 + y^2 = r^2", fill=TEXT1, font=gf(22))
    d.text((cx-400, 300), "f'(x) = 2x*cos(x^2)", fill=TEXT1, font=gf(18))
    
    # Arrow
    if f > 20:
        ctext(d, 280, ">>", ACCENT, 40)
    
    # LaTeX rendered
    if f > 25:
        t = ease_back(min(1,(f-25)/12))
        rr(d, [cx+20, 200, cx+420, 350], 12, CARD, outline=(*MOD_POINT_SLOPE, int(60*t+20)), w=int(2*t+1))
        d.text((cx+40, 220), "LaTeX:", fill=MOD_POINT_SLOPE, font=gf(14))
        d.text((cx+40, 260), "x^2 + y^2 = r^2", fill=TEXT1, font=gf(28, True))
        d.text((cx+40, 300), "f'(x) = 2x*cos(x^2)", fill=TEXT1, font=gf(22, True))
    
    ctext(d, 420, "ACADEMIC PRECISION", TEXT1, 26)
    ctext(d, 470, "Same standard used in research papers", (150,150,170), 18)
    return img

def scene_platform(f):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    ctext(d, 80, "CROSS-PLATFORM", MOD_SLOPE, 52)
    
    devices = [
        ("Android", 150, MOD_DISTANCE),
        ("iOS", 530, MOD_SLOPE),
        ("Web", 910, MOD_TWO_POINT),
        ("Desktop", 1290, MOD_POINT_SLOPE),
    ]
    for i, (name, dx, color) in enumerate(devices):
        if f > i * 12:
            dt = ease_back(min(1,(f-i*12)/10))
            dy = int(lerp(100, 200, dt))
            if i < 2:
                draw_phone(d, dx, dy, 140, 280)
            elif i == 2:
                rr(d, [dx, dy, dx+220, dy+160], 8, CARD, outline=(*color, 60), w=2)
                rr(d, [dx+80, dy+160, dx+140, dy+175], 3, color)
            else:
                rr(d, [dx, dy, dx+220, dy+150], 5, CARD, outline=(*color, 60), w=2)
                rr(d, [dx+70, dy+150, dx+150, dy+165], 3, color)
            d.text((dx+70, dy+310), name, fill=color, font=gf(20, True), anchor="mt")
    
    ctext(d, 560, "ONE CODEBASE. EVERYWHERE.", TEXT1, 28)
    ctext(d, 610, "Built with Flutter", (150,150,170), 18)
    return img

def scene_cta(f):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img)
    # Gradient
    for y in range(H):
        t = y/H
        r=int(ACCENT[0]*(1-t)); g=int(ACCENT[1]*(1-t)+100*t); b=int(ACCENT[2]*(1-t)+180*t)
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

print("Building promo v5 (realistic UI)...")
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
cl = os.path.join(BASE,"_concat_v5.txt")
with open(cl,"w") as f:
    for s in seg_files: f.write(f"file '{s}'\n")

concat_out = os.path.join(BASE, "mathcalcu_promo_v5.mp4")
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
