print("This is the 'UI - Super Unit Manager' replacment for UnitFlagManager.lua")
-------------------------------------------------
-- UnitFlagManager      - MOD by CaptainCWB
-------------------------------------------------
include("IconSupport");
include("SupportFunctions");
include("InstanceManager");
local g_MilitaryManager = InstanceManager:new("NewUnitFlag", "Anchor", Controls.MilitaryFlags);
local g_ReconUniManager = InstanceManager:new("NewUnitFlag", "Anchor", Controls.ReconUniFlags); -- SP Recon Units
local g_CivilianManager = InstanceManager:new("NewUnitFlag", "Anchor", Controls.CivilianFlags);
local g_AirCraftManager = InstanceManager:new("NewUnitFlag", "Anchor", Controls.AirCraftFlags);

local g_MasterList = {};
local g_LastPlayerID;
local g_LastUnitID;
local g_ListPlot;
local g_PrintDebug = false;
local g_GarrisonedUnitFlagsInStrategicView = true;
local g_DeleteALLStrategicUnitFlag = GameInfo.SPNewEffectControler.SP_DELETE_ALL_STRATEGIC_UNIT_FLAG.Enabled

local g_UnitList = {};
ContextPtr:BuildInstanceForControl("UnitList", g_UnitList, Controls.CityContainer);
local g_GGPlot;
local g_GGType                = -1;
local g_IsDoingGG             = false;
local g_HasMove               = false;

local BlackFog                = 0; -- invisible
local GreyFog                 = 1; -- once seen
local WhiteFog                = 2; -- eyes on
local g_DimAlpha              = 0.45;
local g_DimAirAlpha           = 0.6;

local GarrisonOffset          = Vector2( -43, -39);
local GarrisonOtherOffset     = Vector2( -55, -34);
-- local CityNonGarrisonOffset = Vector2( 45, -45 );
-- local CityCivilianOffset = Vector2( 45, -65 );
-- local CityTradeOffset = Vector2( 80, -45 );

local g_CityFlags             = {};
local g_SelectedContainer     = ContextPtr:LookUpControl("../SelectedUnitContainer");
local g_SelectedFlag          = nil;
local CityWorldPositionOffset = { x = 0, y = 0, z = 35 };

local g_UnitFlagClass         =
{
    ------------------------------------------------------------------
    -- default values
    ------------------------------------------------------------------
    m_Instance              = {},
    m_FlagType              = 0,
    m_UnitType              = 0,
    m_IsSelected            = false,
    m_IsCurrentlyVisible    = true,
    m_IsInvisible           = false,
    m_IsGarrisoned          = false,
    m_IsDimmed              = false,
    m_IsForceHide           = false,
    m_OverrideDimedFlag     = false,
    m_HasCivilianSelectFlag = false,
    m_Health                = 1,
    m_Player                = nil,
    m_PlayerID              = -1,
    m_CivID                 = -1,
    m_UnitID                = -1,
    m_IsAirCraft            = false,
    m_IsTrade               = false,
    m_IsCivilian            = false,
    m_CarrierFlag           = nil,
    m_CargoCount            = 0,
    m_StackOrders           = { 0, 0, 0, 0 }, -- Unit Stack Orders { UnitCount, SameUnitCount, UnitOrder, HasCombat } - by CaptainCWB
    m_GroupControls         = nil, -- Unit Group Controls                                                  - by CaptainCWB
    m_IsInGroup             = false, -- Unit Group Flag                                                      - by CaptainCWB
    m_HasGroupAir           = false, -- Unit Group Mark                                                      - by CaptainCWB
    m_CombatType            = -1, -- Unit Combat Type                                                     - by CaptainCWB
    m_GGMPlot               = nil, -- Unit "7" Group Move                                                  - by CaptainCWB
    m_SPUnitType            = -1, -- 0 - Militia, 1 - Citadel -- SP Unit                                  - by CaptainCWB
    m_Escort                = nil, -- m_Plot = nil; - for Compatibility                                    - by CaptainCWB
    ------------------------------------------------------------------
    -- constructor
    ------------------------------------------------------------------
    new = function(self, playerID, unitID, fogState, invisible)
        local o = {};
        setmetatable(o, self);
        self.__index = self;
        o.m_Instance = {};

        if (playerID ~= -1)
        then
            local pUnit = Players[playerID]:GetUnitByID(unitID);

            if (pUnit:IsCombatUnit() and not pUnit:IsEmbarked()) then
                -- SP Recon Units- Begin
                if (pUnit:GetUnitCombatType() == GameInfoTypes.UNITCOMBAT_RECON) then
                    o.m_InstanceManager = g_ReconUniManager;
                else
                    o.m_InstanceManager = g_MilitaryManager;
                end
                -- SP6 ReconUnit - End
            else
                if (pUnit:GetDomainType() == DomainTypes.DOMAIN_AIR) then
                    o.m_InstanceManager = g_AirCraftManager;
                    o.m_IsAirCraft = true;
                else
                    o.m_InstanceManager = g_CivilianManager;
                end
            end

            o.m_Instance = o.m_InstanceManager:GetInstance();
            o:Initialize(playerID, unitID, fogState, invisible);

            ---------------------------------------------------------
            -- Set Unit Combat Type
            local CombatType = pUnit:GetUnitCombatType();
            if pUnit:GetDomainType() == DomainTypes.DOMAIN_LAND and pUnit:IsCombatUnit() and not pUnit:IsImmobile() then
                if (CombatType == GameInfoTypes.UNITCOMBAT_MELEE
                    or (CombatType == GameInfoTypes.UNITCOMBAT_GUN and GameInfo.Units[pUnit:GetUnitType()].Moves == 2 and not pUnit:IsRanged())
                    or (CombatType == GameInfoTypes.UNITCOMBAT_GUN and GameInfo.Units[pUnit:GetUnitType()].DefaultUnitAI == "UNITAI_DEFENSE")
                    or GameInfo.Units[pUnit:GetUnitType()].DefaultUnitAI == "UNITAI_COUNTER")
                    and GameInfo.Units[pUnit:GetUnitType()].DefaultUnitAI ~= "UNITAI_PARADROP"
                then
                    -- Melee Army
                    o.m_CombatType = 0;
                elseif GameInfo.Units[pUnit:GetUnitType()].Moves <= 4 and pUnit:IsRanged() and GameInfo.Units[pUnit:GetUnitType()].DefaultUnitAI ~= "UNITAI_CITY_BOMBARD" then
                    -- Range Army
                    o.m_CombatType = 1;
                elseif GameInfo.Units[pUnit:GetUnitType()].Moves >= 4 and not pUnit:IsRanged() then
                    -- Mobil Unit
                    o.m_CombatType = 2;
                elseif GameInfo.Units[pUnit:GetUnitType()].Moves >= 4 and pUnit:IsRanged() and GameInfo.Units[pUnit:GetUnitType()].DefaultUnitAI ~= "UNITAI_CITY_BOMBARD" then
                    -- Hit & Run
                    o.m_CombatType = 3;
                elseif GameInfo.Units[pUnit:GetUnitType()].DefaultUnitAI == "UNITAI_CITY_BOMBARD" then
                    -- Siege Unit
                    o.m_CombatType = 4;
                else
                    -- Speci Unit
                    o.m_CombatType = 5;
                end
            elseif pUnit:GetDomainType() == DomainTypes.DOMAIN_SEA and pUnit:IsCombatUnit() and not pUnit:IsImmobile() then
                if (CombatType == GameInfoTypes.UNITCOMBAT_NAVALMELEE) then
                    -- Range Navy
                    o.m_CombatType = 6;
                elseif (CombatType == GameInfoTypes.UNITCOMBAT_NAVALRANGED) then
                    -- Melee Navy
                    o.m_CombatType = 7;
                elseif (CombatType == GameInfoTypes.UNITCOMBAT_CARRIER) then
                    -- Carri Unit
                    o.m_CombatType = 8;
                elseif (CombatType == GameInfoTypes.UNITCOMBAT_SUBMARINE) then
                    -- Submarine
                    o.m_CombatType = 9;
                end
            elseif pUnit:GetDomainType() ~= DomainTypes.DOMAIN_AIR and not pUnit:IsCombatUnit() and not pUnit:IsTrade() and not pUnit:IsImmobile() then
                -- Civilian U
                o.m_CombatType = 10;
            elseif pUnit:GetDomainType() == DomainTypes.DOMAIN_AIR then
                if not GameInfo.Units[pUnit:GetUnitType()].Suicide then
                    -- Air Forces
                    o.m_CombatType = 11;
                else
                    -- Missile Un
                    o.m_CombatType = 12;
                end
            end

            ---------------------------------------------------------
            -- for Unit Groups
            if ((pUnit:GetDomainType() ~= DomainTypes.DOMAIN_AIR and not pUnit:IsTrade() and playerID == Game.GetActivePlayer())
                or (pUnit:CargoSpace() > 0 and playerID ~= Game.GetActivePlayer())) and pUnit:GetPlot() ~= nil
            then
                o.m_GroupControls = {};
                ContextPtr:BuildInstanceForControl("GroupButtons", o.m_GroupControls, o.m_Instance.UnitGroupAnchor);
                o.m_GroupControls.AirButton:SetVoid1(pUnit:GetPlot():GetX());
                o.m_GroupControls.AirButton:SetVoid2(pUnit:GetPlot():GetY());
                o.m_GroupControls.AirButton:RegisterCallback(Mouse.eLClick, OnCargoClicked);
                -- Group
                o.m_GroupControls.UISTButton:SetVoid1(playerID);
                o.m_GroupControls.UISTButton:SetVoid2(unitID);
                o.m_GroupControls.UISTButton:RegisterCallback(Mouse.eLClick, OnUISTClicked);
                -- Same CombatType
                o.m_GroupControls.GACTButton:SetVoid1(playerID);
                o.m_GroupControls.GACTButton:SetVoid2(unitID);
                o.m_GroupControls.GACTButton:RegisterCallback(Mouse.eLClick, OnGACTClicked);
                -- All
                o.m_GroupControls.GALLButton:SetVoid1(playerID);
                o.m_GroupControls.GALLButton:SetVoid2(unitID);
                o.m_GroupControls.GALLButton:RegisterCallback(Mouse.eLClick, OnGALLClicked);
            end

            ---------------------------------------------------------
            -- build the table for this player and store the flag
            local playerTable = g_MasterList[playerID];
            if playerTable == nil
            then
                playerTable = {};
                g_MasterList[playerID] = playerTable
            end
            g_MasterList[playerID][unitID] = o;

            -- Threatening? (Disabled)
            --if (pUnit:IsThreateningAnyMinorCiv()) then
            --OnMarkThreateningEvent( playerID, unitID, true )
            --else
            --o:SetFlash( false );
            --end

            local pAirCraftState = CheckPlot(o.m_Escort);
            if o.m_IsAirCraft and o.m_Escort and o.m_Escort:IsCity() then
                UpdateCityCargo(o.m_Escort, pAirCraftState);
            end
        end
        return o;
    end,
    ------------------------------------------------------------------
    -- constructor
    ------------------------------------------------------------------
    Initialize = function(o, playerID, unitID, fogState, invisible)
        o.m_Player = Players[playerID];
        o.m_PlayerID = playerID;
        o.m_UnitID = unitID;

        if (g_PrintDebug) then print(string.format("Creating UnitFlag for: Player[%i] Unit[%i]", playerID, unitID)); end

        local pUnit = Players[playerID]:GetUnitByID(unitID);
        if (pUnit == nil)
        then
            print(string.format("Unit not found for UnitFlag: Player[%i] Unit[%i]", playerID, unitID));
            return nil;
        end

        o.m_Escort = pUnit:GetPlot();
        o.m_IsTrade = pUnit:IsTrade();
        if pUnit:GetUnitCombatType() == GameInfoTypes.UNITCOMBAT_RECON then
            o.m_SPUnitType = 0;
        elseif pUnit:GetBaseCombatStrength() > 0 and not pUnit:IsCargo() and pUnit:IsImmobile() then
            o.m_SPUnitType = 1;
        else
            o.m_SPUnitType = -1;
        end
        o.m_IsCivilian = not pUnit:IsCombatUnit() or pUnit:IsEmbarked();
        o.m_IsInvisible = invisible;

        -- Technically, we should get a UnitGarrisoned event after the creation event if
        -- the unit is garrisoned.  So IsGarrisoned should always be false at creation.
        -- In the interest of preserving behavior I'm allowing m_IsGarrisoned to be set
        -- using IsGarrisoned() on creation.  However, in the strategic view this causes
        -- a visibility error in some odd cases so there it always starts as false.
        if (InStrategicView())
        then
            o.m_IsGarrisoned = false;
        else
            o.m_IsGarrisoned = pUnit:IsGarrisoned();
        end

        ---------------------------------------------------------
        -- Hook up the button
        local active_team = Game.GetActiveTeam();
        local team = o.m_Player:GetTeam();

        o.m_Instance.NormalButton:SetVoid1(playerID);
        o.m_Instance.NormalButton:SetVoid2(unitID);
        o.m_Instance.HealthBarButton:SetVoid1(playerID);
        o.m_Instance.HealthBarButton:SetVoid2(unitID);
        if (o.m_Player:IsHuman()) then
            o.m_Instance.NormalButton:RegisterCallback(Mouse.eLClick, UnitFlagClicked);
            o.m_Instance.NormalButton:RegisterCallback(Mouse.eMouseEnter, UnitFlagEnter);
            o.m_Instance.NormalButton:RegisterCallback(Mouse.eMouseExit, UnitFlagExit);

            o.m_Instance.HealthBarButton:RegisterCallback(Mouse.eLClick, UnitFlagClicked);
            o.m_Instance.HealthBarButton:RegisterCallback(Mouse.eMouseEnter, UnitFlagEnter);
            o.m_Instance.HealthBarButton:RegisterCallback(Mouse.eMouseExit, UnitFlagExit);
        end

        if (active_team == team) then
            o.m_Instance.NormalButton:SetDisabled(false);
            o.m_Instance.NormalButton:SetConsumeMouseOver(true);

            o.m_Instance.HealthBarButton:SetDisabled(false);
            o.m_Instance.HealthBarButton:SetConsumeMouseOver(true);
        else
            o.m_Instance.NormalButton:SetDisabled(true);
            o.m_Instance.NormalButton:SetConsumeMouseOver(false);
            o.m_Instance.NormalButton:RegisterCallback(Mouse.eMouseEnter, function()
                local pMouseOverUnit = Players[playerID]:GetUnitByID(unitID);
                if (pMouseOverUnit ~= nil) then
                    Game.MouseoverUnit(pMouseOverUnit, true);
                end
            end);
            o.m_Instance.NormalButton:RegisterCallback(Mouse.eMouseExit, function()
                local pMouseOverUnit = Players[playerID]:GetUnitByID(unitID);
                if (pMouseOverUnit ~= nil) then
                    Game.MouseoverUnit(pMouseOverUnit, false);
                end
            end);
            o.m_Instance.HealthBarButton:SetDisabled(true);
            o.m_Instance.HealthBarButton:SetConsumeMouseOver(false);
        end


        ---------------------------------------------------------
        -- update all the info
        o:UpdateName();
        o:SetUnitColor();
        o:SetUnitType();
        o:UpdateFlagType();
        o:UpdateHealth();
        o:UpdateSelected();
        o:SetFogState(fogState);
        o:UpdateFlagOffset();
        o:UpdateVisibility();


        ---------------------------------------------------------
        -- Set the world position
        local worldPosX, worldPosY, worldPosZ = GridToWorld(pUnit:GetX(), pUnit:GetY());
        worldPosZ = worldPosZ + 35;

        o:UnitMove(worldPosX, worldPosY, worldPosZ);
    end,
    ------------------------------------------------------------------
    ------------------------------------------------------------------
    destroy = function(self)
        if (self.m_InstanceManager ~= nil)
        then
            self.m_Instance.UnitGroupAnchor:DestroyAllChildren();
            if (self.m_GroupControls ~= nil) then
                self.m_GroupControls = nil;
            end

            self:UpdateSelected(false);

            -- tell the same plot units we're dead
            if (self.m_StackOrders[1] > 1 or self.m_IsAirCraft) and self.m_Escort ~= nil then
                local pAirCraftState = CheckPlot(self.m_Escort);
                if self.m_IsInGroup and not self.m_IsAirCraft and not g_IsDoingGG then
                    for i = 0, self.m_Escort:GetNumUnits() - 1 do
                        if self.m_Escort:GetUnit(i) and self.m_Escort:GetUnit(i):IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID) then
                            RemoveGroupMark(self.m_Escort:GetUnit(i));
                        end
                    end
                    OnGroupMoveSet(self.m_Escort);
                end
                if (self.m_IsAirCraft and self.m_Escort:IsCity()) then
                    UpdateCityCargo(self.m_Escort, pAirCraftState);
                end
                g_ListPlot = nil;
            end

            self.m_Escort = nil;
            self.m_InstanceManager:ReleaseInstance(self.m_Instance);
            g_MasterList[self.m_PlayerID][self.m_UnitID] = nil;
        end
    end,
    ------------------------------------------------------------------
    ------------------------------------------------------------------
    SetUnitColor = function(self)
        local iconColor, flagColor = self.m_Player:GetPlayerColors();

        if (self.m_Player:IsMinorCiv())
        then
            flagColor, iconColor = iconColor, flagColor;
        end

        self.m_Instance.FlagBase:SetColor(flagColor);
        self.m_Instance.UnitIcon:SetColor(iconColor);
        self.m_Instance.FlagBaseOutline:SetColor(iconColor);
    end,
    ------------------------------------------------------------------
    ------------------------------------------------------------------
    SetUnitType = function(self)
        local unit = Players[self.m_PlayerID]:GetUnitByID(self.m_UnitID);
        if unit == nil then
            return;
        end

        local thisUnitInfo = GameInfo.Units[unit:GetUnitType()];

        local textureOffset, textureSheet = IconLookup(thisUnitInfo.UnitFlagIconOffset, 32, thisUnitInfo.UnitFlagAtlas);
        self.m_Instance.UnitIcon:SetTexture(textureSheet);
        self.m_Instance.UnitIconShadow:SetTexture(textureSheet);
        self.m_Instance.UnitIcon:SetTextureOffset(textureOffset);
        self.m_Instance.UnitIconShadow:SetTextureOffset(textureOffset);
    end,
    ------------------------------------------------------------------
    ------------------------------------------------------------------
    SetFogState = function(self, fogState)
        if (fogState ~= WhiteFog) then
            self:SetHide(true);
        else
            self:SetHide(false);
        end
    end,
    ------------------------------------------------------------------
    ------------------------------------------------------------------
    SetHide = function(self, bHide)
        self.m_IsCurrentlyVisible = not bHide;
        self:UpdateVisibility();
    end,
    ------------------------------------------------------------
    ------------------------------------------------------------
    UpdateVisibility = function(self)
        local bVisible = self.m_IsCurrentlyVisible and not self.m_IsInvisible and not self.m_IsForceHide;
        self.m_Instance.Anchor:SetHide(not bVisible);
        if InStrategicView() and not g_DeleteALLStrategicUnitFlag then
            local bShowInStrategicView = bVisible and g_GarrisonedUnitFlagsInStrategicView and self.m_IsGarrisoned;
            self.m_Instance.FlagShadow:SetHide(not bShowInStrategicView);
        else
            self.m_Instance.FlagShadow:SetHide(not bVisible);
            -- Set the same plot units too.
            -- Do not change this in relation to the 'invisible' flag, that is a state of only that unit.  i.e. A sub does not hide the same plot units
            if (self.m_StackOrders[1] > 1 and not self.m_IsAirCraft) then
                local bPlotVisible = self.m_IsCurrentlyVisible and not self.m_IsForceHide;
                self.m_Instance.Anchor:SetHide(not bPlotVisible);
            end
        end
    end,
    ------------------------------------------------------------
    ------------------------------------------------------------
    GarrisonComplete = function(self, bGarrisoned)
        self.m_IsGarrisoned = bGarrisoned;
        self:UpdateVisibility();
        self:UpdateFlagOffset();
        self:UpdateFlagType();
    end,
    ------------------------------------------------------------------
    ------------------------------------------------------------------
    UpdateHealth = function(self)
        local pUnit = Players[self.m_PlayerID]:GetUnitByID(self.m_UnitID);
        if pUnit == nil then
            return;
        end

        local healthPercent = math.max(math.min(pUnit:GetCurrHitPoints() / pUnit:GetMaxHitPoints(), 1), 0);
        if (g_PrintDebug) then print("Setting health: " ..
            tostring(healthPercent) .. " " .. tostring(self.m_PlayerID) .. " " .. tostring(self.m_UnitID)); end

        -- going to damaged state
        if (healthPercent < 1)
        then
            -- show the bar and the button anim
            self.m_Instance.HealthBarBG:SetHide(false);
            self.m_Instance.HealthBar:SetHide(false);
            self.m_Instance.HealthBarButton:SetHide(false);

            -- hide the normal button
            self.m_Instance.NormalButton:SetHide(true);

            -- handle the selection indicator
            if (self.m_IsSelected)
            then
                self.m_Instance.NormalSelect:SetHide(true);
                self.m_Instance.HealthBarSelect:SetHide(false);
            end

            if (healthPercent > 0.66)
            then
                self.m_Instance.HealthBar:SetFGColor(Vector4(0, 1, 0, 1));
            elseif (healthPercent > 0.33)
            then
                self.m_Instance.HealthBar:SetFGColor(Vector4(1, 1, 0, 1));
            else
                self.m_Instance.HealthBar:SetFGColor(Vector4(1, 0, 0, 1));
            end

            --------------------------------------------------------------------
            -- going to full health
        else
            self.m_Instance.HealthBar:SetFGColor(Vector4(0, 1, 0, 1));

            -- hide the bar and the button anim
            self.m_Instance.HealthBarBG:SetHide(true);
            self.m_Instance.HealthBar:SetHide(true);
            self.m_Instance.HealthBarButton:SetHide(true);

            -- show the normal button
            self.m_Instance.NormalButton:SetHide(false);

            -- handle the selection indicator
            if (self.m_IsSelected)
            then
                self.m_Instance.NormalSelect:SetHide(false);
                self.m_Instance.HealthBarSelect:SetHide(true);
            end
        end

        self.m_Instance.HealthBar:SetPercent(healthPercent);
        self.m_Health = healthPercent;
    end,
    ------------------------------------------------------------------
    ------------------------------------------------------------------
    UpdateSelected = function(self, isSelected)
        self.m_IsSelected = isSelected; --self.m_Unit:IsSelected();
        if (g_PrintDebug) then print("Setting selected: " ..
            tostring(self.m_IsSelected) .. " " .. tostring(self.m_PlayerID) .. " " .. tostring(self.m_UnitID)); end

        if (self.m_Health >= 1)
        then
            self.m_Instance.NormalSelect:SetHide(not self.m_IsSelected);
            self.m_Instance.HealthBarSelect:SetHide(true);
        else
            self.m_Instance.HealthBarSelect:SetHide(not self.m_IsSelected);
            self.m_Instance.NormalSelect:SetHide(true);
        end

        local pUnit = Players[self.m_PlayerID]:GetUnitByID(self.m_UnitID);
        local bGUISTIsHide = true;
        local bGGBoxIsHide = true;
        if pUnit then
            self.m_IsInGroup = pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID) or
                pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_AIR"].ID);
            bGUISTIsHide = (not self.m_IsInGroup and (self.m_StackOrders[1] <= 1 or not (pUnit:CanMove() or pUnit:CanDoCommand(CommandTypes.COMMAND_CANCEL)))) or
                g_IsDoingGG or not Players[Game.GetActivePlayer()]:IsTurnActive() or
                (self.m_Escort and self.m_Escort:IsCity());
            bGGBoxIsHide = not pUnit:IsFriendlyUnitAdjacent() or
                not (self.m_IsInGroup or pUnit:CanMove() or pUnit:CanDoCommand(CommandTypes.COMMAND_CANCEL)) or
                g_IsDoingGG or not Players[Game.GetActivePlayer()]:IsTurnActive() or
                (self.m_Escort and self.m_Escort:IsCity());
        end
        if (self.m_IsSelected) then
            self.m_Instance.Anchor:ChangeParent(g_SelectedContainer);
            g_SelectedFlag = self;

            if not g_UnitList.LisAnchor:IsHidden() then
                if self.m_Escort ~= g_ListPlot then
                    g_UnitList.LisAnchor:ChangeParent(Controls.CityContainer);
                    g_UnitList.LisAnchor:ChangeParent(g_SelectedContainer);
                    g_UnitList.LisAnchor:SetHide(true);
                else
                    UpdateCargoList();
                end
            end
            if self.m_GroupControls then
                if not self.m_IsInGroup then
                    self.m_GroupControls.UISTButton:SetText("[ICON_SGM_GROUP_OFF]");
                    self.m_GroupControls.UISTButton:LocalizeAndSetToolTip("TXT_KEY_SGM_GROUP_OFF_TT");
                else
                    self.m_GroupControls.UISTButton:SetText("[ICON_SGM_GROUP_ON]");
                    self.m_GroupControls.UISTButton:LocalizeAndSetToolTip("TXT_KEY_SGM_GROUP_ON_TT");
                end
                self.m_GroupControls.GACTButton:SetText("[ICON_SGM_GROUP_ACT_OFF]");
                self.m_GroupControls.GALLButton:SetText("[ICON_SGM_GROUP_ALL_OFF]");
                self.m_GroupControls.GACTButton:LocalizeAndSetToolTip("TXT_KEY_SGM_GROUP_ACT_OFF_TT");
                self.m_GroupControls.GALLButton:LocalizeAndSetToolTip("TXT_KEY_SGM_GROUP_ALL_OFF_TT");
                self.m_GroupControls.UISTButton:SetHide(bGUISTIsHide);
                self.m_GroupControls.GGBox:SetHide(bGGBoxIsHide);
                if not bGUISTIsHide or not bGGBoxIsHide then
                    self:UpdateFlagOffset();
                end
                if not bGGBoxIsHide and g_GGPlot ~= nil then
                    if g_GGType == 0 then
                        g_GGType = -1;
                        OnGACTClicked(self.m_PlayerID, self.m_UnitID);
                    elseif g_GGType == 1 then
                        g_GGType = -1;
                        OnGALLClicked(self.m_PlayerID, self.m_UnitID);
                    end
                end
            end
            if g_GGPlot == nil or g_GGType == -1 or (pUnit and not pUnit:IsFriendlyUnitAdjacent()) then
                if self.m_GGMPlot and self.m_Escort then
                    for i = 0, self.m_Escort:GetNumUnits() - 1 do
                        local pGGUnit = self.m_Escort:GetUnit(i);
                        if pGGUnit and g_MasterList[pGGUnit:GetOwner()] ~= nil and g_MasterList[pGGUnit:GetOwner()][pGGUnit:GetID()] ~= nil then
                            g_MasterList[pGGUnit:GetOwner()][pGGUnit:GetID()].m_GGMPlot = nil;
                        end
                    end
                end
                if pUnit and self.m_IsInGroup and self.m_StackOrders[1] <= 1 then
                    self.m_IsInGroup = false;
                    if self.m_IsAirCraft then
                        pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_AIR"].ID, false);
                    else
                        RemoveGroupMark(pUnit);
                        pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID, false);
                        if self.m_GroupControls then
                            self.m_GroupControls.UISTButton:SetHide(true);
                        end
                    end
                end
            end
        else
            if (self.m_IsAirCraft) then
                self.m_Instance.Anchor:ChangeParent(Controls.AirCraftFlags);
            elseif (self.m_IsCivilian) then
                self.m_Instance.Anchor:ChangeParent(Controls.CivilianFlags);
            elseif (self.m_IsGarrisoned) then
                self.m_Instance.Anchor:ChangeParent(Controls.GarrisonFlags);
                -- SP Recon Units
            elseif (self.m_SPUnitType == 0) then
                self.m_Instance.Anchor:ChangeParent(Controls.ReconUniFlags);
            else
                self.m_Instance.Anchor:ChangeParent(Controls.MilitaryFlags);
            end
            if self.m_GroupControls then
                self.m_GroupControls.UISTButton:SetHide(true);
                self.m_GroupControls.GGBox:SetHide(true);
            end
        end

        self:OverrideDimmedFlag(self.m_IsSelected);
    end,
    ------------------------------------------------------------------
    ------------------------------------------------------------------
    UpdateFlagType = function(self)
        local textureName;
        local maskName;

        local pUnit = Players[self.m_PlayerID]:GetUnitByID(self.m_UnitID);
        if pUnit == nil then
            return;
        end

        if self.m_IsGarrisoned and not pUnit:IsGarrisoned() then
            self.m_IsGarrisoned = false;
        end

        if (pUnit:IsEmbarked()) then
            textureName = "UnitFlagEmbark.dds";
            maskName = "UnitFlagEmbarkMask.dds";
            self.m_Instance.UnitIconShadow:SetOffsetVal( -1, -2);
        elseif (pUnit:IsGarrisoned() and pUnit:GetTeam() ~= Game.GetActiveTeam()) or (self.m_SPUnitType == 1) then
            textureName = "UnitFlagGarrison.dds";
            maskName = "UnitFlagGarrisonMask.dds";
            self.m_Instance.UnitIconShadow:SetOffsetVal( -1, 1);
            -- SP Ranged Units
        elseif (pUnit:IsSetUpForRangedAttack()) then
            textureName = "UnitFlagRanged.dds";
            maskName = "UnitFlagRangedMask.dds";
            self.m_Instance.UnitIconShadow:SetOffsetVal(0, 0);
        elseif (pUnit:GetFortifyTurns() > 0 and not pUnit:IsGarrisoned()) then
            --[[
            if( pUnit:isRanged() )
            then
                -- need art for this
                textureName = "UnitFlagRanged.dds";
                maskName = "UnitFlagRangedMask.dds";
                self.m_Instance.UnitIconShadow:SetOffsetVal( 0, 0 );
            else
            --]]
            textureName = "UnitFlagFortify.dds";
            maskName = "UnitFlagFortifyMask.dds";
            self.m_Instance.UnitIconShadow:SetOffsetVal( -1, 0);
            --end
        elseif (self.m_IsTrade) then
            textureName = "UnitFlagTrade.dds";
            maskName = "UnitFlagTradeMask.dds";
            self.m_Instance.UnitIconShadow:SetOffsetVal( -1, 0);
            -- SP Recon Units
        elseif (self.m_SPUnitType == 0) then
            textureName = "UnitFlagRecon.dds";
            maskName = "UnitFlagReconMask.dds";
            self.m_Instance.UnitIconShadow:SetOffsetVal( -1, 0);
        elseif (not self.m_IsCivilian) then
            textureName = "UnitFlagBase.dds";
            maskName = "UnitFlagMask.dds";
            self.m_Instance.UnitIconShadow:SetOffsetVal( -1, 0);
        else
            textureName = "UnitFlagCiv.dds";
            maskName = "UnitFlagCivMask.dds";
            self.m_Instance.UnitIconShadow:SetOffsetVal( -1, -3);
        end

        self.m_Instance.UnitIconShadow:ReprocessAnchoring();


        self.m_Instance.FlagShadow:SetTexture(textureName);
        self.m_Instance.FlagBase:SetTexture(textureName);
        self.m_Instance.FlagBaseOutline:SetTexture(textureName);
        self.m_Instance.NormalSelect:SetTexture(textureName);
        self.m_Instance.HealthBarSelect:SetTexture(textureName);
        self.m_Instance.LightEffect:SetTexture(textureName);
        self.m_Instance.HealthBarBG:SetTexture(textureName);
        self.m_Instance.NormalAlphaAnim:SetTexture(textureName);
        self.m_Instance.HealthBarAlphaAnim:SetTexture(textureName);

        self.m_Instance.NormalScrollAnim:SetMask(maskName);
        self.m_Instance.HealthBarScrollAnim:SetMask(maskName);
    end,
    ------------------------------------------------------------------
    ------------------------------------------------------------------
    UpdateName = function(self)
        local pUnit = Players[self.m_PlayerID]:GetUnitByID(self.m_UnitID);
        if pUnit == nil then
            return;
        end

        --[[
        local active_team = Game.GetActiveTeam();
        local team = self.m_Player:GetTeam();

        local unitNameString;
        if(pUnit:HasName()) then
            local desc = Locale.ConvertTextKey("TXT_KEY_PLOTROLL_UNIT_DESCRIPTION_CIV",  self.m_Player:GetCivilizationAdjectiveKey(), pUnit:GetNameKey());
            unitNameString = string.format("%s[NEWLINE](%s)", Locale.Lookup(pUnit:GetNameNoDesc()), desc);
        else
            unitNameString = Locale.ConvertTextKey("TXT_KEY_PLOTROLL_UNIT_DESCRIPTION_CIV",  self.m_Player:GetCivilizationAdjectiveKey(), pUnit:GetNameKey());
        end

        if( active_team == team ) then
            local string;
            if(PreGame.IsMultiplayerGame() and self.m_Player:IsHuman()) then
                string = Locale.ConvertTextKey("TXT_KEY_MULTIPLAYER_UNIT_TT", self.m_Player:GetNickName(), self.m_Player:GetCivilizationAdjectiveKey(), pUnit:GetNameKey() );
            else
                string = unitNameString;
            end

            local eReligion = pUnit:GetReligion();
            if (eReligion > ReligionTypes.RELIGION_PANTHEON) then
                string = string .. " - " .. Locale.Lookup(Game.GetReligionName(eReligion));
            end

            if( playerID == Game.GetActivePlayer() ) then
                string = string .. Locale.ConvertTextKey( "TXT_KEY_UPANEL_CLICK_TO_SELECT" );
            end
            self.m_Instance.UnitIcon:SetToolTipString( string );
        else
            if(PreGame.IsMultiplayerGame() and self.m_Player:IsHuman()) then
                self.m_Instance.UnitIcon:SetToolTipString(Locale.ConvertTextKey("TXT_KEY_MULTIPLAYER_UNIT_TT", self.m_Player:GetNickName(), self.m_Player:GetCivilizationAdjectiveKey(), pUnit:GetNameKey()));
            else
                self.m_Instance.UnitIcon:SetToolTipString(unitNameString);
            end
        end
        ]]
        self.m_Instance.NormalButton:SetToolTipCallback(TipHandler);
        self.m_Instance.HealthBarButton:SetToolTipCallback(TipHandler);
    end,
    ------------------------------------------------------------------
    -- used by CheckPolt to maintain the same Plot Units -(CaptainCWB)
    ------------------------------------------------------------------
    SetPlot = function(self, UnitCount, SameUnitCount, UnitOrder, HasCombat)
        self.m_StackOrders = { UnitCount, SameUnitCount, UnitOrder, HasCombat };
        self:UpdateFlagOffset();
        if (self.m_CarrierFlag ~= nil) then
            self:UpdateCargo(self.m_CargoCount);
        end
    end,
    ------------------------------------------------------------------
    ------------------------------------------------------------------
    UpdateCargo = function(self, CargoCount)
        local pUnit = Players[self.m_PlayerID]:GetUnitByID(self.m_UnitID);
        if (pUnit == nil or pUnit:CargoSpace() <= 0 or self.m_GroupControls == nil or pUnit:GetPlot() == nil) then
            return;
        end

        local pPlot = pUnit:GetPlot();
        if (pPlot:IsCity() or CargoCount == 0 or self.m_CarrierFlag ~= self) then
            self.m_GroupControls.AirButton:SetHide(true);
        else
            self.m_GroupControls.AirButton:SetHide(false);

            self.m_GroupControls.Count:LocalizeAndSetText(CargoCount);
            if not self.m_HasGroupAir then
                self.m_GroupControls.Count:SetColorByName("Beige_Black_Alpha");
            else
                self.m_GroupControls.Count:SetColorByName("Gold_Medal");
            end
            self.m_GroupControls.AirButton:LocalizeAndSetToolTip("TXT_KEY_STATIONED_AIRCRAFT", CargoCount);
        end
    end,
    -----------------------------------------------------------------
    ------------------------------------------------------------------
    SetFlash = function(self, bFlashOn)
        self.m_Instance.UnitIconAnim:SetToBeginning();

        if (bFlashOn) then
            self.m_Instance.UnitIconAnim:Play();
        end
    end,
    -----------------------------------------------------------------
    ------------------------------------------------------------------
    SetDim = function(self, bDim)
        self.m_IsDimmed = bDim;
        self:UpdateDimmedState();
    end,
    -----------------------------------------------------------------
    ------------------------------------------------------------------
    OverrideDimmedFlag = function(self, bOverride)
        self.m_OverrideDimmedFlag = bOverride;
        self:UpdateDimmedState();
    end,
    -----------------------------------------------------------------
    ------------------------------------------------------------------
    UpdateDimmedState = function(self)
        if (self.m_IsDimmed and not self.m_OverrideDimmedFlag) then
            self.m_Instance.FlagShadow:SetAlpha(g_DimAlpha);
            self.m_Instance.HealthBar:SetAlpha(1.0 / g_DimAlpha); -- Health bar doesn't get dimmed (Hacky I know)
        else
            self.m_Instance.FlagShadow:SetAlpha(1.0);
            self.m_Instance.HealthBar:SetAlpha(1.0);
        end
    end,
    -----------------------------------------------------------------
    ------------------------------------------------------------------
    UnitMove = function(self, posX, posY, posZ)
        ------------------------
        if (g_PrintDebug) then print("Setting flag position"); end
        self.m_Instance.Anchor:SetWorldPositionVal(posX, posY, posZ);

        if (self.m_HasCivilianSelectFlag)
        then
            if (g_PrintDebug) then print("Updating select flag pos"); end
            --g_CivilianSelectFlag.m_Instance.Anchor:SetWorldPositionVal( posX, posY, posZ );
        end
        if Players[Game.GetActivePlayer()]:IsTurnActive() and self.m_PlayerID == Game.GetActivePlayer()
            and Players[self.m_PlayerID] ~= nil and Players[self.m_PlayerID]:GetUnitByID(self.m_UnitID) ~= nil
            and Players[self.m_PlayerID]:GetUnitByID(self.m_UnitID):GetDomainType() ~= DomainTypes.DOMAIN_AIR
        then
            local pUnit = Players[self.m_PlayerID]:GetUnitByID(self.m_UnitID);
            if not g_IsDoingGG and self.m_Escort ~= pUnit:GetPlot() then
                g_IsDoingGG = true;
            elseif g_IsDoingGG and self.m_Escort == pUnit:GetPlot() and not pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID) then
                g_IsDoingGG = false;
            end
        end
        if not g_HasMove and self.m_GroupControls ~= nil then
            if not self.m_GroupControls.UISTButton:IsHidden() then
                self.m_GroupControls.UISTButton:SetHide(true);
            end
            if not self.m_GroupControls.GGBox:IsHidden() then
                self.m_GroupControls.GGBox:SetHide(true);
            end
        elseif g_HasMove then
            g_HasMove = false;
            if self.m_GroupControls ~= nil and self.m_IsSelected then
                self:UpdateSelected(true);
            end
        end
    end,
    ------------------------------------------------------------------
    ------------------------------------------------------------------
    UpdateFlagOffset = function(self)
        local pUnit = Players[self.m_PlayerID]:GetUnitByID(self.m_UnitID);
        if pUnit == nil then
            return;
        end

        local plot = pUnit:GetPlot();
        if plot == nil then
            return;
        end

        local offset = Vector2(0, 0);

        if pUnit:IsGarrisoned() then
            if (Game.GetActiveTeam() == Players[self.m_PlayerID]:GetTeam()) then
                offset = GarrisonOffset;
            else
                offset = GarrisonOtherOffset;
            end

            if not self.m_IsGarrisoned then
                self.m_IsGarrisoned = true;
                if InStrategicView() then
                    self:UpdateVisibility();
                end
            end

            -- When garrisoned, we want to line up the icon with the city banner.  Some units sit at different heights, so repostion the icon world position to match the city banner
            local worldPos = Vector4(GridToWorld(pUnit:GetX(), pUnit:GetY()));
            self.m_Instance.Anchor:SetWorldPosition(VecAdd(worldPos, CityWorldPositionOffset));

            -- MOD by CaptainCWB - Begin <<<<<
            -- Flags positions for multi unit stacking.
        else
            local maxWidth = 105; -- reduce this to prevent overlapping icons when zooming out
            local iconSize = 35; -- ideal icon offset
            local airCargoOffset = 45;
            local civilianOffset = -25;
            local numSimilarUnit = math.max(self.m_StackOrders[2] - 1, 0);
            local ordSimilarUnit = math.max(self.m_StackOrders[3] - 1, 0);
            local cityOffset = 45;
            local cityTradehoriOffset = 80;
            local citycivilianvertOffset = -65;
            local horiOffset = 0;
            local vertOffset = 0;
            local width = 0;
            local MultiUnitOffset = Vector2(0, 0);

            if (numSimilarUnit > 0) then
                width = math.min(iconSize * numSimilarUnit, maxWidth);
                horiOffset = math.floor( -(width / 2) + ((width / numSimilarUnit) * ordSimilarUnit));
            end
            if (plot:IsCity()) then
                if (self.m_IsTrade) then
                    horiOffset = horiOffset + cityTradehoriOffset;
                    vertOffset = cityOffset;
                elseif (self.m_IsCivilian and self.m_StackOrders[4] == 2) then
                    horiOffset = horiOffset + cityOffset + math.floor(width / 2);
                    vertOffset = citycivilianvertOffset;
                else
                    horiOffset = horiOffset + cityOffset + math.floor(width / 2);
                    vertOffset = -cityOffset;
                end
            else
                if (self.m_IsAirCraft) then
                    vertOffset = airCargoOffset;
                elseif (self.m_IsTrade and self.m_StackOrders[4] ~= 0) then
                    vertOffset = iconSize;
                elseif (self.m_IsCivilian and self.m_StackOrders[4] ~= 0) then
                    vertOffset = civilianOffset;
                end
            end

            -- Stack Buttons Offset
            if not InStrategicView() then
                self.m_Instance.UnitGroupAnchor:SetOffsetX(36 + math.floor(width / 2));
            else
                self.m_Instance.UnitGroupAnchor:SetOffsetX(36);
            end

            MultiUnitOffset = Vector2(horiOffset, vertOffset);
            offset = VecAdd(offset, MultiUnitOffset);
        end
        -- MOD by CaptainCWB - End   >>>>>

        -- set the ui offset
        self.m_Instance.FlagShadow:SetOffset(offset);
    end,
}

