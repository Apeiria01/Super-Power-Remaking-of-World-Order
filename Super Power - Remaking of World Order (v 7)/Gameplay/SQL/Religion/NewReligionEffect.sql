--***********************************************************************************************--
--Pantheon
--***********************************************************************************************--
INSERT INTO Belief_ResourceYieldChanges (BeliefType,ResourceType,YieldType,Yield)
SELECT 'BELIEF_OPEN_SKY','RESOURCE_COW','YIELD_FAITH',1 UNION ALL
SELECT 'BELIEF_OPEN_SKY','RESOURCE_SHEEP','YIELD_FOOD',1 UNION ALL
SELECT 'BELIEF_OPEN_SKY','RESOURCE_HORSE','YIELD_PRODUCTION',1;

UPDATE Beliefs SET MinPopulation = '0' WHERE Type = 'BELIEF_GODDESS_LOVE';

INSERT INTO Belief_FeatureYieldChanges (BeliefType,FeatureType,YieldType,Yield)
SELECT 'BELIEF_GODDESS_OF_PURITY','FEATURE_FOUNTAIN_YOUTH','YIELD_FOOD',4 UNION ALL
SELECT 'BELIEF_GODDESS_OF_PURITY','FEATURE_FOUNTAIN_YOUTH','YIELD_FAITH',4 UNION ALL
SELECT 'BELIEF_GODDESS_OF_PURITY','FEATURE_FOUNTAIN_YOUTH','YIELD_PRODUCTION',2 UNION ALL
SELECT 'BELIEF_GODDESS_OF_PURITY','FEATURE_FOUNTAIN_YOUTH','YIELD_SCIENCE',2 UNION ALL
SELECT 'BELIEF_GODDESS_OF_PURITY','FEATURE_LAKE_VICTORIA','YIELD_CULTURE',4 UNION ALL
SELECT 'BELIEF_GODDESS_OF_PURITY','FEATURE_LAKE_VICTORIA','YIELD_FAITH',4 UNION ALL
SELECT 'BELIEF_GODDESS_OF_PURITY','FEATURE_LAKE_VICTORIA','YIELD_PRODUCTION',2 UNION ALL
SELECT 'BELIEF_GODDESS_OF_PURITY','FEATURE_LAKE_VICTORIA','YIELD_SCIENCE',2;

Delete FROM Belief_ResourceYieldChanges WHERE BeliefType = 'BELIEF_EARTH_MOTHER';
INSERT INTO Belief_ResourceYieldChanges (BeliefType,ResourceType,YieldType,Yield)
SELECT 'BELIEF_EARTH_MOTHER','RESOURCE_SPICES','YIELD_FOOD',1 UNION ALL
SELECT 'BELIEF_EARTH_MOTHER','RESOURCE_BANANA','YIELD_FOOD',1 UNION ALL
SELECT 'BELIEF_EARTH_MOTHER','RESOURCE_COTTON','YIELD_FOOD',1 UNION ALL
SELECT 'BELIEF_EARTH_MOTHER','RESOURCE_CITRUS','YIELD_FOOD',1 UNION ALL
SELECT 'BELIEF_EARTH_MOTHER','RESOURCE_SPICES','YIELD_FAITH',1 UNION ALL
SELECT 'BELIEF_EARTH_MOTHER','RESOURCE_BANANA','YIELD_FAITH',1 UNION ALL
SELECT 'BELIEF_EARTH_MOTHER','RESOURCE_COTTON','YIELD_FAITH',1 UNION ALL
SELECT 'BELIEF_EARTH_MOTHER','RESOURCE_CITRUS','YIELD_FAITH',1 ;

UPDATE Beliefs SET CityGrowthModifier = '0' WHERE Type = 'BELIEF_FERTILITY_RITES';
INSERT INTO Belief_BuildingClassYieldChanges(BeliefType,BuildingClassType,YieldType,YieldChange)
SELECT 'BELIEF_FERTILITY_RITES','BUILDINGCLASS_GRANARY','YIELD_FAITH',2;
INSERT INTO Belief_ResourceYieldChanges (BeliefType,ResourceType,YieldType,Yield)
SELECT 'BELIEF_FERTILITY_RITES','RESOURCE_WHEAT','YIELD_FAITH',1;

