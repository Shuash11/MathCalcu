"""MathCalcu Promotional Video — 8-Scene Version following official script."""
import os, subprocess, json, math, shutil, random, struct, wave
from PIL import Image, ImageDraw, ImageFont

BASE = os.path.dirname(__file__)
FRAMES_DIR = os.path.join(BASE, "frames")
NARRATION_DIR = os.path.join(BASE, "narration")
OUTPUT = os.path.join(BASE, "mathcalcu_promo.mp4")
LOGO_PATH = os.path.join(BASE, "..", "assets", "images", "app_icon.png")
os.makedirs(FRAMES_DIR, exist_ok=True)

W, H = 1920, 1080
FPS = 15

# Colors from script
BG = (13, 13, 13)  # #0D0D0D
CARD_BG = (26, 26, 46)  # #1A1A2E
PRIMARY = (94, 53, 177)  # #5E35B1
SECONDARY = (0, 188, 212)  # #00BCD4
TEXT_W = (255, 255, 255)
TEXT_S = (176, 176, 195)  # #B0B0C3
RED = (255, 60, 60)
LIME = (100, 255, 100)
GOLD = (255, 215, 0)
CORAL = (255, 100, 80)
PURPLE = (120, 80, 255)
CYAN = (0, 220, 255)
MINT = (0, 255, 180)
SKY = (100, 200, 255)
MAGENTA = (255, 50, 150)

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

def ease(t): return max(0, min(1, 1-(1-t)**3))
def ease_out(t): return max(0, min(1, 1-(1-t)**2))
def lerp(a, b, t): return a + (b - a) * t

def grad(d, c1=BG, c2=(25, 15, 55)):
    for y in range(H):
        t = y / H
        c = tuple(int(c1[i]*(1-t) + c2[i]*t) for i in range(3))
        d.line([(0, y), (W, y)], fill=c)

def rr(d, xy, r, fill, outline=None, w=2):
    x0, y0, x1, y1 = xy
    d.rounded_rectangle(xy, r, fill=fill, outline=outline, width=w)

