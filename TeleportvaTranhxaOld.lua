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
local teleportLocked = false
local targetPlayer = nil
local currentArrow = nil
local teleportConnection = nil
local lastTeleportClickTime = 0
local CLICK_DELAY = 0.3
local AVOID_DISTANCE = 20 -- Khoảng cách tránh xa 20 studs
local lastTeleportTime = 0
local TELEPORT_COOLDOWN = 0.2

-- Hàm tính góc giữa 2 vector
local function getAngleBetweenVectors(v1, v2)
    local dot = v1:Dot(v2)
    local mag1 = v1.Magnitude
    local mag2 = v2.Magnitude
    
    if mag1 == 0 or mag2 == 0 then
        return math.huge
    end
    
    return math.acos(math.clamp(dot / (mag1 * mag2), -1, 1))
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
                local toTarget = (otherRoot.Position - camera.CFrame.Position)
                if toTarget.Magnitude > 0 then
                    toTarget = toTarget.Unit
                    local angle = getAngleBetweenVectors(cameraDirection, toTarget)
                    
                    if angle < smallestAngle then
                        smallestAngle = angle
                        bestTarget = otherPlayer
                    end
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
    arrowGui.Size = UDim2.new(0, 50, 0, 50)
    arrowGui.AlwaysOnTop = true
    arrowGui.Enabled = true
    arrowGui.Adornee = head
    arrowGui.MaxDistance = 150
    arrowGui.SizeOffset = Vector2.new(0, 2.2)
    
    local arrowLabel = Instance.new("TextLabel")
    arrowLabel.Size = UDim2.new(1, 0, 1, 0)
    arrowLabel.BackgroundTransparency = 1
    arrowLabel.Text = teleportLocked and "🔒" or "🎯"
    arrowLabel.TextColor3 = teleportLocked and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
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
    
    -- Kiểm tra thời gian để tránh teleport quá nhanh
    local currentTime = tick()
    if currentTime - lastTeleportTime < TELEPORT_COOLDOWN then
        return false
    end
    lastTeleportTime = currentTime
    
    -- Đơn giản hóa: chỉ teleport phía sau mục tiêu
    local targetCFrame = targetRoot.CFrame
    local lookVector = targetCFrame.LookVector
    
    -- Vị trí phía sau mục tiêu
    local behindPosition = targetCFrame.Position - lookVector * 3
    
    -- Kiểm tra vật cản đơn giản
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {player.Character, target.Character}
    
    local raycastResult = workspace:Raycast(
        targetRoot.Position,
        (behindPosition - targetRoot.Position),
        raycastParams
    )
    
    local finalPosition = behindPosition
    if raycastResult then
        -- Nếu có vật cản, dịch sang bên phải
        finalPosition = targetCFrame.Position + targetCFrame.RightVector * 3
    end
    
    -- Sử dụng CFrame đầy đủ để đảm bảo camera và nhân vật đồng bộ
    local newCFrame = CFrame.new(finalPosition) * (playerRoot.CFrame - playerRoot.Position)
    playerRoot.CFrame = newCFrame
    
    return true
end

-- Tránh xa mục tiêu MỘT LẦN (có thể spam liên tục)
local function avoidTargetOnce()
    if not targetPlayer or not targetPlayer.Character then 
        avoidButton.BackgroundColor3 = Color3.fromRGB(150, 150, 255)
        avoidButton.Text = "NO TARGET"
        
        task.delay(0.3, function()
            avoidButton.BackgroundColor3 = Color3.fromRGB(59, 59, 255)
            avoidButton.Text = "TRÁNH XA"
        end)
        return false 
    end
    
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local playerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    
    if not targetRoot or not playerRoot then return false end
    
    -- Tính hướng từ mục tiêu đến người chơi
    local toPlayer = (playerRoot.Position - targetRoot.Position)
    
    -- Di chuyển ra xa 20 studs
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
        finalPosition = raycastResult.Position - direction * 3
    end
    
    -- Sử dụng CFrame đầy đủ để đảm bảo camera và nhân vật đồng bộ
    -- Giữ nguyên rotation hiện tại của người chơi
    local currentRotation = playerRoot.CFrame - playerRoot.Position
    local newCFrame = CFrame.new(finalPosition) * currentRotation
    playerRoot.CFrame = newCFrame
    
    -- Hiệu ứng nút rất ngắn (0.1 giây) để vẫn có phản hồi nhưng không ảnh hưởng spam
    avoidButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    avoidButton.Text = "ĐÃ TRÁNH"
    
    task.delay(0.1, function()
        avoidButton.BackgroundColor3 = Color3.fromRGB(59, 59, 255)
        avoidButton.Text = "TRÁNH XA"
    end)
    
    return true
