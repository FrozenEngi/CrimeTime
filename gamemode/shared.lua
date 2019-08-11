--Shared includes

include("player_classes.lua")

--Set gamemode information

GM.Name = "Crime Time"
GM.Author = "Frozen Engi"
GM.Email = "rjones898@gmail.com"
GM.Website = "N/A"

--Game states

local WaitingForPlayers = {}
WaitingForPlayers.Name = "Waiting For Players"
WaitingForPlayers.Time = 0
WaitingForPlayers.Index = 1

local Voting = {}
Voting.Name = "Voting Phase"
Voting.Time = 120
Voting.Index = 2

local NightTime = {}
NightTime.Name = "Night Time"
NightTime.Time = 120
NightTime.Index = 3

local PostGame = {}
PostGame.Name = "Post Game"
PostGame.Time = 15
PostGame.Index = 4

GAME_STATES = {}

GAME_STATES.WaitingForPlayers = WaitingForPlayers
GAME_STATES[WaitingForPlayers.Index] = WaitingForPlayers

GAME_STATES.Voting = Voting
GAME_STATES[Voting.Index] = Voting

GAME_STATES.NightTime = NightTime
GAME_STATES[NightTime.Index] = NightTime

GAME_STATES.PostGame = PostGame
GAME_STATES[PostGame.Index] = PostGame

--Teams

TEAMS = {}
TEAMS.TOWN = 1
TEAMS.MAFIA = 2

--Set up teams. Note: Color(red, green, blue, transparency)

team.SetUp(1, "Town", Color(0, 0, 255, 255))
team.SetUp(2, "Mafia", Color(255, 0, 0, 255))

--Called after the gamemode loads and starts
function GM:Initialize()
end
