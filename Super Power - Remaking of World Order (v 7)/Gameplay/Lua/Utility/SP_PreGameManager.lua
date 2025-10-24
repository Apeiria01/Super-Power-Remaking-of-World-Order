include("SP_TableSerialization.lua");

-------------------------------------------------
-- Globals
-------------------------------------------------
MOD_ID = "f9b9c8aa-b6d1-4188-9239-c1de2207ab7c";
g_SPUserData = Modding.OpenUserData("SP_Rise_of_Hegemony", Modding.GetActivatedModVersion(MOD_ID));
g_bSaveScriptActive = GameDefines["SP_SAVE_PREGAME_OPTION"] == 1

SPData = {};

-- Load data from DB and Initialize SPData ---------------------------
function SPData:LoadData()
	if not g_bSaveScriptActive then return end
	-- Create database if it doesn't exist.
	for _ in g_SPUserData.Query('CREATE TABLE IF NOT EXISTS SPData(Data TEXT)') do end

	local loadData = {};

	for row in g_SPUserData.Query('SELECT Data FROM SPData') do
		LoadTable(row.Data, loadData);
		break;
	end
	
	self:CopyData(loadData, self);
	
	SPPreGameInitialize()
end

function SPData:SaveData()
	if not g_bSaveScriptActive then return end
	-- Create SPData database if it doesn't exist.
	for _ in g_SPUserData.Query('CREATE TABLE IF NOT EXISTS SPData(Data TEXT)') do end

	-- Clear SPData.
	for _ in g_SPUserData.Query('DELETE FROM SPData') do end;

	-- Create save data.
	local saveData = {};
	saveData.Civilizations = {};
	for i = 0, GameDefines.MAX_MAJOR_CIVS-1 do
		local Civilization = {};
		if PreGame.GetSlotStatus(i) == SlotStatus.SS_COMPUTER then
			local civIndex = PreGame.GetCivilization(i);
			if civIndex ~= -1 then
				Civilization.Type = GameInfo.Civilizations[civIndex].Type
			else
				Civilization.Type = -1;
			end
			Civilization.LeaderName = PreGame.GetLeaderName( i );
			Civilization.Description = PreGame.GetCivilizationDescription( i );
			Civilization.ShortDescription = PreGame.GetCivilizationShortDescription( i );
			Civilization.Adjective = PreGame.GetCivilizationAdjective( i );

			Civilization.TeamID = PreGame.GetTeam(i);
			Civilization.SlotOpen = true;
		else
			Civilization.Type = -1;
			Civilization.TeamID = i;
			Civilization.SlotOpen = false;
		end
		saveData.Civilizations[i] = Civilization
	end
	saveData.NumMinorCivs = PreGame.GetNumMinorCivs();
	saveData.Era = GameInfo.Eras[PreGame.GetEra()].Type;
	saveData.Handicap = GameInfo.HandicapInfos[PreGame.GetHandicap(0)].Type;
	saveData.GameSpeeds = GameInfo.GameSpeeds[PreGame.GetGameSpeed()].Type;
	saveData.MaxTurns = PreGame.GetMaxTurns();
	saveData.WorldSize = GameInfo.Worlds[PreGame.GetWorldSize()].Type;
	saveData.MapScript = PreGame.GetMapScript();
	saveData.IsRandomMapScript = PreGame.IsRandomMapScript();
	saveData.MapScriptOptions = {};
	for option in GameInfo.MapScriptOptions{FileName = PreGame.GetMapScript()} do
		saveData.MapScriptOptions[option.OptionID] = PreGame.GetMapOption(option.OptionID);
	end
	saveData.Victories = {};
	for victory in GameInfo.Victories() do
		saveData.Victories[victory.ID] = PreGame.IsVictory(victory.ID);
	end
	saveData.SPGameOptions = {};
	for option in GameInfo.GameOptions{Visible = 1} do
		saveData.SPGameOptions[option.Type] = PreGame.GetGameOption(option.Type) == 1 or false;
	end
	saveData.IsSaved = true;

	-- Convert saveData to a string.
	local data = SaveTable(saveData);

	-- Save data string.
	for _ in g_SPUserData.Query(string.format('INSERT INTO SPData(Data) VALUES(%q)', data)) do end
end

-- This is used to determine what gets stored in Civ5 UserData.
function SPData:CopyData(from, to)
	to.Civilizations = {}
	for k, v in pairs(from.Civilizations or {}) do
		to.Civilizations[k] = {}
        for sub_k, sub_v in pairs(v) do
            to.Civilizations[k][sub_k] = sub_v
			--print(k, v, sub_k, sub_v)
        end
	end
	to.NumMinorCivs = from.NumMinorCivs;
	to.Era = from.Era;
	to.Handicap = from.Handicap;
	to.GameSpeeds = from.GameSpeeds;
	to.MaxTurns = from.MaxTurns;
	to.WorldSize = from.WorldSize;
	to.MapScript = from.MapScript and string.gsub(from.MapScript, "\\\\", "\\") or nil;
	to.IsRandomMapScript = from.IsRandomMapScript;
	to.MapScriptOptions = {};
	for k, v in pairs(from.MapScriptOptions or {}) do
		to.MapScriptOptions[k] = v;
	end
	to.Victories = {};
	for k, v in pairs(from.Victories or {}) do
		to.Victories[k] = v;
	end
	to.SPGameOptions = {};
	for k, v in pairs(from.SPGameOptions or {}) do
		to.SPGameOptions[k] = v;
	end
	to.IsSaved = from.IsSaved;
