--Tell the server which files the client needs to download.

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("player_classes.lua")

--Server includes

include("shared.lua")

--Start counting down the time for the first phase.

roundTime = 120
timer.Create("updateRoundTime", 1, 0, function() UpdateRoundTime() end)

--PlayerInitialSpawn: Called when player joins and spawns.
function GM:PlayerInitialSpawn(ply)
    --Mafia is full? We allow for 3 mafia and 9 town.

    if team.NumPlayers(2) > 2 then
        ply:SetTeam(1)
    else
        ply:SetTeam(team.BestAutoJoinTeam())
    end

    local models = player_manager.AllValidModels()
    ply:SetModel(table.Random(models))

    player_manager.SetPlayerClass(ply, table.Random(classes))
end

--PlayerLoadout: Sets the player's loadout
function GM:PlayerLoadout(ply)
    --Is this player town?

    if ply:Team() == 1 then
        ply:Give("weapon_pistol")
        ply:Give("weapon_crowbar")
        --ply:SetModel("models/player/Eli.mdl")

    --Otherwise they are mafia.

    else
        ply:Give("weapon_smg1")
        ply:Give("weapon_crowbar")
        --ply:SetModel(player_manager.TranslatePlayerModel("MobBoss"))
        --ply:SetModel("models/player/Eli.mdl")
    end

end

--UpdateRoundTime: Updates the round time every second.
function UpdateRoundTime()
   --Round ended? For now we reset back to 2 minutes.

   if roundTime == 0 then
      roundTime = 121
   end

   roundTime = roundTime - 1
   SetGlobalInt("roundTime", roundTime)
end
