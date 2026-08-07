#!/usr/bin/env bash
# Raycast Script Command -- record a decision.
#
# Fill in why/expected here and it is captured complete, with no editor.
# Leave them blank and the stub opens in WezTerm to finish at the desk.
#
# @raycast.schemaVersion 1
# @raycast.title Log a decision
# @raycast.mode silent
# @raycast.packageName Second Brain
# @raycast.icon ⚖️
# @raycast.argument1 { "type": "text", "placeholder": "what you decided" }
# @raycast.argument2 { "type": "text", "placeholder": "why", "optional": true }
# @raycast.argument3 { "type": "text", "placeholder": "expected", "optional": true }
# @raycast.description Append a decision. Blank why/expected opens the editor.

exec "$HOME/.config/scripts/brain" -d "$1" "${2:-}" "${3:-}"
