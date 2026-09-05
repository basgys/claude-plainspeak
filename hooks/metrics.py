#!/usr/bin/env python3
"""Structured metrics over one message, stdlib only.

Reads text on stdin, writes one JSON object on stdout. Catches the shapes
that need a count or a two-clause test, which the bash regexes in lib.sh
cannot do. Measured at 58ms cold.

Three metrics folklore recommends are deliberately absent, because the
peer-reviewed direction is the opposite of the folk claim:

  hedging density      humans hedge MORE than LLMs (Herbold et al.,
                       Scientific Reports 13:18617, d = 1.0 to 1.5)
  discourse markers    humans use more, or no significant difference (same)
  type-token ratio     direction flips between GPT-3.5 and GPT-4, and raw
                       TTR correlates with message length at -0.70 on this
                       corpus

Liang et al., Patterns 4(7):100779, found detectors misclassified 61% of
non-native human essays as AI, driven by low linguistic variability. Terse
technical writing sits in that failure mode, so nothing here thresholds on
variance.
"""

import json
import re
import sys

# --- text preparation -------------------------------------------------

FENCE = re.compile(r"^```")
TABLE = re.compile(r"^[ \t]*[|│┌└├┐┘┤┬┴┼]")
LIST = re.compile(r"^[ \t]*([-*+]|\d+[.)])[ \t]+")
HEADING = re.compile(r"^[ \t]*#+[ \t]+")
INLINE_CODE = re.compile(r"`[^`]*`")
URL = re.compile(r"https?://\S+")


def strip_code(text):
    """Fenced code is never prose. Matches lib.sh's behaviour."""
    out, infence = [], False
    for line in text.split("\n"):
        if FENCE.match(line):
            infence = not infence
            continue
        if not infence:
            out.append(line)
    return "\n".join(out)


def prose_lines(text):
    """Lines that carry prose: no table rows, markers stripped."""
    for line in text.split("\n"):
        if TABLE.match(line):
            continue
        line = LIST.sub("", line)
        line = HEADING.sub("", line)
        yield line


def sentences(text):
    out = []
    for line in prose_lines(text):
        line = INLINE_CODE.sub(" CODE ", line)
        line = URL.sub(" URL ", line)
        for part in re.split(r"[.!?;:]+[ \t]+|[.!?]+$", line):
            part = part.strip()
            if part:
                out.append(part)
    return out


def words(text):
    return re.findall(r"[A-Za-z][A-Za-z'-]*", text)


# --- significance coda ------------------------------------------------
# A verbless fragment, a comma, then and/but joining a clause that comments
# on the fragment instead of advancing it. "Mixed, and the split matters."
#
# Parsers do not solve this. Every tagger tested reads "the split matters"
# as a noun phrase, and every one tags "pushed" in the legitimate "Done,
# and pushed at 1.6.0" as a finite verb, so a finite-verb test rejects the
# case that must pass. The tail's subject is what discriminates: the coda
# opens its tail with a determiner or a number, the legitimate coordination
# opens with a bare verb.

CODA_SPLIT = re.compile(r"^(?P<head>[^,]{2,60}),\s+(and|but)\s+(?P<tail>.{4,120})$")
PRONOUN_HEAD = re.compile(r"^\s*(i|we|you|he|she|they|it|this|that|there)\b", re.I)
TAIL_SUBJECT = re.compile(
    r"^\s*(the|a|an|its|his|her|their|our|my|your|this|that|these|those|one|two|"
    r"three|four|five|six|seven|eight|nine|ten|both|each|either|neither|most|"
    r"some|all|every|no|another|\d+)\b",
    re.I,
)
# Closed list plus a suffix rule. The suffix rule was added because the
# closed list missed heads like "The text then supplies the badge's
# baseline", where the verb is ordinary but unlisted.
FINITE = re.compile(
    r"\b(is|are|was|were|be|been|being|am|has|have|had|do|does|did|can|could|"
    r"will|would|shall|should|may|might|must|takes?|took|makes?|made|gets?|got|"
    r"goes|went|comes?|came|sits?|sat|holds?|held|runs?|ran|needs?|means?|"
    r"meant|says?|said|shows?|gives?|gave|keeps?|kept|puts?|lets?|uses?|used)\b",
    re.I,
)
FINITE_SUFFIX = re.compile(r"\b[a-z]{3,}(?<!ss)(?<!us)(?<!is)(es|s|ed)\b", re.I)


def is_coda(sentence):
    m = CODA_SPLIT.match(sentence.strip())
    if not m:
        return False
    head, tail = m.group("head"), m.group("tail")
    # A pronoun head is already a full clause, not a fragment.
    if PRONOUN_HEAD.match(head):
        return False
    # A comma inside the head means this is a serial list, not a clause
    # boundary. Found on the real corpus: without this guard the rate more
    # than doubled, dominated by Oxford-comma enumerations.
    if "," in head:
        return False
    if FINITE.search(head):
        return False
    # The -s/-ed suffix test separates "Two files changed" (a full clause)
    # from "Four options" (a fragment), but only above two words: a bare
    # participle head like "Mixed" or "Modelled" is a fragment and would
    # be rejected by the suffix alone. Plural nouns carry the same -s.
    if len(head.split()) > 2 and FINITE_SUFFIX.search(head):
        return False
    # The tail must be a clause with its own subject and its own verb.
    if not TAIL_SUBJECT.match(tail):
        return False
    if not (FINITE.search(tail) or FINITE_SUFFIX.search(tail)):
        return False
    return True


