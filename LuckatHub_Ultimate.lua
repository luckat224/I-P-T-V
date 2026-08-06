-- ============================================================================
-- LUCKATHUB v9.0 - MOBILE ONLY CLEAN REBUILD (Delta Android)
-- Thiet ke lai hoan toan cho mobile:
--   NO ScrollingFrame  (chiem swipe -> cam xoay/joystick bi dong)
--   NO TweenService    (loi im lang tren Delta Mobile)
--   NO Active=true     (chan joystick)
--   NO UIS.InputChanged global (chan camera)
--   NO PaddingAll      (khong ton tai trong Roblox)
--   NO Emoji / UTF8    (crash Luau tren Delta)
--   Chi dung SourceSansBold, ZIndex Global, direct assignment
-- ============================================================================

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Lighting   = game:GetService("Lighting")
local Workspace  = game:GetService("Workspace")
local VirtualUser= game:GetService("VirtualUser")
local lp         = Players.LocalPlayer
local camera     = Workspace.CurrentCamera

-- ===================== SAFE PARENT =====================
local ROOT = nil
pcall(function() if gethui then ROOT = gethui() end end)
if not ROOT then pcall(function() ROOT = game:GetService("CoreGui") end) end
if not ROOT then ROOT = lp:WaitForChild("PlayerGui") end

-- Cleanup old
pcall(function()
    for _, v in ipairs(ROOT:GetChildren()) do
        if type(v.Name) == "string" and v.Name:find("LuckatHub") then
            pcall(function() v:Destroy() end)
        end
    end
end)

-- ===================== CONFIG =====================
local C = {
    SpeedOn=false,  Speed=40,
    JumpOn=false,   Jump=80,
    FlyOn=false,    FlySpeed=60,
    NoclipOn=false,
    AntiAFK=true,
    AntiStun=true,
    AntiVoid=true,
    Wallhack=true,
    Aimbot=false,
    HUDOn=false,
    GhostOn=false,
    PhantomOn=true, PhantomForce=120,
    AntiHack=false, AntiHackR=8, AntiHackP=18,
    FixLag=false,
}

-- ===================== CHARACTER CACHE =====================
local CH = {}
local function refreshCH()
    CH.char = lp.Character
    CH.hum  = CH.char and CH.char:FindFirstChildOfClass("Humanoid")
    CH.hrp  = CH.char and CH.char:FindFirstChild("HumanoidRootPart")
end
refreshCH()
lp.CharacterAdded:Connect(function() task.wait(0.25) refreshCH() end)

-- ===================== HELPERS =====================
-- Keo tha chi dung input.Changed tren chinh input do, KHONG UIS global
local function makeDrag(frame, handle)
    handle.InputBegan:Connect(function(inp)
        local t = inp.UserInputType
        if t ~= Enum.UserInputType.Touch and t ~= Enum.UserInputType.MouseButton1 then return end
        local s0 = inp.Position
        local f0 = frame.Position
        local conn
        conn = inp.Changed:Connect(function()
            if inp.UserInputState == Enum.UserInputState.End then
                pcall(function() conn:Disconnect() end)
                return
            end
            local d = inp.Position - s0
            frame.Position = UDim2.new(f0.X.Scale, f0.X.Offset + d.X,
                                        f0.Y.Scale, f0.Y.Offset + d.Y)
        end)
    end)
end

-- Gán padding riêng từng thuoc tinh (PaddingAll KHÔNG ton tai)
local function pad4(obj, n)
    obj.PaddingTop    = UDim.new(0, n)
    obj.PaddingBottom = UDim.new(0, n)
    obj.PaddingLeft   = UDim.new(0, n)
    obj.PaddingRight  = UDim.new(0, n)
end

-- ===================== BUILD GUI =====================
local gui = Instance.new("ScreenGui")
gui.Name            = "LuckatHub_Main"
gui.ResetOnSpawn    = false
gui.ZIndexBehavior  = Enum.ZIndexBehavior.Global
gui.Parent          = ROOT

-- === FLOATING BUTTON ===
local floatBtn = Instance.new("TextButton")
floatBtn.Size             = UDim2.new(0,108,0,30)
floatBtn.Position         = UDim2.new(0,10,0.1,0)
floatBtn.BackgroundColor3 = Color3.fromRGB(95,30,185)
floatBtn.Text             = "LuckatHub"
floatBtn.TextColor3       = Color3.new(1,1,1)
floatBtn.TextSize         = 13
floatBtn.Font             = Enum.Font.SourceSansBold
floatBtn.BorderSizePixel  = 0
floatBtn.AutoButtonColor  = false
floatBtn.ZIndex           = 50
floatBtn.Parent           = gui
do local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,8) c.Parent=floatBtn end
do local s=Instance.new("UIStroke") s.Color=Color3.fromRGB(190,140,255) s.Thickness=1 s.Parent=floatBtn end
makeDrag(floatBtn, floatBtn)

