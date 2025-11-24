-- LocalScript – đặt trong StarterPlayerScripts
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "TeleportGui"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- Crosshair (tâm ngắm)
local crosshair = Instance.new("Frame")
crosshair.Name = "Crosshair"
crosshair.Size = UDim2.new(0, 12, 0, 12)
crosshair.Position = UDim2.new(0.5, -6, 0.5, -6)
crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
crosshair.BackgroundTransparency = 1
crosshair.Parent = gui

local crosshairLine1 = Instance.new("Frame")
crosshairLine1.Size = UDim2.new(0, 2, 0, 12)
crosshairLine1.Position = UDim2.new(0.5, -1, 0.5, -6)
crosshairLine1.AnchorPoint = Vector2.new(0.5, 0.5)
crosshairLine1.BackgroundColor3 = Color3.new(1, 1, 1)
crosshairLine1.BorderSizePixel = 0
crosshairLine1.Parent = crosshair

local crosshairLine2 = Instance.new("Frame")
crosshairLine2.Size = UDim2.new(0, 12, 0, 2)
crosshairLine2.Position = UDim2.new(0.5, -6, 0.5, -1)
crosshairLine2.AnchorPoint = Vector2.new(0.5, 0.5)
crosshairLine2.BackgroundColor3 = Color3.new(1, 1, 1)
crosshairLine2.BorderSizePixel = 0
crosshairLine2.Parent = crosshair

local crosshairDot = Instance.new("Frame")
crosshairDot.Size = UDim2.new(0, 2, 0, 2)
crosshairDot.Position = UDim2.new(0.5, -1, 0.5, -1)
crosshairDot.AnchorPoint = Vector2.new(0.5, 0.5)
crosshairDot.BackgroundColor3 = Color3.new(1, 0, 0)
crosshairDot.BorderSizePixel = 0
crosshairDot.Parent = crosshair

-- Nút Fire (bắn) - ĐÃ SỬA VỊ TRÍ
local fireButton = Instance.new("TextButton")
fireButton.Size = UDim2.new(0, 80, 0, 80)
fireButton.Position = UDim2.new(1, -100, 1, -100)
fireButton.AnchorPoint = Vector2.new(0, 0)
fireButton.Text = "FIRE"
fireButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
fireButton.TextColor3 = Color3.new(1, 1, 1)
fireButton.TextSize = 16
fireButton.Font = Enum.Font.GothamBold
fireButton.BorderSizePixel = 0
fireButton.AutoButtonColor = false
fireButton.Parent = gui

local fireButtonCorner = Instance.new("UICorner")
fireButtonCorner.CornerRadius = UDim.new(1, 0)
fireButtonCorner.Parent = fireButton

-- Teleport Button
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
teleportButton.Parent = gui

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(1, 0)
buttonCorner.Parent = teleportButton

-- Aim Bot Button
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
aimButton.Parent = gui

local aimButtonCorner = Instance.new("UICorner")
aimButtonCorner.CornerRadius = UDim.new(0.3, 0)
aimButtonCorner.Parent = aimButton

-- ===========================================================================
-- PHẦN FIRE BUTTON (ĐÃ SỬA - CÁCH THỰC TẾ ĐỂ BẮN SÚNG)
-- ===========================================================================

-- Phương pháp 1: Sử dụng ContextActionService để mô phỏng nút bắn
local function simulateShooting()
    -- Thử kích hoạt action bắn súng mặc định
    ContextActionService:CallFunction("rbasset://fonts/characterActions.json", "Fire", Enum.UserInputState.Begin)
    
    -- Đợi một chút rồi kết thúc
    wait(0.1)
    ContextActionService:CallFunction("rbasset://fonts/characterActions.json", "Fire", Enum.UserInputState.End)
    
    print("🔫 Đã kích hoạt bắn súng")
end

-- Phương pháp 2: Sử dụng VirtualInput để mô phỏng click chuột
local function simulateMouseClick()
    local viewportSize = camera.ViewportSize
    local centerX = viewportSize.X / 2
    local centerY = viewportSize.Y / 2
    
    -- Mô phỏng nhấn chuột tại tâm màn hình
    VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
    wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
    
    print("🔫 Đã mô phỏng click chuột tại tâm")
end

