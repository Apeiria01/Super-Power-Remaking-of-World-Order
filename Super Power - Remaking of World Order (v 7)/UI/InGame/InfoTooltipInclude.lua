--==========================================================
-- Modified by bc1 from 1.0.3.276 code using Notepad++
-- extend full unit & building info pregame
-- extend AI mood info
-- code is common switches
-- compatible with Communitas breaking yield types
-- TODO: lots !
-- remove YieldIcons
--==========================================================

if not GameInfoCache then
	local collectgarbage = collectgarbage
	local pairs = pairs
	local next = next
	local print = print
	local setmetatable = setmetatable
	local type = type
	local insert = table.insert
	local sort = table.sort

	local ContentManager_IsActive = ContentManager.IsActive
	local ContentType_GAMEPLAY = ContentType.GAMEPLAY
	local GameInfo = GameInfo
	local Game = Game
	local L = Locale.ConvertTextKey

	local nilFunction = function() end
	GameInfoCache = setmetatable( {}, { __index = function( t, tableName )
		local thisGameInfoTable = GameInfo[ tableName ]
		if thisGameInfoTable then
			local keys = {}
	--print( "Caching GameInfo table", tableName )
			for row in DB.Query( "PRAGMA table_info("..tableName..")" ) do
				keys[ row.name ] = true
			end
	--for k in pairs( keys ) do print( k ) end
			local setMT
			setMT = { __index = function( set, key )
				if keys[key] then -- verify key is actually valid
	--print("Creating subset for key", key )
					local index = {}
					set[ key ] = index
					for i = 1, #set do
						local row = set[i]
						local v = row[ key ]
						if v then
							local subset = index[ v ]
							if not subset then
								subset = setmetatable( {}, setMT )
								index[ v ] = subset
							end
							insert( subset, row )
						end
					end
					return index
				end
			end }
			local set = setmetatable( {}, setMT )
			local function iterator( t, condition )
				local subset = set
				if condition then
				-- Warning: EUI's GameInfoCache iterator only supports table conditions
					for key, value in pairs( condition ) do
						subset = (subset[ key ] or {})[ value ]
						if not subset then
							return nilFunction
						end
					end
				end
				local k = 0
				local l = #subset
				return function()
					if k < l then
						k = k+1
						return subset[ k ]
					end
				end
			end
			local cacheMT
			cacheMT = { __index = function( t, key )
	--print("caching", tableName, t, key)
					if key then
						local row = thisGameInfoTable[ key ]
						if row then
							local cache = {}
							for k, v in pairs( row ) do
								cache[k] = v
							end
							t[ cache.ID or key ] = cache
							t[ cache.Type or key ] = cache
							return cache
						else
							t[ key ] = false
						end
					end
				end, __call = function( t, condition )
	--print("calling", tableName, t, condition )
					if keys.ID then
						for row in thisGameInfoTable() do
							insert( set, t[row.ID] )
						end
					else
						for row in thisGameInfoTable() do
							local cache = {}
							for k, v in pairs( row ) do
								cache[ k ] = v
							end
							insert( set, cache )
						end
					end
					cacheMT.__call = iterator
					cacheMT.__index = nil
					return iterator( t, condition )
				end
			}
			local cache = setmetatable( {}, cacheMT )
			t[ tableName ] = cache
			return cache
		end
	end } )
end
local GameInfo = GameInfoCache

local IsCiv5 = InStrategicView ~= nil
local IsCiv5BNW = IsCiv5 and ContentManager.IsActive("6DA07636-4123-4018-B643-6575B4EC336B", ContentType.GAMEPLAY)
local IsCiv5Vanilla = IsCiv5 and not IsCiv5BNW and not ContentManager.IsActive("0E3751A1-F840-4e1b-9706-519BF484E59D", ContentType.GAMEPLAY)

if IsCiv5BNW and not GreatPeopleIcons then
	GreatPeopleIcons = {
		SPECIALIST_CITIZEN = "[ICON_CITIZEN]",
		SPECIALIST_WRITER = "[ICON_GREAT_WRITER]",
		SPECIALIST_ARTIST = "[ICON_GREAT_ARTIST]",
		SPECIALIST_MUSICIAN = "[ICON_GREAT_MUSICIAN]",
		SPECIALIST_SCIENTIST = "[ICON_GREAT_SCIENTIST]",
		SPECIALIST_MERCHANT = "[ICON_GREAT_MERCHANT]",
		SPECIALIST_ENGINEER = "[ICON_GREAT_ENGINEER]",
		SPECIALIST_GREAT_GENERAL = "[ICON_GREAT_GENERAL]",
		SPECIALIST_GREAT_ADMIRAL = "[ICON_GREAT_ADMIRAL]",
		SPECIALIST_PROPHET = "[ICON_PROPHET]",
		UNIT_WRITER = "[ICON_GREAT_WRITER]",
		UNIT_ARTIST = "[ICON_GREAT_ARTIST]",
		UNIT_MUSICIAN = "[ICON_GREAT_MUSICIAN]",
		UNIT_SCIENTIST = "[ICON_GREAT_SCIENTIST]",
		UNIT_MERCHANT = "[ICON_GREAT_MERCHANT]",
		UNIT_ENGINEER = "[ICON_GREAT_ENGINEER]",
		UNIT_GREAT_GENERAL = "[ICON_GREAT_GENERAL]",
		UNIT_GREAT_ADMIRAL = "[ICON_GREAT_ADMIRAL]",
		UNIT_PROPHET = "[ICON_PROPHET]",
		UNIT_VENETIAN_MERCHANT = "[ICON_GREAT_MERCHANT_VENICE]",
	}
	local GreatPeopleIcons = GreatPeopleIcons

	for specialist in GameInfo.Specialists() do
		if specialist.Type and GreatPeopleIcons[specialist.Type] == nil then
			GreatPeopleIcons[specialist.Type] = "[ICON_GREAT_PEOPLE]"
		end
		GreatPeopleIcons[specialist.ID or false] = GreatPeopleIcons[specialist.Type]
	end
	for unit in GameInfo.Units() do
		if unit.Type and GreatPeopleIcons[unit.Type] ~= nil then
			GreatPeopleIcons[unit.ID or false] = GreatPeopleIcons[unit.Type]
			GreatPeopleIcons[unit.Class or false] = GreatPeopleIcons[unit.Type]
		else
		    if unit.Class == nil or GameInfo.UnitClasses[unit.Class].DefaultUnit == nil
		    or (GreatPeopleIcons[GameInfo.UnitClasses[unit.Class].DefaultUnit] == nil
		    and GreatPeopleIcons[unit.Class] == nil)
		    then
			GreatPeopleIcons[unit.Type or false] = "[ICON_GREAT_PEOPLE]"
			GreatPeopleIcons[unit.ID or false] = "[ICON_GREAT_PEOPLE]"
			GreatPeopleIcons[unit.Class or false] = "[ICON_GREAT_PEOPLE]"
		    elseif GreatPeopleIcons[unit.Class] then
			GreatPeopleIcons[unit.Type or false] = GreatPeopleIcons[unit.Class]
			GreatPeopleIcons[unit.ID or false] = GreatPeopleIcons[unit.Class]
		    else
			GreatPeopleIcons[unit.Type or false] = GreatPeopleIcons[GameInfo.UnitClasses[unit.Class].DefaultUnit]
			GreatPeopleIcons[unit.ID or false] = GreatPeopleIcons[GameInfo.UnitClasses[unit.Class].DefaultUnit]
			GreatPeopleIcons[unit.Class or false] = GreatPeopleIcons[GameInfo.UnitClasses[unit.Class].DefaultUnit]
		    end
		end
	end
	GreatPeopleIcons[false] = nil
end
local GreatPeopleIcons = GreatPeopleIcons

--print( "Root contexts:", LookUpControl( "/FrontEnd" ) or "nil", LookUpControl( "/InGame" ) or "nil", LookUpControl( "/LeaderHeadRoot" ) or "nil")

--==========================================================
-- Minor lua optimizations
--==========================================================

local ipairs = ipairs
local ceil = math.ceil
local floor = math.floor
local max = math.max
local pairs = pairs
local format = string.format
local concat = table.concat
local insert = table.insert
local sort = table.sort
local tonumber = tonumber
local tostring = tostring

local DisputeLevelTypes = DisputeLevelTypes
local Game = Game
local GameDefines = GameDefines
local GameInfoTypes = GameInfoTypes
local GameOptionTypes = GameOptionTypes
local Locale_ToLower = Locale.ToLower
local Locale_ToUpper = Locale.ToUpper
local MajorCivApproachTypes = MajorCivApproachTypes
local OptionsManager = OptionsManager
local Players = Players
local PreGame = PreGame
local Teams = Teams
local ThreatTypes = ThreatTypes
local TradeableItems = TradeableItems
local GetHeadSelectedCity = UI.GetHeadSelectedCity
local GetNumCurrentDeals = UI.GetNumCurrentDeals
local LoadCurrentDeal = UI.LoadCurrentDeal
local YieldTypes = YieldTypes
local L
do
	local _L = Locale.ConvertTextKey
	function L( text, ...)
		return _L( tostring(text), ... )
	end
end

local YieldIcons = {}
do
	local DB_Query = DB.Query
	for row in Game and GameInfo.Yields() or DB_Query("SELECT * from Yields") do
		YieldIcons[row.ID or false] = row.IconString
		YieldIcons[row.Type or false] = row.IconString
	end
	YieldIcons.YIELD_CULTURE = YieldIcons.YIELD_CULTURE or "[ICON_CULTURE]"
	--new
	YieldIcons.YIELD_ELECTRICITY = "[ICON_RES_ELECTRICITY]"
	YieldIcons.YIELD_TOURISM = "[ICON_TOURISM]"
end

local function append( t, text )
	t[#t] = t[#t] .. text
end

local function insertLocalizedIfNonZero( t, textKey, ... )
	if ... ~= 0 then
		return insert( t, L( textKey, ... ) )
	end
end

local function insertLocalizedBulletIfNonZero( t, a, b, ... )
	if tonumber( b ) then
		if b ~= 0 then
			return insert( t, "[ICON_BULLET]" .. L( a, b, ... ) )
		end
	elseif ... ~= 0 then
		return insert( t, a .. L( b, ... ) )
	end
end

local g_currencyIcon = IsCiv5 and "[ICON_GOLD]" or "[ICON_ENERGY]"
local g_maintenanceCurrency = IsCiv5 and "GoldMaintenance" or "EnergyMaintenance"
local g_isScienceEnabled = true
local g_isPoliciesEnabled = true
local g_isReligionEnabled = not IsCiv5Vanilla

local function GetCivUnit( civilizationType, unitClassType )
	if unitClassType then
		if civilizationType and GameInfo.Civilization_UnitClassOverrides{ CivilizationType = civilizationType, UnitClassType = unitClassType }() then
			local unit = GameInfo.Civilization_UnitClassOverrides{ CivilizationType = civilizationType, UnitClassType = unitClassType }()
			return unit and GameInfo.Units[ unit.UnitType ]
		end
		local unitClass = GameInfo.UnitClasses[ unitClassType ]
		return unitClass and GameInfo.Units[ unitClass.DefaultUnit ]
	end
end

local function GetCivBuilding( civilizationType, buildingClassType )
	if buildingClassType then
		if civilizationType and GameInfo.Civilization_BuildingClassOverrides{ CivilizationType = civilizationType, BuildingClassType = buildingClassType }() then
			local building = GameInfo.Civilization_BuildingClassOverrides{ CivilizationType = civilizationType, BuildingClassType = buildingClassType }()
			return building and GameInfo.Buildings[ building.BuildingType ]
		end
		local buildingClass = GameInfo.BuildingClasses[ buildingClassType ]
		return buildingClass and GameInfo.Buildings[ buildingClass.DefaultBuilding ]
	end
end

local function GetYieldStringSpecial( tag, s, iterator )
	local tip = ""
	for row in iterator do
		if (row[tag] or 0) ~=0 then
			tip = format( s, tip, row[tag], YieldIcons[ row.YieldType ] or "?" )
		end
	end
	return tip
end
local function GetYieldString( iterator )
	return GetYieldStringSpecial( "Yield", "%s %+i%s", iterator )
end


----new
local function GetresourceStringSpecial( tag, s, iterator )
	local tip = ""
	for row in iterator do
		if (row[tag] or 0) ~=0 then
			tip = format( s, tip, row[tag], GameInfo.Resources[ row.ResourceType ].IconString or "?" )
		end
	end
	return tip
end
local function GetresourceString( iterator )
	return GetresourceStringSpecial( "Value", "%s %+i%s", iterator )
end
-------end


----new
local function GetSpecialistStringSpecial( tag, s, iterator )
	local tip = ""
	for row in iterator do
		if (row[tag] or 0) ~=0 then
			tip = format( s, tip, row[tag], GameInfo.Specialists[ row.SpecialistType].Description or "?" )
		end
	end
	return tip
end
local function GetSpecialistString( iterator )
	return GetSpecialistStringSpecial( "Modifier", "%s %+i%s", iterator )
end
-------end

local negativeOrPositiveTextColor = { [true] = "[COLOR_POSITIVE_TEXT]", [false] = "[COLOR_WARNING_TEXT]" }

local function TextColor( c, s )
	return c..(s or "???").."[ENDCOLOR]"
end

local function UnitColor( s )
	return TextColor("[COLOR_UNIT_TEXT]", s)
end

local function BuildingColor( s )
	return TextColor("[COLOR_YIELD_FOOD]", s)
end

local function PolicyColor( s )
	return TextColor("[COLOR_MAGENTA]", s)
end

local function TechColor( s )
	return TextColor("[COLOR_CYAN]", s)
end

local function BeliefColor( s )
	return TextColor("[COLOR_WHITE]", s)
end

local function BuildColor( s )
	return TextColor("[COLOR_GREEN]", s)
end

local function ResourceColor( s )
	return TextColor("[COLOR_BROWN]", s)
end

local function ResourceString( resource )
	return ( resource.IconString or "?" ) .. ResourceColor( L(resource.Description) ) 
end

local function ResourceQuantity( resource, quantity )
	return format( "%+i%s%s", quantity, resource.IconString or "?", ResourceColor( L(resource.Description) ) )
end


local function XPcolor( s )
	return TextColor("[COLOR_BLUE]", s)
end

local function SetKey( t, key, value )
	if key then
		t[key] = value or true
	end
end

local function AddPreWrittenHelpTextAndConcat( tips, row ) -- assumes tips is a table
	local tip = row and row.Help and L( row.Help ) or ""
	if tip ~= "" then
		if #tips > 2 then
			insert( tips, "----------------" )
		end
		insert( tips, tip )
	end
	return concat( tips, "[NEWLINE]" )
end

local GreatPeopleIcon = GreatPeopleIcons and function (k)
	return GreatPeopleIcons[k] or "[ICON_GREAT_PEOPLE]"
end or function()
	return "[ICON_GREAT_PEOPLE]"
end

-------------------------------------------------
-- Help text for Units
-------------------------------------------------

-- How much does it cost to upgrade a Unit to a shiny new eUnit?
local function unitUpgradePrice( unit, unitUpgrade, unitProductionCost, unitUpgradeProductionCost )
	local upgradePrice = GameDefines.BASE_UNIT_UPGRADE_COST
		+ max( 0, (unitUpgradeProductionCost or unitUpgrade.Cost or 0) - (unitProductionCost or unit.Cost or 0) ) * GameDefines.UNIT_UPGRADE_COST_PER_PRODUCTION
	-- Upgrades for later units are more expensive
	local tech = GameInfo.Technologies[ unitUpgrade.PrereqTech ]
	if tech then
		upgradePrice = floor( upgradePrice * ( GameInfo.Eras[ tech.Era ].ID * GameDefines.UNIT_UPGRADE_COST_MULTIPLIER_PER_ERA + 1 ) )
	end
	-- Discount
	-- upgradePrice = upgradePrice - floor( upgradePrice * unit:UpgradeDiscount() / 100)
	-- Mod (Policies, etc.)
	-- upgradePrice = floor( (upgradePrice * (100 + activePlayer:GetUnitUpgradeCostMod()))/100 )
	-- Apply exponent
	upgradePrice = floor( upgradePrice ^ GameDefines.UNIT_UPGRADE_COST_EXPONENT )
	-- Make the number not be funky
	return floor( upgradePrice / GameDefines.UNIT_UPGRADE_COST_VISIBLE_DIVISOR ) * GameDefines.UNIT_UPGRADE_COST_VISIBLE_DIVISOR
end

-- ActivePlayer Data
local activePlayerID = Game and Game.GetActivePlayer()
local activePlayer = activePlayerID and Players[ activePlayerID ]
local activeCivilization = activePlayer and GameInfo.Civilizations[ activePlayer:GetCivilizationType() ]
local activeCivilizationType = activeCivilization and activeCivilization.Type
local activeTeamID = Game and Game.GetActiveTeam()
local activeTeam = activeTeamID and Teams[activeTeamID]
local activeTeamTechs = activeTeam and activeTeam:GetTeamTechs()
local activePlayerIdeologyID = bnw_mode and activePlayer and activePlayer:GetLateGamePolicyTree()
local activePlayerIdeology = activePlayerIdeologyID and GameInfo.PolicyBranchTypes[ activePlayerIdeologyID ]
local activePlayerIdeologyType = activePlayerIdeology and activePlayerIdeology.Type
local activePlayerBeliefs = {}
local availableBeliefs = {}
local activePerkTypes = {}

function GetHelpTextForUnit( unitID ) -- isIncludeRequirementsInfo )
	local unit = GameInfo.Units[ unitID ]
	if not unit then
		return "<Unit undefined in game database>"
	end

	-- Unit XML stats
	local unitClass = GameInfo.UnitClasses[ unit.Class ]
	local unitClassID = unitClass and unitClass.ID
	local maxGlobalInstances = unitClass and tonumber(unitClass.MaxGlobalInstances) or -1
	local maxTeamInstances = unitClass and tonumber(unitClass.MaxTeamInstances) or -1
	local maxPlayerInstances = unitClass and tonumber(unitClass.MaxPlayerInstances) or -1
	local productionCost = unit.Cost
	local rangedStrength = unit.RangedCombat
	local unitRange = unit.Range
	local combatStrength = unit.Combat
	local unitMoves = unit.Moves
	local unitSight = unit.BaseSightRange
	local unitDomainType = unit.Domain

	local HitModifier = 0
	local HitChange = 0
	

	local thisUnitType = { UnitType = unit.Type }
	local thisUnitClass =  { UnitClassType = unit.Class }

	local freePromotions = {}

	local city, item, resource


	------------------------------------------------new for Promotions------------------------------------------------
    for row in GameInfo.Unit_FreePromotions( thisUnitType ) do
		item = GameInfo.UnitPromotions[ row.PromotionType ]
		if item then
		    HitModifier= HitModifier + item.MaxHitPointsModifier
		    HitChange= HitChange + item.MaxHitPointsChange
            if item.ShowInUnitPanel ~= 0 and item.ShowInTooltip ~= 0 then
                insert( freePromotions, item.IconStringSP.. L(item.Description) )
                unitRange = unitRange + (item.RangeChange or 0)
                unitMoves = unitMoves + (item.MovesChange or 0)
                unitSight = unitSight + (item.VisibilityChange or 0)
            end
		end
	end

	local unitName = unit.Description
	if activePlayer then
		productionCost = activePlayer:GetUnitProductionNeeded( unitID )
		city = GetHeadSelectedCity()
		if city and city:GetOwner() ~= activePlayerID then
			city = nil
		end
		city = city or activePlayer:GetCapitalCity() or activePlayer:Cities()(activePlayer)
	end

	-- Name
	item = unit.CombatClass and GameInfo.UnitCombatInfos[ unit.CombatClass ]
	local tip =  format( "%s %s", ( unit.Special and unit.Special == "SPECIALUNIT_PEOPLE" and GreatPeopleIcon( unit.Type ) or "" ), UnitColor( Locale_ToUpper( unitName ) ) )
	if item then
		tip = tip .. " (" .. L(item.Description or "???") .. ")"
	end

	local tips = { tip }
	
	insert( tips, "----------------" )

	if unitDomainType ~= "DOMAIN_AIR" then
		-- Movement:
		insert( tips, L"TXT_KEY_PEDIA_MOVEMENT_LABEL" .. " " .. unitMoves .. "[ICON_MOVES]" )
	end

	-- Combat:
	if combatStrength > 0 then
		insert( tips, format( "%s %g[ICON_STRENGTH]", L"TXT_KEY_PEDIA_COMBAT_LABEL", combatStrength ) )
	end

	--new for maxhp:
	if unit.MaxHitPoints~=nil then
        if HitModifier==0 then
            maxhp = unit.MaxHitPoints + HitChange
            insert( tips, L"TXT_KEY_PEDIA_MAXHP_LABEL_SP".. " " .. maxhp .. "[ICON_SILVER_FIST]")
        else
            maxhp = ((unit.MaxHitPoints)*HitModifier/100)+ HitChange
            insert( tips, L"TXT_KEY_PEDIA_MAXHP_LABEL_SP".. " " .. maxhp .. "[ICON_SILVER_FIST]")
        end
	end


	-- Ranged Combat:
	if rangedStrength > 0 then
		insert( tips, L"TXT_KEY_PEDIA_RANGEDCOMBAT_LABEL" .. " " .. rangedStrength .. "[ICON_RANGE_STRENGTH]" .. unitRange )
	end

	--new for Sight:
	if unitSight > 0 then
		insert( tips, L"TXT_KEY_PEDIA_SIGHT_LABEL_SP" .. " " .. unitSight .. "[ICON_PROMOTION_SIGHT_1]" )
	end

	-- new for Abilities:	--TXT_KEY_PEDIA_FREEPROMOTIONS_LABEL
	if #freePromotions > 0 then
		insert( tips, L"TXT_KEY_FREEPROMOTIONS".."".."[NEWLINE]" .. concat( freePromotions,"[NEWLINE]" ).."[NEWLINE]----------------" )
	end

	-- Ability to create building in city (e.g. vanilla great general)
	for row in GameInfo.Unit_Buildings( thisUnitType ) do
		item = GameInfo.Buildings[ row.BuildingType ]
		if item then
			insert( tips, "[ICON_BULLET]"..L"TXT_KEY_MISSION_CONSTRUCT".." " .. BuildingColor( L(item.Description) ) )
		end
	end

	-- Actions	--TXT_KEY_PEDIA_WORKER_ACTION_LABEL
	for row in GameInfo.Unit_Builds( thisUnitType ) do
		local build = GameInfo.Builds[ row.BuildType ]
		if build then
			item = build.ImprovementType and GameInfo.Improvements[ build.ImprovementType ]
			if not item or not item.SpecificCivRequired or not activePlayer or GameInfoTypes[ GameInfo.Civilizations[ item.CivilizationType ] ] == activePlayer:GetCivilizationType() then -- GameInfoTypes not available pregame: works because activePlayer is also nil
				item = build.PrereqTech and GameInfo.Technologies[ build.PrereqTech ]
				insert( tips, "[ICON_BULLET]" .. (item and TechColor( L(item.Description) ) .. " " or "") .. BuildColor( L(build.Description) ) )
			end
		end
	end
	-- Great Engineer
	if (unit.BaseHurry or 0) > 0 then
		insert( tips, format( "[ICON_BULLET]%s %i[ICON_PRODUCTION]%+i[ICON_PRODUCTION]/[ICON_CITIZEN]", L"TXT_KEY_MISSION_HURRY_PRODUCTION", unit.BaseHurry, unit.HurryMultiplier or 0 ) )
	end

	-- Great Merchant
	if (unit.BaseGold or 0) > 0 then
		insert( tips, format( "[ICON_BULLET]%s %i%s%+i[ICON_INFLUENCE]", L"TXT_KEY_MISSION_CONDUCT_TRADE_MISSION", unit.BaseGold + ( unit.NumGoldPerEra or 0 ) * ( Game and Teams[Game.GetActiveTeam()]:GetCurrentEra() or PreGame.GetEra() ), g_currencyIcon, GameDefines.MINOR_FRIENDSHIP_FROM_TRADE_MISSION or 0 ) )
	end

	-- Other tags
	local unitFlag = {
	--y	RequiresFaithPurchaseEnabled = L"TXT_KEY_NOTIFICATION_SUMMARY_ENOUGH_FAITH_FOR_MISSIONARY",
	--y	PurchaseOnly = L("TXT_KEY_RO_AUTO_FAITH_PURCHASE_GREAT_PERSON", L"TXT_KEY_POPUP_GREAT_PERSON_UNIT"),
		MoveAfterPurchase = L"TXT_KEY_MOVE_AFTER_PC",			-- TODO, LANDSKNECHT
		Immobile = L"TXT_KEY_DOMAIN_IMMOBILE",				-- bombs, missiles, aircraft etc...
	--y	Food = L"TXT_KEY_CITYVIEW_STAGNATION_TEXT" .. " (" .. L"TXT_KEY_POPULATION_SUPPLY" .. ")",	-- build using food / stop city growth
	--n	NoBadGoodies = "",						-- scout, does it have any in-game effect ?
		RivalTerritory = "[ICON_PROMOTION_GOLDEN_AGE_POINTS]" .. L"TXT_KEY_PROMOTION_RIVAL_TERRITORY",		-- unused
	--n	MilitarySupport = "",
	--n	MilitaryProduction = "",
	--	Pillage = L"TXT_KEY_MISSION_PILLAGE",				-- not very informative
		Found = "[ICON_PROMOTION_SIEGE_3]" .. L"TXT_KEY_MISSION_BUILD_CITY",
		FoundAbroad = "[ICON_PROMOTION_SIEGE_2]" .. L"TXT_KEY_MISSION_BUILD_CITY" .. " <> " .. L"TXT_KEY_PGSCREEN_CONTINENTS",
	--u	IgnoreBuildingDefense = "",					-- TODO, important
	--n	PrereqResources = "",						-- workboat only, not informative
	--n	Mechanized = "",						-- art only ?
		Suicide = "[ICON_PROMOTION_AMBUSH_1]" .. L"TXT_KEY_SUICIDE",	-- TODO, although obvious for base game may be less so in mods
	--u	CaptureWhileEmbarked = "",					-- unused
		RushBuilding = L"TXT_KEY_MISSION_HURRY_PRODUCTION",
		SpreadReligion = "[ICON_MISSIONARY]" .. L"TXT_KEY_MISSION_SPREAD_RELIGION",
		RemoveHeresy = L"TXT_KEY_MISSION_REMOVE_HERESY",
		FoundReligion = "[ICON_PROPHET]" .. L"TXT_KEY_MISSION_FOUND_RELIGION",
		RequiresEnhancedReligion = L"TXT_KEY_REQUIRES_E",			-- TODO (inquisitors)
		ProhibitsSpread = "[ICON_INQUISITOR]" .. L"TXT_KEY_PROHIBITS_SPREAD",	-- TODO (inquisitors)
		CanBuyCityState = "[ICON_PROMOTION_TRADE_MISSION_BONUS]" .. L"TXT_KEY_MISSION_BUY_CITY_STATE",
	--n	RangeAttackOnlyInDomain = "",					-- used only for subs
		RangeAttackIgnoreLOS = "[ICON_PROMOTION_INDIRECT_FIRE]" .. L"TXT_KEY_PROMOTION_INDIRECT_FIRE",
		Trade = "[ICON_TRADE]" .. L"TXT_KEY_MISSION_ESTABLISH_TRADE_ROUTE",
		NoMaintenance = L"TXT_KEY_PEDIA_MAINT_LABEL" .. " 0",
	--n	UnitArtInfoCulturalVariation = "",
	--n	UnitArtInfoEraVariation = "",
	--n	DontShowYields = "",
	--n	ShowInPedia = "",
	}
	local unitData = {
	--y	Combat = L"TXT_KEY_PEDIA_COMBAT_LABEL".." %i",
	--y	RangedCombat = L"TXT_KEY_PEDIA_RANGEDCOMBAT_LABEL".." %i[ICON_RANGE_STRENGTH]",
	--y	Cost = "",
	--y	FaithCost = "",
	--y	Moves = L"TXT_KEY_PEDIA_MOVEMENT_LABEL".." %i[ICON_MOVES]",
	--y	Range = L"TXT_KEY_PEDIA_RANGE_LABEL" .. " [ICON_RANGE_STRENGTH]%i",
	--y	BaseSightRange = L"TXT_KEY_COMBAT_LINEOFSIGHT_HEADING3_TITLE" .. " [ICON_RANGE_STRENGTH]%i",
		CultureBombRadius = L"TXT_KEY_MISSION_CULTURE_BOMB" .. " ([ICON_RANGE_STRENGTH]%i)",	-- unused
		GoldenAgeTurns = L"TXT_KEY_MISSION_START_GOLDENAGE" .. " (%i " .. L"TXT_KEY_TURNS"..")",	-- Artist
		FreePolicies = L"TXT_KEY_MISSION_GIVE_POLICIES" .. " (%ix[ICON_CULTURE])",	-- unused
		OneShotTourism = L"TXT_KEY_MISSION_ONE_SHOT_TOURISM" .. " (%ix[ICON_TOURISM])",	-- Musician
	--n	OneShotTourismPercentOthers = "",				-- Musician
	--y	HurryCostModifier = "",
	--n	AdvancedStartCost = "",
	--n	MinAreaSize = "",
		AirInterceptRange = L"TXT_KEY_MISSION_INTERCEPT" .. " [ICON_RANGE_STRENGTH]%i",
	--n	AirUnitCap = "",
	--n	NukeDamageLevel = "",
	--n	WorkRate = "", --L"TXT_KEY_WORKERACTION_TEXT" L"TXT_KEY_MISSION_BUILD_IMPROVEMENT" L"TXT_KEY_MISSION_CONSTRUCT"
		NumFreeTechs = L"TXT_KEY_MISSION_DISCOVER_TECH" .. " (%i)",
		BaseBeakersTurnsToCount = L"TXT_KEY_MISSION_DISCOVER_TECH" .. " (%i " .. L"TXT_KEY_TURNS"..")", -- Scientist
		BaseCultureTurnsToCount = L"TXT_KEY_MISSION_GIVE_POLICIES" .. " (%i " .. L"TXT_KEY_TURNS"..")",	-- Writer
	--y	BaseHurry = "",
	--y	HurryMultiplier = "",
	--y	BaseGold = L"TXT_KEY_MISSION_CONDUCT_TRADE_MISSION" .. " %i[ICON_INFLUENCE] %i" .. g_currencyIcon, -- base gold provided by great merchand
	--y	NumGoldPerEra = "", -- gold increment
		ReligionSpreads = L"TXT_KEY_UPANEL_SPREAD_RELIGION_USES" .. ": %i",
		ReligiousStrength = L"TXT_KEY_REL_STR" .. " %i", -- TODO
	--n	CombatLimit = "",
		NumExoticGoods = L"TXT_KEY_MISSION_SELL_EXOTIC_GOODS" .. ": %i",
	--n	RangedCombatLimit = "",
	--n	XPValueAttack = "",
	--n	XPValueDefense = "",
	--n	Conscription = "",
		ExtraMaintenanceCost = L"TXT_KEY_PEDIA_MAINT_LABEL" .. " -%i" .. g_currencyIcon,
	--u	Unhappiness = L"2": %i[ICON_HAPPINESS_3]",
	--n	LeaderExperience = "", --unused
	--n	UnitFlagIconOffset = "",
	--n	PortraitIndex = "",
	}
	
	for k,v in pairs( unit ) do
		if v and v ~= 0 and v~=-1 then
			tip = unitFlag[k]
			if tip then
				insert( tips, "[ICON_BULLET]" .. tip )
			else
			    tip = unitData[k]
			    v = tonumber(v) or 0
			    if tip and v > 0 then
				if #tip == 0 then
					tip = k .. " %i"
				end
				insert( tips, "[ICON_BULLET]" .. format( tip, v ) )
			    end
			end
		end
	end
	-- Technology_DomainExtraMoves
	for row in GameInfo.Technology_DomainExtraMoves{ DomainType = unitDomainType } do
		item = GameInfo.Technologies[ row.TechType ]
		if item and (row.Moves or 0)~=0 then
			insert( tips, format( "[ICON_BULLET]%s %+i[ICON_MOVES]", TechColor( L(item.Description) ), row.Moves ) )
		end
	end
