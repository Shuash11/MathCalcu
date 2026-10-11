// ─────────────────────────────────────────────────────────────
// TRIG IDENTITY — PreCalc. Proof-step outline for common identities
// + numeric verification. e.g. 'prove sin^2+cos^2=1'. Never throws.
// ─────────────────────────────────────────────────────────────

import 'dart:math' as math;

import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';

class TrigIdentityEquation extends BaseEquation {
  @override
  final String rawInput;
  String? _error;

  TrigIdentityEquation(this.rawInput);

  static const _known = <String, List<String>>{
    'pythagorean': [
      'Start with sin²θ + cos²θ on the unit circle (x = cos θ, y = sin θ).',
      'x² + y² = 1 for every point on the unit circle.',
      'Therefore sin²θ + cos²θ = 1. ∎',
    ],
    'tangent': [
      'Write tan θ as sin θ / cos θ.',
      'sin²θ + cos²θ = 1 (Pythagorean).',
      'Divide by cos²θ: tan²θ + 1 = sec²θ. ∎',
    ],
    'double-angle-sin': [
      'Rotate by θ twice: sin(α + β) = sin α cos β + cos α sin β.',
      'Set α = β = θ.',
      'sin 2θ = 2 sin θ cos θ. ∎',
    ],
    'double-angle-cos': [
      'cos(α + β) = cos α cos β − sin α sin β.',
      'Set α = β = θ: cos 2θ = cos²θ − sin²θ.',
      'Forms: 2cos²θ − 1, or 1 − 2sin²θ. ∎',
    ],
    'reciprocal': [
      'Definitions: sec θ = 1/cos θ, csc θ = 1/sin θ, cot θ = 1/tan θ.',
      'Substitute and simplify each side.',
      'Both sides match. ∎',
    ],
    'quotient': [
      'Write tan θ = sin θ / cos θ and cot θ = cos θ / sin θ.',
      'Substitute and cancel common factors.',
      'Both sides match. ∎',
    ],
  };

  /// LaTeX for the math-bearing outline steps (null = deliberate prose step).
  static const _texByTemplate = <String, List<String?>>{
    'pythagorean': [
      r'x = \cos\theta,\quad y = \sin\theta',
      r'x^{2} + y^{2} = 1',
      r'\sin^{2}\theta + \cos^{2}\theta = 1',
    ],
    'tangent': [
      r'\tan\theta = \frac{\sin\theta}{\cos\theta}',
      r'\sin^{2}\theta + \cos^{2}\theta = 1',
      r'\tan^{2}\theta + 1 = \sec^{2}\theta',
    ],
    'double-angle-sin': [
      r'\sin(\alpha + \beta) = \sin\alpha\cos\beta + \cos\alpha\sin\beta',
      r'\alpha = \beta = \theta',
      r'\sin 2\theta = 2\sin\theta\cos\theta',
    ],
    'double-angle-cos': [
      r'\cos(\alpha + \beta) = \cos\alpha\cos\beta - \sin\alpha\sin\beta',
      r'\cos 2\theta = \cos^{2}\theta - \sin^{2}\theta',
      r'\cos 2\theta = 2\cos^{2}\theta - 1 = 1 - 2\sin^{2}\theta',
    ],
    'reciprocal': [
      r'\sec\theta = \frac{1}{\cos\theta},\quad \csc\theta = \frac{1}{\sin\theta},\quad \cot\theta = \frac{1}{\tan\theta}',
      null,
      null,
    ],
    'quotient': [
      r'\tan\theta = \frac{\sin\theta}{\cos\theta},\quad \cot\theta = \frac{\cos\theta}{\sin\theta}',
      null,
      null,
    ],
  };

  String _norm() => rawInput
      .toLowerCase()
      .replaceAll(' ', '')
      .replaceAll('²', '^2')
      .replaceAll('θ', 't')
      .replaceAll('prove:', '')
      .replaceAll('prove', '');

  /// Normalisation for *numeric evaluation*: unlike [_norm] it KEEPS spaces so
  /// the implicit-multiplication / function-argument structure survives
  /// (`sin 2x` != `sin2x` != `sin x`), and it maps every spelling of the angle
  /// variable (`θ`, `x`, `t`) onto the canonical symbol `x`.
  String _evalInput() => rawInput
      .toLowerCase()
      .replaceAll('²', '^2')
      .replaceAll('θ', 'x')
      .replaceAll('prove:', '')
      .replaceAll('prove', '');

