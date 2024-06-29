-------------------------------------------------
-- Economic
-------------------------------------------------
include( "IconSupport" );
include( "InstanceManager" );
include( "CorruptionUIUtils" )

local reOpenEOfromCV = false;
local defaultErrorTextureSheet = "CityBannerProductionImage.dds";
local nullOffset = Vector2( 0, 0 );
local g_iPortraitSize = 45;

local m_SortTable;
local ePopulation     = 0;
local eName   = 1;
local eStrength = 2;
local eProduction = 3;
local eFood = 5;
local eResearch = 6;
local eGold = 7;
local eCulture = 8;
local eFaith = 9;
local eCityScale = 10;
local eCityLevel = 11;

local m_SortMode = ePopulation;
local m_bSortReverse = false;
local m_bdoSort = false;

local m_bHidden = false;

local pediaSearchStrings = {};


-------------------------------------------------
-------------------------------------------------
function OnProdClick( cityID, prodName )
	local pPCity = Players[Game.GetActivePlayer()]:GetCityByID(cityID);
	if not pPCity then return end
	UI.LookAt(pPCity:Plot(), 0);
end
-------------------------------------------------
-------------------------------------------------
function OnProdRClick( cityID, void2, button )
	local searchString = pediaSearchStrings[tostring(button)];
	Events.SearchForPediaEntry( searchString );		
end
-------------------------------------------------
-------------------------------------------------
function OnCityClick( cityID )
	local pCCity = Players[Game.GetActivePlayer()]:GetCityByID(cityID);
	if (pCCity ~= nil) then
		reOpenEOfromCV = true;
		Events.SerialEventGameMessagePopup( { Type = ButtonPopupTypes.BUTTONPOPUP_ECONOMIC_OVERVIEW, Data1 = 1 } );
		UI.DoSelectCityAtPlot( pCCity:Plot() );
	end
end
function ReOpenEOfromCityScreen()
	if reOpenEOfromCV then
		Events.SerialEventGameMessagePopup( { Type = ButtonPopupTypes.BUTTONPOPUP_ECONOMIC_OVERVIEW } );
		reOpenEOfromCV = false;
	end
end
Events.SerialEventExitCityScreen.Add(ReOpenEOfromCityScreen)
-------------------------------------------------
-------------------------------------------------
function OnCityRename( cityID )
	if (cityID ~= -1) then
		local popupInfo = {
				Type = ButtonPopupTypes.BUTTONPOPUP_RENAME_CITY,
				Data1 = cityID,
				Data2 = true,
				Priority = PopupPriority.Current
			}
		Events.SerialEventGameMessagePopup(popupInfo);
	end
end
-------------------------------------------------
-------------------------------------------------
function OnCityFocusChanged( cityID, focus )
	if Players[Game.GetActivePlayer()] == nil or not Players[Game.GetActivePlayer()]:IsTurnActive() then
		return;
	end
	local pCCity = Players[Game.GetActivePlayer()]:GetCityByID(cityID);
	if (pCCity and not pCCity:IsPuppet()) then
		if pCCity:GetFocusType() == focus then
			focus = CityAIFocusTypes.NO_CITY_AI_FOCUS_TYPE;
		end
		Network.SendSetCityAIFocus( cityID, focus );
	end
end
-------------------------------------------------
-------------------------------------------------
function OnAllCityFocusChanged( cityID, focus )
	if Players[Game.GetActivePlayer()] == nil or not Players[Game.GetActivePlayer()]:IsTurnActive() then
		return;
	end
	local pCCity = Players[Game.GetActivePlayer()]:GetCityByID(cityID);
	if (pCCity and not pCCity:IsPuppet()) then
		if pCCity:GetFocusType() ~= focus then
			focus = CityAIFocusTypes.NO_CITY_AI_FOCUS_TYPE;
		end
		for pCity in Players[Game.GetActivePlayer()]:Cities() do
			if (pCity and not pCity:IsPuppet()) then
				Network.SendSetCityAIFocus( pCity:GetID(), focus );
			end
		end
	end
end
-------------------------------------------------
-------------------------------------------------
function OnCityAvoidGrowth( cityID )
	if Players[Game.GetActivePlayer()] and Players[Game.GetActivePlayer()]:IsTurnActive() then
		local bIsForcedAvoidGrowth = Players[Game.GetActivePlayer()]:GetCityByID(cityID):IsForcedAvoidGrowth();
		Network.SendSetCityAvoidGrowth( cityID, not bIsForcedAvoidGrowth );
	end
end
-------------------------------------------------
-------------------------------------------------
function OnAllCityAvoidGrowth( cityID )
	if Players[Game.GetActivePlayer()] and Players[Game.GetActivePlayer()]:IsTurnActive() then
		local bIsForcedAvoidGrowth = Players[Game.GetActivePlayer()]:GetCityByID(cityID):IsForcedAvoidGrowth();
		for pCity in Players[Game.GetActivePlayer()]:Cities() do
			if (pCity and not pCity:IsPuppet()) then
				Network.SendSetCityAvoidGrowth( pCity:GetID(), bIsForcedAvoidGrowth );
			end
		end
	end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function OnFlashEG()
	if not m_bHidden then
		UpdateDisplay()
	end