-- === MAIN WINDOW ===
-- KHONG dung Active=true (chặn joystick)
local W, H = 440, 310
local win = Instance.new("Frame")
win.Name              = "Win"
win.Size              = UDim2.new(0,W,0,H)
win.Position          = UDim2.new(0.5,-W/2,0.5,-H/2)
win.BackgroundColor3  = Color3.fromRGB(13,14,21)
win.BorderSizePixel   = 0
win.ZIndex            = 10
win.ClipsDescendants  = true
win.Parent            = gui
do local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,10) c.Parent=win end
do local s=Instance.new("UIStroke") s.Color=Color3.fromRGB(110,35,200) s.Thickness=1.5 s.Parent=win end

-- === HEADER ===
local HDR_H = 34
local hdr = Instance.new("Frame")
hdr.Size             = UDim2.new(1,0,0,HDR_H)
hdr.BackgroundColor3 = Color3.fromRGB(20,21,32)
hdr.BorderSizePixel  = 0
hdr.ZIndex           = 11
hdr.Parent           = win
do local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,10) c.Parent=hdr end
-- patch bottom round corners of header
do
    local p=Instance.new("Frame")
    p.Size=UDim2.new(1,0,0,10) p.Position=UDim2.new(0,0,1,-10)
    p.BackgroundColor3=Color3.fromRGB(20,21,32) p.BorderSizePixel=0 p.ZIndex=11 p.Parent=hdr
end

local titleLbl = Instance.new("TextLabel")
titleLbl.Size             = UDim2.new(1,-60,1,0)
titleLbl.Position         = UDim2.new(0,12,0,0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text             = "LuckatHub  VIP PRO"
titleLbl.TextColor3       = Color3.new(1,1,1)
titleLbl.TextSize         = 14
titleLbl.Font             = Enum.Font.SourceSansBold
titleLbl.TextXAlignment   = Enum.TextXAlignment.Left
titleLbl.ZIndex           = 12
titleLbl.Parent           = hdr

local closeBtn = Instance.new("TextButton")
closeBtn.Size             = UDim2.new(0,22,0,22)
closeBtn.Position         = UDim2.new(1,-28,0.5,-11)
closeBtn.BackgroundColor3 = Color3.fromRGB(200,40,40)
closeBtn.Text             = "X"
closeBtn.TextColor3       = Color3.new(1,1,1)
closeBtn.TextSize         = 12
closeBtn.Font             = Enum.Font.SourceSansBold
closeBtn.BorderSizePixel  = 0
closeBtn.AutoButtonColor  = false
closeBtn.ZIndex           = 12
closeBtn.Parent           = hdr
do local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,5) c.Parent=closeBtn end

closeBtn.MouseButton1Click:Connect(function() win.Visible = false end)
floatBtn.MouseButton1Click:Connect(function() win.Visible = not win.Visible end)
makeDrag(win, hdr)

-- === SIDEBAR ===
local SB_W = 112
local sidebar = Instance.new("Frame")
sidebar.Size             = UDim2.new(0,SB_W,1,-HDR_H)
sidebar.Position         = UDim2.new(0,0,0,HDR_H)
sidebar.BackgroundColor3 = Color3.fromRGB(17,18,28)
sidebar.BorderSizePixel  = 0
sidebar.ZIndex           = 11
sidebar.Parent           = win
do
    local l=Instance.new("UIListLayout")
    l.SortOrder=Enum.SortOrder.LayoutOrder l.Padding=UDim.new(0,3) l.Parent=sidebar
    local p=Instance.new("UIPadding") pad4(p,5) p.Parent=sidebar
end

-- Separator
do
    local sep=Instance.new("Frame")
    sep.Size=UDim2.new(0,1,1,-HDR_H) sep.Position=UDim2.new(0,SB_W,0,HDR_H)
    sep.BackgroundColor3=Color3.fromRGB(60,25,110) sep.BorderSizePixel=0 sep.ZIndex=12 sep.Parent=win
end

-- === CONTENT AREA ===
-- KHONG dung ScrollingFrame (chiem swipe gesture)
-- KHONG dung Active=true
local contentArea = Instance.new("Frame")
contentArea.Name             = "ContentArea"
contentArea.Size             = UDim2.new(1,-SB_W,1,-HDR_H)
contentArea.Position         = UDim2.new(0,SB_W,0,HDR_H)
contentArea.BackgroundColor3 = Color3.fromRGB(15,16,24)
contentArea.BorderSizePixel  = 0
contentArea.ZIndex           = 11
contentArea.ClipsDescendants = true
contentArea.Parent           = win

-- ===================== TAB SYSTEM =====================
local tabPanels = {}
local tabBtns   = {}
local ACTIVE_BG   = Color3.fromRGB(95,30,180)
local INACTIVE_BG = Color3.fromRGB(22,24,36)
local ACTIVE_TC   = Color3.new(1,1,1)
local INACTIVE_TC = Color3.fromRGB(155,160,180)
local sideOrder = 0

