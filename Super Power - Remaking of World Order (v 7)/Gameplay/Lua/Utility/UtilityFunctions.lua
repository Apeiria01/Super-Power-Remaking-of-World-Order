-- UtilityFunctions
-- Author: linco
-- DateCreated: 2/13/2016 11:16:01 AM
--------------------------------------------------------------


-------------If two players are AT WAR?

function PlayersAtWar(iPlayer,ePlayer)
	local iTeam = Teams[iPlayer:GetTeam()];
	local eTeamIndex = ePlayer:GetTeam();
	if iTeam:IsAtWar(eTeamIndex) then
		return true;
	else
		return false;
	end
end


---------If the AI player is at war with Human?

function PlayerAtWarWithHuman(player)
	local CurrentPlayerTeam = Teams[player:GetTeam()]
	local IsWarWithHuman = false;
	
	for playerID,HumanPlayer in pairs(Players) do
		if IsWarWithHuman then
			break;
		end
		if HumanPlayer:IsHuman() and CurrentPlayerTeam:IsAtWar(HumanPlayer:GetTeam()) then
			print ("Human is at war with this AI!")
			IsWarWithHuman = true;
		end
	end
	return IsWarWithHuman;
end





---------If the AI has the chance to become the Boss?
function AICanBeBoss (player)

local WorldCityTotal = Game.GetNumCities() 
local WorldPopTotal = Game.GetTotalPopulation()

local AICityCount = player:GetNumCities()
local AIPopCount = player:GetTotalPopulation()
local MajorCivNum=0
for id, pPlayer in pairs(Players) do
	if pPlayer:IsEverAlive() then
		if not (pPlayer:IsMinorCiv() or pPlayer:IsBarbarian()) then 
			MajorCivNum=MajorCivNum+1
		end
	end
end
print("total civ is: "..MajorCivNum)

--local playerID = player:GetID()

--print ("World Cities Count:"..WorldCityTotal)
--print ("World Population Count:"..WorldPopTotal)
--

	if player:IsHuman() or player:IsBarbarian() or player:IsMinorCiv() then
		return false
	end
	
	local CapitalDistance = 0;
	local WorldSizeLength = Map.GetGridSize();
	if  Players[Game.GetActivePlayer()] ~= nil and Players[Game.GetActivePlayer()]:GetCapitalCity() ~= nil and player:GetCapitalCity() ~= nil then
		local HumanCapital  = Players[Game.GetActivePlayer()]:GetCapitalCity();
		local ThisAICapital = player:GetCapitalCity();
		CapitalDistance =  Map.PlotDistance(HumanCapital:GetX(), HumanCapital:GetY(), ThisAICapital:GetX(), ThisAICapital:GetY())
	end
	if AICityCount >= 15 or AICityCount >= WorldCityTotal/MajorCivNum or AIPopCount >= WorldPopTotal/MajorCivNum or CapitalDistance >= WorldSizeLength/3 then
		print ("This AI can become a Boss!")
		return true
	else	
		return false
	end
end




--
-----------Are the two players in different continents?
--function PlayersInDifferentContinets (iPlayer,pPlayer)
--
--
--
--
--end

-----------------------------------------------Plot Functions------------------------------------------------------


function PlotIsVisibleToHuman(plot) --------------------Is the plot can be seen by Human
	for playerID,HumanPlayer in pairs(Players) do
		if HumanPlayer:IsHuman() then
		   local HumanPlayerTeamIndex = HumanPlayer:GetTeam()
		   if plot:IsVisible(HumanPlayerTeamIndex) then
		   
--		   	    print ("Human can see this plot! So stop Cheating!")	
		   		return true
			else
--				print ("Human CANNOT see this plot! Let's Cheat!")
			    return false
			end
			
			break
		   
		end
	end
end





function isFriendlyCity(pUnit, pCity)--------------Is the plot a Friendly City?
	  local bFriendly = (pCity:GetTeam() == pUnit:GetTeam())
	--  bFriendly = (bFriendly and not pCity:IsPuppet())
	  bFriendly = (bFriendly and not pCity:IsResistance())
	  bFriendly = (bFriendly and not pCity:IsRazing())
	  bFriendly = (bFriendly and not (pCity:IsOccupied() and not pCity:IsNoOccupiedUnhappiness()))
	  return bFriendly
end






------------------------------------------------Military/Unit Functions------------------------------------------------------





function GetCivSpecificUnit(player, sUnitClass)
	  local sUnitType = -1
	  local sCivType = GameInfo.Civilizations[player:GetCivilizationType()].Type
	
	  for pOverride in GameInfo.Civilization_UnitClassOverrides{CivilizationType = sCivType, UnitClassType = sUnitClass} do
	    sUnitType = pOverride.UnitType
	    break
	  end
	
	  if sUnitType == -1 or sUnitType == nil then
	     sUnitType = GameInfo.UnitClasses[sUnitClass].DefaultUnit
	  end
	
	  return sUnitType
end



function GetUpgradeUnit(player, sUnitType)
	  local sNewUnitClass = GameInfo.Units[sUnitType].GoodyHutUpgradeUnitClass
	
	  if (sNewUnitClass ~= nil) then
	    local sUpgradeUnitType = GetCivSpecificUnit(player, sNewUnitClass)
	
	    if (sUpgradeUnitType ~= nil and Teams[player:GetTeam()]:IsHasTech(GameInfoTypes[GameInfo.Units[sUpgradeUnitType].PrereqTech])) then
	      return sUpgradeUnitType
	    end
	  end
	
	  return nil
end





--
--function GetUnitPurchaseGoldCost(player, unitID)
--	if player == nil or unitID == nil then
--		return
--	end	
--	
--	local sUnitType = GetCivSpecificUnit(player, unitID)   	
--    local sUpgradeUnitType = GetUpgradeUnit(player, sUnitType)
--	
--	
--	local unit = GameInfo.Units[sUnitType]
--	
--	local productionCost = unit.Cost
--	if productionCost > 1 then	
--		local UnitGoldCost = (productionCost * GameDefines.GOLD_PURCHASE_GOLD_PER_PRODUCTION ) ^ GameDefines.HURRY_GOLD_PRODUCTION_EXPONENT
--		print ("Unit Gold Cost:"..UnitGoldCost)
--	end
--	return UnitGoldCost
--end
--


function SatelliteLaunchEffects(unit,city,player)
	if unit == nil or city == nil or player == nil or player:GetNumCities() == 0
	or not unit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_SATELLITE_UNIT"].ID)
	then
		return
	end
	
	if unit:GetUnitClassType() == GameInfoTypes.UNITCLASS_SATELLITE_SPUTNIK then
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_SATELLITE_SPUTNIK"],1)
	elseif unit:GetUnitClassType() == GameInfoTypes.UNITCLASS_SATELLITE_RECONNAISSANCE then
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_SATELLITE_RECONNAISSANCE"],1)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_SATELLITE_RECONNAISSANCE_SMALL"],1)
	elseif unit:GetUnitClassType() == GameInfoTypes.UNITCLASS_SATELLITE_GPS then
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_SATELLITE_GPS"],1)
	elseif unit:GetUnitClassType() == GameInfoTypes.UNITCLASS_SATELLITE_APOLLO11 then
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_SATELLITE_APOLLO11"],1)
	elseif unit:GetUnitClassType() == GameInfoTypes.UNITCLASS_SATELLITE_HUBBLE then
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_HUBBLE"],1)
		player:InitUnit(GameInfoTypes.UNIT_SCIENTIST, city:GetX(), city:GetY(), UNITAI_SCIENTIST):JumpToNearestValidPlot()
	elseif unit:GetUnitClassType() == GameInfoTypes.UNITCLASS_SATELLITE_WEATHER then
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_SATELLITE_WEATHER"],1)
	elseif unit:GetUnitClassType() == GameInfoTypes.UNITCLASS_SATELLITE_TIANGONG then
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_SATELLITE_TIANGONG"],1)
	elseif unit:GetUnitClassType() == GameInfoTypes.UNITCLASS_SATELLITE_ECCM then
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_SATELLITE_ECCM"],1)
	elseif unit:GetUnitClassType() == GameInfoTypes.UNITCLASS_SATELLITE_ENVIRONMENT then
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_SATELLITE_ENVIRONMENT"],1)
	elseif unit:GetUnitClassType() == GameInfoTypes.UNITCLASS_SATELLITE_ANTIFALLOUT then
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_SATELLITE_ANTIFALLOUT"],1)
	elseif unit:GetUnitClassType() == GameInfoTypes.UNITCLASS_SATELLITE_RESOURCEPLUS then
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_SATELLITE_RESOURCEPLUS"],1)
	elseif unit:GetUnitClassType() == GameInfoTypes.UNITCLASS_SATELLITE_SPACE_ELEVATOR then
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_SPACE_ELEVATOR"],1)
	elseif unit:GetUnitClassType() == GameInfoTypes.UNITCLASS_SATELLITE_ORBITAL_STRIKE then
		player:InitUnit(GameInfo.Units.UNIT_ORBITAL_STRIKE.ID, city:GetX(), city:GetY(),UNITAI_MISSILE_AIR)
		print ("Rods from God built!")
	end
	
	SatelliteEffectsGlobal(unit);
	
	print ("Satellite unit's effect is ON!")
	
end-----------function END




function SatelliteEffectsGlobal(unit)

	if not unit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_SATELLITE_UNIT"].ID) then 
		return 
	end


	if unit:GetUnitClassType() == GameInfoTypes.UNITCLASS_SATELLITE_WEATHER then
		print ("Satellite Effects Global:Weather Control!")
		for plotLoop = 0, Map.GetNumPlots() - 1, 1 do
			local plot = Map.GetPlotByIndex(plotLoop)		
		
			if plot:GetFeatureType() == FeatureTypes.NO_FEATURE and not plot:IsHills() and not plot:IsMountain() then
				if plot:GetTerrainType() == TerrainTypes.TERRAIN_DESERT then
					local pPlotX = plot:GetX()
					local pPlotY = plot:GetY()
					Game.SetPlotExtraYield(pPlotX, pPlotY, GameInfoTypes.YIELD_FOOD, 2)
				end	
			end	
		end	
		
	elseif unit:GetUnitClassType() == GameInfoTypes.UNITCLASS_SATELLITE_ENVIRONMENT then
		print ("Satellite Effects Global:Environment Transform!")
		for plotLoop = 0, Map.GetNumPlots() - 1, 1 do
			local plot = Map.GetPlotByIndex(plotLoop)		
	
		
			if plot:GetTerrainType() == TerrainTypes.TERRAIN_TUNDRA then
				if plot:GetFeatureType() == FeatureTypes.NO_FEATURE and not plot:IsHills() and not plot:IsMountain() then
					local pPlotX = plot:GetX()
					local pPlotY = plot:GetY()
					Game.SetPlotExtraYield(pPlotX, pPlotY, GameInfoTypes.YIELD_PRODUCTION, 1)
				end	
			end	
			
			if plot:GetTerrainType() == TerrainTypes.TERRAIN_SNOW and not plot:IsMountain() then
				local pPlotX = plot:GetX()
				local pPlotY = plot:GetY()
				if plot:IsHills() then 
					Game.SetPlotExtraYield(pPlotX, pPlotY, GameInfoTypes.YIELD_PRODUCTION, 2)
				else	
					Game.SetPlotExtraYield(pPlotX, pPlotY, GameInfoTypes.YIELD_PRODUCTION, 1)
					Game.SetPlotExtraYield(pPlotX, pPlotY, GameInfoTypes.YIELD_FOOD, 1)	
				end			
			end	
				
		end	
		
		

	elseif unit:GetUnitClassType() == GameInfoTypes.UNITCLASS_SATELLITE_ANTIFALLOUT then
		print ("Satellite Effects Global:Remove Fallout!")
		for plotLoop = 0, Map.GetNumPlots() - 1, 1 do
			local plot = Map.GetPlotByIndex(plotLoop)		

			if plot:GetFeatureType() == FeatureTypes.FEATURE_FALLOUT then
				plot:SetFeatureType(-1)
			end	
		end	
	

	elseif unit:GetUnitClassType() == GameInfoTypes.UNITCLASS_SATELLITE_RESOURCEPLUS then
		print ("Satellite Effects Global:Resource Bonus")
		for plotLoop = 0, Map.GetNumPlots() - 1, 1 do
			local plot = Map.GetPlotByIndex(plotLoop)		

			if plot:GetNumResource() >= 2 and not plot:IsCity() then
				-- If you only change the resource amount on the plot, the player's resource quantity will not change! You must remove then add the improvement to make the change!
				local iImprovement = plot:GetImprovementType()
				plot:SetImprovementType (-1)
				plot:ChangeNumResource (4)
				plot:SetImprovementType (iImprovement)
			end
		end

	elseif unit:GetUnitClassType() == GameInfoTypes.UNITCLASS_SATELLITE_GPS or unit:GetUnitClassType() == GameInfoTypes.UNITCLASS_SATELLITE_RECONNAISSANCE or unit:GetUnitClassType() == GameInfoTypes.UNITCLASS_SATELLITE_APOLLO11 or unit:GetUnitClassType() == GameInfoTypes.UNITCLASS_SATELLITE_HUBBLE or unit:GetUnitClassType() == GameInfoTypes.UNITCLASS_SATELLITE_TIANGONG then 
		
		for playerID,player in pairs(Players) do
			if player:GetNumCities() > 0 and not player:IsMinorCiv() and not player:IsBarbarian() then  
				print ("Satellite Effects Global:Effects!")
				local CapitalCity = player:GetCapitalCity()
				print ("Find Capital")
				if unit:GetUnitClassType() == GameInfo.UnitClasses.UNITCLASS_SATELLITE_GPS.ID then
					CapitalCity:SetNumRealBuilding(GameInfoTypes["BUILDING_SATELLITE_GPS_SMALL"],1)
				elseif unit:GetUnitClassType() == GameInfo.UnitClasses.UNITCLASS_SATELLITE_RECONNAISSANCE.ID then
					CapitalCity:SetNumRealBuilding(GameInfoTypes["BUILDING_SATELLITE_RECONNAISSANCE_SMALL"],1)	
				elseif unit:GetUnitClassType() == GameInfo.UnitClasses.UNITCLASS_SATELLITE_APOLLO11.ID then
					print ("Free Tech for everyone!")
					player:SetNumFreeTechs(1)
					
				elseif unit:GetUnitClassType() == GameInfo.UnitClasses.UNITCLASS_SATELLITE_HUBBLE.ID then
					local pPlot = CapitalCity
					local NewUnit = player:InitUnit(GameInfoTypes.UNIT_SCIENTIST, pPlot:GetX(), pPlot:GetY(), UNITAI_SCIENTIST)
	   				NewUnit:JumpToNearestValidPlot()
	   			elseif unit:GetUnitClassType() == GameInfo.UnitClasses.UNITCLASS_SATELLITE_TIANGONG.ID then
					local pPlot = CapitalCity
					local NewUnit = player:InitUnit(GameInfoTypes.UNIT_ENGINEER, pPlot:GetX(), pPlot:GetY(), UNITAI_ENGINEER)
	   				NewUnit:JumpToNearestValidPlot()
				end
			end
		end	
	end
	
	
	