INSERT INTO Belief_TerrainYieldChanges (BeliefType,TerrainType,YieldType,Yield)
SELECT 'BELIEF_SNOW_BELIEF','TERRAIN_TUNDRA','YIELD_FAITH',2 UNION ALL
SELECT 'BELIEF_SNOW_BELIEF','TERRAIN_SNOW','YIELD_FOOD',1 UNION ALL
SELECT 'BELIEF_SNOW_BELIEF','TERRAIN_SNOW','YIELD_FAITH',2;

UPDATE Beliefs SET MinPopulation = '0' WHERE Type = 'BELIEF_GOD_CRAFTSMEN';
DELETE FROM Belief_CityYieldChanges WHERE BeliefType = 'BELIEF_GOD_CRAFTSMEN';
INSERT INTO Belief_ResourceYieldChanges (BeliefType,ResourceType,YieldType,Yield)
SELECT 'BELIEF_GOD_CRAFTSMEN','RESOURCE_JADE','YIELD_PRODUCTION',1 UNION ALL
SELECT 'BELIEF_GOD_CRAFTSMEN','RESOURCE_AMBER','YIELD_PRODUCTION',1 UNION ALL
SELECT 'BELIEF_GOD_CRAFTSMEN','RESOURCE_CORAL','YIELD_PRODUCTION',1 UNION ALL
SELECT 'BELIEF_GOD_CRAFTSMEN','RESOURCE_LAPIS','YIELD_PRODUCTION',1 UNION ALL
SELECT 'BELIEF_GOD_CRAFTSMEN','RESOURCE_JADE','YIELD_FAITH',1 UNION ALL
SELECT 'BELIEF_GOD_CRAFTSMEN','RESOURCE_AMBER','YIELD_FAITH',1 UNION ALL
SELECT 'BELIEF_GOD_CRAFTSMEN','RESOURCE_CORAL','YIELD_FAITH',1 UNION ALL
SELECT 'BELIEF_GOD_CRAFTSMEN','RESOURCE_LAPIS','YIELD_FAITH',1;

Delete FROM Belief_ImprovementYieldChanges WHERE BeliefType = 'BELIEF_GOD_SEA';
INSERT INTO Belief_ImprovementYieldChanges (BeliefType,ImprovementType,YieldType,Yield)
SELECT 'BELIEF_GOD_SEA','IMPROVEMENT_FISHFARM_MOD','YIELD_CULTURE',1 UNION ALL
SELECT 'BELIEF_GOD_SEA','IMPROVEMENT_FISHERY_MOD','YIELD_CULTURE',1 UNION ALL
SELECT 'BELIEF_GOD_SEA','IMPROVEMENT_FISHING_BOATS','YIELD_FAITH',1 UNION ALL
SELECT 'BELIEF_GOD_SEA','IMPROVEMENT_FISHING_BOATS','YIELD_CULTURE',1;

INSERT INTO Belief_FeatureYieldChanges (BeliefType,FeatureType,YieldType,Yield)
SELECT 'BELIEF_MARSH_BELIEF','FEATURE_MARSH','YIELD_CULTURE',1 UNION ALL
SELECT 'BELIEF_MARSH_BELIEF','FEATURE_MARSH','YIELD_FAITH',3 ;

Delete FROM Belief_ResourceYieldChanges WHERE BeliefType = 'BELIEF_GOD_FESTIVALS';
INSERT INTO Belief_ResourceYieldChanges (BeliefType,ResourceType,YieldType,Yield)
SELECT 'BELIEF_GOD_FESTIVALS','RESOURCE_WINE','YIELD_FAITH',2 UNION ALL
SELECT 'BELIEF_GOD_FESTIVALS','RESOURCE_INCENSE','YIELD_FAITH',2 UNION ALL
SELECT 'BELIEF_GOD_FESTIVALS','RESOURCE_WINE','YIELD_CULTURE',2 UNION ALL
SELECT 'BELIEF_GOD_FESTIVALS','RESOURCE_INCENSE','YIELD_CULTURE',2 ;

