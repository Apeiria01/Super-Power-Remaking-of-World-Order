include("UtilityFunctions")

-------------------------------------------------------------------Automation---------------------------------------------------
AllUnitsSleepButton = {
    Name = "All Units Order",
    Title = "TXT_KEY_SP_UI_BTN_ALL_SLEEP", -- or a TXT_KEY
    OrderPriority = 0, -- default is 200
    IconAtlas = "UNIT_ACTION_GOLD_ATLAS", -- 45 and 64 variations required
    PortraitIndex = 6,
    ToolTip = "TXT_KEY_SP_UI_BTN_ALL_SLEEP_HELP", -- or a TXT_KEY_ or a function

    Condition = function(action, unit)
        return unit:CanMove();
    end, -- or nil or a boolean, default is true

    Disabled = function(action, unit)
        return false; -- unit:GetDomainType() ~= DomainTypes.DOMAIN_AIR and not unit:IsCombatUnit();
    end, -- or nil or a boolean, default is false

    Action = function(action, unit, eClick)
        local pPlayer = Players[unit:GetOwner()];

        for pUnit in pPlayer:Units() do
            if not pUnit:CanMove() or pUnit:GetActivityType() ~= 0 then
            elseif pUnit:CanDoCommand(CommandTypes.COMMAND_AUTOMATE, 0) and not pUnit:IsCombatUnit() then
                pUnit:DoCommand(CommandTypes.COMMAND_AUTOMATE, 0);
            elseif (GameInfo.Units[pUnit:GetUnitType()].DefaultUnitAI == "UNITAI_EXPLORE" or GameInfo.Units[pUnit:GetUnitType()].DefaultUnitAI == "UNITAI_EXPLORE_SEA") and pUnit:CanDoCommand(CommandTypes.COMMAND_AUTOMATE, 1) then
                pUnit:DoCommand(CommandTypes.COMMAND_AUTOMATE, 1);
            elseif pUnit:CanStartMission(GameInfoTypes.MISSION_AIRPATROL) and pUnit:GetCurrHitPoints() > 30 then
                pUnit:PushMission(GameInfoTypes.MISSION_AIRPATROL);
            elseif pUnit:CanStartMission(GameInfoTypes.MISSION_HEAL) then
                pUnit:PushMission(GameInfoTypes.MISSION_HEAL);
            elseif pUnit:CanStartMission(GameInfoTypes.MISSION_ALERT) then
                pUnit:PushMission(GameInfoTypes.MISSION_ALERT);
            elseif pUnit:CanStartMission(GameInfoTypes.MISSION_SLEEP) then
                pUnit:PushMission(GameInfoTypes.MISSION_SLEEP);
            end
        end

        print("All Sleep Pressed!");
    end
};
LuaEvents.UnitPanelActionAddin(AllUnitsSleepButton);

AllUnitsWakeButton = {
    Name = "All Units Wake",
    Title = "TXT_KEY_SP_UI_BTN_ALL_WAKE", -- or a TXT_KEY
    OrderPriority = 0, -- default is 200
    IconAtlas = "SP_UNIT_ACTION_ATLAS", -- 45 and 64 variations required
    PortraitIndex = 27,
    ToolTip = "TXT_KEY_SP_UI_BTN_ALL_WAKE_HELP", -- or a TXT_KEY_ or a function

    Condition = function(action, unit)
        return unit:CanMove();
    end, -- or nil or a boolean, default is true

    Disabled = function(action, unit)
        return false;
    end, -- or nil or a boolean, default is false

    Action = function(action, unit, eClick)
        local pPlayer = Players[unit:GetOwner()];

        for pUnit in pPlayer:Units() do
            if pUnit:CanDoCommand(CommandTypes.COMMAND_WAKE) then
                pUnit:DoCommand(CommandTypes.COMMAND_WAKE);
            elseif pUnit:IsAutomated() then
                pUnit:DoCommand(CommandTypes.COMMAND_STOP_AUTOMATION);
            elseif pUnit:CanDoCommand(CommandTypes.COMMAND_CANCEL) then
                pUnit:DoCommand(CommandTypes.COMMAND_CANCEL);
            end
        end

        print("All Wake Pressed!")
    end
};
LuaEvents.UnitPanelActionAddin(AllUnitsWakeButton);

AllUnitsUpgradeButton = {
    Name = "All Units Upgrade",
    Title = "TXT_KEY_SP_UI_BTN_ALL_UPGRADE", -- or a TXT_KEY
    OrderPriority = 0, -- default is 200
    IconAtlas = "SP_UNIT_ACTION_ATLAS", -- 45 and 64 variations required
    PortraitIndex = 15,
    ToolTip = "TXT_KEY_SP_UI_BTN_ALL_UPGRADE_HELP", -- or a TXT_KEY_ or a function

    Condition = function(action, unit)
        return unit:CanMove();
    end, -- or nil or a boolean, default is true

    Disabled = function(action, unit)
        return false;
    end, -- or nil or a boolean, default is false

    Action = function(action, unit, eClick)
        local pPlayer = Players[unit:GetOwner()];

        for pUnit in pPlayer:Units() do
            if pUnit:CanUpgradeRightNow() and pUnit:CanMove() then
                pUnit:DoCommand(CommandTypes["COMMAND_UPGRADE"]);
            end
        end

        print("All Upgrade Pressed!")
    end
};
LuaEvents.UnitPanelActionAddin(AllUnitsUpgradeButton);

SameCombatClassSleepButton = {
    Name = "SCC Units Order",
    Title = "TXT_KEY_SP_UI_BTN_SCC_SLEEP", -- or a TXT_KEY
    OrderPriority = 200, -- default is 200
    IconAtlas = "SP_UNIT_ACTION_ATLAS", -- 45 and 64 variations required
    PortraitIndex = 14,
    ToolTip = "TXT_KEY_SP_UI_BTN_SCC_SLEEP_HELP", -- or a TXT_KEY_ or a function

    Condition = function(action, unit)
        return unit:CanMove() and unit:GetActivityType() == 0;
    end, -- or nil or a boolean, default is true

    Disabled = function(action, unit)
        return false; -- unit:GetDomainType() ~= DomainTypes.DOMAIN_AIR and not unit:IsCombatUnit();
    end, -- or nil or a boolean, default is false

    Action = function(action, unit, eClick)
        local pPlayer = Players[unit:GetOwner()];

        for pUnit in pPlayer:Units() do
            if pUnit:GetUnitCombatType() ~= unit:GetUnitCombatType() or GameInfo.Units[pUnit:GetUnitType()].DefaultUnitAI ~= GameInfo.Units[unit:GetUnitType()].DefaultUnitAI or not pUnit:CanMove() or pUnit:GetActivityType() ~= 0 then
            elseif pUnit:CanStartMission(GameInfoTypes.MISSION_SLEEP) and not pUnit:IsCombatUnit() then
                pUnit:PushMission(GameInfoTypes.MISSION_SLEEP);
            elseif (GameInfo.Units[pUnit:GetUnitType()].DefaultUnitAI == "UNITAI_EXPLORE" or GameInfo.Units[pUnit:GetUnitType()].DefaultUnitAI == "UNITAI_EXPLORE_SEA") and pUnit:CanDoCommand(CommandTypes.COMMAND_AUTOMATE, 1) then
                pUnit:DoCommand(CommandTypes.COMMAND_AUTOMATE, 1);
            elseif pUnit:CanStartMission(GameInfoTypes.MISSION_AIRPATROL) and pUnit:GetCurrHitPoints() > 30 then
                pUnit:PushMission(GameInfoTypes.MISSION_AIRPATROL);
            elseif pUnit:CanStartMission(GameInfoTypes.MISSION_HEAL) then
                pUnit:PushMission(GameInfoTypes.MISSION_HEAL);
            elseif pUnit:CanStartMission(GameInfoTypes.MISSION_ALERT) then
                pUnit:PushMission(GameInfoTypes.MISSION_ALERT);
            elseif pUnit:CanStartMission(GameInfoTypes.MISSION_SLEEP) then
                pUnit:PushMission(GameInfoTypes.MISSION_SLEEP);
            end
        end

        print("SCC Sleep Pressed!");
    end
};
LuaEvents.UnitPanelActionAddin(SameCombatClassSleepButton);

SameCombatClassWakeButton = {
    Name = "SCC Units Wake",
    Title = "TXT_KEY_SP_UI_BTN_SCC_WAKE", -- or a TXT_KEY
    OrderPriority = 200, -- default is 200
    IconAtlas = "UNIT_ACTION_GOLD_ATLAS", -- 45 and 64 variations required
    PortraitIndex = 5,
    ToolTip = "TXT_KEY_SP_UI_BTN_SCC_WAKE_HELP", -- or a TXT_KEY_ or a function

    Condition = function(action, unit)
        return unit:CanMove() and unit:GetActivityType() ~= 0;
    end, -- or nil or a boolean, default is true

    Disabled = function(action, unit)
        return false;
    end, -- or nil or a boolean, default is false

    Action = function(action, unit, eClick)
        local pPlayer = Players[unit:GetOwner()];

        for pUnit in pPlayer:Units() do
            if pUnit:GetUnitCombatType() ~= unit:GetUnitCombatType() or GameInfo.Units[pUnit:GetUnitType()].DefaultUnitAI ~= GameInfo.Units[unit:GetUnitType()].DefaultUnitAI then
            elseif pUnit:CanDoCommand(CommandTypes.COMMAND_WAKE) then
                pUnit:DoCommand(CommandTypes.COMMAND_WAKE);
            elseif pUnit:IsAutomated() then
                pUnit:DoCommand(CommandTypes.COMMAND_STOP_AUTOMATION);
            elseif pUnit:CanDoCommand(CommandTypes.COMMAND_CANCEL) then
                pUnit:DoCommand(CommandTypes.COMMAND_CANCEL);
            end
        end

        print("SCC Wake Pressed!")
    end
};
LuaEvents.UnitPanelActionAddin(SameCombatClassWakeButton);