end-----------function END






----------------------------------City Functions----------------------------





------------Happiness Effects
function SetHappinessEffects(playerID)
	if Players[playerID] == nil or Players[playerID]:GetNumCities() == 0 then
		return;
	end
	local player = Players[playerID];
	local ExcessHappiness = math.max(0, player:GetExcessHappiness());
	local HappinessRatio = math.floor(ExcessHappiness/(player:GetNumCities()*5));
	print ("Happiness to Tourism Ratio (5 times):"..HappinessRatio)
	if HappinessRatio > 0 or player:GetBuildingClassCount( GameInfoTypes["BUILDINGCLASS_HAPPINESS_TOURISMBOOST"] ) > 0 then
		for city in player:Cities() do
			city:SetNumRealBuilding( GameInfoTypes["BUILDING_HAPPINESS_TOURISMBOOST"],HappinessRatio )
			print ("Excess Happiness add to Tourism!")
		end
	end
	
	if player:GetCapitalCity() == nil then
		return;
	end
	local CaptialCity = player:GetCapitalCity();
	
	local HappinesstoScienceRatio = math.floor(ExcessHappiness/25)
	local MaxHappinesstoScienceRatio = 0;
	if player:HasPolicy(GameInfo.Policies["POLICY_RATIONALISM"].ID) then
		MaxHappinesstoScienceRatio = 10;
	end
	if player:HasPolicy(GameInfo.Policies["POLICY_TREATY_ORGANIZATION"].ID) then
		MaxHappinesstoScienceRatio = MaxHappinesstoScienceRatio + 10;
	end
	
	local FinalHappinesstoScienceRatio = math.min(MaxHappinesstoScienceRatio, HappinesstoScienceRatio);
	if FinalHappinesstoScienceRatio ~= CaptialCity:GetNumBuilding(GameInfoTypes["BUILDING_RATIONALISM_HAPPINESS"]) then
		CaptialCity:SetNumRealBuilding(GameInfoTypes["BUILDING_RATIONALISM_HAPPINESS"],FinalHappinesstoScienceRatio)
		print ("Happiness to Science!"..FinalHappinesstoScienceRatio)
	end
end-------------Function End









---------------------Policy Per Turn Effects
function SetPolicyPerTurnEffects(playerID)
	local player = Players[playerID];
	local pCity = player:GetCapitalCity();
	
	if pCity then
		if player:HasPolicy(GameInfoTypes["POLICY_RELIGIOUS_POLITICS"]) then
			local FaithGained = player:GetTotalFaithPerTurn()
			local FaithToHappiness = math.floor(0.1 * FaithGained)
			print ("Player Faith to Happiness per Turn:"..FaithToHappiness)
			if FaithToHappiness > 0 then
				pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_FAITH_RELIGIOUS_POLITICS"],FaithToHappiness)
			else
				pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_FAITH_RELIGIOUS_POLITICS"],0)
			end
		end
		
		
		if player:HasPolicy(GameInfoTypes["POLICY_CAPITALISM"]) then
		   local iUsedTradeRoutes = player:GetNumInternationalTradeRoutesUsed()
		   if iUsedTradeRoutes > 0 then
			print ("Science from International Trade Route:"..iUsedTradeRoutes)
			pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_TRADE_TO_SCIENCE"],iUsedTradeRoutes)
		   else
			pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_TRADE_TO_SCIENCE"],0)
		   end
		end
		
	end
end





if (PreGame.GetGameOption("GAMEOPTION_SP_IMMIGRATION_OFF") == 1) then
	print("International Immigration - OFF!");
else
-----------International Immigration Counter Check
    function CheckMoveOutCounter(HumanPlayerID, AIPlayerID)

	local HumanPlayer = Players[HumanPlayerID];
	local AIPlayer = Players[AIPlayerID];
	
	if HumanPlayer == nil or AIPlayer == nil then
		print ("No players");
		return;
	end
	
	print ("Human Player: " .. tostring(HumanPlayer:GetName()));
	print ("AI Player: " .. tostring(AIPlayer:GetName()));
	
	local iRegressand = 200;
	if     Game.GetGameSpeedType() == 0 then	-- GAMESPEED_MARATHON
		iRegressand = 800;
	elseif Game.GetGameSpeedType() == 1 then	-- GAMESPEED_EPIC
		iRegressand = 400;
	elseif Game.GetGameSpeedType() == 2 then	-- GAMESPEED_STANDARD
		iRegressand = 200;
	elseif Game.GetGameSpeedType() == 3 then	-- GAMESPEED_QUICK
		iRegressand = 100;
	end
	
	local iCountBuildingID = GameInfoTypes["BUILDING_IMMIGRATION_" .. tostring(HumanPlayerID)];
	if iCountBuildingID == -1 or nil then
		print ("No CountBuilding");
		return;
	end
	iCount = AIPlayer:CountNumBuildings(iCountBuildingID);
	
	local MoveOutTeam, MoveInTeam;

	local MoveOutCounterBase = HumanPlayer:GetInfluenceLevel(AIPlayerID) - AIPlayer:GetInfluenceLevel(HumanPlayerID);
	local MoveOutCounterMod  = 1;
	
	print ("Move Out Counter by the Influence Base: "..MoveOutCounterBase);
	
	local MoveInPlayer  = nil;
	local MoveOutPlayer = nil;
	if     MoveOutCounterBase > 0 then
		MoveOutPlayer = AIPlayer;
		MoveInPlayer  = HumanPlayer;
	elseif MoveOutCounterBase < 0 then
		MoveOutPlayer = HumanPlayer;
		MoveInPlayer  = AIPlayer
	end
	
	if MoveInPlayer == nil then
		return {MoveOutCounterBase, iRegressand, iCount};
	else
		MoveOutTeam = Teams[MoveOutPlayer:GetTeam()];
		MoveInTeam  = Teams[MoveInPlayer:GetTeam()];
	end
	
------------------------------------------Player is not able to accept----------------------
	
	
	if MoveInPlayer:GetExcessHappiness() <= 0 or MoveInPlayer:GetNumResourceAvailable(GameInfoTypes["RESOURCE_CONSUMER"], true) <= 0  then
		MoveOutCounterBase = 0
		print ("The Player is unhappy or No Resources! "..MoveOutCounterBase)
	end
	
	if MoveInPlayer:GetCurrentEra() >= GameInfo.Eras["ERA_MODERN"].ID and MoveInPlayer:GetNumResourceAvailable(GameInfoTypes["RESOURCE_ELECTRICITY"], true) <= 0  then
		MoveOutCounterBase = 0
		print ("The Player is lacking of ELECTRICITY! "..MoveOutCounterBase)
	end
	
	
------------------------------------------Diplomacy Modifier--------------------------------
	if PlayersAtWar(MoveOutPlayer,MoveInPlayer) then
		MoveOutCounterBase = 0 
		print ("At War! No Immigration: "..MoveOutCounterBase)
	end
	
	if MoveInTeam:IsAllowsOpenBordersToTeam(MoveOutPlayer:GetTeam()) then
		MoveOutCounterMod = MoveOutCounterMod + 1
		print ("Open Borders +100% "..MoveOutCounterMod)
	end
		
	if MoveOutPlayer:IsDenouncedPlayer(MoveInPlayerID) or MoveInPlayer:IsDenouncedPlayer(MoveOutPlayerID) then
		MoveOutCounterMod = MoveOutCounterMod -0.5
		print ("Denouncing! -50% "..MoveOutCounterMod)
	end
	
	if MoveOutPlayer:IsDoF(MoveInPlayerID) then
		MoveOutCounterMod = MoveOutCounterMod + 0.5
		print ("DOF! +50% "..MoveOutCounterMod)
	end
	
	
------------------------------------------Religion Modifier---------------------------------
	if MoveInPlayer:GetReligionCreatedByPlayer() ~= nil and MoveInPlayer:GetReligionCreatedByPlayer() > 0 then
		local MoveInPlayerReligion = MoveInPlayer:GetReligionCreatedByPlayer()
--		print ("MoveInPlayerReligion:  "..MoveInPlayerReligion)
		if MoveOutPlayer:HasReligionInMostCities(MoveInPlayerReligion) then
			MoveOutCounterMod = MoveOutCounterMod + 1
			print ("Same Religion +100%  "..MoveOutCounterMod)
		end
	end
	
	
------------------------------------------Happiness Modifier--------------------------------
	if MoveInPlayer:IsHuman() then

		if     MoveInPlayer:GetExcessHappiness() >=150 then
			MoveOutCounterMod = MoveOutCounterMod + 0.5
		elseif MoveInPlayer:GetExcessHappiness() < 150 and MoveInPlayer:GetExcessHappiness() >= 100 then
			MoveOutCounterMod = MoveOutCounterMod + 0.25
		elseif MoveInPlayer:GetExcessHappiness() <  50 and MoveInPlayer:GetExcessHappiness() >=  20 then
			MoveOutCounterMod = MoveOutCounterMod - 0.25
		elseif MoveInPlayer:GetExcessHappiness() <  20 and MoveInPlayer:GetExcessHappiness() >=   0 then
			MoveOutCounterMod = MoveOutCounterMod - 0.5
		elseif MoveInPlayer:GetExcessHappiness() <   0 then
			MoveOutCounterMod = 0
		end
		
		print ("Human Move in Special Mod  "..MoveOutCounterMod)
	end
	
	
	if MoveOutPlayer:IsHuman() then
		
		if     MoveOutPlayer:GetExcessHappiness() >=150 then
			MoveOutCounterMod = MoveOutCounterMod - 0.5
		elseif MoveOutPlayer:GetExcessHappiness() < 150 and MoveOutPlayer:GetExcessHappiness() >= 100 then
			MoveOutCounterMod = MoveOutCounterMod - 0.25
		elseif MoveOutPlayer:GetExcessHappiness() <  20 and MoveOutPlayer:GetExcessHappiness() >=   0 then
			MoveOutCounterMod = MoveOutCounterMod + 0.25
		elseif MoveOutPlayer:GetExcessHappiness() <   0 then
			MoveOutCounterMod = MoveOutCounterMod + 0.5
		end	
		
		print ("Human Move out Special Mod  "..MoveOutCounterMod)
	end
	
	
