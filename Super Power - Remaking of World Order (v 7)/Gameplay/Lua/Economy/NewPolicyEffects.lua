-- ********************************************************
-- POLICY_CITIZENSHIP
-- Citizenship offer free Worker when new city founded
-- ******************************************************** 
local PolicyLiberty = GameInfo.Policies["POLICY_CITIZENSHIP"].ID
local WorkerClassID = GameInfoTypes.UNITCLASS_WORKER
function FreeUnitNewCity(iPlayerID, iX, iY)
	local pPlayer = Players[iPlayerID]
	if pPlayer:HasPolicy(PolicyLiberty) then
		local WorkerID = pPlayer:GetCivUnit(WorkerClassID)
		if WorkerID < 0 then return end
		local NewUnit = pPlayer:InitUnit(WorkerID, iX, iY, UNITAI_WORKER)
		NewUnit:JumpToNearestValidPlot()
	end
end

GameEvents.PlayerCityFounded.Add(FreeUnitNewCity)

-- ********************************************************
-- POLICY_CITIZENSHIP
-- ******************************************************** 
local iPolicyCitizenship = GameInfo.Policies["POLICY_CITIZENSHIP"].ID;
function SPEPolicyCitizenshipHelper(pPlayer, pCity)
	local bonus = math.floor(GameInfo.GameSpeeds[Game.GetGameSpeedType()].ConstructPercent * 25 / 100)
	pCity:SetOverflowProduction(pCity:GetOverflowProduction() + bonus)
	if pPlayer:IsHuman() then
		Events.GameplayAlertMessage(Locale.ConvertTextKey("TXT_KEY_MESSAGE_POLICY_CITIZENSHIP_ALERT", pCity:GetName(), bonus))
	end
	--print("SPEPolicyCitizenshipHelper: ", bonus);
end

function SPEPlayerAdoptPolicy(playerID, policyID)
	if policyID == iPolicyCitizenship then
		local pPlayer = Players[playerID]
		for pCity in pPlayer:Cities() do
			SPEPolicyCitizenshipHelper(pPlayer, pCity)
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

	if pPlayer:HasPolicy(iPolicyCitizenship) 
	and not pPlayer:IsPolicyBlocked(iPolicyCitizenship)
	then 
		SPEPolicyCitizenshipHelper(pPlayer, pCity)
	end
end
GameEvents.PlayerCityFounded.Add(SPEPlayerCityFounded)

-- ********************************************************
--POLICY_MERITOCRACY: gain culture and research when finishing a building
-- ********************************************************
function SPECityBuildingCompleted(iPlayer, iCity, iBuilding, bGold, bFaithOrCulture)
	local pPlayer = Players[iPlayer]
	if pPlayer == nil or pPlayer:IsMinorCiv() or pPlayer:IsBarbarian() then
	 	return
	end
	local iBuildingClass = GameInfo.Buildings[iBuilding].BuildingClass
	local isWonder = GameInfo.BuildingClasses[iBuildingClass].MaxGlobalInstances
	if pPlayer:HasPolicy(GameInfoTypes["POLICY_MERITOCRACY"]) 
	and not pPlayer:IsPolicyBlocked(GameInfoTypes["POLICY_MERITOCRACY"])
	and bGold == false
	and bFaithOrCulture == false
	and isWonder  == -1
	then 
		local iCost = pPlayer:GetBuildingProductionNeeded(iBuilding)
		local bonus = math.floor(iCost * 0.1)
		pPlayer:ChangeJONSCulture(bonus)
		pPlayer:ChangeOverflowResearch(bonus)
		if pPlayer:IsHuman() then
			local pCity = pPlayer:GetCityByID(iCity)
			local hex = ToHexFromGrid(Vector2(pCity:GetX(),pCity:GetY()))
			Events.AddPopupTextEvent(HexToWorld(hex), Locale.ConvertTextKey("+{1_Num}[ICON_RESEARCH],+{1_Num}[ICON_CULTURE]", bonus))
			Events.GameplayFX(hex.x, hex.y, -1)
		end
		--print("SPECityBuildingCompleted:",bonus)
	end
end
GameEvents.CityConstructed.Add(SPECityBuildingCompleted)

function SPECityTrainCompleted(iPlayer, iCity, iUnit, bGold, bFaithOrCulture)
	local pPlayer = Players[iPlayer]
	if pPlayer == nil or not pPlayer:IsMajorCiv() or iUnit < 0 then
	 	return
	end
	local pUnit = pPlayer:GetUnitByID(iUnit)

	if not pUnit or not (pUnit:GetUnitClassType() == GameInfoTypes.UNITCLASS_SETTLER) then
		return
	end
	if pPlayer:HasPolicy(GameInfoTypes["POLICY_MERITOCRACY"]) 
	and not pPlayer:IsPolicyBlocked(GameInfoTypes["POLICY_MERITOCRACY"])
	and bGold == false
	and bFaithOrCulture == false
	then 
		--local bonus = GameInfo.GameSpeeds[Game.GetGameSpeedType()].ConstructPercent/100
		local iCost = pPlayer:GetUnitProductionNeeded(pUnit:GetUnitType())
		local bonus = math.floor(iCost * 0.1)
		pPlayer:ChangeJONSCulture(bonus)
		pPlayer:ChangeOverflowResearch(bonus)
		if pPlayer:IsHuman() then
			local pCity = pPlayer:GetCityByID(iCity)
			local hex = ToHexFromGrid(Vector2(pCity:GetX(),pCity:GetY()))
			Events.AddPopupTextEvent(HexToWorld(hex), Locale.ConvertTextKey("+{1_Num}[ICON_RESEARCH],+{1_Num}[ICON_CULTURE]", bonus))
			Events.GameplayFX(hex.x, hex.y, -1)
		end
	end
end
GameEvents.CityTrained.Add(SPECityTrainCompleted)

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

	if pPlayer:HasPolicy(GameInfoTypes["POLICY_CULTURAL_DIPLOMACY"]) then
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
				local hex = ToHexFromGrid(Vector2(pTargetCity:GetX(),pTargetCity:GetY()))
				Events.AddPopupTextEvent(HexToWorld(hex), Locale.ConvertTextKey("+{1_Num}[ICON_RESEARCH],+{2_Num}[ICON_CULTURE],+{3_Num}[ICON_PRODUCTION],+{4_Num}[ICON_FOOD]",iMinorScience, iMinorCulture,iMinorProduction,iMinorFood))
				Events.GameplayFX(hex.x, hex.y, -1)
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
	if pPlayer:HasPolicy(GameInfoTypes["POLICY_CONSULATES"])
	and iNewInfluence - iOldInfluence > 0
	then
		local eEra = pPlayer:GetCurrentEra()
		local bonus =( (iNewInfluence - iOldInfluence) * (2 + eEra) /200 )
		pPlayer:ChangeJONSCulture(bonus)
		print("MajorCiv gains Culture from completed MinorCiv quest:",bonus)
		if pPlayer:IsHuman() then
			Events.GameplayAlertMessage(Locale.ConvertTextKey("TXT_KEY_MESSAGE_POLICY_CONSULATES_ALERT", civPlayer:GetName(), bonus ) )
		end
	end
end
GameEvents.PlayerCompletedQuest.Add(SPEPlayerCompletedMinorCivQuest);

print("New Policy Effects Check Pass!")