SameCombatClassUpgradeButton = {
    Name = "SCC Units Upgrade",
    Title = "TXT_KEY_SP_UI_BTN_SCC_UPGRADE", -- or a TXT_KEY
    OrderPriority = 200, -- default is 200
    IconAtlas = "UNIT_ACTION_GOLD_ATLAS", -- 45 and 64 variations required
    PortraitIndex = 44,
    ToolTip = "TXT_KEY_SP_UI_BTN_SCC_UPGRADE_HELP", -- or a TXT_KEY_ or a function

    Condition = function(action, unit)
        return unit:CanUpgradeRightNow();
    end, -- or nil or a boolean, default is true

    Disabled = function(action, unit)
        return false;
    end, -- or nil or a boolean, default is false

    Action = function(action, unit, eClick)
        local pPlayer = Players[unit:GetOwner()];

        for pUnit in pPlayer:Units() do
            if pUnit:GetUnitCombatType() == unit:GetUnitCombatType() and GameInfo.Units[pUnit:GetUnitType()].DefaultUnitAI == GameInfo.Units[unit:GetUnitType()].DefaultUnitAI and pUnit:CanUpgradeRightNow() and pUnit:CanMove() then
                pUnit:DoCommand(CommandTypes["COMMAND_UPGRADE"]);
            end
        end

        print("SCC Upgrade Pressed!")
    end
};
LuaEvents.UnitPanelActionAddin(SameCombatClassUpgradeButton);

-------------------------------------------------------------------Special Missions---------------------------------------------------

----Settler joins the city
SettlerMissionButton = {
    Name = "Settler enter city",
    Title = "TXT_KEY_SP_BTNNOTE_SETTLER_INTO_CITY_SHORT", -- or a TXT_KEY
    OrderPriority = 300, -- default is 200
    IconAtlas = "UNIT_ACTION_GOLD_ATLAS", -- 45 and 64 variations required
    PortraitIndex = 40,
    ToolTip = "TXT_KEY_SP_BTNNOTE_SETTLER_INTO_CITY", -- or a TXT_KEY_ or a function
    Condition = function(action, unit)
        local plot = unit:GetPlot()
        if plot == nil or not plot:IsCity() then return false end
        local city = plot:GetPlotCity()
        if city == nil then return false end
        return unit:CanMove() and unit:IsFound() and city:GetOwner() == unit:GetOwner();
    end, -- or nil or a boolean, default is true
    Disabled = function(action, unit)
        SettlerMissionButton.Title = Locale.ConvertTextKey("TXT_KEY_SP_BTNNOTE_SETTLER_INTO_CITY_SHORT")
        SettlerMissionButton.ToolTip = Locale.ConvertTextKey("TXT_KEY_SP_BTNNOTE_SETTLER_INTO_CITY")
        local city = unit:GetPlot():GetPlotCity()
        if not (unit:GetExtraPopConsume() > 0) then
            SettlerMissionButton.ToolTip = SettlerMissionButton.ToolTip .. Locale.ConvertTextKey("TXT_KEY_SP_BTNNOTE_SETTLER_INTO_CITY_DISABLE_1")
            return true
        else
            SettlerMissionButton.Title = SettlerMissionButton.Title .. "(" .. unit:GetExtraPopConsume() ..")"
        end
        if not city:CanGrowNormally() then
            SettlerMissionButton.ToolTip = SettlerMissionButton.ToolTip .. Locale.ConvertTextKey("TXT_KEY_SP_BTNNOTE_SETTLER_INTO_CITY_DISABLE_2")
            return true
        end
    end, -- or nil or a boolean, default is false

    Action = function(action, unit, eClick)
        local plot = unit:GetPlot();
        local city = plot:GetPlotCity()
        local player = Players[unit:GetOwner()]

        city:ChangePopulation(unit:GetExtraPopConsume(), true);
        local iPolicyCollectiveRule = GameInfo.Policies["POLICY_COLLECTIVE_RULE"].ID
        if not (player:HasPolicy(iPolicyCollectiveRule) and not player:IsPolicyBlocked(iPolicyCollectiveRule) and player:GetCurrentEra() >= GameInfo.Eras["ERA_RENAISSANCE"].ID) then
            city:SetFood(0);
        end

        unit:Kill();

        local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_SETTLER_INTO_CITY", unit:GetName(), city:GetName())
        local heading = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_SETTLER_INTO_CITY_SHORT", unit:GetName(), city:GetName())
        player:AddNotification(NotificationTypes.NOTIFICATION_CITY_GROWTH, text, heading, unit:GetX(), unit:GetY())

    end
};
LuaEvents.UnitPanelActionAddin(SettlerMissionButton);

-----------------Unit Transformation

-----Caravel and Explorer

CaravelToExplorerButton = {
    Name = "Caravel to Explorer",
    Title = "TXT_KEY_SP_BTNNOTE_UNIT_CARAVELTOEXPLORER_SHORT", -- or a TXT_KEY
    OrderPriority = 300, -- default is 200
    IconAtlas = "UNIT_ACTION_ATLAS", -- 45 and 64 variations required
    PortraitIndex = 15,
    ToolTip = "TXT_KEY_SP_BTNNOTE_UNIT_CARAVELTOEXPLORER", -- or a TXT_KEY_ or a function

    Condition = function(action, unit)
        return unit:CanMove() and unit:GetUnitClassType() == GameInfo.UnitClasses.UNITCLASS_CARAVEL.ID and unit:GetPlot():IsAdjacentToLand() and Players[unit:GetOwner()]:GetCapitalCity() ~= nil;
    end, -- or nil or a boolean, default is true

    Disabled = function(action, unit)
        local bIsDisabled = true;
        for i = 0, 5 do
            local adjPlot = Map.PlotDirection(unit:GetX(), unit:GetY(), i)
            if adjPlot ~= nil and adjPlot:IsCoastalLand() and adjPlot:GetArea() ~= Players[unit:GetOwner()]:GetCapitalCity():Plot():GetArea() then
                bIsDisabled = false;
                break
            end
        end
        return bIsDisabled;
    end, -- or nil or a boolean, default is false

    Action = function(action, unit, eClick)
        local plotX = unit:GetX()
        local plotY = unit:GetY()
        local player = Players[unit:GetOwner()]
        local iNewUnit = GameInfoTypes.UNIT_EXPLORERX;
        local overrideUnit = GameInfo.Civilization_UnitClassOverrides {
            UnitClassType = "UNITCLASS_EXPLORERX",
            CivilizationType = GameInfo.Civilizations[player:GetCivilizationType()].Type
        }();
        if overrideUnit and overrideUnit.UnitType then
            iNewUnit = GameInfoTypes[overrideUnit.UnitType];
        end

        local NewUnit = player:InitUnit(iNewUnit, plotX, plotY, UNITAI_EXPLORE)
        NewUnit:JumpToNearestValidPlot()

        unit:Kill()

    end
};
LuaEvents.UnitPanelActionAddin(CaravelToExplorerButton);

-----Launch UAV

UnitLaunchUavButton = {
    Name = "Launch UAV",
    Title = "TXT_KEY_SP_BTNNOTE_UNIT_LAUNCH_UAV_SHORT", -- or a TXT_KEY
    OrderPriority = 300, -- default is 200
    IconAtlas = "SP_UNIT_ACTION_ATLAS", -- 45 and 64 variations required
    PortraitIndex = 45,
    ToolTip = "TXT_KEY_SP_BTNNOTE_UNIT_LAUNCH_UAV", -- or a TXT_KEY_ or a function

    Condition = function(action, unit)
        local player = Players[unit:GetOwner()]
        local pTeam = Teams[player:GetTeam()]

        return unit:CanMove() and unit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_DRONE_CARRIER"].ID) and pTeam:IsHasTech(GameInfoTypes["TECH_ARTIFICIAL_INTELLIGENCE"]);
    end, -- or nil or a boolean, default is true

    Disabled = function(action, unit)
        return unit:GetPlot() == nil or unit:GetPlot():GetTerrainType() == GameInfo.Terrains.TERRAIN_OCEAN.ID or unit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_DRONE_RELEASED"].ID);
    end, -- or nil or a boolean, default is false

    Action = function(action, unit, eClick)
        local plotX = unit:GetX()
        local plotY = unit:GetY()
        local plot = unit:GetPlot()
        local player = Players[unit:GetOwner()]

        local NewUnit = player:InitUnit(GameInfoTypes.UNIT_UAV, plotX, plotY, UNITAI_EXPLORE)

        unit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_DRONE_RELEASED"].ID, true);
        if plot:GetPlotType() == PlotTypes.PLOT_LAND then
            NewUnit:JumpToNearestValidPlot();
        end

    end
};
LuaEvents.UnitPanelActionAddin(UnitLaunchUavButton);

-----Worker to Militia

WorkerToMilitiaButton = {
    Name = "Worker to Militia",
    Title = "TXT_KEY_SP_BTNNOTE_UNIT_WORKERTOMILITIA_SHORT", -- or a TXT_KEY
    OrderPriority = 300, -- default is 200
    IconAtlas = "SP_UNIT_ACTION_ATLAS", -- 45 and 64 variations required
    PortraitIndex = 44,
    ToolTip = "TXT_KEY_SP_BTNNOTE_UNIT_WORKERTOMILITIA", -- or a TXT_KEY_ or a function

    Condition = function(action, unit)
        return unit:CanMove() and unit:GetUnitClassType() == GameInfo.UnitClasses.UNITCLASS_WORKER.ID;
    end, -- or nil or a boolean, default is true

    Disabled = function(action, unit)
        return unit:IsEmbarked() or unit:GetPlot() == nil or not unit:GetPlot():IsFriendlyTerritory(unit:GetOwner()) or unit:GetPlot():GetNumUnits() > 1;
    end, -- or nil or a boolean, default is false

    Action = function(action, unit, eClick)
        local plot = unit:GetPlot()

        local plotX = plot:GetX()
        local plotY = plot:GetY()

        local player = Players[unit:GetOwner()]

        local sUnitType = GetCivSpecificUnit(player, "UNITCLASS_WARRIOR")
        local sUpgradeUnitType = GetUpgradeUnit(player, sUnitType)

        while (sUpgradeUnitType ~= nil) do
            sUnitType = sUpgradeUnitType
            sUpgradeUnitType = GetUpgradeUnit(player, sUnitType)
        end

        local NewUnit = player:InitUnit(GameInfoTypes[sUnitType], plotX, plotY, UNITAI_DEFENSE)

        if plot:GetNumUnits() > 2 then
            NewUnit:JumpToNearestValidPlot()
        end

        NewUnit:SetMoves(0)
        unit:Kill()

    end
};
LuaEvents.UnitPanelActionAddin(WorkerToMilitiaButton);

