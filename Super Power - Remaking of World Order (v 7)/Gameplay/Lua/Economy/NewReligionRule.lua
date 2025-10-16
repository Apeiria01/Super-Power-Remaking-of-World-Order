if Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION) then return end

local policyCollectionRuleID = GameInfo.Policies["POLICY_COLLECTIVE_RULE"].ID

function SPReformeBeliefs(iPlayer, iReligion, iBelief)
	if iPlayer == -1 or not Players[iPlayer]:HasCreatedReligion() or Game.GetHolyCityForReligion(iReligion, iPlayer) == nil
	then
		return;
	end

	local pPlayer  = Players[iPlayer];
    local pCity = Game.GetHolyCityForReligion(iReligion, iPlayer)
    if pCity:GetOwner() ~= iPlayer then
        pCity = pPlayer:GetCapitalCity()
    end
	if iBelief == GameInfoTypes["BELIEF_UNITY_OF_PROPHETS"] then
		local iProphetID = pPlayer:GetCivUnit(GameInfoTypes.UNITCLASS_PROPHET);
        if iProphetID < 0 then return end
		pPlayer:InitUnit(iProphetID, pCity:GetX(), pCity:GetY())
	elseif iBelief == GameInfoTypes["BELIEF_BELIEF_CURSADER"] then
        local iCurasderUnitType = pPlayer:GetCivUnit(GameInfoTypes.UNITCLASS_TEUTONIC_KNIGHT)
        for i = 1, 6, 1 do
            local pUnit = pPlayer:InitUnit(iCurasderUnitType, pCity:GetX(), pCity:GetY())
			pUnit:ChangeExperience(60)
            pUnit:JumpToNearestValidPlot()
        end
	end
end

GameEvents.ReligionReformed.Add(SPReformeBeliefs)

function SPEReligionAdopt(pPlayer,iBelief,pHolyCity)
    if iBelief == -1 then return end
    --Founded
    if iBelief == GameInfoTypes["BELIEF_RELIGIOUS_COLONIZATION"] then
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
    elseif iBelief == GameInfoTypes["BELIEF_MISSIONARY_ZEAL"]
    and pPlayer:GetID() == pHolyCity:GetOwner()
	then
		print("Choose BELIEF_MISSIONARY_ZEAL")
		pHolyCity:SetNumRealBuilding(GameInfoTypes.BUILDING_EXTRA_RELIGION_SPREADS_2,1)
    
    elseif iBelief == GameInfoTypes["BELIEF_RELIGIOUS_TEXTS"]
    and pPlayer:GetID() == pHolyCity:GetOwner()
	then
		print("Choose BELIEF_RELIGIOUS_TEXTS")
		pHolyCity:SetNumRealBuilding(GameInfoTypes.BUILDING_BELIEF_RELIGIOUS_TEXTS,1)
    end
end

function SPNReligionFounded(iPlayer, iHolyCity, iReligion, iBelief1, iBelief2, iBelief3, iBelief4, iBelief5) 
	local pPlayer = Players[iPlayer]
	if not pPlayer:IsMajorCiv() then
        return
    end
	local pHolyCity = pPlayer:GetCityByID(iHolyCity)
    --Founded Belief Effect
    SPEReligionAdopt(pPlayer,iBelief1,pHolyCity)   
    SPEReligionAdopt(pPlayer,iBelief2,pHolyCity)
    SPEReligionAdopt(pPlayer,iBelief3,pHolyCity)
    SPEReligionAdopt(pPlayer,iBelief4,pHolyCity)
    SPEReligionAdopt(pPlayer,iBelief5,pHolyCity)

end
GameEvents.ReligionFounded.Add(SPNReligionFounded)

function SPNReligionEnhanced(iPlayer, eReligion, iBelief1, iBelief2)
	if iPlayer == -1 or not Players[iPlayer]:HasCreatedReligion() then
		return
	end
    local pPlayer = Players[iPlayer]
	if not pPlayer:IsMajorCiv() then
        return
    end
    local pHolyCity = Game.GetHolyCityForReligion(eReligion, iPlayer)
    --Enhanced Belief Effect
    SPEReligionAdopt(pPlayer,iBelief1,pHolyCity)
    SPEReligionAdopt(pPlayer,iBelief2,pHolyCity)

end
GameEvents.ReligionEnhanced.Add(SPNReligionEnhanced)

function SPNReligionReformed(iPlayer, iReligion, iBelief1) 
	if iPlayer == -1 or not Players[iPlayer]:HasCreatedReligion() then
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

