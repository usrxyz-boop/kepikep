local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VIM = game:GetService("VirtualInputManager")

-- FPS cap 15 (aman: pakai pcall, tanpa RenderStepped)
pcall(function()
    if setfpscap then setfpscap(15) end
end)

local LP = Players.LocalPlayer
while not LP do task.wait() LP = Players.LocalPlayer end
local player = LP

-- CONFIG
local SPEED, TIMEOUT, SKIP  = 15, 10, 1
local MIN_DIST, AURA_RADIUS = 6, 8
local EMOTE_ID, EMOTE_POS   = 87058607990254, 0.84
local farmEnabled, emoteEnabled = true, true
local COIN_TIMEOUT = 60

local whitelist = {}
local STUCK_TIMEOUT   = 3
local autoKillEnabled = true
local skippedTargets  = {}
local killThreadActive = false
local activeKillName   = nil
local roundId          = 0
local lastRoundBump    = 0

local lastCoinTime = tick()
local rejoining    = false

local env = (getgenv and getgenv()) or _G
env.__CoinFarmRun = (env.__CoinFarmRun or 0) + 1
local runId = env.__CoinFarmRun
local function active() return env.__CoinFarmRun == runId end

LP.CharacterAdded:Connect(function() lastCoinTime = tick() end)

-- ANTI-AFK
local function kickAntiAfk()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
    pcall(function()
        local cam = workspace.CurrentCamera
        if cam then
            cam.CFrame = cam.CFrame * CFrame.Angles(0, math.rad(0.1), 0)
        end
    end)
end
LP.Idled:Connect(function() kickAntiAfk() end)
task.spawn(function()
    while active() and LP.Parent do
        task.wait(60)
        if LP.Parent and active() then kickAntiAfk() else break end
    end
end)

-- COIN EVENT listener (deteksi coin penuh)
task.spawn(function()
    local ok, err = pcall(function()
        local remotes  = ReplicatedStorage:WaitForChild("Remotes", 30)
        if not remotes  then return end
        local gameplay = remotes:WaitForChild("Gameplay", 30)
        if not gameplay then return end
        local CoinCollected = gameplay:WaitForChild("CoinCollected", 30)
        if not CoinCollected then return end
        CoinCollected.OnClientEvent:Connect(function(...)
            lastCoinTime = tick()
            local args = {...}
            print("[COIN EVENT] Terpanggil")
            for i, value in ipairs(args) do
                print("[COIN EVENT]", i, typeof(value), tostring(value))
            end
        end)
    end)
    if not ok then warn("[CoinCollected] gagal hook: " .. tostring(err)) end
end)

-- WATCHDOG coin penuh
task.spawn(function()
    while active() do
        task.wait(5)
        if not active() then break end
        if not farmEnabled then
            lastCoinTime = tick()
        else
            local elapsed = tick() - lastCoinTime
            if elapsed >= COIN_TIMEOUT then
                warn(string.format("[CoinFull] Tidak ada coin event %.1fs (>= %ds). Rejoin...", elapsed, COIN_TIMEOUT))
                if not rejoining then
                    rejoining = true
                    task.wait(1)
                    if active() then pcall(function() TeleportService:Teleport(game.PlaceId, LP) end) end
                end
                break
            end
        end
    end
end)

-- ERROR MESSAGE -> rejoin
GuiService.ErrorMessageChanged:Connect(function(msg)
    if not msg or msg == "" then return end
    print("[Error Detected] " .. tostring(msg))
    if not active() or rejoining then return end
    rejoining = true
    task.wait(1)
    if active() then pcall(function() TeleportService:Teleport(game.PlaceId, LP) end) end
end)

-- UI tap
local function tap(btn)
    if not btn then return end
    local p = btn.AbsolutePosition + btn.AbsoluteSize / 2
    VIM:SendMouseButtonEvent(p.X, p.Y, 0, true, game, 0)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(p.X, p.Y, 0, false, game, 0)
end
task.spawn(function()
    while active() do
        local pg = LP:FindFirstChild("PlayerGui")
        if pg and not pg:FindFirstChild("MainGUI") then
            pcall(function() tap(pg.DeviceSelect.Container.Tablet.Button) end)
            pcall(function() tap(pg.Join.Friends.Play) end)
        end
        task.wait(0.5)
    end
end)

-- EMOTE
local track
local function stopEmote()
    if track then pcall(function() track:Stop(0) end) track = nil end
