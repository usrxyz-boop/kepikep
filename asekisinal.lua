local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

while not Players.LocalPlayer do task.wait() end
local player = Players.LocalPlayer

local autoKillEnabled = true
local ignoredNames = { ["alamak942"] = true, ["ets_gakenaaaaaaaaaaa"] = true }
local activeKillName = nil
local targetLabel = nil
local roundId = 0
local roundStarted = false
local killThreadActive = false

local DEBUG = false
local function log(...) if DEBUG then print("[Assassin Auto]", ...) end end

local STATE = { IDLE = "IDLE", KILLING = "KILLING", FINAL = "FINAL" }
local state = STATE.IDLE

local function resetRound(killSelf)
    roundStarted = false
    state = STATE.IDLE
    activeKillName = nil
    killThreadActive = false
    log("round reset")
    if killSelf then
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            hum.Health = 0
        end
    end
end

-- ============================================================
-- helpers
-- ============================================================

local function isIgnored(p)
    if typeof(p) == "Instance" and p:IsA("Player") then
        return ignoredNames[p.Name] == true
    elseif type(p) == "string" then
        return ignoredNames[p] == true
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

local function getTargetName()
    if not targetLabel then return nil end
    local text = targetLabel.Text
    if text and text ~= "" and text ~= "Nikilis" then return text end
    return nil
end

local function rawFire(name)
    if not name then return end
    if isIgnored(name) then return end
    local knife = getKnife()
    if not knife then return end
    local events = knife:FindFirstChild("Events")
    if not events then return end
    local ht = events:FindFirstChild("HandleTouched")
    if not ht then return end
    local p = Players:FindFirstChild(name)
    if not p or not p.Character then return end
    local part = getKillPart(p.Character)
    if not part then return end
    ht:FireServer(part)
end

-- ============================================================
-- kill logic
-- ============================================================

local function rapidKill(name, myRoundId)
    if activeKillName == name then return end
    if killThreadActive then return end
    if isIgnored(name) then return end
    killThreadActive = true
    activeKillName = name
    log("rapidKill: " .. name)

    task.spawn(function()
        while autoKillEnabled and hasKnife() do
            if myRoundId ~= roundId then break end
            if state == STATE.IDLE then break end

            local cur = getTargetName()
            if cur ~= name then break end
            local p = Players:FindFirstChild(name)
            if not p or not p.Character then break end
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then break end
            
            rawFire(name)
            task.wait(0.05)
        end

        killThreadActive = false
        if activeKillName == name then activeKillName = nil end
        log("rapidKill ended: " .. name)
    end)
end

local function attemptKill(name, source)
    task.spawn(function()
        if not autoKillEnabled then return end
        if not name or name == "" then return end
        if not hasKnife() then return end
        if isIgnored(name) then return end

        if state == STATE.IDLE then state = STATE.KILLING end

        rawFire(name)
        rapidKill(name, roundId)
    end)
end

local function startRound()
    if roundStarted then return end
    roundStarted = true
    roundId += 1
    activeKillName = nil
    killThreadActive = false
    state = STATE.KILLING
end

local function onKnifeDetected()
    task.spawn(function()
        if not autoKillEnabled then return end
        startRound()
        attemptKill(getTargetName(), "knife")
    end)
end

local function onTargetChanged(name)
    task.spawn(function()
        if not autoKillEnabled then return end
        if not hasKnife() then return end
        if isIgnored(name) then return end
        attemptKill(name, "targetChanged")
    end)
end

-- ============================================================
-- watchers
-- ============================================================

task.spawn(function()
    local ok, lbl = pcall(function()
        return player.PlayerGui
            :WaitForChild("MainGUI")
            :WaitForChild("Game")
            :WaitForChild("AssassinTarget")
            :WaitForChild("TargetName")
    end)
    if not ok or not lbl then return end
    targetLabel = lbl

    local cur = getTargetName()
    if cur and not isIgnored(cur) then onTargetChanged(cur) end

    targetLabel:GetPropertyChangedSignal("Text"):Connect(function()
        local newTarget = targetLabel.Text
        if not isIgnored(newTarget) then
            onTargetChanged(newTarget)
        end
    end)
end)

task.spawn(function()
    local function watchChar(char)
        if not char then return end
        char.ChildAdded:Connect(function(item)
            if item.Name == "Knife" then onKnifeDetected() end
        end)
    end

    local bp = player:WaitForChild("Backpack")
    bp.ChildAdded:Connect(function(item)
        if item.Name == "Knife" then onKnifeDetected() end
    end)

    watchChar(player.Character)
    player.CharacterAdded:Connect(function(char)
        resetRound()
        watchChar(char)
    end)

    local ok, giveWeapon = pcall(function()
        return ReplicatedStorage
            :WaitForChild("Remotes", 10)
            :WaitForChild("Gameplay", 10)
            :WaitForChild("GiveWeapon", 10)
    end)
    if ok and giveWeapon then
        giveWeapon.OnClientEvent:Connect(function(weaponName)
            if weaponName ~= "Knife" then return end
            task.spawn(function()
                local waited = 0
                while waited < 2 do
                    if hasKnife() then onKnifeDetected() return end
                    task.wait(0.02)
                    waited += 0.02
                end
            end)
        end)
    end
end)

task.spawn(function()
    while true do
        task.wait(0.4)
        if autoKillEnabled and not hasKnife() and state ~= STATE.IDLE then
            resetRound()
        end
    end
end)

print("[Assassin Auto] Script Berhasil Dijalankan (Happy gays)")
