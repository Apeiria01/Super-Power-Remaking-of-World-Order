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
	if iBuildingClass == GameInfo.BuildingClasses.BUILDINGCLASS_ARMORY.ID or iBuildingClass == GameInfo.BuildingClasses.BUILDINGCLASS_ARSENAL.ID then
		if not player:IsHuman() then
			local MAID = GameInfo.Buildings.BUILDING_MILITARY_ACADEMY.ID
			pCity:SetNumRealBuilding(MAID, 1)
			print("AI Free Military Academy!")
			if GameInfo.Leader_Traits { LeaderType = GameInfo.Leaders[player:GetLeaderType()].Type, TraitType =
				"TRAIT_FIGHT_WELL_DAMAGED" } ()
				and (GameInfo.Traits["TRAIT_FIGHT_WELL_DAMAGED"].PrereqPolicy == nil or (GameInfo.Traits["TRAIT_FIGHT_WELL_DAMAGED"].PrereqPolicy
					and player:HasPolicy(GameInfoTypes[GameInfo.Traits["TRAIT_FIGHT_WELL_DAMAGED"].PrereqPolicy])))
			then
				local DJID = GameInfo.Buildings.BUILDING_JAPANESE_DOJO.ID
				pCity:SetNumRealBuilding(DJID, 1)
				print("Japan AI free Dojo!")
			end
		end

		-- Terracotta Army provides Barracks, Armory and Military Academy
	elseif iBuilding == GameInfo.Buildings.BUILDING_TERRACOTTA_ARMY.ID then
		pCity:SetNumRealBuildingClass(GameInfo.BuildingClasses.BUILDINGCLASS_BARRACKS.ID, 1);
		pCity:SetNumRealBuildingClass(GameInfo.BuildingClasses.BUILDINGCLASS_ARMORY.ID, 1);
		pCity:SetNumRealBuildingClass(GameInfo.BuildingClasses.BUILDINGCLASS_MILITARY_ACADEMY.ID, 1);

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
				oCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CAPITAL_MOVEMARK"], 0)
				pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_CAPITAL_MOVEMARK"], 1)
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
				iOldBuilding = player:GetCivBuilding(GameInfoTypes["BUILDINGCLASS_STONE_WORKS"])
				if city:IsHasBuilding(iOldBuilding) then
					bIsDoAddNBuilding = true;
				end
				if not bIsDoAddNBuilding then
					iOldBuilding = player:GetCivBuilding(GameInfoTypes["BUILDINGCLASS_SAWMILL"])
					if city:IsHasBuilding(iOldBuilding) then
						bIsDoAddNBuilding = true;
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
				iOldBuilding = player:GetCivBuilding(GameInfoTypes["BUILDINGCLASS_WORKSHOP"])
				if city:IsHasBuilding(iOldBuilding) then
					bIsDoAddNBuilding = true;
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
				iOldBuilding = player:GetCivBuilding(GameInfoTypes["BUILDINGCLASS_GRAIN_MILL"])
				if city:IsHasBuilding(iOldBuilding) then
					bIsDoAddNBuilding = true;
				end
				if not bIsDoAddNBuilding then
					iOldBuilding = player:GetCivBuilding(GameInfoTypes["BUILDINGCLASS_WATERMILL"])
					if city:IsHasBuilding(iOldBuilding) then
						bIsDoAddNBuilding = true;
					end
				end
				if not bIsDoAddNBuilding then
					iOldBuilding = player:GetCivBuilding(GameInfoTypes["BUILDINGCLASS_STABLE"])
					if city:IsHasBuilding(iOldBuilding) then
						bIsDoAddNBuilding = true;
					end
				end
				if not bIsDoAddNBuilding then
					iOldBuilding = player:GetCivBuilding(GameInfoTypes["BUILDINGCLASS_WINDMILL"])
					if city:IsHasBuilding(iOldBuilding) then
						bIsDoAddNBuilding = true;
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
				iOldBuilding = player:GetCivBuilding(GameInfoTypes["BUILDINGCLASS_FISH_FARM"])
				if city:IsHasBuilding(iOldBuilding) then
					bIsDoAddNBuilding = true;
				end
				if not bIsDoAddNBuilding then
					iOldBuilding = player:GetCivBuilding(GameInfoTypes["BUILDINGCLASS_GRANARY"])
					if city:IsHasBuilding(iOldBuilding) then
						bIsDoAddNBuilding = true;
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
				iOldBuilding = player:GetCivBuilding(GameInfoTypes["BUILDINGCLASS_AQUEDUCT"])
				if city:IsHasBuilding(iOldBuilding) then
					bIsDoAddNBuilding = true;
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
				iOldBuilding = player:GetCivBuilding(GameInfoTypes["BUILDINGCLASS_STAGECOACH"])
				if city:IsHasBuilding(iOldBuilding) then
					bIsDoAddNBuilding = true;
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

