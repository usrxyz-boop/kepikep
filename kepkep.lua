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

-- NORENDER
local blackScreenGui
local function CreateBlackScreen()
    if blackScreenGui and blackScreenGui.Parent then return end
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
    if not ok then
        pcall(function() blackScreenGui.Parent = LP:WaitForChild("PlayerGui") end)
    end
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
    for _, obj in ipairs(workspace:GetChildren()) do
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
    if not HRP.Parent or Humanoid.Health <= 0 then return end
    local d = (HRP.Position - hp.Position).Magnitude
    local t = TweenService:Create(HRP, TweenInfo.new(d / 15, Enum.EasingStyle.Linear), {CFrame = hp.CFrame})
    t:Play()
    t.Completed:Wait()
end

local function isAlive()
    local c = LP.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

-- AUTO FARM (bisa dijeda saat reset)
local farmingEnabled = true

task.spawn(function()
    while true do
        if not farmingEnabled or not isAlive() then
            task.wait(0.25)
        else
            local target = getNearest()
            if target and farmingEnabled then
                tp(target)
                local v = target:FindFirstChild("CoinVisual")
                while farmingEnabled and v and not v:GetAttribute("Collected") and v.Parent do
                    if not isAlive() then break end
                    local n = getNearest()
                    if n and n ~= target then break end
                    task.wait()
                end
            else
                task.wait(0.25)
            end
        end
    end
end)

-- AUTO RESET: jeda autofarm, reset karakter, lalu lanjutkan
local isResetting = false

local function resetCharacter()
    if isResetting then return end
    local char = LP.Character
    if not char then return end
    local h = char:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 then return end

    isResetting = true
    farmingEnabled = false

    -- Hentikan tween yang mungkin masih berjalan pada karakter lama
    pcall(function()
        h.Health = 0
    end)

    -- Tunggu karakter baru muncul dan Humanoid hidup
    local newChar = LP.Character
    if newChar == char then
        local ok, result = pcall(function()
            return LP.CharacterAdded:Wait()
        end)
        if ok then newChar = result end
    end

    if newChar then
        local newHumanoid = newChar:WaitForChild("Humanoid", 10)
        if newHumanoid then
            local deadline = os.clock() + 10
            while newHumanoid.Health <= 0 and os.clock() < deadline do
                task.wait(0.1)
            end
        end
    end

    task.wait(0.5)
    farmingEnabled = true
    isResetting = false
end

-- Trigger reset saat coin penuh
task.spawn(function()
    pcall(function()
        local remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
        if not remotes then return end
        local gameplay = remotes:WaitForChild("Gameplay", 10)
        if not gameplay then return end
        local CoinCollected = gameplay:WaitForChild("CoinCollected", 10)
        if not CoinCollected then return end

        CoinCollected.OnClientEvent:Connect(function(_, currentCoins, maxCoins)
            if typeof(currentCoins) == "number" and typeof(maxCoins) == "number" then
                if currentCoins >= maxCoins then
                    resetCharacter()
                end
            end
        end)
    end)
end)

-- ANTI AFK
LP.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- AUTO REJOIN: teleport ulang jika pesan error Roblox berubah
local GuiService = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")

local function onErrorMessageChanged(errorMessage)
    if errorMessage and errorMessage ~= "" then
        warn("Error detected: " .. tostring(errorMessage))
        task.wait(1)
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LP)
        end)
    end
end

GuiService.ErrorMessageChanged:Connect(onErrorMessageChanged)
