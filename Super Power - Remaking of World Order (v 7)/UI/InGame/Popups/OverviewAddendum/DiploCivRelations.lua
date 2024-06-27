-- DiploCivRelations
-- Author: robk
-- Revisor: CaptainCWB
-- DateCreated: 10/8/2010 10:57:08 PM
--------------------------------------------------------------

include("IconSupport");
include("FLuaVector");




-- This is the max number of icons that are available. Since I'm pre-generating all the
-- positions and connectors, this is tied to external program that writes the XML and
-- generates those connectors.

local iconCount = 22;


-- A bunch of colors that I'm defining myself since I may want to make them slightly
-- different than the named colors available. After the color vectors are defined,
-- they're assigned to the various connection types and the key bars are set.

local red = Vector4(.8, .2, .2, 1);
local green = Vector4(0, .8, .2, 1);
local yellow = Vector4(1, 1, 0, 1);
local purple = Vector4(.63, .13, .94, 1);
local violet = Vector4(.93, .51, .93, 1);
local orange = Vector4(1, .65, 0, 1);
local peachpuff = Vector4(.8, .69, .58, 1)
local white = Vector4(1, 1, 1, 1);
local steelblue = Vector4(.27, .51, .71, 1);
local gold = Vector4(.93, .91, .67, 1);

-- text
local redtext = "[COLOR:204:51:51:255]";
local greentext = "[COLOR:0:204:51:255]";
local yellowtext = "[COLOR:255:255:0:255]";
local violettext = "[COLOR:238:130:238:255]";
local purpletext = "[COLOR:160:32:240:255]";
local orangetext = "[COLOR:255:165:0:255]"
local whitetext = "[COLOR:255:255:255:255]";
local peachpufftext = "[COLOR:204:176:148:255]";
local steelbluetext = "[COLOR:69:130:181:255]";
local goldtext = "[COLOR:238:232:170:255]";

-- Political colors
local war_color = red;
local war_text = redtext;
Controls.WarKeyBar:SetColor(war_color);

local openBorders_color = steelblue;
local openBorders_text = steelbluetext;
Controls.BordersKeyBar:SetColor(openBorders_color);

local DoF_color = green;
local DoF_text = greentext;
Controls.DoFKeyBar:SetColor(DoF_color);

local denounce_color = orange;
local denounce_text = orangetext;
Controls.DenounceKeyBar:SetColor(denounce_color);

local defensivePact_color = white;
local defensivePact_text = whitetext;
Controls.DefensiveKeyBar:SetColor(defensivePact_color);

--Economic colors
local gold_color = gold;
local gold_text = goldtext;
Controls.GPTKeyBar:SetColor(gold_color);

local research_color = violet;
local research_text = violettext;
Controls.ResearchKeyBar:SetColor(research_color);

local resource_color = green;
local resource_text = greentext;
Controls.ResourceKeyBar:SetColor(resource_color);

local traderoute_color = steelblue;
local traderoute_text = steelbluetext;
Controls.TradeRouteKeyBar:SetColor(traderoute_color);

local export_text = purpletext;
local import_text = orangetext;

-- Attitude colors
local hostile_color = red;
local hostile_text = redtext;
Controls.HostileKeyBar:SetColor(hostile_color);

local guarded_color = orange;
local guarded_text = orangetext;
Controls.GuardedKeyBar:SetColor(guarded_color);

local afraid_color = steelblue;
local afraid_text = steelbluetext;
Controls.AfraidKeyBar:SetColor(afraid_color);

local friendly_color = green;
local friendly_text = greentext;
Controls.FriendlyKeyBar:SetColor(friendly_color);

local neutral_color = white;
local neutral_text = whitetext;
Controls.NeutralKeyBar:SetColor(neutral_color);


-- This table keeps track of the connector counts between two icons. Also have a max value
-- in here that's set by the external program that generates the XML for the connectors.

local connectorCount = {};
local maxConnections = 5;


-- Tables to keep track of civ icon and key selection state.
local civSelected = {};
local keySelected = {};


-- The last view select is held here. Initialized to the political view.
local lastView = "political";


-- Global deal place holder
-- local m_Deal = UI.GetScratchDeal();


-- Controls for the various keys are kept in keyBarControls and referenced later on by
-- keyBarHandler(). keyBarControls is set up in initkeySelected();

local keyBarControl = {};


-- Various keys that we're displaying

local keyType = {};
keyType.war = 0;
keyType.defensive = 1;
keyType.denounce = 2;
keyType.DoF = 3;
keyType.borders = 4;
keyType.research = 5;
keyType.GPT = 6;
keyType.resource = 7;
keyType.hostile = 8;
keyType.guarded = 9;
keyType.afraid = 10;
keyType.friendly = 11;
keyType.neutral = 12;
keyType.traderoute = 13;


--------------------------------------------------------
-- !! From InfoAddictLib.lua !! --
--------------------------------------------------------

-- Control option to see all empires regardless if we've met them or not. Set seeThem() to
-- true to cheat, you cheating cheater. The warning popped up a little too often so I've slapped
-- a timer onto it to keep it from being too annoying. It should only show up periodically now.

local lastCheatWarn = 0;
local cheatWarnInterval = 15;
local seeThem = false;

function seeEveryone()
  if (seeThem) then
    local now = os.time();
    if (now - lastCheatWarn > cheatWarnInterval) then
      lastCheatWarn = os.time();
    end;
  end;
  return seeThem;
end;


-- Returns true or false on whether the active player has met a civ. Takes the
-- civ pid as the argument.

function hasMetCiv(pid)
  local pPlayer = Players[pid];
  local pTeam = Teams[pPlayer:GetTeam()];
  return not pPlayer:IsMinorCiv() and pPlayer:IsEverAlive() and
    (pTeam:IsHasMet(Game.GetActiveTeam()) or seeEveryone())
end;

-- Call this from the tuner to toggle seeThem on and off.

function toggleSeeThem()
  if (seeThem) then
    seeThem = false;
  else
    seeThem = true;
  end
end


-- Returns the number of civs that the active player has currently met.

function getVisibleCivCount()
  local civcount = 0
  for iPlayerLoop = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
    if( hasMetCiv(iPlayerLoop) ) then
      civcount = civcount + 1;
    end;
  end;
  return civcount;
end;


-- Get a count of all active civs whether we've met them or not.

function getAllCivCount()
  local civcount = 0
  for iPlayerLoop = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
    local pPlayer = Players[iPlayerLoop];
    if( not pPlayer:IsMinorCiv() and pPlayer:IsEverAlive() ) then
      civcount = civcount + 1;
    end;
  end;
  return civcount;
end;


-- Given a civ Pid, return a full civ title that looks like "Washington of
-- the American Empire".

