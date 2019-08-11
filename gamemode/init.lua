--Tell the server which files the client needs to download.

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_keys.lua")
AddCSLuaFile("cl_voting.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("player_classes.lua")

--Server includes

include("shared.lua")
include("player_voting.lua")

CrimeTime = {}
CrimeTime.RoundTime = 0
local GameState = GAME_STATES.WaitingForPlayers
local ShouldSpawn = false
local RoundStarting = false

SetGlobalInt("Gamestate", GameState.Index)
SetGlobalInt("RoundTime", CrimeTime.RoundTime)

util.AddNetworkString("ClientSpawn")
util.AddNetworkString("ClientVote")
util.AddNetworkString("GameStateChange")
util.AddNetworkString("TrialVote")
util.AddNetworkString("VotingTable")

--Sets the gamestate to the new state.
local function SetGamestate(state)
    GameState = state
    CrimeTime.RoundTime = GameState.Time
    SetGlobalInt("Gamestate", GameState.Index)
    SetGlobalInt("RoundTime", CrimeTime.RoundTime)
    ResetVotes()

    net.Start("GameStateChange")
    net.Broadcast()
end

--Starts a new round.
local function StartRound()
    local Count = player.GetCount()
    local NumMafia = 2

    --Not enough players?
    if Count < 8 then
        SetGamestate(GAME_STATES.WaitingForPlayers)
        RoundStarting = false
        return
    elseif Count > 9 then
        NumMafia = 3
    end

    SetGamestate(GAME_STATES.Voting)

    --Randomize the order of the classes
    local classes = CrimeTimeClasses

    for i = #classes, 2, -1 do
        local j = math.random(i)
        classes[i], classes[j] = classes[j], classes[i]
    end

    ShouldSpawn = true

    local plys = player.GetAll()

    --We add 1 so that we get the correct number of players left in the loop.
    local plyCount = #plys + 1
    local mafiaCount = 0
    local townCount = 0
    local models = player_manager.AllValidModels()

    for k, ply in pairs(plys) do
        --Full?
        if mafiaCount == NumMafia and townCount == 9 then
            ply:SetTeam(0)
            ply:Spectate(OBS_MODE_ROAMING)
        
        --Full on mafia only?
        elseif mafiaCount == NumMafia then
            ply:SetTeam(TEAMS.TOWN)
            ply:SetHealth(30)
            ply:SetMaxHealth(30)

        --Need this player to be mafia?
        elseif (NumMafia - mafiaCount) == (plyCount - k) then
            ply:SetTeam(TEAMS.MAFIA)
            ply:SetMaxHealth(100)
            ply:SetHealth(100)

        --Otherwise, do a coin flip.
        else
            local team = math.random(2)

            ply:SetTeam(team)
        end

        ply:SetModel(table.Random(models))

        player_manager.SetPlayerClass(ply, classes[k])
        ply:SetDeaths(0)
        ply:Spawn()

        net.Start("ClientSpawn")
        net.Send(ply)
    end

    ShouldSpawn = false

    RoundStarting = false
    PrintMessage(HUD_PRINTTALK, "Round starting...")
end

--Updates the round time every second.
local function UpdateRoundTime()
    --Still waiting for players?
    if GameState == GAME_STATES.WaitingForPlayers then return end
    
    CrimeTime.RoundTime = CrimeTime.RoundTime - 1

    --Round hasn't ended?
    if CrimeTime.RoundTime >= 0 then 
        SetGlobalInt("RoundTime", CrimeTime.RoundTime)
        return 
    end

    --Voting phase is ending?
    if GameState == GAME_STATES.Voting then
        SetGamestate(GAME_STATES.NightTime)

        local plyTeam

        for k, ply in pairs(player.GetAll()) do
            --Player has not died?
            if ply:Deaths() < 1 then
                plyTeam = ply:Team()

                --Player is town?
                if plyTeam == TEAMS.TOWN then
                    ply:Give("weapon_pistol")
                elseif plyTeam == TEAMS.MAFIA then
                    ply:Give("weapon_pistol")
                end
            end
        end

    --Night time is ending?
    elseif GameState == GAME_STATES.NightTime then
        SetGamestate(GAME_STATES.Voting)

        for k, ply in pairs(player.GetAll()) do
            ply:RemoveAllItems()
        end

    --Post game is ending?
    elseif GameState == GAME_STATES.PostGame then
        StartRound()
    end
 end

--Start counting down the time for the first phase.
timer.Create("updateRoundTime", 1, 0, UpdateRoundTime)

--Sets the player's loadout
function GM:PlayerLoadout(ply)
    ply:RemoveAllItems()

    --Not the start of the round? Let them spectate.
    if !ShouldSpawn then
        ply:Spectate(OBS_MODE_ROAMING)
        return
    end
end

--Called when a player connects.
function GM:PlayerConnect(name, ip)
    --Round is starting or in progress?
    if GameState != GAME_STATES.WaitingForPlayers or RoundStarting then 
        return 
    end
    
    local Count = player.GetCount() + 1

    --We have enough players to start a round?
    if Count > 7 then
        timer.Simple(2, StartRound)
        RoundStarting = true
    end
end

--Called when a player disconnects.
function GM:PlayerDisconnected(ply)
    --Round isn't active?
    if GameState == GAME_STATES.WaitingForPlayers or 
       GameState == GAME_STATES.PostGame then return end

    local class = player_manager.GetPlayerClass(ply)
    if class == nil then return end

    local plyClass = baseclass.Get(class)
    if plyClass == nil then return end

    PrintMessage(HUD_PRINTTALK, ply:Nick() .. " has disconnected. " .. 
       " They were " .. plyClass.DisplayName .. " on the " .. ply:Team())

    local townAlive = false
    local townPlys = team.GetPlayers(TEAMS.TOWN)

    for k, ply in pairs(townPlys) do
        --Town player is alive?
        if ply:Deaths() < 1 then
            townAlive = true
        end
    end

    local mafiaAlive = false
    local mafiaPlys = team.GetPlayers(TEAMS.MAFIA)

    for k, ply in pairs(mafiaPlys) do
        --Mafia player is alive?
        if ply:Deaths() < 1 then
            mafiaAlive = true
        end
    end

    --No more living town players?
    if !townAlive then
        SetGamestate(GAME_STATES.PostGame)
        PrintMessage(HUD_PRINTTALK, "The Mafia wins!")

    --No more living mafia players?
    elseif !mafiaAlive then
        SetGamestate(GAME_STATES.PostGame)
        PrintMessage(HUD_PRINTTALK, "The Town wins!")
    end
end

--Called when a player dies.
function GM:PlayerDeath(victim, inflictor, attacker)
    local victimTeam = victim:Team()

    --Victim didn't have a team?
    if victimTeam < 1 then return end

    local teamPlys = team.GetPlayers(victimTeam)

    for k, ply in pairs(teamPlys) do
        --Team still has a living player?
        if ply:Deaths() < 1 then return end
    end

    local winningTeam

    --Victim was town?
    if victimTeam == TEAMS.TOWN then
        winningTeam = TEAMS.MAFIA
    else
        winningTeam = TEAMS.TOWN
    end

    SetGamestate(GAME_STATES.PostGame)
    PrintMessage(HUD_PRINTTALK, "The " .. team.GetName(winningTeam) .. " won!")
end

--Determines if players can hear voice chat.
function GM:PlayerCanHearPlayersVoice()
    return false, false
end
