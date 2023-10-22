--------------------------------------------------------------
-- Policy_FreeBuildingClass
-- Author: Machiavelli
-- Revisor: CaptainCWB, Qingyin
-- DateCreated: 5/23/2012 6:10:34 PM
-- DateModified_1: 4/23/2016 10:19:34 AM
-- DateModified_2:12/27/2020 02:09:00 AM
--------------------------------------------------------------
-------------
-- Purpose: -
-------------
-- This lua supports the new Policy_FreeBuildingClass* tables
--
------------
-- Design: -
------------
-- Buildings are added when:
-- Whenever a new policy is adopted every city gets all policy buildings.
-- When a new city is founded or captured, it gets all policy buildings.
-- There is special code for handling capital only buildings,
--
-- Buildings are removed when:
-- Each turn at the start of the turn all buildings which are granted by
-- blocked policies and do not have IsRemovedWhenPolicyBlocked == false
-- are removed.
--
-------------------
-- How to expand: -
-------------------
-- If you want to support new xml tables (such as adding a building in 
-- coastal cities) you will need to write code in two spots.
--
-- 1) "Add new Policy_FreeBuilding tables here"
-- Marks the location where you will need to add buildings.  Use the
-- city state code but with a different test in the initial if statement
-- and change the GameInfo table to the new xml table.
--
-- 2) "Remove new Policy_FreeBuilding tables here"
-- Marks the location where you will need to remove buildings.  Use the
-- city state code but with a different test in the initial if statement
-- and change the GameInfo table to the new xml table.
--
------------------------------
-- Known bugs / limitations: -
------------------------------
-- 1) Switching back and forth between mutually exclusive policy branches
-- without adopting a new policy will not enable the newly unblocked policy
-- buildings.
-- 
-----------------------------------------------------
-- Notes to self: How this should have been written -
-----------------------------------------------------
-- 1) Lists of buildings to add/remove should be built once
-- 2) Than used to call addListOfBuildings(cityID, list)
--
-- 1) The end turn check should test to see if the previous player is in anarchy.
-- 2) Only remove buildings if the previous player is in anarchy.

local tablePolicy_FreeBuildingClass = GameInfo.Policy_FreeBuildingClass
local tablePolicy_FreeBuildingClassCapital = GameInfo.Policy_FreeBuildingClassCapital
local tablePolicy_FreeBuildingClassCityStates = GameInfo.Policy_FreeBuildingClassCityStates

if #tablePolicy_FreeBuildingClassCapital == 0
and #tablePolicy_FreeBuildingClassCityStates == 0
and #tablePolicy_FreeBuildingClass == 0 
then
	print("New Policy Free BuildingClass: All Table Empty!!!")
	return
end

--------------------
-- functions that add buildings
--------------------
function AddPolicyBuildingsToCity(playerID, cityID)
	if Players[playerID] == nil or Players[playerID]:GetCityByID(cityID) == nil then
		return;
	end
	local player = Players[playerID];
	local city = player:GetCityByID(cityID);
	local policyID;
	local buildingType;

	------------------------------------------------
	-- Add buildings for Policy_FreeBuildingClass --
	------------------------------------------------
	for row in GameInfo.Policy_FreeBuildingClass() do
		policyID = GameInfoTypes[row.PolicyType];

		if (player:HasPolicy(policyID) and not player:IsPolicyBlocked(policyID)) then
			city:SetNumRealBuilding(player:GetCivBuilding(GameInfoTypes[row.BuildingClassType]), row.Count);
		end
	end
	----------------------------------------------------------
	-- Add buildings for Policy_FreeBuildingClassCityStates --
	----------------------------------------------------------
	if(Players[city:GetOriginalOwner()]:IsMinorCiv()) then
		for row in GameInfo.Policy_FreeBuildingClassCityStates() do
			policyID = GameInfoTypes[row.PolicyType];

			if (player:HasPolicy(policyID) and not player:IsPolicyBlocked(policyID)) then
				city:SetNumRealBuilding(player:GetCivBuilding(GameInfoTypes[row.BuildingClassType]), row.Count);
			end
		end
	end
	---------------------------------------------
	-- Add new Policy_FreeBuilding tables here --
	---------------------------------------------
end

