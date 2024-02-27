-------------------------------------------------
-- Help text for techs
-------------------------------------------------
local TechHelpStringTable = {}

function GetBaseHelpTextForTech( iTechID )
	local strHelpText = "";
	-- Leads to...
	local strLeadsTo = "";
	local bFirstLeadsTo = true;
	for row in GameInfo.Technology_PrereqTechs() do
		local pPrereqTech = GameInfo.Technologies[row.PrereqTech];
		local pLeadsToTech = GameInfo.Technologies[row.TechType];
		
		if (pPrereqTech and pLeadsToTech) then
			if (iTechID == pPrereqTech.ID) then
				
				-- If this isn't the first leads-to tech, then add a comma to separate
				if (bFirstLeadsTo) then
					bFirstLeadsTo = false;
				else
					strLeadsTo = strLeadsTo .. ", ";
				end
				
				strLeadsTo = strLeadsTo .. "[COLOR_POSITIVE_TEXT]" .. Locale.ConvertTextKey( pLeadsToTech.Description ) .. "[ENDCOLOR]";
			end
		end
	end
	
	if (strLeadsTo ~= "") then
		strHelpText = strHelpText .. " " .. Locale.ConvertTextKey("TXT_KEY_TECH_HELP_LEADS_TO", strLeadsTo);
	end

	-- Unlocks:
	local thisTech = GameInfo.Technologies[iTechID];

	local UnlocksString = "";

	UnlocksString = UnlocksString .. strHelpText;

	local techType = thisTech.Type;
	local condition = "TechType = '" .. techType .. "'";
	local prereqCondition = "PrereqTech = '" .. techType .. "'";
	local otherPrereqCondition = "TechPrereq = '" .. techType .. "'";
	local revealCondition = "TechReveal = '" .. techType .. "'";

	local UnitString = Locale.ConvertTextKey("TXT_KEY_TECH_HELP_UNITS_UNLOCKED_SP");
	local numUnits = 0;
	-- Unlock Unit
	for thisUnitInfo in GameInfo.Units( prereqCondition ) do
		if thisUnitInfo.ShowInPedia
        then
			if numUnits > 0 then
				UnitString = UnitString .. "[NEWLINE]"
			end
			numUnits = numUnits + 1;
			UnitString = UnitString .. " [ICON_BULLET] " .. Locale.ConvertTextKey(thisUnitInfo.Description);
		end
	end
	if numUnits > 0 then
		UnlocksString = UnlocksString .. UnitString
	end
		
	local BuildingString = Locale.ConvertTextKey("TXT_KEY_TECH_HELP_BUILDINGS_UNLOCKED_SP");
	local numBuildings = 0;
	-- Unlock Buildings
	for thisBuildingInfo in GameInfo.Buildings( prereqCondition ) do
		if thisBuildingInfo
		then
			local thisBuildingClass = GameInfo.BuildingClasses[thisBuildingInfo.BuildingClass];
			if thisBuildingClass.MaxGlobalInstances <= 0
			then
				if numBuildings > 0 then
					BuildingString = BuildingString .. "[NEWLINE]"
				end
				BuildingString = BuildingString .. " [ICON_BULLET] " .. Locale.ConvertTextKey(thisBuildingInfo.Description);
				numBuildings = numBuildings + 1;
			end
		end
	end

	if numBuildings > 0 then
		UnlocksString = UnlocksString .. BuildingString
	end

	local WonderString = Locale.ConvertTextKey("TXT_KEY_TECH_HELP_WONDERS_UNLOCKED_SP");
	local numWonders = 0;

	-- Unlock Wonder
	for thisBuildingInfo in GameInfo.Buildings( prereqCondition ) do
		if thisBuildingInfo
		then
			local thisBuildingClass = GameInfo.BuildingClasses[thisBuildingInfo.BuildingClass];
			if thisBuildingClass.MaxGlobalInstances > 0  then
				if numWonders > 0 then
					WonderString = WonderString .. "[NEWLINE]"
				end
				WonderString = WonderString .. " [ICON_BULLET] " .. Locale.ConvertTextKey(thisBuildingInfo.Description);
				numWonders = numWonders + 1;
			end
		end
	end

	if numWonders > 0 then
		UnlocksString = UnlocksString .. WonderString
	end
		
	local ProjectString = Locale.ConvertTextKey("TXT_KEY_TECH_HELP_PROJECTS_UNLOCKED_SP");
	local numProjects = 0;
	-- Unlock Projects
	for thisProjectInfo in GameInfo.Projects( otherPrereqCondition ) do	
		if thisProjectInfo then
			if numProjects > 0 then
				ProjectString = ProjectString .. "[NEWLINE]"
			end
			numProjects = numProjects + 1;
			ProjectString = ProjectString .. " [ICON_BULLET] " .. Locale.ConvertTextKey(thisProjectInfo.Description);
		end
	end
	if numProjects > 0 then
		UnlocksString = UnlocksString .. ProjectString
	end

	local ProcessesString = Locale.ConvertTextKey("TXT_KEY_TECH_HELP_PROCESSES_UNLOCKED_SP");
	local numProcesses = 0;	
	-- Unlock Processes
	for thisProcessInfo in GameInfo.Processes( otherPrereqCondition ) do
		if(thisProcessInfo) then
			if numProcesses > 0 then
				ProcessesString = ProcessesString .. "[NEWLINE]"
			end
			numProcesses = numProcesses + 1;
			ProcessesString = ProcessesString .. " [ICON_BULLET] " .. Locale.ConvertTextKey(thisProcessInfo.Description);
		end			
	end
	if numProcesses > 0 then
		UnlocksString = UnlocksString .. ProcessesString
	end

	
	
	local ResourceString = Locale.ConvertTextKey("TXT_KEY_TECH_HELP_RESOURCES_UNLOCKED_SP");
	local numResources = 0;	
	-- Unlock Resources
	for revealedResource in GameInfo.Resources( revealCondition ) do
		if(revealedResource) then
			if numResources == 0 then
				ResourceString = ResourceString .. " [ICON_BULLET] "
			end
			if numResources > 0 then
				ResourceString = ResourceString .. ", "
			end
			numResources = numResources + 1;
			ResourceString = ResourceString .. Locale.ConvertTextKey(revealedResource.IconString) .. " " .. Locale.ConvertTextKey(revealedResource.Description);
		end			
	end
	if numResources > 0 then
		UnlocksString = UnlocksString .. ResourceString
	end

	local BuildString = Locale.ConvertTextKey("TXT_KEY_TECH_HELP_BUILDS_UNLOCKED_SP");
	local numBuilds = 0;	
	-- Unlock Builds
	for thisBuildInfo in GameInfo.Builds{ PrereqTech = techType, ShowInPedia = 1 } do
		if(thisBuildInfo) then
			if numBuilds > 0 then
				BuildString = BuildString .. "[NEWLINE]"
			end
			numBuilds = numBuilds + 1;
			BuildString = BuildString .. " [ICON_BULLET] " .. Locale.ConvertTextKey(thisBuildInfo.Description);
		end			
	end
	for thisBuildInfo in GameInfo.Build_TechTimeChanges{ TechType = techType} do
		if(thisBuildInfo) then
			if numBuilds > 0 then
				BuildString = BuildString .. "[NEWLINE]"
			end
			numBuilds = numBuilds + 1;
			BuildString = BuildString .. " [ICON_BULLET] " .. Locale.ConvertTextKey("TXT_KEY_TECH_HELP_BUILD_REDUCTION_SP", GameInfo.Builds[thisBuildInfo.BuildType].Description, thisBuildInfo.TimeChange/100);
		end			
	end
	if numBuilds > 0 then
		UnlocksString = UnlocksString .. BuildString
	end


	-- Extra Yield For Improvement
	local yieldsString = Locale.ConvertTextKey("TXT_KEY_TECH_HELP_YIELDS_UNLOCKED_SP") .. " [ICON_BULLET] ";
	local numYields = 0;
	

	for row in GameInfo.Improvement_TechYieldChanges( condition ) do
		if numYields > 0 then
				yieldsString = yieldsString .. "[NEWLINE] [ICON_BULLET] ";
		end
		yieldsString = yieldsString .. Locale.ConvertTextKey("TXT_KEY_CIVILOPEDIA_SPECIALABILITIES_YIELDCHANGES", GameInfo.Improvements[row.ImprovementType].Description, GameInfo.Yields[row.YieldType].IconString, row.Yield, Locale.ConvertTextKey(GameInfo.Yields[row.YieldType].IconString));
		numYields = numYields + 1;
	end	

	for row in GameInfo.Improvement_TechNoFreshWaterYieldChanges( condition ) do
		if numYields > 0 then
				yieldsString = yieldsString .. "[NEWLINE] [ICON_BULLET] ";
		end
			
		yieldsString = yieldsString .. Locale.ConvertTextKey("TXT_KEY_CIVILOPEDIA_SPECIALABILITIES_NOFRESHWATERYIELDCHANGES", GameInfo.Improvements[row.ImprovementType].Description, GameInfo.Yields[row.YieldType].IconString, row.Yield, Locale.ConvertTextKey(GameInfo.Yields[row.YieldType].IconString));
		numYields = numYields + 1;
	end	

	for row in GameInfo.Improvement_TechFreshWaterYieldChanges( condition ) do
		if numYields > 0 then
				yieldsString = yieldsString .. "[NEWLINE] [ICON_BULLET] ";
		end
		yieldsString = yieldsString .. Locale.ConvertTextKey("TXT_KEY_CIVILOPEDIA_SPECIALABILITIES_FRESHWATERYIELDCHANGES", GameInfo.Improvements[row.ImprovementType].Description, GameInfo.Yields[row.YieldType].IconString, row.Yield, Locale.ConvertTextKey(GameInfo.Yields[row.YieldType].IconString));
		numYields = numYields + 1;
	end

	if(numYields > 0) then
		UnlocksString = UnlocksString .. yieldsString
	end
	


	-- Unlock Abilities
	local abilitiesString = Locale.ConvertTextKey("TXT_KEY_TECH_HELP_ACTIONS_UNLOCKED_SP") .. " [ICON_BULLET] ";
	local numAbilities = 0;

	for row in GameInfo.Route_TechMovementChanges( condition ) do
		if numAbilities > 0 then
				abilitiesString = abilitiesString .. "[NEWLINE] [ICON_BULLET] ";
		end
		abilitiesString = abilitiesString .. Locale.ConvertTextKey("TXT_KEY_CIVILOPEDIA_SPECIALABILITIES_MOVEMENT", GameInfo.Routes[row.RouteType].Description);
		numAbilities = numAbilities + 1;
	end	

	if thisTech.EmbarkedMoveChange > 0 then
		if numAbilities > 0 then
				abilitiesString = abilitiesString .. "[NEWLINE] [ICON_BULLET] ";
		end
		abilitiesString = abilitiesString .. Locale.ConvertTextKey( "TXT_KEY_ABLTY_FAST_EMBARK_STRING" );
		numAbilities = numAbilities + 1;
	end
	
	if thisTech.AllowsEmbarking then
		if numAbilities > 0 then
				abilitiesString = abilitiesString .. "[NEWLINE] [ICON_BULLET] ";
		end
		abilitiesString = abilitiesString .. Locale.ConvertTextKey( "TXT_KEY_ALLOWS_EMBARKING" );
		numAbilities = numAbilities + 1;
	end
	
	if thisTech.AllowsDefensiveEmbarking then
		if numAbilities > 0 then
				abilitiesString = abilitiesString .. "[NEWLINE] [ICON_BULLET] ";
		end
		abilitiesString = abilitiesString .. Locale.ConvertTextKey( "TXT_KEY_ABLTY_DEFENSIVE_EMBARK_STRING" );
		numAbilities = numAbilities + 1;
	end
	
	if thisTech.EmbarkedAllWaterPassage then
		if numAbilities > 0 then
				abilitiesString = abilitiesString .. "[NEWLINE] [ICON_BULLET] ";
		end
		abilitiesString = abilitiesString ..  Locale.ConvertTextKey( "TXT_KEY_ABLTY_OCEAN_EMBARK_STRING" );
		numAbilities = numAbilities + 1;
	end

	if thisTech.AllowEmbassyTradingAllowed then
		if numAbilities > 0 then
			abilitiesString = abilitiesString .. "[NEWLINE] [ICON_BULLET] ";
		end
		abilitiesString = abilitiesString .. Locale.ConvertTextKey( "TXT_KEY_ABLTY_ALLOW_EMBASSY_STRING" );
		numAbilities = numAbilities + 1;
	end
	
	if thisTech.OpenBordersTradingAllowed then
		if numAbilities > 0 then
				abilitiesString = abilitiesString .. "[NEWLINE] [ICON_BULLET] ";
		end
		abilitiesString = abilitiesString .. Locale.ConvertTextKey( "TXT_KEY_ABLTY_OPEN_BORDER_STRING" );
		numAbilities = numAbilities + 1;
	end
	
	if thisTech.DefensivePactTradingAllowed then
		if numAbilities > 0 then
				abilitiesString = abilitiesString .. "[NEWLINE] [ICON_BULLET] ";
		end
		abilitiesString = abilitiesString .. Locale.ConvertTextKey( "TXT_KEY_ABLTY_D_PACT_STRING" );
		numAbilities = numAbilities + 1;
	end
	
	if thisTech.TradeAgreementTradingAllowed then
		if numAbilities > 0 then
				abilitiesString = abilitiesString .. "[NEWLINE] [ICON_BULLET] ";
		end
		abilitiesString = abilitiesString .. Locale.ConvertTextKey( "TXT_KEY_ABLTY_T_PACT_STRING" );
		numAbilities = numAbilities + 1;
	end
	
	if thisTech.BridgeBuilding then
		if numAbilities > 0 then
				abilitiesString = abilitiesString .. "[NEWLINE] [ICON_BULLET] ";
		end
		abilitiesString = abilitiesString .. Locale.ConvertTextKey( "TXT_KEY_ABLTY_BRIDGE_STRING" );
		numAbilities = numAbilities + 1;
	end

	if thisTech.MapVisible then
		if numAbilities > 0 then
			abilitiesString = abilitiesString .. "[NEWLINE] [ICON_BULLET] ";
		end
		abilitiesString = abilitiesString .. Locale.ConvertTextKey( "TXT_KEY_REVEALS_ENTIRE_MAP");
		numAbilities = numAbilities + 1;
	end

	if thisTech.BombardIndirect > 0 then
		if numAbilities > 0 then
			abilitiesString = abilitiesString .. "[NEWLINE] [ICON_BULLET] ";
		end
		abilitiesString = abilitiesString .. Locale.ConvertTextKey( "TXT_KEY_CITY_BOMBARDMENT_MOD_SP");
		numAbilities = numAbilities + 1;
	end

	if thisTech.InternationalTradeRoutesChange > 0 then
		if numAbilities > 0 then
				abilitiesString = abilitiesString .. "[NEWLINE] [ICON_BULLET] ";
		end
		abilitiesString = abilitiesString .. "[ICON_INTERNATIONAL_TRADE] " .. Locale.ConvertTextKey( "TXT_KEY_ADDITIONAL_INTERNATIONAL_TRADE_ROUTE");
		numAbilities = numAbilities + 1;
	end

	for row in GameInfo.Technology_TradeRouteDomainExtraRange(condition) do
		if (row.TechType == techType and row.Range > 0) then
			if numAbilities > 0 then
				abilitiesString = abilitiesString .. "[NEWLINE] [ICON_BULLET] ";
			end
			if (GameInfo.Domains[row.DomainType].ID == DomainTypes.DOMAIN_LAND) then
				abilitiesString = abilitiesString .. Locale.ConvertTextKey( "TXT_KEY_EXTENDS_LAND_TRADE_ROUTE_RANGE");
			elseif (GameInfo.Domains[row.DomainType].ID == DomainTypes.DOMAIN_SEA) then
				abilitiesString = abilitiesString .. Locale.ConvertTextKey( "TXT_KEY_EXTENDS_SEA_TRADE_ROUTE_RANGE");
			end
			numAbilities = numAbilities + 1;
		end
	end
	
	if thisTech.InfluenceSpreadModifier > 0 then
		if numAbilities > 0 then
				abilitiesString = abilitiesString .. "[NEWLINE] [ICON_BULLET] ";
		end
		abilitiesString = abilitiesString .. Locale.ConvertTextKey( "TXT_KEY_DOUBLE_TOURISM_PERCENT", thisTech.InfluenceSpreadModifier);
		numAbilities = numAbilities + 1;
	end
	
	if thisTech.AllowsWorldCongress then
		if numAbilities > 0 then
				abilitiesString = abilitiesString .. "[NEWLINE] [ICON_BULLET] ";
		end
		abilitiesString = abilitiesString .. Locale.ConvertTextKey( "TXT_KEY_ALLOWS_WORLD_CONGRESS");
		numAbilities = numAbilities + 1;
	end
	
	if thisTech.ExtraVotesPerDiplomat > 0 then
		if numAbilities > 0 then
				abilitiesString = abilitiesString .. "[NEWLINE] [ICON_BULLET] ";
		end
		abilitiesString = abilitiesString .. Locale.ConvertTextKey( "TXT_KEY_EXTRA_VOTES_FROM_DIPLOMATS", thisTech.ExtraVotesPerDiplomat );
		numAbilities = numAbilities + 1;
	end
	
	for row in GameInfo.Technology_FreePromotions(condition) do
		local promotion = GameInfo.UnitPromotions[row.PromotionType];
		if promotion then
			if numAbilities > 0 then
				abilitiesString = abilitiesString .. "[NEWLINE] [ICON_BULLET] ";
			end
			abilitiesString = abilitiesString .. Locale.ConvertTextKey( "TXT_KEY_FREE_PROMOTION_FROM_TECH_SHORT", promotion.Help );
			numAbilities = numAbilities + 1;
		end
	end

	if (thisTech.ResearchAgreementTradingAllowed) then
		if numAbilities > 0 then
			abilitiesString = abilitiesString .. "[NEWLINE] [ICON_BULLET] ";
		end
		abilitiesString = abilitiesString .. Locale.ConvertTextKey( "TXT_KEY_ABLTY_R_PACT_STRING" );
		numAbilities = numAbilities + 1;
	end

    if thisTech.WorkerSpeedModifier > 0 then
		if numAbilities > 0 then
			abilitiesString = abilitiesString .. "[NEWLINE] [ICON_BULLET] ";
		end
		abilitiesString = abilitiesString .. Locale.ConvertTextKey( "TXT_KEY_TECH_HELP_WORKER_SPEED_MODIFIER_SP", thisTech.WorkerSpeedModifier);
		numAbilities = numAbilities + 1;
	end

    if thisTech.RazeSpeedModifier > 0 then
		if numAbilities > 0 then
			abilitiesString = abilitiesString .. "[NEWLINE] [ICON_BULLET] ";
		end
		abilitiesString = abilitiesString .. Locale.ConvertTextKey( "TXT_KEY_TECH_HELP_RAZE_SPEED_MODIFIER_SP", thisTech.RazeSpeedModifier);
		numAbilities = numAbilities + 1;
	end

	if thisTech.RemoveOceanImpassableCivilian then
		if numAbilities > 0 then
			abilitiesString = abilitiesString .. "[NEWLINE] [ICON_BULLET] ";
		end
		abilitiesString = abilitiesString .. Locale.ConvertTextKey( "TXT_KEY_TECH_HELP_ALL_CIVILIANS_CROSS_OCEAN_SP");
		numAbilities = numAbilities + 1;
	end

	if iTechID == GameInfo.Technologies["TECH_AUTOMATION_T"].ID then
		if numAbilities > 0 then
			abilitiesString = abilitiesString .. "[NEWLINE] [ICON_BULLET] ";
		end
		abilitiesString = abilitiesString .. Locale.ConvertTextKey( "TXT_KEY_SP_TECH_AUTOMATION_T_HELP_SHORT");
		numAbilities = numAbilities + 1;
	end


	if(numAbilities > 0) then
		UnlocksString = UnlocksString .. abilitiesString
	end
	
	return UnlocksString;
