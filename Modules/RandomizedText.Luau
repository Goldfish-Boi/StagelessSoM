local randomText = {
	towerlessDeath = {
		"Has something gone wrong?",
		"oof",
		"rip",
		"And thus you have died",
		"You died",
		"You were slain",
		"Game over",
		"The end",
	},
	towerDeath = {
		"Maybe next time you'll win",
		"Rather unfortunate don't you think?",
		"Don't you give up nah~ nah~ nah~",
		"It's alright it's just an obby afterall",
	},
	towerlessRevive = {
		"Back to reality",
		"function revive()",
		"Back from the grave",
		"Second chances they say"
	},
	towerRestart = {
		"That's the spirit!",
		"You got this!",
		"Let's do this!",
		"Have fun!",
		"One more time~",
		"Keep up your determination",
		"More playtime for me to collect!"
	},
	towerExit = {
		"Maybe try something else",
		"Not for you? That's ok",
		"Take a break and come back fresh",
		"Going back to the lobby",
	},
}


function randomText.returnDeathText(hasTower)
	local text

	if hasTower == "" then
		text = randomText.towerlessDeath[math.random(1, #randomText.towerlessDeath)]
		return text
	elseif hasTower ~= "" then
		text = randomText.towerDeath[math.random(1, #randomText.towerDeath)]
		return text
	else
		print("class Error")
	end
end

function randomText.returnReviveText(hasTower, location)
	local text
	
	if hasTower == "" then
		text = randomText.towerlessRevive[math.random(1, #randomText.towerlessRevive)]
	elseif hasTower ~= "" then
		if location == "Lobby" then
			text = randomText.towerExit[math.random(1, #randomText.towerExit)]
		elseif location == "Tower" then
			text = randomText.towerRestart[math.random(1, #randomText.towerRestart)]
		end
	end
	
	return text
end

return randomText