-----Militia to Worker

MilitiaToWorkerButton = {
    Name = "Militia to Worker",
    Title = "TXT_KEY_SP_BTNNOTE_UNIT_MILITIATOWORKER_SHORT", -- or a TXT_KEY
    OrderPriority = 300, -- default is 200
    IconAtlas = "SP_UNIT_ACTION_ATLAS", -- 45 and 64 variations required
    PortraitIndex = 43,
    ToolTip = "TXT_KEY_SP_BTNNOTE_UNIT_MILITIATOWORKER", -- or a TXT_KEY_ or a function

    Condition = function(action, unit)
        return unit:CanMove() and unit:GetDomainType() == DomainTypes.DOMAIN_LAND and unit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MILITIA_COMBAT"].ID);
    end, -- or nil or a boolean, default is true

    Disabled = function(action, unit)
        return unit:IsEmbarked() or unit:GetPlot() == nil or not unit:GetPlot():IsFriendlyTerritory(unit:GetOwner()) or unit:GetPlot():GetNumUnits() > 1;
    end, -- or nil or a boolean, default is false

    Action = function(action, unit, eClick)
        local plot = unit:GetPlot()

        local plotX = plot:GetX()
        local plotY = plot:GetY()

        local player = Players[unit:GetOwner()]

        local sUnitType = GetCivSpecificUnit(player, "UNITCLASS_WORKER")

        local NewUnit = player:InitUnit(GameInfoTypes[sUnitType], plotX, plotY, UNITAI_WORKER)

        if plot:GetNumUnits() > 2 then
            NewUnit:JumpToNearestValidPlot()
        end

        NewUnit:SetMoves(0)
        unit:Kill()

    end
};
LuaEvents.UnitPanelActionAddin(MilitiaToWorkerButton);

-----------------Recon Airunits Bonus
AirReconBonusButton = {
    Name = "Recon Airunits Bonus",
    Title = "TXT_KEY_SP_UI_BTN_AIR_RECON_SHORT", -- or a TXT_KEY
    OrderPriority = 200, -- default is 200
    IconAtlas = "SP_UNIT_ACTION_ATLAS", -- 45 and 64 variations required
    PortraitIndex = 20,
    ToolTip = "TXT_KEY_SP_UI_BTN_AIR_RECON", -- or a TXT_KEY_ or a function

    Condition = function(action, unit)
        return unit:CanMove() and unit:GetUnitType() == GameInfoTypes.UNIT_SR71_BLACKBIRD;
    end, -- or nil or a boolean, default is true

    Disabled = function(action, unit)
        return false;
    end, -- or nil or a boolean, default is false

    Action = function(action, unit, eClick)

        local plot = unit:GetPlot()
        local unitCount = plot:GetNumUnits()
        for i = 0, unitCount - 1, 1 do
            local pFoundUnit = plot:GetUnit(i)
            if pFoundUnit:GetDomainType() == DomainTypes.DOMAIN_AIR and Players[unit:GetOwner()] == Players[pFoundUnit:GetOwner()] then
                pFoundUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_BLACKBIRD_RECON"].ID, true)
                unit:SetMoves(GameDefines["MOVE_DENOMINATOR"])
                print("Air Recon Set for air units in the same tile!")
            end
        end
    end
};

LuaEvents.UnitPanelActionAddin(AirReconBonusButton);

-- Fast Movement Switch

UnitFastMoveMentnButton = {
    Name = "Fast Movement On",
    Title = "TXT_KEY_SP_BTNNOTE_UNIT_FASTMOVEMENT_SHORT", -- or a TXT_KEY
    OrderPriority = 200, -- default is 200
    IconAtlas = "SP_UNIT_ACTION_ATLAS", -- 45 and 64 variations required
    PortraitIndex = 17,
    ToolTip = "TXT_KEY_SP_BTNNOTE_UNIT_FASTMOVEMENT", -- or a TXT_KEY_ or a function

    Condition = function(action, unit)
        return unit:CanMove() and unit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_NUMIDIAN_MARCH"].ID) and not unit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_RAPID_MARCH"].ID);
    end, -- or nil or a boolean, default is true

    Disabled = function(action, unit)
        return unit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_RAPID_MARCH"].ID);
    end, -- or nil or a boolean, default is false

    Action = function(action, unit, eClick)

        unit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_RAPID_MARCH"].ID, true)

        --	unit:ChangeMoves (300)
        unit:SetMoves(unit:GetMoves() * 2)
        unit:SetMadeAttack(true)
        print("Fast Movement On!")

    end
};

LuaEvents.UnitPanelActionAddin(UnitFastMoveMentnButton);

----Full Attack Mode Switch

UnitFullAttackOnButton = {
    Name = "Full Attack Mode On",
    Title = "TXT_KEY_SP_BTNNOTE_UNIT_FULLATTACK_ON_SHORT", -- or a TXT_KEY
    OrderPriority = 200, -- default is 200
    IconAtlas = "UNIT_ACTION_ATLAS", -- 45 and 64 variations required
    PortraitIndex = 12,
    ToolTip = "TXT_KEY_SP_BTNNOTE_UNIT_FULLATTACK_ON", -- or a TXT_KEY_ or a function

    Condition = function(action, unit)
        return unit:CanMove() and unit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_CAN_FULL_FIRE"].ID) and not unit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_FULL_FIRE"].ID);
    end, -- or nil or a boolean, default is true

    Disabled = function(action, unit)
        return false;
    end, -- or nil or a boolean, default is false

    Action = function(action, unit, eClick)

        unit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_FULL_FIRE"].ID, true)
        local iMovesLeft = math.max(0, unit:MovesLeft() - 3 * GameDefines["MOVE_DENOMINATOR"])
        unit:SetMoves(iMovesLeft)
        print("Full Attack On!")

    end
};

LuaEvents.UnitPanelActionAddin(UnitFullAttackOnButton);

UnitFullAttackOffButton = {
    Name = "Full Attack Mode Off",
    Title = "TXT_KEY_SP_BTNNOTE_UNIT_FULLATTACK_OFF_SHORT", -- or a TXT_KEY
    OrderPriority = 200, -- default is 200
    IconAtlas = "SP_UNIT_ACTION_ATLAS", -- 45 and 64 variations required
    PortraitIndex = 12,
    ToolTip = "TXT_KEY_SP_BTNNOTE_UNIT_FULLATTACK_OFF", -- or a TXT_KEY_ or a function

    Condition = function(action, unit)
        return unit:CanMove() and unit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_FULL_FIRE"].ID);
    end, -- or nil or a boolean, default is true

    Disabled = function(action, unit)
        return not unit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_FULL_FIRE"].ID);
    end, -- or nil or a boolean, default is false

    Action = function(action, unit, eClick)

        unit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_FULL_FIRE"].ID, false)
        unit:SetMoves(0)
        print("Full Attack Off!")

    end
};

LuaEvents.UnitPanelActionAddin(UnitFullAttackOffButton);

-- Target Marking

UnitTargetMarkingButton = {
    Name = "Target Marking",
    Title = "TXT_KEY_SP_BTNNOTE_UNIT_TARGETMARKING_SHORT", -- or a TXT_KEY
    OrderPriority = 200, -- default is 200
    IconAtlas = "SP_UNIT_ACTION_ATLAS", -- 45 and 64 variations required
    PortraitIndex = 16,
    ToolTip = "TXT_KEY_SP_BTNNOTE_UNIT_TARGETMARKING", -- or a TXT_KEY_ or a function

    Condition = function(action, unit)
        return unit:CanMove() and unit:GetUnitType() == GameInfoTypes.UNIT_STEALTH_HELICOPTER;
    end, -- or nil or a boolean, default is true

    Disabled = function(action, unit)
        return unit:GetNumEnemyUnitsAdjacent(unit) < 1 or unit:GetMoves() < 2 * GameDefines["MOVE_DENOMINATOR"]
    end, -- or nil or a boolean, default is false

    Action = function(action, unit, eClick)
        local unitX = unit:GetX()
        local unitY = unit:GetY()

        for i = 0, 5 do
            local adjPlot = Map.PlotDirection(unitX, unitY, i)
            if (adjPlot ~= nil) then
                local pUnit = adjPlot:GetUnit(0)
                if (pUnit ~= nil) then
                    local iActivePlayer = Players[unit:GetOwner()]
                    local pPlayer = Players[pUnit:GetOwner()]

                    if PlayersAtWar(iActivePlayer, pPlayer) and not pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_ANTI_DEBUFF"].ID) then
                        pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MARKED_TARGET"].ID, true)

                        local heading = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_TARGET_MARKED")
                        local text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_TARGET_MARKED_HELP")
                        iActivePlayer:AddNotification(NotificationTypes.NOTIFICATION_GENERIC, text, heading, unitX, unitY)
                    else
                        print("Not at war!")
                    end
                end
            end
        end

        unit:SetMoves(unit:GetMoves() - 2 * GameDefines["MOVE_DENOMINATOR"])
    end
};

LuaEvents.UnitPanelActionAddin(UnitTargetMarkingButton);

----Air EVAC

