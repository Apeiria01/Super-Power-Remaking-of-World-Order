-- PROMOTION_COLLECTION_CQB_COMBAT
insert into PromotionCollections(Type, StopAttacker) values ('PROMOTION_COLLECTION_CQB_COMBAT', 1);
insert into PromotionCollections_Entries(CollectionType, PromotionIndex, PromotionType, TriggerHPFixed, TriggerHPPercent, TriggerMeleeDefense) values
('PROMOTION_COLLECTION_CQB_COMBAT', 1, 'PROMOTION_CQB_COMBAT_1', 0, 80, 1),
('PROMOTION_COLLECTION_CQB_COMBAT', 2, 'PROMOTION_CQB_COMBAT_2', 0, 100, 1);