  static const _funcs = {'sin', 'cos', 'tan', 'sec', 'csc', 'cot'};

  /// Exponent ceiling for `^` anywhere in the grammar. Grade-11 identities use
  /// powers <= 3 (sin^2, cos^2, tan^2, sin^3); anything beyond [_maxExponent]
  /// is the crafted-tolerance evasion class — a bounded spike term
  /// (e.g. (sin x - 0.6)^40) stays under 1e-6 at every sampled angle, so
  /// numeric sampling alone cannot reject it. Such input is rejected BEFORE
  /// sampling with the honest Unsupported message. Checked per `^` site, so
  /// NESTED powers (e.g. ((sin x)^5)^5, effective exponent 25) are NOT caught
  /// by the cap — see the RESIDUAL note at the sampler.
  static const _maxExponent = 19;

  String? _match() {
    final t = _norm();
    if (t.contains('sin^2') && t.contains('cos^2') && t.contains('=1')) {
      return 'pythagorean';
    }
    if (t.contains('tan^2') && t.contains('sec^2')) return 'tangent';
    if (t.contains('sin2') && t.contains('2sin')) return 'double-angle-sin';
    if (t.contains('cos2')) return 'double-angle-cos';
    if (t.contains('sec') || t.contains('csc') || t.contains('cot')) {
      return 'reciprocal';
    }
    if (t.contains('tan') && t.contains('sin') && t.contains('cos')) {
      return 'quotient';
    }
    return null;
  }

  /// `math.pow` gated by the exponent ceiling: an evaluated exponent above
  /// [_maxExponent] is a scope violation (same channel as the bare-variable
  /// gate), so the caller rejects the input before sampling. Violations is
  /// non-null exactly in the gate pass; in sampling passes it throws into the
  /// existing catch, which already means 'not evaluable here'.
  double _powCapped(double base, double exp, {List<String>? violations}) {
    if (violations != null && exp.abs() > _maxExponent) {
      violations.add(
        'power exponent ${exp.abs()} exceeds the supported maximum '
        '($_maxExponent)',
      );
      throw StateError('power exponent above $_maxExponent');
    }
    return math.pow(base, exp).toDouble();
  }

