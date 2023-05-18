include("FLuaVector.lua")
function NromanCampBouns(iPlayer)
    local pPlayer = Players[iPlayer]
    if not pPlayer:IsMajorCiv() then
        return
    end
    local NumOfNromanCamp = pPlayer:CountNumBuildings(GameInfoTypes.BUILDING_NORMAN_CAMP)
    if NumOfNromanCamp < 1 then
        return
    end
    local NromanCampRandom = Game.Rand(4, "Set NormanCamp Random!") --rand=0-3
    local eEra = pPlayer:GetCurrentEra()
    local iNromanCampBonus = (eEra + 1) * NumOfNromanCamp
    print("NormanCamp Random",NromanCampRandom,iNromanCampBonus)
    if pPlayer:IsHuman() then
        local hex
        for pCity in pPlayer:Cities() do
            if pCity:IsHasBuilding(GameInfoTypes.BUILDING_NORMAN_CAMP) then
                hex = ToHexFromGrid(Vector2(pCity:GetX(),pCity:GetY()))
                if NromanCampRandom < 2 then
                    pCity:SetOverflowProduction(pCity:GetOverflowProduction() + iNromanCampBonus)
                    Events.AddPopupTextEvent(HexToWorld(hex), Locale.ConvertTextKey("+{1_Num}[ICON_PRODUCTION]",iNromanCampBonus))
                else
                    pCity:ChangeFood(iNromanCampBonus)
                    Events.AddPopupTextEvent(HexToWorld(hex), Locale.ConvertTextKey("+{1_Num}[ICON_FOOD]",iNromanCampBonus))
                end
                Events.GameplayFX(hex.x, hex.y, -1)
            end
        end
    else
        for pCity in pPlayer:Cities() do
            if pCity:IsHasBuilding(GameInfoTypes.BUILDING_NORMAN_CAMP) then
                if NromanCampRandom < 2 then
                    pCity:SetOverflowProduction(pCity:GetOverflowProduction() + iNromanCampBonus)
                else
                    pCity:ChangeFood(iNromanCampBonus)
                end
            end
        end
    end
    
end

function SPNNromanCampConquestedCity(oldOwnerID, isCapital, cityX, cityY, newOwnerID, numPop, isConquest)
	if not isConquest then return end
    NromanCampBouns(newOwnerID)
end
GameEvents.CityCaptureComplete.Add(SPNNromanCampConquestedCity) 

function SPNNromanCampDestroyCity(hexPos,iPlayer,iCity)
    NromanCampBouns(iPlayer)
end
Events.SerialEventCityDestroyed.Add(SPNNromanCampDestroyCity)

print("New Building Rules Check Pass!");