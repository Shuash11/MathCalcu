// ─────────────────────────────────────────────────────────────
// M4 BASE CONVERSION — binary / octal / decimal / hex (+ generic
// baseN). e.g. '1011 base2 to base10', 'FF hex to dec', '255 to bin'.
// Offline, pure Dart. Never throws.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';

/// Number-base conversion solver (bases 2–36).
class M4BaseConversionEquation extends BaseEquation {
  @override
  final String rawInput;
  String? _error;

  M4BaseConversionEquation(this.rawInput);

  static const _names = {
    'bin': 2,
    'binary': 2,
    'base2': 2,
    'oct': 8,
    'octal': 8,
    'base8': 8,
    'dec': 10,
    'decimal': 10,
    'base10': 10,
    'hex': 16,
    'hexadecimal': 16,
    'base16': 16,
  };

  int? _baseOf(String? token) {
    if (token == null) return null;
    final t = token.toLowerCase().replaceAll(' ', '');
    if (_names.containsKey(t)) return _names[t];
    final m = RegExp(r'^(?:base)?(\d{1,2})$').firstMatch(t);
    if (m != null) {
      final b = int.parse(m.group(1)!);
      if (b >= 2 && b <= 36) return b;
    }
    return null;
  }

  /// Returns [digits, fromBase, toBase].
  List<dynamic>? _parse() {
    final t = rawInput.trim();
    // '1011 base2 to base10' / 'FF hex to dec' / '255 to bin'.
    var m = RegExp(
      r'^([0-9a-zA-Z]+)\s+(?:base\s*(\d{1,2})|(bin|binary|oct|octal|dec|decimal|hex|hexadecimal))\s*(?:to|->|in|=|>)\s*(?:base\s*(\d{1,2})|(bin|binary|oct|octal|dec|decimal|hex|hexadecimal|base\d{1,2}))\s*$',
      caseSensitive: false,
    ).firstMatch(t);
    if (m != null) {
      final digits = m.group(1)!;
      final from = _baseOf(m.group(2) ?? m.group(3));
      final to = _baseOf(m.group(4) ?? m.group(5));
      if (from == null || to == null) return null;
      return [digits, from, to];
    }
    // '0b1011 to dec', '0xFF to bin', '0o17 to dec'.
    m = RegExp(
      r'^(0[bB][01]+|0[oO][0-7]+|0[xX][0-9a-fA-F]+)\s*(?:to|->|in|=|>)\s*(.+)\s*$',
    ).firstMatch(t);
    if (m != null) {
      final lit = m.group(1)!;
      final from = lit.startsWith('0b') || lit.startsWith('0B')
          ? 2
          : lit.startsWith('0o') || lit.startsWith('0O')
          ? 8
          : 16;
      final digits = lit.substring(2);
      final to = _baseOf(m.group(2));
      if (to == null) return null;
      return [digits, from, to];
    }
    return null;
  }

  static const _digits = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  /// Largest magnitude this calculator converts exactly (int64-safe bound).
  ///
  /// Held as a [BigInt] (2^62), NOT an `int`. dart2js models `int` as a JS
  /// double: `1 << 62` silently evaluates to 0 on the web target (which zeroed
  /// the guard), and even the correct literal `0x4000000000000000` was only
  /// half a fix — the constant was exact but the CONVERSION and guard around it
  /// still ran in `int`, so above 2^53 the accumulator, the `~/` guard test and
  /// the digit extraction all rounded on web (e.g. `20000000000001 hex` came
  /// back off-by-one, and `4000000000000001 hex` could not be rejected because
  /// `~/` was itself inexact). BigInt is arbitrary precision, so the constant,
  /// the guard comparison and the conversion are now EXACT AND IDENTICAL on the
  /// VM and the web target.
  static final BigInt _maxValue = BigInt.one << 62;

  static BigInt? toDecimal(String digits, int base) {
    final baseB = BigInt.from(base);
    var value = BigInt.zero;
    for (final ch in digits.toUpperCase().split('')) {
      final d = _digits.indexOf(ch);
      if (d < 0 || d >= base) return null;
      // BUG B fix: reject BEFORE the multiply-add can overflow. The old guard
      // ('value > 1<<62', checked after the add) was false once the accumulator
      // had wrapped negative, so huge inputs slipped through; and a single
      // multiply-add could even wrap back to a small POSITIVE value. Checking
      // the bound up front — now in BigInt, so it is exact on both targets —
      // makes overflow impossible and is symmetric.
      if (value > (_maxValue - BigInt.from(d)) ~/ baseB) return null;
      value = value * baseB + BigInt.from(d);
    }
    return value;
  }

