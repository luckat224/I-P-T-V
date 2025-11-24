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

-- ===========================================================================
-- CROSSHAIR CÓ THỂ KÉO ĐƯỢC (ĐÃ SỬA)
-- ===========================================================================

-- Crosshair chính (có thể kéo)
local crosshair = Instance.new("TextButton") -- Đổi thành TextButton để có thể tương tác
crosshair.Name = "Crosshair"
crosshair.Size = UDim2.new(0, 40, 0, 40) -- Kích thước lớn hơn để dễ kéo
crosshair.Position = UDim2.new(0.5, -20, 0.5, -20) -- Vị trí ban đầu ở giữa
crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
crosshair.BackgroundTransparency = 1 -- Trong suốt
crosshair.Text = "" -- Không có text
crosshair.AutoButtonColor = false
crosshair.Active = true
crosshair.Selectable = true
crosshair.Parent = gui

-- Tạo hình dạng crosshair bên trong
local crosshairContainer = Instance.new("Frame")
crosshairContainer.Size = UDim2.new(1, 0, 1, 0)
crosshairContainer.BackgroundTransparency = 1
crosshairContainer.Parent = crosshair

-- Các phần của crosshair
local crosshairLine1 = Instance.new("Frame")
crosshairLine1.Size = UDim2.new(0, 2, 0, 12)
crosshairLine1.Position = UDim2.new(0.5, -1, 0.5, -6)
crosshairLine1.AnchorPoint = Vector2.new(0.5, 0.5)
crosshairLine1.BackgroundColor3 = Color3.new(1, 1, 1)
crosshairLine1.BorderSizePixel = 0
crosshairLine1.Parent = crosshairContainer

local crosshairLine2 = Instance.new("Frame")
crosshairLine2.Size = UDim2.new(0, 12, 0, 2)
crosshairLine2.Position = UDim2.new(0.5, -6, 0.5, -1)
crosshairLine2.AnchorPoint = Vector2.new(0.5, 0.5)
crosshairLine2.BackgroundColor3 = Color3.new(1, 1, 1)
crosshairLine2.BorderSizePixel = 0
crosshairLine2.Parent = crosshairContainer

local crosshairDot = Instance.new("Frame")
crosshairDot.Size = UDim2.new(0, 2, 0, 2)
crosshairDot.Position = UDim2.new(0.5, -1, 0.5, -1)
crosshairDot.AnchorPoint = Vector2.new(0.5, 0.5)
crosshairDot.BackgroundColor3 = Color3.new(1, 0, 0)
crosshairDot.BorderSizePixel = 0
crosshairDot.Parent = crosshairContainer

-- Biến để theo dõi việc kéo
local isDraggingCrosshair = false
local dragStartPosition = nil
local crosshairStartPosition = nil

-- Sự kiện bắt đầu kéo crosshair
crosshair.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingCrosshair = true
        dragStartPosition = Vector2.new(input.Position.X, input.Position.Y)
        crosshairStartPosition = crosshair.Position
    end
end)

-- Sự kiện kéo crosshair
crosshair.InputChanged:Connect(function(input)
    if isDraggingCrosshair and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local currentPosition = Vector2.new(input.Position.X, input.Position.Y)
        local delta = currentPosition - dragStartPosition
        
        local newX = crosshairStartPosition.X.Offset + delta.X
        local newY = crosshairStartPosition.Y.Offset + delta.Y
        
        -- Giới hạn crosshair trong màn hình
        local viewportSize = camera.ViewportSize
        newX = math.clamp(newX, 20, viewportSize.X - 60)
        newY = math.clamp(newY, 20, viewportSize.Y - 60)
        
        crosshair.Position = UDim2.new(0, newX, 0, newY)
    end
end)

-- Sự kiện kết thúc kéo
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingCrosshair = false
    end
end)

-- Nút reset crosshair về vị trí giữa
local resetCrosshairButton = Instance.new("TextButton")
resetCrosshairButton.Size = UDim2.new(0, 30, 0, 30)
resetCrosshairButton.Position = UDim2.new(0.5, -15, 0, 20)
resetCrosshairButton.AnchorPoint = Vector2.new(0.5, 0)
resetCrosshairButton.Text = "↺"
resetCrosshairButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
resetCrosshairButton.TextColor3 = Color3.new(1, 1, 1)
resetCrosshairButton.TextSize = 16
resetCrosshairButton.Font = Enum.Font.GothamBold
resetCrosshairButton.BorderSizePixel = 0
resetCrosshairButton.AutoButtonColor = true
resetCrosshairButton.Visible = false -- Ẩn ban đầu
resetCrosshairButton.Parent = gui