------------------------------------------Ideology Modifier-------------------------------- 
--	if MoveOutPlayer:GetCurrentEra() >= 5 then
--		local MoveOutIdeology = MoveOutPlayer:GetLateGamePolicyTree()
--	    local MoveInIdeology = MoveInPlayer:GetLateGamePolicyTree()
--	    local PreferedIdeology = MoveOutPlayer:GetPublicOpinionPreferredIdeology()
--	    
--	    if MoveOutIdeology == MoveInIdeology then
--	    	MoveOutCounterMod = MoveOutCounterMod + 0.25
--	    	print ("Same Ideology +25%  "..MoveOutCounterMod)
--	    else
--	    	if PreferedIdeology > -1 and PreferedIdeology == MoveInIdeology then
--	    		MoveOutCounterMod = MoveOutCounterMod
--	    		print ("Different Ideology but preferred -25%  "..MoveOutCounterMod)
--	    	else
--	    		MoveOutCounterMod = MoveOutCounterMod - 0.25
--	    		print ("Different Ideology -25%  "..MoveOutCounterMod)
--	    	end
--	    end
--	end
	
	if MoveOutPlayer:HasPolicy(GameInfoTypes["POLICY_IRON_CURTAIN"]) then
		MoveOutCounterMod = MoveOutCounterMod - 0.5
		print ("Internationalism -50%  "..MoveOutCounterMod)
	end
	
	if MoveInPlayer:HasPolicy(GameInfoTypes["POLICY_TREATY_ORGANIZATION"]) then
		MoveOutCounterMod = MoveOutCounterMod + 1.0
		print ("Beacon of Democracy +100%  "..MoveOutCounterMod)
	end
	
	
------------------------------------------Trait Modifier------------------------------------
	if  MoveInPlayer:GetExcessHappiness() > MoveOutPlayer:GetExcessHappiness()
	and GameInfo.Leader_Traits{ LeaderType = GameInfo.Leaders[MoveInPlayer:GetLeaderType()].Type, TraitType = "TRAIT_RIVER_EXPANSION" }()
	and(GameInfo.Traits["TRAIT_RIVER_EXPANSION"].PrereqPolicy == nil or (GameInfo.Traits["TRAIT_RIVER_EXPANSION"].PrereqPolicy 
	and MoveInPlayer:HasPolicy(GameInfoTypes[GameInfo.Traits["TRAIT_RIVER_EXPANSION"].PrereqPolicy])))
	then
		MoveOutCounterMod = MoveOutCounterMod + 0.5
		print ("American UA to Civilizations with less Happiness +50%  "..MoveOutCounterMod)
	end
	
	
--------------------------------------------------------------------------------------------
	
	
	if MoveOutCounterMod < 0 then
		MoveOutCounterMod = 0
	end
	
	local MoveoutCounterFinal = math.floor(MoveOutCounterMod * MoveOutCounterBase)
	
	
	print ("MoveoutCounterFinal:"..MoveoutCounterFinal)
	
	return {MoveoutCounterFinal, iRegressand, iCount};

    end---------function end
end




------------Set City Level by Distance (used in city founding or else)
local libertyPolicyDistanceChangeLV1 = GameDefines["POLICY_BRANCH_LIBERTY_CITY_LEVEL_DISTANCE_LV1"];
local libertyPolicyDistanceChangeLV2 = GameDefines["POLICY_BRANCH_LIBERTY_CITY_LEVEL_DISTANCE_LV2"];
local libertyPolicyDistanceChangeLV3 = GameDefines["POLICY_BRANCH_LIBERTY_CITY_LEVEL_DISTANCE_LV3"];
local libertyPolicyDistanceChangeLV4 = GameDefines["POLICY_BRANCH_LIBERTY_CITY_LEVEL_DISTANCE_LV4"];

function SetCityLevelbyDistance(city)
	if (PreGame.GetGameOption("GAMEOPTION_SP_CORRUPTION_OFF") == 1) then
		print("Corruption System - OFF!");
		return;
	end
	
	if city == nil or city:Plot() == nil or city:GetOwner() == -1 or Players[city:GetOwner()] == nil
	or Players[city:GetOwner()]:GetCapitalCity() == nil or Players[city:GetOwner()]:GetCapitalCity():Plot() == nil
	then
		return;
	end
	local pPlayer = Players[city:GetOwner()];
	local pCapital = pPlayer:GetCapitalCity();
	local plot = city:Plot();
	local cityX = city:GetX();
	local cityY = city:GetY();
	local pCapPlot = pCapital:Plot();
	local CapX = pCapital:GetX()
	local CapY = pCapital:GetY()
	
	local WorldSizeLength = Map.GetGridSize()
	local policyID = GameInfo.Policies["POLICY_DICTATORSHIP_PROLETARIAT"].ID
	local policyBonusID = GameInfo.Policies["POLICY_POLICE_STATE"].ID
	
	local DistanceLV1 = 7
	
	local DistanceLV2 = WorldSizeLength / 8	
	if DistanceLV2 > 18 then
		DistanceLV2 = 18
	elseif DistanceLV2 < 14 then
	   DistanceLV2 = 14
	end
	
	local DistanceLV3 = WorldSizeLength / 5
	if DistanceLV3 > 30 then
	   DistanceLV3 = 30
	elseif DistanceLV3 < 26 then
	   DistanceLV3 = 26
	end
	       
	local DistanceLV4 = WorldSizeLength / 3
	if DistanceLV4 > 44 then
	   DistanceLV4 = 44
	elseif DistanceLV4 < 36 then
	   DistanceLV4 = 36
	end

	local bAdoptLiberty = pPlayer:HasPolicyBranch(GameInfoTypes["POLICY_BRANCH_LIBERTY"]) and not pPlayer:IsPolicyBranchBlocked(GameInfoTypes["POLICY_BRANCH_LIBERTY"]);
	if bAdoptLiberty then
		DistanceLV1 = DistanceLV1 + libertyPolicyDistanceChangeLV1;
		DistanceLV2 = DistanceLV2 + libertyPolicyDistanceChangeLV2;
		DistanceLV3 = DistanceLV3 + libertyPolicyDistanceChangeLV3;
		DistanceLV4 = DistanceLV4 + libertyPolicyDistanceChangeLV4;
		print ("CityLevel is affected by POLICY_BRANCH_LIBERTY.", libertyPolicyDistanceChangeLV1, libertyPolicyDistanceChangeLV2, libertyPolicyDistanceChangeLV3, libertyPolicyDistanceChangeLV4);
	end
	print ("DistanceLV1:"..DistanceLV1);
	print ("DistanceLV2:"..DistanceLV2);
	print ("DistanceLV3:"..DistanceLV3);
	print ("DistanceLV4:"..DistanceLV4);
	
	local bHasSpy = false;
	local bHasSAgent = false;
	local spies = pPlayer:GetEspionageSpies();
	for i,v in ipairs(spies) do
		if (v.CityX == cityX and v.CityY == cityY) then
			bHasSpy = true;
			if v.Rank == "TXT_KEY_SPY_RANK_2" then
				bHasSAgent = true;
			end
			break;
		end
	end


	if GameInfo.Leader_Traits{ LeaderType = GameInfo.Leaders[pPlayer:GetLeaderType()].Type, TraitType = "TRAIT_OCEAN_MOVEMENT" }()
	and(GameInfo.Traits["TRAIT_OCEAN_MOVEMENT"].PrereqPolicy == nil or (GameInfo.Traits["TRAIT_OCEAN_MOVEMENT"].PrereqPolicy 
	and pPlayer:HasPolicy(GameInfoTypes[GameInfo.Traits["TRAIT_OCEAN_MOVEMENT"].PrereqPolicy])))
	then
		print ("Lv1 up for this city!")
		DistanceLV1 = DistanceLV2
		DistanceLV2 = DistanceLV3
		DistanceLV3 = DistanceLV4
		DistanceLV4 = 999
	elseif pPlayer:HasPolicy(policyID) then
		print ("Lv1 up for this city! - Policy Effect!")
		DistanceLV1 = DistanceLV2
		DistanceLV2 = DistanceLV3
		DistanceLV3 = DistanceLV4
		DistanceLV4 = 999
	end
	if GameInfo.Leader_Traits{ LeaderType = GameInfo.Leaders[pPlayer:GetLeaderType()].Type, TraitType = "TRAIT_WAYFINDING" }()
	and(GameInfo.Traits["TRAIT_WAYFINDING"].PrereqPolicy == nil or (GameInfo.Traits["TRAIT_WAYFINDING"].PrereqPolicy 
	and pPlayer:HasPolicy(GameInfoTypes[GameInfo.Traits["TRAIT_WAYFINDING"].PrereqPolicy])))
	then
		print ("No Lv 4-5 city!")
		DistanceLV3 = 999
		DistanceLV4 = 999
	end
	
	
	if pPlayer:GetNumCities() > 0 then
		if city:IsPuppet() then
		    if pPlayer:MayNotAnnex()
		    --[[GameInfo.Leader_Traits{ LeaderType = GameInfo.Leaders[pPlayer:GetLeaderType()].Type, TraitType = "TRAIT_SUPER_CITY_STATE" }()
		    and(GameInfo.Traits["TRAIT_SUPER_CITY_STATE"].PrereqPolicy == nil or (GameInfo.Traits["TRAIT_SUPER_CITY_STATE"].PrereqPolicy 
		    and pPlayer:HasPolicy(GameInfoTypes[GameInfo.Traits["TRAIT_SUPER_CITY_STATE"].PrereqPolicy])))]]
		    then
			city:SetNumRealBuilding(GameInfoTypes["BUILDING_PUPPET_GOVERNEMENT_FULL"],1)	--puppet city has a local government with no Penalties (Venice)
			city:SetNumRealBuilding(GameInfoTypes["BUILDING_PUPPET_GOVERNEMENT"],0)
