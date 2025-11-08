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
local CLICK_DELAY = 0.3 -- Tránh double click

-- Hàm tính góc giữa 2 vector
local function getAngleBetweenVectors(v1, v2)
    return math.acos(v1:Dot(v2) / (v1.Magnitude * v2.Magnitude))
end

-- Tìm người chơi trong tầm nhìn
local function getTarget()
    local bestTarget = nil
    local smallestAngle = math.rad(30) -- Góc 30 độ
    
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
    -- Xóa mũi tên cũ
    if currentArrow then
        currentArrow:Destroy()
        currentArrow = nil
    end
    
    if not target or not target.Character then return end
    
    local head = target.Character:FindFirstChild("Head")
    if not head then return end
    
    -- Tạo BillboardGui với mũi tên
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

-- Teleport ra sau lưng mục tiêu
local function teleportBehind(target)
    if not target or not target.Character then return false end
    
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    local playerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    
    if not targetRoot or not playerRoot then return false end
    
    -- Tính vị trí PHÍA SAU lưng
    local targetCFrame = targetRoot.CFrame
    local lookVector = targetCFrame.LookVector
    local behindPosition = targetCFrame.Position - (lookVector * 3)
    
    -- Kiểm tra vật cản
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {player.Character, target.Character}
    
    local raycastResult = workspace:Raycast(
        targetRoot.Position,
        -lookVector * 5,
        raycastParams
    )
    
    local finalPosition
    if raycastResult then
        finalPosition = raycastResult.Position + lookVector * 2
    else
        finalPosition = behindPosition
    end
    
    -- Quay mặt về phía mục tiêu
    local backCFrame = CFrame.new(finalPosition, targetRoot.Position)
    
    -- Thực hiện teleport
    playerRoot.CFrame = backCFrame
    
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
                
                -- Teleport liên tục khi khoảng cách > 3 studs
                if distance > 3 then
                    teleportBehind(targetPlayer)
                end
            end
        else
            -- Mục tiêu biến mất
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
    
    print("🔓 Đã mở khóa")
end

-- Hàm lock target
local function lockTarget()
    local newTarget = getTarget()
    
    if not newTarget then
        -- Không có mục tiêu
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
    
    -- Đặt mục tiêu và bật lock
    targetPlayer = newTarget
    isLocked = true
    
    -- Cập nhật giao diện
    teleportButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    teleportButton.Text = "LOCKED"
    
    -- Tạo mũi tên
    createArrow(targetPlayer)
    
    -- Bắt đầu follow liên tục
    startContinuousFollow()
    
    -- Teleport ngay lập tức
    teleportBehind(targetPlayer)
    
    print("🔒 Đã khóa: " .. targetPlayer.Name)
    return true
end

-- Hàm xử lý click chính - BẤM 1 LẦN
local function handleButtonClick()
    -- Chống double click
    local currentTime = tick()
    if currentTime - lastClickTime < CLICK_DELAY then
        return
    end
    lastClickTime = currentTime
    
    if isLocked then
        -- Nếu đang lock thì unlock
        unlockTarget()
    else
        -- Nếu chưa lock thì lock
        lockTarget()
    end
end

-- Kết nối sự kiện nút - SỬ DỤNG MouseButton1Click (không phải MouseButton1Down)
teleportButton.MouseButton1Click:Connect(handleButtonClick)
teleportButton.TouchTap:Connect(handleButtonClick)

-- Cập nhật mục tiêu liên tục
RunService.Heartbeat:Connect(function()
    if not player.Character then return end
    
    local newTarget = getTarget()
    
    if isLocked then
        -- Đang lock: chỉ cập nhật mũi tên nếu có mục tiêu
        if targetPlayer and targetPlayer.Character then
            if not currentArrow then
                createArrow(targetPlayer)
            end
        else
            -- Mục tiêu biến mất
            unlockTarget()
        end
    else
        -- Chưa lock: cập nhật mục tiêu mới
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
print("🎯 Nhìn vào người chơi - mũi tên xuất hiện")
print("🔒 Bấm 1 lần để KHÓA và THEO LIÊN TỤC")
print("🔓 Bấm 1 lần nữa để MỞ KHÓA")
