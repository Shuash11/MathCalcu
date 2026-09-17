"""Worktree secret scan gate (Cycle 5 F1).

Fails when a probable hardcoded secret remains in tracked worktree
files. Skips ``.git/`` history (history cannot be purged from here;
rotation is handled outside the code).

Run: ``python tutorial/check_no_secrets.py`` (exit 0 = clean).
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PATTERNS = (
    re.compile(r"sk_[A-Za-z0-9]{20,}"),
    re.compile(r"xox[bap]-"),
    re.compile(r"ghp_[A-Za-z0-9]{20,}"),
)
SKIP_DIRS = (".git", "__pycache__", ".dart_tool", "build")
SKIP_FILES = ("check_no_secrets.py",)


def iter_files():
    for dirpath, dirnames, filenames in os.walk(ROOT):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        for name in filenames:
            if name in SKIP_FILES:
                continue
            yield os.path.join(dirpath, name)


def main():
    hits = []
    for path in iter_files():
        try:
            with open(path, "r", encoding="utf-8", errors="strict") as handle:
                for lineno, line in enumerate(handle, 1):
                    for pattern in PATTERNS:
                        if pattern.search(line):
                            hits.append("%s:%d" % (os.path.relpath(path, ROOT), lineno))
                            break
        except (OSError, UnicodeDecodeError):
            continue
    if hits:
        print("SECRET SCAN FAILED — %d hit(s):" % len(hits))
        for hit in hits:
            print("  " + hit)
        return 1
    print("SECRET SCAN OK — no hardcoded keys in worktree.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
