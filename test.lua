-- LocalScript – đặt trong StarterPlayerScripts
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Teams = game:GetService("Teams")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Đợi playerGui load
local playerGui = player:WaitForChild("PlayerGui")

-- Tạo GUI
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
-- BIẾN TOÀN CỤC
-- ===========================================================================
local isLocked = false
local targetPlayer = nil
local currentArrow = nil
local followConnection = nil
local lastClickTime = 0
local CLICK_DELAY = 0.3

local aimEnabled = false
local currentTarget = nil
local aimConnection = nil
local espFolders = {}
local arrowGui = nil
local wallhackEnabled = true

-- Biến để theo dõi tất cả người chơi
local allPlayersESP = {}

-- ===========================================================================
-- HÀM CƠ BẢN - TỐI ƯU TỐC ĐỘ
-- ===========================================================================

-- Kiểm tra team - TỐI ƯU
local function isEnemy(targetPlayer)
    if targetPlayer == player then return false end
    if not player.Team then return true end
    if not targetPlayer.Team then return true end
    return player.Team ~= targetPlayer.Team
end

-- Kiểm tra vật cản SIÊU NHANH
local function hasClearLineOfSight(pointA, pointB, ignoreList)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = ignoreList or {}
    raycastParams.IgnoreWater = true
    
    local raycastResult = workspace:Raycast(pointA, (pointB - pointA), raycastParams)
    return not raycastResult
end

