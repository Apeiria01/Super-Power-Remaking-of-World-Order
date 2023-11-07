--==========================================================================================================================
--ArtDefine_LandmarkTypes
--==========================================================================================================================	
INSERT INTO ArtDefine_LandmarkTypes(Type, 	         LandmarkType, 	FriendlyName)
SELECT 'ART_DEF_IMPROVEMENT_SHOSHONE_WILDDOME', 	'Improvement', 	'SHOSHONE_WILDDOME';

INSERT INTO ArtDefine_LandmarkTypes(Type,		LandmarkType,	FriendlyName)
SELECT 'ART_DEF_IMPROVEMENT_INCA_CITY', 		'Improvement',	'INCA_CITY'			UNION ALL 
SELECT 'ART_DEF_IMPROVEMENT_POLYNESIA_CITY_E',	'Improvement', 	'POLYNESIA_CITY_E'	UNION ALL 
SELECT 'ART_DEF_IMPROVEMENT_POLYNESIA_CITY_SE',	'Improvement',	'POLYNESIA_CITY_SE'	UNION ALL 
SELECT 'ART_DEF_IMPROVEMENT_POLYNESIA_CITY_SW',	'Improvement',	'POLYNESIA_CITY_SW'	UNION ALL 
SELECT 'ART_DEF_IMPROVEMENT_POLYNESIA_CITY_W',	'Improvement',	'POLYNESIA_CITY_W'	UNION ALL 
SELECT 'ART_DEF_IMPROVEMENT_POLYNESIA_CITY_NW',	'Improvement',	'POLYNESIA_CITY_NW'	UNION ALL 
SELECT 'ART_DEF_IMPROVEMENT_POLYNESIA_CITY_NE',	'Improvement',	'POLYNESIA_CITY_NE';

INSERT INTO ArtDefine_LandmarkTypes(Type, LandmarkType, FriendlyName)
SELECT 'ART_DEF_IMPROVEMENT_KUNA', 	'Improvement', 	'Kuna';
--==========================================================================================================================
--ArtDefine_Landmarks
--==========================================================================================================================	
INSERT INTO ArtDefine_Landmarks
		(Era, 	State, 					Scale,	ImprovementType,						    LayoutHandler, 	ResourceType, 			Model, 										TerrainContour)
VALUES 	('Any', 'UnderConstruction', 	1.0,  	'ART_DEF_IMPROVEMENT_SHOSHONE_WILDDOME',   'SNAPSHOT', 		'ART_DEF_RESOURCE_ALL', 'North American Encampment 1 HB.fxsxml', 	1),
		('Any', 'Constructed',		 	1.0, 	'ART_DEF_IMPROVEMENT_SHOSHONE_WILDDOME',   'SNAPSHOT', 		'ART_DEF_RESOURCE_ALL', 'North American Encampment 1 B.fxsxml', 	1),
		('Any', 'Pillaged',				1.0,  	'ART_DEF_IMPROVEMENT_SHOSHONE_WILDDOME',   'SNAPSHOT', 		'ART_DEF_RESOURCE_ALL', 'North American Encampment 1 PL.fxsxml', 	1),

		('Any', 'Constructed',			1.4,  	'ART_DEF_IMPROVEMENT_INCA_CITY',   			'SNAPSHOT', 	'ART_DEF_RESOURCE_ALL', 'MachuPicchu.fxsxml',					 0.75),
		('Any', 'Constructed',			0.25,  	'ART_DEF_IMPROVEMENT_POLYNESIA_CITY_E',   	'SNAPSHOT', 	'ART_DEF_RESOURCE_ALL', 'PolyWaterCity_E.fxsxml', 				 	1),
		('Any', 'Constructed',			0.25,  	'ART_DEF_IMPROVEMENT_POLYNESIA_CITY_SE',   	'SNAPSHOT', 	'ART_DEF_RESOURCE_ALL', 'PolyWaterCity_SE.fxsxml', 				 	1),
		('Any', 'Constructed',			0.25,  	'ART_DEF_IMPROVEMENT_POLYNESIA_CITY_SW',   	'SNAPSHOT', 	'ART_DEF_RESOURCE_ALL', 'PolyWaterCity_SW.fxsxml', 				 	1),
		('Any', 'Constructed',			0.25,  	'ART_DEF_IMPROVEMENT_POLYNESIA_CITY_W',   	'SNAPSHOT', 	'ART_DEF_RESOURCE_ALL', 'PolyWaterCity_W.fxsxml', 				 	1),
		('Any', 'Constructed',			0.25,  	'ART_DEF_IMPROVEMENT_POLYNESIA_CITY_NW',   	'SNAPSHOT', 	'ART_DEF_RESOURCE_ALL', 'PolyWaterCity_NW.fxsxml', 				 	1),
		('Any', 'Constructed',			0.25,  	'ART_DEF_IMPROVEMENT_POLYNESIA_CITY_NE',   	'SNAPSHOT', 	'ART_DEF_RESOURCE_ALL', 'PolyWaterCity_NE.fxsxml', 				 	1),

		('Any', 'UnderConstruction',	1.0,  	'ART_DEF_IMPROVEMENT_KUNA',					'SNAPSHOT', 	'ART_DEF_RESOURCE_ALL', 'hb_kuna.fxsxml',					 		1),
		('Any', 'Constructed',			1.0,  	'ART_DEF_IMPROVEMENT_KUNA',   				'SNAPSHOT', 	'ART_DEF_RESOURCE_ALL', 'kuna.fxsxml',								1),
		('Any', 'Pillaged',				1.0,  	'ART_DEF_IMPROVEMENT_KUNA',   				'SNAPSHOT', 	'ART_DEF_RESOURCE_ALL', 'pl_kuna.fxsxml',					 		1);
--==========================================================================================================================
-- ArtDefine_StrategicView
--==========================================================================================================================
INSERT INTO ArtDefine_StrategicView
            (StrategicViewType,								TileType,		Asset)
VALUES      ('ART_DEF_IMPROVEMENT_SHOSHONE_WILDDOME',		'Improvement',	'SV_BeastDome.dds');
--==========================================================================================================================
--==========================================================================================================================