insert into Building_BuildingClassYieldChanges(BuildingType, BuildingClassType, YieldType, YieldChange)
select 'BUILDING_CHINESE_GARDEN', Buildings.BuildingClass, Yields.Type, 1
from Buildings
left join Yields
where Buildings.Type like 'BUILDING_CITY_SIZE%' and Yields.Type <> 'YIELD_TOURISM';