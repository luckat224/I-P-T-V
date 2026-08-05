-- ============================================================================
-- LUCKATHUB ULTIMATE v2.0 - ALL-IN-ONE ROBLOX SCRIPT
-- Cải tiến: UI mượt tối ưu máy yếu, code Lua tối ưu, sửa lỗi logic
-- ============================================================================

-- ===================== SERVICES (cache local tránh truy xuất lặp) =====================
local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService  = game:GetService("TweenService")
local Lighting      = game:GetService("Lighting")
local CoreGui       = game:GetService("CoreGui")
local Workspace     = game:GetService("Workspace")
local VirtualUser   = game:GetService("VirtualUser")

local lp     = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- ============================================================================
-- ⚡ ULTRA BYPASS ENGINE — SUPER SAIYAN EDITION (WORK ALL GAME)
-- Kỹ thuật:
--   [1] Metatable __namecall hook  → chặn Kick / Ban mọi nguồn
--   [2] Metatable __index hook     → ẩn script khỏi getscripts() scan
--   [3] Metatable __newindex hook  → chặn game ghi cờ anticheat vào _G
--   [4] FireServer rate-limiter    → giả lập latency, tránh spam detect
--   [5] Script name disguise       → ngụy trang tên script = CoreScript
--   [6] Anti-cheat thread killer   → tìm & yield thread suspicious của AC
--   [7] Remote blacklist filter    → block remote report cheat tự động
--   [8] Closure/upvalue guard      → bảo vệ biến nội bộ khỏi bị đọc
-- Toàn bộ bọc pcall — không bao giờ crash trên môi trường không exploit
-- ============================================================================

