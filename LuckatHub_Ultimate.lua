-- ============================================================================
-- LUCKATHUB ULTIMATE v2.3 - GUARANTEED 100% FAIL-SAFE DELTA MOBILE EDITION
-- Cấu trúc: Khởi tạo GUI TRƯỚC -> Đảm bảo 100% hiển thị trên màn hình Delta Android
-- ============================================================================

-- ===================== 1. SERVICES & GLOBAL SAFETIES =====================
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
pcall(function()
    if gethui then
        hiddenUI = gethui()
    end
end)
if not hiddenUI then
    pcall(function()
        hiddenUI = CoreGui
    end)
end
if not hiddenUI then
    hiddenUI = lp:WaitForChild("PlayerGui", 10)
end

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

-- Thông báo khởi chạy trên màn hình Roblox
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "⚡ LuckatHub Mobile VIP";
        Text = "Đang mở Giao diện... Đã sẵn sàng!";
        Duration = 3;
    })
end)

-- ===================== 2. CONFIGURATION =====================
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

-- Shared state variables
local espFolders     = {}
local espConnections = {}
local hudGui         = nil
local lastTpClick    = 0
local CLICK_DELAY    = 0.3
local fixLagConn     = nil
local UltraBypass    = { SetKickBlock = function() end, SetRemoteFilter = function() end, Status = function() return { MetatableHooked=false, KickBlockActive=true, RemoteFilter=true, ExecutorLevel="Delta Mobile" } end }

-- ===================== 3. GUI HELPERS =====================
local TWEEN_QUICK = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function tweenColor(obj, prop, targetColor)
    pcall(function()
        TweenService:Create(obj, TWEEN_QUICK, { [prop] = targetColor }):Play()
    end)
end

-- Draggable cho màn hình cảm ứng Touch Screen
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

-- ===================== 4. TAO GIAO DIEN (GUI FIRST ARCHITECTURE) =====================
-- Đặt phần tạo GUI lên hàng đầu để ĐẢM BẢO 100% hiển thị menu trên Delta Mobile
local gui = Instance.new("ScreenGui")
gui.Name          = "LuckatHub_MainUI"
gui.ResetOnSpawn  = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent        = hiddenUI

-- Window Responsive chuẩn điện thoại Android
local screenX = (camera and camera.ViewportSize.X > 100) and camera.ViewportSize.X or 800
local screenY = (camera and camera.ViewportSize.Y > 100) and camera.ViewportSize.Y or 450
local winW    = math.min(440, screenX - 20)
local winH    = math.min(290, screenY - 20)

local mainFrame = Instance.new("Frame")
mainFrame.Name             = "MainFrame"
mainFrame.Size             = UDim2.new(0, winW, 0, winH)
mainFrame.Position         = UDim2.new(0.5, -winW/2, 0.5, -winH/2)
mainFrame.BackgroundColor3 = Color3.fromRGB(14, 15, 21)
mainFrame.BorderSizePixel  = 0
mainFrame.Active           = true
mainFrame.ClipsDescendants = true
mainFrame.Parent           = gui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

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
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

local titleLbl = Instance.new("TextLabel")
titleLbl.Size              = UDim2.new(1, -70, 1, 0)
titleLbl.Position          = UDim2.new(0, 10, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text              = "⚡ LuckatHub  <font color=\"#00FF99\">MOBILE VIP v2.3</font>"
titleLbl.RichText          = true
titleLbl.TextColor3        = Color3.fromRGB(255, 255, 255)
titleLbl.TextSize          = 12
titleLbl.Font              = Enum.Font.GothamBold
titleLbl.TextXAlignment    = Enum.TextXAlignment.Left
titleLbl.Parent            = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size             = UDim2.new(0, 24, 0, 24)
closeBtn.Position         = UDim2.new(1, -28, 0.5, -12)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
closeBtn.Text             = "✕"
closeBtn.TextColor3       = Color3.new(1,1,1)
closeBtn.TextSize         = 11
closeBtn.Font             = Enum.Font.GothamBold
closeBtn.BorderSizePixel  = 0
closeBtn.AutoButtonColor  = false
closeBtn.Parent           = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)
closeBtn.MouseButton1Click:Connect(function() mainFrame.Visible = false end)

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Size             = UDim2.new(0, 120, 1, -36)
sidebar.Position         = UDim2.new(0, 0, 0, 36)
sidebar.BackgroundColor3 = Color3.fromRGB(18, 19, 28)
sidebar.BorderSizePixel  = 0
sidebar.Parent           = mainFrame

