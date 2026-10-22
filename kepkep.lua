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

pcall(function() RunService:Set3dRenderingEnabled(false) end)
CreateBlackScreen()

LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    pcall(function() RunService:Set3dRenderingEnabled(false) end)
    CreateBlackScreen()
end)

-- NOCLIP
local function applyNoclip()
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

-- AUTO FARM
local function GetMap()
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:GetAttribute("MapID") and obj:FindFirstChild("CoinContainer") then
            return obj
        end
    end
    return nil
end

local function getNearest()
    local map = GetMap()
    if not map then return nil end
    if not HRP or not HRP.Parent then return nil end

    local closest, dist = nil, math.huge
    for _, coin in ipairs(map.CoinContainer:GetChildren()) do
        local visual = coin:FindFirstChild("CoinVisual")
        if visual and not visual:GetAttribute("Collected") then
            local part
            if coin:IsA("BasePart") then
                part = coin
            elseif coin:IsA("Model") then
                part = coin.PrimaryPart or coin:FindFirstChildWhichIsA("BasePart", true)
            else
                part = coin:FindFirstChildWhichIsA("BasePart", true)
            end

            if part then
                local d = (HRP.Position - part.Position).Magnitude
                -- Skip coins 4 studs away or closer; keep choosing the nearest
                -- eligible coin in the active map, not a coin in another map.
                if d > 4 and d < dist then
                    closest = part
                    dist = d
                end
            end
        end
    end
    return closest
end

local function tp(hp)
    if not Humanoid or not HRP or not hp then return end
    if not HRP.Parent or not hp.Parent or Humanoid.Health <= 0 then return end

    local d = (HRP.Position - hp.Position).Magnitude
    local tween = TweenService:Create(
        HRP,
        TweenInfo.new(math.max(d / 25, 0.1), Enum.EasingStyle.Linear),
        {CFrame = hp.CFrame}
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
        if not isAlive() then
            task.wait(0.5)
        else
            local target = getNearest()
            if target then
                tp(target)
                -- Recheck immediately after movement; if the coin is still there,
                -- the next loop picks the nearest eligible target again.
            else
                task.wait(0.15)
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
