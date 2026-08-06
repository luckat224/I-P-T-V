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
    SpeedOn = false, Speed = 45,
    JumpOn = false, Jump = 100,
    FlyOn = false, FlySpeed = 50,
    NoclipOn = false,
    Wallhack = false,
    Aimbot = false,
    HUDOn = false,
    AntiAFK = false,
    AntiVoid = false,
    AntiStun = false,
    GhostOn = false,
    PhantomOn = false, PhantomForce = 120,
    AntiHack = false, AntiHackR = 8, AntiHackP = 18,
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
local T1 = makeTab("move", "Di Chuyển")
local T2 = makeTab("combat", "Tác Chiến")
local T3 = makeTab("protect", "Bảo Vệ")
local T4 = makeTab("bypass", "Ultra Bypass")
local T5 = makeTab("lag", "Tối Ưu FPS")

-- TAB 1: Di Chuyển
addTitle(T1, "TỐC ĐỘ & NHẢY")
addToggle(T1, "Chạy Nhanh (Speed)", C.SpeedOn, function(v) C.SpeedOn = v end)
addInput(T1, "Tốc Độ Chạy", C.Speed, function(v) C.Speed = v end)
addToggle(T1, "Nhảy Cao (Jump)", C.JumpOn, function(v) C.JumpOn = v end)
addInput(T1, "Lực Nhảy", C.Jump, function(v) C.Jump = v end)
addTitle(T1, "ĐẶC BIỆT")
addToggle(T1, "Xuyên Tường (Noclip)", C.NoclipOn, function(v) C.NoclipOn = v end)
addToggle(T1, "Bay (Fly)", C.FlyOn, function(v) C.FlyOn = v end)

-- TAB 2: Tác Chiến
addTitle(T2, "QUAN SÁT")
addToggle(T2, "Nhìn Xuyên Tường (ESP)", C.Wallhack, function(v)
    C.Wallhack = v
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local hl = p.Character:FindFirstChild("LH_HL")
            if hl then hl.Enabled = v end
        end
    end
end)
addTitle(T2, "CHIẾN ĐẤU")
addToggle(T2, "Bật HUD Trên Màn Hình (Aimbot & TP)", C.HUDOn, function(v)
    C.HUDOn = v
    if _G.LH_HUD then _G.LH_HUD(v) end
end)

-- TAB 3: Bảo Vệ
addTitle(T3, "SINH TỒN")
addToggle(T3, "Chống AFK", C.AntiAFK, function(v) C.AntiAFK = v end)
addToggle(T3, "Chống Rơi Vực (Anti-Void)", C.AntiVoid, function(v) C.AntiVoid = v end)
addToggle(T3, "Chống Choáng (Anti-Stun)", C.AntiStun, function(v) C.AntiStun = v end)
addTitle(T3, "NÂNG CAO")
addToggle(T3, "Tàng Hình (Ghost Mode)", C.GhostOn, function(v) C.GhostOn = v end)
addToggle(T3, "Chống Hacker Lại Gần", C.AntiHack, function(v) C.AntiHack = v end)
addInput(T3, "Bán kính đẩy (studs)", C.AntiHackR, function(v) C.AntiHackR = v end)

