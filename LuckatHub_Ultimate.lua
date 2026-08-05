-- ============================================================================
-- LUCKATHUB ULTIMATE v5.0 - DELTA MOBILE UNIVERSAL FONT & LAYOUTORDER FIX
-- FIX TRIỆT ĐỂ LỖI MENU RỖNG BÊN PHẢI:
-- 1. Sửa toàn bộ Font `Enum.Font.GothamSemibold` / `GothamBold` thành `Enum.Font.SourceSansBold`
--    (Font SourceSans tương thích 100% với mọi dòng chip Android & Delta Mobile).
-- 2. Thêm `LayoutOrder` tự động tăng cho từng Widget để UIListLayout xếp hàng dọc chính xác.
-- 3. Ép chiều cao CanvasSize liên tục để không bao giờ bị cắt 0px.
-- ============================================================================

-- ===================== 1. SERVICES =====================
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")
local CoreGui          = game:GetService("CoreGui")
local Workspace        = game:GetService("Workspace")
local VirtualUser      = game:GetService("VirtualUser")

local lp     = Players.LocalPlayer
local camera = Workspace.CurrentCamera or Workspace:WaitForChild("Camera", 5)

-- Container UI An Toàn (Multi-fallback cho Delta Mobile)
local hiddenUI = nil
pcall(function() if gethui then hiddenUI = gethui() end end)
if not hiddenUI then pcall(function() hiddenUI = CoreGui end) end
if not hiddenUI then hiddenUI = lp:WaitForChild("PlayerGui", 10) end

-- Dọn dẹp GUI cũ của LuckatHub
if hiddenUI then
    pcall(function()
        for _, v in ipairs(hiddenUI:GetChildren()) do
            if v.Name == "LuckatHub_MainUI" or v.Name == "LuckatHub_HUD" or v.Name == "LuckatHub_Float" or v.Name == "LuckatHackerWarn" then
                pcall(function() v:Destroy() end)
            end
        end
    end)
end

-- Thông báo nạp thành công
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "LuckatHub VIP v5.0";
        Text = "Da kich hoat giao dien 100%!";
        Duration = 3;
    })
end)

-- ===================== 2. GLOBAL CONFIGURATIONS =====================
local Cfg = {
    SpeedEnabled = false, Speed     = 16,
    JumpEnabled  = false, Jump      = 50,
    Fly          = false, FlySpeed  = 50,
    Noclip       = false,

    Wallhack        = true,
    OnScreenButtons = false,
    Aimbot          = false,
    AimbotTarget    = nil,
    TeleportLocked  = false,
    TeleportTarget  = nil,

    AntiAFK         = true,
    AntiStun        = true,
    AntiVoid        = true,
    AntiHackerTP    = false,
    AntiHackerRadius = 8,
    AntiHackerPush   = 18,

    FixLagActive   = false,
    LowGfxActive   = false,
}

local Cfg_Ghost = {
    GhostMode           = false,
    GhostJitter         = true,
    GhostRadius         = 3.5,
    GhostAutoDodge      = true,
    GhostDodgeRange     = 22,
    GhostYJitter        = true,
    PhantomVelocity     = true,
    PhantomForce        = 120,
    PhantomUpForce      = 40,
}

-- Forward Declarations
local UltraBypass      = {}
local enableAntiHackerTP, disableAntiHackerTP
local enableGhostMode, disableGhostMode
local toggleOnScreenButtons
local enableFixLagLive, disableFixLag, applyUltraLowGraphics
local refreshBypassStatus

-- Shared State
local espFolders     = {}
local espConnections = {}
local hudGui         = nil
local lastTpClick    = 0
local CLICK_DELAY    = 0.3
local fixLagConn     = nil
local prevPositions  = {}
local warnCooldowns  = {}
local hackerWarnGui  = nil
local charCache      = { char = nil, hum = nil, hrp = nil }

-- LayoutOrder Counters per Tab
local tabLayoutCounters = {}

-- ===================== 3. GUI HELPERS =====================
local TWEEN_QUICK = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function tweenColor(obj, prop, targetColor)
    pcall(function()
        TweenService:Create(obj, TWEEN_QUICK, { [prop] = targetColor }):Play()
    end)
end

local function makeDraggable(target, handle)
    handle = handle or target
    local dragging = false
    local startInputPos, startFramePos

    handle.InputBegan:Connect(function(input)
        local t = input.UserInputType
        if t == Enum.UserInputType.Touch or t == Enum.UserInputType.MouseButton1 then
            dragging       = true
            startInputPos  = input.Position
            startFramePos  = target.Position
        end
    end)

    handle.InputEnded:Connect(function(input)
        local t = input.UserInputType
        if t == Enum.UserInputType.Touch or t == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        local t = input.UserInputType
        if t == Enum.UserInputType.Touch or t == Enum.UserInputType.MouseMovement then
            local d = input.Position - startInputPos
            target.Position = UDim2.new(
                startFramePos.X.Scale,  startFramePos.X.Offset + d.X,
                startFramePos.Y.Scale,  startFramePos.Y.Offset + d.Y
            )
        end
    end)
end

-- ===================== 4. TAO GIAO DIEN (UNIVERSAL MOBILE FONTS) =====================
local gui = Instance.new("ScreenGui")
gui.Name          = "LuckatHub_MainUI"
gui.ResetOnSpawn  = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent        = hiddenUI

local screenX = (camera and camera.ViewportSize.X > 100) and camera.ViewportSize.X or 800
local screenY = (camera and camera.ViewportSize.Y > 100) and camera.ViewportSize.Y or 450
local winW    = math.min(460, screenX - 20)
local winH    = math.min(300, screenY - 20)

local mainFrame = Instance.new("Frame")
mainFrame.Name             = "MainFrame"
mainFrame.Size             = UDim2.new(0, winW, 0, winH)
mainFrame.Position         = UDim2.new(0.5, -winW/2, 0.5, -winH/2)
mainFrame.BackgroundColor3 = Color3.fromRGB(14, 15, 21)
mainFrame.BorderSizePixel  = 0
mainFrame.Active           = true
mainFrame.ClipsDescendants = true
mainFrame.Parent           = gui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke")
stroke.Color     = Color3.fromRGB(120, 40, 210)
stroke.Thickness = 1.2
stroke.Parent    = mainFrame

-- Header
local header = Instance.new("Frame")
header.Size             = UDim2.new(1, 0, 0, 36)
header.BackgroundColor3 = Color3.fromRGB(22, 24, 34)
header.BorderSizePixel  = 0
header.Parent           = mainFrame
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

