-- NewUnitsRules

--------------------------------------------------------------

--include( "UtilityFunctions.lua" )


g_CorpsCount = {};


local AirCraftCarrierID = GameInfo.UnitPromotions["PROMOTION_CARRIER_UNIT"].ID
local FlagShipID = GameInfo.UnitPromotions["PROMOTION_NAVAL_CAPITAL_SHIP"].ID
local AoeID = GameInfo.UnitPromotions["PROMOTION_SPLASH_DAMAGE"].ID
local SiegeID = GameInfo.UnitPromotions["PROMOTION_CITY_SIEGE"].ID
local MilitiaID = GameInfo.UnitPromotions["PROMOTION_MILITIA_COMBAT"].ID

local CarrierSupply3ID = GameInfo.UnitPromotions["PROMOTION_CARRIER_SUPPLY_3"].ID
local DroneReleasedID = GameInfo.UnitPromotions["PROMOTION_DRONE_RELEASED"].ID

local SatelliteID = GameInfo.UnitPromotions["PROMOTION_SATELLITE_UNIT"].ID

local OceanImpassableID = GameInfo.UnitPromotions["PROMOTION_OCEAN_IMPASSABLE"].ID
local Penetration1ID = GameInfo.UnitPromotions["PROMOTION_PENETRATION_1"].ID
local Penetration2ID = GameInfo.UnitPromotions["PROMOTION_PENETRATION_2"].ID
local SlowDown1ID = GameInfo.UnitPromotions["PROMOTION_MOVEMENT_LOST_1"].ID
local SlowDown2ID = GameInfo.UnitPromotions["PROMOTION_MOVEMENT_LOST_2"].ID
local MoralWeaken1ID = GameInfo.UnitPromotions["PROMOTION_MORAL_WEAKEN_1"].ID
local MoralWeaken2ID = GameInfo.UnitPromotions["PROMOTION_MORAL_WEAKEN_2"].ID
local LoseSupplyID = GameInfo.UnitPromotions["PROMOTION_LOSE_SUPPLY"].ID
local RangeBanID = GameInfo.UnitPromotions["PROMOTION_RANGE_BAN"].ID
local Damage1ID = GameInfo.UnitPromotions["PROMOTION_DAMAGE_1"].ID
local Damage2ID = GameInfo.UnitPromotions["PROMOTION_DAMAGE_2"].ID
local MovetoAdjOnlyID = GameInfo.UnitPromotions["PROMOTION_MOVE_TO_ADJUST_ONLY"].ID
local MovetoAdjOnly1ID = GameInfo.UnitPromotions["PROMOTION_MOVE_TO_ADJUST_ONLY_MARK_I"].ID
local MovetoAdjOnly2ID = GameInfo.UnitPromotions["PROMOTION_MOVE_TO_ADJUST_ONLY_MARK_II"].ID
local MovetoAdjOnly3ID = GameInfo.UnitPromotions["PROMOTION_MOVE_TO_ADJUST_ONLY_MARK_III"].ID
local MovetoAdjOnly4ID = GameInfo.UnitPromotions["PROMOTION_MOVE_TO_ADJUST_ONLY_MARK_IV"].ID

local LuckyCarrierID = GameInfo.UnitPromotions["PROMOTION_LUCKY_CARRIER"].ID
local RapidMarchID = GameInfo.UnitPromotions["PROMOTION_RAPID_MARCH"].ID
local MarkedTargetID = GameInfo.UnitPromotions["PROMOTION_MARKED_TARGET"].ID
local ClearShot3ID = GameInfo.UnitPromotions["PROMOTION_TRAGET_CLEARSHOOT_III"].ID

local LegionGroupID = GameInfo.UnitPromotions["PROMOTION_LEGION_GROUP"].ID

local BlackBirdID = GameInfo.UnitPromotions["PROMOTION_BLACKBIRD_RECON"].ID
local LuckyEID = GameInfo.UnitPromotions["PROMOTION_LUCKYE"].ID
local NoLuckID = GameInfo.UnitPromotions["PROMOTION_NO_LUCK"].ID
local NewlyCapturedID = GameInfo.UnitPromotions["PROMOTION_NEWLYCAPTURED"].ID
local GeneralSID = GameInfo.UnitPromotions["PROMOTION_GENERAL_STACKING"].ID
local SetUpID = GameInfo.UnitPromotions["PROMOTION_MUST_SET_UP"].ID
local ForeignLandsID = GameInfo.UnitPromotions["PROMOTION_FOREIGN_LANDS"].ID
local ExtraRSID = GameInfo.UnitPromotions["PROMOTION_EXTRA_RELIGION_SPREADS"].ID

local CorpsID = GameInfo.UnitPromotions["PROMOTION_CORPS_1"].ID
local ArmeeID = GameInfo.UnitPromotions["PROMOTION_CORPS_2"].ID


