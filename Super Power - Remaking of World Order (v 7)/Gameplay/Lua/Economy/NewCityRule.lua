-- NewCityRule
-- Author: Lincoln_lyf
-- Edited by Tokata
--------------------------------------------------------------
--include( "UtilityFunctions.lua" )




--==========================================================================================
-- Global Defines
--==========================================================================================

--local resManpower		= GameInfoTypes["RESOURCE_MANPOWER"]
--local resConsumer		= GameInfoTypes["RESOURCE_CONSUMER"]
--local resElectricity	= GameInfoTypes["RESOURCE_ELECTRICITY"]
--local bCitySizeLV1	= GameInfoTypes["BUILDING_CITY_SIZE_TOWN"]
--local bCitySizeLV2	= GameInfoTypes["BUILDING_CITY_SIZE_SMALL"]
--local bCitySizeLV3	= GameInfoTypes["BUILDING_CITY_SIZE_MEDIUM"]
--local bCitySizeLV4	= GameInfoTypes["BUILDING_CITY_SIZE_LARGE"]
--local bCitySizeLV5	= GameInfoTypes["BUILDING_CITY_SIZE_XL"]
--local bCitySizeLV6	= GameInfoTypes["BUILDING_CITY_SIZE_XXL"]
--local bCitySizeLV7	= GameInfoTypes["BUILDING_CITY_SIZE_GLOBAL"]
--
--local bPuppetGov	= GameInfoTypes["BUILDING_PUPPET_GOVERNEMENT"]
--local bPuppetGovFull= GameInfoTypes["BUILDING_PUPPET_GOVERNEMENT_FULL"]
--local bConstable	= GameInfoTypes["BUILDING_CONSTABLE"]
--local bRomanSenate	= GameInfoTypes["BUILDING_ROMAN_SENATE"]
--local bSheriffOffice= GameInfoTypes["BUILDING_SHERIFF_OFFICE"]
--local bPoliceStation= GameInfoTypes["BUILDING_POLICE_STATION"]
--local bProcuratorate= GameInfoTypes["BUILDING_PROCURATORATE"]
--
--local polRationalismID	= GameInfo.Policies["POLICY_RATIONALISM"].ID
--local bRationalism	= GameInfoTypes["BUILDING_RATIONALISM_HAPPINESS"]
--local polAristocracyID	= GameInfo.Policies["POLICY_ARISTOCRACY"].ID
--local bTourismBoost	= GameInfoTypes["BUILDING_HAPPINESS_TOURISMBOOST"]
--
--local bManpowerBonus	= GameInfoTypes["BUILDING_MANPOWER_BONUS"]
--local bConsumerBonus	= GameInfoTypes["BUILDING_CONSUMER_BONUS"]
--local bConsumerPenalty	= GameInfoTypes["BUILDING_CONSUMER_PENALTY"]
--local bElectricityBonus	= GameInfoTypes["BUILDING_ELECTRICITY_BONUS"]
--local bElectriPenalty	= GameInfoTypes["BUILDING_ELECTRICITY_PENALTY"]
--
--local eModernID	= GameInfo.Eras["ERA_MODERN"].ID
--
--local polMonarchyID	= GameInfoTypes["POLICY_MONARCHY"]
--local bTManpower	= GameInfoTypes["BUILDING_TRADITION_MANPOWER"]
--local bTFood		= GameInfoTypes["BUILDING_TRADITION_FOOD_GROWTH"]
--






function PlayerEditCity()------------------------This will trigger when player edit the specialists slots inside their cities.


------------------------CANNOT use Events.SpecificCityInfoDirty because it will cause infinte LOOP!!!!!!!!!!!!!!!!!!!!!!WTF!!!!!!!!!!!!!!!!!!!!!!!________

	local player = Players[Game.GetActivePlayer()]
	
	if player:IsBarbarian() or player:IsMinorCiv() then
		print ("Minors are Not available - PlayerEditCity!")
		return
	end

	if not player:IsHuman() then
		return
	end
	

	if UI.GetHeadSelectedCity() == nil then	
		return
	end

	local city = UI.GetHeadSelectedCity()

	local ManpowerRes = player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_MANPOWER"], true)
	local ConsumerRes = player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_CONSUMER"], true)
--
--	SetCityPerTurnEffects(Game.GetActivePlayer())
	
	SetCitySpecialistResources(city)
	
	SetCityAntiNegGoldBonus(city)
	
	
	print ("city's Specialist slot Updated in city screen!")
	
	
end
Events.SerialEventCityInfoDirty.Add(PlayerEditCity)



----------China's UA trigger
function ChinaGoldenAgeTrigger()
	local player = Players[Game.GetActivePlayer()];
	if player and GameInfo.Leader_Traits{ LeaderType = GameInfo.Leaders[player:GetLeaderType()].Type, TraitType = "TRAIT_ART_OF_WAR" }()
	and(GameInfo.Traits["TRAIT_ART_OF_WAR"].PrereqPolicy == nil or (GameInfo.Traits["TRAIT_ART_OF_WAR"].PrereqPolicy 
	and player:HasPolicy(GameInfoTypes[GameInfo.Traits["TRAIT_ART_OF_WAR"].PrereqPolicy])))
	and player:IsGoldenAge() and player:GetCapitalCity()
	then
		local pCapital = player:GetCapitalCity();
		SetGoldenAgeBonus(player, pCapital);
		print ("Chinese UA!")
	end
end	
Events.GoldenAgeStarted.Add (ChinaGoldenAgeTrigger)

local g_InternationalismIdeology = nil;
for playerID,player in pairs(Players) do
	if player and player:IsAlive() and player:HasPolicy(GameInfoTypes["POLICY_IRON_CURTAIN"]) then
		g_InternationalismIdeology = GameInfoTypes[GameInfo.Policies["POLICY_IRON_CURTAIN"].PolicyBranchType];
		break;
	end
end
function SPInternationalismAdopted(playerID, policyID)
	if policyID == GameInfoTypes["POLICY_IRON_CURTAIN"] and g_InternationalismIdeology == nil then
		g_InternationalismIdeology = GameInfoTypes[GameInfo.Policies["POLICY_IRON_CURTAIN"].PolicyBranchType];
	end
end
GameEvents.PlayerAdoptPolicy.Add(SPInternationalismAdopted);

