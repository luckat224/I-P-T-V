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

-- Nút TELEPORT
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

-- Nút AIM
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

-- NÚT TRÁNH XA (DODGE)
local dodgeButton = Instance.new("TextButton")
dodgeButton.Size = UDim2.new(0, 80, 0, 40)
dodgeButton.Position = UDim2.new(0, 20, 0, 110)
dodgeButton.AnchorPoint = Vector2.new(0, 0)
dodgeButton.Text = "TRÁNH XA"
dodgeButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
dodgeButton.TextColor3 = Color3.new(1, 1, 1)
dodgeButton.TextSize = 14
dodgeButton.Font = Enum.Font.GothamBold
dodgeButton.BorderSizePixel = 0
dodgeButton.AutoButtonColor = false
dodgeButton.Parent = gui

local dodgeButtonCorner = Instance.new("UICorner")
dodgeButtonCorner.CornerRadius = UDim.new(0.3, 0)
dodgeButtonCorner.Parent = dodgeButton

-- ===========================================================================
-- BIẾN TOÀN CỤC
-- ===========================================================================
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
-- HÀM TRÁNH XA THÔNG MINH - TRÁNH XA HƠN
-- ===========================================================================
local function findSafeDodgePosition(currentPos, avoidDirection, maxDistance)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {player.Character}
    raycastParams.IgnoreWater = true
    
    -- Các hướng tránh khác nhau (ưu tiên hướng trái/phải trước)
    local testDirections = {
        avoidDirection:Cross(Vector3.new(0, 1, 0)).Unit,  -- Trái
        avoidDirection:Cross(Vector3.new(0, -1, 0)).Unit, -- Phải
        Vector3.new(0, 1, 0),  -- Lên
        Vector3.new(0, -1, 0), -- Xuống
        -avoidDirection,       -- Ngược lại hoàn toàn
        avoidDirection:Cross(Vector3.new(1, 0, 0)).Unit,  -- Hướng khác 1
        avoidDirection:Cross(Vector3.new(-1, 0, 0)).Unit, -- Hướng khác 2
    }
    
    local bestPosition = nil
    local bestDistance = 0
    
    for _, dir in ipairs(testDirections) do
        -- Tăng khoảng cách lên 20-25 studs (tránh xa hơn)
        local testPosition = currentPos + (dir * maxDistance)
        
        -- Kiểm tra có vật cản không
        local ray = Ray.new(currentPos, dir * maxDistance)
        local hit = workspace:Raycast(ray.Origin, ray.Direction * maxDistance, raycastParams)
        
        if not hit then
            -- Kiểm tra mặt đất
            local groundRay = Ray.new(testPosition + Vector3.new(0, 5, 0), Vector3.new(0, -10, 0))
            local groundHit = workspace:Raycast(groundRay.Origin, groundRay.Direction, raycastParams)
            
            if groundHit then
                local groundPos = groundHit.Position
                local distanceFromStart = (groundPos - currentPos).Magnitude
                
                -- Ưu tiên vị trí xa nhất
                if distanceFromStart > bestDistance then
                    bestDistance = distanceFromStart
                    bestPosition = groundPos + Vector3.new(0, 3, 0)
                end
            end
        else
            -- Nếu có vật cản, thử khoảng cách ngắn hơn nhưng vẫn xa
            local shorterDistance = maxDistance * 0.7
            local shorterPosition = currentPos + (dir * shorterDistance)
            local shorterRay = Ray.new(currentPos, dir * shorterDistance)
            local shorterHit = workspace:Raycast(shorterRay.Origin, shorterRay.Direction, raycastParams)
            
            if not shorterHit then
                local groundRay = Ray.new(shorterPosition + Vector3.new(0, 5, 0), Vector3.new(0, -10, 0))
                local groundHit = workspace:Raycast(groundRay.Origin, groundRay.Direction, raycastParams)
                
                if groundHit then
                    local groundPos = groundHit.Position
                    local distanceFromStart = (groundPos - currentPos).Magnitude
                    
                    if distanceFromStart > bestDistance then
                        bestDistance = distanceFromStart
                        bestPosition = groundPos + Vector3.new(0, 3, 0)
                    end
                end
            end
        end
    end
    
    -- Nếu không tìm được vị trí tốt, thử lùi thẳng với khoảng cách ngắn hơn
    if not bestPosition then
        local fallbackDir = -avoidDirection
        local fallbackDistance = 15
        local fallbackPosition = currentPos + (fallbackDir * fallbackDistance)
        
        local groundRay = Ray.new(fallbackPosition + Vector3.new(0, 5, 0), Vector3.new(0, -10, 0))
        local groundHit = workspace:Raycast(groundRay.Origin, groundRay.Direction, raycastParams)
        
        if groundHit then
            bestPosition = groundHit.Position + Vector3.new(0, 3, 0)
        end
    end
    
    return bestPosition