GameEvents.TeamSetHasTech.Add(AutoBuildingReplace)

function MinorProvideRes(iPlayerID)
	local pMinor  = Players[iPlayerID]
	local pPlayer = Players[Game.GetActivePlayer()]

	if pMinor == nil or not pMinor:IsMinorCiv() or pMinor:GetCapitalCity() == nil
		or pPlayer == nil or not pPlayer:IsHuman()
	then
		return
	end

	local pCapital = pMinor:GetCapitalCity()
	local ibRes_Man = GameInfoTypes["BUILDING_CIV_S_P_MAN_RESOURCES"]
	if pPlayer:GetCurrentEra() >= 3 and pCapital:GetNumBuilding(ibRes_Man) < 10 then
		pCapital:SetNumRealBuilding(ibRes_Man, 10)
	elseif pPlayer:GetCurrentEra() == 2 and pCapital:GetNumBuilding(ibRes_Man) < 6 then
		pCapital:SetNumRealBuilding(ibRes_Man, 6)
	elseif pPlayer:GetCurrentEra() == 1 and pCapital:GetNumBuilding(ibRes_Man) < 3 then
		pCapital:SetNumRealBuilding(ibRes_Man, 3)
	elseif pPlayer:GetCurrentEra() == 0 and pCapital:GetNumBuilding(ibRes_Man) < 2 then
		pCapital:SetNumRealBuilding(ibRes_Man, 2)
	end
	-------------Minor Has Res-ManPower----------------------

	local ibRes_Con = GameInfoTypes["BUILDING_CIV_S_P_CON_RESOURCES"]
	if pPlayer:GetCurrentEra() >= 4 and pCapital:GetNumBuilding(ibRes_Con) < 12 then
		pCapital:SetNumRealBuilding(ibRes_Con, 12)
	elseif pPlayer:GetCurrentEra() == 3 and pCapital:GetNumBuilding(ibRes_Con) < 9 then
		pCapital:SetNumRealBuilding(ibRes_Con, 9)
	elseif pPlayer:GetCurrentEra() == 2 and pCapital:GetNumBuilding(ibRes_Con) < 6 then
		pCapital:SetNumRealBuilding(ibRes_Con, 6)
	elseif pPlayer:GetCurrentEra() == 1 and pCapital:GetNumBuilding(ibRes_Con) < 4 then
		pCapital:SetNumRealBuilding(ibRes_Con, 4)
	end
	----------------Minor Has Res-Consumer----------------------

	local ibRes_Ele = GameInfoTypes["BUILDING_CIV_S_P_ELE_RESOURCES"]
	if not pPlayer:HasPolicy(GameInfoTypes["POLICY_MILITARY_AID"]) then
		return;
	elseif pPlayer:GetCurrentEra() > 6 and pCapital:GetNumBuilding(ibRes_Ele) < 8 then
		pCapital:SetNumRealBuilding(ibRes_Ele, 6)
	elseif pPlayer:GetCurrentEra() > 4 and pCapital:GetNumBuilding(ibRes_Ele) < 4 then
		pCapital:SetNumRealBuilding(ibRes_Ele, 3)
	end
	----------------Minor Has Res-Electricity----------------------
end

GameEvents.PlayerDoTurn.Add(MinorProvideRes)


------------------ Greek UB ------------------
if Game.IsCivEverActive(GameInfoTypes.CIVILIZATION_GREECE) then
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
end
------------------ Greek UB END ------------------

