-- New Combat Rules


--include( "UtilityFunctions.lua" )
include("FLuaVector.lua");
--******************************************************************************* Unit Combat Rules *******************************************************************************
local g_DoNewAttackEffect = nil;
local NewAttackOff = GameInfo.SPNewEffectControler.SP_NEWATTACK_OFF.Enabled
local SplashAndCollateralOff = PreGame.GetGameOption("GAMEOPTION_SP_SPLASH_AND_COLLATERAL_OFF")
function NewAttackEffectStarted(iType, iPlotX, iPlotY)
	if NewAttackOff then
		print("SP Attack Effect - OFF!");
		return;
	end

	if iType == GameInfoTypes["BATTLETYPE_MELEE"]
		or iType == GameInfoTypes["BATTLETYPE_RANGED"]
		or iType == GameInfoTypes["BATTLETYPE_AIR"]
		or iType == GameInfoTypes["BATTLETYPE_SWEEP"]
	then
		g_DoNewAttackEffect = {
			attPlayerID = -1,
			attUnitID   = -1,
			defPlayerID = -1,
			defUnitID   = -1,
			attODamage  = 0,
			defODamage  = 0,
			PlotX       = iPlotX,
			PlotY       = iPlotY,
			bIsCity     = false,
			defCityID   = -1,
			battleType  = iType,
		};
	end
end

GameEvents.BattleStarted.Add(NewAttackEffectStarted);
tCaptureSPUnits = {};
function NewAttackEffectJoined(iPlayer, iUnitOrCity, iRole, bIsCity)
	if g_DoNewAttackEffect == nil
		or Players[iPlayer] == nil or not Players[iPlayer]:IsAlive()
		or (not bIsCity and Players[iPlayer]:GetUnitByID(iUnitOrCity) == nil)
		or (bIsCity and (Players[iPlayer]:GetCityByID(iUnitOrCity) == nil or iRole == GameInfoTypes["BATTLEROLE_ATTACKER"]))
		or iRole == GameInfoTypes["BATTLEROLE_BYSTANDER"]
	then
		return;
	end
	if bIsCity then
		g_DoNewAttackEffect.defPlayerID = iPlayer;
		g_DoNewAttackEffect.defCityID = iUnitOrCity;
		g_DoNewAttackEffect.bIsCity = bIsCity;
	elseif iRole == GameInfoTypes["BATTLEROLE_ATTACKER"] then
		g_DoNewAttackEffect.attPlayerID = iPlayer;
		g_DoNewAttackEffect.attUnitID = iUnitOrCity;
		g_DoNewAttackEffect.attODamage = Players[iPlayer]:GetUnitByID(iUnitOrCity):GetDamage();
	elseif iRole == GameInfoTypes["BATTLEROLE_DEFENDER"] or iRole == GameInfoTypes["BATTLEROLE_INTERCEPTOR"] then
		g_DoNewAttackEffect.defPlayerID = iPlayer;
		g_DoNewAttackEffect.defUnitID = iUnitOrCity;
		g_DoNewAttackEffect.defODamage = Players[iPlayer]:GetUnitByID(iUnitOrCity):GetDamage();
	end

	-- Prepare for Capture Unit!
	if not bIsCity and g_DoNewAttackEffect.battleType == GameInfoTypes["BATTLETYPE_MELEE"]
		and Players[g_DoNewAttackEffect.attPlayerID] ~= nil and
		Players[g_DoNewAttackEffect.attPlayerID]:GetUnitByID(g_DoNewAttackEffect.attUnitID) ~= nil
		and Players[g_DoNewAttackEffect.defPlayerID] ~= nil and
		Players[g_DoNewAttackEffect.defPlayerID]:GetUnitByID(g_DoNewAttackEffect.defUnitID) ~= nil
	then
		local attPlayer = Players[g_DoNewAttackEffect.attPlayerID];
		local attUnit   = attPlayer:GetUnitByID(g_DoNewAttackEffect.attUnitID);
		local defPlayer = Players[g_DoNewAttackEffect.defPlayerID];
		local defUnit   = defPlayer:GetUnitByID(g_DoNewAttackEffect.defUnitID);

		if attUnit:GetCaptureChance(defUnit) > 0 then
			local unitClassType = defUnit:GetUnitClassType();
			local unitPlot = defUnit:GetPlot();
			local unitOriginalOwner = defUnit:GetOriginalOwner();

			local sCaptUnitName = nil;
			if defUnit:HasName() then
				sCaptUnitName = defUnit:GetNameNoDesc();
			end

			local unitLevel = defUnit:GetLevel();
			local unitEXP   = attUnit:GetExperience();
			local attMoves  = attUnit:GetMoves();
			print("attacking Unit remains moves:" .. attMoves);

			tCaptureSPUnits = { unitClassType, unitPlot, g_DoNewAttackEffect.attPlayerID, unitOriginalOwner, sCaptUnitName,
				unitLevel, unitEXP, attMoves };
		end
	end
end

