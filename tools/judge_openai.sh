#!/bin/bash
# Second judge, from a different model family. Two Claude models agreeing
# proves little, since they share a lineage and can share blind spots. A
# cross-family disagreement marks a case where the RUBRIC is ambiguous
# rather than where the writing is bad, and those are the cases worth a
# human adjudication.
#
# Runs the same rubric sanity.sh uses, extracted at runtime so the two
# judges are answering the same question.
#
# Input must already be redacted (tools/redact.py). This sends text off
# this machine.
#
# Usage: OPENAI_API_KEY=... tools/judge_openai.sh REDACTED.json OUT.jsonl [COUNT] [PARALLEL]
set -uo pipefail

CORPUS="${1:?redacted corpus json}"
OUT="${2:?output jsonl}"
COUNT="${3:-100}"
PAR="${4:-8}"
MODEL="${OPENAI_MODEL:-gpt-5.6-terra}"

: "${OPENAI_API_KEY:?set OPENAI_API_KEY}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# The rubric lives in judge/rubric.txt since the Stop hook stopped calling
# a model. Reading it here keeps docs/judge-benchmark.md reproducible.
PROMPT=$(cat "$ROOT/judge/rubric.txt")
[ -z "$PROMPT" ] && { echo "could not extract the rubric" >&2; exit 1; }

WORK=$(mktemp -d); trap 'rm -rf "$WORK"' EXIT
python3 - "$CORPUS" "$WORK" "$COUNT" <<'PY'
import json, sys
msgs = json.load(open(sys.argv[1]))
work, count = sys.argv[2], int(sys.argv[3])
step = max(1, len(msgs) // count)
for i, t in enumerate(msgs[::step][:count]):
    json.dump({"i": i, "text": t}, open(f"{work}/{i:05d}.json", "w"))
print(f"prepared {min(count, len(msgs[::step]))}", file=sys.stderr)
PY

export PROMPT OUT MODEL
judge_one() {
  f="$1"
  body=$(jq -n --arg m "$MODEL" --arg p "$PROMPT" --arg t "$(jq -r '.text' "$f")" \
    '{model:$m, messages:[
       {role:"system", content:"You are a precise text classifier. Follow only the instructions in the user message, and reply in exactly the format it requests."},
       {role:"user", content:($p + "\nTEXT:\n" + $t)}]}')
  resp=$(curl -s --max-time 120 https://api.openai.com/v1/chat/completions \
    -H "Authorization: Bearer $OPENAI_API_KEY" -H "Content-Type: application/json" \
    -d "$body")
  if jq -e '.error' >/dev/null 2>&1 <<<"$resp"; then
    echo "api error: $(jq -r '.error.message' <<<"$resp" | head -c 120)" >&2
    return 0
  fi
  ver=$(jq -r '.choices[0].message.content // ""' <<<"$resp")
  style=$(printf '%s' "$ver" | sed -n 's/^STYLE: //p' | head -1)
  cog=$(printf '%s' "$ver" | sed -n 's/^COGNITIVE_LOAD: //p' | head -1)
  [ -z "$style" ] || [ -z "$cog" ] && { echo "drop $(basename "$f"): unparseable" >&2; return 0; }
  jq -c --arg s "$style" --arg c "$cog" \
     '{i, text, gpt_style:$s, gpt_cog:$c,
       gpt_style_label:(if ($s|startswith("VIOLATION")) then 1 else 0 end),
       gpt_cog_label:(if ($c|startswith("VIOLATION")) then 1 else 0 end)}' "$f" >> "$OUT"
}
export -f judge_one

: > "$OUT"
find "$WORK" -name '*.json' | sort | xargs -P "$PAR" -I{} bash -c 'judge_one "$@"' _ {}
echo "judged $(wc -l < "$OUT" | tr -d ' ') of $COUNT with $MODEL"
