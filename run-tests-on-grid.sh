#!/bin/bash

set -e

CONFIG_FILE="testim-config.json"

# Step 1: Load configuration from JSON
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Config file not found: $CONFIG_FILE"
    exit 1
fi

TESTIM_TOKEN=$(jq -r '.token' "$CONFIG_FILE")
TESTIM_PROJECT_ID=$(jq -r '.projectId' "$CONFIG_FILE")

if [ -z "$TESTIM_TOKEN" ] || [ -z "$TESTIM_PROJECT_ID" ]; then
    echo "❌ projectId or token is missing or empty in $CONFIG_FILE"
    exit 1
fi

# Step 2: Clean up old results (if any)
mkdir -p results
rm -f results/test-results.xml results/report.html results/testim.log

# Step 3: Run Testim
echo "🚀 Running Testim CLI..."
testim --token "$TESTIM_TOKEN" \
       --project "$TESTIM_PROJECT_ID" \
       --grid "Testim-Grid" \
       --mode "selenium" \
       --parallel 2 \
       --report-file results/test-results.xml | tee results/testim.log
