print("NewCombatEffects_SP10 start");
include("FLuaVector.lua");

local iBarrageCollecton = GameInfoTypes["PROMOTION_COLLECTION_BARRAGE"];
local iMovementLossCollecton = GameInfoTypes["PROMOTION_COLLECTION_MOVEMENT_LOST"];
local iMovementLoss2 = GameInfoTypes["PROMOTION_MOVEMENT_LOST_2"];
local iMoveDenominator = GameDefines["MOVE_DENOMINATOR"];
GameEvents.OnTriggerAddEnemyPromotion.Add(function(eThisPromotionType, eThisPromotionCollection, iThisPlayer,
                                                    eThisBattleType, iThisUnit, iThisUnitType, eThatPromotionType,
                                                    eThatPromotionCollection, iThatPlayer, iThatUnit, iThatUnitType)
    if eThisPromotionCollection ~= iBarrageCollecton or eThatPromotionCollection ~= iMovementLossCollecton then
        return;
    end

    local pThisPlayer = Players[iThisPlayer];
    local pThatPlayer = Players[iThatPlayer];
    if pThisPlayer == nil or pThatPlayer == nil then
        return;
    end

    local pThisUnit = pThisPlayer:GetUnitByID(iThisUnit);
    local pThatUnit = pThatPlayer:GetUnitByID(iThatUnit);
    if pThisUnit == nil or pThatUnit == nil then
        return;
    end

    local message = 0;
    if pThatUnit:IsHasPromotion(iMovementLoss2) then
        if pThatUnit:CanMove() then
            pThatUnit:SetMoves(0);
        end
        message = 1;
    else
        if pThatUnit:CanMove() then
            pThatUnit:SetMoves(iMoveDenominator);
        end
        message = 0;
    end

    local thisUnitName = pThisUnit:GetName();
    local thatUnitName = pThatUnit:GetName();
    if pThisPlayer:IsHuman() then
        if message == 0 then
            local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_ENEMY_SLOWED", thisUnitName, thatUnitName);
            Events.GameplayAlertMessage(text);
        elseif message == 1 then
            local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_ENEMY_STOPPED", thisUnitName, thatUnitName);
            Events.GameplayAlertMessage(text);
        end
    end
    if pThatPlayer:IsHuman() then
        if message == 0 then
            local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_US_SLOWED", thisUnitName, thatUnitName);
            Events.GameplayAlertMessage(text);
        elseif message == 1 then
            local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_US_STOPPED", thisUnitName, thatUnitName);
            Events.GameplayAlertMessage(text);
        end
    end
end);

local iSunderCollectionID = GameInfoTypes["PROMOTION_COLLECTION_SUNDER"];
local iPenetrationCollectionID = GameInfoTypes["PROMOTION_COLLECTION_PENETRATION"];
GameEvents.OnTriggerAddEnemyPromotion.Add(function(eThisPromotionType, eThisPromotionCollection, iThisPlayer,
                                                    eThisBattleType, iThisUnit, iThisUnitType, eThatPromotionType,
                                                    eThatPromotionCollection, iThatPlayer, iThatUnit, iThatUnitType)
    if eThisPromotionCollection ~= iSunderCollectionID or eThatPromotionCollection ~= iPenetrationCollectionID then
        return;
    end

    local pThisPlayer = Players[iThisPlayer];
    local pThatPlayer = Players[iThatPlayer];
    if pThisPlayer == nil or pThatPlayer == nil then
        return;
    end

    local pThisUnit = pThisPlayer:GetUnitByID(iThisUnit);
    local pThatUnit = pThatPlayer:GetUnitByID(iThatUnit);
    if pThisUnit == nil or pThatUnit == nil then
        return;
    end

    if eThatPromotionType == -1 then
        return;
    end

    local thisUnitName = pThisUnit:GetName();
    local thatUnitName = pThatUnit:GetName();
    if pThisPlayer:IsHuman() then
        local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_ENEMY_SUNDERED", thisUnitName, thatUnitName);
        Events.GameplayAlertMessage(text);
    end
    if pThatPlayer:IsHuman() then
        local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_US_SUNDERED", thisUnitName, thatUnitName);
        Events.GameplayAlertMessage(text);
    end
end);

