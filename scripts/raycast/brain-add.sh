#!/usr/bin/env bash
# Raycast Script Command -- quick capture into the second brain.
#
# @raycast.schemaVersion 1
# @raycast.title Add to brain
# @raycast.mode silent
# @raycast.packageName Second Brain
# @raycast.icon 🧠
# @raycast.argument1 { "type": "text", "placeholder": "capture" }
# @raycast.description One-line capture into the vault inbox; /triage routes it later.

exec "$HOME/.config/scripts/brain" "$1"
