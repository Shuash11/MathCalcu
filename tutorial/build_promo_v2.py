"""MathCalcu Promo Video — 60s advertising style, fast cuts, bold text."""
import os, subprocess, json, math, shutil, random
from PIL import Image, ImageDraw, ImageFont

BASE = os.path.dirname(__file__)
FRAMES_DIR = os.path.join(BASE, "promo_frames")
NARR_DIR = os.path.join(BASE, "narration_promo")
OUTPUT = os.path.join(BASE, "mathcalcu_promo_v2.mp4")
LOGO_PATH = os.path.join(BASE, "..", "assets", "images", "app_icon.png")
os.makedirs(FRAMES_DIR, exist_ok=True)

W, H = 1920, 1080
FPS = 30

# Bold colors
BG = (10, 10, 15)
CYAN = (0, 220, 255)
PURPLE = (120, 80, 255)
WHITE = (255, 255, 255)
GOLD = (255, 215, 0)
LIME = (80, 255, 120)
RED = (255, 60, 60)
MAGENTA = (255, 50, 150)
CORAL = (255, 100, 80)
SKY = (100, 200, 255)
MINT = (0, 255, 180)

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
def ease_out(t): return max(0, min(1, 1-(1-t)**2))
def ease_back(t):
    c1=1.70158; c3=c1+1
    return max(0, min(1, 1+c3*(t-1)**3+c1*(t-1)**2))
def lerp(a, b, t): return a + (b - a) * t
def ease_elastic(t):
    if t <= 0: return 0
    if t >= 1: return 1
    return math.pow(2, -10*t) * math.sin((t*10-0.75)*(2*math.pi)/3) + 1

def rr(d, xy, r, fill, outline=None, w=2):
    d.rounded_rectangle(xy, r, fill=fill, outline=outline, width=w)