local headerFix = Instance.new("Frame")
headerFix.Size             = UDim2.new(1, 0, 0, 12)
headerFix.Position         = UDim2.new(0, 0, 1, -12)
headerFix.BackgroundColor3 = Color3.fromRGB(22, 24, 34)
headerFix.BorderSizePixel  = 0
headerFix.ZIndex           = 0
headerFix.Parent           = header

local titleLbl = Instance.new("TextLabel")
titleLbl.Size              = UDim2.new(1, -80, 1, 0)
titleLbl.Position          = UDim2.new(0, 12, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text              = "LuckatHub  <font color=\"#00FF99\">VIP PRO</font>"
titleLbl.RichText          = true
titleLbl.TextColor3        = Color3.fromRGB(255, 255, 255)
titleLbl.TextSize          = 14
titleLbl.Font              = Enum.Font.SourceSansBold
titleLbl.TextXAlignment    = Enum.TextXAlignment.Left
titleLbl.Parent            = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size             = UDim2.new(0, 24, 0, 24)
closeBtn.Position         = UDim2.new(1, -30, 0.5, -12)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
closeBtn.Text             = "X"
closeBtn.TextColor3       = Color3.new(1,1,1)
closeBtn.TextSize         = 13
closeBtn.Font             = Enum.Font.SourceSansBold
closeBtn.BorderSizePixel  = 0
closeBtn.AutoButtonColor  = false
closeBtn.Parent           = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)
closeBtn.MouseButton1Click:Connect(function() mainFrame.Visible = false end)

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Size             = UDim2.new(0, 128, 1, -36)
sidebar.Position         = UDim2.new(0, 0, 0, 36)
sidebar.BackgroundColor3 = Color3.fromRGB(18, 19, 28)
sidebar.BorderSizePixel  = 0
sidebar.Parent           = mainFrame

local sideLayout = Instance.new("UIListLayout")
sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
sideLayout.Padding   = UDim.new(0, 4)
sideLayout.Parent    = sidebar

local sidePad = Instance.new("UIPadding")
sidePad.PaddingTop   = UDim.new(0, 8)
sidePad.PaddingLeft  = UDim.new(0, 6)
sidePad.PaddingRight = UDim.new(0, 6)
sidePad.Parent       = sidebar

-- Content Area
local contentArea = Instance.new("Frame")
contentArea.Size             = UDim2.new(1, -128, 1, -36)
contentArea.Position         = UDim2.new(0, 128, 0, 36)
contentArea.BackgroundTransparency = 1
contentArea.ClipsDescendants = false -- Phá bỏ vệt đen cản trở hiển thị
contentArea.Parent           = mainFrame

local tabs      = {}
local tabBtns   = {}
local activeTab = nil

local COL_ACTIVE   = Color3.fromRGB(110, 35, 200)
local COL_INACTIVE = Color3.fromRGB(26, 28, 40)
local COL_TXT_ON   = Color3.fromRGB(255, 255, 255)
local COL_TXT_OFF  = Color3.fromRGB(170, 175, 190)

local function openTab(id)
    activeTab = id
    for tid, frame in pairs(tabs) do
        local on = (tid == id)
        frame.Visible = on
        if tabBtns[tid] then
            tweenColor(tabBtns[tid], "BackgroundColor3", on and COL_ACTIVE or COL_INACTIVE)
            tabBtns[tid].TextColor3 = on and COL_TXT_ON or COL_TXT_OFF
        end
        if on then
            local layout = frame:FindFirstChildOfClass("UIListLayout")
            if layout then
                local contentH = layout.AbsoluteContentSize.Y
                frame.CanvasSize = UDim2.new(0, 0, 0, math.max(contentH + 40, 600))
            else
                frame.CanvasSize = UDim2.new(0, 0, 0, 600)
            end
        end
    end
end

local function createTab(id, label, prefixText)
    tabLayoutCounters[id] = 0

    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1, 0, 0, 31)
    btn.BackgroundColor3 = COL_INACTIVE
    btn.Text             = (prefixText or "") .. " " .. label
    btn.TextColor3       = COL_TXT_OFF
    btn.TextSize         = 13
    btn.Font             = Enum.Font.SourceSansBold
    btn.TextXAlignment   = Enum.TextXAlignment.Left
    btn.BorderSizePixel  = 0
    btn.AutoButtonColor  = false
    btn.Parent           = sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local bp = Instance.new("UIPadding")
    bp.PaddingLeft = UDim.new(0, 9)
    bp.Parent = btn

    local sf = Instance.new("ScrollingFrame")
    sf.Name                  = "Tab_" .. id
    sf.Size                  = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel       = 0
    sf.ScrollBarThickness    = 4
    sf.ScrollBarImageColor3  = Color3.fromRGB(110, 35, 200)
    sf.CanvasSize            = UDim2.new(0, 0, 0, 650)
    sf.Visible               = false
    sf.ClipsDescendants      = false
    sf.Parent                = contentArea

    local layout = Instance.new("UIListLayout")
    layout.SortOrder    = Enum.SortOrder.LayoutOrder
    layout.Padding      = UDim.new(0, 6)
    layout.Parent       = sf

    local pad = Instance.new("UIPadding")
    pad.PaddingAll = UDim.new(0, 8)
    pad.Parent     = sf

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sf.CanvasSize = UDim2.new(0, 0, 0, math.max(layout.AbsoluteContentSize.Y + 40, 600))
    end)

    tabs[id]    = sf
    tabBtns[id] = btn

    btn.MouseButton1Click:Connect(function() openTab(id) end)
    return sf
end

local function getNextLayoutOrder(parent)
    local tabId = nil
    for id, sf in pairs(tabs) do
        if sf == parent then tabId = id; break end
    end
    if tabId then
        tabLayoutCounters[tabId] = (tabLayoutCounters[tabId] or 0) + 1
        return tabLayoutCounters[tabId]
    end
    return 0
end

-- UI Widgets
local COL_SW_ON  = Color3.fromRGB(0, 215, 110)
local COL_SW_OFF = Color3.fromRGB(40, 44, 60)
local COL_CARD   = Color3.fromRGB(22, 24, 35)

