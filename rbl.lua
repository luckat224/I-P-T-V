-- ============================================================================
-- ⚡ LUCKATHUB VIP PRO - SIÊU CẤP THÔNG MINH EDITION (V18.5 MAX OPTIMIZED) ⚡
-- Tự Động Kích Hoạt Bypass Hủy Diệt 100% | Zero Lag | Zero Bounce | Max Anti-Hacker
-- ============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local lp = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Tàng hình giao diện tuyệt đối
local safeParent
if typeof(gethui) == "function" then
    safeParent = gethui()
else
    local ok, res = pcall(function() return CoreGui end)
    safeParent = (ok and res) and CoreGui or lp:WaitForChild("PlayerGui")
end

for _, v in ipairs(safeParent:GetChildren()) do
    if v:IsA("ScreenGui") and (v.Name == "LuckatHubMobileV11" or v:FindFirstChild("LHTag")) then
        pcall(function() v:Destroy() end)
    end
end

local C = {
    SpeedOn = false, Speed = 16,
    JumpOn = false, Jump = 50,
    Wallhack = false,
    HUDOn = false,
    FixLag = false,
    GarouV1On = false,
    SaitamaOn = false,
    GarouV2On = false,
    CyborgOn = false,
    NinjaOn = false,
    InvisibleOn = false,
    TrashCanOn = true,
    MetalBatOn = false,
    TatsumakiOn = false,
    SamuraiOn = false,
    ChildEmperorOn = false,
    ZombiemanOn = false,
    SuiryuOn = false,
    DeathCounterOn = true,
    AntiHackerOn = false
}

-- ScreenGui Setup (Sibling ZIndex & IgnoreGuiInset for Mobile Insets)
local gui = Instance.new("ScreenGui")
gui.Name = "LuckatHub_VIP_" .. tostring(math.random(10000, 99999))
local tag = Instance.new("BoolValue", gui)
tag.Name = "LHTag"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.Parent = safeParent

-- Design System Palette (Glassmorphism & Neon Mint/Cyan)
local C_BG = Color3.fromRGB(12, 14, 22)
local C_SIDE = Color3.fromRGB(18, 20, 30)
local C_TOP = Color3.fromRGB(24, 28, 42)
local C_ACCENT = Color3.fromRGB(0, 240, 160)
local C_ACCENT_ALT = Color3.fromRGB(0, 180, 255)
local C_TEXT = Color3.fromRGB(245, 248, 255)
local C_TEXT_DIM = Color3.fromRGB(140, 148, 170)
local C_CARD = Color3.fromRGB(22, 25, 38)
local C_STROKE = Color3.fromRGB(40, 48, 70)

-- Advanced Touch/Mouse Drag Engine with Tap Filter & Screen Clamping
local function makeDraggable(frame, handle, onClick)
    local dragging = false
    local dragStart, startPos
    local totalDelta = Vector2.zero

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            totalDelta = Vector2.zero
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            totalDelta = totalDelta + Vector2.new(math.abs(delta.X), math.abs(delta.Y))
            
            local vpSize = camera.ViewportSize
            local absSize = frame.AbsoluteSize
            
            local newXOffset = math.clamp(startPos.X.Offset + delta.X, -startPos.X.Scale * vpSize.X, (1 - startPos.X.Scale) * vpSize.X - absSize.X)
            local newYOffset = math.clamp(startPos.Y.Offset + delta.Y, -startPos.Y.Scale * vpSize.Y, (1 - startPos.Y.Scale) * vpSize.Y - absSize.Y)
            
            frame.Position = UDim2.new(startPos.X.Scale, newXOffset, startPos.Y.Scale, newYOffset)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
            if onClick and totalDelta.Magnitude < 8 then
                onClick()
            end
        end
    end)
end

-- Ergonomic Mobile Floating Button (52x52px)
local floatBtn = Instance.new("TextButton")
floatBtn.Size = UDim2.new(0, 52, 0, 52)
floatBtn.Position = UDim2.new(0, 18, 0.4, 0)
floatBtn.BackgroundColor3 = C_BG
floatBtn.BackgroundTransparency = 0.15
floatBtn.Text = "⚡"
floatBtn.TextColor3 = C_ACCENT
floatBtn.Font = Enum.Font.GothamBold
floatBtn.TextSize = 22
floatBtn.Parent = gui

Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1, 0)
local floatStroke = Instance.new("UIStroke", floatBtn)
floatStroke.Color = C_ACCENT
floatStroke.Thickness = 2
floatStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Responsive Main Frame
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 420, 0, 270)
main.Position = UDim2.new(0.5, -210, 0.5, -135)
main.BackgroundColor3 = C_BG
main.BackgroundTransparency = 0.1
main.BorderSizePixel = 0
main.Visible = false
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = C_STROKE
mainStroke.Thickness = 1.5

local sizeConstraint = Instance.new("UISizeConstraint", main)
sizeConstraint.MaxSize = Vector2.new(500, 320)
sizeConstraint.MinSize = Vector2.new(280, 200)

-- Header Bar
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = C_TOP
header.BorderSizePixel = 0
header.Parent = main
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

local hPatch = Instance.new("Frame")
hPatch.Size = UDim2.new(1, 0, 0, 12)
hPatch.Position = UDim2.new(0, 0, 1, -12)
hPatch.BackgroundColor3 = C_TOP
hPatch.BorderSizePixel = 0
hPatch.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -55, 1, 0)
title.Position = UDim2.new(0, 14, 0, 0)
title.BackgroundTransparency = 1
title.Text = "LUCKATHUB VIP PRO ⚡ SIÊU CẤP"
title.TextColor3 = C_ACCENT
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -36, 0.5, -16)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 90, 90)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.Parent = header

closeBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    floatBtn.Visible = true
end)

makeDraggable(floatBtn, floatBtn, function()
    main.Visible = not main.Visible
    floatBtn.Visible = not main.Visible
end)
makeDraggable(main, header)

-- Sidebar Navigation
local sidebar = Instance.new("ScrollingFrame")
sidebar.Size = UDim2.new(0, 115, 1, -40)
sidebar.Position = UDim2.new(0, 0, 0, 40)
sidebar.BackgroundColor3 = C_SIDE
sidebar.BorderSizePixel = 0
sidebar.ScrollBarThickness = 3
sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
sidebar.Parent = main

local sLayout = Instance.new("UIListLayout", sidebar)
sLayout.SortOrder = Enum.SortOrder.LayoutOrder
sLayout.Padding = UDim.new(0, 4)
local sPad = Instance.new("UIPadding", sidebar)
sPad.PaddingTop = UDim.new(0, 6)
sPad.PaddingLeft = UDim.new(0, 6)
sPad.PaddingRight = UDim.new(0, 6)

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -115, 1, -40)
content.Position = UDim2.new(0, 115, 0, 40)
content.BackgroundTransparency = 1
content.Parent = main

local tabs = {}
local tabBtns = {}

local function switchTab(name)
    for k, v in pairs(tabs) do v.Visible = (k == name) end
    for k, btn in pairs(tabBtns) do
        local active = (k == name)
        TweenService:Create(btn, TweenInfo.new(0.18), {
            BackgroundColor3 = active and C_ACCENT or C_SIDE,
            TextColor3 = active and Color3.fromRGB(10, 12, 18) or C_TEXT_DIM
        }):Play()
    end
end

local function makeTab(name, displayName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = C_SIDE
    btn.Text = displayName
    btn.TextColor3 = C_TEXT_DIM
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    btn.Parent = sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    tabBtns[name] = btn

    local sf = Instance.new("ScrollingFrame")
    sf.Size = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 5
    sf.ScrollBarImageColor3 = C_ACCENT
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.CanvasSize = UDim2.new(0, 0, 0, 0)
    sf.Visible = false
    sf.Parent = content
    
    local layout = Instance.new("UIListLayout", sf)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)
    
    local pad = Instance.new("UIPadding", sf)
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)
    pad.PaddingLeft = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 10)

    tabs[name] = sf
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
    return sf
end

local layoutOrder = 0
local function getOrder() layoutOrder = layoutOrder + 1 return layoutOrder end

local function addToggle(parent, titleText, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = C_CARD
    frame.LayoutOrder = getOrder()
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -65, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = titleText
    lbl.TextColor3 = C_TEXT
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextWrapped = true
    lbl.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 42, 0, 22)
    btn.Position = UDim2.new(1, -50, 0.5, -11)
    btn.BackgroundColor3 = default and C_ACCENT or Color3.fromRGB(45, 50, 68)
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Parent = btn
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(btn, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
            BackgroundColor3 = state and C_ACCENT or Color3.fromRGB(45, 50, 68)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
            Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        }):Play()
        pcall(callback, state)
    end)
end

local function addInput(parent, titleText, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = C_CARD
    frame.LayoutOrder = getOrder()
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -85, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = titleText
    lbl.TextColor3 = C_TEXT
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextWrapped = true
    lbl.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 55, 0, 24)
    box.Position = UDim2.new(1, -65, 0.5, -12)
    box.BackgroundColor3 = Color3.fromRGB(15, 18, 28)
    box.Text = tostring(default)
    box.TextColor3 = C_ACCENT
    box.Font = Enum.Font.GothamBold
    box.TextSize = 11
    box.Parent = frame
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)
    
    local boxStroke = Instance.new("UIStroke", box)
    boxStroke.Color = C_STROKE
    boxStroke.Thickness = 1

    box.Focused:Connect(function()
        TweenService:Create(boxStroke, TweenInfo.new(0.15), { Color = C_ACCENT }):Play()
    end)

    box.FocusLost:Connect(function()
        TweenService:Create(boxStroke, TweenInfo.new(0.15), { Color = C_STROKE }):Play()
        local n = tonumber(box.Text)
        if n then pcall(callback, n) else box.Text = tostring(default) end
    end)
end

local function addButton(parent, titleText, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = C_CARD
    btn.Text = titleText
    btn.TextColor3 = C_TEXT
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.LayoutOrder = getOrder()
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    btn.MouseButton1Click:Connect(function()
        pcall(callback)
        TweenService:Create(btn, TweenInfo.new(0.08), { BackgroundColor3 = C_ACCENT, TextColor3 = Color3.fromRGB(10, 12, 18) }):Play()
        task.wait(0.12)
        TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = C_CARD, TextColor3 = C_TEXT }):Play()
    end)
end

local function addTitle(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Text = "  " .. text:upper()
    lbl.TextColor3 = C_ACCENT_ALT
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = getOrder()
    lbl.Parent = parent
end

local T1 = makeTab("move", "Di Chuyển")
local T2 = makeTab("combat", "Tác Chiến")
local T_Dodge = makeTab("autododge", "Auto Dodge")
local T4 = makeTab("lag", "Fix Lag")

addTitle(T1, "TÀNG HÌNH & DI CHUYỂN")
addToggle(T1, "Anti Hacker Siêu Cấp", C.AntiHackerOn, function(v)
    C.AntiHackerOn = v
    if _G.LH_SetAntiHacker then _G.LH_SetAntiHacker(v) end
end)
addToggle(T1, "Cảnh Báo Death Counter", C.DeathCounterOn, function(v)
    C.DeathCounterOn = v
end)
addToggle(T1, "Tàng Hình Sky-Desync", C.InvisibleOn, function(v)
    C.InvisibleOn = v
    if _G.LH_SetInvisible then _G.LH_SetInvisible(v) end
end)
addToggle(T1, "Chạy Nhanh", C.SpeedOn, function(v) C.SpeedOn = v end)
addInput(T1, "Tốc Độ Chạy", C.Speed, function(v) C.Speed = tonumber(v) or 16 end)
addToggle(T1, "Nhảy Cao", C.JumpOn, function(v) C.JumpOn = v end)
addInput(T1, "Lực Nhảy", C.Jump, function(v) C.Jump = tonumber(v) or 50 end)

addTitle(T2, "CHIẾN ĐẤU & AIMBOT")
addToggle(T2, "Bật HUD Aimbot/Teleport", C.HUDOn, function(v)
    C.HUDOn = v
    if _G.LH_HUD then _G.LH_HUD(v) end
end)

addTitle(T_Dodge, "AUTO DODGE SYSTEM (SIÊU CẤP 360°)")
addToggle(T_Dodge, "Garou V1", C.GarouV1On, function(v) C.GarouV1On = v end)
addToggle(T_Dodge, "Saitama", C.SaitamaOn, function(v) C.SaitamaOn = v end)
addToggle(T_Dodge, "Garou V2", C.GarouV2On, function(v) C.GarouV2On = v end)
addToggle(T_Dodge, "Cyborg (Genos)", C.CyborgOn, function(v) C.CyborgOn = v end)
addToggle(T_Dodge, "Ninja (Sonic)", C.NinjaOn, function(v) C.NinjaOn = v end)
addToggle(T_Dodge, "Trash Can", C.TrashCanOn, function(v) C.TrashCanOn = v end)
addToggle(T_Dodge, "Metal Bat", C.MetalBatOn, function(v) C.MetalBatOn = v end)
addToggle(T_Dodge, "Tatsumaki", C.TatsumakiOn, function(v) C.TatsumakiOn = v end)
addToggle(T_Dodge, "Atomic Samurai", C.SamuraiOn, function(v) C.SamuraiOn = v end)
addToggle(T_Dodge, "Child Emperor", C.ChildEmperorOn, function(v) C.ChildEmperorOn = v end)
addToggle(T_Dodge, "Zombieman", C.ZombiemanOn, function(v) C.ZombiemanOn = v end)
addToggle(T_Dodge, "Suiryu", C.SuiryuOn, function(v) C.SuiryuOn = v end)

addTitle(T4, "TỐI ƯU PIN & BỘ NHỚ")
addButton(T4, "Bật Tối Ưu Chunking Budget", function() if _G.LH_lagOn then _G.LH_lagOn() end end)
addButton(T4, "Tắt Tối Ưu (Khôi Phục Gốc)", function() if _G.LH_lagOff then _G.LH_lagOff() end end)
addButton(T4, "Quét Rác Ký Ức (RAM Real Purge)", function()
    pcall(function()
        local memBefore = gcinfo()
        if charCache then
            for k, v in pairs(charCache) do
                if typeof(v) == "Instance" and not v.Parent then charCache[k] = nil end
            end
        end
        for i = 1, 3 do
            if typeof(collectgarbage) == "function" then collectgarbage("collect") end
        end
        local memAfter = gcinfo()
        local freed = math.max(0, memBefore - memAfter)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "DỌN RÁC HOÀN TẤT";
            Text = string.format("Đã giải phóng ~%d KB RAM. Bộ nhớ an toàn!", freed);
            Duration = 3;
        })
    end)