def draw_logo(d, cx, cy, sz=100):
    sz = max(10, int(sz))
    if LOGO:
        logo = LOGO.resize((sz, sz), Image.LANCZOS)
        d._image.paste(logo, (cx - sz//2, cy - sz//2), logo)
    else:
        rr(d, [cx-50, cy-50, cx+50, cy+50], 15, CYAN)
        d.text((cx, cy), "∫", fill=WHITE, font=gf(60, True), anchor="mm")

def draw_phone(d, px, py, pw, ph, accent=CYAN):
    # Phone body
    rr(d, [px, py, px+pw, py+ph], 25, (20, 20, 35), outline=(60, 60, 80), w=2)
    # Screen
    rr(d, [px+6, py+30, px+pw-6, py+ph-6], 3, (15, 15, 25))
    # Notch
    rr(d, [px+pw//2-30, py+4, px+pw//2+30, py+20], 8, (30, 30, 45))

def draw_bold_text(d, x, y, text, fill, size, anchor="lt"):
    font = gf(size, True)
    # Shadow
    d.text((x+3, y+3), text, fill=(0, 0, 0), font=font, anchor=anchor)
    d.text((x, y), text, fill=fill, font=font, anchor=anchor)

def center_bold(d, y, text, fill, size):
    draw_bold_text(d, W//2, y, text, fill, size, "mt")

def flash_frame(base, intensity=1.0):
    """Create a white flash overlay."""
    overlay = Image.new("RGB", (W, H), (int(255*intensity), int(255*intensity), int(255*intensity)))
    return Image.blend(base, overlay, intensity * 0.3)

def add_particles(d, f, count=20, colors=None):
    """Add floating particles."""
    if colors is None: colors = [CYAN, PURPLE, MAGENTA, LIME, GOLD]
    random.seed(42)
    for _ in range(count):
        px = random.randint(0, W)
        py = (random.randint(0, H) + f * (random.random() + 0.5) * 2) % (H + 20) - 10
        sz = random.randint(2, 5)
        c = random.choice(colors)
        alpha = int(180 + 75 * math.sin(f * 0.1 + random.random() * 6))
        c_final = tuple(min(255, int(v * alpha / 255)) for v in c)
        d.ellipse([px-sz, py-sz, px+sz, py+sz], fill=c_final)

# ═══════════════════════════════════════════════════════
# SCENE TIMELINE (60 seconds = 1800 frames at 30fps)
# ═══════════════════════════════════════════════════════

# Each scene: (start_sec, end_sec, function)
# Narration clips:
#   promo_01: 1.72s  — "Eight math modules. One app."
#   promo_02: 3.44s  — "Derivatives. Limits. Geometry. Inequalities."
#   promo_03: 2.88s  — "Step by step solutions. LaTeX rendered."
#   promo_04: 1.49s  — "Works completely offline."
#   promo_05: 1.81s  — "Built for BSCS students."
#   promo_06: 3.44s  — "MathCalcu. Math doesn't have to be hard."

def scene_hook(f):
    """0-3s: Black → flash → MATHCALCU"""
    img = Image.new("RGB", (W, H), (0, 0, 0))
    d = ImageDraw.Draw(img)
    
    if f < 15:  # Pure black
        pass
    elif f < 20:  # Flash
        t = (f - 15) / 5
        img = flash_frame(img, 1 - t)
        d = ImageDraw.Draw(img)
    elif f < 45:  # MATHCALCU text slams in
        t = ease_back(min(1, (f - 20) / 15))
        sz = int(80 * t)
        if sz > 10:
            center_bold(d, H//2 - 30, "MATHCALCU", CYAN, sz)
    elif f < 60:  # Tagline fades in
        center_bold(d, H//2 - 30, "MATHCALCU", CYAN, 80)
        t = ease(min(1, (f - 45) / 10))
        alpha = int(255 * t)
        c = tuple(min(255, int(v * t)) for v in WHITE)
        center_bold(d, H//2 + 60, "MATH SOLVER FOR BSCS", c, 28)
    elif f < 90:  # Hold
        center_bold(d, H//2 - 30, "MATHCALCU", CYAN, 80)
        center_bold(d, H//2 + 60, "MATH SOLVER FOR BSCS", WHITE, 28)
    
    if f >= 20:
        add_particles(d, f, 15)
    
    return img

def scene_problem(f):
    """3-6s: Student struggling with calculus"""
    img = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(img)
    # Dark gradient
    for y in range(H):
        t = y / H
        c = tuple(int(10*(1-t) + 20*t) for _ in range(3))
        d.line([(0, y), (W, y)], fill=c)
    
    if f < 15:
        center_bold(d, H//2 - 60, "CALCULUS PROBLEMS?", RED, 52)
    elif f < 30:
        center_bold(d, H//2 - 80, "CALCULUS PROBLEMS?", RED, 52)
        # Equation floating
        eq = "f(x) = sin(x²) + ln(cos(x))"
        t = ease(min(1, (f - 15) / 10))
        eq_x = int(W//2 - 300 * t)
        d.text((eq_x, H//2 + 20), eq, fill=(180, 180, 200), font=gf(28))
    else:
        center_bold(d, H//2 - 80, "CALCULUS PROBLEMS?", RED, 52)
        d.text((W//2 - 200, H//2 + 20), "f(x) = sin(x²) + ln(cos(x))", fill=(180, 180, 200), font=gf(28))
        # Question marks floating
        t = (f - 30) / 30
        for i in range(5):
            qx = W//2 + int(200 * math.sin(t * 4 + i * 1.2))
            qy = H//2 + 100 + int(50 * math.cos(t * 3 + i * 0.8))
            d.text((qx, qy), "?", fill=CORAL, font=gf(40, True))
    
    add_particles(d, f, 10, [RED, CORAL])
    return img

def scene_app_reveal(f):
    """6-10s: Phone drops in with app"""
    img = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(img)
    for y in range(H):
        t = y / H
        c = tuple(int(10*(1-t) + 25*t) for _ in range(3))
        d.line([(0, y), (W, y)], fill=c)
    
    cx, cy = W//2, H//2
    
    if f < 20:  # Phone drops from top
        t = ease_back(min(1, f / 20))
        ph_y = int(lerp(-500, cy - 250, t))
    else:
        ph_y = cy - 250
    
    # Glow behind phone
    for i in range(15, 0, -1):
        glow_c = (0, int(40*(1-i/15)), int(60*(1-i/15)))
        rr(d, [cx-110-i*3, ph_y-i*3, cx+110+i*3, ph_y+500+i*3], 35, glow_c)
    
    draw_phone(d, cx - 100, ph_y, 200, 500, CYAN)
    
    # App icon
    if f > 10:
        icon_t = ease_back(min(1, (f - 10) / 15))
        icon_sz = int(80 * icon_t)
        draw_logo(d, cx, ph_y + 150, icon_sz)
        
        if f > 25:
            draw_bold_text(d, cx, ph_y + 280, "MathCalcu", WHITE, 28, "mt")
    
    # "TAP SOLVE" hint
    if f > 40:
        t = ease(min(1, (f - 40) / 10))
        pulse = int(30 * math.sin((f - 40) * 0.3))
        rr(d, [cx-60, ph_y+340, cx+60, ph_y+380], 15, CYAN)
        d.text((cx, ph_y+360), "SOLVE", fill=WHITE, font=gf(16, True), anchor="mm")
    
    add_particles(d, f, 12)
    return img

def scene_modules_grid(f):
    """10-15s: 8 module cards in grid"""
    img = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(img)
    for y in range(H):
        t = y / H
        c = tuple(int(12*(1-t) + 30*t) for _ in range(3))
        d.line([(0, y), (W, y)], fill=c)
    
    center_bold(d, 50, "8 MODULES", CYAN, 48)
    
    modules = [
        ("Derivatives", CYAN), ("Slope", LIME),
        ("Limits", PURPLE), ("∞ Limits", MAGENTA),
        ("Inequalities", GOLD), ("Circles", CORAL),
        ("Distance", SKY), ("Slope-Int", MINT),
    ]
    
    card_w, card_h = 350, 150
    gap = 30
    grid_w = 2 * card_w + gap
    start_x = (W - grid_w) // 2
    start_y = 130
    
    for i, (name, color) in enumerate(modules):
        row, col = divmod(i, 2)
        delay = i * 4
        if f < delay:
            continue
        
        t = ease_back(min(1, (f - delay) / 12))
        cx_card = start_x + col * (card_w + gap) + card_w // 2
        cy_card = start_y + row * (card_h + gap) + card_h // 2
        
        # Pop in with scale
        scale = t
        w = int(card_w * scale)
        h = int(card_h * scale)
        x0 = cx_card - w // 2
        y0 = cy_card - h // 2
        
        if w > 20:
            # Glow border
            glow = int(40 + 20 * math.sin(f * 0.2 + i))
            rr(d, [x0-2, y0-2, x0+w+2, y0+h+2], 12, None, outline=(glow, glow, glow), w=1)
            rr(d, [x0, y0, x0+w, y0+h], 10, (25, 25, 50), outline=color, w=3)
            if scale > 0.7:
                center_bold(d, cy_card - 10, name, color, 20)
    
    # "ONE APP" at bottom
    if f > 40:
        t = ease(min(1, (f - 40) / 10))
        center_bold(d, H - 80, "ONE APP. NOTHING EXTRA.", WHITE, int(28 * t))
    
    return img

def scene_derivatives_fast(f):
    """15-20s: Quick derivatives showcase"""
    img = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(img)
    for y in range(H):
        t = y / H
        c = tuple(int(10*(1-t) + 20*t) for _ in range(3))
        d.line([(0, y), (W, y)], fill=c)
    
    cx, cy = W//2, H//2
    
    # Big equation
    center_bold(d, 120, "DERIVATIVES", CYAN, 56)
    
    # Phone with equation
    if f > 5:
        draw_phone(d, cx - 150, 200, 300, 600, CYAN)
        
        # Typing animation
        expr = "sin(x²) + ln(cos(x))"
        n = min(len(expr), (f - 5) * 2)
        if n > 0:
            rr(d, [cx-130, 260, cx+130, 310], 8, (25, 25, 50), outline=PURPLE, w=2)
            d.text((cx-120, 275), expr[:n], fill=WHITE, font=gf(18))
        
        # Result
        if f > 50:
            t = ease(min(1, (f - 50) / 15))
            rr(d, [cx-130, 340, cx+130, 400], 8, (25, 25, 50), outline=CYAN, w=2)
            d.text((cx-120, 355), "f'(x) =", fill=(150, 150, 170), font=gf(14))
            result = "2x·cos(x²) - tan(x)"
            center_bold(d, 380, result, LIME, 16)
        
        # Rules popping in
        rules = ["Chain Rule", "Power Rule", "Product Rule", "Quotient Rule"]
        for i, rule in enumerate(rules):
            rd = 60 + i * 10
            if f > rd:
                rt = ease_back(min(1, (f - rd) / 8))
                rx = cx + 200 + int(50 * math.sin(i * 1.5))
                ry = 250 + i * 60
                rr(d, [rx, ry, rx + 200, ry + 40], 8, (25, 25, 50), outline=PURPLE, w=2)
                d.text((rx + 100, ry + 20), rule, fill=PURPLE, font=gf(14, True), anchor="mm")
    
    add_particles(d, f, 10, [CYAN, PURPLE])
    return img

def scene_limits_fast(f):
    """20-25s: Quick limits showcase"""
    img = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(img)
    for y in range(H):
        t = y / H
        c = tuple(int(10*(1-t) + 22*t) for _ in range(3))
        d.line([(0, y), (W, y)], fill=c)
    
    cx, cy = W//2, H//2
    
    center_bold(d, 100, "LIMITS", PURPLE, 56)
    
    # 4 method cards
    methods = ["Substitution", "Factoring", "LCD", "Conjugate"]
    for i, m in enumerate(methods):
        md = i * 8
        if f > md:
            mt = ease_back(min(1, (f - md) / 10))
            mx = 150 + i * 420
            my = int(lerp(-100, 200, mt))
            rr(d, [mx, my, mx + 380, my + 100], 12, (25, 25, 50), outline=PURPLE, w=2)
            center_bold(d, my + 30, f"{i+1}. {m}", PURPLE if i < 2 else GOLD, 20)
    
    # Equation
    if f > 40:
        rr(d, [cx-300, 380, cx+300, 480], 12, (25, 25, 50), outline=LIME, w=2)
        center_bold(d, 400, "lim(x→2) (x²-4)/(x-2) = 4", LIME, 20)
    
    if f > 60:
        center_bold(d, 520, "4 METHODS. SMART DETECTION.", WHITE, 22)
    
    add_particles(d, f, 10, [PURPLE, GOLD])
    return img

def scene_geometry_fast(f):
    """25-30s: Quick geometry showcase"""
    img = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(img)
    for y in range(H):
        t = y / H
        c = tuple(int(10*(1-t) + 18*t) for _ in range(3))
        d.line([(0, y), (W, y)], fill=c)
    
    cx, cy = W//2, H//2
    
    center_bold(d, 80, "ANALYTIC GEOMETRY", CORAL, 48)
    
    # Circle
    if f > 5:
        t = ease(min(1, (f - 5) / 20))
        gr = int(120 * t)
        d.arc([cx-gr, 200-gr, cx+gr, 200+gr], 0, int(360*t), fill=CORAL, width=3)
        if t > 0.9:
            d.ellipse([cx-5, 195, cx+5, 205], fill=CORAL)
            d.text((cx+15, 180), "(x-3)²+(y+2)²=16", fill=TEXT_S if 'TEXT_S' in dir() else (176,176,195), font=gf(14))
    
    # Feature cards
    features = [
        ("Circles", "Center, radius, graph", CORAL),
        ("Distance", "Between two points", SKY),
        ("Slope", "Line equations", MINT),
        ("Inequalities", "Number line", GOLD),
    ]
    for i, (name, desc, color) in enumerate(features):
        fd = 30 + i * 10
        if f > fd:
            ft = ease_back(min(1, (f - fd) / 10))
            fx = 150 + (i % 2) * 800
            fy = int(lerp(600, 350 + (i // 2) * 120, ft))
            rr(d, [fx, fy, fx + 350, fy + 90], 10, (25, 25, 50), outline=color, w=2)
            d.text((fx + 15, fy + 10), name, fill=color, font=gf(20, True))
            d.text((fx + 15, fy + 45), desc, fill=(150, 150, 170), font=gf(14))
    
    add_particles(d, f, 10, [CORAL, SKY, MINT])
    return img

def scene_offline(f):
    """30-33s: Offline feature"""
    img = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(img)
    for y in range(H):
        t = y / H
        c = tuple(int(8*(1-t) + 15*t) for _ in range(3))
        d.line([(0, y), (W, y)], fill=c)
    
    cx, cy = W//2, H//2
    
    # Big airplane icon
    if f < 15:
        t = ease_back(min(1, f / 12))
        sz = int(120 * t)
        center_bold(d, cy - 80, "OFF", WHITE, sz)
    
    center_bold(d, cy + 40, "100% OFFLINE", LIME, 56)
    center_bold(d, cy + 120, "No internet required", (150, 150, 170), 24)
    
    add_particles(d, f, 8, [LIME])
    return img

def scene_latex(f):
    """33-37s: LaTeX rendering feature"""
    img = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(img)
    for y in range(H):
        t = y / H
        c = tuple(int(10*(1-t) + 20*t) for _ in range(3))
        d.line([(0, y), (W, y)], fill=c)
    
    cx, cy = W//2, H//2
    
    center_bold(d, 150, "LaTeX RENDERED", PURPLE, 48)
    
    # Before/After
    if f > 10:
        # Plain text
        rr(d, [cx-350, 250, cx-20, 350], 10, (25, 25, 50), outline=(100, 100, 120), w=2)
        d.text((cx-330, 270), "Plain text:", fill=(150, 150, 170), font=gf(14))
        d.text((cx-330, 300), "x^2 + y^2 = r^2", fill=WHITE, font=gf(18))
        
        # Arrow
        if f > 25:
            t = ease(min(1, (f - 25) / 10))
            arrow_x = int(cx - 185 + 20 * t)
            center_bold(d, 300, "→", CYAN, 36)
        
        # LaTeX rendered
        if f > 30:
            t = ease_back(min(1, (f - 30) / 12))
            rr(d, [cx+20, 250, cx+350, 350], 10, (25, 25, 50), outline=PURPLE, w=int(2*t+1))
            d.text((cx+40, 270), "LaTeX:", fill=PURPLE, font=gf(14))
            # Simulated rendered equation
            d.text((cx+40, 300), "x² + y² = r²", fill=WHITE, font=gf(22, True))
    
    center_bold(d, 420, "ACADEMIC PRECISION", WHITE, 24)
    
    add_particles(d, f, 10, [PURPLE])
    return img

def scene_cross_platform(f):
    """37-41s: Cross-platform"""
    img = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(img)
    for y in range(H):
        t = y / H
        c = tuple(int(10*(1-t) + 18*t) for _ in range(3))
        d.line([(0, y), (W, y)], fill=c)
    
    cx, cy = W//2, H//2
    
    center_bold(d, 120, "CROSS-PLATFORM", SKY, 48)
    
    # 4 device mockups
    devices = [
        ("Android", 200, 300, CYAN),
        ("iOS", 600, 300, LIME),
        ("Web", 1000, 300, GOLD),
        ("Desktop", 1400, 300, PURPLE),
    ]
    
    for i, (name, dx, dy, color) in enumerate(devices):
        dd = i * 8
        if f > dd:
            dt = ease_back(min(1, (f - dd) / 10))
            # Device shape
            if i < 2:  # Phones
                draw_phone(d, dx, int(lerp(-300, dy, dt)), 120, 220, color)
            elif i == 2:  # Web
                rr(d, [dx, int(lerp(-300, dy, dt)), dx+200, int(lerp(-300, dy, dt))+150], 8, (25, 25, 50), outline=color, w=2)
            else:  # Desktop
                rr(d, [dx, int(lerp(-300, dy, dt)), dx+200, int(lerp(-300, dy, dt))+140], 5, (25, 25, 50), outline=color, w=2)
                rr(d, [dx+60, int(lerp(-300, dy, dt))+140, dx+140, int(lerp(-300, dy, dt))+160], 3, color)
            
            if dt > 0.5:
                center_bold(d, int(lerp(-300, dy, dt)) + 240, name, color, 16)
    
    center_bold(d, 600, "ONE CODEBASE. EVERYWHERE.", WHITE, 24)
    
    add_particles(d, f, 10, [CYAN, LIME, GOLD, PURPLE])
    return img

def scene_cta(f):
    """41-50s: Call to action"""
    img = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(img)
    
    # Purple to cyan gradient
    for y in range(H):
        t = y / H
        r = int(60*(1-t) + 0*t)
        g = int(20*(1-t) + 150*t)
        b = int(120*(1-t) + 180*t)
        d.line([(0, y), (W, y)], fill=(r, g, b))
    
    cx, cy = W//2, H//2
    
    # Logo drops in
    if f < 20:
        t = ease_back(min(1, f / 15))
        icon_y = int(lerp(-200, cy - 150, t))
        draw_logo(d, cx, icon_y, int(100 * t))
    else:
        draw_logo(d, cx, cy - 150, 100)
    
    # App name
    if f > 10:
        t = ease(min(1, (f - 10) / 10))
        center_bold(d, cy - 40, "MathCalcu", WHITE, int(64 * t))
    
    # Tagline
    if f > 25:
        t = ease(min(1, (f - 25) / 10))
        center_bold(d, cy + 40, "Built by BSCS students — for BSCS students", (200, 200, 220), int(22 * t))
    
    # GitHub link
    if f > 50:
        t = ease(min(1, (f - 50) / 10))
        rr(d, [cx-200, cy+100, cx+200, cy+150], 25, (255, 255, 255), outline=GOLD, w=2)
        center_bold(d, cy + 115, "⭐ Star on GitHub", (30, 30, 40), 18)
        center_bold(d, cy + 180, "github.com/Shuash11/MathCalcu", (180, 180, 200), 16)
    
    # Share
    if f > 70:
        center_bold(d, cy + 230, "Share with your classmates", WHITE, 20)
    
    add_particles(d, f, 15)
    return img

def scene_close(f):
    """50-55s: Final tagline on black"""
    img = Image.new("RGB", (W, H), (0, 0, 0))
    d = ImageDraw.Draw(img)
    
    if f < 30:
        t = ease(min(1, f / 15))
        center_bold(d, H//2, "Math doesn't have to be hard.", (int(255*t), int(255*t), int(255*t)), 36)
    elif f < 60:
        center_bold(d, H//2, "Math doesn't have to be hard.", WHITE, 36)
        # Fade out
        if f > 45:
            t = 1 - ease(min(1, (f - 45) / 15))
            center_bold(d, H//2, "Math doesn't have to be hard.",
                       (int(255*t), int(255*t), int(255*t)), 36)
    # After 60 frames (2s), stay black
    return img

# ═══════════════════════════════════════════════════════
# BUILD
# ═══════════════════════════════════════════════════════

# Scene timeline (seconds)
SCENE_LIST = [
    ("hook",         scene_hook,         0,   3),
    ("problem",      scene_problem,      3,   6),
    ("app_reveal",   scene_app_reveal,   6,  10),
    ("modules",      scene_modules_grid, 10, 15),
    ("derivatives",  scene_derivatives_fast, 15, 20),
    ("limits",       scene_limits_fast,  20, 25),
    ("geometry",     scene_geometry_fast,25, 30),
    ("offline",      scene_offline,      30, 33),
    ("latex",        scene_latex,        33, 37),
    ("platform",     scene_cross_platform,37, 41),
    ("cta",          scene_cta,          41, 50),
    ("close",        scene_close,        50, 55),
]

# Narration timing (seconds into video)
NARR_TIMING = [
    ("promo_01.mp3", 10.5),   # "8 modules. One app." — during modules grid
    ("promo_02.mp3", 15.5),   # "Derivatives. Limits..." — during derivatives
    ("promo_03.mp3", 22.0),   # "Step by step..." — during limits
    ("promo_04.mp3", 30.5),   # "Works offline" — during offline
    ("promo_05.mp3", 37.5),   # "Built for BSCS" — during cross-platform
    ("promo_06.mp3", 45.0),   # "MathCalcu..." — during CTA
]

def get_dur(path):
    r = subprocess.run(["ffprobe","-v","quiet","-show_entries","format=duration",
                       "-of","default=noprint_wrappers=1:nokey=1",path],
                       capture_output=True, text=True)
    return float(r.stdout.strip())

# Build video
print("Building promo video...")
frame_idx = 0
seg_files = []

for sname, sfunc, t_start, t_end in SCENE_LIST:
    dur = t_end - t_start
    nf = dur * FPS
    print(f"  {sname}: {t_start}s-{t_end}s ({nf} frames)")
    
    for i in range(nf):
        frame = sfunc(f=i)
        # Fade in (first 5 frames)
        if i < 5:
            frame = Image.blend(Image.new("RGB", (W, H)), frame, ease(i / 5))
        # Fade out (last 5 frames)
        elif i >= nf - 5:
            frame = Image.blend(Image.new("RGB", (W, H)), frame, ease((nf - i) / 5))
        frame.save(os.path.join(FRAMES_DIR, f"frame_{frame_idx:06d}.png"))
        frame_idx += 1

print(f"\nTotal frames: {frame_idx} ({frame_idx/FPS:.1f}s)")

# Create silent audio track
print("Creating silent base track...")
silent = os.path.join(BASE, "_silent.wav")
subprocess.run(["ffmpeg", "-y", "-f", "lavfi", "-i",
               f"anullsrc=r=44100:cl=stereo:d={frame_idx/FPS}",
               "-c:a", "pcm_s16le", silent], capture_output=True)

# Build video from frames (no audio yet)
print("Building video track...")
video_only = os.path.join(BASE, "_video_only.mp4")
subprocess.run(["ffmpeg", "-y", "-framerate", str(FPS),
               "-i", os.path.join(FRAMES_DIR, "frame_%06d.png"),
               "-c:v", "libx264", "-pix_fmt", "yuv420p",
               "-r", str(FPS), video_only], capture_output=True)

# Mix narration onto silent track
print("Mixing narration...")
mixed_audio = os.path.join(BASE, "_mixed_audio.wav")

# Build filter: delay each narration and mix
inputs = ["-i", silent]
filter_parts = []
for i, (narr_file, t_start) in enumerate(NARR_TIMING):
    narr_path = os.path.join(NARR_DIR, narr_file)
    if os.path.exists(narr_path):
        inputs += ["-i", narr_path]
        delay_ms = int(t_start * 1000)
        filter_parts.append(f"[{i+1}:a]adelay={delay_ms}|{delay_ms}[d{i}]")

# Mix all
mix_src = "[0:a]" + "".join(f"[d{i}]" for i in range(len(NARR_TIMING)))
n_inputs = 1 + len(NARR_TIMING)
filter_parts.append(f"{mix_src}amix=inputs={n_inputs}:duration=first:dropout_transition=0,atrim=0:{frame_idx/FPS}[out]")

filter_complex = ";".join(filter_parts)
cmd = ["ffmpeg", "-y"] + inputs + ["-filter_complex", filter_complex,
       "-map", "[out]", "-c:a", "pcm_s16le", mixed_audio]

r = subprocess.run(cmd, capture_output=True, text=True)
if r.returncode != 0:
    print(f"  Mix error: {r.stderr[-500:]}")
else:
    print("  Audio mixed OK")

# Combine video + audio
print("Combining...")
final = OUTPUT
cmd = ["ffmpeg", "-y", "-i", video_only, "-i", mixed_audio,
       "-c:v", "libx264", "-c:a", "aac", "-b:a", "192k",
       "-map", "0:v:0", "-map", "1:a:0",
       "-shortest", "-pix_fmt", "yuv420p",
       "-movflags", "+faststart", final]
r = subprocess.run(cmd, capture_output=True, text=True)
if r.returncode == 0:
    sz = os.path.getsize(final) / (1024*1024)
    dur = get_dur(final)
    print(f"\nDONE! {sz:.1f} MB, {dur:.1f}s -> {final}")
else:
    print(f"Error: {r.stderr[-300:]}")

# Cleanup
for f in [silent, video_only, mixed_audio]:
    if os.path.exists(f): os.remove(f)
if os.path.isdir(FRAMES_DIR): shutil.rmtree(FRAMES_DIR)

# Copy to Downloads
copy_to = os.path.join(os.path.expanduser("~"), "Downloads", "mathcalcu_promo_v2.mp4")
shutil.copy2(final, copy_to)
print(f"Copied to {copy_to}")
