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

-- ===========================================================================
-- HÀM CƠ BẢN
-- ===========================================================================

-- Kiểm tra team
local function isEnemy(targetPlayer)
    if not player.Team then return true end
    if not targetPlayer.Team then return true end
    return player.Team ~= targetPlayer.Team
end

-- Kiểm tra vật cản đơn giản
local function hasClearLineOfSight(pointA, pointB, ignoreList)
    local direction = (pointB - pointA)
    local distance = direction.Magnitude
    if distance == 0 then return true end
    direction = direction.Unit
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = ignoreList or {}
    raycastParams.IgnoreWater = true
    
    local raycastResult = workspace:Raycast(pointA, direction * distance, raycastParams)
    return not raycastResult
end

-- Kiểm tra địch có thể nhìn thấy mình
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
-- WALLHACK TỰ ĐỘNG CẬP NHẬT
-- ===========================================================================

local function createESP(targetPlayer)
    if espFolders[targetPlayer] then
        espFolders[targetPlayer]:Destroy()
        espFolders[targetPlayer] = nil
    end
    
    local folder = Instance.new("Folder")
    folder.Name = targetPlayer.Name .. "_ESP"
    folder.Parent = playerGui
    espFolders[targetPlayer] = folder
    
    local function setupCharacter(character)
        if character and character:IsDescendantOf(workspace) then
            -- Đảm bảo xóa highlight cũ
            for _, child in pairs(folder:GetChildren()) do
                if child:IsA("Highlight") then
                    child:Destroy()
                end
            end
            
            -- Tạo highlight mới
            local highlight = Instance.new("Highlight")
            highlight.Name = "ESP_Highlight"
            highlight.FillColor = Color3.fromRGB(255, 50, 50)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.7
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Adornee = character
            highlight.Parent = folder
            highlight.Enabled = wallhackEnabled
            
            -- Kết nối sự kiện khi character bị destroy
            character.Destroying:Connect(function()
                if folder and folder.Parent then
                    folder:Destroy()
                    espFolders[targetPlayer] = nil
                end
            end)
            
            -- Theo dõi humanoid để biết khi chết
            local humanoid = character:WaitForChild("Humanoid")
            if humanoid then
                humanoid.Died:Connect(function()
                    -- Khi chết, đánh dấu để xóa ESP
                    if folder and folder.Parent then
                        folder:Destroy()
                        espFolders[targetPlayer] = nil
                    end
                end)
            end
            
            print("✅ Đã tạo ESP cho: " .. targetPlayer.Name)
        end
    end
    
    -- Thiết lập character hiện tại
    if targetPlayer.Character then
        setupCharacter(targetPlayer.Character)
    end
    
    -- Theo dõi khi character thay đổi (respawn)
    targetPlayer.CharacterAdded:Connect(function(character)
        print("🔄 " .. targetPlayer.Name .. " đã respawn, cập nhật ESP...")
        wait(0.5) -- Đợi character load hoàn toàn
        setupCharacter(character)
    end)
    
    -- Theo dõi khi player rời game
    targetPlayer.AncestryChanged:Connect(function()
        if not targetPlayer or not targetPlayer.Parent then
            if espFolders[targetPlayer] then
                espFolders[targetPlayer]:Destroy()
                espFolders[targetPlayer] = nil
                print("🗑️ Đã xóa ESP của: " .. targetPlayer.Name)
            end
        end
    end)
end

