#!/usr/bin/env bash
#
# Tests for `pulse`. Run: scripts/pulse.test.sh
#
# Only the pure parts are tested: url normalisation, cross-source ranking and
# dedupe. The source functions are deliberately absent -- asserting that a
# fetcher returns what a stubbed fetcher was told to return is the code written
# twice, and the real thing it has to survive is a live API changing shape,
# which a fixture cannot tell you about. `pulse --source hn` is that check.

set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
pass=0
fail=0

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

# Load pulse as a module without running main(), then evaluate the case body
# against it.
run() { # run <python body>
	python3 - "$DIR" <<PY
import sys, types
source = open(sys.argv[1] + "/pulse").read().replace("sys.exit(main())", "pass")
pulse = types.ModuleType("pulse")
exec(compile(source, "pulse", "exec"), pulse.__dict__)
$1
PY
}

printf '\nnormalise_url\n'

check "tracking params are dropped" "True" \
	"$(run 'print(pulse.normalise_url("https://e.com/a?utm_source=x&utm_medium=y") == pulse.normalise_url("https://e.com/a"))')"
check "www and a trailing slash do not matter" "True" \
	"$(run 'print(pulse.normalise_url("https://www.e.com/a/") == pulse.normalise_url("https://e.com/a"))')"
check "a real query param is kept" "False" \
	"$(run 'print(pulse.normalise_url("https://e.com/a?id=1") == pulse.normalise_url("https://e.com/a?id=2"))')"
check "scheme does not matter" "True" \
	"$(run 'print(pulse.normalise_url("http://e.com/a") == pulse.normalise_url("https://e.com/a"))')"
check "an empty url does not explode" "" \
	"$(run 'print(pulse.normalise_url(""))')"

printf '\nrank\n'

# The whole point of per-source normalisation: a platform where numbers run
# small must not be buried by one where they run large.
check "the top item of each source ties at 1.0" "1.0 1.0" \
	"$(run 'items=[{"source":"hn","engagement":900,"when":1},{"source":"hn","engagement":450,"when":1},{"source":"bluesky","engagement":12,"when":1},{"source":"bluesky","engagement":6,"when":1}]
r=pulse.rank(items)
print(r[0]["score"], r[1]["score"])')"
# 12 likes leading Bluesky beats 10 points trailing on HN, even though 10 and 12
# are the same order of magnitude and 900 dwarfs both.
check "leading a small venue beats trailing a large one" "bluesky" \
	"$(run 'items=[{"source":"hn","engagement":900,"when":3},{"source":"hn","engagement":10,"when":2},{"source":"bluesky","engagement":12,"when":1}]
print([i["source"] for i in pulse.rank(items)][1])')"
check "ties break on recency, not on the bigger raw number" "bluesky" \
	"$(run 'items=[{"source":"hn","engagement":900,"when":100},{"source":"bluesky","engagement":12,"when":200}]
print(pulse.rank(items)[0]["source"])')"
check "a source where everything is zero does not divide by zero" "0.0" \
	"$(run 'print(pulse.rank([{"source":"hn","engagement":0,"when":1}])[0]["score"])')"

printf '\ndedupe\n'

check "the same link from two sources becomes one row" "1" \
	"$(run 'items=[{"source":"hn","url":"https://e.com/a","title":"A","engagement":100},
       {"source":"reddit","url":"https://www.e.com/a/","title":"A","engagement":50}]
print(len(pulse.dedupe(items)))')"
check "the busier copy is the one kept" "hn" \
	"$(run 'items=[{"source":"reddit","url":"https://e.com/a","title":"A","engagement":50},
       {"source":"hn","url":"https://e.com/a","title":"A","engagement":100}]
print(pulse.dedupe(items)[0]["source"])')"
check "the other source is recorded, not lost" "reddit" \
	"$(run 'items=[{"source":"hn","url":"https://e.com/a","title":"A","engagement":100},
       {"source":"reddit","url":"https://e.com/a","title":"A","engagement":50}]
print(pulse.dedupe(items)[0]["also"])')"
check "different links stay separate" "2" \
	"$(run 'items=[{"source":"hn","url":"https://e.com/a","title":"A","engagement":1},
       {"source":"hn","url":"https://e.com/b","title":"B","engagement":1}]
print(len(pulse.dedupe(items)))')"
# Bluesky posts have no shared url, so the title is the only key left.
check "urlless items fall back to the title" "1" \
	"$(run 'items=[{"source":"bluesky","url":"","title":"same words here","engagement":9},
       {"source":"bluesky","url":"","title":"same words here","engagement":3}]
print(len(pulse.dedupe(items)))')"

printf '\ncli\n'

"$DIR/pulse" --help >/dev/null 2>&1
check "--help exits 0" "0" "$?"
"$DIR/pulse" topic --source nitter >/dev/null 2>&1
check "an unknown source is rejected" "2" "$?"

printf '\n%d passed, %d failed\n\n' "$pass" "$fail"
[[ $fail -eq 0 ]]
