CREATE TRIGGER Minor_Building_Overrides_Trigger
AFTER UPDATE ON SPTriggerControler
WHEN NEW.TriggerType = 'Minor_Building_Overrides_Trigger' AND NEW.Enabled = 1
BEGIN
    --Clear all
    DELETE FROM Civilization_BuildingClassOverrides
    WHERE (CivilizationType = 'CIVILIZATION_BARBARIAN' OR CivilizationType = 'CIVILIZATION_MINOR');

    --Minor Special Palace
    INSERT INTO Civilization_BuildingClassOverrides(CivilizationType,BuildingClassType,BuildingType)
    SELECT 'CIVILIZATION_MINOR', 'BUILDINGCLASS_PALACE', 'BUILDING_CITYSTATE_RESOURCE';

    --Minor cannot build wonder
    INSERT INTO Civilization_BuildingClassOverrides(CivilizationType,BuildingClassType,BuildingType)
    SELECT 'CIVILIZATION_BARBARIAN',Type,NULL FROM BuildingClasses
    WHERE (MaxPlayerInstances = 1 OR MaxGlobalInstances = 1) AND Type != 'BUILDINGCLASS_PALACE' UNION ALL
    SELECT 'CIVILIZATION_MINOR',Type,NULL FROM BuildingClasses
    WHERE MaxPlayerInstances = 1 OR MaxGlobalInstances = 1 AND Type != 'BUILDINGCLASS_PALACE';

    --Minor should not build culture building except Monument
    INSERT INTO Civilization_BuildingClassOverrides(CivilizationType,BuildingClassType,BuildingType)
    SELECT 'CIVILIZATION_BARBARIAN',t1.Type,NULL
    FROM BuildingClasses t1 LEFT JOIN Building_YieldChanges t2 LEFT JOIN Buildings t3 
    ON t1.DefaultBuilding = t2.BuildingType AND t1.DefaultBuilding = t3.Type
    WHERE t1.MaxPlayerInstances <> 1 AND t1.MaxGlobalInstances <> 1 AND t2.YieldType = 'YIELD_CULTURE' AND t3.Cost > 0 AND NOT t1.Type = 'BUILDINGCLASS_MONUMENT' UNION ALL
    SELECT 'CIVILIZATION_MINOR',t1.Type,NULL
    FROM BuildingClasses t1 LEFT JOIN Building_YieldChanges t2 LEFT JOIN Buildings t3 
    ON t1.DefaultBuilding = t2.BuildingType AND t1.DefaultBuilding = t3.Type
    WHERE t1.MaxPlayerInstances <> 1 AND t1.MaxGlobalInstances <> 1 AND t2.YieldType = 'YIELD_CULTURE' AND t3.Cost > 0 AND NOT t1.Type = 'BUILDINGCLASS_MONUMENT';

    --Minor should not build resource building(Whether consumed or provided)
    INSERT INTO Civilization_BuildingClassOverrides(CivilizationType,BuildingClassType,BuildingType)
    SELECT 'CIVILIZATION_BARBARIAN',t1.Type,NULL
    FROM BuildingClasses t1 LEFT JOIN Buildings t2 ON t1.DefaultBuilding = t2.Type 
    WHERE t1.MaxPlayerInstances <> 1 AND t1.MaxGlobalInstances <> 1 AND t2.Cost > 0
    AND(
        EXISTS (SELECT BuildingType FROM Building_ResourceQuantityRequirements WHERE BuildingType = t1.DefaultBuilding) OR
        EXISTS (SELECT BuildingType FROM Building_ResourceQuantity WHERE BuildingType = t1.DefaultBuilding)
    ) UNION ALL
    SELECT 'CIVILIZATION_MINOR',t1.Type,NULL
    FROM BuildingClasses t1 LEFT JOIN Buildings t2 ON t1.DefaultBuilding = t2.Type 
    WHERE t1.MaxPlayerInstances <> 1 AND t1.MaxGlobalInstances <> 1 AND t2.Cost > 0
    AND(
        EXISTS (SELECT BuildingType FROM Building_ResourceQuantityRequirements WHERE BuildingType = t1.DefaultBuilding) OR
        EXISTS (SELECT BuildingType FROM Building_ResourceQuantity WHERE BuildingType = t1.DefaultBuilding)
    );

    --Delete repeated row
    DELETE FROM Civilization_BuildingClassOverrides
    WHERE rowid NOT IN (SELECT min(rowid) FROM Civilization_BuildingClassOverrides GROUP BY CivilizationType,BuildingClassType);
END;

UPDATE SPTriggerControler SET Enabled = 1 WHERE TriggerType = 'Minor_Building_Overrides_Trigger';