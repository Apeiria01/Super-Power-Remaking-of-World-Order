insert into BarbarianKings
(UnitType,                          LandWeight, SeaWeight, MaxInstance) values
('UNIT_POLISH_PZLW3_HELICOPTER',    100,        50,        1),
('UNIT_ENGLISH_CROMWELL_TANK',      50,         50,        1),
('UNIT_ENGLISH_CROMWELL_TANK',      50,         50,        1),
('UNIT_CHINESE_052D',               0,          400,       1),
('UNIT_JAPANESE_DESTROYER',         0,          400,       1),
('UNIT_MECH',                       1,          1,         1000);

insert into BarbarianCityFreeBuildings
(BuildingType, Num) values
('BUILDING_WALLS', 1),
('BUILDING_BARRACKS', 1);

update DEFINES set Value = 100 where Name = 'BARBARIAN_CITY_SPAWN_PROBABLITY';