document.getElementById('uploadButton').addEventListener('click', function () {
    const files = document.getElementById('logFiles').files;
    if (files.length === 0) {
        alert('Please select one or more .log files.');
        return;
    }

    const gameData = [];
    let filesProcessed = 0;

    Array.from(files).forEach(file => {
        const reader = new FileReader();
        reader.onload = function (event) {
            const content = event.target.result;
            const logData = parseLogFile(content);
            gameData.push(...logData);
            filesProcessed++;

            if (filesProcessed === files.length) {
                saveAndNavigate(gameData);
            }
        };
        reader.readAsText(file);
    });
});

function parseLogFile(fileContent) {
    const pattern = /({"level":"Info".*pc-play-statistics-feedback.*[\s\S].*with data:(.*)[\s\S])(with header.*})/g;

    const matches = fileContent.matchAll(pattern);

    const gameData = [];
    for (const match of matches) {
        try {
            // Extract the JSON data from the second capturing group as before
            const jsonDataString = match[2];
            // Attempt to parse the JSON data
            const jsonData = JSON.parse(jsonDataString);

            // Separate regex to extract the "time" value from the first capturing group
            const timeMatch = /"time":"([^"]+)"/.exec(match[1]);
            let time = "";
            if (timeMatch && timeMatch.length > 1) {
                time = timeMatch[1]; // Extract the time value from the regex match
            }

            jsonData.music_name = jsonData.music_name.replace(/<b>|<\/b>/g, '');

            const characterMap = {
                "26": "Virtual Singers Kagamine Rin & Len",
                "25": "Virtual Singer Hatsune Miku",
                "24": "Exorcist Master Buro",
                "23": "Boxer Ola",
                "22": "Leader of Rhodes Island Amiya",
                "21": "Black-white Magician Kirisame Marisa",
                "20": "Sister Marija",
                "19": "Rebirth Girl El_Clear",
                "18": "Red-white Miko Hakurei Reimu",
                "17": "Part-Time Warrior Rin",
                "16": "Game streamer NEKO#ΦωΦ",
                "15": "Navigator Yume",
                "14": "Sailor Suit Buro",
                "13": "Christmas Gift Rin",
                "12": "The Girl In Black Marija",
                "11": "Little Devil Marija",
                "10": "Magical Girl Marija",
                "9": "Maid Marija",
                "8": "Violinist Marija",
                "7": "Joker Buro",
                "6": "Zombie Girl Buro",
                "5": "Idol Buro",
                "4": "Pilot Buro",
                "3": "Bunny Girl Rin",
                "2": "Sleepwalker Girl Rin",
                "1": "Bad Girl Rin",
                "0": "Bassist Rin",
            };

            const elfinMap = {
                "10": "Neon Egg",
                "9": "Silencer",
                "8": "Dr. Paige",
                "7": "Lilith",
                "6": "Dragon Girl",
                "5": "Little Witch",
                "4": "Little Nurse",
                "3": "Rabot-233",
                "2": "Thanatos",
                "1": "Angela",
                "0": "Mio Sir",
            };

            const character_name = characterMap[jsonData.character_uid] || jsonData.character_name;
            const elfin_name = elfinMap[jsonData.elfin_uid] || jsonData.elfin_name || "No Elfin";

            gameData.push({
                time: time,
                music_uid: jsonData.music_uid,
                music_name: jsonData.music_name,
                music_difficulty: jsonData.music_difficulty,
                music_level: jsonData.music_level,
                character_uid: jsonData.character_uid,
                character_name: character_name,
                elfin_uid: jsonData.elfin_uid,
                elfin_name: elfin_name,
                result_acc: jsonData.result_acc,
                result_score: jsonData.result_score,
                result_finished: jsonData.result_finished,
                result_combo: jsonData.result_combo,
                result_full_combo: jsonData.result_full_combo,
            });
        } catch (error) {
            console.error('Error parsing log data:', error);
        }
    }
    return gameData;
}

function saveAndNavigate(data) {
    console.log(data); // This will log the final parsed data to the console
    sessionStorage.setItem('museDashData', JSON.stringify(data));
    window.location.href = 'visualizationPage.html'; // Adjust as needed
}
