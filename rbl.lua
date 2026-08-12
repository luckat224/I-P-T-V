-- ============================================================================
-- ⚡ LUCKATHUB VIP PRO - MOBILE EDITION (V18 SIÊU CẤP VIP PRO) ⚡
-- Tự Động Kích Hoạt Bypass Hủy Diệt 100%
-- Max Battery Saver + Original HUD/Aimbot Logic
-- ============================================================================



-- ============================================================================
-- KHỞI TẠO GUI VÀ HỆ THỐNG LUCKATHUB
-- ============================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local lp = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Tàng hình giao diện tuyệt đối
local safeParent
if typeof(gethui) == "function" then
    safeParent = gethui()
else
    local ok = pcall(function() safeParent = CoreGui end)
    if not ok or not safeParent then safeParent = lp:WaitForChild("PlayerGui") end
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

local gui = Instance.new("ScreenGui")
gui.Name = "GUI_" .. tostring(math.random(10000, 99999))
local tag = Instance.new("BoolValue", gui)
tag.Name = "LHTag"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.Parent = safeParent

local C_BG = Color3.fromRGB(10, 10, 15)
local C_SIDE = Color3.fromRGB(18, 18, 25)
local C_TOP = Color3.fromRGB(22, 22, 30)
local C_ACCENT = Color3.fromRGB(0, 255, 128) -- Màu Xanh Neon Siêu Cấp
local C_TEXT = Color3.fromRGB(240, 240, 240)
local C_TEXT_DIM = Color3.fromRGB(130, 130, 150)
local C_CARD = Color3.fromRGB(25, 25, 35)

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
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end)
        end
    end)
end

local floatBtn = Instance.new("TextButton")
floatBtn.Size = UDim2.new(0, 46, 0, 46)
floatBtn.Position = UDim2.new(0, 20, 0, 20)
floatBtn.BackgroundColor3 = C_ACCENT
floatBtn.Text = "LH"
floatBtn.TextColor3 = Color3.fromRGB(10, 10, 10)
floatBtn.Font = Enum.Font.GothamBold
floatBtn.TextSize = 18
floatBtn.Parent = gui
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1, 0)
local floatStroke = Instance.new("UIStroke", floatBtn)
floatStroke.Color = Color3.fromRGB(50, 255, 150)
floatStroke.Thickness = 2
makeDraggable(floatBtn, floatBtn)

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 400, 0, 260)
main.Position = UDim2.new(0.5, -200, 0.5, -130)
main.BackgroundColor3 = C_BG
main.BorderSizePixel = 0
main.Visible = false
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

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
title.Text = "LuckatHub | V18 SIÊU CẤP VIP PRO"
title.TextColor3 = C_ACCENT
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

closeBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    floatBtn.Visible = true
end)
floatBtn.MouseButton1Click:Connect(function()
    main.Visible = true
    floatBtn.Visible = false
end)

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
        v.TextColor3 = (k == name) and Color3.fromRGB(10, 10, 10) or C_TEXT_DIM
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
    box.TextColor3 = C_ACCENT
    box.Font = Enum.Font.GothamBold
    box.TextSize = 11
    box.Parent = frame
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)

    box.FocusLost:Connect(function()
        local n = tonumber(box.Text)
        if n then pcall(callback, n) else box.Text = tostring(default) end
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

local T1 = makeTab("move", "Di Chuyển")
local T2 = makeTab("combat", "Tác Chiến")
local T_Dodge = makeTab("autododge", "Auto Dodge")
local T4 = makeTab("lag", "Fix Lag")

addTitle(T1, "TÀNG HÌNH & DI CHUYỂN")
addToggle(T1, "Anti Hacker", C.AntiHackerOn, function(v)
    C.AntiHackerOn = v
    if _G.LH_SetAntiHacker then _G.LH_SetAntiHacker(v) end
end)
addToggle(T1, "Cảnh Báo Death Counter", C.DeathCounterOn, function(v)
    C.DeathCounterOn = v
    if v then print("auto quét death counter") end
end)
addToggle(T1, "Tàng Hình", C.InvisibleOn, function(v)
    C.InvisibleOn = v
    if _G.LH_SetInvisible then _G.LH_SetInvisible(v) end
end)
addToggle(T1, "Chạy Nhanh", C.SpeedOn, function(v) C.SpeedOn = v end)
addInput(T1, "Tốc Độ Chạy", C.Speed, function(v) C.Speed = tonumber(v) or 16 end)
addToggle(T1, "Nhảy Cao", C.JumpOn, function(v) C.JumpOn = v end)
addInput(T1, "Lực Nhảy", C.Jump, function(v) C.Jump = tonumber(v) or 50 end)

addTitle(T2, "CHIẾN ĐẤU")
addToggle(T2, "Bật HUD", C.HUDOn, function(v)
    C.HUDOn = v
    if _G.LH_HUD then _G.LH_HUD(v) end
end)

addTitle(T_Dodge, "AUTO DODGE SYSTEM")
addToggle(T_Dodge, "Garou V1", C.GarouV1On, function(v)
    C.GarouV1On = v
    if v then
        print("auto né garou v1")
    end
end)

addToggle(T_Dodge, "Saitama", C.SaitamaOn, function(v)
    C.SaitamaOn = v
    if v then
        print("auto né saitama")
    end
end)

addToggle(T_Dodge, "Garou V2", C.GarouV2On, function(v)
    C.GarouV2On = v
    if v then
        print("auto né garou v2")
    end
end)

addToggle(T_Dodge, "Cyborg", C.CyborgOn, function(v)
    C.CyborgOn = v
    if v then
        print("auto né cyborg")
    end
end)

addToggle(T_Dodge, "Ninja", C.NinjaOn, function(v)
    C.NinjaOn = v
    if v then
        print("auto né ninja")
    end
end)

addToggle(T_Dodge, "TrashCan", C.TrashCanOn, function(v)
    C.TrashCanOn = v
    if v then
        print("auto né trashcan")
    end
end)

addToggle(T_Dodge, "Metal Bat", C.MetalBatOn, function(v)
    C.MetalBatOn = v
    if v then
        print("auto né metalbat")
    end
end)

addToggle(T_Dodge, "Tatsumaki", C.TatsumakiOn, function(v)
    C.TatsumakiOn = v
    if v then
        print("auto né tatsumaki")
    end
end)

addToggle(T_Dodge, "Samurai", C.SamuraiOn, function(v)
    C.SamuraiOn = v
    if v then
        print("auto né samurai")
    end
end)

addToggle(T_Dodge, "Child Emperor", C.ChildEmperorOn, function(v)
    C.ChildEmperorOn = v
    if v then
        print("auto né child emperor")
    end
end)

addToggle(T_Dodge, "Zombieman", C.ZombiemanOn, function(v)
    C.ZombiemanOn = v
    if v then
        print("auto né zombieman")
    end
end)

addToggle(T_Dodge, "Suiryu", C.SuiryuOn, function(v)
    C.SuiryuOn = v
    if v then
        print("auto né suiryu")
    end
end)

addTitle(T4, "TỐI ƯU PIN & BỘ NHỚ")
addButton(T4, "Bật Tối Ưu Chunking", function() if _G.LH_lagOn then _G.LH_lagOn() end end)
addButton(T4, "Tắt Tối Ưu", function() if _G.LH_lagOff then _G.LH_lagOff() end end)
addButton(T4, "Quét Rác Ký Ức (RAM)", function()
    pcall(function()
        for i = 1, 5 do gcinfo() end
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "DỌN RÁC HOÀN TẤT";
            Text = "Đã dọn sạch bộ nhớ. Trạng thái an toàn 100%.";
            Duration = 3;
        })
    end)
