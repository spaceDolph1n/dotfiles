#!/usr/bin/env bash
# Tests for vault-triage against a throwaway vault.
set -uo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"; TRIAGE="$DIR/vault-triage"; BRAIN="$DIR/brain"
fail=0
check() { if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1 (got '$2', want '$3')"; fail=1; fi; }
BRAIN_VAULT="$(mktemp -d)"; export BRAIN_VAULT; IN="$BRAIN_VAULT/captures.md"; DONE="$BRAIN_VAULT/captures-done.md"
printf -- '- 2026-10-07 09:00 — alpha\n- 2026-10-07 09:01 — beta\n- 2026-10-07 09:02 — alpha\n' > "$IN"

"$TRIAGE" list > "$BRAIN_VAULT/out"
check "list numbers every capture" "$(grep -c '^[0-9]' "$BRAIN_VAULT/out")" 3

"$TRIAGE" done "explore.md" "- 2026-10-07 09:01 — beta" >/dev/null
check "done removes the approved line" "$(grep -c 'beta' "$IN")" 0
check "and keeps the others" "$(wc -l <"$IN" | tr -d ' ')" 2
grep -qE '^- [0-9-]+ [0-9:]+ — explore.md — - 2026-10-07 09:01 — beta$' "$DONE" && r=yes || r=no
check "a receipt names the destination and the text" "$r" yes

"$TRIAGE" done dropped "- 2026-10-07 09:00 — alpha" >/dev/null
check "only one copy of a duplicate line is removed" "$(grep -c 'alpha' "$IN")" 1

"$TRIAGE" done dropped "- not in the inbox" >/dev/null 2>&1; code=$?
check "an unknown line fails" "$code" 1
check "and writes no receipt" "$(grep -c 'not in the inbox' "$DONE")" 0

"$BRAIN" "typed during triage" >/dev/null
"$TRIAGE" done dropped "- 2026-10-07 09:02 — alpha" >/dev/null
check "a capture made mid-triage survives" "$(grep -c 'typed during triage' "$IN")" 1

check "count reports what is left" "$("$TRIAGE" count)" 1
rm -rf "$BRAIN_VAULT"; exit $fail
