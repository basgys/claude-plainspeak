#!/bin/bash
# PreToolUse/Bash hook: gatekeeps `gh pr create` / `gh pr edit --body` the
# same way sanity.sh gatekeeps chat replies, plus PR-specific rules for the
# title and body. Blocks via exit 2, whose stderr is fed back to the
# assistant.
#
# Everything runs locally. The Haiku classifier that used to run after these
# checks is gone, so the judgments needing a reader — whether the body length
# suits the diff, whether the approach's shortcomings are named, whether the
# reasoning survives a dead link — are no longer made. What remains is what a
# regex can decide.
set -uo pipefail
source "$(dirname "$0")/lib.sh"

# Matches sanity.sh. A check costs local CPU, so the budget is set by what a
# rewrite costs the writer rather than by what a verdict costs.
MAX_ATTEMPTS=5

input=$(cat)
[ "$(jq -r '.tool_name // ""' <<<"$input")" != "Bash" ] && exit 0
cmd=$(jq -r '.tool_input.command // ""' <<<"$input")

grep -qE '\bgh\s+pr\s+(create|edit)\b' <<<"$cmd" || exit 0
grep -qE -- '--body(-file)?\b' <<<"$cmd" || exit 0

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

body=""
if [[ "$cmd" =~ --body-file[[:space:]]+([^[:space:]]+) ]]; then
  bodyfile="${BASH_REMATCH[1]}"
  [ -f "$bodyfile" ] && body=$(cat "$bodyfile")
elif [[ "$cmd" == *"<<'EOF'"* || "$cmd" == *'<<"EOF"'* || "$cmd" == *"<<EOF"* ]]; then
  body=$(awk '/<<['\''"]?EOF['\''"]?/{f=1;next} /^EOF$/{f=0} f' <<<"$cmd")