GameEvents.BattleJoined.Add(NewAttackEffectJoined);
function NewAttackEffect()
	--Defines and status checks
	if g_DoNewAttackEffect == nil or Players[g_DoNewAttackEffect.defPlayerID] == nil
		or Players[g_DoNewAttackEffect.attPlayerID] == nil or not Players[g_DoNewAttackEffect.attPlayerID]:IsAlive()
		or Players[g_DoNewAttackEffect.attPlayerID]:GetUnitByID(g_DoNewAttackEffect.attUnitID) == nil
		-- or Players[ g_DoNewAttackEffect.attPlayerID ]:GetUnitByID(g_DoNewAttackEffect.attUnitID):IsDead()
		or Map.GetPlot(g_DoNewAttackEffect.PlotX, g_DoNewAttackEffect.PlotY) == nil
	then
		return;
	end

	local attPlayerID = g_DoNewAttackEffect.attPlayerID;
	local attPlayer = Players[attPlayerID];
	local defPlayerID = g_DoNewAttackEffect.defPlayerID;
	local defPlayer = Players[defPlayerID];

	local attUnit = attPlayer:GetUnitByID(g_DoNewAttackEffect.attUnitID);
	local attPlot = attUnit:GetPlot();

	local plotX = g_DoNewAttackEffect.PlotX;
	local plotY = g_DoNewAttackEffect.PlotY;
	local batPlot = Map.GetPlot(plotX, plotY);
	local batType = g_DoNewAttackEffect.battleType;

	local bIsCity = g_DoNewAttackEffect.bIsCity;
	local defUnit = nil;
	local defPlot = nil;
	local defCity = nil;

	local attFinalUnitDamage = attUnit:GetDamage();
	local defFinalUnitDamage = 0;
	local attUnitDamage = attFinalUnitDamage - g_DoNewAttackEffect.attODamage;
	local defUnitDamage = 0;

	if not bIsCity and defPlayer:GetUnitByID(g_DoNewAttackEffect.defUnitID) then
		defUnit = defPlayer:GetUnitByID(g_DoNewAttackEffect.defUnitID);
		defPlot = defUnit:GetPlot();
		defFinalUnitDamage = defUnit:GetDamage();
		defUnitDamage = defFinalUnitDamage - g_DoNewAttackEffect.defODamage;
	elseif bIsCity and defPlayer:GetCityByID(g_DoNewAttackEffect.defCityID) then
		defCity = defPlayer:GetCityByID(g_DoNewAttackEffect.defCityID);
	end

	g_DoNewAttackEffect = nil;

	--Complex Effects Only for Human VS AI(reduce time and enhance stability)
	if not attPlayer:IsHuman() and not defPlayer:IsHuman() then
		--[[
		--Larger AI's Bonus against Smaller AIs - AI is easier to become a Boss! Player will feel excited fighting Boss!
		--AI will capture another AI's city by ranged attack
		-- AI boss's City cann't be Captured by AI Ranged Unit!
		if not AICanBeBoss(defPlayer) and defCity then
			print ("AI attacking AI's City!")
			if defCity:GetDamage() >= defCity:GetMaxHitPoints() - 1 then
				local cityPop = defCity:GetPopulation()
				if cityPop < 10 or AICanBeBoss(attPlayer) then
					-- attPlayer:AcquireCity(defCity)
					print ("AI Ranged Unit Takes another AI's city!")
				end
			end
		end
		]]
		return;
	end
	-- Not for Barbarins
	if attPlayer:IsBarbarian() then
		return;
	end

	------- PromotionID
	local ArcheryUnitID = GameInfo.UnitPromotions["PROMOTION_ARCHERY_COMBAT"].ID
	local GunpowderInfantryUnitID = GameInfo.UnitPromotions["PROMOTION_GUNPOWDER_INFANTRY_COMBAT"].ID
	local NavalRangedShipUnitID = GameInfo.UnitPromotions["PROMOTION_NAVAL_RANGED_SHIP"].ID
	local NavalRangedCruiserUnitID = GameInfo.UnitPromotions["PROMOTION_NAVAL_RANGED_CRUISER"].ID
	local StragegicBomberUnitID = GameInfo.UnitPromotions["PROMOTION_STRATEGIC_BOMBER"].ID
	local CitySiegeUnitID = GameInfo.UnitPromotions["PROMOTION_CITY_SIEGE"].ID
	local InfantryUnitID = GameInfo.UnitPromotions["PROMOTION_INFANTRY_COMBAT"].ID
	local KnightID = GameInfo.UnitPromotions["PROMOTION_KNIGHT_COMBAT"].ID
	local TankID = GameInfo.UnitPromotions["PROMOTION_TANK_COMBAT"].ID
	local PillageFreeID = GameInfo.UnitPromotions["PROMOTION_CITY_PILLAGE_FREE"].ID
	local SpeComID = GameInfo.UnitPromotions["PROMOTION_SPECIAL_FORCES_COMBAT"].ID
	local SPForce2ID = GameInfo.UnitPromotions["PROMOTION_SP_FORCE_2"].ID

	local Charge1ID = GameInfo.UnitPromotions["PROMOTION_CHARGE_1"].ID
	local Charge2ID = GameInfo.UnitPromotions["PROMOTION_CHARGE_2"].ID
	local Charge3ID = GameInfo.UnitPromotions["PROMOTION_CHARGE_3"].ID

	local Sunder1ID = GameInfo.UnitPromotions["PROMOTION_SUNDER_1"].ID

	local CQBCombat1ID = GameInfo.UnitPromotions["PROMOTION_CQB_COMBAT_1"].ID
	local CQBCombat2ID = GameInfo.UnitPromotions["PROMOTION_CQB_COMBAT_2"].ID

	local KillingEffectsID = GameInfo.UnitPromotions["PROMOTION_GAIN_MOVES_AFFER_KILLING"].ID

	local SPForce1ID = GameInfo.UnitPromotions["PROMOTION_SP_FORCE_1"].ID

	local EMPBomberID = GameInfo.UnitPromotions["PROMOTION_EMP_ATTACK"].ID
	local AntiEMPID = GameInfo.UnitPromotions["PROMOTION_ANTI_EMP"].ID

	local AirTarget1ID = GameInfo.UnitPromotions["PROMOTION_AIR_TARGETING_1"].ID
	local AirTarget2ID = GameInfo.UnitPromotions["PROMOTION_AIR_TARGETING_2"].ID
	local AirTarget3ID = GameInfo.UnitPromotions["PROMOTION_AIR_TARGETING_3"].ID

	local AirTarget_CarrierID = GameInfo.UnitPromotions["PROMOTION_CARRIER_FIGHTER_SIEGE_2"].ID

	local DestroySupply_CarrierID = GameInfo.UnitPromotions["PROMOTION_CARRIER_FIGHTER_SIEGE_1"].ID
	local DestroySupply1ID = GameInfo.UnitPromotions["PROMOTION_DESTROY_SUPPLY_1"].ID
	local DestroySupply2ID = GameInfo.UnitPromotions["PROMOTION_DESTROY_SUPPLY_2"].ID
	local LoseSupplyID = GameInfo.UnitPromotions["PROMOTION_LOSE_SUPPLY"].ID
	local Damage1ID = GameInfo.UnitPromotions["PROMOTION_DAMAGE_1"].ID
	local Damage2ID = GameInfo.UnitPromotions["PROMOTION_DAMAGE_2"].ID

	local ChainReactionID = GameInfo.UnitPromotions["PROMOTION_CHAIN_REACTION"].ID

	local AntiDebuffID = GameInfo.UnitPromotions["PROMOTION_ANTI_DEBUFF"].ID

	local MamlukCombatID = GameInfo.UnitPromotions["PROMOTION_SPN_MAMLUK_COMBAT_FAITH"].ID

	-------Nuclear Rocket Launcher Kills itself (<suicide>is not working!)
	if attUnit:GetUnitType() == GameInfoTypes.UNIT_BAZOOKA then
		attUnit:ChangeDamage(attUnit:GetCurrHitPoints());
	end


	-- Carrier-based aircrafts give EXP to carrier
	if not attUnit:IsDead() and attUnit:IsCargo() and batType == GameInfoTypes["BATTLETYPE_AIR"]
		and attUnit:GetSpecialUnitType() ~= GameInfo.SpecialUnits.SPECIALUNIT_STEALTH.ID
	then
		print("Found a carrier-based aircraft!")
		local AircraftEXP = attUnit:GetExperience()
		if AircraftEXP > 0 then
			print("Gained EXP:" .. AircraftEXP);
			local CarrierUnit = attUnit:GetTransportUnit()
			print("Found its carrier!")
			CarrierUnit:ChangeExperience(AircraftEXP)
			attUnit:SetExperience(0)
		end
	end


	-- Heavy Knight&Tank attacking cities lose all MPs
	if bIsCity and not attUnit:IsDead() and batType == GameInfoTypes["BATTLETYPE_MELEE"]
		and not attUnit:IsHasPromotion(PillageFreeID) and not attUnit:IsHasPromotion(AntiDebuffID)
		and (attUnit:IsHasPromotion(KnightID) or attUnit:IsHasPromotion(TankID))
	then
		attUnit:SetMoves(0)
		print("Attacking City and lost all MPs!")
		if attPlayer:IsHuman() then
			Events.GameplayAlertMessage(Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_ATTACKING_CITY_LOST_MOVEMENT",
				attUnit:GetName()))
		end
	end


	if not defPlayer:IsAlive() then
		return
	end

	--Mamluk gain Faith from Combat
	if not defCity and attUnit:IsHasPromotion(MamlukCombatID) then
		local MamlukDamageBonus = 0
		if defUnit then
			MamlukDamageBonus = defUnitDamage
		end
		print("Mamluk Attack Damage is :",MamlukDamageBonus)
		attPlayer:ChangeFaith(MamlukDamageBonus)
		if attPlayer:IsHuman() and MamlukDamageBonus >0 then
			local hex = ToHexFromGrid(Vector2(plotX,plotY))
			Events.AddPopupTextEvent(HexToWorld(hex), Locale.ConvertTextKey("+{1_Num}[ICON_PEACE]",MamlukDamageBonus))
			Events.GameplayFX(hex.x, hex.y, -1)
		end
	end
		

	----------------EMP Bomber effects
	if attUnit:IsHasPromotion(EMPBomberID) then
		local pTeam = Teams[defPlayer:GetTeam()]
		if not pTeam:IsHasTech(GameInfoTypes["TECH_COMPUTERS"]) then
			print("No Tech - Computer!");
		else
			if defCity then
				defCity:ChangeResistanceTurns(1);
				print("EMP City!");
			end
			local unitCount = batPlot:GetNumUnits();
			if unitCount > 0 then
				for i = 0, unitCount - 1, 1 do
					local pFoundUnit = batPlot:GetUnit(i)
					if pFoundUnit and not pFoundUnit:IsHasPromotion(AntiEMPID) then
						pFoundUnit:SetMoves(0);
						print("EMP same tile Unit!");
					end
				end
				for i = 0, 5 do
					local adjPlot = Map.PlotDirection(plotX, plotY, i);
					if (adjPlot ~= nil) then
						if adjPlot:IsCity() then
							adjPlot:GetPlotCity():ChangeResistanceTurns(1);
							print("EMP around City!");
						end
						unitCount = adjPlot:GetNumUnits();
						if unitCount > 0 then
							for i = 0, unitCount - 1, 1 do
								local pFoundUnit = adjPlot:GetUnit(i);
								if pFoundUnit and not pFoundUnit:IsHasPromotion(AntiEMPID) then
									pFoundUnit:SetMoves(0);
									print("EMP around Unit!");
								end
							end
						end
					end
				end
			end

			-- Notification
			if defPlayer:IsHuman() then
				local heading = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_UNIT_US_EMP_SHORT")
				local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_UNIT_US_EMP")
				defPlayer:AddNotification(NotificationTypes.NOTIFICATION_GENERIC, text, heading, plotX, plotY)
			elseif attPlayer:IsHuman() then
				local heading = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_UNIT_ENEMY_EMP_SHORT")
				local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_UNIT_ENEMY_EMP")
				attPlayer:AddNotification(NotificationTypes.NOTIFICATION_GENERIC, text, heading, plotX, plotY)
			end
		end
	end


	------------------------- Chain Reaction
	if attUnit:IsHasPromotion(ChainReactionID) then
		for unit in defPlayer:Units() do
			local plot = unit:GetPlot()
			if unit and unit ~= defUnit and not unit:IsHasPromotion(AntiDebuffID) and not unit:IsTrade()
				and plot and PlotIsVisibleToHuman(plot)
			then
				local DamageOri = attUnit:GetRangeCombatDamage(unit, nil, false);
				local ChainDamage = 0.33 * DamageOri;
				if ChainDamage >= unit:GetCurrHitPoints() then
					ChainDamage = unit:GetCurrHitPoints();
					local eUnitType = unit:GetUnitType();
				end
				unit:ChangeDamage(ChainDamage, attPlayer);
				print("Chain Reaction!");
			end
		end
	end



	-------------- attacking Cities
	if defCity then
		-- Special Forces sabotage city
		if not attUnit:IsDead() and attUnit:IsHasPromotion(SPForce2ID) then
			print("Special Forces attacking City!")
			if not (attPlayer:HasPolicy(GameInfo.Policies['POLICY_FUTURISM']) and defCity:IsOriginalCapital()) then ---Avoid 0 culture when sabotage a capital city--by HMS
				defCity:ChangeResistanceTurns(1)
			end
			local unitCount = batPlot:GetNumUnits()
			if defCity:GetDamage() < defCity:GetMaxHitPoints() and unitCount > 0 then
				print("Units in the city!")
				for i = 0, unitCount - 1, 1 do
					local pFoundUnit = batPlot:GetUnit(i)
					if pFoundUnit and not pFoundUnit:IsHasPromotion(SpeComID) then
						pFoundUnit:SetMoves(0)
						print("Units in the city are Sabotaged!")
						if attPlayer:IsHuman() then
							Events.GameplayAlertMessage(Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_SPFORCE_CITY_SABOTAGE",
								pFoundUnit:GetName()))
						end
					end
				end
			end



		end

		------- Fix Strong Unit cannot capture city Bug(damage overflow)
		if not attUnit:IsDead() and
			(
			attUnit:GetUnitCombatType() == GameInfoTypes.UNITCOMBAT_NAVALMELEE or
				attUnit:GetUnitCombatType() == GameInfoTypes.UNITCOMBAT_ARMOR or attUnit:IsHasPromotion(GunpowderInfantryUnitID)
				or attUnit:IsHasPromotion(NavalRangedShipUnitID) or attUnit:IsHasPromotion(NavalRangedCruiserUnitID))
			and attUnit:GetBaseCombatStrength() >= 100
		then
			print("Strong Unit is attacking the city!")
			local IsAdjacentToDefendingCity = false
			for i = 0, 5 do
				local adjPlot = Map.PlotDirection(plotX, plotY, i)
				if adjPlot:GetX() == attUnit:GetX() and adjPlot:GetY() == attUnit:GetY() then
					IsAdjacentToDefendingCity = true
					print("Unit is adjacent to the city!")
				end
			end
			if attUnit:GetBaseCombatStrength() / (defCity:GetStrengthValue() / 100) >= 11 and defCity:GetPopulation() < 15 and
				IsAdjacentToDefendingCity then
				local TempUnit = attPlayer:InitUnit(GameInfoTypes.UNIT_ROMAN_LEGION, plotX, plotY, UNITAI_ATTACK)
				TempUnit:Kill()
				attUnit:SetXY(plotX, plotY)
				--			attUnit:AcquireCity(defCity)
				print("Strong Unit Takes the city!")
			end
		end


		------- Fix Stealth Unit cannot capture city Bug
		if not attUnit:IsDead() and batType == GameInfoTypes["BATTLETYPE_MELEE"]
			and attPlot == batPlot and defCity:GetDamage() >= defCity:GetMaxHitPoints()
		then
			local TempUnit = attPlayer:InitUnit(GameInfoTypes.UNIT_ROMAN_LEGION, plotX, plotY, UNITAI_ATTACK)
			TempUnit:Kill()
			attUnit:SetXY(plotX, plotY)
			--		attPlayer:AcquireCity(defCity)
			print("Special Forces Takes the city!")
		end





		-------------- Ranged Attack Kill Popluation of Heavily Damaged City
		if batType == GameInfoTypes["BATTLETYPE_RANGED"] or batType == GameInfoTypes["BATTLETYPE_AIR"] then
			--		print ("Ranged Unit attacked City!")
			if (defCity:GetDamage() >= defCity:GetMaxHitPoints() - 1) then
				local cityPop = defCity:GetPopulation()
				if (cityPop > 1) then
					local NewCityPop = cityPop - 1
					defCity:SetPopulation(NewCityPop, true) ----Set Real Population
					local CityOwner = defCity:GetOwner()

					if Players[CityOwner]:IsHuman() then
						local pPlayer = Players[CityOwner]
						local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_CITY_POPULATION_LOST_BY_RANGEDFIRE", attUnit:GetName()
							, defCity:GetName())
						local heading = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_CITY_POPULATION_LOST_BY_RANGEDFIRE_SHORT")
						pPlayer:AddNotification(NotificationTypes.NOTIFICATION_STARVING, text, heading, plotX, plotY)
					end


				end
			end
		end

		------------------------Attack Aircraft attack units inside the city
		if (attUnit:IsHasPromotion(AirTarget1ID) or attUnit:IsHasPromotion(AirTarget_CarrierID))
			and not attUnit:IsHasPromotion(StragegicBomberUnitID) and batPlot:IsUnit()
		then
			print("Attak AirCraft attacking City!")
			local unitCount = batPlot:GetNumUnits()
			if unitCount > 0 then
				print("Units in the city!")
				for i = 0, unitCount - 1, 1 do
					local pFoundUnit = batPlot:GetUnit(i)
					if (pFoundUnit ~= nil) then
						local iChangeDamage = 20;
						print("Units in the city are attacked!")
						if attUnit:IsHasPromotion(AirTarget2ID) then
							iChangeDamage = iChangeDamage + 20;
						end
						if attUnit:IsHasPromotion(AirTarget3ID) then
							iChangeDamage = iChangeDamage + 20;
						end
						if iChangeDamage >= pFoundUnit:GetCurrHitPoints() then
							iChangeDamage = pFoundUnit:GetCurrHitPoints();
							local eUnitType = pFoundUnit:GetUnitType();
						end
						pFoundUnit:ChangeDamage(iChangeDamage);
					end
				end
			end
		end



		-- Attacking a Unit!
	elseif defUnit then
		-- Charge Damage
		if not attUnit:IsDead() and (attUnit:IsHasPromotion(KnightID) or attUnit:IsHasPromotion(TankID))
			and not defUnit:IsDead() and batPlot ~= defPlot and defUnitDamage > 0 and
			batType == GameInfoTypes["BATTLETYPE_MELEE"
			]
		then
			-- print("Available for Charge Damage!");
			local defFinalUnitDamageChange = 0;
			local ChargeMod = 0.5; -- The percentage of charging damage to the other unit
			if attUnit:IsHasPromotion(Charge1ID) then
				if attUnit:IsHasPromotion(Charge2ID) then
					defFinalUnitDamageChange = 10;
					ChargeMod = 1.0;
				end
				if attUnit:IsHasPromotion(Charge3ID) then
					defFinalUnitDamageChange = 20;
					ChargeMod = 1.5;
				end
			end

			local unitCount = batPlot:GetNumUnits();
			if unitCount >= 1 and batPlot ~= attPlot then
				print("Our damage done=" .. defUnitDamage);
				for i = 0, unitCount - 1, 1 do
					local pFoundUnit = batPlot:GetUnit(i)
					if pFoundUnit ~= nil and pFoundUnit:GetID() ~= defUnit:GetID() then
						local pPlayer = Players[pFoundUnit:GetOwner()];
						if PlayersAtWar(attPlayer, pPlayer) then
							local attUnitStrength = attUnit:GetMaxAttackStrength(attPlot, defPlot, defUnit);
							print("attUnitStrength:" .. attUnitStrength);
							local pFoundUnitStrength = pFoundUnit:GetMaxDefenseStrength(batPlot, attUnit);
							print("pFoundUnitStrength:" .. pFoundUnitStrength);
							local ChargeDamageOri = attUnit:GetCombatDamage(attUnitStrength, pFoundUnitStrength, attFinalUnitDamage, false,
								false, false);
							print("ChargeDamageOri:" .. ChargeDamageOri); --we now consider the buff and debuff when caculating the charge damage.---by WM
							-- local ChargeDamageOri = attUnit:GetCombatDamage(attUnitStrength, pUnitStrength, attUnit:GetDamage(),false,false, false)

							local text = nil;
							local attUnitName = attUnit:GetName();
							local defUnitName = pFoundUnit:GetName();

							print("ChargeMod:" .. ChargeMod)
							local ChargeDamageFinal = math.floor(ChargeDamageOri * ChargeMod);
							if ChargeDamageFinal >= pFoundUnit:GetCurrHitPoints() then
								local eUnitType = pFoundUnit:GetUnitType();

								-- Notification
								if defPlayerID == Game.GetActivePlayer() then
									-- local heading = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_UNIT_DESTROYED_SHORT")
									text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_CHARGE_DAMAGE_DEATH", attUnitName, defUnitName);
									-- defPlayer:AddNotification(NotificationTypes.NOTIFICATION_GENERIC , text, heading, plotX, plotY)
								elseif attPlayerID == Game.GetActivePlayer() then
									text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_CHARGE_DAMAGE_ENEMY_DEATH", attUnitName, defUnitName);
								end
								pFoundUnit:Kill();
							elseif ChargeDamageFinal > 0 then
								-- Notification
								if defPlayerID == Game.GetActivePlayer() then
									text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_CHARGE_DAMAGE", attUnitName, defUnitName,
										ChargeDamageFinal);
								elseif attPlayerID == Game.GetActivePlayer() then
									text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_CHARGE_DAMAGE_ENEMY", attUnitName, defUnitName,
										ChargeDamageFinal);
								end
								pFoundUnit:ChangeDamage(ChargeDamageFinal, attPlayer)
								print("Charge Damage=" .. ChargeDamageFinal)
							end
							if text then
								Events.GameplayAlertMessage(text);
							end
						end
					end
				end
			else
				print("our unit is in this plot or this plot has no other enemy - don't need to charge!")
			end
			local text = nil;
			local attUnitName = attUnit:GetName();
			local defUnitName = defUnit:GetName();

			if defFinalUnitDamageChange >= defUnit:GetCurrHitPoints() then
				defFinalUnitDamageChange = defUnit:GetCurrHitPoints();
				local eUnitType = defUnit:GetUnitType();

				-- Notification
				if defPlayerID == Game.GetActivePlayer() then
					-- local heading = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_UNIT_DESTROYED_SHORT")
					text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_CHARGE_DAMAGE_DEATH", attUnitName, defUnitName);
					-- defPlayer:AddNotification(NotificationTypes.NOTIFICATION_GENERIC , text, heading, defUnit:GetX(), defUnit:GetY())
				elseif attPlayerID == Game.GetActivePlayer() then
					text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_CHARGE_DAMAGE_ENEMY_DEATH", attUnitName, defUnitName);
				end
			elseif defFinalUnitDamageChange > 0 then
				-- Notification
				if defPlayerID == Game.GetActivePlayer() then
					text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_CHARGE_DAMAGE", attUnitName, defUnitName,
						defFinalUnitDamageChange);
				elseif attPlayerID == Game.GetActivePlayer() then
					text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_CHARGE_DAMAGE_ENEMY", attUnitName, defUnitName,
						defFinalUnitDamageChange);
				end
			end
			if text then
				Events.GameplayAlertMessage(text);
			end
			defFinalUnitDamage = defFinalUnitDamage + defFinalUnitDamageChange;
			defUnit:ChangeDamage(defFinalUnitDamageChange,attPlayer);
			--[[if attUnit:CanMoveThrough(batPlot) and batPlot ~= attPlot then
				-- if the target plot has no unit,your unit advances into the target plot!
				attUnit:SetMoves(attUnit:MovesLeft() + GameDefines["MOVE_DENOMINATOR"]);
				attUnit:PushMission(MissionTypes.MISSION_MOVE_TO, plotX, plotY);
			end]]
		end


		----------- PROMOTION_GAIN_MOVES_AFFER_KILLING Effects
		if attUnit:IsHasPromotion(KillingEffectsID) then
			print("DefUnit Damage:" .. defFinalUnitDamage);
			if defFinalUnitDamage >= 100 then
				attUnit:SetMoves(attUnit:MovesLeft() + GameDefines["MOVE_DENOMINATOR"]);
				attUnit:SetMadeAttack(false);
				print("Ah, fresh meat!");
			end
		end

		-----------Gain extra Mp for heavyCharge
		if attUnit:IsHasPromotion(Charge1ID) and batPlot ~= defPlot then
			attUnit:SetMoves(attUnit:MovesLeft() + GameDefines["MOVE_DENOMINATOR"]);
			print("Charging Unit Gains Movement!")
		end


		-- 	    if attUnit:IsHasPromotion(SpecialForcesID) and defUnit:GetUnitCombatType() == GameInfoTypes.UNITCOMBAT_RECON then
		--  		if math.floor(defFinalUnitDamage/100)-math.floor(defUnitDamage/100) > 0  then
		--			attUnit:SetMoves(attUnit:MovesLeft()+GameDefines["MOVE_DENOMINATOR"])
		--			attUnit:SetMadeAttack(false)
		--			print ("Ah, fresh meat!")
		--		end
		-- 	    end


		-- Debuff immune unit
		if defUnit:IsHasPromotion(AntiDebuffID) then
			print("This unit is debuff immune")
			return
		end


		if not attUnit:IsDead() and not attUnit:IsHasPromotion(AntiDebuffID) and batType == GameInfoTypes["BATTLETYPE_MELEE"]
			and defUnit:GetDomainType() == attUnit:GetDomainType()
			and ((defUnit:IsHasPromotion(CQBCombat1ID) and attFinalUnitDamage < 20) or defUnit:IsHasPromotion(CQBCombat2ID))
			and not defUnit:IsHasPromotion(GunpowderInfantryUnitID) and not defUnit:IsHasPromotion(InfantryUnitID)
		then
			attUnit:SetMoves(0)
			Message = 3
			print("Attacker Stopped!")
		end


		----------------------Ranged Unit Counter Attack

		--	    if not attUnit:IsDead() and not defUnit:IsDead() then    ----------------------Ranged Unit Counter Attack
		--		if (attUnit:IsRanged() and defUnit:IsRanged() and not attUnit:GetPlot():IsCity()) then
		--			if attUnit:GetBaseRangedCombatStrength() > attUnit:GetBaseCombatStrength() and defUnit:GetBaseRangedCombatStrength() > defUnit:GetBaseCombatStrength()	then --Hit and Run units won't have this effect
		--				-- Initialize the attack-tracking if this is the first attack of the turn.
		--				   HasAttackedThisTurn = {}
		--				if HasAttackedThisTurn[defUnit] ~= true and HasAttackedThisTurn[attUnit] ~= true then
		--				   HasAttackedThisTurn[attUnit] = true
		--				end
		--
		--				if HasAttackedThisTurn[defUnit] ~= true then
		--					local movesLeft = defUnit:MovesLeft()
		--					print("Qualifies for a counterattack.")
		--					defUnit:RangeStrike( attUnit:GetX(), attUnit:GetY() )
		--					--The defender can defend itself for more than its attacks allowed every turn.
		--					defUnit:SetMadeAttack(false)
		--					defUnit:SetMoves(movesLeft)
		--					-- By this point, the attacker will already have been checked to make a counter-counter attack, so let's delete our table.
		--					HasAttackedThisTurn = nil
		--				else
		--					return
		--				end
		--			end
		--		end
		--	    end


		-----------Archery Unit Counter-attack the attacker attacking the Stacking units
		if batPlot:GetNumUnits() <= 1 then
		elseif (defUnit:IsImmobile() and defUnit:GetBaseCombatStrength() > 0)
			or defUnit:GetUnitCombatType() == GameInfoTypes.UNITCOMBAT_MELEE
		then
			local unitCount = batPlot:GetNumUnits();
			for i = 0, unitCount - 1, 1 do
				local pFoundUnit = batPlot:GetUnit(i);
				if pFoundUnit and not pFoundUnit:IsDead() and pFoundUnit ~= defUnit and pFoundUnit:IsRanged()
					and (pFoundUnit:IsHasPromotion(ArcheryUnitID) and batType == GameInfoTypes["BATTLETYPE_MELEE"])
				-- or (pFoundUnit:IsHasPromotion(FireSupport2ID) and batType == GameInfoTypes["BATTLETYPE_RANGED"]))
				then
					local movesLeft = pFoundUnit:MovesLeft();
					pFoundUnit:RangeStrike(attUnit:GetX(), attUnit:GetY());
					pFoundUnit:SetMadeAttack(false);
					pFoundUnit:SetMoves(movesLeft);
					break;
				end
			end
		elseif defUnit:IsRanged() and not defUnit:IsDead()
			and (defUnit:IsHasPromotion(ArcheryUnitID) and batType == GameInfoTypes["BATTLETYPE_MELEE"])
		-- or    (defUnit:IsHasPromotion(FireSupport2ID) and batType == GameInfoTypes["BATTLETYPE_RANGED"]) )
		then
			local unitCount = batPlot:GetNumUnits();
			for i = 0, unitCount - 1, 1 do
				local pFoundUnit = batPlot:GetUnit(i);
				if pFoundUnit and not pFoundUnit:IsDead()
					and ((pFoundUnit:IsImmobile() and pFoundUnit:GetBaseCombatStrength() > 0)
						or pFoundUnit:GetUnitCombatType() == GameInfoTypes.UNITCOMBAT_MELEE)
				then
					local movesLeft = defUnit:MovesLeft();
					defUnit:RangeStrike(attUnit:GetX(), attUnit:GetY());
					defUnit:SetMadeAttack(false);
					defUnit:SetMoves(movesLeft);
					break;
				end
			end
		end


		------LaserSuppression and CQB Combat Freeze the Attacker
		--	    if defUnit:IsHasPromotion(SuppressionID) and attUnit:GetDomainType() == DomainTypes.DOMAIN_LAND then
		--		if not attUnit:IsHasPromotion(CitySiegeUnitID) then
		--			attUnit:SetMoves(0)
		--			Message = 1
		--			print ("Attacker Stopped!")
		--		end
		--	    end



		-----------Attacking with debuffs
		if (
			attUnit:IsHasPromotion(Sunder1ID)
				or attUnit:IsHasPromotion(DestroySupply_CarrierID) or attUnit:IsHasPromotion(DestroySupply1ID) or
				attUnit:IsHasPromotion(SPForce1ID)
				or attUnit:IsHasPromotion(CitySiegeUnitID)) and not defUnit:IsDead()
		then

			-- if defFinalUnitDamage >= defUnit:GetMaxHitPoints() then
			-- print("Defender is dead, no debuff effects!")
			-- return
			-- end

			local text = nil;
			local attUnitName = attUnit:GetName();
			local defUnitName = defUnit:GetName();
			local MovesLeft = defUnit:MovesLeft();
			local Message = 0;
			local IsNotification = false;
			--		print("Moves Left:"..MovesLeft);

			local tdebuff = nil;
			local tlostHP = nil;
			local combatRoll = Game.Rand(10, "At NewCombatRules.lua NewAttackEffect()") + 1
			if (
				attUnit:IsHasPromotion(DestroySupply1ID) or attUnit:IsHasPromotion(SPForce1ID) or
					attUnit:IsHasPromotion(DestroySupply_CarrierID))
				and not defUnit:IsHasPromotion(LoseSupplyID)
			then
				defUnit:SetHasPromotion(LoseSupplyID, true)
				tdebuff = Locale.ConvertTextKey("TXT_KEY_PROMOTION_LOSE_SUPPLY");
				tlostHP = "[COLOR_NEGATIVE_TEXT]" .. -20 .. "[ENDCOLOR]";
				Message = 5
			elseif attUnit:IsHasPromotion(CitySiegeUnitID) and defUnit:IsCombatUnit() and
				defUnit:GetDomainType() == DomainTypes.DOMAIN_SEA and GameInfo.Units[defUnit:GetUnitType()].MoveRate == "WOODEN_BOAT" then
				if not defUnit:IsHasPromotion(Damage1ID) and combatRoll <= 5 then
					defUnit:SetHasPromotion(Damage1ID, true);
					tdebuff = Locale.ConvertTextKey("TXT_KEY_PROMOTION_DAMAGE_1");
					tlostHP = "[COLOR_NEGATIVE_TEXT]" .. -10 .. "[ENDCOLOR]";
					Message = 5;
				elseif defUnit:IsHasPromotion(Damage1ID) and not defUnit:IsHasPromotion(Damage2ID) and combatRoll <= 8 then
					defUnit:SetHasPromotion(Damage2ID, true);
					tdebuff = Locale.ConvertTextKey("TXT_KEY_PROMOTION_DAMAGE_2");
					tlostHP = "[COLOR_NEGATIVE_TEXT]" .. -20 .. "[ENDCOLOR]";
					Message = 5;
				end
			end

			-- Notification
			if Message ~= 5 then
			elseif attPlayer:IsHuman() then
				-- local heading = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_ENEMY_SUPPLY_DESTROYED_SHORT", tdebuff);
				text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_ENEMY_SUPPLY_DESTROYED", tdebuff, defUnitName, tlostHP);
				-- attPlayer:AddNotification(NotificationTypes.NOTIFICATION_GENERIC, text, heading, plotX, plotY);
				Events.GameplayAlertMessage(text);
			elseif defPlayer:IsHuman() then
				local heading = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_US_SUPPLY_DESTROYED_SHORT", tdebuff);
				text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_US_SUPPLY_DESTROYED", tdebuff, defUnitName, tlostHP);
				defPlayer:AddNotification(NotificationTypes.NOTIFICATION_GENERIC, text, heading, plotX, plotY);
			end
			text = nil;
			Message = 0;

			-- Notification
			if attPlayer:IsHuman() then
				if Message == 1 then
					text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_ENEMY_SUNDERED", attUnitName, defUnitName);
				elseif Message == 4 then
					text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_ENEMY_MORAL_WEAKEN", attUnitName, defUnitName);
				end
			elseif defPlayer:IsHuman() then
				if Message == 1 then
					text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_US_SUNDERED", attUnitName, defUnitName);
				elseif Message == 4 then
					text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_US_MORAL_WEAKEN", attUnitName, defUnitName);
				end
			end
			if text then
				Events.GameplayAlertMessage(text);
			end
		end


		-------Fighters will damage land and naval AA units in an air-sweep
		if not attUnit:IsDead() and not defUnit:IsDead() and defUnit:IsCombatUnit()
			and batType == GameInfoTypes["BATTLETYPE_SWEEP"]
		then
			print("Airsweep!")

			-- This AA unit is exempted from Air-sweep damage!

			-- local attUnitStrength = attUnit:GetBaseCombatStrength()
			-- local defUnitStrength = defUnit:GetBaseCombatStrength()

			print("Airsweep and the defender is an AA unit!")

			local attDamageInflicted = defUnit:GetRangeCombatDamage(defUnit, nil, false) * 0.5
			local defDamageInflicted = attUnit:GetRangeCombatDamage(defUnit, nil, false)

			------------Defender exempt/reduced from damage
			if defUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_ANTI_HELICOPTER"].ID) then
				defDamageInflicted = 0
				print("This AA unit is exempted from Air-sweep damage!")
			end
			if defUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_FLANK_GUN_1"].ID) then
				defDamageInflicted = 0.5 * defDamageInflicted
				print("This AA unit is reduced (-50%) from Air-sweep damage!")
			end

			------------In case of the AA unit is a melee unit
			if not defUnit:IsRanged() then
				attDamageInflicted = defDamageInflicted * 0.25;
			end

			---------------fix embarked unit bug
			if defUnit:IsEmbarked() then
				attDamageInflicted = 1;
				print("Air-sweep embarked unit!");
			end

			-- local defDamageInflicted = attUnit:GetCombatDamage(defUnitStrength, attUnitStrength, defUnit:GetDamage(),false,false, false)

			--------------Death Animation
			-- defUnit:PushMission(MissionTypes.MISSION_DIE_ANIMATION)
			-- attUnit:PushMission(MissionTypes.MISSION_DIE_ANIMATION)

			------------Notifications
			local text = nil;
			local attUnitName = attUnit:GetName();
			local defUnitName = defUnit:GetName();

			if attDamageInflicted >= attUnit:GetCurrHitPoints() then
				attDamageInflicted = attUnit:GetCurrHitPoints();
				local eUnitType = attUnit:GetUnitType();
				print("Airsweep Unit died!")

				if defPlayerID == Game.GetActivePlayer() then
					text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_AIRSWEEP_KILLED_ENEMY_FIGHTER", attUnitName, defUnitName);
				elseif attPlayerID == Game.GetActivePlayer() then
					text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_AIRSWEEP_KILLED_BY_ENEMY", attUnitName, defUnitName);
				end
			elseif attDamageInflicted > 0 then
				attDamageInflicted = math.floor(attDamageInflicted);
				attUnit:ChangeExperience(4)
				if attPlayerID == Game.GetActivePlayer() then
					text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_AIRSWEEP_TO_ENEMY", attUnitName, defUnitName,
						tostring(attDamageInflicted));
				end
			end

			if defDamageInflicted >= defUnit:GetCurrHitPoints() then
				defDamageInflicted = defUnit:GetCurrHitPoints();
				local eUnitType = defUnit:GetUnitType();
				print("AA Unit died!")

				if defPlayerID == Game.GetActivePlayer() then
					text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_AIRSWEEP_AA_KILLED_BY_ENEMY", attUnitName, defUnitName);
				elseif attPlayerID == Game.GetActivePlayer() then
					text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_AIRSWEEP_KILLED_ENEMY_AA", attUnitName, defUnitName);
				end
			elseif defDamageInflicted > 0 then
				defDamageInflicted = math.floor(defDamageInflicted);
				defUnit:ChangeExperience(2);
				if defPlayerID == Game.GetActivePlayer() then
					text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_AIRSWEEP_BY_ENEMY", attUnitName, defUnitName,
						tostring(attDamageInflicted));
				end
			end

			if text and (attPlayer:IsHuman() or defPlayer:IsHuman()) then
				Events.GameplayAlertMessage(text)
			end

			print("Air Sweep Damage Dealt: " .. attDamageInflicted);
			print("Air Sweep Damage Received: " .. defDamageInflicted);

			attUnit:ChangeDamage(attDamageInflicted, defPlayer);
			defUnit:ChangeDamage(defDamageInflicted, attPlayer);
		end


		--------------------------- Supply Damage AOE Effects
		if attUnit:IsHasPromotion(DestroySupply2ID) then
			defUnit:SetHasPromotion(LoseSupplyID, true)

			for i = 0, 5 do
				local adjPlot = Map.PlotDirection(plotX, plotY, i)
				if (adjPlot ~= nil) then
					local pUnit = adjPlot:GetUnit(0)
					if pUnit and pUnit:GetOwner() ~= attUnit:GetOwner() and not pUnit:IsHasPromotion(AntiDebuffID) then --not for immune unit---by HMS
						pUnit:SetHasPromotion(LoseSupplyID, true);
					end
				end
			end
		end
	end
