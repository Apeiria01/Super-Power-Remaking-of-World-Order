-- New Combat Rules


--include( "UtilityFunctions.lua" )
include("FLuaVector.lua");
--******************************************************************************* Unit Combat Rules *******************************************************************************
local g_DoNewAttackEffect = nil;
local NewAttackOff = GameInfo.SPNewEffectControler.SP_NEWATTACK_OFF.Enabled
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
		return;
	end
	-- Not for Barbarins
	if attPlayer:IsBarbarian() then
		return;
	end

	------- PromotionID
	local SpeComID = GameInfo.UnitPromotions["PROMOTION_SPECIAL_FORCES_COMBAT"].ID
	local SPForce2ID = GameInfo.UnitPromotions["PROMOTION_SP_FORCE_2"].ID

	local EMPBomberID = GameInfo.UnitPromotions["PROMOTION_EMP_ATTACK"].ID
	local AntiEMPID = GameInfo.UnitPromotions["PROMOTION_ANTI_EMP"].ID

	local AntiDebuffID = GameInfo.UnitPromotions["PROMOTION_ANTI_DEBUFF"].ID

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

		-- Attacking a Unit!
	elseif defUnit then
		-- Debuff immune unit
		if defUnit:IsHasPromotion(AntiDebuffID) then
			print("This unit is debuff immune")
			return
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
	end
end --function END

GameEvents.BattleFinished.Add(NewAttackEffect)


print("New Combat Rules Check Pass!")
