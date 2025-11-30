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
-- AIMBOT BÁM DÍNH KHÔNG DỰ ĐOÁN
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

-- Cấu hình Aimbot - ĐÃ LOẠI BỎ DỰ ĐOÁN
local AIMBOT_CONFIG = {
    FOV = 120, -- Góc nhìn (độ)
    MAX_DISTANCE = 500, -- Khoảng cách tối đa
    SMOOTHING = 0.08, -- Độ mượt thấp hơn để bám dính tốt hơn
    HEAD_PRIORITY = true, -- Ưu tiên headshot
    VISIBILITY_CHECK = true, -- Kiểm tra tầm nhìn
    STICKY_AIM = true, -- Bám dính chặt vào mục tiêu
    AIM_POINT = "Head" -- Head, UpperTorso, HumanoidRootPart
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
    
    local raycastResult = workspace:Raycast(pointA, direction * distance, raycastParams)
    
    if raycastResult then
        -- Kiểm tra thêm từ nhiều góc độ để tránh false positive
        local offsets = {
            Vector3.new(0.3, 0, 0),
            Vector3.new(-0.3, 0, 0),
            Vector3.new(0, 0.3, 0),
            Vector3.new(0, -0.3, 0)
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

-- Hàm tính điểm đe dọa đơn giản hóa
local function calculateThreatScore(targetPlayer, camPos)
    if not targetPlayer.Character then return 0 end
    
    local root = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = targetPlayer.Character:FindFirstChild("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then return 0 end
    
    local score = 0
    local distance = (root.Position - camPos).Magnitude
    
    -- Yếu tố khoảng cách (gần = điểm cao)
    local distanceScore = math.max(0, 1 - (distance / AIMBOT_CONFIG.MAX_DISTANCE))
    score = score + distanceScore * 50
    
    -- Yếu tố có thể bắn mình
    if canShootMe(targetPlayer) then
        score = score + 30
    end
    
    -- Yếu tố tầm nhìn trực tiếp
    local isVisible = hasClearLineOfSight(
        camPos, 
        root.Position, 
        {player.Character, targetPlayer.Character}
    )
    if isVisible then
        score = score + 20
    end
    
    -- Yếu tố góc nhìn (càng ở trung tâm càng tốt)
    local camDir = camera.CFrame.LookVector
    local toTarget = (root.Position - camPos).Unit
    local dot = camDir:Dot(toTarget)
    if dot > 0.9 then -- Chỉ tính những mục tiêu trong tầm nhìn
        score = score + (dot * 20)
    end
    
    return math.max(0, score)
end

-- Hàm tìm mục tiêu tối ưu
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
    if bestScore < 40 then -- Ngưỡng tối thiểu cao hơn để chọn mục tiêu tốt
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
-- AIMBOT BÁM DÍNH TRỰC TIẾP - KHÔNG DỰ ĐOÁN
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

-- Hàm aim trực tiếp vào vị trí hiện tại - KHÔNG DỰ ĐOÁN
local function directAim(target)
    if not target or not target.Character then return end
    
    local camPos = camera.CFrame.Position
    local targetPart = nil
    
    -- Chọn điểm aim dựa trên cấu hình
    if AIMBOT_CONFIG.HEAD_PRIORITY then
        targetPart = target.Character:FindFirstChild("Head") or 
                    target.Character:FindFirstChild("UpperTorso") or 
                    target.Character:FindFirstChild("HumanoidRootPart")
    else
        targetPart = target.Character:FindFirstChild("UpperTorso") or 
                    target.Character:FindFirstChild("HumanoidRootPart") or 
                    target.Character:FindFirstChild("Head")
    end
    
    if not targetPart then return end
    
    -- AIM TRỰC TIẾP - KHÔNG DỰ ĐOÁN
    local targetPos = targetPart.Position
    
    -- Tính toán hướng nhìn mới
    local newLookVector = (targetPos - camPos).Unit
    
    -- Áp dụng độ mượt nhẹ để tránh giật
    local currentLookVector = camera.CFrame.LookVector
    local smoothedLookVector = currentLookVector:Lerp(newLookVector, AIMBOT_CONFIG.SMOOTHING)
    
    -- Cập nhật camera - aim trực tiếp vào vị trí hiện tại
    camera.CFrame = CFrame.new(camPos, camPos + smoothedLookVector)
end

-- Hàm aim cứng (không mượt) cho độ chính xác cao
local function hardAim(target)
    if not target or not target.Character then return end
    
    local camPos = camera.CFrame.Position
    local targetPart = target.Character:FindFirstChild("Head") or 
                      target.Character:FindFirstChild("UpperTorso")
    
    if not targetPart then return end
    
    -- AIM CỨNG TRỰC TIẾP - KHÔNG MƯỢT
    local targetPos = targetPart.Position
    camera.CFrame = CFrame.new(camPos, targetPos)
end

-- Bắt đầu Aim với độ chính xác cao
local function startPreciseAim()
    if aimConnection then aimConnection:Disconnect() end
    
    local lastTargetSwitch = 0
    local TARGET_SWITCH_COOLDOWN = 0.3 -- Giây
    
    aimConnection = RunService.RenderStepped:Connect(function()
        if not aimEnabled then return end

        -- Kiểm tra và tìm mục tiêu mới nếu cần
        local currentTime = tick()
        if not currentTarget or 
           not currentTarget.Character or 
           not currentTarget.Character:FindFirstChild("Humanoid") or 
           currentTarget.Character.Humanoid.Health <= 0 or
           (currentTime - lastTargetSwitch > TARGET_SWITCH_COOLDOWN) then
            
            local newTarget = findOptimalTarget()
            if newTarget then
                currentTarget = newTarget
                lastTargetSwitch = currentTime
                showArrow(currentTarget)
            else
                currentTarget = nil
                removeArrow()
            end
        end

        -- Aim vào mục tiêu với độ chính xác cao
        if currentTarget then
            if AIMBOT_CONFIG.STICKY_AIM then
                hardAim(currentTarget) -- Aim cứng cho độ chính xác
            else
                directAim(currentTarget) -- Aim có độ mượt nhẹ
            end
        end
    end)
end

-- Nút bật/tắt AimBot chính xác
aimButton.MouseButton1Click:Connect(function()
    aimEnabled = not aimEnabled
    if aimEnabled then
        aimButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        aimButton.Text = "AIM ON"
        startPreciseAim()
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

print("✅ Aimbot Bám Dính Chính Xác Đã Sẵn Sàng! (Không Dự Đoán)")
