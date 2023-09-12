-- Citizenship offer free Worker when new city founded
function FreeUnitNewCity(iPlayerID, iX, iY)
	local pPlayer = Players[iPlayerID]
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
	end
end

GameEvents.ReligionReformed.Add(SPReformeBeliefs)

print("New Policy Effects Check Pass!")