-- TAB 4: Ultra Bypass
local _kickBlock = false
local _remFilter = false
addTitle(T4, "CHỐNG KICK/BAN")
addToggle(T4, "Kick Block (Chống Kick)", _kickBlock, function(v) _kickBlock = v end)
addToggle(T4, "Remote Blacklist (Bảo Vệ)", _remFilter, function(v) _remFilter = v end)
addTitle(T4, "CÔNG CỤ BYPASS")
addButton(T4, "Ngụy Trang Tên Script", function()
    local names = {"PlayerModule", "CameraModule", "ControlModule", "ChatMain"}
    pcall(function() if script and script.Parent then script.Name = names[math.random(#names)] end end)
end)
addButton(T4, "Scan & Đóng Băng AntiCheat", function()
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

-- TAB 5: Fix Lag
addTitle(T5, "TỐI ƯU HÓA TRỰC TIẾP")
addButton(T5, "Bật Fix Lag Live", function() if _G.LH_lagOn then _G.LH_lagOn() end end)
addButton(T5, "Tắt Fix Lag Live", function() if _G.LH_lagOff then _G.LH_lagOff() end end)
addTitle(T5, "ĐỒ HỌA MÁY YẾU")
addButton(T5, "Bật Chế Độ Đồ Họa Siêu Thấp", function()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    for _, o in ipairs(workspace:GetDescendants()) do
        if o:IsA("BasePart") then
            o.Material = Enum.Material.SmoothPlastic
        elseif o:IsA("PostEffect") or o:IsA("ParticleEmitter") then
            o.Enabled = false
        end
    end
end)

switchTab("move")

-- ==================== VẬN HÀNH TÍNH NĂNG (SUBSYSTEMS) ====================
local charCache = {}
local function getChar()
    charCache.char = lp.Character
    charCache.hum = charCache.char and charCache.char:FindFirstChildOfClass("Humanoid")
    charCache.hrp = charCache.char and charCache.char:FindFirstChild("HumanoidRootPart")
end
getChar()
lp.CharacterAdded:Connect(function() task.wait(0.3) getChar() end)

-- Vòng lặp vật lý chính
RunService.Heartbeat:Connect(function()
    local char, hum, hrp = charCache.char, charCache.hum, charCache.hrp
    if not hum or not hrp or hum.Health <= 0 then return end

    if C.JumpOn then
        hum.UseJumpPower = true
        hum.JumpPower = C.Jump
    end

    if C.SpeedOn then
        local d = hum.MoveDirection
        if d.Magnitude > 0.05 then
            hrp.AssemblyLinearVelocity = Vector3.new(d.X * C.Speed, hrp.AssemblyLinearVelocity.Y, d.Z * C.Speed)
        end
    end

    if C.NoclipOn and char then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end

    if C.AntiVoid and hrp.Position.Y < -100 then
        hrp.CFrame = CFrame.new(hrp.Position.X, 50, hrp.Position.Z)
        hrp.AssemblyLinearVelocity = Vector3.zero
    end
    
    if C.AntiStun and char then
        hum.PlatformStand = false
        for _, ch in ipairs(char:GetChildren()) do
            local n = ch.Name
            if n == "Stun" or n == "Freeze" or n == "Ragdoll" or n == "Knockback" then
                pcall(function() ch:Destroy() end)
            end
        end
    end
end)

local prevP = {}
local dodgeCD = 0
local warnCD = {}
RunService.Heartbeat:Connect(function()
    local hrp = charCache.hrp
    if not hrp then return end
    local myPos = hrp.Position
    local now = tick()
    for _, p in ipairs(Players:GetPlayers()) do
        if p == lp or not p.Character then continue end
        local r = p.Character:FindFirstChild("HumanoidRootPart")
        if not r then prevP[p] = nil continue end
        local cur = r.Position
        local prev = prevP[p]
        if prev then
            local jumped = (cur - prev).Magnitude
            local dist = (cur - myPos).Magnitude
            if C.AntiHack and jumped > 80 and dist < C.AntiHackR then
                if not warnCD[p] or now - warnCD[p] > 2 then
                    warnCD[p] = now
                    local dir = (myPos - cur)
                    if dir.Magnitude > 0 then dir = dir.Unit else dir = -camera.CFrame.LookVector end
                    hrp.CFrame = CFrame.new(myPos + dir * C.AntiHackP)
                    hrp.AssemblyLinearVelocity = dir * 22
                end
            end
            if C.GhostOn and jumped > 60 and dist < 14 and now - dodgeCD > 0.4 then
                dodgeCD = now
                local angle = math.random() * math.pi * 2
                local esc = Vector3.new(math.cos(angle), 0, math.sin(angle))
                if C.PhantomOn then
                    hrp.AssemblyLinearVelocity = Vector3.new(esc.X * C.PhantomForce, 38, esc.Z * C.PhantomForce)
                else
                    hrp.CFrame = CFrame.new(myPos + esc * 18)
                end
            end
        end
        prevP[p] = cur
    end
end)

-- Vòng lặp Render (Fly & Aimbot)
local flyBV, flyBG
RunService.RenderStepped:Connect(function()
    local hrp, hum = charCache.hrp, charCache.hum
    if hrp then
        if C.FlyOn then
            if not flyBV then
                flyBV = Instance.new("BodyVelocity", hrp)
                flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            end
            if not flyBG then
                flyBG = Instance.new("BodyGyro", hrp)
                flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
                flyBG.P = 5e4
            end
            flyBG.CFrame = camera.CFrame
            local dir = hum and hum.MoveDirection or Vector3.zero
            flyBV.Velocity = dir * C.FlySpeed
        else
            if flyBV then flyBV:Destroy() flyBV = nil end
            if flyBG then flyBG:Destroy() flyBG = nil end
        end
    end

    if C.Aimbot then
        local camPos = camera.CFrame.Position
        local camDir = camera.CFrame.LookVector
        local best, maxDot = nil, 0.90
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                local r = p.Character:FindFirstChild("HumanoidRootPart")
                if r then
                    local dot = camDir:Dot((r.Position - camPos).Unit)
                    if dot > maxDot then maxDot = dot best = p end
                end
            end
        end
        if best and best.Character and best.Character:FindFirstChild("Head") then
            camera.CFrame = CFrame.new(camPos, best.Character.Head.Position)
        end
    end
end)

-- Anti-AFK (Dùng Idled thuần, không dùng VirtualUser để tránh kẹt Joystick)
lp.Idled:Connect(function()
    if C.AntiAFK then
        local gc = getconnections or get_signal_cons
        if gc then
            for _, conn in pairs(gc(lp.Idled)) do
                pcall(function() conn:Disable() end)
            end
        end
    end
end)

-- ESP Setup
local function setupESP(p)
    if p == lp then return end
    if p.Character then
        local hl = Instance.new("Highlight")
        hl.Name = "LH_HL"
        hl.FillColor = Color3.fromRGB(255, 50, 50)
        hl.OutlineColor = Color3.new(1,1,1)
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Enabled = C.Wallhack
        hl.Parent = p.Character
    end
    p.CharacterAdded:Connect(function(c)
        task.wait(0.5)
        local hl = Instance.new("Highlight")
        hl.Name = "LH_HL"
        hl.FillColor = Color3.fromRGB(255, 50, 50)
        hl.OutlineColor = Color3.new(1,1,1)
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Enabled = C.Wallhack
        hl.Parent = c
    end)
end
for _, p in ipairs(Players:GetPlayers()) do setupESP(p) end
Players.PlayerAdded:Connect(setupESP)

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

-- Fix Lag Live System
local lagConn = nil
local FXTypes = {ParticleEmitter=true, Trail=true, Beam=true, Sparkles=true, Fire=true, Smoke=true}
local function stripFX(o) pcall(function() if FXTypes[o.ClassName] then o.Enabled = false end end) end

_G.LH_lagOn = function()
    if lagConn then return end
    for _, o in ipairs(workspace:GetDescendants()) do stripFX(o) end
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    for _, fx in ipairs(Lighting:GetChildren()) do
        if fx:IsA("PostEffect") then fx.Enabled = false end
    end
    lagConn = workspace.DescendantAdded:Connect(function(o) task.defer(stripFX, o) end)
    C.FixLag = true
end
_G.LH_lagOff = function()
    if lagConn then lagConn:Disconnect() lagConn = nil end
    C.FixLag = false
end

-- On-Screen HUD System
local hudGUI = nil
_G.LH_HUD = function(on)
    if hudGUI then pcall(function() hudGUI:Destroy() end) hudGUI = nil end
    if not on then return end

    hudGUI = Instance.new("ScreenGui")
    hudGUI.Name = "LuckatHub_HUD"
    hudGUI.ResetOnSpawn = false
    hudGUI.ZIndexBehavior = Enum.ZIndexBehavior.Global
    local ok = pcall(function() hudGUI.Parent = CoreGui end)
    if not ok then hudGUI.Parent = lp:WaitForChild("PlayerGui") end

    local tpBtn = Instance.new("TextButton")
    tpBtn.Size = UDim2.new(0, 60, 0, 60)
    tpBtn.Position = UDim2.new(0, 20, 0, 80)
    tpBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    tpBtn.Text = "TP"
    tpBtn.TextColor3 = Color3.new(1,1,1)
    tpBtn.Font = Enum.Font.GothamBold
    tpBtn.TextSize = 14
    tpBtn.Parent = hudGUI
    Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(1, 0)

    local aimBtn = Instance.new("TextButton")
    aimBtn.Size = UDim2.new(0, 70, 0, 35)
    aimBtn.Position = UDim2.new(1, -90, 0, 80)
    aimBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 220)
    aimBtn.Text = "AIM OFF"
    aimBtn.TextColor3 = Color3.new(1,1,1)
    aimBtn.Font = Enum.Font.GothamBold
    aimBtn.TextSize = 12
    aimBtn.Parent = hudGUI
    Instance.new("UICorner", aimBtn).CornerRadius = UDim.new(0, 8)

    local locked = false
    local lockT = nil
    local followC = nil

    local function getTarget()
        local cp = camera.CFrame.Position
        local cd = camera.CFrame.LookVector
        local best, bd = nil, 0.88
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                local r = p.Character:FindFirstChild("HumanoidRootPart")
                local h = p.Character:FindFirstChildOfClass("Humanoid")
                if r and h and h.Health > 0 then
                    local d = cd:Dot((r.Position - cp).Unit)
                    if d > bd then bd = d best = p end
                end
            end
        end
        return best
    end

    local function tpTo(target)
        if not target or not target.Character then return end
        local tr = target.Character:FindFirstChild("HumanoidRootPart")
        local pr = charCache.hrp
        if tr and pr then
            pr.CFrame = CFrame.new(tr.Position + tr.CFrame.RightVector * 2.2, tr.Position)
        end
    end

    tpBtn.MouseButton1Click:Connect(function()
        if locked then
            locked = false lockT = nil
            if followC then followC:Disconnect() followC = nil end
            tpBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
            tpBtn.Text = "TP"
        else
            local t = getTarget()
            if not t then 
                tpBtn.Text = "NO TGT" 
                task.delay(1, function() if tpBtn.Parent then tpBtn.Text = "TP" end end) 
                return 
            end
            locked = true lockT = t
            tpBtn.BackgroundColor3 = Color3.fromRGB(50, 220, 80)
            tpBtn.Text = "LOCK"
            tpTo(t)
            if followC then followC:Disconnect() end
            followC = RunService.Heartbeat:Connect(function()
                if not locked or not lockT or not lockT.Character then
                    if followC then followC:Disconnect() followC = nil end
                    locked = false lockT = nil
                    if tpBtn.Parent then 
                        tpBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
                        tpBtn.Text = "TP" 
                    end
                    return
                end
                tpTo(lockT)
            end)
        end
    end)

    aimBtn.MouseButton1Click:Connect(function()
        C.Aimbot = not C.Aimbot
        aimBtn.BackgroundColor3 = C.Aimbot and Color3.fromRGB(50, 220, 80) or Color3.fromRGB(50, 50, 220)
        aimBtn.Text = C.Aimbot and "AIM ON" or "AIM OFF"
    end)
end

-- Thông báo
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "LuckatHub Mobile V11";
    Text = "Đã khởi động thành công!";
    Duration = 5;
})
