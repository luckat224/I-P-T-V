-- ============================================================================
-- LUCKATHUB ULTIMATE v8.1 - DELTA MOBILE DEFINITIVE FIX
-- v8.0 FIX: PaddingAll -> PaddingTop/Bottom/Left/Right (UI now renders)
-- v8.1 FIX: Remove TweenService (silently fails on Delta Mobile)
--           -> Direct property assignment for tab highlight & toggle switches
-- ============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")

local lp = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- ====== SAFE PARENT ======
local safeParent = nil
pcall(function() if gethui then safeParent = gethui() end end)
if not safeParent then pcall(function() safeParent = game:GetService("CoreGui") end) end
if not safeParent then safeParent = lp:WaitForChild("PlayerGui") end

-- ====== CLEANUP OLD GUI ======
pcall(function()
    for _, v in ipairs(safeParent:GetChildren()) do
        if v.Name and string.find(v.Name, "Luckat") then
            pcall(function() v:Destroy() end)
        end
    end
end)

-- ====== NOTIFY ======
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "LuckatHub v8.0";
        Text = "Dang khoi tao...";
        Duration = 2;
    })
end)

-- ====== CONFIG ======
local CFG = {
    SpeedOn = false, Speed = 40,
    JumpOn = false, JumpPow = 80,
    FlyOn = false, FlySpeed = 60,
    NoclipOn = false,
    AntiAFKOn = true,
    AntiStunOn = true,
    AntiVoidOn = true,
    WallhackOn = true,
    AimbotOn = false,
    OnScreenBtns = false,
    FixLagOn = false,
    GhostOn = false,
    AntiHackOn = false, AntiHackRadius = 8, AntiHackPush = 18,
    PhantomOn = true, PhantomForce = 120,
}

-- ====== CHARACTER CACHE ======
local cc = {}
local function refreshCC()
    cc.char = lp.Character
    if cc.char then
        cc.hum = cc.char:FindFirstChildOfClass("Humanoid")
        cc.hrp = cc.char:FindFirstChild("HumanoidRootPart")
    end
end
refreshCC()
lp.CharacterAdded:Connect(function() task.wait(0.3) refreshCC() end)

-- ====== HELPER: set 4 paddings ======
local function setPadding(uipad, top, bot, left, right)
    uipad.PaddingTop = UDim.new(0, top)
    uipad.PaddingBottom = UDim.new(0, bot or top)
    uipad.PaddingLeft = UDim.new(0, left or top)
    uipad.PaddingRight = UDim.new(0, right or left or top)
end

-- ====== HELPER: direct set (NO TweenService - crashes Delta Mobile) ======
local function setProps(obj, props)
    for k, v in pairs(props) do
        pcall(function() obj[k] = v end)
    end
end

-- ====== HELPER: draggable (mobile touch) ======
-- KHÔNG dùng UIS.InputChanged toàn cục (chặn joystick + camera)
-- Chỉ theo dõi input.Changed trên chính input đã bắt đầu trên handle
local function makeDrag(frame, handle)
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            local startInputPos = input.Position
            local startFramePos = frame.Position
            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    if conn then conn:Disconnect() conn = nil end
                    return
                end
                local delta = input.Position - startInputPos
                frame.Position = UDim2.new(
                    startFramePos.X.Scale, startFramePos.X.Offset + delta.X,
                    startFramePos.Y.Scale, startFramePos.Y.Offset + delta.Y
                )
            end)
        end
    end)
end

-- ====================================================================
-- BUILD GUI
-- ====================================================================
local gui = Instance.new("ScreenGui")
gui.Name = "LuckatHub_Main"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.Parent = safeParent

-- ====== FLOATING BUTTON ======
local floatBtn = Instance.new("TextButton")
floatBtn.Name = "LuckatFloat"
floatBtn.Size = UDim2.new(0, 110, 0, 30)
floatBtn.Position = UDim2.new(0, 10, 0.12, 0)
floatBtn.BackgroundColor3 = Color3.fromRGB(100, 30, 190)
floatBtn.Text = "LuckatHub"
floatBtn.TextColor3 = Color3.new(1, 1, 1)
floatBtn.TextSize = 13
floatBtn.Font = Enum.Font.SourceSansBold
floatBtn.BorderSizePixel = 0
floatBtn.ZIndex = 50
floatBtn.Parent = gui
local fc = Instance.new("UICorner")
fc.CornerRadius = UDim.new(0, 8)
fc.Parent = floatBtn
local fs = Instance.new("UIStroke")
fs.Color = Color3.fromRGB(200, 160, 255)
fs.Thickness = 1
fs.Parent = floatBtn
makeDrag(floatBtn, floatBtn)

