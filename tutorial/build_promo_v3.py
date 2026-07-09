"""MathCalcu Promo Video v3 — Fixed overlapping + narration."""
import os, subprocess, json, math, shutil, random
from PIL import Image, ImageDraw, ImageFont

BASE = os.path.dirname(__file__)
FRAMES_DIR = os.path.join(BASE, "promo_frames_v3")
NARR_DIR = os.path.join(BASE, "narration_promo")
OUTPUT = os.path.join(BASE, "mathcalcu_promo_v3.mp4")
LOGO_PATH = os.path.join(BASE, "..", "assets", "images", "app_icon.png")
os.makedirs(FRAMES_DIR, exist_ok=True)

W, H = 1920, 1080
FPS = 30

# Colors
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
GRAY = (150, 150, 170)

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
    rr(d, [px, py, px+pw, py+ph], 25, (20, 20, 35), outline=(60, 60, 80), w=2)
    rr(d, [px+6, py+30, px+pw-6, py+ph-6], 3, (15, 15, 25))
    rr(d, [px+pw//2-30, py+4, px+pw//2+30, py+20], 8, (30, 30, 45))

def draw_bg(d, c1=(10,10,15), c2=(20,20,30)):
    for y in range(H):
        t = y / H
        c = tuple(int(c1[i]*(1-t) + c2[i]*t) for i in range(3))
        d.line([(0, y), (W, y)], fill=c)

def draw_text_shadow(d, x, y, text, fill, size, anchor="lt"):
    font = gf(size, True)
    d.text((x+3, y+3), text, fill=(0, 0, 0), font=font, anchor=anchor)
    d.text((x, y), text, fill=fill, font=font, anchor=anchor)

def center_text(d, y, text, fill, size):
    draw_text_shadow(d, W//2, y, text, fill, size, "mt")

def flash_frame(base, intensity=1.0):
    overlay = Image.new("RGB", (W, H), (int(255*intensity), int(255*intensity), int(255*intensity)))
    return Image.blend(base, overlay, intensity * 0.3)

# ═══════════════════════════════════════════════════════
# SCENES — each draws on a FRESH canvas (no overlap)
# ═══════════════════════════════════════════════════════

def scene_hook(f):
    """0-3s: Black -> flash -> MATHCALCU"""
    img = Image.new("RGB", (W, H), (0, 0, 0))
    d = ImageDraw.Draw(img)
    if f < 15:
        pass
    elif f < 20:
        t = (f - 15) / 5
        img = flash_frame(img, 1 - t)
        d = ImageDraw.Draw(img)
    elif f < 50:
        t = ease_back(min(1, (f - 20) / 15))
        sz = int(80 * t)
        if sz > 10:
            center_text(d, H//2 - 30, "MATHCALCU", CYAN, sz)
            if f > 35:
                center_text(d, H//2 + 60, "MATH SOLVER FOR BSCS", GRAY, 28)
    else:
        center_text(d, H//2 - 30, "MATHCALCU", CYAN, 80)
        center_text(d, H//2 + 60, "MATH SOLVER FOR BSCS", GRAY, 28)
    return img

def scene_problem(f):
    """3-6s: Problem statement"""
    img = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(img)
    draw_bg(d)
    # Clear top area with title
    rr(d, [0, 0, W, 120], 0, (10, 10, 15))
    center_text(d, 60, "THE PROBLEM", RED, 48)
    # Equation centered
    if f > 10:
        t = ease(min(1, (f-10)/10))
        rr(d, [W//2-300, 250, W//2+300, 350], 12, (25,25,50), outline=CORAL, w=2)
        center_text(d, 275, "f(x) = sin(x²) + ln(cos(x))", WHITE, 24)
    if f > 30:
        center_text(d, 420, "Textbook not helping?", GRAY, 20)
        center_text(d, 480, "There's a better way.", CYAN, 28)
    return img

def scene_app_reveal(f):
    """6-10s: Phone drops in"""
    img = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(img)
    draw_bg(d, (10,10,15), (15,15,30))
    cx, cy = W//2, H//2
    if f < 20:
        t = ease_back(min(1, f / 20))
        ph_y = int(lerp(-500, cy - 250, t))
    else:
        ph_y = cy - 250
    for i in range(12, 0, -1):
        glow = (0, int(30*(1-i/12)), int(50*(1-i/12)))
        rr(d, [cx-105-i*3, ph_y-i*3, cx+105+i*3, ph_y+500+i*3], 35, glow)
    draw_phone(d, cx-100, ph_y, 200, 500, CYAN)
    if f > 10:
        icon_t = ease_back(min(1, (f-10)/15))
        draw_logo(d, cx, ph_y+150, int(80*icon_t))
        if f > 25:
            draw_text_shadow(d, cx, ph_y+280, "MathCalcu", WHITE, 28, "mt")
    if f > 40:
        rr(d, [cx-60, ph_y+340, cx+60, ph_y+380], 15, CYAN)
        d.text((cx, ph_y+360), "SOLVE", fill=WHITE, font=gf(16, True), anchor="mm")
    return img

def scene_modules_grid(f):
    """10-15s: 8 module cards"""
    img = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(img)
    draw_bg(d)
    center_text(d, 40, "8 MODULES", CYAN, 52)
    modules = [
        ("Derivatives", CYAN), ("Slope", LIME),
        ("Limits", PURPLE), ("Infinity Limits", MAGENTA),
        ("Inequalities", GOLD), ("Circles", CORAL),
        ("Distance", SKY), ("Slope-Intercept", MINT),
    ]
    card_w, card_h = 380, 120
    gap_x, gap_y = 40, 25
    grid_w = 2*card_w + gap_x
    start_x = (W - grid_w)//2
    start_y = 130
    for i, (name, color) in enumerate(modules):
        row, col = divmod(i, 2)
        delay = i * 4
        if f < delay: continue
        t = ease_back(min(1, (f-delay)/12))
        cx_c = start_x + col*(card_w+gap_x) + card_w//2
        cy_c = start_y + row*(card_h+gap_y) + card_h//2
        w = int(card_w * t)
        h = int(card_h * t)
        x0 = cx_c - w//2
        y0 = cy_c - h//2
        if w > 30:
            rr(d, [x0, y0, x0+w, y0+h], 10, (25,25,50), outline=color, w=3)
            if t > 0.7:
                d.text((cx_c, cy_c), name, fill=color, font=gf(18, True), anchor="mm")
    if f > 45:
        center_text(d, H-80, "ONE APP. NOTHING EXTRA.", WHITE, 28)
    return img

def scene_derivatives_fast(f):
    """15-20s: Derivatives"""
    img = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(img)
    draw_bg(d)
    cx, cy = W//2, H//2
    center_text(d, 40, "DERIVATIVES", CYAN, 52)
    # Phone on left
    draw_phone(d, 100, 130, 350, 800, CYAN)
    if f > 5:
        expr = "sin(x^2) + ln(cos(x))"
        n = min(len(expr), (f-5)*2)
        rr(d, [115, 180, 435, 230], 8, (25,25,50), outline=PURPLE, w=2)
        d.text((130, 195), expr[:n], fill=WHITE, font=gf(18))
    if f > 50:
        rr(d, [115, 260, 435, 340], 8, (25,25,50), outline=CYAN, w=2)
        d.text((130, 275), "f'(x) =", fill=GRAY, font=gf(14))
        d.text((130, 300), "2x*cos(x^2) - tan(x)", fill=LIME, font=gf(16, True))
    # Rules on right
    rules = ["Chain Rule", "Power Rule", "Product Rule", "Quotient Rule"]
    for i, rule in enumerate(rules):
        rd = 60 + i * 12
        if f > rd:
            rt = ease_back(min(1, (f-rd)/10))
            rx = 600
            ry = int(lerp(150, 200 + i*100, rt))
            rr(d, [rx, ry, rx+500, ry+70], 10, (25,25,50), outline=PURPLE, w=2)
            d.text((rx+20, ry+15), rule, fill=PURPLE, font=gf(18, True))
            d.text((rx+20, ry+42), f"d/dx using {rule.lower()}", fill=GRAY, font=gf(13))
    return img

def scene_limits_fast(f):
    """20-25s: Limits"""
    img = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(img)
    draw_bg(d)
    center_text(d, 40, "LIMITS", PURPLE, 52)
    methods = [
        ("1. Substitution", "Direct plug-in", CYAN),
        ("2. Factoring", "Remove indeterminate", LIME),
        ("3. LCD", "Complex fractions", GOLD),
        ("4. Conjugate", "Radical expressions", CORAL),
    ]
    for i, (name, desc, color) in enumerate(methods):
        md = i * 10
        if f > md:
            mt = ease_back(min(1, (f-md)/10))
            mx = 100 + (i%2)*900
            my = int(lerp(-100, 150 + (i//2)*180, mt))
            rr(d, [mx, my, mx+800, my+140], 12, (25,25,50), outline=color, w=2)
            d.text((mx+20, my+15), name, fill=color, font=gf(22, True))
            d.text((mx+20, my+55), desc, fill=GRAY, font=gf(16))
            if i == 0 and f > 30:
                d.text((mx+20, my+90), "lim(x->2) x^2+3x = 10", fill=LIME, font=gf(16))
            elif i == 1 and f > 50:
                d.text((mx+20, my+90), "lim(x->2) (x^2-4)/(x-2) = 4", fill=LIME, font=gf(16))
    if f > 70:
        center_text(d, H-80, "4 METHODS. SMART DETECTION.", WHITE, 26)
    return img

def scene_geometry_fast(f):
    """25-30s: Geometry"""
    img = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(img)
    draw_bg(d)
    center_text(d, 40, "ANALYTIC GEOMETRY", CORAL, 48)
    # Circle on left
    if f > 5:
        t = ease(min(1, (f-5)/20))
        gr = int(120 * t)
        gcx, gcy = 350, 350
        d.arc([gcx-gr, gcy-gr, gcx+gr, gcy+gr], 0, int(360*t), fill=CORAL, width=3)
        if t > 0.9:
            d.ellipse([gcx-5, gcy-5, gcx+5, gcy+5], fill=CORAL)
            d.text((gcx+15, gcy-gr-10), "(x-3)^2+(y+2)^2=16", fill=GRAY, font=gf(14))
    # Features on right
    features = [
        ("Circles", "Center, radius, graph", CORAL),
        ("Distance", "Between two points", SKY),
        ("Slope", "Line equations", MINT),
        ("Inequalities", "Number line", GOLD),
    ]
    for i, (name, desc, color) in enumerate(features):
        fd = 20 + i * 12
        if f > fd:
            ft = ease_back(min(1, (f-fd)/10))
            fx = 800
            fy = int(lerp(150, 180 + i*110, ft))
            rr(d, [fx, fy, fx+600, fy+90], 10, (25,25,50), outline=color, w=2)
            d.text((fx+20, fy+12), name, fill=color, font=gf(20, True))
            d.text((fx+20, fy+48), desc, fill=GRAY, font=gf(14))
    return img

def scene_offline(f):
    """30-33s: Offline"""
    img = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(img)
    draw_bg(d, (8,8,12), (12,15,20))
    cx, cy = W//2, H//2
    center_text(d, cy-100, "100% OFFLINE", LIME, 64)
    center_text(d, cy, "No internet required", GRAY, 28)
    center_text(d, cy+60, "All 8 modules on-device", GRAY, 20)
    return img

def scene_latex(f):
    """33-37s: LaTeX"""
    img = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(img)
    draw_bg(d)
    cx, cy = W//2, H//2
    center_text(d, 100, "LaTeX RENDERED", PURPLE, 52)
    # Before
    rr(d, [cx-400, 220, cx-30, 340], 12, (25,25,50), outline=GRAY, w=2)
    d.text((cx-380, 240), "Plain text:", fill=GRAY, font=gf(14))
    d.text((cx-380, 280), "x^2 + y^2 = r^2", fill=WHITE, font=gf(22))
    # Arrow
    if f > 20:
        center_text(d, 280, "->", CYAN, 40)
    # After
    if f > 25:
        t = ease_back(min(1, (f-25)/12))
        rr(d, [cx+30, 220, cx+400, 340], 12, (25,25,50), outline=PURPLE, w=int(2*t+1))
        d.text((cx+50, 240), "LaTeX:", fill=PURPLE, font=gf(14))
        d.text((cx+50, 280), "x² + y² = r²", fill=WHITE, font=gf(28, True))
    center_text(d, 420, "ACADEMIC PRECISION", WHITE, 26)
    return img

def scene_cross_platform(f):
    """37-41s: Cross-platform"""
    img = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(img)
    draw_bg(d)
    cx, cy = W//2, H//2
    center_text(d, 80, "CROSS-PLATFORM", SKY, 52)
    devices = [("Android", 250, CYAN), ("iOS", 650, LIME), ("Web", 1050, GOLD), ("Desktop", 1450, PURPLE)]
    for i, (name, dx, color) in enumerate(devices):
        dd = i * 10
        if f > dd:
            dt = ease_back(min(1, (f-dd)/10))
            dy = int(lerp(100, 250, dt))
            if i < 2:
                draw_phone(d, dx, dy, 120, 220, color)
            elif i == 2:
                rr(d, [dx, dy, dx+200, dy+150], 8, (25,25,50), outline=color, w=2)
            else:
                rr(d, [dx, dy, dx+200, dy+140], 5, (25,25,50), outline=color, w=2)
                rr(d, [dx+60, dy+140, dx+140, dy+160], 3, color)
            center_text(d, dy+240, name, color, 18)
    center_text(d, 580, "ONE CODEBASE. EVERYWHERE.", WHITE, 26)
    return img

def scene_cta(f):
    """41-50s: CTA"""
    img = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(img)
    # Purple-cyan gradient
    for y in range(H):
        t = y / H
        r = int(60*(1-t))
        g = int(20*(1-t) + 150*t)
        b = int(120*(1-t) + 180*t)
        d.line([(0,y),(W,y)], fill=(r,g,b))
    cx, cy = W//2, H//2
    if f < 20:
        t = ease_back(min(1, f/15))
        draw_logo(d, cx, int(lerp(-200, cy-150, t)), int(100*t))
    else:
        draw_logo(d, cx, cy-150, 100)
    if f > 10:
        t = ease(min(1, (f-10)/10))
        center_text(d, cy-40, "MathCalcu", WHITE, int(64*t))
    if f > 25:
        t = ease(min(1, (f-25)/10))
        center_text(d, cy+40, "Built by BSCS students", (200,200,220), int(22*t))
    if f > 50:
        rr(d, [cx-200, cy+100, cx+200, cy+150], 25, WHITE, outline=GOLD, w=2)
        center_text(d, cy+115, "Star on GitHub", (30,30,40), 18)
        center_text(d, cy+180, "github.com/Shuash11/MathCalcu", (180,180,200), 16)
    if f > 70:
        center_text(d, cy+230, "Share with your classmates", WHITE, 20)
    return img

def scene_close(f):
    """50-55s: Final"""
    img = Image.new("RGB", (W, H), (0, 0, 0))
    d = ImageDraw.Draw(img)
    if f < 30:
        t = ease(min(1, f/15))
        c = int(255*t)
        center_text(d, H//2, "Math doesn't have to be hard.", (c,c,c), 40)
    elif f < 60:
        center_text(d, H//2, "Math doesn't have to be hard.", WHITE, 40)
        if f > 45:
            t = 1 - ease(min(1, (f-45)/15))
            c = int(255*t)
            center_text(d, H//2, "Math doesn't have to be hard.", (c,c,c), 40)
    return img

# ═══════════════════════════════════════════════════════
# BUILD
# ═══════════════════════════════════════════════════════

SCENE_LIST = [
    ("hook",       scene_hook,        0,  3),
    ("problem",    scene_problem,     3,  6),
    ("app_reveal", scene_app_reveal,  6, 10),
    ("modules",    scene_modules_grid,10, 15),
    ("derivatives",scene_derivatives_fast, 15, 20),
    ("limits",     scene_limits_fast, 20, 25),
    ("geometry",   scene_geometry_fast,25, 30),
    ("offline",    scene_offline,     30, 33),
    ("latex",      scene_latex,       33, 37),
    ("platform",   scene_cross_platform,37, 41),
    ("cta",        scene_cta,         41, 50),
    ("close",      scene_close,       50, 55),
]

NARR_TIMING = [
    ("promo_01.mp3", 10.5),
    ("promo_02.mp3", 15.5),
    ("promo_03.mp3", 22.0),
    ("promo_04.mp3", 30.5),
    ("promo_05.mp3", 37.5),
    ("promo_06.mp3", 45.0),
]

def get_dur(path):
    r = subprocess.run(["ffprobe","-v","quiet","-show_entries","format=duration",
                       "-of","default=noprint_wrappers=1:nokey=1",path],
                       capture_output=True, text=True)
    return float(r.stdout.strip())

print("Building promo v3...")
frame_idx = 0
for sname, sfunc, t_start, t_end in SCENE_LIST:
    dur = t_end - t_start
    nf = dur * FPS
    print(f"  {sname}: {t_start}s-{t_end}s ({nf} frames)")
    for i in range(nf):
        frame = sfunc(f=i)
        if i < 5:
            frame = Image.blend(Image.new("RGB", (W, H)), frame, ease(i/5))
        elif i >= nf - 5:
            frame = Image.blend(Image.new("RGB", (W, H)), frame, ease((nf-i)/5))
        frame.save(os.path.join(FRAMES_DIR, f"frame_{frame_idx:06d}.png"))
        frame_idx += 1

total_dur = frame_idx / FPS
print(f"\nTotal: {frame_idx} frames ({total_dur:.1f}s)")

# Build video from frames
print("Building video track...")
video_only = os.path.join(BASE, "_video_v3.mp4")
r = subprocess.run(["ffmpeg", "-y", "-framerate", str(FPS),
    "-i", os.path.join(FRAMES_DIR, "frame_%06d.png"),
    "-c:v", "libx264", "-pix_fmt", "yuv420p", "-r", str(FPS),
    video_only], capture_output=True, text=True)
if r.returncode != 0:
    print(f"Video error: {r.stderr[-300:]}")

# Build mixed audio using individual delayed tracks
print("Building audio...")
mixed_audio = os.path.join(BASE, "_audio_v3.wav")

# Step 1: Create silent base
silent = os.path.join(BASE, "_silent_v3.wav")
subprocess.run(["ffmpeg", "-y", "-f", "lavfi", "-i",
    f"anullsrc=r=44100:cl=stereo:d={total_dur}",
    "-c:a", "pcm_s16le", silent], capture_output=True)

# Step 2: Pad each narration clip to full video duration with delay
temp_audios = []
filter_inputs = ["-i", silent]
for i, (narr_file, t_start) in enumerate(NARR_TIMING):
    narr_path = os.path.join(NARR_DIR, narr_file)
    padded = os.path.join(BASE, f"_narr_pad_{i}.wav")
    if os.path.exists(narr_path):
        # Create delayed version: silence + narration
        delay_s = t_start
        narr_dur = get_dur(narr_path)
        cmd = ["ffmpeg", "-y",
            "-f", "lavfi", "-i", f"anullsrc=r=44100:cl=stereo:d={delay_s}",
            "-i", narr_path,
            "-f", "lavfi", "-i", f"anullsrc=r=44100:cl=stereo:d={max(0, total_dur - delay_s - narr_dur)}",
            "-filter_complex", "[0:a][1:a][2:a]concat=n=3:v=0:a=1[out]",
            "-map", "[out]", "-c:a", "pcm_s16le", padded]
        r = subprocess.run(cmd, capture_output=True, text=True)
        if r.returncode == 0:
            temp_audios.append(padded)
            filter_inputs += ["-i", padded]
        else:
            print(f"  Pad error for {narr_file}: {r.stderr[-200:]}")
    else:
        print(f"  Missing: {narr_path}")

# Step 3: Mix all padded tracks
if temp_audios:
    n = len(temp_audios)
    mix_inputs = "".join(f"[{i+1}:a]" for i in range(n))
    cmd = ["ffmpeg", "-y"] + filter_inputs + [
        "-filter_complex", f"{mix_inputs}amix=inputs={n}:duration=first:dropout_transition=0,atrim=0:{total_dur},volume={n}[out]",
        "-map", "[out]", "-c:a", "pcm_s16le", mixed_audio]
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode != 0:
        print(f"  Mix error: {r.stderr[-300:]}")
    else:
        print("  Audio mixed OK")

# Step 4: Combine
print("Combining...")
final = OUTPUT
cmd = ["ffmpeg", "-y", "-i", video_only, "-i", mixed_audio,
    "-c:v", "libx264", "-c:a", "aac", "-b:a", "192k",
    "-map", "0:v:0", "-map", "1:a:0",
    "-shortest", "-pix_fmt", "yuv420p", "-movflags", "+faststart", final]
r = subprocess.run(cmd, capture_output=True, text=True)
if r.returncode == 0:
    sz = os.path.getsize(final) / (1024*1024)
    dur = get_dur(final)
    print(f"\nDONE! {sz:.1f} MB, {dur:.1f}s")
else:
    print(f"Error: {r.stderr[-300:]}")

# Cleanup
for f_path in [silent, video_only, mixed_audio] + temp_audios:
    if os.path.exists(f_path): os.remove(f_path)
if os.path.isdir(FRAMES_DIR): shutil.rmtree(FRAMES_DIR)

# Copy to Downloads
copy_to = os.path.join(os.path.expanduser("~"), "Downloads", "mathcalcu_promo_v3.mp4")
shutil.copy2(final, copy_to)
print(f"Copied to {copy_to}")
