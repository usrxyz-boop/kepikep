
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local Workspace         = game:GetService("Workspace")
local TweenService      = game:GetService("TweenService")
local VIM               = game:GetService("VirtualInputManager")
local VirtualUser       = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService   = game:GetService("TeleportService")
local LP                = Players.LocalPlayer

while not LP do task.wait() end

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

-- NORENDER
local blackScreenGui
local function CreateBlackScreen()
    if blackScreenGui then return end
    blackScreenGui = Instance.new("ScreenGui")
    blackScreenGui.Name = "NoRenderBackground"
    blackScreenGui.DisplayOrder = -99999
    blackScreenGui.IgnoreGuiInset = true
    blackScreenGui.ResetOnSpawn = false
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 1, 0)
    f.BackgroundColor3 = Color3.new(0, 0, 0)
    f.BorderSizePixel = 0
    f.Parent = blackScreenGui
    local ok = pcall(function() blackScreenGui.Parent = game:GetService("CoreGui") end)
    if not ok then blackScreenGui.Parent = LP:WaitForChild("PlayerGui") end
end

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
            part.CanCollide = false
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

RunService.Heartbeat:Connect(function()
    local char = LP.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local rootPos = root.Position
    for _, part in ipairs(getCoinParts(getCoinContainers())) do
        if (rootPos - part.Position).Magnitude <= AURA_RADIUS then
            touch(root, part)
        end
    end
end)

-- AUTO FARM
local function GetMap()
    while true do
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:GetAttribute("MapID") and obj:FindFirstChild("CoinContainer") then
                return obj
            end
        end
        task.wait()
    end
end

local function getNearest()
    local map = GetMap()
    if not map then return nil end
    local closest, dist = nil, math.huge
    for _, coin in ipairs(map.CoinContainer:GetChildren()) do
        local v = coin:FindFirstChild("CoinVisual")
        if v and not v:GetAttribute("Collected") then
            local d = (HRP.Position - coin.Position).Magnitude
            if d < dist then
                closest = coin
                dist = d
            end
        end
    end
    return closest
end

local function tp(hp)
    if not Humanoid or not HRP or not hp then return end
    Humanoid:ChangeState(11)
    local d = (HRP.Position - hp.Position).Magnitude
    local t = TweenService:Create(HRP, TweenInfo.new(d / 15, Enum.EasingStyle.Linear), {CFrame = hp.CFrame})
    t:Play()
    t.Completed:Wait()
end

task.spawn(function()
    while true do
        local target = getNearest()
        if target and LP:GetAttribute("Alive") then
            tp(target)
            local v = target:FindFirstChild("CoinVisual")
            while v and not v:GetAttribute("Collected") and v.Parent do
                if not LP:GetAttribute("Alive") then break end
                local n = getNearest()
                if n and n ~= target then break end
                task.wait()
            end
        else
            task.wait(0.5)
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

    -- Metode utama
    pcall(function() h.Health = 0 end)
    pcall(function() h:TakeDamage(math.huge) end)

    task.wait(0.3)

    -- Fallback kalau masih hidup
    if h.Health > 0 and h.Parent then
        pcall(function() h:ChangeState(Enum.HumanoidStateType.Dead) end)
        pcall(function() char:BreakJoints() end)
    end

    task.wait(0.5)
    isResetting = false
end

-- Reset flag saat character respawn
LP.CharacterAdded:Connect(function()
    task.wait(1)
    isResetting = false
end)

-- COIN TIMER + AUTO RESET
local lastCoinTime = tick()
local COIN_TIMEOUT = 60
local rejoining = false

task.spawn(function()
    local remotes = game:GetService("ReplicatedStorage")
        :WaitForChild("Remotes")
    local gameplay = remotes:WaitForChild("Gameplay")
    local CoinCollected = gameplay:WaitForChild("CoinCollected")

    CoinCollected.OnClientEvent:Connect(function(...)
        local args = {...}

        print("[COIN EVENT] Terpanggil")
        for i, value in ipairs(args) do
            print("[COIN EVENT]", i, typeof(value), tostring(value))
        end

        lastCoinTime = tick()

        -- TODO: kondisi koin penuh perlu memakai
        -- argumen yang sudah dipastikan benar.
    end)
end)

-- AUTO REJOIN
local function rejoin()
    if rejoining then return end
    rejoining = true

    pcall(function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(
            game.PlaceId, game.JobId, game:GetService("Players").LocalPlayer
        )
    end)

    task.wait(3)

    pcall(function()
        game:GetService("TeleportService"):Teleport(
            game.PlaceId, game:GetService("Players").LocalPlayer
        )
    end)
end

task.spawn(function()
    while true do
        task.wait(5)

        if tick() - lastCoinTime >= COIN_TIMEOUT then
            lastCoinTime = tick()
            rejoin()
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(5)
        if tick() - lastCoinTime >= COIN_TIMEOUT then
            lastCoinTime = tick() -- cegah spam rejoin
            rejoin()
        end
    end
end)

-- ANTI AFK
LP.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- msk
local GuiService = game:GetService("GuiService")
‎local Players = game:GetService("Players")
‎local TeleportService = game:GetService("TeleportService")
‎
‎local player = Players.LocalPlayer
‎
‎local function onErrorMessageChanged(errorMessage)
‎    if errorMessage and errorMessage ~= "" then
‎        print("Error detected: " .. errorMessage)
‎
‎        if player then
‎            wait()
‎            TeleportService:Teleport(game.PlaceId, player)
‎        end
‎    end
‎end
‎
‎GuiService.ErrorMessageChanged:Connect(onErrorMessageChanged)