--g_CivilianSelectFlag = g_UnitFlagClass:new( -1 );
--ContextPtr:BuildInstance( "NewUnitFlag", g_CivilianSelectFlag.m_Instance );
--g_CivilianSelectFlag.m_Instance.Anchor:SetHide( true );


-------------------------------------------------
-- Unit List Manager     - by CaptainCWB
-------------------------------------------------
function OnGroupSetup(bIsChecked, pOUnit, iCombatType, bInAll)
    if pOUnit == nil or pOUnit:GetPlot() == nil then
        return;
    end

    local pPlot = pOUnit:GetPlot();
    for i = 0, pPlot:GetNumUnits() - 1 do
        local pUnit = pPlot:GetUnit(i);
        if g_MasterList[pUnit:GetOwner()] ~= nil
            and g_MasterList[pUnit:GetOwner()][pUnit:GetID()] ~= nil
            and pUnit and pUnit:GetOwner() == Game.GetActivePlayer()
        then
            local pFlag = g_MasterList[pUnit:GetOwner()][pUnit:GetID()];
            if pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID) then
                RemoveGroupMark(pUnit);
            end
            if bInAll then
                if (iCombatType == 13 and pUnit:IsCargo() and pUnit:GetTransportUnit():GetID() == pOUnit:GetID() and pUnit:GetDomainType() == DomainTypes.DOMAIN_AIR)
                    or (iCombatType == pFlag.m_CombatType and pUnit:GetDomainType() == DomainTypes.DOMAIN_AIR)
                then
                    pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_AIR"].ID, bIsChecked);
                    pFlag.m_IsInGroup = bIsChecked;
                elseif (iCombatType == -1 or iCombatType == pFlag.m_CombatType) and not pUnit:IsTrade()
                    and not (bIsChecked and not (pUnit:CanMove() or pUnit:CanDoCommand(CommandTypes.COMMAND_CANCEL) or g_GGType == -1))
                    and pUnit:GetDomainType() ~= DomainTypes.DOMAIN_AIR
                then
                    pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID, bIsChecked);
                    pFlag.m_IsInGroup = bIsChecked;
                end
            else
                if pUnit == pOUnit and pUnit:GetDomainType() == DomainTypes.DOMAIN_AIR then
                    pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_AIR"].ID,
                        not pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_AIR"].ID));
                    pFlag.m_IsInGroup = pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_AIR"].ID);
                end
            end
            pFlag.m_GGMPlot = nil;
        end
    end
    if pOUnit:GetDomainType() ~= DomainTypes.DOMAIN_AIR then
        OnGroupMoveSet(pPlot);
    end
    if not g_UnitList.LisAnchor:IsHidden() then
        UpdateCargoList();
    end
end

-------------------------------------------------