function NewCitySystem(playerID)
	local player = Players[playerID]
	
	
	if player == nil then
		print ("No players")
		return
	end
	
	if player:IsBarbarian() or player:IsMinorCiv() then
		print ("Minors are Not available!")
    	return
	end
	
	if player:GetNumCities() <= 0 then
		print ("No Cities!")
		return
	end
	
	
	-- Policie Effects & Some Civs' UAs
	if player:GetCapitalCity() ~= nil then
		local pCapital = player:GetCapitalCity();
		-- Set Policy Buildings in Capital
		
		pCapital:SetNumRealBuilding(GameInfoTypes["BUILDING_IRON_CURTAIN_HAPPI"], 0);
		pCapital:SetNumRealBuilding(GameInfoTypes["BUILDING_IRON_CURTAIN_UNHAP"], 0);
		local iUnhappinessFromPublicOpinion = player:GetPublicOpinionUnhappiness();		-- iUnhappinessFromPublicOpinion = player:GetUnhappinessFromPublicOpinion()
		-- print("Player: " .. playerID .. " - UnhappinessFromPublicOpinion: " .. iUnhappinessFromPublicOpinion .. " - Ideology: " .. tostring(player:GetLateGamePolicyTree()) .. " - Order Ideology: " .. tostring(g_InternationalismIdeology));
		if iUnhappinessFromPublicOpinion > 0 then
		-- Policy - Internationalism
		    if player:HasPolicy(GameInfoTypes["POLICY_IRON_CURTAIN"]) then
			pCapital:SetNumRealBuilding(GameInfoTypes["BUILDING_IRON_CURTAIN_HAPPI"], iUnhappinessFromPublicOpinion);
		    elseif g_InternationalismIdeology and player:GetLateGamePolicyTree() ~= g_InternationalismIdeology then
			pCapital:SetNumRealBuilding(GameInfoTypes["BUILDING_IRON_CURTAIN_UNHAP"], iUnhappinessFromPublicOpinion);
		    end
		-- Policy - Authoritarianism
		    iUnhappinessFromPublicOpinion = math.floor(iUnhappinessFromPublicOpinion/2) + pCapital:GetNumBuilding(GameInfoTypes["BUILDING_IRON_CURTAIN_HAPPI"]);
		    if player:HasPolicy(GameInfoTypes["POLICY_NEW_ORDER"]) then
			pCapital:SetNumRealBuilding(GameInfoTypes["BUILDING_IRON_CURTAIN_HAPPI"], iUnhappinessFromPublicOpinion);
		    end
		end
		
		-- Chinese UA
		if GameInfo.Leader_Traits{ LeaderType = GameInfo.Leaders[player:GetLeaderType()].Type, TraitType = "TRAIT_ART_OF_WAR" }()
		and(GameInfo.Traits["TRAIT_ART_OF_WAR"].PrereqPolicy == nil or (GameInfo.Traits["TRAIT_ART_OF_WAR"].PrereqPolicy 
		and player:HasPolicy(GameInfoTypes[GameInfo.Traits["TRAIT_ART_OF_WAR"].PrereqPolicy])))
		then
			SetGoldenAgeBonus(player, pCapital)
			print ("Chinese UA!")
		end
	end
	
	
	-- Set "Allah Akbar" from Islamic University
	if (player:CountNumBuildings(GameInfoTypes["BUILDING_ARABIA_ISIAMIC_UNIVERSITY"]) > 6 or player:CountNumBuildings(GameInfoTypes["BUILDING_ARABIA_ISIAMIC_UNIVERSITY_ALLAH_AKBAR"]) > 0)
	-- Policy Effects
	-- +5% Culture Cost for New Policies if the city hasn't city hall -- Representation
	-- +25% Faith in all cities which have built a World Wonder -- Piety - Opening Effect
	-- Remove +25% WonderProductionModifier after enter "World War Era" -- Artistic Genius
	-- Get Consumers from Policy - Merchant Navy
	-- Get Local Happiness from Policy - Protectionism
	-- Get Consumers & Electricities from Policy - Total War
	or (player:HasPolicy(GameInfoTypes["POLICY_REPRESENTATION"]) or player:HasPolicy(GameInfoTypes["POLICY_PIETY"])
	or  player:HasPolicy(GameInfoTypes["POLICY_MERCHANT_NAVY"])  or(player:HasPolicy(GameInfoTypes["POLICY_ARTISTIC_GENIUS"]) and player:GetCurrentEra() > 5)
	or  player:HasPolicy(GameInfoTypes["POLICY_PROTECTIONISM"])  or player:HasPolicy(GameInfoTypes["POLICY_TOTAL_WAR"]))
	-- German UA
	or (GameInfo.Leader_Traits{ LeaderType = GameInfo.Leaders[player:GetLeaderType()].Type, TraitType = "TRAIT_CONVERTS_LAND_BARBARIANS" }()
	and(GameInfo.Traits["TRAIT_CONVERTS_LAND_BARBARIANS"].PrereqPolicy == nil or (GameInfo.Traits["TRAIT_CONVERTS_LAND_BARBARIANS"].PrereqPolicy 
	and player:HasPolicy(GameInfoTypes[GameInfo.Traits["TRAIT_CONVERTS_LAND_BARBARIANS"].PrereqPolicy]))))
	--[[
	-- Hunnic UA
	or (GameInfo.Leader_Traits{ LeaderType = GameInfo.Leaders[player:GetLeaderType()].Type, TraitType = "TRAIT_RAZE_AND_HORSES" }()
	and(GameInfo.Traits["TRAIT_RAZE_AND_HORSES"].PrereqPolicy == nil or (GameInfo.Traits["TRAIT_RAZE_AND_HORSES"].PrereqPolicy 
	and player:HasPolicy(GameInfoTypes[GameInfo.Traits["TRAIT_RAZE_AND_HORSES"].PrereqPolicy]))))
	]]
	then
		local iCountIU = math.floor(player:CountNumBuildings(GameInfoTypes["BUILDING_ARABIA_ISIAMIC_UNIVERSITY"])/7);
		
		for pCity in player:Cities() do
		    if pCity ~= nil then
			-- CityName Change
			if not pCity:IsCapital() and pCity:GetName() == Locale.ConvertTextKey("TXT_KEY_CITY_NAME_SHENDU") then
				pCity:SetName("TXT_KEY_CITY_NAME_LOYANG");
			elseif pCity:IsCapital() and pCity:GetName() == Locale.ConvertTextKey("TXT_KEY_CITY_NAME_LOYANG") then
				pCity:SetName("TXT_KEY_CITY_NAME_SHENDU");
			end
			
			local iNumAIUAA = 0;
			local bHasCH  = false;
			-- Islamic University
			if (iCountIU > 0 and not pCity:IsPuppet() and pCity:IsHasBuilding(GameInfoTypes["BUILDING_ARABIA_ISIAMIC_UNIVERSITY"]))
			-- +5% Culture Cost for New Policies if the city hasn't city hall
			or pCity:IsHasBuilding(GameInfoTypes["BUILDING_REPRESENTATION_CULTURE"])
			then
				local iNumFB = 0;
				local iNumOFB = 0;
				local bHasLab = false;
				for building in GameInfo.Buildings() do
				    if pCity:IsHasBuilding(building.ID) then
					if building.BuildingClass ~= "BUILDINGCLASS_ARABIA_ISIAMIC_UNIVERSITY_ALLAH_AKBAR" then
					    if(building.FaithCost > 0 and building.Cost == -1)
					    or building.BuildingClass == "BUILDINGCLASS_SHRINE"
					    or building.BuildingClass == "BUILDINGCLASS_TEMPLE"
					    then
						iNumFB  = iNumFB  + 1;
					    elseif GameInfo.Building_YieldChanges{BuildingType = building.Type, YieldType = "YIELD_FAITH"}() then
						iNumOFB = iNumOFB + 1;
					    end
					end
					if building.BuildingClass == "BUILDINGCLASS_LABORATORY" then
						bHasLab = true;
					end
					if building.BuildingClass == "BUILDINGCLASS_CITY_HALL_LV1"
					or building.BuildingClass == "BUILDINGCLASS_CITY_HALL_LV2"
					or building.BuildingClass == "BUILDINGCLASS_CITY_HALL_LV3"
					or building.BuildingClass == "BUILDINGCLASS_CITY_HALL_LV4"
					or building.BuildingClass == "BUILDINGCLASS_CITY_HALL_LV5"
					then
						bHasCH  = true;
					end
				    end
				end
				if pCity:IsPuppet() or not pCity:IsHasBuilding(GameInfoTypes["BUILDING_ARABIA_ISIAMIC_UNIVERSITY"]) then
				elseif bHasLab then
					iNumAIUAA = iCountIU *(iNumFB + iNumOFB);
				else
					iNumAIUAA = iCountIU * iNumFB;
				end
				-- iNumAIUAA = math.min(iNumAIUAA,20);
			end
			if pCity:GetNumBuilding(GameInfoTypes["BUILDING_ARABIA_ISIAMIC_UNIVERSITY_ALLAH_AKBAR"]) ~= iNumAIUAA then
				pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_ARABIA_ISIAMIC_UNIVERSITY_ALLAH_AKBAR"], iNumAIUAA);
			end
			
		    -- Policy Effects
			-- +5% Culture Cost for New Policies if the city hasn't city hall
			if pCity:IsHasBuilding(GameInfoTypes["BUILDING_REPRESENTATION_CULTURE_COST"]) then
			    if not pCity:IsHasBuilding(GameInfoTypes["BUILDING_REPRESENTATION_CULTURE"])  or bHasCH then
				pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_REPRESENTATION_CULTURE_COST"], 0);
			    end
			else
			    if pCity:IsHasBuilding(GameInfoTypes["BUILDING_REPRESENTATION_CULTURE"]) and not bHasCH then
				pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_REPRESENTATION_CULTURE_COST"], 1);
			    end
			end
			-- +25% Faith in all cities which have built a World Wonder
			if pCity:GetNumWorldWonders() > 0 and not pCity:IsHasBuilding(GameInfoTypes["BUILDING_WONDER_YIELD_FAITH_MOD"]) then
				pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_WONDER_YIELD_FAITH_MOD"], 1);
			end
			
			-- Remove Effect after enter "World War Era"
			if player:GetCurrentEra() > 5 and pCity:IsHasBuilding(GameInfoTypes["BUILDING_ARTISTIC_GENIUS"]) then
				pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_ARTISTIC_GENIUS"], 0);
			end
			-- Get Extra Consumers & Electricities
			local iNumCon = 0;
			local iNumEle = 0;
			if player:HasPolicy(GameInfoTypes["POLICY_REPUBLIC"]) then
				iNumCon = 2;			-- Has been given by XML, but need to be counted
			end
			if player:HasPolicy(GameInfoTypes["POLICY_MERCHANT_NAVY"]) and pCity:IsCoastal(GameDefines["MIN_WATER_SIZE_FOR_OCEAN"]) then
				iNumCon = iNumCon + 3;
			end
			if player:HasPolicy(GameInfoTypes["POLICY_TOTAL_WAR"]) then
			    if pCity:IsHasBuilding(GameInfoTypes["BUILDING_CITY_SIZE_SMALL"]) then
				iNumCon = iNumCon + 3;
				iNumEle = iNumEle + 3;
			    end
			    if pCity:IsHasBuilding(GameInfoTypes["BUILDING_CITY_SIZE_MEDIUM"]) then
				iNumCon = iNumCon + 3;
				iNumEle = iNumEle + 3;
			    end
			end
			if pCity:GetNumBuilding(GameInfoTypes["BUILDING_CIV_S_P_CON_RESOURCES"]) ~= iNumCon then
				pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CIV_S_P_CON_RESOURCES"], iNumCon);
			end
			if pCity:GetNumBuilding(GameInfoTypes["BUILDING_CIV_S_P_ELE_RESOURCES"]) ~= iNumEle then
				pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CIV_S_P_ELE_RESOURCES"], iNumEle);
			end
			-- Get Extra Happiness
			if player:HasPolicy(GameInfoTypes["POLICY_PROTECTIONISM"]) and pCity:GetWeLoveTheKingDayCounter() > 0 then
				pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_PROTECTIONISM"], 1);
			elseif pCity:IsHasBuilding(GameInfoTypes["BUILDING_PROTECTIONISM"]) then
				pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_PROTECTIONISM"], 0);
			end
			
		    -- Civs' UAs
			-- German UA
			if GameInfo.Leader_Traits{ LeaderType = GameInfo.Leaders[player:GetLeaderType()].Type, TraitType = "TRAIT_CONVERTS_LAND_BARBARIANS" }()
			and(GameInfo.Traits["TRAIT_CONVERTS_LAND_BARBARIANS"].PrereqPolicy == nil or (GameInfo.Traits["TRAIT_CONVERTS_LAND_BARBARIANS"].PrereqPolicy 
			and player:HasPolicy(GameInfoTypes[GameInfo.Traits["TRAIT_CONVERTS_LAND_BARBARIANS"].PrereqPolicy])))
			then
				local Cityname = pCity:GetName()
				local CityProduction = pCity:GetYieldRate(YieldTypes.YIELD_PRODUCTION)
				local ProductionRate = 0
				pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_TB_CONVERTS_LAND_BARBARIANS"],0)
				print ("German City:"..Cityname.."Production:"..CityProduction)
				if CityProduction < 50 then
					print ("Production Too Low!")
				else 
					ProductionRate = math.floor(CityProduction/50)
				--	if ProductionRate > 20 then
				--		ProductionRate = 20
				--	end
					print ("Production to Culture and Science for Germany! Rate:"..ProductionRate)
				end
				
				if ProductionRate >= 1 then
					pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_TB_CONVERTS_LAND_BARBARIANS"],ProductionRate)
				end
				print ("German UA!")
			end
			--[[
			-- Hunnic UA
			if GameInfo.Leader_Traits{ LeaderType = GameInfo.Leaders[player:GetLeaderType()].Type, TraitType = "TRAIT_RAZE_AND_HORSES" }()
			and(GameInfo.Traits["TRAIT_RAZE_AND_HORSES"].PrereqPolicy == nil or (GameInfo.Traits["TRAIT_RAZE_AND_HORSES"].PrereqPolicy 
			and player:HasPolicy(GameInfoTypes[GameInfo.Traits["TRAIT_RAZE_AND_HORSES"].PrereqPolicy])))
			and pCity:IsRazing()
			then
				local Cityname = pCity:GetName()
				print ("Burning pCity:"..Cityname)
				
				local CityPop = pCity:GetPopulation()
				
				if CityPop < 1 then
					print ("Citizens are all dead!")
					return
				end
				
				local GoldOutput = pCity:GetYieldRate(YieldTypes.YIELD_GOLD)
				local ScienceOutput = pCity:GetYieldRate(YieldTypes.YIELD_SCIENCE)
				local CultureOutput = pCity:GetYieldRate(YieldTypes.YIELD_CULTURE)
				local FaithOutput = pCity:GetYieldRate(YieldTypes.YIELD_FAITH)
				
				print ("Gold:"..GoldOutput)
				print ("Science:"..ScienceOutput)
				print ("Culture:"..CultureOutput)
				print ("Faith:"..FaithOutput)
				
				player:ChangeJONSCulture(CultureOutput)
				player:ChangeGold(GoldOutput)
				player:ChangeFaith(FaithOutput)
				
				local team = Teams[player:GetTeam()]
				local teamTechs = team:GetTeamTechs()
				
				if teamTechs ~= nil then 
					local currentTech = player:GetCurrentResearch()
					local researchProgress = teamTechs:GetResearchProgress(currentTech)
					
					if currentTech ~= nil and researchProgress > 0 then
						teamTechs:SetResearchProgress(currentTech, researchProgress + ScienceOutput)
					end
				end
				
				if player:IsHuman() and ScienceOutput > 0 then
			 		local text = Locale.ConvertTextKey( "TXT_KEY_SP_NOTIFICATION_TRAIT_OUTPUT_FROM_RAZING", tostring(ScienceOutput), Cityname)
					Events.GameplayAlertMessage( text )
				end
				print ("Hunnic UA!")
			end
			]]
		    end
		end
	end
	
	
	
	if not player:IsHuman() then ------(only for human players for now)
		print ("Not available for AI!")
		return
	end
	
	
	
