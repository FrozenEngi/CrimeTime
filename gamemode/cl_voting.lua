include("shared.lua")

local ButtonWidth = 250
local ButtonHeight = 80
local gameState = GAME_STATES.WaitingForPlayers
local frame
local VotingTotals = {}
local localVote = 0
local convicted = false

--This allows players to keep chatting with the voting panel up.
--[[hook.Add("FinishChat", "KeepChatOpen", function()
   --Voting panel is open? Reopen chat after sending a message.
   if frame != nil and frame:IsVisible() then
      chat.Open(1)
   end
end)--]]

function GM:FinishChat()
   if frame != nil and frame:IsVisible() then
      timer.Simple(0.3, function() chat.Open(1) end)
   end
end

local BUTTON = {
   Init = function(self)
      self:SetSize(ButtonWidth, ButtonHeight)

      self.ButtonBase = self:Add("DColorButton")
      self.ButtonBase:SetSize(ButtonWidth, ButtonHeight)
      self.ButtonBase:SetColor(Color(51, 53, 56, 255))
      self.ButtonBase:SetTextColor(Color(255, 255, 255, 255))
      self.ButtonBase:SetFont("DermaDefaultBold")
      self.ButtonBase:SetContentAlignment(8)
      self.ButtonBase:SetTooltip(false)
      self.ButtonBase:SetMouseInputEnabled(false)
      self.ButtonBase.DoClick = function()
         local localPly = LocalPlayer()
         local localPlyID = localPly:SteamID64()
         local plyID = self.Player:SteamID64() or self.Player:Nick()

         --Is the player voting for the same person again or themselves?
         if localVote == plyID or localPlyID == plyID then return end

         localVote = plyID

         net.Start("ClientVote")
         net.WriteEntity(self.Player)
         net.SendToServer()
      end

      self.PlayerInfo = self:Add("RichText")
      self.PlayerInfo:SetPos(70, 25)
      self.PlayerInfo:SetVerticalScrollbarEnabled(false)
      self.PlayerInfo:SetSize(100, 100)
      self.PlayerInfo:SetMouseInputEnabled(false)
      self.PlayerInfo.PerformLayout = function() 
         self.PlayerInfo:SetFontInternal("DermaDefaultBold")
      end

      self.Votes = self:Add("DLabel")
      self.Votes:SetPos(210, 15)
      self.Votes:SetSize(50, 50)
      self.Votes:SetFont("DermaLarge")
      self.Votes:SetText("")
   end,

   Setup = function(self, ply, index)
      self.Player = ply

      self.MouseInput = false
      self.PlayerValid = false

      local x = (index - 1) % 3
      self:SetPos(30 + x*(ButtonWidth + 5), 
         40 + math.floor((index - 1)/3)*(ButtonHeight + 5))
   end,

   Paint = function(self)
      local plyTeam = 0
      
      --Player is valid?
      if IsValid(self.Player) then
         plyTeam = self.Player:Team()
         self.PlayerValid = true
      end

      --Player is not valid yet?
      if self.PlayerValid == false then return end

      --Player is no longer valid?
      if !IsValid(self.Player) or (plyTeam != TEAMS.TOWN and plyTeam != TEAMS.MAFIA)
         and self.PlayerValid then
            self.ButtonBase:SetText("")
            self.PlayerInfo:SetText("")
            self.Votes:SetText("")
            
            --Did we draw a player icon?
            if self.Icon != nil then
               self.Icon:Hide()
            end

            self.PlayerValid = false
            return
      end

      local plyAlive = self.Player:Deaths() < 1

      --Player live or dead status changed?
      if self.PlayerAlive == nil or self.PlayerAlive != plyAlive then
         self.PlayerAlive = plyAlive
         self.PlayerName = nil
         self.PlayerClass = nil
      end

      --Player name changed?
      if self.PlayerName == nil or self.PlayerName != self.Player:Nick() then
         self.PlayerName = self.Player:Nick()

         --Player is alive?
         if self.PlayerAlive then
            self.ButtonBase:SetText(self.PlayerName)
         else
            self.ButtonBase:SetText(self.PlayerName .. " (DEAD)")
         end
      end

      local class = player_manager.GetPlayerClass(self.Player)
      local plyClass = baseclass.Get(class)

      --Player class changed?
      if self.PlayerClass == nil or self.PlayerClass != plyClass then
         self.PlayerClass = plyClass

         --Player isn't alive?
         if !self.PlayerAlive then
            self.PlayerInfo:InsertColorChange(255, 255, 255, 255)
            self.PlayerInfo:AppendText(plyClass.DisplayName .. "\n")

            local teamColor = team.GetColor(plyTeam)
            self.PlayerInfo:InsertColorChange(teamColor["r"], teamColor["g"], teamColor["b"], teamColor["a"])
            self.PlayerInfo:AppendText(team.GetName(plyTeam))
         else
            self.PlayerInfo:SetText("")
         end
      end

      local i = GetGlobalInt("Gamestate")
      gameState = GAME_STATES[i]

      local localPly = LocalPlayer()
      local localPlyAlive = localPly:Deaths() < 1
   
      --Player is alive and its the voting phase and no one is convicted and we're alive?
      if self.PlayerAlive and gameState == GAME_STATES.Voting and convicted == false and localPlyAlive then
         --Was mouse input disabled? Enabled it.
         if self.MouseInput == false then
            self.MouseInput = true
            self.ButtonBase:SetMouseInputEnabled(true)
         end

      --Was mouse input enabled? Disable it.
      elseif self.MouseInput == true then
            self.MouseInput = false
            self.ButtonBase:SetMouseInputEnabled(false)
      end

      local plyID = self.Player:SteamID64() or self.Player:Nick()

      --Does the player have votes?
      if VotingTotals[plyID] != nil and VotingTotals[plyID] > 0 then
         --New number of votes?
         if self.NumVotes == nil or self.NumVotes != VotingTotals[plyID] then
            self.NumVotes = VotingTotals[plyID]
            self.Votes:SetText(self.NumVotes)
         end
      else
         --The player has no votes now? No need to display a number.
         if self.NumVotes != nil then
            self.NumVotes = nil
            self.Votes:SetText("")
         end
      end

      --Player model changed?
      if self.PlayerModel == nil or self.PlayerModel != self.Player:GetModel() then
         self.PlayerModel = self.Player:GetModel()

         --Player icon was drawn? Remove it so we can redraw it.
         if self.Icon != nil then
            self.Icon:Remove()
         end

         self.Icon = spawnmenu.CreateContentIcon("model", self, { model = self.Player:GetModel() })
         self.Icon:SetPos(0, 15)
         self.Icon:SetEnabled(false)
         self.Icon:SetTooltip(false)
         self.Icon:SetMouseInputEnabled(false)
      end
   end  
}