local PromotionIGNORETERRAINCOST             = GameInfo.UnitPromotions["PROMOTION_IGNORE_TERRAIN_COST"];
local PromotionALTITUDETRAINING              = GameInfo.UnitPromotions["PROMOTION_ALTITUDE_TRAINING"];
local PromotionWOODSMAN                      = GameInfo.UnitPromotions["PROMOTION_WOODSMAN"];
local PromotionSTEAMPOWERED                  = GameInfo.UnitPromotions["PROMOTION_STEAM_POWERED"];
local PromotionSKIINFANTRY                   = GameInfo.UnitPromotions["PROMOTION_SKI_INFANTRY"];
local PromotionHOVERINGUNIT                  = GameInfo.UnitPromotions["PROMOTION_HOVERING_UNIT"];
local PromotionLIGHTNINGWARFARE              = GameInfo.UnitPromotions["PROMOTION_LIGHTNING_WARFARE"];
local PromotionFIRSTSTRIKE                   = GameInfo.UnitPromotions["PROMOTION_FIRST_STRIKE"];
local PromotionROUGHTERRAINENDSTURN          = GameInfo.UnitPromotions["PROMOTION_ROUGH_TERRAIN_ENDS_TURN"];
local PromotionOCEANIMPASSABLE               = GameInfo.UnitPromotions["PROMOTION_OCEAN_IMPASSABLE"];
local PromotionOCEANIMPASSABLEUNTILASTRONOMY = GameInfo.UnitPromotions["PROMOTION_OCEAN_IMPASSABLE_UNTIL_ASTRONOMY"];
function RemoveGroupMark(pUnit)
    if pUnit == nil then
        return;
    end

    local iMoves = 0;
    local iChangeMoves = 0;
    if Players[Game.GetActivePlayer()]:IsTurnActive() then
        if pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_V"].ID)
            and pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_IV"].ID)
            and pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_III"].ID)
            and pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_II"].ID)
            and pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_I"].ID)
        then
            iChangeMoves = 15 * GameDefines["MOVE_DENOMINATOR"];
        elseif pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_V"].ID)
            and pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_IV"].ID)
            and pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_III"].ID)
            and pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_II"].ID)
        then
            iChangeMoves = 14 * GameDefines["MOVE_DENOMINATOR"];
        elseif pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_V"].ID)
            and pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_IV"].ID)
            and pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_III"].ID)
            and pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_I"].ID)
        then
            iChangeMoves = 13 * GameDefines["MOVE_DENOMINATOR"];
        elseif pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_V"].ID)
            and pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_IV"].ID)
            and pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_III"].ID)
        then
            iChangeMoves = 12 * GameDefines["MOVE_DENOMINATOR"];
        elseif pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_V"].ID)
            and pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_IV"].ID)
            and pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_II"].ID)
        then
            iChangeMoves = 11 * GameDefines["MOVE_DENOMINATOR"];
        elseif pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_V"].ID)
            and pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_IV"].ID)
            and pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_I"].ID)
        then
            iChangeMoves = 10 * GameDefines["MOVE_DENOMINATOR"];
        elseif pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_V"].ID)
            and pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_IV"].ID)
        then
            iChangeMoves = 9 * GameDefines["MOVE_DENOMINATOR"];
        elseif pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_V"].ID)
            and pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_III"].ID)
        then
            iChangeMoves = 8 * GameDefines["MOVE_DENOMINATOR"];
        elseif pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_V"].ID)
            and pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_II"].ID)
        then
            iChangeMoves = 7 * GameDefines["MOVE_DENOMINATOR"];
        elseif pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_V"].ID)
            and pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_I"].ID)
        then
            iChangeMoves = 6 * GameDefines["MOVE_DENOMINATOR"];
        elseif pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_V"].ID)
        then
            iChangeMoves = 5 * GameDefines["MOVE_DENOMINATOR"];
        elseif pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_IV"].ID)
        then
            iChangeMoves = 4 * GameDefines["MOVE_DENOMINATOR"];
        elseif pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_III"].ID)
        then
            iChangeMoves = 3 * GameDefines["MOVE_DENOMINATOR"];
        elseif pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_II"].ID)
        then
            iChangeMoves = 2 * GameDefines["MOVE_DENOMINATOR"];
        elseif pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_I"].ID)
        then
            iChangeMoves = 1 * GameDefines["MOVE_DENOMINATOR"];
        end
    end
    pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_I"].ID, false);
    pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_II"].ID, false);
    pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_III"].ID, false);
    pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_IV"].ID, false);
    pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_V"].ID, false);

    if Players[Game.GetActivePlayer()]:IsTurnActive()
        or (not Players[Game.GetActivePlayer()]:IsTurnActive() and not pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID))
    then
        pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_I"].ID, false);
        pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_II"].ID, false);
        pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_III"].ID, false);
        pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_IV"].ID, false);
        pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_V"].ID, false);
        iMoves = math.min(pUnit:GetMoves() + iChangeMoves, pUnit:MaxMoves());
        if not Players[Game.GetActivePlayer()]:IsTurnActive() then
            pUnit:SetMoves(pUnit:MaxMoves());
        else
            pUnit:SetMoves(iMoves);
        end

        pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X"].ID, false);
        if pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_I"].ID) then
            if PromotionIGNORETERRAINCOST then pUnit:SetHasPromotion(PromotionIGNORETERRAINCOST.ID, true) end
            ;
            pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_I"].ID, false);
        end
        if pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_II"].ID) then
            if PromotionALTITUDETRAINING then pUnit:SetHasPromotion(PromotionALTITUDETRAINING.ID, true) end
            ;
            pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_II"].ID, false);
        end
        if pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_III"].ID) then
            if PromotionWOODSMAN then pUnit:SetHasPromotion(PromotionWOODSMAN.ID, true) end
            ;
            pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_III"].ID, false);
        end
        if pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_IV"].ID) then
            if PromotionSTEAMPOWERED then pUnit:SetHasPromotion(PromotionSTEAMPOWERED.ID, true) end
            ;
            pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_IV"].ID, false);
        end
        if pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_V"].ID) then
            if PromotionSKIINFANTRY then pUnit:SetHasPromotion(PromotionSKIINFANTRY.ID, true) end
            ;
            pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_V"].ID, false);
        end
        if pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_VI"].ID) then
            if PromotionHOVERINGUNIT then pUnit:SetHasPromotion(PromotionHOVERINGUNIT.ID, true) end
            ;
            pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_VI"].ID, false);
        end
        if pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_VII"].ID) then
            if PromotionLIGHTNINGWARFARE then pUnit:SetHasPromotion(PromotionLIGHTNINGWARFARE.ID, true) end
            ;
            pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_VII"].ID, false);
        end
        if pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_VII_FS"].ID) then
            if PromotionFIRSTSTRIKE then pUnit:SetHasPromotion(PromotionFIRSTSTRIKE.ID, true) end
            ;
            pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_VII_FS"].ID, false);
        end
        pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_VIII"].ID, false);
        pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_IX"].ID, false);
        pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_X"].ID, false);
    end
end

-------------------------------------------------
function OnCargoClicked(gridPosX, gridPosY)
    if (Map.GetPlot(gridPosX, gridPosY) == g_ListPlot) then
        g_UnitList.LisAnchor:SetHide(not g_UnitList.LisAnchor:IsHidden());
    else
        g_ListPlot = Map.GetPlot(gridPosX, gridPosY);

        UpdateCargoList();
        g_UnitList.LisAnchor:SetHide(false);
    end
end

function UpdateCargoList()
    local pPlot = g_ListPlot;
    if pPlot == nil then
        g_UnitList.LisAnchor:SetHide(true);
        return;
    end
    g_UnitList.LisAnchor:ChangeParent(Controls.CityContainer);
    g_UnitList.ListStack:DestroyAllChildren();
    local worldPos = Vector4(GridToWorld(pPlot:GetX(), pPlot:GetY()));
    g_UnitList.LisAnchor:SetWorldPosition(VecAdd(worldPos, CityWorldPositionOffset));
    local isbHasGroup = false;

    local controlTable;
    local unitCount = 0;
    local carrCount = 0;
    local selecPlot = nil;
    if UI.GetHeadSelectedUnit() ~= nil then
        selecPlot = UI.GetHeadSelectedUnit():GetPlot();
    end
    local afCount = 0;
    local gmCount = 0;

    local aFIsAllCheckSet = true;
    local gMIsAllCheckSet = true;

    if (pPlot:IsCity()) then
        -- count the air units
        for i = 0, pPlot:GetNumUnits() - 1 do
            local pAirUnit = pPlot:GetUnit(i);
            local isHasPromotion = pAirUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_AIR"].ID);
            if not isbHasGroup and isHasPromotion then
                isbHasGroup = true;
            end

            if pAirUnit:GetDomainType() == DomainTypes.DOMAIN_AIR and not pAirUnit:IsInvisible(Game.GetActiveTeam()) then
                unitCount = unitCount + 1;
                controlTable = {};
                ContextPtr:BuildInstanceForControl("UnitInstance", controlTable, g_UnitList.ListStack);

                TruncateString(controlTable.CargoName, 130, pAirUnit:GetName());
                controlTable.Button:SetVoid1(pAirUnit:GetOwner());
                controlTable.Button:SetVoid2(pAirUnit:GetID());
                controlTable.Button:RegisterCallback(Mouse.eLClick, UnitFlagClicked);
                controlTable.GroupMark:SetHide(false);

                if unitCount == 1 and pPlot ~= selecPlot and pAirUnit:GetOwner() == Game.GetActivePlayer() then
                    controlTable.SelectHighlight:SetHide(false);
                    Events.SerialEventUnitFlagSelected(pAirUnit:GetOwner(), pAirUnit:GetID());
                end

                if (pAirUnit == UI.GetHeadSelectedUnit()) then
                    controlTable.SelectHighlight:SetHide(false);
                end
                if (pAirUnit:GetOwner() ~= Game.GetActivePlayer()) then
                    controlTable.GroupMark:SetHide(true);
                    controlTable.Button:SetAlpha(0.6);
                else
                    if (not pAirUnit:CanMove()) then
                        controlTable.Button:SetAlpha(0.6);
                    elseif (pAirUnit:HasMoved()) then
                        controlTable.Button:SetAlpha(0.8);
                    else
                        controlTable.Button:SetAlpha(1.0);
                    end
                    if not GameInfo.Units[pAirUnit:GetUnitType()].Suicide then
                        afCount = afCount + 1;
                        controlTable.GroupMark:RegisterCallback(Mouse.eLClick,
                            function() OnGroupSetup(_, pAirUnit, 11, false); end);
                        if isHasPromotion then
                            controlTable.GroupMark:SetText("[ICON_BULLET]");
                            controlTable.GroupMark:LocalizeAndSetToolTip("TXT_KEY_AIRCRAFT_OFF_TT");
                        else
                            controlTable.GroupMark:SetText("[ICON_WTF1]");
                            controlTable.GroupMark:LocalizeAndSetToolTip("TXT_KEY_AIRCRAFT_ON_TT");
                            if aFIsAllCheckSet then
                                aFIsAllCheckSet = false;
                            end
                        end
                    else
                        gmCount = gmCount + 1;
                        controlTable.GroupMark:RegisterCallback(Mouse.eLClick,
                            function() OnGroupSetup(_, pAirUnit, 12, false); end);
                        if isHasPromotion then
                            controlTable.GroupMark:SetText("[ICON_BULLET]");
                            controlTable.GroupMark:LocalizeAndSetToolTip("TXT_KEY_AIRCRAFT_OFF_TT");
                        else
                            controlTable.GroupMark:SetText("[ICON_WTF1]");
                            controlTable.GroupMark:LocalizeAndSetToolTip("TXT_KEY_AIRCRAFT_ON_TT");
                            if gMIsAllCheckSet then
                                gMIsAllCheckSet = false;
                            end
                        end
                    end
                end
            end
        end

        if g_CityFlags[pPlot:GetX() .. " " .. pPlot:GetY()] ~= nil then
            if not isbHasGroup then
                g_CityFlags[pPlot:GetX() .. " " .. pPlot:GetY()].Count:SetColorByName("Beige_Black_Alpha");
            else
                g_CityFlags[pPlot:GetX() .. " " .. pPlot:GetY()].Count:SetColorByName("Gold_Medal");
            end
        end
    else
        local pFirstCarriFlag = nil;
        for i = 0, pPlot:GetNumUnits() - 1, 1 do
            local pCarrierUnit = pPlot:GetUnit(i);
            if (pCarrierUnit:HasCargo() and not pCarrierUnit:IsInvisible(Game.GetActiveTeam())) then
                unitCount = unitCount + 1;
                carrCount = carrCount + 1;

                -----------------------------------------------
                -- button for the carriers having cargo
                controlTable = {};
                ContextPtr:BuildInstanceForControl("UnitInstance", controlTable, g_UnitList.ListStack);

                controlTable.Button:SetVoid1(pCarrierUnit:GetOwner());
                controlTable.Button:SetVoid2(pCarrierUnit:GetID());
                controlTable.Button:RegisterCallback(Mouse.eLClick, UnitFlagClicked);

                if carrCount == 1 and pPlot ~= selecPlot and pCarrierUnit:GetOwner() == Game.GetActivePlayer() then
                    controlTable.SelectHighlight:SetHide(false);
                    Events.SerialEventUnitFlagSelected(pCarrierUnit:GetOwner(), pCarrierUnit:GetID());
                end

                if (pCarrierUnit == UI.GetHeadSelectedUnit()) then
                    controlTable.SelectHighlight:SetHide(false);
                end
                if (pCarrierUnit:GetOwner() ~= Game.GetActivePlayer()) then
                    TruncateString(controlTable.CarriName, 155,
                        Locale.ConvertTextKey("[ICON_BULLET]" .. pCarrierUnit:GetName()));
                    controlTable.GroupMark:SetHide(true);
                    controlTable.Button:SetAlpha(0.6);
                else
                    TruncateString(controlTable.CarriName, 140,
                        Locale.ConvertTextKey("[ICON_BULLET]" .. pCarrierUnit:GetName()));
                    controlTable.GroupMark:SetHide(false);
                    if (not pCarrierUnit:CanMove()) then
                        controlTable.Button:SetAlpha(0.6);
                    elseif (pCarrierUnit:HasMoved()) then
                        controlTable.Button:SetAlpha(0.8);
                    else
                        controlTable.Button:SetAlpha(1.0);
                    end
                end

                local cargoIsAllCheckSet = true;
                local cargoCoTable;

                for j = 0, pPlot:GetNumUnits() - 1 do
                    local pCargoUnit = pPlot:GetUnit(j);
                    local isHasPromotion = pCargoUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_AIR"].ID);

                    if not isbHasGroup and isHasPromotion then
                        isbHasGroup = true;
                    end

                    if (pCargoUnit:IsCargo() and pCargoUnit:GetTransportUnit():GetID() == pCarrierUnit:GetID()
                        and not pCargoUnit:IsInvisible(Game.GetActiveTeam()))
                    then
                        unitCount = unitCount + 1;

                        -- we're carrying
                        cargoCoTable = {};
                        ContextPtr:BuildInstanceForControl("UnitInstance", cargoCoTable, g_UnitList.ListStack);

                        TruncateString(cargoCoTable.CargoName, 130, pCargoUnit:GetName());
                        cargoCoTable.Button:SetVoid1(pCargoUnit:GetOwner());
                        cargoCoTable.Button:SetVoid2(pCargoUnit:GetID());
                        cargoCoTable.Button:RegisterCallback(Mouse.eLClick, UnitFlagClicked);

                        if (pCargoUnit == UI.GetHeadSelectedUnit()) then
                            cargoCoTable.SelectHighlight:SetHide(false);
                        end
                        if (pCargoUnit:GetOwner() ~= Game.GetActivePlayer()) then
                            cargoCoTable.GroupMark:SetHide(true);
                            cargoCoTable.Button:SetAlpha(0.6);
                        else
                            cargoCoTable.GroupMark:SetHide(false);
                            if (not pCargoUnit:CanMove()) then
                                civilianUAllCanMove = false;
                                cargoCoTable.Button:SetAlpha(0.6);
                            elseif (pCargoUnit:HasMoved()) then
                                cargoCoTable.Button:SetAlpha(0.8);
                            else
                                cargoCoTable.Button:SetAlpha(1.0);
                            end
                            if not GameInfo.Units[pCargoUnit:GetUnitType()].Suicide then
                                afCount = afCount + 1;
                                cargoCoTable.GroupMark:RegisterCallback(Mouse.eLClick,
                                    function() OnGroupSetup(_, pCargoUnit, 11, false); end);
                                if isHasPromotion then
                                    cargoCoTable.GroupMark:SetText("[ICON_BULLET]");
                                    cargoCoTable.GroupMark:LocalizeAndSetToolTip("TXT_KEY_AIRCRAFT_OFF_TT");
                                else
                                    cargoCoTable.GroupMark:SetText("[ICON_WTF1]");
                                    cargoCoTable.GroupMark:LocalizeAndSetToolTip("TXT_KEY_AIRCRAFT_ON_TT");
                                    if aFIsAllCheckSet then
                                        aFIsAllCheckSet = false;
                                    end
                                    cargoIsAllCheckSet = false;
                                end
                            else
                                gmCount = gmCount + 1;
                                cargoCoTable.GroupMark:RegisterCallback(Mouse.eLClick,
                                    function() OnGroupSetup(_, pCargoUnit, 12, false); end);
                                if isHasPromotion then
                                    cargoCoTable.GroupMark:SetText("[ICON_BULLET]");
                                    cargoCoTable.GroupMark:LocalizeAndSetToolTip("TXT_KEY_AIRCRAFT_OFF_TT");
                                else
                                    cargoCoTable.GroupMark:SetText("[ICON_WTF1]");
                                    cargoCoTable.GroupMark:LocalizeAndSetToolTip("TXT_KEY_AIRCRAFT_ON_TT");
                                    if gMIsAllCheckSet then
                                        gMIsAllCheckSet = false;
                                    end
                                    cargoIsAllCheckSet = false;
                                end
                            end
                        end
                    end
                end

                if pFirstCarriFlag == nil
                    and g_MasterList[pCarrierUnit:GetOwner()] ~= nil
                    and g_MasterList[pCarrierUnit:GetOwner()][pCarrierUnit:GetID()] ~= nil
                then
                    pFirstCarriFlag = g_MasterList[pCarrierUnit:GetOwner()][pCarrierUnit:GetID()].m_CarrierFlag;
                end

                controlTable.GroupMark:RegisterCallback(Mouse.eLClick,
                    function() OnGroupSetup(not cargoIsAllCheckSet, pCarrierUnit, 13, true); end);
                if cargoIsAllCheckSet then
                    controlTable.GroupMark:SetText("[ICON_STAR]");
                    controlTable.GroupMark:LocalizeAndSetToolTip("TXT_KEY_CARRIER_OFF_TT");
                else
                    controlTable.GroupMark:SetText("[ICON_WTF1]");
                    controlTable.GroupMark:LocalizeAndSetToolTip("TXT_KEY_CARRIER_ON_TT");
                end
            end
        end

        if pFirstCarriFlag ~= nil and pFirstCarriFlag.m_GroupControls ~= nil then
            if not isbHasGroup then
                pFirstCarriFlag.m_GroupControls.Count:SetColorByName("Beige_Black_Alpha");
            else
                pFirstCarriFlag.m_GroupControls.Count:SetColorByName("Gold_Medal");
            end
        end

        for k = 0, pPlot:GetNumUnits() - 1, 1 do
            local pOtherUnit = pPlot:GetUnit(k);
            if not (pOtherUnit:HasCargo() or pOtherUnit:IsCargo()) then
                unitCount = unitCount + 1;

                -----------------------------------------------
                -- button for the other units
                controlTable = {};
                ContextPtr:BuildInstanceForControl("UnitInstance", controlTable, g_UnitList.ListStack);

                TruncateString(controlTable.CarriName, 155,
                    Locale.ConvertTextKey("[ICON_MOVES]" .. pOtherUnit:GetName()));
                controlTable.Button:SetVoid1(pOtherUnit:GetOwner());
                controlTable.Button:SetVoid2(pOtherUnit:GetID());
                controlTable.Button:RegisterCallback(Mouse.eLClick, UnitFlagClicked);

                if (pOtherUnit == UI.GetHeadSelectedUnit()) then
                    controlTable.SelectHighlight:SetHide(false);
                end
                controlTable.GroupMark:SetHide(true);
                if (pOtherUnit:GetOwner() ~= Game.GetActivePlayer() or not pOtherUnit:CanMove()) then
                    controlTable.Button:SetAlpha(0.6);
                elseif (pOtherUnit:HasMoved()) then
                    controlTable.Button:SetAlpha(0.8);
                else
                    controlTable.Button:SetAlpha(1.0);
                end
            end
        end
    end

    if afCount > 0 and gmCount > 0 then
        g_UnitList.T1Box:SetHide(false);
        g_UnitList.T2Box:SetHide(false);
        g_UnitList.T2Label:SetText("[ICON_WAR]");
        g_UnitList.T1Label:SetText("[ICON_RANGE_STRENGTH]");
        g_UnitList.T2Check:RegisterCallback(Mouse.eLClick,
            function() OnGroupSetup(not aFIsAllCheckSet, pPlot:GetUnit(0), 11, true); end);
        g_UnitList.T1Check:RegisterCallback(Mouse.eLClick,
            function() OnGroupSetup(not gMIsAllCheckSet, pPlot:GetUnit(0), 12, true); end);
        if aFIsAllCheckSet then
            g_UnitList.T2Check:LocalizeAndSetToolTip("TXT_KEY_GROUPAF_OFF_TT");
            g_UnitList.T2Off:SetTextureOffsetVal(0, 0);
            g_UnitList.T2On:SetHide(false);
        else
            g_UnitList.T2Check:LocalizeAndSetToolTip("TXT_KEY_GROUPAF_ON_TT");
            g_UnitList.T2Off:SetTextureOffsetVal(0, 0);
            g_UnitList.T2On:SetHide(true);
        end
        if gMIsAllCheckSet then
            g_UnitList.T1Check:LocalizeAndSetToolTip("TXT_KEY_GROUPGM_OFF_TT");
            g_UnitList.T1Off:SetTextureOffsetVal(0, 0);
            g_UnitList.T1On:SetHide(false);
        else
            g_UnitList.T1Check:LocalizeAndSetToolTip("TXT_KEY_GROUPGM_ON_TT");
            g_UnitList.T1Off:SetTextureOffsetVal(0, 0);
            g_UnitList.T1On:SetHide(true);
        end
    elseif afCount > 0 then
        g_UnitList.T1Box:SetHide(false);
        g_UnitList.T2Box:SetHide(true);
        g_UnitList.T1Label:SetText("[ICON_WAR]");
        g_UnitList.T1Check:RegisterCallback(Mouse.eLClick,
            function() OnGroupSetup(not aFIsAllCheckSet, pPlot:GetUnit(0), 11, true); end);
        if aFIsAllCheckSet then
            g_UnitList.T1Check:LocalizeAndSetToolTip("TXT_KEY_GROUPAF_OFF_TT");
            g_UnitList.T1Off:SetTextureOffsetVal(0, 0);
            g_UnitList.T1On:SetHide(false);
        else
            g_UnitList.T1Check:LocalizeAndSetToolTip("TXT_KEY_GROUPAF_ON_TT");
            g_UnitList.T1Off:SetTextureOffsetVal(0, 0);
            g_UnitList.T1On:SetHide(true);
        end
    elseif gmCount > 0 then
        g_UnitList.T1Box:SetHide(false);
        g_UnitList.T2Box:SetHide(true);
        g_UnitList.T1Label:SetText("[ICON_RANGE_STRENGTH]");
        g_UnitList.T1Check:RegisterCallback(Mouse.eLClick,
            function() OnGroupSetup(not gMIsAllCheckSet, pPlot:GetUnit(0), 12, true); end);
        if gMIsAllCheckSet then
            g_UnitList.T1Check:LocalizeAndSetToolTip("TXT_KEY_GROUPGM_OFF_TT");
            g_UnitList.T1Off:SetTextureOffsetVal(0, 0);
            g_UnitList.T1On:SetHide(false);
        else
            g_UnitList.T1Check:LocalizeAndSetToolTip("TXT_KEY_GROUPGM_ON_TT");
            g_UnitList.T1Off:SetTextureOffsetVal(0, 0);
            g_UnitList.T1On:SetHide(true);
        end
    else
        g_UnitList.T1Box:SetHide(true);
        g_UnitList.T2Box:SetHide(true);
    end

    g_UnitList.ListGrid:SetSizeY(math.min(26 * unitCount + 24 + 88, 320));

    g_UnitList.ListStack:CalculateSize();
    g_UnitList.ListStack:ReprocessAnchoring();

    g_UnitList.ScrollPanel:CalculateInternalSize();

    g_UnitList.LisAnchor:ChangeParent(g_SelectedContainer);
