#!/usr/bin/env bash
#
# Tests for `workmux-resurrect-all`. Run: scripts/workmux-resurrect-all.test.sh
#
# Real git repos and worktrees in a temp dir; only workmux is stubbed, and it
# appends "<cwd> <args>" to $CALLS so each case can see where it ran.

set -uo pipefail

SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/workmux-resurrect-all"
pass=0
fail=0

# --- harness -----------------------------------------------------------------

setup() {
	TMP="$(cd "$(mktemp -d)" && pwd -P)"
	ROOT="$TMP/worktrees"
	STUBS="$TMP/stubs"
	CALLS="$TMP/calls"
	mkdir -p "$ROOT" "$STUBS"
	: >"$CALLS"
	export CALLS
	unset STUB_FAIL_IN

	cat >"$STUBS/workmux" <<'EOF'
#!/usr/bin/env bash
echo "$(pwd -P) $*" >>"$CALLS"
[[ -n "${STUB_FAIL_IN:-}" && "$(pwd -P)" == "$STUB_FAIL_IN" ]] && exit 1
exit 0
EOF
	chmod +x "$STUBS/workmux"
}

repo_with_worktrees() { # repo_with_worktrees <name> <worktree>...
	local repo="$TMP/repos/$1"
	shift
	git init -q "$repo"
	git -C "$repo" -c user.name=t -c user.email=t@t commit -q --allow-empty -m init
	for wt in "$@"; do
		git -C "$repo" worktree add -q "$ROOT/$(basename "$repo")/$wt" -b "$wt"
	done
}

run() {
	PATH="$STUBS:$PATH" WORKMUX_WORKTREE_ROOT="$ROOT" "$SCRIPT" "$@" 2>&1
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

# --- cases -------------------------------------------------------------------

echo "two projects, several worktrees each"
setup
repo_with_worktrees web a b
repo_with_worktrees dotfiles c
run >/dev/null
check "resurrects once per main repo" \
	"$TMP/repos/dotfiles resurrect"$'\n'"$TMP/repos/web resurrect" "$(sort "$CALLS")"

echo "flags pass through"
setup
repo_with_worktrees web a
run --dry-run >/dev/null
check "forwards --dry-run" "$TMP/repos/web resurrect --dry-run" "$(cat "$CALLS")"

echo "project folder with no worktrees left"
setup
repo_with_worktrees web a
mkdir -p "$ROOT/empty"
run >/dev/null
check "skips it" "$TMP/repos/web resurrect" "$(cat "$CALLS")"

echo "one repo fails"
setup
repo_with_worktrees web a
repo_with_worktrees dotfiles c
export STUB_FAIL_IN="$TMP/repos/dotfiles"
run >/dev/null
status=$?
check "still runs the others" 2 "$(wc -l <"$CALLS" | tr -d ' ')"
check "exits non-zero" 1 "$status"

printf '\n%d passed, %d failed\n' "$pass" "$fail"
((fail == 0))
