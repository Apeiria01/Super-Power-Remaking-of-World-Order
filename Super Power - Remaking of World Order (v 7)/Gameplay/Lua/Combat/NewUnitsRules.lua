-- NewUnitsRules

--------------------------------------------------------------

include("UtilityFunctions")


local AirCraftCarrierID = GameInfo.UnitPromotions["PROMOTION_CARRIER_UNIT"].ID
local MilitiaID = GameInfo.UnitPromotions["PROMOTION_MILITIA_COMBAT"].ID

local CarrierSupply3ID = GameInfo.UnitPromotions["PROMOTION_CARRIER_SUPPLY_3"].ID

local SatelliteID = GameInfo.UnitPromotions["PROMOTION_SATELLITE_UNIT"].ID

local OceanImpassableID = GameInfo.UnitPromotions["PROMOTION_OCEAN_IMPASSABLE"].ID

local LuckyCarrierID = GameInfo.UnitPromotions["PROMOTION_LUCKY_CARRIER"].ID

local ForeignLandsID = GameInfo.UnitPromotions["PROMOTION_FOREIGN_LANDS"].ID

local CorpsID = GameInfo.UnitPromotions["PROMOTION_CORPS_1"].ID
local ArmeeID = GameInfo.UnitPromotions["PROMOTION_CORPS_2"].ID

local CitadelID = GameInfo.UnitPromotions["PROMOTION_CITADEL_DEFENSE"].ID


