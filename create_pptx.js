const pptxgen = require("pptxgenjs");

const pres = new pptxgen();
pres.layout = "LAYOUT_16x9";
pres.author = "MathCalcu Team";
pres.title = "MathCalcu — Agile System Documentation";

// ─── PALETTE ─────────────────────────────────────────────────────────────────
const C = {
  dark:    "0D0F1A",   // deep navy-black
  navy:    "121629",   // slide bg
  card:    "1A1F38",   // card bg
  accent:  "6C63FF",   // violet
  teal:    "00D4AA",   // teal
  gold:    "F7B731",   // gold
  slate:   "B0B8D8",   // muted text
  white:   "FFFFFF",
  light:   "E8ECFF",
};

const makeShadow = () => ({ type: "outer", blur: 18, offset: 6, angle: 135, color: "000000", opacity: 0.35 });
const makeShadowSm = () => ({ type: "outer", blur: 8, offset: 3, angle: 135, color: "000000", opacity: 0.25 });

// ═══════════════════════════════════════════════════════════════════════════════
// SLIDE 1 — TITLE
// ═══════════════════════════════════════════════════════════════════════════════
{
  const s = pres.addSlide();
  s.background = { color: C.dark };

  // Decorative geometric shapes (morph anchor pieces)
  s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 10, h: 5.625, fill: { color: C.dark }, line: { color: C.dark } });

  // Big circle accent — top right
  s.addShape(pres.shapes.OVAL, {
    x: 7.2, y: -1.2, w: 4.5, h: 4.5,
    fill: { color: C.accent, transparency: 80 },
    line: { color: C.accent, width: 1, transparency: 50 },
    shadow: makeShadow(),
  });
  // Small teal circle — bottom left
  s.addShape(pres.shapes.OVAL, {
    x: -0.8, y: 3.8, w: 2.8, h: 2.8,
    fill: { color: C.teal, transparency: 82 },
    line: { color: C.teal, width: 1, transparency: 60 },
  });

  // Accent bar left
  s.addShape(pres.shapes.RECTANGLE, {
    x: 0.65, y: 1.45, w: 0.08, h: 2.5,
    fill: { color: C.accent }, line: { color: C.accent },
  });

  // App name
  s.addText("MathCalcu", {
    x: 0.85, y: 1.3, w: 8, h: 1.0,
    fontSize: 52, bold: true, fontFace: "Calibri",
    color: C.white, margin: 0,
  });

  // Tagline
  s.addText("Advanced Calculus & Algebra System", {
    x: 0.85, y: 2.35, w: 7.5, h: 0.55,
    fontSize: 20, fontFace: "Calibri",
    color: C.teal, margin: 0,
  });

  // Sub-description
  s.addText("Flutter · Multi-platform · Agile-driven Development", {
    x: 0.85, y: 2.92, w: 7.5, h: 0.4,
    fontSize: 13, fontFace: "Calibri",
    color: C.slate, margin: 0,
  });

  // Divider
  s.addShape(pres.shapes.LINE, {
    x: 0.85, y: 3.45, w: 7.5, h: 0,
    line: { color: C.accent, width: 1, transparency: 60 },
  });

  // Bottom row: 3 stats
  const stats = [
    { val: "10+", lbl: "Math Modules" },
    { val: "5", lbl: "Agile Sprints" },
    { val: "Multi", lbl: "Platform" },
  ];
  stats.forEach((st, i) => {
    const bx = 0.85 + i * 2.8;
    s.addText(st.val, { x: bx, y: 3.7, w: 2.6, h: 0.55, fontSize: 26, bold: true, color: C.gold, fontFace: "Calibri", margin: 0 });
    s.addText(st.lbl, { x: bx, y: 4.22, w: 2.6, h: 0.35, fontSize: 11, color: C.slate, fontFace: "Calibri", margin: 0 });
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// SLIDE 2 — SYSTEM OVERVIEW
// ═══════════════════════════════════════════════════════════════════════════════
{
  const s = pres.addSlide();
  s.background = { color: C.navy };

  // Top accent bar
  s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 10, h: 0.07, fill: { color: C.accent }, line: { color: C.accent } });

  s.addText("System Overview", { x: 0.55, y: 0.2, w: 8, h: 0.6, fontSize: 28, bold: true, color: C.white, fontFace: "Calibri", margin: 0 });
  s.addText("MathCalcu is a Flutter-based mobile & web math solver built using the Agile methodology.", {
    x: 0.55, y: 0.82, w: 8.8, h: 0.45, fontSize: 13, color: C.slate, fontFace: "Calibri", margin: 0,
  });

  // 4 overview cards
  const cards = [
    { icon: "🏗️", title: "Architecture", desc: "Clean modular structure with separate solvers, UI layers, and shared widgets per math domain." },
    { icon: "📱", title: "Cross-Platform", desc: "Targets Android, iOS, Web, macOS, Linux & Windows from a single Flutter codebase." },
    { icon: "🔢", title: "Math Engine", desc: "Custom parsers, tokenizers & step-by-step solvers for calculus, algebra & analytic geometry." },
    { icon: "⚡", title: "Agile Process", desc: "Developed in iterative sprints with backlog grooming, sprint reviews & continuous delivery." },
  ];

  cards.forEach((c, i) => {
    const col = i % 2;
    const row = Math.floor(i / 2);
    const bx = 0.4 + col * 4.85;
    const by = 1.5 + row * 1.82;

    s.addShape(pres.shapes.RECTANGLE, {
      x: bx, y: by, w: 4.6, h: 1.6,
      fill: { color: C.card }, line: { color: C.accent, transparency: 75 },
      shadow: makeShadowSm(),
    });
    // left accent strip
    s.addShape(pres.shapes.RECTANGLE, {
      x: bx, y: by, w: 0.065, h: 1.6,
      fill: { color: C.accent }, line: { color: C.accent },
    });
    s.addText(c.icon + "  " + c.title, {
      x: bx + 0.18, y: by + 0.18, w: 4.2, h: 0.45,
      fontSize: 14, bold: true, color: C.white, fontFace: "Calibri", margin: 0,
    });
    s.addText(c.desc, {
      x: bx + 0.18, y: by + 0.65, w: 4.2, h: 0.8,
      fontSize: 11, color: C.slate, fontFace: "Calibri", margin: 0,
    });
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// SLIDE 3 — AGILE MODEL
// ═══════════════════════════════════════════════════════════════════════════════
{
  const s = pres.addSlide();
  s.background = { color: C.navy };

  s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 10, h: 0.07, fill: { color: C.gold }, line: { color: C.gold } });
  s.addText("Agile Development Model", { x: 0.55, y: 0.2, w: 8, h: 0.6, fontSize: 28, bold: true, color: C.white, fontFace: "Calibri", margin: 0 });

  // Agile cycle — horizontal pipeline
  const phases = [
    { label: "Plan", sub: "Backlog & Sprint Planning", color: C.accent },
    { label: "Design", sub: "UI/UX & Solver Architecture", color: "8B5CF6" },
    { label: "Develop", sub: "Flutter Modules & Engines", color: C.teal },
    { label: "Test", sub: "Unit & Widget Testing", color: C.gold },
    { label: "Review", sub: "Sprint Demo & Retrospective", color: "F06292" },
  ];

  phases.forEach((ph, i) => {
    const bx = 0.3 + i * 1.88;
    // Circle
    s.addShape(pres.shapes.OVAL, {
      x: bx + 0.32, y: 1.1, w: 1.2, h: 1.2,
      fill: { color: ph.color, transparency: 20 },
      line: { color: ph.color, width: 2 },
      shadow: makeShadowSm(),
    });
    s.addText(ph.label, {
      x: bx + 0.32, y: 1.32, w: 1.2, h: 0.55,
      fontSize: 12, bold: true, color: C.white, fontFace: "Calibri", align: "center", valign: "middle", margin: 0,
    });
    // Arrow
    if (i < phases.length - 1) {
      s.addShape(pres.shapes.LINE, {
        x: bx + 1.6, y: 1.69, w: 0.58, h: 0,
        line: { color: C.slate, width: 1.5, endArrowType: "triangle" },
      });
    }
    // Label below
    s.addText(ph.sub, {
      x: bx, y: 2.42, w: 1.85, h: 0.55,
      fontSize: 9.5, color: C.slate, fontFace: "Calibri", align: "center", margin: 0,
    });
  });

  // Sprint timeline table
  s.addText("Sprint Timeline", { x: 0.55, y: 3.15, w: 8, h: 0.38, fontSize: 14, bold: true, color: C.teal, fontFace: "Calibri", margin: 0 });

  const sprints = [
    ["Sprint 1", "Core engine + Slope & Distance modules"],
    ["Sprint 2", "Circles, Y-Intercept, Midpoint modules"],
    ["Sprint 3", "Inequalities (7 types) + Graph visualizations"],
    ["Sprint 4", "Finals modules: Derivatives, Limits, Calculus"],
    ["Sprint 5", "Polish, cross-platform build, CI/CD"],
  ];
  sprints.forEach((row, ri) => {
    const by = 3.6 + ri * 0.37;
    const bg = ri % 2 === 0 ? C.card : C.dark;
    s.addShape(pres.shapes.RECTANGLE, { x: 0.55, y: by, w: 2.4, h: 0.35, fill: { color: C.accent, transparency: 70 }, line: { color: C.accent, transparency: 70 } });
    s.addShape(pres.shapes.RECTANGLE, { x: 2.95, y: by, w: 6.5, h: 0.35, fill: { color: bg }, line: { color: bg } });
    s.addText(row[0], { x: 0.55, y: by, w: 2.4, h: 0.35, fontSize: 11, bold: true, color: C.white, fontFace: "Calibri", align: "center", valign: "middle", margin: 0 });
    s.addText(row[1], { x: 3.05, y: by, w: 6.3, h: 0.35, fontSize: 11, color: C.slate, fontFace: "Calibri", valign: "middle", margin: 0 });
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// SLIDE 4 — MATH MODULES
// ═══════════════════════════════════════════════════════════════════════════════
{
  const s = pres.addSlide();
  s.background = { color: C.navy };

  s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 10, h: 0.07, fill: { color: C.teal }, line: { color: C.teal } });
  s.addText("Math Modules", { x: 0.55, y: 0.2, w: 8, h: 0.6, fontSize: 28, bold: true, color: C.white, fontFace: "Calibri", margin: 0 });
  s.addText("10+ specialized solvers, each with its own engine, UI, and step-by-step walkthrough.", {
    x: 0.55, y: 0.82, w: 8.8, h: 0.38, fontSize: 12, color: C.slate, fontFace: "Calibri", margin: 0,
  });

  const modules = [
    { cat: "Algebra / Geometry", color: C.accent, items: ["Slope", "Two-Point Slope", "Y-Intercept & Slope-Intercept", "Point-Slope Form", "Midpoint", "Distance", "Circles (Center, Radius)"] },
    { cat: "Inequalities", color: C.teal, items: ["Simple", "Strict", "Non-Strict", "Continued", "Quadratic", "Rational", "Radical", "Absolute Value"] },
    { cat: "Calculus (Finals)", color: C.gold, items: ["Derivatives (step-by-step)", "Limits → ∞", "Limits by Substitution", "Limits by Factoring", "Limits by LCD", "Limits by Conjugate", "Slope via Derivatives"] },
  ];

  modules.forEach((m, mi) => {
    const bx = 0.25 + mi * 3.25;
    // Header card
    s.addShape(pres.shapes.RECTANGLE, { x: bx, y: 1.35, w: 3.05, h: 0.48, fill: { color: m.color, transparency: 15 }, line: { color: m.color }, shadow: makeShadowSm() });
    s.addText(m.cat, { x: bx, y: 1.35, w: 3.05, h: 0.48, fontSize: 11, bold: true, color: C.white, fontFace: "Calibri", align: "center", valign: "middle", margin: 0 });

    m.items.forEach((item, ii) => {
      const iy = 1.9 + ii * 0.42;
      s.addShape(pres.shapes.RECTANGLE, { x: bx, y: iy, w: 3.05, h: 0.38, fill: { color: C.card }, line: { color: m.color, transparency: 82 } });
      s.addShape(pres.shapes.OVAL, { x: bx + 0.12, y: iy + 0.12, w: 0.13, h: 0.13, fill: { color: m.color }, line: { color: m.color } });
      s.addText(item, { x: bx + 0.32, y: iy, w: 2.65, h: 0.38, fontSize: 10, color: C.slate, fontFace: "Calibri", valign: "middle", margin: 0 });
    });
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// SLIDE 5 — TECHNICAL ARCHITECTURE
// ═══════════════════════════════════════════════════════════════════════════════
{
  const s = pres.addSlide();
  s.background = { color: C.navy };

  s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 10, h: 0.07, fill: { color: "8B5CF6" }, line: { color: "8B5CF6" } });
  s.addText("Technical Architecture", { x: 0.55, y: 0.2, w: 8, h: 0.6, fontSize: 28, bold: true, color: C.white, fontFace: "Calibri", margin: 0 });

  // Layer diagram — stacked
  const layers = [
    { label: "UI Layer", sub: "Screens · Widgets · Cards · Animations", color: C.accent, y: 1.1 },
    { label: "Module Layer", sub: "Domain modules (slope, calculus, circles…)", color: "8B5CF6", y: 1.85 },
    { label: "Solver / Engine Layer", sub: "Parsers · Tokenizers · Step generators · Math engines", color: C.teal, y: 2.6 },
    { label: "Core / Shared Layer", sub: "BaseEquation · SolveResult · StepModel · Router", color: C.gold, y: 3.35 },
    { label: "Platform Layer", sub: "Android · iOS · Web · macOS · Windows · Linux", color: "F06292", y: 4.1 },
  ];

  layers.forEach((l) => {
    s.addShape(pres.shapes.RECTANGLE, {
      x: 1.2, y: l.y, w: 7.6, h: 0.62,
      fill: { color: l.color, transparency: 22 },
      line: { color: l.color, width: 1.5 },
      shadow: makeShadowSm(),
    });
    s.addText(l.label, { x: 1.4, y: l.y + 0.04, w: 3.2, h: 0.32, fontSize: 13, bold: true, color: C.white, fontFace: "Calibri", margin: 0 });
    s.addText(l.sub, { x: 1.4, y: l.y + 0.32, w: 7.1, h: 0.24, fontSize: 10, color: C.slate, fontFace: "Calibri", margin: 0 });

    // Color swatch strip right
    s.addShape(pres.shapes.RECTANGLE, { x: 8.68, y: l.y, w: 0.12, h: 0.62, fill: { color: l.color }, line: { color: l.color } });
  });

  // Down arrows between layers
  for (let i = 0; i < 4; i++) {
    s.addShape(pres.shapes.LINE, {
      x: 4.95, y: 1.72 + i * 0.75, w: 0, h: 0.13,
      line: { color: C.slate, width: 1.5, endArrowType: "triangle" },
    });
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SLIDE 6 — FEATURES & HIGHLIGHTS
// ═══════════════════════════════════════════════════════════════════════════════
{
  const s = pres.addSlide();
  s.background = { color: C.navy };

  s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 10, h: 0.07, fill: { color: C.gold }, line: { color: C.gold } });
  s.addText("Features & Highlights", { x: 0.55, y: 0.2, w: 8, h: 0.6, fontSize: 28, bold: true, color: C.white, fontFace: "Calibri", margin: 0 });

  // Left column: feature list
  const features = [
    { icon: "📐", title: "Step-by-Step Solutions", desc: "Every module breaks down computations into clear, readable steps with LaTeX-ready math display." },
    { icon: "📊", title: "Graph Visualizations", desc: "Interactive graphs for slopes, inequalities, circles, distance, and midpoint using custom Flutter painters." },
    { icon: "🧩", title: "Modular Solver Design", desc: "Each math topic lives in its own folder with isolated solver, UI, and theme — no coupling." },
    { icon: "🌐", title: "Cross-Platform Build", desc: "CI/CD-ready GitHub Actions workflow for Android APK and Web deployment from a single codebase." },
  ];

  features.forEach((f, i) => {
    const by = 1.05 + i * 1.13;
    s.addShape(pres.shapes.RECTANGLE, {
      x: 0.4, y: by, w: 5.6, h: 0.98,
      fill: { color: C.card }, line: { color: C.accent, transparency: 78 },
      shadow: makeShadowSm(),
    });
    s.addText(f.icon + "  " + f.title, { x: 0.6, y: by + 0.1, w: 5.2, h: 0.36, fontSize: 13, bold: true, color: C.white, fontFace: "Calibri", margin: 0 });
    s.addText(f.desc, { x: 0.6, y: by + 0.46, w: 5.2, h: 0.45, fontSize: 10.5, color: C.slate, fontFace: "Calibri", margin: 0 });
  });

  // Right column: tech stack
  s.addShape(pres.shapes.RECTANGLE, {
    x: 6.3, y: 1.05, w: 3.35, h: 4.43,
    fill: { color: C.card }, line: { color: C.teal, transparency: 65 },
    shadow: makeShadowSm(),
  });
  s.addText("Tech Stack", { x: 6.5, y: 1.18, w: 3.0, h: 0.4, fontSize: 13, bold: true, color: C.teal, fontFace: "Calibri", margin: 0 });

  const stack = [
    ["Framework", "Flutter 3.x"],
    ["Language", "Dart"],
    ["State Mgmt", "StatefulWidgets"],
    ["Math Display", "flutter_math_fork"],
    ["Routing", "go_router"],
    ["Storage", "shared_prefs"],
    ["Build CI", "GitHub Actions"],
    ["Platforms", "6 targets"],
  ];

  stack.forEach(([k, v], si) => {
    const sy = 1.7 + si * 0.47;
    s.addText(k, { x: 6.5, y: sy, w: 1.55, h: 0.38, fontSize: 10, color: C.slate, fontFace: "Calibri", valign: "middle", margin: 0 });
    s.addText(v, { x: 8.05, y: sy, w: 1.45, h: 0.38, fontSize: 10, bold: true, color: C.gold, fontFace: "Calibri", valign: "middle", margin: 0 });
    if (si < stack.length - 1) {
      s.addShape(pres.shapes.LINE, { x: 6.5, y: sy + 0.38, w: 2.9, h: 0, line: { color: C.accent, width: 0.5, transparency: 70 } });
    }
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// SLIDE 7 — TEAM & AGILE ROLES
// ═══════════════════════════════════════════════════════════════════════════════
{
  const s = pres.addSlide();
  s.background = { color: C.navy };

  s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 10, h: 0.07, fill: { color: "F06292" }, line: { color: "F06292" } });
  s.addText("Team & Agile Roles", { x: 0.55, y: 0.2, w: 8, h: 0.6, fontSize: 28, bold: true, color: C.white, fontFace: "Calibri", margin: 0 });

  // Agile roles
  const roles = [
    { role: "Product Owner", resp: "Defines math module requirements and prioritizes the backlog", color: C.gold },
    { role: "Scrum Master", resp: "Facilitates sprint ceremonies, removes blockers, tracks velocity", color: "F06292" },
    { role: "Flutter Dev — Joashua", resp: "Calculus modules: Derivatives, Limits (4 methods), Slope via Derivatives", color: C.teal },
    { role: "Flutter Dev — Core Team", resp: "Algebra/Geometry modules, Inequalities, UI framework, routing", color: C.accent },
    { role: "QA / Testing", resp: "Unit tests for solvers (conjugate, substitution), widget test coverage", color: "8B5CF6" },
  ];

  roles.forEach((r, i) => {
    const by = 1.1 + i * 0.88;
    s.addShape(pres.shapes.RECTANGLE, {
      x: 0.4, y: by, w: 9.2, h: 0.74,
      fill: { color: C.card }, line: { color: r.color, transparency: 72 },
      shadow: makeShadowSm(),
    });
    s.addShape(pres.shapes.RECTANGLE, { x: 0.4, y: by, w: 0.07, h: 0.74, fill: { color: r.color }, line: { color: r.color } });

    // Role badge
    s.addShape(pres.shapes.ROUNDED_RECTANGLE, { x: 0.6, y: by + 0.12, w: 2.6, h: 0.35, fill: { color: r.color, transparency: 30 }, line: { color: r.color, transparency: 40 }, rectRadius: 0.05 });
    s.addText(r.role, { x: 0.6, y: by + 0.12, w: 2.6, h: 0.35, fontSize: 10.5, bold: true, color: C.white, fontFace: "Calibri", align: "center", valign: "middle", margin: 0 });
    s.addText(r.resp, { x: 3.35, y: by + 0.12, w: 6.1, h: 0.5, fontSize: 11, color: C.slate, fontFace: "Calibri", valign: "middle", margin: 0 });
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// SLIDE 8 — CONCLUSION
// ═══════════════════════════════════════════════════════════════════════════════
{
  const s = pres.addSlide();
  s.background = { color: C.dark };

  // Decorative shapes
  s.addShape(pres.shapes.OVAL, { x: -1, y: 3.5, w: 4, h: 4, fill: { color: C.accent, transparency: 85 }, line: { color: C.accent, transparency: 70 } });
  s.addShape(pres.shapes.OVAL, { x: 8.2, y: -0.8, w: 3.2, h: 3.2, fill: { color: C.teal, transparency: 85 }, line: { color: C.teal, transparency: 70 } });

  s.addText("🎯", { x: 3.8, y: 0.6, w: 2.4, h: 0.9, fontSize: 40, align: "center", margin: 0 });

  s.addText("MathCalcu", { x: 1, y: 1.45, w: 8, h: 0.85, fontSize: 44, bold: true, color: C.white, fontFace: "Calibri", align: "center", margin: 0 });

  s.addText("A complete, Agile-built math solver\nthat empowers students with clear, step-by-step solutions.", {
    x: 1.2, y: 2.3, w: 7.6, h: 0.9, fontSize: 15, color: C.slate, fontFace: "Calibri", align: "center", margin: 0,
  });

  // 3 key takeaways
  const pts = [
    { label: "Modular & Scalable", color: C.accent },
    { label: "Agile Delivered", color: C.gold },
    { label: "Cross-Platform Ready", color: C.teal },
  ];
  pts.forEach((p, i) => {
    const bx = 1.0 + i * 2.78;
    s.addShape(pres.shapes.RECTANGLE, {
      x: bx, y: 3.55, w: 2.6, h: 0.6,
      fill: { color: p.color, transparency: 20 },
      line: { color: p.color },
      shadow: makeShadowSm(),
    });
    s.addText(p.label, { x: bx, y: 3.55, w: 2.6, h: 0.6, fontSize: 12, bold: true, color: C.white, fontFace: "Calibri", align: "center", valign: "middle", margin: 0 });
  });

  s.addText("Built with Flutter · Powered by Agile · Made for Students", {
    x: 1, y: 4.55, w: 8, h: 0.4, fontSize: 11, color: C.slate, fontFace: "Calibri", align: "center", margin: 0,
  });
}

// ─── WRITE ───────────────────────────────────────────────────────────────────
pres.writeFile({ fileName: "C:\\ppt\\MathCalcu_System.pptx" })
  .then(() => console.log("✅ PPTX created: C:\\ppt\\MathCalcu_System.pptx"))
  .catch(e => { console.error(e); process.exit(1); });