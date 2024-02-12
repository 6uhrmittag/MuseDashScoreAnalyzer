<#
.SYNOPSIS
    Exports personal scores from Muse Dash game to CSV and JSON formats.

.DESCRIPTION
    This script extracts personal game scores from Muse Dash logs and exports the data into both CSV and JSON files in the current directory.

    The script scans the game's log files for score information and then processes this data to create a structured representation of the scores, which includes details such as music name, difficulty, player's score, accuracy, and more.

.PARAMETER test
    Indicates whether the script should run in test mode. When specified, the script uses an alternative log path for testing purposes.

.EXAMPLE
    .\ExtractGameData.ps1
    Runs the script with the default log path. It will automatically locate the Muse Dash log files, extract the scores, and export them to MuseDashScores.csv and MuseDashScores.json in the current directory.

.EXAMPLE
    .\ExtractGameData.ps1 -test
    Runs the script in test mode, using the alternative log path for log files. This is useful for testing purposes or when accessing logs from a different location.

#>

param (
    [switch]$test
)

# Configuration variables
if ($test)
{
    $logPath = ".\test\"
}
else
{
    $logPath = "C:\Users\$env:USERNAME\AppData\LocalLow\PeroPeroGames\MuseDash\Logs\"
}

$jsonFilePath = "MuseDashScores.json"
$csvFilePath = "MuseDashScores.csv"

# Informing the user about the process start and which mode is being used
Write-Host "Starting Muse Dash scores extraction process..."
if ($test)
{
    Write-Host "Running in test mode. Using alternative log path for testing." -ForegroundColor Yellow
}

# Verify log path existence
if (-Not(Test-Path $logPath))
{
    Write-Host "Log path does not exist. Please ensure Muse Dash is installed and has been run at least once." -ForegroundColor Red
    exit
}
else
{
    Write-Host "Log path found. Processing log files..." -ForegroundColor Green
}

# Initialize an array to store game data
$gameData = @()

# Define a regex pattern to filter lines related to statistics feedback
$pattern = '({"level":"Info".*pc-play-statistics-feedback.*[\s\S].*with data:(.*)[\s\S])(with header.*})'

# Process each log file
Get-ChildItem $logPath -Filter *.log | ForEach-Object {
    $filePath = $_.FullName
    $fileContent = Get-Content $filePath -Raw

    Write-Host "Processing file: $filePath"

    # Find matches that include 'with data:'
    [regex]::Matches($fileContent, $pattern) | ForEach-Object {
        $match_post = $_.Groups[1].Value
        $match_data = $_.Groups[2].Value

        try
        {
            $time = if ($match_post -match '"time":"([^"]+)"')
            {
                $matches[1]
            }
            $jsonData_DATA = $match_data | ConvertFrom-Json

            # clean-up jsonData_DATA since some seem to have '<b>' and '</b>' in them
            $jsonData_DATA.music_name = $jsonData_DATA.music_name -replace '<b>|</b>'

            # Add the relevant fields to an object and add it to the gameData array
            $gameData += [PSCustomObject]@{
                time = $time
                music_uid = $jsonData_DATA.music_uid
                music_name = $jsonData_DATA.music_name
                music_difficulty = $jsonData_DATA.music_difficulty
                music_level = $jsonData_DATA.music_level
                character_uid = $jsonData_DATA.character_uid
                character_name = $jsonData_DATA.character_name
                elfin_uid = $jsonData_DATA.elfin_uid
                elfin_name = $jsonData_DATA.elfin_name
                result_acc = $jsonData_DATA.result_acc
                result_score = $jsonData_DATA.result_score
                result_finished = $jsonData_DATA.result_finished
                result_combo = $jsonData_DATA.result_combo
                result_full_combo = $jsonData_DATA.result_full_combo
            }
        }
        catch
        {
            Write-Warning "Failed to parse JSON data from file: $filePath. Error: $_"
        }
    }
}

# Export to JSON
$gameData | ConvertTo-Json | Set-Content $jsonFilePath
Write-Host "Scores have been successfully exported to JSON file: $jsonFilePath"

# Export to CSV
$gameData | Export-Csv $csvFilePath -NoTypeInformation
Write-Host "Scores have been successfully exported to CSV file: $csvFilePath"

Write-Host "Muse Dash scores extraction process completed." -ForegroundColor Green



# New code to insert JSON into HTML template

# Step 1: Read the JSON data
$jsonData = Get-Content $jsonFilePath -Raw

# Step 2: Read the template HTML content
$templateHtmlPath = "MuseDashAnalytics.html.template"
$templateContent = Get-Content $templateHtmlPath -Raw

# Step 3: Replace the placeholder with the JSON data
# Make sure your template has a line with: var data = <INSERT JSON HERE>;
$modifiedContent = $templateContent -replace "<INSERT JSON HERE>", $jsonData

# Step 4: Save the modified content as a new HTML file
$newHtmlFilePath = "MuseDashAnalytics.html"
$modifiedContent | Set-Content $newHtmlFilePath

Write-Host "Muse Dash analytics HTML file has been successfully created: $newHtmlFilePath" -ForegroundColor Green

# Open the newly created HTML file in the default web browser
Invoke-Item $newHtmlFilePath