function AddPolicyBuildingsToCapital(playerID)
	local player = Players[playerID];
	local capital = player:GetCapitalCity();
	local policyID;
	local buildingType;
	
	-- Avoid "Complete Kills" CTD!
	if capital == nil then
		return;
	end

	for row in GameInfo.Policy_FreeBuildingClassCapital() do
		policyID = GameInfoTypes[row.PolicyType];

		if (player:HasPolicy(policyID) and not player:IsPolicyBlocked(policyID)) then
			capital:SetNumRealBuilding(player:GetCivBuilding(GameInfoTypes[row.BuildingClassType]), row.Count);
		end
	end
end

--------------------
-- functions that call the building adders
--------------------
function PolicyBuildingOnCityFound(playerID, iX, iY)
	-- Args are: playerID and cityID
	if Players[playerID] == nil or Map.GetPlot(iX, iY) == nil or not Map.GetPlot(iX, iY):IsCity() then
		return;
	end
	
	AddPolicyBuildingsToCity(playerID, Map.GetPlot(iX, iY):GetPlotCity():GetID());
end
GameEvents.PlayerCityFounded.Add(PolicyBuildingOnCityFound);

function PolicyBuildingOnCityCapture(oldPlayerID, bCapital, iX, iY, newPlayerID, conquest, conquest2)
	if Players[oldPlayerID] == nil or Players[newPlayerID] == nil or Map.GetPlot(iX, iY) == nil or not Map.GetPlot(iX, iY):IsCity() then
		return;
	end
	local oldPlayer = Players[oldPlayerID];
	local newPlayer = Players[newPlayerID];
	local city =  Map.GetPlot(iX, iY):GetPlotCity();

	-- If the old player just lost their capital, they will need to have their capital-only policy buildings replaced
	if(bCapital and oldPlayer:IsAlive() and not oldPlayer:IsMinorCiv() and not oldPlayer:IsBarbarian()) then
		AddPolicyBuildingsToCapital(oldPlayerID);
	end

	-- If the new player just recovered their capital, they will need to have their capital-only policy buildings moved
	if(newPlayer:GetCapitalCity() ~= nil and newPlayer:GetCapitalCity():GetID() == city:GetID()) then
		local policyID;
		local buildingTypeID;
		-- Remove capital only buildings from the new player's cities
		for cityToRemove in newPlayer:Cities() do
			for row in GameInfo.Policy_FreeBuildingClassCapital() do
				policyID = GameInfoTypes[row.PolicyType];
				-- Only remove the building if the player has the policy, but it is disabled
				if(newPlayer:HasPolicy(policyID)) then
					-- Determine what buildingType to remove based on the buildingClass
					buildingTypeID = newPlayer:GetCivBuilding(GameInfoTypes[row.BuildingClassType]);

					-- If the city has the building, remove it
					if(cityToRemove:IsHasBuilding(buildingTypeID)) then
						-- Remove any specialists from the building
						local iCount = GameInfo.Buildings[buildingType].SpecialistCount;
						local i = 0;
						while(cityToRemove:GetNumSpecialistsInBuilding(buildingTypeID) > 0 and i < iCount) do
							local iSpecialist = GameInfoTypes[GameInfo.Buildings[buildingTypeID].SpecialistType];
							cityToRemove:DoTask(TaskTypes.TASK_REMOVE_SPECIALIST, iSpecialist, buildingTypeID, playerID);
							i = i + 1;
						end
						-- Remove the building
						cityToRemove:SetNumRealBuilding(buildingTypeID, 0);
					end
				end
			end
		end
		-- Add back the capital-only policy buildings
		AddPolicyBuildingsToCapital(newPlayerID);
	end

	-- Add the new player's policy buildings to the city they just captured
	AddPolicyBuildingsToCity(newPlayerID, city:GetID());
end
GameEvents.CityCaptureComplete.Add(PolicyBuildingOnCityCapture);

function PolicyBuildingOnAdoptPolicy(playerID, policyTypeID)
	AddPolicyBuildingsToCapital(playerID);

	for city in Players[playerID]:Cities() do
		AddPolicyBuildingsToCity(playerID, city:GetID());
	end
end
GameEvents.PlayerAdoptPolicy.Add(PolicyBuildingOnAdoptPolicy);
GameEvents.PlayerAdoptPolicyBranch.Add(PolicyBuildingOnAdoptPolicy);

