-- ============================================================
-- SERVICES
-- ============================================================
local Players         = game:GetService("Players")
local Workspace       = game:GetService("Workspace")
local RunService      = game:GetService("RunService")
local VIM             = game:GetService("VirtualInputManager")
local GuiService      = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")

local LP      = Players.LocalPlayer
local running = true

-- ============================================================
-- 1) AUTO COLLECT COIN
-- ============================================================
coroutine.wrap(function()
    while running do
        local character = LP.Character
        local rootPart  = character and character:FindFirstChild("HumanoidRootPart")

        if rootPart then
            local rootPos = rootPart.Position

            for _, map in ipairs(Workspace:GetChildren()) do
                local coinContainer = map:FindFirstChild("CoinContainer")
                if coinContainer then
                    for _, descendant in ipairs(coinContainer:GetDescendants()) do
                        if descendant:IsA("BasePart") then
                            local touchInterest = descendant:FindFirstChild("TouchInterest")
                            if touchInterest then
                                local dist = (rootPos - descendant.Position).Magnitude
                                if dist <= 8 then
                                    firetouchinterest(rootPart, descendant, 0)
                                    firetouchinterest(rootPart, descendant, 1)
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)()

-- ============================================================
-- 2) AUTO JOIN
-- ============================================================
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

-- ============================================================
-- 3) BLACK SCREEN / DISABLE 3D RENDER
-- ============================================================
local blackScreenGui

local function CreateBlackScreen()
    if blackScreenGui and blackScreenGui.Parent then return end
    blackScreenGui = Instance.new("ScreenGui")
    blackScreenGui.Name          = "NoRenderBackground"
    blackScreenGui.DisplayOrder  = -99999
    blackScreenGui.IgnoreGuiInset = true
    blackScreenGui.ResetOnSpawn  = false

    local f = Instance.new("Frame")
    f.Size             = UDim2.new(1, 0, 1, 0)
    f.BackgroundColor3 = Color3.new(0, 0, 0)
    f.BorderSizePixel  = 0
    f.Parent           = blackScreenGui

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

-- ============================================================
-- 4) AUTO REJOIN (deteksi error → teleport ulang)
-- ============================================================
local function onErrorMessageChanged(errorMessage)
    if errorMessage and errorMessage ~= "" then
        print("Error detected: " .. errorMessage)
        if LP then
            task.wait()
            pcall(function()
                TeleportService:Teleport(game.PlaceId, LP)
            end)
        end
    end
end

GuiService.ErrorMessageChanged:Connect(onErrorMessageChanged)
