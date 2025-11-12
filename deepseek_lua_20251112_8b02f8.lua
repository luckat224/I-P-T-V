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
buttonContainer.Size = UDim2.new(0, 80, 0, 200)
buttonContainer.Position = UDim2.new(0, 20, 0.5, -100)
buttonContainer.AnchorPoint = Vector2.new(0, 0.5)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = gui

-- Nút Tốc Độ
local speedButton = Instance.new("TextButton")
speedButton.Size = UDim2.new(1, 0, 0.25, -5)
speedButton.Position = UDim2.new(0, 0, 0, 0)
speedButton.Text = "TỐC ĐỘ: 1x"
speedButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
speedButton.TextColor3 = Color3.new(1, 1, 1)
speedButton.TextSize = 12
speedButton.Font = Enum.Font.GothamBold
speedButton.BorderSizePixel = 0
speedButton.AutoButtonColor = false
speedButton.Parent = buttonContainer

-- Bo tròn nút tốc độ
local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(1, 0)
speedCorner.Parent = speedButton

-- Nút Teleport chính
local teleportButton = Instance.new("TextButton")
teleportButton.Size = UDim2.new(1, 0, 0.375, -5)
teleportButton.Position = UDim2.new(0, 0, 0.25, 0)
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

-- Nút Tránh xa
local avoidButton = Instance.new("TextButton")
avoidButton.Size = UDim2.new(1, 0, 0.375, -5)
avoidButton.Position = UDim2.new(0, 0, 0.625, 5)
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

-- GUI điều chỉnh tốc độ
local speedSliderGui = Instance.new("Frame")
speedSliderGui.Size = UDim2.new(0, 200, 0, 80)
speedSliderGui.Position = UDim2.new(0, 100, 0, 0)
speedSliderGui.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
speedSliderGui.BorderSizePixel = 0
speedSliderGui.Visible = false
speedSliderGui.Parent = buttonContainer

-- Bo tròn cho GUI tốc độ
local speedGuiCorner = Instance.new("UICorner")
speedGuiCorner.CornerRadius = UDim.new(0.1, 0)
speedGuiCorner.Parent = speedSliderGui

-- Thanh trượt tốc độ
local speedSlider = Instance.new("Frame")
speedSlider.Size = UDim2.new(0.8, 0, 0, 6)
speedSlider.Position = UDim2.new(0.1, 0, 0.4, 0)
speedSlider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
speedSlider.BorderSizePixel = 0
speedSlider.Parent = speedSliderGui

-- Bo tròn thanh trượt
local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(1, 0)
sliderCorner.Parent = speedSlider

-- Con trỏ thanh trượt
local speedKnob = Instance.new("Frame")
speedKnob.Size = UDim2.new(0, 20, 0, 20)
speedKnob.Position = UDim2.new(0, 0, 0.5, -10)
speedKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
speedKnob.BorderSizePixel = 0
speedKnob.Parent = speedSlider

-- Bo tròn con trỏ
local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1, 0)
knobCorner.Parent = speedKnob

-- Hiển thị giá trị tốc độ
local speedValueLabel = Instance.new("TextLabel")
speedValueLabel.Size = UDim2.new(1, 0, 0.3, 0)
speedValueLabel.Position = UDim2.new(0, 0, 0.1, 0)
speedValueLabel.BackgroundTransparency = 1
speedValueLabel.Text = "Tốc độ: 1x"
speedValueLabel.TextColor3 = Color3.new(1, 1, 1)
speedValueLabel.TextSize = 14
speedValueLabel.Font = Enum.Font.GothamBold
speedValueLabel.Parent = speedSliderGui

-- Nút đóng
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 80, 0, 25)
closeButton.Position = UDim2.new(0.3, 0, 0.7, 0)
closeButton.Text = "ĐÓNG"
closeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.TextSize = 12
closeButton.Font = Enum.Font.GothamBold
closeButton.BorderSizePixel = 0
closeButton.Parent = speedSliderGui

-- Bo tròn nút đóng
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0.2, 0)
closeCorner.Parent = closeButton

-- Biến điều khiển
local teleportLocked = false
local targetPlayer = nil
local currentArrow = nil
local teleportConnection = nil
local lastTeleportClickTime = 0
local CLICK_DELAY = 0.3
local AVOID_DISTANCE = 20
local lastTeleportTime = 0
local TELEPORT_COOLDOWN = 0.2

-- Biến tốc độ
local currentSpeedMultiplier = 1
local minSpeed = 1
local maxSpeed = 10
local isSpeedSliderVisible = false
local isDraggingSpeed = false

-- Hàm cập nhật tốc độ nhân vật
local function updatePlayerSpeed()
    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if not humanoid:GetAttribute("OriginalWalkSpeed") then
                humanoid:SetAttribute("OriginalWalkSpeed", humanoid.WalkSpeed)
            end
            
            local originalSpeed = humanoid:GetAttribute("OriginalWalkSpeed") or 16
            humanoid.WalkSpeed = originalSpeed * currentSpeedMultiplier
        end
    end
end

-- Hàm cập nhật giao diện tốc độ
local function updateSpeedUI()
    speedButton.Text = "TỐC ĐỘ: " .. currentSpeedMultiplier .. "x"
    speedValueLabel.Text = "Tốc độ: " .. currentSpeedMultiplier .. "x"
    
    local sliderWidth = speedSlider.AbsoluteSize.X
    local knobWidth = speedKnob.AbsoluteSize.X
    local availableWidth = sliderWidth - knobWidth
    
    local normalizedValue = (currentSpeedMultiplier - minSpeed) / (maxSpeed - minSpeed)
    local knobPosition = normalizedValue * availableWidth
    
    speedKnob.Position = UDim2.new(0, knobPosition, 0.5, -10)
    
    if currentSpeedMultiplier == 1 then
        speedButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    elseif currentSpeedMultiplier < 1 then
        speedButton.BackgroundColor3 = Color3.fromRGB(150, 100, 100)
    else
        speedButton.BackgroundColor3 = Color3.fromRGB(100, 150, 100)
    end
