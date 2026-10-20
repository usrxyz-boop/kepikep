local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local Workspace         = game:GetService("Workspace")
local TweenService      = game:GetService("TweenService")
local VIM               = game:GetService("VirtualInputManager")
local VirtualUser       = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService       = game:GetService("HttpService")
local TeleportService   = game:GetService("TeleportService")
local GuiService        = game:GetService("GuiService")

local LP
repeat
    LP = Players.LocalPlayer
    task.wait()
until LP

-- FUNGSI SERVER HOP
local function ServerHop()
    warn("Tidak mendapatkan coin dalam 2 menit. Melakukan Server Hop...")
    local placeId = game.PlaceId
    local servers = {}
    local req = request or http_request or (syn and syn.request) or (http and http.request)
    
    if req then
        local success, result = pcall(function()
            return req({
                Url = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100", tostring(placeId)),
                Method = "GET"
            })
        end)
        
        if success and result and result.Body then
            local data = HttpService:JSONDecode(result.Body)
            if data and data.data then
                for _, v in ipairs(data.data) do
                    if type(v) == "table" and v.playing < v.maxPlayers and v.id ~= game.JobId then
                        table.insert(servers, v.id)
                    end
                end
            end
        end
    end

    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(placeId, servers[math.random(1, #servers)], LP)
    else
        TeleportService:Teleport(placeId, LP)
    end
end

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

-- COIN MONITOR, AUTO RESPAWN (COIN FULL) & SERVERHOP TIMER
local lastCoinTime = os.time()

local function isAlive()
    local c = LP.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function respawnPlayer()
    if isAlive() then
        LP.Character.Humanoid.Health = 0
    end
end

-- Deteksi Jumlah Coin & Respawn saat Penuh
task.spawn(function()
    while true do
        task.wait(0.5)
        pcall(function()
            -- Cek teks UI Coin (Misal: "10/10" atau "40/40")
            local mainGui = LP.PlayerGui:FindFirstChild("MainGUI")
            if mainGui then
                local coinLabel = mainGui:FindFirstChild("Game") 
                    and mainGui.Game:FindFirstChild("Coin") 
                    and mainGui.Game.Coin:FindFirstChild("CoinContainer")
                    and mainGui.Game.Coin.CoinContainer:FindFirstChild("Coin")
                
                if coinLabel and coinLabel:IsA("TextLabel") then
                    local current, max = coinLabel.Text:match("(%d+)%s*/%s*(%d+)")
                    if current and max then
                        if tonumber(current) >= tonumber(max) and tonumber(max) > 0 then
                            respawnPlayer()
                        end
                    end
                end
            end

            -- Cek alternatif via leaderstats/Data
            local leaderstats = LP:FindFirstChild("leaderstats") or LP:FindFirstChild("Data")
            if leaderstats then
                local coinVal = leaderstats:FindFirstChild("Coins") or leaderstats:FindFirstChild("Coin")
                local maxCoinVal = leaderstats:FindFirstChild("MaxCoins") or leaderstats:FindFirstChild("MaxCoin")
                if coinVal and maxCoinVal and coinVal.Value >= maxCoinVal.Value and maxCoinVal.Value > 0 then
                    respawnPlayer()
                end
            end
        end)
    end
end)

-- Monitor Perubahan Coin untuk Timer Server Hop
local function watchCoinData()
    local leaderstats = LP:WaitForChild("leaderstats", 5) or LP:WaitForChild("Data", 5)
    if leaderstats then
        for _, stat in ipairs(leaderstats:GetChildren()) do
            if string.find(string.lower(stat.Name), "coin") then
                stat:GetPropertyChangedSignal("Value"):Connect(function()
                    lastCoinTime = os.time()
                end)
            end
        end
    end
end
task.spawn(watchCoinData)

-- Checking loop untuk Server Hop jika timeout 2 menit
task.spawn(function()
    while true do
        task.wait(5)
        if os.time() - lastCoinTime >= 120 then
            ServerHop()
            break
        end
    end
end)

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
                        lastCoinTime = os.time()
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

-- AUTO VOTE MODULE
local CONFIG_VOTE = {
    Mode = 1, -- 0 = Off, 1 = Smallest, 2 = Biggest, 3 = Random
    MaxVotes = 0,
}

local ORDER_MAPS = {
    "Manor", "House 2", "Office 3", "Hospital 3", "Bank 2",
    "Vampire's Castle", "Mansion 2", "WorkPlace", "Hotel 2",
    "Farm House", "Police Station", "Factory", "Bio Lab",
    "Research Facility", "Mil Base"
}

local function normalize(s)
    s = string.lower(s or "")
    s = s:gsub("%-", " ")
    return s:match("^%s*(.-)%s*$") or s
end

local function rankMap(name)
    local clean = normalize(name)
    for i, map in ipairs(ORDER_MAPS) do
        if clean == normalize(map) then return i end
    end
    for i, map in ipairs(ORDER_MAPS) do
        if clean == normalize(map):gsub("%s+%d+$", "") then return i end
    end
    for i, map in ipairs(ORDER_MAPS) do
        if clean:find(normalize(map), 1, true) then return i end
    end
    return #ORDER_MAPS + 1
end

local function getPads()
    local lobby = workspace:FindFirstChild("Lobby")
    local folder = lobby and lobby:FindFirstChild("VotePads")
    if not folder then return {} end

    local result = {}
    for i = 1, 3 do
        local pad = folder:FindFirstChild("VotePad" .. i)
        local trigger = pad and pad:FindFirstChild("Pad")
        local gui = pad and pad:FindFirstChild("VoteInfoGui")
        local container = gui and gui:FindFirstChild("Container")
        local label = container and container:FindFirstChild("MapName")

        if trigger and gui and label then
            table.insert(result, {
                trigger = trigger,
                gui = gui,
                map = label.Text,
            })
        end
    end
    return result
end

local function votingOpen()
    for _, pad in ipairs(getPads()) do
        if pad.gui.Enabled then return true end
    end
    return false
end

local function choosePad(mode)
    local pads = getPads()
    if #pads == 0 then return nil end
    if mode == 3 then return pads[math.random(1, #pads)] end

    table.sort(pads, function(a, b)
        local ra = rankMap(a.map)
        local rb = rankMap(b.map)
        return mode == 1 and (ra < rb) or (ra > rb)
    end)
    return pads[1]
end

local function insidePad(part, position)
    local p = part.CFrame:PointToObjectSpace(position)
    local h = part.Size * 0.5
    return math.abs(p.X) <= h.X and math.abs(p.Y) <= h.Y and math.abs(p.Z) <= h.Z
end

task.spawn(function()
    local votes = 0
    local lastCharacter = nil

    while true do
        task.wait(0.25)
        if CONFIG_VOTE.Mode < 1 or CONFIG_VOTE.Mode > 3 then continue end
        if CONFIG_VOTE.MaxVotes > 0 and votes >= CONFIG_VOTE.MaxVotes then continue end
        if not votingOpen() then
            lastCharacter = nil
            continue
        end

        local target = choosePad(CONFIG_VOTE.Mode)
        if not target or not target.gui.Enabled then continue end

        local character = LP.Character
        if not character or character == lastCharacter then continue end

        local root = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChildOfClass("Humanoid")

        if not root or not humanoid or humanoid.Health <= 0 then continue end

        if not insidePad(target.trigger, root.Position) then
            local destination = target.trigger.Position + Vector3.new(0, 1, 0)
            root.CFrame = CFrame.new(destination) * root.CFrame.Rotation
            root.AssemblyLinearVelocity = Vector3.zero
        end

        task.wait(0.25)

        if character.Parent and humanoid.Health > 0 and target.gui.Parent and target.gui.Enabled and insidePad(target.trigger, root.Position) then
            lastCharacter = character
            votes = votes + 1
            humanoid.Health = 0
        end
    end
end)

-- ANTI AFK
LP.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- AUTO REJOIN
GuiService.ErrorMessageChanged:Connect(function(errorMessage)
    if errorMessage and errorMessage ~= "" then
        warn("Error detected: " .. tostring(errorMessage))
        task.wait(1)
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LP)
        end)
    end
end)