-- ====== MAIN WINDOW ======
local win = Instance.new("Frame")
win.Name = "Win"
win.Size = UDim2.new(0, 450, 0, 290)
win.Position = UDim2.new(0.5, -225, 0.5, -145)
win.BackgroundColor3 = Color3.fromRGB(14, 15, 22)
win.BorderSizePixel = 0
win.ZIndex = 10
win.ClipsDescendants = true
win.Parent = gui
local wc = Instance.new("UICorner")
wc.CornerRadius = UDim.new(0, 10)
wc.Parent = win
local ws = Instance.new("UIStroke")
ws.Color = Color3.fromRGB(110, 35, 200)
ws.Thickness = 1.5
ws.Parent = win

-- ====== HEADER ======
local hdr = Instance.new("Frame")
hdr.Size = UDim2.new(1, 0, 0, 34)
hdr.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
hdr.BorderSizePixel = 0
hdr.ZIndex = 11
hdr.Parent = win
local hc = Instance.new("UICorner")
hc.CornerRadius = UDim.new(0, 10)
hc.Parent = hdr
-- patch bottom corners
local hdrPatch = Instance.new("Frame")
hdrPatch.Size = UDim2.new(1, 0, 0, 10)
hdrPatch.Position = UDim2.new(0, 0, 1, -10)
hdrPatch.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
hdrPatch.BorderSizePixel = 0
hdrPatch.ZIndex = 11
hdrPatch.Parent = hdr

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "LuckatHub VIP PRO"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 14
title.Font = Enum.Font.SourceSansBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 12
title.Parent = hdr

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 22, 0, 22)
closeBtn.Position = UDim2.new(1, -28, 0.5, -11)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.TextSize = 12
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 12
closeBtn.Parent = hdr
local cc2 = Instance.new("UICorner")
cc2.CornerRadius = UDim.new(0, 5)
cc2.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function() win.Visible = false end)
floatBtn.MouseButton1Click:Connect(function() win.Visible = not win.Visible end)
makeDrag(win, hdr)

-- ====== SIDEBAR ======
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 120, 1, -34)
sidebar.Position = UDim2.new(0, 0, 0, 34)
sidebar.BackgroundColor3 = Color3.fromRGB(18, 20, 30)
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 11
sidebar.Parent = win
local sideLayout = Instance.new("UIListLayout")
sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
sideLayout.Padding = UDim.new(0, 3)
sideLayout.Parent = sidebar
local sidePad = Instance.new("UIPadding")
setPadding(sidePad, 6, 6, 5, 5)
sidePad.Parent = sidebar

-- ====== CONTENT AREA ======
local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, -120, 1, -34)
content.Position = UDim2.new(0, 120, 0, 34)
content.BackgroundColor3 = Color3.fromRGB(16, 17, 25)
content.BorderSizePixel = 0
content.ZIndex = 11
content.ClipsDescendants = true
content.Parent = win

-- Separator line
local sep = Instance.new("Frame")
sep.Size = UDim2.new(0, 1, 1, -34)
sep.Position = UDim2.new(0, 120, 0, 34)
sep.BackgroundColor3 = Color3.fromRGB(60, 30, 110)
sep.BorderSizePixel = 0
sep.ZIndex = 12
sep.Parent = win

-- ====== TAB SYSTEM ======
local tabPanels = {}
local tabBtns = {}
local activeTab = ""
local ACTIVE_BG = Color3.fromRGB(100, 30, 185)
local INACTIVE_BG = Color3.fromRGB(24, 26, 38)

local function switchTab(id)
    activeTab = id
    for tid, panel in pairs(tabPanels) do
        panel.Visible = (tid == id)
    end
    for tid, btn in pairs(tabBtns) do
        local on = (tid == id)
        btn.BackgroundColor3 = on and ACTIVE_BG or INACTIVE_BG
        btn.TextColor3 = on and Color3.new(1,1,1) or Color3.fromRGB(160, 165, 185)
    end
end

local sideOrder = 0