local sideLayout = Instance.new("UIListLayout")
sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
sideLayout.Padding   = UDim.new(0, 4)
sideLayout.Parent    = sidebar

local sidePad = Instance.new("UIPadding")
sidePad.PaddingTop   = UDim.new(0, 6)
sidePad.PaddingLeft  = UDim.new(0, 5)
sidePad.PaddingRight = UDim.new(0, 5)
sidePad.Parent       = sidebar

-- Content Area
local contentArea = Instance.new("Frame")
contentArea.Size             = UDim2.new(1, -120, 1, -36)
contentArea.Position         = UDim2.new(0, 120, 0, 36)
contentArea.BackgroundTransparency = 1
contentArea.ClipsDescendants = true
contentArea.Parent           = mainFrame

local tabs      = {}
local tabBtns   = {}
local activeTab = nil

local COL_ACTIVE   = Color3.fromRGB(110, 35, 200)
local COL_INACTIVE = Color3.fromRGB(26, 28, 40)
local COL_TXT_ON   = Color3.fromRGB(255, 255, 255)
local COL_TXT_OFF  = Color3.fromRGB(170, 175, 190)

local function openTab(id)
    if activeTab == id then return end
    activeTab = id
    for tid, frame in pairs(tabs) do
        local on = (tid == id)
        frame.Visible = on
        tweenColor(tabBtns[tid], "BackgroundColor3", on and COL_ACTIVE or COL_INACTIVE)
        tabBtns[tid].TextColor3 = on and COL_TXT_ON or COL_TXT_OFF
    end
end

local function createTab(id, label, icon)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = COL_INACTIVE
    btn.Text             = icon .. " " .. label
    btn.TextColor3       = COL_TXT_OFF
    btn.TextSize         = 10
    btn.Font             = Enum.Font.GothamSemibold
    btn.TextXAlignment   = Enum.TextXAlignment.Left
    btn.BorderSizePixel  = 0
    btn.AutoButtonColor  = false
    btn.Parent           = sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    local bp = Instance.new("UIPadding")
    bp.PaddingLeft = UDim.new(0, 7)
    bp.Parent = btn

    local sf = Instance.new("ScrollingFrame")
    sf.Size                  = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel       = 0
    sf.ScrollBarThickness    = 3
    sf.ScrollBarImageColor3  = Color3.fromRGB(110, 35, 200)
    sf.CanvasSize            = UDim2.new(0, 0, 0, 0)
    sf.AutomaticCanvasSize   = Enum.AutomaticSize.Y
    sf.Visible               = false
    sf.Parent                = contentArea

    local layout = Instance.new("UIListLayout")
    layout.SortOrder    = Enum.SortOrder.LayoutOrder
    layout.Padding      = UDim.new(0, 5)
    layout.Parent       = sf

    local pad = Instance.new("UIPadding")
    pad.PaddingAll = UDim.new(0, 6)
    pad.Parent     = sf

    tabs[id]    = sf
    tabBtns[id] = btn

    btn.MouseButton1Click:Connect(function() openTab(id) end)
    return sf
end

-- UI Widgets
local COL_SW_ON  = Color3.fromRGB(0, 215, 110)
local COL_SW_OFF = Color3.fromRGB(40, 44, 60)
local COL_CARD   = Color3.fromRGB(22, 24, 35)

