local DEBUG = false

function print(...)
    local s = ""
    for i,v in ipairs(arg) do
        s = s .. tostring(v)
    end
    DEFAULT_CHAT_FRAME:AddMessage(s)
  end

-- function to pick out marker from marker texture
local function SetRaidTargetIconTexture(texture, raidTargetIconIndex)
  raidTargetIconIndex = raidTargetIconIndex - 1;
  local left, right, top, bottom;
  local coordIncrement = RAID_TARGET_ICON_DIMENSION / RAID_TARGET_TEXTURE_DIMENSION;
  left = mod(raidTargetIconIndex , RAID_TARGET_TEXTURE_COLUMNS) * coordIncrement;
  right = left + coordIncrement;
  top = floor(raidTargetIconIndex / RAID_TARGET_TEXTURE_ROWS) * coordIncrement;
  bottom = top + coordIncrement;
  texture:SetTexCoord(left, right, top, bottom);
end

local icon_size = 18
local group_width = 60 + icon_size * 2
local group_height = 23
local frame_width = group_width * 8
local group_count = 9
local group_size = 7
local button_width = 110

-- Initialize addon frame
local addonFrame = CreateFrame("Frame", "RaidUIAddonFrame", UIParent)
addonFrame:SetWidth(frame_width+10)
addonFrame:SetHeight(group_height*6+10)
addonFrame:SetPoint("CENTER", UIParent, "CENTER")
addonFrame:SetMovable(true)
addonFrame:EnableMouse(true)
-- addonFrame:SetToplevel(true)
-- addonFrame:SetFrameStrata("HIGH")
addonFrame:SetBackdrop({
  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  tile = true,
  tileSize = 16,
  edgeSize = 16,
  insets = {
    left = 4,
    right = 4,
    top = 4,
    bottom = 4,
  },
})
addonFrame:SetBackdropColor(0, 0, 0, 0.5)
addonFrame:RegisterForDrag("LeftButton")
addonFrame:SetScript("OnDragStart", function() addonFrame:StartMoving() end)
addonFrame:SetScript("OnDragStop", function() addonFrame:StopMovingOrSizing() end)
for i=0,7 do
  local mark = addonFrame:CreateTexture(nil, "OVERLAY")
  mark:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
  SetRaidTargetIconTexture(mark, i+1)
  mark:SetPoint("LEFT", addonFrame, "RIGHT", -group_width*i + -(group_width/2)-(icon_size/2)-5, (group_height*2)+10)
  mark:SetWidth(icon_size)
  mark:SetHeight(icon_size)
end
local cthun = addonFrame:CreateTexture(nil, "OVERLAY")
cthun:SetTexture("Interface\\Addons\\CThunGroups\\images\\cthun2.tga")
cthun:SetPoint("BOTTOM", addonFrame, "TOP", 0 ,0)
local scale = 0.75
cthun:SetWidth(512*scale)
cthun:SetHeight(512*scale)

local groups = {}
local guild = "unguilded"
local config_mode = true
local enabled = true
local DataSource = {}
local showAddon = true

if not DEBUG then
  showAddon = false
  addonFrame:Hide()
end

-- track guild info

