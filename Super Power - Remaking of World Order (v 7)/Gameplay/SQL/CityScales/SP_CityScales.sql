delete from CityScales where 1 = 1;
delete from CityScale_FreeBuildingClass where 1 = 1;

insert into CityScales(ID, Type, MinPopulation, NeedGrowthBuilding) values
(1, 'CITYSCALE_TOWN', 1, 0),
(2, 'CITYSCALE_SMALL', 6, 0),
(3, 'CITYSCALE_MEDIUM', 15, 1),
(4, 'CITYSCALE_LARGE', 26, 1),
(5, 'CITYSCALE_XL', 40, 1),
(6, 'CITYSCALE_XXL', 60, 1),
(7, 'CITYSCALE_GLOBAL', 80, 0);

insert into CityScale_FreeBuildingClass (CityScaleType, BuildingClassType, NumBuildings)
select Type, 'BUILDINGCLASS_CITY_SIZE_TOWN', 1 from CityScales where ID >= 1;

insert into CityScale_FreeBuildingClass (CityScaleType, BuildingClassType, NumBuildings)
select Type, 'BUILDINGCLASS_CITY_SIZE_SMALL', 1 from CityScales where ID >= 2;

insert into CityScale_FreeBuildingClass (CityScaleType, BuildingClassType, NumBuildings)
select Type, 'BUILDINGCLASS_CITY_SIZE_MEDIUM', 1 from CityScales where ID >= 3;

insert into CityScale_FreeBuildingClass (CityScaleType, BuildingClassType, NumBuildings)
select Type, 'BUILDINGCLASS_CITY_SIZE_LARGE', 1 from CityScales where ID >= 4;

insert into CityScale_FreeBuildingClass (CityScaleType, BuildingClassType, NumBuildings)
select Type, 'BUILDINGCLASS_CITY_SIZE_XL', 1 from CityScales where ID >= 5;

insert into CityScale_FreeBuildingClass (CityScaleType, BuildingClassType, NumBuildings)
select Type, 'BUILDINGCLASS_CITY_SIZE_XXL', 1 from CityScales where ID >= 6;

insert into CityScale_FreeBuildingClass (CityScaleType, BuildingClassType, NumBuildings)
select Type, 'BUILDINGCLASS_CITY_SIZE_GLOBAL', 1 from CityScales where ID >= 7;

insert into CityScale_FreeBuildingClass (CityScaleType, BuildingClassType, NumBuildings, RequiredTraitType)
select Type, 'BUILDINGCLASS_TB_DIPLOMACY_GREAT_PEOPLE', 1, 'TRAIT_DIPLOMACY_GREAT_PEOPLE' from CityScales where ID >= 2;

insert into CityScale_FreeBuildingClass (CityScaleType, BuildingClassType, NumBuildings, RequiredPolicyType)
select Type, 'BUILDINGCLASS_TRADITION_FOOD_GROWTH', 1, 'POLICY_ARISTOCRACY' from CityScales where ID = 1;


insert into Building_DomainTroops (BuildingType, DomainType, NumTroop)
select BuildingType, 'DOMAIN_SEA', 4 from CitySizeBuildings where CitySize > 1;