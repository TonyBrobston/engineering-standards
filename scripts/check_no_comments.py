import io
import re
import sys
import tokenize
from pathlib import Path

ALLOWED_COMMENT_PATTERNS = [
    re.compile(r"^#!"),
    re.compile(r"^#\s*-\*-\s*coding"),
    re.compile(r"^#\s*noqa"),
    re.compile(r"^#\s*type:"),
    re.compile(r"^#\s*pragma"),
    re.compile(r"^#\s*fmt:"),
    re.compile(r"^#\s*ruff:"),
    re.compile(r"^#\s*SPDX-License-Identifier"),
]

SKIPPED_DIRECTORY_NAMES = {
    ".git",
    ".venv",
    "venv",
    "node_modules",
    "__pycache__",
    "build",
    "dist",
    ".engineering-standards",
}


def is_allowed_comment(comment_text):
    return any(pattern.match(comment_text) for pattern in ALLOWED_COMMENT_PATTERNS)


def disallowed_comments_in_source(source_text):
    findings = []
    tokens = tokenize.generate_tokens(io.StringIO(source_text).readline)
    for token in tokens:
        if token.type == tokenize.COMMENT and not is_allowed_comment(token.string):
            findings.append((token.start[0], token.string))
    return findings


def python_files_under(root):
    for path in root.rglob("*.py"):
        if SKIPPED_DIRECTORY_NAMES.isdisjoint(path.parts):
            yield path


def report(root):
    failure_count = 0
    for path in sorted(python_files_under(root)):
        try:
            findings = disallowed_comments_in_source(path.read_text(encoding="utf-8"))
        except (tokenize.TokenError, SyntaxError, UnicodeDecodeError):
            continue
        for line_number, comment_text in findings:
            failure_count += 1
            print(f"::error file={path},line={line_number}::Comment not allowed: {comment_text}")
    return failure_count


def self_test():
    assert disallowed_comments_in_source("x = 1  # explains x\n") == [(1, "# explains x")]
    assert disallowed_comments_in_source("#!/usr/bin/env python3\nx = 1\n") == []
    assert disallowed_comments_in_source("import os  # noqa: F401\n") == []
    assert disallowed_comments_in_source("value = cast(int, raw)  # type: ignore\n") == []
    assert disallowed_comments_in_source("def f():\n    return 1\n") == []
    print("check_no_comments self-test passed")


def main(arguments):
    if arguments == ["--self-test"]:
        self_test()
        return 0
    root = Path(arguments[0]) if arguments else Path(".")
    failure_count = report(root)
    if failure_count:
        print(f"{failure_count} disallowed comment(s). Extract a named function or rename instead.")
        return 1
    print("no disallowed comments")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
