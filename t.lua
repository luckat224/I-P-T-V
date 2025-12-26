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

-- Trạng thái AimBot
local aimEnabled = false
local currentTarget = nil
local aimConnection = nil
local espFolders = {}
local arrowGui = nil
local wallhackEnabled = true

-- ===========================================================================
-- WALLHACK ESP (KHÔNG ĐỘ TRỄ)
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
    
    if espFolders[targetPlayer] then
        espFolders[targetPlayer]:Destroy()
    end
    
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
    highlight.Enabled = wallhackEnabled
    
    character.Destroying:Connect(function()
        if folder and folder.Parent then
            folder:Destroy()
            espFolders[targetPlayer] = nil
        end
    end)
    
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
            updateHighlight(character, otherPlayer)
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Died:Connect(function()
                    if espFolders[otherPlayer] then
                        espFolders[otherPlayer]:Destroy()
                        espFolders[otherPlayer] = nil
                    end
                end)
            end
            
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
    
    if otherPlayer.Character then
        setupCharacter(otherPlayer.Character)
    end
    
    otherPlayer.CharacterAdded:Connect(function(character)
        setupCharacter(character)
    end)
    
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
    for targetPlayer, folder in pairs(espFolders) do
        folder:Destroy()
    end
    espFolders = {}
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        initializePlayerESP(otherPlayer)
    end
    
    Players.PlayerAdded:Connect(function(newPlayer)
        initializePlayerESP(newPlayer)
    end)
end

-- ===========================================================================
-- AIMBOT HỆ THỐNG MỚI
-- ===========================================================================
local function showArrow(target)
    if arrowGui then arrowGui:Destroy() end
    if not target or not target.Character then return end
    local head = target.Character:FindFirstChild("Head")
    if not head then return end

    local gui = Instance.new("BillboardGui")
    gui.Name = "TargetArrow"
    gui.Size = UDim2.new(0, 50, 0, 50)
    gui.AlwaysOnTop = true
    gui.Adornee = head
    gui.MaxDistance = 500
    gui.SizeOffset = Vector2.new(0, 2.5)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "🔒"
    label.TextColor3 = Color3.fromRGB(255, 0, 0)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = gui

    gui.Parent = head
    arrowGui = gui
end

local function removeArrow()
    if arrowGui then
        arrowGui:Destroy()
        arrowGui = nil
    end
end

local function getVisibleTarget()
    local camPos = camera.CFrame.Position
    local camDir = camera.CFrame.LookVector
    local bestTarget = nil
    local bestDot = 0.98
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChild("Humanoid")
            if root and hum and hum.Health > 0 then
                local dir = (root.Position - camPos).Unit
                local dot = camDir:Dot(dir)
                if dot > bestDot then
                    bestDot = dot
                    bestTarget = p
                end
            end
        end
    end
    return bestTarget
end

local function lockAim(target)
    if not target or not target.Character then return end
    local head = target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("UpperTorso")
    if not head then return end
    local camPos = camera.CFrame.Position
    camera.CFrame = CFrame.new(camPos, head.Position)
end

local function startAim()
    if aimConnection then aimConnection:Disconnect() end
    aimConnection = RunService.RenderStepped:Connect(function()
        if not aimEnabled then return end

        if not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("Humanoid") or currentTarget.Character.Humanoid.Health <= 0 then
            currentTarget = getVisibleTarget()
            if currentTarget then
                showArrow(currentTarget)
            else
                removeArrow()
            end
        end

        if currentTarget then
            lockAim(currentTarget)
        end
    end)
end

aimButton.MouseButton1Click:Connect(function()
    aimEnabled = not aimEnabled
    if aimEnabled then
        aimButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        aimButton.Text = "AIM ON"
        startAim()
    else
        aimButton.BackgroundColor3 = Color3.fromRGB(59, 59, 255)
        aimButton.Text = "AIM OFF"
        removeArrow()
        currentTarget = nil
        if aimConnection then 
            aimConnection:Disconnect() 
            aimConnection = nil
        end
    end
end)

-- ===========================================================================
-- TELEPORT HỆ THỐNG THÔNG MINH (TRÁNH VẬT CẢN NHƯ BANH NẢY)
-- ===========================================================================
local function getAngleBetweenVectors(v1, v2)
    return math.acos(v1:Dot(v2) / (v1.Magnitude * v2.Magnitude))
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
    arrowGui.Size = UDim2.new(0, 50, 0, 50)
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

