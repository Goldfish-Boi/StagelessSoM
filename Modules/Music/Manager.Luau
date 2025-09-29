--!strict
-- MusicSystemManager by @synnwave
-- Modified for Stageless by @Goldfish_Boi

--> Types
export type ZonePart = {
	zoneID: string,
	id: string,
	part: BasePart,
	disabled: boolean,
	updateDisabled: (self: ZonePart, forceDisabled: boolean?) -> (),
}
export type Song = {
	id: string,
	zoneID: string,
	song: Sound,
	originalVolume: number,
	startAt: number?,
	name: string,
	focused: boolean,
	fadeIncrement: number,
	play: (self: Song, noFadeIn: boolean?) -> (),
}
export type Zone = {
	id: string,
	instance: Instance,
	zoneParts: { ZonePart },
	songs: { [string]: Song },
	tracklistIDs: { string },
	disabled: boolean?,
	priority: number,

	introSong: Song?,
	noFadeIn: boolean?,
	noFadeOut: boolean?,
	exitBehavior: string?,
	buttonActivatedColor: Color3?,
	buttonInverted: boolean?,
	orderedTracklistEnabled: boolean?,
}

--> Variables

local Manager = {
	Config = require(script.Settings),
	Communicator = Instance.new("BindableEvent"),

	Muted = false,
	CurrentSong = nil :: Song?,
	CurrentZone = nil :: Zone?,
	focusedPrimaryPart = nil :: BasePart?,
}

_G.MusicUseSmoothTransition = true -- there's going to be a lot of _G usage in this script because of backwards compatibility 😭
if Manager.Config.UseSmoothAsDefaultTransition ~= nil then
	_G.MusicUseSmoothTransition = Manager.Config.UseSmoothAsDefaultTransition
end

if Manager.Config.UseDefaultMuteButton == nil then
	Manager.Config.UseDefaultMuteButton = true
end

local EVENTS = {
	SONG_DATA_CHANGED = "song-data-changed",
	ENTERED_ZONE = "entered-zone",
	SET_MUTED = "set-muted",
	MUTE_STATE_CHANGED = "mute-state-changed",
	SONG_CHANGED = "song-changed",
}
Manager.Events = EVENTS

local UPDATE_INTERVAL = 0.25
local SOUND_UPDATE_INTERVAL = 0.1
local CLASSIC_SOUND_UPDATE_INTERVAL = 0.05

local ATTRIBUTE_KEYS = {
	INTRO = "IntroMusic",
	VOLUME = "OriginalVolume",
	DISABLED = "Disabled",
	STARTAT = "StartAt",
	CUSTOM_NAME = "MusicName",
	SOUNDID = "_SOUNDID",
	PRIORITY = "Priority",
	BUTTON_COLOR = "ButtonActivated",
	BUTTON_INVERT = "Invert",
	ORDERED_MUSIC = "OrderedTracklist",
	NOFADEIN = "NoFadeIn",
	NOFADEOUT = "NoFadeOut",
	ZONE_EXIT_BEHAVIOR = "ExitZoneBehavior",
	FADE_INCREMENT = "FadeIncrement",
}
local PLACEHOLDER_SONG_NAME = "[getting song name]"
local NUMBER_STRING_PATTERN = "%d+$"

local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

--> Functions
local function generateUID(curlyBraces: boolean?, dontRemoveSplit: boolean?): string
	return (HttpService:GenerateGUID(curlyBraces):gsub(if not dontRemoveSplit then "-" else "", ""))
end

local cachedMusicNames: { [number]: string } = {}
local function getSongName(soundId: string): string
	local realId = tonumber((soundId:match(NUMBER_STRING_PATTERN)))
	if typeof(realId) ~= "number" then
		return "?"
	end
	if cachedMusicNames[realId] then
		return cachedMusicNames[realId]
	end

	local success, assetData = pcall(function()
		return MarketplaceService:GetProductInfo(realId)
	end)
	if not success then
		return "error"
	end
	cachedMusicNames[realId] = assetData.Name
	task.defer(function()
		Manager.Communicator:Fire(EVENTS.SONG_DATA_CHANGED)
	end)
	return assetData.Name
