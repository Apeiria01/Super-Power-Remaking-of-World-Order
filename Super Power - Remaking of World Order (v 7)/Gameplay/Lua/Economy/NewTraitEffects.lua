-- New Trait and Policies
--include( "UtilityFunctions.lua" )
include("FLuaVector.lua");
include("UtilityFunctions.lua");
include("PlotIterators.lua");
-------------------------------------------------------------------------New Trait Effects-----------------------------------------------------------------------
if Game.GetGameSpeedType() == 3 then
	local QuickGameSpeedID = GameInfo.UnitPromotions["PROMOTION_GAME_QUICKSPEED"].ID
	Events.SerialEventUnitCreated.Add(
		function(iPlayerID, iUnitID)
			local pPlayer = Players[iPlayerID]
			if pPlayer == nil then return end
			local pUnit = pPlayer:GetUnitByID(iUnitID)
			if pUnit == nil then return end
			pUnit:SetHasPromotion(QuickGameSpeedID, true)
		end
	)
end

-- Hun UA effects
if Game.IsCivEverActive(GameInfoTypes.CIVILIZATION_HUNS) then
	function HunDestroyCity(hexPos, playerID, cityID) --Hun will gain yield after razing a city
		local player = Players[playerID];

		if player and player:HasTrait(GameInfoTypes["TRAIT_RAZE_AND_HORSES"])
		then
			print("Hun City Razed!")

			local CurrentTurn = Game.GetGameTurn();
			local Output = 10 * CurrentTurn;
			if Output > 1000 then
				Output = 1000;
			end

			print("Output:" .. Output);

			player:ChangeJONSCulture(Output);
			player:ChangeGold(Output);
			player:ChangeFaith(Output);

			local team = Teams[player:GetTeam()];
			local teamTech = team:GetTeamTechs();
			local iCurrentTech = player:GetCurrentResearch();
			-- Avoid Crash if a Tech is finished right now
			if teamTech == nil or iCurrentTech == -1 then
				print("no Tech under researching");
			else
				local iResearchLeft = teamTech:GetResearchLeft(iCurrentTech);
				if iResearchLeft > Output then
					teamTech:ChangeResearchProgress(iCurrentTech, Output, playerID);
				else
					team:SetHasTech(iCurrentTech, true);
				end
			end

			-- Send a notification to the player (if Human)
			if player:IsHuman() and Output > 0 then
				local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_TRAIT_OUTPUT_FROM_RAZING", tostring(Output))
				Events.GameplayAlertMessage(text)
			end
		end
	end

	Events.SerialEventCityDestroyed.Add(HunDestroyCity)
end

----Reddit to avoid triggering when getting city peacefully
if Game.IsCivEverActive(GameInfoTypes.CIVILIZATION_ASSYRIA) then
	-- Assyria gain population after capturing cities
	function AssyriaCityCapture(oldPlayerID, bIsCapital, iX, iY, newPlayerID, iOldPopulation, bConquest, iGreatWorksPresent, iGreatWorksXferred)
		if not bConquest then
			print("trading city is not availiable for assyria'ua")
			return
		end
		
		local NewPlayer = Players[newPlayerID]
		local pPlot = Map.GetPlot(iX, iY)
		local pCity = pPlot:GetPlotCity()
		local OldPlayer = Players[oldPlayerID]
		if NewPlayer == nil or OldPlayer == nil then
			print("No players")
			return
		end

		if NewPlayer:HasTrait(GameInfoTypes["TRAIT_SLAYER_OF_TIAMAT"])
		then
			print("Assyria Militarily conquested a city")
			if pCity:GetPopulation() > 4 and NewPlayer:GetCapitalCity() ~= nil then
				print("Assyria can plunder population!")
				local pCapital = NewPlayer:GetCapitalCity()
				pCapital:ChangePopulation(1, true)

				-- Notification
				local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_ASSYRIA_POPULATION", pCapital:GetName())
				local heading = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_ASSYRIA_POPULATION_SHORT")
				NewPlayer:AddNotification(NotificationTypes.NOTIFICATION_CITY_GROWTH, text, heading, iX, iY)
			end
		end
	end

	GameEvents.CityCaptureComplete.Add(AssyriaCityCapture)
end


