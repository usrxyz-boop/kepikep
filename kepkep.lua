local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")
local VIM = game:GetService("VirtualInputManager")

local LP = Players.LocalPlayer
while not LP do task.wait() LP = Players.LocalPlayer end

local SPEED, TIMEOUT, SKIP = 15, 10, 1
local MIN_DIST, AURA_RADIUS = 6, 8
local EMOTE_ID, EMOTE_POS = 87058607990254, 0.84
local farmEnabled, emoteEnabled = true, true

local env = (getgenv and getgenv()) or _G
env.__CoinFarmRun = (env.__CoinFarmRun or 0) + 1
local runId = env.__CoinFarmRun
local function active() return env.__CoinFarmRun == runId end

local rejoining = false

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

GuiService.ErrorMessageChanged:Connect(function(msg)
    if not active() or not msg or msg == "" or rejoining then return end
    rejoining = true
    task.wait(1)
    if active() then
        pcall(function() TeleportService:Teleport(game.PlaceId, LP) end)
    end
end)

LP.Idled:Connect(function()
    if not active() then return end
    pcall(function()
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.1)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
end)

local track

local function stopEmote()
    if track then
        pcall(function() track:Stop(0) end)
        track = nil
    end
end

local function emote(char)
    if not emoteEnabled then return end
    local hum = char:WaitForChild("Humanoid")
    local animator = hum:WaitForChild("Animator")
    if not emoteEnabled then return end
    stopEmote()

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. EMOTE_ID
    local t = animator:LoadAnimation(anim)
    track = t
    t.Priority = Enum.AnimationPriority.Action4
    t:Play(0)

    task.spawn(function()
        local waited = os.clock()
        while active() and t == track and t.IsPlaying
            and t.Length == 0 and os.clock() - waited < 5 do
            task.wait()
        end
        if active() and t == track and t.IsPlaying then
            t.TimePosition = EMOTE_POS
            t:AdjustSpeed(0)
        end
    end)
end

LP.CharacterAdded:Connect(function(char) task.spawn(emote, char) end)
if LP.Character then task.spawn(emote, LP.Character) end

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
    local v = coin:FindFirstChild("CoinVisual", true)
    if not v then return true end
    return v:GetAttribute("Collected") or coin:GetAttribute("Collected") or false
end

task.spawn(function()
    while active() do
        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if farmEnabled and root then
            for _, map in ipairs(Workspace:GetChildren()) do
                local c = map:FindFirstChild("CoinContainer")
                if c then
                    for _, part in ipairs(c:GetDescendants()) do
                        if part:IsA("BasePart")
                            and part:FindFirstChild("TouchInterest")
                            and (root.Position - part.Position).Magnitude <= AURA_RADIUS then
                            touch(root, part)
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
    for _, map in ipairs(Workspace:GetChildren()) do
        local c = map:FindFirstChild("CoinContainer")
        if c then
            for _, coin in ipairs(c:GetChildren()) do
                if not isCollected(coin)
                    and not (skipped[coin] and skipped[coin] > os.clock()) then
                    local part = getCoinPart(coin)
                    if part then
                        local d = (root.Position - part.Position).Magnitude
                        if d > MIN_DIST and d < bestDist then
                            best, bestPart, bestDist = coin, part, d
                        end
                    end
                end
            end
        end
    end
    return best, bestPart
end

task.spawn(function()
    while active() do
        local ok, err = pcall(function()
            if not farmEnabled then task.wait(0.3) return end

            local char = LP.Character or LP.CharacterAdded:Wait()
            local root = char:WaitForChild("HumanoidRootPart")
            local hum = char:WaitForChild("Humanoid")

            if hum.Health <= 0 or LP:GetAttribute("Alive") == false then
                task.wait(0.5)
                return
            end

            local coin, part = nearest(root)
            if not coin then task.wait(0.5) return end

            pcall(function() hum:ChangeState(11) end)

            local start, goal = root.Position, part.Position
            local dir = Vector3.new(goal.X - start.X, 0, goal.Z - start.Z)
            local cf = dir.Magnitude > 0.01 and CFrame.lookAt(goal, goal + dir) or CFrame.new(goal)

            local tween = TweenService:Create(root, TweenInfo.new(
                math.max((start - goal).Magnitude / SPEED, 0.05),
                Enum.EasingStyle.Linear
            ), {CFrame = cf})

            tween:Play()
            local began = os.clock()

            while active() and os.clock() - began < TIMEOUT do
                if not farmEnabled or isCollected(coin) or hum.Health <= 0
                    or (root.Position - part.Position).Magnitude <= AURA_RADIUS then
                    break
                end
                task.wait(0.05)
            end

            if tween.PlaybackState == Enum.PlaybackState.Playing then tween:Cancel() end
            if not isCollected(coin) then skipped[coin] = os.clock() + SKIP end
        end)

        if not ok then warn("[Farm] " .. tostring(err)) end
        task.wait()
    end
end)

print("Coin Farm Farted")