-------------Special Policy Effects
	
	if player:HasPolicy(GameInfoTypes["POLICY_RELIGIOUS_POLITICS"]) or player:HasPolicy(GameInfoTypes["POLICY_CAPITALISM"]) then
		SetPolicyPerTurnEffects(playerID)
		print ("Set Policy Per Turn Effects!") 
	end
	
	
-------------Set City Per Turn Effects
	
	local ManpowerRes = player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_MANPOWER"], true)
	local ConsumerRes = player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_CONSUMER"], true)
	local ElectricRes = player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_ELECTRICITY"], true)
	
	print ("International Immigration Start!");
	InternationalImmigration(playerID)
	
--	if ConsumerRes < 0 then
--		AutoAddingMerchants (player,ConsumerRes)
--	end
	
	SetCityPerTurnEffects(playerID)
	SetCityResEffects(playerID,ManpowerRes,ConsumerRes,ElectricRes)
	SetHappinessEffects(playerID)
	
	print("City per Turn Effects set!!")
	
	
---------------------Automation set auto improvement working
	--[[
	if Teams[player:GetTeam()]:IsHasTech(GameInfoTypes["TECH_AUTOMATION_T"]) then
		local iTurnsElapsed = Game.GetElapsedGameTurns()
		local iTurnTrigger = 2
		local GameSpeed = Game.GetGameSpeedType()
		if GameSpeed == 0 then
			iTurnTrigger = 5
		elseif GameSpeed == 1 then
			iTurnTrigger = 4
		elseif GameSpeed == 2 then
			iTurnTrigger = 3
		elseif GameSpeed == 3 then
			iTurnTrigger = 2
		end	
		print ("Automation active cycle:"..iTurnTrigger)

		if iTurnsElapsed % iTurnTrigger == 0 then
			print ("Automation: an active turn!")
			
			local text = Locale.ConvertTextKey( "TXT_KEY_SP_NOTIFICATION_AUTOMATION_ACTIVE")
			Events.GameplayAlertMessage( text )
			ImproveTiles(true);	-- player:IsHuman()
		end
	end
	]]
end---------Function End
GameEvents.PlayerDoTurn.Add(NewCitySystem)



--------------Trigger the city system when player build new city
function HumanFoundingNewCities (iPlayerID,iX,iY)

	local player = Players[iPlayerID]
	if player and player:IsHuman() and player:GetNumCities() >= 1 then
		local pPlot = Map.GetPlot(iX, iY)
		local pCity = pPlot:GetPlotCity()
		
		-- SetCityPerTurnEffects(iPlayerID)
		SetCityLevelbyDistance(pCity);
		SetCityResEffects(iPlayerID,ManpowerRes,ConsumerRes,ElectricRes)
		print ("Human's New city founded!")
	end
end
GameEvents.PlayerCityFounded.Add(HumanFoundingNewCities)