end

function OnUISTClicked(playerID, unitID)
    if g_MasterList[playerID] == nil or g_MasterList[playerID][unitID] == nil or not g_MasterList[playerID][unitID].m_IsSelected
        or g_MasterList[playerID][unitID].m_GroupControls == nil
        or Players[playerID] == nil or Players[playerID]:GetUnitByID(unitID) == nil
    then
        return;
    end
    local pUnit = Players[playerID]:GetUnitByID(unitID);
    local pFlag = g_MasterList[playerID][unitID];
    if pFlag.m_StackOrders[1] <= 1 then
        pFlag.m_GroupControls.UISTButton:SetHide(true);
    end

    -- Hide the UnitList
    g_ListPlot = nil;
    if not g_UnitList.LisAnchor:IsHidden() then
        g_UnitList.LisAnchor:SetHide(true);
    end

    -- Set GGOption
    local IsCheckSet = pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID) or
        pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_AIR"].ID);

    -- Set Great Group
    if IsCheckSet and g_GGType ~= -1 then
        if g_GGType == 0 and not pFlag.m_GroupControls.GGBox:IsHidden() then
            OnGACTClicked(playerID, unitID);
            return;
        elseif g_GGType == 1 and not pFlag.m_GroupControls.GGBox:IsHidden() then
            OnGALLClicked(playerID, unitID);
            return;
        end
    end

    -- GroupSetup
    OnGroupSetup(not IsCheckSet, pUnit, -1, true);

    -- SetMark
    if pFlag.m_IsInGroup then
        pFlag.m_GroupControls.UISTButton:SetText("[ICON_SGM_GROUP_ON]");
        pFlag.m_GroupControls.UISTButton:LocalizeAndSetToolTip("TXT_KEY_SGM_GROUP_ON_TT");
    else
        pFlag.m_GroupControls.UISTButton:SetText("[ICON_SGM_GROUP_OFF]");
        pFlag.m_GroupControls.UISTButton:LocalizeAndSetToolTip("TXT_KEY_SGM_GROUP_OFF_TT");
    end
end

function OnGACTClicked(playerID, unitID)
    if g_MasterList[playerID] == nil or g_MasterList[playerID][unitID] == nil or not g_MasterList[playerID][unitID].m_IsSelected
        or g_MasterList[playerID][unitID].m_GroupControls == nil
        or Players[playerID] == nil or Players[playerID]:GetUnitByID(unitID) == nil
        or Players[playerID]:GetUnitByID(unitID):GetPlot() == nil
    then
        return;
    end
    local pUnit = Players[playerID]:GetUnitByID(unitID);
    local pFlag = g_MasterList[playerID][unitID];
    local pPlot = pUnit:GetPlot();
    if not pUnit:IsFriendlyUnitAdjacent() then
        pFlag.m_GroupControls.GGBox:SetHide(true);
        return;
    end

    -- Hide the UnitList
    g_ListPlot = nil;
    if not g_UnitList.LisAnchor:IsHidden() then
        g_UnitList.LisAnchor:SetHide(true);
    end

    -- Set GGOption
    local IsCheckSet = false;
    if g_GGType ~= 0 then
        g_GGPlot = pPlot;
        g_GGType = 0;
        IsCheckSet = true;
    else
        g_GGPlot = nil;
        g_GGType = -1;
    end
    if pFlag.m_StackOrders[1] <= 1 then
        if not IsCheckSet then
            pFlag.m_GroupControls.UISTButton:SetHide(true);
        else
            pFlag.m_GroupControls.UISTButton:SetHide(false);
        end
    end

    -- samUnits GroupSetup
    OnGroupSetup(false, pUnit, -1, true);
    if IsCheckSet then
        OnGroupSetup(IsCheckSet, pUnit, pFlag.m_CombatType, true);
    end

    -- adjUnits GroupSetup
    for direction = 0, 5 do
        local adjPlot = Map.PlotDirection(pPlot:GetX(), pPlot:GetY(), direction);
        if adjPlot and adjPlot:GetNumUnits() > 0 then
            local adjUnit = adjPlot:GetUnit(0);
            if g_MasterList[adjUnit:GetOwner()] ~= nil
                and g_MasterList[adjUnit:GetOwner()][adjUnit:GetID()] ~= nil
            then
                local adjFlag = g_MasterList[adjUnit:GetOwner()][adjUnit:GetID()];
                OnGroupSetup(false, adjUnit, -1, true);
                if IsCheckSet then
                    OnGroupSetup(IsCheckSet, adjUnit, pFlag.m_CombatType, true);
                end
            end
        end
    end
    if g_GGType == 0 then
        pFlag.m_GGMPlot = pPlot;
    end

    -- SetMark & for "7" Group
    if not pFlag.m_IsInGroup then
        pFlag.m_GroupControls.UISTButton:SetText("[ICON_SGM_GROUP_OFF]");
        pFlag.m_GroupControls.GACTButton:SetText("[ICON_SGM_GROUP_ACT_OFF]");
        pFlag.m_GroupControls.GALLButton:SetText("[ICON_SGM_GROUP_ALL_OFF]");
        pFlag.m_GroupControls.UISTButton:LocalizeAndSetToolTip("TXT_KEY_SGM_GROUP_OFF_TT");
        pFlag.m_GroupControls.GACTButton:LocalizeAndSetToolTip("TXT_KEY_SGM_GROUP_ACT_OFF_TT");
        pFlag.m_GroupControls.GALLButton:LocalizeAndSetToolTip("TXT_KEY_SGM_GROUP_ALL_OFF_TT");
    else
        pFlag.m_GroupControls.UISTButton:SetText("[ICON_SGM_GROUP_ON]");
        pFlag.m_GroupControls.GACTButton:SetText("[ICON_SGM_GROUP_ACT_ON]");
        pFlag.m_GroupControls.GALLButton:SetText("[ICON_SGM_GROUP_ALL_OFF]");
        pFlag.m_GroupControls.UISTButton:LocalizeAndSetToolTip("TXT_KEY_SGM_GROUP_ON_TT");
        pFlag.m_GroupControls.GACTButton:LocalizeAndSetToolTip("TXT_KEY_SGM_GROUP_ALL_ON_TT");
        pFlag.m_GroupControls.GALLButton:LocalizeAndSetToolTip("TXT_KEY_SGM_GROUP_ALL_OFF_TT");
    end
end

function OnGALLClicked(playerID, unitID)
    if g_MasterList[playerID] == nil or g_MasterList[playerID][unitID] == nil or not g_MasterList[playerID][unitID].m_IsSelected
        or g_MasterList[playerID][unitID].m_GroupControls == nil
        or Players[playerID] == nil or Players[playerID]:GetUnitByID(unitID) == nil
        or Players[playerID]:GetUnitByID(unitID):GetPlot() == nil
    then
        return;
    end
    local pUnit = Players[playerID]:GetUnitByID(unitID);
    local pFlag = g_MasterList[playerID][unitID];
    local pPlot = pUnit:GetPlot();
    if not pUnit:IsFriendlyUnitAdjacent() then
        pFlag.m_GroupControls.GGBox:SetHide(true);
        return;
    end

    -- Hide the UnitList
    g_ListPlot = nil;
    if not g_UnitList.LisAnchor:IsHidden() then
        g_UnitList.LisAnchor:SetHide(true);
    end

    -- Set GGOption
    local IsCheckSet = false;
    if g_GGType ~= 1 then
        g_GGPlot = pPlot;
        g_GGType = 1;
        IsCheckSet = true;
    else
        g_GGPlot = nil;
        g_GGType = -1;
    end
    if pFlag.m_StackOrders[1] <= 1 then
        if not IsCheckSet then
            pFlag.m_GroupControls.UISTButton:SetHide(true);
        else
            pFlag.m_GroupControls.UISTButton:SetHide(false);
        end
    end

    -- allUnits GroupSetup
    if not pFlag.m_IsAirCraft then
        OnGroupSetup(IsCheckSet, pUnit, -1, true);
    else
        OnGroupSetup(IsCheckSet, pUnit, pFlag.m_CombatType, true);
    end

    -- adjUnits GroupSetup
    for direction = 0, 5 do
        local adjPlot = Map.PlotDirection(pPlot:GetX(), pPlot:GetY(), direction);
        if adjPlot and adjPlot:GetNumUnits() > 0 then
            local adjUnit = adjPlot:GetUnit(0);
            if g_MasterList[adjUnit:GetOwner()] ~= nil
                and g_MasterList[adjUnit:GetOwner()][adjUnit:GetID()] ~= nil
            then
                local adjFlag = g_MasterList[adjUnit:GetOwner()][adjUnit:GetID()];
                if not pFlag.m_IsAirCraft then
                    OnGroupSetup(IsCheckSet, adjUnit, -1, true);
                else
                    OnGroupSetup(IsCheckSet, adjUnit, pFlag.m_CombatType, true);
                end
            end
        end
    end
    if g_GGType == 1 then
        pFlag.m_GGMPlot = pPlot;
    end

    -- SetMark for "7" Group
    if not pFlag.m_IsInGroup then
        pFlag.m_GroupControls.UISTButton:SetText("[ICON_SGM_GROUP_OFF]");
        pFlag.m_GroupControls.GACTButton:SetText("[ICON_SGM_GROUP_ACT_OFF]");
        pFlag.m_GroupControls.GALLButton:SetText("[ICON_SGM_GROUP_ALL_OFF]");
        pFlag.m_GroupControls.UISTButton:LocalizeAndSetToolTip("TXT_KEY_SGM_GROUP_OFF_TT");
        pFlag.m_GroupControls.GACTButton:LocalizeAndSetToolTip("TXT_KEY_SGM_GROUP_ACT_OFF_TT");
        pFlag.m_GroupControls.GALLButton:LocalizeAndSetToolTip("TXT_KEY_SGM_GROUP_ALL_OFF_TT");
    else
        pFlag.m_GroupControls.UISTButton:SetText("[ICON_SGM_GROUP_ON]");
        pFlag.m_GroupControls.GACTButton:SetText("[ICON_SGM_GROUP_ACT_OFF]");
        pFlag.m_GroupControls.GALLButton:SetText("[ICON_SGM_GROUP_ALL_ON]");
        pFlag.m_GroupControls.UISTButton:LocalizeAndSetToolTip("TXT_KEY_SGM_GROUP_ON_TT");
        pFlag.m_GroupControls.GACTButton:LocalizeAndSetToolTip("TXT_KEY_SGM_GROUP_ACT_OFF_TT");
        pFlag.m_GroupControls.GALLButton:LocalizeAndSetToolTip("TXT_KEY_SGM_GROUP_ALL_ON_TT");
    end
end

function OnCloseUnitList()
    g_ListPlot = nil;
    if not g_UnitList.LisAnchor:IsHidden() then
        g_UnitList.LisAnchor:SetHide(true);
    end
end

Events.UnitShouldDimFlag.Add(OnCloseUnitList);

-------------------------------------------------
-- On Unit Created
-------------------------------------------------
function OnUnitCreated(playerID, unitID, hexVec, unitType, cultureType, civID, primaryColor, secondaryColor,
                       unitFlagIndex, fogState, selected, military, notInvisible)
    if (Players[playerID] == nil or
        Players[playerID]:GetUnitByID(unitID) == nil or
        Players[playerID]:GetUnitByID(unitID):IsDead())
    then
        return;
    end

    -- support for debug panel
    g_LastPlayerID = playerID;
    g_LastUnitID   = unitID;

    if (g_PrintDebug) then print("  Unit Created: " ..
        tostring(playerID) .. " " .. tostring(unitID) .. " " .. fogState); end

    g_UnitFlagClass:new(playerID, unitID, fogState, not notInvisible);
end

Events.SerialEventUnitCreated.Add(OnUnitCreated);



-------------------------------------------------
-- On Unit Position Changed
-- sent by the engine while it walks a unit around
-------------------------------------------------
function OnUnitPositionChanged(playerID, unitID, unitPosition)
    if (Players[playerID] == nil or
        not Players[playerID]:IsAlive())
    --Players[ playerID ]:GetUnitByID( unitID ) == nil or
    --Players[ playerID ]:GetUnitByID( unitID ):IsDead() )
    then
        return;
    end

    if (g_MasterList[playerID] == nil or
        g_MasterList[playerID][unitID] == nil)
    then
        --print( string.format( "Unit not found for OnUnitMove: Player[%i] Unit[%i]", playerID, unitID ) );
    else
        local pUnit = Players[playerID]:GetUnitByID(unitID);
        if (pUnit ~= nil and pUnit:IsGarrisoned()) then
            -- When garrisoned, we want to line up the icon with the city banner.
            -- Some units sit at different heights, so repostion the icon world position to match the city banner
            local worldPosX, worldPosY, worldPosZ = GridToWorld(pUnit:GetX(), pUnit:GetY());
            unitPosition.z = worldPosZ;
        end

        local position = VecAdd(unitPosition, CityWorldPositionOffset);

        g_MasterList[playerID][unitID]:UnitMove(position.x, position.y, position.z);
    end
end

Events.LocalMachineUnitPositionChanged.Add(OnUnitPositionChanged);



--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function OnFlagTypeChange(playerID, unitID)
    if (Players[playerID] == nil or
        not Players[playerID]:IsAlive() or
        Players[playerID]:GetUnitByID(unitID) == nil or
        Players[playerID]:GetUnitByID(unitID):IsDead())
    then
        return;
    end

    if (g_MasterList[playerID] == nil or
        g_MasterList[playerID][unitID] == nil)
    then
        --print( string.format( "Unit not found for OnFlagTypeChange: Player[%i] Unit[%i]", playerID, unitID ) );
    else
        local unit = g_MasterList[playerID][unitID];
        unit:UpdateFlagType();
        unit:UpdateFlagOffset();
    end
end

Events.UnitActionChanged.Add(OnFlagTypeChange);
Events.UnitEmbark.Add(OnFlagTypeChange);


-------------------------------------------------
-- nukes teleport instead of moving
-------------------------------------------------
function OnUnitTeleported(i, j, playerID, unitID)
    -- spoof out the move queue changed logic.
    OnUnitMoveQueueChanged(playerID, unitID, false);
end

Events.SerialEventUnitTeleportedToHex.Add(OnUnitTeleported);


-------------------------------------------------
-- On Unit Move Queue Changed
-------------------------------------------------
function OnUnitMoveQueueChanged(playerID, unitID, bRemainingMoves)
    if (not bRemainingMoves) then
        if (Players[playerID] ~= nil and Players[playerID]:GetUnitByID(unitID) ~= nil
            and Players[playerID]:GetUnitByID(unitID):GetPlot() ~= nil
            and g_MasterList[playerID] ~= nil and g_MasterList[playerID][unitID] ~= nil
            and g_MasterList[playerID][unitID].m_Escort ~= nil)
        then
            local thisUnit = Players[playerID]:GetUnitByID(unitID);
            local flag = g_MasterList[playerID][unitID];
            local pPlot = thisUnit:GetPlot();
            local pAirCraftState = CheckPlot(flag.m_Escort);

            if flag.m_Escort:IsCity() then
                if flag.m_IsAirCraft then
                    UpdateCityCargo(flag.m_Escort, pAirCraftState);
                else
                    flag:GarrisonComplete(thisUnit:IsGarrisoned());
                end
            end

            if flag.m_Escort ~= pPlot then
                -- Group Move or Rebase!
                if thisUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID)
                    or (thisUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_AIR"].ID) and not thisUnit:CanMove())
                then
                    if thisUnit:IsCargo() and thisUnit:GetTransportUnit() ~= nil and g_MasterList[thisUnit:GetTransportUnit():GetOwner()] ~= nil
                        and g_MasterList[thisUnit:GetTransportUnit():GetOwner()][thisUnit:GetTransportUnit():GetID()] ~= nil
                        and g_MasterList[thisUnit:GetTransportUnit():GetOwner()][thisUnit:GetTransportUnit():GetID()].m_Escort ~= pPlot
                    then
                    else
                        GroupMove(thisUnit, flag.m_Escort);
                    end
                end

                -- Moved Citadel Unit will be destroyed!
                if flag.m_SPUnitType == 1 then
                    thisUnit:Kill();
                    return;
                end
                flag.m_Escort = pPlot;

                if flag.m_GroupControls then
                    if flag.m_CarrierFlag ~= nil then
                        flag.m_GroupControls.AirButton:SetVoid1(pPlot:GetX());
                        flag.m_GroupControls.AirButton:SetVoid2(pPlot:GetY());
                    end

                    if not g_IsDoingGG and playerID == Game.GetActivePlayer() then
                        g_HasMove = true;
                    end
                end
                pAirCraftState = CheckPlot(pPlot);

                if pPlot:IsCity() then
                    if flag.m_IsAirCraft then
                        UpdateCityCargo(pPlot, pAirCraftState);
                    else
                        flag:GarrisonComplete(thisUnit:IsGarrisoned());
                    end
                end
            end
        end
    end
end

Events.UnitMoveQueueChanged.Add(OnUnitMoveQueueChanged);


-------------------------------------------------
-------------------------------------------------
-- Group Orders
local G_ExcludeSuicide = false;
local g_DoGroupAlertUnit = nil;
local g_DoGroupDWakeUnit = nil;
local g_DoGroupCaMisUnit = nil;
local g_DoGroupSetUpUnit = nil;

function OnGroupStateClear()
    local thisUnit = UI.GetHeadSelectedUnit();
    if not Players[Game.GetActivePlayer()]:IsTurnActive() then
        return;
    end

    if g_DoGroupAlertUnit ~= nil and g_DoGroupAlertUnit ~= thisUnit then
        g_DoGroupAlertUnit = nil;
    end
    if g_DoGroupDWakeUnit ~= nil and g_DoGroupDWakeUnit ~= thisUnit then
        g_DoGroupDWakeUnit = nil;
    end
    if g_DoGroupSetUpUnit ~= nil and g_DoGroupSetUpUnit ~= thisUnit then
        g_DoGroupSetUpUnit = nil;
    end
    if g_DoGroupCaMisUnit ~= nil and g_DoGroupCaMisUnit ~= thisUnit then
        if not g_DoGroupCaMisUnit:CanDoCommand(CommandTypes.COMMAND_CANCEL) then
            GroupCanMis(g_DoGroupCaMisUnit);
        end
        g_DoGroupCaMisUnit = nil;
    end
end

Events.UnitSelectionChanged.Add(OnGroupStateClear);
Events.UnitSelectionCleared.Add(OnGroupStateClear);

function OnGroupTurnPlayerEnd()
    G_ExcludeSuicide = false;
    g_DoGroupAlertUnit = nil;
    g_DoGroupDWakeUnit = nil;
    g_DoGroupCaMisUnit = nil;
    g_DoGroupSetUpUnit = nil;

    -- "7" Group
    g_IsDoingGG = false;
end

Events.ActivePlayerTurnEnd.Add(OnGroupTurnPlayerEnd);

function OnGroupStateChange()
    local thisUnit = UI.GetHeadSelectedUnit();
    if thisUnit == nil then
        return;
    end

    if Players[Game.GetActivePlayer()]:IsTurnActive()
        and (thisUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID)
        or thisUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_AIR"].ID))
    then
        -- Alert & Wake
        if thisUnit:GetActivityType() == 2 or thisUnit:GetActivityType() == 3
            or thisUnit:GetActivityType() == 4 or thisUnit:GetActivityType() == 5
        then
            if g_DoGroupDWakeUnit == nil then
                g_DoGroupDWakeUnit = thisUnit;
            end
            if thisUnit == g_DoGroupAlertUnit then
                GroupAlert(thisUnit);
                g_DoGroupAlertUnit = nil;
            end
        elseif thisUnit:GetActivityType() == 0 or thisUnit:GetActivityType() == 1 then
            if thisUnit == g_DoGroupDWakeUnit then
                GroupWake(thisUnit);
                g_DoGroupDWakeUnit = nil;
            end
            if g_DoGroupAlertUnit == nil then
                g_DoGroupAlertUnit = thisUnit;
            end
        end

        -- SetUP to Ranged Attack
        if thisUnit:IsMustSetUpToRangedAttack() then
            if g_DoGroupSetUpUnit == nil and not thisUnit:IsSetUpForRangedAttack() then
                g_DoGroupSetUpUnit = thisUnit;
            end
            if thisUnit == g_DoGroupSetUpUnit and thisUnit:IsSetUpForRangedAttack() then
                GroupSetUP(thisUnit);
                g_DoGroupSetUpUnit = nil;
            end
        end

        -- Cancel Mission
        if thisUnit:CanDoCommand(CommandTypes.COMMAND_CANCEL) then
            if g_DoGroupCaMisUnit == nil then
                g_DoGroupCaMisUnit = thisUnit;
            end
        elseif g_DoGroupCaMisUnit ~= nil then
            if not g_DoGroupCaMisUnit:CanDoCommand(CommandTypes.COMMAND_CANCEL) then
                GroupCanMis(g_DoGroupCaMisUnit);
            end
            g_DoGroupCaMisUnit = nil;
        end
    end
end

Events.SerialEventUnitInfoDirty.Add(OnGroupStateChange);

function ExcludeSuicide(iPlayerID, iUnitID)
    if Players[Game.GetActivePlayer()]:IsTurnActive() and iPlayerID == Game.GetActivePlayer()
        and g_MasterList[iPlayerID] ~= nil and g_MasterList[iPlayerID][iUnitID] ~= nil
        and g_MasterList[iPlayerID][iUnitID].m_IsAirCraft and g_MasterList[iPlayerID][iUnitID].m_IsInGroup
        and not G_ExcludeSuicide
    then
        G_ExcludeSuicide = true;
    end
end

Events.SerialEventUnitDestroyed.Add(ExcludeSuicide);
function GroupCombatCity(iPlayerID, iCityID)
    if not Players[Game.GetActivePlayer()]:IsTurnActive() or iPlayerID == Game.GetActivePlayer() or Players[iPlayerID] == nil or Players[iPlayerID]:GetCityByID(iCityID) == nil then
        return;
    end

    local pOUnit = nil;
    if G_ExcludeSuicide then
        G_ExcludeSuicide = false;
    else
        pOUnit = UI.GetHeadSelectedUnit();
    end
    local pTCity = Players[iPlayerID]:GetCityByID(iCityID);
    local pTPlot = pTCity:Plot();
    if pOUnit ~= nil and pTPlot ~= nil and not GameInfo.Units[pOUnit:GetUnitType()].Suicide
        and (pOUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID)
        or pOUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_AIR"].ID))
    then
        GroupCombat(pOUnit, pTPlot, pTCity);
    end
end

Events.SerialEventCitySetDamage.Add(GroupCombatCity);
function GroupCombatUnit(iPlayerID, iUnitID)
    if not Players[Game.GetActivePlayer()]:IsTurnActive() or iPlayerID == Game.GetActivePlayer() or g_MasterList[iPlayerID] == nil or g_MasterList[iPlayerID][iUnitID] == nil then
        return;
    end

    local pOUnit = nil;
    if G_ExcludeSuicide then
        G_ExcludeSuicide = false;
    else
        pOUnit = UI.GetHeadSelectedUnit();
    end
    local pTFlag = g_MasterList[iPlayerID][iUnitID];
    local pTPlot = pTFlag.m_Escort;
    if pOUnit ~= nil and pTPlot ~= nil and not GameInfo.Units[pOUnit:GetUnitType()].Suicide
        and (pOUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID)
        or pOUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_AIR"].ID))
    then
        GroupCombat(pOUnit, pTPlot, pTFlag);
    end
end

Events.SerialEventUnitSetDamage.Add(GroupCombatUnit);
Events.SerialEventUnitDestroyed.Add(GroupCombatUnit);

function GroupUpgradeUnit(iPlayerID, iUnitID)
    g_IsDoingGG = true;
    if not Players[Game.GetActivePlayer()]:IsTurnActive() or iPlayerID ~= Game.GetActivePlayer()
        or Players[iPlayerID] == nil or Players[iPlayerID]:GetUnitByID(iUnitID) == nil
        or Players[iPlayerID]:GetUnitByID(iUnitID):GetPlot() == nil
        or (Players[iPlayerID]:GetUnitByID(iUnitID):IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID)
        and not Players[iPlayerID]:GetUnitByID(iUnitID):IsCombatUnit())
        or (not Players[iPlayerID]:GetUnitByID(iUnitID):IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID)
        and not Players[iPlayerID]:GetUnitByID(iUnitID):IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_AIR"].ID))
    then
        g_IsDoingGG = false;
        return;
    end
    local pUnit = Players[iPlayerID]:GetUnitByID(iUnitID);
    local pPlot = pUnit:GetPlot();

    if pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID) then
        pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID, false);
    elseif pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_AIR"].ID) then
        pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_AIR"].ID, false);
    end
    if pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_I"].ID) then
        if PromotionIGNORETERRAINCOST then pUnit:SetHasPromotion(PromotionIGNORETERRAINCOST.ID, true) end
        ;
        pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_I"].ID, false);
    end
    if pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_II"].ID) then
        if PromotionALTITUDETRAINING then pUnit:SetHasPromotion(PromotionALTITUDETRAINING.ID, true) end
        ;
        pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_II"].ID, false);
    end
    if pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_III"].ID) then
        if PromotionWOODSMAN then pUnit:SetHasPromotion(PromotionWOODSMAN.ID, true) end
        ;
        pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_III"].ID, false);
    end
    if pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_IV"].ID) then
        if PromotionSTEAMPOWERED then pUnit:SetHasPromotion(PromotionSTEAMPOWERED.ID, true) end
        ;
        pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_IV"].ID, false);
    end
    if pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_V"].ID) then
        if PromotionSKIINFANTRY then pUnit:SetHasPromotion(PromotionSKIINFANTRY.ID, true) end
        ;
        pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_V"].ID, false);
    end
    if pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_VI"].ID) then
        if PromotionHOVERINGUNIT then pUnit:SetHasPromotion(PromotionHOVERINGUNIT.ID, true) end
        ;
        pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_VI"].ID, false);
    end
    if pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_VII"].ID) then
        if PromotionLIGHTNINGWARFARE then pUnit:SetHasPromotion(PromotionLIGHTNINGWARFARE.ID, true) end
        ;
        pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_VII"].ID, false);
    end
    if pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_VII_FS"].ID) then
        if PromotionFIRSTSTRIKE then pUnit:SetHasPromotion(PromotionFIRSTSTRIKE.ID, true) end
        ;
        pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_VII_FS"].ID, false);
    end

    for i = pPlot:GetNumUnits() - 1, 0, -1 do
        local pUpgradeUnit = pPlot:GetUnit(i);
        if pUpgradeUnit ~= pUnit and pUpgradeUnit:CanMove() and pUpgradeUnit:CanDoCommand(CommandTypes.COMMAND_UPGRADE) and not pUpgradeUnit:IsDead() and not pUpgradeUnit:IsDelayedDeath()
            and (pUpgradeUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID) or pUpgradeUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_AIR"].ID))
        then
            pUpgradeUnit:DoCommand(CommandTypes.COMMAND_UPGRADE);
            return;
        end
    end

    -- "7" Group
    if g_GGPlot and g_GGType ~= -1 then
        for direction = 0, 5 do
            local adjPlot = Map.PlotDirection(g_GGPlot:GetX(), g_GGPlot:GetY(), direction);
            if adjPlot and adjPlot:GetNumUnits() > 0 then
                for i = adjPlot:GetNumUnits() - 1, 0, -1 do
                    local adjUnit = adjPlot:GetUnit(i);
                    if adjUnit:CanMove() and adjUnit:CanDoCommand(CommandTypes.COMMAND_UPGRADE) and not adjUnit:IsDead() and not adjUnit:IsDelayedDeath()
                        and (adjUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID)) -- or adjUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_AIR"].ID))
                    then
                        adjUnit:DoCommand(CommandTypes.COMMAND_UPGRADE);
                        return;
                    end
                end
            end
        end
    end
    g_IsDoingGG = false;
    local pSelectedUnit = UI.GetHeadSelectedUnit();
    if pSelectedUnit and g_MasterList[pSelectedUnit:GetOwner()] ~= nil and g_MasterList[pSelectedUnit:GetOwner()][pSelectedUnit:GetID()] ~= nil
        and g_MasterList[pSelectedUnit:GetOwner()][pSelectedUnit:GetID()].m_IsSelected
    then
        g_MasterList[pSelectedUnit:GetOwner()][pSelectedUnit:GetID()]:UpdateSelected(true);
    end
