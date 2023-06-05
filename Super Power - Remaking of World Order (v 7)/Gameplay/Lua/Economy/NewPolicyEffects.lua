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
function FreeUnitNewCity(iPlayerID, iX, iY)
	local pPlayer = Players[iPlayerID]
	local pPlot = Map.GetPlot(iX, iY)
	local PolicyLiberty = GameInfo.Policies["POLICY_CITIZENSHIP"].ID
	local WorkerID = GameInfoTypes.UNIT_WORKER

	if pPlayer:HasPolicy(PolicyLiberty) then
		--		print ("Free Policy Unit!")
		local overrideUnit = GameInfo.Civilization_UnitClassOverrides { UnitClassType = "UNITCLASS_WORKER", CivilizationType =
		GameInfo.Civilizations[pPlayer:GetCivilizationType()].Type } ();
		if overrideUnit and overrideUnit.UnitType then
			WorkerID = GameInfoTypes[overrideUnit.UnitType];
		end
		local NewUnit = pPlayer:InitUnit(WorkerID, iX, iY, UNITAI_WORKER)
		NewUnit:JumpToNearestValidPlot()
	end
end

GameEvents.PlayerCityFounded.Add(FreeUnitNewCity)


function PolicyAdoptedEffects(playerID, policyID)
	local player = Players[playerID]
	if player == nil then
		return
	end

	if not player:IsHuman() then ------(only for human players for now)
		print("AI Poicy, not available!")
		return
	end

	if player:GetNumCities() < 1 then
		return
			print("Not enough city!")
	end

	if policyID == nil then
		return
	end

	if policyID == GameInfo.Policies["POLICY_ARISTOCRACY"].ID then
		FasterFoodGrowth(playerID)
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
	if GameInfo.Beliefs[iBelief].Type == "BELIEF_UNITY_OF_PROPHETS" then
		local iProphetID = GameInfoTypes.UNIT_PROPHET;
		local overrideUnit = GameInfo.Civilization_UnitClassOverrides { UnitClassType = "UNITCLASS_PROPHET", CivilizationType =
		GameInfo.Civilizations[pPlayer:GetCivilizationType()].Type } ();
		if overrideUnit and overrideUnit.UnitType then
			iProphetID = GameInfoTypes[overrideUnit.UnitType];
		end
		pPlayer:InitUnit(iProphetID, holyCity:GetX(), holyCity:GetY(), UNITAI_PROPHET)
	elseif GameInfo.Beliefs[iBelief].Type == "BELIEF_TO_GLORY_OF_GOD" then
		holyCity:SetNumRealBuilding(GameInfoTypes["BUILDING_BELIEF_TO_GLORY_OF_GOD"], 1);
	elseif GameInfo.Beliefs[iBelief].Type == "BELIEF_UNDERGROUND_SECT" then
		holyCity:SetNumRealBuilding(GameInfoTypes["BUILDING_BELIEF_UNDERGROUND_SECT"], 1);
		holyCity:SetNumRealBuilding(GameInfoTypes["BUILDING_BELIEF_UNDERGROUND_SECT"], 0);
	end
end

GameEvents.ReligionReformed.Add(SPReformeBeliefs)

function FasterFoodGrowth(playerID)
	local player = Players[playerID];
	for city in player:Cities() do
		if city:IsHasBuilding(GameInfo.Buildings["BUILDING_CITY_SIZE_TOWN"].ID) then
			local pThreshold = city:GrowthThreshold()
			city:ChangeFood(pThreshold)
			print ("Aristocracy Growth Bonus!")
		end
	end
end

print("New Policy Effects Check Pass!")
