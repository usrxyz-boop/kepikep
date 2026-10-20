local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MM2FarmGUI"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 10
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 280, 0, 360)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -180)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BackgroundTransparency = 0
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 16)
uiCorner.Parent = mainFrame

local glow = Instance.new("Frame")
glow.Size = UDim2.new(1.04, 0, 1.04, 0)
glow.Position = UDim2.new(-0.02, 0, -0.02, 0)
glow.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
glow.BackgroundTransparency = 0.6
glow.BorderSizePixel = 0
glow.Parent = mainFrame

local glowCorner = Instance.new("UICorner")
glowCorner.CornerRadius = UDim.new(0, 18)
glowCorner.Parent = glow

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 42)
topBar.BackgroundColor3 = Color3.fromRGB(180, 20, 20)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 16)
topCorner.Parent = topBar

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 30, 30)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(160, 15, 15)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 10, 10))
})
gradient.Parent = topBar

local umbrella = Instance.new("ImageLabel")
umbrella.Size = UDim2.new(0, 32, 0, 32)
umbrella.Position = UDim2.new(0, 12, 0.5, -16)
umbrella.BackgroundTransparency = 1
umbrella.Image = "rbxassetid:6031097223"
umbrella.Parent = topBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.5, 0, 1, 0)
title.Position = UDim2.new(0, 52, 0, 0)
title.BackgroundTransparency = 1
title.Text = "MM2 Farm"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.TextStrokeColor3 = Color3.fromRGB(80, 0, 0)
title.TextStrokeTransparency = 0.5
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -73, 0.5, -15)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.new(1,1,1)
minimizeBtn.TextScaled = true
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.Parent = topBar

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 10)
minimizeCorner.Parent = minimizeBtn

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -38, 0.5, -15)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = topBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 10)
closeCorner.Parent = closeBtn

-- ============ NORENDER BLACKSCREEN ============
local noRenderGui = Instance.new("ScreenGui")
noRenderGui.Name = "NoRenderBlack"
noRenderGui.DisplayOrder = 5
noRenderGui.IgnoreGuiInset = true
noRenderGui.ResetOnSpawn = false
noRenderGui.Enabled = false
noRenderGui.Parent = playerGui

local blackFrame = Instance.new("Frame")
blackFrame.Size = UDim2.new(1, 0, 1, 0)
blackFrame.BackgroundColor3 = Color3.new(0, 0, 0)
blackFrame.BorderSizePixel = 0
blackFrame.Active = true
blackFrame.Parent = noRenderGui

local blackText = Instance.new("TextLabel")
blackText.Size = UDim2.new(1, 0, 0, 24)
blackText.Position = UDim2.new(0, 0, 1, -40)
blackText.BackgroundTransparency = 1
blackText.Text = "NORENDER MODE ACTIVE"
blackText.TextColor3 = Color3.fromRGB(70, 70, 70)
blackText.TextScaled = true
blackText.Font = Enum.Font.GothamBold
blackText.Parent = blackFrame
-- ==============================================

local contentContainer = Instance.new("Frame")
contentContainer.Name = "ContentContainer"
contentContainer.Size = UDim2.new(1, 0, 1, -42)
contentContainer.Position = UDim2.new(0, 0, 0, 42)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainFrame

local line = Instance.new("Frame")
line.Size = UDim2.new(0.9, 0, 0, 2)
line.Position = UDim2.new(0.05, 0, 0, 8)
line.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
line.BackgroundTransparency = 0.3
line.BorderSizePixel = 0
line.Parent = contentContainer

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 26)
statusLabel.Position = UDim2.new(0.05, 0, 0, 18)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "● Status: Ready!"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.GothamSemibold
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = contentContainer

local startButton = Instance.new("TextButton")
startButton.Size = UDim2.new(0.9, 0, 0, 44)
startButton.Position = UDim2.new(0.05, 0, 0, 52)
startButton.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
startButton.Text = "▶ START"
startButton.TextColor3 = Color3.new(1, 1, 1)
startButton.TextScaled = true
startButton.Font = Enum.Font.GothamBold
startButton.Parent = contentContainer

local startCorner = Instance.new("UICorner")
startCorner.CornerRadius = UDim.new(0, 12)
startCorner.Parent = startButton

local btnGradient = Instance.new("UIGradient")
btnGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 40, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 20, 20))
})
btnGradient.Parent = startButton