function getFullLeaderTitle(pid)

  local player = Players[pid];
  local name = Locale.ConvertTextKey( GameInfo.Civilizations[ player:GetCivilizationType() ].Description );
  local leader = player:GetName();
  return leader .. " " .. Locale.ConvertTextKey("TXT_KEY_DO_OF_THE") .. " " .. name;

end;
--------------------------------------------------------


-- Global table that holds icon positions for each civ. Initialized when the game is loaded
-- and referenced through getIconPosition().

local iconPositionTable = {};


function initIconPositions()

  local count = getAllCivCount();
  local iconDistance = iconCount/count;

  local iconPosition = 0;
  for iPlayerLoop = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
    iconPositionTable[iPlayerLoop] = nil;    -- init everybody to non-existant position
    if (not Players[iPlayerLoop]:IsMinorCiv() and Players[iPlayerLoop]:IsEverAlive()) then
    
      local thisIcon = math.floor(iconPosition + .5);   -- the + .5 rounds the number instead of a straight floor

      iconPositionTable[iPlayerLoop] = thisIcon;
      iconPosition = iconPosition + iconDistance;

    end;
  end;
end;
initIconPositions();


-- Initialize the civ selections
function initCivSelected()
  for pid = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
    civSelected[pid] = false;
  end;
end;
initCivSelected();


-- Initialize the key selections and keyBarControls

function initKeySelected()

  -- Political Keys
  keySelected[keyType.war] = false;
  keyBarControl[keyType.war] = Controls.WarKeyBar;

  keySelected[keyType.defensive] = false;
  keyBarControl[keyType.defensive] = Controls.DefensiveKeyBar;

  keySelected[keyType.denounce] = false;
  keyBarControl[keyType.denounce] = Controls.DenounceKeyBar;

  keySelected[keyType.borders] = false;
  keyBarControl[keyType.borders] = Controls.BordersKeyBar;

  keySelected[keyType.DoF] = false;
  keyBarControl[keyType.DoF] = Controls.DoFKeyBar;


  -- Economic Keys
  keySelected[keyType.GPT] = false;
  keyBarControl[keyType.GPT] = Controls.GPTKeyBar;

  keySelected[keyType.resource] = false;
  keyBarControl[keyType.resource] = Controls.ResourceKeyBar;

  keySelected[keyType.research] = false;
  keyBarControl[keyType.research] = Controls.ResearchKeyBar;

  keySelected[keyType.traderoute] = false;
  keyBarControl[keyType.traderoute] = Controls.TradeRouteKeyBar;

  
  -- Attitude Keys
  keySelected[keyType.hostile] = false;
  keyBarControl[keyType.hostile] = Controls.HostileKeyBar;

  keySelected[keyType.guarded] = false;
  keyBarControl[keyType.guarded] = Controls.GuardedKeyBar;

  keySelected[keyType.afraid] = false;
  keyBarControl[keyType.afraid] = Controls.AfraidKeyBar;
  
  keySelected[keyType.friendly] = false;
  keyBarControl[keyType.friendly] = Controls.FriendlyKeyBar;

  keySelected[keyType.neutral] = false;
  keyBarControl[keyType.neutral] = Controls.NeutralKeyBar;

end;
initKeySelected();



-- Returns the icon position of a given civ

function getIconPosition(pid)
  local pos = iconPositionTable[pid];
  return pos;
end;



-- This handler acts as a toggle when the civ icon is selected. Selection
-- state is held in the civSelected table and selecting the civ icon
-- causes the current view to rebuild. Special pid of -1 does nothing (this
-- is for dead civs).

function civIconButtonHandler( pid )

  if (pid == -1) then
    return false;
  end;


  local icon = getIconPosition(pid);

  if (civSelected[pid] == true) then
    civSelected[pid] = false;
  else
    civSelected[pid] = true;
  end;

  BuildView(lastView);
end


-- Unhide all the icons for the civs that we have met and set the button handlers for each
-- of the icons. Also checks to see if frames need to be drawn for selected icons.

function showVisibleCivIcons()

  for iPlayerLoop = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
    if( hasMetCiv(iPlayerLoop) ) then

      local thisIcon = getIconPosition(iPlayerLoop);
      local iconcontrol = Controls["IARelIcon-" .. thisIcon];
      local framecontrol = Controls["IARelIconFrame-" .. thisIcon];

      iconcontrol:SetHide(false);
      SimpleCivIconHookup( iPlayerLoop, 64, iconcontrol);

      -- Dim the icon if the civ is dead
      if (not Players[iPlayerLoop]:IsAlive() ) then
        iconcontrol:SetAlpha(.2);
      else
        iconcontrol:SetAlpha(1);
      end;

      local buttonarg = iPlayerLoop;
      if (not Players[iPlayerLoop]:IsAlive()) then
        buttonarg = -1;
        framecontrol:SetHide(true);
      end;

      local buttoncontrol = Controls["IARelIconButton-" .. thisIcon];
      buttoncontrol:SetVoid1(buttonarg);
      buttoncontrol:RegisterCallback( Mouse.eLClick, civIconButtonHandler );
      buttoncontrol:RegisterCallback( Mouse.eRClick, LeaderSelected );

      if (civSelected[iPlayerLoop] == true) then
        framecontrol:SetHide(false);
      else
        framecontrol:SetHide(true);
      end;

    end;
  end;
end;




-- Main view handler for building connections and tooltips. 

function BuildView(view)

  local totaltimer = os.clock();

  showVisibleCivIcons();
  keyBarHandler();
  selectionResetShowHide();

  if (view == "political") then
    politicalView();
  elseif (view == "economic") then
    economicView();
  elseif (view == "attitude") then
    attitudeView();
  end;

  lastView = view;
end;


-- Switch to the political relations view

