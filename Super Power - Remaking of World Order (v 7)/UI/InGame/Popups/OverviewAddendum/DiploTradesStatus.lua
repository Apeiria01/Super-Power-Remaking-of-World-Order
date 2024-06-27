include("IconSupport")
include("SupportFunctions")
include("InstanceManager")
include("InfoTooltipInclude")

local gPlayerIM = InstanceManager:new("TradeStatusInstance", "TradeBox", Controls.PlayerBox)
local gAiIM = InstanceManager:new("TradeStatusInstance", "TradeBox", Controls.AiStack)
local gCsIM = InstanceManager:new("TradeStatusInstance", "TradeBox", Controls.CsStack)


function ShowHideHandler(bIsHide, bIsInit)
	if (not bIsInit and not bIsHide) then
		gPlayerIM:ResetInstances()
		gAiIM:ResetInstances()
		gCsIM:ResetInstances()
	
		local iPlayer = Game.GetActivePlayer()
		InitPlayer(iPlayer)
		InitAiList(iPlayer)
	end
end
ContextPtr:SetShowHideHandler(ShowHideHandler)


function InitPlayer(iPlayer)
	GetCivControl(gPlayerIM, iPlayer, false)
end

function InitAiList(iPlayer)
	local pPlayer = Players[iPlayer]
	local pTeam = Teams[pPlayer:GetTeam()]
	local count = 0
	
	for iPlayerLoop = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
		local pOtherPlayer = Players[iPlayerLoop]
		local iOtherTeam = pOtherPlayer:GetTeam()
		
		if (iPlayerLoop ~= iPlayer and pOtherPlayer:IsAlive()) then
			if (pTeam:IsHasMet(iOtherTeam)) then
				count = count+1
				GetCivControl(gAiIM, iPlayerLoop, true)
			end
		end
	end
	
	if (InitCsList()) then
		count = count+1
	end

	if (count == 0) then
		Controls.AiNoneMetText:SetHide(false)
		Controls.AiScrollPanel:SetHide(true)
	else
		Controls.AiNoneMetText:SetHide(true)
		Controls.AiScrollPanel:SetHide(false)

		Controls.AiStack:CalculateSize()
		Controls.AiStack:ReprocessAnchoring()
		Controls.CsStack:CalculateSize()
		Controls.CsStack:ReprocessAnchoring()
		Controls.AiScrollPanel:CalculateInternalSize()
	end
end

