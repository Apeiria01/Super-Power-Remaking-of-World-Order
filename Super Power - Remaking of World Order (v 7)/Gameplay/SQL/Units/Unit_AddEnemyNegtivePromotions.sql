update UnitPromotions set AddEnemyPromotionImmune = 1 where Type = 'PROMOTION_ANTI_DEBUFF';

-- PROMOTION_COLLECTION_BARRAGE -> PROMOTION_COLLECTION_MOVEMENT_LOST
insert into PromotionCollections(Type) values ('PROMOTION_COLLECTION_BARRAGE');
insert into PromotionCollections_Entries(CollectionType, PromotionIndex, PromotionType, TriggerRangedAttack, TriggerHPPercent, TriggerLuaHook) values
('PROMOTION_COLLECTION_BARRAGE', 1, 'PROMOTION_BARRAGE_1', 1, 60, 1),
('PROMOTION_COLLECTION_BARRAGE', 2, 'PROMOTION_BARRAGE_2', 1, 75, 1),
('PROMOTION_COLLECTION_BARRAGE', 3, 'PROMOTION_BARRAGE_3', 1, 90, 1);

insert into PromotionCollections(Type) values ('PROMOTION_COLLECTION_MOVEMENT_LOST');
insert into PromotionCollections_Entries(CollectionType, PromotionIndex, PromotionType) values
('PROMOTION_COLLECTION_MOVEMENT_LOST', 1, 'PROMOTION_MOVEMENT_LOST_1'),
('PROMOTION_COLLECTION_MOVEMENT_LOST', 2, 'PROMOTION_MOVEMENT_LOST_2');

insert into PromotionCollections_AddEnemyPromotions(CollectionType, OtherCollectionType) values
('PROMOTION_COLLECTION_BARRAGE', 'PROMOTION_COLLECTION_MOVEMENT_LOST');

-- PROMOTION_COLLECTION_SUNDER -> PROMOTION_COLLECTION_PENETRATION
insert into PromotionCollections(Type) values ('PROMOTION_COLLECTION_SUNDER');
insert into PromotionCollections_Entries(CollectionType, PromotionIndex, PromotionType, TriggerRangedAttack, TriggerMeleeAttack, TriggerHPPercent, TriggerLuaHook) values
('PROMOTION_COLLECTION_SUNDER', 1, 'PROMOTION_SUNDER_1', 1, 1, 75, 1),
('PROMOTION_COLLECTION_SUNDER', 2, 'PROMOTION_SUNDER_2', 1, 1, 90, 1);

insert into PromotionCollections(Type) values ('PROMOTION_COLLECTION_PENETRATION');
insert into PromotionCollections_Entries(CollectionType, PromotionIndex, PromotionType) values
('PROMOTION_COLLECTION_PENETRATION', 1, 'PROMOTION_PENETRATION_1'),
('PROMOTION_COLLECTION_PENETRATION', 2, 'PROMOTION_PENETRATION_2');

insert into PromotionCollections_AddEnemyPromotions(CollectionType, OtherCollectionType) values
('PROMOTION_COLLECTION_SUNDER', 'PROMOTION_COLLECTION_PENETRATION');

-- PROMOTION_COLLECTION_COLLATERAL_DAMAGE VS PROMOTION_COLLECTION_MORAL_WEAKEN
insert into PromotionCollections(Type) values ('PROMOTION_COLLECTION_COLLATERAL_DAMAGE');
insert into PromotionCollections_Entries(CollectionType, PromotionIndex, PromotionType, TriggerRangedAttack, TriggerMeleeAttack, TriggerHPPercent, TriggerLuaHook) values
('PROMOTION_COLLECTION_COLLATERAL_DAMAGE', 1, 'PROMOTION_COLLATERAL_DAMAGE_1', 1, 1, 75, 1),
('PROMOTION_COLLECTION_COLLATERAL_DAMAGE', 2, 'PROMOTION_COLLATERAL_DAMAGE_2', 1, 1, 90, 1);

insert into PromotionCollections(Type) values ('PROMOTION_COLLECTION_MORAL_WEAKEN');
insert into PromotionCollections_Entries(CollectionType, PromotionIndex, PromotionType) values
('PROMOTION_COLLECTION_MORAL_WEAKEN', 1, 'PROMOTION_MORAL_WEAKEN_1'),
('PROMOTION_COLLECTION_MORAL_WEAKEN', 2, 'PROMOTION_MORAL_WEAKEN_2');
insert into PromotionCollections_AddEnemyPromotions(CollectionType, OtherCollectionType) values
('PROMOTION_COLLECTION_COLLATERAL_DAMAGE', 'PROMOTION_COLLECTION_MORAL_WEAKEN');

