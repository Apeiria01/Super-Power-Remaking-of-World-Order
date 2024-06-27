include( "IconSupport" );
-------------------------------------------------
-- Diplomatic
-------------------------------------------------

local m_CurrentPanel = Controls.RelationsPanel;
local m_PopupInfo = nil;

-------------------------------------------------
-- On Popup
-------------------------------------------------
function OnPopup( popupInfo )
	if( popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_DIPLOMATIC_OVERVIEW ) then
		m_PopupInfo = popupInfo;
		if( m_PopupInfo.Data1 == 1 ) then
			if( ContextPtr:IsHidden() == false ) then
				OnClose();
			else
				UIManager:QueuePopup( ContextPtr, PopupPriority.InGameUtmost );
			end
		elseif ( m_PopupInfo.Data1 == 2 ) then
			UIManager:PushModal( ContextPtr );
		else
			UIManager:QueuePopup( ContextPtr, PopupPriority.DiploOverview );
		end
	end
end
Events.SerialEventGameMessagePopup.Add( OnPopup );


-------------------------------------------------
-- Main function to Select Panels
-------------------------------------------------
function PanelSelector(Panel)

	if (Panel == "Deals") then
		Controls.DealsSelectHighlight:SetHide(false);
		Controls.DealsPanel:SetHide(false);
		m_CurrentPanel = Controls.DealsPanel;
	else
		Controls.DealsSelectHighlight:SetHide(true);
		Controls.DealsPanel:SetHide(true);
	end;
	
	if (Panel == "Relations") then
		Controls.RelationsSelectHighlight:SetHide(false);
		Controls.RelationsPanel:SetHide(false);
		m_CurrentPanel = Controls.RelationsPanel;
	else
		Controls.RelationsSelectHighlight:SetHide(true);
		Controls.RelationsPanel:SetHide(true);
	end;

	if (Panel == "Trades") then
		Controls.TradesSelectHighlight:SetHide(false);
		Controls.TradesPanel:SetHide(false);
		m_CurrentPanel = Controls.TradesPanel;
	else
		Controls.TradesSelectHighlight:SetHide(true);
		Controls.TradesPanel:SetHide(true);
	end;

	if (Panel == "CityStates") then
		Controls.CityStatesSelectHighlight:SetHide(false);
		Controls.CityStatesPanel:SetHide(false);
		m_CurrentPanel = Controls.CityStatesPanel;
	else
		Controls.CityStatesSelectHighlight:SetHide(true);
		Controls.CityStatesPanel:SetHide(true);
	end;
	
	if (Panel == "Global") then
		Controls.GlobalSelectHighlight:SetHide(false);
		Controls.GlobalPanel:SetHide(false);
		m_CurrentPanel = Controls.GlobalPanel;
	else
		Controls.GlobalSelectHighlight:SetHide(true);
		Controls.GlobalPanel:SetHide(true);
	end;

	if (Panel == "CivRelations") then
		Controls.CivRelationsSelectHighlight:SetHide(false);
		Controls.CivRelationsPanel:SetHide(false);
		m_CurrentPanel = Controls.CivRelationsPanel;
	else
		Controls.CivRelationsSelectHighlight:SetHide(true);
		Controls.CivRelationsPanel:SetHide(true);
	end;

end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function OnDeals()
	PanelSelector("Deals");
end
Controls.DealsButton:RegisterCallback( Mouse.eLClick, OnDeals );


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function OnRelations()
	PanelSelector("Relations");
end
Controls.RelationsButton:RegisterCallback( Mouse.eLClick, OnRelations );


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function OnTrades()
	PanelSelector("Trades");
end
Controls.TradesButton:RegisterCallback( Mouse.eLClick, OnTrades );


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function OnCityStates()
	PanelSelector("CityStates");
end
Controls.CityStatesButton:RegisterCallback( Mouse.eLClick, OnCityStates );


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function OnGlobal()
	PanelSelector("Global");
end
Controls.GlobalPoliticsButton:RegisterCallback( Mouse.eLClick, OnGlobal );


-------------------------------------------------------------------------------
-- Display the Civ relations graph Panel
-------------------------------------------------------------------------------
function OnCivRelations()
	PanelSelector("CivRelations");
end
Controls.CivRelationsButton:RegisterCallback( Mouse.eLClick, OnCivRelations );

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function OnClose()
	UIManager:PopModal( ContextPtr );
	UIManager:DequeuePopup( ContextPtr );
end
Controls.CloseButton:RegisterCallback( Mouse.eLClick, OnClose);

----------------------------------------------------------------
-- 'Active' (local human) player has changed
----------------------------------------------------------------
Events.GameplaySetActivePlayer.Add(OnClose);

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function InputHandler( uiMsg, wParam, lParam )
    if uiMsg == KeyEvents.KeyDown then
        if wParam == Keys.VK_ESCAPE or wParam == Keys.VK_RETURN then
            OnClose();
            return true;
        end
    end
end
ContextPtr:SetInputHandler( InputHandler );


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function ShowHideHandler( bIsHide, bInitState )
	-- Set player icon at top of screen
	CivIconHookup( Game.GetActivePlayer(), 64, Controls.Icon, Controls.CivIconBG, Controls.CivIconShadow, false, true );

    if( not bInitState ) then
        if( not bIsHide ) then
        	UI.incTurnTimerSemaphore();
        	-- trigger the show/hide handler to update state
        	m_CurrentPanel:SetHide( false );
        	Events.SerialEventGameMessagePopupShown(m_PopupInfo);
        else
        	UI.decTurnTimerSemaphore();
        	Events.SerialEventGameMessagePopupProcessed.CallImmediate(ButtonPopupTypes.BUTTONPOPUP_DIPLOMATIC_OVERVIEW, 0);
        end
    end
end
ContextPtr:SetShowHideHandler( ShowHideHandler );

OnRelations();