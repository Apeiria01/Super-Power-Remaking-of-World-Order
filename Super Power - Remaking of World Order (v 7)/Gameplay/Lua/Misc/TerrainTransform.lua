

--include( "UtilityFunctions.lua" )

--Road/Railroad turn mountain into hill

--function RoadChangeMountain(iHexX, iHexY, iPlayerID, iRouteType)
--	local pPlot = Map.GetPlot(ToGridFromHex(iHexX, iHexY))
--	
--	if pPlot == nil then
--		return
--	end
--	
--	if pPlot:IsMountain() then
--		pPlot:SetPlotType(PlotTypes.PLOT_HILLS, false, true)
--		print("Road on Mountain! Now it is Hill!")
--	end
--
--end
--
--Events.SerialEventRoadCreated.Add(RoadChangeMountain)
--
--


--Build Improvements Effects



function ImprovementBuilt(iPlayer, x, y, eImprovement)


	if Players[iPlayer] == nil then
		return
	end
	
	local player = Players[iPlayer]
--	if not player:IsHuman() then ------(only for human players for now)
--		print ("Improvement is built by AI, Not available for now because it may cause CTD!!!!")
--    	return
--	end
	

--	print ("Improvement Built:" ..eImprovement)
	local pPlot = Map.GetPlot(x, y)
	
	
	if pPlot == nil then
		return
	end
	
	
	--AI build Citadels
	if eImprovement == GameInfo.Improvements["IMPROVEMENT_FARM"].ID or eImprovement == GameInfo.Improvements["IMPROVEMENT_TRADING_POST"].ID or eImprovement == GameInfo.Improvements["IMPROVEMENT_LUMBERMILL"].ID then
	
		if player:GetUnitClassCount(GameInfo.UnitClasses.UNITCLASS_CITADEL_EARLY.ID) < player:GetNumCities() * 1.5 or player:GetUnitClassCount(GameInfo.UnitClasses.UNITCLASS_CITADEL_MID.ID) < player:GetNumCities() * 1.5 or player:GetUnitClassCount(GameInfo.UnitClasses.UNITCLASS_CITADEL_LATE.ID) < player:GetNumCities()* 1.5 and not player:IsHuman() then
			local pTeam = Teams[player:GetTeam()]
			if pTeam:IsHasTech(GameInfoTypes["TECH_GUNPOWDER"]) then
				if not PlotIsVisibleToHuman(pPlot) then
					if player:CanBuild (pPlot,GameInfo.Builds.BUILD_CITADEL.ID,iPlayer) then
						if pPlot:CanHaveImprovement (GameInfo.Improvements.IMPROVEMENT_CITADEL.ID, player:GetTeam()) then
							if pPlot:IsRoute() or pPlot:IsFreshWater() then
								print ("This is a good location for building a Citadel!")
								pPlot:SetImprovementType(-1)
								pPlot:SetFeatureType(-1)
								pPlot:SetImprovementType(GameInfo.Improvements["IMPROVEMENT_CITADEL"].ID)
								SetCitadelUnits(iPlayer, x, y)
								print ("AI built a Citadel!")
							end
						end
					end
				end
			end
		end
	end
	-----AI build Coastal Fort
	if eImprovement  == GameInfo.Improvements["IMPROVEMENT_FISHERY_MOD"].ID then
	
		if player:GetUnitClassCount(GameInfo.UnitClasses.UNITCLASS_CITADEL_EARLY.ID) < player:GetNumCities() * 1.5 or player:GetUnitClassCount(GameInfo.UnitClasses.UNITCLASS_CITADEL_MID.ID) < player:GetNumCities() * 1.5 or player:GetUnitClassCount(GameInfo.UnitClasses.UNITCLASS_CITADEL_LATE.ID) < player:GetNumCities()* 1.5 and not player:IsHuman() then
			local pTeam = Teams[player:GetTeam()]
			if pTeam:IsHasTech(GameInfoTypes["TECH_GUNPOWDER"]) then
				if not PlotIsVisibleToHuman(pPlot) then
					if player:CanBuild (pPlot,GameInfo.Builds.BUILD_CITADEL.ID,iPlayer) then
						if pPlot:CanHaveImprovement (GameInfo.Improvements.IMPROVEMENT_CITADEL.ID, player:GetTeam()) then
							if pPlot:IsAdjacentToLand() then
								print ("This is a good location for building a Coastal Fort!")
								pPlot:SetImprovementType(-1)
								pPlot:SetFeatureType(-1)
								pPlot:SetImprovementType(GameInfo.Improvements["IMPROVEMENT_COASTAL_FORT"].ID)
								SetCitadelUnits(iPlayer, x, y)
								print ("AI built a Coastal Fort!")
							end
						end
					end
				end
			end
		end
	end
	
	
	if     (eImprovement == GameInfo.Improvements["IMPROVEMENT_FARM"].ID) and pPlot:GetFeatureType() == FeatureTypes.FEATURE_FOREST then
	    -- Iroquois UA - Forest Farm
	    if  GameInfo.Leader_Traits{ LeaderType = GameInfo.Leaders[player:GetLeaderType()].Type, TraitType = "TRAIT_IGNORE_TERRAIN_IN_FOREST" }()
	    and(GameInfo.Traits["TRAIT_IGNORE_TERRAIN_IN_FOREST"].PrereqPolicy == nil or (GameInfo.Traits["TRAIT_IGNORE_TERRAIN_IN_FOREST"].PrereqPolicy 
	    and player:HasPolicy(GameInfoTypes[GameInfo.Traits["TRAIT_IGNORE_TERRAIN_IN_FOREST"].PrereqPolicy])))
	    then
	    -- other Civs - Remove Forest
	    else
		pPlot:SetFeatureType(-1, iPlayer);
	    end
	elseif (eImprovement == GameInfo.Improvements["IMPROVEMENT_FISHERY_MOD"].ID) then
		pPlot:SetImprovementType(-1)
		if pPlot:GetResourceType(-1) == -1 then
			
			pPlot:SetResourceType(GameInfoTypes.RESOURCE_FISH, 1)
		end
		pPlot:SetImprovementType(GameInfo.Improvements["IMPROVEMENT_FISHFARM_MOD"].ID)
		print ("fish farm created!")
		