# --- negative parallelism ---------------------------------------------
# Two tiers, measured against 262 messages where two independent judges
# agreed. A single strict hit flags; the looser "instead of" form needs a
# second hit to join it.
#
# The strict form alone at 2+ scored precision 99%, recall 68%. At 1+ it
# scores 96% / 87%. Since 17 of the 20 violations that only the model judge
# caught were single-occurrence negative parallelism, recall matters more
# here than the last point of precision. End to end the local checks go from
# 89% to 95% recall at 90% precision, and human false positives on kernel
# commits rise from 4.8% to 7.3%.
NEG_PARALLEL = re.compile(
    r"(,|—|;) *not +(just |only |merely |simply )?[a-z0-9\"]|\brather than\b", re.I
)
NEG_PARALLEL_LOOSE = re.compile(r"\binstead of\b", re.I)

# A generic noun called valuable, and the sentence ends before it is named:
# "found a real cost worth removing", "one thing worth watching." The reader
# is told something counts and has to read on to learn what.
#
# A colon, dash or that-clause after the phrase means the naming follows
# immediately, so only the sentence-terminated form is matched. Measured
# against 3,615 real messages: 0.08% hit rate, every hit a true positive.
# The unrestricted "worth <verb>ing" fires on 9.2% and is mostly legitimate
# ("worth checking after this deploys"), so the generic-noun list carries
# the discrimination.
VAGUE_REFERENT = re.compile(
    r"\b(something|anything|one thing|a few things|(?:a|an|one) "
    r"(?:real |genuine |serious )?(?:cost|issue|problem|gap|win|thing|change|"
    r"point)s?) worth [a-z]+ing\s*[.!?]",
    re.I,
)

# --- nominalization ---------------------------------------------------
# Reported for the benchmark tooling, never blocked on. It was the
# best-replicated metric in the literature (Reinhart et al.,
# arXiv:2410.16107, GPT-4o d = 1.23; Herbold et al. corroborating at
# d = 0.88 to 1.35) and it does not survive contact with this corpus:
# against 20,000 pre-ChatGPT Linux kernel commit bodies it fires on 3.9% of
# human prose against 4.8% here. Software English is congenitally
# nominalized and the published effect was measured on academic prose, so
# the register is wrong.
NOMINAL = re.compile(r"\b[a-z]{4,}(tion|tions|ment|ments|ness|ity|ities|ance|ence)\b", re.I)
NOMINAL_STOP = {
    "application", "applications", "authentication", "authorization",
    "configuration", "configurations", "connection", "connections",
    "collection", "collections", "compaction", "compression", "condition",
    "conditions", "convention", "conventions", "dependency", "description",
    "descriptions", "detection", "direction", "distribution", "documentation",
    "environment", "environments", "exception", "exceptions", "execution",
    "expression", "expressions", "extension", "extensions", "function",
    "functions", "implementation", "information", "instrumentation",
    "integration", "iteration", "iterations", "latency", "migration",
    "migrations", "notification", "notifications", "operation", "operations",
    "optimization", "option", "options", "partition", "partitions",
    "performance", "permission", "permissions", "persistence", "position",
    "precision", "production", "quality", "reference", "references",
    "resolution", "section", "sections", "security", "selection",
    "serialization", "session", "sessions", "specification", "statement",
    "statements", "transaction", "transactions", "validation", "variance",
    "version", "versions", "visibility",
}

QUANTITY = re.compile(
    r"^[0-9][0-9,]*(\.[0-9]+)?(h[0-9]+m|m[0-9]+s|[hmsd]|%|x|GB|MB|KB|ms)?$"
)


def with_context(pattern, text, limit=3, pad=40):
    """Matched spans plus surrounding words, for the block message.

    A count alone ("negative parallelism (x2)") makes the writer hunt for
    what fired, and the usual result is a blind full rewrite that trips a
    different rule. Quoting the span makes the fix mechanical.
    """
    out = []
    for m in pattern.finditer(text):
        start, end = max(0, m.start() - pad), min(len(text), m.end() + pad)
        frag = " ".join(text[start:end].split())
        out.append(("..." if start else "") + frag + ("..." if end < len(text) else ""))
        if len(out) >= limit:
            break
    return out


def figures_per_paragraph(text):
    worst, para = 0, []

    def flush():
        nonlocal worst
        if not para:
            return
        joined = " ".join(para)
        c = sum(1 for t in joined.split() if QUANTITY.match(t.strip("([,;:.)]")))
        worst = max(worst, c)
        para.clear()

    for line in text.split("\n"):
        if not line.strip() or TABLE.match(line) or LIST.match(line):
            flush()
            continue
        para.append(line)
    flush()
    return worst


def compute(raw):
    text = strip_code(raw)
    toks = words(text)
    n = len(toks) or 1
    lens = [len(s.split()) for s in sentences(text)] or [0]
    nom = [t for t in toks if NOMINAL.fullmatch(t) and t.lower() not in NOMINAL_STOP]

    strict = len(NEG_PARALLEL.findall(text))
    loose = len(NEG_PARALLEL_LOOSE.findall(text))
    coda_hits = [s for s in sentences(text) if is_coda(s)]

    return {
        "words": len(toks),
        "emdash": text.count("—"),
        "longest_sentence": max(lens),
        "figures_per_paragraph": figures_per_paragraph("\n".join(prose_lines(text))),
        "neg_parallel": strict,
        "neg_parallel_flag": strict >= 1 or strict + loose >= 2,
        "neg_parallel_hits": (with_context(NEG_PARALLEL, text)
                              or with_context(NEG_PARALLEL_LOOSE, text)),
        "vague_referent": len(VAGUE_REFERENT.findall(text)),
        "vague_referent_hits": with_context(VAGUE_REFERENT, text, pad=20),
        "coda": len(coda_hits),
        "coda_hits": coda_hits[:3],
        "nominal_per_100w": round(len(nom) / n * 100, 3),
    }


if __name__ == "__main__":
    print(json.dumps(compute(sys.stdin.read())))