UnitEVACButton = {
    Name = "Air EVAC",
    Title = "TXT_KEY_SP_BTNNOTE_UNIT_AIREVAC_SHORT", -- or a TXT_KEY
    OrderPriority = 200, -- default is 200
    IconAtlas = "SP_UNIT_ACTION_ATLAS", -- 45 and 64 variations required
    PortraitIndex = 11,
    ToolTip = "TXT_KEY_SP_BTNNOTE_UNIT_AIREVAC", -- or a TXT_KEY_ or a function

    Condition = function(action, unit)
        return unit:CanMove() and unit:GetUnitType() == GameInfoTypes.UNIT_TASKFORCE_141 and Players[unit:GetOwner()]:GetCapitalCity() ~= nil;
    end, -- or nil or a boolean, default is true

    Disabled = function(action, unit)
        return false
    end, -- or nil or a boolean, default is false

    Action = function(action, unit, eClick)
        local player = Players[unit:GetOwner()]
        local pCity = player:GetCapitalCity()
        local pPlot = pCity
        unit:SetXY(pPlot:GetX(), pPlot:GetY())
        unit:JumpToNearestValidPlot()
        unit:SetMoves(0)
        print("Evac!")

    end
};

LuaEvents.UnitPanelActionAddin(UnitEVACButton);

-----------------------------------------------------Special Forces-----------------------------------------------------------------------

--------Riot Control

UnitRiotControlButton = {
    Name = "Riot Control",
    Title = "TXT_KEY_SP_BTNNOTE_UNIT_RIOT_CONTROL_SHORT", -- or a TXT_KEY
    OrderPriority = 200, -- default is 200
    IconAtlas = "SP_UNIT_ACTION_ATLAS", -- 45 and 64 variations required
    PortraitIndex = 9,
    ToolTip = "TXT_KEY_SP_BTNNOTE_UNIT_RIOT_CONTROL", -- or a TXT_KEY_ or a function

    Condition = function(action, unit)
        return unit:CanMove() and unit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_SP_FORCE_X_1"].ID)
    end, -- or nil or a boolean, default is true

    Disabled = function(action, unit)
        local plot = unit:GetPlot();
        if not plot:IsCity() then
            return true
        end
        local city = plot:GetPlotCity()
        return not city or city:GetOwner() ~= unit:GetOwner() or not city:IsResistance() or (city:GetResistanceTurns() < 3 and not unit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_ANTI_RIOT_BONUS"].ID));
    end, -- or nil or a boolean, default is false

    Action = function(action, unit, eClick)
        local plot = unit:GetPlot()
        local city = plot:GetPlotCity()
        local player = Players[unit:GetOwner()]
        if not city then
            return
        end

        if unit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_ANTI_RIOT_BONUS"].ID) then
            city:ChangeResistanceTurns(-3)
            unit:SetMoves(0)
            unit:ChangeExperience(6)
        else
            city:ChangeResistanceTurns(-1)
            unit:SetMoves(0)
            unit:ChangeExperience(2)

        end
        print("Riot Control!")

    end
};

LuaEvents.UnitPanelActionAddin(UnitRiotControlButton);

ReconTargetGuideButton = {
    Name = "Recon Target Guide",
    Title = "TXT_KEY_SP_BTNNOTE_UNIT_RECON_TARGET_GUIDE_SHORT", -- or a TXT_KEY
    OrderPriority = 200, -- default is 200
    IconAtlas = "SP_UNIT_ACTION_ATLAS", -- 45 and 64 variations required
    PortraitIndex = 18,
    ToolTip = "TXT_KEY_SP_BTNNOTE_UNIT_RECON_TARGET_GUIDE", -- or a TXT_KEY_ or a function

    Condition = function(action, unit)
        return unit:CanMove() and (unit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_SP_FORCE_X_2"].ID) or unit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GREAT_ADMIRAL"].ID));
    end, -- or nil or a boolean, default is true

    Disabled = function(action, unit)
        local plot = unit:GetPlot()
        local unitCount = plot:GetNumUnits()

        if unitCount <= 1 then
            return true
        end

        --   	for i = 0, unitCount-1, 1 do  
        --  		local pFoundUnit = plot:GetUnit(i)
        --  		if pFoundUnit:GetID() ~= pDefendingUnit:GetID() then
        --	  		if not pFoundUnit:IsRanged() then
        --	  			return true 
        --	  		end
        --  		end
        --	end

    end, -- or nil or a boolean, default is false

    Action = function(action, unit, eClick)
        local plot = unit:GetPlot()
        local unitCount = plot:GetNumUnits()
        for i = 0, unitCount - 1, 1 do
            local pFoundUnit = plot:GetUnit(i)
            if pFoundUnit:IsCombatUnit() and pFoundUnit:IsRanged() and not pFoundUnit:IsEmbarked() then
                print("Found Ranged Unit in the same tile!")
                pFoundUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_TRAGET_CLEARSHOOT_III"].ID, true)
                unit:SetMoves(0)
            end
        end

        print("Target Guided!")

    end
};

LuaEvents.UnitPanelActionAddin(ReconTargetGuideButton);

--------Stealth Operation Switch
-- UnitStealthOnButton = {
--  Name = "Stealth Operation on",
--  Title = "TXT_KEY_SP_BTNNOTE_UNIT_STEALTH_ON_SHORT", -- or a TXT_KEY
--  OrderPriority = 200, -- default is 200
--  IconAtlas = "SP_UNIT_ACTION_ATLAS", -- 45 and 64 variations required
--  PortraitIndex = 20,
--  ToolTip = "TXT_KEY_SP_BTNNOTE_UNIT_STEALTH_ON", -- or a TXT_KEY_ or a function
--  
-- 
--  
--  Condition = function(action, unit)
--    return unit:CanMove() and not unit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_STEALTH_OPERATION"].ID) and unit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_SP_FORCE_X_2"].ID) 
--  end, -- or nil or a boolean, default is true
--  
-- Disabled = function(action, unit)  
--   
--    return unit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_STEALTH_OPERATION"].ID)
--  end, -- or nil or a boolean, default is false
--  
--  Action = function(action, unit, eClick) 	
--    unit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_STEALTH_OPERATION"].ID, true)  
--   	print ("Stealth On!")	
--  end
-- };
--
-- LuaEvents.UnitPanelActionAddin(UnitStealthOnButton);
--
--
--
-- UnitStealthOffButton = {
--  Name = "Stealth Operation off",
--  Title = "TXT_KEY_SP_BTNNOTE_UNIT_STEALTH_OFF_SHORT", -- or a TXT_KEY
--  OrderPriority = 200, -- default is 200
--  IconAtlas = "SP_UNIT_ACTION_ATLAS", -- 45 and 64 variations required
--  PortraitIndex = 21,
--  ToolTip = "TXT_KEY_SP_BTNNOTE_UNIT_STEALTH_OFF", -- or a TXT_KEY_ or a function
--  
--  
-- Condition = function(action, unit)
--    return unit:CanMove() and unit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_STEALTH_OPERATION"].ID);
--  end, -- or nil or a boolean, default is true
--  
--  Disabled = function(action, unit)     
--    return not unit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_STEALTH_OPERATION"].ID) ;
--  end, -- or nil or a boolean, default is false
--  
--  Action = function(action, unit, eClick) 	
--    unit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_STEALTH_OPERATION"].ID, false)  
--    unit:SetMoves(0)
--   	print ("Stealth Off!")	
--  end
-- };
--
-- LuaEvents.UnitPanelActionAddin(UnitStealthOffButton);

----------Emergency Heal

EmergencyHealButton = {
    Name = "Emergency Heal",
    Title = "TXT_KEY_SP_BTNNOTE_UNIT_EMERGENCY_HEAL_SHORT", -- or a TXT_KEY
    OrderPriority = 200, -- default is 200
    IconAtlas = "UNIT_ACTION_ATLAS", -- 45 and 64 variations required
    PortraitIndex = 10,
    ToolTip = "TXT_KEY_SP_BTNNOTE_UNIT_EMERGENCY_HEAL", -- or a TXT_KEY_ or a function

    Condition = function(action, unit)
        return unit:CanMove() and unit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_SP_FORCE_X_3"].ID);
    end, -- or nil or a boolean, default is true

    Disabled = function(action, unit)
        local plot = unit:GetPlot()
        local unitCount = plot:GetNumUnits()
        local IsDisabled = true;
        for i = 0, unitCount - 1, 1 do
            local pFoundUnit = plot:GetUnit(i)
            if pFoundUnit:IsCombatUnit() and not pFoundUnit:CanMove() and Players[unit:GetOwner()] == Players[pFoundUnit:GetOwner()] and pFoundUnit:GetDomainType() == DomainTypes.DOMAIN_LAND then
                IsDisabled = false;
                break
            end
        end
        return IsDisabled
    end, -- or nil or a boolean, default is false

    Action = function(action, unit, eClick)
        local plot = unit:GetPlot()
        local unitCount = plot:GetNumUnits()
        for i = 0, unitCount - 1, 1 do
            local pFoundUnit = plot:GetUnit(i)
            if pFoundUnit:IsCombatUnit() and not pFoundUnit:CanMove() and Players[unit:GetOwner()] == Players[pFoundUnit:GetOwner()] and pFoundUnit:GetDomainType() == DomainTypes.DOMAIN_LAND then
                local AddMoves = math.floor(pFoundUnit:MaxMoves() / (3 * GameDefines["MOVE_DENOMINATOR"])) * GameDefines["MOVE_DENOMINATOR"]
                pFoundUnit:SetMoves(AddMoves)
                pFoundUnit:SetMadeAttack(true)
                unit:SetMoves(0)
            end
        end

        print("Emergency Heal! +1/3 MP")

    end
};

LuaEvents.UnitPanelActionAddin(EmergencyHealButton);

----------MilitiaResupply