-- Human Player's units rule & AI units assistance
function NewUnitCreationRules()
	for playerID, player in pairs(Players) do
		if player and player:IsAlive() and not player:IsMinorCiv() and player:GetNumUnits() > 0 then --  and not player:IsBarbarian() then
			print("Player " .. playerID .. " - Unit Counts: " .. player:GetNumUnits());

			-- Fix Embarked Graphic Reoverride for POLYNESIAN & DANISH when they into ERA_INDUSTRIAL
			if (player:GetEmbarkedGraphicOverride() == "ART_DEF_UNIT_U_POLYNESIAN_WAR_CANOE"
					or player:GetEmbarkedGraphicOverride() == "ART_DEF_UNIT_U_DANISH_LONGBOAT")
				and player:GetCurrentEra() >= GameInfo.Eras["ERA_INDUSTRIAL"].ID
			then
				player:SetEmbarkedGraphicOverride("ART_DEF_UNIT_TRANSPORT");
			end

			-- Troops count - Total
			local CapCity = player:GetCapitalCity();

			-------------Units Processing!
			-- Initial Cargo List
			g_CargoSetList[playerID] = nil;
			for unit in player:Units() do
				if unit == nil then
					-- Fix Possible 0 HP Unit Bug (Temp Method)
				elseif (unit:GetDamage() >= unit:GetMaxHitPoints() or unit:GetCurrHitPoints() <= 0) then
					unit:Kill();
					print("-----------------------BUG Fix-------0HP Unit---------------")
					-- Remove mis-placed units in city
				elseif (unit:GetSpecialUnitType() == GameInfo.SpecialUnits.SPECIALUNIT_MISSILE.ID
						or unit:GetSpecialUnitType() == GameInfo.SpecialUnits.SPECIALUNIT_FIGHTER.ID)
					and not unit:IsCargo()
				then
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
					-- Remove "PROMOTION_OCEAN_IMPASSABLE" for Great Admiral after having "TECH_NAVIGATION"
					if unit:GetUnitClassType() == GameInfo.UnitClasses.UNITCLASS_GREAT_ADMIRAL.ID and unit:IsHasPromotion(OceanImpassableID)
						and Teams[player:GetTeam()]:IsHasTech(GameInfoTypes["TECH_NAVIGATION"])
					then
						unit:SetHasPromotion(OceanImpassableID, false);
					end
					-- MOD Begin by CaptainCWB

					-- Enterprise upgrade to become the most powerful carrier
					if unit:GetUnitClassType() == GameInfoTypes["UNITCLASS_SUPER_CARRIER"] and unit:IsHasPromotion(LuckyCarrierID)
						and not unit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_ADDITIONAL_CARGO_II"].ID)
					then
						unit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_ADDITIONAL_CARGO_II"].ID, true)
					end

					-- Fix mis-placed Citadel Units
					if unit:IsImmobile() and unit:GetBaseCombatStrength() > 0 and unit:GetPlot() ~= nil then
						local plot = unit:GetPlot();
						if plot:GetImprovementType() ~= GameInfo.Improvements["IMPROVEMENT_CITADEL"].ID
							and plot:GetImprovementType() ~= GameInfo.Improvements["IMPROVEMENT_COASTAL_FORT"].ID
						then
							if not plot:IsWater() then
								plot:SetImprovementType(GameInfo.Improvements["IMPROVEMENT_CITADEL"].ID);
							else
								plot:SetImprovementType(GameInfo.Improvements["IMPROVEMENT_COASTAL_FORT"].ID);
							end
							print("Miss-placed Citidal units Fixed!")
						end
					end

					-- Add 2 Movements for Embarked Conquistador
					if unit:GetUnitType() == GameInfoTypes.UNIT_SPANISH_CONQUISTADOR and unit:IsEmbarked() then
						unit:SetMoves(unit:GetMoves() + 2 * GameDefines["MOVE_DENOMINATOR"]);
					end

					-- Carriers & Cargos Setting System
					local sSpecialCargo   = GameInfo.Units[unit:GetUnitType()].SpecialCargo;
					local sSpecial        = GameInfo.Units[unit:GetUnitType()].Special;
					local creationRandNum = Game.Rand(100,
						"At NewUnitCreationRules.lua NewUnitCreationRules(), percentage") + 1
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
						if not player:IsHuman() and not PlayerAtWarWithHuman(player) then
						elseif sSpecialCargo == "SPECIALUNIT_FIGHTER"
							and g_CargoSetList[playerID][1] and g_CargoSetList[playerID][1] ~= -1
							and g_CargoSetList[playerID][4] and g_CargoSetList[playerID][4] ~= -1
							and not player:IsHuman()
						then
							iCost = CarrierRestore(playerID, unit:GetID(), g_CargoSetList[playerID][1]);
						elseif sSpecialCargo == "SPECIALUNIT_MISSILE"
							and g_CargoSetList[playerID][2] and g_CargoSetList[playerID][2] ~= -1
						then
							iCost = CarrierRestore(playerID, unit:GetID(), g_CargoSetList[playerID][2]);
						end
						if iCost and iCost > 0 then
							player:ChangeGold(-iCost);
						end
						-- Cargos Update
					elseif unit:IsCargo() and unit:GetTransportUnit()
						and GameInfo.Units[unit:GetUpgradeUnitType()] and GameInfo.Units[unit:GetUpgradeUnitType()].PrereqTech
						and Teams[player:GetTeam()]:IsHasTech(GameInfoTypes[GameInfo.Units[unit:GetUpgradeUnitType()].PrereqTech])
						and ((unit:GetTransportUnit():GetUnitType() == GameInfoTypes["UNIT_HORNET"] and creationRandNum < 34)
							or sSpecial == "SPECIALUNIT_FIGHTER" or sSpecial == "SPECIALUNIT_MISSILE")
						and (unit:GetPlot():IsFriendlyTerritory(playerID) or unit:GetTransportUnit():IsHasPromotion(CarrierSupply3ID))
						-- not for AI
						and player:IsHuman()
					then
						if g_CargoSetList[playerID] == nil then
							SPCargoListSetup(playerID);
						end
						local iCost = CarrierRestore(playerID, unit:GetID(), unit:GetUpgradeUnitType());
						if iCost and iCost > 0 then
							player:ChangeGold(-iCost);
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
						--------- Human player special END
						-- Auto Upgrade for Barbarian
					elseif player:IsBarbarian() then
						if unit:GetPlot() and GameInfo.Units[unit:GetUpgradeUnitType()] and GameInfo.Units[unit:GetUpgradeUnitType()].PrereqTech
							and Teams[Game.GetActiveTeam()]:IsHasTech(GameInfoTypes[GameInfo.Units[unit:GetUpgradeUnitType()].PrereqTech])
						then
							local plot = unit:GetPlot();
							local iUnitType = unit:GetUpgradeUnitType();
							unit:Kill();
							player:InitUnit(iUnitType, plot:GetX(), plot:GetY(), UNITAI_ATTACK);
						end
						if not unit:IsDead() and not unit:IsDelayedDeath()
							and not unit:IsHasPromotion(ForeignLandsID) and unit:IsHasPromotion(MilitiaID)
						then
							unit:SetHasPromotion(ForeignLandsID, true);
						end
						-- Establish Inquisition for AI
					elseif ((unit:GetSpreadsLeft() > 0 and unit:GetSpreadsLeft() >= GameInfo.Units[unit:GetUnitType()].ReligionSpreads) or GameInfo.Units[unit:GetUnitType()].ProhibitsSpread) and not GameInfo.Units[unit:GetUnitType()].FoundReligion
						and unit:GetPlot() and unit:GetOwner() == unit:GetPlot():GetOwner() and (unit:GetPlot():IsCity() or unit:GetPlot():GetWorkingCity() ~= nil)
					then
						local city = unit:GetPlot():GetPlotCity() or unit:GetPlot():GetWorkingCity();
						if city and city:GetReligiousMajority() == unit:GetReligion() and city:IsCanPurchase(false, false, -1, GameInfoTypes["BUILDING_INQUISITION"], -1, YieldTypes.YIELD_FAITH) then
							local numReligion = 0;
							for religion in GameInfo.Religions("Type <> 'RELIGION_PANTHEON'") do
								if city:GetNumFollowers(religion.ID) > 0 then
									numReligion = numReligion + 1;
								end
								if numReligion > 1 then
									city:SetNumRealBuilding(GameInfoTypes["BUILDING_INQUISITION"], 1);
									unit:Kill();
									break;
								end
							end
						end
					end
					-- MOD End   by CaptainCWB

				end
			end -------for units END
		end ----------if player ~= nil END
	end -------for playerID END