--------------------
-- functions for removing buildings
--------------------
function ResetPolicyFreeBuildings(playerID,iPolicyBranch,isBlock)
	local player = Players[playerID];
	if player == nil or not player:IsMajorCiv() or not isBlock then
		return;
	end
	local capital = player:GetCapitalCity();
	local policyID;
	local buildingTypeID;

	print("Player Block a Policy tree, remove blocked policy building and set available building")

	--------------------------------------------------------
	-- Remove any blocked Policy_FreeBuildingClassCapital --
	--------------------------------------------------------
	if capital ~= nil then
		for row in GameInfo.Policy_FreeBuildingClassCapital() do
			policyID = GameInfoTypes[row.PolicyType];
			
			-- Only remove the building if the player has the policy, but it is disabled and the building gets removed
			if(player:HasPolicy(policyID) and player:IsPolicyBlocked(policyID)) then
				-- Determine what buildingType to remove based on the buildingClass
				buildingTypeID = player:GetCivBuilding(GameInfoTypes[row.BuildingClassType]);
				
				-- If the city has the building, remove it
				if(capital:IsHasBuilding(buildingTypeID)) then
					-- Remove any specialists from the building
					local iCount = GameInfo.Buildings[buildingTypeID].SpecialistCount;
					local i = 0;
					local iSpecialist = GameInfoTypes[GameInfo.Buildings[buildingTypeID].SpecialistType];
					while(capital:GetNumSpecialistsInBuilding(buildingTypeID) > 0 and i < iCount) do
						capital:DoTask(TaskTypes.TASK_REMOVE_SPECIALIST, iSpecialist, buildingTypeID, playerID);
						i = i + 1;
					end
					-- Remove the building
					capital:SetNumRealBuilding(buildingTypeID, 0);
				end
			end
		end
		AddPolicyBuildingsToCapital(playerID)
	end
	-------------------------------------------------
	for city in player:Cities() do
		-------------------------------------------------
		-- Remove any blocked Policy_FreeBuildingClass --
		-------------------------------------------------
		for row in GameInfo.Policy_FreeBuildingClass() do
			policyID = GameInfoTypes[row.PolicyType];

			if(player:HasPolicy(policyID) and player:IsPolicyBlocked(policyID) and row.IsRemovedWhenPolicyBlocked) then
				buildingTypeID = player:GetCivBuilding(GameInfoTypes[row.BuildingClassType]);
				if(city:IsHasBuilding(buildingTypeID)) then
					-- Remove any specialists from the building
					local iCount = GameInfo.Buildings[buildingTypeID].SpecialistCount;
					local i = 0;
					local iSpecialist = GameInfoTypes[GameInfo.Buildings[buildingTypeID].SpecialistType];
					while(city:GetNumSpecialistsInBuilding(buildingTypeID) > 0 and i < iCount) do
						city:DoTask(TaskTypes.TASK_REMOVE_SPECIALIST, iSpecialist, buildingTypeID, playerID);
						i = i + 1;
					end
					city:SetNumRealBuilding(buildingTypeID, 0);
				end
			end
		end
		-----------------------------------------------------------
		-- Remove any blocked Policy_FreeBuildingClassCityStates --
		-----------------------------------------------------------
		if(Players[city:GetOriginalOwner()]:IsMinorCiv()) then
			for row in GameInfo.Policy_FreeBuildingClassCityStates() do
				policyID = GameInfoTypes[row.PolicyType];
				if(player:HasPolicy(policyID) and player:IsPolicyBlocked(policyID) and row.IsRemovedWhenPolicyBlocked) then
					buildingTypeID = player:GetCivBuilding(GameInfoTypes[row.BuildingClassType]);
					if(city:IsHasBuilding(buildingTypeID)) then
						-- Remove any specialists from the building
						local iCount = GameInfo.Buildings[buildingTypeID].SpecialistCount;
						local i = 0;
						local iSpecialist = GameInfoTypes[GameInfo.Buildings[buildingTypeID].SpecialistType];
						while(city:GetNumSpecialistsInBuilding(buildingTypeID) > 0 and i < iCount) do
							city:DoTask(TaskTypes.TASK_REMOVE_SPECIALIST, iSpecialist, buildingTypeID, playerID);
							i = i + 1;
						end
						city:SetNumRealBuilding(buildingTypeID, 0);
					end
				end
			end
		end
		AddPolicyBuildingsToCity(playerID, city:GetID());
		------------------------------------------------
		-- Remove new Policy_FreeBuilding tables here --
		------------------------------------------------
	end -- for city in player:Cities() do
end
GameEvents.PlayerBlockPolicyBranch.Add(ResetPolicyFreeBuildings);


print("New Policy Free BuildingClass Check Pass!")
