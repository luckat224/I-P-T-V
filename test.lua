-- LocalScript – đặt trong StarterPlayerScripts
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Chờ playerGui load
local playerGui = player:WaitForChild("PlayerGui")

-- Giao diện nút Teleport
local gui = Instance.new("ScreenGui")
gui.Name = "TeleportGui"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- Container cho các nút
local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.new(0, 80, 0, 160)
buttonContainer.Position = UDim2.new(0, 20, 0.5, -80)
buttonContainer.AnchorPoint = Vector2.new(0, 0.5)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = gui

-- Nút Teleport chính
local teleportButton = Instance.new("TextButton")
teleportButton.Size = UDim2.new(1, 0, 0.5, -5)
teleportButton.Position = UDim2.new(0, 0, 0, 0)
teleportButton.Text = "TELEPORT"
teleportButton.BackgroundColor3 = Color3.fromRGB(255, 59, 59)
teleportButton.TextColor3 = Color3.new(1, 1, 1)
teleportButton.TextSize = 14
teleportButton.Font = Enum.Font.GothamBold
teleportButton.BorderSizePixel = 0
teleportButton.AutoButtonColor = false
teleportButton.Parent = buttonContainer

-- Bo tròn nút teleport
local teleportCorner = Instance.new("UICorner")
teleportCorner.CornerRadius = UDim.new(1, 0)
teleportCorner.Parent = teleportButton

-- Nút Tránh xa (nhỏ hơn, ở dưới)
local avoidButton = Instance.new("TextButton")
avoidButton.Size = UDim2.new(1, 0, 0.5, -5)
avoidButton.Position = UDim2.new(0, 0, 0.5, 5)
avoidButton.Text = "TRÁNH XA"
avoidButton.BackgroundColor3 = Color3.fromRGB(59, 59, 255)
avoidButton.TextColor3 = Color3.new(1, 1, 1)
avoidButton.TextSize = 12
avoidButton.Font = Enum.Font.GothamBold
avoidButton.BorderSizePixel = 0
avoidButton.AutoButtonColor = false
avoidButton.Parent = buttonContainer

-- Bo tròn nút tránh xa
local avoidCorner = Instance.new("UICorner")
avoidCorner.CornerRadius = UDim.new(1, 0)
avoidCorner.Parent = avoidButton

-- Biến điều khiển
local isLocked = false
local isAvoiding = false
local targetPlayer = nil
local currentArrow = nil
local followConnection = nil
local avoidConnection = nil
local lastClickTime = 0
local CLICK_DELAY = 0.3
local AVOID_DISTANCE = 5 -- Khoảng cách tránh xa (studs)

-- Hàm tính góc giữa 2 vector
local function getAngleBetweenVectors(v1, v2)
    return math.acos(v1:Dot(v2) / (v1.Magnitude * v2.Magnitude))
end

-- Tìm người chơi trong tầm nhìn
local function getTarget()
    local bestTarget = nil
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
                    smallestAngle = angle
                    bestTarget = otherPlayer
                end
            end
        end
    end
    
    return bestTarget
end

-- Tạo mũi tên trên đầu
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
    arrowGui.Size = UDim2.new(0, 25, 0, 25)
    arrowGui.AlwaysOnTop = true
    arrowGui.Enabled = true
    arrowGui.Adornee = head
    arrowGui.MaxDistance = 150
    arrowGui.SizeOffset = Vector2.new(0, 2.2)
    
    local arrowLabel = Instance.new("TextLabel")
    arrowLabel.Size = UDim2.new(1, 0, 1, 0)
    arrowLabel.BackgroundTransparency = 1
    arrowLabel.Text = isLocked and "🔒" or (isAvoiding and "🚫" or "🎯")
    arrowLabel.TextColor3 = isLocked and Color3.fromRGB(255, 0, 0) or (isAvoiding and Color3.fromRGB(59, 59, 255) or Color3.fromRGB(0, 255, 0))
    arrowLabel.TextScaled = true
    arrowLabel.Font = Enum.Font.GothamBold
    arrowLabel.Parent = arrowGui
    
    arrowGui.Parent = head
    currentArrow = arrowGui
    
    return arrowGui