function NewUnitCreationRules()   ------------------------Human Player's units rule & AI units assistance--
	
	local iTurnTrigger = 10;
	local iTurnsElapsed = Game.GetElapsedGameTurns();
	local IsTimetoCheckPromotion = false;
	if iTurnsElapsed % iTurnTrigger == 9 then
		IsTimetoCheckPromotion = true;
		print ("It's Time to Check Unit Promotion");
	end
	
	for playerID,player in pairs(Players) do
		
		if player and player:IsAlive() and not player:IsMinorCiv() and player:GetNumUnits() > 0 then --  and not player:IsBarbarian() then
			print("Player " .. playerID .. " - Unit Counts: " .. player:GetNumUnits());

			-- Fix Embarked Graphic Reoverride for POLYNESIAN & DANISH when they into ERA_INDUSTRIAL
			if (player:GetEmbarkedGraphicOverride() == "ART_DEF_UNIT_U_POLYNESIAN_WAR_CANOE"
			or  player:GetEmbarkedGraphicOverride() == "ART_DEF_UNIT_U_DANISH_LONGBOAT")
			and player:GetCurrentEra() >= GameInfo.Eras["ERA_INDUSTRIAL"].ID
			then
				player:SetEmbarkedGraphicOverride("ART_DEF_UNIT_TRANSPORT");
			end
			
			-- Troops count - Total
			local CapCity = player:GetCapitalCity();
			local iTotalTroops = 0;
			local iUsedTroops = 0
			if CapCity then
				iTotalTroops = player:GetBuildingClassCount(GameInfoTypes["BUILDINGCLASS_CITY_SIZE_SMALL"])
				             + player:GetBuildingClassCount(GameInfoTypes["BUILDINGCLASS_CITY_SIZE_MEDIUM"])
				             + player:GetBuildingClassCount(GameInfoTypes["BUILDINGCLASS_CITY_SIZE_LARGE"])
				             + player:GetBuildingClassCount(GameInfoTypes["BUILDINGCLASS_CITY_SIZE_XL"])
				             + player:GetBuildingClassCount(GameInfoTypes["BUILDINGCLASS_CITY_SIZE_XXL"])
				             + player:GetBuildingClassCount(GameInfoTypes["BUILDINGCLASS_CITY_SIZE_GLOBAL"]);
				if player:IsHuman() then
					iTotalTroops = iTotalTroops + 6;
				else
					iTotalTroops = iTotalTroops + 8;
				end
			end
			
	-------------Units Processing!
			-- Initial Cargo List
			g_CargoSetList[playerID] = nil;
			g_CorpsCount[playerID] = {0,0,nil,nil,nil};
			for unit in player:Units() do
				-- Troops count - Used
				if unit and unit:IsCombatUnit() and not unit:IsImmobile() then
					iUsedTroops = iUsedTroops + 1;
					if unit:IsHasPromotion(CorpsID) and GameInfo.Unit_FreePromotions{ UnitType = GameInfo.Units[unit:GetUnitType()].Type, PromotionType = "PROMOTION_CORPS_1" }() == nil then
						g_CorpsCount[playerID][1] = g_CorpsCount[playerID][1] + 1;
					end
					if unit:IsHasPromotion(ArmeeID) and GameInfo.Unit_FreePromotions{ UnitType = GameInfo.Units[unit:GetUnitType()].Type, PromotionType = "PROMOTION_CORPS_2" }() == nil then
						g_CorpsCount[playerID][2] = g_CorpsCount[playerID][2] + 1;
					end
				end
				
				if      unit == nil then
				
				-- Fix Possible 0 HP Unit Bug (Temp Method)
				elseif (unit:GetDamage() >= unit:GetMaxHitPoints() or unit:GetCurrHitPoints() <= 0) then
					unit:Kill();
					print ("-----------------------BUG Fix-------0HP Unit---------------")
				-- Remove mis-placed units in city
				elseif (unit:GetSpecialUnitType() == GameInfo.SpecialUnits.SPECIALUNIT_MISSILE.ID
				or      unit:GetSpecialUnitType() == GameInfo.SpecialUnits.SPECIALUNIT_FIGHTER.ID)
				and not unit:IsCargo()
				then
					unit:Kill();
					print ("This unit shoudln't be put without Carrier, so it is removed!");
				-- Remove Temp Units (UAV)
				elseif (unit:GetUnitClassType() == GameInfoTypes.UNITCLASS_UAV) then
					unit:Kill();
					print ("UAV Removed!")
				-- Help AI Lanuch Satellites!
				elseif (unit:IsHasPromotion(SatelliteID) and player:GetCurrentEra() >= 6 and CapCity and not player:IsHuman()) then
					SatelliteLaunchEffects(unit,CapCity,player);
					unit:Kill();
					print ("AI has built a Satellite Unit!");
				else
					-- Remove "PROMOTION_OCEAN_IMPASSABLE" for Great Admiral after having "TECH_NAVIGATION"
					if unit:GetUnitClassType() == GameInfo.UnitClasses.UNITCLASS_GREAT_ADMIRAL.ID and unit:IsHasPromotion(OceanImpassableID)
					and Teams[player:GetTeam()]:IsHasTech(GameInfoTypes["TECH_NAVIGATION"])
					then
						unit:SetHasPromotion(OceanImpassableID, false);
					end
					
					-- Remove error promotion
					if IsTimetoCheckPromotion then
						RemoveErrorPromotion(playerID,unit:GetID())
					end
					
					-- MOD Begin by CaptainCWB
					
					-- Romve Temp promotion
					if unit:IsHasPromotion(MovetoAdjOnlyID) then
						unit:SetHasPromotion(MovetoAdjOnlyID,false);
					end
					if unit:IsHasPromotion(MovetoAdjOnly1ID) then
						unit:SetHasPromotion(MovetoAdjOnly1ID,false);
					end
					if unit:IsHasPromotion(MovetoAdjOnly2ID) then
						unit:SetHasPromotion(MovetoAdjOnly2ID,false);
					end
					if unit:IsHasPromotion(MovetoAdjOnly3ID) then
						unit:SetHasPromotion(MovetoAdjOnly3ID,false);
					end
					if unit:IsHasPromotion(MovetoAdjOnly4ID) then
						unit:SetHasPromotion(MovetoAdjOnly4ID,false);
					end
					if unit:IsHasPromotion(DroneReleasedID) then
						unit:SetHasPromotion(DroneReleasedID, false)
					end
					--Restore form Temp Effects
					if unit:IsHasPromotion(RapidMarchID) or unit:IsHasPromotion(MarkedTargetID)
					or unit:IsHasPromotion(ClearShot3ID) or unit:IsHasPromotion(LegionGroupID)
					or unit:IsHasPromotion(BlackBirdID)  or unit:IsHasPromotion(LuckyEID)
					or unit:IsHasPromotion(NoLuckID)     or unit:IsHasPromotion(NewlyCapturedID)
					then
						unit:SetHasPromotion(RapidMarchID,false);
						unit:SetHasPromotion(MarkedTargetID,false);
						unit:SetHasPromotion(ClearShot3ID,false);
						unit:SetHasPromotion(LegionGroupID,false);
						unit:SetHasPromotion(BlackBirdID,false);
						unit:SetHasPromotion(LuckyEID,false);
						unit:SetHasPromotion(NoLuckID,false);
						unit:SetHasPromotion(NewlyCapturedID,false);
					end
					---- Restore from Debuff Effects -- Repair the loopholes
					if unit:IsHasPromotion(Penetration1ID) or unit:IsHasPromotion(SlowDown1ID)
					or unit:IsHasPromotion(MoralWeaken1ID) or unit:IsHasPromotion(LoseSupplyID)
					or unit:IsHasPromotion(Damage1ID)
					then	-- Remove Debuff
						local CurrHP = unit:GetCurrHitPoints();
						local MaxHP  = unit:GetMaxHitPoints();
						if (CurrHP == MaxHP) then
							unit:SetHasPromotion(Penetration1ID, false);
							unit:SetHasPromotion(Penetration2ID, false);
							unit:SetHasPromotion(SlowDown1ID, false);
							unit:SetHasPromotion(SlowDown2ID, false);
							unit:SetHasPromotion(MoralWeaken1ID, false);
							unit:SetHasPromotion(MoralWeaken2ID, false);
							unit:SetHasPromotion(LoseSupplyID, false);
							unit:SetHasPromotion(Damage1ID, false);
							unit:SetHasPromotion(Damage2ID, false);
						end
					end
					
					-- Enterprise upgrade to become the most powerful carrier
					if unit:GetUnitClassType() == GameInfoTypes["UNITCLASS_SUPER_CARRIER"] and unit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_LUCKY_CARRIER"].ID)
					and not unit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_ADDITIONAL_CARGO_II"].ID)
					then
						unit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_ADDITIONAL_CARGO_II"].ID,true) 
					end
					
					-- Fix mis-placed Citadel Units
					if unit:IsImmobile() and unit:GetBaseCombatStrength() > 0 and unit:GetPlot() ~= nil then
						local plot = unit:GetPlot();
						if  plot:GetImprovementType() ~= GameInfo.Improvements["IMPROVEMENT_CITADEL"].ID
						and plot:GetImprovementType() ~= GameInfo.Improvements["IMPROVEMENT_COASTAL_FORT"].ID
						then
							if not plot:IsWater() then
								plot:SetImprovementType(GameInfo.Improvements["IMPROVEMENT_CITADEL"].ID);
							else
								plot:SetImprovementType(GameInfo.Improvements["IMPROVEMENT_COASTAL_FORT"].ID);
							end
							print ("Miss-placed Citidal units Fixed!")
						end
					end
					
					-- Help AI Use melee attack
					if(unit:GetUnitCombatType()== GameInfoTypes.UNITCOMBAT_HELICOPTER or unit:GetUnitCombatType()== GameInfoTypes.UNITCOMBAT_MELEE)
					and unit:GetBaseRangedCombatStrength() > 0 and not player:IsHuman()
					then
						if unit:GetNumEnemyUnitsAdjacent(unit) > 0 then
							unit:SetHasPromotion(RangeBanID, true);
						else
							unit:SetHasPromotion(RangeBanID, false);
						end
					end
					
					-- Add 2 Movements for Embarked Conquistador
					if unit:GetUnitType() == GameInfoTypes.UNIT_SPANISH_CONQUISTADOR and unit:IsEmbarked() then
						unit:SetMoves(unit:GetMoves() + 2*GameDefines["MOVE_DENOMINATOR"]);
					end
					
					-- Carriers & Cargos Setting System
					local sSpecialCargo = GameInfo.Units[unit:GetUnitType()].SpecialCargo;
					local sSpecial      = GameInfo.Units[unit:GetUnitType()].Special;
					local creationRandNum = Game.Rand(100, "At NewUnitCreationRules.lua NewUnitCreationRules(), percentage") + 1
					if     unit:GetPlot() == nil or not unit:CanMove() then
					-- Cargos Add for AI (Human use Button) & Missile for all
					elseif unit:CargoSpace() > 0 and not unit:IsFull()
					and ( sSpecialCargo == "SPECIALUNIT_FIGHTER" or sSpecialCargo == "SPECIALUNIT_MISSILE" )
					and (  unit:GetPlot():IsFriendlyTerritory(playerID) or unit:IsHasPromotion(CarrierSupply3ID) )
					then
						if g_CargoSetList[playerID] == nil then
							SPCargoListSetup(playerID);
						end
						local iCost = -1;
						if  not player:IsHuman() and not PlayerAtWarWithHuman(player) then
						elseif sSpecialCargo == "SPECIALUNIT_FIGHTER"
						and g_CargoSetList[playerID][1] and g_CargoSetList[playerID][1] ~= -1
						and g_CargoSetList[playerID][4] and g_CargoSetList[playerID][4] ~= -1
						and not player:IsHuman()
						then
							iCost = CarrierRestore(playerID,unit:GetID(),g_CargoSetList[playerID][1]);
						elseif sSpecialCargo == "SPECIALUNIT_MISSILE"
						and g_CargoSetList[playerID][2] and g_CargoSetList[playerID][2] ~= -1
						then
							iCost = CarrierRestore(playerID,unit:GetID(),g_CargoSetList[playerID][2]);
						end
						if iCost and iCost > 0 then
							player:ChangeGold(-iCost);
						end
					-- Cargos Update
					elseif unit:IsCargo() and unit:GetTransportUnit()
					and GameInfo.Units[unit:GetUpgradeUnitType()] and GameInfo.Units[unit:GetUpgradeUnitType()].PrereqTech
					and Teams[player:GetTeam()]:IsHasTech(GameInfoTypes[GameInfo.Units[unit:GetUpgradeUnitType()].PrereqTech])
					and ( (unit:GetTransportUnit():GetUnitType() == GameInfoTypes["UNIT_HORNET"] and creationRandNum < 34)
					or sSpecial == "SPECIALUNIT_FIGHTER" or sSpecial == "SPECIALUNIT_MISSILE" )
					and (  unit:GetPlot():IsFriendlyTerritory(playerID) or unit:GetTransportUnit():IsHasPromotion(CarrierSupply3ID) )
					    -- not for AI
					and player:IsHuman()
					then
						if g_CargoSetList[playerID] == nil then
							SPCargoListSetup(playerID);
						end
						local iCost = CarrierRestore(playerID,unit:GetID(),unit:GetUpgradeUnitType());
						if iCost and iCost > 0 then
							player:ChangeGold(-iCost);
						end
					end

					---------- Human player special Begin
					if     player:IsHuman() then
						--Cargo Promotions Transfer
						if unit:GetPlot() ~= nil
						and(sSpecialCargo == "SPECIALUNIT_MISSILE" or sSpecialCargo == "SPECIALUNIT_FIGHTER")
						then
						    if unit:IsHasPromotion(AirCraftCarrierID) then
							CarrierPromotionTransfer(player,unit)
							print ("Promotions Transfer Finished!") 
						    end
						    
						    if unit:GetUnitType() == GameInfoTypes.UNIT_FRANCE_MISTRAL then
							AASPromotionTransfer(player,unit) 
							print ("Promotions Transfer Finished on AAS!") 
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
						if  not unit:IsDead() and not unit:IsDelayedDeath()
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
					
					
					--------Special for AI	------Cause CTD!!!!!