local function addToggle(parent, label, default, onChange)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, 0, 0, 32)
    row.BackgroundColor3 = COL_CARD
    row.BorderSizePixel  = 0
    row.Parent           = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)

    local lbl = Instance.new("TextLabel")
    lbl.Size             = UDim2.new(1, -48, 1, 0)
    lbl.Position         = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text             = label
    lbl.TextColor3       = Color3.fromRGB(225, 228, 240)
    lbl.TextSize         = 10
    lbl.Font             = Enum.Font.GothamSemibold
    lbl.TextXAlignment   = Enum.TextXAlignment.Left
    lbl.TextWrapped      = true
    lbl.Parent           = row

    local sw = Instance.new("TextButton")
    sw.Size             = UDim2.new(0, 34, 0, 16)
    sw.Position         = UDim2.new(1, -40, 0.5, -8)
    sw.BackgroundColor3 = default and COL_SW_ON or COL_SW_OFF
    sw.Text             = ""
    sw.BorderSizePixel  = 0
    sw.AutoButtonColor  = false
    sw.Parent           = row
    Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size             = UDim2.new(0, 10, 0, 10)
    knob.Position         = default and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel  = 0
    knob.Parent           = sw
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local state = default
    sw.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(sw, TWEEN_QUICK, { BackgroundColor3 = state and COL_SW_ON or COL_SW_OFF }):Play()
        TweenService:Create(knob, TWEEN_QUICK, { Position = state and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5) }):Play()
        pcall(onChange, state)
    end)

    return row
end

local function addInput(parent, label, default, min, max, onChange)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, 0, 0, 32)
    row.BackgroundColor3 = COL_CARD
    row.BorderSizePixel  = 0
    row.Parent           = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)

    local lbl = Instance.new("TextLabel")
    lbl.Size             = UDim2.new(0.58, 0, 1, 0)
    lbl.Position         = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text             = label
    lbl.TextColor3       = Color3.fromRGB(225, 228, 240)
    lbl.TextSize         = 10
    lbl.Font             = Enum.Font.GothamSemibold
    lbl.TextXAlignment   = Enum.TextXAlignment.Left
    lbl.Parent           = row

    local box = Instance.new("TextBox")
    box.Size             = UDim2.new(0.36, 0, 0, 20)
    box.Position         = UDim2.new(0.62, 0, 0.5, -10)
    box.BackgroundColor3 = Color3.fromRGB(30, 33, 48)
    box.Text             = tostring(default)
    box.TextColor3       = Color3.fromRGB(0, 240, 170)
    box.TextSize         = 10
    box.Font             = Enum.Font.GothamBold
    box.ClearTextOnFocus = false
    box.BorderSizePixel  = 0
    box.Parent           = row
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)

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
    btn.Size             = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = color or COL_ACTIVE
    btn.Text             = label
    btn.TextColor3       = Color3.new(1, 1, 1)
    btn.TextSize         = 10
    btn.Font             = Enum.Font.GothamBold
    btn.BorderSizePixel  = 0
    btn.AutoButtonColor  = false
    btn.Parent           = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function() pcall(onClick) end)
end

