#!/bin/bash/

set -e

CONFIG_FILE="testim-config.json"
RESULTS_DIR="results"
XML_FILE="test-results.xml"

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

# Step 2: Ensure results directory exists
mkdir -p "$RESULTS_DIR"

# Step 3: Run Testim and export results
echo "🚀 Running Testim CLI..."
testim --token "$TESTIM_TOKEN" \
       --project "$TESTIM_PROJECT_ID" \
       --grid "Testim-Grid" \
       --parallel 2 \
       --report-file "$RESULTS_DIR/$XML_FILE" \
       | tee "$RESULTS_DIR/testim.log"
