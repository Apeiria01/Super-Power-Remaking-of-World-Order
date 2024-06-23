
--Traditional Policies: CapitalYieldChanges +4
INSERT INTO Policy_CapitalYieldPerPopChanges (PolicyType,YieldType,Yield)
SELECT 'POLICY_MONARCHY','YIELD_GOLD',100 UNION ALL
SELECT 'POLICY_MONARCHY','YIELD_FOOD',34 UNION ALL
SELECT 'POLICY_MONARCHY','YIELD_CULTURE',34 UNION ALL
SELECT 'POLICY_MONARCHY','YIELD_SCIENCE',34 UNION ALL
SELECT 'POLICY_MONARCHY','YIELD_PRODUCTION',34 ;

--POLICY_LANDED_ELITE
INSERT INTO Policy_ImprovementYieldChanges (PolicyType,ImprovementType,YieldType,Yield)
SELECT 'POLICY_LANDED_ELITE','IMPROVEMENT_FARM','YIELD_FOOD',1 UNION ALL
SELECT 'POLICY_LANDED_ELITE','IMPROVEMENT_FISHFARM_MOD','YIELD_FOOD',1 UNION ALL
SELECT 'POLICY_LANDED_ELITE','IMPROVEMENT_TERRACE_FARM','YIELD_FOOD',1 UNION ALL
SELECT 'POLICY_LANDED_ELITE','IMPROVEMENT_POLDER','YIELD_FOOD',1 UNION ALL
SELECT 'POLICY_LANDED_ELITE','IMPROVEMENT_KASBAH','YIELD_FOOD',1 UNION ALL
SELECT 'POLICY_LANDED_ELITE','IMPROVEMENT_SHOSHONE_TIPI','YIELD_FOOD',1 ;

--POLICY_COASTAL_ADMINISTRATION
INSERT INTO Policy_BuildingClassYieldModifiers (PolicyType,BuildingClassType,YieldType,YieldMod)
SELECT 'POLICY_COASTAL_ADMINISTRATION','BUILDINGCLASS_SEAPORT','YIELD_SCIENCE',5 UNION ALL
SELECT 'POLICY_COASTAL_ADMINISTRATION','BUILDINGCLASS_SHIPYARD','YIELD_SCIENCE',5 UNION ALL
SELECT 'POLICY_COASTAL_ADMINISTRATION','BUILDINGCLASS_LIGHTHOUSE','YIELD_SCIENCE',3 UNION ALL
SELECT 'POLICY_COASTAL_ADMINISTRATION','BUILDINGCLASS_HARBOR','YIELD_SCIENCE',3 UNION ALL
SELECT 'POLICY_COASTAL_ADMINISTRATION','BUILDINGCLASS_WOOD_DOCK','YIELD_SCIENCE',3 UNION ALL

SELECT 'POLICY_COASTAL_ADMINISTRATION','BUILDINGCLASS_SEAPORT','YIELD_PRODUCTION',5 UNION ALL
SELECT 'POLICY_COASTAL_ADMINISTRATION','BUILDINGCLASS_SHIPYARD','YIELD_PRODUCTION',5 UNION ALL
SELECT 'POLICY_COASTAL_ADMINISTRATION','BUILDINGCLASS_LIGHTHOUSE','YIELD_PRODUCTION',3 UNION ALL
SELECT 'POLICY_COASTAL_ADMINISTRATION','BUILDINGCLASS_HARBOR','YIELD_PRODUCTION',3 UNION ALL
SELECT 'POLICY_COASTAL_ADMINISTRATION','BUILDINGCLASS_WOOD_DOCK','YIELD_PRODUCTION',3 ;

INSERT INTO Policy_BuildingClassYieldChanges (PolicyType,BuildingClassType,YieldType,YieldChange)
SELECT 'POLICY_COASTAL_ADMINISTRATION','BUILDINGCLASS_SEAPORT','YIELD_PRODUCTION',2 UNION ALL
SELECT 'POLICY_COASTAL_ADMINISTRATION','BUILDINGCLASS_SHIPYARD','YIELD_PRODUCTION',2 UNION ALL
SELECT 'POLICY_COASTAL_ADMINISTRATION','BUILDINGCLASS_LIGHTHOUSE','YIELD_PRODUCTION',2 UNION ALL
SELECT 'POLICY_COASTAL_ADMINISTRATION','BUILDINGCLASS_HARBOR','YIELD_PRODUCTION',2 UNION ALL
SELECT 'POLICY_COASTAL_ADMINISTRATION','BUILDINGCLASS_WOOD_DOCK','YIELD_PRODUCTION',2 ;