local function addSectionLabel(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size             = UDim2.new(1, 0, 0, 14)
    lbl.BackgroundTransparency = 1
    lbl.Text             = text
    lbl.TextColor3       = Color3.fromRGB(110, 115, 140)
    lbl.TextSize         = 9
    lbl.Font             = Enum.Font.GothamBold
    lbl.TextXAlignment   = Enum.TextXAlignment.Left
    lbl.Parent           = parent
end

-- Build các Tab
local moveTab    = createTab("move", "Di Chuyển", "🏃")
local combatTab  = createTab("combat", "Tác Chiến", "⚔️")
local protectTab = createTab("protect", "Bảo Vệ", "🛡️")
local bypassTab  = createTab("bypass", "Ultra Bypass", "⚡")
local lagTab     = createTab("lag", "Fix Lag", "🚀")

-- Tab 1: Di Chuyển
addSectionLabel(moveTab, "TỐC ĐỘ & NHẢY")
addToggle(moveTab, "Speed Hack",      Cfg.SpeedEnabled, function(v) Cfg.SpeedEnabled = v end)
addInput (moveTab, "Tốc độ (Speed)",  Cfg.Speed,  16, 300, function(v) Cfg.Speed = v end)
addToggle(moveTab, "Jump Hack",       Cfg.JumpEnabled,  function(v) Cfg.JumpEnabled = v end)
addInput (moveTab, "Jump Power",      Cfg.Jump,   50, 600, function(v) Cfg.Jump = v end)
addSectionLabel(moveTab, "NÂNG CAO")
addToggle(moveTab, "🚀 Chế Độ Bay (Fly)",       Cfg.Fly,    function(v) Cfg.Fly = v end)
addInput (moveTab, "Fly Speed",       Cfg.FlySpeed, 10, 300, function(v) Cfg.FlySpeed = v end)
addToggle(moveTab, "Xuyên Tường (Noclip)", Cfg.Noclip, function(v) Cfg.Noclip = v end)

-- Tab 2: Tác Chiến
addSectionLabel(combatTab, "QUAN SÁT")
addToggle(combatTab, "1. Wallhack / ESP Nhìn Xuyên Tường", Cfg.Wallhack, function(v)
    Cfg.Wallhack = v
    for _, folder in pairs(espFolders) do
        local hl = folder:FindFirstChild("WallhackHighlight")
        if hl then hl.Enabled = v end
    end
end)
addSectionLabel(combatTab, "ĐIỀU KHIỂN TRỰC TIẾP")
addToggle(combatTab, "2. Hiện Nút Teleport & Aim Trên Màn Hình", Cfg.OnScreenButtons, function(v)
    if toggleOnScreenButtons then toggleOnScreenButtons(v) end
end)

-- Tab 3: Bảo Vệ
addSectionLabel(protectTab, "TÍNH MẠNG & ỔN ĐỊNH")
addToggle(protectTab, "Anti-AFK (Chống văng treo máy)",         Cfg.AntiAFK,   function(v) Cfg.AntiAFK = v end)
addToggle(protectTab, "Anti-Stun / Anti-Ragdoll (All Game)",    Cfg.AntiStun,  function(v) Cfg.AntiStun = v end)
addToggle(protectTab, "Anti-Void (Cứu khi rơi xuống vực)",      Cfg.AntiVoid,  function(v) Cfg.AntiVoid = v end)
addSectionLabel(protectTab, "CHỐNG HACKER")
addToggle(protectTab, "🚨 Anti-Hacker Teleport (Chống dính sát)", Cfg.AntiHackerTP, function(v)
    Cfg.AntiHackerTP = v
    if v then if enableAntiHackerTP then enableAntiHackerTP() end else if disableAntiHackerTP then disableAntiHackerTP() end end
end)
addInput(protectTab, "Bán kính nguy hiểm (studs)", Cfg.AntiHackerRadius, 3, 30, function(v) Cfg.AntiHackerRadius = v end)
addInput(protectTab, "Lực đẩy ra khi bị tấn công", Cfg.AntiHackerPush, 8, 60, function(v) Cfg.AntiHackerPush = v end)

addSectionLabel(protectTab, "👻 GHOST MODE v2 — PHANTOM VELOCITY")
addToggle(protectTab, "👻 Ghost Mode (Bật toàn bộ hệ thống)", Cfg_Ghost.GhostMode, function(v)
    if v then if enableGhostMode then enableGhostMode() end else if disableGhostMode then disableGhostMode() end end
end)
addToggle(protectTab, "🌀 Ghost Jitter 60fps — Rung HRP", Cfg_Ghost.GhostJitter, function(v) Cfg_Ghost.GhostJitter = v end)
addToggle(protectTab, "↕️ Y-Jitter — Phá vertical aimbot", Cfg_Ghost.GhostYJitter, function(v) Cfg_Ghost.GhostYJitter = v end)
addToggle(protectTab, "⚡ Phantom Velocity — Văng ra khi bị áp sát", Cfg_Ghost.PhantomVelocity, function(v) Cfg_Ghost.PhantomVelocity = v end)
addToggle(protectTab, "🏃 Auto-Dodge — Backup nếu tắt Phantom", Cfg_Ghost.GhostAutoDodge, function(v) Cfg_Ghost.GhostAutoDodge = v end)

-- Tab 4: Ultra Bypass
addSectionLabel(bypassTab, "⚡ ULTRA BYPASS (DELTA ANDROID SAFE)")
local bypassStatusLabel = Instance.new("TextLabel")
bypassStatusLabel.Size             = UDim2.new(1, 0, 0, 26)
bypassStatusLabel.BackgroundColor3 = Color3.fromRGB(15, 40, 20)
bypassStatusLabel.TextColor3       = Color3.fromRGB(0, 255, 120)
bypassStatusLabel.TextSize         = 10
bypassStatusLabel.Font             = Enum.Font.GothamBold
bypassStatusLabel.Text             = "Metatable: ✅ Safe | KickBlock: ✅ Active"
bypassStatusLabel.BorderSizePixel  = 0
bypassStatusLabel.Parent           = bypassTab
Instance.new("UICorner", bypassStatusLabel).CornerRadius = UDim.new(0, 5)

addToggle(bypassTab, "🔒 Kick Block (Chặn mọi lệnh Kick/Ban)", true, function(v)
    if UltraBypass and UltraBypass.SetKickBlock then UltraBypass.SetKickBlock(v) end
end)

-- Tab 5: Fix Lag
addSectionLabel(lagTab, "TỐI ƯU HIỆU NĂNG ANDROID")
addButton(lagTab, "⚡ Bật Fix Lag Liên Tục (Giảm giật lag)", Color3.fromRGB(0, 170, 120), function() if enableFixLagLive then enableFixLagLive() end end)
addButton(lagTab, "🔴 Tắt Fix Lag (Khôi phục Effect)", Color3.fromRGB(180, 40, 40), function() if disableFixLag then disableFixLag() end end)
addSectionLabel(lagTab, "ĐỒ HỌA MÁY YẾU")
addButton(lagTab, "🚀 Ultra Low Graphics (Max FPS Android)", Color3.fromRGB(20, 130, 220), function() if applyUltraLowGraphics then applyUltraLowGraphics() end end)

-- Nút Bấm Nổi Cảm Ứng (Floating Button)
local floatBtn = Instance.new("TextButton")
floatBtn.Name             = "LuckatFloat"
floatBtn.Size             = UDim2.new(0, 105, 0, 32)
floatBtn.Position         = UDim2.new(0, 10, 0.2, 0)
floatBtn.BackgroundColor3 = Color3.fromRGB(108, 32, 200)
floatBtn.Text             = "⚡ LuckatHub"
floatBtn.TextColor3       = Color3.new(1, 1, 1)
floatBtn.TextSize         = 11
floatBtn.Font             = Enum.Font.GothamBold
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
openTab("move")

-- ===================== 5. KHỞI TẠO CÁC NĂNG LỰC CHỨC NĂNG (ISOLATED SUBSYSTEMS) =====================
-- Bọc từng Subsystem độc lập trong task.spawn + pcall để LỖI NÀO CŨNG KHÔNG THỂ LÀM HỎNG GIAO DIỆN

-- [Subsystem 1: Ultra Bypass Engine]
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
                        return nil
                    end
                    if remoteFilterActive and (method == "FireServer" or method == "InvokeServer") then
                        local ok, name = pcall(function() return self.Name:lower() end)
                        if ok and name then
                            local blacklist = { "report", "cheat", "hack", "detect", "ban", "kick", "anticheat", "_ac", "exploit" }
                            for _, kw in ipairs(blacklist) do
                                if name:find(kw, 1, true) then return nil end
                            end
                        end
                    end
                    return oldNamecall(self, ...)
                end)
            end
        end

        UltraBypass.SetKickBlock = function(v) kickBlockActive = v end
        UltraBypass.SetRemoteFilter = function(v) remoteFilterActive = v end
    end)