end

-- Hàm bắt đầu teleport liên tục
local function startContinuousTeleport()
    if teleportConnection then
        teleportConnection:Disconnect()
    end
    
    teleportConnection = RunService.Heartbeat:Connect(function()
        if not teleportLocked then return end
        
        -- Thêm độ trễ để giảm tải
        if tick() - lastTeleportTime < TELEPORT_COOLDOWN then
            return
        end
        
        if targetPlayer and targetPlayer.Character and player.Character then
            local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local playerRoot = player.Character:FindFirstChild("HumanoidRootPart")
            
            if targetRoot and playerRoot then
                -- Chỉ teleport nếu khoảng cách đủ xa
                local distance = (targetRoot.Position - playerRoot.Position).Magnitude
                if distance > 5 then
                    pcall(function()
                        teleportClose(targetPlayer)
                    end)
                end
            end
        else
            unlockAll()
        end
    end)
end

-- Hàm unlock tất cả
local function unlockAll()
    teleportLocked = false
    targetPlayer = nil
    
    if teleportConnection then
        teleportConnection:Disconnect()
        teleportConnection = nil
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

-- Hàm unlock teleport
local function unlockTeleport()
    teleportLocked = false
    
    if teleportConnection then
        teleportConnection:Disconnect()
        teleportConnection = nil
    end
    
    teleportButton.BackgroundColor3 = Color3.fromRGB(255, 59, 59)
    teleportButton.Text = "TELEPORT"
    
    if currentArrow then
        currentArrow:Destroy()
        currentArrow = nil
    end
end

-- Hàm lock target (teleport)
local function lockTeleport()
    local newTarget = getTarget()
    
    if not newTarget then
        teleportButton.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
        teleportButton.Text = "NO TARGET"
        
        task.delay(1, function()
            if not teleportLocked then
                teleportButton.BackgroundColor3 = Color3.fromRGB(255, 59, 59)
                teleportButton.Text = "TELEPORT"
            end
        end)
        return false
    end
    
    targetPlayer = newTarget
    teleportLocked = true
    
    -- Cập nhật UI
    teleportButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    teleportButton.Text = "TELEPORTING"
    
    createArrow(targetPlayer)
    startContinuousTeleport()
    
    return true
end

-- Hàm xử lý click nút teleport
local function handleTeleportClick()
    local currentTime = tick()
    if currentTime - lastTeleportClickTime < CLICK_DELAY then
        return
    end
    lastTeleportClickTime = currentTime
    
    if teleportLocked then
        unlockTeleport()
    else
        lockTeleport()
    end
end

-- Hàm xử lý click nút tránh xa (KHÔNG CÓ DELAY)
local function handleAvoidClick()
    -- Nếu đang bật teleport thì tắt teleport trước
    if teleportLocked then
        unlockTeleport()
    end
    
    -- Nếu chưa có target, tìm target trước
    if not targetPlayer then
        targetPlayer = getTarget()
    end
    
    -- Thực hiện tránh xa MỘT LẦN (có thể spam liên tục)
    avoidTargetOnce()
end

-- Kết nối sự kiện nút
teleportButton.MouseButton1Click:Connect(handleTeleportClick)
avoidButton.MouseButton1Click:Connect(handleAvoidClick)

-- Cập nhật mục tiêu liên tục
local lastTargetUpdate = 0
local TARGET_UPDATE_COOLDOWN = 0.1

RunService.Heartbeat:Connect(function()
    if not player.Character then return end
    
    -- Giảm tần suất cập nhật mục tiêu
    local currentTime = tick()
    if currentTime - lastTargetUpdate < TARGET_UPDATE_COOLDOWN then
        return
    end
    lastTargetUpdate = currentTime
    
    local newTarget = getTarget()
    
    if teleportLocked then
        if targetPlayer and targetPlayer.Character then
            if not currentArrow then
                createArrow(targetPlayer)
            end
        else
            unlockAll()
        end
    else
        if newTarget then
            if not currentArrow or (currentArrow and newTarget ~= targetPlayer) then
                targetPlayer = newTarget
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
        unlockAll()
    end
end)

-- Tự động unlock khi respawn
player.CharacterAdded:Connect(function(character)
    task.wait(1)
    unlockAll()
end)

print("✅ Teleport & Avoid Script Đã Sẵn Sàng! (Spam tránh xa không delay)")