end  ------function end

Events.ActivePlayerTurnStart.Add(NewUnitCreationRules)


-- MOD Begin by CaptainCWB

-- Corps & Armee Manager
G_isSPLoading = true;
function OnSPLoadSkip()
	G_isSPLoading = false;
end

Events.LoadScreenClose.Add(OnSPLoadSkip)

-- Set Corps & Armee for AI
function OnCorpsArmeeSP(iPlayerID, iUnitID)
	if G_isSPLoading or Players[iPlayerID] == nil or Players[iPlayerID]:GetCapitalCity() == nil
		or PreGame.GetGameOption("GAMEOPTION_SP_CORPS_MODE_DISABLE") == 1
		or Players[iPlayerID]:GetUnitByID(iUnitID) == nil
		or Players[iPlayerID]:GetUnitByID(iUnitID):GetPlot() == nil
		or Players[iPlayerID]:GetUnitByID(iUnitID):IsImmobile()
		or Players[iPlayerID]:GetUnitByID(iUnitID):IsEmbarked()
		or Players[iPlayerID]:GetUnitByID(iUnitID):IsHasPromotion(CorpsID)
	then
		return;
	end

	local pPlayer = Players[iPlayerID];
	local pUnit = pPlayer:GetUnitByID(iUnitID);
	if pUnit:GetUnitClassType() == GameInfoTypes["UNITCLASS_GREAT_GENERAL"]
		and not pPlayer:IsHuman() and not pUnit:HasMoved()
	-- Set Corps & Armee only for AI land units
	then
		local eUnitList = {};
		local pCUnit = nil;
		for pEUnit in pPlayer:Units() do
			if pEUnit and pEUnit:GetDomainType() == pUnit:GetDomainType()
				and pEUnit:GetUnitCombatType() ~= GameInfoTypes.UNITCOMBAT_RECON
				and pEUnit:IsCombatUnit() and not pEUnit:IsImmobile()
				and not pEUnit:IsHasPromotion(ArmeeID)
				and pEUnit:GetDomainType() == DomainTypes.DOMAIN_LAND -- SP8.0: Corps & Armee only for land units
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

	local iArsenalClass      = GameInfoTypes["BUILDINGCLASS_ARSENAL"];
	local iMilitaryBaseClass = GameInfoTypes["BUILDINGCLASS_MILITARY_BASE"];

	-- Establish Corps & Armee for AI
	local DoCombine          = false;
	local otherUnit          = nil;
	local CorpsUnit          = nil;
	local Heal1Unit          = nil;
	local Heal2Unit          = nil;
	local Heal3Unit          = nil;
	local corpsRandNum       = Game.Rand(10, "At NewUnitsRule.lua OnCorpsArmeeSP(), AI spawning corps & armee") + 1
	if (Game:GetHandicapType() == 7)
		or (Game:GetHandicapType() == 6 and corpsRandNum > 1)
		or (Game:GetHandicapType() == 5 and corpsRandNum > 2)
		or (Game:GetHandicapType() == 4 and corpsRandNum > 3)
		or (Game:GetHandicapType() == 3 and corpsRandNum > 5)
		or (Game:GetHandicapType() == 2 and corpsRandNum > 7)
		or (Game:GetHandicapType() == 1 and corpsRandNum > 9)
	then
		DoCombine = true;
	end

	if pPlayer:GetUnitClassCount(class) > 1 and not pPlayer:IsHuman() and DoCombine then
		for unit in pPlayer:Units() do
			-- Armee | Corps
			if unit == nil or unit:IsHasPromotion(ArmeeID) or unit:GetUnitClassType() ~= pUnit:GetUnitClassType() then
			elseif unit:IsHasPromotion(CorpsID) and unit:GetDomainType() == DomainTypes.DOMAIN_LAND then
				if pPlayer:GetBuildingClassCount(iMilitaryBaseClass) > 0 then
					CorpsUnit = unit;
				end
			elseif pPlayer:GetBuildingClassCount(iArsenalClass) > 0 and unit:GetDomainType() == DomainTypes.DOMAIN_LAND then
				otherUnit = unit;
			end
			-- Heal
			if unit and unit:GetDamage() >= 30 and unit:GetUnitClassType() == pUnit:GetUnitClassType() and not unit:IsImmobile() and unit:CanMove() then
				if Heal2Unit then
					Heal3Unit = unit;
					break;
				elseif Heal1Unit then
					Heal2Unit = unit;
				else
					Heal1Unit = unit;
				end
			end
		end
	end

	if Heal2Unit or (Heal1Unit and pPlayer:IsLackingTroops()) then
		if Heal1Unit then
			Heal1Unit:ChangeDamage(-30);
			Heal1Unit:SetMoves(math.floor(Heal1Unit:MovesLeft() / (2 * GameDefines["MOVE_DENOMINATOR"])) *
			GameDefines["MOVE_DENOMINATOR"]);
		end
		if Heal2Unit then
			Heal2Unit:ChangeDamage(-30);
			Heal2Unit:SetMoves(math.floor(Heal2Unit:MovesLeft() / (2 * GameDefines["MOVE_DENOMINATOR"])) *
			GameDefines["MOVE_DENOMINATOR"]);
		end
		if Heal3Unit then
			Heal3Unit:ChangeDamage(-30);
			Heal3Unit:SetMoves(math.floor(Heal3Unit:MovesLeft() / (2 * GameDefines["MOVE_DENOMINATOR"])) *
			GameDefines["MOVE_DENOMINATOR"]);
		end
		pUnit:Kill();
		return;
	elseif CorpsUnit then
		CorpsUnit:SetHasPromotion(ArmeeID, true);
		pUnit:Kill();
		return;
	elseif otherUnit then
		otherUnit:SetHasPromotion(CorpsID, true);
		pUnit:Kill();
		return;
	end

	-- Remove redundance Units
	if pPlayer:GetDomainTroopsActive() < 0
	and not pUnit:IsNoTroops() 
	and not (pUnit:GetLevel() > 1) 
	then
		pUnit:Kill();
	end
