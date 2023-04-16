-- NewBuildingEffects

--------------------------------------------------------------
include("FLuaVector.lua");
include("UtilityFunctions.lua");
include("PlotIterators.lua");

-----------New building effects when it is built
function NewBuildingEffects(iPlayer, iCity, iBuilding, bGold, bFaith)
	local player = Players[iPlayer];
	if player == nil or player:IsBarbarian() or player:IsMinorCiv() or player:GetNumCities() <= 0 then
		return;
	end
	local pCity = player:GetCityByID(iCity);
	if pCity == nil then
		return;
	end
	local iBuildingClass = GameInfoTypes[GameInfo.Buildings[iBuilding].BuildingClass];
	
	-- AI Bonus
	if     iBuildingClass == GameInfo.BuildingClasses.BUILDINGCLASS_ARMORY.ID or iBuildingClass == GameInfo.BuildingClasses.BUILDINGCLASS_ARSENAL.ID then
		if not player:IsHuman() then
			local MAID = GameInfo.Buildings.BUILDING_MILITARY_ACADEMY.ID
--				local ConsumerResID = GameInfoTypes["RESOURCE_CONSUMER"]-----------Give AI additional Consumer Goods to make them able to build settlers
			pCity:SetNumRealBuilding(MAID, 1)
--				player:ChangeNumResourceTotal (ConsumerResID,1)
			print ("AI Free Military Academy!")
			if GameInfo.Leader_Traits{ LeaderType = GameInfo.Leaders[player:GetLeaderType()].Type, TraitType = "TRAIT_FIGHT_WELL_DAMAGED" }()
			and(GameInfo.Traits["TRAIT_FIGHT_WELL_DAMAGED"].PrereqPolicy == nil or (GameInfo.Traits["TRAIT_FIGHT_WELL_DAMAGED"].PrereqPolicy 
			and player:HasPolicy(GameInfoTypes[GameInfo.Traits["TRAIT_FIGHT_WELL_DAMAGED"].PrereqPolicy])))
			then
				local DJID = GameInfo.Buildings.BUILDING_JAPANESE_DOJO.ID
				pCity:SetNumRealBuilding(DJID, 1)
				print ("Japan AI free Dojo!")
			end
		end
		
	-- One-time Money Offer Effect
	elseif iBuilding == GameInfo.Buildings.BUILDING_BURJ_TOWER.ID then
		local GameSpeed = Game.GetGameSpeedType()
		print ("Game Speed:"..GameSpeed)
		if GameSpeed == 0 then
			player:ChangeGold(99999)
		elseif GameSpeed == 1 then
			player:ChangeGold(66666)
		elseif GameSpeed == 2 then
			player:ChangeGold(44444)
		elseif GameSpeed == 3 then
			player:ChangeGold(22222)
		end
	elseif iBuilding == GameInfo.Buildings.BUILDING_AUSTRIA_MUSIC_SCHOOL.ID then
		local GameSpeed = Game.GetGameSpeedType()
		print ("Game Speed:"..GameSpeed)
		if GameSpeed == 0 then
			player:ChangeGold(1000)
		elseif GameSpeed == 1 then
			player:ChangeGold(750)
		elseif GameSpeed == 2 then
			player:ChangeGold(500)
		elseif GameSpeed == 3 then
			player:ChangeGold(300)
		end
		
	-- Remove Utility Penalty
	elseif iBuildingClass == GameInfo.BuildingClasses.BUILDINGCLASS_AQUEDUCT.ID
	or     iBuildingClass == GameInfo.BuildingClasses.BUILDINGCLASS_TAP_WATER_SUPPLY.ID
	or     iBuildingClass == GameInfo.BuildingClasses.BUILDINGCLASS_WATER_TREATMENT_FACTORY.ID
	or     iBuildingClass == GameInfo.BuildingClasses.BUILDINGCLASS_HOSPITAL.ID
	or     iBuildingClass == GameInfo.BuildingClasses.BUILDINGCLASS_MEDICAL_LAB.ID
	or     iBuilding == GameInfo.Buildings.BUILDING_VENICE_FONDACO.ID
	 then
		local UPID = GameInfo.Buildings.BUILDING_NO_UTILITY_WARNING.ID
		pCity:SetNumRealBuilding(UPID, 0)
		
	-- One-time Population Effect
	elseif iBuilding == GameInfo.Buildings.BUILDING_MEGACITY_PYRAMID.ID then
		pCity:ChangePopulation(30, true)
		
	-- Terracotta Army provides Barracks, Armory and Military Academy
	elseif iBuilding == GameInfo.Buildings.BUILDING_TERRACOTTA_ARMY.ID then
		local iMB = GameInfo.Buildings.BUILDING_BARRACKS.ID;
		local overrideMB = GameInfo.Civilization_BuildingClassOverrides{ BuildingClassType = "BUILDINGCLASS_BARRACKS", CivilizationType = GameInfo.Civilizations[player:GetCivilizationType()].Type }();
		if overrideMB ~= nil then
			iMB = GameInfo.Buildings[overrideMB.BuildingType].ID;
		end
		pCity:SetNumRealBuilding(iMB, 1);
		iMB = GameInfo.Buildings.BUILDING_ARMORY.ID;
		overrideMB = GameInfo.Civilization_BuildingClassOverrides{ BuildingClassType = "BUILDINGCLASS_ARMORY", CivilizationType = GameInfo.Civilizations[player:GetCivilizationType()].Type }();
		if overrideMB ~= nil then
			iMB = GameInfo.Buildings[overrideMB.BuildingType].ID;
		end
		pCity:SetNumRealBuilding(iMB, 1);
		iMB = GameInfo.Buildings.BUILDING_MILITARY_ACADEMY.ID;
		overrideMB = GameInfo.Civilization_BuildingClassOverrides{ BuildingClassType = "BUILDINGCLASS_MILITARY_ACADEMY", CivilizationType = GameInfo.Civilizations[player:GetCivilizationType()].Type }();
		if overrideMB ~= nil then
			iMB = GameInfo.Buildings[overrideMB.BuildingType].ID;
		end
		pCity:SetNumRealBuilding(iMB, 1);
		
	-- Move Captial
	elseif iBuilding == GameInfo.Buildings.BUILDING_NEW_PALACE.ID then
		print("New Captial Built!")
		local oCity = player:GetCapitalCity();
		pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_NEW_PALACE"], 0);
		
		if oCity ~= nil then
			
			-- CityName Change
			if oCity:GetName() == Locale.ConvertTextKey("TXT_KEY_CITY_NAME_SHENDU") then
				oCity:SetName("TXT_KEY_CITY_NAME_LOYANG");
			end
			if pCity:GetName() == Locale.ConvertTextKey("TXT_KEY_CITY_NAME_LOYANG") then
				pCity:SetName("TXT_KEY_CITY_NAME_SHENDU");
			end
			
			for building in GameInfo.Buildings() do
				-- MoveMark
				oCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CAPITAL_MOVEMARK"],0)
				pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CAPITAL_MOVEMARK"],1)
				-- Palace
				if oCity:IsHasBuilding(building.ID) and building.Capital then
					local i = oCity:GetNumBuilding(building.ID);
					oCity:SetNumRealBuilding(building.ID, 0);
					pCity:SetNumRealBuilding(building.ID, i);
				end
				
				-- Remove "BonusBT" from Old
				if oCity:IsHasBuilding(building.ID)
				and(building.Type == "BUILDING_ELECTRICITY_BONUS"
				or  building.Type == "BUILDING_ELECTRICITY_PENALTY"
				or  building.Type == "BUILDING_MANPOWER_BONUS"
				or  building.Type == "BUILDING_CONSUMER_BONUS"
				or  building.Type == "BUILDING_CONSUMER_PENALTY_WARNING"
				or  building.Type == "BUILDING_CONSUMER_PENALTY"
				or  building.Type == "BUILDING_TB_ART_OF_WAR"
				or  building.Type == "BUILDING_HAPPINESS_TOURISMBOOST"
				or  building.Type == "BUILDING_TRADE_TO_SCIENCE"
				or  building.Type == "BUILDING_RATIONALISM_HAPPINESS"
			--	or  building.Type == "BUILDING_SCHOLASTICISM"
				or  building.Type == "BUILDING_TROOPS_DEBUFF"
				)then
					oCity:SetNumRealBuilding(building.ID, 0);
				end
				
				-- Remove "Corrupt" from New
				if pCity:IsHasBuilding(building.ID)
				and(building.BuildingClass == "BUILDINGCLASS_CITY_HALL_LV1"
				or  building.BuildingClass == "BUILDINGCLASS_CITY_HALL_LV2"
				or  building.BuildingClass == "BUILDINGCLASS_CITY_HALL_LV3"
				or  building.BuildingClass == "BUILDINGCLASS_CITY_HALL_LV4"
				or  building.BuildingClass == "BUILDINGCLASS_CITY_HALL_LV5"
				or  building.BuildingClass == "BUILDINGCLASS_PUPPET_GOVERNEMENT"
				or  building.BuildingClass == "BUILDINGCLASS_CONSTABLE"
				or  building.BuildingClass == "BUILDINGCLASS_SHERIFF_OFFICE"
				or  building.BuildingClass == "BUILDINGCLASS_POLICE_STATION"
				or  building.BuildingClass == "BUILDINGCLASS_PROCURATORATE"
				)then
					pCity:SetNumRealBuilding(building.ID, 0);
				end
				
				-- Move Policy Buildings & Count Buildings
				local policFreeBCCapital = GameInfo.Policy_FreeBuildingClassCapital{ BuildingClassType = building.BuildingClass }()
				if oCity:IsHasBuilding(building.ID) and (policFreeBCCapital ~= nil or building.BuildingClass == "BUILDINGCLASS_COUNT_BUILIDNGS") then
					local i = oCity:GetNumBuilding(building.ID);
					oCity:SetNumRealBuilding(building.ID, 0);
					pCity:SetNumRealBuilding(building.ID, i);
				end
			end
			print("Captial Moved!")
		end
	end
	
	--[[ Free Great People from Buildings don't Upgrade Threshold - by CaptainCWB
	if GameInfo.Building_FreeUnits_Truly and GameInfo.Building_FreeUnits_Truly{ BuildingType = GameInfo.Buildings[iBuilding].Type }() ~= nil then
		local FreeUnit  = GameInfo.Building_FreeUnits_Truly{ BuildingType = GameInfo.Buildings[iBuilding].Type }();
		local iUnitType = GameInfoTypes[FreeUnit.UnitType];
		local overrideUnit = GameInfo.Civilization_UnitClassOverrides{ UnitClassType = GameInfo.Units[FreeUnit.UnitType].Class, CivilizationType = GameInfo.Civilizations[player:GetCivilizationType()].Type }();
		if overrideUnit then
		    if overrideUnit.UnitType ~= nil then
			iUnitType = GameInfoTypes[overrideUnit.UnitType];
		    else
			iUnitType = nil;
		    end
		end
		local iNumUnits = FreeUnit.NumUnits;
		
		if iNumUnits > 0 and iUnitType and iUnitType ~= -1 then
			for i = 1, iNumUnits, 1 do
				player:InitUnit(iUnitType, pCity:GetX(), pCity:GetY());
			end
		end
	end]]
