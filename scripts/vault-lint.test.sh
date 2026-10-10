#!/usr/bin/env bash
# Tests for vault-lint against a throwaway vault.
set -uo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"; LINT="$DIR/vault-lint"
fail=0
check() { if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1 (got '$2', want '$3')"; fail=1; fi; }
BRAIN_VAULT="$(mktemp -d)"; export BRAIN_VAULT
note() { printf -- '---\nid: %s\ntype: concept\n---\n\nbody\n' "$1" > "$BRAIN_VAULT/$1.md"; }
stale() { "$LINT" --json | python3 -c 'import json,sys; print(" ".join(json.load(sys.stdin)["stale_companion"]))'; }

note fresh; touch -t 202610100900 "$BRAIN_VAULT/fresh.md"
echo '<p>chart</p>' > "$BRAIN_VAULT/fresh.html"; touch -t 202610101000 "$BRAIN_VAULT/fresh.html"
note edited; touch -t 202610101000 "$BRAIN_VAULT/edited.md"
echo '<p>chart</p>' > "$BRAIN_VAULT/edited.html"; touch -t 202610100900 "$BRAIN_VAULT/edited.html"
echo '<p>lesson</p>' > "$BRAIN_VAULT/lesson.html"

check "a companion older than its note is stale, and only that one" "$(stale)" "edited.html"
"$LINT" --only stale-companion | grep -q 'edited.html' && r=yes || r=no
check "the text report lists it too" "$r" yes

rm -rf "$BRAIN_VAULT"; exit $fail
