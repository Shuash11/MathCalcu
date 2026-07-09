"""Generate tutorial slides for MathCalcu app."""
import os
from PIL import Image, ImageDraw, ImageFont

OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "slides")
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Slide dimensions (1920x1080)
W, H = 1920, 1080

# Colors
BG = (15, 15, 25)
ACCENT = (99, 102, 241)
ACCENT_LIGHT = (139, 92, 246)
WHITE = (255, 255, 255)
GRAY = (160, 160, 170)
GREEN = (34, 197, 94)
DARK_CARD = (30, 30, 50)

def get_font(size, bold=False):
    """Get a font - fallback to default if system fonts unavailable."""
    paths = [
        "C:/Windows/Fonts/segoeui.ttf",
        "C:/Windows/Fonts/segoeuib.ttf" if bold else "C:/Windows/Fonts/segoeui.ttf",
        "C:/Windows/Fonts/arial.ttf",
    ]
    for p in paths:
        if os.path.exists(p):
            try:
                return ImageFont.truetype(p, size)
            except:
                continue
    return ImageFont.load_default()

def draw_rounded_rect(draw, xy, radius, fill):
    """Draw a rounded rectangle."""
    x0, y0, x1, y1 = xy
    draw.rectangle([x0 + radius, y0, x1 - radius, y1], fill=fill)
    draw.rectangle([x0, y0 + radius, x1, y1 - radius], fill=fill)
    draw.pieslice([x0, y0, x0 + 2*radius, y0 + 2*radius], 180, 270, fill=fill)
    draw.pieslice([x1 - 2*radius, y0, x1, y0 + 2*radius], 270, 360, fill=fill)
    draw.pieslice([x0, y1 - 2*radius, x0 + 2*radius, y1], 90, 180, fill=fill)
    draw.pieslice([x1 - 2*radius, y1 - 2*radius, x1, y1], 0, 90, fill=fill)

def draw_gradient_bg(img):
    """Draw a subtle gradient background."""
    draw = ImageDraw.Draw(img)
    for y in range(H):
        r = int(15 + (y / H) * 10)
        g = int(15 + (y / H) * 5)
        b = int(25 + (y / H) * 15)
        draw.line([(0, y), (W, y)], fill=(r, g, b))
    return draw