end------Function End
GameEvents.CityConstructed.Add(NewBuildingEffects)



--[[
function SPNotificationEvents ( Id, type, toolTip, strSummary, iGameValue, iExtraGameData, ePlayer )
	
	
	-------------Remove Useless Notifications （Temporary method）
	
	

	local Keywords = string.find(strSummary,"OVER_RESOURCE") 

	if Keywords ~= nil then 
		UI.RemoveNotification( Id )
		print ("Useless Notification Removed!"..type)
	else
		return
	end
	
	
	-----------------------Spy Events
--	if type == NotificationTypes.NOTIFICATION_SPY_KILLED_A_SPY then
--		local player = Players[Game.GetActivePlayer()]
--		if player:IsHuman() and player:GetCapitalCity() then
--			local pCity = player:GetCapitalCity()
--			pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_INTELLIGENCE_AGENCY"],1) 
--			print ("Espionage Success!")
--		end
--	end

end
Events.NotificationAdded.Add(SPNotificationEvents);
]]






-------Auto replacement for obsolete buildings, currently only for human player for stability issues


function AutoBuildingReplace(iTeam, iTech, bAdopted)
--	print ("tech researched!")
	local pTeam = Teams[iTeam]
	
	if not pTeam:IsHuman() then
--	print ("Only for human!")
	 	return
	end
	
	local player = Players[Game.GetActivePlayer()]
	if player:IsMinorCiv() or player:IsBarbarian() or not player:IsHuman() then
	 	return
	end
	
	if player:GetNumCities() > 0 then
		print ("Auto Buildings Replacement!")
		
		local text
		
		local iOldBuilding = -1;
		local iNewBuilding = -1;
		local overrideBuilding = nil;
		local bIsDoAddNBuilding = false;
		
		if     iTech == GameInfoTypes["TECH_DYNAMITE"] then
			print ("tech: DYNAMITE")
			for city in player:Cities() do
				bIsDoAddNBuilding = false;
				iOldBuilding = GameInfoTypes["BUILDING_STONE_WORKS"];
				overrideBuilding = GameInfo.Civilization_BuildingClassOverrides{ BuildingClassType = "BUILDINGCLASS_STONE_WORKS", CivilizationType = GameInfo.Civilizations[player:GetCivilizationType()].Type }();
				if overrideBuilding ~= nil then
					iOldBuilding = GameInfoTypes[overrideBuilding.BuildingType];
				end
				if city:IsHasBuilding(iOldBuilding) then
					bIsDoAddNBuilding = true;
				end
				if not bIsDoAddNBuilding then
				    iOldBuilding = GameInfoTypes["BUILDING_SAWMILL"];
				    overrideBuilding = GameInfo.Civilization_BuildingClassOverrides{ BuildingClassType = "BUILDINGCLASS_SAWMILL", CivilizationType = GameInfo.Civilizations[player:GetCivilizationType()].Type }();
				    if overrideBuilding ~= nil then
					iOldBuilding = GameInfoTypes[overrideBuilding.BuildingType];
				    end
				    if city:IsHasBuilding(iOldBuilding) then
					bIsDoAddNBuilding = true;
				    end
				end
				
				if bIsDoAddNBuilding then
					iNewBuilding = GameInfoTypes["BUILDING_MINGING_FACTORY"];
					overrideBuilding = GameInfo.Civilization_BuildingClassOverrides{ BuildingClassType = "BUILDINGCLASS_MINGING_FACTORY", CivilizationType = GameInfo.Civilizations[player:GetCivilizationType()].Type }();
					if overrideBuilding ~= nil then
						iNewBuilding = GameInfoTypes[overrideBuilding.BuildingType];
					end
					city:SetNumRealBuilding(iNewBuilding, 1);
					
					text = Locale.ConvertTextKey( "TXT_KEY_SP_NOTIFICATION_AUTO_BUILDING_REPLACEMENT", city:GetName(), GameInfo.Buildings[iOldBuilding].Description)
					text = text .. Locale.ConvertTextKey(GameInfo.Buildings[iNewBuilding].Description)
					
					Events.GameplayAlertMessage( text )
				end
			end
		elseif iTech == GameInfoTypes["TECH_INDUSTRIALIZATION"] then
			print ("tech: INDUSTRIALIZATION")
			for city in player:Cities() do
				bIsDoAddNBuilding = false;
				iOldBuilding = GameInfoTypes["BUILDING_WORKSHOP"];
				overrideBuilding = GameInfo.Civilization_BuildingClassOverrides{ BuildingClassType = "BUILDINGCLASS_WORKSHOP", CivilizationType = GameInfo.Civilizations[player:GetCivilizationType()].Type }();
				if overrideBuilding ~= nil then
					iOldBuilding = GameInfoTypes[overrideBuilding.BuildingType];
				end
				if city:IsHasBuilding(iOldBuilding) then
					bIsDoAddNBuilding = true;
				end
				
				if bIsDoAddNBuilding then
					iNewBuilding = GameInfoTypes["BUILDING_FACTORY"];
					overrideBuilding = GameInfo.Civilization_BuildingClassOverrides{ BuildingClassType = "BUILDINGCLASS_FACTORY", CivilizationType = GameInfo.Civilizations[player:GetCivilizationType()].Type }();
					if overrideBuilding ~= nil then
						iNewBuilding = GameInfoTypes[overrideBuilding.BuildingType];
					end
					city:SetNumRealBuilding(iNewBuilding, 1);
					
					text = Locale.ConvertTextKey( "TXT_KEY_SP_NOTIFICATION_AUTO_BUILDING_REPLACEMENT", city:GetName(), GameInfo.Buildings[iOldBuilding].Description)
					text = text .. Locale.ConvertTextKey(GameInfo.Buildings[iNewBuilding].Description)
					
					Events.GameplayAlertMessage( text )
				end
				
				bIsDoAddNBuilding = false;
				iOldBuilding = GameInfoTypes["BUILDING_GRAIN_MILL"];
				overrideBuilding = GameInfo.Civilization_BuildingClassOverrides{ BuildingClassType = "BUILDINGCLASS_GRAIN_MILL", CivilizationType = GameInfo.Civilizations[player:GetCivilizationType()].Type }();
				if overrideBuilding ~= nil then
					iOldBuilding = GameInfoTypes[overrideBuilding.BuildingType];
				end
				if city:IsHasBuilding(iOldBuilding) then
					bIsDoAddNBuilding = true;
				end
				if not bIsDoAddNBuilding then
				    iOldBuilding = GameInfoTypes["BUILDING_WATERMILL"];
				    overrideBuilding = GameInfo.Civilization_BuildingClassOverrides{ BuildingClassType = "BUILDINGCLASS_WATERMILL", CivilizationType = GameInfo.Civilizations[player:GetCivilizationType()].Type }();
				    if overrideBuilding ~= nil then
					iOldBuilding = GameInfoTypes[overrideBuilding.BuildingType];
				    end
				    if city:IsHasBuilding(iOldBuilding) then
					bIsDoAddNBuilding = true;
				    end
				end
				if not bIsDoAddNBuilding then
				    iOldBuilding = GameInfoTypes["BUILDING_STABLE"];
				    overrideBuilding = GameInfo.Civilization_BuildingClassOverrides{ BuildingClassType = "BUILDINGCLASS_STABLE", CivilizationType = GameInfo.Civilizations[player:GetCivilizationType()].Type }();
				    if overrideBuilding ~= nil then
					iOldBuilding = GameInfoTypes[overrideBuilding.BuildingType];
				    end
				    if city:IsHasBuilding(iOldBuilding) then
					bIsDoAddNBuilding = true;
				    end
				end
				if not bIsDoAddNBuilding then
				    iOldBuilding = GameInfoTypes["BUILDING_WINDMILL"];
				    overrideBuilding = GameInfo.Civilization_BuildingClassOverrides{ BuildingClassType = "BUILDINGCLASS_WINDMILL", CivilizationType = GameInfo.Civilizations[player:GetCivilizationType()].Type }();
				    if overrideBuilding ~= nil then
					iOldBuilding = GameInfoTypes[overrideBuilding.BuildingType];
				    end
				    if city:IsHasBuilding(iOldBuilding) then
					bIsDoAddNBuilding = true;
				    end
				end
				
				if bIsDoAddNBuilding then
					iNewBuilding = GameInfoTypes["BUILDING_MECHANIZED_FARM"];
					overrideBuilding = GameInfo.Civilization_BuildingClassOverrides{ BuildingClassType = "BUILDINGCLASS_MECHANIZED_FARM", CivilizationType = GameInfo.Civilizations[player:GetCivilizationType()].Type }();
					if overrideBuilding ~= nil then
						iNewBuilding = GameInfoTypes[overrideBuilding.BuildingType];
					end
					city:SetNumRealBuilding(iNewBuilding, 1);
					
					text = Locale.ConvertTextKey( "TXT_KEY_SP_NOTIFICATION_AUTO_BUILDING_REPLACEMENT", city:GetName(), GameInfo.Buildings[iOldBuilding].Description)
					text = text .. Locale.ConvertTextKey(GameInfo.Buildings[iNewBuilding].Description)
					
					Events.GameplayAlertMessage( text )
				end
			end
		elseif iTech == GameInfoTypes["TECH_FERTILIZER"] then
			print ("tech: FERTILIZER")
			for city in player:Cities() do
				bIsDoAddNBuilding = false;
				iOldBuilding = GameInfoTypes["BUILDING_FISH_FARM"];
				overrideBuilding = GameInfo.Civilization_BuildingClassOverrides{ BuildingClassType = "BUILDINGCLASS_FISH_FARM", CivilizationType = GameInfo.Civilizations[player:GetCivilizationType()].Type }();
				if overrideBuilding ~= nil then
					iOldBuilding = GameInfoTypes[overrideBuilding.BuildingType];
				end
				if city:IsHasBuilding(iOldBuilding) then
					bIsDoAddNBuilding = true;
				end
				if not bIsDoAddNBuilding then
				    iOldBuilding = GameInfoTypes["BUILDING_GRANARY"];
				    overrideBuilding = GameInfo.Civilization_BuildingClassOverrides{ BuildingClassType = "BUILDINGCLASS_GRANARY", CivilizationType = GameInfo.Civilizations[player:GetCivilizationType()].Type }();
				    if overrideBuilding ~= nil then
					iOldBuilding = GameInfoTypes[overrideBuilding.BuildingType];
				    end
				    if city:IsHasBuilding(iOldBuilding) then
					bIsDoAddNBuilding = true;
				    end
				end
				
				if bIsDoAddNBuilding then
					iNewBuilding = GameInfoTypes["BUILDING_GRAIN_DEPOT"];
					overrideBuilding = GameInfo.Civilization_BuildingClassOverrides{ BuildingClassType = "BUILDINGCLASS_GRAIN_DEPOT", CivilizationType = GameInfo.Civilizations[player:GetCivilizationType()].Type }();
					if overrideBuilding ~= nil then
						iNewBuilding = GameInfoTypes[overrideBuilding.BuildingType];
					end
					city:SetNumRealBuilding(iNewBuilding, 1);
					
					text = Locale.ConvertTextKey( "TXT_KEY_SP_NOTIFICATION_AUTO_BUILDING_REPLACEMENT", city:GetName(), GameInfo.Buildings[iOldBuilding].Description)
					text = text .. Locale.ConvertTextKey(GameInfo.Buildings[iNewBuilding].Description)
					
					Events.GameplayAlertMessage( text )
				end
			end
		elseif iTech == GameInfoTypes["TECH_URBANLIZATION"] then
			print ("tech: URBANLIZATION")
			for city in player:Cities() do
				bIsDoAddNBuilding = false;
				iOldBuilding = GameInfoTypes["BUILDING_AQUEDUCT"];
				overrideBuilding = GameInfo.Civilization_BuildingClassOverrides{ BuildingClassType = "BUILDINGCLASS_AQUEDUCT", CivilizationType = GameInfo.Civilizations[player:GetCivilizationType()].Type }();
				if overrideBuilding ~= nil then
					iOldBuilding = GameInfoTypes[overrideBuilding.BuildingType];
				end
				if city:IsHasBuilding(iOldBuilding) then
					bIsDoAddNBuilding = true;
				end
				
				if bIsDoAddNBuilding then
					iNewBuilding = GameInfoTypes["BUILDING_TAP_WATER_SUPPLY"];
					overrideBuilding = GameInfo.Civilization_BuildingClassOverrides{ BuildingClassType = "BUILDINGCLASS_TAP_WATER_SUPPLY", CivilizationType = GameInfo.Civilizations[player:GetCivilizationType()].Type }();
					if overrideBuilding ~= nil then
						iNewBuilding = GameInfoTypes[overrideBuilding.BuildingType];
					end
					city:SetNumRealBuilding(iNewBuilding, 1);
					
					text = Locale.ConvertTextKey( "TXT_KEY_SP_NOTIFICATION_AUTO_BUILDING_REPLACEMENT", city:GetName(), GameInfo.Buildings[iOldBuilding].Description)
					text = text .. Locale.ConvertTextKey(GameInfo.Buildings[iNewBuilding].Description)
					
					Events.GameplayAlertMessage( text )
				end
			end
		elseif iTech == GameInfoTypes["TECH_COMBUSTION"] then
			print ("tech: COMBUSTION")
			for city in player:Cities() do
				bIsDoAddNBuilding = false;
				iOldBuilding = GameInfoTypes["BUILDING_STAGECOACH"];
				overrideBuilding = GameInfo.Civilization_BuildingClassOverrides{ BuildingClassType = "BUILDINGCLASS_STAGECOACH", CivilizationType = GameInfo.Civilizations[player:GetCivilizationType()].Type }();
				if overrideBuilding ~= nil then
					iOldBuilding = GameInfoTypes[overrideBuilding.BuildingType];
				end
				if city:IsHasBuilding(iOldBuilding) then
					bIsDoAddNBuilding = true;
				end
				
				if bIsDoAddNBuilding then
					iNewBuilding = GameInfoTypes["BUILDING_BUS_STATION"];
					overrideBuilding = GameInfo.Civilization_BuildingClassOverrides{ BuildingClassType = "BUILDINGCLASS_BUS_STATION", CivilizationType = GameInfo.Civilizations[player:GetCivilizationType()].Type }();
					if overrideBuilding ~= nil then
						iNewBuilding = GameInfoTypes[overrideBuilding.BuildingType];
					end
					city:SetNumRealBuilding(iNewBuilding, 1);
					
					text = Locale.ConvertTextKey( "TXT_KEY_SP_NOTIFICATION_AUTO_BUILDING_REPLACEMENT", city:GetName(), GameInfo.Buildings[iOldBuilding].Description)
					text = text .. Locale.ConvertTextKey(GameInfo.Buildings[iNewBuilding].Description)
					
					Events.GameplayAlertMessage( text )
				end
			end
		elseif iTech == GameInfoTypes["TECH_RAILROAD"] then
			print ("tech: RAILROAD")
			
			text = Locale.ConvertTextKey( "TXT_KEY_SP_NOTIFICATION_AUTO_RAILROAD_REPLACEMENT")
			Events.GameplayAlertMessage( text )

			for plotLoop = 0, Map.GetNumPlots() - 1, 1 do
				local plot = Map.GetPlotByIndex(plotLoop)