--			city:SetFocusType(3)
			print("Special Puppet City with no Penalties!")
		    else
			city:SetNumRealBuilding(GameInfoTypes["BUILDING_PUPPET_GOVERNEMENT"],1)		--puppet city has a local government
			city:SetNumRealBuilding(GameInfoTypes["BUILDING_PUPPET_GOVERNEMENT_FULL"],0)
		    end
		
		    if not city:IsResistance() then
			if city:GetOrderQueueLength() <= 0 or city:GetProduction()== 0 then
				if not city:IsProductionProcess() then
					city:PushOrder (OrderTypes.ORDER_MAINTAIN, 0, -1, 0, false, false)
					print("Puppet City doing nothing! Let it produce Gold!")
				end
			end
		    end
		    print("Puppet City!")
		else
			city:SetNumRealBuilding(GameInfoTypes["BUILDING_PUPPET_GOVERNEMENT"],0)
			city:SetNumRealBuilding(GameInfoTypes["BUILDING_PUPPET_GOVERNEMENT_FULL"],0)
		end
		
		local overrideBuilding = nil;
		local iCityHallLv1 = GameInfo.Buildings.BUILDING_CITY_HALL_LV1.ID;
		overrideBuilding = GameInfo.Civilization_BuildingClassOverrides{ BuildingClassType = "BUILDINGCLASS_CITY_HALL_LV1", CivilizationType = GameInfo.Civilizations[pPlayer:GetCivilizationType()].Type }();
		if overrideBuilding ~= nil then
			iCityHallLv1 = GameInfo.Buildings[overrideBuilding.BuildingType].ID;
		end
		local iCityHallLv2 = GameInfo.Buildings.BUILDING_CITY_HALL_LV2.ID;
		overrideBuilding = GameInfo.Civilization_BuildingClassOverrides{ BuildingClassType = "BUILDINGCLASS_CITY_HALL_LV2", CivilizationType = GameInfo.Civilizations[pPlayer:GetCivilizationType()].Type }();
		if overrideBuilding ~= nil then
			iCityHallLv2 = GameInfo.Buildings[overrideBuilding.BuildingType].ID;
		end
		local iCityHallLv3 = GameInfo.Buildings.BUILDING_CITY_HALL_LV3.ID;
		overrideBuilding = GameInfo.Civilization_BuildingClassOverrides{ BuildingClassType = "BUILDINGCLASS_CITY_HALL_LV3", CivilizationType = GameInfo.Civilizations[pPlayer:GetCivilizationType()].Type }();
		if overrideBuilding ~= nil then
			iCityHallLv3 = GameInfo.Buildings[overrideBuilding.BuildingType].ID;
		end
		local iCityHallLv4 = GameInfo.Buildings.BUILDING_CITY_HALL_LV4.ID;
		overrideBuilding = GameInfo.Civilization_BuildingClassOverrides{ BuildingClassType = "BUILDINGCLASS_CITY_HALL_LV4", CivilizationType = GameInfo.Civilizations[pPlayer:GetCivilizationType()].Type }();
		if overrideBuilding ~= nil then
			iCityHallLv4 = GameInfo.Buildings[overrideBuilding.BuildingType].ID;
		end
		local iCityHallLv5 = GameInfo.Buildings.BUILDING_CITY_HALL_LV5.ID;
		overrideBuilding = GameInfo.Civilization_BuildingClassOverrides{ BuildingClassType = "BUILDINGCLASS_CITY_HALL_LV5", CivilizationType = GameInfo.Civilizations[pPlayer:GetCivilizationType()].Type }();
		if overrideBuilding ~= nil then
			iCityHallLv5 = GameInfo.Buildings[overrideBuilding.BuildingType].ID;
		end
		local iConstable = GameInfo.Buildings.BUILDING_CONSTABLE.ID;
		overrideBuilding = GameInfo.Civilization_BuildingClassOverrides{ BuildingClassType = "BUILDINGCLASS_CONSTABLE", CivilizationType = GameInfo.Civilizations[pPlayer:GetCivilizationType()].Type }();
		if overrideBuilding ~= nil then
			iConstable = GameInfo.Buildings[overrideBuilding.BuildingType].ID;
		end
		local iSheriffOffice = GameInfo.Buildings.BUILDING_SHERIFF_OFFICE.ID;
		overrideBuilding = GameInfo.Civilization_BuildingClassOverrides{ BuildingClassType = "BUILDINGCLASS_SHERIFF_OFFICE", CivilizationType = GameInfo.Civilizations[pPlayer:GetCivilizationType()].Type }();
		if overrideBuilding ~= nil then
			iSheriffOffice = GameInfo.Buildings[overrideBuilding.BuildingType].ID;
		end
		local iPoliceStation = GameInfo.Buildings.BUILDING_POLICE_STATION.ID;
		overrideBuilding = GameInfo.Civilization_BuildingClassOverrides{ BuildingClassType = "BUILDINGCLASS_POLICE_STATION", CivilizationType = GameInfo.Civilizations[pPlayer:GetCivilizationType()].Type }();
		if overrideBuilding ~= nil then
			iPoliceStation = GameInfo.Buildings[overrideBuilding.BuildingType].ID;
		end
		local iProcuratorate = GameInfo.Buildings.BUILDING_PROCURATORATE.ID;
		overrideBuilding = GameInfo.Civilization_BuildingClassOverrides{ BuildingClassType = "BUILDINGCLASS_PROCURATORATE", CivilizationType = GameInfo.Civilizations[pPlayer:GetCivilizationType()].Type }();
		if overrideBuilding ~= nil then
			iProcuratorate = GameInfo.Buildings[overrideBuilding.BuildingType].ID;
		end
		
		city:SetNumRealBuilding(iCityHallLv1,0);
		city:SetNumRealBuilding(iCityHallLv2,0);
		city:SetNumRealBuilding(iCityHallLv3,0);
		city:SetNumRealBuilding(iCityHallLv4,0);
		city:SetNumRealBuilding(iCityHallLv5,0);
		
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_POLICE_STATE_LV2"],0);
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_POLICE_STATE_LV3"],0);
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_POLICE_STATE_LV4"],0);
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_POLICE_STATE_LV5"],0);
		
		local iCityLevel = 0;
		if     city:IsCapital() or city:IsPuppet() or bHasSAgent
		or ( ( plot:GetResourceType() == GameInfoTypes.RESOURCE_NUTMEG or plot:GetResourceType() == GameInfoTypes.RESOURCE_CLOVES
		or     plot:GetResourceType() == GameInfoTypes.RESOURCE_PEPPER ) and city:GetOwner() == city:GetOriginalOwner() )
		then
		else
			print("Annexed City, City Hall is built!")
			local Distance = Map.PlotDistance (cityX,cityY,CapX,CapY);
			print("City's Distance from Capital:"..Distance);
			if     (Distance <= DistanceLV1) then
				iCityLevel = 1;
			elseif (Distance >  DistanceLV1 and Distance <= DistanceLV2) then
				iCityLevel = 2;
			elseif (Distance >  DistanceLV2 and Distance <= DistanceLV3) then
				iCityLevel = 3;
			elseif (Distance >  DistanceLV3 and Distance <= DistanceLV4) then
				iCityLevel = 4;
			elseif (Distance >  DistanceLV4) then
				iCityLevel = 5;
			end
			
			-- Diplomatic Marriage (CIVILIZATION_AUSTRIA)
			if city:IsHasBuilding(GameInfoTypes["BUILDING_OLD_CAPITAL_OF_CITYSTATE"]) then
				iCityLevel = math.max(1, iCityLevel - 2);
			end
			
			-- Spy - Governor
			if bHasSpy then
				iCityLevel = math.max(1, iCityLevel - 1);
			end
		end
		
		if     iCityLevel == 0 then
			city:SetNumRealBuilding(iConstable,0);
			city:SetNumRealBuilding(iSheriffOffice,0);
			city:SetNumRealBuilding(iPoliceStation,0);
			city:SetNumRealBuilding(iProcuratorate,0);
		
		elseif iCityLevel == 1 then
			city:SetNumRealBuilding(iCityHallLv1,1);
			city:SetNumRealBuilding(iConstable,0);
			city:SetNumRealBuilding(iSheriffOffice,0);
			city:SetNumRealBuilding(iPoliceStation,0);
			city:SetNumRealBuilding(iProcuratorate,0);
			
			print("City lv1")
			
		elseif iCityLevel == 2 then
			city:SetNumRealBuilding(iCityHallLv2,1);
			if city:IsHasBuilding(iSheriffOffice) then
				city:SetNumRealBuilding(iConstable,1);
			end
			city:SetNumRealBuilding(iSheriffOffice,0);
			city:SetNumRealBuilding(iPoliceStation,0);
			city:SetNumRealBuilding(iProcuratorate,0);
			
			if pPlayer:HasPolicy(policyBonusID) then
				city:SetNumRealBuilding(GameInfoTypes["BUILDING_POLICE_STATE_LV2"],1);
				print ("Police State!")
			end
			
			print("City lv2")
			
		elseif iCityLevel == 3 then
			city:SetNumRealBuilding(iCityHallLv3,1);
			city:SetNumRealBuilding(iConstable,0);
			if city:IsHasBuilding(iPoliceStation) then
				city:SetNumRealBuilding(iSheriffOffice,1);
			end
			city:SetNumRealBuilding(iPoliceStation,0);
			city:SetNumRealBuilding(iProcuratorate,0);
			
			if pPlayer:HasPolicy(policyBonusID) then
				city:SetNumRealBuilding(GameInfoTypes["BUILDING_POLICE_STATE_LV3"],1);
				print ("Police State!")
			end
			
			print("City lv3")
			
		elseif iCityLevel == 4 then
			city:SetNumRealBuilding(iCityHallLv4,1);
			city:SetNumRealBuilding(iConstable,0);
			city:SetNumRealBuilding(iSheriffOffice,0);
			if city:IsHasBuilding(iProcuratorate) then
				city:SetNumRealBuilding(iPoliceStation,1);
			end
			city:SetNumRealBuilding(iProcuratorate,0);
			
			if pPlayer:HasPolicy(policyBonusID) then
				city:SetNumRealBuilding(GameInfoTypes["BUILDING_POLICE_STATE_LV4"],1);
				print ("Police State!")
			end
			
			print("City lv4")
			
		elseif iCityLevel == 5 then
			city:SetNumRealBuilding(iCityHallLv5,1);
			city:SetNumRealBuilding(iConstable,0);
			city:SetNumRealBuilding(iSheriffOffice,0);
			city:SetNumRealBuilding(iPoliceStation,0);
			
			if pPlayer:HasPolicy(policyBonusID) then
				city:SetNumRealBuilding(GameInfoTypes["BUILDING_POLICE_STATE_LV5"],1);
				print ("Police State!")
			end
			
			print("City lv5")
		end
	end


	
	
	
end-------------Function End










----------------------------------Misc----------------------------

----------Set up Citadel Units
function SetCitadelUnits(iPlayer, x, y)

	if iPlayer == nil then
		return
	end

	local pPlayer = Players[iPlayer]
	local pTeam = Teams[pPlayer:GetTeam()]
	local pPlot = Map.GetPlot(x, y)
	
	local CitadelUnitID = GameInfo.UnitPromotions["PROMOTION_CITADEL_DEFENSE"].ID
	
	local CitadelUnitEarly = GameInfoTypes.UNIT_CITADEL_EARLY
	local CitadelUnitMid = GameInfoTypes.UNIT_CITADEL_MID
	local CitadelUnitLate = GameInfoTypes.UNIT_CITADEL_LATE



	
	
--	if not pPlayer:IsHuman() then ------(only for human players for now)
--		print ("Citadel Units Not available for now because it may cause CTD!!!!")
--    	return
--	end
	
	
	local unitCount = pPlot:GetNumUnits()
	local iCounter = 1
	
	---------------This Event will be triggered TWICE , so must delete one of them to stop it from creating two units
	for i = 0, unitCount-1, 1 do
		local pFoundUnit = pPlot:GetUnit(i)			
		if pFoundUnit ~= nil and pFoundUnit:IsHasPromotion(CitadelUnitID) then
			iCounter = 3
			print ("Already there!")		
		end	
	end	
	
	if iCounter < 2 then
		if pTeam:IsHasTech(GameInfoTypes["TECH_ADV_FLIGHT"]) then
		   pPlayer:InitUnit(CitadelUnitLate, x, y, UNITAI_RANGED)
		elseif pTeam:IsHasTech(GameInfoTypes["TECH_MILITARY_LOGISTICS"]) then
		   pPlayer:InitUnit(CitadelUnitMid, x, y, UNITAI_RANGED)
		elseif pTeam:IsHasTech(GameInfoTypes["TECH_GUNPOWDER"]) then	   		   
		   pPlayer:InitUnit(CitadelUnitEarly, x, y, UNITAI_RANGED)
		end
	end

end



function RemoveConflictFeatures (plot)
	if plot == nil then
		return
	end
	
	if plot:GetFeatureType() == FeatureTypes.FEATURE_FOREST or plot:GetFeatureType() == FeatureTypes.FEATURE_MARSH or plot:GetFeatureType() == FeatureTypes.FEATURE_JUNGLE then
	   plot:SetFeatureType(-1)
	   print ("ConflictFeatures Removed!")
	end
end


-------------------AI Force build units

----------------------Make AI build unit of different types so they can work together----------------------------------------------------

----------Oringinal Codes from William Howard's Policy - Free Warrior' mod

function AIForceBuildAirEscortUnits (unitX, unitY, player)

	if unitX == nil or unitY == nil or player == nil or player:CountNumBuildings(GameInfoTypes["BUILDING_TROOPS_DEBUFF"]) > 0 then
		return
	end


	if player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_ALUMINUM"],true) <= 3
	and player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_MANPOWER"],true) <= 15 then
		print ("Not enough resources!")
		return
	end

	local sUnitType = GetCivSpecificUnit(player, "UNITCLASS_TRIPLANE")
    local sUpgradeUnitType = GetUpgradeUnit(player, sUnitType)
    
    while (sUpgradeUnitType ~= nil) do
       sUnitType = sUpgradeUnitType
       sUpgradeUnitType = GetUpgradeUnit(player, sUnitType)
    end

    local PlayerEra = player:GetCurrentEra()
    local NewUnitEXP = PlayerEra*20

    local NewUnit = player:InitUnit(GameInfoTypes[sUnitType], unitX, unitY, UNITAI_DEFENSE_AIR)
    
    AINewUnitSetUp(NewUnit, NewUnitEXP)
	NewUnit:PushMission(GameInfoTypes.MISSION_AIRPATROL)
    
    print ("Stupid AI need more Fighters! Now they are set intercepting!")
end



function AIForceBuildNavalEscortUnits (unitX, unitY, player)

	if unitX == nil or unitY == nil or player == nil or player:CountNumBuildings(GameInfoTypes["BUILDING_TROOPS_DEBUFF"]) > 0 then
		return
	end

	if player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_IRON"],true) <= 3
	and player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_MANPOWER"],true) <= 6 then
		print ("Not enough resources!")
		return
	end


	local sUnitType = GetCivSpecificUnit(player, "UNITCLASS_GALLEASS")
    local sUpgradeUnitType = GetUpgradeUnit(player, sUnitType)
        
    while (sUpgradeUnitType ~= nil) do
       sUnitType = sUpgradeUnitType
       sUpgradeUnitType = GetUpgradeUnit(player, sUnitType)
    end


    local PlayerEra = player:GetCurrentEra()
    local NewUnitEXP = PlayerEra*5

    local NewUnit = player:InitUnit(GameInfoTypes[sUnitType], unitX, unitY, UNITAI_ATTACK_SEA)
    
    AINewUnitSetUp(NewUnit, NewUnitEXP)
   
    print ("Stupid AI need more Naval Melee Ships!")
end



function AIForceBuildNavalHRUnits (unitX, unitY, player) 

	if unitX == nil or unitY == nil or player == nil or player:CountNumBuildings(GameInfoTypes["BUILDING_TROOPS_DEBUFF"]) > 0 then
		return
	end
	
	if player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_MANPOWER"],true) <= 4 then
		print ("Not enough resources!")
		return
	end

	local sUnitType = GetCivSpecificUnit(player, "UNITCLASS_FIRE_SHIP")
    local sUpgradeUnitType = GetUpgradeUnit(player, sUnitType)
        
    while (sUpgradeUnitType ~= nil) do
       sUnitType = sUpgradeUnitType
       sUpgradeUnitType = GetUpgradeUnit(player, sUnitType)
    end
    
    local PlayerEra = player:GetCurrentEra()
    local NewUnitEXP = PlayerEra*15

    local NewUnit = player:InitUnit(GameInfoTypes[sUnitType], unitX, unitY, UNITAI_ASSAULT_SEA)
   
    AINewUnitSetUp(NewUnit, NewUnitEXP)
    print ("Stupid AI need more Naval Hit and Run Ships!")