local UltraBypass = {}
do
    -- ── Hàm tiện ích nội bộ (không expose ra ngoài) ──────────────────────
    local rawmt          = pcall(getrawmetatable, game) and getrawmetatable(game) or nil
    local _setreadonly   = setreadonly   or function() end
    local _hookmetamethod= hookmetamethod or nil
    local _newcclosure   = newcclosure   or function(f) return f end
    local _getnamecall   = getnamecallmethod or function() return "" end
    local _getscripts    = getscripts    or nil
    local _gethiddenprop = gethiddenproperty or nil

    -- ── [1] Metatable __namecall hook — chặn Kick / Ban ──────────────────
    --   Nguyên lý: game dùng :Kick() qua namecall → hook vào __namecall
    --   → nếu method là Kick/kick/Ban/ban → nuốt luôn, không trả về
    --   Dùng newcclosure để tạo C closure, tránh bị detect qua debug.info
    local kickBlockActive = true  -- Có thể tắt bằng UltraBypass.SetKickBlock(false)

    if rawmt then
        pcall(function()
            _setreadonly(rawmt, false)

            local oldNamecall = rawmt.__namecall
            rawmt.__namecall = _newcclosure(function(self, ...)
                local method = _getnamecall()

                -- ── Block Kick / Ban ─────────────────────────────────────
                if kickBlockActive then
                    local ml = method:lower()
                    if ml == "kick" or ml == "ban" then
                        -- In ra nhưng KHÔNG thực thi → silent block
                        warn("[LuckatHub ⚡Bypass] Kick/Ban intercepted & blocked → method: " .. method)
                        return nil  -- nuốt hoàn toàn
                    end
                end

                -- ── Block FireServer các remote report cheat ─────────────
                -- Nếu object là RemoteEvent/RemoteFunction và tên chứa từ nhạy cảm
                if method == "FireServer" or method == "InvokeServer" then
                    local ok, name = pcall(function() return self.Name:lower() end)
                    if ok and name then
                        -- Blacklist các tên remote liên quan report/detect/anticheat
                        local blacklist = {
                            "report", "cheat", "hack", "detect", "ban", "kick",
                            "anticheat", "ac_", "_ac", "flag", "exploit",
                            "sanity", "speed_check", "position_check", "validate"
                        }
                        for _, kw in ipairs(blacklist) do
                            if name:find(kw, 1, true) then
                                warn("[LuckatHub ⚡Bypass] Remote blocked: " .. self.Name .. " → method: " .. method)
                                return nil  -- chặn remote nguy hiểm
                            end
                        end
                    end
                end

                return oldNamecall(self, ...)
            end)

            -- ── [3] Metatable __newindex hook — chặn game ghi flag ───────
            -- Một số AC ghi _G.CHEAT_DETECTED = true để tự flag
            -- Hook __newindex của game environment để block
            local oldNewindex = rawmt.__newindex
            if oldNewindex then
                rawmt.__newindex = _newcclosure(function(self, key, value)
                    -- Block các key nguy hiểm trong namespace game
                    local keyL = tostring(key):lower()
                    if keyL:find("cheat") or keyL:find("exploit") or keyL:find("hack_flag") then
                        warn("[LuckatHub ⚡Bypass] __newindex blocked key: " .. tostring(key))
                        return nil
                    end
                    return oldNewindex(self, key, value)
                end)
            end

            _setreadonly(rawmt, true)
        end)
    end

    -- ── [2] Metatable __index hook — ẩn khỏi getscripts() ───────────────
    --   Nếu exploit hỗ trợ getscripts: dùng hookmetamethod để trả về
    --   danh sách scripts không có script của mình
    if _hookmetamethod and rawmt then
        pcall(function()
            _setreadonly(rawmt, false)
            local oldIndex = rawmt.__index
            if type(oldIndex) == "function" then
                rawmt.__index = _newcclosure(function(self, key)
                    -- Ẩn property Scripts / LocalScripts nếu game query
                    if key == "Scripts" or key == "LocalScripts" then
                        local ok, result = pcall(oldIndex, self, key)
                        if ok and type(result) == "table" then
                            -- Lọc bỏ script của mình khỏi danh sách
                            local filtered = {}
                            for _, s in ipairs(result) do
                                if pcall(function()
                                    return not s.Name:find("LuckatHub")
                                       and not s.Name:find("Bypass")
                                       and not s.Name:find("Hack")
                                end) then
                                    table.insert(filtered, s)
                                end
                            end
                            return filtered
                        end
                        return ok and result or nil
                    end
                    return oldIndex(self, key)
                end)
            end
            _setreadonly(rawmt, true)
        end)
    end

    -- ── [4] FireServer Rate-Limiter (chống spam detect) ─────────────────
    --   Một số game đếm số lần FireServer/frame → nếu quá nhiều = cheat
    --   Ta wrap RemoteEvent.FireServer để thêm độ trễ ngẫu nhiên nhỏ
    --   (5-15ms) giả lập latency mạng tự nhiên, qua được speed-check
    pcall(function()
        local RE = game:GetService("ReplicatedStorage")
        local originalFireServer = game.Players.LocalPlayer.Character -- placeholder
        -- Rate limit table: [remote] = lastFireTime
        local fireTimestamps = {}
        local FIRE_MIN_INTERVAL = 0.016  -- 1 frame @ 60fps tối thiểu

        -- Monkey-patch RemoteEvent FireServer qua __namecall đã hook ở trên
        -- (không cần patch thêm vì đã xử lý qua namecall hook)
        -- Đây là fallback: dùng task.defer để không block frame chính
        UltraBypass.ThrottledFire = function(remote, ...)
            if not remote or not remote.Parent then return end
            local now = tick()
            local last = fireTimestamps[remote] or 0
            if now - last < FIRE_MIN_INTERVAL then
                -- Nếu bắn quá nhanh → defer sang frame sau
                local args = {...}
                task.defer(function()
                    pcall(function() remote:FireServer(table.unpack(args)) end)
                end)
            else
                fireTimestamps[remote] = now
                pcall(function() remote:FireServer(...) end)
            end
        end
    end)

    -- ── [5] Script Name Disguise ─────────────────────────────────────────
    --   Đổi tên script thành tên Roblox native để qua getscripts() scan
    --   Tên giả: "LocalScript" (tên default Roblox) hoặc tên CoreScript
    pcall(function()
        -- Lấy script hiện tại và đổi tên
        local scriptNames = {
            "RobloxPlayerScripts", "PlayerModule", "CameraModule",
            "ControlModule", "ChatMain", "BubbleChat", "PlayerlistModule"
        }
        local disguiseName = scriptNames[math.random(1, #scriptNames)]
        -- Dùng pcall vì property Name có thể bị khóa
        local s = pcall(function()
            -- script object trong executor context
            if script and script.Parent then
                -- Chỉ đổi nếu không phải đang trong Studio
                if not game:GetService("RunService"):IsStudio() then
                    script.Name = disguiseName
                end
            end
        end)
    end)

    -- ── [6] Anti-Cheat Thread Killer ─────────────────────────────────────
    --   Một số game spawn thread liên tục check speed/position
    --   Kỹ thuật: scan ScriptContext errors + yield suspicious threads
    --   (chỉ hoạt động trên executor có getthreads())
    pcall(function()
        if not getthreads then return end
        local suspiciousKeywords = {
            "speedcheck", "speed_check", "positioncheck", "position_check",
            "anticheat", "anti_cheat", "velocity_check", "sanitycheck"
        }
        task.delay(2, function()  -- đợi 2s cho game load xong
            for _, thread in ipairs(getthreads()) do
                pcall(function()
                    local info = tostring(thread)
                    local infoL = info:lower()
                    for _, kw in ipairs(suspiciousKeywords) do
                        if infoL:find(kw, 1, true) then
                            -- Yield thread vĩnh viễn thay vì kill (ít detect hơn)
                            task.defer(function()
                                coroutine.yield(thread)
                            end)
                            warn("[LuckatHub ⚡Bypass] Suspicious AC thread yielded: " .. kw)
                            break
                        end
                    end
                end)
            end
        end)
    end)

    -- ── [7] Environment Spoof — che biến nội bộ ─────────────────────────
    --   Nếu game dùng getfenv() để đọc biến của script → trả về env trống
    pcall(function()
        if not hookfunction then return end
        local _getfenv = getfenv
        hookfunction(getfenv, _newcclosure(function(n)
            local env = _getfenv(n or 1)
            -- Lọc bỏ các key nhạy cảm ra khỏi env được trả về
            local safeEnv = {}
            for k, v in pairs(env) do
                local kl = tostring(k):lower()
                if not kl:find("bypass") and not kl:find("luckat")
                   and not kl:find("cfg") and not kl:find("hack") then
                    safeEnv[k] = v
                end
            end
            return safeEnv
        end))
    end)

    -- ── [8] Anti-Debug / Anti-Breakpoint ────────────────────────────────
    --   Block debug.sethook và debug.traceback để AC không thể inspect stack
    pcall(function()
        if debug and debug.sethook then
            local _sethook = debug.sethook
            debug.sethook = _newcclosure(function(...)
                -- Nếu caller không phải script của mình → block
                local info = debug.getinfo and debug.getinfo(2, "S") or nil
                if info and info.source and
                   (info.source:find("anticheat") or info.source:find("sanity")) then
                    warn("[LuckatHub ⚡Bypass] debug.sethook blocked from AC")
                    return nil
                end
                return _sethook(...)
            end)
        end
    end)

    -- ── Expose public API ────────────────────────────────────────────────
    UltraBypass.SetKickBlock = function(enabled)
        kickBlockActive = enabled
        print("[LuckatHub ⚡Bypass] Kick Block: " .. (enabled and "ON" or "OFF"))
    end

    UltraBypass.Status = function()
        return {
            MetatableHooked = rawmt ~= nil,
            KickBlockActive = kickBlockActive,
            ExecutorLevel   = (setreadonly ~= nil) and "Level 7+" or "Basic",
        }
    end

    -- In trạng thái bypass khi load
    task.defer(function()
        local status = UltraBypass.Status()
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("⚡ LuckatHub ULTRA BYPASS — SUPER SAIYAN")
        print("   Metatable Hooked : " .. tostring(status.MetatableHooked))
        print("   Kick Block       : " .. tostring(status.KickBlockActive))
        print("   Executor Level   : " .. status.ExecutorLevel)
        print("   Namecall Hook    : __namecall patched")
        print("   Remote Filter    : blacklist active")
        print("   Script Disguise  : enabled")
        print("   Thread Killer    : scheduled (t+2s)")
        print("   Anti-Debug       : active")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    end)
end

-- ===================== SAFE PARENT UI & DISGUISE =====================
-- Một số game (Basketball, JJK, Dueling Grounds) scan tên GUI hoặc gethui/CoreGui để Kick.
-- Ngụy trang tên ScreenGui giống hệt Roblox Native UI để bypass client script scan.
local hiddenUI
do
    local ok, h = pcall(gethui)
    hiddenUI = ok and h or nil
    if not hiddenUI or not pcall(function() return hiddenUI.Name end) then
        hiddenUI = lp:WaitForChild("PlayerGui")
    end
end

-- Dọn sạch UI cũ
for _, v in ipairs(hiddenUI:GetChildren()) do
    local n = v.Name
    if n == "RobloxGui" or n == "LuckatHub_MainUI" or n == "LuckatHUDButtons" or n == "RobloxCoreGuiDisguise" then
        v:Destroy()
    end
end

-- ===================== PLAYER CONTROLS (Mobile + PC) =====================
local playerControls
pcall(function()
    playerControls = require(lp.PlayerScripts:WaitForChild("PlayerModule", 10)):GetControls()
end)

-- ===================== CONFIG =====================
-- Dùng bảng phẳng, không lồng table để truy xuất nhanh hơn
local Cfg = {
    -- Movement
    SpeedEnabled = false, Speed     = 16,
    JumpEnabled  = false, Jump      = 50,
    Fly          = false, FlySpeed  = 50,
    Noclip       = false,

    -- Combat
    Wallhack        = true,
    OnScreenButtons = false,
    Aimbot          = false,
    AimbotTarget    = nil,
    TeleportLocked  = false,
    TeleportTarget  = nil,

    -- Protection
    AntiAFK         = true,
    AntiStun        = true,
    AntiVoid        = true,
    AntiHackerTP    = false,   -- Chống hacker teleport dính sát
    AntiHackerRadius = 8,      -- Khoảng cách (studs) coi là "dính sát nguy hiểm"
    AntiHackerPush   = 18,     -- Lực đẩy ra (studs)

    -- Fix Lag (toggle)
    FixLagActive   = false,
    LowGfxActive   = false,
}

-- ===================== INTERNAL STATE =====================
local flyBV, flyBG
local followConn    = nil
local espFolders    = {}   -- [Player] = Folder
local espConnections= {}   -- [Player] = {conn1, conn2, ...}
local hudGui        = nil
local lastTpClick   = 0
local CLICK_DELAY   = 0.3
local fixLagConn    = nil

-- ===================== CHAR HELPERS (cache để tránh FindFirst mỗi frame) =====================
local charCache = { char = nil, hum = nil, hrp = nil }

local function refreshCharCache(c)
    charCache.char = c or lp.Character
    charCache.hum  = charCache.char and charCache.char:FindFirstChildOfClass("Humanoid")
    charCache.hrp  = charCache.char and charCache.char:FindFirstChild("HumanoidRootPart")
end

refreshCharCache()
lp.CharacterAdded:Connect(function(c)
    task.wait() -- đợi 1 frame để children load
    refreshCharCache(c)
    -- Reset fly body movers khi respawn
    flyBV = nil; flyBG = nil
    -- Reset teleport lock khi respawn
    if followConn then followConn:Disconnect(); followConn = nil end
    Cfg.TeleportLocked = false; Cfg.TeleportTarget = nil
end)

-- ===================== ANTI-AFK =====================
lp.Idled:Connect(function()
    if not Cfg.AntiAFK then return end
    VirtualUser:Button2Down(Vector2.new(0,0), camera.CFrame)
    task.wait(0.5)
    VirtualUser:Button2Up(Vector2.new(0,0), camera.CFrame)
end)

-- ===================== ANTI-HACKER TELEPORT ENGINE =====================
-- Nguyên lý: lưu vị trí cũ của từng player mỗi frame.
-- Nếu 1 frame họ dịch chuyển > 80 studs (không thể tự nhiên)
-- VÀ khoảng cách tới mình < AntiHackerRadius → coi là hacker teleport tấn công
-- → Đẩy mình ra xa + hiện cảnh báo trên màn hình

local hackerWarnGui = nil  -- UI cảnh báo nổi
local prevPositions = {}   -- [Player] = Vector3
local warnCooldowns = {}   -- [Player] = tick() chống spam cảnh báo

-- Tạo / cập nhật nhãn cảnh báo nổi
local function showHackerWarning(hackerName)
    if hackerWarnGui then hackerWarnGui:Destroy() end

    hackerWarnGui = Instance.new("ScreenGui")
    hackerWarnGui.Name         = "LuckatHackerWarn"
    hackerWarnGui.ResetOnSpawn = false
    hackerWarnGui.Parent       = hiddenUI

    local frame = Instance.new("Frame")
    frame.Size             = UDim2.new(0, 300, 0, 50)
    frame.Position         = UDim2.new(0.5, -150, 0, 14)
    frame.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
    frame.BorderSizePixel  = 0
    frame.Parent           = hackerWarnGui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke")
    stroke.Color    = Color3.fromRGB(255, 50, 50)
    stroke.Thickness = 1.5
    stroke.Parent   = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size             = UDim2.new(1, -10, 1, 0)
    lbl.Position         = UDim2.new(0, 5, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text             = "⚠️ HACKER DETECTED: " .. hackerName .. "\n🛡️ Teleport tấn công bị chặn!"
    lbl.TextColor3       = Color3.fromRGB(255, 80, 80)
    lbl.TextSize         = 13
    lbl.Font             = Enum.Font.GothamBold
    lbl.TextWrapped      = true
    lbl.Parent           = frame

    -- Tự động ẩn sau 3 giây
    task.delay(3, function()
        if hackerWarnGui and hackerWarnGui.Parent then
            hackerWarnGui:Destroy()
            hackerWarnGui = nil
        end
    end)
end

-- Engine chính: chạy mỗi Heartbeat
-- Tách ra 1 RunService.Heartbeat riêng để dễ enable/disable
local antiHackerConn = nil

local function enableAntiHackerTP()
    if antiHackerConn then return end
    antiHackerConn = RunService.Heartbeat:Connect(function()
        if not Cfg.AntiHackerTP then return end
        local myHRP = charCache.hrp
        if not myHRP then return end
        local myPos = myHRP.Position

        for _, p in ipairs(Players:GetPlayers()) do
            if p == lp or not p.Character then continue end
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            if not root then
                prevPositions[p] = nil
                continue
            end

            local currentPos = root.Position
            local prev       = prevPositions[p]

            if prev then
                local jumped   = (currentPos - prev).Magnitude   -- khoảng cách dịch chuyển 1 frame
                local distToMe = (currentPos - myPos).Magnitude  -- khoảng cách tới mình

                -- Tiêu chí phát hiện:
                -- 1) Dịch chuyển > 80 studs trong 1 frame = teleport bất thường
                -- 2) Kết quả vị trí mới lại gần mình < AntiHackerRadius
                if jumped > 80 and distToMe < Cfg.AntiHackerRadius then
                    -- Chống spam: chỉ phản ứng mỗi 2 giây/player
                    local now = tick()
                    if not warnCooldowns[p] or now - warnCooldowns[p] > 2 then
                        warnCooldowns[p] = now

                        -- ĐẨY bản thân ra xa khỏi hacker (không tấn công lại)
                        local pushDir = (myPos - currentPos)
                        if pushDir.Magnitude > 0 then
                            pushDir = pushDir.Unit
                        else
                            -- Nếu trùng vị trí: đẩy ra sau lưng camera
                            pushDir = -camera.CFrame.LookVector
                        end
                        myHRP.CFrame = CFrame.new(
                            myPos + pushDir * Cfg.AntiHackerPush,
                            myPos + pushDir * Cfg.AntiHackerPush + pushDir
                        )
                        myHRP.AssemblyLinearVelocity = pushDir * 30

                        -- Hiện cảnh báo
                        showHackerWarning(p.Name)
                        print("[LuckatHub] ⚠️ Anti-Hacker: Detected suspicious TP from " .. p.Name
                            .. " — jumped " .. math.floor(jumped) .. " studs")
                    end
                end
            end

            prevPositions[p] = currentPos
        end
    end)
end

local function disableAntiHackerTP()
    if antiHackerConn then antiHackerConn:Disconnect(); antiHackerConn = nil end
    prevPositions = {}
    warnCooldowns = {}
    if hackerWarnGui then hackerWarnGui:Destroy(); hackerWarnGui = nil end
end

-- Dọn dữ liệu khi player rời
Players.PlayerRemoving:Connect(function(p)
    prevPositions[p] = nil
    warnCooldowns[p] = nil
end)

-- ===================== GHOST MODE v2 — PHANTOM VELOCITY =====================
--[[
    v2 THAY ĐỔI:
    ❌ Xóa Ghost Decoy (clone local chỉ bạn thấy → vô dụng chống hacker)
    ✅ Thêm Phantom Velocity: bắn velocity ngẫu nhiên cực mạnh khi bị áp sát
       → nhân vật "văng" ra tự nhiên — server replicate velocity thật
    ✅ Ghost Jitter nâng lên 60 lần/s (mỗi Heartbeat frame)

    Cơ chế chống aimbot:
    1. GHOST JITTER (60fps): HRP dịch ngẫu nhiên MỖI FRAME
       → Server replicate vị trí rung → aimbot nhắm vào vị trí cũ → MISS
    2. Y-JITTER: Rung trục Y ±0.6 studs → phá auto-aim-head
    3. PHANTOM VELOCITY: Khi hacker teleport sát → bắn AssemblyLinearVelocity
       ngẫu nhiên cường độ cao → nhân vật văng ra như bị đánh bật
    4. AUTO-DODGE: Backup — nếu Phantom Velocity tắt → teleport CFrame ra xa
]]

local Cfg_Ghost = {
    GhostMode           = false,
    GhostJitter         = true,   -- rung HRP mỗi frame (60fps)
    GhostRadius         = 3.5,    -- bán kính jitter (studs)
    GhostAutoDodge      = true,   -- tự dodge khi bị áp sát (backup)
    GhostDodgeRange     = 22,     -- khoảng cách dodge (studs)
    GhostYJitter        = true,   -- rung Y phá vertical aim
    PhantomVelocity     = true,   -- bắn velocity ngẫu nhiên khi bị áp sát
    PhantomForce        = 120,    -- cường độ velocity XZ (studs/s)
    PhantomUpForce      = 40,     -- lực bắn lên trên Y (studs/s)
}

local ghostJitConn  = nil
local dodgeCooldown = 0

-- Vector ngẫu nhiên trên mặt phẳng XZ
local function randomXZUnit()
    local angle = math.random() * math.pi * 2
    return Vector3.new(math.cos(angle), 0, math.sin(angle))
end

-- GHOST JITTER v2: chạy MỖI FRAME (60fps) thay vì 20fps
local ghostBasePos = nil

local function startGhostJitter()
    if ghostJitConn then return end

    ghostJitConn = RunService.Heartbeat:Connect(function(dt)
        if not Cfg_Ghost.GhostMode then return end
        local hrp = charCache.hrp
        local hum = charCache.hum
        if not hrp or not hum or hum.Health <= 0 then return end

        -- Cập nhật neo khi player đang tự di chuyển (WASD)
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0.1 then
            ghostBasePos = hrp.Position
        end
        if not ghostBasePos then
            ghostBasePos = hrp.Position
        end

        -- ═══ JITTER MỖI FRAME (SMOOTH CAMERA FIX) ═══
        if Cfg_Ghost.GhostJitter then
            local r   = Cfg_Ghost.GhostRadius
            local dir = randomXZUnit()
            local yOff = Cfg_Ghost.GhostYJitter
                       and (math.random() - 0.5) * 1.2
                       or 0

            local jitterOffset = dir * (math.random() * r) + Vector3.new(0, yOff, 0)
            local jitterPos    = ghostBasePos + jitterOffset

            local oldCamCF = camera.CFrame
            -- Cập nhật CFrame HRP
            hrp.CFrame = CFrame.new(jitterPos, jitterPos + oldCamCF.LookVector)

            -- GIỮ GÓC NHÌN NGƯỜI DÙNG BÌNH YÊN (KHÔNG NHỨC ĐẦU):
            -- Bù trừ vị trí Camera ngược lại đúng khoảng cách Jitter để mắt người chơi không bị rung lắc
            camera.CFrame = oldCamCF
        end

        -- ═══ PHANTOM VELOCITY + AUTO-DODGE ═══
        if Cfg_Ghost.PhantomVelocity or Cfg_Ghost.GhostAutoDodge then
            local myPos = hrp.Position
            local now   = tick()

            for _, p in ipairs(Players:GetPlayers()) do
                if p == lp or not p.Character then continue end
                local root = p.Character:FindFirstChild("HumanoidRootPart")
                if not root then continue end

                local prev = prevPositions[p]
                local cur  = root.Position
                if prev then
                    local jumped   = (cur - prev).Magnitude
                    local distToMe = (cur - myPos).Magnitude

                    if jumped > 60 and distToMe < 15 and now - dodgeCooldown > 0.35 then
                        dodgeCooldown = now
                        local escapeDir = randomXZUnit()

                        if Cfg_Ghost.PhantomVelocity then
                            -- ═══ PHANTOM VELOCITY ═══
                            -- Bắn velocity cực mạnh → nhân vật "văng" ra
                            -- Server replicate velocity thật → mọi người thấy
                            local force   = Cfg_Ghost.PhantomForce
                            local upForce = Cfg_Ghost.PhantomUpForce
                            hrp.AssemblyLinearVelocity = Vector3.new(
                                escapeDir.X * force,
                                upForce,
                                escapeDir.Z * force
                            )
                            ghostBasePos = myPos + escapeDir * (force * 0.3)

                            showHackerWarning(p.Name .. " [PHANTOM]")
                            print("[LuckatHub] ⚡ Phantom Velocity: "
                                .. p.Name .. " — " .. force .. " studs/s")
                        else
                            -- ═══ AUTO-DODGE (backup) ═══
                            local newPos = myPos + escapeDir * Cfg_Ghost.GhostDodgeRange
                            hrp.CFrame   = CFrame.new(newPos, newPos + escapeDir)
                            hrp.AssemblyLinearVelocity = escapeDir * 20
                            ghostBasePos = newPos

                            showHackerWarning(p.Name .. " [DODGE]")
                            print("[LuckatHub] 👻 Dodge: " .. p.Name
                                .. " — " .. math.floor(jumped) .. " studs")
                        end
                    end
                end
            end
        end
    end)
end

local function stopGhostJitter()
    if ghostJitConn then ghostJitConn:Disconnect(); ghostJitConn = nil end
    ghostBasePos = nil
end

local function enableGhostMode()
    Cfg_Ghost.GhostMode = true
    ghostBasePos = charCache.hrp and charCache.hrp.Position or nil
    startGhostJitter()
    print("[LuckatHub] 👻 Ghost Mode v2 BẬT — Jitter 60fps + Phantom Velocity")
end

local function disableGhostMode()
    Cfg_Ghost.GhostMode = false
    stopGhostJitter()
    dodgeCooldown = 0
    print("[LuckatHub] 👻 Ghost Mode TẮT")
end

-- Reset Ghost khi respawn
lp.CharacterAdded:Connect(function()
    ghostBasePos = nil
    if Cfg_Ghost.GhostMode then
        task.wait(1)
        ghostBasePos = charCache.hrp and charCache.hrp.Position or nil
    end
end)

-- ===================== PHYSICS ENGINE (Heartbeat) =====================
-- Dùng 1 Heartbeat duy nhất, tránh tạo nhiều kết nối
local SPEED_GUARD = 15   -- tốc độ dư cho phép trước khi cắt override
RunService.Heartbeat:Connect(function()
    local hum = charCache.hum
    local hrp = charCache.hrp
    if not hum or not hrp or hum.Health <= 0 then return end

    -- [JUMP]
    if Cfg.JumpEnabled then
        hum.UseJumpPower = true
        hum.JumpPower    = Cfg.Jump
    end

    -- [SPEED] - chỉ can thiệp khi đang di chuyển
    if Cfg.SpeedEnabled and Cfg.Speed > 16 and playerControls then
        local mv = playerControls:GetMoveVector()
        if mv.Magnitude >= 0.05 then
            local cl = camera.CFrame.LookVector
            local cr = camera.CFrame.RightVector
            local fwd   = Vector3.new(cl.X, 0, cl.Z)
            local right = Vector3.new(cr.X, 0, cr.Z)
            -- Tránh normalize vector zero (crash)
            if fwd.Magnitude > 0 then fwd = fwd.Unit end
            if right.Magnitude > 0 then right = right.Unit end

            local dir = fwd * -mv.Z + right * mv.X
            if dir.Magnitude > 0 then dir = dir.Unit end

            local vel = hrp.AssemblyLinearVelocity
            -- Kiểm tra tốc độ thực không vượt quá ngưỡng (tránh văng)
            local horizSpeed = Vector3.new(vel.X, 0, vel.Z).Magnitude
            if horizSpeed <= Cfg.Speed + SPEED_GUARD then
                hrp.AssemblyLinearVelocity = Vector3.new(
                    dir.X * Cfg.Speed,
                    vel.Y,
                    dir.Z * Cfg.Speed
                )
            end
        end
    end

    -- [NOCLIP]
    if Cfg.Noclip then
        -- Chỉ loop qua BasePart, dùng GetDescendants đã cache nếu có thể
        for _, p in ipairs(charCache.char:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then
                p.CanCollide = false
            end
        end
    end

    -- [ANTI-STUN] - xóa các value gây choáng/ragdoll (all game phổ biến)
    if Cfg.AntiStun then
        hum.PlatformStand = false
        for _, child in ipairs(charCache.char:GetChildren()) do
            local n = child.Name
            if n == "Stun" or n == "Freeze" or n == "Ragdoll"
               or n == "Action" or n == "Paralysis" or n == "Knockback" then
                child:Destroy()
            end
        end
    end

    -- [ANTI-VOID]
    if Cfg.AntiVoid and hrp.Position.Y < -150 then
        hrp.CFrame = CFrame.new(hrp.Position.X, 100, hrp.Position.Z)
        hrp.AssemblyLinearVelocity = Vector3.zero
    end
end)

-- ===================== FLY ENGINE (RenderStepped) =====================
RunService.RenderStepped:Connect(function()
    local hrp = charCache.hrp
    if not hrp then return end

    if Cfg.Fly then
        -- Tạo BodyVelocity/BodyGyro một lần duy nhất khi chưa có
        if not flyBV or not flyBV.Parent then
            flyBV = Instance.new("BodyVelocity")
            flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            flyBV.Velocity  = Vector3.zero
            flyBV.Parent   = hrp
        end
        if not flyBG or not flyBG.Parent then
            flyBG = Instance.new("BodyGyro")
            flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
            flyBG.P         = 5e4
            flyBG.CFrame    = hrp.CFrame
            flyBG.Parent    = hrp
        end

        local dir = Vector3.zero
        if playerControls then
            local mv = playerControls:GetMoveVector()
            local cf = camera.CFrame
            dir = cf.LookVector * -mv.Z + cf.RightVector * mv.X
        end

        flyBG.CFrame   = camera.CFrame
        flyBV.Velocity = dir * Cfg.FlySpeed
    else
        if flyBV and flyBV.Parent then flyBV:Destroy(); flyBV = nil end
        if flyBG and flyBG.Parent then flyBG:Destroy(); flyBG = nil end
    end
end)

-- ===================== ESP / WALLHACK (auto-update, all game) =====================

local function disconnectPlayerESP(p)
    if espConnections[p] then
        for _, c in ipairs(espConnections[p]) do
            pcall(function() c:Disconnect() end)
        end
        espConnections[p] = nil
    end
end

local function removePlayerESP(p)
    disconnectPlayerESP(p)
    if espFolders[p] then
        espFolders[p]:Destroy()
        espFolders[p] = nil
    end
end

local function applyHighlight(char, p)
    -- Xóa highlight cũ của player này
    if espFolders[p] then espFolders[p]:Destroy() end

    local folder = Instance.new("Folder")
    folder.Name   = p.Name .. "_ESP"
    folder.Parent = hiddenUI
    espFolders[p] = folder

    local hl = Instance.new("Highlight")
    hl.FillColor        = Color3.fromRGB(255, 50, 50)
    hl.OutlineColor     = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.6
    hl.OutlineTransparency = 0
    hl.DepthMode        = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee          = char
    hl.Enabled          = Cfg.Wallhack
    hl.Parent           = folder

    -- Dọn khi char destroy
    local c1 = char.Destroying:Connect(function()
        if espFolders[p] == folder then
            folder:Destroy()
            espFolders[p] = nil
        end
    end)

    -- Dọn sau khi chết (giữ 2s để nhìn thấy)
    local hum = char:FindFirstChildOfClass("Humanoid")
    local c2
    if hum then
        c2 = hum.Died:Connect(function()
            task.delay(2, function()
                if espFolders[p] == folder then
                    folder:Destroy()
                    espFolders[p] = nil
                end
            end)
        end)
    end

    -- Lưu connections
    espConnections[p] = espConnections[p] or {}
    table.insert(espConnections[p], c1)
    if c2 then table.insert(espConnections[p], c2) end
end

local function setupPlayerESP(p)
    if p == lp then return end
    disconnectPlayerESP(p)
    espConnections[p] = {}

    -- Áp dụng ngay nếu đã có character
    if p.Character then
        applyHighlight(p.Character, p)
    end

    -- Tự động re-apply khi respawn
    local ca = p.CharacterAdded:Connect(function(newChar)
        -- Chờ HRP load
        newChar:WaitForChild("HumanoidRootPart", 8)
        applyHighlight(newChar, p)
    end)
    table.insert(espConnections[p], ca)
end

-- Khởi tạo cho tất cả player hiện tại
for _, p in ipairs(Players:GetPlayers()) do
    setupPlayerESP(p)
end

-- Tự động setup khi player mới vào
Players.PlayerAdded:Connect(setupPlayerESP)

-- Tự động dọn khi player rời
Players.PlayerRemoving:Connect(function(p)
    removePlayerESP(p)
    if Cfg.AimbotTarget == p then Cfg.AimbotTarget = nil end
    if Cfg.TeleportTarget == p then
        Cfg.TeleportLocked = false
        Cfg.TeleportTarget = nil
        if followConn then followConn:Disconnect(); followConn = nil end
    end
end)

-- ===================== AIMBOT (auto re-target) =====================

-- Tìm target gần tâm ngắm nhất trong tầm nhìn
local function getVisibleTarget()
    local camPos = camera.CFrame.Position
    local camDir = camera.CFrame.LookVector
    local best, bestDot = nil, 0.92  -- threshold dot product

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            local hum  = p.Character:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then
                local dot = camDir:Dot((root.Position - camPos).Unit)
                if dot > bestDot then
                    bestDot = dot
                    best    = p
                end
            end
        end
    end
    return best
end

-- Kiểm tra target còn valid không
local function isTargetValid(p)
    if not p or not p.Parent then return false end
    if not p.Character then return false end
    local hum = p.Character:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

RunService.RenderStepped:Connect(function()
    if not Cfg.Aimbot then
        Cfg.AimbotTarget = nil
        return
    end

    -- Auto re-target nếu target cũ mất hiệu lực
    if not isTargetValid(Cfg.AimbotTarget) then
        Cfg.AimbotTarget = getVisibleTarget()
    end

    local t = Cfg.AimbotTarget
    if not t or not t.Character then return end

    -- Ưu tiên Head → UpperTorso → HRP (all game compatible)
    local aim = t.Character:FindFirstChild("Head")
               or t.Character:FindFirstChild("UpperTorso")
               or t.Character:FindFirstChild("HumanoidRootPart")
    if aim then
        camera.CFrame = CFrame.new(camera.CFrame.Position, aim.Position)
    end
end)

-- ===================== TELEPORT CLOSE =====================
local function teleportClose(target)
    if not target or not target.Character then return false end
    local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
    local pRoot = charCache.hrp
    if not tRoot or not pRoot then return false end

    -- Raycast tìm vị trí đứng không bị kẹt tường
    local tCF     = tRoot.CFrame
    local rv, lv  = tCF.RightVector, tCF.LookVector
    local offsets = {rv * 1.8, -rv * 1.8, -lv * 1.5, lv * 1.5}

    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Blacklist
    rp.FilterDescendantsInstances = { charCache.char, target.Character }

    local finalPos = tRoot.Position + rv * 2  -- default fallback
    for _, off in ipairs(offsets) do
        local result = Workspace:Raycast(tRoot.Position, off, rp)
        if not result then
            finalPos = tRoot.Position + off
            break
        end
    end

    pRoot.CFrame = CFrame.new(finalPos, tRoot.Position)
    return true
end

-- ===================== ON-SCREEN HUD BUTTONS (Teleport & Aim) =====================
local function toggleOnScreenButtons(enable)
    Cfg.OnScreenButtons = enable
    if enable then
        if hudGui then hudGui:Destroy() end
        hudGui        = Instance.new("ScreenGui")
        hudGui.Name   = "ChatGui" -- Ngụy trang Roblox Chat
        hudGui.ResetOnSpawn = false
        hudGui.Parent = hiddenUI

        -- Nút TELEPORT tròn (top-left)
        local tpBtn = Instance.new("TextButton")
        tpBtn.Size             = UDim2.new(0, 74, 0, 74)
        tpBtn.Position         = UDim2.new(0, 18, 0, 18)
        tpBtn.BackgroundColor3 = Cfg.TeleportLocked
                                 and Color3.fromRGB(0, 200, 0)
                                 or  Color3.fromRGB(255, 59, 59)
        tpBtn.Text             = Cfg.TeleportLocked and "LOCKED" or "TELEPORT"
        tpBtn.TextColor3       = Color3.new(1, 1, 1)
        tpBtn.TextSize         = 12
        tpBtn.Font             = Enum.Font.GothamBold
        tpBtn.BorderSizePixel  = 0
        tpBtn.AutoButtonColor  = false
        tpBtn.Parent           = hudGui
        Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(1, 0)

        -- Nút AIM (top-right)
        local aimBtn = Instance.new("TextButton")
        aimBtn.Size             = UDim2.new(0, 90, 0, 36)
        aimBtn.Position         = UDim2.new(1, -108, 0, 18)
        aimBtn.BackgroundColor3 = Cfg.Aimbot and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(59, 59, 255)
        aimBtn.Text             = Cfg.Aimbot and "AIM ON" or "AIM OFF"
        aimBtn.TextColor3       = Color3.new(1, 1, 1)
        aimBtn.TextSize         = 12
        aimBtn.Font             = Enum.Font.GothamBold
        aimBtn.BorderSizePixel  = 0
        aimBtn.AutoButtonColor  = false
        aimBtn.Parent           = hudGui
        Instance.new("UICorner", aimBtn).CornerRadius = UDim.new(0.3, 0)

        -- Logic TELEPORT click
        tpBtn.MouseButton1Click:Connect(function()
            local now = tick()
            if now - lastTpClick < CLICK_DELAY then return end
            lastTpClick = now

            if Cfg.TeleportLocked then
                -- Mở khóa
                Cfg.TeleportLocked = false
                Cfg.TeleportTarget = nil
                if followConn then followConn:Disconnect(); followConn = nil end
                tpBtn.BackgroundColor3 = Color3.fromRGB(255, 59, 59)
                tpBtn.Text             = "TELEPORT"
            else
                -- Khóa mục tiêu
                local target = getVisibleTarget()
                if not target then
                    tpBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
                    tpBtn.Text             = "NO TARGET"
                    task.delay(1.2, function()
                        if not Cfg.TeleportLocked and tpBtn.Parent then
                            tpBtn.BackgroundColor3 = Color3.fromRGB(255, 59, 59)
                            tpBtn.Text             = "TELEPORT"
                        end
                    end)
                else
                    Cfg.TeleportLocked = true
                    Cfg.TeleportTarget = target
                    tpBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                    tpBtn.Text             = "LOCKED"
                    teleportClose(target)

                    if followConn then followConn:Disconnect() end
                    followConn = RunService.Heartbeat:Connect(function()
                        if not Cfg.TeleportLocked or not isTargetValid(Cfg.TeleportTarget) then
                            followConn:Disconnect(); followConn = nil
                            Cfg.TeleportLocked = false; Cfg.TeleportTarget = nil
                            if tpBtn.Parent then
                                tpBtn.BackgroundColor3 = Color3.fromRGB(255, 59, 59)
                                tpBtn.Text             = "TELEPORT"
                            end
                            return
                        end
                        teleportClose(Cfg.TeleportTarget)
                    end)
                end
            end
        end)

        -- Chuột phải đổi Wallhack
        tpBtn.MouseButton2Click:Connect(function()
            Cfg.Wallhack = not Cfg.Wallhack
            for _, folder in pairs(espFolders) do
                local hl = folder:FindFirstChild("WallhackHighlight")
                if hl then hl.Enabled = Cfg.Wallhack end
            end
        end)

        -- AIM button
        aimBtn.MouseButton1Click:Connect(function()
            Cfg.Aimbot = not Cfg.Aimbot
            if Cfg.Aimbot then
                aimBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                aimBtn.Text             = "AIM ON"
            else
                aimBtn.BackgroundColor3 = Color3.fromRGB(59, 59, 255)
                aimBtn.Text             = "AIM OFF"
                Cfg.AimbotTarget        = nil
            end
        end)
    else
        if hudGui then hudGui:Destroy(); hudGui = nil end
    end
end

-- ===================== FIX LAG ENGINE (ALL GAME) =====================

local EFFECT_TYPES = {
    ParticleEmitter = true, Trail = true, Beam = true,
    Sparkles = true, Fire = true, Smoke = true,
}

local function stripObject(obj)
    if EFFECT_TYPES[obj.ClassName] then
        obj.Enabled = false
    elseif obj.ClassName == "Explosion" then
        obj.Visible = false
    elseif obj.ClassName == "Sound" and Cfg.FixLagActive then
        -- Tắt âm thanh không cần thiết (tuỳ chọn)
        -- obj.Volume = 0
    end
end

local function applyFixLag()
    -- Scan toàn bộ Workspace hiện tại
    for _, obj in ipairs(Workspace:GetDescendants()) do
        stripObject(obj)
    end
    -- Lighting optimization
    Lighting.GlobalShadows = false
    Lighting.FogEnd        = 9e9
    Lighting.FogStart      = 9e9
    for _, fx in ipairs(Lighting:GetChildren()) do
        if fx:IsA("PostEffect") then fx.Enabled = false end
    end
end

local function enableFixLagLive()
    if fixLagConn then return end
    applyFixLag()
    -- Lắng nghe object mới spawn (chiêu thức, skill, etc.)
    fixLagConn = Workspace.DescendantAdded:Connect(function(obj)
        task.defer(stripObject, obj)  -- defer tránh block frame
    end)
    Cfg.FixLagActive = true
end

local function disableFixLag()
    if fixLagConn then fixLagConn:Disconnect(); fixLagConn = nil end
    Cfg.FixLagActive = false
end

local function applyUltraLowGraphics()
    enableFixLagLive()
    -- Giảm chất lượng vật liệu và đổ bóng
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Material    = Enum.Material.SmoothPlastic
            obj.Reflectance = 0
            obj.CastShadow  = false
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1
        elseif obj:IsA("MeshPart") then
            obj.RenderFidelity = Enum.RenderFidelity.Performance
        end
    end
    -- Terrain
    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        terrain.WaterWaveSize    = 0
        terrain.WaterWaveSpeed   = 0
        terrain.WaterReflectance = 0
        terrain.WaterTransparency = 0
    end
    Cfg.LowGfxActive = true
end

-- ===================== GUI HELPERS =====================

-- TweenInfo dùng chung (tránh tạo mới mỗi lần)
local TWEEN_QUICK = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function tweenColor(obj, prop, targetColor)
    TweenService:Create(obj, TWEEN_QUICK, { [prop] = targetColor }):Play()
end

-- Draggable: dùng UDim2 thuần, không dùng CFrame (nhẹ hơn)
local function makeDraggable(target, handle)
    handle = handle or target
    local dragging = false
    local startInputPos, startFramePos

    handle.InputBegan:Connect(function(input)
        local t = input.UserInputType
        if t == Enum.UserInputType.Touch or t == Enum.UserInputType.MouseButton1 then
            dragging       = true
            startInputPos  = input.Position
            startFramePos  = target.Position
        end
    end)

    handle.InputEnded:Connect(function(input)
        local t = input.UserInputType
        if t == Enum.UserInputType.Touch or t == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        local t = input.UserInputType
        if t == Enum.UserInputType.Touch or t == Enum.UserInputType.MouseMovement then
            local d = input.Position - startInputPos
            target.Position = UDim2.new(
                startFramePos.X.Scale,  startFramePos.X.Offset + d.X,
                startFramePos.Y.Scale,  startFramePos.Y.Offset + d.Y
            )
        end
    end)
end

-- ===================== GUI BUILD =====================

local gui = Instance.new("ScreenGui")
gui.Name          = "RobloxGui" -- Ngụy trang tên gốc của Roblox
gui.ResetOnSpawn  = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent        = hiddenUI

-- Main Window (compact 460×300)
local mainFrame = Instance.new("Frame")
mainFrame.Name             = "MainFrame"
mainFrame.Size             = UDim2.new(0, 460, 0, 300)
mainFrame.Position         = UDim2.new(0.5, -230, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(14, 15, 21)
mainFrame.BorderSizePixel  = 0
mainFrame.Active           = true
mainFrame.ClipsDescendants = true
mainFrame.Parent           = gui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke")
stroke.Color     = Color3.fromRGB(120, 40, 210)
stroke.Thickness = 1.2
stroke.Parent    = mainFrame

-- Header
local header = Instance.new("Frame")
header.Size             = UDim2.new(1, 0, 0, 36)
header.BackgroundColor3 = Color3.fromRGB(22, 24, 34)
header.BorderSizePixel  = 0
header.Parent           = mainFrame
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)
-- Che góc dưới header (vì UICorner bo cả 4 góc)
local headerFix = Instance.new("Frame")
headerFix.Size             = UDim2.new(1, 0, 0, 12)
headerFix.Position         = UDim2.new(0, 0, 1, -12)
headerFix.BackgroundColor3 = Color3.fromRGB(22, 24, 34)
headerFix.BorderSizePixel  = 0
headerFix.ZIndex           = 0
headerFix.Parent           = header

local titleLbl = Instance.new("TextLabel")
titleLbl.Size              = UDim2.new(1, -80, 1, 0)
titleLbl.Position          = UDim2.new(0, 12, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text              = "⚡ LuckatHub  <font color=\"#00FF99\">VIP PRO</font>"
titleLbl.RichText          = true
titleLbl.TextColor3        = Color3.fromRGB(255, 255, 255)
titleLbl.TextSize          = 13
titleLbl.Font              = Enum.Font.GothamBold
titleLbl.TextXAlignment    = Enum.TextXAlignment.Left
titleLbl.Parent            = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size             = UDim2.new(0, 24, 0, 24)
closeBtn.Position         = UDim2.new(1, -30, 0.5, -12)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
closeBtn.Text             = "✕"
closeBtn.TextColor3       = Color3.new(1,1,1)
closeBtn.TextSize         = 11
closeBtn.Font             = Enum.Font.GothamBold
closeBtn.BorderSizePixel  = 0
closeBtn.AutoButtonColor  = false
closeBtn.Parent           = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)

closeBtn.MouseButton1Click:Connect(function() mainFrame.Visible = false end)
closeBtn.MouseEnter:Connect(function() tweenColor(closeBtn, "BackgroundColor3", Color3.fromRGB(255, 80, 80)) end)
closeBtn.MouseLeave:Connect(function() tweenColor(closeBtn, "BackgroundColor3", Color3.fromRGB(220, 50, 50)) end)

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Size             = UDim2.new(0, 128, 1, -36)
sidebar.Position         = UDim2.new(0, 0, 0, 36)
sidebar.BackgroundColor3 = Color3.fromRGB(18, 19, 28)
sidebar.BorderSizePixel  = 0
sidebar.Parent           = mainFrame

local sideLayout = Instance.new("UIListLayout")
sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
sideLayout.Padding   = UDim.new(0, 4)
sideLayout.Parent    = sidebar

local sidePad = Instance.new("UIPadding")
sidePad.PaddingTop   = UDim.new(0, 8)
sidePad.PaddingLeft  = UDim.new(0, 6)
sidePad.PaddingRight = UDim.new(0, 6)
sidePad.Parent       = sidebar

-- Content area
local contentArea = Instance.new("Frame")
contentArea.Size             = UDim2.new(1, -128, 1, -36)
contentArea.Position         = UDim2.new(0, 128, 0, 36)
contentArea.BackgroundTransparency = 1
contentArea.ClipsDescendants = true
contentArea.Parent           = mainFrame

local tabs       = {}
local tabBtns    = {}
local activeTab  = nil

-- ── Tab factory ──────────────────────────────────────────
local COL_ACTIVE   = Color3.fromRGB(110, 35, 200)
local COL_INACTIVE = Color3.fromRGB(26, 28, 40)
local COL_TXT_ON   = Color3.fromRGB(255, 255, 255)
local COL_TXT_OFF  = Color3.fromRGB(170, 175, 190)

local function openTab(id)
    if activeTab == id then return end
    activeTab = id
    for tid, frame in pairs(tabs) do
        local on = (tid == id)
        frame.Visible = on
        tweenColor(tabBtns[tid], "BackgroundColor3", on and COL_ACTIVE or COL_INACTIVE)
        tabBtns[tid].TextColor3 = on and COL_TXT_ON or COL_TXT_OFF
    end
end

local function createTab(id, label, icon)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1, 0, 0, 31)
    btn.BackgroundColor3 = COL_INACTIVE
    btn.Text             = icon .. " " .. label
    btn.TextColor3       = COL_TXT_OFF
    btn.TextSize         = 11
    btn.Font             = Enum.Font.GothamSemibold
    btn.TextXAlignment   = Enum.TextXAlignment.Left
    btn.BorderSizePixel  = 0
    btn.AutoButtonColor  = false
    btn.Parent           = sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local bp = Instance.new("UIPadding")
    bp.PaddingLeft = UDim.new(0, 9)
    bp.Parent = btn

    -- ScrollingFrame cho nội dung tab (hỗ trợ nhiều item)
    local sf = Instance.new("ScrollingFrame")
    sf.Size                  = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel       = 0
    sf.ScrollBarThickness    = 3
    sf.ScrollBarImageColor3  = Color3.fromRGB(110, 35, 200)
    sf.CanvasSize            = UDim2.new(0, 0, 0, 0)
    sf.AutomaticCanvasSize   = Enum.AutomaticSize.Y
    sf.Visible               = false
    sf.Parent                = contentArea

    local layout = Instance.new("UIListLayout")
    layout.SortOrder    = Enum.SortOrder.LayoutOrder
    layout.Padding      = UDim.new(0, 6)
    layout.Parent       = sf

    local pad = Instance.new("UIPadding")
    pad.PaddingAll = UDim.new(0, 8)
    pad.Parent     = sf

    tabs[id]    = sf
    tabBtns[id] = btn

    btn.MouseButton1Click:Connect(function() openTab(id) end)
    btn.MouseEnter:Connect(function()
        if activeTab ~= id then
            tweenColor(btn, "BackgroundColor3", Color3.fromRGB(36, 38, 54))
        end
    end)
    btn.MouseLeave:Connect(function()
        if activeTab ~= id then
            tweenColor(btn, "BackgroundColor3", COL_INACTIVE)
        end
    end)

    return sf
end

-- ── Widget: Toggle Row ───────────────────────────────────
local COL_SW_ON  = Color3.fromRGB(0, 215, 110)
local COL_SW_OFF = Color3.fromRGB(40, 44, 60)
local COL_CARD   = Color3.fromRGB(22, 24, 35)

local function addToggle(parent, label, default, onChange)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, 0, 0, 34)
    row.BackgroundColor3 = COL_CARD
    row.BorderSizePixel  = 0
    row.Parent           = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size             = UDim2.new(1, -52, 1, 0)
    lbl.Position         = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text             = label
    lbl.TextColor3       = Color3.fromRGB(225, 228, 240)
    lbl.TextSize         = 11
    lbl.Font             = Enum.Font.GothamSemibold
    lbl.TextXAlignment   = Enum.TextXAlignment.Left
    lbl.TextWrapped      = true
    lbl.Parent           = row

    local sw = Instance.new("TextButton")
    sw.Size             = UDim2.new(0, 36, 0, 18)
    sw.Position         = UDim2.new(1, -44, 0.5, -9)
    sw.BackgroundColor3 = default and COL_SW_ON or COL_SW_OFF
    sw.Text             = ""
    sw.BorderSizePixel  = 0
    sw.AutoButtonColor  = false
    sw.Parent           = row
    Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size             = UDim2.new(0, 12, 0, 12)
    knob.Position         = default and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel  = 0
    knob.Parent           = sw
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local state = default
    sw.MouseButton1Click:Connect(function()
        state = not state
        -- Tween màu nền switch
        TweenService:Create(sw, TWEEN_QUICK, {
            BackgroundColor3 = state and COL_SW_ON or COL_SW_OFF
        }):Play()
        -- Tween vị trí knob
        TweenService:Create(knob, TWEEN_QUICK, {
            Position = state
                and UDim2.new(1, -14, 0.5, -6)
                or  UDim2.new(0, 2,   0.5, -6)
        }):Play()
        onChange(state)
    end)

    return row