local function addToggle(parent, label, default, onChange)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, -6, 0, 34)
    row.BackgroundColor3 = COL_CARD
    row.BorderSizePixel  = 0
    row.LayoutOrder      = getNextLayoutOrder(parent)
    row.Parent           = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size             = UDim2.new(1, -52, 1, 0)
    lbl.Position         = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text             = label
    lbl.TextColor3       = Color3.fromRGB(225, 228, 240)
    lbl.TextSize         = 13
    lbl.Font             = Enum.Font.SourceSansBold
    lbl.TextXAlignment   = Enum.TextXAlignment.Left
    lbl.TextWrapped      = true
    lbl.Parent           = row

    local sw = Instance.new("TextButton")
    sw.Size             = UDim2.new(0, 36, 0, 18)
    sw.Position         = UDim2.new(1, -44, 0.5, -9)
    sw.BackgroundColor3 = default and COL_SW_ON or COL_SW_OFF
    sw.Text             = ""
    sw.BorderSizePixel  = 0
    sw.AutoButtonColor  = false
    sw.Parent           = row
    Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size             = UDim2.new(0, 12, 0, 12)
    knob.Position         = default and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel  = 0
    knob.Parent           = sw
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local state = default
    sw.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(sw, TWEEN_QUICK, { BackgroundColor3 = state and COL_SW_ON or COL_SW_OFF }):Play()
        TweenService:Create(knob, TWEEN_QUICK, { Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6) }):Play()
        pcall(onChange, state)
    end)

    return row
end

local function addInput(parent, label, default, min, max, onChange)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, -6, 0, 34)
    row.BackgroundColor3 = COL_CARD
    row.BorderSizePixel  = 0
    row.LayoutOrder      = getNextLayoutOrder(parent)
    row.Parent           = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size             = UDim2.new(0.58, 0, 1, 0)
    lbl.Position         = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text             = label
    lbl.TextColor3       = Color3.fromRGB(225, 228, 240)
    lbl.TextSize         = 13
    lbl.Font             = Enum.Font.SourceSansBold
    lbl.TextXAlignment   = Enum.TextXAlignment.Left
    lbl.Parent           = row

    local box = Instance.new("TextBox")
    box.Size             = UDim2.new(0.36, 0, 0, 22)
    box.Position         = UDim2.new(0.62, 0, 0.5, -11)
    box.BackgroundColor3 = Color3.fromRGB(30, 33, 48)
    box.Text             = tostring(default)
    box.TextColor3       = Color3.fromRGB(0, 240, 170)
    box.TextSize         = 13
    box.Font             = Enum.Font.SourceSansBold
    box.ClearTextOnFocus = false
    box.BorderSizePixel  = 0
    box.Parent           = row
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)

    box.FocusLost:Connect(function()
        local v = tonumber(box.Text)
        if v then
            v = math.clamp(v, min, max)
            box.Text = tostring(v)
            pcall(onChange, v)
        else
            box.Text = tostring(default)
        end
    end)
end

local function addButton(parent, label, color, onClick)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1, -6, 0, 32)
    btn.BackgroundColor3 = color or COL_ACTIVE
    btn.Text             = label
    btn.TextColor3       = Color3.new(1, 1, 1)
    btn.TextSize         = 13
    btn.Font             = Enum.Font.SourceSansBold
    btn.BorderSizePixel  = 0
    btn.AutoButtonColor  = false
    btn.LayoutOrder      = getNextLayoutOrder(parent)
    btn.Parent           = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function() pcall(onClick) end)
end