local function makeTab(id, label)
    sideOrder = sideOrder + 1

    -- Sidebar button
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.BackgroundColor3 = INACTIVE_BG
    btn.Text = "  " .. label
    btn.TextColor3 = Color3.fromRGB(160, 165, 185)
    btn.TextSize = 12
    btn.Font = Enum.Font.SourceSansBold
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.LayoutOrder = sideOrder
    btn.ZIndex = 12
    btn.Parent = sidebar
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 5)
    bc.Parent = btn

    -- Content panel
    local panel = Instance.new("Frame")
    panel.Name = "P_" .. id
    panel.Size = UDim2.new(1, 0, 1, 0)
    panel.BackgroundTransparency = 1
    panel.BorderSizePixel = 0
    panel.Visible = false
    panel.ZIndex = 12
    panel.Parent = content

    -- ScrollingFrame inside panel
    local sf = Instance.new("ScrollingFrame")
    sf.Name = "SF"
    sf.Size = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 4
    sf.ScrollBarImageColor3 = Color3.fromRGB(100, 30, 185)
    sf.CanvasSize = UDim2.new(0, 0, 0, 900)
    sf.ZIndex = 13
    sf.Parent = panel

    local list = Instance.new("UIListLayout")
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 5)
    list.Parent = sf

    -- FIX: Use individual padding properties (PaddingAll does NOT exist!)
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 7)
    pad.PaddingBottom = UDim.new(0, 7)
    pad.PaddingLeft = UDim.new(0, 7)
    pad.PaddingRight = UDim.new(0, 7)
    pad.Parent = sf

    tabPanels[id] = panel
    tabBtns[id] = btn

    btn.MouseButton1Click:Connect(function() switchTab(id) end)
    return sf
end

-- ====== WIDGET BUILDERS ======
local CARD_BG = Color3.fromRGB(24, 26, 40)
local ON_COL = Color3.fromRGB(0, 210, 100)
local OFF_COL = Color3.fromRGB(38, 40, 58)
local rowOrder = 0

local function nextOrd()
    rowOrder = rowOrder + 1
    return rowOrder
end

local function addLabel(sf, txt)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -4, 0, 16)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = Color3.fromRGB(130, 135, 165)
    l.TextSize = 11
    l.Font = Enum.Font.SourceSansBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.LayoutOrder = nextOrd()
    l.ZIndex = 15
    l.Parent = sf
end

local function addSwitch(sf, label, default, onChange)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 32)
    row.BackgroundColor3 = CARD_BG
    row.BorderSizePixel = 0
    row.LayoutOrder = nextOrd()
    row.ZIndex = 15
    row.Parent = sf
    local rc = Instance.new("UICorner")
    rc.CornerRadius = UDim.new(0, 6)
    rc.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -50, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(220, 225, 240)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextWrapped = true
    lbl.ZIndex = 16
    lbl.Parent = row

    local track = Instance.new("TextButton")
    track.Size = UDim2.new(0, 34, 0, 16)
    track.Position = UDim2.new(1, -42, 0.5, -8)
    track.BackgroundColor3 = default and ON_COL or OFF_COL
    track.Text = ""
    track.BorderSizePixel = 0
    track.AutoButtonColor = false
    track.ZIndex = 16
    track.Parent = row
    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(1, 0)
    tc.Parent = track

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 11, 0, 11)
    knob.Position = default and UDim2.new(1, -13, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.ZIndex = 17
    knob.Parent = track
    local kc = Instance.new("UICorner")
    kc.CornerRadius = UDim.new(1, 0)
    kc.Parent = knob

    local state = default
    track.MouseButton1Click:Connect(function()
        state = not state
        track.BackgroundColor3 = state and ON_COL or OFF_COL
        knob.Position = state and UDim2.new(1, -13, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
        pcall(onChange, state)
    end)
end

local function addNum(sf, label, val, mn, mx, onChange)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 32)
    row.BackgroundColor3 = CARD_BG
    row.BorderSizePixel = 0
    row.LayoutOrder = nextOrd()
    row.ZIndex = 15
    row.Parent = sf
    local rc = Instance.new("UICorner")
    rc.CornerRadius = UDim.new(0, 6)
    rc.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.55, 0, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(220, 225, 240)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 16
    lbl.Parent = row

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.35, 0, 0, 22)
    box.Position = UDim2.new(0.63, 0, 0.5, -11)
    box.BackgroundColor3 = Color3.fromRGB(32, 35, 52)
    box.Text = tostring(val)
    box.TextColor3 = Color3.fromRGB(0, 230, 150)
    box.TextSize = 12
    box.Font = Enum.Font.SourceSansBold
    box.ClearTextOnFocus = false
    box.BorderSizePixel = 0
    box.ZIndex = 16
    box.Parent = row
    local bxc = Instance.new("UICorner")
    bxc.CornerRadius = UDim.new(0, 5)
    bxc.Parent = box

    box.FocusLost:Connect(function()
        local n = tonumber(box.Text)
        if n then
            n = math.clamp(n, mn, mx)
            box.Text = tostring(n)
            pcall(onChange, n)
        else
            box.Text = tostring(val)
        end
    end)