end
Events.SerialEventCityInfoDirty.Add( OnFlashEG );
	
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function UpdateDisplay()
    UpdateGPT();
    
    local pPlayer = Players[ Game.GetActivePlayer() ];
    if( pPlayer == nil ) then
        print( "Could not get player... huh?" );
        return;
    end
    
    m_SortTable = {};
	pediaSearchStrings = {};

    Controls.MainStack:DestroyAllChildren();
      
    for pCity in pPlayer:Cities() do
		local instance = {};
        ContextPtr:BuildInstanceForControl( "CityInstance", instance, Controls.MainStack );
        
        local sortEntry = {};
		m_SortTable[ tostring( instance.Root ) ] = sortEntry;
					
		sortEntry.Strength = math.floor( pCity:GetStrengthValue() / 100 );
        instance.Defense:SetText( sortEntry.Strength );
        
        sortEntry.Production = pCity:GetProductionNameKey();
        ProductionDetails( pCity, instance );

		sortEntry.CityName = pCity:GetName();
        instance.CityName:SetText( sortEntry.CityName );
        
        if(pCity:IsCapital())then
			instance.IconCapital:SetText("[ICON_CAPITAL]");
	        instance.IconCapital:SetHide( false );  
		elseif(pCity:IsSecondCapital())then
			instance.IconCapital:SetText("[ICON_FLOWER]");
			instance.IconCapital:SetHide( false );  
		elseif(pCity:IsPuppet()) then
			instance.IconCapital:SetText("[ICON_PUPPET]");
			instance.IconCapital:SetHide(false);
		elseif(pCity:IsOccupied() and not pCity:IsNoOccupiedUnhappiness()) then
			instance.IconCapital:SetText("[ICON_OCCUPIED]");
			instance.IconCapital:SetHide(false);
		else
			instance.IconCapital:SetHide(true);
		end
		
        -- MOD Start - by CaptainCWB
        -- hookup city popup to cityname button
        instance.CityButton:RegisterCallback( Mouse.eLClick, OnCityClick);
        instance.CityButton:RegisterCallback( Mouse.eRClick, OnCityRename);
		instance.CityButton:SetVoid1( pCity:GetID() );
		-- MOD End
        
    	local pct = 1 - (pCity:GetDamage() / pCity:GetMaxHitPoints());
    	if( pct ~= 1 ) then
    	
            if pct > 0.66 then
                instance.HealthBar:SetFGColor( { x = 0, y = 1, z = 0, w = 1 } );
            elseif pct > 0.33 then
                instance.HealthBar:SetFGColor( { x = 1, y = 1, z = 0, w = 1 } );
            else
                instance.HealthBar:SetFGColor( { x = 1, y = 0, z = 0, w = 1 } );
            end
            
        	instance.HealthBar:SetPercent( pct );
        	instance.HealthBarBox:SetHide( false );
    	else
        	instance.HealthBarBox:SetHide( true );
    	end
        
        sortEntry.Population = pCity:GetPopulation();
        instance.Population:SetText( sortEntry.Population );
        
	    -- Update Growth Meter
		if (instance.GrowthBar) then
			
			local iCurrentFood = pCity:GetFood();
			local iFoodNeeded = pCity:GrowthThreshold();
			local iFoodPerTurn = pCity:FoodDifference();
			local iCurrentFoodPlusThisTurn = iCurrentFood + iFoodPerTurn;
			
			local fGrowthProgressPercent = iCurrentFood / iFoodNeeded;
			local fGrowthProgressPlusThisTurnPercent = iCurrentFoodPlusThisTurn / iFoodNeeded;
			if (fGrowthProgressPlusThisTurnPercent > 1) then
				fGrowthProgressPlusThisTurnPercent = 1
			end
			
			instance.GrowthBar:SetPercent( fGrowthProgressPercent );
			instance.GrowthBarShadow:SetPercent( fGrowthProgressPlusThisTurnPercent );
		end
		
		-- Update Growth Time
		if(instance.CityGrowth) then
			local cityGrowth = pCity:GetFoodTurnsLeft();
			
			if (pCity:IsFoodProduction() or pCity:FoodDifferenceTimes100() == 0) then
				cityGrowth = "-";
				--instance.CityBannerRightBackground:SetToolTipString(Locale.ConvertTextKey("TXT_KEY_CITY_STOPPED_GROWING_TT", localizedCityName, cityPopulation));
			elseif pCity:FoodDifferenceTimes100() < 0 then
				cityGrowth = "[COLOR_WARNING_TEXT]-[ENDCOLOR]";
				--instance.CityBannerRightBackground:SetToolTipString(Locale.ConvertTextKey("TXT_KEY_CITY_STARVING_TT",localizedCityName ));
			else
				--instance.CityBannerRightBackground:SetToolTipString(Locale.ConvertTextKey("TXT_KEY_CITY_WILL_GROW_TT", localizedCityName, cityPopulation, cityPopulation+1, cityGrowth));
			end
			
			instance.CityGrowth:SetText(cityGrowth);
		end
		
		sortEntry.Food = pCity:FoodDifference();
        instance.Food:SetText( sortEntry.Food );
       
		local productionYield = pCity:GetYieldRate( YieldTypes.YIELD_PRODUCTION );
		local totalProductionPerTurn = math.floor(productionYield + (productionYield * (pCity:GetProductionModifier() / 100)));
       
		sortEntry.Production = totalProductionPerTurn;
        instance.Production:SetText( sortEntry.Production );
        
        
        if(Game.IsOption(GameOptionTypes.GAMEOPTION_NO_SCIENCE)) then
			instance.ScienceFocusButton:SetHide(true);
        else
			sortEntry.Science = pCity:GetYieldRate( YieldTypes.YIELD_SCIENCE );
			instance.Science:SetText( sortEntry.Science );
			instance.ScienceFocusButton:SetHide(false);
        end
        
        sortEntry.Gold = pCity:GetYieldRate( YieldTypes.YIELD_GOLD );
        instance.Gold:SetText( sortEntry.Gold );
        
        sortEntry.Culture = pCity:GetJONSCulturePerTurn();
        instance.Culture:SetText( sortEntry.Culture );
        
        if(Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION)) then
			instance.FaithFocusButton:SetHide(true);
        else
			sortEntry.Faith = pCity:GetFaithPerTurn();
			instance.Faith:SetText(sortEntry.Faith);
			instance.FaithFocusButton:SetHide(false);   
        end
        -- MOD Start - by CaptainCWB
        -- Set & Diskplay City AvoidGrowth & Focus
        local focusType = pCity:GetFocusType();
        instance.GPFocusMarked:SetHide(true);
        instance.FoodFocusMarked:SetHide(true);
        instance.ScienceFocusMarked:SetHide(true);
        instance.GoldFocusMarked:SetHide(true);
        instance.CultureFocusMarked:SetHide(true);
        instance.FaithFocusMarked:SetHide(true);
        instance.ProductionFocusMarked:SetHide(true);
	
	instance.CityAvoidGrowthLabel:SetHide(true);
	
	-- Not for Puppet Cities
	instance.GPFocusButton:SetDisabled(pCity:IsPuppet());
	instance.FoodFocusButton:SetDisabled(pCity:IsPuppet());
	instance.ScienceFocusButton:SetDisabled(pCity:IsPuppet());
	instance.GoldFocusButton:SetDisabled(pCity:IsPuppet());
	instance.CultureFocusButton:SetDisabled(pCity:IsPuppet());
	instance.FaithFocusButton:SetDisabled(pCity:IsPuppet());
	instance.ProductionFocusButton:SetDisabled(pCity:IsPuppet());
	
	instance.CityAvoidGrowthButton:SetDisabled(pCity:IsPuppet());
	
	if not pCity:IsPuppet() then
		if     focusType == CityAIFocusTypes.CITY_AI_FOCUS_TYPE_GREAT_PEOPLE then
			instance.GPFocusMarked:SetHide(false);
		elseif focusType == CityAIFocusTypes.CITY_AI_FOCUS_TYPE_FOOD then
			instance.FoodFocusMarked:SetHide(false);
		elseif focusType == CityAIFocusTypes.CITY_AI_FOCUS_TYPE_SCIENCE then
			instance.ScienceFocusMarked:SetHide(false);
		elseif focusType == CityAIFocusTypes.CITY_AI_FOCUS_TYPE_GOLD then
			instance.GoldFocusMarked:SetHide(false);
		elseif focusType == CityAIFocusTypes.CITY_AI_FOCUS_TYPE_CULTURE then
			instance.CultureFocusMarked:SetHide(false);
		elseif focusType == CityAIFocusTypes.CITY_AI_FOCUS_TYPE_FAITH then
			instance.FaithFocusMarked:SetHide(false);
		elseif focusType == CityAIFocusTypes.CITY_AI_FOCUS_TYPE_PRODUCTION then
			instance.ProductionFocusMarked:SetHide(false);
		end
		instance.CityAvoidGrowthLabel:SetHide( not pCity:IsForcedAvoidGrowth() );
		
		instance.GPFocusButton:RegisterCallback( Mouse.eLClick, OnCityFocusChanged);
		instance.GPFocusButton:RegisterCallback( Mouse.eRClick, OnAllCityFocusChanged);
		instance.GPFocusButton:SetVoid1( pCity:GetID() );
		instance.GPFocusButton:SetVoid2( CityAIFocusTypes.CITY_AI_FOCUS_TYPE_GREAT_PEOPLE );
		instance.GPFocusButton:SetToolTipString( Locale.ConvertTextKey("TXT_KEY_EO_FOCUS_TT", "[ICON_GREAT_PEOPLE]") );
		instance.FoodFocusButton:RegisterCallback( Mouse.eLClick, OnCityFocusChanged);
		instance.FoodFocusButton:RegisterCallback( Mouse.eRClick, OnAllCityFocusChanged);
		instance.FoodFocusButton:SetVoid1( pCity:GetID() );
		instance.FoodFocusButton:SetVoid2( CityAIFocusTypes.CITY_AI_FOCUS_TYPE_FOOD );
		instance.FoodFocusButton:SetToolTipString( Locale.ConvertTextKey("TXT_KEY_EO_FOCUS_TT", "[ICON_FOOD]") );
		instance.ScienceFocusButton:RegisterCallback( Mouse.eLClick, OnCityFocusChanged);
		instance.ScienceFocusButton:RegisterCallback( Mouse.eRClick, OnAllCityFocusChanged);
		instance.ScienceFocusButton:SetVoid1( pCity:GetID() );
		instance.ScienceFocusButton:SetVoid2( CityAIFocusTypes.CITY_AI_FOCUS_TYPE_SCIENCE );
		instance.ScienceFocusButton:SetToolTipString( Locale.ConvertTextKey("TXT_KEY_EO_FOCUS_TT", "[ICON_RESEARCH]") );
		instance.GoldFocusButton:RegisterCallback( Mouse.eLClick, OnCityFocusChanged);
		instance.GoldFocusButton:RegisterCallback( Mouse.eRClick, OnAllCityFocusChanged);
		instance.GoldFocusButton:SetVoid1( pCity:GetID() );
		instance.GoldFocusButton:SetVoid2( CityAIFocusTypes.CITY_AI_FOCUS_TYPE_GOLD );
		instance.GoldFocusButton:SetToolTipString( Locale.ConvertTextKey("TXT_KEY_EO_FOCUS_TT", "[ICON_GOLD]") );
		instance.CultureFocusButton:RegisterCallback( Mouse.eLClick, OnCityFocusChanged);
		instance.CultureFocusButton:RegisterCallback( Mouse.eRClick, OnAllCityFocusChanged);
		instance.CultureFocusButton:SetVoid1( pCity:GetID() );
		instance.CultureFocusButton:SetVoid2( CityAIFocusTypes.CITY_AI_FOCUS_TYPE_CULTURE );
		instance.CultureFocusButton:SetToolTipString( Locale.ConvertTextKey("TXT_KEY_EO_FOCUS_TT", "[ICON_CULTURE]") );
		instance.FaithFocusButton:RegisterCallback( Mouse.eLClick, OnCityFocusChanged);
		instance.FaithFocusButton:RegisterCallback( Mouse.eRClick, OnAllCityFocusChanged);
		instance.FaithFocusButton:SetVoid1( pCity:GetID() );
		instance.FaithFocusButton:SetVoid2( CityAIFocusTypes.CITY_AI_FOCUS_TYPE_FAITH );
		instance.FaithFocusButton:SetToolTipString( Locale.ConvertTextKey("TXT_KEY_EO_FOCUS_TT", "[ICON_PEACE]") );
		instance.ProductionFocusButton:RegisterCallback( Mouse.eLClick, OnCityFocusChanged);
		instance.ProductionFocusButton:RegisterCallback( Mouse.eRClick, OnAllCityFocusChanged);
		instance.ProductionFocusButton:SetVoid1( pCity:GetID() );
		instance.ProductionFocusButton:SetVoid2( CityAIFocusTypes.CITY_AI_FOCUS_TYPE_PRODUCTION );
		instance.ProductionFocusButton:SetToolTipString( Locale.ConvertTextKey("TXT_KEY_EO_FOCUS_TT", "[ICON_PRODUCTION]") );
		
		instance.CityAvoidGrowthButton:RegisterCallback( Mouse.eLClick, OnCityAvoidGrowth);
		instance.CityAvoidGrowthButton:RegisterCallback( Mouse.eRClick, OnAllCityAvoidGrowth);
		instance.CityAvoidGrowthButton:SetVoid1( pCity:GetID() );
	end
		
		-- Set City Scale & Level
		if(GameInfoTypes["BUILDING_CITY_SIZE_GLOBAL"] == nil) then
			instance.CityScaleBox:SetHide(true);
			instance.CityButton:SetSizeX(instance.CityButton:GetSizeX() + 15);
		else
			local iCitySc1 = pPlayer:GetCivBuilding(GameInfoTypes["BUILDINGCLASS_CITY_SIZE_TOWN"])
			local iCitySc2 = pPlayer:GetCivBuilding(GameInfoTypes["BUILDINGCLASS_CITY_SIZE_SMALL"])
			local iCitySc3 = pPlayer:GetCivBuilding(GameInfoTypes["BUILDINGCLASS_CITY_SIZE_MEDIUM"])
			local iCitySc4 = pPlayer:GetCivBuilding(GameInfoTypes["BUILDINGCLASS_CITY_SIZE_LARGE"])
			local iCitySc5 = pPlayer:GetCivBuilding(GameInfoTypes["BUILDINGCLASS_CITY_SIZE_XL"])
			local iCitySc6 = pPlayer:GetCivBuilding(GameInfoTypes["BUILDINGCLASS_CITY_SIZE_XXL"])
			local iCitySc7 = pPlayer:GetCivBuilding(GameInfoTypes["BUILDINGCLASS_CITY_SIZE_GLOBAL"])
			
			if pCity:IsHasBuilding(iCitySc7)then
				sortEntry.CityScale = 7;
				sortEntry.CityScaleIcon = "[ICON_CITYBANNER_CITY_GLOBAL]";
				sortEntry.CityScaleTT = Locale.ConvertTextKey("TXT_KEY_BUILDING_CITY_SIZE_GLOBAL_HELP");
			elseif pCity:IsHasBuilding(iCitySc6)then
				sortEntry.CityScale = 6;
				sortEntry.CityScaleIcon = "[ICON_CITYBANNER_CITY_XXL]";
				sortEntry.CityScaleTT = Locale.ConvertTextKey("TXT_KEY_BUILDING_CITY_SIZE_XXL_HELP");
			elseif pCity:IsHasBuilding(iCitySc5)then
				sortEntry.CityScale = 5;
				sortEntry.CityScaleIcon = "[ICON_CITYBANNER_CITY_XL]";
				sortEntry.CityScaleTT = Locale.ConvertTextKey("TXT_KEY_BUILDING_CITY_SIZE_XL_HELP");
			elseif pCity:IsHasBuilding(iCitySc4)then
				sortEntry.CityScale = 4;
				sortEntry.CityScaleIcon = "[ICON_CITYBANNER_CITY_LARGE]";
				sortEntry.CityScaleTT = Locale.ConvertTextKey("TXT_KEY_BUILDING_CITY_SIZE_LARGE_HELP");
			elseif pCity:IsHasBuilding(iCitySc3)then
				sortEntry.CityScale = 3;
				sortEntry.CityScaleIcon = "[ICON_CITYBANNER_CITY_MEDIUM]";
				sortEntry.CityScaleTT = Locale.ConvertTextKey("TXT_KEY_BUILDING_CITY_SIZE_MEDIUM_HELP");
			elseif pCity:IsHasBuilding(iCitySc2)then
				sortEntry.CityScale = 2;
				sortEntry.CityScaleIcon = "[ICON_CITYBANNER_CITY_SMALL]";
				sortEntry.CityScaleTT = Locale.ConvertTextKey("TXT_KEY_BUILDING_CITY_SIZE_SMALL_HELP");
			elseif pCity:IsHasBuilding(iCitySc1)then
				sortEntry.CityScale = 1;
				sortEntry.CityScaleIcon = "[ICON_CITYBANNER_CITY_TOWN]";
				sortEntry.CityScaleTT = Locale.ConvertTextKey("TXT_KEY_BUILDING_CITY_SIZE_TOWN_HELP");
			else
				sortEntry.CityScale = 8;
				sortEntry.CityScaleIcon = "";
				sortEntry.CityScaleTT = "";
			end
			instance.CityScale:SetText(sortEntry.CityScaleIcon);
			instance.CityScale:SetToolTipString(sortEntry.CityScaleTT);
			instance.CityScaleBox:SetHide(false);
		end
		
		if(GameInfoTypes["BUILDING_CITY_HALL_LV5"] == nil) then
			instance.CityLevelBox:SetHide(true);
			instance.CityButton:SetSizeX(instance.CityButton:GetSizeX() + 15);
		else
			local iCityLevel = pCity:GetCorruptionLevel()
			sortEntry.CityLevel = iCityLevel - GameInfo.CorruptionLevels["CORRUPTION_LV0"].ID;
			sortEntry.CityLevelTT = "";
			if iCityLevel >= GameInfoTypes["CORRUPTION_LV1"] then
				sortEntry.CityLevelIcon = getCorruptionLevelIconString(iCityLevel);
				sortEntry.CityLevelTT = getCorruptionScoreReport(pPlayer, pCity) .. Locale.ConvertTextKey(string.format("TXT_KEY_BUILDING_CITY_HALL_LV%d_HELP", sortEntry.CityLevel));
			end

			instance.CityLevel:SetText(sortEntry.CityLevelIcon);
			instance.CityLevel:SetToolTipString(sortEntry.CityLevelTT);
			instance.CityLevelBox:SetHide(false);
		end
	-- MOD End
    end
    
    if(m_bdoSort == true) then
    	Controls.MainStack:SortChildren( SortFunction );
    end
    
    Controls.MainStack:CalculateSize();
    Controls.MainStack:ReprocessAnchoring();
    Controls.MainScroll:CalculateInternalSize();
