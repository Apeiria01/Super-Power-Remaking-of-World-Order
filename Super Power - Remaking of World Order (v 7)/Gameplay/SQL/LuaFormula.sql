insert into LuaFormula(Type, Formula) values
('FORMULA_ATTACK_CHANCE_FROM_ATTACK_DAMAGE', 'local iAttackDamage, bEmenyDeath = ... if iAttackDamage >= 30 then return true else return false end'),
('FORMULA_MOVEMENT_FROM_ATTACK_DAMAGE', 'local iAttackDamage, bEmenyDeath = ... if iAttackDamage >= 30 then return 60 else return 0 end'),
('FORMULA_HEAL_PERCENT_FROM_ATTACK_DAMAGE', 'local iAttackDamage, iMaxHitPoints, bEmenyDeath = ... if bEmenyDeath then return 10 else return 0 end');