end
local function emote(char)
    if not emoteEnabled or not active() then return end
    local hum = char:WaitForChild("Humanoid")
    local animator = hum:WaitForChild("Animator")
    if not emoteEnabled or not active() then return end
    stopEmote()
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. EMOTE_ID
    local t = animator:LoadAnimation(anim)
    track = t
    t.Priority = Enum.AnimationPriority.Action4
    t:Play(0)
    task.spawn(function()
        local waited = os.clock()
        while active() and t == track and t.IsPlaying and t.Length == 0 and os.clock() - waited < 5 do task.wait() end
        if active() and t == track and t.IsPlaying then
            t.TimePosition = EMOTE_POS
            t:AdjustSpeed(0)
        end
    end)
end
LP.CharacterAdded:Connect(function(char) task.spawn(emote, char) end)
if LP.Character then task.spawn(emote, LP.Character) end

-- COIN FARM
local function touch(a, b)
    pcall(function()
        firetouchinterest(a, b, 0)
        firetouchinterest(a, b, 1)
    end)
end

local function getCoinPart(coin)
    if coin:IsA("BasePart") then return coin end
    if coin:IsA("Model") and coin.PrimaryPart then return coin.PrimaryPart end
    return coin:FindFirstChildWhichIsA("BasePart", true)
end

local function isCollected(coin)
    if not coin or not coin.Parent then return true end
    if coin:GetAttribute("Collected") == true then return true end
    local visual = coin:FindFirstChild("CoinVisual", true)
    if visual and visual:GetAttribute("Collected") == true then return true end
    return false
end

