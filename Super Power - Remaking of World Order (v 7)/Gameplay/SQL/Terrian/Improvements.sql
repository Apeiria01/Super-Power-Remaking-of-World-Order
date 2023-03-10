-- Shoshone Wild Domesticate
--==========================================================================================================================	
-- Improvements
--==========================================================================================================================	
INSERT INTO Improvements
		(Type,							    SpecificCivRequired,	CivilizationType,		    NoTwoAdjacent,  DestroyedWhenPillaged,  Description,							    Help,										    Civilopedia,								    ArtDefineTag,						        PortraitIndex,	IconAtlas)
VALUES	('IMPROVEMENT_SHOSHONE_WILDDOME',	1,						'CIVILIZATION_SHOSHONE',    1,              1,                      'TXT_KEY_IMPROVEMENT_SHOSHONE_WILDDOME',	'TXT_KEY_IMPROVEMENT_SHOSHONE_WILDDOME_HELP',	'TXT_KEY_IMPROVEMENT_SHOSHONE_WILDDOME_HELP',	'ART_DEF_IMPROVEMENT_SHOSHONE_WILDDOME', 	2,				'SP8_EXTRA_ATLAS');
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



