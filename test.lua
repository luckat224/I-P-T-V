-- LocalScript – đặt trong StarterPlayerScripts
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "TeleportGui"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local teleportButton = Instance.new("TextButton")
teleportButton.Size = UDim2.new(0, 80, 0, 80)
teleportButton.Position = UDim2.new(0, 20, 0.5, -40)
teleportButton.AnchorPoint = Vector2.new(0, 0.5)
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
aimButton.Size = UDim2.new(0, 60, 0, 30)
aimButton.Position = UDim2.new(0, 30, 0.5, 50)
aimButton.AnchorPoint = Vector2.new(0, 0.5)
aimButton.Text = "AIM BOT"
aimButton.BackgroundColor3 = Color3.fromRGB(59, 59, 255)
aimButton.TextColor3 = Color3.new(1, 1, 1)
aimButton.TextSize = 12
aimButton.Font = Enum.Font.GothamBold
aimButton.BorderSizePixel = 0
aimButton.AutoButtonColor = false
aimButton.Parent = gui

local aimButtonCorner = Instance.new("UICorner")
aimButtonCorner.CornerRadius = UDim.new(0.3, 0)
aimButtonCorner.Parent = aimButton

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(0, 120, 0, 40)
infoLabel.Position = UDim2.new(0, 20, 0.5, 100)
infoLabel.AnchorPoint = Vector2.new(0, 0.5)
infoLabel.Text = "DISTANCE: -\nTARGET: NONE"
infoLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
infoLabel.BackgroundTransparency = 0.5
infoLabel.TextColor3 = Color3.new(1, 1, 1)
infoLabel.TextSize = 12
infoLabel.Font = Enum.Font.Gotham
infoLabel.BorderSizePixel = 0
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.Parent = gui

local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0.2, 0)
infoCorner.Parent = infoLabel

local isLocked = false
local targetPlayer = nil
local currentArrow = nil
local followConnection = nil
local lastClickTime = 0
local CLICK_DELAY = 0.3

local aimBotEnabled = false
local aimBotConnection = nil
local currentAimTarget = nil

local wallhackEnabled = true
local espFolders = {}

-- Cấu hình aimbot thông minh
local AIM_PRIORITY = {
    ATTACKING = 10,      -- Đang tấn công
    AIMING_AT_ME = 8,    -- Đang nhìn vào mình
    CLOSE_RANGE = 6,     Ở cự ly gần
    LOW_HEALTH = 5,      -- Máu thấp
    NORMAL = 1           -- Bình thường
}

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
    
    -- Thêm label hiển thị tên và khoảng cách
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESPInfo"
    billboard.Size = UDim2.new(0, 200, 0, 100)
    billboard.AlwaysOnTop = true
    billboard.Enabled = true
    billboard.Adornee = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
    billboard.MaxDistance = 200
    billboard.Parent = folder
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = targetPlayer.Name
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Parent = billboard
    
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "DIST: -"
    distanceLabel.TextColor3 = Color3.new(1, 1, 1)
    distanceLabel.TextScaled = true
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.Parent = billboard
    
    -- Cập nhật khoảng cách liên tục
    local function updateDistance()
        while billboard and billboard.Parent and character and character.Parent do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local playerRoot = player.Character.HumanoidRootPart
                local targetRoot = character:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    local distance = (playerRoot.Position - targetRoot.Position).Magnitude
                    distanceLabel.Text = "DIST: " .. math.floor(distance) .. "m"
                    
                    -- Đổi màu theo khoảng cách
                    if distance < 20 then
                        distanceLabel.TextColor3 = Color3.fromRGB(255, 50, 50)  -- Đỏ: rất gần
                    elseif distance < 50 then
                        distanceLabel.TextColor3 = Color3.fromRGB(255, 150, 50) -- Cam: gần
                    else
                        distanceLabel.TextColor3 = Color3.fromRGB(50, 255, 50)  -- Xanh: xa
                    end
                end
            end
            wait(0.2)
        end
    end
    
    coroutine.wrap(updateDistance)()
end

local function toggleWallhack()
    wallhackEnabled = not wallhackEnabled
    
    for targetPlayer, folder in pairs(espFolders) do
        if folder then
            folder.Enabled = wallhackEnabled
        end
    end
    
    if wallhackEnabled then
        teleportButton.BackgroundColor3 = Color3.fromRGB(255, 59, 59)
    else
        teleportButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
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
        end
    end
    
    Players.PlayerAdded:Connect(function(newPlayer)
        if newPlayer ~= player then
            newPlayer.CharacterAdded:Connect(function(character)
                wait(1)
                createHighlight(character, newPlayer)
            end)
        end
    end)
end

