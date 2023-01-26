--BUILDING_SHOSHONE_HUNTING
INSERT INTO Building_ResourceYieldChanges(BuildingType,ResourceType,YieldType,Yield)
SELECT 'BUILDING_SHOSHONE_HUNTING',ResourceType,'YIELD_PRODUCTION',2
FROM Improvement_ResourceTypes WHERE ImprovementType = 'IMPROVEMENT_PASTURE' OR ImprovementType = 'IMPROVEMENT_CAMP' UNION ALL

SELECT 'BUILDING_SHOSHONE_HUNTING',ResourceType,'YIELD_GOLD',1
FROM Improvement_ResourceTypes WHERE ImprovementType = 'IMPROVEMENT_PASTURE' OR ImprovementType = 'IMPROVEMENT_CAMP' UNION ALL

SELECT 'BUILDING_SHOSHONE_HUNTING',ResourceType,'YIELD_FOOD',1
FROM Improvement_ResourceTypes WHERE ImprovementType = 'IMPROVEMENT_PASTURE' OR ImprovementType = 'IMPROVEMENT_CAMP' ;

--BUILDING_PORTUGAL_PORT
INSERT INTO Building_ResourceYieldChanges(BuildingType,ResourceType,YieldType,Yield)
SELECT 'BUILDING_PORTUGAL_PORT',t1.Type,'YIELD_PRODUCTION',1
FROM Resources t1 LEFT JOIN Resource_TerrainBooleans t2
ON t1.Type = t2.ResourceType
WHERE t1.ResourceClassType = 'RESOURCECLASS_LUXURY' AND t2.TerrainType = 'TERRAIN_COAST' UNION ALL
SELECT 'BUILDING_PORTUGAL_PORT',t1.Type,'YIELD_GOLD',1
FROM Resources t1 LEFT JOIN Resource_TerrainBooleans t2
ON t1.Type = t2.ResourceType
WHERE t1.ResourceClassType = 'RESOURCECLASS_LUXURY' AND t2.TerrainType = 'TERRAIN_COAST' ;