end

local function addBtn(sf, label, col, onClick)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 0, 30)
    btn.BackgroundColor3 = col or ACTIVE_BG
    btn.Text = label
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 12
    btn.Font = Enum.Font.SourceSansBold
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.LayoutOrder = nextOrd()
    btn.ZIndex = 15
    btn.Parent = sf
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 6)
    bc.Parent = btn
    btn.MouseButton1Click:Connect(function() pcall(onClick) end)
end

-- ====== CREATE 5 TABS ======
local t1 = makeTab("move", "[1] Di Chuyen")
local t2 = makeTab("combat", "[2] Tac Chien")
local t3 = makeTab("protect", "[3] Bao Ve")
local t4 = makeTab("bypass", "[4] Ultra Bypass")
local t5 = makeTab("lag", "[5] Fix Lag")

-- ====== POPULATE TAB 1: DI CHUYEN ======
addLabel(t1, "--- TOC DO & NHAY ---")
addSwitch(t1, "Speed Hack", CFG.SpeedOn, function(v) CFG.SpeedOn = v end)
addNum(t1, "Toc do", CFG.Speed, 16, 300, function(v) CFG.Speed = v end)
addSwitch(t1, "Jump Hack", CFG.JumpOn, function(v) CFG.JumpOn = v end)
addNum(t1, "Jump Power", CFG.JumpPow, 50, 600, function(v) CFG.JumpPow = v end)
addLabel(t1, "--- NANG CAO ---")
addSwitch(t1, "Bay (Fly)", CFG.FlyOn, function(v) CFG.FlyOn = v end)
addNum(t1, "Fly Speed", CFG.FlySpeed, 10, 300, function(v) CFG.FlySpeed = v end)
addSwitch(t1, "Xuyen Tuong (Noclip)", CFG.NoclipOn, function(v) CFG.NoclipOn = v end)

-- ====== POPULATE TAB 2: TAC CHIEN ======
addLabel(t2, "--- QUAN SAT ---")
addSwitch(t2, "Wallhack ESP", CFG.WallhackOn, function(v)
    CFG.WallhackOn = v
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local hl = p.Character:FindFirstChild("LH_hl")
            if hl then hl.Enabled = v end
        end
    end
end)
addLabel(t2, "--- CHIEN DAU ---")
addSwitch(t2, "Aimbot (Tu dong ngam)", CFG.AimbotOn, function(v) CFG.AimbotOn = v end)
addSwitch(t2, "Hien Nut HUD Man Hinh", CFG.OnScreenBtns, function(v)
    CFG.OnScreenBtns = v
    if _G.LH_toggleHUD then _G.LH_toggleHUD(v) end
end)

-- ====== POPULATE TAB 3: BAO VE ======
addLabel(t3, "--- SONG SOT ---")
addSwitch(t3, "Anti-AFK", CFG.AntiAFKOn, function(v) CFG.AntiAFKOn = v end)
addSwitch(t3, "Anti-Stun / Anti-Ragdoll", CFG.AntiStunOn, function(v) CFG.AntiStunOn = v end)
addSwitch(t3, "Anti-Void (Chong roi vuc)", CFG.AntiVoidOn, function(v) CFG.AntiVoidOn = v end)
addLabel(t3, "--- CHONG HACKER ---")
addSwitch(t3, "Anti-Hacker Teleport", CFG.AntiHackOn, function(v) CFG.AntiHackOn = v end)
addNum(t3, "Ban kinh (studs)", CFG.AntiHackRadius, 3, 30, function(v) CFG.AntiHackRadius = v end)
addNum(t3, "Luc day ra", CFG.AntiHackPush, 8, 60, function(v) CFG.AntiHackPush = v end)
addLabel(t3, "--- GHOST MODE v2 ---")
addSwitch(t3, "Ghost Mode", CFG.GhostOn, function(v) CFG.GhostOn = v end)
addSwitch(t3, "Phantom Velocity", CFG.PhantomOn, function(v) CFG.PhantomOn = v end)
addNum(t3, "Phantom Force", CFG.PhantomForce, 50, 200, function(v) CFG.PhantomForce = v end)

