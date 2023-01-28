update Units
set Cost = Cost * 70 / 100
where CombatClass = 'UNITCOMBAT_HELICOPTER' and Domain = 'DOMAIN_LAND';