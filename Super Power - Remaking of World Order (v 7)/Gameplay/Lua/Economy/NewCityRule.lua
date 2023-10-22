--------------------- International Immigration
function InternationalImmigration(TargetPlayerID)
    if CheckMoveOutCounter == nil or (TargetPlayerID == -1 or nil) then
        return;
    end

    local thisPlayer = Players[TargetPlayerID]
    if thisPlayer == nil or not thisPlayer:IsHuman() then
        return;
    end

    for playerID, player in pairs(Players) do
        local OutPlayer = -1;
        local InPlayer = -1;

        if player:IsAlive() and player:IsMajorCiv() and playerID ~= TargetPlayerID then
            local ImmigrationCount = CheckMoveOutCounter(TargetPlayerID, playerID);
            if ImmigrationCount then
                if player:GetImmigrationCounter(TargetPlayerID) <= 0 
                or player:GetImmigrationCounter(TargetPlayerID) >= ImmigrationCount[2] * 2
                then
                    --Init ImmigrationCounter, ImmigrationCount[2] is iRegressand, default 30
                    player:SetImmigrationCounter(TargetPlayerID, ImmigrationCount[2])
                end
                local iCount = player:GetImmigrationCounter(TargetPlayerID);

                if iCount == 0 or iCount == ImmigrationCount[2] * 2 then
                    --reach Upper and lower limits
                else
                    --ImmigrationCount[1] is MoveoutCounterFinal
                    iCount = iCount + ImmigrationCount[1];
                end

                --iCount must in (0, iRegressand * 2)
                iCount = math.max(0, iCount);
                iCount = math.min(iCount, ImmigrationCount[2] * 2);

                if iCount == 0 then
                    OutPlayer = TargetPlayerID;
                    InPlayer = playerID;
                elseif iCount == ImmigrationCount[2] * 2 then
                    OutPlayer = playerID;
                    InPlayer = TargetPlayerID;
                end
                player:SetImmigrationCounter(TargetPlayerID, iCount)

                if OutPlayer >= 0 and InPlayer >= 0 then
                    local bIsDoImmigration = DoInternationalImmigration(OutPlayer, InPlayer);
                    if bIsDoImmigration then
                        --return to iRegressand
                        player:SetImmigrationCounter(TargetPlayerID, ImmigrationCount[2])
                        print("Successful International Immigration: Player " .. OutPlayer .. " to Player " .. InPlayer);
                    else
                        print("Fail International Immigration: Player " ..
                            OutPlayer .. " to Player " .. InPlayer);
                    end
                end
            end
        end
    end
end ---------function end
GameEvents.PlayerDoTurn.Add(InternationalImmigration)

function DoInternationalImmigration(MoveOutPlayerID, MoveInPlayerID)
    --This nation's population tries to move out
    local MoveOutPlayer = Players[MoveOutPlayerID]
    --Move to this nation
    local MoveInPlayer = Players[MoveInPlayerID]

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
        print("Immigrant left this city:" .. Cityname)

        ------------Notification-----------
        if MoveOutPlayer:IsHuman() and targetCity ~= nil then
            local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_IMMIGRANT_LEFT_CITY", targetCity:GetName())
            local heading = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_IMMIGRANT_LEFT_CITY_SHORT")
            MoveOutPlayer:AddNotification(NotificationTypes.NOTIFICATION_STARVING, text, heading, targetCity:GetX(), targetCity:GetY())
        end

        ------------AI will enhance culture output to encounter!
        if targetCity:GetPopulation() > 15 and not MoveOutPlayer:IsHuman() then
            targetCity:SetFocusType(5)
            print("Shit human is stealing people from us! AI need more culture!")
        end
    else
        return false
    end

    ---------------------------------Immigrant Moving In--------------------
    local apCities = {}
    local iCounter = 0
    for pCity in MoveInPlayer:Cities() do
        local cityPop = pCity:GetPopulation()
        if cityPop > 0 and cityPop < 80 and not pCity:IsPuppet() and
            not pCity:IsRazing() and not pCity:IsResistance() and
            not pCity:IsForcedAvoidGrowth() and
            pCity:CanGrowNormally() and
            pCity:GetSpecialistCount(GameInfo.Specialists.SPECIALIST_CITIZEN.ID) <=
            0 then
            apCities[iCounter] = pCity
            iCounter = iCounter + 1
        end
    end

    if iCounter > 0 then
        local iRandChoice = Game.Rand(iCounter, "Choosing random city")
        local targetCity = apCities[iRandChoice]
        local Cityname = targetCity:GetName()
        targetCity:ChangePopulation(1, true)
        print("Immigrant Move into this city:" .. Cityname)

        ------------Notification-----------
        if MoveInPlayer:IsHuman() and targetCity ~= nil then
            local text = Locale.ConvertTextKey(
                "TXT_KEY_SP_NOTIFICATION_IMMIGRANT_REACHED_CITY",
                targetCity:GetName())
            local heading = Locale.ConvertTextKey(
                "TXT_KEY_SP_NOTIFICATION_IMMIGRANT_REACHED_CITY_SHORT")
            MoveInPlayer:AddNotification(
                NotificationTypes.NOTIFICATION_CITY_GROWTH, text, heading,
                targetCity:GetX(), targetCity:GetY())
        end
        return true
    else
        return false
    end