--					if not player:IsHuman() and PlayerAtWarWithHuman(player) then	
--						
--						
--						------------------------AI Force Intercept
--						if unit:GetDomainType() == DomainTypes.DOMAIN_AIR and unit:CurrInterceptionProbability()> 0 then
--							unit:SetMoves(2*GameDefines["MOVE_DENOMINATOR"])
--							unit:SetMadeInterception (false)
--							unit:PushMission(GameInfoTypes.MISSION_AIRPATROL)
--							print ("AI fighter intercepting!")
--						end
--						
					------------------------AI generate Escorts -------Cause CTD, disabled!
--						if PlayerAtWarWithHuman(player) and player:GetNumResourceAvailable(GameInfoTypes["RESOURCE_IRON"],true) >= 3 then
--							if unit:IsHasPromotion(CarrierID) or unit:IsHasPromotion(FlagShipID) or unit:IsHasPromotion(AoeID) or unit:IsHasPromotion(SiegeID) then
--							
--								if plot ~= nil and not PlotIsVisibleToHuman(plot) then
--									if unit:IsHasPromotion(SiegeID) and plot:GetNumUnits() < 2 then
--										AIForceBuildLandCounterUnits (plot:GetX(), plot:GetY(), player)
--										print ("Create escort units for AI siege Units!")
--									end
--									if unit:IsHasPromotion(AoeID) and plot:GetNumUnits() < 2 then
--										AIForceBuildInfantryUnits (plot:GetX(), plot:GetY(), player)
--										print ("Create escort units for AI AoE Units!")
--									end
--									if unit:IsHasPromotion(FlagShipID) and plot:GetNumUnits() < 2 then
--										AIForceBuildNavalEscortUnits (plot:GetX(), plot:GetY(), player)
--										AIForceBuildNavalHRUnits (plot:GetX(), plot:GetY(), player)
--										print ("Create escort ships for AI flagships!")
--									end
--							
--									if unit:IsHasPromotion(CarrierID) and plot:GetNumUnits() < 3 then
--										AIForceBuildNavalEscortUnits (plot:GetX(), plot:GetY(), player)
--										AIForceBuildNavalHRUnits (plot:GetX(), plot:GetY(), player)
--										AIForceBuildNavalRangedUnits (plot:GetX(), plot:GetY(), player)
--										print ("Create escort ships for AI carriers!")
--									end
--								end
--							end
--						end
						