function InitCsList()
	local bCsMet = false

	local iActivePlayer = Game.GetActivePlayer()
	local pActivePlayer = Players[iActivePlayer]
	local pActiveTeam = Teams[pActivePlayer:GetTeam()]
	
	for iCsLoop = GameDefines.MAX_MAJOR_CIVS, GameDefines.MAX_CIV_PLAYERS-1, 1 do
		local pCs = Players[iCsLoop]
		
		if (pCs:IsAlive() and pActiveTeam:IsHasMet(pCs:GetTeam())) then
			local csControlTable = gCsIM:GetInstance();
			
			csControlTable.TradeOps:SetHide(pActiveTeam:IsAtWar(pCs:GetTeam()) == true);
			csControlTable.TradeWar:SetHide(pActiveTeam:IsAtWar(pCs:GetTeam()) == false);
			
			csControlTable.EmbassyText:SetHide(false);
			csControlTable.ResearchText:SetHide(true);
			csControlTable.BordersText:SetHide(true);
			csControlTable.GoldText:SetHide(true);
			
			csControlTable.CivButton:SetHide(true);
			csControlTable.CsButton:SetHide(false);
			csControlTable.CsButton:SetVoid1(iCsLoop);
			csControlTable.CsButton:RegisterCallback(Mouse.eLClick, OnCsSelected);
			
			local sTrait = GameInfo.MinorCivilizations[pCs:GetMinorCivType()].MinorCivTrait
			csControlTable.CsTraitIcon:SetTexture(GameInfo.MinorCivTraits[sTrait].TraitIcon)
			local primaryColor, secondaryColor = pCs:GetPlayerColors()
			csControlTable.CsTraitIcon:SetColor({x = secondaryColor.x, y = secondaryColor.y, z = secondaryColor.z, w = 1})

			local sCsAlly = "TXT_KEY_CITY_STATE_NOBODY"

			local sToolTip = Locale.ConvertTextKey(pCs:GetCivilizationShortDescriptionKey());
			local iCsAlly = pCs:GetAlly();
			if (iCsAlly ~= nil and iCsAlly ~= -1) then
				if (iCsAlly ~= iActivePlayer) then
					if (pActiveTeam:IsHasMet(Players[iCsAlly]:GetTeam())) then
						sCsAlly = Players[iCsAlly]:GetCivilizationShortDescriptionKey()
					else
						sCsAlly = "TXT_KEY_MISC_UNKNOWN"
					end
				else
					sCsAlly = "TXT_KEY_YOU"
				end
				sToolTip = Locale.ConvertTextKey(pCs:GetCivilizationShortDescriptionKey()) .. " (" .. Locale.ConvertTextKey(sCsAlly) .. ")";
			end


			local sResourceList;
			local sStrateRes;
			local sLuxuryRes;
	
			-- Strategic First
			for pResource in GameInfo.Resources() do
				local iResource = pResource.ID
				local iNumResource = 0;
				local iNumResourceUntapped = 0;
				local sResourceText;
				if (Game.GetResourceUsageType(iResource) == ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC
				and pActiveTeam:GetTeamTechs():HasTech(GameInfoTypes[pResource.TechReveal]) and pActiveTeam:GetTeamTechs():HasTech(GameInfoTypes[pResource.TechCityTrade]))
				then
					if pCs:GetNumResourceTotal(iResource, false) + pCs:GetResourceExport(iResource) > 0 then
						iNumResource = pCs:GetNumResourceTotal(iResource, false) + pCs:GetResourceExport(iResource);
					end
					iNumResourceUntapped = getNumResourceUntapped(pCs, pResource);
					if     iNumResource > 0 and iNumResourceUntapped > 0 then
						sResourceText = "[COLOR_POSITIVE_TEXT]" .. iNumResource .. "[ENDCOLOR]" .. "[COLOR_WARNING_TEXT]" .. "(" ..  iNumResourceUntapped .. ")" .. "[ENDCOLOR]" .. Locale.ConvertTextKey(pResource.IconString);
					elseif iNumResource > 0 then
						sResourceText = "[COLOR_POSITIVE_TEXT]" .. iNumResource .. "[ENDCOLOR]" .. Locale.ConvertTextKey(pResource.IconString);
					elseif iNumResourceUntapped > 0  then
						sResourceText = "[COLOR_WARNING_TEXT]" .. "(" ..  iNumResourceUntapped .. ")" .. "[ENDCOLOR]" .. Locale.ConvertTextKey(pResource.IconString);
					end
					if sResourceText ~= nil then
						if sStrateRes == nil then
							sStrateRes = sResourceText;
						else
							sStrateRes = sStrateRes .. "," .. sResourceText;
						end
					end
				end
			end
			-- Luxury Next
			for pLuxury in GameInfo.Resources() do
				local iLuxury = pLuxury.ID;
				local bIsHasLuxury = false;
				local bIsHasLuxuryUntapped = false;
				local sLuxuryText;
				if (pLuxury.Happiness > 0) then
					if pCs:GetNumResourceTotal(iLuxury, false) + pCs:GetResourceExport(iLuxury) > 0 then
						bIsHasLuxury = true;
					else
						bIsHasLuxuryUntapped = getNumResourceUntapped(pCs, pLuxury) > 0;
					end
					if     bIsHasLuxury then
						sLuxuryText = "[COLOR_YELLOW]" .. Locale.ConvertTextKey(pLuxury.IconString) .. "[ENDCOLOR]";
					elseif bIsHasLuxuryUntapped then
						sLuxuryText = "[COLOR_WARNING_TEXT]" .. "(" ..  Locale.ConvertTextKey(pLuxury.IconString) .. ")" .. "[ENDCOLOR]";
					end
					if sLuxuryText ~= nil then
						if sLuxuryRes == nil then
							sLuxuryRes = sLuxuryText;
						else
							sLuxuryRes = sLuxuryRes .. "," .. sLuxuryText;
						end
					end
				end
			end
			-- Text
			if     sStrateRes ~= nil and sLuxuryRes ~= nil then
				sResourceList = sStrateRes .. "[ICON_TURNS_REMAINING]" .. sLuxuryRes;
			elseif sStrateRes ~= nil then
				sResourceList = sStrateRes;
			elseif sLuxuryRes ~= nil then
				sResourceList = sLuxuryRes;
			end
			if sResourceList ~= nil then
				sToolTip = sToolTip .. "[NEWLINE]" .. sResourceList;
			end
			csControlTable.ResourcesList:SetText( sResourceList or "" );
			csControlTable.ResourcesList:SetToolTipString( sToolTip );
			
			local sEmbassyIcon = "";
			local sEmbassyTip  = "";
			if     pCs:IsAllies(iActivePlayer) then
				sEmbassyIcon = "[ICON_CITY_STATE]";
				sEmbassyTip  = Locale.ConvertTextKey("TXT_KEY_ALLIES_CSTATE_TT", pCs:GetCivilizationShortDescriptionKey());
			elseif pCs:IsFriends(iActivePlayer) then
				sEmbassyIcon = "[ICON_INFLUENCE]";
				sEmbassyTip  = Locale.ConvertTextKey("TXT_KEY_FRIENDS_CSTATE_TT", pCs:GetCivilizationShortDescriptionKey());
			elseif pCs:IsMinorPermanentWar(pActivePlayer:GetTeam()) then
				sEmbassyIcon = "[ICON_RAZING]";
				sEmbassyTip  = Locale.ConvertTextKey("TXT_KEY_PERMANENT_WAR_CSTATE_TT", pCs:GetCivilizationShortDescriptionKey());
			elseif pCs:IsPeaceBlocked(pActivePlayer:GetTeam()) then
				sEmbassyIcon = "[ICON_OCCUPIED]";
				sEmbassyTip  = Locale.ConvertTextKey("TXT_KEY_PEACE_BLOCKED_CSTATE_TT", pCs:GetCivilizationShortDescriptionKey());
			elseif pActiveTeam:IsAtWar(pCs:GetTeam()) then
				sEmbassyIcon = "[ICON_WAR]";
				sEmbassyTip  = Locale.ConvertTextKey("TXT_KEY_WAR_CSTATE_TT", pCs:GetCivilizationShortDescriptionKey());
			end
			if sEmbassyIcon ~= nil then
				csControlTable.EmbassyText:SetHide(false);
				csControlTable.EmbassyText:SetText(sEmbassyIcon)
				csControlTable.EmbassyText:SetToolTipString(sEmbassyTip)
			end
			csControlTable.CsButton:SetToolTipString(sToolTip);
			bCsMet = true
		end
	end

	if (not bCsMet) then
		Controls.CsTitle:SetHide(true)
	else
		Controls.CsTitle:SetHide(false)
	end

	return bCsMet
