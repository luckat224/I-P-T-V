-- TSB & JJK: SUPER SMOOTH PHYSICS (Bản Tối Thượng Không Giật Lag)
-- Tính năng: Tốc độ + Nhảy cao siêu mượt

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local lp = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local char, hum, hrp

local targetSpeed = 16
local targetJump = 50 -- Nhảy mặc định của Roblox

-- Lấy Joystick gốc của thiết bị
local playerControls = require(lp.PlayerScripts:WaitForChild("PlayerModule")):GetControls()

local hiddenUI = pcall(function() return gethui() end) and gethui() or CoreGui
if not pcall(function() local x = hiddenUI.Name end) then
    hiddenUI = lp:WaitForChild("PlayerGui")
end

local function getChar()
    char = lp.Character
    if char then
        hum = char:FindFirstChildOfClass("Humanoid")
        hrp = char:FindFirstChild("HumanoidRootPart")
    end
end

lp.CharacterAdded:Connect(function(c)
    char = c
    hum = c:WaitForChild("Humanoid")
    hrp = c:WaitForChild("HumanoidRootPart")
end)
getChar()

-- ==========================================
-- ĐỘNG CƠ PHYSICS SIÊU MƯỢT (HEARTBEAT)
-- ==========================================
RunService.Heartbeat:Connect(function(deltaTime)
    if not hrp or not hum or hum.Health <= 0 then return end
    
    -- [ÁP DỤNG NHẢY CAO BẤT TỬ]
    -- Liên tục ép JumpPower để game không thể đè/reset lại chỉ số của bạn
    if targetJump ~= 50 then
        hum.UseJumpPower = true
        hum.JumpPower = targetJump
    else
        hum.JumpPower = 50
    end

    -- Nếu tốc độ là 16 (Mặc định) thì ngắt không can thiệp vật lý chạy
    if targetSpeed <= 16 then return end
    
    -- Lấy tín hiệu tay vuốt trên màn hình
    local activeMove = playerControls:GetMoveVector()
    if activeMove.Magnitude < 0.05 then return end 
    
    local camLook = camera.CFrame.LookVector
    local camRight = camera.CFrame.RightVector
    local forward = Vector3.new(camLook.X, 0, camLook.Z).Unit
    local right = Vector3.new(camRight.X, 0, camRight.Z).Unit
    
    local worldMoveDir = (forward * -activeMove.Z) + (right * activeMove.X)
    if worldMoveDir.Magnitude > 0 then
        worldMoveDir = worldMoveDir.Unit
    end
    
    if hrp.Anchored then hrp.Anchored = false end
    hum.AutoRotate = true 
    
    local currentVel = hrp.AssemblyLinearVelocity
    local currentHorizSpeed = Vector3.new(currentVel.X, 0, currentVel.Z).Magnitude
    
    if currentHorizSpeed > targetSpeed + 15 then
        return
    end
    
    hrp.AssemblyLinearVelocity = Vector3.new(
        worldMoveDir.X * targetSpeed,
        currentVel.Y,
        worldMoveDir.Z * targetSpeed
    )
    
    if hum.MoveDirection.Magnitude < 0.05 then
        local targetLook = hrp.Position + worldMoveDir
        hrp.CFrame = hrp.CFrame:Lerp(CFrame.lookAt(hrp.Position, targetLook), 0.15)
    end
end)

-- ==========================================
-- GIAO DIỆN TRÊN CÙNG + THU NHỎ
-- ==========================================
for _, v in pairs(hiddenUI:GetChildren()) do
    if v.Name == "SpeedJumpUltra" or v.Name == "SpeedHaxUltra" then v:Destroy() end
end

local gui = Instance.new("ScreenGui")
gui.Name = "SpeedJumpUltra"
gui.ResetOnSpawn = false
gui.Parent = hiddenUI

-- Mở rộng Frame để chứa 2 ô nhập liệu
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 160, 0, 75)
frame.Position = UDim2.new(0.5, -80, 0.01, 0)
frame.BackgroundTransparency = 0.4
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.ClipsDescendants = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

-- 1. Ô nhập Tốc Độ
local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(1, -40, 0, 30)
speedBox.Position = UDim2.new(0, 10, 0, 5)
speedBox.BackgroundTransparency = 1
speedBox.TextColor3 = Color3.fromRGB(0, 255, 150)
speedBox.Text = "🏃 " .. tostring(targetSpeed)
speedBox.TextSize = 16
speedBox.Font = Enum.Font.GothamBold
speedBox.TextXAlignment = Enum.TextXAlignment.Left
speedBox.ClearTextOnFocus = true
speedBox.Parent = frame

-- 2. Ô nhập Nhảy Cao
local jumpBox = Instance.new("TextBox")
jumpBox.Size = UDim2.new(1, -40, 0, 30)
jumpBox.Position = UDim2.new(0, 10, 0, 40)
jumpBox.BackgroundTransparency = 1
jumpBox.TextColor3 = Color3.fromRGB(255, 150, 0)
jumpBox.Text = "🚀 " .. tostring(targetJump)
jumpBox.TextSize = 16
jumpBox.Font = Enum.Font.GothamBold
jumpBox.TextXAlignment = Enum.TextXAlignment.Left
jumpBox.ClearTextOnFocus = true
jumpBox.Parent = frame

-- Nút Thu Nhỏ
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -35, 0, 5)
minBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
minBtn.Text = "➖"
minBtn.TextColor3 = Color3.new(1, 1, 1)
minBtn.TextSize = 12
minBtn.Parent = frame
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

-- Logic Thu Nhỏ/Mở Rộng
local isMinimized = false
minBtn.Activated:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        frame.Size = UDim2.new(0, 45, 0, 40)
        speedBox.Visible = false
        jumpBox.Visible = false
        minBtn.Position = UDim2.new(0, 7, 0, 5)
        minBtn.Text = "➕"
    else
        frame.Size = UDim2.new(0, 160, 0, 75)
        speedBox.Visible = true
        jumpBox.Visible = true
        minBtn.Position = UDim2.new(1, -35, 0, 5)
        minBtn.Text = "➖"
    end
end)

-- Kéo Thả UI
local dragging, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true dragStart = input.Position startPos = frame.Position
    end
end)
frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Xử lý khi nhập số xong
speedBox.FocusLost:Connect(function()
    local text = speedBox.Text:gsub("[^%d]", "") -- Xóa các ký tự thừa, chỉ giữ lại số
    local v = tonumber(text)
    if v then
        targetSpeed = math.clamp(v, 16, 200)
    end
    speedBox.Text = "🏃 " .. tostring(targetSpeed)
end)

jumpBox.FocusLost:Connect(function()
    local text = jumpBox.Text:gsub("[^%d]", "") -- Xóa các ký tự thừa, chỉ giữ lại số
    local v = tonumber(text)
    if v then
        targetJump = math.clamp(v, 50, 500)
    end
    jumpBox.Text = "🚀 " .. tostring(targetJump)
end)