INSERT INTO Belief_ImprovementYieldChanges (BeliefType,ImprovementType,YieldType,Yield)
SELECT 'BELIEF_ORAL_TRADITION','IMPROVEMENT_PLANTATION','YIELD_GOLD',1;
INSERT INTO Belief_ResourceYieldChanges (BeliefType,ResourceType,YieldType,Yield)
SELECT 'BELIEF_ORAL_TRADITION','RESOURCE_TEA','YIELD_CULTURE',1 UNION ALL
SELECT 'BELIEF_ORAL_TRADITION','RESOURCE_SILK','YIELD_CULTURE',1 ;

--BELIEF_FAITH_HEALERS

INSERT INTO Belief_FeatureYieldChanges (BeliefType,FeatureType,YieldType,Yield)
SELECT 'BELIEF_DESERT_FOLKLORE','FEATURE_OASIS','YIELD_CULTURE',1 UNION ALL
SELECT 'BELIEF_DESERT_FOLKLORE','FEATURE_OASIS','YIELD_FAITH',1 ;

Delete FROM Belief_BuildingClassYieldChanges WHERE BeliefType = 'BELIEF_GOD_KING';
INSERT INTO Belief_BuildingClassYieldChanges(BeliefType,BuildingClassType,YieldType,YieldChange)
SELECT 'BELIEF_GOD_KING','BUILDINGCLASS_PALACE','YIELD_FAITH',3 UNION ALL
SELECT 'BELIEF_GOD_KING','BUILDINGCLASS_CITY_HALL_LV1','YIELD_PRODUCTION',1 UNION ALL
SELECT 'BELIEF_GOD_KING','BUILDINGCLASS_CITY_HALL_LV1','YIELD_CULTURE',1 UNION ALL
SELECT 'BELIEF_GOD_KING','BUILDINGCLASS_CITY_HALL_LV1','YIELD_FOOD',1 ;

UPDATE Beliefs SET WonderProductionModifier = '0',ObsoleteEra= NULL WHERE Type = 'BELIEF_MONUMENT_GODS';
INSERT INTO Belief_BuildingClassYieldChanges (BeliefType,BuildingClassType,YieldType,YieldChange)
SELECT 'BELIEF_MONUMENT_GODS','BUILDINGCLASS_MONUMENT','YIELD_FAITH',2;

INSERT INTO Belief_FeatureYieldChanges (BeliefType,FeatureType,YieldType,Yield)
SELECT 'BELIEF_SACRED_PATH','FEATURE_JUNGLE','YIELD_FAITH',1;

INSERT INTO Belief_TerrainYieldChanges (BeliefType,TerrainType,YieldType,Yield)
SELECT 'BELIEF_SACRED_WATERS','TERRAIN_COAST','YIELD_FAITH',1;

DELETE FROM Belief_YieldChangeTradeRoute WHERE BeliefType = 'BELIEF_MESSENGER_GODS';
INSERT INTO Belief_YieldChangeTradeRoute (BeliefType,YieldType,Yield)
SELECT 'BELIEF_MESSENGER_GODS','YIELD_FAITH',2 UNION ALL
SELECT 'BELIEF_MESSENGER_GODS','YIELD_SCIENCE' ,2;

INSERT INTO Belief_ResourceYieldChanges (BeliefType,ResourceType,YieldType,Yield)
SELECT 'BELIEF_TEARS_OF_GODS','RESOURCE_PEARLS','YIELD_CULTURE',2 UNION ALL
SELECT 'BELIEF_TEARS_OF_GODS','RESOURCE_GEMS','YIELD_CULTURE',2 ;

INSERT INTO Belief_ResourceYieldChanges (BeliefType,ResourceType,YieldType,Yield)
SELECT 'BELIEF_STONE_CIRCLES','RESOURCE_MARBLE','YIELD_PRODUCTION',1;
INSERT INTO Belief_BuildingClassYieldChanges(BeliefType,BuildingClassType,YieldType,YieldChange)
SELECT 'BELIEF_STONE_CIRCLES','BUILDINGCLASS_STONE_WORKS','YIELD_FAITH',2;

