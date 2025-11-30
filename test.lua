-- LocalScript – đặt trong StarterPlayerScripts
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Teams = game:GetService("Teams")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "TeleportGui"
gui.ResetOnSpawn = false
gui.Parent = playerGui

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
-- AIMBOT THÔNG MINH NÂNG CAO
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

-- Cấu hình Aimbot
local AIMBOT_CONFIG = {
    FOV = 120, -- Góc nhìn (độ)
    MAX_DISTANCE = 500, -- Khoảng cách tối đa
    SMOOTHING = 0.15, -- Độ mượt (0-1, càng nhỏ càng mượt)
    PREDICTION = true, -- Dự đoán chuyển động
    HEAD_PRIORITY = true, -- Ưu tiên headshot
    VISIBILITY_CHECK = true, -- Kiểm tra tầm nhìn
    THREAT_PRIORITY = true -- Ưu tiên mục tiêu nguy hiểm
}

-- Hàm kiểm tra team (đồng đội hay địch)
local function isEnemy(targetPlayer)
    if not player.Team then return true end
    if not targetPlayer.Team then return true end
    return player.Team ~= targetPlayer.Team
end

-- Hàm kiểm tra vật cản với độ chính xác cao
local function hasClearLineOfSight(pointA, pointB, ignoreList)
    local direction = (pointB - pointA)
    local distance = direction.Magnitude
    direction = direction.Unit
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = ignoreList or {}
    raycastParams.IgnoreWater = true
    
    -- Raycast chính
    local raycastResult = workspace:Raycast(pointA, direction * distance, raycastParams)
    
    if raycastResult then
        -- Kiểm tra thêm từ nhiều góc độ để tránh false positive
        local offsets = {
            Vector3.new(0.5, 0, 0),
            Vector3.new(-0.5, 0, 0),
            Vector3.new(0, 0.5, 0),
            Vector3.new(0, -0.5, 0),
            Vector3.new(0.3, 0.3, 0),
            Vector3.new(-0.3, -0.3, 0)
        }
        
        for _, offset in pairs(offsets) do
            local newPointA = pointA + offset
            local newRay = workspace:Raycast(newPointA, direction * distance, raycastParams)
            if not newRay then
                return true -- Có ít nhất một đường ray không bị chặn
            end
        end
        return false
    end
    
    return true
end