----------Adopt Resource Policy Effects instantly
function ResourcePolicyEffects(playerID, policyID)
local player = Players[playerID]
 
 	if player== nil then
 		return
 	end
	
	if not player:IsHuman() then ------(only for human players for now)
		print ("AI Poicy, not available!")
		return
	end
	
	if player:GetNumCities() < 1 then 
		return
		print("Not enough city!")
	end
	
	if policyID == nil then
		return
	end 
	
	if policyID == GameInfo.Policies["POLICY_MERCANTILISM"].ID or policyID == GameInfo.Policies["POLICY_SPACE_PROCUREMENTS"].ID then
		
		for city in player:Cities() do
			SetCitySpecialistResources(city)
		end
	end
end
GameEvents.PlayerAdoptPolicy.Add(ResourcePolicyEffects);




----------------City sized changing by population growth

function CitySizeChanged(hexX, hexY, population, citySize)
	if hexX == nil or hexY ==nil then
		print ("No Plot")
		return
	end

	local plot = Map.GetPlot(ToGridFromHex(hexX, hexY))
	local city = plot:GetPlotCity()
	
	if city ==nil then
		print ("No cities")
	return
	end
	
	local player = Players[city:GetOwner()]

	
	if player == nil then
		print ("No players")
		return
	end
	
	if player:IsBarbarian() or player:IsMinorCiv() then
		return
	end

	local cityPop = city:GetPopulation()
	if cityPop >= 1 then
		CitySetSize(city,player,cityPop)
		print ("Set CitySize!")
	end
	
	
end-------------Function End
Events.SerialEventCityPopulationChanged.Add(CitySizeChanged)



----------------------------------------------Utilities----------------------------------------
--
---- On city sell a building
--function CitySellGovernment(playerID, cityID, buildingID)
--	local pPlayer = Players[playerID]
--	local pBuilding = GameInfo.Buildings[buildingID]
--	if pBuilding.CityHallLevel > 0 then -- we sell the government!
--		local pCity = pPlayer:GetCityByID(cityID)
--		pCity:SetPuppet(true)
--		pCity:SetNumRealBuilding(bPuppetGov, 1) -- we do not need to consider Venice because they cannot sell governments!
--	end
--end
--GameEvents.CitySoldBuilding.Add(CitySellGovernment)
--







--------------------- International Immigration
function InternationalImmigration(TargetPlayerID)
	if CheckMoveOutCounter == nil or (TargetPlayerID == -1 or nil) then
		return;
	end
	
	for playerID, player in pairs(Players) do
		local OutPlayer = -1;
		local InPlayer  = -1;
		
		if player and player:IsAlive() and player:GetCapitalCity() and not player:IsMinorCiv() and not player:IsBarbarian() and playerID ~= TargetPlayerID then
		    local iCountBuildingID = GameInfoTypes["BUILDING_IMMIGRATION_" .. tostring(TargetPlayerID)];
		    if iCountBuildingID == -1 or nil then
			print ("No CountBuilding");
		    elseif CheckMoveOutCounter(TargetPlayerID,playerID) then
			local ImmigrationCount = CheckMoveOutCounter(TargetPlayerID,playerID);
			local pCapital = player:GetCapitalCity();
			if not pCapital:IsHasBuilding(iCountBuildingID) then
				pCapital:SetNumRealBuilding(iCountBuildingID, ImmigrationCount[2]);
			end
			local iCount = pCapital:GetNumBuilding(iCountBuildingID);
			
			if iCount == 0 or iCount == ImmigrationCount[2]*2 then
			else
				iCount = iCount + ImmigrationCount[1];
			end
			iCount = math.max(0, iCount);
			iCount = math.min(iCount, ImmigrationCount[2]*2);
			
			if     iCount == 0 then
				OutPlayer = TargetPlayerID;
				InPlayer  = playerID;
			elseif iCount == ImmigrationCount[2]*2 then
				OutPlayer = playerID;
				InPlayer  = TargetPlayerID;
			end
			if iCount ~= pCapital:GetNumBuilding(iCountBuildingID) then
				pCapital:SetNumRealBuilding(iCountBuildingID, iCount);
			end
		
			if OutPlayer >= 0 and InPlayer >= 0 then
				local bIsDoImmigration = DoInternationalImmigration(OutPlayer, InPlayer);
				if bIsDoImmigration then
					pCapital:SetNumRealBuilding(iCountBuildingID, ImmigrationCount[2]);
					print ("Successful International Immigration: Player " .. OutPlayer .. " to Player " .. InPlayer);
				else
					print ("Fail International Immigration: Player " .. OutPlayer .. " to Player " .. InPlayer);
				end
			end
		    end
		end
	end
end---------function end
















function DoInternationalImmigration(MoveOutPlayerID, MoveInPlayerID)
	
	local MoveOutPlayer = Players[MoveOutPlayerID]-----------This nation's population tries to move out
	local MoveInPlayer = Players[MoveInPlayerID]-----------Move to this nation
	
	if MoveOutPlayer:GetNumCities() < 1 or MoveInPlayer:GetNumCities() < 1 then
		return false
	end
	
	
	
---------------------------------Immigrant Moving out--------------------
	local MoveOutCities = {}
	local MoveOutCounter = 0
	for pCity in MoveOutPlayer:Cities() do
		local cityPop = pCity:GetPopulation()
		if cityPop > 6 then
			MoveOutCities[MoveOutCounter] = pCity
			MoveOutCounter = MoveOutCounter + 1
		end
	end	
		
	if MoveOutCounter > 0 then
		local iRandChoice = Game.Rand(MoveOutCounter, "Choosing random city");
		local targetCity = MoveOutCities[iRandChoice];
		local Cityname = targetCity:GetName();
		targetCity:ChangePopulation(-1, true)
		print ("Immigrant left this city:"..Cityname)
		
		------------Notification-----------
		if MoveOutPlayer:IsHuman() and targetCity ~= nil then
			local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_IMMIGRANT_LEFT_CITY", targetCity:GetName())
			local heading = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_IMMIGRANT_LEFT_CITY_SHORT")
			MoveOutPlayer:AddNotification(NotificationTypes.NOTIFICATION_STARVING, text, heading, targetCity:GetX(), targetCity:GetY())
		end
		
		------------AI will enhance culture output to encounter!
		if targetCity:GetPopulation() > 15 and not MoveOutPlayer:IsHuman()then
			targetCity:SetFocusType(5)
			print ("Shit human is stealing people from us! AI need more culture!")
		end
	else
		return false
	end




---------------------------------Immigrant Moving In--------------------
	local apCities = {}
	local iCounter = 0
	for pCity in MoveInPlayer:Cities() do
		local cityPop = pCity:GetPopulation()
		if cityPop > 0 and cityPop < 80 and not pCity:IsPuppet() and not pCity:IsRazing() and not pCity:IsResistance() and not pCity:IsForcedAvoidGrowth() and not pCity:IsHasBuilding(GameInfoTypes["BUILDING_IMMIGRANT_RECEIVED"]) and not pCity:IsHasBuilding(GameInfoTypes["BUILDING_NO_UTILITY_WARNING"]) and pCity:GetSpecialistCount(GameInfo.Specialists.SPECIALIST_CITIZEN.ID) <= 0 then
			apCities[iCounter] = pCity
			iCounter = iCounter + 1
		end
	end
	
	
	if iCounter > 0 then
		local iRandChoice = Game.Rand(iCounter, "Choosing random city")
		local targetCity = apCities[iRandChoice]
		local Cityname = targetCity:GetName()
		targetCity:ChangePopulation(1, true)
		targetCity:SetNumRealBuilding(GameInfoTypes["BUILDING_IMMIGRANT_RECEIVED"],1)
		print ("Immigrant Move into this city:"..Cityname)
		
		------------Notification-----------
		if MoveInPlayer:IsHuman() and targetCity ~= nil then
			local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_IMMIGRANT_REACHED_CITY", targetCity:GetName())
			local heading = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_IMMIGRANT_REACHED_CITY_SHORT")
			MoveInPlayer:AddNotification(NotificationTypes.NOTIFICATION_CITY_GROWTH, text, heading, targetCity:GetX(), targetCity:GetY())
		end
		return true
	else
		return false
	
	end


end---------function end



---------------------China's UA
function SetGoldenAgeBonus(player, capCity)
	if player and capCity then
		if player:IsGoldenAge() then
			capCity:SetNumRealBuilding(GameInfoTypes["BUILDING_TB_ART_OF_WAR"],1);
			print("China in Pax Sinica!");
		else
			capCity:SetNumRealBuilding(GameInfoTypes["BUILDING_TB_ART_OF_WAR"],0);
		end
	end
