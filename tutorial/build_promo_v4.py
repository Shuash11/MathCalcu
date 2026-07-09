"""MathCalcu Promo v4 — each scene = own MP4, then concat. Fixes narration + overlays."""
import os, subprocess, json, math, shutil, random
from PIL import Image, ImageDraw, ImageFont

BASE = os.path.dirname(__file__)
FRAMES_DIR = os.path.join(BASE, "promo_frames_v4")
NARR_DIR = os.path.join(BASE, "narration_promo")
OUTPUT = os.path.join(BASE, "mathcalcu_promo_v4.mp4")
LOGO_PATH = os.path.join(BASE, "..", "assets", "images", "app_icon.png")
os.makedirs(FRAMES_DIR, exist_ok=True)

W, H = 1920, 1080
FPS = 30

CYAN = (0, 220, 255); PURPLE = (120, 80, 255); WHITE = (255, 255, 255)
GOLD = (255, 215, 0); LIME = (80, 255, 120); RED = (255, 60, 60)
MAGENTA = (255, 50, 150); CORAL = (255, 100, 80); SKY = (100, 200, 255)
MINT = (0, 255, 180); GRAY = (150, 150, 170)

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
        rr(d, [cx-50, cy-50, cx+50, cy+50], 15, CYAN)
        d.text((cx, cy), "f", fill=WHITE, font=gf(60, True), anchor="mm")

def draw_phone(d, px, py, pw, ph, accent=CYAN):
    rr(d, [px, py, px+pw, py+ph], 25, (20, 20, 35), outline=(60, 60, 80), w=2)
    rr(d, [px+6, py+30, px+pw-6, py+ph-6], 3, (15, 15, 25))

def draw_bg(d, c1=(10,10,15), c2=(20,20,30)):
    for y in range(H):
        t = y / H
        c = tuple(int(c1[i]*(1-t) + c2[i]*t) for i in range(3))
        d.line([(0, y), (W, y)], fill=c)

