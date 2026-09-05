#!/usr/bin/env python3
"""Extracts the assistant-message corpus the judge benchmark runs on.

Reads every Claude Code transcript under ~/.claude/projects, keeps
assistant text blocks of 15+ words, and strips fenced code the same way
hooks/lib.sh does. See docs/judge-benchmark.md.

Usage: tools/mine.py corpus.json
"""
import json, glob, os, re, sys

out = []
for f in glob.glob(os.path.expanduser('~/.claude/projects/**/*.jsonl'), recursive=True):
    try:
        for line in open(f, errors='ignore'):
            try:
                d = json.loads(line)
            except Exception:
                continue
            if d.get('type') != 'assistant':
                continue
            for c in (d.get('message') or {}).get('content') or []:
                if isinstance(c, dict) and c.get('type') == 'text':
                    t = (c.get('text') or '').strip()
                    if len(t.split()) >= 15:
                        out.append(t)
    except Exception:
        pass

# strip fenced code, the same way the hook does
def strip_fences(t):
    keep, infence = [], False
    for line in t.split('\n'):
        if line.startswith('```'):
            infence = not infence
            continue
        if not infence:
            keep.append(line)
    return '\n'.join(keep)

out = [strip_fences(t) for t in out]
out = [t for t in out if len(t.split()) >= 15]
json.dump(out, open(sys.argv[1], 'w'))
print(f"messages: {len(out)}")
print(f"words:    {sum(len(t.split()) for t in out):,}")
