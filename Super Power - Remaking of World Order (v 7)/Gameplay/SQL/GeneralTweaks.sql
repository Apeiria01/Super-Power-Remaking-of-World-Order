-- Insert SQL Rules Here 

-- Unit_Builds -> UnitClass_Builds (from UnitType to UnitClassType) - by CaptainCWB!
CREATE TRIGGER IF NOT EXISTS UnitClass_Builds
AFTER INSERT ON Unit_Builds
BEGIN
	INSERT INTO Unit_Builds (UnitType, BuildType) SELECT Type, NEW.BuildType FROM Units WHERE Class = (SELECT Type FROM UnitClasses WHERE DefaultUnit = NEW.UnitType) AND Type != NEW.UnitType;
END;

-- UnitPromotions_CivilianUnitType -> UnitPromotions_CivilianUnitClassType (from UnitType to UnitClassType) - by CaptainCWB!
CREATE TRIGGER IF NOT EXISTS UnitPromotions_CivilianUnitClassType
AFTER INSERT ON UnitPromotions_CivilianUnitType
BEGIN
	INSERT INTO UnitPromotions_CivilianUnitType (UnitType, PromotionType) SELECT Type, NEW.PromotionType FROM Units WHERE Class = (SELECT Type FROM UnitClasses WHERE DefaultUnit = NEW.UnitType) AND Type != NEW.UnitType;
END;


-- Add Corps & Armee Promotions for UNITCLASS_CITADEL_MID & UNITCLASS_CITADEL_LATE - SP
CREATE TRIGGER IF NOT EXISTS UnitClass_FreePromotions_Corps
AFTER INSERT ON Unit_FreePromotions WHEN (NEW.PromotionType = 'PROMOTION_CARGO_I'  AND EXISTS (SELECT * FROM Unit_FreePromotions WHERE (PromotionType = 'PROMOTION_CITADEL_DEFENSE' AND UnitType = NEW.UnitType)))
BEGIN
	INSERT OR IGNORE INTO Unit_FreePromotions(UnitType, PromotionType) VALUES(NEW.UnitType, 'PROMOTION_CORPS_1');
END;
CREATE TRIGGER IF NOT EXISTS UnitClass_FreePromotions_Armee
AFTER INSERT ON Unit_FreePromotions WHEN (NEW.PromotionType = 'PROMOTION_CARGO_IV' AND EXISTS (SELECT * FROM Unit_FreePromotions WHERE (PromotionType = 'PROMOTION_CITADEL_DEFENSE' AND UnitType = NEW.UnitType)))
BEGIN
	INSERT OR IGNORE INTO Unit_FreePromotions(UnitType, PromotionType) VALUES(NEW.UnitType, 'PROMOTION_CORPS_1');
	INSERT OR IGNORE INTO Unit_FreePromotions(UnitType, PromotionType) VALUES(NEW.UnitType, 'PROMOTION_CORPS_2');
END;

CREATE TRIGGER SPFix
AFTER INSERT ON ArtDefine_StrategicView WHEN NEW.StrategicViewType = 'ART_DEF_UNIT_ZULU_BOER_COMMANDO'
BEGIN
	--Faster Aircraft Animation
	UPDATE ArtDefine_UnitMemberCombats SET MoveRate = 2*MoveRate;
	UPDATE ArtDefine_UnitMemberCombats SET TurnRateMin = 2*TurnRateMin WHERE MoveRate > 0;
	UPDATE ArtDefine_UnitMemberCombats SET TurnRateMax = 2*TurnRateMax WHERE MoveRate > 0;
END;

-- UPDATE Units SET Moves=2 WHERE Class='UNITCLASS_CARAVAN';
-- UPDATE Units SET Moves=4 WHERE Class='UNITCLASS_CARGO_SHIP';

-- +25% Faith from World Wonders - POLICY_PIETY - by CaptainCWB!
/*
CREATE TRIGGER Policy_BuildingClassYieldModifiers_SP
AFTER INSERT ON BuildingClasses WHEN NEW.MaxGlobalInstances = 1
BEGIN
	INSERT INTO Policy_BuildingClassYieldModifiers (PolicyType, BuildingClassType, YieldType, YieldMod) VALUES ('POLICY_PIETY', NEW.Type, 'YIELD_FAITH', 25);
END;
*/

-- Free Great People from Buildings don't Upgrade Threshold - by CaptainCWB!
/*
CREATE TABLE IF NOT EXISTS Building_FreeUnits_Truly("BuildingType" TEXT NOT NULL, "UnitType" TEXT NOT NULL, "NumUnits" INTEGER, FOREIGN KEY("BuildingType") REFERENCES Buildings("Type"), FOREIGN KEY("UnitType") REFERENCES Units("Type"));
CREATE TRIGGER TrulyFreeGPfromBuildings_SP
AFTER INSERT ON Building_FreeUnits WHEN EXISTS (SELECT * FROM CustomModOptions WHERE Name = 'GLOBAL_TRULY_FREE_GP' AND Value = 0) AND EXISTS (SELECT * FROM Units WHERE Type = NEW.UnitType AND Special = 'SPECIALUNIT_PEOPLE')
BEGIN
	INSERT INTO Building_FreeUnits_Truly (BuildingType, UnitType, NumUnits) VALUES (NEW.BuildingType, NEW.UnitType, NEW.NumUnits);
	DELETE FROM Building_FreeUnits WHERE BuildingType = NEW.BuildingType AND UnitType = NEW.UnitType;
END;
*/

--Trade Route Scale
UPDATE Worlds SET TradeRouteDistanceMod=60 WHERE Type='WORLDSIZE_DUEL';
UPDATE Worlds SET TradeRouteDistanceMod=60 WHERE Type='WORLDSIZE_TINY';
UPDATE Worlds SET TradeRouteDistanceMod=70 WHERE Type='WORLDSIZE_SMALL';
UPDATE Worlds SET TradeRouteDistanceMod=80 WHERE Type='WORLDSIZE_STANDARD';
UPDATE Worlds SET TradeRouteDistanceMod=100 WHERE Type='WORLDSIZE_LARGE';
UPDATE Worlds SET TradeRouteDistanceMod=120 WHERE Type='WORLDSIZE_HUGE';

UPDATE GameSpeeds SET TradeRouteSpeedMod=900 WHERE Type='GAMESPEED_QUICK';
UPDATE GameSpeeds SET TradeRouteSpeedMod=1000 WHERE Type='GAMESPEED_STANDARD';
UPDATE GameSpeeds SET TradeRouteSpeedMod=1200 WHERE Type='GAMESPEED_EPIC';
UPDATE GameSpeeds SET TradeRouteSpeedMod=1200 WHERE Type='GAMESPEED_MARATHON';

UPDATE CustomModOptions SET Value = 1 WHERE Name = 'EVENTS_UNIT_UPGRADES';
UPDATE CustomModOptions SET Value = 1 WHERE Name = 'EVENTS_UNIT_CREATED';