  /// True when every character of [digits] is a legal digit for [base].
  static bool _digitsLegalForBase(String digits, int base) {
    for (final ch in digits.toUpperCase().split('')) {
      final d = _digits.indexOf(ch);
      if (d < 0 || d >= base) return false;
    }
    return true;
  }

  /// Message for a rejected conversion, distinguishing a bad DIGIT from an
  /// out-of-range MAGNITUDE (Bug B: a size problem used to be mislabelled as a
  /// digits problem and, worse, sometimes produced an empty answer).
  static const String _magnitudeMessage =
      'That value exceeds the largest integer this calculator converts exactly.';

  static String fromDecimal(BigInt value, int base) {
    if (value == BigInt.zero) return '0';
    final baseB = BigInt.from(base);
    var v = value;
    var out = '';
    while (v > BigInt.zero) {
      out = _digits[(v % baseB).toInt()] + out;
      v = v ~/ baseB;
    }
    return out;
  }

  @override
  bool validate() {
    final empty = FieldValidators.notEmpty(
      rawInput,
      example: '1011 base2 to base10',
    );
    if (empty != null) {
      _error = empty;
      return false;
    }
    final p = _parse();
    if (p == null) {
      _error = 'Use 1011 base2 to base10, FF hex to dec, or 0xFF to bin.';
      return false;
    }
    final digits = p[0] as String;
    final from = p[1] as int;
    if (toDecimal(digits, from) == null) {
      // Distinguish a bad digit from an out-of-range magnitude so the user is
      // never told "digits do not fit" when the real problem is size (Bug B).
      _error = _digitsLegalForBase(digits, from)
          ? _magnitudeMessage
          : 'Digits do not fit the source base — e.g. binary is 0/1 only.';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    final p = _parse();
    if (p == null) {
      return SolveResult.error(_error ?? 'Use 1011 base2 to base10.');
    }
    final digits = (p[0] as String).toUpperCase();
    final from = p[1] as int;
    final to = p[2] as int;
    final dec = toDecimal(digits, from);
    if (dec == null) {
      return SolveResult.error(
        _digitsLegalForBase(digits, from)
            ? _magnitudeMessage
            : 'Digits do not fit base $from — check each digit < $from.',
      );
    }
    final out = fromDecimal(dec, to);
    return SolveResult(
      answer: '$digits (base $from) = $out (base $to)',
      points: [dec.toDouble()],
      customData: [
        {
          'kind': 'base-conversion',
          'digits': digits,
          'fromBase': from,
          'toBase': to,
          'decimal': dec,
          'result': out,
        },
      ],
    );
  }

  @override
  List<StepModel> getSteps() {
    final p = _parse();
    if (p == null) {
      return [
        StepModel(
          stepNumber: 1,
          title: 'Invalid input',
          explanation: _error ?? 'Use 1011 base2 to base10.',
        ),
      ];
    }
    final r = solve();
    final data = (r.customData == null || r.customData!.isEmpty)
        ? null
        : r.customData!.first;
    final digits = (p[0] as String).toUpperCase();
    final from = p[1] as int;
    final to = p[2] as int;
    final dec = data?['decimal'];
    final out = data?['result'];
    return [
      StepModel(
        stepNumber: 1,
        title: 'Expand in the source base',
        explanation:
            '${(p[0] as String).toUpperCase()} base ${p[1]} → decimal by place value.',
        latex: dec == null ? null : '${digits}_{$from} = ${dec}_{10}',
      ),
      StepModel(
        stepNumber: 2,
        title: 'Divide into the target base',
        explanation: 'Repeated ÷ ${p[2]}, read remainders bottom-up.',
      ),
      StepModel(
        stepNumber: 3,
        title: 'Read the result',
        explanation: r.hasError ? (r.errorMessage ?? '') : r.answer,
        latex: out == null ? null : '${digits}_{$from} = ${out}_{$to}',
      ),
    ];
  }
}
