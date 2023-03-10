--move cultural specialist output to table SpecialistYields
INSERT INTO SpecialistYields(SpecialistType,YieldType,Yield)
SELECT Type , 'YIELD_CULTURE',4 
FROM Specialists WHERE CulturePerTurn > 0;
UPDATE Specialists Set CulturePerTurn = 0;

--GreatPeopleImprovement provide surrounding output
INSERT INTO Improvement_AdjacentImprovementYieldChanges(ImprovementType,OtherImprovementType,YieldType,Yield)
SELECT	'IMPROVEMENT_ACADEMY',Type,  'YIELD_SCIENCE', 1  
FROM Improvements ;

INSERT INTO Improvement_AdjacentImprovementYieldChanges(ImprovementType,OtherImprovementType,YieldType,Yield)
SELECT	'IMPROVEMENT_CUSTOMS_HOUSE',Type,  'YIELD_GOLD', 3 
FROM Improvements ;

INSERT INTO Improvement_AdjacentImprovementYieldChanges(ImprovementType,OtherImprovementType,YieldType,Yield)
SELECT	'IMPROVEMENT_MANUFACTORY',Type,  'YIELD_PRODUCTION', 1  
FROM Improvements ;

INSERT INTO Improvement_AdjacentImprovementYieldChanges(ImprovementType,OtherImprovementType,YieldType,Yield)
SELECT	'IMPROVEMENT_HOLY_SITE',Type,  'YIELD_FAITH', 1  
FROM Improvements ;

--BUILDING_SPECIALISTS
CREATE TABLE BuildingSpecialistTemp (BuildingType text, SpecialistType text,YieldType text);
INSERT INTO BuildingSpecialistTemp (BuildingType, SpecialistType,YieldType)
SELECT 'BUILDING_SPECIALISTS_ARTISTIC_LV1','SPECIALIST_WRITER','YIELD_CULTURE' UNION ALL
SELECT 'BUILDING_SPECIALISTS_ARTISTIC_LV1','SPECIALIST_ARTIST','YIELD_CULTURE' UNION ALL
SELECT 'BUILDING_SPECIALISTS_ARTISTIC_LV1','SPECIALIST_MUSICIAN','YIELD_CULTURE' UNION ALL
SELECT 'BUILDING_SPECIALISTS_ARTISTIC_LV2','SPECIALIST_WRITER','YIELD_CULTURE' UNION ALL
SELECT 'BUILDING_SPECIALISTS_ARTISTIC_LV2','SPECIALIST_ARTIST','YIELD_CULTURE' UNION ALL
SELECT 'BUILDING_SPECIALISTS_ARTISTIC_LV2','SPECIALIST_MUSICIAN','YIELD_CULTURE' UNION ALL
SELECT 'BUILDING_SPECIALISTS_ARTISTIC_LV3','SPECIALIST_WRITER','YIELD_CULTURE' UNION ALL
SELECT 'BUILDING_SPECIALISTS_ARTISTIC_LV3','SPECIALIST_ARTIST','YIELD_CULTURE' UNION ALL
SELECT 'BUILDING_SPECIALISTS_ARTISTIC_LV3','SPECIALIST_MUSICIAN','YIELD_CULTURE' UNION ALL

SELECT 'BUILDING_SPECIALISTS_SCIENTIFIC_LV1','SPECIALIST_SCIENTIST','YIELD_SCIENCE' UNION ALL
SELECT 'BUILDING_SPECIALISTS_SCIENTIFIC_LV2','SPECIALIST_SCIENTIST','YIELD_SCIENCE' UNION ALL
SELECT 'BUILDING_SPECIALISTS_SCIENTIFIC_LV3','SPECIALIST_SCIENTIST','YIELD_SCIENCE' UNION ALL

SELECT 'BUILDING_SPECIALISTS_ENGINEERING_LV1','SPECIALIST_ENGINEER','YIELD_PRODUCTION' UNION ALL
SELECT 'BUILDING_SPECIALISTS_ENGINEERING_LV2','SPECIALIST_ENGINEER','YIELD_PRODUCTION' UNION ALL
SELECT 'BUILDING_SPECIALISTS_ENGINEERING_LV3','SPECIALIST_ENGINEER','YIELD_PRODUCTION' UNION ALL

SELECT 'BUILDING_SPECIALISTS_MERCHANT_LV1','SPECIALIST_MERCHANT','YIELD_GOLD' UNION ALL
SELECT 'BUILDING_SPECIALISTS_MERCHANT_LV2','SPECIALIST_MERCHANT','YIELD_FOOD' UNION ALL
SELECT 'BUILDING_SPECIALISTS_MERCHANT_LV3','SPECIALIST_MERCHANT','YIELD_FOOD';

INSERT INTO Building_SpecialistYieldChanges(BuildingType,SpecialistType,YieldType,Yield)
SELECT BuildingType, SpecialistType, YieldType, 
(CASE WHEN YieldType = 'YIELD_FOOD'  THEN 1 ELSE 2 END)
FROM BuildingSpecialistTemp UNION ALL
SELECT BuildingType, SpecialistType, 'YIELD_GOLD', -2
FROM BuildingSpecialistTemp WHERE SpecialistType != 'SPECIALIST_MERCHANT';

DROP TABLE BuildingSpecialistTemp;