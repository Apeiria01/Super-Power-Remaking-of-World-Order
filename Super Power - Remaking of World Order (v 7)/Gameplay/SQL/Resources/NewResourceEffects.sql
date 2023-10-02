insert into LuaFormula(Type, Formula) values
('FORMULA_CONSUMER_UNHAPPINESS_MOD', 'local num, cityCount = ... if num < 0 then return math.min(50, -num * (cityCount / 10)) else if num >= 25 then return math.max(-50, -math.floor(num / cityCount)) else return 0 end end'),
('FORMULA_CONSUMER_CITY_CONNECTION_GOLD_MOD', 'local num, cityCount = ... if num < 25 then return 0 else return math.min(50, math.floor(num / cityCount)) end'),
('FORMULA_MANPOWER_GOLD_HURRY_MOD', 'local num, cityCount = ... if num < 25 then return 0 else return math.max(-35, -math.floor(5 * num / cityCount / 2)) end'),
('FORMULA_ELECTRICITY_BONUS', 'local num, cityCount, numTech = ... 	local lowerLimit = math.max(-75, -math.max(0, numTech - 50) * 5) local upperLimit = math.min(50, math.max(0, numTech - 50) * 5) if num < 0 then return math.max(lowerLimit, (cityCount / 10) * num) else if num >= 25 then return math.min(upperLimit, math.floor(num / cityCount)) else return 0 end end');

update Resources
set UnHappinessModifierFormula = 'FORMULA_CONSUMER_UNHAPPINESS_MOD',
	CityConnectionTradeRouteGoldModifierFormula = 'FORMULA_CONSUMER_CITY_CONNECTION_GOLD_MOD'
where Type = 'RESOURCE_CONSUMER';

update Resources
set GoldHurryCostModifierFormula = 'FORMULA_MANPOWER_GOLD_HURRY_MOD'
where Type = 'RESOURCE_MANPOWER';

insert into Resource_GlobalYieldModifiers values
('RESOURCE_ELECTRICITY', 'YIELD_PRODUCTION', 'FORMULA_ELECTRICITY_BONUS', 'ERA_MODERN', null),
('RESOURCE_ELECTRICITY', 'YIELD_SCIENCE', 'FORMULA_ELECTRICITY_BONUS', 'ERA_MODERN', null);