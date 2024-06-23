CREATE TRIGGER IF NOT EXISTS Minor_Building_Overrides_Trigger
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

--Militia Unit
UPDATE Units SET BarbarianCanTrait = 1 WHERE Type = 'UNIT_BARBARIAN_WARRIOR';
UPDATE Units SET BarbarianCanTrait = 1 WHERE Type = 'UNIT_MILITIA_ANCIENT';
UPDATE Units SET BarbarianCanTrait = 1 WHERE Type = 'UNIT_AMERICAN_MINUTEMAN';
UPDATE Units SET BarbarianCanTrait = 1 WHERE Type = 'UNIT_CONSCRIPTMAN';
UPDATE Units SET BarbarianCanTrait = 1 WHERE Type = 'UNIT_MILITIA_MODERN';
UPDATE Units SET BarbarianTraitTechObsolete = 1 WHERE Type = 'UNIT_MILITIA_MODERN';

--Melee Infantry Unit
UPDATE Units SET BarbarianCanTrait = 1 WHERE Type = 'UNIT_SWORDSMAN';
UPDATE Units SET BarbarianCanTrait = 1 WHERE Type = 'UNIT_LONGSWORDSMAN';
UPDATE Units SET BarbarianCanTrait = 1 WHERE Type = 'UNIT_MUSKETMAN';
UPDATE Units SET BarbarianCanTrait = 1 WHERE Type = 'UNIT_RIFLEMAN';
UPDATE Units SET BarbarianCanTrait = 1 WHERE Type = 'UNIT_GREAT_WAR_INFANTRY';
UPDATE Units SET BarbarianCanTrait = 1 WHERE Type = 'UNIT_INFANTRY';
UPDATE Units SET BarbarianTraitTechObsolete = 1 WHERE Type = 'UNIT_INFANTRY';

--Anti-Mounted Unit
UPDATE Units SET BarbarianCanTrait = 1 WHERE Type = 'UNIT_SPEARMAN';
UPDATE Units SET BarbarianCanTrait = 1 WHERE Type = 'UNIT_PIKEMAN';
UPDATE Units SET BarbarianCanTrait = 1 WHERE Type = 'UNIT_SPANISH_TERCIO';
UPDATE Units SET BarbarianCanTrait = 1 WHERE Type = 'UNIT_ANTI_TANK_GUN';
UPDATE Units SET BarbarianTraitTechObsolete = 1 WHERE Type = 'UNIT_ANTI_TANK_GUN';

--Land Ranged Units
UPDATE Units SET BarbarianCanTrait = 1 WHERE Type = 'UNIT_BARBARIAN_ARCHER';
UPDATE Units SET BarbarianCanTrait = 1 WHERE Type = 'UNIT_COMPOSITE_BOWMAN';
UPDATE Units SET BarbarianCanTrait = 1 WHERE Type = 'UNIT_CROSSBOWMAN';
UPDATE Units SET BarbarianCanTrait = 1 WHERE Type = 'UNIT_VOLLEY_GUN';
UPDATE Units SET BarbarianCanTrait = 1 WHERE Type = 'UNIT_GATLINGGUN';
UPDATE Units SET BarbarianCanTrait = 1 WHERE Type = 'UNIT_MACHINE_GUN';
UPDATE Units SET BarbarianCanTrait = 1 WHERE Type = 'UNIT_ANTI_AIRCRAFT_GUN';
UPDATE Units SET BarbarianTraitTechObsolete = 1 WHERE Type = 'UNIT_ANTI_AIRCRAFT_GUN';

--Land Hit-and-run Units
UPDATE Units SET BarbarianCanTrait = 1 WHERE Type = 'UNIT_BARBARIAN_AXMAN';
UPDATE Units SET BarbarianCanTrait = 1 WHERE Type = 'UNIT_MEDIEVAL_CHARIOT';
UPDATE Units SET BarbarianCanTrait = 1 WHERE Type = 'UNIT_BOMBARD';
UPDATE Units SET BarbarianCanTrait = 1 WHERE Type = 'UNIT_CAVALRY';
UPDATE Units SET BarbarianTraitTechObsolete = 1 WHERE Type = 'UNIT_CAVALRY';

--Heavy Cavalry Units
UPDATE Units SET BarbarianCanTrait = 1 WHERE Type = 'UNIT_HORSEMAN';
UPDATE Units SET BarbarianCanTrait = 1 WHERE Type = 'UNIT_KNIGHT';
UPDATE Units SET BarbarianCanTrait = 1 WHERE Type = 'UNIT_LANCER';
UPDATE Units SET BarbarianTraitTechObsolete = 1 WHERE Type = 'UNIT_LANCER';

--Naval Militia Unit
UPDATE Units SET BarbarianCanTrait = 1 WHERE Type = 'UNIT_BARBARIAN_GALLEY';
UPDATE Units SET BarbarianCanTrait = 1 WHERE Type = 'UNIT_MONITOR_SHIP';
UPDATE Units SET BarbarianCanTrait = 1 WHERE Type = 'UNIT_CORVETTE';
UPDATE Units SET BarbarianCanTrait = 1 WHERE Type = 'UNIT_LITTORAL_COMBAT_SHIP';
UPDATE Units SET BarbarianTraitTechObsolete = 1 WHERE Type = 'UNIT_LITTORAL_COMBAT_SHIP';


CREATE TRIGGER IF NOT EXISTS Minor_Units_Overrides_Trigger
AFTER UPDATE ON SPTriggerControler
WHEN NEW.TriggerType = 'Minor_Units_Overrides_Trigger' AND NEW.Enabled = 1
BEGIN
    --Clear all
    DELETE FROM Civilization_UnitClassOverrides WHERE CivilizationType = 'CIVILIZATION_BARBARIAN';

    --Barbarian Special Unit
    INSERT INTO Civilization_UnitClassOverrides(CivilizationType,UnitClassType,UnitType)
    SELECT 'CIVILIZATION_BARBARIAN', 'UNITCLASS_WARRIOR', 'UNIT_BARBARIAN_WARRIOR' UNION ALL
    SELECT 'CIVILIZATION_BARBARIAN', 'UNITCLASS_ARCHER', 'UNIT_BARBARIAN_ARCHER' UNION ALL
    SELECT 'CIVILIZATION_BARBARIAN', 'UNITCLASS_CHARIOT_ARCHER', 'UNIT_BARBARIAN_AXMAN' UNION ALL
    SELECT 'CIVILIZATION_BARBARIAN', 'UNITCLASS_NAVAL_MILITIA', 'UNIT_BARBARIAN_GALLEY';

    INSERT INTO Civilization_UnitClassOverrides(CivilizationType,UnitClassType,UnitType)
    SELECT 'CIVILIZATION_BARBARIAN',t1.Type,NULL
    FROM UnitClasses t1 LEFT JOIN Units t2 ON t1.DefaultUnit = t2.Type 
    WHERE NOT t2.BarbarianCanTrait
    AND t1.Type != 'UNITCLASS_WARRIOR' AND t1.Type != 'UNITCLASS_ARCHER'
    AND t1.Type != 'UNITCLASS_CHARIOT_ARCHER' AND t1.Type != 'UNITCLASS_NAVAL_MILITIA' ;

    --Delete repeated row
    DELETE FROM Civilization_UnitClassOverrides
    WHERE rowid NOT IN (SELECT min(rowid) FROM Civilization_UnitClassOverrides GROUP BY CivilizationType,UnitClassType);
END;

UPDATE SPTriggerControler SET Enabled = 1 WHERE TriggerType = 'Minor_Units_Overrides_Trigger';