-- Initialized raid members table for testing
local raidMemberDataExmple = {
  ["Wwwwwwwwwwww"] = {name = "Wwwwwwwwwwww", role = 1, symbol = 1, class="Mage"},
  ["Mary"] = {name = "Mary", role = 3, symbol = 2, class="Rogue"},
  ["David"] = {name = "David", role = 2, symbol = 3, class="Warlock"},
  ["Sarah"] = {name = "Sarah", role = 1, symbol = 4, class="Druid"},
  ["Michael"] = {name = "Michael", role = 3, symbol = 5, class="Priest"},
  ["Jennifer"] = {name = "Jennifer", role = 2, symbol = 6, class="Paladin"},
  ["Daniel"] = {name = "Daniel", role = 1, symbol = 7, class="Hunter"},
  ["Lisa"] = {name = "Lisa", role = 3, symbol = 9, class="Shaman"},
  ["James"] = {name = "James", role = 2, symbol = 1, class="Warrior"},
  ["Emily"] = {name = "Emily", role = 1, symbol = 2, class="Mage"},
  ["Jessica"] = {name = "Jessica", role = 3, symbol = 3, class="Rogue"},
  ["Matthew"] = {name = "Matthew", role = 2, symbol = 4, class="Warlock"},
  ["Ashley"] = {name = "Ashley", role = 1, symbol = 9, class="Druid"},
  ["Christopher"] = {name = "Christopher", role = 3, symbol = 6, class="Priest"},
  ["Amanda"] = {name = "Amanda", role = 2, symbol = 7, class="Paladin"},
  ["Andrew"] = {name = "Andrew", role = 1, symbol = 8, class="Hunter"},
  ["Joshua"] = {name = "Joshua", role = 2, symbol = 2, class="Shaman"},
  ["Nicole"] = {name = "Nicole", role = 1, symbol = 3, class="Warrior"},
  ["William"] = {name = "William", role = 0, symbol = 4, class="Mage"},
  ["Samantha"] = {name = "Samantha", role = 2, symbol = 5, class="Rogue"},
  ["Brandon"] = {name = "Brandon", role = 1, symbol = 6, class="Warlock"},
  ["Elizabeth"] = {name = "Elizabeth", role = 3, symbol = 7, class="Druid"},
  ["Taylor"] = {name = "Taylor", role = 2, symbol = 8, class="Priest"},
  ["Alex"] = {name = "Alex", role = 1, symbol = 1, class="Paladin"},
  ["Lauren"] = {name = "Lauren", role = 3, symbol = 2, class="Hunter"},
  ["Ryan"] = {name = "Ryan", role = 2, symbol = 3, class="Shaman"},
  ["Stephanie"] = {name = "Stephanie", role = 1, symbol = 4, class="Warrior"},
  ["Justin"] = {name = "Justin", role = 0, symbol = 5, class="Mage"},
  ["Farmerina"] = {name = "Farmerina", role = 2, symbol = 1, class="Mage"},
  ["Ehawne"] = {name = "Ehawne", role = 3, symbol = 7, class="Shaman"},
  ["Stephanie2"] = {name = "Stephanie2", role = 1, symbol = 4, class="Warrior"},
  ["Justin2"] = {name = "Justin2", role = 0, symbol = 5, class="Mage"},
  ["Farmerina2"] = {name = "Farmerina2", role = 2, symbol = 1, class="Mage"},
  ["Ehawne2"] = {name = "Ehawne2", role = 3, symbol = 7, class="Shaman"},
  ["Stephanie3"] = {name = "Stephanie3", role = 1, symbol = 4, class="Warrior"},
  ["Justin3"] = {name = "Justin3", role = 0, symbol = 5, class="Mage"},
  ["Farmerina3"] = {name = "Farmerina3", role = 2, symbol = 1, class="Mage"},
  ["Ehawne3"] = {name = "Ehawne3", role = 3, symbol = 7, class="Shaman"},
}


-- Role textures
local roleMarkerTextures = {
    [1] = "Interface\\Addons\\CThunGroups\\images\\tank2", -- Melee
    [2] = "Interface\\Addons\\CThunGroups\\images\\damage2", -- Ranged
    [3] = "Interface\\Addons\\CThunGroups\\images\\healer2", -- Healer
}

-- Function to update raid members list
local function UpdateRaidMembers()
  if GetNumRaidMembers() > 0 then
    for i = 1, 40 do -- Assuming max raid size is 40 in WoW 1.12
      local name, _, _, _, _, class = GetRaidRosterInfo(i)
      if name then
        CThunGroupsDB[guild][name] = CThunGroupsDB[guild][name] or {}
        CThunGroupsDB[guild][name].name = CThunGroupsDB[guild][name].name or name
        CThunGroupsDB[guild][name].role = CThunGroupsDB[guild][name].role or 0 -- Default role to 0, none
        CThunGroupsDB[guild][name].symbol = CThunGroupsDB[guild][name].symbol or 9 -- Default symbol to 9, none
        CThunGroupsDB[guild][name].class = class or CThunGroupsDB[guild][name].class or "Warrior" -- Default
      end
    end
  end
end