-- ============ NORENDER TOGGLE ============
local noRenderBtn = Instance.new("TextButton")
noRenderBtn.Size = UDim2.new(0.9, 0, 0, 34)
noRenderBtn.Position = UDim2.new(0.05, 0, 0, 108)
noRenderBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
noRenderBtn.Text = "🌑 Norender: OFF"
noRenderBtn.TextColor3 = Color3.new(1,1,1)
noRenderBtn.TextScaled = true
noRenderBtn.Font = Enum.Font.GothamSemibold
noRenderBtn.Parent = contentContainer

local nrCorner = Instance.new("UICorner")
nrCorner.CornerRadius = UDim.new(0, 10)
nrCorner.Parent = noRenderBtn

-- ============ AUTO RESET TOGGLE ============
local autoResetBtn = Instance.new("TextButton")
autoResetBtn.Size = UDim2.new(0.9, 0, 0, 34)
autoResetBtn.Position = UDim2.new(0.05, 0, 0, 150)
autoResetBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
autoResetBtn.Text = "🔄 Auto Reset: OFF"
autoResetBtn.TextColor3 = Color3.new(1,1,1)
autoResetBtn.TextScaled = true
autoResetBtn.Font = Enum.Font.GothamSemibold
autoResetBtn.Parent = contentContainer

local arCorner = Instance.new("UICorner")
arCorner.CornerRadius = UDim.new(0, 10)
arCorner.Parent = autoResetBtn

local intervalLabel = Instance.new("TextLabel")
intervalLabel.Size = UDim2.new(0.5, 0, 0, 26)
intervalLabel.Position = UDim2.new(0.05, 0, 0, 194)
intervalLabel.BackgroundTransparency = 1
intervalLabel.Text = "⏱ Interval (s):"
intervalLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
intervalLabel.TextScaled = true
intervalLabel.Font = Enum.Font.Gotham
intervalLabel.TextXAlignment = Enum.TextXAlignment.Left
intervalLabel.Parent = contentContainer

local intervalBox = Instance.new("TextBox")
intervalBox.Size = UDim2.new(0.35, 0, 0, 26)
intervalBox.Position = UDim2.new(0.6, 0, 0, 194)
intervalBox.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
intervalBox.Text = "60"
intervalBox.TextColor3 = Color3.new(1,1,1)
intervalBox.Font = Enum.Font.Gotham
intervalBox.TextSize = 16
intervalBox.Parent = contentContainer

local ibCorner = Instance.new("UICorner")
ibCorner.CornerRadius = UDim.new(0, 8)
ibCorner.Parent = intervalBox

local creditLabel = Instance.new("TextLabel")
creditLabel.Size = UDim2.new(1, 0, 0, 14)
creditLabel.Position = UDim2.new(0, 0, 1, -18)
creditLabel.BackgroundTransparency = 1
creditLabel.Text = "discord.gg/K92JgMUnCG"
creditLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
creditLabel.TextScaled = true
creditLabel.Font = Enum.Font.GothamSemibold
creditLabel.TextTransparency = 0.3
creditLabel.Parent = contentContainer

-- ============ STATE & SERVICES ============
local TweenService = game:GetService("TweenService")
local LP = game.Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local HRP = Char:WaitForChild("HumanoidRootPart")
local Humanoid = Char:WaitForChild("Humanoid")

local isFarming = false
local farmingConnection = nil
local isMinimized = false
local dragging = false
local dragStart, startPos
local noRenderEnabled = false
local autoResetEnabled = false
local resetInterval = 60
local wasFarmingBeforeDeath = false
local autoResetLoopRunning = false

-- ============ RESET CHARACTER FUNCTION ============
local function resetCharacter()
    if Humanoid and Humanoid.Health > 0 then
        if isFarming then
            wasFarmingBeforeDeath = true
        end
        Humanoid.Health = 0
    end
end

-- ============ HOVER EFFECTS ============
minimizeBtn.MouseEnter:Connect(function()
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(230, 180, 0)
end)
minimizeBtn.MouseLeave:Connect(function()
    if not isMinimized then
        minimizeBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
    else
        minimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    end
end)

closeBtn.MouseEnter:Connect(function()
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
end)
closeBtn.MouseLeave:Connect(function()
    closeBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
end)

startButton.MouseEnter:Connect(function()
    startButton.BackgroundColor3 = Color3.fromRGB(230, 50, 50)
end)
startButton.MouseLeave:Connect(function()
    if isFarming then
        startButton.BackgroundColor3 = Color3.fromRGB(180, 20, 20)
    else
        startButton.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
    end
end)

