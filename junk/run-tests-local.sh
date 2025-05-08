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

TOKEN=$(jq -r '.token' "$CONFIG_FILE")
PROJECT_ID=$(jq -r '.projectId' "$CONFIG_FILE")
USER_ID=$(jq -r '.userId' "$CONFIG_FILE")

if [ -z "$TOKEN" ] || [ -z "$PROJECT_ID" ] || [ -z "$USER_ID" ]; then
    echo "❌ projectId or token is missing or empty in $CONFIG_FILE"
    exit 1
fi

# Step 1: Run Testim and export XML
echo "Running Testim..."
testim --token "$TOKEN" --project "$PROJECT_ID" --use-local-chrome-driver --user $USER_ID --parallel 2 --report-file results/test-results.xml > results/testim.log

# Step 2: Check if test-results.xml was created
if [ ! -f results/test-results.xml ]; then
  echo "❌ Test results not found! Something went wrong."
  exit 1
fi

# Step 3: Convert to HTML
echo "Generating HTML report..."
xunit-viewer --results results --file test-results.xml --output results/report.html

echo "✅ Report available at: results/report.html"