BUTTON = vgui.RegisterTable(BUTTON, "Panel")

--Opens the trial vote dialog (guilty or innocent).
local function OpenTrialVoteDialog()
   local dialogW = 280
   local dialogH = 150

   local dialog = vgui.Create("DFrame")
   dialog:SetSize(dialogW, dialogH)
   dialog:SetPos(ScrW()/2 - dialogW/2, ScrH()/2 - dialogH/2)
   dialog:SetTitle("")
   dialog:MakePopup()

   local text = vgui.Create("DLabel", dialog)
   text:SetSize(180, 50)
   text:SetText("Cast your vote.")
   text:SetPos(dialogW/2 - text:GetWide()/2, dialogH/4)
   text:SetFont("DermaLarge")
   
   local btnGuilty = vgui.Create("DButton", dialog)
   btnGuilty:SetText("Guilty")
   btnGuilty:SetPos(dialogW/3 - btnGuilty:GetWide()/2, dialogH*(3/4) - btnGuilty:GetTall()/2)

   function btnGuilty:DoClick()
      net.Start("TrialVote")
      net.WriteInt(1, 2)
      net.SendToServer()

      dialog:Remove()
   end

   local btnInnocent = vgui.Create("DButton", dialog)
   btnInnocent:SetText("Innocent")
   btnInnocent:SetPos(dialogW*(2/3) - btnInnocent:GetWide()/2, dialogH*(3/4) - btnInnocent:GetTall()/2)

   function btnInnocent:DoClick()
      net.Start("TrialVote")
      net.WriteInt(-1, 2)
      net.SendToServer()

      dialog:Remove()
   end
end

--Called when there is a new vote.
local function VoteUpdate()
   local voter = net.ReadEntity()
   local voted = net.ReadEntity()
   local oldVotedID = net.ReadString()
   local voterID = voter:SteamID64()
   local votedID = voted:SteamID64() or voted:Nick()
   local localPly = LocalPlayer()

   --First vote?
   if VotingTotals[votedID] == nil then
      VotingTotals[votedID] = 1
   else
      VotingTotals[votedID] = VotingTotals[votedID] + 1
   end

   --Vote is being changed? Adjust the count for the previous voted player.
   if oldVotedID != "0" and VotingTotals[oldVotedID] != nil then
      VotingTotals[oldVotedID] = VotingTotals[oldVotedID] - 1
   end

   localPly:ChatPrint(voter:Nick() .. " voted to convict " .. voted:Nick() .. "!")

   local aliveCount = 0

   for k, ply in pairs(player.GetAll()) do
      --Player is alive?
      if ply:Alive() then
          aliveCount = aliveCount + 1
      end
   end

   local threshold = math.ceil(aliveCount/2)

   --Enough votes for trial were reached?
   if VotingTotals[votedID] >= threshold then
      --Is the player on trial not us and we're alive?
      if votedID != localPly:SteamID64() then
         timer.Simple(15, OpenTrialVoteDialog)
      end

      convicted = true
   end
end
net.Receive("ClientVote", VoteUpdate)

--Called when the server gives us the current votes.
local function ReceiveVotingTable()
   VotingTotals = net.ReadTable()

   local players = player.GetAll()

   for i=1,12 do
      local ply = players[i]
      
      local button = vgui.CreateFromTable (BUTTON, frame)
      button:Setup(ply, i)
   end
end
net.Receive("VotingTable", ReceiveVotingTable)

--Opens the voting panel to allow the player to vote.
function OpenVotingPanel()
   frame = vgui.Create("DFrame")
   frame:SetSize((ButtonWidth*3) + 80, (ButtonHeight*4) + 80)
   frame:SetPos(400, 60)
   frame:SetTitle("Voting Panel")

   net.Start("VotingTable")
   net.SendToServer()

   chat.Open(1)
end

--Called when the game state changes.
local function ResetVotes()
   convicted = false
   VotingTotals = {}
end
net.Receive("GameStateChange", ResetVotes)