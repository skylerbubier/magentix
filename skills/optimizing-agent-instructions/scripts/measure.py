#!/usr/bin/env python3
"""Measure an agent-instruction file and flag common verbosity/ambiguity smells.

Usage:
    python scripts/measure.py FILE                 # metrics + flags for one file
    python scripts/measure.py BEFORE AFTER         # side-by-side, with deltas
    python scripts/measure.py FILE --json          # machine-readable output

Token counts are approximate (chars / 4) and only useful for relative comparison.
Flags are heuristics: each one is a place to look, not a rule violation.
No third-party dependencies.
"""

from __future__ import annotations

import json
import re
import sys
from collections import Counter
from pathlib import Path

# Phrases that almost never change model behavior. Reviewed as candidates for deletion.
FILLER_PHRASES = [
    "it is important to",
    "it's important to",
    "please note that",
    "note that",
    "keep in mind",
    "make sure to",
    "be sure to",
    "in order to",
    "as you know",
    "basically",
    "essentially",
    "simply",
    "just",
    "very",
    "really",
    "always remember",
    "remember to",
    "don't forget",
    "feel free to",
    "you should",
    "you need to",
    "you must",
    "you will need to",
    "there are many",
    "a variety of",
    "in general",
    "generally speaking",
    "as a best practice",
    "best practices",
    "high quality",
    "clean code",
    "well-structured",
]

# Words that date the content or will rot.
TIME_WORDS = [
    r"\bas of\b",
    r"\bcurrently\b",
    r"\brecently\b",
    r"\bnow\b",
    r"\bnew(ly)?\b",
    r"\blatest\b",
    r"\bsoon\b",
    r"\bthis (week|month|quarter|year)\b",
    r"\b(19|20)\d{2}\b",
    r"\b(jan|feb|mar|apr|may|jun|jul|aug|sep|sept|oct|nov|dec)[a-z]*\.? \d{1,2}\b",
]

DIRECTIVE_CAPS = r"\b(ALWAYS|NEVER|MUST|CRITICAL|IMPORTANT|REQUIRED|DO NOT|SHALL)\b"
SECOND_PERSON = r"\b(I can|I will|I'll|you can use|you can|you should|use this to)\b"
BACKSLASH_PATH = r"[A-Za-z0-9_.-]+\\[A-Za-z0-9_.\\-]+"
MD_LINK = r"\[[^\]]*\]\(([^)\s]+\.md)\)"
BARE_MD_REF = r"(?:see|read|refer to)\s+`?([A-Za-z0-9_./-]+\.md)`?"


def split_frontmatter(text: str) -> tuple[str, str]:
    if text.startswith("---"):
        parts = text.split("\n---", 2)
        if len(parts) >= 2:
            fm = parts[0].lstrip("-").strip()
            body = parts[1].split("\n", 1)[1] if "\n" in parts[1] else ""
            if len(parts) == 3:
                body += parts[2]
            return fm, body
    return "", text


def frontmatter_field(fm: str, key: str) -> str:
    m = re.search(rf"^{key}:\s*(.*)$", fm, flags=re.M)
    return m.group(1).strip().strip("\"'") if m else ""


def analyze(path: Path) -> dict:
    text = path.read_text(encoding="utf-8", errors="replace")
    fm, body = split_frontmatter(text)
    lines = text.splitlines()
    words = re.findall(r"\S+", text)
    lower = text.lower()

    filler_hits = Counter()
    for phrase in FILLER_PHRASES:
        n = len(re.findall(rf"\b{re.escape(phrase)}\b", lower))
        if n:
            filler_hits[phrase] = n

    stripped = [ln.strip() for ln in lines if len(ln.strip()) > 25]
    dup_lines = [ln for ln, c in Counter(stripped).items() if c > 1]

    time_hits = []
    for pat in TIME_WORDS:
        for m in re.finditer(pat, text, flags=re.I):
            line_no = text.count("\n", 0, m.start()) + 1
            time_hits.append((line_no, m.group(0)))

    caps = re.findall(DIRECTIVE_CAPS, text)
    caps_per_100_lines = round(len(caps) / max(len(lines), 1) * 100, 1)

    description = frontmatter_field(fm, "description")
    second_person = re.findall(SECOND_PERSON, description, flags=re.I) if description else []
    name = frontmatter_field(fm, "name")
    name_issues = []
    if name:
        if not re.fullmatch(r"[a-z0-9]+(-[a-z0-9]+)*", name):
            name_issues.append("name must be lowercase letters/digits/hyphens, no leading/trailing hyphen")
        if len(name) > 64:
            name_issues.append("name exceeds 64 chars")
        if re.search(r"anthropic|claude", name):
            name_issues.append("name contains reserved word")
    if description and len(description) > 1024:
        name_issues.append(f"description is {len(description)} chars (limit 1024)")

    md_refs = set(re.findall(MD_LINK, text)) | set(re.findall(BARE_MD_REF, text, flags=re.I))
    nested = []
    for ref in sorted(md_refs):
        target = (path.parent / ref).resolve()
        if target.exists() and target.suffix == ".md":
            inner = target.read_text(encoding="utf-8", errors="replace")
            inner_refs = set(re.findall(MD_LINK, inner)) | set(re.findall(BARE_MD_REF, inner, flags=re.I))
            # Only count refs that resolve to real files; mentions inside examples are not chains.
            inner_refs = {r for r in inner_refs
                          if not r.endswith(path.name) and (target.parent / r).exists()}
            if inner_refs:
                nested.append((ref, sorted(inner_refs)))
            if len(inner.splitlines()) > 100 and not re.search(r"^##?\s*(contents|table of contents)", inner, flags=re.I | re.M):
                nested.append((ref, ["(>100 lines, no Contents section)"]))

    backslashes = re.findall(BACKSLASH_PATH, text)
    long_lines = [i + 1 for i, ln in enumerate(lines) if len(ln) > 400 and not ln.strip().startswith(("|", "```", "http"))]
    code_blocks = text.count("```") // 2
    headers = len(re.findall(r"^#{1,6}\s", text, flags=re.M))

    return {
        "file": str(path),
        "lines": len(lines),
        "words": len(words),
        "approx_tokens": round(len(text) / 4),
        "description_chars": len(description),
        "headers": headers,
        "code_blocks": code_blocks,
        "caps_directives": len(caps),
        "caps_per_100_lines": caps_per_100_lines,
        "flags": {
            "filler_phrases": dict(filler_hits.most_common()),
            "duplicate_lines": dup_lines[:10],
            "time_sensitive": time_hits[:15],
            "second_person_in_description": second_person,
            "frontmatter_issues": name_issues,
            "nested_or_untocd_references": nested,
            "backslash_paths": backslashes[:10],
            "very_long_lines": long_lines[:10],
        },
    }