end



function AIForceBuildNavalRangedUnits (unitX, unitY, player) 

	if unitX == nil or unitY == nil or player == nil or player:CountNumBuildings(GameInfoTypes["BUILDING_TROOPS_DEBUFF"]) > 0 then
		return
	end
	
	if player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_IRON"],true) <= 3
	and player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_MANPOWER"],true) <= 6 then
		print ("Not enough resources!")
		return
	end
	
	if player:GetCurrentEra() >= 5 and player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_COAL"],true) <= 4
	and player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_MANPOWER"],true) <= 15 then
		print ("Not enough resources!")
		return
	end
	

	local sUnitType = GetCivSpecificUnit(player, "UNITCLASS_GREAT_GALLEASS")
    local sUpgradeUnitType = GetUpgradeUnit(player, sUnitType)
        
    while (sUpgradeUnitType ~= nil) do
       sUnitType = sUpgradeUnitType
       sUpgradeUnitType = GetUpgradeUnit(player, sUnitType)
    end
    
    local PlayerEra = player:GetCurrentEra()
    local NewUnitEXP = PlayerEra*15

    local NewUnit = player:InitUnit(GameInfoTypes[sUnitType], unitX, unitY, UNITAI_ASSAULT_SEA)
   
    AINewUnitSetUp(NewUnit, NewUnitEXP)
    
    print ("Stupid AI need more Naval Ranged Ships!")
end






function AIForceBuildInfantryUnits (unitX, unitY, player) 

	if unitX == nil or unitY == nil or player == nil or player:CountNumBuildings(GameInfoTypes["BUILDING_TROOPS_DEBUFF"]) > 0 then
		return
	end
	
	if player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_IRON"],true) <= 3
	and player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_MANPOWER"],true) <= 4 then
		print ("Not enough resources!")
		return
	end

	local sUnitType = GetCivSpecificUnit(player, "UNITCLASS_SWORDSMAN")
    local sUpgradeUnitType = GetUpgradeUnit(player, sUnitType)
        
    while (sUpgradeUnitType ~= nil) do
       sUnitType = sUpgradeUnitType
       sUpgradeUnitType = GetUpgradeUnit(player, sUnitType)
    end
    
    local PlayerEra = player:GetCurrentEra()
    local NewUnitEXP = PlayerEra*5
	

    local NewUnit = player:InitUnit(GameInfoTypes[sUnitType], unitX, unitY, UNITAI_ATTACK)
    
  
  	AINewUnitSetUp(NewUnit, NewUnitEXP)
  
    print ("Stupid AI need more Infantry!")
end



function AIForceBuildLandCounterUnits (unitX, unitY, player) 

	if unitX == nil or unitY == nil or player == nil or player:CountNumBuildings(GameInfoTypes["BUILDING_TROOPS_DEBUFF"]) > 0 then
		return
	end
	if player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_MANPOWER"],true) <= 4 then
		print ("Not enough resources!")
		return
	end

	local sUnitType = GetCivSpecificUnit(player, "UNITCLASS_SPEARMAN")
    local sUpgradeUnitType = GetUpgradeUnit(player, sUnitType)
        
    while (sUpgradeUnitType ~= nil) do
       sUnitType = sUpgradeUnitType
       sUpgradeUnitType = GetUpgradeUnit(player, sUnitType)
    end
    
    local PlayerEra = player:GetCurrentEra()
    local NewUnitEXP = PlayerEra*5
	

    local NewUnit = player:InitUnit(GameInfoTypes[sUnitType], unitX, unitY, UNITAI_ATTACK)
    
  
  	AINewUnitSetUp(NewUnit, NewUnitEXP)
    print ("Stupid AI need more Counter Units!")
end






function AIForceBuildMobileUnits (unitX, unitY, player) 
	
	if unitX == nil or unitY == nil or player == nil or player:CountNumBuildings(GameInfoTypes["BUILDING_TROOPS_DEBUFF"]) > 0 then
		return
	end
	
	if player:GetCurrentEra() < 5 and player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_HORSE"],true) <= 3
    and player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_MANPOWER"],true) <= 5 then
		print ("Not enough resources!")
		return
	end
	
	if player:GetCurrentEra() >= 5 and player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_OIL"],true) <= 3
	and player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_MANPOWER"],true) <= 10 then
		print ("Not enough resources!")
		return
	end

	local sUnitType = GetCivSpecificUnit(player, "UNITCLASS_HORSEMAN")
    local sUpgradeUnitType = GetUpgradeUnit(player, sUnitType)
        
    while (sUpgradeUnitType ~= nil) do
       sUnitType = sUpgradeUnitType
       sUpgradeUnitType = GetUpgradeUnit(player, sUnitType)
    end
    
    local PlayerEra = player:GetCurrentEra()
    local NewUnitEXP = PlayerEra*10

    local NewUnit = player:InitUnit(GameInfoTypes[sUnitType], unitX, unitY, UNITAI_FAST_ATTACK)
   
    AINewUnitSetUp(NewUnit, NewUnitEXP)
    print ("Stupid AI need more Mobile Units!")
end



function AIForceBuildLandHRUnits  (unitX, unitY, player) 
	
	if unitX == nil or unitY == nil or player == nil or player:CountNumBuildings(GameInfoTypes["BUILDING_TROOPS_DEBUFF"]) > 0 then
		return
	end
	
	
	if player:GetCurrentEra() < 6 and player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_HORSE"],true) <= 3
	and player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_MANPOWER"],true) <= 6 then
		print ("Not enough resources!")
		return
	end
	
	if player:GetCurrentEra() >= 6 and player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_ALUMINUM"],true) <= 3
	and player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_MANPOWER"],true) <= 10 then
		print ("Not enough resources!")
		return
	end

	local sUnitType = GetCivSpecificUnit(player, "UNITCLASS_MEDIEVAL_CHARIOT")
    local sUpgradeUnitType = GetUpgradeUnit(player, sUnitType)
        
    while (sUpgradeUnitType ~= nil) do
       sUnitType = sUpgradeUnitType
       sUpgradeUnitType = GetUpgradeUnit(player, sUnitType)
    end
    
    local PlayerEra = player:GetCurrentEra()
    local NewUnitEXP = PlayerEra*25

    local NewUnit = player:InitUnit(GameInfoTypes[sUnitType], unitX, unitY, UNITAI_FAST_ATTACK)
   
    NewUnit:SetExperience (NewUnitEXP)

	local plot = NewUnit:GetPlot()
	local unitCount = plot:GetNumUnits()
	
	if unitCount >=3 then
		if NewUnit:GetDomainType() == DomainTypes.DOMAIN_LAND then
			NewUnit:JumpToNearestValidPlot()
			print ("Jump out AI stacking units!")
		else
			NewUnit:Kill()
		end
	end
    print ("Stupid AI need more Land Hit and Run Units!")
end



function AIConscriptMilitiaUnits (unitX, unitY, player) 
	
	if player == nil or player:IsHuman() or player:CountNumBuildings(GameInfoTypes["BUILDING_TROOPS_DEBUFF"]) > 0 then
		return
	end
	

	local sUnitType = GetCivSpecificUnit(player, "UNITCLASS_WARRIOR")
    local sUpgradeUnitType = GetUpgradeUnit(player, sUnitType)
        
    while (sUpgradeUnitType ~= nil) do
       sUnitType = sUpgradeUnitType
       sUpgradeUnitType = GetUpgradeUnit(player, sUnitType)
    end
    
    local NewUnit = player:InitUnit(GameInfoTypes[sUnitType], unitX, unitY, UNITAI_DEFENSE)
    NewUnit:JumpToNearestValidPlot()
        
    print ("AI conscript Militia reporting! We fight to the last man!")
end


function AIConscriptMilitiaNavy (unitX, unitY, player) 
	
	if player == nil or player:IsHuman() or player:CountNumBuildings(GameInfoTypes["BUILDING_TROOPS_DEBUFF"]) > 0 then
		return
	end
	

	local sUnitType = GetCivSpecificUnit(player, "UNITCLASS_NAVAL_MILITIA")
    local sUpgradeUnitType = GetUpgradeUnit(player, sUnitType)
        
    while (sUpgradeUnitType ~= nil) do
       sUnitType = sUpgradeUnitType
       sUpgradeUnitType = GetUpgradeUnit(player, sUnitType)
    end
    
    local NewUnit = player:InitUnit(GameInfoTypes[sUnitType], unitX, unitY, UNITAI_ESCORT_SEA)
    NewUnit:JumpToNearestValidPlot()
        
    print ("AI conscript Militia Navy boadt! We fight to the last boat!")
end




function AINewUnitSetUp(NewUnit, NewUnitEXP)
	NewUnit:SetExperience (NewUnitEXP)
	
	if NewUnit == nil then
		return
	end
	
	local plot = NewUnit:GetPlot()
	local unitCount = plot:GetNumUnits()
	
	if unitCount >=3 then
		if NewUnit:GetDomainType() == DomainTypes.DOMAIN_LAND or NewUnit:GetDomainType() == DomainTypes.DOMAIN_SEA then
			NewUnit:JumpToNearestValidPlot()
			print ("Jump out AI stacking units!")
		end
	end
--	local NewUnitName = NewUnit:GetName()
--	print ("AI New Unit Setup Finsihed:"..NewUnitName)

end









--

--
-------------Timer Countdown to force AI end turn if freezeed at certain turns
--
--function CountDownForceEndTurn (player)
--
--	if not player:IsHuman() then
--    local x = os.clock()
--    local s = 0
--    for i=1,2000 do s = s + i end
--		print(string.format("AI turn processing elapsed time: %.2f\n", os.clock() - x))
--	end
--	Game.DoControl(GameInfoTypes.CONTROL_FORCEENDTURN)	
--	print ("This AI is taking too long time! So we force it to end its turn!")
--end
--
--