--				local plotOwner = Players[plot:GetOwner()]

			   if plot:GetRouteType() == GameInfo.Routes.ROUTE_ROAD.ID then
				  plot:SetRouteType(GameInfo.Routes.ROUTE_RAILROAD.ID)
			   end
--				if plotOwner ~= nil then
--					if plotOwner == player then
--		
--					end
--				end	
			end
			
		else
			
		end
		
	end
	
	
end------Function End
GameEvents.TeamSetHasTech.Add(AutoBuildingReplace)



--[[ -- Not Work Now! -- CaptainCWB
AIHasPROM = 0
function AINotLosePop(iPlayer, iCity, iUnit, bGold, bFaith)
    local player = Players[iPlayer]
    print("AI Has PROM:"..AIHasPROM)
	if player == nil then
		print ("No players")
		return
	end
    if iUnit == nil then 
    	return 
    end
    if player:IsHuman() or player:IsMinorCiv() or player:IsBarbarian() then ----------Only for Major AI
    	return 
    end
    if Game:GetHandicapType() < 3 then
		print ("Human beings are not as clever as AI,AI should take care of human beings.")
		return
	end
	local HalfID = GameInfo.UnitPromotions["PROMOTION_HALF_CASUALTIES"].ID
	local bunit = player:GetUnitByID(iUnit)    
	if bunit == nil then
		return
	end
	if not PlayerAtWarWithHuman(player) and AIHasPROM == 1 then
		if not bunit:IsHasPromotion(HalfID) then
			bunit:SetHasPromotion(HalfID, true)
		end
		print("AI New Unit Has PROM !")
	elseif not PlayerAtWarWithHuman(player) and AIHasPROM == 0 then
		for unit in player:Units() do
			if unit ~= nil then
				if not unit:IsHasPromotion(HalfID) then
					unit:SetHasPromotion(HalfID, true)
				end
			end
		end
		print("AI can not lose Pop ! So AI has Promotion !")
		AIHasPROM = 1
	elseif PlayerAtWarWithHuman(player) and AIHasPROM == 1 then
		for pUnit in player:Units() do
			if pUnit ~= nil then
				if pUnit:IsHasPromotion(HalfID) then
					pUnit:SetHasPromotion(HalfID, false)
				end
			end
		end
		print("AI war at Human ! AI lose Promotion !")
		AIHasPROM = 0
	end
end
GameEvents.CityTrained.Add(AINotLosePop)
]]

