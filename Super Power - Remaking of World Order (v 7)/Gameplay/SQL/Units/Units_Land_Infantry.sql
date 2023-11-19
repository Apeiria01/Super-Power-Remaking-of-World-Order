insert into Unit_FreePromotions (UnitType, PromotionType)
select `Type`, 'PROMOTION_ANTI_RIOT_BONUS'
from Units 
where Class = 'UNITCLASS_MARINE' or Class = 'UNITCLASS_PARATROOPER' or Class = 'UNITCLASS_XCOM_SQUAD';

INSERT INTO UnitPromotions_PromotionUpgrade(PromotionType, JudgePromotionType, NewPromotionType)
SELECT 'PROMOTION_FORMATION_1', 'PROMOTION_ANTI_TANK', 'PROMOTION_AMBUSH_1' UNION ALL
SELECT 'PROMOTION_FORMATION_2', 'PROMOTION_ANTI_TANK', 'PROMOTION_AMBUSH_2';