MilitiaResupplyButton = {
    Name = "Milital Resupply",
    Title = "TXT_KEY_SP_BTNNOTE_UNIT_MILITIA_RESUPPLY_SHORT", -- or a TXT_KEY
    OrderPriority = 200, -- default is 200
    IconAtlas = "SP_UNIT_ACTION_ATLAS", -- 45 and 64 variations required
    PortraitIndex = 19,
    ToolTip = "TXT_KEY_SP_BTNNOTE_UNIT_MILITIA_RESUPPLY", -- or a TXT_KEY_ or a function

    Condition = function(action, unit)
        return unit:CanMove() and unit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MILITIA_COMBAT"].ID);
    end, -- or nil or a boolean, default is true

    Disabled = function(action, unit)
        local plot = unit:GetPlot()
        local unitCount = plot:GetNumUnits()
        for i = 0, unitCount - 1, 1 do
            local pFoundUnit = plot:GetUnit(i)
            if pFoundUnit == nil or pFoundUnit:GetID() == unit:GetID() or not pFoundUnit:IsCombatUnit() or pFoundUnit:GetCurrHitPoints() == pFoundUnit:GetMaxHitPoints() or not pFoundUnit:CanMove() then
                return true
            else
                return false
            end
        end
    end, -- or nil or a boolean, default is false

    Action = function(action, unit, eClick)
        local plot = unit:GetPlot()
        local unitCount = plot:GetNumUnits()
        for i = 0, unitCount - 1, 1 do
            local pFoundUnit = plot:GetUnit(i)
            if pFoundUnit ~= nil and pFoundUnit:IsCombatUnit() and pFoundUnit:GetCurrHitPoints() < pFoundUnit:GetMaxHitPoints() and pFoundUnit:GetDomainType() == unit:GetDomainType() and pFoundUnit:GetID() ~= unit:GetID() and pFoundUnit:CanMove() and Players[unit:GetOwner()] == Players[pFoundUnit:GetOwner()] then
                local iDamage = 50;
                if iDamage > pFoundUnit:GetDamage() then
                    iDamage = pFoundUnit:GetDamage();
                end
                pFoundUnit:ChangeDamage(-iDamage)
                pFoundUnit:SetMoves(0)
                unit:Kill();
                break
            end
        end

        print("Emergency Heal!")

    end
};

LuaEvents.UnitPanelActionAddin(MilitiaResupplyButton);

-----------------------------------------------------Rods from Gods-----------------------------------------------------------------------
GlobalStrikeButton = {
    Name = "Global Strike",
    Title = "TXT_KEY_SP_BTNNOTE_GLOBAL_STRIKE_SHORT", -- or a TXT_KEY
    OrderPriority = 200, -- default is 200
    IconAtlas = "SP_UNIT_ACTION_ATLAS", -- 45 and 64 variations required
    PortraitIndex = 10,
    ToolTip = "TXT_KEY_SP_BTNNOTE_GLOBAL_STRIKE", -- or a TXT_KEY_ or a function
    Condition = function(action, unit)
        return unit:CanMove() and unit:GetUnitType() == GameInfoTypes.UNIT_ORBITAL_STRIKE;
    end, -- or nil or a boolean, default is true

    --  Disabled = function(action, unit) 
    --    
    --    return 
    --  end, -- or nil or a boolean, default is false

    Action = function(action, unit, eClick)

        unit:SetMoves(0)

        for playerID, player in pairs(Players) do
            if player and player:IsAlive() and player:GetNumCities() >= 1 then
                if not player:IsHuman() then
                    if PlayerAtWarWithHuman(player) then
                        for city in player:Cities() do
                            local CityMaxHP = city:GetMaxHitPoints()
                            city:SetDamage(CityMaxHP)
                            print("Global Strike!")
                        end
                    end
                end
            end
        end

    end

};
LuaEvents.UnitPanelActionAddin(GlobalStrikeButton);

-----------------------------------------------------Hacker-----------------------------------------------------------------------

HackingMissionButton = {
    Name = "Hacking Mission",
    Title = "TXT_KEY_SP_BTNNOTE_HACKING_MISSION_SHORT", -- or a TXT_KEY
    OrderPriority = 200, -- default is 200
    IconAtlas = "SP_UNIT_ACTION_ATLAS", -- 45 and 64 variations required
    PortraitIndex = 30,
    ToolTip = "TXT_KEY_SP_BTNNOTE_HACKING_MISSION", -- or a TXT_KEY_ or a function
    Condition = function(action, unit)
        return unit:CanMove() and unit:GetUnitType() == GameInfoTypes.UNIT_HACKER;
    end, -- or nil or a boolean, default is true

    Disabled = function(action, unit)
        local plotOwner = Players[unit:GetPlot():GetOwner()]
        if plotOwner == nil or not plotOwner:IsAtWar(unit:GetOwner())  then
            return true
        end

    end, -- or nil or a boolean, default is false

    Action = function(action, unit, eClick)
        local plotOwner = Players[unit:GetPlot():GetOwner()]

        plotOwner:SetAnarchyNumTurns(2)
        print("Hacking success!")
        unit:Kill()
    end
};

LuaEvents.UnitPanelActionAddin(HackingMissionButton);

-----------------------------------------------------Great People-----------------------------------------------------------------------

local CorpsID = GameInfo.UnitPromotions["PROMOTION_CORPS_1"].ID
local ArmeeID = GameInfo.UnitPromotions["PROMOTION_CORPS_2"].ID
local iArsenal = GameInfoTypes["BUILDINGCLASS_ARSENAL"]
local iMilitaryBase = GameInfoTypes["BUILDINGCLASS_MILITARY_BASE"]
function bUnitCanEstablishCorps(unit)
    if unit:IsHasPromotion(ArmeeID)
    --only land unit can establish corps SP8.0
    or unit:GetDomainType() ~= DomainTypes.DOMAIN_LAND
    --CitadelUnits can't establish
    or unit:IsEmbarked() or unit:IsImmobile() or not unit:CanMove()
    or (unit:GetDomainType() == DomainTypes.DOMAIN_LAND and unit:GetPlot():IsWater())
    or (unit:GetDomainType() == DomainTypes.DOMAIN_SEA and not unit:GetPlot():IsWater())
    then
        return false
    end
    return true
