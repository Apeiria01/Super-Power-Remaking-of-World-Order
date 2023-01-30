-- Atztec UW

local SacrificeMissionFaithRate = GameDefines["AZTEC_UB_FAITH_RATE"];
local SacrificeMissionCultureRate = GameDefines["AZTEC_UB_CULTURE_RATE"];
local SacrificeMissionPromotionProbability = GameDefines["AZTEC_UB_PROMOTION_PROBABILITY"];
SacrificeMissionButton = {
    Name = "Sacrifice",
    Title = "TXT_KEY_SP_MISSION_SACRIFICE_TITLE", -- or a TXT_KEY
    OrderPriority = 300, -- default is 200
    IconAtlas = "BUILDING_AZTEC_ATLAS", -- 45 and 64 variations required
    PortraitIndex = 0,
    ToolTip = Locale.ConvertTextKey("TXT_KEY_SP_MISSION_SACRIFICE_TOOL_TIP", SacrificeMissionFaithRate, SacrificeMissionCultureRate), -- or a TXT_KEY_ or a function

    Condition = function(action, unit)
        return (unit:CanMove()
            and unit:GetBaseCombatStrength() > 0
            and unit:GetDomainType() == DomainTypes.DOMAIN_LAND
            and unit:GetPlot():IsCity()
            and unit:GetPlot():GetPlotCity():GetOwner() == unit:GetOwner() 
            and unit:GetPlot():GetPlotCity():IsHasBuilding(GameInfoTypes["BUILDING_AZTEC_HUEY_TEOCALLI_SP"]));
    end, -- or nil or a boolean, default is true

    Disabled = function(action, unit)
        return unit:IsHasPromotion(GameInfoTypes["PROMOTION_AZTEC_HUEY_TEOCALLI"]);
    end, -- or nil or a boolean, default is false

    Action = function(action, unit, eClick)
        local plot = unit:GetPlot();
        local city = plot:GetPlotCity()
        local player = Players[unit:GetOwner()]
        if not city then return end

        local strength = unit:GetBaseCombatStrength();
        player:ChangeJONSCulture(strength * SacrificeMissionCultureRate / 100);
        player:ChangeFaith(strength * SacrificeMissionFaithRate / 100);

        --local iRand = math.random(1, 100);
        local iRand = Game.Rand(100, "At UnitSpecialButtons_SP8.lua SacrificeMissionButton, result for sacrifice") + 1
        if iRand <= SacrificeMissionPromotionProbability then
            unit:SetHasPromotion(GameInfoTypes["PROMOTION_AZTEC_HUEY_TEOCALLI"], true);
            unit:SetMoves(0);
        else
            unit:Kill();
        end

    end,
};
LuaEvents.UnitPanelActionAddin(SacrificeMissionButton);

SupplyExoticGoodsMissionButton = {
    Name = "SupplyExoticGoods",
    Title = "TXT_KEY_SP_MISSION_SUPPLY_EXOTIC_GOODS_TITLE", -- or a TXT_KEY
    OrderPriority = 300, -- default is 200
    IconAtlas = "EXPANSION2_UNIT_ATLAS", -- 45 and 64 variations required
    PortraitIndex = 13,
    ToolTip = "TXT_KEY_SP_MISSION_SUPPLY_EXOTIC_GOODS_TOOLTIP", -- or a TXT_KEY_ or a function

    Condition = function(action, unit)
        return (unit:GetUnitType() == GameInfoTypes["UNIT_PORTUGUESE_NAU"]
            and unit:CanMove()
            and unit:GetPlot():IsCity()
            and unit:GetPlot():GetPlotCity():IsHasBuilding(GameInfoTypes["BUILDING_PORTUGAL_PORT"]));
    end, -- or nil or a boolean, default is true

    Disabled = function(action, unit)
        return unit:MovesLeft() < unit:MaxMoves() or unit:GetNumExoticGoodsMax() <= unit:GetNumExoticGoods();
    end, -- or nil or a boolean, default is false

    Action = function(action, unit, eClick)
        unit:ChangeNumExoticGoods(1);
        unit:SetMoves(0);
    end,
};
LuaEvents.UnitPanelActionAddin(SupplyExoticGoodsMissionButton);

print("UnitSpecialButtons_SP8: Check Pass!");