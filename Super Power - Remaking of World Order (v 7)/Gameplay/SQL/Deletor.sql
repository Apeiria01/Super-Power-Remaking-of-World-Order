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


UPDATE sqlite_sequence SET seq = 0 WHERE name = 'Traits';
UPDATE sqlite_sequence SET seq = 0 WHERE name = 'Buildings';
UPDATE sqlite_sequence SET seq = 0 WHERE name = 'BuildingClasses';
UPDATE sqlite_sequence SET seq = 0 WHERE name = 'Units';
UPDATE sqlite_sequence SET seq = 0 WHERE name = 'UnitClasses';
UPDATE sqlite_sequence SET seq = 0 WHERE name = 'UnitPromotions';
UPDATE sqlite_sequence SET seq = 0 WHERE name = 'Technologies';
UPDATE sqlite_sequence SET seq = 0 WHERE name = 'Eras';