-- Phương pháp 3: Tìm tool weapon và kích hoạt trực tiếp
local function activateWeapon()
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    -- Tìm tool đang được cầm
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then
        -- Thử kích hoạt tool
        local toolHandle = tool:FindFirstChild("Handle")
        if toolHandle then
            -- Kích hoạt sự kiện sử dụng tool
            tool:Activate()
            print("🔫 Đã kích hoạt tool: " .. tool.Name)
        end
    else
        -- Nếu không có tool, thử mô phỏng click chuột
        simulateMouseClick()
    end
end

-- Khi nhấn nút Fire
fireButton.MouseButton1Click:Connect(function()
    print("🎯 Đang kích hoạt bắn súng...")
    
    -- Thử cả 3 phương pháp
    activateWeapon()
    wait(0.1)
    simulateShooting()
    wait(0.1)
    simulateMouseClick()
end)

-- Thêm sự kiện chạm cho mobile
fireButton.TouchTap:Connect(function()
    print("🎯 Đang kích hoạt bắn súng (mobile)...")
    activateWeapon()
    wait(0.1)
    simulateShooting()
    wait(0.1)
    simulateMouseClick()
end)

-- ===========================================================================
-- PHẦN TỰ ĐỘNG BẮN KHI CÓ MỤC TIÊU (TÙY CHỌN)
-- ===========================================================================

local autoShoot = false
local shootConnection = nil

local function toggleAutoShoot()
    autoShoot = not autoShoot
    
    if autoShoot then
        fireButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        fireButton.Text = "AUTO ON"
        
        -- Tự động bắn khi có mục tiêu
        shootConnection = RunService.Heartbeat:Connect(function()
            if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("Humanoid") then
                if currentTarget.Character.Humanoid.Health > 0 then
                    activateWeapon()
                end
            end
        end)
    else
        fireButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        fireButton.Text = "FIRE"
        
        if shootConnection then
            shootConnection:Disconnect()
            shootConnection = nil
        end
    end
end

-- Nhấn giữ nút Fire để bật/tắt tự động bắn
fireButton.MouseButton2Click:Connect(toggleAutoShoot)

-- ===========================================================================
-- PHẦN WALLHACK TỰ ĐỘNG LÀM MỚI
-- ===========================================================================

local isLocked = false
local targetPlayer = nil
local currentArrow = nil
local followConnection = nil
local lastClickTime = 0
local CLICK_DELAY = 0.3

-- Trạng thái AimBot
local aimEnabled = false
local currentTarget = nil
local aimConnection = nil
local espFolders = {}
local arrowGui = nil

local wallhackEnabled = true

-- ESP Functions (đã cập nhật để tự động làm mới)
local function createEspFolder(targetPlayer)
    if espFolders[targetPlayer] then
        espFolders[targetPlayer]:Destroy()
    end
    
    local folder = Instance.new("Folder")
    folder.Name = targetPlayer.Name .. "_ESP"
    folder.Parent = playerGui
    espFolders[targetPlayer] = folder
    return folder
end

local function createHighlight(character, targetPlayer)
    if not character then return end
    
    local folder = createEspFolder(targetPlayer)
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "WallhackHighlight"
    highlight.FillColor = Color3.fromRGB(255, 50, 50)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = character
    highlight.Parent = folder
    
    -- Thêm listener để tự động cập nhật khi character thay đổi
    character.Destroying:Connect(function()
        if espFolders[targetPlayer] then
            wait(1) -- Chờ character mới load
            if targetPlayer.Character then
                createHighlight(targetPlayer.Character, targetPlayer)
            end
        end
    end)
end

local function toggleWallhack()
    wallhackEnabled = not wallhackEnabled
    
    for targetPlayer, folder in pairs(espFolders) do
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

local function cleanupPlayerESP(leavingPlayer)
    if espFolders[leavingPlayer] then
        espFolders[leavingPlayer]:Destroy()
        espFolders[leavingPlayer] = nil
    end
end

local function initializeWallhack()
    -- Dọn dẹp ESP cũ
    for targetPlayer, folder in pairs(espFolders) do
        folder:Destroy()
    end
    espFolders = {}
    
    -- Tạo ESP cho tất cả người chơi hiện tại
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            if otherPlayer.Character then
                createHighlight(otherPlayer.Character, otherPlayer)
            end
            
            -- Kết nối sự kiện khi người chơi thay đổi character (hồi sinh)
            otherPlayer.CharacterAdded:Connect(function(character)
                wait(1) -- Đợi character load hoàn toàn
                createHighlight(character, otherPlayer)
            end)
            
            -- Kết nối sự kiện khi character bị destroy (chết)
            otherPlayer.CharacterRemoving:Connect(function()
                cleanupPlayerESP(otherPlayer)
            end)
        end
    end
    
    -- Kết nối sự kiện cho người chơi mới
    Players.PlayerAdded:Connect(function(newPlayer)
        if newPlayer ~= player then
            newPlayer.CharacterAdded:Connect(function(character)
                wait(1) -- Đợi character load hoàn toàn
                createHighlight(character, newPlayer)
            end)
            
            newPlayer.CharacterRemoving:Connect(function()
                cleanupPlayerESP(newPlayer)
            end)
        end
    end)