UPDATE Beliefs SET CityRangeStrikeModifier = '0' WHERE Type='BELIEF_GODDESS_STRATEGY';
INSERT INTO Belief_BuildingClassYieldChanges(BeliefType,BuildingClassType,YieldType,YieldChange)
SELECT 'BELIEF_GODDESS_STRATEGY','BUILDINGCLASS_CASTLE','YIELD_CULTURE',4 UNION ALL
SELECT 'BELIEF_GODDESS_STRATEGY','BUILDINGCLASS_WALLS','YIELD_FAITH',2;

INSERT INTO Belief_ImprovementYieldChanges (BeliefType,ImprovementType,YieldType,Yield)
SELECT 'BELIEF_GODDESS_HUNT','IMPROVEMENT_CAMP','YIELD_FAITH',1 ;
INSERT INTO Belief_ResourceYieldChanges (BeliefType,ResourceType,YieldType,Yield)
SELECT 'BELIEF_GODDESS_HUNT','RESOURCE_DEER','YIELD_PRODUCTION',1 UNION ALL
SELECT 'BELIEF_GODDESS_HUNT','RESOURCE_BISON','YIELD_FOOD',1;

DELETE FROM Belief_TerrainYieldChanges WHERE BeliefType = 'BELIEF_DANCE_AURORA';
INSERT INTO Belief_CityYieldChanges (BeliefType,YieldType,Yield)
SELECT 'BELIEF_DANCE_AURORA','YIELD_FAITH',1 UNION ALL
SELECT 'BELIEF_DANCE_AURORA','YIELD_PRODUCTION',1;

DELETE FROM Belief_ResourceYieldChanges WHERE BeliefType = 'BELIEF_SUN_GOD';
INSERT INTO Belief_ResourceYieldChanges (BeliefType,ResourceType,YieldType,Yield)
SELECT 'BELIEF_SUN_GOD','RESOURCE_OLIVE','YIELD_SCIENCE',1 UNION ALL
SELECT 'BELIEF_SUN_GOD','RESOURCE_TOBACCO','YIELD_SCIENCE',1 UNION ALL
SELECT 'BELIEF_SUN_GOD','RESOURCE_PERFUME','YIELD_SCIENCE',1 UNION ALL
SELECT 'BELIEF_SUN_GOD','RESOURCE_SUGAR','YIELD_SCIENCE',1 UNION ALL
SELECT 'BELIEF_SUN_GOD','RESOURCE_OLIVE','YIELD_FAITH',1 UNION ALL
SELECT 'BELIEF_SUN_GOD','RESOURCE_TOBACCO','YIELD_FAITH',1 UNION ALL
SELECT 'BELIEF_SUN_GOD','RESOURCE_PERFUME','YIELD_FAITH',1 UNION ALL
SELECT 'BELIEF_SUN_GOD','RESOURCE_SUGAR','YIELD_FAITH',1;

DELETE FROM Belief_YieldChangeNaturalWonder WHERE BeliefType = 'BELIEF_ONE_WITH_NATURE';
INSERT INTO Belief_YieldChangeNaturalWonder (BeliefType,YieldType,Yield)
SELECT 'BELIEF_ONE_WITH_NATURE','YIELD_FAITH',8;

UPDATE Beliefs SET PlotCultureCostModifier = '-50' WHERE Type = 'BELIEF_RELIGIOUS_SETTLEMENTS';
INSERT INTO Belief_CityYieldChanges (BeliefType,YieldType,Yield)
SELECT 'BELIEF_RELIGIOUS_SETTLEMENTS','YIELD_CULTURE',2 ;

UPDATE Beliefs SET MaxDistance = '6' WHERE Type = 'BELIEF_GOD_WAR';
INSERT INTO Belief_BuildingClassYieldChanges(BeliefType,BuildingClassType,YieldType,YieldChange)
SELECT 'BELIEF_GOD_WAR','BUILDINGCLASS_BARRACKS','YIELD_FAITH',2 UNION ALL
SELECT 'BELIEF_GOD_WAR','BUILDINGCLASS_ARMORY','YIELD_FAITH',2;