end


-------------------------------------------------
-------------------------------------------------
function UpdateGPT()

    local pPlayer = Players[ Game.GetActivePlayer() ];
    
    local iHandicap = Players[Game.GetActivePlayer()]:GetHandicapType();

    Controls.TotalGoldValue:SetText( Locale.ToNumber( pPlayer:GetGold(), "#.##" ) );
    
    local netGPT = pPlayer:CalculateGoldRateTimes100() / 100;
    Controls.NetGoldValue:SetText( Locale.ToNumber( netGPT, "#.##" ) );
    
    if( netGPT < 0 ) then
        Controls.ScienceLost:SetHide( false );
        Controls.ScienceLostValue:SetText( Locale.ToNumber( pPlayer:GetScienceFromBudgetDeficitTimes100() / 100, "#.##" ) );
    else
        Controls.ScienceLost:SetHide( true );
    end
    
    Controls.GrossGoldValue:SetText( "[COLOR_POSITIVE_TEXT]" .. Locale.ToNumber( pPlayer:CalculateGrossGoldTimes100() / 100, "#.##" ) .. "[ENDCOLOR]" );
    
    Controls.TotalExpenseValue:SetText( "[COLOR_NEGATIVE_TEXT]" .. Locale.ToNumber( pPlayer:CalculateInflatedCosts(), "#.##" ) .. "[ENDCOLOR]" );

	-- Cities
    Controls.CityIncomeValue:SetText( Locale.ToNumber( pPlayer:GetGoldFromCitiesTimes100() / 100, "#.##" ) );
    
    local bFoundCity = false;
    Controls.CityStack:DestroyAllChildren();
    for pCity in pPlayer:Cities() do
    
        local CityIncome = pCity:GetYieldRateTimes100(YieldTypes.YIELD_GOLD) / 100;
    
        if( CityIncome > 0 ) then
            bFoundCity = true;
    		local instance = {};
            ContextPtr:BuildInstanceForControl( "TradeEntry", instance, Controls.CityStack );
            
            instance.CityName:SetText( pCity:GetName() );
            instance.TradeIncomeValue:SetText( Locale.ToNumber( CityIncome, "#.##" ) );
        end
    end
    
    if( bFoundCity ) then
        Controls.CityToggle:SetDisabled( false );
        Controls.CityToggle:SetAlpha( 1.0 );
    else
        Controls.CityToggle:SetDisabled( true );
        Controls.CityToggle:SetAlpha( 0.5 );
    end
    Controls.CityStack:CalculateSize();
    Controls.CityStack:ReprocessAnchoring();
    
    -- Diplomacy
    local diploGPT = pPlayer:GetGoldPerTurnFromDiplomacy();
    if( diploGPT > 0 ) then
        Controls.DiploIncomeValue:SetText( Locale.ToNumber( diploGPT, "#.##" ) );
    else
        Controls.DiploIncomeValue:SetText( 0 );
    end
    
    -- Religion
    local religionGPT = pPlayer:GetGoldPerTurnFromReligion();
    if( religionGPT > 0 ) then
        Controls.ReligionIncomeValue:SetText( Locale.ToNumber( religionGPT, "#.##" ) );
    else
        Controls.ReligionIncomeValue:SetText( 0 );
    end

    Controls.TradeIncomeValue:SetText( Locale.ToNumber( pPlayer:GetCityConnectionGoldTimes100() / 100, "#.##" ) );
    
    -- Trade income breakdown tooltip
    local iBaseGold = GameDefines.TRADE_ROUTE_BASE_GOLD / 100;
    local iGoldPerPop = GameDefines.TRADE_ROUTE_CITY_POP_GOLD_MULTIPLIER / 100;
    local strTooltip = Locale.ConvertTextKey("TXT_KEY_EO_INCOME_TRADE");
    strTooltip = strTooltip .. "[NEWLINE][NEWLINE]";
	local iTradeRouteGoldModifier = pPlayer:GetCityConnectionTradeRouteGoldModifier();
	if (iTradeRouteGoldModifier ~= 0) then
		strTooltip = strTooltip .. Locale.ConvertTextKey("TXT_KEY_EGI_TRADE_ROUTE_MOD_INFO", iTradeRouteGoldModifier);
		strTooltip = strTooltip .. "[NEWLINE]";
	end
    strTooltip = strTooltip .. Locale.ConvertTextKey("TXT_KEY_TRADE_ROUTE_INCOME_INFO", iBaseGold, iGoldPerPop);
    Controls.TradeIncomeValue:SetToolTipString( strTooltip );
    
    local bFoundTrade = false;
    Controls.TradeStack:DestroyAllChildren();
    for pCity in pPlayer:Cities() do
    
        if( pPlayer:IsCapitalConnectedToCity( pCity ) ) then
            local tradeIncome = pPlayer:GetCityConnectionRouteGoldTimes100( pCity ) / 100;
        
            if( tradeIncome > 0 ) then
                bFoundTrade = true;
        		local instance = {};
                ContextPtr:BuildInstanceForControl( "TradeEntry", instance, Controls.TradeStack );
                
                instance.CityName:SetText( pCity:GetName() );
                instance.TradeIncomeValue:SetText( Locale.ToNumber( tradeIncome, "#.##" ) );
                
                local strPopInfo = " (" .. pCity:GetPopulation() .. ")"; 
                instance.CityName:SetToolTipString( strTooltip .. strPopInfo );
                instance.TradeIncomeValue:SetToolTipString( strTooltip .. strPopInfo );
                instance.TradeIncome:SetToolTipString( strTooltip .. strPopInfo );
            end 
        end 
    end
    
    if( bFoundTrade ) then
        Controls.TradeToggle:SetDisabled( false );
        Controls.TradeToggle:SetAlpha( 1.0 );
    else
        Controls.TradeToggle:SetDisabled( true );
        Controls.TradeToggle:SetAlpha( 0.5 );
    end
    Controls.TradeStack:CalculateSize();
    Controls.TradeStack:ReprocessAnchoring();

	-- Units
	
	local iTotalUnitMaintenance = pPlayer:CalculateUnitCost();
	
    Controls.UnitExpenseValue:SetText( Locale.ToNumber( iTotalUnitMaintenance , "#.##" ) );
    
    local iTotalUnits = pPlayer:GetNumUnits();
    
	print("Total Units - " .. iTotalUnits);
    local iMaintenanceFreeUnits = pPlayer:GetNumMaintenanceFreeUnits(DomainTypes.NO_DOMAIN, false);
    
    
	print("Maint Free Units - " .. iMaintenanceFreeUnits);
    
    local iPaidUnits = iTotalUnits - iMaintenanceFreeUnits;
    
    print("Paid Units - " .. iPaidUnits);
    
    local fCostPer = Locale.ToNumber( iTotalUnitMaintenance / iPaidUnits , "#.##" );
    
    local strUnitTT = Locale.ConvertTextKey("TXT_KEY_EO_EX_UNITS", fCostPer, iPaidUnits);
    
    -- Maintenance free units
    if (iMaintenanceFreeUnits ~= 0) then
		strUnitTT = strUnitTT .. "[NEWLINE][NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_EO_EX_UNITS_NO_MAINT", iMaintenanceFreeUnits);
    end
    
    -- Maintenance mod (handicap)
    local iUnitMaintMod = GameInfo.HandicapInfos[iHandicap].UnitCostPercent;
    if (iUnitMaintMod ~= 100) then
		strUnitTT = strUnitTT .. "[NEWLINE][NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_HANDICAP_MAINTENANCE_MOD", iUnitMaintMod);
	end
    
    Controls.UnitExpense:SetToolTipString( strUnitTT );
    
    -- Buildings
    local iBuildingMaintMod = GameInfo.HandicapInfos[iHandicap].BuildingCostPercent;
    
    local strBuildingsTT = Locale.ConvertTextKey("TXT_KEY_EO_EX_BUILDINGS");
    local strBuildingsModTT = "";
    
    if (iBuildingMaintMod ~= 100) then
		strBuildingsModTT = Locale.ConvertTextKey("TXT_KEY_HANDICAP_MAINTENANCE_MOD", iBuildingMaintMod);
		strBuildingsTT = strBuildingsTT .. "[NEWLINE][NEWLINE]" .. strBuildingsModTT;
		strBuildingsModTT = Locale.ConvertTextKey("TXT_KEY_EO_EX_BASE_BUILDINGS") .. "[NEWLINE][NEWLINE]" .. strBuildingsModTT;
	end
    
    Controls.BuildingsToggle:SetToolTipString( strBuildingsTT );
    
    Controls.BuildingExpenseValue:SetText( Locale.ToNumber( pPlayer:GetBuildingGoldMaintenance(), "#.##" ) );
   
    bFoundCity = false;
    Controls.BuildingsStack:DestroyAllChildren();
    for pCity in pPlayer:Cities() do
		
        local BuildingCost = pCity:GetTotalBaseBuildingMaintenance();
		
        if( BuildingCost > 0 ) then
            bFoundCity = true;
    		local instance = {};
            ContextPtr:BuildInstanceForControl( "TradeEntry", instance, Controls.BuildingsStack );
            
            instance.CityName:SetText( pCity:GetName() );
            instance.TradeIncomeValue:SetText( Locale.ToNumber( BuildingCost, "#.##" ) );
            instance.TradeIncome:SetToolTipString( strBuildingsModTT );
        end
    end
    
    if( bFoundCity ) then
        Controls.BuildingsToggle:SetDisabled( false );
        Controls.BuildingsToggle:SetAlpha( 1.0 );
    else
        Controls.BuildingsToggle:SetDisabled( true );
        Controls.BuildingsToggle:SetAlpha( 0.5 );
    end
    Controls.BuildingsStack:CalculateSize();
    Controls.BuildingsStack:ReprocessAnchoring();
    
    -- Routes
    local strRoutesTT = Locale.ConvertTextKey("TXT_KEY_EO_EX_IMPROVEMENTS");
    
    local iRouteMaintMod = GameInfo.HandicapInfos[iHandicap].RouteCostPercent;
    local strRoutesModTT = "";
    
    if (iRouteMaintMod ~= 100) then
		strRoutesModTT = Locale.ConvertTextKey("TXT_KEY_HANDICAP_MAINTENANCE_MOD", iRouteMaintMod);
		strRoutesTT = strRoutesTT .. "[NEWLINE][NEWLINE]" .. strRoutesModTT;
	end
    
    Controls.TileExpense:SetToolTipString(strRoutesTT);
    Controls.TileExpenseValue:SetText( Locale.ToNumber( pPlayer:GetImprovementGoldMaintenance(), "#.##" ) );
    
    -- Diplo
    local diploGPT = pPlayer:GetGoldPerTurnFromDiplomacy();
    if( diploGPT < 0 ) then
        Controls.DiploExpenseValue:SetText( Locale.ToNumber( -diploGPT, "#.##" ) );
    else
        Controls.DiploExpenseValue:SetText( 0 );
    end
    
    Controls.GoldScroll:CalculateInternalSize();
