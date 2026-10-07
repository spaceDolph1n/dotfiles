#!/usr/bin/env bash
# Tests for lua/core/swap.lua with real swap files from killed nvim processes.
set -uo pipefail
CFG="$(cd "$(dirname "$0")" && pwd)"; fail=0
check() { if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1 (got '$2', want '$3')"; fail=1; fi; }
T="$(mktemp -d)"; export XDG_STATE_HOME="$T/state"   # swaps go here, not the real swap dir

# Start an nvim that edits $1 (adds a line, unsaved), forces the swap to disk, then is killed.
dirty_swap() {
	printf 'original\n' > "$1"
	nvim --headless --clean -c "set swapfile directory=$T/swap//" -c "edit $1" \
		-c 'call append(0, "unsaved edit")' -c 'preserve' \
		-c "call writefile([swapname('%')], '$T/swapname')" -c 'sleep 30' >/dev/null 2>&1 &
	pid=$!; for _ in $(seq 50); do [ -s "$T/swapname" ] && break; sleep 0.1; done
	echo "$pid"
}
choice() {  # prints what the module decides for swap $1 of file $2
	nvim --headless --clean -c "set rtp^=$CFG" \
		-c "lua io.write(tostring(require('core.swap').choice([[$1]], [[$2]])))" -c 'qa!' 2>/dev/null
}
mkdir -p "$T/swap"

pid=$(dirty_swap "$T/a.md"); sw=$(cat "$T/swapname")
check "owner alive: leave it to the prompt" "$(choice "$sw" "$T/a.md")" nil
kill -9 "$pid"; sleep 0.3
check "owner dead, unsaved edit differs from disk: prompt" "$(choice "$sw" "$T/a.md")" nil
printf 'unsaved edit\noriginal\n' > "$T/a.md"
check "owner dead, recovered text equals disk: delete" "$(choice "$sw" "$T/a.md")" d
check "the swap file is untouched by the check" "$([ -f "$sw" ] && echo yes)" yes

rm -rf "$T"; exit $fail
