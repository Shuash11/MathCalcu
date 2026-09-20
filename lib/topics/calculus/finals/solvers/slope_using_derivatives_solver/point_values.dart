// point_values.dart
// Parses user-entered point values (e.g. "x=2  y=-1.5e2  theta=0.5")
// into a variable -> value map for the slope solver.
//
// Variable names follow identifier rules ([a-zA-Z_][a-zA-Z0-9_]*) so
// multi-char names like x1 and theta are accepted, not silently ignored.
// Values accept plain decimals and scientific notation (e.g. 1e-3).
// Malformed parts are skipped; an empty input yields an empty map.

class PointValues {
  static final RegExp _pair = RegExp(
      r'^([a-zA-Z_][a-zA-Z0-9_]*)=([-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?)$');

  static Map<String, double> parse(String text) {
    final vars = <String, double>{};
    for (final part in text.split(RegExp(r'\s+'))) {
      final kv = _pair.firstMatch(part);
      if (kv != null) {
        vars[kv.group(1)!] = double.parse(kv.group(2)!);
      }
    }
    return vars;
  }
}