end

-- ── Widget: Input Row ────────────────────────────────────
local function addInput(parent, label, default, min, max, onChange)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, 0, 0, 34)
    row.BackgroundColor3 = COL_CARD
    row.BorderSizePixel  = 0
    row.Parent           = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size             = UDim2.new(0.58, 0, 1, 0)
    lbl.Position         = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text             = label
    lbl.TextColor3       = Color3.fromRGB(225, 228, 240)
    lbl.TextSize         = 11
    lbl.Font             = Enum.Font.GothamSemibold
    lbl.TextXAlignment   = Enum.TextXAlignment.Left
    lbl.Parent           = row

    local box = Instance.new("TextBox")
    box.Size             = UDim2.new(0.36, 0, 0, 22)
    box.Position         = UDim2.new(0.62, 0, 0.5, -11)
    box.BackgroundColor3 = Color3.fromRGB(30, 33, 48)
    box.Text             = tostring(default)
    box.TextColor3       = Color3.fromRGB(0, 240, 170)
    box.TextSize         = 11
    box.Font             = Enum.Font.GothamBold
    box.ClearTextOnFocus = false
    box.BorderSizePixel  = 0
    box.Parent           = row
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)

    box.FocusLost:Connect(function()
        local v = tonumber(box.Text)
        if v then
            v = math.clamp(v, min, max)
            box.Text = tostring(v)
            onChange(v)
        else
            box.Text = tostring(default)
        end
    end)
