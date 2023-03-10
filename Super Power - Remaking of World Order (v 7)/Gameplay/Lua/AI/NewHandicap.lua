-- New Handicap


--include( "UtilityFunctions.lua" )





---------------------------------------------Help AI to catch up with human----------------------------------------------------
-----------Research Check
function CheckHumanResearch(iTeam)
	if iTeam == nil then 
		return
	end
	
	if Game:GetHandicapType() < 3 then
		print ("Human beings are not as clever as AI in Research, AI should take care of human beings.")
		return
	end
	
	local pTeam = Teams[iTeam]
	if not pTeam:IsHuman() then
	 	return
	end
		
	local player = Players[Game.GetActivePlayer()]
	if player ~= nil and player:IsHuman() then
		local HumanResearchPerTurn = player:GetScience()
		local HumanCurrentEra = player:GetCurrentEra()
		if HumanCurrentEra >= 4 and HumanResearchPerTurn > 0 then
			for playerID,AIplayer in pairs(Players) do
				if AIplayer ~= nil and AIplayer:GetNumCities() >= 1 and not AIplayer:IsMinorCiv() and not AIplayer:IsBarbarian() and not AIplayer:IsHuman() then
					AIResearchCatchUp(HumanResearchPerTurn,HumanCurrentEra,AIplayer) 
				end
			end
		end
	end
end
GameEvents.TeamSetHasTech.Add(CheckHumanResearch)


-----------Economy Check
function CheckHumanEconomy(playerID)
	if playerID == nil then
		return
	end
	if Game:GetHandicapType() < 3 then
		print ("Human beings are not as clever as AI in Economy, AI should take care of human beings.")
		return
	end
	
	local player = Players[playerID]
	if player:IsHuman() then
		local HumanCityCount = player:GetNumCities()
	    local HumanPopCount = player:GetTotalPopulation()	
		if HumanCityCount > 2 and HumanPopCount > 6 then
			for playerID,AIplayer in pairs(Players) do		
				if AIplayer ~= nil and AIplayer:GetNumCities() >= 1 and not AIplayer:IsMinorCiv() and not AIplayer:IsBarbarian()
				and not AIplayer:IsHuman() then
					AIEconomyCatchUp(HumanCityCount,HumanPopCount,AIplayer) 
				end
			end
		end
   	end
end
GameEvents.PlayerAdoptPolicy.Add(CheckHumanEconomy)



-----------Military Check
function CheckHumanMilitary( iTeam1, iTeam2, bWar )
	if iTeam1 == nil or iTeam2 == nil then 
		return
	end
	if Game:GetHandicapType() < 3 then
		print ("Human beings are not as clever as AI in Military, AI should take care of human beings.")
		return
	end
	
	local pTeam1 = Teams[iTeam1]
	local pTeam2 = Teams[iTeam2]

	if not pTeam1:IsHuman() and not pTeam2:IsHuman() then
	 	return
	end
	
	local player = Players[Game.GetActivePlayer()]
	if player ~= nil and player:IsHuman() then
		local iNumCapitals = 0
		for pCity in player:Cities() do
			if pCity:IsOriginalCapital() then						
				iNumCapitals = iNumCapitals + 1
			end	
		end
		print ("Human Player owns Capitals:"..iNumCapitals)
		if iNumCapitals >= 1 then
			for playerID,AIplayer in pairs(Players) do		
				if AIplayer ~= nil and AIplayer:GetNumCities() >= 1 and not AIplayer:IsMinorCiv() and not AIplayer:IsBarbarian()
				and not AIplayer:IsHuman() then
					AIMilitaryCatchUp(iNumCapitals,AIplayer) 
				end
			end
		end
	end
end
Events.WarStateChanged.Add(CheckHumanMilitary)


-----------Score Check

--[[
function CheckHumanScore(playerID)
	if playerID == nil then
		return
	end
	
	local iTurnTrigger = 10
	local iTurnsElapsed = Game.GetElapsedGameTurns()
	if iTurnsElapsed % iTurnTrigger ~= 0 then
		print ("Check Human Score every 10 turns!")
		return
	end
	
	local player = Players[playerID]
	if player:IsHuman() then
		local HumanScore = player:GetScore()
		if HumanScore > 0 then
			local TotalScore = HumanScore
			local TotalMajCiv = 1
			
			for playerID,AIplayer in pairs(Players) do		
				if AIplayer ~= nil and AIplayer:GetNumCities() >= 1 and not AIplayer:IsMinorCiv() and not AIplayer:IsBarbarian() and not AIplayer:IsHuman() then
				
					local AIName = AIplayer:GetName()
					local AIScore = AIplayer:GetScore()
					TotalScore = TotalScore + AIScore
					TotalMajCiv = TotalMajCiv + 1
					if AIScore > HumanScore / 0.75 or AICanBeBoss (AIplayer) then
						AIBossBonus(HumanScore,TotalScore,TotalMajCiv,AIplayer) 
					end
					
				end
			end
			
		end
	end


end
GameEvents.PlayerDoTurn.Add(CheckHumanScore)--]]

function CheckHumanScore(playerID)
	
	if playerID ~= Game.GetActivePlayer() then
		return;
	end
	if Game:GetHandicapType() < 3 then
		print ("Human beings are not as clever as AI in Score, AI should take care of human beings.")
		return
	end
	
	local iTurnTrigger = 10;
	local iTurnsElapsed = Game.GetElapsedGameTurns();
	if iTurnsElapsed % iTurnTrigger ~= 0 then
		print ("Check Human Score every 10 turns!");
		return;
	end
	
	local HumanPlayer = Players[Game.GetActivePlayer()]
	if HumanPlayer:IsHuman() then
		local HumanScore = HumanPlayer:GetScore()
		if HumanScore > 0 then
			local TotalScore = 0;
			local TotalMajCiv = 0;
			for iPlayerID = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
				if Players[iPlayerID] and Players[iPlayerID]:GetNumCities() > 0 then
					TotalScore = TotalScore + Players[iPlayerID]:GetScore();
					TotalMajCiv = TotalMajCiv + 1;
				end
			end
	
			if HumanScore > 0 and TotalScore > HumanScore and TotalMajCiv > 1 then
				for _, AIplayer in pairs(Players) do
					if  AIplayer ~= nil and not AIplayer:IsHuman() and not AIplayer:IsMinorCiv() and not AIplayer:IsBarbarian()
					and AIplayer:GetNumCities() > 0 and (AIplayer:GetScore() > HumanScore / 0.75 or AICanBeBoss(AIplayer))
					then
						AIBossBonus(HumanScore,TotalScore,TotalMajCiv, AIplayer);
					end
				end
			end
		end
	end
end
GameEvents.PlayerDoTurn.Add(CheckHumanScore)





------------------------------------------------------------AI bonus entering new era------------------------------------------------

function PlayerIntoNewEra(era, playerID) -- AI will get bonus when Human Player entering new Eras
	local handicap = Game:GetHandicapType();
	local player = Players[playerID];
	if player == nil then
		print ("No players")
		return;
	end

