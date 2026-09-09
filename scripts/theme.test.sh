#!/usr/bin/env bash
#
# Tests for the theme generator. Run: scripts/theme.test.sh
#
# The extractor reads the real nvim plugins on purpose: a fixture would test the
# fixture. Asserted here is the contract -- every role in both themes, never a
# sentinel, and `term` from each theme's wezterm port rather than `theme.term`.

set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PALETTE="$DIR/theme-palette"
THEMES=(kanso kanagawa-dragon)
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

ok() { # ok <name> <condition-exit-code> [detail]
	if [[ "$2" -eq 0 ]]; then
		printf '  ok   %s\n' "$1"
		pass=$((pass + 1))
	else
		printf '  FAIL %s%s\n' "$1" "${3:+ -- $3}"
		fail=$((fail + 1))
	fi
}

# --- extractor ---------------------------------------------------------------

printf '\ntheme-palette\n'

for theme in "${THEMES[@]}"; do
	out="$("$PALETTE" "$theme" 2>/dev/null)"
	ok "$theme: exits 0" $?

	printf '%s' "$out" | python3 -c 'import json,sys; json.load(sys.stdin)' 2>/dev/null
	ok "$theme: emits valid JSON" $?

	# Roles the templates will reference. Absent or "NONE" both have to fail --
	# syn.variable and ui.none are literally the string "NONE" upstream.
	missing="$(printf '%s' "$out" | python3 -c '
import json, sys
p = json.load(sys.stdin)
bad = [k for k, v in p.items() if not isinstance(v, str) or not v.startswith("#")]
print(",".join(sorted(bad)))
' 2>/dev/null)"
	check "$theme: every role is a hex colour" "" "$missing"

	count="$(printf '%s' "$out" | python3 -c '
import json, sys
print(len(json.load(sys.stdin)))
' 2>/dev/null)"
	ok "$theme: emits the full contract (got ${count:-0})" "$([[ ${count:-0} -ge 70 ]] && echo 0 || echo 1)"

	slots="$(printf '%s' "$out" | python3 -c '
import json, sys
p = json.load(sys.stdin)
print(sum(1 for k in p if k.startswith("term.")))
' 2>/dev/null)"
	check "$theme: term has 16 slots" "16" "$slots"
done

printf '\nterm comes from the upstream wezterm port, not theme.term\n'

# kanso's theme.term gives #C5C9C7 for ansi-cyan and #909398 for bright-black;
# its wezterm extra gives #8EA4A2 and #A4A7A4, which is what wezterm.lua already
# has. Getting this backwards silently dims the tmux pane border.
cyan="$("$PALETTE" kanso 2>/dev/null | python3 -c 'import json,sys; print(json.load(sys.stdin)["term.6"])' 2>/dev/null)"
check "kanso term.6 is aqua, not fg" "#8ea4a2" "$cyan"
bright_black="$("$PALETTE" kanso 2>/dev/null | python3 -c 'import json,sys; print(json.load(sys.stdin)["term.8"])' 2>/dev/null)"
check "kanso term.8 is #a4a7a4, not #909398" "#a4a7a4" "$bright_black"

printf '\nderived colours reproduce the hand-tuned ones\n'

# The anchor is outside this code: these four are what Tiago tuned by hand in
# hunk/config.toml before any of this existed. If a formula drifts, they move.
derived="$("$PALETTE" kanso 2>/dev/null | python3 -c '
import json, sys
p = json.load(sys.stdin)
print(" ".join(p[k] for k in ("diff.add_content", "diff.delete_content", "note.border", "note.bg")))
' 2>/dev/null)"
bg_inactive="$("$PALETTE" kanso 2>/dev/null | python3 -c 'import json,sys; print(json.load(sys.stdin)["ui.bg_inactive"])' 2>/dev/null)"
check "kanso ui.bg_inactive is the dim tmux already uses" "#0d1218" "$bg_inactive"
check "kanso derived match hunk's hand-tuned values" "#44533e #6e2d33 #8992a7 #1c1e25" "$derived"

printf '\nthe inherit sentinel is excluded, not passed through\n'

# Both themes use a sentinel meaning "inherit" for these, and disagree on its
# case: kanso "NONE", dragon "none". Neither may reach a template.
for theme in "${THEMES[@]}"; do
	sentinels="$("$PALETTE" "$theme" 2>/dev/null | python3 -c '