function MinorProvideRes(iPlayerID)
	local pMinor  = Players[iPlayerID]
	local pPlayer = Players[Game.GetActivePlayer()]
	
	if pMinor  == nil or not pMinor:IsMinorCiv() or pMinor:GetCapitalCity() == nil
	or pPlayer == nil or not pPlayer:IsHuman()
	then
		return
	end
	
	local pCapital = pMinor:GetCapitalCity()
	local ibRes_Man = GameInfoTypes["BUILDING_CIV_S_P_MAN_RESOURCES"]
	if     pPlayer:GetCurrentEra() >= 3 and pCapital:GetNumBuilding(ibRes_Man) < 10 then
		pCapital:SetNumRealBuilding(ibRes_Man,10)
	elseif pPlayer:GetCurrentEra() == 2 and pCapital:GetNumBuilding(ibRes_Man) <  6 then
		pCapital:SetNumRealBuilding(ibRes_Man, 6)
	elseif pPlayer:GetCurrentEra() == 1 and pCapital:GetNumBuilding(ibRes_Man) <  3 then
		pCapital:SetNumRealBuilding(ibRes_Man, 3)
	elseif pPlayer:GetCurrentEra() == 0 and pCapital:GetNumBuilding(ibRes_Man) <  2 then
		pCapital:SetNumRealBuilding(ibRes_Man, 2)
	end
	-------------Minor Has Res-ManPower----------------------
	
	local ibRes_Con = GameInfoTypes["BUILDING_CIV_S_P_CON_RESOURCES"]
	if     pPlayer:GetCurrentEra() >= 4 and pCapital:GetNumBuilding(ibRes_Con) < 12 then
		pCapital:SetNumRealBuilding(ibRes_Con,12)
	elseif pPlayer:GetCurrentEra() == 3 and pCapital:GetNumBuilding(ibRes_Con) <  9 then
		pCapital:SetNumRealBuilding(ibRes_Con, 9)
	elseif pPlayer:GetCurrentEra() == 2 and pCapital:GetNumBuilding(ibRes_Con) <  6 then
		pCapital:SetNumRealBuilding(ibRes_Con, 6)
	elseif pPlayer:GetCurrentEra() == 1 and pCapital:GetNumBuilding(ibRes_Con) <  4 then
		pCapital:SetNumRealBuilding(ibRes_Con, 4)
	end
	----------------Minor Has Res-Consumer----------------------
	
	local ibRes_Ele = GameInfoTypes["BUILDING_CIV_S_P_ELE_RESOURCES"]
	if not pPlayer:HasPolicy(GameInfoTypes["POLICY_MILITARY_AID"]) then
		return;
	elseif pPlayer:GetCurrentEra() >  6 and pCapital:GetNumBuilding(ibRes_Ele) <  8 then
		pCapital:SetNumRealBuilding(ibRes_Ele, 6)
	elseif pPlayer:GetCurrentEra() >  4 and pCapital:GetNumBuilding(ibRes_Ele) <  4 then
		pCapital:SetNumRealBuilding(ibRes_Ele, 3)
	end
	----------------Minor Has Res-Electricity----------------------
