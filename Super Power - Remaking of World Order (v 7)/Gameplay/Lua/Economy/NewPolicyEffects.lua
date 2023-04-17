-- NewPolicyEffects

--include( "UtilityFunctions.lua" )


--------------------------------------------------------------
-------------------------------------------------------------------------New Policy Effects-----------------------------------------------------------------------
-- Militarism reduce city resistance time
function OnCityCaptured(oldPlayerID, iCapital, iX, iY, newPlayerID, bConquest, iGreatWorksPresent, iGreatWorksXferred)
	local PolicyAuto = GameInfo.Policies["POLICY_MILITARISM"].ID
	local NewPlayer = Players[newPlayerID]
	local oldPlayer = Players[oldPlayerID]
	local resModifier = -50
	local pPlot = Map.GetPlot(iX, iY)
	local pCity = pPlot:GetPlotCity()

	if NewPlayer == nil then
		print("No players")
		return
	end

	if NewPlayer:IsBarbarian() or NewPlayer:IsMinorCiv() then
		print("Minors are Not available - City Captured!")
		return
	end

	if NewPlayer:HasPolicy(PolicyAuto) then
		local resTime = pCity:GetResistanceTurns()
		local CityPop = pCity:GetPopulation()
		print("resTime=" .. resTime)

		if CityPop < 6 or oldPlayer:IsHasLostCapital() then
			pCity:ChangeResistanceTurns(-resTime)
			print("War Propaganda effect, resTime:" .. pCity:GetResistanceTurns())
			print("should be 0 turn")
		else
			if resTime > 1 then
				local resTimeRatio = resTime * resModifier / 100
				local resTimeChange = math.floor(resTimeRatio)
				print("resTimeChange=" .. resTimeChange)
				pCity:ChangeResistanceTurns(resTimeChange)
				print("War Propaganda effect, resTime:" .. pCity:GetResistanceTurns())
				print("should be:" .. resTime / 2 + 0.5)
			end
		end
	end
end
GameEvents.CityCaptureComplete.Add(OnCityCaptured)





-- Citizenship offer free Worker when new city founded
function FreeUnitNewCity(iPlayerID,iX,iY)
	local pPlayer = Players[iPlayerID]
	local pPlot = Map.GetPlot(iX, iY)
	local PolicyLiberty = GameInfo.Policies["POLICY_CITIZENSHIP"].ID
	local WorkerID = GameInfoTypes.UNIT_WORKER
	
	if pPlayer:HasPolicy(PolicyLiberty) then
--		print ("Free Policy Unit!")
		local overrideUnit = GameInfo.Civilization_UnitClassOverrides{ UnitClassType = "UNITCLASS_WORKER", CivilizationType = GameInfo.Civilizations[pPlayer:GetCivilizationType()].Type }();
		if overrideUnit and overrideUnit.UnitType then
			WorkerID = GameInfoTypes[overrideUnit.UnitType];
   	 	end
   	 	local NewUnit = pPlayer:InitUnit(WorkerID, iX, iY, UNITAI_WORKER)
		NewUnit:JumpToNearestValidPlot()    
	end
end

GameEvents.PlayerCityFounded.Add(FreeUnitNewCity)