--TODO Technology_TradeRouteDomainExtraRange

	-- Ability to generate tourism upon spawn
	if IsCiv5BNW then
		for row in GameInfo.Policy_TourismOnUnitCreation( thisUnitClass ) do
			item = GameInfo.Policies[ row.PolicyType ]
			if item and (row.Tourism or 0)~=0 then
				insert( tips, format( "[ICON_BULLET]%s %+i[ICON_TOURISM]", PolicyColor( L(item.Description) ), row.Tourism ) )
			end
		end
	end

	-- Resources required:
	if Game then
		for resource in GameInfo.Resources() do
			item = Game.GetNumResourceRequiredForUnit( unitID, resource.ID )
			if resource and item ~= 0 then
				insert( tips, ResourceQuantity( resource, -item ) )
			end
		end
	else
		for row in GameInfo.Unit_ResourceQuantityRequirements( thisUnitType ) do
			resource = GameInfo.Resources[ row.ResourceType ]
			if resource and (row.Cost or 0)~=0 then
				insert( tips, ResourceQuantity( resource, -row.Cost ) )
			end
		end
	end

	insert( tips, "----------------" )

	-- Cost:
	local costTip
	if productionCost > 1 then -- Production cost
		if not unit.PurchaseOnly then
			costTip = productionCost .. "[ICON_PRODUCTION]"
		end
		local goldCost = 0
		if city then
			goldCost = city:GetUnitPurchaseCost( unitID )
		elseif (unit.HurryCostModifier or 0) > 0 then
			goldCost = (productionCost * GameDefines.GOLD_PURCHASE_GOLD_PER_PRODUCTION ) ^ GameDefines.HURRY_GOLD_PRODUCTION_EXPONENT
			goldCost = (unit.HurryCostModifier + 100) * goldCost / 100
			goldCost = goldCost - ( goldCost % GameDefines.GOLD_PURCHASE_VISIBLE_DIVISOR )
		end
		if goldCost > 0 then
			if costTip then
				costTip = costTip .. ("(%i%%)"):format(productionCost*100/goldCost)
				if IsCiv5Vanilla then
					costTip = costTip .. " / " .. goldCost .. g_currencyIcon
				else
					costTip = L("TXT_KEY_PEDIA_A_OR_B", costTip, goldCost .. g_currencyIcon )
				end
			else
				costTip = goldCost .. g_currencyIcon
			end
		end
	end -- production cost
	if g_isReligionEnabled then -- Faith cost
		local faithCost = 0
		if city then
			faithCost = city:GetUnitFaithPurchaseCost( unitID, true )
		elseif Game then
			faithCost = Game.GetFaithCost( unitID )
		elseif unit.RequiresFaithPurchaseEnabled and unit.FaithCost then
			faithCost = unit.FaithCost
		end
		if ( faithCost or 0 ) > 0 then
			if costTip then
				costTip = L("TXT_KEY_PEDIA_A_OR_B", costTip, faithCost .. "[ICON_PEACE]" )
			else
				costTip = faithCost .. "[ICON_PEACE]"
			end
		end
	end --faith cost
	if costTip then
		insert( tips, L"TXT_KEY_PEDIA_COST_LABEL" .. " " .. ( costTip or L"TXT_KEY_FREE" ) )
	end

	-- build using food / stop city growth
	if unit.Food then
		insert( tips, L"TXT_KEY_CITYVIEW_STAGNATION_TEXT" .. " (" .. L"TXT_KEY_POPULATION_SUPPLY" .. ")" )
	end
	-- Settler Specifics
	if unit.Found or unit.FoundAbroad then
		append( tips, L("TXT_KEY_NO_ACTION_SETTLER_SIZE_LIMIT", GameDefines.CITY_MIN_SIZE_FOR_SETTLERS) )
	end

	-- Civilization:
	local civs = {}
	for requiredCivilizationType in GameInfo.Civilization_UnitClassOverrides( thisUnitType ) do
		item = GameInfo.Civilizations[ requiredCivilizationType.CivilizationType ]
		if item then
			insert( civs, L(item.ShortDescription) )
		end
	end
	if #civs > 0 then
		insert( tips, L"TXT_KEY_PEDIA_CIVILIZATIONS_LABEL".." "..concat( civs, ", ") )
	end

	-- Replaces:
	item = unitClass and GameInfo.Units[ unitClass.DefaultUnit ]
	if item and item ~= unit then
		insert( tips, L"TXT_KEY_PEDIA_REPLACES_LABEL".." "..format( "%s %s", ( item.Special and item.Special == "SPECIALUNIT_PEOPLE" and GreatPeopleIcon( item.Type ) or "" ), UnitColor( L(item.Description) ) ) )--!!! row
	end

	-- Required Policies:
	item = unit.PolicyType and GameInfo.Policies[ unit.PolicyType ]
	if unit.PolicyType then
		insert( tips, L"TXT_KEY_PEDIA_PREREQ_POLICY_LABEL" .. " " .. PolicyColor( L(item.Description) ) )
	end

	-- Required Buildings:
	local buildings = {}
	for row in GameInfo.Unit_BuildingClassRequireds( thisUnitType ) do
		item = GetCivBuilding( activeCivilizationType, row.BuildingClassType )
		if item then
			insert( buildings, BuildingColor( L(item.Description) ) )
		end
	end
	item = unit.ProjectPrereq and GameInfo.Projects[ unit.ProjectPrereq ]
	if unit.ProjectPrereq then
		insert( buildings, BuildingColor( L(item.Description) ) )
	end
	if #buildings > 0 then
		insert( tips, L"TXT_KEY_PEDIA_REQ_BLDG_LABEL" .. " " .. concat( buildings, ", ") ) -- TXT_KEY_NO_ACTION_UNIT_REQUIRES_BUILDING
	end

	-- Prerequisite Techs:
	item = unit.PrereqTech and GameInfo.Technologies[ unit.PrereqTech ]
	if item and item.ID > 0 then
		insert( tips, L"TXT_KEY_PEDIA_PREREQ_TECH_LABEL" .. " " .. TechColor( L(item.Description) ) )
	end

	-- Upgrade from:
	local unitClassUpgrades = {}
	for unitUpgrade in GameInfo.Unit_ClassUpgrades( thisUnitClass ) do
		unitUpgrade = GameInfo.Units[ unitUpgrade.UnitType ]
		SetKey( unitClassUpgrades, unitUpgrade and unitUpgrade.Class )
	end
	local unitUpgrades = {}
	for unitToUpgrade in pairs( unitClassUpgrades ) do
		item = GetCivUnit( activeCivilizationType, unitToUpgrade )
		if item then
			insert( unitUpgrades, format( "%s %s", ( item.Special and item.Special == "SPECIALUNIT_PEOPLE" and GreatPeopleIcon( item.Type ) or "" ), UnitColor( L(item.Description) ) ) .. " ("..unitUpgradePrice( item, unit, activePlayer and activePlayer:GetUnitProductionNeeded( item.ID ), productionCost )..g_currencyIcon..")" )
		end
	end
	if #unitUpgrades > 0 then
		insert( tips, L"TXT_KEY_GOLD_UPGRADE_UNITS_HEADING3_TITLE" .. ": " .. concat( unitUpgrades, ", ") )
	end

	-- Becomes Obsolete with:
	item = unit.ObsoleteTech and GameInfo.Technologies[ unit.ObsoleteTech ]
	if item then
		insert( tips, L"TXT_KEY_PEDIA_OBSOLETE_TECH_LABEL" .. " " .. TechColor( L(item.Description) ) )
	end

	-- Upgrade unit
	if Game then
		local item = Game.GetUnitUpgradesTo( unit.ID )
		item = item and GameInfo.Units[ Game.GetUnitUpgradesTo( unit.ID ) ]
		if item and activeCivilizationType then
			item = GetCivUnit( activeCivilizationType, item.Class )
			insert( tips, L"TXT_KEY_COMMAND_UPGRADE" .. ": " .. format( "%s %s", ( item.Special and item.Special == "SPECIALUNIT_PEOPLE" and GreatPeopleIcon( item.Type ) or "" ), UnitColor( L(item.Description) ) ) .. " ("..unitUpgradePrice( unit, item, productionCost, activePlayer:GetUnitProductionNeeded( item.ID ) )..g_currencyIcon..")" )
		end
	else
		local unitClassUpgrades = {}
		for unitClassUpgrade in GameInfo.Unit_ClassUpgrades( thisUnitType ) do
			SetKey( unitClassUpgrades, unitClassUpgrade.UnitClassType )
		end
		local unitUpgrades = {}
		for unitUpgrade in pairs( unitClassUpgrades ) do
			item = GetCivUnit( activeCivilizationType, unitUpgrade )
			if item then
				insert( unitUpgrades, UnitColor( L(item.Description) ) .. " ("..unitUpgradePrice( unit, item, productionCost )..g_currencyIcon..")" )
			end
		end
		if #unitUpgrades > 0 then
			insert( tips, L"TXT_KEY_COMMAND_UPGRADE" .. ": " .. concat( unitUpgrades, ", ") )
		end
	end

	-- Built <> Buiding Class Count
	local countText = {};
	if activePlayer then
	    if activePlayer:GetUnitClassCount( unitClassID ) == 0 and activePlayer:GetUnitClassMaking( unitClassID ) == 0 then
	    else
		if activePlayer:GetUnitClassCount( unitClassID ) > 0 then
			insert( countText, "[NEWLINE]" .. L( "TXT_KEY_ACTION_CLASS_BUILT_COUNT", activePlayer:GetUnitClassCount( unitClassID ) ) );
			if activePlayer:GetUnitClassMaking( unitClassID ) > 0 then
				append( countText, " <> "  .. L( "TXT_KEY_ACTION_CLASS_BUILDING_COUNT", activePlayer:GetUnitClassMaking( unitClassID ) ) );
			end
		else
			insert( countText, "[NEWLINE]" .. L( "TXT_KEY_ACTION_CLASS_BUILDING_COUNT", activePlayer:GetUnitClassMaking( unitClassID ) ) );
		end
	    end
	end
	if #countText > 0 then
		insert( tips, concat( countText, "") );
	end

	-- Limited number can be built
	if #countText == 0 and (maxGlobalInstances > 0 or maxTeamInstances > 0 or maxPlayerInstances > 0) then
		append( tips, "[NEWLINE]" );
	end
	if maxGlobalInstances > 0 then
		append( tips, "[COLOR_YELLOW]" .. L( "TXT_KEY_NO_ACTION_GAME_COUNT_MAX", maxGlobalInstances ) .. "[ENDCOLOR]" );
	end
	if maxTeamInstances > 0 then
		append( tips, "[COLOR_YELLOW]" .. L( "TXT_KEY_NO_ACTION_TEAM_COUNT_MAX", maxTeamInstances ) .. "[ENDCOLOR]" );
	end
	if maxPlayerInstances > 0 then
		append( tips, "[COLOR_YELLOW]" .. L( "TXT_KEY_NO_ACTION_PLAYER_COUNT_MAX", maxPlayerInstances ) .. "[ENDCOLOR]" );
	end

	-- Pre-written Help text
	return AddPreWrittenHelpTextAndConcat( tips, unit )
end


-------------------------------------------------
-- Help text for Buildings
-------------------------------------------------

local g_gameAvailableBeliefs = Game and { Game.GetAvailablePantheonBeliefs, Game.GetAvailableFounderBeliefs, Game.GetAvailableFollowerBeliefs, Game.GetAvailableFollowerBeliefs, Game.GetAvailableEnhancerBeliefs, Game.GetAvailableBonusBeliefs }

-------------------------------------------------
-- Helper function to build religion tooltip string
-------------------------------------------------
local function GetSpecialistSlotsTooltip( specialistType, numSlots )
	local tip = ""
	for row in GameInfo.SpecialistYields{ SpecialistType = specialistType } do
		tip = format( "%s %+i%s", tip, row.Yield, YieldIcons[ row.YieldType ] or "?" )
	end
	local row = GameInfo.Specialists[ specialistType ]
	return format( "%i %s%s", numSlots, row and L(row.Description or "???"), tip )
end

local function GetSpecialistYields( city, specialist )
	local specialistID = specialist.ID
	local tip = ""
	if city then
		-- Culture
		local cultureFromSpecialist = city:GetCultureFromSpecialist( specialistID )
		-- Yield
		for yieldID = 0, YieldTypes.NUM_YIELD_TYPES-1 do
			local specialistYield = city:GetSpecialistYield( specialistID, yieldID )
			if specialistYield ~= 0 then
				tip = format( "%s %+i%s", tip, specialistYield, YieldIcons[ yieldID ] or "?" )
				if yieldID == YieldTypes.YIELD_CULTURE then
					cultureFromSpecialist = 0
				end
			end
		end
		if cultureFromSpecialist > 0 then
			tip = format( "%s %+i[ICON_CULTURE]", tip, cultureFromSpecialist )
		end
	else
		for row in GameInfo.SpecialistYields{ SpecialistType = specialist.Type or -1 } do
			tip = format( "%s %+i%s", tip, row.Yield, YieldIcons[ row.YieldType ] or "?" )
		end
	end
	if IsCiv5 and (specialist.GreatPeopleRateChange or 0) > 0 then
		tip = format( "%s %+i%s", tip, specialist.GreatPeopleRateChange, GreatPeopleIcon( specialist.Type ) )
	end
	return tip
end