-- Function to update raid member frames
local function UpdateGroups()
    -- first move all group data back to raid, we don't do this earlier so that the user
    -- can make changes without things moving around. This also saves the mark info.
    -- for _,group in ipairs(groups) do
    --   for _,member in ipairs(group) do
    --     if member and raidMembers[name] == member.name then
    --         print("hit: ", member.name)
    --       raidMembers[name].role = member.role
    --       raidMembers[name].symbol = member.symbol
    --     end
    --   end
    -- end
    -- ^ don't need to do this, info is update on the on-click

    -- Initialize groups
    for i = 1, 9 do
        groups[i] = {}
    end

    -- Sort raid members into groups based on raid symbols
    for name, data in pairs(DataSource) do
        local symbol = data.symbol
        local name = data.name

        -- print(name," ",symbol)
        -- is in raid to actually group?
        local in_raid = false
        for i=1,40 do
          if UnitName("raid"..i) == name then
            in_raid = true
            break
          end
        end

        if in_raid or DEBUG then
          local ix = symbol
          if not (ix > 0 and ix <= 9) then ix = 9 end -- stick true unknowns in group 9
          table.insert(groups[ix], {name = name, class = data.class, role = data.role, symbol = symbol})
        end
    end

    -- Arrange members within each group: melee first, then ranged, then healers
    for i, group in ipairs(groups) do
      local sortedGroup = {}
      local meleeMembers = {}
      local rangedMembers = {}
      local healerMembers = {}
  
      -- Separate members based on their roles
      for _, member in ipairs(group) do
          if member.role == 1 then
              table.insert(meleeMembers, member)
          elseif member.role == 2 then
              table.insert(rangedMembers, member)
          elseif member.role == 3 then
              table.insert(healerMembers, member)
          elseif member.role == 0 then -- not assigned yet
              table.insert(healerMembers, member)
          end
        end

      -- Add members to the sorted group
      for _, member in ipairs(meleeMembers) do
          table.insert(sortedGroup, member)
      end
      for _, member in ipairs(rangedMembers) do
          table.insert(sortedGroup, member)
      end
      for _, member in ipairs(healerMembers) do
          table.insert(sortedGroup, member)
      end
      -- if getn(sortedGroup) > 5 and addonFrame:IsVisible() then
        -- print("WARNING: Group "..i.." is attempting to be larger than 5 members!")
        -- I want to allow this but only show up to 7
      -- end
      groups[i] = sortedGroup
    end
  end

local function GetClassColor(class)
  local classColors = {
      ["WARRIOR"] = {r = 0.78, g = 0.61, b = 0.43},
      ["MAGE"] = {r = 0.41, g = 0.8, b = 0.94},
      ["ROGUE"] = {r = 1, g = 0.96, b = 0.41},
      ["DRUID"] = {r = 1, g = 0.49, b = 0.04},
      ["HUNTER"] = {r = 0.67, g = 0.83, b = 0.45},
      ["SHAMAN"] = {r = 0, g = 0.44, b = 0.87},
      ["PRIEST"] = {r = 1, g = 1, b = 1},
      ["WARLOCK"] = {r = 0.58, g = 0.51, b = 0.79},
      ["PALADIN"] = {r = 0.96, g = 0.55, b = 0.73},
  }

  return classColors[class] or {r = 1, g = 1, b = 1} -- Default to white if class color not found
end

local function ColorizeName(name, class)
  local classColor = GetClassColor(string.upper(class))
  return string.format("|cff%02x%02x%02x%s|r", classColor.r * 255, classColor.g * 255, classColor.b * 255, name)
end