------------------ Portugal UB BEGIN ------------------
if Game.IsCivEverActive(GameInfoTypes.CIVILIZATION_PORTUGAL) then
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
			-- print("TradeRouteMove-Portugal-UB: pCity == nil");
			return;
		end

		if not pCity:IsHasBuilding(GameInfoTypes["BUILDING_PORTUGAL_PORT"]) then
			-- print("TradeRouteMove-Portugal-UB: do not have BUILDING_PORTUGAL_PORT");
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
end
------------------ Portugal UB END   ------------------

------------------ CARTHAGINIAN_AGORA BEGIN   ------------------

if Game.IsCivEverActive(GameInfoTypes.CIVILIZATION_CARTHAGE) then
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
		local bHaveDummyCommerce = pPlayer:HasPolicy(CarthaginianAgoraDummyPolicyCommerce) and
		not pPlayer:IsPolicyBlocked(CarthaginianAgoraDummyPolicyCommerce);
		local bShouldHaveDummyCommerce = bAdoptCommerce and bHaveUW;
		if bShouldHaveDummyCommerce ~= bHaveDummyCommerce then
			print("CARTHAGINIAN_AGORA: commerce: ", bShouldHaveDummyCommerce);
			pPlayer:SetHasPolicy(CarthaginianAgoraDummyPolicyCommerce, bShouldHaveDummyCommerce, true);
		end


		local bAdoptExploration = pPlayer:HasPolicyBranch(GameInfoTypes["POLICY_BRANCH_EXPLORATION"]);
		local bHaveDummyExploration = pPlayer:HasPolicy(CarthaginianAgoraDummyPolicyExploration) and
		not pPlayer:IsPolicyBlocked(CarthaginianAgoraDummyPolicyExploration);
		local bShouldHaveDummyExploration = bAdoptExploration and bHaveUW;
		if bShouldHaveDummyExploration ~= bHaveDummyExploration then
			print("CARTHAGINIAN_AGORA: exploration: ", bShouldHaveDummyExploration);
			pPlayer:SetHasPolicy(CarthaginianAgoraDummyPolicyExploration, bShouldHaveDummyExploration, true);
		end
	end

	GameEvents.PlayerDoTurn.Add(UpdateCarthaginanUWEffect);
	GameEvents.PlayerAdoptPolicy.Add(function(iPlayerID, iPolicyID) UpdateCarthaginanUWEffect(iPlayerID); end);
end
------------------ CARTHAGINIAN_AGORA END   ------------------

if Game.IsCivEverActive(GameInfoTypes.CIVILIZATION_ASSYRIA) then
	local assurTemple = GameInfoTypes["BUILDING_ASSUR_TEMPLE"]
	function ASHUR_TEMPLEGetFoodAndFaith(iPlayer, iKilledPlayer, iUnitType, iKillingUnit, iKilledUnit)
		if iPlayer == iKilledPlayer or iPlayer == -1 then return end
		local pPlayer = Players[iKilledPlayer]
		local ByPlayer = Players[iPlayer]
		if ByPlayer == nil or pPlayer == nil then return end
		if ByPlayer:CountNumBuildings(assurTemple) == 0 then return end

		local pUnit = pPlayer:GetUnitByID(iKilledUnit)
		local plot = pUnit:GetPlot()
		if pUnit == nil or plot == nil then return end
		local iX = plot:GetX()
		local iY = plot:GetY()
		
		local iStrength = pUnit:GetBaseCombatStrength()
		if iStrength <= 0 then return end

		local iFoodBoost = iStrength * 0.5
		local iFaithdBoost = iStrength * 0.5
		
		for iCity in ByPlayer:Cities() do
			if iCity:IsHasBuilding(assurTemple)
			and Map.PlotDistance(iX, iY, iCity:GetX(), iCity:GetY()) <= 6
			then
				ByPlayer:ChangeFaith(iFaithdBoost)
				iCity:ChangeFood(iFoodBoost)
				if ByPlayer:IsHuman() then
					local hex = ToHexFromGrid(Vector2(iCity:GetX(), iCity:GetY()));
					Events.AddPopupTextEvent(HexToWorld(hex),
					Locale.ConvertTextKey("+{1_Num}[ICON_PEACE] +{2_Num}[ICON_FOOD]", iFaithdBoost,iFoodBoost))
				end
			end
		end
	end
	GameEvents.UnitKilledInCombat.Add(ASHUR_TEMPLEGetFoodAndFaith)