function GetHelpTextForBuilding( buildingID, bExcludeName, bExcludeHeader, bNoMaintenance, city )
	local building = GameInfo.Buildings[ buildingID ]
	if not building then
		return "<Building undefined in game database>"
	end
	local buildingType = building.Type or -1
	local buildingClassType = building.BuildingClass
	local buildingClass = GameInfo.BuildingClasses[ buildingClassType ]
	local buildingClassID = buildingClass and buildingClass.ID
	local maxGlobalInstances = buildingClass and tonumber(buildingClass.MaxGlobalInstances) or -1
	local maxTeamInstances = buildingClass and tonumber(buildingClass.MaxTeamInstances) or -1
	local maxPlayerInstances = buildingClass and tonumber(buildingClass.MaxPlayerInstances) or -1
	local thisBuildingType = { BuildingType = buildingType }
	local thisBuildingAndResourceTypes =  { BuildingType = buildingType }
	local thisBuildingClassType = { BuildingClassType = buildingClassType }
	local tip, tips, items, item, yieldID, yieldChange, yieldModifier, yieldPerPop,yieldPerPopGlobal, yieldPerReligion, tradeRouteSeaGoldBonus, tradeRouteLandGoldBonus, resource, tradeRouteSeaGoldBonusGlobal, tradeRouteLandGoldBonusGlobal

	if g_isReligionEnabled and activePlayer then
		local religionID = activePlayer:GetReligionCreatedByPlayer()
		if religionID > 0 then
			activePlayerBeliefs = Game.GetBeliefsInReligion( religionID )
		elseif activePlayer:HasCreatedPantheon() then
			activePlayerBeliefs = { activePlayer:GetBeliefInPantheon() }
		end

		for i = 1, activePlayer:IsTraitBonusReligiousBelief() and 6 or 5 do
			if (activePlayerBeliefs[i] or -1) < 0 then -- active player does not already have a belief in "i" belief class
				for _,beliefID in pairs( g_gameAvailableBeliefs[i]() ) do
					availableBeliefs[beliefID] = true -- because available to active player in "i" belief class
				end
			end
		end
	end
	------------------
	-- Tech Filter
	local function techFilter( row )
		return row and g_isScienceEnabled and ( not activeTeamTechs or not activeTeamTechs:HasTech( row.ID ) )
	end

	------------------
	-- Policy Filter
	local function policyFilter( row )
		return row and g_isPoliciesEnabled
			and not( activePlayer and activePlayer:HasPolicy( row.ID ) and not activePlayer:IsPolicyBlocked( row.ID ) )
			and not( activePlayerIdeologyType and activePlayerIdeologyType ~= row.PolicyBranchType )
	end

	------------------
	-- Belief Filter
	local function beliefFilter( row )
		return row and g_isReligionEnabled and ( not activePlayer or availableBeliefs[ row.ID ] )
	end


	local productionCost = tonumber(building.Cost) or 0
	local maintenanceCost = tonumber(building[g_maintenanceCurrency]) or 0
	local happinessChange = (tonumber(building.Happiness) or 0)
	local defenseChange = tonumber(building.Defense) or 0
	local hitPointChange = tonumber(building.ExtraCityHitPoints) or 0
	local cultureChange = IsCiv5Vanilla and tonumber(building.Culture) or 0
	local cultureModifier = tonumber(building.CultureRateModifier) or 0

	local enhancedYieldTech = building.EnhancedYieldTech and GameInfo.Technologies[ building.EnhancedYieldTech ]
	local enhancedYieldTechName = enhancedYieldTech and TechColor( L(enhancedYieldTech.Description) )

	if activePlayer then
		-- Not in CityView, Don't need to get the value of 'city' !
		-- city =  city or GetHeadSelectedCity()
		-- city = (city and city:GetOwner() == activePlayerID and city) or activePlayer:GetCapitalCity() or activePlayer:Cities()(activePlayer)

		-- player production cost
		productionCost = activePlayer:GetBuildingProductionNeeded( buildingID )
		if IsCiv5 then
			-- player extra happiness
			happinessChange = happinessChange + activePlayer:GetExtraBuildingHappinessFromPolicies( buildingID )
			if not IsCiv5Vanilla then
				happinessChange = happinessChange + activePlayer:GetPlayerBuildingClassHappiness( buildingClassID )
			end
		else
			-- get the active perk types
			activePerkTypes = activePlayer:GetAllActivePlayerPerkTypes()
		end
	end

	if city and not IsCiv5Vanilla and buildingClassID then
		happinessChange = happinessChange + city:GetReligionBuildingClassHappiness(buildingClassID)
	end

	-- Name
	tips = { BuildingColor( Locale_ToUpper( building.Description or "???" ) ) }
	
	insert( tips, "----------------" )

	-- Other tags
	local buildingFlag = {
	--y	Water = L"TXT_KEY_TERRAIN_COAST",
		TeamShare = L"TXT_KEY_POP_UN_TEAM",
	--y	River = L"TXT_KEY_PLOTROLL_RIVER",
		FreshWater = L"TXT_KEY_ABLTY_FRESH_WATER_STRING",
	--y	Mountain = L"TXT_KEY_TERRAIN_MOUNTAIN" .. "[ICON_RANGE_STRENGTH]1",
	--y	NearbyMountainRequired = L"TXT_KEY_TERRAIN_MOUNTAIN" .. "[ICON_RANGE_STRENGTH]2",
	--y	Hill = L"TXT_KEY_TERRAIN_HILL",
	--y	Flat = L"TXT_KEY_MAP_OPTION_FLAT",
		FoundsReligion = "[ICON_RELIGION]" .. L"TXT_KEY_MISSION_FOUND_RELIGION",
	--u	IsReligious = "",
		BorderObstacle = "[ICON_PROMOTION_VOLLEY]" .. L"TXT_KEY_BO1",		-- TODO
		PlayerBorderObstacle = "[ICON_PROMOTION_VOLLEY]" .. L"TXT_KEY_BO1".."*",-- TODO
		Capital = "[ICON_CAPITAL]" .. L"TXT_KEY_CAPITAL1",
		GoldenAge = "[ICON_GOLDEN_AGE]" .. L"TXT_KEY_MISSION_START_GOLDENAGE",
	--	MapCentering = L"TXT_KEY_MC1",						-- TODO
	--n	NeverCapture = "",
	--n	NukeImmune = "",
		AllowsWaterRoutes = "[ICON_TRADE_WHITE][ICON_PROMOTION_AMPHIBIOUS]" .. L"TXT_KEY_BUILDING_HARBOR",-- TODO
		ExtraLuxuries = L"TXT_KEY_EL1",						-- TODO
		DiplomaticVoting = "[ICON_DIPLOMAT]"..L"TXT_KEY_VICTORY_ECONOMIC_BANG",	-- TODO
		AffectSpiesNow = L"TXT_KEY_ASN1",					-- TODO
		NullifyInfluenceModifier = L"TXT_KEY_NIM1",				-- TODO
	--y	UnlockedByBelief = "",
	--y	UnlockedByLeague = "",
		HolyCity = "[ICON_RELIGION]" .. L"TXT_KEY_RO_WR_HOLY_CITY",
		Airlift = "[ICON_PROMOTION_EXTENDED_PARADROP]" .. L"TXT_KEY_MISSION_AIRLIFT",
		NoOccupiedUnhappiness = "[ICON_HAPPINESS_1]" .. L"TXT_KEY_BUILDING_COURTHOUSE_HELP",
		AllowsRangeStrike = "[ICON_RANGE_STRENGTH]" .. L"TXT_KEY_ARS1",
	--n	Espionage = L"TXT_KEY_GAME_CONCEPT_SECTION_22",
		AllowsFoodTradeRoutes = "[ICON_INTERNATIONAL_TRADE][ICON_FOOD]" .. L"TXT_KEY_TRADE_ROUTES_HEADING2_TITLE", --TXT_KEY_DECLARE_WAR_TRADE_ROUTES_HEADER
		AllowsProductionTradeRoutes = "[ICON_INTERNATIONAL_TRADE][ICON_PRODUCTION]" .. L"TXT_KEY_TRADE_ROUTES_HEADING2_TITLE", --TXT_KEY_DECLARE_WAR_TRADE_ROUTES_HEADER
		InstantMilitaryIncrease = L"TXT_KEY_IMI11",				-- TOTO
	--n	CityWall = "",
	--n	ArtInfoCulturalVariation = "",
	--n	ArtInfoEraVariation = "",
	--n	ArtInfoRandomVariation = "",
	}
	local buildingData = {
	--y	Cost = L("TXT_KEY_PEDIA_COST_LABEL") .. " %i[ICON_PRODUCTION]", -- production cost
	--y	GoldMaintenance = L("TXT_KEY_PEDIA_MAINT_LABEL") .. " %i"..g_currencyIcon, -- maintenance
	--y	MutuallyExclusiveGroup = "",						-- TOTO
	--y	FaithCost = "",
	--u	LeagueCost = "",
	--n	NumCityCostMod = "",
	--y	HurryCostModifier = "",
	--n	MinAreaSize = "",
	--n	ConquestProb = "",
	--	CitiesPrereq = L"TXT_KEY_CP1",						-- TOTO
	--	LevelPrereq = L"TXT_KEY_LP1",						-- TOTO
	--y	CultureRateModifier = "",
		GlobalCultureRateModifier = L"TXT_KEY_GLOBAL1" .. L"TXT_KEY_CRM1" .. "%+i%%[ICON_CULTURE]",-- TOTO
		GreatPeopleRateModifier = L"TXT_KEY_GPRM1" .. "%+i%%[ICON_GREAT_PEOPLE]",-- TOTO
		GlobalGreatPeopleRateModifier = L"TXT_KEY_GLOBAL1" .. L"TXT_KEY_GPRM1" .. "%+i%%[ICON_GREAT_PEOPLE]",-- TOTO
		GreatGeneralRateModifier = L"TXT_KEY_GGRM2" .. "%+i%%[ICON_GREAT_GENERAL]",-- TOTO
		GreatPersonExpendGold = L"TXT_KEY_GPEG1" .. "%+i[ICON_GOLD]",		-- TOTO
		GoldenAgeModifier = L"TXT_KEY_REPLAY_DATA_GOLDAGETURNS" .. ":" .. "%+i%% ",
		UnitUpgradeCostMod = L"TXT_KEY_UUCM1" .. "%+i%%[ICON_GOLD]",		-- TOTO
		Experience = L("TXT_KEY_EXPERIENCE_POPUP", "%i"),			-- TOTO
		GlobalExperience = L"TXT_KEY_GLOBAL1" .. L("TXT_KEY_EXPERIENCE_POPUP", "%i"),-- TOTO
		FoodKept = "%+i%%[ICON_FOOD] " .. L"TXT_KEY_TRAIT_POPULATION_GROWTH_SHORT",-- granary effect
		AirModifier = L"TXT_KEY_AIR_MODIFIER11" .. "%+i[ICON_PROMOTION_SPACE_ELEVATOR]",-- TOTO
		NukeModifier = L"TXT_KEY_NUKE_MODIFIER11" .. "%i%%",			-- TOTO
		NukeInterceptionChance = L"TXT_KEY_NUKE_INTERCEPTION11_SP" .. "%i%%",			-- TOTO
		ExtraAttacks = L"TXT_KEY_CITY_ATTACK_CHANGE_SP" .. "%+i",			-- TOTO
		RangedStrikeModifier = L"TXT_KEY_CITY_RANGED_ATTACK_MOD_SP" .. "%i%%",			-- TOTO

		GlobalCityStrengthMod = L"TXT_KEY_GLOBAL_CITY_STRENGTH_MOD_SP" .. "%i%%",			-- TOTO
		GlobalRangedStrikeModifier = L"TXT_KEY_GLOBAL_CITY_RANGED_ATTACK_MOD_SP" .. "%i%%",			-- TOTO
	--	NukeExplosionRand = L"TXT_KEY_NUKE_EXPLOSION_RAND111",			-- TOTO
	--	HealRateChange = L"TXT_KEY_HEAL_RATE_CHANGE111",			-- TOTO
	--y	Happiness = "",
		UnmoddedHappiness = L"TXT_KEY_UH11" .. "%+i[ICON_HAPPINESS_1]",
		UnhappinessModifier = L"TXT_KEY_UNHAPPINESS_MODIFIER111" .. "%+i%%",	-- TOTO
		HappinessPerCity = L"TXT_KEY_HAPPINESS_PERCITY111" .. "%+i[ICON_HAPPINESS_1]",-- TOTO
	--y	HappinessPerXPolicies = "",
	--	CityCountUnhappinessMod = L"TXT_KEY_CITY_COUNT_UNHAPPINESS_MOD111",	-- TOTO
		WorkerSpeedModifier = L"TXT_KEY_WORKER_SPEED_MODIFIER111" .. "%+i%%",	-- TOTO
		MilitaryProductionModifier = L"TXT_KEY_MILITARY_PRODUCTION_MODIFIER111" .. "%+i%%[ICON_PRODUCTION]",-- TOTO
		SpaceProductionModifier = L"TXT_KEY_SPACE_PRODUCTION_MODIFIER11" .. "%+i%%[ICON_PRODUCTION]",	-- TOTO
		GlobalSpaceProductionModifier = L"TXT_KEY_GLOBAL1" .. L"TXT_KEY_SPACE_PRODUCTION_MODIFIER11" .. "%+i%%[ICON_PRODUCTION]",-- TOTO
		BuildingProductionModifier = L"TXT_KEY_SV_ICONS_LOCAL_SP" .. L"TXT_KEY_BUILDING_PRODUCTION_MODIFIER11" .. "%+i%%[ICON_PRODUCTION]",	-- TOTO
		WonderProductionModifier = L"TXT_KEY_WONDER_PRODUCTION_MODIFIER111" .. "%+i%%[ICON_PRODUCTION]",	-- TOTO
		CityConnectionTradeRouteModifier = L"TXT_KEY_CCTRM22" .. "%+i%%[ICON_GOLD]",-- TOTO
		CapturePlunderModifier = L"TXT_KEY_CPM3" .. "%+i%%[ICON_GOLD]",		-- TOTO
		PolicyCostModifier = L"TXT_KEY_PCM22" .. "%+i%%[ICON_CULTURE]",		-- TOTO
		PlotCultureCostModifier = L"TXT_KEY_PCCM4" .. "%+i%%[ICON_CULTURE]",	-- TOTO
		GlobalPlotCultureCostModifier = L"TXT_KEY_GLOBAL1" .. L"TXT_KEY_PCCM4" .. "%+i%%[ICON_CULTURE]",-- TOTO
		PlotBuyCostModifier = L"TXT_KEY_PBCM5" .. "%+i%%[ICON_GOLD]",		-- TOTO
		GlobalPlotBuyCostModifier = L"TXT_KEY_GLOBAL1" .. L"TXT_KEY_PBCM5" .. "%+i%%[ICON_GOLD]",-- TOTO
		GlobalPopulationChange = L"TXT_KEY_GLOBAL1" .. "%+i[ICON_CITIZEN]" .. L"TXT_KEY_POPULATION_SUPPLY",-- TOTO
		PopulationChange = L"TXT_KEY_LOCAL_POP_SP" .. "%+i[ICON_CITIZEN]" .. L"TXT_KEY_POPULATION_SUPPLY",-- TOTO
	--	TechShare = L"TXT_KEY_TS_1",						-- TOTO
		FreeTechs = L"TXT_KEY_FREE_TECHS" .. "%i",				-- TOTO
		FreePolicies = L"TXT_KEY_FREE_POLICIES" .. "%i",			-- TOTO
		FreeGreatPeople = L"TXT_KEY_GP111" .. "%i",				-- TOTO
		MedianTechPercentChange = L"TXT_KEY_MTPC_444" .. "2*%+i%%[ICON_RESEARCH]",-- TOTO
		Gold = L"TXT_KEY_PEDIA_GOLD_LABEL" .. " %i",				-- TOTO
	--y	Defense = "",
	--y	ExtraCityHitPoints = "",
		GlobalDefenseMod = L"TXT_KEY_GLOBAL1" .. L"TXT_KEY_DM_0" .. "%+i%%[ICON_STRENGTH]",-- TOTO
		MinorFriendshipChange = L"TXT_KEY_MFC_23" .. "%+i%%",			-- TOTO
	--	VictoryPoints = L"TXT_KEY_VP_00",					-- TOTO
		ExtraMissionarySpreads = L"TXT_KEY_EMS_5" .. " %+i".."[ICON_MISSIONARY]",-- TOTO
		ReligiousPressureModifier = L"TXT_KEY_RPM_10" .. "%+i%%",		-- TOTO
		EspionageModifier = L"TXT_KEY_EM561" .. "%+i%%",			-- TOTO
		GlobalEspionageModifier = L"TXT_KEY_GLOBAL1" .. L"TXT_KEY_EM561" .. "%+i%%",-- TOTO
		ExtraSpies = L"TXT_KEY_ES123123" .. " %+i" .. "[ICON_SPY]",		-- TOTO
		SpyRankChange = L"TXT_KEY_SC_10" .. "[ICON_SPY]" .. "^%i",		-- TOTO
		InstantSpyRankChange = L"TXT_KEY_ISC_10" .. "[ICON_SPY]" .. "^%i",	-- TOTO
		TradeRouteRecipientBonus = "[ICON_INTERNATIONAL_TRADE]" .. L"TXT_KEY_TRADE_TO_OTHER_CITY_BONUS" .. " %+i"..g_currencyIcon.."[ICON_ARROW_LEFT]",
		TradeRouteTargetBonus = "[ICON_INTERNATIONAL_TRADE]" .. L"TXT_KEY_TRADE_TO_OTHER_CITY_BONUS" .. " %+i"..g_currencyIcon.."[ICON_ARROW_RIGHT]",
		NumTradeRouteBonus = "%+i[ICON_INTERNATIONAL_TRADE]" .. L"TXT_KEY_DECLARE_WAR_TRADE_ROUTES_HEADER",
		LandmarksTourismPercent = L"TXT_KEY_LTP11" .. "%i%%[ICON_TOURISM]",	-- TOTO
		LandmarksTourismPercentGlobal = L"TXT_KEY_GLOBAL1" .. L"TXT_KEY_LTP11" .. "%i%%[ICON_TOURISM]",	-- TOTO
		GreatWorksTourismModifier = L"TXT_KEY_GWTM111" .. "%+i%%[ICON_TOURISM]",-- TOTO
		GreatWorksTourismModifierGlobal = L"TXT_KEY_GLOBAL1" .. L"TXT_KEY_GWTM111" .. "%+i%%[ICON_TOURISM]",-- TOTO
		XBuiltTriggersIdeologyChoice = L("TXT_KEY_XBTIC1", "%i"),			-- TOTO
		TradeRouteSeaDistanceModifier = L"TXT_KEY_TSDM1" .. "%+i%%",
	--y	TradeRouteSeaGoldBonus = L"TXT_KEY_TRSGB1" .. "%+i%%[ICON_GOLD]",	-- TOTO
		TradeRouteLandDistanceModifier = L"TXT_KEY_TRLDM1" .. "%+i%%",		-- TOTO
	--y	TradeRouteLandGoldBonus = L"TXT_KEY_TRLGB1" .. "%+i%%[ICON_GOLD]",	-- TOTO 
		CityStateTradeRouteProductionModifier = L"TXT_KEY_CSTRPM1111" .. "%+i%%[ICON_PRODUCTION]",-- TOTO
		CityStateTradeRouteProductionModifierGlobal = L"TXT_KEY_CSTRPMG" .. "%+i%%[ICON_PRODUCTION]",-- TOTO
		GreatScientistBeakerModifier = L"TXT_KEY_GSBM4" .. "%+i%%[ICON_RESEARCH]",-- TOTO
	--y	TechEnhancedTourism = "",
	--y	SpecialistCount = "",
	--y	GreatWorkCount = "",
	--	SpecialistExtraCulture = L"TXT_KEY_SEC444",				-- TOTO
	--y	GreatPeopleRateChange = "",
		ExtraLeagueVotes = L"TXT_KEY_ELV3434" .. "%i",				-- TOTO
	}
	
	for k,v in pairs( building ) do
		if v and v ~= 0 then
			tip = buildingFlag[k]
			if tip then
				if #tip == 0 then
					tip = k
				end
				insert( tips, tip )
			else
			    tip = buildingData[k]
			    v = tonumber(v) or 0
			    if tip then
				insert( tips, format( tip, v ) )
			    end
			end
		end
	end

--local function GetBuildingYields( buildingID, buildingType, buildingClassID, activePlayer )
	-- Yields
	local thisBuildingAndYieldTypes = { BuildingType = buildingType }
	for yield in GameInfo.Yields() do
		yieldID = yield.ID
		yieldChange = 0
		yieldModifier = 0
		thisBuildingAndYieldTypes.YieldType = yield.Type

		if Game and buildingClassID and yieldID < YieldTypes.NUM_YIELD_TYPES then -- weed out strange Communitas yields
			yieldChange = Game.GetBuildingYieldChange( buildingID, yieldID )
			yieldModifier = Game.GetBuildingYieldModifier( buildingID, yieldID )
			if activePlayer then
				if not IsCiv5Vanilla then
					yieldChange = yieldChange + activePlayer:GetPlayerBuildingClassYieldChange( buildingClassID, yieldID )
								+ activePlayer:GetPolicyBuildingClassYieldChange( buildingClassID, yieldID )
				end
				yieldModifier = yieldModifier + activePlayer:GetPolicyBuildingClassYieldModifier( buildingClassID, yieldID )
				for i = 1, #activePerkTypes do
					yieldChange = yieldChange + Game.GetPlayerPerkBuildingClassFlatYieldChange( activePerkTypes[i], buildingClassID, yieldID )
					yieldModifier = yieldModifier + Game.GetPlayerPerkBuildingClassPercentYieldChange( activePerkTypes[i], buildingClassID, yieldID )
				end
			end
			if city and not IsCiv5Vanilla then
				yieldChange = yieldChange + city:GetReligionBuildingClassYieldChange( buildingClassID, yieldID )
				if IsCiv5BNW then
					yieldChange = yieldChange + city:GetLeagueBuildingClassYieldChange( buildingClassID, yieldID )
				end
			end
		else -- not Game
			for row in GameInfo.Building_YieldChanges( thisBuildingAndYieldTypes ) do
				yieldChange = yieldChange + (row.Yield or 0)
			end
			for row in GameInfo.Building_YieldModifiers( thisBuildingAndYieldTypes ) do
				yieldModifier = yieldModifier + (row.Yield or 0)
			end
		end
		if yield.Type == "YIELD_CULTURE" then -- works pregame, when GameInfoTypes is not available
			yieldChange = yieldChange + cultureChange
			yieldModifier = yieldModifier + cultureModifier
			cultureChange = 0
			cultureModifier = 0
		end


		yieldPerPop = 0
		for row in GameInfo.Building_YieldChangesPerPop( thisBuildingAndYieldTypes ) do
			yieldPerPop = yieldPerPop + (row.Yield or 0)/100
		end

		---------------------------------New--------------------------------------------
		yieldPerPopGlobal = 0
		for row in GameInfo.Building_YieldChangesPerPopInEmpire( thisBuildingAndYieldTypes ) do
			yieldPerPopGlobal = yieldPerPopGlobal + (row.Yield or 0)/100
		end
		---------------------------------New--------------------------------------------

		yieldPerReligion = 0
		if IsCiv5BNW then
			for row in GameInfo.Building_YieldChangesPerReligion( thisBuildingAndYieldTypes ) do
				yieldPerReligion = yieldPerReligion + (row.Yield or 0)/100
			end
		end
		if yieldChange ~= 0 then
			tip = format("%+i%s", yieldChange, yield.IconString or "?" )
		else
			tip = ""
		end


		if yieldModifier ~= 0 then
			if tip ~= "" then
				tip = format("%s, ", tip )
			end
			tip = format("%s%+i%%%s", tip, yieldModifier, yield.IconString or "?" )
		end


		if yieldPerPop ~= 0 then
			if yieldPerPop > 0 then
				yieldPerPop = format("+%s", yieldPerPop);
			end
			if tip ~= "" then
				tip = format("%s, ", tip )
			end
			tip = format("%s%s%s %s[ICON_CITIZEN]", tip, yieldPerPop, yield.IconString or "?", L"TXT_KEY_CITYVIEW_EACH" )
		end

		---------------------------------New--------------------------------------------
		if yieldPerPopGlobal ~= 0 then
			if yieldPerPopGlobal > 0 then
				yieldPerPopGlobal = format("+%s", yieldPerPopGlobal);
			end
			if tip ~= "" then
				tip = format("%s, ", tip )
			end
			tip = format("%s%s%s %s[ICON_CITIZEN]", tip, yieldPerPopGlobal, yield.IconString or "?", L"TXT_KEY_CITYVIEW_GLOBAL_EACH_SP" )
		end
		---------------------------------New--------------------------------------------

		if yieldPerReligion ~= 0 then
			if yieldPerReligion > 0 then
				yieldPerReligion = format("+%s", yieldPerReligion);
			end
			if tip ~= "" then
				tip = format("%s, ", tip )
			end
			tip = format("%s%s%s %s[ICON_RELIGION]", tip, yieldPerReligion, yield.IconString or "?", L"TXT_KEY_CITYVIEW_EACH" )
		end
		if yield.Type == "YIELD_GOLD" and building.TradeRouteSeaGoldBonus > 0 then
			tradeRouteSeaGoldBonus = (building.TradeRouteSeaGoldBonus)/100
			if tradeRouteSeaGoldBonus > 0 then
				tradeRouteSeaGoldBonus = format("+%s", tradeRouteSeaGoldBonus);
			end
			if tip ~= "" then
				tip = format("%s, ", tip )
			end
			tip = format("%s[ICON_INTERNATIONAL_TRADE]%s%s%s", tip, L"TXT_KEY_TRSGB1", tradeRouteSeaGoldBonus, yield.IconString or "?" )
		end
		if yield.Type == "YIELD_GOLD" and building.TradeRouteLandGoldBonus > 0 then
			tradeRouteLandGoldBonus = (building.TradeRouteLandGoldBonus)/100
			if tradeRouteLandGoldBonus > 0 then
				tradeRouteSeaGoldBonus = format("+%s", tradeRouteLandGoldBonus);
			end
			if tip ~= "" then
				tip = format("%s, ", tip )
			end
			tip = format("%s[ICON_INTERNATIONAL_TRADE]%s%s%s", tip, L"TXT_KEY_TRLGB1", tradeRouteLandGoldBonus, yield.IconString or "?" )
		end

		if yield.Type == "YIELD_GOLD" and building.TradeRouteSeaGoldBonusGlobal > 0 then
			tradeRouteSeaGoldBonusGlobal = (building.TradeRouteSeaGoldBonusGlobal)/100
			if tradeRouteSeaGoldBonusGlobal > 0 then
				tradeRouteSeaGoldBonusGlobal = format("+%s", tradeRouteSeaGoldBonusGlobal);
			end
			if tip ~= "" then
				tip = format("%s, ", tip )
			end
			tip = format("%s[ICON_INTERNATIONAL_TRADE]%s%s%s", tip, L"TXT_KEY_GLOBAL1" .. L"TXT_KEY_TRSGB1", tradeRouteSeaGoldBonusGlobal, yield.IconString or "?" )
		end
		if yield.Type == "YIELD_GOLD" and building.TradeRouteLandGoldBonusGlobal > 0 then
			tradeRouteLandGoldBonusGlobal = (building.TradeRouteLandGoldBonusGlobal)/100
			if tradeRouteLandGoldBonusGlobal > 0 then
				tradeRouteLandGoldBonusGlobal = format("+%s", tradeRouteLandGoldBonusGlobal);
			end
			if tip ~= "" then
				tip = format("%s, ", tip )
			end
			tip = format("%s[ICON_INTERNATIONAL_TRADE]%s%s%s", tip, L"TXT_KEY_GLOBAL1" .. L"TXT_KEY_TRLGB1", tradeRouteLandGoldBonusGlobal, yield.IconString or "?" )
		end

		if tip ~= "" then
			insert( tips, L(yield.Description) .. ": " .. tip )
		end
	end
	-- Culture leftovers
	if cultureChange ~= 0 then
		tip = format(" %+i[ICON_CULTURE]", cultureChange )
	else
		tip = ""
	end
	if cultureModifier ~= 0 then
		tip = format("%s %+i%%[ICON_CULTURE]", tip, cultureModifier )
	end
	if tip ~= "" then
		insert( tips, L"TXT_KEY_PEDIA_CULTURE_LABEL" .. tip )
	end
	if IsCiv5 then
		-- Happiness:
		if happinessChange ~= 0 then
			tip = format( " %+i[ICON_HAPPINESS_1]", happinessChange )
		else
			tip = ""
		end
		if (building.HappinessPerXPolicies or 0) ~= 0 then
			tip = format( "%s +1[ICON_HAPPINESS_1]/%i %s", tip, building.HappinessPerXPolicies, PolicyColor( L"TXT_KEY_VP_POLICIES" ) )
		end
		if tip ~= "" then
			insert( tips, L"TXT_KEY_PEDIA_HAPPINESS_LABEL" .. tip )
		end
	end

	-- Defense:
	if defenseChange ~=0 then
		tip = format(" %+g[ICON_STRENGTH]", defenseChange / 100 )
	else
		tip = ""
	end
	if hitPointChange ~=0 then
		tip = tip .. " " .. L( "TXT_KEY_PEDIA_DEFENSE_HITPOINTS", hitPointChange )
	end


	-- New for Gobal Defense:
	--if (building.GlobalDefenseMod ~= 0) then 
	    --tip = tip .. " " .. L( "TXT_KEY_PRODUCTION_BUILDING_DEFENSE_MOD_SP", building.GlobalDefenseMod )
	--end

	 --New for City Attack Range: 
	if building.BombardRange ~= 0 then 
		tip = tip .. " " .. L("TXT_KEY_PEDIA_CITY_BOMBARDRANGE_SP", building.BombardRange)
	end


	if tip~="" then
		insert( tips, L"TXT_KEY_PEDIA_DEFENSE_LABEL" .. tip )
	end



	--New for Conquest Pro:
	if (building.ConquestProb ~= 0) then 
	    insert( tips, L( "TXT_KEY_PEDIA_CONQUESTPROB_SP", building.ConquestProb))
	end

	--New for Never Capture:
	if (building.NeverCapture == true) then 
	    insert( tips, L( "TXT_KEY_PEDIA_NEVER_CAPTURE_SP"))
	end

	--New for Nuke NukeI mmune:
	--if (building.NukeModifier ~= 0) then 
	    --insert( tips, L( "TXT_KEY_PEDIA_NUKE_DECREASE", building.NukeModifier))
	--end


	-- Maintenance:
	if maintenanceCost ~= 0 then
		insert( tips, format( "%s %+i%s", L"TXT_KEY_PEDIA_MAINT_LABEL", -maintenanceCost, g_currencyIcon) )
	end

	-- Resources required:
	if Game then


		for resource in GameInfo.Resources() do
			item = Game.GetNumResourceRequiredForBuilding( buildingID, resource.ID )
			if item ~= 0 then
				insert( tips, ResourceQuantity( resource, -item ) )
			end
		end
	else
		for row in GameInfo.Building_ResourceQuantityRequirements( thisBuildingType ) do
			resource = GameInfo.Resources[ row.ResourceType ]
			if resource and (row.Cost or 0)~=0 then
				insert( tips, ResourceQuantity( resource, -row.Cost ) )
			end
		end
	end





	-- Specialists
	local specialistType = building.SpecialistType
	local specialist = specialistType and GameInfo.Specialists[ specialistType ]
	if specialist then
		if ( building.GreatPeopleRateChange or 0 ) ~= 0 then
			insert( tips, format("%s %+i%s", L( specialist.GreatPeopleTitle ), building.GreatPeopleRateChange, GreatPeopleIcon( specialistType ) ) )
		end
		if (building.SpecialistCount or 0) ~= 0 then
			if IsCiv5 then
				local numSpecialistsInBuilding = city and city:GetNumSpecialistsInBuilding( buildingID ) or building.SpecialistCount
				if numSpecialistsInBuilding ~= building.SpecialistCount then
					numSpecialistsInBuilding = numSpecialistsInBuilding.."/"..building.SpecialistCount
				end
				insert( tips, L( "TXT_KEY_CITYVIEW_BUILDING_SPECIALIST_YIELD", numSpecialistsInBuilding, specialist.Description, GetSpecialistYields( city, specialist ) ) )
			else
				insert( tips, format( "%i[ICON_CITIZEN]%s /%s", building.SpecialistCount, UnitColor( L(specialist.Description or "???") ), GetSpecialistYields( city, specialist ) ) )
			end
		end
	end

	if IsCiv5BNW then
		-- Great Work Slots
		local greatWorkType = (building.GreatWorkCount or 0) > 0 and GameInfo.GreatWorkSlots[building.GreatWorkSlotType]
		if greatWorkType then
			insert( tips, L( greatWorkType.SlotsToolTipText, building.GreatWorkCount ) )
		end
		for row in GameInfo.Building_DomainFreeExperiencePerGreatWork( thisBuildingType ) do
			item = GameInfo.Domains[ row.DomainType ]
			if item and (row.Experience or 0) > 0 then
				insert( tips, XPcolor(L(item.Description)).." "..L( "TXT_KEY_EXPERIENCE_POPUP", row.Experience ).."/ "..L"TXT_KEY_VP_GREAT_WORKS" )
			end
		end
		-- Theming Bonus
