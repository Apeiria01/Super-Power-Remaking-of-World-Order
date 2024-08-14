-- Insert SQL Rules Here 



DELETE FROM Civilization_FreeTechs;
DELETE FROM Civilization_BuildingClassOverrides;
DELETE FROM Civilization_UnitClassOverrides;
DELETE FROM Trait_ResourceQuantityModifiers;
DELETE FROM Trait_Terrains;
DELETE FROM Trait_MovesChangeUnitCombats;
DELETE FROM Trait_FreePromotionUnitCombats;
DELETE FROM Trait_FreePromotions;
DELETE FROM Trait_YieldModifiers;
DELETE FROM Trait_YieldChangesStrategicResources;
DELETE FROM Trait_YieldChanges;
DELETE FROM Trait_ExtraYieldThresholds;
DELETE FROM Trait_YieldChangesPerTradePartner;
DELETE FROM Trait_YieldChangesIncomingTradeRoute;
DELETE FROM Traits;


DELETE FROM Policy_BuildingClassHappiness;
DELETE FROM Policy_BuildingClassCultureChanges;
DELETE FROM Policy_BuildingClassYieldModifiers;
DELETE FROM Policy_BuildingClassYieldChanges;
DELETE FROM Policy_BuildingClassProductionModifiers;
DELETE FROM Policy_BuildingClassTourismModifiers;
DELETE FROM Policy_UnitCombatProductionModifiers;
DELETE FROM Policy_ImprovementCultureChanges;
DELETE FROM Policy_ImprovementYieldChanges;
DELETE FROM Policy_TourismOnUnitCreation;
DELETE FROM Policy_GreatWorkYieldChanges;
DELETE FROM Policy_SpecialistExtraYields;
DELETE FROM Policy_PrereqORPolicies;
DELETE FROM Policy_PrereqPolicies;
DELETE FROM Policy_HurryModifiers;
DELETE FROM Policy_Flavors;
DELETE FROM Policy_Disables;
DELETE FROM Policy_CapitalYieldChanges;
DELETE FROM Policy_CapitalYieldModifiers;
DELETE FROM Policy_CapitalYieldPerPopChanges;
DELETE FROM Policy_CoastalCityYieldChanges;
DELETE FROM Policy_CityYieldChanges;
DELETE FROM Policy_FreePromotions;
DELETE FROM Policy_FreeUnitClasses;


DELETE FROM Building_YieldModifiers;
DELETE FROM Building_TechEnhancedYieldChanges;
DELETE FROM Building_YieldChangesPerPop;
DELETE FROM Building_YieldChanges;
DELETE FROM Building_UnitCombatFreeExperiences;
DELETE FROM Building_SpecialistYieldChanges;
DELETE FROM Building_TerrainYieldChanges;
DELETE FROM Building_FeatureYieldChanges;
DELETE FROM Building_ResourceYieldChanges;
DELETE FROM Building_SeaResourceYieldChanges;
DELETE FROM Building_LakePlotYieldChanges;
DELETE FROM Building_SeaPlotYieldChanges;
DELETE FROM Building_RiverPlotYieldChanges;
DELETE FROM Building_ResourceCultureChanges;
DELETE FROM Building_ResourceYieldModifiers;
DELETE FROM Building_ResourceQuantityRequirements;
DELETE FROM Building_PrereqBuildingClasses;
DELETE FROM Building_LocalResourceAnds;
DELETE FROM Building_LocalResourceOrs;
DELETE FROM Building_HurryModifiers;
DELETE FROM Building_GlobalYieldModifiers;
DELETE FROM Building_Flavors;
DELETE FROM Building_DomainFreeExperiences;
DELETE FROM Building_FreeUnits;
DELETE FROM Building_ClassesNeededInCity;
DELETE FROM Building_BuildingClassYieldChanges;
DELETE FROM Building_BuildingClassHappiness;
DELETE FROM Building_ResourceQuantity;
DELETE FROM Building_DomainProductionModifiers;
DELETE FROM Building_UnitCombatProductionModifiers;
DELETE FROM Building_DomainFreeExperiencePerGreatWork;
DELETE FROM Building_YieldChangesPerReligion;
DELETE FROM Buildings;
DELETE FROM BuildingClasses;


DELETE FROM UnitPromotions_UnitCombats;
DELETE FROM UnitPromotions_UnitCombatMods;
DELETE FROM UnitPromotions_Domains;
DELETE FROM UnitPromotions_UnitClasses;
DELETE FROM UnitPromotions_Features;
DELETE FROM UnitPromotions_Terrains;
DELETE FROM UnitPromotions_PostCombatRandomPromotion;
DELETE FROM UnitPromotions_CivilianUnitType;
DELETE FROM UnitPromotions;
 
