--[[
    TobaUI Library
    Features: Smooth Animations, Notifications, Floating Thumbnail Toggle, Confirmation Dialog, Full Elements
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local ParentGui = (RunService:IsStudio() and game.Players.LocalPlayer:WaitForChild("PlayerGui")) or CoreGui

local Toba = {}
Toba.Theme = {
    Background = Color3.fromRGB(20, 20, 25),
    Sidebar = Color3.fromRGB(25, 25, 30),
    Element = Color3.fromRGB(35, 35, 42),
    Hover = Color3.fromRGB(45, 45, 55),
    Accent = Color3.fromRGB(99, 102, 241), -- Sleek Indigo
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(170, 170, 170),
    Danger = Color3.fromRGB(239, 68, 68)
}

-- Tween Utility
local function Tween(instance, properties, duration)
    local t = TweenService:Create(instance, TweenInfo.new(duration or 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), properties)
    t:Play()
    return t
end

-- Dragging Utility
local function MakeDraggable(dragPart, movePart)
    local dragging, dragInput, dragStart, startPos
    dragPart.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = movePart.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    dragPart.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            movePart.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Resolve Icon (Basic asset id resolver for simplicity, integrate your lucide module here if needed)
local function ResolveIcon(iconStr)
    if not iconStr or iconStr == "" then return "" end
    if iconStr:match("^rbxassetid://") then return iconStr end
    if tonumber(iconStr) then return "rbxassetid://" .. iconStr end
    return iconStr -- Fallback
end

-- Notification System Storage
local NotifContainer = nil

function Toba:CreateNotif(config)
    if not NotifContainer then return end
    
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 280, 0, 70)
    notif.BackgroundColor3 = Toba.Theme.Sidebar
    notif.Position = UDim2.new(1, 300, 0, 0) -- Start off-screen
    notif.Parent = NotifContainer
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)
    
    local UIStroke = Instance.new("UIStroke", notif)
    UIStroke.Color = Toba.Theme.Element
    UIStroke.Thickness = 1

    local Icon = Instance.new("ImageLabel")
    Icon.Size = UDim2.new(0, 24, 0, 24)
    Icon.Position = UDim2.new(0, 15, 0.5, -12)
    Icon.BackgroundTransparency = 1
    Icon.Image = ResolveIcon(config.Icon) or ""
    Icon.ImageColor3 = Toba.Theme.Accent
    Icon.Parent = notif

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -60, 0, 20)
    Title.Position = UDim2.new(0, 50, 0, 12)
    Title.BackgroundTransparency = 1
    Title.Text = config.Title or "Notification"
    Title.TextColor3 = Toba.Theme.Text
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = notif

    local Desc = Instance.new("TextLabel")
    Desc.Size = UDim2.new(1, -60, 0, 20)
    Desc.Position = UDim2.new(0, 50, 0, 32)
    Desc.BackgroundTransparency = 1
    Desc.Text = config.Desc or ""
    Desc.TextColor3 = Toba.Theme.SubText
    Desc.Font = Enum.Font.Gotham
    Desc.TextSize = 12
    Desc.TextWrapped = true
    Desc.TextXAlignment = Enum.TextXAlignment.Left
    Desc.Parent = notif

    -- Animate In
    local duration = config.Duration or 3
    Tween(notif, {Position = UDim2.new(1, 0, 0, 0)})
    
    -- Animate Out
    task.delay(duration, function()
        local t = Tween(notif, {Position = UDim2.new(1, 300, 0, 0), BackgroundTransparency = 1})
        Tween(Title, {TextTransparency = 1})
        Tween(Desc, {TextTransparency = 1})
        Tween(Icon, {ImageTransparency = 1})
        Tween(UIStroke, {Transparency = 1})
        t.Completed:Connect(function() notif:Destroy() end)
    end)
end