end)

switchTab("move")

-- ==================== ĐỘNG CƠ PHYSICS BAN ĐẦU ====================
local charCache = {}
local function getChar()
    charCache.char = lp.Character
    charCache.hum = charCache.char and charCache.char:FindFirstChildOfClass("Humanoid")
    charCache.hrp = charCache.char and charCache.char:FindFirstChild("HumanoidRootPart")
end
getChar()
lp.CharacterAdded:Connect(function() task.wait(0.2) getChar() end)

local playerControls
pcall(function()
    playerControls = require(lp.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
end)

RunService.Heartbeat:Connect(function(deltaTime)
    local hum, hrp = charCache.hum, charCache.hrp
    if not hrp or not hum or hum.Health <= 0 then return end
    
    if C.JumpOn then
        if not hum.UseJumpPower then hum.UseJumpPower = true end
        if hum.JumpPower ~= C.Jump then hum.JumpPower = C.Jump end
    end

    if not C.SpeedOn or not playerControls then return end
    
    local activeMove = playerControls:GetMoveVector()
    if activeMove.Magnitude < 0.05 then return end 
    
    local camLook = camera.CFrame.LookVector
    local camRight = camera.CFrame.RightVector
    local forward = Vector3.new(camLook.X, 0, camLook.Z).Unit
    local right = Vector3.new(camRight.X, 0, camRight.Z).Unit
    
    local worldMoveDir = (forward * -activeMove.Z) + (right * activeMove.X)
    if worldMoveDir.Magnitude > 0 then worldMoveDir = worldMoveDir.Unit end
    
    if hrp.Anchored then hrp.Anchored = false end
    if not hum.AutoRotate then hum.AutoRotate = true end
    
    local currentVel = hrp.AssemblyLinearVelocity
    local currentHorizSpeed = Vector3.new(currentVel.X, 0, currentVel.Z).Magnitude
    
    if currentHorizSpeed > C.Speed + 15 then return end
    
    hrp.AssemblyLinearVelocity = Vector3.new(worldMoveDir.X * C.Speed, currentVel.Y, worldMoveDir.Z * C.Speed)
    
    if hum.MoveDirection.Magnitude < 0.05 then
        local targetLook = hrp.Position + worldMoveDir
        hrp.CFrame = hrp.CFrame:Lerp(CFrame.lookAt(hrp.Position, targetLook), 0.15)
    end
end)

-- ===========================================================================
-- ⚡ UNIFIED SKILL DATABASE ARCHITECTURE (SIÊU CẤP THÔNG MINH) ⚡
-- ===========================================================================

local SkillCategory = {
    -- bodyHitRange = khoảng cách tối đa chiêu ĐÁNH TRÚNG BODY nhân vật
    -- trackRange  = khoảng cách theo dõi kẻ địch đang lướt/bắn tới
    M1          = { bodyHitRange = 10, trackRange = 25,  buffer = 0.3, minDodge = 0.6, height = 100 },
    Melee       = { bodyHitRange = 14, trackRange = 35,  buffer = 0.5, minDodge = 1.0, height = 100 },
    LungeDash   = { bodyHitRange = 16, trackRange = 80,  buffer = 0.8, minDodge = 1.2, height = 100, cone = 120 },
    BeamLine    = { bodyHitRange = 18, trackRange = 100, buffer = 1.2, minDodge = 1.5, height = 120, cone = 120 },
    WideAoE     = { bodyHitRange = 30, trackRange = 55,  buffer = 1.5, minDodge = 1.8, height = 150 },
    UltimateAoE = { bodyHitRange = 130, trackRange = 180, buffer = 3.5, minDodge = 2.5, height = 350 },
}

local SkillDatabase = {
    -- Saitama
    ["10466974800"] = { name = "Normal Punch",         hero = "Saitama", category = SkillCategory.Melee },
    ["13927612951"] = { name = "Shove",                hero = "Saitama", category = SkillCategory.Melee },
    ["10468665991"] = { name = "Uppercut",             hero = "Saitama", category = SkillCategory.Melee },
    ["10471336737"] = { name = "Consecutive Punches",  hero = "Saitama", category = SkillCategory.Melee, buffer = 1.5 },
    ["11365563255"] = { name = "Table Flip",           hero = "Saitama", category = SkillCategory.UltimateAoE },
    ["12983333733"] = { name = "Omni Punches",         hero = "Saitama", category = SkillCategory.UltimateAoE },
    ["12447707844"] = { name = "Serious Punch Ult",    hero = "Saitama", category = SkillCategory.UltimateAoE, isUlt = true },
    ["11343318134"] = { name = "Beatdown",             hero = "Saitama", category = SkillCategory.UltimateAoE, isBeatdown = true },
    ["12510170988"] = { name = "Death Counter",        hero = "Saitama", category = SkillCategory.Melee, isDeathCounter = true },
    ["12447226503"] = { name = "Table Flip Charge",    hero = "Saitama", category = SkillCategory.UltimateAoE },
    ["12447228807"] = { name = "Table Flip Slam",      hero = "Saitama", category = SkillCategory.UltimateAoE },
    ["12983416823"] = { name = "Omni Finisher",        hero = "Saitama", category = SkillCategory.UltimateAoE },

    -- Garou V1
    ["12272894215"] = { name = "Flowing Water",        hero = "GarouV1", category = SkillCategory.Melee },
    ["12307656616"] = { name = "Lethal Whirlwind",     hero = "GarouV1", category = SkillCategory.WideAoE },
    ["12296882427"] = { name = "Hunter's Grasp",       hero = "GarouV1", category = SkillCategory.LungeDash },
    ["13603396939"] = { name = "Prey's Peril",         hero = "GarouV1", category = SkillCategory.LungeDash },
    ["13630786846"] = { name = "Garou V1 Skill 5",     hero = "GarouV1", category = SkillCategory.Melee },
    ["14057231976"] = { name = "Garou V1 Skill 6",     hero = "GarouV1", category = SkillCategory.Melee },
    ["12463072679"] = { name = "Garou V1 Skill 7",     hero = "GarouV1", category = SkillCategory.LungeDash },
    ["12460977270"] = { name = "Garou V1 Skill 8",     hero = "GarouV1", category = SkillCategory.Melee },
    ["12342141464"] = { name = "Garou V1 Skill 9",     hero = "GarouV1", category = SkillCategory.Melee },

    -- Garou V2
    ["109617620932970"] = { name = "Garou V2 Skill 1", hero = "GarouV2", category = SkillCategory.LungeDash },
    ["125955606488863"] = { name = "Garou V2 Skill 2", hero = "GarouV2", category = SkillCategory.Melee },
    ["72533960079559"]  = { name = "Garou V2 Skill 3", hero = "GarouV2", category = SkillCategory.LungeDash },
    ["102989537449083"] = { name = "Garou V2 Skill 4", hero = "GarouV2", category = SkillCategory.Melee },
    ["131820095363270"] = { name = "Garou V2 Table Flip", hero = "GarouV2", category = SkillCategory.UltimateAoE },
    ["85025226664507"]  = { name = "Garou V2 Skill 6", hero = "GarouV2", category = SkillCategory.Melee },
    ["71317401437256"]  = { name = "Garou V2 Skill 7", hero = "GarouV2", category = SkillCategory.LungeDash },
    ["136465810903839"] = { name = "Garou V2 Skill 8", hero = "GarouV2", category = SkillCategory.WideAoE },
    ["107484339495811"] = { name = "Garou V2 Skill 9", hero = "GarouV2", category = SkillCategory.Melee },
    ["79527508933159"]  = { name = "Garou V2 Skill 10",hero = "GarouV2", category = SkillCategory.Melee },
    ["139070970861356"] = { name = "Garou V2 Skill 11",hero = "GarouV2", category = SkillCategory.LungeDash },

    -- Cyborg (Genos)
    ["12534735382"] = { name = "Machine Gun Blows",   hero = "Cyborg",  category = SkillCategory.Melee, buffer = 1.2 },
    ["12502664044"] = { name = "Genos Dash",          hero = "Cyborg",  category = SkillCategory.LungeDash },
    ["12509505723"] = { name = "Genos Skill 3",       hero = "Cyborg",  category = SkillCategory.BeamLine },
    ["12684185971"] = { name = "Genos Skill 4",       hero = "Cyborg",  category = SkillCategory.Melee },
    ["12618271998"] = { name = "Incinerate",          hero = "Cyborg",  category = SkillCategory.BeamLine },
    ["12618292188"] = { name = "Genos Skill 6",       hero = "Cyborg",  category = SkillCategory.BeamLine },
    ["14721837245"] = { name = "Genos Skill 7",       hero = "Cyborg",  category = SkillCategory.WideAoE },
    ["12832505612"] = { name = "Genos Skill 8",       hero = "Cyborg",  category = SkillCategory.Melee },
    ["13083332742"] = { name = "Genos Skill 9",       hero = "Cyborg",  category = SkillCategory.LungeDash },
    ["13146710762"] = { name = "Max Incinerate Ult",  hero = "Cyborg",  category = SkillCategory.UltimateAoE },

    -- Ninja (Sonic)
    ["13376869471"] = { name = "Flash Strike",        hero = "Ninja",   category = SkillCategory.LungeDash },
    ["13294790250"] = { name = "Ninja Skill 2",       hero = "Ninja",   category = SkillCategory.Melee },
    ["13501296372"] = { name = "Ninja Skill 3",       hero = "Ninja",   category = SkillCategory.LungeDash },
    ["13365849295"] = { name = "Ninja Skill 4",       hero = "Ninja",   category = SkillCategory.Melee },
    ["13632347366"] = { name = "Ninja Skill 5",       hero = "Ninja",   category = SkillCategory.LungeDash },
    ["13643152947"] = { name = "Ninja Skill 6",       hero = "Ninja",   category = SkillCategory.Melee },
    ["13634395775"] = { name = "Ninja Skill 7",       hero = "Ninja",   category = SkillCategory.LungeDash },
    ["13723174078"] = { name = "Ninja Skill 8",       hero = "Ninja",   category = SkillCategory.WideAoE },
    ["13639700348"] = { name = "Ninja Skill 9",       hero = "Ninja",   category = SkillCategory.Melee },
    ["13876406148"] = { name = "Dragon Placement",    hero = "Ninja",   category = SkillCategory.LungeDash },

    -- Trash Can
    ["13813955149"] = { name = "Trash Can Slam",      hero = "TrashCan",category = SkillCategory.Melee },

    -- Metal Bat
    ["14004235777"] = { name = "Homerun",             hero = "MetalBat",category = SkillCategory.Melee },
    ["14357943487"] = { name = "Foul Ball",           hero = "MetalBat",category = SkillCategory.BeamLine },
    ["14003607057"] = { name = "Metal Bat Skill 3",   hero = "MetalBat",category = SkillCategory.Melee },
    ["14048349132"] = { name = "Metal Bat Skill 4",   hero = "MetalBat",category = SkillCategory.Melee },
    ["14046756619"] = { name = "Metal Bat Skill 5",   hero = "MetalBat",category = SkillCategory.LungeDash },
    ["14299135500"] = { name = "Metal Bat Skill 6",   hero = "MetalBat",category = SkillCategory.Melee },
    ["14967219354"] = { name = "Metal Bat Skill 7",   hero = "MetalBat",category = SkillCategory.Melee },
    ["14351441234"] = { name = "Metal Bat Skill 8",   hero = "MetalBat",category = SkillCategory.LungeDash },
    ["14733282425"] = { name = "Metal Bat Skill 9",   hero = "MetalBat",category = SkillCategory.Melee },
    ["14719290328"] = { name = "Metal Bat Skill 10",  hero = "MetalBat",category = SkillCategory.Melee },
    ["14701242661"] = { name = "Metal Bat Skill 11",  hero = "MetalBat",category = SkillCategory.WideAoE },
    ["14900168720"] = { name = "Metal Bat Skill 12",  hero = "MetalBat",category = SkillCategory.Melee },
    ["15128849047"] = { name = "Metal Bat Skill 13",  hero = "MetalBat",category = SkillCategory.Melee },
    ["15134211820"] = { name = "Metal Bat Skill 14",  hero = "MetalBat",category = SkillCategory.WideAoE },
    ["14389973809"] = { name = "Savage Tornado Ult",  hero = "MetalBat",category = SkillCategory.UltimateAoE },

    -- Tatsumaki
    ["16139108718"] = { name = "Tatsumaki Skill 1",   hero = "Tatsumaki",category = SkillCategory.Melee },
    ["16139402582"] = { name = "Tatsumaki Skill 2",   hero = "Tatsumaki",category = SkillCategory.WideAoE },
    ["16515850153"] = { name = "Tatsumaki Skill 3",   hero = "Tatsumaki",category = SkillCategory.BeamLine },
    ["16431491215"] = { name = "Tatsumaki Skill 4",   hero = "Tatsumaki",category = SkillCategory.Melee },
    ["16597322398"] = { name = "Tatsumaki Skill 5",   hero = "Tatsumaki",category = SkillCategory.WideAoE },
    ["16734584478"] = { name = "Tatsumaki Skill 6",   hero = "Tatsumaki",category = SkillCategory.BeamLine },
    ["16737255386"] = { name = "Tatsumaki Skill 7",   hero = "Tatsumaki",category = SkillCategory.Melee },
    ["17275795209"] = { name = "Tatsumaki Skill 8",   hero = "Tatsumaki",category = SkillCategory.WideAoE },
    ["17275150809"] = { name = "Tatsumaki Skill 9",   hero = "Tatsumaki",category = SkillCategory.Melee },
    ["17450393107"] = { name = "Tatsumaki Skill 10",  hero = "Tatsumaki",category = SkillCategory.BeamLine },
    ["17860467628"] = { name = "Meteor Strike Real",  hero = "Tatsumaki",category = SkillCategory.UltimateAoE },
    ["17464644182"] = { name = "Tatsumaki Skill 12",  hero = "Tatsumaki",category = SkillCategory.WideAoE },
    ["16918808605"] = { name = "Meteor Strike",       hero = "Tatsumaki",category = SkillCategory.UltimateAoE },
    ["16918865210"] = { name = "Tornado Surge",       hero = "Tatsumaki",category = SkillCategory.UltimateAoE },
    ["16918910022"] = { name = "Psychic Crush",       hero = "Tatsumaki",category = SkillCategory.UltimateAoE },
    ["16918955110"] = { name = "Earth Shatter",       hero = "Tatsumaki",category = SkillCategory.UltimateAoE },

    -- Atomic Samurai
    ["15290930205"] = { name = "Samurai Skill 1",     hero = "Samurai", category = SkillCategory.Melee },
    ["15145462680"] = { name = "Samurai Skill 2",     hero = "Samurai", category = SkillCategory.LungeDash },
    ["15295895753"] = { name = "Samurai Skill 3",     hero = "Samurai", category = SkillCategory.Melee },
    ["15271263467"] = { name = "Samurai Skill 4",     hero = "Samurai", category = SkillCategory.Melee },
    ["15311685628"] = { name = "Samurai Skill 5",     hero = "Samurai", category = SkillCategory.LungeDash },
    ["15391323441"] = { name = "Samurai Skill 6",     hero = "Samurai", category = SkillCategory.Melee },
    ["15520132233"] = { name = "Samurai Skill 7",     hero = "Samurai", category = SkillCategory.Melee },
    ["15676072469"] = { name = "Samurai Skill 8",     hero = "Samurai", category = SkillCategory.WideAoE },
    ["16062410809"] = { name = "Samurai Skill 9",     hero = "Samurai", category = SkillCategory.Melee },
    ["16082123712"] = { name = "Samurai Skill 10",    hero = "Samurai", category = SkillCategory.Melee },
    ["15260195500"] = { name = "Atomic Slash Ult",    hero = "Samurai", category = SkillCategory.UltimateAoE },
    ["15260241120"] = { name = "Sunrise Blade Ult",   hero = "Samurai", category = SkillCategory.UltimateAoE },

    -- Child Emperor
    ["113166426814229"] = { name = "Child Emperor 1", hero = "ChildEmperor", category = SkillCategory.Melee },
    ["114095570398448"] = { name = "Child Emperor 2", hero = "ChildEmperor", category = SkillCategory.Melee },
    ["116153572280464"] = { name = "Child Emperor 3", hero = "ChildEmperor", category = SkillCategory.LungeDash },
    ["116753755471636"] = { name = "Child Emperor 4", hero = "ChildEmperor", category = SkillCategory.Melee },
    ["138932866508108"] = { name = "Child Emperor 5", hero = "ChildEmperor", category = SkillCategory.BeamLine },
    ["77509627104305"]  = { name = "Child Emperor 6", hero = "ChildEmperor", category = SkillCategory.Melee },
    ["98542310119798"]  = { name = "Child Emperor 7", hero = "ChildEmperor", category = SkillCategory.Melee },
    ["96558273957850"]  = { name = "Child Emperor 8", hero = "ChildEmperor", category = SkillCategory.Melee },
    ["100059874351664"] = { name = "Child Emperor 9", hero = "ChildEmperor", category = SkillCategory.WideAoE },
    ["91353107056596"]  = { name = "Child Emperor 10",hero = "ChildEmperor", category = SkillCategory.Melee },
    ["123005629431309"] = { name = "Child Emperor 11",hero = "ChildEmperor", category = SkillCategory.Melee },
    ["71852503410610"]  = { name = "Child Emperor 12",hero = "ChildEmperor", category = SkillCategory.BeamLine },
    ["105616370132258"] = { name = "Mech Beam Ult",   hero = "ChildEmperor", category = SkillCategory.UltimateAoE },
    ["17950189000"]     = { name = "Mech Beam Legacy",hero = "ChildEmperor", category = SkillCategory.UltimateAoE },

    -- Zombieman
    ["18240019200"] = { name = "Zombieman 1",         hero = "Zombieman", category = SkillCategory.Melee },
    ["18240089110"] = { name = "Zombieman 2",         hero = "Zombieman", category = SkillCategory.Melee },
    ["18240160220"] = { name = "Zombieman 3",         hero = "Zombieman", category = SkillCategory.BeamLine },
    ["18240230011"] = { name = "Zombieman 4",         hero = "Zombieman", category = SkillCategory.Melee },
    ["18350290011"] = { name = "Zombieman 5",         hero = "Zombieman", category = SkillCategory.LungeDash },
    ["18350345022"] = { name = "Zombieman 6",         hero = "Zombieman", category = SkillCategory.Melee },
    ["18350390011"] = { name = "Zombieman 7",         hero = "Zombieman", category = SkillCategory.Melee },
    ["18350435099"] = { name = "Zombieman 8",         hero = "Zombieman", category = SkillCategory.WideAoE },

    -- Suiryu
    ["17799224866"]     = { name = "Suiryu Skill 1",   hero = "Suiryu", category = SkillCategory.Melee },
    ["17838006839"]     = { name = "Suiryu Skill 2",   hero = "Suiryu", category = SkillCategory.LungeDash },
    ["17857880283"]     = { name = "Suiryu Skill 3",   hero = "Suiryu", category = SkillCategory.Melee },
    ["17857788598"]     = { name = "Suiryu Skill 4",   hero = "Suiryu", category = SkillCategory.Melee },
    ["18179181663"]     = { name = "Suiryu Skill 5",   hero = "Suiryu", category = SkillCategory.LungeDash },
    ["18435383478"]     = { name = "Suiryu Skill 6",   hero = "Suiryu", category = SkillCategory.Melee },
    ["18435535291"]     = { name = "Suiryu Skill 7",   hero = "Suiryu", category = SkillCategory.WideAoE },
    ["129651400898906"] = { name = "Suiryu Skill 8",   hero = "Suiryu", category = SkillCategory.Melee },
    ["18896232119"]     = { name = "Suiryu Skill 9",   hero = "Suiryu", category = SkillCategory.LungeDash },
    ["18896229321"]     = { name = "Suiryu Skill 10",  hero = "Suiryu", category = SkillCategory.Melee },
    ["18897119503"]     = { name = "Suiryu Skill 11",  hero = "Suiryu", category = SkillCategory.Melee },
    ["106755459092436"] = { name = "Suiryu Skill 12",  hero = "Suiryu", category = SkillCategory.LungeDash },
    ["132259592388175"] = { name = "Suiryu Skill 13",  hero = "Suiryu", category = SkillCategory.WideAoE },
    ["95575238948327"]  = { name = "Suiryu Skill 14",  hero = "Suiryu", category = SkillCategory.Melee },
    ["102814369422840"] = { name = "Suiryu Skill 15",  hero = "Suiryu", category = SkillCategory.Melee },
    ["16089102000"]     = { name = "Void Tremor Ult",  hero = "Suiryu", category = SkillCategory.UltimateAoE },
}

-- Populate 44 M1 Skills
local M1List = {
    "10469493270", "10469630950", "10469639222", "10469643643",
    "12273188754", "12273208740", "12273216350", "12273226279",
    "10961750011", "10961765022", "10961780011", "10961795022",
    "12509359810", "12509372990", "12509386400", "12509400270",
    "13370310931", "13370323320", "13370335800", "13370348700",
    "14028357321", "14028369011", "14028381200", "14028393500",
    "15162450120", "15162462340", "15162475010", "15162488020",
    "15978290011", "15978305022", "15978320011", "15978335022",
    "16782350011", "16782365022", "16782380011", "16782395022",
    "17835010011", "17835025022", "17835040011", "17835055022",
    "18240010011", "18240025022", "18240040011", "18240055022",
}
for _, id in ipairs(M1List) do
    SkillDatabase[id] = { name = "M1 Strike", hero = "AllM1", category = SkillCategory.M1 }
end

local SAFE_ZONE_RADIUS = 15
local TELEPORT_HEIGHT = 100
local GHOST_TRANSPARENCY = 0.4
local activeDodgeHeight = TELEPORT_HEIGHT

local isDodging = false
local fakePlatform = nil
local activeGhostModel = nil
local dodgeSavedCFrame = nil
local cancelDodgeSignal = false
local dodgeQueue = {}

local dodgeLocalChar, dodgeLocalHrp, dodgeLocalHum
local function updateDodgeLocalChar()
    dodgeLocalChar = lp.Character
    dodgeLocalHrp = dodgeLocalChar and dodgeLocalChar:FindFirstChild("HumanoidRootPart")
    dodgeLocalHum = dodgeLocalChar and dodgeLocalChar:FindFirstChildOfClass("Humanoid")
end
updateDodgeLocalChar()
lp.CharacterAdded:Connect(updateDodgeLocalChar)

-- ⚡ BODY-PROXIMITY THREAT ENGINE (SIÊU CẤP VIP PRO) ⚡
-- Chỉ né khi chiêu SẮP ĐÁNH DÍNH VÀO BODY nhân vật
local function evaluateSkillThreat(rawId, enemyHrp, localHrp)
    local skill = SkillDatabase[rawId]

    -- Vị trí thực tế của body người chơi (dùng vị trí mặt đất nếu đang bay né)
    local localPos = (isDodging and dodgeSavedCFrame) and dodgeSavedCFrame.Position or localHrp.Position
    local relPos = localPos - enemyHrp.Position
    local dist2D = math.sqrt(relPos.X * relPos.X + relPos.Z * relPos.Z)
    local deltaY = math.abs(relPos.Y)

    -- Skill chưa đăng ký trong database: chỉ né khi body cực gần (<=12 studs)
    if not skill then
        local isBodyHit = dist2D <= 12 and deltaY <= 30
        local isTrackable = not isBodyHit and dist2D <= 50 and deltaY <= 50
        return isBodyHit, 12, 0.5, 100, 1.0, isTrackable
    end

    local cat = skill.category
    local buffer = skill.buffer or cat.buffer
    local height = skill.height or cat.height
    local minDodge = skill.minDodge or cat.minDodge
    local bodyHitRange = cat.bodyHitRange
    local trackRange = cat.trackRange

    -- Lọc theo chiều dọc: bỏ qua nếu kẻ địch ở tầng hoàn toàn khác
    local maxVerticalThreshold = (cat == SkillCategory.UltimateAoE) and 300 or math.max(40, height * 0.5)
    if deltaY > maxVerticalThreshold then
        return false, bodyHitRange, buffer, height, minDodge, false
    end

    -- Cone check cho chiêu có hướng (BeamLine): bỏ qua nếu kẻ địch KHÔNG nhắm vào mình
    if cat.cone and cat.cone < 360 and dist2D > bodyHitRange * 0.6 then
        local flatRel = Vector3.new(relPos.X, 0, relPos.Z)
        local lv = enemyHrp.CFrame.LookVector
        local flatEnemyLook = Vector3.new(lv.X, 0, lv.Z)
        if flatRel.Magnitude > 0.001 and flatEnemyLook.Magnitude > 0.001 then
            local dot = flatEnemyLook.Unit:Dot(flatRel.Unit)
            if dot < math.cos(math.rad(cat.cone / 2)) then
                return false, bodyHitRange, buffer, height, minDodge, false
            end
        end
    end

    -- ⚡ BODY-HIT DETECTION: Chỉ né khi kẻ địch ở trong phạm vi đánh trúng body
    local isBodyHit = dist2D <= bodyHitRange

    -- Tracking: Nếu chưa đánh trúng body nhưng kẻ địch đang trong tầm theo dõi
    local shouldTrack = false
    if not isBodyHit and dist2D <= trackRange then
        shouldTrack = true
    end

    return isBodyHit, bodyHitRange, buffer, height, minDodge, shouldTrack
end

-- HÀM HẠ CÁCH AN TOÀN SIÊU MƯỢT - TRIỆT TIÊU 100% HIỆU ỨNG BUMP/CHÌM ĐẤT/HẠ CÁNH SÀN ẢO
local function safeLandCharacter(heightOffset, savedCFrame)
    if not dodgeLocalChar or not dodgeLocalHrp or not dodgeLocalHum or dodgeLocalHum.Health <= 0 then return end

    if fakePlatform then pcall(function() fakePlatform.CanCollide = false fakePlatform:Destroy() end) fakePlatform = nil end
    if invisFakePlatform then pcall(function() invisFakePlatform.CanCollide = false invisFakePlatform:Destroy() end) invisFakePlatform = nil end

    local currentPos = dodgeLocalHrp.Position
    local targetX, targetZ = currentPos.X, currentPos.Z
    local expectedY = savedCFrame and savedCFrame.Position.Y or (currentPos.Y - (heightOffset or activeDodgeHeight or 500))

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.RespectCanCollide = true

    local filterList = {dodgeLocalChar}
    if activeGhostModel then table.insert(filterList, activeGhostModel) end
    if invisGhostModel then table.insert(filterList, invisGhostModel) end

    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("BasePart") and (obj.Name:find("Platform") or obj.Name:find("Ghost") or obj.Name:find("LocalDodgeGhost")) then
            table.insert(filterList, obj)
        end
    end
    raycastParams.FilterDescendantsInstances = filterList

    local rayHeightOrigin = math.max(expectedY + 100, currentPos.Y)
    local rayDistance = math.max(rayHeightOrigin - (expectedY - 100), 300)

    local offsets = {
        Vector3.new(0, 0, 0), Vector3.new(1.5, 0, 0), Vector3.new(-1.5, 0, 0),
        Vector3.new(0, 0, 1.5), Vector3.new(0, 0, -1.5)
    }

    local highestGroundY = nil
    for _, offset in ipairs(offsets) do
        local origin = Vector3.new(targetX + offset.X, rayHeightOrigin, targetZ + offset.Z)
        local result = Workspace:Raycast(origin, Vector3.new(0, -rayDistance, 0), raycastParams)
        if result then
            if not highestGroundY or result.Position.Y > highestGroundY then
                highestGroundY = result.Position.Y
            end
        end
    end

    local legOffset = 3.0
    if dodgeLocalHum.RigType == Enum.HumanoidRigType.R15 then
        legOffset = dodgeLocalHum.HipHeight + (dodgeLocalHrp.Size.Y / 2)
    else
        legOffset = (dodgeLocalHum.HipHeight > 0) and (dodgeLocalHum.HipHeight + 1) or 3.0
    end

    local finalY = highestGroundY and (highestGroundY + legOffset) or expectedY
    local finalCFrame = CFrame.new(targetX, finalY, targetZ) * dodgeLocalHrp.CFrame.Rotation

    -- Khóa physics tức thì → Gán CFrame chính xác → Triệt tiêu quán tính → Nhả ra ngay trong cùng frame
    dodgeLocalHrp.Anchored = true
    dodgeLocalHrp.CFrame = finalCFrame
    dodgeLocalHrp.AssemblyLinearVelocity = Vector3.zero
    dodgeLocalHrp.AssemblyAngularVelocity = Vector3.zero
    dodgeLocalHrp.Anchored = false

    dodgeLocalHum:ChangeState(Enum.HumanoidStateType.Running)
end

-- Notification Queue System for Serious Punch Ult
local ultNotifyContainer = nil
local function showUltNotification(ownerChar)
    pcall(function()
        local sg = safeParent:FindFirstChild("SaitamaUltNotifyGui")
        if not sg then
            sg = Instance.new("ScreenGui")
            sg.Name = "SaitamaUltNotifyGui"
            sg.ResetOnSpawn = false
            sg.Parent = safeParent
        end

        if not ultNotifyContainer then
            ultNotifyContainer = Instance.new("Frame")
            ultNotifyContainer.Size = UDim2.new(0, 260, 0.5, 0)
            ultNotifyContainer.Position = UDim2.new(1, -270, 0.25, 0)
            ultNotifyContainer.BackgroundTransparency = 1
            ultNotifyContainer.Parent = sg

            local layout = Instance.new("UIListLayout", ultNotifyContainer)
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.Padding = UDim.new(0, 6)
        end

        local plr = Players:GetPlayerFromCharacter(ownerChar)
        local pName = plr and (plr.DisplayName .. " (@" .. plr.Name .. ")") or ownerChar.Name
        pName = string.gsub(pName, "[<>&]", "") -- Sanitize RichText inputs
        local userId = plr and plr.UserId or 1

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 50)
        frame.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
        frame.BorderSizePixel = 0
        frame.Parent = ultNotifyContainer

        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
        local stroke = Instance.new("UIStroke", frame)
        stroke.Color = Color3.fromRGB(0, 180, 255)
        stroke.Thickness = 1.5

        local avatarImg = Instance.new("ImageLabel")
        avatarImg.Size = UDim2.new(0, 38, 0, 38)
        avatarImg.Position = UDim2.new(0, 6, 0.5, -19)
        avatarImg.BackgroundTransparency = 1
        avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(userId) .. "&w=150&h=150"
        avatarImg.Parent = frame
        Instance.new("UICorner", avatarImg).CornerRadius = UDim.new(1, 0)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -52, 1, 0)
        label.Position = UDim2.new(0, 50, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = string.format("⚡ <b>%s</b>\n<font color='#00FFCC'>ĐÃ MỞ ULTI SAITAMA!</font>", pName)
        label.RichText = true
        label.TextColor3 = Color3.fromRGB(240, 240, 240)
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame

        task.delay(4.5, function()
            if frame and frame.Parent then
                TweenService:Create(frame, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
                task.wait(0.3)
                frame:Destroy()
            end
        end)
    end)
end

-- Special Beatdown Sky-Dodge Core (Dành riêng cho Beatdown ID 11343318134 / 11343354388)
local beatdownRunning = false
local function handleSaitamaBeatdownEscape(enemyChar)
    if beatdownRunning then return end
    beatdownRunning = true

    if not dodgeLocalHrp then updateDodgeLocalChar() end
    if not dodgeLocalHrp or not dodgeLocalHum or dodgeLocalHum.Health <= 0 then 
        beatdownRunning = false 
        return 
    end

    local BEATDOWN_ESCAPE_HEIGHT = 5000
    local currentCFrame = dodgeLocalHrp.CFrame

    local platform = Instance.new("Part")
    platform.Name = "BeatdownEscapePlatform"
    platform.Size = Vector3.new(100, 5, 100)
    platform.CFrame = currentCFrame + Vector3.new(0, BEATDOWN_ESCAPE_HEIGHT - 3.5, 0)
    platform.Anchored = true
    platform.Transparency = 1
    platform.CanCollide = true
    platform.Parent = Workspace

    dodgeLocalHrp.CFrame = currentCFrame + Vector3.new(0, BEATDOWN_ESCAPE_HEIGHT, 0)
    dodgeLocalHrp.AssemblyLinearVelocity = Vector3.zero
    dodgeLocalHrp.AssemblyAngularVelocity = Vector3.zero

    task.delay(3, function()
        pcall(function()
            if platform and platform.Parent then platform:Destroy() end
            if dodgeLocalHrp and dodgeLocalHrp.Parent and dodgeLocalHum and dodgeLocalHum.Health > 0 then
                safeLandCharacter(BEATDOWN_ESCAPE_HEIGHT, currentCFrame)
            end
        end)
        beatdownRunning = false
    end)
end

-- Direct Dual-Array Structural Ghost Generator with Attribute Part Mapping
local function destroyGhostModel(ghostModel)
    if not ghostModel then return end
    pcall(function()
        for _, desc in ipairs(ghostModel:GetDescendants()) do
            if desc:IsA("Highlight") then
                desc.Enabled = false
                desc.Adornee = nil
                desc:Destroy()
            end
        end
        ghostModel:Destroy()
    end)
end

local function createGhostClone(char)
    if not char then return nil, {}, {} end
    
    local realDescendants = char:GetDescendants()
    local realMap = {}
    for i = 1, #realDescendants do
        local realObj = realDescendants[i]
        realObj:SetAttribute("_GhostID", i)
        realMap[i] = realObj
    end

    char.Archivable = true
    local ok, clone = pcall(function() return char:Clone() end)
    char.Archivable = false

    for i = 1, #realDescendants do
        realDescendants[i]:SetAttribute("_GhostID", nil)
    end

    if not ok or not clone then return nil, {}, {} end

    local realParts = {}
    local ghostParts = {}
    local cloneDescendants = clone:GetDescendants()

    for i = 1, #cloneDescendants do
        local obj = cloneDescendants[i]
        local id = obj:GetAttribute("_GhostID")
        local realObj = id and realMap[id]
        if id then obj:SetAttribute("_GhostID", nil) end

        if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("Animator") 
           or obj:IsA("ParticleEmitter") or obj:IsA("Trail") 
           or obj:IsA("Beam") or obj:IsA("Sound") or obj:IsA("Light") 
           or obj:IsA("Highlight") or obj:IsA("GuiObject") or obj:IsA("LayerCollector") then
            obj:Destroy()
        elseif obj:IsA("Humanoid") then
            obj.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            obj.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
        elseif obj:IsA("BasePart") then
            obj.CanCollide = false
            obj.CanTouch = false
            obj.CanQuery = false
            obj.Anchored = true
            obj.CastShadow = false
            obj.Massless = true
            
            if obj.Name == "HumanoidRootPart" or (realObj and realObj:IsA("BasePart") and realObj.Transparency >= 1) then
                obj.Transparency = 1
            else
                local baseTrans = (realObj and realObj:IsA("BasePart")) and realObj.Transparency or 0
                obj.Transparency = math.max(baseTrans, GHOST_TRANSPARENCY)
            end

            if obj.Material == Enum.Material.ForceField then
                obj.Material = Enum.Material.SmoothPlastic
            end

            if realObj and realObj:IsA("BasePart") then
                table.insert(realParts, realObj)
                table.insert(ghostParts, obj)
            end
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            local baseTrans = (realObj and (realObj:IsA("Decal") or realObj:IsA("Texture"))) and realObj.Transparency or 0
            if baseTrans >= 1 then
                obj.Transparency = 1
            else
                obj.Transparency = math.max(baseTrans, GHOST_TRANSPARENCY)
            end
        end
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "GhostHighlight"
    highlight.FillColor = Color3.fromRGB(0, 200, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0.1
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = clone

    clone.Name = "LocalDodgeGhost"
    clone.Parent = Workspace

    return clone, realParts, ghostParts
end

-- Dynamic Invisibility Engine 2.0 (Ultra-Clean Ground Sync)
local INVIS_HEIGHT = 500
local invisFakePlatform = nil
local invisGhostModel = nil
local invisRealParts = nil
local invisGhostParts = nil
local invisSavedCFrame = nil

_G.LH_SetInvisible = function(enable)
    C.InvisibleOn = enable
    if enable then
        if not dodgeLocalHrp or not dodgeLocalHum or dodgeLocalHum.Health <= 0 then 
            updateDodgeLocalChar() 
        end
        if not dodgeLocalHrp or not dodgeLocalHum or dodgeLocalHum.Health <= 0 then return end

        pcall(function() RunService:UnbindFromRenderStep("InvisCamAndGhostSync") end)
        if invisFakePlatform then pcall(function() invisFakePlatform:Destroy() end) invisFakePlatform = nil end
        if invisGhostModel then destroyGhostModel(invisGhostModel) invisGhostModel = nil end

        invisSavedCFrame = dodgeLocalHrp.CFrame

        local legOffset = 3.0
        if dodgeLocalHum then
            if dodgeLocalHum.RigType == Enum.HumanoidRigType.R15 then
                legOffset = dodgeLocalHum.HipHeight + (dodgeLocalHrp.Size.Y / 2)
            else
                legOffset = dodgeLocalHum.HipHeight > 0 and (dodgeLocalHum.HipHeight + 1) or 3.0
            end
        end

        invisFakePlatform = Instance.new("Part")
        invisFakePlatform.Name = "InvisAirPlatform"
        invisFakePlatform.Size = Vector3.new(4000, 10, 4000)
        invisFakePlatform.Position = Vector3.new(invisSavedCFrame.Position.X, invisSavedCFrame.Position.Y + INVIS_HEIGHT - legOffset - 5, invisSavedCFrame.Position.Z)
        invisFakePlatform.Anchored = true
        invisFakePlatform.Transparency = 1
        invisFakePlatform.CanCollide = true
        invisFakePlatform.CanTouch = false
        invisFakePlatform.CanQuery = false
        invisFakePlatform.Parent = Workspace

        local ghostModel, rParts, gParts = createGhostClone(dodgeLocalChar)
        invisGhostModel = ghostModel
        invisRealParts = rParts
        invisGhostParts = gParts

        dodgeLocalHrp.CFrame = invisSavedCFrame + Vector3.new(0, INVIS_HEIGHT, 0)
        dodgeLocalHrp.AssemblyLinearVelocity = Vector3.zero
        dodgeLocalHrp.AssemblyAngularVelocity = Vector3.zero

        local heightOffsetVec = Vector3.new(0, INVIS_HEIGHT, 0)
        camera.CFrame = camera.CFrame - heightOffsetVec

        local targetY = invisSavedCFrame.Position.Y + INVIS_HEIGHT
        local partCount = #invisGhostParts
        local CAM_PRIORITY = Enum.RenderPriority.Camera.Value + 1

        RunService:BindToRenderStep("InvisCamAndGhostSync", CAM_PRIORITY, function()
            if not C.InvisibleOn or not dodgeLocalHrp or not dodgeLocalHrp.Parent or not dodgeLocalHum or dodgeLocalHum.Health <= 0 then
                pcall(function() RunService:UnbindFromRenderStep("InvisCamAndGhostSync") end)
                return
            end

            local currentPos = dodgeLocalHrp.Position
            if invisFakePlatform and invisFakePlatform.Parent then
                invisFakePlatform.Position = Vector3.new(currentPos.X, targetY - legOffset - 5, currentPos.Z)
            end

            if currentPos.Y < targetY - 4 then
                dodgeLocalHrp.CFrame = CFrame.new(currentPos.X, targetY, currentPos.Z) * dodgeLocalHrp.CFrame.Rotation
                dodgeLocalHrp.AssemblyLinearVelocity = Vector3.new(dodgeLocalHrp.AssemblyLinearVelocity.X, 0, dodgeLocalHrp.AssemblyLinearVelocity.Z)
            end

            camera.CFrame = camera.CFrame - heightOffsetVec

            if invisRealParts and invisGhostParts then
                for i = 1, partCount do
                    local rp = invisRealParts[i]
                    local gp = invisGhostParts[i]
                    if rp and gp and rp.Parent and gp.Parent then
                        gp.CFrame = rp.CFrame - heightOffsetVec
                    end
                end
            end
        end)
    else
        if dodgeLocalHrp and dodgeLocalHrp.Parent and dodgeLocalHum and dodgeLocalHum.Health > 0 then
            local currentPos = dodgeLocalHrp.Position
            local currentX, currentZ = currentPos.X, currentPos.Z

            local expectedGroundY = invisSavedCFrame and invisSavedCFrame.Position.Y or (currentPos.Y - INVIS_HEIGHT)

            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
            raycastParams.RespectCanCollide = true

            local filterList = {dodgeLocalChar}
            if activeGhostModel then table.insert(filterList, activeGhostModel) end
            if invisGhostModel then table.insert(filterList, invisGhostModel) end
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj:IsA("BasePart") and (obj.Name:find("Platform") or obj.Name:find("Ghost")) then
                    table.insert(filterList, obj)
                end
            end
            raycastParams.FilterDescendantsInstances = filterList

            local rayOriginY = expectedGroundY + 50
            local rayDistance = 150
            local result = Workspace:Raycast(Vector3.new(currentX, rayOriginY, currentZ), Vector3.new(0, -rayDistance, 0), raycastParams)

            local legOffset = 3.0
            if dodgeLocalHum.RigType == Enum.HumanoidRigType.R15 then
                legOffset = dodgeLocalHum.HipHeight + (dodgeLocalHrp.Size.Y / 2)
            else
                legOffset = (dodgeLocalHum.HipHeight > 0) and (dodgeLocalHum.HipHeight + 1) or 3.0
            end

            local groundY = result and (result.Position.Y + legOffset) or expectedGroundY
            local landingCFrame = CFrame.new(currentX, groundY, currentZ) * dodgeLocalHrp.CFrame.Rotation

            -- Teleport real HRP down to ground BEFORE unbinding camera
            dodgeLocalHrp.Anchored = true
            dodgeLocalHrp.CFrame = landingCFrame
            dodgeLocalHrp.AssemblyLinearVelocity = Vector3.zero
            dodgeLocalHrp.AssemblyAngularVelocity = Vector3.zero
            dodgeLocalHum:ChangeState(Enum.HumanoidStateType.Running)

            pcall(function() RunService:UnbindFromRenderStep("InvisCamAndGhostSync") end)
            if invisFakePlatform then pcall(function() invisFakePlatform:Destroy() end) invisFakePlatform = nil end
            if invisGhostModel then destroyGhostModel(invisGhostModel) invisGhostModel = nil end

            task.defer(function()
                if dodgeLocalHrp and dodgeLocalHrp.Parent then
                    dodgeLocalHrp.Anchored = false
                    dodgeLocalHrp.AssemblyLinearVelocity = Vector3.zero
                    dodgeLocalHrp.AssemblyAngularVelocity = Vector3.zero
                end
            end)
        else
            pcall(function() RunService:UnbindFromRenderStep("InvisCamAndGhostSync") end)
            if invisFakePlatform then pcall(function() invisFakePlatform:Destroy() end) invisFakePlatform = nil end
            if invisGhostModel then destroyGhostModel(invisGhostModel) invisGhostModel = nil end
        end

        invisRealParts = nil
        invisGhostParts = nil
        invisSavedCFrame = nil
    end
end

-- Multi-Layer Enterprise Anti-Hacker Engine
local antiHackerSteppedConn = nil
local antiHackerHeartbeatConn = nil
local lastValidCFrame = nil

_G.LH_SetAntiHacker = function(enable)
    C.AntiHackerOn = enable
    
    if antiHackerSteppedConn then pcall(function() antiHackerSteppedConn:Disconnect() end) antiHackerSteppedConn = nil end
    if antiHackerHeartbeatConn then pcall(function() antiHackerHeartbeatConn:Disconnect() end) antiHackerHeartbeatConn = nil end
    
    lastValidCFrame = nil
    if not enable then return end

    antiHackerSteppedConn = RunService.Stepped:Connect(function()
        pcall(function()
            local myChar = lp.Character
            if not myChar then return end
            
            -- Phase Collision Disabling for Enemy Characters (GetDescendants for complete coverage)
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= lp and player.Character then
                    for _, part in ipairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            if part.CanCollide then part.CanCollide = false end
                        end
                    end
                end
            end
            
            -- Anti-Weld Bring Protection: Only destroy foreign welds connecting local character to external objects
            for _, obj in ipairs(myChar:GetDescendants()) do
                if obj:IsA("Weld") or obj:IsA("ManualWeld") or obj:IsA("WeldConstraint") or obj:IsA("RopeConstraint") or obj:IsA("Seat") then
                    local p0 = (obj:IsA("Weld") or obj:IsA("ManualWeld") or obj:IsA("WeldConstraint")) and obj.Part0 or nil
                    local p1 = (obj:IsA("Weld") or obj:IsA("ManualWeld") or obj:IsA("WeldConstraint")) and obj.Part1 or nil
                    
                    local isForeignBring = false
                    if p0 and p1 then
                        local p0InChar = p0:IsDescendantOf(myChar)
                        local p1InChar = p1:IsDescendantOf(myChar)
                        if (p0InChar and not p1InChar) or (p1InChar and not p0InChar) then
                            isForeignBring = true
                        end
                    elseif obj:IsA("Seat") and obj.Parent == myChar then
                        isForeignBring = true
                    elseif obj:IsA("RopeConstraint") then
                        local a0 = obj.Attachment0
                        local a1 = obj.Attachment1
                        if a0 and a1 then
                            local a0In = a0:IsDescendantOf(myChar)
                            local a1In = a1:IsDescendantOf(myChar)
                            if (a0In and not a1In) or (a1In and not a0In) then
                                isForeignBring = true
                            end
                        end
                    end

                    if isForeignBring then
                        pcall(function() obj:Destroy() end)
                    end
                end
            end
        end)
    end)

    antiHackerHeartbeatConn = RunService.Heartbeat:Connect(function(dt)
        pcall(function()
            local myChar = lp.Character
            if not myChar then return end
            local hrp = myChar:FindFirstChild("HumanoidRootPart")
            local hum = myChar:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum or hum.Health <= 0 then return end

            local currentPos = hrp.Position
            local destroyHeight = Workspace.FallenPartsDestroyHeight or -500

            -- Anti-Fling Velocity Clamping across entire character assembly
            local maxLinVel = math.max(200, (C.SpeedOn and C.Speed * 2.5 or 160))
            local isLinearFling = hrp.AssemblyLinearVelocity.Magnitude > maxLinVel
            local isAngularFling = hrp.AssemblyAngularVelocity.Magnitude > 100

            if isLinearFling or isAngularFling then
                for _, part in ipairs(myChar:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.AssemblyLinearVelocity = Vector3.zero
                        part.AssemblyAngularVelocity = Vector3.zero
                    end
                end
                if lastValidCFrame then hrp.CFrame = lastValidCFrame end
            end

            -- Anti-Void Safety: Prevent infinite void teleport loops
            local safeVoidThreshold = destroyHeight + 60
            if currentPos.Y < safeVoidThreshold then
                for _, part in ipairs(myChar:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.AssemblyLinearVelocity = Vector3.zero
                        part.AssemblyAngularVelocity = Vector3.zero
                    end
                end
                if lastValidCFrame and lastValidCFrame.Position.Y > (destroyHeight + 100) then
                    hrp.CFrame = lastValidCFrame + Vector3.new(0, 5, 0)
                else
                    hrp.CFrame = CFrame.new(currentPos.X, 100, currentPos.Z)
                end
            end

            -- Speed Validation & Distance Guard with zero physics stuttering
            local isCustomMoving = isDodging or beatdownRunning or C.InvisibleOn or C.FlyOn or C.NoclipOn or C.Tweening or C.Teleporting or (hum and (hum:GetState() == Enum.HumanoidStateType.PlatformStanding or hum:GetState() == Enum.HumanoidStateType.Seated or hum.Sit))
            if lastValidCFrame and not isCustomMoving then
                local maxAllowedDist = ((C.SpeedOn and C.Speed or 16) * dt) + 35
                local deltaDist = (currentPos - lastValidCFrame.Position).Magnitude
                if deltaDist > maxAllowedDist and not isLinearFling and not isAngularFling then
                    hrp.CFrame = lastValidCFrame
                    hrp.AssemblyLinearVelocity = Vector3.zero
                else
                    if currentPos.Y > (destroyHeight + 100) and not isLinearFling and not isAngularFling then
                        lastValidCFrame = hrp.CFrame
                    end
                end
            else
                if currentPos.Y > (destroyHeight + 100) then
                    lastValidCFrame = hrp.CFrame
                end
            end
        end)
    end)

    -- ⚡ HITBOX DETECTION SYSTEM: Detect game-spawned hitbox Parts → trigger dodge độ chính xác tuyệt đối
    local hitboxConn = nil
    hitboxConn = Workspace.DescendantAdded:Connect(function(obj)
        if not C.AntiHackerOn then
            if hitboxConn then pcall(function() hitboxConn:Disconnect() end) hitboxConn = nil end
            return
        end
        if not obj:IsA("BasePart") then return end

        -- Detect hitbox patterns: Transparency=1, CanCollide=false, Anchored=false, nhỏ, không phải Platform/Ghost của script
        local name = obj.Name
        if name == "DodgeAirPlatform" or name == "BeatdownEscapePlatform" 
           or name == "LocalDodgeGhost" or name == "InvisAirPlatform" then return end

        -- Hitbox thường có: Transparency >= 0.9, CanCollide=false, Size nhỏ-vừa, tồn tại rất ngắn
        local isLikelyHitbox = false
        if obj.Transparency >= 0.9 and not obj.CanCollide and obj.Size.Magnitude < 80 then
            -- Kiểm tra tên chứa keyword hitbox
            local lname = string.lower(name)
            if lname:find("hit") or lname:find("damage") or lname:find("attack")
               or lname:find("slash") or lname:find("punch") or lname:find("skill")
               or lname:find("projectile") or lname:find("blast") then
                isLikelyHitbox = true
            end
        end

        if not isLikelyHitbox then return end

        -- Check nếu hitbox thuộc về enemy (không phải của mình)
        local ownerChar = getCharacterFromInstance(obj)
        if ownerChar and ownerChar == lp.Character then return end

        -- Check proximity với body người chơi
        task.spawn(function()
            task.wait() -- Chờ 1 frame để hitbox có vị trí chính xác
            if not obj or not obj.Parent then return end
            local myHrp = dodgeLocalHrp or (lp.Character and lp.Character:FindFirstChild("HumanoidRootPart"))
            if not myHrp then return end

            local localPos = (isDodging and dodgeSavedCFrame) and dodgeSavedCFrame.Position or myHrp.Position
            local hitboxPos = obj.Position
            local relPos = localPos - hitboxPos
            local dist2D = math.sqrt(relPos.X * relPos.X + relPos.Z * relPos.Z)
            local deltaY = math.abs(relPos.Y)

            if dist2D <= 20 and deltaY <= 30 then
                if not isDodging and dodgeLocalHum and dodgeLocalHum.Health > 0 then
                    task.spawn(function()
                        triggerDynamicDodge(nil, ownerChar)
                    end)
                end
            end
        end)
    end)
end

-- Emergency Cleanup Manager
local function emergencyDodgeCleanup(skipLand)
    cancelDodgeSignal = true

    -- Hạ cánh TRƯỚC khi gỡ camera offset → tránh 100% camera flash lên trời
    if not skipLand and isDodging and dodgeSavedCFrame and dodgeLocalHrp and dodgeLocalHrp.Parent and dodgeLocalHum and dodgeLocalHum.Health > 0 then
        -- Anchor HRP tại ground position TRƯỚC để camera không flash
        pcall(function()
            dodgeLocalHrp.Anchored = true
            dodgeLocalHrp.CFrame = dodgeSavedCFrame
            dodgeLocalHrp.AssemblyLinearVelocity = Vector3.zero
            dodgeLocalHrp.AssemblyAngularVelocity = Vector3.zero
        end)
        -- Unbind camera NGAY sau khi HRP đã ở mặt đất
        pcall(function() RunService:UnbindFromRenderStep("DodgeCamAndGhostSync") end)
        pcall(function() RunService:UnbindFromRenderStep("InvisCamAndGhostSync") end)
        -- Land chính xác bằng raycast
        safeLandCharacter(activeDodgeHeight, dodgeSavedCFrame)
    else
        pcall(function() RunService:UnbindFromRenderStep("DodgeCamAndGhostSync") end)
        pcall(function() RunService:UnbindFromRenderStep("InvisCamAndGhostSync") end)

        if dodgeLocalHrp and dodgeLocalHrp.Parent and dodgeLocalHum and dodgeLocalHum.Health <= 0 then
            local tFrame = dodgeSavedCFrame or invisSavedCFrame
            if tFrame then pcall(function() dodgeLocalHrp.CFrame = tFrame end) end
        end
    end

    if fakePlatform then pcall(function() fakePlatform:Destroy() end) fakePlatform = nil end
    if activeGhostModel then destroyGhostModel(activeGhostModel) activeGhostModel = nil end
    if invisFakePlatform then pcall(function() invisFakePlatform:Destroy() end) invisFakePlatform = nil end
    if invisGhostModel then destroyGhostModel(invisGhostModel) invisGhostModel = nil end

    invisRealParts = nil
    invisGhostParts = nil
    dodgeSavedCFrame = nil
    invisSavedCFrame = nil
    isDodging = false
    dodgeQueue = {}
end

lp.CharacterAdded:Connect(function(newChar)
    emergencyDodgeCleanup(true)
    C.InvisibleOn = false
    updateDodgeLocalChar()
    if C.AntiHackerOn then _G.LH_SetAntiHacker(true) end

    -- ⚡ SELF-ANIMATOR HOOK: Hook trực tiếp vào Animator của nhân vật mình để detect M1/Skill real-time
    task.spawn(function()
        local myHum = newChar:WaitForChild("Humanoid", 10)
        if not myHum then return end
        local myAnimator = myHum:FindFirstChildOfClass("Animator")
        if not myAnimator then
            myAnimator = myHum:WaitForChild("Animator", 5)
        end
        if not myAnimator then return end

        myAnimator.AnimationPlayed:Connect(function(track)
            if not isDodging then return end
            local animObj = track.Animation
            if not animObj or not animObj.AnimationId then return end
            local rawId = string.match(animObj.AnimationId, "%d+")
            if rawId and SkillDatabase[rawId] then
                cancelDodgeSignal = true
            end
        end)
    end)
end)

-- Hook Animator của nhân vật hiện tại ngay lập tức (không chờ CharacterAdded)
if lp.Character then
    task.spawn(function()
        local myChar = lp.Character
        local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
        if not myHum then return end
        local myAnimator = myHum:FindFirstChildOfClass("Animator")
        if not myAnimator then
            myAnimator = myHum:WaitForChild("Animator", 3)
        end
        if not myAnimator then return end

        myAnimator.AnimationPlayed:Connect(function(track)
            if not isDodging then return end
            local animObj = track.Animation
            if not animObj or not animObj.AnimationId then return end
            local rawId = string.match(animObj.AnimationId, "%d+")
            if rawId and SkillDatabase[rawId] then
                cancelDodgeSignal = true
            end
        end)
    end)
end

local function cancelDodgeNow()
    if isDodging then cancelDodgeSignal = true end
end

-- ⚡ UserInputService Fallback: Bắt M1/Touch/Skill key → cancel dodge đáng tin cậy 100%
local DODGE_CANCEL_KEYS = {
    [Enum.KeyCode.Z] = true, [Enum.KeyCode.X] = true, [Enum.KeyCode.C] = true,
    [Enum.KeyCode.V] = true, [Enum.KeyCode.B] = true, [Enum.KeyCode.F] = true,
    [Enum.KeyCode.G] = true, [Enum.KeyCode.R] = true, [Enum.KeyCode.T] = true,
    [Enum.KeyCode.Q] = true, [Enum.KeyCode.E] = true,
}
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if not isDodging then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        cancelDodgeNow()
    elseif not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard
        and DODGE_CANCEL_KEYS[input.KeyCode] then
        cancelDodgeNow()
    end
end)

-- Dynamic Auto Dodge Core Trigger Function
local function triggerDynamicDodge(enemyTrack, enemyChar)
    if isDodging then 
        table.insert(dodgeQueue, {track = enemyTrack, char = enemyChar})
        return 
    end

    if not dodgeLocalHrp or not dodgeLocalHum or dodgeLocalHum.Health <= 0 then 
        updateDodgeLocalChar()
        if not dodgeLocalHrp or not dodgeLocalHum or dodgeLocalHum.Health <= 0 then return end
    end

    isDodging = true
    cancelDodgeSignal = false

    local enemyRawId = enemyTrack and enemyTrack.Animation and string.match(enemyTrack.Animation.AnimationId, "%d+")
    local skillInfo = enemyRawId and SkillDatabase[enemyRawId]
    if skillInfo then
        activeDodgeHeight = skillInfo.height or (skillInfo.category and skillInfo.category.height) or TELEPORT_HEIGHT
    else
        activeDodgeHeight = TELEPORT_HEIGHT
    end

    task.delay(5, function()
        if isDodging then emergencyDodgeCleanup() end
    end)

    -- ⚡ Ground-Snap: Nếu đang nhảy/rơi, raycast tìm mặt đất thật trước khi lưu vị trí
    local humState = dodgeLocalHum:GetState()
    if humState == Enum.HumanoidStateType.Jumping or humState == Enum.HumanoidStateType.Freefall then
        local snapParams = RaycastParams.new()
        snapParams.FilterType = Enum.RaycastFilterType.Exclude
        snapParams.FilterDescendantsInstances = {dodgeLocalChar}
        snapParams.RespectCanCollide = true
        local snapResult = Workspace:Raycast(dodgeLocalHrp.Position, Vector3.new(0, -200, 0), snapParams)
        if snapResult then
            local groundLegOff = 3.0
            if dodgeLocalHum.RigType == Enum.HumanoidRigType.R15 then
                groundLegOff = dodgeLocalHum.HipHeight + (dodgeLocalHrp.Size.Y / 2)
            end
            dodgeSavedCFrame = CFrame.new(dodgeLocalHrp.Position.X, snapResult.Position.Y + groundLegOff, dodgeLocalHrp.Position.Z) * dodgeLocalHrp.CFrame.Rotation
        else
            dodgeSavedCFrame = dodgeLocalHrp.CFrame
        end
    else
        dodgeSavedCFrame = dodgeLocalHrp.CFrame
    end
    local legOffset = 3.0
    if dodgeLocalHum.RigType == Enum.HumanoidRigType.R15 then
        legOffset = dodgeLocalHum.HipHeight + (dodgeLocalHrp.Size.Y / 2)
    else
        legOffset = (dodgeLocalHum.HipHeight > 0) and (dodgeLocalHum.HipHeight + (dodgeLocalHrp.Size.Y / 2)) or 3.0
    end

    if fakePlatform then pcall(function() fakePlatform:Destroy() end) fakePlatform = nil end

    fakePlatform = Instance.new("Part")
    fakePlatform.Name = "DodgeAirPlatform"
    fakePlatform.Size = Vector3.new(30, 2, 30)
    fakePlatform.Position = dodgeSavedCFrame.Position + Vector3.new(0, activeDodgeHeight - legOffset - 1, 0)
    fakePlatform.Anchored = true
    fakePlatform.Transparency = 1
    fakePlatform.CanCollide = true
    fakePlatform.CanTouch = false
    fakePlatform.CanQuery = false
    fakePlatform.CastShadow = false
    fakePlatform.Parent = Workspace

    -- ⚡ BIND CAMERA OFFSET NGAY LẬP TỨC trước khi teleport → 0% camera flash
    pcall(function() RunService:UnbindFromRenderStep("DodgeCamAndGhostSync") end)
    local CAM_PRIORITY = Enum.RenderPriority.Camera.Value + 1
    local heightOffsetVec = Vector3.new(0, activeDodgeHeight, 0)

    -- Mutable ghost references — render step sẽ pick up ghost parts sau khi tạo
    local ghostRealParts = {}
    local ghostCloneParts = {}
    local ghostPartCount = 0

    RunService:BindToRenderStep("DodgeCamAndGhostSync", CAM_PRIORITY, function()
        if not isDodging or not dodgeLocalHrp or not dodgeLocalHrp.Parent or not dodgeSavedCFrame then return end

        camera.CFrame = camera.CFrame - heightOffsetVec

        local currentPos = dodgeLocalHrp.Position
        local targetY = dodgeSavedCFrame.Position.Y + activeDodgeHeight

        if math.abs(currentPos.Y - targetY) > 0.1 then
            dodgeLocalHrp.CFrame = CFrame.new(currentPos.X, targetY, currentPos.Z) * dodgeLocalHrp.CFrame.Rotation
            dodgeLocalHrp.AssemblyLinearVelocity = Vector3.new(dodgeLocalHrp.AssemblyLinearVelocity.X, 0, dodgeLocalHrp.AssemblyLinearVelocity.Z)
        end

        if dodgeLocalHum and dodgeLocalHum:GetState() == Enum.HumanoidStateType.Freefall then
            dodgeLocalHum:ChangeState(Enum.HumanoidStateType.Running)
        end

        if fakePlatform and fakePlatform.Parent then
            fakePlatform.Position = Vector3.new(currentPos.X, targetY - legOffset - 1, currentPos.Z)
        end

        for i = 1, ghostPartCount do
            local rp = ghostRealParts[i]
            local gp = ghostCloneParts[i]
            if rp and gp and rp.Parent and gp.Parent then
                gp.CFrame = rp.CFrame - heightOffsetVec
            end
        end
    end)

    -- Teleport HRP lên cao SAU khi camera sync đã bind → camera offset ngay frame đầu tiên
    dodgeLocalHrp.CFrame = dodgeSavedCFrame + Vector3.new(0, activeDodgeHeight, 0)
    dodgeLocalHrp.AssemblyLinearVelocity = Vector3.zero
    dodgeLocalHrp.AssemblyAngularVelocity = Vector3.zero

    -- Tạo ghost clone SAU (nếu fail thì dodge vẫn hoạt động, chỉ ko có hình ghost)
    if activeGhostModel then destroyGhostModel(activeGhostModel) activeGhostModel = nil end

    local ghostOk, ghostModel, rParts, gParts = pcall(createGhostClone, dodgeLocalChar)
    if not ghostOk then ghostModel = nil; rParts = {}; gParts = {} end
    activeGhostModel = ghostModel

    -- Inject ghost parts vào render step (mutable upvalue)
    ghostRealParts = rParts or {}
    ghostCloneParts = gParts or {}
    ghostPartCount = #ghostCloneParts

    local dodgeEnemyChar = enemyChar
    local currentTrack = enemyTrack
    while currentTrack and not cancelDodgeSignal do
        local trackEnded = false
        local connStopped, connEnded
        if currentTrack then
            connStopped = currentTrack.Stopped:Connect(function() trackEnded = true end)
            connEnded = currentTrack.Ended:Connect(function() trackEnded = true end)
        end

        local rawAnimId = currentTrack and currentTrack.Animation and string.match(currentTrack.Animation.AnimationId, "%d+")
        local baseLength = (currentTrack and currentTrack.Length and currentTrack.Length > 0) and currentTrack.Length or 1.5
        local catInfo = rawAnimId and SkillDatabase[rawAnimId] and SkillDatabase[rawAnimId].category
        local safetyBuffer = catInfo and catInfo.buffer or 0.3
        local animDuration = math.min(math.max(baseLength + safetyBuffer, 0.8), 4)
        local MIN_DODGE_DURATION = catInfo and catInfo.minDodge or 0.4
        local safeZoneRange = (catInfo and catInfo.bodyHitRange or 12) * 1.8

        local startTime = os.clock()
        while not cancelDodgeSignal and (os.clock() - startTime < animDuration) do
            if not dodgeLocalHum or dodgeLocalHum.Health <= 0 or not dodgeLocalHrp or not dodgeLocalHrp.Parent then
                emergencyDodgeCleanup()
                return
            end

            -- ⚡ REAL-TIME TRACK CHECK: animation đã dừng → hạ cánh ngay (không chờ minDodge)
            if trackEnded or (currentTrack and not currentTrack.IsPlaying) then
                break
            end

            -- ⚡ SAFE ZONE CHECK: Nếu người chơi đã di chuyển ra xa vùng nguy hiểm → hạ cánh sớm
            if dodgeSavedCFrame and dodgeLocalHrp and (os.clock() - startTime >= MIN_DODGE_DURATION) then
                local enemyHrpSafe = dodgeEnemyChar and getRootPart(dodgeEnemyChar)
                if enemyHrpSafe and enemyHrpSafe.Parent then
                    local myGroundPos = Vector3.new(dodgeLocalHrp.Position.X, dodgeSavedCFrame.Position.Y, dodgeLocalHrp.Position.Z)
                    local relSafe = myGroundPos - enemyHrpSafe.Position
                    local dist2DSafe = math.sqrt(relSafe.X * relSafe.X + relSafe.Z * relSafe.Z)
                    if dist2DSafe > safeZoneRange then
                        cancelDodgeSignal = true
                        break
                    end
                elseif not dodgeEnemyChar or not dodgeEnemyChar.Parent then
                    cancelDodgeSignal = true
                    break
                end
            end

            RunService.RenderStepped:Wait()
        end

        if connStopped then pcall(function() connStopped:Disconnect() end) end
        if connEnded then pcall(function() connEnded:Disconnect() end) end

        local nextTrack = nil
        local nextEnemyChar = nil
        local pendingList = dodgeQueue
        dodgeQueue = {}
        for i = #pendingList, 1, -1 do
            local p = pendingList[i]
            if p and p.track and p.track.IsPlaying then
                nextTrack = p.track
                nextEnemyChar = p.char
                break
            end
        end

        currentTrack = nextTrack
        if nextEnemyChar then dodgeEnemyChar = nextEnemyChar end
    end

    -- Cleanup chỉ khi dodge này vẫn active (tránh race condition với emergencyDodgeCleanup)
    if isDodging then
        -- Anchor HRP tại vị trí saved TRƯỚC → camera không flash lên trời
        if dodgeSavedCFrame and dodgeLocalHrp and dodgeLocalHrp.Parent then
            pcall(function()
                dodgeLocalHrp.Anchored = true
                dodgeLocalHrp.CFrame = dodgeSavedCFrame
                dodgeLocalHrp.AssemblyLinearVelocity = Vector3.zero
                dodgeLocalHrp.AssemblyAngularVelocity = Vector3.zero
            end)
        end
        pcall(function() RunService:UnbindFromRenderStep("DodgeCamAndGhostSync") end)
        safeLandCharacter(activeDodgeHeight, dodgeSavedCFrame)
        if fakePlatform then pcall(function() fakePlatform:Destroy() end) fakePlatform = nil end
        if activeGhostModel then destroyGhostModel(activeGhostModel) activeGhostModel = nil end
        dodgeSavedCFrame = nil
        isDodging = false
    end
    cancelDodgeSignal = false
end

-- Thread-Safe Death Counter Warning GUI
local function showDeathCounterWarning(enemyChar, track)
    if not C.DeathCounterOn or not enemyChar then return end
    local head = enemyChar:FindFirstChild("Head") or enemyChar:FindFirstChild("HumanoidRootPart")
    if not head or head:FindFirstChild("LH_DeathCounterGui") then return end

    local bb = Instance.new("BillboardGui")
    bb.Name = "LH_DeathCounterGui"
    bb.Adornee = head
    bb.Size = UDim2.new(0, 38, 0, 38)
    bb.StudsOffset = Vector3.new(0, 3.5, 0)
    bb.AlwaysOnTop = true

    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(1, 0, 1, 0)
    img.BackgroundTransparency = 1
    img.Image = "rbxassetid://10875220379"
    img.Parent = bb
    bb.Parent = head

    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://9114223178"
        sound.Volume = 1.0
        sound.Parent = head
        sound:Play()
        task.delay(1.5, function() pcall(function() sound:Destroy() end) end)
    end)

    local cleaned = false
    local delayThread
    local conn1, conn2

    local function cleanup()
        if cleaned then return end
        cleaned = true
        if conn1 then conn1:Disconnect() end
        if conn2 then conn2:Disconnect() end
        if delayThread then task.cancel(delayThread) end
        pcall(function() bb:Destroy() end)
    end

    if track then
        conn1 = track.Stopped:Connect(cleanup)
        conn2 = track.Ended:Connect(cleanup)
        delayThread = task.delay(5, cleanup)
    else
        delayThread = task.delay(3, cleanup)
    end
end

-- Weak-Key Centralized Animation Listener Architecture
local AnimatorTracker = setmetatable({}, { __mode = "k" })
local ActiveTrackingTasks = {}
local VERTICAL_THREAT_MAX = 18

local function getCharacterFromInstance(inst)
    if not inst then return nil end
    local current = inst
    while current and current ~= Workspace do
        if current:IsA("Model") then
            if current:FindFirstChildOfClass("Humanoid") or Players:GetPlayerFromCharacter(current) then
                return current
            end
        end
        current = current.Parent
    end
    return nil
end

local function getRootPart(charModel)
    if not charModel then return nil end
    return charModel:FindFirstChild("HumanoidRootPart") or charModel.PrimaryPart
end

-- ⚡ Single Central Heartbeat Loop for Ranged/Dash Tracking (SMART PRUNING) ⚡
RunService.Heartbeat:Connect(function()
    if #ActiveTrackingTasks == 0 then return end
    
    local myChar = lp.Character
    local myHrp = getRootPart(myChar)
    if not myHrp then return end
    
    local currentTime = os.clock()
    
    for i = #ActiveTrackingTasks, 1, -1 do
        local taskData = ActiveTrackingTasks[i]
        local track = taskData.Track
        local ownerChar = taskData.OwnerChar
        local rawId = taskData.RawId
        local skillData = rawId and SkillDatabase[rawId]
        local cat = skillData and skillData.category
        
        -- Timeout thông minh: UltimateAoE = 4s, còn lại = 2.5s
        local maxTrackTime = (cat == SkillCategory.UltimateAoE) and 4.0 or 2.5
        
        -- Prune nhanh: kẻ địch biến mất, timeout, hoặc animation đã dừng
        if not ownerChar or not ownerChar.Parent
            or (currentTime - taskData.StartTime > maxTrackTime)
            or (track and not track.IsPlaying) then
            table.remove(ActiveTrackingTasks, i)
        else
            local enemyHrp = getRootPart(ownerChar)
            if enemyHrp and enemyHrp.Parent then
                -- Cone direction check cho LungeDash/BeamLine: kẻ địch phải đang hướng VỀ PHÍA người chơi
                local passDirectionCheck = true
                if cat and (cat == SkillCategory.LungeDash or cat == SkillCategory.BeamLine) then
                    local relPos = myHrp.Position - enemyHrp.Position
                    local flatRel = Vector3.new(relPos.X, 0, relPos.Z)
                    local lv = enemyHrp.CFrame.LookVector
                    local flatLook = Vector3.new(lv.X, 0, lv.Z)
                    if flatRel.Magnitude > 1 and flatLook.Magnitude > 0.1 then
                        local dot = flatLook.Unit:Dot(flatRel.Unit)
                        if dot < 0.3 then -- Kẻ địch KHÔNG nhắm về phía mình → bỏ qua
                            passDirectionCheck = false
                        end
                    end
                end
                
                if passDirectionCheck then
                    local isBodyHit = evaluateSkillThreat(rawId, enemyHrp, myHrp)
                    if isBodyHit then
                        table.remove(ActiveTrackingTasks, i)
                        task.spawn(function()
                            triggerDynamicDodge(track, ownerChar)
                        end)
                    end
                end
            else
                table.remove(ActiveTrackingTasks, i)
            end
        end
    end
end)

local function onAnimationPlayed(track, animator, boundChar)
    local animObj = track.Animation
    if not animObj or not animObj.AnimationId then return end

    local rawId = string.match(animObj.AnimationId, "%d+")
    if not rawId then return end

    local myChar = lp.Character
    local myHrp = getRootPart(myChar)
    local realOwnerChar = getCharacterFromInstance(animator) or boundChar
    if not realOwnerChar then return end

    -- Self attack/M1 cancellation + Beatdown cutscene detection on LOCAL character
    if realOwnerChar == myChar or realOwnerChar:IsDescendantOf(myChar) then
        -- Nếu bản thân dính Beatdown cutscene → trigger escape (KHÔNG cancel dodge)
        if rawId == "11343354388" and C.SaitamaOn then
            task.spawn(handleSaitamaBeatdownEscape, myChar)
            return
        end
        if isDodging and SkillDatabase[rawId] then
            cancelDodgeNow()
        end
        return
    end

    if SkillDatabase[rawId] and SkillDatabase[rawId].isDeathCounter and C.DeathCounterOn then
        showDeathCounterWarning(realOwnerChar, track)
    end

    -- Kích hoạt Đồng Quy Vu Tận khi phát hiện Saitama ra chiêu Beatdown (11343318134) hoặc khi bản thân dính Cutscene Beatdown (11343354388)
    if (rawId == "11343318134" or rawId == "11343354388") and C.SaitamaOn then
        local enemyHrp = getRootPart(realOwnerChar)
        if myHrp then
            task.spawn(handleSaitamaBeatdownEscape, realOwnerChar)
            return
        end
    end

    if rawId == "12447707844" and C.SaitamaOn then
        showUltNotification(realOwnerChar)
    end

    local skillData = SkillDatabase[rawId]
    local isEnabled = false

    if skillData then
        local hero = skillData.hero
        if C.AntiHackerOn then
            isEnabled = true
        else
            if hero == "GarouV1" and C.GarouV1On then isEnabled = true
            elseif hero == "Saitama" and C.SaitamaOn then isEnabled = true
            elseif hero == "GarouV2" and C.GarouV2On then isEnabled = true
            elseif hero == "Cyborg" and C.CyborgOn then isEnabled = true
            elseif hero == "Ninja" and C.NinjaOn then isEnabled = true
            elseif hero == "TrashCan" and C.TrashCanOn then isEnabled = true
            elseif hero == "MetalBat" and C.MetalBatOn then isEnabled = true
            elseif hero == "Tatsumaki" and C.TatsumakiOn then isEnabled = true
            elseif hero == "Samurai" and C.SamuraiOn then isEnabled = true
            elseif hero == "ChildEmperor" and C.ChildEmperorOn then isEnabled = true
            elseif hero == "Zombieman" and C.ZombiemanOn then isEnabled = true
            elseif hero == "Suiryu" and C.SuiryuOn then isEnabled = true
            end
        end
    end

    if not isEnabled or not myHrp then return end

    local enemyHrp = getRootPart(realOwnerChar)
    if not enemyHrp then return end

    local isThreat, radius, buffer, height, minDodge, shouldTrack = evaluateSkillThreat(rawId, enemyHrp, myHrp)

    if isThreat then
        task.spawn(function()
            triggerDynamicDodge(track, realOwnerChar)
        end)
    elseif shouldTrack then
        table.insert(ActiveTrackingTasks, {
            Track = track,
            OwnerChar = realOwnerChar,
            RawId = rawId,
            StartTime = os.clock()
        })
    end
end

local function hookAnimator(animator)
    if not animator or not animator:IsA("Animator") then return end
    if AnimatorTracker[animator] then return end

    local boundChar = getCharacterFromInstance(animator)
    local connections = {}

    connections.AnimationPlayed = animator.AnimationPlayed:Connect(function(track)
        onAnimationPlayed(track, animator, getCharacterFromInstance(animator) or boundChar)
    end)

    local ok, tracks = pcall(function() return animator:GetPlayingAnimationTracks() end)
    if ok and tracks then
        for _, track in ipairs(tracks) do
            if track.IsPlaying then
                task.spawn(onAnimationPlayed, track, animator, boundChar)
            end
        end
    end

    connections.Destroying = animator.Destroying:Connect(function()
        for _, conn in pairs(connections) do conn:Disconnect() end
        AnimatorTracker[animator] = nil
    end)

    AnimatorTracker[animator] = connections
end

local function scanContainer(container)
    if not container then return end
    for _, obj in ipairs(container:GetDescendants()) do
        if obj:IsA("Animator") then hookAnimator(obj) end
    end
end

scanContainer(Workspace)

Workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Animator") then
        hookAnimator(obj)
    elseif obj:IsA("Model") and (obj:FindFirstChildOfClass("Humanoid") or Players:GetPlayerFromCharacter(obj)) then
        scanContainer(obj)
    end
end)

-- ===========================================================================
-- ULTRA-INTELLIGENT MEMORY & OPTIMIZATION CORE
-- ===========================================================================
local OptimizationCore = {
    IsActive = false,
    OriginalStates = setmetatable({}, { __mode = "k" }),
    OriginalLighting = {},
    Connections = {},
    ScanThread = nil,
    FrameBudgetMS = 1.5,
}

local function isProtected(inst)
    if not inst then return true end
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and inst:IsDescendantOf(player.Character) then return true end
    end
    local nameLower = string.lower(inst.Name)
    if string.find(nameLower, "indicator") or string.find(nameLower, "telegraph") 
        or string.find(nameLower, "hitbox") or string.find(nameLower, "dodge") then
        return true
    end
    return false
end

local function optimizeObject(inst)
    if isProtected(inst) or OptimizationCore.OriginalStates[inst] then return end

    if inst:IsA("BasePart") then
        OptimizationCore.OriginalStates[inst] = {
            Material = inst.Material,
            CastShadow = inst.CastShadow
        }
        if inst.Material ~= Enum.Material.SmoothPlastic then inst.Material = Enum.Material.SmoothPlastic end
        if inst.CastShadow then inst.CastShadow = false end

    elseif inst:IsA("PostEffect") or inst:IsA("ParticleEmitter") or inst:IsA("Trail") then
        OptimizationCore.OriginalStates[inst] = { Enabled = inst.Enabled }
        if inst.Enabled then inst.Enabled = false end

    elseif inst:IsA("Decal") or inst:IsA("Texture") then
        OptimizationCore.OriginalStates[inst] = { Transparency = inst.Transparency }
        inst.Transparency = 1
    end
end

local function revertObject(inst, state)
    if not inst or not inst.Parent then return end
    if state.Material ~= nil then inst.Material = state.Material end
    if state.CastShadow ~= nil then inst.CastShadow = state.CastShadow end
    if state.Enabled ~= nil then inst.Enabled = state.Enabled end
    if state.Transparency ~= nil then inst.Transparency = state.Transparency end
end

local function runBudgetedScan()
    local descendants = Workspace:GetDescendants()
    local startTime = os.clock()
    
    for i = 1, #descendants do
        if not C.FixLag then break end
        optimizeObject(descendants[i])
        if (os.clock() - startTime) * 1000 >= OptimizationCore.FrameBudgetMS then
            task.wait()
            startTime = os.clock()
        end
    end
end

_G.LH_lagOn = function()
    if C.FixLag or OptimizationCore.IsActive then return end
    C.FixLag = true
    OptimizationCore.IsActive = true

    OptimizationCore.OriginalLighting = {
        GlobalShadows = Lighting.GlobalShadows,
        FogEnd = Lighting.FogEnd,
        Brightness = Lighting.Brightness,
        WaterWaveSize = Workspace.Terrain and Workspace.Terrain.WaterWaveSize or 0,
        WaterWaveSpeed = Workspace.Terrain and Workspace.Terrain.WaterWaveSpeed or 0,
        WaterReflectance = Workspace.Terrain and Workspace.Terrain.WaterReflectance or 0,
        WaterTransparency = Workspace.Terrain and Workspace.Terrain.WaterTransparency or 1,
    }

    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 1
    if Workspace.Terrain then
        Workspace.Terrain.WaterWaveSize = 0
        Workspace.Terrain.WaterWaveSpeed = 0
        Workspace.Terrain.WaterReflectance = 0
        Workspace.Terrain.WaterTransparency = 1
    end

    OptimizationCore.ScanThread = task.spawn(runBudgetedScan)

    local conn = Workspace.DescendantAdded:Connect(function(child)
        if C.FixLag then optimizeObject(child) end
    end)
    table.insert(OptimizationCore.Connections, conn)
end

_G.LH_lagOff = function()
    C.FixLag = false
    OptimizationCore.IsActive = false

    if OptimizationCore.ScanThread then
        task.cancel(OptimizationCore.ScanThread)
        OptimizationCore.ScanThread = nil
    end

    for _, conn in ipairs(OptimizationCore.Connections) do
        if conn and conn.Connected then conn:Disconnect() end
    end
    table.clear(OptimizationCore.Connections)

    for inst, state in pairs(OptimizationCore.OriginalStates) do
        pcall(revertObject, inst, state)
    end
    table.clear(OptimizationCore.OriginalStates)

    if OptimizationCore.OriginalLighting.GlobalShadows ~= nil then
        Lighting.GlobalShadows = OptimizationCore.OriginalLighting.GlobalShadows
        Lighting.FogEnd = OptimizationCore.OriginalLighting.FogEnd
        Lighting.Brightness = OptimizationCore.OriginalLighting.Brightness
        if Workspace.Terrain then
            Workspace.Terrain.WaterWaveSize = OptimizationCore.OriginalLighting.WaterWaveSize
            Workspace.Terrain.WaterWaveSpeed = OptimizationCore.OriginalLighting.WaterWaveSpeed
            Workspace.Terrain.WaterReflectance = OptimizationCore.OriginalLighting.WaterReflectance
            Workspace.Terrain.WaterTransparency = OptimizationCore.OriginalLighting.WaterTransparency
        end
    end
    table.clear(OptimizationCore.OriginalLighting)
end

-- ===========================================================================
-- ON-SCREEN HUD (TELEPORT & AIMBOT) - BẢN GỐC 100% CỦA NGƯỜI CHƠI
-- ===========================================================================
local hudGUI = nil

_G.LH_HUD = function(on)
    if hudGUI then pcall(function() hudGUI:Destroy() end) hudGUI = nil end
    if not on then return end

    local playerGui = safeParent

    hudGUI = Instance.new("ScreenGui")
    hudGUI.Name = "TeleportGui"
    hudGUI.ResetOnSpawn = false
    hudGUI.ZIndexBehavior = Enum.ZIndexBehavior.Global
    hudGUI.Parent = playerGui

    local teleportButton = Instance.new("TextButton")
    teleportButton.Size = UDim2.new(0, 80, 0, 80)
    teleportButton.Position = UDim2.new(0, 20, 0, 20)
    teleportButton.AnchorPoint = Vector2.new(0, 0)
    teleportButton.Text = "TELEPORT"
    teleportButton.BackgroundColor3 = Color3.fromRGB(255, 59, 59)
    teleportButton.TextColor3 = Color3.new(1, 1, 1)
    teleportButton.TextSize = 14
    teleportButton.Font = Enum.Font.GothamBold
    teleportButton.BorderSizePixel = 0
    teleportButton.AutoButtonColor = false
    teleportButton.Parent = hudGUI

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(1, 0)
    buttonCorner.Parent = teleportButton

    local aimButton = Instance.new("TextButton")
    aimButton.Size = UDim2.new(0, 100, 0, 40)
    aimButton.Position = UDim2.new(1, -110, 0, 20)
    aimButton.AnchorPoint = Vector2.new(0, 0)
    aimButton.Text = "AIM OFF"
    aimButton.BackgroundColor3 = Color3.fromRGB(59, 59, 255)
    aimButton.TextColor3 = Color3.new(1, 1, 1)
    aimButton.TextSize = 14
    aimButton.Font = Enum.Font.GothamBold
    aimButton.BorderSizePixel = 0
    aimButton.AutoButtonColor = false
    aimButton.Parent = hudGUI

    local aimButtonCorner = Instance.new("UICorner")
    aimButtonCorner.CornerRadius = UDim.new(0.3, 0)
    aimButtonCorner.Parent = aimButton

    local isLocked = false
    local targetPlayer = nil
    local currentArrow = nil
    local followConnection = nil
    local lastClickTime = 0
    local CLICK_DELAY = 0.3

    local aimEnabled = false
    local currentTarget = nil
    local aimConnection = nil
    local espFolders = {}
    local arrowGui = nil

    local wallhackEnabled = true

    local function createEspFolder(tPlayer)
        if espFolders[tPlayer] then
            espFolders[tPlayer]:Destroy()
        end
        local folder = Instance.new("Folder")
        folder.Name = tPlayer.Name .. "_ESP"
        folder.Parent = playerGui
        espFolders[tPlayer] = folder
        return folder
    end

    local function updateHighlight(character, tPlayer)
        if not character then return end
        if espFolders[tPlayer] then
            espFolders[tPlayer]:Destroy()
        end
        local folder = createEspFolder(tPlayer)
        
        local highlight = Instance.new("Highlight")
        highlight.Name = "WallhackHighlight"
        highlight.FillColor = Color3.fromRGB(255, 50, 50)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.7
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Adornee = character
        highlight.Parent = folder
        highlight.Enabled = wallhackEnabled
        
        character.Destroying:Connect(function()
            if folder and folder.Parent then
                folder:Destroy()
                espFolders[tPlayer] = nil
            end
        end)
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Died:Connect(function()
                if folder and folder.Parent then
                    folder:Destroy()
                    espFolders[tPlayer] = nil
                end
            end)
        end
    end

    local function toggleWallhack()
        wallhackEnabled = not wallhackEnabled
        for tPlayer, folder in pairs(espFolders) do
            if folder then
                for _, child in pairs(folder:GetChildren()) do
                    if child:IsA("Highlight") then
                        child.Enabled = wallhackEnabled
                    end
                end
            end
        end
        if wallhackEnabled then
            teleportButton.BackgroundColor3 = Color3.fromRGB(255, 59, 59)
        else
            teleportButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        end
    end

    local function initializePlayerESP(otherPlayer)
        if otherPlayer == lp then return end
        local function setupCharacter(character)
            if character and character:IsDescendantOf(Workspace) then
                updateHighlight(character, otherPlayer)
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.Died:Connect(function()
                        if espFolders[otherPlayer] then
                            espFolders[otherPlayer]:Destroy()
                            espFolders[otherPlayer] = nil
                        end
                    end)
                end
                character.AncestryChanged:Connect(function(_, parent)
                    if not character or not character:IsDescendantOf(Workspace) then
                        if espFolders[otherPlayer] then
                            espFolders[otherPlayer]:Destroy()
                            espFolders[otherPlayer] = nil
                        end
                    end
                end)
            end
        end
        if otherPlayer.Character then setupCharacter(otherPlayer.Character) end
        otherPlayer.CharacterAdded:Connect(function(character)
            setupCharacter(character)
        end)
        otherPlayer.AncestryChanged:Connect(function()
            if not otherPlayer or not otherPlayer.Parent then
                if espFolders[otherPlayer] then
                    espFolders[otherPlayer]:Destroy()
                    espFolders[otherPlayer] = nil
                end
            end
        end)
    end

    local function initializeWallhack()
        for tPlayer, folder in pairs(espFolders) do folder:Destroy() end
        espFolders = {}
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            initializePlayerESP(otherPlayer)
        end
        Players.PlayerAdded:Connect(function(newPlayer)
            initializePlayerESP(newPlayer)
        end)
    end

    local function showArrow(target)
        if arrowGui then arrowGui:Destroy() end
        if not target or not target.Character then return end
        local head = target.Character:FindFirstChild("Head")
        if not head then return end

        local agui = Instance.new("BillboardGui")
        agui.Name = "TargetArrow"
        agui.Size = UDim2.new(0, 50, 0, 50)
        agui.AlwaysOnTop = true
        agui.Adornee = head
        agui.MaxDistance = 500
        agui.SizeOffset = Vector2.new(0, 2.5)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = "🔒"
        label.TextColor3 = Color3.fromRGB(255, 0, 0)
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Parent = agui

        agui.Parent = head
        arrowGui = agui
    end

    local function removeArrow()
        if arrowGui then
            arrowGui:Destroy()
            arrowGui = nil
        end
    end

    local function getVisibleTarget()
        local camPos = camera.CFrame.Position
        local camDir = camera.CFrame.LookVector
        local bestTarget = nil
        local bestDot = 0.98
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                local root = p.Character:FindFirstChild("HumanoidRootPart")
                local hum = p.Character:FindFirstChild("Humanoid")
                if root and hum and hum.Health > 0 then
                    local dir = (root.Position - camPos).Unit
                    local dot = camDir:Dot(dir)
                    if dot > bestDot then
                        bestDot = dot
                        bestTarget = p
                    end
                end
            end
        end
        return bestTarget
    end

    local function lockAim(target)
        if not target or not target.Character then return end
        local head = target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("UpperTorso")
        if not head then return end
        local camPos = camera.CFrame.Position
        camera.CFrame = CFrame.new(camPos, head.Position)
    end

    local function startAim()
        if aimConnection then aimConnection:Disconnect() end
        aimConnection = RunService.RenderStepped:Connect(function()
            if not aimEnabled then return end
            if not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("Humanoid") or currentTarget.Character.Humanoid.Health <= 0 then
                currentTarget = getVisibleTarget()
                if currentTarget then
                    showArrow(currentTarget)
                else
                    removeArrow()
                end
            end
            if currentTarget then
                lockAim(currentTarget)
            end
        end)
    end

    aimButton.MouseButton1Click:Connect(function()
        aimEnabled = not aimEnabled
        if aimEnabled then
            aimButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            aimButton.Text = "AIM ON"
            startAim()
        else
            aimButton.BackgroundColor3 = Color3.fromRGB(59, 59, 255)
            aimButton.Text = "AIM OFF"
            removeArrow()
            currentTarget = nil
            if aimConnection then 
                aimConnection:Disconnect() 
                aimConnection = nil
            end
        end
    end)

    local function createArrow(target)
        if currentArrow then
            currentArrow:Destroy()
            currentArrow = nil
        end
        if not target or not target.Character then return end
        local head = target.Character:FindFirstChild("Head")
        if not head then return end
        
        local aGui = Instance.new("BillboardGui")
        aGui.Name = "TargetArrow"
        aGui.Size = UDim2.new(0, 50, 0, 50)
        aGui.AlwaysOnTop = true
        aGui.Enabled = true
        aGui.Adornee = head
        aGui.MaxDistance = 500
        aGui.SizeOffset = Vector2.new(0, 2.5)
        
        local arrowLabel = Instance.new("TextLabel")
        arrowLabel.Size = UDim2.new(1, 0, 1, 0)
        arrowLabel.BackgroundTransparency = 1
        arrowLabel.Text = isLocked and "🔒" or "🎯"
        arrowLabel.TextColor3 = isLocked and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
        arrowLabel.TextScaled = true
        arrowLabel.Font = Enum.Font.GothamBold
        arrowLabel.Parent = aGui
        
        aGui.Parent = head
        currentArrow = aGui
        return aGui
    end

    local function teleportClose(target)
        if not target or not target.Character then return false end
        local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
        local playerRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if not targetRoot or not playerRoot then return false end
        
        local targetCFrame = targetRoot.CFrame
        local lookVector = targetCFrame.LookVector
        local rightVector = targetCFrame.RightVector
        
        local possiblePositions = {
            targetCFrame.Position + rightVector * 1.5,
            targetCFrame.Position - rightVector * 1.5,
            targetCFrame.Position - lookVector * 1.2,
            targetCFrame.Position + lookVector * 1.2,
        }
        
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        raycastParams.FilterDescendantsInstances = {lp.Character, target.Character}
        
        local finalPosition = targetCFrame.Position
        local shortestDistance = math.huge
        
        for _, position in pairs(possiblePositions) do
            local direction = (position - targetRoot.Position)
            local raycastResult = Workspace:Raycast(
                targetRoot.Position,
                direction,
                raycastParams
            )
            if not raycastResult then
                finalPosition = position
                break
            else
                local distance = (raycastResult.Position - targetRoot.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    finalPosition = raycastResult.Position - direction.Unit * 0.5
                end
            end
        end
        
        local teleportCFrame = CFrame.new(finalPosition, targetRoot.Position)
        playerRoot.CFrame = teleportCFrame
        return true
    end

    local function unlockTarget()
        isLocked = false
        targetPlayer = nil
        if followConnection then
            followConnection:Disconnect()
            followConnection = nil
        end
        if currentArrow then
            currentArrow:Destroy()
            currentArrow = nil
        end
        teleportButton.BackgroundColor3 = wallhackEnabled and Color3.fromRGB(255, 59, 59) or Color3.fromRGB(100, 100, 100)
        teleportButton.Text = "TELEPORT"
    end

    local function startContinuousFollow()
        if followConnection then
            followConnection:Disconnect()
            followConnection = nil
        end
        followConnection = RunService.Heartbeat:Connect(function()
            if not isLocked then return end
            if targetPlayer and targetPlayer.Character then
                local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                local playerRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot and playerRoot then
                    local distance = (targetRoot.Position - playerRoot.Position).Magnitude
                    if distance > 3 then
                        teleportClose(targetPlayer)
                    end
                end
            else
                unlockTarget()
            end
        end)
    end

    local function lockTarget()
        local newTarget = getVisibleTarget()
        if not newTarget then
            teleportButton.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
            teleportButton.Text = "NO TARGET"
            task.delay(1, function()
                if not isLocked then
                    if teleportButton and teleportButton.Parent then
                        teleportButton.BackgroundColor3 = wallhackEnabled and Color3.fromRGB(255, 59, 59) or Color3.fromRGB(100, 100, 100)
                        teleportButton.Text = "TELEPORT"
                    end
                end
            end)
            return false
        end
        targetPlayer = newTarget
        isLocked = true
        teleportButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        teleportButton.Text = "LOCKED"
        createArrow(targetPlayer)
        startContinuousFollow()
        teleportClose(targetPlayer)
        return true
    end

    local function handleTeleportClick()
        local currentTime = tick()
        if currentTime - lastClickTime < CLICK_DELAY then return end
        lastClickTime = currentTime
        if isLocked then
            unlockTarget()
        else
            lockTarget()
        end
    end

    teleportButton.MouseButton1Click:Connect(handleTeleportClick)
    teleportButton.MouseButton2Click:Connect(toggleWallhack)
    teleportButton.TouchTap:Connect(handleTeleportClick)

    local cAdd = lp.CharacterAdded:Connect(function(character)
        unlockTarget()
        initializeWallhack()
    end)
    
    local pRem = Players.PlayerRemoving:Connect(function(leavingPlayer)
        if leavingPlayer == targetPlayer then unlockTarget() end
        if leavingPlayer == currentTarget then
            currentTarget = nil
            removeArrow()
        end
        if espFolders[leavingPlayer] then
            espFolders[leavingPlayer]:Destroy()
            espFolders[leavingPlayer] = nil
        end
    end)
    
    hudGUI.Destroying:Connect(function()
        cAdd:Disconnect()
        pRem:Disconnect()
        for tPlayer, folder in pairs(espFolders) do folder:Destroy() end
        espFolders = {}
        if aimConnection then aimConnection:Disconnect() aimConnection = nil end
        if followConnection then followConnection:Disconnect() followConnection = nil end
    end)

    initializeWallhack()
end

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "LUCKATHUB V18.5 SIÊU CẤP";
    Text = "Đã tải xong toàn bộ hệ thống Auto Dodge & Anti-Hacker Siêu Thông Minh!",
    Duration = 5;
})
