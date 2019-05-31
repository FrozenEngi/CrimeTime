include ('player_default.lua')

DEFINE_BASECLASS("player_default")

--Crime Time Classes

classes = {"tycoon", "gravedigger", "lookout", "captain", "bartender", "doctor", 
   "handyman", "sheriff", "groundskeeper", "alchemist", "mayor"}

local TYCOON = {}
TYCOON.DisplayName = "Tycoon"

local GRAVEDIGGER = {}
GRAVEDIGGER.DisplayName = "Gravedigger"

local LOOKOUT = {}
LOOKOUT.DisplayName = "Lookout"

local CAPTAIN = {}
CAPTAIN.DisplayName = "Captain"

local BARTENDER = {}
BARTENDER.DisplayName = "Bartender"

local BANKER = {}
BANKER.DisplayName = "Banker"

local DOCTOR = {}
DOCTOR.DisplayName = "Doctor"

local HANDYMAN = {}
HANDYMAN.DisplayName = "Handyman"

local SHERIFF = {}
SHERIFF.DisplayName = "Sheriff"

local GROUNDSKEEPER = {}
GROUNDSKEEPER.DisplayName = "Groundskeeper"

local ALCHEMIST = {}
ALCHEMIST.DisplayName = "Alchemist"

local MAYOR = {}
MAYOR.DisplayName = "Mayor"

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