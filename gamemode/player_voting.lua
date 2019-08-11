local PlayerVotes = {}
local VoteTotals = {}

local TrialVotes = {}

--Notifies the clients when there is a new vote.
local function NotifyClientVote(length, voter)    
    local voted = net.ReadEntity ()
    local voterID = voter:SteamID64()
    local votedID = voted:SteamID64()
    local oldVotedID = 0

    --The voted player is already dead?
    if voted:Deaths() > 0 then return end

    --Voting for a bot?
    if voted:IsBot() then
        votedID = voted:Nick()
    end

    --Voter had a previous vote?
    if PlayerVotes[voterID] != nil then
        oldVotedID = PlayerVotes[voterID]
        VoteTotals[oldVotedID] = VoteTotals[oldVotedID] - 1
     end

    PlayerVotes[voterID] = votedID

    --First vote?
    if VoteTotals[votedID] == nil then
        VoteTotals[votedID] = 1
    else
        VoteTotals[votedID] = VoteTotals[votedID] + 1
    end

    local aliveCount = 0

    for k, ply in pairs(player.GetAll()) do
        --Player is alive?
        if ply:Alive() then
            aliveCount = aliveCount + 1
        end
    end

    local threshold = math.ceil(aliveCount/2)

    --Enough votes were reached?
    if VoteTotals[votedID] >= threshold then
        TrialVotes.Voted = voted
        TrialVotes.VoteTotal = 0
        CrimeTime.RoundTime = 30
        PrintMessage(HUD_PRINTTALK, voted:Nick() .. " was put on trial! They will now give their defense...")
    end

    net.Start("ClientVote")
    net.WriteEntity(voter)
    net.WriteEntity(voted)
    net.WriteString(oldVotedID)
    net.Broadcast()
end
net.Receive("ClientVote", NotifyClientVote)

--Receives a trial vote from a client.
local function ReceiveTrialVote(length, voter)
    local voterID = voter:SteamID64()
    local vote = net.ReadInt(2)

    --Voter already voted?
    if TrialVotes[voterID] != nil and TrialVotes[voterID] == vote then
        return
    end

    TrialVotes[voterID] = vote
    TrialVotes.VoteTotal = TrialVotes.VoteTotal + vote
end
net.Receive("TrialVote", ReceiveTrialVote)

--Gives the client the current votes.
local function SendVotingTable(length, cli)
    net.Start("VotingTable")
    net.WriteTable(VoteTotals)
    net.Send(cli)
end
net.Receive("VotingTable", SendVotingTable)

--Resets all votes. Called when the gamestate changes.
function ResetVotes()
    PlayerVotes = {}
    VoteTotals = {}

    --No trial?
    if TrialVotes.Voted == nil then return end

    local voted = TrialVotes.Voted

    --Majority guilty votes? Innocent votes = -1, Guilty votes = +1
    if TrialVotes.VoteTotal > 1 then
        PrintMessage(HUD_PRINTTALK, voted:Nick() .. " was voted guilty! They were hanged!")
        voted:Kill()
    else
        PrintMessage(HUD_PRINTTALK, voted:Nick() .. " was voted innocent!")
    end
    
    TrialVotes = {}
end