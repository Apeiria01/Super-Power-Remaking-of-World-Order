-- Shoshone Wild Domesticate
--==========================================================================================================================	
-- Improvements
--==========================================================================================================================	
INSERT INTO Improvements
		(Type,							    SpecificCivRequired,	CivilizationType,		    NoTwoAdjacent,  DestroyedWhenPillaged,  Description,							    Help,										    Civilopedia,								    ArtDefineTag,						        PortraitIndex,	IconAtlas,				CreatedItemMod, CreatedResourceQuantity, IsFreshWater)
VALUES	('IMPROVEMENT_SHOSHONE_WILDDOME',	1,						'CIVILIZATION_SHOSHONE',    1,              1,                      'TXT_KEY_IMPROVEMENT_SHOSHONE_WILDDOME',	'TXT_KEY_IMPROVEMENT_SHOSHONE_WILDDOME_HELP',	'TXT_KEY_IMPROVEMENT_SHOSHONE_WILDDOME_HELP',	'ART_DEF_IMPROVEMENT_SHOSHONE_WILDDOME', 	0,				'SP_IMPROVEMENT_ATLAS',	3,				1,						 1);

INSERT INTO Improvements
		(Type,					Description,					Civilopedia,							Help,									ArtDefineTag,						PortraitIndex,	IconAtlas,				NoTwoAdjacent,	OutsideBorders,	BuildableOnResources,	RequiresFlatlands,	DestroyedWhenPillaged)
VALUES	('IMPROVEMENT_CAIRN',	'TXT_KEY_IMPROVEMENT_CAIRN_SP',	'TXT_KEY_IMPROVEMENT_CAIRN_SP_TEXT',	'TXT_KEY_IMPROVEMENT_CAIRN_SP_HELP',	'ART_DEF_IMPROVEMENT_STONE_ALTAR',	2,				'SP_IMPROVEMENT_ATLAS',	1,				0,				0,						0,					1);

INSERT OR REPLACE INTO Improvements
		(Type,								Description,							ArtDefineTag,							GraphicalOnly,	Water,	AllowsWalkWater)
SELECT	'IMPROVEMENT_INCA_CITY',			'TXT_KEY_IMPROVEMENT_INCA_CITY',		'ART_DEF_IMPROVEMENT_INCA_CITY',	 	1, 				0,		0	UNION ALL
SELECT	'IMPROVEMENT_POLYNESIA_CITY_E',		'TXT_KEY_IMPROVEMENT_POLYNESIA_CITY',	'ART_DEF_IMPROVEMENT_POLYNESIA_CITY_E',	1,				1,		1	UNION ALL
SELECT	'IMPROVEMENT_POLYNESIA_CITY_SE',	'TXT_KEY_IMPROVEMENT_POLYNESIA_CITY',	'ART_DEF_IMPROVEMENT_POLYNESIA_CITY_SE',1,				1,		1	UNION ALL
SELECT	'IMPROVEMENT_POLYNESIA_CITY_SW',	'TXT_KEY_IMPROVEMENT_POLYNESIA_CITY',	'ART_DEF_IMPROVEMENT_POLYNESIA_CITY_SW',1,				1,		1	UNION ALL
SELECT	'IMPROVEMENT_POLYNESIA_CITY_W',		'TXT_KEY_IMPROVEMENT_POLYNESIA_CITY',	'ART_DEF_IMPROVEMENT_POLYNESIA_CITY_W',	1,				1,		1	UNION ALL
SELECT	'IMPROVEMENT_POLYNESIA_CITY_NW',	'TXT_KEY_IMPROVEMENT_POLYNESIA_CITY',	'ART_DEF_IMPROVEMENT_POLYNESIA_CITY_NW',1,				1,		1	UNION ALL
SELECT	'IMPROVEMENT_POLYNESIA_CITY_NE',	'TXT_KEY_IMPROVEMENT_POLYNESIA_CITY',	'ART_DEF_IMPROVEMENT_POLYNESIA_CITY_NE',1,				1,		1;
--==========================================================================================================================	
-- Improvement_ValidTerrains
--==========================================================================================================================	
INSERT INTO Improvement_ValidTerrains
		(ImprovementType,					TerrainType)