function OnHolyCityRegain(pCity, pPlayer)
    local iOwnerReligion = pPlayer:GetReligionCreatedByPlayer()
	if pCity:IsHolyCityForReligion(iOwnerReligion)
    then
		for i, iBelief in ipairs(Game.GetBeliefsInReligion(iOwnerReligion)) do
			if iBelief == GameInfoTypes["BELIEF_MISSIONARY_ZEAL"] then
				print("Player has BELIEF_MISSIONARY_ZEAL and take back the Holy City")
				pCity:SetNumRealBuilding(GameInfoTypes.BUILDING_EXTRA_RELIGION_SPREADS_2,1)

            elseif iBelief == GameInfoTypes["BELIEF_RELIGIOUS_TEXTS"] then
				print("Player has BELIEF_RELIGIOUS_TEXTS and take back the Holy City")
				pCity:SetNumRealBuilding(GameInfoTypes.BUILDING_BELIEF_RELIGIOUS_TEXTS,1)

            elseif iBelief == GameInfoTypes["BELIEF_RELIGIOUS_COLONIZATION"] then
				print("Player has BELIEF_RELIGIOUS_COLONIZATION and take back the Holy City")
                if pPlayer:HasPolicy(policyCollectionRuleID) 
                and not pPlayer:IsPolicyBlocked(policyCollectionRuleID)
                then
                    pCity:SetNumRealBuilding(GameInfoTypes.BUILDING_BELIEF_RELIGIOUS_COLONIZATION_2,1)
                else
                    pCity:SetNumRealBuilding(GameInfoTypes.BUILDING_BELIEF_RELIGIOUS_COLONIZATION,1)
                end
			end
		end
	end
end

local spn_Religions_Table = {}
local spn_Religions_Count = 1
for row in DB.Query("SELECT ID FROM Religions WHERE Type != 'RELIGION_PANTHEON';") do 	
	spn_Religions_Table[spn_Religions_Count] = row
	spn_Religions_Count = spn_Religions_Count + 1
end

local HeathenConversionEnable = GameInfo.SPReligionLuaEffectEnable.BELIEF_HEATHEN_CONVERSION.Enabled
function SPNReligionConquestedHolyCity(oldOwnerID, isCapital, cityX, cityY, newOwnerID, numPop, isConquest)
    if newOwnerID == -1 then return end
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
    if newOwnerPlayer:HasBelief(GameInfoTypes["BELIEF_JUST_WAR"])
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
    if HeathenConversionEnable
    and newOwnerPlayer:HasBelief(GameInfoTypes["BELIEF_HEATHEN_CONVERSION"])
    and isConquest
    then
        local newOwnerReligionID = newOwnerPlayer:GetReligionCreatedByPlayer()
		local religionsTable = spn_Religions_Table
		local numReligions = #religionsTable
		local oldReligionFollowersInCity = pCity:GetNumFollowers(newOwnerReligionID)
		
		for index = 1, numReligions do
			local row = religionsTable[index]
			local religionID = row.ID
			pCity:ConvertPercentFollowers(newOwnerReligionID, religionID, 40) 
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
    OnHolyCityRegain(pCity, newOwnerPlayer)
end
GameEvents.CityCaptureComplete.Add(SPNReligionConquestedHolyCity)
function SPTOnReligionFounderChanged(iOldFounder, iCity, iNewFounder, iReligion, bIsRegain)
    local pPlayer = Players[iNewFounder]
    if not pPlayer or not pPlayer:IsMajorCiv() then return end
    local pCity = pPlayer:GetCityByID(iCity)
    if not pCity then return end
    OnHolyCityRegain(pCity, pPlayer)
end
GameEvents.ReligionFounderChanged.Add(SPTOnReligionFounderChanged)
function SPNReligionUnitCreatedOutputBonus(iPlayer, iUnit, iUnitType, iPlotX, iPlotY)
	if iPlayer == -1 or not Players[iPlayer]:HasCreatedReligion() then
		return
	end
    local pPlayer = Players[iPlayer]
    local pUnit = pPlayer:GetUnitByID(iUnit)
    if not pPlayer:IsMajorCiv() or pUnit == nil then
        return
    end

	if pUnit:GetUnitClassType() == GameInfoTypes.UNITCLASS_PROPHET 
    then
        local eReligion = pPlayer:GetReligionCreatedByPlayer()
		local pHolyCity = Game.GetHolyCityForReligion(eReligion, iPlayer)
        if iPlotX ~= pHolyCity:GetX() or iPlotY ~= pHolyCity:GetY() then
            return
        end
        if pPlayer:HasBelief(GameInfoTypes.BELIEF_ORTHODOX_CHURCH)
        and pHolyCity:HasBelief(GameInfoTypes.BELIEF_ORTHODOX_CHURCH) then
            local numOfTargetCity = Game.GetNumCitiesFollowing(eReligion)
            if numOfTargetCity > 0 then
                local religionCultureBonus = (pPlayer:GetCurrentEra() + 1) * 10 * numOfTargetCity
                pPlayer:ChangeJONSCulture(religionCultureBonus)
                if pPlayer:IsHuman() then
                    local hex = ToHexFromGrid(Vector2(iPlotX,iPlotY))
                    Events.AddPopupTextEvent(HexToWorld(hex), Locale.ConvertTextKey("+{1_Num}[ICON_CULTURE]",religionCultureBonus))
                    Events.GameplayFX(hex.x, hex.y, -1)
                end
            end
        end
	end
