#!/usr/bin/env python3
"""Draws one stratified sample and writes it twice: raw for the Haiku
judge, redacted for the second judge off-machine. Both judges must see the
SAME messages in the SAME order, or a disagreement means nothing.

Usage: sample.py CORPUS.json N OUT.json OUT-REDACTED.json -- [redact terms]
"""
import importlib.util, json, subprocess, sys

corpus, n, out, out_red = sys.argv[1], int(sys.argv[2]), sys.argv[3], sys.argv[4]
terms = sys.argv[6:] if len(sys.argv) > 5 else []

spec = importlib.util.spec_from_file_location("m", "hooks/metrics.py")
m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)

msgs = json.load(open(corpus))
buckets = {}
for t in msgs:
    mm = m.compute(t)
    sig = (mm["coda"] + (mm["neg_parallel"] >= 2) + (mm["longest_sentence"] > 40)
           + (mm["emdash"] > max(3, mm["words"] // 150))
           + (mm["figures_per_paragraph"] > 5) + (mm["nominal_per_100w"] > 5.556))
    buckets.setdefault(min(sig, 3), []).append(t)

per = max(1, n // len(buckets))
picked = []
for k in sorted(buckets):
    rows = buckets[k]
    step = max(1, len(rows) // per)
    picked += rows[::step][:per]
picked = picked[:n]

json.dump(picked, open(out, "w"))
red = subprocess.run([sys.executable, "tools/redact.py", *terms],
                     input=json.dumps(picked), capture_output=True, text=True)
open(out_red, "w").write(red.stdout)
print(f"sampled {len(picked)} across signal levels {sorted(buckets)}", file=sys.stderr)
