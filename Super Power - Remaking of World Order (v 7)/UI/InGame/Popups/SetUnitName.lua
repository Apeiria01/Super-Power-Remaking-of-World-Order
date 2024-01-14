-------------------------------------------------
-- Select Unit Names
-------------------------------------------------
local m_PopupInfo = nil;

-------------------------------------------------
-------------------------------------------------
function OnCancel()
    UIManager:DequeuePopup(ContextPtr);
end
Controls.CancelButton:RegisterCallback(Mouse.eLClick, OnCancel);

-------------------------------------------------
-------------------------------------------------
function OnAccept()
    local pUnit = UI.GetHeadSelectedUnit();
    if pUnit then
        local sNewName = Controls.EditUnitName:GetText();

        if sNewName:match("^%.Y+.") ~= nil then
            sNewName = string.sub(sNewName, 3)
            sNewName = "[COLOR_YELLOW]" .. sNewName .. "[ENDCOLOR]"
        elseif sNewName:match("^%.R+.") ~= nil then
            sNewName = string.sub(sNewName, 3)
            sNewName = "[COLOR_RED]" .. sNewName .. "[ENDCOLOR]"
        elseif sNewName:match("^%.P+.") ~= nil then
            sNewName = string.sub(sNewName, 3)
            sNewName = "[COLOR_POSITIVE_TEXT]" .. sNewName .. "[ENDCOLOR]"
        elseif sNewName:match("^%.N+.") ~= nil then
            sNewName = string.sub(sNewName, 3)
            sNewName = "[COLOR_NEGATIVE_TEXT]" .. sNewName .. "[ENDCOLOR]"
        elseif sNewName:match("^%.M+.") ~= nil then
            sNewName = string.sub(sNewName, 3)
            sNewName = "[COLOR_MAGENTA]" .. sNewName .. "[ENDCOLOR]"
        elseif sNewName:match("^%.S+.") ~= nil then
            sNewName = string.sub(sNewName, 3)
            sNewName = "[COLOR_SELECTED_TEXT]" .. sNewName .. "[ENDCOLOR]"
        elseif sNewName:match("^%.U+.") ~= nil then
            sNewName = string.sub(sNewName, 3)
            sNewName = "[COLOR_UNIT_TEXT]" .. sNewName .. "[ENDCOLOR]"
        elseif sNewName:match("^%.F+.") ~= nil then
            sNewName = string.sub(sNewName, 3)
            sNewName = "[COLOR_YIELD_FOOD]" .. sNewName .. "[ENDCOLOR]"
        elseif sNewName:match("^%.C+.") ~= nil then
            sNewName = string.sub(sNewName, 3)
            sNewName = "[COLOR_CYAN]" .. sNewName .. "[ENDCOLOR]"
        elseif sNewName:match("^%.W+.") ~= nil then
            sNewName = string.sub(sNewName, 3)
            sNewName = "[COLOR_WHITE]" .. sNewName .. "[ENDCOLOR]"
        elseif sNewName:match("^%.G+.") ~= nil then
            sNewName = string.sub(sNewName, 3)
            sNewName = "[COLOR_GREEN]" .. sNewName .. "[ENDCOLOR]"
        elseif sNewName:match("^%.+BR+.") ~= nil then
            sNewName = string.sub(sNewName, 4)
            sNewName = "[COLOR_BROWN]" .. sNewName .. "[ENDCOLOR]"
        elseif sNewName:match("^%.+BL+.") ~= nil then
            sNewName = string.sub(sNewName, 4)
            sNewName = "[COLOR_BLUE]" .. sNewName .. "[ENDCOLOR]"
        end

        Network.SendRenameUnit(pUnit:GetID(), sNewName);
    end

    UIManager:DequeuePopup(ContextPtr);
end
Controls.AcceptButton:RegisterCallback(Mouse.eLClick, OnAccept);

----------------------------------------------------------------
-- Input processing
----------------------------------------------------------------
function InputHandler(uiMsg, wParam, lParam)
    if uiMsg == KeyEvents.KeyDown then
        if (wParam == Keys.VK_ESCAPE) then
            OnCancel();
        elseif (wParam == Keys.VK_RETURN) then
            OnAccept();
        end
    end
    return true;
end
ContextPtr:SetInputHandler(InputHandler);

----------------------------------------------------------------
----------------------------------------------------------------
function ValidateText(text)

    local numNonWhiteSpace = 0;
    for i = 1, #text, 1 do
        if string.byte(text, i) ~= 32 then
            numNonWhiteSpace = numNonWhiteSpace + 1;
        end
    end

    if numNonWhiteSpace < 3 then
        return false;
    end

    -- don't allow % character
    for i = 1, #text, 1 do
        if string.byte(text, i) == 37 then
            return false;
        end
    end

    local invalidCharArray = {'\"', '<', '>', '|', '\b', '\0', '\t', '\n', '/', '\\', '*', '?', '%[', ']'};

    for i, ch in ipairs(invalidCharArray) do
        if string.find(text, ch) ~= nil then
            return false;
        end
    end

    -- don't allow control characters
    for i = 1, #text, 1 do
        if string.byte(text, i) < 32 then
            return false;
        end
    end

    return true;
end

function Validate(dummyString)
    local bValid = false;

    if ValidateText(dummyString) then
        bValid = true;
    end

    Controls.AcceptButton:SetDisabled(not bValid);
end
Controls.EditUnitName:RegisterCallback(Validate);

----------------------------------------------------------------
----------------------------------------------------------------
function ShowHideHandler(bIsHide, bInitState)
    if (not bInitState) then
        if (not bIsHide) then
            UI.incTurnTimerSemaphore();
            Events.SerialEventGameMessagePopupShown(m_PopupInfo);
        else
            UI.decTurnTimerSemaphore();
            Events.SerialEventGameMessagePopupProcessed.CallImmediate(ButtonPopupTypes.BUTTONPOPUP_RENAME_UNIT, 0);
        end
    end
end
ContextPtr:SetShowHideHandler(ShowHideHandler);

function OnPopup(popupInfo)
    if (popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_RENAME_UNIT) then
        return;
    end

    m_PopupInfo = popupInfo;

    local pUnit = UI.GetHeadSelectedUnit();
    if pUnit then
        local unitName = pUnit:GetNameKey();
        local convertedKey = Locale.ConvertTextKey(unitName);

        Controls.EditUnitName:SetText(convertedKey);
        Controls.AcceptButton:SetDisabled(true);

        UIManager:QueuePopup(ContextPtr, PopupPriority.Priority_GreatPersonReward);
    end
end
Events.SerialEventGameMessagePopup.Add(OnPopup);

----------------------------------------------------------------
-- 'Active' (local human) player has changed
----------------------------------------------------------------
Events.GameplaySetActivePlayer.Add(OnCancel);