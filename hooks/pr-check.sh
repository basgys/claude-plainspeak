#!/bin/bash
# PreToolUse/Bash hook: gatekeeps `gh pr create`/`gh pr edit --body` the same
# way sanity.sh gatekeeps chat replies — regex first (free), Haiku fallback
# second — but judged against PR-description rules (prose not bullets,
# motivation before implementation, single unit) plus the same style/
# cognitive-load axes, since CLAUDE.md's writing rules explicitly apply to
# PR descriptions too. Blocks via exit 2 (stderr fed back to the assistant),
# matching guard-shell.sh's existing convention in this project.
set -uo pipefail

MAX_ATTEMPTS=3

input=$(cat)
tool=$(jq -r '.tool_name // ""' <<<"$input")
[ "$tool" != "Bash" ] && exit 0

cmd=$(jq -r '.tool_input.command // ""' <<<"$input")

# Only fire on PR body-setting commands.
echo "$cmd" | grep -qE '\bgh\s+pr\s+(create|edit)\b' || exit 0
echo "$cmd" | grep -qE -- '--body(-file)?\b' || exit 0

session_id=$(jq -r '.session_id // "unknown"' <<<"$input")
cmd_key=$(printf '%s' "$cmd" | shasum -a 256 | cut -d' ' -f1 | head -c 16)
counter_file="/tmp/.claude-sanity-pr-attempts-${session_id}-${cmd_key}"

attempt=0
[ -f "$counter_file" ] && attempt=$(cat "$counter_file" 2>/dev/null || echo 0)
[ -z "$attempt" ] && attempt=0

if [ "$attempt" -ge "$MAX_ATTEMPTS" ]; then
  rm -f "$counter_file"
  exit 0
fi

# Extract the PR body text.
body=""
if [[ "$cmd" =~ --body-file[[:space:]]+([^[:space:]]+) ]]; then
  bodyfile="${BASH_REMATCH[1]}"
  [ -f "$bodyfile" ] && body=$(cat "$bodyfile")
elif [[ "$cmd" == *"<<'EOF'"* || "$cmd" == *'<<"EOF"'* || "$cmd" == *"<<EOF"* ]]; then
  body=$(awk '/<<['\''"]?EOF['\''"]?/{f=1;next} /^EOF$/{f=0} f' <<<"$cmd")
