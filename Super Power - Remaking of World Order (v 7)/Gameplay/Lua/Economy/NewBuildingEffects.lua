-- NewBuildingEffects
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
	if iBuildingClass == GameInfo.BuildingClasses.BUILDINGCLASS_ARMORY.ID or iBuildingClass == GameInfo.BuildingClasses.BUILDINGCLASS_ARSENAL.ID then
		if not player:IsHuman() then
			local MAID = GameInfo.Buildings.BUILDING_MILITARY_ACADEMY.ID
			pCity:SetNumRealBuilding(MAID, 1)
			print("AI Free Military Academy!")
			if player:HasTrait(GameInfoTypes["TRAIT_FIGHT_WELL_DAMAGED"])
			then
				local DJID = GameInfo.Buildings.BUILDING_JAPANESE_DOJO.ID
				pCity:SetNumRealBuilding(DJID, 1)
				print("Japan AI free Dojo!")
			end
		end

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

			-- MoveMark
			oCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CAPITAL_MOVEMARK"], 0)
			pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CAPITAL_MOVEMARK"], 1)

			for building in GameInfo.Buildings() do
				-- Palace
				if oCity:IsHasBuilding(building.ID) and building.Capital then
					local i = oCity:GetNumBuilding(building.ID);
					oCity:SetNumRealBuilding(building.ID, 0);
					pCity:SetNumRealBuilding(building.ID, i);
				end

				-- Remove "Corrupt" from New
				if pCity:IsHasBuilding(building.ID)
					and (building.BuildingClass == "BUILDINGCLASS_CITY_HALL_LV1"
						or building.BuildingClass == "BUILDINGCLASS_CITY_HALL_LV2"
						or building.BuildingClass == "BUILDINGCLASS_CITY_HALL_LV3"
						or building.BuildingClass == "BUILDINGCLASS_CITY_HALL_LV4"
						or building.BuildingClass == "BUILDINGCLASS_CITY_HALL_LV5"
						or building.BuildingClass == "BUILDINGCLASS_PUPPET_GOVERNEMENT"
						or building.BuildingClass == "BUILDINGCLASS_CONSTABLE"
						or building.BuildingClass == "BUILDINGCLASS_SHERIFF_OFFICE"
						or building.BuildingClass == "BUILDINGCLASS_POLICE_STATION"
						or building.BuildingClass == "BUILDINGCLASS_PROCURATORATE"
					) then
					pCity:SetNumRealBuilding(building.ID, 0);
				end

				-- Move Policy Buildings & Count Buildings
				local policFreeBCCapital = GameInfo.Policy_FreeBuildingClassCapital { BuildingClassType = building.BuildingClass } ()
				if oCity:IsHasBuilding(building.ID) and (policFreeBCCapital ~= nil) then
					local i = oCity:GetNumBuilding(building.ID);
					oCity:SetNumRealBuilding(building.ID, 0);
					pCity:SetNumRealBuilding(building.ID, i);
				end
			end
			print("Captial Moved!")
		end
	end
end ------Function End

GameEvents.CityConstructed.Add(NewBuildingEffects)