--
--
--
---- Honor training unit gain Science
--function UnitGainScience(iPlayer, iCity, iUnit, bGold, bFaith)
--   local player = Players[iPlayer]
--   local pUnit = player:GetUnitByID(iUnit)
--   local policyID = GameInfoTypes["POLICY_MILITARY_CASTE"]
--   
--  	if player == nil then
--		print ("No players")
--		return
--	end 
--	
--
--	
--	if player:IsBarbarian() or player:IsMinorCiv() then
--		print ("Minors are Not available - CityTrained!")
--    	return
--	end
--	
--	if player:GetNumCities() < 1 then 
--		print ("No Cities!")
--		return
--	end
--	
--	 if pUnit == nil then
--		print ("No Units")
--		return
--   	end 
--   
--
--
--	if player:HasPolicy(policyID) and pUnit:IsCombatUnit() then
----		print("New unit built!")
--
--		if not player:IsTurnActive() then
--			print ("Not Current Player")
--			return
--		end 
--	
--
--		local team = Teams[player:GetTeam()]
--		local teamTechs = team:GetTeamTechs()
--		
--		if not teamTechs then --------------Avoid AI crash if a Tech is finished right after a unit built
--			print ("no Tech under researching")
--			return
--		end
--		
--		local currentTech = player:GetCurrentResearch()
--		local researchProgress = teamTechs:GetResearchProgress(currentTech)
--		
--		if not currentTech then
--			return
--		end
--		
--		if not researchProgress then
--			return
--		end
--		
--		
--		local pUnitStrength = pUnit:GetBaseCombatStrength()
--		
--		if pUnitStrength < 1 then 
--			return
--		end
--		
--		
--		if pUnit:IsRanged() then
--			if pUnit:GetBaseCombatStrength() < pUnit:GetBaseRangedCombatStrength()	then
--				pUnitStrength = pUnit:GetBaseRangedCombatStrength()	
--			else
--				pUnitStrength = pUnit:GetBaseCombatStrength()	
--			end
--		end
--		
--		local adjustedBonus = math.ceil(pUnitStrength*0.5)
--		-- Give the Science
--		
--		print ("researchProgress "..researchProgress)
--		if researchProgress > 0 then
--   			teamTechs:SetResearchProgress(currentTech, researchProgress + adjustedBonus)
--   			local text
--			if adjustedBonus > 0 then		   
--			   text = Locale.ConvertTextKey( "TXT_KEY_SP_NOTIFICATION_UNIT_GAIN_SCIENCE", tostring(adjustedBonus), pUnit:GetName())
--			end
--			if player:IsHuman() then
--				Events.GameplayAlertMessage( text )
--			end
--		end
--		
--
--		
--		
--
--		-- Send a notification to the player
----		if player:IsHuman()then
----			local text = Locale.ConvertTextKey("TXT_KEY_SP_POLICY_SCIENCE_FROM_UNIT", tostring(adjustedBonus), pUnit:GetName())
----			player:AddNotification(NotificationTypes.NOTIFICATION_GENERIC, text, text)
----		end
--	end
--end
--GameEvents.CityTrained.Add(UnitGainScience)
--



function PolicyAdoptedEffects(playerID,policyID)

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

	if     policyID == GameInfo.Policies["POLICY_ARISTOCRACY"].ID then
		FasterFoodGrowth(playerID)
	elseif policyID == GameInfo.Policies["POLICY_RELIGIOUS_POLITICS"].ID or policyID == GameInfo.Policies["POLICY_CAPITALISM"].ID then
		SetPolicyPerTurnEffects(playerID)
	elseif policyID == GameInfo.Policies["POLICY_RATIONALISM"].ID or policyID == GameInfo.Policies["POLICY_TREATY_ORGANIZATION"].ID then
		SetHappinessEffects(playerID)
--	elseif policyID == GameInfo.Policies["POLICY_DICTATORSHIP_PROLETARIAT"].ID then
--		ChangeACBuildings(playerID)
--	elseif policyID == GameInfo.Policies["POLICY_REPRESENTATION"].ID then
--		ReducePolicyCost(playerID)
--	elseif policyID == GameInfo.Policies["POLICY_MONARCHY"].ID then
--		AddAdditionalManpower(playerID)
	end
end
GameEvents.PlayerAdoptPolicy.Add(PolicyAdoptedEffects);

