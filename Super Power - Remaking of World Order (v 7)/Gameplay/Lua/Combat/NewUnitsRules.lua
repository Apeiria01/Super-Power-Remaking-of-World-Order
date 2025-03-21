-- NewUnitsRules

--------------------------------------------------------------

include("UtilityFunctions")


local AirCraftCarrierID = GameInfo.UnitPromotions["PROMOTION_CARRIER_UNIT"].ID
local MilitiaID = GameInfo.UnitPromotions["PROMOTION_MILITIA_COMBAT"].ID

local CarrierSupply3ID = GameInfo.UnitPromotions["PROMOTION_CARRIER_SUPPLY_3"].ID

local SatelliteID = GameInfo.UnitPromotions["PROMOTION_SATELLITE_UNIT"].ID

local LuckyCarrierID = GameInfo.UnitPromotions["PROMOTION_LUCKY_CARRIER"].ID

local ForeignLandsID = GameInfo.UnitPromotions["PROMOTION_FOREIGN_LANDS"].ID

local CorpsID = GameInfo.UnitPromotions["PROMOTION_CORPS_1"].ID
local ArmeeID = GameInfo.UnitPromotions["PROMOTION_CORPS_2"].ID

local CitadelID = GameInfo.UnitPromotions["PROMOTION_CITADEL_DEFENSE"].ID


function DoUnitForceUpgrade(player, unit)
	if not unit or not unit:GetPlot() then return end
	local unitInfo = GameInfo.Units[unit:GetUpgradeUnitType()];
	if not unitInfo or not unitInfo.PrereqTech then return end
	if not player:HasTech(GameInfoTypes[unitInfo.PrereqTech]) then return end
	
	local plot = unit:GetPlot();
	local iUnitType = unit:GetUpgradeUnitType();
	unit:Kill();
	player:InitUnit(iUnitType, plot:GetX(), plot:GetY(), UNITAI_ATTACK);