def draw_logo(d, cx, cy, sz=100):
    sz = max(10, sz)
    if LOGO:
        logo = LOGO.resize((sz, sz), Image.LANCZOS)
        d._image.paste(logo, (cx - sz//2, cy - sz//2), logo)
    else:
        rr(d, [cx-50, cy-50, cx+50, cy+50], 15, CYAN)
        d.text((cx, cy), "∫", fill=TEXT_W, font=gf(60, True), anchor="mm")

def draw_phone(d, px, py, pw, ph, accent=CYAN):
    rr(d, [px, py, px+pw, py+ph], 30, (22, 22, 50), outline=accent, w=2)
    # Screen area
    rr(d, [px+8, py+35, px+pw-8, py+ph-8], 5, BG)

def text_width(d, text, font):
    bbox = d.textbbox((0, 0), text, font=font)
    return bbox[2] - bbox[0]

def draw_centered_text(d, y, text, fill, font, cx=W//2):
    d.text((cx, y), text, fill=fill, font=font, anchor="mm")

# ═══════════════════════════════════════════════════════
# SCENE 1: COLD OPEN — THE PROBLEM (0:00–0:25, ~375 frames)
# ═══════════════════════════════════════════════════════
def scene_cold_open(f):
    img = Image.new("RGB", (W, H), (0, 0, 0))
    d = ImageDraw.Draw(img)
    
    # [0:00–0:01] Black screen, silence (0-15 frames)
    # [0:01–0:05] Clock tick, white text fades in (15-75 frames)
    if 15 <= f < 75:
        t = ease((f - 15) / 30)
        alpha = int(255 * t)
        draw_centered_text(d, H//2 - 40, "You have a Calculus problem.",
                          (alpha, alpha, alpha), gf(48, True))
    
    # [0:05–0:10] Text fades, new text (75-150 frames)
    if 45 <= f < 75:
        t = 1 - ease((f - 45) / 30)
        alpha = int(255 * t)
        draw_centered_text(d, H//2 - 40, "You have a Calculus problem.",
                          (alpha, alpha, alpha), gf(48, True))
    if 75 <= f < 150:
        t = ease((f - 75) / 30)
        alpha = int(255 * t)
        draw_centered_text(d, H//2 - 40, "And your textbook isn't helping.",
                          (alpha, alpha, alpha), gf(48, True))
    if 120 <= f < 150:
        t = 1 - ease((f - 120) / 30)
        alpha = int(255 * t)
        draw_centered_text(d, H//2 - 40, "And your textbook isn't helping.",
                          (alpha, alpha, alpha), gf(48, True))
    
    # [0:15–0:20] Whiteboard with equation (150-300 frames)
    if 150 <= f < 300:
        t = ease((f - 150) / 30)
        # Whiteboard
        wb_x, wb_y = W//2 - 400, H//2 - 200
        rr(d, [wb_x, wb_y, wb_x + 800, wb_y + 400], 10, (240, 240, 240), outline=(200, 200, 200), w=2)
        # Equation text
        eq = "f(x) = sin(x²) + ln(cos(x))"
        font_eq = gf(int(40 * t), True)
        draw_centered_text(d, H//2, eq, (30, 30, 30), font_eq)
    
    # [0:20–0:25] Phone screen glows, MathCalcu icon (300-375 frames)
    if f >= 300:
        t = ease((f - 300) / 30)
        # Dark background
        img = Image.new("RGB", (W, H), (0, 0, 0))
        d = ImageDraw.Draw(img)
        
        # Phone glow
        glow_alpha = int(80 * t)
        for i in range(20, 0, -1):
            c = (0, int(188 * t * (1 - i/20)), int(212 * t * (1 - i/20)))
            rr(d, [W//2 - 110 - i*2, H//2 - 190 - i*2, W//2 + 110 + i*2, H//2 + 190 + i*2], 35, c)
        
        draw_phone(d, W//2 - 100, H//2 - 180, 200, 360, SECONDARY)
        
        # App icon in phone
        icon_sz = int(80 * t)
        if icon_sz > 10:
            draw_logo(d, W//2, H//2, icon_sz)
    
    return img

# ═══════════════════════════════════════════════════════
# SCENE 2: APP REVEAL (0:25–1:00, ~525 frames)
# ═══════════════════════════════════════════════════════
def scene_app_reveal(f):
    img = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(img)
    grad(d)
    cx, cy = W//2, H//2
    
    # [0:25–0:35] App home screen full on dark bg (0-150)
    if f < 150:
        t = ease(min(1, f / 30))
        # Phone mockup center
        draw_phone(d, cx - 160, 80, 320, 800, SECONDARY)
        # App header
        rr(d, [cx-145, 115, cx+145, 160], 5, PRIMARY)
        draw_centered_text(d, 137, "MathCalcu", TEXT_W, gf(20, True), cx)
        # Module grid
        mods = [("Derivatives", CYAN), ("Slope", LIME), ("Limits", PURPLE),
                ("∞ Limits", MAGENTA), ("Ineq.", GOLD), ("Circles", CORAL),
                ("Distance", SKY), ("Slope-Int", MINT)]
        for i, (name, color) in enumerate(mods):
            row, col = divmod(i, 2)
            mx = cx - 145 + col * 155
            my = 180 + row * 90
            if f > 20 + i * 5:
                card_t = ease(min(1, (f - 20 - i * 5) / 10))
                rr(d, [mx, my, mx + 145, my + 75], 8, CARD_BG, outline=color, w=2)
                draw_centered_text(d, my + 37, name, color, gf(14, True), mx + 72)
    
    # [0:35–0:45] Title + tagline (150-300)
    if f >= 150:
        t = ease(min(1, (f - 150) / 20))
        # Title springs up
        title_y = int(lerp(cy + 100, cy - 80, t))
        draw_centered_text(d, title_y, "MathCalcu", TEXT_W, gf(64, True))
        # Tagline fades
        if f > 170:
            tag_t = ease(min(1, (f - 170) / 15))
            tag_alpha = int(255 * tag_t)
            draw_centered_text(d, title_y + 70, "Powered Math System for BSCS Students",
                             (tag_alpha, tag_alpha, tag_alpha), gf(22), cx)
    
    # [0:45–0:55] Badge chips slide in (300-450)
    if f >= 300:
        badges = ["📴 100% Offline", "🧮 Step-by-Step Solutions", "✨ LaTeX Precision Rendering"]
        for i, badge in enumerate(badges):
            bd = 300 + i * 30
            if f > bd:
                bt = ease(min(1, (f - bd) / 15))
                bx = cx - 200
                by = int(lerp(H + 50, cy + 160 - i * 50, bt))
                rr(d, [bx, by, bx + 400, by + 40], 20, CARD_BG, outline=SECONDARY, w=2)
                draw_centered_text(d, by + 20, badge, TEXT_W, gf(16, True), cx)
    
    # [0:55–1:00] Pull back, gradient bg (450-525)
    if f >= 450:
        # Purple-to-cyan gradient
        for y in range(H):
            t = y / H
            r = int(94 * (1-t) + 0 * t)
            g = int(53 * (1-t) + 188 * t)
            b = int(177 * (1-t) + 212 * t)
            d.line([(0, y), (W, y)], fill=(r, g, b))
        
        t = ease(min(1, (f - 450) / 30))
        # Phone floats
        ph_y = int(lerp(80, cy - 200, t))
        draw_phone(d, cx - 120, ph_y, 240, 480, SECONDARY)
        draw_logo(d, cx, ph_y + 120, int(60 * t))
        draw_centered_text(d, ph_y + 220, "MathCalcu", TEXT_W, gf(24, True), cx)
    
    return img

# ═══════════════════════════════════════════════════════
# SCENE 3: MODULE SHOWCASE (1:00–1:45, ~675 frames)
# ═══════════════════════════════════════════════════════
def scene_module_showcase(f):
    img = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(img)
    grad(d)
    cx, cy = W//2, H//2
    
    modules = [
        ("Derivatives", "Symbolic differentiation\nwith full rule detection", CYAN),
        ("Slope Using\nDerivatives", "Slope at a point —\nexplicit, implicit, parametric", LIME),
        ("Evaluating\nLimits", "4 methods: Substitution,\nFactoring, LCD, Conjugate", PURPLE),
        ("Limits at\nInfinity", "Rational, radical,\nand trig forms", MAGENTA),
        ("Inequalities", "Linear, quadratic, rational,\nradical, absolute value", GOLD),
        ("Circles", "Center, radius,\nstandard & general form", CORAL),
        ("Distance &\nMidpoint", "With graphing support", SKY),
        ("Slope &\nIntercept", "Point-slope, two-point,\nparallel & perpendicular", MINT),
    ]
    
    # [1:00–1:10] Cards bounce in 2×4 grid (0-150)
    # [1:10–1:30] Each card glows + zoom one at a time (150-450)
    # [1:30–1:45] Collapse to dot → expand (450-675)
    
    card_w, card_h = 380, 180
    gap_x, gap_y = 40, 30
    grid_w = 2 * card_w + gap_x
    grid_h = 4 * card_h + gap_y
    start_x = (W - grid_w) // 2
    start_y = (H - grid_h) // 2
    
    active_card = -1
    if 150 <= f < 450:
        active_card = min(7, (f - 150) // 37)
    
    collapse_t = 0
    if f >= 450:
        collapse_t = ease(min(1, (f - 450) / 60))
    
    for i, (name, desc, color) in enumerate(modules):
        row, col = divmod(i, 2)
        cx_card = start_x + col * (card_w + gap_x) + card_w // 2
        cy_card = start_y + row * (card_h + gap_y) + card_h // 2
        
        # Bounce in
        if f < i * 10:
            continue
        bounce_t = ease(min(1, (f - i * 10) / 15))
        
        # Collapse
        if collapse_t > 0:
            cx_card = int(lerp(cx_card, W//2, collapse_t))
            cy_card = int(lerp(cy_card, H//2, collapse_t))
            scale = 1 - collapse_t * 0.8
        else:
            scale = 1.0
        
        # Active card glow/zoom
        zoom = 1.0
        if i == active_card:
            at = (f - 150 - i * 37) / 37
            zoom = 1.0 + 0.1 * math.sin(at * math.pi)
        
        w = int(card_w * scale * zoom)
        h = int(card_h * scale * zoom)
        x0 = cx_card - w // 2
        y0 = cy_card - h // 2
        
        if w > 20 and h > 20:
            glow_color = color if i == active_card else None
            rr(d, [x0, y0, x0 + w, y0 + h], 12, CARD_BG,
               outline=glow_color or color, w=3 if i == active_card else 2)
            
            if scale > 0.5:
                # Module name
                name_lines = name.split("\n")
                for li, nl in enumerate(name_lines):
                    draw_centered_text(d, y0 + 30 + li * 22, nl, color, gf(16, True), cx_card)
                # Description (show for active card)
                if i == active_card and scale > 0.8:
                    desc_lines = desc.split("\n")
                    for li, dl in enumerate(desc_lines):
                        draw_centered_text(d, y0 + 80 + li * 18, dl, TEXT_S, gf(12), cx_card)
    
    # Glowing dot at collapse
    if collapse_t > 0.5:
        dot_t = (collapse_t - 0.5) * 2
        dot_r = int(20 * (1 - dot_t) + 400 * dot_t)
        dot_alpha = int(255 * (1 - dot_t * 0.5))
        rr(d, [W//2 - dot_r, H//2 - dot_r, W//2 + dot_r, H//2 + dot_r],
           dot_r, (0, dot_alpha, dot_alpha))
    
    return img

# ═══════════════════════════════════════════════════════
# SCENE 4: TUTORIAL — DERIVATIVES (1:45–3:15, ~1350 frames)
# ═══════════════════════════════════════════════════════
def scene_derivatives(f):
    img = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(img)
    grad(d)
    cx, cy = W//2, H//2
    
    # Step labels
    steps = [
        (0, 150, "STEP 1 — OPEN DERIVATIVES"),
        (150, 375, "STEP 2 — ENTER YOUR EXPRESSION"),
        (375, 525, "STEP 3 — TAP SOLVE"),
        (525, 975, "STEP 4 — WALK THROUGH THE STEPS"),
        (975, 1350, "STEP 5 — RAPID DEMO REEL"),
    ]
    
    # Find current step
    step_label = ""
    for s_start, s_end, label in steps:
        if s_start <= f < s_end:
            step_label = label
            break
    
    # Phone mockup
    px, py, pw, ph = 100, 80, 400, 900
    draw_phone(d, px, py, pw, ph, PURPLE)
    rr(d, [px+15, py+40, px+pw-15, py+80], 5, PURPLE)
    draw_centered_text(d, py+60, "Derivatives", TEXT_W, gf(18, True), px+pw//2)
    
    # Step label bottom-left
    if step_label:
        rr(d, [50, H-60, 400, H-20], 5, CARD_BG, outline=SECONDARY, w=1)
        d.text((60, H-50), step_label, fill=SECONDARY, font=gf(14, True))
    
    # Step 2: Type expression
    expr = "sin(x^2) + ln(cos(x))"
    if 150 <= f < 375:
        t = (f - 150) / 225
        n = min(len(expr), int(len(expr) * t))
        rr(d, [px+20, py+100, px+pw-20, py+150], 8, CARD_BG, outline=PURPLE, w=2)
        d.text((px+35, py+115), expr[:n], fill=TEXT_W, font=gf(18))
        if f > 200:
            draw_centered_text(d, py+180, "Supports polynomials, trig, exponentials,",
                             TEXT_S, gf(12), px+pw//2)
            draw_centered_text(d, py+200, "logarithms, composites, products, quotients",
                             TEXT_S, gf(12), px+pw//2)
    
    # Step 3: Tap solve + loading
    if 375 <= f < 525:
        # Solve button
        rr(d, [px+80, py+160, px+pw-80, py+210], 10, PRIMARY)
        draw_centered_text(d, py+185, "SOLVE", TEXT_W, gf(18, True), px+pw//2)
        
        # Loading animation
        if f > 400:
            load_t = (f - 400) / 125
            dot_r = 5 + int(3 * math.sin(load_t * math.pi * 6))
            for i in range(3):
                dx = int(20 * math.sin(load_t * math.pi * 2 + i * 2.1))
                d.ellipse([px+pw//2-15+i*15+dx, py+230-dot_r, px+pw//2-15+i*15+dx+dot_r*2, py+230+dot_r],
                         fill=SECONDARY)
    
    # Step 4: Walk through solution
    if 525 <= f < 975:
        solution_blocks = [
            ("Problem Statement", "sin(x²) + ln(cos(x))", CYAN),
            ("Chain Rule on sin(x²)", "cos(x²) · 2x", PURPLE),
            ("Chain Rule on ln(cos(x))", "-sin(x)/cos(x)", PURPLE),
            ("Apply Differentiation", "2x·cos(x²) - tan(x)", LIME),
            ("Simplify", "f'(x) = 2x·cos(x²) - tan(x)", GOLD),
        ]
        
        sy = py + 100
        for i, (title, content, color) in enumerate(solution_blocks):
            bd = 525 + i * 80
            if f > bd:
                bt = ease(min(1, (f - bd) / 20))
                block_x = px + 20
                block_w = pw - 40
                block_h = 60
                sy_i = sy + i * 70
                
                rr(d, [block_x, sy_i, block_x + block_w, sy_i + block_h], 8, CARD_BG, outline=color, w=2)
                d.text((block_x + 10, sy_i + 5), title, fill=color, font=gf(13, True))
                d.text((block_x + 10, sy_i + 28), content, fill=TEXT_W, font=gf(14))
                
                # Glow on chain rule blocks
                if i in [1, 2] and bt > 0.5:
                    glow_a = int(40 * math.sin(bt * math.pi))
                    rr(d, [block_x-3, sy_i-3, block_x+block_w+3, sy_i+block_h+3], 10,
                       None, outline=(glow_a, glow_a, glow_a), w=1)
        
        # Final answer zoom
        if f > 875:
            zt = ease(min(1, (f - 875) / 50))
            # Highlight final answer
            rr(d, [px+17, sy+280-5, px+pw-17, sy+340+5], 8, None, outline=GOLD, w=3)
    
    # Step 5: Rapid demo reel
    if f >= 975:
        demos = [
            ("x³ - 2x + 5", "3x² - 2", "Power Rule"),
            ("e^(2x)", "2·e^(2x)", "Chain Rule"),
            ("(x+1)/(x-1)", "-2/(x-1)²", "Quotient Rule"),
            ("x² · sin(x)", "2x·sin(x) + x²·cos(x)", "Product Rule"),
        ]
        
        rx = px + pw + 80
        draw_centered_text(d, 140, "Rapid Demo", TEXT_W, gf(28, True), rx + 350)
        
        for i, (expr, ans, rule) in enumerate(demos):
            dd = 975 + i * 80
            if f > dd:
                dt = ease(min(1, (f - dd) / 20))
                dy = 200 + i * 100
                
                # Slide in from right
                slide_x = int(lerp(rx + 100, rx, dt))
                rr(d, [slide_x, dy, slide_x + 700, dy + 80], 10, CARD_BG, outline=CYAN, w=2)
                d.text((slide_x + 15, dy + 8), expr, fill=TEXT_W, font=gf(16, True))
                d.text((slide_x + 15, dy + 35), f"→ {ans}", fill=LIME, font=gf(14))
                d.text((slide_x + 500, dy + 35), rule, fill=SECONDARY, font=gf(12))
        
        # Rules list
        if f > 1100:
            draw_centered_text(d, 650, "Rules:", TEXT_W, gf(20, True), rx + 350)
            rules = ["Power Rule", "Chain Rule", "Product & Quotient",
                    "All 6 Trig", "Inverse Trig & Hyperbolic",
                    "Log & Exponential", "Square Root & Abs Value"]
            for i, rule in enumerate(rules):
                if f > 1120 + i * 10:
                    d.text((rx + 100, 690 + i * 28), "✅ " + rule, fill=LIME, font=gf(15))
    
    return img

# ═══════════════════════════════════════════════════════
# SCENE 5: TUTORIAL — LIMITS (3:15–4:15, ~900 frames)
# ═══════════════════════════════════════════════════════
def scene_limits(f):
    img = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(img)
    grad(d)
    cx, cy = W//2, H//2
    
    # [3:15–3:30] 4 method cards (0-225)
    methods = [
        ("1️⃣ By Substitution", CYAN),
        ("2️⃣ By Factoring", LIME),
        ("3️⃣ By LCD", GOLD),
        ("4️⃣ By Conjugate", CORAL),
    ]
    
    for i, (name, color) in enumerate(methods):
        md = i * 30
        if f > md:
            mt = ease(min(1, (f - md) / 15))
            mx = 100 + i * 440
            my = int(lerp(-100, 100, mt))
            rr(d, [mx, my, mx + 400, my + 60], 10, CARD_BG, outline=color, w=2)
            draw_centered_text(d, my + 30, name, color, gf(18, True), mx + 200)
    
    # Demo 1: By Substitution (225-450)
    if 225 <= f < 450:
        dt = ease(min(1, (f - 225) / 30))
        rr(d, [150, 200, 650, 380], 10, CARD_BG, outline=CYAN, w=2)
        draw_centered_text(d, 220, "BY SUBSTITUTION", CYAN, gf(16, True), 400)
        draw_centered_text(d, 260, "lim(x→2) x² + 3x", TEXT_W, gf(20), 400)
        if f > 300:
            draw_centered_text(d, 310, "= 4 + 6 = 10", LIME, gf(22, True), 400)
        draw_centered_text(d, 360, "Direct plug-in", TEXT_S, gf(14), 400)
    
    # Demo 2: By Factoring (450-675)
    if 450 <= f < 675:
        dt = ease(min(1, (f - 450) / 30))
        rr(d, [cx-250, 200, cx+250, 400], 10, CARD_BG, outline=LIME, w=2)
        draw_centered_text(d, 220, "BY FACTORING", LIME, gf(16, True), cx)
        draw_centered_text(d, 260, "lim(x→2) (x²-4)/(x-2)", TEXT_W, gf(18), cx)
        if f > 520:
            draw_centered_text(d, 300, "= lim(x→2) (x+2)(x-2)/(x-2)", TEXT_S, gf(14), cx)
        if f > 570:
            # Strikethrough animation
            draw_centered_text(d, 330, "= lim(x→2) (x+2) = 4", LIME, gf(18, True), cx)
            # Red strikethrough line
            strike_t = ease(min(1, (f - 570) / 15))
            strike_w = int(120 * strike_t)
            d.line([(cx - strike_w, 338), (cx + strike_w, 338)], fill=RED, width=2)
    
    # Demo 3: Limits at Infinity (675-900)
    if f >= 675:
        dt = ease(min(1, (f - 675) / 30))
        rr(d, [cx-300, 200, cx+300, 400], 10, CARD_BG, outline=PURPLE, w=2)
        draw_centered_text(d, 220, "LIMITS AT INFINITY", PURPLE, gf(16, True), cx)
        draw_centered_text(d, 260, "lim(x→∞) (3x²+2)/(x²-1)", TEXT_W, gf(18), cx)
        if f > 750:
            draw_centered_text(d, 310, "Dominant term wins", TEXT_S, gf(14), cx)
        if f > 800:
            draw_centered_text(d, 350, "= 3", LIME, gf(28, True), cx)
    
    # Bottom text
    if f > 100:
        draw_centered_text(d, H - 80, "Rational, Radical, Trig forms all supported",
                         TEXT_S, gf(18), cx)
    
    return img

# ═══════════════════════════════════════════════════════
# SCENE 6: TUTORIAL — ANALYTIC GEOMETRY (4:15–5:15, ~900 frames)
# ═══════════════════════════════════════════════════════
def scene_geometry(f):
    img = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(img)
    grad(d)
    cx, cy = W//2, H//2
    
    # Title card
    if f < 105:
        t = ease(min(1, f / 20))
        draw_centered_text(d, cy - 40, "ANALYTIC GEOMETRY", TEXT_W, gf(52, True))
        if f > 30:
            draw_centered_text(d, cy + 30, "Circles. Distance. Slope. Midpoint.",
                             TEXT_S, gf(20))
    else:
        # Demo 1: Circles (105-330)
        if 105 <= f < 330:
            rr(d, [80, 110, 600, 350], 10, CARD_BG, outline=CORAL, w=2)
            draw_centered_text(d, 130, "⭕ Circles", CORAL, gf(24, True), 340)
            d.text((100, 170), "x² + y² - 6x + 4y - 3 = 0", fill=TEXT_W, font=gf(14))
            
            if f > 180:
                d.text((100, 210), "Center: (3, -2)", fill=LIME, font=gf(16, True))
                d.text((100, 240), "Radius: 4", fill=LIME, font=gf(16, True))
                d.text((100, 270), "(x-3)² + (y+2)² = 16", fill=CYAN, font=gf(14))
            
            # Circle graph
            if f > 240:
                gx, gy, gr = 450, 250, 60
                draw_t = ease(min(1, (f - 240) / 30))
                arc_extent = int(360 * draw_t)
                d.arc([gx-gr, gy-gr, gx+gr, gy+gr], 0, arc_extent, fill=CORAL, width=2)
                if draw_t > 0.9:
                    d.ellipse([gx-4, gy-4, gx+4, gy+4], fill=CORAL)
                    d.text((gx+10, gy-20), "(3,-2)", fill=TEXT_S, font=gf(10))
        
        # Demo 2: Distance & Midpoint (330-540)
        if 330 <= f < 540:
            rr(d, [620, 110, 1140, 350], 10, CARD_BG, outline=SKY, w=2)
            draw_centered_text(d, 130, "📏 Distance & Midpoint", SKY, gf(22, True), 880)
            d.text((640, 170), "A(1, 2)   B(4, 6)", fill=TEXT_W, font=gf(16))
            
            if f > 400:
                d.text((640, 210), "Distance: 5 units", fill=LIME, font=gf(16, True))
                d.text((640, 240), "Midpoint: (2.5, 4)", fill=LIME, font=gf(16, True))
            
            # Graph with line
            if f > 450:
                gx1, gy1 = 750, 280
                gx2, gy2 = 1000, 200
                draw_t = ease(min(1, (f - 450) / 20))
                # Points
                d.ellipse([gx1-5, gy1-5, gx1+5, gy1+5], fill=SKY)
                d.ellipse([gx2-5, gy2-5, gx2+5, gy2+5], fill=SKY)
                # Line
                lx = int(lerp(gx1, gx2, draw_t))
                ly = int(lerp(gy1, gy2, draw_t))
                d.line([(gx1, gy1), (lx, ly)], fill=SKY, width=2)
                # Midpoint
                if draw_t > 0.9:
                    mx, my = (gx1+gx2)//2, (gy1+gy2)//2
                    d.ellipse([mx-4, my-4, mx+4, my+4], fill=GOLD)
        
        # Demo 3: Slope & Intercept (540-720)
        if 540 <= f < 720:
            rr(d, [1160, 110, 1680, 350], 10, CARD_BG, outline=MINT, w=2)
            draw_centered_text(d, 130, "➖ Slope & Intercept", MINT, gf(22, True), 1420)
            d.text((1180, 170), "(2, 3) and (5, 9)", fill=TEXT_W, font=gf(16))
            
            if f > 610:
                d.text((1180, 210), "Slope: 2", fill=LIME, font=gf(16, True))
                d.text((1180, 240), "y = 2x - 1", fill=LIME, font=gf(16, True))
        
        # Demo 4: Inequalities (720-900)
        if f >= 720:
            rr(d, [cx-350, 400, cx+350, 550], 10, CARD_BG, outline=GOLD, w=2)
            draw_centered_text(d, 420, "INEQUALITIES", GOLD, gf(18, True), cx)
            draw_centered_text(d, 460, "|x - 2| < 5", TEXT_W, gf(20), cx)
            
            if f > 780:
                draw_centered_text(d, 500, "-3 < x < 7", LIME, gf(18, True), cx)
                # Number line
                nl_y = 530
                d.line([(cx-200, nl_y), (cx+200, nl_y)], fill=TEXT_S, width=2)
                # Range highlight
                highlight_t = ease(min(1, (f - 780) / 20))
                hw = int(150 * highlight_t)
                d.line([(cx-hw, nl_y), (cx+hw, nl_y)], fill=LIME, width=4)
                for v in [-3, 0, 7]:
                    vx = cx + int(v * 20)
                    d.line([(vx, nl_y-5), (vx, nl_y+5)], fill=TEXT_S, width=1)
    
    return img

# ═══════════════════════════════════════════════════════
# SCENE 7: POWER FEATURES (5:15–5:45, ~450 frames)
# ═══════════════════════════════════════════════════════
def scene_power_features(f):
    img = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(img)
    grad(d)
    cx, cy = W//2, H//2
    
    features = [
        ("📴 Fully Offline",
         "All math runs on-device.\nNo internet. No API. No waiting.",
         SECONDARY),
        ("✨ LaTeX Rendering",
         "Every formula renders using flutter_math_fork —\nthe same typesetting as academic research papers.",
         PURPLE),
        ("📱 Cross-Platform",
         "One codebase.\nAndroid. iOS. Web. Desktop.",
         CYAN),
        ("🎓 Built for BSCS",
         "Covers exactly what BSCS students need —\naligned to your actual coursework.",
         PRIMARY),
    ]
    
    card_w, card_h = 700, 200
    card_x = cx - card_w // 2
    
    for i, (title, desc, color) in enumerate(features):
        card_start = i * 100
        card_end = card_start + 100
        
        if f >= card_start and f < card_end + 50:
            # Slide in from right
            t = ease(min(1, (f - card_start) / 20))
            card_y = int(lerp(cy + 200, cy - card_h // 2, t))
            
            # Exit left
            if f >= card_end:
                exit_t = ease(min(1, (f - card_end) / 15))
                card_x_i = int(lerp(cx - card_w // 2, -card_w - 50, exit_t))
            else:
                card_x_i = cx - card_w // 2
            
            rr(d, [card_x_i, card_y, card_x_i + card_w, card_y + card_h], 15, CARD_BG, outline=color, w=3)
            d.text((card_x_i + 30, card_y + 20), title, fill=color, font=gf(28, True))
            
            desc_lines = desc.split("\n")
            for li, dl in enumerate(desc_lines):
                d.text((card_x_i + 30, card_y + 70 + li * 25), dl, fill=TEXT_S, font=gf(16))
            
            # Special effects per feature
            if i == 1 and f > card_start + 30:  # LaTeX shimmer
                shimmer_t = (f - card_start - 30) / 40
                for si in range(4):
                    sx = card_x_i + 400 + int(si * 20 * math.sin(shimmer_t * math.pi + si))
                    d.text((sx, card_y + 80), "∑", fill=(200, 200, 255), font=gf(12))
            
            if i == 2 and f > card_start + 30:  # 4 devices
                devices = ["📱", "📲", "🌐", "🖥️"]
                for di, dev in enumerate(devices):
                    dx = card_x_i + 350 + di * 60
                    d.text((dx, card_y + 120), dev, fill=TEXT_W, font=gf(20))
    
    return img

# ═══════════════════════════════════════════════════════
# SCENE 8: CLOSING PROMO (5:45–6:15, ~450 frames)
# ═══════════════════════════════════════════════════════
def scene_closing(f):
    img = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(img)
    
    # Purple-to-cyan gradient background
    for y in range(H):
        t = y / H
        r = int(94 * (1-t) + 0 * t)
        g = int(53 * (1-t) + 188 * t)
        b = int(177 * (1-t) + 212 * t)
        d.line([(0, y), (W, y)], fill=(r, g, b))
    
    cx, cy = W//2, H//2
    
    # [5:45–5:55] Icon drops, bounces, lands (0-150)
    if f < 150:
        t = ease(min(1, f / 30))
        # Drop from above
        icon_y = int(lerp(-100, cy - 120, t))
        # Bounce effect
        if t > 0.8:
            bounce = math.sin((t - 0.8) * 25) * 10 * (1 - t)
            icon_y += int(bounce)
        
        icon_sz = int(120 * min(1, t * 2))
        draw_logo(d, cx, icon_y, icon_sz)
        
        if f > 60:
            draw_centered_text(d, icon_y + 90, "MathCalcu", TEXT_W, gf(48, True))
        if f > 90:
            draw_centered_text(d, icon_y + 140, "Powered Math System for BSCS Students",
                             TEXT_S, gf(18))
    
    # [5:55–6:05] CTAs fade in (150-300)
    if f >= 150:
        icon_y = cy - 120
        draw_logo(d, cx, icon_y, 120)
        draw_centered_text(d, icon_y + 90, "MathCalcu", TEXT_W, gf(48, True))
        draw_centered_text(d, icon_y + 140, "Powered Math System for BSCS Students",
                         TEXT_S, gf(18))
        
        ctas = [
            ("⭐ Star us on GitHub", GOLD),
            ("📲 Share with your classmates", TEXT_W),
            ("github.com/Shuash11/MathCalcu", TEXT_S),
        ]
        for i, (cta, color) in enumerate(ctas):
            cd = 150 + i * 30
            if f > cd:
                ct = ease(min(1, (f - cd) / 15))
                cta_y = int(lerp(icon_y + 200, icon_y + 200 + i * 45, ct))
                cta_alpha = int(255 * ct)
                c = tuple(min(255, int(color[j] * ct)) for j in range(3))
                draw_centered_text(d, cta_y, cta, c, gf(20 if i < 2 else 16, i < 2))
    
    # [6:05–6:10] Fade, icon pulse (300-375)
    if 300 <= f < 375:
        t = (f - 300) / 75
        alpha = int(255 * (1 - t))
        # Icon pulse
        pulse = 120 + int(10 * math.sin(t * math.pi * 2))
        draw_logo(d, cx, cy - 120, pulse)
    
    # [6:10–6:15] Black, final text (375-450)
    if f >= 375:
        img = Image.new("RGB", (W, H), (0, 0, 0))
        d = ImageDraw.Draw(img)
        t = ease(min(1, (f - 375) / 30))
        alpha = int(255 * t)
        draw_centered_text(d, H//2, "Math doesn't have to be hard.",
                         (alpha, alpha, alpha), gf(36, True))
    
    return img

# ═══════════════════════════════════════════════════════
# BUILD
# ═══════════════════════════════════════════════════════

def get_dur(path):
    r = subprocess.run(["ffprobe","-v","quiet","-print_format","json","-show_format",path],
                       capture_output=True, text=True)
    return float(json.loads(r.stdout)["format"]["duration"])

def pad_audio(input_path, output_path, target_dur):
    """Pad audio with silence to reach target duration."""
    dur = get_dur(input_path)
    if dur >= target_dur:
        # Just copy
        shutil.copy2(input_path, output_path)
        return
    silence_dur = target_dur - dur
    # Generate silence and concatenate
    cmd = [
        "ffmpeg", "-y",
        "-i", input_path,
        "-f", "lavfi", "-i", f"anullsrc=r=44100:cl=mono:d={silence_dur}",
        "-filter_complex", "[0:a][1:a]concat=n=2:v=0:a=1",
        "-c:a", "libmp3lame", "-b:a", "128k",
        output_path
    ]
    subprocess.run(cmd, capture_output=True)

# Target durations from script (in seconds)
SCENE_DURS = {
    "s01_cold_open": 25,
    "s02_app_reveal": 35,
    "s03_module_showcase": 45,
    "s04_derivatives": 90,
    "s05_limits": 60,
    "s06_geometry": 60,
    "s07_power_features": 30,
    "s08_closing": 30,
}

scenes = [
    ("s01_cold_open", scene_cold_open),
    ("s02_app_reveal", scene_app_reveal),
    ("s03_module_showcase", scene_module_showcase),
    ("s04_derivatives", scene_derivatives),
    ("s05_limits", scene_limits),
    ("s06_geometry", scene_geometry),
    ("s07_power_features", scene_power_features),
    ("s08_closing", scene_closing),
]

# Pad narration
print("Padding narration...")
for sname, target_dur in SCENE_DURS.items():
    narr = os.path.join(NARRATION_DIR, f"{sname}.mp3")
    padded = os.path.join(NARRATION_DIR, f"{sname}_padded.mp3")
    if os.path.exists(narr):
        pad_audio(narr, padded, target_dur)
        actual = get_dur(padded)
        print(f"  {sname}: {actual:.1f}s (target: {target_dur}s)")

# Render frames
print("\nRendering frames...")
frame_idx = 0
seg_info = []

for sname, sfunc in scenes:
    target_dur = SCENE_DURS[sname]
    nf = int(target_dur * FPS)
    print(f"  {sname}: {target_dur}s ({nf} frames)")
    
    for i in range(nf):
        frame = sfunc(f=i)
        # Fade in/out
        fade_frames = 10
        if i < fade_frames:
            frame = Image.blend(Image.new("RGB", (W, H)), frame, ease(i / fade_frames))
        elif i >= nf - fade_frames:
            frame = Image.blend(Image.new("RGB", (W, H)), frame, ease((nf - i) / fade_frames))
        frame.save(os.path.join(FRAMES_DIR, f"frame_{frame_idx:06d}.png"))
        frame_idx += 1
    
    seg_info.append((sname, nf))

print(f"\nTotal: {frame_idx} frames ({frame_idx/FPS:.1f}s)")

# Build segments
print("\nBuilding segments...")
segs = []
offset = 0
for sname, nf in seg_info:
    narr_padded = os.path.join(NARRATION_DIR, f"{sname}_padded.mp3")
    sdir = os.path.join(BASE, f"_sf_{sname}")
    os.makedirs(sdir, exist_ok=True)
    
    # Move frames to segment dir
    for i in range(nf):
        src = os.path.join(FRAMES_DIR, f"frame_{offset+i:06d}.png")
        dst = os.path.join(sdir, f"frame_{i:06d}.png")
        if os.path.exists(src):
            os.rename(src, dst)
    
    seg_mp4 = os.path.join(BASE, f"_seg_{sname}.mp4")
    ds = nf / FPS
    cmd = ["ffmpeg", "-y", "-framerate", str(FPS),
           "-i", os.path.join(sdir, "frame_%06d.png")]
    if os.path.exists(narr_padded):
        cmd += ["-i", narr_padded, "-c:v", "libx264", "-t", str(ds),
                "-c:a", "aac", "-b:a", "192k", "-shortest",
                "-map", "0:v:0", "-map", "1:a:0"]
    else:
        cmd += ["-c:v", "libx264", "-t", str(ds)]
    cmd += ["-pix_fmt", "yuv420p", "-r", str(FPS), seg_mp4]
    
    print(f"  {sname}: {ds:.1f}s")
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode == 0:
        segs.append(seg_mp4)
    else:
        print(f"    ERR: {r.stderr[-300:]}")
    offset += nf

# Concatenate
print("\nConcatenating...")
cl = os.path.join(BASE, "_cl.txt")
with open(cl, "w") as f:
    for s in segs:
        f.write(f"file '{s}'\n")

cmd = ["ffmpeg", "-y", "-f", "concat", "-safe", "0", "-i", cl,
       "-c:v", "libx264", "-c:a", "aac", "-b:a", "192k",
       "-map", "0:v:0", "-map", "0:a:0?",
       "-pix_fmt", "yuv420p", "-movflags", "+faststart", OUTPUT]
r = subprocess.run(cmd, capture_output=True, text=True)
if r.returncode == 0:
    sz = os.path.getsize(OUTPUT) / (1024*1024)
    print(f"\nDONE! {sz:.1f} MB -> {OUTPUT}")
else:
    print(f"Error: {r.stderr[-400:]}")

# Cleanup
for s in segs:
    if os.path.exists(s): os.remove(s)
for sname, _ in seg_info:
    d = os.path.join(BASE, f"_sf_{sname}")
    if os.path.isdir(d): shutil.rmtree(d)
if os.path.exists(cl): os.remove(cl)
if os.path.isdir(FRAMES_DIR): shutil.rmtree(FRAMES_DIR)
# Remove padded narration files
for sname in SCENE_DURS:
    padded = os.path.join(NARRATION_DIR, f"{sname}_padded.mp3")
    if os.path.exists(padded): os.remove(padded)
