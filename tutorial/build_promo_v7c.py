"""Build v7b video — reads narration durations first, builds matched video."""
import os, subprocess, shutil, math
from PIL import Image, ImageDraw, ImageFont

BASE = os.path.dirname(__file__)
NARR_DIR = os.path.join(BASE, "narration_promo")
FRAMES_DIR = os.path.join(BASE, "promo_frames_v7b")

W, H = 1920, 1080
FPS = 30

# Colors
SURFACE = (10, 10, 15)
CARD = (18, 18, 26)
CARD2 = (13, 13, 20)
TEXT1 = (232, 232, 240)
TEXT2 = (150, 150, 170)
ACCENT = (108, 99, 255)
GOLD = (255, 215, 0)
GREEN = (100, 220, 150)
CYAN = (0, 194, 255)
ORANGE = (255, 176, 32)
PINK = (239, 71, 111)
RED = (255, 90, 90)

C_INEQ = (108, 99, 255)
C_SLOPE = (0, 194, 255)
C_MID = (233, 236, 239)
C_DIST = (78, 205, 196)
C_PSLP = (168, 85, 247)
C_2PT = (245, 158, 11)
C_YINT = (16, 185, 129)
C_PAR = (6, 182, 212)
C_CIRC = (6, 182, 212)
C_DERIV = (255, 209, 102)
C_SLOPED = (239, 71, 111)
C_LIM = (255, 176, 32)
C_LIMINF = (255, 107, 53)

LOGO_PATH = os.path.join(BASE, "..", "assets", "images", "app_icon.png")
LOGO = None
if os.path.exists(LOGO_PATH):
    try: LOGO = Image.open(LOGO_PATH).convert("RGBA")
    except: pass

def gf(sz, bold=False):
    for p in ["C:/Windows/Fonts/segoeuib.ttf" if bold else "C:/Windows/Fonts/segoeui.ttf",
              "C:/Windows/Fonts/arialbd.ttf" if bold else "C:/Windows/Fonts/arial.ttf"]:
        if os.path.exists(p):
            try: return ImageFont.truetype(p, sz)
            except: pass
    return ImageFont.load_default()

def ease(t):
    t = max(0, min(1, t))
    return 1 - (1 - t) ** 3

def ease_back(t):
    t = max(0, min(1, t))
    c1 = 1.70158; c3 = c1 + 1
    return 1 + c3 * (t - 1) ** 3 + c1 * (t - 1) ** 2

def lerp(a, b, t):
    return a + (b - a) * max(0, min(1, t))

def rr(d, xy, r, fill, outline=None, w=2):
    d.rounded_rectangle(xy, r, fill=fill, outline=outline, width=w)

