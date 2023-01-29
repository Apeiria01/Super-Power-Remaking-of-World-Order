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

print("NewCityStateDiplomaticRule: Check Pass!");