--	elseif (eImprovement == GameInfo.Improvements["IMPROVEMENT_SAND_DREDGE_MOD"].ID) then
--		print ("Sand dredge ceated!")
--		pPlot:SetImprovementType(-1)
--		if pPlot:GetResourceType(-1) == -1 then
--			pPlot:SetResourceType(GameInfoTypes.RESOURCE_SAND_DREDGE, 1)
--		end
--		pPlot:SetImprovementType(GameInfo.Improvements["IMPROVEMENT_SAND_DREDGE_MOD"].ID)
		
	elseif (eImprovement == GameInfo.Improvements["IMPROVEMENT_GAS_RIG_MOD"].ID) then
		pPlot:SetImprovementType(-1)
		if pPlot:GetResourceType(-1) == -1 then
			pPlot:SetResourceType(GameInfoTypes.RESOURCE_NATRUALGAS, 1)
		end
		pPlot:SetImprovementType(GameInfo.Improvements["IMPROVEMENT_OFFSHORE_PLATFORM"].ID)
		print ("Gas Rig created!")
		
--	elseif (eImprovement == GameInfo.Improvements["IMPROVEMENT_IROQUOIAN_FOREST_FARM"].ID) then
--		pPlot:SetImprovementType(-1)
--		pPlot:SetImprovementType(GameInfo.Improvements["IMPROVEMENT_FARM"].ID)
--		print ("Farm in Forest created!")
		
	elseif (eImprovement == GameInfo.Improvements["IMPROVEMENT_ETHIOPIA_COFFEE"].ID) then
		if     pPlot:GetTerrainType() == TerrainTypes.TERRAIN_GRASS then
			pPlot:SetFeatureType(-1)
			pPlot:SetImprovementType(-1)
			if pPlot:GetResourceType(-1) == -1 then
				pPlot:SetResourceType(GameInfoTypes.RESOURCE_COFFEE, 1)
			end
			pPlot:SetImprovementType(GameInfo.Improvements["IMPROVEMENT_PLANTATION"].ID)
			print ("Ethiopian Coffee created!")
		elseif pPlot:GetTerrainType() == TerrainTypes.TERRAIN_PLAINS then
			pPlot:SetFeatureType(-1)
			pPlot:SetImprovementType(-1)
			if pPlot:GetResourceType(-1) == -1 then
				pPlot:SetResourceType(GameInfoTypes.RESOURCE_COCOA, 1)
			end
			pPlot:SetImprovementType(GameInfo.Improvements["IMPROVEMENT_PLANTATION"].ID)
			print ("Ethiopian Cocoa created!")
		end
		
	elseif (eImprovement == GameInfo.Improvements["IMPROVEMENT_CITADEL"].ID) or (eImprovement == GameInfo.Improvements["IMPROVEMENT_COASTAL_FORT"].ID) then		
		SetCitadelUnits(iPlayer, x, y)
		if pPlot:GetResourceType(-1) == GameInfoTypes.RESOURCE_FISH then
			pPlot:SetResourceType(-1);
			print ("Fish removed!");
		end
		print ("Citadel created!")
	elseif (eImprovement == GameInfo.Improvements["IMPROVEMENT_PONTOON_BRIDGE_MOD"].ID) then
		if pPlot:GetResourceType(-1) == GameInfoTypes.RESOURCE_FISH then
			pPlot:SetResourceType(-1);
			print ("Fish removed!");
		end
		
	elseif (eImprovement == GameInfo.Improvements["IMPROVEMENT_CREATE_FOREST_MOD"].ID) then
		pPlot:SetImprovementType(-1)
		pPlot:SetFeatureType(-1)
		pPlot:SetFeatureType(FeatureTypes.FEATURE_FOREST, -1)
		print ("Forest created!")
		
	elseif (eImprovement == GameInfo.Improvements["IMPROVEMENT_CREATE_JUNGLE_MOD"].ID) then
		pPlot:SetImprovementType(-1)
		pPlot:SetFeatureType(-1)
		pPlot:SetFeatureType(FeatureTypes.FEATURE_JUNGLE, -1)
		print ("Jungle created!")
		
	elseif (eImprovement == GameInfo.Improvements["IMPROVEMENT_TUNNEL"].ID) then
		pPlot:SetRouteType(GameInfoTypes.ROUTE_RAILROAD);
