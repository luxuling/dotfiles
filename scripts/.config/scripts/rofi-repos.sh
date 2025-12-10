#!/bin/sh
set -eu

terminal="kitty"
base="$HOME/MINE/codes"

#PICK CATEGORY
parents="$(ls -1 "$base")"
[ -n "$parents" ] || exit 0

chosen_parent="$(printf '%s\n' "$parents" | rofi -dmenu -p 'Category:')"
[ -n "$chosen_parent" ] || exit 0

parent_dir="$base/$chosen_parent"

#PICK PROJECT
projects="$(ls -1 "$parent_dir")"
[ -n "$projects" ] || exit 0

chosen_project="$(printf '%s\n' "$projects" | rofi -dmenu -p 'Project:')"
[ -n "$chosen_project" ] || exit 0

final_dir="$parent_dir/$chosen_project"

#CLOSE EXISTING KITTY
pkill -x "$terminal" 2>/dev/null || true
sleep 0.2

#LAUNCH AND BLOCK
exec "$terminal" sh -c '
    "'"$HOME"'/.config/scripts/coding" "'"$final_dir"'"
'
