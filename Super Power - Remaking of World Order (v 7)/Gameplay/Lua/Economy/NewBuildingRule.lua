local bIsAllUBActive = PreGame.GetGameOption("GAMEOPTION_HUMAN_ALL_UC") == 1 or GameInfo.SPNewEffectControler.SP_ALL_UB_ACTIVE.Enabled
function NromanCampBouns(iPlayer)
    local pPlayer = Players[iPlayer]
    if not pPlayer:IsMajorCiv() then
        return
    end
    local NumOfNromanCamp = pPlayer:CountNumBuildings(GameInfoTypes.BUILDING_NORMAN_CAMP)
    if NumOfNromanCamp < 1 then
        return
    end
    local NromanCampRandom = Game.Rand(4, "Set NormanCamp Random!") --rand=0-3
    local eEra = pPlayer:GetCurrentEra()
    local iNromanCampBonus = (eEra + 1) * NumOfNromanCamp
    print("NormanCamp Random", NromanCampRandom, iNromanCampBonus)
    if pPlayer:IsHuman() then
        local hex
        for pCity in pPlayer:Cities() do
            if pCity:IsHasBuilding(GameInfoTypes.BUILDING_NORMAN_CAMP) then
                hex = ToHexFromGrid(Vector2(pCity:GetX(), pCity:GetY()))
                if NromanCampRandom < 2 then
                    pCity:SetOverflowProduction(pCity:GetOverflowProduction() + iNromanCampBonus)
                    Events.AddPopupTextEvent(HexToWorld(hex),
                        Locale.ConvertTextKey("+{1_Num}[ICON_PRODUCTION]", iNromanCampBonus))
                else
                    pCity:ChangeFood(iNromanCampBonus)
                    Events.AddPopupTextEvent(HexToWorld(hex),
                        Locale.ConvertTextKey("+{1_Num}[ICON_FOOD]", iNromanCampBonus))
                end
                Events.GameplayFX(hex.x, hex.y, -1)
            end
        end
    else
        for pCity in pPlayer:Cities() do
            if pCity:IsHasBuilding(GameInfoTypes.BUILDING_NORMAN_CAMP) then
                if NromanCampRandom < 2 then
                    pCity:SetOverflowProduction(pCity:GetOverflowProduction() + iNromanCampBonus)
                else
                    pCity:ChangeFood(iNromanCampBonus)
                end
            end
        end
    end
end

if bIsAllUBActive or Game.IsCivEverActive(GameInfoTypes.CIVILIZATION_DENMARK) then
    function SPNNromanCampConquestedCity(oldOwnerID, isCapital, cityX, cityY, newOwnerID, numPop, isConquest)
        if not isConquest then return end
        NromanCampBouns(newOwnerID)
    end

    GameEvents.CityCaptureComplete.Add(SPNNromanCampConquestedCity)

    function SPNNromanCampDestroyCity(hexPos, iPlayer, iCity)
        NromanCampBouns(iPlayer)
    end

    Events.SerialEventCityDestroyed.Add(SPNNromanCampDestroyCity)
end

------------------ Portugal UB BEGIN ------------------
if bIsAllUBActive or Game.IsCivEverActive(GameInfoTypes.CIVILIZATION_PORTUGAL) then
	GameEvents.TradeRouteMove.Add(function(iX, iY, iUnit, iOwner, iOriginalPlayer, iOriginalCity, iDestPlayer, iDestCity)
		local pOnwer = Players[iOwner];
		if pOnwer == nil or not pOnwer:IsAlive()
		or (iOriginalPlayer == iDestPlayer and iOriginalPlayer == iOwner) then
			return;
		end

		local plot = Map.GetPlot(iX, iY);
		if plot == nil then
			return;
		end

		if not plot:IsWater() and not plot:IsCity() then
			return;
		end

		local pCity = plot:GetWorkingCity();
		if pCity == nil then
			-- print("TradeRouteMove-Portugal-UB: pCity == nil");
			return;
		end

		if not pCity:IsHasBuilding(GameInfoTypes["BUILDING_PORTUGAL_PORT"]) then
			-- print("TradeRouteMove-Portugal-UB: do not have BUILDING_PORTUGAL_PORT");
			return;
		end

		local pCityOwner = Players[pCity:GetOwner()];
		local iGold = 5 * (2 + pCityOwner:GetCurrentEra());
		pCityOwner:ChangeGold(iGold);

		if pCityOwner:IsHuman() then
			local hex = ToHexFromGrid(Vector2(iX, iY));
			Events.AddPopupTextEvent(HexToWorld(hex), Locale.ConvertTextKey("+{1_Num}[ICON_GOLD]", iGold));
		end
		print("TradeRouteMove-Portugal-UB: gain ", iGold);
	end
	)