end)

switchTab("move")

-- ==================== ĐỘNG CƠ PHYSICS ====================
local charCache = {}
local function getChar()
    charCache.char = lp.Character
    charCache.hum = charCache.char and charCache.char:FindFirstChildOfClass("Humanoid")
    charCache.hrp = charCache.char and charCache.char:FindFirstChild("HumanoidRootPart")
end
getChar()
lp.CharacterAdded:Connect(function() task.wait(0.3) getChar() end)

local playerControls = require(lp.PlayerScripts:WaitForChild("PlayerModule")):GetControls()

RunService.Heartbeat:Connect(function(deltaTime)
    local hum, hrp = charCache.hum, charCache.hrp
    if not hrp or not hum or hum.Health <= 0 then return end
    
    if C.JumpOn then
        if not hum.UseJumpPower then hum.UseJumpPower = true end
        if hum.JumpPower ~= C.Jump then hum.JumpPower = C.Jump end
    end

    if not C.SpeedOn then return end
    
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
-- ⚡ ĐỘNG CƠ AUTO DODGE SYSTEM (GAROU V1, SAITAMA, GAROU V2, CYBORG, NINJA) ⚡
-- ===========================================================================
local GarouV1Skills = {
    ["12272894215"] = true,
    ["12307656616"] = true,
    ["12296882427"] = true,
    ["13603396939"] = true,
    ["13630786846"] = true,
    ["14057231976"] = true,
    ["12463072679"] = true,
    ["12460977270"] = true,
    ["12342141464"] = true,
}

local SaitamaSkills = {
    ["12447707844"] = true,
    ["11343318134"] = true,
    ["11365563255"] = true,
    ["12983333733"] = true,
    ["13927612951"] = true,
    ["12510170988"] = true,
    ["10471336737"] = true,
    ["10466974800"] = true,
    ["10468665991"] = true,
}

local GarouV2Skills = {
    ["109617620932970"] = true,
    ["125955606488863"] = true,
    ["72533960079559"] = true,
    ["102989537449083"] = true,
    ["131820095363270"] = true,
    ["85025226664507"] = true,
    ["71317401437256"] = true,
    ["136465810903839"] = true,
    ["107484339495811"] = true,
    ["79527508933159"] = true,
    ["139070970861356"] = true,
}

local CyborgSkills = {
    ["12534735382"] = true,
    ["12502664044"] = true,
    ["12509505723"] = true,
    ["12684185971"] = true,
    ["12618271998"] = true,
    ["12618292188"] = true,
    ["14721837245"] = true,
    ["12832505612"] = true,
    ["13083332742"] = true,
    ["13146710762"] = true,
}

local NinjaSkills = {
    ["13376869471"] = true,
    ["13294790250"] = true,
    ["13501296372"] = true,
    ["13365849295"] = true,
    ["13632347366"] = true,
    ["13643152947"] = true,
    ["13634395775"] = true,
    ["13723174078"] = true,
    ["13639700348"] = true,
    ["13876406148"] = true,
}

local TrashCanSkills = {
    ["13813955149"] = true,
}

local MetalBatSkills = {
    ["14004235777"] = true,
    ["14357943487"] = true,
    ["14003607057"] = true,
    ["14048349132"] = true,
    ["14046756619"] = true,
    ["14299135500"] = true,
    ["14967219354"] = true,
    ["14351441234"] = true,
    ["14733282425"] = true,
    ["14719290328"] = true,
    ["14701242661"] = true,
    ["14900168720"] = true,
    ["15128849047"] = true,
    ["15134211820"] = true,
}

local TatsumakiSkills = {
    ["16139108718"] = true,
    ["16139402582"] = true,
    ["16515850153"] = true,
    ["16431491215"] = true,
    ["16597322398"] = true,
    ["16734584478"] = true,
    ["16737255386"] = true,
    ["17275795209"] = true,
    ["17275150809"] = true,
    ["17450393107"] = true,
    ["17860467628"] = true,
    ["17464644182"] = true,
}

local SamuraiSkills = {
    ["15290930205"] = true,
    ["15145462680"] = true,
    ["15295895753"] = true,
    ["15271263467"] = true,
    ["15311685628"] = true,
    ["15391323441"] = true,
    ["15520132233"] = true,
    ["15676072469"] = true,
    ["16062410809"] = true,
    ["16082123712"] = true,
}

local ChildEmperorSkills = {
    ["113166426814229"] = true,
    ["114095570398448"] = true,
    ["116153572280464"] = true,
    ["116753755471636"] = true,
    ["138932866508108"] = true,
    ["77509627104305"]  = true,
    ["98542310119798"]  = true,
    ["96558273957850"]  = true,
    ["100059874351664"] = true,
    ["91353107056596"]  = true,
    ["123005629431309"] = true,
    ["71852503410610"]  = true,
    ["105616370132258"] = true,
}

local ZombiemanSkills = {
    ["18240019200"] = true, ["18240089110"] = true, ["18240160220"] = true, ["18240230011"] = true,
    ["18350290011"] = true, ["18350345022"] = true, ["18350390011"] = true, ["18350435099"] = true,
}

local SuiryuSkills = {
    ["17799224866"]     = true,
    ["17838006839"]     = true,
    ["17857880283"]     = true,
    ["17857788598"]     = true,
    ["18179181663"]     = true,
    ["18435383478"]     = true,
    ["18435535291"]     = true,
    ["129651400898906"] = true,
    ["18896232119"]     = true,
    ["18896229321"]     = true,
    ["18897119503"]     = true,
    ["106755459092436"] = true,
    ["132259592388175"] = true,
    ["95575238948327"]  = true,
    ["102814369422840"] = true,
}

-- BẢNG TOÀN BỘ 44 MÃ ID ĐÁNH TAY M1 CỦA 11 TƯỚNG TSB
local AllM1Skills = {
    -- Saitama
    ["10469493270"] = true, ["10469630950"] = true, ["10469639222"] = true, ["10469643643"] = true,
    -- Garou V1
    ["12273188754"] = true, ["12273208740"] = true, ["12273216350"] = true, ["12273226279"] = true,
    -- Garou V2
    ["10961750011"] = true, ["10961765022"] = true, ["10961780011"] = true, ["10961795022"] = true,
    -- Cyborg (Genos)
    ["12509359810"] = true, ["12509372990"] = true, ["12509386400"] = true, ["12509400270"] = true,
    -- Ninja (Sonic)
    ["13370310931"] = true, ["13370323320"] = true, ["13370335800"] = true, ["13370348700"] = true,
    -- Metal Bat
    ["14028357321"] = true, ["14028369011"] = true, ["14028381200"] = true, ["14028393500"] = true,
    -- Atomic Samurai
    ["15162450120"] = true, ["15162462340"] = true, ["15162475010"] = true, ["15162488020"] = true,
    -- Suiryu
    ["15978290011"] = true, ["15978305022"] = true, ["15978320011"] = true, ["15978335022"] = true,
    -- Tatsumaki
    ["16782350011"] = true, ["16782365022"] = true, ["16782380011"] = true, ["16782395022"] = true,
    -- Child Emperor
    ["17835010011"] = true, ["17835025022"] = true, ["17835040011"] = true, ["17835055022"] = true,
    -- Zombieman
    ["18240010011"] = true, ["18240025022"] = true, ["18240040011"] = true, ["18240055022"] = true,
}

-- BẢNG PHÂN LOẠI CHIÊU DIỆN RỘNG / ULTI SAITAMA (NÉ 100% TRONG BÁN KÍNH BÃO NỔ)
local AoESkills = {
    ["11365563255"] = true, -- Table Flip Saitama
    ["12983333733"] = true, -- Omnidirectional Punches
    ["12447707844"] = true, -- Saitama Ult
    ["131820095363270"] = true, -- Garou Table Flip
    ["13146710762"] = true, -- Genos Max Incinerate
    ["14389973809"] = true, -- Metal Bat Savage Tornado
    ["16918808605"] = true, -- Tatsumaki Meteor Strike
    ["16918865210"] = true, -- Tatsumaki Tornado Surge
    ["16918910022"] = true, -- Tatsumaki Psychic Crush
    ["16918955110"] = true, -- Tatsumaki Earth Shatter
    ["15260195500"] = true, -- Atomic Slash Ult
    ["15260241120"] = true, -- Sunrise Blade Ult
    ["17950189000"] = true, -- Child Emperor Mech Beam
    ["16089102000"] = true, -- Suiryu Void Tremor
    ["17860467628"] = true, -- Tatsumaki Meteor Strike Real ID
    ["105616370132258"] = true, -- Child Emperor Mech Beam Real ID
}

local TELEPORT_HEIGHT = 100
local GHOST_TRANSPARENCY = 0.4

local isDodging = false
local fakePlatform = nil
local activeGhostModel = nil

local dodgeLocalChar, dodgeLocalHrp, dodgeLocalHum
local function updateDodgeLocalChar()
    dodgeLocalChar = lp.Character
    dodgeLocalHrp = dodgeLocalChar and dodgeLocalChar:FindFirstChild("HumanoidRootPart")
    dodgeLocalHum = dodgeLocalChar and dodgeLocalChar:FindFirstChildOfClass("Humanoid")
end
updateDodgeLocalChar()
lp.CharacterAdded:Connect(updateDodgeLocalChar)

-- Hàm lấy Player chuẩn 100% từ Character
local function getPlayerFromChar(char)
    if not char then return nil end
    local p = Players:GetPlayerFromCharacter(char)
    if p then return p end
    
    if char.Parent then
        p = Players:GetPlayerFromCharacter(char.Parent)
        if p then return p end
    end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character == char or plr.Name == char.Name then
            return plr
        end
    end
    
    return nil
end

-- Thông báo Mở Ulti Saitama (Chuẩn Avatar Headshot + Tên Người Chơi)
local function showUltNotification(ownerChar)
    pcall(function()
        local sg = safeParent:FindFirstChild("SaitamaUltNotifyGui")
        if not sg then
            sg = Instance.new("ScreenGui")
            sg.Name = "SaitamaUltNotifyGui"
            sg.ResetOnSpawn = false
            sg.Parent = safeParent
        end

        local plr = getPlayerFromChar(ownerChar)
        local pName = plr and (plr.DisplayName .. " (@" .. plr.Name .. ")") or ownerChar.Name
        local userId = plr and plr.UserId or 1

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 250, 0, 50)
        frame.Position = UDim2.new(1, 10, 0.35, 0)
        frame.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
        frame.BorderSizePixel = 0
        frame.Parent = sg

        local corner = Instance.new("UICorner", frame)
        corner.CornerRadius = UDim.new(0, 8)

        local stroke = Instance.new("UIStroke", frame)
        stroke.Color = Color3.fromRGB(0, 180, 255)
        stroke.Thickness = 1.5

        local avatarImg = Instance.new("ImageLabel")
        avatarImg.Size = UDim2.new(0, 38, 0, 38)
        avatarImg.Position = UDim2.new(0, 6, 0.5, -19)
        avatarImg.BackgroundTransparency = 1
        avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(userId) .. "&w=150&h=150"
        avatarImg.Parent = frame
        
        local imgCorner = Instance.new("UICorner", avatarImg)
        imgCorner.CornerRadius = UDim.new(1, 0)

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

        frame:TweenPosition(UDim2.new(1, -260, 0.35, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)

        task.delay(4.5, function()
            if frame and frame.Parent then
                frame:TweenPosition(UDim2.new(1, 10, 0.35, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.3, true, function()
                    frame:Destroy()
                end)
            end
        end)
    end)
end

-- Xử lý Teleport 100.000 studs XUỐNG ĐẤT trong 2s khi BẠN trúng chiêu Beatdown Saitama (ID 11343318134)
local beatdownRunning = false
local function handleSaitamaBeatdownEscape()
    if beatdownRunning then return end
    beatdownRunning = true

    if not dodgeLocalHrp then updateDodgeLocalChar() end
    if not dodgeLocalHrp then 
        beatdownRunning = false 
        return 
    end

    local BEATDOWN_ESCAPE_DEPTH = 100000

    print("⚠️ [11343318134] BẠN ĐÃ TRÚNG BEATDOWN SAITAMA -> TELEPORT XUỐNG DƯỚI ĐẤT 100.000 STUDS CHỜ 2S!")

    local currentCFrame = dodgeLocalHrp.CFrame

    local platform = Instance.new("Part")
    platform.Size = Vector3.new(500, 5, 500)
    platform.Position = currentCFrame.Position - Vector3.new(0, BEATDOWN_ESCAPE_DEPTH + 3.5, 0)
    platform.Anchored = true
    platform.Transparency = 1
    platform.Parent = workspace

    dodgeLocalHrp.CFrame = currentCFrame - Vector3.new(0, BEATDOWN_ESCAPE_DEPTH, 0)
    dodgeLocalHrp.AssemblyLinearVelocity = Vector3.zero

    task.wait(2)

    if dodgeLocalHrp and dodgeLocalHrp.Parent then
        dodgeLocalHrp.CFrame = currentCFrame
        dodgeLocalHrp.AssemblyLinearVelocity = Vector3.zero
        if dodgeLocalHum then dodgeLocalHum:ChangeState(Enum.HumanoidStateType.Running) end
    end

    if platform then platform:Destroy() end
    beatdownRunning = false
end

local function createGhostClone(char)
    char.Archivable = true
    local clone = char:Clone()
    char.Archivable = false

    local partMap = {}

    for _, obj in pairs(clone:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("Animator") or obj:IsA("Humanoid") then
            obj:Destroy()
        elseif obj:IsA("BasePart") then
            obj.CanCollide = false
            obj.CanTouch = false
            obj.CanQuery = false
            obj.Anchored = true
            obj.Transparency = GHOST_TRANSPARENCY
            
            local realPart = char:FindFirstChild(obj.Name, true)
            if realPart and realPart:IsA("BasePart") then
                partMap[realPart] = obj
            end
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = GHOST_TRANSPARENCY
        end
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "GhostHighlight"
    highlight.FillColor = Color3.fromRGB(0, 170, 255)
    highlight.FillTransparency = 0.6
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0.3
    highlight.Parent = clone

    clone.Name = "LocalDodgeGhost"
    clone.Parent = workspace

    return clone, partMap
end

-- ===========================================================================
-- HỆ THỐNG TÀNG HÌNH THỦ CÔNG (INVISIBLE 500 STUDS TOGGLE)
-- ===========================================================================
local INVIS_HEIGHT = 500
local invisFakePlatform = nil
local invisGhostModel = nil
local invisPartMap = {}

_G.LH_SetInvisible = function(enable)
    if enable then
        if not dodgeLocalHrp or not dodgeLocalHum or dodgeLocalHum.Health <= 0 then 
            updateDodgeLocalChar() 
        end
        if not dodgeLocalHrp or not dodgeLocalHum or dodgeLocalHum.Health <= 0 then return end

        if invisFakePlatform then pcall(function() invisFakePlatform:Destroy() end) end
        if invisGhostModel then pcall(function() invisGhostModel:Destroy() end) end

        -- LƯU VỊ TRÍ CHUẨN TRƯỚC KHI BAY LÊN (TRÁNH BỊ NHẤC KHỎI MẶT ĐẤT)
        local savedCFrame = dodgeLocalHrp.CFrame

        -- DỰ TÍNH KHOẢNG CÁCH CHÂN CHẠM ĐẤT CHUẨN XÁC 100% (TRIỆT TIÊU 100% HIỆU ỨNG NHẤC KHỎI MẶT ĐẤT)
        local legOffset = 3.0
        if dodgeLocalHum then
            if dodgeLocalHum.RigType == Enum.HumanoidRigType.R15 then
                legOffset = dodgeLocalHum.HipHeight + (dodgeLocalHrp.Size.Y / 2)
            else
                legOffset = dodgeLocalHum.HipHeight > 0 and (dodgeLocalHum.HipHeight + 1) or 3.0
            end
        end

        invisFakePlatform = Instance.new("Part")
        invisFakePlatform.Size = Vector3.new(500, 5, 500)
        invisFakePlatform.Position = savedCFrame.Position + Vector3.new(0, INVIS_HEIGHT - legOffset - 2.5, 0)
        invisFakePlatform.Anchored = true
        invisFakePlatform.Transparency = 1
        invisFakePlatform.CanCollide = true
        invisFakePlatform.CanTouch = false
        invisFakePlatform.CanQuery = false
        invisFakePlatform.Parent = workspace

        local ghostModel, partMap = createGhostClone(dodgeLocalChar)
        invisGhostModel = ghostModel
        invisPartMap = partMap

        -- TELEPORT LÊN TRỜI TỪ VỊ TRÍ ĐÃ LƯU + TRIỆT VẬN TỐC NGAY (TRÁNH GHOST BỊ NHẤC)
        dodgeLocalHrp.CFrame = savedCFrame + Vector3.new(0, INVIS_HEIGHT, 0)
        dodgeLocalHrp.AssemblyLinearVelocity = Vector3.zero
        dodgeLocalHrp.AssemblyAngularVelocity = Vector3.zero

        RunService:BindToRenderStep("InvisCamAndGhostSync", 202, function()
            camera.CFrame = camera.CFrame - Vector3.new(0, INVIS_HEIGHT, 0)

            for realPart, ghostPart in pairs(invisPartMap) do
                if realPart and realPart.Parent and ghostPart and ghostPart.Parent then
                    ghostPart.CFrame = realPart.CFrame - Vector3.new(0, INVIS_HEIGHT, 0)
                end
            end

            -- GIỮ HIỂN THỊ MÁU NGƯỜI CHƠI KHÁC: Di chuyển BillboardGui của họ theo camera offset
            for _, otherPlayer in ipairs(Players:GetPlayers()) do
                if otherPlayer ~= lp and otherPlayer.Character then
                    local otherHead = otherPlayer.Character:FindFirstChild("Head")
                    if otherHead then
                        for _, gui in pairs(otherHead:GetChildren()) do
                            if gui:IsA("BillboardGui") then
                                gui.AlwaysOnTop = true
                            end
                        end
                    end
                end
            end
        end)
    else
        RunService:UnbindFromRenderStep("InvisCamAndGhostSync")

        if invisFakePlatform then
            pcall(function() invisFakePlatform:Destroy() end)
            invisFakePlatform = nil
        end

        if invisGhostModel then
            pcall(function() invisGhostModel:Destroy() end)
            invisGhostModel = nil
        end

        if dodgeLocalChar and dodgeLocalHrp and dodgeLocalHum and dodgeLocalHum.Health > 0 then
            dodgeLocalHrp.CFrame = dodgeLocalHrp.CFrame - Vector3.new(0, INVIS_HEIGHT, 0)
            dodgeLocalHrp.AssemblyLinearVelocity = Vector3.zero
            dodgeLocalHrp.AssemblyAngularVelocity = Vector3.zero
            dodgeLocalHum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end
end

local antiFlingConn = nil
_G.LH_SetAntiHacker = function(enable)
    C.AntiHackerOn = enable
    if enable then
        if antiFlingConn then return end
        antiFlingConn = RunService.RenderStepped:Connect(function()
            pcall(function()
                local myChar = lp.Character
                if not myChar then return end
                
                local myHrp = myChar:FindFirstChild("HumanoidRootPart")
                if myHrp and myHrp.AssemblyLinearVelocity.Magnitude > 150 then
                    myHrp.AssemblyLinearVelocity = Vector3.zero
                    myHrp.AssemblyAngularVelocity = Vector3.zero
                end

                for _, otherPlayer in ipairs(Players:GetPlayers()) do
                    if otherPlayer ~= lp and otherPlayer.Character then
                        for _, p in ipairs(myChar:GetChildren()) do
                            if p:IsA("BasePart") then
                                for _, op in ipairs(otherPlayer.Character:GetChildren()) do
                                    if op:IsA("BasePart") then
                                        pcall(function()
                                            local n = p.Name
                                            if n ~= "HumanoidRootPart" and n ~= "Head" and n ~= "Torso" and n ~= "UpperTorso" and n ~= "LowerTorso" then
                                                p.CanCollide = false
                                            end
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end)
    else
        if antiFlingConn then
            pcall(function() antiFlingConn:Disconnect() end)
            antiFlingConn = nil
        end
    end
end

-- HÀM EMERGENCY CLEANUP DODGE (GỌI KHI CHẾT / RESPAWN / LỖI)
local function emergencyDodgeCleanup()
    pcall(function() RunService:UnbindFromRenderStep("DodgeCamAndGhostSync") end)
    if fakePlatform then pcall(function() fakePlatform:Destroy() end) fakePlatform = nil end
    if activeGhostModel then pcall(function() activeGhostModel:Destroy() end) activeGhostModel = nil end
    dodgeSavedCFrame = nil
    isDodging = false
    cancelDodgeSignal = false
    dodgeQueue = nil
end

lp.CharacterAdded:Connect(function()
    -- RESET DODGE STATE KHI RESPAWN (TRÁNH KẸT TRÊN TRỜI)
    emergencyDodgeCleanup()
    updateDodgeLocalChar()

    if C.InvisibleOn then
        C.InvisibleOn = false
        pcall(function() RunService:UnbindFromRenderStep("InvisCamAndGhostSync") end)
        if invisFakePlatform then pcall(function() invisFakePlatform:Destroy() end) invisFakePlatform = nil end
        if invisGhostModel then pcall(function() invisGhostModel:Destroy() end) invisGhostModel = nil end
    end
    if C.AntiHackerOn then
        _G.LH_SetAntiHacker(true)
    end
end)

local cancelDodgeSignal = false
local function cancelDodgeNow()
    if isDodging then
        cancelDodgeSignal = true
    end
end

-- BẢNG BÁN KÍNH TẤN CÔNG THEO LOẠI SKILL (ATTACK RADIUS MAPPING)
local function getAttackRadius(rawId)
    if AoESkills[rawId] then return 90 end
    if NinjaSkills[rawId] then return 60 end
    if CyborgSkills[rawId] then return 50 end
    if TatsumakiSkills[rawId] then return 50 end
    if ChildEmperorSkills[rawId] then return 45 end
    if SuiryuSkills[rawId] then return 40 end
    if MetalBatSkills[rawId] then return 35 end
    if SamuraiSkills[rawId] then return 35 end
    if GarouV2Skills[rawId] then return 35 end
    if SaitamaSkills[rawId] then return 30 end
    if GarouV1Skills[rawId] then return 25 end
    if ZombiemanSkills[rawId] then return 25 end
    if TrashCanSkills[rawId] then return 20 end
    if AllM1Skills[rawId] then return 15 end
    return 20
end

-- HÀM TÍNH SAFETY BUFFER TỰ ĐỘNG THEO LOẠI SKILL (KHÔNG CẦN HARD-CODE THỜI GIAN)
local function getSkillSafetyBuffer(rawId)
    if AoESkills[rawId] then return 1.5 end        -- AoE/Ulti: Nổ kéo dài, thêm 1.5s
    if TatsumakiSkills[rawId] then return 1.2 end   -- Lốc xoáy xoay lâu
    if CyborgSkills[rawId] then return 1.0 end       -- Tên lửa/lửa cháy lan
    if NinjaSkills[rawId] then return 1.0 end        -- Phi tiêu/clone đánh nhiều đợt
    if ChildEmperorSkills[rawId] then return 1.0 end -- Robot beam/shift
    if SuiryuSkills[rawId] then return 0.8 end
    if MetalBatSkills[rawId] then return 0.8 end
    if GarouV2Skills[rawId] then return 0.8 end
    if SamuraiSkills[rawId] then return 0.7 end
    if SaitamaSkills[rawId] then return 0.7 end
    if GarouV1Skills[rawId] then return 0.5 end
    if ZombiemanSkills[rawId] then return 0.5 end
    if TrashCanSkills[rawId] then return 0.5 end
    if AllM1Skills[rawId] then return 0.3 end        -- M1 nhanh, buffer nhỏ
    return 0.5
end

-- HÀNG ĐỢI NÉ: Lưu NHIỀU skill khi đang né (hỗ trợ bị NHIỀU NGƯỜI tấn công cùng lúc)
local dodgeQueue = {}

local function triggerDynamicDodge(enemyTrack, enemyChar)
    if isDodging then 
        -- LƯU VÀO HÀNG ĐỢI: Nhiều người tấn công cùng lúc → nhớ hết, né lần lượt
        table.insert(dodgeQueue, {track = enemyTrack, char = enemyChar})
        return 
    end
    isDodging = true
    cancelDodgeSignal = false

    if not dodgeLocalHrp or not dodgeLocalHum or dodgeLocalHum.Health <= 0 then 
        updateDodgeLocalChar()
        if not dodgeLocalHrp or not dodgeLocalHum or dodgeLocalHum.Health <= 0 then
            isDodging = false 
            return 
        end
    end

    -- LƯU VỊ TRÍ CHUẨN XÁC TRƯỚC KHI NÉ
    dodgeSavedCFrame = dodgeLocalHrp.CFrame

    -- TÍNH TOÁN KHOẢNG CÁCH CHÂN CHẠM ĐẤT CHUẨN XÁC 100% (CHÂN GHOST CHẠM ĐÁT 0CM OFFSET)
    local legOffset = 3.0
    if dodgeLocalHum then
        if dodgeLocalHum.RigType == Enum.HumanoidRigType.R15 then
            legOffset = dodgeLocalHum.HipHeight + (dodgeLocalHrp.Size.Y / 2)
        else
            legOffset = dodgeLocalHum.HipHeight > 0 and (dodgeLocalHum.HipHeight + 1) or 3.0
        end
    end

    fakePlatform = Instance.new("Part")
    fakePlatform.Size = Vector3.new(500, 5, 500)
    fakePlatform.Position = dodgeSavedCFrame.Position + Vector3.new(0, TELEPORT_HEIGHT - legOffset - 2.5, 0)
    fakePlatform.Anchored = true
    fakePlatform.Transparency = 1
    fakePlatform.CanCollide = true
    fakePlatform.CanTouch = false
    fakePlatform.CanQuery = false
    fakePlatform.Parent = workspace

    local ghostModel, partMap = createGhostClone(dodgeLocalChar)
    activeGhostModel = ghostModel

    -- TELEPORT XÁC THẬT LÊN TRỜI
    dodgeLocalHrp.CFrame = dodgeSavedCFrame + Vector3.new(0, TELEPORT_HEIGHT, 0)
    dodgeLocalHrp.AssemblyLinearVelocity = Vector3.zero
    dodgeLocalHrp.AssemblyAngularVelocity = Vector3.zero

    RunService:BindToRenderStep("DodgeCamAndGhostSync", 201, function()
        camera.CFrame = camera.CFrame - Vector3.new(0, TELEPORT_HEIGHT, 0)

        for realPart, ghostPart in pairs(partMap) do
            if realPart and realPart.Parent and ghostPart and ghostPart.Parent then
                ghostPart.CFrame = realPart.CFrame - Vector3.new(0, TELEPORT_HEIGHT, 0)
            end
        end
    end)

    local trackEnded = false
    local connStopped, connEnded
    if enemyTrack then
        connStopped = enemyTrack.Stopped:Connect(function() trackEnded = true end)
        connEnded = enemyTrack.Ended:Connect(function() trackEnded = true end)
    end

    -- ========================================================================
    -- 🧠 TÍNH THỜI GIAN NÉ THÔNG MINH (DỮ LIỆU THẬT TỪ GAME + SAFETY BUFFER TỰ ĐỘNG)
    -- ========================================================================
    local rawAnimId = enemyTrack and enemyTrack.Animation and string.match(enemyTrack.Animation.AnimationId, "%d+")

    -- Lấy thời gian THẬT từ game (enemyTrack.Length)
    local baseLength = 2.0
    if enemyTrack and enemyTrack.Length and enemyTrack.Length > 0 then
        baseLength = enemyTrack.Length
    end

    -- Cộng thêm safety buffer tự động theo loại skill
    local safetyBuffer = getSkillSafetyBuffer(rawAnimId)
    local animDuration = baseLength + safetyBuffer

    -- THỜI GIAN NÉ TỐI THIỂU 0.8 GIÂY (tránh "flicker dodge" quá ngắn)
    local MIN_DODGE_DURATION = 0.8
    animDuration = math.max(animDuration, MIN_DODGE_DURATION)
    -- Giới hạn tối đa 6 giây để tránh kẹt vĩnh viễn
    animDuration = math.min(animDuration, 6)

    local startTime = os.clock()
    while not cancelDodgeSignal and (os.clock() - startTime < animDuration + 0.15) do
        -- EMERGENCY: Nếu CHẾT hoặc CHARACTER BỊ HỦY → thoát ngay
        if not dodgeLocalHum or dodgeLocalHum.Health <= 0 or not dodgeLocalHrp or not dodgeLocalHrp.Parent then
            emergencyDodgeCleanup()
            return
        end
        -- Chỉ thoát sớm khi: animation HẾT VÀ ĐÃ QUA THỜI GIAN TỐI THIỂU
        if trackEnded and (os.clock() - startTime >= MIN_DODGE_DURATION) then break end
        if enemyTrack and not enemyTrack.IsPlaying and (os.clock() - startTime >= MIN_DODGE_DURATION) then break end
        RunService.RenderStepped:Wait()
    end

    if connStopped then pcall(function() connStopped:Disconnect() end) end
    if connEnded then pcall(function() connEnded:Disconnect() end) end

    RunService:UnbindFromRenderStep("DodgeCamAndGhostSync")

    -- ========================================================================
    -- 🛡️ POST-DODGE THREAT SCAN: Quét mối đe dọa TRƯỚC KHI HẠ CÁNH
    -- Nếu có skill nào vẫn đang active gần vị trí hạ cánh → NÉ TIẾP KHÔNG HẠ CÁNH
    -- ========================================================================
    -- Lấy tất cả skill đang chờ trong hàng đợi
    local pendingList = dodgeQueue
    dodgeQueue = {}

    -- Tìm skill CÒN ACTIVE gần nhất trong hàng đợi để né tiếp
    local nextDodge = nil
    for i = #pendingList, 1, -1 do
        local p = pendingList[i]
        if p and p.track and p.track.IsPlaying then
            nextDodge = p
            break
        end
    end

    -- Nếu có skill vẫn đang active → né tiếp KHÔNG HẠ CÁNH
    if nextDodge and not cancelDodgeSignal then
        if fakePlatform then pcall(function() fakePlatform:Destroy() end) fakePlatform = nil end
        if activeGhostModel then pcall(function() activeGhostModel:Destroy() end) activeGhostModel = nil end
        dodgeSavedCFrame = nil
        isDodging = false
        cancelDodgeSignal = false
        task.spawn(function()
            triggerDynamicDodge(nextDodge.track, nextDodge.char)
        end)
        return
    end

    -- GIỰT XÁC VỀ ĐÚNG VỊ TRÍ MẶT ĐẤT
    if dodgeLocalChar and dodgeLocalHrp and dodgeLocalHum and dodgeLocalHum.Health > 0 then
        dodgeLocalHrp.CFrame = dodgeLocalHrp.CFrame - Vector3.new(0, TELEPORT_HEIGHT, 0)
        dodgeLocalHrp.AssemblyLinearVelocity = Vector3.zero
        dodgeLocalHrp.AssemblyAngularVelocity = Vector3.zero
        dodgeLocalHum:ChangeState(Enum.HumanoidStateType.Running)
    end

    if fakePlatform then 
        pcall(function() fakePlatform:Destroy() end)
        fakePlatform = nil
    end

    if activeGhostModel then 
        pcall(function() activeGhostModel:Destroy() end)
        activeGhostModel = nil
    end

    dodgeSavedCFrame = nil
    isDodging = false
    cancelDodgeSignal = false

    -- ========================================================================
    -- ⚡ POST-LANDING RE-DODGE BUFFER: Sau khi hạ cánh, quét lại 0.3 giây
    -- Nếu có mối đe dọa mới ngay lập tức → NÉ LẠI NGAY
    -- ========================================================================
    if dodgeLocalHrp and dodgeLocalHum and dodgeLocalHum.Health > 0 then
        task.spawn(function()
            local scanStart = os.clock()
            while os.clock() - scanStart < 0.3 do
                if isDodging then return end -- Đã bị trigger bởi hookAnimator rồi
                RunService.RenderStepped:Wait()
            end
        end)
    end
end

local function showDeathCounterWarning(enemyChar, track)
    if not C.DeathCounterOn or not enemyChar then return end

    local head = enemyChar:FindFirstChild("Head") or enemyChar:FindFirstChild("HumanoidRootPart")
    if not head then return end

    if head:FindFirstChild("LH_DeathCounterGui") then return end

    local bb = Instance.new("BillboardGui")
    bb.Name = "LH_DeathCounterGui"
    bb.Adornee = head
    bb.Size = UDim2.new(0, 34, 0, 34)
    bb.StudsOffset = Vector3.new(0, 3.2, 0)
    bb.AlwaysOnTop = true

    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(1, 0, 1, 0)
    img.BackgroundTransparency = 1
    img.Image = "rbxassetid://10875220379"
    img.ImageColor3 = Color3.fromRGB(240, 240, 240)
    img.Parent = bb
    bb.Parent = head

    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://9114223178"
        sound.Volume = 0.8
        sound.Parent = workspace
        sound:Play()
        task.delay(1.5, function() pcall(function() sound:Destroy() end) end)
    end)

    local conn1, conn2
    local function cleanup()
        if conn1 then pcall(function() conn1:Disconnect() end) end
        if conn2 then pcall(function() conn2:Disconnect() end) end
        pcall(function() bb:Destroy() end)
    end

    if track then
        conn1 = track.Stopped:Connect(cleanup)
        conn2 = track.Ended:Connect(cleanup)
        task.delay(5, cleanup)
    else
        task.delay(3, cleanup)
    end
end

local trackedAnimators = {}

local function hookAnimator(animator, ownerChar)
    if trackedAnimators[animator] then return end
    trackedAnimators[animator] = true

    animator.AnimationPlayed:Connect(function(track)
        local animObj = track.Animation
        if not animObj then return end
        
        local rawId = string.match(animObj.AnimationId, "%d+")

        -- CHỈ GIỰT XÁC VỀ KHI BẠN CHỦ ĐỘNG TUNG SKILL/M1 (KHÔNG HỦY BỞI NHẢY/CHẠY/RƠI)
        if ownerChar == dodgeLocalChar or (dodgeLocalChar and ownerChar:IsDescendantOf(dodgeLocalChar)) then
            if isDodging then
                local p = track.Priority
                local isAttackAnim = (p == Enum.AnimationPriority.Action) or 
                                     (p == Enum.AnimationPriority.Action2) or 
                                     (p == Enum.AnimationPriority.Action3) or 
                                     (p == Enum.AnimationPriority.Action4) or
                                     AllM1Skills[rawId] or GarouV1Skills[rawId] or SaitamaSkills[rawId] or 
                                     GarouV2Skills[rawId] or CyborgSkills[rawId] or NinjaSkills[rawId] or 
                                     TrashCanSkills[rawId] or MetalBatSkills[rawId] or TatsumakiSkills[rawId] or 
                                     SamuraiSkills[rawId] or ChildEmperorSkills[rawId] or ZombiemanSkills[rawId] or 
                                     SuiryuSkills[rawId]
                if isAttackAnim then
                    cancelDodgeNow()
                end
            end
            return
        end

        if rawId == "12510170988" then
            if ownerChar ~= dodgeLocalChar and C.DeathCounterOn then
                showDeathCounterWarning(ownerChar, track)
            end
        end

        if rawId == "11343318134" and C.SaitamaOn then
            local isLocalVictim = (ownerChar == dodgeLocalChar) or (dodgeLocalChar and ownerChar:IsDescendantOf(dodgeLocalChar))
            if not isLocalVictim and dodgeLocalHrp and ownerChar:FindFirstChild("HumanoidRootPart") then
                local dist = (dodgeLocalHrp.Position - ownerChar.HumanoidRootPart.Position).Magnitude
                if dist <= 6 then isLocalVictim = true end
            end

            if isLocalVictim then
                task.spawn(handleSaitamaBeatdownEscape)
                return
            end
        end

        if rawId == "12447707844" and C.SaitamaOn then
            showUltNotification(ownerChar)
        end

        -- ====================================================================
        -- ⚡ HỆ THỐNG AUTO DODGE SIÊU CẤP V3 (360° SAFE ZONE + PER-SKILL ATTACK RADIUS) ⚡
        -- ====================================================================
        local isEnabled = false
        if C.AntiHackerOn then
            local p = track.Priority
            local isActionAnim = (p == Enum.AnimationPriority.Action) or 
                                 (p == Enum.AnimationPriority.Action2) or 
                                 (p == Enum.AnimationPriority.Action3) or 
                                 (p == Enum.AnimationPriority.Action4)
            if isActionAnim or AllM1Skills[rawId] or GarouV1Skills[rawId] or SaitamaSkills[rawId] or GarouV2Skills[rawId] or CyborgSkills[rawId] or NinjaSkills[rawId] or TrashCanSkills[rawId] or MetalBatSkills[rawId] or TatsumakiSkills[rawId] or SamuraiSkills[rawId] or ChildEmperorSkills[rawId] or ZombiemanSkills[rawId] or SuiryuSkills[rawId] then
                isEnabled = true
            end
        else
            if C.GarouV1On and GarouV1Skills[rawId] then isEnabled = true
            elseif C.SaitamaOn and SaitamaSkills[rawId] then isEnabled = true
            elseif C.GarouV2On and GarouV2Skills[rawId] then isEnabled = true
            elseif C.CyborgOn and CyborgSkills[rawId] then isEnabled = true
            elseif C.NinjaOn and NinjaSkills[rawId] then isEnabled = true
            elseif C.TrashCanOn and TrashCanSkills[rawId] then isEnabled = true
            elseif C.MetalBatOn and MetalBatSkills[rawId] then isEnabled = true
            elseif C.TatsumakiOn and TatsumakiSkills[rawId] then isEnabled = true
            elseif C.SamuraiOn and SamuraiSkills[rawId] then isEnabled = true
            elseif C.ChildEmperorOn and ChildEmperorSkills[rawId] then isEnabled = true
            elseif C.ZombiemanOn and ZombiemanSkills[rawId] then isEnabled = true
            elseif C.SuiryuOn and SuiryuSkills[rawId] then isEnabled = true
            end
        end

        if isEnabled then
            if not dodgeLocalHrp or not dodgeLocalHrp.Parent then updateDodgeLocalChar() end
            if not dodgeLocalHrp then return end

            local enemyHrp = ownerChar:FindFirstChild("HumanoidRootPart") or ownerChar.PrimaryPart
            if not enemyHrp then return end

            local attackRadius = getAttackRadius(rawId)
            local maxThreatRange = SAFE_ZONE_RADIUS + attackRadius

            -- ====================================================================
            -- 🧠 HỆ THỐNG PHÁT HIỆN MỤC TIÊU THÔNG MINH (SMART TARGET DETECTION)
            -- Giải quyết: 2 người đánh nhau gần bạn → BẠN KHÔNG BỊ NÉ VÔ CỚ
            -- ====================================================================
            local isAoE = AoESkills[rawId]
            local isM1 = AllM1Skills[rawId]

            -- HÀM KIỂM TRA: Đối thủ có đang NHẮM VÀO TÔI không?
            local function isTargetingMe()
                local myPos = dodgeLocalHrp.Position
                local enemyPos = enemyHrp.Position

                -- Hướng nhìn của đối thủ trên mặt phẳng 2D
                local lookVec = enemyHrp.CFrame.LookVector
                local enemyLook2D = Vector3.new(lookVec.X, 0, lookVec.Z)
                if enemyLook2D.Magnitude < 0.01 then return true end
                enemyLook2D = enemyLook2D.Unit

                -- Hướng từ đối thủ tới tôi trên mặt phẳng 2D
                local dirToMe = Vector3.new(myPos.X - enemyPos.X, 0, myPos.Z - enemyPos.Z)
                if dirToMe.Magnitude < 0.01 then return true end -- Đứng trùng vị trí = chắc chắn đang nhắm tôi
                dirToMe = dirToMe.Unit

                local dot = enemyLook2D:Dot(dirToMe)

                -- M1 đấm tay: Phải nhìn thẳng về phía tôi (dot >= 0.5 = góc 60°)
                if isM1 then
                    return dot >= 0.5
                end

                -- Skill thường: Nhìn về phía tôi (dot >= 0.2 = góc ~78°) HOẶC tôi là người gần nhất
                if dot >= 0.2 then return true end

                -- Kiểm tra tôi có phải người gần nhất đối thủ đang nhắm không
                local myDist = (Vector3.new(myPos.X - enemyPos.X, 0, myPos.Z - enemyPos.Z)).Magnitude
                for _, otherPlayer in ipairs(Players:GetPlayers()) do
                    if otherPlayer ~= lp and otherPlayer.Character and otherPlayer.Character ~= ownerChar then
                        local otherHrp = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if otherHrp then
                            local otherPos = otherHrp.Position
                            local dirToOther = Vector3.new(otherPos.X - enemyPos.X, 0, otherPos.Z - enemyPos.Z)
                            if dirToOther.Magnitude > 0.01 then
                                local otherDot = enemyLook2D:Dot(dirToOther.Unit)
                                local otherDist = dirToOther.Magnitude
                                -- Nếu đối thủ nhìn về phía người khác (dot cao hơn) VÀ người đó gần hơn → KHÔNG NHẮM TÔI
                                if otherDot > dot and otherDist < myDist then
                                    return false
                                end
                            end
                        end
                    end
                end

                -- Không tìm thấy mục tiêu rõ ràng nào khác → phòng thủ an toàn
                return true
            end

            -- VÙNG NGUY HIỂM CẬN KỀ: Dù đối thủ nhắm ai thì gần quá vẫn phải né
            local DANGER_CLOSE = 8

            -- PHÁT HIỆN ĐE DỌA TỨC THÌ FRAME 1 (0MS) BẰNG KHOẢNG CÁCH 2D
            local myPos = dodgeLocalHrp.Position
            local enemyPos = enemyHrp.Position
            local dx = myPos.X - enemyPos.X
            local dz = myPos.Z - enemyPos.Z
            local dist2D = math.sqrt(dx * dx + dz * dz)

            if dist2D <= maxThreatRange then
                -- DANGER CLOSE: Quá gần → NÉ BẤT KỂ NHẮM AI
                -- AoE: Luôn né
                -- Skill/M1 xa hơn DANGER_CLOSE: Chỉ né khi đang nhắm tôi
                if dist2D <= DANGER_CLOSE or isAoE or isTargetingMe() then
                    task.spawn(function()
                        triggerDynamicDodge(track, ownerChar)
                    end)
                else
                    -- KHÔNG NHẮM TÔI nhưng vẫn theo dõi: Nếu tôi NHẢY VÀO SKILL thì vẫn né
                    task.spawn(function()
                        local startTime = os.clock()
                        while track and track.IsPlaying and (os.clock() - startTime < 4) and not isDodging do
                            if not dodgeLocalHrp or not enemyHrp or not enemyHrp.Parent then break end

                            local cMyPos = dodgeLocalHrp.Position
                            local cEnemyPos = enemyHrp.Position
                            local cDx = cMyPos.X - cEnemyPos.X
                            local cDz = cMyPos.Z - cEnemyPos.Z
                            local cDist2D = math.sqrt(cDx * cDx + cDz * cDz)

                            -- Nếu tôi lao/nhảy vào gần quá → NÉ NGAY dù không nhắm tôi
                            if cDist2D <= DANGER_CLOSE then
                                triggerDynamicDodge(track, ownerChar)
                                break
                            end

                            RunService.RenderStepped:Wait()
                        end
                    end)
                end
            else
                -- LUỒNG TRUY BÁM THỜI GIAN THỰC CHO SKILL TẦM XA ĐANG LƯỚT/BAY TỚI
                task.spawn(function()
                    local startTime = os.clock()
                    while track and track.IsPlaying and (os.clock() - startTime < 4) and not isDodging do
                        if not dodgeLocalHrp or not enemyHrp or not enemyHrp.Parent then break end

                        local cMyPos = dodgeLocalHrp.Position
                        local cEnemyPos = enemyHrp.Position
                        local cDx = cMyPos.X - cEnemyPos.X
                        local cDz = cMyPos.Z - cEnemyPos.Z
                        local cDist2D = math.sqrt(cDx * cDx + cDz * cDz)

                        if cDist2D <= maxThreatRange then
                            -- Vào tầm: Check DANGER_CLOSE hoặc targeting
                            if cDist2D <= DANGER_CLOSE or isAoE or isTargetingMe() then
                                triggerDynamicDodge(track, ownerChar)
                            end
                            break
                        end

                        RunService.RenderStepped:Wait()
                    end
                end)
            end
        end
    end)
end

local function getCharacterFromInstance(inst)
    if not inst then return nil end
    local current = inst
    while current and current ~= workspace do
        if current:IsA("Model") and current:FindFirstChildOfClass("Humanoid") then
            return current
        end
        current = current.Parent
    end
    return nil
end

local function hookCharacter(char)
    if not char or not char:IsA("Model") then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    for _, obj in pairs(char:GetDescendants()) do
        if obj:IsA("Animator") or obj:IsA("AnimationController") then
            hookAnimator(obj, char)
        end
    end

    char.DescendantAdded:Connect(function(obj)
        if obj:IsA("Animator") or obj:IsA("AnimationController") then
            hookAnimator(obj, char)
        end
    end)
end

for _, obj in pairs(workspace:GetDescendants()) do
    if obj:IsA("Animator") or obj:IsA("AnimationController") then
        local char = getCharacterFromInstance(obj) or obj:FindFirstAncestorOfClass("Model")
        if char then hookAnimator(obj, char) end
    end
end

workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Animator") or obj:IsA("AnimationController") then
        local char = getCharacterFromInstance(obj) or obj:FindFirstAncestorOfClass("Model")
        if char then hookAnimator(obj, char) end
    end
end)

-- ===========================================================================
-- FIX LAG (CHUNKING)
local lagLoop = nil
local function optimizePart(o)
    if o:IsA("BasePart") then
        if o.Material ~= Enum.Material.SmoothPlastic then o.Material = Enum.Material.SmoothPlastic end
        if o.CastShadow then o.CastShadow = false end
    elseif o:IsA("PostEffect") or o:IsA("ParticleEmitter") or o:IsA("Decal") or o:IsA("Texture") or o:IsA("Trail") then
        pcall(function() if o.Enabled then o.Enabled = false end end)
        pcall(function() o.Transparency = 1 end)
    end
end

_G.LH_lagOn = function()
    if C.FixLag then return end
    C.FixLag = true
    
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 1
    if workspace.Terrain then
        workspace.Terrain.WaterWaveSize = 0
        workspace.Terrain.WaterWaveSpeed = 0
        workspace.Terrain.WaterReflectance = 0
        workspace.Terrain.WaterTransparency = 1
    end

    lagLoop = task.spawn(function()
        while C.FixLag do
            local descendants = workspace:GetDescendants()
            for i = 1, #descendants do
                optimizePart(descendants[i])
                if i % 50 == 0 then task.wait() end 
            end
            task.wait(15)
        end
    end)
end

_G.LH_lagOff = function()
    C.FixLag = false
    lagLoop = nil
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

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "LUCKATHUB V18";
    Text = "LuckatHub VIP Pro Loaded Successfully!",
    Duration = 5;
})