end
GameEvents.PlayerDoTurn.Add(MinorProvideRes)


------------------ Greek UB ------------------
local GreekOlympicsDummyMax = GameDefines["GREEK_UB_DUMMY_MAX"];

function GreekOlympicsBuildingsEffectConstruct(iPlayer, iCity, iBuilding, bGold, bFaith)
	if iBuilding ~= GameInfoTypes["BUILDING_GREEK_OLYMPICS"] then
		return
	end

	local pPlayer = Players[iPlayer];
	if pPlayer == nil then
		return
	end

	local pCity = pPlayer:GetCityByID(iCity);
	if pCity == nil then
		return
	end

	print("GreekOlympicsBuildingsEffectConstruct");
	pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_GREEK_OLYMPICS_DUMMY"], 0);
	if pPlayer:CountNumBuildings(GameInfoTypes["BUILDING_GREEK_OLYMPICS_DUMMY"]) < GreekOlympicsDummyMax then
		pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_GREEK_OLYMPICS_DUMMY"], 1);
	end
end
GameEvents.CityConstructed.Add(GreekOlympicsBuildingsEffectConstruct);

function GreekOlympicsBuildingsEffectSold(iPlayer, iCity, iBuilding)
	if iBuilding ~= GameInfoTypes["BUILDING_GREEK_OLYMPICS"] then
		return;
	end

	local pPlayer = Players[iPlayer];
	if pPlayer == nil then
		return;
	end

	print("GreekOlympicsBuildingsEffectSold");

	local count = 0;
	for pCity in pPlayer:Cities() do
		pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_GREEK_OLYMPICS_DUMMY"], 0);
		if pCity:GetNumBuilding(GameInfoTypes["BUILDING_GREEK_OLYMPICS"]) > 0 and count < GreekOlympicsDummyMax then
			count = count + 1;
			pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_GREEK_OLYMPICS_DUMMY"], 1);
		end

		if count >= 20 then
			break;
		end
	end

	print("GreekOlympicsBuildingsEffectSold: reset - ", count);