end

local function checkZoneButton(zone: Zone)
	-- only here because of backwards compatibility. I hate this because the _G.Button metatable loops through workspace's descendants when called.. whyyy juke...... jukeee whyyy do you use _G so much i am gonna go insane
	local color = zone.buttonActivatedColor
	if typeof(color) == "Color3" and typeof(_G.Button) == "table" then
		local success, active = pcall(function()
			return _G.Button[color]
		end)
		if not success then
			warn(`Failed to check if the color frequency of ({tostring(color)}) is active! Assuming it is inactive`)
			active = false
		end

		if zone.buttonInverted then
			active = not active
		end
		return active
	end

	return true
end

local function updateIsFocused(song: Song, focusedID)
	local nowFocused = song.zoneID == focusedID
	if song.focused ~= nowFocused then
		song.focused = nowFocused
		if nowFocused then
			Manager.CurrentSong = song
			Manager.Communicator:Fire(EVENTS.SONG_CHANGED)
		end
	end

	return nowFocused
end

-- functions below are stolen from kit v6 but slightly modified
local function getConfigRaw(instance: Instance, configName: string): any
	if typeof(instance) ~= "Instance" or typeof(configName) ~= "string" then
		return
	end
	local foundValue: Instance? = instance:FindFirstChild(configName)
	local foundAttribute: any = instance:GetAttribute(configName)

	return if (foundValue and foundValue:IsA("ValueBase"))
		then (foundValue :: any).Value
		elseif foundAttribute ~= nil then foundAttribute
		else nil
end

local function getConfig<defaultType>(instance: Instance, configName: string, default: defaultType): defaultType
	local returnedConfig = getConfigRaw(instance, configName)
	return if typeof(default) == typeof(returnedConfig) then returnedConfig :: defaultType else default
end

local function getConfigChangedSignal(instance: Instance, configName: string): RBXScriptSignal
	local foundValue: Instance? = instance:FindFirstChild(configName)
	if foundValue and foundValue:IsA("ValueBase") then
		return (foundValue :: any):GetPropertyChangedSignal("Value")
	end

	return instance:GetAttributeChangedSignal(configName)
end

--> Code
local localPlayer = Players.LocalPlayer
local mainFolder = ReplicatedStorage:WaitForChild("Background Music")
local musicZonesModel = mainFolder:WaitForChild("BackgroundMusicZones") :: WorldModel
local globalMusic = mainFolder:WaitForChild("GlobalBackgroundMusic") :: Folder
Manager.RootFolder = mainFolder
Manager.BackgroundMusicZonesFolder = musicZonesModel
Manager.GlobalMusicFolder = globalMusic

Manager.SoundGroup = Instance.new("SoundGroup")
Manager.SoundGroup.Name = "MusicSoundGroup"
Manager.SoundGroup.Parent = SoundService
Manager.SoundGroup.Volume = 1
Manager.SoundGroup:SetAttribute(ATTRIBUTE_KEYS.VOLUME, 1)

local currentlyPlaying: { [string]: Song } = {}

--> Set up Zones
local zones: { [string]: Zone } = {}
local allZoneParts: { [string]: ZonePart } = {}
local zoneBlacklist: { Instance } = {}
local zoneParams = OverlapParams.new()
zoneParams.FilterType = Enum.RaycastFilterType.Exclude
zoneParams.FilterDescendantsInstances = zoneBlacklist
Manager.Zones = zones

