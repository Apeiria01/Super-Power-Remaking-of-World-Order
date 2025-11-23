print("NewCombatEffects_SP10 start");
include("FLuaVector.lua");

local iBarrageCollecton = GameInfoTypes["PROMOTION_COLLECTION_BARRAGE"];
local iMovementLossCollecton = GameInfoTypes["PROMOTION_COLLECTION_MOVEMENT_LOST"];
local iMovementLoss2 = GameInfoTypes["PROMOTION_MOVEMENT_LOST_2"];
local iMoveDenominator = GameDefines["MOVE_DENOMINATOR"];
GameEvents.OnTriggerAddEnemyPromotion.Add(function(eThisPromotionType, eThisPromotionCollection, eThisBattleType, iThisPlayer,
                                                   iThisUnit, iThisUnitType, eThatPromotionType,
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

    local iActivePlayer = Game.GetActivePlayer();
    local thisUnitName = pThisUnit:GetName();
    local thatUnitName = pThatUnit:GetName();
    if iThisPlayer == iActivePlayer then
        if message == 0 then
            local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_ENEMY_SLOWED", thisUnitName, thatUnitName);
            Events.GameplayAlertMessage(text);
        elseif message == 1 then
            local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_ENEMY_STOPPED", thisUnitName, thatUnitName);
            Events.GameplayAlertMessage(text);
        end
    elseif iThatPlayer == iActivePlayer then
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
GameEvents.OnTriggerAddEnemyPromotion.Add(function(eThisPromotionType, eThisPromotionCollection, eThisBattleType, iThisPlayer,
                                                   iThisUnit, iThisUnitType, eThatPromotionType,
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

    local iActivePlayer = Game.GetActivePlayer();
    local thisUnitName = pThisUnit:GetName();
    local thatUnitName = pThatUnit:GetName();
    if iThisPlayer == iActivePlayer then
        local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_ENEMY_SUNDERED", thisUnitName, thatUnitName);
        Events.GameplayAlertMessage(text);
    elseif iThatPlayer == iActivePlayer then
        local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_US_SUNDERED", thisUnitName, thatUnitName);
        Events.GameplayAlertMessage(text);
    end
end);

local iColCollectionID = GameInfoTypes["PROMOTION_COLLECTION_COLLATERAL_DAMAGE"];
local iWeakenCollectionID = GameInfoTypes["PROMOTION_COLLECTION_MORAL_WEAKEN"];
GameEvents.OnTriggerAddEnemyPromotion.Add(function(eThisPromotionType, eThisPromotionCollection, eThisBattleType, iThisPlayer,
                                                   iThisUnit, iThisUnitType, eThatPromotionType,
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

    local iActivePlayer = Game.GetActivePlayer();
    local thisUnitName = pThisUnit:GetName();
    local thatUnitName = pThatUnit:GetName();
    if iThisPlayer == iActivePlayer then
        local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_ENEMY_MORAL_WEAKEN", thisUnitName, thatUnitName);
        Events.GameplayAlertMessage(text);
    elseif iThatPlayer == iActivePlayer then
        local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_US_MORAL_WEAKEN", thisUnitName, thatUnitName);
        Events.GameplayAlertMessage(text);
    end
end);

local iLoseSupplyCollectionID = GameInfoTypes["PROMOTION_COLLECTION_LOSE_SUPPLY"];
local DestroySupply2ID = GameInfoTypes["PROMOTION_DESTROY_SUPPLY_2"]
local LoseSupplyID = GameInfoTypes["PROMOTION_LOSE_SUPPLY"]
GameEvents.OnTriggerAddEnemyPromotion.Add(function(eThisPromotionType, eThisPromotionCollection, eThisBattleType, iThisPlayer,
                                                   iThisUnit, iThisUnitType, eThatPromotionType,
                                                   eThatPromotionCollection, iThatPlayer, iThatUnit, iThatUnitType)
    if eThatPromotionCollection ~= iLoseSupplyCollectionID then
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

    local iActivePlayer = Game.GetActivePlayer();

    -- TODO: will implement in DLL later
    if pThisUnit:IsHasPromotion(DestroySupply2ID) then
        local plotX = pThatUnit:GetX();
        local plotY = pThatUnit:GetY();
        for i = 0, 5 do
            local adjPlot = Map.PlotDirection(plotX, plotY, i)
            if (adjPlot ~= nil) then
                local pUnit = adjPlot:GetUnit(0)
                if pUnit and pUnit:GetOwner() ~= pThisUnit:GetOwner()
                and not pUnit:IsHasPromotion(LoseSupplyID)
                and not pUnit:IsImmuneNegtivePromotions() 
                then
                    pUnit:SetHasPromotion(LoseSupplyID, true);
                    if iActivePlayer == iThisPlayer then
                        local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_ENEMY_SUPPLY_DESTROYED", Locale.ConvertTextKey("TXT_KEY_PROMOTION_LOSE_SUPPLY"), pUnit:GetName(), "[COLOR_NEGATIVE_TEXT]" .. -20 .. "[ENDCOLOR]");
                        Events.GameplayAlertMessage(text);
                    elseif iActivePlayer == iThatPlayer then
                        local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_US_SUPPLY_DESTROYED", Locale.ConvertTextKey("TXT_KEY_PROMOTION_LOSE_SUPPLY"), pUnit:GetName(), "[COLOR_NEGATIVE_TEXT]" .. -20 .. "[ENDCOLOR]");
                        Events.GameplayAlertMessage(text);
                    end
                end
            end
        end
    end

    if eThatPromotionType == -1 then return end
    if iActivePlayer == iThisPlayer then
        local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_ENEMY_SUPPLY_DESTROYED", Locale.ConvertTextKey("TXT_KEY_PROMOTION_LOSE_SUPPLY"), pThatUnit:GetName(), "[COLOR_NEGATIVE_TEXT]" .. -20 .. "[ENDCOLOR]");
        Events.GameplayAlertMessage(text);
    elseif iActivePlayer == iThatPlayer then
        local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_US_SUPPLY_DESTROYED", Locale.ConvertTextKey("TXT_KEY_PROMOTION_LOSE_SUPPLY"), pThatUnit:GetName(), "[COLOR_NEGATIVE_TEXT]" .. -20 .. "[ENDCOLOR]");
        Events.GameplayAlertMessage(text);
    end
end);

local iSiegeWoodenBoatCollectionID = GameInfoTypes["PROMOTION_COLLECTION_SIEGE_WOODEN_BOAT"];
local iPromotionDamage1 = GameInfoTypes["PROMOTION_DAMAGE_1"];
local iPromotionDamage2 = GameInfoTypes["PROMOTION_DAMAGE_2"];
local WoodensQuery = DB.CreateQuery("SELECT ID FROM Units WHERE MoveRate = 'WOODEN_BOAT';");
local WoodenTable = {}
for row in WoodensQuery() do WoodenTable[row.ID] = true end
GameEvents.CanAddEnemyPromotion.Add(function(eThisPromotionType, iThisPromotionCollectionType, eThisBattleRole,
                                              iThisPlayer, iThisUnit, iThatPlayer, iThatUnit)
    if iThisPromotionCollectionType ~= iSiegeWoodenBoatCollectionID then
        return false;
    end

    local pThisPlayer = Players[iThisPlayer];
    local pThatPlayer = Players[iThatPlayer];
    if pThisPlayer == nil or pThatPlayer == nil then
        return false;
    end

    local pThisUnit = pThisPlayer:GetUnitByID(iThisUnit);
    local pThatUnit = pThatPlayer:GetUnitByID(iThatUnit);
    if pThisUnit == nil or pThatUnit == nil then
        return false;
    end

    if pThatUnit:IsHasPromotion(iPromotionDamage2) then
        return false;
    end

    local result = false;
    local tdebuff, tlostHP
    if pThatUnit:IsCombatUnit()
    and pThatUnit:GetDomainType() == DomainTypes.DOMAIN_SEA
    and WoodenTable[pThatUnit:GetUnitType()] then
        local combatRoll = Game.Rand(100, "At NewCombatRules.lua NewAttackEffect()");
        if pThatUnit:IsHasPromotion(iPromotionDamage1) then
            result = combatRoll <= 80;
            tdebuff = Locale.ConvertTextKey("TXT_KEY_PROMOTION_DAMAGE_2");
            tlostHP = "[COLOR_NEGATIVE_TEXT]" .. -20 .. "[ENDCOLOR]";
        else
            result = combatRoll <= 50;
            tdebuff = Locale.ConvertTextKey("TXT_KEY_PROMOTION_DAMAGE_1");
            tlostHP = "[COLOR_NEGATIVE_TEXT]" .. -10 .. "[ENDCOLOR]";
        end
    end

    if result then
        local iActivePlayer = Game.GetActivePlayer()
        if iThisPlayer == iActivePlayer then
            local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_ENEMY_SUPPLY_DESTROYED", tdebuff, pThatUnit:GetName(), tlostHP);
            Events.GameplayAlertMessage(text);
        elseif iThatPlayer == iActivePlayer then
            local heading = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_US_SUPPLY_DESTROYED_SHORT", tdebuff);
            local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_US_SUPPLY_DESTROYED", tdebuff, pThatUnit:GetName(), tlostHP);
            pThatPlayer:AddNotification(NotificationTypes.NOTIFICATION_GENERIC, text, heading, pThatUnit:GetX(), pThatUnit:GetY());
        end
    end

    return result;
end);


print("NewCombatEffects_SP10 end");
