insert into LuaFormula(Type, Formula) values
('FORMULA_CONSUMER_UNHAPPINESS_MOD', 'local num, cityCount = ... if num < 0 then return math.min(50, -num * cityCount) else if num >= 25 then return math.max(-50, -math.floor(num / cityCount)) else return 0 end end'),
('FORMULA_CONSUMER_CITY_CONNECTION_GOLD_MOD', 'local num, cityCount = ... if num < 25 then return 0 else return math.min(50, math.floor(num / cityCount)) end'),
('FORMULA_MANPOWER_GOLD_HURRY_MOD', 'local num, cityCount = ... if num < 25 then return 0 else return math.max(-35, -math.floor(num / cityCount)) end');

update Resources
set UnHappinessModifierFormula = 'FORMULA_CONSUMER_UNHAPPINESS_MOD',
	CityConnectionTradeRouteGoldModifierFormula = 'FORMULA_CONSUMER_CITY_CONNECTION_GOLD_MOD'
where Type = 'RESOURCE_CONSUMER';

update Resources
set GoldHurryCostModifierFormula = 'FORMULA_MANPOWER_GOLD_HURRY_MOD'
where Type = 'RESOURCE_MANPOWER';