function politicalView()

  resetAllConnections();
  resetAllTooltips();

  local tooltipPad = "[NEWLINE]   ";

  -- Tables to hold values for tooltip building. I probably could have done this in a smarter, cleaner
  -- way but, meh, this is good enough.

  local tooltipData = {};
  tooltipData["war"] = {};
  tooltipData["defensive"] = {};
  tooltipData["DoF"] = {};
  tooltipData["borders"] = {};
  tooltipData["denounce"] = {};


  -- Some political states are uni-directional but we only want to draw one line between
  -- the civs if there is a mutual state between two civs. These tables keep track if
  -- that line has been drawn or not.

  local openBordersDrawn = {};
  local denounceDrawn = {};


  for thisPid = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
    if( hasMetCiv(thisPid) and Players[thisPid]:IsAlive()) then

      if (tooltipData["war"][thisPid] == nil) then
        tooltipData["war"][thisPid] = "";
        tooltipData["defensive"][thisPid] = "";
        tooltipData["DoF"][thisPid] = "";
        tooltipData["borders"][thisPid] = "";
        tooltipData["denounce"][thisPid] = "";
      end;

      for targetPid = thisPid + 1, GameDefines.MAX_MAJOR_CIVS-1, 1 do
        if( hasMetCiv(targetPid) and Players[targetPid]:IsAlive()) then

          if (tooltipData["war"][targetPid] == nil) then
            tooltipData["war"][targetPid] = "";
            tooltipData["defensive"][targetPid] = "";
            tooltipData["DoF"][targetPid] = "";
            tooltipData["borders"][targetPid] = "";
            tooltipData["denounce"][targetPid] = "";
          end;

          local thisPlayer = Players[thisPid];
          local thisTid = thisPlayer:GetTeam();
          local thisTeam = Teams[thisTid];

          local targetPlayer = Players[targetPid];
          local targetTid = targetPlayer:GetTeam();
          local targetTeam = Teams[targetTid];

          local thisName = Locale.ConvertTextKey( GameInfo.Civilizations[ thisPlayer:GetCivilizationType() ].ShortDescription );
          local targetName = Locale.ConvertTextKey( GameInfo.Civilizations[ targetPlayer:GetCivilizationType() ].ShortDescription );


          if (thisTeam:IsAtWar(targetTid) and isKeySelected(keyType.war)) then
            showConnector(thisPid, targetPid, war_color);
            if (isCivSelected(thisPid) or isCivSelected(targetPid)) then
              tooltipData["war"][thisPid] = tooltipData["war"][thisPid] .. tooltipPad .. targetName;
              tooltipData["war"][targetPid] = tooltipData["war"][targetPid] .. tooltipPad .. thisName;
            end;
          else

            if (thisTeam:IsDefensivePact(targetTid) and isKeySelected(keyType.defensive)) then
              showConnector(thisPid, targetPid, defensivePact_color);
              if (isCivSelected(thisPid) or isCivSelected(targetPid)) then
                tooltipData["defensive"][thisPid] = tooltipData["defensive"][thisPid] .. tooltipPad .. targetName;
                tooltipData["defensive"][targetPid] = tooltipData["defensive"][targetPid] .. tooltipPad .. thisName;
              end;
            end;

            if (thisPlayer:IsDoF(targetPid) and isKeySelected(keyType.DoF) ) then
              showConnector(thisPid, targetPid, DoF_color);
              if (isCivSelected(thisPid) or isCivSelected(targetPid)) then
                tooltipData["DoF"][thisPid] = tooltipData["DoF"][thisPid] .. tooltipPad .. targetName;
                tooltipData["DoF"][targetPid] = tooltipData["DoF"][targetPid] .. tooltipPad .. thisName;
              end;
            end;

            -- open borders can be one-sided so we check both directions. Connectors are drawn regardless if it's
            -- mutual or not but the tooltips should show who is opening borders to whom.

            if (isKeySelected(keyType.borders)) then
              if (thisTeam:IsAllowsOpenBordersToTeam(targetTid)) then
                if (isCivSelected(thisPid) or isCivSelected(targetPid)) then
                  tooltipData["borders"][thisPid] = tooltipData["borders"][thisPid] .. tooltipPad .. targetName;
                end;
              end;

              if (targetTeam:IsAllowsOpenBordersToTeam(thisTid)) then
                if (isCivSelected(thisPid) or isCivSelected(targetPid)) then
                  tooltipData["borders"][targetPid] = tooltipData["borders"][targetPid] .. tooltipPad .. thisName;
                end;
              end;

              local firstPid = thisPid;
              local secondPid = targetPid;
              if (firstPid > secondPid) then
                firstPid = toPid;
                secondPid = fromPid;
              end;

              local bordercheck = firstPid .. "-" .. secondPid;

              if ((thisTeam:IsAllowsOpenBordersToTeam(targetTid) or targetTeam:IsAllowsOpenBordersToTeam(thisTid)) and
                   openBordersDrawn[bordercheck] == nil)
              then
                showConnector(thisPid, targetPid, openBorders_color);
                openBordersDrawn[bordercheck] = true;
              end;
            end;


            -- Like open borders, denouncements get checked in both directions but only one line is drawn

            if (isKeySelected(keyType.denounce)) then
              if (thisPlayer:IsDenouncedPlayer(targetPid)) then
                if (isCivSelected(thisPid) or isCivSelected(targetPid)) then
                  tooltipData["denounce"][thisPid] = tooltipData["denounce"][thisPid] .. tooltipPad .. targetName;
                end;
              end;

              if (targetPlayer:IsDenouncedPlayer(thisPid)) then
                if (isCivSelected(thisPid) or isCivSelected(targetPid)) then
                  tooltipData["denounce"][targetPid] = tooltipData["denounce"][targetPid] .. tooltipPad .. thisName;
                end;
              end;

              local firstPid = thisPid;
              local secondPid = targetPid;
              if (firstPid > secondPid) then
                firstPid = toPid;
                secondPid = fromPid;
              end;

              local denouncecheck = firstPid .. "-" .. secondPid;

              if ((thisPlayer:IsDenouncedPlayer(targetPid) or targetPlayer:IsDenouncedPlayer(thisPid)) and
                   denounceDrawn[denouncecheck] == nil)
              then
                showConnector(thisPid, targetPid, denounce_color);
                denounceDrawn[denouncecheck] = true;
              end;
            end;

          end;

        end;
      end;
    end;
  end;


  -- Now that we've collected all the data, tooltips can be built.

  for thisPid = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
    if (tooltipData["war"][thisPid] ~= nil) then
      
      local str = "";

      -- First, the main civ name
      str = str .. "[COLOR_POSITIVE_TEXT]" .. getFullLeaderTitle(thisPid) .. "[ENDCOLOR]";

      -- Any wars?
      if (tooltipData["war"][thisPid] ~= "") then
        str = str .. "[NEWLINE]" .. war_text .. Locale.ConvertTextKey("TXT_KEY_DO_RELATIONKEY_WAR") .. ":[ENDCOLOR] " .. tooltipData["war"][thisPid];
      end;

      -- Defensive pacts
      if (tooltipData["defensive"][thisPid] ~= "") then
        str = str .. "[NEWLINE]" .. defensivePact_text .. Locale.ConvertTextKey("TXT_KEY_DO_RELATIONKEY_DEFENSIVE_PACT") ..
              ":[ENDCOLOR] " .. tooltipData["defensive"][thisPid];
      end;

      -- Declaration of Friendship
      if (tooltipData["DoF"][thisPid] ~= "") then
        str = str .. "[NEWLINE]" .. DoF_text .. Locale.ConvertTextKey("TXT_KEY_DO_RELATIONKEY_DECLARATION_OF_FRIENDSHIP") .. ":[ENDCOLOR] " .. tooltipData["DoF"][thisPid];
      end;

      -- Open Borders?
      if (tooltipData["borders"][thisPid] ~= "") then
        str = str .. "[NEWLINE]" .. openBorders_text .. Locale.ConvertTextKey("TXT_KEY_DO_RELATIONKEY_OPEN_BORDERS") .. ":[ENDCOLOR] " .. tooltipData["borders"][thisPid];
      end;

      -- Denouncements
      if (tooltipData["denounce"][thisPid] ~= nil and tooltipData["denounce"][thisPid] ~= "") then
        str = str .. "[NEWLINE]" .. denounce_text .. Locale.ConvertTextKey("TXT_KEY_DO_RELATIONKEY_DENOUNCEMENT") .. ":[ENDCOLOR] " .. tooltipData["denounce"][thisPid];
      end;


      -- Right-Click to Meet
      if (thisPid ~= Game.GetActivePlayer()) then
        str = str .. "[NEWLINE][NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_DO_RELATIONTOOLTIP_RCLICK");
      end;

      local icon = getIconPosition(thisPid);
      local iconname = "IARelIconButton-" .. icon;
      local iconcontrol = Controls[iconname];
      iconcontrol:SetToolTipString(str);


    end;
  end;