end

Events.SerialEventUnitCreated.Add(GroupUpgradeUnit)

-------------------------------------------------
function GroupAlert(pOUnit)
    -- Alert or Sleep
    if pOUnit == nil or pOUnit:GetPlot() == nil then
        return;
    end
    local pPlot = pOUnit:GetPlot();
    if pOUnit:GetDomainType() ~= DomainTypes.DOMAIN_AIR then
        for i = 0, pPlot:GetNumUnits() - 1 do
            local pUnit = pPlot:GetUnit(i);
            if pUnit ~= pOUnit and pUnit:CanMove() and pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID) then
                if pUnit:CanDoCommand(CommandTypes.COMMAND_WAKE) then
                    pUnit:DoCommand(CommandTypes.COMMAND_WAKE);
                end
                if pUnit:CanStartMission(GameInfoTypes.MISSION_HEAL) then
                    pUnit:PushMission(GameInfoTypes.MISSION_HEAL);
                elseif pUnit:CanStartMission(GameInfoTypes.MISSION_ALERT) then
                    pUnit:PushMission(GameInfoTypes.MISSION_ALERT);
                else
                    pUnit:PushMission(GameInfoTypes.MISSION_SLEEP);
                end
            end
        end
    else
        for i = 0, pPlot:GetNumUnits() - 1 do
            local pUnit = pPlot:GetUnit(i);
            if pUnit ~= pOUnit and pUnit:CanMove() and pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_AIR"].ID) then
                if pUnit:CanDoCommand(CommandTypes.COMMAND_WAKE) then
                    pUnit:DoCommand(CommandTypes.COMMAND_WAKE);
                end
                if pUnit:CanStartMission(GameInfoTypes.MISSION_HEAL) then
                    pUnit:PushMission(GameInfoTypes.MISSION_HEAL);
                elseif pUnit:CanStartMission(GameInfoTypes.MISSION_AIRPATROL) then
                    pUnit:PushMission(GameInfoTypes.MISSION_AIRPATROL);
                else
                    pUnit:PushMission(GameInfoTypes.MISSION_SLEEP);
                end
            end
        end
    end

    -- "7" Group
    if g_GGPlot and g_GGType ~= -1 then
        for direction = 0, 5 do
            local adjPlot = Map.PlotDirection(g_GGPlot:GetX(), g_GGPlot:GetY(), direction);
            if adjPlot and adjPlot:GetNumUnits() > 0 then
                if pOUnit:GetDomainType() ~= DomainTypes.DOMAIN_AIR then
                    for i = 0, adjPlot:GetNumUnits() - 1 do
                        local adjUnit = adjPlot:GetUnit(i);
                        if adjUnit:CanMove() and adjUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID) then
                            if adjUnit:CanDoCommand(CommandTypes.COMMAND_WAKE) then
                                adjUnit:DoCommand(CommandTypes.COMMAND_WAKE);
                            end
                            if adjUnit:CanStartMission(GameInfoTypes.MISSION_HEAL) then
                                adjUnit:PushMission(GameInfoTypes.MISSION_HEAL);
                            elseif adjUnit:CanStartMission(GameInfoTypes.MISSION_ALERT) then
                                adjUnit:PushMission(GameInfoTypes.MISSION_ALERT);
                            else
                                adjUnit:PushMission(GameInfoTypes.MISSION_SLEEP);
                            end
                        end
                    end
                    --[[
				else
					for i = 0, adjPlot:GetNumUnits() - 1 do
						local adjUnit = adjPlot:GetUnit( i );
						if adjUnit:CanMove() and adjUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_AIR"].ID) then
							if     adjUnit:CanDoCommand(CommandTypes.COMMAND_WAKE) then
								adjUnit:DoCommand(CommandTypes.COMMAND_WAKE);
							end
							if     adjUnit:CanStartMission(GameInfoTypes.MISSION_HEAL) then
								adjUnit:PushMission(GameInfoTypes.MISSION_HEAL);
							elseif adjUnit:CanStartMission(GameInfoTypes.MISSION_AIRPATROL) then
								adjUnit:PushMission(GameInfoTypes.MISSION_AIRPATROL);
							else
								adjUnit:PushMission(GameInfoTypes.MISSION_SLEEP);
							end
						end
					end
				]]
                end
            end
        end
    end
end

function GroupWake(pOUnit)
    -- Wake
    if pOUnit == nil or pOUnit:GetPlot() == nil then
        return;
    end
    local pPlot = pOUnit:GetPlot();
    if pOUnit:GetDomainType() ~= DomainTypes.DOMAIN_AIR then
        for i = 0, pPlot:GetNumUnits() - 1 do
            local pUnit = pPlot:GetUnit(i);
            if pUnit ~= pOUnit and pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID) then
                if (pUnit:CanDoCommand(CommandTypes.COMMAND_WAKE)) then
                    pUnit:DoCommand(CommandTypes.COMMAND_WAKE);
                end
            end
        end
    else
        for i = 0, pPlot:GetNumUnits() - 1 do
            local pUnit = pPlot:GetUnit(i);
            if pUnit ~= pOUnit and pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_AIR"].ID) then
                if (pUnit:CanDoCommand(CommandTypes.COMMAND_WAKE)) then
                    pUnit:DoCommand(CommandTypes.COMMAND_WAKE);
                end
            end
        end
    end

    -- "7" Group
    if g_GGPlot and g_GGType ~= -1 then
        for direction = 0, 5 do
            local adjPlot = Map.PlotDirection(g_GGPlot:GetX(), g_GGPlot:GetY(), direction);
            if adjPlot and adjPlot:GetNumUnits() > 0 then
                if pOUnit:GetDomainType() ~= DomainTypes.DOMAIN_AIR then
                    for i = 0, adjPlot:GetNumUnits() - 1 do
                        local adjUnit = adjPlot:GetUnit(i);
                        if adjUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID) then
                            if (adjUnit:CanDoCommand(CommandTypes.COMMAND_WAKE)) then
                                adjUnit:DoCommand(CommandTypes.COMMAND_WAKE);
                            end
                        end
                    end
                    --[[
				else
					for i = 0, adjPlot:GetNumUnits() - 1 do
						local adjUnit = adjPlot:GetUnit( i );
						if adjUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_AIR"].ID) then
							if ( adjUnit:CanDoCommand(CommandTypes.COMMAND_WAKE) ) then
								adjUnit:DoCommand(CommandTypes.COMMAND_WAKE);
							end
						end
					end
				]]
                end
            end
        end
    end
end

function GroupCanMis(pOUnit)
    -- Cancel Mission
    if pOUnit == nil or pOUnit:GetPlot() == nil then
        return;
    end
    local pPlot = pOUnit:GetPlot();
    if pOUnit:GetDomainType() ~= DomainTypes.DOMAIN_AIR then
        for i = 0, pPlot:GetNumUnits() - 1 do
            local pUnit = pPlot:GetUnit(i);
            if pUnit ~= pOUnit and pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID) then
                if (pUnit:CanDoCommand(CommandTypes.COMMAND_CANCEL) and pUnit:GetBuildType() == -1) then
                    pUnit:DoCommand(CommandTypes.COMMAND_CANCEL);
                end
            end
        end
    else
        for i = 0, pPlot:GetNumUnits() - 1 do
            local pUnit = pPlot:GetUnit(i);
            if pUnit ~= pOUnit and pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_AIR"].ID) then
                if (pUnit:CanDoCommand(CommandTypes.COMMAND_CANCEL)) then
                    pUnit:DoCommand(CommandTypes.COMMAND_CANCEL);
                end
            end
        end
    end

    -- "7" Group
    if g_GGPlot and g_GGType ~= -1 then
        for direction = 0, 5 do
            local adjPlot = Map.PlotDirection(g_GGPlot:GetX(), g_GGPlot:GetY(), direction);
            if adjPlot and adjPlot:GetNumUnits() > 0 then
                if pOUnit:GetDomainType() ~= DomainTypes.DOMAIN_AIR then
                    for i = 0, adjPlot:GetNumUnits() - 1 do
                        local adjUnit = adjPlot:GetUnit(i);
                        if adjUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID) then
                            if (adjUnit:CanDoCommand(CommandTypes.COMMAND_CANCEL) and adjUnit:GetBuildType() == -1) then
                                adjUnit:DoCommand(CommandTypes.COMMAND_CANCEL);
                            end
                        end
                    end
                    --[[
				else
					for i = 0, adjPlot:GetNumUnits() - 1 do
						local adjUnit = adjPlot:GetUnit( i );
						if adjUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_AIR"].ID) then
							if ( adjUnit:CanDoCommand(CommandTypes.COMMAND_CANCEL) ) then
								adjUnit:DoCommand(CommandTypes.COMMAND_CANCEL);
							end
						end
					end
				]]
                end
            end
        end
    end
end

function GroupSetUP(pOUnit)
    -- SetUp
    if pOUnit == nil or pOUnit:GetPlot() == nil then
        return;
    end
    local pPlot = pOUnit:GetPlot();
    for i = 0, pPlot:GetNumUnits() - 1 do
        local pUnit = pPlot:GetUnit(i);
        if pUnit and pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID) then
            RemoveGroupMark(pUnit);
            if pUnit:CanMove() and pUnit:CanStartMission(GameInfoTypes.MISSION_SET_UP_FOR_RANGED_ATTACK) then
                pUnit:PushMission(GameInfoTypes.MISSION_SET_UP_FOR_RANGED_ATTACK);
            end
        end
    end

    -- "7" Group
    if g_GGPlot and g_GGType ~= -1 then
        for direction = 0, 5 do
            local adjPlot = Map.PlotDirection(g_GGPlot:GetX(), g_GGPlot:GetY(), direction);
            if adjPlot and adjPlot:GetNumUnits() > 0 then
                for i = 0, adjPlot:GetNumUnits() - 1 do
                    local adjUnit = adjPlot:GetUnit(i);
                    if adjUnit and adjUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID) then
                        RemoveGroupMark(adjUnit);
                        if adjUnit:CanMove() and adjUnit:CanStartMission(GameInfoTypes.MISSION_SET_UP_FOR_RANGED_ATTACK) then
                            adjUnit:PushMission(GameInfoTypes.MISSION_SET_UP_FOR_RANGED_ATTACK);
                        end
                    end
                end
                OnGroupMoveSet(adjPlot);
            end
        end
    end
    OnGroupMoveSet(pPlot);
end


function GroupMove(pOUnit, pOldPlot)
    -- Move or Rebase
    if pOUnit == nil or pOUnit:GetPlot() == nil or pOldPlot == nil then
        return;
    end
    local pLastMissionPlot = pOUnit:LastMissionPlot();
    if pLastMissionPlot ~= nil and pLastMissionPlot ~= pOldPlot
        and g_MasterList[pOUnit:GetOwner()] ~= nil and g_MasterList[pOUnit:GetOwner()][pOUnit:GetID()] ~= nil
    then
        local pOFlag = g_MasterList[pOUnit:GetOwner()][pOUnit:GetID()];
        if pOUnit:GetDomainType() ~= DomainTypes.DOMAIN_AIR then
            -- Exclude Airlift or Paradrop
            if Map.PlotDistance(pOUnit:GetPlot():GetX(), pOUnit:GetPlot():GetY(), pOldPlot:GetX(), pOldPlot:GetY())
                > pOUnit:MaxMoves() / GameDefines["MOVE_DENOMINATOR"]
            then
                g_IsDoingGG = false;
                return;
            end

            -- the "GGFlag" Unit has Moved - Set its self, same & adjacency Plots Units!
            if g_GGPlot and g_GGType ~= -1 and pOFlag.m_GGMPlot == pOldPlot then
                -- Self
                pOFlag.m_GGMPlot = pLastMissionPlot;

                -- Same
                for i = 0, pOldPlot:GetNumUnits() - 1 do
                    local sUnit = pOldPlot:GetUnit(i);
                    if sUnit ~= nil and sUnit ~= pOUnit
                        and sUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID)
                        and g_MasterList[sUnit:GetOwner()] ~= nil
                        and g_MasterList[sUnit:GetOwner()][sUnit:GetID()] ~= nil
                    then
                        local sFlag = g_MasterList[sUnit:GetOwner()][sUnit:GetID()];
                        sFlag.m_GGMPlot = pLastMissionPlot;
                    end
                end

                -- Adjacency
                for direction = 0, 5 do
                    local adjPlot   = Map.PlotDirection(g_GGPlot:GetX(), g_GGPlot:GetY(), direction);
                    local adjLMPlot = nil;
                    if adjPlot and adjPlot:GetNumUnits() > 0 then
                        for i = 0, adjPlot:GetNumUnits() - 1 do
                            local adjUnit = adjPlot:GetUnit(i);
                            if adjUnit ~= nil and adjUnit ~= pOUnit
                                and g_MasterList[adjUnit:GetOwner()] ~= nil
                                and g_MasterList[adjUnit:GetOwner()][adjUnit:GetID()] ~= nil
                            then
                                local adjFlag = g_MasterList[adjUnit:GetOwner()][adjUnit:GetID()];

                                if not adjUnit:CanMove() or adjUnit == pOUnit or not adjUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID)
                                    or (adjUnit:GetDomainType() ~= pOUnit:GetDomainType() and adjUnit:IsEmbarked() == pOUnit:IsEmbarked())
                                    or (adjUnit:GetDomainType() == pOUnit:GetDomainType() and adjUnit:IsEmbarked() ~= pOUnit:IsEmbarked())
                                then
                                    adjLMPlot = nil;
                                else
                                    adjLMPlot = Map.PlotDirection(pLastMissionPlot:GetX(), pLastMissionPlot:GetY(),
                                        direction);
                                    if adjLMPlot ~= nil then
                                        if not adjUnit:CanMoveThrough(adjLMPlot) then
                                            local tempAdjLMPlot = nil;
                                            for directionLM = 0, 5 do
                                                tempAdjLMPlot = Map.PlotDirection(adjLMPlot:GetX(), adjLMPlot:GetY(),
                                                    directionLM);
                                                if tempAdjLMPlot and adjUnit:CanMoveThrough(tempAdjLMPlot) then
                                                    break;
                                                end
                                                -- not Plot to Move into!
                                                tempAdjLMPlot = nil;
                                            end
                                            adjLMPlot = tempAdjLMPlot;
                                        end
                                    end
                                    if adjLMPlot == nil then
                                        local tempAdjLMPlot = nil;
                                        for directionLM = 0, 5 do
                                            tempAdjLMPlot = Map.PlotDirection(pLastMissionPlot:GetX(),
                                                pLastMissionPlot:GetY(), directionLM);
                                            if tempAdjLMPlot and adjUnit:CanMoveThrough(tempAdjLMPlot) then
                                                break;
                                            end
                                            -- not Plot to Move into!
                                            tempAdjLMPlot = nil;
                                        end
                                        adjLMPlot = tempAdjLMPlot;
                                    end
                                end

                                adjFlag.m_GGMPlot = adjLMPlot;
                            end
                        end
                    end
                end
            end

            for i = pOldPlot:GetNumUnits() - 1, 0, -1 do
                local pUnit = pOldPlot:GetUnit(i);
                local bSkip = false;
                if pUnit ~= nil
                    and g_MasterList[pUnit:GetOwner()] ~= nil
                    and g_MasterList[pUnit:GetOwner()][pUnit:GetID()] ~= nil
                then
                    local pFlag = g_MasterList[pUnit:GetOwner()][pUnit:GetID()];
                    -- "7" Group Skip
                    if pFlag.m_GGMPlot == pUnit:GetPlot() and g_GGType ~= -1 then
                        bSkip = true;
                    end
                    if pUnit:CanMove() and pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID)
                        and pUnit:CanMoveThrough(pLastMissionPlot) and not bSkip
                        and (pUnit:GetActivityType() == 0 or pUnit:GetActivityType() == 1)
                        and not pUnit:IsDead() and not pUnit:IsDelayedDeath()
                    then
                        local oPlot = pUnit:GetPlot();
                        pUnit:PushMission(MissionTypes.MISSION_MOVE_TO, pLastMissionPlot:GetX(), pLastMissionPlot:GetY());
                        if oPlot ~= pUnit:GetPlot() then
                            return;
                        end
                    end
                end
            end

            -- "7" Group
            if g_GGPlot and g_GGType ~= -1 then
                for direction = 0, 5 do
                    local adjPlot = Map.PlotDirection(g_GGPlot:GetX(), g_GGPlot:GetY(), direction);
                    local adjLMPlot = nil;
                    if adjPlot and adjPlot:GetNumUnits() > 0 then
                        for i = adjPlot:GetNumUnits() - 1, 0, -1 do
                            local adjUnit = adjPlot:GetUnit(i);
                            local bSkip = false;
                            if adjUnit ~= nil
                                and g_MasterList[adjUnit:GetOwner()] ~= nil
                                and g_MasterList[adjUnit:GetOwner()][adjUnit:GetID()] ~= nil
                                and g_MasterList[adjUnit:GetOwner()][adjUnit:GetID()].m_GGMPlot ~= nil
                            then
                                local adjFlag = g_MasterList[adjUnit:GetOwner()][adjUnit:GetID()];
                                adjLMPlot = adjFlag.m_GGMPlot;
                                if adjLMPlot == nil or adjFlag.m_GGMPlot == adjUnit:GetPlot() then
                                    bSkip = true;
                                end
                                if adjUnit:CanMove() and adjUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID)
                                    and adjLMPlot and adjUnit:CanMoveThrough(adjLMPlot) and not bSkip
                                    and (adjUnit:GetActivityType() == 0 or adjUnit:GetActivityType() == 1)
                                    and not adjUnit:IsDead() and not adjUnit:IsDelayedDeath()
                                then
                                    local oPlot = adjUnit:GetPlot();
                                    adjUnit:PushMission(MissionTypes.MISSION_MOVE_TO, adjLMPlot:GetX(), adjLMPlot:GetY());
                                    if oPlot ~= adjUnit:GetPlot() then
                                        return;
                                    end
                                end
                            end
                        end
                    end
                end
            end
        else
            for i = pOldPlot:GetNumUnits() - 1, 0, -1 do
                local pUnit = pOldPlot:GetUnit(i);
                if pUnit and pUnit:CanMove() and pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_AIR"].ID)
                    and pUnit:CanRebaseAt(pOldPlot, pLastMissionPlot:GetX(), pLastMissionPlot:GetY())
                    and (pUnit:GetActivityType() == 0 or pUnit:GetActivityType() == 1)
                    and not pUnit:IsDead() and not pUnit:IsDelayedDeath()
                then
                    local oPlot = pUnit:GetPlot();
                    pUnit:PushMission(MissionTypes.MISSION_REBASE, pLastMissionPlot:GetX(), pLastMissionPlot:GetY());
                    if oPlot ~= pUnit:GetPlot() then
                        return;
                    end
                end
            end
        end
    end
    g_IsDoingGG = false;
    local pSelectedUnit = UI.GetHeadSelectedUnit();
    if pSelectedUnit and g_MasterList[pSelectedUnit:GetOwner()] ~= nil and g_MasterList[pSelectedUnit:GetOwner()][pSelectedUnit:GetID()] ~= nil
        and g_MasterList[pSelectedUnit:GetOwner()][pSelectedUnit:GetID()].m_IsSelected
    then
        g_MasterList[pSelectedUnit:GetOwner()][pSelectedUnit:GetID()]:UpdateSelected(true);
    end