end

if Game.IsCivEverActive(GameInfoTypes.CIVILIZATION_ZULU) then
	GameEvents.UnitPromoted.Add(function(iPlayer, iUnit, iPromotionType)
		local pPlayer = Players[iPlayer];
		if pPlayer == nil then
			return;
		end

		if pPlayer:CountNumBuildings(GameInfoTypes["BUILDING_ZULU_IZIKO"]) == 0 then
			return;
		end

		local iBonus = 1 + pPlayer:GetCurrentEra();
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

if Game.IsCivEverActive(GameInfoTypes.CIVILIZATION_ARABIA) then
	local iIsiamicFactor = GameDefines["ARABIA_ISIAMIC_UNIVERSITY_FACTOR"] or 7;
	local eIsiamicSchool = GameInfoTypes["BUILDING_ARABIA_ISIAMIC_UNIVERSITY"]
	local eIsiamicUniversityAllahAkbar = GameInfoTypes["BUILDING_ARABIA_ISIAMIC_UNIVERSITY_ALLAH_AKBAR"]

	local faithBuildingCollection1 = {}
	local faithBuildingCollection2 = {}
	for building in GameInfo.Buildings() do
		if building.Type ~= "BUILDING_ARABIA_ISIAMIC_UNIVERSITY_ALLAH_AKBAR" then
			if (building.FaithCost > 0 and building.Cost == -1) or
				building.BuildingClass == "BUILDINGCLASS_SHRINE" or
				building.BuildingClass == "BUILDINGCLASS_TEMPLE" then
				faithBuildingCollection1[building.ID] = true
			elseif GameInfo.Building_YieldChanges {
					BuildingType = building.Type,
					YieldType = "YIELD_FAITH",
				} () then
				faithBuildingCollection2[building.ID] = true
			end
		end
	end

	function setIsiamSchoolEffect(pCity, iNumBonusFactor)
		if pCity == nil then
			return
		end
		if pCity:IsPuppet() then
			pCity:SetNumRealBuilding(eIsiamicUniversityAllahAkbar, 0)
			return
		end

		local iNumBonus = 0;
		local iNumFaithBuildingInCollection1 = 0
		for i, v in pairs(faithBuildingCollection1) do
			if v == true and pCity:IsHasBuilding(i) then
				iNumFaithBuildingInCollection1 = iNumFaithBuildingInCollection1 + 1
			end
		end
		iNumBonus = iNumBonus + iNumFaithBuildingInCollection1 * iNumBonusFactor

		local bHasLab = pCity:IsHasBuilding(GameInfoTypes["BUILDING_LABORATORY"])
		if bHasLab then
			local iNumFaithBuildingInCollection2 = 0
			for i, v in pairs(faithBuildingCollection2) do
				if v == true and pCity:IsHasBuilding(i) then
					iNumFaithBuildingInCollection2 = iNumFaithBuildingInCollection2 + 1
				end
			end
			iNumBonus = iNumBonus + iNumFaithBuildingInCollection2 * iNumBonusFactor
		end

		pCity:SetNumRealBuilding(eIsiamicUniversityAllahAkbar, iNumBonus)
	end

	GameEvents.PlayerDoTurn.Add(function(iPlayer)
		local pPlayer = Players[iPlayer]
		if pPlayer == nil or not pPlayer:IsAlive() then
			return
		end
		if pPlayer:GetCivilizationType() ~= GameInfoTypes.CIVILIZATION_ARABIA then
			return
		end

		local iNumIsiamicSchool = pPlayer:CountNumBuildings(eIsiamicSchool)
		local iNumBonusFactor = math.floor(iNumIsiamicSchool / iIsiamicFactor)

		for city in pPlayer:Cities() do
			setIsiamSchoolEffect(city, iNumBonusFactor)
		end
	end)
end

print("New Building Effects Check Pass!")


---------------------------------------------------------Utilities---------------------------------------------------------