Delete FROM Belief_ResourceYieldChanges WHERE BeliefType = 'BELIEF_FORMAL_LITURGY';
INSERT INTO Belief_ResourceYieldChanges (BeliefType,ResourceType,YieldType,Yield)
SELECT 'BELIEF_FORMAL_LITURGY','RESOURCE_IRON','YIELD_FAITH',1 UNION ALL
SELECT 'BELIEF_FORMAL_LITURGY','RESOURCE_COPPER','YIELD_FAITH',1 UNION ALL
SELECT 'BELIEF_FORMAL_LITURGY','RESOURCE_SALT','YIELD_FAITH',1 UNION ALL
SELECT 'BELIEF_FORMAL_LITURGY','RESOURCE_SILVER','YIELD_FAITH',1 UNION ALL
SELECT 'BELIEF_FORMAL_LITURGY','RESOURCE_GOLD','YIELD_FAITH',1 UNION ALL

SELECT 'BELIEF_FORMAL_LITURGY','RESOURCE_IRON','YIELD_CULTURE',1 UNION ALL
SELECT 'BELIEF_FORMAL_LITURGY','RESOURCE_COPPER','YIELD_CULTURE',1 UNION ALL
SELECT 'BELIEF_FORMAL_LITURGY','RESOURCE_SALT','YIELD_CULTURE',1 UNION ALL
SELECT 'BELIEF_FORMAL_LITURGY','RESOURCE_SILVER','YIELD_CULTURE',1 UNION ALL
SELECT 'BELIEF_FORMAL_LITURGY','RESOURCE_GOLD','YIELD_CULTURE',1 ;

UPDATE Beliefs SET WonderProductionModifier = '10',ObsoleteEra = 'ERA_INDUSTRIAL' WHERE Type = 'BELIEF_ANCESTOR_WORSHIP';
DELETE FROM Belief_BuildingClassYieldChanges WHERE BeliefType = 'BELIEF_ANCESTOR_WORSHIP';
INSERT INTO Belief_BuildingClassYieldChanges (BeliefType,BuildingClassType,YieldType,YieldChange)
SELECT 'BELIEF_ANCESTOR_WORSHIP','BUILDINGCLASS_SHRINE','YIELD_CULTURE',1 UNION ALL
SELECT 'BELIEF_ANCESTOR_WORSHIP','BUILDINGCLASS_SHRINE','YIELD_FAITH',1;

--***********************************************************************************************--
--Founder
--***********************************************************************************************--
DELETE FROM Belief_YieldChangePerForeignCity WHERE BeliefType = 'BELIEF_PILGRIMAGE';
INSERT INTO Belief_YieldChangePerForeignCity (BeliefType,YieldType,Yield)
SELECT 'BELIEF_PILGRIMAGE','YIELD_FAITH',4;

UPDATE Beliefs SET GoldPerFollowingCity = '6' WHERE Type = 'BELIEF_CHURCH_PROPERTY';

INSERT INTO Belief_YieldChangePerXForeignFollowers (BeliefType,YieldType,ForeignFollowers)
SELECT 'BELIEF_FAITH_WITHOUT_BORDERS','YIELD_FAITH',3;

UPDATE Beliefs SET HappinessPerXPeacefulForeignFollowers = '6' WHERE Type = 'BELIEF_PEACE_LOVING';

UPDATE Beliefs SET GoldPerFirstCityConversion = '180' WHERE Type = 'BELIEF_INITIATION_RITES';

UPDATE Beliefs SET GoldPerXFollowers = '2' WHERE Type = 'BELIEF_TITHE';

DELETE FROM Belief_YieldChangePerXForeignFollowers WHERE BeliefType = 'BELIEF_WORLD_CHURCH';
INSERT INTO Belief_YieldChangePerXForeignFollowers (BeliefType,YieldType,ForeignFollowers)
SELECT 'BELIEF_WORLD_CHURCH','YIELD_CULTURE',3;

--BELIEF_INTERFAITH_DIALOGUE

UPDATE Beliefs SET HappinessPerFollowingCity = '1' WHERE Type = 'BELIEF_CEREMONIAL_BURIAL';

