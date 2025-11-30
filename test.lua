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
-- ESP HOẠT ĐỘNG 100% (TỪ CODE CỦA BẠN)
-- ===========================================================================

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
    
    -- Xóa highlight cũ ngay lập tức
    if espFolders[targetPlayer] then
        espFolders[targetPlayer]:Destroy()
    end
    
    local folder = createEspFolder(targetPlayer)
    
    -- Tạo highlight mới ngay lập tức
    local highlight = Instance.new("Highlight")
    highlight.Name = "WallhackHighlight"
    highlight.FillColor = Color3.fromRGB(255, 50, 50)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = character
    highlight.Parent = folder
    highlight.Enabled = wallhackEnabled
    
    -- Kết nối để tự động xóa khi character bị destroy
    character.Destroying:Connect(function()
        if folder and folder.Parent then
            folder:Destroy()
            espFolders[targetPlayer] = nil
        end
    end)
    
    -- Theo dõi humanoid để biết khi chết
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
            -- CẬP NHẬT NGAY LẬP TỨC - KHÔNG CHỜ
            updateHighlight(character, otherPlayer)
            
            -- Theo dõi humanoid để biết khi chết
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                -- Kết nối sự kiện died
                humanoid.Died:Connect(function()
                    -- Xóa ESP khi chết
                    if espFolders[otherPlayer] then
                        espFolders[otherPlayer]:Destroy()
                        espFolders[otherPlayer] = nil
                    end
                end)
            end
            
            -- Theo dõi khi character bị remove
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
    
    -- Thiết lập cho character hiện tại NGAY LẬP TỨC
    if otherPlayer.Character then
        setupCharacter(otherPlayer.Character)
    end
    
    -- Theo dõi khi character thay đổi (respawn) - CẬP NHẬT NGAY
    otherPlayer.CharacterAdded:Connect(function(character)
        setupCharacter(character)
    end)
    
    -- Theo dõi khi player rời game
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
    -- Xóa toàn bộ ESP cũ
    for targetPlayer, folder in pairs(espFolders) do
        folder:Destroy()
    end
    espFolders = {}
    
    -- Khởi tạo ESP cho tất cả người chơi NGAY LẬP TỨC
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        initializePlayerESP(otherPlayer)
    end
    
    -- Theo dõi người chơi mới tham gia
    Players.PlayerAdded:Connect(function(newPlayer)
        initializePlayerESP(newPlayer)
    end)
end

-- ===========================================================================
-- AIMBOT THÔNG MINH - CHỈ AIM ĐỊCH & KHÔNG MŨI TÊN
-- ===========================================================================

local function isEnemy(targetPlayer)
    if targetPlayer == player then return false end
    if not player.Team then return true end
    if not targetPlayer.Team then return false end
    return player.Team ~= targetPlayer.Team
end

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
                
                -- Ưu tiên mục tiêu gần
                threatLevel = threatLevel + (100 - math.min(distance / 5, 100))
                
                -- Ưu tiên mục tiêu trong tầm nhìn
                local camDir = camera.CFrame.LookVector
                local toTarget = (rootPart.Position - camPos).Unit
                local dot = camDir:Dot(toTarget)
                
                if dot > 0.9 then
                    threatLevel = threatLevel + 200
                end
                
                -- Chọn mục tiêu có điểm cao nhất
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
    
    camera.CFrame = CFrame.new(camPos, targetPos)
end

-- KHÔNG CÓ MŨI TÊN CHO AIMBOT

-- ===========================================================================
-- TELEPORT ĐẾN NGƯỜI CAMERA ĐANG NHÌN
-- ===========================================================================

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
                local toPlayer = head.Position - cameraPosition
                local distance = toPlayer.Magnitude
                local dot = cameraDirection:Dot(toPlayer.Unit)
                
                if dot > 0.9 and distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = otherPlayer
                end
            end
        end
    end
    
    return closestPlayer
end

local function smartTeleportToTarget(target)
    if not target or not target.Character then return false end
    if not player.Character then return false end
    
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    local playerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    
    if not targetRoot or not playerRoot then return false end
    
    local targetCF = targetRoot.CFrame
    local teleportPosition = targetCF.Position - targetCF.LookVector * 4
    
    playerRoot.CFrame = CFrame.new(teleportPosition) * CFrame.Angles(0, math.rad(180), 0)
    return true
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
-- ĐIỀU KHIỂN AIMBOT - CHỈ AIM ĐỊCH & KHÔNG MŨI TÊN
-- ===========================================================================

aimButton.MouseButton1Click:Connect(function()
    aimEnabled = not aimEnabled
    
    if aimEnabled then
        aimButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        aimButton.Text = "AIM ON"
        
        if aimConnection then 
            aimConnection:Disconnect() 
        end
        
        aimConnection = RunService.RenderStepped:Connect(function()
            if not aimEnabled then return end
            
            local newTarget = findMostDangerousTarget()
            
            if newTarget then
                if currentTarget ~= newTarget then
                    currentTarget = newTarget
                    -- KHÔNG HIỂN THỊ MŨI TÊN - CHỈ AIM THÔI
                end
                preciseAim(currentTarget)
            else
                currentTarget = nil
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
    -- TELEPORT ĐẾN NGƯỜI CAMERA ĐANG NHÌN (KHÔNG PHÂN BIỆT TEAM)
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
-- CẬP NHẬT TỰ ĐỘNG ESP
-- ===========================================================================

-- Khi có người chơi mới
Players.PlayerAdded:Connect(function(newPlayer)
    if newPlayer ~= player then
        initializePlayerESP(newPlayer)
    end
end)

-- Khi người chơi rời
Players.PlayerRemoving:Connect(function(leavingPlayer)
    if espFolders[leavingPlayer] then
        espFolders[leavingPlayer]:Destroy()
        espFolders[leavingPlayer] = nil
    end
    
    if leavingPlayer == targetPlayer then
        unlockTeleport()
    end
    
    if leavingPlayer == currentTarget then
        currentTarget = nil
    end
end)

-- Khi local player respawn - CẬP NHẬT LẠI ESP
player.CharacterAdded:Connect(function(character)
    unlockTeleport()
    
    -- Cập nhật lại ESP sau khi respawn
    wait(1)
    for targetPlayer, folder in pairs(espFolders) do
        if folder and targetPlayer.Character then
            for _, child in pairs(folder:GetChildren()) do
                if child:IsA("Highlight") then
                    child.Adornee = targetPlayer.Character
                end
            end
        end
    end
end)

-- ===========================================================================
-- KHỞI TẠO HỆ THỐNG
-- ===========================================================================

-- Kích hoạt wallhack ngay khi chạy code
wait(1)
initializeWallhack()

print("")
print("🎯 HỆ THỐNG ĐÃ SẴN SÀNG 100%!")
print("===========================================")
print("✅ ESP: Hoạt động 100% từ code của bạn")
print("✅ AIMBOT: Chỉ aim địch, không có mũi tên che") 
print("✅ TELEPORT: Đến người camera đang nhìn")
print("===========================================")
