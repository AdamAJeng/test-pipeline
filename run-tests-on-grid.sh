#!/bin/bash

set -e

RESULTS_DIR="results"
CONFIG_FILE="testim-config.json"
XML_FILE="test-results.xml"
HTML_FILE="report.html"

# Step 1: Clean up old reports
echo "🧹 Cleaning up old test results..."
mkdir -p "$RESULTS_DIR"
find "$RESULTS_DIR" -type f \( -name "*.xml" -o -name "*.html" \) -exec rm -f {} +

# Step 2: Load configuration from JSON
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

# Step 3: Run Testim and export results
echo "🚀 Running Testim CLI..."
testim --token "$TESTIM_TOKEN" --project "$TESTIM_PROJECT_ID" --grid "Testim-Grid" --mode "selenium" --parallel 2 --report-file "$RESULTS_DIR/$XML_FILE" | tee "$RESULTS_DIR/testim.log"

# Step 4: Verify results file exists
if [ ! -f "$RESULTS_DIR/$XML_FILE" ]; then
    echo "❌ Test results not found! Testim may have failed."
    exit 1
fi

# Step 5: Generate HTML report
echo "📄 Generating HTML report..."
xunit-viewer --results "$RESULTS_DIR" --file "$XML_FILE" --output "$RESULTS_DIR/$HTML_FILE"

# Step 6: Confirm
if [ -f "$RESULTS_DIR/$HTML_FILE" ]; then
    echo "✅ Report generated at: $RESULTS_DIR/$HTML_FILE"
else
    echo "❌ Failed to generate HTML report."
    exit 1
fi
