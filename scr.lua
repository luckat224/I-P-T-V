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

-- Bo tròn nút
local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(1, 0)
buttonCorner.Parent = teleportButton

-- Biến điều khiển
local isLocked = false
local targetPlayer = nil
local currentArrow = nil
local followConnection = nil
local lastClickTime = 0
local CLICK_DELAY = 0.3

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
    arrowLabel.Text = isLocked and "🔒" or "🎯"
    arrowLabel.TextColor3 = isLocked and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
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

-- Hàm unlock target
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
    
    teleportButton.BackgroundColor3 = Color3.fromRGB(255, 59, 59)
    teleportButton.Text = "TELEPORT"
end

-- Hàm lock target
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
    
    teleportButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    teleportButton.Text = "LOCKED"
    
    createArrow(targetPlayer)
    startContinuousFollow()
    teleportClose(targetPlayer)
    
    return true
end

-- Hàm xử lý click chính
local function handleButtonClick()
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

-- Kết nối sự kiện nút
teleportButton.MouseButton1Click:Connect(handleButtonClick)
teleportButton.TouchTap:Connect(handleButtonClick)

-- Cập nhật mục tiêu liên tục
RunService.Heartbeat:Connect(function()
    if not player.Character then return end
    
    local newTarget = getTarget()
    
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

print("✅ Teleport Script Đã Sẵn Sàng!")
