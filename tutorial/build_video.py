"""Generate animated tutorial video for MathCalcu with realistic UI mockups."""
import os
import subprocess
import json
import math
from PIL import Image, ImageDraw, ImageFont

BASE = os.path.dirname(__file__)
FRAMES_DIR = os.path.join(BASE, "frames")
NARRATION_DIR = os.path.join(BASE, "narration")
OUTPUT = os.path.join(BASE, "mathcalcu_tutorial.mp4")
os.makedirs(FRAMES_DIR, exist_ok=True)

W, H = 1920, 1080
FPS = 30

# ── Colors (matching MathCalcu theme) ──
BG = (18, 18, 30)
SURFACE = (25, 25, 42)
CARD = (32, 32, 55)
CARDSecondary = (40, 40, 65)
PRIMARY = (124, 58, 237)
PRIMARY_LIGHT = (167, 139, 250)
GREEN = (34, 197, 94)
RED = (239, 68, 68)
WHITE = (255, 255, 255)
GRAY = (148, 163, 184)
DARK_GRAY = (100, 116, 139)

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
        r = int(c1[0] * (1-t) + c2[0] * t)
        g = int(c1[1] * (1-t) + c2[1] * t)
        b = int(c1[2] * (1-t) + c2[2] * t)
        draw.line([(0, y), (W, y)], fill=(r, g, b))
    return draw

def rounded_rect(draw, xy, r, fill, outline=None):
    x0, y0, x1, y1 = xy
    draw.rectangle([x0+r, y0, x1-r, y1], fill=fill)
    draw.rectangle([x0, y0+r, x1, y1-r], fill=fill)
    draw.pieslice([x0, y0, x0+2*r, y0+2*r], 180, 270, fill=fill)
    draw.pieslice([x1-2*r, y0, x1, y0+2*r], 270, 360, fill=fill)
    draw.pieslice([x0, y1-2*r, x0+2*r, y1], 90, 180, fill=fill)
    draw.pieslice([x1-2*r, y1-2*r, x1, y1], 0, 90, fill=fill)
    if outline:
        draw.rounded_rectangle(xy, r, outline=outline, width=2)

def ease_out_cubic(t): return 1 - (1 - t) ** 3
def ease_in_out(t):
    if t < 0.5: return 4 * t ** 3
    return 1 - (-2 * t + 2) ** 3 / 2

def lerp(a, b, t): return int(a + (b - a) * t)

def fade_transition(frames_dir, prefix, make_frame, total_frames, *args):
    """Generate frames for a slide with fade-in and hold."""
    for i in range(total_frames):
        img = Image.new("RGB", (W, H))
        if i < 15:  # Fade in
            alpha = ease_out_cubic(i / 15)
            frame = make_frame(*args, alpha=alpha)
            img.paste(frame)
        elif i >= total_frames - 15:  # Fade out
            alpha = ease_out_cubic((total_frames - i) / 15)
            frame = make_frame(*args, alpha=alpha)
            img.paste(frame)
        else:
            img = make_frame(*args, alpha=1.0)
        img.save(os.path.join(frames_dir, f"{prefix}_{i:04d}.png"))

# ═══════════════════════════════════════════════════════
# SLIDE FRAMES
# ═══════════════════════════════════════════════════════