function SPReformeBeliefs(iPlayer, iReligion, iBelief)
	if Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION) or iPlayer == -1 or not Players[iPlayer]:HasCreatedReligion()
	or Game.GetHolyCityForReligion(iReligion, iPlayer) == nil
	then
		return;
	end
	
	local pPlayer  = Players[iPlayer];
	local holyCity = Game.GetHolyCityForReligion(iReligion, iPlayer);
	if     GameInfo.Beliefs[iBelief].Type == "BELIEF_UNITY_OF_PROPHETS" then
		local iProphetID = GameInfoTypes.UNIT_PROPHET;
		local overrideUnit = GameInfo.Civilization_UnitClassOverrides{ UnitClassType = "UNITCLASS_PROPHET", CivilizationType = GameInfo.Civilizations[pPlayer:GetCivilizationType()].Type }();
		if overrideUnit and overrideUnit.UnitType then
			iProphetID = GameInfoTypes[overrideUnit.UnitType];
		end
		pPlayer:InitUnit(iProphetID, holyCity:GetX(), holyCity:GetY(), UNITAI_PROPHET)
	elseif GameInfo.Beliefs[iBelief].Type == "BELIEF_TO_GLORY_OF_GOD" then
		holyCity:SetNumRealBuilding(GameInfoTypes["BUILDING_BELIEF_TO_GLORY_OF_GOD"], 1);
	elseif GameInfo.Beliefs[iBelief].Type == "BELIEF_UNDERGROUND_SECT" then
		holyCity:SetNumRealBuilding(GameInfoTypes["BUILDING_BELIEF_UNDERGROUND_SECT"], 1);
		holyCity:SetNumRealBuilding(GameInfoTypes["BUILDING_BELIEF_UNDERGROUND_SECT"], 0);
	elseif GameInfo.Beliefs[iBelief].Type == "BELIEF_EVANGELISM" then
		g_iEMSReligion = iReligion;
		for iPlayer = 0, GameDefines.MAX_CIV_PLAYERS - 1 do
			local player = Players[iPlayer];
			if pPlayer and pPlayer:GetNumCities() > 0 then
				for city in player:Cities() do
					if city:GetReligiousMajority() == iReligion then
						city:SetNumRealBuilding(GameInfoTypes["BUILDING_EXTRA_RELIGION_SPREADS"], 1);
					end
				end
			end
		end
	end
end
GameEvents.ReligionReformed.Add(SPReformeBeliefs)
function SPEvangelism(iOwner, iReligion, iX, iY)
	local pPlot = Map.GetPlot(iX, iY);
	if pPlot and pPlot:IsCity() then
		local pCity = pPlot:GetPlotCity();
		if g_iEMSReligion == -1 then
		elseif iReligion == g_iEMSReligion then
			pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_EXTRA_RELIGION_SPREADS"], 1);
		elseif pCity:IsHasBuilding(GameInfoTypes["BUILDING_EXTRA_RELIGION_SPREADS"]) then
			pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_EXTRA_RELIGION_SPREADS"], 0);
		end
	end
end
GameEvents.CityConvertsReligion.Add(SPEvangelism)


--[[
function NewPolicyEffectsAPTS()
	local tSetScholasticismBuilding = {};
	for iCS = GameDefines.MAX_MAJOR_CIVS, GameDefines.MAX_PLAYERS-2, 1 do
		if  Players[iCS]:IsAlive() and Players[iCS]:IsMinorCiv()
		and Players[iCS]:GetAlly() ~= -1 and Players[Players[iCS]:GetAlly()]:IsAlive()
		and Players[Players[iCS]:GetAlly()]:HasPolicy(GameInfo.Policies["POLICY_SCHOLASTICISM"].ID)
		then
			if tSetScholasticismBuilding[Players[iCS]:GetAlly()] == nil then
				tSetScholasticismBuilding[Players[iCS]:GetAlly()] = 0;
			end
			tSetScholasticismBuilding[Players[iCS]:GetAlly()] = tSetScholasticismBuilding[Players[iCS]:GetAlly()] + 1;
		end
	end
	for iCiv = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
		if tSetScholasticismBuilding[iCiv] == nil then
			tSetScholasticismBuilding[iCiv] = 0;
		end
		if  Players[iCiv]:IsAlive() and not Players[iCiv]:IsMinorCiv() and not Players[iCiv]:IsBarbarian()
		and Players[iCiv]:GetCapitalCity() ~= nil
		and Players[iCiv]:GetBuildingClassCount(GameInfoTypes["BUILDINGCLASS_SCHOLASTICISM"]) ~= tSetScholasticismBuilding[iCiv]
		then
			Players[iCiv]:GetCapitalCity():SetNumRealBuilding(GameInfoTypes["BUILDING_SCHOLASTICISM"], tSetScholasticismBuilding[iCiv]);
		end
	end
end
Events.ActivePlayerTurnStart.Add(NewPolicyEffectsAPTS)
]]


