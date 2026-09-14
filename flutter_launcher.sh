#!/bin/bash

echo "🔍 Checking for connected physical or running devices..."
# Check if any active devices are running
DEVICES=$(flutter devices | grep -E '•' | grep -v '• id •')

if [ -n "$DEVICES" ]; then
    echo "✅ Running device detected. Launching application..."
    flutter run
else
    echo "⚠️  No active or physical devices found."
    echo "🔄 Fetching available cold emulators/simulators..."

    # Get list of cold emulators
    # Format: id • name • provider
    MAPFILE=()
    while IFS= read -line; do
        if [[ "$line" == *"•"* && "$line" != *"Emulator ID"* ]]; then
            MAPFILE+=("$line")
        fi
    done < <(flutter emulators)

    if [ ${#MAPFILE[@]} -eq 0 ]; then
        echo "❌ Error: No physical devices connected AND no emulators found."
        echo "Please connect a device or create an emulator in Android Studio/Xcode."
        exit 1
    fi

    echo ""
    echo "📱 Available Emulators:"
    for i in "${!MAPFILE[@]}"; do
        # Clean up the output line for readability
        clean_name=$(echo "${MAPFILE[$i]}" | sed 's/ • / | /g')
        echo "  [$((i+1))] $clean_name"
    done
    echo ""

    # Prompt the user for selection in the terminal
    printf "👉 Select an emulator number to launch (or press Enter to cancel): "
    read -r choice

    # Validate choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#MAPFILE[@]}" ]; then
        # Extract the emulator ID (first column before the first bullet point)
        selected_line="${MAPFILE[$((choice-1))]}"
        emulator_id=$(echo "$selected_line" | awk -F ' • ' '{print $1}' | xargs)

        echo "🚀 Launching emulator: $emulator_id..."
        flutter emulators --launch "$emulator_id"

        # Wait a moment for the emulator to initialize, then run the app
        echo "⏳ Waiting for emulator to boot..."
        sleep 5
        flutter run
    else
        echo "❌ Invalid choice or cancelled."
        exit 1
    fi
fi