VALUES	('IMPROVEMENT_SHOSHONE_WILDDOME',	'TERRAIN_GRASS'),
		('IMPROVEMENT_SHOSHONE_WILDDOME',	'TERRAIN_TUNDRA'),
		('IMPROVEMENT_SHOSHONE_WILDDOME',	'TERRAIN_PLAINS'),
		('IMPROVEMENT_CAIRN',				'TERRAIN_GRASS'),
		('IMPROVEMENT_CAIRN',				'TERRAIN_PLAINS'),
		('IMPROVEMENT_CAIRN',				'TERRAIN_TUNDRA'),
		('IMPROVEMENT_CAIRN',				'TERRAIN_SNOW'),
		('IMPROVEMENT_CAIRN',				'TERRAIN_DESERT');
--==========================================================================================================================	
-- Improvement_Flavors
--==========================================================================================================================	
INSERT INTO Improvement_Flavors
		(ImprovementType,					FlavorType,					Flavor)
VALUES	('IMPROVEMENT_SHOSHONE_WILDDOME',	'FLAVOR_TILE_IMPROVEMENT',	40),
		('IMPROVEMENT_SHOSHONE_WILDDOME',	'FLAVOR_GROWTH',			20),
		('IMPROVEMENT_CAIRN',				'FLAVOR_RELIGION',			5);
--==========================================================================================================================	
-- Builds
--==========================================================================================================================	
INSERT INTO Builds
		(Type,						PrereqTech,			ImprovementType, 				    Time, 	Recommendation,						    Description,					    Help,										    OrderPriority,	AltDown,    IconIndex,	IconAtlas,				EntityEvent,            HotKey)
VALUES	('BUILD_SHOSHONE_WILDDOME',	'TECH_GUNPOWDER',	'IMPROVEMENT_SHOSHONE_WILDDOME',	1300,  'TXT_KEY_BUILD_SHOSHONE_WILDDOME_REC', 	'TXT_KEY_BUILD_SHOSHONE_WILDDOME',	'TXT_KEY_IMPROVEMENT_SHOSHONE_WILDDOME_HELP',	1,				1,          1,			'SP_IMPROVEMENT_ATLAS',	'ENTITY_EVENT_CHOP',    'KB_C');

INSERT INTO Builds
		(Type,			Time,	PrereqTech,			ObsoleteTech,		ImprovementType,		Description,				Help,							Recommendation,					EntityEvent,			HotKey,		OrderPriority,		IconIndex,	IconAtlas)
VALUES	('BUILD_CAIRN',	400,	'TECH_POTTERY',		'TECH_EDUCATION',	'IMPROVEMENT_CAIRN',	'TXT_KEY_BUILD_CAIRN_SP', 	'TXT_KEY_BUILD_CAIRN_SP_HELP',	'TXT_KEY_BUILD_CAIRN_SP_REC',	'ENTITY_EVENT_BUILD',	'KB_M',		98,          		3,			'SP_IMPROVEMENT_ATLAS');
--==========================================================================================================================	
-- BuildFeatures
--==========================================================================================================================	
INSERT INTO BuildFeatures
		(BuildType,						FeatureType,		PrereqTech,				Time,	Remove)
VALUES	('BUILD_SHOSHONE_WILDDOME',		'FEATURE_JUNGLE',	'TECH_BRONZE_WORKING',	700,	0),
		('BUILD_SHOSHONE_WILDDOME',		'FEATURE_FOREST',	NULL,	    			400,	0);
--==========================================================================================================================	
-- Unit_Builds
--==========================================================================================================================	
INSERT INTO Unit_Builds
		(UnitType,			BuildType)
VALUES	('UNIT_WORKER',		'BUILD_SHOSHONE_WILDDOME'),
		('UNIT_WORKER',		'BUILD_CAIRN');
--==========================================================================================================================	
-- Improvements_Create_Collection
--==========================================================================================================================	
INSERT INTO Improvements_Create_Collection(ImprovementType,TerrainType,TerrainOnly,FeatureType,FeatureOnly,ResourceType)
SELECT 'IMPROVEMENT_ETHIOPIA_COFFEE','TERRAIN_GRASS',1,NULL,0,'RESOURCE_COFFEE' UNION ALL
SELECT 'IMPROVEMENT_ETHIOPIA_COFFEE','TERRAIN_PLAINS',1,NULL,0,'RESOURCE_COCOA' UNION ALL