-- PROMOTION_COLLECTION_SP_FORCE/PROMOTION_COLLECTION_DESTROY_SUPPLY -> PROMOTION_COLLECTION_LOSE_SUPPLY
insert into PromotionCollections(Type) values ('PROMOTION_COLLECTION_SP_FORCE');
insert into PromotionCollections_Entries(CollectionType, PromotionIndex, PromotionType, TriggerRangedAttack, TriggerMeleeAttack, TriggerHPPercent, TriggerLuaHook) values
('PROMOTION_COLLECTION_SP_FORCE', 1, 'PROMOTION_SP_FORCE_1', 1, 1, 100, 0);
insert into PromotionCollections(Type) values ('PROMOTION_COLLECTION_DESTROY_SUPPLY');
insert into PromotionCollections_Entries(CollectionType, PromotionIndex, PromotionType, TriggerRangedAttack, TriggerMeleeAttack, TriggerHPPercent, TriggerLuaHook) values
('PROMOTION_COLLECTION_DESTROY_SUPPLY', 1, 'PROMOTION_DESTROY_SUPPLY_1', 1, 1, 100, 1),
('PROMOTION_COLLECTION_DESTROY_SUPPLY', 2, 'PROMOTION_DESTROY_SUPPLY_2', 1, 1, 100, 1);

insert into PromotionCollections(Type) values ('PROMOTION_COLLECTION_LOSE_SUPPLY');
insert into PromotionCollections_Entries(CollectionType, PromotionIndex, PromotionType) values
('PROMOTION_COLLECTION_LOSE_SUPPLY', 1, 'PROMOTION_LOSE_SUPPLY');
insert into PromotionCollections_AddEnemyPromotions(CollectionType, OtherCollectionType) values
('PROMOTION_COLLECTION_SP_FORCE', 'PROMOTION_COLLECTION_LOSE_SUPPLY');
insert into PromotionCollections_AddEnemyPromotions(CollectionType, OtherCollectionType) values
('PROMOTION_COLLECTION_DESTROY_SUPPLY', 'PROMOTION_COLLECTION_LOSE_SUPPLY');

-- Siege units attack Wooden Boat
insert into PromotionCollections(Type) values ('PROMOTION_COLLECTION_SIEGE_WOODEN_BOAT');
insert into PromotionCollections_Entries(CollectionType, PromotionIndex, PromotionType, TriggerRangedAttack, TriggerLuaCheck) values
('PROMOTION_COLLECTION_SIEGE_WOODEN_BOAT', 1, 'PROMOTION_CITY_SIEGE', 1, 1);
insert into PromotionCollections(Type) values ('PROMOTION_COLLECTION_WOODEN_BOAT_DAMAGE');
insert into PromotionCollections_Entries(CollectionType, PromotionIndex, PromotionType) values
('PROMOTION_COLLECTION_WOODEN_BOAT_DAMAGE', 1, 'PROMOTION_DAMAGE_1'),
('PROMOTION_COLLECTION_WOODEN_BOAT_DAMAGE', 2, 'PROMOTION_DAMAGE_2');
insert into PromotionCollections_AddEnemyPromotions(CollectionType, OtherCollectionType) values
('PROMOTION_COLLECTION_SIEGE_WOODEN_BOAT', 'PROMOTION_COLLECTION_WOODEN_BOAT_DAMAGE');

--Hwacha
insert into PromotionCollections_Entries(CollectionType, PromotionIndex, PromotionType, TriggerRangedAttack, TriggerHPPercent, TriggerLuaHook) values
('PROMOTION_COLLECTION_BARRAGE', 1, 'PROMOTION_DIVINE_WEAPON_1', 1, 50, 1),
('PROMOTION_COLLECTION_SUNDER', 1, 'PROMOTION_DIVINE_WEAPON_2', 1, 50, 1),
('PROMOTION_COLLECTION_DESTROY_SUPPLY', 1, 'PROMOTION_DIVINE_WEAPON_3', 1, 50, 1);

--Roar
insert into PromotionCollections_Entries(CollectionType, PromotionIndex, PromotionType, TriggerRangedAttack, TriggerMeleeAttack, TriggerHPPercent, TriggerLuaHook) values
('PROMOTION_COLLECTION_COLLATERAL_DAMAGE', 1, 'PROMOTION_ROARING_ELEPHANT', 1, 1, 100, 1);