UPDATE Beliefs SET CityStateMinimumInfluence = '35' WHERE Type = 'BELIEF_PAPAL_PRIMACY';

INSERT INTO Belief_YieldPerFollowingCity (BeliefType,YieldType,Yield)
SELECT 'BELIEF_RELIGIOUS_SCIENCE','YIELD_SCIENCE',2;
INSERT INTO Belief_ImprovementYieldChanges (BeliefType,ImprovementType,YieldType,Yield)
SELECT 'BELIEF_RELIGIOUS_SCIENCE','IMPROVEMENT_HOLY_SITE','YIELD_SCIENCE',2;

--BELIEF_RELIGIOUS_COLONIZATION

--***********************************************************************************************--
--Follower
--***********************************************************************************************--
DELETE FROM Belief_BuildingClassYieldChanges WHERE BeliefType='BELIEF_FEED_WORLD';
INSERT INTO Belief_BuildingClassYieldChanges (BeliefType,BuildingClassType,YieldType,YieldChange)
SELECT 'BELIEF_FEED_WORLD','BUILDINGCLASS_SHRINE','YIELD_FOOD',2 UNION ALL
SELECT 'BELIEF_FEED_WORLD','BUILDINGCLASS_TEMPLE','YIELD_FOOD',2;

--BELIEF_CATHEDRALS

--BELIEF_PAGODAS

DELETE FROM Belief_BuildingClassYieldChanges WHERE BeliefType = 'BELIEF_CHORAL_MUSIC';
INSERT INTO Belief_BuildingClassYieldChanges (BeliefType,BuildingClassType,YieldType,YieldChange)
SELECT 'BELIEF_CHORAL_MUSIC','BUILDINGCLASS_TEMPLE','YIELD_CULTURE',4;

INSERT INTO Belief_BuildingClassHappiness (BeliefType,BuildingClassType,Happiness)
SELECT 'BELIEF_FEED_WORLD','BUILDINGCLASS_WATERMILL',2 ;

UPDATE Beliefs SET CityGrowthModifier = '25' WHERE Type = 'BELIEF_SWORD_PLOWSHARES';

--BELIEF_EIRENE

UPDATE Beliefs SET MinFollowers = '0' WHERE Type = 'BELIEF_ASCETISM';

INSERT INTO Belief_BuildingClassHappiness (BeliefType,BuildingClassType,Happiness)
SELECT 'BELIEF_LITURGICAL_DRAMA','BUILDINGCLASS_AMPHITHEATER',1 ;

INSERT INTO Belief_BuildingClassHappiness (BeliefType,BuildingClassType,Happiness)
SELECT 'BELIEF_MAZU','BUILDINGCLASS_HARBOR',2 ;

INSERT INTO Belief_BuildingClassYieldChanges (BeliefType,BuildingClassType,YieldType,YieldChange)
SELECT 'BELIEF_CHARITES','BUILDINGCLASS_AMPHITHEATER','YIELD_CULTURE',2 UNION ALL
SELECT 'BELIEF_CHARITES','BUILDINGCLASS_ART_GALLERY','YIELD_CULTURE',2 UNION ALL
SELECT 'BELIEF_CHARITES','BUILDINGCLASS_OPERA_HOUSE','YIELD_CULTURE',2 ;

DELETE FROM Belief_BuildingClassHappiness WHERE BeliefType = 'BELIEF_PEACE_GARDENS';
INSERT INTO Belief_BuildingClassHappiness (BeliefType,BuildingClassType,Happiness)
SELECT 'BELIEF_PEACE_GARDENS','BUILDINGCLASS_GARDEN',4 ;

--BELIEF_MOSQUES

INSERT INTO Belief_YieldChangeWorldWonder (BeliefType,YieldType,Yield)
SELECT 'BELIEF_DIVINE_INSPIRATION','YIELD_CULTURE',2;

DELETE FROM Belief_EraFaithUnitPurchase WHERE BeliefType = 'BELIEF_HOLY_WARRIORS';
INSERT INTO Belief_EraFaithUnitPurchase (BeliefType,EraType)
SELECT 'BELIEF_HOLY_WARRIORS','ERA_CLASSICAL' UNION ALL
SELECT 'BELIEF_HOLY_WARRIORS','ERA_MEDIEVAL';