end



function SetCityPerTurnEffects (playerID)

	if Players[playerID] and Players[playerID]:GetNumCities() > 0 then
		local player = Players[playerID];
		for city in player:Cities() do
		
			if city ~= nil then
			
				local Cityname = city:GetName()
				print ("Get the city:"..Cityname)
				
				city:SetNumRealBuilding(GameInfoTypes["BUILDING_IMMIGRANT_RECEIVED"],0)
	--			print ("Reset immigrant status!")
				
				SetCityLevelbyDistance(city)
				
				SetCitySpecialistResources(city)
				
				SetCityAntiNegGoldBonus(city)
		
				-- Add|Remove "Bullring" for Spainish Amusement Park
				if  GameInfo.Leader_Traits{ LeaderType = GameInfo.Leaders[player:GetLeaderType()].Type, TraitType = "TRAIT_SEVEN_CITIES" }()
				and(GameInfo.Traits["TRAIT_SEVEN_CITIES"].PrereqPolicy == nil or (GameInfo.Traits["TRAIT_SEVEN_CITIES"].PrereqPolicy 
				and player:HasPolicy(GameInfoTypes[GameInfo.Traits["TRAIT_SEVEN_CITIES"].PrereqPolicy])))
				then
					if   (  city:IsHasBuilding(GameInfoTypes["BUILDING_AMUSEMENT_PARK"]) and city:IsHasBuilding(GameInfoTypes["BUILDING_SPAIN_BULLRING"]) )
					or (not city:IsHasBuilding(GameInfoTypes["BUILDING_AMUSEMENT_PARK"]) and not city:IsHasBuilding(GameInfoTypes["BUILDING_SPAIN_BULLRING"]) )
					then
					elseif  city:IsHasBuilding(GameInfoTypes["BUILDING_AMUSEMENT_PARK"]) then
						city:SetNumRealBuilding(GameInfoTypes["BUILDING_SPAIN_BULLRING"], 1);
					else
						city:SetNumRealBuilding(GameInfoTypes["BUILDING_SPAIN_BULLRING"], 0);
					end
				end
			end
		end
	end
end-------------Function End



function SetCityAntiNegGoldBonus(city)

	if city == nil then
		print ("City does not exist!")
		return
	end
	if city:IsHasBuilding(GameInfoTypes["BUILDING_BUGFIX_NEGATIVE_GOLD"]) then
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_BUGFIX_NEGATIVE_GOLD"],0)
	end
	if not city:IsHasBuilding(GameInfoTypes["BUILDING_BANK_OF_ENGLAND"])then
	return
	end
	print("Bank of england exists")
	
	if city:GetYieldRate(YieldTypes.YIELD_GOLD) < 0 then
		print ("City Goldyield < 0!")
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_BUGFIX_NEGATIVE_GOLD"],1)
	end

end



function SetCitySpecialistResources(city)

	if city == nil then
		print ("City does not exist!")
		return
	end
	local player = Players[city:GetOwner()];
	if player == nil then
		print ("No players")
		return
	end
	
	city:SetNumRealBuilding(GameInfoTypes["BUILDING_SPECIALISTS_MANPOWER"],0)
	city:SetNumRealBuilding(GameInfoTypes["BUILDING_SPECIALISTS_CONSUMER"],0)
	
	-------------------Set Manpower offered by Engineers
	local CityEngineerCount = city:GetSpecialistCount(GameInfo.Specialists.SPECIALIST_ENGINEER.ID)	
	if CityEngineerCount > 0 then
		print ("Engineers in the city:"..CityEngineerCount)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_SPECIALISTS_MANPOWER"],CityEngineerCount)
	end
	
	-------------------Set Comsumer Goods offered by Merchants
	local CityMerchantCount = city:GetSpecialistCount(GameInfo.Specialists.SPECIALIST_MERCHANT.ID)
	
	if CityMerchantCount > 0 then
		local ComsumerGoodsMultiplier = 2
		print ("Merchant in the city Base:"..CityMerchantCount)
		if player:HasPolicy(GameInfo.Policies["POLICY_MERCANTILISM"].ID) then
			ComsumerGoodsMultiplier = ComsumerGoodsMultiplier + 1
		end
		if player:HasPolicy(GameInfo.Policies["POLICY_SPACE_PROCUREMENTS"].ID) then
			ComsumerGoodsMultiplier = ComsumerGoodsMultiplier + 1
		end
		print ("Merchant Multiplier:"..ComsumerGoodsMultiplier)
		
		local CityMerchantProducingFinal = CityMerchantCount * ComsumerGoodsMultiplier
		print ("Merchant in the city producing Final:"..CityMerchantProducingFinal)
		
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_SPECIALISTS_CONSUMER"],CityMerchantProducingFinal)
	end
end---------function end



function SetCityResEffects(playerID,ManpowerRes,ConsumerRes,ElectricRes)
	if playerID == nil or Players[playerID] == nil or Players[playerID]:GetCapitalCity() == nil
	or ManpowerRes == nil or ConsumerRes == nil or ElectricRes == nil
	then
		return;
	end
	local player = Players[playerID];
	local CaptialCity = player:GetCapitalCity();
	
	CaptialCity:SetNumRealBuilding(GameInfoTypes["BUILDING_MANPOWER_BONUS"],0)
	CaptialCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CONSUMER_BONUS"],0)
	CaptialCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CONSUMER_PENALTY"],0)
	CaptialCity:SetNumRealBuilding(GameInfoTypes["BUILDING_ELECTRICITY_BONUS"],0)
	CaptialCity:SetNumRealBuilding(GameInfoTypes["BUILDING_ELECTRICITY_PENALTY"],0)
	
	local CityTotal = player:GetNumCities()
	local DubCityTotal = CityTotal * 2
	local CityDivd = math.ceil(CityTotal/10)
	print ("Player Total Cities:"..CityTotal)
	
	
	----------------------Manpower Effects
	if ManpowerRes >= 25 then
		local ManpowerRate = math.floor(ManpowerRes/DubCityTotal)
		if ManpowerRate > 7 then
		   ManpowerRate = 7
		end
		