-- Function to display a group of raid members
local function DisplayGroups()
  for i=1,group_count do
    for j=1,group_size do
      local frame = addonFrame["raidslot"..i..j]
      local member = groups[i][j]
      if member and ((i <= 8 and j <= 5) or config_mode) then
        local role = member.role
        local symbol = member.symbol
        local name = member.name
        local class = member.class
        local colored_name = ColorizeName(name,class)
        frame.nameText:SetText(colored_name)
        if config_mode then
          frame.nameText:SetPoint("LEFT", frame.raidMarker, "LEFT", icon_size, 0)
          frame.raidMarker:Show()
          frame.roleMarker:Show()
        else
          frame.nameText:SetPoint("LEFT", frame.raidMarker, "LEFT", 3, 0)
          frame.raidMarker:Hide()
          frame.roleMarker:Hide()
        end
        if member.role == 0 then
          frame.roleMarker:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        else
          frame.roleMarker:SetTexture(roleMarkerTextures[role]) -- Display symbol
        end
        if member.symbol == 9 then -- no symbol
          frame.raidMarker:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
          frame.raidMarker:SetTexCoord(0,1,0,1)
        else
          frame.raidMarker:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
          SetRaidTargetIconTexture(frame.raidMarker, symbol)
        end
        frame:Show()
      else
        frame:Hide()
      end
    end
  end
end

-- Function to handle clicks
-- this really shouldn't update the DataSource, that should be done on addon reload/player quit
local function RaiderOnClick(i,j)
    local button = arg1
    -- print(arg1)
    if button == "RightButton" then
      -- Toggle raid member's role on right click
      local member = groups[i][j]
      -- print("i:",i," j:", j)
      if member then
        -- print(member.name)
        DataSource[member.name].role = math.mod(DataSource[member.name].role, 3) + 1
        member.role = math.mod(member.role, 3) + 1
      end
      DisplayGroups()
    elseif button == "LeftButton" then
      -- Cycle through symbols on left click
      local member = groups[i][j]
      if member then
        -- DataSource[member.name].symbol = math.mod(DataSource[member.name].symbol, 9) + 1
        DataSource[member.name].symbol = DataSource[member.name].symbol <= 1 and 9 or DataSource[member.name].symbol - 1
        member.symbol = member.symbol <= 1 and 9 or member.symbol - 1
      end
      DisplayGroups()
    end
  end

local function InitDisplayGroups(group)
  local xOffset = frame_width/2 + -group_width/2
  for i=1,9 do -- hide extra if not config mode
      local yOffset = group_height + 5
      if i == 9 then xOffset = -xOffset end
      for j=1,7 do -- hide extra if not config mode
          local name = "raidslot"..i..j
          local frame = addonFrame[name]
          if not frame then
              frame = CreateFrame("Button", nil, addonFrame)
              frame:SetWidth(group_width)
              frame:SetHeight(group_height)
              frame:SetPoint("TOP", addonFrame, "TOP", xOffset, -yOffset)
              frame:SetBackdrop({
                  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
                  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                  tile = true,
                  tileSize = 16,
                  edgeSize = 16,
                  insets = {
                      left = 4,
                      right = 4,
                      top = 4,
                      bottom = 4,
                  },
              })
              if j <= 2 then
                frame:SetBackdropColor(250/255, 54/255, 35/255, 1)
              elseif j == 3 then
                frame:SetBackdropColor(168/255, 213/255, 148/255, 1)
              else
                frame:SetBackdropColor(255/255, 214/255, 66/255, 1)
              end
              frame:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
              -- Role symbol text
              frame.roleText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
              frame.roleText:SetPoint("RIGHT", frame, "RIGHT", -(5+icon_size), 0)
              frame.roleMarker = frame:CreateTexture(nil, "OVERLAY")
              frame.roleMarker:SetWidth(icon_size)
              frame.roleMarker:SetHeight(icon_size)
              frame.roleMarker:SetPoint("RIGHT", frame, "RIGHT", -5, 0)
              -- Raid marker icon
              frame.raidMarker = frame:CreateTexture(nil, "OVERLAY")
              frame.raidMarker:SetWidth(icon_size)
              frame.raidMarker:SetHeight(icon_size)
              frame.raidMarker:SetPoint("LEFT", frame, "LEFT", 5, 0)
              frame.raidMarker:SetAlpha(0.5, 1, 1, 1)
              frame.raidMarker:Hide()
              -- Name text
              frame.nameText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
              frame.nameText:SetPoint("LEFT", frame.raidMarker, "LEFT", 0, 0)
              -- Set click handler
              local ix_i,ix_j = i,j
              frame:SetScript("OnClick", function () return RaiderOnClick(ix_i,ix_j) end)
              addonFrame[name] = frame
              -- frame.name = name
          end
          yOffset = yOffset + group_height
      end
  xOffset = xOffset - group_width
  end
