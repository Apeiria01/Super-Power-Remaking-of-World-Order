insert into
    CustomModOptions(`Class`, `Name`, `Value`)
select
    5,
    'API_UNIT_CANNOT_BE_RANGED_ATTACKED',
    1
where
    not exists (
        select
            1
        from
            CustomModOptions
        where
            `Class` = 5
            and `Name` = 'API_UNIT_CANNOT_BE_RANGED_ATTACKED'
    );

alter table
    UnitPromotions
add
    column `CannotBeRangedAttacked` boolean default 0 not null;