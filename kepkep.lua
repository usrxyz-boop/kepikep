local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local VIM = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LP = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local HRP = Char:WaitForChild("HumanoidRootPart")
local Humanoid = Char:WaitForChild("Humanoid")

LP.CharacterAdded:Connect(function(c)
    Char, HRP, Humanoid = c, c:WaitForChild("HumanoidRootPart"), c:WaitForChild("Humanoid")
end)

-- 1. OPTIMASI & BLACKSCREEN BUILD-IN
pcall(function() RunService:Set3dRenderingEnabled(false) end)
local sg = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
local fr = Instance.new("Frame", sg)
fr.Size, fr.BackgroundColor3 = UDim2.new(1,0,1,0), Color3.new(0,0,0)

-- 2. AUTO JOIN
local function TapUI(btn)
    if not btn then return end
    local pos = btn.AbsolutePosition + (btn.AbsoluteSize / 2)
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

-- 3. NOCLIP
RunService.Stepped:Connect(function()
    if Char then
        for _, part in ipairs(Char:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- 4. COIN AURA & MAP DETECTOR
local function GetMap()
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:GetAttribute("MapID") and obj:FindFirstChild("CoinContainer") then
            return obj
        end
    end
    return nil
end

RunService.Heartbeat:Connect(function()
    if not HRP then return end
    local map = GetMap()
    if not map then return end

    for _, coin in ipairs(map.CoinContainer:GetChildren()) do
        if (HRP.Position - coin.Position).Magnitude <= 8 then
            pcall(function()
                firetouchinterest(HRP, coin, 0)
                firetouchinterest(HRP, coin, 1)
            end)
        end
    end
end)

-- 5. AUTO FARM (TWEEN COIN)
local function getNearestCoin()
    local map = GetMap()
    if not map then return end
    local closest, dist = nil, math.huge
    for _, coin in ipairs(map.CoinContainer:GetChildren()) do
        local v = coin:FindFirstChild("CoinVisual")
        if v and not v:GetAttribute("Collected") then
            local d = (HRP.Position - coin.Position).Magnitude
            if d < dist then
                closest, dist = coin, d
            end
        end
    end
    return closest
end

task.spawn(function()
    while true do
        task.wait(0.1)
        if LP:GetAttribute("Alive") and HRP and Humanoid then
            local target = getNearestCoin()
            if target then
                Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                local dist = (HRP.Position - target.Position).Magnitude
                local tween = TweenService:Create(HRP, TweenInfo.new(dist / 15, Enum.EasingStyle.Linear), {CFrame = target.CFrame})
                tween:Play()
                
                repeat task.wait() until not target or not target.Parent or target:FindFirstChild("CoinVisual"):GetAttribute("Collected") or not LP:GetAttribute("Alive")
                tween:Cancel()
            end
        end
    end
end)

-- 6. TIMEOUT & REJOIN
local lastCoinTime = tick()
local rejoining = false

pcall(function()
    ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Gameplay"):WaitForChild("CoinCollected").OnClientEvent:Connect(function()
        lastCoinTime = tick()
    end)
end)

local function rejoin()
    if rejoining then return end
    rejoining = true
    if not pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP) end) then
        TeleportService:Teleport(game.PlaceId, LP)
    end
end

task.spawn(function()
    while task.wait(5) do
        if tick() - lastCoinTime >= 60 then
            rejoin()
        end
    end
end)

-- 7. ANTI AFK & AUTO RECONNECT ERROR
LP.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

GuiService.ErrorMessageChanged:Connect(function(msg)
    if msg and msg ~= "" then rejoin() end
end)
