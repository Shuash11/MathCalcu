"""Animated tutorial video for MathCalcu with LaTeX formulas and cute character."""
import os, subprocess, json, math, shutil
from PIL import Image, ImageDraw, ImageFont

BASE = os.path.dirname(__file__)
FRAMES_DIR = os.path.join(BASE, "frames")
NARRATION_DIR = os.path.join(BASE, "narration")
OUTPUT = os.path.join(BASE, "mathcalcu_tutorial.mp4")
os.makedirs(FRAMES_DIR, exist_ok=True)

W, H = 1920, 1080
FPS = 30

# ── Theme Colors ──
BG = (18, 18, 30)
SURFACE = (25, 25, 42)
CARD = (32, 32, 55)
CARD2 = (40, 40, 65)
PRIMARY = (124, 58, 237)
PRIMARY_L = (167, 139, 250)
GREEN = (34, 197, 94)
RED = (239, 68, 68)
WHITE = (255, 255, 255)
GRAY = (148, 163, 184)
YELLOW = (250, 204, 21)
CYAN = (34, 211, 238)
ORANGE = (249, 115, 22)

def get_font(size, bold=False):
    paths = [
        "C:/Windows/Fonts/segoeuib.ttf" if bold else "C:/Windows/Fonts/segoeui.ttf",
        "C:/Windows/Fonts/arialbd.ttf" if bold else "C:/Windows/Fonts/arial.ttf",
    ]
    for p in paths:
        if os.path.exists(p):
            try: return ImageFont.truetype(p, size)
            except: continue
    return ImageFont.load_default()

def draw_gradient(img, c1=BG, c2=(28, 22, 50)):
    draw = ImageDraw.Draw(img)
    for y in range(H):
        t = y / H
        r = int(c1[0]*(1-t)+c2[0]*t)
        g = int(c1[1]*(1-t)+c2[1]*t)
        b = int(c1[2]*(1-t)+c2[2]*t)
        draw.line([(0,y),(W,y)], fill=(r,g,b))
    return draw

def rounded_rect(draw, xy, r, fill, outline=None, width=2):
    x0,y0,x1,y1 = xy
    draw.rectangle([x0+r,y0,x1-r,y1], fill=fill)
    draw.rectangle([x0,y0+r,x1,y1-r], fill=fill)
    draw.pieslice([x0,y0,x0+2*r,y0+2*r], 180, 270, fill=fill)
    draw.pieslice([x1-2*r,y0,x1,y0+2*r], 270, 360, fill=fill)
    draw.pieslice([x0,y1-2*r,x0+2*r,y1], 90, 180, fill=fill)
    draw.pieslice([x1-2*r,y1-2*r,x1,y1], 0, 90, fill=fill)
    if outline:
        draw.rounded_rectangle(xy, r, outline=outline, width=width)

def ease_out(t): return 1-(1-t)**3
def ease_in_out(t):
    if t<0.5: return 4*t**3
    return 1-(-2*t+2)**3/2
def ease_out_bounce(t):
    if t<1/2.75: return 7.5625*t*t
    elif t<2/2.75: t-=1.5/2.75; return 7.5625*t*t+0.75
    elif t<2.5/2.75: t-=2.25/2.75; return 7.5625*t*t+0.9375
    else: t-=2.625/2.75; return 7.5625*t*t+0.984375

def lerp(a,b,t): return a+(b-a)*t

# ═══════════════════════════════════════════════════════
# CUTE STUDENT CHARACTER
# ═══════════════════════════════════════════════════════

