-- Shoshone Wild Domesticate
--==========================================================================================================================	
-- Improvements
--==========================================================================================================================	
INSERT INTO Improvements
		(Type,							    SpecificCivRequired,	CivilizationType,		    NoTwoAdjacent,  DestroyedWhenPillaged,  Description,							    Help,										    Civilopedia,								    ArtDefineTag,						        PortraitIndex,	IconAtlas,			CreatedItemMod, CreatedResourceQuantity, IsFreshWater)
VALUES	('IMPROVEMENT_SHOSHONE_WILDDOME',	1,						'CIVILIZATION_SHOSHONE',    1,              1,                      'TXT_KEY_IMPROVEMENT_SHOSHONE_WILDDOME',	'TXT_KEY_IMPROVEMENT_SHOSHONE_WILDDOME_HELP',	'TXT_KEY_IMPROVEMENT_SHOSHONE_WILDDOME_HELP',	'ART_DEF_IMPROVEMENT_SHOSHONE_WILDDOME', 	2,				'SP8_EXTRA_ATLAS',	3,				1,						 1);

INSERT OR REPLACE INTO Improvements
		(Type,								Description,							ArtDefineTag,							GraphicalOnly,	Water)
SELECT	'IMPROVEMENT_INCA_CITY',			'TXT_KEY_IMPROVEMENT_INCA_CITY',		'ART_DEF_IMPROVEMENT_INCA_CITY',	 	1, 				0	UNION ALL
SELECT	'IMPROVEMENT_POLYNESIA_CITY_E',		'TXT_KEY_IMPROVEMENT_POLYNESIA_CITY',	'ART_DEF_IMPROVEMENT_POLYNESIA_CITY_E',	1,				1	UNION ALL
SELECT	'IMPROVEMENT_POLYNESIA_CITY_SE',	'TXT_KEY_IMPROVEMENT_POLYNESIA_CITY',	'ART_DEF_IMPROVEMENT_POLYNESIA_CITY_SE',1,				1	UNION ALL
SELECT	'IMPROVEMENT_POLYNESIA_CITY_SW',	'TXT_KEY_IMPROVEMENT_POLYNESIA_CITY',	'ART_DEF_IMPROVEMENT_POLYNESIA_CITY_SW',1,				1	UNION ALL
SELECT	'IMPROVEMENT_POLYNESIA_CITY_W',		'TXT_KEY_IMPROVEMENT_POLYNESIA_CITY',	'ART_DEF_IMPROVEMENT_POLYNESIA_CITY_W',	1,				1	UNION ALL
SELECT	'IMPROVEMENT_POLYNESIA_CITY_NW',	'TXT_KEY_IMPROVEMENT_POLYNESIA_CITY',	'ART_DEF_IMPROVEMENT_POLYNESIA_CITY_NW',1,				1	UNION ALL
SELECT	'IMPROVEMENT_POLYNESIA_CITY_NE',	'TXT_KEY_IMPROVEMENT_POLYNESIA_CITY',	'ART_DEF_IMPROVEMENT_POLYNESIA_CITY_NE',1,				1;
--==========================================================================================================================	
-- Improvement_ValidTerrains
--==========================================================================================================================	
INSERT INTO Improvement_ValidTerrains
		(ImprovementType,					TerrainType)
VALUES	('IMPROVEMENT_SHOSHONE_WILDDOME',	'TERRAIN_GRASS'),
		('IMPROVEMENT_SHOSHONE_WILDDOME',	'TERRAIN_TUNDRA'),
		('IMPROVEMENT_SHOSHONE_WILDDOME',	'TERRAIN_PLAINS');
--==========================================================================================================================	
-- Improvement_Flavors
--==========================================================================================================================	
INSERT INTO Improvement_Flavors
		(ImprovementType,					FlavorType,					Flavor)
VALUES	('IMPROVEMENT_SHOSHONE_WILDDOME',	'FLAVOR_TILE_IMPROVEMENT',	40),
		('IMPROVEMENT_SHOSHONE_WILDDOME',	'FLAVOR_GROWTH',			20);
--==========================================================================================================================	
-- Builds
--==========================================================================================================================	
INSERT INTO Builds
		(Type,						PrereqTech,			ImprovementType, 				    Time, Recommendation,						    Description,					    Help,										    OrderPriority,	AltDown,    IconIndex,	IconAtlas,			EntityEvent,            HotKey)
