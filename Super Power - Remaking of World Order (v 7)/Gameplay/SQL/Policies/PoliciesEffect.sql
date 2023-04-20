
--Traditional Policies: CapitalYieldChanges +4
INSERT INTO Policy_CapitalYieldPerPopChanges (PolicyType,YieldType,Yield)
SELECT 'POLICY_MONARCHY','YIELD_GOLD',100 UNION ALL
SELECT 'POLICY_MONARCHY','YIELD_FOOD',100 UNION ALL
SELECT 'POLICY_MONARCHY','YIELD_CULTURE',100 UNION ALL
SELECT 'POLICY_MONARCHY','YIELD_SCIENCE',100 UNION ALL
SELECT 'POLICY_MONARCHY','YIELD_PRODUCTION',100 ;

--POLICY_LANDED_ELITE
INSERT INTO Policy_ImprovementYieldChanges (PolicyType,ImprovementType,YieldType,Yield)
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
SELECT 'POLICY_COASTAL_ADMINISTRATION','BUILDINGCLASS_SEAPORT','YIELD_GOLD',4 UNION ALL
SELECT 'POLICY_COASTAL_ADMINISTRATION','BUILDINGCLASS_SHIPYARD','YIELD_GOLD',4 UNION ALL
SELECT 'POLICY_COASTAL_ADMINISTRATION','BUILDINGCLASS_LIGHTHOUSE','YIELD_GOLD',4 UNION ALL
SELECT 'POLICY_COASTAL_ADMINISTRATION','BUILDINGCLASS_HARBOR','YIELD_GOLD',4 UNION ALL
SELECT 'POLICY_COASTAL_ADMINISTRATION','BUILDINGCLASS_WOOD_DOCK','YIELD_GOLD',4 ;

--POLICY_BILL_OF_RIGHTS
INSERT INTO Policy_BuildingClassYieldChanges (PolicyType, BuildingClassType, YieldType, YieldChange)
SELECT 'POLICY_BILL_OF_RIGHTS', t1.Type, t3.YieldType, t2.SpecialistCount
FROM BuildingClasses t1 LEFT JOIN Buildings t2 LEFT JOIN SpecialistYields t3
ON t1.DefaultBuilding = t2.Type AND t2.SpecialistType = t3.SpecialistType
WHERE t2.SpecialistCount > 0 AND 
(t2.SpecialistType = 'SPECIALIST_ENGINEER' OR t2.SpecialistType='SPECIALIST_SCIENTIST' OR t2.SpecialistType='SPECIALIST_MERCHANT'
or t2.SpecialistType='SPECIALIST_WRITER' OR t2.SpecialistType='SPECIALIST_MUSICIAN' OR t2.SpecialistType='SPECIALIST_ARTIST')
AND t3.Yield > 0;

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