end

Events.SerialEventUnitCreated.Add(OnCorpsArmeeSP)

function CarrierPromotionTransfer(player, unit)
	local AntiAir1ID = GameInfo.UnitPromotions["PROMOTION_CARRIER_FIGHTER_ANTI_AIR_1"].ID
	local AntiAir2ID = GameInfo.UnitPromotions["PROMOTION_CARRIER_FIGHTER_ANTI_AIR_2"].ID

	local AirFight1ID = GameInfo.UnitPromotions["PROMOTION_CARRIER_FIGHTER_AIRFIGHT_1"].ID
	local AirFight2ID = GameInfo.UnitPromotions["PROMOTION_CARRIER_FIGHTER_AIRFIGHT_2"].ID
	local Attack1ID = GameInfo.UnitPromotions["PROMOTION_CARRIER_FIGHTER_ATTACK_1"].ID
	local Attack2ID = GameInfo.UnitPromotions["PROMOTION_CARRIER_FIGHTER_ATTACK_2"].ID
	local Siege1ID = GameInfo.UnitPromotions["PROMOTION_CARRIER_FIGHTER_SIEGE_1"].ID
	local Siege2ID = GameInfo.UnitPromotions["PROMOTION_CARRIER_FIGHTER_SIEGE_2"].ID
	local SupplyID = GameInfo.UnitPromotions["PROMOTION_CARRIER_SUPPLY_2"].ID
	local SortieID = GameInfo.UnitPromotions["PROMOTION_CARRIER_FIGHTER_SORTIE"].ID

	local GainExpID = GameInfo.UnitPromotions["PROMOTION_GAIN_EXPERIENCE"].ID

	local plot = unit:GetPlot();
	if plot and unit:IsHasPromotion(AirCraftCarrierID) and unit:HasCargo() then
		print("Found the carrier!")
		local unitCount = plot:GetNumUnits()

		for i = 0, unitCount - 1, 1 do
			local pCargoUnit = plot:GetUnit(i);
			if pCargoUnit:IsCargo() and pCargoUnit:GetTransportUnit() == unit then
				print("Found the aircraft on the carrier!")
				pCargoUnit:SetHasPromotion(AirFight1ID, unit:IsHasPromotion(AntiAir1ID));
				pCargoUnit:SetHasPromotion(AirFight2ID, unit:IsHasPromotion(AntiAir2ID));
				pCargoUnit:SetHasPromotion(Attack1ID, unit:IsHasPromotion(Attack1ID));
				pCargoUnit:SetHasPromotion(Attack2ID, unit:IsHasPromotion(Attack2ID));
				pCargoUnit:SetHasPromotion(Siege1ID, unit:IsHasPromotion(Siege1ID));
				pCargoUnit:SetHasPromotion(Siege2ID, unit:IsHasPromotion(Siege2ID));
				pCargoUnit:SetHasPromotion(SupplyID, unit:IsHasPromotion(SupplyID));
				pCargoUnit:SetHasPromotion(SortieID, unit:IsHasPromotion(SortieID));
				pCargoUnit:SetHasPromotion(GainExpID, unit:IsHasPromotion(GainExpID));
				pCargoUnit:SetHasPromotion(CorpsID, unit:IsHasPromotion(CorpsID));
				pCargoUnit:SetHasPromotion(ArmeeID, unit:IsHasPromotion(ArmeeID));
			end
		end
	end