end
local tUnit = nil;
local nUnit = nil;
-- Establish Corps & Armee
EstablishCorpsButton = {
    Name = "Establish Corps & Armee",
    Title = "TXT_KEY_SP_BTNNOTE_UNIT_ESTABLISH_CORPS_SHORT", -- or a TXT_KEY
    OrderPriority = 200, -- default is 200
    IconAtlas = "SP_UNIT_ACTION_ATLAS", -- 45 and 64 variations required
    PortraitIndex = 1,
    ToolTip = "TXT_KEY_SP_BTNNOTE_UNIT_ESTABLISH_CORPS", -- or a TXT_KEY_ or a function
    Condition = function(action, unit)
        local playerID = unit:GetOwner();
        local player = Players[playerID];
        local plot = unit:GetPlot();
		local city = plot:GetPlotCity() or plot:GetWorkingCity();

		if player:GetDomainTroopsActive() <= 0
        or plot:GetNumUnits() ~= 2
		or city == nil or city:GetOwner() ~= playerID
		or not bUnitCanEstablishCorps(unit)
		then
			return false
		end

		tUnit = nil;
		nUnit = nil;

		if unit:GetUnitClassType() == GameInfo.UnitClasses.UNITCLASS_GREAT_GENERAL.ID 
		or unit:GetUnitClassType() == GameInfo.UnitClasses.UNITCLASS_GREAT_ADMIRAL.ID 
		then
			nUnit = unit;
		elseif unit:IsCombatUnit() then
            if player:GetBuildingClassCount(iArsenal) <= 0 then
                return false
            end
			tUnit = unit;
		else
            --Other civilians don't need it
			return false
		end
		
		for i = 0, plot:GetNumUnits() - 1, 1 do
			local iUnit = plot:GetUnit(i)
            if iUnit ~= unit then
                --the other Unit must be a Combat Unit
                if not iUnit:IsCombatUnit() then
                    return false
                end
                --unit is Great Person
                if tUnit == nil then
                    if not bUnitCanEstablishCorps(iUnit) then
                        return false
                    end
                    tUnit = iUnit
                    break
                else
                    --not allow other unit is crops: we only want to keep tUnit and kill nUnit 
                    if iUnit:IsHasPromotion(CorpsID)
                    --only for same Type
                    or iUnit:GetUnitType() ~= unit:GetUnitType()
                    then
                        return false
                    end
                    nUnit = iUnit
                    break
                end
            end
		end

		if tUnit and nUnit and tUnit ~= nUnit 
		then
			if tUnit:IsHasPromotion(CorpsID) then
				if unit:GetDomainType() == DomainTypes.DOMAIN_LAND then
					EstablishCorpsButton.Title = "TXT_KEY_SP_BTNNOTE_UNIT_ESTABLISH_ARMEE_SHORT"
					EstablishCorpsButton.ToolTip = Locale.ConvertTextKey("TXT_KEY_SP_BTNNOTE_UNIT_ESTABLISH_ARMEE")
				else
					EstablishCorpsButton.Title = "TXT_KEY_SP_BTNNOTE_UNIT_ESTABLISH_ARMADA_SHORT"
					EstablishCorpsButton.ToolTip = Locale.ConvertTextKey("TXT_KEY_SP_BTNNOTE_UNIT_ESTABLISH_ARMADA")
				end
                local AvailableArmeeNum = player:GetNumArmeeTotal() - player:GetNumArmeeUsed();
                EstablishCorpsButton.ToolTip = EstablishCorpsButton.ToolTip .. Locale.ConvertTextKey("TXT_KEY_SP_BTNNOTE_UNIT_ESTABLISH_ARMEE_EXTRA", AvailableArmeeNum)
				EstablishCorpsButton.PortraitIndex = 3;
			else
				if unit:GetDomainType() == DomainTypes.DOMAIN_LAND then
					EstablishCorpsButton.Title = "TXT_KEY_SP_BTNNOTE_UNIT_ESTABLISH_CORPS_SHORT"
					EstablishCorpsButton.ToolTip = Locale.ConvertTextKey("TXT_KEY_SP_BTNNOTE_UNIT_ESTABLISH_CORPS")
				else
					EstablishCorpsButton.Title = "TXT_KEY_SP_BTNNOTE_UNIT_ESTABLISH_FLEET_SHORT"
					EstablishCorpsButton.ToolTip = Locale.ConvertTextKey("TXT_KEY_SP_BTNNOTE_UNIT_ESTABLISH_FLEET")
				end
                local AvailableCropsNum = player:GetNumCropsTotal() - player:GetNumCropsUsed();
				EstablishCorpsButton.ToolTip = EstablishCorpsButton.ToolTip .. Locale.ConvertTextKey("TXT_KEY_SP_BTNNOTE_UNIT_ESTABLISH_CORPS_EXTRA", AvailableCropsNum);
				EstablishCorpsButton.PortraitIndex = 1;
			end
		end
        return true
    end, -- or nil or a boolean, default is true

    Disabled = function(action, unit)
		local plot = unit:GetPlot()
		local city = plot:GetPlotCity() or plot:GetWorkingCity()
		local playerID = unit:GetOwner()
        local player = Players[playerID]

		if unit:GetUnitClassType() == GameInfo.UnitClasses.UNITCLASS_GREAT_GENERAL.ID 
		or unit:GetUnitClassType() == GameInfo.UnitClasses.UNITCLASS_GREAT_ADMIRAL.ID 
		then
			for i = 0, plot:GetNumUnits() - 1, 1 do
				local iUnit = plot:GetUnit(i)
				if iUnit:IsCombatUnit()
				and not iUnit:IsHasPromotion(ArmeeID) 
				then
					if iUnit:IsHasPromotion(CorpsID) and not city:IsHasBuildingClass(iArsenal) then
                        --Use a Great Prople to Upgrade a Unit need Arsenal in this City
						EstablishCorpsButton.ToolTip = EstablishCorpsButton.ToolTip .. Locale.ConvertTextKey("TXT_KEY_SP_BTNNOTE_UNIT_ESTABLISH_CORPS_OR_ARMEE_TIP_1")
						return true
					end
				end
			end
		elseif unit:IsCombatUnit() then
			if not unit:IsHasPromotion(CorpsID) then
				if not city:IsHasBuildingClass(iArsenal) then
                    --Combine two same type of Units in this tile into Corps need Arsenal in this City
					EstablishCorpsButton.ToolTip = EstablishCorpsButton.ToolTip .. Locale.ConvertTextKey("TXT_KEY_SP_BTNNOTE_UNIT_ESTABLISH_CORPS_OR_ARMEE_TIP_2")
					return true
				elseif not player:IsCanEstablishCrops() then
                    --Corps reached limit
					return true
				end
			else
				if not city:IsHasBuildingClass(iMilitaryBase) then
                    --Add a same type Unit in this tile into Corps to become an Armee need MilitaryBase in this City
					EstablishCorpsButton.ToolTip = EstablishCorpsButton.ToolTip .. Locale.ConvertTextKey("TXT_KEY_SP_BTNNOTE_UNIT_ESTABLISH_CORPS_OR_ARMEE_TIP_3")
					return true
				elseif not player:IsCanEstablishArmee() then
                    --Armee reached limit
					return true
				end
			end
		end
        if tUnit:IsPromotionReady() or nUnit:IsPromotionReady() then
            EstablishCorpsButton.ToolTip = EstablishCorpsButton.ToolTip .. Locale.ConvertTextKey("TXT_KEY_SP_BTNNOTE_UNIT_ESTABLISH_CORPS_OR_ARMEE_TIP_4")
            return true
        end

		return false
    end, -- or nil or a boolean, default is false

    Action = function(action, unit, eClick)
        local playerID = unit:GetOwner();
        local player = Players[playerID];
        local plot = unit:GetPlot();
        if plot and plot:GetNumUnits() > 1 and not unit:IsEmbarked() and not unit:IsImmobile() 
		and not unit:IsHasPromotion(GameInfoTypes["PROMOTION_CORPS_2"]) 
		and tUnit ~= nil and nUnit ~= nil and tUnit ~= nUnit
		and tUnit:GetPlot() == nUnit:GetPlot() 
		then
            if tUnit:GetUnitType() == nUnit:GetUnitType() then
                local iLevel = math.max(tUnit:GetLevel(), nUnit:GetLevel());
                local iExperience = math.max(tUnit:GetExperience(), nUnit:GetExperience());
                tUnit:SetLevel(iLevel);
                tUnit:SetExperience(iExperience);
                for unitPromotion in GameInfo.UnitPromotions() do
                    if nUnit:IsHasPromotion(unitPromotion.ID) and not tUnit:IsHasPromotion(unitPromotion.ID) then
                        tUnit:SetHasPromotion(unitPromotion.ID, true);
                    end
                end
				--new for SP9.3, merge some attributes of unit
                local HPFromRazedCityPopLimit = player:GetTraitUnitMaxHitPointChangePerRazedCityPopLimit()
                local HPFromRazedCityPop = tUnit:GetMaxHitPointsChangeFromRazedCityPop()+nUnit:GetMaxHitPointsChangeFromRazedCityPop()
                if HPFromRazedCityPop > HPFromRazedCityPopLimit
                then
                    HPFromRazedCityPop = HPFromRazedCityPopLimit
                end
				tUnit:SetMaxHitPointsChangeFromRazedCityPop(HPFromRazedCityPop)
				tUnit:SetCombatStrengthChangeFromKilledUnits(tUnit:GetCombatStrengthChangeFromKilledUnits()+nUnit:GetCombatStrengthChangeFromKilledUnits())
				tUnit:SetRangedCombatStrengthChangeFromKilledUnits(tUnit:GetRangedCombatStrengthChangeFromKilledUnits()+nUnit:GetRangedCombatStrengthChangeFromKilledUnits())
				
            else
                nUnit = nil;
            end
            if tUnit:IsHasPromotion(GameInfoTypes["PROMOTION_CORPS_1"]) then
                tUnit:SetHasPromotion(GameInfoTypes["PROMOTION_CORPS_2"], true);
            else
                tUnit:SetHasPromotion(GameInfoTypes["PROMOTION_CORPS_1"], true);
            end
            tUnit:SetMoves(0);
            if nUnit then
                nUnit:Kill();
            end
            --kill Great People
            if tUnit ~= unit and nUnit ~= unit then
                unit:Kill();
            end
        end
    end
};
LuaEvents.UnitPanelActionAddin(EstablishCorpsButton);

----------remove Debuff
MoralBoostButton = {
    Name = "Moral Boost",
    Title = "TXT_KEY_SP_BTNNOTE_UNIT_MORAL_BOOST_SHORT", -- or a TXT_KEY
    OrderPriority = 200, -- default is 200
    IconAtlas = "SP_UNIT_ACTION_ATLAS", -- 45 and 64 variations required
    PortraitIndex = 22,
    ToolTip = "TXT_KEY_SP_BTNNOTE_UNIT_MORAL_BOOST", -- or a TXT_KEY_ or a function

    Condition = function(action, unit)
        return unit:CanMove() and (unit:GetUnitClassType() == GameInfo.UnitClasses.UNITCLASS_GREAT_GENERAL.ID or unit:GetUnitClassType() == GameInfo.UnitClasses.UNITCLASS_GREAT_ADMIRAL.ID or unit:GetUnitType() == GameInfoTypes["UNIT_POLISH_PZLW3_HELICOPTER"] or unit:GetUnitType() == GameInfoTypes["UNIT_HUN_SHAMAN"]);
    end, -- or nil or a boolean, default is true

    Disabled = function(action, unit)
        return unit:GetPlot() == nil or unit:GetPlot():GetNumUnits() <= 1;
    end, -- or nil or a boolean, default is false

    Action = function(action, unit, eClick)
        if unit:GetPlot() == nil or unit:GetPlot():GetNumUnits() <= 1 then
            return;
        end
        unit:ClearSamePlotPromotions()
        print("Moral Boost!")
        unit:SetMoves(0)
    end
};
LuaEvents.UnitPanelActionAddin(MoralBoostButton);

----Build the JAPANESE DOJO in the city
BuildDOJOButton = {
    Name = "Build JAPANESE DOJO",
    Title = "TXT_KEY_SP_BTNNOTE_BUILDING_JAPANESE_DOJO_SHORT", -- or a TXT_KEY
    OrderPriority = 1500, -- default is 200
    IconAtlas = "SP_UNIT_ACTION_ATLAS", -- 45 and 64 variations required
    PortraitIndex = 13,
    ToolTip = "TXT_KEY_SP_BTNNOTE_BUILDING_JAPANESE_DOJO", -- or a TXT_KEY_ or a function
    Condition = function(action, unit)
        return unit:CanMove() and unit:GetUnitType() == GameInfoTypes.UNIT_JAPANESE_SAMURAI;
    end, -- or nil or a boolean, default is true

    Disabled = function(action, unit)
        local plot = unit:GetPlot();
        if not plot:IsCity() then
            return true
        end
        local city = plot:GetPlotCity()
        return not city or city:GetOwner() ~= unit:GetOwner() or city:IsHasBuilding(GameInfo.Buildings["BUILDING_JAPANESE_DOJO"].ID);
    end, -- or nil or a boolean, default is false

    Action = function(action, unit, eClick)
        local plot = unit:GetPlot();
        local city = plot:GetPlotCity()
        local player = Players[unit:GetOwner()]
        if not city then
            return
        end

        city:SetNumRealBuilding(GameInfoTypes["BUILDING_JAPANESE_DOJO"], 1)
        unit:Kill();
    end
};
LuaEvents.UnitPanelActionAddin(BuildDOJOButton);