end --function END

GameEvents.BattleFinished.Add(NewAttackEffect)


--*******************************************************************************Combat restrictions*******************************************************************************
-- MOD Begin - by CaptainCWB
-- Captured Unit Keeps the Name and remains some movements
-- Captured unit does not occupy normal unit's name
function OnCapturedUnitNoChangeName(iPlayer, iUnit, iName)
	if Players[iPlayer] == nil or Players[iPlayer]:GetUnitByID(iUnit) == nil
		or (tCaptureSPUnits and #tCaptureSPUnits > 0 and tCaptureSPUnits[5] ~= nil
			and Players[iPlayer]:GetUnitByID(iUnit):GetUnitClassType() == tCaptureSPUnits[1]
			and Players[iPlayer]:GetUnitByID(iUnit):GetPlot() == tCaptureSPUnits[2]
			and iPlayer == tCaptureSPUnits[3]
			and Players[iPlayer]:GetUnitByID(iUnit):GetOriginalOwner() == tCaptureSPUnits[4])
	then
		return false;
	else
		return true;
	end
end

GameEvents.UnitCanHaveName.Add(OnCapturedUnitNoChangeName)
-- Do Keeping Promotions & Name
function CaptureSPDKP(iPlayerID, iUnitID)
	local NewlyCapturedID = GameInfo.UnitPromotions["PROMOTION_NEWLYCAPTURED"].ID
	if Players[iPlayerID] == nil or Players[iPlayerID]:GetUnitByID(iUnitID) == nil
		or tCaptureSPUnits == nil or #tCaptureSPUnits == 0
	then
		return;
	end
	local pUnit = Players[iPlayerID]:GetUnitByID(iUnitID);

	if pUnit:GetUnitClassType() == tCaptureSPUnits[1]
		and pUnit:GetPlot() == tCaptureSPUnits[2] and iPlayerID == tCaptureSPUnits[3]
		and pUnit:GetOriginalOwner() == tCaptureSPUnits[4]
	then
		if tCaptureSPUnits[5] ~= nil then
			pUnit:SetName(tCaptureSPUnits[5]);
		end
		if pUnit:IsCombatUnit() then
			-- pUnit:SetLevel(tCaptureSPUnits[6]);
			pUnit:SetExperience(tCaptureSPUnits[7] / 4);
			pUnit:SetLevel(1);
			local pMoves = pUnit:MaxMoves();
			print("MaxMoves of captured unit is " .. pMoves);
			local qMoves = tCaptureSPUnits[8];
			local captureMoveRoll = Game.Rand(100, "At NewCombatRules.lua CaptureSPDKP(), roll for moves remain") + 1
			local rMoves = (pMoves * 0.2 + qMoves * 0.4) * (captureMoveRoll * 0.002 + 0.9);
			print("newly captured unit remains movements:" .. rMoves);
			pUnit:SetMoves(rMoves);
			pUnit:SetHasPromotion(NewlyCapturedID, true);
			local captureDamageRoll = Game.Rand(30, "At NewCombatRules.lua CaptureSPDKP(), roll for damage") + 1
			local pDamage = captureDamageRoll + 69 - qMoves / GameDefines["MOVE_DENOMINATOR"] * 4;
			print("newly captured unit remains hit points:" .. pDamage);
			pUnit:SetDamage(pDamage);
			tCaptureSPUnits = {};
		end
	end