end

function AASPromotionTransfer(player, unit)
	local Sunder1ID = GameInfo.UnitPromotions["PROMOTION_SUNDER_1"].ID
	local Sunder2ID = GameInfo.UnitPromotions["PROMOTION_SUNDER_2"].ID
	local CollDamageLV1ID = GameInfo.UnitPromotions["PROMOTION_COLLATERAL_DAMAGE_1"].ID
	local CollDamageLV2ID = GameInfo.UnitPromotions["PROMOTION_COLLATERAL_DAMAGE_2"].ID

	local LogisticsID = GameInfo.UnitPromotions["PROMOTION_LOGISTICS"].ID

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
				-- if unit:IsHasPromotion(Sunder3ID) then
				-- pFoundUnit:SetHasPromotion(Sunder3ID, true)
				-- end
				if unit:IsHasPromotion(CollDamageLV1ID) then
					pFoundUnit:SetHasPromotion(CollDamageLV1ID, true)
				end
				if unit:IsHasPromotion(CollDamageLV2ID) then
					pFoundUnit:SetHasPromotion(CollDamageLV2ID, true)
				end
				-- if unit:IsHasPromotion(CollDamageLV3ID) then
				-- pFoundUnit:SetHasPromotion(CollDamageLV3ID, true)
				-- end
				if unit:IsHasPromotion(LogisticsID) then
					pFoundUnit:SetHasPromotion(LogisticsID, true)
				end
			end
		end
	end
