local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local Workspace         = game:GetService("Workspace")
local TweenService      = game:GetService("TweenService")
local VIM               = game:GetService("VirtualInputManager")
local VirtualUser       = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LP
repeat
    LP = Players.LocalPlayer
    task.wait()
until LP

-- AUTO JOIN
local function TapUI(button)
    if not button then return end
    local pos = button.AbsolutePosition + (button.AbsoluteSize / 2)
    VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
end

task.spawn(function()
    repeat
        task.wait(0.5)
        pcall(function() TapUI(LP.PlayerGui.DeviceSelect.Container.Tablet.Button) end)
        pcall(function() TapUI(LP.PlayerGui.Join.Friends.Play) end)
    until LP.PlayerGui:FindFirstChild("MainGUI")
end)

-- CHARACTER REFS
local Char = LP.Character or LP.CharacterAdded:Wait()
local HRP = Char:WaitForChild("HumanoidRootPart")
local Humanoid = Char:WaitForChild("Humanoid")

LP.CharacterAdded:Connect(function(c)
    Char = c
    HRP = c:WaitForChild("HumanoidRootPart")
    Humanoid = c:WaitForChild("Humanoid")
end)

-- which can cause falling through the floor / into the void.

    local char = LP.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            if part.Name ~= "HumanoidRootPart" then
                part.CanCollide = false
            end
        end
    end
end
RunService.Stepped:Connect(applyNoclip)
LP.CharacterAdded:Connect(function()
    task.wait(0.1)
    applyNoclip()
end)
applyNoclip()

-- COIN AURA
local AURA_RADIUS = 8
local function touch(a, b)
    pcall(function()
        firetouchinterest(a, b, 0)
        firetouchinterest(a, b, 1)
    end)
end

local function getCoinContainers()
    local out = {}
    for _, map in ipairs(Workspace:GetChildren()) do
        local c = map:FindFirstChild("CoinContainer")
        if c then table.insert(out, c) end
    end
    return out
end

local function getCoinParts(containers)
    local out = {}
    for _, c in ipairs(containers) do
        for _, d in ipairs(c:GetDescendants()) do
            if d:IsA("BasePart") and d:FindFirstChild("TouchInterest") then
                table.insert(out, d)
            end
        end
    end
    return out
end

task.spawn(function()
    while true do
        task.wait(0.1)
        local char = LP.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local rootPos = root.Position
                for _, part in ipairs(getCoinParts(getCoinContainers())) do
                    if (rootPos - part.Position).Magnitude <= AURA_RADIUS then
                        touch(root, part)
                    end
                end
            end
        end
    end
end)

-- AUTO FARM (consistent map/container lookup)
local function GetMap()
    -- Use the same map-level lookup as Coin Aura, not the first arbitrary descendant.
    local containers = getCoinContainers()
    for _, container in ipairs(containers) do
        if #container:GetChildren() > 0 then
            return container
        end
    end
    return nil
end

local function getCoinTarget(coin)
    if not coin or not coin.Parent then return nil, nil end

    local visual = coin:FindFirstChild("CoinVisual", true)
    local targetPart

    if coin:IsA("BasePart") then
        targetPart = coin
    elseif coin:IsA("Model") then
        targetPart = coin.PrimaryPart or (visual and visual:IsA("BasePart") and visual)
            or coin:FindFirstChildWhichIsA("BasePart", true)
    else
        targetPart = coin:FindFirstChildWhichIsA("BasePart", true)
    end

    if not targetPart then return nil, visual end
    return targetPart, visual
end

local function isCoinCollected(coin, visual)
    if not coin or not coin.Parent then return true end
    if coin:GetAttribute("Collected") == true then return true end
    if visual and visual:GetAttribute("Collected") == true then return true end
    return false
end

local function getNearest()
    local containers = getCoinContainers()
    if #containers == 0 then return nil, nil, nil end
    if not HRP or not HRP.Parent then return nil, nil, nil end

    local closest, closestVisual, closestCoin
    local dist = math.huge
    local MAX_TARGET_DISTANCE = 250

    -- Search every map-level CoinContainer and choose the nearest valid coin,
    -- rather than trusting the first CoinContainer found in all descendants.
    for _, container in ipairs(containers) do
        for _, coin in ipairs(container:GetChildren()) do
            local targetPart, visual = getCoinTarget(coin)
            if targetPart and not isCoinCollected(coin, visual) then
                local d = (HRP.Position - targetPart.Position).Magnitude
                if d <= MAX_TARGET_DISTANCE and d < dist then
                    closest = targetPart
                    closestVisual = visual
                    closestCoin = coin
                    dist = d
                end
            end
        end
    end

    return closest, closestVisual, closestCoin
end

local function tp(targetPart)
    if not Humanoid or not HRP or not targetPart then return end
    if not HRP.Parent or not targetPart.Parent or Humanoid.Health <= 0 then return end

    local d = (HRP.Position - targetPart.Position).Magnitude
    local tween = TweenService:Create(
        HRP,
        TweenInfo.new(math.max(d / 25, 0.1), Enum.EasingStyle.Linear),
        {CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)}
    )
    tween:Play()
    tween.Completed:Wait()
end

local function isAlive()
    local c = LP.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h ~= nil and h.Health > 0
end

task.spawn(function()
    while true do
        task.wait(0.15)
        if isAlive() then
            local targetPart, visual, coin = getNearest()
            if targetPart then
                tp(targetPart)
                local deadline = os.clock() + 3
                while coin and coin.Parent and not isCoinCollected(coin, visual) and os.clock() < deadline do
                    if not isAlive() then break end
                    task.wait(0.1)
                end
            end
        end
    end
end)

-- AUTO RESET
local isResetting = false

local function resetCharacter()
    if isResetting then return end
    local char = LP.Character
    if not char then return end
    local h = char:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 then return end

    isResetting = true

    pcall(function() h.Health = 0 end)
    pcall(function() h:TakeDamage(math.huge) end)

    task.wait(2)
    isResetting = false
end

-- Trigger reset saat coin penuh
task.spawn(function()
    local remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
    if not remotes then return end

    local gameplay = remotes:WaitForChild("Gameplay", 10)
    if not gameplay then return end

    local CoinCollected = gameplay:WaitForChild("CoinCollected", 10)
    if not CoinCollected then return end

    CoinCollected.OnClientEvent:Connect(function(_, currentCoins)
        if typeof(currentCoins) ~= "number" then return end

        if currentCoins >= 50 then
            resetCharacter()
        end
    end)
end)

-- ANTI AFK
LP.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- AUTO REJOIN
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer

local function onErrorMessageChanged(errorMessage)
    if errorMessage and errorMessage ~= "" then
        print("Error detected: " .. errorMessage)

        if player then
            wait()
            TeleportService:Teleport(game.PlaceId, player)
        end
    end
end

GuiService.ErrorMessageChanged:Connect(onErrorMessageChanged)
