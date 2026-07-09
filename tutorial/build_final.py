"""Build final persuasive promo — 1080x1080 square format for phone."""
import os, subprocess, shutil, math
from PIL import Image, ImageDraw, ImageFont

BASE = os.path.dirname(__file__)
NARR_DIR = os.path.join(BASE, "narration_promo")
FRAMES_DIR = os.path.join(BASE, "promo_frames_final")

W, H = 1080, 1080
FPS = 30

SURFACE = (10, 10, 15); CARD = (18, 18, 26); CARD2 = (13, 13, 20)
TEXT1 = (232, 232, 240); TEXT2 = (150, 150, 170); ACCENT = (108, 99, 255)
GOLD = (255, 215, 0); GREEN = (100, 220, 150); CYAN = (0, 194, 255)
RED = (255, 90, 90)
C_INEQ = (108, 99, 255); C_SLOPE = (0, 194, 255); C_MID = (233, 236, 239)
C_DIST = (78, 205, 196); C_PSLP = (168, 85, 247); C_2PT = (245, 158, 11)
C_YINT = (16, 185, 129); C_PAR = (6, 182, 212); C_CIRC = (6, 182, 212)
C_DERIV = (255, 209, 102); C_SLOPED = (239, 71, 111); C_LIM = (255, 176, 32)
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
    t = max(0, min(1, t)); return 1 - (1 - t) ** 3

def ease_back(t):
    t = max(0, min(1, t)); c1 = 1.70158; c3 = c1 + 1
    return 1 + c3 * (t - 1) ** 3 + c1 * (t - 1) ** 2

def lerp(a, b, t):
    return a + (b - a) * max(0, min(1, t))

def rr(d, xy, r, fill, outline=None, w=2):
    d.rounded_rectangle(xy, r, fill=fill, outline=outline, width=w)

