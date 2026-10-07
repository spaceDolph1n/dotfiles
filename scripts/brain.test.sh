#!/usr/bin/env bash
# Tests for `brain`. Every case points BRAIN_VAULT at a throwaway vault.
set -uo pipefail
BRAIN="$(cd "$(dirname "$0")" && pwd)/brain"
fail=0
check() { if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1 (got '$2', want '$3')"; fail=1; fi; }
fresh() { BRAIN_VAULT="$(mktemp -d)"; export BRAIN_VAULT; }

fresh
"$BRAIN" "check nvim marks" >/dev/null
check "a capture lands in captures.md" "$(grep -c 'check nvim marks' "$BRAIN_VAULT/captures.md")" 1
grep -qE '^- [0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2} — check nvim marks$' "$BRAIN_VAULT/captures.md" && f=yes || f=no
check "the line is dated" "$f" yes

"$BRAIN" two words here >/dev/null
check "unquoted words are one capture" "$(grep -c 'two words here' "$BRAIN_VAULT/captures.md")" 1

printf 'piped line\n' | "$BRAIN" >/dev/null
check "a line on stdin is captured" "$(grep -c 'piped line' "$BRAIN_VAULT/captures.md")" 1

before=$(wc -l <"$BRAIN_VAULT/captures.md")
printf '   \n' | "$BRAIN" >/dev/null 2>&1; code=$?
check "an empty capture is refused" "$code" 1
check "and writes nothing" "$(wc -l <"$BRAIN_VAULT/captures.md")" "$before"

"$BRAIN" -d "old decision" >/dev/null 2>&1; code=$?
check "the removed -d flag fails loudly" "$code" 1
[ ! -e "$BRAIN_VAULT/decisions.md" ] && d=no || d=yes
check "and writes no decisions file" "$d" no

exit $fail
