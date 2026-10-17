-- Funky Friday Auto-Play UI Prototype
-- Single-file Lua prototype for authorized testing.
-- This is a standalone timing simulation: it does NOT read or press notes
-- in the live Funky Friday game.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("FFAutoPlayPrototype")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "FFAutoPlayPrototype"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(320, 300)
frame.Position = UDim2.new(0.5, -160, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 36)
title.Position = UDim2.fromOffset(10, 4)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "FF Auto-Play Prototype"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Parent = frame

local function makeLabel(text, y, height)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -24, 0, height or 24)
    label.Position = UDim2.fromOffset(12, y)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.fromRGB(225, 225, 235)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    return label
end

local function makeButton(text, y)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -24, 0, 32)
    button.Position = UDim2.fromOffset(12, y)
    button.BackgroundColor3 = Color3.fromRGB(75, 85, 145)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamBold
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 13
    button.Parent = frame
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = button
    return button
end

local running = false
local accuracy = 95
local modeIndex = 2
local modes = {
    {name = "Casual", window = 0.18},
    {name = "Normal", window = 0.10},
    {name = "Perfect", window = 0.035},
}
local hits, misses = 0, 0

local status = makeLabel("Status: stopped (simulation only)", 43, 22)
local accuracyLabel = makeLabel("Accuracy setting: 95%", 70, 22)
local accuracyDown = makeButton("Accuracy - 5%", 96)
local accuracyUp = makeButton("Accuracy + 5%", 134)
local modeButton = makeButton("Timing mode: Normal", 172)
local toggleButton = makeButton("Start Simulation", 210)
local stats = makeLabel("Simulated hits: 0   Misses: 0", 248, 22)
stats.TextSize = 12

local function refresh()
    accuracyLabel.Text = "Accuracy setting: " .. accuracy .. "%"
    modeButton.Text = "Timing mode: " .. modes[modeIndex].name
    toggleButton.Text = running and "Stop Simulation" or "Start Simulation"
    toggleButton.BackgroundColor3 = running
        and Color3.fromRGB(150, 65, 75)
        or Color3.fromRGB(75, 125, 90)
    status.Text = running and "Status: running timing simulation"
        or "Status: stopped (simulation only)"
    stats.Text = "Simulated hits: " .. hits .. "   Misses: " .. misses
end

accuracyDown.MouseButton1Click:Connect(function()
    accuracy = math.max(50, accuracy - 5)
    refresh()
end)

accuracyUp.MouseButton1Click:Connect(function()
    accuracy = math.min(100, accuracy + 5)
    refresh()
end)

modeButton.MouseButton1Click:Connect(function()
    modeIndex = (modeIndex % #modes) + 1
    refresh()
end)

toggleButton.MouseButton1Click:Connect(function()
    running = not running
    refresh()
end)

-- Demo-only simulated note timing; no game notes or inputs are accessed.
task.spawn(function()
    while gui.Parent do
        task.wait(1)
        if running then
            local chance = accuracy / 100
            if math.random() <= chance then
                hits += 1
            else
                misses += 1
            end
            refresh()
        end
    end
end)

-- Drag the window using its title bar.
local dragging, dragStart, startPos
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

title.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

refresh()