end


-- Start hidden
Controls.CityStack:SetHide( true );
Controls.TradeStack:SetHide( true );
Controls.BuildingsStack:SetHide( true );

-------------------------------------------------
-------------------------------------------------
function OnCityToggle()
    local bWasHidden = Controls.CityStack:IsHidden();
    Controls.CityStack:SetHide( not bWasHidden );
    if( bWasHidden ) then
        Controls.CityToggle:LocalizeAndSetText("TXT_KEY_EO_INCOME_CITIES_COLLAPSE");
    else
        Controls.CityToggle:LocalizeAndSetText("TXT_KEY_EO_INCOME_CITIES");
    end
    Controls.GoldStack:CalculateSize();
    Controls.GoldStack:ReprocessAnchoring();
    Controls.GoldScroll:CalculateInternalSize();
end
Controls.CityToggle:RegisterCallback( Mouse.eLClick, OnCityToggle );

-------------------------------------------------
-------------------------------------------------
function OnTradeToggle()
    local bWasHidden = Controls.TradeStack:IsHidden();
    Controls.TradeStack:SetHide( not bWasHidden );
    if( bWasHidden ) then
        Controls.TradeToggle:LocalizeAndSetText("TXT_KEY_EO_INCOME_TRADE_DETAILS_COLLAPSE");
    else
        Controls.TradeToggle:LocalizeAndSetText("TXT_KEY_EO_INCOME_TRADE_DETAILS");
    end
    Controls.GoldStack:CalculateSize();
    Controls.GoldStack:ReprocessAnchoring();
    Controls.GoldScroll:CalculateInternalSize();