-- TODO Building_ThemingBonuses
--		if building.ThemingBonusHelp then insert( tips, L( building.ThemingBonusHelp ) ) end
		-- Free Great Work
		local freeGreatWork = building.FreeGreatWork and GameInfo.GreatWorks[ building.FreeGreatWork ]
-- TODO type rather than blurb
		if freeGreatWork then
			insert( tips, L"TXT_KEY_FREE" .." "..PolicyColor(L(freeGreatWork.Description)) )
		end

-- TODO sacred sites properly
		tip = ""
		if (building.FaithCost or 0) > 0 and building.UnlockedByBelief and building.Cost == -1 then
			local tourism = city and city:GetFaithBuildingTourism() or 0
			if tourism ~= 0 then
				tip = format(" %+i[ICON_TOURISM]", tourism )
			end
		end
		if enhancedYieldTechName and (building.TechEnhancedTourism or 0) ~= 0 then
			tip = format("%s %s %+i[ICON_TOURISM]", tip, enhancedYieldTechName, building.TechEnhancedTourism )
		end
		if tip ~= "" then
			insert( tips, L"TXT_KEY_CITYVIEW_TOURISM_TEXT" .. ":" .. tip )
		end
	end
-- TODO GetInternationalTradeRouteYourBuildingBonus
	if not IsCiv5Vanilla then
		-- Resources
		for row in GameInfo.Building_ResourceQuantity( thisBuildingType ) do
			resource = GameInfo.Resources[ row.ResourceType ]
			if resource and (row.Quantity or 0) ~= 0 then
				insert( tips, ResourceQuantity( resource, row.Quantity ) )
			end
		end
	end

	-- Resource Yields enhanced by Building
	for resource in GameInfo.Resources() do
		thisBuildingAndResourceTypes.ResourceType = resource.Type or -1
		tip = GetYieldString( GameInfo.Building_ResourceYieldChanges( thisBuildingAndResourceTypes ) )
		for row in GameInfo.Building_ResourceCultureChanges( thisBuildingAndResourceTypes ) do
			if (row.CultureChange or 0) ~= 0 then
				tip = format("%s %+i[ICON_CULTURE]", tip, row.CultureChange )
			end
		end
		if g_isReligionEnabled then
			for row in GameInfo.Building_ResourceFaithChanges( thisBuildingAndResourceTypes ) do
				if (row.FaithChange or 0)~= 0 then
					tip = format("%s %+i[ICON_FAITH]", tip, row.FaithChange )
				end
			end
		end
-- TODO GameInfo.Building_ResourceYieldModifiers( thisBuildingType ), ResourceType, YieldType, Yield
		if tip ~= "" then
			insert( tips, ResourceString( resource ) .. ":" .. tip )
		end
	end

	-- Gobal Resource Bouns
	for resource in GameInfo.Resources() do
		thisBuildingAndResourceTypes.ResourceType = resource.Type or -1
		tip = GetYieldString( GameInfo.Building_ResourceYieldChangesGlobal( thisBuildingAndResourceTypes ) )
		if tip ~= "" then
				insert( tips, L("TXT_KEY_PEDIA_GLOBAL_RESOURCES_SP")..ResourceString( resource ) .. ":" .. tip )
		end
	end

	-- Gobal Improvement Bouns
	for Improvement in GameInfo.Improvements() do
		tip = GetYieldString( GameInfo.Building_ImprovementYieldChangesGlobal{ BuildingType = buildingType, ImprovementType = Improvement.Type } )
		if tip ~= "" then
			insert( tips, L"TXT_KEY_PEDIA_GLOBAL_RESOURCES_SP" ..ResourceColor(L(Improvement.Description)).. ":" .. tip )
		end
	end

	-- Feature Yields enhanced by Building
	for feature in GameInfo.Features() do
		tip = GetYieldString( GameInfo.Building_FeatureYieldChangesGlobal{ BuildingType = buildingType, FeatureType = feature.Type } )
		if tip ~= "" then
			insert( tips, L"TXT_KEY_CITYVIEW_GLOBAL_EACH_SP"..ResourceColor(L(feature.Description) ) .. ":" .. tip )
		end
	end

	for terrain in GameInfo.Terrains() do
			tip = GetYieldString( GameInfo.Building_TerrainYieldChangesGlobal{ BuildingType = buildingType, TerrainType = terrain.Type } )
			if tip ~= "" then
			insert( tips, L"TXT_KEY_CITYVIEW_GLOBAL_EACH_SP"..ResourceColor(L(terrain.Description) ) .. ":" .. tip )
		end
	end

	-- Local Improvement Bouns
	for Improvement in GameInfo.Improvements() do
		tip = GetYieldString( GameInfo.Building_ImprovementYieldChanges{ BuildingType = buildingType, ImprovementType = Improvement.Type } )
		if tip ~= "" then
			insert( tips, L"TXT_KEY_LOCAL_IMPROVEMENT_YIELD_SP" ..ResourceColor(L(Improvement.Description)) .. ":" .. tip )
		end
	end

	-- Feature Yields enhanced by Building
	for feature in GameInfo.Features() do
		tip = GetYieldString( GameInfo.Building_FeatureYieldChanges{ BuildingType = buildingType, FeatureType = feature.Type } )
		if tip ~= "" then
			insert( tips, ResourceColor( L(feature.Description) ) .. ":" .. tip )
		end
	end
	if not IsCiv5Vanilla then
		-- Terrain Yields enhanced by Building
		for terrain in GameInfo.Terrains() do
			tip = GetYieldString( GameInfo.Building_TerrainYieldChanges{ BuildingType = buildingType, TerrainType = terrain.Type } )
			if tip ~= "" then
				insert( tips, ResourceColor( L(terrain.Description) ) .. ":" .. tip )
			end
		end
	end
	-- Specialist Yields enhanced by Building
	for specialist in GameInfo.Specialists() do
		tip = GetYieldString( GameInfo.Building_SpecialistYieldChanges{ BuildingType = buildingType, SpecialistType = specialist.Type } )
		if tip ~= "" then
			insert( tips, UnitColor( L(specialist.Description) ) .. ":" .. tip )
		end
	end

	--Local Specialist Yields enhanced by Building
	for specialist in GameInfo.Specialists() do
		tip = GetYieldString( GameInfo.Building_SpecialistYieldChangesLocal{ BuildingType = buildingType, SpecialistType = specialist.Type } )
		if tip ~= "" then
			insert( tips, L"TXT_KEY_LOCAL_SPECIALIST_SP" ..UnitColor( L(specialist.Description) ) .. ":" .. tip )
		end
	end




	-- River Yields enhanced by Building
	tip = GetYieldString( GameInfo.Building_RiverPlotYieldChanges( thisBuildingType ) )
	if tip ~= "" then
		insert( tips, L"TXT_KEY_PLOTROLL_RIVER" .. ":" .. tip )
	end




	-- Lake Yields enhanced by Building
	tip = GetYieldString( GameInfo.Building_LakePlotYieldChanges( thisBuildingType ) )
	if tip ~= "" then
		insert( tips, L"TXT_KEY_PLOTROLL_LAKE" .. ":" .. tip )
	end

	-- Ocean Yields enhanced by Building
	tip = GetYieldString( GameInfo.Building_SeaPlotYieldChanges( thisBuildingType ) )
	if tip ~= "" then
		insert( tips, L"TXT_KEY_PLOTROLL_OCEAN" .. ":" .. tip )
	end

	-- Ocean Resource Yields enhanced by Building
	tip = GetYieldString( GameInfo.Building_SeaResourceYieldChanges( thisBuildingType ) )