----Build the Military Academy in the city
BuildMilitaryAcademyButton = {
    Name = "Build Military Academy",
    Title = "TXT_KEY_SP_BTNNOTE_BUILDING_MILITARY_ACADEMY_SHORT", -- or a TXT_KEY
    OrderPriority = 1500, -- default is 200
    IconAtlas = "SP_UNIT_ACTION_ATLAS", -- 45 and 64 variations required
    PortraitIndex = 13,
    ToolTip = "TXT_KEY_SP_BTNNOTE_BUILDING_MILITARY_ACADEMY", -- or a TXT_KEY_ or a function
    Condition = function(action, unit)
        return unit:CanMove() and (unit:GetUnitClassType() == GameInfoTypes.UNITCLASS_GREAT_GENERAL or unit:GetUnitClassType() == GameInfoTypes.UNITCLASS_GREAT_ADMIRAL);
    end, -- or nil or a boolean, default is true

    Disabled = function(action, unit)
        local plot = unit:GetPlot();
        if not plot:IsCity() then
            return true
        end
        local city = plot:GetPlotCity()
        return not city or city:GetOwner() ~= unit:GetOwner() or city:IsHasBuilding(GameInfo.Buildings["BUILDING_MILITARY_ACADEMY"].ID);
    end, -- or nil or a boolean, default is false

    Action = function(action, unit, eClick)
        local plot = unit:GetPlot();
        local city = plot:GetPlotCity()
        local player = Players[unit:GetOwner()]
        if not city then
            return
        end

        city:SetNumRealBuilding(GameInfoTypes["BUILDING_MILITARY_ACADEMY"], 1)
        if GameInfo.Leader_Traits {LeaderType = GameInfo.Leaders[player:GetLeaderType()].Type, TraitType = "TRAIT_TERROR"}() 
		and (GameInfo.Traits["TRAIT_TERROR"].PrereqPolicy == nil or (GameInfo.Traits["TRAIT_TERROR"].PrereqPolicy and player:HasPolicy(GameInfoTypes[GameInfo.Traits["TRAIT_TERROR"].PrereqPolicy]))) 
		or (player:HasPolicy(GameInfo.Policies["POLICY_EXPLORATION_FINISHER"].ID) 
		and unit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GREAT_ADMIRAL"].ID)) 
		then
            print("Mongolian Khan cannot be consumed!")
            return
        else
            unit:Kill()
        end
    end
};
LuaEvents.UnitPanelActionAddin(BuildMilitaryAcademyButton);

-- Religious Unit Establish Inquisition
EstablishInquisition = {
    Name = "EstablishInquisition",
    Title = "TXT_KEY_BUILD_INQUISITION", -- or a TXT_KEY
    OrderPriority = 300, -- default is 200
    IconAtlas = "SP_BUILDING_ATLAS_DLC_07", -- 45 and 64 variations required
    PortraitIndex = 5,
    ToolTip = "TXT_KEY_BUILDING_INQUISITION_HELP", -- or a TXT_KEY_ or a function
    Condition = function(action, unit)
        local bIsCondition = false;
        if (
			(unit:GetSpreadsLeft() > 0 and unit:GetSpreadsLeft() >= GameInfo.Units[unit:GetUnitType()].ReligionSpreads) 
			or GameInfo.Units[unit:GetUnitType()].ProhibitsSpread) and unit:GetPlot() and unit:GetOwner() == unit:GetPlot():GetOwner() 
			and (unit:GetPlot():IsCity() or unit:GetPlot():GetWorkingCity() ~= nil) 
		then
            local player = Players[unit:GetOwner()];
            local city = unit:GetPlot():GetPlotCity() or unit:GetPlot():GetWorkingCity();
            if city and city:GetReligiousMajority() == unit:GetReligion() 
			and city:IsCanPurchase(false, false, -1, GameInfoTypes["BUILDING_INQUISITION"], -1, YieldTypes.YIELD_FAITH) then
                bIsCondition = true;
            end
        end
        return bIsCondition and unit:CanMove();
    end, -- or nil or a boolean, default is true
    Disabled = function(action, unit)
        local bIsDisabled = true;
        local numReligion = 0;
        local city = unit:GetPlot():GetPlotCity() or unit:GetPlot():GetWorkingCity();
        for religion in GameInfo.Religions("Type <> 'RELIGION_PANTHEON'") do
            if city == nil then
                break
            elseif city:GetNumFollowers(religion.ID) > 0 then
                numReligion = numReligion + 1;
            end
            if numReligion > 1 then
                bIsDisabled = false;
                break
            end
        end
        return bIsDisabled;
    end, -- or nil or a boolean, default is false

    Action = function(action, unit, eClick)
        local city = unit:GetPlot():GetPlotCity() or unit:GetPlot():GetWorkingCity();
        if city then
            city:SetNumRealBuilding(GameInfoTypes["BUILDING_INQUISITION"], 1);
            unit:Kill();
        end
    end
};
LuaEvents.UnitPanelActionAddin(EstablishInquisition);

----Satellite Launching
SatelliteLaunchingButton = {
    Name = "Satellite Launching",
    Title = "TXT_KEY_SP_BTNNOTE_SATELLITE_LAUNCHING_SHORT", -- or a TXT_KEY
    OrderPriority = 9999, -- default is 200
    IconAtlas = "UNIT_ACTION_ATLAS", -- 45 and 64 variations required
    PortraitIndex = 49,
    ToolTip = "TXT_KEY_SP_BTNNOTE_SATELLITE_LAUNCHING", -- or a TXT_KEY_ or a function
    Condition = function(action, unit)
        return unit:CanMove() and unit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_SATELLITE_UNIT"].ID);
    end, -- or nil or a boolean, default is true

    Disabled = function(action, unit)
        local plot = unit:GetPlot();
        if not plot:IsCity() then
            return true
        end
        local city = plot:GetPlotCity()
        return not city or city:GetOwner() ~= unit:GetOwner() or not city:IsCapital();
    end, -- or nil or a boolean, default is false

    Action = function(action, unit, eClick)
        local plot = unit:GetPlot();
        if not plot then
            return
        end

        local city = plot:GetPlotCity()
        local player = Players[unit:GetOwner()]

        SatelliteLaunchEffects(unit, city, player);
        unit:Kill();

        print("Satellite Launched!")

    end
};
LuaEvents.UnitPanelActionAddin(SatelliteLaunchingButton);

---------MOD Begin By HMS------
-----------------LuckyE Bonus
LuckyEButton = {
    Name = "Lucky E Bonus",
    Title = "TXT_KEY_LUCKYE_SHORT", -- or a TXT_KEY
    OrderPriority = 200, -- default is 200
    IconAtlas = "SP_UNIT_ACTION_ATLAS", -- 45 and 64 variations required
    PortraitIndex = 20,
    ToolTip = "TXT_KEY_LUCKYE", -- or a TXT_KEY_ or a function

    Condition = function(action, unit)
        return unit:CanMove() and unit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_LUCKY_CARRIER"].ID) and not unit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_NO_LUCK"].ID)
    end, -- or nil or a boolean, default is true

    Disabled = function(action, unit)
        return unit:GetMoves() < 2 * GameDefines["MOVE_DENOMINATOR"]
    end, -- or nil or a boolean, default is false

    Action = function(action, unit, eClick)

        local plot = unit:GetPlot()
        local unitCount = plot:GetNumUnits()
        for i = 0, unitCount - 1, 1 do
            local pFoundUnit = plot:GetUnit(i)
            -- local LuckyERoll = math.random(1, 100)
            local LuckyERoll = Game.Rand(100, "At UnitSpecialButtons.lua LuckyEButton") + 1
            print("LuckyERoll:" .. LuckyERoll)
            if LuckyERoll >= 70 and pFoundUnit:GetDomainType() == DomainTypes.DOMAIN_AIR 
			and Players[unit:GetOwner()] == Players[pFoundUnit:GetOwner()] then
                pFoundUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_LUCKYE"].ID, true)
                print("LuckyE Set for air units in the same tile!")
            end
        end
        unit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_NO_LUCK"].ID, true)
        unit:SetMoves(unit:GetMoves() - 2 * GameDefines["MOVE_DENOMINATOR"])

    end
};
LuaEvents.UnitPanelActionAddin(LuckyEButton);
--------------------------------------------------------------------------------------Utilities-----------------------------------------------------------------
-----------------Tokyo Raid
TokyoRaidButton = {
    Name = "Tokyo Raid Button",
    Title = "TXT_KEY_TOKYO_RAID_SHORT", -- or a TXT_KEY
    OrderPriority = 300, -- default is 200
    IconAtlas = "SP_UNIT_ACTION_ATLAS", -- 45 and 64 variations required
    PortraitIndex = 22,
    ToolTip = "TXT_KEY_TOKYO_RAID", -- or a TXT_KEY_ or a function

    Condition = function(action, unit)
        return unit:CanMove() and unit:GetUnitType() == GameInfoTypes["UNIT_ENTERPRISE"]
    end, -- or nil or a boolean, default is true

    Disabled = function(action, unit)
        return false;
    end, -- or nil or a boolean, default is false

    Action = function(action, unit, eClick)
        -- unit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_CARRIER_UNIT"].ID,false)
        local unitType = GameInfoTypes["UNIT_HORNET"]
        local unitEXP = unit:GetExperience()
        local unitAIType = unit:GetUnitAIType()
        local unitX = unit:GetX()
        local unitY = unit:GetY()
        local unitDamage = unit:GetDamage()
        local unitMoves = unit:GetMoves()
        local pPlayer = Players[unit:GetOwner()]
        print("unitType ready")
        local NewUnit = pPlayer:InitUnit(unitType, unitX, unitY, unitAIType)
        NewUnit:SetLevel(unit:GetLevel())
        NewUnit:SetExperience(unitEXP)
        for unitPromotion in GameInfo.UnitPromotions() do
            local unitPromotionID = unitPromotion.ID
            if unit:IsHasPromotion(unitPromotionID) and not unitPromotion.LostWithUpgrade then
                NewUnit:SetHasPromotion(unitPromotionID, true)
            end
        end
        -- NewUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_CARRIER_UNIT"].ID, false)
        NewUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_NO_LUCK"].ID, true)
        NewUnit:SetDamage(unitDamage)
        NewUnit:SetMoves(unitMoves)
        unit:Kill()
    end
};
LuaEvents.UnitPanelActionAddin(TokyoRaidButton);