-- Hàm kiểm tra xem địch có thể nhìn thấy mình
local function canShootMe(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return false end
    
    local targetHead = targetPlayer.Character:FindFirstChild("Head")
    local playerHead = player.Character and player.Character:FindFirstChild("Head")
    
    if not targetHead or not playerHead then return false end
    
    return hasClearLineOfSight(
        targetHead.Position, 
        playerHead.Position, 
        {targetPlayer.Character, player.Character}
    )
end

-- Hàm tính điểm đe dọa dựa trên nhiều yếu tố
local function calculateThreatScore(targetPlayer, camPos)
    if not targetPlayer.Character then return 0 end
    
    local root = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = targetPlayer.Character:FindFirstChild("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then return 0 end
    
    local score = 0
    local distance = (root.Position - camPos).Magnitude
    
    -- Yếu tố khoảng cách (gần = điểm cao)
    local distanceScore = math.max(0, 1 - (distance / AIMBOT_CONFIG.MAX_DISTANCE))
    score = score + distanceScore * 40
    
    -- Yếu tố có thể bắn mình
    if canShootMe(targetPlayer) then
        score = score + 35
    end
    
    -- Yếu tố tầm nhìn trực tiếp
    local isVisible = hasClearLineOfSight(
        camPos, 
        root.Position, 
        {player.Character, targetPlayer.Character}
    )
    if isVisible then
        score = score + 25
    end
    
    -- Yếu tố góc nhìn (càng ở trung tâm càng tốt)
    local camDir = camera.CFrame.LookVector
    local toTarget = (root.Position - camPos).Unit
    local dot = camDir:Dot(toTarget)
    local angleScore = (dot + 1) / 2 -- Chuyển từ [-1,1] sang [0,1]
    score = score + angleScore * 20
    
    -- Yếu tố máu (máu thấp = dễ tiêu diệt = ưu tiên)
    local healthScore = (100 - humanoid.Health) / 100
    score = score + healthScore * 15
    
    -- Yếu tố chuyển động (đang di chuyển = khó bắn hơn)
    local velocity = root.Velocity.Magnitude
    if velocity > 10 then
        score = score - (velocity / 50) * 10
    end
    
    return math.max(0, score)
end

-- Hàm dự đoán vị trí dựa trên chuyển động
local function predictPosition(targetPlayer, predictionTime)
    if not targetPlayer.Character then return nil end
    
    local root = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    -- Dự đoán dựa trên vận tốc hiện tại
    local predictedPos = root.Position + (root.Velocity * predictionTime)
    
    -- Giới hạn dự đoán trong phạm vi hợp lý
    local maxPrediction = 5 -- Giây
    if predictionTime > maxPrediction then
        predictedPos = root.Position + (root.Velocity * maxPrediction)
    end
    
    return predictedPos
end

-- Hàm tìm mục tiêu tối ưu với thuật toán thông minh
local function findOptimalTarget()
    local camPos = camera.CFrame.Position
    local bestTarget = nil
    local bestScore = 0
    
    for _, potentialTarget in pairs(Players:GetPlayers()) do
        -- Kiểm tra điều kiện cơ bản
        if potentialTarget ~= player and 
           isEnemy(potentialTarget) and 
           potentialTarget.Character then
            
            local root = potentialTarget.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = potentialTarget.Character:FindFirstChild("Humanoid")
            
            if root and humanoid and humanoid.Health > 0 then
                -- Kiểm tra khoảng cách
                local distance = (root.Position - camPos).Magnitude
                if distance <= AIMBOT_CONFIG.MAX_DISTANCE then
                    -- Tính điểm đe dọa
                    local threatScore = calculateThreatScore(potentialTarget, camPos)
                    
                    -- Chọn mục tiêu có điểm cao nhất
                    if threatScore > bestScore then
                        bestScore = threatScore
                        bestTarget = potentialTarget
                    end
                end
            end
        end
    end
    
    -- Chỉ nhắm nếu điểm đủ cao
    if bestScore < 30 then -- Ngưỡng tối thiểu
        return nil
    end
    
    return bestTarget
end

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

local function updateHighlight(character, targetPlayer)
    if not character then return end
    
    if espFolders[targetPlayer] then
        espFolders[targetPlayer]:Destroy()
    end
    
    local folder = createEspFolder(targetPlayer)
    
    -- Xác định màu dựa trên team
    local fillColor, outlineColor
    if isEnemy(targetPlayer) then
        fillColor = Color3.fromRGB(255, 50, 50)
        outlineColor = Color3.fromRGB(255, 255, 255)
    else
        fillColor = Color3.fromRGB(50, 150, 255)
        outlineColor = Color3.fromRGB(200, 200, 200)
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "WallhackHighlight"
    highlight.FillColor = fillColor
    highlight.OutlineColor = outlineColor
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = character
    highlight.Parent = folder
    highlight.Enabled = wallhackEnabled
    
    character.Destroying:Connect(function()
        if folder and folder.Parent then
            folder:Destroy()
            espFolders[targetPlayer] = nil
        end
    end)
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Died:Connect(function()
            if folder and folder.Parent then
                folder:Destroy()
                espFolders[targetPlayer] = nil
            end
        end)
    end
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

local function initializePlayerESP(otherPlayer)
    if otherPlayer == player then return end
    
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
    
    if otherPlayer.Character then
        setupCharacter(otherPlayer.Character)
    end
    
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
    for targetPlayer, folder in pairs(espFolders) do
        folder:Destroy()
    end
    espFolders = {}
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        initializePlayerESP(otherPlayer)
    end
    
    Players.PlayerAdded:Connect(function(newPlayer)
        initializePlayerESP(newPlayer)
    end)
end

-- ===========================================================================
-- AIMBOT THÔNG MINH VỚI ĐỘ MƯỢT VÀ DỰ ĐOÁN
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

-- Hàm aim mượt với dự đoán
local function smoothAim(target)
    if not target or not target.Character then return end
    
    local camPos = camera.CFrame.Position
    local targetPart = nil
    
    -- Ưu tiên headshot nếu được bật
    if AIMBOT_CONFIG.HEAD_PRIORITY then
        targetPart = target.Character:FindFirstChild("Head")
    end
    
    -- Nếu không tìm thấy head thì dùng upper torso
    if not targetPart then
        targetPart = target.Character:FindFirstChild("UpperTorso") or 
                    target.Character:FindFirstChild("HumanoidRootPart")
    end
    
    if not targetPart then return end
    
    -- Dự đoán vị trí nếu được bật
    local targetPos = targetPart.Position
    if AIMBOT_CONFIG.PREDICTION then
        local distance = (targetPos - camPos).Magnitude
        local predictionTime = distance / 1000 -- Thời gian dự đoán dựa trên khoảng cách
        local predictedPos = predictPosition(target, predictionTime)
        if predictedPos then
            targetPos = predictedPos
        end
    end
    
    -- Tính toán hướng nhìn mới
    local newLookVector = (targetPos - camPos).Unit
    
    -- Áp dụng độ mượt
    local currentLookVector = camera.CFrame.LookVector
    local smoothedLookVector = currentLookVector:Lerp(newLookVector, AIMBOT_CONFIG.SMOOTHING)
    
    -- Cập nhật camera
    camera.CFrame = CFrame.new(camPos, camPos + smoothedLookVector)
end

-- Bắt đầu Aim với thuật toán thông minh
local function startSmartAim()
    if aimConnection then aimConnection:Disconnect() end
    
    local lastTargetSwitch = 0
    local TARGET_SWITCH_COOLDOWN = 0.5 -- Giây
    
    aimConnection = RunService.RenderStepped:Connect(function()
        if not aimEnabled then return end

        -- Kiểm tra và tìm mục tiêu mới nếu cần
        local currentTime = tick()
        if not currentTarget or 
           not currentTarget.Character or 
           not currentTarget.Character:FindFirstChild("Humanoid") or 
           currentTarget.Character.Humanoid.Health <= 0 or
           (currentTime - lastTargetSwitch > TARGET_SWITCH_COOLDOWN and findOptimalTarget() ~= currentTarget) then
            
            local newTarget = findOptimalTarget()
            if newTarget and newTarget ~= currentTarget then
                currentTarget = newTarget
                lastTargetSwitch = currentTime
                showArrow(currentTarget)
            elseif not newTarget then
                currentTarget = nil
                removeArrow()
            end
        end

        -- Aim vào mục tiêu
        if currentTarget then
            smoothAim(currentTarget)
        end
    end)
end

-- Nút bật/tắt AimBot thông minh
aimButton.MouseButton1Click:Connect(function()
    aimEnabled = not aimEnabled
    if aimEnabled then
        aimButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        aimButton.Text = "AIM ON"
        startSmartAim()
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
-- PHẦN TELEPORT (GIỮ NGUYÊN)
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
    local newTarget = findOptimalTarget()
    
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

-- Cập nhật khi local player respawn
player.CharacterAdded:Connect(function(character)
    unlockTarget()
    initializeWallhack()
end)

-- Cleanup khi người chơi rời
Players.PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == targetPlayer then
        unlockTarget()
    end
    
    if leavingPlayer == currentTarget then
        currentTarget = nil
        removeArrow()
    end
    
    if espFolders[leavingPlayer] then
        espFolders[leavingPlayer]:Destroy()
        espFolders[leavingPlayer] = nil
    end
end)

-- Khởi tạo
initializeWallhack()

print("✅ Aimbot Thông Minh Đã Sẵn Sàng!")