-------Auto replacement for obsolete buildings, currently only for human player for stability issues
function AutoBuildingReplace(ePlayer, iTech, bAdopted)

	local player = Players[ePlayer]
	if player == nil or not player:IsHuman() then return end

	if player:GetNumCities() > 0 then
		print("Auto Buildings Replacement!")

		local text

		local iOldBuilding = -1;
		local iNewBuilding = -1;
		local overrideBuilding = nil;
		local bIsDoAddNBuilding = false;

		if iTech == GameInfoTypes["TECH_DYNAMITE"] then
			print("tech: DYNAMITE")
			for city in player:Cities() do
				bIsDoAddNBuilding = false;
				iOldBuilding = GameInfoTypes["BUILDINGCLASS_STONE_WORKS"]
				if city:IsHasBuildingClass(iOldBuilding) then
					bIsDoAddNBuilding = true;
					iOldBuilding = player:GetCivBuilding(iOldBuilding)
				end
				if not bIsDoAddNBuilding then
					iOldBuilding = GameInfoTypes["BUILDINGCLASS_SAWMILL"]
					if city:IsHasBuildingClass(iOldBuilding) then
						bIsDoAddNBuilding = true;
						iOldBuilding = player:GetCivBuilding(iOldBuilding)
					end
				end

				if bIsDoAddNBuilding then
					iNewBuilding = player:GetCivBuilding(GameInfoTypes["BUILDINGCLASS_MINGING_FACTORY"])
					city:SetNumRealBuilding(iNewBuilding, 1);

					text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_AUTO_BUILDING_REPLACEMENT", city:GetName(),
						GameInfo.Buildings[iOldBuilding].Description)
					text = text .. Locale.ConvertTextKey(GameInfo.Buildings[iNewBuilding].Description)
					Events.GameplayAlertMessage(text)
				end
			end
		elseif iTech == GameInfoTypes["TECH_INDUSTRIALIZATION"] then
			print("tech: INDUSTRIALIZATION")
			for city in player:Cities() do
				bIsDoAddNBuilding = false;
				iOldBuilding = GameInfoTypes["BUILDINGCLASS_WORKSHOP"]
				if city:IsHasBuildingClass(iOldBuilding) then
					bIsDoAddNBuilding = true;
					iOldBuilding = player:GetCivBuilding(iOldBuilding)
				end

				if bIsDoAddNBuilding then
					iNewBuilding = player:GetCivBuilding(GameInfoTypes["BUILDINGCLASS_FACTORY"])
					city:SetNumRealBuilding(iNewBuilding, 1);

					text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_AUTO_BUILDING_REPLACEMENT", city:GetName(),
						GameInfo.Buildings[iOldBuilding].Description)
					text = text .. Locale.ConvertTextKey(GameInfo.Buildings[iNewBuilding].Description)
					Events.GameplayAlertMessage(text)
				end

				bIsDoAddNBuilding = false;
				iOldBuilding = GameInfoTypes["BUILDINGCLASS_GRAIN_MILL"]
				if city:IsHasBuildingClass(iOldBuilding) then
					bIsDoAddNBuilding = true;
					iOldBuilding = player:GetCivBuilding(iOldBuilding)
				end
				if not bIsDoAddNBuilding then
					iOldBuilding = GameInfoTypes["BUILDINGCLASS_WATERMILL"]
					if city:IsHasBuildingClass(iOldBuilding) then
						bIsDoAddNBuilding = true;
						iOldBuilding = player:GetCivBuilding(iOldBuilding)
					end
				end
				if not bIsDoAddNBuilding then
					iOldBuilding = GameInfoTypes["BUILDINGCLASS_STABLE"]
					if city:IsHasBuildingClass(iOldBuilding) then
						bIsDoAddNBuilding = true;
						iOldBuilding = player:GetCivBuilding(iOldBuilding)
					end
				end
				if not bIsDoAddNBuilding then
					iOldBuilding = GameInfoTypes["BUILDINGCLASS_WINDMILL"]
					if city:IsHasBuildingClass(iOldBuilding) then
						bIsDoAddNBuilding = true;
						iOldBuilding = player:GetCivBuilding(iOldBuilding)
					end
				end

				if bIsDoAddNBuilding then
					iNewBuilding = player:GetCivBuilding(GameInfoTypes["BUILDINGCLASS_MECHANIZED_FARM"])
					city:SetNumRealBuilding(iNewBuilding, 1);

					text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_AUTO_BUILDING_REPLACEMENT", city:GetName(),
						GameInfo.Buildings[iOldBuilding].Description)
					text = text .. Locale.ConvertTextKey(GameInfo.Buildings[iNewBuilding].Description)
					Events.GameplayAlertMessage(text)
				end
			end
		elseif iTech == GameInfoTypes["TECH_FERTILIZER"] then
			print("tech: FERTILIZER")
			for city in player:Cities() do
				bIsDoAddNBuilding = false;
				iOldBuilding = GameInfoTypes["BUILDINGCLASS_FISH_FARM"]
				if city:IsHasBuildingClass(iOldBuilding) then
					bIsDoAddNBuilding = true;
					iOldBuilding = player:GetCivBuilding(iOldBuilding)
				end
				if not bIsDoAddNBuilding then
					iOldBuilding = GameInfoTypes["BUILDINGCLASS_GRANARY"]
					if city:IsHasBuildingClass(iOldBuilding) then
						bIsDoAddNBuilding = true;
						iOldBuilding = player:GetCivBuilding(iOldBuilding)
					end
				end

				if bIsDoAddNBuilding then
					iNewBuilding = player:GetCivBuilding(GameInfoTypes["BUILDINGCLASS_GRAIN_DEPOT"])
					city:SetNumRealBuilding(iNewBuilding, 1);

					text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_AUTO_BUILDING_REPLACEMENT", city:GetName(),
						GameInfo.Buildings[iOldBuilding].Description)
					text = text .. Locale.ConvertTextKey(GameInfo.Buildings[iNewBuilding].Description)
					Events.GameplayAlertMessage(text)
				end
			end
		elseif iTech == GameInfoTypes["TECH_URBANLIZATION"] then
			print("tech: URBANLIZATION")
			for city in player:Cities() do
				bIsDoAddNBuilding = false;
				iOldBuilding = GameInfoTypes["BUILDINGCLASS_AQUEDUCT"]
				if city:IsHasBuildingClass(iOldBuilding) then
					bIsDoAddNBuilding = true;
					iOldBuilding = player:GetCivBuilding(iOldBuilding)
				end

				if bIsDoAddNBuilding then
					iNewBuilding = player:GetCivBuilding(GameInfoTypes["BUILDINGCLASS_TAP_WATER_SUPPLY"])
					city:SetNumRealBuilding(iNewBuilding, 1);

					text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_AUTO_BUILDING_REPLACEMENT", city:GetName(),
						GameInfo.Buildings[iOldBuilding].Description)
					text = text .. Locale.ConvertTextKey(GameInfo.Buildings[iNewBuilding].Description)
					Events.GameplayAlertMessage(text)
				end
			end
		elseif iTech == GameInfoTypes["TECH_COMBUSTION"] then
			print("tech: COMBUSTION")
			for city in player:Cities() do
				bIsDoAddNBuilding = false;
				iOldBuilding = GameInfoTypes["BUILDINGCLASS_STAGECOACH"]
				if city:IsHasBuildingClass(iOldBuilding) then
					bIsDoAddNBuilding = true;
					iOldBuilding = player:GetCivBuilding(iOldBuilding)
				end

				if bIsDoAddNBuilding then
					iNewBuilding = player:GetCivBuilding(GameInfoTypes["BUILDINGCLASS_BUS_STATION"])
					city:SetNumRealBuilding(iNewBuilding, 1);

					text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_AUTO_BUILDING_REPLACEMENT", city:GetName(),
						GameInfo.Buildings[iOldBuilding].Description)
					text = text .. Locale.ConvertTextKey(GameInfo.Buildings[iNewBuilding].Description)
					Events.GameplayAlertMessage(text)
				end
			end
		elseif iTech == GameInfoTypes["TECH_RAILROAD"] then
			print("tech: RAILROAD")

			text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_AUTO_RAILROAD_REPLACEMENT")
			Events.GameplayAlertMessage(text)

			for plotLoop = 0, Map.GetNumPlots() - 1, 1 do
				local plot = Map.GetPlotByIndex(plotLoop)
				--Update All route
				if plot:GetRouteType() == GameInfo.Routes.ROUTE_ROAD.ID then
					plot:SetRouteType(GameInfo.Routes.ROUTE_RAILROAD.ID)
				end
			end
		else

		end
	end