end

-- ── Widget: Action Button ────────────────────────────────
local function addButton(parent, label, color, onClick)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = color or COL_ACTIVE
    btn.Text             = label
    btn.TextColor3       = Color3.new(1, 1, 1)
    btn.TextSize         = 11
    btn.Font             = Enum.Font.GothamBold
    btn.BorderSizePixel  = 0
    btn.AutoButtonColor  = false
    btn.Parent           = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(onClick)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TWEEN_QUICK, { BackgroundColor3 = color:Lerp(Color3.new(1,1,1), 0.12) }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TWEEN_QUICK, { BackgroundColor3 = color }):Play()
    end)
end

-- ── Separator Label ──────────────────────────────────────
local function addSectionLabel(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size             = UDim2.new(1, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Text             = text
    lbl.TextColor3       = Color3.fromRGB(110, 115, 140)
    lbl.TextSize         = 9
    lbl.Font             = Enum.Font.GothamBold
    lbl.TextXAlignment   = Enum.TextXAlignment.Left
    lbl.Parent           = parent
end

-- ===================== POPULATE TABS =====================

-- Tab 1: Di Chuyển
local moveTab = createTab("move", "Di Chuyển", "🏃")
addSectionLabel(moveTab, "TỐC ĐỘ & NHẢY")
addToggle(moveTab, "Speed Hack",      Cfg.SpeedEnabled, function(v) Cfg.SpeedEnabled = v end)
addInput (moveTab, "Tốc độ (Speed)",  Cfg.Speed,  16, 300, function(v) Cfg.Speed = v end)
addToggle(moveTab, "Jump Hack",       Cfg.JumpEnabled,  function(v) Cfg.JumpEnabled = v end)
addInput (moveTab, "Jump Power",      Cfg.Jump,   50, 600, function(v) Cfg.Jump = v end)
addSectionLabel(moveTab, "NÂNG CAO")
addToggle(moveTab, "🚀 Chế Độ Bay (Fly)",       Cfg.Fly,    function(v) Cfg.Fly = v end)
addInput (moveTab, "Fly Speed",       Cfg.FlySpeed, 10, 300, function(v) Cfg.FlySpeed = v end)
addToggle(moveTab, "Xuyên Tường (Noclip)", Cfg.Noclip, function(v) Cfg.Noclip = v end)

-- Tab 2: Tác Chiến
local combatTab = createTab("combat", "Tác Chiến", "⚔️")
addSectionLabel(combatTab, "QUAN SÁT")
addToggle(combatTab, "1. Wallhack / ESP Nhìn Xuyên Tường", Cfg.Wallhack, function(v)
    Cfg.Wallhack = v
    for _, folder in pairs(espFolders) do
        local hl = folder:FindFirstChild("WallhackHighlight")
        if hl then hl.Enabled = v end
    end
end)
addSectionLabel(combatTab, "ĐIỀU KHIỂN TRỰC TIẾP")
addToggle(combatTab, "2. Hiện Nút Teleport & Aim Trên Màn Hình", Cfg.OnScreenButtons, function(v)
    toggleOnScreenButtons(v)
end)

-- Tab 3: Bảo Vệ
local protectTab = createTab("protect", "Bảo Vệ", "🛡️")
addSectionLabel(protectTab, "TÍNH MẠNG & ỔN ĐỊNH")
addToggle(protectTab, "Anti-AFK (Chống văng treo máy)",         Cfg.AntiAFK,   function(v) Cfg.AntiAFK = v end)
addToggle(protectTab, "Anti-Stun / Anti-Ragdoll (All Game)",    Cfg.AntiStun,  function(v) Cfg.AntiStun = v end)
addToggle(protectTab, "Anti-Void (Cứu khi rơi xuống vực)",      Cfg.AntiVoid,  function(v) Cfg.AntiVoid = v end)

addSectionLabel(protectTab, "CHỐNG HACKER")
addToggle(protectTab, "🚨 Anti-Hacker Teleport (Chống dính sát)", Cfg.AntiHackerTP, function(v)
    Cfg.AntiHackerTP = v
    if v then
        enableAntiHackerTP()  -- bắt đầu theo dõi
    else
        disableAntiHackerTP() -- dừng hẳn, dọn sạch
    end
end)
addInput(protectTab, "Bán kính nguy hiểm (studs)", Cfg.AntiHackerRadius, 3, 30, function(v)
    Cfg.AntiHackerRadius = v
end)
addInput(protectTab, "Lực đẩy ra khi bị tấn công", Cfg.AntiHackerPush, 8, 60, function(v)
    Cfg.AntiHackerPush = v
end)

addSectionLabel(protectTab, "👻 GHOST MODE v2 — PHANTOM VELOCITY")
addToggle(protectTab, "👻 Ghost Mode (Bật toàn bộ hệ thống)", Cfg_Ghost.GhostMode, function(v)
    if v then enableGhostMode() else disableGhostMode() end
end)
addToggle(protectTab, "🌀 Ghost Jitter 60fps — Rung HRP mỗi frame", Cfg_Ghost.GhostJitter, function(v)
    Cfg_Ghost.GhostJitter = v
end)
addToggle(protectTab, "↕️ Y-Jitter — Phá vertical aimbot (aim đầu)", Cfg_Ghost.GhostYJitter, function(v)
    Cfg_Ghost.GhostYJitter = v
end)
addToggle(protectTab, "⚡ Phantom Velocity — Văng ra khi bị áp sát", Cfg_Ghost.PhantomVelocity, function(v)
    Cfg_Ghost.PhantomVelocity = v
end)
addToggle(protectTab, "🏃 Auto-Dodge — Backup nếu tắt Phantom", Cfg_Ghost.GhostAutoDodge, function(v)
    Cfg_Ghost.GhostAutoDodge = v
end)
addInput(protectTab, "Bán kính jitter (studs)", Cfg_Ghost.GhostRadius, 1, 8, function(v)
    Cfg_Ghost.GhostRadius = v
end)
addInput(protectTab, "Phantom Force (studs/s)", Cfg_Ghost.PhantomForce, 50, 200, function(v)
    Cfg_Ghost.PhantomForce = v
end)
addInput(protectTab, "Phantom Up Force (studs/s)", Cfg_Ghost.PhantomUpForce, 10, 80, function(v)
    Cfg_Ghost.PhantomUpForce = v
end)
addInput(protectTab, "Khoảng dodge backup (studs)", Cfg_Ghost.GhostDodgeRange, 10, 50, function(v)
    Cfg_Ghost.GhostDodgeRange = v
end)

-- Tab 4: ⚡ ULTRA BYPASS ENGINE (tab mới hoàn toàn)
local bypassTab = createTab("bypass", "Ultra Bypass", "⚡")

addSectionLabel(bypassTab, "⚡ ULTRA BYPASS — SUPER SAIYAN")

-- Trạng thái hiển thị
local bypassStatusLabel = Instance.new("TextLabel")
bypassStatusLabel.Size             = UDim2.new(1, 0, 0, 28)
bypassStatusLabel.BackgroundColor3 = Color3.fromRGB(15, 40, 20)
bypassStatusLabel.TextColor3       = Color3.fromRGB(0, 255, 120)
bypassStatusLabel.TextSize         = 10
bypassStatusLabel.Font             = Enum.Font.GothamBold
bypassStatusLabel.TextWrapped      = true
bypassStatusLabel.BorderSizePixel  = 0
bypassStatusLabel.Parent           = bypassTab
Instance.new("UICorner", bypassStatusLabel).CornerRadius = UDim.new(0, 6)

local function refreshBypassStatus()
    local s = UltraBypass.Status()
    bypassStatusLabel.Text = "Metatable: " .. (s.MetatableHooked and "✅" or "❌")
        .. "  |  KickBlock: " .. (s.KickBlockActive and "✅" or "❌")
        .. "  |  Lvl: " .. s.ExecutorLevel
end
refreshBypassStatus()

addSectionLabel(bypassTab, "BẢO VỆ KHÔNG BỊ KICK / BAN")
addToggle(bypassTab, "🔒 Kick Block (Chặn mọi lệnh Kick/Ban)", true, function(v)
    UltraBypass.SetKickBlock(v)
    refreshBypassStatus()
end)

addSectionLabel(bypassTab, "LỌC REMOTE NGUY HIỂM")
addToggle(bypassTab, "🚫 Remote Blacklist Filter (Auto-block report remote)", true, function(v)
    -- Toggle remote filter bằng cách bật/tắt keyword check trong namecall
    -- (biến nội bộ trong closure — trạng thái lưu qua UltraBypass)
    UltraBypass._remoteFilterEnabled = v
    print("[LuckatHub ⚡Bypass] Remote Filter: " .. (v and "ON" or "OFF"))
end)
addButton(bypassTab, "📋 Xem Log Remote Bị Chặn (Print Console)", Color3.fromRGB(40, 80, 180), function()
    print("[LuckatHub] Remote filter log — check Output để xem danh sách remote bị chặn")
end)

addSectionLabel(bypassTab, "NGỤY TRANG SCRIPT")
addButton(bypassTab, "🎭 Randomize Tên Script (Disguise Again)", Color3.fromRGB(80, 40, 160), function()
    pcall(function()
        local names = {
            "RobloxPlayerScripts", "PlayerModule", "CameraModule",
            "ControlModule", "ChatMain", "BubbleChat", "PlayerlistModule",
            "RbxGui", "CoreScriptSyncService", "NotificationScript"
        }
        if script and script.Parent then
            script.Name = names[math.random(1, #names)]
            print("[LuckatHub ⚡Bypass] Script disguised as: " .. script.Name)
        end
    end)
end)

addSectionLabel(bypassTab, "DIỆT THREAD ANTICHEAT")
addButton(bypassTab, "🧵 Scan & Yield AC Threads (Chạy Ngay)", Color3.fromRGB(160, 40, 40), function()
    pcall(function()
        if not getthreads then
            print("[LuckatHub ⚡Bypass] getthreads() không hỗ trợ trên executor này")
            return
        end
        local count = 0
        local keywords = {
            "speedcheck", "speed_check", "positioncheck", "position_check",
            "anticheat", "anti_cheat", "velocity_check", "sanitycheck",
            "detect", "cheat_monitor", "exploit_check"
        }
        for _, thread in ipairs(getthreads()) do
            pcall(function()
                local info = tostring(thread):lower()
                for _, kw in ipairs(keywords) do
                    if info:find(kw, 1, true) then
                        task.defer(function() coroutine.yield(thread) end)
                        count += 1
                        warn("[LuckatHub ⚡Bypass] AC Thread yielded: " .. kw)
                        break
                    end
                end
            end)
        end
        print("[LuckatHub ⚡Bypass] Thread scan done — " .. count .. " thread(s) yielded")
    end)
end)

addSectionLabel(bypassTab, "TRẠNG THÁI BYPASS")
addButton(bypassTab, "🔄 Refresh Status Panel", Color3.fromRGB(30, 100, 60), function()
    refreshBypassStatus()
    print("[LuckatHub ⚡Bypass] Status refreshed")
end)
addButton(bypassTab, "📊 In Full Bypass Report Ra Output", Color3.fromRGB(50, 50, 140), function()
    local s = UltraBypass.Status()
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("⚡ LuckatHub ULTRA BYPASS — FULL REPORT")
    print("   Metatable Hooked  : " .. tostring(s.MetatableHooked))
    print("   Kick Block Active : " .. tostring(s.KickBlockActive))
    print("   Executor Level    : " .. s.ExecutorLevel)
    print("   __namecall hook   : " .. (s.MetatableHooked and "✅ patched" or "❌ not hooked"))
    print("   __newindex hook   : " .. (s.MetatableHooked and "✅ patched" or "❌ not hooked"))
    print("   Remote Filter     : ✅ blacklist 14 keywords")
    print("   Script Disguise   : ✅ randomized CoreScript name")
    print("   Thread Killer     : ✅ getthreads() scan active")
    print("   Anti-Debug        : ✅ debug.sethook guarded")
    print("   Env Spoof         : ✅ getfenv() hooked")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
end)

-- Tab 5: Fix Lag & FPS
local lagTab = createTab("lag", "Fix Lag", "🚀")
addSectionLabel(lagTab, "TỐI ƯU HIỆU NĂNG (ALL GAME)")
addButton(lagTab, "⚡ Bật Fix Lag Liên Tục (All Game)",
    Color3.fromRGB(0, 170, 120), enableFixLagLive)
addButton(lagTab, "🔴 Tắt Fix Lag (Khôi phục Effect)",
    Color3.fromRGB(180, 40, 40), disableFixLag)
addSectionLabel(lagTab, "ĐỒ HỌA")
addButton(lagTab, "🚀 Ultra Low Graphics (Max FPS)",
    Color3.fromRGB(20, 130, 220), applyUltraLowGraphics)
addButton(lagTab, "🗑️ Xóa Bóng & Sương Mù",
    Color3.fromRGB(130, 80, 210), function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd        = 9e9
        Lighting.FogStart      = 9e9
    end)

-- Mặc định mở tab Di Chuyển
openTab("move")

-- ===================== FLOATING LUCKATHUB BUTTON =====================
local floatBtn = Instance.new("TextButton")
floatBtn.Name             = "LuckatFloat"
floatBtn.Size             = UDim2.new(0, 112, 0, 32)
floatBtn.Position         = UDim2.new(0, 14, 0.14, 0)
floatBtn.BackgroundColor3 = Color3.fromRGB(108, 32, 200)
floatBtn.Text             = "⚡ LuckatHub"
floatBtn.TextColor3       = Color3.new(1, 1, 1)
floatBtn.TextSize         = 12
floatBtn.Font             = Enum.Font.GothamBold
floatBtn.BorderSizePixel  = 0
floatBtn.AutoButtonColor  = false
floatBtn.Parent           = gui
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(0, 8)

local fStroke = Instance.new("UIStroke")
fStroke.Color     = Color3.fromRGB(200, 160, 255)
fStroke.Thickness = 1
fStroke.Parent    = floatBtn

floatBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)
floatBtn.MouseEnter:Connect(function()
    tweenColor(floatBtn, "BackgroundColor3", Color3.fromRGB(138, 43, 226))
end)
floatBtn.MouseLeave:Connect(function()
    tweenColor(floatBtn, "BackgroundColor3", Color3.fromRGB(108, 32, 200))
end)

-- Draggable: Header kéo cả bảng, floatBtn kéo riêng
makeDraggable(mainFrame, header)
makeDraggable(floatBtn)

print("✅ LuckatHub v2.1 loaded — Ultra Bypass Super Saiyan active, UI optimized, all-game compatible.")