end
Controls.TradeToggle:RegisterCallback( Mouse.eLClick, OnTradeToggle );

-------------------------------------------------
-------------------------------------------------
function OnBuildingsToggle()
    local bWasHidden = Controls.BuildingsStack:IsHidden();
    Controls.BuildingsStack:SetHide( not bWasHidden );
    if( bWasHidden ) then
        Controls.BuildingsToggle:LocalizeAndSetText("TXT_KEY_EO_BUILDINGS_COLLAPSE");
    else
        Controls.BuildingsToggle:LocalizeAndSetText("TXT_KEY_EO_BUILDINGS");
    end
    Controls.GoldStack:CalculateSize();
    Controls.GoldStack:ReprocessAnchoring();
    Controls.GoldScroll:CalculateInternalSize();
end
Controls.BuildingsToggle:RegisterCallback( Mouse.eLClick, OnBuildingsToggle );


-------------------------------------------------
-------------------------------------------------
function SortFunction( a, b )
    local valueA, valueB;

    local entryA = m_SortTable[ tostring( a ) ];
    local entryB = m_SortTable[ tostring( b ) ];
    
    if (entryA == nil) or (entryB == nil) then 
		if entryA and (entryB == nil) then
			return false;
		elseif (entryA == nil) and entryB then
			return true;
		else
			if( m_bSortReverse ) then
				return tostring(a) > tostring(b); -- gotta do something deterministic
			else
				return tostring(a) < tostring(b); -- gotta do something deterministic
			end
        end;
    else
		if( m_SortMode == ePopulation ) then
			valueA = entryA.Population;
			valueB = entryB.Population;
		elseif( m_SortMode == eName ) then
			valueA = entryA.CityName;
			valueB = entryB.CityName;
		elseif( m_SortMode == eStrength ) then
			valueA = entryA.Strength;
			valueB = entryB.Strength;
		elseif( m_SortMode == eFood ) then
			valueA = entryA.Food;
			valueB = entryB.Food;
		elseif( m_SortMode == eResearch ) then
			valueA = entryA.Science;
			valueB = entryB.Science;
		elseif( m_SortMode == eGold ) then
			valueA = entryA.Gold;
			valueB = entryB.Gold;
		elseif( m_SortMode == eCulture ) then
			valueA = entryA.Culture;
			valueB = entryB.Culture;
		elseif( m_SortMode == eFaith ) then
			valueA = entryA.Faith;
			valueB = entryB.Faith;
		elseif( m_SortMode == eCityScale ) then
			valueA = entryA.CityScale;
			valueB = entryB.CityScale;
		elseif( m_SortMode == eCityLevel ) then
			valueA = entryA.CityLevel;
			valueB = entryB.CityLevel;
		else -- SortProduction
			valueA = entryA.Production;
			valueB = entryB.Production;
		end
	    
		if( valueA == valueB ) then
			valueA = entryA.CityName;
			valueB = entryB.CityName;
		end

		if( m_bSortReverse ) then
			return valueA > valueB;
		else
			return valueA < valueB;
		end
	end