  /// Evaluates [expr] at angle [th]. When [violations] is non-null it collects
  /// scope violations: a variable consumed while [argDepth] == 0 is a BARE
  /// variable — one outside every trig function's argument — i.e. a
  /// polynomial/rational term in x; and any power operation whose EVALUATED
  /// exponent exceeds [_maxExponent] (grade-11 identities use powers <= 3;
  /// high powers are the crafted-tolerance evasion class). The gate reuses
  /// this same parser so the checked grammar and the evaluated grammar can
  /// never diverge. When [funcsSeen] is non-null, every trig FUNCTION token
  /// encountered is recorded in it, so callers can branch on the parsed token
  /// stream (e.g. the tan/sec/cot zone-skip) instead of a raw substring of
  /// the input.
  double? _evalSide(
    String expr,
    double th, {
    List<String>? violations,
    Set<String>? funcsSeen,
  }) {
    // Recursive-descent evaluator for sin/cos/tan/sec/csc/cot over the angle
    // variable, with numbers, + - * /, ^ and implicit multiplication.
    final toks = RegExp(r'sin|cos|tan|sec|csc|cot|x|t|\d+(?:\.\d+)?|[+\-*/^()]')
        .allMatches(expr)
        .map((m) => m.group(0)!)
        .toList();
    try {
      var pos = 0;
      var argDepth = 0;
      bool atEnd() => pos >= toks.length;
      String peek() => atEnd() ? '' : toks[pos];
      bool isNum(String s) => s.isNotEmpty && RegExp(r'\d').hasMatch(s[0]);
      bool startsAtom(String s) =>
          s == '(' || s == 'x' || s == 't' || isNum(s) || _funcs.contains(s);

      double applyFunc(String f, double a) {
        switch (f) {
          case 'sin':
            return math.sin(a);
          case 'cos':
            return math.cos(a);
          case 'tan':
            return math.tan(a);
          case 'sec':
            return 1 / math.cos(a);
          case 'csc':
            return 1 / math.sin(a);
          default: // cot
            return 1 / math.tan(a);
        }
      }

      late double Function() parseExpr,
          parseTerm,
          parseUnary,
          parsePower,
          parsePrimary,
          parseArgAtom;

      // Argument of a trig function: the tightest following product of
      // numbers, the angle variable and parenthesised groups (implicit *).
      // Nothing usable follows (e.g. `sin^2`, `sec`, `cot`) -> the implicit
      // argument is the angle itself.
      bool startsArg(String s) => s == '(' || s == 'x' || s == 't' || isNum(s);
      double parseFuncArg() {
        if (!startsArg(peek())) return th;
        argDepth++;
        try {
          var v = parseArgAtom();
          while (startsArg(peek())) {
            v *= parseArgAtom();
          }
          return v;
        } finally {
          argDepth--;
        }
      }

      parseArgAtom = () {
        if (peek() == '(') {
          pos++;
          final v = parseExpr();
          if (peek() == ')') pos++;
          return v;
        }
        if (peek() == 'x' || peek() == 't') {
          pos++;
          return th;
        }
        final n = double.parse(toks[pos++]);
        if (peek() == '^') {
          pos++;
          return math.pow(n, parsePower()).toDouble();
        }
        return n;
      };

      parsePrimary = () {
        if (peek() == '(') {
          pos++;
          final v = parseExpr();
          if (peek() == ')') pos++;
          return v;
        }
        if (_funcs.contains(peek())) {
          final f = toks[pos++];
          funcsSeen?.add(f);
          var exp = 1.0;
          if (peek() == '^') {
            pos++;
            exp = parsePower();
          }
          final base = applyFunc(f, parseFuncArg());
          return exp == 1.0
              ? base
              : _powCapped(base, exp, violations: violations);
        }
        if (peek() == 'x' || peek() == 't') {
          pos++;
          if (argDepth == 0) {
            violations?.add('bare variable outside a trig argument');
            throw StateError('bare variable outside a trig argument');
          }
          return th;
        }
        if (isNum(peek())) {
          return double.parse(toks[pos++]);
        }
        throw StateError('unexpected token "${peek()}"');
      };

      parsePower = () {
        final v = parsePrimary();
        if (peek() == '^') {
          pos++;
          return _powCapped(v, parseUnary(), violations: violations);
        }
        return v;
      };

      parseUnary = () {
        if (peek() == '-') {
          pos++;
          return -parseUnary();
        }
        if (peek() == '+') {
          pos++;
          return parseUnary();
        }
        return parsePower();
      };

      parseTerm = () {
        var v = parseUnary();
        while (!atEnd()) {
          final t = peek();
          if (t == '*') {
            pos++;
            v *= parseUnary();
          } else if (t == '/') {
            pos++;
            v /= parseUnary();
          } else if (startsAtom(t)) {
            v *= parseUnary(); // implicit multiplication: 2x, 2 sin x, ...
          } else {
            break;
          }
        }
        return v;
      };

      parseExpr = () {
        var v = parseTerm();
        while (!atEnd() && (peek() == '+' || peek() == '-')) {
          final op = toks[pos++];
          final r = parseTerm();
          v = op == '+' ? v + r : v - r;
        }
        return v;
      };

      final value = parseExpr();
      if (!atEnd()) return null; // unparsed trailing tokens -> not evaluable
      return value;
    } catch (_) {
      return null;
    }
  }

  /// Deterministic, input-dependent sample angles for the numeric identity
  /// check. Deriving the angles from a hash of the *whole* normalised input
  /// (both sides) — instead of a fixed table — closes the fixed-sample evasion
  /// class: a crafted term (e.g. a degree-5 polynomial whose roots are the old
  /// fixed samples) changes the hash, hence changes the angles it would have to
  /// vanish at, so no fixed-root construction can be authored against the
  /// sampler. It is a pure function of the input, so results stay deterministic
  /// and test-stable.
  List<double> _sampleAngles() {
    var h = _hash(_evalInput());
    final angles = <double>[];
    for (var i = 0; i < 5; i++) {
      h = (h * 48271 + 11) % 2147483647; // Lehmer LCG (product < 2^53 on web)
      angles.add(_mapAngle(h / 2147483647.0));
    }
    return angles;
  }

  /// Rolling hash kept below 2^31 so it is identical on the VM and on web
  /// (dart2js doubles): the sampler must be deterministic everywhere.
  static int _hash(String s) {
    var h = 0;
    for (final c in s.codeUnits) {
      h = (h * 131 + c) % 2147483647;
    }
    return h;
  }

