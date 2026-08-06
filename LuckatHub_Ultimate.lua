-- ============================================================================
-- LUCKATHUB VIP PRO - MOBILE EDITION (V10)
-- 100% Tối ưu cho Mobile (Delta / Fluxus / CodeX)
-- Khởi động dạng icon thu nhỏ (chống kẹt joystick)
-- Giao diện siêu mượt, không lỗi kéo thả, không lỗi đơ màn hình
-- ============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local lp = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ==================== DỌN DẸP GUI CŨ ====================
local safeParent
local ok = pcall(function() safeParent = CoreGui end)
if not ok or not safeParent then safeParent = lp:WaitForChild("PlayerGui") end

for _, v in ipairs(safeParent:GetChildren()) do
    if v.Name == "LuckatHubMobileV11" then
        pcall(function() v:Destroy() end)
    end
end

-- ==================== CẤU HÌNH TÍNH NĂNG ====================
local C = {
    Wallhack = false,
    HUDOn = false,
    FixLag = false
}

-- ==================== KHỞI TẠO GUI ====================
local gui = Instance.new("ScreenGui")
gui.Name = "LuckatHubMobileV11"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.Parent = safeParent

-- Bảng màu Neon Dark
local C_BG = Color3.fromRGB(15, 15, 20)
local C_SIDE = Color3.fromRGB(22, 22, 30)
local C_TOP = Color3.fromRGB(26, 26, 36)
local C_ACCENT = Color3.fromRGB(90, 60, 255)
local C_TEXT = Color3.fromRGB(240, 240, 240)
local C_TEXT_DIM = Color3.fromRGB(130, 130, 150)
local C_CARD = Color3.fromRGB(30, 30, 42)

-- Kéo thả tối ưu Mobile (Chỉ track ngón tay đang chạm)
local function makeDraggable(frame, handle)
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local startPos = frame.Position
            local startInput = input.Position
            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    if conn then conn:Disconnect() end
                    return
                end
                local delta = input.Position - startInput
                frame.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end)
        end
    end)
end

-- ==================== NÚT THU NHỎ (MỞ ĐẦU TIÊN) ====================
-- Bắt đầu bằng nút thu nhỏ để KHÔNG BAO GIỜ đè lên joystick
local floatBtn = Instance.new("TextButton")
floatBtn.Size = UDim2.new(0, 46, 0, 46)
floatBtn.Position = UDim2.new(0, 20, 0, 20)
floatBtn.BackgroundColor3 = C_ACCENT
floatBtn.Text = "LH"
floatBtn.TextColor3 = Color3.new(1, 1, 1)
floatBtn.Font = Enum.Font.GothamBold
floatBtn.TextSize = 18
floatBtn.Parent = gui
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1, 0)
local floatStroke = Instance.new("UIStroke", floatBtn)
floatStroke.Color = Color3.fromRGB(150, 100, 255)
floatStroke.Thickness = 2
makeDraggable(floatBtn, floatBtn)

-- ==================== MENU CHÍNH ====================
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 400, 0, 260) -- Kích thước gọn gàng cho mobile
main.Position = UDim2.new(0.5, -200, 0.5, -130)
main.BackgroundColor3 = C_BG
main.BorderSizePixel = 0
main.Visible = false -- BẮT ĐẦU ẨN
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 35)
header.BackgroundColor3 = C_TOP
header.BorderSizePixel = 0
header.Parent = main
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 8)
local hPatch = Instance.new("Frame")
hPatch.Size = UDim2.new(1, 0, 0, 10)
hPatch.Position = UDim2.new(0, 0, 1, -10)
hPatch.BackgroundColor3 = C_TOP
hPatch.BorderSizePixel = 0
hPatch.Parent = header
makeDraggable(main, header)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "LuckatHub | Mobile VIP"
title.TextColor3 = C_TEXT
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 2)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.Parent = header

-- Logic Đóng/Mở
closeBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    floatBtn.Visible = true
end)
floatBtn.MouseButton1Click:Connect(function()
    main.Visible = true
    floatBtn.Visible = false
end)

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 110, 1, -35)
sidebar.Position = UDim2.new(0, 0, 0, 35)
sidebar.BackgroundColor3 = C_SIDE
sidebar.BorderSizePixel = 0
sidebar.Parent = main
local sLayout = Instance.new("UIListLayout", sidebar)
sLayout.SortOrder = Enum.SortOrder.LayoutOrder
local sPad = Instance.new("UIPadding", sidebar)
sPad.PaddingTop = UDim.new(0, 5)

-- Content Area
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -110, 1, -35)
content.Position = UDim2.new(0, 110, 0, 35)
content.BackgroundTransparency = 1
content.Parent = main

local tabs = {}
local tabBtns = {}