local function getAngleBetweenVectors(v1, v2)
    return math.acos(v1:Dot(v2) / (v1.Magnitude * v2.Magnitude))
end

local function calculateTargetPriority(targetPlayer, targetCharacter)
    if not targetPlayer or not targetCharacter then return 0 end
    
    local priority = AIM_PRIORITY.NORMAL
    local playerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
    local targetHumanoid = targetCharacter:FindFirstChild("Humanoid")
    
    if not playerRoot or not targetRoot or not targetHumanoid then return priority end
    
    -- Tính khoảng cách
    local distance = (playerRoot.Position - targetRoot.Position).Magnitude
    
    -- Ưu tiên mục tiêu ở cự ly gần
    if distance < 15 then
        priority = priority + AIM_PRIORITY.CLOSE_RANGE
    end
    
    -- Kiểm tra nếu mục tiêu đang nhìn vào mình
    local targetHead = targetCharacter:FindFirstChild("Head")
    if targetHead then
        local targetLook = targetHead.CFrame.LookVector
        local toPlayer = (playerRoot.Position - targetHead.Position).Unit
        local angleToPlayer = getAngleBetweenVectors(targetLook, toPlayer)
        
        if angleToPlayer < math.rad(30) then -- Nếu mục tiêu đang nhìn về phía mình
            priority = priority + AIM_PRIORITY.AIMING_AT_ME
        end
    end
    
    -- Ưu tiên mục tiêu có máu thấp
    if targetHumanoid.Health < targetHumanoid.MaxHealth * 0.3 then
        priority = priority + AIM_PRIORITY.LOW_HEALTH
    end
    
    -- Phát hiện nếu mục tiêu đang tấn công (di chuyển nhanh về phía mình)
    local targetVelocity = targetRoot.Velocity
    local toPlayerDirection = (playerRoot.Position - targetRoot.Position).Unit
    local velocityTowardsPlayer = targetVelocity:Dot(toPlayerDirection)
    
    if velocityTowardsPlayer > 10 then -- Đang di chuyển nhanh về phía mình
        priority = priority + AIM_PRIORITY.ATTACKING
    end
    
    return priority
end

local function getBestTarget()
    local bestTarget = nil
    local highestPriority = 0
    local smallestAngle = math.rad(30)
    
    if not player.Character then return nil end
    
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return nil end
    
    local cameraDirection = camera.CFrame.LookVector
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            local otherHumanoid = otherPlayer.Character:FindFirstChild("Humanoid")
            
            if otherRoot and otherHumanoid and otherHumanoid.Health > 0 then
                local toTarget = (otherRoot.Position - camera.CFrame.Position).Unit
                local angle = getAngleBetweenVectors(cameraDirection, toTarget)
                
                if angle < smallestAngle then
                    local priority = calculateTargetPriority(otherPlayer, otherPlayer.Character)
                    
                    if priority > highestPriority then
                        highestPriority = priority
                        bestTarget = otherPlayer
                        smallestAngle = angle
                    elseif priority == highestPriority and angle < smallestAngle then
                        bestTarget = otherPlayer
                        smallestAngle = angle
                    end
                end
            end
        end
    end
    
    return bestTarget, highestPriority
end

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
    arrowGui.Size = UDim2.new(0, 100, 0, 100)
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

local function updateInfoLabel()
    if not player.Character then return end
    
    local playerRoot = player.Character:FindFirstChild("HumanoidRootPart")
    if not playerRoot then return end
    
    local closestDistance = math.huge
    local closestTarget = nil
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            if otherRoot then
                local distance = (playerRoot.Position - otherRoot.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestTarget = otherPlayer
                end
            end
        end
    end
    
    if closestTarget then
        local priority = calculateTargetPriority(closestTarget, closestTarget.Character)
        local priorityText = ""
        
        if priority >= AIM_PRIORITY.ATTACKING then
            priorityText = "⚡ ATTACKING"
        elseif priority >= AIM_PRIORITY.AIMING_AT_ME then
            priorityText = "👀 TARGETING YOU"
        elseif priority >= AIM_PRIORITY.CLOSE_RANGE then
            priorityText = "🔴 CLOSE RANGE"
        elseif priority >= AIM_PRIORITY.LOW_HEALTH then
            priorityText = "💚 LOW HEALTH"
        else
            priorityText = "🟢 NORMAL"
        end
        
        infoLabel.Text = string.format("DIST: %dm\nTARGET: %s\n%s", 
            math.floor(closestDistance), 
            closestTarget.Name,
            priorityText)
    else
        infoLabel.Text = "DISTANCE: -\nTARGET: NONE\nNO THREATS"
    end
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
    local newTarget, priority = getBestTarget()
    
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
    
    -- Đổi màu theo độ ưu tiên
    if priority >= AIM_PRIORITY.ATTACKING then
        teleportButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Đỏ: đang tấn công
    elseif priority >= AIM_PRIORITY.AIMING_AT_ME then
        teleportButton.BackgroundColor3 = Color3.fromRGB(255, 100, 0) -- Cam: đang nhắm mình
    else
        teleportButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0) -- Xanh: bình thường
    end
    
    teleportButton.Text = "LOCKED"
    
    createArrow(targetPlayer)
    startContinuousFollow()
    teleportClose(targetPlayer)
    
    return true