end

-- MOD Begin by HMS
-----Enterprise Carrier Roll to Generate
function SetHeroicCarrierRoll(iPlayer, iCity, iProject, bGold, bFaith)
	if Players[iPlayer] == nil
		or iProject == nil
		or Players[iPlayer]:GetCityByID(iCity) == nil
	then
		return
	end
	local pPlayer = Players[iPlayer]
	if iProject == GameInfo.Projects["PROJECT_HEROIC_CARRIER"].ID then
		print("Heroic Carrier Project finished")
		local CapitalCity = pPlayer:GetCapitalCity()
		CapitalCity:SetNumRealBuilding(GameInfoTypes["BUILDING_HEROIC_CARRIER_PROJECT"], 1)
		print("Heroic Carrier Project in Capital")
	end
end

GameEvents.CityCreated.Add(SetHeroicCarrierRoll)


function HeroicCarrierRollStart(iTeam1, iTeam2, bWar)
	if iTeam1 == nil or iTeam2 == nil then
		return
	end
	local pTeam1 = Teams[iTeam1]
	local pTeam2 = Teams[iTeam2]
	if not pTeam1:IsAtWar(pTeam2) then
		return
	end
	local CapitalCity = nil
	for playerID, pPlayer in pairs(Players) do
		if pPlayer and pPlayer:IsAlive() and not pPlayer:IsMinorCiv() and not pPlayer:IsBarbarian() then
			CapitalCity = pPlayer:GetCapitalCity()
			if CapitalCity ~= nil and CapitalCity:IsHasBuilding(GameInfoTypes["BUILDING_HEROIC_CARRIER_PROJECT"])
				and (pPlayer:GetTeam() == iTeam1 or pPlayer:GetTeam() == iTeam2) then
				print("The war calls the Heroic Carrier")
				CapitalCity:SetNumRealBuilding(GameInfoTypes["BUILDING_HEROIC_CARRIER_START"], 1)
				CapitalCity:SetNumRealBuilding(GameInfoTypes["BUILDING_HEROIC_CARRIER_PROJECT"], 0)
				print("for next turn")
				return
			end
		end
	end
end

