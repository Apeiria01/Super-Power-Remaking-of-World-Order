
local COMPLETE  = 0; -- Successfully completed this task
local DISMISSED = 1; -- Tutorial display was seen and dismissed by player
local INVALID   = 2; -- Missed the boat on this task
local ACTIVE    = 3; -- This task can be evaluated
local INACTIVE  = 4; -- This task cannot currently be evaluated

local ADVISOR_SCIENCE  = AdvisorTypes.ADVISOR_SCIENCE;
local ADVISOR_ECONOMIC = AdvisorTypes.ADVISOR_ECONOMIC;
local ADVISOR_FOREIGN  = AdvisorTypes.ADVISOR_FOREIGN;
local ADVISOR_MILITARY = AdvisorTypes.ADVISOR_MILITARY;

-- utility functions
function GetPlayer ()
	local iPlayerID = Game.GetActivePlayer();
	if (iPlayerID < 0) then
		return nil;
	end

	local player = Players[iPlayerID];
	if (player ~= nil and player:IsHuman()) then
		return player
	end;
	
	return nil;
end

function CheckHasTech(techType)
	return function()
		local player = GetPlayer();
		if(player == nil) then
			return INACTIVE;
		end
		
		local team = Teams[player:GetTeam()];
		if(team == nil) then
			return INACTIVE;
		end
		
		if(techType == nil) then
			return ACTIVE;
		end
		local techID = GameInfo.Technologies[techType].ID;
		if(team:IsHasTech(techID)) then
			return ACTIVE;
		end
	
		return INACTIVE;
	end
end


function GetUnitClassID(unitClassType)
	local unitClass = GameInfo.UnitClasses[unitClassType];
	if(unitClass ~= nil) then
		return unitClass.ID;
	end
end
	
function CreateFirstUnitOfUnitClassCheck(unitClassType)
	local unitClassID = GetUnitClassID(unitClassType);
	
	if(unitClassID ~= nil) then
		return function()
			local player = GetPlayer();
			if(player == nil) then
				return INACTIVE;
			end
			
			if(player:HasUnitOfClassType(unitClassID)) then
				return ACTIVE;
			else
				return INACTIVE;
			end
		end
	end
end

function CheckHasTourism()
	local player = GetPlayer();
	
	if(player == nil) then
		return INACTIVE;
	end
	
	if(player:GetTourism() > 0) then
		return ACTIVE;
	else
		return INACTIVE;
	end
end

function CheckCanPropose()
	local player = GetPlayer();
	
	if(player == nil) then
		return INACTIVE;
	end
	
	local playerID = player:GetID();
	
	for leagueID = 0, Game.GetNumActiveLeagues() - 1, 1 do
		local league = Game.GetLeague(leagueID);
		if(league:IsMember(playerID) and league:CanPropose(playerID)) then
			return ACTIVE;
		end
	end
	
	return INACTIVE;
end

