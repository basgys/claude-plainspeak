#!/usr/bin/env python3
"""Strips identifiers from corpus messages before they leave this machine.

The second judge reads sentence SHAPES: fragments, codas, buried
conclusions, padding. None of that needs to know the table is called
raw.steam_review. So every identifier becomes a typed placeholder of
similar shape, consistently within a message, and the judgment is
unaffected while the project detail stays local.

Replacements keep their token shape on purpose. Turning `api/game/list.go`
into a bare `X` would change sentence length and rhythm, which are exactly
what the judge measures.

Usage: redact.py < in.json > out.json   (a JSON list of strings)
"""

import json
import re
import sys

# Order matters: the most specific patterns run first, so a URL is not
# first mangled into a path.
PATTERNS = [
    ("EMAIL", re.compile(r"\b[\w.+-]+@[\w-]+\.[\w.-]+\b")),
    # mcp__server__tool, before anything else claims the underscores
    ("TOOL", re.compile(r"\bmcp__[\w]+__[\w]+\b")),
    # SCREAMING_SNAKE env vars carry project names too
    ("ENV", re.compile(r"\b[A-Z][A-Z0-9]*(?:_[A-Z0-9]+){1,}\b")),
    ("URL", re.compile(r"https?://[^\s)>\]]+")),
    # dotted qualified names: raw.steam_review, validated.igdb_game_item,
    # metrics.company_reputation, lake.foreach.diff
    ("TABLE", re.compile(r"\b[a-z][a-z0-9_]{2,}(?:\.[a-z][a-z0-9_]{2,}){1,3}\b(?!\()")),
    # file paths with a slash, optionally :line
    ("PATH", re.compile(r"\b[\w.@-]+(?:/[\w.@-]+)+(?::\d+(?:-\d+)?)?")),
    # Go/TS identifiers: mongoRepository.Migrate, subscriptionListLoader
    ("IDENT", re.compile(r"\b[a-z][a-zA-Z0-9]*[A-Z][a-zA-Z0-9]*\b")),
    # Exported/acronym-led names: IGDBGameTypeCategory, HTTPClient. Needs
    # 6+ chars and a second capital, so JSON, API and CI stay intact.
    ("TYPE", re.compile(r"\b(?=[A-Za-z0-9]{6,}\b)[A-Z][a-z0-9]*[A-Z][A-Za-z0-9]*\b")),
    # bare snake_case that survived the dotted rule
    ("NAME", re.compile(r"\b[a-z][a-z0-9]*(?:_[a-z0-9]+){1,}\b")),
]

# Words that look like identifiers but are ordinary English or public
# technical vocabulary. Redacting these would distort the prose.
KEEP = {
    "javascript", "typescript", "postgresql", "mysql", "sqlite", "github",
    "gitlab", "kubernetes", "docker", "python", "golang", "nodejs",
    "isnull", "readme", "jsonl", "stdout", "stderr", "stdin",
    "https", "restapi", "graphql", "openapi", "webhook", "changelog",
    "runtime", "codebase", "hostname", "username", "timeout", "boolean",
    "goroutine", "middleware", "namespace", "workflow", "toolchain",
}


def redact(text):
    counters = {}
    mapping = {}

    def sub(kind, m):
        tok = m.group(0)
        if tok.lower() in KEEP:
            return tok
        if tok not in mapping:
            counters[kind] = counters.get(kind, 0) + 1
            mapping[tok] = f"{kind}_{counters[kind]}"
        return mapping[tok]

    out = text
    for kind, pat in PATTERNS:
        out = pat.sub(lambda m, k=kind: sub(k, m), out)
    # A method hanging off an already-redacted identifier leaks the method
    # name (IDENT_1.Migrate). Collapse it into the placeholder.
    out = re.sub(r"\b((?:IDENT|TABLE|NAME|PATH)_\d+)\.[A-Za-z][A-Za-z0-9_]*", r"\1", out)
    # A bare capitalised project name is not recoverable by pattern, so the
    # caller passes any extra terms via argv.
    for extra in sys.argv[1:]:
        # No word boundary: these names appear glued to wildcards and
        # package prefixes (playstation_*, pkgigdb., mcp__lakehouse__*).
        out = re.sub(re.escape(extra), "PROJECT", out, flags=re.I)
    return out


if __name__ == "__main__":
    msgs = json.load(sys.stdin)
    json.dump([redact(m) for m in msgs], sys.stdout)