import json, sys
p = json.load(sys.stdin)
print(",".join(k for k in ("syn.variable", "ui.pmenu.fg_sel") if k in p))
' 2>/dev/null)"
	check "$theme: sentinel roles absent" "" "$sentinels"
done

printf '\nfailure modes\n'

"$PALETTE" no-such-theme >/dev/null 2>&1
[[ $? -ne 0 ]]
ok "unknown theme exits non-zero" $?

"$PALETTE" >/dev/null 2>&1
[[ $? -ne 0 ]]
ok "no argument exits non-zero" $?

# --- generator -----------------------------------------------------------------

printf '\ntheme\n'

THEME="$DIR/theme"
was="$("$THEME")"

"$THEME" --check >/dev/null 2>&1
ok "--check renders every surface" $?

# Idempotent: the second run must leave the tree exactly as the first did.
"$THEME" "$was" >/dev/null 2>&1
before="$(cd "$DIR/.." && git status --porcelain)"
"$THEME" "$was" >/dev/null 2>&1
after="$(cd "$DIR/.." && git status --porcelain)"
check "running twice changes nothing further" "$before" "$after"

"$THEME" no-such-theme >/dev/null 2>&1
[[ $? -ne 0 ]]
ok "generator rejects an unknown theme" $?

# A template naming a role no palette has must abort the whole run, before any
# file is touched -- os.replace is per-file, so a partial run would half-switch.
probe="$DIR/../theme/probe.conf.tmpl"
printf 'x = "<<ui.no_such_role>>"\n' >"$probe"
out="$("$THEME" --check 2>&1)"
rc=$?
rm -f "$probe"
[[ $rc -ne 0 ]]
ok "an unknown role aborts the run" $?
check_role_named() { case "$1" in *ui.no_such_role*) return 0;; *) return 1;; esac; }
check_role_named "$out"
ok "the abort names the missing role" $?

"$THEME" "$was" >/dev/null 2>&1

# --- file modes ------------------------------------------------------------------

printf '\nregeneration preserves file modes\n'

# scripts/vault-graph is a program, not a config. `os.replace` renames a fresh
# 0644 temp over the target, which once dropped its executable bit and shipped
# that in a commit.
"$THEME" "$(cat "$DIR/../theme/active")" >/dev/null 2>&1
[[ -x "$DIR/vault-graph" ]]
ok "scripts/vault-graph is still executable" $?

# --- key drift ------------------------------------------------------------------

printf '\nkeys still match what each tool accepts\n'

# lazygit, hunk and workmux all ignore an unknown theme key silently, so a rename
# upstream reverts that surface to defaults with nothing to show for it. Only
# lazygit can be asked what it accepts; the other two are regression guards.

drift="$(python3 - <<'PYEOF'
import re, subprocess
src = open("lazygit/config.yml").read()
block = src[src.index("  theme:"):src.index("customCommands:")]
mine = set(re.findall(r"^    ([a-zA-Z]+):", block, re.M))
dump = subprocess.run(["lazygit", "--config"], capture_output=True, text=True).stdout
theirs_block = dump[dump.index("    theme:"):dump.index("    commitLength:")]
theirs = set(re.findall(r"^        ([a-zA-Z]+):", theirs_block, re.M))
out = []
if mine - theirs: out.append("unknown to lazygit: " + ",".join(sorted(mine - theirs)))
if theirs - mine: out.append("not pinned: " + ",".join(sorted(theirs - mine)))
print("; ".join(out))
PYEOF
)"
check "lazygit theme keys match its own --config dump" "" "$drift"

# The 15 documented workmux fields. Hardcoded on purpose: workmux offers no way
# to ask, so this catches a template edit dropping one, not an upstream rename.
missing="$(python3 - <<'PYEOF'
import re
want = {"current_row_bg","highlight_row_bg","current_worktree_fg","dimmed","text",
        "border","help_border","help_muted","header","keycap","info","success",
        "warning","danger","accent"}
src = open("workmux/config.yaml").read()
block = src[src.index("theme:"):src.index("sidebar:")]
have = set(re.findall(r"^    ([a-z_]+):", block, re.M))
print(",".join(sorted(want - have)) or "")
PYEOF
)"
check "workmux theme carries all 15 documented fields" "" "$missing"

# --- result ------------------------------------------------------------------

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[[ "$fail" -eq 0 ]]