def make_title(alpha=1.0):
    img = Image.new("RGB", (W, H))
    draw = draw_gradient(img)
    
    # App icon
    cx, cy = W//2, H//2 - 140
    draw.ellipse([cx-55, cy-55, cx+55, cy+55], fill=PRIMARY)
    f = get_font(48, True)
    draw.text((cx, cy), "π", fill=WHITE, font=f, anchor="mm")
    
    # Title
    f_title = get_font(68, True)
    draw.text((W//2, cy+130), "MathCalcu", fill=WHITE, font=f_title, anchor="mm")
    
    # Subtitle
    f_sub = get_font(28)
    draw.text((W//2, cy+190), "Powered Math System", fill=PRIMARY_LIGHT, font=f_sub, anchor="mm")
    
    f_tag = get_font(22)
    draw.text((W//2, cy+250), "Calculus  •  Analytic Geometry  •  Step-by-Step  •  Offline", 
              fill=GRAY, font=f_tag, anchor="mm")
    
    return img

def make_features(alpha=1.0):
    img = Image.new("RGB", (W, H))
    draw = draw_gradient(img)
    
    f_title = get_font(44, True)
    draw.text((W//2, 70), "Features Overview", fill=WHITE, font=f_title, anchor="mm")
    
    features = [
        ("Derivatives", "Symbolic differentiation\nwith step-by-step", "d/dx"),
        ("Slope", "Find slope at any point\nexplicit, implicit, parametric", "m=f'(a)"),
        ("Limits", "Substitution, factoring,\nLCD, conjugate", "lim"),
        ("Inequalities", "Linear, quadratic, rational,\nradical, absolute value", "≥ ≤"),
        ("Circles", "Center, radius, standard\nand general form", "⊙"),
        ("Distance", "Distance & midpoint\nwith graphing", "d=√Δ²"),
    ]
    
    cw, ch = 500, 180
    cols = 3
    sx = (W - cols*(cw+40)+40)//2
    sy = 150
    
    for i, (title, desc, icon) in enumerate(features):
        col, row = i % cols, i // cols
        x = sx + col*(cw+40)
        y = sy + row*(ch+35)
        
        # Slide-in animation
        if alpha < 1.0:
            offset = int(60 * (1 - alpha))
            x += offset
        
        rounded_rect(draw, (x, y, x+cw, y+ch), 14, CARD)
        draw.ellipse([x+18, y+18, x+62, y+62], fill=PRIMARY)
        fi = get_font(20, True)
        draw.text((x+40, y+40), icon, fill=WHITE, font=fi, anchor="mm")
        
        ft = get_font(26, True)
        draw.text((x+80, y+28), title, fill=WHITE, font=ft)
        
        fd = get_font(19)
        for j, line in enumerate(desc.split("\n")):
            draw.text((x+80, y+70+j*26), line, fill=GRAY, font=fd)
    
    return img

def make_derivatives_ui(alpha=1.0):
    """Realistic mockup of the Derivatives screen."""
    img = Image.new("RGB", (W, H))
    draw = draw_gradient(img, (18, 18, 30), (22, 20, 38))
    
    # Phone frame
    px, py = 340, 40
    pw, ph = 560, 1000
    rounded_rect(draw, (px, py, px+pw, py+ph), 30, SURFACE)
    
    # Status bar
    f_sm = get_font(14)
    draw.text((px+20, py+12), "9:41", fill=GRAY, font=f_sm)
    draw.text((px+pw-60, py+12), "100%", fill=GRAY, font=f_sm)
    
    # Back arrow
    f_arrow = get_font(20, True)
    draw.text((px+20, py+50), "←", fill=PRIMARY, font=f_arrow)
    
    # Title
    f_title = get_font(26, True)
    draw.text((px+50, py+48), "Differentiate", fill=WHITE, font=f_title)
    f_sub = get_font(14)
    draw.text((px+50, py+80), "Enter a function to find its derivative step-by-step.", fill=GRAY, font=f_sub)
    
    # Input field
    iy = py + 120
    rounded_rect(draw, (px+20, iy, px+pw-20, iy+55), 12, CARD, outline=PRIMARY)
    f_input = get_font(22)
    draw.text((px+40, iy+15), "x³ - 2x + 5", fill=WHITE, font=f_input)
    
    # Solve button
    by = iy + 75
    rounded_rect(draw, (px+20, by, px+pw-20, by+50), 12, PRIMARY)
    f_btn = get_font(20, True)
    draw.text((px+pw//2, by+25), "Solve", fill=WHITE, font=f_btn, anchor="mm")
    
    # Answer card
    ay = by + 80
    rounded_rect(draw, (px+20, ay, px+pw-20, ay+80), 12, CARD)
    draw.text((px+40, ay+15), "Answer", fill=PRIMARY_LIGHT, font=get_font(14, True))
    draw.text((px+40, ay+40), "f'(x) = 3x² - 2", fill=WHITE, font=get_font(24, True))
    
    # Step-by-step
    sy = ay + 110
    draw.text((px+40, sy), "Step-by-Step Solution", fill=WHITE, font=get_font(18, True))
    draw.text((px+40, sy+28), "Understand the rules applied to reach the answer.", fill=GRAY, font=get_font(12))
    
    steps = [
        ("1", "Problem Statement", "f(x) = x³ - 2x + 5", False),
        ("2", "Identify the Rule", "Power Rule: d/dx[xⁿ] = n·xⁿ⁻¹", True),
        ("3", "Apply Differentiation", "f'(x) = 3x² - 2", False),
        ("4", "Final Answer", "f'(x) = 3x² - 2", True),
    ]
    
    step_y = sy + 65
    for num, title, expr, is_final in steps:
        # Timeline circle
        cx_circ = px + 44
        draw.ellipse([cx_circ-12, step_y, cx_circ+12, step_y+24], 
                     fill=PRIMARY if is_final else (60, 60, 90))
        f_num = get_font(12, True)
        draw.text((cx_circ, step_y+12), num, fill=WHITE if is_final else PRIMARY, font=f_num, anchor="mm")
        
        # Timeline line
        if num != "4":
            draw.line([(cx_circ, step_y+24), (cx_circ, step_y+55)], fill=(60, 60, 90), width=2)
        
        # Step content
        draw.text((px+70, step_y+2), title, fill=WHITE, font=get_font(14, True))
        rounded_rect(draw, (px+70, step_y+24, px+pw-30, step_y+50), 8, CARDSecondary)
        draw.text((px+82, step_y+30), expr, fill=GRAY, font=get_font(13))
        
        step_y += 65
    
    # Right side: explanation text
    rx = px + pw + 80
    ry = 120
    f_explain = get_font(28, True)
    draw.text((rx, ry), "How It Works", fill=WHITE, font=f_explain)
    
    lines = [
        "1. Enter any math expression",
        "2. Tap Solve to compute",
        "3. See each differentiation step",
        "4. Learn the rules applied",
        "",
        "Supports:",
        "• Power, Product, Quotient, Chain rules",
        "• All 6 trig functions",
        "• Logarithmic & exponential",
        "• Inverse trig & hyperbolic",
    ]
    f_lines = get_font(22)
    for i, line in enumerate(lines):
        c = PRIMARY_LIGHT if line.startswith("•") else WHITE if line.startswith("Supports") else GRAY
        if line == "":
            continue
        draw.text((rx, ry + 60 + i*38), line, fill=c, font=f_lines)
    
    return img

def make_slope_ui(alpha=1.0):
    """Realistic mockup of the Slope screen."""
    img = Image.new("RGB", (W, H))
    draw = draw_gradient(img, (18, 18, 30), (22, 20, 38))
    
    px, py = 340, 40
    pw, ph = 560, 1000
    rounded_rect(draw, (px, py, px+pw, py+ph), 30, SURFACE)
    
    f_title = get_font(26, True)
    draw.text((px+50, py+48), "Slope Using Derivatives", fill=WHITE, font=f_title)
    f_sub = get_font(14)
    draw.text((px+50, py+80), "Find slope at a point for any equation type.", fill=GRAY, font=f_sub)
    
    # Input
    iy = py + 120
    rounded_rect(draw, (px+20, iy, px+pw-20, iy+55), 12, CARD, outline=PRIMARY)
    draw.text((px+40, iy+15), "y = x³ - 2x + 1,  x = 2", fill=WHITE, font=get_font(22))
    
    # Tabs
    tabs = ["Explicit", "Implicit", "Parametric"]
    tab_w = 160
    tab_sx = px + 20
    for i, tab in enumerate(tabs):
        tx = tab_sx + i * (tab_w + 10)
        color = PRIMARY if i == 0 else CARD
        rounded_rect(draw, (tx, iy+70, tx+tab_w, iy+105), 8, color)
        draw.text((tx+tab_w//2, iy+87), tab, fill=WHITE, font=get_font(16, True), anchor="mm")
    
    # Solution steps
    sy = iy + 140
    steps = [
        ("Given", "y = x³ - 2x + 1 at x = 2"),
        ("Differentiate", "y' = 3x² - 2"),
        ("Substitute", "y' = 3(2)² - 2 = 10"),
        ("Slope", "m = 10"),
        ("Tangent Line", "y = 10x - 19"),
        ("Normal Line", "y = -x/10 + 21/5"),
    ]
    
    for i, (label, val) in enumerate(steps):
        sy_step = sy + i * 70
        cx_circ = px + 44
        draw.ellipse([cx_circ-12, sy_step, cx_circ+12, sy_step+24], fill=PRIMARY if i==3 else (60, 60, 90))
        draw.text((cx_circ, sy_step+12), str(i+1), fill=WHITE, font=get_font(12, True), anchor="mm")
        if i < len(steps)-1:
            draw.line([(cx_circ, sy_step+24), (cx_circ, sy_step+55)], fill=(60, 60, 90), width=2)
        
        draw.text((px+70, sy_step+2), label, fill=WHITE, font=get_font(14, True))
        rounded_rect(draw, (px+70, sy_step+24, px+pw-30, sy_step+50), 8, CARDSecondary)
        draw.text((px+82, sy_step+30), val, fill=GRAY, font=get_font(13))
    
    # Right side
    rx = px + pw + 80
    draw.text((rx, 120), "Equation Types", fill=WHITE, font=get_font(28, True))
    
    types = [
        ("Explicit", "y = x³ - 2x + 1"),
        ("Implicit", "x² + y² = 25"),
        ("Parametric", "x = cos(t), y = sin(t)"),
    ]
    for i, (name, ex) in enumerate(types):
        ty = 200 + i * 80
        rounded_rect(draw, (rx, ty, rx+480, ty+60), 10, CARD)
        draw.text((rx+20, ty+8), name, fill=PRIMARY_LIGHT, font=get_font(18, True))
        draw.text((rx+20, ty+34), ex, fill=GRAY, font=get_font(16))
    
    draw.text((rx, 480), "Output", fill=WHITE, font=get_font(28, True))
    rounded_rect(draw, (rx, 540, rx+480, 680), 12, CARD)
    out_lines = [
        "Slope:  m = 10",
        "Tangent:  y = 10x - 19",
        "Normal:  y = -x/10 + 21/5",
    ]
    for i, line in enumerate(out_lines):
        draw.text((rx+20, 560+i*42), line, fill=WHITE if i==0 else GRAY, font=get_font(20, True if i==0 else False))
    
    return img

def make_limits_ui(alpha=1.0):
    """Realistic mockup of the Limits screen."""
    img = Image.new("RGB", (W, H))
    draw = draw_gradient(img, (18, 18, 30), (22, 20, 38))
    
    px, py = 340, 40
    pw, ph = 560, 1000
    rounded_rect(draw, (px, py, px+pw, py+ph), 30, SURFACE)
    
    f_title = get_font(26, True)
    draw.text((px+50, py+48), "Evaluating Limits", fill=WHITE, font=f_title)
    f_sub = get_font(14)
    draw.text((px+50, py+80), "Solve limits by substitution, factoring, LCD, or conjugate.", fill=GRAY, font=f_sub)
    
    # Input
    iy = py + 120
    rounded_rect(draw, (px+20, iy, px+pw-20, iy+55), 12, CARD, outline=PRIMARY)
    draw.text((px+40, iy+15), "lim(x→1) (x²-1)/(x-1)", fill=WHITE, font=get_font(22))
    
    # Method tabs
    tabs = ["Substitution", "Factoring", "LCD", "Conjugate"]
    tab_sx = px + 20
    tab_w = 120
    for i, tab in enumerate(tabs):
        tx = tab_sx + i * (tab_w + 8)
        color = PRIMARY if i == 1 else CARD
        rounded_rect(draw, (tx, iy+70, tx+tab_w, iy+100), 8, color)
        draw.text((tx+tab_w//2, iy+85), tab, fill=WHITE, font=get_font(13, True), anchor="mm")
    
    # Steps
    sy = iy + 130
    steps = [
        ("Method", "Factoring"),
        ("Factor", "(x²-1)/(x-1) = (x+1)(x-1)/(x-1)"),
        ("Cancel", "= x + 1"),
        ("Substitute", "= 1 + 1 = 2"),
        ("Result", "lim = 2"),
    ]
    
    for i, (label, val) in enumerate(steps):
        sy_step = sy + i * 75
        cx_circ = px + 44
        draw.ellipse([cx_circ-12, sy_step, cx_circ+12, sy_step+24], fill=PRIMARY if i==4 else (60, 60, 90))
        draw.text((cx_circ, sy_step+12), str(i+1), fill=WHITE, font=get_font(12, True), anchor="mm")
        if i < len(steps)-1:
            draw.line([(cx_circ, sy_step+24), (cx_circ, sy_step+55)], fill=(60, 60, 90), width=2)
        
        draw.text((px+70, sy_step+2), label, fill=WHITE, font=get_font(14, True))
        rounded_rect(draw, (px+70, sy_step+24, px+pw-30, sy_step+50), 8, CARDSecondary)
        draw.text((px+82, sy_step+30), val, fill=GRAY, font=get_font(13))
    
    # Right side
    rx = px + pw + 80
    draw.text((rx, 120), "Limit Methods", fill=WHITE, font=get_font(28, True))
    
    methods = [
        ("Substitution", "Plug in x = a directly"),
        ("Factoring", "Factor and cancel common terms"),
        ("LCD", "Multiply by least common denominator"),
        ("Conjugate", "Multiply by conjugate for radicals"),
    ]
    for i, (name, desc) in enumerate(methods):
        my = 200 + i * 90
        rounded_rect(draw, (rx, my, rx+480, my+70), 10, CARD)
        draw.text((rx+20, my+10), name, fill=PRIMARY_LIGHT, font=get_font(18, True))
        draw.text((rx+20, my+38), desc, fill=GRAY, font=get_font(15))
    
    draw.text((rx, 600), "Also Supports", fill=WHITE, font=get_font(24, True))
    extras = ["Limits at Infinity", "Rational forms", "Radical forms", "Trigonometric forms"]
    for i, e in enumerate(extras):
        draw.text((rx+20, 650+i*35), "•  " + e, fill=GRAY, font=get_font(18))
    
    return img

def make_cta(alpha=1.0):
    img = Image.new("RGB", (W, H))
    draw = draw_gradient(img)
    
    cx, cy = W//2, H//2
    
    f_title = get_font(56, True)
    draw.text((cx, cy-100), "Try MathCalcu Today", fill=WHITE, font=f_title, anchor="mm")
    
    f_sub = get_font(26)
    draw.text((cx, cy-20), "All computations run offline  •  No internet required", fill=GRAY, font=f_sub, anchor="mm")
    
    platforms = ["Android", "iOS", "Web", "Desktop"]
    f_plat = get_font(20, True)
    bw = 150
    total = len(platforms)*bw + (len(platforms)-1)*20
    sx = cx - total//2
    for i, p in enumerate(platforms):
        x = sx + i*(bw+20)
        rounded_rect(draw, (x, cy+50, x+bw, cy+95), 8, PRIMARY)
        draw.text((x+bw//2, cy+72), p, fill=WHITE, font=f_plat, anchor="mm")
    
    f_link = get_font(22)
    draw.text((cx, cy+140), "github.com/mathcalcu", fill=PRIMARY_LIGHT, font=f_link, anchor="mm")
    
    return img

# ═══════════════════════════════════════════════════════
# GENERATE ALL FRAMES
# ═══════════════════════════════════════════════════════

def get_audio_dur(path):
    cmd = ["ffprobe", "-v", "quiet", "-print_format", "json", "-show_format", path]
    r = subprocess.run(cmd, capture_output=True, text=True)
    return float(json.loads(r.stdout)["format"]["duration"])

slides_config = [
    ("01_title", make_title, 1.0),
    ("02_features", make_features, 1.0),
    ("03_derivatives", make_derivatives_ui, 1.0),
    ("04_slope", make_slope_ui, 1.0),
    ("05_limits", make_limits_ui, 1.0),
    ("06_cta", make_cta, 1.0),
]

frame_idx = 0
segment_info = []

for slide_name, make_fn, _ in slides_config:
    audio_path = os.path.join(NARRATION_DIR, f"{slide_name}.mp3")
    if not os.path.exists(audio_path):
        # Try alternative naming
        alt = slide_name.replace("_cta", "_title")
        audio_path = os.path.join(NARRATION_DIR, f"{alt}.mp3")
    
    if os.path.exists(audio_path):
        dur = get_audio_dur(audio_path)
    else:
        dur = 5.0
    
    total_frames = int((dur + 0.8) * FPS)
    fade_in = 20
    fade_out = 20
    
    print(f"Rendering {slide_name}: {dur:.1f}s ({total_frames} frames)")
    
    for i in range(total_frames):
        # Calculate alpha for fade
        if i < fade_in:
            a = ease_out_cubic(i / fade_in)
        elif i >= total_frames - fade_out:
            a = ease_out_cubic((total_frames - i) / fade_out)
        else:
            a = 1.0
        
        frame = make_fn(alpha=a)
        
        # Apply alpha blending with black background for fade
        if a < 1.0:
            black = Image.new("RGB", (W, H), (0, 0, 0))
            frame = Image.blend(black, frame, a)
        
        frame.save(os.path.join(FRAMES_DIR, f"frame_{frame_idx:06d}.png"))
        frame_idx += 1
    
    segment_info.append((slide_name, total_frames))

print(f"\nTotal frames: {frame_idx}")
print(f"Estimated duration: {frame_idx/FPS:.1f}s")

# Compose video with ffmpeg
print("\nComposing video with ffmpeg...")
concat_file = os.path.join(BASE, "frames_concat.txt")
with open(concat_file, "w") as f:
    f.write(f"file '{FRAMES_DIR.replace(chr(92), '/')}/'\n")

cmd = [
    "ffmpeg", "-y",
    "-framerate", str(FPS),
    "-i", os.path.join(FRAMES_DIR, "frame_%06d.png"),
    "-c:v", "libx264",
    "-pix_fmt", "yuv420p",
    "-preset", "medium",
    "-crf", "20",
    os.path.join(BASE, "video_only.mp4")
]
r = subprocess.run(cmd, capture_output=True, text=True)
if r.returncode != 0:
    print(f"Video encode error: {r.stderr[-500:]}")
else:
    print("Video track done.")

# Now mux with audio
print("Muxing audio...")
# Create silent audio of same length, then overlay narration clips
# Simple approach: just use the concat method with audio

# Build per-segment videos with audio, then concat
seg_files = []
for slide_name, n_frames in segment_info:
    audio_path = os.path.join(NARRATION_DIR, f"{slide_name}.mp3")
    if not os.path.exists(audio_path):
        alt = slide_name.replace("_cta", "_title")
        audio_path = os.path.join(NARRATION_DIR, f"{alt}.mp3")
    
    seg_mp4 = os.path.join(BASE, f"_seg_{slide_name}.mp4")
    
    # Find the frame range for this segment
    start_frame = sum(n for _, n in segment_info[:segment_info.index((slide_name, n_frames))])
    
    # Create video from frames + audio
    cmd = [
        "ffmpeg", "-y",
        "-framerate", str(FPS),
        "-i", os.path.join(FRAMES_DIR, "frame_%06d.png"),
        "-ss", str(start_frame / FPS),
        "-t", str(n_frames / FPS),
    ]
    
    if os.path.exists(audio_path):
        cmd += ["-i", audio_path]
        cmd += ["-c:v", "libx264", "-c:a", "aac", "-b:a", "192k", "-shortest"]
    else:
        cmd += ["-c:v", "libx264"]
    
    cmd += ["-pix_fmt", "yuv420p", "-r", str(FPS), seg_mp4]
    
    # This approach won't work well with frame-based input + offset
    # Instead, extract frames for this segment first
    pass

# Better approach: extract per-segment frame ranges
print("Extracting per-segment frames...")
seg_videos = []
offset = 0
for slide_name, n_frames in segment_info:
    audio_path = os.path.join(NARRATION_DIR, f"{slide_name}.mp3")
    if not os.path.exists(audio_path):
        alt = slide_name.replace("_cta", "_title")
        audio_path = os.path.join(NARRATION_DIR, f"{alt}.mp3")
    
    seg_frames_dir = os.path.join(BASE, f"_segframes_{slide_name}")
    os.makedirs(seg_frames_dir, exist_ok=True)
    
    # Copy frames for this segment
    for i in range(n_frames):
        src = os.path.join(FRAMES_DIR, f"frame_{offset+i:06d}.png")
        dst = os.path.join(seg_frames_dir, f"frame_{i:06d}.png")
        if os.path.exists(src):
            os.rename(src, dst)
    
    seg_mp4 = os.path.join(BASE, f"_seg_{slide_name}.mp4")
    dur_s = n_frames / FPS
    
    cmd = [
        "ffmpeg", "-y",
        "-framerate", str(FPS),
        "-i", os.path.join(seg_frames_dir, "frame_%06d.png"),
    ]
    
    if os.path.exists(audio_path):
        cmd += ["-i", audio_path,
                "-c:v", "libx264", "-t", str(dur_s),
                "-c:a", "aac", "-b:a", "192k", "-shortest"]
    else:
        cmd += ["-c:v", "libx264", "-t", str(dur_s)]
    
    cmd += ["-pix_fmt", "yuv420p", "-r", str(FPS), seg_mp4]
    
    print(f"  Segment: {slide_name} ({dur_s:.1f}s)")
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode != 0:
        print(f"    ERROR: {r.stderr[-300:]}")
    else:
        seg_videos.append(seg_mp4)
    
    offset += n_frames

# Concat all segments
print("\nConcatenating segments...")
concat_list = os.path.join(BASE, "_concat_list.txt")
with open(concat_list, "w") as f:
    for sv in seg_videos:
        f.write(f"file '{sv}'\n")

cmd = [
    "ffmpeg", "-y",
    "-f", "concat", "-safe", "0",
    "-i", concat_list,
    "-c:v", "libx264", "-c:a", "aac",
    "-b:a", "192k",
    "-pix_fmt", "yuv420p",
    "-movflags", "+faststart",
    OUTPUT
]
r = subprocess.run(cmd, capture_output=True, text=True)
if r.returncode == 0:
    sz = os.path.getsize(OUTPUT) / (1024*1024)
    print(f"\nDONE! {OUTPUT}")
    print(f"Size: {sz:.1f} MB")
else:
    print(f"Concat error: {r.stderr[-500:]}")

# Cleanup
import shutil
for sv in seg_videos:
    if os.path.exists(sv): os.remove(sv)
for slide_name, _ in segment_info:
    d = os.path.join(BASE, f"_segframes_{slide_name}")
    if os.path.isdir(d): shutil.rmtree(d)
if os.path.exists(concat_list): os.remove(concat_list)
if os.path.exists(os.path.join(BASE, "video_only.mp4")): os.remove(os.path.join(BASE, "video_only.mp4"))
if os.path.isdir(FRAMES_DIR): shutil.rmtree(FRAMES_DIR)