end

function GroupCombat(pOUnit, pTPlot, pTarget)
    -- Attack
    if not g_UnitList.LisAnchor:IsHidden() then
        OnCloseUnitList();
    end

    g_IsDoingGG = true;
    local pOPlot = pOUnit:GetPlot();
    if (pOPlot ~= nil and pTPlot ~= nil and pOPlot ~= pTPlot) then
        if pTPlot:IsCity() and pTPlot:GetPlotCity():GetDamage() >= pTPlot:GetPlotCity():GetMaxHitPoints() - 1 then
            g_IsDoingGG = false;
            return;
        end
        for i = pOPlot:GetNumUnits() - 1, 0, -1 do
            local pUnit = pOPlot:GetUnit(i);

            if pUnit and (pUnit:IsDead() or pUnit:IsDelayedDeath()
                or GameInfo.Units[pUnit:GetUnitType()].Suicide
                or not pUnit:CanMove() or pUnit:GetActivityType() == 6)
            then
            elseif pUnit and pOUnit:GetDomainType() ~= DomainTypes.DOMAIN_AIR
                and pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID)
            then
                if not pOUnit:IsRangedSupportFire() and pOUnit:GetBaseRangedCombatStrength() > 0 then
                    if pUnit:CanRangeStrikeAt(pTPlot:GetX(), pTPlot:GetY(), true, true) then
                        pUnit:RangeStrike(pTPlot:GetX(), pTPlot:GetY());
                        return;
                    end
                else
                    if pUnit:CanMoveOrAttackInto(pTPlot) then
                        local oPlot = pUnit:GetPlot();
                        local oHP = pUnit:GetCurrHitPoints();
                        pUnit:PushMission(MissionTypes.MISSION_MOVE_TO, pTPlot:GetX(), pTPlot:GetY());
                        if oPlot ~= pUnit:GetPlot() or oHP ~= pUnit:GetCurrHitPoints() then
                            return;
                        end
                    end
                end
            elseif pUnit and pOUnit:GetDomainType() == DomainTypes.DOMAIN_AIR
                and pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_AIR"].ID)
            then
                local iAirStrikeDefenseDamage = 0;
                local iGetEnemyOwner = -1;
                local pDefendingUnit;
                if pTPlot:IsEnemyCity(pUnit) then
                    iAirStrikeDefenseDamage = pTPlot:GetPlotCity():GetAirStrikeDefenseDamage(pUnit, false);
                    iGetEnemyOwner = pTPlot:GetOwner();
                elseif pTPlot:IsVisibleEnemyDefender(pUnit) then
                    if pTarget ~= nil and pTarget.m_IsCivilian
                        and Players[pTarget.m_PlayerID] ~= nil and Players[pTarget.m_PlayerID]:GetUnitByID(pTarget.m_UnitID) ~= nil
                        and not Players[pTarget.m_PlayerID]:GetUnitByID(pTarget.m_UnitID):IsDead()
                    then
                        Players[pTarget.m_PlayerID]:GetUnitByID(pTarget.m_UnitID):Kill();
                    end
                    pDefendingUnit = pTPlot:GetBestDefender(pTPlot:GetUnit(0):GetOwner(), pUnit:GetOwner(), pUnit);
                    if pDefendingUnit and pDefendingUnit:IsCombatUnit() and not pDefendingUnit:IsEmbarked() then
                        iAirStrikeDefenseDamage = pDefendingUnit:GetAirStrikeDefenseDamage(pUnit, false);
                    end
                    if pTPlot:GetUnit(0) then
                        iGetEnemyOwner = pTPlot:GetUnit(0):GetOwner();
                    end
                end

                if pDefendingUnit ~= nil and iAirStrikeDefenseDamage < pUnit:GetCurrHitPoints()
                    and pUnit:CanRangeStrikeAt(pTPlot:GetX(), pTPlot:GetY(), true, true)
                then
                    pUnit:RangeStrike(pTPlot:GetX(), pTPlot:GetY());
                    pUnit:ChangeDamage(iAirStrikeDefenseDamage, iGetEnemyOwner);
                    return;
                end
            end
        end

        if pOUnit:GetDomainType() ~= DomainTypes.DOMAIN_AIR then
            for j = 0, pOPlot:GetNumUnits() - 1 do
                if pOPlot:GetUnit(j) and pOPlot:GetUnit(j):IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID) then
                    RemoveGroupMark(pOPlot:GetUnit(j));
                end
            end
            OnGroupMoveSet(pOPlot);
        end

        -- "7" Group
        if g_GGPlot and g_GGType ~= -1 then
            for direction = 0, 5 do
                local adjPlot = nil;
                local adjMapD = -1;

                if not pOUnit:IsRangedSupportFire() and pOUnit:GetBaseRangedCombatStrength() > 0 then
                    adjPlot = Map.PlotDirection(pOPlot:GetX(), pOPlot:GetY(), direction);
                else
                    adjPlot = Map.PlotDirection(pTPlot:GetX(), pTPlot:GetY(), direction);
                    if adjPlot ~= nil then
                        adjMapD = Map.PlotDistance(pOPlot:GetX(), pOPlot:GetY(), adjPlot:GetX(), adjPlot:GetY());
                    end
                end
                if adjPlot and adjPlot:GetNumUnits() > 0 then
                    for i = adjPlot:GetNumUnits() - 1, 0, -1 do
                        local adjUnit = adjPlot:GetUnit(i);

                        if adjUnit and (adjUnit:IsDead() or adjUnit:IsDelayedDeath()
                            or GameInfo.Units[adjUnit:GetUnitType()].Suicide
                            or not adjUnit:CanMove() or adjUnit:GetActivityType() == 6)
                        then
                        elseif adjUnit and pOUnit:GetDomainType() ~= DomainTypes.DOMAIN_AIR
                            and adjUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID)
                        then
                            if not pOUnit:IsRangedSupportFire() and pOUnit:GetBaseRangedCombatStrength() > 0 then
                                if adjUnit:CanRangeStrikeAt(pTPlot:GetX(), pTPlot:GetY(), true, true) then
                                    adjUnit:RangeStrike(pTPlot:GetX(), pTPlot:GetY());
                                    return;
                                end
                            else
                                if adjUnit:CanMoveOrAttackInto(pTPlot) and adjMapD == 1 then
                                    local oPlot = adjUnit:GetPlot();
                                    local oHP = adjUnit:GetCurrHitPoints();
                                    adjUnit:PushMission(MissionTypes.MISSION_MOVE_TO, pTPlot:GetX(), pTPlot:GetY());
                                    if oPlot ~= adjUnit:GetPlot() or oHP ~= adjUnit:GetCurrHitPoints() then
                                        return;
                                    end
                                end
                            end
                            --[[
						elseif adjUnit and pOUnit:GetDomainType() == DomainTypes.DOMAIN_AIR
						and    adjUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_AIR"].ID)
						and    adjUnit:CanRangeStrikeAt(pTPlot:GetX(), pTPlot:GetY(), true, true)
						then
							local iAirStrikeDefenseDamage = 0;
							local iGetEnemyOwner = -1;
							local pDefendingUnit;
							if     pTPlot:IsEnemyCity(adjUnit) then
								iAirStrikeDefenseDamage = pTPlot:GetPlotCity():GetAirStrikeDefenseDamage(adjUnit, false);
								iGetEnemyOwner = pTPlot:GetOwner();
							elseif pTPlot:IsVisibleEnemyDefender(adjUnit) then
							    pDefendingUnit = pTPlot:GetBestDefender( pTPlot:GetUnit(0):GetOwner(), adjUnit:GetOwner(), adjUnit);
							    if pDefendingUnit and pDefendingUnit:IsCombatUnit() and not pDefendingUnit:IsEmbarked() then
								iAirStrikeDefenseDamage = pDefendingUnit:GetAirStrikeDefenseDamage(adjUnit, false);
							    else
								iAirStrikeDefenseDamage = 0;
							    end
							    iGetEnemyOwner = pTPlot:GetUnit(0):GetOwner();
							end
				
							if iAirStrikeDefenseDamage < adjUnit:GetCurrHitPoints() then
								adjUnit:RangeStrike( pTPlot:GetX(), pTPlot:GetY() );
								if iAirStrikeDefenseDamage > 0 then
									adjUnit:ChangeDamage( iAirStrikeDefenseDamage, iGetEnemyOwner );
								elseif   pDefendingUnit and not pDefendingUnit:IsDead() and not pDefendingUnit:IsDelayedDeath()
								and (not pDefendingUnit:IsCombatUnit() or pDefendingUnit:IsEmbarked())
								then
									pDefendingUnit:Kill();
								end
								return;
							end
						]]
                        end
                    end
                end
                --[[
				adjPlot = Map.PlotDirection(pOPlot:GetX(), pOPlot:GetY(), direction);
				if adjPlot ~= nil then
					adjMapD = Map.PlotDistance( pTPlot:GetX(), pTPlot:GetY(), adjPlot:GetX(), adjPlot:GetY() );
				end
				if adjPlot and adjPlot:GetNumUnits() > 0 and adjMapD > 1 then
					for i = adjPlot:GetNumUnits() - 1, 0, -1 do
						local adjUnit = adjPlot:GetUnit( i );
						
						if  adjUnit and not adjUnit:IsDead() and not adjUnit:IsDelayedDeath()
						and adjUnit:CanMove() and adjUnit:GetActivityType() ~= 6
						and adjUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID)
						and adjUnit:CanMoveOrAttackInto(pTPlot)
						--and  pTPlot:MovementCost(adjUnit, adjPlot) <= 1
						and  pOUnit:GetDomainType() ~= DomainTypes.DOMAIN_AIR
						then
							local oPlot = adjUnit:GetPlot();
							local oHP = adjUnit:GetCurrHitPoints();
							adjUnit:PushMission(MissionTypes.MISSION_MOVE_TO, pTPlot:GetX(), pTPlot:GetY());
							if oPlot ~= adjUnit:GetPlot() or oHP ~= adjUnit:GetCurrHitPoints() then
								return;
							end
						end
					end
				end
				]]
            end
        end
    end
    g_IsDoingGG = false;
    local pSelectedUnit = UI.GetHeadSelectedUnit();
    if pSelectedUnit and g_MasterList[pSelectedUnit:GetOwner()] ~= nil and g_MasterList[pSelectedUnit:GetOwner()][pSelectedUnit:GetID()] ~= nil
        and g_MasterList[pSelectedUnit:GetOwner()][pSelectedUnit:GetID()].m_IsSelected
    then
        g_MasterList[pSelectedUnit:GetOwner()][pSelectedUnit:GetID()]:UpdateSelected(true);
    end
end

-------------------------------------------------
-------------------------------------------------
function OnGroupMoveSet(pPlot)
    local pMovesLeft    = -1;
    local pMaxMoves     = -1;

    local pDMovesLeft   = 0;
    local pDMaxMoves    = 0;

    local isHasMNMA     = false;
    local isHasITC      = false;
    local isHasAT       = false;
    local isHasW        = false;
    local isHasDMIC     = false;
    local isHasBISTH    = false;
    local isHasHU       = false;
    local isHasLW       = false;
    local isHasFS       = false;
    local isHasRTP      = false;
    local isHasCEDO     = false;
    local isHasAN       = false;

    local isHasNotMNMA  = false;
    local isHasNotITC   = false;
    local isHasNotAT    = false;
    local isHasNotW     = false;
    local isHasNotDMIC  = false;
    local isHasNotBISTH = false;
    local isHasNotHU    = false;
    local isHasNotLW    = false;
    local isHasNotFS    = false;
    local isHasNotRTP   = false;
    local isHasNotCEDO  = false;
    local isHasNotAN    = false;

    local doMNMA        = 0;
    local doITC         = 0;
    local doAT          = 0;
    local doW           = 0;
    local doDMIC        = 0;
    local doBISTH       = 0;
    local doHU          = 0;
    local doLW          = 0;
    local doFS          = 0;
    local doRTP         = 0;
    local doCEDO        = 0;
    local doAN          = 0;

    for i = 0, pPlot:GetNumUnits() - 1 do
        local test = pPlot:GetUnit(i);
        if test ~= nil and test:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID) then
            if pMovesLeft == -1 or pMaxMoves == -1 then
                pMovesLeft = test:MovesLeft();
                pMaxMoves  = test:MaxMoves();
            else
                pMovesLeft = math.min(test:MovesLeft(), pMovesLeft);
                pMaxMoves  = math.min(test:MaxMoves(), pMaxMoves);
            end

            if not test:IsCanAttackWithMove() then
                isHasMNMA = true;
            else
                isHasNotMNMA = true;
            end
            if PromotionIGNORETERRAINCOST and test:IsHasPromotion(PromotionIGNORETERRAINCOST.ID) then
                isHasITC = true;
            else
                isHasNotITC = true;
            end
            if PromotionALTITUDETRAINING and test:IsHasPromotion(PromotionALTITUDETRAINING.ID) then
                isHasAT = true;
            else
                isHasNotAT = true;
            end
            if PromotionWOODSMAN and test:IsHasPromotion(PromotionWOODSMAN.ID) then
                isHasW = true;
            else
                isHasNotW = true;
            end
            if PromotionSTEAMPOWERED and test:IsHasPromotion(PromotionSTEAMPOWERED.ID) then
                isHasDMIC = true;
            else
                isHasNotDMIC = true;
            end
            if PromotionSKIINFANTRY and test:IsHasPromotion(PromotionSKIINFANTRY.ID) then
                isHasBISTH = true;
            else
                isHasNotBISTH = true;
            end
            if PromotionHOVERINGUNIT and test:IsHasPromotion(PromotionHOVERINGUNIT.ID) then
                isHasHU = true;
            else
                isHasNotHU = true;
            end
            if PromotionLIGHTNINGWARFARE and test:IsHasPromotion(PromotionLIGHTNINGWARFARE.ID)
            then
                isHasLW = true;
            else
                isHasNotLW = true;
            end
            if PromotionFIRSTSTRIKE and test:IsHasPromotion(PromotionFIRSTSTRIKE.ID)
            then
                isHasFS = true;
            else
                isHasNotFS = true;
            end
            if PromotionROUGHTERRAINENDSTURN and test:IsHasPromotion(PromotionROUGHTERRAINENDSTURN.ID) then
                isHasRTP = true;
            else
                isHasNotRTP = true;
            end
            if PromotionOCEANIMPASSABLE and test:IsHasPromotion(PromotionOCEANIMPASSABLE.ID) then
                isHasCEDO = true;
            else
                isHasNotCEDO = true;
            end
            local pTeam = Teams[Players[test:GetOwner()]:GetTeam()];
            if PromotionOCEANIMPASSABLEUNTILASTRONOMY and test:IsHasPromotion(PromotionOCEANIMPASSABLEUNTILASTRONOMY.ID) and not pTeam:IsHasTech(GameInfoTypes["TECH_ASTRONOMY"]) then
                isHasAN = true;
            else
                isHasNotAN = true;
            end
        end
    end

    if isHasMNMA == isHasNotMNMA then
        doMNMA = 1;
    end
    if isHasITC == isHasNotITC then
        doITC = 1;
    end
    if isHasAT == isHasNotAT then
        doAT = 1;
    end
    if isHasW == isHasNotW then
        doW = 1;
    end
    if isHasDMIC == isHasNotDMIC then
        doDMIC = 1;
    end
    if isHasBISTH == isHasNotBISTH then
        doBISTH = 1;
    end
    if isHasHU == isHasNotHU then
        doHU = 1;
    end
    if isHasLW == isHasNotLW then
        doLW = 1;
    end
    if isHasFS == isHasNotFS then
        doFS = 1;
    end
    if isHasRTP == isHasNotRTP then
        doRTP = 1;
    end
    if isHasCEDO == isHasNotCEDO then
        doCEDO = 1;
    end
    if isHasAN == isHasNotAN then
        doAN = 1;
    end

    ---------------------------------------------------------------------
    ---------------------------------------------------------------------
    for j = 0, pPlot:GetNumUnits() - 1 do
        local pUnit = pPlot:GetUnit(j);
        if pUnit ~= nil and pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID) then
            pDMaxMoves = pUnit:MaxMoves() - pMaxMoves;
            if pDMaxMoves == 1 * GameDefines["MOVE_DENOMINATOR"] then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_I"].ID, true);
            elseif pDMaxMoves == 2 * GameDefines["MOVE_DENOMINATOR"] then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_II"].ID, true);
            elseif pDMaxMoves == 3 * GameDefines["MOVE_DENOMINATOR"] then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_III"].ID, true);
            elseif pDMaxMoves == 4 * GameDefines["MOVE_DENOMINATOR"] then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_IV"].ID, true);
            elseif pDMaxMoves == 5 * GameDefines["MOVE_DENOMINATOR"] then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_V"].ID, true);
            elseif pDMaxMoves == 6 * GameDefines["MOVE_DENOMINATOR"] then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_V"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_I"].ID, true);
            elseif pDMaxMoves == 7 * GameDefines["MOVE_DENOMINATOR"] then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_V"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_II"].ID, true);
            elseif pDMaxMoves == 8 * GameDefines["MOVE_DENOMINATOR"] then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_V"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_III"].ID, true);
            elseif pDMaxMoves == 9 * GameDefines["MOVE_DENOMINATOR"] then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_V"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_IV"].ID, true);
            elseif pDMaxMoves == 10 * GameDefines["MOVE_DENOMINATOR"] then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_V"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_IV"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_I"].ID, true);
            elseif pDMaxMoves == 11 * GameDefines["MOVE_DENOMINATOR"] then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_V"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_IV"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_II"].ID, true);
            elseif pDMaxMoves == 12 * GameDefines["MOVE_DENOMINATOR"] then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_V"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_IV"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_III"].ID, true);
            elseif pDMaxMoves == 13 * GameDefines["MOVE_DENOMINATOR"] then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_V"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_IV"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_III"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_I"].ID, true);
            elseif pDMaxMoves == 14 * GameDefines["MOVE_DENOMINATOR"] then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_V"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_IV"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_III"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_II"].ID, true);
            elseif pDMaxMoves == 15 * GameDefines["MOVE_DENOMINATOR"] then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_V"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_IV"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_III"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_II"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_I"].ID, true);
            end
            pDMovesLeft = pUnit:MovesLeft() - pMovesLeft;
            if pDMovesLeft == 1 * GameDefines["MOVE_DENOMINATOR"] then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_I"].ID, true);
            elseif pDMovesLeft == 2 * GameDefines["MOVE_DENOMINATOR"] then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_II"].ID, true);
            elseif pDMovesLeft == 3 * GameDefines["MOVE_DENOMINATOR"] then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_III"].ID, true);
            elseif pDMovesLeft == 4 * GameDefines["MOVE_DENOMINATOR"] then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_IV"].ID, true);
            elseif pDMovesLeft == 5 * GameDefines["MOVE_DENOMINATOR"] then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_V"].ID, true);
            elseif pDMovesLeft == 6 * GameDefines["MOVE_DENOMINATOR"] then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_V"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_I"].ID, true);
            elseif pDMovesLeft == 7 * GameDefines["MOVE_DENOMINATOR"] then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_V"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_II"].ID, true);
            elseif pDMovesLeft == 8 * GameDefines["MOVE_DENOMINATOR"] then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_V"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_III"].ID, true);
            elseif pDMovesLeft == 9 * GameDefines["MOVE_DENOMINATOR"] then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_V"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_IV"].ID, true);
            elseif pDMovesLeft == 10 * GameDefines["MOVE_DENOMINATOR"] then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_V"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_IV"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_I"].ID, true);
            elseif pDMovesLeft == 11 * GameDefines["MOVE_DENOMINATOR"] then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_V"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_IV"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_II"].ID, true);
            elseif pDMovesLeft == 12 * GameDefines["MOVE_DENOMINATOR"] then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_V"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_IV"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_III"].ID, true);
            elseif pDMovesLeft == 13 * GameDefines["MOVE_DENOMINATOR"] then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_V"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_IV"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_III"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_I"].ID, true);
            elseif pDMovesLeft == 14 * GameDefines["MOVE_DENOMINATOR"] then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_V"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_IV"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_III"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_II"].ID, true);
            elseif pDMovesLeft == 15 * GameDefines["MOVE_DENOMINATOR"] then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_V"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_IV"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_III"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_II"].ID, true);
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_MOVELIFT_I"].ID, true);
            end
            pUnit:SetMoves(pMovesLeft);

            if doMNMA == 1 and pUnit:IsCanAttackWithMove() then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X"].ID, true);
            end
            if doITC == 1 and PromotionIGNORETERRAINCOST and pUnit:IsHasPromotion(PromotionIGNORETERRAINCOST.ID) then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_I"].ID, true);
                pUnit:SetHasPromotion(PromotionIGNORETERRAINCOST.ID, false);
            end
            if doAT == 1 and PromotionALTITUDETRAINING and pUnit:IsHasPromotion(PromotionALTITUDETRAINING.ID) then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_II"].ID, true);
                pUnit:SetHasPromotion(PromotionALTITUDETRAINING.ID, false);
            end
            if doW == 1 and PromotionWOODSMAN and pUnit:IsHasPromotion(PromotionWOODSMAN.ID) then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_III"].ID, true);
                pUnit:SetHasPromotion(PromotionWOODSMAN.ID, false);
            end
            if doDMIC == 1 and PromotionSTEAMPOWERED and pUnit:IsHasPromotion(PromotionSTEAMPOWERED.ID) then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_IV"].ID, true);
                pUnit:SetHasPromotion(PromotionSTEAMPOWERED.ID, false);
            end
            if doBISTH == 1 and PromotionSKIINFANTRY and pUnit:IsHasPromotion(PromotionSKIINFANTRY.ID) then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_V"].ID, true);
                pUnit:SetHasPromotion(PromotionSKIINFANTRY.ID, false);
            end
            if doHU == 1 and PromotionHOVERINGUNIT and pUnit:IsHasPromotion(PromotionHOVERINGUNIT.ID) then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_VI"].ID, true);
                pUnit:SetHasPromotion(PromotionHOVERINGUNIT.ID, false);
            end
            if doLW == 1 and PromotionLIGHTNINGWARFARE and pUnit:IsHasPromotion(PromotionLIGHTNINGWARFARE.ID) then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_VII"].ID, true);
                pUnit:SetHasPromotion(PromotionLIGHTNINGWARFARE.ID, false);
            end
            if doFS == 1 and PromotionFIRSTSTRIKE and pUnit:IsHasPromotion(PromotionFIRSTSTRIKE.ID) then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_VII_FS"].ID, true);
                pUnit:SetHasPromotion(PromotionFIRSTSTRIKE.ID, false);
            end
            if doRTP == 1 and PromotionROUGHTERRAINENDSTURN and not pUnit:IsHasPromotion(PromotionROUGHTERRAINENDSTURN.ID) then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_VIII"].ID, true);
            end
            if doCEDO == 1 and PromotionOCEANIMPASSABLE and not pUnit:IsHasPromotion(PromotionOCEANIMPASSABLE.ID) then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_IX"].ID, true);
            end
            if doAN == 1 and PromotionOCEANIMPASSABLEUNTILASTRONOMY and not pUnit:IsHasPromotion(PromotionOCEANIMPASSABLEUNTILASTRONOMY.ID) then
                pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_MOVE_X_X"].ID, true);
            end
        end
    end
