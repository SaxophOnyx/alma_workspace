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

FAILED=0

for package in modules/domain modules/data; do
    if [ -z "$(find "$package/test" -name '*_test.dart' -print -quit 2>/dev/null)" ]; then
        echo "No tests found in $package, skipping."
        continue
    fi

    (cd "$package" && dart test) || FAILED=1
done

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Done in ${DURATION} seconds${NC}"

if [ "$FAILED" -ne 0 ]; then
    echo -e "${RED}Tests failed${NC}" >&2
fi

exit $FAILED