--					end--------Special for AI END
				end
				
				
				
				
				
			end-------for units END
			
			-- Troops count - Set
			if     PreGame.GetGameOption("GAMEOPTION_SP_CORPS_MODE_HIGH") == 1 then
				iTotalTroops = iTotalTroops * 4;
			elseif PreGame.GetGameOption("GAMEOPTION_SP_CORPS_MODE_MEDIUM") == 1 then
				iTotalTroops = iTotalTroops * 2;
			elseif PreGame.GetGameOption("GAMEOPTION_SP_CORPS_MODE_LOW") == 1 then
				iTotalTroops = iTotalTroops * 1;
			else
				iTotalTroops = 0;
			end
			if iTotalTroops < iUsedTroops then
				iUsedTroops = iTotalTroops;
			end
			if CapCity then
				if CapCity:GetNumBuilding(GameInfoTypes["BUILDING_TROOPS"]) ~= iTotalTroops then
					CapCity:SetNumRealBuilding(GameInfoTypes["BUILDING_TROOPS"], iTotalTroops);
				end
				if CapCity:GetNumBuilding(GameInfoTypes["BUILDING_TROOPS_USED"]) ~= iUsedTroops then
					CapCity:SetNumRealBuilding(GameInfoTypes["BUILDING_TROOPS_USED"], iUsedTroops);
				end
				if iTotalTroops > 0 then
				    if iTotalTroops > iUsedTroops then
					CapCity:SetNumRealBuilding(GameInfoTypes["BUILDING_TROOPS_DEBUFF"], 0);
				    else
					CapCity:SetNumRealBuilding(GameInfoTypes["BUILDING_TROOPS_DEBUFF"], 1);
				    end
				end
			end
		end	----------if player ~= nil END
		
			
	end-------for playerID END
