local policyCollectionRuleID = GameInfo.Policies["POLICY_COLLECTIVE_RULE"].ID

function SPEReligionAdopt(pPlayer,iBelief,pHolyCity)
    --Founded
    if iBelief == GameInfo.Beliefs["BELIEF_RELIGIOUS_COLONIZATION"].ID then
		if pPlayer:HasPolicy(policyCollectionRuleID) 
        and not pPlayer:IsPolicyBlocked(policyCollectionRuleID)
        then
            print("Player chose BELIEF_RELIGIOUS_COLONIZATION and has POLICY_COLLECTIVE_RULE, set free Building")
            pHolyCity:SetNumRealBuilding(GameInfoTypes.BUILDING_BELIEF_RELIGIOUS_COLONIZATION_2,1)
        else 
            print("Player chose BELIEF_RELIGIOUS_COLONIZATION , set free Building")
            pHolyCity:SetNumRealBuilding(GameInfoTypes.BUILDING_BELIEF_RELIGIOUS_COLONIZATION,1)
        end

    --Enhanced
    elseif iBelief == GameInfo.Beliefs["BELIEF_MISSIONARY_ZEAL"].ID
	then
		print("Choose BELIEF_MISSIONARY_ZEAL")
		pHolyCity:SetNumRealBuilding(GameInfoTypes.BUILDING_EXTRA_RELIGION_SPREADS_2,1)

    elseif iBelief == GameInfo.Beliefs["BELIEF_MESSIAH"].ID
    then
        print("Choose BELIEF_MESSIAH")
        pPlayer:SetHasPolicy(GameInfo.Policies["POLICY_BELIEF_MESSIAH"].ID,true,true)
        for iUnit in pPlayer:Units() do
			if iUnit:GetUnitClassType() == GameInfoTypes.UNITCLASS_PROPHET then 
				iUnit:SetHasPromotion((GameInfo.UnitPromotions["PROMOTION_RIVAL_TERRITORY"].ID), true)
			end
		end	

    elseif iBelief == GameInfo.Beliefs["BELIEF_JUST_WAR"].ID 
    then
		print("Choose BELIEF_JUST_WAR, set free Policy")
		pPlayer:SetHasPolicy(GameInfo.Policies["POLICY_BELIEF_JUST_WAR"].ID,true,true)	
    
    elseif iBelief == GameInfo.Beliefs["BELIEF_DEFENDER_FAITH"].ID 
    then
		print("Choose BELIEF_DEFENDER_FAITH,set free building in holy city")
		pHolyCity:SetNumRealBuilding(GameInfoTypes.BUILDING_BELIEF_DEFENDER_FAITH,1)

    elseif iBelief == GameInfo.Beliefs["BELIEF_SACRED_CALENDAR"].ID
    then
        print("Choose BELIEF_SACRED_CALENDAR, set free Policy")
        pPlayer:SetHasPolicy(GameInfo.Policies["POLICY_BELIEF_SACRED_CALENDAR"].ID,true,true)
    
    elseif iBelief == GameInfo.Beliefs["BELIEF_ORTHODOX_CHURCH"].ID 
    then
		print("Choose BELIEF_ORTHODOX_CHURCH,set free building in holy city")
		pHolyCity:SetNumRealBuilding(GameInfoTypes.BUILDING_BELIEF_ORTHODOX_CHURCH,1)

    elseif iBelief == GameInfo.Beliefs["BELIEF_RELIGIOUS_UNITY"].ID 
    then
		print("Choose BELIEF_RELIGIOUS_UNITY, set free Policy")
		pPlayer:SetHasPolicy(GameInfo.Policies["POLICY_BELIEF_RELIGIOUS_UNITY"].ID,true,true)	

    --Reformed
    elseif iBelief == GameInfo.Beliefs["BELIEF_HEATHEN_CONVERSION"].ID 
    then
		print("Choose BELIEF_HEATHEN_CONVERSION")
		pPlayer:SetHasPolicy(GameInfo.Policies["POLICY_BELIEF_HEATHEN_CONVERSION"].ID,true,true)	
    
    end