end;




function economicView()

  resetAllConnections();
  resetAllTooltips();

  local tooltipPad = "[NEWLINE]   ";
  local iconPad = "  ";

  -- Build tables of strings that hold all active trade deal details. We also have an
  -- "already seen" table so that we do not list the same trade multiple times in a tooltip.

  local exports = {};
  local imports = {};
  local research = {};
  local traderoutes = {};
  local alreadyseen = {};

  local thisTurn = Game.GetGameTurn();


  -- Loops through all current trade deals for all visible players. Turn on connectors
  -- where appropriate and start building export and import strings for the tooltips.
  --
  -- The looping is really kinda messed up because it appears the UI:GetNumCurrentDeals(pid)
  -- is broken. No matter what player ID you feed it, it will return the number of current
  -- deals for player 0. So, to get around this, I'm using something I noticed:
  -- UI.LoadCurrentDeal() leaves the current state of m_Deal alone if you ask for a deal that
  -- doesn't exist. So, I loop over all the civs, loading successive deals until I start getting
  -- repeats. Once I know that's done, I move on the the next civ. As a side effect of my little
  -- hack, I have to put in a loop stopper just in case there are no deals whatsoever (which is
  -- always the case right at the beginning of a game). I figure 20 deals per visible civ is high
  -- enough to prevent premature cutoff but still give good performance.

  local hackGuardPissed = getVisibleCivCount() * 20;
  local maxRepeats = 10;

  for thisPid = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
    if( hasMetCiv(thisPid) and Players[thisPid]:IsAlive()) then


      local repeatcheck = false;
      local repeatchecktable = {};
      local dealIterator = 0;
      local hackGuard = 0;

      if (repeatcheck == false and hackGuard < hackGuardPissed) then
      repeat

        local itemType;
        local duration;
        local finalTurn;
        local data1;
        local data2;
		local data3;
		local flag1;
        local fromPidDeal;
        local m_Deal = UI.GetScratchDeal();

        UI.LoadCurrentDeal( thisPid, dealIterator );
        local otherPid = m_Deal:GetOtherPlayer();

        dealIterator = dealIterator + 1;
        hackGuard = hackGuard + 1;


        m_Deal:ResetIterator();
        itemType, duration, finalTurn, data1, data2, data3, flag1, fromPidDeal = m_Deal:GetNextItem();

        -- For some reason, deals get loaded that don't include the player that we're looking at. Let's skip
        -- those.
        local fromCheck = m_Deal:GetFromPlayer();
        local toCheck = m_Deal:GetToPlayer();
        local thisCheckFail = false;

        if (fromCheck ~= thisPid and toCheck ~= thisPid) then
          thisCheckFail = true;
        end;

        if( itemType ~= nil and thisCheckFail == false) then
        repeat
          
          local toPid = thisPid;
          local fromPid = otherPid;

          if (fromPidDeal == thisPid) then
            toPid = otherPid;
            fromPid = thisPid;
          end;

          local repeatcheckstr = itemType .. "-" .. finalTurn .. "-" .. duration .. "-" .. data1 .. "-"
                                  .. fromPid .. "-" .. toPid;
          
          if (repeatchecktable[repeatcheckstr] == nil) then
            repeatchecktable[repeatcheckstr] = 1;
          elseif (repeatchecktable[repeatcheckstr] > maxRepeats) then
            repeatcheck = true;
          else
            repeatchecktable[repeatcheckstr] = repeatchecktable[repeatcheckstr] + 1;
          end; 


          -- Not sure what a trade to yourself is all about but it seems like I have to check
          -- for it anyway.

          if (toPid ~= fromPid) then

            -- Check to initialize tooltip string if needed

            if (exports[toPid] == nil)     then exports[toPid] = {} end;
            if (imports[toPid] == nil)     then imports[toPid] = {} end;
            if (research[toPid] == nil)    then research[toPid] = "" end;

            if (exports[fromPid] == nil)   then exports[fromPid] = {} end;
            if (imports[fromPid] == nil)   then imports[fromPid] = {}  end;
            if (research[fromPid] == nil)  then research[fromPid] = "" end;


            local toPlayer = Players[toPid];
            local fromPlayer = Players[fromPid];
    
            local toName = Locale.ConvertTextKey( GameInfo.Civilizations[ toPlayer:GetCivilizationType() ].ShortDescription );
            local fromName = Locale.ConvertTextKey( GameInfo.Civilizations[ fromPlayer:GetCivilizationType() ].ShortDescription );


            if (hasMetCiv(fromPid) and Players[fromPid]:IsAlive() and 
                hasMetCiv(toPid) and Players[toPid]:IsAlive()) then

              local turnsLeft = finalTurn - thisTurn;

              -- Deal is for gold per turn
              if( TradeableItems.TRADE_ITEM_GOLD_PER_TURN == itemType ) then
                
                local goldamount = data1;
                local exportstr = tooltipPad .. "[ICON_GOLD]" .. iconPad .. goldamount .. " " .. Locale.ConvertTextKey("TXT_KEY_DO_RELATIONTOOLTIP_GPT_TO") ..
                                  " " .. toName .. " (" .. turnsLeft .. ")";
                local importstr = tooltipPad .. "[ICON_GOLD]" .. iconPad .. goldamount .. " " .. Locale.ConvertTextKey("TXT_KEY_DO_RELATIONTOOLTIP_GPT_FROM") ..
                                  " " .. fromName .. " (" .. turnsLeft .. ")";

                
                if ((isCivSelected(fromPid) or isCivSelected(toPid)) and isKeySelected(keyType.GPT)) then
                  exports[fromPid][exportstr] = turnsLeft;
                end;

                if ((isCivSelected(fromPid) or isCivSelected(toPid)) and isKeySelected(keyType.GPT)) then
                  imports[toPid][importstr] = turnsLeft;
                end;
                  
                local firstPid = fromPid;
                local secondPid = toPid;
                if (firstPid > secondPid) then
                  firstPid = toPid;
                  secondPid = fromPid;
                end;

                local check = "gpt:" .. firstPid .. "-" .. secondPid;
                if (alreadyseen[check] ~= 1) then
                  if (isKeySelected(keyType.GPT)) then
                    showConnector(fromPid, toPid, gold_color);
                  end;
                  alreadyseen[check] = 1;
                end;

              elseif( TradeableItems.TRADE_ITEM_RESEARCH_AGREEMENT == itemType ) then     
 
                local exportstr = tooltipPad .. "[ICON_RESEARCH]" .. iconPad .. " " .. toName .. " (" .. turnsLeft .. ")";

                if (alreadyseen[exportstr .. fromName] ~= 1 and (isCivSelected(fromPid) or isCivSelected(toPid)) and isKeySelected(keyType.research)) then
                  research[fromPid] = research[fromPid] .. exportstr;
                  alreadyseen[exportstr .. fromName] = 1;
                end;

                local firstPid = fromPid;
                local secondPid = toPid;
                if (firstPid > secondPid) then
                  firstPid = toPid;
                  secondPid = fromPid;
                end;

                local check = "research:" .. firstPid .. "-" .. secondPid;
                if (alreadyseen[check] ~= 1) then
                  if (isKeySelected(keyType.research)) then
                    showConnector(fromPid, toPid, research_color);
                  end;
                  alreadyseen[check] = 1;
                end;


              elseif( TradeableItems.TRADE_ITEM_RESOURCES == itemType ) then

                local resourceName = Locale.ConvertTextKey( GameInfo.Resources[data1].Description );
                local iconstr = GameInfo.Resources[data1].IconString;
                local exportstr = tooltipPad .. iconstr .. iconPad .. resourceName .. " " .. Locale.ConvertTextKey("TXT_KEY_DO_RELATIONTOOLTIP_TO") ..
                                  " " .. toName .. " (" .. turnsLeft .. ")";
                local importstr = tooltipPad .. iconstr .. iconPad .. resourceName .. " " .. Locale.ConvertTextKey("TXT_KEY_DO_RELATIONTOOLTIP_FROM") ..
                                  " " .. fromName .. " (" .. turnsLeft .. ")";

                -- Check to see if this is a strategic resource. If it is, the number traded is included in the
                -- tooltip.

                if( GameInfo.Resources[data1].ResourceUsage == 1 ) then
                  local amount = data2;
                  exportstr = tooltipPad .. iconstr .. iconPad .. data2 .. " " .. resourceName .. " " .. Locale.ConvertTextKey("TXT_KEY_DO_RELATIONTOOLTIP_TO") ..
                              " " .. toName .. " (" .. turnsLeft .. ")";
                  importstr = tooltipPad .. iconstr .. iconPad .. data2 .. " " .. resourceName .. " " .. Locale.ConvertTextKey("TXT_KEY_DO_RELATIONTOOLTIP_FROM") ..
                              " " .. fromName .. " (" .. turnsLeft .. ")";
                else

                end;


                if ((isCivSelected(fromPid) or isCivSelected(toPid)) and isKeySelected(keyType.resource)) then
                  exports[fromPid][exportstr] = turnsLeft;
                end;

                if ((isCivSelected(fromPid) or isCivSelected(toPid)) and isKeySelected(keyType.resource)) then
                  imports[toPid][importstr] = turnsLeft;
                end;

                local firstPid = fromPid;
                local secondPid = toPid;
                if (firstPid > secondPid) then
                  firstPid = toPid;
                  secondPid = fromPid;
                end;

                local check = "resource:" .. firstPid .. "-" .. secondPid;
                if (alreadyseen[check] ~= 1) then
                  if (isKeySelected(keyType.resource)) then
                    showConnector(fromPid, toPid, resource_color);
                  end;
                  alreadyseen[check] = 1;
                end;

              end;

            end;
           end;

          itemType, duration, finalTurn, data1, data2, data3, flag1, fromPidDeal = m_Deal:GetNextItem();
        until( itemType == nil )
        end;

      if (hackGuard > hackGuardPissed) then
      end;

      until(repeatcheck == true or hackGuard > hackGuardPissed)
      end;
    end;
  end;


  -- Grab the data for any established trade routes and show connectors for them. Build strings for the tooltips
  -- while we're at it.

  for thisPid = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
    if( hasMetCiv(thisPid) and Players[thisPid]:IsAlive()) then
	  
	  local thisPlayer = Players[thisPid];

	  local tradeRoutesTable = thisPlayer:GetTradeRoutes()
	  for i = 1, table.count(tradeRoutesTable), 1 do

		local toPid = tradeRoutesTable[i].ToID
		local toPlayer = Players[toPid];
        local toName = Locale.ConvertTextKey( GameInfo.Civilizations[ toPlayer:GetCivilizationType() ].ShortDescription );

		if (not toPlayer:IsMinorCiv() and toPlayer:IsEverAlive() and hasMetCiv(toPid) and thisPid ~= toPid) then
		    local turnsLeft = tradeRoutesTable[i].TurnsLeft
		    local gold = math.floor(tradeRoutesTable[i].FromGPT / 100)
		    local science = math.floor(tradeRoutesTable[i].FromScience / 100)
			local str = tooltipPad .. "[ICON_TURNS_REMAINING]" .. iconPad .. toName .. "," .. iconPad

			if (gold > 0) then
			  str = str .. gold .. "[ICON_GOLD]"
			end

			-- Comma if both are listed
			if (gold > 0 and science > 0) then
			  str = str .. "," .. iconPad
			end

			if (science > 0) then
			  str = str .. science .. "[ICON_RESEARCH]"
			end

			-- nice space padding and the number of turns left
			str = str .. iconPad .. "(" .. turnsLeft .. ")"
			
			if ((isCivSelected(thisPid) or isCivSelected(toPid)) and isKeySelected(keyType.traderoute)) then
          
			  if (traderoutes[thisPid] == nil) then
				traderoutes[thisPid] = {}
			  end

			  traderoutes[thisPid][str] = turnsLeft;
			end;

			-- Show connector
			local firstPid = thisPid
			local secondPid = toPid
			if (firstPid > secondPid) then
			  firstPid = toPid
			  secondPid = thisPid
			end

			local check = "traderoute:" .. firstPid .. "-" .. secondPid;
			if (alreadyseen[check] ~= 1) then
			  if (isKeySelected(keyType.traderoute)) then
				showConnector(thisPid, toPid, traderoute_color)
			  end
			  alreadyseen[check] = 1;
			end
		end

	  end
	end
  end


  -- Now that we've collected all the data, tooltips can be built. First, we build the export and import
  -- strings from a sorted version of the export and import tables.


  for thisPid = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
    if (hasMetCiv(thisPid) and Players[thisPid]:IsAlive()) then
        
      function sortExportsByTurnsLeft(a, b)
        return exports[thisPid][a] < exports[thisPid][b];
      end;

      function sortImportsByTurnsLeft(a, b)
        return imports[thisPid][a] < imports[thisPid][b];
      end;

      function sortTradeRoutesByTurnsLeft(a, b)
        return traderoutes[thisPid][a] < traderoutes[thisPid][b];
      end;

      local exportstr = "";
      local importstr = "";
	  local traderoutesstr = "";
    
      if (exports[thisPid] ~= nil) then
        local exportTable = {};
        for string, _ in pairs(exports[thisPid]) do table.insert(exportTable, string) end;
        table.sort(exportTable, sortExportsByTurnsLeft);
        for _, string in ipairs(exportTable) do exportstr = exportstr .. string end;
      end;

      if (imports[thisPid] ~= nil) then
        local importTable = {};
        for string, _ in pairs(imports[thisPid]) do table.insert(importTable, string) end;
        table.sort(importTable, sortImportsByTurnsLeft);
        for _, string in ipairs(importTable) do importstr = importstr .. string end;
      end;

	  if (traderoutes[thisPid] ~= nil) then
        local traderouteTable = {};
        for string, _ in pairs(traderoutes[thisPid]) do table.insert(traderouteTable, string) end;
        table.sort(traderouteTable, sortTradeRoutesByTurnsLeft);
        for _, string in ipairs(traderouteTable) do traderoutesstr = traderoutesstr .. string end;
      end;

      local str = "";

      -- First, the main civ name
      str = str .. "[COLOR_POSITIVE_TEXT]" .. getFullLeaderTitle(thisPid) .. "[ENDCOLOR]";

      -- Any exports?
      if (exportstr ~= "") then
        str = str .. "[NEWLINE]" .. export_text .. Locale.ConvertTextKey("TXT_KEY_DO_RELATIONTOOLTIP_EXPORTS") ..
              ":[ENDCOLOR] " .. exportstr;
      end;

      -- Any imports?
      if (importstr ~= "") then
        str = str .. "[NEWLINE]" .. import_text .. Locale.ConvertTextKey("TXT_KEY_DO_RELATIONTOOLTIP_IMPORTS") .. 
              ":[ENDCOLOR] " .. importstr;
      end;

	  -- Any trade routes?
	  if (traderoutesstr ~= "") then
        str = str .. "[NEWLINE]" .. traderoute_text .. Locale.ConvertTextKey("TXT_KEY_DO_RELATIONTOOLTIP_TRADEROUTES") .. 
              ":[ENDCOLOR] " .. traderoutesstr;
      end;

      -- Any research?
      if (research[thisPid] ~= nil and research[thisPid] ~= "") then
        str = str .. "[NEWLINE]" .. research_text .. Locale.ConvertTextKey("TXT_KEY_DO_RELATIONTOOLTIP_RESEARCH_AGREEMENTS") ..
              ":[ENDCOLOR] " .. research[thisPid];
      end;

      local icon = getIconPosition(thisPid);
      local iconname = "IARelIconButton-" .. icon;
      local iconcontrol = Controls[iconname];
      iconcontrol:SetToolTipString(str);


    end;
  end