local iColCollectionID = GameInfoTypes["PROMOTION_COLLECTION_COLLATERAL_DAMAGE"];
local iWeakenCollectionID = GameInfoTypes["PROMOTION_COLLECTION_MORAL_WEAKEN"];
GameEvents.OnTriggerAddEnemyPromotion.Add(function(eThisPromotionType, eThisPromotionCollection, iThisPlayer,
                                                    eThisBattleType, iThisUnit, iThisUnitType, eThatPromotionType,
                                                    eThatPromotionCollection, iThatPlayer, iThatUnit, iThatUnitType)
    if eThisPromotionCollection ~= iColCollectionID or eThatPromotionCollection ~= iWeakenCollectionID then
        return;
    end

    local pThisPlayer = Players[iThisPlayer];
    local pThatPlayer = Players[iThatPlayer];
    if pThisPlayer == nil or pThatPlayer == nil then
        return;
    end

    local pThisUnit = pThisPlayer:GetUnitByID(iThisUnit);
    local pThatUnit = pThatPlayer:GetUnitByID(iThatUnit);
    if pThisUnit == nil or pThatUnit == nil then
        return;
    end

    if eThatPromotionType == -1 then
        return;
    end

    local thisUnitName = pThisUnit:GetName();
    local thatUnitName = pThatUnit:GetName();
    if pThisPlayer:IsHuman() then
        local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_ENEMY_MORAL_WEAKEN", thisUnitName, thatUnitName);
        Events.GameplayAlertMessage(text);
    end
    if pThatPlayer:IsHuman() then
        local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_US_MORAL_WEAKEN", thisUnitName, thatUnitName);
        Events.GameplayAlertMessage(text);
    end
end);

local iDestroySupplyCollectionID = GameInfoTypes["PROMOTION_COLLECTION_DESTROY_SUPPLY"];
local iLoseSupplyCollectionID = GameInfoTypes["PROMOTION_COLLECTION_LOSE_SUPPLY"];
local DestroySupply2ID = GameInfoTypes["PROMOTION_DESTROY_SUPPLY_2"]
local LoseSupplyID = GameInfoTypes["PROMOTION_LOSE_SUPPLY"]
GameEvents.OnTriggerAddEnemyPromotion.Add(function(eThisPromotionType, eThisPromotionCollection, iThisPlayer,
                                                    eThisBattleType, iThisUnit, iThisUnitType, eThatPromotionType,
                                                    eThatPromotionCollection, iThatPlayer, iThatUnit, iThatUnitType)
    if eThisPromotionCollection ~= iDestroySupplyCollectionID or eThatPromotionCollection ~= iLoseSupplyCollectionID then
        return;
    end

    local pThisPlayer = Players[iThisPlayer];
    local pThatPlayer = Players[iThatPlayer];
    if pThisPlayer == nil or pThatPlayer == nil then
        return;
    end

    local pThisUnit = pThisPlayer:GetUnitByID(iThisUnit);
    local pThatUnit = pThatPlayer:GetUnitByID(iThatUnit);
    if pThisUnit == nil or pThatUnit == nil then
        return;
    end

    -- TODO: will implement in DLL later
    if pThisUnit:IsHasPromotion(DestroySupply2ID) then
        local plotX = pThatUnit:GetX();
        local plotY = pThatUnit:GetY();
        for i = 0, 5 do
            local adjPlot = Map.PlotDirection(plotX, plotY, i)
            if (adjPlot ~= nil) then
                local pUnit = adjPlot:GetUnit(0)
                if pUnit and pUnit:GetOwner() ~= pThisUnit:GetOwner() and not pUnit:IsImmuneNegtivePromotions() then --not for immune unit---by HMS
                    pUnit:SetHasPromotion(LoseSupplyID, true);
                end
            end
        end
    end
end);

print("NewCombatEffects_SP10 end");