end
-- Human Player's units rule & AI units assistance
function NewUnitCreationRules(playerID)

	local player = Players[playerID]
	if player == nil or not player:IsAlive()
	or player:IsMinorCiv()
	then
		return
	end

	if player:IsBarbarian() then
		-- Auto Upgrade for Barbarian
		for unit in player:Units() do
			DoUnitForceUpgrade(player, unit)
		end
		return;
	end

	-- Fix Embarked Graphic Reoverride for POLYNESIAN & DANISH when they into ERA_INDUSTRIAL
	if (player:GetEmbarkedGraphicOverride() == "ART_DEF_UNIT_U_POLYNESIAN_WAR_CANOE"
			or player:GetEmbarkedGraphicOverride() == "ART_DEF_UNIT_U_DANISH_LONGBOAT")
		and player:GetCurrentEra() >= GameInfoTypes["ERA_INDUSTRIAL"]
	then
		player:SetEmbarkedGraphicOverride("ART_DEF_UNIT_TRANSPORT");
	end

	local CapCity = player:GetCapitalCity();
	local bAutoPurchase = (player:IsHuman() or PlayerAtWarWithHuman(player) or (Players[Game.GetActivePlayer()]:IsObserver() and not Game.IsGameMultiPlayer()));

	-------------Units Processing!
	-- Initial Cargo List
	g_CargoSetList[playerID] = nil;
	local iTotalCost = 0;
	for unit in player:Units() do
		if unit == nil then
			-- Remove mis-placed units in city
		elseif (unit:GetSpecialUnitType() == GameInfoTypes.SPECIALUNIT_MISSILE
				or unit:GetSpecialUnitType() == GameInfoTypes.SPECIALUNIT_FIGHTER)
		and not unit:IsCargo() then
			unit:Kill();
			print("This unit shoudln't be put without Carrier, so it is removed!");
			-- Remove Temp Units (UAV)
		elseif (unit:GetUnitClassType() == GameInfoTypes.UNITCLASS_UAV) then
			unit:Kill();
			print("UAV Removed!")
			-- Help AI Lanuch Satellites!
		elseif (unit:IsHasPromotion(SatelliteID) and player:GetCurrentEra() >= 6 and CapCity and not player:IsHuman()) then
			SatelliteLaunchEffects(unit, CapCity, player);
			unit:Kill();
			print("AI has built a Satellite Unit!");
		else
			-- MOD Begin by CaptainCWB

			-- Enterprise upgrade to become the most powerful carrier
			if unit:GetUnitClassType() == GameInfoTypes["UNITCLASS_SUPER_CARRIER"] and unit:IsHasPromotion(LuckyCarrierID)
				and not unit:IsHasPromotion(GameInfoTypes["PROMOTION_ADDITIONAL_CARGO_II"])
			then
				unit:SetHasPromotion(GameInfoTypes["PROMOTION_ADDITIONAL_CARGO_II"], true)
			end

			-- Fix mis-placed Citadel Units
			if unit:IsImmobile() 
			and unit:GetBaseCombatStrength() > 0 
			and unit:GetPlot() ~= nil 
			and unit:IsHasPromotion(GameInfoTypes["PROMOTION_CITADEL_DEFENSE"]) 
			then
				local plot = unit:GetPlot();
				if plot:GetImprovementType() ~= GameInfoTypes["IMPROVEMENT_CITADEL"]
					and plot:GetImprovementType() ~= GameInfoTypes["IMPROVEMENT_COASTAL_FORT"]
				then
					if not plot:IsWater() then
						plot:SetImprovementType(GameInfoTypes["IMPROVEMENT_CITADEL"]);
					else
						plot:SetImprovementType(GameInfoTypes["IMPROVEMENT_COASTAL_FORT"]);
					end
					print("Miss-placed Citidal units Fixed!")
				end
			end

			-- Carriers & Cargos Setting System
			local sSpecialCargo   = GameInfo.Units[unit:GetUnitType()].SpecialCargo;
			local sSpecial        = GameInfo.Units[unit:GetUnitType()].Special;
			local creationRandNum = Game.Rand(100,"At NewUnitCreationRules.lua NewUnitCreationRules(), percentage") + 1
			if unit:GetPlot() == nil or not unit:CanMove() then
			-- Cargos Add for AI (Human use Button) & Missile for all
			elseif unit:CargoSpace() > 0 and not unit:IsFull()
				and (sSpecialCargo == "SPECIALUNIT_FIGHTER" or sSpecialCargo == "SPECIALUNIT_MISSILE")
				and (unit:GetPlot():IsFriendlyTerritory(playerID) or unit:IsHasPromotion(CarrierSupply3ID))
			then
				if g_CargoSetList[playerID] == nil then
					SPCargoListSetup(playerID);
				end
				local iCost = -1;

				--AI auto purchase Fighter
				if sSpecialCargo == "SPECIALUNIT_FIGHTER"
				and g_CargoSetList[playerID][1] and g_CargoSetList[playerID][1] ~= -1
				and g_CargoSetList[playerID][4] and g_CargoSetList[playerID][4] ~= -1
				and not player:IsHuman()
				then
					iCost = CarrierRestore(playerID, unit:GetID(), g_CargoSetList[playerID][1]);

				elseif sSpecialCargo == "SPECIALUNIT_MISSILE"
				and bAutoPurchase
				and g_CargoSetList[playerID][2] and g_CargoSetList[playerID][2] ~= -1
				then
					iCost = CarrierRestore(playerID, unit:GetID(), g_CargoSetList[playerID][2]);
				end
				if iCost and iCost > 0 then
					iTotalCost = iTotalCost + iCost
				end
			-- Cargos Update
			elseif unit:IsCargo() and unit:GetTransportUnit()
			-- not for AI
			and player:IsHuman()
			and ((unit:GetTransportUnit():GetUnitType() == GameInfoTypes["UNIT_HORNET"] and creationRandNum < 34)
				or sSpecial == "SPECIALUNIT_FIGHTER" or sSpecial == "SPECIALUNIT_MISSILE")
			and (unit:GetPlot():IsFriendlyTerritory(playerID) or unit:GetTransportUnit():IsHasPromotion(CarrierSupply3ID))
			and GameInfo.Units[unit:GetUpgradeUnitType()] and GameInfo.Units[unit:GetUpgradeUnitType()].PrereqTech
			and Teams[player:GetTeam()]:IsHasTech(GameInfoTypes[GameInfo.Units[unit:GetUpgradeUnitType()].PrereqTech])
			then
				if g_CargoSetList[playerID] == nil then
					SPCargoListSetup(playerID);
				end
				local iCost = CarrierRestore(playerID, unit:GetID(), unit:GetUpgradeUnitType());
				if iCost and iCost > 0 then
					iTotalCost = iTotalCost + iCost
				end
			end

			---------- Human player special Begin
			if player:IsHuman() then
				--Cargo Promotions Transfer
				if unit:GetPlot() ~= nil
					and (sSpecialCargo == "SPECIALUNIT_MISSILE" or sSpecialCargo == "SPECIALUNIT_FIGHTER")
				then
					if unit:IsHasPromotion(AirCraftCarrierID) then
						CarrierPromotionTransfer(player, unit)
						print("Promotions Transfer Finished!")
					end

					if unit:GetUnitType() == GameInfoTypes.UNIT_FRANCE_MISTRAL then
						AASPromotionTransfer(player, unit)
						print("Promotions Transfer Finished on AAS!")
					end
				end
			end
			--------- Human player special END
			-- MOD End   by CaptainCWB
		end
	end -------for units END
	player:ChangeGold(-iTotalCost);