end


-------------------------------------------------
-------------------------------------------------
function OnSort( type )
    if( m_SortMode == type ) then
        m_bSortReverse = not m_bSortReverse;
    else
        m_bSortReverse = true;
    end
    
    if( m_bSortReverse ~= m_bdoSort ) then
    	m_bdoSort = true;
    else
    	m_bSortReverse = false;
    	m_bdoSort = false;
    end

    if( m_bdoSort == true ) then
    	m_SortMode = type;
    	Controls.MainStack:SortChildren( SortFunction );
    else
	UpdateDisplay();
    end
end
Controls.SortPopulation:RegisterCallback( Mouse.eLClick, OnSort );
Controls.SortCityName:RegisterCallback( Mouse.eLClick, OnSort );
Controls.SortStrength:RegisterCallback( Mouse.eLClick, OnSort );
Controls.SortProduction:RegisterCallback( Mouse.eLClick, OnSort );
Controls.SortFood:RegisterCallback( Mouse.eLClick, OnSort );
Controls.SortGold:RegisterCallback( Mouse.eLClick, OnSort );
Controls.SortCulture:RegisterCallback( Mouse.eLClick, OnSort );

Controls.SortPopulation:SetVoid1( ePopulation );
Controls.SortCityName:SetVoid1( eName );
Controls.SortStrength:SetVoid1( eStrength );
Controls.SortProduction:SetVoid1( eProduction );
Controls.SortFood:SetVoid1( eFood );
Controls.SortGold:SetVoid1( eGold );
Controls.SortCulture:SetVoid1( eCulture );