--	print("handicap="..Game:GetHandicapType())
--	print("Player Era="..era)
	
	-- Minor Civs get bouns after industrial era
	if player:IsMinorCiv() and player:GetCapitalCity() and era >= 4 then
		local CaptialCity = player:GetCapitalCity()
		CaptialCity:SetNumRealBuilding(GameInfoTypes["BUILDING_GRAIN_DEPOT"],1)
		CaptialCity:SetNumRealBuilding(GameInfoTypes["BUILDING_MECHANIZED_FARM"],1)
		CaptialCity:SetNumRealBuilding(GameInfoTypes["BUILDING_TAP_WATER_SUPPLY"],1)
		CaptialCity:SetNumRealBuilding(GameInfoTypes["BUILDING_HOSPITAL"],1)
		CaptialCity:SetNumRealBuilding(GameInfoTypes["BUILDING_LIBRARY"],1)
		CaptialCity:SetNumRealBuilding(GameInfoTypes["BUILDING_PUBLIC_SCHOOL"],1)
		print("Minor civ get post-industrial bonus!")
	end
	
	if player:IsBarbarian() then
		return;
	end
	
	-- Only effective when the difficulty from LV3 up
	if playerID == Game.GetActivePlayer() and handicap > 3 then
		-- Force AI to build improvemnts on resources since they always forget
		ImproveTiles(false);	-- player:IsHuman()
		for AIPlayerID, AIPlayer in pairs(Players) do
			if AIPlayer == nil or not AIPlayer:IsAlive() or AIPlayer:IsMinorCiv() or AIPlayer:IsBarbarian() or AIPlayer:IsHuman() then
			else
				-- AI will get bouns when Active Player entering new Eras
				if (era >= 1 and not AIPlayer:HasPolicy(GameInfo.Policies["POLICY_AI_CLASSICAL"].ID)) then
					AIPlayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_CLASSICAL"].ID,true)
					print ("AI Bonus!-CLASSICAL")
				end
				if (era >= 2 and not AIPlayer:HasPolicy(GameInfo.Policies["POLICY_AI_MEDIEVAL"].ID)) then
					AIPlayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_MEDIEVAL"].ID,true)
					print ("AI Bonus!-MEDIEVAL")
				end
				if (era >= 3 and not AIPlayer:HasPolicy(GameInfo.Policies["POLICY_AI_RENAISSANCE"].ID)) then
					AIPlayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_RENAISSANCE"].ID,true)
					print ("AI Bonus!-RENAISSANCE")
				end
				if (era >= 4 and not AIPlayer:HasPolicy(GameInfo.Policies["POLICY_AI_INDUSTRY"].ID)) then
					AIPlayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_INDUSTRY"].ID,true)
	--  				AIMapVisibility (AIPlayer)
					print ("AI Bonus!-INDUSTRY")
				end
				if (era >= 5 and not AIPlayer:HasPolicy(GameInfo.Policies["POLICY_AI_MODERN"].ID)) then
					AIPlayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_MODERN"].ID,true)
					print ("AI Bonus!-MODERN")
				end
				if (era >= 6 and not AIPlayer:HasPolicy(GameInfo.Policies["POLICY_AI_WORLDWAR"].ID)) then
					AIPlayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_WORLDWAR"].ID,true)
					print ("AI Bonus!-WORLDWAR")
				end
				if (era >= 7 and not AIPlayer:HasPolicy(GameInfo.Policies["POLICY_AI_ATOMIC"].ID)) then
					AIPlayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_ATOMIC"].ID,true)
					print ("AI Bonus!-ATOMIC")
				end
			end
		end
		print("Active Player Enter New Era: ".. era)
	end
end
Events.SerialEventEraChanged.Add(PlayerIntoNewEra)



----------------------------------------- ------------------Give AI Map visibility so their units won't wander around---Cost too much system resource so canceled		------------------------------------------------
--function AIMapVisibility (player)
--   local AITeamID = player:GetTeam()
--   print ("AI Map Visibility!")
--  	  
--   for i = 0, Map.GetNumPlots()-1, 1 do
--		local plot = Map.GetPlotByIndex(i);
--		plot:ChangeVisibilityCount(AITeamID, 10, -1, true, false);
--		plot:SetRevealed(AITeamID, true);
--		plot:UpdateFog();
--		plot:UpdateVisibility();
--		Game.UpdateFOW(true);
--	end
--end
--



------------------------------------------------------------ AI will annex the city to recover quikly------------------------------------------------
function AIAutoAnnexCity(hexX, hexY, population, citySize)
	if hexX == nil or hexY ==nil then
		print ("No Plot")
		return
	end	

	local plot = Map.GetPlot(ToGridFromHex(hexX, hexY))
	local city = plot:GetPlotCity();
	
	if city == nil then
		print ("No cities")
		return
	end
	
	local player = Players[city:GetOwner()]

	if player == nil then
		print ("No players")
		return
	end
		
		
	if player:IsHuman() or player:IsMinorCiv()or player:IsBarbarian() or player:GetNumCities() < 1 or player:MayNotAnnex() then
		return;
	end

	if city:IsCapital() then ---------AI check resource condition
		AICheckResource(player)
	end
	
	if city:IsResistance() and city:GetResistanceTurns() > 5 then
		city:ChangeResistanceTurns(-1)
	end
	if city:IsPuppet() then
		if city:GetPopulation() > 10 and not city:IsResistance() then
			city:SetPuppet(false)
			city:SetOccupied(true)
--			city:DoAnnex()
			print("AI Annexes City!")
		end
	end
end
Events.SerialEventCityPopulationChanged.Add(AIAutoAnnexCity)



-------------------------------------AI Units Assistance help AI to get required Promotions ----------------------------------------------------

function AIUnitsAssist(playerID)
    local player = Players[playerID]
    
    	if player == nil then
			print ("No players")
			return
		end
		
    	if player:IsMinorCiv() or player:IsBarbarian() or player:IsHuman() then
   		 	return 
    	end
  
		if player:IsHasLostCapital() then
			print ("This AI is fucked up! No bonus for it!")
   		 	return 
    	end
    
	
	local CarrierID = GameInfo.UnitPromotions["PROMOTION_CARRIER_UNIT"].ID
	local SPForceID = GameInfo.UnitPromotions["PROMOTION_SPECIAL_FORCES_COMBAT"].ID
	local StgBomberID = GameInfo.UnitPromotions["PROMOTION_STRATEGIC_BOMBER"].ID
	
--	local CarrierAircraftID = GameInfo.UnitPromotions["PROMOTION_CARRIER_FIGHTER"].ID	
--	local CarrierAirFight1ID = GameInfo.UnitPromotions["PROMOTION_CARRIER_FIGHTER_AIRFIGHT_1"].ID
--	local CarrierAirFight2ID = GameInfo.UnitPromotions["PROMOTION_CARRIER_FIGHTER_AIRFIGHT_2"].ID
--	local CarrierAirAttack1ID = GameInfo.UnitPromotions["PROMOTION_CARRIER_FIGHTER_ATTACK_1"].ID
--	local CarrierAirAttack2ID = GameInfo.UnitPromotions["PROMOTION_CARRIER_FIGHTER_ATTACK_2"].ID
--	local CarrierAirSiege1ID = GameInfo.UnitPromotions["PROMOTION_CARRIER_FIGHTER_SIEGE_1"].ID	
--	local CarrierAirSiege2ID = GameInfo.UnitPromotions["PROMOTION_CARRIER_FIGHTER_SIEGE_2"].ID	
	
	local AICityCount = player:GetNumCities()
		
	if AICityCount > 1 then
	
	
		for unit in player:Units() do
		
		
	------------------------AI Force Upgrade Units
			if unit:CanUpgradeRightNow() then
				unit:DoCommand(CommandTypes["COMMAND_UPGRADE"])
				print ("AI Unit upgraded!")
			end	
		
	----------------------AI remove distant Obselete units
			
			if unit:GetUnitClassType() == GameInfo.UnitClasses.UNITCLASS_CARAVEL.ID
			or unit:GetUnitClassType() == GameInfo.UnitClasses.UNITCLASS_SCOUT.ID
			or unit:GetUnitClassType() == GameInfo.UnitClasses.UNITCLASS_EXPLORERX.ID
			or unit:GetUnitClassType() == GameInfo.UnitClasses.UNITCLASS_MISSIONARY.ID
			or unit:GetUnitClassType() == GameInfo.UnitClasses.UNITCLASS_INQUISITOR.ID
			or unit:GetUnitClassType() == GameInfo.UnitClasses.UNITCLASS_PROPHET.ID
			or unit:GetUnitClassType() == GameInfo.UnitClasses.UNITCLASS_SCOUT.ID
			or unit:GetUnitClassType() == GameInfo.UnitClasses.UNITCLASS_SLOOP_OF_WAR.ID
			or unit:GetUnitClassType() == GameInfo.UnitClasses.UNITCLASS_FIRE_SHIP.ID then
			 	if player:GetCurrentEra() >= 6 then
			   		unit:Kill()	
			  		print ("AI Obselete units outside removed!")
				end			
			end
		
		
	----------------------AI air attack human cities	
			if unit:IsHasPromotion(SPForceID) or unit:IsHasPromotion(StgBomberID) then
				if PlayerAtWarWithHuman(player) then
					for playerID,Humanplayer in pairs(Players) do
						if Humanplayer:IsHuman() then
						
							-------------Pick up random human city to attack
							local TargetCities = {}
							local TargetCityCounter = 0
							for pCity in Humanplayer:Cities() do
								local cityPop = pCity:GetPopulation()
								if cityPop > 15 then
									TargetCities[TargetCityCounter] = pCity
									TargetCityCounter = TargetCityCounter + 1
								end		
							end	
							if (TargetCityCounter > 0) then
								local iRandChoice = Game.Rand(TargetCityCounter, "Choosing random city")
								local targetCity = TargetCities[iRandChoice]
								local plot = targetCity
								local plotX = plot:GetX()
								local plotY = plot:GetY()
								local unitPlot = unit:GetPlot()
								
								-----------------Paradrop!
								if unit:GetDomainType() == DomainTypes.DOMAIN_LAND and unit:CanParadropAt(unitPlot, plotX+1, plotY) then
								   if targetCity:IsCapital() or targetCity:GetPopulation() > 50 then
									  unit:SetXY (plotX+1, plotY)
									  unit:JumpToNearestValidPlot()
									  unit:SetMadeAttack (true)
									  print ("AI paradrop at human's city!")
								   end
								end
								
								if unit:GetDomainType() == DomainTypes.DOMAIN_AIR and unit:CanRangeStrikeAt(plotX,plotY) then

   									local unitCount = plot:GetNumUnits()
									if unitCount <= 2 then---------Attack only when no patrol in the city!
									   unit:RangeStrike(plotX, plotY)
									   unit:SetMadeAttack (true)
									   print ("AI bomber attacks human's city!")
									end
								end
								
								
							end	
							
							
						end
					end
				
				end
			end
			
			-- Add Escort Ships for AI carriers!
			if GameInfo.Units[unit:GetUnitType()].SpecialCargo == "SPECIALUNIT_FIGHTER" and not unit:IsFriendlyUnitAdjacent(true) then
				local plot = unit:GetPlot()
				if plot and not plot:IsCity() and not PlotIsVisibleToHuman(plot) then
					AIForceBuildNavalEscortUnits (plot:GetX(), plot:GetY(), player)
					AIForceBuildNavalHRUnits (plot:GetX(), plot:GetY(), player)
					AIForceBuildNavalRangedUnits (plot:GetX(), plot:GetY(), player)
					print ("Create escort ships for AI carriers!")
				end
			end
		end
	end