local function switchTab(id)
    for tid, panel in pairs(tabPanels) do
        panel.Visible = (tid == id)
        -- reset scroll position khi chuyen tab
        local inner = panel:FindFirstChild("Inner")
        if inner then inner.Position = UDim2.new(0,4,0,4) end
    end
    for tid, btn in pairs(tabBtns) do
        local on = (tid == id)
        btn.BackgroundColor3 = on and ACTIVE_BG or INACTIVE_BG
        btn.TextColor3       = on and ACTIVE_TC  or INACTIVE_TC
    end
end

-- Tao tab: tra ve Inner Frame (KHONG phai ScrollingFrame)
local function makeTab(id, label)
    sideOrder = sideOrder + 1

    -- Sidebar button
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1,0,0,27)
    btn.BackgroundColor3 = INACTIVE_BG
    btn.Text             = label
    btn.TextColor3       = INACTIVE_TC
    btn.TextSize         = 12
    btn.Font             = Enum.Font.SourceSansBold
    btn.TextXAlignment   = Enum.TextXAlignment.Left
    btn.BorderSizePixel  = 0
    btn.AutoButtonColor  = false
    btn.LayoutOrder      = sideOrder
    btn.ZIndex           = 12
    btn.Parent           = sidebar
    do
        local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,5) c.Parent=btn
        local p=Instance.new("UIPadding") p.PaddingLeft=UDim.new(0,7) p.Parent=btn
    end

    -- Outer panel (clip frame - KHONG Active)
    local panel = Instance.new("Frame")
    panel.Name             = "Panel_"..id
    panel.Size             = UDim2.new(1,0,1,0)
    panel.BackgroundTransparency = 1
    panel.BorderSizePixel  = 0
    panel.Visible          = false
    panel.ZIndex           = 12
    panel.ClipsDescendants = true
    panel.Parent           = contentArea

    -- Inner frame (di chuyen len/xuong = scroll)
    local inner = Instance.new("Frame")
    inner.Name             = "Inner"
    inner.Size             = UDim2.new(1,-26,0,1800)
    inner.Position         = UDim2.new(0,4,0,4)
    inner.BackgroundTransparency = 1
    inner.BorderSizePixel  = 0
    inner.ZIndex           = 13
    inner.Parent           = panel
    do
        local l=Instance.new("UIListLayout")
        l.SortOrder=Enum.SortOrder.LayoutOrder l.Padding=UDim.new(0,5) l.Parent=inner
    end

    -- Scroll buttons (TextButton - khong dung swipe)
    local SCROLL = 75
    local function clampScroll(val)
        local panH = panel.AbsoluteSize.Y
        local layout = inner:FindFirstChildOfClass("UIListLayout")
        local innerH = layout and (layout.AbsoluteContentSize.Y + 12) or 200
        return math.clamp(val, -(math.max(innerH - panH, 0)), 4)
    end

    local btnUp = Instance.new("TextButton")
    btnUp.Size             = UDim2.new(0,18,0,55)
    btnUp.Position         = UDim2.new(1,-22,0,4)
    btnUp.BackgroundColor3 = Color3.fromRGB(35,37,55)
    btnUp.Text             = "^"
    btnUp.TextColor3       = Color3.fromRGB(160,165,200)
    btnUp.TextSize         = 13
    btnUp.Font             = Enum.Font.SourceSansBold
    btnUp.BorderSizePixel  = 0
    btnUp.AutoButtonColor  = false
    btnUp.ZIndex           = 20
    btnUp.Parent           = panel
    do local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,4) c.Parent=btnUp end

    local btnDn = Instance.new("TextButton")
    btnDn.Size             = UDim2.new(0,18,0,55)
    btnDn.Position         = UDim2.new(1,-22,1,-59)
    btnDn.BackgroundColor3 = Color3.fromRGB(35,37,55)
    btnDn.Text             = "v"
    btnDn.TextColor3       = Color3.fromRGB(160,165,200)
    btnDn.TextSize         = 13
    btnDn.Font             = Enum.Font.SourceSansBold
    btnDn.BorderSizePixel  = 0
    btnDn.AutoButtonColor  = false
    btnDn.ZIndex           = 20
    btnDn.Parent           = panel
    do local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,4) c.Parent=btnDn end

    btnUp.MouseButton1Click:Connect(function()
        local ny = clampScroll(inner.Position.Y.Offset + SCROLL)
        inner.Position = UDim2.new(0,4,0,ny)
    end)
    btnDn.MouseButton1Click:Connect(function()
        local ny = clampScroll(inner.Position.Y.Offset - SCROLL)
        inner.Position = UDim2.new(0,4,0,ny)
    end)

    tabPanels[id] = panel
    tabBtns[id]   = btn
    btn.MouseButton1Click:Connect(function() switchTab(id) end)
    return inner
end