local resetButtonCorner = Instance.new("UICorner")
resetButtonCorner.CornerRadius = UDim.new(0.5, 0)
resetButtonCorner.Parent = resetCrosshairButton

-- Hiển thị nút reset khi crosshair được di chuyển
crosshair.Changed:Connect(function(property)
    if property == "Position" then
        -- Cập nhật vị trí nút reset gần crosshair
        local crosshairPos = crosshair.Position
        resetCrosshairButton.Position = UDim2.new(
            0, crosshairPos.X.Offset + 50,
            0, crosshairPos.Y.Offset
        )
        resetCrosshairButton.Visible = true
        
        -- Ẩn nút reset sau 3 giây
        delay(3, function()
            resetCrosshairButton.Visible = false
        end)
    end
end)

resetCrosshairButton.MouseButton1Click:Connect(function()
    crosshair.Position = UDim2.new(0.5, -20, 0.5, -20)
    resetCrosshairButton.Visible = false
end)

-- ===========================================================================
-- NÚT FIRE (CẬP NHẬT SỬ DỤNG VỊ TRÍ CROSSHAIR)
-- ===========================================================================

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
-- PHẦN FIRE BUTTON (SỬ DỤNG VỊ TRÍ CROSSHAIR)
-- ===========================================================================

local function getCrosshairCenter()
    local crosshairPos = crosshair.AbsolutePosition
    local crosshairSize = crosshair.AbsoluteSize
    local centerX = crosshairPos.X + crosshairSize.X / 2
    local centerY = crosshairPos.Y + crosshairSize.Y / 2
    return centerX, centerY
end

-- Phương pháp mô phỏng click tại vị trí crosshair
local function simulateMouseClickAtCrosshair()
    local centerX, centerY = getCrosshairCenter()
    
    -- Mô phỏng nhấn chuột tại vị trí crosshair
    VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
    wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
    
    print("🔫 Đã mô phỏng click tại crosshair: " .. math.floor(centerX) .. ", " .. math.floor(centerY))
end

-- Phương pháp tìm tool weapon và kích hoạt trực tiếp
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
        -- Nếu không có tool, thử mô phỏng click chuột tại crosshair
        simulateMouseClickAtCrosshair()
    end
end

-- Khi nhấn nút Fire
fireButton.MouseButton1Click:Connect(function()
    print("🎯 Đang kích hoạt bắn súng tại vị trí crosshair...")
    activateWeapon()
    simulateMouseClickAtCrosshair()
end)

-- Thêm sự kiện chạm cho mobile
fireButton.TouchTap:Connect(function()
    print("🎯 Đang kích hoạt bắn súng tại vị trí crosshair (mobile)...")
    activateWeapon()
    simulateMouseClickAtCrosshair()
end)

-- ===========================================================================
-- PHẦN TỰ ĐỘNG BẮN KHI CÓ MỤC TIÊU
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
                    simulateMouseClickAtCrosshair()
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

-- ESP Functions
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
            wait(1)
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
    for targetPlayer, folder in pairs(espFolders) do
        folder:Destroy()
    end
    espFolders = {}
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            if otherPlayer.Character then
                createHighlight(otherPlayer.Character, otherPlayer)
            end
            
            otherPlayer.CharacterAdded:Connect(function(character)
                wait(1)
                createHighlight(character, otherPlayer)
            end)
            
            otherPlayer.CharacterRemoving:Connect(function()
                cleanupPlayerESP(otherPlayer)
            end)
        end
    end
    
    Players.PlayerAdded:Connect(function(newPlayer)
        if newPlayer ~= player then
            newPlayer.CharacterAdded:Connect(function(character)
                wait(1)
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
print("🎯 Crosshair: Có thể kéo và đặt vị trí tùy ý")
print("🔄 Reset Button: Nút ↺ để reset crosshair về giữa")
print("🔫 Fire Button: Bắn tại vị trí crosshair hiện tại")
print("🤖 Auto Shoot: Nhấn chuột phải vào nút Fire để bật/tắt")
print("📡 Wallhack: Tự động làm mới khi người chơi hồi sinh/join game")