end

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
    --Founded Belief Effect
    SPEReligionAdopt(pPlayer,iBelief3,pHolyCity)
    SPEReligionAdopt(pPlayer,iBelief5,pHolyCity)

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
    local pHolyCity = Game.GetHolyCityForReligion(eReligion, iPlayer)
    --Enhanced Belief Effect
    SPEReligionAdopt(pPlayer,iBelief2,pHolyCity)

end
GameEvents.ReligionEnhanced.Add(SPNReligionEnhanced)

function SPNReligionReformed(iPlayer, iReligion, iBelief1) 
	if Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION) or iPlayer == -1 or not Players[iPlayer]:HasCreatedReligion() then
		return
	end
    local pPlayer = Players[iPlayer]
	if not pPlayer:IsMajorCiv() then
        return
    end
    local pHolyCity = Game.GetHolyCityForReligion(iReligion, iPlayer)
    --Reformed Belief Effect
    SPEReligionAdopt(pPlayer,iBelief1,pHolyCity)

end
GameEvents.ReligionReformed.Add(SPNReligionReformed) 

local spn_Religions_Table = {}
local spn_Religions_Count = 1
for row in DB.Query("SELECT ID FROM Religions WHERE Type != 'RELIGION_PANTHEON';") do 	
	spn_Religions_Table[spn_Religions_Count] = row
	spn_Religions_Count = spn_Religions_Count + 1
end