end

-- Function to handle clicks
local function PromoteOnClick()
  local button = arg1
  if button == "LeftButton" and IsRaidLeader("player") then
      for _,group in ipairs(groups) do
        local member = group[1]
        if member then PromoteToAssistant(member.name) end
      end
  end
end

local function InitPromoteButton()
  local frame = {}
  local name = "promote_button"
  local width = button_width
  frame = CreateFrame("Button", nil, addonFrame)
  frame:SetWidth(width)
  frame:SetHeight(25)
  frame:SetPoint("TOP", addonFrame, "BOTTOM", -button_width, -group_height*2)
  frame:SetBackdrop({
      bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
      edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
      tile = true,
      tileSize = 16,
      edgeSize = 16,
      insets = {
          left = 4,
          right = 4,
          top = 4,
          bottom = 4,
      },
  })
  frame:SetBackdropColor(1, 1, 0, 0.5)
  -- frame:RegisterForClicks('LeftButtonUp')
  -- Name text
  frame.nameText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  frame.nameText:SetPoint("CENTER", frame, "CENTER", 0, 0)
  frame.nameText:SetText("Promote Marks")
  -- Set click handler
  frame:SetScript("OnClick", PromoteOnClick)
  addonFrame[name] = frame
end

-- Function to handle clicks
local function CalcOnClick()
  local button = arg1
  -- print(arg1)
  if button == "LeftButton" then
      groups = {}
      UpdateGroups()
      DisplayGroups()
  end
end

local function InitCalcButton()
  local frame = {}
  local name = "calc_button"
  local width = button_width
  frame = CreateFrame("Button", nil, addonFrame)
  frame:SetWidth(width)
  frame:SetHeight(25)
  frame:SetPoint("TOP", addonFrame, "BOTTOM", 0, -group_height*2)
  frame:SetBackdrop({
      bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
      edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
      tile = true,
      tileSize = 16,
      edgeSize = 16,
      insets = {
          left = 4,
          right = 4,
          top = 4,
          bottom = 4,
      },
  })
  frame:SetBackdropColor(1, 1, 0, 0.5)
  -- frame:RegisterForClicks('LeftButtonUp')
  -- Name text
  frame.nameText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  frame.nameText:SetPoint("CENTER", frame, "CENTER", 0, 0)
  frame.nameText:SetText("Calculate Raid")
  -- Set click handler
  frame:SetScript("OnClick", CalcOnClick)
  addonFrame[name] = frame
end

local function ToggleMarksButton()
  local frame = {}
  local name = "marks_button"
  local width = button_width
  frame = CreateFrame("Button", nil, addonFrame)
  frame:SetWidth(width)
  frame:SetHeight(25)
  frame:SetPoint("TOP", addonFrame, "BOTTOM", button_width, -group_height*2)
  frame:SetBackdrop({
      bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
      edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
      tile = true,
      tileSize = 16,
      edgeSize = 16,
      insets = {
          left = 4,
          right = 4,
          top = 4,
          bottom = 4,
      },
  })
  frame:SetBackdropColor(1, 1, 0, 0.5)
  -- frame:RegisterForClicks('LeftButtonUp')
  -- Name text
  frame.nameText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  frame.nameText:SetPoint("CENTER", frame, "CENTER", 0, 0)
  frame.nameText:SetText("Toggle Marks")
  -- Set click handler
  frame:SetScript("OnClick", function()
    config_mode = not config_mode
    DisplayGroups()
  end)
  addonFrame[name] = frame
end