end------function end
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
	or Players[iPlayerID]:CountNumBuildings(GameInfoTypes["BUILDING_TROOPS"]) == 0
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
			if  pEUnit and pEUnit:GetDomainType() == pUnit:GetDomainType()
				and pEUnit:GetUnitCombatType() ~= GameInfoTypes.UNITCOMBAT_RECON
				and pEUnit:IsCombatUnit() and not pEUnit:IsImmobile()
				and not pEUnit:IsHasPromotion(ArmeeID)
				and pEUnit.GetDomainType() == DomainTypes.DOMAIN_LAND -- SP8.0: Corps & Armee only for land units
			then
				table.insert(eUnitList, pEUnit);
			end
		end
		if #eUnitList > 0 then
			local corpsSelectRandNum = Game.Rand(#eUnitList, "At NewUnitCreationRules.lua OnCorpsArmeeSP(), select unit") + 1
			pCUnit = eUnitList[corpsSelectRandNum];
		end
		if     pCUnit == nil then
		elseif pCUnit:IsHasPromotion(CorpsID) then
			pCUnit:SetHasPromotion(ArmeeID, true);
			if g_CorpsCount[iPlayerID] then
				g_CorpsCount[iPlayerID][2] = g_CorpsCount[iPlayerID][2] + 1;
			end
		else
			pCUnit:SetHasPromotion(CorpsID, true);
			if g_CorpsCount[iPlayerID] then
				g_CorpsCount[iPlayerID][1] = g_CorpsCount[iPlayerID][1] + 1;
			end
		end
	end
	if not pUnit:IsCombatUnit() then
		return;
	end

	-- print ("Combat Unit Created!")
	local CapCity = pPlayer:GetCapitalCity();
	local pPlot = pUnit:GetPlot();
	local iType = pUnit:GetUnitType();
	local class = pUnit:GetUnitClassType();
	
	local iTotalTroops = CapCity:GetNumBuilding(GameInfoTypes["BUILDING_TROOPS"]);
	local iUsedTroops  = CapCity:GetNumBuilding(GameInfoTypes["BUILDING_TROOPS_USED"]);
	
	local iArsenalClass = GameInfoTypes["BUILDINGCLASS_ARSENAL"];
	local iMilitaryBaseClass = GameInfoTypes["BUILDINGCLASS_MILITARY_BASE"];
	
	-- Establish Corps & Armee for AI
	local DoCombine = false;
	local otherUnit = nil;
	local CorpsUnit = nil;
	local Heal1Unit = nil;
	local Heal2Unit = nil;
	local Heal3Unit = nil;
	local corpsRandNum = Game.Rand(10, "At NewUnitsRule.lua OnCorpsArmeeSP(), AI spawning corps & armee") + 1
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
			    if     Heal2Unit then
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
	
	if     Heal2Unit or (Heal1Unit and pPlayer:CountNumBuildings(GameInfoTypes["BUILDING_TROOPS_DEBUFF"]) > 0) then
		if Heal1Unit then
			Heal1Unit:ChangeDamage(-30);
			Heal1Unit:SetMoves( math.floor(Heal1Unit:MovesLeft()/(2*GameDefines["MOVE_DENOMINATOR"]))*GameDefines["MOVE_DENOMINATOR"] );
		end
		if Heal2Unit then
			Heal2Unit:ChangeDamage(-30);
			Heal2Unit:SetMoves( math.floor(Heal2Unit:MovesLeft()/(2*GameDefines["MOVE_DENOMINATOR"]))*GameDefines["MOVE_DENOMINATOR"] );
		end
		if Heal3Unit then
			Heal3Unit:ChangeDamage(-30);
			Heal3Unit:SetMoves( math.floor(Heal3Unit:MovesLeft()/(2*GameDefines["MOVE_DENOMINATOR"]))*GameDefines["MOVE_DENOMINATOR"] );
		end
		pUnit:Kill();
		return;
	elseif CorpsUnit then
		CorpsUnit:SetHasPromotion(ArmeeID, true);
		pUnit:Kill();
		if g_CorpsCount[iPlayerID] then
			g_CorpsCount[iPlayerID][2] = g_CorpsCount[iPlayerID][2] + 1;
		end
		return;
	elseif otherUnit then
		otherUnit:SetHasPromotion(CorpsID, true);
		pUnit:Kill();
		if g_CorpsCount[iPlayerID] then
			g_CorpsCount[iPlayerID][1] = g_CorpsCount[iPlayerID][1] + 1;
		end
		return;
	end
	
	-- Remove redundance Units
	if (not pUnit:CanMove() and not pPlot:IsCity()) or pUnit:GetLevel() > 1 then
	elseif pPlayer:CountNumBuildings(GameInfoTypes["BUILDING_TROOPS_DEBUFF"]) > 0 then
		pUnit:Kill();
	else
		iUsedTroops = math.min(iUsedTroops + 1, iTotalTroops);
		CapCity:SetNumRealBuilding(GameInfoTypes["BUILDING_TROOPS_USED"], iUsedTroops);
		if iUsedTroops == iTotalTroops then
			CapCity:SetNumRealBuilding(GameInfoTypes["BUILDING_TROOPS_DEBUFF"], 1);
		end
	end
end
Events.SerialEventUnitCreated.Add(OnCorpsArmeeSP)

-- Citadel Manager
local CitadelList = {};
function OnCitadelCreatSP(iPlayerID, iUnitID)
	if Players[iPlayerID] == nil or Players[iPlayerID]:GetUnitByID(iUnitID) == nil
	or not Players[iPlayerID]:GetUnitByID(iUnitID):IsImmobile()
	or Players[iPlayerID]:GetUnitByID(iUnitID):GetBaseCombatStrength() == 0
	or Players[iPlayerID]:GetUnitByID(iUnitID):GetPlot() == nil
	then
		return;
	end
	-- print ("Citadel Created!")
	local pUnit = Players[iPlayerID]:GetUnitByID(iUnitID);
	local pPlot = pUnit:GetPlot();
	
	table.insert(CitadelList, {iPlayerID, iUnitID, pPlot});
	if not pPlot:IsWater() then
		pPlot:SetImprovementType(GameInfo.Improvements["IMPROVEMENT_CITADEL"].ID);
	else
		pPlot:SetImprovementType(GameInfo.Improvements["IMPROVEMENT_COASTAL_FORT"].ID);
	end
end
Events.SerialEventUnitCreated.Add(OnCitadelCreatSP)
function OnCitadelDestroyedSP(iPlayerID, iUnitID)
	for loop, citadelUnit in pairs(CitadelList) do
		if iPlayerID == citadelUnit[1] and iUnitID == citadelUnit[2] and citadelUnit[3] ~= nil then
			print ("Citadel Destroyed!")
			local pPlot = citadelUnit[3];
			
			table.remove(CitadelList, loop)
			pPlot:SetImprovementType(-1);
			break;
		end
	end
end
Events.SerialEventUnitDestroyed.Add(OnCitadelDestroyedSP)

-- Disembark Unit will get 1 movement at least
function SPDisembarkUnit(iPlayerID, iUnitID)
	if Players[iPlayerID] == nil or Players[iPlayerID]:GetUnitByID(iUnitID) == nil
	or Players[iPlayerID]:GetUnitByID(iUnitID):IsEmbarked()
	or Players[iPlayerID]:GetUnitByID(iUnitID):IsDead()
	or Players[iPlayerID]:GetUnitByID(iUnitID):IsDelayedDeath()
	then
		return;
	end
	local pUnit = Players[iPlayerID]:GetUnitByID(iUnitID);
	if not pUnit:CanMove() then
		pUnit:SetMoves(GameDefines["MOVE_DENOMINATOR"]);
	end
end
Events.UnitEmbark.Add( SPDisembarkUnit );
-- MOD End   by CaptainCWB



--[[
function LegionMovement (playerID, unitID, bRemainingMoves)

	local player = Players[ playerID ]
	local unit = player:GetUnitByID(unitID)
	if player ==nil then
		return
	end
	

	
	if unit ==nil then
		return
	end
	

	if unit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_LEGION_GROUP"].ID) then
--		local plotX = unit:GetX()
--		local plotY = unit:GetY()
		local DesPlot = unit:LastMissionPlot()
		UnitGroupMovement(player,DesPlot,unitID)
		unit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_LEGION_GROUP"].ID, false)
		print ("Find a Legion moved!")
	end
	


end------function end
Events.UnitMoveQueueChanged.Add( LegionMovement )






----------------------------------------------------------------------Utilities--------------------------------------


function UnitGroupMovement(player,DesPlot,unitID)---------Move all Units in a Legion
	for unit in player:Units() do
		if unit:IsCombatUnit() and unit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_LEGION_GROUP"].ID) and unit:GetID() ~= unitID then
--		   unit:SetXY(plotX,plotY)
		   local unitPlot = unit:GetPlot()
		   local unitCount = DesPlot:GetNumUnits()
		   
		   if unitCount >= 2 then
		   	for i = 0, 5 do
				local adjPlot = Map.PlotDirection(DesPlot:GetX(), DesPlot:GetY(), i)
				if adjPlot ~= nil and adjPlot:GetNumUnits()< 2 then
			   	    DesPlot = adjPlot
			   	    break
			   	end 
		   	 end  
		   end
		   
		   local plotX = DesPlot:GetX()
		   local plotY = DesPlot:GetY()
		   
		   unit:PushMission(MissionTypes.MISSION_MOVE_TO, plotX, plotY, 0, 0, 1, MissionTypes.MISSION_MOVE_TO, unitPlot, unit)
	
		  
--		   if unitCount >= 3 then
--		  	  unit:JumpToNearestValidPlot()
--		   end
		   unit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_LEGION_GROUP"].ID, false)
--		   unit:SetMoves(0)
		   print ("Group Movement finished!")	
		end
	end
end
]]


-- MOD Begin by CaptainCWB
-------No Set-up for Upgraded Howitzer from France Battery
function NoSetUPforUFHowitzer(iPlayerID, iUnitID)
	if  Players[ iPlayerID ] and Players[ iPlayerID ]:IsAlive()
	and Players[ iPlayerID ]:GetUnitByID( iUnitID )
	and not Players[ iPlayerID ]:GetUnitByID( iUnitID ):IsDead()
	and not Players[ iPlayerID ]:GetUnitByID( iUnitID ):IsDelayedDeath()
	and Players[ iPlayerID ]:GetUnitByID( iUnitID ):IsHasPromotion(GeneralSID)
	and Players[ iPlayerID ]:GetUnitByID( iUnitID ):IsHasPromotion(SetUpID)
	then
		Players[ iPlayerID ]:GetUnitByID( iUnitID ):SetHasPromotion(SetUpID, false);
	end
end
Events.SerialEventUnitCreated.Add( NoSetUPforUFHowitzer );
-- MOD End   by CaptainCWB



function CarrierPromotionTransfer(player,unit)
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

		for i = 0, unitCount-1, 1 do
			local pCargoUnit = plot:GetUnit(i);
			if pCargoUnit:IsCargo() and pCargoUnit:GetTransportUnit() == unit then
				print ("Found the aircraft on the carrier!")
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





function AASPromotionTransfer(player,unit) 

	local Sunder1ID = GameInfo.UnitPromotions["PROMOTION_SUNDER_1"].ID
	local Sunder2ID = GameInfo.UnitPromotions["PROMOTION_SUNDER_2"].ID
	-- local Sunder3ID = GameInfo.UnitPromotions["PROMOTION_SUNDER_3"].ID
	local CollDamageLV1ID = GameInfo.UnitPromotions["PROMOTION_COLLATERAL_DAMAGE_1"].ID
	local CollDamageLV2ID = GameInfo.UnitPromotions["PROMOTION_COLLATERAL_DAMAGE_2"].ID
	-- local CollDamageLV3ID = GameInfo.UnitPromotions["PROMOTION_COLLATERAL_DAMAGE_3"].ID
	
	local LogisticsID = GameInfo.UnitPromotions["PROMOTION_LOGISTICS"].ID
	
	local plot = unit:GetPlot();
	if plot and unit:GetUnitType() == GameInfoTypes.UNIT_FRANCE_MISTRAL and unit:HasCargo() then
		print("Found the AAS!")
		local unitCount = plot:GetNumUnits()

		for i = 0, unitCount-1, 1 do
			local pFoundUnit = plot:GetUnit(i)
			print ("Found the aircraft on the AAS!")
			
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
---------strong quick study
function NewUnitWithQuickStudy(iPlayer, iCity, iUnit, bGold, bFaith)
	if Players[iPlayer] == nil
	or Players[iPlayer]:GetUnitByID(iUnit) == nil
	or Players[iPlayer]:GetCityByID(iCity) == nil
	or GameInfo.UnitPromotions["PROMOTION_GAIN_EXPERIENCE"] == nil
	then
		return;
	end
	local pPlayer = Players[iPlayer];
	local pUnit = pPlayer:GetUnitByID(iUnit);
	if not pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GAIN_EXPERIENCE"].ID) then
		return;
	end
	print("found NewUnitWithQuickStudy! Original Exp Is: ".. pUnit:GetExperience());
	pUnit:SetExperience(pUnit:GetExperience()*2);
	print("New Exp is: "..pUnit:GetExperience());
end
GameEvents.CityTrained.Add(NewUnitWithQuickStudy)


-----Enterprise Carrier Roll to Generate
function SetHeroicCarrierRoll(iPlayer, iCity, iProject, bGold, bFaith) 
	if Players[iPlayer] == nil
	or iProject == nil
	or Players[iPlayer]:GetCityByID(iCity) == nil
	then
		return
	end
	local pPlayer = Players[iPlayer]
	if iProject==GameInfo.Projects["PROJECT_HEROIC_CARRIER"].ID then
	print("Heroic Carrier Project finished")
	local CapitalCity = pPlayer:GetCapitalCity()
	CapitalCity:SetNumRealBuilding(GameInfoTypes["BUILDING_HEROIC_CARRIER_PROJECT"],1)
	print("Heroic Carrier Project in Capital")
	end
end
GameEvents.CityCreated.Add(SetHeroicCarrierRoll)


function HeroicCarrierRollStart( iTeam1, iTeam2, bWar )
	if iTeam1 == nil or iTeam2 == nil then 
		return
	end
	local pTeam1 = Teams[iTeam1]
	local pTeam2 = Teams[iTeam2]
	if not pTeam1:IsAtWar(pTeam2) then
		return
	end
	local CapitalCity=nil
	for playerID,pPlayer in pairs(Players) do
		if pPlayer and pPlayer:IsAlive() and not pPlayer:IsMinorCiv() and not pPlayer:IsBarbarian() then
			CapitalCity=pPlayer:GetCapitalCity()
			if CapitalCity~=nil and CapitalCity:IsHasBuilding(GameInfoTypes["BUILDING_HEROIC_CARRIER_PROJECT"])
			and(pPlayer:GetTeam()==iTeam1 or pPlayer:GetTeam()==iTeam2)then
				print("The war calls the Heroic Carrier")
				CapitalCity:SetNumRealBuilding(GameInfoTypes["BUILDING_HEROIC_CARRIER_START"],1)
				CapitalCity:SetNumRealBuilding(GameInfoTypes["BUILDING_HEROIC_CARRIER_PROJECT"],0)
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
	CapitalCity=pPlayer:GetCapitalCity()
	if CapitalCity == nil then
		return
	end
	if CapitalCity:IsHasBuilding(GameInfoTypes["BUILDING_HEROIC_CARRIER_START"]) then
		print("HeroicRoll Starts at the capital:"..CapitalCity:GetName())
		for pUnit in pPlayer:Units() do
			if pUnit:IsHasPromotion(GameInfoTypes["PROMOTION_CARRIER_UNIT"])then
				local heroicRoll = Game.Rand(100, "At NewUnitCreationRules.lua HeroicCarrierGenerate(), spawn heroic") + 1
				--local HeroicRoll = math.random(1, 100)
				print("HeroicRoll:" .. HeroicRoll)
				if HeroicRoll >= 75  then
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
						if pUnit:IsHasPromotion(unitPromotionID) and not unitPromotion.LostWithUpgrade then
							NewUnit:SetHasPromotion(unitPromotionID, true)
						end
					end
					pUnit:Kill()
					
					if g_CargoSetList[playerID] == nil then
						SPCargoListSetup(playerID);
					end
					if g_CargoSetList[playerID][1] and g_CargoSetList[playerID][1] ~= -1 then
						for i=0, 5 do
						    if  (  pPlayer:IsHuman() and pPlayer:IsCanPurchaseAnyCity(false, true, g_CargoSetList[playerID][4], -1, YieldTypes.YIELD_GOLD)  )
						    or not pPlayer:IsHuman()
						    then
							local iCost = CarrierRestore(playerID,NewUnit:GetID(),g_CargoSetList[playerID][1]);
							if iCost and iCost > 0 then
								pPlayer:ChangeGold(- iCost);
							end
						    end
						end
					end
					CapitalCity:SetNumRealBuilding(GameInfoTypes["BUILDING_HEROIC_CARRIER_START"],0)
					CapitalCity:SetNumRealBuilding(GameInfoTypes["BUILDING_HEROIC_CARRIER_PROJECT"],0)
					print("Heroic Carrier Generated!")
					return
				end
			end
		end
	end
end
GameEvents.PlayerDoTurn.Add(HeroicCarrierGenerate)

function NewUnitRemoveErrorPromotion( iPlayerID, iUnitID )
	if( Players[ iPlayerID ] == nil or not Players[ iPlayerID ]:IsAlive()
	or  Players[ iPlayerID ]:GetUnitByID( iUnitID ) == nil
	or  Players[ iPlayerID ]:GetUnitByID( iUnitID ):IsDead()
	or  Players[ iPlayerID ]:GetUnitByID( iUnitID ):IsDelayedDeath() )
	then
		return;
	end
	RemoveErrorPromotion(iPlayerID, iUnitID)
end
Events.SerialEventUnitCreated.Add(NewUnitRemoveErrorPromotion)
-- MOD end by HMS

-- MOD by CaptainCWB
function SetEliteUnitsName( iPlayerID, iUnitID )
	if Players[ iPlayerID ] == nil or not Players[ iPlayerID ]:IsAlive()
	or Players[ iPlayerID ]:GetUnitByID( iUnitID ) == nil
	or Players[ iPlayerID ]:GetUnitByID( iUnitID ):IsDead()
	or Players[ iPlayerID ]:GetUnitByID( iUnitID ):IsDelayedDeath()
	or Players[ iPlayerID ]:GetUnitByID( iUnitID ):HasName()
	then
		return;
	end
	local pUnit = Players[ iPlayerID ]:GetUnitByID( iUnitID );
	if     pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_ELITE_DEFENSE"].ID) then
		pUnit:SetName("TXT_KEY_ELITE_NAME_SPARTAN300");		-- Locale.ConvertTextKey("TXT_KEY_ELITE_NAME_SPARTAN300")
	elseif pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_NUMIDIAN_MARCH"].ID) and pUnit:GetUnitCombatType()== GameInfoTypes.UNITCOMBAT_HELICOPTER then
		pUnit:SetName("TXT_KEY_ELITE_NAME_NUMIDIAN");		-- Locale.ConvertTextKey("TXT_KEY_ELITE_NAME_NUMIDIAN")
	elseif pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GAIN_MOVES_AFFER_KILLING"].ID) then
		pUnit:SetName("TXT_KEY_ELITE_NAME_ELITE_RIDER");	-- Locale.ConvertTextKey("TXT_KEY_ELITE_NAME_ELITE_RIDER")
	elseif pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_RANGE_SPECIAL"].ID) then
		pUnit:SetName("TXT_KEY_ELITE_NAME_ENGLISH_LONGBOWMAN");	-- Locale.ConvertTextKey("TXT_KEY_ELITE_NAME_ENGLISH_LONGBOWMAN")
	
	elseif pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_SKI_INFANTRY"].ID) and pUnit:GetUnitClassType() ~= GameInfoTypes.UNITCLASS_MUSKETEER then
		pUnit:SetName("TXT_KEY_ELITE_NAME_DANISH_SKI_INFANTRY");-- Locale.ConvertTextKey("TXT_KEY_ELITE_NAME_DANISH_SKI_INFANTRY")
	
	elseif pUnit:GetUnitClassType() == GameInfoTypes.UNITCLASS_PROTOTYPE_HWACHA then
		pUnit:SetName("TXT_KEY_ELITE_NAME_KOREA_HWACHA");	-- Locale.ConvertTextKey("TXT_KEY_ELITE_NAME_KOREA_HWACHA")
	elseif pUnit:GetUnitClassType() == GameInfoTypes.UNITCLASS_PROTOTYPE_SUBMARINE then
		pUnit:SetName("TXT_KEY_ELITE_NAME_PROTOTYPE_SUBMARINE");-- Locale.ConvertTextKey("TXT_KEY_ELITE_NAME_PROTOTYPE_SUBMARINE")
	elseif pUnit:GetUnitClassType() == GameInfoTypes.UNITCLASS_SUPER_HOWITZER then
		pUnit:SetName("TXT_KEY_ELITE_NAME_SUPER_HOWITZER");	-- Locale.ConvertTextKey("TXT_KEY_ELITE_NAME_SUPER_HOWITZER")
	elseif pUnit:GetUnitClassType() == GameInfoTypes.UNITCLASS_PROTOTYPE_BOMBER then
		pUnit:SetName("TXT_KEY_ELITE_NAME_PROTOTYPE_BOMBER");	-- Locale.ConvertTextKey("TXT_KEY_ELITE_NAME_PROTOTYPE_BOMBER")
	-- "Ville de Paris" is the "Default" Name of HMS First Rate!	--(> w·*)/
	elseif pUnit:GetUnitType() == GameInfoTypes.UNIT_ENGLISH_SHIPOFTHELINE then
		pUnit:SetName("TXT_KEY_ENGLISH_HMS_VILLE");		-- Locale.ConvertTextKey("TXT_KEY_ENGLISH_HMS_VILLE")
	end
end
Events.SerialEventUnitCreated.Add(SetEliteUnitsName)

-- Promotions Add|Remove when Units Move
function PromotionsARonUnitsMove( iPlayerID, iUnitID )
	if( Players[ iPlayerID ] == nil or
	not Players[ iPlayerID ]:IsAlive()
	or  Players[ iPlayerID ]:GetCapitalCity() == nil
	or  Players[ iPlayerID ]:GetCapitalCity():Plot() == nil
	or  Players[ iPlayerID ]:GetUnitByID( iUnitID ) == nil
	or  Players[ iPlayerID ]:GetUnitByID( iUnitID ):GetPlot() == nil
	or  Players[ iPlayerID ]:GetUnitByID( iUnitID ):IsDead()
	or  Players[ iPlayerID ]:GetUnitByID( iUnitID ):IsDelayedDeath() )
	then
		return;
	end
	
	local pPlayer = Players[ iPlayerID ];
	local pCPlot  = pPlayer:GetCapitalCity():Plot();
	local pUnit   = pPlayer:GetUnitByID( iUnitID );
	local pUPlot  = pUnit:GetPlot();
	
	-- Invisible inside owner's territory
	if pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_INVISIBLE_INSIDE"].ID) then
	    if pUPlot:GetOwner() == pUnit:GetOwner() then
		pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_RECON_UNIT"].ID, true);
	    else
		pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_RECON_UNIT"].ID, false);
	    end
	end
	
	-- Scurvy
--	if pPlayer:IsBarbarian() or pPlayer:IsMinorCiv() or pUnit:IsTrade() then
--	elseif pUPlot:GetTerrainType() == TerrainTypes.TERRAIN_OCEAN and Teams[pPlayer:GetTeam()]:GetProjectCount(GameInfoTypes["PROJECT_NAVAL_EXPLORATION"]) == 0 then
--	    if not pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_SCURVY"].ID) then
--		pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_SCURVY"].ID, true);
--	    end
--	elseif pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_SCURVY"].ID) then
--		pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_SCURVY"].ID, false);
--	end
	
	-- Continental Overlord & Exotic Overlord
	if pUnit:GetBaseCombatStrength() <= 0
	or (not pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_SAME_CONTINENT"].ID)
	and not pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_OTHER_CONTINENT"].ID))
	then
		return;
	elseif  pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_SAME_CONTINENT"].ID)
	and     pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_OTHER_CONTINENT"].ID)
	then
		if not pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MORALE"].ID) then
			pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MORALE"].ID, true);
		end
		return;
	end
	local bIsSetMorale = (pCPlot:GetArea() == pUPlot:GetArea()) == pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_SAME_CONTINENT"].ID);
	if bIsSetMorale ~= pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MORALE"].ID) then
		pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MORALE"].ID, bIsSetMorale);
	end
end
Events.UnitMoveQueueChanged.Add(PromotionsARonUnitsMove)
Events.SerialEventUnitCreated.Add(PromotionsARonUnitsMove)

function OnUnitMovetoAdjOnly( iPlayerID, iUnitID, bRemainingMoves )
	if Players[ iPlayerID ] == nil or not Players[ iPlayerID ]:IsAlive()
	or Players[ iPlayerID ]:GetUnitByID( iUnitID ) == nil
	or Players[ iPlayerID ]:GetUnitByID( iUnitID ):IsDead()
	or Players[ iPlayerID ]:GetUnitByID( iUnitID ):IsDelayedDeath()
	or not Players[ iPlayerID ]:GetUnitByID( iUnitID ):IsHasPromotion(MovetoAdjOnlyID)
	then
		return;
	end
	local pUnit = Players[ iPlayerID ]:GetUnitByID( iUnitID );
	-- Romve Temp promotion after move
	if pUnit:IsHasPromotion(MovetoAdjOnlyID) then
		pUnit:SetHasPromotion(MovetoAdjOnlyID,false);
	end
	if pUnit:IsHasPromotion(MovetoAdjOnly1ID) then
		pUnit:SetHasPromotion(MovetoAdjOnly1ID,false);
	end
	if pUnit:IsHasPromotion(MovetoAdjOnly2ID) then
		pUnit:SetHasPromotion(MovetoAdjOnly2ID,false);
	end
	if pUnit:IsHasPromotion(MovetoAdjOnly3ID) then
		pUnit:SetHasPromotion(MovetoAdjOnly3ID,false);
	end
	if pUnit:IsHasPromotion(MovetoAdjOnly4ID) then
		pUnit:SetHasPromotion(MovetoAdjOnly4ID,false);
	end
end
Events.UnitMoveQueueChanged.Add( OnUnitMovetoAdjOnly );

function FixWorkerBridge( iPlayerID, iUnitID )
	if (Players[ iPlayerID ] == nil or not Players[ iPlayerID ]:IsAlive()
	or  Players[ iPlayerID ]:GetUnitByID( iUnitID ) == nil
	or  Players[ iPlayerID ]:GetUnitByID( iUnitID ):IsDead()
	or  Players[ iPlayerID ]:GetUnitByID( iUnitID ):IsDelayedDeath()
	or  Players[ iPlayerID ]:GetUnitByID( iUnitID ):GetPlot() == nil)
	or  Players[ iPlayerID ]:GetUnitByID( iUnitID ):GetUnitClassType() ~= GameInfoTypes.UNITCLASS_WORKER
	then
		return;
	end
	
	local pPlayer  = Players[iPlayerID];
	local pUnit = pPlayer:GetUnitByID(iUnitID);
	local pPlot = pUnit:GetPlot();
	
	if pUnit:IsEmbarked() then
		if not pPlot:IsWater() then
			pUnit:SetEmbarked(false);
		elseif pPlot:GetImprovementType() == GameInfo.Improvements["IMPROVEMENT_PONTOON_BRIDGE_MOD"].ID then
			for i = 0, pPlot:GetNumUnits() - 1, 1 do
			    if pPlot:GetUnit( i ) and pPlot:GetUnit( i ):GetDomainType() == DomainTypes.DOMAIN_LAND and pPlot:GetUnit( i ):IsEmbarked() then
				pPlot:GetUnit( i ):SetEmbarked(false);
			    end
			end
		end
	elseif pPlot:IsWater() and pPlot:GetImprovementType() ~= GameInfo.Improvements["IMPROVEMENT_PONTOON_BRIDGE_MOD"].ID then
		if pPlot:IsRoute() then
			pPlot:SetRouteType(-1);
		end
		for i = 0, pPlot:GetNumUnits() - 1, 1 do
			if pPlot:GetUnit( i ) and pPlot:GetUnit( i ):GetDomainType() == DomainTypes.DOMAIN_LAND and not pPlot:GetUnit( i ):IsEmbarked() then
				pPlot:GetUnit( i ):SetEmbarked(true);
			end
		end
	end
end
Events.UnitShouldDimFlag.Add(FixWorkerBridge)


tExExRSUnitName = nil;
-- Captured unit & exchange Extra Religion Spread Unit does not occupy normal unit's name
function OnUnitNoChangeNameSP( iPlayer, iUnit, iName )
	if  Players[ iPlayer ] == nil or not Players[ iPlayer ]:IsEverAlive()
	or Players[ iPlayer ]:GetUnitByID( iUnit ) == nil
	or (tCaptureSPUnits and #tCaptureSPUnits > 0 and tCaptureSPUnits[8] ~= nil
	and Players[ iPlayer ]:GetUnitByID( iUnit ):GetPlot() == tCaptureSPUnits[2]
	and iPlayer == tCaptureSPUnits[3])
	or (tExExRSUnitName and #tExExRSUnitName > 0 and tExExRSUnitName[3] ~= nil
	and Players[ iPlayer ]:GetUnitByID( iUnit ):GetPlot() == tExExRSUnitName[2]
	and iPlayer == tExExRSUnitName[1])
	then
		return false;
	else
		return true;
	end
end
GameEvents.UnitCanHaveName.Add(OnUnitNoChangeNameSP)
-- Religion Spread Unit "exchange" to get extra Time
function ExchangeExRSUnitSP(iPlayerID, iUnitID)
	if Players[iPlayerID] == nil or not Players[iPlayerID]:IsEverAlive()
	or Players[iPlayerID]:GetUnitByID(iUnitID) == nil
	or Players[iPlayerID]:GetUnitByID(iUnitID):GetPlot() == nil
	or not Players[iPlayerID]:GetUnitByID(iUnitID):IsHasPromotion(ExtraRSID)
	or tExExRSUnitName ~= nil
	then
		return;
	end
	local pPlayer = Players[iPlayerID];
	local pUnit   = Players[iPlayerID]:GetUnitByID(iUnitID);
	local pUPlot  = pUnit:GetPlot();
	pUnit:SetHasPromotion(ExtraRSID, false);
	
	if pUnit:GetSpreadsLeft() <= 0 or pUnit:GetSpreadsLeft() < GameInfo.Units[pUnit:GetUnitType()].ReligionSpreads then
		return;
	end
	local pCity   = nil;
	local pPlot   = nil;
	if     pUnit:GetPlot():IsCity() and pUnit:GetPlot():GetPlotCity():GetReligiousMajority() > 0 then
		pCity = pUnit:GetPlot():GetPlotCity();
		pPlot = pUnit:GetPlot();
	elseif pUnit:GetPlot():IsFriendlyTerritory(iPlayerID) and pUnit:GetPlot():GetWorkingCity() and pUnit:GetPlot():GetWorkingCity():GetReligiousMajority() > 0 then
		pCity = pUnit:GetPlot():GetWorkingCity();
		pPlot = pUnit:GetPlot():GetWorkingCity():Plot();
	elseif pPlayer:GetCapitalCity() and pPlayer:GetCapitalCity():GetReligiousMajority() > 0 then
		pCity = pPlayer:GetCapitalCity();
		pPlot = pPlayer:GetCapitalCity():Plot();
	else
		return;
	end
	
	local iUnitType = pUnit:GetUnitType();
	local iUnitMove = pUnit:GetMoves();
	local sUnitName = nil;
	if pUnit:HasName() then
		sUnitName = pUnit:GetNameNoDesc();
	end
	tExExRSUnitName = { iPlayerID, pPlot, sUnitName };
	
	pUnit:Kill();
	pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_EXTRA_RELIGION_SPREADS_4"],1);
	local pNUnit = pPlayer:InitUnit(iUnitType, pPlot:GetX(), pPlot:GetY());
	pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_EXTRA_RELIGION_SPREADS_4"],0);
	if pPlot ~= pUPlot then
		pNUnit:SetXY(pUPlot:GetX(), pUPlot:GetY());
	end
	pNUnit:SetHasPromotion(ExtraRSID, false);
	pNUnit:SetMoves(iUnitMove);
	if tExExRSUnitName and tExExRSUnitName[3] ~= nil then
		pNUnit:SetName(tExExRSUnitName[3]);
	end
	tExExRSUnitName = nil;
end
Events.SerialEventUnitCreated.Add(ExchangeExRSUnitSP);


print("NewUnitRules Check success!")