-- ===================== WIDGET BUILDERS =====================
local CARD    = Color3.fromRGB(22,24,38)
local COL_ON  = Color3.fromRGB(0,205,100)
local COL_OFF = Color3.fromRGB(36,38,56)
local rowN = 0
local function nxt() rowN=rowN+1 return rowN end

local function mkLabel(parent, txt)
    local l = Instance.new("TextLabel")
    l.Size              = UDim2.new(1,-4,0,15)
    l.BackgroundTransparency = 1
    l.Text              = txt
    l.TextColor3        = Color3.fromRGB(120,125,155)
    l.TextSize          = 11
    l.Font              = Enum.Font.SourceSansBold
    l.TextXAlignment    = Enum.TextXAlignment.Left
    l.LayoutOrder       = nxt()
    l.ZIndex            = 15
    l.Parent            = parent
end

local function mkToggle(parent, label, default, onChange)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1,-4,0,31)
    row.BackgroundColor3 = CARD
    row.BorderSizePixel  = 0
    row.LayoutOrder      = nxt()
    row.ZIndex           = 15
    row.Parent           = parent
    do local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,6) c.Parent=row end

    local lbl = Instance.new("TextLabel")
    lbl.Size              = UDim2.new(1,-50,1,0)
    lbl.Position          = UDim2.new(0,8,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text              = label
    lbl.TextColor3        = Color3.fromRGB(215,220,235)
    lbl.TextSize          = 12
    lbl.Font              = Enum.Font.SourceSansBold
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.TextWrapped       = true
    lbl.ZIndex            = 16
    lbl.Parent            = row

    local track = Instance.new("TextButton")
    track.Size             = UDim2.new(0,33,0,16)
    track.Position         = UDim2.new(1,-40,0.5,-8)
    track.BackgroundColor3 = default and COL_ON or COL_OFF
    track.Text             = ""
    track.BorderSizePixel  = 0
    track.AutoButtonColor  = false
    track.ZIndex           = 16
    track.Parent           = row
    do local c=Instance.new("UICorner") c.CornerRadius=UDim.new(1,0) c.Parent=track end

    local knob = Instance.new("Frame")
    knob.Size             = UDim2.new(0,11,0,11)
    knob.Position         = default and UDim2.new(1,-13,0.5,-5) or UDim2.new(0,2,0.5,-5)
    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.BorderSizePixel  = 0
    knob.ZIndex           = 17
    knob.Parent           = track
    do local c=Instance.new("UICorner") c.CornerRadius=UDim.new(1,0) c.Parent=knob end

    local state = default
    track.MouseButton1Click:Connect(function()
        state = not state
        -- Direct assignment, NO TweenService
        track.BackgroundColor3 = state and COL_ON or COL_OFF
        knob.Position          = state and UDim2.new(1,-13,0.5,-5) or UDim2.new(0,2,0.5,-5)
        pcall(onChange, state)
    end)
end

local function mkInput(parent, label, val, mn, mx, onChange)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1,-4,0,31)
    row.BackgroundColor3 = CARD
    row.BorderSizePixel  = 0
    row.LayoutOrder      = nxt()
    row.ZIndex           = 15
    row.Parent           = parent
    do local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,6) c.Parent=row end

    local lbl = Instance.new("TextLabel")
    lbl.Size              = UDim2.new(0.56,0,1,0)
    lbl.Position          = UDim2.new(0,8,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text              = label
    lbl.TextColor3        = Color3.fromRGB(215,220,235)
    lbl.TextSize          = 12
    lbl.Font              = Enum.Font.SourceSansBold
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.ZIndex            = 16
    lbl.Parent            = row

    local box = Instance.new("TextBox")
    box.Size              = UDim2.new(0.36,0,0,21)
    box.Position          = UDim2.new(0.62,0,0.5,-10)
    box.BackgroundColor3  = Color3.fromRGB(30,32,50)
    box.Text              = tostring(val)
    box.TextColor3        = Color3.fromRGB(0,225,140)
    box.TextSize          = 12
    box.Font              = Enum.Font.SourceSansBold
    box.ClearTextOnFocus  = false
    box.BorderSizePixel   = 0
    box.ZIndex            = 16
    box.Parent            = row
    do local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,4) c.Parent=box end

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

local function mkButton(parent, label, col, onClick)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1,-4,0,29)
    btn.BackgroundColor3 = col or Color3.fromRGB(95,30,180)
    btn.Text             = label
    btn.TextColor3       = Color3.new(1,1,1)
    btn.TextSize         = 12
    btn.Font             = Enum.Font.SourceSansBold
    btn.BorderSizePixel  = 0
    btn.AutoButtonColor  = false
    btn.LayoutOrder      = nxt()
    btn.ZIndex           = 15
    btn.Parent           = parent
    do local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,6) c.Parent=btn end
    btn.MouseButton1Click:Connect(function() pcall(onClick) end)
end

