insert into Unit_FreePromotions (UnitType, PromotionType)
select `Type`, 'PROMOTION_ANTI_RIOT_BONUS'
from Units 
where Class = 'UNITCLASS_MARINE' or Class = 'UNITCLASS_PARATROOPER' or Class = 'UNITCLASS_XCOM_SQUAD';