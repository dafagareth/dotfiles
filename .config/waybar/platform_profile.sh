#!/bin/bash

# Fixed platform profile script - no spam errors

PROFILE_FILE="/sys/firmware/acpi/platform_profile"

# Check if file exists
if [ ! -f "$PROFILE_FILE" ]; then
    # File doesn't exist - return default/disabled state
    echo '{"text": "N/A", "tooltip": "Platform profile not supported", "class": "disabled", "alt": "default"}'
    exit 0
fi

# File exists - read the profile
PROFILE=$(cat "$PROFILE_FILE" 2>/dev/null)

# Handle read errors
if [ -z "$PROFILE" ]; then
    echo '{"text": "?", "tooltip": "Cannot read platform profile", "class": "error", "alt": "default"}'
    exit 0
fi

# Return the profile
case "$PROFILE" in
    "quiet"|"low-power")
        echo "{\"text\": \"Quiet\", \"tooltip\": \"Power mode: Quiet\", \"class\": \"quiet\", \"alt\": \"quiet\"}"
        ;;
    "balanced")
        echo "{\"text\": \"Balanced\", \"tooltip\": \"Power mode: Balanced\", \"class\": \"balanced\", \"alt\": \"balanced\"}"
        ;;
    "performance")
        echo "{\"text\": \"Performance\", \"tooltip\": \"Power mode: Performance\", \"class\": \"performance\", \"alt\": \"performance\"}"
        ;;
    *)
        echo "{\"text\": \"$PROFILE\", \"tooltip\": \"Power mode: $PROFILE\", \"class\": \"unknown\", \"alt\": \"default\"}"
        ;;
esac