end

function RoadTechHelpString()
	for row in GameInfo.Technologies() do
		if TechHelpStringTable[row.ID] == nil then
			TechHelpStringTable[row.ID] = GetBaseHelpTextForTech( row.ID );
		end
	end
	print("Pre Road Tech Help String Success!")
end

RoadTechHelpString()

function GetShortHelpTextForTech(iTechID)
	if TechHelpStringTable[iTechID] == nil then
		print("TechHelpInclude.lua: nil Value:",iTechID)
		return ""
	end
	return TechHelpStringTable[iTechID]
end

function GetHelpTextForTech( iTechID )
	local pTechInfo = GameInfo.Technologies[iTechID];
	
	local strHelpText = "";

	if(Game ~= nil) then
		local pActiveTeam = Teams[Game.GetActiveTeam()];
		local pActivePlayer = Players[Game.GetActivePlayer()];
		local pTeamTechs = pActiveTeam:GetTeamTechs();
		local iTechCost = pActivePlayer:GetResearchCost(iTechID);
	
		-- Name
		strHelpText = strHelpText .. Locale.ToUpper(Locale.ConvertTextKey( pTechInfo.Description ));

		-- Do we have this tech?
		if (pTeamTechs:HasTech(iTechID)) then
			strHelpText = strHelpText .. " [COLOR_POSITIVE_TEXT](" .. Locale.ConvertTextKey("TXT_KEY_RESEARCHED") .. ")[ENDCOLOR]";
		end

		-- Cost/Progress
		strHelpText = strHelpText .. "[NEWLINE]-------------------------[NEWLINE]";
	
		local iProgress = pActivePlayer:GetResearchProgress(iTechID);
		local iOverflow = pActivePlayer:GetOverflowResearch();
		local bShowProgress = true;
	
		-- Don't show progres if we have 0 or we're done with the tech
		if (iProgress == 0 or pTeamTechs:HasTech(iTechID)) then
			bShowProgress = false;
		end
	
		if (bShowProgress) then
			if iOverflow > 0 then
				strHelpText = strHelpText .. " " .. Locale.ConvertTextKey("TXT_KEY_TECH_HELP_PROGRESS_WITH_OVERFLOW", iProgress, iTechCost, iOverflow);
			else
				strHelpText = strHelpText .. " " .. Locale.ConvertTextKey("TXT_KEY_TECH_HELP_COST_WITH_PROGRESS", iProgress, iTechCost);
			end
		else
			strHelpText = strHelpText .. " " .. Locale.ConvertTextKey("TXT_KEY_TECH_HELP_COST", iTechCost);
		end
	end
	
	strHelpText = strHelpText .. "[NEWLINE]" .. GetShortHelpTextForTech(iTechID)
	return strHelpText
end