end
GameEvents.PlayerDoTurn.Add(AIUnitsAssist)



------------------------------------------------------------ Remove AI Resources Bonus when it is losing / Enhance AI when lose its city to human------------------------------------------------

function AICityCaptured(oldPlayerID, iCapital, iX, iY, newPlayerID, bConquest, iGreatWorksPresent, iGreatWorksXferred)
	if Players[newPlayerID] == nil or Players[oldPlayerID] == nil or Map.GetPlot(iX, iY) == nil or not Map.GetPlot(iX, iY):IsCity() then
		return;
	end
	local NewPlayer = Players[newPlayerID]
	local OldPlayer = Players[oldPlayerID]
	local pCity = Map.GetPlot(iX, iY):GetPlotCity()
 	local CityOriginalOwner = Players[pCity:GetOriginalOwner()]
	
	if Game.GetHandicapType() < 4 then
		print ("Human beings are not as clever as AI in City Captured, AI should take care of human beings.")
		return
	end

	if OldPlayer:GetNumCities() <= 1 then
		print ("AI no city left!")-------In case of "complete kill" selected will crash the game 
		return
	end

--	if AICanBeBoss (OldPlayer) then
--		print ("Not effective with Boss!")
--		return
--	end

	local NumMaxUnits = (OldPlayer:GetNumCities())*25
	if NumMaxUnits > 1000 then
		NumMaxUnits = 1000
	end

	---------- help AI defend their land when human is pushing!!!!!!
	if pCity:GetPopulation() > 2 and PlayerAtWarWithHuman(OldPlayer) and NewPlayer:IsHuman() and not OldPlayer:IsHuman()
	and not OldPlayer:IsCapitalCapturedBy(newPlayerID) and OldPlayer:GetNumUnits() < NumMaxUnits then
		print ("AI lost a city to human!")
		
		
		if OldPlayer == CityOriginalOwner and OldPlayer:GetNumUnits() < NewPlayer:GetNumUnits()* 1.2 then
			print ("AI run out of its units and is losing cities! We need everyone in battle!")
		
			for city in OldPlayer:Cities() do
				local plot = city
				local unitX = plot:GetX()
				local unitY = plot:GetY()
				if not PlotIsVisibleToHuman(plot) then
					if city:GetPopulation() >= 6 or city:IsCapital() then
						AICheckResource(OldPlayer)
						AIConscriptMilitiaUnits(unitX, unitY, OldPlayer) 
						AIConscriptMilitiaUnits(unitX, unitY, OldPlayer)
						AIForceBuildLandCounterUnits(unitX, unitY, OldPlayer)
						if AICanBeBoss(OldPlayer) then
							AICheckResource(OldPlayer)
							AIForceBuildInfantryUnits(unitX, unitY, OldPlayer)
							AIForceBuildLandCounterUnits(unitX, unitY, OldPlayer)
							AIForceBuildInfantryUnits(unitX, unitY, OldPlayer)
							print ("AI Boss is not easy to yield!")
							if OldPlayer:GetCurrentEra() >= 5 then
								AIForceBuildAirEscortUnits(unitX, unitY, OldPlayer)
							end
						end
						
						if city:IsCoastal(GameDefines["MIN_WATER_SIZE_FOR_OCEAN"]) then
							AIConscriptMilitiaNavy(unitX, unitY, OldPlayer) 
							AIConscriptMilitiaNavy(unitX, unitY, OldPlayer) 
--							AIConscriptMilitiaNavy(unitX, unitY, OldPlayer) 
							if AICanBeBoss(OldPlayer) then
								AICheckResource(OldPlayer)
								AIForceBuildNavalEscortUnits(unitX, unitY, OldPlayer)
								AIForceBuildNavalHRUnits(unitX, unitY, OldPlayer)	
								print ("AI Boss is not easy to yield!")
							end
						end 
					
					end
				end
			end
		end	
	end






	if not OldPlayer:IsHuman() and not NewPlayer:IsHuman() then
	
		if OldPlayer == CityOriginalOwner then
			

--			print ("Defeated AI Remove Resources Bonus so it can die faster and save system's resource!")
--			local ConsumerNum = OldPlayer:GetNumResourceAvailable(GameInfoTypes["RESOURCE_CONSUMER"],true)
--			local ElectricityNum = OldPlayer:GetNumResourceAvailable(GameInfoTypes["RESOURCE_ELECTRICITY"],true)
--			local ManPowerNum = OldPlayer:GetNumResourceAvailable(GameInfoTypes["RESOURCE_MANPOWER"],true)
			
--[[			if not AICanBeBoss(OldPlayer) and not NewPlayer:IsHuman() then
				if ConsumerNum > 6 then
					local ResPenalty = ConsumerNum - 6
					local ConsumerNums = math.min(8, ResPenalty)
					OldPlayer:ChangeNumResourceTotal(GameInfoTypes["RESOURCE_CONSUMER"], - ConsumerNums)					
				end	
				
				if ElectricityNum > 8 then
					local ResPenalty = ElectricityNum - 8
					local ElectricityNums = math.min(12, ResPenalty)
					OldPlayer:ChangeNumResourceTotal(GameInfoTypes["RESOURCE_ELECTRICITY"], - ElectricityNums)
				end	
				
				if ManPowerNum > 5 then
					local ResPenalty = ManPowerNum - 5
					local ManPowerNums = math.min(8, ResPenalty)
					OldPlayer:ChangeNumResourceTotal(GameInfoTypes["RESOURCE_MANPOWER"], - ManPowerNums)
				end	
			end
			
--]]			local ConsumerResID = GameInfoTypes["RESOURCE_CONSUMER"]
			local ElectricityResID = GameInfoTypes["RESOURCE_ELECTRICITY"]
			local ManPowerResID = GameInfoTypes["RESOURCE_MANPOWER"]
			if not PlayerAtWarWithHuman(OldPlayer) then 
				if OldPlayer:GetNumResourceAvailable(ConsumerResID,true) >= 15 then
					OldPlayer:ChangeNumResourceTotal(ConsumerResID, -15)
				end	
			
				if OldPlayer:GetNumResourceAvailable(ElectricityResID,true) >= 15 then
					OldPlayer:ChangeNumResourceTotal(ElectricityResID, -15)
				end	
			
				if OldPlayer:GetNumResourceAvailable(ManPowerResID,true) >= 15 then
					OldPlayer:ChangeNumResourceTotal(ManPowerResID, -15)
				end	
			else
				if OldPlayer:GetNumResourceAvailable(ConsumerResID,true) <= 5 then
					OldPlayer:ChangeNumResourceTotal(ConsumerResID, 15)
				end	
			
				if OldPlayer:GetNumResourceAvailable(ElectricityResID,true) <= 5 then
					OldPlayer:ChangeNumResourceTotal(ElectricityResID, 15)
				end	
			
				if (OldPlayer:GetNumResourceAvailable(ManPowerResID, true) + OldPlayer:GetNumResourceUsed(ManPowerResID)) <= (OldPlayer:GetCurrentEra())*100 then
					OldPlayer:ChangeNumResourceTotal(ManPowerResID, (OldPlayer:GetCurrentEra())*50)
				end	
			
			end
	
			if AICanBeBoss(NewPlayer) then
			
				AICheckResource(NewPlayer)
				
				local bNumMaxUnits = (NewPlayer:GetNumCities())*25
				if bNumMaxUnits > 1000 then
					bNumMaxUnits = 1000
				end
				
				if NewPlayer:GetNumUnits() < bNumMaxUnits then
				
					if pCity:IsCoastal(GameDefines["MIN_WATER_SIZE_FOR_OCEAN"]) then
						if NewPlayer:GetCurrentEra() >= 2 then
							AIForceBuildNavalEscortUnits(iX, iY, NewPlayer)
							AIForceBuildNavalHRUnits(iX, iY, NewPlayer)
							AIForceBuildNavalEscortUnits(iX, iY, NewPlayer)
							AIForceBuildNavalRangedUnits(iX, iY, NewPlayer)
						end
						AIForceBuildInfantryUnits(iX, iY, NewPlayer)
						AIForceBuildLandCounterUnits(iX, iY, NewPlayer)
						print ("Coastal city is captured!Offer AI boss more navy to advance!")					
					else
						AIForceBuildInfantryUnits(iX, iY, NewPlayer)
						AIForceBuildMobileUnits(iX, iY, NewPlayer)
						AIForceBuildInfantryUnits(iX, iY, NewPlayer)
						AIForceBuildInfantryUnits(iX, iY, NewPlayer)
						AIForceBuildMobileUnits(iX, iY, NewPlayer)
						AIForceBuildMobileUnits(iX, iY, NewPlayer)
						AIForceBuildLandCounterUnits(iX, iY, NewPlayer)
						print ("Inland city is captured!Offer AI boss more army to advance!")		
					end	
				end
			end	
			
			-- reddit begin by HMS -- avoid AI boss being destroyed by this function
			local OldPlayerCurrentEra = OldPlayer:GetCurrentEra()
			local OldPlayerCapital = OldPlayer:GetCapitalCity()
			local DistanceToCapital = 0;
			if CapitalOldPlayer ~= nil then
				DistanceToCapital = Map.PlotDistance(iX, iY, OldPlayerCapital:GetX(), OldPlayerCapital:GetY());
			end
			if not PlayerAtWarWithHuman(OldPlayer) and pCity:GetPopulation() >= math.max(OldPlayerCurrentEra,3) and DistanceToCapital<=16 then
				for unit in OldPlayer:Units() do
					if unit ~= nil then
						local plot = unit:GetPlot()
						if plot ~= nil then
							if not PlotIsVisibleToHuman(plot) then
								unit:Kill()
								print ("Kill Weak AI's units to let AI's war go faster!")
							end
						end
					end
				end
			end
			--reddit end by HMS
		end
	end
