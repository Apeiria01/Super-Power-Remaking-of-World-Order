insert into CustomModOptions(`Class`, `Name`, `Value`) values(5, 'API_PROMOTION_TO_PROMOTION_MODIFIERS', 1);

create table if not exists UnitPromotions_PromotionModifiers (
    `PromotionType` text not null,
    `OtherPromotionType` text not null,
    `Modifier` integer default 0 not null,
    `Attack` integer default 0 not null,
    `Defense` integer default 0 not null
);