end ---------function end

-- Check to Set Capital for avoiding CTD -- by CaptainCWB
function CheckCapital(iPlayerID)
    if Players[iPlayerID] == nil or not Players[iPlayerID]:IsAlive() or
        Players[iPlayerID]:GetNumCities() <= 0 then
        return;
    end
    local pPlayer = Players[iPlayerID];
    local pOCapital = pPlayer:GetCapitalCity();
    local pNCapital = nil;
    local iCityPop = 0;
    local ibIsNewCapital = false;

    -- Fix Puppet|Annex for "MayNotAnnex Player" & Capital
    if pOCapital == nil or ((pPlayer:MayNotAnnex() and pOCapital:IsPuppet()) or
            (pPlayer:GetBuildingClassCount(
                    GameInfoTypes["BUILDINGCLASS_CAPITAL_MOVEMARK"]) > 0 and
                not pOCapital:IsHasBuilding(
                    GameInfoTypes["BUILDING_CAPITAL_MOVEMARK"]))) then
        for pCity in pPlayer:Cities() do
            if pCity == nil then
            elseif not pCity:IsCapital() then
                if pCity:IsHasBuilding(
                        GameInfoTypes["BUILDING_CAPITAL_MOVEMARK"]) then
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
            local iPalaceID = pPlayer:GetCivBuilding(GameInfoTypes["BUILDINGCLASS_PALACE"])
            pNCapital:SetNumRealBuilding(iPalaceID, 1);

            for building in GameInfo.Buildings() do
                if pOCapital then
                    -- Palace
                    if pOCapital:IsHasBuilding(building.ID) and building.Capital then
                        local i = pOCapital:GetNumBuilding(building.ID);
                        pOCapital:SetNumRealBuilding(building.ID, 0);
                        if pNCapital:GetNumBuilding(building.ID) ~= i then
                            pNCapital:SetNumRealBuilding(building.ID, i);
                        end
                    end

                    -- Move Policy Buildings & Count Buildings
                    local policFreeBCCapital = GameInfo.Policy_FreeBuildingClassCapital {BuildingClassType = building.BuildingClass} ()
                    if pOCapital:IsHasBuilding(building.ID) and
                        (policFreeBCCapital ~= nil) then
                        local i = pOCapital:GetNumBuilding(building.ID);
                        pOCapital:SetNumRealBuilding(building.ID, 0);
                        pNCapital:SetNumRealBuilding(building.ID, i);
                    end
                end
            end
            print("Captial Moved!")

            if pNCapital:IsRazing() then
                Network.SendDoTask(pNCapital:GetID(), TaskTypes.TASK_UNRAZE, -1,
                    -1, false, false, false, false);
                -- pNCapital:SetNeverLost(true);
            end
        end
    end
end

GameEvents.PlayerDoTurn.Add(CheckCapital)

