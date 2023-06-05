update Yields
set GreakWorkYieldMod = 2
where Type = 'YIELD_CULTURE' or Type = 'YIELD_TOURISM';

insert into LuaFormula(Type, Formula) values
('FORMULA_EXCESS_HAPPINESS_TOURISM', 'local num, cityCount = ... if num <= 0 then return 0 else return math.floor(num / cityCount) end');

update Yields
set ExcessHappinessModifierFormula = 'FORMULA_EXCESS_HAPPINESS_TOURISM'
where Type = 'YIELD_TOURISM';