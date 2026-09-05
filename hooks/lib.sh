#!/bin/bash
# Checks shared by sanity.sh (chat replies) and pr-check.sh (PR text).
# Sourced, never executed. Callers set `hits` and read it back.
#
# Rules come from two places: the user's writing rules, and the common
# LLM-writing tells at en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing.
# The counted ones are grounded in published work — Federal Plain Language
# (Plain Writing Act 2010) for the ~40-word sentence ceiling, Cowan (2001)
# for the list-length ceiling. Citations stay here rather than in any
# runtime prompt.

NL=$'\n'
METRICS="$(dirname "${BASH_SOURCE[0]}")/metrics.py"

# One flag per line, quoting the text that fired it. A bare rule name makes
# the writer guess which sentence it meant, and a guess costs an attempt.
add_hit() { hits="${hits:+$hits$NL}- $1"; }

# The user's explicit banned tokens. Any occurrence flags.
HARD_WORD_PATTERN='\b(load-bearing|crux|honest answer|honest solution|delve|nuanced|tapestry|leverage|utilize|robust|innovative|streamline|great question|good point|absolutely|certainly|of course|awesome|honestly|to be clear|fair point|fair pushback|I should (note|flag|mention|call out|point out|say)|it.s worth noting)\b'

# Fine once, a tell when repeated. Needs >=2 hits.
SOFT_WORD_PATTERN='\b(boasts?|bolstered|testament|vibrant|showcas(e|es|ing)|groundbreaking|game.?changer|cutting.?edge|paradigm shift|holistic approach|synergy|underscores?|exemplifies|nestled|in the heart of)\b'

PHRASE_PATTERN='not (just |merely |simply )?[a-zA-Z ]{1,40}(,? but |, it.s )|not (just |only )?about [a-zA-Z ]{1,40}(,? it.s about|, but about)|whether (you.re|it.s|this is) [a-zA-Z ]{1,30}(,| or)|in (today.s|this) (fast-paced|ever-evolving|ever-changing) world|when it comes to|at the end of the day|let.s (dive|break|unpack)|unlock the (power|potential) of|navigate the complexities|harness the power of|embark on (a|an|this)|seamless(ly)? integrat|(stands|serves) as a (testament|reminder)|is a testament to|plays a (crucial|pivotal|vital|key) role|sets the stage for|underscores? (its|the) importance|,\s*(highlighting|underscoring|emphasizing|reflecting|symbolizing|demonstrating|showcasing) (the|its|how|that)|\bin (connection|association) with\b|\b(widely|particularly) associated with\b|(^|[.!?] )rather, (it|this|that|they|the)\b|\bno [a-z]+, no [a-z]+, just\b|(^|[.!?] )(here.s|here is) (what|the (thing|key|short)) |\b(two|three|four) things (I|to) (should |want to )?(flag|note|mention|call out)\b|\bworth (acting on|flagging|watching|highlighting|calling out|raising)\b|\bone to watch\b'

# Fenced code is never prose. Blockquotes are NOT stripped: the exemption
# was purely syntactic (matches a leading '>'), so it was a full bypass —
# wrap anything in blockquote formatting and the checks went blind. That
# happened non-adversarially too, with commentary trailing off inside a
# blockquote.
strip_code() {
  awk '/^```/ { infence = !infence; next } infence { next } { print }'
}

check_words() {
  local text="$1" hard_m soft_all soft_count soft_m phrase_m
  hard_m=$(grep -oiE "$HARD_WORD_PATTERN" <<<"$text" 2>/dev/null \
    | tr '[:upper:]' '[:lower:]' | sort -u | paste -sd, -)
  [ -n "$hard_m" ] && add_hit "banned words: $hard_m — delete each one; rephrase the sentence without a synonym for it"

  soft_all=$(grep -oiE "$SOFT_WORD_PATTERN" <<<"$text" 2>/dev/null | tr '[:upper:]' '[:lower:]')
  soft_count=$(wc -l <<<"$soft_all" | tr -d ' ')
  [ -z "$soft_all" ] && soft_count=0
  if [ "$soft_count" -ge 2 ]; then
    soft_m=$(sort -u <<<"$soft_all" | paste -sd, -)
    add_hit "repeated AI-vocab, $soft_count occurrences of: $soft_m — one use is fine, so cut all but at most one"
  fi

  phrase_m=$(grep -oiE "$PHRASE_PATTERN" <<<"$text" 2>/dev/null | sort -u | head -3 \
    | sed 's/^/"/; s/$/"/' | paste -sd'; ' -)
  [ -n "$phrase_m" ] && add_hit "templated phrasing (not-X-but-Y / throat-clearing / hollow significance) at: $phrase_m — delete the construction and state the point directly"
}

