#!/bin/bash

MODE="${1:-run}"

echo "Detecting Flutter devices..."

DEVICE_JSON=$(flutter devices --machine 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$DEVICE_JSON" ]; then
    echo ""
    echo "Unable to get Flutter devices."
    echo ""
    flutter devices
    exit 1
fi

DEVICE_LIST=$(echo "$DEVICE_JSON" | python3 -c '
import sys
import json

devices = json.load(sys.stdin)

for d in devices:
    device_id = d.get("id", "")
    name = d.get("name", device_id)
    platform = d.get("targetPlatform", "")

    if device_id:
        print(f"{device_id}\t{name}\t{platform}")
')

if [ -z "$DEVICE_LIST" ]; then
    echo "No Flutter devices detected."
    exit 1
fi

SELECTED=$(printf '%s\n' "$DEVICE_LIST" | \
    fzf \
    --height=60% \
    --layout=reverse \
    --border \
    --prompt="Flutter device > " \
    --header="ENTER select • ESC cancel" \
    --delimiter=$'\t' \
    --with-nth=2,3)

if [ -z "$SELECTED" ]; then
    echo "Cancelled."
    exit 0
fi

DEVICE_ID=$(printf '%s' "$SELECTED" | cut -f1)
DEVICE_NAME=$(printf '%s' "$SELECTED" | cut -f2)

echo ""
echo "Running on: $DEVICE_NAME"
echo "Device ID: $DEVICE_ID"
echo ""

case "$MODE" in
    run)
        exec flutter run -d "$DEVICE_ID"
        ;;

    debug)
        exec flutter run --flavor development -t lib/main_development.dart --debug -d "$DEVICE_ID"
        ;;

    profile)
        exec flutter run --profile -d "$DEVICE_ID"
        ;;

    *)
        echo "Unknown mode: $MODE"
        exit 1
        ;;
esac
