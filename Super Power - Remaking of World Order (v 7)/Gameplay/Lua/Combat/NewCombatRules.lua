-- New Combat Rules


--include( "UtilityFunctions.lua" )

--******************************************************************************* Unit Combat Rules *******************************************************************************
local g_DoNewAttackEffect = nil;
function NewAttackEffectStarted(iType, iPlotX, iPlotY)
	if (PreGame.GetGameOption("GAMEOPTION_SP_NEWATTACK_OFF") == 1) then
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
	local NavalHitAndRunUnitID = GameInfo.UnitPromotions["PROMOTION_NAVAL_HIT_AND_RUN"].ID
	local SubmarineUnitID = GameInfo.UnitPromotions["PROMOTION_SUBMARINE_COMBAT"].ID
	local GunpowderInfantryUnitID = GameInfo.UnitPromotions["PROMOTION_GUNPOWDER_INFANTRY_COMBAT"].ID
	local NavalCapitalShipUnitID = GameInfo.UnitPromotions["PROMOTION_NAVAL_CAPITAL_SHIP"].ID
	local NavalRangedShipUnitID = GameInfo.UnitPromotions["PROMOTION_NAVAL_RANGED_SHIP"].ID
	local NavalRangedCruiserUnitID = GameInfo.UnitPromotions["PROMOTION_NAVAL_RANGED_CRUISER"].ID
	local StragegicBomberUnitID = GameInfo.UnitPromotions["PROMOTION_STRATEGIC_BOMBER"].ID
	local AttackAircraftUnitID = GameInfo.UnitPromotions["PROMOTION_AIR_ATTACK"].ID
	local CitySiegeUnitID = GameInfo.UnitPromotions["PROMOTION_CITY_SIEGE"].ID
	local NuclearArtilleryUnitID = GameInfo.UnitPromotions["PROMOTION_NUCLEAR_ARTILLERY"].ID
	local CarrierFighterUnitID = GameInfo.UnitPromotions["PROMOTION_CARRIER_FIGHTER"].ID
	local IntercepterAircraftUnitID = GameInfo.UnitPromotions["PROMOTION_ANTI_AIR_II"].ID
	local HelicopterUnitID = GameInfo.UnitPromotions["PROMOTION_HELI_ATTACK"].ID
	local HitAndRunUnitID = GameInfo.UnitPromotions["PROMOTION_HITANDRUN"].ID
	local MissileUnitID = GameInfo.UnitPromotions["PROMOTION_NO_CASUALTIES"].ID
	local InfantryUnitID = GameInfo.UnitPromotions["PROMOTION_INFANTRY_COMBAT"].ID
	local LongBowManUnitID = GameInfo.UnitPromotions["PROMOTION_RANGE_SPECIAL"].ID
	local KnightID = GameInfo.UnitPromotions["PROMOTION_KNIGHT_COMBAT"].ID
	local TankID = GameInfo.UnitPromotions["PROMOTION_TANK_COMBAT"].ID
	local PillageFreeID = GameInfo.UnitPromotions["PROMOTION_CITY_PILLAGE_FREE"].ID
	local SpeComID = GameInfo.UnitPromotions["PROMOTION_SPECIAL_FORCES_COMBAT"].ID
	local SPForce2ID = GameInfo.UnitPromotions["PROMOTION_SP_FORCE_2"].ID

	local Charge1ID = GameInfo.UnitPromotions["PROMOTION_CHARGE_1"].ID
	local Charge2ID = GameInfo.UnitPromotions["PROMOTION_CHARGE_2"].ID
	local Charge3ID = GameInfo.UnitPromotions["PROMOTION_CHARGE_3"].ID

	local Barrage1ID = GameInfo.UnitPromotions["PROMOTION_BARRAGE_1"].ID
	local Barrage2ID = GameInfo.UnitPromotions["PROMOTION_BARRAGE_2"].ID
	local Barrage3ID = GameInfo.UnitPromotions["PROMOTION_BARRAGE_3"].ID

	local Sunder1ID = GameInfo.UnitPromotions["PROMOTION_SUNDER_1"].ID
	local Sunder2ID = GameInfo.UnitPromotions["PROMOTION_SUNDER_2"].ID
	-- local Sunder3ID = GameInfo.UnitPromotions["PROMOTION_SUNDER_3"].ID

	local Penetration1ID = GameInfo.UnitPromotions["PROMOTION_PENETRATION_1"].ID
	local Penetration2ID = GameInfo.UnitPromotions["PROMOTION_PENETRATION_2"].ID

	local CollDamageLV1ID = GameInfo.UnitPromotions["PROMOTION_COLLATERAL_DAMAGE_1"].ID
	local CollDamageLV2ID = GameInfo.UnitPromotions["PROMOTION_COLLATERAL_DAMAGE_2"].ID
	-- local CollDamageLV3ID = GameInfo.UnitPromotions["PROMOTION_COLLATERAL_DAMAGE_3"].ID

	local CQBCombat1ID = GameInfo.UnitPromotions["PROMOTION_CQB_COMBAT_1"].ID
	local CQBCombat2ID = GameInfo.UnitPromotions["PROMOTION_CQB_COMBAT_2"].ID

	local KillingEffectsID = GameInfo.UnitPromotions["PROMOTION_GAIN_MOVES_AFFER_KILLING"].ID

	local SPForce1ID = GameInfo.UnitPromotions["PROMOTION_SP_FORCE_1"].ID

	local StgBomberID = GameInfo.UnitPromotions["PROMOTION_STRATEGIC_BOMBER"].ID

	local EMPBomberID = GameInfo.UnitPromotions["PROMOTION_EMP_ATTACK"].ID
	local AntiEMPID = GameInfo.UnitPromotions["PROMOTION_ANTI_EMP"].ID

	local NapalmBomb1ID = GameInfo.UnitPromotions["PROMOTION_NAPALMBOMB_1"].ID
	local NapalmBomb2ID = GameInfo.UnitPromotions["PROMOTION_NAPALMBOMB_2"].ID
	local NapalmBomb3ID = GameInfo.UnitPromotions["PROMOTION_NAPALMBOMB_3"].ID
	local AirSiege1ID = GameInfo.UnitPromotions["PROMOTION_AIR_SIEGE_1"].ID
	local AirSiege2ID = GameInfo.UnitPromotions["PROMOTION_AIR_SIEGE_2"].ID
	local AirSiege3ID = GameInfo.UnitPromotions["PROMOTION_AIR_SIEGE_3"].ID
	local BombShelterID = GameInfo.Buildings["BUILDING_BOMB_SHELTER"].ID

	local AttackAirCraftID = GameInfo.UnitPromotions["PROMOTION_AIR_ATTACK"].ID
	local AirTarget1ID = GameInfo.UnitPromotions["PROMOTION_AIR_TARGETING_1"].ID
	local AirTarget2ID = GameInfo.UnitPromotions["PROMOTION_AIR_TARGETING_2"].ID
	local AirTarget3ID = GameInfo.UnitPromotions["PROMOTION_AIR_TARGETING_3"].ID

	local CarrierFighterID = GameInfo.UnitPromotions["PROMOTION_CARRIER_FIGHTER"].ID
	local AirTarget_CarrierID = GameInfo.UnitPromotions["PROMOTION_CARRIER_FIGHTER_SIEGE_2"].ID

	local AntiAirID = GameInfo.UnitPromotions["PROMOTION_ANTI_AIR"].ID
	local DestroyerID = GameInfo.UnitPromotions["PROMOTION_DESTROYER_COMBAT"].ID

	local SplashDamageID = GameInfo.UnitPromotions["PROMOTION_SPLASH_DAMAGE"].ID
	local NavalCapitalShipID = GameInfo.UnitPromotions["PROMOTION_NAVAL_CAPITAL_SHIP"].ID

	local ClusterRocket1ID = GameInfo.UnitPromotions["PROMOTION_CLUSTER_ROCKET_1"].ID
	local ClusterRocket2ID = GameInfo.UnitPromotions["PROMOTION_CLUSTER_ROCKET_2"].ID

	local DestroySupply_CarrierID = GameInfo.UnitPromotions["PROMOTION_CARRIER_FIGHTER_SIEGE_1"].ID
	local DestroySupply1ID = GameInfo.UnitPromotions["PROMOTION_DESTROY_SUPPLY_1"].ID
	local DestroySupply2ID = GameInfo.UnitPromotions["PROMOTION_DESTROY_SUPPLY_2"].ID
	local LoseSupplyID = GameInfo.UnitPromotions["PROMOTION_LOSE_SUPPLY"].ID
	local Damage1ID = GameInfo.UnitPromotions["PROMOTION_DAMAGE_1"].ID
	local Damage2ID = GameInfo.UnitPromotions["PROMOTION_DAMAGE_2"].ID

	--local FireSupport1ID = GameInfo.UnitPromotions["PROMOTION_FIRESUPPORT_1"].ID
	--local FireSupport2ID = GameInfo.UnitPromotions["PROMOTION_FIRESUPPORT_2"].ID

	local NuclearArtilleryID = GameInfo.UnitPromotions["PROMOTION_NUCLEAR_ARTILLERY"].ID
	local ChainReactionID = GameInfo.UnitPromotions["PROMOTION_CHAIN_REACTION"].ID

	local BlitzID = GameInfo.UnitPromotions["PROMOTION_BLITZ"].ID
	local MovetoAdjOnlyID = GameInfo.UnitPromotions["PROMOTION_MOVE_TO_ADJUST_ONLY"].ID
	local MovetoAdjOnly1ID = GameInfo.UnitPromotions["PROMOTION_MOVE_TO_ADJUST_ONLY_MARK_I"].ID
	local MovetoAdjOnly2ID = GameInfo.UnitPromotions["PROMOTION_MOVE_TO_ADJUST_ONLY_MARK_II"].ID
	local MovetoAdjOnly3ID = GameInfo.UnitPromotions["PROMOTION_MOVE_TO_ADJUST_ONLY_MARK_III"].ID
	local MovetoAdjOnly4ID = GameInfo.UnitPromotions["PROMOTION_MOVE_TO_ADJUST_ONLY_MARK_IV"].ID


	local AntiDebuffID = GameInfo.UnitPromotions["PROMOTION_ANTI_DEBUFF"].ID


	-- Ranged Unit Logistics can only move to the adjusted plot
	if attUnit:IsDead() then
	elseif attUnit:GetMoves() > 0 and not attUnit:IsImmobile() and not attUnit:IsRangedSupportFire()
		and not attUnit:IsHasPromotion(BlitzID) and not attUnit:IsHasPromotion(MovetoAdjOnlyID)
	then
		local IsMoveToAdjOnly = true;
		local iExtraAttacks = 0;
		for unitPromotion in GameInfo.UnitPromotions() do
			if unitPromotion == nil or unitPromotion.OrderPriority == 10 or not attUnit:IsHasPromotion(unitPromotion.ID) then
			elseif unitPromotion.ExtraAttacks > 0 then
				iExtraAttacks = iExtraAttacks + unitPromotion.ExtraAttacks;
			elseif unitPromotion.CanMoveAfterAttacking then
				IsMoveToAdjOnly = false;
				break;
			end
		end
		if IsMoveToAdjOnly then
			attUnit:SetHasPromotion(MovetoAdjOnlyID, true);
			if attUnit:GetMoves() >= GameDefines["MOVE_DENOMINATOR"] then
				if iExtraAttacks > 1 then
					local coeff = 1;
					if iExtraAttacks >= attUnit:MaxMoves() / GameDefines["MOVE_DENOMINATOR"] then
						coeff = iExtraAttacks / (attUnit:MaxMoves() / GameDefines["MOVE_DENOMINATOR"] - 1);
					end
					local iMarkNum = math.min(math.ceil(coeff * attUnit:GetMoves() / GameDefines["MOVE_DENOMINATOR"]), iExtraAttacks) -
						1;
					if iMarkNum == 10 then
						attUnit:SetHasPromotion(MovetoAdjOnly1ID, true);
						attUnit:SetHasPromotion(MovetoAdjOnly2ID, true);
						attUnit:SetHasPromotion(MovetoAdjOnly3ID, true);
						attUnit:SetHasPromotion(MovetoAdjOnly4ID, true);
					elseif iMarkNum == 9 then
						attUnit:SetHasPromotion(MovetoAdjOnly2ID, true);
						attUnit:SetHasPromotion(MovetoAdjOnly3ID, true);
						attUnit:SetHasPromotion(MovetoAdjOnly4ID, true);
					elseif iMarkNum == 8 then
						attUnit:SetHasPromotion(MovetoAdjOnly1ID, true);
						attUnit:SetHasPromotion(MovetoAdjOnly3ID, true);
						attUnit:SetHasPromotion(MovetoAdjOnly4ID, true);
					elseif iMarkNum == 7 then
						attUnit:SetHasPromotion(MovetoAdjOnly1ID, true);
						attUnit:SetHasPromotion(MovetoAdjOnly2ID, true);
						attUnit:SetHasPromotion(MovetoAdjOnly4ID, true);
					elseif iMarkNum == 6 then
						attUnit:SetHasPromotion(MovetoAdjOnly1ID, true);
						attUnit:SetHasPromotion(MovetoAdjOnly2ID, true);
						attUnit:SetHasPromotion(MovetoAdjOnly3ID, true);
					elseif iMarkNum == 5 then
						attUnit:SetHasPromotion(MovetoAdjOnly1ID, true);
						attUnit:SetHasPromotion(MovetoAdjOnly4ID, true);
					elseif iMarkNum == 4 then
						attUnit:SetHasPromotion(MovetoAdjOnly4ID, true);
					elseif iMarkNum == 3 then
						attUnit:SetHasPromotion(MovetoAdjOnly3ID, true);
					elseif iMarkNum == 2 then
						attUnit:SetHasPromotion(MovetoAdjOnly2ID, true);
					elseif iMarkNum == 1 then
						attUnit:SetHasPromotion(MovetoAdjOnly1ID, true);
					end
				end
				attUnit:SetMoves(GameDefines["MOVE_DENOMINATOR"]);
			end
		end
	elseif attUnit:GetMoves() == 0 and attUnit:IsHasPromotion(MovetoAdjOnlyID) then
		if attUnit:IsHasPromotion(MovetoAdjOnly1ID) or attUnit:IsHasPromotion(MovetoAdjOnly2ID)
			or attUnit:IsHasPromotion(MovetoAdjOnly3ID) or attUnit:IsHasPromotion(MovetoAdjOnly4ID)
		then
			attUnit:SetMoves(GameDefines["MOVE_DENOMINATOR"]);
			if attUnit:IsHasPromotion(MovetoAdjOnly1ID)
				and attUnit:IsHasPromotion(MovetoAdjOnly2ID)
				and attUnit:IsHasPromotion(MovetoAdjOnly3ID)
				and attUnit:IsHasPromotion(MovetoAdjOnly4ID)
			then -- 10
				attUnit:SetHasPromotion(MovetoAdjOnly1ID, false);
			elseif attUnit:IsHasPromotion(MovetoAdjOnly2ID)
				and attUnit:IsHasPromotion(MovetoAdjOnly3ID)
				and attUnit:IsHasPromotion(MovetoAdjOnly4ID)
			then --  9
				attUnit:SetHasPromotion(MovetoAdjOnly2ID, false);
				attUnit:SetHasPromotion(MovetoAdjOnly1ID, true);
			elseif attUnit:IsHasPromotion(MovetoAdjOnly1ID)
				and attUnit:IsHasPromotion(MovetoAdjOnly3ID)
				and attUnit:IsHasPromotion(MovetoAdjOnly4ID)
			then --  8
				attUnit:SetHasPromotion(MovetoAdjOnly3ID, false);
				attUnit:SetHasPromotion(MovetoAdjOnly2ID, true);
			elseif attUnit:IsHasPromotion(MovetoAdjOnly1ID)
				and attUnit:IsHasPromotion(MovetoAdjOnly2ID)
				and attUnit:IsHasPromotion(MovetoAdjOnly4ID)
			then --  7
				attUnit:SetHasPromotion(MovetoAdjOnly4ID, false);
				attUnit:SetHasPromotion(MovetoAdjOnly3ID, true);
			elseif attUnit:IsHasPromotion(MovetoAdjOnly1ID)
				and attUnit:IsHasPromotion(MovetoAdjOnly2ID)
				and attUnit:IsHasPromotion(MovetoAdjOnly3ID)
			then --  6
				attUnit:SetHasPromotion(MovetoAdjOnly2ID, false);
				attUnit:SetHasPromotion(MovetoAdjOnly3ID, false);
				attUnit:SetHasPromotion(MovetoAdjOnly4ID, true);
			elseif attUnit:IsHasPromotion(MovetoAdjOnly1ID)
				and attUnit:IsHasPromotion(MovetoAdjOnly4ID)
			then --  5
				attUnit:SetHasPromotion(MovetoAdjOnly1ID, false);
			elseif attUnit:IsHasPromotion(MovetoAdjOnly4ID)
			then --  4
				attUnit:SetHasPromotion(MovetoAdjOnly4ID, false);
				attUnit:SetHasPromotion(MovetoAdjOnly3ID, true);
			elseif attUnit:IsHasPromotion(MovetoAdjOnly3ID)
			then --  3
				attUnit:SetHasPromotion(MovetoAdjOnly3ID, false);
				attUnit:SetHasPromotion(MovetoAdjOnly2ID, true);
			elseif attUnit:IsHasPromotion(MovetoAdjOnly2ID)
			then --  2
				attUnit:SetHasPromotion(MovetoAdjOnly2ID, false);
				attUnit:SetHasPromotion(MovetoAdjOnly1ID, true);
			else --  1 or others
				attUnit:SetHasPromotion(MovetoAdjOnly1ID, false);
				attUnit:SetHasPromotion(MovetoAdjOnly2ID, false);
				attUnit:SetHasPromotion(MovetoAdjOnly3ID, false);
				attUnit:SetHasPromotion(MovetoAdjOnly4ID, false);
			end
		else
			attUnit:SetHasPromotion(MovetoAdjOnlyID, false);
		end
	end


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
					UnitDeathCounter(attPlayerID, unit:GetOwner(), eUnitType);
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


		----------------Strategic Bomber kill popluation
		if (attUnit:IsHasPromotion(NapalmBomb1ID) or attUnit:IsHasPromotion(NuclearArtilleryID))
			and not (attUnit:IsHasPromotion(AttackAirCraftID) or attUnit:IsHasPromotion(CarrierFighterUnitID))
		then
			local CityPopLoss = 0
			local cityPop = defCity:GetPopulation()
			-- *************************Popluation Loss************************************
			if cityPop > 1 then
				local CityPopLoss1 = 0
				local CityPopLoss2 = 0
				local CityPopLoss3 = 0
				if attUnit:IsHasPromotion(NapalmBomb1ID) then --Strategic Bomber attacking City killing popluation Lv1
					if defCity:IsHasBuilding(BombShelterID) then
						defCity:ChangePopulation(-math.floor(cityPop * 0.05), true)
						CityPopLoss1 = math.floor(cityPop * 0.05)
					else
						defCity:ChangePopulation(-math.floor(cityPop * 0.2), true)
						CityPopLoss1 = math.floor(cityPop * 0.2)
					end
				end
				if attUnit:IsHasPromotion(NapalmBomb2ID) then --Strategic Bomber attacking City killing popluation Lv2
					if defCity:IsHasBuilding(BombShelterID) then
						defCity:ChangePopulation(-math.floor(cityPop * 0.05), true)
						CityPopLoss2 = math.floor(cityPop * 0.05)
					else
						defCity:ChangePopulation(-math.floor(cityPop * 0.2), true)
						CityPopLoss2 = math.floor(cityPop * 0.2)
					end
				end
				if attUnit:IsHasPromotion(NapalmBomb3ID) then --Strategic Bomber attacking City killing popluation Lv3
					if defCity:IsHasBuilding(BombShelterID) then
						defCity:ChangePopulation(-math.floor(cityPop * 0.05), true)
						CityPopLoss3 = math.floor(cityPop * 0.05)
					else
						defCity:ChangePopulation(-math.floor(cityPop * 0.2), true)
						CityPopLoss3 = math.floor(cityPop * 0.2)
					end
				end
				if attUnit:IsHasPromotion(NuclearArtilleryID) then -- killing popluation for Nuclear Artillery
					if defCity:IsHasBuilding(BombShelterID) then
						defCity:ChangePopulation(-math.floor(cityPop * 0.15), true)
						CityPopLoss2 = math.floor(cityPop * 0.15)
					else
						defCity:ChangePopulation(-math.floor(cityPop * 0.6), true)
						CityPopLoss2 = math.floor(cityPop * 0.6)
					end
				end

				CityPopLoss = CityPopLoss1 + CityPopLoss2 + CityPopLoss3
				print("Population loss:" .. CityPopLoss)
			end

			-- Notification
			if attPlayer:IsHuman() then
				local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_BOMBER_CITY_KILL_POPULATION_ATTACKING",
					tostring(CityPopLoss))
				Events.GameplayAlertMessage(text)
			end
			if defPlayer:IsHuman() then
				local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_BOMBER_CITY_KILL_POPULATION_ATTACKED",
					tostring(CityPopLoss), defCity:GetName())
				local heading = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_BOMBER_CITY_ATTACKED_SHORT", defCity:GetName())
				defPlayer:AddNotification(NotificationTypes.NOTIFICATION_STARVING, text, heading, plotX, plotY)
			end
		end

		-- *************************Destroy Building************************************
		if attUnit:IsHasPromotion(AirSiege1ID) then
			local BuildingLoss = 1
			if attUnit:IsHasPromotion(AirSiege2ID) and attUnit:IsHasPromotion(StragegicBomberUnitID) then
				BuildingLoss = BuildingLoss + 1
			end
			if attUnit:IsHasPromotion(AirSiege3ID) and attUnit:IsHasPromotion(StragegicBomberUnitID) then
				BuildingLoss = BuildingLoss + 1
			end

			if batPlot and defCity then
				for i = 0, BuildingLoss - 1 do
					if defCity:IsHasBuilding(GameInfo.Buildings["BUILDING_MILITARY_BASE"].ID) then
						defCity:SetNumRealBuilding(GameInfoTypes["BUILDING_MILITARY_BASE"], 0);

					elseif defCity:IsHasBuilding(GameInfo.Buildings["BUILDING_SHIPYARD"].ID) then
						defCity:SetNumRealBuilding(GameInfoTypes["BUILDING_SHIPYARD"], 0);

					elseif defCity:IsHasBuilding(GameInfo.Buildings["BUILDING_ARSENAL"].ID) then
						defCity:SetNumRealBuilding(GameInfoTypes["BUILDING_ARSENAL"], 0);

					elseif defCity:IsHasBuilding(GameInfo.Buildings["BUILDING_ARMORY"].ID) then
						defCity:SetNumRealBuilding(GameInfoTypes["BUILDING_ARMORY"], 0);

					elseif defCity:IsHasBuilding(GameInfo.Buildings["BUILDING_BARRACKS"].ID) then
						defCity:SetNumRealBuilding(GameInfoTypes["BUILDING_BARRACKS"], 0);
					elseif defCity:IsHasBuilding(GameInfo.Buildings["BUILDING_WOOD_DOCK"].ID) then
						defCity:SetNumRealBuilding(GameInfoTypes["BUILDING_WOOD_DOCK"], 0);
					elseif defCity:IsHasBuilding(GameInfo.Buildings["BUILDING_CASTLE"].ID) then
						defCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CASTLE"], 0)
					elseif defCity:IsHasBuilding(GameInfo.Buildings["BUILDING_JAPANESE_TENSHU"].ID) then
						defCity:SetNumRealBuilding(GameInfoTypes["BUILDING_JAPANESE_TENSHU"], 0);
					elseif defCity:IsHasBuilding(GameInfo.Buildings["BUILDING_WALLS"].ID) then
						defCity:SetNumRealBuilding(GameInfoTypes["BUILDING_WALLS"], 0);
					elseif defCity:IsHasBuilding(GameInfo.Buildings["BUILDING_WALLS_OF_BABYLON"].ID) then
						defCity:SetNumRealBuilding(GameInfoTypes["BUILDING_WALLS_OF_BABYLON"], 0);

					elseif defCity:IsHasBuilding(GameInfo.Buildings["BUILDING_FUSION_PLANT"].ID) then
						defCity:SetNumRealBuilding(GameInfoTypes["BUILDING_FUSION_PLANT"], 0);

					elseif defCity:IsHasBuilding(GameInfo.Buildings["BUILDING_NUCLEAR_PLANT_EXTEND"].ID) then
						defCity:SetNumRealBuilding(GameInfoTypes["BUILDING_NUCLEAR_PLANT_EXTEND"], 0);

					elseif defCity:IsHasBuilding(GameInfo.Buildings["BUILDING_NUCLEAR_PLANT"].ID) then
						defCity:SetNumRealBuilding(GameInfoTypes["BUILDING_NUCLEAR_PLANT"], 0);

					elseif defCity:IsHasBuilding(GameInfo.Buildings["BUILDING_COAL_PLANT_EXTEND"].ID) then
						defCity:SetNumRealBuilding(GameInfoTypes["BUILDING_COAL_PLANT_EXTEND"], 0);

					elseif defCity:IsHasBuilding(GameInfo.Buildings["BUILDING_COAL_PLANT"].ID) then
						defCity:SetNumRealBuilding(GameInfoTypes["BUILDING_COAL_PLANT"], 0);

					elseif defCity:IsHasBuilding(GameInfo.Buildings["BUILDING_WIND_PLANT"].ID) then
						defCity:SetNumRealBuilding(GameInfoTypes["BUILDING_WIND_PLANT"], 0);

					elseif defCity:IsHasBuilding(GameInfo.Buildings["BUILDING_DANISH_WIND_TURBINE"].ID) then
						defCity:SetNumRealBuilding(GameInfoTypes["BUILDING_DANISH_WIND_TURBINE"], 0);

					elseif defCity:IsHasBuilding(GameInfo.Buildings["BUILDING_HYDRO_PLANT"].ID) then
						defCity:SetNumRealBuilding(GameInfoTypes["BUILDING_HYDRO_PLANT"], 0);

					elseif defCity:IsHasBuilding(GameInfo.Buildings["BUILDING_OIL_PLANT"].ID) then
						defCity:SetNumRealBuilding(GameInfoTypes["BUILDING_OIL_PLANT"], 0);

					elseif defCity:IsHasBuilding(GameInfo.Buildings["BUILDING_GAS_PLANT"].ID) then
						defCity:SetNumRealBuilding(GameInfoTypes["BUILDING_GAS_PLANT"], 0);

					elseif defCity:IsHasBuilding(GameInfo.Buildings["BUILDING_SPAIN_SOLAR10"].ID) then
						defCity:SetNumRealBuilding(GameInfoTypes["BUILDING_SPAIN_SOLAR10"], 0);
					elseif defCity:IsHasBuilding(GameInfo.Buildings["BUILDING_SOLAR_PLANT"].ID) then
						defCity:SetNumRealBuilding(GameInfoTypes["BUILDING_SOLAR_PLANT"], 0);
					elseif defCity:IsHasBuilding(GameInfo.Buildings["BUILDING_TIDAL_PLANT"].ID) then
						defCity:SetNumRealBuilding(GameInfoTypes["BUILDING_TIDAL_PLANT"], 0);

					elseif defCity:IsHasBuilding(GameInfo.Buildings["BUILDING_DUTCH_DTP"].ID) then
						defCity:SetNumRealBuilding(GameInfoTypes["BUILDING_DUTCH_DTP"], 0);

					elseif defCity:IsHasBuilding(GameInfo.Buildings["BUILDING_SPACESHIP_FACTORY"].ID) then
						defCity:SetNumRealBuilding(GameInfoTypes["BUILDING_SPACESHIP_FACTORY"], 0);

					elseif defCity:IsHasBuilding(GameInfo.Buildings["BUILDING_FUTURE_FACTORY"].ID) then
						defCity:SetNumRealBuilding(GameInfoTypes["BUILDING_FACTORY"], 0);

					elseif defCity:IsHasBuilding(GameInfo.Buildings["BUILDING_FACTORY"].ID) then
						defCity:SetNumRealBuilding(GameInfoTypes["BUILDING_FACTORY"], 0);

					elseif defCity:IsHasBuilding(GameInfo.Buildings["BUILDING_STEEL_MILL"].ID) then
						defCity:SetNumRealBuilding(GameInfoTypes["BUILDING_STEEL_MILL"], 0);

					elseif defCity:IsHasBuilding(GameInfo.Buildings["BUILDING_OIL_REFINERY"].ID) then
						defCity:SetNumRealBuilding(GameInfoTypes["BUILDING_OIL_REFINERY"], 0);

					elseif defCity:IsHasBuilding(GameInfo.Buildings["BUILDING_SONGHAI_ISLAM_MINT"].ID) then
						defCity:SetNumRealBuilding(GameInfoTypes["BUILDING_SONGHAI_ISLAM_MINT"], 0);

					elseif defCity:IsHasBuilding(GameInfo.Buildings["BUILDING_FORGE"].ID) then
						defCity:SetNumRealBuilding(GameInfoTypes["BUILDING_FORGE"], 0);

					elseif defCity:IsHasBuilding(GameInfo.Buildings["BUILDING_MINGING_FACTORY"].ID) then
						defCity:SetNumRealBuilding(GameInfoTypes["BUILDING_MINGING_FACTORY"], 0);

					elseif defCity:IsHasBuilding(GameInfo.Buildings["BUILDING_INLAND_CANAL"].ID) then
						defCity:SetNumRealBuilding(GameInfoTypes["BUILDING_INLAND_CANAL"], 0);

					elseif defCity:IsHasBuilding(GameInfo.Buildings["BUILDING_METAL_FACTORY"].ID) then
						defCity:SetNumRealBuilding(GameInfoTypes["BUILDING_METAL_FACTORY"], 0);
					end
				end

				print("Building loss:" .. BuildingLoss)
				---------------------Notification
				if attPlayer:IsHuman() then
					local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_BOMBER_CITY_BUILDING_DESTROYED_ATTACKING",
						tostring(BuildingLoss))
					Events.GameplayAlertMessage(text)
				end

				if defPlayer:IsHuman() then
					local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_BOMBER_CITY_BUILDING_DESTROYED_ATTACKED",
						tostring(CityPopLoss), defCity:GetName())
					local heading = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_BOMBER_CITY_ATTACKED_SHORT", defCity:GetName())
					defPlayer:AddNotification(NotificationTypes.NOTIFICATION_STARVING, text, heading, plotX, plotY)
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
							UnitDeathCounter(attPlayerID, pFoundUnit:GetOwner(), eUnitType);
						end
						pFoundUnit:ChangeDamage(iChangeDamage);
					end
				end
			end
		end



		-- Attacking a Unit!
	elseif defUnit then
		------ Collateral damage (both melee and ranged)!
		if (attUnit:IsHasPromotion(NavalRangedShipUnitID) or attUnit:IsHasPromotion(NavalRangedCruiserUnitID)
			or attUnit:IsHasPromotion(CitySiegeUnitID)) and batPlot:GetNumUnits() > 1 then
			-- print("Melee or Ranged attack and Available for Collateral Damage!")
			local unitCount = batPlot:GetNumUnits()
			for i = 0, unitCount - 1, 1 do
				local pFoundUnit = batPlot:GetUnit(i)
				if (pFoundUnit and pFoundUnit ~= defUnit and pFoundUnit:GetDomainType() ~= DomainTypes.DOMAIN_AIR) then
					local pPlayer = Players[pFoundUnit:GetOwner()]
					if PlayersAtWar(attPlayer, pPlayer) then
						local CollDamageOri = 0;
						if batType == GameInfoTypes["BATTLETYPE_MELEE"] then
							local attUnitStrength = attUnit:GetMaxAttackStrength(attPlot, defPlot, defUnit);
							print("attUnitStrength:" .. attUnitStrength);
							local pFoundUnitStrength = pFoundUnit:GetMaxDefenseStrength(batPlot, attUnit);
							print("pFoundUnitStrength:" .. pFoundUnitStrength);
							CollDamageOri = attUnit:GetCombatDamage(attUnitStrength, pFoundUnitStrength, attFinalUnitDamage, false, false,
								false);
						else
							CollDamageOri = attUnit:GetRangeCombatDamage(pFoundUnit, nil, false);
						end
						print("CollDamageOri:" .. CollDamageOri); --we now consider the buff and debuff when caculating the charge damage.

						local CollDmgMod = 0.5

						if attUnit:IsHasPromotion(CollDamageLV1ID) then
							CollDmgMod = 1.00 -- 0.83
						end
						if attUnit:IsHasPromotion(CollDamageLV2ID) then
							CollDmgMod = 1.50 -- 1.16
						end
						-- if attUnit:IsHasPromotion(CollDamageLV3ID) then
						-- CollDmgMod = 1.50
						-- end

						local text = nil;
						local attUnitName = attUnit:GetName();
						local defUnitName = pFoundUnit:GetName();

						print("CollDmgMod:" .. CollDmgMod)
						local CollDamageFinal = math.floor(CollDamageOri * CollDmgMod);
						if CollDamageFinal >= pFoundUnit:GetCurrHitPoints() then
							CollDamageFinal = pFoundUnit:GetCurrHitPoints();
							local eUnitType = pFoundUnit:GetUnitType();
							UnitDeathCounter(attPlayerID, pFoundUnit:GetOwner(), eUnitType);

							-- Notification
							if defPlayerID == Game.GetActivePlayer() then
								-- local heading = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_UNIT_DESTROYED_SHORT")
								text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_COLL_DAMAGE_DEATH", attUnitName, defUnitName);
								-- defPlayer:AddNotification(NotificationTypes.NOTIFICATION_GENERIC , text, heading, plotX, plotY)
							elseif attPlayerID == Game.GetActivePlayer() then
								text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_COLL_DAMAGE_ENEMY_DEATH", attUnitName, defUnitName);
							end
						elseif CollDamageFinal > 0 then
							-- Notification
							if defPlayerID == Game.GetActivePlayer() then
								text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_COLL_DAMAGE", attUnitName, defUnitName, CollDamageFinal);
							elseif attPlayerID == Game.GetActivePlayer() then
								text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_COLL_DAMAGE_ENEMY", attUnitName, defUnitName,
									CollDamageFinal);
							end
						end
						if text then
							Events.GameplayAlertMessage(text);
						end
						pFoundUnit:ChangeDamage(CollDamageFinal, attPlayer)
						print("Collateral Damage=" .. CollDamageFinal)
					end
				end
			end
		end

		--------Splash Damage (AOE)
		if (attUnit:IsHasPromotion(SplashDamageID) or attUnit:IsHasPromotion(NavalCapitalShipID)) then

			for i = 0, 5 do
				local adjPlot = Map.PlotDirection(plotX, plotY, i)
				if (adjPlot ~= nil and not adjPlot:IsCity()) then
					print("Available for AOE Damage!")

					local pUnit = adjPlot:GetUnit(0) ------------Find Units affected
					if pUnit and
						(pUnit:GetDomainType() == DomainTypes.DOMAIN_LAND or pUnit:GetDomainType() == DomainTypes.DOMAIN_SEA) then
						local pCombat = pUnit:GetBaseCombatStrength()
						local pPlayer = Players[pUnit:GetOwner()]

						if PlayersAtWar(attPlayer, pPlayer) then
							local SplashDamageOri = attUnit:GetRangeCombatDamage(pUnit, nil, false)

							local AOEmod = 0.5 -- the percent of damage reducing to nearby units

							if attUnit:IsHasPromotion(ClusterRocket1ID) then
								AOEmod = 0.75
								if attUnit:IsHasPromotion(ClusterRocket2ID) then
									AOEmod = 1
								end
								print("AOEmod:" .. AOEmod)
							end

							local text = nil;
							local attUnitName = attUnit:GetName();
							local defUnitName = pUnit:GetName();

							local SplashDamageFinal = math.floor(SplashDamageOri * AOEmod); -- Set the Final Damage
							if SplashDamageFinal >= pUnit:GetCurrHitPoints() then
								SplashDamageFinal = pUnit:GetCurrHitPoints();
								local eUnitType = pUnit:GetUnitType();
								UnitDeathCounter(attPlayerID, pUnit:GetOwner(), eUnitType);

								-- Notification
								if defPlayerID == Game.GetActivePlayer() then
									-- local heading = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_UNIT_DESTROYED_SHORT")
									text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_SPLASH_DAMAGE_DEATH", attUnitName, defUnitName);
									-- defPlayer:AddNotification(NotificationTypes.NOTIFICATION_GENERIC , text, heading, plotX, plotY)
								elseif attPlayerID == Game.GetActivePlayer() then
									text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_SPLASH_DAMAGE_ENEMY_DEATH", attUnitName, defUnitName);
								end
							elseif SplashDamageFinal > 0 then
								-- Notification
								if defPlayerID == Game.GetActivePlayer() then
									text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_SPLASH_DAMAGE", attUnitName, defUnitName,
										SplashDamageFinal);
								elseif attPlayerID == Game.GetActivePlayer() then
									text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_SPLASH_DAMAGE_ENEMY", attUnitName, defUnitName,
										SplashDamageFinal);
								end
							end
							if text then
								Events.GameplayAlertMessage(text);
							end
							pUnit:ChangeDamage(SplashDamageFinal, attPlayer)
							--						--------------Death Animation
							--						pUnit:PushMission(MissionTypes.MISSION_DIE_ANIMATION)
							print("Splash Damage=" .. SplashDamageFinal)
						end
					end
				end
			end
		end

		-------------------------Both Collateral Damage and AOE
		if attUnit:IsHasPromotion(NuclearArtilleryID) then
			local unitCount = batPlot:GetNumUnits();
			local iDamage = 0;
			-- Collateral
			for i = 0, unitCount - 1, 1 do
				local pFoundUnit = batPlot:GetUnit(i)
				if (pFoundUnit ~= nil and pFoundUnit:GetID() ~= defUnit:GetID()) then
					local textd = nil;
					local texta = nil;
					local attUnitName = attUnit:GetName();
					local defUnitName = pFoundUnit:GetName();

					iDamage = math.floor(attUnit:GetRangeCombatDamage(pFoundUnit, nil, false));
					if iDamage >= pFoundUnit:GetCurrHitPoints() then
						iDamage = pFoundUnit:GetCurrHitPoints();
						local eUnitType = pFoundUnit:GetUnitType();
						UnitDeathCounter(attPlayerID, pFoundUnit:GetOwner(), eUnitType);
						-- Notification
						if pFoundUnit:GetOwner() == Game.GetActivePlayer() then
							-- local heading = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_UNIT_DESTROYED_SHORT")
							textd = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_COLL_DAMAGE_DEATH", attUnitName, defUnitName);
							-- defPlayer:AddNotification(NotificationTypes.NOTIFICATION_GENERIC , text, heading, plotX, plotY)
						end
						if attPlayerID == Game.GetActivePlayer() then
							texta = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_COLL_DAMAGE_ENEMY_DEATH", attUnitName, defUnitName);
						end
					elseif iDamage > 0 then
						-- Notification
						if pFoundUnit:GetOwner() == Game.GetActivePlayer() then
							textd = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_COLL_DAMAGE", attUnitName, defUnitName, iDamage);
						end
						if attPlayerID == Game.GetActivePlayer() then
							texta = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_COLL_DAMAGE_ENEMY", attUnitName, defUnitName, iDamage);
						end
					end
					if textd then
						Events.GameplayAlertMessage(textd);
					end
					if texta then
						Events.GameplayAlertMessage(texta);
					end
					pFoundUnit:ChangeDamage(iDamage, attPlayer);
					print("Nuclear Artillery - Collateral!")
				end
			end
			-- AOE
			for i = 0, 5 do
				local adjPlot = Map.PlotDirection(plotX, plotY, i);
				if (adjPlot and adjPlot:GetNumUnits() > 0) then
					local unitCount = adjPlot:GetNumUnits();
					for i = 0, unitCount - 1, 1 do
						local pFoundUnit = adjPlot:GetUnit(i)
						if (pFoundUnit and pFoundUnit:GetID() ~= defUnit:GetID()) then
							local textd = nil;
							local texta = nil;
							local attUnitName = attUnit:GetName();
							local defUnitName = pFoundUnit:GetName();

							iDamage = math.floor(attUnit:GetRangeCombatDamage(pFoundUnit, nil, false));
							if iDamage >= pFoundUnit:GetCurrHitPoints() then
								iDamage = pFoundUnit:GetCurrHitPoints();
								local eUnitType = pFoundUnit:GetUnitType();
								UnitDeathCounter(attPlayerID, pFoundUnit:GetOwner(), eUnitType);

								-- Notification
								if pFoundUnit:GetOwner() == Game.GetActivePlayer() then
									-- local heading = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_UNIT_DESTROYED_SHORT")
									textd = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_SPLASH_DAMAGE_DEATH", attUnitName, defUnitName);
									-- defPlayer:AddNotification(NotificationTypes.NOTIFICATION_GENERIC , text, heading, plotX, plotY)
								end
								if attPlayerID == Game.GetActivePlayer() then
									texta = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_SPLASH_DAMAGE_ENEMY_DEATH", attUnitName, defUnitName);
								end
							elseif iDamage > 0 then
								-- Notification
								if pFoundUnit:GetOwner() == Game.GetActivePlayer() then
									textd = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_SPLASH_DAMAGE", attUnitName, defUnitName, iDamage);
								end
								if attPlayerID == Game.GetActivePlayer() then
									texta = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_SPLASH_DAMAGE_ENEMY", attUnitName, defUnitName, iDamage);
								end
							end
							if textd then
								Events.GameplayAlertMessage(textd);
							end
							if texta then
								Events.GameplayAlertMessage(texta);
							end
							pFoundUnit:ChangeDamage(iDamage, attPlayer);
							print("Nuclear Artillery - AOE & Collateral !")
						end
					end
				end
			end
		end


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
								UnitDeathCounter(attPlayerID, pFoundUnit:GetOwner(), eUnitType);

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
				UnitDeathCounter(attPlayerID, defPlayerID, eUnitType);

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
			defUnit:ChangeDamage(defFinalUnitDamageChange);
			if attUnit:CanMoveThrough(batPlot) and batPlot ~= attPlot then
				-- if the target plot has no unit,your unit advances into the target plot!
				attUnit:SetMoves(attUnit:MovesLeft() + GameDefines["MOVE_DENOMINATOR"]);
				attUnit:PushMission(MissionTypes.MISSION_MOVE_TO, plotX, plotY);
			end
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
			attUnit:IsHasPromotion(Sunder1ID) or attUnit:IsHasPromotion(Barrage1ID) or attUnit:IsHasPromotion(CollDamageLV1ID)
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
				if not defUnit:IsHasPromotion(Damage1ID) and math.random(1, 10) <= 5 then
					defUnit:SetHasPromotion(Damage1ID, true);
					tdebuff = Locale.ConvertTextKey("TXT_KEY_PROMOTION_DAMAGE_1");
					tlostHP = "[COLOR_NEGATIVE_TEXT]" .. -10 .. "[ENDCOLOR]";
					Message = 5;
				elseif defUnit:IsHasPromotion(Damage1ID) and not defUnit:IsHasPromotion(Damage2ID) and math.random(1, 10) <= 8 then
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

			if (defFinalUnitDamage / defUnit:GetMaxHitPoints() > 0.4) then
				if attUnit:IsHasPromotion(Sunder1ID) then ---only for legal units
					SetPenetration(defUnit)
					Message = 1
				end

				if attUnit:IsHasPromotion(CollDamageLV1ID) then
					SetMoralWeaken(defUnit)
					Message = 4
				end

				if attUnit:IsHasPromotion(Barrage1ID)
					and not defUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVEMENT_LOST_1"].ID, true) then
					defUnit:SetMoves(GameDefines["MOVE_DENOMINATOR"])
					SetSlowDown(defUnit)
					Message = 2
				elseif attUnit:IsHasPromotion(Barrage1ID) and
					defUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVEMENT_LOST_1"].ID, true) then
					if defUnit:CanMove() then
						IsNotification = true;
						defUnit:SetMoves(0)
					end
					SetSlowDown(defUnit)
					Message = 3
				end
			elseif (
				defFinalUnitDamage / defUnit:GetMaxHitPoints() > 0.25 and defFinalUnitDamage / defUnit:GetMaxHitPoints() <=
					0.4) then
				if attUnit:IsHasPromotion(Sunder1ID) then
					SetPenetration(defUnit)
					Message = 1
				end

				if attUnit:IsHasPromotion(CollDamageLV1ID) then
					SetMoralWeaken(defUnit)
					Message = 4
				end

				if attUnit:IsHasPromotion(Barrage2ID) and
					not defUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVEMENT_LOST_1"].ID, true) then
					defUnit:SetMoves(GameDefines["MOVE_DENOMINATOR"])
					SetSlowDown(defUnit)
					Message = 2
				elseif attUnit:IsHasPromotion(Barrage2ID) and
					defUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVEMENT_LOST_1"].ID, true) then
					if defUnit:CanMove() then
						IsNotification = true;
						defUnit:SetMoves(0)
					end
					SetSlowDown(defUnit)
					Message = 3
				end
			elseif (defFinalUnitDamage / defUnit:GetMaxHitPoints() > 0.1 and defFinalUnitDamage / defUnit:GetMaxHitPoints() <=
				0.25) then
				if attUnit:IsHasPromotion(Sunder2ID)
				--(attUnit:IsHasPromotion(NavalRangedCruiserUnitID)
				--or attUnit:IsHasPromotion(NavalRangedShipUnitID)
				--or attUnit:IsHasPromotion(HitAndRunUnitID)
				--or attUnit:IsHasPromotion(HelicopterUnitID)
				--or attUnit:IsHasPromotion(GunpowderInfantryUnitID)
				--or attUnit:IsHasPromotion(MissileUnitID)
				--or attUnit:IsHasPromotion(LongBowManUnitID))
				then
					SetPenetration(defUnit)
					Message = 1
				end

				if attUnit:IsHasPromotion(CollDamageLV2ID) then
					SetMoralWeaken(defUnit)
					Message = 4
				end

				if attUnit:IsHasPromotion(Barrage3ID) and
					not defUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVEMENT_LOST_1"].ID, true) then
					defUnit:SetMoves(GameDefines["MOVE_DENOMINATOR"])
					SetSlowDown(defUnit)
					Message = 2
				elseif attUnit:IsHasPromotion(Barrage3ID) and
					(attUnit:IsHasPromotion(ArcheryUnitID)
						or attUnit:IsHasPromotion(NavalHitAndRunUnitID)
						or attUnit:IsHasPromotion(SubmarineUnitID)) and
					defUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVEMENT_LOST_1"].ID, true) then
					if defUnit:CanMove() then
						IsNotification = true;
						defUnit:SetMoves(0)
					end
					SetSlowDown(defUnit)
					Message = 3
				end
			end

			-- Notification
			if attPlayer:IsHuman() then
				if Message == 1 then
					-- local heading = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_ENEMY_SUNDERED_SHORT");
					text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_ENEMY_SUNDERED", attUnitName, defUnitName);
					-- attPlayer:AddNotification(NotificationTypes.NOTIFICATION_GENERIC, text, heading, plotX, plotY);
				elseif Message == 2 then
					-- local heading = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_ENEMY_SLOWED_SHORT");
					text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_ENEMY_SLOWED", attUnitName, defUnitName);
					-- attPlayer:AddNotification(NotificationTypes.NOTIFICATION_GENERIC, text, heading, plotX, plotY);
				elseif Message == 3 then
					-- local heading = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_ENEMY_STOPPED_SHORT");
					text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_ENEMY_STOPPED", attUnitName, defUnitName);
					-- attPlayer:AddNotification(NotificationTypes.NOTIFICATION_GENERIC, text, heading, plotX, plotY);
				elseif Message == 4 then
					-- local heading = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_ENEMY_MORAL_WEAKEN_SHORT");
					text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_ENEMY_MORAL_WEAKEN", attUnitName, defUnitName);
					-- attPlayer:AddNotification(NotificationTypes.NOTIFICATION_GENERIC, text, heading, plotX, plotY);
				end
			elseif defPlayer:IsHuman() then
				if Message == 1 then
					-- local heading = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_US_SUNDERED_SHORT");
					text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_US_SUNDERED", attUnitName, defUnitName);
					-- defPlayer:AddNotification(NotificationTypes.NOTIFICATION_GENERIC, text, heading, plotX, plotY);
				elseif Message == 2 then
					-- local heading = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_US_SLOWED_SHORT");
					text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_US_SLOWED", attUnitName, defUnitName);
					-- defPlayer:AddNotification(NotificationTypes.NOTIFICATION_GENERIC, text, heading, plotX, plotY);
				elseif Message == 3 then
					local heading = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_US_STOPPED_SHORT");
					text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_US_STOPPED", attUnitName, defUnitName);
					if IsNotification then
						defPlayer:AddNotification(NotificationTypes.NOTIFICATION_GENERIC, text, heading, plotX, plotY);
						text = nil;
					end
				elseif Message == 4 then
					-- local heading = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_US_MORAL_WEAKEN_SHORT");
					text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_US_MORAL_WEAKEN", attUnitName, defUnitName);
					-- defPlayer:AddNotification(NotificationTypes.NOTIFICATION_GENERIC, text, heading, plotX, plotY);
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
				UnitDeathCounter(defPlayerID, attPlayerID, eUnitType);
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
				UnitDeathCounter(attPlayerID, defPlayerID, eUnitType);
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