end
GameEvents.CitySoldBuilding.Add(GreekOlympicsBuildingsEffectSold);
------------------ Greek UB END ------------------

------------------ Portugal UB BEGIN ------------------
GameEvents.TradeRouteMove.Add(function(iX, iY, iUnit, iOwner, iOriginalPlayer, iOriginalCity, iDestPlayer, iDestCity)
	local pOnwer = Players[iOwner];
	if pOnwer == nil or not pOnwer:IsAlive() then
		return;
	end

	local plot = Map.GetPlot(iX, iY);
	if plot == nil then
		return;
	end

	if not plot:IsWater() and not plot:IsCity() then
		return;
	end

	local pCity = plot:GetWorkingCity();
	if pCity == nil then
		print("TradeRouteMove-Portugal-UB: pCity == nil");
		return;
	end

	if not pCity:IsHasBuilding(GameInfoTypes["BUILDING_PORTUGAL_PORT"]) then
		print("TradeRouteMove-Portugal-UB: do not have BUILDING_PORTUGAL_PORT");
		return;
	end

	local pCityOwner = Players[pCity:GetOwner()];
	local iGold = 5 * (2 + pCityOwner:GetCurrentEra());
	pCityOwner:ChangeGold(iGold);

	if pCityOwner:IsHuman() then
		local hex = ToHexFromGrid(Vector2(iX, iY));
		Events.AddPopupTextEvent(HexToWorld(hex), Locale.ConvertTextKey("+{1_Num}[ICON_GOLD]", iGold));
	end
	print("TradeRouteMove-Portugal-UB: gain ", iGold);
end
)
------------------ Portugal UB END   ------------------

