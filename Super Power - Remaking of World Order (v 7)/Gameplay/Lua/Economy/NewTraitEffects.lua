-- New Trait and Policies
--include( "UtilityFunctions.lua" )
include("FLuaVector.lua");
include("UtilityFunctions.lua");
include("PlotIterators.lua");
-------------------------------------------------------------------------New Trait Effects-----------------------------------------------------------------------
function SpecialUnitType(iPlayerID, iUnitID)
	local pPlayer = Players[iPlayerID]
	if pPlayer == nil then return end
	local pUnit = pPlayer:GetUnitByID(iUnitID)
	if pUnit == nil then return end
	--	local ChineseGeneralID = GameInfoTypes.UNIT_CHINESE_GREAT_GENERAL
	--	local NoOceanID = GameInfo.UnitPromotions["PROMOTION_OCEAN_IMPASSABLE"].ID

	--Shoshone new UA effect
	if GameInfo.Leader_Traits { LeaderType = GameInfo.Leaders[pPlayer:GetLeaderType()].Type, TraitType = "TRAIT_GREAT_EXPANSE" }()
		and pUnit:GetUnitType() == GameInfoTypes.UNIT_SCOUT
		and (not pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GOODY_HUT_PICKER"].ID))
	then
		pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GOODY_HUT_PICKER"].ID, true)
	end

	if GameInfo.Leader_Traits { LeaderType = GameInfo.Leaders[pPlayer:GetLeaderType()].Type, TraitType = "TRAIT_GREAT_ANDEAN_ROAD" }()
		and (GameInfo.Traits["TRAIT_GREAT_ANDEAN_ROAD"].PrereqPolicy == nil or (GameInfo.Traits["TRAIT_GREAT_ANDEAN_ROAD"].PrereqPolicy
		and pPlayer:HasPolicy(GameInfoTypes[GameInfo.Traits["TRAIT_GREAT_ANDEAN_ROAD"].PrereqPolicy]))) then
		if not pUnit:IsCombatUnit() then
			pUnit:SetHasPromotion(GameInfoTypes["PROMOTION_INCA_CAN_CROSS_MOUNTAINS"], true);
			print("Inca UA: Set Unit Can Cross Mountains", iPlayerID, iUnitID);
		end
	end

	local GameSpeed = Game.GetGameSpeedType()
	local QuickGameSpeedID = GameInfo.UnitPromotions["PROMOTION_GAME_QUICKSPEED"].ID

	if GameSpeed == 3 then
		pUnit:SetHasPromotion(QuickGameSpeedID, true)
	end
end

Events.SerialEventUnitCreated.Add(SpecialUnitType)



-- Fix the "Archaeological Dig Finished" Freeze
function OnPopupMessageCA(popupInfo)
	
	local popupType = popupInfo.Type;
	if popupType ~= ButtonPopupTypes.BUTTONPOPUP_CHOOSE_ARCHAEOLOGY then
		return;
	end
	
	local iUnit = popupInfo.Data2;
	if (iUnit == nil or iUnit == -1) and Players[Game.GetActivePlayer()]:GetUnitClassCount(GameInfoTypes.UNITCLASS_ARCHAEOLOGIST) == 1 then
		for pUnit in Players[Game.GetActivePlayer()]:Units() do
			if  pUnit and pUnit:GetUnitClassType() == GameInfoTypes.UNITCLASS_ARCHAEOLOGIST
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
Events.SerialEventGameMessagePopup.Add( OnPopupMessageCA );



function JapanCultureUnit(iPlayer, iCity, iUnit, bGold, bFaith)	-- Japan can gain Culture from building units
	local pPlayer = Players[iPlayer];
	if pPlayer == nil then return end;
	local pUnit = pPlayer:GetUnitByID(iUnit);
	if pUnit == nil then return end;

---------Brazil Minas Geraes add Golden Age Points
	if pUnit:GetUnitType() == GameInfoTypes.UNIT_BRAZILIAN_MINAS_GERAES then
		pPlayer:ChangeGoldenAgeProgressMeter(280);
		print ("Brazil Minas Geraes created! Golden Age Progress Changed!");
	end

	if GameInfo.Leader_Traits{ LeaderType = GameInfo.Leaders[pPlayer:GetLeaderType()].Type, TraitType = "TRAIT_FIGHT_WELL_DAMAGED" }()
	and(GameInfo.Traits["TRAIT_FIGHT_WELL_DAMAGED"].PrereqPolicy == nil or (GameInfo.Traits["TRAIT_FIGHT_WELL_DAMAGED"].PrereqPolicy
	and pPlayer:HasPolicy(GameInfoTypes[GameInfo.Traits["TRAIT_FIGHT_WELL_DAMAGED"].PrereqPolicy]))) 
	and (pUnit:GetBaseCombatStrength() > 0 or pUnit:GetBaseRangedCombatStrength() > 0)
	then
		local currentCulture = pPlayer:GetJONSCulture();
		local BaseCulture = math.max(pUnit:GetBaseCombatStrength(), pUnit:GetBaseRangedCombatStrength());
		local bonusCulture = math.ceil(BaseCulture * 1);
		
		-- Give the culture
		pPlayer:SetJONSCulture(currentCulture + bonusCulture);

		-- Notification
		if pPlayer:IsHuman() then
			local text = Locale.ConvertTextKey( "TXT_KEY_SP_TRAIT_CULTURE_FROM_UNIT", tostring(bonusCulture), pUnit:GetName());
			Events.GameplayAlertMessage( text );
		end
	end
	
	-- Get Culture from Policy - Coastal Adminstration
	if pPlayer:HasPolicy(GameInfoTypes["POLICY_NAVIGATION_SCHOOL"]) and pUnit:GetDomainType() == DomainTypes.DOMAIN_SEA and not pUnit:IsHasPromotion(GameInfoTypes["PROMOTION_OCEAN_IMPASSABLE"]) then
		local currentCulture = pPlayer:GetJONSCulture();
		local BaseCulture = math.max(pUnit:GetBaseCombatStrength(), pUnit:GetBaseRangedCombatStrength());
		local bonusCulture = math.ceil(BaseCulture * 1);
		
		-- Give the culture
		pPlayer:SetJONSCulture(currentCulture + bonusCulture);

		-- Notification
		if pPlayer:IsHuman() then
			local text = Locale.ConvertTextKey( "TXT_KEY_SP_POLICY_CULTURE_FROM_UNIT", tostring(bonusCulture), pUnit:GetName());
			Events.GameplayAlertMessage( text );
		end
	end
end
GameEvents.CityTrained.Add(JapanCultureUnit)

function JapanReligionEnhancedUA(iPlayer, eReligion, iBelief1, iBelief2)
	-- Add Random Pantheon
	if Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION) or Players[iPlayer] == nil or not Players[iPlayer]:HasCreatedReligion() then
		return;
	end
	local pPlayer = Players[iPlayer];
	if GameInfo.Leader_Traits{ LeaderType = GameInfo.Leaders[pPlayer:GetLeaderType()].Type, TraitType = "TRAIT_FIGHT_WELL_DAMAGED" }()
	and (GameInfo.Traits["TRAIT_FIGHT_WELL_DAMAGED"].PrereqPolicy == nil or (GameInfo.Traits["TRAIT_FIGHT_WELL_DAMAGED"].PrereqPolicy
	and pPlayer:HasPolicy(GameInfoTypes[GameInfo.Traits["TRAIT_FIGHT_WELL_DAMAGED"].PrereqPolicy]))) 
	then
		local iBeliefsCount = 0;
		for i,v in ipairs(Game.GetBeliefsInReligion(eReligion)) do
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
		for i,v in ipairs(Game.GetAvailablePantheonBeliefs()) do
			local belief = GameInfo.Beliefs[v];
			if belief ~= nil and belief.Pantheon
			then
				table.insert(availableBeliefs, belief.ID);
			end
		end
		
		print("Nums of available Pantheon Beliefs: " .. #availableBeliefs);
		if #availableBeliefs > 0 then
			local chooseBeliefRandNum = Game.Rand(#availableBeliefs, "At NewTraitEffects.lua JapanReligionEnhancedUA(), choose belief") + 1
			Game.EnhanceReligion(iPlayer, eReligion, availableBeliefs[chooseBeliefRandNum], -1);
		end
	end
end
GameEvents.ReligionEnhanced.Add(JapanReligionEnhancedUA);



function HunDestroyCity(hexPos,playerID,cityID)--Hun will gain yield after razing a city
	local player = Players[playerID];
	
	if player and GameInfo.Leader_Traits{ LeaderType = GameInfo.Leaders[player:GetLeaderType()].Type, TraitType = "TRAIT_RAZE_AND_HORSES" }()
	and(GameInfo.Traits["TRAIT_RAZE_AND_HORSES"].PrereqPolicy == nil or (GameInfo.Traits["TRAIT_RAZE_AND_HORSES"].PrereqPolicy 
	and player:HasPolicy(GameInfoTypes[GameInfo.Traits["TRAIT_RAZE_AND_HORSES"].PrereqPolicy])))
	then
		print ("Hun City Razed!")
		
		local CurrentTurn = Game.GetGameTurn();
		local Output = 10 * CurrentTurn;
		if Output > 1000 then
			Output = 1000;
		end
		
		print ("Output:"..Output);
		
		player:ChangeJONSCulture(Output);
		player:ChangeGold(Output);
		player:ChangeFaith(Output);
		
		local team = Teams[player:GetTeam()];
		local teamTech = team:GetTeamTechs();
		local iCurrentTech = player:GetCurrentResearch();
		-- Avoid Crash if a Tech is finished right now
		if teamTech == nil or iCurrentTech == -1 then
			print ("no Tech under researching");
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
			local text = Locale.ConvertTextKey( "TXT_KEY_SP_NOTIFICATION_TRAIT_OUTPUT_FROM_RAZING", tostring(Output))
			Events.GameplayAlertMessage( text )
		end
	end

end
Events.SerialEventCityDestroyed.Add (HunDestroyCity)






----Reddit to avoid triggering when getting city peacefully---By HMS
function AssyriaCityCapture(oldPlayerID, bIsCapital, iX, iY, newPlayerID, bConquest, iGreatWorksPresent, iGreatWorksXferred)-- Assyria gain population after capturing cities
	print("conquested")
	local NewPlayer = Players[newPlayerID]
	local pPlot = Map.GetPlot(iX, iY)
	local pCity = pPlot:GetPlotCity()
	local OldPlayer = Players[oldPlayerID]
	if NewPlayer == nil or OldPlayer == nil then
		print ("No players")
		return
	end 
	
	if not PlayersAtWar(NewPlayer, OldPlayer) then 
		print("trading city is not availiable for assyria'ua")
		return
	end
	
	if GameInfo.Leader_Traits{ LeaderType = GameInfo.Leaders[NewPlayer:GetLeaderType()].Type, TraitType = "TRAIT_SLAYER_OF_TIAMAT" }()
	and(GameInfo.Traits["TRAIT_SLAYER_OF_TIAMAT"].PrereqPolicy == nil or (GameInfo.Traits["TRAIT_SLAYER_OF_TIAMAT"].PrereqPolicy 
	and NewPlayer:HasPolicy(GameInfoTypes[GameInfo.Traits["TRAIT_SLAYER_OF_TIAMAT"].PrereqPolicy])))
	then
		print("Assyria Militarily conquested a city")
		if pCity:GetPopulation() > 4 and NewPlayer:GetCapitalCity() ~= nil then
			print ("Assyria can plunder population!")
			local pCapital = NewPlayer:GetCapitalCity()
			pCapital:ChangePopulation(1,true)
			
			-- Notification
			local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_ASSYRIA_POPULATION", pCapital:GetName())
			local heading = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_ASSYRIA_POPULATION_SHORT")
			NewPlayer:AddNotification(NotificationTypes.NOTIFICATION_CITY_GROWTH, text, heading, iX, iY)
		end
	end
end
GameEvents.CityCaptureComplete.Add(AssyriaCityCapture)


-- Austria Set "Old Capital" Building for Annexed CityState
function AustriaAnnexCityState(oldPlayerID, bIsCapital, iX, iY, newPlayerID, bConquest, iGreatWorksPresent, iGreatWorksXferred)
	local NewPlayer = Players[newPlayerID];
	local pPlot = Map.GetPlot(iX, iY);
	local pCity = pPlot:GetPlotCity();
	if NewPlayer == nil or newPlayerID == oldPlayerID or pCity == nil or not pCity:IsOriginalCapital()
	or not Players[pCity:GetOriginalOwner()]:IsMinorCiv()
	then
		return;
	end
	
	--[[
	if Players[oldPlayerID] and not Teams[NewPlayer:GetTeam()]:IsAtWar(Players[oldPlayerID]:GetTeam()) then
		-- pCity:SetOccupied(false);
		if pCity:IsResistance() then
			pCity:ChangeResistanceTurns( - pCity:GetResistanceTurns() );
		end
	end
	]]
	
	if NewPlayer:IsAbleToAnnexCityStates() then
		pCity:SetNumRealBuilding( GameInfoTypes["BUILDING_OLD_CAPITAL_OF_CITYSTATE"], 1 );
		print("Austria Annex City State!");
	end
end
GameEvents.CityCaptureComplete.Add(AustriaAnnexCityState)


--[[
--function PortugalBuildFeitoria(iHexX, iHexY, PlayerID, ImprovementType)
--	local pPlayer = Players[PlayerID]
--	
--	if ImprovementType == GameInfo.Improvements.IMPROVEMENT_FEITORIA.ID
--	and GameInfo.Leader_Traits{ LeaderType = GameInfo.Leaders[pPlayer:GetLeaderType()].Type, TraitType = "TRAIT_EXTRA_TRADE" }()
	and(GameInfo.Traits["TRAIT_EXTRA_TRADE"].PrereqPolicy == nil or (GameInfo.Traits["TRAIT_EXTRA_TRADE"].PrereqPolicy 
	and pPlayer:HasPolicy(GameInfoTypes[GameInfo.Traits["TRAIT_EXTRA_TRADE"].PrereqPolicy])))
	then
--	   	print ("Portugal Build a Feitoria!")
--	   	local GAThreshold = pPlayer:GetGoldenAgeProgressThreshold()
--	   	print ("GoldenAgeProgressThreshold:"..GAThreshold)
--	   	local GAmod = 0.25 * GAThreshold
--	   	pPlayer:ChangeGoldenAgeProgressMeter(GAmod)
--	   	print ("Done!")
--	end
--end
--Events.SerialEventImprovementCreated.Add(PortugalBuildFeitoria)
--]]


----------Remove wrong starting units ---Some civs will have their old UU due to StartingDefenseUnits
function StartingUnitCorrection( playerID, unitID )
	-- Only the first 6s!
	if Game.GetMinutesPlayed() > 0.1 then
		return;
	end
	if( Players[ playerID ] == nil or
	Players[ playerID ]:GetUnitByID( unitID ) == nil or
	Players[ playerID ]:GetUnitByID( unitID ):IsDead() )
	then
		return;
	end
	
	local pPlayer = Players[ playerID ];
	local pUnit   = pPlayer:GetUnitByID( unitID );
	if (pUnit:GetUnitType() == GameInfoTypes.UNIT_AZTEC_JAGUAR
	and not Teams[pPlayer:GetTeam()]:IsHasTech(GameInfoTypes["TECH_STEEL"]))
	or (pUnit:GetUnitType() == GameInfoTypes.UNIT_POLYNESIAN_MAORI_WARRIOR
	and not Teams[pPlayer:GetTeam()]:IsHasTech(GameInfoTypes["TECH_IRON_WORKING"]))
	then
		pPlayer:InitUnit(GameInfoTypes.UNIT_WARRIOR, pUnit:GetX(), pUnit:GetY(),UNITAI_DEFENSE);
		pUnit:Kill();
		print ("This UU isn't the correct 'warrior' as the starting unit!")
	end
end
Events.SerialEventUnitCreated.Add(StartingUnitCorrection)



function SPTraitsTech(iTeam, eTech, bAdopted)
	local Team = Teams[iTeam]
	if Team == nil then
		return
	end
	
	-- Nederland Set Buildings
	local player = Players[Team:GetLeaderID()];
	if player == nil or player:IsMinorCiv() or player:IsBarbarian() then
	 	return
	end
	if GameInfo.Leader_Traits{ LeaderType = GameInfo.Leaders[player:GetLeaderType()].Type, TraitType = "TRAIT_LUXURY_RETENTION" }()
	and(GameInfo.Traits["TRAIT_LUXURY_RETENTION"].PrereqPolicy == nil or (GameInfo.Traits["TRAIT_LUXURY_RETENTION"].PrereqPolicy 
	and player:HasPolicy(GameInfoTypes[GameInfo.Traits["TRAIT_LUXURY_RETENTION"].PrereqPolicy])))
	then
		if     eTech == GameInfoTypes["TECH_ELECTRONICS"] then
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
GameEvents.TeamSetHasTech.Add(SPTraitsTech)

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

	GameEvents.TeamSetHasTech.Add(function(iTeam, eTech, bAdopted)
		if not (bAdopted and eTech == GameInfoTypes.TECH_INDUSTRIALIZATION) then
			return;
		end

		for playerID, pPlayer in pairs(Players) do
			if pPlayer:GetTeam() == iTeam and pPlayer:GetCivilizationType() == GameInfoTypes.CIVILIZATION_RUSSIA then
				local capital = pPlayer:GetCapitalCity();
				capital:SetNumRealBuilding(GameInfoTypes.BUILDING_TB_STRATEGIC_RICHES_IDEOLOGY, 1);
				print("Russia: Strategic Riches ideology building added to capital");
			end
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

  print ("New Trait Effect Check Pass!")  