--POLICY_BILL_OF_RIGHTS
--DROP TRIGGER Policy_Bill_Of_Right_Trigger;
CREATE TRIGGER IF NOT EXISTS Policy_Bill_Of_Right_Trigger
AFTER UPDATE ON SPTriggerControler
WHEN NEW.TriggerType = 'Policy_Bill_Of_Right_Trigger' AND NEW.Enabled = 1
BEGIN
	DELETE FROM Policy_BuildingClassYieldChanges 
    WHERE PolicyType = 'POLICY_BILL_OF_RIGHTS' AND BuildingClassType NOT LIKE 'BUILDINGCLASS_CITY_HALL_LV%';

    INSERT INTO Policy_BuildingClassYieldChanges (PolicyType, BuildingClassType, YieldType, YieldChange)
    SELECT 'POLICY_BILL_OF_RIGHTS', t1.Type, t3.YieldType, t2.SpecialistCount
    FROM BuildingClasses t1 LEFT JOIN Buildings t2 LEFT JOIN SpecialistYields t3
    ON t1.DefaultBuilding = t2.Type AND t2.SpecialistType = t3.SpecialistType
    WHERE t2.SpecialistCount > 0 AND
    (t2.SpecialistType = 'SPECIALIST_ENGINEER' OR t2.SpecialistType='SPECIALIST_SCIENTIST' OR t2.SpecialistType='SPECIALIST_MERCHANT'
    or t2.SpecialistType='SPECIALIST_WRITER' OR t2.SpecialistType='SPECIALIST_MUSICIAN' OR t2.SpecialistType='SPECIALIST_ARTIST')
    AND t3.Yield > 0;
END;
UPDATE SPTriggerControler SET Enabled = 1 WHERE TriggerType = 'Policy_Bill_Of_Right_Trigger';

-- POLICY_MERCHANT_CONFEDERACY
insert into Policy_MinorsTradeRouteYieldRate (PolicyType, YieldType, Rate) values
('POLICY_MERCHANT_CONFEDERACY', 'YIELD_SCIENCE', 10),
('POLICY_MERCHANT_CONFEDERACY', 'YIELD_CULTURE', 10);

-- POLICY_PROTECTIONISM
insert into Policy_InternalTradeRouteDestYieldRate (PolicyType, YieldType, Rate) values
('POLICY_PROTECTIONISM', 'YIELD_SCIENCE', 5),
('POLICY_PROTECTIONISM', 'YIELD_CULTURE', 5);

create table MillitaryBuildingClasses (
    Type text primary key references BuildingClasses (Type)
);
insert into MillitaryBuildingClasses values
('BUILDINGCLASS_BARRACKS'),
('BUILDINGCLASS_ARMORY'),
('BUILDINGCLASS_ARSENAL'),
('BUILDINGCLASS_MILITARY_BASE'),
('BUILDINGCLASS_WOOD_DOCK'),
('BUILDINGCLASS_SHIPYARD'),
('BUILDINGCLASS_JAPANESE_DOJO'),
('BUILDINGCLASS_MILITARY_ACADEMY');

create table StrategyResourceBuildingClasses (
    Type text primary key references BuildingClasses (Type)
);
insert into StrategyResourceBuildingClasses values
('BUILDINGCLASS_STABLE'),
('BUILDINGCLASS_COAL_COMPANY'),
('BUILDINGCLASS_COAL_TO_OIL'),
('BUILDINGCLASS_STEEL_MILL'),
('BUILDINGCLASS_IRON_PROVIDER'),
('BUILDINGCLASS_OIL_REFINERY'),
('BUILDINGCLASS_ALUMINUM_PROVIDER'),
('BUILDINGCLASS_COAL_TO_URANIUM'),
('BUILDINGCLASS_METAL_FACTORY');

delete from Policy_BuildingClassYieldChanges where PolicyType = 'POLICY_FORTIFIED_BORDERS';
insert into Policy_BuildingClassYieldChanges (PolicyType, BuildingClassType, YieldType, YieldChange)
select 'POLICY_FORTIFIED_BORDERS', t1.Type, 'YIELD_GOLD', t2.GoldMaintenance / 2
from MillitaryBuildingClasses as t1
left join Buildings as t2
on t1.Type = t2.BuildingClass
left join BuildingClasses t3
where t3.DefaultBuilding = t2.Type and t2.GoldMaintenance > 0
union all
select 'POLICY_FORTIFIED_BORDERS', t1.Type, 'YIELD_GOLD', t2.GoldMaintenance
from StrategyResourceBuildingClasses as t1
left join Buildings as t2
on t1.Type = t2.BuildingClass
left join BuildingClasses t3
where t3.DefaultBuilding = t2.Type and t2.GoldMaintenance > 0;