end

Events.SerialEventUnitCreated.Add(CaptureSPDKP);
-- MOD End   - by CaptainCWB









--****************************************************************************Utilities*************************************************************************************************
---- Set Debuff Effects: Armor Damaged
function SetPenetration(defUnit)
	local Penetration1ID = GameInfo.UnitPromotions["PROMOTION_PENETRATION_1"].ID
	local Penetration2ID = GameInfo.UnitPromotions["PROMOTION_PENETRATION_2"].ID

	if (defUnit:IsHasPromotion(Penetration1ID, true)) then
		defUnit:SetHasPromotion(Penetration2ID, true)
	else
		defUnit:SetHasPromotion(Penetration1ID, true)
		return
	end
end

---- Set Debuff Effects: Slow Down
function SetSlowDown(defUnit)
	local SlowDown1ID = GameInfo.UnitPromotions["PROMOTION_MOVEMENT_LOST_1"].ID
	local SlowDown2ID = GameInfo.UnitPromotions["PROMOTION_MOVEMENT_LOST_2"].ID

	if (defUnit:IsHasPromotion(SlowDown1ID, true)) then
		defUnit:SetHasPromotion(SlowDown2ID, true)
	else
		defUnit:SetHasPromotion(SlowDown1ID, true)
	end
end

---- Set Debuff Effects: Moral Weaken
function SetMoralWeaken(defUnit)
	local MoralWeaken1ID = GameInfo.UnitPromotions["PROMOTION_MORAL_WEAKEN_1"].ID
	local MoralWeaken2ID = GameInfo.UnitPromotions["PROMOTION_MORAL_WEAKEN_2"].ID

	if (defUnit:IsHasPromotion(MoralWeaken1ID, true)) then
		defUnit:SetHasPromotion(MoralWeaken2ID, true)
	else
		defUnit:SetHasPromotion(MoralWeaken1ID, true)
	end
end

print("New Combat Rules Check Pass!")
