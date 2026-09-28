#!/usr/bin/env bash
#
# Tests for `dev-pane`. Run: scripts/dev-pane.test.sh
#
# lsof, npm and kill are stubbed on PATH, so no real port, server or install is
# touched. Each stub appends what it was asked to $CALLS; each case starts from a
# fresh temp worktree so nothing leaks between them.

set -uo pipefail

DEV_PANE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/dev-pane"
pass=0
fail=0

# --- harness -----------------------------------------------------------------

setup() { # setup [with-node-modules]
	TREE="$(mktemp -d)"
	STUBS="$(mktemp -d)"
	CALLS="$STUBS/calls"
	: >"$CALLS"
	printf '{}\n' >"$TREE/package.json"
	[[ "${1:-}" == "with-node-modules" ]] && mkdir "$TREE/node_modules"
	export CALLS STUBS
	unset STUB_PID STUB_CWD

	# lsof -ti ... -> the listener's pid, unless kill has freed the port.
	# lsof -a -p <pid> -d cwd -Fn -> "n<cwd>".
	cat >"$STUBS/lsof" <<'EOF'
#!/usr/bin/env bash
if [[ " $* " == *" -ti "* ]]; then
	[[ -n "${STUB_PID:-}" && ! -e "$STUBS/killed" ]] && echo "$STUB_PID"
	exit 0
fi
printf 'p%s\nn%s\n' "$STUB_PID" "$STUB_CWD"
EOF
	cat >"$STUBS/npm" <<'EOF'
#!/usr/bin/env bash
echo "npm $*" >>"$CALLS"
EOF
	cat >"$STUBS/kill" <<'EOF'
#!/usr/bin/env bash
echo "kill $*" >>"$CALLS"
touch "$STUBS/killed"
EOF
	chmod +x "$STUBS"/*
}

run() { # run [stdin]
	(cd "$TREE" && PATH="$STUBS:$PATH" DEV_PANE_KILL="$STUBS/kill" "$DEV_PANE" <<<"${1:-}" 2>&1)
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
		printf '       wanted:   %q\n' "$2"
		printf '       in:       %q\n' "$3"
		fail=$((fail + 1))
	fi
}

# --- cases -------------------------------------------------------------------

echo "fresh worktree, port free"
setup
run >/dev/null
check "installs, then serves" $'npm ci\nnpm run dev' "$(cat "$CALLS")"

echo "installed worktree, port free"
setup with-node-modules
run >/dev/null
check "serves without installing" "npm run dev" "$(cat "$CALLS")"

echo "port held by another worktree, Enter"
setup with-node-modules
export STUB_PID=4242 STUB_CWD=/Users/x/Documents/work/web
out="$(run $'\n')"
check_contains "names what is being served" "/Users/x/Documents/work/web" "$out"
check "stops it, then serves this one" $'kill 4242\nnpm run dev' "$(cat "$CALLS")"

echo "port held by another worktree, q"
setup with-node-modules
export STUB_PID=4242 STUB_CWD=/Users/x/Documents/work/web
run q >/dev/null
check "leaves it running" "" "$(cat "$CALLS")"

echo "port held by this worktree"
setup with-node-modules
export STUB_PID=4242
STUB_CWD="$(cd "$TREE" && pwd -P)"
export STUB_CWD
out="$(run)"
check_contains "says it is already serving here" "already serving this worktree" "$out"
check "does nothing" "" "$(cat "$CALLS")"

printf '\n%d passed, %d failed\n' "$pass" "$fail"
((fail == 0))