end;



-- Switch to the attitude view

function attitudeView()

  resetAllConnections();
  resetAllTooltips();

  local tooltipPad = "[NEWLINE]   ";
  local attitudes = getCivAttitudes();


  -- Tables to hold values for tooltip building. I probably could have done this in a smarter, cleaner
  -- way but, meh, this is good enough.

  local tooltipData = {};
  tooltipData["hostile"] = {};
  tooltipData["guarded"] = {};
  tooltipData["afraid"] = {};
  tooltipData["friendly"] = {};
  tooltipData["neutral"] = {};


  for thisPid = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
    if( thisPid ~= Game.GetActivePlayer() and hasMetCiv(thisPid) and Players[thisPid]:IsAlive()) then

      for i, v in pairs(tooltipData) do
        if (tooltipData[i][thisPid] == nil) then
          tooltipData[i][thisPid] = "";
        end;
      end;
      
      for targetPid = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
        if( hasMetCiv(targetPid) and Players[targetPid]:IsAlive()) then

          for i, v in pairs(tooltipData) do
            if (tooltipData[i][targetPid] == nil) then
              tooltipData[i][targetPid] = "";
            end;
          end;

          local thisPlayer = Players[thisPid];
          local thisTid = thisPlayer:GetTeam();
          local thisTeam = Teams[thisTid];

          local targetPlayer = Players[targetPid];
          local targetTid = targetPlayer:GetTeam();
          local targetTeam = Teams[targetTid];

          local thisName = Locale.ConvertTextKey( GameInfo.Civilizations[ thisPlayer:GetCivilizationType() ].ShortDescription );
          local targetName = Locale.ConvertTextKey( GameInfo.Civilizations[ targetPlayer:GetCivilizationType() ].ShortDescription );

          local currentAttitude = attitudes[targetPid][thisPid];

          if( (currentAttitude == MajorCivApproachTypes.MAJOR_CIV_APPROACH_HOSTILE or 
              currentAttitude == MajorCivApproachTypes.MAJOR_CIV_APPROACH_WAR or thisTeam:IsAtWar(targetTid)) and isKeySelected(keyType.hostile))
          then
            showConnector(thisPid, targetPid, hostile_color);
            if (isCivSelected(thisPid) or isCivSelected(targetPid)) then
              tooltipData["hostile"][thisPid] = tooltipData["hostile"][thisPid] .. tooltipPad .. targetName;
            end;
          
          elseif( currentAttitude == MajorCivApproachTypes.MAJOR_CIV_APPROACH_GUARDED and isKeySelected(keyType.guarded)) then
            showConnector(thisPid, targetPid, guarded_color);
            if (isCivSelected(thisPid) or isCivSelected(targetPid)) then
              tooltipData["guarded"][thisPid] = tooltipData["guarded"][thisPid] .. tooltipPad .. targetName;
            end;

          elseif( currentAttitude == MajorCivApproachTypes.MAJOR_CIV_APPROACH_AFRAID and isKeySelected(keyType.afraid)) then
            showConnector(thisPid, targetPid, afraid_color);
            if (isCivSelected(thisPid) or isCivSelected(targetPid)) then
              tooltipData["afraid"][thisPid] = tooltipData["afraid"][thisPid] .. tooltipPad .. targetName;
            end;

          elseif( currentAttitude == MajorCivApproachTypes.MAJOR_CIV_APPROACH_FRIENDLY and isKeySelected(keyType.friendly)) then
            showConnector(thisPid, targetPid, friendly_color);
            if (isCivSelected(thisPid) or isCivSelected(targetPid)) then
              tooltipData["friendly"][thisPid] = tooltipData["friendly"][thisPid] .. tooltipPad .. targetName;
            end;

          elseif( currentAttitude == MajorCivApproachTypes.MAJOR_CIV_APPROACH_NEUTRAL and isKeySelected(keyType.neutral)) then
            showConnector(thisPid, targetPid, neutral_color);
            if (isCivSelected(thisPid) or isCivSelected(targetPid)) then
              tooltipData["neutral"][thisPid] = tooltipData["neutral"][thisPid] .. tooltipPad .. targetName;
            end;
          end;

        end;
      end;
    end;
  end;


  -- Now that we've collected all the data, tooltips can be built.

  for thisPid = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
    if (tooltipData["hostile"][thisPid] ~= nil) then
      
      local str = "";

      -- First, the main civ name
      str = str .. "[COLOR_POSITIVE_TEXT]" .. getFullLeaderTitle(thisPid) .. "[ENDCOLOR]";

      -- Hostile?
      if (tooltipData["hostile"][thisPid] ~= "") then
        str = str .. "[NEWLINE]" .. hostile_text .. Locale.ConvertTextKey("TXT_KEY_DO_RELATIONTOOLTIP_HOSTILE") ..
              ":[ENDCOLOR] " .. tooltipData["hostile"][thisPid];
      end;

      -- Guarded?
      if (tooltipData["guarded"][thisPid] ~= "") then
        str = str .. "[NEWLINE]" .. guarded_text .. Locale.ConvertTextKey("TXT_KEY_DO_RELATIONTOOLTIP_GUARDED") ..
              ":[ENDCOLOR] " .. tooltipData["guarded"][thisPid];
      end;

      -- afraid?
      if (tooltipData["afraid"][thisPid] ~= "") then
        str = str .. "[NEWLINE]" .. afraid_text .. Locale.ConvertTextKey("TXT_KEY_DO_RELATIONTOOLTIP_AFRAID") ..
              ":[ENDCOLOR] " .. tooltipData["afraid"][thisPid];
      end;

      -- friendly?
      if (tooltipData["friendly"][thisPid] ~= "") then
        str = str .. "[NEWLINE]" .. friendly_text .. Locale.ConvertTextKey("TXT_KEY_DO_RELATIONTOOLTIP_FRIENDLY") ..
              ":[ENDCOLOR] " .. tooltipData["friendly"][thisPid];
      end;

      -- Neutral?
      if (tooltipData["neutral"][thisPid] ~= "") then
        str = str .. "[NEWLINE]" .. neutral_text .. Locale.ConvertTextKey("TXT_KEY_DO_RELATIONTOOLTIP_NEUTRAL") ..
              ":[ENDCOLOR] " .. tooltipData["neutral"][thisPid];
      end;


      local icon = getIconPosition(thisPid);
      local iconname = "IARelIconButton-" .. icon;
      local iconcontrol = Controls[iconname];
      iconcontrol:SetToolTipString(str);


    end;
  end;