elif [[ "$cmd" =~ --body[[:space:]]+\"([^\"]*)\" ]]; then
  body="${BASH_REMATCH[1]}"
fi

[ -z "$body" ] && exit 0

block() {
  attempt=$((attempt + 1))
  echo "$attempt" > "$counter_file"
  if [ "$attempt" -ge "$MAX_ATTEMPTS" ]; then
    echo "Sanity (PR): gave up after $MAX_ATTEMPTS attempts, letting the PR command through as-is ($1)." >&2
    rm -f "$counter_file"
    exit 0
  fi
  echo "Blocked (attempt $attempt/$MAX_ATTEMPTS): PR description check failed. $1" >&2
  exit 2
}

# --- Stage 1: regex (same lists as the chat response check) -----------

HARD_WORD_PATTERN='\b(load-bearing|crux|honest answer|honest solution|delve|nuanced|tapestry|leverage|utilize|robust|innovative|streamline|great question|good point|absolutely|certainly|of course|awesome|honestly|to be clear|fair point|fair pushback|I should note|it.s worth noting)\b'
SOFT_WORD_PATTERN='\b(boasts?|bolstered|testament|vibrant|showcas(e|es|ing)|groundbreaking|game.?changer|cutting.?edge|paradigm shift|holistic approach|synergy|underscores?|exemplifies|nestled|in the heart of)\b'
# Federal Plain Language Guidelines' "hidden verb" nominalization.
NOMINALIZATION_PATTERN='\bthe [a-z]+(ment|tion|sion|ance) of\b'

hits=""
hard_m=$(grep -oiE "$HARD_WORD_PATTERN" <<<"$body" 2>/dev/null | tr '[:upper:]' '[:lower:]' | sort -u | paste -sd, -)
[ -n "$hard_m" ] && hits="banned words: $hard_m"

soft_all=$(grep -oiE "$SOFT_WORD_PATTERN" <<<"$body" 2>/dev/null | tr '[:upper:]' '[:lower:]')
soft_count=$(wc -l <<<"$soft_all" | tr -d ' ')
[ -z "$soft_all" ] && soft_count=0
if [ "$soft_count" -ge 2 ]; then
  soft_m=$(sort -u <<<"$soft_all" | paste -sd, -)
  hits="${hits:+$hits; }repeated AI-vocab ($soft_count occurrences: $soft_m)"
fi

if grep -qiE "$NOMINALIZATION_PATTERN" <<<"$body"; then
  hits="${hits:+$hits; }hidden-verb nominalization ('the X of' instead of a plain verb)"
fi

longest_sentence=$(awk 'BEGIN{RS="[.!?]+[ \t\n]+"} {n=split($0,w,/[ \t\n]+/); if(n>max) max=n} END{print max+0}' <<<"$body")
if [ "$longest_sentence" -gt 40 ]; then
  hits="${hits:+$hits; }sentence too long ($longest_sentence words, Federal Plain Language ceiling is ~40)"
fi

max_bullets=$(awk '/^[-*][ \t]/{c++; if(c>max) max=c; next} {c=0} END{print max+0}' <<<"$body")
if [ "$max_bullets" -gt 6 ]; then
  hits="${hits:+$hits; }flat list too long ($max_bullets items, working-memory comfortable limit is ~4-5 — Cowan 2001)"
fi

if [ -n "$hits" ]; then
  block "regex ($hits). Rewrite the PR body, cut the flagged words."
fi

# --- Stage 2: PR-structure + style/cognitive-load check via Haiku -----

# COGNITIVE_LOAD axis rules are grounded in evidence-based communication
# protocols (BLUF, SBAR, Minto Pyramid Principle) rather than house style —
# see sanity.sh's header comment for citations. Kept out of the prompt
# itself: it runs on every invocation, and the model needs the operational
# rule, not the citation.
verdict=$(claude --restricted --model haiku -p "Judge this GitHub PR description body against THREE independent axes. Report all three, even if some are clean.

AXIS 1 — PR_STRUCTURE: this is a permanent record of why the change exists, not a changelog of what changed.
- Must be prose, not a bullet-point list (a short bulleted 'Why' section area is fine if the surrounding text is prose; a body that's ALL bullets is a violation)
- One or two sentences of context before any heading
- Motivation/why comes before implementation/how
- Headings named after the specific concern (e.g. 'Why the retry budget changed'), not generic labels like 'Summary' or 'Changes'
- No test plan section unless the user explicitly asked for one
- Treats the PR as one unit — does not narrate individual commits or session history ('first I did X, then Y, then fixed Z')
- Honest about what wasn't delivered, if anything was cut from scope

AXIS 2 — STYLE: mechanical AI-writing tells (paraphrases count).
- Banned stock phrases, corporate vocabulary (crucial, delve, robust, leverage, testament, etc.)
- Rule-of-three filler, hollow significance framing, throat-clearing, negated-strawman parallelism, copula avoidance

AXIS 3 — COGNITIVE_LOAD: same six general principles as any text, applied here.
1. Point first: the main point comes before the reasoning or elaboration that led to it.
2. Context before ask: if the text needs something from the reader, the situation motivating that ask comes first, never after.
3. Clean structure: groupings/lists are genuinely distinct (no overlap) and complete (no obvious gap), not padded to hit a count.
4. Only what's needed: no restating what's already visible elsewhere in the text, no caveat that doesn't follow from something specific already stated, no elaboration beyond what was asked for.
5. Respect working-memory limits: sentences and lists short enough to hold in the head at once.
6. Unambiguous terminal state: if the text signals it is ending or concluding, that state is one of a small, plainly-stated set (e.g. done; blocked, needs X) — not hedged or left to be inferred. This checks clarity of what's said, not whether it's true.

Never flag: code blocks, inline code, file paths, commands, error strings, identifiers, numbers.

Per axis: VIOLATION only when you're sure a reader would notice it. NOTE when uncertain. Always include a concrete preferred alternative when flagging, or say 'cut it' if there's no better rewrite.

Reply with EXACTLY three lines, this format, nothing else:
PR_STRUCTURE: OK|VIOLATION: <fragment> — <reason> — prefer: <replacement or 'cut it'>|NOTE: <fragment> — <reason> — prefer: <replacement or 'cut it'>
STYLE: OK|VIOLATION: <fragment> — <reason> — prefer: <replacement or 'cut it'>|NOTE: <fragment> — <reason> — prefer: <replacement or 'cut it'>
COGNITIVE_LOAD: OK|VIOLATION: <fragment> — <reason> — prefer: <replacement or 'cut it'>|NOTE: <fragment> — <reason> — prefer: <replacement or 'cut it'>

PR BODY:
$body" 2>/dev/null)

struct_val="${verdict#*PR_STRUCTURE: }"
struct_val="${struct_val%%$'\n'*}"
style_val="${verdict#*STYLE: }"
style_val="${style_val%%$'\n'*}"
cog_val="${verdict##*COGNITIVE_LOAD: }"

violations=""

if [[ "$struct_val" == VIOLATION:* ]]; then
  violations="pr-structure: ${struct_val#VIOLATION: }"
fi
if [[ "$style_val" == VIOLATION:* ]]; then
  violations="${violations:+$violations; }style: ${style_val#VIOLATION: }"
fi
if [[ "$cog_val" == VIOLATION:* ]]; then
  violations="${violations:+$violations; }cognitive-load: ${cog_val#VIOLATION: }"
fi

if [ -n "$violations" ]; then
  block "$violations"
fi

rm -f "$counter_file"
exit 0
