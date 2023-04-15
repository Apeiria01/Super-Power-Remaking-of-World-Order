function SPEBattleCustomDamage(iBattleUnitType, iBattleType,
	iAttackPlayerID, iAttackUnitOrCityID, bAttackIsCity, iAttackDamage,
	iDefensePlayerID, iDefenseUnitOrCityID, bDefenseIsCity, iDefenseDamage,
	iInterceptorPlayerID, iInterceptorUnitOrCityID, bInterceptorIsCity, iInterceptorDamage)

	local additionalDamage = 0;

	local attPlayer = Players[iAttackPlayerID]
	local defPlayer = Players[iDefensePlayerID]
	if attPlayer == nil or defPlayer == nil then
		return 0
	end

	if iBattleUnitType == GameInfoTypes["BATTLEROLE_ATTACKER"] then
		if bAttackIsCity then
			return 0
		end

		local attUnit = attPlayer:GetUnitByID(iAttackUnitOrCityID)
		if attUnit == nil then
			return 0
		end

		local attUnitCombatType = attUnit:GetUnitCombatType() 

		if attPlayer:HasPolicy(GameInfo.Policies["POLICY_HORSEMAN_TRAINING"].ID) 
		and ((attUnitCombatType == GameInfoTypes.UNITCOMBAT_MOUNTED) or (attUnitCombatType == GameInfoTypes.UNITCOMBAT_ARMOR))
		then
			additionalDamage = additionalDamage + 5
		end

		if attPlayer:HasPolicy(GameInfo.Policies["POLICY_MILITARY_CASTE"].ID) then
			if ( (attUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_ARCHERY_COMBAT"].ID) ) 
			or ( (attUnitCombatType == GameInfoTypes.UNITCOMBAT_HELICOPTER) ) )
			then
				additionalDamage = additionalDamage + 5
			end

			if bDefenseIsCity then
				local defCity = defPlayer:GetCityByID(iDefenseUnitOrCityID) 
				if defCity == nil then return 0 end

				if attUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_CITY_SIEGE"].ID) 
				or attUnit:GetDomainType() == DomainTypes.DOMAIN_AIR then
					additionalDamage = additionalDamage + defCity:GetMaxHitPoints() * 0.1
				end
			end
		end
	end
	return additionalDamage
end
GameEvents.BattleCustomDamage.Add(SPEBattleCustomDamage)

print("NewBattleCustomDamage Check Pass ");