Events.WarStateChanged.Add(HeroicCarrierRollStart)
function HeroicCarrierGenerate(playerID)
	local CapitalCity = nil
	local pPlayer = Players[playerID]
	if pPlayer == nil then
		return
	end
	if pPlayer:IsMinorCiv() or pPlayer:IsBarbarian() then
		return
	end
	CapitalCity = pPlayer:GetCapitalCity()
	if CapitalCity == nil then
		return
	end
	if CapitalCity:IsHasBuilding(GameInfoTypes["BUILDING_HEROIC_CARRIER_START"]) then
		print("HeroicRoll Starts at the capital:" .. CapitalCity:GetName())
		for pUnit in pPlayer:Units() do
			if pUnit:IsHasPromotion(GameInfoTypes["PROMOTION_CARRIER_UNIT"])
				and (pUnit:GetUnitClassType() == GameInfo.UnitClasses.UNITCLASS_CARRIER.ID
					or pUnit:GetUnitClassType() == GameInfo.UnitClasses.UNITCLASS_NUCLEAR_CARRIER.ID)
			then
				local HeroicRoll = Game.Rand(100, "At NewUnitCreationRules.lua HeroicCarrierGenerate(), spawn heroic") +
				1
				--local HeroicRoll = math.random(1, 100)
				print("HeroicRoll:" .. HeroicRoll)
				if HeroicRoll >= 75 then
					local unitType = GameInfoTypes["UNIT_ENTERPRISE"]
					local unitEXP = pUnit:GetExperience()
					local unitAIType = pUnit:GetUnitAIType()
					local unitX = pUnit:GetX()
					local unitY = pUnit:GetY()
					print("unitType ready")
					local NewUnit = pPlayer:InitUnit(unitType, unitX, unitY, unitAIType)
					NewUnit:SetLevel(pUnit:GetLevel())
					NewUnit:SetExperience(unitEXP)
					for unitPromotion in GameInfo.UnitPromotions() do
						local unitPromotionID = unitPromotion.ID
						if pUnit:IsHasPromotion(unitPromotionID)
							and not unitPromotion.LostWithUpgrade
							and not NewUnit:IsHasPromotion(unitPromotionID)
						then
							NewUnit:SetHasPromotion(unitPromotionID, true)
						end
					end
					pUnit:Kill()

					if g_CargoSetList[playerID] == nil then
						SPCargoListSetup(playerID);
					end
					if g_CargoSetList[playerID][1] and g_CargoSetList[playerID][1] ~= -1 then
						for i = 0, 5 do
							if (pPlayer:IsHuman() and pPlayer:IsCanPurchaseAnyCity(false, true, g_CargoSetList[playerID][4], -1, YieldTypes.YIELD_GOLD))
								or not pPlayer:IsHuman()
							then
								local iCost = CarrierRestore(playerID, NewUnit:GetID(), g_CargoSetList[playerID][1]);
								if iCost and iCost > 0 then
									pPlayer:ChangeGold(-iCost);
								end
							end
						end
					end
					CapitalCity:SetNumRealBuilding(GameInfoTypes["BUILDING_HEROIC_CARRIER_START"], 0)
					CapitalCity:SetNumRealBuilding(GameInfoTypes["BUILDING_HEROIC_CARRIER_PROJECT"], 0)
					print("Heroic Carrier Generated!")
					return
				end
			end
		end
	end
end

GameEvents.PlayerDoTurn.Add(HeroicCarrierGenerate)
-- MOD end by HMS

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
	if pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_ELITE_DEFENSE"].ID) then
		pUnit:SetName("TXT_KEY_ELITE_NAME_SPARTAN300");   -- Locale.ConvertTextKey("TXT_KEY_ELITE_NAME_SPARTAN300")
	elseif pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_NUMIDIAN_MARCH"].ID) and pUnit:GetUnitCombatType() == GameInfoTypes.UNITCOMBAT_HELICOPTER then
		pUnit:SetName("TXT_KEY_ELITE_NAME_NUMIDIAN");     -- Locale.ConvertTextKey("TXT_KEY_ELITE_NAME_NUMIDIAN")
	elseif pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GAIN_MOVES_AFFER_KILLING"].ID) then
		pUnit:SetName("TXT_KEY_ELITE_NAME_ELITE_RIDER");  -- Locale.ConvertTextKey("TXT_KEY_ELITE_NAME_ELITE_RIDER")
	elseif pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_RANGE_SPECIAL"].ID) then
		pUnit:SetName("TXT_KEY_ELITE_NAME_ENGLISH_LONGBOWMAN"); -- Locale.ConvertTextKey("TXT_KEY_ELITE_NAME_ENGLISH_LONGBOWMAN")
	elseif pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_SKI_INFANTRY"].ID) and pUnit:GetUnitClassType() ~= GameInfoTypes.UNITCLASS_MUSKETEER then
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

Events.SerialEventUnitCreated.Add(SetEliteUnitsName)

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
		elseif pPlot:GetImprovementType() == GameInfo.Improvements["IMPROVEMENT_PONTOON_BRIDGE_MOD"].ID then
			for i = 0, pPlot:GetNumUnits() - 1, 1 do
				if pPlot:GetUnit(i) and pPlot:GetUnit(i):GetDomainType() == DomainTypes.DOMAIN_LAND and pPlot:GetUnit(i):IsEmbarked() then
					pPlot:GetUnit(i):SetEmbarked(false);
				end
			end
		end
	elseif pPlot:IsWater() and pPlot:GetImprovementType() ~= GameInfo.Improvements["IMPROVEMENT_PONTOON_BRIDGE_MOD"].ID then
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

Events.UnitShouldDimFlag.Add(FixWorkerBridge)

print("NewUnitRules Check success!")