DELETE FROM Belief_YieldChangeAnySpecialist WHERE BeliefType = 'BELIEF_GURUSHIP';
INSERT INTO Belief_YieldChangeAnySpecialist (BeliefType,YieldType,Yield)
SELECT 'BELIEF_GURUSHIP','YIELD_FAITH',2 UNION ALL
SELECT 'BELIEF_GURUSHIP','YIELD_CULTURE',1 UNION ALL
SELECT 'BELIEF_GURUSHIP','YIELD_PRODUCTION',1 UNION ALL
SELECT 'BELIEF_GURUSHIP','YIELD_SCIENCE',1;

--BELIEF_MONASTERIES

INSERT INTO Belief_BuildingClassFaithPurchase (BeliefType,BuildingClassType)
SELECT 'BELIEF_INQUISITION','BUILDINGCLASS_INQUISITION';

DELETE FROM Belief_MaxYieldModifierPerFollower WHERE BeliefType = 'BELIEF_RELIGIOUS_COMMUNITY';
INSERT INTO Belief_MaxYieldModifierPerFollower (BeliefType,YieldType,Max)
SELECT 'BELIEF_RELIGIOUS_COMMUNITY','YIELD_PRODUCTION',20;

DELETE FROM Belief_BuildingClassTourism WHERE BeliefType = 'BELIEF_RELIGIOUS_ART';
DELETE FROM Belief_BuildingClassYieldChanges WHERE BeliefType = 'BELIEF_RELIGIOUS_ART';
INSERT INTO Belief_BuildingClassTourism (BeliefType,BuildingClassType,Tourism)
SELECT 'BELIEF_RELIGIOUS_ART','BUILDINGCLASS_HAGIA_SOPHIA',2 UNION ALL
SELECT 'BELIEF_RELIGIOUS_ART','BUILDINGCLASS_MOSQUE_OF_DJENNE',2 UNION ALL
SELECT 'BELIEF_RELIGIOUS_ART','BUILDINGCLASS_ANGKOR_WAT',2 UNION ALL
SELECT 'BELIEF_RELIGIOUS_ART','BUILDINGCLASS_BOROBUDUR',2 UNION ALL
SELECT 'BELIEF_RELIGIOUS_ART','BUILDINGCLASS_SISTINE_CHAPEL',2 UNION ALL
SELECT 'BELIEF_RELIGIOUS_ART','BUILDINGCLASS_NOTRE_DAME',2 ;

--BELIEF_RELIGIOUS_CENTER

--***********************************************************************************************--
--Enhancer
--***********************************************************************************************--
--BELIEF_MISSIONARY_ZEAL
--BELIEF_MESSIAH
--BELIEF_RELIGION_PRESSURE

INSERT INTO Belief_BuildingClassYieldChanges(BeliefType,BuildingClassType,YieldType,YieldChange)
SELECT 'BELIEF_SACRED_CALENDAR','BUILDINGCLASS_CATHEDRAL','YIELD_GOLDEN_AGE_POINTS',3 UNION ALL
SELECT 'BELIEF_SACRED_CALENDAR','BUILDINGCLASS_MOSQUE','YIELD_GOLDEN_AGE_POINTS',3 UNION ALL
SELECT 'BELIEF_SACRED_CALENDAR','BUILDINGCLASS_PAGODA','YIELD_GOLDEN_AGE_POINTS',3 UNION ALL
SELECT 'BELIEF_SACRED_CALENDAR','BUILDINGCLASS_MONASTERY','YIELD_GOLDEN_AGE_POINTS',3 UNION ALL
SELECT 'BELIEF_SACRED_CALENDAR','BUILDINGCLASS_INQUISITION','YIELD_GOLDEN_AGE_POINTS',3 ;

--BELIEF_HOLY_ORDER
--BELIEF_DEFENDER_FAITH
--BELIEF_ITINERANT_PREACHERS
--BELIEF_JUST_WAR

