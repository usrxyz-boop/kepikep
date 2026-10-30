local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

while not Players.LocalPlayer do task.wait() end
local player = Players.LocalPlayer

local autoKillEnabled = true
local ignoredNames = {
    ["alamak942"] = true,
    ["ets_gakenaaaaaaaaaaa"] = true
}

local activeKillName = nil
local targetLabel = nil
local roundId = 0
local roundStarted = false
local killThreadActive = false

-- Diaktifkan untuk melihat pesan error/proses di F9 Console
local DEBUG = true

local function log(...)
    if DEBUG then print("[Assassin Auto]", ...) end
end

local STATE = { IDLE = "IDLE", KILLING = "KILLING", FINAL = "FINAL" }
local state = STATE.IDLE

local function resetRound(killSelf)
    roundStarted = false
    state = STATE.IDLE
    activeKillName = nil
    killThreadActive = false
    log("Round Reset")
    if killSelf then
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            hum.Health = 0
        end
    end
end

-- ============================================================
-- Helpers
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

local function hasKnife()
    return getKnife() ~= nil
end

-- Memastikan pisau di-equip ke tangan
local function equipKnife()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local bp = player:FindFirstChild("Backpack")
    if bp and hum then
        local k = bp:FindFirstChild("Knife")
        if k then
            hum:EquipTool(k)
            log("Knife equipped!")
        end
    end
end

local function getKillPart(char)
    if not char then return nil end
    return char:FindFirstChild("UpperTorso") 
        or char:FindFirstChild("Torso") 
        or char:FindFirstChild("HumanoidRootPart") 
        or char:FindFirstChild("Head")
end

local function getTargetName()
    if not targetLabel then return nil end
    local text = targetLabel.Text
    if not text or text == "" then return nil end
    
    -- Membersihkan awalan teks jika UI memakai format "Target: PlayerName"
    text = string.gsub(text, "^Target:%s*", "")
    text = string.gsub(text, "^Target%s*", "")
    
    if text ~= "" and text ~= "Nikilis" and text ~= "None" then
        return text
    end
    return nil
end

local function rawFire(name)
    if not name or isIgnored(name) then return end
    
    local knife = getKnife()
    if not knife then 
        log("rawFire gagal: Knife tidak ditemukan")
        return 
    end
    
    local events = knife:FindFirstChild("Events")
    if not events then 
        log("rawFire gagal: Folder Events tidak ditemukan di Knife")
        return 
    end
    
    local ht = events:FindFirstChild("HandleTouched")
    if not ht then 
        log("rawFire gagal: Remote HandleTouched tidak ditemukan")
        return 
    end
    
    local p = Players:FindFirstChild(name)
    if not p or not p.Character then 
        log("rawFire gagal: Player " .. tostring(name) .. " tidak ada di server/karakter belum load")
        return 
    end
    
    local part = getKillPart(p.Character)
    if not part then 
        log("rawFire gagal: Body part target tidak ditemukan")
        return 
    end
    
    log("Firing HandleTouched -> Target:", name, "| Part:", part.Name)
    ht:FireServer(part)
end

-- ============================================================
-- Kill Logic
-- ============================================================
local function rapidKill(name, myRoundId)
    if isIgnored(name) then return end
    
    killThreadActive = true
    activeKillName = name
    log("rapidKill dimulai untuk target:", name)

    task.spawn(function()
        while autoKillEnabled and hasKnife() do
            if myRoundId ~= roundId or state == STATE.IDLE then 
                log("Loop dibatalkan: Round ID atau State berubah")
                break 
            end
            
            equipKnife()
            
            local cur = getTargetName()
            if cur and cur ~= name then 
                log("Target berganti dari", name, "ke", cur)
                break 
            end
            
            local p = Players:FindFirstChild(name)
            if not p or not p.Character then break end
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then 
                log("Target mati atau tidak memiliki Humanoid")
                break 
            end
            
            rawFire(name)
            task.wait(0.05)
        end
        
        killThreadActive = false
        if activeKillName == name then
            activeKillName = nil
        end
        log("rapidKill selesai untuk target:", name)
    end)
end

local function attemptKill(name, source)
    if not autoKillEnabled then return end
    if not name or name == "" then 
        log("attemptKill dibatalkan: Nama target kosong")
        return 
    end
    if isIgnored(name) then 
        log("attemptKill dibatalkan: Target di-ignore (" .. name .. ")")
        return 
    end
    if not hasKnife() then 
        log("attemptKill dibatalkan: Karakter tidak punya Knife")
        return 
    end
    
    equipKnife()
    
    if state == STATE.IDLE then 
        state = STATE.KILLING 
    end
    
    log("attemptKill dipanggil dari source:", source, "| Target:", name)
    rawFire(name)
    rapidKill(name, roundId)
end

local function startRound()
    roundStarted = true
    roundId += 1
    activeKillName = nil
    killThreadActive = false
    state = STATE.KILLING
    log("Round Baru Dimulai ID:", roundId)
end

local function onKnifeDetected()
    if not autoKillEnabled then return end
    startRound()
    local target = getTargetName()
    if target then
        attemptKill(target, "knifeDetected")
    else
        log("Knife terdeteksi tetapi nama target belum didapat dari UI")
    end
end

local function onTargetChanged(name)
    if not autoKillEnabled or isIgnored(name) or not hasKnife() then return end
    attemptKill(name, "targetChanged")
end

-- ============================================================
-- Watchers
-- ============================================================

-- Watch Target UI
task.spawn(function()
    while true do
        local ok, lbl = pcall(function()
            return player:WaitForChild("PlayerGui")
                :WaitForChild("MainGUI")
                :WaitForChild("Game")
                :WaitForChild("AssassinTarget")
                :WaitForChild("TargetName")
        end)
        
        if ok and lbl then
            targetLabel = lbl
            log("Target UI Berhasil Ditemukan!")
            
            local cur = getTargetName()
            if cur and not isIgnored(cur) then 
                onTargetChanged(cur) 
            end
            
            local conn
            conn = targetLabel:GetPropertyChangedSignal("Text"):Connect(function()
                if not targetLabel or not targetLabel.Parent then
                    conn:Disconnect()
                    return
                end
                local newTarget = getTargetName()
                log("Teks Target UI Berubah:", newTarget)
                if newTarget and not isIgnored(newTarget) then
                    onTargetChanged(newTarget)
                end
            end)
            
            targetLabel.AncestryChanged:Wait()
        else
            log("Gagal menemukan Target UI, mencoba lagi...")
        end
        task.wait(1)
    end
end)

-- Watch Backpack & Character
task.spawn(function()
    local function watchChar(char)
        if not char then return end
        char.ChildAdded:Connect(function(item)
            if item.Name == "Knife" then
                log("Knife ditambahkan ke Character")
                onKnifeDetected()
            end
        end)
    end

    player.CharacterAdded:Connect(function(char)
        resetRound()
        watchChar(char)
    end)
    
    if player.Character then
        watchChar(player.Character)
    end

    local bp = player:WaitForChild("Backpack")
    bp.ChildAdded:Connect(function(item)
        if item.Name == "Knife" then
            log("Knife ditambahkan ke Backpack")
            onKnifeDetected()
        end
    end)
end)

-- Auto Reset saat Knife hilang
task.spawn(function()
    while true do
        task.wait(0.4)
        if autoKillEnabled and not hasKnife() and state ~= STATE.IDLE then
            resetRound()
        end
    end
end)

print("[Assassin Auto] Happy farm gays.")