end

-------------------------------------------------
-------------------------------------------------
function CheckPlot(plot)
    if (plot == nil or not plot:IsVisible(Game.GetActiveTeam())) then
        return;
    end

    local nonAirUnitNum = 0;
    local combatUnitNum = 0;
    local civilianUnitNum = 0;
    local tradeUnitNum = 0;
    local airCraftNum = 0;

    local carrierNum = 0;
    local firstCarrier = nil;
    local carrierFlag = nil;
    local isHasGroupAir = false;

    local combatUnitOrd = 0;
    local civilianUnitOrd = 0;
    local tradeUnitOrd = 0;

    local AllUCou = 0;
    local UnitCou = 0;
    local UnitOrd = 0;
    local HasComb = 0;

    -- check current hex for similar units
    if (plot:GetNumLayerUnits() > 1) then
        for i = 0, plot:GetNumLayerUnits() - 1, 1 do
            local test = plot:GetLayerUnit(i);
            if (g_PrintDebug) then print(string.format("Determining Plot for: Player[%i] Unit[%i] - %i", self.m_PlayerID,
                    self.m_UnitID, i)); end
            if (test ~= nil and not test:IsDead() and not test:IsDelayedDeath() and not test:IsInvisible(Game.GetActiveTeam()) and not test:IsGarrisoned())
            then
                if test:IsCombatUnit() and not test:IsEmbarked() then
                    if (g_PrintDebug) then print(string.format("There is a Combat unit on that plot...")); end
                    combatUnitNum = combatUnitNum + 1;
                    nonAirUnitNum = nonAirUnitNum + 1;
                elseif test:IsTrade() then
                    tradeUnitNum = tradeUnitNum + 1;
                elseif test:GetDomainType() == DomainTypes.DOMAIN_AIR then
                    airCraftNum = airCraftNum + 1;
                else
                    civilianUnitNum = civilianUnitNum + 1;
                    nonAirUnitNum = nonAirUnitNum + 1;
                end

                if test:HasCargo() then
                    carrierNum = carrierNum + 1;
                    if carrierNum == 1 then
                        firstCarrier = test;
                    end
                end

                if test:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_AIR"].ID) then
                    isHasGroupAir = true;
                end
            end
        end

        if firstCarrier ~= nil and (g_MasterList[firstCarrier:GetOwner()] ~= nil)
            and (g_MasterList[firstCarrier:GetOwner()][firstCarrier:GetID()] ~= nil)
        then
            carrierFlag = g_MasterList[firstCarrier:GetOwner()][firstCarrier:GetID()];
            carrierFlag.m_HasGroupAir = isHasGroupAir;
        end

        for j = 0, plot:GetNumLayerUnits() - 1, 1 do
            local stackUnit = plot:GetLayerUnit(j);
            if stackUnit and not stackUnit:IsDead() and not stackUnit:IsDelayedDeath() and not stackUnit:IsGarrisoned()
                and g_MasterList[stackUnit:GetOwner()] and g_MasterList[stackUnit:GetOwner()][stackUnit:GetID()]
            then
                local stackUnitFlag = g_MasterList[stackUnit:GetOwner()][stackUnit:GetID()];
                if stackUnit:IsInvisible(Game.GetActiveTeam()) then
                    stackUnitFlag:SetPlot(1, 0, 0, 0);
                else
                    if combatUnitNum > 0 then
                        HasComb = 2;
                    elseif tradeUnitNum > 0 and civilianUnitNum > 0 then
                        HasComb = 1;
                    else
                        HasComb = 0;
                    end

                    if (stackUnit:CargoSpace() > 0) then
                        if stackUnit:HasCargo() then
                            stackUnitFlag.m_CarrierFlag = carrierFlag;
                            stackUnitFlag.m_CargoCount = airCraftNum;
                        else
                            stackUnitFlag.m_CarrierFlag = -1;
                            stackUnitFlag.m_CargoCount = 0;
                        end
                    end

                    if stackUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID)
                        or stackUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_AIR"].ID)
                    then
                        stackUnitFlag.m_IsInGroup = true;
                    else
                        stackUnitFlag.m_IsInGroup = false;
                    end

                    if stackUnit:IsCombatUnit() and not stackUnit:IsEmbarked() then
                        combatUnitOrd = combatUnitOrd + 1;
                        AllUCou = nonAirUnitNum;
                        UnitCou = combatUnitNum;
                        UnitOrd = combatUnitOrd;
                    elseif stackUnit:IsTrade() then
                        tradeUnitOrd = tradeUnitOrd + 1;
                        AllUCou = nonAirUnitNum;
                        UnitCou = tradeUnitNum;
                        UnitOrd = tradeUnitOrd;
                    elseif stackUnit:GetDomainType() == DomainTypes.DOMAIN_AIR then
                        AllUCou = airCraftNum;
                        UnitCou = 0;
                        UnitOrd = 0;
                    else
                        civilianUnitOrd = civilianUnitOrd + 1;
                        AllUCou = nonAirUnitNum;
                        UnitCou = civilianUnitNum;
                        UnitOrd = civilianUnitOrd;
                    end
                    stackUnitFlag:SetPlot(AllUCou, UnitCou, UnitOrd, HasComb);
                end
            end
        end
    elseif plot:GetNumLayerUnits() == 1 then
        local pUnit = plot:GetLayerUnit(0);
        if pUnit ~= nil and (g_MasterList[pUnit:GetOwner()] ~= nil)
            and (g_MasterList[pUnit:GetOwner()][pUnit:GetID()] ~= nil)
        then
            local pUnitFlag = g_MasterList[pUnit:GetOwner()][pUnit:GetID()];

            if (pUnit:CargoSpace() > 0) then
                pUnitFlag.m_CarrierFlag = -1;
                pUnitFlag.m_CargoCount = 0;
            end
            if (pUnit:GetDomainType() == DomainTypes.DOMAIN_AIR) then
                airCraftNum = 1;
            end
            AllUCou = 1;

            pUnitFlag:SetPlot(AllUCou, UnitCou, UnitOrd, HasComb);
        end
    end

    return { airCraftNum, isHasGroupAir };
end

-------------------------------------------------
-------------------------------------------------
function UpdateCityCargo(pPlot, AirCraftState)
    if pPlot == nil then
        return;
    end

    local cityFlagInstance = g_CityFlags[pPlot:GetX() .. " " .. pPlot:GetY()];
    if not pPlot:IsVisible(Game.GetActiveTeam()) then
        if cityFlagInstance ~= nil then
            cityFlagInstance.Anchor:SetHide(true);
        end
    elseif (pPlot:IsCity() and AirCraftState[1] > 0) then
        if (cityFlagInstance == nil) then
            cityFlagInstance = {};
            ContextPtr:BuildInstanceForControl("CityFlag", cityFlagInstance, Controls.CityContainer);
            g_CityFlags[pPlot:GetX() .. " " .. pPlot:GetY()] = cityFlagInstance;

            local worldPos = Vector4(GridToWorld(pPlot:GetX(), pPlot:GetY()));
            cityFlagInstance.Anchor:SetWorldPosition(VecAdd(worldPos, CityWorldPositionOffset));
        end
        cityFlagInstance.AirButton:SetVoid1(pPlot:GetX());
        cityFlagInstance.AirButton:SetVoid2(pPlot:GetY());
        cityFlagInstance.AirButton:RegisterCallback(Mouse.eLClick, OnCargoClicked);
        cityFlagInstance.AirButton:SetHide(false);
        cityFlagInstance.Count:LocalizeAndSetText(AirCraftState[1]);
        cityFlagInstance.AirButton:LocalizeAndSetToolTip("TXT_KEY_STATIONED_AIRCRAFT", AirCraftState[1]);
        if not AirCraftState[2] then
            cityFlagInstance.Count:SetColorByName("Beige_Black_Alpha");
        else
            cityFlagInstance.Count:SetColorByName("Gold_Medal");
        end
        cityFlagInstance.Anchor:SetHide(false);
    else
        if (cityFlagInstance ~= nil) then
            cityFlagInstance.Anchor:SetHide(true);
        end
    end
end

-------------------------------------------------
-------------------------------------------------
function OnCityCreated(hexPos, playerID, cityID, cultureType, eraType, continent, populationSize, size, fowState)
    local gridPosX, gridPosY = ToGridFromHex(hexPos.x, hexPos.y);
    -- print( "gridPosX, gridPosY: "..tostring(gridPosX)..","..tostring(gridPosY) );
    local pAirCraftState = CheckPlot(Map.GetPlot(gridPosX, gridPosY));
    UpdateCityCargo(Map.GetPlot(gridPosX, gridPosY), pAirCraftState);

    --[[ Set the visibility
    if (pCityFlag ~= nil) then
        local bInvisible = fowState ~= WhiteFog;
        pCityFlag.Anchor:SetHide( bInvisible );
   end]]
end

Events.SerialEventCityCreated.Add(OnCityCreated);


-------------------------------------------------
-- On Unit Garrison
-------------------------------------------------
function OnUnitGarrison(playerID, unitID, bGarrisoned)
    if not UnitMoving(playerID, unitID) and g_MasterList[playerID] ~= nil then
        local flag = g_MasterList[playerID][unitID];
        if flag ~= nil then
            flag:GarrisonComplete(bGarrisoned);
        end
    end
end

Events.UnitGarrison.Add(OnUnitGarrison);


-------------------------------------------------
-------------------------------------------------
function OnUnitVisibility(playerID, unitID, visible, checkFlag, blendTime)
    if checkFlag then
        if (g_MasterList[playerID] ~= nil
            and g_MasterList[playerID][unitID] ~= nil)
        then
            local flag = g_MasterList[playerID][unitID];
            flag.m_IsInvisible = not visible;
            local pAirCraftState = CheckPlot(flag.m_Escort);
            if flag.m_IsAirCraft and flag.m_Escort and flag.m_Escort:IsCity() then
                UpdateCityCargo(flag.m_Escort, pAirCraftState);
            end
            flag:UpdateVisibility();
        end
    end
end

Events.UnitVisibilityChanged.Add(OnUnitVisibility);


-------------------------------------------------
-- On Unit Destroyed
-------------------------------------------------
function OnUnitDestroyed(playerID, unitID)
    if (g_MasterList[playerID] == nil or
        g_MasterList[playerID][unitID] == nil)
    then
        --print( string.format( "Unit not found for OnUnitDestroyed: Player[%i] Unit[%i]", playerID, unitID ) );
    else
        g_MasterList[playerID][unitID]:destroy();
    end
end

Events.SerialEventUnitDestroyed.Add(OnUnitDestroyed);


-------------------------------------------------
-- On Flag Clicked
-------------------------------------------------
function UnitFlagClicked(playerID, unitID)
    Events.SerialEventUnitFlagSelected(playerID, unitID);
end

function UnitFlagEnter(playerID, unitID)
    if (g_MasterList[playerID] ~= nil and
        g_MasterList[playerID][unitID] ~= nil) then
        g_MasterList[playerID][unitID]:OverrideDimmedFlag(true);
    end
end

function UnitFlagExit(playerID, unitID)
    if (g_MasterList[playerID] ~= nil and
        g_MasterList[playerID][unitID] ~= nil) then
        local flag = g_MasterList[playerID][unitID];
        flag:OverrideDimmedFlag(flag.m_IsSelected);
    end
end

-------------------------------------------------
-------------------------------------------------
function OnUnitSelect(playerID, unitID, i, j, k, isSelected)
    if (Players[playerID] == nil or
        not Players[playerID]:IsAlive() or
        Players[playerID]:GetUnitByID(unitID) == nil or
        Players[playerID]:GetUnitByID(unitID):IsDead())
    then
        return;
    end

    if (g_MasterList[playerID] == nil or
        g_MasterList[playerID][unitID] == nil)
    then
        print(string.format("Unit not found for OnUnitSelect: Player[%i] Unit[%i]", playerID, unitID));
    else
        g_MasterList[playerID][unitID]:UpdateSelected(isSelected);
    end
end

Events.UnitSelectionChanged.Add(OnUnitSelect);



--------------------------------------------------------------------------------
-- Unit SetDamage was called - we only enter this function if the amount of damage actually changed
--------------------------------------------------------------------------------
function OnUnitSetDamage(playerID, unitID, iDamage, iPreviousDamage)
    if (Players[playerID] == nil or
        not Players[playerID]:IsAlive() or
        Players[playerID]:GetUnitByID(unitID) == nil or
        Players[playerID]:GetUnitByID(unitID):IsDead())
    then
        return;
    end

    if (g_MasterList[playerID] == nil or
        g_MasterList[playerID][unitID] == nil)
    then
        --print( "Unit not found for OnUnitSetDamage: Player[" .. tostring( playerID ) .. "] Unit[" .. tostring( unitID ) .. "]" );
    else
        g_MasterList[playerID][unitID]:UpdateHealth();
    end
end

Events.SerialEventUnitSetDamage.Add(OnUnitSetDamage);

--------------------------------------------------------------------------------
-- A unit has changed its name, update the tool tip string
--------------------------------------------------------------------------------
function OnUnitNameChanged(playerID, unitID)
    if (Players[playerID] == nil or
        not Players[playerID]:IsAlive() or
        Players[playerID]:GetUnitByID(unitID) == nil or
        Players[playerID]:GetUnitByID(unitID):IsDead())
    then
        return;
    end

    if (g_MasterList[playerID] ~= nil) then
        local pFlag = g_MasterList[playerID][unitID];
        if (pFlag ~= nil) then
            pFlag:UpdateName();
        end
    end
end

Events.UnitNameChanged.Add(OnUnitNameChanged);


------------------------------------------------------------
-- this goes off when a hex is seen or unseen
------------------------------------------------------------
function OnHexFogEvent(hexPos, fogState, bWholeMap)
    local bInvisible = fogState ~= WhiteFog;
    local bCheckPlot = false;
    if (bWholeMap) then
        for playerID, playerTable in pairs(g_MasterList)
        do
            for unitID, flag in pairs(playerTable)
            do
                flag:SetFogState(fogState);
            end
        end

        -- Do the city flags
        for cityIndex, pCityFlag in pairs(g_CityFlags) do
            pCityFlag.Anchor:SetHide(bInvisible);
        end
    else
        local gridVecX, gridVecY = ToGridFromHex(hexPos.x, hexPos.y);
        local plot = Map.GetPlot(gridVecX, gridVecY);

        if (plot ~= nil) then
            local unitCount = plot:GetNumLayerUnits(); -- Get all layers, so we update the trade units as well
            if unitCount == 0 then
                return;
            end

            for i = 0, unitCount - 1, 1 do
                local unit = plot:GetLayerUnit(i); -- Get all layers, so we update the trade units as well
                if (unit ~= nil)
                then
                    local owner, unitID = unit:GetOwner(), unit:GetID();
                    if (g_MasterList[owner] ~= nil and
                        g_MasterList[owner][unitID] ~= nil)
                    then
                        local bIsCurrentlyVisible = g_MasterList[owner][unitID].m_IsCurrentlyVisible;
                        --print( " FOG OF WAR'd!! " .. owner .. " " .. unitID .. " " .. fogState );
                        g_MasterList[owner][unitID]:SetFogState(fogState);
                        if not bInvisible and not bCheckPlot and not bIsCurrentlyVisible
                            and g_MasterList[owner][unitID].m_IsCurrentlyVisible
                        then
                            bCheckPlot = true;
                        end
                    end
                end
            end

            if bCheckPlot then
                local airCraftState = CheckPlot(plot);
                -- Do city flag
                if plot:IsCity() then
                    UpdateCityCargo(plot, airCraftState);
                end
            end
        end
    end
end

Events.HexFOWStateChanged.Add(OnHexFogEvent);




--------------------------------------------------------------------------------
-- Update the name of all unit flags.
--------------------------------------------------------------------------------
function UpdateAllFlagNames()
    for playerID, playerTable in pairs(g_MasterList) do
        for unitID, flag in pairs(playerTable) do
            flag:UpdateName(fogState);
        end
    end
end

-- We have to update all flags because we don't know which player was updated (disconnected/reconnected/etc).
Events.MultiplayerGamePlayerUpdated.Add(UpdateAllFlagNames);


------------------------------------------------------------
-- this goes off when a unit moves into or out of the fog
------------------------------------------------------------
function OnUnitFogEvent(playerID, unitID, fogState)
    if (Players[playerID] == nil or
        not Players[playerID]:IsAlive() or
        Players[playerID]:GetUnitByID(unitID) == nil or
        Players[playerID]:GetUnitByID(unitID):IsDead())
    then
        return;
    end

    playerTable = g_MasterList[playerID];
    if (playerTable ~= nil)
    then
        local flag = playerTable[unitID];
        if (flag ~= nil)
        then
            flag:SetFogState(fogState);
        end
    end
end

Events.UnitStateChangeDetected.Add(OnUnitFogEvent);



------------------------------------------------------------
-- this goes off when gameplay decides a unit's flag should be dimmed or not
------------------------------------------------------------
function OnDimEvent(playerID, unitID, bDim)
    if (Players[playerID] == nil or
        not Players[playerID]:IsAlive() or
        Players[playerID]:GetUnitByID(unitID) == nil or
        Players[playerID]:GetUnitByID(unitID):IsDead())
    then
        return;
    end

    playerTable = g_MasterList[playerID];
    if (playerTable ~= nil)
    then
        local pUnit = Players[playerID]:GetUnitByID(unitID);
        local flag = playerTable[unitID];
        if (flag ~= nil)
        then
            local active_team = Game.GetActiveTeam();
            local team = Players[playerID]:GetTeam();

            if (active_team == team) then
                if flag.m_StackOrders[1] <= 1 and flag.m_IsInGroup and not Players[Game.GetActivePlayer()]:IsTurnActive() then
                    if pUnit ~= nil then
                        if flag.m_IsAirCraft then
                            flag.m_IsInGroup = false;
                            pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP_AIR"].ID, false);
                        elseif (g_GGPlot == nil or g_GGType == -1) or not pUnit:IsFriendlyUnitAdjacent() then
                            flag.m_IsInGroup = false;
                            RemoveGroupMark(pUnit);
                            pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_GROUP"].ID, false);
                        end
                    end
                end

                -- print( "  Unit dim: " .. tostring( playerID ) .. " " .. tostring( unitID ) .. " " .. iDim );
                flag:SetDim(bDim);
            end
            if pUnit:IsMustSetUpToRangedAttack() then
                flag:UpdateFlagType();
            end
        end
    end
end

Events.UnitShouldDimFlag.Add(OnDimEvent);



------------------------------------------------------------
-- this goes off when gameplay decides a unit is threatening and wants it marked
------------------------------------------------------------
function OnMarkThreateningEvent(playerID, unitID, bMark)
    -- print("Marking Unit as Threatening: " .. tostring(playerID) .. ", " .. tostring(unitID) .. ", " .. tostring(bMark));

    if (Players[playerID] == nil or
        not Players[playerID]:IsAlive() or
        Players[playerID]:GetUnitByID(unitID) == nil or
        Players[playerID]:GetUnitByID(unitID):IsDead())
    then
        return;
    end

    playerTable = g_MasterList[playerID];
    if (playerTable ~= nil)
    then
        local flag = playerTable[unitID];
        if (flag ~= nil)
        then
            --print( "  Unit mark threatening: " .. tostring( playerID ) .. " " .. tostring( unitID ) .. " " .. tostring(bMark) );
            flag:SetFlash(bMark);
        end
    end
end

Events.UnitMarkThreatening.Add(OnMarkThreateningEvent);










-- -------------------------------------------------------
-- temp to make updating units easier
-- -------------------------------------------------------
g_LastPlayerID = 0;
g_LastUnitID   = 0;



------------------------------------------------------------
-- scan for all cities when we are loaded
-- this keeps the banners from disappearing on hotload
------------------------------------------------------------
if (ContextPtr:IsHotLoad())
then
    local i = 0;
    local player = Players[i];
    while player ~= nil
    do
        if (player:IsAlive())
        then
            for unit in player:Units() do
                local plot = Map.GetPlot(unit:GetX(), unit:GetY());
                if (plot ~= nil) then
                    if (plot:IsVisible(Game.GetActiveTeam())) then
                        OnUnitCreated(player:GetID(), unit:GetID(), 0, 0, 0, 0, 0, 0, 0, WhiteFog, 0, 0, true);
                    end
                end
            end
        end

        i = i + 1;
        player = Players[i];
    end
end

------------------------------------------------------------
------------------------------------------------------------
function OnStrategicViewStateChanged(bStrategicView, bCityBanners)
    g_GarrisonedUnitFlagsInStrategicView = bStrategicView and bCityBanners;
    for playerID, playerTable in pairs(g_MasterList)
    do
        for unitID, flag in pairs(playerTable)
        do
            flag:UpdateVisibility();
            if flag.m_CarrierFlag == flag or flag.m_IsSelected then
                flag:UpdateFlagOffset();
            end
        end
    end
end

Events.StrategicViewStateChanged.Add(OnStrategicViewStateChanged);


------------------------------------------------------------
------------------------------------------------------------
function OnCityDestroyed(hexPos, playerID, cityID)
    local pPlot = Map.GetPlot(ToGridFromHex(hexPos.x, hexPos.y));
    if (pPlot ~= nil) then
        local count = pPlot:GetNumUnits();
        for i = 0, count - 1 do
            local pUnit = pPlot:GetUnit(i);
            if (pUnit ~= nil) then
                local playerTable = g_MasterList[pUnit:GetOwner()];
                if (playerTable ~= nil) then
                    local pFlag = playerTable[pUnit:GetID()];
                    if (pFlag ~= nil) then
                        pFlag:UpdateFlagOffset();
                    end
                end
            end
        end

        if g_CityFlags[pPlot:GetX() .. " " .. pPlot:GetY()] ~= nil then
            Controls.CityContainer:ReleaseChild(g_CityFlags[pPlot:GetX() .. " " .. pPlot:GetY()].Anchor);
            g_CityFlags[pPlot:GetX() .. " " .. pPlot:GetY()] = nil;
        end
    end