function Toba:CreateWindow(config)
    local Window = {}
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TobaUI"
    ScreenGui.Parent = ParentGui
    ScreenGui.DisplayOrder = -1 -- Keeps UI in the back behind core menus
    ScreenGui.ResetOnSpawn = false
    
    -- Setup Global Notification Container
    NotifContainer = Instance.new("Frame")
    NotifContainer.Size = UDim2.new(0, 280, 1, -40)
    NotifContainer.Position = UDim2.new(1, -300, 0, 20)
    NotifContainer.BackgroundTransparency = 1
    NotifContainer.Parent = ScreenGui
    local NotifLayout = Instance.new("UIListLayout", NotifContainer)
    NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifLayout.Padding = UDim.new(0, 10)

    -- Floating Toggle Thumbnail
    local FloatToggle = Instance.new("ImageButton")
    FloatToggle.Size = UDim2.new(0, 50, 0, 50)
    FloatToggle.Position = UDim2.new(0.1, 0, 0.1, 0)
    FloatToggle.BackgroundColor3 = Toba.Theme.Background
    FloatToggle.Image = ResolveIcon(config.Icon) or ""
    FloatToggle.Parent = ScreenGui
    Instance.new("UICorner", FloatToggle).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", FloatToggle).Color = Toba.Theme.Accent
    MakeDraggable(FloatToggle, FloatToggle)

    -- Main UI CanvasGroup (for smooth transparency/size transitions)
    local MainUI = Instance.new("CanvasGroup")
    MainUI.Size = UDim2.new(0, 550, 0, 350)
    MainUI.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainUI.AnchorPoint = Vector2.new(0.5, 0.5)
    MainUI.BackgroundColor3 = Toba.Theme.Background
    MainUI.Parent = ScreenGui
    Instance.new("UICorner", MainUI).CornerRadius = UDim.new(0, 10)

    -- Topbar
    local Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1, 0, 0, 45)
    Topbar.BackgroundTransparency = 1
    Topbar.Parent = MainUI
    MakeDraggable(Topbar, MainUI)

    local TopIcon = Instance.new("ImageLabel")
    TopIcon.Size = UDim2.new(0, 24, 0, 24)
    TopIcon.Position = UDim2.new(0, 15, 0.5, -12)
    TopIcon.BackgroundTransparency = 1
    TopIcon.Image = ResolveIcon(config.Icon) or ""
    TopIcon.Parent = Topbar

    local TitleInfo = Instance.new("TextLabel")
    TitleInfo.Size = UDim2.new(1, -100, 1, 0)
    TitleInfo.Position = UDim2.new(0, 45, 0, 0)
    TitleInfo.BackgroundTransparency = 1
    TitleInfo.RichText = true
    TitleInfo.Text = string.format("<b>%s</b> <font color='rgb(170,170,170)'>v%s | %s</font>", config.Title or "TobaUI", config.Version or "1.0", config.Author or "You")
    TitleInfo.TextColor3 = Toba.Theme.Text
    TitleInfo.Font = Enum.Font.Gotham
    TitleInfo.TextSize = 14
    TitleInfo.TextXAlignment = Enum.TextXAlignment.Left
    TitleInfo.Parent = Topbar

    -- Topbar Controls
    local Controls = Instance.new("Frame")
    Controls.Size = UDim2.new(0, 70, 1, 0)
    Controls.Position = UDim2.new(1, -70, 0, 0)
    Controls.BackgroundTransparency = 1
    Controls.Parent = Topbar

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Position = UDim2.new(0, 0, 0.5, -15)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Toba.Theme.Text
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 18
    MinBtn.Parent = Controls

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(0, 35, 0.5, -15)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Toba.Theme.Danger
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 16
    CloseBtn.Parent = Controls

    -- Confirmation Dialog
    local ConfirmOverlay = Instance.new("CanvasGroup")
    ConfirmOverlay.Size = UDim2.new(1, 0, 1, 0)
    ConfirmOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    ConfirmOverlay.GroupTransparency = 1
    ConfirmOverlay.Visible = false
    ConfirmOverlay.ZIndex = 10
    ConfirmOverlay.Parent = MainUI

    local ConfirmBox = Instance.new("Frame")
    ConfirmBox.Size = UDim2.new(0, 250, 0, 120)
    ConfirmBox.Position = UDim2.new(0.5, 0, 0.5, 0)
    ConfirmBox.AnchorPoint = Vector2.new(0.5, 0.5)
    ConfirmBox.BackgroundColor3 = Toba.Theme.Element
    ConfirmBox.Parent = ConfirmOverlay
    Instance.new("UICorner", ConfirmBox).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", ConfirmBox).Color = Toba.Theme.Sidebar

    local ConfirmText = Instance.new("TextLabel")
    ConfirmText.Size = UDim2.new(1, 0, 0, 60)
    ConfirmText.BackgroundTransparency = 1
    ConfirmText.Text = "Are you sure you want to completely destroy the UI?"
    ConfirmText.TextColor3 = Toba.Theme.Text
    ConfirmText.Font = Enum.Font.GothamBold
    ConfirmText.TextSize = 13
    ConfirmText.TextWrapped = true
    ConfirmText.Parent = ConfirmBox

    local YesBtn = Instance.new("TextButton")
    YesBtn.Size = UDim2.new(0.4, 0, 0, 35)
    YesBtn.Position = UDim2.new(0.06, 0, 0, 70)
    YesBtn.BackgroundColor3 = Toba.Theme.Danger
    YesBtn.Text = "Destroy"
    YesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    YesBtn.Font = Enum.Font.GothamBold
    YesBtn.Parent = ConfirmBox
    Instance.new("UICorner", YesBtn).CornerRadius = UDim.new(0, 6)

    local NoBtn = Instance.new("TextButton")
    NoBtn.Size = UDim2.new(0.4, 0, 0, 35)
    NoBtn.Position = UDim2.new(0.54, 0, 0, 70)
    NoBtn.BackgroundColor3 = Toba.Theme.Sidebar
    NoBtn.Text = "Cancel"
    NoBtn.TextColor3 = Toba.Theme.Text
    NoBtn.Font = Enum.Font.GothamBold
    NoBtn.Parent = ConfirmBox
    Instance.new("UICorner", NoBtn).CornerRadius = UDim.new(0, 6)

    -- Window Controls Logic
    local UIOn = true
    local function ToggleUI()
        UIOn = not UIOn
        if UIOn then
            MainUI.Visible = true
            Tween(MainUI, {GroupTransparency = 0, Size = UDim2.new(0, 550, 0, 350)})
        else
            local t = Tween(MainUI, {GroupTransparency = 1, Size = UDim2.new(0, 500, 0, 300)})
            t.Completed:Connect(function() if not UIOn then MainUI.Visible = false end end)
        end
    end

    FloatToggle.MouseButton1Click:Connect(ToggleUI)
    MinBtn.MouseButton1Click:Connect(ToggleUI)

    CloseBtn.MouseButton1Click:Connect(function()
        ConfirmOverlay.Visible = true
        Tween(ConfirmOverlay, {GroupTransparency = 0.3})
    end)

    NoBtn.MouseButton1Click:Connect(function()
        local t = Tween(ConfirmOverlay, {GroupTransparency = 1})
        t.Completed:Connect(function() ConfirmOverlay.Visible = false end)
    end)

    YesBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- Sidebar & Pages
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 150, 1, -45)
    Sidebar.Position = UDim2.new(0, 0, 0, 45)
    Sidebar.BackgroundColor3 = Toba.Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainUI

    local TabList = Instance.new("UIListLayout", Sidebar)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 5)

    local TabPadding = Instance.new("UIPadding", Sidebar)
    TabPadding.PaddingTop = UDim.new(0, 10)
    TabPadding.PaddingLeft = UDim.new(0, 10)
    TabPadding.PaddingRight = UDim.new(0, 10)

    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -150, 1, -45)
    PageContainer.Position = UDim2.new(0, 150, 0, 45)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = MainUI

    local FirstTab = true

    function Window:CreateTab(tabConfig)
        local Tab = {}
        
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 35)
        TabBtn.BackgroundColor3 = Toba.Theme.Background
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.Parent = Sidebar
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

        local TabIcon = Instance.new("ImageLabel")
        TabIcon.Size = UDim2.new(0, 18, 0, 18)
        TabIcon.Position = UDim2.new(0, 10, 0.5, -9)
        TabIcon.BackgroundTransparency = 1
        TabIcon.Image = ResolveIcon(tabConfig.Icon) or ""
        TabIcon.ImageColor3 = Toba.Theme.SubText
        TabIcon.Parent = TabBtn

        local TabText = Instance.new("TextLabel")
        TabText.Size = UDim2.new(1, -35, 1, 0)
        TabText.Position = UDim2.new(0, 35, 0, 0)
        TabText.BackgroundTransparency = 1
        TabText.Text = tabConfig.Title or "Tab"
        TabText.TextColor3 = Toba.Theme.SubText
        TabText.Font = Enum.Font.GothamBold
        TabText.TextSize = 13
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        TabText.Parent = TabBtn

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Toba.Theme.Accent
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.Visible = false
        Page.Parent = PageContainer

        local PageLayout = Instance.new("UIListLayout", Page)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 8)
        
        local PagePadding = Instance.new("UIPadding", Page)
        PagePadding.PaddingTop = UDim.new(0, 10)
        PagePadding.PaddingLeft = UDim.new(0, 15)
        PagePadding.PaddingRight = UDim.new(0, 15)
        PagePadding.PaddingBottom = UDim.new(0, 10)

        if FirstTab then
            FirstTab = false
            Page.Visible = true
            TabBtn.BackgroundTransparency = 0
            TabText.TextColor3 = Toba.Theme.Text
            TabIcon.ImageColor3 = Toba.Theme.Accent
        end

        TabBtn.MouseButton1Click:Connect(function()
            for _, child in pairs(Sidebar:GetChildren()) do
                if child:IsA("TextButton") then
                    Tween(child, {BackgroundTransparency = 1})
                    Tween(child.TextLabel, {TextColor3 = Toba.Theme.SubText})
                    Tween(child.ImageLabel, {ImageColor3 = Toba.Theme.SubText})
                end
            end
            for _, child in pairs(PageContainer:GetChildren()) do
                if child:IsA("ScrollingFrame") then child.Visible = false end
            end
            Tween(TabBtn, {BackgroundTransparency = 0})
            Tween(TabText, {TextColor3 = Toba.Theme.Text})
            Tween(TabIcon, {ImageColor3 = Toba.Theme.Accent})
            Page.Visible = true
        end)

        -- Page Elements
        function Tab:CreateSection(title)
            local Sec = Instance.new("TextLabel")
            Sec.Size = UDim2.new(1, 0, 0, 25)
            Sec.BackgroundTransparency = 1
            Sec.Text = title
            Sec.TextColor3 = Toba.Theme.Accent
            Sec.Font = Enum.Font.GothamBold
            Sec.TextSize = 14
            Sec.TextXAlignment = Enum.TextXAlignment.Left
            Sec.Parent = Page
        end

        function Tab:CreateButton(config)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 0, 40)
            Btn.BackgroundColor3 = Toba.Theme.Element
            Btn.Text = config.Name or "Button"
            Btn.TextColor3 = Toba.Theme.Text
            Btn.Font = Enum.Font.GothamBold
            Btn.TextSize = 13
            Btn.Parent = Page
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

            Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = Toba.Theme.Hover}) end)
            Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = Toba.Theme.Element}) end)
            Btn.MouseButton1Click:Connect(function()
                Tween(Btn, {BackgroundColor3 = Toba.Theme.Accent}, 0.1).Completed:Connect(function()
                    Tween(Btn, {BackgroundColor3 = Toba.Theme.Hover}, 0.1)
                end)
                if config.Callback then config.Callback() end
            end)
        end

        function Tab:CreateToggle(config)
            local State = config.Default or false
            local Tgl = Instance.new("TextButton")
            Tgl.Size = UDim2.new(1, 0, 0, 40)
            Tgl.BackgroundColor3 = Toba.Theme.Element
            Tgl.Text = ""
            Tgl.Parent = Page
            Instance.new("UICorner", Tgl).CornerRadius = UDim.new(0, 6)

            local TglText = Instance.new("TextLabel")
            TglText.Size = UDim2.new(1, -60, 1, 0)
            TglText.Position = UDim2.new(0, 15, 0, 0)
            TglText.BackgroundTransparency = 1
            TglText.Text = config.Name or "Toggle"
            TglText.TextColor3 = Toba.Theme.Text
            TglText.Font = Enum.Font.GothamBold
            TglText.TextSize = 13
            TglText.TextXAlignment = Enum.TextXAlignment.Left
            TglText.Parent = Tgl

            local SwitchBG = Instance.new("Frame")
            SwitchBG.Size = UDim2.new(0, 36, 0, 20)
            SwitchBG.Position = UDim2.new(1, -50, 0.5, -10)
            SwitchBG.BackgroundColor3 = State and Toba.Theme.Accent or Toba.Theme.Background
            SwitchBG.Parent = Tgl
            Instance.new("UICorner", SwitchBG).CornerRadius = UDim.new(1, 0)

            local Switch = Instance.new("Frame")
            Switch.Size = UDim2.new(0, 16, 0, 16)
            Switch.Position = State and UDim2.new(0, 18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            Switch.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Switch.Parent = SwitchBG
            Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

            Tgl.MouseButton1Click:Connect(function()
                State = not State
                Tween(SwitchBG, {BackgroundColor3 = State and Toba.Theme.Accent or Toba.Theme.Background})
                Tween(Switch, {Position = State and UDim2.new(0, 18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
                if config.Callback then config.Callback(State) end
            end)
        end

        function Tab:CreateSlider(config)
            local Min, Max, Current = config.Min or 0, config.Max or 100, config.Default or 50
            local Sld = Instance.new("Frame")
            Sld.Size = UDim2.new(1, 0, 0, 55)
            Sld.BackgroundColor3 = Toba.Theme.Element
            Sld.Parent = Page
            Instance.new("UICorner", Sld).CornerRadius = UDim.new(0, 6)

            local SldText = Instance.new("TextLabel")
            SldText.Size = UDim2.new(1, -30, 0, 30)
            SldText.Position = UDim2.new(0, 15, 0, 0)
            SldText.BackgroundTransparency = 1
            SldText.Text = config.Name or "Slider"
            SldText.TextColor3 = Toba.Theme.Text
            SldText.Font = Enum.Font.GothamBold
            SldText.TextSize = 13
            SldText.TextXAlignment = Enum.TextXAlignment.Left
            SldText.Parent = Sld

            local ValText = Instance.new("TextLabel")
            ValText.Size = UDim2.new(1, -30, 0, 30)
            ValText.Position = UDim2.new(0, 15, 0, 0)
            ValText.BackgroundTransparency = 1
            ValText.Text = tostring(Current)
            ValText.TextColor3 = Toba.Theme.SubText
            ValText.Font = Enum.Font.Gotham
            ValText.TextSize = 13
            ValText.TextXAlignment = Enum.TextXAlignment.Right
            ValText.Parent = Sld

            local BarBG = Instance.new("TextButton")
            BarBG.Size = UDim2.new(1, -30, 0, 6)
            BarBG.Position = UDim2.new(0, 15, 0, 35)
            BarBG.BackgroundColor3 = Toba.Theme.Background
            BarBG.Text = ""
            BarBG.Parent = Sld
            Instance.new("UICorner", BarBG).CornerRadius = UDim.new(1, 0)

            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new(math.clamp((Current - Min) / (Max - Min), 0, 1), 0, 1, 0)
            Fill.BackgroundColor3 = Toba.Theme.Accent
            Fill.Parent = BarBG
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

            local dragging = false
            local function Update(input)
                local pos = math.clamp((input.Position.X - BarBG.AbsolutePosition.X) / BarBG.AbsoluteSize.X, 0, 1)
                Current = math.floor(Min + ((Max - Min) * pos))
                ValText.Text = tostring(Current)
                Tween(Fill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
                if config.Callback then config.Callback(Current) end
            end

            BarBG.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true; Update(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then Update(input) end
            end)
        end

        function Tab:CreateInput(config)
            local Box = Instance.new("Frame")
            Box.Size = UDim2.new(1, 0, 0, 40)
            Box.BackgroundColor3 = Toba.Theme.Element
            Box.Parent = Page
            Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 6)

            local Input = Instance.new("TextBox")
            Input.Size = UDim2.new(1, -30, 1, 0)
            Input.Position = UDim2.new(0, 15, 0, 0)
            Input.BackgroundTransparency = 1
            Input.PlaceholderText = config.Name or "Enter Text..."
            Input.PlaceholderColor3 = Toba.Theme.SubText
            Input.Text = ""
            Input.TextColor3 = Toba.Theme.Text
            Input.Font = Enum.Font.GothamBold
            Input.TextSize = 13
            Input.TextXAlignment = Enum.TextXAlignment.Left
            Input.ClearTextOnFocus = false
            Input.Parent = Box

            Input.FocusLost:Connect(function()
                if config.Callback then config.Callback(Input.Text) end
            end)
        end

        function Tab:CreateDropdown(config)
            local Multi = config.Multi or false
            local Options = config.Options or {}
            local Selected = Multi and {} or nil
            local Open = false

            local Drop = Instance.new("Frame")
            Drop.Size = UDim2.new(1, 0, 0, 40)
            Drop.BackgroundColor3 = Toba.Theme.Element
            Drop.ClipsDescendants = true
            Drop.Parent = Page
            Instance.new("UICorner", Drop).CornerRadius = UDim.new(0, 6)

            local DropBtn = Instance.new("TextButton")
            DropBtn.Size = UDim2.new(1, 0, 0, 40)
            DropBtn.BackgroundTransparency = 1
            DropBtn.Text = ""
            DropBtn.Parent = Drop

            local DropText = Instance.new("TextLabel")
            DropText.Size = UDim2.new(1, -30, 1, 0)
            DropText.Position = UDim2.new(0, 15, 0, 0)
            DropText.BackgroundTransparency = 1
            DropText.Text = config.Name .. " - None"
            DropText.TextColor3 = Toba.Theme.Text
            DropText.Font = Enum.Font.GothamBold
            DropText.TextSize = 13
            DropText.TextXAlignment = Enum.TextXAlignment.Left
            DropText.Parent = DropBtn

            local OptionContainer = Instance.new("Frame")
            OptionContainer.Size = UDim2.new(1, 0, 1, -40)
            OptionContainer.Position = UDim2.new(0, 0, 0, 40)
            OptionContainer.BackgroundTransparency = 1
            OptionContainer.Parent = Drop

            local OptList = Instance.new("UIListLayout", OptionContainer)
            OptList.SortOrder = Enum.SortOrder.LayoutOrder

            local function UpdateText()
                if Multi then
                    local sel = {}
                    for k, v in pairs(Selected) do if v then table.insert(sel, k) end end
                    DropText.Text = #sel > 0 and config.Name .. " - " .. table.concat(sel, ", ") or config.Name .. " - None"
                else
                    DropText.Text = Selected and config.Name .. " - " .. Selected or config.Name .. " - None"
                end
            end

            local function Refresh()
                for _, child in pairs(OptionContainer:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
                local totalSize = 40
                for _, opt in ipairs(Options) do
                    totalSize = totalSize + 30
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1, 0, 0, 30)
                    btn.BackgroundColor3 = Toba.Theme.Element
                    btn.Text = opt
                    btn.TextColor3 = (Multi and Selected[opt]) and Toba.Theme.Accent or (not Multi and Selected == opt) and Toba.Theme.Accent or Toba.Theme.SubText
                    btn.Font = Enum.Font.GothamBold
                    btn.TextSize = 13
                    btn.Parent = OptionContainer

                    btn.MouseButton1Click:Connect(function()
                        if Multi then
                            Selected[opt] = not Selected[opt]
                            btn.TextColor3 = Selected[opt] and Toba.Theme.Accent or Toba.Theme.SubText
                        else
                            Selected = opt
                            for _, b in pairs(OptionContainer:GetChildren()) do if b:IsA("TextButton") then b.TextColor3 = Toba.Theme.SubText end end
                            btn.TextColor3 = Toba.Theme.Accent
                            Open = false
                            Tween(Drop, {Size = UDim2.new(1, 0, 0, 40)})
                        end
                        UpdateText()
                        if config.Callback then config.Callback(Selected) end
                    end)
                end
                if Open then Tween(Drop, {Size = UDim2.new(1, 0, 0, totalSize)}) end
            end

            DropBtn.MouseButton1Click:Connect(function()
                Open = not Open
                local targetSize = Open and (40 + (#Options * 30)) or 40
                Tween(Drop, {Size = UDim2.new(1, 0, 0, targetSize)})
            end)

            Refresh()
        end

        return Tab
    end

    return Window
end
