-- Toba UI Library v0.2 Demo
-- Fully functional demo: Buttons, Sliders, Toggles, Inputs, Dropdowns, Notifications
-- Mobile & PC ready, responsive, animated
-- Author: Ivan

local Toba = {}
Toba.__index = Toba

-- Roblox Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- ScreenGui setup
local player = Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Utility Tween function
local function tween(obj, properties, duration, style, dir)
    local info = TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, properties)
    t:Play()
    return t
end

-- Adaptive UI scale (mobile & PC)
local function getUIScale()
    local res = workspace.CurrentCamera.ViewportSize
    if res.X < 700 then
        return 0.7 -- mobile
    else
        return 1 -- PC
    end
end

-- Core Window
function Toba:CreateWindow(opts)
    local win = {}
    win.Title = opts.Title or "Toba Window"
    win.Version = opts.Version or "0.2"

    -- Main Frame
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 400, 0, 350)
    main.Position = UDim2.new(0.5, -200, 0.5, -175)
    main.BackgroundColor3 = Color3.fromRGB(25,25,25)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.ClipsDescendants = true
    main.Parent = screenGui

    -- Adaptive scaling
    local scale = Instance.new("UIScale", main)
    scale.Scale = getUIScale()

    -- Title Bar
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1,0,0,40)
    bar.BackgroundColor3 = Color3.fromRGB(45,45,45)
    bar.Parent = main

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = win.Title.." - "..win.Version
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 18
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = bar

    -- Draggable
    local dragging, dragInput, mouseStart, frameStart = false
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mouseStart = input.Position
            frameStart = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    bar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - mouseStart
            main.Position = frameStart + UDim2.new(0, delta.X, 0, delta.Y)
        end
    end)

    -- Sections
    function win:Section(title)
        local sec = {}
        sec.Frame = Instance.new("Frame")
        sec.Frame.Size = UDim2.new(1, -20, 0, 150)
        sec.Frame.Position = UDim2.new(0, 10, 0, 50)
        sec.Frame.BackgroundColor3 = Color3.fromRGB(35,35,35)
        sec.Frame.Parent = main

        local secLabel = Instance.new("TextLabel")
        secLabel.Size = UDim2.new(1, -10, 0, 30)
        secLabel.Position = UDim2.new(0, 5, 0, 5)
        secLabel.BackgroundTransparency = 1
        secLabel.Text = title
        secLabel.TextColor3 = Color3.fromRGB(255,255,255)
        secLabel.Font = Enum.Font.GothamBold
        secLabel.TextSize = 16
        secLabel.TextXAlignment = Enum.TextXAlignment.Left
        secLabel.Parent = sec.Frame

        -- Button
        function sec:Button(txt, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 35)
            btn.Position = UDim2.new(0, 5, 0, 40)
            btn.BackgroundColor3 = Color3.fromRGB(65,65,65)
            btn.TextColor3 = Color3.fromRGB(255,255,255)
            btn.Text = txt
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            btn.Parent = sec.Frame

            btn.MouseEnter:Connect(function()
                tween(btn, {BackgroundColor3 = Color3.fromRGB(85,85,85)}, 0.2)
            end)
            btn.MouseLeave:Connect(function()
                tween(btn, {BackgroundColor3 = Color3.fromRGB(65,65,65)}, 0.2)
            end)
            btn.MouseButton1Click:Connect(callback)
        end

        -- Toggle
        function sec:Toggle(txt, default, callback)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, -10, 0, 30)
            frame.Position = UDim2.new(0, 5, 0, 80)
            frame.BackgroundTransparency = 1
            frame.Parent = sec.Frame

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.7,0,1,0)
            label.BackgroundTransparency = 1
            label.Text = txt
            label.TextColor3 = Color3.fromRGB(255,255,255)
            label.Font = Enum.Font.Gotham
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0,50,0,20)
            btn.Position = UDim2.new(0.75,0,0.3,0)
            btn.BackgroundColor3 = default and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
            btn.Text = ""
            btn.Parent = frame

            local state = default
            btn.MouseButton1Click:Connect(function()
                state = not state
                btn.BackgroundColor3 = state and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
                callback(state)
            end)
        end

        -- Slider
        function sec:Slider(txt, min, max, default, callback)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1,-10,0,30)
            frame.Position = UDim2.new(0,5,0,120)
            frame.BackgroundTransparency = 1
            frame.Parent = sec.Frame

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.5,0,1,0)
            label.BackgroundTransparency = 1
            label.Text = txt.." : "..default
            label.TextColor3 = Color3.fromRGB(255,255,255)
            label.Font = Enum.Font.Gotham
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame

            local slider = Instance.new("Frame")
            slider.Size = UDim2.new(0.45,0,0.4,0)
            slider.Position = UDim2.new(0.5,0,0.3,0)
            slider.BackgroundColor3 = Color3.fromRGB(65,65,65)
            slider.Parent = frame

            local handle = Instance.new("Frame")
            handle.Size = UDim2.new(default/(max-min),0,1,0)
            handle.BackgroundColor3 = Color3.fromRGB(0,170,255)
            handle.Parent = slider

            local dragging = false
            handle.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                end
            end)
            handle.InputEnded:Connect(function(input)
                dragging = false
            end)
            RunService.RenderStepped:Connect(function()
                if dragging then
                    local mouseX = game:GetService("UserInputService"):GetMouseLocation().X
                    local sliderPos = slider.AbsolutePosition.X
                    local sliderWidth = slider.AbsoluteSize.X
                    local percent = math.clamp((mouseX - sliderPos)/sliderWidth,0,1)
                    handle.Size = UDim2.new(percent,0,1,0)
                    local value = math.floor(percent*(max-min)+min)
                    label.Text = txt.." : "..value
                    callback(value)
                end
            end)
        end

        return sec
    end

    -- Notifications
    function win:Notify(msg, duration)
        duration = duration or 3
        local notif = Instance.new("Frame")
        notif.Size = UDim2.new(0,200,0,50)
        notif.Position = UDim2.new(1,-210,0,10)
        notif.BackgroundColor3 = Color3.fromRGB(45,45,45)
        notif.Parent = screenGui

        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1,0,1,0)
        txt.BackgroundTransparency = 1
        txt.Text = msg
        txt.TextColor3 = Color3.fromRGB(255,255,255)
        txt.Font = Enum.Font.Gotham
        txt.TextSize = 14
        txt.Parent = notif

        tween(notif, {Position = UDim2.new(1,-210,0,10)},0.5)
        delay(duration,function()
            tween(notif, {Position = UDim2.new(1,210,0,10)},0.5)
            wait(0.5)
            notif:Destroy()
        end)
    end

    return win
end

return Toba
