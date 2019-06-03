--Client includes

include("shared.lua")

--Fonts

surface.CreateFont("RoleInfo", {font = "Verdana",
                                    size = 20,
                                    weight = 1000})

--InitPostEntity: Called after all the entites are initialized.
function GM:InitPostEntity()
   --Draw the player HUD for the first time once they are initialized.

   DrawPlayerHUD()

   hook.Add("HUDPaint", "TimeLeft", DrawTimeLeft)

   --Redraw the HUD every time the player spawns, since they will have a new class
   --and team.

   gameevent.Listen("player_spawn")
   hook.Add("player_spawn", "DrawPlayerHUD", function(data) DrawPlayerHUD()
   end)
end

--DrawPlayerHUD: Gives player relevant info on their HUD.
function DrawPlayerHUD()
   local ply = LocalPlayer()
   local plyClass = baseclass.Get(player_manager.GetPlayerClass(ply))

   local frame = vgui.Create("DFrame")
   frame:SetSize(350, 250)
   frame:SetPos(30, 20)

   richtext = vgui.Create("RichText", frame)
   richtext:Dock(FILL)

   --This is how we set the font.
   function richtext:PerformLayout()
      self:SetFontInternal("RoleInfo")
   end
   
   richtext:InsertColorChange(192, 192, 192, 255)

   --Player isn't valid? We can't get their info.

   if !IsValid(ply) then
      richtext:AppendText("An error occurred while getting your role. Try respawning.")
      return
   end

   richtext:AppendText("Your role is ")

   richtext:InsertColorChange(255, 255, 224, 255)
   richtext:AppendText(plyClass.DisplayName .. "\n")

   richtext:InsertColorChange(192, 192, 192, 255)
   richtext:AppendText("Your role is described here. \n")
   
   local plyTeam = ply:Team()

   --Player doesn't have a team yet?
   
   if plyTeam == 0 then
      richtext:AppendText("An error occurred getting your team.")
      return
   end

   local teamColor = team.GetColor(plyTeam)

   richtext:AppendText("You are sided with ")
   richtext:InsertColorChange(teamColor["r"], teamColor["g"], teamColor["b"], teamColor["a"])
   richtext:AppendText(team.GetName(plyTeam))
end

--DrawTimeLeft: Draws the time left on the HUD.
function DrawTimeLeft()
   local roundTime = GetGlobalInt("roundTime")
   local x = ScrW() / 2
   local y = 10
   local text = SimpleTime(roundTime, "Voting Phase: %02i:%02i")

   ShadowedText(text, "Trebuchet24", x, y, Color(255, 255, 255), TEXT_ALIGN_CENTER)
end

--ShadowedText: Draws the text with a drop shadow.
function ShadowedText(text, font, x, y, color, xalign, yalign)
   draw.SimpleText(text, font, x+2, y+2, Color(0, 0, 0), xalign, yalign)
   draw.SimpleText(text, font, x, y, color, xalign, yalign)
end

--SimpleTime: Converts seconds to a format with minutes and seconds.
function SimpleTime(seconds, fmt)
   --Seconds wasn't given?

	if not seconds then seconds = 0 end

   seconds = math.floor(seconds)
   local s = seconds % 60
   seconds = (seconds - s) / 60
   local m = seconds % 60

   return string.format(fmt, m, s)
end

--HUDDrawTargetID: Draws the target ID when you look at a player.
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
		--text = trace.Entity:GetClass()
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
	
	local text = trace.Entity:Health() .. "%"
	local font = "TargetIDSmall"
	
	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )
	local x = MouseX - w / 2
	
	draw.SimpleText( text, font, x + 1, y + 1, Color( 0, 0, 0, 120 ) )
	draw.SimpleText( text, font, x + 2, y + 2, Color( 0, 0, 0, 50 ) )
	draw.SimpleText( text, font, x, y, Color(255, 255, 224, 255) )
end

--OnPlayerChat: Handles printing a player's chat message.
function GM:OnPlayerChat( player, strText, bTeamOnly, bPlayerIsDead )
	local tab = {}

	if ( bPlayerIsDead ) then
		table.insert( tab, Color( 255, 30, 40 ) )
		table.insert( tab, "*DEAD* " )
	end

	if ( bTeamOnly ) then
		table.insert( tab, Color( 30, 160, 40 ) )
		table.insert( tab, "(TEAM) " )
	end

   if ( IsValid( player ) ) then
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