local function newZone(zoneFolder: Instance, isGlobal: boolean?): Zone?
	local musicFolder = zoneFolder:FindFirstChild("Music") or (if isGlobal then zoneFolder else nil)
	if not musicFolder then
		return
	end

	local thisID = if isGlobal then "GLOBAL" else generateUID()

	--> Zones
	local zoneParts: { ZonePart } = {}
	if not isGlobal then
		for _, zonePart in zoneFolder:GetChildren() do
			if not zonePart:IsA("BasePart") then
				continue
			end
			local thisZonePart: ZonePart = {
				id = generateUID(),
				zoneID = thisID,
				disabled = getConfig(zonePart, ATTRIBUTE_KEYS.DISABLED, false),
				part = zonePart,
				updateDisabled = function(self, forceDisabled: boolean?)
					local blacklistIndex = table.find(zoneBlacklist, zonePart)
					local isDisabled = (forceDisabled or self.disabled)
					if isDisabled and not blacklistIndex then
						table.insert(zoneBlacklist, zonePart)
					elseif (not isDisabled) and blacklistIndex then
						table.remove(zoneBlacklist, blacklistIndex)
					end

					zoneParams.FilterDescendantsInstances = zoneBlacklist
				end,
			}

			thisZonePart:updateDisabled()
			getConfigChangedSignal(zonePart, ATTRIBUTE_KEYS.DISABLED):Connect(function()
				thisZonePart.disabled = getConfig(zonePart, ATTRIBUTE_KEYS.DISABLED, false)
				thisZonePart:updateDisabled()
			end)

			allZoneParts[thisZonePart.id] = thisZonePart
			table.insert(zoneParts, thisZonePart)
		end
	end

	--> Songs
	-- i probably overcomplicated this just for the ordered songs functionality ..
	local orderedTracklistEnabled: boolean? = getConfig(zoneFolder, ATTRIBUTE_KEYS.ORDERED_MUSIC, false)
	local songs: { [string]: Song } = {}
	local tracklistIDs: { string } = {}
	local introMusic
	local function newSong(song: Instance)
		if not song:IsA("Sound") then
			return
		end
		song:SetAttribute(ATTRIBUTE_KEYS.VOLUME, song.Volume)
		song.SoundGroup = Manager.SoundGroup

		local isIntroMusic = song.Name == ATTRIBUTE_KEYS.INTRO
		local isFetchingName = false
		local realFadeIncrement = getConfig(song, ATTRIBUTE_KEYS.FADE_INCREMENT, 30)
		local thisSong: Song = {
			id = generateUID(),
			zoneID = thisID,
			originalVolume = song.Volume,
			song = song,
			name = PLACEHOLDER_SONG_NAME,
			startAt = getConfigRaw(song, ATTRIBUTE_KEYS.STARTAT),
			focused = false,
			fadeIncrement = song.Volume / realFadeIncrement,
			play = function(self, noFadeIn)
				if song.SoundId == "" and typeof(song:GetAttribute(ATTRIBUTE_KEYS.SOUNDID)) == "string" then
					song.SoundId = song:GetAttribute(ATTRIBUTE_KEYS.SOUNDID)
				end

				--> Fetch song name
				task.spawn(function()
					if isFetchingName then
						return
					end
					isFetchingName = true
					self.name = getSongName(song.SoundId)
				end)

				if noFadeIn then
					song.Volume = self.originalVolume
				end
				if self.startAt then
					song.TimePosition = self.startAt
				end
				song:Play()
				self.focused = true
				currentlyPlaying[self.id] = self
				Manager.CurrentSong = self
				Manager.Communicator:Fire(EVENTS.SONG_CHANGED)
			end,
		}

		local setSongName = getConfigRaw(song, ATTRIBUTE_KEYS.CUSTOM_NAME)
		if typeof(setSongName) == "string" then
			isFetchingName = true
			thisSong.name = setSongName
		end
		getConfigChangedSignal(song, ATTRIBUTE_KEYS.CUSTOM_NAME):Connect(function()
			thisSong.name = getConfigRaw(song, ATTRIBUTE_KEYS.CUSTOM_NAME)
			Manager.Communicator:Fire(EVENTS.SONG_DATA_CHANGED)
		end)

		getConfigChangedSignal(song, ATTRIBUTE_KEYS.VOLUME):Connect(function()
			thisSong.originalVolume = getConfig(song, ATTRIBUTE_KEYS.VOLUME, 1)
			thisSong.fadeIncrement = thisSong.originalVolume / realFadeIncrement
		end)
		getConfigChangedSignal(song, ATTRIBUTE_KEYS.STARTAT):Connect(function()
			thisSong.startAt = getConfig(song, ATTRIBUTE_KEYS.STARTAT, 0)
		end)

		if isIntroMusic then
			introMusic = thisSong
		else
			table.insert(tracklistIDs, thisSong.id)
			songs[thisSong.id] = thisSong
		end

		--> Loop Functionality
		local function loopSong()
			currentlyPlaying[thisSong.id] = nil
			if not song.Playing then
				return
			end
			song:Stop()

			if not (Manager.CurrentZone and Manager.CurrentZone.id == thisID) then
				return
			end
			local chosenSongID
			if orderedTracklistEnabled then
				chosenSongID = tracklistIDs[(table.find(tracklistIDs, thisSong.id) or 0) + 1] or tracklistIDs[1]
			elseif #tracklistIDs <= 1 and not isIntroMusic then
				chosenSongID = thisSong.id
			else
				chosenSongID = tracklistIDs[math.random(#tracklistIDs)]
			end

			songs[chosenSongID]:play(true)
		end

		if isIntroMusic then
			song.Played:Connect(function()
				if not song.IsLoaded then
					song.Loaded:Wait()
				end -- wait for the song to actually load
				task.delay(song.TimeLength - 0.05, function()
					if song.Playing and song.TimePosition > (song.TimeLength - 1) then
						loopSong()
					end
				end)
			end)
		else
			song.DidLoop:Connect(loopSong)
		end

		if orderedTracklistEnabled and not isIntroMusic then --> Sort songs table
			table.sort(tracklistIDs, function(a, b)
				local a_Order = tonumber((songs[a].song.Name:match(NUMBER_STRING_PATTERN))) or math.huge -- kill me
				local b_Order = tonumber((songs[b].song.Name:match(NUMBER_STRING_PATTERN))) or math.huge -- ^^^^^^^
				return a_Order < b_Order
			end)
		end
	end

	for _, song in musicFolder:GetChildren() do
		task.spawn(newSong, song)
	end
	musicFolder.ChildAdded:Connect(newSong)

	--> Finalize
	local thisZone: Zone = {
		id = thisID,
		instance = zoneFolder,
		zoneParts = zoneParts,
		songs = songs,
		tracklistIDs = tracklistIDs,
		introSong = introMusic,

		orderedTracklistEnabled = orderedTracklistEnabled,
		disabled = getConfig(zoneFolder, ATTRIBUTE_KEYS.DISABLED, false),
		priority = getConfig(zoneFolder, ATTRIBUTE_KEYS.PRIORITY, 1),
		noFadeIn = getConfig(zoneFolder, ATTRIBUTE_KEYS.NOFADEIN, false),
		noFadeOut = getConfig(zoneFolder, ATTRIBUTE_KEYS.NOFADEOUT, false),
		exitBehavior = getConfig(zoneFolder, ATTRIBUTE_KEYS.ZONE_EXIT_BEHAVIOR, "Stop"),
		buttonActivatedColor = getConfigRaw(zoneFolder, ATTRIBUTE_KEYS.BUTTON_COLOR),
		buttonInverted = getConfigRaw(zoneFolder, ATTRIBUTE_KEYS.BUTTON_INVERT),
	}

	local function updateDisabledParts()
		for _, zonePart in zoneParts do
			zonePart:updateDisabled(thisZone.disabled)
		end
	end

	updateDisabledParts()
	getConfigChangedSignal(zoneFolder, ATTRIBUTE_KEYS.DISABLED):Connect(function()
		thisZone.disabled = getConfig(zoneFolder, ATTRIBUTE_KEYS.DISABLED, false)
		updateDisabledParts()
	end)
	getConfigChangedSignal(zoneFolder, ATTRIBUTE_KEYS.PRIORITY):Connect(function()
		thisZone.priority = getConfig(zoneFolder, ATTRIBUTE_KEYS.PRIORITY, 1)
	end)

	zoneFolder.Destroying:Connect(function()
		--> remove zoneparts from the table & blacklist
		for _, zonePart in zoneParts do
			allZoneParts[zonePart.id] = nil

			local blacklistIndex = table.find(zoneBlacklist, zonePart.part)
			if blacklistIndex then
				table.remove(zoneBlacklist, blacklistIndex)
			end
			zoneParams.FilterDescendantsInstances = zoneBlacklist
		end

		--> clear any currently playing songs
		for _, songID in tracklistIDs do
			currentlyPlaying[songID] = nil
		end
		if introMusic then
			currentlyPlaying[introMusic.id] = nil
		end

		--> clear tables from memory
		zones[thisID] = nil
		thisZone = nil :: any
		zoneParts = nil :: any
		songs = nil :: any
		tracklistIDs = nil :: any
	end)

	zones[thisID] = thisZone
	return thisZone
end

local globalZone = newZone(globalMusic, true) :: Zone
for _, zone in musicZonesModel:GetDescendants() do -- sorry not sorry
	task.spawn(newZone, zone)
end

musicZonesModel.DescendantAdded:Connect(function(descendant: Instance)  
    task.wait() -- fixes the sound replicating before the whole zone
    newZone(descendant)
end)

--> Main Loop
local lastZoneCheck = os.clock()
local lastAudioCheck = os.clock()

local function getRootPart(character)
	task.wait() -- don't know why . but this fixes things
	local humanoid = character:WaitForChild("Humanoid")
	while not humanoid.RootPart do
		task.wait()
	end
	Manager.focusedPrimaryPart = humanoid.RootPart
end

task.spawn(getRootPart, localPlayer.Character or localPlayer.CharacterAdded:Wait())
localPlayer.CharacterAdded:Connect(getRootPart)

RunService.Heartbeat:Connect(function()
	debug.profilebegin("MusicSystem -> Loop")
	local currentClock = os.clock()
	local useSmooth = _G.MusicUseSmoothTransition

	--> Check Zones
	debug.profilebegin("MusicSystem -> Check Music Zones")
	if (currentClock - lastZoneCheck) >= UPDATE_INTERVAL and not _G.LockMusicPlaying then
		lastZoneCheck = currentClock
		local primaryPart = Manager.focusedPrimaryPart
		if not primaryPart then
			debug.profileend()
			debug.profileend()
			return
		end

		--> Get zones that the player is in
		local zonesIn: { string } = {}
		local blacklistedZones: { [string]: boolean } = {}
		for _, part in musicZonesModel:GetPartsInPart(primaryPart, zoneParams) do
			local rootZoneID: string?
			for _, zonePart in allZoneParts do
				if zonePart.disabled or zonePart.part ~= part then
					continue
				end
				rootZoneID = zonePart.zoneID
				break
			end

			if not ((rootZoneID and not blacklistedZones[rootZoneID]) and (not table.find(zonesIn, rootZoneID))) then
				continue
			end
			local thisZone = zones[rootZoneID]
			if thisZone.disabled or (not checkZoneButton(thisZone)) then
				blacklistedZones[rootZoneID] = true
				continue
			end

			table.insert(zonesIn, rootZoneID)
		end

		--> Sort by priority to get the best zone
		table.sort(zonesIn, function(a, b)
			return zones[a].priority > zones[b].priority
		end)
		local bestZone: Zone = zones[zonesIn[1]] or globalZone
		if not (Manager.CurrentZone and Manager.CurrentZone.id == bestZone.id) then
			Manager.CurrentZone = bestZone
			Manager.Communicator:Fire(EVENTS.ENTERED_ZONE, bestZone.id)
		end

		--local sideZone: Zone? = zones[zonesIn[2]] --TODO: add a feature where you can have two zones playing at once

		--> Play music
		local isMusicPlaying = false
		for _, song in currentlyPlaying do
			updateIsFocused(song, bestZone.id)
			if not song.focused then
				continue
			end
			isMusicPlaying = true
			break
		end

		local currentZone = Manager.CurrentZone
		if
			not isMusicPlaying and (currentZone and (#currentZone.tracklistIDs > 0 or currentZone.introSong ~= nil))
		then
			local trackID = if currentZone.orderedTracklistEnabled then 1 else math.random(#currentZone.tracklistIDs)
			local songToPlay = currentZone.introSong or currentZone.songs[currentZone.tracklistIDs[trackID]]
			songToPlay.song.Volume = 0
			if useSmooth then
				songToPlay:play(currentZone.noFadeIn)
			else
				currentlyPlaying[songToPlay.id] = songToPlay
			end
		end
	end
	debug.profileend()

	--> Update music volumes
	debug.profilebegin("MusicSystem -> Update music volumes")
	local currentUpdateInterval = if useSmooth then SOUND_UPDATE_INTERVAL else CLASSIC_SOUND_UPDATE_INTERVAL
	if (currentClock - lastAudioCheck) >= currentUpdateInterval then
		lastAudioCheck = currentClock

		local totalPlaying = 0
		for _ in currentlyPlaying do
			totalPlaying += 1
		end

		local focusedID = Manager.CurrentZone and Manager.CurrentZone.id
		for _, currentSong in currentlyPlaying do
			local isFocused = updateIsFocused(currentSong, focusedID)

			local soundInstance = currentSong.song
			local currentVolume = soundInstance.Volume
			local originalVolume = currentSong.originalVolume
			if isFocused and currentVolume == originalVolume then
				continue
			end

			local lastVolume = currentVolume
			local parentZone = zones[currentSong.zoneID]
			if not parentZone then
				currentlyPlaying[currentSong.id] = nil
				continue
			end

			if isFocused then
				if soundInstance.IsPlaying then -- smooth transition
					currentVolume = if parentZone.noFadeIn then originalVolume else currentVolume
					currentVolume += currentSong.fadeIncrement
				elseif totalPlaying <= 1 then -- classic transition
					currentVolume = originalVolume
					currentSong:play(true)
				end
			else
				currentVolume = if parentZone.noFadeOut then 0 else currentVolume
				currentVolume -= currentSong.fadeIncrement
				if currentVolume <= 0 then
					if parentZone.exitBehavior == "Pause" then
						soundInstance:Pause()
					else
						soundInstance:Stop()
					end

					currentlyPlaying[currentSong.id] = nil
				end
			end

			currentVolume = math.clamp(currentVolume, 0, originalVolume)
			if lastVolume == currentVolume then
				continue
			end
			soundInstance.Volume = currentVolume
		end
	end
	debug.profileend()
	debug.profileend()
end)

--> Listen to events
Manager.Communicator.Event:Connect(function(type: string, ...)
	if type == EVENTS.SET_MUTED then
		local muted = ...
		local toggle = if typeof(muted) == "boolean" then muted else not Manager.Muted

		Manager.Muted = toggle
		Manager.SoundGroup.Volume = if toggle then 0 else Manager.SoundGroup:GetAttribute(ATTRIBUTE_KEYS.VOLUME)
		Manager.Communicator:Fire(EVENTS.MUTE_STATE_CHANGED, toggle)
	end

	--> _G Backwards compatibility
	if (type == EVENTS.SONG_CHANGED) or (type == EVENTS.SONG_DATA_CHANGED) or (type == EVENTS.ENTERED_ZONE) then
		_G.MusicName = if Manager.CurrentSong then Manager.CurrentSong.name else ""
		_G.CurrentlyPlayingMusic = Manager.CurrentSong and Manager.CurrentSong.song
	end
end)

return Manager
