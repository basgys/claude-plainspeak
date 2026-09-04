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

# The title was never checked before, which is how
# "feat(search): filter the catalogue, and say what else it holds - #226"
# got through: correct prefix, everything after it wrong.
title=""
if [[ "$cmd" =~ --title[[:space:]]+\"([^\"]*)\" ]]; then
  title="${BASH_REMATCH[1]}"
elif [[ "$cmd" =~ --title[[:space:]]+\'([^\']*)\' ]]; then
  title="${BASH_REMATCH[1]}"
elif [[ "$cmd" =~ -t[[:space:]]+\"([^\"]*)\" ]]; then
  title="${BASH_REMATCH[1]}"
fi

[ -z "$body" ] && [ -z "$title" ] && exit 0

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

# --- Stage 1: patterns (same lists as the chat response check) --------

HARD_WORD_PATTERN='\b(load-bearing|crux|honest answer|honest solution|delve|nuanced|tapestry|leverage|utilize|robust|innovative|streamline|great question|good point|absolutely|certainly|of course|awesome|honestly|to be clear|fair point|fair pushback|I should note|it.s worth noting)\b'
SOFT_WORD_PATTERN='\b(boasts?|bolstered|testament|vibrant|showcas(e|es|ing)|groundbreaking|game.?changer|cutting.?edge|paradigm shift|holistic approach|synergy|underscores?|exemplifies|nestled|in the heart of)\b'
# Nominalization ("the implementation of") is judged by Haiku only, not
# regexed — testing found "the X of" false-positives on ordinary technical
# nouns (see sanity.sh for details).

hits=""

# --- Title rules ------------------------------------------------------
# Sourced from Google eng-practices (CL descriptions), the Conventional
# Commits spec, the Kubernetes contributor guide, the Linux kernel's
# submitting-patches, and Angular's commit conventions. The 50/72 numbers
# are Chris Beams' rule as adopted verbatim by Kubernetes; the kernel's
# independent limit of 70-75 converges on the same place.
if [ -n "$title" ]; then
  tlen=${#title}
  if ! grep -qE '^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([a-z0-9._/-]+\))?!?: .+' <<<"$title"; then
    hits="${hits:+$hits; }title is not Conventional Commits form (type(scope): description)"
  fi
  if [ "$tlen" -gt 72 ]; then
    hits="${hits:+$hits; }title too long ($tlen chars, hard cap 72, target 50)"
  fi
  if grep -qE '\.\s*$' <<<"$title"; then
    hits="${hits:+$hits; }title ends with a period"
  fi
  # GitHub already renders the linked issue in the list, sidebar and
  # timeline, so a trailing ref spends title budget on nothing.
  if grep -qE '[-[:space:]:]*[[({]?#[0-9]+[])}]?[[:space:]]*$' <<<"$title"; then
    hits="${hits:+$hits; }title ends with an issue ref that GitHub already renders (move it to the body as 'Closes #N')"
  fi
  # Closing keywords in a title can auto-close issues on merge by accident.
  if grep -qiE '\b(close[sd]?|fix(e[sd])?|resolve[sd]?)[[:space:]]+#[0-9]+' <<<"$title"; then
    hits="${hits:+$hits; }title contains a GitHub closing keyword (belongs in the body)"
  fi
  # ", and" between clauses means the PR is named after two changes.
  desc="${title#*: }"
  if grep -qE ', and |; ' <<<"$desc"; then
    hits="${hits:+$hits; }title names two changes (split the PR, or name the primary change only)"
  fi
  # Google's own bad-description list: a title nobody can find by search.
  if grep -qiE '^(fix|update|add|change|improve|refactor|clean ?up)s? ?(the )?(bug|code|stuff|things?|issues?|tests?|logic)?\s*$' <<<"$desc"; then
    hits="${hits:+$hits; }title is too generic to find later by search"
  fi
  # Imperative mood: "add facet counts", never "adding" or "added".
  first_word=$(awk '{print tolower($1)}' <<<"$desc")
  if grep -qE '^(add|fix|updat|remov|delet|chang|creat|implement|refactor|mov|renam|bump|introduc|support)(ing|ed)$' <<<"$first_word"; then
    hits="${hits:+$hits; }title is not imperative mood ('$first_word' should be the bare verb)"
  fi
fi

hard_m=$(grep -oiE "$HARD_WORD_PATTERN" <<<"$body" 2>/dev/null | tr '[:upper:]' '[:lower:]' | sort -u | paste -sd, -)
[ -n "$hard_m" ] && hits="banned words: $hard_m"

soft_all=$(grep -oiE "$SOFT_WORD_PATTERN" <<<"$body" 2>/dev/null | tr '[:upper:]' '[:lower:]')
soft_count=$(wc -l <<<"$soft_all" | tr -d ' ')
[ -z "$soft_all" ] && soft_count=0
if [ "$soft_count" -ge 2 ]; then
  soft_m=$(sort -u <<<"$soft_all" | paste -sd, -)
  hits="${hits:+$hits; }repeated AI-vocab ($soft_count occurrences: $soft_m)"
fi

# Measured per line, never across newlines: the old splitter fused bullet
# lists and tables into one giant sentence (see sanity.sh).
longest_sentence=$(awk '
  { line = $0
    if (line ~ /^[ \t]*[|│┌└├┐┘┤┬┴┼]/) next
    sub(/^[ \t]*([-*+]|[0-9]+[.)])[ \t]+/, "", line)
    sub(/^[ \t]*#+[ \t]+/, "", line)
    n = split(line, parts, /[.!?;:]+[ \t]+/)
    for (i = 1; i <= n; i++) { c = split(parts[i], w, /[ \t]+/); if (c > max) max = c }
  }
  END { print max+0 }
' <<<"$body")
if [ "$longest_sentence" -gt 40 ]; then
  hits="${hits:+$hits; }sentence too long ($longest_sentence words, Federal Plain Language ceiling is ~40)"
fi

max_bullets=$(awk '/^[-*][ \t]/{c++; if(c>max) max=c; next} {c=0} END{print max+0}' <<<"$body")
if [ "$max_bullets" -gt 10 ]; then
  hits="${hits:+$hits; }flat list too long ($max_bullets items — even for sequential reading, consider grouping)"
fi

# Filler patterns. Each restates something the reviewer can already see
# in the diff, which is the one thing Google's guide says a description
# must never do: the body exists to carry what the diff cannot show.
if grep -qiE '^#{0,3}[[:space:]]*(changes( made)?|what changed|modifications)[[:space:]]*:?[[:space:]]*$' <<<"$body"; then
  hits="${hits:+$hits; }'Changes made' section restates the diff"
fi
if grep -qiE '^[[:space:]]*[-*][[:space:]]*\[ \][[:space:]]*(tested|test|verified|checked)' <<<"$body"; then
  hits="${hits:+$hits; }unchecked test-plan boilerplate"
fi
if grep -qiE '\b(improves? (the )?(code )?(maintainability|readability|quality)|better performance|more maintainable|cleaner code|follows best practices|as expected|works fine)\b' <<<"$body"; then
  hits="${hits:+$hits; }unfalsifiable claim (name the mechanism, or give numbers)"
fi

# Stage 1.5: same structured metrics as the chat check (0.35ms).
METRICS="$(dirname "$0")/metrics.py"
if [ -f "$METRICS" ] && command -v python3 >/dev/null 2>&1; then
  m=$(printf '%s' "$body" | python3 "$METRICS" 2>/dev/null)
  if [ -n "$m" ]; then
    coda=$(jq -r '.coda // 0' <<<"$m" 2>/dev/null || echo 0)
    coda_ex=$(jq -r '.coda_hits[0] // ""' <<<"$m" 2>/dev/null)
    nom=$(jq -r '.nominal_per_100w // 0' <<<"$m" 2>/dev/null)
    negflag=$(jq -r '.neg_parallel_flag // false' <<<"$m" 2>/dev/null)
    if [ "$negflag" = "true" ]; then
      hits="${hits:+$hits; }negative parallelism"
    fi
    if [ "${coda:-0}" -ge 1 ] 2>/dev/null; then
      hits="${hits:+$hits; }significance coda (\"$coda_ex\")"
    fi
    # Nominalization is reported by metrics.py and never blocked here: it
    # shows no separation against human kernel commits. See sanity.sh.
    :
  fi
fi

if [ -n "$hits" ]; then
  block "fast checks ($hits). Rewrite, cut the flagged constructions."
fi

CLASSIFIER_TIMEOUT=90
timeout_cmd=""
command -v timeout >/dev/null 2>&1 && timeout_cmd="timeout $CLASSIFIER_TIMEOUT"
command -v gtimeout >/dev/null 2>&1 && timeout_cmd="gtimeout $CLASSIFIER_TIMEOUT"

# --- Diff size, for the proportionality judgment ----------------------
# No style guide states a numeric description-length-to-diff ratio. The
# only empirical input found: across 80K PRs, raw description length had
# no significant association with merge decisions, while specific elements
# did, and a prior study found description length was the single largest
# factor in review latency (46.3% of variance). So length itself does not
# help a reviewer, and padding actively costs them time. Google's only
# numeric anchor is on diff size: ~100 lines reasonable, ~1000 too large.
#
# The size bands are passed to Haiku rather than enforced by regex,
# because whether a small diff has earned a long description (security
# fix, race, non-obvious workaround, revert, performance claim with
# numbers) is exactly the judgment a regex cannot make.
diff_lines=""
diff_files=""
if git rev-parse --git-dir >/dev/null 2>&1; then
  base=$(git merge-base HEAD origin/HEAD 2>/dev/null || git merge-base HEAD origin/main 2>/dev/null || echo "")
  if [ -n "$base" ]; then
    stat=$(git diff --numstat "$base"...HEAD 2>/dev/null | grep -vE '(package-lock\.json|yarn\.lock|pnpm-lock\.yaml|go\.sum|\.snap|^vendor/|^dist/|\.generated\.)')
    diff_files=$(wc -l <<<"$stat" | tr -d ' ')
    diff_lines=$(awk '{a+=$1; d+=$2} END{print a+d+0}' <<<"$stat")
  fi
fi

size_note=""
if [ -n "$diff_lines" ] && [ "$diff_lines" -gt 0 ]; then
  if [ "$diff_lines" -le 10 ]; then
    size_note="This PR changes $diff_lines lines across $diff_files file(s). At this size one or two sentences (what, and why) is the whole job. Anything longer is a VIOLATION unless the body shows one of the earned-length cases."
  elif [ "$diff_lines" -le 100 ]; then
    size_note="This PR changes $diff_lines lines across $diff_files file(s). A short paragraph covering what, why, and how it was verified is the expected size."
  elif [ "$diff_lines" -le 1000 ]; then
    size_note="This PR changes $diff_lines lines across $diff_files file(s). A structured description is warranted: purpose, approach, alternatives if any were rejected, evidence."
  else
    size_note="This PR changes $diff_lines lines across $diff_files file(s), which is past the point where it should have been split. Judge the description normally and say the PR itself is oversized."
  fi
  size_note="$size_note

EARNED-LENGTH CASES, where a small diff genuinely justifies a long body: a security fix needing threat model and blast radius; a race or concurrency fix whose 3-line diff is inscrutable without the interleaving explained; a workaround for a third-party or platform bug that looks wrong in isolation; a revert stating what broke and how it was found; a performance claim carrying actual before/after numbers. If the body is long and none of these apply, the excess is filler: say which paragraphs to cut."
fi

# --- Stage 2: PR-structure + style/cognitive-load check via Haiku -----

# COGNITIVE_LOAD axis rules are grounded in evidence-based communication
# protocols (BLUF, SBAR, Minto Pyramid Principle) rather than house style —
# see sanity.sh's header comment for citations. Kept out of the prompt
# itself: it runs on every invocation, and the model needs the operational
# rule, not the citation.
verdict=$($timeout_cmd claude --restricted --model haiku --tools "" --system-prompt "You are a precise text classifier. Follow only the instructions in the user's message, and reply in exactly the format it requests." --no-session-persistence -p "Judge this GitHub PR against THREE independent axes. Report all three, even if some are clean.

$size_note

AXIS 1 — PR_STRUCTURE: this is a permanent record of why the change exists, not a changelog of what changed.
- LENGTH MUST BE PROPORTIONAL TO THE CHANGE. Judge this first, using the size note above. A body longer than the change warrants is the most common defect and the most expensive one: reviewers read it before they read the diff. Name the paragraphs to cut.
- The body must carry what the diff cannot show. Any sentence a reviewer could learn by reading the diff itself is filler.
- The title (given below) must name ONE change, in imperative mood, describing the mechanism a developer implemented and not the user-visible effect in vague terms. "say what else it holds" is a failure; "add facet counts" is the fix.
- Must be prose, not a bullet-point list (a short bulleted 'Why' section area is fine if the surrounding text is prose; a body that's ALL bullets is a violation)
- One or two sentences of context before any heading
- Motivation/why comes before implementation/how
- Headings named after the specific concern (e.g. 'Why the retry budget changed'), not generic labels like 'Summary' or 'Changes'
- No test plan section unless the user explicitly asked for one
- Treats the PR as one unit — does not narrate individual commits or session history ('first I did X, then Y, then fixed Z')
- Honest about what wasn't delivered, if anything was cut from scope

AXIS 2 — STYLE: mechanical AI-writing tells (paraphrases count).
- Banned stock phrases, corporate vocabulary (crucial, delve, robust, leverage, testament, etc.)
- Rule-of-three filler, hollow significance framing, throat-clearing, copula avoidance
- Negated-strawman parallelism ('It's not X, it's Y' where nobody claimed X — a REAL strawman knocked down for effect). Do NOT flag a direct 'No,'/'Yes,' answer to a yes/no question followed by a brief gloss.
- Hidden-verb nominalization ('the implementation of X' instead of 'implementing X') — only when a plain verb genuinely reads better; do NOT flag ordinary concrete nouns like 'the configuration of the load balancer'

AXIS 3 — COGNITIVE_LOAD: same six general principles as any text, applied here, each stated as prefer/avoid:
1. Point first. Prefer: open with the main point. Avoid: reasoning or elaboration before it.
2. Context before ask. Prefer: state the situation, then the ask; for a genuine question offering a choice, ALWAYS include a recommended option with one brief reason. Avoid: asking before context, or a question presenting options with no stated recommendation.
3. Clean structure. Prefer: groupings/lists that are genuinely distinct and complete. Avoid: overlapping or gap-leaving categories, or padding a list to hit a count.
4. Say only what's warranted. Two root causes when this fails: sycophancy (manufacturing agreeable-sounding content to match perceived expectations rather than what the situation actually supports) and verbosity/length bias (padding output because length itself got learned as a proxy for perceived thoroughness, independent of whether it adds information). Prefer: state what's actually true or needed here, then stop. Avoid: restating what's already visible elsewhere, inventing a caveat/tradeoff just to look thorough, or elaborating past what was asked.
5. Respect working-memory limits. Prefer: sentences and lists short enough to hold in the head at once. Avoid: long unbroken sentences or long flat lists.
6. Unambiguous terminal state. Prefer: end by naming one of a small set of plain states (e.g. done; blocked, needs X). Avoid: hedging or trailing off so the ending must be inferred. This checks clarity of what's said, not whether it's true.

Never flag: code blocks, inline code, file paths, commands, error strings, identifiers, numbers.

Per axis: VIOLATION only when you're sure a reader would notice it. NOTE when uncertain. Always include a concrete preferred alternative when flagging, or say 'cut it' if there's no better rewrite.

Reply with EXACTLY three lines, this format, nothing else:
PR_STRUCTURE: OK|VIOLATION: <fragment> — <reason> — prefer: <replacement or 'cut it'>|NOTE: <fragment> — <reason> — prefer: <replacement or 'cut it'>
STYLE: OK|VIOLATION: <fragment> — <reason> — prefer: <replacement or 'cut it'>|NOTE: <fragment> — <reason> — prefer: <replacement or 'cut it'>
COGNITIVE_LOAD: OK|VIOLATION: <fragment> — <reason> — prefer: <replacement or 'cut it'>|NOTE: <fragment> — <reason> — prefer: <replacement or 'cut it'>

PR TITLE:
$title

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