function SPNReligionConquestedHolyCity(oldOwnerID, isCapital, cityX, cityY, newOwnerID, numPop, isConquest)
    if Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION) or newOwnerID == -1 then
		return
	end
    local newOwnerPlayer = Players[newOwnerID]
    local oldOwnerPlayer = Players[oldOwnerID]
	local pCity = Map.GetPlot(cityX, cityY):GetPlotCity()

	if newOwnerPlayer == nil or oldOwnerPlayer == nil
    or not newOwnerPlayer:HasCreatedReligion()
    or pCity == nil
    then
	 	return
	end

    --Player has BELIEF_JUST_WAR and conquested city
    if newOwnerPlayer:HasPolicy(GameInfo.Policies["POLICY_BELIEF_JUST_WAR"].ID) 
    and isConquest
    then
        local aReligion = pCity:GetReligiousMajority()
        local bReligion = newOwnerPlayer:GetReligionCreatedByPlayer()
        if aReligion == bReligion then
            if pCity:IsResistance() then 
                local ReligionResistanceReduce = math.floor(pCity:GetResistanceTurns() / 2)
				pCity:ChangeResistanceTurns(-ReligionResistanceReduce)
            end
        end
    end

    --Player has BELIEF_HEATHEN_CONVERSION and conquested city
    if newOwnerPlayer:HasPolicy(GameInfo.Policies["POLICY_BELIEF_HEATHEN_CONVERSION"].ID) 
    and isConquest
    then
        local newOwnerReligionID = newOwnerPlayer:GetReligionCreatedByPlayer()
		local religionsTable = spn_Religions_Table
		local numReligions = #religionsTable
		local oldReligionFollowersInCity = pCity:GetNumFollowers(newOwnerReligionID)
		
		for index = 1, numReligions do
			local row = religionsTable[index]
			local religionID = row.ID
			pCity:ConvertPercentFollowers(newOwnerReligionID, religionID, 50) 
		end
		pCity:ConvertPercentFollowers(newOwnerReligionID, -1, 50)

		local newReligionFollowersInCity = pCity:GetNumFollowers(newOwnerReligionID)
        local ReligionFollowersBonus = 10 * (newOwnerPlayer:GetCurrentEra() + 1)
		local religionBonus = (newReligionFollowersInCity - oldReligionFollowersInCity) * ReligionFollowersBonus
		print("Player has BELIEF_HEATHEN_CONVERSION and conquested city,convert followers",newReligionFollowersInCity,oldReligionFollowersInCity)
		newOwnerPlayer:ChangeGold(religionBonus)
		newOwnerPlayer:ChangeFaith(religionBonus)
		newOwnerPlayer:ChangeJONSCulture(religionBonus)
		if newOwnerPlayer:IsHuman() 
        and religionBonus > 0
        then
			Events.GameplayAlertMessage(Locale.ConvertTextKey("TXT_KEY_MESSAGE_BELIEF_HEATHEN_CONVERSION_ALERT",pCity:GetName(),religionBonus) )
		end
    end

	--Player take back the Holy City
	if newOwnerID == pCity:GetOriginalOwner() 
    and pCity:IsHasBuilding(GameInfoTypes.BUILDING_RELIGION_HOLYCITY_MARK)
    then
		local pReligion = newOwnerPlayer:GetReligionCreatedByPlayer()
		for i,v in ipairs(Game.GetBeliefsInReligion(pReligion)) do
			if GameInfo.Beliefs[v].Type == "BELIEF_MISSIONARY_ZEAL" then
				print("Player has BELIEF_MISSIONARY_ZEAL and take back the Holy City")
				pCity:SetNumRealBuilding(GameInfoTypes.BUILDING_EXTRA_RELIGION_SPREADS_2,1)

			elseif GameInfo.Beliefs[v].Type == "BELIEF_RELIGION_PRESSURE" then
				print("Player has BELIEF_RELIGION_PRESSURE and take back the Holy City")
				pCity:SetNumRealBuilding(GameInfoTypes.BUILDING_BELIEF_RELIGION_PRESSURE,1)

            elseif GameInfo.Beliefs[v].Type == "BELIEF_DEFENDER_FAITH" then
				print("Player has BELIEF_DEFENDER_FAITH and take back the Holy City")
				pCity:SetNumRealBuilding(GameInfoTypes.BUILDING_BELIEF_DEFENDER_FAITH,1)

            elseif GameInfo.Beliefs[v].Type == "BELIEF_ORTHODOX_CHURCH" then
				print("Player has BELIEF_ORTHODOX_CHURCH and take back the Holy City")
				pCity:SetNumRealBuilding(GameInfoTypes.BUILDING_BELIEF_ORTHODOX_CHURCH,1)

            elseif GameInfo.Beliefs[v].Type == "BELIEF_RELIGIOUS_COLONIZATION" then
				print("Player has BELIEF_RELIGIOUS_COLONIZATION and take back the Holy City")
                if newOwnerPlayer:HasPolicy(policyCollectionRuleID) 
                and not newOwnerPlayer:IsPolicyBlocked(policyCollectionRuleID)
                then
                    pCity:SetNumRealBuilding(GameInfoTypes.BUILDING_BELIEF_RELIGIOUS_COLONIZATION_2,1)
                else
                    pCity:SetNumRealBuilding(GameInfoTypes.BUILDING_BELIEF_RELIGIOUS_COLONIZATION,1)
                end
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
    then
        if pPlayer:HasPolicy(GameInfo.Policies["POLICY_BELIEF_MESSIAH"].ID) then
            print("Player has BELIEF_MESSIAH and Prophet has been born")
            pUnit:SetHasPromotion((GameInfo.UnitPromotions["PROMOTION_RIVAL_TERRITORY"].ID), true)
        end
        local eReligion = pPlayer:GetReligionCreatedByPlayer()
		local pHolyCity = Game.GetHolyCityForReligion(eReligion, iPlayer)
        if pHolyCity:IsHasBuilding(GameInfoTypes.BUILDING_BELIEF_ORTHODOX_CHURCH) then
            local numOfTargetCity = 0
            for iCity in pPlayer:Cities() do
                if eReligion == iCity:GetReligiousMajority() then
                    numOfTargetCity = numOfTargetCity +1
                end
            end
            if numOfTargetCity > 0 then
                local religionCultureBonus = (pPlayer:GetCurrentEra() + 1) * 10 * numOfTargetCity
                pPlayer:ChangeJONSCulture(religionCultureBonus)
                if pPlayer:IsHuman() then
                    local pPlot = pUnit:GetPlot()
                    local hex = ToHexFromGrid(Vector2(pPlot:GetX(),pPlot:GetY()))
                    Events.AddPopupTextEvent(HexToWorld(hex), Locale.ConvertTextKey("+{1_Num}[ICON_CULTURE]",religionCultureBonus))
                    Events.GameplayFX(hex.x, hex.y, -1)
                end
            end
        end
	end
end
Events.SerialEventUnitCreated.Add(SPNReligionUnitCreatedBuffBonus)

