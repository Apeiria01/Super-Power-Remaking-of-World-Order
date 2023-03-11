function DisableSiegeWorkshopAfterDynamite(iPlayer, iCity, iBuilding)
    local pPlayer = Players[iPlayer];
    return not(GameInfoTypes["BUILDING_OTTOMAN_SIEGE_WORKSHOP"] == iBuilding and Teams[pPlayer:GetTeam()]:IsHasTech(GameInfoTypes["TECH_DYNAMITE"]));
end
GameEvents.CityCanConstruct.Add(DisableSiegeWorkshopAfterDynamite);

print("New Building Rules Check Pass!");