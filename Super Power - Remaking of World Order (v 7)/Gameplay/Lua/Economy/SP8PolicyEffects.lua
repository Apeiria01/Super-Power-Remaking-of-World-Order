-- ********************************************************
-- POLICY_HORSEMAN_TRAINING and POLICY_MILITARY_CASTE
-- ******************************************************** 
function SPEBattleCustomDamage(iBattleUnitType, iBattleType,
	iAttackPlayerID, iAttackUnitOrCityID, bAttackIsCity, iAttackDamage,
	iDefensePlayerID, iDefenseUnitOrCityID, bDefenseIsCity, iDefenseDamage,
	iInterceptorPlayerID, iInterceptorUnitOrCityID, bInterceptorIsCity, iInterceptorDamage)

	print("SPEBattleCustomDamage");
	local additionalDamage = 0;

	local attPlayer = Players[iAttackPlayerID]
	local defPlayer = Players[iDefensePlayerID]
	if attPlayer == nil or defPlayer == nil then
		return 0
	end

	if iBattleUnitType == GameInfoTypes["BATTLEROLE_ATTACKER"] then
		if bAttackIsCity then
			return 0
		end

		local attUnit = attPlayer:GetUnitByID(iAttackUnitOrCityID)
		if attUnit == nil then
			return 0
		end

		local attUnitCombatType = attUnit:GetUnitCombatType() 

		if attPlayer:HasPolicy(GameInfo.Policies["POLICY_HORSEMAN_TRAINING"].ID) 
		and ((attUnitCombatType == GameInfoTypes.UNITCOMBAT_MOUNTED) or (attUnitCombatType == GameInfoTypes.UNITCOMBAT_ARMOR))
		then
			additionalDamage = additionalDamage + 5
		end

		if attPlayer:HasPolicy(GameInfo.Policies["POLICY_MILITARY_CASTE"].ID) then
			if ( (attUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_ARCHERY_COMBAT"].ID) ) 
			or ( (attUnitCombatType == GameInfoTypes.UNITCOMBAT_HELICOPTER) ) )
			then
				additionalDamage = additionalDamage + 5
			end

			if bDefenseIsCity then
				local defCity = defPlayer:GetCityByID(iDefenseUnitOrCityID) 
				if defCity == nil then return 0 end

				if attUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_CITY_SIEGE"].ID) 
				or attUnit:GetDomainType() == DomainTypes.DOMAIN_AIR then
					additionalDamage = additionalDamage + defCity:GetMaxHitPoints() * 0.1
				end
			end
		end
	end
	return additionalDamage
end
GameEvents.BattleCustomDamage.Add(SPEBattleCustomDamage)

function SPEConquestedCity(oldOwnerID, isCapital, cityX, cityY, newOwnerID, numPop, isConquest)
    local pPlayer = Players[newOwnerID]
    local capturedPlayer = Players[oldOwnerID]
	if pPlayer == nil or capturedPlayer == nil then
	 	return
	end

	if pPlayer:HasPolicy(GameInfo.Policies["POLICY_WARRIOR_CODE"].ID) then  
		local conquestedCityPlot = Map.GetPlot(cityX, cityY)
		local pCity = conquestedCityPlot:GetPlotCity()
		if pCity == nil then return end

		local pTeam = Teams[pPlayer:GetTeam()]
		if pTeam == nil then return end

		if pTeam:IsHasTech(GameInfo.Technologies["TECH_MATHEMATICS"].ID)
		and isConquest
		and newOwnerID ~= pCity:GetOriginalOwner()
		then 
			local buildingClass = "BUILDINGCLASS_COURTHOUSE"
			local thisCivilizationType = pPlayer:GetCivilizationType()
			local buildingType = GameInfoTypes["BUILDING_COURTHOUSE"]
			
			for row in GameInfo.Civilization_BuildingClassOverrides() do

				if (GameInfoTypes[row.CivilizationType] == thisCivilizationType and row.BuildingClassType == buildingClass) then
					print("POLICY_WARRIOR_CODE: Courthouse UB!")
					buildingType = row.BuildingType
				end
			end
			print("POLICY_WARRIOR_CODE: set courthouse!")
			pCity:SetNumRealBuilding(buildingType,1)
		end 				
	end

end
GameEvents.CityCaptureComplete.Add(SPEConquestedCity) 


-- ********************************************************
-- POLICY_BRANCH_EXPLORATION
-- ******************************************************** 
function SPEAdoptPolicyBranch( playerID, policybranchID )
	
    local pPlayer = Players[playerID]	
    if pPlayer == nil or pPlayer:IsBarbarian() then return end
	if(policybranchID == GameInfo.PolicyBranchTypes["POLICY_BRANCH_EXPLORATION"].ID) then
		for iUnit in pPlayer:Units() do
			if iUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_OCEAN_IMPASSABLE"].ID) 
           			and iUnit:GetDomainType() == DomainTypes.DOMAIN_SEA
            			and iUnit:IsCombatUnit()
            			then
				print("POLICY_BRANCH_EXPLORATION: adopt")
				iUnit:SetHasPromotion(GameInfoTypes.PROMOTION_OCEAN_IMPASSABLE,false)
			end
		end	
	end
end
GameEvents.PlayerAdoptPolicyBranch.Add(SPEAdoptPolicyBranch)

function SPEPolicyUnitCreated(iPlayerID, iUnitID)

    local pPlayer = Players[iPlayerID]	
    if pPlayer == nil or pPlayer:IsBarbarian() then return end
    local pUnit = pPlayer:GetUnitByID(iUnitID)
    if pUnit == nil then return end

    if pPlayer:HasPolicyBranch(GameInfo.PolicyBranchTypes["POLICY_BRANCH_EXPLORATION"].ID) 
    and pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_OCEAN_IMPASSABLE"].ID) 
    then
        if pUnit:GetDomainType() == DomainTypes.DOMAIN_SEA
        and pUnit:IsCombatUnit()
        then 
			print("POLICY_BRANCH_EXPLORATION: create unit");
			pUnit:SetHasPromotion(GameInfoTypes.PROMOTION_OCEAN_IMPASSABLE,false)
		end
    end

end
Events.SerialEventUnitCreated.Add(SPEPolicyUnitCreated)

--POLICY_MARITIME_INFRASTRUCTURE: +50% build speed on water tiles
function SPEBuildSpeedIncrease(iPlayer, iUnit, iX, iY, iBuild, bStarting)
	local pPlayer = Players[iPlayer]
	local unit = pPlayer:GetUnitByID(iUnit)
 
	if pPlayer == nil or pPlayer:IsMinorCiv() or pPlayer:IsBarbarian() then
		return
	end
 
	if pPlayer:HasPolicy(GameInfo.Policies["POLICY_MARITIME_INFRASTRUCTURE"].ID) then 
		if GameInfo.Builds[iBuild].Water == true then
			print("SPEBuildSpeedIncrease!", iX, iY);
			Map.GetPlot(iX, iY):ChangeBuildProgress(unit:GetBuildType(),(0.5)*unit:WorkRate(),pPlayer:GetTeam())
		end
	end
end 
GameEvents.PlayerBuilding.Add(SPEBuildSpeedIncrease)

-- ********************************************************
-- POLLICY_COLLECTIVE_RULE
-- ******************************************************** 
local PolicyCollectiveRuleID = GameInfo.Policies["POLICY_COLLECTIVE_RULE"].ID
local PolicyCollectiveRuleFreeID = GameInfo.Policies["POLICY_COLLECTIVE_RULE_FREE"].ID
function SPEPlayerIntoNewEra(eTeam, eEra, bFirst)
	for iPlayer=0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
		local pPlayer = Players[iPlayer]

		if pPlayer:IsAlive()
		and pPlayer:GetTeam() == eTeam
		and eEra >= GameInfo.Eras["ERA_RENAISSANCE"].ID
		and pPlayer:HasPolicy(PolicyCollectiveRuleID) 
		and not pPlayer:IsPolicyBlocked(PolicyCollectiveRuleID)
		and (not pPlayer:HasPolicy(PolicyCollectiveRuleFreeID))
		then
			print("POLLICY_COLLECTIVE_RULE: enter Renaissance, free policy");  
			pPlayer:SetHasPolicy(PolicyCollectiveRuleFreeID,true,true)
		end
	end
end
GameEvents.TeamSetEra.Add(SPEPlayerIntoNewEra)

function SPEPlayerAdoptPolicy(playerID, policyID)
	if(policyID == PolicyCollectiveRuleID) then
		local pPlayer = Players[playerID]
		if pPlayer == nil or pPlayer:IsMinorCiv() or pPlayer:IsBarbarian() then
			return
		end

		local eEra = pPlayer:GetCurrentEra()
		if pPlayer:IsAlive()
		and eEra >= GameInfo.Eras["ERA_RENAISSANCE"].ID
		and not pPlayer:IsPolicyBlocked(PolicyCollectiveRuleID)
		and (not pPlayer:HasPolicy(PolicyCollectiveRuleFreeID))
		then
			print("POLLICY_COLLECTIVE_RULE: adopt after Renaissance, free policy"); 
			pPlayer:SetHasPolicy(PolicyCollectiveRuleFreeID,true,true)
		end
	end
end
GameEvents.PlayerAdoptPolicy.Add(SPEPlayerAdoptPolicy)

--POLICY_CITIZENSHIP: +25 production when founding a new city
function SPEPlayerCityFounded(iPlayer,cityX, cityY)
	local pPlayer = Players[iPlayer]
	if pPlayer == nil or pPlayer:IsMinorCiv() or pPlayer:IsBarbarian() then
		return
	end
	local cityPlot = Map.GetPlot(cityX, cityY)
	local pCity = cityPlot:GetPlotCity()
	if pCity == nil then return end

	if pPlayer:HasPolicy(GameInfo.Policies["POLICY_CITIZENSHIP"].ID) 
	and not pPlayer:IsPolicyBlocked(GameInfo.Policies["POLICY_CITIZENSHIP"].ID)
	then 
		local bonus=GameInfo.GameSpeeds[Game.GetGameSpeedType()].ConstructPercent/100
		bonus = math.floor(bonus * 25)
		pCity:SetOverflowProduction(pCity:GetOverflowProduction() + bonus)
		if pPlayer:IsHuman() then
			Events.GameplayAlertMessage(Locale.ConvertTextKey("TXT_KEY_MESSAGE_POLICY_CITIZENSHIP_ALERT", pCity:GetName(), bonus) )
		end
		print("SPEPlayerCityFounded:",bonus)	
	end
end
GameEvents.PlayerCityFounded.Add(SPEPlayerCityFounded)

--POLICY_MERITOCRACY: gain culture and research when finishing a building
function SPECityBuildingCompleted(iPlayer, iCity, iBuilding, bGold, bFaithOrCulture)
	local pPlayer = Players[iPlayer]
	if pPlayer == nil or pPlayer:IsMinorCiv() or pPlayer:IsBarbarian() then
	 	return
	end
	local iBuildingClass = GameInfo.Buildings[iBuilding].BuildingClass
	local isWonder = GameInfo.BuildingClasses[iBuildingClass].MaxGlobalInstances
	if pPlayer:HasPolicy(GameInfo.Policies["POLICY_MERITOCRACY"].ID) 
	and not pPlayer:IsPolicyBlocked(GameInfo.Policies["POLICY_MERITOCRACY"].ID)
	and bGold == false
	and bFaithOrCulture == false
	and isWonder  == -1
	then 
		local bonus = GameInfo.GameSpeeds[Game.GetGameSpeedType()].ConstructPercent/100
		local pCost = GameInfo.Buildings[iBuilding].Cost
		bonus = math.floor(bonus * pCost * 0.1)
		pPlayer:ChangeJONSCulture(bonus)
		pPlayer:ChangeOverflowResearch(bonus)
		if pPlayer:IsHuman() then
			local pCity = pPlayer:GetCityByID(iCity)
			local hex = ToHexFromGrid(Vector2(pCity:GetX(),pCity:GetY()))
			Events.AddPopupTextEvent(HexToWorld(hex), Locale.ConvertTextKey("+{1_Num}[ICON_RESEARCH],+{1_Num}[ICON_CULTURE]", bonus, bonus))
			Events.GameplayFX(hex.x, hex.y, -1)
		end
		print("SPECityBuildingCompleted:",bonus)
	end
end
GameEvents.CityConstructed.Add(SPECityBuildingCompleted)

--When block Liberty,recycle free building and policy
function SPEPlayerBlockPolicyBranch(iPlayer,iPolicyBranch,isBlock)
	local pPlayer = Players[iPlayer]
	if pPlayer == nil or pPlayer:IsMinorCiv() or pPlayer:IsBarbarian() then
	 	return
	end
	if iPolicyBranch == GameInfo.PolicyBranchTypes["POLICY_BRANCH_LIBERTY"].ID
	or iPolicyBranch == GameInfo.PolicyBranchTypes["POLICY_BRANCH_TRADITION"].ID
	then
		if iPolicyBranch == GameInfo.PolicyBranchTypes["POLICY_BRANCH_LIBERTY"].ID and isBlock then
			print("Player Block Liberty and adopt Tradition!!!")
			pPlayer:SetHasPolicy(PolicyCollectiveRuleFreeID,false)
			for iCity in pPlayer:Cities() do
				iCity:SetNumRealBuilding(GameInfoTypes.BUILDING_POLICY_REPUBLIC_FREE,0)
				iCity:SetNumRealBuilding(GameInfoTypes.BUILDING_REPRESENTATION_CULTURE,0)
				iCity:SetNumRealBuilding(GameInfoTypes.BUILDING_REPRESENTATION_CULTURE_COST,0)
				--Liberty manpower 
				iCity:SetNumRealBuilding(GameInfoTypes.BUILDING_CIV_S_P_MAN_RESOURCES,0)

				if(pPlayer:HasPolicy(GameInfo.Policies["POLICY_ARISTOCRACY"].ID)) then
					iCity:SetNumRealBuilding(GameInfoTypes.BUILDING_TRADITION_FOOD_GROWTH,1)
				end
				if(pPlayer:HasPolicy(GameInfo.Policies["POLICY_FAMILY_REGISTER"].ID)) then
					iCity:SetNumRealBuilding(GameInfoTypes.BUILDING_FAMILY_PRODUCTION,1)
				end
				
			end

		elseif iPolicyBranch == GameInfo.PolicyBranchTypes["POLICY_BRANCH_TRADITION"].ID and isBlock then
			print("Player Block Tradition and adopt Liberty!!!")
			if pPlayer:HasPolicy(PolicyCollectiveRuleID) then
				pPlayer:SetHasPolicy(PolicyCollectiveRuleFreeID,true,true)
			end
			for iCity in pPlayer:Cities() do
				iCity:SetNumRealBuilding(GameInfoTypes.BUILDING_TRADITION_FOOD_GROWTH,0)
				iCity:SetNumRealBuilding(GameInfoTypes.BUILDING_FAMILY_PRODUCTION,0)

				if(pPlayer:HasPolicy(GameInfo.Policies["POLICY_REPUBLIC"].ID)) then
					iCity:SetNumRealBuilding(GameInfoTypes.BUILDING_POLICY_REPUBLIC_FREE,1)
				end
				if(pPlayer:HasPolicy(GameInfo.Policies["POLICY_REPRESENTATION"].ID)) then
					iCity:SetNumRealBuilding(GameInfoTypes.BUILDING_REPRESENTATION_CULTURE,1)
					iCity:SetNumRealBuilding(GameInfoTypes.BUILDING_REPRESENTATION_CULTURE_COST,1)
				end
				if(pPlayer:HasPolicy(GameInfo.Policies["POLICY_CITIZENSHIP"].ID)) then
					iCity:SetNumRealBuilding(GameInfoTypes.BUILDING_CIV_S_P_MAN_RESOURCES,2)
				end
			end
		end

	end
end
GameEvents.PlayerBlockPolicyBranch.Add(SPEPlayerBlockPolicyBranch)



-- ********************************************************
--Patronage
-- ******************************************************** 
--POLICY_CULTURAL_DIPLOMACY
function SPEPlayerBulliedMinorCiv(iCS, iPlayer, iGold, iUnitType, iPlotX, iPlotY) 
	local pPlayer = Players[iCS]
	local civPlayer = Players[iPlayer]
	if pPlayer == nil or civPlayer == nil or pPlayer:IsMinorCiv() or pPlayer:IsBarbarian() then
	 	return
	end
	if( iGold == -1 ) and ( iUnitType == -1 ) then return end

	if pPlayer:HasPolicy(GameInfo.Policies["POLICY_CULTURAL_DIPLOMACY"].ID) then
		local minorCity = civPlayer:GetCapitalCity()
		if minorCity == nil then return end
		--get nearest city from wp
		local iDistance = nil
		local pTargetCity = nil
		for city in pPlayer:Cities() do
			if not(iDistance) or iDistance > Map.PlotDistance(minorCity:GetX(), minorCity:GetY(), city:GetX(), city:GetY()) then
				pTargetCity = city
				iDistance = Map.PlotDistance(minorCity:GetX(), minorCity:GetY(), city:GetX(), city:GetY())
			end
		end

		if pTargetCity ~= nil then
			local iMinorFood = math.max(0,minorCity:GetYieldRateTimes100(YieldTypes.YIELD_FOOD) / 100)
			local iMinorProduction = math.max(0,minorCity:GetYieldRateTimes100(YieldTypes.YIELD_PRODUCTION) / 100)
			local iMinorCulture = math.max(0,minorCity:GetYieldRateTimes100(YieldTypes.YIELD_CULTURE) / 100)
			local iMinorScience = math.max(0,minorCity:GetYieldRateTimes100(YieldTypes.YIELD_SCIENCE) / 100)
			print("Evil MajorCiv gains output from bullying MinorCiv:",iMinorFood,iMinorProduction,iMinorCulture,iMinorScience)
			pTargetCity:ChangeFood(iMinorFood)
			pTargetCity:SetOverflowProduction(pTargetCity:GetOverflowProduction() + iMinorProduction)
			pPlayer:ChangeJONSCulture(iMinorCulture)
			pPlayer:ChangeOverflowResearch(iMinorScience)
			if pPlayer:IsHuman() then
				Events.GameplayAlertMessage(Locale.ConvertTextKey("TXT_KEY_MESSAGE_POLICY_CULTURAL_DIPLOMACY_ALERT", minorCity:GetName(), pTargetCity:GetName() ) )
			end
		end
	end

end
GameEvents.PlayerBullied.Add(SPEPlayerBulliedMinorCiv)

--POLICY_CONSULATES
function SPEPlayerCompletedMinorCivQuest(iMajor, iMinor, iQuestType, iStartTurn, iOldInfluence, iNewInfluence) 
	local pPlayer = Players[iMajor]
	local civPlayer = Players[iMinor]
	if pPlayer == nil or civPlayer == nil or pPlayer:IsMinorCiv() or pPlayer:IsBarbarian() then
	 	return
	end
	if pPlayer:HasPolicy(GameInfo.Policies["POLICY_CONSULATES"].ID) then
		local eEra = pPlayer:GetCurrentEra()
		local bonus =( (iNewInfluence - iOldInfluence) * (2 + eEra) /200 )
		pPlayer:ChangeJONSCulture(bonus)
		print("MajorCiv gains Culture from completed MinorCiv quest:",bonus)
		if pPlayer:IsHuman() then
			Events.GameplayAlertMessage(Locale.ConvertTextKey("TXT_KEY_MESSAGE_POLICY_CONSULATES_ALERT", civPlayer:GetName(), bonus ) )
		end
	end
end
GameEvents.PlayerCompletedQuest.Add(SPEPlayerCompletedMinorCivQuest) 

print('SP8PolicyEffects: Check Pass')