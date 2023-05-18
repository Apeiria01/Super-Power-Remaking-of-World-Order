print("NewCombatEffects_SP10 start");

local iBarrageCollecton = GameInfoTypes["PROMOTION_COLLECTION_BARRAGE"];
local iMovementLossCollecton = GameInfoTypes["PROMOTION_COLLECTION_MOVEMENT_LOST"];
local iMovementLoss2 = GameInfoTypes["PROMOTION_MOVEMENT_LOST_2"];
local iMoveDenominator = GameDefines["MOVE_DENOMINATOR"];
GameEvents.OnTriggerAddEnermyPromotion.Add(function(eThisPromotionType, eThisPromotionCollection, iThisPlayer,
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
        message = 0;
    else
        if pThatUnit:CanMove() then
            pThatUnit:SetMoves(iMoveDenominator);
        end
        message = 1;
    end

    local thisUnitName = pThisUnit:GetName();
    local thatUnitName = pThatUnit:GetName();
    local text = "";
    if pThisPlayer:IsHuman() then
        if message == 0 then
            text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_ENEMY_SLOWED", thisUnitName, thatUnitName);
        elseif message == 1 then
            text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_ENEMY_STOPPED", thisUnitName, thatUnitName);
        end
    end
    if pThatPlayer:IsHuman() then
        if message == 0 then
            text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_US_SLOWED", thisUnitName, thatUnitName);
        elseif message == 1 then
            text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_US_STOPPED", thisUnitName, thatUnitName);
        end
    end

    if text ~= "" then
        Events.GameplayAlertMessage(text);
    end
end);


print("NewCombatEffects_SP10 end");