end ------Function End

GameEvents.PlayerSetHasTech.Add(AutoBuildingReplace)

local ibRes_Man = GameInfoTypes["BUILDING_CIV_S_P_MAN_RESOURCES"]
local ibRes_Con = GameInfoTypes["BUILDING_CIV_S_P_CON_RESOURCES"]
local ibRes_Ele = GameInfoTypes["BUILDING_CIV_S_P_ELE_RESOURCES"]

function MinorProvideRes(iPlayerID)
	local pMinor  = Players[iPlayerID]
	if pMinor == nil or not pMinor:IsMinorCiv() or pMinor:GetCapitalCity() == nil or pMinor:GetAlly() < 0 then return end
	local pPlayer = Players[pMinor:GetAlly()]
	if pPlayer == nil then return end

	local iAllyEra = pPlayer:GetCurrentEra()
	local pCapital = pMinor:GetCapitalCity()
	
	-------------Minor Has Res-ManPower----------------------
	if iAllyEra >= 3 and pCapital:GetNumBuilding(ibRes_Man) < 10 then
		pCapital:SetNumRealBuilding(ibRes_Man, 10)
	elseif iAllyEra == 2 and pCapital:GetNumBuilding(ibRes_Man) < 6 then
		pCapital:SetNumRealBuilding(ibRes_Man, 6)
	elseif iAllyEra == 1 and pCapital:GetNumBuilding(ibRes_Man) < 3 then
		pCapital:SetNumRealBuilding(ibRes_Man, 3)
	elseif iAllyEra == 0 and pCapital:GetNumBuilding(ibRes_Man) < 2 then
		pCapital:SetNumRealBuilding(ibRes_Man, 2)
	end
	----------------Minor Has Res-Consumer----------------------
	if iAllyEra >= 4 and pCapital:GetNumBuilding(ibRes_Con) < 12 then
		pCapital:SetNumRealBuilding(ibRes_Con, 12)
	elseif iAllyEra == 3 and pCapital:GetNumBuilding(ibRes_Con) < 9 then
		pCapital:SetNumRealBuilding(ibRes_Con, 9)
	elseif iAllyEra == 2 and pCapital:GetNumBuilding(ibRes_Con) < 6 then
		pCapital:SetNumRealBuilding(ibRes_Con, 6)
	elseif iAllyEra == 1 and pCapital:GetNumBuilding(ibRes_Con) < 4 then
		pCapital:SetNumRealBuilding(ibRes_Con, 4)
	end
	----------------Minor Has Res-Electricity----------------------
	if not pPlayer:HasPolicy(GameInfoTypes["POLICY_MILITARY_AID"]) then
		return;
	elseif iAllyEra > 6 and pCapital:GetNumBuilding(ibRes_Ele) < 8 then
		pCapital:SetNumRealBuilding(ibRes_Ele, 6)
	elseif iAllyEra > 4 and pCapital:GetNumBuilding(ibRes_Ele) < 4 then
		pCapital:SetNumRealBuilding(ibRes_Ele, 3)
	end
end
GameEvents.PlayerDoTurn.Add(MinorProvideRes)

print("New Building Effects Check Pass!")