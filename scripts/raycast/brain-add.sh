#!/usr/bin/env bash
# Raycast Script Command -- quick capture into the second brain.
#
# @raycast.schemaVersion 1
# @raycast.title Add to brain
# @raycast.mode silent
# @raycast.packageName Second Brain
# @raycast.icon 🧠
# @raycast.argument1 { "type": "text", "placeholder": "thought" }
# @raycast.description Append a timestamped one-liner to the second brain log.

exec "$HOME/.config/scripts/brain" "$1"