end

-- Hàm hiển thị/ẩn thanh trượt tốc độ
local function toggleSpeedSlider()
    isSpeedSliderVisible = not isSpeedSliderVisible
    speedSliderGui.Visible = isSpeedSliderVisible
end

-- Hàm xử lý kéo thanh trượt (hỗ trợ cả cảm ứng và chuột)
local function handleSpeedDrag(input)
    local sliderAbsolutePosition = speedSlider.AbsolutePosition
    local sliderAbsoluteSize = speedSlider.AbsoluteSize
    local knobWidth = speedKnob.AbsoluteSize.X
    
    local mousePosition
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.MouseButton1 then
        mousePosition = input.Position
    elseif input.UserInputType == Enum.UserInputType.Touch then
        mousePosition = input.Position
    else
        return
    end
    
    -- Tính vị trí tương đối của chuột/cảm ứng trong thanh trượt
    local relativeX = math.clamp(
        mousePosition.X - sliderAbsolutePosition.X,
        0,
        sliderAbsoluteSize.X
    )
    
    -- Tính giá trị tốc độ dựa trên vị trí
    local normalizedValue = relativeX / sliderAbsoluteSize.X
    currentSpeedMultiplier = minSpeed + normalizedValue * (maxSpeed - minSpeed)
    currentSpeedMultiplier = math.floor(currentSpeedMultiplier * 10) / 10
    
    updatePlayerSpeed()
    updateSpeedUI()
end

-- Hàm bắt đầu kéo thanh trượt
local function startSpeedDrag(input)
    isDraggingSpeed = true
    
    -- Xử lý ngay vị trí ban đầu
    handleSpeedDrag(input)
    
    -- Kết nối sự kiện di chuyển
    local dragConnection
    dragConnection = UserInputService.InputChanged:Connect(function(inputChanged)
        if isDraggingSpeed and (inputChanged.UserInputType == Enum.UserInputType.MouseMovement or inputChanged.UserInputType == Enum.UserInputType.Touch) then
            handleSpeedDrag(inputChanged)
        end
    end)
    
    -- Kết nối sự kiện kết thúc
    local releaseConnection
    releaseConnection = UserInputService.InputEnded:Connect(function(inputEnded)
        if inputEnded.UserInputType == Enum.UserInputType.MouseButton1 or inputEnded.UserInputType == Enum.UserInputType.Touch then
            isDraggingSpeed = false
            if dragConnection then
                dragConnection:Disconnect()
            end
            if releaseConnection then
                releaseConnection:Disconnect()
            end
        end
    end)
end

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
    
    local currentTime = tick()
    if currentTime - lastTeleportTime < TELEPORT_COOLDOWN then
        return false
    end
    lastTeleportTime = currentTime
    
    local targetCFrame = targetRoot.CFrame
    local lookVector = targetCFrame.LookVector
    
    local behindPosition = targetCFrame.Position - lookVector * 3
    
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
        finalPosition = targetCFrame.Position + targetCFrame.RightVector * 3
    end
    
    local newCFrame = CFrame.new(finalPosition) * (playerRoot.CFrame - playerRoot.Position)
    playerRoot.CFrame = newCFrame
    
    return true
end

-- Tránh xa mục tiêu MỘT LẦN
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
    
    local toPlayer = (playerRoot.Position - targetRoot.Position)
    local direction = toPlayer.Unit
    local targetPosition = targetRoot.Position + direction * AVOID_DISTANCE
    
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
    
    local currentRotation = playerRoot.CFrame - playerRoot.Position
    local newCFrame = CFrame.new(finalPosition) * currentRotation
    playerRoot.CFrame = newCFrame
    
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
        
        if tick() - lastTeleportTime < TELEPORT_COOLDOWN then
            return
        end
        
        if targetPlayer and targetPlayer.Character and player.Character then
            local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local playerRoot = player.Character:FindFirstChild("HumanoidRootPart")
            
            if targetRoot and playerRoot then
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

-- Hàm xử lý click nút tránh xa
local function handleAvoidClick()
    if teleportLocked then
        unlockTeleport()
    end
    
    if not targetPlayer then
        targetPlayer = getTarget()
    end
    
    avoidTargetOnce()
end

-- Kết nối sự kiện nút
teleportButton.MouseButton1Click:Connect(handleTeleportClick)
avoidButton.MouseButton1Click:Connect(handleAvoidClick)
speedButton.MouseButton1Click:Connect(toggleSpeedSlider)
closeButton.MouseButton1Click:Connect(toggleSpeedSlider)

-- Kết nối sự kiện kéo thanh trượt (hỗ trợ cả cảm ứng và chuột)
speedKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        startSpeedDrag(input)
    end
end)

speedSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        startSpeedDrag(input)
        handleSpeedDrag(input)
    end
end)

-- Cập nhật mục tiêu liên tục
local lastTargetUpdate = 0
local TARGET_UPDATE_COOLDOWN = 0.1

RunService.Heartbeat:Connect(function()
    if not player.Character then return end
    
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

-- Tự động unlock khi respawn và cập nhật tốc độ
player.CharacterAdded:Connect(function(character)
    task.wait(1)
    unlockAll()
    updatePlayerSpeed()
end)

-- Khởi tạo tốc độ ban đầu
updatePlayerSpeed()
updateSpeedUI()

print("✅ Teleport & Avoid & Speed Control Script Đã Sẵn Sàng! (Hỗ trợ cảm ứng)")