end
GameEvents.CityCaptureComplete.Add(AICityCaptured)







---------------------------------------------------------------------AI Force Promotion and Unitclass Balance----------------------------------------------------

function AIPromotion(iPlayer, iCity, iUnit, bGold, bFaith)
    local player = Players[iPlayer]
    
    
    	if player == nil then
			print ("No players")
			return
		end
    
      	if iUnit == nil then 
    		return 
    	end
    
    	if player:IsHuman() then ----------Only for Major AI
    		return 
    	end
    	
    	if player:IsMinorCiv() then
   		return
    	end
    	
    	if player:IsBarbarian() then
    		return 
    	end
		

    local handicap = Game:GetHandicapType()
    
--    local city = player:GetCityByID(iCity) 


	local RangedUnitID = GameInfo.UnitPromotions["PROMOTION_ARCHERY_COMBAT"].ID
	local CitySiegeID = GameInfo.UnitPromotions["PROMOTION_CITY_SIEGE"].ID
	local LandAOEUnitID = GameInfo.UnitPromotions["PROMOTION_SPLASH_DAMAGE"].ID
	
	local HitandRunID = GameInfo.UnitPromotions["PROMOTION_HITANDRUN"].ID
	local HelicopterID = GameInfo.UnitPromotions["PROMOTION_HELI_ATTACK"].ID
	
	local NavalHitandRunID = GameInfo.UnitPromotions["PROMOTION_NAVAL_HIT_AND_RUN"].ID
	local NavalRangedID = GameInfo.UnitPromotions["PROMOTION_NAVAL_RANGED_SHIP"].ID
	local SubmarineID = GameInfo.UnitPromotions["PROMOTION_SUBMARINE_COMBAT"].ID
	
	local CapitalShipID = GameInfo.UnitPromotions["PROMOTION_NAVAL_CAPITAL_SHIP"].ID
	local CarrierID = GameInfo.UnitPromotions["PROMOTION_CARRIER_UNIT"].ID
	
	local SSBNID = GameInfo.UnitPromotions["PROMOTION_CARGO_IX"].ID
	
	local BomberID = GameInfo.UnitPromotions["PROMOTION_STRATEGIC_BOMBER"].ID
	local AirAttackID = GameInfo.UnitPromotions["PROMOTION_AIR_ATTACK"].ID

	
	local CollDamageLV1ID = GameInfo.UnitPromotions["PROMOTION_COLLATERAL_DAMAGE_1"].ID
	local CollDamageLV2ID = GameInfo.UnitPromotions["PROMOTION_COLLATERAL_DAMAGE_2"].ID
	-- local CollDamageLV3ID = GameInfo.UnitPromotions["PROMOTION_COLLATERAL_DAMAGE_3"].ID
	
	local Barrage1ID = GameInfo.UnitPromotions["PROMOTION_BARRAGE_1"].ID
	local Barrage2ID = GameInfo.UnitPromotions["PROMOTION_BARRAGE_2"].ID
	local Barrage3ID = GameInfo.UnitPromotions["PROMOTION_BARRAGE_3"].ID
	
	local Accuracy1ID = GameInfo.UnitPromotions["PROMOTION_ACCURACY_1"].ID
	local Accuracy2ID = GameInfo.UnitPromotions["PROMOTION_ACCURACY_2"].ID
	
	local Sunder1ID = GameInfo.UnitPromotions["PROMOTION_SUNDER_1"].ID
	local Sunder2ID = GameInfo.UnitPromotions["PROMOTION_SUNDER_2"].ID
	-- local Sunder3ID = GameInfo.UnitPromotions["PROMOTION_SUNDER_3"].ID
	
	local AOEAttack1ID = GameInfo.UnitPromotions["PROMOTION_CLUSTER_ROCKET_1"].ID
	local AOEAttack2ID = GameInfo.UnitPromotions["PROMOTION_CLUSTER_ROCKET_2"].ID
	local CapitalShipArmor1ID = GameInfo.UnitPromotions["PROMOTION_ARMOR_BATTLESHIP_1"].ID
	local CapitalShipArmor2ID = GameInfo.UnitPromotions["PROMOTION_ARMOR_BATTLESHIP_2"].ID
	
	local NapalmBomb1ID = GameInfo.UnitPromotions["PROMOTION_NAPALMBOMB_1"].ID
	local NapalmBomb2ID = GameInfo.UnitPromotions["PROMOTION_NAPALMBOMB_2"].ID
	local NapalmBomb3ID = GameInfo.UnitPromotions["PROMOTION_NAPALMBOMB_3"].ID
	local DestroySupply1ID = GameInfo.UnitPromotions["PROMOTION_DESTROY_SUPPLY_1"].ID
	local DestroySupply2ID = GameInfo.UnitPromotions["PROMOTION_DESTROY_SUPPLY_2"].ID
	
	local AirBomb1ID = GameInfo.UnitPromotions["PROMOTION_AIR_BOMBARDMENT_1"].ID
	local AirBomb2ID = GameInfo.UnitPromotions["PROMOTION_AIR_BOMBARDMENT_2"].ID
	local AirBomb3ID = GameInfo.UnitPromotions["PROMOTION_AIR_BOMBARDMENT_3"].ID
	local AirTarget1ID = GameInfo.UnitPromotions["PROMOTION_AIR_TARGETING_1"].ID
	local AirTarget2ID = GameInfo.UnitPromotions["PROMOTION_AIR_TARGETING_2"].ID
	local AirTarget3ID = GameInfo.UnitPromotions["PROMOTION_AIR_TARGETING_3"].ID
	
	local AIHitandRunID = GameInfo.UnitPromotions["PROMOTION_RANGE_REDUCE"].ID
	local AIRangeID = GameInfo.UnitPromotions["PROMOTION_RANGE"].ID
	
	local AISPForceID = GameInfo.UnitPromotions["PROMOTION_SPECIAL_FORCES_COMBAT"].ID
	
	local SetUpID = GameInfo.UnitPromotions["PROMOTION_MUST_SET_UP"].ID
	
	local MilitiaUnitID = GameInfo.UnitPromotions["PROMOTION_MILITIA_COMBAT"].ID
	
	local CarrierSupply1ID = GameInfo.UnitPromotions["PROMOTION_CARRIER_SUPPLY_1"].ID
	local CarrierSupply2ID = GameInfo.UnitPromotions["PROMOTION_CARRIER_SUPPLY_2"].ID
	local CarrierSupply3ID = GameInfo.UnitPromotions["PROMOTION_CARRIER_SUPPLY_3"].ID
	local CarrierAntiAir1ID = GameInfo.UnitPromotions["PROMOTION_CARRIER_FIGHTER_ANTI_AIR_1"].ID
	local CarrierAntiAir2ID = GameInfo.UnitPromotions["PROMOTION_CARRIER_FIGHTER_ANTI_AIR_2"].ID
		
	local AICityCount = player:GetNumCities()
	
	
	if AICityCount < 1 then
		return
	end	
	

	local unit = player:GetUnitByID(iUnit)
	    
	if unit == nil or unitBuiltCity == nil then
		return
	end	
	
	
	local unitX = unit:GetX()
	local unitY = unit:GetY()
	
	if unitX == nil or unitY == nil then
		return
	end	
	
	local ThisUnitClass = unit:GetUnitClassType()
	
	local NumMaxUnits = (player:GetNumCities())*25
	if NumMaxUnits > 1000 then
		NumMaxUnits = 1000
	end
	
	if unit:IsCombatUnit() and player:GetNumUnits() > NumMaxUnits then
		unit:Kill()
		print ("AI has too many this units!")
		return
	end
	
	if unit:GetUnitClassType() == GameInfoTypes.UNITCLASS_WORKER then
	   if player:GetUnitClassCount(ThisUnitClass) > AICityCount or player:GetUnitClassCount(ThisUnitClass) > 20 then
	    	unit:Kill()
	    	print ("Major Civ removed too many workers to let the turn goes faster!")
	   end	
	end

	if unit:IsHasPromotion(MilitiaUnitID) and not PlayerAtWarWithHuman(player) then	   
	   if player:GetUnitClassCount(ThisUnitClass) > AICityCount/5 then
	   	  unit:Kill()
	   	  print ("Reduce AI Militia units' number when not at war with Human to let the turn goes faster!")	
	   end	  
	end

	if handicap >= 3 and player:GetCurrentEra() > 1 and player:CalculateGoldRate() > 20 and not PlotIsVisibleToHuman(plot) then 



		if unit:IsHasPromotion(BomberID) then
	       unit:SetHasPromotion(NapalmBomb1ID, true)
		   unit:SetHasPromotion(NapalmBomb2ID, true)	
		   unit:SetHasPromotion(NapalmBomb3ID, true)
		   unit:SetHasPromotion(DestroySupply1ID, true)
		   unit:SetHasPromotion(DestroySupply2ID, true)
		   
		   
		   ------------------------Force AI build escort units!	
		   if AINeedEscortUnit(player) then	   	   
		  	  AIForceBuildAirEscortUnits(unitX, unitY, player)
		  	  if unitBuiltCity:IsCoastal(GameDefines["MIN_WATER_SIZE_FOR_OCEAN"]) then
				if player:GetCurrentEra() >= 2 then
					AIForceBuildNavalEscortUnits(unitX, unitY, player)
					AIForceBuildNavalHRUnits(unitX, unitY, player)
				end
			  else
			  	 AIForceBuildInfantryUnits(unitX, unitY, player)   
				 AIForceBuildMobileUnits(unitX, unitY, player) 
				  AIForceBuildInfantryUnits(unitX, unitY, player)   
		  	  end
		   end
		   
		   
		   
		   
		elseif unit:IsHasPromotion(AirAttackID) then
			unit:SetHasPromotion(AirBomb1ID, true)
			unit:SetHasPromotion(AirBomb2ID, true)	
			unit:SetHasPromotion(AirBomb3ID, true)	
			unit:SetHasPromotion(AirTarget1ID, true)
			unit:SetHasPromotion(AirTarget2ID, true)
			unit:SetHasPromotion(AirTarget3ID, true)	
			
		   

		   ------------------------Force AI build escort units!		
		   if AINeedEscortUnit(player) then	   	   	   	   
				AIForceBuildAirEscortUnits(unitX, unitY, player)
				if unitBuiltCity:IsCoastal(GameDefines["MIN_WATER_SIZE_FOR_OCEAN"]) then
					if player:GetCurrentEra() >= 2 then
						AIForceBuildNavalEscortUnits(unitX, unitY, player)
						AIForceBuildNavalHRUnits(unitX, unitY, player)
					end
				else
					AIForceBuildInfantryUnits(unitX, unitY, player)   
					AIForceBuildMobileUnits(unitX, unitY, player) 
					AIForceBuildInfantryUnits(unitX, unitY, player)  
				end
		   end		   
				   
				   
		   
		elseif unit:IsHasPromotion(CapitalShipID) then
		
			
		   unit:SetHasPromotion(AOEAttack1ID, true)
		   unit:SetHasPromotion(AOEAttack2ID, true)
		   unit:SetHasPromotion(CapitalShipArmor1ID, true)
		   unit:SetHasPromotion(CapitalShipArmor2ID, true)
		   
		   
		   ------------------------Force AI build escort units!	
		   if AINeedEscortUnit(player) then
				if player:GetCurrentEra() >= 2 then
					AIForceBuildNavalEscortUnits(unitX, unitY, player)
					AIForceBuildNavalEscortUnits(unitX, unitY, player)
					AIForceBuildNavalHRUnits(unitX, unitY, player)
					AIForceBuildNavalRangedUnits(unitX, unitY, player)
				end
			   AIForceBuildInfantryUnits(unitX, unitY, player)   
		   end
		   
		   
		elseif unit:IsHasPromotion(CarrierID) then		   
		   
		   unit:SetHasPromotion(CarrierSupply1ID, true)
		   unit:SetHasPromotion(CarrierSupply2ID, true)
		   unit:SetHasPromotion(CarrierSupply3ID, true)
		   unit:SetHasPromotion(CarrierAntiAir1ID, true)
		   unit:SetHasPromotion(CarrierAntiAir2ID, true)
		   
		   
		   ------------------------Force AI build escort units!	
		   if AINeedEscortUnit(player) then	
				if player:GetCurrentEra() >= 2 then
					AIForceBuildNavalEscortUnits(unitX, unitY, player)
					AIForceBuildNavalEscortUnits(unitX, unitY, player)
					AIForceBuildNavalHRUnits(unitX, unitY, player)
					AIForceBuildNavalRangedUnits(unitX, unitY, player)
				end
			   AIForceBuildAirEscortUnits(unitX, unitY, player)
		   end
		   
		   
		 elseif unit:IsHasPromotion(SSBNID) then
		 
		 ------------------------Force AI build escort units!	
		   if AINeedEscortUnit(player) then	  
				if player:GetCurrentEra() >= 2 then
					AIForceBuildNavalEscortUnits(unitX, unitY, player)
					AIForceBuildNavalEscortUnits(unitX, unitY, player)
					AIForceBuildNavalHRUnits(unitX, unitY, player)
				end
			   AIForceBuildAirEscortUnits(unitX, unitY, player)
		   end
		   
		 elseif unit:IsHasPromotion(NavalRangedID) then
		 	unit:SetHasPromotion(Sunder1ID, true)
			--unit:SetHasPromotion(Sunder2ID, true)
		 	unit:SetHasPromotion(CollDamageLV1ID, true)
			--unit:SetHasPromotion(CollDamageLV2ID, true)
			
			------------------------Force AI build escort units!	
			if AINeedEscortUnit(player) then	
				if player:GetCurrentEra() >= 2 then
					AIForceBuildNavalEscortUnits (unitX, unitY, player)
					AIForceBuildNavalHRUnits(unitX, unitY, player)
				end
			end
			
			if player:GetCurrentEra() > 4 then
				unit:SetHasPromotion(CollDamageLV2ID, true)
				unit:SetHasPromotion(Sunder2ID, true)
				unit:SetHasPromotion(AIRangeID, true)
		   	end  
	   	  
	   	
		   		
		elseif unit:IsHasPromotion(AISPForceID) then  		
		   	if AINeedEscortUnit(player) then	   	 	
				AIForceBuildInfantryUnits(unitX, unitY, player)
				AIForceBuildLandCounterUnits(unitX, unitY, player)  
				AIForceBuildMobileUnits(unitX, unitY, player)     
				AIForceBuildMobileUnits(unitX, unitY, player)     
			end  	
		   		
		   
		elseif unit:IsHasPromotion(LandAOEUnitID) then
		   unit:SetHasPromotion(AOEAttack1ID, true)
		   unit:SetHasPromotion(AOEAttack2ID, true)
		   unit:SetHasPromotion(SetUpID, false)	
			   
			------------------------Force AI build escort units!
			if AINeedEscortUnit(player) then	   	 	
				AIForceBuildInfantryUnits(unitX, unitY, player)
				AIForceBuildLandCounterUnits(unitX, unitY, player)  
				AIForceBuildMobileUnits(unitX, unitY, player)     
				AIForceBuildMobileUnits(unitX, unitY, player)     
			end  

		elseif unit:IsHasPromotion(HitandRunID) and player:GetCurrentEra() > 1 then
			unit:SetHasPromotion(Sunder1ID, true)
			unit:SetHasPromotion(Sunder2ID, true)
			unit:SetHasPromotion(AIHitandRunID, true)
			if player:GetCurrentEra() > 5 then
				unit:SetHasPromotion(AIHitandRunID, false)
				unit:SetHasPromotion(AIRangeID, true)
			end
			
		elseif unit:IsHasPromotion(HelicopterID) then
			unit:SetHasPromotion(Sunder1ID, true)
			unit:SetHasPromotion(Sunder2ID, true)
			-- unit:SetHasPromotion(Sunder3ID, true)
			unit:SetHasPromotion(AIRangeID, true)
			
			------------------------Force AI build escort units!
			if AINeedEscortUnit(player) then
				AIForceBuildInfantryUnits(unitX, unitY, player)
				AIForceBuildMobileUnits(unitX, unitY, player)
			end
			
			
		elseif unit:IsHasPromotion(CitySiegeID) then
			unit:SetHasPromotion(CollDamageLV1ID, true)
			unit:SetHasPromotion(SetUpID, false)
			if player:GetCurrentEra() > 3 then
				unit:SetHasPromotion(CollDamageLV2ID, true)
				-- unit:SetHasPromotion(CollDamageLV3ID, true)
		   	end
		   	
		  	------------------------Force AI build escort units!
		  	if AINeedEscortUnit(player) then
				AIForceBuildInfantryUnits(unitX, unitY, player)
				AIForceBuildLandCounterUnits(unitX, unitY, player)  
			   	AIForceBuildInfantryUnits(unitX, unitY, player)
		   	end
		   	
		   	
		elseif unit:IsHasPromotion(RangedUnitID) or unit:IsHasPromotion(NavalHitandRunID) or unit:IsHasPromotion(SubmarineID) then
			unit:SetHasPromotion(Barrage1ID, true)
			unit:SetHasPromotion(Barrage2ID, true)
			
			if player:GetCurrentEra() > 4 then
				unit:SetHasPromotion(Barrage3ID, true)
				unit:SetHasPromotion(Accuracy1ID, true)
				unit:SetHasPromotion(Accuracy2ID, true)
			end
			
			if AINeedEscortUnit(player) then
				if unit:IsHasPromotion(RangedUnitID) then
					AIForceBuildInfantryUnits(unitX, unitY, player)
					AIForceBuildLandCounterUnits(unitX, unitY, player)  			
				elseif unit:IsHasPromotion(SubmarineID) or unit:IsHasPromotion(NavalHitandRunID) then
					AIForceBuildNavalEscortUnits(unitX, unitY, player)
				end
			end
			
			
		end
	end	
		
		------------------------AI with many coastal cities will build more naval units other than land units
	
	if unit:IsCombatUnit() and unitBuiltCity:IsCoastal(GameDefines["MIN_WATER_SIZE_FOR_OCEAN"]) and player:GetUnitClassCount(ThisUnitClass) > AICityCount / 2 then		
			
		---------------------------------Count the ratio of coastal cities
		local AICoastalCitiesCount = 0
		for city in player:Cities() do
			if city:IsCoastal(GameDefines["MIN_WATER_SIZE_FOR_OCEAN"]) then
			   AICoastalCitiesCount = AICoastalCitiesCount + 1				   
			end
		end
		print ("AI coastal cities count:"..AICoastalCitiesCount)
		
		if AICoastalCitiesCount > AICityCount / 1.5 then
		
			if unit:IsRanged() then
				if player:GetCurrentEra() >= 2 then
					AIForceBuildNavalHRUnits(unitX, unitY, player)	
				end
			else
				if player:GetCurrentEra() >= 2 then
					AIForceBuildNavalEscortUnits(unitX, unitY, player)
				end
			end
				
			if player:GetUnitClassCount(ThisUnitClass) > AICityCount * 2 and not PlayerAtWarWithHuman(player) then
				unit:Kill()
				print ("AI has too many this type of land units! So remove it!")
			end
			print ("Coastal AI build more naval units other than land units!")
				
		end
	end
	
	if unit:IsHasPromotion(MilitiaUnitID) then
		if player:GetUnitClassCount(ThisUnitClass) > AICityCount*3 then
			unit:Kill()
		end
	end
	
	if unit:IsHasPromotion(RangedUnitID) or unit:IsHasPromotion(CitySiegeID) then
		if player:GetUnitClassCount(ThisUnitClass) > AICityCount*4 then
			unit:Kill()
		end
	end
	if unit~=nil and unit:GetID()~=nil then 
		RemoveErrorPromotion(unit:GetOwner(), unit:GetID())
	end
