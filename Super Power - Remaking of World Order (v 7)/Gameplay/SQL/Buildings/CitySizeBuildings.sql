create table CitySizeBuildings (
    CitySize integer not null primary key,
    BuildingType text default ''
);

insert into CitySizeBuildings(CitySize, BuildingType) values
(1, 'BUILDING_CITY_SIZE_TOWN'),
(2, 'BUILDING_CITY_SIZE_SMALL'),
(3, 'BUILDING_CITY_SIZE_MEDIUM'),
(4, 'BUILDING_CITY_SIZE_LARGE'),
(5, 'BUILDING_CITY_SIZE_XL'),
(6, 'BUILDING_CITY_SIZE_XXL'),
(7, 'BUILDING_CITY_SIZE_GLOBAL');