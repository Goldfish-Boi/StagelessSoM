--== Multi-Tower Kit Server Config ==--

return {

	--== GAME BEHAVIOR ==--

	-- Both the client and the server time how long you are in a tower, but the client's is merely cosmetic
	-- The server will send it's own timer to the client to avoid desync
	-- This setting will determin how often (in seconds) the server corrents the client's timer
	TimerSyncInterval = 2,

	-- How often (in seconds) should the server check to see if a player has touched an anticheat checkpoint?
	CheckpointInterval = 0.25,

	-- How often (in seconds) can the player restart?
	RestartCooldown = 3,

	-- Does holding the R key send you to the first tower in the tower rush if in one? (or does it preserve your position?)
	RestartResetsTowerRush = false,


	--== COSMETIC ==--

	-- How often (in seconds) should the winpad change colors?
	WinpadInterval = 0.25,

	-- Should the winpads change colors?
	WinpadsChangeColor = true,

	-- Should the winpads change materials?
	WinpadsChangeMaterial = true,

	-- Will display names be used over usernames in announcements?
	UseDisplayName = false,


	--== WARNINGS ==--

	-- Should warnings of any kind be suppressed? (Not reccomended)
	Quiet = false,

	-- Should you be warned if tower checkpoints are stored in the workspace?
	CheckpointsWorkspaceWarning = true,

	-- Should you be warned if a tower has no checkpoints?
	CheckpointsMissingWarning = true,

	-- Should you be warned if a tower has no minimum completion time?
	NoMinimumTimeWarning = true,

	-- Should you be warned if players spawn with R15 rigs?
	R15Warning = true
}