------------------ CARTHAGINIAN_AGORA BEGIN   ------------------
local CarthaginianAgoraDummyPolicyCommerce = GameInfoTypes["POLICY_BUILDING_CARTHAGINIAN_AGORA_COMMERCE"];
local CarthaginianAgoraDummyPolicyExploration = GameInfoTypes["POLICY_BUILDING_CARTHAGINIAN_AGORA_EXPLORATION"];
local CarthaginianAgoraBuildingID = GameInfoTypes["BUILDING_CARTHAGINIAN_AGORA"];
function UpdateCarthaginanUWEffect(iPlayerID)
	local pPlayer = Players[iPlayerID];
	if pPlayer == nil or not pPlayer:IsMajorCiv() then
		return;
	end

	local bHaveUW = pPlayer:CountNumBuildings(CarthaginianAgoraBuildingID) > 0;

	local bAdoptCommerce = pPlayer:HasPolicyBranch(GameInfoTypes["POLICY_BRANCH_COMMERCE"]);
	local bHaveDummyCommerce = pPlayer:HasPolicy(CarthaginianAgoraDummyPolicyCommerce) and not pPlayer:IsPolicyBlocked(CarthaginianAgoraDummyPolicyCommerce);
	local bShouldHaveDummyCommerce = bAdoptCommerce and bHaveUW;
	-- print("CARTHAGINIAN_AGORA: @1", bHaveUW, bAdoptCommerce, bHaveDummyCommerce, bShouldHaveDummyCommerce);
	if bShouldHaveDummyCommerce ~= bHaveDummyCommerce then
		print("CARTHAGINIAN_AGORA: commerce: ", bShouldHaveDummyCommerce);
		pPlayer:SetHasPolicy(CarthaginianAgoraDummyPolicyCommerce, bShouldHaveDummyCommerce, true);
	end

		
	local bAdoptExploration = pPlayer:HasPolicyBranch(GameInfoTypes["POLICY_BRANCH_EXPLORATION"]);
	local bHaveDummyExploration = pPlayer:HasPolicy(CarthaginianAgoraDummyPolicyExploration) and not pPlayer:IsPolicyBlocked(CarthaginianAgoraDummyPolicyExploration);
	local bShouldHaveDummyExploration = bAdoptExploration and bHaveUW;
	-- print("CARTHAGINIAN_AGORA: @2", bHaveUW, bAdoptExploration, bHaveDummyExploration, bShouldHaveDummyExploration);
	if bShouldHaveDummyExploration ~= bHaveDummyExploration then
		print("CARTHAGINIAN_AGORA: exploration: ", bShouldHaveDummyExploration);
		pPlayer:SetHasPolicy(CarthaginianAgoraDummyPolicyExploration, bShouldHaveDummyExploration, true);
	end
