-- New Population Rule

--------------------------------------------------------------

--------------------------------------------------------------Still WIP! Some functions are still stupid and cumbersome! Sorry but I'm a newbee for programming!!!----------------------------------

--include( "UtilityFunctions.lua" )



-----------------------------------------------------------------------Settlers & Population---------------------------------------
function SettlerTrainedCity(iPlayer, iCity, iUnit, bGold, bFaith)
	local pPlayer = Players[iPlayer]
	local pUnit = pPlayer:GetUnitByID(iUnit)
	local pCity = pPlayer:GetCityByID(iCity)
	local CityPop = pCity:GetPopulation()   
	local NewCityPop = CityPop
	
	if pPlayer:IsHuman() and pUnit and pUnit:IsFound() then
--		pUnit:JumpToNearestValidPlot() ----Move Settler out of the city to avoid settler become population after built BUG
		if 	pPlayer:HasPolicy(GameInfo.Policies["POLICY_RESETTLEMENT"].ID) and CityPop >= 4 then
			NewCityPop = CityPop - 3
			pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_SETTLER_POP_3"].ID, true)
		else	
			NewCityPop = CityPop - 1
		end
		
		pCity:SetPopulation(NewCityPop, true)----Set Real Population
		---- Notifications
		local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_SETTLER_TRAINED_CITY", pUnit:GetName(), pCity:GetName())
		local heading = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_SETTLER_TRAINED_CITY_SHORT", pUnit:GetName(), pCity:GetName())
		pPlayer:AddNotification(NotificationTypes.NOTIFICATION_STARVING, text, heading, pUnit:GetX(), pUnit:GetY())
	end
end
GameEvents.CityTrained.Add(SettlerTrainedCity)
------------------------------------------------------------------Misc Functions-------------------------------------------------------------------------
print("New Population Rule Pass!")