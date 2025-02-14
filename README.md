# MuseDashScoreAnalyzer

Helper to view and analyze personal statistic of your Muse Dash scores.

This Repo currently contains two versions:

1. online version: https://6uhrmittag.github.io/MuseDashScoreAnalyzer
2. offline version that works with Powershell: `Export-MuseDashScores.ps1`

**Disclaimer:** This works by extracting the scores from the game logfiles. Every time the game is played, a logfile is written. I don't know far back th log-files go, so it might not be able to extract all scores.

![GifOfVisualizations](_static/GifOfVisualizations.gif)

## Overall Motivation

I want to have a view of my own Muse Dash scores over time to see how I improve.

## Status and Todos

- [x] Export scores as CSV and JSON
- [x] Visualize scores and accuracy per song in a chart
- [ ] Show details when hovering over a data point (e.g. character, elfin... )
- [x] translate/map the character and elfin names to english (right now it only shows the chinese names because that's what the log-files contain and I have not found a map from ID to name yet)
    - [x] create a mapping chart from ID to chinese and english name
    - [ ] add a switch to turn off the translation for the online version
- [ ] maybe one chart with all scores to see all scores over time
- [ ] switch to exclude failed runs(`result_finished:false`) from the chart
- [ ] switch to exclude runs with only one datapoint
- [x] add zoom feature to the charts
- [ ] add more charts for different statistics
    - [x] failed runs
    - [x] full combo
    - [x] total runs per song
    - [x] most used character
    - [x] most used elfin
    - [x] most played song
    - [x] finished vs. failed runs
    - [x] full combo vs. no full combo runs

# How to use

## Online Version

1. Go to: https://6uhrmittag.github.io/MuseDashScoreAnalyzer
2. Follow the instructions

## Export-MuseDashScores.ps1

1. Download `Export-MuseDashScores.ps1` and `MuseDashAnalytics.html.template`
2. Open powershell
3. Navigate to the directory where the script is located
4. Run the script with `.\Export-MuseDashScores.ps1`
5. The script creates `MuseDashAnalytics.html` and opens it in your default browser

The script will export the scores to a csv file and a json file(with the same content):

- `MuseDashScores.csv`
- `MuseDashScores.json`

![MuseDashExport.gif](_static/Export-MuseDashScores.ps1.gif)

![Sceenshot_charts.png](_static/Sceenshot_charts.png)

### Disable Translation of Characters and Elfins to English

Run the script with `.\Export-MuseDashScores.ps1 -KeepOriginalNames`

# Technical details

## official leaderboard

- MuseDash records the top 4000 of every song online, but even than only with minimal details - e.g. the date is missing
    - https://musedash.moe/player/<Player ID>   (you can get the ID from the gams "account" settings)
    - https://musedash.moe/mdmc/player  this somehow lists different/less scores for me... don't know why
- For custom charts, you can get some scores on your profile... but it doesn't seem to keep all scores: https://mdmc.moe/user/<ID>
    - technically the scores are also recorded in the channel #recent-scores on the [MDMC discord server](https://discord.com/servers/muse-dash-modding-community-812100927468470273)

## SO! How to get **ALL scores**?!

MuseDash creates a log-file very time you open the game. The results of each game is logged to the file. This script reads all log-files and extracts the scores.

The log-files are located in `C:\Users\<Windows Username>\AppData\LocalLow\PeroPeroGames\MuseDash\Logs\`

The Scores seem to get send to PeroPero even when you don't reach the top 4000. This request gets logged:

````text
{"level":"Info","time":"2024/1/1 18:44:13.422","msg":"============== Send to url: https://prpr-muse-dash.peropero.net/statistics/pc-play-statistics-feedback on method: POST ============== 
with data: {"player":"<REDACTED ACCOUNT ID>","player_level":146,"music_uid":"8-1","music_name":"Brain Power","music_difficulty":1,"music_level":4,"character_uid":"25","character_name":"初音未来-虚拟歌手","elfin_uid":"7","elfin_name":"莉莉丝","result_finished":true,"result_acc":90.8499951,"result_score":96850,"result_combo":135,"result_full_combo":false,"controller_name":"KeyboardCustom0"}
with header: {"Authorization":"<REDACTED SECRET>","Version":"3.12.1","Platform":"pc"}","stackTrace":null,"gameId":"com.PeroPeroGames.MuseDash","userId":null,"deviceId":"<REDACTED DEVICE ID>","sessionId":"<REDACTED>","platform":"WindowsPlayer","version":"3.12.1"}
````

The info we are interested in is:

````json
{
  "player": "<REDACTED ACCOUNT ID>",
  "player_level": 146,
  "music_uid": "8-1",
  "music_name": "Brain Power",
  "music_difficulty": 1,
  "music_level": 4,
  "character_uid": "25",
  "character_name": "初音未来-虚拟歌手",
  "elfin_uid": "7",
  "elfin_name": "莉莉丝",
  "result_finished": true,
  "result_acc": 90.8499951,
  "result_score": 96850,
  "result_combo": 135,
  "result_full_combo": false,
  "controller_name": "KeyboardCustom0"
}
````

### notes for future development

- the language isn't fixed to powershell. I'd love to have a real application for this but powershell is what worked fast
- be aware of the format of the data! This is an JSON object with two JSON objects inside!
- the Time and Date is in the outer object(in `time`), so it's not enough to just extract the `with data: {"player":` JSON
- the Date and Time format is non-standard(as far as I understand). The time doesn't include leading zeros
- the `character_name` would need to be mapped to the english character name in the game (or the script needs multiple language support)
- the `elfin_name` would need to be mapped to the english elfin name in the game (or the script needs multiple language support)
- the log-files also contain failed runs by setting `result_finished: false`. In this case the values for `result_score` etc. are empty

### notes on the exported data

````json
{
  "time": "Date and time of the finished run",
  "music_uid": "ID of the song",
  "music_name": "Name of the song(same as in the game)",
  "music_difficulty": "Song difficulty (1-4; easy, hard, master, hidden)",
  "music_level": "Song level (1-11)",
  "character_uid": "ID of the character",
  "character_name": "Name of the character in chinese",
  "elfin_uid": "ID of the elfin",
  "elfin_name": "Name of the elfin in chinese",
  "result_acc": "Accuracy in percent",
  "result_score": "Score of the run",
  "result_finished": "Run finished(true) or not(false)",
  "result_combo": "Highest combo in the run",
  "result_full_combo": "Full Combo reached(true) or not(false)"
}
````

### testing

Run the script with `.\ExtractGameData.ps1 -test` to use the test log-file in this repo.

### Export Format

See `.\test` for demo files of the export.

# Additional Notes

- Please open an issue if you have any questions or suggestions, as long as I somewhat understand the code I'm happy for any help
- I heavily use ChatGPT-4 and GitHub Copilot to code. I'm not a professional developer, so please don't judge me for the code quality :D
- Charting is done with [charts.js](https://www.chartjs.org/)