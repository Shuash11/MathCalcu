"""Compose MathCalcu tutorial video: slides + narration -> final mp4."""
import subprocess
import os
import json

BASE = os.path.dirname(__file__)
SLIDES_DIR = os.path.join(BASE, "slides")
NARRATION_DIR = os.path.join(BASE, "narration")
OUTPUT = os.path.join(BASE, "mathcalcu_tutorial.mp4")

slides = [
    "01_title",
    "02_features",
    "03_derivatives",
    "04_slope",
    "05_limits",
    "06_more",
    "07_cta",
]

def get_audio_duration(path):
    """Get duration of audio file in seconds using ffprobe."""
    cmd = [
        "ffprobe", "-v", "quiet",
        "-print_format", "json",
        "-show_format",
        path
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    data = json.loads(result.stdout)
    return float(data["format"]["duration"])

# Step 1: Get durations and build per-slide video segments
segments = []
for name in slides:
    audio_path = os.path.join(NARRATION_DIR, f"{name}.mp3")
    slide_path = os.path.join(SLIDES_DIR, f"{name}.png")
    duration = get_audio_duration(audio_path)
    
    # Add 0.5s padding after narration
    total_dur = duration + 0.5
    seg_path = os.path.join(BASE, f"seg_{name}.mp4")
    
    # Create video segment: static image + audio
    cmd = [
        "ffmpeg", "-y",
        "-loop", "1",
        "-i", slide_path,
        "-i", audio_path,
        "-c:v", "libx264",
        "-t", str(total_dur),
        "-pix_fmt", "yuv420p",
        "-vf", "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2",
        "-c:a", "aac",
        "-b:a", "192k",
        "-shortest",
        "-r", "30",
        seg_path
    ]
    print(f"Creating segment: {name} ({total_dur:.1f}s)")
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"  ERROR: {result.stderr[-300:]}")
    else:
        segments.append(seg_path)

# Step 2: Concatenate all segments
concat_file = os.path.join(BASE, "concat_segments.txt")
with open(concat_file, "w") as f:
    for seg in segments:
        f.write(f"file '{seg}'\n")

print(f"\nConcatenating {len(segments)} segments...")
cmd = [
    "ffmpeg", "-y",
    "-f", "concat",
    "-safe", "0",
    "-i", concat_file,
    "-c:v", "libx264",
    "-c:a", "aac",
    "-b:a", "192k",
    "-pix_fmt", "yuv420p",
    "-movflags", "+faststart",
    OUTPUT
]
result = subprocess.run(cmd, capture_output=True, text=True)
if result.returncode == 0:
    size_mb = os.path.getsize(OUTPUT) / (1024 * 1024)
    dur = get_audio_duration(OUTPUT)
    print(f"\nDONE!")
    print(f"  Output: {OUTPUT}")
    print(f"  Duration: {dur:.1f}s")
    print(f"  Size: {size_mb:.1f} MB")
else:
    print(f"Concat error: {result.stderr[-500:]}")

# Cleanup temp segments
for seg in segments:
    os.remove(seg)
os.remove(concat_file)
os.remove(os.path.join(BASE, "concat.txt"))
