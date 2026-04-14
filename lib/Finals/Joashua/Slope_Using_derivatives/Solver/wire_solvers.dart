// main.dart
// Entry point only: CLI argument parsing and the demo suite.
// Wires together: SlopeSolver (compute) → PrettyPrinter (display).
// No mathematics or formatting logic lives here.

import 'dart:io';
import 'package:calculus_system/Finals/Joashua/Slope_Using_derivatives/Solver/display_answer.dart';

import 'solver.dart';

// ==================== CLI ARG PARSER ====================

/// Parses CLI args of the form:  "y = sin(x)"  x=1.5708
/// Equation tokens and key=value tokens are split by pattern.
/// Returns (equation_string, {varName: numericValue, ...}).
(String, Map<String, double>) _parseArgs(List<String> args) {
  if (args.isEmpty) return ('', {});

  final eqParts = <String>[];
  final vals = <String, double>{};

  for (final arg in args) {
    final kv =
        RegExp(r'^([a-zA-Z_][a-zA-Z0-9_]*)=([-\d.eE+]+)$').firstMatch(arg);
    if (kv != null) {
      vals[kv.group(1)!] = double.parse(kv.group(2)!);
    } else {
      eqParts.add(arg);
    }
  }

  return (eqParts.join(' '), vals);
}

// ==================== DEMO SUITE ====================

const _demos = <(String, Map<String, double>)>[
  // Explicit — polynomial
  ('y = x^3 - 3x^2 + 2', {'x': 2.0}),
  // Explicit — trig
  ('y = sin(x) * cos(x)', {'x': 0.0}),
  // Explicit — exponential / ln combo
  ('y = e^x * ln(x)', {'x': 1.0}),
  // Explicit — quotient rule
  ('y = (x^2 + 1) / (x - 1)', {'x': 3.0}),
  // Explicit — chain rule inside power
  ('y = (sin(x))^3', {'x': 1.5708}),
  // Explicit — sqrt
  ('y = sqrt(x^2 + 1)', {'x': 2.0}),
  // Implicit — circle
  ('x^2 + y^2 = 25', {'x': 3.0, 'y': 4.0}),
  // Implicit — Folium of Descartes
  ('x^3 + y^3 = 6*x*y', {'x': 3.0, 'y': 3.0}),
  // Implicit — ellipse
  ('4*x^2 + 9*y^2 = 36', {'x': 0.0, 'y': 2.0}),
  // Parametric — unit circle
  ('x=cos(t), y=sin(t)', {'t': 0.7854}),
  // Parametric — cycloid
  ('x=t - sin(t), y=1 - cos(t)', {'t': 1.5708}),
  // Parametric — astroid
  ('x=cos(t)^3, y=sin(t)^3', {'t': 0.5236}),
];

// ==================== MAIN ====================

void main(List<String> args) {
  if (args.isNotEmpty) {
    final (eq, vals) = _parseArgs(args);
    if (eq.isEmpty) {
      stderr.writeln('Usage: dart main.dart "<equation>" [var=value ...]');
      stderr.writeln('Examples:');
      stderr.writeln('  dart main.dart "y = x^3 - 2x + 1" x=2');
      stderr.writeln('  dart main.dart "x^2 + y^2 = 25" x=3 y=4');
      stderr.writeln('  dart main.dart "x=cos(t), y=sin(t)" t=1.5708');
      exit(1);
    }
    try {
      final result = SlopeSolver.solve(eq, pointValues: vals);
      PrettyPrinter.print(result);
    } catch (e) {
      stderr.writeln('Error: $e');
      exit(1);
    }
    return;
  }

  // Full demo suite
  stdout.writeln('\n${'═' * 64}');
  stdout.writeln('  SLOPE SOLVER — COMPREHENSIVE DEMO');
  stdout.writeln('${'═' * 64}\n');

  int passed = 0;
  int failed = 0;

  for (int i = 0; i < _demos.length; i++) {
    final (eq, vals) = _demos[i];
    stdout.writeln('\n[Demo ${i + 1}/${_demos.length}]');
    try {
      final result = SlopeSolver.solve(eq, pointValues: vals);
      PrettyPrinter.print(result);
      passed++;
    } catch (e, st) {
      stderr.writeln('  !! Error solving "$eq": $e');
      stderr.writeln(st);
      failed++;
    }
    stdout.writeln();
  }

  stdout.writeln('${'═' * 64}');
  stdout.writeln(
      '  RESULTS: $passed passed, $failed failed out of ${_demos.length} demos');
  stdout.writeln('${'═' * 64}\n');
}