end

-- ===========================================================================
-- PHẦN AIMBOT
-- ===========================================================================

local function showArrow(target)
    if arrowGui then arrowGui:Destroy() end
    if not target or not target.Character then return end
    local head = target.Character:FindFirstChild("Head")
    if not head then return end

    local gui = Instance.new("BillboardGui")
    gui.Name = "TargetArrow"
    gui.Size = UDim2.new(0, 50, 0, 50)
    gui.AlwaysOnTop = true
    gui.Adornee = head
    gui.MaxDistance = 500
    gui.SizeOffset = Vector2.new(0, 2.5)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "🔒"
    label.TextColor3 = Color3.fromRGB(255, 0, 0)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = gui

    gui.Parent = head
    arrowGui = gui
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
        if p ~= player and p.Character then
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

-- ===========================================================================
-- PHẦN TELEPORT
-- ===========================================================================

local function createArrow(target)
    if currentArrow then
        currentArrow:Destroy()
        currentArrow = nil
    end
    
    if not target or not target.Character then return end
    
    local head = target.Character:FindFirstChild("Head")
    if not head then return end
    
    local arrowGui = Instance.new("BillboardGui")
    arrowGui.Name = "TargetArrow"
    arrowGui.Size = UDim2.new(0, 50, 0, 50)
    arrowGui.AlwaysOnTop = true
    arrowGui.Enabled = true
    arrowGui.Adornee = head
    arrowGui.MaxDistance = 500
    arrowGui.SizeOffset = Vector2.new(0, 2.5)
    
    local arrowLabel = Instance.new("TextLabel")
    arrowLabel.Size = UDim2.new(1, 0, 1, 0)
    arrowLabel.BackgroundTransparency = 1
    arrowLabel.Text = isLocked and "🔒" or "🎯"
    arrowLabel.TextColor3 = isLocked and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
    arrowLabel.TextScaled = true
    arrowLabel.Font = Enum.Font.GothamBold
    arrowLabel.Parent = arrowGui
    
    arrowGui.Parent = head
    currentArrow = arrowGui
    
    return arrowGui
end

local function teleportClose(target)
    if not target or not target.Character then return false end
    
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    local playerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    
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
    raycastParams.FilterDescendantsInstances = {player.Character, target.Character}
    
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

local function startContinuousFollow()
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end
    
    followConnection = RunService.Heartbeat:Connect(function()
        if not isLocked then return end
        
        if targetPlayer and targetPlayer.Character then
            local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local playerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            
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

local function lockTarget()
    local newTarget = getVisibleTarget()
    
    if not newTarget then
        teleportButton.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
        teleportButton.Text = "NO TARGET"
        
        delay(1, function()
            if not isLocked then
                teleportButton.BackgroundColor3 = wallhackEnabled and Color3.fromRGB(255, 59, 59) or Color3.fromRGB(100, 100, 100)
                teleportButton.Text = "TELEPORT"
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
    if currentTime - lastClickTime < CLICK_DELAY then
        return
    end
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

-- Cleanup khi người chơi rời
Players.PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == targetPlayer then
        unlockTarget()
    end
    
    if leavingPlayer == currentTarget then
        currentTarget = nil
        removeArrow()
    end
    
    cleanupPlayerESP(leavingPlayer)
end)

player.CharacterAdded:Connect(function(character)
    wait(1)
    unlockTarget()
end)

-- Khởi tạo sau 2 giây
wait(2)
initializeWallhack()

print("✅ Teleport & Aim Bot Script Đã Sẵn Sàng!")
print("🎯 Crosshair: Tâm ngắm ở giữa màn hình")
print("🔫 Fire Button: 3 phương pháp bắn khác nhau")
print("🤖 Auto Shoot: Nhấn chuột phải vào nút Fire để bật/tắt")
print("📡 Wallhack: Tự động làm mới khi người chơi hồi sinh/join game")