local function initializeWallhack()
    print("🔄 Đang khởi tạo wallhack...")
    
    -- Xóa toàn bộ ESP cũ
    for targetPlayer, folder in pairs(espFolders) do
        if folder then
            folder:Destroy()
        end
    end
    espFolders = {}
    
    -- Tạo ESP cho tất cả người chơi
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            createESP(otherPlayer)
        end
    end
    
    print("✅ Wallhack đã khởi tạo cho " .. #Players:GetPlayers() - 1 .. " người chơi")
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
        print("🔵 Wallhack: BẬT")
    else
        teleportButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        print("🔴 Wallhack: TẮT")
    end
end

-- ===========================================================================
-- PHẦN AIMBOT ĐƠN GIẢN HOẠT ĐỘNG NGAY
-- ===========================================================================

local function findBestTarget()
    local camPos = camera.CFrame.Position
    local bestTarget = nil
    local bestScore = -9999
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and isEnemy(otherPlayer) and otherPlayer.Character then
            local humanoid = otherPlayer.Character:FindFirstChild("Humanoid")
            local rootPart = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart then
                local distance = (rootPart.Position - camPos).Magnitude
                if distance < 500 then -- Giới hạn khoảng cách
                    local score = 0
                    
                    -- Điểm cơ bản
                    score = score + (500 - distance) * 0.1 -- Ưu tiên gần
                    
                    -- Ưu tiên mục tiêu có thể bắn mình
                    if canShootMe(otherPlayer) then
                        score = score + 100
                    end
                    
                    -- Ưu tiên mục tiêu trong tầm nhìn
                    local isVisible = hasClearLineOfSight(
                        camPos, 
                        rootPart.Position, 
                        {player.Character, otherPlayer.Character}
                    )
                    if isVisible then
                        score = score + 50
                    end
                    
                    if score > bestScore then
                        bestScore = score
                        bestTarget = otherPlayer
                    end
                end
            end
        end
    end
    
    return bestTarget
end

local function simpleAim(target)
    if not target or not target.Character then return end
    if not camera then return end
    
    local targetPart = target.Character:FindFirstChild("Head") or 
                      target.Character:FindFirstChild("UpperTorso") or 
                      target.Character:FindFirstChild("HumanoidRootPart")
    
    if not targetPart then return end
    
    local camPos = camera.CFrame.Position
    local targetPos = targetPart.Position
    
    -- Aim trực tiếp
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
-- PHẦN TELEPORT ĐƠN GIẢN HOẠT ĐỘNG NGAY
-- ===========================================================================

local function teleportToTarget(target)
    if not target or not target.Character then return false end
    if not player.Character then return false end
    
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    local playerRoot = player.Character:FindFirstChild("HumanoidRootPart")
    
    if not targetRoot or not playerRoot then return false end
    
    -- Vị trí teleport đơn giản - phía sau target
    local targetCF = targetRoot.CFrame
    local teleportPosition = targetCF.Position - targetCF.LookVector * 4
    
    -- Kiểm tra vật cản đơn giản
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {player.Character, target.Character}
    
    local raycastResult = workspace:Raycast(targetRoot.Position, (teleportPosition - targetRoot.Position), raycastParams)
    
    if not raycastResult then
        playerRoot.CFrame = CFrame.new(teleportPosition) * CFrame.Angles(0, math.rad(180), 0)
        return true
    else
        -- Thử vị trí khác
        local sidePosition = targetCF.Position + targetCF.RightVector * 3
        local raycastResult2 = workspace:Raycast(targetRoot.Position, (sidePosition - targetRoot.Position), raycastParams)
        
        if not raycastResult2 then
            playerRoot.CFrame = CFrame.new(sidePosition)
            return true
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
-- KẾT NỐI SỰ KIỆN VÀ ĐIỀU KHIỂN CHÍNH
-- ===========================================================================

-- AIM BOT CONTROLS
aimButton.MouseButton1Click:Connect(function()
    aimEnabled = not aimEnabled
    
    if aimEnabled then
        aimButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        aimButton.Text = "AIM ON"
        
        -- Bắt đầu aim
        if aimConnection then 
            aimConnection:Disconnect() 
        end
        
        aimConnection = RunService.RenderStepped:Connect(function()
            if not aimEnabled then return end
            if not currentTarget then
                currentTarget = findBestTarget()
                if currentTarget then
                    showTargetArrow(currentTarget)
                end
            else
                -- Kiểm tra nếu mục tiêu vẫn tồn tại
                if not currentTarget.Character or 
                   not currentTarget.Character:FindFirstChild("Humanoid") or 
                   currentTarget.Character.Humanoid.Health <= 0 then
                    currentTarget = nil
                    removeTargetArrow()
                else
                    simpleAim(currentTarget)
                end
            end
        end)
        
        print("Aimbot: BẬT")
    else
        aimButton.BackgroundColor3 = Color3.fromRGB(59, 59, 255)
        aimButton.Text = "AIM OFF"
        
        if aimConnection then 
            aimConnection:Disconnect() 
            aimConnection = nil
        end
        
        currentTarget = nil
        removeTargetArrow()
        print("Aimbot: TẮT")
    end
end)

-- TELEPORT CONTROLS
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
    
    print("Teleport: MỞ KHÓA")
end

local function lockTeleport()
    local newTarget = findBestTarget()
    
    if not newTarget then
        teleportButton.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
        teleportButton.Text = "NO TARGET"
        
        print("Teleport: Không tìm thấy mục tiêu")
        
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
    
    -- Teleport ngay lập tức
    teleportToTarget(targetPlayer)
    
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
            if distance > 5 then -- Giữ khoảng cách 5 studs
                teleportToTarget(targetPlayer)
            end
        end
    end)
    
    print("Teleport: ĐÃ KHÓA - " .. targetPlayer.Name)
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
-- CẬP NHẬT TỰ ĐỘNG KHI CÓ THAY ĐỔI
-- ===========================================================================

