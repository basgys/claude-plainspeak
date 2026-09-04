#!/bin/bash
# Replays a corpus through the SAME stage 2 prompt sanity.sh uses, to build
# the label set the cascade needs. The prompt is extracted from sanity.sh
# at runtime rather than copied, so the labels can never drift from what
# the hook actually enforces.
#
# There is no API key on this machine (auth is claude.ai), so the Message
# Batches API and its 50% discount are unavailable. This runs `claude -p`
# in parallel against plan quota instead.
#
# Usage: tools/label.sh CORPUS.json OUT.jsonl [COUNT] [PARALLEL]
set -uo pipefail

CORPUS="${1:?corpus json}"
OUT="${2:?output jsonl}"
COUNT="${3:-100}"
PAR="${4:-12}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SANITY="$ROOT/hooks/sanity.sh"
METRICS="$ROOT/hooks/metrics.py"

# Pull the rubric out of sanity.sh, between `-p "` and the TEXT: marker.
PROMPT=$(python3 - "$SANITY" <<'PY'
import sys
s = open(sys.argv[1]).read()
i = s.index('verdict=$(')
j = s.index('-p "', i) + 4
k = s.index('\nTEXT:', j)
print(s[j:k])
PY
)
[ -z "$PROMPT" ] && { echo "could not extract the stage 2 prompt" >&2; exit 1; }

# Stratified sample: take from across the metric-signal range so the labels
# cover clean and dirty alike. A random sample would be dominated by the
# short clean messages that make up most of the corpus.
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

python3 - "$CORPUS" "$METRICS" "$WORK" "$COUNT" <<'PY'
import json, sys, importlib.util
corpus, metrics_path, work, count = sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4])
spec = importlib.util.spec_from_file_location("m", metrics_path)
m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)

msgs = json.load(open(corpus))
scored = []
for t in msgs:
    mm = m.compute(t)
    signal = (mm["coda"] + (mm["neg_parallel"] >= 2) + (mm["longest_sentence"] > 40)
              + (mm["emdash"] > max(3, mm["words"] // 150))
              + (mm["figures_per_paragraph"] > 5) + (mm["nominal_per_100w"] > 5.556))
    scored.append((signal, t, mm))

# Even quota per signal level, so rare dirty messages are not swamped.
by = {}
for s, t, mm in scored:
    by.setdefault(min(s, 3), []).append((t, mm))
per = max(1, count // max(1, len(by)))
picked = []
for k in sorted(by):
    rows = by[k]
    step = max(1, len(rows) // per)
    picked += rows[::step][:per]
picked = picked[:count]

for i, (t, mm) in enumerate(picked):
    json.dump({"i": i, "text": t, "metrics": mm}, open(f"{work}/{i:05d}.json", "w"))
print(f"sampled {len(picked)} across signal levels {sorted(by)}", file=sys.stderr)
PY

export PROMPT OUT WORK
label_one() {
  f="$1"
  txt=$(jq -r '.text' "$f")
  ver=$(timeout 150 claude --restricted --model haiku --tools "" \
        --system-prompt "You are a precise text classifier. Follow only the instructions in the user's message, and reply in exactly the format it requests." \
        --no-session-persistence -p "$PROMPT
TEXT:
$txt" 2>/dev/null)
  style=$(printf '%s' "$ver" | sed -n 's/^STYLE: //p' | head -1)
  cog=$(printf '%s' "$ver" | sed -n 's/^COGNITIVE_LOAD: //p' | head -1)
  # A timed-out or unparseable verdict must be DROPPED, never recorded as
  # clean. The pilot lost 5 of 24 calls this way, and silently labelling
  # those 0 would have taught the classifier that hard messages are fine.
  if [ -z "$style" ] || [ -z "$cog" ]; then
    echo "drop $(basename "$f"): empty verdict" >&2
    return 0
  fi
  jq -c --arg s "$style" --arg c "$cog" \
     '{sha:(.text|@base64|.[0:16]), metrics, style:$s, cognitive:$c,
       style_label:(if ($s|startswith("VIOLATION")) then 1 else 0 end),
       cog_label:(if ($c|startswith("VIOLATION")) then 1 else 0 end)}' "$f" >> "$OUT"
}
export -f label_one

: > "$OUT"
find "$WORK" -name '*.json' | sort | xargs -P "$PAR" -I{} bash -c 'label_one "$@"' _ {}
echo "labelled $(wc -l < "$OUT" | tr -d ' ') of $COUNT into $OUT"