# ─── Slide 1: Title ───
def slide_title():
    img = Image.new("RGB", (W, H))
    draw = draw_gradient_bg(img)
    
    # App icon circle
    cx, cy = W // 2, H // 2 - 120
    draw.ellipse([cx-60, cy-60, cx+60, cy+60], fill=ACCENT)
    font_icon = get_font(50, bold=True)
    draw.text((cx, cy), "π", fill=WHITE, font=font_icon, anchor="mm")
    
    # Title
    font_title = get_font(72, bold=True)
    draw.text((W//2, cy + 120), "MathCalcu", fill=WHITE, font=font_title, anchor="mm")
    
    # Subtitle
    font_sub = get_font(32)
    draw.text((W//2, cy + 180), "Powered Math System", fill=ACCENT_LIGHT, font=font_sub, anchor="mm")
    
    # Tagline
    font_tag = get_font(24)
    draw.text((W//2, cy + 240), "Calculus & Analytic Geometry  •  Step-by-Step Solutions  •  Offline", 
              fill=GRAY, font=font_tag, anchor="mm")
    
    img.save(os.path.join(OUTPUT_DIR, "01_title.png"))

# ─── Slide 2: Features Overview ───
def slide_features():
    img = Image.new("RGB", (W, H))
    draw = draw_gradient_bg(img)
    
    font_title = get_font(48, bold=True)
    draw.text((W//2, 80), "Features", fill=WHITE, font=font_title, anchor="mm")
    
    features = [
        ("Derivatives", "Symbolic differentiation with\nstep-by-step solutions", "d/dx"),
        ("Slope", "Find slope at a point for\nexplicit, implicit, parametric", "m = f'(a)"),
        ("Limits", "By substitution, factoring,\nLCD, and conjugate", "lim"),
        ("Inequalities", "Linear, quadratic, rational,\nradical, absolute value", "≥ ≤"),
        ("Circles", "Center, radius, standard\nand general form", "⊙"),
        ("Distance", "Distance & midpoint\nwith graphing support", "d = √Δ²"),
    ]
    
    card_w, card_h = 520, 200
    cols = 3
    start_x = (W - cols * (card_w + 30) + 30) // 2
    start_y = 160
    
    for i, (title, desc, icon) in enumerate(features):
        col = i % cols
        row = i // cols
        x = start_x + col * (card_w + 30)
        y = start_y + row * (card_h + 30)
        
        draw_rounded_rect(draw, (x, y, x+card_w, y+card_h), 12, DARK_CARD)
        
        # Icon
        draw.ellipse([x+20, y+20, x+70, y+70], fill=ACCENT)
        font_icon = get_font(24, bold=True)
        draw.text((x+45, y+45), icon, fill=WHITE, font=font_icon, anchor="mm")
        
        # Title
        font_feat = get_font(28, bold=True)
        draw.text((x+90, y+30), title, fill=WHITE, font=font_feat)
        
        # Description
        font_desc = get_font(20)
        for j, line in enumerate(desc.split("\n")):
            draw.text((x+90, y+75 + j*28), line, fill=GRAY, font=font_desc)
    
    img.save(os.path.join(OUTPUT_DIR, "02_features.png"))

# ─── Slide 3: Derivatives Demo ───
def slide_derivatives():
    img = Image.new("RGB", (W, H))
    draw = draw_gradient_bg(img)
    
    font_title = get_font(44, bold=True)
    draw.text((W//2, 60), "Derivatives — Step by Step", fill=WHITE, font=font_title, anchor="mm")
    
    # Example card
    draw_rounded_rect(draw, (100, 130, W-100, H-80), 16, DARK_CARD)
    
    font_label = get_font(22, bold=True)
    font_math = get_font(28)
    font_step = get_font(24)
    
    y = 170
    draw.text((140, y), "Input:", fill=ACCENT_LIGHT, font=font_label)
    draw.text((140, y+35), "f(x) = x³ - 2x + 5", fill=WHITE, font=font_math)
    
    y += 100
    draw.text((140, y), "Step 1: Problem Statement", fill=GREEN, font=font_label)
    draw.text((140, y+30), "f(x) = x³ - 2x + 5", fill=GRAY, font=font_step)
    
    y += 80
    draw.text((140, y), "Step 2: Identify the Rule", fill=GREEN, font=font_label)
    draw.text((140, y+30), "Power Rule: d/dx[xⁿ] = n·xⁿ⁻¹", fill=GRAY, font=font_step)
    
    y += 80
    draw.text((140, y), "Step 3: Apply Differentiation", fill=GREEN, font=font_label)
    draw.text((140, y+30), "f'(x) = 3x² - 2", fill=WHITE, font=font_math)
    
    y += 80
    draw.text((140, y), "Step 4: Final Answer", fill=GREEN, font=font_label)
    draw.text((140, y+30), "f'(x) = 3x² - 2", fill=ACCENT_LIGHT, font=font_math)
    
    # Side note
    y += 120
    draw.text((140, y), "Supports: Power, Product, Quotient, Chain, Trig, Log, Exp, Hyperbolic", 
              fill=GRAY, font=get_font(20))
    
    img.save(os.path.join(OUTPUT_DIR, "03_derivatives.png"))

# ─── Slide 4: Slope Using Derivatives ───
def slide_slope():
    img = Image.new("RGB", (W, H))
    draw = draw_gradient_bg(img)
    
    font_title = get_font(44, bold=True)
    draw.text((W//2, 60), "Slope Using Derivatives", fill=WHITE, font=font_title, anchor="mm")
    
    draw_rounded_rect(draw, (100, 130, W-100, H-80), 16, DARK_CARD)
    
    font_label = get_font(22, bold=True)
    font_math = get_font(26)
    font_step = get_font(22)
    
    y = 170
    draw.text((140, y), "Input Types:", fill=ACCENT_LIGHT, font=font_label)
    
    y += 40
    for t in ["Explicit:   y = x³ - 2x + 1,  x = 2", 
              "Implicit:   x² + y² = 25,  x = 3",
              "Parametric: x = cos(t),  y = sin(t),  t = 1.5708"]:
        draw.text((160, y), t, fill=GRAY, font=font_step)
        y += 32
    
    y += 30
    draw.text((140, y), "Example: y = x³ - 2x + 1 at x = 2", fill=WHITE, font=font_math)
    
    y += 50
    draw.text((140, y), "Step 1: Differentiate", fill=GREEN, font=font_label)
    draw.text((140, y+30), "y' = 3x² - 2", fill=GRAY, font=font_step)
    
    y += 70
    draw.text((140, y), "Step 2: Substitute x = 2", fill=GREEN, font=font_label)
    draw.text((140, y+30), "y' = 3(2)² - 2 = 10", fill=GRAY, font=font_step)
    
    y += 70
    draw.text((140, y), "Result:", fill=GREEN, font=font_label)
    draw.text((140, y+30), "Slope = 10  |  Tangent: y = 10x - 19  |  Normal: y = -x/10 + 21/5", 
              fill=ACCENT_LIGHT, font=font_step)
    
    img.save(os.path.join(OUTPUT_DIR, "04_slope.png"))

# ─── Slide 5: Limits ───
def slide_limits():
    img = Image.new("RGB", (W, H))
    draw = draw_gradient_bg(img)
    
    font_title = get_font(44, bold=True)
    draw.text((W//2, 60), "Evaluating Limits", fill=WHITE, font=font_title, anchor="mm")
    
    draw_rounded_rect(draw, (100, 130, W-100, H-80), 16, DARK_CARD)
    
    font_label = get_font(22, bold=True)
    font_math = get_font(26)
    font_step = get_font(22)
    
    methods = [
        ("By Substitution", "Plug in x = a directly", "lim(x→2) (x²+1) = 5"),
        ("By Factoring", "Factor and cancel common terms", "lim(x→1) (x²-1)/(x-1) = 2"),
        ("By LCD", "Multiply by least common denominator", "Rational expressions"),
        ("By Conjugate", "Multiply by conjugate for radicals", "lim(x→0) (√(x+1)-1)/x = 1/2"),
    ]
    
    y = 160
    for name, desc, ex in methods:
        draw.text((140, y), name, fill=ACCENT_LIGHT, font=font_label)
        draw.text((400, y), desc, fill=GRAY, font=font_step)
        draw.text((900, y), ex, fill=WHITE, font=font_step)
        y += 55
    
    y += 30
    draw.text((140, y), "Also supports: Limits at Infinity (rational, radical, trigonometric)", 
              fill=GRAY, font=get_font(20))
    
    img.save(os.path.join(OUTPUT_DIR, "05_limits.png"))

# ─── Slide 6: More Features ───
def slide_more():
    img = Image.new("RGB", (W, H))
    draw = draw_gradient_bg(img)
    
    font_title = get_font(44, bold=True)
    draw.text((W//2, 60), "And More...", fill=WHITE, font=font_title, anchor="mm")
    
    items = [
        ("Inequalities", "Solve linear, quadratic, rational, radical, and absolute value inequalities with number line visualization"),
        ("Circles", "Find center, radius, convert between standard and general form: (x-h)² + (y-k)² = r²"),
        ("Distance & Midpoint", "Calculate distance between two points and find midpoints with optional graphing"),
        ("Slope & Intercept", "Point-slope form, two-point form, parallel and perpendicular line equations"),
    ]
    
    font_item = get_font(28, bold=True)
    font_desc = get_font(22)
    
    y = 150
    for title, desc in items:
        draw_rounded_rect(draw, (100, y, W-100, y+140), 12, DARK_CARD)
        draw.text((140, y+20), title, fill=ACCENT_LIGHT, font=font_item)
        
        # Word wrap description
        words = desc.split()
        line = ""
        ly = y + 65
        for word in words:
            test = line + " " + word if line else word
            if len(test) > 80:
                draw.text((140, ly), line, fill=GRAY, font=font_desc)
                ly += 28
                line = word
            else:
                line = test
        if line:
            draw.text((140, ly), line, fill=GRAY, font=font_desc)
        
        y += 170
    
    img.save(os.path.join(OUTPUT_DIR, "06_more.png"))

# ─── Slide 7: CTA ───
def slide_cta():
    img = Image.new("RGB", (W, H))
    draw = draw_gradient_bg(img)
    
    cx, cy = W // 2, H // 2
    
    font_title = get_font(56, bold=True)
    draw.text((cx, cy - 80), "Try MathCalcu Today", fill=WHITE, font=font_title, anchor="mm")
    
    font_sub = get_font(28)
    draw.text((cx, cy), "All computations run offline  •  No internet required", fill=GRAY, font=font_sub, anchor="mm")
    
    # Platform badges
    platforms = ["Android", "iOS", "Web", "Desktop"]
    font_plat = get_font(22, bold=True)
    badge_w = 160
    total_w = len(platforms) * badge_w + (len(platforms)-1) * 20
    sx = (cx - total_w // 2)
    
    for i, p in enumerate(platforms):
        x = sx + i * (badge_w + 20)
        draw_rounded_rect(draw, (x, cy+60, x+badge_w, cy+110), 8, ACCENT)
        draw.text((x + badge_w//2, cy+85), p, fill=WHITE, font=font_plat, anchor="mm")
    
    font_link = get_font(24)
    draw.text((cx, cy+160), "github.com/your-repo/mathcalcu", fill=ACCENT_LIGHT, font=font_link, anchor="mm")
    
    img.save(os.path.join(OUTPUT_DIR, "07_cta.png"))

if __name__ == "__main__":
    slide_title()
    slide_features()
    slide_derivatives()
    slide_slope()
    slide_limits()
    slide_more()
    slide_cta()
    print(f"Generated 7 slides in {OUTPUT_DIR}")