----------------------------------------------Utilities----------------------------------------

function FasterFoodGrowth(playerID)
	local player = Players[playerID];
	for city in player:Cities() do
		if city:IsHasBuilding(GameInfo.Buildings["BUILDING_CITY_SIZE_TOWN"].ID) then
			local pPopulation = city:GetPopulation()
			local pThreshold = city:GrowthThreshold()
			city:ChangeFood(pThreshold)
			city:SetNumRealBuilding(GameInfoTypes["BUILDING_TRADITION_FOOD_GROWTH"],1)
			print ("Aristocracy Growth Bonus!")
		end
	end
end



--[[
function AddAdditionalManpower (playerID)
	local player = Players[playerID];
	for city in player:Cities() do
		if city:IsHasBuilding(GameInfo.Buildings["BUILDING_CITY_SIZE_GLOBAL"].ID) then
			city:SetNumRealBuilding(GameInfoTypes["BUILDING_TRADITION_MANPOWER"],5)
			
		elseif city:IsHasBuilding(GameInfo.Buildings["BUILDING_CITY_SIZE_XXL"].ID) then
			city:SetNumRealBuilding(GameInfoTypes["BUILDING_TRADITION_MANPOWER"],4)
			
		elseif city:IsHasBuilding(GameInfo.Buildings["BUILDING_CITY_SIZE_XL"].ID) then
			city:SetNumRealBuilding(GameInfoTypes["BUILDING_TRADITION_MANPOWER"],3)
			
		elseif city:IsHasBuilding(GameInfo.Buildings["BUILDING_CITY_SIZE_LARGE"].ID) then
			city:SetNumRealBuilding(GameInfoTypes["BUILDING_TRADITION_MANPOWER"],2)
			
		elseif city:IsHasBuilding(GameInfo.Buildings["BUILDING_CITY_SIZE_MEDIUM"].ID) then
			city:SetNumRealBuilding(GameInfoTypes["BUILDING_TRADITION_MANPOWER"],1)
		end
	end
end



function ReducePolicyCost(playerID)
	local player = Players[playerID];
	for pCity in player:Cities() do
		if not pCity:IsPuppet() and not pCity:IsCapital() then
			pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_REPRESENTATION_CULTURE"],1)
			print ("Player has the Representation policy!")
		end
	end
end



function ChangeACBuildings(playerID)
	local player = Players[playerID];
	for pCity in player:Cities() do
		local iDefaultBuildingID = nil;
		local iUniqueBuildingID  = nil;
		
		if     pCity:IsHasBuilding(GameInfo.Buildings["BUILDING_CITY_HALL_LV2"].ID) then
		
		    iDefaultBuildingID = GameInfo.Buildings.BUILDING_CONSTABLE.ID;
		    local overrideBuilding = GameInfo.Civilization_BuildingClassOverrides{ BuildingClassType = "BUILDINGCLASS_CONSTABLE", CivilizationType = GameInfo.Civilizations[player:GetCivilizationType()].Type }();
		    if overrideBuilding ~= nil then
			iUniqueBuildingID = GameInfo.Buildings[overrideBuilding.BuildingType].ID;
		    else
			iUniqueBuildingID = nil;
		    end
		    if pCity:IsHasBuilding(iDefaultBuildingID) then
			pCity:SetNumRealBuilding(iDefaultBuildingID,0);
		    end
		    if iUniqueBuildingID and pCity:IsHasBuilding(iUniqueBuildingID) then
		   	pCity:SetNumRealBuilding(iUniqueBuildingID,0);
		    end
		    
		    iDefaultBuildingID = GameInfo.Buildings.BUILDING_CITY_HALL_LV1.ID;
		    local overrideBuilding = GameInfo.Civilization_BuildingClassOverrides{ BuildingClassType = "BUILDINGCLASS_CITY_HALL_LV1", CivilizationType = GameInfo.Civilizations[player:GetCivilizationType()].Type }();
		    if overrideBuilding ~= nil then
			iUniqueBuildingID = GameInfo.Buildings[overrideBuilding.BuildingType].ID;
		    else
			iUniqueBuildingID = nil;
		    end
		    if iUniqueBuildingID ~= nil then
			pCity:SetNumRealBuilding(iUniqueBuildingID,1);
		    else
			pCity:SetNumRealBuilding(iDefaultBuildingID,1);
		    end
		    pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_HALL_LV2"],0)
		    pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_HALL_LV3"],0)
		    pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_HALL_LV4"],0)
		    pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_HALL_LV5"],0)
		    
		    
		    
		elseif pCity:IsHasBuilding(GameInfo.Buildings["BUILDING_CITY_HALL_LV3"].ID) then

		    if pCity:IsHasBuilding(GameInfo.Buildings["BUILDING_SHERIFF_OFFICE"].ID) then
			iDefaultBuildingID = GameInfo.Buildings.BUILDING_CONSTABLE.ID;
			local overrideBuilding = GameInfo.Civilization_BuildingClassOverrides{ BuildingClassType = "BUILDINGCLASS_CONSTABLE", CivilizationType = GameInfo.Civilizations[player:GetCivilizationType()].Type }();
			if overrideBuilding ~= nil then
				iUniqueBuildingID = GameInfo.Buildings[overrideBuilding.BuildingType].ID;
			else
				iUniqueBuildingID = nil;
			end
			pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_SHERIFF_OFFICE"],0); 
			if iUniqueBuildingID then
				pCity:SetNumRealBuilding(iUniqueBuildingID,1);
			else
				pCity:SetNumRealBuilding(iDefaultBuildingID,1);
				
			end
		    end
		    
		    pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_HALL_LV1"],0)
		    pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_HALL_LV2"],1)
		    pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_HALL_LV3"],0)
		    pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_HALL_LV4"],0)
		    pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_HALL_LV5"],0)
		    
		    
		    
		elseif pCity:IsHasBuilding(GameInfo.Buildings["BUILDING_CITY_HALL_LV4"].ID) then
		
		    if pCity:IsHasBuilding(GameInfo.Buildings["BUILDING_POLICE_STATION"].ID) then
			pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_POLICE_STATION"],0); 
			pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_SHERIFF_OFFICE"],1); 
		    end
		    
		    pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_HALL_LV1"],0)
		    pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_HALL_LV2"],0)
		    pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_HALL_LV3"],1)
		    pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_HALL_LV4"],0)
		    pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_HALL_LV5"],0)
		    
		elseif pCity:IsHasBuilding(GameInfo.Buildings["BUILDING_CITY_HALL_LV5"].ID) then
		
		    if pCity:IsHasBuilding(GameInfo.Buildings["BUILDING_PROCURATORATE"].ID) then
			pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_PROCURATORATE"],0); 
			pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_POLICE_STATION"],1); 
		    end	
		    
		    pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_HALL_LV1"],0)
		    pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_HALL_LV2"],0)
		    pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_HALL_LV3"],0)
		    pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_HALL_LV4"],1)
		    pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CITY_HALL_LV5"],0)
		    
		end
		print ("AC building changed!")
	end
end
]]


print("New Policy Effects Check Pass!")