def ctext(d, y, text, fill, size):
    f = gf(size, True)
    d.text((W//2+2, y+2), text, fill=(0,0,0), font=f, anchor="mt")
    d.text((W//2, y), text, fill=fill, font=f, anchor="mt")

# ═══════════════════════════════════════════════════════
# SCENES
# ═══════════════════════════════════════════════════════

def scene_hook(f):
    img = Image.new("RGB", (W, H), (0,0,0)); d = ImageDraw.Draw(img)
    if f < 15: pass
    elif f < 20:
        img = Image.blend(Image.new("RGB",(W,H)), img, 1-(f-15)/5)
        d = ImageDraw.Draw(img)
    elif f < 50:
        t = ease_back(min(1,(f-20)/15))
        sz = int(80*t)
        if sz > 10: ctext(d, H//2-30, "MATHCALCU", CYAN, sz)
        if f > 35: ctext(d, H//2+60, "MATH SOLVER FOR BSCS", GRAY, 28)
    else:
        ctext(d, H//2-30, "MATHCALCU", CYAN, 80)
        ctext(d, H//2+60, "MATH SOLVER FOR BSCS", GRAY, 28)
    return img

def scene_problem(f):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    ctext(d, 60, "THE PROBLEM", RED, 48)
    if f > 10:
        rr(d, [W//2-300, 250, W//2+300, 350], 12, (25,25,50), outline=CORAL, w=2)
        ctext(d, 275, "f(x) = sin(x^2) + ln(cos(x))", WHITE, 24)
    if f > 30:
        ctext(d, 420, "Textbook not helping?", GRAY, 20)
        ctext(d, 480, "There is a better way.", CYAN, 28)
    return img

def scene_app_reveal(f):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    cx = W//2; cy = H//2
    ph_y = int(lerp(-500, cy-250, ease_back(min(1,f/20)))) if f < 20 else cy-250
    for i in range(12,0,-1):
        g = (0, int(30*(1-i/12)), int(50*(1-i/12)))
        rr(d, [cx-105-i*3,ph_y-i*3,cx+105+i*3,ph_y+500+i*3], 35, g)
    draw_phone(d, cx-100, ph_y, 200, 500, CYAN)
    if f > 10:
        draw_logo(d, cx, ph_y+150, int(80*ease_back(min(1,(f-10)/15))))
        if f > 25: d.text((cx, ph_y+280), "MathCalcu", fill=WHITE, font=gf(28,True), anchor="mt")
    return img

def scene_modules(f):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    ctext(d, 40, "8 MODULES", CYAN, 52)
    mods = [("Derivatives",CYAN),("Slope",LIME),("Limits",PURPLE),("Inf. Limits",MAGENTA),
            ("Inequalities",GOLD),("Circles",CORAL),("Distance",SKY),("Slope-Int",MINT)]
    cw, ch = 380, 120; gx, gy = 40, 25
    sx = (W - 2*cw - gx)//2; sy = 130
    for i,(n,c) in enumerate(mods):
        r, col = divmod(i, 2)
        if f < i*4: continue
        t = ease_back(min(1,(f-i*4)/12))
        w, h = int(cw*t), int(ch*t)
        cx_c = sx + col*(cw+gx) + cw//2
        cy_c = sy + r*(ch+gy) + ch//2
        x0, y0 = cx_c-w//2, cy_c-h//2
        if w > 30:
            rr(d, [x0,y0,x0+w,y0+h], 10, (25,25,50), outline=c, w=3)
            if t > 0.7: d.text((cx_c,cy_c), n, fill=c, font=gf(18,True), anchor="mm")
    if f > 45: ctext(d, H-80, "ONE APP. NOTHING EXTRA.", WHITE, 28)
    return img

def scene_derivatives(f):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    ctext(d, 40, "DERIVATIVES", CYAN, 52)
    draw_phone(d, 100, 130, 350, 800, CYAN)
    if f > 5:
        expr = "sin(x^2) + ln(cos(x))"
        n = min(len(expr), (f-5)*2)
        rr(d, [115,180,435,230], 8, (25,25,50), outline=PURPLE, w=2)
        d.text((130,195), expr[:n], fill=WHITE, font=gf(18))
    if f > 50:
        rr(d, [115,260,435,340], 8, (25,25,50), outline=CYAN, w=2)
        d.text((130,275), "f'(x) =", fill=GRAY, font=gf(14))
        d.text((130,300), "2x*cos(x^2) - tan(x)", fill=LIME, font=gf(16,True))
    for i,r in enumerate(["Chain Rule","Power Rule","Product Rule","Quotient Rule"]):
        if f > 60+i*12:
            t = ease_back(min(1,(f-60-i*12)/10))
            ry = int(lerp(200, 200+i*100, t))
            rr(d, [600,ry,1100,ry+70], 10, (25,25,50), outline=PURPLE, w=2)
            d.text((620,ry+15), r, fill=PURPLE, font=gf(18,True))
            d.text((620,ry+42), f"d/dx using {r.lower()}", fill=GRAY, font=gf(13))
    return img

def scene_limits(f):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    ctext(d, 40, "LIMITS", PURPLE, 52)
    ms = [("1. Substitution","Direct plug-in",CYAN),("2. Factoring","Remove indeterminate",LIME),
          ("3. LCD","Complex fractions",GOLD),("4. Conjugate","Radical expressions",CORAL)]
    for i,(nm,ds,c) in enumerate(ms):
        if f > i*10:
            t = ease_back(min(1,(f-i*10)/10))
            mx = 100 + (i%2)*900
            my = int(lerp(-100, 150+(i//2)*180, t))
            rr(d, [mx,my,mx+800,my+140], 12, (25,25,50), outline=c, w=2)
            d.text((mx+20,my+15), nm, fill=c, font=gf(22,True))
            d.text((mx+20,my+55), ds, fill=GRAY, font=gf(16))
            if i==0 and f>30: d.text((mx+20,my+90), "lim(x->2) x^2+3x = 10", fill=LIME, font=gf(16))
            elif i==1 and f>50: d.text((mx+20,my+90), "lim(x->2) (x^2-4)/(x-2) = 4", fill=LIME, font=gf(16))
    if f > 70: ctext(d, H-80, "4 METHODS. SMART DETECTION.", WHITE, 26)
    return img

def scene_geometry(f):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    ctext(d, 40, "ANALYTIC GEOMETRY", CORAL, 48)
    if f > 5:
        t = ease(min(1,(f-5)/20)); gr = int(120*t)
        gcx, gcy = 350, 350
        d.arc([gcx-gr,gcy-gr,gcx+gr,gcy+gr], 0, int(360*t), fill=CORAL, width=3)
        if t > 0.9:
            d.ellipse([gcx-5,gcy-5,gcx+5,gcy+5], fill=CORAL)
            d.text((gcx+15,gcy-gr-10), "(x-3)^2+(y+2)^2=16", fill=GRAY, font=gf(14))
    fs = [("Circles","Center, radius, graph",CORAL),("Distance","Between two points",SKY),
          ("Slope","Line equations",MINT),("Inequalities","Number line",GOLD)]
    for i,(nm,ds,c) in enumerate(fs):
        if f > 20+i*12:
            t = ease_back(min(1,(f-20-i*12)/10))
            fy = int(lerp(150, 180+i*110, t))
            rr(d, [800,fy,1400,fy+90], 10, (25,25,50), outline=c, w=2)
            d.text((820,fy+12), nm, fill=c, font=gf(20,True))
            d.text((820,fy+48), ds, fill=GRAY, font=gf(14))
    return img

def scene_offline(f):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    cy = H//2
    ctext(d, cy-100, "100% OFFLINE", LIME, 64)
    ctext(d, cy, "No internet required", GRAY, 28)
    ctext(d, cy+60, "All 8 modules on-device", GRAY, 20)
    return img

def scene_latex(f):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    cx = W//2
    ctext(d, 100, "LaTeX RENDERED", PURPLE, 52)
    rr(d, [cx-400,220,cx-30,340], 12, (25,25,50), outline=GRAY, w=2)
    d.text((cx-380,240), "Plain text:", fill=GRAY, font=gf(14))
    d.text((cx-380,280), "x^2 + y^2 = r^2", fill=WHITE, font=gf(22))
    if f > 20: ctext(d, 280, "->", CYAN, 40)
    if f > 25:
        t = ease_back(min(1,(f-25)/12))
        rr(d, [cx+30,220,cx+400,340], 12, (25,25,50), outline=PURPLE, w=int(2*t+1))
        d.text((cx+50,240), "LaTeX:", fill=PURPLE, font=gf(14))
        d.text((cx+50,280), "x^2 + y^2 = r^2", fill=WHITE, font=gf(28,True))
    ctext(d, 420, "ACADEMIC PRECISION", WHITE, 26)
    return img

def scene_platform(f):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img); draw_bg(d)
    ctext(d, 80, "CROSS-PLATFORM", SKY, 52)
    ds = [("Android",250,CYAN),("iOS",650,LIME),("Web",1050,GOLD),("Desktop",1450,PURPLE)]
    for i,(nm,dx,c) in enumerate(ds):
        if f > i*10:
            t = ease_back(min(1,(f-i*10)/10))
            dy = int(lerp(100, 250, t))
            if i < 2: draw_phone(d, dx, dy, 120, 220, c)
            elif i == 2: rr(d, [dx,dy,dx+200,dy+150], 8, (25,25,50), outline=c, w=2)
            else:
                rr(d, [dx,dy,dx+200,dy+140], 5, (25,25,50), outline=c, w=2)
                rr(d, [dx+60,dy+140,dx+140,dy+160], 3, c)
            d.text((dx+60,dy+240), nm, fill=c, font=gf(18,True), anchor="mt")
    ctext(d, 580, "ONE CODEBASE. EVERYWHERE.", WHITE, 26)
    return img

def scene_cta(f):
    img = Image.new("RGB", (W, H)); d = ImageDraw.Draw(img)
    for y in range(H):
        t = y/H; r=int(60*(1-t)); g=int(20*(1-t)+150*t); b=int(120*(1-t)+180*t)
        d.line([(0,y),(W,y)], fill=(r,g,b))
    cx, cy = W//2, H//2
    if f < 20:
        t = ease_back(min(1,f/15))
        draw_logo(d, cx, int(lerp(-200,cy-150,t)), int(100*t))
    else:
        draw_logo(d, cx, cy-150, 100)
    if f > 10: ctext(d, cy-40, "MathCalcu", WHITE, int(64*ease(min(1,(f-10)/10))))
    if f > 25: ctext(d, cy+40, "Built by BSCS students", (200,200,220), int(22*ease(min(1,(f-25)/10))))
    if f > 50:
        rr(d, [cx-200,cy+100,cx+200,cy+150], 25, WHITE, outline=GOLD, w=2)
        d.text((cx,cy+115), "Star on GitHub", fill=(30,30,40), font=gf(18,True), anchor="mm")
        d.text((cx,cy+180), "github.com/Shuash11/MathCalcu", fill=(180,180,200), font=gf(16), anchor="mt")
    if f > 70: ctext(d, cy+230, "Share with your classmates", WHITE, 20)
    return img

def scene_close(f):
    img = Image.new("RGB", (W, H), (0,0,0)); d = ImageDraw.Draw(img)
    if f < 30:
        t = ease(min(1,f/15)); c = int(255*t)
        ctext(d, H//2, "Math doesn't have to be hard.", (c,c,c), 40)
    elif f < 60:
        ctext(d, H//2, "Math doesn't have to be hard.", WHITE, 40)
        if f > 45:
            t = 1-ease(min(1,(f-45)/15)); c = int(255*t)
            ctext(d, H//2, "Math doesn't have to be hard.", (c,c,c), 40)
    return img

# ═══════════════════════════════════════════════════════
# BUILD: each scene = separate MP4 with its own audio
# ═══════════════════════════════════════════════════════

def get_dur(path):
    r = subprocess.run(["ffprobe","-v","quiet","-show_entries","format=duration",
                       "-of","default=noprint_wrappers=1:nokey=1",path],
                       capture_output=True, text=True)
    return float(r.stdout.strip())

# Scene definitions: (name, func, duration_sec, narration_file_or_None)
# Durations matched to narration length
SCENES = [
    ("01_hook",       scene_hook,        3,  "s01_hook.mp3"),
    ("02_problem",    scene_problem,     5,  "s02_problem.mp3"),
    ("03_app_reveal", scene_app_reveal,  6,  "s03_reveal.mp3"),
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

seg_files = []
total_frames = 0

for sname, sfunc, dur, narr in SCENES:
    print(f"  {sname}: {dur}s", end="")
    nf = dur * FPS
    sdir = os.path.join(FRAMES_DIR, sname)
    os.makedirs(sdir, exist_ok=True)

    # Render frames
    for i in range(nf):
        frame = sfunc(f=i)
        if i < 4:
            frame = Image.blend(Image.new("RGB",(W,H)), frame, ease(i/4))
        elif i >= nf-4:
            frame = Image.blend(Image.new("RGB",(W,H)), frame, ease((nf-i)/4))
        frame.save(os.path.join(sdir, f"frame_{i:06d}.png"))

    # Build segment MP4
    seg_mp4 = os.path.join(BASE, f"_seg_{sname}.mp4")
    narr_path = os.path.join(NARR_DIR, narr) if narr else None

    if narr and os.path.exists(narr_path):
        # Pad narration with silence to match scene duration
        narr_dur = get_dur(narr_path)
        if narr_dur > dur:
            # Narration longer than scene — trim it
            padded_narr = os.path.join(BASE, f"_padded_{sname}.wav")
            cmd_trim = ["ffmpeg", "-y", "-i", narr_path, "-t", str(dur),
                        "-c:a", "pcm_s16le", padded_narr]
            subprocess.run(cmd_trim, capture_output=True)
        else:
            silence_needed = max(0, dur - narr_dur)
            padded_narr = os.path.join(BASE, f"_padded_{sname}.wav")
            cmd_pad = ["ffmpeg", "-y",
                "-i", narr_path,
                "-f", "lavfi", "-i", f"anullsrc=r=44100:cl=stereo:d={silence_needed}",
                "-filter_complex", "[0:a][1:a]concat=n=2:v=0:a=1[out]",
                "-map", "[out]", "-c:a", "pcm_s16le", padded_narr]
            subprocess.run(cmd_pad, capture_output=True)

        cmd = ["ffmpeg", "-y", "-framerate", str(FPS),
               "-i", os.path.join(sdir, "frame_%06d.png"),
               "-i", padded_narr,
               "-c:v", "libx264", "-t", str(dur),
               "-c:a", "aac", "-b:a", "192k",
               "-pix_fmt", "yuv420p", "-r", str(FPS), seg_mp4]
    else:
        # Video only (silent)
        cmd = ["ffmpeg", "-y", "-framerate", str(FPS),
               "-i", os.path.join(sdir, "frame_%06d.png"),
               "-f", "lavfi", "-i", "anullsrc=r=44100:cl=stereo",
               "-c:v", "libx264", "-t", str(dur),
               "-c:a", "aac", "-b:a", "128k", "-shortest",
               "-pix_fmt", "yuv420p", "-r", str(FPS), seg_mp4]

    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode == 0:
        seg_files.append(seg_mp4)
        actual = get_dur(seg_mp4)
        print(f" -> {actual:.1f}s OK")
    else:
        print(f" -> ERR: {r.stderr[-200:]}")

    total_frames += nf

# Concat all segments
print("\nConcatenating...")
cl = os.path.join(BASE, "_concat_v4.txt")
with open(cl, "w") as f:
    for s in seg_files:
        f.write(f"file '{s}'\n")

cmd = ["ffmpeg", "-y", "-f", "concat", "-safe", "0", "-i", cl,
       "-c:v", "libx264", "-c:a", "aac", "-b:a", "192k",
       "-pix_fmt", "yuv420p", "-movflags", "+faststart", OUTPUT]
r = subprocess.run(cmd, capture_output=True, text=True)
if r.returncode == 0:
    sz = os.path.getsize(OUTPUT)/(1024*1024)
    dur = get_dur(OUTPUT)
    print(f"\n  Video OK: {sz:.1f} MB, {dur:.1f}s")
else:
    print(f"Concat error: {r.stderr[-300:]}")

# Mix with background music
print("\nMixing background music...")
music_path = os.path.join(BASE, "music", "elevenlabs_bg_looped.wav")
final = os.path.join(BASE, "mathcalcu_promo_final.mp4")
if os.path.exists(music_path):
    cmd = ["ffmpeg", "-y", "-i", OUTPUT, "-i", music_path,
           "-filter_complex",
           "[0:a]volume=1.0[vo];[1:a]volume=0.45[bg];[vo][bg]amix=inputs=2:duration=first:dropout_transition=0[a]",
           "-map", "0:v", "-map", "[a]",
           "-c:v", "copy", "-c:a", "aac", "-b:a", "192k",
           "-shortest", "-movflags", "+faststart", final]
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode == 0:
        sz = os.path.getsize(final)/(1024*1024)
        dur = get_dur(final)
        print(f"  Final OK: {sz:.1f} MB, {dur:.1f}s")
    else:
        print(f"  Music mix error: {r.stderr[-300:]}")
        # Fallback: use video without music
        shutil.copy2(OUTPUT, final)
else:
    print("  No music file found, using video-only")
    shutil.copy2(OUTPUT, final)

# Cleanup
for s in seg_files:
    if os.path.exists(s): os.remove(s)
for sname,_,_,_ in SCENES:
    d = os.path.join(FRAMES_DIR, sname)
    if os.path.isdir(d): shutil.rmtree(d)
    padded = os.path.join(BASE, f"_padded_{sname}.wav")
    if os.path.exists(padded): os.remove(padded)
if os.path.exists(cl): os.remove(cl)
if os.path.isdir(FRAMES_DIR): shutil.rmtree(FRAMES_DIR)
if os.path.exists(OUTPUT): os.remove(OUTPUT)

# Copy to Downloads
copy_to = os.path.join(os.path.expanduser("~"), "Downloads", "mathcalcu_promo_final.mp4")
shutil.copy2(final, copy_to)
print(f"Copied to {copy_to}")