end;



-- Returns a table containing all the civ relations

function getCivAttitudes()

  local table = {};

  for thisPid = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
    if (Players[thisPid]:IsEverAlive()) then
      table[thisPid] = {};

      for targetPid = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
        if (Players[targetPid]:IsEverAlive()) then
          table[thisPid][targetPid] = Players[thisPid]:GetApproachTowardsUsGuess(targetPid);      
        end;
      end;

    end;
  end;

  return table;
end;



-- Given a pair of civs, illuminate their connector with the given color. This
-- function doesn't do any error checking on whether the civ actually exists or
-- not. Color is passed in as a vector4 color. The connectorCount table is checked
-- to see if more than one connection between icons is being asked for. If we go 
-- over the max connections between icons, a warning is spit out and no line
-- is drawn. Finally, this the point where the civSelected table is queried to see
-- if the lines should actually be drawn or not.

function showConnector(civ1, civ2, color)

  if (not isCivSelected(civ1) and not isCivSelected(civ2)) then
    return false;
  end;

  local icon1 = getIconPosition(civ1);
  local icon2 = getIconPosition(civ2);

  if (icon1 > icon2) then
    local temp = icon1;
    icon1 = icon2;
    icon2 = temp;
  end;

  local cid = "iac" .. icon1 .. "-" .. icon2;
  local count = connectorCount[cid];

  if (count == nil) then
    connectorCount[cid] = 0;
    count = 0;
  end;

  if (count > maxConnections-1) then
    return false;
  end;
  
  local connector = cid .. "." .. count;
  local connectorcontrol = Controls[connector];
  connectorcontrol:SetHide(false);
  connectorcontrol:SetColor(color);

  connectorCount[cid] = connectorCount[cid] + 1;