--		local PlayerHurryMod = player:GetHurryModifier(GameInfo.HurryInfos.HURRY_GOLD.ID) 
--		print ("-------------------------------------------------Player HurryModifier:"..PlayerHurryMod)
		
		print ("Manpower Rate:"..ManpowerRate)
		CaptialCity:SetNumRealBuilding(GameInfoTypes["BUILDING_MANPOWER_BONUS"],ManpowerRate)
		print ("Manpower Bonus!")
	else
		CaptialCity:SetNumRealBuilding(GameInfoTypes["BUILDING_MANPOWER_BONUS"],0)
		print ("No Manpower Bonus!")
	end
	
	
		----------------------Consumer Effects
	if ConsumerRes >= 25 then	
		local ConsumerRate = math.floor(ConsumerRes/CityTotal)
		if ConsumerRate >= 50 then
		   ConsumerRate = 50
		end
		print ("Consumer Rate:"..ConsumerRate)
		
		if ConsumerRate >= 1 then
		   CaptialCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CONSUMER_BONUS"],ConsumerRate)
		   CaptialCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CONSUMER_PENALTY"],0)
		   CaptialCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CONSUMER_PENALTY_WARNING"],0)
		   print ("Consumer Bonus!")
		end
	elseif ConsumerRes >= 0 and ConsumerRes < 25 then
		CaptialCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CONSUMER_BONUS"],0)
		CaptialCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CONSUMER_PENALTY"],0)
		CaptialCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CONSUMER_PENALTY_WARNING"],0)
		print ("No Consumer Bonus!")
		
	elseif ConsumerRes < 0 then
		local ConsumerLackRaw = math.floor(ConsumerRes*CityDivd)
		local ConsumerLack = math.abs(ConsumerLackRaw)
		print ("Consumer Lacking:"..ConsumerLack)
		
		
		if ConsumerLack >= 50 then
		   ConsumerLack = 50
		elseif ConsumerLack <= 5 then
			ConsumerLack = 5    
		end
		
		if CaptialCity:IsHasBuilding(GameInfoTypes["BUILDING_CONSUMER_PENALTY_WARNING"]) then
		   CaptialCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CONSUMER_PENALTY"],ConsumerLack)	
		   print ("Consumer Penalty Effective!")
		else
			CaptialCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CONSUMER_PENALTY_WARNING"],1)
			if player:IsHuman() then
				local heading = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_LACKING_CONSUMER_GOODS_WARNING_SHORT")
				local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_LACKING_CONSUMER_GOODS_WARNING")
				player:AddNotification(NotificationTypes.NOTIFICATION_REQUEST_RESOURCE, text, heading, -1, -1, GameInfoTypes["RESOURCE_CONSUMER"])
			end
			print ("Consumer Penalty Warning! Penalty will come if still lacking next turn!")
		end
		
	end
	
	
	
		----------------------Electricity Effects
	if player:GetCurrentEra() >= GameInfo.Eras["ERA_MODERN"].ID then
		local PlayerTechsCount = Teams[player:GetTeam()]:GetTeamTechs():GetNumTechsKnown()
		print ("Player Techs count:"..PlayerTechsCount)
		local ModernTechsCount = PlayerTechsCount - 50
		if ModernTechsCount > 15 then 
			ModernTechsCount = 15
		end	
		print ("Modern Techs count"..ModernTechsCount)
		
		
		if ElectricRes >= 25 then
		   local ElectricityRate = math.floor(ElectricRes/CityTotal)
		   local ElectricityBonusLimit = ModernTechsCount * 5
		   print ("Electricity Bonus Limit:"..ElectricityBonusLimit)
		   
		   if ElectricityBonusLimit > 50 then
			  ElectricityBonusLimit = 50
		   end
		   
		   if ElectricityRate > ElectricityBonusLimit then
			  ElectricityRate = ElectricityBonusLimit
		   end
		  
		  	print ("Electricity Rate:"..ElectricityRate)
		  
		  if ElectricityRate >= 1 then
			 CaptialCity:SetNumRealBuilding(GameInfoTypes["BUILDING_ELECTRICITY_BONUS"],ElectricityRate)			 
			 print ("Electricity Bonus!")
		  end
		  
		elseif ElectricRes >= 0 and ElectricRes < 25 then
		  CaptialCity:SetNumRealBuilding(GameInfoTypes["BUILDING_ELECTRICITY_BONUS"],0)
		  CaptialCity:SetNumRealBuilding(GameInfoTypes["BUILDING_ELECTRICITY_PENALTY"],0)
		  print ("No Electricity Bonus!")
		  
		elseif ElectricRes < 0 then
		   local ElectricityLackRaw = math.floor(ElectricRes*CityDivd)
		   local ElectricityLack = math.abs(ElectricityLackRaw) 
		   local ElectricityPenaltyLimit = ModernTechsCount * 5
		   print ("Electricity Penalty Limit:"..ElectricityPenaltyLimit)
		   
		   if ElectricityPenaltyLimit > 75 then		
			  ElectricityPenaltyLimit = 75
		   end
		   
		   	if ElectricityLack > ElectricityPenaltyLimit then
			   ElectricityLack = ElectricityPenaltyLimit
			end
		   
		   	print ("Electricity lacking:"..ElectricityLack)
		   
		   	CaptialCity:SetNumRealBuilding(GameInfoTypes["BUILDING_ELECTRICITY_PENALTY"],ElectricityLack)
			print ("Electricity Penalty!")
		   
	    end	
	end		
		
			
	
	
end-------------Function End



function CitySetSize(city,player,cityPop)

	if player == nil then
		print ("No players")
		return
	end
	
	if city == nil then
		print ("No city")
		return
	end
	
	if cityPop < 1 then
		print ("No Population!")
		return
	end
	
	
	-- Swedish Trait
	if GameInfo.Leader_Traits{ LeaderType = GameInfo.Leaders[player:GetLeaderType()].Type, TraitType = "TRAIT_DIPLOMACY_GREAT_PEOPLE" }()
	and(GameInfo.Traits["TRAIT_DIPLOMACY_GREAT_PEOPLE"].PrereqPolicy == nil or (GameInfo.Traits["TRAIT_DIPLOMACY_GREAT_PEOPLE"].PrereqPolicy
	and player:HasPolicy(GameInfoTypes[GameInfo.Traits["TRAIT_DIPLOMACY_GREAT_PEOPLE"].PrereqPolicy]))) and cityPop >= 6
	then
		if cityPop >= 6 then
			city:SetNumRealBuilding(GameInfoTypes["BUILDING_TB_DIPLOMACY_GREAT_PEOPLE"],1);
		else
			city:SetNumRealBuilding(GameInfoTypes["BUILDING_TB_DIPLOMACY_GREAT_PEOPLE"],0);
		end
	end
		
	if player:HasPolicy(GameInfoTypes["POLICY_ARISTOCRACY"]) and cityPop < 6 then
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_TRADITION_FOOD_GROWTH"],1)
		print ("Aristocracy Growth Bonus!")
	else
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_TRADITION_FOOD_GROWTH"],0)
	end
	
	if     cityPop >= 80 then
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_TOWN"],1)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_SMALL"],1)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_MEDIUM"],1)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_LARGE"],1)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_XL"],1)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_XXL"],1)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_GLOBAL"],1)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_NO_UTILITY_WARNING"],0)
		
		--[[
		if player:HasPolicy(GameInfoTypes["POLICY_MONARCHY"])then
			city:SetNumRealBuilding(GameInfoTypes["BUILDING_TRADITION_MANPOWER"],5)
			print ("Monarchy Manpower Bonus!")
		else
			city:SetNumRealBuilding(GameInfoTypes["BUILDING_TRADITION_MANPOWER"],0)
		end
		]]
	
	elseif cityPop >= 60 then
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_TOWN"],1)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_SMALL"],1)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_MEDIUM"],1)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_LARGE"],1)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_XL"],1)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_XXL"],1)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_GLOBAL"],0)
		
		--[[
		if player:HasPolicy(GameInfoTypes["POLICY_MONARCHY"])then
			city:SetNumRealBuilding(GameInfoTypes["BUILDING_TRADITION_MANPOWER"],4)
			print ("Monarchy Manpower Bonus!")
		else
			city:SetNumRealBuilding(GameInfoTypes["BUILDING_TRADITION_MANPOWER"],0)
		end
		]]
		
		if city:IsHasBuilding(GameInfo.Buildings["BUILDING_MEDICAL_LAB"].ID) or city:IsHasBuilding(GameInfo.Buildings["BUILDING_VENICE_FONDACO"].ID) then--------Check if city has utility building?
			city:SetNumRealBuilding(GameInfoTypes["BUILDING_NO_UTILITY_WARNING"],0)
		else
			city:SetNumRealBuilding(GameInfoTypes["BUILDING_NO_UTILITY_WARNING"],1)----Stop population growth!
			city:SetFood( 0 )
			print ("This city doesn't have Utility building so the population growth has stopped!")
		end
		
	elseif cityPop >= 40 then
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_TOWN"],1)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_SMALL"],1)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_MEDIUM"],1)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_LARGE"],1)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_XL"],1)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_XXL"],0)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_GLOBAL"],0)
		
		--[[
		if player:HasPolicy(GameInfoTypes["POLICY_MONARCHY"])then
			city:SetNumRealBuilding(GameInfoTypes["BUILDING_TRADITION_MANPOWER"],3)
			print ("Monarchy Manpower Bonus!")
		else
			city:SetNumRealBuilding(GameInfoTypes["BUILDING_TRADITION_MANPOWER"],0)
		end
		]]
	
		if city:IsHasBuilding(GameInfo.Buildings["BUILDING_WATER_TREATMENT_FACTORY"].ID) or city:IsHasBuilding(GameInfo.Buildings["BUILDING_VENICE_FONDACO"].ID) then--------Check if city has utility building?
			city:SetNumRealBuilding(GameInfoTypes["BUILDING_NO_UTILITY_WARNING"],0)
		else
			city:SetNumRealBuilding(GameInfoTypes["BUILDING_NO_UTILITY_WARNING"],1)----Stop population growth!
			city:SetFood( 0 )
			print ("This city doesn't have Utility building so the population growth has stopped!")
		end
	
	
	
	
	elseif cityPop >= 26 then
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_TOWN"],1)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_SMALL"],1)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_MEDIUM"],1)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_LARGE"],1)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_XL"],0)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_XXL"],0)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_GLOBAL"],0)
		
		--[[
		if player:HasPolicy(GameInfoTypes["POLICY_MONARCHY"])then
			city:SetNumRealBuilding(GameInfoTypes["BUILDING_TRADITION_MANPOWER"],2)
			print ("Monarchy Manpower Bonus!")
		else
			city:SetNumRealBuilding(GameInfoTypes["BUILDING_TRADITION_MANPOWER"],0)
		end
		]]

		if city:IsHasBuilding(GameInfo.Buildings["BUILDING_HOSPITAL"].ID) or city:IsHasBuilding(GameInfo.Buildings["BUILDING_VENICE_FONDACO"].ID) then--------Check if city has utility building?
			city:SetNumRealBuilding(GameInfoTypes["BUILDING_NO_UTILITY_WARNING"],0)
		else
			city:SetNumRealBuilding(GameInfoTypes["BUILDING_NO_UTILITY_WARNING"],1)----Stop population growth!
			city:SetFood( 0 )
			print ("This city doesn't have Utility building so the population growth has stopped!")
		end
		
		
	
	elseif cityPop >= 15 then
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_TOWN"],1)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_SMALL"],1)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_MEDIUM"],1)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_LARGE"],0)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_XL"],0)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_XXL"],0)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_GLOBAL"],0)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_TRADITION_FOOD_GROWTH"],0)
		
		--[[
		if player:HasPolicy(GameInfoTypes["POLICY_MONARCHY"])then
			city:SetNumRealBuilding(GameInfoTypes["BUILDING_TRADITION_MANPOWER"],1)
			print ("Monarchy Manpower Bonus!")
		else
			city:SetNumRealBuilding(GameInfoTypes["BUILDING_TRADITION_MANPOWER"],0)
		end
		]]
	
		if city:IsHasBuilding(GameInfo.Buildings["BUILDING_AQUEDUCT"].ID) or city:IsHasBuilding(GameInfo.Buildings["BUILDING_VENICE_FONDACO"].ID) or city:IsHasBuilding(GameInfo.Buildings["BUILDING_BASILICA_CISTERN"].ID) or city:IsHasBuilding(GameInfo.Buildings["BUILDING_TAP_WATER_SUPPLY"].ID) then--------Check if city has utility building?
			city:SetNumRealBuilding(GameInfoTypes["BUILDING_NO_UTILITY_WARNING"],0)
		else
			city:SetNumRealBuilding(GameInfoTypes["BUILDING_NO_UTILITY_WARNING"],1)----Stop population growth!
			city:SetFood( 0 )
			print ("This city doesn't have Utility building so the population growth has stopped!")
		end

	
	elseif cityPop >= 6 then
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_TOWN"],1)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_SMALL"],1)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_MEDIUM"],0)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_LARGE"],0)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_XL"],0)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_XXL"],0)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_GLOBAL"],0)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_NO_UTILITY_WARNING"],0)
		
		-- city:SetNumRealBuilding(GameInfoTypes["BUILDING_TRADITION_MANPOWER"],0)
	else
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_TOWN"],1)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_SMALL"],0)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_MEDIUM"],0)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_LARGE"],0)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_XL"],0)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_XXL"],0)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_SIZE_GLOBAL"],0)
		city:SetNumRealBuilding(GameInfoTypes["BUILDING_NO_UTILITY_WARNING"],0)
		
		-- city:SetNumRealBuilding(GameInfoTypes["BUILDING_TRADITION_MANPOWER"],0)
	end
	
	
	
	------Auto add merchant to produce consumer goods
	
	local ConsumerRes = player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_CONSUMER"], true)

	if ConsumerRes <= 4 then
		print ("Not enough consumer goods!")
		if not city:IsResistance() and not city:IsNoAutoAssignSpecialists() and not city:IsRazing() and city:GetYieldRate(YieldTypes.YIELD_FOOD) >= 2 then
			for building in GameInfo.Buildings() do
				if building.SpecialistType == "SPECIALIST_MERCHANT" then
					local buildingID= building.ID
					if city:IsHasBuilding(buildingID) then
						if city:GetNumSpecialistsAllowedByBuilding(buildingID) > 0 and city:GetNumSpecialistsInBuilding(buildingID) < 2 then
							city:DoTask(TaskTypes.TASK_ADD_SPECIALIST,GameInfo.Specialists.SPECIALIST_MERCHANT.ID,buildingID)
							print ("Auto add a merchant to fill the consumer goods' gap!")
						end
					end
				end
			end
		end
	end