local function switchTab(name)
    for k, v in pairs(tabs) do v.Visible = (k == name) end
    for k, v in pairs(tabBtns) do
        v.BackgroundColor3 = (k == name) and C_ACCENT or C_SIDE
        v.TextColor3 = (k == name) and Color3.new(1,1,1) or C_TEXT_DIM
    end
end

local function makeTab(name, displayName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = C_SIDE
    btn.Text = "  " .. displayName
    btn.TextColor3 = C_TEXT_DIM
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.Parent = sidebar
    tabBtns[name] = btn

    local sf = Instance.new("ScrollingFrame")
    sf.Size = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 2
    sf.Visible = false
    sf.Parent = content
    
    local layout = Instance.new("UIListLayout", sf)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)
    
    local pad = Instance.new("UIPadding", sf)
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)
    pad.PaddingLeft = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 12)

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sf.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
    end)

    tabs[name] = sf
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
    
    return sf
end

-- ==================== THÀNH PHẦN UI ====================
local layoutOrder = 0
local function getOrder() layoutOrder = layoutOrder + 1 return layoutOrder end

local function addToggle(parent, title, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 38)
    frame.BackgroundColor3 = C_CARD
    frame.LayoutOrder = getOrder()
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = C_TEXT
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 38, 0, 18)
    btn.Position = UDim2.new(1, -50, 0.5, -9)
    btn.BackgroundColor3 = default and C_ACCENT or Color3.fromRGB(50, 50, 65)
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.Parent = btn
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and C_ACCENT or Color3.fromRGB(50, 50, 65)
        knob.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        pcall(callback, state)
    end)
end

local function addInput(parent, title, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 38)
    frame.BackgroundColor3 = C_CARD
    frame.LayoutOrder = getOrder()
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -80, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = C_TEXT
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 50, 0, 22)
    box.Position = UDim2.new(1, -62, 0.5, -11)
    box.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    box.Text = tostring(default)
    box.TextColor3 = Color3.fromRGB(0, 220, 150)
    box.Font = Enum.Font.GothamBold
    box.TextSize = 11
    box.Parent = frame
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)

    box.FocusLost:Connect(function()
        local n = tonumber(box.Text)
        if n then
            pcall(callback, n)
        else
            box.Text = tostring(default)
        end
    end)
end