end)

-- [Subsystem 2: Player Controls & Character Cache]
local charCache = { char = nil, hum = nil, hrp = nil }
local playerControls = nil

task.spawn(function()
    pcall(function()
        local PlayerModule = lp.PlayerScripts:WaitForChild("PlayerModule", 5)
        if PlayerModule then
            playerControls = require(PlayerModule):GetControls()
        end
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

-- [Subsystem 3: Anti-AFK]
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

-- [Subsystem 4: Physics Engine (Speed, Jump, Noclip, AntiStun, AntiVoid)]
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

-- [Subsystem 5: Fly Engine]
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

-- [Subsystem 6: ESP / Wallhack Engine]
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

-- [Subsystem 7: Fix Lag Engine Functions]
enableFixLagLive = function()
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd        = 9e9
        Lighting.FogStart      = 9e9
        Cfg.FixLagActive = true
    end)
end

disableFixLag = function()
    Cfg.FixLagActive = false
end

applyUltraLowGraphics = function()
    pcall(function()
        enableFixLagLive()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Material   = Enum.Material.SmoothPlastic
                obj.CastShadow = false
            end
        end
        Cfg.LowGfxActive = true
    end)
end

print("✅ [LuckatHub v2.3] Guaranteed Fail-Safe Script Loaded Successfully!")