end  ------function end

GameEvents.PlayerTurnStart.Add(NewUnitCreationRules)


-- MOD Begin by CaptainCWB

-- Set Corps & Armee for AI
function OnCorpsArmeeSP(iPlayerID, iUnitID)
	local pPlayer = Players[iPlayerID];
	if pPlayer == nil or pPlayer:GetCapitalCity() == nil
		or pPlayer:GetUnitByID(iUnitID) == nil
		or pPlayer:GetUnitByID(iUnitID):GetPlot() == nil
		or pPlayer:GetUnitByID(iUnitID):IsImmobile()
		or pPlayer:GetUnitByID(iUnitID):IsEmbarked()
		or pPlayer:GetUnitByID(iUnitID):IsHasPromotion(CorpsID)
	then
		return;
	end

	local pUnit = pPlayer:GetUnitByID(iUnitID);
	if pUnit:GetUnitClassType() == GameInfoTypes["UNITCLASS_GREAT_GENERAL"]
		and not pPlayer:IsHuman() and not pUnit:HasMoved()
	-- Set Corps & Armee only for AI land units
	then
		local eUnitList = {};
		local pCUnit = nil;
		for pEUnit in pPlayer:Units() do
			if pEUnit:IsCanBeEstablishedCorps()
				and pEUnit:GetUnitCombatType() ~= GameInfoTypes.UNITCOMBAT_RECON
			then
				table.insert(eUnitList, pEUnit);
			end
		end
		if #eUnitList > 0 then
			local corpsSelectRandNum = Game.Rand(#eUnitList, "At NewUnitCreationRules.lua OnCorpsArmeeSP(), select unit") +
			1
			pCUnit = eUnitList[corpsSelectRandNum];
		end
		if pCUnit == nil then
		elseif pCUnit:IsHasPromotion(CorpsID) then
			pCUnit:SetHasPromotion(ArmeeID, true);
		else
			pCUnit:SetHasPromotion(CorpsID, true);
		end
	end
	if not pUnit:IsCombatUnit() then
		return;
	end

	-- print ("Combat Unit Created!")
	local CapCity            = pPlayer:GetCapitalCity();
	local pPlot              = pUnit:GetPlot();
	local iType              = pUnit:GetUnitType();
	local class              = pUnit:GetUnitClassType();

	-- Establish Corps & Armee for AI
	local DoCombine          = false;
	local otherUnit          = nil;
	local CorpsUnit          = nil;
	local corpsRandNum       = Game.Rand(10, "At NewUnitsRule.lua OnCorpsArmeeSP(), AI spawning corps & armee") + 1
	local iCombineNum 		 = 10 - Game:GetHandicapType()
	if corpsRandNum > iCombineNum
	then
		DoCombine = true;
	end

	if pPlayer:GetUnitClassCount(class) > 5
	and pPlayer:GetNumCropsTotal() > 0
	and not pPlayer:IsHuman()
	and DoCombine
	then
		for unit in pPlayer:Units() do
			-- Armee | Corps
			if unit == nil 
			or unit:IsHasPromotion(ArmeeID) 
			or unit:GetUnitClassType() ~= pUnit:GetUnitClassType() 
			or unit:GetDomainType() ~= DomainTypes.DOMAIN_LAND 
			then
				--jump
			elseif unit:IsHasPromotion(CorpsID) and pPlayer:GetNumArmeeTotal() > 0 then
				CorpsUnit = unit;
			else
				otherUnit = unit;
			end
		end
	end

	local iKillRandNum = Game.Rand(5, "At NewUnitsRule.lua OnCorpsArmeeSP(), AI kill this Unit") + 1
	if CorpsUnit then
		CorpsUnit:SetHasPromotion(ArmeeID, true);
		if iKillRandNum <= iCombineNum then
			pUnit:Kill(true);
		end
		return;
	elseif otherUnit then
		otherUnit:SetHasPromotion(CorpsID, true);
		if iKillRandNum <= iCombineNum then
			pUnit:Kill(true);
		end
		return;
	end

	-- Remove redundance Units
	if pPlayer:GetDomainTroopsActive() < 0
	and not pUnit:IsNoTroops() 
	and not (pUnit:GetLevel() > 1) 
	then
		pUnit:Kill(true);
	end
end
if PreGame.GetGameOption("GAMEOPTION_SP_CORPS_MODE_DISABLE") == 0 then
    GameEvents.UnitCreated.Add(OnCorpsArmeeSP)
end

g_SPCarrierTransferPromotions = {}
for row in GameInfo.SPCarrierTransferPromotions() do
	local CarrierPromotion = GameInfo.UnitPromotions[row.CarrierPromotionType]
	local FighterPromotion = GameInfo.UnitPromotions[row.FighterPromotionType]
	if CarrierPromotion and FighterPromotion then
		g_SPCarrierTransferPromotions[CarrierPromotion.ID] = FighterPromotion.ID
	else
		print("Carrier Transfer Promotion load err:", row.CarrierPromotionType, row.FighterPromotionType)
	end
end
function CarrierPromotionTransfer(player, unit)
	local plot = unit:GetPlot();
	if plot and unit:IsHasPromotion(AirCraftCarrierID) and unit:HasCargo() then
		print("Found the carrier!")
		local unitCount = plot:GetNumUnits()

		for i = 0, unitCount - 1, 1 do
			local pCargoUnit = plot:GetUnit(i);
			if pCargoUnit:IsCargo() and pCargoUnit:GetTransportUnit() == unit then
				print("Found the aircraft on the carrier!")
				for CarrierPromotionID, FighterPromotionID in pairs(g_SPCarrierTransferPromotions) do
					pCargoUnit:SetHasPromotion(FighterPromotionID, unit:IsHasPromotion(CarrierPromotionID));
				end
			end
		end
	end
end

function AASPromotionTransfer(player, unit)
	local Sunder1ID = GameInfoTypes["PROMOTION_SUNDER_1"]
	local Sunder2ID = GameInfoTypes["PROMOTION_SUNDER_2"]
	local CollDamageLV1ID = GameInfoTypes["PROMOTION_COLLATERAL_DAMAGE_1"]
	local CollDamageLV2ID = GameInfoTypes["PROMOTION_COLLATERAL_DAMAGE_2"]

	local LogisticsID = GameInfoTypes["PROMOTION_LOGISTICS"]

	local plot = unit:GetPlot();
	if plot and unit:GetUnitType() == GameInfoTypes.UNIT_FRANCE_MISTRAL and unit:HasCargo() then
		print("Found the AAS!")
		local unitCount = plot:GetNumUnits()

		for i = 0, unitCount - 1, 1 do
			local pFoundUnit = plot:GetUnit(i)
			print("Found the aircraft on the AAS!")

			if pFoundUnit:IsCargo() and pFoundUnit:GetUnitType() == GameInfoTypes.UNIT_FRANCE_EUROCOPTER_TIGER and unit:GetUnitType() == GameInfoTypes.UNIT_FRANCE_MISTRAL then
				if unit:IsHasPromotion(Sunder1ID) then
					pFoundUnit:SetHasPromotion(Sunder1ID, true)
					print("Promotion for aircrafts on the carrier!-AntiAir1")
				end
				if unit:IsHasPromotion(Sunder2ID) then
					pFoundUnit:SetHasPromotion(Sunder2ID, true)
					print("Promotion for aircrafts on the carrier!-AntiAir2")
				end
				if unit:IsHasPromotion(CollDamageLV1ID) then
					pFoundUnit:SetHasPromotion(CollDamageLV1ID, true)
				end
				if unit:IsHasPromotion(CollDamageLV2ID) then
					pFoundUnit:SetHasPromotion(CollDamageLV2ID, true)
				end
				if unit:IsHasPromotion(LogisticsID) then
					pFoundUnit:SetHasPromotion(LogisticsID, true)
				end
			end
		end
	end
end

-- MOD by CaptainCWB
function SetEliteUnitsName(iPlayerID, iUnitID)
	if Players[iPlayerID] == nil or not Players[iPlayerID]:IsAlive()
		or Players[iPlayerID]:GetUnitByID(iUnitID) == nil
		or Players[iPlayerID]:GetUnitByID(iUnitID):IsDead()
		or Players[iPlayerID]:GetUnitByID(iUnitID):IsDelayedDeath()
		or Players[iPlayerID]:GetUnitByID(iUnitID):HasName()
	then
		return;
	end
	local pUnit = Players[iPlayerID]:GetUnitByID(iUnitID);
	if pUnit:IsHasPromotion(GameInfoTypes["PROMOTION_ELITE_DEFENSE"]) then
		pUnit:SetName("TXT_KEY_ELITE_NAME_SPARTAN300");   -- Locale.ConvertTextKey("TXT_KEY_ELITE_NAME_SPARTAN300")
	elseif pUnit:IsHasPromotion(GameInfoTypes["PROMOTION_NUMIDIAN_MARCH"]) and pUnit:GetUnitCombatType() == GameInfoTypes.UNITCOMBAT_HELICOPTER then
		pUnit:SetName("TXT_KEY_ELITE_NAME_NUMIDIAN");     -- Locale.ConvertTextKey("TXT_KEY_ELITE_NAME_NUMIDIAN")
	elseif pUnit:IsHasPromotion(GameInfoTypes["PROMOTION_GAIN_MOVES_AFFER_KILLING"]) then
		pUnit:SetName("TXT_KEY_ELITE_NAME_ELITE_RIDER");  -- Locale.ConvertTextKey("TXT_KEY_ELITE_NAME_ELITE_RIDER")
	elseif pUnit:IsHasPromotion(GameInfoTypes["PROMOTION_RANGE_SPECIAL"]) then
		pUnit:SetName("TXT_KEY_ELITE_NAME_ENGLISH_LONGBOWMAN"); -- Locale.ConvertTextKey("TXT_KEY_ELITE_NAME_ENGLISH_LONGBOWMAN")
	elseif pUnit:IsHasPromotion(GameInfoTypes["PROMOTION_SKI_INFANTRY"]) and pUnit:GetUnitClassType() ~= GameInfoTypes.UNITCLASS_MUSKETEER then
		pUnit:SetName("TXT_KEY_ELITE_NAME_DANISH_SKI_INFANTRY"); -- Locale.ConvertTextKey("TXT_KEY_ELITE_NAME_DANISH_SKI_INFANTRY")
	elseif pUnit:GetUnitClassType() == GameInfoTypes.UNITCLASS_PROTOTYPE_HWACHA then
		pUnit:SetName("TXT_KEY_ELITE_NAME_KOREA_HWACHA");  -- Locale.ConvertTextKey("TXT_KEY_ELITE_NAME_KOREA_HWACHA")
	elseif pUnit:GetUnitClassType() == GameInfoTypes.UNITCLASS_PROTOTYPE_SUBMARINE then
		pUnit:SetName("TXT_KEY_ELITE_NAME_PROTOTYPE_SUBMARINE"); -- Locale.ConvertTextKey("TXT_KEY_ELITE_NAME_PROTOTYPE_SUBMARINE")
	elseif pUnit:GetUnitClassType() == GameInfoTypes.UNITCLASS_SUPER_HOWITZER then
		pUnit:SetName("TXT_KEY_ELITE_NAME_SUPER_HOWITZER"); -- Locale.ConvertTextKey("TXT_KEY_ELITE_NAME_SUPER_HOWITZER")
	elseif pUnit:GetUnitClassType() == GameInfoTypes.UNITCLASS_PROTOTYPE_BOMBER then
		pUnit:SetName("TXT_KEY_ELITE_NAME_PROTOTYPE_BOMBER"); -- Locale.ConvertTextKey("TXT_KEY_ELITE_NAME_PROTOTYPE_BOMBER")
		-- "Ville de Paris" is the "Default" Name of HMS First Rate!	--(> w·*)/
	elseif pUnit:GetUnitType() == GameInfoTypes.UNIT_ENGLISH_SHIPOFTHELINE then
		pUnit:SetName("TXT_KEY_ENGLISH_HMS_VILLE"); -- Locale.ConvertTextKey("TXT_KEY_ENGLISH_HMS_VILLE")
	end
end

GameEvents.UnitCreated.Add(SetEliteUnitsName)

function FixWorkerBridge(iPlayerID, iUnitID)
	if (Players[iPlayerID] == nil or not Players[iPlayerID]:IsAlive()
			or Players[iPlayerID]:GetUnitByID(iUnitID) == nil
			or Players[iPlayerID]:GetUnitByID(iUnitID):IsDead()
			or Players[iPlayerID]:GetUnitByID(iUnitID):IsDelayedDeath()
			or Players[iPlayerID]:GetUnitByID(iUnitID):GetPlot() == nil)
		or Players[iPlayerID]:GetUnitByID(iUnitID):GetUnitClassType() ~= GameInfoTypes.UNITCLASS_WORKER
	then
		return;
	end

	local pPlayer = Players[iPlayerID];
	local pUnit   = pPlayer:GetUnitByID(iUnitID);
	local pPlot   = pUnit:GetPlot();

	if pUnit:IsEmbarked() then
		if not pPlot:IsWater() then
			pUnit:SetEmbarked(false);
		elseif pPlot:GetImprovementType() == GameInfoTypes["IMPROVEMENT_PONTOON_BRIDGE_MOD"] then
			for i = 0, pPlot:GetNumUnits() - 1, 1 do
				if pPlot:GetUnit(i) and pPlot:GetUnit(i):GetDomainType() == DomainTypes.DOMAIN_LAND and pPlot:GetUnit(i):IsEmbarked() then
					pPlot:GetUnit(i):SetEmbarked(false);
				end
			end
		end
	elseif pPlot:IsWater() and pPlot:GetImprovementType() ~= GameInfoTypes["IMPROVEMENT_PONTOON_BRIDGE_MOD"] then
		if pPlot:IsRoute() then
			pPlot:SetRouteType(-1);
		end
		for i = 0, pPlot:GetNumUnits() - 1, 1 do
			if pPlot:GetUnit(i) and pPlot:GetUnit(i):GetDomainType() == DomainTypes.DOMAIN_LAND and not pPlot:GetUnit(i):IsEmbarked() then
				pPlot:GetUnit(i):SetEmbarked(true);
			end
		end
	end
end

--Events.UnitShouldDimFlag.Add(FixWorkerBridge)

print("NewUnitRules Check success!")