noRenderBtn.MouseEnter:Connect(function()
    if not noRenderEnabled then noRenderBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 105) end
end)
noRenderBtn.MouseLeave:Connect(function()
    if not noRenderEnabled then noRenderBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80) end
end)

autoResetBtn.MouseEnter:Connect(function()
    if not autoResetEnabled then autoResetBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 105) end
end)
autoResetBtn.MouseLeave:Connect(function()
    if not autoResetEnabled then autoResetBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80) end
end)

-- ============ DRAG ============
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position

        if not isMinimized then
            mainFrame:TweenSize(UDim2.new(0, 275, 0, 355), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
        end

        local connection
        connection = game:GetService("UserInputService").InputChanged:Connect(function(input2)
            if dragging and (input2.UserInputType == Enum.UserInputType.MouseMovement or input2.UserInputType == Enum.UserInputType.Touch) then
                local delta = input2.Position - dragStart
                mainFrame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                connection:Disconnect()
                if not isMinimized then
                    mainFrame:TweenSize(UDim2.new(0, 280, 0, 360), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
                end
            end
        end)
    end
end)

-- ============ FARM LOGIC ============
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
    if not Humanoid or not Humanoid.Parent or Humanoid.Health <= 0 then return end
    pcall(function() Humanoid:ChangeState(11) end)
    local d = (HRP.Position - hp.Position).Magnitude
    local t = TweenService:Create(HRP, TweenInfo.new(d / 25, Enum.EasingStyle.Linear), {CFrame = hp.CFrame})
    t:Play()
    t.Completed:Wait()
end

local function startFarming()
    if farmingConnection then return end

    farmingConnection = task.spawn(function()
        while isFarming do
            local ok = pcall(function()
                local target = getNearest()
                if target and LP:GetAttribute("Alive") and Humanoid and Humanoid.Health > 0 then
                    tp(target)
                    local v = target:FindFirstChild("CoinVisual")
                    while v and not v:GetAttribute("Collected") and v.Parent and isFarming do
                        if not LP:GetAttribute("Alive") or not Humanoid or Humanoid.Health <= 0 then break end
                        local n = getNearest()
                        if n and n ~= target then break end
                        task.wait()
                    end
                else
                    task.wait(0.5)
                end
            end)
            if not ok then task.wait(0.5) end
        end
    end)
end

local function stopFarming()
    isFarming = false
    if farmingConnection then
        farmingConnection = nil
    end
end

local function setStatus(text, color)
    statusLabel.Text = text
    statusLabel.TextColor3 = color
    TweenService:Create(statusLabel, TweenInfo.new(0.3), {TextColor3 = color}):Play()
end

local function toggleFarming()
    isFarming = not isFarming

    if isFarming then
        startButton.Text = "⏹ STOP"
        startButton.BackgroundColor3 = Color3.fromRGB(180, 20, 20)
        setStatus("● Status: Farming...", Color3.fromRGB(100, 255, 100))
        startFarming()
        print("MM2 Farm Started!")
    else
        startButton.Text = "▶ START"
        startButton.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
        setStatus("● Status: Stopped", Color3.fromRGB(200, 200, 200))
        stopFarming()
        print("MM2 Farm Stopped!")
    end
end

-- ============ NORENDER ============
local UserGameSettings, originalQuality
pcall(function()
    UserGameSettings = UserSettings():GetService("UserGameSettings")
    originalQuality = UserGameSettings.SavedQualityLevel
end)

local function setNoRender(on)
    noRenderEnabled = on
    noRenderGui.Enabled = on
    if on then
        noRenderBtn.Text = "🌑 Norender: ON"
        noRenderBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
        pcall(function()
            if UserGameSettings then
                UserGameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
            end
        end)
    else
        noRenderBtn.Text = "🌑 Norender: OFF"
        noRenderBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        pcall(function()
            if UserGameSettings and originalQuality then
                UserGameSettings.SavedQualityLevel = originalQuality
            end
        end)
    end
end

-- ============ DEATH / RESPAWN HANDLER ============
local function handleDeath()
    if isFarming then
        wasFarmingBeforeDeath = true
    end
    stopFarming()
    isFarming = false
    startButton.Text = "▶ START"
    startButton.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
    setStatus("● Status: Respawning...", Color3.fromRGB(255, 200, 100))
end

local function handleRespawn(char)
    Char = char
    HRP = char:WaitForChild("HumanoidRootPart")
    Humanoid = char:WaitForChild("Humanoid")

    Humanoid.Died:Connect(handleDeath)

    if wasFarmingBeforeDeath then
        wasFarmingBeforeDeath = false
        task.wait(1.5)
        if not isFarming then
            isFarming = true
            startButton.Text = "⏹ STOP"
            startButton.BackgroundColor3 = Color3.fromRGB(180, 20, 20)
            setStatus("● Status: Farming...", Color3.fromRGB(100, 255, 100))
            startFarming()
        end
    else
        setStatus("● Status: Ready!", Color3.fromRGB(200, 200, 200))
    end
end

-- ============ AUTO RESET LOOP (TIMER) ============
local function startAutoResetLoop()
    if autoResetLoopRunning then return end
    autoResetLoopRunning = true
    task.spawn(function()
        while autoResetEnabled do
            task.wait(resetInterval)
            if not autoResetEnabled then break end
            if isFarming and Humanoid and Humanoid.Parent and Humanoid.Health > 0 then
                resetCharacter()
                local t = 0
                while (not isFarming) and autoResetEnabled and t < 60 do
                    task.wait(1)
                    t = t + 1
                end
            end
        end
        autoResetLoopRunning = false
    end)
end

-- ============ AUTO RESET WHEN COIN FULL ============
task.spawn(function()
    pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
        if not remotes then return end
        
        local gameplay = remotes:WaitForChild("Gameplay", 10)
        if not gameplay then return end
        
        local CoinCollected = gameplay:WaitForChild("CoinCollected", 10)
        if not CoinCollected then return end

        CoinCollected.OnClientEvent:Connect(function(_, currentCoins, maxCoins)
            if typeof(currentCoins) == "number" and typeof(maxCoins) == "number" then
                if currentCoins >= maxCoins and maxCoins > 0 then
                    resetCharacter()
                end
            end
        end)
    end)
end)