end-------------Function End

----------------- Monarchy -------New Policy
--[[
function PolicyMonarchyAdopt(playerID,policyID)
	local player = Players[playerID]
 
 	if player== nil then
 		return
 	end
	
	if not player:IsHuman() then
		print ("Ai Poicy, not available!")
    	return
	end
	
	if player:GetNumCities() < 1 then 
		return
		print("Not enough city!")
	end
	
	if policyID == nil then
		return
   	end 
   	
	if policyID == GameInfo.Policies["POLICY_MONARCHY"].ID then
		for city in player:Cities() do
			local CityPopManpower = 0
			if not city:IsPuppet() and city:GetPopulation() > 2 then
				local CityPop = city:GetPopulation()
				CityPopManpower = math.floor(CityPop/3)
				print("CityPopManpower:"..CityPopManpower)
				city:SetNumRealBuilding(GameInfoTypes["BUILDING_TRADITION_MANPOWER"], CityPopManpower)
			end
		end
	end 
end
GameEvents.PlayerAdoptPolicy.Add(PolicyMonarchyAdopt);
function PolicyMonarchyCityPop(hexX, hexY, population, citySize)
	if hexX == nil or hexY ==nil then
		print ("No Plot")
	return
	end	

	local plot = Map.GetPlot(ToGridFromHex(hexX, hexY))
	local city = plot:GetPlotCity()
	
	if city == nil then
		print ("No cities")
	return
	end
	
	local player = Players[city:GetOwner()]

	
	if player == nil then
		print ("No players")
		return
	end
	
	if player:IsBarbarian() or player:IsMinorCiv() then
		return
	end

	if player:IsHuman() then
		if player:HasPolicy(GameInfoTypes["POLICY_MONARCHY"]) then
			city:SetNumRealBuilding(GameInfoTypes["BUILDING_TRADITION_MANPOWER"], 0)
			local CityPopManpower = 0
			if not city:IsPuppet() and city:GetPopulation() > 2 then
				local CityPop = city:GetPopulation()
				CityPopManpower = math.floor(CityPop/3)
				print("CityPopManpower:"..CityPopManpower)
				city:SetNumRealBuilding(GameInfoTypes["BUILDING_TRADITION_MANPOWER"], CityPopManpower)
			end
		end
	end
end
Events.SerialEventCityPopulationChanged.Add(PolicyMonarchyCityPop)
]]

------------remove real buildings when a national wonder which sent free building is built(used for grand_shrine & grand_temple)-by Null
function RemoveRealBuildingsiffree(iPlayer, iCity, iBuilding, bGold, bFaith)
	local pPlayer = Players[iPlayer];
	if pPlayer == nil or not pPlayer:IsAlive() or pPlayer:IsMinorCiv() or pPlayer:IsBarbarian() or pPlayer:GetCityByID(iCity) == nil then
		return
	end
	print ("City constructed: "..GameInfo.Buildings[iBuilding].Type)
	local FBC = GameInfo.Buildings[iBuilding].FreeBuilding
	if FBC == nil or GameInfo.Buildings[GameInfo.BuildingClasses[FBC].DefaultBuilding].Cost < 1
	or GameInfo.BuildingClasses[GameInfo.Buildings[iBuilding].BuildingClass].MaxGlobalInstances > 0
	then
		return;
	end
	print ("Free BuildingClass: "..FBC)
	pCity = pPlayer:GetCityByID(iCity)
	pCity:SetNumRealBuilding(iBuilding,0)
	local FreeBuildingType = GameInfo.BuildingClasses[FBC].DefaultBuilding
	-- See if this civilization has a unique building for this building class
	local overrideBuilding = GameInfo.Civilization_BuildingClassOverrides{ BuildingClassType = FBC, CivilizationType = GameInfo.Civilizations[pPlayer:GetCivilizationType()].Type }();
	if overrideBuilding ~= nil then
		FreeBuildingType = overrideBuilding.BuildingType;
	end
	print ("Real building: "..FreeBuildingType)
	for city in pPlayer:Cities() do
		city:SetNumRealBuilding(GameInfoTypes[FreeBuildingType],0)
		print ("Real building removed!")
		local numbuild = city:GetNumBuilding(GameInfoTypes[FreeBuildingType])
		print ("Num of building: "..numbuild)
		local numrb = city:GetNumRealBuilding(GameInfoTypes[FreeBuildingType])
		print ("Num of real building: "..numrb)
	end
	pCity:SetNumRealBuilding(iBuilding,1)
end
GameEvents.CityConstructed.Add(RemoveRealBuildingsiffree)

