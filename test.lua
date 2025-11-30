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

-- Kiểm tra team - CHỈ AIM ĐỊCH
local function isEnemy(targetPlayer)
    if targetPlayer == player then return false end
    
    -- Nếu không có hệ thống team, coi tất cả là địch (trừ bản thân)
    if not game:GetService("Teams"):GetChildren() or #game:GetService("Teams"):GetChildren() == 0 then
        return true
    end
    
    -- Nếu người chơi không có team, không aim
    if not player.Team then return false end
    if not targetPlayer.Team then return false end
    
    -- Chỉ aim nếu khác team
    return player.Team ~= targetPlayer.Team
end

-- Hàm tìm người chơi mà camera đang nhìn
local function getPlayerInSight()
    if not player.Character then return nil end
    
    local camera = workspace.CurrentCamera
    local cameraPosition = camera.CFrame.Position
    local cameraDirection = camera.CFrame.LookVector
    
    local closestPlayer = nil
    local closestDistance = math.huge
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local humanoid = otherPlayer.Character:FindFirstChild("Humanoid")
            local head = otherPlayer.Character:FindFirstChild("Head")
            
            if humanoid and humanoid.Health > 0 and head then
                -- Tính vector từ camera đến player
                local toPlayer = head.Position - cameraPosition
                local distance = toPlayer.Magnitude
                
                -- Tính góc giữa hướng camera và hướng đến player
                local dot = cameraDirection:Dot(toPlayer.Unit)
                
                -- Nếu player nằm trong tầm nhìn (góc nhỏ) và gần hơn
                if dot > 0.9 then -- Góc ~25 độ
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = otherPlayer
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

-- ===========================================================================
-- ESP CẬP NHẬT TỨC THÌ - KÍCH HOẠT NGAY KHI CHẠY CODE
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
        
        -- Màu sắc dựa trên team
        if isEnemy(targetPlayer) then
            highlight.FillColor = Color3.fromRGB(255, 50, 50)  -- Đỏ: địch
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        else
            highlight.FillColor = Color3.fromRGB(50, 150, 255)  -- Xanh: đồng đội
            highlight.OutlineColor = Color3.fromRGB(200, 200, 200)
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
    
    print("🟢 WALLHACK ĐÃ KÍCH HOẠT NGAY LẬP TỨC!")
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
        print("🔵 Wallhack: BẬT")
    else
        teleportButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        print("🔴 Wallhack: TẮT")
    end
end

-- ===========================================================================
-- AIMBOT THÔNG MINH - CHỈ AIM ĐỊCH TRONG TRẬN
-- ===========================================================================

local function findMostDangerousTarget()
    if not player.Character then return nil end
    
    local camPos = camera.CFrame.Position
    local bestTarget = nil
    local highestThreatLevel = -1
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        -- CHỈ AIM ĐỊCH - KHÔNG AIM ĐỒNG ĐỘI
        if otherPlayer ~= player and isEnemy(otherPlayer) and otherPlayer.Character then
            local humanoid = otherPlayer.Character:FindFirstChild("Humanoid")
            local rootPart = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart then
                local threatLevel = 0
                local distance = (rootPart.Position - camPos).Magnitude
                
                -- Ưu tiên mục tiêu trong tầm nhìn của mình
                local camDir = camera.CFrame.LookVector
                local toTarget = (rootPart.Position - camPos).Unit
                local dot = camDir:Dot(toTarget)
                
                if dot > 0.9 then
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
    label.Text = "🎯"
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
-- TELEPORT ĐẾN NGƯỜI CAMERA ĐANG NHÌN
-- ===========================================================================

local function smartTeleportToTarget(target)
    if not target or not target.Character then return false end
    if not player.Character then return false end
    
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    local playerRoot = player.Character:FindFirstChild("HumanoidRootPart")
    
    if not targetRoot or not playerRoot then return false end
    
    local targetCF = targetRoot.CFrame
    local teleportPosition = targetCF.Position - targetCF.LookVector * 4
    
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
-- ĐIỀU KHIỂN AIMBOT - CHỈ AIM ĐỊCH
-- ===========================================================================

aimButton.MouseButton1Click:Connect(function()
    aimEnabled = not aimEnabled
    
    if aimEnabled then
        aimButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        aimButton.Text = "AIM ON"
        
        -- Bắt đầu aimbot thông minh - CHỈ AIM ĐỊCH
        if aimConnection then 
            aimConnection:Disconnect() 
        end
        
        aimConnection = RunService.RenderStepped:Connect(function()
            if not aimEnabled then return end
            
            -- Luôn tìm mục tiêu nguy hiểm nhất mỗi frame - CHỈ ĐỊCH
            local newTarget = findMostDangerousTarget()
            
            if newTarget then
                if currentTarget ~= newTarget then
                    currentTarget = newTarget
                    showTargetArrow(currentTarget)
                    print("🎯 Đã khóa mục tiêu: " .. currentTarget.Name .. " (Địch)")
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
-- ĐIỀU KHIỂN TELEPORT - TELEPORT ĐẾN NGƯỜI CAMERA ĐANG NHÌN
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
    -- TÌM NGƯỜI CHƠI MÀ CAMERA ĐANG NHÌN (KHÔNG PHÂN BIỆT TEAM)
    local newTarget = getPlayerInSight()
    
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
    
    print("🔒 Đã khóa teleport đến: " .. targetPlayer.Name)
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
-- HỆ THỐNG CẬP NHẬT TỰ ĐỘNG 100% - KÍCH HOẠT WALL NGAY KHI CHẠY CODE
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
    wait(0.1)
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
                        if isEnemy(targetPlayer) then
                            child.FillColor = Color3.fromRGB(255, 50, 50)
                            child.OutlineColor = Color3.fromRGB(255, 255, 255)
                        else
                            child.FillColor = Color3.fromRGB(50, 150, 255)
                            child.OutlineColor = Color3.fromRGB(200, 200, 200)
                        end
                    end
                end
            end
        end
    end)
end

-- ===========================================================================
-- KHỞI TẠO HỆ THỐNG - KÍCH HOẠT WALL NGAY KHI CHẠY CODE
-- ===========================================================================

-- KÍCH HOẠT WALLHACK NGAY KHI CHẠY CODE
wait(0.5) -- Đợi game load một chút
initializeInstantWallhack()

print("")
print("🎯 HỆ THỐNG ĐÃ SẴN SÀNG 100%")
print("===========================================")
print("✅ WALLHACK: Đã kích hoạt ngay lập tức")
print("✅ AIMBOT: Chỉ aim địch trong trận") 
print("✅ TELEPORT: Teleport đến người camera đang nhìn")
print("✅ ESP: Phân biệt đồng đội (xanh) và địch (đỏ)")
print("===========================================")
print("📌 Hướng dẫn sử dụng:")
print("   - Click TRÁI nút AIM: Bật/Tắt Aimbot (chỉ aim địch)")
print("   - Click TRÁI nút TELEPORT: Teleport đến người camera đang nhìn") 
print("   - Click PHẢI nút TELEPORT: Bật/Tắt Wallhack")
print("===========================================")