def draw_logo(d, cx, cy, sz=100):
    sz = max(10, int(sz))
    if LOGO:
        logo = LOGO.resize((sz, sz), Image.LANCZOS)
        d._image.paste(logo, (cx - sz // 2, cy - sz // 2), logo)

def draw_phone(d, px, py, pw, ph):
    for i in range(8, 0, -1):
        a = int(30 * (1 - i / 8))
        rr(d, [px - i * 2, py - i * 2, px + pw + i * 2, py + ph + i * 2], 30, (a, a, a))
    rr(d, [px, py, px + pw, py + ph], 28, (25, 25, 35), outline=(60, 60, 75), w=2)
    rr(d, [px + 8, py + 32, px + pw - 8, py + ph - 8], 4, SURFACE)
    rr(d, [px + pw // 2 - 35, py + 6, px + pw // 2 + 35, py + 18], 8, (35, 35, 45))

def ctext(d, y, text, fill, size, cx=W // 2):
    f = gf(size, True)
    d.text((cx + 2, y + 2), text, fill=(0, 0, 0), font=f, anchor="mt")
    d.text((cx, y), text, fill=fill, font=f, anchor="mt")

def draw_bg(d):
    for y in range(H):
        t = y / H
        c = tuple(int(SURFACE[i] * (1 - t) + (15, 15, 25)[i] * t) for i in range(3))
        d.line([(0, y), (W, y)], fill=c)

def draw_card(d, x, y, w, h, accent=None, outline_w=1):
    o = (*accent, 60) if accent else (50, 50, 70)
    rr(d, [x, y, x + w, y + h], 12, CARD, outline=o, w=outline_w)

def phone_app_bar(d, px, py, pw, title, color):
    rr(d, [px + 8, py + 32, px + pw - 8, py + 70], 0, color)
    d.text((px + 22, py + 51), "<", fill=TEXT1, font=gf(16), anchor="mm")
    d.text((px + pw // 2, py + 51), title, fill=TEXT1, font=gf(14, True), anchor="mm")

def draw_grid(d, cx, cy, size, color=(40, 40, 60)):
    for i in range(-size, size + 1):
        x = cx + i * 25
        y = cy + i * 25
        if 0 < x < W: d.line([(x, cy - size * 25), (x, cy + size * 25)], fill=color, width=1)
        if 0 < y < H: d.line([(cx - size * 25, y), (cx + size * 25, y)], fill=color, width=1)
    d.line([(cx - size * 25, cy), (cx + size * 25, cy)], fill=(70, 70, 90), width=2)
    d.line([(cx, cy - size * 25), (cx, cy + size * 25)], fill=(70, 70, 90), width=2)

def draw_axis_labels(d, cx, cy, size):
    f = gf(10)
    for i in range(-size, size + 1):
        if i != 0:
            x = cx + i * 25
            y = cy + i * 25
            if 40 < x < W - 40: d.text((x, cy + 8), str(i), fill=TEXT2, font=f, anchor="mt")
            if 40 < y < H - 40: d.text((cx + 5, y), str(-i), fill=TEXT2, font=f, anchor="lt")

def draw_point(d, x, y, color, label=None, sz=4):
    d.ellipse([x - sz, y - sz, x + sz, y + sz], fill=color)
    if label: d.text((x + 8, y - 8), label, fill=color, font=gf(11, True))

def draw_line_on_grid(d, cx, cy, m, b, color):
    pts = []
    for px in range(0, W):
        x_graph = (px - cx) / 25
        y_graph = m * x_graph + b
        py = int(cy - y_graph * 25)
        if 0 < py < H: pts.append((px, py))
    if len(pts) > 1:
        for i in range(len(pts) - 1):
            d.line([pts[i], pts[i + 1]], fill=color, width=2)

def draw_keyboard(d, px, py, pw):
    rr(d, [px, py, px + pw, py + 120], 8, (20, 20, 30))
    rows = [
        ["(", ")", "sqrt", "^", "pi", "e"],
        ["sin", "cos", "tan", "log", "ln", "abs"],
        ["7", "8", "9", "/", "C", "<"],
        ["4", "5", "6", "*", "(", ")"],
        ["1", "2", "3", "-", "x", "y"],
        ["0", ".", "=", "+", "SOLVE"],
    ]
    kw = (pw - 16) // 6
    kh = 17
    for r, row in enumerate(rows):
        for c, key in enumerate(row):
            kx = px + 8 + c * (kw + 1)
            ky = py + 8 + r * (kh + 2)
            if key == "SOLVE":
                rr(d, [kx, ky, kx + kw * 2 + 1, ky + kh], 4, ACCENT)
                d.text((kx + kw, ky + kh // 2), key, fill=TEXT1, font=gf(9, True), anchor="mm")
            else:
                rr(d, [kx, ky, kx + kw, ky + kh], 4, (35, 35, 50), outline=(55, 55, 75), w=1)
                d.text((kx + kw // 2, ky + kh // 2), key, fill=TEXT2, font=gf(8), anchor="mm")

# ═══════════════════════════════════════════════════════════════
# SCENE FUNCTIONS
# ═══════════════════════════════════════════════════════════════

def scene_hook(f, dur):
    img = Image.new("RGB", (W, H), (0, 0, 0)); d = ImageDraw.Draw(img)
    if f < 15: pass
    elif f < 20:
        intensity = 1 - (f - 15) / 5
        img = Image.blend(img, Image.new("RGB", (W, H), (255, 255, 255)), intensity * 0.3)
        d = ImageDraw.Draw(img)
    else:
        t = ease_back(min(1, (f - 20) / 18))
        sz = int(90 * t)
        if sz > 10: ctext(d, H // 2 - 40, "MATHCALCU", ACCENT, sz)
        if f > 38:
            t2 = ease(min(1, (f - 38) / 12))
            ctext(d, H // 2 + 60, "MATH SOLVER FOR BSCS", TEXT2, int(30 * t2))
        if f > 55:
            t3 = ease(min(1, (f - 55) / 10))
            ctext(d, H // 2 + 110, "13 MODULES  |  STEP-BY-STEP  |  GRAPHING", ACCENT, int(18 * t3))
    return img

def scene_problem(f, dur):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    ctext(d, 80, "STUCK ON CALCULUS?", (255, 80, 80), 52)
    problems = [
        ("Derivative", "d/dx[sin(x^2) * ln(cos(x))]", C_DERIV, 15),
        ("Limit", "lim(x->0) (sin(x) - x) / x^3", C_LIM, 25),
        ("Circle", "x^2+y^2-6x+4y-3=0", C_CIRC, 35),
        ("Inequality", "|2x - 3| > 5", C_INEQ, 45),
    ]
    for i, (label, expr, color, delay) in enumerate(problems):
        if f > delay:
            t = ease_back(min(1, (f - delay) / 10))
            py = 180 + i * 95
            draw_card(d, W // 2 - 350, py, 700, 80, color, 2)
            rr(d, [W // 2 - 335, py + 15, W // 2 - 220, py + 65], 8, (*color, 40))
            d.text((W // 2 - 278, py + 40), label, fill=color, font=gf(16, True), anchor="mm")
            d.text((W // 2 - 200, py + 30), expr, fill=TEXT1, font=gf(20))
    if f > 60:
        ctext(d, 620, "Your textbook is not helping.", TEXT2, 24)
    if f > 80:
        ctext(d, 680, "There is a better way.", ACCENT, 32)
    return img

def scene_reveal(f, dur):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    cx, cy = W // 2, H // 2
    ph_y = int(lerp(-700, cy - 320, ease_back(min(1, f / 30)))) if f < 30 else cy - 320
    draw_phone(d, cx - 140, ph_y, 280, 640)
    phone_app_bar(d, cx - 140, ph_y, 280, "MathCalcu", ACCENT)
    modules = [
        ("Ineq", C_INEQ), ("Slope", C_SLOPE), ("Midpt", C_MID), ("Dist", C_DIST),
        ("P-Slp", C_PSLP), ("2-Pt", C_2PT), ("Y-Int", C_YINT), ("Par/Prp", C_PAR),
        ("Circ", C_CIRC), ("Deriv", C_DERIV), ("Lim", C_LIM), ("SlopeD", C_SLOPED),
    ]
    if f > 10:
        for i, (n, c) in enumerate(modules):
            row, col = divmod(i, 3)
            ct = ease_back(min(1, (f - 10 - i * 2) / 12))
            mx = cx - 130 + col * 90
            my = ph_y + 80 + row * 60
            w, h = int(80 * ct), int(50 * ct)
            if w > 20:
                rr(d, [mx, my, mx + w, my + h], 8, CARD, outline=(*c, 70), w=1)
                if ct > 0.7: d.text((mx + w // 2, my + h // 2), n, fill=c, font=gf(9, True), anchor="mm")
    if f > 40:
        ctext(d, ph_y + 680, "MathCalcu", TEXT1, 40)
    if f > 55:
        ctext(d, ph_y + 730, "Powered Math System for BSCS", TEXT2, 20)
    if f > 50:
        rx = cx + 200
        features = [("13 Modules", "Mid Term + Finals", ACCENT), ("Step-by-Step", "Numbered solutions", GREEN),
                    ("Graphing", "Visual plotting", CYAN), ("LaTeX", "Math rendering", C_PSLP)]
        for i, (title, sub, color) in enumerate(features):
            if f > 55 + i * 8:
                fy = 250 + i * 70
                draw_card(d, rx, fy, 350, 55, color)
                rr(d, [rx + 10, fy + 10, rx + 50, fy + 45], 8, (*color, 30))
                d.text((rx + 30, fy + 27), title[0], fill=color, font=gf(14, True), anchor="mm")
                d.text((rx + 60, fy + 10), title, fill=color, font=gf(14, True))
                d.text((rx + 60, fy + 35), sub, fill=TEXT2, font=gf(11))
    return img

def scene_keyboard(f, dur):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    px, py, pw, ph = 100, 40, 360, 960
    draw_phone(d, px, py, pw, ph)
    phone_app_bar(d, px, py, pw, "Derivatives", C_DERIV)
    expr = "sin(x^2) + ln(cos(x))"
    n = min(len(expr), max(0, (f - 5) * 3))
    rr(d, [px + 15, py + 80, px + pw - 15, py + 130], 10, CARD2, outline=(50, 50, 70), w=1)
    if n > 0: d.text((px + 30, py + 95), expr[:n], fill=TEXT1, font=gf(16))
    else: d.text((px + 30, py + 95), "Enter expression...", fill=TEXT2, font=gf(16))
    if f > 15:
        kt = ease_back(min(1, (f - 15) / 15))
        ky = py + int(lerp(ph, 340, kt))
        draw_keyboard(d, px + 8, ky, pw - 16)
    rx = px + pw + 60
    ctext(d, 40, "CUSTOM MATH KEYBOARD", ACCENT, 42)
    if f > 25:
        features = [("Math Symbols", "pi, e, sqrt, ^, abs", C_SLOPE),
                    ("Trig Functions", "sin, cos, tan, log, ln", C_INEQ),
                    ("Variables", "x, y for equations", C_2PT),
                    ("Operations", "+, -, *, /, =, (, )", C_YINT),
                    ("Auto-Solve", "Results as you type", GREEN),
                    ("Fractions", "Built-in fraction support", C_DIST)]
        for i, (title, desc, color) in enumerate(features):
            if f > 30 + i * 6:
                fy = 130 + i * 65
                draw_card(d, rx, fy, 600, 50, color)
                rr(d, [rx + 10, fy + 8, rx + 45, fy + 42], 8, (*color, 30))
                d.text((rx + 27, fy + 25), title[0], fill=color, font=gf(13, True), anchor="mm")
                d.text((rx + 55, fy + 8), title, fill=color, font=gf(15, True))
                d.text((rx + 55, fy + 33), desc, fill=TEXT2, font=gf(12))
    return img

def scene_derivatives(f, dur):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    px, py, pw, ph = 80, 30, 380, 960
    draw_phone(d, px, py, pw, ph)
    phone_app_bar(d, px, py, pw, "Derivatives", C_DERIV)
    d.text((px + 25, py + 85), "f(x) = sin(x^2) + ln(cos(x))", fill=TEXT1, font=gf(14))
    if f > 15:
        rr(d, [px + 15, py + 115, px + pw - 15, py + 155], 10, C_DERIV)
        d.text((px + pw // 2, py + 135), "SOLVE", fill=SURFACE, font=gf(14, True), anchor="mm")
    steps = [("Identify Rule", "Product + Chain Rule needed", 1),
             ("Step 1", "d/dx[sin(x^2)] = cos(x^2) * 2x", 2),
             ("Step 2", "d/dx[ln(cos(x))] = -tan(x)", 3),
             ("Step 3", "Apply sum rule: combine", 4),
             ("Final Answer", "f'(x) = 2x*cos(x^2) - tan(x)", 5)]
    for i, (title, content, num) in enumerate(steps):
        sd = 25 + i * 15
        if f > sd:
            sy = py + 175 + i * 80
            draw_card(d, px + 15, sy, pw - 30, 70, C_DERIV)
            rr(d, [px + 25, sy + 10, px + 55, sy + 40], 8, C_DERIV)
            d.text((px + 40, sy + 25), str(num), fill=SURFACE, font=gf(12, True), anchor="mm")
            d.text((px + 65, sy + 10), title, fill=C_DERIV, font=gf(12, True))
            d.text((px + 65, sy + 32), content, fill=TEXT1, font=gf(11))
            d.text((px + pw - 35, sy + 10), "done", fill=GREEN, font=gf(10))
    rx = px + pw + 50
    ctext(d, 40, "DERIVATIVE RULES", C_DERIV, 40)
    rules = [("Chain Rule", "f(g(x)) -> f'(g(x)) * g'(x)", C_DERIV),
             ("Product Rule", "(fg)' = f'g + fg'", C_SLOPE),
             ("Quotient Rule", "(f/g)' = (f'g - fg')/g^2", C_PSLP),
             ("Power Rule", "d/dx[x^n] = nx^(n-1)", C_2PT),
             ("Trig Functions", "sin, cos, tan, csc, sec, cot", C_YINT),
             ("Inverse Trig", "arcsin, arccos, arctan", C_DIST),
             ("Log & Exp", "ln, log, e^x, a^x", C_INEQ),
             ("Hyperbolic", "sinh, cosh, tanh", C_SLOPED)]
    for i, (name, formula, color) in enumerate(rules):
        if f > 40 + i * 6:
            fy = 120 + i * 75
            draw_card(d, rx, fy, 700, 60, color)
            rr(d, [rx + 10, fy + 8, rx + 50, fy + 52], 8, (*color, 30))
            d.text((rx + 30, fy + 30), name[0], fill=color, font=gf(14, True), anchor="mm")
            d.text((rx + 60, fy + 8), name, fill=color, font=gf(15, True))
            d.text((rx + 60, fy + 35), formula, fill=TEXT2, font=gf(12))
    return img

def scene_limits(f, dur):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    px, py, pw, ph = 80, 30, 380, 960
    draw_phone(d, px, py, pw, ph)
    phone_app_bar(d, px, py, pw, "Evaluating Limits", C_LIM)
    d.text((px + 25, py + 85), "lim(x->2) (x^2-4)/(x-2)", fill=TEXT1, font=gf(13))
    if f > 15:
        rr(d, [px + 15, py + 115, px + pw - 15, py + 155], 10, C_LIM)
        d.text((px + pw // 2, py + 135), "SOLVE", fill=SURFACE, font=gf(14, True), anchor="mm")
    steps = [("Method Detected", "Factoring (0/0 indeterminate)", 1),
             ("Step 1", "Factor: (x-2)(x+2)/(x-2)", 2),
             ("Step 2", "Cancel: x+2", 3),
             ("Step 3", "Substitute x=2: 2+2", 4),
             ("Final Answer", "lim = 4", 5)]
    for i, (title, content, num) in enumerate(steps):
        sd = 25 + i * 15
        if f > sd:
            sy = py + 175 + i * 80
            draw_card(d, px + 15, sy, pw - 30, 70, C_LIM)
            rr(d, [px + 25, sy + 10, px + 55, sy + 40], 8, C_LIM)
            d.text((px + 40, sy + 25), str(num), fill=SURFACE, font=gf(12, True), anchor="mm")
            d.text((px + 65, sy + 10), title, fill=C_LIM, font=gf(12, True))
            d.text((px + 65, sy + 32), content, fill=TEXT1, font=gf(11))
    rx = px + pw + 50
    ctext(d, 40, "4 EVALUATION METHODS", C_LIM, 40)
    methods = [("1. Direct Substitution", "Plug in the value directly\nExample: lim(x->3) x^2 = 9", C_SLOPE, 35),
               ("2. Factoring", "Factor and cancel common terms\nExample: lim(x->2) (x^2-4)/(x-2) = 4", C_DIST, 50),
               ("3. LCD Method", "Multiply by least common denominator\nComplex fractions with rational expressions", C_2PT, 65),
               ("4. Conjugate", "Multiply by conjugate pair\nEliminates radicals: sqrt(x+1)-1", C_PSLP, 80)]
    for i, (name, desc, color, delay) in enumerate(methods):
        if f > delay:
            fy = 120 + i * 140
            draw_card(d, rx, fy, 750, 120, color, 2)
            d.text((rx + 20, fy + 12), name, fill=color, font=gf(17, True))
            for li, line in enumerate(desc.split("\n")):
                d.text((rx + 20, fy + 40 + li * 22), line, fill=TEXT1, font=gf(13))
    return img

def scene_inequalities(f, dur):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    ctext(d, 30, "INEQUALITIES — 8 TYPES", C_INEQ, 44)
    ineq_types = [
        ("Strict", "x > 3, x < 5", "Open circle, shaded region", C_INEQ),
        ("Non-strict", "x >= 3, x <= 5", "Closed circle, shaded region", C_SLOPE),
        ("Absolute", "|x - 2| < 3", "Distance from center point", C_DIST),
        ("Continued", "1 < x < 5", "Compound inequality", C_2PT),
        ("Simple", "2x + 3 > 7", "Single variable, solve for x", C_YINT),
        ("Rational", "(x-1)/(x+2) >= 0", "Test intervals for sign", C_PSLP),
        ("Quadratic", "x^2 - 4x + 3 < 0", "Factor, find roots, test intervals", C_CIRC),
        ("Radical", "sqrt(x-1) > 2", "Isolate radical, square both sides", C_SLOPED),
    ]
    cols = 2
    cw, ch = 850, 95
    gx = 40
    sx = (W - cols * cw - (cols - 1) * gx) // 2
    sy = 90
    for i, (name, example, desc, color) in enumerate(ineq_types):
        row, col = divmod(i, cols)
        delay = i * 8
        if f > delay:
            t = ease_back(min(1, (f - delay) / 10))
            mx = sx + col * (cw + gx)
            my = sy + row * (ch + 20)
            draw_card(d, mx, my, cw, ch, color, 2)
            rr(d, [mx + 10, my + 10, mx + 50, my + 50], 10, (*color, 30))
            d.text((mx + 30, my + 30), str(i + 1), fill=color, font=gf(16, True), anchor="mm")
            d.text((mx + 65, my + 10), name, fill=color, font=gf(16, True))
            d.text((mx + 65, my + 35), example, fill=TEXT1, font=gf(14))
            d.text((mx + 65, my + 60), desc, fill=TEXT2, font=gf(12))
    return img

def scene_geometry(f, dur):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    total_frames = int(dur * FPS)
    mid_frame = total_frames // 2  # circles gets first half, analytical gets second half
    if f < mid_frame:
        # Part 1: Circles with graphing — use relative frame
        rf = f  # relative frame for this section
        ctext(d, 30, "CIRCLES MODULE", C_CIRC, 44)
        gx, gy, gs = 150, H // 2, 10
        draw_grid(d, gx, gy, gs, (30, 30, 50))
        draw_axis_labels(d, gx, gy, gs)
        cx_graph = gx + 3 * 25
        cy_graph = gy - (-2) * 25
        r_graph = 4 * 25
        if rf > 10:
            t = min(1, (rf - 10) / 30)
            angle_end = int(360 * t)
            for angle in range(0, angle_end):
                a1 = math.radians(angle)
                a2 = math.radians(angle + 1)
                x1 = cx_graph + r_graph * math.cos(a1)
                y1 = cy_graph - r_graph * math.sin(a1)
                x2 = cx_graph + r_graph * math.cos(a2)
                y2 = cy_graph - r_graph * math.sin(a2)
                d.line([(int(x1), int(y1)), (int(x2), int(y2))], fill=C_CIRC, width=3)
            draw_point(d, cx_graph, cy_graph, RED, "C(3,-2)", 5)
        rx = 500
        draw_card(d, rx, 100, 700, 140, C_CIRC, 2)
        d.text((rx + 20, 115), "Input:", fill=C_CIRC, font=gf(16, True))
        d.text((rx + 20, 145), "x^2 + y^2 - 6x + 4y - 3 = 0", fill=TEXT1, font=gf(20))
        d.text((rx + 20, 185), "General Form", fill=TEXT2, font=gf(14))
        if rf > 40:
            draw_card(d, rx, 260, 700, 160, GREEN, 2)
            d.text((rx + 20, 275), "Output:", fill=GREEN, font=gf(16, True))
            d.text((rx + 20, 305), "Center: (3, -2)", fill=TEXT1, font=gf(20))
            d.text((rx + 20, 340), "Radius: 4", fill=TEXT1, font=gf(20))
            d.text((rx + 20, 375), "Standard: (x-3)^2 + (y+2)^2 = 16", fill=TEXT2, font=gf(14))
        if rf > 55:
            types = [("Standard Form", "(x-h)^2 + (y-k)^2 = r^2"),
                     ("General Form", "x^2 + y^2 + Dx + Ey + F = 0"),
                     ("Center-Radius", "h = -D/2, k = -E/2")]
            for i, (tname, tdesc) in enumerate(types):
                ty = 450 + i * 45
                d.text((rx + 20, ty), f"  {tname}", fill=C_CIRC, font=gf(14, True))
                d.text((rx + 200, ty + 2), tdesc, fill=TEXT1, font=gf(13))
    else:
        # Part 2: Analytical Geometry — use relative frame for animations
        rf = f - mid_frame  # relative frame for this section
        ctext(d, 30, "ANALYTIC GEOMETRY", C_DIST, 44)
        modules = [("Distance Formula", "d = sqrt((x2-x1)^2 + (y2-y1)^2)", "Between any two points on a plane", C_DIST),
                   ("Midpoint Formula", "M = ((x1+x2)/2, (y1+y2)/2)", "Center point between coordinates", C_MID),
                   ("Slope", "m = (y2-y1)/(x2-x1)", "Rate of change between points", C_SLOPE),
                   ("Point-Slope Form", "y - y1 = m(x - x1)", "Line equation from point and slope", C_PSLP),
                   ("Two-Point Form", "(y-y1)/(y2-y1) = (x-x1)/(x2-x1)", "Line through two known points", C_2PT),
                   ("Y-Intercept", "b = y - mx", "Where line crosses the Y-axis", C_YINT),
                   ("Parallel Lines", "m1 = m2 (equal slopes)", "Same slope, never intersect", C_PAR),
                   ("Perpendicular", "m1 * m2 = -1", "Slopes are negative reciprocals", C_SLOPED)]
        for i, (name, formula, desc, color) in enumerate(modules):
            delay = i * 8  # stagger each card by 8 frames
            if rf > delay:
                t = ease_back(min(1, (rf - delay) / 10))
                row, col = divmod(i, 2)
                mx = 150 + col * 850
                my = 100 + row * 115
                draw_card(d, mx, my, 800, 100, color, 2)
                d.text((mx + 20, my + 10), name, fill=color, font=gf(18, True))
                d.text((mx + 20, my + 38), formula, fill=TEXT1, font=gf(15))
                d.text((mx + 20, my + 65), desc, fill=TEXT2, font=gf(12))
    return img

def scene_graphing(f, dur):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    ctext(d, 30, "REAL-TIME GRAPHING", CYAN, 44)
    # Grid shifted right to avoid left-side cards
    gx, gy, gs = W // 2 + 120, H // 2 + 30, 7
    draw_grid(d, gx, gy, gs, (30, 30, 50))
    draw_axis_labels(d, gx, gy, gs)
    if f > 10:
        draw_line_on_grid(d, gx, gy, 2, -1, C_SLOPE)
        draw_point(d, gx + (-1) * 25, gy - (2 * (-1) - 1) * 25, C_SLOPE, "(-1,-3)", 5)
        draw_point(d, gx + 2 * 25, gy - (2 * 2 - 1) * 25, C_SLOPE, "(2,3)", 5)
    if f > 25:
        t = min(1, (f - 25) / 40)
        angle_end = int(360 * t)
        cx_g = gx + 2 * 25
        cy_g = gy - 1 * 25
        r_g = 3 * 25
        for angle in range(0, angle_end):
            a1 = math.radians(angle)
            a2 = math.radians(angle + 1)
            x1 = cx_g + r_g * math.cos(a1)
            y1 = cy_g - r_g * math.sin(a1)
            x2 = cx_g + r_g * math.cos(a2)
            y2 = cy_g - r_g * math.sin(a2)
            d.line([(int(x1), int(y1)), (int(x2), int(y2))], fill=C_CIRC, width=3)
        draw_point(d, cx_g, cy_g, RED, "C(2,1)", 5)
    # Feature cards on far left with clear separation from grid
    rx = 60
    features = [("Circles", "Center, radius, general form\nReal-time plotting", C_CIRC),
                ("Lines", "Slope, intercept, point-slope\nParallel & perpendicular", C_SLOPE),
                ("Inequalities", "Shaded regions, boundary lines\nStrict & non-strict", C_INEQ)]
    for i, (title, desc, color) in enumerate(features):
        if f > 15 + i * 15:
            fy = 100 + i * 120
            draw_card(d, rx, fy, 400, 100, color, 2)
            d.text((rx + 20, fy + 10), title, fill=color, font=gf(18, True))
            for li, line in enumerate(desc.split("\n")):
                d.text((rx + 20, fy + 40 + li * 22), line, fill=TEXT1, font=gf(13))
    if f > 60:
        d.text((gx, H - 80), "Powered by fl_chart", fill=TEXT2, font=gf(14), anchor="mt")
    return img

def scene_stepbystep(f, dur):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    ctext(d, 30, "STEP-BY-STEP SOLUTIONS", GREEN, 44)
    px, py, pw, ph = 100, 40, 400, 960
    draw_phone(d, px, py, pw, ph)
    phone_app_bar(d, px, py, pw, "Point-Slope Form", C_PSLP)
    d.text((px + 25, py + 85), "Find line through (3,5) m=2", fill=TEXT1, font=gf(13))
    steps = [("Formula", "y - y1 = m(x - x1)", 1), ("Substitute", "y - 5 = 2(x - 3)", 2),
             ("Expand", "y - 5 = 2x - 6", 3), ("Simplify", "y = 2x - 1", 4),
             ("Slope-Intercept", "m=2, b=-1", 5), ("Y-Intercept", "(0, -1)", 6)]
    for i, (title, content, num) in enumerate(steps):
        sd = 15 + i * 12
        if f > sd:
            sy = py + 115 + i * 75
            draw_card(d, px + 15, sy, pw - 30, 60, C_PSLP)
            rr(d, [px + 25, sy + 8, px + 50, sy + 33], 8, C_PSLP)
            d.text((px + 37, sy + 20), str(num), fill=SURFACE, font=gf(10, True), anchor="mm")
            d.text((px + 60, sy + 8), title, fill=C_PSLP, font=gf(12, True))
            d.text((px + 60, sy + 28), content, fill=TEXT1, font=gf(12))
            d.text((px + pw - 40, sy + 8), "done", fill=GREEN, font=gf(9))
    rx = px + pw + 80
    d.text((rx, 40), "EVERY STEP SHOWN", fill=GREEN, font=gf(40, True))
    features = [("Numbered Steps", "Each step has a unique number\nfor easy reference", C_SLOPE),
                ("Rule Identification", "App identifies which rule\nis being applied", C_DERIV),
                ("Intermediate Work", "All algebraic manipulation\nshown explicitly", C_2PT),
                ("Final Answer", "Clearly highlighted at the end\nwith solution summary", GREEN),
                ("LaTeX Rendered", "Math notation via flutter_math_fork\nAcademic paper quality", C_PSLP)]
    for i, (title, desc, color) in enumerate(features):
        if f > 25 + i * 12:
            fy = 120 + i * 100
            draw_card(d, rx, fy, 700, 85, color)
            rr(d, [rx + 10, fy + 10, rx + 55, fy + 55], 10, (*color, 30))
            d.text((rx + 32, fy + 32), str(i + 1), fill=color, font=gf(16, True), anchor="mm")
            d.text((rx + 65, fy + 10), title, fill=color, font=gf(16, True))
            for li, line in enumerate(desc.split("\n")):
                d.text((rx + 65, fy + 40 + li * 18), line, fill=TEXT1, font=gf(12))
    return img

def scene_activation(f, dur):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    px, py, pw, ph = W // 2 - 160, 50, 320, 880
    draw_phone(d, px, py, pw, ph)
    phone_app_bar(d, px, py, pw, "Activation", ACCENT)
    if f > 10:
        t = ease_back(min(1, (f - 10) / 10))
        sz = int(60 * t)
        rr(d, [px + pw // 2 - sz // 2, py + 100, px + pw // 2 + sz // 2, py + 100 + sz], 12, (*ACCENT, 40))
        d.text((px + pw // 2, py + 100 + sz // 2), "LOCK", fill=ACCENT, font=gf(14, True), anchor="mm")
    if f > 25:
        d.text((px + 25, py + 200), "Enter your activation code:", fill=TEXT2, font=gf(12))
        code = "ABC-123-XYZ"
        n = min(len(code), max(0, (f - 25) * 2))
        rr(d, [px + 25, py + 230, px + pw - 25, py + 275], 10, CARD2, outline=ACCENT, w=2)
        if n > 0: d.text((px + pw // 2, py + 252), code[:n], fill=TEXT1, font=gf(18, True), anchor="mm")
    if f > 50:
        rr(d, [px + 25, py + 300, px + pw - 25, py + 345], 10, ACCENT)
        d.text((px + pw // 2, py + 322), "ACTIVATE", fill=TEXT1, font=gf(16, True), anchor="mm")
    if f > 65:
        rr(d, [px + 25, py + 370, px + pw - 25, py + 420], 10, GREEN)
        d.text((px + pw // 2, py + 395), "ACCESS GRANTED", fill=TEXT1, font=gf(14, True), anchor="mm")
    rx = px + pw + 100
    ctext(d, 100, "ACTIVATION GATE", ACCENT, 40)
    if f > 30:
        features = [("One-Time Setup", "Enter your 9-character code\ngiven by your instructor", C_SLOPE),
                    ("Course-Specific", "Different codes for\ndifferent class sections", C_INEQ),
                    ("Secure Access", "Only authorized BSCS students\ncan use the app", C_YINT),
                    ("Instant Unlock", "All 13 modules unlock\nimmediately after activation", GREEN)]
        for i, (title, desc, color) in enumerate(features):
            if f > 40 + i * 10:
                fy = 200 + i * 105
                draw_card(d, rx, fy, 620, 85, color)
                rr(d, [rx + 10, fy + 10, rx + 55, fy + 55], 10, (*color, 30))
                d.text((rx + 32, fy + 32), str(i + 1), fill=color, font=gf(16, True), anchor="mm")
                d.text((rx + 65, fy + 10), title, fill=color, font=gf(16, True))
                for li, line in enumerate(desc.split("\n")):
                    d.text((rx + 65, fy + 40 + li * 18), line, fill=TEXT1, font=gf(12))
    return img

def scene_theme(f, dur):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    ctext(d, 30, "DARK / LIGHT MODE", ACCENT, 44)
    px1, py1 = 180, 120
    draw_phone(d, px1, py1, 280, 560)
    phone_app_bar(d, px1, py1, 280, "MathCalcu", ACCENT)
    dark_tiles = [("Ineq", C_INEQ), ("Slope", C_SLOPE), ("Dist", C_DIST),
                  ("Circ", C_CIRC), ("Deriv", C_DERIV), ("Lim", C_LIM)]
    for i, (n, c) in enumerate(dark_tiles):
        row, col = divmod(i, 2)
        tx = px1 + 20 + col * 130
        ty = py1 + 80 + row * 70
        rr(d, [tx, ty, tx + 120, ty + 60], 8, CARD, outline=(*c, 50), w=1)
        d.text((tx + 60, ty + 30), n, fill=c, font=gf(12, True), anchor="mm")
    d.text((px1 + 140, py1 + 600), "Dark Mode", fill=TEXT1, font=gf(20, True), anchor="mt")
    d.text((px1 + 140, py1 + 630), "Default theme", fill=TEXT2, font=gf(14), anchor="mt")
    # Arrow between phones (not overlapping either phone)
    if f > 20:
        arrow_x = (px1 + 280 + 940) // 2  # midpoint between Phone1 right and Phone2 left
        d.text((arrow_x, py1 + 300), ">>", fill=ACCENT, font=gf(40, True), anchor="mm")
    if f > 25:
        px2, py2 = 940, 120
        rr(d, [px2, py2, px2 + 280, py2 + 560], 28, (245, 245, 250), outline=(200, 200, 210), w=2)
        rr(d, [px2 + 8, py2 + 32, px2 + 272, py2 + 70], 0, ACCENT)
        d.text((px2 + 140, py2 + 51), "MathCalcu", fill=TEXT1, font=gf(14, True), anchor="mm")
        for i, (n, c) in enumerate(dark_tiles):
            row, col = divmod(i, 2)
            tx = px2 + 20 + col * 130
            ty = py2 + 80 + row * 70
            rr(d, [tx, ty, tx + 120, ty + 60], 8, (255, 255, 255), outline=(*c, 50), w=1)
            d.text((tx + 60, ty + 30), n, fill=c, font=gf(12, True), anchor="mm")
        d.text((px2 + 140, py2 + 600), "Light Mode", fill=(30, 30, 40), font=gf(20, True), anchor="mt")
        d.text((px2 + 140, py2 + 630), "Toggle anytime", fill=TEXT2, font=gf(14), anchor="mt")
    if f > 50:
        ctext(d, 780, "Theme persists across sessions", TEXT2, 20)
        ctext(d, 820, "Saved via SharedPreferences", TEXT2, 16)
    return img

def scene_offline(f, dur):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    cy = H // 2
    if f > 5:
        t = ease_back(min(1, (f - 5) / 15))
        sz = int(80 * t)
        rr(d, [W // 2 - sz // 2, cy - 180, W // 2 + sz // 2, cy - 100], 16, GREEN)
        d.text((W // 2, cy - 140), "100%", fill=SURFACE, font=gf(28, True), anchor="mm")
    if f > 20: ctext(d, cy - 60, "OFFLINE", C_DIST, 64)
    if f > 35: ctext(d, cy + 20, "No internet required", TEXT2, 28)
    if f > 45: ctext(d, cy + 60, "No API calls  |  No waiting  |  No data collection", TEXT1, 20)
    if f > 55: ctext(d, cy + 110, "All computation happens on your device", TEXT2, 18)
    if f > 65: ctext(d, cy + 160, "Mid Term + Finals modules included", ACCENT, 22)
    return img

def scene_platform(f, dur):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    ctext(d, 40, "CROSS-PLATFORM", CYAN, 52)
    devices = [("Android", 120, C_DIST, "Phone & Tablet"), ("iOS", 480, C_SLOPE, "iPhone & iPad"),
               ("Web", 840, C_2PT, "Any Browser"), ("Desktop", 1200, C_PSLP, "Windows & Mac")]
    for i, (name, dx, color, sub) in enumerate(devices):
        if f > i * 12:
            dt = ease_back(min(1, (f - i * 12) / 10))
            dy = int(lerp(50, 150, dt))
            if i < 2:
                draw_phone(d, dx, dy, 160, 320)
                rr(d, [dx + 20, dy + 40, dx + 140, dy + 70], 0, color)
                d.text((dx + 80, dy + 55), name, fill=TEXT1, font=gf(10, True), anchor="mm")
            elif i == 2:
                draw_card(d, dx, dy, 240, 180, color, 2)
                rr(d, [dx + 80, dy + 180, dx + 160, dy + 195], 3, color)
                d.text((dx + 120, dy + 80), "WEB", fill=color, font=gf(20, True), anchor="mm")
            else:
                draw_card(d, dx, dy, 240, 170, color, 2)
                rr(d, [dx + 70, dy + 170, dx + 170, dy + 185], 3, color)
                d.text((dx + 120, dy + 80), "DESKTOP", fill=color, font=gf(20, True), anchor="mm")
            d.text((dx + 80, dy + 350), name, fill=color, font=gf(22, True), anchor="mt")
            d.text((dx + 80, dy + 385), sub, fill=TEXT2, font=gf(14), anchor="mt")
    ctext(d, 570, "ONE CODEBASE. EVERYWHERE.", TEXT1, 28)
    ctext(d, 610, "Built with Flutter", TEXT2, 16)
    return img

def scene_cta(f, dur):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img)
    for y in range(H):
        t = y / H
        r = int(ACCENT[0] * (1 - t)); g = int(ACCENT[1] * (1 - t) + 80 * t)
        b = int(ACCENT[2] * (1 - t) + 160 * t)
        d.line([(0, y), (W, y)], fill=(r, g, b))
    cx, cy = W // 2, H // 2
    if f < 25:
        t = ease_back(min(1, f / 20))
        draw_logo(d, cx, int(lerp(-250, cy - 180, t)), int(130 * t))
    else:
        draw_logo(d, cx, cy - 200, 130)
    if f > 10:
        ctext(d, cy - 50, "MathCalcu", TEXT1, 68)
    if f > 25:
        ctext(d, cy + 30, "Built by BSCS students, for BSCS students", (200, 200, 220), 24)
    if f > 45:
        ctext(d, cy + 80, "13 modules  |  Step-by-step  |  Graphing  |  LaTeX", ACCENT, 18)
    if f > 55:
        rr(d, [cx - 240, cy + 120, cx + 240, cy + 180], 30, TEXT1, outline=GOLD, w=2)
        d.text((cx, cy + 150), "Star on GitHub", fill=(30, 30, 40), font=gf(22, True), anchor="mm")
        d.text((cx, cy + 220), "github.com/Shuash11/MathCalcu", fill=(180, 180, 200), font=gf(18), anchor="mt")
    if f > 75: ctext(d, cy + 280, "Share with your classmates", TEXT1, 22)
    return img

def scene_close(f, dur):
    img = Image.new("RGB", (W, H), (0, 0, 0)); d = ImageDraw.Draw(img)
    if f < 40:
        t = ease(min(1, f / 15)); c = int(255 * t)
        ctext(d, H // 2 - 20, "Math doesn't have to be hard.", (c, c, c), 42)
    elif f < 80:
        ctext(d, H // 2 - 20, "Math doesn't have to be hard.", TEXT1, 42)
        if f > 60:
            ctext(d, H // 2 + 40, "MathCalcu makes it visual.", ACCENT, 28)
        if f > 70:
            t = 1 - ease(min(1, (f - 70) / 10)); c = int(255 * t)
            ctext(d, H // 2 - 20, "Math doesn't have to be hard.", (c, c, c), 42)
    return img

# ═══════════════════════════════════════════════════════════════
# MAIN BUILD
# ═══════════════════════════════════════════════════════════════

def get_dur(path):
    r = subprocess.run(["ffprobe", "-v", "quiet", "-show_entries", "format=duration",
                       "-of", "default=noprint_wrappers=1:nokey=1", path],
                       capture_output=True, text=True)
    try: return float(r.stdout.strip())
    except: return 0

SCENES = [
    ("01_hook",          scene_hook,          "s01_hook"),
    ("02_problem",       scene_problem,       "s02_problem"),
    ("03_reveal",        scene_reveal,        "s03_reveal"),
    ("04_keyboard",      scene_keyboard,      "s04_keyboard"),
    ("05_derivatives",   scene_derivatives,   "s05_derivatives"),
    ("06_limits",        scene_limits,        "s06_limits"),
    ("07_inequalities",  scene_inequalities,  "s07_inequalities"),
    ("08_geometry",      scene_geometry,      "s08_geometry"),
    ("09_graphing",      scene_graphing,      "s09_graphing"),
    ("10_stepbystep",    scene_stepbystep,    "s10_stepbystep"),
    ("11_activation",    scene_activation,    "s11_activation"),
    ("12_theme",         scene_theme,         "s12_theme"),
    ("13_offline",       scene_offline,       "s13_offline"),
    ("14_platform",      scene_platform,      "s14_platform"),
    ("15_cta",           scene_cta,           "s15_cta"),
    ("16_close",         scene_close,         "s16_close"),
]

print("Step 1: Reading narration durations...")
scene_durs = {}
for sname, _, narr_key in SCENES:
    narr_path = os.path.join(NARR_DIR, f"{narr_key}.mp3")
    dur = get_dur(narr_path)
    scene_durs[narr_key] = dur
    print(f"  {narr_key}: {dur:.1f}s")

print("\nStep 2: Building video frames...")
seg_files = []
for sname, sfunc, narr_key in SCENES:
    narr_dur = scene_durs[narr_key]
    dur = narr_dur + 1.5  # 1.5s padding
    dur = max(dur, 3)
    
    print(f"  {sname}: scene={dur:.1f}s", end="")
    
    nf = int(dur * FPS)
    sdir = os.path.join(FRAMES_DIR, sname)
    os.makedirs(sdir, exist_ok=True)
    
    for i in range(nf):
        frame = sfunc(f=i, dur=dur)
        if i < 4:
            frame = Image.blend(Image.new("RGB", (W, H)), frame, ease(i / 4))
        elif i >= nf - 4:
            frame = Image.blend(Image.new("RGB", (W, H)), frame, ease((nf - i) / 4))
        frame.save(os.path.join(sdir, f"frame_{i:06d}.png"))
    
    seg_mp4 = os.path.join(BASE, f"_seg_{sname}.mp4")
    narr_path = os.path.join(NARR_DIR, f"{narr_key}.mp3")
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
    
    r = subprocess.run(cmd, capture_output=True, text=True)
    actual = get_dur(seg_mp4) if r.returncode == 0 else 0
    seg_files.append(seg_mp4)
    print(f" -> {actual:.1f}s")

print("\nStep 3: Concatenating...")
cl = os.path.join(BASE, "_concat_v7c.txt")
with open(cl, "w") as f:
    for s in seg_files:
        f.write(f"file '{s}'\n")

concat_out = os.path.join(BASE, "mathcalcu_promo_v7c.mp4")
subprocess.run(["ffmpeg", "-y", "-f", "concat", "-safe", "0", "-i", cl,
    "-c:v", "libx264", "-c:a", "aac", "-b:a", "192k",
    "-pix_fmt", "yuv420p", "-movflags", "+faststart", concat_out], capture_output=True)

print("Step 4: Mixing music...")
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
for sname, _, _ in SCENES:
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