class Student:
    """Draw a cute simple student character."""
    
    @staticmethod
    def draw(draw_ctx, x, y, scale=1.0, pose="stand", frame=0, color=None):
        """
        Draw student at (x, y) with given pose.
        pose: stand, walk, point, think, excited, wave
        """
        s = scale
        c = color or PRIMARY
        
        # Body colors
        skin = (255, 210, 170)
        hair = (60, 40, 30)
        shirt = c
        pants = (50, 50, 80)
        shoes = (40, 40, 40)
        eye = (30, 30, 30)
        cheek = (255, 150, 150)
        
        # Animation offsets
        walk_bob = math.sin(frame * 0.3) * 3 * s if pose == "walk" else 0
        arm_wave = math.sin(frame * 0.4) * 15 if pose == "wave" else 0
        think_bounce = math.sin(frame * 0.2) * 2 if pose == "think" else 0
        
        cy = y + walk_bob
        
        # Legs (with walk animation)
        if pose == "walk":
            leg_angle1 = math.sin(frame * 0.3) * 20
            leg_angle2 = -leg_angle1
        else:
            leg_angle1 = 0
            leg_angle2 = 0
        
        # Left leg
        lx = x - 8*s
        draw_ctx.line([(lx, cy+30*s), (lx + math.sin(math.radians(leg_angle1))*12*s, cy+55*s)], fill=pants, width=int(6*s))
        draw_ctx.ellipse([lx+math.sin(math.radians(leg_angle1))*12*s-4*s, cy+53*s, lx+math.sin(math.radians(leg_angle1))*12*s+4*s, cy+58*s], fill=shoes)
        
        # Right leg
        rx = x + 8*s
        draw_ctx.line([(rx, cy+30*s), (rx + math.sin(math.radians(leg_angle2))*12*s, cy+55*s)], fill=pants, width=int(6*s))
        draw_ctx.ellipse([rx+math.sin(math.radians(leg_angle2))*12*s-4*s, cy+53*s, rx+math.sin(math.radians(leg_angle2))*12*s+4*s, cy+58*s], fill=shoes)
        
        # Body (shirt)
        draw_ctx.rounded_rectangle([x-12*s, cy-5*s, x+12*s, cy+32*s], radius=int(6*s), fill=shirt)
        
        # Arms
        if pose == "point":
            # Right arm pointing
            draw_ctx.line([(x+12*s, cy+5*s), (x+35*s, cy-5*s)], fill=shirt, width=int(5*s))
            draw_ctx.ellipse([x+33*s-3*s, cy-8*s, x+33*s+5*s, cy-2*s], fill=skin)
            # Left arm
            draw_ctx.line([(x-12*s, cy+5*s), (x-18*s, cy+20*s)], fill=shirt, width=int(5*s))
        elif pose == "think":
            # Hand on chin
            draw_ctx.line([(x+12*s, cy+5*s), (x+15*s, cy-15*s+think_bounce)], fill=shirt, width=int(5*s))
            draw_ctx.ellipse([x+12*s, cy-18*s+think_bounce, x+18*s, cy-12*s+think_bounce], fill=skin)
            # Left arm
            draw_ctx.line([(x-12*s, cy+5*s), (x-18*s, cy+20*s)], fill=shirt, width=int(5*s))
        elif pose == "excited":
            # Both arms up
            draw_ctx.line([(x+12*s, cy+5*s), (x+25*s, cy-20*s)], fill=shirt, width=int(5*s))
            draw_ctx.ellipse([x+23*s, cy-24*s, x+29*s, cy-18*s], fill=skin)
            draw_ctx.line([(x-12*s, cy+5*s), (x-25*s, cy-20*s)], fill=shirt, width=int(5*s))
            draw_ctx.ellipse([x-29*s, cy-24*s, x-23*s, cy-18*s], fill=skin)
        elif pose == "wave":
            # Right arm waving
            wave_y = -15*s + arm_wave
            draw_ctx.line([(x+12*s, cy+5*s), (x+25*s, cy+wave_y)], fill=shirt, width=int(5*s))
            draw_ctx.ellipse([x+22*s, cy+wave_y-4*s, x+28*s, cy+wave_y+4*s], fill=skin)
            # Left arm
            draw_ctx.line([(x-12*s, cy+5*s), (x-18*s, cy+20*s)], fill=shirt, width=int(5*s))
        else:
            # Default arms down
            draw_ctx.line([(x+12*s, cy+5*s), (x+18*s, cy+22*s)], fill=shirt, width=int(5*s))
            draw_ctx.line([(x-12*s, cy+5*s), (x-18*s, cy+22*s)], fill=shirt, width=int(5*s))
        
        # Head
        draw_ctx.ellipse([x-14*s, cy-35*s, x+14*s, cy-5*s], fill=skin)
        
        # Hair
        draw_ctx.arc([x-15*s, cy-40*s, x+15*s, cy-15*s], 180, 360, fill=hair, width=int(8*s))
        draw_ctx.ellipse([x-15*s, cy-38*s, x+15*s, cy-25*s], fill=hair)
        
        # Eyes
        eye_y = cy - 22*s
        if pose == "excited":
            # Happy eyes (^_^)
            draw_ctx.arc([x-9*s, eye_y-3*s, x-3*s, eye_y+3*s], 200, 340, fill=eye, width=int(2*s))
            draw_ctx.arc([x+3*s, eye_y-3*s, x+9*s, eye_y+3*s], 200, 340, fill=eye, width=int(2*s))
        elif pose == "think":
            # Looking up
            draw_ctx.ellipse([x-8*s, eye_y-2*s, x-4*s, eye_y+2*s], fill=eye)
            draw_ctx.ellipse([x+4*s, eye_y-4*s, x+8*s, eye_y], fill=eye)
        else:
            # Normal eyes
            draw_ctx.ellipse([x-8*s, eye_y-2*s, x-4*s, eye_y+2*s], fill=eye)
            draw_ctx.ellipse([x+4*s, eye_y-2*s, x+8*s, eye_y+2*s], fill=eye)
            # Eye shine
            draw_ctx.ellipse([x-7*s, eye_y-1*s, x-5*s, eye_y+1*s], fill=WHITE)
            draw_ctx.ellipse([x+5*s, eye_y-1*s, x+7*s, eye_y+1*s], fill=WHITE)
        
        # Cheeks
        draw_ctx.ellipse([x-13*s, eye_y+4*s, x-7*s, eye_y+8*s], fill=cheek)
        draw_ctx.ellipse([x+7*s, eye_y+4*s, x+13*s, eye_y+8*s], fill=cheek)
        
        # Mouth
        if pose == "excited":
            draw_ctx.arc([x-4*s, cy-16*s, x+4*s, cy-10*s], 0, 180, fill=eye, width=int(2*s))
        elif pose == "think":
            draw_ctx.ellipse([x-2*s, cy-14*s, x+2*s, cy-12*s], fill=eye)
        else:
            draw_ctx.arc([x-4*s, cy-17*s, x+4*s, cy-12*s], 0, 180, fill=eye, width=int(2*s))
        
        # Glasses (optional - makes it look studious)
        if pose in ["think", "point"]:
            draw_ctx.rounded_rectangle([x-11*s, eye_y-4*s, x-1*s, eye_y+4*s], radius=int(2*s), outline=GRAY, width=int(1.5*s))
            draw_ctx.rounded_rectangle([x+1*s, eye_y-4*s, x+11*s, eye_y+4*s], radius=int(2*s), outline=GRAY, width=int(1.5*s))
            draw_ctx.line([(x-1*s, eye_y), (x+1*s, eye_y)], fill=GRAY, width=int(1*s))