end

local function startAimBot()
    if aimBotConnection then
        aimBotConnection:Disconnect()
        aimBotConnection = nil
    end
    
    aimBotConnection = RunService.Heartbeat:Connect(function()
        if not aimBotEnabled then return end
        
        local bestTarget, priority = getBestTarget()
        
        if bestTarget and bestTarget.Character then
            local targetHead = bestTarget.Character:FindFirstChild("Head")
            local targetRoot = bestTarget.Character:FindFirstChild("HumanoidRootPart")
            
            if targetHead then
                local cameraPosition = camera.CFrame.Position
                local targetPosition = targetHead.Position
                
                -- Thêm dự đoán chuyển động
                if targetRoot then
                    local targetVelocity = targetRoot.Velocity
                    local distance = (targetPosition - cameraPosition).Magnitude
                    local timeToTarget = distance / 1000 -- Giả sử tốc độ đạn
                    targetPosition = targetPosition + targetVelocity * timeToTarget
                end
                
                local newCFrame = CFrame.new(cameraPosition, targetPosition)
                camera.CFrame = newCFrame
                currentAimTarget = bestTarget
                
                -- Đổi màu aim button theo độ ưu tiên
                if priority >= AIM_PRIORITY.ATTACKING then
                    aimButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                elseif priority >= AIM_PRIORITY.AIMING_AT_ME then
                    aimButton.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
                else
                    aimButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                end
            elseif targetRoot then
                local cameraPosition = camera.CFrame.Position
                local targetPosition = targetRoot.Position
                local newCFrame = CFrame.new(cameraPosition, targetPosition)
                camera.CFrame = newCFrame
                currentAimTarget = bestTarget
            end
        else
            currentAimTarget = nil
            aimButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        end
    end)
end

local function toggleAimBot()
    aimBotEnabled = not aimBotEnabled
    
    if aimBotEnabled then
        aimButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        aimButton.Text = "AIM: ON"
        startAimBot()
    else
        aimButton.BackgroundColor3 = Color3.fromRGB(59, 59, 255)
        aimButton.Text = "AIM BOT"
        if aimBotConnection then
            aimBotConnection:Disconnect()
            aimBotConnection = nil
        end
        currentAimTarget = nil
    end
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

local function handleAimClick()
    toggleAimBot()
end

teleportButton.MouseButton1Click:Connect(handleTeleportClick)
teleportButton.MouseButton2Click:Connect(toggleWallhack)
teleportButton.TouchTap:Connect(handleTeleportClick)

aimButton.MouseButton1Click:Connect(handleAimClick)

-- Cập nhật thông tin liên tục
RunService.Heartbeat:Connect(function()
    updateInfoLabel()
    
    if not player.Character then return end
    
    local newTarget = getBestTarget()
    
    if isLocked then
        if targetPlayer and targetPlayer.Character then
            if not currentArrow then
                createArrow(targetPlayer)
            end
        else
            unlockTarget()
        end
    else
        if newTarget then
            if not currentArrow or (currentArrow and newTarget ~= targetPlayer) then
                createArrow(newTarget)
            end
        else
            if currentArrow then
                currentArrow:Destroy()
                currentArrow = nil
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == targetPlayer then
        unlockTarget()
    end
    
    if leavingPlayer == currentAimTarget then
        currentAimTarget = nil
    end
    
    if espFolders[leavingPlayer] then
        espFolders[leavingPlayer]:Destroy()
        espFolders[leavingPlayer] = nil
    end
end)

player.CharacterAdded:Connect(function(character)
    wait(1)
    unlockTarget()
end)

wait(2)
initializeWallhack()

print("✅ Enhanced Teleport & Smart Aim Bot Script Đã Sẵn Sàng!")
print("📊 Tính năng mới:")
print("   • Hiển thị khoảng cách và thông tin mục tiêu")
print("   • Aimbot thông minh ưu tiên mục tiêu nguy hiểm")
print("   • Nhận diện kẻ địch đang nhắm vào bạn")
print("   • Phát hiện kẻ địch đang tấn công")
print("   • Ưu tiên mục tiêu máu thấp và cự ly gần")
