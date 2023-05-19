insert into PromotionCollections(Type) values ('PROMOTION_COLLECTION_BARRAGE');
insert into PromotionCollections_Entries(CollectionType, PromotionIndex, PromotionType, TriggerRangedAttack, TriggerHPFixed, TriggerLuaHook) values
('PROMOTION_COLLECTION_BARRAGE', 1, 'PROMOTION_BARRAGE_1', 1, 60, 1),
('PROMOTION_COLLECTION_BARRAGE', 2, 'PROMOTION_BARRAGE_2', 1, 75, 1),
('PROMOTION_COLLECTION_BARRAGE', 3, 'PROMOTION_BARRAGE_3', 1, 90, 1);

insert into PromotionCollections(Type) values ('PROMOTION_COLLECTION_MOVEMENT_LOST');
insert into PromotionCollections_Entries(CollectionType, PromotionIndex, PromotionType) values
('PROMOTION_COLLECTION_MOVEMENT_LOST', 1, 'PROMOTION_MOVEMENT_LOST_1'),
('PROMOTION_COLLECTION_MOVEMENT_LOST', 2, 'PROMOTION_MOVEMENT_LOST_2');

insert into PromotionCollections_AddEnermyPromotions(CollectionType, OtherCollectionType) values
('PROMOTION_COLLECTION_BARRAGE', 'PROMOTION_COLLECTION_MOVEMENT_LOST');

insert into PromotionCollections(Type) values ('PROMOTION_COLLECTION_SUNDER');
insert into PromotionCollections_Entries(CollectionType, PromotionIndex, PromotionType, TriggerRangedAttack, TriggerHPFixed, TriggerLuaHook) values
('PROMOTION_COLLECTION_SUNDER', 1, 'PROMOTION_SUNDER_1', 1, 75, 1),
('PROMOTION_COLLECTION_SUNDER', 2, 'PROMOTION_SUNDER_2', 1, 90, 1);

insert into PromotionCollections(Type) values ('PROMOTION_COLLECTION_PENETRATION');
insert into PromotionCollections_Entries(CollectionType, PromotionIndex, PromotionType) values
('PROMOTION_COLLECTION_PENETRATION', 1, 'PROMOTION_PENETRATION_1'),
('PROMOTION_COLLECTION_PENETRATION', 2, 'PROMOTION_PENETRATION_2');

insert into PromotionCollections_AddEnermyPromotions(CollectionType, OtherCollectionType) values
('PROMOTION_COLLECTION_SUNDER', 'PROMOTION_COLLECTION_PENETRATION');