-- Khi có người chơi mới tham gia
Players.PlayerAdded:Connect(function(newPlayer)
    print("👤 Người chơi mới: " .. newPlayer.Name)
    wait(1) -- Đợi player load
    if newPlayer ~= player then
        createESP(newPlayer)
        print("✅ Đã thêm ESP cho người chơi mới: " .. newPlayer.Name)
    end
end)

-- Khi người chơi rời game
Players.PlayerRemoving:Connect(function(leavingPlayer)
    print("🚪 Người chơi rời: " .. leavingPlayer.Name)
    
    if leavingPlayer == targetPlayer then
        unlockTeleport()
    end
    
    if leavingPlayer == currentTarget then
        currentTarget = nil
        removeTargetArrow()
    end
    
    if espFolders[leavingPlayer] then
        espFolders[leavingPlayer]:Destroy()
        espFolders[leavingPlayer] = nil
        print("🗑️ Đã xóa ESP của: " .. leavingPlayer.Name)
    end
end)

-- Khi LOCAL PLAYER respawn - CẬP NHẬT LẠI TOÀN BỘ WALLHACK
player.CharacterAdded:Connect(function(character)
    print("🔄 Local player đã respawn, cập nhật wallhack...")
    
    -- Reset trạng thái
    unlockTeleport()
    
    if aimEnabled then
        currentTarget = nil
    end
    
    -- Đợi một chút rồi khởi tạo lại wallhack
    wait(2)
    initializeWallhack()
    print("✅ Đã cập nhật wallhack sau respawn")
end)

-- Khi có sự thay đổi về team (nếu game có team)
if player:FindFirstChild("Team") then
    player.TeamChanged:Connect(function()
        print("🔄 Team thay đổi, cập nhật wallhack...")
        wait(1)
        initializeWallhack()
    end)
end

-- ===========================================================================
-- KHỞI TẠO HỆ THỐNG
-- ===========================================================================

-- Khởi tạo lần đầu
wait(3) -- Đợi game load hoàn toàn
initializeWallhack()

print("")
print("🎯 HỆ THỐNG AIMBOT & TELEPORT ĐÃ SẴN SÀNG!")
print("===========================================")
print("📌 Hướng dẫn sử dụng:")
print("   - Click TRÁI nút AIM: Bật/Tắt Aimbot")
print("   - Click TRÁI nút TELEPORT: Khóa/Thoát mục tiêu") 
print("   - Click PHẢI nút TELEPORT: Bật/Tắt Wallhack")
print("")
print("🔄 Wallhack sẽ tự động cập nhật khi:")
print("   - Bạn chết/respawn")
print("   - Địch chết/respawn") 
print("   - Có người mới tham gia/rời game")
print("===========================================")
