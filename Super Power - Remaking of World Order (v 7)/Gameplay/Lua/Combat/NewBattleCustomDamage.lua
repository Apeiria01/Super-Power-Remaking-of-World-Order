local policyNewOrder = GameInfo.Policies["POLICY_NEW_ORDER"].ID;
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
	end
	return additionalDamage
end
--GameEvents.BattleCustomDamage.Add(SPEBattleCustomDamage)

print("NewBattleCustomDamage Check Pass ");