#!/usr/bin/env bash
#
# Tests for `brain`. Run: scripts/brain.test.sh
#
# Every case points BRAIN_VAULT at a throwaway vault, so the real second brain
# is never touched. Each test builds its own vault from scratch -- shared state
# between shell tests is how they start passing for the wrong reason.

set -uo pipefail

BRAIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/brain"
pass=0
fail=0

# --- harness -----------------------------------------------------------------

new_vault() {
	VAULT="$(mktemp -d)"
	export BRAIN_VAULT="$VAULT"
	printf '# Log\n' >"$VAULT/log.md"
	printf '# Decisions\n' >"$VAULT/decisions.md"
}

note() { # note <stem> [body]
	printf '%s\n' "${2:-# ${1}}" >"$BRAIN_VAULT/$1.md"
}

check() { # check <name> <expected> <actual>
	if [[ "$2" == "$3" ]]; then
		printf '  ok   %s\n' "$1"
		pass=$((pass + 1))
	else
		printf '  FAIL %s\n' "$1"
		printf '       expected: %q\n' "$2"
		printf '       actual:   %q\n' "$3"
		fail=$((fail + 1))
	fi
}

check_contains() { # check_contains <name> <needle> <haystack>
	if [[ "$3" == *"$2"* ]]; then
		printf '  ok   %s\n' "$1"
		pass=$((pass + 1))
	else
		printf '  FAIL %s\n' "$1"
		printf '       expected to contain: %q\n' "$2"
		printf '       actual:              %q\n' "$3"
		fail=$((fail + 1))
	fi
}

# --- autolink: must not corrupt code spans or identifiers --------------------

printf 'autolink\n'

new_vault
note code-review
printf -- '- 2026-08-20 adherence is `pr-review-toolkit:code-review` work\n' >>"$BRAIN_VAULT/log.md"
"$BRAIN" --relink >/dev/null 2>&1
check "leaves a stem inside an inline code span alone" \
	'- 2026-08-20 adherence is `pr-review-toolkit:code-review` work' \
	"$(sed -n '2p' "$BRAIN_VAULT/log.md")"

new_vault
note code-review
printf -- '- 2026-08-20 the code-review notes are worth rereading\n' >>"$BRAIN_VAULT/log.md"
"$BRAIN" --relink >/dev/null 2>&1
check_contains "still links a bare prose mention" \
	'[[code-review]]' \
	"$(sed -n '2p' "$BRAIN_VAULT/log.md")"

new_vault
note code-review
printf -- '- 2026-08-20 see pr-review-toolkit:code-review for that\n' >>"$BRAIN_VAULT/log.md"
"$BRAIN" --relink >/dev/null 2>&1
check "leaves a stem inside a colon-separated identifier alone" \
	'- 2026-08-20 see pr-review-toolkit:code-review for that' \
	"$(sed -n '2p' "$BRAIN_VAULT/log.md")"

new_vault
note git-sheet
printf -- '- 2026-08-20 pinned to git-sheet-v2 last week\n' >>"$BRAIN_VAULT/log.md"
"$BRAIN" --relink >/dev/null 2>&1
check "leaves a stem inside a longer hyphenated identifier alone" \
	'- 2026-08-20 pinned to git-sheet-v2 last week' \
	"$(sed -n '2p' "$BRAIN_VAULT/log.md")"

new_vault
note git-sheet
printf -- '- 2026-08-20 reread the git-sheet.\n' >>"$BRAIN_VAULT/log.md"
"$BRAIN" --relink >/dev/null 2>&1
check_contains "still links a stem ending a sentence" \
	'[[git-sheet]].' \
	"$(sed -n '2p' "$BRAIN_VAULT/log.md")"

new_vault
note code-review
"$BRAIN" 'adherence is `pr-review-toolkit:code-review` work' >/dev/null 2>&1
check_contains "capture path leaves a code span alone" \
	'`pr-review-toolkit:code-review`' \
	"$(cat "$BRAIN_VAULT/log.md")"

# --- backlinks: only a real heading is a heading ------------------------------

printf 'backlinks\n'

new_vault
note code-review
prose='# Second brain capture

It re-scans the streams and refreshes `## Backlinks` sections in notes
that opt in by containing that heading.

## Committing

Nothing to see here.'
printf '%s\n' "$prose" >"$BRAIN_VAULT/second-brain-capture.md"
"$BRAIN" --relink >/dev/null 2>&1
check "leaves a literal '## Backlinks' in prose alone" \
	"$prose" \
	"$(cat "$BRAIN_VAULT/second-brain-capture.md")"

new_vault
note code-review
printf -- '- 2026-08-20 the code-review notes are worth rereading\n' >>"$BRAIN_VAULT/log.md"
printf '# Code review\n\nBody.\n\n## Backlinks\n\nstale\n' >"$BRAIN_VAULT/code-review.md"
"$BRAIN" --relink >/dev/null 2>&1
check_contains "refreshes a real '## Backlinks' heading" \
	'- 2026-08-20 the code-review notes are worth rereading' \
	"$(cat "$BRAIN_VAULT/code-review.md")"

# --- result ------------------------------------------------------------------

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[[ "$fail" -eq 0 ]]
