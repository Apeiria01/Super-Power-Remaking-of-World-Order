insert into Era_MountainCityYieldChanges
select Type, 'YIELD_SCIENCE', ID + 1 from Eras
union select Type, 'YIELD_FOOD', ID + 1 from Eras;