include("cl_voting.lua")

-- Key overrides for CrimeTime specific keyboard functions

--Called when a bound key is pressed. Doesn't work for F1-F12.
function GM:PlayerBindPress(ply, bind, pressed)
   --Player isn't valid?
   if not IsValid(ply) then return end

   --Player pressed the binding for showing the scoreboard?
   if bind == "+showscores" and pressed then
      OpenVotingPanel()
      return true
   end
end

--Called when the player presses an IN key.
function GM:KeyPress(ply, key)
--EXAMPLE
   --[[if not IsFirstTimePredicted() then return end
   if not IsValid(ply) or ply != LocalPlayer() then return end

   if key == IN_ATTACK and ply:Alive() == false then return end--]]
   --[[if key == IN_SPEED and ply:IsActiveTraitor() then
      timer.Simple(0.05, function() RunConsoleCommand("+voicerecord") end)
   end --]]
end

--Called when the player releases an IN key.
function GM:KeyRelease(ply, key)
end

--Called when the player releases any key.
function GM:PlayerButtonUp(ply, btn)
   -- Not the first call?
   if not IsFirstTimePredicted() then return end

   --The F1 key was pressed? Open up the help page.
   if btn == KEY_F1 then
      local help = vgui.Create("DFrame")
      help:SetSize(500, 320)
      help:SetPos((ScrW()/2) - 250, 80)
      help:SetTitle("Help Page")
      help:SetContentAlignment(8)
      help:MakePopup()

      local helptext = vgui.Create("DHTML", help)
      helptext:Dock(FILL)
      helptext:SetHTML("<h1 style=\"text-align:center;\"><font color=\"white\">CrimeTime</font></h1>" ..
         "<p style=\"text-align:center;\"><font color=\"white\">This is a battle of deception between the Town" ..
         " and the Mafia. One side wins when the other is wiped out. Each" ..
         " player also has a role which gives them extra abilities. During" ..
         " the voting phase, there is a vote to see who will be hanged. At" ..
         " night, only the mafia can talk (amongst themselves). Everyone gets" ..
         " a gun, but the mafia are harder to take down." ..
         " Trust no one.<br><br>" ..
         "Hotkeys:<br>F1: Help page<br>TAB: Voting panel</font></p>")
   end
end