-- ===================== CREATE TABS =====================
local T1 = makeTab("move",    "[1] Di Chuyen")
local T2 = makeTab("combat",  "[2] Tac Chien")
local T3 = makeTab("protect", "[3] Bao Ve")
local T4 = makeTab("bypass",  "[4] Ultra Bypass")
local T5 = makeTab("lag",     "[5] Fix Lag")

-- ====== TAB 1: DI CHUYEN ======
mkLabel(T1, "--- TOC DO & NHAY ---")
mkToggle(T1,"Speed Hack",   C.SpeedOn, function(v) C.SpeedOn=v end)
mkInput (T1,"Toc do",       C.Speed,   16,300, function(v) C.Speed=v end)
mkToggle(T1,"Jump Hack",    C.JumpOn,  function(v) C.JumpOn=v end)
mkInput (T1,"Jump Power",   C.Jump,    50,600, function(v) C.Jump=v end)
mkLabel(T1, "--- NANG CAO ---")
mkToggle(T1,"Bay (Fly)",    C.FlyOn,   function(v) C.FlyOn=v end)
mkInput (T1,"Fly Speed",    C.FlySpeed,10,300, function(v) C.FlySpeed=v end)
mkToggle(T1,"Xuyen Tuong (Noclip)", C.NoclipOn, function(v) C.NoclipOn=v end)

-- ====== TAB 2: TAC CHIEN ======
mkLabel(T2, "--- QUAN SAT ---")
mkToggle(T2,"Wallhack ESP", C.Wallhack, function(v)
    C.Wallhack = v
    for _,p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local h = p.Character:FindFirstChild("LH_HL")
            if h then h.Enabled = v end
        end
    end
end)
mkLabel(T2, "--- CHIEN DAU ---")
mkToggle(T2,"Aimbot (Tu dong ngam)", C.Aimbot, function(v) C.Aimbot=v end)
mkLabel(T2, "--- HUD TREN MAN HINH ---")
mkToggle(T2,"Hien Nut Teleport & Aim", C.HUDOn, function(v)
    C.HUDOn = v
    if _G.LH_HUD then _G.LH_HUD(v) end
end)

-- ====== TAB 3: BAO VE ======
mkLabel(T3, "--- SONG CON ---")
mkToggle(T3,"Anti-AFK",        C.AntiAFK,  function(v) C.AntiAFK=v end)
mkToggle(T3,"Anti-Stun/Ragdoll",C.AntiStun,function(v) C.AntiStun=v end)
mkToggle(T3,"Anti-Void (Roi vuc)",C.AntiVoid,function(v) C.AntiVoid=v end)
mkLabel(T3, "--- CHONG HACKER ---")
mkToggle(T3,"Anti-Hacker Teleport",C.AntiHack,function(v) C.AntiHack=v end)
mkInput (T3,"Ban kinh (studs)", C.AntiHackR,3,30,function(v) C.AntiHackR=v end)
mkInput (T3,"Luc day ra",       C.AntiHackP,8,60,function(v) C.AntiHackP=v end)
mkLabel(T3, "--- GHOST MODE v2 ---")
mkToggle(T3,"Ghost Mode (ON/OFF)", C.GhostOn, function(v) C.GhostOn=v end)
mkToggle(T3,"Phantom Velocity",    C.PhantomOn,function(v) C.PhantomOn=v end)
mkInput (T3,"Phantom Force",C.PhantomForce,50,200,function(v) C.PhantomForce=v end)