def fmt_flags(r: dict) -> str:
    f = r["flags"]
    out = []
    if f["filler_phrases"]:
        top = ", ".join(f"{k}×{v}" for k, v in list(f["filler_phrases"].items())[:8])
        out.append(f"  filler phrases ({sum(f['filler_phrases'].values())}): {top}")
    if f["duplicate_lines"]:
        out.append(f"  duplicate lines: {len(f['duplicate_lines'])} e.g. \"{f['duplicate_lines'][0][:70]}\"")
    if f["time_sensitive"]:
        ex = "; ".join(f"L{n} '{w}'" for n, w in f["time_sensitive"][:5])
        out.append(f"  time-sensitive wording: {ex}")
    if f["second_person_in_description"]:
        out.append(f"  description not third person: {f['second_person_in_description']}")
    for issue in f["frontmatter_issues"]:
        out.append(f"  frontmatter: {issue}")
    for ref, inner in f["nested_or_untocd_references"]:
        out.append(f"  reference {ref}: {', '.join(inner)}")
    if f["backslash_paths"]:
        out.append(f"  backslash paths: {f['backslash_paths'][:3]}")
    if f["very_long_lines"]:
        out.append(f"  lines >400 chars at: {f['very_long_lines']}")
    if r["caps_per_100_lines"] > 15:
        out.append(f"  high ALL-CAPS directive density: {r['caps_directives']} ({r['caps_per_100_lines']}/100 lines)")
    return "\n".join(out) if out else "  none"


def print_single(r: dict) -> None:
    print(f"{r['file']}")
    print(f"  lines {r['lines']}  words {r['words']}  ~tokens {r['approx_tokens']}  "
          f"description {r['description_chars']} chars  headers {r['headers']}  code blocks {r['code_blocks']}")
    print("flags:")
    print(fmt_flags(r))


def pct(a: int, b: int) -> str:
    if a == 0:
        return "n/a"
    return f"{(b - a) / a * 100:+.0f}%"


def print_compare(a: dict, b: dict) -> None:
    print(f"{'metric':<20}{'before':>10}{'after':>10}{'delta':>10}")
    for k in ("lines", "words", "approx_tokens", "description_chars", "caps_directives"):
        print(f"{k:<20}{a[k]:>10}{b[k]:>10}{pct(a[k], b[k]):>10}")
    fa = sum(a["flags"]["filler_phrases"].values())
    fb = sum(b["flags"]["filler_phrases"].values())
    print(f"{'filler_phrases':<20}{fa:>10}{fb:>10}{pct(fa, fb):>10}")
    print("\nremaining flags in AFTER:")
    print(fmt_flags(b))


def main(argv: list[str]) -> int:
    as_json = "--json" in argv
    paths = [Path(p) for p in argv if not p.startswith("--")]
    if not paths or len(paths) > 2:
        print(__doc__)
        return 2
    for p in paths:
        if not p.is_file():
            print(f"not a file: {p}")
            return 2
    results = [analyze(p) for p in paths]
    if as_json:
        print(json.dumps(results if len(results) > 1 else results[0], indent=2, default=list))
    elif len(results) == 1:
        print_single(results[0])
    else:
        print_compare(results[0], results[1])
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main(sys.argv[1:]))
    except BrokenPipeError:
        sys.exit(0)
