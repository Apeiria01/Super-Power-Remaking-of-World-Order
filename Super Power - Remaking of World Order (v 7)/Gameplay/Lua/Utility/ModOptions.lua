if PreGame.GetGameOption("GAMEOPTION_SP_CORPS_MODE_DISABLE") == 0
or PreGame.GetGameOption("GAMEOPTION_SP_RECORD_MODE") == 1
then
	Controls.SP_Option_BTN_EmergencyRest:SetHide( true );
end

Controls.SP_Option_BTN_EmergencyRest:RegisterCallback(Mouse.eLClick, function() 
	
	for playerID,player in pairs(Players) do

		if player and player:IsAlive() and not player:IsHuman() then
			for unit in player:Units() do
				if unit ~= nil and not unit:IsTrade() then
					local unitType = unit:GetUnitType()
					local unitEXP = unit:GetExperience()
					local unitAIType = unit:GetUnitAIType()
					local unitX = unit:GetX()
					local unitY = unit:GetY()
					unit:Kill()
					print ("old unit removed!")
					local NewUnit = player:InitUnit(unitType, unitX, unitY, unitAIType)
					NewUnit:JumpToNearestValidPlot()
					NewUnit:SetExperience(unitEXP)
					print ("new unit replaced!")
				end
			end	
		end		
	end
	
	print("Emergency! AI fucked up and player reset it!")
end);