#!/bin/bash
# Stop hook: per-turn gatekeeper for the final assistant message, judged on
# two independent axes (style, cognitive load) against CLAUDE.md's writing
# rules + common LLM-writing tells
# (en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing). Stateless — no
# memory of past turns, not a conversational agent.
#
# Stage 1: regex over banned words + known templated phrasings. Free,
# instant, catches most offenders. If it hits, block immediately.
# Stage 2: only runs when stage 1 passes clean. A one-shot Haiku classifier
# (--restricted, so it loads no settings/hooks and can't recursively trigger
# this hook, while still using normal account auth) whose sole job is
# spotting sentence-STRUCTURE tells regex can't reliably match (rule-of-
# three, hollow significance framing, throat-clearing, copula avoidance,
# paraphrased negative-parallelism). Keeps the common case free while still
# catching what regex misses.
set -uo pipefail

MAX_ATTEMPTS=3

input=$(cat)
session_id=$(jq -r '.session_id // "unknown"' <<<"$input")
counter_file="/tmp/.claude-sanity-attempts-${session_id}"

attempt=0
[ -f "$counter_file" ] && attempt=$(cat "$counter_file" 2>/dev/null || echo 0)
[ -z "$attempt" ] && attempt=0

msg=$(jq -r '.last_assistant_message // empty' <<<"$input")
[ -z "$msg" ] && exit 0

# A prior attempt already maxed out and gave up — don't re-enter.
if [ "$attempt" -ge "$MAX_ATTEMPTS" ]; then
  rm -f "$counter_file"
  exit 0
fi

block() {
  attempt=$((attempt + 1))
  echo "$attempt" > "$counter_file"
  if [ "$attempt" -ge "$MAX_ATTEMPTS" ]; then
    jq -n --arg r "$1" --arg m "Sanity check: gave up after $MAX_ATTEMPTS correction attempts, letting it through as-is ($1)" \
      '{systemMessage: $m}'
    rm -f "$counter_file"
    exit 0
  fi
  jq -n --arg r "$1 (attempt $attempt/$MAX_ATTEMPTS)" --arg m "Sanity check: rewriting (attempt $attempt/$MAX_ATTEMPTS) — $1" \
    '{systemMessage: $m, hookSpecificOutput:{hookEventName:"Stop",decision:"block",reason:$r}}'
  exit 0
}

pass() {
  if [ "$attempt" -gt 0 ]; then
    jq -n --arg m "Sanity check: passed after $attempt correction(s)." '{systemMessage: $m}'
  fi
  rm -f "$counter_file"
  exit 0
}