end

GameEvents.PlayerDoTurn.Add(UpdateCarthaginanUWEffect);
GameEvents.PlayerAdoptPolicy.Add(function(iPlayerID, iPolicyID) UpdateCarthaginanUWEffect(iPlayerID); end);
------------------ CARTHAGINIAN_AGORA END   ------------------

function ASHUR_TEMPLEGetFoodAndFaith(iPlayer, iUnit, iUnitType, iX, iY, bDelay, iByPlayer)
	local pPlayer = Players[iPlayer]
	local pUnit = pPlayer:GetUnitByID(iUnit)
	local ByPlayer = Players[iByPlayer]
	if iPlayer == iByPlayer then return end
	if iByPlayer == -1 then return end

	if pPlayer == nil
	then
		return
	end

	if not pUnit:IsCombatUnit() then return end

	if ByPlayer == nil or ByPlayer:CountNumBuildings(GameInfoTypes["BUILDING_ASSUR_TEMPLE"]) == 0 then
		print("@1")
		return
	end

	local plot = pUnit:GetPlot()
	local iStrength = pUnit:GetBaseCombatStrength()
	local iFoodBoost = iStrength * 0.5
	local iFaithdBoost = iStrength * 0.5
	for LoopPlot in PlotAreaSpiralIterator(plot, 6, SECTOR_NORTH, DIRECTION_CLOCKWISE, DIRECTION_OUTWARDS, CENTRE_EXCLUDE) do
		if LoopPlot:IsCity() then
			local pCity = LoopPlot:GetPlotCity()
			if pCity:GetOwner() == iByPlayer then
				if pCity:IsHasBuilding(GameInfoTypes["BUILDING_ASSUR_TEMPLE"]) then
					ByPlayer:ChangeFaith(iFaithdBoost)
					pCity:ChangeFood(iFoodBoost)
					if ByPlayer:IsHuman() then
						local hex = ToHexFromGrid(Vector2(pCity:GetX(), pCity:GetY()));
						Events.AddPopupTextEvent(HexToWorld(hex), Locale.ConvertTextKey("+{1_Num}[ICON_PEACE] +{2_Num}[ICON_FOOD]", iFaithdBoost, iFoodBoost))
					end
				end
			end
		end
	end
end
GameEvents.UnitPrekill.Add(ASHUR_TEMPLEGetFoodAndFaith)
if Game.IsCivEverActive(GameInfoTypes.CIVILIZATION_ZULU) then
	GameEvents.UnitPromoted.Add(function(iPlayer, iUnit, iPromotionType)
		local pPlayer = Players[iPlayer];
		if pPlayer == nil then
			return;
		end

		if pPlayer:CountNumBuildings(GameInfoTypes["BUILDING_ZULU_IZIKO"]) == 0 then
			return;
		end

		local iBonus = 1 + 2 * pPlayer:GetCurrentEra();
		for city in pPlayer:Cities() do
			if city:IsHasBuilding(GameInfoTypes["BUILDING_ZULU_IZIKO"]) then
				city:ChangeJONSCultureStored(iBonus);
				pPlayer:ChangeJONSCulture(iBonus);

				if pPlayer:IsHuman() and pPlayer:IsTurnActive() then
					local hex = ToHexFromGrid(Vector2(city:GetX(), city:GetY()));
					Events.AddPopupTextEvent(HexToWorld(hex),
						Locale.ConvertTextKey("[COLOR_MAGENTA]+{1_Num}[ICON_CULTURE][ENDCOLOR]", iBonus));
				end
			end
		end
	end)
end
print("New Building Effects Check Pass!")


---------------------------------------------------------Utilities---------------------------------------------------------