end

-- Teleport ra SÁT mục tiêu
local function teleportClose(target)
    if not target or not target.Character then return false end
    
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    local playerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    
    if not targetRoot or not playerRoot then return false end
    
    -- Tính vị trí SÁT BÊN mục tiêu (cách 1-2 studs)
    local targetCFrame = targetRoot.CFrame
    local lookVector = targetCFrame.LookVector
    local rightVector = targetCFrame.RightVector
    
    -- Thử các vị trí khác nhau: phải, trái, phía sau
    local possiblePositions = {
        targetCFrame.Position + rightVector * 1.5,      -- Bên phải
        targetCFrame.Position - rightVector * 1.5,      -- Bên trái  
        targetCFrame.Position - lookVector * 1.2,       -- Phía sau gần
        targetCFrame.Position + lookVector * 1.2,       -- Phía trước (đối diện)
    }
    
    -- Kiểm tra vật cản
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
    
    -- Quay mặt về phía mục tiêu để dễ tấn công
    local teleportCFrame = CFrame.new(finalPosition, targetRoot.Position)
    playerRoot.CFrame = teleportCFrame
    
    return true
end

-- Tránh xa mục tiêu
local function avoidTarget()
    if not targetPlayer or not targetPlayer.Character then return false end
    
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local playerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    
    if not targetRoot or not playerRoot then return false end
    
    -- Tính hướng từ mục tiêu đến người chơi
    local toPlayer = (playerRoot.Position - targetRoot.Position)
    local currentDistance = toPlayer.Magnitude
    
    -- Nếu đang ở quá gần (< AVOID_DISTANCE), di chuyển ra xa
    if currentDistance < AVOID_DISTANCE then
        -- Tính vị trí mới cách mục tiêu AVOID_DISTANCE
        local direction = toPlayer.Unit
        local targetPosition = targetRoot.Position + direction * AVOID_DISTANCE
        
        -- Kiểm tra vật cản
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        raycastParams.FilterDescendantsInstances = {player.Character, targetPlayer.Character}
        
        local raycastResult = workspace:Raycast(
            targetRoot.Position,
            direction * AVOID_DISTANCE,
            raycastParams
        )
        
        local finalPosition = targetPosition
        if raycastResult then
            -- Nếu có vật cản, di chuyển đến vị trí trước vật cản
            finalPosition = raycastResult.Position - direction * 0.5
        end
        
        -- Quay mặt về phía mục tiêu (nhìn từ xa)
        local avoidCFrame = CFrame.new(finalPosition, targetRoot.Position)
        playerRoot.CFrame = avoidCFrame
    end
    
    return true
end

-- Hàm bắt đầu follow liên tục
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
                
                -- Teleport liên tục khi khoảng cách > 3 studs (gần hơn)
                if distance > 3 then
                    teleportClose(targetPlayer)
                end
            end
        else
            unlockTarget()
        end
    end)
end

-- Hàm bắt đầu tránh xa liên tục
local function startContinuousAvoid()
    if avoidConnection then
        avoidConnection:Disconnect()
        avoidConnection = nil
    end
    
    avoidConnection = RunService.Heartbeat:Connect(function()
        if not isAvoiding then return end
        
        if targetPlayer and targetPlayer.Character then
            local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local playerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            
            if targetRoot and playerRoot then
                local distance = (targetRoot.Position - playerRoot.Position).Magnitude
                
                -- Tránh xa liên tục khi khoảng cách < AVOID_DISTANCE + 1 (có độ trễ)
                if distance < AVOID_DISTANCE + 1 then
                    avoidTarget()
                end
            end
        else
            stopAvoiding()
        end
    end)
end