end
GameEvents.CityTrained.Add(AIPromotion)


---------------------------------------------------------------------Check AI resource condition----------------------------------------------------


function AICheckResource(player)
--	local ConsumerNum = player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_CONSUMER"],true) - player:GetNumResourceUsed(GameInfoTypes["RESOURCE_CONSUMER"])
--	local ElectricityNum = player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_ELECTRICITY"],true) - player:GetNumResourceUsed(GameInfoTypes["RESOURCE_ELECTRICITY"])
--	local ManPowerNum = player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_MANPOWER"],true) - player:GetNumResourceUsed(GameInfoTypes["RESOURCE_MANPOWER"])
--	local IronNum = player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_IRON"],true) - player:GetNumResourceUsed(GameInfoTypes["RESOURCE_IRON"])
--	local AluminumNum = player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_ALUMINUM"],true) - player:GetNumResourceUsed(GameInfoTypes["RESOURCE_ALUMINUM"])
--	local OilNum = player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_OIL"],true) - player:GetNumResourceUsed(GameInfoTypes["RESOURCE_OIL"])
--	local CoalNum = player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_COAL"],true) - player:GetNumResourceUsed(GameInfoTypes["RESOURCE_COAL"])
	
	if player == nil or player:IsHuman() or player:GetNumCities() < 3 or player:IsMinorCiv() or player:IsBarbarian() then
		return
	end
	if Game:GetHandicapType() < 3 then
		print ("Human beings are not as clever as AI in Resource, AI should take care of human beings.")
		return
	end 
	local iHandicap = Game:GetHandicapType()
	
	local NumEra = player:GetCurrentEra()
	
	if player:GetCurrentEra() >= 5 then

		if AICanBeBoss(player) then
			if player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_ELECTRICITY"],true) <= 20 then