if(Game.IsOption(GameOptionTypes.GAMEOPTION_NO_SCIENCE)) then
	Controls.SortResearch:SetHide(true);
	Controls.ScienceLost:SetHide(true);
else
	Controls.SortResearch:RegisterCallback(Mouse.eLClick, OnSort);
	Controls.SortResearch:SetVoid1(eResearch);
	Controls.SortResearch:SetHide(false);
	Controls.ScienceLost:SetHide(false);
end

if(Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION)) then
	Controls.SortFaith:SetHide(true);
	Controls.ReligionIncome:SetHide(true);
else
	Controls.SortFaith:RegisterCallback(Mouse.eLClick, OnSort);
	Controls.SortFaith:SetVoid1(eFaith);
	Controls.SortFaith:SetHide(false);
	Controls.ReligionIncome:SetHide(false);
end

if(GameInfoTypes["BUILDING_CITY_SIZE_GLOBAL"] == nil) then
	Controls.SortCityScale:SetHide(true);
	Controls.SortCityName:SetSizeX( Controls.SortCityName:GetSizeX() + 15 );
else
	Controls.SortCityScale:RegisterCallback(Mouse.eLClick, OnSort);
	Controls.SortCityScale:SetVoid1(eCityScale);
	Controls.SortCityScale:SetHide(false);