-- ============ BUTTON CONNECTIONS ============
noRenderBtn.MouseButton1Click:Connect(function()
    setNoRender(not noRenderEnabled)
end)

autoResetBtn.MouseButton1Click:Connect(function()
    autoResetEnabled = not autoResetEnabled
    if autoResetEnabled then
        autoResetBtn.Text = "🔄 Auto Reset: ON"
        autoResetBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 80)
        startAutoResetLoop()
    else
        autoResetBtn.Text = "🔄 Auto Reset: OFF"
        autoResetBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    end
end)

intervalBox.FocusLost:Connect(function()
    local n = tonumber(intervalBox.Text)
    if n and n >= 5 then
        resetInterval = math.floor(n)
    end
    intervalBox.Text = tostring(resetInterval)
end)

startButton.MouseButton1Click:Connect(toggleFarming)

-- ============ MINIMIZE ============
local function toggleMinimize()
    isMinimized = not isMinimized

    if isMinimized then
        mainFrame:TweenSize(UDim2.new(0, 200, 0, 42), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
        minimizeBtn.Text = "+"
        minimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        minimizeBtn.TextSize = 24
        contentContainer.Visible = false
        umbrella.Visible = false
        glow.Size = UDim2.new(1.08, 0, 1.12, 0)
        glow.Position = UDim2.new(-0.04, 0, -0.06, 0)
        title.Text = "KEVIN"
        title.Position = UDim2.new(0, 12, 0, 0)
        title.Size = UDim2.new(0.8, 0, 1, 0)
        topCorner.CornerRadius = UDim.new(0, 20)
    else
        mainFrame:TweenSize(UDim2.new(0, 280, 0, 360), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
        minimizeBtn.Text = "−"
        minimizeBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
        minimizeBtn.TextSize = 18
        contentContainer.Visible = true
        umbrella.Visible = true
        glow.Size = UDim2.new(1.04, 0, 1.04, 0)
        glow.Position = UDim2.new(-0.02, 0, -0.02, 0)
        title.Text = "MM2 Farm"
        title.Position = UDim2.new(0, 52, 0, 0)
        title.Size = UDim2.new(0.5, 0, 1, 0)
        topCorner.CornerRadius = UDim.new(0, 16)
    end
end

minimizeBtn.MouseButton1Click:Connect(toggleMinimize)

closeBtn.MouseButton1Click:Connect(function()
    isFarming = false
    autoResetEnabled = false
    setNoRender(false)
    mainFrame:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.3, true)
    task.wait(0.3)
    stopFarming()
    noRenderGui:Destroy()
    screenGui:Destroy()
end)

-- ============ INIT CHARACTER ============
handleRespawn(Char)
LP.CharacterAdded:Connect(handleRespawn)