--City Founded in Special Terrain
local improvementMachuID = GameInfoTypes["IMPROVEMENT_INCA_CITY"]
local improvementPolyCity = {
    [0] = GameInfoTypes["IMPROVEMENT_POLYNESIA_CITY_NE"],
    [1] = GameInfoTypes["IMPROVEMENT_POLYNESIA_CITY_E"],
    [2] = GameInfoTypes["IMPROVEMENT_POLYNESIA_CITY_SE"],
    [3] = GameInfoTypes["IMPROVEMENT_POLYNESIA_CITY_SW"],
    [4] = GameInfoTypes["IMPROVEMENT_POLYNESIA_CITY_W"],
    [5] = GameInfoTypes["IMPROVEMENT_POLYNESIA_CITY_NW"]
}

local incaID = GameInfoTypes["CIVILIZATION_INCA"]
local polyID = GameInfoTypes["CIVILIZATION_POLYNESIA"]

function SPNIsCivilisationActive(civilizationID)
    for iSlot = 0, GameDefines.MAX_MAJOR_CIVS - 1, 1 do
        local slotStatus = PreGame.GetSlotStatus(iSlot)
        if (slotStatus == SlotStatus.SS_TAKEN or slotStatus == SlotStatus.SS_COMPUTER) then
            if PreGame.GetCivilization(iSlot) == civilizationID then
                return true
            end
        end
    end
    return false
end

function chooseCoastalCityDirection(plotX, plotY)
    if Map.GetPlot(plotX, plotY):GetPlotCity() == nil then return end
    local improvementPolyCityID = 0
    local ContinuousWaterPlot = 0
    local maxContinuousWaterPlot = 0
    --Looking for the center of the largest continuous water plot
    for i = 0, 11 do
        local index = i % 6
        local adjPlot = Map.PlotDirection(plotX, plotY, index)
        if adjPlot ~= nil then
            if adjPlot:IsWater() then
                if ContinuousWaterPlot >= maxContinuousWaterPlot then
                    improvementPolyCityID = math.abs(i - math.floor(ContinuousWaterPlot / 2)) % 6
                end
                ContinuousWaterPlot = ContinuousWaterPlot + 1
            else
                if ContinuousWaterPlot > maxContinuousWaterPlot then
                    maxContinuousWaterPlot = ContinuousWaterPlot
                end
                ContinuousWaterPlot = 0
            end
        end
    end
    --print("improvementPolyCityID=",improvementPolyCityID,maxContinuousWaterPlot)
    return improvementPolyCityID
end

function SPNCityFoundedInSpecialTerrain(playerID, plotX, plotY)
    local player = Players[playerID]
    if not player:IsAlive() then return end
    local cityPlot = Map.GetPlot(plotX, plotY)

    --Inca city
    if cityPlot:IsMountain()
    then
        print("Inca Mountain city! Set Improvement")
        cityPlot:SetImprovementType(improvementMachuID)
        --Poly city
    elseif cityPlot:IsWater()
    then
        local PolyCityDirection = chooseCoastalCityDirection(plotX, plotY)
        print("Poly Coastal City! Set Improvement", PolyCityDirection)
        cityPlot:SetImprovementType(improvementPolyCity[PolyCityDirection])
    end
end

function SPNDestroySpecialTerrainCity(hexPos, iPlayer, iCity)
    local pCity = Players[iPlayer]:GetCityByID(iCity);
    if pCity == nil then return end
    local pPlot = Map.GetPlot(pCity:GetX(), pCity:GetY())
    if pPlot:IsMountain()
        or pPlot:IsWater()
    then
        print("A Mountain City or a Coastal City was destoryed,remove fake Improvement")
        pPlot:SetImprovementType(-1)
    end
end

function SPNConquestedSpecialTerrianCity(oldOwnerID, isCapital, cityX, cityY, newOwnerID, numPop, isConquest)
    SPNCityFoundedInSpecialTerrain(newOwnerID, cityX, cityY)
end

if SPNIsCivilisationActive(incaID) or SPNIsCivilisationActive(polyID) then
    GameEvents.PlayerCityFounded.Add(SPNCityFoundedInSpecialTerrain)
    Events.SerialEventCityDestroyed.Add(SPNDestroySpecialTerrainCity)
    GameEvents.CityCaptureComplete.Add(SPNConquestedSpecialTerrianCity)
end

print("New City Rules Check Pass!")