-- Aura auto-collect
task.spawn(function()
    while active() do
        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if farmEnabled and root then
            for _, map in ipairs(Workspace:GetChildren()) do
                local container = map:FindFirstChild("CoinContainer")
                if container then
                    for _, part in ipairs(container:GetDescendants()) do
                        if part:IsA("BasePart") and part:FindFirstChild("TouchInterest") then
                            if (root.Position - part.Position).Magnitude <= AURA_RADIUS then
                                touch(root, part)
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

local skipped = {}
local function nearest(root)
    local best, bestPart, bestDist = nil, nil, math.huge
    local now = os.clock()
    for _, map in ipairs(Workspace:GetChildren()) do
        local container = map:FindFirstChild("CoinContainer")
        if container then
            for _, coin in ipairs(container:GetChildren()) do
                if not isCollected(coin) and not (skipped[coin] and skipped[coin] > now) then
                    local part = getCoinPart(coin)
                    if part then
                        local dist = (root.Position - part.Position).Magnitude
                        if dist > MIN_DIST and dist < bestDist then
                            best, bestPart, bestDist = coin, part, dist
                        end
                    end
                end
            end
        end
    end
    return best, bestPart
end

-- MAIN FARM LOOP (skip agresif kalau koin gak ke-collect)
task.spawn(function()
    while active() do
        local tween
        local ok, err = pcall(function()
            if not farmEnabled then task.wait(0.3) return end
            local char = LP.Character or LP.CharacterAdded:Wait()
            local root = char:WaitForChild("HumanoidRootPart")
            local hum  = char:WaitForChild("Humanoid")
            if hum.Health <= 0 or LP:GetAttribute("Alive") == false then
                task.wait(0.3) return
            end
            local coin, part = nearest(root)
            if not coin or not part then task.wait(0.2) return end
            pcall(function() hum:ChangeState(11) end)

            local start = root.Position
            local goal  = part.Position
            local dir   = Vector3.new(goal.X - start.X, 0, goal.Z - start.Z)
            if dir.Magnitude > 0.1 then
                local target = CFrame.lookAt(
                    Vector3.new(goal.X, start.Y, goal.Z),
                    Vector3.new(goal.X, start.Y, goal.Z) + dir
                )
                local duration = math.max(dir.Magnitude / SPEED, 0.1)
                tween = TweenService:Create(
                    root,
                    TweenInfo.new(duration, Enum.EasingStyle.Linear),
                    { CFrame = target }
                )
                tween:Play()
                task.wait(math.min(duration, TIMEOUT))
                tween:Cancel()
            end

            local began = os.clock()
            local collected = false
            while active() and os.clock() - began < 1.5 do
                if not farmEnabled or hum.Health <= 0 then break end
                if LP.Character ~= char then break end
                if isCollected(coin) or not part.Parent then
                    collected = true
                    break
                end
                if (root.Position - part.Position).Magnitude <= AURA_RADIUS then
                    collected = true
                    break
                end
                task.wait(0.05)
            end

            if not collected then
                skipped[coin] = os.clock() + SKIP
            else
                skipped[coin] = nil
            end
        end)
        if tween then pcall(function() tween:Cancel() end) end
        if not ok then warn("[Farm] " .. tostring(err)) end
        task.wait(0.1)
    end
end)

-- ASSASSIN UTILS
local function isWhitelisted(p)
    if typeof(p) == "Instance" and p:IsA("Player") then
        if table.find(whitelist, p.Name) or table.find(whitelist, p.UserId) then return true end
    elseif type(p) == "string" then
        if table.find(whitelist, p) then return true end
        local plr = Players:FindFirstChild(p)
        if plr and (table.find(whitelist, plr.UserId) or table.find(whitelist, plr.Name)) then return true end
    end
    return false
end

local function getKnife()
    local char = player.Character
    if char then
        local k = char:FindFirstChild("Knife")
        if k then return k end
    end
    local bp = player:FindFirstChild("Backpack")
    if bp then
        local k = bp:FindFirstChild("Knife")
        if k then return k end
    end
    return nil
end
local function hasKnife() return getKnife() ~= nil end

local function getKillPart(char)
    if not char then return nil end
    return char:FindFirstChild("UpperTorso")
        or char:FindFirstChild("Torso")
        or char:FindFirstChild("HumanoidRootPart")
end

local function rawFire(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local knife = getKnife()
    if not knife then return end
    if knife.Parent ~= player.Character and player.Character then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:EquipTool(knife) end
    end
    local events = knife:FindFirstChild("Events")
    if not events then return end
    local ht = events:FindFirstChild("HandleTouched")
    if not ht then return end
    local part = getKillPart(targetPlayer.Character)
    if not part then return end
    ht:FireServer(part)
end

-- ASSASSIN KILL LOGIC
local function killTargetSync(targetPlayer, currentRound)
    local name = targetPlayer.Name
    local startTime = os.clock()
    while autoKillEnabled and hasKnife() do
        if currentRound ~= roundId then break end
        if not targetPlayer or not targetPlayer.Character or not targetPlayer:IsDescendantOf(Players) then break end
        local hum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then break end
        if (os.clock() - startTime) > STUCK_TIMEOUT then
            skippedTargets[name] = true
            warn("[Assassin] Target " .. name .. " gagal terbunuh (Timeout Skip).")
            break
        end
        rawFire(targetPlayer)
        task.wait(0.05)
    end
end

local function startAutoKillLoop()
    if killThreadActive then return end
    killThreadActive = true
    task.spawn(function()
        local currentRound = roundId
        while autoKillEnabled and hasKnife() and currentRound == roundId do
            local targets = Players:GetPlayers()
            local targetFound = false
            for _, target in ipairs(targets) do
                if currentRound ~= roundId or not hasKnife() then break end
                if target ~= player
                   and not isWhitelisted(target)
                   and not skippedTargets[target.Name]
                   and target.Character
                then
                    local hum = target.Character:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        targetFound = true
                        activeKillName = target.Name
                        killTargetSync(target, currentRound)
                        activeKillName = nil
                        task.wait(0.05)
                    end
                end
            end
            if not targetFound then task.wait(0.5) end
        end
        killThreadActive = false
    end)
end

-- ASSASSIN WATCHERS
local function bumpRound()
    local now = os.clock()
    if now - lastRoundBump < 1 then return end
    lastRoundBump = now
    roundId = roundId + 1
    skippedTargets = {}
end

local function watchChar(char)
    if not char then return end
    char.ChildAdded:Connect(function(item)
        if item.Name == "Knife" then
            bumpRound()
            startAutoKillLoop()
        end
    end)
end

local function watchBackpack()
    local bp = player:WaitForChild("Backpack")
    bp.ChildAdded:Connect(function(item)
        if item.Name == "Knife" then
            bumpRound()
            startAutoKillLoop()
        end
    end)
end

if LP.Character then watchChar(LP.Character) end
LP.CharacterAdded:Connect(watchChar)
task.spawn(watchBackpack)

print("[Loaded] Coin Farm + Anti-AFK + Assassin + CoinFull/Error detection (FPS cap 15) - dengan skip agresif")
