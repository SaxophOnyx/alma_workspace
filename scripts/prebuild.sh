#!/bin/bash

if [ -f "pubspec.yaml" ]; then
    echo "Found pubspec.yaml in current directory."
elif [ -f "../pubspec.yaml" ]; then
    echo "Found pubspec.yaml in parent directory. Changing directory..."
    cd .. || { echo "Error: Failed to change directory." >&2; exit 1; }
else
    echo "Error: pubspec.yaml not found in current or parent directory." >&2
    exit 1
fi

START_TIME=$(date +%s)

flutter clean
dart pub get

(cd modules/shared_ui && dart run slang)

dart run build_runner build --workspace

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""

GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}Done in ${DURATION} seconds${NC}"
