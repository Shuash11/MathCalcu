"""Merge multi-line narration into single files per scene and print durations."""
import os, subprocess, json, glob

BASE = os.path.dirname(__file__)
NARR_DIR = os.path.join(BASE, "narration")

scenes = ["s01_cold_open", "s02_app_reveal", "s03_module_showcase", "s04_derivatives",
          "s05_limits", "s06_geometry", "s07_power_features", "s08_closing"]

def get_dur(path):
    r = subprocess.run(["ffprobe","-v","quiet","-print_format","json","-show_format",path],
                       capture_output=True, text=True)
    return float(json.loads(r.stdout)["format"]["duration"])

for scene in scenes:
    files = sorted(glob.glob(os.path.join(NARR_DIR, f"{scene}_*.mp3")))
    merged = os.path.join(NARR_DIR, f"{scene}.mp3")
    
    if len(files) == 1:
        # Just rename
        if os.path.exists(merged):
            os.remove(merged)
        os.rename(files[0], merged)
    elif len(files) > 1:
        # Concatenate with ffmpeg
        list_file = os.path.join(NARR_DIR, f"_concat_{scene}.txt")
        with open(list_file, "w") as f:
            for fp in files:
                f.write(f"file '{fp}'\n")
        cmd = ["ffmpeg","-y","-f","concat","-safe","0","-i",list_file,"-c","copy",merged]
        subprocess.run(cmd, capture_output=True)
        os.remove(list_file)
        # Remove individual files
        for fp in files:
            if os.path.exists(fp):
                os.remove(fp)
    
    if os.path.exists(merged):
        dur = get_dur(merged)
        print(f"{scene}: {dur:.2f}s")
    else:
        print(f"{scene}: MISSING")
