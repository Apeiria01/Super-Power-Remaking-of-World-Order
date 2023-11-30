-- New Trait and Policies
--include( "UtilityFunctions.lua" )
include("FLuaVector.lua");
include("UtilityFunctions.lua");
include("PlotIterators.lua");
-------------------------------------------------------------------------New Trait Effects-----------------------------------------------------------------------
if Game.GetGameSpeedType() == 3 then
	GameEvents.UnitCreated.Add(
		function(iPlayerID, iUnitID)
			local pPlayer = Players[iPlayerID]
			if pPlayer == nil then return end
			local pUnit = pPlayer:GetUnitByID(iUnitID)
			if pUnit == nil then return end

			local GameSpeed = Game.GetGameSpeedType()
			local QuickGameSpeedID = GameInfo.UnitPromotions["PROMOTION_GAME_QUICKSPEED"].ID

			if GameSpeed == 3 then
				pUnit:SetHasPromotion(QuickGameSpeedID, true)
			end
		end
	)
end

-- Fix the "Archaeological Dig Finished" Freeze
function OnPopupMessageCA(popupInfo)
	local popupType = popupInfo.Type;
	if popupType ~= ButtonPopupTypes.BUTTONPOPUP_CHOOSE_ARCHAEOLOGY then
		return;
	end

	local iUnit = popupInfo.Data2;
	if (iUnit == nil or iUnit == -1) and Players[Game.GetActivePlayer()]:GetUnitClassCount(GameInfoTypes.UNITCLASS_ARCHAEOLOGIST) == 1 then
		for pUnit in Players[Game.GetActivePlayer()]:Units() do
			if pUnit and pUnit:GetUnitClassType() == GameInfoTypes.UNITCLASS_ARCHAEOLOGIST
				and pUnit:GetPlot():GetImprovementType() == GameInfoTypes["IMPROVEMENT_ARCHAEOLOGICAL_DIG"]
			then
				local iX, iY = pUnit:GetX(), pUnit:GetY();
				pUnit:Kill();
				Players[Game.GetActivePlayer()]:InitUnit(GameInfoTypes.UNIT_ARCHAEOLOGIST, iX, iY):SetMoves(0);
				break;
			end
		end
	end
end

Events.SerialEventGameMessagePopup.Add(OnPopupMessageCA);


if Game.IsCivEverActive(GameInfoTypes.CIVILIZATION_JAPAN) then
	function JapanReligionEnhancedUA(iPlayer, eReligion, iBelief1, iBelief2)
		-- Add Random Pantheon
		if Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION) or Players[iPlayer] == nil or not Players[iPlayer]:HasCreatedReligion() then
			return;
		end
		local pPlayer = Players[iPlayer];
		if GameInfo.Leader_Traits { LeaderType = GameInfo.Leaders[pPlayer:GetLeaderType()].Type, TraitType =
			"TRAIT_FIGHT_WELL_DAMAGED" } ()
			and (GameInfo.Traits["TRAIT_FIGHT_WELL_DAMAGED"].PrereqPolicy == nil or (GameInfo.Traits["TRAIT_FIGHT_WELL_DAMAGED"].PrereqPolicy
				and pPlayer:HasPolicy(GameInfoTypes[GameInfo.Traits["TRAIT_FIGHT_WELL_DAMAGED"].PrereqPolicy])))
		then
			local iBeliefsCount = 0;
			for i, v in ipairs(Game.GetBeliefsInReligion(eReligion)) do
				local belief = GameInfo.Beliefs[v];
				if belief ~= nil and not belief.Reformation then
					iBeliefsCount = iBeliefsCount + 1;
				end
			end
			if pPlayer:IsTraitBonusReligiousBelief() then
				iBeliefsCount = iBeliefsCount - 1;
			end
			if iBeliefsCount ~= 5 then
				return;
			end

			local availableBeliefs = {};
			for i, v in ipairs(Game.GetAvailablePantheonBeliefs()) do
				local belief = GameInfo.Beliefs[v];
				if belief ~= nil and belief.Pantheon
				then
					table.insert(availableBeliefs, belief.ID);
				end
			end

			print("Nums of available Pantheon Beliefs: " .. #availableBeliefs);
			if #availableBeliefs > 0 then
				local chooseBeliefRandNum = Game.Rand(#availableBeliefs,
					"At NewTraitEffects.lua JapanReligionEnhancedUA(), choose belief") + 1
				Game.EnhanceReligion(iPlayer, eReligion, availableBeliefs[chooseBeliefRandNum], -1);
			end
		end
	end

	GameEvents.ReligionEnhanced.Add(JapanReligionEnhancedUA);
end

-- Hun UA effects
if Game.IsCivEverActive(GameInfoTypes.CIVILIZATION_HUNS) then
	function HunDestroyCity(hexPos, playerID, cityID) --Hun will gain yield after razing a city
		local player = Players[playerID];

		if player and GameInfo.Leader_Traits { LeaderType = GameInfo.Leaders[player:GetLeaderType()].Type, TraitType =
			"TRAIT_RAZE_AND_HORSES" } ()
			and (GameInfo.Traits["TRAIT_RAZE_AND_HORSES"].PrereqPolicy == nil or (GameInfo.Traits["TRAIT_RAZE_AND_HORSES"].PrereqPolicy
				and player:HasPolicy(GameInfoTypes[GameInfo.Traits["TRAIT_RAZE_AND_HORSES"].PrereqPolicy])))
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

		if GameInfo.Leader_Traits { LeaderType = GameInfo.Leaders[NewPlayer:GetLeaderType()].Type, TraitType =
			"TRAIT_SLAYER_OF_TIAMAT" } ()
			and (GameInfo.Traits["TRAIT_SLAYER_OF_TIAMAT"].PrereqPolicy == nil or (GameInfo.Traits["TRAIT_SLAYER_OF_TIAMAT"].PrereqPolicy
				and NewPlayer:HasPolicy(GameInfoTypes[GameInfo.Traits["TRAIT_SLAYER_OF_TIAMAT"].PrereqPolicy])))
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
		if GameInfo.Leader_Traits { LeaderType = GameInfo.Leaders[player:GetLeaderType()].Type, TraitType =
			"TRAIT_LUXURY_RETENTION" } ()
			and (GameInfo.Traits["TRAIT_LUXURY_RETENTION"].PrereqPolicy == nil or (GameInfo.Traits["TRAIT_LUXURY_RETENTION"].PrereqPolicy
				and player:HasPolicy(GameInfoTypes[GameInfo.Traits["TRAIT_LUXURY_RETENTION"].PrereqPolicy])))
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