if(TutorialInfo ~= nil) then

	-- Culture Overview
	table.insert(TutorialInfo, {
		ID = "CULTURE_OVERVIEW",
		Advisor = ADVISOR_FOREIGN,
		ButtonPopupType = ButtonPopupTypes.BUTTONPOPUP_CULTURE_OVERVIEW,
		Modal = true,		
		TutorialLevel = 3,
		Concept1 = "CONCEPT_CULTURE_TOURISM",
		Concept2 = "CONCEPT_CULTURE_TOURISM_AND_CULTURE",
		Concept3 = "CONCEPT_CULTURE_GREAT_WORKS",
	});
	
	
	local caravanUnit = GameInfo.Units["UNIT_CARAVAN"];
	if(caravanUnit ~= nil) then	
		-- First Caravan
		table.insert(TutorialInfo, { 
			ID = "FIRST_CARAVAN",		
			Advisor = ADVISOR_ECONOMIC,
			TutorialLevel = 3,
			CheckFunction = CheckHasTech(caravanUnit.PrereqTech),
			TurnTimeCheck = 2,
			Concept1 = "CONCEPT_TRADE_ROUTES",
			Concept2 = "CONCEPT_TRADE_CARAVAN",
			Concept3 = "CONCEPT_TRADE_CARGO",
		});	
	end
	
	local archUnit = GameInfo.Units["UNIT_ARCHAEOLOGIST"];
	if(archUnit ~= nil) then	
		-- Antiquity Sites
		table.insert(TutorialInfo, { 
			ID = "ARCH",		
			Advisor = ADVISOR_FOREIGN,
			TutorialLevel = 3,
			CheckFunction = CheckHasTech(archUnit.PrereqTech),
			TurnTimeCheck = 2,
			Concept1 = "CONCEPT_CULTURE_ARCH",
			Concept2 = "CONCEPT_CULTURE_ANTIQUITY",
			Concept3 = "CONCEPT_CULTURE_ARTIFACTS",
		});	
	end
	
	local checkFirstGreatWriter = CreateFirstUnitOfUnitClassCheck("UNITCLASS_WRITER");
	if(checkFirstGreatWriter) then
		table.insert(TutorialInfo, {
			ID = "GREAT_WRITER",		
			Advisor = ADVISOR_ECONOMIC, 
			CheckFunction = checkFirstGreatWriter,   
			UnitIndexFunction = nil, 
			MinTurn =  1, 
			TurnsCheck = 1, 
			TutorialLevel = 3,
			TurnTimeCheck = 2,
			Concept1 = "CONCEPT_CULTURE_GREAT_WORK_WRITING",
			Concept2 = "CONCEPT_SPECIALISTS_AND_GREAT_PEOPLE_GREAT_PEOPLE_TREATISE",
			Concept3 = "CONCEPT_CULTURE_TOURISM",
		});
	end
	
	local checkFirstGreatArtist = CreateFirstUnitOfUnitClassCheck("UNITCLASS_ARTIST");
	if(checkFirstGreatArtist) then
		table.insert(TutorialInfo, { 
			ID = "GREAT_ARTIST",		
			Advisor = ADVISOR_ECONOMIC, 
			CheckFunction = checkFirstGreatArtist,   
			UnitIndexFunction = nil, 
			MinTurn =  1, 
			TurnsCheck = 1, 
			TutorialLevel = 3,
			TurnTimeCheck = 2,
			Concept1 = "CONCEPT_CULTURE_GREAT_WORK_ART",
			Concept2 = "CONCEPT_CULTURE_TOURISM",
		});
	end
	
	local checkFirstGreatMusician = CreateFirstUnitOfUnitClassCheck("UNITCLASS_MUSICIAN");
	if(checkFirstGreatMusician) then
		table.insert(TutorialInfo, { 
			ID = "GREAT_MUSICIAN",		
			Advisor = ADVISOR_ECONOMIC, 
			CheckFunction = checkFirstGreatMusician,   
			UnitIndexFunction = nil, 
			MinTurn =  1, 
			TurnsCheck = 1, 
			TutorialLevel = 3,
			TurnTimeCheck = 2,
			Concept1 = "CONCEPT_CULTURE_GREAT_WORK_MUSIC",
			Concept2 = "CONCEPT_SPECIALISTS_AND_GREAT_PEOPLE_GREAT_PEOPLE_CONCERT_TOUR",
			Concept3 = "CONCEPT_CULTURE_TOURISM",
		});
	end
	
	local checkFirstArcheologist = CreateFirstUnitOfUnitClassCheck("UNITCLASS_ARCHEOLOGIST");
	if(checkFirstArcheologist) then
		table.insert(TutorialInfo, {
			ID = "ARCHEOLOGIST",		
			Advisor = ADVISOR_ECONOMIC, 
			CheckFunction = checkFirstArcheologist,   
			UnitIndexFunction = nil, 
			MinTurn =  1, 
			TurnsCheck = 1, 
			TutorialLevel = 3,
			TurnTimeCheck = 2,
			Concept1 = "CONCEPT_CULTURE_ARCH",
			Concept2 = "CONCEPT_CULTURE_ANTIQUITY",
			Concept3 = "CONCEPT_CULTURE_ARTIFACTS",
		});
	end
	
	local writersGuildBuilding = GameInfo.Buildings["BUILDING_WRITERS_GUILD"];
	if(writersGuildBuilding ~= nil) then	
		table.insert(TutorialInfo, { 
			ID = "WRITERS_GUILD",		
			Advisor = ADVISOR_FOREIGN,
			TutorialLevel = 3,
			TurnTimeCheck = 2,
			CheckFunction = CheckHasTech(writersGuildBuilding.PrereqTech),
			Concept1 = "CONCEPT_CULTURE_GREAT_WORK_WRITING",
			Concept2 = "CONCEPT_CULTURE_TOURISM",
			Concept3 = "CONCEPT_CULTURE_TOURISM_AND_CULTURE",
		});	
	end
	
	local artistGuildBuilding = GameInfo.Buildings["BUILDING_ARTISTS_GUILD"];
	if(artistGuildBuilding ~= nil) then	
		table.insert(TutorialInfo, { 
			ID = "ARTISTS_GUILD",		
			Advisor = ADVISOR_FOREIGN,
			TutorialLevel = 3,
			TurnTimeCheck = 2,
			CheckFunction = CheckHasTech(artistGuildBuilding.PrereqTech),
			Concept1 = "CONCEPT_CULTURE_GREAT_WORK_ART",
			Concept2 = "CONCEPT_CULTURE_TOURISM",
			Concept3 = "CONCEPT_CULTURE_TOURISM_AND_CULTURE",
		});	
	end
	
	local musicGuildBuilding = GameInfo.Buildings["BUILDING_MUSICIANS_GUILD"];
	if(musicGuildBuilding ~= nil) then	
		table.insert(TutorialInfo, { 
			ID = "MUSIC_GUILD",		
			Advisor = ADVISOR_FOREIGN,
			TutorialLevel = 3,
			TurnTimeCheck = 2,
			CheckFunction = CheckHasTech(musicGuildBuilding.PrereqTech),
			Concept1 = "CONCEPT_CULTURE_GREAT_WORK_MUSIC",
			Concept2 = "CONCEPT_CULTURE_TOURISM",
			Concept3 = "CONCEPT_CULTURE_TOURISM_AND_CULTURE",
		});	
	end
	
	-- World Congress Founded
	table.insert(TutorialInfo, {
		ID = "CONGRESS_FOUNDED",
		Advisor = ADVISOR_FOREIGN,
		ButtonPopupType = ButtonPopupTypes.BUTTONPOPUP_LEAGUE_SPLASH,
		Modal = true,	
		TutorialLevel = 3,
		Concept1 = "CONCEPT_CONGRESS",
		Concept2 = "CONCEPT_CONGRESS_SESSIONS",
		Concept3 = "CONCEPT_CONGRESS_RESOLUTIONS",
	});
	
	table.insert(TutorialInfo, {
		ID = "CONGRESS_PROPOSE",
		Advisor = ADVISOR_FOREIGN,
		--NotificationType = NotificationTypes.NOTIFICATION_LEAGUE_CALL_FOR_PROPOSALS,   
		ButtonPopupType = ButtonPopupTypes.BUTTONPOPUP_LEAGUE_OVERVIEW,
		CheckFunction = CheckCanPropose,
		Modal = true,		
		TutorialLevel = 3,
		Concept1 = "CONCEPT_CONGRESS_RESOLUTIONS",
		Concept2 = "CONCEPT_CONGRESS_PROJECTS",
		Concept3 = "CONCEPT_CONGRESS_DELEGATES",
	});
	
	table.insert(TutorialInfo, {
		ID = "CONGRESS_VOTE",
		Advisor = ADVISOR_FOREIGN,
		NotificationType = NotificationTypes.NOTIFICATION_LEAGUE_CALL_FOR_VOTES,   
		Modal = true,		
		TutorialLevel = 3,
		Concept1 = "CONCEPT_CONGRESS_DELEGATES",
		Concept2 = "CONCEPT_CONGRESS_TRADING",
		Concept3 = "CONCEPT_CONGRESS_INTRIGUE",
	});
	
	table.insert(TutorialInfo, { 
		ID = "TOURISM",		
		Advisor = ADVISOR_FOREIGN,
		TutorialLevel = 3,
		TurnTimeCheck = 2,
		CheckFunction = CheckHasTourism,
		Concept1 = "CONCEPT_CULTURE_TOURISM",
		Concept2 = "CONCEPT_CULTURE_TOURISM_AND_CULTURE",
	});	
	
	table.insert(TutorialInfo, {
		ID = "CHOOSE_IDEOLOGY",
		Advisor = ADVISOR_FOREIGN,
		NotificationType = NotificationTypes.NOTIFICATION_CHOOSE_IDEOLOGY,   
		Modal = true,		
		TutorialLevel = 3,
		Concept1 = "CONCEPT_SOCIAL_POLICY_BRANCH_IDEOLOGY",
	});
	
	
	table.insert(TutorialInfo, {
		ID = "CHOOSE_ARCHAEOLOGY",
		Advisor = ADVISOR_FOREIGN,
		NotificationType = NotificationTypes.NOTIFICATION_CHOOSE_ARCHAEOLOGY,   
		Modal = true,		
		TutorialLevel = 3,
		Concept1 = "CONCEPT_CULTURE_ARTIFACTS",
		Concept2 = "CONCEPT_CULTURE_TOURISM",
		Concept3 = "",
	});

end