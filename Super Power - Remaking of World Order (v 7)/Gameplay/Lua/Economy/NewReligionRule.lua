function SPNReligionPopulationBuff(iX, iY, iOld, iNew)
    if Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION) then
		return
	end
    local pPlot = Map.GetPlot(iX, iY)
	if pPlot == nil then return end
    local pCity = pPlot:GetPlotCity()
	if pCity == nil then return end
    local eBelief = GameInfo.Beliefs["BELIEF_GODDESS_LOVE"].ID
    if pCity:GetMajorReligionPantheonBelief() == eBelief
    or pCity:GetSecondaryReligionPantheonBelief() == eBelief
    then
        local pPlayer = Players[pPlot:GetOwner()]
        if not pPlayer:IsMajorCiv() then
            return
        end
        if not (iNew > iOld and iNew > 1) then return end
        local pPlot = Map.GetPlot(iX, iY)
        if pPlot== nil then return end
        
        local bonus = (GameInfo.GameSpeeds[Game.GetGameSpeedType()].ConstructPercent/100) * 6
        bonus = math.floor(bonus * (iNew - iOld))
        print("Religion Population Buff bonus = ",bonus)
        if pPlayer:IsHuman() then
            local hex = ToHexFromGrid(Vector2(iX, iY))
            Events.AddPopupTextEvent(HexToWorld(hex), Locale.ConvertTextKey("+{1_Num}[ICON_PEACE]",bonus))
            Events.GameplayFX(hex.x, hex.y, -1)
        end
        pPlayer:ChangeFaith(bonus)
    end

end
GameEvents.SetPopulation.Add(SPNReligionPopulationBuff)

function SPNReligionFounded(iPlayer, iHolyCity, iReligion, iBelief1, iBelief2, iBelief3, iBelief4, iBelief5) 
    if Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION) then
		return
	end
	local pPlayer = Players[iPlayer]
	if not pPlayer:IsMajorCiv() then
        return
    end
    --Holy City Mark
    print("Player founded a religion, mark holy city!")
	local pHolyCity = pPlayer:GetCityByID(iHolyCity)
	pHolyCity:SetNumRealBuilding(GameInfoTypes.BUILDING_RELIGION_HOLYCITY_MARK,1)

end
GameEvents.ReligionFounded.Add(SPNReligionFounded)

function SPNReligionEnhanced(iPlayer, eReligion, iBelief1, iBelief2)
	if Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION) or iPlayer == -1 or not Players[iPlayer]:HasCreatedReligion() then
		return
	end
    local pPlayer = Players[iPlayer]
	if not pPlayer:IsMajorCiv() then
        return
    end

	if iBelief1 and (GameInfo.Beliefs[iBelief1].Type == "BELIEF_MISSIONARY_ZEAL"
	or (GameInfo.Beliefs[iBelief2] and GameInfo.Beliefs[iBelief2].Type == "BELIEF_MISSIONARY_ZEAL"))
	then
		print("Choose BELIEF_MISSIONARY_ZEAL")
		local pHolyCity = Game.GetHolyCityForReligion(eReligion, iPlayer)
		pHolyCity:SetNumRealBuilding(GameInfoTypes.BUILDING_EXTRA_RELIGION_SPREADS_2,1)

    elseif iBelief1 and (GameInfo.Beliefs[iBelief1].Type == "BELIEF_MESSIAH"
    or (GameInfo.Beliefs[iBelief2] and GameInfo.Beliefs[iBelief2].Type == "BELIEF_MESSIAH"))
    then
        print("Choose BELIEF_MESSIAH")
        pPlayer:SetHasPolicy(GameInfo.Policies["POLICY_BELIEF_MESSIAH"].ID,true,true)
        for iUnit in pPlayer:Units() do
			if iUnit:GetUnitClassType() == GameInfoTypes.UNITCLASS_PROPHET then 
				iUnit:SetHasPromotion((GameInfo.UnitPromotions["PROMOTION_GPS_MOVEMENT_SMALL"].ID), true)
			end
		end	
    end

end
GameEvents.ReligionEnhanced.Add(SPNReligionEnhanced)

function SPNReligionConquestedHolyCity(oldOwnerID, isCapital, cityX, cityY, newOwnerID)
    if Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION) or iPlayer == -1 then
		return
	end
    local newOwnerPlayer = Players[newOwnerID]
    local oldOwnerPlayer = Players[oldOwnerID]
    local conquestedCityPlot = Map.GetPlot(cityX, cityY)
	local pCity = conquestedCityPlot:GetPlotCity()

	if newOwnerPlayer == nil or oldOwnerPlayer == nil
    or not newOwnerPlayer:HasCreatedReligion()
    or pCity == nil
    or not pCity:IsHasBuilding(GameInfoTypes.BUILDING_RELIGION_HOLYCITY_MARK)
    then
	 	return
	end

	--Player take back the Holy City
	if newOwnerID == pCity:GetOriginalOwner() then
		local pReligion = newOwnerPlayer:GetReligionCreatedByPlayer()
		for i,v in ipairs(Game.GetBeliefsInReligion(pReligion)) do
			if GameInfo.Beliefs[v].Type == "BELIEF_MISSIONARY_ZEAL" then
				print("Player chose BELIEF_MISSIONARY_ZEAL take back the Holy City")
				pCity:SetNumRealBuilding(GameInfoTypes.BUILDING_EXTRA_RELIGION_SPREADS_2,1)
			elseif GameInfo.Beliefs[v].Type == "BELIEF_RELIGION_PRESSURE" then
				print("Player chose BELIEF_RELIGION_PRESSURE take back the Holy City")
				pCity:SetNumRealBuilding(GameInfoTypes.BUILDING_BELIEF_RELIGION_PRESSURE,1)
			end
		end
	end

end
GameEvents.CityCaptureComplete.Add(SPNReligionConquestedHolyCity) 

function SPNReligionUnitCreatedBuffBonus(iPlayer, iUnit)
	if Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION) or iPlayer == -1 or not Players[iPlayer]:HasCreatedReligion() then
		return
	end
    local pPlayer = Players[iPlayer]
    local pUnit = pPlayer:GetUnitByID(iUnit)
    if not pPlayer:IsMajorCiv() or pUnit == nil then
        return
    end

	if pUnit:GetUnitClassType() == GameInfoTypes.UNITCLASS_PROPHET 
    and pPlayer:HasPolicy(GameInfo.Policies["POLICY_BELIEF_ENLIGHTENMENT"].ID)
    then
        print("Player has BELIEF_MESSIAH and Prophet has been born")
        pUnit:SetHasPromotion((GameInfo.UnitPromotions["PROMOTION_GPS_MOVEMENT_SMALL"].ID), true)
	end
end
Events.SerialEventUnitCreated.Add(SPNReligionUnitCreatedBuffBonus)

print('New Religion Rule: Check Pass')