def draw_logo(d, cx, cy, sz=80):
    sz = max(10, int(sz))
    if LOGO:
        logo = LOGO.resize((sz, sz), Image.LANCZOS)
        d._image.paste(logo, (cx - sz // 2, cy - sz // 2), logo)

def draw_phone(d, px, py, pw, ph):
    for i in range(6, 0, -1):
        a = int(30 * (1 - i / 6))
        rr(d, [px - i * 2, py - i * 2, px + pw + i * 2, py + ph + i * 2], 24, (a, a, a))
    rr(d, [px, py, px + pw, py + ph], 24, (25, 25, 35), outline=(60, 60, 75), w=2)
    rr(d, [px + 6, py + 28, px + pw - 6, py + ph - 6], 4, SURFACE)
    rr(d, [px + pw // 2 - 28, py + 5, px + pw // 2 + 28, py + 15], 6, (35, 35, 45))

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
    rr(d, [x, y, x + w, y + h], 10, CARD, outline=o, w=outline_w)

def phone_app_bar(d, px, py, pw, title, color):
    rr(d, [px + 6, py + 28, px + pw - 6, py + 60], 0, color)
    d.text((px + 18, py + 44), "<", fill=TEXT1, font=gf(13), anchor="mm")
    d.text((px + pw // 2, py + 44), title, fill=TEXT1, font=gf(12, True), anchor="mm")

def draw_grid(d, cx, cy, size, color=(40, 40, 60)):
    for i in range(-size, size + 1):
        x = cx + i * 20; y = cy + i * 20
        if 0 < x < W: d.line([(x, cy - size * 20), (x, cy + size * 20)], fill=color, width=1)
        if 0 < y < H: d.line([(cx - size * 20, y), (cx + size * 20, y)], fill=color, width=1)
    d.line([(cx - size * 20, cy), (cx + size * 20, cy)], fill=(70, 70, 90), width=2)
    d.line([(cx, cy - size * 20), (cx, cy + size * 20)], fill=(70, 70, 90), width=2)

def draw_axis_labels(d, cx, cy, size):
    f = gf(9)
    for i in range(-size, size + 1):
        if i != 0:
            x = cx + i * 20; y = cy + i * 20
            if 30 < x < W - 30: d.text((x, cy + 6), str(i), fill=TEXT2, font=f, anchor="mt")
            if 30 < y < H - 30: d.text((cx + 4, y), str(-i), fill=TEXT2, font=f, anchor="lt")

def draw_point(d, x, y, color, label=None, sz=3):
    d.ellipse([x - sz, y - sz, x + sz, y + sz], fill=color)
    if label: d.text((x + 6, y - 6), label, fill=color, font=gf(9, True))

def draw_line_on_grid(d, cx, cy, m, b, color):
    pts = []
    for px in range(0, W):
        x_graph = (px - cx) / 20; y_graph = m * x_graph + b
        py = int(cy - y_graph * 20)
        if 0 < py < H: pts.append((px, py))
    if len(pts) > 1:
        for i in range(len(pts) - 1):
            d.line([pts[i], pts[i + 1]], fill=color, width=2)

def draw_keyboard(d, px, py, pw):
    rr(d, [px, py, px + pw, py + 100], 6, (20, 20, 30))
    rows = [["(", ")", "sqrt", "^", "pi", "e"],
            ["sin", "cos", "tan", "log", "ln", "abs"],
            ["7", "8", "9", "/", "C", "<"],
            ["4", "5", "6", "*", "(", ")"],
            ["1", "2", "3", "-", "x", "y"],
            ["0", ".", "=", "+", "SOLVE"]]
    kw = (pw - 12) // 6; kh = 14
    for r, row in enumerate(rows):
        for c, key in enumerate(row):
            kx = px + 6 + c * (kw + 1); ky = py + 6 + r * (kh + 1)
            if key == "SOLVE":
                rr(d, [kx, ky, kx + kw * 2 + 1, ky + kh], 3, ACCENT)
                d.text((kx + kw, ky + kh // 2), key, fill=TEXT1, font=gf(7, True), anchor="mm")
            else:
                rr(d, [kx, ky, kx + kw, ky + kh], 3, (35, 35, 50), outline=(55, 55, 75), w=1)
                d.text((kx + kw // 2, ky + kh // 2), key, fill=TEXT2, font=gf(7), anchor="mm")

# ═══════════════════════════════════════════════════════════════
# SCENES (1080x1080)
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
        sz = int(72 * t)
        if sz > 10: ctext(d, H // 2 - 40, "MATHCALCU", ACCENT, sz)
        if f > 38:
            t2 = ease(min(1, (f - 38) / 12))
            ctext(d, H // 2 + 40, "MATH SOLVER FOR BSCS", TEXT2, int(24 * t2))
        if f > 55:
            t3 = ease(min(1, (f - 55) / 10))
            ctext(d, H // 2 + 80, "13 MODULES  |  STEP-BY-STEP  |  GRAPHING", ACCENT, int(15 * t3))
    return img

def scene_problem(f, dur):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    ctext(d, 50, "STUCK ON CALCULUS?", (255, 80, 80), 42)
    problems = [("Derivative", "d/dx[sin(x^2) * ln(cos(x))]", C_DERIV, 15),
                ("Limit", "lim(x->0) (sin(x) - x) / x^3", C_LIM, 25),
                ("Circle", "x^2+y^2-6x+4y-3=0", C_CIRC, 35),
                ("Inequality", "|2x - 3| > 5", C_INEQ, 45)]
    for i, (label, expr, color, delay) in enumerate(problems):
        if f > delay:
            py = 140 + i * 90
            draw_card(d, 60, py, W - 120, 75, color, 2)
            rr(d, [75, py + 12, 180, py + 62], 8, (*color, 40))
            d.text((128, py + 37), label, fill=color, font=gf(14, True), anchor="mm")
            d.text((200, py + 28), expr, fill=TEXT1, font=gf(17))
    if f > 60: ctext(d, 540, "Your textbook is not helping.", TEXT2, 20)
    if f > 80: ctext(d, 590, "There is a better way.", ACCENT, 28)
    return img

def scene_reveal(f, dur):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    cx, cy = W // 2, H // 2
    ph_y = int(lerp(-600, cy - 280, ease_back(min(1, f / 30)))) if f < 30 else cy - 280
    pw, ph = 220, 520
    draw_phone(d, cx - pw // 2, ph_y, pw, ph)
    phone_app_bar(d, cx - pw // 2, ph_y, pw, "MathCalcu", ACCENT)
    modules = [("Ineq", C_INEQ), ("Slope", C_SLOPE), ("Midpt", C_MID), ("Dist", C_DIST),
               ("P-Slp", C_PSLP), ("2-Pt", C_2PT), ("Y-Int", C_YINT), ("Par/Prp", C_PAR),
               ("Circ", C_CIRC), ("Deriv", C_DERIV), ("Lim", C_LIM), ("SlopeD", C_SLOPED)]
    if f > 10:
        for i, (n, c) in enumerate(modules):
            row, col = divmod(i, 3)
            ct = ease_back(min(1, (f - 10 - i * 2) / 12))
            mx = cx - 95 + col * 70; my = ph_y + 70 + row * 50
            w, h = int(60 * ct), int(40 * ct)
            if w > 15:
                rr(d, [mx, my, mx + w, my + h], 6, CARD, outline=(*c, 70), w=1)
                if ct > 0.7: d.text((mx + w // 2, my + h // 2), n, fill=c, font=gf(8, True), anchor="mm")
    if f > 40: ctext(d, ph_y + ph + 20, "MathCalcu", TEXT1, 32)
    if f > 55: ctext(d, ph_y + ph + 55, "Powered Math System for BSCS", TEXT2, 16)
    if f > 50:
        features = [("13 Modules", "Mid Term + Finals", ACCENT), ("Step-by-Step", "Numbered solutions", GREEN),
                    ("Graphing", "Visual plotting", CYAN), ("LaTeX", "Math rendering", C_PSLP)]
        for i, (title, sub, color) in enumerate(features):
            if f > 55 + i * 8:
                fy = 140 + i * 65
                draw_card(d, 60, fy, W - 120, 50, color)
                rr(d, [70, fy + 8, 105, fy + 42], 6, (*color, 30))
                d.text((88, fy + 25), title[0], fill=color, font=gf(12, True), anchor="mm")
                d.text((115, fy + 8), title, fill=color, font=gf(13, True))
                d.text((115, fy + 30), sub, fill=TEXT2, font=gf(10))
    return img

def scene_keyboard(f, dur):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    pw, ph = 240, 780
    px = W // 2 - pw // 2; py = 80
    draw_phone(d, px, py, pw, ph)
    phone_app_bar(d, px, py, pw, "Derivatives", C_DERIV)
    expr = "sin(x^2) + ln(cos(x))"; n = min(len(expr), max(0, (f - 5) * 3))
    rr(d, [px + 12, py + 70, px + pw - 12, py + 110], 8, CARD2, outline=(50, 50, 70), w=1)
    if n > 0: d.text((px + 20, py + 82), expr[:n], fill=TEXT1, font=gf(13))
    else: d.text((px + 20, py + 82), "Enter expression...", fill=TEXT2, font=gf(13))
    if f > 15:
        kt = ease_back(min(1, (f - 15) / 15)); ky = py + int(lerp(ph, 280, kt))
        draw_keyboard(d, px + 6, ky, pw - 12)
    ctext(d, 20, "CUSTOM MATH KEYBOARD", ACCENT, 32)
    if f > 25:
        features = [("Math Symbols", "pi, e, sqrt, ^, abs", C_SLOPE),
                    ("Trig Functions", "sin, cos, tan, log, ln", C_INEQ),
                    ("Variables", "x, y for equations", C_2PT),
                    ("Operations", "+, -, *, /, =, (, )", C_YINT),
                    ("Auto-Solve", "Results as you type", GREEN),
                    ("Fractions", "Built-in fraction support", C_DIST)]
        for i, (title, desc, color) in enumerate(features):
            if f > 30 + i * 6:
                fy = py + ph + 20 + i * 55
                if fy + 45 < H - 20:
                    draw_card(d, 40, fy, W - 80, 45, color)
                    rr(d, [50, fy + 6, 80, fy + 38], 6, (*color, 30))
                    d.text((65, fy + 22), title[0], fill=color, font=gf(11, True), anchor="mm")
                    d.text((90, fy + 6), title, fill=color, font=gf(12, True))
                    d.text((90, fy + 26), desc, fill=TEXT2, font=gf(10))
    return img

def scene_derivatives(f, dur):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    pw, ph = 260, 800
    px = 40; py = 80
    draw_phone(d, px, py, pw, ph)
    phone_app_bar(d, px, py, pw, "Derivatives", C_DERIV)
    d.text((px + 18, py + 72), "f(x) = sin(x^2)+ln(cos(x))", fill=TEXT1, font=gf(11))
    if f > 15:
        rr(d, [px + 12, py + 100, px + pw - 12, py + 135], 8, C_DERIV)
        d.text((px + pw // 2, py + 117), "SOLVE", fill=SURFACE, font=gf(12, True), anchor="mm")
    steps = [("Identify Rule", "Product + Chain Rule", 1), ("Step 1", "cos(x^2)*2x", 2),
             ("Step 2", "-tan(x)", 3), ("Step 3", "Combine", 4),
             ("Final Answer", "2x*cos(x^2)-tan(x)", 5)]
    for i, (title, content, num) in enumerate(steps):
        sd = 25 + i * 15
        if f > sd:
            sy = py + 150 + i * 70
            if sy + 60 < py + ph - 10:
                draw_card(d, px + 10, sy, pw - 20, 55, C_DERIV)
                rr(d, [px + 18, sy + 8, px + 42, sy + 32], 6, C_DERIV)
                d.text((px + 30, sy + 20), str(num), fill=SURFACE, font=gf(10, True), anchor="mm")
                d.text((px + 50, sy + 8), title, fill=C_DERIV, font=gf(10, True))
                d.text((px + 50, sy + 26), content, fill=TEXT1, font=gf(9))
                d.text((px + pw - 30, sy + 8), "done", fill=GREEN, font=gf(8))
    ctext(d, 20, "DERIVATIVE RULES", C_DERIV, 30)
    rules = [("Chain Rule", "f(g(x)) -> f'(g(x))*g'(x)", C_DERIV),
             ("Product Rule", "(fg)' = f'g + fg'", C_SLOPE), ("Quotient Rule", "(f/g)' = (f'g-fg')/g^2", C_PSLP),
             ("Power Rule", "d/dx[x^n] = nx^(n-1)", C_2PT), ("Trig Functions", "sin, cos, tan, csc, sec, cot", C_YINT),
             ("Inverse Trig", "arcsin, arccos, arctan", C_DIST), ("Log & Exp", "ln, log, e^x, a^x", C_INEQ),
             ("Hyperbolic", "sinh, cosh, tanh", C_SLOPED)]
    rx = px + pw + 30
    for i, (name, formula, color) in enumerate(rules):
        if f > 40 + i * 6:
            fy = 80 + i * 65
            if fy + 50 < H - 20:
                draw_card(d, rx, fy, W - rx - 30, 50, color)
                rr(d, [rx + 8, fy + 6, rx + 40, fy + 42], 6, (*color, 30))
                d.text((rx + 24, fy + 24), name[0], fill=color, font=gf(12, True), anchor="mm")
                d.text((rx + 48, fy + 6), name, fill=color, font=gf(12, True))
                d.text((rx + 48, fy + 28), formula, fill=TEXT2, font=gf(10))
    return img

def scene_limits(f, dur):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    pw, ph = 260, 800
    px = 40; py = 80
    draw_phone(d, px, py, pw, ph)
    phone_app_bar(d, px, py, pw, "Evaluating Limits", C_LIM)
    d.text((px + 18, py + 72), "lim(x->2) (x^2-4)/(x-2)", fill=TEXT1, font=gf(11))
    if f > 15:
        rr(d, [px + 12, py + 100, px + pw - 12, py + 135], 8, C_LIM)
        d.text((px + pw // 2, py + 117), "SOLVE", fill=SURFACE, font=gf(12, True), anchor="mm")
    steps = [("Method Detected", "Factoring (0/0)", 1), ("Step 1", "(x-2)(x+2)/(x-2)", 2),
             ("Step 2", "Cancel: x+2", 3), ("Step 3", "Sub x=2: 2+2", 4),
             ("Final Answer", "lim = 4", 5)]
    for i, (title, content, num) in enumerate(steps):
        sd = 25 + i * 15
        if f > sd:
            sy = py + 150 + i * 70
            if sy + 55 < py + ph - 10:
                draw_card(d, px + 10, sy, pw - 20, 50, C_LIM)
                rr(d, [px + 18, sy + 6, px + 42, sy + 30], 6, C_LIM)
                d.text((px + 30, sy + 18), str(num), fill=SURFACE, font=gf(10, True), anchor="mm")
                d.text((px + 50, sy + 6), title, fill=C_LIM, font=gf(10, True))
                d.text((px + 50, sy + 24), content, fill=TEXT1, font=gf(9))
    ctext(d, 20, "4 EVALUATION METHODS", C_LIM, 30)
    methods = [("1. Direct Sub", "Plug in directly\nlim(x->3) x^2 = 9", C_SLOPE, 35),
               ("2. Factoring", "Factor and cancel\nlim(x->2) (x^2-4)/(x-2)=4", C_DIST, 50),
               ("3. LCD Method", "Multiply by LCD\nComplex fractions", C_2PT, 65),
               ("4. Conjugate", "Multiply by conjugate\nEliminates radicals", C_PSLP, 80)]
    rx = px + pw + 30
    for i, (name, desc, color, delay) in enumerate(methods):
        if f > delay:
            fy = 80 + i * 120
            if fy + 100 < H - 20:
                draw_card(d, rx, fy, W - rx - 30, 100, color, 2)
                d.text((rx + 15, fy + 10), name, fill=color, font=gf(14, True))
                for li, line in enumerate(desc.split("\n")):
                    d.text((rx + 15, fy + 35 + li * 20), line, fill=TEXT1, font=gf(11))
    return img

def scene_inequalities(f, dur):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    ctext(d, 20, "INEQUALITIES — 8 TYPES", C_INEQ, 34)
    ineq_types = [("Strict", "x > 3, x < 5", "Open circle, shaded", C_INEQ),
                  ("Non-strict", "x >= 3, x <= 5", "Closed circle, shaded", C_SLOPE),
                  ("Absolute", "|x - 2| < 3", "Distance from center", C_DIST),
                  ("Continued", "1 < x < 5", "Compound inequality", C_2PT),
                  ("Simple", "2x + 3 > 7", "Solve for x", C_YINT),
                  ("Rational", "(x-1)/(x+2) >= 0", "Test intervals", C_PSLP),
                  ("Quadratic", "x^2 - 4x + 3 < 0", "Factor, test intervals", C_CIRC),
                  ("Radical", "sqrt(x-1) > 2", "Isolate, square both", C_SLOPED)]
    cols = 2; cw = (W - 80 - 20) // 2; ch = 80; gx = 20
    sx = 40; sy = 75
    for i, (name, example, desc, color) in enumerate(ineq_types):
        row, col = divmod(i, cols); delay = i * 8
        if f > delay:
            mx = sx + col * (cw + gx); my = sy + row * (ch + 12)
            draw_card(d, mx, my, cw, ch, color, 2)
            rr(d, [mx + 8, my + 8, mx + 40, my + 40], 8, (*color, 30))
            d.text((mx + 24, my + 24), str(i + 1), fill=color, font=gf(13, True), anchor="mm")
            d.text((mx + 50, my + 8), name, fill=color, font=gf(14, True))
            d.text((mx + 50, my + 30), example, fill=TEXT1, font=gf(12))
            d.text((mx + 50, my + 52), desc, fill=TEXT2, font=gf(10))
    return img

def scene_geometry(f, dur):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    total_frames = int(dur * FPS); mid_frame = total_frames // 2
    if f < mid_frame:
        rf = f
        ctext(d, 20, "CIRCLES MODULE", C_CIRC, 34)
        gx, gy, gs = 180, H // 2 + 40, 8
        draw_grid(d, gx, gy, gs, (30, 30, 50)); draw_axis_labels(d, gx, gy, gs)
        cx_graph = gx + 3 * 20; cy_graph = gy - (-2) * 20; r_graph = 4 * 20
        if rf > 10:
            t = min(1, (rf - 10) / 30); angle_end = int(360 * t)
            for angle in range(0, angle_end):
                a1 = math.radians(angle); a2 = math.radians(angle + 1)
                x1 = cx_graph + r_graph * math.cos(a1); y1 = cy_graph - r_graph * math.sin(a1)
                x2 = cx_graph + r_graph * math.cos(a2); y2 = cy_graph - r_graph * math.sin(a2)
                d.line([(int(x1), int(y1)), (int(x2), int(y2))], fill=C_CIRC, width=2)
            draw_point(d, cx_graph, cy_graph, RED, "C(3,-2)", 4)
        rx = 420
        draw_card(d, rx, 80, W - rx - 30, 110, C_CIRC, 2)
        d.text((rx + 15, 92), "Input:", fill=C_CIRC, font=gf(13, True))
        d.text((rx + 15, 115), "x^2+y^2-6x+4y-3=0", fill=TEXT1, font=gf(16))
        d.text((rx + 15, 145), "General Form", fill=TEXT2, font=gf(12))
        if rf > 40:
            draw_card(d, rx, 210, W - rx - 30, 130, GREEN, 2)
            d.text((rx + 15, 222), "Output:", fill=GREEN, font=gf(13, True))
            d.text((rx + 15, 245), "Center: (3, -2)", fill=TEXT1, font=gf(16))
            d.text((rx + 15, 275), "Radius: 4", fill=TEXT1, font=gf(16))
            d.text((rx + 15, 305), "Standard: (x-3)^2+(y+2)^2=16", fill=TEXT2, font=gf(11))
        if rf > 55:
            types = [("Standard Form", "(x-h)^2 + (y-k)^2 = r^2"),
                     ("General Form", "x^2 + y^2 + Dx + Ey + F = 0"),
                     ("Center-Radius", "h = -D/2, k = -E/2")]
            for i, (tname, tdesc) in enumerate(types):
                ty = 370 + i * 38
                d.text((rx + 15, ty), f"  {tname}", fill=C_CIRC, font=gf(12, True))
                d.text((rx + 160, ty + 2), tdesc, fill=TEXT1, font=gf(11))
    else:
        rf = f - mid_frame
        ctext(d, 20, "ANALYTIC GEOMETRY", C_DIST, 34)
        modules = [("Distance", "d=sqrt((x2-x1)^2+(y2-y1)^2)", C_DIST),
                   ("Midpoint", "M=((x1+x2)/2,(y1+y2)/2)", C_MID),
                   ("Slope", "m=(y2-y1)/(x2-x1)", C_SLOPE),
                   ("Point-Slope", "y-y1=m(x-x1)", C_PSLP),
                   ("Two-Point", "(y-y1)/(y2-y1)=(x-x1)/(x2-x1)", C_2PT),
                   ("Y-Intercept", "b=y-mx", C_YINT),
                   ("Parallel", "m1=m2 (equal slopes)", C_PAR),
                   ("Perpendicular", "m1*m2=-1", C_SLOPED)]
        for i, (name, formula, color) in enumerate(modules):
            delay = i * 8
            if rf > delay:
                row, col = divmod(i, 2)
                cw = (W - 80 - 20) // 2
                mx = 40 + col * (cw + 20); my = 75 + row * 60
                draw_card(d, mx, my, cw, 50, color, 2)
                d.text((mx + 12, my + 6), name, fill=color, font=gf(13, True))
                d.text((mx + 12, my + 26), formula, fill=TEXT1, font=gf(11))
    return img

def scene_graphing(f, dur):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    ctext(d, 20, "REAL-TIME GRAPHING", CYAN, 34)
    gx, gy, gs = W // 2 + 60, H // 2 + 20, 6
    draw_grid(d, gx, gy, gs, (30, 30, 50)); draw_axis_labels(d, gx, gy, gs)
    if f > 10:
        draw_line_on_grid(d, gx, gy, 2, -1, C_SLOPE)
        draw_point(d, gx + (-1) * 20, gy - (2 * (-1) - 1) * 20, C_SLOPE, "(-1,-3)", 4)
        draw_point(d, gx + 2 * 20, gy - (2 * 2 - 1) * 20, C_SLOPE, "(2,3)", 4)
    if f > 25:
        t = min(1, (f - 25) / 40); angle_end = int(360 * t)
        cx_g = gx + 2 * 20; cy_g = gy - 1 * 20; r_g = 3 * 20
        for angle in range(0, angle_end):
            a1 = math.radians(angle); a2 = math.radians(angle + 1)
            x1 = cx_g + r_g * math.cos(a1); y1 = cy_g - r_g * math.sin(a1)
            x2 = cx_g + r_g * math.cos(a2); y2 = cy_g - r_g * math.sin(a2)
            d.line([(int(x1), int(y1)), (int(x2), int(y2))], fill=C_CIRC, width=2)
        draw_point(d, cx_g, cy_g, RED, "C(2,1)", 4)
    features = [("Circles", "Center, radius, general form\nReal-time plotting", C_CIRC),
                ("Lines", "Slope, intercept, point-slope\nParallel & perpendicular", C_SLOPE),
                ("Inequalities", "Shaded regions, boundary lines\nStrict & non-strict", C_INEQ)]
    for i, (title, desc, color) in enumerate(features):
        if f > 15 + i * 15:
            fy = 80 + i * 100
            draw_card(d, 30, fy, 380, 85, color, 2)
            d.text((45, fy + 8), title, fill=color, font=gf(15, True))
            for li, line in enumerate(desc.split("\n")):
                d.text((45, fy + 32 + li * 20), line, fill=TEXT1, font=gf(11))
    if f > 60: d.text((gx, H - 50), "Powered by fl_chart", fill=TEXT2, font=gf(12), anchor="mt")
    return img

def scene_stepbystep(f, dur):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    ctext(d, 20, "STEP-BY-STEP SOLUTIONS", GREEN, 34)
    pw, ph = 240, 680
    px = 40; py = 70
    draw_phone(d, px, py, pw, ph)
    phone_app_bar(d, px, py, pw, "Point-Slope", C_PSLP)
    d.text((px + 15, py + 72), "Find line thru (3,5) m=2", fill=TEXT1, font=gf(11))
    steps = [("Formula", "y-y1=m(x-x1)", 1), ("Substitute", "y-5=2(x-3)", 2),
             ("Expand", "y-5=2x-6", 3), ("Simplify", "y=2x-1", 4),
             ("Slope-Int", "m=2, b=-1", 5), ("Y-Intercept", "(0, -1)", 6)]
    for i, (title, content, num) in enumerate(steps):
        sd = 15 + i * 12
        if f > sd:
            sy = py + 100 + i * 60
            if sy + 50 < py + ph - 10:
                draw_card(d, px + 8, sy, pw - 16, 45, C_PSLP)
                rr(d, [px + 15, sy + 6, px + 38, sy + 28], 6, C_PSLP)
                d.text((px + 26, sy + 17), str(num), fill=SURFACE, font=gf(9, True), anchor="mm")
                d.text((px + 44, sy + 5), title, fill=C_PSLP, font=gf(10, True))
                d.text((px + 44, sy + 22), content, fill=TEXT1, font=gf(9))
                d.text((px + pw - 28, sy + 5), "done", fill=GREEN, font=gf(8))
    ctext(d, 70 + ph + 15, "EVERY STEP SHOWN", GREEN, 24)
    features = [("Numbered Steps", "Unique number for each step", C_SLOPE),
                ("Rule Identification", "App identifies the rule used", C_DERIV),
                ("Intermediate Work", "All algebra shown explicitly", C_2PT),
                ("Final Answer", "Clearly highlighted at end", GREEN),
                ("LaTeX Rendered", "Academic paper quality math", C_PSLP)]
    for i, (title, desc, color) in enumerate(features):
        if f > 25 + i * 12:
            fy = 70 + ph + 55 + i * 65
            if fy + 55 < H - 20:
                draw_card(d, 40, fy, W - 80, 50, color)
                rr(d, [50, fy + 6, 82, fy + 42], 6, (*color, 30))
                d.text((66, fy + 24), str(i + 1), fill=color, font=gf(12, True), anchor="mm")
                d.text((92, fy + 6), title, fill=color, font=gf(12, True))
                d.text((92, fy + 28), desc, fill=TEXT1, font=gf(10))
    return img

def scene_activation(f, dur):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    pw, ph = 260, 720
    px = W // 2 - pw // 2; py = 80
    draw_phone(d, px, py, pw, ph)
    phone_app_bar(d, px, py, pw, "Activation", ACCENT)
    if f > 10:
        t = ease_back(min(1, (f - 10) / 10)); sz = int(50 * t)
        rr(d, [px + pw // 2 - sz // 2, py + 90, px + pw // 2 + sz // 2, py + 90 + sz], 10, (*ACCENT, 40))
        d.text((px + pw // 2, py + 90 + sz // 2), "LOCK", fill=ACCENT, font=gf(12, True), anchor="mm")
    if f > 25:
        d.text((px + 18, py + 170), "Enter activation code:", fill=TEXT2, font=gf(10))
        code = "ABC-123-XYZ"; n = min(len(code), max(0, (f - 25) * 2))
        rr(d, [px + 18, py + 195, px + pw - 18, py + 235], 8, CARD2, outline=ACCENT, w=2)
        if n > 0: d.text((px + pw // 2, py + 215), code[:n], fill=TEXT1, font=gf(15, True), anchor="mm")
    if f > 50:
        rr(d, [px + 18, py + 260, px + pw - 18, py + 300], 8, ACCENT)
        d.text((px + pw // 2, py + 280), "ACTIVATE", fill=TEXT1, font=gf(14, True), anchor="mm")
    if f > 65:
        rr(d, [px + 18, py + 320, px + pw - 18, py + 360], 8, GREEN)
        d.text((px + pw // 2, py + 340), "ACCESS GRANTED", fill=TEXT1, font=gf(12, True), anchor="mm")
    ctext(d, 20, "ACTIVATION GATE", ACCENT, 30)
    if f > 30:
        features = [("One-Time Setup", "Enter 9-character code\nfrom your instructor", C_SLOPE),
                    ("Course-Specific", "Different codes for\ndifferent class sections", C_INEQ),
                    ("Secure Access", "Only authorized BSCS\nstudents can use app", C_YINT),
                    ("Instant Unlock", "All 13 modules unlock\nimmediately", GREEN)]
        for i, (title, desc, color) in enumerate(features):
            if f > 40 + i * 10:
                fy = py + ph + 20 + i * 75
                if fy + 65 < H - 20:
                    draw_card(d, 40, fy, W - 80, 65, color)
                    rr(d, [50, fy + 8, 82, fy + 40], 6, (*color, 30))
                    d.text((66, fy + 24), str(i + 1), fill=color, font=gf(12, True), anchor="mm")
                    d.text((92, fy + 6), title, fill=color, font=gf(13, True))
                    for li, line in enumerate(desc.split("\n")):
                        d.text((92, fy + 28 + li * 16), line, fill=TEXT1, font=gf(10))
    return img

def scene_theme(f, dur):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    ctext(d, 20, "DARK / LIGHT MODE", ACCENT, 34)
    pw, ph = 180, 380
    gap = 60
    px1 = W // 2 - pw - gap // 2; py1 = 80
    draw_phone(d, px1, py1, pw, ph)
    phone_app_bar(d, px1, py1, pw, "MathCalcu", ACCENT)
    dark_tiles = [("Ineq", C_INEQ), ("Slope", C_SLOPE), ("Dist", C_DIST),
                  ("Circ", C_CIRC), ("Deriv", C_DERIV), ("Lim", C_LIM)]
    for i, (n, c) in enumerate(dark_tiles):
        row, col = divmod(i, 2)
        tx = px1 + 14 + col * 82; ty = py1 + 65 + row * 48
        rr(d, [tx, ty, tx + 74, ty + 40], 6, CARD, outline=(*c, 50), w=1)
        d.text((tx + 37, ty + 20), n, fill=c, font=gf(10, True), anchor="mm")
    d.text((px1 + pw // 2, py1 + ph + 15), "Dark Mode", fill=TEXT1, font=gf(16, True), anchor="mt")
    d.text((px1 + pw // 2, py1 + ph + 38), "Default theme", fill=TEXT2, font=gf(11), anchor="mt")
    if f > 20:
        arrow_x = W // 2
        d.text((arrow_x, py1 + ph // 2), ">>", fill=ACCENT, font=gf(30, True), anchor="mm")
    if f > 25:
        px2 = W // 2 + gap // 2
        rr(d, [px2, py1, px2 + pw, py1 + ph], 24, (245, 245, 250), outline=(200, 200, 210), w=2)
        rr(d, [px2 + 6, py1 + 28, px2 + pw - 6, py1 + 60], 0, ACCENT)
        d.text((px2 + pw // 2, py1 + 44), "MathCalcu", fill=TEXT1, font=gf(11, True), anchor="mm")
        for i, (n, c) in enumerate(dark_tiles):
            row, col = divmod(i, 2)
            tx = px2 + 14 + col * 82; ty = py1 + 65 + row * 48
            rr(d, [tx, ty, tx + 74, ty + 40], 6, (255, 255, 255), outline=(*c, 50), w=1)
            d.text((tx + 37, ty + 20), n, fill=c, font=gf(10, True), anchor="mm")
        d.text((px2 + pw // 2, py1 + ph + 15), "Light Mode", fill=(30, 30, 40), font=gf(16, True), anchor="mt")
        d.text((px2 + pw // 2, py1 + ph + 38), "Toggle anytime", fill=TEXT2, font=gf(11), anchor="mt")
    if f > 50:
        ctext(d, py1 + ph + 75, "Theme persists across sessions", TEXT2, 16)
        ctext(d, py1 + ph + 100, "Saved via SharedPreferences", TEXT2, 13)
    return img

def scene_offline(f, dur):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    cy = H // 2
    if f > 5:
        t = ease_back(min(1, (f - 5) / 15)); sz = int(70 * t)
        rr(d, [W // 2 - sz // 2, cy - 160, W // 2 + sz // 2, cy - 90], 14, GREEN)
        d.text((W // 2, cy - 125), "100%", fill=SURFACE, font=gf(24, True), anchor="mm")
    if f > 20: ctext(d, cy - 50, "OFFLINE", C_DIST, 52)
    if f > 35: ctext(d, cy + 15, "No internet required", TEXT2, 22)
    if f > 45: ctext(d, cy + 50, "No API calls  |  No waiting  |  No data", TEXT1, 16)
    if f > 55: ctext(d, cy + 85, "All computation on your device", TEXT2, 15)
    if f > 65: ctext(d, cy + 125, "Mid Term + Finals modules included", ACCENT, 18)
    return img

def scene_platform(f, dur):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    ctext(d, 30, "CROSS-PLATFORM", CYAN, 40)
    pw, ph = 110, 220
    devices = [("Android", C_DIST, "Phone & Tablet"), ("iOS", C_SLOPE, "iPhone & iPad")]
    for i, (name, color, sub) in enumerate(devices):
        if f > i * 12:
            dt = ease_back(min(1, (f - i * 12) / 10)); dy = int(lerp(100, 140, dt))
            dx = 80 + i * (pw + 40)
            draw_phone(d, dx, dy, pw, ph)
            rr(d, [dx + 12, dy + 30, dx + pw - 12, dy + 55], 0, color)
            d.text((dx + pw // 2, dy + 42), name, fill=TEXT1, font=gf(9, True), anchor="mm")
            d.text((dx + pw // 2, dy + ph + 15), name, fill=color, font=gf(16, True), anchor="mt")
            d.text((dx + pw // 2, dy + ph + 38), sub, fill=TEXT2, font=gf(11), anchor="mt")
    if f > 24:
        dx = W // 2 - 60; dy = 140
        draw_card(d, dx, dy, 120, 100, C_2PT, 2)
        rr(d, [dx + 40, dy + 100, dx + 80, dy + 112], 3, C_2PT)
        d.text((dx + 60, dy + 40), "WEB", fill=C_2PT, font=gf(16, True), anchor="mm")
        d.text((dx + 60, dy + ph + 15), "Web", fill=C_2PT, font=gf(16, True), anchor="mt")
        d.text((dx + 60, dy + ph + 38), "Any Browser", fill=TEXT2, font=gf(11), anchor="mt")
    if f > 36:
        dx = W - 80 - pw; dy = 140
        draw_card(d, dx, dy, pw, 95, C_PSLP, 2)
        rr(d, [dx + 35, dy + 95, dx + 85, dy + 107], 3, C_PSLP)
        d.text((dx + 60, dy + 40), "DESKTOP", fill=C_PSLP, font=gf(14, True), anchor="mm")
        d.text((dx + pw // 2, dy + ph + 15), "Desktop", fill=C_PSLP, font=gf(16, True), anchor="mt")
        d.text((dx + pw // 2, dy + ph + 38), "Windows & Mac", fill=TEXT2, font=gf(11), anchor="mt")
    ctext(d, 520, "ONE CODEBASE. EVERYWHERE.", TEXT1, 22)
    ctext(d, 555, "Built with Flutter", TEXT2, 14)
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
        draw_logo(d, cx, int(lerp(-200, cy - 160, t)), int(100 * t))
    else:
        draw_logo(d, cx, cy - 180, 100)
    if f > 10: ctext(d, cy - 40, "MathCalcu", TEXT1, 52)
    if f > 25: ctext(d, cy + 20, "Built by BSCS students, for BSCS students", (200, 200, 220), 18)
    if f > 45: ctext(d, cy + 55, "13 modules  |  Step-by-step  |  Graphing  |  LaTeX", ACCENT, 14)
    if f > 55:
        rr(d, [cx - 180, cy + 90, cx + 180, cy + 135], 24, TEXT1, outline=GOLD, w=2)
        d.text((cx, cy + 112), "Star on GitHub", fill=(30, 30, 40), font=gf(17, True), anchor="mm")
        d.text((cx, cy + 160), "github.com/Shuash11/MathCalcu", fill=(180, 180, 200), font=gf(14), anchor="mt")
    if f > 75: ctext(d, cy + 210, "Share with your classmates", TEXT1, 18)
    return img

def scene_close(f, dur):
    img = Image.new("RGB", (W, H), (0, 0, 0)); d = ImageDraw.Draw(img)
    if f < 40:
        t = ease(min(1, f / 15)); c = int(255 * t)
        ctext(d, H // 2 - 20, "Math doesn't have to be hard.", (c, c, c), 34)
    elif f < 80:
        ctext(d, H // 2 - 20, "Math doesn't have to be hard.", TEXT1, 34)
        if f > 60: ctext(d, H // 2 + 30, "MathCalcu makes it visual.", ACCENT, 22)
        if f > 70:
            t = 1 - ease(min(1, (f - 70) / 10)); c = int(255 * t)
            ctext(d, H // 2 - 20, "Math doesn't have to be hard.", (c, c, c), 34)
    return img

# ═══════════════════════════════════════════════════════════════
# BUILD
# ═══════════════════════════════════════════════════════════════

def get_dur(path):
    r = subprocess.run(["ffprobe", "-v", "quiet", "-show_entries", "format=duration",
                       "-of", "default=noprint_wrappers=1:nokey=1", path],
                       capture_output=True, text=True)
    try: return float(r.stdout.strip())
    except: return 0

SCENES = [
    ("01_hook", scene_hook, "s01_hook"), ("02_problem", scene_problem, "s02_problem"),
    ("03_reveal", scene_reveal, "s03_reveal"), ("04_keyboard", scene_keyboard, "s04_keyboard"),
    ("05_derivatives", scene_derivatives, "s05_derivatives"), ("06_limits", scene_limits, "s06_limits"),
    ("07_inequalities", scene_inequalities, "s07_inequalities"), ("08_geometry", scene_geometry, "s08_geometry"),
    ("09_graphing", scene_graphing, "s09_graphing"), ("10_stepbystep", scene_stepbystep, "s10_stepbystep"),
    ("11_activation", scene_activation, "s11_activation"), ("12_theme", scene_theme, "s12_theme"),
    ("13_offline", scene_offline, "s13_offline"), ("14_platform", scene_platform, "s14_platform"),
    ("15_cta", scene_cta, "s15_cta"), ("16_close", scene_close, "s16_close"),
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
    dur = narr_dur + 1.5; dur = max(dur, 3)
    print(f"  {sname}: scene={dur:.1f}s", end="")
    nf = int(dur * FPS)
    sdir = os.path.join(FRAMES_DIR, sname)
    os.makedirs(sdir, exist_ok=True)
    for i in range(nf):
        frame = sfunc(f=i, dur=dur)
        if i < 4: frame = Image.blend(Image.new("RGB", (W, H)), frame, ease(i / 4))
        elif i >= nf - 4: frame = Image.blend(Image.new("RGB", (W, H)), frame, ease((nf - i) / 4))
        frame.save(os.path.join(sdir, f"frame_{i:06d}.png"))
    seg_mp4 = os.path.join(BASE, f"_seg_{sname}.mp4")
    narr_path = os.path.join(NARR_DIR, f"{narr_key}.mp3")
    padded = os.path.join(BASE, f"_padded_{sname}.wav")
    actual_narr = get_dur(narr_path); silence = max(0, dur - actual_narr)
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
cl = os.path.join(BASE, "_concat_final.txt")
with open(cl, "w") as f:
    for s in seg_files: f.write(f"file '{s}'\n")

concat_out = os.path.join(BASE, "mathcalcu_promo_final.mp4")
subprocess.run(["ffmpeg", "-y", "-f", "concat", "-safe", "0", "-i", cl,
    "-c:v", "libx264", "-c:a", "aac", "-b:a", "192k",
    "-pix_fmt", "yuv420p", "-movflags", "+faststart", concat_out], capture_output=True)

# NO MUSIC — just copy concatenated output
shutil.copy2(concat_out, os.path.join(os.path.expanduser("~"), "Downloads", "mathcalcu_promo_final.mp4"))

sz = os.path.getsize(concat_out) / (1024 * 1024)
dur = get_dur(concat_out)
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
print(f"Copied to {copy_to}")