-- Kiểm tra địch có thể nhìn thấy mình - TỐI ƯU
local function canShootMe(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return false end
    if not player.Character then return false end
    
    local targetHead = targetPlayer.Character:FindFirstChild("Head")
    local playerHead = player.Character:FindFirstChild("Head")
    
    if not targetHead or not playerHead then return false end
    
    return hasClearLineOfSight(
        targetHead.Position, 
        playerHead.Position, 
        {targetPlayer.Character, player.Character}
    )
end

-- ===========================================================================
-- ESP CẬP NHẬT TỨC THÌ - KHÔNG ĐỘ TRỄ
-- ===========================================================================

local function createInstantESP(targetPlayer)
    if allPlayersESP[targetPlayer] then
        allPlayersESP[targetPlayer]:Destroy()
    end
    
    local folder = Instance.new("Folder")
    folder.Name = targetPlayer.Name .. "_ESP"
    folder.Parent = playerGui
    allPlayersESP[targetPlayer] = folder
    
    local function createHighlight(character)
        if not character or not character:IsDescendantOf(workspace) then return end
        
        -- Xóa highlight cũ
        for _, child in pairs(folder:GetChildren()) do
            child:Destroy()
        end
        
        -- Tạo highlight mới NGAY LẬP TỨC
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        
        -- Màu sắc dựa trên mức độ nguy hiểm
        if canShootMe(targetPlayer) then
            highlight.FillColor = Color3.fromRGB(255, 0, 0)  -- Đỏ rực: cực kỳ nguy hiểm
            highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
        else
            highlight.FillColor = Color3.fromRGB(255, 100, 100) -- Đỏ nhạt: kẻ địch thường
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        end
        
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Adornee = character
        highlight.Parent = folder
        highlight.Enabled = wallhackEnabled
    end
    
    -- Xử lý character hiện tại NGAY LẬP TỨC
    if targetPlayer.Character then
        createHighlight(targetPlayer.Character)
    end
    
    -- Kết nối sự kiện CharacterAdded - CẬP NHẬT TỨC THÌ
    local characterConnection
    characterConnection = targetPlayer.CharacterAdded:Connect(function(character)
        createHighlight(character)
        
        -- Kết nối sự kiện humanoid để biết khi chết
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.Died:Connect(function()
            -- Khi chết, đánh dấu để tạo lại ESP khi respawn
            wait() -- Đợi 1 frame
        end)
    end)
    
    -- Lưu kết nối để cleanup sau
    folder:SetAttribute("CharacterConnection", characterConnection)
end

local function initializeInstantWallhack()
    -- Xóa toàn bộ ESP cũ
    for targetPlayer, folder in pairs(allPlayersESP) do
        if folder then
            local conn = folder:GetAttribute("CharacterConnection")
            if conn then conn:Disconnect() end
            folder:Destroy()
        end
    end
    allPlayersESP = {}
    
    -- Tạo ESP cho tất cả người chơi NGAY LẬP TỨC
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            createInstantESP(otherPlayer)
        end
    end
end

local function toggleWallhack()
    wallhackEnabled = not wallhackEnabled
    
    for targetPlayer, folder in pairs(allPlayersESP) do
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

-- ===========================================================================
-- AIMBOT THÔNG MINH - ƯU TIÊN MỤC TIÊU NGUY HIỂM NHẤT
-- ===========================================================================

local function findMostDangerousTarget()
    if not player.Character then return nil end
    
    local camPos = camera.CFrame.Position
    local bestTarget = nil
    local highestThreatLevel = -1
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and isEnemy(otherPlayer) and otherPlayer.Character then
            local humanoid = otherPlayer.Character:FindFirstChild("Humanoid")
            local rootPart = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart then
                local threatLevel = 0
                local distance = (rootPart.Position - camPos).Magnitude
                
                -- ƯU TIÊN CAO NHẤT: Mục tiêu có thể bắn mình (đang nhìn thấy mình)
                if canShootMe(otherPlayer) then
                    threatLevel = threatLevel + 1000  -- Điểm cực cao cho mục tiêu nguy hiểm
                    
                    -- Thêm điểm thưởng nếu mục tiêu rất gần
                    if distance < 10 then
                        threatLevel = threatLevel + 500  -- Cực kỳ nguy hiểm
                    elseif distance < 25 then
                        threatLevel = threatLevel + 300  -- Rất nguy hiểm
                    end
                end
                
                -- Ưu tiên mục tiêu trong tầm nhìn của mình
                local isVisibleToMe = hasClearLineOfSight(
                    camPos, 
                    rootPart.Position, 
                    {player.Character, otherPlayer.Character}
                )
                if isVisibleToMe then
                    threatLevel = threatLevel + 200
                end
                
                -- Ưu tiên mục tiêu gần
                threatLevel = threatLevel + (100 - math.min(distance / 5, 100))
                
                -- Ưu tiên mục tiêu máu thấp (dễ tiêu diệt)
                threatLevel = threatLevel + (100 - humanoid.Health)
                
                -- Chọn mục tiêu có mức độ đe dọa cao nhất
                if threatLevel > highestThreatLevel then
                    highestThreatLevel = threatLevel
                    bestTarget = otherPlayer
                end
            end
        end
    end
    
    return bestTarget
end

local function preciseAim(target)
    if not target or not target.Character then return end
    if not camera then return end
    
    local targetPart = target.Character:FindFirstChild("Head") or 
                      target.Character:FindFirstChild("UpperTorso") or 
                      target.Character:FindFirstChild("HumanoidRootPart")
    
    if not targetPart then return end
    
    local camPos = camera.CFrame.Position
    local targetPos = targetPart.Position
    
    -- Aim chính xác 100%
    camera.CFrame = CFrame.new(camPos, targetPos)
end

local function showTargetArrow(target)
    if arrowGui then 
        arrowGui:Destroy()
        arrowGui = nil
    end
    
    if not target or not target.Character then return end
    
    local head = target.Character:FindFirstChild("Head")
    if not head then return end

    local gui = Instance.new("BillboardGui")
    gui.Name = "TargetArrow"
    gui.Size = UDim2.new(0, 50, 0, 50)
    gui.AlwaysOnTop = true
    gui.Adornee = head
    gui.MaxDistance = 1000
    gui.SizeOffset = Vector2.new(0, 2)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "🔴"
    label.TextColor3 = Color3.fromRGB(255, 0, 0)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = gui

    gui.Parent = head
    arrowGui = gui
end

local function removeTargetArrow()
    if arrowGui then
        arrowGui:Destroy()
        arrowGui = nil
    end
end

-- ===========================================================================
-- TELEPORT TỐI ƯU
-- ===========================================================================

local function smartTeleportToTarget(target)
    if not target or not target.Character then return false end
    if not player.Character then return false end
    
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    local playerRoot = player.Character:FindFirstChild("HumanoidRootPart")
    
    if not targetRoot or not playerRoot then return false end
    
    local targetCF = targetRoot.CFrame
    local teleportPosition = targetCF.Position - targetCF.LookVector * 3
    
    -- Kiểm tra vật cản
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {player.Character, target.Character}
    
    local raycastResult = workspace:Raycast(targetRoot.Position, (teleportPosition - targetRoot.Position), raycastParams)
    
    if not raycastResult then
        playerRoot.CFrame = CFrame.new(teleportPosition) * CFrame.Angles(0, math.rad(180), 0)
        return true
    else
        -- Thử các vị trí khác
        local positions = {
            targetCF.Position + targetCF.RightVector * 3,
            targetCF.Position - targetCF.RightVector * 3,
            targetCF.Position + targetCF.LookVector * 3
        }
        
        for _, pos in ipairs(positions) do
            local ray = workspace:Raycast(targetRoot.Position, (pos - targetRoot.Position), raycastParams)
            if not ray then
                playerRoot.CFrame = CFrame.new(pos)
                return true
            end
        end
    end
    
    return false
end

local function createTeleportArrow(target)
    if currentArrow then
        currentArrow:Destroy()
        currentArrow = nil
    end
    
    if not target or not target.Character then return end
    
    local head = target.Character:FindFirstChild("Head")
    if not head then return end
    
    local arrowGui = Instance.new("BillboardGui")
    arrowGui.Name = "TeleportArrow"
    arrowGui.Size = UDim2.new(0, 50, 0, 50)
    arrowGui.AlwaysOnTop = true
    arrowGui.Enabled = true
    arrowGui.Adornee = head
    arrowGui.MaxDistance = 500
    
    local arrowLabel = Instance.new("TextLabel")
    arrowLabel.Size = UDim2.new(1, 0, 1, 0)
    arrowLabel.BackgroundTransparency = 1
    arrowLabel.Text = "🔒"
    arrowLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    arrowLabel.TextScaled = true
    arrowLabel.Font = Enum.Font.GothamBold
    arrowLabel.Parent = arrowGui
    
    arrowGui.Parent = head
    currentArrow = arrowGui
    
    return arrowGui
end

-- ===========================================================================
-- ĐIỀU KHIỂN AIMBOT
-- ===========================================================================

aimButton.MouseButton1Click:Connect(function()
    aimEnabled = not aimEnabled
    
    if aimEnabled then
        aimButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        aimButton.Text = "AIM ON"
        
        -- Bắt đầu aimbot thông minh
        if aimConnection then 
            aimConnection:Disconnect() 
        end
        
        aimConnection = RunService.RenderStepped:Connect(function()
            if not aimEnabled then return end
            
            -- Luôn tìm mục tiêu nguy hiểm nhất mỗi frame
            local newTarget = findMostDangerousTarget()
            
            if newTarget then
                if currentTarget ~= newTarget then
                    currentTarget = newTarget
                    showTargetArrow(currentTarget)
                end
                preciseAim(currentTarget)
            else
                currentTarget = nil
                removeTargetArrow()
            end
        end)
        
    else
        aimButton.BackgroundColor3 = Color3.fromRGB(59, 59, 255)
        aimButton.Text = "AIM OFF"
        
        if aimConnection then 
            aimConnection:Disconnect() 
            aimConnection = nil
        end
        
        currentTarget = nil
        removeTargetArrow()
    end
end)

-- ===========================================================================
-- ĐIỀU KHIỂN TELEPORT
-- ===========================================================================

local function unlockTeleport()
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

local function lockTeleport()
    local newTarget = findMostDangerousTarget()
    
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
    
    createTeleportArrow(targetPlayer)
    smartTeleportToTarget(targetPlayer)
    
    -- Theo dõi liên tục
    if followConnection then
        followConnection:Disconnect()
    end
    
    followConnection = RunService.Heartbeat:Connect(function()
        if not isLocked then return end
        if not targetPlayer or not targetPlayer.Character then
            unlockTeleport()
            return
        end
        
        local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local playerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        
        if targetRoot and playerRoot then
            local distance = (targetRoot.Position - playerRoot.Position).Magnitude
            if distance > 6 then
                smartTeleportToTarget(targetPlayer)
            end
        end
    end)
    
    return true
end

teleportButton.MouseButton1Click:Connect(function()
    local currentTime = tick()
    if currentTime - lastClickTime < CLICK_DELAY then
        return
    end
    lastClickTime = currentTime
    
    if isLocked then
        unlockTeleport()
    else
        lockTeleport()
    end
end)

teleportButton.MouseButton2Click:Connect(toggleWallhack)

-- ===========================================================================
-- HỆ THỐNG CẬP NHẬT TỰ ĐỘNG 100% - KHÔNG ĐỘ TRỄ
-- ===========================================================================

-- Khi có người chơi mới tham gia - CẬP NHẬT NGAY
Players.PlayerAdded:Connect(function(newPlayer)
    createInstantESP(newPlayer)
end)

-- Khi người chơi rời game - XÓA NGAY
Players.PlayerRemoving:Connect(function(leavingPlayer)
    if allPlayersESP[leavingPlayer] then
        local folder = allPlayersESP[leavingPlayer]
        local conn = folder:GetAttribute("CharacterConnection")
        if conn then conn:Disconnect() end
        folder:Destroy()
        allPlayersESP[leavingPlayer] = nil
    end
    
    if leavingPlayer == targetPlayer then
        unlockTeleport()
    end
    
    if leavingPlayer == currentTarget then
        currentTarget = nil
        removeTargetArrow()
    end
end)

-- Khi LOCAL PLAYER respawn - CẬP NHẬT LẠI TOÀN BỘ NGAY LẬP TỨC
player.CharacterAdded:Connect(function(character)
    unlockTeleport()
    
    -- Cập nhật lại ESP cho tất cả người chơi sau khi respawn
    wait(0.1) -- Đợi 1 frame
    for targetPlayer, folder in pairs(allPlayersESP) do
        if folder and targetPlayer.Character then
            for _, child in pairs(folder:GetChildren()) do
                if child:IsA("Highlight") then
                    child.Adornee = targetPlayer.Character
                end
            end
        end
    end
end)

-- Tự động cập nhật ESP khi team thay đổi
if player:FindFirstChild("Team") then
    player.TeamChanged:Connect(function()
        wait(0.1)
        for targetPlayer, folder in pairs(allPlayersESP) do
            if folder and targetPlayer.Character then
                for _, child in pairs(folder:GetChildren()) do
                    if child:IsA("Highlight") then
                        if canShootMe(targetPlayer) then
                            child.FillColor = Color3.fromRGB(255, 0, 0)
                            child.OutlineColor = Color3.fromRGB(255, 255, 0)
                        else
                            child.FillColor = Color3.fromRGB(255, 100, 100)
                            child.OutlineColor = Color3.fromRGB(255, 255, 255)
                        end
                    end
                end
            end
        end
    end)
end

-- ===========================================================================
-- KHỞI TẠO HỆ THỐNG
-- ===========================================================================

-- Khởi tạo ngay khi script chạy
initializeInstantWallhack()

print("🎯 HỆ THỐNG ĐÃ SẴN SÀNG 100%")
print("✅ ESP: Cập nhật tức thì")
print("✅ Aimbot: Ưu tiên mục tiêu nguy hiểm nhất") 
print("✅ Teleport: Hoạt động mượt")
