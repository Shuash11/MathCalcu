# MathCalcu Video Tutorial Project

## Session Summary — 2026-06-21

### What We Built
A promotional/tutorial video for MathCalcu Flutter app with 9 segments following the official script at `C:\Users\joashua\Downloads\MathCalcu_VideoPromo_Script.md`.

### Key Files
- **App project:** `C:\projects\mathcalcu` (Flutter)
- **Real logo:** `C:\projects\mathcalcu\assets\images\app_icon.png` (dark navy, cyan integral + parabola)
- **Tutorial scripts:** `C:\projects\mathcalcu\tutorial\build_video_v*.py`
- **Narration audio:** `C:\projects\mathcalcu\tutorial\narration\*.mp3`
- **Final output:** `C:\Users\joashua\Downloads\mathcalcu_tutorial.mp4`
- **Official script:** `C:\Users\joashua\Downloads\MathCalcu_VideoPromo_Script.md`

### ElevenLabs API
- Key in: `C:\Users\joashua\video-use\.env`
- Key: `sk_d3bee5ebdb0fc6d937c799d43e62efafff8d1ecfb308d1c0`
- Voice ID: `hpp4J3VqNfWAUOO0d1Us`

### What Worked
1. ElevenLabs API for narration (direct calls, not Voicebox)
2. PIL/Pillow for generating animated frames
3. ffmpeg for compiling frames to video + concat
4. Real logo loaded from `assets/images/app_icon.png`

### What to Improve Next Time
1. **Use video-use `render.py`** for proper composition (audio fades, overlays, grades)
2. **Don't regenerate narration** if already done — reuse existing MP3s
3. **Use 15 FPS** for faster rendering (30 FPS is overkill for animated graphics)
4. **Build segments incrementally** — don't rebuild everything each time
5. **Use EDL format** for structured editing

### The 9 Segments (from official script)
1. Hook — "Tomorrow: MATH EXAM" → stress → "MATHCALCU HAS ENTERED THE CHAT"
2. App Introduction — 8 modules, benefits, "Built by BSCS students"
3. Derivatives Tutorial — Step-by-step demo, rapid demo, rules list
4. Quiz Break #1 — 2 derivative questions with countdown
5. Limits Tutorial — 4 methods, substitution/factoring/infinity demos
6. Analytic Geometry — Circles, Distance, Slope, Inequalities
7. Quiz Break #2 — 2 questions + bonus challenge
8. Fun Facts — 6 cards (Flutter, LaTeX, Descartes, Newton/Leibniz)
9. CTA/Outro — Logo, GitHub link, "Math doesn't have to be hard"

### Colors/Theme (from real logo)
- Background: dark navy (12,12,28)
- Primary: cyan (0,220,255)
- Accent: purple (120,80,255)
- Cards: (28,28,60)
- Fun accents: CORAL, LIME, GOLD, SKY, MAGENTA, MINT

### Student Character
- Cute animated character with: walk, wave, think, excited, point poses
- Shirt color matches brand (CYAN)
- Skin: (255,220,180), Hair: (50,35,25)

### Important Notes
- **Never assume a file is corrupted** — just has bracket/syntax mismatch
- **Always read full file before editing**
- **Fix only the specific line with the mismatch**
- **The video-use skill is for EDITING existing videos, not creating from scratch**
- **For creation from scratch: PIL → frames → ffmpeg compile is correct approach**