DELETE FROM Unit_ResourceQuantityRequirements;
DELETE FROM Unit_YieldFromKills;
DELETE FROM Unit_FreePromotions;
DELETE FROM Unit_ClassUpgrades;
DELETE FROM Unit_BuildingClassRequireds;
DELETE FROM Unit_Builds;
DELETE FROM Unit_AITypes;
DELETE FROM Unit_Flavors;
DELETE FROM Units;
DELETE FROM UnitClasses;


DELETE FROM Technology_PrereqTechs;
DELETE FROM Technology_ORPrereqTechs;
DELETE FROM Technology_Flavors;
DELETE FROM Technology_DomainExtraMoves;
DELETE FROM Technology_TradeRouteDomainExtraRange;
DELETE FROM Technologies;


DELETE FROM Improvement_TechFreshWaterYieldChanges;
DELETE FROM Improvement_TechNoFreshWaterYieldChanges;

DELETE FROM Eras;

DELETE FROM GameSpeed_Turns;

DELETE FROM HandicapInfo_AIFreeTechs;

DELETE FROM HandicapInfo_Goodies;
DELETE FROM GoodyHuts;

UPDATE sqlite_sequence SET seq = 0 WHERE name = 'Traits';
UPDATE sqlite_sequence SET seq = 0 WHERE name = 'Buildings';
UPDATE sqlite_sequence SET seq = 0 WHERE name = 'BuildingClasses';
UPDATE sqlite_sequence SET seq = 0 WHERE name = 'Units';
UPDATE sqlite_sequence SET seq = 0 WHERE name = 'UnitClasses';
UPDATE sqlite_sequence SET seq = 0 WHERE name = 'UnitPromotions';
UPDATE sqlite_sequence SET seq = 0 WHERE name = 'Technologies';
UPDATE sqlite_sequence SET seq = 0 WHERE name = 'Eras';

--Some Special Trigger for SPsubmod
CREATE TABLE SPTriggerControler (TriggerType text PRIMARY KEY, Enabled boolean);
INSERT INTO SPTriggerControler(TriggerType,Enabled)
SELECT 'SPNRligionDeleteEffect',0 UNION ALL
SELECT 'SPNDeleteALLUnitStrategicFlag',0 UNION ALL
SELECT 'Policy_Bill_Of_Right_Trigger',0 UNION ALL
SELECT 'Minor_Units_Overrides_Trigger',0 UNION ALL
SELECT 'Minor_Building_Overrides_Trigger',0;