UPDATE Beliefs SET GreatPersonExpendedFaith='0' WHERE Type = 'BELIEF_RELIQUARY';
INSERT INTO Belief_ImprovementYieldChanges (BeliefType,ImprovementType,YieldType,Yield)
SELECT 'BELIEF_RELIQUARY','IMPROVEMENT_LANDMARK','YIELD_FAITH',5 UNION ALL
SELECT 'BELIEF_RELIQUARY','IMPROVEMENT_HOLY_SITE','YIELD_FAITH',5 UNION ALL
SELECT 'BELIEF_RELIQUARY','IMPROVEMENT_MANUFACTORY','YIELD_FAITH',5 UNION ALL
SELECT 'BELIEF_RELIQUARY','IMPROVEMENT_CUSTOMS_HOUSE','YIELD_FAITH',5 UNION ALL
SELECT 'BELIEF_RELIQUARY','IMPROVEMENT_ACADEMY','YIELD_FAITH',5;

--BELIEF_RELIGIOUS_UNITY
--BELIEF_RELIGIOUS_TEXTS

--***********************************************************************************************--
--Reformation
--***********************************************************************************************--
UPDATE Beliefs SET CityStateInfluenceModifier='50',CityStateMinimumInfluence='30' WHERE Type = 'BELIEF_CHARITABLE_MISSIONS';

--BELIEF_UNDERGROUND_SECT
--BELIEF_EVANGELISM
--BELIEF_UNITY_OF_PROPHETS

UPDATE Beliefs SET WonderProductionModifier='25',ObsoleteEra='ERA_FUTURE' WHERE Type = 'BELIEF_RELIGIOUS_FERVOR';
INSERT INTO Belief_EraFaithUnitPurchase (BeliefType,EraType)
SELECT 'BELIEF_RELIGIOUS_FERVOR','ERA_RENAISSANCE';
INSERT INTO Belief_BuildingClassYieldChanges (BeliefType,BuildingClassType,YieldType,YieldChange)
SELECT 'BELIEF_RELIGIOUS_FERVOR','BUILDINGCLASS_AMPHITHEATER','YIELD_FAITH',2 UNION ALL
SELECT 'BELIEF_RELIGIOUS_FERVOR','BUILDINGCLASS_ART_GALLERY','YIELD_FAITH',2 UNION ALL
SELECT 'BELIEF_RELIGIOUS_FERVOR','BUILDINGCLASS_OPERA_HOUSE','YIELD_FAITH',2 ;

--BELIEF_TO_GLORY_OF_GOD

INSERT INTO Belief_ImprovementYieldChanges (BeliefType,ImprovementType,YieldType,Yield)
SELECT 'BELIEF_SACRED_SITES','IMPROVEMENT_HOLY_SITE','YIELD_CULTURE',5 UNION ALL
SELECT 'BELIEF_SACRED_SITES','IMPROVEMENT_MANUFACTORY','YIELD_CULTURE',5 UNION ALL
SELECT 'BELIEF_SACRED_SITES','IMPROVEMENT_CUSTOMS_HOUSE','YIELD_CULTURE',5 UNION ALL
SELECT 'BELIEF_SACRED_SITES','IMPROVEMENT_ACADEMY','YIELD_CULTURE',5;

INSERT INTO Belief_MaxYieldModifierPerFollower (BeliefType,YieldType,Max)
SELECT 'BELIEF_SCIENCE_RELIGION','YIELD_SCIENCE',30;

INSERT INTO Belief_BuildingClassYieldChanges (BeliefType,BuildingClassType,YieldType,YieldChange)
SELECT 'BELIEF_JESUIT_EDUCATION','BUILDINGCLASS_UNIVERSITY','YIELD_FAITH',2 UNION ALL
SELECT 'BELIEF_JESUIT_EDUCATION','BUILDINGCLASS_PUBLIC_SCHOOL','YIELD_FAITH',2 UNION ALL
SELECT 'BELIEF_JESUIT_EDUCATION','BUILDINGCLASS_LABORATORY','YIELD_FAITH',2 ;

--BELIEF_HEATHEN_CONVERSION

--DROP TRIGGER SPNRligionDeleteEffect;
/*CREATE TRIGGER SPNRligionDeleteEffect 
BEFORE DELETE ON Beliefs
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
END;*/