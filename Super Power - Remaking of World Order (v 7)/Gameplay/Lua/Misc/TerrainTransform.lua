--Build Improvements Effects
local iCitadelPromotion = GameInfo.UnitPromotions["PROMOTION_CITADEL_DEFENSE"].ID
function ImprovementBuilt(iPlayer, x, y, eImprovement)
	local player = Players[iPlayer]
	if player == nil then return end

	local pPlot = Map.GetPlot(x, y)
	if pPlot == nil then return end

	if not player:IsHuman() then
		--AI build Citadels
		if eImprovement == GameInfo.Improvements["IMPROVEMENT_FARM"].ID 
		or eImprovement == GameInfo.Improvements["IMPROVEMENT_TRADING_POST"].ID 
		or eImprovement == GameInfo.Improvements["IMPROVEMENT_LUMBERMILL"].ID 
		then
			if (pPlot:IsRoute() or pPlot:IsFreshWater())
			and player:CanBuild(pPlot, GameInfo.Builds.BUILD_CITADEL.ID) 
			and not PlotIsVisibleToHuman(pPlot)
			and player:GetUnitCountFromHasPromotion(iCitadelPromotion) < (player:GetNumCities() * 2 + player:GetTotalPopulation() / 20)
			then
				if pPlot:IsBuildRemovesFeature(GameInfo.Builds.BUILD_CITADEL.ID) then
					pPlot:SetFeatureType(-1)
				end
				SetCitadelUnits(iPlayer, x, y)
				print ("This is a good location for building a Citadel! AI built a Citadel!")
			end
		--AI build Coastal Fort
		elseif eImprovement  == GameInfo.Improvements["IMPROVEMENT_FISHFARM_MOD"].ID then
			if pPlot:IsAdjacentToLand()
			and player:CanBuild(pPlot, GameInfo.Builds.BUILD_COASTAL_FORT.ID)
			and not PlotIsVisibleToHuman(pPlot) 
			and player:GetUnitCountFromHasPromotion(iCitadelPromotion) < (player:GetNumCities() * 2 + player:GetTotalPopulation() / 20)
			then
				SetCitadelUnits(iPlayer, x, y)
				print ("This is a good location for building a Coastal Fort! AI built a Coastal Fort!")
			end
		end
	end
	
	
	if eImprovement == GameInfo.Improvements["IMPROVEMENT_CITADEL"].ID
	or eImprovement == GameInfo.Improvements["IMPROVEMENT_COASTAL_FORT"].ID
	then		
		SetCitadelUnits(iPlayer, x, y)
	elseif eImprovement == GameInfo.Improvements["IMPROVEMENT_TUNNEL"].ID then
		pPlot:SetRouteType(GameInfoTypes.ROUTE_RAILROAD);
	end

end
GameEvents.BuildFinished.Add(ImprovementBuilt) 

-------------------------------------------------------------------------------------
-- Fix Error Forest Planting & Citadel Removing & Forbid Build Tunnel on special Plot
-------------------------------------------------------------------------------------
function ImprovementAvailableSP(iX, iY, iImprovement)
	if Map.GetPlot(iX, iY) == nil then
		return;
	end
	local pPlot = Map.GetPlot(iX, iY);
	
	if ((iImprovement == GameInfo.Improvements["IMPROVEMENT_CREATE_FOREST_MOD"].ID
	or   iImprovement == GameInfo.Improvements["IMPROVEMENT_CREATE_JUNGLE_MOD"].ID)
	and pPlot:GetFeatureType() ~= FeatureTypes.NO_FEATURE)
	
	or (pPlot:GetImprovementType() == GameInfo.Improvements["IMPROVEMENT_CITADEL"].ID
	or pPlot:GetImprovementType() == GameInfo.Improvements["IMPROVEMENT_COASTAL_FORT"].ID)
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