-- Hàm teleport thông minh: tìm vị trí trống tốt nhất quanh mục tiêu
local function findOptimalTeleportPosition(targetRoot, maxAttempts)
    if not targetRoot then return nil end
    
    local baseCFrame = targetRoot.CFrame
    local basePosition = targetRoot.Position
    
    -- Danh sách hướng thử (giống như banh nảy)
    local directions = {
        Vector3.new(1, 0, 0),   -- Phải
        Vector3.new(-1, 0, 0),  -- Trái
        Vector3.new(0, 0, 1),   -- Trước
        Vector3.new(0, 0, -1),  -- Sau
        Vector3.new(0.7, 0, 0.7),   -- Phải trước
        Vector3.new(-0.7, 0, 0.7),  -- Trái trước
        Vector3.new(0.7, 0, -0.7),  -- Phải sau
        Vector3.new(-0.7, 0, -0.7), -- Trái sau
    }
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {player.Character, targetRoot.Parent}
    raycastParams.IgnoreWater = true
    
    local bestPosition = nil
    local bestDistance = math.huge
    
    for i = 1, maxAttempts do
        for _, dir in ipairs(directions) do
            -- Tăng khoảng cách dần dần
            local distance = 2 + (i * 0.5)
            local testPosition = basePosition + (dir * distance)
            
            -- Kiểm tra có vật cản không
            local ray = Ray.new(basePosition, (testPosition - basePosition).Unit * distance)
            local hit = workspace:Raycast(ray.Origin, ray.Direction * distance, raycastParams)
            
            if not hit then
                -- Kiểm tra xem vị trí có trên mặt đất không
                local groundRay = Ray.new(testPosition + Vector3.new(0, 5, 0), Vector3.new(0, -10, 0))
                local groundHit = workspace:Raycast(groundRay.Origin, groundRay.Direction, raycastParams)
                
                if groundHit then
                    local groundPosition = groundHit.Position
                    local distanceToTarget = (groundPosition - basePosition).Magnitude
                    
                    -- Ưu tiên vị trí gần mục tiêu nhưng không quá gần
                    if distanceToTarget >= 2 and distanceToTarget <= 4 then
                        if distanceToTarget < bestDistance then
                            bestDistance = distanceToTarget
                            bestPosition = groundPosition + Vector3.new(0, 3, 0) -- Nâng lên một chút
                        end
                    end
                end
            end
        end
        
        if bestPosition then
            break
        end
    end
    
    return bestPosition or (basePosition + Vector3.new(0, 3, 0))
end

local function smartTeleport(target)
    if not target or not target.Character then return false end
    
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    local playerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    
    if not targetRoot or not playerRoot then return false end
    
    -- Tìm vị trí teleport tối ưu
    local teleportPosition = findOptimalTeleportPosition(targetRoot, 5)
    
    if teleportPosition then
        -- Tạo CFrame nhìn về phía mục tiêu
        local lookCFrame = CFrame.new(teleportPosition, targetRoot.Position)
        playerRoot.CFrame = lookCFrame
        return true
    end
    
    return false
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
                
                -- Chỉ teleport khi ở xa hơn 5 studs
                if distance > 5 then
                    smartTeleport(targetPlayer)
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
    -- Ưu tiên mục tiêu đang bị aim
    local newTarget = currentTarget or getVisibleTarget()
    
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
    
    createArrow(targetPlayer)
    startContinuousFollow()
    smartTeleport(targetPlayer)
    
    return true
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
        -- Nếu đang có mục tiêu aim, teleport đến mục tiêu đó ngay
        if currentTarget then
            targetPlayer = currentTarget
            isLocked = true
            
            teleportButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            teleportButton.Text = "LOCKED"
            
            createArrow(targetPlayer)
            startContinuousFollow()
            smartTeleport(targetPlayer)
        else
            lockTarget()
        end
    end
end

teleportButton.MouseButton1Click:Connect(handleTeleportClick)
teleportButton.MouseButton2Click:Connect(toggleWallhack)
teleportButton.TouchTap:Connect(handleTeleportClick)

-- Cleanup và khởi tạo
player.CharacterAdded:Connect(function(character)
    unlockTarget()
    initializeWallhack()
end)

Players.PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == targetPlayer then
        unlockTarget()
    end
    
    if leavingPlayer == currentTarget then
        currentTarget = nil
        removeArrow()
    end
    
    if espFolders[leavingPlayer] then
        espFolders[leavingPlayer]:Destroy()
        espFolders[leavingPlayer] = nil
    end
end)

-- KHỞI TẠO
initializeWallhack()

print("✅ Teleport & Aim Bot Script Đã Sẵn Sàng! - HỆ THỐNG THÔNG MINH")
