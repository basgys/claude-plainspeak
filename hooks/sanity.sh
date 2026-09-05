#!/bin/bash
# Stop hook: gatekeeps the final assistant message of each turn against the
# writing rules. Stateless apart from an attempt counter — no memory of past
# turns, not a conversational agent.
#
# All checks live in lib.sh and run locally. The Haiku classifier that used
# to run second was removed once the local checks reached 95% of what two
# independent judges agree on (docs/judge-benchmark.md); it cost 27-79s per
# turn, against 250ms now. Roughly a fifth of the clean-looking band ships
# unjudged as a result, predominantly cognitive-load items no regex sees.
set -uo pipefail
source "$(dirname "$0")/lib.sh"

# A check costs ~250ms of local CPU, so the budget is set by what a rewrite
# costs the writer (one more full turn). Three was tight enough that the
# give-up path fired on drafts one flag from clean.
MAX_ATTEMPTS=5

input=$(cat)
session_id=$(jq -r '.session_id // "unknown"' <<<"$input")
counter_file="/tmp/.claude-sanity-attempts-${session_id}"

# stop_hook_active is true only when Claude is continuing because this hook
# blocked. Stop hooks don't fire on user interrupts, so a rewrite cut short
# by Escape leaves a counter behind that must not carry into the next turn.
stop_hook_active=$(jq -r '.stop_hook_active // false' <<<"$input")
attempt=0
if [ "$stop_hook_active" = "true" ] && [ -f "$counter_file" ]; then
  attempt=$(cat "$counter_file" 2>/dev/null || echo 0)
else
  rm -f "$counter_file" "$counter_file.hits"
fi
[ -z "$attempt" ] && attempt=0

msg=$(jq -r '.last_assistant_message // empty' <<<"$input")
[ -z "$msg" ] && exit 0

# A prior attempt already maxed out and gave up — don't re-enter.
if [ "$attempt" -ge "$MAX_ATTEMPTS" ]; then
  rm -f "$counter_file" "$counter_file.hits"
  exit 0
fi

# No hook can retract a message already displayed, so a rewrite cycle leaves
# the reader several near-identical walls with no way to tell which one
# survived. The systemMessage prints directly under the message it judged,
# so every draft gets a verdict marker and the reader scrolls for the tick.
block() {
  attempt=$((attempt + 1))
  echo "$attempt" > "$counter_file"
  if [ "$attempt" -ge "$MAX_ATTEMPTS" ]; then
    jq -n --arg m "⚠️  KEPT AS-IS ↑ still failing after $MAX_ATTEMPTS attempts, gave up" \
      '{systemMessage: $m}'
    rm -f "$counter_file" "$counter_file.hits"
    exit 0
  fi

  # A rewrite tripping the identical flag means the writer did not find the
  # text, or read the flag as a general style note. Saying so is the
  # difference between a second attempt and a fifth.
  local repeat=""
  if [ -f "$counter_file.hits" ] && [ "$(cat "$counter_file.hits")" = "$1" ]; then
    repeat="These are the SAME flags as the last attempt — the rewrite missed them. Locate the quoted text literally and delete or replace it before changing anything else.$NL$NL"
  fi
  printf '%s' "$1" > "$counter_file.hits"

  # Each tier removes a degree of freedom rather than repeating the advice
  # louder: a writer on attempt 3 has already tried its reading twice.
  local howto
  if [ "$attempt" -le 1 ]; then
    howto="HOW TO FIX: edit only the flagged constructions. Keep the content, the findings, the code and the structure of everything that was not flagged — a full rewrite usually trips a different rule and burns another attempt."
  elif [ "$attempt" -eq 2 ]; then
    howto="HOW TO FIX — MECHANICAL EDIT ONLY. Do not redraft. Copy the previous message and change ONLY the quoted spans above: delete each one, or replace it with the shortest wording that keeps the fact. Every other character stays byte-identical. If a quoted span cannot be deleted without losing a fact, delete the sentence around it and state the fact in five words."
  else
    howto="HOW TO FIX — LAST RESORT, CUT IT DOWN. $attempt attempts have failed, so the draft's length is what keeps generating flags. Send the answer in at most three sentences plus, if truly needed, one list of at most four items. Drop every explanation the reader did not ask for. A short blunt answer passes these checks; a polished long one does not."
  fi

  # Stop hooks only honor decision/reason at the TOP level of the output
  # JSON. Nested under hookSpecificOutput they are silently ignored: the
  # systemMessage still prints, but the reply goes through unchanged.
  jq -n --arg r "Draft blocked, attempt $attempt of $MAX_ATTEMPTS. ${repeat}Fix every item below, then send the whole message again. Each failed attempt leaves the reader another discarded draft to scroll past, so treat this as the last one.

FLAGGED:
$1

$howto Fenced code is exempt from these checks; blockquotes are not. Do not apologize, do not mention this check, and do not add a note about the rewrite: send the corrected message as if it were the first." \
    --arg m "❌ DISCARDED ↑ do not read, rewriting ($attempt/$MAX_ATTEMPTS)" \
    '{decision: "block", reason: $r, systemMessage: $m}'
  exit 0
}

hits=""
run_checks "$(strip_code <<<"$msg")"

[ -n "$hits" ] && block "$hits"

# Only mark the winner when there were losers above it to tell apart.
if [ "$attempt" -gt 0 ]; then
  jq -n --arg m "✅ FINAL ANSWER ↑ read this one (passed after $attempt rewrite(s))" '{systemMessage: $m}'
fi
rm -f "$counter_file" "$counter_file.hits"
exit 0