end;




-- test function to turn on all visible civs' connections

function allConnectionsOn()

  local white = Vector4(1,1,1,1);

  for iThisCiv = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
    if( hasMetCiv(iThisCiv) ) then
      for iTargetCiv = iThisCiv + 1, GameDefines.MAX_MAJOR_CIVS-1, 1 do
        if( hasMetCiv(iTargetCiv) ) then
          showConnector(iThisCiv, iTargetCiv, white);
        end;
      end;
    end;
  end;
end;



-- Turn all connections off and clear the connectorCount table.

function resetAllConnections()
  connectorCount = {};

  for firstIcon = 0, iconCount -1, 1 do
    for secondIcon = firstIcon + 1, iconCount - 1, 1 do
      for subid = 0, maxConnections-1, 1 do
        local connector = "iac" .. firstIcon .. "-" .. secondIcon .. "." .. subid;
        local connectorcontrol = Controls[connector];
        connectorcontrol:SetHide(true);
      end;
    end;
  end;

end;


-- Reset all tooltips to nothing.

function resetAllTooltips()

  for icon = 0, iconCount -1, 1 do
    local iconname = "IARelIconButton-" .. icon;
    local iconcontrol = Controls[iconname];
    iconcontrol:SetToolTipString("");
  end;

end;



-- Check to see if any icon at all has been selected.

function isAnyCivSelected()

  -- Checking icon selection 
  local check = false;

  for pid, selected in ipairs(civSelected) do
    if (selected == true) then
      check = true;
    end;
  end;

  return check;
end;


-- Check to see if a civ is selected. If no civs have been selected at all
-- this function always returns true.

function isCivSelected(pid)
  return (not isAnyCivSelected() or (isAnyCivSelected() and civSelected[pid]));
end;



-- The OnKey function sets the selection state for the various types of keys
-- that can be selected from the bottom right corner.