--DROP TRIGGER SPNRligionDeleteEffect;
CREATE TRIGGER IF NOT EXISTS SPNRligionDeleteEffect 
BEFORE DELETE ON Beliefs
WHEN (SELECT Enabled FROM SPTriggerControler WHERE TriggerType = 'SPNRligionDeleteEffect') = 1
BEGIN
    DELETE FROM Belief_BuildingClassFaithPurchase WHERE BeliefType = OLD.Type;
    DELETE FROM Belief_BuildingClassHappiness WHERE BeliefType = OLD.Type;
    DELETE FROM Belief_BuildingClassTourism WHERE BeliefType = OLD.Type;
    DELETE FROM Belief_BuildingClassYieldChanges WHERE BeliefType = OLD.Type;
    DELETE FROM Belief_CapitalYieldChanges WHERE BeliefType = OLD.Type;
    DELETE FROM Belief_CityYieldChanges WHERE BeliefType = OLD.Type;
    DELETE FROM Belief_CityYieldFromUnimprovedFeature WHERE BeliefType = OLD.Type;
    DELETE FROM Belief_CoastalCityYieldChanges WHERE BeliefType = OLD.Type;
    DELETE FROM Belief_EraFaithUnitPurchase WHERE BeliefType = OLD.Type;
    DELETE FROM Belief_FeatureYieldChanges WHERE BeliefType = OLD.Type;
    DELETE FROM Belief_GoldenAgeGreatPersonRateModifier WHERE BeliefType = OLD.Type;
    DELETE FROM Belief_GreatPersonExpendedYield WHERE BeliefType = OLD.Type;
    DELETE FROM Belief_GreatWorkYieldChanges WHERE BeliefType = OLD.Type;
    DELETE FROM Belief_HolyCityYieldChanges WHERE BeliefType = OLD.Type;
    DELETE FROM Belief_ImprovementYieldChanges WHERE BeliefType = OLD.Type;
    DELETE FROM Belief_MaxYieldModifierPerFollower WHERE BeliefType = OLD.Type;
    DELETE FROM Belief_PlotYieldChanges WHERE BeliefType = OLD.Type;
    DELETE FROM Belief_ResourceHappiness WHERE BeliefType = OLD.Type;
    DELETE FROM Belief_ResourceQuantityModifiers WHERE BeliefType = OLD.Type;
    DELETE FROM Belief_ResourceYieldChanges WHERE BeliefType = OLD.Type;
    DELETE FROM Belief_SpecialistYieldChanges WHERE BeliefType = OLD.Type;
    DELETE FROM Belief_TerrainYieldChanges WHERE BeliefType = OLD.Type;
    DELETE FROM Belief_TradeRouteYieldChange WHERE BeliefType = OLD.Type;
    DELETE FROM Belief_UnimprovedFeatureYieldChanges WHERE BeliefType = OLD.Type;
    DELETE FROM Belief_YieldChangeAnySpecialist WHERE BeliefType = OLD.Type;
    DELETE FROM Belief_YieldChangeNaturalWonder WHERE BeliefType = OLD.Type;
    DELETE FROM Belief_YieldChangePerForeignCity WHERE BeliefType = OLD.Type;
    DELETE FROM Belief_YieldChangePerXForeignFollowers WHERE BeliefType = OLD.Type;
    DELETE FROM Belief_YieldChangeTradeRoute WHERE BeliefType = OLD.Type;
    DELETE FROM Belief_YieldChangeWorldWonder WHERE BeliefType = OLD.Type;
    DELETE FROM Belief_YieldFromBarbarianKills WHERE BeliefType = OLD.Type;
    DELETE FROM Belief_YieldFromKills WHERE BeliefType = OLD.Type;
    DELETE FROM Belief_YieldModifierNaturalWonder WHERE BeliefType = OLD.Type;
    DELETE FROM Belief_YieldPerFollowingCity WHERE BeliefType = OLD.Type;
    DELETE FROM Belief_YieldPerOtherReligionFollower WHERE BeliefType = OLD.Type;
    DELETE FROM Belief_YieldPerXFollowers WHERE BeliefType = OLD.Type;
END;

CREATE TRIGGER IF NOT EXISTS SPNDeleteALLUnitStrategicFlag1
AFTER UPDATE ON SPTriggerControler
WHEN NEW.TriggerType = 'SPNDeleteALLUnitStrategicFlag' AND NEW.Enabled = 1
BEGIN
	DELETE FROM ArtDefine_StrategicView WHERE TileType = 'Unit';
END;

CREATE TRIGGER IF NOT EXISTS SPNDeleteALLUnitStrategicFlag2
AFTER INSERT ON ArtDefine_StrategicView
WHEN (SELECT Enabled FROM SPTriggerControler WHERE TriggerType = 'SPNDeleteALLUnitStrategicFlag') = 1
AND NEW.TileType = 'Unit'
BEGIN
	DELETE FROM ArtDefine_StrategicView WHERE StrategicViewType = NEW.StrategicViewType;
END;

CREATE TRIGGER IF NOT EXISTS SPNDeleteALLUnitStrategicFlag3
AFTER INSERT ON Units
WHEN (SELECT Enabled FROM SPTriggerControler WHERE TriggerType = 'SPNDeleteALLUnitStrategicFlag') = 1
BEGIN
	DELETE FROM ArtDefine_StrategicView WHERE StrategicViewType = NEW.UnitArtInfo;
END;

CREATE TABLE SPNewEffectControler (Type text PRIMARY KEY, Enabled boolean);
INSERT INTO SPNewEffectControler (Type,Enabled)
SELECT 'SP_NEWATTACK_OFF',0 UNION ALL
SELECT 'SP_DELETE_ALL_STRATEGIC_UNIT_FLAG',0 UNION ALL
SELECT 'SP_ALL_UB_ACTIVE',0 UNION ALL
SELECT 'UNIT_DEATH_COUNTER_OFF',0;

--UPDATE SPTriggerControler SET Enabled = 1 WHERE TriggerType = 'SPNDeleteALLUnitStrategicFlag';
--UPDATE SPNewEffectControler SET Enabled = 1 WHERE Type = 'SP_DELETE_ALL_STRATEGIC_UNIT_FLAG';