  /// Map t in [0,1) onto [0.20,1.45] u [1.70,2.90]: a spread of angles that
  /// deliberately skips the (1.45,1.70) neighbourhood of pi/2, where tan/sec/cot
  /// blow up and catastrophic cancellation could falsely reject a TRUE identity.
  static double _mapAngle(double t) {
    const w1 = 1.25; // width of [0.20, 1.45]
    final u = t * 2.45; // w1 + width of [1.70, 2.90]
    return u < w1 ? 0.20 + u : 1.70 + (u - w1);
  }

  /// A SECOND, differently-derived sample set used alongside [_sampleAngles].
  /// Both are deterministic functions of the input, but with independent
  /// roundings, so a spurious term crafted (or coincidentally small) at one
  /// set must ALSO be small at the other to pass. A genuine identity is
  /// identical everywhere, so extra samples cost it nothing.
  static List<double> _auditAngles(String normed) {
    // Independent LCG parameters (different multiplier and modulus).
    var h = 7919;
    for (final c in normed.codeUnits) {
      h = (h * 48271 + c) % 2147483629;
    }
    final out = <double>[];
    for (var i = 0; i < 5; i++) {
      h = (h * 48271) % 2147483629;
      out.add(_mapAngle(h / 2147483629 * 0.999 + 0.0005));
    }
    return out;
  }