-- todo determine sea resources
	if tip ~= "" then
		insert( tips, L"TXT_KEY_PLOTROLL_OCEAN" .." "..L"TXT_KEY_TOPIC_RESOURCES".. ":" .. tip )
	end

	-- Area Yields enhanced by Building
	tip = GetYieldStringSpecial( "Yield", "%s %+i%%%s", GameInfo.Building_AreaYieldModifiers( thisBuildingType ) )
	if tip ~= "" then
		insert( tips, L"TXT_KEY_PGSCREEN_CONTINENTS" .. ":" .. tip )
	end
	-- Map Yields enhanced by Building
	tip = GetYieldStringSpecial( "Yield", "%s %+i%%%s", GameInfo.Building_GlobalYieldModifiers( thisBuildingType ) )
	if tip ~= "" then
		insert( tips, L"TXT_KEY_SV_ICONS_GLOBAL_SP" .. ":" .. tip )
	end

	-- victory requisite
	item = building.VictoryPrereq and GameInfo.Victories[ building.VictoryPrereq ]
	if item then
		insert( tips, TextColor( "[COLOR_GREEN]", L(item.Description) ) )
	end

	-- free building in this city
	item = GetCivBuilding( activeCivilizationType, building.FreeBuildingThisCity )
	if item then
		insert( tips, L"TXT_KEY_FREE".." "..BuildingColor( L(item.Description) ) )
	end

	-- free building in all cities
	item = GetCivBuilding( activeCivilizationType, building.FreeBuilding )
	if item then
		insert( tips, L"TXT_KEY_FREE".." "..BuildingColor( L(item.Description) ) )-- todo xml
	end

	-- free units
	for row in GameInfo.Building_FreeUnits( thisBuildingType ) do
		item = GameInfo.Units[ row.UnitType ]
		item = item and GetCivUnit( activeCivilizationType, item.Class )
		if item and (row.NumUnits or 0) > 0 then
			insert( tips, L("{1: plural 2?{1} ;}{TXT_KEY_FREE} {2}", row.NumUnits, format( "%s %s", ( item.Special and item.Special == "SPECIALUNIT_PEOPLE" and GreatPeopleIcon( item.Type ) or "" ), UnitColor( L(item.Description) ) ) ) )
		end
	end


	--New for free units
	for row in GameInfo.Building_FreeSpecUnits( thisBuildingType ) do
		item = GameInfo.Units[ row.UnitType ]
		if item and (row.NumUnits or 0) > 0 then
			insert( tips, L("{1: plural 2?{1} ;}{TXT_KEY_FREE} {2}", row.NumUnits, format( "%s %s", ( item.Special and item.Special == "SPECIALUNIT_PEOPLE" and GreatPeopleIcon( item.Type ) or "" ), UnitColor( L(item.Description) ) ) ) )
		end
	end

    --Building_FreeSpecialistCounts unused ?
	-- free promotion to units trained in this city
	item = building.TrainedFreePromotion and GameInfo.UnitPromotions[ building.TrainedFreePromotion ]
	if item then
		insert( tips, L"TXT_KEY_PEDIA_FREEPROMOTIONS_LABEL".." ("..L( "TXT_KEY_NOTIFICATION_SUMMARY_CITY_STATE_UNIT_SPAWN", "TXT_KEY_CITY" )..") +"..( item.IconStringSP or "?" )..L( item.Help or "???" ) )
	end

	-- free promotion for all units
	--item = building.FreePromotion and GameInfo.UnitPromotions[ building.FreePromotion ]
	--if item then
		--insert( tips, L"TXT_KEY_PEDIA_FREEPROMOTIONS_LABEL".." +"..( item.IconStringSP or "?" )..L( item.Help or "???" ) )
	--end

	--New for free promotion for all units
	item = building.FreePromotion and GameInfo.UnitPromotions[ building.FreePromotion ]
	if item then
		insert( tips, L"TXT_KEY_PEDIA_FREEPROMOTIONS_LABEL_EXTRA_SP".." +"..( item.IconStringSP or "?" )..L( item.Help or "???" ) )
	end

	item = building.FreePromotion2 and GameInfo.UnitPromotions[ building.FreePromotion2 ]
	if item then
		insert( tips, L"TXT_KEY_PEDIA_FREEPROMOTIONS_LABEL_EXTRA_SP".." +"..( item.IconStringSP or "?" )..L( item.Help or "???" ) )
	end

	item = building.FreePromotion3 and GameInfo.UnitPromotions[ building.FreePromotion3 ]
	if item then
		insert( tips, L"TXT_KEY_PEDIA_FREEPROMOTIONS_LABEL_EXTRA_SP".." +"..( item.IconStringSP or "?" )..L( item.Help or "???" ) )
	end


	-- hurry modifiers
	for row in GameInfo.Building_HurryModifiers( thisBuildingType ) do
		item = GameInfo.HurryInfos[ row.HurryType ]
		if item and (row.HurryCostModifier or 0) ~= 0 then
			insert( tips, format( "%s %+i%%", TextColor( "[COLOR_GREEN]", L(item.Description) ), row.HurryCostModifier ) )
		end
	end

	-- Unit production modifier
	for row in GameInfo.Building_UnitCombatProductionModifiers( thisBuildingType ) do
		item = GameInfo.UnitCombatInfos[ row.UnitCombatType ]
		if item and (row.Modifier or 0) ~= 0 then
			insert( tips, format( "%s %+i%%[ICON_PRODUCTION]", UnitColor( L(item.Description) ), row.Modifier ) )
		end
	end
	for row in GameInfo.Building_DomainProductionModifiers( thisBuildingType ) do
		item = GameInfo.Domains[ row.DomainType ]
		if item and (row.Modifier or 0) ~= 0 then
			insert( tips, format( "%s %+i%%[ICON_PRODUCTION]", UnitColor( L(item.Description) ), row.Modifier ) )
		end
	end

	-- free experience
	for row in GameInfo.Building_DomainFreeExperiences( thisBuildingType ) do
		item = GameInfo.Domains[ row.DomainType ]
		if item and (row.Experience or 0) ~= 0 then
			insert( tips, UnitColor( L(item.Description) ).." "..L( "TXT_KEY_EXPERIENCE_POPUP", row.Experience ) )
		end
	end

	--New For Gobal Experence
	for row in GameInfo.Building_DomainFreeExperiencesGlobal( thisBuildingType ) do
		item = GameInfo.Domains[ row.DomainType ]
		if item and (row.Experience or 0) ~= 0 then
			insert( tips, L("TXT_KEY_EXPERIENCE_DOMAIN_GLOBAL_SP")..UnitColor( L(item.Description) ).." "..L( "TXT_KEY_EXPERIENCE_POPUP", row.Experience ) )
		end
	end


	--New for local Specialist Bouns
	for row in GameInfo.Building_SpecificGreatPersonRateModifier( thisBuildingType ) do
	    item = GameInfo.Specialists[ row.SpecialistType ]
		if item and (row.Modifier or 0) ~= 0 then
			insert( tips, L("TXT_KEY_LOCAL_SPECIALIST_SP")..L(item.Description) .. ":" .."".."+" ..row.Modifier.."%".."[ICON_GREAT_PEOPLE]"  )
		end
	end



	------------------------------------------------------------------------------------------------
	for row in GameInfo.Building_UnitCombatFreeExperiences( thisBuildingType ) do
		item = GameInfo.UnitCombatInfos[ row.UnitCombatType ]
		if item and (row.Experience or 0) > 0 then
			insert( tips, UnitColor( L(item.Description) ).." "..L( "TXT_KEY_EXPERIENCE_POPUP", row.Experience ) )
		end
	end

	insertLocalizedIfNonZero( tips, "TXT_KEY_PRODUCTION_NEEDED_UNIT_MODIFIER", building.GlobalProductionNeededUnitModifier or 0 )
	insertLocalizedIfNonZero( tips, "TXT_KEY_PRODUCTION_NEEDED_BUILDING_MODIFIER", building.GlobalProductionNeededBuildingModifier or 0 )
	insertLocalizedIfNonZero( tips, "TXT_KEY_PRODUCTION_NEEDED_PROJECT_MODIFIER", building.GlobalProductionNeededProjectModifier or 0 )

	if PreGame.GetGameOption("GAMEOPTION_SP_CORPS_MODE_DISABLE") == 0 then
		local TroopRow = GameInfo.Building_DomainTroops{BuildingType = buildingType, DomainType = "DOMAIN_SEA"}()
		if TroopRow then
			insertLocalizedIfNonZero( tips, "TXT_KEY_BASE_TROOPS", TroopRow.NumTroop or 0 )
		end
		insertLocalizedIfNonZero( tips, "TXT_KEY_BASE_CROPS", building.NumCrops  or 0 )
		insertLocalizedIfNonZero( tips, "TXT_KEY_BASE_ARMEE", building.NumArmee or 0 )
	end

	--New for Yield From Other Yield
	for row in GameInfo.Building_YieldFromOtherYield(thisBuildingType) do
		item = GameInfo.Yields[ row.InYieldType ]
		item2 = GameInfo.Yields[ row.OutYieldType ]
		if item and (row.InYieldValue or 0) > 0 then
			insert( tips,(L( "TXT_KEY_EVERY_PER_SP")..row.InYieldValue..L(item.IconString).."+"..row.OutYieldValue..L(item2.IconString)  ) )
		end
	end


	-- Yields enhanced by Technology
	if techFilter( enhancedYieldTech ) then
		tip = GetYieldString( GameInfo.Building_TechEnhancedYieldChanges( thisBuildingType ) )
		if #tip > 0 then
			insert( tips, "[ICON_BULLET]" .. enhancedYieldTechName .. tip )
		end
	end

	items = {}
	-- Yields enhanced by Policy
	for row in GameInfo.Policy_BuildingClassYieldChanges( thisBuildingClassType ) do
		if row.PolicyType and (row.YieldChange or 0) ~= 0 then
			items[row.PolicyType] = format( "%s %+i%s", items[row.PolicyType] or "", row.YieldChange, YieldIcons[row.YieldType] or "?" )
		end
	end
	for row in GameInfo.Policy_BuildingClassCultureChanges( thisBuildingClassType ) do
		if row.PolicyType and (row.CultureChange or 0) ~= 0 then
			items[row.PolicyType] = format( "%s %+i[ICON_CULTURE]", items[row.PolicyType] or "", row.CultureChange )
		end
	end
	-- Yield modifiers enhanced by Policy
	for row in GameInfo.Policy_BuildingClassYieldModifiers( thisBuildingClassType ) do
		if row.PolicyType and (row.YieldMod or 0) ~= 0 
		and GameInfo.Policies[ row.PolicyType].Dummy~=1  --New
		and row.PolicyType:match("^[POLICY_AI_]+.") == nil
		then
			items[row.PolicyType] = format( "%s %+i%%%s", items[row.PolicyType] or "", row.YieldMod, YieldIcons[row.YieldType] or "?" )
		end
	end
	if IsCiv5 then
		if IsCiv5BNW then
			for row in GameInfo.Policy_BuildingClassTourismModifiers( thisBuildingClassType ) do
				if row.PolicyType and (row.TourismModifier or 0) ~= 0
				and GameInfo.Policies[ row.PolicyType].Dummy~=1  --New
				and row.PolicyType:match("^[POLICY_AI_]+.") == nil
				then
					items[row.PolicyType] = format( "%s %+i%%[ICON_TOURISM]", items[row.PolicyType] or "", row.TourismModifier )
				end
			end
		end
		for row in GameInfo.Policy_BuildingClassHappiness( thisBuildingClassType ) do
			if row.PolicyType and (row.Happiness or 0) ~= 0 then
				items[row.PolicyType] = format( "%s %+i[ICON_HAPPINESS_1]", items[row.PolicyType] or "", row.Happiness )
			end
		end
		local lastTip -- universal healthcare kludge
		for policyType, tip in pairs( items ) do
			local policy = GameInfo.Policies[ policyType ]
			if policyFilter( policy ) and #tip > 0 then
				tip = "[ICON_BULLET]" .. PolicyColor( L(policy.Description) ) .. tip
				if tip~=lastTip then
					insert( tips, tip )
				end
				lastTip = tip
			end
		end

		if not IsCiv5Vanilla then
			-- Yields enhanced by Beliefs
			items = {}
			for row in GameInfo.Belief_BuildingClassYieldChanges( thisBuildingClassType ) do
				if row.BeliefType and (row.YieldChange or 0) ~= 0 then
					items[row.BeliefType] = format( "%s %+i%s", items[row.BeliefType] or "", row.YieldChange, YieldIcons[row.YieldType] or "?" )
				end
			end
			if maxGlobalInstances > 0 then -- world wonder
				for row in GameInfo.Belief_YieldChangeWorldWonder() do
					if row.BeliefType and (row.Yield or 0) ~= 0 then
						items[row.BeliefType] = format( "%s %+i%s", items[row.BeliefType] or "", row.Yield, YieldIcons[row.YieldType] or "?" )
					end
				end
			end
			if IsCiv5BNW then
				for row in GameInfo.Belief_BuildingClassTourism( thisBuildingClassType ) do
					if row.BeliefType and (row.Tourism or 0) ~= 0 then
						items[row.BeliefType] = format( "%s %+i[ICON_TOURISM]", items[row.BeliefType] or "", row.Tourism )
					end
				end
			end
			for row in GameInfo.Belief_BuildingClassHappiness( thisBuildingClassType ) do
				if row.BeliefType and (row.Happiness or 0) ~= 0 then
					items[row.BeliefType] = format( "%s %+i[ICON_HAPPINESS_1]", items[row.BeliefType] or "", row.Happiness )
				end
			end

	

			for beliefType, tip in pairs( items ) do
				local belief = GameInfo.Beliefs[beliefType]
				if beliefFilter( belief ) and #tip > 0 then
					insert( tips, "[ICON_BULLET]" .. BeliefColor( L(belief.ShortDescription) ) .. tip )
				end
			end

			-- Other Building Yields enhanced by this Building
			local buildingClassTypes = {}
			for row in GameInfo.BuildingClasses() do
				if GameInfo.Building_BuildingClassYieldChanges{ BuildingType = buildingType, BuildingClassType = row.Type }()
				or(IsCiv5 and GameInfo.Building_BuildingClassHappiness{ BuildingType = buildingType, BuildingClassType = row.Type }())
				then
					insert( buildingClassTypes, row.Type )
				end
			end
			local condition = { BuildingType = buildingType }
			for _, buildingClassType in pairs( buildingClassTypes ) do
				condition.BuildingClassType = buildingClassType
				tip = GetYieldStringSpecial( "YieldChange", "%s %+i%s", GameInfo.Building_BuildingClassYieldChanges( condition ) )
				if IsCiv5 then
					local happinessChange = 0
					for row in GameInfo.Building_BuildingClassHappiness( condition ) do
						happinessChange = happinessChange + (row.Happiness or 0)
					end
					if happinessChange ~= 0 then
						tip = format( "%s %+i[ICON_HAPPINESS_1]", tip, happinessChange )
					end
				end
				local enhancedBuilding = GetCivBuilding( activeCivilizationType, buildingClassType )
				if enhancedBuilding and #tip > 0 then
					insert( tips, "[ICON_BULLET]" ..L"TXT_KEY_SV_ICONS_ALL".." ".. BuildingColor( L(enhancedBuilding.Description) ) .. tip )
				end
			end
		

			-- Other Building Yields enhanced by this Building
			local buildingClassTypes2 = {}
			for row in GameInfo.BuildingClasses() do
				if GameInfo.Building_BuildingClassLocalYieldChanges{ BuildingType = buildingType, BuildingClassType = row.Type }()
				then
					insert( buildingClassTypes2, row.Type )
				end
			end
			local condition = { BuildingType = buildingType }
			for _, buildingClassType in pairs( buildingClassTypes2 ) do
				condition.BuildingClassType = buildingClassType
				tip = GetYieldStringSpecial( "YieldChange", "%s %+i%s", GameInfo.Building_BuildingClassLocalYieldChanges( condition ) )
				local enhancedBuilding = GetCivBuilding( activeCivilizationType, buildingClassType )
				if enhancedBuilding and #tip > 0 then
					insert( tips, "[ICON_BULLET]" ..L"TXT_KEY_SV_ICONS_LOCAL_SP".." ".. BuildingColor( L(enhancedBuilding.Description) ) .. tip )
				end
			end

	

			-- Other Building Yields Modifiers enhanced by this Building
			local buildingClassTypes3 = {}
			for row in GameInfo.BuildingClasses() do
				if GameInfo.Building_BuildingClassYieldModifiers{ BuildingType = buildingType, BuildingClassType = row.Type }()
				then
					insert( buildingClassTypes3, row.Type )
				end
			end
			local condition = { BuildingType = buildingType }
			for _, buildingClassType in pairs( buildingClassTypes3 ) do
				condition.BuildingClassType = buildingClassType
				tip = GetYieldStringSpecial( "Modifier", "%s%+i%%%s", GameInfo.Building_BuildingClassYieldModifiers( condition ) )
				local enhancedBuilding = GetCivBuilding( activeCivilizationType, buildingClassType )
				if enhancedBuilding and #tip > 0 then
					insert( tips, "[ICON_BULLET]" ..L"TXT_KEY_SV_ICONS_GLOBAL_SP".." ".. BuildingColor( L(enhancedBuilding.Description) ) .. tip )
				end
			end

		end
	end

	insert( tips, "----------------" )

	-- Cost:
	local costTip
	-- League project
	if IsCiv5BNW and building.UnlockedByLeague then
		if Game
			and Game.GetNumActiveLeagues() > 0
			and Game.GetActiveLeague()
		then
			costTip = L( "TXT_KEY_LEAGUE_PROJECT_COST_PER_PLAYER",
				Game.GetActiveLeague():GetProjectBuildingCostPerPlayer( buildingID ) )
		else
			local leagueProjectReward = GameInfo.LeagueProjectRewards{ Building = buildingType }()
			local leagueProject = leagueProjectReward and GameInfo.LeagueProjects{ RewardTier3 = leagueProjectReward.Type }()
			local costPerPlayer = leagueProject and leagueProject.CostPerPlayer	-- * GameInfo.GameSpeeds[ PreGame.GetGameSpeed() ].ConstructPercent * GameInfo.Eras[ PreGame.GetEra() ].ConstructPercent / 100000	-- GameInfo.Eras[ player:GetCurrentEra() ]
			if costPerPlayer then
				costTip = L( "TXT_KEY_LEAGUE_PROJECT_COST_PER_PLAYER", costPerPlayer )
			end
		end
	-- Production
	else
		if productionCost > 1 then
			costTip = productionCost .. "[ICON_PRODUCTION]"
			local goldCost = 0
			if city then
				goldCost = city:GetBuildingPurchaseCost( buildingID )

			elseif building.HurryCostModifier and building.HurryCostModifier >= 0 then
				goldCost = (productionCost * GameDefines.GOLD_PURCHASE_GOLD_PER_PRODUCTION ) ^ GameDefines.HURRY_GOLD_PRODUCTION_EXPONENT
				goldCost = (building.HurryCostModifier + 100) * goldCost / 100
				goldCost = goldCost - ( goldCost % GameDefines.GOLD_PURCHASE_VISIBLE_DIVISOR )
			end
			if goldCost > 0 then
				if costTip then
					costTip = costTip .. ("(%i%%)"):format(productionCost*100/goldCost)
					if IsCiv5Vanilla then
						costTip = costTip .. " / " .. goldCost .. g_currencyIcon
					else
						costTip = L( "TXT_KEY_PEDIA_A_OR_B", costTip, goldCost .. g_currencyIcon )
					end
				else
					costTip = goldCost .. g_currencyIcon
				end
			end
		end
		-- Faith
		if g_isReligionEnabled then
			local faithCost = 0
			if city then
				faithCost = city:GetBuildingFaithPurchaseCost( buildingID, true )
			else
				faithCost = building.FaithCost or 0
			end
			if faithCost > 0 then
				if costTip then
					costTip = L( "TXT_KEY_PEDIA_A_OR_B", costTip, faithCost .. "[ICON_PEACE]" )
				else
					costTip = faithCost .. "[ICON_PEACE]"
				end
			end
		end
	end
	insert( tips, L"TXT_KEY_PEDIA_COST_LABEL" .. " " .. ( costTip or L"TXT_KEY_FREE" ) )

	-- Production Modifiers
	for row in GameInfo.Policy_BuildingClassProductionModifiers( thisBuildingClassType ) do
		local policy = GameInfo.Policies[ row.PolicyType ]
		if policyFilter( policy ) and (row.ProductionModifier or 0) ~= 0 then
			insert( tips, format( "[ICON_BULLET]%s +%i%%[ICON_PRODUCTION]", PolicyColor( L(policy.Description) ), row.ProductionModifier ) )
		end
	end

	-- Civilization:
	local civs = {}
	local t
	for row in GameInfo.Civilization_BuildingClassOverrides( thisBuildingType ) do
		t = GameInfo.Civilizations[ row.CivilizationType ]
		if t then
			insert( civs, L(t.ShortDescription) )
		end
	end
	if #civs > 0 then
		insert( tips, L"TXT_KEY_PEDIA_CIVILIZATIONS_LABEL" .. " " .. concat( civs, ", ") )
	end

	-- Replaces:
	item = buildingClass and GameInfo.Buildings[ buildingClass.DefaultBuilding ]
	if item and item ~= building then
		insert( tips, L"TXT_KEY_PEDIA_REPLACES_LABEL".." "..BuildingColor( L(item.Description) ) ) --!!! row
	end

	-- Required Social Policy:
	item = building.PolicyBranchType and GameInfo.PolicyBranchTypes[ building.PolicyBranchType ]
	if item then
		insert( tips, L"TXT_KEY_PEDIA_PREREQ_POLICY_LABEL" .. " " .. PolicyColor( L(item.Description) ) )
	end

	-- -------------------------------------------------------------end-- --------------------------------------------------------------------


	-- Prerequisite Techs:
	local techs = {}
	item = building.PrereqTech and GameInfo.Technologies[ building.PrereqTech ]
	if item and item.ID > 0 then
		insert( techs, TechColor( L(item.Description) ) )
	end
	for row in GameInfo.Building_TechAndPrereqs( thisBuildingType ) do
		item = GameInfo.Technologies[ row.TechType ]
		if item and item.ID > 0 then
			insert( techs, TechColor( L(item.Description) ) )
		end
	end
	if #techs > 0 then
		insert( tips, L"TXT_KEY_PEDIA_PREREQ_TECH_LABEL" .. " " .. concat( techs, ", " ) )
	end

	-- Required Buildings:
	local buildings = {}
	for row in GameInfo.Building_PrereqBuildingClasses( thisBuildingType ) do
		local item = GetCivBuilding( activeCivilizationType, row.BuildingClassType )
		if item then
			insert( tips, L"TXT_KEY_PEDIA_REQ_BLDG_LABEL".." ".. BuildingColor( L(item.Description) ).." ("..((row.NumBuildingNeeded or -1)==-1 and L"TXT_KEY_SV_ICONS_ALL" or row.NumBuildingNeeded)..")" )
			buildings[ item ] = true
		end
	end
	for row in GameInfo.Building_ClassesNeededInCity( thisBuildingType ) do
		local item = GetCivBuilding( activeCivilizationType, row.BuildingClassType )
		if item and not buildings[ item ] then
			insert( buildings, BuildingColor( L(item.Description) ) )
		end
	end
	items = {}
	if (building.MutuallyExclusiveGroup or -1) >= 0 then
		for row in GameInfo.Buildings{ MutuallyExclusiveGroup = building.MutuallyExclusiveGroup } do
			SetKey( items, row.BuildingClass ~= buildingClassType and row.BuildingClass )
		end
	end
	for buildingClassType in pairs( items ) do
		local item = GetCivBuilding( activeCivilizationType, buildingClassType )
		if item then
			insert( buildings, TextColor( "[COLOR_RED]", L(item.Description) ) )
		end
	end
	if #buildings > 0 then
		insert( tips, L"TXT_KEY_PEDIA_REQ_BLDG_LABEL" .. " " .. concat( buildings, ", ") )
	end

	
	--New for Buildings Needed
	--local buildings2 = {}
	--for row in GameInfo.Building_ClassesNeededInCityOR( thisBuildingType ) do
		--local item = GetCivBuilding( activeCivilizationType, row.BuildingClassType )
		--if item  then
		   --insert( buildings2, BuildingColor( L(item.Description) ) )
		--end
	--end
	--if #buildings2 > 0 then
		--insert( tips, L"TXT_KEY_PEDIA_REQ_BLDG_LABEL2_SP" .. " " .. concat( buildings2, ", ") )
	--end




	--end

	-- Required Buildings Global:
	local buildingsGloabl = {}
	for row in GameInfo.Building_ClassesNeededGlobal( thisBuildingType ) do
		local item = GetCivBuilding( activeCivilizationType, row.BuildingClassType )
		if item and not buildingsGloabl[ item ] then
			insert( buildingsGloabl, BuildingColor( L(item.Description) ) )
		end
	end
	if #buildingsGloabl > 0 then
		insert( tips, L"TXT_KEY_BUILDIND_NEEDED_GLOBAL_SP" .. " " .. concat( buildingsGloabl, ", ") )
	end

	-- Local Resources Required:
	local resources = {}
	for row in GameInfo.Building_LocalResourceAnds( thisBuildingType ) do
		resource = GameInfo.Resources[ row.ResourceType ]
		if resource then
			insert( resources, ResourceString( resource ) ) -- resource.IconString
		end
	end
	if #resources > 0 then
		resources = { concat( resources, ", ") }
	end
	for row in GameInfo.Building_LocalResourceOrs( thisBuildingType ) do
		resource = GameInfo.Resources[ row.ResourceType ]
		if resource then
			insert( resources, ResourceString( resource ) ) -- resource.IconString
		end
	end
	if IsCiv5Vanilla then
		resources = concat( resources, " / ")
	else
		local txt = resources[1] or ""
		for i = 2, #resources do
			txt = L( "TXT_KEY_PEDIA_A_OR_B", txt, resources[i] )
		end
		resources = txt
	end
	if #resources > 0 then
		insert( tips, L"TXT_KEY_PEDIA_LOCAL_RESRC_LABEL" .. " " .. resources )
	end

	local terrains = {}
	if building.Water then
		if building.MinAreaSize > 0 then
			insert( terrains, L"TXT_KEY_TERRAIN_COAST" .. "(" .. building.MinAreaSize .. ")")
		else
			insert( terrains, L"TXT_KEY_TERRAIN_COAST")
		end
	end
	if building.River then
		insert( terrains, L"TXT_KEY_PLOTROLL_RIVER" )
	end
	if building.FreshWater then
		insert( terrains, L"TXT_KEY_ABLTY_FRESH_WATER_STRING" )
	end
	if building.Mountain then
		insert( terrains, L"TXT_KEY_TERRAIN_MOUNTAIN" .. "[ICON_RANGE_STRENGTH]1" )
	end

	if building.AnyWater==1 then
		insert( terrains, L"TXT_KEY_BUILDING_NEED_ANY_WATER" )
	end

	if building.NearbyMountainRequired then
		insert( terrains, L"TXT_KEY_TERRAIN_MOUNTAIN" .. "[ICON_RANGE_STRENGTH]2" )
	end
	if building.Hill then
		insert( terrains, L"TXT_KEY_TERRAIN_HILL" )
	end
	if building.Flat then
		insert( terrains, L"TXT_KEY_MAP_OPTION_FLAT" )
	end
	-- mandatory terrain
	local terrain = building.NearbyTerrainRequired and GameInfo.Terrains[ building.NearbyTerrainRequired ]
	if terrain then
		insert( terrains, ResourceColor( L(terrain.Description) ) .. "[ICON_RANGE_STRENGTH]1" )
	end
	-- prohibited terrain
	terrain = building.ProhibitedCityTerrain and GameInfo.Terrains[ building.ProhibitedCityTerrain ]
	if terrain then
		insert( terrains, TextColor( "[COLOR_RED]", L(terrain.Description) ) )
	end

	if #terrains > 0 then
		insert( tips, L"TXT_KEY_PEDIA_TERRAIN_LABEL"..": "..concat( terrains, ", ") )
	end

	-- Becomes Obsolete with:
	item = building.ObsoleteTech and GameInfo.Technologies[ building.ObsoleteTech ]
	if item then
		insert( tips, L"TXT_KEY_PEDIA_OBSOLETE_TECH_LABEL" .. " " .. TechColor( L(item.Description) ) )
	end

	-- Buildings Unlocked:
	local buildingsUnlocked = {}
	for row in GameInfo.Building_ClassesNeededInCity( thisBuildingClassType ) do
		local buildingUnlocked = GameInfo.Buildings[ row.BuildingType ]
		SetKey( buildingsUnlocked, buildingUnlocked and buildingUnlocked.BuildingClass )
	end
	items = {}
	for buildingUnlocked in pairs(buildingsUnlocked) do
		buildingUnlocked = GetCivBuilding( activeCivilizationType, buildingUnlocked )
		if buildingUnlocked then
			insert( items, BuildingColor( L(buildingUnlocked.Description) ) )
		end
	end
	if #items > 0 then
		insert( tips, L"TXT_KEY_PEDIA_BLDG_UNLOCK_LABEL" .. " " .. concat( items, ", ") )
	end

	-- Buildings Unlocked Global:
	local buildingsUnlockedGlobal = {}
	for row in GameInfo.Building_ClassesNeededGlobal( thisBuildingClassType ) do
		local buildingUnlocked = GameInfo.Buildings[ row.BuildingType ]
		SetKey( buildingsUnlockedGlobal, buildingUnlocked and buildingUnlocked.BuildingClass )
	end
	items = {}
	for buildingUnlocked in pairs(buildingsUnlockedGlobal) do
		buildingUnlocked = GetCivBuilding( activeCivilizationType, buildingUnlocked )
		if buildingUnlocked then
			insert( items, BuildingColor( L(buildingUnlocked.Description) ) )
		end
	end
	if #items > 0 then
		insert( tips, L"TXT_KEY_BUILDIND_UNLOCKED_GLOBAL_SP" .. " " .. concat( items, ", ") )
	end


	-- Built <> Buiding Class Count
	local countText = {};
	if activePlayer then
	    if activePlayer:GetBuildingClassCount( buildingClassID ) == 0 and activePlayer:GetBuildingClassMaking( buildingClassID ) == 0 then
	    else
		if activePlayer:GetBuildingClassCount( buildingClassID ) > 0 then
			insert( countText, "[NEWLINE]"..L( "TXT_KEY_ACTION_CLASS_BUILT_COUNT", activePlayer:GetBuildingClassCount( buildingClassID ) ) );
			if activePlayer:GetBuildingClassMaking( buildingClassID ) > 0 then
				append( countText, " <> " .. L( "TXT_KEY_ACTION_CLASS_BUILDING_COUNT", activePlayer:GetBuildingClassMaking( buildingClassID ) ) );
			end
		else
			insert( countText, "[NEWLINE]"..L( "TXT_KEY_ACTION_CLASS_BUILDING_COUNT", activePlayer:GetBuildingClassMaking( buildingClassID ) ) );
		end
	    end
	end
	if #countText > 0 then
		insert( tips, concat( countText, "") );
	end

	-- Limited number can be built
	if #countText == 0 and (maxGlobalInstances > 0 or maxTeamInstances > 0 or maxPlayerInstances > 0) then
		append( tips, "[NEWLINE]" );
	end
	if maxGlobalInstances > 0 then
		if Game and ( Game.IsBuildingClassMaxedOut( buildingClassID ) or Game.GetBuildingClassCreatedCount( buildingClassID ) > 0 ) then
			local buildingCount = Game.IsBuildingClassMaxedOut( buildingClassID ) and maxGlobalInstances or Game.GetBuildingClassCreatedCount( buildingClassID );
			for playerID = 0, GameDefines.MAX_CIV_PLAYERS - 1 do -- GameDefines.MAX_CIV_PLAYERS because city state may have captured wonder city
				if buildingCount <= 0 then
					break;
				end
				local player = Players[playerID];
				if player and player:IsAlive() and player:GetBuildingClassCount( buildingClassID ) > 0 then
					buildingCount = buildingCount - player:GetBuildingClassCount( buildingClassID );
					for city in player:Cities() do
						if city:GetNumBuilding( buildingID ) > 0 then
							local builderID = city:GetBuildingOriginalOwner( buildingID );
							local buildTime = city:GetBuildingOriginalTime( buildingID );
							local builder = Players[ builderID ] or player
							insert( tips, (playerID == activePlayerID and "[COLOR_POSITIVE_TEXT]" or "[COLOR_BUILDING_TEXT]")..L( "TXT_KEY_WONDER_SCENARIO_BUILT_BY", builderID == activePlayerID and "TXT_KEY_YOU" or (activeTeam:IsHasMet(builder:GetTeam()) and builder:GetName()) or "TXT_KEY_UNMET_PLAYER", city:Plot():IsRevealed( activeTeamID ) and city:GetName() or "TXT_KEY_RO_WR_UNKNOWN_HOLY_CITY" )..", "..( buildTime < 0 and L("TXT_KEY_TIME_BC", -buildTime) or L("TXT_KEY_TIME_AD", buildTime) ).."[ENDCOLOR]" )
						end
					end
				end
			end
			if buildingCount > 0 then
				insert( tips, "[COLOR_WARNING_TEXT]"..L"TXT_KEY_RAZED_CITY".."[ENDCOLOR]" );
			end
		end
		append( tips, "[COLOR_YELLOW]" .. L( "TXT_KEY_NO_ACTION_GAME_COUNT_MAX", maxGlobalInstances ) .. "[ENDCOLOR]" );
	end
	if maxTeamInstances > 0 then
		append( tips, "[COLOR_YELLOW]" .. L( "TXT_KEY_NO_ACTION_TEAM_COUNT_MAX", maxTeamInstances ) .. "[ENDCOLOR]" );
	end
	if maxPlayerInstances > 0 then
		append( tips, "[COLOR_YELLOW]" .. L( "TXT_KEY_NO_ACTION_PLAYER_COUNT_MAX", maxPlayerInstances ) .. "[ENDCOLOR]" );
	end

	-- Pre-written Help text
	return AddPreWrittenHelpTextAndConcat( tips, building )
end

-------------------------------------------------
-- Help text for Improvements
-------------------------------------------------
function GetHelpTextForImprovement( improvementID )
	local improvement = GameInfo.Improvements[ improvementID ]

	local thisImprovementType = { ImprovementType = improvement.Type or -1 }
	local ItemBuild = GameInfo.Builds( thisImprovementType )()
	local tip, items, item, condition

	-- Name
	local tips = { Locale_ToUpper( TextColor( "[COLOR_GREEN]", L(improvement.Description) ) ) }
	
	insert( tips, "----------------" )

	-- Maintenance:
	if (improvement[g_maintenanceCurrency] or 0) ~= 0 then
		insert( tips, format( "%s %+i%s", L"TXT_KEY_PEDIA_MAINT_LABEL", -improvement[g_maintenanceCurrency], g_currencyIcon) )
	end

	-- Improved Resources
	items = {}
	for row in GameInfo.Improvement_ResourceTypes( thisImprovementType ) do
		item = GameInfo.Resources[ row.ResourceType ]
		if item then
			insert( items, ResourceString( item ) ) -- item.IconString
		end
	end
	if #items > 0  then
		insert( tips, L"TXT_KEY_PEDIA_IMPROVES_RESRC_LABEL" .. " " .. concat( items, ", " ) )
	end

	-- Yields
	items = {}
	for row in GameInfo.Improvement_Yields( thisImprovementType ) do
		SetKey( items, (row.Yield or 0)~=0 and row.YieldType, format("%s %+i%s", items[ row.YieldType ] or "", row.Yield, YieldIcons[ row.YieldType ] or "?" ) )
	end


	for row in GameInfo.Improvement_FreshWaterYields( thisImprovementType ) do
		SetKey( items, (row.Yield or 0)~=0 and row.YieldType, format( "%s %s %+i%s", items[ row.YieldType ] or "", L"TXT_KEY_ABLTY_FRESH_WATER_STRING", row.Yield, YieldIcons[ row.YieldType ] or "?" ) )
	end
	if IsCiv5BNW then  -- or CivBE ?
		for row in GameInfo.Improvement_YieldPerEra( thisImprovementType ) do
			SetKey( items, (row.Yield or 0)~=0 and row.YieldType, format( "%s %+i%s/%s", items[ row.YieldType ] or "", row.Yield, YieldIcons[ row.YieldType ] or "?", L"TXT_KEY_AD_SETUP_GAME_ERA" ) )
		end
	end
	for yieldType, tip in pairs( items ) do
		item = GameInfo.Yields[ yieldType ]
		if item then
			insert( tips, L(item.Description) .. ":" ..  tip )
		end
	end

	-- Culture
	if IsCiv5Vanilla and (improvement.Culture or 0) ~= 0 then
		insert( tips, format( "%s: %+i[ICON_CULTURE]", L"TXT_KEY_CITYVIEW_CULTURE_TEXT", improvement.Culture ) )
	end

    -- New for Improvement Provide Resource
    if improvement.ImprovementResource ~= nil then
        local item = GameInfo.Resources[improvement.ImprovementResource]
        if improvement.ImprovementResourceQuantity > 0 then
            insert(tips, L(item.Description) .. ":" .. " " .. "+" .. improvement.ImprovementResourceQuantity .. L(item.IconString))
        else
            insert(tips, L(item.Description) .. ":" .. " " .. improvement.ImprovementResourceQuantity .. L(item.IconString))
        end
    end


	-- Mountain Bonus
	--tip = GetYieldString( GameInfo.Improvement_AdjacentMountainYieldChanges( thisImprovementType ) )
	--if #tip>0 then
		--insert( tips, L"TXT_KEY_PEDIA_MOUNTAINADJYIELD_LABEL" .. tip )
	--end

	-- Defense Modifier
   	if (improvement.DefenseModifier or 0)~=0 then
		insert( tips, format( "%s %+i%%[ICON_STRENGTH]", L"TXT_KEY_PEDIA_DEFENSE_LABEL", improvement.DefenseModifier ) )
	end

	
	-- Nearby Enemy Damage
   	if (improvement.NearbyEnemyDamage or 0)~=0 then
		insert( tips, L("TXT_KEY_PEDIA_NEAR_ENEMY_DAMAGE_SP",improvement.NearbyEnemyDamage ))
	end

  	if (improvement.NearbyFriendHeal or 0)~=0 then
		insert( tips,  L("TXT_KEY_PEDIA_NEAR_OUR_HEAL_SP",improvement.NearbyFriendHeal))
	end

	-- -----------------New for Improvement_AdjacentCityYields-------------------------------------------------------
	tip = GetYieldString( GameInfo.Improvement_AdjacentCityYields( thisImprovementType ) )
	if #tip>0 then
		insert( tips, L"TXT_KEY_PEDIA_IMADJCITY_LABEL_SP"..tip)
	end
	-- -----------------New for Improvement_CoastalLandYields--------------------------------------------------------
	tip = GetYieldString( GameInfo.Improvement_CoastalLandYields( thisImprovementType ) )
	if #tip>0 then
		insert( tips, L"TXT_KEY_ABLTY_COASTALAND_SIDE_STRING_SP"..tip)
	end

	-- -----------------New for Improvement_RiverSideYields----------------------------------------------------------
	tip = GetYieldString( GameInfo.Improvement_RiverSideYields( thisImprovementType ) )
	if #tip>0 then
		insert( tips, L"TXT_KEY_ABLTY_RIVER_SIDE_STRING_SP"..tip)
	end

	-- -----------------New for Improvement_RouteYieldChanges--------------------------------------------------------
	items = {}
	condition = { ImprovementType = improvement.Type }
	for row in GameInfo.Improvement_RouteYieldChanges( thisImprovementType ) do
		SetKey( items, row.RouteType )
	end
	for routeType in pairs( items ) do
		item = GameInfo.Routes[ routeType ]
		if item then
			condition.RouteType = routeType
			tip = GetYieldString( GameInfo.Improvement_RouteYieldChanges( condition ) )
			if tip~="" then
				insert( tips, "[ICON_BULLET]" .. TechColor( L(item.Description) ) .. tip )
			end
		end
	end

	-- -----------------New for Improvement_FeatureYieldChanges------------------------------------------------------

	-- -----------------New for Improvement_AdjacentTerrainYieldChanges----------------------------------------------

	-- -----------------New for Improvement_AdjacentFeatureYieldChanges----------------------------------------------

	-- -----------------New for Improvement_AdjacentResourceYieldChanges---------------------------------------------

	-- -----------------New for Improvement_AdjacentImprovementYieldChanges------------------------------------------

	-- Tech yield changes
	items = {}
	condition = { ImprovementType = improvement.Type }
	for row in GameInfo.Improvement_TechYieldChanges( thisImprovementType ) do
		SetKey( items, row.TechType )
	end
	for techType in pairs( items ) do
		item = GameInfo.Technologies[ techType ]
		if item then
			condition.TechType = techType
			tip = GetYieldString( GameInfo.Improvement_TechYieldChanges( condition ) )
			if tip~="" then
				insert( tips, "[ICON_BULLET]" .. TechColor( L(item.Description) ) .. tip )
			end
		end
	end
	items = {}
	for row in GameInfo.Improvement_TechFreshWaterYieldChanges( thisImprovementType ) do
		SetKey( items, row.TechType )
	end
	for techType in pairs( items ) do
		item = GameInfo.Technologies[ techType ]
		if item then
			condition.TechType = techType
			tip = GetYieldString( GameInfo.Improvement_TechFreshWaterYieldChanges( condition ) )
			if tip~="" then
				insert( tips, "[ICON_BULLET]" .. TechColor( L(item.Description) ) .. " (" .. L"TXT_KEY_ABLTY_FRESH_WATER_STRING" .. ")" .. tip )
			end
		end
	end
	items = {}
	for row in GameInfo.Improvement_TechNoFreshWaterYieldChanges( thisImprovementType ) do
		SetKey( items, row.TechType )
	end
	for techType in pairs( items ) do
		item = GameInfo.Technologies[ techType ]
		if item then
			condition.TechType = techType
			tip = GetYieldString( GameInfo.Improvement_TechNoFreshWaterYieldChanges( condition ) )
			if tip~="" then
				insert( tips, "[ICON_BULLET]" .. TechColor( L(item.Description) ) .. " (" .. L"TXT_KEY_ABLTY_NO_FRESH_WATER_STRING" .. ")" .. tip )
			end
		end
	end

	-- Policy yield changes
	items = {}
	condition = { ImprovementType = improvement.Type }
	for row in GameInfo.Policy_ImprovementYieldChanges( thisImprovementType ) do
		SetKey( items, row.PolicyType )
	end
	for row in GameInfo.Policy_ImprovementCultureChanges( thisImprovementType ) do
		SetKey( items, row.PolicyType )
	end
	for policyType in pairs( items ) do
		item = GameInfo.Policies[ policyType ]
		if item then
			tip = ""
			condition.PolicyType = policyType
			tip = GetYieldString( GameInfo.Policy_ImprovementYieldChanges( condition ) )
			for row in GameInfo.Policy_ImprovementCultureChanges( condition ) do
				if (row.CultureChange or 0)~=0 then
					tip = format( "%s %+i[ICON_CULTURE]", tip, row.CultureChange )
				end
			end
			if tip~="" then
				insert( tips, "[ICON_BULLET]" .. PolicyColor( L(item.Description) ) .. tip )
			end
		end
	end

	-- Belief yield changes
	if g_isReligionEnabled then
		items = {}
		condition = { ImprovementType = improvement.Type }
		for row in GameInfo.Belief_ImprovementYieldChanges( thisImprovementType ) do
			SetKey( items, row.BeliefType )
		end
		for beliefType in pairs( items ) do
			item = GameInfo.Beliefs[ beliefType ]
			if item then
				condition.BeliefType = beliefType
				tip = GetYieldString( GameInfo.Belief_ImprovementYieldChanges( condition ) )
				if tip~="" then
					insert( tips, "[ICON_BULLET]" .. BeliefColor( L(item.ShortDescription) ) .. tip )
				end
			end
		end

	end

	-- Resource Yields
	local thisImprovementAndResourceTypes = { ImprovementType = improvement.Type or -1 }
	for resource in GameInfo.Resources() do
		thisImprovementAndResourceTypes.ResourceType = resource.Type or -1
		tip = GetYieldString( GameInfo.Improvement_ResourceType_Yields( thisImprovementAndResourceTypes ) )
		if #tip > 0 then
			insert( tips, ResourceString( resource ) .. ":" .. tip )
		end
	end

	insert( tips, "----------------" )

	-- Civ Requirement
	if improvement.SpecificCivRequired and improvement.CivilizationType then
		item = GameInfo.Civilizations[ improvement.CivilizationType ]
		insert( tips, L"TXT_KEY_PEDIA_CIVILIZATIONS_LABEL".." "..(item and L(item.ShortDescription) or "???") )
	end

	-- Tech Requirements
	item = ItemBuild and ItemBuild.PrereqTech and GameInfo.Technologies[ ItemBuild.PrereqTech ]
	if item and item.ID > 0  then
		insert( tips, L"TXT_KEY_PEDIA_PREREQ_TECH_LABEL" .. " " .. TechColor( L(item.Description) ) )
	end



	------------------------New for ObsoleteTech------------------------------------------------------------------------
	item = ItemBuild and ItemBuild.ObsoleteTech and GameInfo.Technologies[ ItemBuild.ObsoleteTech ]
	if item and item.ID > 0  then
	insert( tips, L"TXT_KEY_PEDIA_IMPROVEMENT_OBSOLETE_TECH_LABEL_SP" .. " " .. TechColor( L(item.Description) ) )
	end



	-- Terrain
	items = {}
	for row in GameInfo.Improvement_ValidTerrains( thisImprovementType ) do
		item = GameInfo.Terrains[ row.TerrainType ]
		if item then
			insert( items, L(item.Description) )
		end
	end
	for row in GameInfo.Improvement_ValidFeatures( thisImprovementType ) do
		item = GameInfo.Features[ row.FeatureType ]
		if item then
			insert( items, L(item.Description) )
		end
	end
	if IsCiv5BNW then -- or CivBE ?
		for row in GameInfo.Improvement_ValidImprovements( thisImprovementType ) do
			item = GameInfo.Improvements[ row.PrereqImprovement ]
			if item then
				insert( items, L(item.Description) )
			end
		end
	end
	for row in GameInfo.Improvement_ResourceTypes( thisImprovementType ) do
		item = GameInfo.Resources[ row.ResourceType ]
		if item and row.ResourceMakesValid then
			insert( items, ResourceString( item ) )
		end
	end
