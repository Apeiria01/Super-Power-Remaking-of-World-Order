-- New Population Rule

--------------------------------------------------------------

--------------------------------------------------------------Still WIP! Some functions are still stupid and cumbersome! Sorry but I'm a newbee for programming!!!----------------------------------

--include( "UtilityFunctions.lua" )



-----------------------------------------------------------------------Settlers & Population---------------------------------------
function SettlerTrainedCity(iPlayer, iCity, iUnit, bGold, bFaith)
	local pPlayer = Players[iPlayer]
	local pUnit = pPlayer:GetUnitByID(iUnit)
	local pCity = pPlayer:GetCityByID(iCity)
	local CityPop = pCity:GetPopulation()   
	local NewCityPop = CityPop
	
	if pPlayer:IsHuman() and pUnit and pUnit:IsFound() then
--		pUnit:JumpToNearestValidPlot() ----Move Settler out of the city to avoid settler become population after built BUG
		if 	pPlayer:HasPolicy(GameInfo.Policies["POLICY_RESETTLEMENT"].ID) and CityPop >= 4 then
			NewCityPop = CityPop - 3
			pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_SETTLER_POP_3"].ID, true)
		else	
			NewCityPop = CityPop - 1
		end
		
		pCity:SetPopulation(NewCityPop, true)----Set Real Population
		---- Notifications
		local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_SETTLER_TRAINED_CITY", pUnit:GetName(), pCity:GetName())
		local heading = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_SETTLER_TRAINED_CITY_SHORT", pUnit:GetName(), pCity:GetName())
		pPlayer:AddNotification(NotificationTypes.NOTIFICATION_STARVING, text, heading, pUnit:GetX(), pUnit:GetY())
	end
end
GameEvents.CityTrained.Add(SettlerTrainedCity)



-- Unit death cause population loss -- MOD by CaptainCWB
function UnitDeathCounter(iKerPlayer, iKeePlayer, eUnitType)
	if (PreGame.GetGameOption("GAMEOPTION_SP_NEWATTACK_OFF") == 1) then
		print("New Attack Effects - War Casualties - OFF!");
		return;
	end
	
	if Players[iKeePlayer] == nil or not Players[iKeePlayer]:IsAlive() or Players[iKeePlayer]:GetCapitalCity() == nil
	or Players[iKeePlayer]:IsMinorCiv() or Players[iKeePlayer]:IsBarbarian()
	or GameInfo.Units[eUnitType] == nil
	-- UnCombat units do not count
	or(GameInfo.Units[eUnitType].Combat == 0 and GameInfo.Units[eUnitType].RangedCombat == 0)
	then
		return;
	end
	
	local defPlayer = Players[iKeePlayer];
	local iCasualty = defPlayer:GetCapitalCity():GetNumBuilding(GameInfoTypes["BUILDING_WAR_CASUALTIES"]);
	local sUnitType = GameInfo.Units[eUnitType].Type;
	local iDCounter = 6;
	
	if     GameInfo.Unit_FreePromotions{ UnitType = sUnitType, PromotionType = "PROMOTION_NO_CASUALTIES" }() then
		print ("This unit won't cause Casualties!");
		return;
	elseif GameInfo.Unit_FreePromotions{ UnitType = sUnitType, PromotionType = "PROMOTION_HALF_CASUALTIES" }() then
		iDCounter = iDCounter/2;
	end
	if defPlayer:HasPolicy(GameInfo.Policies["POLICY_CENTRALISATION"].ID) then
		iDCounter = 2*iDCounter/3;
	end
	
	print ("DeathCounter(Max-12): ".. iCasualty .. " + " .. iDCounter);
	if iCasualty + iDCounter < 12 then
		defPlayer:GetCapitalCity():SetNumRealBuilding(GameInfoTypes["BUILDING_WAR_CASUALTIES"], iCasualty + iDCounter);
	else
		defPlayer:GetCapitalCity():SetNumRealBuilding(GameInfoTypes["BUILDING_WAR_CASUALTIES"], 0);
		local PlayerCitiesCount = defPlayer:GetNumCities();
		if PlayerCitiesCount <= 0 then ---- In case of 0 city error
			return;
		end
		local apCities = {};
		local iCounter = 0;
		
		for pCity in defPlayer:Cities() do
			local cityPop = pCity:GetPopulation();
			if ( cityPop > 1 and defPlayer:IsHuman() ) or cityPop > 5 then
				apCities[iCounter] = pCity
				iCounter = iCounter + 1
			end
		end
		
		if (iCounter > 0) then
			local iRandChoice = Game.Rand(iCounter, "Choosing random city")
			local targetCity = apCities[iRandChoice]
			local Cityname = targetCity:GetName()
			local iX = targetCity:GetX();
			local iY = targetCity:GetY();
			
			if targetCity:GetPopulation() > 1 then
				targetCity:ChangePopulation(-1, true)
				print ("population lost!"..Cityname)
			else 
				return;
			end
			if defPlayer:IsHuman() then -- Sending Message
				local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTE_POPULATION_LOSS",targetCity:GetName())
				local heading = Locale.ConvertTextKey("TXT_KEY_SP_NOTE_POPULATION_LOSS_SHORT")
				defPlayer:AddNotification(NotificationTypes.NOTIFICATION_STARVING, text, heading, iX, iY)
			end
		end
	end
end
GameEvents.UnitKilledInCombat.Add(UnitDeathCounter)



------------------------------------------------------------------Misc Functions-------------------------------------------------------------------------











print("New Population Rule Pass!")




