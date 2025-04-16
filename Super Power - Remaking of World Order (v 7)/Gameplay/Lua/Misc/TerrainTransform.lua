--Build Improvements Effects
local iCitadelPromotion = GameInfoTypes["PROMOTION_CITADEL_DEFENSE"]
local iImprovementFarm = GameInfoTypes["IMPROVEMENT_FARM"]
local iImprovementTradingPost = GameInfoTypes["IMPROVEMENT_TRADING_POST"]
local iImprovementLumberMill = GameInfoTypes["IMPROVEMENT_LUMBERMILL"]
local iImprovementFishFarm = GameInfoTypes["IMPROVEMENT_FISHFARM_MOD"]
local iImprovementCitadel = GameInfoTypes["IMPROVEMENT_CITADEL"]
local iImprovementCoastalCitadel = GameInfoTypes["IMPROVEMENT_COASTAL_FORT"]
local iImprovementTunnel = GameInfoTypes["IMPROVEMENT_TUNNEL"]
local iImprovementRail = GameInfoTypes["ROUTE_RAILROAD"]
local iBuiltCitadel = GameInfoTypes["BUILD_CITADEL"]
local iBuiltCoastalCitadel = GameInfoTypes["BUILD_COASTAL_FORT"]


function ImprovementBuilt(iPlayer, x, y, eImprovement)
	local player = Players[iPlayer]
	if player == nil then return end

	local pPlot = Map.GetPlot(x, y)
	if pPlot == nil then return end

	if not player:IsHuman() then
		--AI build Citadels
		if eImprovement == iImprovementFarm
		or eImprovement == iImprovementTradingPost
		or eImprovement == iImprovementLumberMill
		then
			if (pPlot:IsRoute() or pPlot:IsFreshWater())
			and player:CanBuild(pPlot, iBuiltCitadel) 
			and not PlotIsVisibleToHuman(pPlot)
			and player:GetUnitCountFromHasPromotion(iCitadelPromotion) < (player:GetNumCities() * 2 + player:GetTotalPopulation() / 20)
			then
				if pPlot:IsBuildRemovesFeature(iBuiltCitadel) then
					pPlot:SetFeatureType(-1)
				end
				SetCitadelUnits(iPlayer, x, y)
				print ("This is a good location for building a Citadel! AI built a Citadel!")
			end
		--AI build Coastal Fort
		elseif eImprovement == iImprovementFishFarm then
			if pPlot:IsAdjacentToLand()
			and player:CanBuild(pPlot, iBuiltCoastalCitadel)
			and not PlotIsVisibleToHuman(pPlot) 
			and player:GetUnitCountFromHasPromotion(iCitadelPromotion) < (player:GetNumCities() * 2 + player:GetTotalPopulation() / 20)
			then
				SetCitadelUnits(iPlayer, x, y)
				print ("This is a good location for building a Coastal Fort! AI built a Coastal Fort!")
			end
		end
	end
	
	
	if eImprovement == iImprovementCitadel
	or eImprovement == iImprovementCoastalCitadel
	then		
		SetCitadelUnits(iPlayer, x, y)
	elseif eImprovement == iImprovementTunnel then
		pPlot:SetRouteType(iImprovementRail)
	end

end
GameEvents.BuildFinished.Add(ImprovementBuilt) 

print("TerrainTransform Check Pass!")