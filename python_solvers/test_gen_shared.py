#!/usr/bin/env python3
"""Cycle 6 P5: deterministic coverage for python_solvers/gen_shared.py.

Single responsibility: pin the generator hook contract without flakiness.
- format fallback warns (never fails) when dart is missing or exits nonzero
- write helpers round-trip UTF-8 content and return Path objects
- every generator module stays py_compile-clean with warnings as errors

Stdlib only (unittest + mock), no network, no SDK required.
"""
import py_compile
import subprocess
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import gen_shared


class WriteDartFileTests(unittest.TestCase):
    def test_write_round_trips_utf8_and_returns_path(self):
        with tempfile.TemporaryDirectory() as tmp:
            target = Path(tmp) / "out.dart"
            returned = gen_shared.write_dart_file(target, "// √ ≈ 2.2361\n")
            self.assertEqual(returned, Path(target))
            self.assertEqual(
                Path(target).read_text(encoding="utf-8"),
                "// √ ≈ 2.2361\n",
            )

    def test_overwrite_replaces_previous_content(self):
        with tempfile.TemporaryDirectory() as tmp:
            target = Path(tmp) / "out.dart"
            gen_shared.write_dart_file(target, "old")
            gen_shared.write_dart_file(target, "new")
            self.assertEqual(Path(target).read_text(encoding="utf-8"), "new")


class FormatFallbackTests(unittest.TestCase):
    def test_missing_dart_binary_warns_instead_of_raising(self):
        with tempfile.TemporaryDirectory() as tmp:
            target = Path(tmp) / "out.dart"
            target.write_text("// hi\n", encoding="utf-8")
            with patch.object(
                gen_shared.subprocess,
                "run",
                side_effect=OSError("dart missing"),
            ):
                returned = gen_shared.format_dart_file(target)
            self.assertEqual(returned, Path(target))

    def test_nonzero_dart_format_warns_instead_of_raising(self):
        with tempfile.TemporaryDirectory() as tmp:
            target = Path(tmp) / "out.dart"
            target.write_text("// hi\n", encoding="utf-8")
            with patch.object(
                gen_shared.subprocess,
                "run",
                side_effect=subprocess.CalledProcessError(1, "dart format"),
            ):
                returned = gen_shared.format_dart_file(target)
            self.assertEqual(returned, Path(target))

    def test_write_formatted_calls_format_step(self):
        with tempfile.TemporaryDirectory() as tmp:
            target = Path(tmp) / "out.dart"
            with patch.object(gen_shared, "format_dart_file") as fmt:
                returned = gen_shared.write_dart_formatted(target, "// hi\n")
            fmt.assert_called_once()
            self.assertEqual(returned, Path(target))
            self.assertEqual(
                Path(target).read_text(encoding="utf-8"), "// hi\n"
            )


class PyCompileGuardTests(unittest.TestCase):
    def test_all_generators_compile_with_warnings_as_errors(self):
        root = Path(__file__).resolve().parent
        modules = sorted(root.glob("*_generator.py")) + [root / "gen_shared.py"]
        self.assertGreaterEqual(len(modules), 2)
        for module in modules:
            with self.subTest(module=module.name):
                # -W error surfaces SyntaxWarning/DeprecationWarning as
                # failures; doraise=True raises instead of returning bool.
                py_compile.compile(
                    str(module), doraise=True, optimize=0,
                )


if __name__ == "__main__":
    unittest.main()