function OnKey(key)

  if (keySelected[key] == false) then
    keySelected[key] = true;
  else
    keySelected[key] = false;
  end;

  BuildView(lastView);
end;


Controls.WarKeyButton:SetVoid1(keyType.war);
Controls.WarKeyButton:RegisterCallback( Mouse.eLClick, OnKey);

Controls.DefensiveKeyButton:SetVoid1(keyType.defensive);
Controls.DefensiveKeyButton:RegisterCallback( Mouse.eLClick, OnKey);

Controls.DenounceKeyButton:SetVoid1(keyType.denounce);
Controls.DenounceKeyButton:RegisterCallback( Mouse.eLClick, OnKey);

Controls.DoFKeyButton:SetVoid1(keyType.DoF);
Controls.DoFKeyButton:RegisterCallback( Mouse.eLClick, OnKey);

Controls.BordersKeyButton:SetVoid1(keyType.borders);
Controls.BordersKeyButton:RegisterCallback( Mouse.eLClick, OnKey);

Controls.ResearchKeyButton:SetVoid1(keyType.research);
Controls.ResearchKeyButton:RegisterCallback( Mouse.eLClick, OnKey);

Controls.TradeRouteKeyButton:SetVoid1(keyType.traderoute);
Controls.TradeRouteKeyButton:RegisterCallback( Mouse.eLClick, OnKey);

Controls.GPTKeyButton:SetVoid1(keyType.GPT);
Controls.GPTKeyButton:RegisterCallback( Mouse.eLClick, OnKey);

Controls.ResourceKeyButton:SetVoid1(keyType.resource);
Controls.ResourceKeyButton:RegisterCallback( Mouse.eLClick, OnKey);

Controls.HostileKeyButton:SetVoid1(keyType.hostile);
Controls.HostileKeyButton:RegisterCallback( Mouse.eLClick, OnKey);

Controls.GuardedKeyButton:SetVoid1(keyType.guarded);
Controls.GuardedKeyButton:RegisterCallback( Mouse.eLClick, OnKey);

Controls.AfraidKeyButton:SetVoid1(keyType.afraid);
Controls.AfraidKeyButton:RegisterCallback( Mouse.eLClick, OnKey);

Controls.FriendlyKeyButton:SetVoid1(keyType.friendly);
Controls.FriendlyKeyButton:RegisterCallback( Mouse.eLClick, OnKey);

Controls.NeutralKeyButton:SetVoid1(keyType.neutral);
Controls.NeutralKeyButton:RegisterCallback( Mouse.eLClick, OnKey);


-- Check to see if any key at all has been selected.

function isAnyKeySelected()

  -- Checking icon selection 
  local check = false;

  for key, selected in ipairs(keySelected) do
    if (selected == true) then
      check = true;
    end;
  end;

  return check;
end;


-- Check to see if a key is selected. If no keys are select at all, this function
-- will return true.

function isKeySelected(key)
  return (not isAnyKeySelected() or (isAnyKeySelected() and keySelected[key]));
end;


-- Shows and hides the key bars based on whether they have been selected or not.

function keyBarHandler()

  for key, keyBarControl in ipairs(keyBarControl) do
    if (isKeySelected(key)) then
      keyBarControl:SetAlpha(1);
    else
      keyBarControl:SetAlpha(0);
    end;
  end;

end;


-- Shows or hides the reset button depending on whether anything selected.

function selectionResetShowHide()
  if (isAnyKeySelected() or isAnyCivSelected()) then
    Controls.SelectionResetButton:SetHide(false);
  else
    Controls.SelectionResetButton:SetHide(true);
  end;
end;


-- The SelectionResetButton will clear all reset states and redraws the last graph.

function OnSelectionReset()
  initKeySelected();
  initCivSelected();
  BuildView(lastView);
end;
Controls.SelectionResetButton:RegisterCallback( Mouse.eLClick, OnSelectionReset);



-- The OnStuff functions register the buttons at the bottom of the screen to
-- draw the appropriate graphs when clicked. They also highlight the button that
-- was just selected using the HighlightSelected function. Did I just copy this
-- comment exactly from InfoAddictHistoricalData.lua? Damn straight I did.

function HighlightSelected(type)
  
  if (type == "political") then
    Controls.PoliticalSelectHighlight:SetHide(false);
    Controls.PoliticalKey:SetHide(false);
  else
    Controls.PoliticalSelectHighlight:SetHide(true);
    Controls.PoliticalKey:SetHide(true);
  end;

  if (type == "economic") then
    Controls.EconomicSelectHighlight:SetHide(false);
    Controls.EconomicKey:SetHide(false);
  else
    Controls.EconomicSelectHighlight:SetHide(true);
    Controls.EconomicKey:SetHide(true);
  end;

  if (type == "attitude") then
    Controls.AttitudeSelectHighlight:SetHide(false);
    Controls.AttitudeKey:SetHide(false);
  else
    Controls.AttitudeSelectHighlight:SetHide(true);
    Controls.AttitudeKey:SetHide(true);
  end;
    
end;


function OnPolitical()
  BuildView("political");
  HighlightSelected("political");
end
Controls.PoliticalButton:RegisterCallback( Mouse.eLClick, OnPolitical);

function OnEconomic()
  BuildView("economic");
  HighlightSelected("economic");
end
Controls.EconomicButton:RegisterCallback( Mouse.eLClick, OnEconomic);

function OnAttitude()
  BuildView("attitude");
  HighlightSelected("attitude");
end
Controls.AttitudeButton:RegisterCallback( Mouse.eLClick, OnAttitude);


-- Re-draw the last view when the windows pops up just in case
-- we've met someone recently.

function ShowHideHandler( bIsHide, bInitState )
  if( not bInitState ) then
    if( not bIsHide ) then
      BuildView(lastView);
    end
  end
end
ContextPtr:SetShowHideHandler( ShowHideHandler );


-- Certain events should cause the graphs to redraw themselves

function turnStartHandler()
  BuildView(lastView);
end
Events.ActivePlayerTurnStart.Add( turnStartHandler );

function teamMetHandler()
  BuildView(lastView);
end
Events.TeamMet.Add( teamMetHandler );



-------------------------------------------------
-- On Leader Selected
-------------------------------------------------
function LeaderSelected(ePlayer)
	if (Players[ePlayer] ~= nil and Players[ePlayer] ~= Players[Game.GetActivePlayer()]) then
		if (Players[ePlayer]:IsHuman()) then
			Events.OpenPlayerDealScreenEvent( ePlayer );
		else
			UI.SetRepeatActionPlayer(ePlayer);
			UI.ChangeStartDiploRepeatCount(1);
			Players[ePlayer]:DoBeginDiploWithHuman();
		end
	end
end



-- Initialize the display to the political view and redraw the current
-- view at the beginning of each turn.

OnPolitical();