--				ElectricityNum = math.max(-10, ElectricityNum)
			   player:ChangeNumResourceTotal(GameInfoTypes["RESOURCE_ELECTRICITY"], NumEra*(1+iHandicap))
			end
			if player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_ALUMINUM"],true) <= 50 then
--				AluminumNum = math.max(-10, AluminumNum)
			   player:ChangeNumResourceTotal(GameInfoTypes["RESOURCE_ALUMINUM"], NumEra*(1+2*iHandicap))
			end
			if player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_OIL"],true) <= 50 then
--				ilNum = math.max(-10, OilNum)
			   player:ChangeNumResourceTotal(GameInfoTypes["RESOURCE_OIL"], NumEra*(1+2*iHandicap))
			end
			if player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_COAL"],true) <= 50 then
--				CoalNum = math.max(-10, CoalNum)
			   player:ChangeNumResourceTotal(GameInfoTypes["RESOURCE_COAL"], NumEra*(1+2*iHandicap))
			end
		else
			if player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_ELECTRICITY"],true) <= 15 then
--				ElectricityNum = math.max(-10, ElectricityNum)
			   player:ChangeNumResourceTotal(GameInfoTypes["RESOURCE_ELECTRICITY"], NumEra*(2+math.floor(iHandicap/2)))
			end
			if player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_ALUMINUM"],true) <= 30 then
--				AluminumNum = math.max(-10, AluminumNum)
			   player:ChangeNumResourceTotal(GameInfoTypes["RESOURCE_ALUMINUM"], NumEra*(3+iHandicap))
			end
			if player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_OIL"],true) <= 30 then
--				ilNum = math.max(-10, OilNum)
			   player:ChangeNumResourceTotal(GameInfoTypes["RESOURCE_OIL"], NumEra*(3+iHandicap))
			end
			if player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_COAL"],true) <= 30 then
--				CoalNum = math.max(-10, CoalNum)
			   player:ChangeNumResourceTotal(GameInfoTypes["RESOURCE_COAL"], NumEra*(3+iHandicap))
			end
		end
		print ("AI get Post-modern Resource Supply!")
	end	
	