end
------------------ Portugal UB END   ------------------

------------------ CARTHAGINIAN_AGORA BEGIN   ------------------

if bIsAllUBActive or Game.IsCivEverActive(GameInfoTypes.CIVILIZATION_CARTHAGE) then
	local CarthaginianAgoraDummyPolicyCommerce = GameInfoTypes["POLICY_BUILDING_CARTHAGINIAN_AGORA_COMMERCE"];
	local CarthaginianAgoraDummyPolicyExploration = GameInfoTypes["POLICY_BUILDING_CARTHAGINIAN_AGORA_EXPLORATION"];
	local CarthaginianAgoraBuildingID = GameInfoTypes["BUILDING_CARTHAGINIAN_AGORA"];
	function UpdateCarthaginanUWEffect(iPlayerID)
		local pPlayer = Players[iPlayerID];
		if pPlayer == nil or not pPlayer:IsMajorCiv() then
			return;
		end

		local bHaveUW = pPlayer:CountNumBuildings(CarthaginianAgoraBuildingID) > 0;

		local bAdoptCommerce = pPlayer:HasPolicyBranch(GameInfoTypes["POLICY_BRANCH_COMMERCE"]);
		local bHaveDummyCommerce = pPlayer:HasPolicy(CarthaginianAgoraDummyPolicyCommerce) and
		not pPlayer:IsPolicyBlocked(CarthaginianAgoraDummyPolicyCommerce);
		local bShouldHaveDummyCommerce = bAdoptCommerce and bHaveUW;
		if bShouldHaveDummyCommerce ~= bHaveDummyCommerce then
			print("CARTHAGINIAN_AGORA: commerce: ", bShouldHaveDummyCommerce);
			pPlayer:SetHasPolicy(CarthaginianAgoraDummyPolicyCommerce, bShouldHaveDummyCommerce, true);
		end


		local bAdoptExploration = pPlayer:HasPolicyBranch(GameInfoTypes["POLICY_BRANCH_EXPLORATION"]);
		local bHaveDummyExploration = pPlayer:HasPolicy(CarthaginianAgoraDummyPolicyExploration) and
		not pPlayer:IsPolicyBlocked(CarthaginianAgoraDummyPolicyExploration);
		local bShouldHaveDummyExploration = bAdoptExploration and bHaveUW;
		if bShouldHaveDummyExploration ~= bHaveDummyExploration then
			print("CARTHAGINIAN_AGORA: exploration: ", bShouldHaveDummyExploration);
			pPlayer:SetHasPolicy(CarthaginianAgoraDummyPolicyExploration, bShouldHaveDummyExploration, true);
		end
	end

	GameEvents.PlayerDoTurn.Add(UpdateCarthaginanUWEffect);
	GameEvents.PlayerAdoptPolicyBranch.Add(UpdateCarthaginanUWEffect);
end
------------------ CARTHAGINIAN_AGORA END   ------------------

if bIsAllUBActive or Game.IsCivEverActive(GameInfoTypes.CIVILIZATION_ASSYRIA) then
	local assurTemple = GameInfoTypes["BUILDING_ASSUR_TEMPLE"]
	function ASHUR_TEMPLEGetFoodAndFaith(iPlayer, iKilledPlayer, iUnitType, iKillingUnit, iKilledUnit)
		if iPlayer == iKilledPlayer or iPlayer == -1 then return end
		local pPlayer = Players[iKilledPlayer]
		local ByPlayer = Players[iPlayer]
		if ByPlayer == nil or pPlayer == nil then return end
		if ByPlayer:CountNumBuildings(assurTemple) == 0 then return end

		local pUnit = pPlayer:GetUnitByID(iKilledUnit)
		local plot = pUnit:GetPlot()
		if pUnit == nil or plot == nil then return end
		local iX = plot:GetX()
		local iY = plot:GetY()
		
		local iStrength = pUnit:GetBaseCombatStrength()
		if iStrength <= 0 then return end

		local iFoodBoost = iStrength * 0.5
		local iFaithdBoost = iStrength * 0.5
		
		for iCity in ByPlayer:Cities() do
			if iCity:IsHasBuilding(assurTemple)
			and Map.PlotDistance(iX, iY, iCity:GetX(), iCity:GetY()) <= 6
			then
				ByPlayer:ChangeFaith(iFaithdBoost)
				iCity:ChangeFood(iFoodBoost)
				if ByPlayer:IsHuman() then
					local hex = ToHexFromGrid(Vector2(iCity:GetX(), iCity:GetY()));
					Events.AddPopupTextEvent(HexToWorld(hex),
					Locale.ConvertTextKey("+{1_Num}[ICON_PEACE] +{2_Num}[ICON_FOOD]", iFaithdBoost,iFoodBoost))
				end
			end
		end
	end
	GameEvents.UnitKilledInCombat.Add(ASHUR_TEMPLEGetFoodAndFaith)