function SPNReligionPolicyAdopt(iPlayer,iPolicy)
	if Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION) or iPlayer == -1 or not Players[iPlayer]:HasCreatedReligion() then
		return
	end
    local pPlayer = Players[iPlayer]
	if not pPlayer:IsMajorCiv() then
        return
    end

    if iPolicy == GameInfoTypes["POLICY_COLLECTIVE_RULE"] then
        local eReligion = pPlayer:GetReligionCreatedByPlayer()
        local pHolyCity = Game.GetHolyCityForReligion(eReligion, iPlayer)
        if pHolyCity:IsHasBuilding(GameInfoTypes.BUILDING_BELIEF_RELIGIOUS_COLONIZATION) then
            print("Player chose POLICY_COLLECTIVE_RULE, and has BELIEF_RELIGIOUS_COLONIZATION, change free Building")
            pHolyCity:SetNumRealBuilding(GameInfoTypes.BUILDING_BELIEF_RELIGIOUS_COLONIZATION,0)
            pHolyCity:SetNumRealBuilding(GameInfoTypes.BUILDING_BELIEF_RELIGIOUS_COLONIZATION_2,1)
        end
    end

end
GameEvents.PlayerAdoptPolicy.Add(SPNReligionPolicyAdopt)

function SPNReligionBlockPolicyBranch(iPlayer,iPolicyBranch,isBlock)
	if Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION) or iPlayer == -1 or not Players[iPlayer]:HasCreatedReligion() then
		return
	end
    local pPlayer = Players[iPlayer]
	if not pPlayer:IsMajorCiv() then
        return
    end
	if (iPolicyBranch == GameInfo.PolicyBranchTypes["POLICY_BRANCH_LIBERTY"].ID
	or iPolicyBranch == GameInfo.PolicyBranchTypes["POLICY_BRANCH_TRADITION"].ID)
    and isBlock
	then
        local eReligion = pPlayer:GetReligionCreatedByPlayer()
        local pHolyCity = Game.GetHolyCityForReligion(eReligion, iPlayer)
        if pHolyCity:IsHasBuilding(GameInfoTypes.BUILDING_BELIEF_RELIGIOUS_COLONIZATION_2) then
            print("Player has BELIEF_RELIGIOUS_COLONIZATION, and change base Policy Branch 1")
            pHolyCity:SetNumRealBuilding(GameInfoTypes.BUILDING_BELIEF_RELIGIOUS_COLONIZATION_2,0)
            pHolyCity:SetNumRealBuilding(GameInfoTypes.BUILDING_BELIEF_RELIGIOUS_COLONIZATION,1)
        elseif pHolyCity:IsHasBuilding(GameInfoTypes.BUILDING_BELIEF_RELIGIOUS_COLONIZATION) then
            print("Player has BELIEF_RELIGIOUS_COLONIZATION, and change base Policy Branch 2")
            pHolyCity:SetNumRealBuilding(GameInfoTypes.BUILDING_BELIEF_RELIGIOUS_COLONIZATION,0)
            pHolyCity:SetNumRealBuilding(GameInfoTypes.BUILDING_BELIEF_RELIGIOUS_COLONIZATION_2,1)
        end
	end
end
GameEvents.PlayerBlockPolicyBranch.Add(SPNReligionBlockPolicyBranch)

function SPNReligionMinorCivQuestBonus(iMajor, iMinor, iQuestType, iStartTurn, iOldInfluence, iNewInfluence) 
    if Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION) or iMajor == -1 or not Players[iMajor]:HasCreatedReligion() then
		return
	end
	local pPlayer = Players[iMajor]
	local civPlayer = Players[iMinor]
	if pPlayer == nil or civPlayer == nil or pPlayer:IsMinorCiv() or pPlayer:IsBarbarian() then
	 	return
	end
	if pPlayer:HasPolicy(GameInfo.Policies["POLICY_BELIEF_RELIGIOUS_UNITY"].ID) 
    and civPlayer:HasReligionInMostCities(pPlayer:GetReligionCreatedByPlayer())
    then
		local bonus =math.floor((iNewInfluence - iOldInfluence) / 100 * 0.5)
        civPlayer:ChangeMinorCivFriendshipWithMajor(iMajor,bonus)
		print("MajorCiv has BELIEF_RELIGIOUS_UNITY and completed MinorCiv quest:",bonus)
	end
end
GameEvents.PlayerCompletedQuest.Add(SPNReligionMinorCivQuestBonus) 

print('New Religion Rule: Check Pass')