# ═══════════════════════════════════════════════════════
# LATEX RENDERING (Unicode approximation)
# ═══════════════════════════════════════════════════════

def render_latex_block(draw, x, y, formulas, font_size=28):
    """Render LaTeX-style math formulas using Unicode symbols."""
    f = get_font(font_size, True)
    f_sm = get_font(font_size - 6)
    
    colors = [WHITE, CYAN, YELLOW, GREEN, PRIMARY_L]
    
    for i, (label, formula) in enumerate(formulas):
        ry = y + i * (font_size + 18)
        
        # Label
        if label:
            draw.text((x, ry), label, fill=GRAY, font=f_sm)
            ry += font_size - 4
        
        # Formula with fancy rendering
        # Background card
        bbox = draw.textbbox((0, 0), formula, font=f)
        tw = bbox[2] - bbox[0]
        rounded_rect(draw, (x-5, ry-3, x+tw+15, ry+font_size+5), 8, CARD2)
        
        # Colored math text
        draw.text((x+5, ry), formula, fill=colors[i % len(colors)], font=f)

def latex_formula(draw, x, y, text, size=32, color=CYAN):
    """Render a single LaTeX-style formula."""
    f = get_font(size, True)
    bbox = draw.textbbox((0,0), text, font=f)
    tw = bbox[2] - bbox[0]
    # Fancy underline
    draw.line([(x, y+size+4), (x+tw, y+size+4)], fill=color, width=2)
    draw.text((x, y), text, fill=color, font=f)

# ═══════════════════════════════════════════════════════
# SLIDE GENERATORS
# ═══════════════════════════════════════════════════════

