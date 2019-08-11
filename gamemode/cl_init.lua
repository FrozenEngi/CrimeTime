--Client includes

include("cl_keys.lua")
include("shared.lua")

--Fonts

surface.CreateFont("RoleInfo", {font = "Verdana",
                                    size = 20,
                                    weight = 1000})

local frame
local richtext
local ply
local index
local gameState
local roundTime

--Converts seconds to a format with minutes and seconds.
local function SimpleTime(seconds, fmt)
   --Seconds weren't given?
	if not seconds then seconds = 0 end

   seconds = math.floor(seconds)
   local s = seconds % 60
   seconds = (seconds - s) / 60
   local m = seconds % 60

   return string.format(fmt, m, s)
end

--Draws the time left on the HUD.
local function DrawTimeLeft()
   roundTime = GetGlobalInt("RoundTime")
   index = GetGlobalInt("Gamestate")
   gameState = GAME_STATES[index] or GAME_STATES.WaitingForPlayers
   local x = (ScrW()/2)
   local y = 10
   local text
   
   if gameState == GAME_STATES.WaitingForPlayers then
      text = "Waiting For Players: " .. player.GetCount() .. "/12"
   else
      text = SimpleTime(roundTime, gameState.Name .. ": %02i:%02i")
   end

   draw.SimpleText(text, "Trebuchet24", x, y, color_white, TEXT_ALIGN_CENTER)
end

--Draws the text with a drop shadow.
local function ShadowedText(text, font, x, y, color, xalign, yalign)
   draw.SimpleText(text, font, x+2, y+2, Color(0, 0, 0), xalign, yalign)
   draw.SimpleText(text, font, x, y, color, xalign, yalign)
end

--Gives player relevant info on their HUD.
local function DrawPlayerHUD()
   --We drew the HUD?
   if frame != nil then return end

   --Player isn't valid?
   if !IsValid(ply) then return end

   local class = player_manager.GetPlayerClass(ply)
   if class == nil then return end

   local plyClass = baseclass.Get(class)
   if plyClass == nil then return end

   local plyTeam = ply:Team()

   --Player doesn't have a team yet?
   if plyTeam != TEAMS.TOWN and plyTeam != TEAMS.MAFIA then return end

   frame = vgui.Create("DPanel")
   frame:SetSize(350, 250)
   frame:SetPos(30, 20)
   frame:SetBackgroundColor(Color(53, 53, 53, 200))

   richtext = vgui.Create("RichText", frame)
   richtext:SetVerticalScrollbarEnabled(false)
   richtext:Dock(FILL)

   --This is how we set the font.
   function richtext:PerformLayout()
      self:SetFontInternal("RoleInfo")
   end
   
   richtext:InsertColorChange(192, 192, 192, 255)

   richtext:AppendText("Your role is ")

   richtext:InsertColorChange(255, 255, 224, 255)
   richtext:AppendText(plyClass.DisplayName .. "\n")

   richtext:InsertColorChange(192, 192, 192, 255)
   richtext:AppendText(plyClass.Description .. "\n")

   local teamColor = team.GetColor(plyTeam)

   richtext:AppendText("You are sided with ")
   richtext:InsertColorChange(teamColor["r"], teamColor["g"], teamColor["b"], teamColor["a"])
   richtext:AppendText(team.GetName(plyTeam))
end

--Called when we spawn. We remove the HUD so we can redraw it.
local function ClientSpawned()
   --No HUD yet?
   if frame == nil then return end

   frame:Remove()
   frame = nil
end
net.Receive("ClientSpawn", ClientSpawned)

--Called after all the entites are initialized.
function GM:InitPostEntity()
   ply = LocalPlayer()

   --Player isn't valid?
   if !IsValid(ply) then
      print("ply is not valid yet. hmm...")
   end

   ply:ChatPrint("Welcome to Crime Time! If you're new, press F1.")

   hook.Add("HUDPaint", "TimeLeft", DrawTimeLeft)
   hook.Add("HUDPaint", "PlayerHUD", DrawPlayerHUD)
end

--Draws the target ID when you look at a player.
function GM:HUDDrawTargetID()
	local tr = util.GetPlayerTrace( LocalPlayer() )
	local trace = util.TraceLine( tr )
	if ( !trace.Hit ) then return end
	if ( !trace.HitNonWorld ) then return end
	
	local text = "ERROR"
	local font = "TargetID"
	
	if ( trace.Entity:IsPlayer() ) then
		text = trace.Entity:Nick()
	else
		return
	end
	
	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )
	
	local MouseX, MouseY = gui.MousePos()
	
	if ( MouseX == 0 && MouseY == 0 ) then
	
		MouseX = ScrW() / 2
		MouseY = ScrH() / 2
	
	end
	
	local x = MouseX
	local y = MouseY
	
	x = x - w / 2
	y = y + 30
	
	-- The fonts internal drop shadow looks lousy with AA on
	draw.SimpleText( text, font, x + 1, y + 1, Color( 0, 0, 0, 120 ) )
	draw.SimpleText( text, font, x + 2, y + 2, Color( 0, 0, 0, 50 ) )
	draw.SimpleText( text, font, x, y, Color(255, 255, 224, 255) )
	
	y = y + h + 5
	
	local text = math.floor(100 * trace.Entity:Health()/trace.Entity:GetMaxHealth()) .. "%"
	local font = "TargetIDSmall"
	
	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )
	local x = MouseX - w / 2
	
	draw.SimpleText( text, font, x + 1, y + 1, Color( 0, 0, 0, 120 ) )
	draw.SimpleText( text, font, x + 2, y + 2, Color( 0, 0, 0, 50 ) )
	draw.SimpleText( text, font, x, y, Color(255, 255, 224, 255) )
end

--Handles printing a player's chat message.
function GM:OnPlayerChat( player, strText, bTeamOnly, bPlayerIsDead )
	local tab = {}

   --Player is dead? Dead players can't chat.
   if bPlayerIsDead then return true end
   
   local validPlayer = IsValid(player)
   local playerTeam = player:Team()

   --Spectator? They can't chat either.
   if playerTeam < 0 then return true end

   --Is it night time?
   if gameState == GAME_STATES.NightTime and validPlayer then
      --Player is town?
      if playerTeam == TEAMS.TOWN then
         player:ChatPrint("Only the mafia can talk at night.")
         return true
      else
         bTeamOnly = true
      end
   end

   --Team only chat?
   if bTeamOnly and validPlayer then
      --Player is town?
      if playerTeam == TEAMS.TOWN then
         player:ChatPrint("Only the mafia can team chat.")
         return true
      else
		   table.insert( tab, Color( 255, 0, 0 ) )
         table.insert( tab, "(MAFIA) " )
      end
	end

   --Player is valid?
   if validPlayer then
      table.insert( tab, Color( 255, 255, 224, 255))
      table.insert( tab, player:Nick() )
	else
		table.insert( tab, "Console" )
	end

	table.insert( tab, Color( 255, 255, 255 ) )
	table.insert( tab, ": " .. strText )

	chat.AddText( unpack(tab) )

	return true

end

--Adds a death notice.
function GM:AddDeathNotice()
   --We don't add death notices. We don't want players to know who killed who.
end

--Draws a death notice.
function GM:DrawDeathNotice()
   --We don't draw death notices. We don't want players to know who killed who.
end