# Content the agent is quoting verbatim (fenced code, blockquotes) is never
# ours to rewrite — strip it before either stage looks at the message.
checktext=$(awk '
  /^```/ { infence = !infence; next }
  infence { next }
  /^[[:space:]]*>/ { next }
  { print }
' <<<"$msg")

# --- Stage 1: regex ---------------------------------------------------

# Hard list: CLAUDE.md's own explicit banned tokens. Zero tolerance by the
# user's own standing instruction — any occurrence blocks.
HARD_WORD_PATTERN='\b(load-bearing|crux|honest answer|honest solution|delve|nuanced|tapestry|leverage|utilize|robust|innovative|streamline|great question|good point|absolutely|certainly|of course|awesome|honestly|to be clear|fair point|fair pushback|I should note|it.s worth noting)\b'

# Soft list: words that are fine on a single, ordinary use but are the tell
# when repeated — the actual complaint is "this appears every sentence",
# not "this word exists". Requires >=2 total hits to flag.
SOFT_WORD_PATTERN='\b(boasts?|bolstered|testament|vibrant|showcas(e|es|ing)|groundbreaking|game.?changer|cutting.?edge|paradigm shift|holistic approach|synergy|underscores?|exemplifies|nestled|in the heart of)\b'

PHRASE_PATTERN='not (just |merely |simply )?[a-zA-Z ]{1,40}(,? but |, it.s )|not (just |only )?about [a-zA-Z ]{1,40}(,? it.s about|, but about)|whether (you.re|it.s|this is) [a-zA-Z ]{1,30}(,| or)|in (today.s|this) (fast-paced|ever-evolving|ever-changing) world|when it comes to|at the end of the day|let.s (dive|break|unpack)|unlock the (power|potential) of|navigate the complexities|harness the power of|embark on (a|an|this)|seamless(ly)? integrat|(stands|serves) as a (testament|reminder)|is a testament to|plays a (crucial|pivotal|vital|key) role|sets the stage for|underscores? (its|the) importance|,\s*(highlighting|underscoring|emphasizing|reflecting|symbolizing|demonstrating|showcasing) (the|its|how|that)|\bin (connection|association) with\b|\b(widely|particularly) associated with\b'

hits=""
hard_m=$(grep -oiE "$HARD_WORD_PATTERN" <<<"$checktext" 2>/dev/null | tr '[:upper:]' '[:lower:]' | sort -u | paste -sd, -)
[ -n "$hard_m" ] && hits="banned words: $hard_m"

soft_all=$(grep -oiE "$SOFT_WORD_PATTERN" <<<"$checktext" 2>/dev/null | tr '[:upper:]' '[:lower:]')
soft_count=$(wc -l <<<"$soft_all" | tr -d ' ')
[ -z "$soft_all" ] && soft_count=0
if [ "$soft_count" -ge 2 ]; then
  soft_m=$(sort -u <<<"$soft_all" | paste -sd, -)
  hits="${hits:+$hits; }repeated AI-vocab ($soft_count occurrences: $soft_m)"
fi

if grep -qiE "$PHRASE_PATTERN" <<<"$checktext"; then
  hits="${hits:+$hits; }templated LLM phrasing (not-X-but-Y / throat-clearing / hollow significance)"
fi

emdash_count=$(grep -o '—' <<<"$checktext" 2>/dev/null | wc -l | tr -d ' ')
[ -z "$emdash_count" ] && emdash_count=0
if [ "$emdash_count" -ge 3 ]; then
  hits="${hits:+$hits; }em dash overused ($emdash_count occurrences)"
fi

if [ -n "$hits" ]; then
  block "Style check failed [regex] ($hits). Rewrite per CLAUDE.md writing rules: cut the flagged words/constructions, stay terse, no filler. Quoted/code content is exempt — this only matched text you authored."
fi

# --- Stage 2: structural check via Haiku, only when stage 1 passed ----

verdict=$(claude --restricted --model haiku -p "You judge one message against one person's writing rules, on TWO independent axes. Report both, even if one is clean.

AXIS 1 — STYLE: mechanical AI-writing tells (paraphrases count, not just exact wording).
- Filler/hedging, banned stock phrases, corporate vocabulary (crucial, delve, robust, leverage, testament, etc.)
- Rule-of-three lists used as filler, hollow significance framing ('X reflects/underscores a deeper Y')
- Throat-clearing before the answer, negated-strawman parallelism ('not X, it is Y' where nobody claimed X)
- Copula avoidance ('serves as' instead of 'is')

AXIS 2 — COGNITIVE_LOAD: protect the reader's attention, their scarcest resource, independent of whether the text sounds AI-generated. Every sentence that costs extra parsing effort without adding real information is a defect.
- Buried lede: the actual finding or decision is not the first sentence
- Ambiguous outcome signaling: when reporting stopped/finished/blocked/needs-clarification, that status is not stated plainly and immediately
- Fake due diligence: a caveat, tradeoff, or comparison that does not follow from anything specific already stated in THIS text — the kind of hedge that could be pasted into any answer regardless of topic
- Exhaustive tradeoff narrative in place of a decision plus one brief reason
- Formulaic closing that lists strengths then pivots to challenges/future work ('Despite its X, it faces Y... future improvements could address this') when nobody asked for a balanced retrospective
- Any other sentence structure that makes the reader work harder than the content requires

Never flag on either axis: code blocks, inline code, file paths, commands, error strings, identifiers, numbers, or anything the author is quoting/relaying verbatim (another person's words, a file's contents, a tool's output) rather than writing themselves — content the author didn't compose isn't theirs to be judged on. Fenced code blocks and blockquote lines have already been stripped from the text below; if what remains still reads like a pasted excerpt, don't flag it either.
Do NOT flag: plain technical writing, terse fragments, legitimate lists of genuinely distinct facts, normal use of 'and'/'but'. A word from the checklist below used ONCE, in an ordinary sentence, is not a violation by itself — the tell is the word recurring or the sentence being built around it, not its mere presence.

Per axis: VIOLATION only when you are sure the reader would notice it. NOTE when something feels off but you are not certain enough to force a rewrite — these are surfaced to the reader, not auto-corrected.

Whenever you flag VIOLATION or NOTE, include a concrete preferred alternative — the actual replacement wording or structure, not just a description of what's wrong. If no rewrite is obviously better (e.g. the fix is 'just cut this sentence'), say that instead.

Reply with EXACTLY two lines, this format, nothing else:
STYLE: OK|VIOLATION: <fragment> — <reason> — prefer: <replacement or 'cut it'>|NOTE: <fragment> — <reason> — prefer: <replacement or 'cut it'>
COGNITIVE_LOAD: OK|VIOLATION: <fragment> — <reason> — prefer: <replacement or 'cut it'>|NOTE: <fragment> — <reason> — prefer: <replacement or 'cut it'>

TEXT:
$checktext" 2>/dev/null)

style_val="${verdict#*STYLE: }"
style_val="${style_val%%$'\n'*}"
cog_val="${verdict#*COGNITIVE_LOAD: }"

violations=""
notes=""

if [[ "$style_val" == VIOLATION:* ]]; then
  violations="style: ${style_val#VIOLATION: }"
elif [[ "$style_val" == NOTE:* ]]; then
  notes="style: ${style_val#NOTE: }"
fi

if [[ "$cog_val" == VIOLATION:* ]]; then
  violations="${violations:+$violations; }cognitive-load: ${cog_val#VIOLATION: }"
elif [[ "$cog_val" == NOTE:* ]]; then
  notes="${notes:+$notes; }cognitive-load: ${cog_val#NOTE: }"
fi

if [ -n "$violations" ]; then
  block "Style check failed [$violations]. Rewrite per CLAUDE.md writing rules."
fi

if [ -n "$notes" ]; then
  jq -n --arg m "Style note (not blocking) [$notes]" '{systemMessage: $m}'
  rm -f "$counter_file"
  exit 0
fi

pass