def make_title(frame=0, alpha=1.0):
    img = Image.new("RGB", (W, H))
    draw = draw_gradient(img)
    
    # Floating particles
    for i in range(20):
        px = (i * 97 + frame * 2) % W
        py = (i * 53 + frame) % H
        ps = 2 + (i % 3)
        a = int(40 + 20 * math.sin(frame * 0.05 + i))
        draw.ellipse([px-ps, py-ps, px+ps, py+ps], fill=(PRIMARY[0], PRIMARY[1], PRIMARY[2]))
    
    cx, cy = W//2, H//2 - 120
    
    # Bouncing app icon
    bounce = ease_out_bounce(min(1.0, frame / 30)) if frame < 30 else 1.0
    icon_y = cy - 50 + (1 - bounce) * -100
    
    draw.ellipse([cx-55, icon_y-55, cx+55, icon_y+55], fill=PRIMARY)
    draw.text((cx, icon_y), "π", fill=WHITE, font=get_font(48, True), anchor="mm")
    
    # Title with typewriter effect
    title = "MathCalcu"
    chars_shown = min(len(title), int(frame / 3) + 1) if frame < 40 else len(title)
    shown_title = title[:chars_shown]
    
    draw.text((W//2, cy+100), shown_title, fill=WHITE, font=get_font(68, True), anchor="mm")
    
    if frame > 40:
        draw.text((W//2, cy+170), "Powered Math System", fill=PRIMARY_L, font=get_font(28), anchor="mm")
    if frame > 60:
        draw.text((W//2, cy+220), "Calculus  •  Analytic Geometry  •  Step-by-Step  •  Offline", 
                  fill=GRAY, font=get_font(22), anchor="mm")
    
    # Student character walking in from left
    if frame > 50:
        char_x = min(280, 50 + (frame - 50) * 8)
        Student.draw(draw, char_x, cy + 80, scale=1.5, pose="wave", frame=frame)
    
    return img

def make_features(frame=0, alpha=1.0):
    img = Image.new("RGB", (W, H))
    draw = draw_gradient(img)
    
    draw.text((W//2, 60), "Features Overview", fill=WHITE, font=get_font(44, True), anchor="mm")
    
    features = [
        ("Derivatives", "Symbolic differentiation", "d/dx", CYAN),
        ("Slope", "Find slope at any point", "m=f'(a)", GREEN),
        ("Limits", "4 solving methods", "lim", YELLOW),
        ("Inequalities", "All types supported", "≥ ≤", ORANGE),
        ("Circles", "Standard & general form", "⊙", RED),
        ("Distance", "Distance & midpoint", "d=√Δ²", PRIMARY_L),
    ]
    
    cw, ch = 480, 160
    cols = 3
    sx = (W - cols*(cw+40)+40)//2
    
    for i, (title, desc, icon, color) in enumerate(features):
        col, row = i % cols, i // cols
        x = sx + col*(cw+40)
        y = 140 + row*(ch+30)
        
        # Staggered slide-in animation
        delay = i * 5
        if frame > delay:
            progress = min(1.0, (frame - delay) / 20)
            x_offset = int(80 * (1 - ease_out(progress)))
            x += x_offset
            a = ease_out(progress)
        else:
            a = 0
        
        if a <= 0: continue
        
        rounded_rect(draw, (x, y, x+cw, y+ch), 14, CARD)
        
        # Icon circle
        draw.ellipse([x+18, y+18, x+58, y+58], fill=color)
        draw.text((x+38, y+38), icon, fill=WHITE, font=get_font(18, True), anchor="mm")
        
        draw.text((x+75, y+25), title, fill=WHITE, font=get_font(24, True))
        draw.text((x+75, y+60), desc, fill=GRAY, font=get_font(18))
        
        # LaTeX preview
        if frame > delay + 15:
            formulas = {
                "Derivatives": "f'(x) = 3x² - 2",
                "Slope": "m = f'(a) = 10",
                "Limits": "lim(x→1) = 2",
                "Inequalities": "x² - 4 > 0",
                "Circles": "(x-h)² + (y-k)² = r²",
                "Distance": "d = √((x₂-x₁)² + (y₂-y₁)²)",
            }
            f_text = formulas.get(title, "")
            draw.text((x+75, y+90), f_text, fill=color, font=get_font(16))
    
    # Student pointing at features
    if frame > 30:
        Student.draw(draw, 160, 500, scale=1.3, pose="point", frame=frame)
    
    return img

def make_derivatives_ui(frame=0, alpha=1.0):
    img = Image.new("RGB", (W, H))
    draw = draw_gradient(img, (18, 18, 30), (22, 20, 38))
    
    # Phone frame
    px, py = 300, 30
    pw, ph = 500, 1020
    rounded_rect(draw, (px, py, px+pw, py+ph), 30, SURFACE)
    
    # Status bar
    draw.text((px+20, py+12), "9:41", fill=GRAY, font=get_font(14))
    draw.text((px+pw-60, py+12), "100%", fill=GRAY, font=get_font(14))
    
    # Title
    draw.text((px+50, py+48), "Differentiate", fill=WHITE, font=get_font(26, True))
    draw.text((px+50, py+78), "Enter a function to find its derivative.", fill=GRAY, font=get_font(14))
    
    # Input field with typing animation
    iy = py + 120
    rounded_rect(draw, (px+20, iy, px+pw-20, iy+55), 12, CARD, outline=PRIMARY)
    
    expr = "x³ - 2x + 5"
    chars = min(len(expr), int(frame / 2) + 1) if frame < 30 else len(expr)
    draw.text((px+40, iy+15), expr[:chars], fill=WHITE, font=get_font(22))
    # Cursor blink
    if frame % 20 < 10 and chars < len(expr):
        cursor_x = px + 40 + len(expr[:chars]) * 14
        draw.line([(cursor_x, iy+12), (cursor_x, iy+40)], fill=PRIMARY, width=2)
    
    # Solve button (animated press)
    by = iy + 75
    btn_pressed = 30 <= frame <= 35
    btn_offset = 2 if btn_pressed else 0
    rounded_rect(draw, (px+20, by+btn_offset, px+pw-20, by+50+btn_offset), 12, PRIMARY if not btn_pressed else (100, 40, 200))
    draw.text((px+pw//2, by+25+btn_offset), "Solve", fill=WHITE, font=get_font(20, True), anchor="mm")
    
    # Answer card (appears after solve)
    if frame > 40:
        ay = by + 85
        appear = ease_out(min(1.0, (frame - 40) / 15))
        rounded_rect(draw, (px+20, ay, px+pw-20, ay+80), 12, CARD)
        draw.text((px+40, ay+15), "Answer", fill=GREEN, font=get_font(14, True))
        
        # LaTeX formula with underline
        formula = "f'(x) = 3x² - 2"
        draw.text((px+40, ay+40), formula, fill=WHITE, font=get_font(24, True))
        draw.line([(px+40, ay+70), (px+250, ay+70)], fill=CYAN, width=2)
    
    # Steps (appear one by one)
    if frame > 60:
        sy = by + 185
        draw.text((px+40, sy), "Step-by-Step Solution", fill=WHITE, font=get_font(18, True))
        draw.text((px+40, sy+26), "Understand each rule applied.", fill=GRAY, font=get_font(12))
        
        steps = [
            ("1", "Problem Statement", "f(x) = x³ - 2x + 5", False),
            ("2", "Identify Rule", "Power Rule: d/dx[xⁿ] = n·xⁿ⁻¹", True),
            ("3", "Apply", "f'(x) = 3x² - 2", False),
            ("4", "Final Answer", "f'(x) = 3x² - 2", True),
        ]
        
        step_y = sy + 60
        for i, (num, title, expr_s, is_final) in enumerate(steps):
            step_delay = 70 + i * 10
            if frame < step_delay: continue
            
            progress = min(1.0, (frame - step_delay) / 10)
            slide_x = int(30 * (1 - ease_out(progress)))
            
            cx_c = px + 44 + slide_x
            draw.ellipse([cx_c-12, step_y, cx_c+12, step_y+24], 
                        fill=PRIMARY if is_final else (60, 60, 90))
            draw.text((cx_c, step_y+12), num, fill=WHITE if is_final else PRIMARY, 
                     font=get_font(12, True), anchor="mm")
            
            if num != "4":
                draw.line([(cx_c, step_y+24), (cx_c, step_y+55)], fill=(60, 60, 90), width=2)
            
            draw.text((px+70+slide_x, step_y+2), title, fill=WHITE, font=get_font(14, True))
            rounded_rect(draw, (px+70+slide_x, step_y+24, px+pw-30, step_y+50), 8, CARD2)
            draw.text((px+82+slide_x, step_y+30), expr_s, fill=GRAY, font=get_font(13))
            
            step_y += 62
    
    # Right side explanation
    rx = px + pw + 80
    draw.text((rx, 100), "How It Works", fill=WHITE, font=get_font(32, True))
    
    # Student thinking
    if frame > 20:
        Student.draw(draw, rx + 200, 180, scale=1.2, pose="think", frame=frame)
    
    lines = [
        ("1.", "Enter any math expression", WHITE),
        ("2.", "Tap Solve to compute", WHITE),
        ("3.", "See each step explained", WHITE),
        ("", "", WHITE),
        ("Rules Supported:", "", PRIMARY_L),
        ("• Power Rule: d/dx[xⁿ] = n·xⁿ⁻¹", "", CYAN),
        ("• Product Rule: (fg)' = f'g + fg'", "", CYAN),
        ("• Quotient Rule: (f/g)' = (f'g-fg')/g²", "", CYAN),
        ("• Chain Rule: d/dx[f(g(x))] = f'(g(x))·g'(x)", "", CYAN),
        ("• Trig: sin, cos, tan, csc, sec, cot", "", GREEN),
        ("• Log & Exp: ln(x), eˣ, aˣ", "", GREEN),
    ]
    
    for i, (text, sub, color) in enumerate(lines):
        if frame > 25 + i * 3:
            ly = 320 + i * 32
            draw.text((rx, ly), text, fill=color, font=get_font(19))
    
    return img

def make_slope_ui(frame=0, alpha=1.0):
    img = Image.new("RGB", (W, H))
    draw = draw_gradient(img, (18, 18, 30), (22, 20, 38))
    
    px, py = 300, 30
    pw, ph = 500, 1020
    rounded_rect(draw, (px, py, px+pw, py+ph), 30, SURFACE)
    
    draw.text((px+50, py+48), "Slope Using Derivatives", fill=WHITE, font=get_font(24, True))
    draw.text((px+50, py+76), "Find slope at any point.", fill=GRAY, font=get_font(14))
    
    # Input
    iy = py + 115
    rounded_rect(draw, (px+20, iy, px+pw-20, iy+50), 12, CARD, outline=PRIMARY)
    draw.text((px+40, iy+14), "y = x³ - 2x + 1,  x = 2", fill=WHITE, font=get_font(20))
    
    # Tabs
    tabs = ["Explicit", "Implicit", "Parametric"]
    for i, tab in enumerate(tabs):
        tx = px + 20 + i * 165
        rounded_rect(draw, (tx, iy+65, tx+155, iy+95), 8, PRIMARY if i==0 else CARD)
        draw.text((tx+77, iy+80), tab, fill=WHITE, font=get_font(14, True), anchor="mm")
    
    # Solution with LaTeX formulas
    sy = iy + 120
    steps = [
        ("Given:", "y = x³ - 2x + 1 at x = 2"),
        ("Differentiate:", "y' = 3x² - 2"),
        ("Substitute:", "y' = 3(2)² - 2 = 10"),
        ("Slope:", "m = 10"),
        ("Tangent:", "y = 10x - 19"),
        ("Normal:", "y = -x/10 + 21/5"),
    ]
    
    for i, (label, val) in enumerate(steps):
        step_delay = 15 + i * 8
        if frame < step_delay: continue
        
        progress = min(1.0, (frame - step_delay) / 10)
        slide = int(20 * (1 - ease_out(progress)))
        
        sy_s = sy + i * 68
        cx_c = px + 44 + slide
        is_result = i == 3
        
        draw.ellipse([cx_c-12, sy_s, cx_c+12, sy_s+24], fill=PRIMARY if is_result else (60,60,90))
        draw.text((cx_c, sy_s+12), str(i+1), fill=WHITE if is_result else PRIMARY, font=get_font(12, True), anchor="mm")
        if i < 5:
            draw.line([(cx_c, sy_s+24), (cx_c, sy_s+55)], fill=(60,60,90), width=2)
        
        draw.text((px+70+slide, sy_s+2), label, fill=PRIMARY_L if is_result else WHITE, font=get_font(14, True))
        rounded_rect(draw, (px+70+slide, sy_s+24, px+pw-30, sy_s+50), 8, CARD2)
        draw.text((px+82+slide, sy_s+30), val, fill=GRAY, font=get_font(13))
    
    # Right side: equation types with LaTeX
    rx = px + pw + 60
    draw.text((rx, 80), "Equation Types", fill=WHITE, font=get_font(28, True))
    
    # Student excited
    if frame > 20:
        Student.draw(draw, rx + 380, 130, scale=1.0, pose="excited", frame=frame)
    
    eq_types = [
        ("Explicit", "y = x³ - 2x + 1", CYAN),
        ("Implicit", "x² + y² = 25", GREEN),
        ("Parametric", "x = cos(t), y = sin(t)", YELLOW),
    ]
    
    for i, (name, ex, color) in enumerate(eq_types):
        if frame < 10 + i * 8: continue
        ty = 150 + i * 90
        rounded_rect(draw, (rx, ty, rx+460, ty+70), 10, CARD)
        draw.text((rx+20, ty+8), name, fill=color, font=get_font(18, True))
        draw.text((rx+20, ty+38), ex, fill=GRAY, font=get_font(16))
        draw.line([(rx+20, ty+60), (rx+20+len(ex)*9, ty+60)], fill=color, width=2)
    
    # Output box
    draw.text((rx, 440), "Result", fill=WHITE, font=get_font(28, True))
    rounded_rect(draw, (rx, 490, rx+460, 620), 12, CARD)
    
    out = [("Slope:", "m = 10", CYAN), ("Tangent:", "y = 10x - 19", GREEN), ("Normal:", "y = -x/10 + 21/5", YELLOW)]
    for i, (lbl, val, c) in enumerate(out):
        if frame > 40 + i * 5:
            draw.text((rx+20, 510+i*38), lbl, fill=GRAY, font=get_font(16))
            draw.text((rx+120, 510+i*38), val, fill=c, font=get_font(18, True))
    
    return img

def make_limits_ui(frame=0, alpha=1.0):
    img = Image.new("RGB", (W, H))
    draw = draw_gradient(img, (18, 18, 30), (22, 20, 38))
    
    px, py = 300, 30
    pw, ph = 500, 1020
    rounded_rect(draw, (px, py, px+pw, py+ph), 30, SURFACE)
    
    draw.text((px+50, py+48), "Evaluating Limits", fill=WHITE, font=get_font(24, True))
    draw.text((px+50, py+76), "Solve by substitution, factoring, LCD, or conjugate.", fill=GRAY, font=get_font(14))
    
    # Input
    iy = py + 115
    rounded_rect(draw, (px+20, iy, px+pw-20, iy+50), 12, CARD, outline=PRIMARY)
    draw.text((px+40, iy+14), "lim(x→1) (x²-1)/(x-1)", fill=WHITE, font=get_font(20))
    
    # Method tabs
    tabs = ["Substitution", "Factoring", "LCD", "Conjugate"]
    for i, tab in enumerate(tabs):
        tx = px + 20 + i * 118
        rounded_rect(draw, (tx, iy+65, tx+112, iy+95), 8, PRIMARY if i==1 else CARD)
        draw.text((tx+56, iy+80), tab, fill=WHITE, font=get_font(12, True), anchor="mm")
    
    # Steps
    sy = iy + 120
    steps = [
        ("Method:", "Factoring"),
        ("Factor:", "(x²-1)/(x-1) = (x+1)(x-1)/(x-1)"),
        ("Cancel:", "= x + 1"),
        ("Substitute:", "= 1 + 1 = 2"),
        ("Result:", "lim = 2"),
    ]
    
    for i, (label, val) in enumerate(steps):
        step_delay = 15 + i * 8
        if frame < step_delay: continue
        
        progress = min(1.0, (frame - step_delay) / 10)
        slide = int(20 * (1 - ease_out(progress)))
        
        sy_s = sy + i * 72
        cx_c = px + 44 + slide
        is_result = i == 4
        
        draw.ellipse([cx_c-12, sy_s, cx_c+12, sy_s+24], fill=PRIMARY if is_result else (60,60,90))
        draw.text((cx_c, sy_s+12), str(i+1), fill=WHITE if is_result else PRIMARY, font=get_font(12, True), anchor="mm")
        if i < 4:
            draw.line([(cx_c, sy_s+24), (cx_c, sy_s+55)], fill=(60,60,90), width=2)
        
        draw.text((px+70+slide, sy_s+2), label, fill=PRIMARY_L if is_result else WHITE, font=get_font(14, True))
        rounded_rect(draw, (px+70+slide, sy_s+24, px+pw-30, sy_s+50), 8, CARD2)
        draw.text((px+82+slide, sy_s+30), val, fill=GRAY, font=get_font(13))
    
    # Right side
    rx = px + pw + 60
    draw.text((rx, 80), "Limit Methods", fill=WHITE, font=get_font(28, True))
    
    # Student waving
    if frame > 10:
        Student.draw(draw, rx + 380, 130, scale=1.0, pose="wave", frame=frame)
    
    methods = [
        ("Substitution", "Plug in x = a directly", CYAN),
        ("Factoring", "Factor and cancel common terms", GREEN),
        ("LCD", "Multiply by least common denominator", YELLOW),
        ("Conjugate", "Multiply by conjugate for radicals", ORANGE),
    ]
    
    for i, (name, desc, color) in enumerate(methods):
        if frame < 10 + i * 6: continue
        my = 150 + i * 85
        progress = min(1.0, (frame - 10 - i*6) / 12)
        slide = int(40 * (1 - ease_out(progress)))
        
        rounded_rect(draw, (rx+slide, my, rx+460+slide, my+65), 10, CARD)
        draw.text((rx+20+slide, my+8), name, fill=color, font=get_font(18, True))
        draw.text((rx+20+slide, my+35), desc, fill=GRAY, font=get_font(15))
    
    # Also supports
    if frame > 40:
        draw.text((rx, 520), "Also Supports", fill=WHITE, font=get_font(22, True))
        extras = ["Limits at Infinity", "Rational forms", "Radical forms", "Trigonometric"]
        for i, e in enumerate(extras):
            draw.text((rx+20, 560+i*32), "•  " + e, fill=GRAY, font=get_font(17))
    
    return img

def make_cta(frame=0, alpha=1.0):
    img = Image.new("RGB", (W, H))
    draw = draw_gradient(img)
    
    # Particles
    for i in range(30):
        px = (i * 67 + frame * 3) % W
        py = (i * 41 + frame * 2) % H
        ps = 2 + (i % 4)
        draw.ellipse([px-ps, py-ps, px+ps, py+ps], fill=CYAN)
    
    cx, cy = W//2, H//2
    
    # Title
    draw.text((cx, cy-120), "Try MathCalcu Today", fill=WHITE, font=get_font(56, True), anchor="mm")
    draw.text((cx, cy-40), "All computations run offline  •  No internet required", fill=GRAY, font=get_font(24), anchor="mm")
    
    # Platforms
    platforms = ["Android", "iOS", "Web", "Desktop"]
    bw = 150
    total = len(platforms)*bw + (len(platforms)-1)*20
    sx = cx - total//2
    for i, p in enumerate(platforms):
        if frame > 10 + i * 3:
            progress = min(1.0, (frame - 10 - i*3) / 10)
            bounce = ease_out_bounce(progress)
            y_off = int((1-bounce) * 50)
            x = sx + i*(bw+20)
            rounded_rect(draw, (x, cy+30+y_off, x+bw, cy+75+y_off), 8, PRIMARY)
            draw.text((x+bw//2, cy+52+y_off), p, fill=WHITE, font=get_font(20, True), anchor="mm")
    
    # Student excited at bottom
    Student.draw(draw, cx, cy+160, scale=1.5, pose="excited", frame=frame)
    
    return img

# ═══════════════════════════════════════════════════════
# BUILD VIDEO
# ═══════════════════════════════════════════════════════

def get_audio_dur(path):
    cmd = ["ffprobe", "-v", "quiet", "-print_format", "json", "-show_format", path]
    r = subprocess.run(cmd, capture_output=True, text=True)
    return float(json.loads(r.stdout)["format"]["duration"])

slides_config = [
    ("01_title", make_title),
    ("02_features", make_features),
    ("03_derivatives", make_derivatives_ui),
    ("04_slope", make_slope_ui),
    ("05_limits", make_limits_ui),
    ("06_cta", make_cta),
]

frame_idx = 0
segment_info = []

for slide_name, make_fn in slides_config:
    audio_path = os.path.join(NARRATION_DIR, f"{slide_name}.mp3")
    if not os.path.exists(audio_path):
        alt = slide_name.replace("_cta", "_title")
        audio_path = os.path.join(NARRATION_DIR, f"{alt}.mp3")
    
    dur = get_audio_dur(audio_path) if os.path.exists(audio_path) else 5.0
    total_frames = int((dur + 1.0) * FPS)
    
    print(f"Rendering {slide_name}: {dur:.1f}s ({total_frames} frames)")
    
    for i in range(total_frames):
        frame = make_fn(frame=i, alpha=1.0)
        frame.save(os.path.join(FRAMES_DIR, f"frame_{frame_idx:06d}.png"))
        frame_idx += 1
    
    segment_info.append((slide_name, total_frames))

print(f"\nTotal frames: {frame_idx} ({frame_idx/FPS:.1f}s)")

# Extract segments and mux with audio
print("\nBuilding segments with audio...")
seg_videos = []
offset = 0

for slide_name, n_frames in segment_info:
    audio_path = os.path.join(NARRATION_DIR, f"{slide_name}.mp3")
    if not os.path.exists(audio_path):
        alt = slide_name.replace("_cta", "_title")
        audio_path = os.path.join(NARRATION_DIR, f"{alt}.mp3")
    
    seg_frames_dir = os.path.join(BASE, f"_sf_{slide_name}")
    os.makedirs(seg_frames_dir, exist_ok=True)
    
    for i in range(n_frames):
        src = os.path.join(FRAMES_DIR, f"frame_{offset+i:06d}.png")
        dst = os.path.join(seg_frames_dir, f"frame_{i:06d}.png")
        if os.path.exists(src):
            os.rename(src, dst)
    
    seg_mp4 = os.path.join(BASE, f"_seg_{slide_name}.mp4")
    dur_s = n_frames / FPS
    
    cmd = ["ffmpeg", "-y", "-framerate", str(FPS),
           "-i", os.path.join(seg_frames_dir, "frame_%06d.png")]
    
    if os.path.exists(audio_path):
        cmd += ["-i", audio_path, "-c:v", "libx264", "-t", str(dur_s),
                "-c:a", "aac", "-b:a", "192k", "-shortest"]
    else:
        cmd += ["-c:v", "libx264", "-t", str(dur_s)]
    
    cmd += ["-pix_fmt", "yuv420p", "-r", str(FPS), seg_mp4]
    
    print(f"  {slide_name}: {dur_s:.1f}s")
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode == 0:
        seg_videos.append(seg_mp4)
    else:
        print(f"    ERROR: {r.stderr[-200:]}")
    
    offset += n_frames

# Concat
print("\nConcatenating...")
concat_list = os.path.join(BASE, "_concat.txt")
with open(concat_list, "w") as f:
    for sv in seg_videos:
        f.write(f"file '{sv}'\n")

cmd = ["ffmpeg", "-y", "-f", "concat", "-safe", "0", "-i", concat_list,
       "-c:v", "libx264", "-c:a", "aac", "-b:a", "192k",
       "-pix_fmt", "yuv420p", "-movflags", "+faststart", OUTPUT]
r = subprocess.run(cmd, capture_output=True, text=True)

if r.returncode == 0:
    sz = os.path.getsize(OUTPUT) / (1024*1024)
    print(f"\nDONE! {OUTPUT}")
    print(f"Size: {sz:.1f} MB")
else:
    print(f"Error: {r.stderr[-500:]}")

# Cleanup
for sv in seg_videos:
    if os.path.exists(sv): os.remove(sv)
for slide_name, _ in segment_info:
    d = os.path.join(BASE, f"_sf_{slide_name}")
    if os.path.isdir(d): shutil.rmtree(d)
if os.path.exists(concat_list): os.remove(concat_list)
if os.path.isdir(FRAMES_DIR): shutil.rmtree(FRAMES_DIR)