-- ====== POPULATE TAB 4: ULTRA BYPASS ======
addLabel(t4, "--- CHONG KICK/BAN ---")
addSwitch(t4, "Kick Block", true, function(v)
    if _G.LH_setKickBlock then _G.LH_setKickBlock(v) end
end)
addSwitch(t4, "Remote Blacklist Filter", true, function(v)
    if _G.LH_setRemoteFilter then _G.LH_setRemoteFilter(v) end
end)
addLabel(t4, "--- CONG CU ---")
addBtn(t4, "Nguy Trang Ten Script", Color3.fromRGB(80, 40, 160), function()
    pcall(function()
        local names = {"PlayerModule", "CameraModule", "ControlModule", "ChatMain", "BubbleChat"}
        if script and script.Parent then
            script.Name = names[math.random(#names)]
        end
    end)
end)
addBtn(t4, "Scan & Yield AC Threads", Color3.fromRGB(160, 40, 40), function()
    pcall(function()
        if not getthreads then return end
        local count = 0
        local kws = {"speedcheck", "positioncheck", "anticheat", "velocity_check", "sanity"}
        for _, th in ipairs(getthreads()) do
            pcall(function()
                local info = tostring(th):lower()
                for _, kw in ipairs(kws) do
                    if info:find(kw, 1, true) then
                        task.defer(function() coroutine.yield(th) end)
                        count = count + 1
                        break
                    end
                end
            end)
        end
    end)
end)
addLabel(t4, "--- TRANG THAI ---")
local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(1, -4, 0, 26)
statusLbl.BackgroundColor3 = Color3.fromRGB(15, 38, 22)
statusLbl.TextColor3 = Color3.fromRGB(0, 240, 120)
statusLbl.TextSize = 11
statusLbl.Font = Enum.Font.SourceSansBold
statusLbl.TextWrapped = true
statusLbl.BorderSizePixel = 0
statusLbl.LayoutOrder = nextOrd()
statusLbl.ZIndex = 15
statusLbl.Text = "Bypass: Dang khoi dong..."
statusLbl.Parent = t4
local slc = Instance.new("UICorner")
slc.CornerRadius = UDim.new(0, 5)
slc.Parent = statusLbl

-- ====== POPULATE TAB 5: FIX LAG ======
addLabel(t5, "--- TOI UU HIEU NANG ---")
addBtn(t5, "Bat Fix Lag Live", Color3.fromRGB(0, 160, 110), function()
    if _G.LH_fixLagOn then _G.LH_fixLagOn() end
end)
addBtn(t5, "Tat Fix Lag", Color3.fromRGB(180, 40, 40), function()
    if _G.LH_fixLagOff then _G.LH_fixLagOff() end
end)
addLabel(t5, "--- DO HOA ---")
addBtn(t5, "Ultra Low Graphics (Max FPS)", Color3.fromRGB(20, 120, 210), function()
    if _G.LH_ultraLow then _G.LH_ultraLow() end
end)
addBtn(t5, "Xoa Bong & Suong Mu", Color3.fromRGB(120, 70, 200), function()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.FogStart = 9e9
end)

-- ====== OPEN DEFAULT TAB ======
switchTab("move")

-- ====================================================================
-- SUBSYSTEMS (all in task.spawn for isolation)
-- ====================================================================

-- ====== PHYSICS ENGINE ======
task.spawn(function()
    local flyBV, flyBG
    RunService.Heartbeat:Connect(function()
        local hum = cc.hum
        local hrp = cc.hrp
        if not hum or not hrp or hum.Health <= 0 then return end

        if CFG.JumpOn then
            hum.UseJumpPower = true
            hum.JumpPower = CFG.JumpPow
        end

        if CFG.SpeedOn then
            local dir = hum.MoveDirection
            if dir.Magnitude > 0.05 then
                hrp.AssemblyLinearVelocity = Vector3.new(dir.X * CFG.Speed, hrp.AssemblyLinearVelocity.Y, dir.Z * CFG.Speed)
            end
        end

        if CFG.NoclipOn and cc.char then
            for _, p in ipairs(cc.char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end

        if CFG.AntiStunOn and cc.char then
            hum.PlatformStand = false
            for _, c in ipairs(cc.char:GetChildren()) do
                local n = c.Name
                if n == "Stun" or n == "Freeze" or n == "Ragdoll" or n == "Knockback" then
                    pcall(function() c:Destroy() end)
                end
            end
        end

        if CFG.AntiVoidOn and hrp.Position.Y < -150 then
            hrp.CFrame = CFrame.new(hrp.Position.X, 80, hrp.Position.Z)
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
    end)

    RunService.RenderStepped:Connect(function()
        local hrp = cc.hrp
        local hum = cc.hum
        if not hrp then return end
        if CFG.FlyOn then
            if not flyBV or not flyBV.Parent then
                flyBV = Instance.new("BodyVelocity")
                flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                flyBV.Velocity = Vector3.zero
                flyBV.Parent = hrp
            end
            if not flyBG or not flyBG.Parent then
                flyBG = Instance.new("BodyGyro")
                flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
                flyBG.P = 5e4
                flyBG.CFrame = hrp.CFrame
                flyBG.Parent = hrp
            end
            local dir = hum and hum.MoveDirection or Vector3.zero
            flyBG.CFrame = camera.CFrame
            flyBV.Velocity = dir * CFG.FlySpeed
        else
            if flyBV and flyBV.Parent then pcall(function() flyBV:Destroy() end) flyBV = nil end
            if flyBG and flyBG.Parent then pcall(function() flyBG:Destroy() end) flyBG = nil end
        end
    end)
end)

-- ====== ANTI-AFK ======
task.spawn(function()
    lp.Idled:Connect(function()
        if not CFG.AntiAFKOn then return end
        pcall(function()
            VirtualUser:Button2Down(Vector2.zero, camera.CFrame)
            task.wait(0.5)
            VirtualUser:Button2Up(Vector2.zero, camera.CFrame)
        end)
    end)
end)

-- ====== WALLHACK ESP ======
task.spawn(function()
    local function applyHL(char)
        pcall(function()
            local old = char:FindFirstChild("LH_hl")
            if old then old:Destroy() end
            local hl = Instance.new("Highlight")
            hl.Name = "LH_hl"
            hl.FillColor = Color3.fromRGB(255, 50, 50)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.5
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Enabled = CFG.WallhackOn
            hl.Parent = char
        end)
    end
    local function setupP(p)
        if p == lp then return end
        if p.Character then applyHL(p.Character) end
        p.CharacterAdded:Connect(function(c) task.wait(0.5) applyHL(c) end)
    end
    for _, p in ipairs(Players:GetPlayers()) do setupP(p) end
    Players.PlayerAdded:Connect(setupP)
end)

-- ====== AIMBOT ======
task.spawn(function()
    RunService.RenderStepped:Connect(function()
        if not CFG.AimbotOn then return end
        local camPos = camera.CFrame.Position
        local camDir = camera.CFrame.LookVector
        local best, bestDot = nil, 0.90
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                local r = p.Character:FindFirstChild("HumanoidRootPart")
                local h = p.Character:FindFirstChildOfClass("Humanoid")
                if r and h and h.Health > 0 then
                    local d = camDir:Dot((r.Position - camPos).Unit)
                    if d > bestDot then bestDot = d best = p end
                end
            end
        end
        if best and best.Character then
            local aim = best.Character:FindFirstChild("Head") or best.Character:FindFirstChild("HumanoidRootPart")
            if aim then camera.CFrame = CFrame.new(camPos, aim.Position) end
        end
    end)
end)

-- ====== GHOST MODE & ANTI-HACKER ======
task.spawn(function()
    local prevPos = {}
    local dodgeCD = 0
    local warnCD = {}
    RunService.Heartbeat:Connect(function()
        local hrp = cc.hrp
        local hum = cc.hum
        if not hrp or not hum then return end
        local myPos = hrp.Position
        local now = tick()

        for _, p in ipairs(Players:GetPlayers()) do
            if p == lp or not p.Character then continue end
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            if not r then prevPos[p] = nil continue end
            local cur = r.Position
            local prev = prevPos[p]

            if prev then
                local jumped = (cur - prev).Magnitude
                local dist = (cur - myPos).Magnitude

                -- Anti-Hacker TP
                if CFG.AntiHackOn and jumped > 80 and dist < CFG.AntiHackRadius then
                    if not warnCD[p] or now - warnCD[p] > 2 then
                        warnCD[p] = now
                        local pushDir = (myPos - cur)
                        if pushDir.Magnitude > 0 then pushDir = pushDir.Unit else pushDir = -camera.CFrame.LookVector end
                        hrp.CFrame = CFrame.new(myPos + pushDir * CFG.AntiHackPush)
                        hrp.AssemblyLinearVelocity = pushDir * 25
                    end
                end

                -- Ghost Mode dodge
                if CFG.GhostOn and jumped > 60 and dist < 15 and now - dodgeCD > 0.4 then
                    dodgeCD = now
                    local angle = math.random() * math.pi * 2
                    local escDir = Vector3.new(math.cos(angle), 0, math.sin(angle))
                    if CFG.PhantomOn then
                        hrp.AssemblyLinearVelocity = Vector3.new(escDir.X * CFG.PhantomForce, 40, escDir.Z * CFG.PhantomForce)
                    else
                        hrp.CFrame = CFrame.new(myPos + escDir * 20)
                    end
                end
            end
            prevPos[p] = cur
        end
    end)
end)

-- ====== BYPASS ENGINE ======
task.spawn(function()
    local kickBlock = true
    local remFilter = true
    local hooked = false

    pcall(function()
        if typeof(hookmetamethod) ~= "function" then return end
        if typeof(getnamecallmethod) ~= "function" then return end
        local oldNC = hookmetamethod(game, "__namecall", function(self, ...)
            local m = getnamecallmethod()
            if kickBlock and (m == "Kick" or m == "Ban") then return nil end
            if remFilter and (m == "FireServer" or m == "InvokeServer") then
                local ok, n = pcall(function() return self.Name:lower() end)
                if ok and n then
                    for _, kw in ipairs({"report","cheat","hack","detect","ban","kick","anticheat","sanity","exploit","flag"}) do
                        if n:find(kw, 1, true) then return nil end
                    end
                end
            end
            return oldNC(self, ...)
        end)
        hooked = true
    end)

    _G.LH_setKickBlock = function(v) kickBlock = v end
    _G.LH_setRemoteFilter = function(v) remFilter = v end

    if statusLbl then
        statusLbl.Text = "KickBlock: ON | Filter: ON | Hook: " .. (hooked and "OK" or "Safe")
    end
end)

-- ====== FIX LAG ENGINE ======
local fixConn = nil
local FX = {ParticleEmitter=true, Trail=true, Beam=true, Sparkles=true, Fire=true, Smoke=true}
local function stripFX(o)
    pcall(function() if FX[o.ClassName] then o.Enabled = false end end)
end

_G.LH_fixLagOn = function()
    if fixConn then return end
    for _, o in ipairs(Workspace:GetDescendants()) do stripFX(o) end
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.FogStart = 9e9
    for _, fx in ipairs(Lighting:GetChildren()) do
        if fx:IsA("PostEffect") then fx.Enabled = false end
    end
    fixConn = Workspace.DescendantAdded:Connect(function(o) task.defer(stripFX, o) end)
    CFG.FixLagOn = true
end

_G.LH_fixLagOff = function()
    if fixConn then fixConn:Disconnect() fixConn = nil end
    CFG.FixLagOn = false
end

_G.LH_ultraLow = function()
    _G.LH_fixLagOn()
    for _, o in ipairs(Workspace:GetDescendants()) do
        pcall(function()
            if o:IsA("BasePart") then
                o.Material = Enum.Material.SmoothPlastic
                o.CastShadow = false
            elseif o:IsA("Decal") or o:IsA("Texture") then
                o.Transparency = 1
            elseif o:IsA("MeshPart") then
                o.RenderFidelity = Enum.RenderFidelity.Performance
            end
        end)
    end
    local t = Workspace:FindFirstChildOfClass("Terrain")
    if t then t.WaterWaveSize = 0 t.WaterWaveSpeed = 0 end
end

-- ====== ON-SCREEN HUD ======
local hudGUI = nil
_G.LH_toggleHUD = function(on)
    if hudGUI then pcall(function() hudGUI:Destroy() end) hudGUI = nil end
    if not on then return end

    hudGUI = Instance.new("ScreenGui")
    hudGUI.Name = "LuckatHub_HUD"
    hudGUI.ResetOnSpawn = false
    hudGUI.ZIndexBehavior = Enum.ZIndexBehavior.Global
    hudGUI.Parent = safeParent

    local tpBtn = Instance.new("TextButton")
    tpBtn.Size = UDim2.new(0, 70, 0, 70)
    tpBtn.Position = UDim2.new(0, 18, 0, 18)
    tpBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    tpBtn.Text = "TELEPORT"
    tpBtn.TextColor3 = Color3.new(1, 1, 1)
    tpBtn.TextSize = 11
    tpBtn.Font = Enum.Font.SourceSansBold
    tpBtn.BorderSizePixel = 0
    tpBtn.ZIndex = 60
    tpBtn.Parent = hudGUI
    local tpc = Instance.new("UICorner")
    tpc.CornerRadius = UDim.new(1, 0)
    tpc.Parent = tpBtn

    local aimBtn = Instance.new("TextButton")
    aimBtn.Size = UDim2.new(0, 80, 0, 32)
    aimBtn.Position = UDim2.new(1, -98, 0, 18)
    aimBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 220)
    aimBtn.Text = "AIM OFF"
    aimBtn.TextColor3 = Color3.new(1, 1, 1)
    aimBtn.TextSize = 11
    aimBtn.Font = Enum.Font.SourceSansBold
    aimBtn.BorderSizePixel = 0
    aimBtn.ZIndex = 60
    aimBtn.Parent = hudGUI
    local ac = Instance.new("UICorner")
    ac.CornerRadius = UDim.new(0, 6)
    ac.Parent = aimBtn

    local locked = false
    local lockTarget = nil
    local followConn = nil

    local function getTarget()
        local camPos = camera.CFrame.Position
        local camDir = camera.CFrame.LookVector
        local best, bestD = nil, 0.88
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                local r = p.Character:FindFirstChild("HumanoidRootPart")
                local h = p.Character:FindFirstChildOfClass("Humanoid")
                if r and h and h.Health > 0 then
                    local d = camDir:Dot((r.Position - camPos).Unit)
                    if d > bestD then bestD = d best = p end
                end
            end
        end
        return best
    end

    local function tpTo(target)
        if not target or not target.Character then return end
        local tr = target.Character:FindFirstChild("HumanoidRootPart")
        local pr = cc.hrp
        if not tr or not pr then return end
        pr.CFrame = CFrame.new(tr.Position + tr.CFrame.RightVector * 2, tr.Position)
    end

    tpBtn.MouseButton1Click:Connect(function()
        if locked then
            locked = false
            lockTarget = nil
            if followConn then followConn:Disconnect() followConn = nil end
            tpBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
            tpBtn.Text = "TELEPORT"
        else
            local t = getTarget()
            if not t then
                tpBtn.Text = "NO TARGET"
                task.delay(1, function() if tpBtn.Parent then tpBtn.Text = "TELEPORT" end end)
                return
            end
            locked = true
            lockTarget = t
            tpBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
            tpBtn.Text = "LOCKED"
            tpTo(t)
            if followConn then followConn:Disconnect() end
            followConn = RunService.Heartbeat:Connect(function()
                if not locked or not lockTarget or not lockTarget.Character then
                    if followConn then followConn:Disconnect() followConn = nil end
                    locked = false
                    lockTarget = nil
                    if tpBtn.Parent then
                        tpBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
                        tpBtn.Text = "TELEPORT"
                    end
                    return
                end
                tpTo(lockTarget)
            end)
        end
    end)

    aimBtn.MouseButton1Click:Connect(function()
        CFG.AimbotOn = not CFG.AimbotOn
        aimBtn.BackgroundColor3 = CFG.AimbotOn and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(50, 50, 220)
        aimBtn.Text = CFG.AimbotOn and "AIM ON" or "AIM OFF"
    end)
end

-- ====== DONE ======
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "LuckatHub v8.0";
        Text = "100% Da san sang!";
        Duration = 3;
    })
end)
