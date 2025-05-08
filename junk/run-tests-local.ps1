# Step 1: Clean up old reports
$resultsDir = "results"

if (Test-Path $resultsDir) {
    Write-Host "🧹 Cleaning up old test results..."
    Get-ChildItem -Path $resultsDir -Include *.xml, *.html -File -Recurse | Remove-Item -Force
} else {
    New-Item -ItemType Directory -Path $resultsDir | Out-Null
}

# Step 2: Load configuration from JSON
$configPath = "testim-config.json"
if (-not (Test-Path $configPath)) {
    Write-Error "❌ Config file not found at $configPath"
    exit 1
}

$config = Get-Content $configPath | ConvertFrom-Json

# Access values from JSON
$Token = $config.token
$ProjectId = $config.projectId
$User = $config.user

# Ensure the results directory exists
if (-not (Test-Path "results")) {
    New-Item -ItemType Directory -Path "results" | Out-Null
}

# Step 3: Run Testim and export results
Write-Host "Running Testim CLI..."
$testimCommand = "testim --token $Token --project $ProjectId --use-local-chrome-driver --user $User --report-file results/test-results.xml"
Invoke-Expression $testimCommand | Tee-Object -FilePath results\testim.log

# Step 4: Verify results file exists
if (-not (Test-Path "results\test-results.xml")) {
    Write-Error "❌ Test results not found! Testim may have failed."
    exit 1
}

# Step 5: Generate HTML report
Write-Host "Generating HTML report..."
xunit-viewer --results results --file test-results.xml --output results\report.html

# Step 6: Confirm
if (Test-Path "results\report.html") {
    Write-Host "✅ Report generated at: results\report.html"
} else {
    Write-Error "❌ Failed to generate HTML report."
    exit 1
}
