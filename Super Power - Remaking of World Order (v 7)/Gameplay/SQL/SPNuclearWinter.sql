INSERT INTO NuclearWinterLevels(Type, Description, Help, TriggerThreshold)
SELECT 'NUCLEAR_WINTER_ALARM', 'TXT_KEY_NUCLEAR_WINTER_ALARM', 'TXT_KEY_NUCLEAR_WINTER_ALARM_HELP', 50 UNION ALL
SELECT 'NUCLEAR_WINTER_LEVEL_1', 'TXT_KEY_NUCLEAR_WINTER_LEVEL_1', 'TXT_KEY_NUCLEAR_WINTER_LEVEL_1_HELP', 75 UNION ALL
SELECT 'NUCLEAR_WINTER_LEVEL_2', 'TXT_KEY_NUCLEAR_WINTER_LEVEL_2', 'TXT_KEY_NUCLEAR_WINTER_LEVEL_2_HELP', 225 UNION ALL
SELECT 'NUCLEAR_WINTER_LEVEL_3', 'TXT_KEY_NUCLEAR_WINTER_LEVEL_3', 'TXT_KEY_NUCLEAR_WINTER_LEVEL_3_HELP', 500;

INSERT INTO NuclearWinterLevel_GlobalYieldModifier(NuclearWinterLevelType, YieldType, Yield)
SELECT 'NUCLEAR_WINTER_LEVEL_1', 'YIELD_FOOD', -10 UNION ALL
SELECT 'NUCLEAR_WINTER_LEVEL_2', 'YIELD_FOOD', -15 UNION ALL
SELECT 'NUCLEAR_WINTER_LEVEL_3', 'YIELD_FOOD', -20 UNION ALL
SELECT 'NUCLEAR_WINTER_LEVEL_3', 'YIELD_PRODUCTION', -20;