  @override
  bool validate() {
    final empty = FieldValidators.notEmpty(
      rawInput,
      example: 'prove: sin^2 + cos^2 = 1',
    );
    if (empty != null) {
      _error = empty;
      return false;
    }
    if (!rawInput.contains('=')) {
      _error = 'Write an identity with = — e.g. prove: sin^2 + cos^2 = 1.';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    if (!rawInput.contains('=')) {
      return SolveResult.error(_error ?? 'Write an identity with = sign.');
    }
    final sides = _evalInput().split('=');
    if (sides.length != 2 || sides.any((s) => s.trim().isEmpty)) {
      return SolveResult.error('Need LHS = RHS — e.g. sin^2+cos^2 = 1.');
    }
    // SCOPE GATE (Failure 2): every occurrence of the angle variable must sit
    // inside a trig function's argument. A bare variable — one outside any
    // sin/cos/tan/sec/csc/cot argument — is a polynomial/rational term in x,
    // which this evaluator's algebraic grammar cannot reason about honestly,
    // so such input is rejected BEFORE any sampling. This is not merely a
    // sampler-hardening measure: the parser is shared with the numeric check,
    // so no input that passes the gate can contain a term the evaluator only
    // pretends to understand.
    // EXPONENT CAP (Failure 3): a power whose EVALUATED exponent exceeds
    // [_maxExponent] is rejected the same way — high powers are the crafted
    // tolerance-evasion class (0 = (sin x - 0.6)^40 stays under 1e-6 at every
    // sample), and an exponent containing the bare variable is already caught
    // by the bare-variable rule above, so only constant exponents reach here.
    const unsupported =
        'Unsupported — only trig expressions in one angle are supported; '
        'a bare variable outside sin/cos/tan/sec/csc/cot (e.g. a polynomial '
        'term like (x-1)^2) cannot be verified, and exponents above '
        '$_maxExponent (e.g. (sin x)^40) are not verifiable numerically.';
    final violations = <String>[];
    // Token-based zone-skip inputs (Failure 1): the parsed function tokens of
    // each side, collected in the same gate pass — so 'tan x * 0' (harmless
    // tan) no longer disables the pi-zone defense via a raw substring match.
    final sideFuncs = List<Set<String>>.generate(
      sides.length,
      (_) => <String>{},
    );
    for (var i = 0; i < sides.length; i++) {
      _evalSide(sides[i], 0.3, violations: violations, funcsSeen: sideFuncs[i]);
    }
    if (violations.isNotEmpty) {
      return SolveResult.error(unsupported);
    }
    // Numeric check at input-derived sample angles (see [_sampleAngles]).
    var okCount = 0;
    var checked = 0;
    // A variable-dependent pair needs samples that a crafted term cannot have
    // been tuned against. The LCG samples are input-derived (already hostile
    // to pre-authoring), and we ADD a second, differently-derived set so a
    // spurious term must vanish on BOTH sets to pass — while a true identity
    // (identical functions, not tuned) matches everywhere by construction.
    var angles = [..._sampleAngles(), ..._auditAngles(_evalInput())];
    // sin-negative-zone samples (pi, 3pi/2): a term built to be tiny wherever
    // sin t is in [0.2, 1.0] (e.g. (sin t - 0.3)^40, whose sup over the safe
    // zone is ~3e-7) blows up where sin t is NEGATIVE. Skipped only when a
    // tan/sec/cot function TOKEN actually occurs on a side (they blow up at
    // pi/2-neighbourhood angles; the zone angles sit near cot's pole at pi),
    // decided from the gate-pass token stream, not a substring of the input —
    // a tan factor multiplied by 0 or sec/sec cancelling is still a tan/sec/cot
    // token, so the defense stays ON for such inputs (their spike terms are
    // caught by the exponent cap instead). Sin/cos identities are unaffected,
    // and a true identity matches by construction.
    final hasTanLike = sideFuncs.any(
      (f) => f.intersection(const {'tan', 'sec', 'cot'}).isNotEmpty,
    );
    if (!hasTanLike) angles = [...angles, 3.14159265358979, 4.71238898038469];
    // RESIDUAL: numeric sampling at finite angles with tolerance 1e-6 cannot
    // distinguish a false pair whose difference has sup-norm < 1e-6 over the
    // reals; deliberate constructions with NESTED bounded powers (e.g.
    // ((sin x cos x)^5)^5, effective exponent 25 — each ^ site is 5, under
    // the cap) can still evade, and symbolic verification is the recorded
    // follow-up.
    for (final th in angles) {
      final l = _evalSide(sides[0], th);
      final r = _evalSide(sides[1], th);
      // null = structurally unevaluable (bad grammar). Parsing is
      // angle-independent, so a null side is null at EVERY angle and carries
      // no per-angle information — skip such samples; the checked == 0 guard
      // below then reports the input honestly as unverifiable.
      if (l == null || r == null) continue;
      final lBad = !l.isFinite;
      final rBad = !r.isFinite;
      if (lBad && rBad) continue; // symmetric domain gap: no information.
      // Exactly ONE side non-finite (e.g. (sin x)^2.5 * 0 is NaN where
      // sin x < 0 while the other side stays finite) is a MISMATCH, not a
      // skip — otherwise NaN poisons exactly the zone samples of a crafted
      // input and the sampler silently loses its defense there.
      if (lBad != rBad) {
        checked++;
        continue;
      }
      checked++;
      if ((l - r).abs() < 1e-6) okCount++;
    }
    // A side that never produced a usable number (trailing tokens, unsupported
    // grammar, …) must NEVER be reported as a proof — guard BOTH branches.
    if (checked == 0) {
      return SolveResult.error(
        'Could not verify — keep to sin/cos/tan/sec/csc/cot with numeric angles.',
      );
    }
    if (okCount < checked) {
      return SolveResult.error(
        'Not an identity — sides differ at sample angles ($okCount/$checked match).',
      );
    }
    final key = _match();
    if (key == null) {
      // Unnamed-template numeric verification (Adviser: restrict, don't trust
      // blindly). The false-confidence hole was that a variable-dependent pair
      // could be crushed below tolerance at the safe-zone samples by a high
      // power (0 = (sin x - 0.6)^40 read "Verified numerically"). That is now
      // closed by the exponent cap in the gate above (and, for powers the cap
      // admits, by the pi-zone samples + one-sided-mismatch rule). What
      // remains here is a genuine 12-point numeric verification of an
      // in-scope expression no named template covers (e.g. sin + 0 = sin).
      return SolveResult(
        answer:
            'Verified numerically at $okCount/$checked sample angles (no named proof template).',
        points: const [],
        customData: [
          {'kind': 'identity', 'template': 'numeric', 'matches': okCount},
        ],
      );
    }
    return SolveResult(
      answer: 'Identity holds — ${_known[key]!.last}',
      points: const [],
      customData: [
        {'kind': 'identity', 'template': key, 'steps': _known[key]},
      ],
    );
  }

  @override
  List<StepModel> getSteps() {
    final r = solve();
    if (r.hasError) {
      return [
        StepModel(
          stepNumber: 1,
          title: 'Check failed',
          explanation: r.errorMessage ?? '',
        ),
      ];
    }
    final data = r.customData!.first as Map;
    final steps =
        (data['steps'] as List?)?.cast<String>() ??
        ['Both sides agree at sample angles.'];
    final texSteps = _texByTemplate[data['template'] as String?];
    return [
      for (var i = 0; i < steps.length; i++)
        StepModel(
          stepNumber: i + 1,
          title: i == steps.length - 1 ? 'Conclusion' : 'Step ${i + 1}',
          explanation: steps[i],
          latex: (texSteps != null && i < texSteps.length) ? texSteps[i] : null,
        ),
    ];
  }
}