function SPForceTwo(playerID)
	local player = Players[playerID]
	if player == nil then
		return
	end
	for unit in player:Units() do
		if not unit:IsDead() then
			if unit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_SP_FORCE_2"].ID) then
				if unit:GetCurrHitPoints() == unit:GetMaxHitPoints() then
					unit:SetHasPromotion((GameInfo.UnitPromotions["PROMOTION_SPFORCE_2"].ID), true)
					print("Has ChunGe!")
				else
					unit:SetHasPromotion((GameInfo.UnitPromotions["PROMOTION_SPFORCE_2"].ID), false)
					print("Go Die!")
				end
			end
		end
	end
end

GameEvents.PlayerDoTurn.Add(SPForceTwo)


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
			pUnit:SetExperience(tCaptureSPUnits[7] / 3);
			local pMoves = pUnit:MaxMoves();
			print("MaxMoves of captured unit is " .. pMoves);
			local qMoves = tCaptureSPUnits[8];
			local rMoves = (pMoves * 0.2 + qMoves * 0.4) * (math.random(1, 100) * 0.002 + 0.9);
			print("newly captured unit remains movements:" .. rMoves);
			pUnit:SetMoves(rMoves);
			pUnit:SetHasPromotion(NewlyCapturedID, true);
			local pDamage = math.random(1, 30) + 69 - qMoves / GameDefines["MOVE_DENOMINATOR"] * 4;
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