-- ====== TAB 4: ULTRA BYPASS ======
local _kickBlock  = true
local _remFilter  = true
mkLabel(T4, "--- CHONG KICK/BAN ---")
mkToggle(T4,"Kick Block",       _kickBlock, function(v) _kickBlock=v end)
mkToggle(T4,"Remote Blacklist", _remFilter, function(v) _remFilter=v end)
mkLabel(T4, "--- CONG CU ---")
mkButton(T4,"Nguy Trang Ten Script", Color3.fromRGB(75,35,155), function()
    local names={"PlayerModule","CameraModule","ControlModule","ChatMain","BubbleChat"}
    pcall(function() if script and script.Parent then script.Name=names[math.random(#names)] end end)
end)
mkButton(T4,"Scan Yield AC Threads", Color3.fromRGB(155,35,35), function()
    pcall(function()
        if not getthreads then return end
        local kws={"speedcheck","positioncheck","anticheat","velocity_check","sanity"}
        for _,th in ipairs(getthreads()) do
            pcall(function()
                local s=tostring(th):lower()
                for _,kw in ipairs(kws) do
                    if s:find(kw,1,true) then task.defer(function() coroutine.yield(th) end) break end
                end
            end)
        end
    end)
end)
mkLabel(T4, "--- BYPASS ENGINE STATUS ---")
local bypassLbl = Instance.new("TextLabel")
bypassLbl.Size              = UDim2.new(1,-4,0,24)
bypassLbl.BackgroundColor3  = Color3.fromRGB(14,36,20)
bypassLbl.TextColor3        = Color3.fromRGB(0,235,115)
bypassLbl.TextSize          = 11
bypassLbl.Font              = Enum.Font.SourceSansBold
bypassLbl.TextWrapped       = true
bypassLbl.LayoutOrder       = nxt()
bypassLbl.ZIndex            = 15
bypassLbl.Text              = "Bypass: Dang khoi dong..."
bypassLbl.Parent            = T4
do local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,5) c.Parent=bypassLbl end

-- ====== TAB 5: FIX LAG ======
mkLabel(T5, "--- TOI UU HIEU NANG ---")
mkButton(T5,"Bat Fix Lag Live",        Color3.fromRGB(0,155,105), function() if _G.LH_lagOn  then _G.LH_lagOn()  end end)
mkButton(T5,"Tat Fix Lag",             Color3.fromRGB(175,38,38), function() if _G.LH_lagOff then _G.LH_lagOff() end end)
mkLabel(T5, "--- DO HOA MAY YEU ---")
mkButton(T5,"Ultra Low Graphics",      Color3.fromRGB(18,115,205), function() if _G.LH_ultraLow then _G.LH_ultraLow() end end)
mkButton(T5,"Xoa Bong & Suong Mu",    Color3.fromRGB(110,65,195), function()
    Lighting.GlobalShadows=false Lighting.FogEnd=9e9 Lighting.FogStart=9e9
end)

-- === OPEN DEFAULT TAB ===
switchTab("move")

-- ===================== SUBSYSTEMS =====================

-- [1] PHYSICS
task.spawn(function()
    local flyBV, flyBG
    RunService.Heartbeat:Connect(function()
        local hum,hrp = CH.hum, CH.hrp
        if not hum or not hrp or hum.Health<=0 then return end

        if C.JumpOn then hum.UseJumpPower=true; hum.JumpPower=C.Jump end

        if C.SpeedOn then
            local d = hum.MoveDirection
            if d.Magnitude>0.05 then
                hrp.AssemblyLinearVelocity = Vector3.new(d.X*C.Speed, hrp.AssemblyLinearVelocity.Y, d.Z*C.Speed)
            end
        end

        if C.NoclipOn and CH.char then
            for _,p in ipairs(CH.char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide=false end
            end
        end

        if C.AntiStun and CH.char then
            hum.PlatformStand=false
            for _,ch in ipairs(CH.char:GetChildren()) do
                local n=ch.Name
                if n=="Stun" or n=="Freeze" or n=="Ragdoll" or n=="Knockback" then
                    pcall(function() ch:Destroy() end)
                end
            end
        end

        if C.AntiVoid and hrp.Position.Y < -120 then
            hrp.CFrame = CFrame.new(hrp.Position.X, 80, hrp.Position.Z)
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
    end)

    RunService.RenderStepped:Connect(function()
        local hrp,hum = CH.hrp, CH.hum
        if not hrp then return end
        if C.FlyOn then
            if not flyBV or not flyBV.Parent then
                flyBV=Instance.new("BodyVelocity")
                flyBV.MaxForce=Vector3.new(1e5,1e5,1e5) flyBV.Velocity=Vector3.zero flyBV.Parent=hrp
            end
            if not flyBG or not flyBG.Parent then
                flyBG=Instance.new("BodyGyro")
                flyBG.MaxTorque=Vector3.new(1e5,1e5,1e5) flyBG.P=5e4 flyBG.CFrame=hrp.CFrame flyBG.Parent=hrp
            end
            local dir = hum and hum.MoveDirection or Vector3.zero
            flyBG.CFrame  = camera.CFrame
            flyBV.Velocity = dir * C.FlySpeed
        else
            if flyBV and flyBV.Parent then pcall(function() flyBV:Destroy() end); flyBV=nil end
            if flyBG and flyBG.Parent then pcall(function() flyBG:Destroy() end); flyBG=nil end
        end
    end)
end)

-- [2] ANTI-AFK
task.spawn(function()
    lp.Idled:Connect(function()
        if not C.AntiAFK then return end
        pcall(function()
            VirtualUser:Button2Down(Vector2.zero, camera.CFrame)
            task.wait(0.5)
            VirtualUser:Button2Up(Vector2.zero, camera.CFrame)
        end)
    end)
end)

-- [3] WALLHACK ESP
task.spawn(function()
    local function applyHL(char)
        pcall(function()
            local old = char:FindFirstChild("LH_HL")
            if old then old:Destroy() end
            local hl = Instance.new("Highlight")
            hl.Name             = "LH_HL"
            hl.FillColor        = Color3.fromRGB(255,50,50)
            hl.OutlineColor     = Color3.new(1,1,1)
            hl.FillTransparency = 0.5
            hl.DepthMode        = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Enabled          = C.Wallhack
            hl.Parent           = char
        end)
    end
    local function setupP(p)
        if p==lp then return end
        if p.Character then applyHL(p.Character) end
        p.CharacterAdded:Connect(function(c) task.wait(0.5) applyHL(c) end)
    end
    for _,p in ipairs(Players:GetPlayers()) do setupP(p) end
    Players.PlayerAdded:Connect(setupP)
end)

-- [4] AIMBOT
task.spawn(function()
    RunService.RenderStepped:Connect(function()
        if not C.Aimbot then return end
        local cp = camera.CFrame.Position
        local cd = camera.CFrame.LookVector
        local best, bd = nil, 0.90
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=lp and p.Character then
                local r = p.Character:FindFirstChild("HumanoidRootPart")
                local h = p.Character:FindFirstChildOfClass("Humanoid")
                if r and h and h.Health>0 then
                    local dot = cd:Dot((r.Position-cp).Unit)
                    if dot>bd then bd=dot; best=p end
                end
            end
        end
        if best and best.Character then
            local aim = best.Character:FindFirstChild("Head") or best.Character:FindFirstChild("HumanoidRootPart")
            if aim then camera.CFrame = CFrame.new(cp, aim.Position) end
        end
    end)
end)

-- [5] GHOST MODE + ANTI-HACKER
task.spawn(function()
    local prevP    = {}
    local dodgeCD  = 0
    local warnCD   = {}
    RunService.Heartbeat:Connect(function()
        local hrp = CH.hrp
        if not hrp then return end
        local myPos = hrp.Position
        local now   = tick()
        for _,p in ipairs(Players:GetPlayers()) do
            if p==lp or not p.Character then continue end
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            if not r then prevP[p]=nil; continue end
            local cur  = r.Position
            local prev = prevP[p]
            if prev then
                local jumped = (cur-prev).Magnitude
                local dist   = (cur-myPos).Magnitude
                if C.AntiHack and jumped>80 and dist<C.AntiHackR then
                    local t = now
                    if not warnCD[p] or t-warnCD[p]>2 then
                        warnCD[p]=t
                        local dir = (myPos-cur)
                        if dir.Magnitude>0 then dir=dir.Unit else dir=-camera.CFrame.LookVector end
                        hrp.CFrame = CFrame.new(myPos + dir*C.AntiHackP)
                        hrp.AssemblyLinearVelocity = dir*22
                    end
                end
                if C.GhostOn and jumped>60 and dist<14 and now-dodgeCD>0.4 then
                    dodgeCD = now
                    local angle = math.random()*math.pi*2
                    local esc   = Vector3.new(math.cos(angle),0,math.sin(angle))
                    if C.PhantomOn then
                        hrp.AssemblyLinearVelocity = Vector3.new(esc.X*C.PhantomForce, 38, esc.Z*C.PhantomForce)
                    else
                        hrp.CFrame = CFrame.new(myPos + esc*18)
                    end
                end
            end
            prevP[p] = cur
        end
    end)
end)

-- [6] BYPASS ENGINE
task.spawn(function()
    local hooked = false
    pcall(function()
        if typeof(hookmetamethod)~="function" or typeof(getnamecallmethod)~="function" then return end
        local old = hookmetamethod(game,"__namecall",function(self,...)
            local m = getnamecallmethod()
            if _kickBlock and (m=="Kick" or m=="Ban") then return nil end
            if _remFilter and (m=="FireServer" or m=="InvokeServer") then
                local ok,n = pcall(function() return self.Name:lower() end)
                if ok and n then
                    for _,kw in ipairs({"report","cheat","hack","detect","ban","kick","anticheat","sanity","exploit","flag"}) do
                        if n:find(kw,1,true) then return nil end
                    end
                end
            end
            return old(self,...)
        end)
        hooked = true
    end)
    pcall(function()
        bypassLbl.Text = "KickBlock: ON | Filter: ON | Hook: "..(hooked and "OK" or "Safe Mode")
    end)
end)

-- [7] FIX LAG ENGINE
local lagConn = nil
local FXTypes = {ParticleEmitter=true,Trail=true,Beam=true,Sparkles=true,Fire=true,Smoke=true}
local function stripFX(o) pcall(function() if FXTypes[o.ClassName] then o.Enabled=false end end) end

_G.LH_lagOn = function()
    if lagConn then return end
    for _,o in ipairs(Workspace:GetDescendants()) do stripFX(o) end
    Lighting.GlobalShadows=false; Lighting.FogEnd=9e9; Lighting.FogStart=9e9
    for _,fx in ipairs(Lighting:GetChildren()) do
        if fx:IsA("PostEffect") then fx.Enabled=false end
    end
    lagConn = Workspace.DescendantAdded:Connect(function(o) task.defer(stripFX,o) end)
    C.FixLag=true
end
_G.LH_lagOff = function()
    if lagConn then lagConn:Disconnect(); lagConn=nil end
    C.FixLag=false
end
_G.LH_ultraLow = function()
    _G.LH_lagOn()
    for _,o in ipairs(Workspace:GetDescendants()) do
        pcall(function()
            if o:IsA("BasePart") then o.Material=Enum.Material.SmoothPlastic; o.CastShadow=false
            elseif o:IsA("Decal") or o:IsA("Texture") then o.Transparency=1
            elseif o:IsA("MeshPart") then o.RenderFidelity=Enum.RenderFidelity.Performance end
        end)
    end
    local t=Workspace:FindFirstChildOfClass("Terrain")
    if t then t.WaterWaveSize=0; t.WaterWaveSpeed=0 end
end

-- [8] ON-SCREEN HUD (Teleport + Aimbot buttons)
local hudGUI = nil
_G.LH_HUD = function(on)
    if hudGUI then pcall(function() hudGUI:Destroy() end); hudGUI=nil end
    if not on then return end

    hudGUI = Instance.new("ScreenGui")
    hudGUI.Name            = "LuckatHub_HUD"
    hudGUI.ResetOnSpawn    = false
    hudGUI.ZIndexBehavior  = Enum.ZIndexBehavior.Global
    hudGUI.Parent          = ROOT

    local tpBtn = Instance.new("TextButton")
    tpBtn.Size             = UDim2.new(0,66,0,66)
    tpBtn.Position         = UDim2.new(0,18,0,60)
    tpBtn.BackgroundColor3 = Color3.fromRGB(210,45,45)
    tpBtn.Text             = "TP"
    tpBtn.TextColor3       = Color3.new(1,1,1)
    tpBtn.TextSize         = 13
    tpBtn.Font             = Enum.Font.SourceSansBold
    tpBtn.BorderSizePixel  = 0
    tpBtn.AutoButtonColor  = false
    tpBtn.ZIndex           = 60
    tpBtn.Parent           = hudGUI
    do local c=Instance.new("UICorner") c.CornerRadius=UDim.new(1,0) c.Parent=tpBtn end

    local aimBtn = Instance.new("TextButton")
    aimBtn.Size             = UDim2.new(0,76,0,30)
    aimBtn.Position         = UDim2.new(1,-94,0,60)
    aimBtn.BackgroundColor3 = Color3.fromRGB(45,45,210)
    aimBtn.Text             = "AIM OFF"
    aimBtn.TextColor3       = Color3.new(1,1,1)
    aimBtn.TextSize         = 11
    aimBtn.Font             = Enum.Font.SourceSansBold
    aimBtn.BorderSizePixel  = 0
    aimBtn.AutoButtonColor  = false
    aimBtn.ZIndex           = 60
    aimBtn.Parent           = hudGUI
    do local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,6) c.Parent=aimBtn end

    local locked=false; local lockT=nil; local followC=nil

    local function getTarget()
        local cp=camera.CFrame.Position; local cd=camera.CFrame.LookVector
        local best,bd=nil,0.88
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=lp and p.Character then
                local r=p.Character:FindFirstChild("HumanoidRootPart")
                local h=p.Character:FindFirstChildOfClass("Humanoid")
                if r and h and h.Health>0 then
                    local d=cd:Dot((r.Position-cp).Unit)
                    if d>bd then bd=d; best=p end
                end
            end
        end
        return best
    end

    local function tpTo(target)
        if not target or not target.Character then return end
        local tr=target.Character:FindFirstChild("HumanoidRootPart"); local pr=CH.hrp
        if not tr or not pr then return end
        pr.CFrame = CFrame.new(tr.Position + tr.CFrame.RightVector*2.2, tr.Position)
    end

    tpBtn.MouseButton1Click:Connect(function()
        if locked then
            locked=false; lockT=nil
            if followC then followC:Disconnect(); followC=nil end
            tpBtn.BackgroundColor3=Color3.fromRGB(210,45,45); tpBtn.Text="TP"
        else
            local t=getTarget()
            if not t then tpBtn.Text="NO TGT"; task.delay(1,function() if tpBtn.Parent then tpBtn.Text="TP" end end); return end
            locked=true; lockT=t
            tpBtn.BackgroundColor3=Color3.fromRGB(0,195,80); tpBtn.Text="LOCK"
            tpTo(t)
            if followC then followC:Disconnect() end
            followC=RunService.Heartbeat:Connect(function()
                if not locked or not lockT or not lockT.Character then
                    if followC then followC:Disconnect(); followC=nil end
                    locked=false; lockT=nil
                    if tpBtn.Parent then tpBtn.BackgroundColor3=Color3.fromRGB(210,45,45); tpBtn.Text="TP" end
                    return
                end
                tpTo(lockT)
            end)
        end
    end)

    aimBtn.MouseButton1Click:Connect(function()
        C.Aimbot = not C.Aimbot
        aimBtn.BackgroundColor3 = C.Aimbot and Color3.fromRGB(0,195,80) or Color3.fromRGB(45,45,210)
        aimBtn.Text             = C.Aimbot and "AIM ON" or "AIM OFF"
    end)
end

-- === DONE ===
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title="LuckatHub v9.0"; Text="Ready! Chuc ban choi vui!"; Duration=3;
    })
end)
print("[LuckatHub v9.0] Loaded OK - Mobile Only Build")
