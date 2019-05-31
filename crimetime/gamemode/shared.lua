--Shared includes

include("player_classes.lua")

--Set gamemode information

GM.Name = "Crime Time"
GM.Author = "Frozen Engi"
GM.Email = "rjones898@gmail.com"
GM.Website = "N/A"

--Set up teams. Note: Color(red, green, blue, transparency)

team.SetUp(1, "Town", Color(0, 0, 255, 255))
team.SetUp(2, "Mafia", Color(255, 0, 0, 255))

--Tell the client to download these resources.

resource.AddFile("models/mafia/male_08.mdl")
resource.AddFile("materials/models/humans/mafia")

--Initialization function for gamemode
function GM:Initialize()
   player_manager.AddValidModel( "MobBoss",			"models/humans/mafia/male_08.mdl" )
   player_manager.AddValidModel( "Mobster1",			"models/humans/mafia/male_02.mdl" )
   player_manager.AddValidModel( "Mobster2",			"models/humans/mafia/male_04.mdl" )
   player_manager.AddValidModel( "Mobster3",			"models/humans/mafia/male_06.mdl" )
   player_manager.AddValidModel( "Mobster4",			"models/humans/mafia/male_07.mdl" )
   player_manager.AddValidModel( "Mobster3",			"models/humans/mafia/male_09.mdl" )
end
