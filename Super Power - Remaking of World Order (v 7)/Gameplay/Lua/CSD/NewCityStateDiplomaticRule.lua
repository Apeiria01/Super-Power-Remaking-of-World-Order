function AbleGiftMilitia(iMajor, iMinor, iUnit)
    local ableMilitia = PreGame.GetGameOption("GAMEOPTION_ABLE_GIFT_MILITIA") == 0;
    if not ableMilitia then
        return true;
    end

    local pMajor = Players[iMajor];
    if pMajor:IsMinorCiv() or pMajor:IsBarbarian() then return true end

    local pUnit = pMajor:GetUnitByID(iUnit);
    if pUnit == nil then
        return true;
    end

    return not pUnit:IsHasPromotion(GameInfoTypes.PROMOTION_MILITIA_COMBAT);
end
GameEvents.PlayerCanGiftUnit.Add(AbleGiftMilitia);

function BlockMilitiaGiving(iPlayer, iUnit, iCommand, iData1, iData2, iPlotX, iPlotY, bTestVisible)
    if not (iCommand == CommandTypes.COMMAND_GIFT) then 
        return true 
    end
    local enableMilitiaGiving = PreGame.GetGameOption("GAMEOPTION_ABLE_GIFT_MILITIA") == 1
    local pPlot = Map.GetPlot(iPlotX, iPlotY)
    local pPlayer = Players[iPlayer]
    if (not pPlayer) or (not pPlot) then 
        --Yield condition check
        return true
    end

    local pUnit = pPlayer:GetUnitByID(iUnit)
    if pUnit and pPlot:IsOwned() then
        local pTargetPlayer = Players[pPlot:GetOwner()]
        if pTargetPlayer:IsMinorCiv() then
            return (not pUnit:IsHasPromotion(GameInfoTypes.PROMOTION_MILITIA_COMBAT)) or enableMilitiaGiving
        else
            return true
        end
    else
        --Yield condition check
        return true
    end
end
GameEvents.CanDoCommand.Add(BlockMilitiaGiving);

print("NewCityStateDiplomaticRule: Check Pass!");