-- Austria UA effects
-- TODO(catgrep): will implement in DLL in the future
if Game.IsCivEverActive(GameInfoTypes.CIVILIZATION_AUSTRIA) then
	function AustriaAnnexCityState(oldPlayerID, bIsCapital, iX, iY, newPlayerID, iOldPopulation, bConquest, iGreatWorksPresent, iGreatWorksXferred)
		local NewPlayer = Players[newPlayerID];
		local pPlot = Map.GetPlot(iX, iY);
		local pCity = pPlot:GetPlotCity();
		if NewPlayer == nil or newPlayerID == oldPlayerID or pCity == nil or not pCity:IsOriginalCapital()
			or not Players[pCity:GetOriginalOwner()]:IsMinorCiv()
		then
			return;
		end

		if NewPlayer:IsAbleToAnnexCityStates() then
			pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_OLD_CAPITAL_OF_CITYSTATE"], 1);
			print("Austria Annex City State!");
		end
	end

	GameEvents.CityCaptureComplete.Add(AustriaAnnexCityState)
end

if Game.IsCivEverActive(GameInfoTypes.CIVILIZATION_NETHERLANDS) then
	function SPTraitsTech(ePlayer, eTech, bAdopted)
		
		-- Nederland Set Buildings
		local player = Players[ePlayer];
		if player == nil or player:IsMinorCiv() or player:IsBarbarian() then
			return
		end
		if player:HasTrait(GameInfoTypes["TRAIT_LUXURY_RETENTION"])
		then
			if eTech == GameInfoTypes["TECH_ELECTRONICS"] then
				for city in player:Cities() do
					if city:IsHasBuilding(GameInfoTypes["BUILDING_STOCK_EXCHANGE"]) then
						city:SetNumRealBuilding(GameInfoTypes["BUILDING_FINANCE_COMPANY"], 1)
					end
				end
			elseif eTech == GameInfoTypes["TECH_URBANLIZATION"] then
				for city in player:Cities() do
					if city:IsHasBuilding(GameInfoTypes["BUILDING_BANK"]) then
						city:SetNumRealBuilding(GameInfoTypes["BUILDING_STOCK_EXCHANGE"], 1)
					end
				end
			elseif eTech == GameInfoTypes["TECH_ECONOMICS"] then
				for city in player:Cities() do
					if city:IsHasBuilding(GameInfoTypes["BUILDING_MARKET"]) then
						city:SetNumRealBuilding(GameInfoTypes["BUILDING_BANK"], 1)
					end
				end
			end
		end
	end

	GameEvents.PlayerSetHasTech.Add(SPTraitsTech)
end

if Game.IsCivEverActive(GameInfoTypes.CIVILIZATION_RUSSIA) then
	GameEvents.CityBoughtPlot.Add(function(iPlayer, iCity, iPlotX, iPlotY, bGold, bCulture)
		local pPlayer = Players[iPlayer]
		if pPlayer == nil or not pPlayer:IsAlive() or pPlayer:GetCivilizationType() ~= GameInfoTypes.CIVILIZATION_RUSSIA then
			return;
		end
		if not bCulture then
			return;
		end

		local iBonus = 2 + 2 * pPlayer:GetCurrentEra();
		pPlayer:ChangeOverflowResearch(iBonus);
		if pPlayer:IsHuman() and pPlayer:IsTurnActive() then
			local hex = ToHexFromGrid(Vector2(iPlotX, iPlotY));
			Events.AddPopupTextEvent(HexToWorld(hex),
				Locale.ConvertTextKey("[COLOR_BLUE]+{1_Num}[ICON_RESEARCH][ENDCOLOR]", iBonus));
		end
	end)
end

if Game.IsCivEverActive(GameInfoTypes.CIVILIZATION_VENICE) then
	GameEvents.PlayerDoTurn.Add(function(iPlayer) -- Venice AI food bonus.
		local pPlayer = Players[iPlayer];
		if pPlayer == nil or pPlayer:IsHuman() or not pPlayer:IsAlive() or not pPlayer:IsMajorCiv() or pPlayer:GetCivilizationType() ~= GameInfoTypes.CIVILIZATION_VENICE then
			return;
		end

		local pCapital = pPlayer:GetCapitalCity();
		if pCapital == nil then return; end
		local iBonus = Game.GetHandicapType() * 4 * pCapital:GrowthThreshold() / 100;
		pCapital:ChangeFood(iBonus);
	end)
end

print("New Trait Effect Check Pass!")