end

local function dodgeAway()
    local playerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not playerRoot then return false end
    
    local currentPos = playerRoot.Position
    local avoidDirection
    
    -- Xác định hướng cần tránh
    if currentTarget and currentTarget.Character then
        -- Nếu đang aim mục tiêu, tránh xa mục tiêu đó
        local targetRoot = currentTarget.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            avoidDirection = (currentPos - targetRoot.Position).Unit
        else
            avoidDirection = playerRoot.CFrame.LookVector
        end
    else
        -- Nếu không có mục tiêu, tránh theo hướng ngược lại với hướng nhìn
        avoidDirection = -playerRoot.CFrame.LookVector
    end
    
    -- Tìm vị trí an toàn để tránh (TĂNG KHOẢNG CÁCH LÊN 25 studs)
    local safePosition = findSafeDodgePosition(currentPos, avoidDirection, 25)
    
    if safePosition then
        -- Teleport đến vị trí an toàn
        local lookCFrame = CFrame.new(safePosition, safePosition + avoidDirection)
        playerRoot.CFrame = lookCFrame
        
        -- Hiệu ứng visual
        dodgeButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        dodgeButton.Text = "ĐÃ TRÁNH!"
        
        task.wait(0.5)
        
        dodgeButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        dodgeButton.Text = "TRÁNH XA"
        
        return true
    else
        -- Nếu không tìm thấy vị trí an toàn, thử teleport lùi đơn giản
        local fallbackPosition = currentPos + (avoidDirection * 20)
        playerRoot.CFrame = CFrame.new(fallbackPosition, fallbackPosition + avoidDirection)
        
        dodgeButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        dodgeButton.Text = "KHÔNG AN TOÀN!"
        
        task.wait(0.5)
        
        dodgeButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        dodgeButton.Text = "TRÁNH XA"
        
        return false
    end
end

-- Kết nối nút TRÁNH XA
dodgeButton.MouseButton1Click:Connect(function()
    dodgeAway()
end)

-- ===========================================================================
-- TELEPORT MỘT LẦN (KHÔNG TỰ ĐỘNG THEO DÕI)
-- ===========================================================================
local function findOptimalTeleportPosition(targetRoot, maxAttempts)
    if not targetRoot then return nil end
    
    local basePosition = targetRoot.Position
    
    -- Danh sách hướng thử
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
            -- Khoảng cách 2-4 studs
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
                            bestPosition = groundPosition + Vector3.new(0, 3, 0)
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

local function singleTeleport(target)
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
        
        -- Hiệu ứng feedback
        teleportButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        teleportButton.Text = "ĐÃ TELE!"
        
        task.wait(0.5)
        
        teleportButton.BackgroundColor3 = wallhackEnabled and Color3.fromRGB(255, 59, 59) or Color3.fromRGB(100, 100, 100)
        teleportButton.Text = "TELEPORT"
        
        return true
    end
    
    return false
end

local function handleTeleportClick()
    local currentTime = tick()
    if currentTime - lastClickTime < CLICK_DELAY then
        return
    end
    lastClickTime = currentTime
    
    -- Ưu tiên mục tiêu đang bị aim
    local target = currentTarget or getVisibleTarget()
    
    if not target then
        teleportButton.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
        teleportButton.Text = "NO TARGET"
        
        task.wait(1)
        
        teleportButton.BackgroundColor3 = wallhackEnabled and Color3.fromRGB(255, 59, 59) or Color3.fromRGB(100, 100, 100)
        teleportButton.Text = "TELEPORT"
        
        return false
    end
    
    -- Thực hiện teleport một lần duy nhất
    singleTeleport(target)
end

teleportButton.MouseButton1Click:Connect(handleTeleportClick)
teleportButton.MouseButton2Click:Connect(toggleWallhack)
teleportButton.TouchTap:Connect(handleTeleportClick)

-- Cleanup và khởi tạo
player.CharacterAdded:Connect(function(character)
    teleportButton.BackgroundColor3 = wallhackEnabled and Color3.fromRGB(255, 59, 59) or Color3.fromRGB(100, 100, 100)
    teleportButton.Text = "TELEPORT"
    initializeWallhack()
end)

Players.PlayerRemoving:Connect(function(leavingPlayer)
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

print("✅ Teleport & Aim Bot Script Đã Sẵn Sàng!")
print("📌 TELEPORT: Một lần duy nhất, không tự theo dõi")
print("📌 TRÁNH XA: Tránh xa 25 studs")
print("📌 AIM: Tự động lock mục tiêu")
