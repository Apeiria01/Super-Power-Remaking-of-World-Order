function DisableGiftMilitia(iMajor, iMinor, iUnit)
    local disableMilitia = PreGame.GetGameOption("GAMEOPTION_DISABLE_GIFT_MILITIA") == 1;
    if not disableMilitia then
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
GameEvents.PlayerCanGiftUnit.Add(DisableGiftMilitia);

print("NewCityStateDiplomaticRule: Check Pass!");