end

function SPPreGameInitialize()
	if (SPData.IsSaved == nil) then
		PreGame.SetWorldSize(GameInfo.Worlds["WORLDSIZE_HUGE"].ID);
		PreGame.SetMapScript("Assets\\Maps\\Continents.lua");
		PreGame.SetHandicap(0, GameInfo.HandicapInfos["HANDICAP_DEITY"].ID);
		PreGame.SetGameSpeed(GameInfo.GameSpeeds["GAMESPEED_EPIC"].ID);
		PreGame.SetCivilization(0, -1);
	else
		PreGame.SetWorldSize(GameInfo.Worlds[SPData.WorldSize] and GameInfo.Worlds[SPData.WorldSize].ID or GameInfo.Worlds["WORLDSIZE_HUGE"].ID);
		PreGame.SetMapScript(SPData.MapScript);
		PreGame.SetRandomMapScript(SPData.IsRandomMapScript);
		PreGame.SetEra(GameInfo.Eras[SPData.Era] and GameInfo.Eras[SPData.Era].ID or GameInfo.Eras["ERA_ANCIENT"].ID);
		PreGame.SetHandicap(0, GameInfo.HandicapInfos[SPData.Handicap] and GameInfo.HandicapInfos[SPData.Handicap].ID or GameInfo.HandicapInfos["HANDICAP_DEITY"].ID);
		PreGame.SetGameSpeed(GameInfo.GameSpeeds[SPData.GameSpeeds] and GameInfo.GameSpeeds[SPData.GameSpeeds].ID or GameInfo.GameSpeeds["GAMESPEED_EPIC"].ID);
		PreGame.SetMaxTurns(SPData.MaxTurns);
		for i = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
			local bSoltActive = SPData.Civilizations[i] and SPData.Civilizations[i].SlotOpen
			-- first 2 must be open
			if i < 2 or bSoltActive then
				if(PreGame.GetSlotStatus(i) ~= SlotStatus.SS_COMPUTER) then
					PreGame.SetSlotStatus(i, SlotStatus.SS_COMPUTER);
				end
			else
				if(PreGame.GetSlotStatus(i) == SlotStatus.SS_COMPUTER) then
					PreGame.SetSlotStatus(i, SlotStatus.SS_CLOSED);
				end
			end
			if bSoltActive then
				-- mod Civ that unload
				if SPData.Civilizations[i].Type ~= -1 and not GameInfo.Civilizations[SPData.Civilizations[i].Type] then
					PreGame.SetCivilization(i, -1);
				else
					if GameInfo.Civilizations[SPData.Civilizations[i].Type] then
						PreGame.SetCivilization(i, GameInfo.Civilizations[SPData.Civilizations[i].Type].ID);
					end
					local str = SPData.Civilizations[i].LeaderName
					if str and str ~= "" then PreGame.SetLeaderName( i, str ) end
					str = SPData.Civilizations[i].Description
					if str and str ~= "" then PreGame.SetCivilizationDescription( i, str ) end
					str = SPData.Civilizations[i].ShortDescription
					if str and str ~= "" then PreGame.SetCivilizationShortDescription( i, str ) end
					str = SPData.Civilizations[i].Adjective
					if str and str ~= "" then PreGame.SetCivilizationAdjective( i, str ) end
				end
				PreGame.SetTeam(i, SPData.Civilizations[i].TeamID);
			else
				PreGame.SetCivilization(i, -1);
				PreGame.SetTeam(i, i);
			end
		end
		local maxMinorCivs = math.min((GameDefines.MAX_CIV_PLAYERS - GameDefines.MAX_MAJOR_CIVS), #GameInfo.MinorCivilizations);
		PreGame.SetNumMinorCivs( math.min(SPData.NumMinorCivs, maxMinorCivs) );
		for option in GameInfo.MapScriptOptions{FileName = PreGame.GetMapScript()} do
			PreGame.SetMapOption(option.OptionID, SPData.MapScriptOptions[option.OptionID]);
		end
		for victory in GameInfo.Victories() do
			if SPData.Victories[victory.ID] ~= nil then
				PreGame.SetVictory(victory.ID, SPData.Victories[victory.ID]);
			end
		end
		for option in GameInfo.GameOptions{Visible = 1} do
			if option.Type ~= "GAMEOPTION_QUICK_COMBAT" and option.Type ~= "GAMEOPTION_QUICK_MOVEMENT" then
				PreGame.SetGameOption(option.Type, SPData.SPGameOptions[option.Type]);
			end
		end
	end
end
