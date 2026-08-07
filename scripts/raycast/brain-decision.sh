#!/usr/bin/env bash
# Raycast Script Command -- start a decision entry.
#
# Captures the title instantly, then opens the decision stub in a new WezTerm
# window so the what/why/expected fields can be filled in at the desk.
#
# @raycast.schemaVersion 1
# @raycast.title Log a decision
# @raycast.mode silent
# @raycast.packageName Second Brain
# @raycast.icon ⚖️
# @raycast.argument1 { "type": "text", "placeholder": "what you decided" }
# @raycast.description Append a decision stub and open it for editing.

exec "$HOME/.config/scripts/brain" -d "$1"
