include ('player_default.lua')

DEFINE_BASECLASS("player_default")

--CrimeTime Classes

CrimeTimeClasses = {"tycoon", "gravedigger", "lookout", "captain", "bartender", "doctor", 
   "handyman", "sheriff", "groundskeeper", "alchemist", "mayor"}

local TYCOON = {}
TYCOON.DisplayName = "Tycoon"
TYCOON.Description = "You can buy buildings around town."

local GRAVEDIGGER = {}
GRAVEDIGGER.DisplayName = "Gravedigger"
GRAVEDIGGER.Description = "You can get clues about those who died."

local LOOKOUT = {}
LOOKOUT.DisplayName = "Lookout"
LOOKOUT.Description = "You can present reports about night-time activity" ..
   " at the start of each voting phase. You can choose to present a true" ..
   " report or a randomly generated false."

local CAPTAIN = {}
CAPTAIN.DisplayName = "Captain"
CAPTAIN.Description = "You can smuggle weapons in via the docks and " ..
   "provide weapon upgrades."

local BARTENDER = {}
BARTENDER.DisplayName = "Bartender"
BARTENDER.Description = "You can get clues about the town."

local BANKER = {}
BANKER.DisplayName = "Banker"
BANKER.Description = "You can bail people out of jail. However, you can" ..
   " only do this a limited number of times."

local DOCTOR = {}
DOCTOR.DisplayName = "Doctor"
DOCTOR.Description = "You can save people from being killed at night."

local HANDYMAN = {}
HANDYMAN.DisplayName = "Handyman"
HANDYMAN.Description = "You can repair the turrets around town."

local SHERIFF = {}
SHERIFF.DisplayName = "Sheriff"
SHERIFF.Description = "You can choose a player to arrest and talk to that" ..
   " evening."

local GROUNDSKEEPER = {}
GROUNDSKEEPER.DisplayName = "Groundskeeper"
GROUNDSKEEPER.Description = "You have a hobo hut."

local ALCHEMIST = {}
ALCHEMIST.DisplayName = "Alchemist"
ALCHEMIST.Description = "You can give people medicine or make bombs."

local MAYOR = {}
MAYOR.DisplayName = "Mayor"
MAYOR.Description = "You can act as a tiebreaker."

player_manager.RegisterClass("tycoon", TYCOON, "player_default")
player_manager.RegisterClass("gravedigger", GRAVEDIGGER, "player_default")
player_manager.RegisterClass("lookout", LOOKOUT, "player_default")
player_manager.RegisterClass("captain", CAPTAIN, "player_default")
player_manager.RegisterClass("bartender", BARTENDER, "player_default")
player_manager.RegisterClass("banker", BANKER, "player_default")
player_manager.RegisterClass("doctor", DOCTOR, "player_default")
player_manager.RegisterClass("handyman", HANDYMAN, "player_default")
player_manager.RegisterClass("sheriff", SHERIFF, "player_default")
player_manager.RegisterClass("groundskeeper", GROUNDSKEEPER, "player_default")
player_manager.RegisterClass("alchemist", ALCHEMIST, "player_default")
player_manager.RegisterClass("mayor", MAYOR, "player_default")