-- MOD Begin by CaptainCWB
-- Improve Tiles for Both Human & AI
function ImproveTiles(bIsHuman)
	for plotLoop = 0, Map.GetNumPlots() - 1, 1 do
		local plot = Map.GetPlotByIndex(plotLoop)
		if plot == nil or plot:GetOwner() == -1 or plot:IsCity() or Players[plot:GetOwner()]:IsMinorCiv() or Players[plot:GetOwner()]:IsBarbarian()
		or (bIsHuman and (not Players[plot:GetOwner()]:IsHuman() or not Teams[Players[plot:GetOwner()]:GetTeam()]:IsHasTech(GameInfoTypes["TECH_AUTOMATION_T"])))
		or ( not bIsHuman and Players[plot:GetOwner()]:IsHuman() )
		then
		else
			local player = Players[plot:GetOwner()];
			
			if plot:GetResourceType(player:GetTeam()) ~= -1
			and(plot:GetImprovementType() == -1
			or (not plot:CanHaveImprovement(plot:GetImprovementType(), player:GetTeam())
			and GameInfo.Resources[plot:GetResourceType(player:GetTeam())].ResourceClassType ~= "RESOURCECLASS_BONUS"))
			then
				if plot:CanHaveImprovement(GameInfo.Improvements.IMPROVEMENT_FARM.ID, player:GetTeam()) then
				    if  GameInfo.Leader_Traits{ LeaderType = GameInfo.Leaders[player:GetLeaderType()].Type, TraitType = "TRAIT_IGNORE_TERRAIN_IN_FOREST" }()
				    and(GameInfo.Traits["TRAIT_IGNORE_TERRAIN_IN_FOREST"].PrereqPolicy == nil or (GameInfo.Traits["TRAIT_IGNORE_TERRAIN_IN_FOREST"].PrereqPolicy 
				    and player:HasPolicy(GameInfoTypes[GameInfo.Traits["TRAIT_IGNORE_TERRAIN_IN_FOREST"].PrereqPolicy])))
				    then
				    else
					RemoveConflictFeatures(plot)
				    end
					plot:SetImprovementType(GameInfo.Improvements.IMPROVEMENT_FARM.ID)
				
				elseif plot:CanHaveImprovement(GameInfo.Improvements.IMPROVEMENT_MINE.ID, player:GetTeam()) then
					RemoveConflictFeatures(plot)
					plot:SetImprovementType(GameInfo.Improvements.IMPROVEMENT_MINE.ID)
				
				elseif plot:CanHaveImprovement(GameInfo.Improvements.IMPROVEMENT_QUARRY.ID, player:GetTeam()) then
					RemoveConflictFeatures(plot)
					plot:SetImprovementType(GameInfo.Improvements.IMPROVEMENT_QUARRY.ID)
						
				elseif plot:CanHaveImprovement(GameInfo.Improvements.IMPROVEMENT_PASTURE.ID, player:GetTeam()) then
					RemoveConflictFeatures(plot)
					plot:SetImprovementType(GameInfo.Improvements.IMPROVEMENT_PASTURE.ID)
				
				elseif plot:CanHaveImprovement(GameInfo.Improvements.IMPROVEMENT_FISHING_BOATS.ID, player:GetTeam()) then
					plot:SetImprovementType(GameInfo.Improvements.IMPROVEMENT_FISHING_BOATS.ID)
				
				elseif plot:CanHaveImprovement(GameInfo.Improvements.IMPROVEMENT_FISHFARM_MOD.ID, player:GetTeam()) then
					plot:SetImprovementType(GameInfo.Improvements.IMPROVEMENT_FISHFARM_MOD.ID)
				
				elseif plot:CanHaveImprovement(GameInfo.Improvements.IMPROVEMENT_PLANTATION.ID, player:GetTeam()) then
					RemoveConflictFeatures(plot)
					plot:SetImprovementType(GameInfo.Improvements.IMPROVEMENT_PLANTATION.ID)
				
				elseif plot:CanHaveImprovement(GameInfo.Improvements.IMPROVEMENT_CAMP.ID, player:GetTeam()) then
					plot:SetImprovementType(GameInfo.Improvements.IMPROVEMENT_CAMP.ID)
				
				elseif plot:CanHaveImprovement(GameInfo.Improvements.IMPROVEMENT_WELL.ID, player:GetTeam()) then
					RemoveConflictFeatures(plot)
					plot:SetImprovementType(GameInfo.Improvements.IMPROVEMENT_WELL.ID)
						
				elseif plot:CanHaveImprovement(GameInfo.Improvements.IMPROVEMENT_OFFSHORE_PLATFORM.ID, player:GetTeam()) then
					plot:SetImprovementType(GameInfo.Improvements.IMPROVEMENT_OFFSHORE_PLATFORM.ID)
				end
				print ("Improve Resource Automatically!")
			end
			if not plot:IsWater() or plot:GetResourceType(-1) ~= -1 or plot:GetImprovementType() ~= -1 or (plot:IsUnit() and player:IsHuman()) then
				if  plot:GetFeatureType() == FeatureTypes.FEATURE_JUNGLE and plot:GetImprovementType() == -1
				and plot:CanHaveImprovement(GameInfo.Improvements.IMPROVEMENT_TRADING_POST.ID, player:GetTeam())
				and (GameInfoTypes[GameInfo.Builds["BUILD_TRADING_POST"].PrereqTech] == nil
				or  Teams[player:GetTeam()]:IsHasTech(GameInfoTypes[GameInfo.Builds["BUILD_TRADING_POST"].PrereqTech]))
				then
					plot:SetImprovementType(GameInfo.Improvements.IMPROVEMENT_TRADING_POST.ID);
				end
			elseif plot:CanHaveImprovement(GameInfo.Improvements.IMPROVEMENT_FISHERY_MOD.ID, player:GetTeam()) and Teams[player:GetTeam()]:IsHasTech(GameInfoTypes[GameInfo.Builds["BUILD_FISHERY_MOD"].PrereqTech]) then
				plot:SetResourceType(GameInfoTypes.RESOURCE_FISH, 1)
				plot:SetImprovementType(GameInfo.Improvements.IMPROVEMENT_FISHFARM_MOD.ID)
			elseif plot:CanHaveImprovement(GameInfo.Improvements.IMPROVEMENT_GAS_RIG_MOD.ID, player:GetTeam()) and Teams[player:GetTeam()]:IsHasTech(GameInfoTypes[GameInfo.Builds["BUILD_GAS_RIG_MOD"].PrereqTech]) then
				plot:SetResourceType(GameInfoTypes.RESOURCE_NATRUALGAS, 1)
				plot:SetImprovementType(GameInfo.Improvements.IMPROVEMENT_OFFSHORE_PLATFORM.ID)
			end
			if plot:IsImprovementPillaged() then
				plot:SetImprovementPillaged(false)
				print ("pillaged plot repaired by Automation!")
			end
		end
	end
end

-- Carriers Restore Cargos
g_CargoSetList = {};
function SPCargoListSetup(iPlayerID)
	if Players[iPlayerID] == nil then return end
	if g_CargoSetList[iPlayerID] == nil then
		g_CargoSetList[iPlayerID] = {};
	end
	local pPlayer = Players[iPlayerID];
	
	local iCBARangedCombat = 0;
	local iASARangedCombat = 0;
	local iMisRangedCombat = 0;
	local pCBAcraftUnit = nil;
	local pASAcraftUnit = nil;
	local pMissile_Unit = nil;
	local iCBAcraft = -1
	local iASAcraft = -1
	local iMissileU = -1
	local overrideCBA = nil;
	local overrideASA = nil;
	local overrideMis = nil;
	local iCost = -1;
	for unit in GameInfo.Units() do
		if  unit and unit.Special ~= nil and unit.Type == GameInfo.UnitClasses[unit.Class].DefaultUnit
		and(unit.PrereqTech == nil or (unit.PrereqTech and Teams[pPlayer:GetTeam()]:IsHasTech(GameInfoTypes[unit.PrereqTech]))) then
			if     unit.Special == "SPECIALUNIT_FIGHTER" and unit.RangedCombat > iCBARangedCombat then
				iCBARangedCombat = unit.RangedCombat;
				pCBAcraftUnit = unit;
				iCBAcraft = unit.ID
			elseif unit.Special == "SPECIALUNIT_STEALTH" and unit.RangedCombat > iASARangedCombat and unit.RangeAttackOnlyInDomain then
				iASARangedCombat = unit.RangedCombat;
				pASAcraftUnit = unit;
				iASAcraft = unit.ID
			elseif unit.Special == "SPECIALUNIT_MISSILE" and unit.RangedCombat > iMisRangedCombat then
				iMisRangedCombat = unit.RangedCombat;
				pMissile_Unit = unit;
				iMissileU = unit.ID
			end
		end
	end
	if pCBAcraftUnit then
		overrideCBA = GameInfo.Civilization_UnitClassOverrides{ UnitClassType = pCBAcraftUnit.Class, CivilizationType = GameInfo.Civilizations[pPlayer:GetCivilizationType()].Type }();
	end
	if pASAcraftUnit then
		overrideASA = GameInfo.Civilization_UnitClassOverrides{ UnitClassType = pASAcraftUnit.Class, CivilizationType = GameInfo.Civilizations[pPlayer:GetCivilizationType()].Type }();
	end
	if pMissile_Unit then
		overrideMis = GameInfo.Civilization_UnitClassOverrides{ UnitClassType = pMissile_Unit.Class, CivilizationType = GameInfo.Civilizations[pPlayer:GetCivilizationType()].Type }();
	end
	
	if overrideCBA and GameInfo.Units[overrideCBA.UnitType].Special == "SPECIALUNIT_FIGHTER" then
		iCBAcraft = GameInfoTypes[overrideCBA.UnitType];
	elseif iCBAcraft == GameInfoTypes["UNIT_CARRIER_FIGHTER_ADV"]
	and GameInfo.Leader_Traits{ LeaderType = GameInfo.Leaders[pPlayer:GetLeaderType()].Type, TraitType = "TRAIT_OCEAN_MOVEMENT" }()
	and(GameInfo.Traits["TRAIT_OCEAN_MOVEMENT"].PrereqPolicy == nil or (GameInfo.Traits["TRAIT_OCEAN_MOVEMENT"].PrereqPolicy 
	and pPlayer:HasPolicy(GameInfoTypes[GameInfo.Traits["TRAIT_OCEAN_MOVEMENT"].PrereqPolicy])))
	then
		iCBAcraft = GameInfoTypes["UNIT_CARRIER_FIGHTER_ENGLISH_HARRIER_ADV"];
		print ("English Unique Adv CF!")
	end
	if overrideASA and GameInfo.Units[overrideASA.UnitType].Special == "SPECIALUNIT_STEALTH" then
		iASAcraft = GameInfoTypes[overrideASA.UnitType];
	end
	if overrideMis and GameInfo.Units[overrideMis.UnitType].Special == "SPECIALUNIT_MISSILE" then
		iMissileU = GameInfoTypes[overrideMis.UnitType];
	end
	if iASAcraft and iASAcraft ~= -1 then
	    for pCity in pPlayer:Cities() do
		if pCity and pCity:IsCanPurchase(false, false, iASAcraft, -1, -1, YieldTypes.YIELD_GOLD) then
			iCost = math.floor(pCity:GetUnitPurchaseCost( iASAcraft )/5);
			break;
		end
	    end
	end
	local sCBAcraft = "None";
	if iCBAcraft ~= -1 then
		sCBAcraft = Locale.ConvertTextKey(GameInfo.Units[iCBAcraft].Description);
	end
	print("Player ".. iPlayerID .. "'s Carriers can Purchase " .. sCBAcraft .. " in this turn, Cost: " .. iCost);
	
	if pPlayer:IsHuman() and iCBAcraft ~= -1 then
		CarrierRestoreButton.Title         = Locale.ConvertTextKey("TXT_KEY_BUILD_CARRIER_FIGHTER") .. Locale.ConvertTextKey(GameInfo.Units[iCBAcraft].Description);
		CarrierRestoreButton.IconAtlas     = GameInfo.Units[iCBAcraft].IconAtlas;
		CarrierRestoreButton.PortraitIndex = GameInfo.Units[iCBAcraft].PortraitIndex;
	end
	
	g_CargoSetList[iPlayerID] = {iCBAcraft, iMissileU, iCost, iASAcraft}
end