-- Function to create minimap icon
local function CreateMinimapIcon()
  local minimap_button = CreateFrame("Button", "CThunGroupsMinimapButton", Minimap)
  minimap_button:SetWidth(32)
  minimap_button:SetHeight(32)
  minimap_button:SetFrameStrata("MEDIUM")
  minimap_button:SetMovable(true)
  minimap_button:SetUserPlaced(true)
  minimap_button:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 52 - (80 * cos(0)), (80 * sin(0)) - 52)
  minimap_button:RegisterForDrag("LeftButton")
  minimap_button:SetScript("OnDragStart", function()
    minimap_button:StartMoving()
  end)
  minimap_button:SetScript("OnDragStop", function()
    minimap_button:StopMovingOrSizing()
  end)
  minimap_button:SetScript("OnClick", function()
      local button = arg1 
      if button == "LeftButton" then
        if addonFrame:IsVisible() then
          addonFrame:Hide()
        else
          addonFrame:Show()
        end
      end
  end)

  -- Create circular mask texture
  local mask = minimap_button:CreateTexture(nil, "BACKGROUND")
  mask:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
  mask:SetAllPoints(minimap_button)

  local mask = minimap_button:CreateTexture(nil, "BACKGROUND")
  mask:SetTexture("Interface\\Addons\\CThunGroups\\images\\CircleMask") -- Replace "CircleMask" with your circular mask texture path
  mask:SetAllPoints(minimap_button)

  local texture = minimap_button:CreateTexture(nil, "BACKGROUND")
  texture:SetTexture("Interface\\Icons\\INV_Misc_AhnQirajTrinket_05")
  texture:SetAllPoints(minimap_button)
  texture:SetWidth(32)
  texture:SetHeight(32)

  -- texture:AddMaskTexture(mask)

  local overlay = minimap_button:CreateTexture(nil, "OVERLAY")
  overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
  overlay:SetAllPoints(minimap_button)
  overlay:SetWidth(32)
  overlay:SetHeight(32)

    minimap_button:SetScript("OnEnter", function()
        GameTooltip:SetOwner(minimap_button, "ANCHOR_LEFT")
        GameTooltip:SetText("My Addon", 1, 1, 1)
        GameTooltip:AddLine("Click to do something", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    minimap_button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

  return minimap_button
end

local function EventHandler()
  if enabled then
    if event == "RAID_ROSTER_UPDATE" then
      -- print("roster update")
      UpdateRaidMembers()
      UpdateGroups()
      DisplayGroups()
    end
  end
end

local function InitAddon()
  if event == "ADDON_LOADED" and arg1 == "CThunGroups" then
    -- print("loaded")
    if not CThunGroupsDB then CThunGroupsDB = {} end
    local i_guild,_ = GetGuildInfo("player")
    guild = i_guild or guild
    if not CThunGroupsDB[guild] then CThunGroupsDB[guild] = {} end
    if DEBUG then DataSource = raidMemberDataExmple else DataSource = CThunGroupsDB[guild] end
    -- if DEBUG then DataSource = raidMemberDataExmple else DataSource = CThunGroupsDB[guild] end

    -- Create minimap icon
    -- local minimapIcon = CreateMinimapIcon() 
    -- ^ no good yet

    InitDisplayGroups()
    InitCalcButton()
    InitPromoteButton()
    ToggleMarksButton()
    UpdateRaidMembers()
    UpdateGroups()
    DisplayGroups()
    addonFrame:SetScript("OnEvent",EventHandler)
  end
end

-- local delay = 1
-- function ShowWhenAltZ()
--   local now = GetTime()
--   delay = delay - arg1
--   if delay <= 0 and showAddon then
--     delay = 1
--     -- print("showing",delay)
--     addonFrame:Show()
--   end
-- end

addonFrame:RegisterEvent("RAID_ROSTER_UPDATE")
addonFrame:RegisterEvent("ADDON_LOADED")
addonFrame:SetScript("OnEvent",InitAddon)
-- addonFrame:SetScript("OnUpdate",ShowWhenAltZ)

function CThunGroupsDeleteUnknown()
  for k,v in pairs(CThunGroupsDB[guild]) do
    if v.symbol == 9 then
      CThunGroupsDB[guild][k] = nil
    end
  end
end

SLASH_CTHUNGROUPS1 = "/ctg";
SLASH_CTHUNGROUPS2 = "/cthungroups";
SlashCmdList["CTHUNGROUPS"] =
function()
  if addonFrame:IsVisible() then
    showAddon = false
    addonFrame:Hide()
  else
    showAddon = true
    addonFrame:Show()
  end
end