--	if improvement.HillsMakesValid then insert( items, L( (GameInfo.Terrains.TERRAIN_HILL or {}).Description) ) end -- hackery for hills
	if #items > 0  then
		insert( tips, L"TXT_KEY_PEDIA_FOUNDON_LABEL" .. " " .. concat( items, ", " ) )
	end

--[[
	-- Upgrade
	item = improvement.ImprovementUpgrade and GameInfo.Improvements[ improvement.ImprovementUpgrade ]
-- TODO xml text
	if item then
		insert( tips, L"" .. " " .. L(item.Description) )
	end
--]]
	-- Pre-written Help text
	return AddPreWrittenHelpTextAndConcat( tips, improvement )
end

-- ===========================================================================
-- Help text for Projects
-- ===========================================================================
function GetHelpTextForProject( projectID, bIncludeRequirements, city )
	local project = GameInfo.Projects[ projectID ]
	local maxGlobalInstances = project and tonumber(project.MaxGlobalInstances) or 0
	local maxTeamInstances = project and tonumber(project.MaxTeamInstances) or 0
	local CityMaxNum = project and tonumber(project.CityMaxNum) or 0
	local Maintenance = project and tonumber(project.Maintenance) or 0

	-- Name & Cost
	local productionCost = 0
	if city ~= nil then
		productionCost = city:GetProjectProductionNeeded(projectID)
	else
		productionCost = (Game and Players[Game.GetActivePlayer()]:GetProjectProductionNeeded(projectID)) or project.Cost
	end
	local tips = { Locale_ToUpper( project.Description or "???" ), "----------------", L"TXT_KEY_PEDIA_COST_LABEL" .. " " .. productionCost .. "[ICON_PRODUCTION]" }


	-- New for Unit Maintenance
	if  Maintenance > 0 then
		insert( tips, L"TXT_KEY_GOLD_COST_LABEL_SP"..-Maintenance .."[ICON_GOLD]" )
	end

	-- Requirements?
	if project.Requirements then
		insert( tips, L( project.Requirements ) )
	end

	if maxGlobalInstances > 0 or maxTeamInstances > 0 or CityMaxNum > 0 then
		append( tips, "[NEWLINE]" );
	end

	-- Limited number can be built
	if maxGlobalInstances > 0 then
		append( tips, "[COLOR_YELLOW]" .. L( "TXT_KEY_NO_ACTION_GAME_COUNT_MAX", maxGlobalInstances ) .. "[ENDCOLOR]" );
	end
	if maxTeamInstances > 0 then
		append( tips, "[COLOR_YELLOW]" .. L( "TXT_KEY_NO_ACTION_TEAM_COUNT_MAX", maxTeamInstances ) .. "[ENDCOLOR]" );
	end
	if CityMaxNum > 0 then
		append( tips, "[COLOR_YELLOW]" .. L( "TXT_KEY_NO_ACTION_CITY_COUNT_MAX_SP", CityMaxNum ) .. "[ENDCOLOR]" );
	end

	-- Pre-written Help text
	return AddPreWrittenHelpTextAndConcat( tips, project )
end

-- ===========================================================================
-- Help text for Processes
-- ===========================================================================
function GetHelpTextForProcess( processID )
	local process = GameInfo.Processes[ processID ]

	-- Name
	local tips = { Locale_ToUpper( process.Description or "???" ), "----------------" }
	for row in GameInfo.Process_ProductionYields{ ProcessType = process.Type } do
		local yield = GameInfo.Yields[ row.YieldType ]
		local percent = yield and tonumber( row.Yield ) or 0
		if percent == 0 then
		else
			insert( tips, format( "%s = %i%%([ICON_PRODUCTION])", yield.IconString, percent ) )
		end
	end
	-- League Project text
	local activeLeague = IsCiv5BNW and Game and not Game.IsOption("GAMEOPTION_NO_LEAGUES") and Game.GetActiveLeague()
	if activeLeague then
		for row in GameInfo.LeagueProjects{ Process = process.Type } do
			insert( tips, L( "TXT_KEY_LEAGUE_PROJECT_POPUP_TOTAL_COST", activeLeague:GetProjectCost(row.ID )/100 ) )
			insert( tips, activeLeague:GetProjectDetails( row.ID, Game.GetActivePlayer() ) )
		end
	end

	-- Pre-written Help text
	return AddPreWrittenHelpTextAndConcat( tips, process )
end