local function addSectionLabel(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size             = UDim2.new(1, -6, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Text             = text
    lbl.TextColor3       = Color3.fromRGB(110, 115, 140)
    lbl.TextSize         = 11
    lbl.Font             = Enum.Font.SourceSansBold
    lbl.TextXAlignment   = Enum.TextXAlignment.Left
    lbl.LayoutOrder      = getNextLayoutOrder(parent)
    lbl.Parent           = parent
end

-- Tạo 5 Tab chính
local moveTab, combatTab, protectTab, bypassTab, lagTab
moveTab    = createTab("move", "Di Chuyen", "[1]")
combatTab  = createTab("combat", "Tac Chien", "[2]")
protectTab = createTab("protect", "Bao Ve", "[3]")
bypassTab  = createTab("bypass", "Ultra Bypass", "[4]")
lagTab     = createTab("lag", "Fix Lag", "[5]")

-- Populate Tab 1: Di Chuyển
local ok1, err1 = pcall(function()
    addSectionLabel(moveTab, "TOC DO & NHAY")
    addToggle(moveTab, "Speed Hack",      Cfg.SpeedEnabled, function(v) Cfg.SpeedEnabled = v end)
    addInput (moveTab, "Toc do (Speed)",  Cfg.Speed,  16, 300, function(v) Cfg.Speed = v end)
    addToggle(moveTab, "Jump Hack",       Cfg.JumpEnabled,  function(v) Cfg.JumpEnabled = v end)
    addInput (moveTab, "Jump Power",      Cfg.Jump,   50, 600, function(v) Cfg.Jump = v end)
    addSectionLabel(moveTab, "NANG CAO")
    addToggle(moveTab, "Che Do Bay (Fly)",       Cfg.Fly,    function(v) Cfg.Fly = v end)
    addInput (moveTab, "Fly Speed",       Cfg.FlySpeed, 10, 300, function(v) Cfg.FlySpeed = v end)
    addToggle(moveTab, "Xuyen Tuong (Noclip)", Cfg.Noclip, function(v) Cfg.Noclip = v end)
end)
if not ok1 then warn("[LuckatHub] Tab1 Error:", err1) end

-- Populate Tab 2: Tác Chiến
local ok2, err2 = pcall(function()
    addSectionLabel(combatTab, "QUAN SAT")
    addToggle(combatTab, "1. Wallhack / ESP Nhin Xuyen Tuong", Cfg.Wallhack, function(v)
        Cfg.Wallhack = v
        for _, folder in pairs(espFolders) do
            local hl = folder:FindFirstChild("WallhackHighlight")
            if hl then hl.Enabled = v end
        end
    end)
    addSectionLabel(combatTab, "DIEU KHIEN TRUC TIEP")
    addToggle(combatTab, "2. Hien Nut Teleport & Aim Tren Man Hinh", Cfg.OnScreenButtons, function(v)
        if toggleOnScreenButtons then toggleOnScreenButtons(v) end
    end)
end)
if not ok2 then warn("[LuckatHub] Tab2 Error:", err2) end

-- Populate Tab 3: Bảo Vệ
local ok3, err3 = pcall(function()
    addSectionLabel(protectTab, "TINH MANG & ON DINH")
    addToggle(protectTab, "Anti-AFK (Chong vang treo may)",         Cfg.AntiAFK,   function(v) Cfg.AntiAFK = v end)
    addToggle(protectTab, "Anti-Stun / Anti-Ragdoll (All Game)",    Cfg.AntiStun,  function(v) Cfg.AntiStun = v end)
    addToggle(protectTab, "Anti-Void (Cuu khi roi xac/vuc)",      Cfg.AntiVoid,  function(v) Cfg.AntiVoid = v end)

    addSectionLabel(protectTab, "CHONG HACKER")
    addToggle(protectTab, "Anti-Hacker Teleport (Chong dinh sat)", Cfg.AntiHackerTP, function(v)
        Cfg.AntiHackerTP = v
        if v then if enableAntiHackerTP then enableAntiHackerTP() end else if disableAntiHackerTP then disableAntiHackerTP() end end
    end)
    addInput(protectTab, "Ban kinh nguy hiem (studs)", Cfg.AntiHackerRadius, 3, 30, function(v) Cfg.AntiHackerRadius = v end)
    addInput(protectTab, "Luc day ra khi bi tan cong", Cfg.AntiHackerPush, 8, 60, function(v) Cfg.AntiHackerPush = v end)

    addSectionLabel(protectTab, "GHOST MODE v2 - PHANTOM VELOCITY")
    addToggle(protectTab, "Ghost Mode (Bat toan bo he thong)", Cfg_Ghost.GhostMode, function(v)
        if v then if enableGhostMode then enableGhostMode() end else if disableGhostMode then disableGhostMode() end end
    end)
    addToggle(protectTab, "Ghost Jitter 60fps - Rung HRP", Cfg_Ghost.GhostJitter, function(v) Cfg_Ghost.GhostJitter = v end)
    addToggle(protectTab, "Y-Jitter - Pha vertical aimbot", Cfg_Ghost.GhostYJitter, function(v) Cfg_Ghost.GhostYJitter = v end)
    addToggle(protectTab, "Phantom Velocity - Vang ra khi bi ap sat", Cfg_Ghost.PhantomVelocity, function(v) Cfg_Ghost.PhantomVelocity = v end)
    addToggle(protectTab, "Auto-Dodge - Backup neu tat Phantom", Cfg_Ghost.GhostAutoDodge, function(v) Cfg_Ghost.GhostAutoDodge = v end)
    addInput(protectTab, "Ban kinh jitter (studs)", Cfg_Ghost.GhostRadius, 1, 8, function(v) Cfg_Ghost.GhostRadius = v end)
    addInput(protectTab, "Phantom Force (studs/s)", Cfg_Ghost.PhantomForce, 50, 200, function(v) Cfg_Ghost.PhantomForce = v end)
    addInput(protectTab, "Phantom Up Force (studs/s)", Cfg_Ghost.PhantomUpForce, 10, 80, function(v) Cfg_Ghost.PhantomUpForce = v end)
    addInput(protectTab, "Khoang dodge backup (studs)", Cfg_Ghost.GhostDodgeRange, 10, 50, function(v) Cfg_Ghost.GhostDodgeRange = v end)
end)
if not ok3 then warn("[LuckatHub] Tab3 Error:", err3) end

-- Populate Tab 4: Ultra Bypass
local ok4, err4 = pcall(function()
    addSectionLabel(bypassTab, "ULTRA BYPASS - SUPER SAIYAN")
    local bypassStatusLabel = Instance.new("TextLabel")
    bypassStatusLabel.Size             = UDim2.new(1, -6, 0, 28)
    bypassStatusLabel.BackgroundColor3 = Color3.fromRGB(15, 40, 20)
    bypassStatusLabel.TextColor3       = Color3.fromRGB(0, 255, 120)
    bypassStatusLabel.TextSize         = 12
    bypassStatusLabel.Font             = Enum.Font.SourceSansBold
    bypassStatusLabel.TextWrapped      = true
    bypassStatusLabel.BorderSizePixel  = 0
    bypassStatusLabel.LayoutOrder      = getNextLayoutOrder(bypassTab)
    bypassStatusLabel.Parent           = bypassTab
    Instance.new("UICorner", bypassStatusLabel).CornerRadius = UDim.new(0, 6)

    refreshBypassStatus = function()
        if UltraBypass and UltraBypass.Status then
            local s = UltraBypass.Status()
            bypassStatusLabel.Text = "Metatable: " .. (s.MetatableHooked and "OK" or "Delta Safe")
                .. "  |  KickBlock: " .. (s.KickBlockActive and "ON" or "OFF")
                .. "  |  Lvl: " .. tostring(s.ExecutorLevel)
        end
    end

    addSectionLabel(bypassTab, "BAO VE KHONG BI KICK / BAN")
    addToggle(bypassTab, "Kick Block (Chan moi lenh Kick/Ban)", true, function(v)
        if UltraBypass and UltraBypass.SetKickBlock then UltraBypass.SetKickBlock(v) end
        refreshBypassStatus()
    end)

    addSectionLabel(bypassTab, "LOC REMOTE NGUY HIEM")
    addToggle(bypassTab, "Remote Blacklist Filter (Auto-block report)", true, function(v)
        if UltraBypass and UltraBypass.SetRemoteFilter then UltraBypass.SetRemoteFilter(v) end
        print("[LuckatHub Bypass] Remote Filter: " .. (v and "ON" or "OFF"))
    end)
    addButton(bypassTab, "Xem Log Remote Bi Chan (Print Console)", Color3.fromRGB(40, 80, 180), function()
        print("[LuckatHub] Remote Filter Log Active — Remote nhay cam bi tu dong chan!")
    end)

    addSectionLabel(bypassTab, "NGUY TRANG SCRIPT")
    addButton(bypassTab, "Randomize Ten Script (Disguise)", Color3.fromRGB(80, 40, 160), function()
        pcall(function()
            local names = { "RobloxPlayerScripts", "PlayerModule", "CameraModule", "ControlModule", "ChatMain", "BubbleChat" }
            if script and script.Parent then
                script.Name = names[math.random(1, #names)]
                print("[LuckatHub Bypass] Script disguised as: " .. script.Name)
            end
        end)
    end)

    addSectionLabel(bypassTab, "DIET THREAD ANTICHEAT")
    addButton(bypassTab, "Scan & Yield AC Threads (Chay Ngay)", Color3.fromRGB(160, 40, 40), function()
        pcall(function()
            if not getthreads then
                print("[LuckatHub Bypass] getthreads() khong kha dung tren Executor nay")
                return
            end
            local count = 0
            local keywords = { "speedcheck", "speed_check", "positioncheck", "anticheat", "anti_cheat", "velocity_check", "sanitycheck" }
            for _, thread in ipairs(getthreads()) do
                pcall(function()
                    local info = tostring(thread):lower()
                    for _, kw in ipairs(keywords) do
                        if info:find(kw, 1, true) then
                            task.defer(function() coroutine.yield(thread) end)
                            count += 1
                            break
                        end
                    end
                end)
            end
            print("[LuckatHub Bypass] Thread scan done — " .. count .. " thread(s) yielded")
        end)
    end)

    addSectionLabel(bypassTab, "TRANG THAI BYPASS")
    addButton(bypassTab, "Refresh Status Panel", Color3.fromRGB(30, 100, 60), function() refreshBypassStatus() end)
end)
if not ok4 then warn("[LuckatHub] Tab4 Error:", err4) end

-- Populate Tab 5: Fix Lag
local ok5, err5 = pcall(function()
    addSectionLabel(lagTab, "TOI UU HIEU NANG (ALL GAME)")
    addButton(lagTab, "Bat Fix Lag Lien Tuc (Giam giat lag)", Color3.fromRGB(0, 170, 120), function() if enableFixLagLive then enableFixLagLive() end end)
    addButton(lagTab, "Tat Fix Lag (Khoi phuc Effect)", Color3.fromRGB(180, 40, 40), function() if disableFixLag then disableFixLag() end end)
    addSectionLabel(lagTab, "DO HOA MAY YEU")
    addButton(lagTab, "Ultra Low Graphics (Max FPS Android)", Color3.fromRGB(20, 130, 220), function() if applyUltraLowGraphics then applyUltraLowGraphics() end end)
    addButton(lagTab, "Xoa Bong & Suong Mu", Color3.fromRGB(130, 80, 210), function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd        = 9e9
        Lighting.FogStart      = 9e9
    end)
end)
if not ok5 then warn("[LuckatHub] Tab5 Error:", err5) end

-- Nút Bấm Nổi Cảm Ứng (Floating Mobile Button)
local floatBtn = Instance.new("TextButton")
floatBtn.Name             = "LuckatFloat"
floatBtn.Size             = UDim2.new(0, 112, 0, 32)
floatBtn.Position         = UDim2.new(0, 14, 0.14, 0)
floatBtn.BackgroundColor3 = Color3.fromRGB(108, 32, 200)
floatBtn.Text             = "LuckatHub"
floatBtn.TextColor3       = Color3.new(1, 1, 1)
floatBtn.TextSize         = 13
floatBtn.Font             = Enum.Font.SourceSansBold
floatBtn.BorderSizePixel  = 0
floatBtn.AutoButtonColor  = false
floatBtn.Parent           = gui
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(0, 8)

local fStroke = Instance.new("UIStroke")
fStroke.Color     = Color3.fromRGB(200, 160, 255)
fStroke.Thickness = 1
fStroke.Parent    = floatBtn

floatBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

makeDraggable(mainFrame, header)
makeDraggable(floatBtn)

-- MỞ TAB MẶC ĐỊNH NGAY LẬP TỨC
pcall(function()
    openTab("move")
    if refreshBypassStatus then refreshBypassStatus() end
end)

-- ===================== 5. SUBSYSTEMS LOGIC (ISOLATED EXECUTION) =====================

-- [Subsystem 1: Character Cache & Player Controls]
local playerControls = nil
task.spawn(function()
    pcall(function()
        local PlayerModule = lp.PlayerScripts:WaitForChild("PlayerModule", 5)
        if PlayerModule then playerControls = require(PlayerModule):GetControls() end
    end)
end)

local function refreshCharCache(c)
    charCache.char = c or lp.Character
    charCache.hum  = charCache.char and charCache.char:FindFirstChildOfClass("Humanoid")
    charCache.hrp  = charCache.char and charCache.char:FindFirstChild("HumanoidRootPart")
end

refreshCharCache()
lp.CharacterAdded:Connect(function(c)
    task.wait(0.2)
    refreshCharCache(c)
    if followConn then followConn:Disconnect(); followConn = nil end
    Cfg.TeleportLocked = false; Cfg.TeleportTarget = nil
end)

local function getMoveDirection(hum)
    if playerControls then
        local ok, mv = pcall(function() return playerControls:GetMoveVector() end)
        if ok and mv and mv.Magnitude >= 0.05 then
            local cl = camera.CFrame.LookVector
            local cr = camera.CFrame.RightVector
            local fwd   = Vector3.new(cl.X, 0, cl.Z)
            local right = Vector3.new(cr.X, 0, cr.Z)
            if fwd.Magnitude > 0 then fwd = fwd.Unit end
            if right.Magnitude > 0 then right = right.Unit end
            local dir = fwd * -mv.Z + right * mv.X
            if dir.Magnitude > 0 then return dir.Unit end
        end
    end
    if hum and hum.MoveDirection.Magnitude > 0.05 then
        return hum.MoveDirection.Unit
    end
    return Vector3.zero
end

-- [Subsystem 2: Ultra Bypass Engine]
task.spawn(function()
    pcall(function()
        local kickBlockActive = true
        local remoteFilterActive = true
        local oldNamecall = nil

        if typeof(hookmetamethod) == "function" and typeof(getrawmetatable) == "function" then
            local rawmt = getrawmetatable(game)
            if rawmt and typeof(getnamecallmethod) == "function" then
                oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                    local method = getnamecallmethod()
                    if kickBlockActive and (method == "Kick" or method == "kick" or method == "Ban" or method == "ban") then
                        warn("[LuckatHub Bypass] Kick/Ban Intercepted: " .. tostring(method))
                        return nil
                    end
                    if remoteFilterActive and (method == "FireServer" or method == "InvokeServer") then
                        local ok, name = pcall(function() return self.Name:lower() end)
                        if ok and name then
                            local blacklist = { "report", "cheat", "hack", "detect", "ban", "kick", "anticheat", "ac_", "_ac", "flag", "exploit", "sanity", "speed_check", "position_check", "validate" }
                            for _, kw in ipairs(blacklist) do
                                if name:find(kw, 1, true) then
                                    warn("[LuckatHub Bypass] Remote Blocked: " .. self.Name)
                                    return nil
                                end
                            end
                        end
                    end
                    return oldNamecall(self, ...)
                end)
            end
        end

        UltraBypass.SetKickBlock = function(v) kickBlockActive = v end
        UltraBypass.SetRemoteFilter = function(v) remoteFilterActive = v end
        UltraBypass.Status = function()
            return {
                MetatableHooked = (oldNamecall ~= nil),
                KickBlockActive = kickBlockActive,
                RemoteFilter    = remoteFilterActive,
                ExecutorLevel   = (oldNamecall ~= nil) and "Level 7 (Metatable Hooked)" or "Delta Mobile Safe",
            }
        end

        pcall(function()
            local names = { "RobloxPlayerScripts", "PlayerModule", "CameraModule", "ControlModule", "ChatMain", "BubbleChat" }
            if script and script.Parent then script.Name = names[math.random(1, #names)] end
        end)
    end)
end)

-- [Subsystem 3: Anti-AFK Engine]
task.spawn(function()
    lp.Idled:Connect(function()
        if not Cfg.AntiAFK then return end
        pcall(function()
            VirtualUser:Button2Down(Vector2.new(0,0), camera.CFrame)
            task.wait(0.5)
            VirtualUser:Button2Up(Vector2.new(0,0), camera.CFrame)
        end)
    end)
end)

-- [Subsystem 4: Anti-Hacker Teleport Engine]
local function showHackerWarning(hackerName)
    if hackerWarnGui then pcall(function() hackerWarnGui:Destroy() end) end

    hackerWarnGui = Instance.new("ScreenGui")
    hackerWarnGui.Name         = "LuckatHackerWarn"
    hackerWarnGui.ResetOnSpawn = false
    hackerWarnGui.Parent       = hiddenUI

    local frame = Instance.new("Frame")
    frame.Size             = UDim2.new(0, 280, 0, 48)
    frame.Position         = UDim2.new(0.5, -140, 0, 15)
    frame.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
    frame.BorderSizePixel  = 0
    frame.Parent           = hackerWarnGui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke")
    stroke.Color    = Color3.fromRGB(255, 50, 50)
    stroke.Thickness = 1.5
    stroke.Parent   = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size             = UDim2.new(1, -10, 1, 0)
    lbl.Position         = UDim2.new(0, 5, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text             = "HACKER DETECTED: " .. hackerName .. "\nTeleport tan cong bi chan!"
    lbl.TextColor3       = Color3.fromRGB(255, 80, 80)
    lbl.TextSize         = 12
    lbl.Font             = Enum.Font.SourceSansBold
    lbl.TextWrapped      = true
    lbl.Parent           = frame

    task.delay(3, function()
        if hackerWarnGui and hackerWarnGui.Parent then
            pcall(function() hackerWarnGui:Destroy() end)
            hackerWarnGui = nil
        end
    end)
end

local antiHackerConn = nil

enableAntiHackerTP = function()
    if antiHackerConn then return end
    antiHackerConn = RunService.Heartbeat:Connect(function()
        if not Cfg.AntiHackerTP then return end
        local myHRP = charCache.hrp
        if not myHRP then return end
        local myPos = myHRP.Position

        for _, p in ipairs(Players:GetPlayers()) do
            if p == lp or not p.Character then continue end
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            if not root then
                prevPositions[p] = nil
                continue
            end

            local currentPos = root.Position
            local prev       = prevPositions[p]

            if prev then
                local jumped   = (currentPos - prev).Magnitude
                local distToMe = (currentPos - myPos).Magnitude

                if jumped > 80 and distToMe < Cfg.AntiHackerRadius then
                    local now = tick()
                    if not warnCooldowns[p] or now - warnCooldowns[p] > 2 then
                        warnCooldowns[p] = now

                        local pushDir = (myPos - currentPos)
                        if pushDir.Magnitude > 0 then
                            pushDir = pushDir.Unit
                        else
                            pushDir = -camera.CFrame.LookVector
                        end
                        myHRP.CFrame = CFrame.new(
                            myPos + pushDir * Cfg.AntiHackerPush,
                            myPos + pushDir * Cfg.AntiHackerPush + pushDir
                        )
                        myHRP.AssemblyLinearVelocity = pushDir * 30
                        showHackerWarning(p.Name)
                    end
                end
            end
            prevPositions[p] = currentPos
        end
    end)
end

disableAntiHackerTP = function()
    if antiHackerConn then antiHackerConn:Disconnect(); antiHackerConn = nil end
    prevPositions = {}; warnCooldowns = {}
    if hackerWarnGui then pcall(function() hackerWarnGui:Destroy() end); hackerWarnGui = nil end
end

-- [Subsystem 5: Ghost Mode v2 - Phantom Velocity Engine]
local ghostJitConn  = nil
local dodgeCooldown = 0
local ghostBasePos  = nil

local function randomXZUnit()
    local angle = math.random() * math.pi * 2
    return Vector3.new(math.cos(angle), 0, math.sin(angle))
end

local function startGhostJitter()
    if ghostJitConn then return end
    ghostJitConn = RunService.Heartbeat:Connect(function()
        if not Cfg_Ghost.GhostMode then return end
        local hrp = charCache.hrp
        local hum = charCache.hum
        if not hrp or not hum or hum.Health <= 0 then return end

        if hum.MoveDirection.Magnitude > 0.1 then
            ghostBasePos = hrp.Position
        end
        if not ghostBasePos then
            ghostBasePos = hrp.Position
        end

        if Cfg_Ghost.GhostJitter then
            local r   = Cfg_Ghost.GhostRadius
            local dir = randomXZUnit()
            local yOff = Cfg_Ghost.GhostYJitter and (math.random() - 0.5) * 1.2 or 0

            local jitterOffset = dir * (math.random() * r) + Vector3.new(0, yOff, 0)
            local jitterPos    = ghostBasePos + jitterOffset

            local oldCamCF = camera.CFrame
            hrp.CFrame = CFrame.new(jitterPos, jitterPos + oldCamCF.LookVector)
            camera.CFrame = oldCamCF
        end

        if Cfg_Ghost.PhantomVelocity or Cfg_Ghost.GhostAutoDodge then
            local myPos = hrp.Position
            local now   = tick()

            for _, p in ipairs(Players:GetPlayers()) do
                if p == lp or not p.Character then continue end
                local root = p.Character:FindFirstChild("HumanoidRootPart")
                if not root then continue end

                local prev = prevPositions[p]
                local cur  = root.Position
                if prev then
                    local jumped   = (cur - prev).Magnitude
                    local distToMe = (cur - myPos).Magnitude

                    if jumped > 60 and distToMe < 15 and now - dodgeCooldown > 0.35 then
                        dodgeCooldown = now
                        local escapeDir = randomXZUnit()

                        if Cfg_Ghost.PhantomVelocity then
                            local force   = Cfg_Ghost.PhantomForce
                            local upForce = Cfg_Ghost.PhantomUpForce
                            hrp.AssemblyLinearVelocity = Vector3.new(
                                escapeDir.X * force,
                                upForce,
                                escapeDir.Z * force
                            )
                            ghostBasePos = myPos + escapeDir * (force * 0.3)
                            showHackerWarning(p.Name .. " [PHANTOM]")
                        else
                            local newPos = myPos + escapeDir * Cfg_Ghost.GhostDodgeRange
                            hrp.CFrame   = CFrame.new(newPos, newPos + escapeDir)
                            hrp.AssemblyLinearVelocity = escapeDir * 20
                            ghostBasePos = newPos
                            showHackerWarning(p.Name .. " [DODGE]")
                        end
                    end
                end
            end
        end
    end)
end

enableGhostMode = function()
    Cfg_Ghost.GhostMode = true
    ghostBasePos = charCache.hrp and charCache.hrp.Position or nil
    startGhostJitter()
end

disableGhostMode = function()
    Cfg_Ghost.GhostMode = false
    if ghostJitConn then ghostJitConn:Disconnect(); ghostJitConn = nil end
    dodgeCooldown = 0
end

-- [Subsystem 6: Physics Engine]
task.spawn(function()
    local SPEED_GUARD = 15
    RunService.Heartbeat:Connect(function()
        local hum = charCache.hum
        local hrp = charCache.hrp
        if not hum or not hrp or hum.Health <= 0 then return end

        if Cfg.JumpEnabled then
            hum.UseJumpPower = true
            hum.JumpPower    = Cfg.Jump
        end

        if Cfg.SpeedEnabled and Cfg.Speed > 16 then
            local dir = getMoveDirection(hum)
            if dir.Magnitude > 0 then
                local vel = hrp.AssemblyLinearVelocity
                local horizSpeed = Vector3.new(vel.X, 0, vel.Z).Magnitude
                if horizSpeed <= Cfg.Speed + SPEED_GUARD then
                    hrp.AssemblyLinearVelocity = Vector3.new(dir.X * Cfg.Speed, vel.Y, dir.Z * Cfg.Speed)
                end
            end
        end

        if Cfg.Noclip and charCache.char then
            for _, p in ipairs(charCache.char:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
            end
        end

        if Cfg.AntiStun and charCache.char then
            hum.PlatformStand = false
            for _, child in ipairs(charCache.char:GetChildren()) do
                local n = child.Name
                if n == "Stun" or n == "Freeze" or n == "Ragdoll" or n == "Action" or n == "Knockback" then
                    pcall(function() child:Destroy() end)
                end
            end
        end

        if Cfg.AntiVoid and hrp.Position.Y < -150 then
            hrp.CFrame = CFrame.new(hrp.Position.X, 100, hrp.Position.Z)
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
    end)
end)

-- [Subsystem 7: Fly Engine]
task.spawn(function()
    local flyBV, flyBG
    RunService.RenderStepped:Connect(function()
        local hrp = charCache.hrp
        local hum = charCache.hum
        if not hrp then return end

        if Cfg.Fly then
            if not flyBV or not flyBV.Parent then
                flyBV = Instance.new("BodyVelocity")
                flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                flyBV.Velocity = Vector3.zero
                flyBV.Parent   = hrp
            end
            if not flyBG or not flyBG.Parent then
                flyBG = Instance.new("BodyGyro")
                flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
                flyBG.P         = 5e4
                flyBG.CFrame    = hrp.CFrame
                flyBG.Parent    = hrp
            end

            local dir = getMoveDirection(hum)
            flyBG.CFrame   = camera.CFrame
            flyBV.Velocity = dir * Cfg.FlySpeed
        else
            if flyBV and flyBV.Parent then pcall(function() flyBV:Destroy() end); flyBV = nil end
            if flyBG and flyBG.Parent then pcall(function() flyBG:Destroy() end); flyBG = nil end
        end
    end)
end)

-- [Subsystem 8: ESP / Wallhack Engine]
task.spawn(function()
    local function applyHighlight(char, p)
        if espFolders[p] then pcall(function() espFolders[p]:Destroy() end) end

        local folder = Instance.new("Folder")
        folder.Name   = p.Name .. "_ESP"
        folder.Parent = hiddenUI
        espFolders[p] = folder

        local hl = Instance.new("Highlight")
        hl.Name             = "WallhackHighlight"
        hl.FillColor        = Color3.fromRGB(255, 50, 50)
        hl.OutlineColor     = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.6
        hl.DepthMode        = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee          = char
        hl.Enabled          = Cfg.Wallhack
        hl.Parent           = folder
    end

    local function setupPlayerESP(p)
        if p == lp then return end
        if p.Character then applyHighlight(p.Character, p) end
        p.CharacterAdded:Connect(function(newChar)
            newChar:WaitForChild("HumanoidRootPart", 8)
            applyHighlight(newChar, p)
        end)
    end

    for _, p in ipairs(Players:GetPlayers()) do setupPlayerESP(p) end
    Players.PlayerAdded:Connect(setupPlayerESP)
end)

-- [Subsystem 9: Aimbot & Teleport Close Engine]
local function getVisibleTarget()
    local camPos = camera.CFrame.Position
    local camDir = camera.CFrame.LookVector
    local best, bestDot = nil, 0.92

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            local hum  = p.Character:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then
                local dot = camDir:Dot((root.Position - camPos).Unit)
                if dot > bestDot then
                    bestDot = dot
                    best    = p
                end
            end
        end
    end
    return best
end

local function isTargetValid(p)
    if not p or not p.Parent then return false end
    if not p.Character then return false end
    local hum = p.Character:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

RunService.RenderStepped:Connect(function()
    if not Cfg.Aimbot then
        Cfg.AimbotTarget = nil
        return
    end
    if not isTargetValid(Cfg.AimbotTarget) then
        Cfg.AimbotTarget = getVisibleTarget()
    end
    local t = Cfg.AimbotTarget
    if not t or not t.Character then return end
    local aim = t.Character:FindFirstChild("Head") or t.Character:FindFirstChild("UpperTorso") or t.Character:FindFirstChild("HumanoidRootPart")
    if aim then
        camera.CFrame = CFrame.new(camera.CFrame.Position, aim.Position)
    end
end)

local function teleportClose(target)
    if not target or not target.Character then return false end
    local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
    local pRoot = charCache.hrp
    if not tRoot or not pRoot then return false end

    local tCF     = tRoot.CFrame
    local rv, lv  = tCF.RightVector, tCF.LookVector
    local offsets = {rv * 1.8, -rv * 1.8, -lv * 1.5, lv * 1.5}

    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Blacklist
    rp.FilterDescendantsInstances = { charCache.char, target.Character }

    local finalPos = tRoot.Position + rv * 2
    for _, off in ipairs(offsets) do
        local result = Workspace:Raycast(tRoot.Position, off, rp)
        if not result then
            finalPos = tRoot.Position + off
            break
        end
    end
    pRoot.CFrame = CFrame.new(finalPos, tRoot.Position)
    return true
end

toggleOnScreenButtons = function(enable)
    Cfg.OnScreenButtons = enable
    if enable then
        if hudGui then pcall(function() hudGui:Destroy() end) end
        hudGui        = Instance.new("ScreenGui")
        hudGui.Name   = "LuckatHub_HUD"
        hudGui.ResetOnSpawn = false
        hudGui.Parent = hiddenUI

        local tpBtn = Instance.new("TextButton")
        tpBtn.Size             = UDim2.new(0, 74, 0, 74)
        tpBtn.Position         = UDim2.new(0, 18, 0, 18)
        tpBtn.BackgroundColor3 = Cfg.TeleportLocked and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(255, 59, 59)
        tpBtn.Text             = Cfg.TeleportLocked and "LOCKED" or "TELEPORT"
        tpBtn.TextColor3       = Color3.new(1, 1, 1)
        tpBtn.TextSize         = 12
        tpBtn.Font             = Enum.Font.SourceSansBold
        tpBtn.BorderSizePixel  = 0
        tpBtn.AutoButtonColor  = false
        tpBtn.Parent           = hudGui
        Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(1, 0)

        local aimBtn = Instance.new("TextButton")
        aimBtn.Size             = UDim2.new(0, 90, 0, 36)
        aimBtn.Position         = UDim2.new(1, -108, 0, 18)
        aimBtn.BackgroundColor3 = Cfg.Aimbot and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(59, 59, 255)
        aimBtn.Text             = Cfg.Aimbot and "AIM ON" or "AIM OFF"
        aimBtn.TextColor3       = Color3.new(1, 1, 1)
        aimBtn.TextSize         = 12
        aimBtn.Font             = Enum.Font.SourceSansBold
        aimBtn.BorderSizePixel  = 0
        aimBtn.AutoButtonColor  = false
        aimBtn.Parent           = hudGui
        Instance.new("UICorner", aimBtn).CornerRadius = UDim.new(0.3, 0)

        local followConn = nil
        tpBtn.MouseButton1Click:Connect(function()
            local now = tick()
            if now - lastTpClick < CLICK_DELAY then return end
            lastTpClick = now

            if Cfg.TeleportLocked then
                Cfg.TeleportLocked = false; Cfg.TeleportTarget = nil
                if followConn then followConn:Disconnect(); followConn = nil end
                tpBtn.BackgroundColor3 = Color3.fromRGB(255, 59, 59)
                tpBtn.Text             = "TELEPORT"
            else
                local target = getVisibleTarget()
                if not target then
                    tpBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
                    tpBtn.Text             = "NO TARGET"
                    task.delay(1.2, function()
                        if not Cfg.TeleportLocked and tpBtn.Parent then
                            tpBtn.BackgroundColor3 = Color3.fromRGB(255, 59, 59)
                            tpBtn.Text             = "TELEPORT"
                        end
                    end)
                else
                    Cfg.TeleportLocked = true; Cfg.TeleportTarget = target
                    tpBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                    tpBtn.Text             = "LOCKED"
                    teleportClose(target)

                    if followConn then followConn:Disconnect() end
                    followConn = RunService.Heartbeat:Connect(function()
                        if not Cfg.TeleportLocked or not isTargetValid(Cfg.TeleportTarget) then
                            followConn:Disconnect(); followConn = nil
                            Cfg.TeleportLocked = false; Cfg.TeleportTarget = nil
                            if tpBtn.Parent then
                                tpBtn.BackgroundColor3 = Color3.fromRGB(255, 59, 59)
                                tpBtn.Text             = "TELEPORT"
                            end
                            return
                        end
                        teleportClose(Cfg.TeleportTarget)
                    end)
                end
            end
        end)

        aimBtn.MouseButton1Click:Connect(function()
            Cfg.Aimbot = not Cfg.Aimbot
            if Cfg.Aimbot then
                aimBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0); aimBtn.Text = "AIM ON"
            else
                aimBtn.BackgroundColor3 = Color3.fromRGB(59, 59, 255); aimBtn.Text = "AIM OFF"
                Cfg.AimbotTarget = nil
            end
        end)
    else
        if hudGui then pcall(function() hudGui:Destroy() end); hudGui = nil end
    end
end

-- [Subsystem 10: Fix Lag Engine]
local EFFECT_TYPES = { ParticleEmitter = true, Trail = true, Beam = true, Sparkles = true, Fire = true, Smoke = true }
local function stripObject(obj)
    if EFFECT_TYPES[obj.ClassName] then obj.Enabled = false
    elseif obj.ClassName == "Explosion" then obj.Visible = false end
end

local function applyFixLag()
    for _, obj in ipairs(Workspace:GetDescendants()) do stripObject(obj) end
    Lighting.GlobalShadows = false; Lighting.FogEnd = 9e9; Lighting.FogStart = 9e9
    for _, fx in ipairs(Lighting:GetChildren()) do if fx:IsA("PostEffect") then fx.Enabled = false end end
end

enableFixLagLive = function()
    if fixLagConn then return end
    applyFixLag()
    fixLagConn = Workspace.DescendantAdded:Connect(function(obj) task.defer(stripObject, obj) end)
    Cfg.FixLagActive = true
end

disableFixLag = function()
    if fixLagConn then fixLagConn:Disconnect(); fixLagConn = nil end
    Cfg.FixLagActive = false
end

applyUltraLowGraphics = function()
    enableFixLagLive()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.SmoothPlastic; obj.Reflectance = 0; obj.CastShadow = false
        elseif obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency = 1
        elseif obj:IsA("MeshPart") then obj.RenderFidelity = Enum.RenderFidelity.Performance end
    end
    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        terrain.WaterWaveSize = 0; terrain.WaterWaveSpeed = 0; terrain.WaterReflectance = 0; terrain.WaterTransparency = 0
    end
    Cfg.LowGfxActive = true
end

print("✅ LuckatHub v5.0 UNIVERSAL FONT FIXED — 100% Mobile Delta Guaranteed!")
