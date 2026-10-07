#!/usr/bin/env bash
# Tests for vault/pre-commit against a throwaway vault repo; the real vault is never touched.
set -uo pipefail
HOOK="$(cd "$(dirname "$0")" && pwd)/pre-commit"
fail=0
check() { if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1 (got $2, want $3)"; fail=1; fi; }

T="$(mktemp -d)"; cd "$T" || exit 1
git init -q && git config user.email t@t && git config user.name t && git config commit.gpgsign false
mkdir -p "00 - zettelkasten" work
printf -- '---\nid: a\ntype: concept\n---\n# A\n' > "00 - zettelkasten/a.md"
git add . && git commit -qm init --no-verify
export BRAIN_VAULT="$T"
commit() { "$HOOK" >/dev/null 2>&1; echo $?; }

echo 'x' > work/secret.md; git add -f work/secret.md
check "staged work/ file is refused" "$(commit)" 1; git reset -q

echo 'x' > moved.md; git add moved.md; git commit -qm m --no-verify
git mv moved.md work/moved.md 2>/dev/null; git add -f -A work 2>/dev/null
check "rename into work/ is refused" "$(commit)" 1; git reset -q --hard

echo 'line' > captures.md; git add -f captures.md
check "captures.md is refused" "$(commit)" 1; git reset -q; rm -f captures.md

printf -- '---\nid: b\ntype: concept\n---\n# B\n' > "00 - zettelkasten/b.md"; git add "00 - zettelkasten/b.md"
check "a normal note passes" "$(commit)" 0
git diff --cached --name-only | grep -qx index.md && staged=yes || staged=no
check "index.md is regenerated and staged" "$staged" yes
grep -q '\[\[b\]\]' index.md && listed=yes || listed=no
check "the new note is in the index" "$listed" yes

rm -rf "$T"; exit $fail