end

if bIsAllUBActive or Game.IsCivEverActive(GameInfoTypes.CIVILIZATION_ZULU) then
	GameEvents.UnitPromoted.Add(function(iPlayer, iUnit, iPromotionType)
		local pPlayer = Players[iPlayer];
		if pPlayer == nil then return end

		local iNumIzako = pPlayer:CountNumBuildings(GameInfoTypes["BUILDING_ZULU_IZIKO"])
		if iNumIzako == 0 then
			return;
		end

		local pUnit = pPlayer:GetUnitByID(iUnit)
		if pUnit == nil then return end

		local iBonus = pPlayer:GetCurrentEra() / 2 + 1;
		iBonus = math.floor(iBonus * iNumIzako);
	
		pPlayer:ChangeJONSCulture(iBonus);
		if pPlayer:IsHuman() and pPlayer:IsTurnActive() then
			local hex = ToHexFromGrid(Vector2(pUnit:GetX(), pUnit:GetY()));
			Events.AddPopupTextEvent(HexToWorld(hex), Locale.ConvertTextKey("[COLOR_MAGENTA]+{1_Num}[ICON_CULTURE][ENDCOLOR]", iBonus));
		end
	end)
end

if bIsAllUBActive or Game.IsCivEverActive(GameInfoTypes.CIVILIZATION_ARABIA) then
	local iIsiamicFactor = GameDefines["ARABIA_ISIAMIC_UNIVERSITY_FACTOR"] or 7;
	local eIsiamicSchool = GameInfoTypes["BUILDING_ARABIA_ISIAMIC_UNIVERSITY"]
	local eIsiamicUniversityAllahAkbar = GameInfoTypes["BUILDING_ARABIA_ISIAMIC_UNIVERSITY_ALLAH_AKBAR"]

	local faithBuildingCollection1 = {}
	local faithBuildingCollection2 = {}
	for building in GameInfo.Buildings() do
		if building.Type ~= "BUILDING_ARABIA_ISIAMIC_UNIVERSITY_ALLAH_AKBAR" then
			if (building.FaithCost > 0 and building.Cost == -1) or
				building.BuildingClass == "BUILDINGCLASS_SHRINE" or
				building.BuildingClass == "BUILDINGCLASS_TEMPLE" then
				faithBuildingCollection1[building.ID] = true
			elseif GameInfo.Building_YieldChanges {
					BuildingType = building.Type,
					YieldType = "YIELD_FAITH",
				} () then
				faithBuildingCollection2[building.ID] = true
			end
		end
	end

	function setIsiamSchoolEffect(pCity, iNumBonusFactor)
		if pCity == nil then
			return
		end
		if pCity:IsPuppet() then
			pCity:SetNumRealBuilding(eIsiamicUniversityAllahAkbar, 0)
			return
		end

		local iNumBonus = 0;
		local iNumFaithBuildingInCollection1 = 0
		for i, v in pairs(faithBuildingCollection1) do
			if v == true and pCity:IsHasBuilding(i) then
				iNumFaithBuildingInCollection1 = iNumFaithBuildingInCollection1 + 1
			end
		end
		iNumBonus = iNumBonus + iNumFaithBuildingInCollection1 * iNumBonusFactor

		local bHasLab = pCity:IsHasBuilding(GameInfoTypes["BUILDING_LABORATORY"])
		if bHasLab then
			local iNumFaithBuildingInCollection2 = 0
			for i, v in pairs(faithBuildingCollection2) do
				if v == true and pCity:IsHasBuilding(i) then
					iNumFaithBuildingInCollection2 = iNumFaithBuildingInCollection2 + 1
				end
			end
			iNumBonus = iNumBonus + iNumFaithBuildingInCollection2 * iNumBonusFactor
		end

		pCity:SetNumRealBuilding(eIsiamicUniversityAllahAkbar, iNumBonus)
	end

	GameEvents.PlayerDoTurn.Add(function(iPlayer)
		local pPlayer = Players[iPlayer]
		if pPlayer == nil or not pPlayer:IsAlive() then
			return
		end
		local iNumIsiamicSchool = pPlayer:CountNumBuildings(eIsiamicSchool)
		if iNumIsiamicSchool <= 0 then return end
		
		local iNumBonusFactor = math.floor(iNumIsiamicSchool / iIsiamicFactor)

		for city in pPlayer:Cities() do
			setIsiamSchoolEffect(city, iNumBonusFactor)
		end
	end)
end

print("New Building Rules Check Pass!");