VALUES	('BUILD_SHOSHONE_WILDDOME',	'TECH_GUNPOWDER',	'IMPROVEMENT_SHOSHONE_WILDDOME',	1300,  'TXT_KEY_BUILD_SHOSHONE_WILDDOME_REC', 	'TXT_KEY_BUILD_SHOSHONE_WILDDOME',	'TXT_KEY_IMPROVEMENT_SHOSHONE_WILDDOME_HELP',	1,				1,          3,			'SP8_EXTRA_ATLAS',	'ENTITY_EVENT_CHOP',    'KB_C');
--==========================================================================================================================	
-- BuildFeatures
--==========================================================================================================================	
INSERT INTO BuildFeatures
		(BuildType,						FeatureType,		PrereqTech,				Time,	Remove)
VALUES	('BUILD_SHOSHONE_WILDDOME',		'FEATURE_JUNGLE',	'TECH_GUNPOWDER',	    100,	0),
		('BUILD_SHOSHONE_WILDDOME',		'FEATURE_FOREST',	'TECH_GUNPOWDER',	    100,	0);
--==========================================================================================================================	
-- Unit_Builds
--==========================================================================================================================	
INSERT INTO Unit_Builds
		(UnitType,			BuildType)
VALUES	('UNIT_WORKER',		'BUILD_SHOSHONE_WILDDOME');
--==========================================================================================================================	
-- Improvements_Create_Collection
--==========================================================================================================================	
INSERT INTO Improvements_Create_Collection(ImprovementType,TerrainType,TerrainOnly,FeatureType,FeatureOnly,ResourceType)
SELECT 'IMPROVEMENT_FISHERY_MOD',NULL,0,NULL,0,'RESOURCE_FISH' UNION ALL
SELECT 'IMPROVEMENT_GAS_RIG_MOD',NULL,0,NULL,0,'RESOURCE_NATRUALGAS' UNION ALL

SELECT 'IMPROVEMENT_ETHIOPIA_COFFEE','TERRAIN_GRASS',1,NULL,0,'RESOURCE_COFFEE' UNION ALL
SELECT 'IMPROVEMENT_ETHIOPIA_COFFEE','TERRAIN_PLAINS',1,NULL,0,'RESOURCE_COCOA' UNION ALL

SELECT 'IMPROVEMENT_SHOSHONE_WILDDOME',NULL,0,NULL,0,'RESOURCE_TRUFFLES' UNION ALL
SELECT 'IMPROVEMENT_SHOSHONE_WILDDOME',NULL,0,NULL,0,'RESOURCE_FUR' UNION ALL
SELECT 'IMPROVEMENT_SHOSHONE_WILDDOME',NULL,0,NULL,0,'RESOURCE_BISON' UNION ALL
SELECT 'IMPROVEMENT_SHOSHONE_WILDDOME',NULL,0,NULL,0,'RESOURCE_DEER' UNION ALL
SELECT 'IMPROVEMENT_SHOSHONE_WILDDOME',NULL,0,NULL,0,'RESOURCE_IVORY';

UPDATE Improvements Set ExtraScore = -100 WHERE Type = 'IMPROVEMENT_TRADING_POST';
UPDATE Improvements Set ExtraScore = 100 WHERE Type = 'IMPROVEMENT_BYZANTIUM_ANGELOKASTRO';
UPDATE Improvements Set ExtraScore = 100 WHERE Type = 'IMPROVEMENT_BRAZILWOOD_CAMP';
UPDATE Improvements Set ExtraScore = 100 WHERE Type = 'IMPROVEMENT_CHATEAU';
UPDATE Improvements Set ExtraScore = 200 WHERE Type = 'IMPROVEMENT_TERRACE_FARM';
UPDATE Improvements Set ExtraScore = 250 WHERE Type = 'IMPROVEMENT_MOAI';
UPDATE Improvements Set ExtraScore = 700 WHERE Type = 'IMPROVEMENT_ETHIOPIA_COFFEE';
UPDATE Improvements Set ExtraScore = 900 WHERE Type = 'IMPROVEMENT_SHOSHONE_WILDDOME';