--	elseif (eImprovement == GameInfo.Improvements["IMPROVEMENT_MOUNTAIN_ROCKS"].ID) then
--		if pPlot:GetFeatureType() ~= -1 or not pPlot:IsMountain() or pPlot:GetTerrainType() == TerrainTypes.TERRAIN_SNOW then
--		    pPlot:SetImprovementType(-1)
--		    print("Natural Wonders / not Mountain / Snow Mountains can never be digged!")
--		else
--		    pPlot:SetPlotType(PlotTypes.PLOT_HILLS, false, true)
--		    if pPlot:GetResourceType(-1) == -1 then
--			pPlot:SetResourceType(GameInfoTypes.RESOURCE_STONE, 1)
--		    end
--		    if pPlot:CanHaveImprovement(GameInfo.Improvements.IMPROVEMENT_QUARRY.ID, player:GetTeam()) then
--			pPlot:SetImprovementType(GameInfo.Improvements["IMPROVEMENT_QUARRY"].ID)
--		    end
--		    print("Mountain digged!")
--		end

	elseif (eImprovement == GameInfo.Improvements["IMPROVEMENT_SHOSHONE_WILDDOME"].ID) then
		-- Shoshone Wild Domesticate
		pPlot:SetImprovementType(-1)
		--local numRandom = math.random(1, 5)
		local numRandom = Game.Rand(5, "At TerrainTransform.lua ImprovementBuilt(), choose resource for SHOSHONE WILDDOME") + 1
		local g_ResourcesWild = {GameInfoTypes.RESOURCE_TRUFFLES, GameInfoTypes.RESOURCE_FUR, GameInfoTypes.RESOURCE_BISON,
								 GameInfoTypes.RESOURCE_DEER, GameInfoTypes.RESOURCE_IVORY}
		pPlot:SetResourceType(g_ResourcesWild[numRandom], 1)
		print ("Shoshone Wild Domesticate!")
	end

end
GameEvents.BuildFinished.Add(ImprovementBuilt) 