-- Hàm unlock target (tắt cả teleport và avoid)
local function unlockTarget()
    isLocked = false
    isAvoiding = false
    targetPlayer = nil
    
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end
    
    if avoidConnection then
        avoidConnection:Disconnect()
        avoidConnection = nil
    end
    
    if currentArrow then
        currentArrow:Destroy()
        currentArrow = nil
    end
    
    -- Reset màu nút
    teleportButton.BackgroundColor3 = Color3.fromRGB(255, 59, 59)
    teleportButton.Text = "TELEPORT"
    avoidButton.BackgroundColor3 = Color3.fromRGB(59, 59, 255)
    avoidButton.Text = "TRÁNH XA"
end

-- Hàm dừng tránh xa
local function stopAvoiding()
    isAvoiding = false
    
    if avoidConnection then
        avoidConnection:Disconnect()
        avoidConnection = nil
    end
    
    avoidButton.BackgroundColor3 = Color3.fromRGB(59, 59, 255)
    avoidButton.Text = "TRÁNH XA"
    
    if isLocked then
        teleportButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        teleportButton.Text = "LOCKED"
    else
        if currentArrow then
            currentArrow:Destroy()
            currentArrow = nil
        end
    end
end

-- Hàm lock target (teleport)
local function lockTarget()
    local newTarget = getTarget()
    
    if not newTarget then
        teleportButton.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
        teleportButton.Text = "NO TARGET"
        
        delay(1, function()
            if not isLocked then
                teleportButton.BackgroundColor3 = Color3.fromRGB(255, 59, 59)
                teleportButton.Text = "TELEPORT"
            end
        end)
        return false
    end
    
    targetPlayer = newTarget
    isLocked = true
    isAvoiding = false
    
    -- Reset màu nút tránh xa
    avoidButton.BackgroundColor3 = Color3.fromRGB(59, 59, 255)
    avoidButton.Text = "TRÁNH XA"
    
    teleportButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    teleportButton.Text = "LOCKED"
    
    createArrow(targetPlayer)
    startContinuousFollow()
    teleportClose(targetPlayer)
    
    return true
end

-- Hàm bắt đầu tránh xa
local function startAvoiding()
    local newTarget = getTarget()
    
    if not newTarget then
        avoidButton.BackgroundColor3 = Color3.fromRGB(150, 150, 255)
        avoidButton.Text = "NO TARGET"
        
        delay(1, function()
            if not isAvoiding then
                avoidButton.BackgroundColor3 = Color3.fromRGB(59, 59, 255)
                avoidButton.Text = "TRÁNH XA"
            end
        end)
        return false
    end
    
    targetPlayer = newTarget
    isAvoiding = true
    isLocked = false
    
    -- Reset màu nút teleport
    teleportButton.BackgroundColor3 = Color3.fromRGB(255, 59, 59)
    teleportButton.Text = "TELEPORT"
    
    avoidButton.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
    avoidButton.Text = "AVOIDING"
    
    createArrow(targetPlayer)
    startContinuousAvoid()
    avoidTarget()
    
    return true
end

-- Hàm xử lý click nút teleport
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

-- Hàm xử lý click nút tránh xa
local function handleAvoidClick()
    local currentTime = tick()
    if currentTime - lastClickTime < CLICK_DELAY then
        return
    end
    lastClickTime = currentTime
    
    if isAvoiding then
        stopAvoiding()
    else
        startAvoiding()
    end
end

-- Kết nối sự kiện nút
teleportButton.MouseButton1Click:Connect(handleTeleportClick)
teleportButton.TouchTap:Connect(handleTeleportClick)

avoidButton.MouseButton1Click:Connect(handleAvoidClick)
avoidButton.TouchTap:Connect(handleAvoidClick)

-- Cập nhật mục tiêu liên tục
RunService.Heartbeat:Connect(function()
    if not player.Character then return end
    
    local newTarget = getTarget()
    
    if isLocked or isAvoiding then
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

-- Xử lý khi mục tiêu rời game
Players.PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == targetPlayer then
        unlockTarget()
    end
end)

-- Tự động unlock khi respawn
player.CharacterAdded:Connect(function(character)
    wait(1)
    unlockTarget()
end)

print("✅ Teleport & Avoid Script Đã Sẵn Sàng!")