end

Events.SerialEventCityDestroyed.Add(OnCityDestroyed);
Events.SerialEventCityCaptured.Add(OnCityDestroyed);


------------------------------------------------------------
------------------------------------------------------------
local g_AttackerPlot = nil;
local g_DefenderPlot = nil;

function OnCombatBegin(m_AttackerPlayer,
                       m_AttackerUnitID,
                       m_AttackerUnitDamage,
                       m_AttackerFinalUnitDamage,
                       m_AttackerMaxHitPoints,
                       m_DefenderPlayer,
                       m_DefenderUnitID,
                       m_DefenderUnitDamage,
                       m_DefenderFinalUnitDamage,
                       m_DefenderMaxHitPoints,
                       m_bContinuation)
    if not g_UnitList.LisAnchor:IsHidden() then
        g_UnitList.LisAnchor:SetHide(true);
    end

    if Players[m_AttackerPlayer] ~= nil
        and Players[m_AttackerPlayer]:GetUnitByID(m_AttackerUnitID) ~= nil
        and Players[m_AttackerPlayer]:GetUnitByID(m_AttackerUnitID):GetPlot() ~= nil
    then
        g_AttackerPlot = Players[m_AttackerPlayer]:GetUnitByID(m_AttackerUnitID):GetPlot();

        for i = 0, g_AttackerPlot:GetNumLayerUnits() - 1, 1 do
            local attplotunit = g_AttackerPlot:GetLayerUnit(i);
            if (g_MasterList[attplotunit:GetOwner()] ~= nil)
                and (g_MasterList[attplotunit:GetOwner()][attplotunit:GetID()] ~= nil)
            then
                local flag = g_MasterList[attplotunit:GetOwner()][attplotunit:GetID()];
                if attplotunit:GetID() == m_AttackerUnitID then
                    flag.m_IsForceHide = false;
                else
                    flag.m_IsForceHide = true;
                end
                flag:UpdateVisibility();
            end
        end
    end

    if Players[m_DefenderPlayer] ~= nil
        and Players[m_DefenderPlayer]:GetUnitByID(m_DefenderUnitID) ~= nil
        and Players[m_DefenderPlayer]:GetUnitByID(m_DefenderUnitID):GetPlot() ~= nil
    then
        g_DefenderPlot = Players[m_DefenderPlayer]:GetUnitByID(m_DefenderUnitID):GetPlot();

        for i = 0, g_DefenderPlot:GetNumLayerUnits() - 1, 1 do
            local defplotunit = g_DefenderPlot:GetLayerUnit(i);
            if (g_MasterList[defplotunit:GetOwner()] ~= nil)
                and (g_MasterList[defplotunit:GetOwner()][defplotunit:GetID()] ~= nil)
            then
                local flag = g_MasterList[defplotunit:GetOwner()][defplotunit:GetID()];
                if defplotunit:GetID() == m_DefenderUnitID then
                    flag.m_IsForceHide = false;
                else
                    flag.m_IsForceHide = true;
                end
                flag:UpdateVisibility();
            end
        end
    end
end

Events.RunCombatSim.Add(OnCombatBegin);


------------------------------------------------------------
------------------------------------------------------------
function OnCombatEnd(m_AttackerPlayer,
                     m_AttackerUnitID,
                     m_AttackerUnitDamage,
                     m_AttackerFinalUnitDamage,
                     m_AttackerMaxHitPoints,
                     m_DefenderPlayer,
                     m_DefenderUnitID,
                     m_DefenderUnitDamage,
                     m_DefenderFinalUnitDamage,
                     m_DefenderMaxHitPoints)
    if not g_UnitList.LisAnchor:IsHidden() then
        g_UnitList.LisAnchor:SetHide(true);
    end

    if g_AttackerPlot ~= nil then
        for i = 0, g_AttackerPlot:GetNumLayerUnits() - 1, 1 do
            local attplotunit = g_AttackerPlot:GetLayerUnit(i);
            if (g_MasterList[attplotunit:GetOwner()] ~= nil)
                and (g_MasterList[attplotunit:GetOwner()][attplotunit:GetID()] ~= nil)
            then
                local flag = g_MasterList[attplotunit:GetOwner()][attplotunit:GetID()];
                flag.m_IsForceHide = false;
                flag:UpdateVisibility();
            end
        end
    end

    if g_DefenderPlot ~= nil then
        for i = 0, g_DefenderPlot:GetNumLayerUnits() - 1, 1 do
            local defplotunit = g_DefenderPlot:GetLayerUnit(i);
            if (g_MasterList[defplotunit:GetOwner()] ~= nil)
                and (g_MasterList[defplotunit:GetOwner()][defplotunit:GetID()] ~= nil)
            then
                local flag = g_MasterList[defplotunit:GetOwner()][defplotunit:GetID()];
                flag.m_IsForceHide = false;
                flag:UpdateVisibility();
            end
        end
    end

    g_AttackerPlot = nil;
    g_DefenderPlot = nil;
end

Events.EndCombatSim.Add(OnCombatEnd);


----------------------------------------------------------------
-- on shutdown, we need to get the selected flag instance back,
-- or we'll assert clearing the registered button handler
function OnShutdown()
    -- doesn't really matter where we put it, as long as we own it again.
    if (g_SelectedFlag ~= nil) then
        g_SelectedFlag.m_Instance.Anchor:ChangeParent(Controls.MilitaryFlags);
    end
end

ContextPtr:SetShutdown(OnShutdown);

----------------------------------------------------------------
-- 'Active' (local human) player has changed
----------------------------------------------------------------
function OnActivePlayerChanged(iActivePlayer, iPrevActivePlayer)
    local iActivePlayerID = Game.GetActivePlayer();

    if (g_SelectedFlag ~= nil) then
        g_SelectedFlag.m_Instance.Anchor:ChangeParent(Controls.MilitaryFlags);
        g_SelectedFlag = nil;
    end

    -- Rebuild all the tool tip strings.
    for playerID, playerTable in pairs(g_MasterList)
    do
        local pPlayer = Players[playerID];

        local bIsActivePlayer = (playerID == iActivePlayer);

        -- Only need to do this for human players
        if (pPlayer:IsHuman()) then
            for unitID, pFlag in pairs(playerTable)
            do
                local pUnit = pPlayer:GetUnitByID(unitID);
                if (pUnit ~= nil) then
                    --[[
					local toolTipString;
					if (PreGame.IsMultiplayerGame()) then
						toolTipString = Locale.ConvertTextKey("TXT_KEY_MULTIPLAYER_UNIT_TT", pPlayer:GetNickName(), pPlayer:GetCivilizationAdjectiveKey(), pUnit:GetNameKey());
					else
						if (pUnit:HasName()) then
							local desc = Locale.ConvertTextKey("TXT_KEY_PLOTROLL_UNIT_DESCRIPTION_CIV",  pPlayer:GetCivilizationAdjectiveKey(), pUnit:GetNameKey());
							toolTipString = string.format("%s (%s)", Locale.Lookup(pUnit:GetName()), desc);
						else
							toolTipString = Locale.ConvertTextKey("TXT_KEY_PLOTROLL_UNIT_DESCRIPTION_CIV",  pPlayer:GetCivilizationAdjectiveKey(), pUnit:GetNameKey());
						end
					end

					local eReligion = pUnit:GetReligion();
					if (eReligion > ReligionTypes.RELIGION_PANTHEON) then
						toolTipString = toolTipString .. " - " .. Locale.ConvertTextKey(GameInfo.Religions[eReligion].Description);
					end
					]]
                    if (bIsActivePlayer) then
                        -- toolTipString = toolTipString .. Locale.ConvertTextKey( "TXT_KEY_UPANEL_CLICK_TO_SELECT" );
                        pFlag.m_Instance.NormalButton:SetDisabled(false);
                        pFlag.m_Instance.NormalButton:SetConsumeMouseOver(true);
                        pFlag.m_Instance.HealthBarButton:SetDisabled(false);
                        pFlag.m_Instance.HealthBarButton:SetConsumeMouseOver(true);
                    else
                        pFlag.m_Instance.NormalButton:SetDisabled(true);
                        pFlag.m_Instance.NormalButton:SetConsumeMouseOver(false);
                        pFlag.m_Instance.HealthBarButton:SetDisabled(true);
                        pFlag.m_Instance.HealthBarButton:SetConsumeMouseOver(false);
                    end

                    -- pFlag.m_Instance.UnitIcon:SetToolTipString( toolTipString );
                    pFlag.m_Instance.NormalButton:SetToolTipCallback(TipHandler);
                    pFlag.m_Instance.HealthBarButton:SetToolTipCallback(TipHandler);
                    pFlag:UpdateFlagOffset();
                end
            end
        end
    end
end

Events.GameplaySetActivePlayer.Add(OnActivePlayerChanged);


------------------------------------------------------------
------------------------------------------------------------
local function GetCivBuilding( civilizationType, buildingClassType )
	if buildingClassType then
		if civilizationType and GameInfo.Civilization_BuildingClassOverrides{ CivilizationType = civilizationType, BuildingClassType = buildingClassType }() then
			local building = GameInfo.Civilization_BuildingClassOverrides{ CivilizationType = civilizationType, BuildingClassType = buildingClassType }()
			return building and GameInfo.Buildings[ building.BuildingType ]
		end
		local buildingClass = GameInfo.BuildingClasses[ buildingClassType ]
		return buildingClass and GameInfo.Buildings[ buildingClass.DefaultBuilding ]
	end
end

local function TextColor( c, s )
	return c..s.."[ENDCOLOR]"
end

local function UnitColor( s )
	return TextColor("[COLOR_UNIT_TEXT]", s)
end

local function BuildingColor( s )
	return TextColor("[COLOR_YIELD_FOOD]", s)
end

local function PolicyColor( s )
	return TextColor("[COLOR_MAGENTA]", s)
end

local function TechColor( s )
	return TextColor("[COLOR_CYAN]", s)
end

local function BeliefColor( s )
	return TextColor("[COLOR_WHITE]", s)
end

local tipControlTable = {};
TTManager:GetTypeControlTable("UnitTooltip", tipControlTable);
function TipHandler(Button)
    local iPlayer = Button:GetVoid1();
    local iUnit = Button:GetVoid2();

    if Players[iPlayer] and Players[iPlayer]:GetUnitByID(iUnit) then
        local player = Players[iPlayer];
        local unit = player:GetUnitByID(iUnit);

        local activePlayerID = Game.GetActivePlayer();
        local activeTeamID = Game.GetActiveTeam();
        local activeTeam = Teams[activeTeamID];
        local unitTeamID = unit:GetTeam();
        local civAdjective = player:GetCivilizationAdjective();
        local nickName = player:GetNickName();

        local controls = tipControlTable;
        local toolTipString;

        if activeTeamID == unitTeamID or (player:IsMinorCiv() and player:IsAllies(activePlayerID)) then
            toolTipString = "[COLOR_WHITE]"
        elseif activeTeam:IsAtWar(unitTeamID) then
            toolTipString = "[COLOR_NEGATIVE_TEXT]"
        else
            toolTipString = "[COLOR_POSITIVE_TEXT]"
        end
        toolTipString = toolTipString .. Locale.ConvertTextKey(unit:GetNameKey()) .. "[ENDCOLOR]"

        -- Player using nickname
        if PreGame.IsMultiplayerGame() and nickName and #nickName > 0 then
            toolTipString = Locale.ConvertTextKey("TXT_KEY_MULTIPLAYER_UNIT_TT", nickName, civAdjective, toolTipString)
        elseif activeTeam:IsHasMet(unitTeamID) then
            toolTipString = Locale.ConvertTextKey("TXT_KEY_PLOTROLL_UNIT_DESCRIPTION_CIV", civAdjective, toolTipString)
            if unit:HasName() then
                toolTipString = Locale.ConvertTextKey(unit:GetNameNoDesc()) .. " (" .. toolTipString .. ")"
            end
        end

        local originalOwnerID = unit:GetOriginalOwner()
        local originalOwner = originalOwnerID and Players[originalOwnerID]
        if originalOwner and originalOwnerID ~= iPlayer and activeTeam:IsHasMet(originalOwner:GetTeam()) then
            toolTipString = toolTipString .. " (" .. originalOwner:GetCivilizationAdjective() .. ")"
        end

        -- Debug stuff
        if Game.IsDebugMode() then
            toolTipString = toolTipString .. " (" .. tostring(iPlayer) .. ":" .. tostring(iUnit) .. ")"
        end

        -- Moves & Combat Strength
        local unitMoves = 0
        local unitStrength = unit:GetBaseCombatStrength() or unit:GetCombatStrength()
        -- todo unit:GetMaxDefenseStrength()
        local rangedStrength = unit:GetBaseRangedCombatStrength() or unit:GetRangedCombatStrength()


        local hp = unit:GetMaxHitPoints();


        if unit:GetDomainType() == DomainTypes.DOMAIN_AIR then
            unitStrength = rangedStrength;
            rangedStrength = 0;
            unitMoves = unit:Range();
        else
            unitMoves = unit:MovesLeft() / GameDefines.MOVE_DENOMINATOR
        end

        -- In Orbit?
        if unit.IsInOrbit and unit:IsInOrbit() then
            toolTipString = toolTipString ..
                " " .. "[COLOR_CYAN]" .. Locale.ConvertTextKey("TXT_KEY_PLOTROLL_ORBITING") .. "[ENDCOLOR]"
        else
            -- Moves
            if unitMoves > 0 then
                toolTipString = string.format("%s %.3g[ICON_MOVES]", toolTipString, unitMoves)
            end

            ---------------- Strength----------------
            if unitStrength > 0 then
                local adjustedUnitStrength = (math.max(100 + unit:GetStrategicResourceCombatPenalty(), 10) * unitStrength) /
                    100
                --todo other modifiers eg unhappy...
                if adjustedUnitStrength < unitStrength then
                    adjustedUnitStrength = " [COLOR_NEGATIVE_TEXT]" .. adjustedUnitStrength .. "[ENDCOLOR]"
                end
                toolTipString = toolTipString .. " " .. adjustedUnitStrength .. "[ICON_STRENGTH]"
            end


            -- Ranged Strength
            if rangedStrength > 0 then
                toolTipString = toolTipString .. " " .. rangedStrength .. "[ICON_RANGE_STRENGTH]" .. unit:Range() .. " "
            end

            -- Religious Fervor
            if unit.GetReligion then
                local religionID = unit:GetReligion()
                if religionID > 0 then
                    local spreadsLeft = unit:GetSpreadsLeft()
                    toolTipString = toolTipString .. " "
                    if spreadsLeft > 0 then
                        toolTipString = toolTipString .. spreadsLeft
                    end
                    toolTipString = toolTipString ..
                        ((GameInfo.Religions[religionID] or {}).IconString or "?") ..
                        Locale.ConvertTextKey(Game.GetReligionName(religionID))
                end
            end

            -- Hit Points
            ---if unit:GetDamage() > 0 then
            if not unit:IsTrade() then
                hp = unit:GetCurrHitPoints() .. "/" .. hp
            end
            toolTipString = toolTipString .. " " .. hp .. "[ICON_HP]"
        end

        -- Embarked?
        if unit:IsEmbarked() then
            toolTipString = toolTipString .. " " .. Locale.ConvertTextKey("TXT_KEY_PLOTROLL_EMBARKED")
        end

        -- Level, Experience for ActivePlayer
        if unit:IsCombatUnit() or unit:CanAirAttack() then
            toolTipString = toolTipString ..
                "[NEWLINE]" ..
                Locale.ConvertTextKey("TXT_KEY_UNIT_EXPERIENCE_INFO", unit:GetLevel(), unit:GetExperience(),
                    unit:ExperienceNeeded()):gsub("%[NEWLINE]", " ")
        end






        -- UnitCombatType?
        if unit:IsCombatUnit() then
            local item = GameInfo.UnitCombatInfos[unit:GetUnitCombatType()]
            if item then
                toolTipString = toolTipString ..
                    "[NEWLINE]" ..
                    Locale.ConvertTextKey("TXT_KEY_FLAG_UNIT_TYPE") ..
                    "[COLOR_CYAN]" .. Locale.ConvertTextKey(item.Description) .. "[ENDCOLOR]" .. " ";
            end
        end

        -- Drop:
        if unit:GetDropRange() > 0 then
            toolTipString = toolTipString ..
                "[NEWLINE]" ..
                Locale.ConvertTextKey("TXT_KEY_FLAG_UNIT_DROP_RANGE") ..
                "[COLOR_CYAN]" .. unit:GetDropRange() .. "[ENDCOLOR]" .. " "
        end


        --Upgrade:
        if unit:GetUpgradeUnitType() ~= -1 then
            local iUnitType = unit:GetUpgradeUnitType();
            local item = GameInfo.Units[iUnitType].Description
            toolTipString = toolTipString ..
                "[NEWLINE]" ..
                Locale.ConvertTextKey("TXT_KEY_FLAG_UNIT_UPGRADE") ..
                "[COLOR_YELLOW]" .. Locale.ConvertTextKey(item) .. "[ENDCOLOR]" .. " "
        end

        local unit2 = GameInfo.Units[unit:GetUnitType()]
        local productionCost = unit2.Cost
        local city, item, resource
        local activePlayer = Players[activePlayerID]
        local item
        local activeCivilization = activePlayer and GameInfo.Civilizations[activePlayer:GetCivilizationType()]
        local activeCivilizationType = activeCivilization and activeCivilization.Type

        local unitClassText;

        toolTipString = toolTipString .. "[NEWLINE]" .. "------------------------" .. "[NEWLINE]" --ÐÞ¸Ä

        if activePlayer then
            productionCost = activePlayer:GetUnitProductionNeeded(unit:GetUnitType())
        end

        -- Cost:
        local costTip
        if productionCost > 1 then -- Production cost
            if not unit2.PurchaseOnly then
                costTip = productionCost .. "[ICON_PRODUCTION]"
            end
        end -- production cost
        if costTip then
            toolTipString = toolTipString ..
                Locale.ConvertTextKey("TXT_KEY_PEDIA_COST_LABEL") ..
                " " .. (costTip or Locale.ConvertTextKey("TXT_KEY_FREE"))
        end

        if unit2.ExtraMaintenanceCost > 0 then -- ExtraMaintenanceCost cost
            ExtraMaintenanceCost = unit2.ExtraMaintenanceCost
            toolTipString = toolTipString ..
                " " .. Locale.ConvertTextKey("TXT_KEY_PEDIA_MAINT_LABEL") .. -ExtraMaintenanceCost .. "[ICON_GOLD]"
        end

        -- Resources required:

        local OtherResources = {};
        for resource in GameInfo.Resources() do
            item = Game.GetNumResourceRequiredForUnit(unit2.ID, resource.ID)
            if resource and item ~= 0 then
                table.insert(OtherResources, -item .. resource.IconString);
            end
        end

        local resourceText = {};
        for _, resource in pairs(OtherResources) do
            table.insert(resourceText, resource);
        end

        if #resourceText > 0 then
            toolTipString = toolTipString ..
                "[NEWLINE]" ..
                Locale.ConvertTextKey("TXT_KEY_PEDIA_RESOURCES_NEED") .. table.concat(resourceText, "  ") .. " "
        end



        -- Required Buildings:
        local buildings = {}
        for row in GameInfo.Unit_BuildingClassRequireds({ UnitType = unit2.Type }) do
            item = GetCivBuilding(activeCivilizationType, row.BuildingClassType)
            if item then
                table.insert(buildings, BuildingColor(Locale.ConvertTextKey(item.Description)))
            end
        end
        item = unit2.ProjectPrereq and GameInfo.Projects[unit2.ProjectPrereq]
        if unit2.ProjectPrereq then
            table.insert(buildings, BuildingColor(Locale.ConvertTextKey(item.Description)))
        end
        if #buildings > 0 then
            toolTipString = toolTipString ..
                "[NEWLINE]" ..
                Locale.ConvertTextKey("TXT_KEY_PEDIA_REQ_BLDG_LABEL") ..
                " " .. table.concat(buildings, ", ") -- UNIT_REQUIRES_BUILDING
        end


        controls.Text:SetText(toolTipString);

        -- Icons
        local iconIndex, iconAtlas = UI.GetUnitPortraitIcon(unit)
        IconHookup(iconIndex, 256, iconAtlas, controls.UnitPortrait)
        CivIconHookup(iPlayer, 64, controls.CivIcon, controls.CivIconBG, controls.CivIconShadow, false, true)

        -- UnitClass B|B Inf for ActivePlayer
        local unitClassText;
        if iPlayer == activePlayerID then
            local unitClassID = unit:GetUnitClassType();
            if player:GetUnitClassCount(unitClassID) == 0 and player:GetUnitClassMaking(unitClassID) == 0 then
            else
                if player:GetUnitClassCount(unitClassID) > 0 then
                    unitClassText = "[ICON_BULLET]" ..
                        Locale.ConvertTextKey("TXT_KEY_ACTION_CLASS_BUILT_COUNT", player:GetUnitClassCount(unitClassID));
                    if player:GetUnitClassMaking(unitClassID) > 0 then
                        unitClassText = unitClassText ..
                            " <> " ..
                            Locale.ConvertTextKey("TXT_KEY_ACTION_CLASS_BUILDING_COUNT",
                                player:GetUnitClassMaking(unitClassID));
                    end
                else
                    unitClassText = "[ICON_BULLET]" ..
                        Locale.ConvertTextKey("TXT_KEY_ACTION_CLASS_BUILDING_COUNT",
                            player:GetUnitClassMaking(unitClassID));
                end
            end
        end

        -- Promotions
        local otherPromotions = {};
        if not unit:IsTrade() then
            for unitPromotion in GameInfo.UnitPromotions() do
                if unit:IsHasPromotion(unitPromotion.ID) and unitPromotion.ShowInUnitPanel ~= 0 then
                    if unitPromotion ~= nil then
                        local promotionDescribe = unitPromotion.IconStringSP .. Locale.ConvertTextKey(unitPromotion.Description)
                        if(unitPromotion.LostWithUpgrade) then
                            promotionDescribe = Locale.ConvertTextKey("[ICON_NEGATIVE_BULLET]") .. promotionDescribe
                        else 
                            promotionDescribe = Locale.ConvertTextKey("[ICON_BULLET]") .. promotionDescribe
                        end
                        table.insert(otherPromotions,promotionDescribe);
                    end
                end
            end
        end
        local promotionText = {};
        for _, promotion in pairs(otherPromotions) do
            table.insert(promotionText, promotion);
        end



        controls.PortraitFrame:SetAnchor(UIManager.GetMousePos() > 300 and "L,T" or "R,T");
        controls.UnitClassText:SetText(unitClassText or "");
        controls.UnitClassText:SetHide(unitClassText == nil);
        controls.PromotionText:SetText(Locale.ConvertTextKey("TXT_KEY_FREEPROMOTIONS") ..
        "" .. "[NEWLINE]" .. table.concat(promotionText, "[NEWLINE]"));
        controls.PromotionText:SetHide(#promotionText == 0);
        controls.Grid:ReprocessAnchoring();
        controls.Grid:DoAutoSize();
        Controls.UnitTooltipTimer:SetToBeginning();
        Controls.UnitTooltipTimer:Reverse();
    end
end