--	if IronNum < 0 then
	local pTeam = Teams[player:GetTeam()]
	if pTeam:IsHasTech(GameInfoTypes["TECH_IRON_WORKING"]) then
		if AICanBeBoss(player) then
			if player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_IRON"],true) <= 50 then
--				IronNum = math.max(-8, IronNum)
				player:ChangeNumResourceTotal(GameInfoTypes["RESOURCE_IRON"], NumEra*(3+iHandicap))
			end
		else
			if player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_IRON"],true) <= 30 then
				player:ChangeNumResourceTotal(GameInfoTypes["RESOURCE_IRON"], NumEra*(2+math.floor(iHandicap/2)))
			end
			print ("AI get Iron Supply!")
		end	
	end
	
	if pTeam:IsHasTech(GameInfoTypes["TECH_ANIMAL_HUSBANDRY"]) then
		if AICanBeBoss(player) then
			if player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_HORSE"],true) <= 50 then
--				IronNum = math.max(-8, IronNum)
				player:ChangeNumResourceTotal(GameInfoTypes["RESOURCE_HORSE"], NumEra*(3+iHandicap))
			end
		else
			if player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_HORSE"],true) <= 30 then
				player:ChangeNumResourceTotal(GameInfoTypes["RESOURCE_HORSE"], NumEra*(2+math.floor(iHandicap/2)))
			end
			print ("AI get Iron Supply!")
		end	
	end
				