# Measured per LINE, never across newlines: an RS spanning lines fuses a
# bullet list or a table into one giant "sentence" and blocks every rewrite
# until the hook gives up. Splits on ;: too — a semicolon-joined
# enumeration is dense legitimate writing, and each clause is its own unit.
# Naming the offending sentence is what makes this fixable in one attempt.
check_sentence_length() {
  local out count text
  out=$(awk '
    { line = $0
      if (line ~ /^[ \t]*[|│┌└├┐┘┤┬┴┼]/) next
      sub(/^[ \t]*([-*+]|[0-9]+[.)])[ \t]+/, "", line)
      sub(/^[ \t]*#+[ \t]+/, "", line)
      n = split(line, parts, /[.!?;:]+[ \t]+/)
      for (i = 1; i <= n; i++) {
        c = split(parts[i], w, /[ \t]+/)
        if (c > max) { max = c; worst = ""; for (j = 1; j <= 10 && j <= c; j++) worst = worst w[j] " " }
      }
    }
    END { print (max+0) "\t" worst }
  ' <<<"$1")
  count=${out%%$'\t'*}
  text=${out#*$'\t'}
  [ "$count" -gt 40 ] && add_hit "sentence too long ($count words, ceiling ~40), starting \"${text}...\" — split it at its first natural break"
}

# Cowan's ~4-chunk limit is for material held in memory at once. A
# sequential checklist is read in order, so genuinely necessary 8-step
# lists were being flagged at the original threshold of 6. Loosened to 10
# as a "too long even for sequential reading" ceiling.
check_list_length() {
  local n
  n=$(awk '/^[-*][ \t]/{c++; if(c>max) max=c; next} {c=0} END{print max+0}' <<<"$1")
  [ "$n" -gt 10 ] && add_hit "flat list too long ($n items) — group them under headings, or cut to the ones that matter"
}

# Shapes needing a count or a two-clause test, which regex cannot do.
# Silently skipped when python3 is absent, leaving the bash checks intact.
check_metrics() {
  local m neg negn neg_ex coda coda_ex vague vague_ex
  [ -f "$METRICS" ] && command -v python3 >/dev/null 2>&1 || return 0
  m=$(printf '%s' "$1" | python3 "$METRICS" 2>/dev/null)
  [ -n "$m" ] || return 0

  neg=$(jq -r '.neg_parallel_flag // false' <<<"$m" 2>/dev/null)
  if [ "$neg" = "true" ]; then
    negn=$(jq -r '.neg_parallel // 0' <<<"$m" 2>/dev/null)
    neg_ex=$(jq -r '[.neg_parallel_hits[]? | "\"" + . + "\""] | join("; ")' <<<"$m" 2>/dev/null)
    add_hit "negative parallelism (x$negn) at: ${neg_ex:-<no fragment captured>} — each states what is NOT the case right after what is. Delete the negated half of each; keep it only where it corrects a belief the reader holds"
  fi

  vague=$(jq -r '.vague_referent // 0' <<<"$m" 2>/dev/null)
  if [ "${vague:-0}" -ge 1 ] 2>/dev/null; then
    vague_ex=$(jq -r '[.vague_referent_hits[]? | "\"" + . + "\""] | join("; ")' <<<"$m" 2>/dev/null)
    add_hit "unnamed referent at: $vague_ex — the sentence says something counts and ends before naming it. Name the thing in that sentence"
  fi

  coda=$(jq -r '.coda // 0' <<<"$m" 2>/dev/null)
  if [ "${coda:-0}" -ge 1 ] 2>/dev/null; then
    coda_ex=$(jq -r '[.coda_hits[]? | "\"" + . + "\""] | join("; ")' <<<"$m" 2>/dev/null)
    add_hit "significance coda (x$coda) at: $coda_ex — a verbless fragment, then a clause commenting on it. Say what follows from it, or cut the clause"
    coda_flagged=1
  fi
}

# Literal-form significance coda, a floor under metrics.py's two-clause
# test: a clipped verdict, a comma, then a clause asserting the thing
# matters in place of showing why. "Mixed, and the split matters." Skipped
# when metrics.py already flagged one, so the same span is never quoted
# twice — a doubled flag reads as two separate defects and costs an attempt.
CODA_LITERAL_PATTERN='\b(and|but) (the|that|this|it|those|these) [a-z]{2,14}( [a-z]{2,14})?( (really|actually|genuinely))? (matters|is the point|counts|is what counts|makes the difference|changes everything)\b|\b(that|this|which)( part| bit)? (really |actually )?matters\b|(^|[.!?] )[A-Z][a-z]{2,12}(ed)?, (and|but) (the|that|this|it) [a-z]{2,14} (is|are|was|were|comes|come|belongs|follows)\b'

check_coda_literal() {
  local m
  [ "${coda_flagged:-0}" = "1" ] && return 0
  m=$(grep -oiE "$CODA_LITERAL_PATTERN" <<<"$1" 2>/dev/null | head -3 \
    | sed 's/^/"/; s/$/"/' | paste -sd'; ' -)
  [ -n "$m" ] && add_hit "significance coda at: $m — say what follows from it, or cut the clause"
}

check_emdash() {
  local n words budget over
  n=$(grep -o '—' <<<"$1" 2>/dev/null | wc -l | tr -d ' ')
  words=$(wc -w <<<"$1" | tr -d ' ')
  budget=$((words / 150))
  [ "$budget" -lt 3 ] && budget=3
  if [ "${n:-0}" -gt "$budget" ]; then
    over=$((n - budget))
    add_hit "em dash overused ($n in $words words, budget $budget) — replace at least $over with a comma, a full stop, or nothing"
  fi
}

# Cowan again, applied to figures: a prose paragraph carrying seven
# durations and counts forces the reader to hold all of them to follow the
# argument. Tables and lists are exempt — those are scanned column-wise.
# Identifiers (list.go:412, steam_app) are excluded by the token shape.
check_figure_density() {
  local n
  n=$(awk '
    function flush(  i, tok, t, c, k) {
      if (para == "") return
      c = 0; k = split(para, t, /[ \t]+/)
      for (i = 1; i <= k; i++) {
        tok = t[i]; gsub(/^[(\[]|[.,;:)\]]+$/, "", tok)
        if (tok ~ /^[0-9][0-9,]*(\.[0-9]+)?(h[0-9]+m|m[0-9]+s|[hmsd]|%|x|GB|MB|KB|ms)?$/) c++
      }
      if (c > max) max = c
      para = ""
    }
    /^[ \t]*$/ { flush(); next }
    /^[ \t]*([-*+]|[0-9]+[.)])[ \t]/ { flush(); next }
    /^[ \t]*[|│┌└├┐┘┤┬┴┼]/ { flush(); next }
    { para = para " " $0 }
    END { flush(); print max+0 }
  ' <<<"$1")
  [ "$n" -gt 5 ] && add_hit "too many figures in one prose paragraph ($n) — move them to a list or table, or cut to the ones that carry the argument"
}

# Every check runs before anything blocks, so one verdict lists all the
# flags. A writer told about one violation at a time spends an attempt per
# rule, which is how a draft tripping three checks exhausts the budget
# without ever being wrong three times over.
run_checks() {
  local text="$1"
  coda_flagged=0
  check_words "$text"
  check_metrics "$text"
  check_coda_literal "$text"
  check_emdash "$text"
  check_sentence_length "$text"
  check_figure_density "$text"
  check_list_length "$text"
}
