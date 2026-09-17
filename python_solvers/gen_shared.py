#!/usr/bin/env python3
"""Shared post-generation helpers for MathCalcu Dart code generators.

Single responsibility: write generated Dart files and keep them
`dart format`-clean so the format CI gate stays green on every regen.
"""
import os
import subprocess
from pathlib import Path


def write_dart_file(path, content):
    """Write generated Dart content to path (UTF-8). Returns the Path."""
    path = Path(path)
    path.write_text(content, encoding="utf-8")
    return path


def format_dart_file(path):
    """Run `dart format` on a generated file.

    Warns (never fails) when the SDK is unavailable so regen still works.
    (shell=True on Windows because dart ships as dart.BAT there.)
    """
    try:
        subprocess.run(
            ["dart", "format", str(path)],
            check=True,
            shell=(os.name == "nt"),
        )
    except (OSError, subprocess.CalledProcessError) as e:
        print(f"  (warning: dart format skipped for {path}: {e})")
    return Path(path)


def write_dart_formatted(path, content):
    """Write generated Dart content, then format it. Returns the Path."""
    write_dart_file(path, content)
    format_dart_file(path)
    return Path(path)
