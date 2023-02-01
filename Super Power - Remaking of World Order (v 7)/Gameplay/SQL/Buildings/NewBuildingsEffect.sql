insert into Building_BuildingClassYieldChanges(BuildingType, BuildingClassType, YieldType, YieldChange)
select 'BUILDING_CHINESE_GARDEN', Buildings.BuildingClass, Yields.Type, 1
from Buildings
left join Yields
left join CitySizeBuildings
on Buildings.Type = CitySizeBuildings.BuildingType
where Buildings.Type like 'BUILDING_CITY_SIZE%' and Yields.Type in ('YIELD_FOOD', 'YIELD_PRODUCTION', 'YIELD_GOLDEN_AGE_POINTS') and CitySizeBuildings.CitySize < 4;

insert into Building_BuildingClassYieldChanges(BuildingType, BuildingClassType, YieldType, YieldChange)
select 'BUILDING_CHINESE_GARDEN', Buildings.BuildingClass, Yields.Type, 1
from Buildings
left join Yields
left join CitySizeBuildings
on Buildings.Type = CitySizeBuildings.BuildingType
where Buildings.Type like 'BUILDING_CITY_SIZE%' and Yields.Type in ('YIELD_CULTURE', 'YIELD_SCIENCE') and CitySizeBuildings.CitySize >= 4;