TokyoRaidCancelButton = {
    Name = "Tokyo Raid Cancel Button",
    Title = "TXT_KEY_TOKYO_RAID_CANCEL_SHORT", -- or a TXT_KEY
    OrderPriority = 300, -- default is 200
    IconAtlas = "SP_UNIT_ACTION_ATLAS", -- 45 and 64 variations required
    PortraitIndex = 13,
    ToolTip = "TXT_KEY_TOKYO_RAID_CANCEL", -- or a TXT_KEY_ or a function

    Condition = function(action, unit)
        return unit:CanMove() and unit:GetUnitType() == GameInfoTypes["UNIT_HORNET"]
    end, -- or nil or a boolean, default is true

    Disabled = function(action, unit)
        return false;
    end, -- or nil or a boolean, default is false

    Action = function(action, unit, eClick)
        -- unit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_CARRIER_UNIT"].ID,true)
        local unitType = GameInfoTypes["UNIT_ENTERPRISE"]
        local unitEXP = unit:GetExperience()
        local unitAIType = unit:GetUnitAIType()
        local unitX = unit:GetX()
        local unitY = unit:GetY()
        local unitDamage = unit:GetDamage()
        local unitMoves = unit:GetMoves()
        local pPlayer = Players[unit:GetOwner()]
        print("unitType ready")

        local NewUnit = pPlayer:InitUnit(unitType, unitX, unitY, unitAIType)
        NewUnit:SetLevel(unit:GetLevel())
        NewUnit:SetExperience(unitEXP)
        for unitPromotion in GameInfo.UnitPromotions() do
            local unitPromotionID = unitPromotion.ID
            if unit:IsHasPromotion(unitPromotionID) and not unitPromotion.LostWithUpgrade then
                NewUnit:SetHasPromotion(unitPromotionID, true)
            end
        end
        NewUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_NO_LUCK"].ID, true)
        NewUnit:SetDamage(unitDamage)
        NewUnit:SetMoves(unitMoves)
        unit:Kill()
    end
};
LuaEvents.UnitPanelActionAddin(TokyoRaidCancelButton);

CarrierRestoreButton = {
    Name = "Carrier Restore Button",
    Title = "TXT_KEY_BUILD_CARRIER_FIGHTER", -- or a TXT_KEY
    OrderPriority = 200, -- default is 200
    IconAtlas = "SP_UNIT_ACTION_ATLAS", -- 45 and 64 variations required
    PortraitIndex = 46,
    ToolTip = "TXT_KEY_BUILD_CARRIER_FIGHTER_HELP", -- or a TXT_KEY_ or a function

    Condition = function(action, unit)
        local PlayerID = unit:GetOwner();
        if GameInfo.Units[unit:GetUnitType()].SpecialCargo == "SPECIALUNIT_FIGHTER" and g_CargoSetList[PlayerID] == nil then
            SPCargoListSetup(PlayerID);
        end
        return 
            unit:CanMove() 
            and GameInfo.Units[unit:GetUnitType()].SpecialCargo == "SPECIALUNIT_FIGHTER" 
            and not unit:IsFull() and g_CargoSetList[PlayerID] and g_CargoSetList[PlayerID][1] ~= -1
    end, -- or nil or a boolean, default is true

    Disabled = function(action, unit)
        return 
            unit:GetOwner() < 0 
            or unit:GetPlot() == nil or unit:GetPlot():IsCity() 
            or (not unit:GetPlot():IsFriendlyTerritory(unit:GetOwner()) 
            and not unit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_CARRIER_SUPPLY_3"].ID)) 
            or g_CargoSetList[unit:GetOwner()] == nil 
            or g_CargoSetList[unit:GetOwner()][3] < 0 
            or g_CargoSetList[unit:GetOwner()][3] > Players[unit:GetOwner()]:GetGold() 
            or not Players[unit:GetOwner()]:IsCanPurchaseAnyCity(false, true, g_CargoSetList[unit:GetOwner()][4], -1, YieldTypes.YIELD_GOLD)
    end, -- or nil or a boolean, default is false

    Action = function(action, unit, eClick)
        local PlayerID = unit:GetOwner();
        if unit == nil or PlayerID == nil then
            print("No unit or player to restore aircrafts")
            return
        end

        local iCost = CarrierRestore(PlayerID, unit:GetID(), g_CargoSetList[PlayerID][1]);
        if iCost and iCost > 0 then
            Players[PlayerID]:ChangeGold(-iCost);
        end
    end
};
LuaEvents.UnitPanelActionAddin(CarrierRestoreButton);
---------MOD End By HMS

-- Explorer Upgrade to Archaeologist
UpgradetoArchaeologist = {
    Name = "Upgrade to Archaeologist",
    Title = "TXT_KEY_COMMAND_UPGRADE", -- or a TXT_KEY
    OrderPriority = 200, -- default is 200
    IconAtlas = "EXPANSION2_UNIT_ATLAS", -- 45 and 64 variations required
    PortraitIndex = 0,
    ToolTip = Locale.ConvertTextKey("TXT_KEY_UPGRADE_HELP", GameInfo.Units["UNIT_ARCHAEOLOGIST"].Description, 80), -- or a TXT_KEY_ or a function
    Condition = function(action, unit)
        return unit:CanMove() and unit:GetUnitClassType() == GameInfoTypes["UNITCLASS_EXPLORERX"] and Teams[Players[unit:GetOwner()]:GetTeam()]:IsHasTech(GameInfoTypes["TECH_ARCHAEOLOGY"]);
    end, -- or nil or a boolean, default is true
    Disabled = function(action, unit)
        return unit:GetPlot():GetOwner() ~= unit:GetOwner() or Players[unit:GetOwner()]:GetUnitClassCount(GameInfoTypes.UNITCLASS_ARCHAEOLOGIST) >= GameInfo.UnitClasses["UNITCLASS_ARCHAEOLOGIST"].MaxPlayerInstances or Players[unit:GetOwner()]:GetGold() < 80;
    end, -- or nil or a boolean, default is false

    Action = function(action, unit, eClick)
        local iX, iY = unit:GetX(), unit:GetY();
        unit:Kill();
        Players[unit:GetOwner()]:InitUnit(GameInfoTypes.UNIT_ARCHAEOLOGIST, iX, iY):SetMoves(0);
        Players[unit:GetOwner()]:ChangeGold(-80);
    end
};
LuaEvents.UnitPanelActionAddin(UpgradetoArchaeologist);

----Worker can remove sheep on the hills
RemoveSheepOntheHills = {
    Name = "Remove Sheep on the Hills",
    Title = "TXT_KEY_SP_BTNNOTE_REMOVE_SHEEP_ON_THE_HILLS_SHORT", -- or a TXT_KEY
    OrderPriority = 300, -- default is 200
    IconAtlas = "SP_UNIT_ACTION_ATLAS", -- 45 and 64 variations required
    PortraitIndex = 50,
    ToolTip = "TXT_KEY_SP_BTNNOTE_REMOVE_SHEEP_ON_THE_HILLS", -- or a TXT_KEY_ or a function
    Condition = function(action, unit)
        local player = Players[unit:GetOwner()];
        local plot = unit:GetPlot();
        local bIsCondition = false;
        if unit:GetUnitClassType() == GameInfoTypes.UNITCLASS_WORKER 
		and plot:IsHills() and not plot:IsCity() and plot:GetResourceType(-1) == GameInfoTypes.RESOURCE_SHEEP 
		and GameInfo.Leader_Traits {LeaderType = GameInfo.Leaders[player:GetLeaderType()].Type, TraitType = "TRAIT_GREAT_ANDEAN_ROAD"}() 
		and (GameInfo.Traits["TRAIT_GREAT_ANDEAN_ROAD"].PrereqPolicy == nil or (GameInfo.Traits["TRAIT_GREAT_ANDEAN_ROAD"].PrereqPolicy and player:HasPolicy(GameInfoTypes[GameInfo.Traits["TRAIT_GREAT_ANDEAN_ROAD"].PrereqPolicy]))) then
            bIsCondition = true;
        end
        return bIsCondition and unit:CanMove();
    end, -- or nil or a boolean, default is true
    Disabled = function(action, unit)
        return unit:GetPlot():GetOwner() ~= unit:GetOwner();
    end, -- or nil or a boolean, default is false

    Build = function(action, unit, eClick)
        unit:GetPlot():SetResourceType(-1);
        unit:SetMoves(0);
    end
};
LuaEvents.UnitPanelBuildAddin(RemoveSheepOntheHills);

-- Automation T
AutomationTButton = {
    Name = "Automation T",
    Title = "TXT_KEY_TECH_AUTOMATION_T_TITLE", -- or a TXT_KEY
    IconAtlas = "UNIT_ACTION_GOLD_ATLAS", -- 45 and 64 variations required
    PortraitIndex = 36,
    ToolTip = "TXT_KEY_SP_NOTIFICATION_AUTOMATION_ACTIVE", -- or a TXT_KEY_ or a function
    Condition = function(build, unit)
        return unit:CanMove() and unit:WorkRate() > 0 and Teams[Players[unit:GetOwner()]:GetTeam()]:IsHasTech(GameInfoTypes["TECH_AUTOMATION_T"]);
    end, -- or nil or a boolean, default is true
    Disabled = function(build, unit)
        return false;
    end, -- or nil or a boolean, default is false
    Build = function(build, unit, eClick)
        ImproveTiles(true); -- bIsHuman
        Events.GameplayAlertMessage(Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_AUTOMATION_ACTIVE"));
    end,
    Recommended = function(build, unit, eClick)
    end
};
LuaEvents.UnitPanelBuildAddin(AutomationTButton);

print("UnitSpecialButtons Check Success!")