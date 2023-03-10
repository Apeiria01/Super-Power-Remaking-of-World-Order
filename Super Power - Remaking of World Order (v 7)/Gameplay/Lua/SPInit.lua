--[[Init file for all the New lua Effects. This file gets called by InGameUIAddin and is the 
entry point for most of the mod. The contexts below are loaded after all the contexts in
InGame.xml.]]

-- InGame New Effect

-- DLL-VMC -- STFU
include( "Stfu" )

-- SP - All
include( "UtilityFunctions" )
-- AI
include("NewHandicap");
-- Combat
include("NewCombatRules");
include("NewUnitsRules");
-- Economy
include("NewBuildingEffects");
include("NewCityRule");
include("NewPolicyEffects");
include("SP8PolicyEffects");
include("NewPopulationRule");
include("NewTraitEffects");
include("NuclearWinter");
-- Misc
include("TerrainTransform");
include("UnitSpecialButtons");
include("UnitSpecialButtons_SP8");
-- Utility
include("Policy_FreeBuildingClass");
-- CSD
include("NewCityStateDiplomaticRule");
ContextPtr:LoadNewContext("ModOptions");