local function addButton(parent, title, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = C_CARD
    btn.Text = title
    btn.TextColor3 = C_TEXT
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.LayoutOrder = getOrder()
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(function()
        pcall(callback)
        btn.BackgroundColor3 = C_ACCENT
        task.wait(0.1)
        btn.BackgroundColor3 = C_CARD
    end)
end

local function addTitle(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = C_TEXT_DIM
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = getOrder()
    lbl.Parent = parent
end

-- ==================== XÂY DỰNG TABS ====================
local T1 = makeTab("combat", "Tác Chiến")
local T2 = makeTab("bypass", "Ultra Bypass")
local T3 = makeTab("lag", "Tối Ưu FPS")

-- TAB 1: Tác Chiến
addTitle(T1, "CHIẾN ĐẤU")
addToggle(T1, "Bật HUD (Teleport & Aimbot)", C.HUDOn, function(v)
    C.HUDOn = v
    if _G.LH_HUD then _G.LH_HUD(v) end
end)

-- TAB 2: Ultra Bypass
local _kickBlock = false
local _remFilter = false
addTitle(T2, "CHỐNG KICK/BAN")
addToggle(T2, "Kick Block (Chống Kick)", _kickBlock, function(v) _kickBlock = v end)
addToggle(T2, "Remote Blacklist (Bảo Vệ)", _remFilter, function(v) _remFilter = v end)
addTitle(T2, "CÔNG CỤ BYPASS")
addButton(T2, "Ngụy Trang Tên Script", function()
    local names = {"PlayerModule", "CameraModule", "ControlModule", "ChatMain"}
    pcall(function() if script and script.Parent then script.Name = names[math.random(#names)] end end)
end)
addButton(T2, "Scan & Đóng Băng AntiCheat", function()
    pcall(function()
        if not getthreads then return end
        local kws = {"speedcheck","positioncheck","anticheat","velocity_check","sanity"}
        for _, th in ipairs(getthreads()) do
            pcall(function()
                local s = tostring(th):lower()
                for _, kw in ipairs(kws) do
                    if s:find(kw, 1, true) then task.defer(function() coroutine.yield(th) end) break end
                end
            end)
        end
    end)
end)

-- TAB 3: Fix Lag
addTitle(T3, "TỐI ƯU HÓA TRỰC TIẾP")
addButton(T3, "Bật Fix Lag Auto (Triệt Để)", function() if _G.LH_lagOn then _G.LH_lagOn() end end)
addButton(T3, "Tắt Fix Lag Auto", function() if _G.LH_lagOff then _G.LH_lagOff() end end)

switchTab("combat")

-- ==================== VẬN HÀNH TÍNH NĂNG (SUBSYSTEMS) ====================
local charCache = {}
local function getChar()
    charCache.char = lp.Character
    charCache.hum = charCache.char and charCache.char:FindFirstChildOfClass("Humanoid")
    charCache.hrp = charCache.char and charCache.char:FindFirstChild("HumanoidRootPart")
end
getChar()
lp.CharacterAdded:Connect(function() task.wait(0.3) getChar() end)

-- ==========================================
-- ĐỘNG CƠ PHYSICS SIÊU MƯỢT (HEARTBEAT)
-- ==========================================
local targetSpeed = 16
local targetJump = 50
local playerControls = require(lp.PlayerScripts:WaitForChild("PlayerModule")):GetControls()

RunService.Heartbeat:Connect(function(deltaTime)
    local hum, hrp = charCache.hum, charCache.hrp
    if not hrp or not hum or hum.Health <= 0 then return end
    
    if targetJump ~= 50 then
        hum.UseJumpPower = true
        hum.JumpPower = targetJump
    else
        hum.JumpPower = 50
    end

    if targetSpeed <= 16 then return end
    
    local activeMove = playerControls:GetMoveVector()
    if activeMove.Magnitude < 0.05 then return end 
    
    local camLook = camera.CFrame.LookVector
    local camRight = camera.CFrame.RightVector
    local forward = Vector3.new(camLook.X, 0, camLook.Z).Unit
    local right = Vector3.new(camRight.X, 0, camRight.Z).Unit
    
    local worldMoveDir = (forward * -activeMove.Z) + (right * activeMove.X)
    if worldMoveDir.Magnitude > 0 then
        worldMoveDir = worldMoveDir.Unit
    end
    
    if hrp.Anchored then hrp.Anchored = false end
    hum.AutoRotate = true 
    
    local currentVel = hrp.AssemblyLinearVelocity
    local currentHorizSpeed = Vector3.new(currentVel.X, 0, currentVel.Z).Magnitude
    
    if currentHorizSpeed > targetSpeed + 15 then
        return
    end
    
    hrp.AssemblyLinearVelocity = Vector3.new(
        worldMoveDir.X * targetSpeed,
        currentVel.Y,
        worldMoveDir.Z * targetSpeed
    )
    
    if hum.MoveDirection.Magnitude < 0.05 then
        local targetLook = hrp.Position + worldMoveDir
        hrp.CFrame = hrp.CFrame:Lerp(CFrame.lookAt(hrp.Position, targetLook), 0.15)
    end
end)

-- ==========================================
-- GIAO DIỆN CHỈNH TỐC ĐỘ + NHẢY CAO
-- ==========================================
local speedGui = Instance.new("ScreenGui")
speedGui.Name = "SpeedJumpUltra"
speedGui.ResetOnSpawn = false
speedGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
speedGui.Parent = safeParent

local sf = Instance.new("Frame")
sf.Size = UDim2.new(0, 160, 0, 75)
sf.Position = UDim2.new(0.5, -80, 0.01, 0)
sf.BackgroundTransparency = 0.4
sf.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
sf.BorderSizePixel = 0
sf.Active = true
sf.ClipsDescendants = true
sf.Parent = speedGui
Instance.new("UICorner", sf).CornerRadius = UDim.new(0, 8)

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(1, -40, 0, 30)
speedBox.Position = UDim2.new(0, 10, 0, 5)
speedBox.BackgroundTransparency = 1
speedBox.TextColor3 = Color3.fromRGB(0, 255, 150)
speedBox.Text = "🏃 " .. tostring(targetSpeed)
speedBox.TextSize = 16
speedBox.Font = Enum.Font.GothamBold
speedBox.TextXAlignment = Enum.TextXAlignment.Left
speedBox.ClearTextOnFocus = true
speedBox.Parent = sf

local jumpBox = Instance.new("TextBox")
jumpBox.Size = UDim2.new(1, -40, 0, 30)
jumpBox.Position = UDim2.new(0, 10, 0, 40)
jumpBox.BackgroundTransparency = 1
jumpBox.TextColor3 = Color3.fromRGB(255, 150, 0)
jumpBox.Text = "🚀 " .. tostring(targetJump)
jumpBox.TextSize = 16
jumpBox.Font = Enum.Font.GothamBold
jumpBox.TextXAlignment = Enum.TextXAlignment.Left
jumpBox.ClearTextOnFocus = true
jumpBox.Parent = sf

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -35, 0, 5)
minBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
minBtn.Text = "➖"
minBtn.TextColor3 = Color3.new(1, 1, 1)
minBtn.TextSize = 12
minBtn.Parent = sf
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

local isMinimized = false
minBtn.Activated:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        sf.Size = UDim2.new(0, 45, 0, 40)
        speedBox.Visible = false
        jumpBox.Visible = false
        minBtn.Position = UDim2.new(0, 7, 0, 5)
        minBtn.Text = "➕"
    else
        sf.Size = UDim2.new(0, 160, 0, 75)
        speedBox.Visible = true
        jumpBox.Visible = true
        minBtn.Position = UDim2.new(1, -35, 0, 5)
        minBtn.Text = "➖"
    end
end)

local draggingS, dragStartS, startPosS
sf.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingS = true dragStartS = input.Position startPosS = sf.Position
    end
end)
sf.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then draggingS = false end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if draggingS and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStartS
        sf.Position = UDim2.new(startPosS.X.Scale, startPosS.X.Offset + delta.X, startPosS.Y.Scale, startPosS.Y.Offset + delta.Y)
    end
end)

speedBox.FocusLost:Connect(function()
    local text = speedBox.Text:gsub("[^%d]", "")
    local v = tonumber(text)
    if v then targetSpeed = math.clamp(v, 16, 200) end
    speedBox.Text = "🏃 " .. tostring(targetSpeed)
end)
jumpBox.FocusLost:Connect(function()
    local text = jumpBox.Text:gsub("[^%d]", "")
    local v = tonumber(text)
    if v then targetJump = math.clamp(v, 50, 500) end
    jumpBox.Text = "🚀 " .. tostring(targetJump)
end)

-- Hook Bypass Engine
task.spawn(function()
    pcall(function()
        if typeof(hookmetamethod) ~= "function" or typeof(getnamecallmethod) ~= "function" then return end
        local old
        old = hookmetamethod(game, "__namecall", function(self, ...)
            local m = getnamecallmethod()
            if _kickBlock and (m == "Kick" or m == "Ban") then return nil end
            if _remFilter and (m == "FireServer" or m == "InvokeServer") then
                local ok, n = pcall(function() return self.Name:lower() end)
                if ok and n then
                    for _, kw in ipairs({"report", "cheat", "hack", "detect", "ban", "kick", "anticheat", "sanity", "exploit"}) do
                        if n:find(kw, 1, true) then return nil end
                    end
                end
            end
            return old(self, ...)
        end)
    end)
end)

-- Fix Lag Auto System
local lagConn = nil
local lagLoop = nil
local function doLagFix()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 1
    for _, o in ipairs(workspace:GetDescendants()) do
        if o:IsA("BasePart") then
            o.Material = Enum.Material.SmoothPlastic
            o.CastShadow = false
        elseif o:IsA("PostEffect") or o:IsA("ParticleEmitter") or o:IsA("Decal") or o:IsA("Texture") or o:IsA("Trail") then
            pcall(function() o.Enabled = false end)
            pcall(function() o.Transparency = 1 end)
        end
    end
end

_G.LH_lagOn = function()
    C.FixLag = true
    doLagFix()
    if not lagLoop then
        lagLoop = RunService.Heartbeat:Connect(function()
            if workspace.Terrain then
                workspace.Terrain.WaterWaveSize = 0
                workspace.Terrain.WaterWaveSpeed = 0
                workspace.Terrain.WaterReflectance = 0
                workspace.Terrain.WaterTransparency = 1
            end
        end)
    end
    if not lagConn then
        lagConn = workspace.DescendantAdded:Connect(function(o)
            task.defer(function()
                if o:IsA("BasePart") then
                    o.Material = Enum.Material.SmoothPlastic
                    o.CastShadow = false
                elseif o:IsA("PostEffect") or o:IsA("ParticleEmitter") or o:IsA("Decal") or o:IsA("Texture") or o:IsA("Trail") then
                    pcall(function() o.Enabled = false end)
                end
            end)
        end)
    end
end
_G.LH_lagOff = function()
    C.FixLag = false
    if lagLoop then lagLoop:Disconnect() lagLoop = nil end
    if lagConn then lagConn:Disconnect() lagConn = nil end
end

-- On-Screen HUD System (Tích hợp Code Gốc)
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

    -- ===========================================================================
    -- PHẦN AIMBOT MỚI (ĐÃ THAY THẾ HOÀN TOÀN)
    -- ===========================================================================

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
            if character and character:IsDescendantOf(workspace) then
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
                    if not character or not character:IsDescendantOf(workspace) then
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
            local raycastResult = workspace:Raycast(
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

-- Thông báo
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "LuckatHub Mobile V11";
    Text = "Đã khởi động thành công!";
    Duration = 5;
})