elif [[ "$cmd" =~ --body[[:space:]]+\"([^\"]*)\" ]]; then
  body="${BASH_REMATCH[1]}"
fi

# The title was unchecked until a PR titled "feat(search): filter the
# catalogue, and say what else it holds - #226" got through: correct
# prefix, everything after it wrong.
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
    echo "Sanity (PR): gave up after $MAX_ATTEMPTS attempts, letting the command through as-is ($1)." >&2
    rm -f "$counter_file"
    exit 0
  fi
  cat >&2 <<EOM
PR description blocked, attempt $attempt of $MAX_ATTEMPTS. Fix every item below, then re-run the command.

FLAGGED:
$1

HOW TO FIX: edit only the flagged parts of the title and body. Keep everything that was not flagged. Do not mention this check in the PR text.
EOM
  exit 2
}

hits=""

# --- Title -----------------------------------------------------------
# Sourced from Google eng-practices (google.github.io/eng-practices/review/
# developer/cl-descriptions.html), Conventional Commits, the Kubernetes
# contributor guide and the kernel's submitting-patches. The 72-char cap is
# Chris Beams' rule as Kubernetes adopted it; the kernel's independent
# 70-75 converges on the same place.
if [ -n "$title" ]; then
  grep -qE '^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([a-z0-9._/-]+\))?!?: .+' <<<"$title" \
    || add_hit "title is not Conventional Commits form (type(scope): description)"
  [ "${#title}" -gt 72 ] && add_hit "title too long (${#title} chars, hard cap 72, target 50)"
  grep -qE '\.\s*$' <<<"$title" && add_hit "title ends with a period"
  # GitHub renders the linked issue in the list, sidebar and timeline, so a
  # trailing ref spends title budget on nothing.
  grep -qE '[-[:space:]:]*[[({]?#[0-9]+[])}]?[[:space:]]*$' <<<"$title" \
    && add_hit "title ends with an issue ref that GitHub already renders (move it to the body as 'Closes #N')"
  # A closing keyword in a title can auto-close an issue on merge by accident.
  grep -qiE '\b(close[sd]?|fix(e[sd])?|resolve[sd]?)[[:space:]]+#[0-9]+' <<<"$title" \
    && add_hit "title contains a GitHub closing keyword (belongs in the body)"

  desc="${title#*: }"
  grep -qE ', and |; ' <<<"$desc" \
    && add_hit "title names two changes (split the PR, or name the primary change only)"
  # Google's own bad-description list, verbatim: "Fix bug", "Fix build",
  # "Add patch", "Moving code from A to B", "Phase 1", "Add convenience
  # functions", "kill weird URLs". A future developer searches version
  # history by this line, so a title that describes no specific change
  # cannot be found by the person who needs it.
  # The bare-noun form is the same defect wearing a Conventional Commits
  # prefix: "fix: bug" puts Google's worst example after a colon, where the
  # verb-led pattern below cannot see it.
  if grep -qiE '^(the )?(bug|build|patch|code|stuff|things?|issues?|problems?|errors?|tests?|logic|typos?|improvements?|updates?|changes?|fixes|cleanup|refactor(ing)?|convenience functions?)\s*$' <<<"$desc" \
    || grep -qiE '^(fix|update|add|change|improve|refactor|clean ?up)s? ?(the )?(bug|build|patch|code|stuff|things?|issues?|tests?|logic|convenience functions?)?\s*$' <<<"$desc" \
    || grep -qiE '^(phase|part|step|stage)[[:space:]]*[0-9ivx]+\.?$' <<<"$desc" \
    || grep -qiE '^mov(e|ing) (the )?(code|files?|logic|stuff) (from|to|out of)\b' <<<"$desc"; then
    add_hit "title is too generic to find later by search — name the specific change, as Google's CL-description guide requires ('Remove the size limit on the RPC server message freelist', never 'Fix bug')"
  fi
  first_word=$(awk '{print tolower($1)}' <<<"$desc")
  grep -qE '^(add|fix|updat|remov|delet|chang|creat|implement|refactor|mov|renam|bump|introduc|support)(ing|ed)$' <<<"$first_word" \
    && add_hit "title is not imperative mood ('$first_word' should be the bare verb)"

  # Tags are optional and belong in the body when long. Google: too many
  # tags, or tags that are too long, overwhelm the first line and obscure
  # the content. Conventional Commits' scope already carries the category
  # here, so a bracketed tag on top of it is doubled labelling.
  tag_chars=$(grep -oE '^([[:space:]]*\[[^]]*\])+' <<<"$title" | tr -d ' ')
  if [ "${#tag_chars}" -gt 0 ]; then
    tag_count=$(grep -o '\[' <<<"$tag_chars" | wc -l | tr -d ' ')
    if [ "$tag_count" -gt 1 ] || [ "${#tag_chars}" -gt 16 ]; then
      add_hit "title carries $tag_count bracketed tag(s) taking ${#tag_chars} chars — long or stacked tags obscure the content. Use the Conventional Commits scope, or move the tags to the body"
    fi
  fi
fi

# --- Body ------------------------------------------------------------
run_checks "$(strip_code <<<"$body")"

# Each of these restates something the reviewer can already see in the
# diff, which is the one thing Google's guide says a description must never
# do: the body exists to carry what the diff cannot show.
grep -qiE '^#{0,3}[[:space:]]*(changes( made)?|what changed|modifications)[[:space:]]*:?[[:space:]]*$' <<<"$body" \
  && add_hit "'Changes made' section restates the diff"
grep -qiE '^[[:space:]]*[-*][[:space:]]*\[ \][[:space:]]*(tested|test|verified|checked)' <<<"$body" \
  && add_hit "unchecked test-plan boilerplate"
grep -qiE '\b(improves? (the )?(code )?(maintainability|readability|quality)|better performance|more maintainable|cleaner code|follows best practices|as expected|works fine)\b' <<<"$body" \
  && add_hit "unfalsifiable claim (name the mechanism, or give numbers)"

# Google: a heading named after the specific concern tells a future reader
# what the section decides. A generic label tells them nothing, and costs a
# line they have to read to find that out.
generic_heading=$(grep -oiE '^#{1,4}[[:space:]]*(summary|overview|details|background|description|notes?|context|implementation|approach)[[:space:]]*:?[[:space:]]*$' <<<"$body" \
  | sed 's/^#*[[:space:]]*//' | sort -u | paste -sd, -)
[ -n "$generic_heading" ] \
  && add_hit "generic heading(s): $generic_heading — name the specific concern instead ('Why the retry budget changed')"

# A body opening on a heading gives the reader structure before it gives
# them the change. One or two sentences of context come first.
grep -qE '^[[:space:]]*#' <<<"$(sed '/^[[:space:]]*$/d' <<<"$body" | head -1)" \
  && add_hit "body opens with a heading — put one or two sentences of context above it"

# An all-bullets body is a changelog. The reasoning a reviewer needs lives
# in the sentences between the facts, and bullets delete them.
body_prose=$(sed -e '/^```/,/^```/d' -e '/^[[:space:]]*$/d' -e '/^[[:space:]]*[-*+][[:space:]]/d' \
  -e '/^[[:space:]]*[0-9]\+[.)][[:space:]]/d' -e '/^[[:space:]]*#/d' -e '/^[[:space:]]*[|>]/d' <<<"$body")
body_lines=$(sed -e '/^[[:space:]]*$/d' <<<"$body" | wc -l | tr -d ' ')
prose_words=$(wc -w <<<"$body_prose" | tr -d ' ')
if [ "${body_lines:-0}" -ge 4 ] && [ "${prose_words:-0}" -lt 15 ]; then
  add_hit "body is all bullets ($prose_words words of prose) — say in sentences why the change exists; the diff already lists what changed"
fi

[ -n "$hits" ] && block "$hits"

rm -f "$counter_file"
exit 0
