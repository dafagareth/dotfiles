#!/bin/bash

# Get list windows dengan detail lengkap
windows=$(hyprctl clients -j | jq -r '.[] | 
    "WS:\(.workspace.id) | \(.class) | \(.title) | \(.address)"')

if [ -z "$windows" ]; then
    notify-send "No Windows" "No windows are currently open"
    exit 0
fi

# Format untuk display (hilangkan address dari tampilan)
display=$(echo "$windows" | awk -F'|' '{
    ws = $1
    class = $2
    title = $3
    gsub(/^[ \t]+|[ \t]+$/, "", ws)
    gsub(/^[ \t]+|[ \t]+$/, "", class)
    gsub(/^[ \t]+|[ \t]+$/, "", title)
    printf "%-8s %-20s %s\n", ws, class, title
}')

# Show dalam wofi
selected=$(echo "$display" | wofi --dmenu \
    --prompt "󰖯 Switch Window" \
    --width 900 \
    --height 500 \
    --cache-file=/dev/null \
    --style ~/.config/wofi/style-switcher.css)

if [ -n "$selected" ]; then
    # Get line number dari selection
    line_num=$(echo "$display" | grep -n "^$selected$" | cut -d: -f1)
    
    # Get address dari line yang sama
    address=$(echo "$windows" | sed -n "${line_num}p" | awk -F'|' '{print $4}' | xargs)
    
    # Focus window
    hyprctl dispatch focuswindow address:$address
fi