function CarrierRestore(iPlayerID, iUnitID, iCargoUnit)
	if Players[ iPlayerID ] == nil or not Players[ iPlayerID ]:IsAlive()
	or Players[ iPlayerID ]:GetUnitByID( iUnitID ) == nil
	or Players[ iPlayerID ]:GetUnitByID( iUnitID ):IsDead()
	or Players[ iPlayerID ]:GetUnitByID( iUnitID ):IsDelayedDeath()
	or Players[ iPlayerID ]:GetUnitByID( iUnitID ):GetPlot() == nil
	or Players[ iPlayerID ]:GetUnitByID( iUnitID ):GetPlot():IsCity()
	or iCargoUnit == nil or iCargoUnit == -1
	or g_CargoSetList[iPlayerID] == nil
	then
		return;
	end
	local pPlayer = Players[iPlayerID];
	local pUnit   = pPlayer:GetUnitByID(iUnitID);
	local pPlot   = pUnit:GetPlot();
	local iCost   = g_CargoSetList[iPlayerID][3];
	
	-- Add New aircraft(s)!
	if     pUnit:CargoSpace() > 0 and not pUnit:IsFull() then
		local sSpecialCargo = GameInfo.Units[pUnit:GetUnitType()].SpecialCargo;
		
		local SupplyDiscount = 0;
		if pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_CARRIER_SUPPLY_1"].ID) then 
			SupplyDiscount = SupplyDiscount+1
		end
		if pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_CARRIER_SUPPLY_2"].ID) then 
			SupplyDiscount = SupplyDiscount+1
		end
		if pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_CARRIER_SUPPLY_3"].ID) then 
			SupplyDiscount = SupplyDiscount+1
		end
		if iCost and iCost > 0 then
			iCost = math.floor(iCost*(1-0.2*SupplyDiscount));
		end
		
		if     sSpecialCargo == "SPECIALUNIT_MISSILE" then
			if pUnit:GetUnitType() == GameInfoTypes.UNIT_FRANCE_MISTRAL and iCargoUnit == GameInfoTypes.UNIT_GUIDED_MISSILE then
				iCargoUnit = GameInfoTypes["UNIT_FRANCE_EUROCOPTER_TIGER"];
				print ("French Eurotiger Unique!");
			end
			while not pUnit:IsFull() do
				pPlayer:InitUnit(iCargoUnit, pPlot:GetX(), pPlot:GetY(), UNITAI_MISSILE_AIR):SetMoves(0);
				print ("Missile restored!");
			end
		elseif sSpecialCargo == "SPECIALUNIT_FIGHTER" and iCost and iCost >= 0 and iCost <= pPlayer:GetGold() then
			local pNewCargoUnit = pPlayer:InitUnit(iCargoUnit, pPlot:GetX(), pPlot:GetY(), UNITAI_ATTACK_AIR);
			print ("New Aircraft restored on Carrier! Cost: "..iCost);
			if not pPlayer:IsHuman() then
				pNewCargoUnit:PushMission(GameInfoTypes.MISSION_AIRPATROL);
			end
			pNewCargoUnit:SetMoves(0);
			if not pPlayer:IsHuman() and not pUnit:IsFull() and 2*iCost <= pPlayer:GetGold() then
				iCost = 2*iCost;
				pNewCargoUnit = pPlayer:InitUnit(iCargoUnit, pPlot:GetX(), pPlot:GetY(), UNITAI_ATTACK_AIR);
				pNewCargoUnit:PushMission(GameInfoTypes.MISSION_AIRPATROL);
				pNewCargoUnit:SetMoves(0);
				print ("New Aircraft restored on Carrier twice for AI! Total Cost: "..iCost);
			end
			return iCost
		end
	
	-- Upgrade Old aircraft!
	elseif pUnit:IsCargo() then
		local sSpecial = GameInfo.Units[pUnit:GetUnitType()].Special;
		if     sSpecial == "SPECIALUNIT_FIGHTER" and iCost and iCost > 0 then
			iCost = math.floor(iCost/2);
		elseif sSpecial == "SPECIALUNIT_STEALTH" then
			iCost = pUnit:UpgradePrice(iCargoUnit);
		elseif sSpecial == "SPECIALUNIT_MISSILE" then
			iCost = 0;
		end
		local SupplyDiscount = 0;
		if pUnit:GetTransportUnit():IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_CARRIER_SUPPLY_1"].ID) then 
			SupplyDiscount = SupplyDiscount+1
		end
		if pUnit:GetTransportUnit():IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_CARRIER_SUPPLY_2"].ID) then 
			SupplyDiscount = SupplyDiscount+1
		end
		if pUnit:GetTransportUnit():IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_CARRIER_SUPPLY_3"].ID) then 
			SupplyDiscount = SupplyDiscount+1
		end
		if iCost and iCost > 0 then
			iCost = math.floor(iCost*(1-0.2*SupplyDiscount));
		end
		-- Can't upgrade because lacking the Gold!
		if iCost == nil or iCost < 0 or iCost > pPlayer:GetGold() then
			return;
		end
		if (GameInfo.Leader_Traits{ LeaderType = GameInfo.Leaders[pPlayer:GetLeaderType()].Type, TraitType = "TRAIT_OCEAN_MOVEMENT" }()
		and(GameInfo.Traits["TRAIT_OCEAN_MOVEMENT"].PrereqPolicy == nil or (GameInfo.Traits["TRAIT_OCEAN_MOVEMENT"].PrereqPolicy 
		and pPlayer:HasPolicy(GameInfoTypes[GameInfo.Traits["TRAIT_OCEAN_MOVEMENT"].PrereqPolicy])))
		and iCargoUnit == GameInfoTypes["UNIT_CARRIER_FIGHTER_ADV"])
		or pUnit:GetUnitType() == GameInfoTypes["UNIT_CARRIER_FIGHTER_ENGLISH_HARRIER"]
		then
			iCargoUnit = GameInfoTypes["UNIT_CARRIER_FIGHTER_ENGLISH_HARRIER_ADV"];
			print ("English Unique 'Upgrade' CFJ!");
		elseif pUnit:GetTransportUnit():GetUnitType() == GameInfoTypes.UNIT_FRANCE_MISTRAL and iCargoUnit == GameInfoTypes.UNIT_GUIDED_MISSILE then
			iCargoUnit = GameInfoTypes["UNIT_FRANCE_EUROCOPTER_TIGER"];
			print ("French Eurotiger Unique!");
		end
		--[[
		-- Change the "Error" Old aircraft to UU!
		if pUnit:GetUnitType() == GameInfoTypes[GameInfo.UnitClasses[pUnit:GetUnitClassType()].DefaultUnit] then
			local overrideUnit = GameInfo.Civilization_UnitClassOverrides{ UnitClassType = GameInfo.UnitClasses[pUnit:GetUnitClassType()].Type, CivilizationType = GameInfo.Civilizations[pPlayer:GetCivilizationType()].Type }();
			if overrideUnit and overrideUnit.UnitType and GameInfo.Units[overrideUnit.UnitType].Special == GameInfo.Units[pUnit:GetUnitType()].Special then
				iCargoUnit = GameInfoTypes[overrideUnit.UnitType];
				print ("UU!");
			elseif GameInfo.Leader_Traits{ LeaderType = GameInfo.Leaders[pPlayer:GetLeaderType()].Type, TraitType = "TRAIT_OCEAN_MOVEMENT" }()
			and(GameInfo.Traits["TRAIT_OCEAN_MOVEMENT"].PrereqPolicy == nil or (GameInfo.Traits["TRAIT_OCEAN_MOVEMENT"].PrereqPolicy 
			and pPlayer:HasPolicy(GameInfoTypes[GameInfo.Traits["TRAIT_OCEAN_MOVEMENT"].PrereqPolicy])))
			and pUnit:GetUnitType() == GameInfoTypes["UNIT_CARRIER_FIGHTER_ADV"]
			then
				iCargoUnit = GameInfoTypes["UNIT_CARRIER_FIGHTER_ENGLISH_HARRIER_ADV"]
				print ("English Unique Adv CF!")
			end
		end
		]]
		
		if iCargoUnit ~= -1 then
			print ("Found old aircrafts! Upgrade Price is: " .. iCost);
			local iLevel = pUnit:GetLevel();
			local iExperience = pUnit:GetExperience();
			local tUnitPromotions = {};
			for unitPromotion in GameInfo.UnitPromotions() do
				if pUnit:IsHasPromotion(unitPromotion.ID) and not unitPromotion.LostWithUpgrade then
					table.insert(tUnitPromotions, unitPromotion.ID);
				end
			end
			local unitAIType = pUnit:GetUnitAIType();
			pUnit:Kill();
			local pNewCargoUnit = pPlayer:InitUnit(iCargoUnit, pPlot:GetX(), pPlot:GetY(), unitAIType);
			pNewCargoUnit:SetLevel(iLevel);
			pNewCargoUnit:SetExperience(iExperience);
			for _, unitPromotionID in ipairs(tUnitPromotions) do
				pNewCargoUnit:SetHasPromotion(unitPromotionID, true);
			end
			--[[
			if not pPlayer:IsHuman() then
				pNewCargoUnit:PushMission(GameInfoTypes.MISSION_AIRPATROL);
			end
			]]
			pNewCargoUnit:SetMoves(0);
			return iCost;
		end
	end
end
-- MOD End   by CaptainCWB

