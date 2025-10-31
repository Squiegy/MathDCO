local badges = require(game.ReplicatedStorage.BadgesModuleScript)

local t = {

}

for i,v in pairs(badges) do
	t[tostring(v.Id)] = false
end
t["FirstAgain"] = true

local module = {
	['leaderstats'] = {
		['Stage'] = 0,
	},
	['stats'] = {
		['FreeHint'] = false,
		['Hints'] = 0,
		['Savers'] = 0,
		['Device'] = "PC",
		['Deaths'] = 0,
		['Multiplier'] = 1,
		['CurrentHalo'] = '',
		['CurrentFlame'] = '',
		['CurrentTag'] = '',
		['CurrentStage'] = 0,
		['Restarts'] = 0,
		['Tickets'] = 0,
		['Streak'] = 0,
		['HighestStreak'] = 0,
		['HighestStage'] = 0,
		['LastReview'] = os.time(),
		['Robux'] = 0,
		['FirstJoin'] = true,
		['RIAFreeSkip24'] = false,
		['FirstFall'] = true,
		['isVIP'] = true,
		['BadgesEarned'] = 0,
		['TimePlayed'] = 0,
		['FreeSkips'] = 0,
		['Sunsetter'] = false,
		['Cooldown'] = 0,
		['Link'] = "[]",
	},
	['settings'] = {
		['Lights'] = false,
		['Shadows'] = false,
		['Textures'] = true,
		['HideUI'] = false,
		['LDM'] = false,
		['StreakNotif'] = true,
		['CorrectNotif'] = false,
		['SpeedrunMode'] = false,
		['TipNotif'] = true,
		['Region'] = true, -- false means us, true means international
		['DecimalComma'] = false, -- false means 1.24, true means 1,24
		['Creator'] = true, -- false copyright plays,true non copyright plays
		['PlayersVisible'] = true,
		['DarkMode'] = false,
		['Offset'] = 0,
		['FPS'] = false,
		['Ping'] = false,
		['PromptStreakSave'] = 40,

	},
	['speedrun'] = {
		['Grade1'] = math.huge,
		['Grade2'] = math.huge,
		['Grade3'] = math.huge,
		['Grade4'] = math.huge,
		['Grade5'] = math.huge,
		['Grade6'] = math.huge,
		['Grade7'] = math.huge,
		['Grade8'] = math.huge,
		['Grade9'] = math.huge,
		['Grade10'] = math.huge,
		['Grade11'] = math.huge,
		['BestTime'] = math.huge,
		['BestTime9'] = math.huge,
		['BestTime10'] = math.huge
	},
	['challenges'] = {
		['Streak'] = 0,
		['LastProblem'] = 0, -- when was the last time the player answered a question
		['LastProblemSimple'] = 0, 
		['LastProblemAdvanced'] = 0, 
		['LastProblemExpert'] = 0, 
		['SimpleCompletions'] = 0,
		['AdvancedCompletions'] = 0,
		['ExpertCompletions'] = 0,
		['Credits'] = 0,
		['Hearts'] = 3,
		['LastDay'] = 0,
		['LastDaySimple'] = 0,
		['LastDayAdvanced'] = 0,
		['LastDayExpert'] = 0,
		['PlayedToday'] = 0
	},

	['halloween'] = {
		['Began'] = false,
		['Done'] = true,
		['AbePumpkin'] = false,
		['BossPumpkin'] = false,
		['EmoPumpkin'] = false,
		['MattPumpkin'] = false,
		['MePumpkin'] = false,
		['TaskNum'] = 0,
		['Task1Count'] = 0,
		['InTask3'] = false,
		['Task3Done'] = false,
		['CreditsGoal'] = 0
	},
	['towers'] = {
		['InTower'] = false
	},
	['piday'] = {
		['Digit'] = 1,
		['MaxDigit'] = 1,
		['Review'] = 0
	},
	['all_badges'] = t
}
return module
