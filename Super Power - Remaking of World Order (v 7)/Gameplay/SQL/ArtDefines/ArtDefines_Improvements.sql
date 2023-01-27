--==========================================================================================================================
-- BuildingClasses
--==========================================================================================================================	
INSERT INTO ArtDefine_LandmarkTypes(Type, 	         LandmarkType, 	FriendlyName)
SELECT 'ART_DEF_IMPROVEMENT_SHOSHONE_WILDDOME', 	'Improvement', 	'SHOSHONE_WILDDOME';
--==========================================================================================================================
-- BuildingClasses
--==========================================================================================================================	
INSERT INTO ArtDefine_Landmarks
		(Era, 	State, 					Scale,	ImprovementType,						    LayoutHandler, 	ResourceType, 			Model, 										TerrainContour)
VALUES 	('Any', 'UnderConstruction', 	1.0,  	'ART_DEF_IMPROVEMENT_SHOSHONE_WILDDOME',   'SNAPSHOT', 		'ART_DEF_RESOURCE_ALL', 'North American Encampment 1 HB.fxsxml', 	1),
		('Any', 'Constructed',		 	1.0, 	'ART_DEF_IMPROVEMENT_SHOSHONE_WILDDOME',   'SNAPSHOT', 		'ART_DEF_RESOURCE_ALL', 'North American Encampment 1 B.fxsxml', 	1),
		('Any', 'Pillaged',				1.0,  	'ART_DEF_IMPROVEMENT_SHOSHONE_WILDDOME',   'SNAPSHOT', 		'ART_DEF_RESOURCE_ALL', 'North American Encampment 1 PL.fxsxml', 	1);

--==========================================================================================================================
-- ArtDefine_StrategicView
--==========================================================================================================================
INSERT INTO ArtDefine_StrategicView
            (StrategicViewType,								TileType,		Asset)
VALUES      ('ART_DEF_IMPROVEMENT_SHOSHONE_WILDDOME',		'Improvement',	'SV_BeastDome.dds');
--==========================================================================================================================
--==========================================================================================================================