if Game then
	if not ScratchDeal then
		local pairs = pairs
		local print = print
		local insert = table.insert
		local remove = table.remove
		local unpack = unpack or table.unpack -- depends on Lua version

		local TradeableItems = TradeableItems
		local GetPlot = Map.GetPlot
		ScratchDeal = UI.GetScratchDeal()
		local ScratchDeal = ScratchDeal

		local g_savedDealStack = {}

		local g_deal_functions = {
			[ TradeableItems.TRADE_ITEM_MAPS or-1] = function( from )
				return ScratchDeal:AddMapTrade( from )
			end,
			[ TradeableItems.TRADE_ITEM_RESOURCES or-1] = function( from, item )
				return ScratchDeal:AddResourceTrade( from, item[4], item[5], item[2] )
			end,
			[ TradeableItems.TRADE_ITEM_CITIES or-1] = function( from, item )
				local plot = GetPlot( item[4], item[5] )
				local city = plot and plot:GetPlotCity()
				if city and city:GetOwner() == from then
					return ScratchDeal:AddCityTrade( from, city:GetID() )
				else
					print( "Cannot add city trade", city and city:GetName(), unpack(item) )
				end
			end,
			[ TradeableItems.TRADE_ITEM_UNITS or-1] = function( from, item )
				return ScratchDeal:AddUnitTrade( from, item[4] )
			end,
			[ TradeableItems.TRADE_ITEM_OPEN_BORDERS or-1] = function( from, item )
				return ScratchDeal:AddOpenBorders( from, item[2] )
			end,
			[ TradeableItems.TRADE_ITEM_TRADE_AGREEMENT or-1] = function( from, item )
				return ScratchDeal:AddTradeAgreement( from, item[2] )
			end,
			[ TradeableItems.TRADE_ITEM_PERMANENT_ALLIANCE or-1] = function()
				print( "Error - alliance not supported by game DLL")--ScratchDeal:AddPermamentAlliance()
			end,
			[ TradeableItems.TRADE_ITEM_SURRENDER or-1] = function( from )
				return ScratchDeal:AddSurrender( from )
			end,
			[ TradeableItems.TRADE_ITEM_TRUCE or-1] = function()
				print( "Error - truce not supported by game DLL")--ScratchDeal:AddTruce()
			end,
			[ TradeableItems.TRADE_ITEM_PEACE_TREATY or-1] = function( from, item )
				return ScratchDeal:AddPeaceTreaty( from, item[2] )
			end,
			[ TradeableItems.TRADE_ITEM_THIRD_PARTY_PEACE or-1] = function( from, item )
				return ScratchDeal:AddThirdPartyPeace( from, item[4], item[2] )
			end,
			[ TradeableItems.TRADE_ITEM_THIRD_PARTY_WAR or-1] = function( from, item )
				return ScratchDeal:AddThirdPartyWar( from, item[4] )
			end,
			[ TradeableItems.TRADE_ITEM_THIRD_PARTY_EMBARGO or-1] = function( from, item )
				return ScratchDeal:AddThirdPartyEmbargo( from, item[4], item[2] )
			end,
			-- civ5
			[ TradeableItems.TRADE_ITEM_GOLD or-1] = function( from, item )
				return ScratchDeal:AddGoldTrade( from, item[4] )
			end,
			[ TradeableItems.TRADE_ITEM_GOLD_PER_TURN or-1] = function( from, item )
				return ScratchDeal:AddGoldPerTurnTrade( from, item[4], item[2] )
			end,
			[ TradeableItems.TRADE_ITEM_DEFENSIVE_PACT or-1] = function( from, item )
				return ScratchDeal:AddDefensivePact( from, item[2] )
			end,
			[ TradeableItems.TRADE_ITEM_RESEARCH_AGREEMENT or-1] = function( from, item )
				return ScratchDeal:AddResearchAgreement( from, item[2] )
			end,
			[ TradeableItems.TRADE_ITEM_ALLOW_EMBASSY or-1] = function( from )
				return ScratchDeal:AddAllowEmbassy( from )
			end,
			[ TradeableItems.TRADE_ITEM_DECLARATION_OF_FRIENDSHIP or-1] = function( from )
				return ScratchDeal:AddDeclarationOfFriendship( from )
			end,
			[ TradeableItems.TRADE_ITEM_VOTE_COMMITMENT or-1] = function( from, item )
				return ScratchDeal:AddVoteCommitment( from, item[4], item[5], item[6], item[7] )
			end,
			-- civ be
			[ TradeableItems.TRADE_ITEM_ENERGY or-1] = function( from, item )
				return ScratchDeal:AddGoldTrade( from, item[4] )
			end,
			[ TradeableItems.TRADE_ITEM_ENERGY_PER_TURN or-1] = function( from, item )
				return ScratchDeal:AddGoldPerTurnTrade( from, item[4], item[2] )
			end,
			[ TradeableItems.TRADE_ITEM_ALLIANCE or-1] = function( from, item )
				return ScratchDeal:AddAlliance( from, item[2] )
			end,
			[ TradeableItems.TRADE_ITEM_COOPERATION_AGREEMENT or-1] = function( from )
				return ScratchDeal:AddCooperationAgreement( from )
			end,
			[ TradeableItems.TRADE_ITEM_FAVOR or-1] = function( from, item )
				return ScratchDeal:AddFavorTrade( from, item[4] )
			end,
			[ TradeableItems.TRADE_ITEM_RESEARCH_PER_TURN or-1] = function( from, item )
				return ScratchDeal:AddResearchPerTurnTrade( from, item[4], item[2] )
			end,
			-- cdf / cp / cbp
			[ TradeableItems.TRADE_ITEM_VASSALAGE or-1] = function( from )
				return ScratchDeal:AddVassalageTrade( from )
			end,
			[ TradeableItems.TRADE_ITEM_VASSALAGE_REVOKE or-1] = function( from )
				return ScratchDeal:AddRevokeVassalageTrade( from )
			end,
			[ TradeableItems.TRADE_ITEM_TECHS or-1] = function( from, item )
				return ScratchDeal:AddTechTrade( from, item[4] )
			end,
		} g_deal_functions[-1] = nil

		function PushScratchDeal()
		--print("PushScratchDeal")
			-- save curent deal
			local ScratchDeal = ScratchDeal
			local deal = {}
			local item = {
				SetFromPlayer = ScratchDeal:GetFromPlayer(),
				SetToPlayer = ScratchDeal:GetToPlayer(),
				SetSurrenderingPlayer = ScratchDeal:GetSurrenderingPlayer(),
				SetDemandingPlayer = ScratchDeal:GetDemandingPlayer(),
				SetRequestingPlayer = ScratchDeal:GetRequestingPlayer(),
			}
			ScratchDeal:ResetIterator()
			repeat
		--print( unpack(item) )
				insert( deal, item )
				item = { ScratchDeal:GetNextItem() }
			until #item < 1
			insert( g_savedDealStack, deal )
			ScratchDeal:ClearItems()
		end

		function PopScratchDeal()
		--print("PopScratchDeal")
			-- restore saved deal
			local ScratchDeal = ScratchDeal
			ScratchDeal:ClearItems()
			local deal = remove( g_savedDealStack )
			if deal then
				for k,v in pairs( deal[1] ) do
					ScratchDeal[ k ]( ScratchDeal, v )
				end

				for i = 2, #deal do
					local item = deal[ i ]
					local from = item[#item]
					local tradeType = item[1]
					local f = g_deal_functions[ tradeType ]
					if f and ScratchDeal:IsPossibleToTradeItem( from, ScratchDeal:GetOtherPlayer(from), tradeType, item[4], item[5], item[6], item[7] ) then
						f( from, item )
					else
						print( "Cannot restore deal trade", unpack(item) )
					end
				end
		--print( "Restored deal#", #g_savedDealStack ) ScratchDeal:ResetIterator() repeat local item = { ScratchDeal:GetNextItem() } print( unpack(item) ) until #item < 1
			else
				print( "Cannot pop scratch deal" )
			end
		end
	end
	local ScratchDeal = ScratchDeal
	local PushScratchDeal = PushScratchDeal
	local PopScratchDeal = PopScratchDeal

	if not GetCityStateStatusToolTip then
		include "CityStateStatusHelper"
	end
	local GetCityStateStatusToolTip = GetCityStateStatusToolTip
	GetCityStateStatus = function( minorPlayer, majorPlayerID )
		return GetCityStateStatusToolTip( majorPlayerID, minorPlayer:GetID(), true )
	end

	local g_dealDuration = Game.GetDealDuration()
	g_isScienceEnabled = not Game.IsOption(GameOptionTypes.GAMEOPTION_NO_SCIENCE)
	g_isPoliciesEnabled = not Game.IsOption(GameOptionTypes.GAMEOPTION_NO_POLICIES)
	g_isReligionEnabled = not IsCiv5Vanilla and not Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION)

	local function GetCivName( player )
		-- Met
		if Teams[Game.GetActiveTeam()]:IsHasMet(player:GetTeam()) then
			return player:GetCivilizationShortDescription()
		-- Not met
		else
			return L"TXT_KEY_UNMET_PLAYER"
		end
	end

	local function GetLeaderName( player )
		-- You
		if player:GetID() == Game.GetActivePlayer() then
			return L"TXT_KEY_YOU"
		-- Not met
		elseif not Teams[Game.GetActiveTeam()]:IsHasMet(player:GetTeam()) then
			return L"TXT_KEY_UNMET_PLAYER"
		-- Human
		elseif player:IsHuman() then -- Game.IsGameMultiPlayer()
			local n = player:GetNickName()
			if n and n ~= "" then
				return player:GetNickName()
			end
		end
		local n = PreGame.GetLeaderName(player:GetID())
		if n and n ~= "" then
			return L( n )
		else
			n = GameInfo.Leaders[ player:GetLeaderType() ]
			return n and L(n.Description) or "???"
		end
	end

	-- ===========================================================================
	-- Tooltips for Yield & Similar (e.g. Culture)
	-- ===========================================================================

	-- Helper function to build yield tooltip string
	function GetYieldTooltip( city, yieldID, baseYield, totalYield, yieldIconString, strModifiersString )

		yieldIconString = yieldIconString or YieldIcons[yieldID] or "?"
		local tips = {}

		insert( tips, city:GetYieldRateInfoTool(yieldID) )

		-- Food eaten by pop
		if yieldID == YieldTypes.YIELD_FOOD then
			insertLocalizedBulletIfNonZero( tips, "TXT_KEY_FOOD_FROM_TRADE_ROUTES", city:GetYieldRate( yieldID, false ) - city:GetYieldRate( yieldID, true ) )
			strModifiersString = "[NEWLINE][ICON_BULLET]" .. L( "TXT_KEY_YIELD_EATEN_BY_POP", city:FoodConsumption( true, 0 ), yieldIconString ) .. strModifiersString
		end

		-- Modifiers
		if strModifiersString ~= "" then
			insert( tips, "----------------" )
			insert( tips, L( "TXT_KEY_YIELD_BASE", baseYield, yieldIconString ) )
			insert( tips, strModifiersString )
		end
		-- Total
		insert( tips, "----------------" )
		insert( tips, L( totalYield >= 0 and "TXT_KEY_YIELD_TOTAL" or "TXT_KEY_YIELD_TOTAL_NEGATIVE", totalYield, yieldIconString ) )

		return concat( tips, "[NEWLINE]" )

	end
	local GetYieldTooltip = GetYieldTooltip

	-- Yield Tooltip Helper
	function GetYieldTooltipHelper( city, yieldID, yieldIconString )

		return GetYieldTooltip( city, yieldID, city:GetBaseYieldRate( yieldID ) + city:GetYieldPerPopTimes100( yieldID ) * city:GetPopulation() / 100, yieldID == YieldTypes.YIELD_FOOD and city:FoodDifferenceTimes100()/100 or city:GetYieldRateTimes100( yieldID )/100, yieldIconString, city:GetYieldModifierTooltip( yieldID ) )
	end
	local GetYieldTooltipHelper = GetYieldTooltipHelper

	-- FOOD
	function GetFoodTooltip( city )

		local tipText
		local isNoob = not OptionsManager.IsNoBasicHelp()
		local cityPopulation = city:GetPopulation()

		local foodStoredTimes100 = city:GetFoodTimes100()
		local foodPerTurnTimes100 = city:FoodDifferenceTimes100( true )	-- true means size 1 city cannot starve
		local foodThreshold = city:GrowthThreshold()
		local turnsToCityGrowth = city:GetFoodTurnsLeft()

		if foodPerTurnTimes100 < 0 then
			foodThreshold = 0
			turnsToCityGrowth = floor( foodStoredTimes100 / -foodPerTurnTimes100 ) + 1
			tipText = "[COLOR_WARNING_TEXT]" .. cityPopulation - 1 .. "[ENDCOLOR][ICON_CITIZEN]"
			if isNoob then
				tipText = L"TXT_KEY_CITYVIEW_STARVATION_TEXT" .. "[NEWLINE]"
				.. L( "TXT_KEY_PROGRESS_TOWARDS", tipText )
			end
		elseif city:IsForcedAvoidGrowth() then
			tipText = "[ICON_LOCKED]".. cityPopulation .."[ICON_CITIZEN]"
			if isNoob then
				tipText = L"TXT_KEY_CITYVIEW_FOCUS_AVOID_GROWTH_TEXT" .. " " .. tipText
			end
			foodPerTurnTimes100 = 0
		elseif foodPerTurnTimes100 == 0 then
			tipText = "[COLOR_YELLOW]" .. cityPopulation .. "[ENDCOLOR][ICON_CITIZEN]"
			if isNoob then
				tipText = L( "TXT_KEY_PROGRESS_TOWARDS", tipText )
			end
		else
			tipText = "[COLOR_POSITIVE_TEXT]" .. cityPopulation +1 .. "[ENDCOLOR][ICON_CITIZEN]"
			if isNoob then
				tipText = L( "TXT_KEY_PROGRESS_TOWARDS", tipText )
			end
		end

		tipText = GetYieldTooltipHelper( city, YieldTypes.YIELD_FOOD ) .. "[NEWLINE][NEWLINE]" .. tipText .. "  " .. foodStoredTimes100 / 100 .. "[ICON_FOOD]/ " .. foodThreshold .. "[ICON_FOOD][NEWLINE]"

		if foodPerTurnTimes100 == 0 then

			tipText = tipText .. L"TXT_KEY_CITYVIEW_STAGNATION_TEXT"
		else
			local foodOverflowTimes100 = foodPerTurnTimes100 * turnsToCityGrowth + foodStoredTimes100 - foodThreshold * 100

			if turnsToCityGrowth > 1 then
				tipText = format( "%s%s %+g[ICON_FOOD]  ", tipText, L( "TXT_KEY_STR_TURNS", turnsToCityGrowth -1 ), ( foodOverflowTimes100 - foodPerTurnTimes100 ) / 100 )
			end
			tipText =  format( "%s%s%s[ENDCOLOR] %+g[ICON_FOOD]", tipText, foodPerTurnTimes100 < 0 and "[COLOR_WARNING_TEXT]" or "[COLOR_POSITIVE_TEXT]", Locale_ToUpper( L( "TXT_KEY_STR_TURNS", turnsToCityGrowth ) ), foodOverflowTimes100 / 100 )
		end

		if isNoob then
			return L"TXT_KEY_FOOD_HELP_INFO" .. "[NEWLINE]" .. tipText
		else
			return tipText
		end
	end

	-- GOLD
	function GetGoldTooltip( city )

		if IsCiv5 and OptionsManager.IsNoBasicHelp() then
			return GetYieldTooltipHelper( city, YieldTypes.YIELD_GOLD )
		else
			return L"TXT_KEY_GOLD_HELP_INFO" .. "[NEWLINE]" .. GetYieldTooltipHelper( city, YieldTypes.YIELD_GOLD )
		end
	end

	-- SCIENCE
	function GetScienceTooltip( city )

		if g_isScienceEnabled then
			if IsCiv5 and OptionsManager.IsNoBasicHelp() then
				return GetYieldTooltipHelper( city, YieldTypes.YIELD_SCIENCE )
			else
				return L"TXT_KEY_SCIENCE_HELP_INFO" .. "[NEWLINE]" .. GetYieldTooltipHelper( city, YieldTypes.YIELD_SCIENCE )
			end
		else
			return L"TXT_KEY_TOP_PANEL_SCIENCE_OFF_TOOLTIP"
		end
	end

	-- PRODUCTION
	function GetProductionTooltip( city )

		local isNoob = not OptionsManager.IsNoBasicHelp()
		local cityProductionName = city:GetProductionNameKey()
		local tipText = ""
		local productionColor

		local productionPerTurn100 = city:GetCurrentProductionDifferenceTimes100( false, false )	-- food = false, overflow = false
		local productionStored100 = city:GetProductionTimes100() + city:GetCurrentProductionDifferenceTimes100(false, true) - productionPerTurn100
		local productionNeeded = 0
		local productionTurnsLeft = 1

		local unitProductionID = city:GetProductionUnit()
		local buildingProductionID = city:GetProductionBuilding()
		local projectProductionID = city:GetProductionProject()
		local processProductionID = city:GetProductionProcess()

		if unitProductionID ~= -1 then
			productionColor = UnitColor

		elseif buildingProductionID ~= -1 then
			productionColor = BuildingColor

		elseif projectProductionID ~= -1 then
			productionColor = BuildingColor

		elseif processProductionID ~= -1 then
			tipText = GetHelpTextForProcess( processProductionID, false )
		else
			if isNoob then
				tipText = L( "TXT_KEY_CITY_NOT_PRODUCING", city:GetName() )
			else
				tipText = L"TXT_KEY_PRODUCTION_NO_PRODUCTION"
			end
		end

		if productionColor then
			productionNeeded = city:GetProductionNeeded()
			productionTurnsLeft = city:GetProductionTurnsLeft()
			tipText = productionColor( Locale_ToUpper( cityProductionName ) )
			if isNoob then
				tipText = L( "TXT_KEY_PROGRESS_TOWARDS", tipText )
			end
			tipText = tipText .. "  " .. productionStored100 / 100 .. "[ICON_PRODUCTION]/ " .. productionNeeded .. "[ICON_PRODUCTION]"
			if productionPerTurn100 > 0 then

				tipText = tipText .. "[NEWLINE]"

				local productionOverflow100 = productionPerTurn100 * productionTurnsLeft + productionStored100 - productionNeeded * 100
				if productionTurnsLeft > 1 then
					tipText =  format( "%s%s %+g[ICON_PRODUCTION]  ", tipText, L( "TXT_KEY_STR_TURNS", productionTurnsLeft -1 ), ( productionOverflow100 - productionPerTurn100 ) / 100 )
				end
				tipText = format( "%s%s %+g[ICON_PRODUCTION]", tipText, productionColor( Locale_ToUpper( L( "TXT_KEY_STR_TURNS", productionTurnsLeft ) ) ), productionOverflow100 / 100 )
			end
		end
		local strModifiersString = city:GetYieldModifierTooltip( YieldTypes.YIELD_PRODUCTION )
		-- Extra Production from Food (ie. producing Colonists)
		if city:IsFoodProduction() then
			local productionFromFood = city:GetYieldRate( YieldTypes.YIELD_FOOD, false ) - city:FoodConsumption( true, 0 )
			if productionFromFood <= 0 then
				productionFromFood = 0
			elseif productionFromFood <= 2 then
				productionFromFood = productionFromFood * 100
			elseif productionFromFood <= 4 then
				productionFromFood = 200 + (productionFromFood - 2) * 50
			else
				productionFromFood = 300 + (productionFromFood - 4) * 25
			end
			if productionFromFood > 0 then
				strModifiersString = strModifiersString .. L( "TXT_KEY_PRODMOD_FOOD_CONVERSION", productionFromFood / 100 )
			end
		end
		tipText = GetYieldTooltip( city, YieldTypes.YIELD_PRODUCTION, city:GetBaseYieldRate( YieldTypes.YIELD_PRODUCTION ), productionPerTurn100 / 100, "[ICON_PRODUCTION]", strModifiersString ) .. "[NEWLINE][NEWLINE]" .. tipText

		-- Basic explanation of production
		if isNoob then
			return L"TXT_KEY_PRODUCTION_HELP_INFO" .. "[NEWLINE]" .. tipText
		else
			return tipText
		end
	end

	-- CULTURE
	function GetCultureTooltip( city )

		local tips = {}
		local cityOwner = Players[city:GetOwner()]
		local culturePerTurn, cultureStored, cultureNeeded, baseCulturePerTurn
		-- Thanks fo Firaxis Cleverness...
		culturePerTurn = city:GetJONSCulturePerTurn()
		cultureStored = city:GetJONSCultureStored()
		cultureNeeded = city:GetJONSCultureThreshold()
		baseCulturePerTurn = city:GetBaseJONSCulturePerTurn()

		if not OptionsManager.IsNoBasicHelp() then
			insert( tips, L"TXT_KEY_CULTURE_HELP_INFO" )
		end

		insert( tips, city:GetYieldRateInfoTool(YieldTypes.YIELD_CULTURE) )

		-- Base Total
		if baseCulturePerTurn ~= culturePerTurn then
			insert( tips, "----------------" )
			insert( tips, L( "TXT_KEY_YIELD_BASE", baseCulturePerTurn, "[ICON_CULTURE]" ) )
			insert( tips, "" )
		end

		-- Empire Culture modifier
		insertLocalizedBulletIfNonZero( tips, "TXT_KEY_CULTURE_PLAYER_MOD", cityOwner and cityOwner:GetCultureCityModifier() or 0 )

		if IsCiv5 then
			-- City Culture modifier
			insertLocalizedBulletIfNonZero( tips, "TXT_KEY_CULTURE_CITY_MOD", city:GetCultureRateModifier())

			-- Culture Wonders modifier
			insertLocalizedBulletIfNonZero( tips, "TXT_KEY_CULTURE_WONDER_BONUS", city:GetNumWorldWonders() > 0 and cityOwner and cityOwner:GetCultureWonderMultiplier() or 0 )
		end

		-- Puppet modifier
		local puppetMod = city:IsPuppet() and GameDefines.PUPPET_CULTURE_MODIFIER or 0
		if puppetMod ~= 0 then
			append( tips, L( "TXT_KEY_PRODMOD_PUPPET", puppetMod ) )
		end

		---Other modify(Great Works Bouns ...)
  		insert( tips,city:GetYieldModifierTooltip( YieldTypes.YIELD_CULTURE ) )

		-- Total
		insert( tips, "----------------" )
		insert( tips, L( "TXT_KEY_YIELD_TOTAL", culturePerTurn, "[ICON_CULTURE]" ) )

		-- Tile growth
		insert( tips, "" )
		insert( tips, L( "TXT_KEY_CULTURE_INFO", "[COLOR_MAGENTA]" .. cultureStored .. "[ICON_CULTURE][ENDCOLOR]", "[COLOR_MAGENTA]" .. cultureNeeded .. "[ICON_CULTURE][ENDCOLOR]" ) )
		if culturePerTurn > 0 then
			local tipText = ""
			local turnsRemaining =  max(ceil((cultureNeeded - cultureStored ) / culturePerTurn), 1)
			local overflow = culturePerTurn * turnsRemaining + cultureStored - cultureNeeded
			if turnsRemaining > 1 then
				tipText = format( "%s %+g[ICON_CULTURE]  ", L( "TXT_KEY_STR_TURNS", turnsRemaining -1 ), overflow - culturePerTurn )
			end
			insert( tips, format( "%s[COLOR_MAGENTA]%s[ENDCOLOR] %+g[ICON_CULTURE]", tipText, Locale_ToUpper( L( "TXT_KEY_STR_TURNS", turnsRemaining ) ), overflow ) )
		end
		return concat( tips, "[NEWLINE]" )
	end

	-------------------------------------------------
	-- Helper function to build religion tooltip string
	-------------------------------------------------
	function GetReligionTooltip( city )

		if g_isReligionEnabled then

			local tips = {}
			local majorityReligionID = city:GetReligiousMajority()
			local pressureMultiplier = GameDefines.RELIGION_MISSIONARY_PRESSURE_MULTIPLIER or 1

			for religion in GameInfo.Religions() do
				local religionID = religion.ID

				if religionID >= 0 then
					local pressureLevel, numTradeRoutesAddingPressure = city:GetPressurePerTurn(religionID)
					local numFollowers = city:GetNumFollowers(religionID)
					local religionName = L( Game.GetReligionName(religionID) )
					local religionIcon = religion.IconString or "?"

					if pressureLevel > 0 or numFollowers > 0 then

						local religionTip = ""
						if pressureLevel > 0 then
							religionTip = L( "TXT_KEY_RELIGIOUS_PRESSURE_STRING", floor(pressureLevel/pressureMultiplier))
						end

						if numTradeRoutesAddingPressure and numTradeRoutesAddingPressure > 0 then
							religionTip = L( "TXT_KEY_RELIGION_TOOLTIP_LINE_WITH_TRADE", religionIcon, numFollowers, religionTip, numTradeRoutesAddingPressure)
						else
							religionTip = L( "TXT_KEY_RELIGION_TOOLTIP_LINE", religionIcon, numFollowers, religionTip)
						end

						if religionID == majorityReligionID then
							local beliefs
							if religionID > 0 then
								beliefs = Game.GetBeliefsInReligion( religionID )
							else
								beliefs = {Players[city:GetOwner()]:GetBeliefInPantheon()}
							end
							if beliefs then
								local item
								for _, beliefID in pairs( beliefs ) do
									item = GameInfo.Beliefs[ beliefID ]
									religionTip = religionTip .. "[NEWLINE][ICON_BULLET]"..BeliefColor( item and L(item.ShortDescription) )
								end
								insert( tips, 1, religionTip )
							end
						else
							insert( tips, religionTip )
						end
					end

					if city:IsHolyCityForReligion( religionID ) then
						insert( tips, 1, L( "TXT_KEY_HOLY_CITY_TOOLTIP_LINE", religionIcon, religionName) )
					end
				end
			end
			return concat( tips, "[NEWLINE]" )
		else
			return L"TXT_KEY_TOP_PANEL_RELIGION_OFF_TOOLTIP"
		end
	end
	local GetReligionTooltip = GetReligionTooltip

	--------
	-- FAITH
	--------
	function GetFaithTooltip( city )

		if g_isReligionEnabled then
			local tips = {}

			if not OptionsManager.IsNoBasicHelp() then
				insert( tips, L"TXT_KEY_FAITH_HELP_INFO" )
			end

			local iFaithPerTurn = city:GetFaithPerTurn()
			if iFaithPerTurn ~= 0 then
				insert( tips, city:GetYieldRateInfoTool(YieldTypes.YIELD_FAITH) )

				-- Puppet modifier
				insertLocalizedBulletIfNonZero( tips, "TXT_KEY_PRODMOD_PUPPET", city:IsPuppet() and GameDefines.PUPPET_FAITH_MODIFIER or 0 )

				insert( tips, city:GetYieldModifierTooltip( YieldTypes.YIELD_FAITH ) )

				-- Citizens breakdown
				insert( tips, "----------------")
				insert( tips, L( "TXT_KEY_YIELD_TOTAL", city:GetFaithPerTurn(), "[ICON_PEACE]" ) )
				insert( tips, GetReligionTooltip( city ) )
			end
			return concat( tips, "[NEWLINE]" )
		else
			return L"TXT_KEY_TOP_PANEL_RELIGION_OFF_TOOLTIP"
		end
	end

	-- TOURISM
	function GetTourismTooltip(city)
		return city:GetTourismTooltip()
	end

	----------------------------------------------------------------
	-- MAJOR PLAYER MOOD INFO
	----------------------------------------------------------------
	local function addIfNz( v, icon )
		if v and v > 0 then
			return "+"..(v/100)..icon
		else
			return ""
		end
	end
	local function routeBonus( route, d )
		return addIfNz( route[d.."GPT"], g_currencyIcon )
			.. addIfNz( route[d.."Food"], "[ICON_FOOD]" )
			.. addIfNz( route[d.."Production"], "[ICON_PRODUCTION]" )
			.. addIfNz( route[d.."Science"], "[ICON_RESEARCH]" )
	end
	local function inParentheses( duration )
		if duration and duration >= 0 then
			return " (".. duration ..")"
		else
			return ""
		end
	end

	-- MOD by CaptainCWB - Begin
	local relationshipDuration = GameDefines.DOF_EXPIRATION_TIME; -- or GameDefines.DENUNCIATION_EXPIRATION_TIME;
	if not IsCiv5Vanilla then
		-- 'GameInfo.GameSpeeds[ PreGame.GetGameSpeed() ].RelationshipDuration' can't get the "True" value, so we use 'DB.Query' here!
		for row in DB.Query([[SELECT RelationshipDuration FROM GameSpeeds WHERE GameSpeeds.ID = ?]], PreGame.GetGameSpeed()) do
			relationshipDuration = row.RelationshipDuration;
		end
	end
	-- MOD by CaptainCWB - End

	function GetMoodInfo( playerID )
		local player = Players[playerID]
		local teamID = player:GetTeam()
		local team = Teams[teamID]

		-- Player & civ names
		local strInfo = GetCivName(player) .. " (" .. GetLeaderName(player) .. ") "

		-- Always war ?
		if (playerID ~= activePlayerID) and (
			( activeTeam:IsAtWar( teamID )
			and Game.IsOption( GameOptionTypes.GAMEOPTION_NO_CHANGING_WAR_PEACE ) )
			or Game.IsOption(GameOptionTypes.GAMEOPTION_ALWAYS_WAR) )
		then
			return strInfo .. L"TXT_KEY_ALWAYS_WAR_TT"
		end

		-- Era
		local item = GameInfo.Eras[ player:GetCurrentEra() ]
		strInfo = strInfo .. (item and L(item.ShortDescription) or "???")

		-- Tech in Progress
		if teamID == activeTeamID then
			local currentTechID = player:GetCurrentResearch()
			local currentTech = GameInfo.Technologies[currentTechID]
			if currentTech and g_isScienceEnabled then
				strInfo = strInfo .. " [ICON_RESEARCH] " .. TechColor( L(currentTech.Description) )
			end
		else
		-- Mood
			local visibleApproachID = activePlayer:GetApproachTowardsUsGuess(playerID)
			strInfo = strInfo .. " " .. (
			-- At war
			((team:IsAtWar( activeTeamID ) or visibleApproachID == MajorCivApproachTypes.MAJOR_CIV_APPROACH_WAR) and L"TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_WAR")
			-- Denouncing
			or (player:IsDenouncingPlayer( activePlayerID ) and L"TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_DENOUNCING")
			-- Resurrected
			or (not IsCiv5Vanilla and player:WasResurrectedThisTurnBy( activePlayerID ) and L"TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_LIBERATED")
			-- Appears Hostile
			or (visibleApproachID == MajorCivApproachTypes.MAJOR_CIV_APPROACH_HOSTILE and L"TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_HOSTILE")
			-- Appears Guarded
			or (visibleApproachID == MajorCivApproachTypes.MAJOR_CIV_APPROACH_GUARDED and L"TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_GUARDED")
			-- Appears Afraid
			or (visibleApproachID == MajorCivApproachTypes.MAJOR_CIV_APPROACH_AFRAID and L"TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_AFRAID")
			-- Appears Friendly
			or (visibleApproachID == MajorCivApproachTypes.MAJOR_CIV_APPROACH_FRIENDLY and L"TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_FRIENDLY")
			-- Neutral - default string
			or L"TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_NEUTRAL" ) .. "[/COLOR]"
		end

		-- Techs Known
		local tips = {}
		-- Policies
		for policyBranch in GameInfo.PolicyBranchTypes() do
			local policyCount = 0

			for policy in GameInfo.Policies() do
				if policy.PolicyBranchType == policyBranch.Type and player:HasPolicy(policy.ID) then
					policyCount = policyCount + 1
				end
			end

			if policyCount > 0 then
				insert( tips, policyCount .. " " .. PolicyColor( Locale_ToLower(policyBranch.Description or "???") ) )
			end
		end
		-- Religion Founded
		if g_isReligionEnabled then
			local religionID = player:GetReligionCreatedByPlayer()
			if religionID > 0 then
				item = GameInfo.Religions[ religionID ]
				insert( tips, (item and item.IconString or "?")..BeliefColor( L("TXT_KEY_RO_STATUS_FOUNDER", Game.GetReligionName( religionID ) ) ) )
			end
		end
		tips = { strInfo, concat( tips, ", ") }

		-- Wonders
		local wonders = {}
		for building in GameInfo.Buildings() do
			item = GameInfo.BuildingClasses[building.BuildingClass]
			if item and ( item.MaxGlobalInstances or 0 ) > 0 and player:CountNumBuildings(building.ID) > 0 then
				insert( wonders, BuildingColor( L(building.Description) ) )
			end
		end
		table.sort(wonders)
		local project = {}
		for iProject in GameInfo.Projects() do
			if team:GetProjectCount(iProject.ID) > 0
			then
				if iProject.MaxGlobalInstances == 1 then
					insert( project, BuildingColor(L(iProject.Description)))
				elseif iProject.MaxTeamInstances == 1 then
					insert( project, BuildColor(L(iProject.Description)))
				end
			end
		end
		table.sort(project)
		-- Population
		insert( tips, 
				team:GetTeamTechs():GetNumTechsKnown() .. " " .. TechColor( Locale_ToLower("TXT_KEY_VP_TECH") ) 
				.. ", "
				.. player:GetTotalPopulation() .. "[ICON_CITIZEN]"
				.. ", "
				.. L("{1} {1: plural 1?{TXT_KEY_CITY:lower}; 2?{TXT_KEY_VP_CITIES:lower};}", player:GetNumCities() )
				.. "[NEWLINE]"
				.. player:GetNumWorldWonders() .. " " .. L("{TXT_KEY_VP_WONDERS:lower}")
				.. (#wonders>0 and ": " .. concat( wonders, ", " ) or "")
				.. "[NEWLINE]"
				.. #project .. " " .. L("{TXT_KEY_WONDER_SECTION_3:lower}")
				.. (#project>0 and ": " .. concat( project, ", " ) or ""))
		--[[ too much info
		local cities = {}
		for city in player:Cities() do
			-- Name & population
			local cityTxt = format("%i[ICON_CITIZEN] %s", city:GetPopulation(), city:GetName())
			if city:IsCapital() then
				cityTxt = "[ICON_CAPITAL]" .. cityTxt
			end
			-- Wonders
			local wonders = {}
			for building in GameInfo.Buildings() do
				if city:IsHasBuilding(building.ID) and GameInfo.BuildingClasses[building.BuildingClass].MaxGlobalInstances > 0 then
					insert( wonders, L(building.Description) )
				end
			end
			if #wonders > 0 then
				cityTxt = cityTxt .. " (" .. concat( wonders, ", ") .. ")"
			end
			insert( cities, cityTxt )
		end
		if #cities > 1 then
			insert( tips, #cities .. " " .. L"TXT_KEY_DIPLO_CITIES":lower() .. " : " .. concat( cities, ", ") )
		elseif #cities ==1 then
			insert( tips, cities[1] )
		end
		--]]

		-- Gold (can be seen in diplo relation ship)
		insert( tips, format( "%i%s(%+i)", player:GetGold(), g_currencyIcon, player:CalculateGoldRate() ) )


		--------------------------------------------------------------------
		-- Loop through the active player's current deals
		--------------------------------------------------------------------

		local isTradeable, isActiveDeal
		local dealsFinalTurn = {}
		local deals = {}
		local tradeRoutes = {}
		local opinions = {}
		local treaties = {}
		local currentTurn = Game.GetGameTurn() -1
		local isUs = playerID == activePlayerID
		local bnw_be = IsCiv5BNW

		local function GetDealTurnsRemaining( itemID )
			local turnsRemaining
			if bnw_be and itemID == TradeableItems.TRADE_ITEM_DECLARATION_OF_FRIENDSHIP then -- DoF or Denounced special kinky case
				turnsRemaining = relationshipDuration - activePlayer:GetDoFCounter( playerID )
				if activePlayer:IsDenouncedPlayer( playerID ) then
					turnsRemaining = relationshipDuration - activePlayer:GetDenouncedPlayerCounter( playerID );
				end
			elseif itemID then
				local finalTurn = dealsFinalTurn[ itemID ]
				if finalTurn then
					turnsRemaining = finalTurn - currentTurn
				end
			end
			return inParentheses( isActiveDeal and turnsRemaining )
		end

		local dealItems = {}
		local finalTurns = {}
		PushScratchDeal()
		for i = 0, GetNumCurrentDeals( activePlayerID ) - 1 do
			LoadCurrentDeal( activePlayerID, i )
			local toPlayerID = ScratchDeal:GetOtherPlayer( activePlayerID )
			ScratchDeal:ResetIterator()
			repeat
				local itemID, duration, finalTurn, data1, data2, data3, flag1, fromPlayerID = ScratchDeal:GetNextItem()
				if itemID then
					if not bnw_be then
						fromPlayerID = data3
					end
					if isUs or toPlayerID == playerID or fromPlayerID == playerID then
	--					finalTurn = finalTurn - currentTurn
						local isFromUs = fromPlayerID == activePlayerID
						local dealItem = dealItems[ finalTurn ]
						if not dealItem then
							dealItem = {}
							dealItems[ finalTurn ] = dealItem
							insert( finalTurns, finalTurn )
						end
						if itemID == TradeableItems.TRADE_ITEM_GOLD_PER_TURN then
							dealItem.GPT = (dealItem.GPT or 0) + (isFromUs and -data1 or data1)
						elseif itemID == TradeableItems.TRADE_ITEM_RESOURCES then
							dealItem[data1] = (dealItem[data1] or 0) + (isFromUs and -data2 or data2)
						else
							dealsFinalTurn[ itemID + (isFromUs and 65536 or 0) ] = finalTurn
						end
					end
				else
					break
				end
			until false
		end
		PopScratchDeal()
		sort( finalTurns )
		for i = 1, #finalTurns do
			local finalTurn = finalTurns[i]
			local dealItem = dealItems[ finalTurn ] or {}
	--todo!
			local deal = {}
			local quantity = dealItem.GPT
			if quantity and quantity ~= 0 then
				insert( deal, format( "%+g%s", quantity, g_currencyIcon ) )
			end
			for resource in GameInfo.Resources() do
				local quantity = dealItem[ resource.ID ]
				if (quantity or 0) ~= 0 then
					insert( deal, format( "%+i%s", quantity, resource.IconString or "?" ) )
				end
			end
			if #deal > 0 then
				insert( deals, concat( deal ) .. "("..( finalTurn - currentTurn )..")" )
			end
		end

		--[[ too much info
		local tip
		if bnw_be then
			for _, route in ipairs( activePlayer:GetTradeRoutes() ) do
				if isUs or route.ToID == playerID then
					tip = "   [ICON_INTERNATIONAL_TRADE]" .. route.FromCityName .. " "
							.. routeBonus( route, "From" )
							.. "[ICON_MOVES]" .. route.ToCityName
					if route.ToID == activePlayerID then
						tip = tip .. " ".. routeBonus( route, "To" )
					end
					insert( tradeRoutes, tip .. " ("..(route.TurnsLeft-1)..")" )
				end
			end
			for _, route in ipairs( activePlayer:GetTradeRoutesToYou() ) do
				if isUs or route.FromID == playerID then
					insert( tradeRoutes, "   [ICON_INTERNATIONAL_TRADE]" .. route.FromCityName .. "[ICON_MOVES]" .. route.ToCityName .. " " .. routeBonus( route, "To" ) )
				end
			end
		end
		]]

		if isUs then

			-- Resources available for trade
			local luxuries = {}
			local strategic = {}
			for resource in GameInfo.Resources() do
				local i = activePlayer:GetNumResourceAvailable( resource.ID, false )
				if i > 0 then
					if resource.ResourceClassType == "RESOURCECLASS_LUXURY" then
						insert( luxuries, " " .. activePlayer:GetNumResourceAvailable( resource.ID, true ) .. ResourceString( resource ) )
					elseif resource.ResourceClassType ~= "RESOURCECLASS_BONUS" then
						insert( strategic, " " .. i .. ResourceString( resource ) )
					end
				end
			end
	-- todo !!!
			if #luxuries > 0 then
				insert( tips, "[ICON_BULLET]" .. L"TXT_KEY_LUXURIES_SHORT" .. ":" .. concat(luxuries))
			end
			if #strategic > 0 then
				insert( tips, "[ICON_BULLET]" .. L"TXT_KEY_STRATEGIC_SHORT" .. ":" .. concat(strategic))
			end

		else  --if teamID ~= activeTeamID then

			local visibleApproachID = activePlayer:GetApproachTowardsUsGuess(playerID)

			if activeTeam:IsAtWar( teamID ) then	-- At war right now

				insert( opinions, L"TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_WAR" )

			else	-- Not at war right now

				-- Resources available from them
				local luxuries = {}
				local strategic = {}
				for resource in GameInfo.Resources() do
					if ScratchDeal:IsPossibleToTradeItem( playerID, activePlayerID, TradeableItems.TRADE_ITEM_RESOURCES, resource.ID, 1 ) then	-- 1 here is 1 quantity of the Resource, which is the minimum possible
						tip = "  " .. player:GetNumResourceAvailable( resource.ID, false ) .. ResourceString( resource )
						if resource.ResourceClassType == "RESOURCECLASS_LUXURY" then
							insert( luxuries, tip )
						else
							insert( strategic, tip )
						end
					end
				end
				if #luxuries > 0 then
					insert( tips, "[ICON_BULLET]" .. L"TXT_KEY_LUXURIES_SHORT" .. ":" .. concat(luxuries))
				end
				if #strategic > 0 then
					insert( tips, "[ICON_BULLET]" .. L"TXT_KEY_STRATEGIC_SHORT" .. ":" .. concat(strategic))
				end

				-- Resources they would like from us
				luxuries = {}
				strategic = {}
				for resource in GameInfo.Resources() do
					if ScratchDeal:IsPossibleToTradeItem( activePlayerID, playerID, TradeableItems.TRADE_ITEM_RESOURCES, resource.ID, 1 ) then	-- 1 here is 1 quantity of the Resource, which is the minimum possible
						if resource.ResourceClassType == "RESOURCECLASS_LUXURY" then
							insert( luxuries, " " .. activePlayer:GetNumResourceAvailable( resource.ID, true ) .. ResourceString( resource ) )
						else
							insert( strategic, " " .. activePlayer:GetNumResourceAvailable( resource.ID, false ) .. ResourceString( resource ) )
						end
					end
				end
				if #luxuries > 0 or #strategic > 0 then
					insert( tips, "----------------" .. "[NEWLINE][COLOR_POSITIVE_TEXT]" .. L"TXT_KEY_DIPLO_YOUR_ITEMS_LABEL" .. "[ENDCOLOR]")
					if #luxuries > 0 then
						insert( tips, "[ICON_BULLET]" .. L"TXT_KEY_LUXURIES_SHORT" .. ":" .. concat(luxuries))
					end
					if #strategic > 0 then
						insert( tips, "[ICON_BULLET]" .. L"TXT_KEY_STRATEGIC_SHORT" .. ":" .. concat(strategic))
					end
					insert( tips, "----------------")
				end

				-- Treaties
				local peaceTurnExpire = dealsFinalTurn[ TradeableItems.TRADE_ITEM_PEACE_TREATY ]
				if peaceTurnExpire and peaceTurnExpire > currentTurn then
					insert( treaties, "[ICON_PEACE]" .. L( "TXT_KEY_DIPLO_PEACE_TREATY", peaceTurnExpire - currentTurn ) )
				end
				if not IsCiv5Vanilla then

					-- Embassy to them
					isTradeable = ScratchDeal:IsPossibleToTradeItem( activePlayerID, playerID, TradeableItems.TRADE_ITEM_ALLOW_EMBASSY, g_dealDuration )
					isActiveDeal = team:HasEmbassyAtTeam( activeTeamID )

					if isTradeable or isActiveDeal then
						insert( treaties, negativeOrPositiveTextColor[isActiveDeal] .. "[ICON_CAPITAL]"
								.. L"TXT_KEY_DIPLO_ALLOW_EMBASSY":lower()
								.. "[ENDCOLOR]" .. GetDealTurnsRemaining( TradeableItems.TRADE_ITEM_ALLOW_EMBASSY + 65536 ) -- 65536 means from us
						)
					end

					-- Embassy from them
					isTradeable = ScratchDeal:IsPossibleToTradeItem( playerID, activePlayerID, TradeableItems.TRADE_ITEM_ALLOW_EMBASSY, g_dealDuration )
					isActiveDeal = activeTeam:HasEmbassyAtTeam( teamID )

					if isTradeable or isActiveDeal then
						insert( treaties, negativeOrPositiveTextColor[isActiveDeal]
								.. L"TXT_KEY_DIPLO_ALLOW_EMBASSY":lower()
								.. "[ICON_CAPITAL][ENDCOLOR]" .. GetDealTurnsRemaining( TradeableItems.TRADE_ITEM_ALLOW_EMBASSY )
						)
					end
				end

				-- Open Borders to them
				isTradeable = ScratchDeal:IsPossibleToTradeItem( activePlayerID, playerID, TradeableItems.TRADE_ITEM_OPEN_BORDERS, g_dealDuration )
				isActiveDeal = activeTeam:IsAllowsOpenBordersToTeam(teamID)

				if isTradeable or isActiveDeal then
					insert( treaties, negativeOrPositiveTextColor[isActiveDeal] .. "<"
							.. L"TXT_KEY_DO_OPEN_BORDERS"
							.. "[ENDCOLOR]" .. GetDealTurnsRemaining( TradeableItems.TRADE_ITEM_OPEN_BORDERS + 65536 ) -- 65536 means from us
					)
				end

				-- Open Borders from them
				isTradeable = ScratchDeal:IsPossibleToTradeItem( playerID, activePlayerID, TradeableItems.TRADE_ITEM_OPEN_BORDERS, g_dealDuration )
				isActiveDeal = team:IsAllowsOpenBordersToTeam( activeTeamID )

				if isTradeable or isActiveDeal then
					insert( treaties, negativeOrPositiveTextColor[isActiveDeal]
							.. L"TXT_KEY_DO_OPEN_BORDERS"
							.. ">[ENDCOLOR]" .. GetDealTurnsRemaining( TradeableItems.TRADE_ITEM_OPEN_BORDERS )
					)
				end

				-- Declaration of Friendship or Denounced
				isTradeable = IsCiv5Vanilla or ScratchDeal:IsPossibleToTradeItem( playerID, activePlayerID, TradeableItems.TRADE_ITEM_DECLARATION_OF_FRIENDSHIP, g_dealDuration )
				isActiveDeal = activePlayer:IsDoF(playerID) or activePlayer:IsDenouncedPlayer(playerID)
				local DoF_Denounced = L"TXT_KEY_DIPLOMACY_FRIENDSHIP_ADV_QUEST";
				if     activePlayer:IsDoF(playerID) then
					DoF_Denounced = L"TXT_KEY_FRIENDS";
				elseif activePlayer:IsFriendDenouncedUs(playerID) then
					DoF_Denounced = L"TXT_KEY_DIPLO_YOU_HAVE_BACKSTABBED";
				elseif activePlayer:IsDenouncedPlayer(playerID) then
					DoF_Denounced = L"TXT_KEY_DIPLO_YOU_HAVE_DENOUNCED";
				end
				if isTradeable or isActiveDeal then
					insert( treaties, negativeOrPositiveTextColor[isActiveDeal] .. "[ICON_FLOWER]"
							.. DoF_Denounced
							.. "[ENDCOLOR]" .. GetDealTurnsRemaining( TradeableItems.TRADE_ITEM_DECLARATION_OF_FRIENDSHIP )
					)
				end

				-- Research Agreement
	--			isTradeable = (activeTeam:IsResearchAgreementTradingAllowed() or team:IsResearchAgreementTradingAllowed())
	--				and not activeTeam:GetTeamTechs():HasResearchedAllTechs() and not team:GetTeamTechs():HasResearchedAllTechs()
	--				and not g_isScienceEnabled
				isTradeable = ScratchDeal:IsPossibleToTradeItem( playerID, activePlayerID, TradeableItems.TRADE_ITEM_RESEARCH_AGREEMENT, g_dealDuration )
				isActiveDeal = activeTeam:IsHasResearchAgreement(teamID)
				if isTradeable or isActiveDeal then
					insert( treaties, negativeOrPositiveTextColor[isActiveDeal] .. "[ICON_RESEARCH]"
							.. L"TXT_KEY_DO_RESEARCH_AGREEMENT"
							.. "[ENDCOLOR]" .. GetDealTurnsRemaining( TradeableItems.TRADE_ITEM_RESEARCH_AGREEMENT )
					)
				end

				-- Trade Agreement
				isTradeable = ScratchDeal:IsPossibleToTradeItem( playerID, activePlayerID, TradeableItems.TRADE_ITEM_TRADE_AGREEMENT, g_dealDuration )
				isActiveDeal = activeTeam:IsHasTradeAgreement(teamID)
				if isTradeable or isActiveDeal then
					insert( treaties, negativeOrPositiveTextColor[isActiveDeal] .. "[ICON_RESEARCH]"
							.. L"TXT_KEY_DIPLO_TRADE_AGREEMENT":lower()
							.. "[ENDCOLOR]" .. GetDealTurnsRemaining( TradeableItems.TRADE_ITEM_TRADE_AGREEMENT )
					)
				end

				-- Defensive Pact
				isTradeable = ScratchDeal:IsPossibleToTradeItem( playerID, activePlayerID, TradeableItems.TRADE_ITEM_DEFENSIVE_PACT, g_dealDuration )
				isActiveDeal = activeTeam:IsDefensivePact(teamID)
				if isTradeable or isActiveDeal then
					insert( treaties, negativeOrPositiveTextColor[isActiveDeal] .. "[ICON_STRENGTH]"
							.. L"TXT_KEY_DO_PACT"
							.. "[ENDCOLOR]" .. GetDealTurnsRemaining( TradeableItems.TRADE_ITEM_DEFENSIVE_PACT )
					)
				end

				-- We've fought before
				if IsCiv5Vanilla and activePlayer:GetNumWarsFought(playerID) > 0 then
					-- They don't appear to be mad
					if visibleApproachID == MajorCivApproachTypes.MAJOR_CIV_APPROACH_FRIENDLY or
						visibleApproachID == MajorCivApproachTypes.MAJOR_CIV_APPROACH_NEUTRAL then
						insert( opinions, L"TXT_KEY_DIPLO_PAST_WAR_NEUTRAL" )
					-- They aren't happy with us
					else
						insert( opinions, L"TXT_KEY_DIPLO_PAST_WAR_BAD" )
					end
				end
			end

			if player.GetOpinionTable then
				opinions = player:GetOpinionTable( activePlayerID )
			else

				-- Good things
				if activePlayer:IsDoF(playerID) then
					insert( opinions, L"TXT_KEY_DIPLO_DOF" )
				end
				-- Human has a mutual friend with the AI
				if activePlayer:IsPlayerDoFwithAnyFriend(playerID) then
					insert( opinions, L"TXT_KEY_DIPLO_MUTUAL_DOF" )
				end
				-- Human has denounced an enemy of the AI
				if activePlayer:IsPlayerDenouncedEnemy(playerID) then
					insert( opinions, L"TXT_KEY_DIPLO_MUTUAL_ENEMY" )
				end
				if player:GetNumCiviliansReturnedToMe(activePlayerID) > 0 then
					insert( opinions, L"TXT_KEY_DIPLO_CIVILIANS_RETURNED" )
				end

				-- Neutral things
				if visibleApproachID == MajorCivApproachTypes.MAJOR_CIV_APPROACH_AFRAID then
					insert( opinions, L"TXT_KEY_DIPLO_AFRAID" )
				end

				-- Bad things

				-- Human was a friend and declared war on us
				if player:IsFriendDeclaredWarOnUs(activePlayerID) then
					insert( opinions, L"TXT_KEY_DIPLO_HUMAN_FRIEND_DECLARED_WAR" )
				end
				-- Human was a friend and denounced us
				if player:IsFriendDenouncedUs(activePlayerID) then
					insert( opinions, L"TXT_KEY_DIPLO_HUMAN_FRIEND_DENOUNCED" )
				end
				-- Human declared war on friends
				if activePlayer:GetWeDeclaredWarOnFriendCount() > 0 then
					insert( opinions, L"TXT_KEY_DIPLO_HUMAN_DECLARED_WAR_ON_FRIENDS" )
				end
				-- Human has denounced his friends
				if activePlayer:GetWeDenouncedFriendCount() > 0 then
					insert( opinions, L"TXT_KEY_DIPLO_HUMAN_DENOUNCED_FRIENDS" )
				end
				-- Human has been denounced by friends
				if activePlayer:GetNumFriendsDenouncedBy() > 0 then
					insert( opinions, L"TXT_KEY_DIPLO_HUMAN_DENOUNCED_BY_FRIENDS" )
				end
				if activePlayer:IsDenouncedPlayer(playerID) then
					insert( opinions, L"TXT_KEY_DIPLO_DENOUNCED_BY_US" )
				end
				if player:IsDenouncedPlayer(activePlayerID) then
					insert( opinions, L"TXT_KEY_DIPLO_DENOUNCED_BY_THEM" )
				end
				if player:IsPlayerDoFwithAnyEnemy(activePlayerID) then
					insert( opinions, L"TXT_KEY_DIPLO_HUMAN_DOF_WITH_ENEMY" )
				end
				if player:IsPlayerDenouncedFriend(activePlayerID) then
					insert( opinions, L"TXT_KEY_DIPLO_HUMAN_DENOUNCED_FRIEND" )
				end
				if player:IsPlayerNoSettleRequestEverAsked(activePlayerID) then
					insert( opinions, L"TXT_KEY_DIPLO_NO_SETTLE_ASKED" )
				end
				if player:IsDemandEverMade(activePlayerID) then
					insert( opinions, L"TXT_KEY_DIPLO_TRADE_DEMAND" )
				end
				if player:GetNumTimesCultureBombed(activePlayerID) > 0 then
					insert( opinions, L"TXT_KEY_DIPLO_CULTURE_BOMB" )
				end
				if player:IsPlayerBrokenMilitaryPromise(activePlayerID) then
					insert( opinions, L"TXT_KEY_DIPLO_MILITARY_PROMISE" )
				end
				if player:IsPlayerIgnoredMilitaryPromise(activePlayerID) then
					insert( opinions, L"TXT_KEY_DIPLO_MILITARY_PROMISE_IGNORED" )
				end
				if player:IsPlayerBrokenExpansionPromise(activePlayerID) then
					insert( opinions, L"TXT_KEY_DIPLO_EXPANSION_PROMISE" )
				end
				if player:IsPlayerIgnoredExpansionPromise(activePlayerID) then
					insert( opinions, L"TXT_KEY_DIPLO_EXPANSION_PROMISE_IGNORED" )
				end
				if player:IsPlayerBrokenBorderPromise(activePlayerID) then
					insert( opinions, L"TXT_KEY_DIPLO_BORDER_PROMISE" )
				end
				if player:IsPlayerIgnoredBorderPromise(activePlayerID) then
					insert( opinions, L"TXT_KEY_DIPLO_BORDER_PROMISE_IGNORED" )
				end
				if player:IsPlayerBrokenCityStatePromise(activePlayerID) then
					insert( opinions, L"TXT_KEY_DIPLO_CITY_STATE_PROMISE" )
				end
				if player:IsPlayerIgnoredCityStatePromise(activePlayerID) then
					insert( opinions, L"TXT_KEY_DIPLO_CITY_STATE_PROMISE_IGNORED" )
				end
				if player:IsPlayerBrokenCoopWarPromise(activePlayerID) then
					insert( opinions, L"TXT_KEY_DIPLO_COOP_WAR_PROMISE" )
				end
				if player:IsPlayerRecklessExpander(activePlayerID) then
					insert( opinions, L"TXT_KEY_DIPLO_RECKLESS_EXPANDER" )
				end
				if player:GetNumRequestsRefused(activePlayerID) > 0 then
					insert( opinions, L"TXT_KEY_DIPLO_REFUSED_REQUESTS" )
				end
				if player:GetRecentTradeValue(activePlayerID) > 0 then
					insert( opinions, L"TXT_KEY_DIPLO_TRADE_PARTNER" )
				end
				if player:GetCommonFoeValue(activePlayerID) > 0 then
					insert( opinions, L"TXT_KEY_DIPLO_COMMON_FOE" )
				end
				if player:GetRecentAssistValue(activePlayerID) > 0 then
					insert( opinions, L"TXT_KEY_DIPLO_ASSISTANCE_TO_THEM" )
				end
				if player:IsLiberatedCapital(activePlayerID) then
					insert( opinions, L"TXT_KEY_DIPLO_LIBERATED_CAPITAL" )
				end
				if player:IsLiberatedCity(activePlayerID) then
					insert( opinions, L"TXT_KEY_DIPLO_LIBERATED_CITY" )
				end
				if player:IsGaveAssistanceTo(activePlayerID) then
					insert( opinions, L"TXT_KEY_DIPLO_ASSISTANCE_FROM_THEM" )
				end
				if player:IsHasPaidTributeTo(activePlayerID) then
					insert( opinions, L"TXT_KEY_DIPLO_PAID_TRIBUTE" )
				end
				if player:IsNukedBy(activePlayerID) then
					insert( opinions, L"TXT_KEY_DIPLO_NUKED" )
				end
				if player:IsCapitalCapturedBy(activePlayerID) then
					insert( opinions, L"TXT_KEY_DIPLO_CAPTURED_CAPITAL" )
				end
				-- Protected Minors
				if player:GetOtherPlayerNumProtectedMinorsKilled(activePlayerID) > 0 then
					insert( opinions, L"TXT_KEY_DIPLO_PROTECTED_MINORS_KILLED" )
				-- Only worry about protected minors ATTACKED if they haven't KILLED any
				elseif player:GetOtherPlayerNumProtectedMinorsAttacked(activePlayerID) > 0 then
					insert( opinions, L"TXT_KEY_DIPLO_PROTECTED_MINORS_ATTACKED" )
				end

				--local actualApproachID = player:GetMajorCivApproach(activePlayerID)

				-- Bad things we don't want visible if someone is friendly (acting or truthfully)
				if visibleApproachID ~= MajorCivApproachTypes.MAJOR_CIV_APPROACH_FRIENDLY then
					-- and actualApproachID ~= MajorCivApproachTypes.MAJOR_CIV_APPROACH_DECEPTIVE then
					if player:GetLandDisputeLevel(activePlayerID) > DisputeLevelTypes.DISPUTE_LEVEL_NONE then
						insert( opinions, L"TXT_KEY_DIPLO_LAND_DISPUTE" )
					end
					--if player:GetVictoryDisputeLevel(activePlayerID) > DisputeLevelTypes.DISPUTE_LEVEL_NONE then insert( opinions, L"TXT_KEY_DIPLO_VICTORY_DISPUTE" ) end
					if player:GetWonderDisputeLevel(activePlayerID) > DisputeLevelTypes.DISPUTE_LEVEL_NONE then
						insert( opinions, L"TXT_KEY_DIPLO_WONDER_DISPUTE" )
					end
					if player:GetMinorCivDisputeLevel(activePlayerID) > DisputeLevelTypes.DISPUTE_LEVEL_NONE then
						insert( opinions, L"TXT_KEY_DIPLO_MINOR_CIV_DISPUTE" )
					end
					if player:GetWarmongerThreat(activePlayerID) > ThreatTypes.THREAT_NONE then
						insert( opinions, L"TXT_KEY_DIPLO_WARMONGER_THREAT" )
					end
				end
			end

			--  No specific events - let's see what string we should use
			if #opinions == 0 then
				-- At war
				if visibleApproachID == MajorCivApproachTypes.MAJOR_CIV_APPROACH_WAR then
					opinions = { L"TXT_KEY_DIPLO_AT_WAR" }
				-- Appears Friendly
				elseif visibleApproachID == MajorCivApproachTypes.MAJOR_CIV_APPROACH_FRIENDLY then
					opinions = { L"TXT_KEY_DIPLO_FRIENDLY" }
				-- Appears Guarded
				elseif visibleApproachID == MajorCivApproachTypes.MAJOR_CIV_APPROACH_GUARDED then
					opinions = { L"TXT_KEY_DIPLO_GUARDED" }
				-- Appears Hostile
				elseif visibleApproachID == MajorCivApproachTypes.MAJOR_CIV_APPROACH_HOSTILE then
					opinions = { L"TXT_KEY_DIPLO_HOSTILE" }
				-- Appears Affraid
				elseif visibleApproachID == MajorCivApproachTypes.MAJOR_CIV_APPROACH_AFRAID  then
					opinions = { L"TXT_KEY_DIPLO_AFRAID" }
				-- Neutral - default string
				else
					opinions = { L"TXT_KEY_DIPLO_DEFAULT_STATUS" }
				end
			end

		end -- playerID vs activePlayerID

	--TODO "TXT_KEY_DO_WE_PROVIDE" & "TXT_KEY_DO_THEY_PROVIDE"
		if #deals > 0 then
			insert( tips, L"TXT_KEY_DO_CURRENT_DEALS" .. "[NEWLINE]" .. concat( deals, ", " ) )
		end
		if #tradeRoutes > 0 then
			insert( tips, concat( tradeRoutes, "[NEWLINE]" ) )
		end
		if #treaties > 0 then
			insert( tips, concat( treaties, ", " ) .. "[ENDCOLOR]" )
		end
		if #opinions > 0 then
			insert( tips, "[ICON_BULLET]" .. concat( opinions, "[NEWLINE][ICON_BULLET]" ) .. "[ENDCOLOR]" )
		end

		local allied = {}
		local friends = {}
		local protected = {}
		local denouncements = {}
		local backstabs = {}
		local denouncedBy = {}
		local wars = {}

		-- Relationships with others
		for otherPlayerID = 0, GameDefines.MAX_CIV_PLAYERS - 1 do
			local otherPlayer = Players[otherPlayerID]
			local otherTeamID = otherPlayer:GetTeam()
			if otherPlayer
			and otherPlayerID ~= playerID
			and otherPlayer:IsAlive()
			and activeTeam:IsHasMet(otherTeamID)
			then
				local otherPlayerName =  GetCivName(otherPlayer)
				if otherPlayerID == Game.GetActivePlayer() then
					otherPlayerName = L"TXT_KEY_YOU"
				end
				-- Wars
				if team:IsAtWar(otherTeamID) then
					insert( wars, otherPlayerName )
				end
				if otherPlayer:IsMinorCiv() then
					-- Alliances
					if otherPlayer:IsAllies(playerID) then
						insert( allied, otherPlayerName )
					-- Friendships
					elseif otherPlayer:IsFriends(playerID) then
						insert( friends, otherPlayerName )
					end
					-- Protections
					if player:IsProtectingMinor(otherPlayerID) then
						insert( protected, otherPlayerName .. inParentheses( not IsCiv5Vanilla and isUs and ( otherPlayer:GetTurnLastPledgedProtectionByMajor(playerID) - Game.GetGameTurn() + 10 ) ) )  -- todo check scaling % game speed
					end
				else
					-- Defensive pacts
					if team:IsDefensivePact(otherTeamID) then
						insert( allied, otherPlayerName )
					end
					-- Friendships
					if player:IsDoF(otherPlayerID) then
						insert( friends, otherPlayerName .. inParentheses( bnw_be and ( relationshipDuration - player:GetDoFCounter( otherPlayerID ) ) ) )
					end
					-- Backstab
					if otherPlayer:IsFriendDenouncedUs(playerID) or otherPlayer:IsFriendDeclaredWarOnUs(playerID) then
						insert( backstabs, otherPlayerName )
					end
					-- Denouncement
					if player:IsDenouncedPlayer(otherPlayerID) then
						insert( denouncements, otherPlayerName .. inParentheses( bnw_be and ( relationshipDuration - player:GetDenouncedPlayerCounter( otherPlayerID ) ) ) )
					end
					-- Denounced by 3rd party
					if otherPlayer:IsDenouncedPlayer(playerID) then
						insert( denouncedBy, otherPlayerName .. inParentheses( bnw_be and ( relationshipDuration - otherPlayer:GetDenouncedPlayerCounter( playerID ) ) ) )
					end
				end
			end
		end

		if #allied > 0 then
			insert( tips, "[ICON_STRENGTH]" .. L( "TXT_KEY_ALLIED_WITH", concat( allied, ", ") ) )
		end
		if #friends > 0 then
			insert( tips, "[ICON_FLOWER]" .. L( "TXT_KEY_DIPLO_FRIENDS_WITH", concat( friends, ", ") ) )
		end
		if #protected > 0 then
			insert( tips, "[ICON_CITY_STATE]" .. L"TXT_KEY_POP_CSTATE_PLEDGE_TO_PROTECT" .. ": " .. concat( protected, ", ") )
		end
		if #backstabs > 0 then
			insert( tips, "[ICON_PIRATE]" .. L( "TXT_KEY_DIPLO_BACKSTABBED", concat( backstabs, ", ") ) )
		end
		if #denouncements > 0 then
			insert( tips, "[ICON_DENOUNCE]" .. L( "TXT_KEY_DIPLO_DENOUNCED", concat( denouncements, ", ") ) )
		end
		if #denouncedBy > 0 then
			insert( tips, "[ICON_DENOUNCE]" .. TextColor( negativeOrPositiveTextColor[false], L( "TXT_KEY_NTFN_DENOUNCED_US_S", concat( denouncedBy, ", ") ) ) )
		end
		if #wars > 0 then
			insert( tips, "[ICON_WAR]" .. L( "TXT_KEY_AT_WAR_WITH", concat( wars, ", ") ) )
		end

		return concat( tips, "[NEWLINE]" )
	end
end