--	if ManPowerNum < 0 and player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_MANPOWER"],true) <= 100 then
	if AICanBeBoss(player) then
		if (player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_MANPOWER"],true) + player:GetNumResourceUsed(GameInfoTypes["RESOURCE_MANPOWER"])) < (NumEra + 2)*220 then
--			ManPowerNum = math.max(-10, ManPowerNum)
			if player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_MANPOWER"],true) <= math.min(NumEra*20, 50) then
				player:ChangeNumResourceTotal(GameInfoTypes["RESOURCE_MANPOWER"], NumEra*(4+3*iHandicap))
			end
		end
	else
		if (player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_MANPOWER"],true) + player:GetNumResourceUsed(GameInfoTypes["RESOURCE_MANPOWER"])) < (NumEra + 2)*180 then
			if player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_MANPOWER"],true) <= math.min(NumEra*18, 30) then
				player:ChangeNumResourceTotal(GameInfoTypes["RESOURCE_MANPOWER"], NumEra*(6+2*iHandicap))
			end
		end
		print ("AI get Manpower Supply!")
	end	
	
	if AICanBeBoss(player) then
		if player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_CONSUMER"],true) <= 30 then
			player:ChangeNumResourceTotal(GameInfoTypes["RESOURCE_CONSUMER"], NumEra*(3+iHandicap))
			print ("AI Boss get Consumer Goods Supply!")
		end
	else
		if player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_CONSUMER"],true) <= 20 then
--			ConsumerNum = math.max(-10, ConsumerNum)
			player:ChangeNumResourceTotal(GameInfoTypes["RESOURCE_CONSUMER"], NumEra*(2+math.floor(iHandicap*0.75)))
			print ("AI get Consumer Goods Supply!")
		end
	end	
end





---------------------------------------------------------------------Check if AI has too many units of same type----------------------------------------------------


function AINeedEscortUnit(player)

	if AICanBeBoss(player) or player:HasPolicy(GameInfoTypes["POLICY_AI_BONUS_WAR_LV2"]) or PlayerAtWarWithHuman(player) then
		return true
	else
		return false
	end
	
end



------------------------------------------------------------------AI bonus by Human's strength----------------------------------------------------

----------AI Science Bonus
function AIResearchCatchUp(HumanResearchPerTurn,HumanCurrentEra,AIplayer) 


	if AIplayer == nil then
		return
	end

	local AICurrentEra = AIplayer:GetCurrentEra()
	local AIResearchPerTurn = AIplayer:GetScience()
	print ("Human science Output:"..HumanResearchPerTurn)
	print ("AI science Output:"..AIResearchPerTurn)
	
	if AIplayer:HasPolicy(GameInfo.Policies["POLICY_AI_BOUNS_RESEARCH_LV1"].ID) then
		AIResearchPerTurn = AIResearchPerTurn * 0.75;
	end
	
	if AICurrentEra >= 3 and AIResearchPerTurn > 1 then
		if     HumanCurrentEra - AICurrentEra >= 2 then		-- HumanResearchPerTurn > AIResearchPerTurn * 2 or 
			AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_BOUNS_RESEARCH_LV1"].ID,true)
			AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_BOUNS_RESEARCH_LV2"].ID,true)
			AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_BOUNS_RESEARCH_LV3"].ID,true)
			print ("Human's research is too fast -2X, AI needs to catch up sooner!")
			
		elseif HumanCurrentEra - AICurrentEra == 1 then		-- HumanResearchPerTurn > AIResearchPerTurn * 1.5 or 
			AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_BOUNS_RESEARCH_LV1"].ID,true)
			AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_BOUNS_RESEARCH_LV2"].ID,true)
			AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_BOUNS_RESEARCH_LV3"].ID,false)
			print ("Human's research is fast -1.5X, AI needs to catch up!")
			
		elseif HumanResearchPerTurn > AIResearchPerTurn and HumanCurrentEra == AICurrentEra then
			AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_BOUNS_RESEARCH_LV1"].ID,true)
			AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_BOUNS_RESEARCH_LV2"].ID,false)
			AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_BOUNS_RESEARCH_LV3"].ID,false)
			print ("Human's research is not so fast!")	
			
		elseif HumanResearchPerTurn <= AIResearchPerTurn or HumanCurrentEra <  AICurrentEra then
			AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_BOUNS_RESEARCH_LV1"].ID,false)
			AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_BOUNS_RESEARCH_LV2"].ID,false)
			AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_BOUNS_RESEARCH_LV3"].ID,false)
			print ("Human's research is slow! So give him or her a chance!")
		end
	end
	
	-- Special AI Research Bonus for 8 Handicap
	if Game:GetHandicapType() == 7 and HumanCurrentEra >= 5 then
		AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_BOUNS_RESEARCH_DEITY"].ID, true);
		print ("Special AI Research Bonus for Super Power Players!")
	end
end


 		--------AI Economy Bonus
function AIEconomyCatchUp(HumanCityCount,HumanPopCount,AIplayer)  

	if AIplayer == nil then
		return
	end
	local AIPopCount = AIplayer:GetTotalPopulation()
	local AICityCount = AIplayer:GetNumCities()	
	
	if AIPopCount > 6 and AICityCount >= 1 then
		if HumanCityCount > AICityCount * 2 or HumanPopCount > AIPopCount * 1.5 then
			AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_BOUNS_ECONOMY_LV1"].ID,true)
			AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_BOUNS_ECONOMY_LV2"].ID,true)
			AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_BOUNS_ECONOMY_LV3"].ID,true)
			print ("Human's nation is developing fast - 2X. AI must catch up!")
		elseif HumanCityCount > AICityCount * 1.5 or HumanPopCount > AIPopCount * 1.25 then
			AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_BOUNS_ECONOMY_LV1"].ID,true)
			AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_BOUNS_ECONOMY_LV2"].ID,true)
			AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_BOUNS_ECONOMY_LV3"].ID,false)
			print ("Human's nation is developing well - 1.5X. AI must catch up!")
		elseif HumanCityCount > AICityCount * 1.25 or HumanPopCount > AIPopCount then
			AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_BOUNS_ECONOMY_LV1"].ID,true)
			AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_BOUNS_ECONOMY_LV2"].ID,false)
			AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_BOUNS_ECONOMY_LV3"].ID,false)
			print ("Human's nation is developing. AI should catch up!")  	 
		elseif HumanCityCount <= AICityCount or HumanPopCount <= AIPopCount * 0.75 then
			AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_BOUNS_ECONOMY_LV1"].ID,false)
			AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_BOUNS_ECONOMY_LV2"].ID,false)
			AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_BOUNS_ECONOMY_LV3"].ID,false)
			print ("Human's nation is not developing well. So give him or her a chance!")
		end
	end
end


----------AI War Bonus
function AIMilitaryCatchUp(iNumCapitals,AIplayer) 

	if AIplayer == nil then
		return
	end
	if PlayerAtWarWithHuman(AIplayer) then
		if iNumCapitals >= 6 then
			AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_BONUS_WAR_LV1"].ID,true)
			AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_BONUS_WAR_LV2"].ID,true)
			AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_BONUS_WAR_LV3"].ID,true)
			print ("Human's military is too strong, Fight to the last man!")
		elseif iNumCapitals < 6 and iNumCapitals >= 4 then	
			AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_BONUS_WAR_LV1"].ID,true)
			AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_BONUS_WAR_LV2"].ID,true)
			AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_BONUS_WAR_LV3"].ID,false)
			print ("Human's military is strong, Hit them hard!")
		elseif iNumCapitals < 4 and iNumCapitals >= 2 then	
			AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_BONUS_WAR_LV1"].ID,true)
			AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_BONUS_WAR_LV2"].ID,false)
			AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_BONUS_WAR_LV3"].ID,false)
			print ("Human's military is not weak!")
		elseif iNumCapitals < 2 then	
			AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_BONUS_WAR_LV1"].ID,false)
			AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_BONUS_WAR_LV2"].ID,false)
			AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_BONUS_WAR_LV3"].ID,false)
			print ("Human's military is weak! No need for going hard!")	
		end
	end
end



function AIBossBonus(HumanScore,TotalScore,TotalMajCiv,AIplayer) 

	if HumanScore == nil or TotalMajCiv == nil then
		print ("Error! No human data input!")
		return
	end	
		
	print ("Total Score:"..TotalScore)
	print ("Total Major Civs:"..TotalMajCiv)
	local AvgScore = TotalScore / TotalMajCiv
	print ("Average Score:"..AvgScore)
	print ("Human Score:"..HumanScore)

	   		---------AI enhancement for human's score
	if HumanScore >= AvgScore * 2 then
		AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_PLAYER_CITIES_50"].ID,true)
		AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_PLAYER_CITIES_30"].ID,true)
		AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_PLAYER_CITIES_20"].ID,true)
		AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_PLAYER_CITIES_10"].ID,true)	
		print ("Human is unstopable!!!")
		
	elseif HumanScore >= AvgScore * 1.6 then 
		AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_PLAYER_CITIES_50"].ID,false)
		AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_PLAYER_CITIES_30"].ID,true)
		AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_PLAYER_CITIES_20"].ID,true)
		AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_PLAYER_CITIES_10"].ID,true)
		print ("Human is too strong!!!Hurry up AIs!")
		
	elseif HumanScore >= AvgScore * 1.3 then 	
		AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_PLAYER_CITIES_50"].ID,false)
		AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_PLAYER_CITIES_30"].ID,false)
		AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_PLAYER_CITIES_20"].ID,true)
		AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_PLAYER_CITIES_10"].ID,true)
		print ("Human is very strong!!!")
		
	elseif HumanScore >= AvgScore then 
		AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_PLAYER_CITIES_50"].ID,false)
		AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_PLAYER_CITIES_30"].ID,false)
		AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_PLAYER_CITIES_20"].ID,false)
		AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_PLAYER_CITIES_10"].ID,true)
		print ("Human is strong!!!")
		
	elseif HumanScore < AvgScore then
		AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_PLAYER_CITIES_50"].ID,false)
		AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_PLAYER_CITIES_30"].ID,false)
		AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_PLAYER_CITIES_20"].ID,false)
		AIplayer:SetHasPolicy(GameInfo.Policies["POLICY_AI_PLAYER_CITIES_10"].ID,false)
		print ("Human is weak! No Boss bonus!")
	end
end



---------------------------------------------------------------------Limit Minor Civs build too many untis to make the system slow----------------------------------------------------

function MinorLimitUnits(iPlayer, iUnit)
	local player = Players[iPlayer];
	if player == nil or not player:IsMinorCiv() or player:GetNumCities() < 1 then
		return;
	end
	local unit = player:GetUnitByID(iUnit);
	if unit == nil then
		return;
	end
	
	if     unit:GetUnitClassType() == GameInfoTypes.UNITCLASS_WORKER
	and player:GetUnitClassCount(GameInfo.UnitClasses.UNITCLASS_WORKER.ID) > 1
	then
		unit:Kill();
		print ("Minor Civ removed too many workers!");
	elseif unit:IsCombatUnit() and unit:GetUnitCombatType() == GameInfoTypes.UNITCOMBAT_RECON
	and player:GetNumMilitaryUnits() > 5*player:GetNumCities()
	then
		unit:Kill();
		print ("Minor Civ removed too many militia units!");
	end
end


Events.SerialEventUnitCreated.Add(MinorLimitUnits)


function MinorLoseCity(oldPlayerID, bCapital, iX, iY, newPlayerID, conquest, conquest2)
	local oldPlayer = Players[oldPlayerID]
	local newPlayer = Players[newPlayerID]
	local City =  Map.GetPlot(iX, iY):GetPlotCity()
	if bCapital and oldPlayer:IsMinorCiv() and oldPlayer:GetCurrentEra() >= 4 and not newPlayer:IsMinorCiv() then
		City:SetNumRealBuilding(GameInfoTypes["BUILDING_GRAIN_DEPOT"],0)
		City:SetNumRealBuilding(GameInfoTypes["BUILDING_MECHANIZED_FARM"],0)
		City:SetNumRealBuilding(GameInfoTypes["BUILDING_TAP_WATER_SUPPLY"],0)
		City:SetNumRealBuilding(GameInfoTypes["BUILDING_HOSPITAL"],0)
		City:SetNumRealBuilding(GameInfoTypes["BUILDING_LIBRARY"],0)
		City:SetNumRealBuilding(GameInfoTypes["BUILDING_PUBLIC_SCHOOL"],0)
		print("Minor civ lose post-industrial bonus!")
	end
end
GameEvents.CityCaptureComplete.Add(MinorLoseCity)



function ChangeUnitsToLand( iTeam1, iTeam2, bWar )
	if iTeam1 == nil or iTeam2 == nil then 
		return
	end
	if Game:GetHandicapType() < 3 then
		print ("Human beings are not as clever as AI in War, AI should take care of human beings.")
		return
	end
	local pTeam1 = Teams[iTeam1]
	local pTeam2 = Teams[iTeam2]
	if not pTeam1:IsHuman() and not pTeam2:IsHuman() then
	 	return
	end
	if not pTeam1:IsAtWar(pTeam2) then
		return
	end

-------------      Start War : Naval to Land     ----------------------	
	
	local player = Teams[iTeam2]
	if player ~= nil and player:IsHuman() then
		local AIplayer = Players[iTeam1]
		if AIplayer ~= nil and AIplayer:GetNumCities() >= 1 and not AIplayer:IsMinorCiv() and not AIplayer:IsBarbarian()
		and not AIplayer:IsHuman() then
			print("This AI at war with human!")
			local NumNavalUnits = 0
			local NumLandUnits = 0
			local NumDValue = 0
			local NumNowUnits = AIplayer:GetNumUnits()
			local NumMaxUnits = (AIplayer:GetNumCities())*25
			local NumCitis = AIplayer:GetNumCities()
			if NumMaxUnits > 1000 then
				NumMaxUnits = 1000
			end
			for unit in AIplayer:Units() do
				local unitDomain = unit:GetDomainType()
				if unitDomain == DomainTypes.DOMAIN_SEA and unit:IsCombatUnit() then
					NumNavalUnits = NumNavalUnits + 1
				elseif unitDomain == DomainTypes.DOMAIN_LAND and unit:IsCombatUnit() then
					NumLandUnits = NumLandUnits + 1
				end
			end
			print("Civ's Naval Unit:"..NumNavalUnits)
			print("Civ's Land Unit:"..NumLandUnits)
			if NumNavalUnits > NumNowUnits/2 then
				for pUnit in AIplayer:Units() do
					local pUnitDomain = pUnit:GetDomainType()
					if pUnitDomain == DomainTypes.DOMAIN_SEA and pUnit:IsCombatUnit() and NumNavalUnits > NumLandUnits
					and	NumDValue <= NumCitis*4 then
						pUnit:Kill()
						NumNavalUnits = NumNavalUnits - 1
						NumLandUnits = NumLandUnits + 1
						NumDValue = NumDValue + 1
					end
				end
				print("Civ's Land - Naval:"..NumDValue)
				for city in AIplayer:Cities() do
					local plot = city
					local unitX = plot:GetX()
					local unitY = plot:GetY()
					if NumDValue > 0 and AIplayer:GetNumUnits() < NumMaxUnits then
						AIForceBuildInfantryUnits(unitX, unitY, AIplayer)
						AIForceBuildInfantryUnits(unitX, unitY, AIplayer)
						AIForceBuildLandCounterUnits(unitX, unitY, AIplayer)
						AIForceBuildLandCounterUnits(unitX, unitY, AIplayer)
						AIForceBuildMobileUnits(unitX, unitY, AIplayer)
						AIForceBuildMobileUnits(unitX, unitY, AIplayer)
						NumDValue = NumDValue - 4
					end
				end
				print("AI need land units!")
			end
		end						
	end
end
Events.WarStateChanged.Add(ChangeUnitsToLand)







print("New Handicap Check Pass!")