------------remove real buildings when player captured a city with free wonders which sent free building(used for grand_shrine,grand_temple,temple of artemis and cn tower for now)
function RemoveRealBuildingswhencapturingFreewonders(oldPlayerID, bCapital, iX, iY, newPlayerID, conquest, conquest2)
	if Players[newPlayerID] == nil or Map.GetPlot(iX, iY) == nil or not Map.GetPlot(iX, iY):IsCity() then
		return;
	end
	local pPlayer = Players[newPlayerID];
	local pCity =  Map.GetPlot(iX, iY):GetPlotCity();
	for pBuilding in GameInfo.Buildings() do
		if pBuilding.FreeBuilding ~= nil and not pBuilding.NeverCapture
		and GameInfo.BuildingClasses[pBuilding.BuildingClass].MaxGlobalInstances <= 0
		then
			local FBC = pBuilding.FreeBuilding
			print ("Free BuildingClass is"..FBC)
			if GameInfo.Buildings[GameInfo.BuildingClasses[FBC].DefaultBuilding].Cost >= 0 and pCity:GetNumBuilding(pBuilding.ID)>0 then
				print ("Free Building city wonder provides: "..FBC)
				pCity:SetNumRealBuilding(pBuilding.ID,0)
				local FreeBuildingType = GameInfo.BuildingClasses[FBC].DefaultBuilding
				local overrideBuilding = GameInfo.Civilization_BuildingClassOverrides{ BuildingClassType = FBC, CivilizationType = GameInfo.Civilizations[pPlayer:GetCivilizationType()].Type }();
				if overrideBuilding ~= nil then
					FreeBuildingType = overrideBuilding.BuildingType;
				end
				print ("Real building: "..FreeBuildingType)
				for city in pPlayer:Cities() do
					city:SetNumRealBuilding(GameInfoTypes[FreeBuildingType],0)
					print ("Real building removed!")
					local numbuild = city:GetNumBuilding(GameInfoTypes[FreeBuildingType])
					print ("Num of building: "..numbuild)
					local numrb = city:GetNumRealBuilding(GameInfoTypes[FreeBuildingType])
					print ("Num of real building: "..numrb)
				end
				pCity:SetNumRealBuilding(pBuilding.ID,1)
			end
		end
		
	end
end
GameEvents.CityCaptureComplete.Add(RemoveRealBuildingswhencapturingFreewonders)


-- Check to Set Capital for avoiding CTD -- by CaptainCWB
function CheckCapital(iPlayerID)
	if Players[iPlayerID] == nil or not Players[iPlayerID]:IsAlive() or Players[iPlayerID]:GetNumCities() <= 0 then
		return;
	end
	local pPlayer = Players[iPlayerID];
	local pOCapital = pPlayer:GetCapitalCity();
	local pNCapital = nil;
	local iCityPop = 0;
	local ibIsNewCapital = false;
	
	-- Fix Puppet|Annex for "MayNotAnnex Player" & Capital
	if pOCapital == nil or ((pPlayer:MayNotAnnex() and pOCapital:IsPuppet())
	or (pPlayer:GetBuildingClassCount(GameInfoTypes["BUILDINGCLASS_CAPITAL_MOVEMARK"]) > 0
	and not pOCapital:IsHasBuilding(GameInfoTypes["BUILDING_CAPITAL_MOVEMARK"])))
	then
		for pCity in pPlayer:Cities() do
		    if pCity == nil then
		    elseif not pCity:IsCapital() then
			if pCity:IsHasBuilding(GameInfoTypes["BUILDING_CAPITAL_MOVEMARK"]) then
				pNCapital = pCity;
				ibIsNewCapital = true;
			end
			if pPlayer:MayNotAnnex() and not pCity:IsPuppet() then
				pCity:SetPuppet(true);
				pCity:SetProductionAutomated(true);
			end
			
			if ibIsNewCapital then
			-- the first NotPuppet City will be the New Capital!
			elseif not pCity:IsPuppet() and not pCity:IsRazing() then
				pNCapital = pCity;
				ibIsNewCapital = true;
			-- the most Population City will be the New Capital!
			elseif pCity:GetPopulation() > iCityPop then
				pNCapital = pCity;
				iCityPop = pCity:GetPopulation();
			end
		    elseif pPlayer:MayNotAnnex() and pCity:IsPuppet() then
			pCity:SetPuppet(false);
			pCity:SetOccupied(false);
			pCity:SetProductionAutomated(false);
		    end
		end
		
		if pNCapital and pNCapital ~= pOCapital then
			-- Palace
			local iPalaceID = GameInfo.Buildings.BUILDING_PALACE.ID;
			local overridePalace = GameInfo.Civilization_BuildingClassOverrides{ BuildingClassType = "BUILDINGCLASS_PALACE", CivilizationType = GameInfo.Civilizations[pPlayer:GetCivilizationType()].Type }();
			if overridePalace ~= nil then
				iPalaceID = GameInfo.Buildings[overridePalace.BuildingType].ID;
			end
			pNCapital:SetNumRealBuilding(iPalaceID, 1);
			
			for building in GameInfo.Buildings() do
				-- Remove "Corrupt" from New
				if pNCapital:IsHasBuilding(building.ID)
				and(building.BuildingClass == "BUILDINGCLASS_CITY_HALL_LV1"
				or  building.BuildingClass == "BUILDINGCLASS_CITY_HALL_LV2"
				or  building.BuildingClass == "BUILDINGCLASS_CITY_HALL_LV3"
				or  building.BuildingClass == "BUILDINGCLASS_CITY_HALL_LV4"
				or  building.BuildingClass == "BUILDINGCLASS_CITY_HALL_LV5"
				or  building.BuildingClass == "BUILDINGCLASS_PUPPET_GOVERNEMENT"
				or  building.BuildingClass == "BUILDINGCLASS_CONSTABLE"
				or  building.BuildingClass == "BUILDINGCLASS_SHERIFF_OFFICE"
				or  building.BuildingClass == "BUILDINGCLASS_POLICE_STATION"
				or  building.BuildingClass == "BUILDINGCLASS_PROCURATORATE"
				)then
					pNCapital:SetNumRealBuilding(building.ID, 0);
				end
			
				if pOCapital then
					-- Palace
					if pOCapital:IsHasBuilding(building.ID) and building.Capital then
						local i = pOCapital:GetNumBuilding(building.ID);
						pOCapital:SetNumRealBuilding(building.ID, 0);
						if pNCapital:GetNumBuilding(building.ID) ~= i then
							pNCapital:SetNumRealBuilding(building.ID, i);
						end
					end
					
				-- Remove "BonusBT" from Old
					if pOCapital:IsHasBuilding(building.ID)
					and(building.Type == "BUILDING_ELECTRICITY_BONUS"
					or  building.Type == "BUILDING_ELECTRICITY_PENALTY"
					or  building.Type == "BUILDING_MANPOWER_BONUS"
					or  building.Type == "BUILDING_CONSUMER_BONUS"
					or  building.Type == "BUILDING_CONSUMER_PENALTY_WARNING"
					or  building.Type == "BUILDING_CONSUMER_PENALTY"
					or  building.Type == "BUILDING_TB_ART_OF_WAR"
					or  building.Type == "BUILDING_HAPPINESS_TOURISMBOOST"
					or  building.Type == "BUILDING_TRADE_TO_SCIENCE"
					or  building.Type == "BUILDING_RATIONALISM_HAPPINESS"
				--	or  building.Type == "BUILDING_SCHOLASTICISM"
					or  building.Type == "BUILDING_TROOPS_DEBUFF"
					)then
						pOCapital:SetNumRealBuilding(building.ID, 0);
					end
					
					-- Move Policy Buildings & Count Buildings
					local policFreeBCCapital = GameInfo.Policy_FreeBuildingClassCapital{ BuildingClassType = building.BuildingClass }()
					if pOCapital:IsHasBuilding(building.ID) and (policFreeBCCapital ~= nil or building.BuildingClass == "BUILDINGCLASS_COUNT_BUILIDNGS") then
						local i = pOCapital:GetNumBuilding(building.ID);
						pOCapital:SetNumRealBuilding(building.ID, 0);
						pNCapital:SetNumRealBuilding(building.ID, i);
					end
				end
			end
			print("Captial Moved!")
			
			if pNCapital:IsRazing() then
				Network.SendDoTask(pNCapital:GetID(), TaskTypes.TASK_UNRAZE, -1, -1, false, false, false, false);
				-- pNCapital:SetNeverLost(true);
			end
		end
	end
end
GameEvents.PlayerDoTurn.Add(CheckCapital)



print("New City Rules Check Pass!")