delete from Policy_BuildingClassHappiness where PolicyType = 'POLICY_FORTIFIED_BORDERS';
insert into Policy_BuildingClassHappiness (PolicyType, BuildingClassType, Happiness)
select 'POLICY_FORTIFIED_BORDERS', t1.Type, 1
from MillitaryBuildingClasses as t1
left join Buildings as t2
on t1.Type = t2.BuildingClass
left join BuildingClasses t3
where t3.DefaultBuilding = t2.Type
union all
select 'POLICY_FORTIFIED_BORDERS', t1.Type, 1
from StrategyResourceBuildingClasses as t1
left join Buildings as t2
on t1.Type = t2.BuildingClass
left join BuildingClasses t3
where t3.DefaultBuilding = t2.Type;

delete from Policy_BuildingClassProductionModifiers where PolicyType = 'POLICY_FORTIFIED_BORDERS';
insert into Policy_BuildingClassProductionModifiers (PolicyType, BuildingClassType, ProductionModifier)
select 'POLICY_FORTIFIED_BORDERS', t1.Type, 100
from MillitaryBuildingClasses as t1
left join Buildings as t2
on t1.Type = t2.BuildingClass
left join BuildingClasses t3
where t3.DefaultBuilding = t2.Type
union all
select 'POLICY_FORTIFIED_BORDERS', t1.Type, 100
from StrategyResourceBuildingClasses as t1
left join Buildings as t2
on t1.Type = t2.BuildingClass
left join BuildingClasses t3
where t3.DefaultBuilding = t2.Type;

insert into Policy_CityResources (PolicyType, ResourceType, Quantity) values
('POLICY_CITIZENSHIP', 'RESOURCE_MANPOWER', 2);
insert into Policy_CityResources (PolicyType, ResourceType, Quantity) values
('POLICY_REPUBLIC', 'RESOURCE_CONSUMER', 2);

insert into Policy_CityResources (PolicyType, ResourceType, Quantity, MustCoastal) values
('POLICY_MERCHANT_NAVY', 'RESOURCE_CONSUMER', 3, 1);

insert into Policy_CityResources (PolicyType, ResourceType, Quantity) values
('POLICY_TOTAL_WAR', 'RESOURCE_MANPOWER', 5);
insert into Policy_CityResources (PolicyType, ResourceType, Quantity, CityScaleType) values
('POLICY_TOTAL_WAR', 'RESOURCE_ELECTRICITY', 1, 'CITYSCALE_TOWN'),
('POLICY_TOTAL_WAR', 'RESOURCE_CONSUMER', 1, 'CITYSCALE_TOWN'),
('POLICY_TOTAL_WAR', 'RESOURCE_ELECTRICITY', 3, 'CITYSCALE_SMALL'),
('POLICY_TOTAL_WAR', 'RESOURCE_CONSUMER', 3, 'CITYSCALE_SMALL'),
('POLICY_TOTAL_WAR', 'RESOURCE_ELECTRICITY', 6, 'CITYSCALE_MEDIUM'),
('POLICY_TOTAL_WAR', 'RESOURCE_CONSUMER', 6, 'CITYSCALE_MEDIUM');

insert into Policy_CityResources (PolicyType, ResourceType, Quantity) values
('POLICY_DOUBLE_AGENTS', 'RESOURCE_CONSUMER', 6),
('POLICY_DOUBLE_AGENTS', 'RESOURCE_ELECTRICITY', 6);

insert into LuaFormula(Type, Formula) values
('FORMULA_EXCESS_HAPPINESS_POLICY_SCIENCE', 'local num, cityCount = ... if num <= 0 then return 0 else return math.min(5 * math.floor(num / 25), 50) end');

insert into Policy_HappinessYieldModifier values
('POLICY_RATIONALISM', 'YIELD_SCIENCE', 'FORMULA_EXCESS_HAPPINESS_POLICY_SCIENCE'),
('POLICY_TREATY_ORGANIZATION', 'YIELD_SCIENCE', 'FORMULA_EXCESS_HAPPINESS_POLICY_SCIENCE');

insert into LuaFormula(Type, Formula) values
('FORMULA_CAPTURE_CITY_RESISTANCE_CHANGE', 'local pop, resistence, oldOwnerLoss = ... if pop < 6 or oldOwnerLoss then return -resistence else return -math.floor(resistence / 2) end');

update Policies 
set CaptureCityResistanceTurnsChangeFormula = 'FORMULA_CAPTURE_CITY_RESISTANCE_CHANGE'
where Type = 'POLICY_MILITARISM';