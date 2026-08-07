#!/usr/bin/env bash
# Raycast Script Command -- backfill links into past entries.
#
# Run after creating notes, so entries written before the note existed start
# pointing at it.
#
# @raycast.schemaVersion 1
# @raycast.title Relink brain
# @raycast.mode compact
# @raycast.packageName Second Brain
# @raycast.icon 🔗
# @raycast.description Re-scan log and decisions for notes created since.

exec "$HOME/.config/scripts/brain" --relink
