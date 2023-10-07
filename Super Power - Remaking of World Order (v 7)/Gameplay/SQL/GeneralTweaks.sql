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