end

function GetCivControl(im, iPlayer, bCanTrade)
	local iActivePlayer = Game.GetActivePlayer()
	local pActivePlayer = Players[iActivePlayer]
	local iActiveTeam = pActivePlayer:GetTeam()
	local pActiveTeam = Teams[iActiveTeam]
	local bIsActivePlayer = (iActivePlayer == iPlayer)

	local pPlayer = Players[iPlayer]
	local iTeam = pPlayer:GetTeam()
	local pTeam = Teams[iTeam]
	local pCivInfo = GameInfo.Civilizations[pPlayer:GetCivilizationType()]
	
	local pDeal = UI.GetScratchDeal()

	local controlTable = im:GetInstance()

	controlTable.TradeOps:SetHide(pActiveTeam:IsAtWar(iTeam) == true)
	controlTable.TradeWar:SetHide(pActiveTeam:IsAtWar(iTeam) == false)

	-- controlTable.CivName:SetText(Locale.ConvertTextKey(pCivInfo.ShortDescription))
	CivIconHookup(iPlayer, 32, controlTable.CivSymbol, controlTable.CivIconBG, controlTable.CivIconShadow, false, true)
	controlTable.CivIconBG:SetHide(false)

	controlTable.CsButton:SetHide(true);
	controlTable.CivButton:SetHide(false);

	if (bCanTrade) then
		controlTable.CivButton:SetVoid1(iPlayer)
		controlTable.CivButton:RegisterCallback(Mouse.eLClick, OnCivSelected)
	else
		controlTable.CivButtonHL:SetHide(true)
	end

	local sResourceList;
	local sResourceTTList;
	local sResourceImList;
	local sResourceExList;
	local sStrateRes;
	local sStrateResImport;
	local sStrateResExport;
	local sLuxuryRes;
	local sLuxuryResImport;
	local sLuxuryResExport;
	local sLuxuryResNeeded;
	
	-- Strategic First
	for pResource in GameInfo.Resources() do
		local iResource = pResource.ID
		if (Game.GetResourceUsageType(iResource) == ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC) then
			if pPlayer:GetNumResourceAvailable(iResource, false) > 0 then
				if sStrateRes == nil then
					sStrateRes = "[COLOR_POSITIVE_TEXT]" .. pPlayer:GetNumResourceAvailable(iResource, false) .. "[ENDCOLOR]" .. Locale.ConvertTextKey(pResource.IconString);
				else
					sStrateRes = sStrateRes .. "," .. "[COLOR_POSITIVE_TEXT]" .. pPlayer:GetNumResourceAvailable(iResource, false) .. "[ENDCOLOR]" .. Locale.ConvertTextKey(pResource.IconString);
				end
			end
			if pPlayer:GetResourceImport(iResource) > 0 then
				if sStrateResImport == nil then
					sStrateResImport = "[COLOR_POSITIVE_TEXT]" .. pPlayer:GetResourceImport(iResource) .. "[ENDCOLOR]" .. Locale.ConvertTextKey(pResource.IconString);
				else
					sStrateResImport = sStrateResImport .. "," .. "[COLOR_POSITIVE_TEXT]" .. pPlayer:GetResourceImport(iResource) .. "[ENDCOLOR]" .. Locale.ConvertTextKey(pResource.IconString);
				end
			end
			if pPlayer:GetResourceExport(iResource) > 0 then
				if sStrateResExport == nil then
					sStrateResExport = "[COLOR_POSITIVE_TEXT]" .. pPlayer:GetResourceExport(iResource) .. "[ENDCOLOR]" .. Locale.ConvertTextKey(pResource.IconString);
				else
					sStrateResExport = sStrateResExport .. "," .. "[COLOR_POSITIVE_TEXT]" .. pPlayer:GetResourceExport(iResource) .. "[ENDCOLOR]" .. Locale.ConvertTextKey(pResource.IconString);
				end
			end
		end
	end
	-- Luxury Next
	for pLuxury in GameInfo.Resources() do
		local iLuxury = pLuxury.ID;
		if (pLuxury.Happiness > 0) then
			if pPlayer:GetNumResourceAvailable(iLuxury, false) > 0 and not (pPlayer ~= pActivePlayer and pActivePlayer:GetNumResourceAvailable(iLuxury, true) > 0) then
				if sLuxuryRes == nil then
					sLuxuryRes = "[COLOR_YELLOW]" .. pPlayer:GetNumResourceAvailable(iLuxury, false) .. "[ENDCOLOR]" .. Locale.ConvertTextKey(pLuxury.IconString);
				else
					sLuxuryRes = sLuxuryRes .. "," .. "[COLOR_YELLOW]" .. pPlayer:GetNumResourceAvailable(iLuxury, false) .. "[ENDCOLOR]" .. Locale.ConvertTextKey(pLuxury.IconString);
				end
			end
			if pPlayer:GetResourceImport(iLuxury) > 0 then
				if sLuxuryResImport == nil then
					sLuxuryResImport = Locale.ConvertTextKey(pLuxury.IconString);
				else
					sLuxuryResImport = sLuxuryResImport .. "," .. Locale.ConvertTextKey(pLuxury.IconString);
				end
			end
			if pPlayer:GetResourceExport(iLuxury) > 0 then
				if sLuxuryResExport == nil then
					sLuxuryResExport = "[COLOR_YELLOW]" .. pPlayer:GetResourceExport(iLuxury) .. "[ENDCOLOR]" .. Locale.ConvertTextKey(pLuxury.IconString);
				else
					sLuxuryResExport = sLuxuryResExport .. "," .. "[COLOR_YELLOW]" .. pPlayer:GetResourceExport(iLuxury) .. "[ENDCOLOR]" .. Locale.ConvertTextKey(pLuxury.IconString);
				end
			end
		end
	end
	-- Luxury Needed Last
	for pLuxury in GameInfo.Resources() do
		local iLuxury = pLuxury.ID
		if (pLuxury.Happiness > 0 and pPlayer:GetNumResourceAvailable(iLuxury, true) == 0 and pActivePlayer:GetNumResourceAvailable(iLuxury, false) > 0 )then
			if sLuxuryResNeeded == nil then
				sLuxuryResNeeded = " [ICON_INVEST][COLOR_WARNING_TEXT]-[ENDCOLOR]" .. Locale.ConvertTextKey(pLuxury.IconString);
			else
				sLuxuryResNeeded = sLuxuryResNeeded .. "," .. "[COLOR_WARNING_TEXT]-[ENDCOLOR]" .. Locale.ConvertTextKey(pLuxury.IconString);
			end
		end
	end
	-- Text
	if     sStrateRes ~= nil and sLuxuryRes ~= nil then
		sResourceList = sStrateRes .. "[ICON_TURNS_REMAINING]" .. sLuxuryRes;
	elseif sStrateRes ~= nil then
		sResourceList = sStrateRes;
	elseif sLuxuryRes ~= nil then
		sResourceList = sLuxuryRes;
	end
	if sLuxuryResNeeded ~= nil then
	    if sResourceList ~= nil then
		sResourceList = sResourceList .. sLuxuryResNeeded;
	    else
		sResourceList = sLuxuryResNeeded;
	    end
	end
	controlTable.ResourcesList:SetText( sResourceList or "" );
	-- ToolTip
	if     sStrateResImport ~= nil and sLuxuryResImport ~= nil then
		sResourceImList = "[ICON_ARROW_RIGHT]" .. sStrateResImport .. "[ICON_TURNS_REMAINING]" .. sLuxuryResImport;
	elseif sStrateResImport ~= nil then
		sResourceImList = "[ICON_ARROW_RIGHT]" .. sStrateResImport;
	elseif sLuxuryResImport ~= nil then
		sResourceImList = "[ICON_ARROW_RIGHT]" .. sLuxuryResImport;
	end
	if     sStrateResExport ~= nil and sLuxuryResExport ~= nil then
		sResourceExList = "[ICON_ARROW_LEFT]" .. sStrateResExport .. "[ICON_TURNS_REMAINING]" .. sLuxuryResExport;
	elseif sStrateResExport ~= nil then
		sResourceExList = "[ICON_ARROW_LEFT]" .. sStrateResExport;
	elseif sLuxuryResExport ~= nil then
		sResourceExList = "[ICON_ARROW_LEFT]" .. sLuxuryResExport;
	end
	if     sResourceImList ~= nil and sResourceExList ~= nil then
		sResourceTTList = sResourceImList .. "[NEWLINE]" .. sResourceExList;
	elseif sResourceImList ~= nil then
		sResourceTTList = sResourceImList;
	elseif sResourceExList ~= nil then
		sResourceTTList = sResourceExList;
	end
	if     sResourceList ~= nil and sResourceTTList ~= nil then
		sResourceTTList = sResourceList .. "[NEWLINE]" .. sResourceTTList;
	elseif sResourceList ~= nil then
		sResourceTTList = sResourceList;
	end
	controlTable.ResourcesList:SetToolTipString( sResourceTTList or "" );
	if sResourceTTList ~= nil then
		controlTable.CivButton:SetToolTipString(Locale.ConvertTextKey(pCivInfo.ShortDescription) .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_DO_CIV_STATUS", GetApproach(pActivePlayer, pPlayer), GameInfo.Eras[pPlayer:GetCurrentEra()].Description, pPlayer:GetScore()) .. "[NEWLINE]" .. sResourceTTList);
	else
		controlTable.CivButton:SetToolTipString(Locale.ConvertTextKey(pCivInfo.ShortDescription) .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_DO_CIV_STATUS", GetApproach(pActivePlayer, pPlayer), GameInfo.Eras[pPlayer:GetCurrentEra()].Description, pPlayer:GetScore()));
	end

	local sResearchIcon = ""
	local sResearchTip = ""
	if (bIsActivePlayer) then
		sResearchIcon = "[ICON_RESEARCH]"
		sResearchTip = "TXT_KEY_DO_TRADE_STATUS_RA_TT"
	else
		if (pDeal:IsPossibleToTradeItem(iPlayer, iActivePlayer, TradeableItems.TRADE_ITEM_RESEARCH_AGREEMENT, Game.GetDealDuration())) then
			sResearchIcon = "[ICON_RESEARCH]"
			sResearchTip = "TXT_KEY_DO_TRADE_STATUS_RA_YES_TT"
		elseif (pTeam:IsHasResearchAgreement(iActiveTeam)) then
			sResearchIcon = "[ICON_INFLUENCE]"
			sResearchTip = "TXT_KEY_DO_TRADE_STATUS_RA_NO_TT"
		end
	end
	controlTable.ResearchText:SetText(sResearchIcon)
	controlTable.ResearchText:SetToolTipString(Locale.ConvertTextKey(sResearchTip))

	local sEmbassyIcon = ""
	local sEmbassyTip = ""
	if (bIsActivePlayer) then
		sEmbassyIcon = "[ICON_CITY_STATE]"
		sEmbassyTip = "TXT_KEY_DO_TRADE_STATUS_EMBASSY_TT"
	else
		if (pDeal:IsPossibleToTradeItem(iPlayer, iActivePlayer, TradeableItems.TRADE_ITEM_ALLOW_EMBASSY, Game.GetDealDuration()) and
				pDeal:IsPossibleToTradeItem(iActivePlayer, iPlayer, TradeableItems.TRADE_ITEM_ALLOW_EMBASSY, Game.GetDealDuration())) then
			sEmbassyIcon = "[ICON_CITY_STATE]"
			sEmbassyTip = "TXT_KEY_DO_TRADE_STATUS_EMBASSY_YES_TT"
		elseif (pTeam:HasEmbassyAtTeam(iActiveTeam) and pActiveTeam:HasEmbassyAtTeam(iTeam)) then
			sEmbassyIcon = "[ICON_INFLUENCE]"
			sEmbassyTip = "TXT_KEY_DO_TRADE_STATUS_EMBASSY_NO_TT"
		elseif (pActiveTeam:HasEmbassyAtTeam(iTeam)) then
			sEmbassyIcon = "[ICON_CAPITAL]"
			sEmbassyTip = "TXT_KEY_DO_TRADE_STATUS_EMBASSY_US_TT"
		elseif (pTeam:HasEmbassyAtTeam(iActiveTeam)) then
			sEmbassyIcon = "[ICON_CAPITAL]"
			sEmbassyTip = "TXT_KEY_DO_TRADE_STATUS_EMBASSY_THEM_TT"
		end
	end
	controlTable.EmbassyText:SetText(sEmbassyIcon)
	controlTable.EmbassyText:SetToolTipString(Locale.ConvertTextKey(sEmbassyTip))

	local sBordersIcon = ""
	local sBordersTip = ""
	if (bIsActivePlayer) then
		sBordersIcon = "[ICON_TRADE]"
		sBordersTip = "TXT_KEY_DO_TRADE_STATUS_BORDERS_TT"
	else
		if (pDeal:IsPossibleToTradeItem(iPlayer, iActivePlayer, TradeableItems.TRADE_ITEM_OPEN_BORDERS, Game.GetDealDuration()) and
				pDeal:IsPossibleToTradeItem(iActivePlayer, iPlayer, TradeableItems.TRADE_ITEM_OPEN_BORDERS, Game.GetDealDuration())) then
			sBordersIcon = "[ICON_TRADE]"
			sBordersTip = "TXT_KEY_DO_TRADE_STATUS_BORDERS_YES_TT"
		elseif (pTeam:IsAllowsOpenBordersToTeam(iActiveTeam) and pActiveTeam:IsAllowsOpenBordersToTeam(iTeam)) then
			sBordersIcon = "[ICON_TRADE_WHITE]"
			sBordersTip = "TXT_KEY_DO_TRADE_STATUS_BORDERS_NO_TT"
		elseif (pTeam:IsAllowsOpenBordersToTeam(iActiveTeam)) then
			sBordersIcon = "[ICON_TRADE_WHITE]"
			sBordersTip = "TXT_KEY_DO_TRADE_STATUS_BORDERS_US_TT"
		elseif (pActiveTeam:IsAllowsOpenBordersToTeam(iTeam)) then
			sBordersIcon = "[ICON_TRADE_WHITE]"
			sBordersTip = "TXT_KEY_DO_TRADE_STATUS_BORDERS_THEM_TT"
		end
	end
	controlTable.BordersText:SetText(sBordersIcon)
	controlTable.BordersText:SetToolTipString(Locale.ConvertTextKey(sBordersTip))

	local sGoldText = string.format("[ICON_GOLD]%d / %d", pDeal:GetGoldAvailable(iPlayer, -1), pPlayer:CalculateGoldRate())
	local sGoldTip = "TXT_KEY_DO_TRADE_STATUS_GOLD_TT"
	controlTable.GoldText:SetText(sGoldText)
	controlTable.GoldText:SetToolTipString(Locale.ConvertTextKey(sGoldTip))

	return controlTable
end

function GetApproach(pActivePlayer, pPlayer)
	local sApproach = ""

	if (pActivePlayer:GetID() ~= pPlayer:GetID()) then
		if (Teams[pActivePlayer:GetTeam()]:IsAtWar(pPlayer:GetTeam())) then
			sApproach = Locale.ConvertTextKey("TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_WAR")
		elseif (pPlayer:IsDenouncingPlayer(pActivePlayer:GetID())) then
			sApproach = Locale.ConvertTextKey("TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_DENOUNCING")
		else
			local iApproach = pActivePlayer:GetApproachTowardsUsGuess(pPlayer:GetID())
	
			if (iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_WAR) then
				sApproach = Locale.ConvertTextKey("TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_WAR")
			elseif (iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_HOSTILE) then
				sApproach = Locale.ConvertTextKey("TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_HOSTILE")
			elseif (iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_GUARDED) then
				sApproach = Locale.ConvertTextKey("TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_GUARDED")
			elseif (iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_NEUTRAL) then
				sApproach = Locale.ConvertTextKey("TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_NEUTRAL")
			elseif (iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_FRIENDLY) then
				sApproach = Locale.ConvertTextKey("TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_FRIENDLY")
			elseif (iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_AFRAID) then
				sApproach = Locale.ConvertTextKey("TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_AFRAID")
			end
		end
	end

	if (sApproach ~= "") then
		sApproach = sApproach .. ": "
	end

	return sApproach
end

function getNumResourceUntapped(pCs, pResource)
	local iCs = pCs:GetID();
	local pCapital = pCs:GetCapitalCity();
	local iNumResourcesUntapped = 0;
	
	if (pCapital ~= nil) then
		local thisX = pCapital:GetX();
		local thisY = pCapital:GetY();
		
		local iRange = GameDefines["MINOR_CIV_RESOURCE_SEARCH_RADIUS"]; --5
		local iCloseRange = math.floor(iRange/2); --2
		
		for iDX = -iRange, iRange, 1 do
			for iDY = -iRange, iRange, 1 do
				local pTargetPlot = Map.GetPlotXY(thisX, thisY, iDX, iDY);
				
				if (pTargetPlot ~= nil) then
					local iOwner = pTargetPlot:GetOwner();
					
					if (iOwner == iCs or iOwner == -1) then
						local plotDistance = Map.PlotDistance(thisX, thisY, pTargetPlot:GetX(), pTargetPlot:GetY());
						
						if (plotDistance <= iRange and (plotDistance <= iCloseRange or iOwner == iCs)) then
							if ( pTargetPlot:GetResourceType(Game.GetActiveTeam()) == pResource.ID ) then-- IsTrueResouce
								local bIsTrueImprovement = false;
								for pImprovementType in GameInfo.Improvement_ResourceTypes( "ResourceType = '" .. pResource.Type .. "'" ) do
									if pTargetPlot:GetImprovementType() == GameInfoTypes[pImprovementType.ImprovementType] then
										bIsTrueImprovement = true;
										break;
									end
								end
								if not bIsTrueImprovement then -- Untapped
									iNumResourcesUntapped = iNumResourcesUntapped + pTargetPlot:GetNumResource();
								end
							end
						end
					end
				end
			end
		end
	end

	return iNumResourcesUntapped
end

function OnCivSelected(iPlayer)
	if (Players[iPlayer]:IsHuman()) then
		Events.OpenPlayerDealScreenEvent(iPlayer)
	else
		UI.SetRepeatActionPlayer(iPlayer)
		UI.ChangeStartDiploRepeatCount(1)
		Players[iPlayer]:DoBeginDiploWithHuman()
	end
end

function OnCsSelected(iCs)
	local popupInfo = {
		Type = ButtonPopupTypes.BUTTONPOPUP_CITY_STATE_DIPLO,
		Data1 = iCs
	}
	
	Events.SerialEventGameMessagePopup(popupInfo)
end