SELECT 'IMPROVEMENT_SHOSHONE_WILDDOME',NULL,0,NULL,0,'RESOURCE_TRUFFLES' UNION ALL
SELECT 'IMPROVEMENT_SHOSHONE_WILDDOME',NULL,0,NULL,0,'RESOURCE_FUR' UNION ALL
SELECT 'IMPROVEMENT_SHOSHONE_WILDDOME',NULL,0,NULL,0,'RESOURCE_BISON' UNION ALL
SELECT 'IMPROVEMENT_SHOSHONE_WILDDOME',NULL,0,NULL,0,'RESOURCE_DEER' UNION ALL
SELECT 'IMPROVEMENT_SHOSHONE_WILDDOME',NULL,0,NULL,0,'RESOURCE_IVORY';

--==========================================================================================================================	
-- Misc Changes
--==========================================================================================================================	
UPDATE Improvements Set ExtraScore = -2000 WHERE Type = 'IMPROVEMENT_CUSTOMS_HOUSE';
UPDATE Improvements Set ExtraScore = -100 WHERE Type = 'IMPROVEMENT_TRADING_POST';
UPDATE Improvements Set ExtraScore = -100 WHERE Type = 'IMPROVEMENT_CAIRN_SP';
UPDATE Improvements Set ExtraScore = 100 WHERE Type = 'IMPROVEMENT_BYZANTIUM_ANGELOKASTRO';
UPDATE Improvements Set ExtraScore = 100 WHERE Type = 'IMPROVEMENT_BRAZILWOOD_CAMP';
UPDATE Improvements Set ExtraScore = 100 WHERE Type = 'IMPROVEMENT_CHATEAU';
UPDATE Improvements Set ExtraScore = 200 WHERE Type = 'IMPROVEMENT_IROQUOIAN_FOREST_FARM';
UPDATE Improvements Set ExtraScore = 200 WHERE Type = 'IMPROVEMENT_TERRACE_FARM';
UPDATE Improvements Set ExtraScore = 250 WHERE Type = 'IMPROVEMENT_MOAI';
UPDATE Improvements Set ExtraScore = 300 WHERE Type = 'IMPROVEMENT_MAYA_ALTAR';
UPDATE Improvements Set ExtraScore = 700 WHERE Type = 'IMPROVEMENT_ETHIOPIA_COFFEE';
UPDATE Improvements Set ExtraScore = 900 WHERE Type = 'IMPROVEMENT_SHOSHONE_WILDDOME';
UPDATE Improvements Set ExtraScore = 300 WHERE Type = 'IMPROVEMENT_CREATE_FOREST_MOD';
UPDATE Improvements Set ExtraScore = 300 WHERE Type = 'IMPROVEMENT_CREATE_JUNGLE_MOD';
--UPDATE Improvements Set ExtraScore = 2000 WHERE Type = 'IMPROVEMENT_CITADEL';
--UPDATE Improvements Set ExtraScore = 2000 WHERE Type = 'IMPROVEMENT_COASTAL_FORT';

--BUG fix: Superfluous Archaeologist may cause some problems
UPDATE Improvements Set ForbidSameBuildUnitClasses = 'UNITCLASS_ARCHAEOLOGIST' WHERE Type = 'IMPROVEMENT_LANDMARK';

UPDATE Improvements Set RequiresFeature = 0, RemoveWhenSetNoFuture = 1, NumWaterPlotMakesValid = 3, RequiresFlatlands = 1 WHERE Type = 'IMPROVEMENT_POLDER';
-- IMPROVEMENT_CAIRN
INSERT INTO Improvement_Yields (ImprovementType,		YieldType,					Yield)
SELECT 							'IMPROVEMENT_CAIRN',	'YIELD_FAITH',				1 UNION ALL
SELECT 							'IMPROVEMENT_CAIRN',	'YIELD_GOLDEN_AGE_POINTS',	1;