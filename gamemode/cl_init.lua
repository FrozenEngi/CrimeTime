--Client includes

include("shared.lua")

--Fonts

surface.CreateFont("RoleInfo", {font = "Verdana",
                                    size = 20,
                                    weight = 1000})

--InitPostEntity: Called when the client connects
function GM:InitPostEntity()
   local ply = LocalPlayer()

   local frame = vgui.Create("DFrame")
   frame:SetSize(350, 250)
   frame:SetPos(30, 20)

   richtext = vgui.Create("RichText", frame)
   richtext:Dock(FILL)
   
   richtext:InsertColorChange(192, 192, 192, 255)
   richtext:AppendText("Your role is ")

   richtext:InsertColorChange(255, 255, 224, 255)

   --Player is valid? Print their class.

   if IsValid(ply) then
      local plyClass = baseclass.Get(player_manager.GetPlayerClass(ply))
      richtext:AppendText(plyClass.DisplayName .. "\n")
   end

   richtext:InsertColorChange(192, 192, 192, 255)
   richtext:AppendText("Your role is described here. \n")
   
   local plyTeam = ply:Team()

   --Player doesn't have a team yet?
   
   if plyTeam == 0 then return end

   local teamColor = team.GetColor(plyTeam)

   richtext:AppendText("You are sided with ")
   richtext:InsertColorChange(teamColor["r"], teamColor["g"], teamColor["b"], teamColor["a"])
   richtext:AppendText(team.GetName(plyTeam))

   --This is how we set the font.
   function richtext:PerformLayout()
      self:SetFontInternal("RoleInfo")
   end
   
   hook.Add("HUDPaint", "TimeLeft", DrawTimeLeft)
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