end

if(GameInfoTypes["BUILDING_CITY_HALL_LV5"] == nil) then
	Controls.SortCityLevel:SetHide(true);
	Controls.SortCityName:SetSizeX( Controls.SortCityName:GetSizeX() + 15 );
else
	Controls.SortCityLevel:RegisterCallback(Mouse.eLClick, OnSort);
	Controls.SortCityLevel:SetVoid1(eCityLevel);
	Controls.SortCityLevel:SetHide(false);
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function ProductionDetails( city, instance )
	
	-- Update Production Meter
	if (instance.ProductionBar) then
		
		local iCurrentProduction = city:GetProduction();
		local iProductionNeeded = city:GetProductionNeeded();
		local iProductionPerTurn = city:GetYieldRate(YieldTypes.YIELD_PRODUCTION);
		if (city:IsFoodProduction()) then
			iProductionPerTurn = iProductionPerTurn + city:GetYieldRate(YieldTypes.YIELD_FOOD) - city:FoodConsumption(true);
		end
		local iCurrentProductionPlusThisTurn = iCurrentProduction + iProductionPerTurn;
		
		local fProductionProgressPercent = iCurrentProduction / iProductionNeeded;
		local fProductionProgressPlusThisTurnPercent = iCurrentProductionPlusThisTurn / iProductionNeeded;
		if (fProductionProgressPlusThisTurnPercent > 1) then
			fProductionProgressPlusThisTurnPercent = 1
		end
		
		instance.ProductionBar:SetPercent( fProductionProgressPercent );
		instance.ProductionBarShadow:SetPercent( fProductionProgressPlusThisTurnPercent );	
	end	
	
	-- Update Production Time
	if(instance.BuildGrowth) then
		local buildGrowth = "-";
		
		if (city:IsProduction() and not city:IsProductionProcess()) then
			if (city:GetCurrentProductionDifferenceTimes100(false, false) > 0) then
				buildGrowth = city:GetProductionTurnsLeft();
			end
		end
		
		instance.BuildGrowth:SetText(buildGrowth);

	end
	

	-- Update Production Name
	local cityProductionName = city:GetProductionNameKey();
	if cityProductionName == nil or string.len(cityProductionName) == 0 then
		cityProductionName = "TXT_KEY_PRODUCTION_NO_PRODUCTION";
	end
	instance.ProdImage:SetToolTipString( Locale.ConvertTextKey( cityProductionName ) );


	-- Update Production icon
	if instance.ProdImage then
		local unitProduction = city:GetProductionUnit();
		local buildingProduction = city:GetProductionBuilding();
		local projectProduction = city:GetProductionProject();
		local processProduction = city:GetProductionProcess();
		local noProduction = false;

		if unitProduction ~= -1 then
			local thisUnitInfo = GameInfo.Units[unitProduction];
			local portraitOffset, portraitAtlas = UI.GetUnitPortraitIcon(unitProduction, city:GetOwner());
			if IconHookup( portraitOffset, g_iPortraitSize, portraitAtlas, instance.ProdImage ) then
				instance.ProdImage:SetHide( false );
			else
				instance.ProdImage:SetHide( true );
			end
		elseif buildingProduction ~= -1 then
			local thisBuildingInfo = GameInfo.Buildings[buildingProduction];
			if IconHookup( thisBuildingInfo.PortraitIndex, g_iPortraitSize, thisBuildingInfo.IconAtlas, instance.ProdImage ) then
				instance.ProdImage:SetHide( false );
			else
				instance.ProdImage:SetHide( true );
			end
		elseif projectProduction ~= -1 then
			local thisProjectInfo = GameInfo.Projects[projectProduction];
			if IconHookup( thisProjectInfo.PortraitIndex, g_iPortraitSize, thisProjectInfo.IconAtlas, instance.ProdImage ) then
				instance.ProdImage:SetHide( false );
			else
				instance.ProdImage:SetHide( true );
			end
		elseif processProduction ~= -1 then
			local thisProcessInfo = GameInfo.Processes[processProduction];
			if IconHookup( thisProcessInfo.PortraitIndex, g_iPortraitSize, thisProcessInfo.IconAtlas, instance.ProdImage ) then
				instance.ProdImage:SetHide( false );
			else
				instance.ProdImage:SetHide( true );
			end
		else -- really should have an error texture
			instance.ProdImage:SetHide(true);
		end
	end
	
	-- hookup pedia and production popup to production button
	instance.ProdButton:RegisterCallback( Mouse.eLClick, OnProdClick );
	pediaSearchStrings[tostring(instance.ProdButton)] = Locale.ConvertTextKey(cityProductionName);
	instance.ProdButton:RegisterCallback( Mouse.eRClick, OnProdRClick );
	instance.ProdButton:SetVoids( city:GetID(), nil );

end


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function ShowHideHandler( bIsHide, bInitState )
    if( not bIsHide ) then
    	UpdateDisplay();
	end
	m_bHidden = bIsHide;
end
ContextPtr:SetShowHideHandler( ShowHideHandler );