-- MOD Begin by HMS
function RemoveErrorPromotion(iPlayerID, iUnitID)
	local player = Players[iPlayerID]
	if player == nil then
		print ("No Player to RemovePromotion ")
		return
	end
    
      	if iUnitID == nil then 
		print ("No unit to RemovePromotion")
    		return 
    	end
    	
    	if player:IsMinorCiv() or player:IsBarbarian() then
   		 	return
    	end
    	
	local unit = player:GetUnitByID(iUnitID)
	    
	if unit == nil  then
	print ("No unit to RemovePromotion")
		return
	end	
	
	
	local unitX = unit:GetX()
	local unitY = unit:GetY()
	
	if unitX == nil or unitY == nil then
	print ("No Plot to Remove Promotion")
		return
	end
	--Unit Type list
	local RangedUnitID = GameInfo.UnitPromotions["PROMOTION_ARCHERY_COMBAT"].ID
	local AntiAirID = GameInfo.UnitPromotions["PROMOTION_ANTI_AIR"].ID
	local CitySiegeID = GameInfo.UnitPromotions["PROMOTION_CITY_SIEGE"].ID
	local LandAOEUnitID = GameInfo.UnitPromotions["PROMOTION_SPLASH_DAMAGE"].ID
	local FixedArtilleryID = GameInfo.UnitPromotions["PROMOTION_CITADEL_DEFENSE"].ID
	local CounterMountedID = GameInfo.UnitPromotions["PROMOTION_ANTI_MOUNTED"].ID
	local CounterTankID = GameInfo.UnitPromotions["PROMOTION_ANTI_TANK"].ID
	local InfantryID = GameInfo.UnitPromotions["PROMOTION_INFANTRY_COMBAT"].ID
	local GunpowderInfantryID = GameInfo.UnitPromotions["PROMOTION_GUNPOWDER_INFANTRY_COMBAT"].ID
	
	local HitandRunID = GameInfo.UnitPromotions["PROMOTION_HITANDRUN"].ID
	local HelicopterID = GameInfo.UnitPromotions["PROMOTION_HELI_ATTACK"].ID
	
	local NavalCuiserID = GameInfo.UnitPromotions["PROMOTION_NAVAL_RANGED_CRUISER"].ID
	local NavalHitandRunID = GameInfo.UnitPromotions["PROMOTION_NAVAL_HIT_AND_RUN"].ID
	local NavalRangedID = GameInfo.UnitPromotions["PROMOTION_NAVAL_RANGED_SHIP"].ID
	local SubmarineID = GameInfo.UnitPromotions["PROMOTION_SUBMARINE_COMBAT"].ID
	
	local CapitalShipID = GameInfo.UnitPromotions["PROMOTION_NAVAL_CAPITAL_SHIP"].ID
	local CarrierID = GameInfo.UnitPromotions["PROMOTION_CARRIER_UNIT"].ID
	
	local SSBNID = GameInfo.UnitPromotions["PROMOTION_CARGO_IX"].ID
	
	local BomberID = GameInfo.UnitPromotions["PROMOTION_STRATEGIC_BOMBER"].ID
	local AirAttackID = GameInfo.UnitPromotions["PROMOTION_AIR_ATTACK"].ID
	local LandBasedFighterID = GameInfo.UnitPromotions["PROMOTION_ANTI_AIR_II"].ID
	local CarrierFighterID = GameInfo.UnitPromotions["PROMOTION_CARRIER_FIGHTER"].ID
	
	--Promotion List
	local InfantryShock1ID = GameInfo.UnitPromotions["PROMOTION_SHOCK_1"].ID
	local InfantryShock2ID = GameInfo.UnitPromotions["PROMOTION_SHOCK_2"].ID
	local InfantryShock3ID = GameInfo.UnitPromotions["PROMOTION_SHOCK_3"].ID
	local Cover1ID = GameInfo.UnitPromotions["PROMOTION_COVER_1"].ID
	local Cover2ID = GameInfo.UnitPromotions["PROMOTION_COVER_2"].ID
	local Cover3ID = GameInfo.UnitPromotions["PROMOTION_COVER_3"].ID
	
	local AntiMounted1ID = GameInfo.UnitPromotions["PROMOTION_FORMATION_1"].ID
	local AntiMounted2ID = GameInfo.UnitPromotions["PROMOTION_FORMATION_2"].ID
	local AntiTank1ID = GameInfo.UnitPromotions["PROMOTION_AMBUSH_1"].ID
	local AntiTank2ID = GameInfo.UnitPromotions["PROMOTION_AMBUSH_2"].ID
	local CQBCombat1ID = GameInfo.UnitPromotions["PROMOTION_CQB_COMBAT_1"].ID
	local CQBCombat2ID = GameInfo.UnitPromotions["PROMOTION_CQB_COMBAT_2"].ID
	
	local BlitzID = GameInfo.UnitPromotions["PROMOTION_BLITZ"].ID
	local LogisticsID = GameInfo.UnitPromotions["PROMOTION_LOGISTICS"].ID
	
	local CollDamageLV1ID = GameInfo.UnitPromotions["PROMOTION_COLLATERAL_DAMAGE_1"].ID
	local CollDamageLV2ID = GameInfo.UnitPromotions["PROMOTION_COLLATERAL_DAMAGE_2"].ID
	-- local CollDamageLV3ID = GameInfo.UnitPromotions["PROMOTION_COLLATERAL_DAMAGE_3"].ID
	
	local SiegeLV1ID = GameInfo.UnitPromotions["PROMOTION_VOLLEY_1"].ID
	local SiegeLV2ID = GameInfo.UnitPromotions["PROMOTION_VOLLEY_2"].ID
	
	local Barrage1ID = GameInfo.UnitPromotions["PROMOTION_BARRAGE_1"].ID
	local Barrage2ID = GameInfo.UnitPromotions["PROMOTION_BARRAGE_2"].ID
	local Barrage3ID = GameInfo.UnitPromotions["PROMOTION_BARRAGE_3"].ID
	local LongBowManUnitID = GameInfo.UnitPromotions["PROMOTION_RANGE_SPECIAL"].ID
	
	local Accuracy1ID = GameInfo.UnitPromotions["PROMOTION_ACCURACY_1"].ID
	local Accuracy2ID = GameInfo.UnitPromotions["PROMOTION_ACCURACY_2"].ID
	
	local FlankGun1ID = GameInfo.UnitPromotions["PROMOTION_FLANK_GUN_1"].ID
	local FlankGun2ID = GameInfo.UnitPromotions["PROMOTION_FLANK_GUN_2"].ID
	
	local Sunder1ID = GameInfo.UnitPromotions["PROMOTION_SUNDER_1"].ID
	local Sunder2ID = GameInfo.UnitPromotions["PROMOTION_SUNDER_2"].ID
	-- local Sunder3ID = GameInfo.UnitPromotions["PROMOTION_SUNDER_3"].ID
	
	local AntiNaval1ID = GameInfo.UnitPromotions["PROMOTION_FAE_ROCKET_1"].ID 
	local AntiNaval2ID = GameInfo.UnitPromotions["PROMOTION_FAE_ROCKET_2"].ID
	local AOEAttack1ID = GameInfo.UnitPromotions["PROMOTION_CLUSTER_ROCKET_1"].ID
	local AOEAttack2ID = GameInfo.UnitPromotions["PROMOTION_CLUSTER_ROCKET_2"].ID
	local CapitalShipArmor1ID = GameInfo.UnitPromotions["PROMOTION_ARMOR_BATTLESHIP_1"].ID
	local CapitalShipArmor2ID = GameInfo.UnitPromotions["PROMOTION_ARMOR_BATTLESHIP_2"].ID
	
	local NapalmBomb1ID = GameInfo.UnitPromotions["PROMOTION_NAPALMBOMB_1"].ID
	local NapalmBomb2ID = GameInfo.UnitPromotions["PROMOTION_NAPALMBOMB_2"].ID
	local NapalmBomb3ID = GameInfo.UnitPromotions["PROMOTION_NAPALMBOMB_3"].ID
	local DestroySupply1ID = GameInfo.UnitPromotions["PROMOTION_DESTROY_SUPPLY_1"].ID
	local DestroySupply2ID = GameInfo.UnitPromotions["PROMOTION_DESTROY_SUPPLY_2"].ID
	local AirSiege1ID = GameInfo.UnitPromotions["PROMOTION_AIR_SIEGE_1"].ID
	local AirSiege2ID = GameInfo.UnitPromotions["PROMOTION_AIR_SIEGE_2"].ID
	local AirSiege3ID = GameInfo.UnitPromotions["PROMOTION_AIR_SIEGE_3"].ID
	
	local AirBomb1ID = GameInfo.UnitPromotions["PROMOTION_AIR_BOMBARDMENT_1"].ID
	local AirBomb2ID = GameInfo.UnitPromotions["PROMOTION_AIR_BOMBARDMENT_2"].ID
	local AirBomb3ID = GameInfo.UnitPromotions["PROMOTION_AIR_BOMBARDMENT_3"].ID
	local AirTarget1ID = GameInfo.UnitPromotions["PROMOTION_AIR_TARGETING_1"].ID
	local AirTarget2ID = GameInfo.UnitPromotions["PROMOTION_AIR_TARGETING_2"].ID
	local AirTarget3ID = GameInfo.UnitPromotions["PROMOTION_AIR_TARGETING_3"].ID
	
	local DogFight1ID = GameInfo.UnitPromotions["PROMOTION_DOGFIGHTING_1"].ID
	local DogFight2ID = GameInfo.UnitPromotions["PROMOTION_DOGFIGHTING_2"].ID
	local DogFight3ID = GameInfo.UnitPromotions["PROMOTION_DOGFIGHTING_3"].ID
	local Intercept1ID = GameInfo.UnitPromotions["PROMOTION_INTERCEPTION_1"].ID
	local Intercept2ID = GameInfo.UnitPromotions["PROMOTION_INTERCEPTION_2"].ID
	local Intercept3ID = GameInfo.UnitPromotions["PROMOTION_INTERCEPTION_3"].ID
	
	local AIHitandRunID = GameInfo.UnitPromotions["PROMOTION_RANGE_REDUCE"].ID
	local AIRangeID = GameInfo.UnitPromotions["PROMOTION_RANGE"].ID
	
	local AISPForceID = GameInfo.UnitPromotions["PROMOTION_SPECIAL_FORCES_COMBAT"].ID
	
	local SetUpID = GameInfo.UnitPromotions["PROMOTION_MUST_SET_UP"].ID
	
	local MilitiaUnitID = GameInfo.UnitPromotions["PROMOTION_MILITIA_COMBAT"].ID
	
	local CarrierSupply1ID = GameInfo.UnitPromotions["PROMOTION_CARRIER_SUPPLY_1"].ID
	local CarrierSupply2ID = GameInfo.UnitPromotions["PROMOTION_CARRIER_SUPPLY_2"].ID
	local CarrierSupply3ID = GameInfo.UnitPromotions["PROMOTION_CARRIER_SUPPLY_3"].ID
	local CarrierAntiAir1ID = GameInfo.UnitPromotions["PROMOTION_CARRIER_FIGHTER_AIRFIGHT_1"].ID
	local CarrierAntiAir2ID = GameInfo.UnitPromotions["PROMOTION_CARRIER_FIGHTER_AIRFIGHT_2"].ID
	local CarrierAttack1ID = GameInfo.UnitPromotions["PROMOTION_CARRIER_FIGHTER_ATTACK_1"].ID
	local CarrierAttack2ID = GameInfo.UnitPromotions["PROMOTION_CARRIER_FIGHTER_ATTACK_2"].ID
	local DestroySupply_CarrierID = GameInfo.UnitPromotions["PROMOTION_CARRIER_FIGHTER_SIEGE_1"].ID
	local AirTarget_CarrierID = GameInfo.UnitPromotions["PROMOTION_CARRIER_FIGHTER_SIEGE_2"].ID
	
	local CorpsID = GameInfo.UnitPromotions["PROMOTION_CORPS_1"].ID;
	local ArmeeID = GameInfo.UnitPromotions["PROMOTION_CORPS_2"].ID;
	
	-- Units with formation(anti-mounted) auto upgrade to Ambush(anti-tank). -- Longbowman and Camelarcher also update.
	if unit:IsHasPromotion(CounterTankID) or unit:IsHasPromotion(HelicopterID) or unit:IsHasPromotion(AntiAirID) then
	    if unit:IsHasPromotion(AntiMounted1ID) then
		unit:SetHasPromotion(AntiMounted1ID,false);
		unit:SetHasPromotion(AntiTank1ID,true);
	    end
	    if unit:IsHasPromotion(AntiMounted2ID) then
		unit:SetHasPromotion(AntiMounted2ID,false);
		unit:SetHasPromotion(AntiTank2ID,true);
	    end
	end
	
	if unit:IsHasPromotion(CounterMountedID) or unit:IsHasPromotion(CounterTankID) then 
		unit:SetHasPromotion(InfantryShock1ID,false)
		unit:SetHasPromotion(InfantryShock2ID,false)
		unit:SetHasPromotion(InfantryShock3ID,false)
		unit:SetHasPromotion(Cover1ID,false)
		unit:SetHasPromotion(Cover2ID,false)
		unit:SetHasPromotion(Cover3ID,false)
		unit:SetHasPromotion(BlitzMeleeID,false)
	end
	if unit:IsHasPromotion(InfantryID) or unit:IsHasPromotion(GunpowderInfantryID) then 
		unit:SetHasPromotion(AntiTank1ID,false)
		unit:SetHasPromotion(AntiTank2ID,false)
		unit:SetHasPromotion(AntiMounted1ID,false)
		unit:SetHasPromotion(AntiMounted2ID,false)
		unit:SetHasPromotion(CQBCombat1ID,false)
		unit:SetHasPromotion(CQBCombat2ID,false)
	end
	if unit:IsHasPromotion(RangedUnitID) then 
		unit:SetHasPromotion(SiegeLV1ID,false)
		unit:SetHasPromotion(SiegeLV2ID,false)
		unit:SetHasPromotion(CollDamageLV1ID,false)
		unit:SetHasPromotion(CollDamageLV2ID,false)
		-- unit:SetHasPromotion(CollDamageLV3ID,false)
		unit:SetHasPromotion(BlitzID,false)
	end
	if unit:IsHasPromotion(CitySiegeID) then 
		unit:SetHasPromotion(FlankGun1ID,false)
		unit:SetHasPromotion(FlankGun2ID,false)
		unit:SetHasPromotion(Accuracy1ID,false)
		unit:SetHasPromotion(Accuracy2ID,false)
		unit:SetHasPromotion(Barrage1ID,false)
		unit:SetHasPromotion(Barrage2ID,false)
		unit:SetHasPromotion(Barrage3ID,false)
		unit:SetHasPromotion(BlitzID,false)
		unit:SetHasPromotion(LongBowManUnitID,false)
	end
	if unit:IsHasPromotion(FixedArtilleryID) then 
		unit:SetHasPromotion(AntiNaval1ID,false)
		unit:SetHasPromotion(AntiNaval2ID,false)
		unit:SetHasPromotion(AOEAttack1ID,false)
		unit:SetHasPromotion(AOEAttack2ID,false)
		end
	if unit:IsHasPromotion(NavalRangedID) or unit:IsHasPromotion(NavalCuiserID) then 
		unit:SetHasPromotion(CapitalShipArmor1ID,false)
		unit:SetHasPromotion(CapitalShipArmor2ID,false)
		unit:SetHasPromotion(AOEAttack1ID,false)
		unit:SetHasPromotion(AOEAttack2ID,false)
		unit:SetHasPromotion(IndirectFireID,false)
		unit:SetHasPromotion(BlitzID,false)
	end
	if unit:IsHasPromotion(CapitalShipID) then 
		unit:SetHasPromotion(FlankGun1ID,false)
		unit:SetHasPromotion(FlankGun2ID,false)
		unit:SetHasPromotion(Sunder1ID,false)
		unit:SetHasPromotion(Sunder2ID,false)
		-- unit:SetHasPromotion(Sunder3ID,false)
		unit:SetHasPromotion(CollDamageLV1ID,false)
		unit:SetHasPromotion(CollDamageLV2ID,false)
		-- unit:SetHasPromotion(CollDamageLV3ID,false)
		unit:SetHasPromotion(BlitzID,false)
		unit:SetHasPromotion(LogisticsID,false)
	end
	if unit:IsHasPromotion(AirAttackID) then 
		unit:SetHasPromotion(DestroySupply1ID,false)
		unit:SetHasPromotion(DestroySupply2ID,false)
		unit:SetHasPromotion(AirSiege1ID,false)
		unit:SetHasPromotion(AirSiege2ID,false)
		unit:SetHasPromotion(AirSiege3ID,false)
		unit:SetHasPromotion(NapalmBomb1ID,false)
		unit:SetHasPromotion(NapalmBomb2ID,false)
		unit:SetHasPromotion(NapalmBomb3ID,false)
	end
	if unit:IsHasPromotion(BomberID) then 
		unit:SetHasPromotion(AirBomb1ID,false)
		unit:SetHasPromotion(AirBomb2ID,false)
		unit:SetHasPromotion(AirBomb3ID,false)
		unit:SetHasPromotion(AirTarget1ID,false)
		unit:SetHasPromotion(AirTarget2ID,false)
		unit:SetHasPromotion(AirTarget3ID,false)
		unit:SetHasPromotion(BlitzID,false)
		unit:SetHasPromotion(LogisticsID,false)
		
	end
	if unit:IsHasPromotion(CarrierFighterID) then 
		unit:SetHasPromotion(DogFight1ID,false)
		unit:SetHasPromotion(DogFight2ID,false)
		unit:SetHasPromotion(DogFight3ID,false)
		unit:SetHasPromotion(Intercept1ID,false)
		unit:SetHasPromotion(Intercept2ID,false)
		unit:SetHasPromotion(Intercept3ID,false)
	end
	if unit:IsHasPromotion(LandBasedFighterID) or unit:IsHasPromotion(BomberID) or unit:IsHasPromotion(AirAttackID) then
		unit:SetHasPromotion(CarrierAntiAir1ID,false)
		unit:SetHasPromotion(CarrierAntiAir2ID,false)
		unit:SetHasPromotion(CarrierSupply1ID,false)
		unit:SetHasPromotion(CarrierSupply2ID,false)
		unit:SetHasPromotion(CarrierSupply3ID,false)
		unit:SetHasPromotion(DestroySupply_CarrierID,false)
		unit:SetHasPromotion(AirTarget_CarrierID,false)
		unit:SetHasPromotion(CarrierAttack1ID,false)
		unit:SetHasPromotion(CarrierAttack2ID,false)
	end
	
	-- MOD Begin by CaptainCWB
	-- Remove Corps Promotions in Record Mode without Corps Mode
	if  (PreGame.GetGameOption("GAMEOPTION_SP_RECORD_MODE") == 1
	and PreGame.GetGameOption("GAMEOPTION_SP_CORPS_MODE_DISABLE") == 1) 
	or unit:GetDomainType() ~= DomainTypes.DOMAIN_LAND
	then
		if unit:IsHasPromotion(CorpsID) then
			unit:SetHasPromotion(CorpsID, false);
		end
		if unit:IsHasPromotion(ArmeeID) then
			unit:SetHasPromotion(ArmeeID, false);
		end
	end
	-- MOD End   by CaptainCWB
end
-- MOD end by HMS



-- Beliefs
g_iEMSReligion = -1;
if not Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION) then
	for iPlayer = 0, GameDefines.MAX_CIV_PLAYERS - 1 do
		local pPlayer = Players[iPlayer];
		if pPlayer:IsEverAlive() and pPlayer:HasCreatedReligion() then
			local eReligion = pPlayer:GetReligionCreatedByPlayer();
			for i,v in ipairs(Game.GetBeliefsInReligion(eReligion)) do
				if GameInfo.Beliefs[v].Type == "BELIEF_EVANGELISM" then
					g_iEMSReligion = eReligion;
					break;
				end
			end
		end
	end
end



print ("UtilityFunctions Check Pass!")