end
GameEvents.UnitCreated.Add(SPNReligionUnitCreatedOutputBonus)

function SPNReligionPolicyAdopt(iPlayer,iPolicy)
	if iPlayer == -1 or not Players[iPlayer]:HasCreatedReligion() then
		return
	end
    local pPlayer = Players[iPlayer]
	if not pPlayer:IsMajorCiv() then
        return
    end

    if iPolicy == policyCollectionRuleID then
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
	if iPlayer == -1 or not Players[iPlayer]:HasCreatedReligion() then
		return
	end
    local pPlayer = Players[iPlayer]
	if not pPlayer:IsMajorCiv() then
        return
    end
	if (iPolicyBranch == GameInfoTypes["POLICY_BRANCH_LIBERTY"]
	or iPolicyBranch == GameInfoTypes["POLICY_BRANCH_TRADITION"])
    and isBlock
	then
        local eReligion = pPlayer:GetReligionCreatedByPlayer()
        local pHolyCity = Game.GetHolyCityForReligion(eReligion, iPlayer)
        if pHolyCity:IsHasBuilding(GameInfoTypes.BUILDING_BELIEF_RELIGIOUS_COLONIZATION_2) then
            print("Player has BELIEF_RELIGIOUS_COLONIZATION, and change base Policy Branch 1")
            pHolyCity:SetNumRealBuilding(GameInfoTypes.BUILDING_BELIEF_RELIGIOUS_COLONIZATION_2,0)
            pHolyCity:SetNumRealBuilding(GameInfoTypes.BUILDING_BELIEF_RELIGIOUS_COLONIZATION,1)
        elseif pHolyCity:IsHasBuilding(GameInfoTypes.BUILDING_BELIEF_RELIGIOUS_COLONIZATION) 
        and pPlayer:HasPolicy(policyCollectionRuleID) 
        and not pPlayer:IsPolicyBlocked(policyCollectionRuleID)
        then
            print("Player has BELIEF_RELIGIOUS_COLONIZATION, and change base Policy Branch 2")
            pHolyCity:SetNumRealBuilding(GameInfoTypes.BUILDING_BELIEF_RELIGIOUS_COLONIZATION,0)
            pHolyCity:SetNumRealBuilding(GameInfoTypes.BUILDING_BELIEF_RELIGIOUS_COLONIZATION_2,1)
        end
	end
end
GameEvents.PlayerBlockPolicyBranch.Add(SPNReligionBlockPolicyBranch)

function SPNReligionMinorCivQuestBonus(iMajor, iMinor, iQuestType, iStartTurn, iOldInfluence, iNewInfluence) 
    if iMajor == -1 or not Players[iMajor]:HasCreatedReligion() then
		return
	end
	local pPlayer = Players[iMajor]
	local civPlayer = Players[iMinor]
	if pPlayer == nil or civPlayer == nil or pPlayer:IsMinorCiv() or pPlayer:IsBarbarian() then
	 	return
	end
	if pPlayer:HasBelief(GameInfoTypes["BELIEF_RELIGIOUS_UNITY"])
    and civPlayer:HasReligionInMostCities(pPlayer:GetReligionCreatedByPlayer())
    then
		local bonus =math.floor((iNewInfluence - iOldInfluence) / 100 * 0.5)
        civPlayer:ChangeMinorCivFriendshipWithMajor(iMajor,bonus) 
        if pPlayer:IsHuman() then
            local heading = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_RELIGION_CIVQUEST_BONUS_SHORT")
            local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_RELIGION_CIVQUEST_BONUS",civPlayer:GetName(),bonus)
            pPlayer:AddNotification(NotificationTypes.NOTIFICATION_MINOR_QUEST, text, heading, civPlayer:GetCapitalCity():GetX(),civPlayer:GetCapitalCity():GetY())
        end
		print("MajorCiv has BELIEF_RELIGIOUS_UNITY and completed MinorCiv quest:",bonus)
	end
end
GameEvents.PlayerCompletedQuest.Add(SPNReligionMinorCivQuestBonus) 

print('New Religion Rule: Check Pass')