--Fix Citadel Improvement when the unit is Created by other reasons or destroyed
--[[
function FixCitadel(playerID, unitID, iX, iY)
	if Players[playerID] == nil
	or Players[playerID]:GetUnitByID(unitID) == nil
	or Players[playerID]:GetUnitByID(unitID):GetBaseCombatStrength() <= 0
	or not Players[playerID]:GetUnitByID(unitID):IsImmobile()
	or Map.GetPlot(iX, iY) == nil
	then
		return
	end
	local pCitadel = Players[playerID]:GetUnitByID(unitID);
	local pCitadelPlot = Map.GetPlot(iX, iY);
	
	if    (pCitadel:IsDead() or pCitadel:IsDelayedDeath())
	and   (pCitadelPlot:GetImprovementType() == GameInfo.Improvements["IMPROVEMENT_COASTAL_FORT"].ID
	    or pCitadelPlot:GetImprovementType() == GameInfo.Improvements["IMPROVEMENT_CITADEL"].ID)
	then
		pCitadelPlot:SetImprovementType(-1);
	elseif pCitadelPlot:GetImprovementType() ~= GameInfo.Improvements["IMPROVEMENT_COASTAL_FORT"].ID
	and pCitadelPlot:GetImprovementType() ~= GameInfo.Improvements["IMPROVEMENT_CITADEL"].ID
	then
	    if pCitadelPlot:IsWater() then
		pCitadelPlot:SetImprovementType(GameInfo.Improvements["IMPROVEMENT_COASTAL_FORT"].ID);
	    else
		pCitadelPlot:SetImprovementType(GameInfo.Improvements["IMPROVEMENT_CITADEL"].ID);
	    end
	end
end
GameEvents.UnitSetXY.Add(FixCitadel)
--]]

--------------------------------------------------Utilities-------------------------------------















--------------------------Clear the naval improvement resource after being destroyed--------------------------

--function ImprovementDestroyed(iHexX, iHexY, iContinent1, iContinent2)
--	print ("Improvement Destroyed!")
--
--	local pPlot = Map.GetPlot(ToGridFromHex(iHexX, iHexY))
--	
--	if pPlot == nil then
--		return
--	end
--
--
--	---------------Remove Man-made Naval Resources
--	
-- 	if pPlot:GetResourceType() == GameInfoTypes.RESOURCE_OIL and pPlot:GetNumResource()== 1 then
-- 	   print ("find naval resource leftover: natrual gas!")	
--	   pPlot:SetResourceType(-1)   
--	   LuaEvents.SerialEventRawResourceIconDestroyed(iHexX, iHexY)
-- 	end
--
--	if pPlot:GetResourceType() == GameInfoTypes.RESOURCE_FISHFARM or pPlot:GetResourceType() == GameInfoTypes.RESOURCE_SAND_DREDGE then
--	   print ("find naval resource leftover: fish or sand!")	
--	   pPlot:SetResourceType(-1)
--	   LuaEvents.SerialEventRawResourceIconDestroyed(iHexX, iHexY)
--	end


-------------------------------------------------------------------------------------
-- Fix Error Forest Planting & Citadel Removing & Forbid Build Tunnel on special Plot
-------------------------------------------------------------------------------------

-- Available
function ImprovementAvailableSP(iX, iY, iImprovement)
	if Map.GetPlot(iX, iY) == nil then
		return;
	end
	local pPlot = Map.GetPlot(iX, iY);
	
	if ((iImprovement == GameInfo.Improvements["IMPROVEMENT_CREATE_FOREST_MOD"].ID
	or   iImprovement == GameInfo.Improvements["IMPROVEMENT_CREATE_JUNGLE_MOD"].ID)
	and pPlot:GetFeatureType() ~= FeatureTypes.NO_FEATURE)
	
	or ((iImprovement == GameInfo.Improvements["IMPROVEMENT_FARM"].ID
	or   iImprovement == GameInfo.Improvements["IMPROVEMENT_MINE"].ID
	or   iImprovement == GameInfo.Improvements["IMPROVEMENT_TRADING_POST"].ID
	or   iImprovement == GameInfo.Improvements["IMPROVEMENT_FISHERY_MOD"].ID)
	and (pPlot:GetImprovementType() == GameInfo.Improvements["IMPROVEMENT_CITADEL"].ID
	or   pPlot:GetImprovementType() == GameInfo.Improvements["IMPROVEMENT_COASTAL_FORT"].ID))
	then
		return false;
	else
		return true;
	end
end
GameEvents.PlotCanImprove.Add(ImprovementAvailableSP)
function BuildAvailableSP(iPlayer, iUnit, iX, iY, iBuild)
	if Map.GetPlot(iX, iY) == nil then
		return;
	end
	local pPlot = Map.GetPlot(iX, iY);
	
	if iBuild == GameInfo.Builds["BUILD_TUNNEL"].ID and (not pPlot:IsMountain()
	or pPlot:GetFeatureType() ~= FeatureTypes.NO_FEATURE
	or pPlot:GetTerrainType() == TerrainTypes.TERRAIN_SNOW)
	then
		return false;
	else
		return true;
	end
end
GameEvents.PlayerCanBuild.Add(BuildAvailableSP)

print("TerrainTransform Check Pass!")