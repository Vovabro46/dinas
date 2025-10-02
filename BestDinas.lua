local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")

local Library = {}
Library.__index = Library

local colors = {
    background = Color3.fromRGB(15, 15, 25),
    surface = Color3.fromRGB(25, 25, 35),
    primary = Color3.fromRGB(100, 70, 200),
    secondary = Color3.fromRGB(70, 130, 230),
    accent = Color3.fromRGB(0, 200, 220),
    text = Color3.fromRGB(240, 240, 250),
    textSecondary = Color3.fromRGB(180, 180, 200),
    success = Color3.fromRGB(90, 200, 120),
    warning = Color3.fromRGB(230, 170, 50),
    error = Color3.fromRGB(220, 80, 80),
    dark = Color3.fromRGB(10, 10, 20),
    light = Color3.fromRGB(40, 40, 60),
    purple = Color3.fromRGB(140, 80, 255),
    pink = Color3.fromRGB(255, 80, 180),
    cyan = Color3.fromRGB(80, 200, 255),
    orange = Color3.fromRGB(255, 140, 50)
}

local FONT_REGULAR = Enum.Font.ArimoBold
local FONT_BOLD = Enum.Font.ArimoBold
local FONT_ICONS = Enum.Font.ArimoBold

local function createTween(object, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        duration or 0.4,
        easingStyle or Enum.EasingStyle.Quint,
        easingDirection or Enum.EasingDirection.Out,
        0, false, 0
    )
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

local function springTween(object, properties, frequency, damping)
    frequency = frequency or 6
    damping = damping or 0.7
    
    local startValues = {}
    local targetValues = {}
    local velocity = {}
    
    for property, value in pairs(properties) do
        startValues[property] = object[property]
        targetValues[property] = value
        velocity[property] = 0
    end
    
    local connection
    connection = RunService.Heartbeat:Connect(function(delta)
        local stillMoving = false
        
        for property, targetValue in pairs(targetValues) do
            local currentValue = object[property]
            local currentVelocity = velocity[property]
            
            if typeof(currentValue) == "number" then
                local displacement = targetValue - currentValue
                local acceleration = (displacement * frequency * frequency) - (2 * frequency * damping * currentVelocity)
                
                velocity[property] = currentVelocity + acceleration * delta
                local newValue = currentValue + velocity[property] * delta
                
                if math.abs(displacement) < 0.001 and math.abs(currentVelocity) < 0.001 then
                    object[property] = targetValue
                else
                    object[property] = newValue
                    stillMoving = true
                end
            elseif typeof(currentValue) == "Color3" then
                local rDisplacement = targetValue.R - currentValue.R
                local gDisplacement = targetValue.G - currentValue.G
                local bDisplacement = targetValue.B - currentValue.B
                
                local rAcceleration = (rDisplacement * frequency * frequency) - (2 * frequency * damping * currentVelocity)
                local gAcceleration = (gDisplacement * frequency * frequency) - (2 * frequency * damping * currentVelocity)
                local bAcceleration = (bDisplacement * frequency * frequency) - (2 * frequency * damping * currentVelocity)
                
                velocity[property] = currentVelocity + ((rAcceleration + gAcceleration + bAcceleration) / 3) * delta
                
                local newR = math.clamp(currentValue.R + velocity[property] * delta, 0, 1)
                local newG = math.clamp(currentValue.G + velocity[property] * delta, 0, 1)
                local newB = math.clamp(currentValue.B + velocity[property] * delta, 0, 1)
                
                if math.abs(rDisplacement) < 0.001 and math.abs(gDisplacement) < 0.001 and math.abs(bDisplacement) < 0.001 and math.abs(velocity[property]) < 0.001 then
                    object[property] = targetValue
                else
                    object[property] = Color3.new(newR, newG, newB)
                    stillMoving = true
                end
            end
        end
        
        if not stillMoving then
            connection:Disconnect()
        end
    end)
    
    return connection
end

local themes = {
    Dark = {
        background = Color3.fromRGB(15, 15, 25),
        surface = Color3.fromRGB(25, 25, 35),
        primary = Color3.fromRGB(100, 70, 200),
        text = Color3.fromRGB(240, 240, 250)
    },
    Light = {
        background = Color3.fromRGB(240, 240, 245),
        surface = Color3.fromRGB(255, 255, 255),
        primary = Color3.fromRGB(80, 60, 180),
        text = Color3.fromRGB(30, 30, 40)
    },
    Cyber = {
        background = Color3.fromRGB(10, 15, 30),
        surface = Color3.fromRGB(20, 25, 45),
        primary = Color3.fromRGB(0, 200, 255),
        text = Color3.fromRGB(220, 240, 255)
    },
    Neon = {
        background = Color3.fromRGB(5, 5, 15),
        surface = Color3.fromRGB(15, 15, 25),
        primary = Color3.fromRGB(255, 0, 255),
        text = Color3.fromRGB(255, 255, 255)
    }
}

local icons = {
    Settings = "⚙️",
    Home = "🏠",
    Info = "ℹ️",
    Warning = "⚠️",
    Error = "❌",
    Success = "✅",
    Add = "➕",
    Remove = "➖",
    Search = "🔍",
    User = "👤",
    Lock = "🔒",
    Unlock = "🔓",
    Star = "⭐",
    Heart = "❤️",
    Fire = "🔥",
    Money = "💰",
    Time = "⏰"
}

function Library:CreateWindow(title, config)
    config = config or {}
    local player = Players.LocalPlayer
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DinasLib_" .. HttpService:GenerateGUID(false):sub(1, 8)
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 999
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.BackgroundColor3 = colors.background
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    mainFrame.ZIndex = 2

    mainFrame.Size = UDim2.new(0, 10, 0, 10)
    mainFrame.BackgroundTransparency = 1

    local spawnTween = createTween(mainFrame, {
        Size = UDim2.new(0, 650, 0, 500),
        BackgroundTransparency = 0
    }, 0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 16)
    uiCorner.Parent = mainFrame

    local uiStroke = Instance.new("UIStroke")
    uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    uiStroke.Color = colors.primary
    uiStroke.Thickness = 2
    uiStroke.Transparency = 0.3
    uiStroke.Parent = mainFrame

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, colors.primary),
        ColorSequenceKeypoint.new(1, colors.secondary)
    })
    gradient.Rotation = 45
    gradient.Transparency = NumberSequence.new(0.9)
    gradient.Parent = uiStroke

    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 45)
    titleBar.BackgroundColor3 = colors.surface
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    titleBar.ZIndex = 3

    local titleBarGradient = Instance.new("UIGradient")
    titleBarGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, colors.primary),
        ColorSequenceKeypoint.new(1, colors.secondary)
    })
    titleBarGradient.Transparency = NumberSequence.new(0.9)
    titleBarGradient.Parent = titleBar

    local titleText = Instance.new("TextLabel")
    titleText.Name = "TitleText"
    titleText.Size = UDim2.new(1, -100, 1, 0)
    titleText.Position = UDim2.new(0, 15, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = icons.Home .. " " .. title
    titleText.TextColor3 = colors.text
    titleText.TextSize = 18
    titleText.Font = FONT_BOLD
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    titleText.ZIndex = 4

    local controlButtons = {"Minimize", "Maximize", "Close"}
    local buttonIcons = {icons.Remove, "⛶", icons.Error}
    
    for i, buttonName in ipairs(controlButtons) do
        local button = Instance.new("TextButton")
        button.Name = buttonName .. "Button"
        button.Size = UDim2.new(0, 35, 1, 0)
        button.Position = UDim2.new(1, -35 * (4 - i), 0, 0)
        button.BackgroundTransparency = 1
        button.Text = buttonIcons[i]
        button.TextColor3 = colors.text
        button.TextSize = 16
        button.Font = FONT_REGULAR
        button.Parent = titleBar
        button.ZIndex = 4
        
        button.MouseEnter:Connect(function()
            createTween(button, {TextColor3 = colors.primary}, 0.2)
        end)
        
        button.MouseLeave:Connect(function()
            createTween(button, {TextColor3 = colors.text}, 0.2)
        end)
    end

    local tabButtonsFrame = Instance.new("ScrollingFrame")
    tabButtonsFrame.Name = "TabButtons"
    tabButtonsFrame.Size = UDim2.new(0, 180, 1, -45)
    tabButtonsFrame.Position = UDim2.new(0, 0, 0, 45)
    tabButtonsFrame.BackgroundColor3 = colors.surface
    tabButtonsFrame.BorderSizePixel = 0
    tabButtonsFrame.ScrollBarThickness = 3
    tabButtonsFrame.ScrollBarImageColor3 = colors.primary
    tabButtonsFrame.Parent = mainFrame
    tabButtonsFrame.ZIndex = 2

    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -180, 1, -45)
    contentFrame.Position = UDim2.new(0, 180, 0, 45)
    contentFrame.BackgroundColor3 = colors.background
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = mainFrame
    contentFrame.ZIndex = 2

    local glassEffect = Instance.new("Frame")
    glassEffect.Name = "GlassEffect"
    glassEffect.Size = UDim2.new(1, 0, 1, 0)
    glassEffect.BackgroundColor3 = Color3.new(1, 1, 1)
    glassEffect.BackgroundTransparency = 0.95
    glassEffect.BorderSizePixel = 0
    glassEffect.ZIndex = 5
    glassEffect.Parent = mainFrame

    local tabs = {}
    local currentTab = nil
    local isMinimized = false

    local closeButton = titleBar:FindFirstChild("CloseButton")
    local minimizeButton = titleBar:FindFirstChild("MinimizeButton")
    local maximizeButton = titleBar:FindFirstChild("MaximizeButton")

    closeButton.MouseButton1Click:Connect(function()
        createTween(mainFrame, {
            Size = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = 1
        }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        
        createTween(backdrop, {BackgroundTransparency = 1}, 0.5)
        wait(0.5)
        screenGui:Destroy()
    end)

    minimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            createTween(mainFrame, {Size = UDim2.new(0, 650, 0, 45)}, 0.4)
            minimizeButton.Text = icons.Add
            tabButtonsFrame.Visible = false
            contentFrame.Visible = false
        else
            createTween(mainFrame, {Size = UDim2.new(0, 650, 0, 500)}, 0.4)
            minimizeButton.Text = icons.Remove
            tabButtonsFrame.Visible = true
            contentFrame.Visible = true
        end
    end)

    local dragging = false
    local dragInput, dragStart, startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    local function adaptForDevice()
        if UserInputService.TouchEnabled then
            mainFrame.Size = UDim2.new(0.95, 0, 0.9, 0)
            titleText.TextSize = 20
        else
            mainFrame.Size = UDim2.new(0, 650, 0, 500)
            titleText.TextSize = 18
        end
    end

    adaptForDevice()
    UserInputService:GetPropertyChangedSignal("TouchEnabled"):Connect(adaptForDevice)

    local window = {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        TabButtonsFrame = tabButtonsFrame,
        ContentFrame = contentFrame,
        Tabs = tabs,
        CurrentTheme = "Dark",
    }

    setmetatable(window, Library)

    function window:SetTheme(themeName)
        local theme = themes[themeName] or themes.Dark
        self.CurrentTheme = themeName
        
        springTween(mainFrame, {BackgroundColor3 = theme.background}, 8)
        springTween(titleBar, {BackgroundColor3 = theme.surface}, 8)
        springTween(tabButtonsFrame, {BackgroundColor3 = theme.surface}, 8)
        springTween(titleText, {TextColor3 = theme.text}, 8)
        
        for _, tab in ipairs(self.Tabs) do
            springTween(tab.Button, {BackgroundColor3 = theme.surface}, 8)
            springTween(tab.Button:FindFirstChild("TextLabel"), {TextColor3 = theme.text}, 8)
        end
    end
    
    function window:SetVisible(visible)
        if visible then
            self.ScreenGui.Enabled = true
            createTween(self.MainFrame, {
                Size = UDim2.new(0, 600, 0, 430),
                BackgroundTransparency = 0
            }, 0.4)
            createTween(self.Backdrop, {BackgroundTransparency = 0.7}, 0.4)
        else
            createTween(self.MainFrame, {
                Size = UDim2.new(0, 10, 0, 10),
                BackgroundTransparency = 1
            }, 0.4)
            createTween(self.Backdrop, {BackgroundTransparency = 1}, 0.4)
            wait(0.4)
            self.ScreenGui.Enabled = false
        end
    end
    
    local function handleHotkey(input)
        if input.KeyCode == Enum.KeyCode.RightControl then
            window:SetVisible(not screenGui.Enabled)
        end
    end
    
    UserInputService.InputBegan:Connect(handleHotkey)

    return window
end

function Library:AddSection(tab, name, icon, config)
    config = config or {}
    local textColor = config.color or colors.text
    
    local sectionFrame = Instance.new("Frame")
    sectionFrame.Name = name .. "Section"
    sectionFrame.Size = UDim2.new(1, -20, 0, 40)
    sectionFrame.BackgroundTransparency = 1
    sectionFrame.Parent = tab.Content
    sectionFrame.LayoutOrder = #tab.Elements + 1
    sectionFrame.Visible = true
    sectionFrame.ZIndex = 3

    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, 0, 1, 0)
    contentFrame.Position = UDim2.new(0, 0, 0, 0)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = sectionFrame
    contentFrame.ZIndex = 4

    local iconLabel
    if icon then
        iconLabel = Instance.new("TextLabel")
        iconLabel.Name = "Icon"
        iconLabel.Size = UDim2.new(0, 30, 0, 30)
        iconLabel.Position = UDim2.new(0, 0, 0.5, -15)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Text = icon
        iconLabel.TextColor3 = colors.primary
        iconLabel.TextSize = 20
        iconLabel.Font = FONT_REGULAR
        iconLabel.TextXAlignment = Enum.TextXAlignment.Center
        iconLabel.TextYAlignment = Enum.TextYAlignment.Center
        iconLabel.Parent = contentFrame
        iconLabel.ZIndex = 5
    end

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "Text"
    textLabel.Size = UDim2.new(1, icon and -35 or 0, 1, 0)
    textLabel.Position = UDim2.new(0, icon and 35 or 0, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = name
    textLabel.TextColor3 = textColor
    textLabel.TextSize = 16
    textLabel.Font = FONT_BOLD
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Center
    textLabel.Parent = contentFrame
    textLabel.ZIndex = 5

    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.Position = UDim2.new(0, 0, 1, -1)
    divider.BackgroundColor3 = colors.primary
    divider.BackgroundTransparency = 0.7
    divider.BorderSizePixel = 0
    divider.Parent = sectionFrame
    divider.ZIndex = 4

    sectionFrame.BackgroundTransparency = 1
    textLabel.TextTransparency = 1
    divider.BackgroundTransparency = 1
    
    if iconLabel then
        iconLabel.TextTransparency = 1
        createTween(iconLabel, {TextTransparency = 0}, 0.5)
    end
    
    createTween(textLabel, {TextTransparency = 0}, 0.5)
    createTween(divider, {BackgroundTransparency = 0.7}, 0.5)

    table.insert(tab.Elements, sectionFrame)
    return sectionFrame
end

function Library:AddTab(name, icon)
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "TabButton"
    tabButton.Size = UDim2.new(1, -20, 0, 50)
    tabButton.Position = UDim2.new(0, 10, 0, 10 + (#self.Tabs * 55))
    tabButton.BackgroundColor3 = colors.surface
    tabButton.BorderSizePixel = 0
    tabButton.Text = ""
    tabButton.AutoButtonColor = false
    tabButton.Parent = self.TabButtonsFrame
    tabButton.LayoutOrder = #self.Tabs + 1

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 12)
    uiCorner.Parent = tabButton

    local iconLabel = Instance.new("TextLabel")
    iconLabel.Name = "Icon"
    iconLabel.Size = UDim2.new(0, 30, 1, 0)
    iconLabel.Position = UDim2.new(0, 10, 0, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon or icons.Settings
    iconLabel.TextColor3 = colors.textSecondary
    iconLabel.TextSize = 16
    iconLabel.Font = FONT_REGULAR
    iconLabel.TextXAlignment = Enum.TextXAlignment.Left
    iconLabel.Parent = tabButton

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "Text"
    textLabel.Size = UDim2.new(1, -50, 1, 0)
    textLabel.Position = UDim2.new(0, 40, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = name
    textLabel.TextColor3 = colors.textSecondary
    textLabel.TextSize = 14
    textLabel.Font = FONT_BOLD
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = tabButton

    local highlight = Instance.new("Frame")
    highlight.Name = "Highlight"
    highlight.Size = UDim2.new(0, 4, 0.6, 0)
    highlight.Position = UDim2.new(0, -8, 0.2, 0)
    highlight.BackgroundColor3 = colors.primary
    highlight.BorderSizePixel = 0
    highlight.Visible = false
    highlight.Parent = tabButton

    local highlightCorner = Instance.new("UICorner")
    highlightCorner.CornerRadius = UDim.new(0, 2)
    highlightCorner.Parent = highlight

    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Name = name .. "Content"
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundColor3 = colors.background
    tabContent.BorderSizePixel = 0
    tabContent.ScrollBarThickness = 4
    tabContent.ScrollBarImageColor3 = colors.primary
    tabContent.Visible = false
    tabContent.Parent = self.ContentFrame

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 15)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = tabContent

    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingLeft = UDim.new(0, 20)
    contentPadding.PaddingTop = UDim.new(0, 20)
    contentPadding.PaddingRight = UDim.new(0, 20)
    contentPadding.Parent = tabContent

    local tab = {
        Name = name,
        Button = tabButton,
        Content = tabContent,
        Elements = {},
        Highlight = highlight
    }

    table.insert(self.Tabs, tab)

    tabButton.MouseEnter:Connect(function()
        if currentTab ~= tab then
            springTween(tabButton, {BackgroundColor3 = Color3.fromRGB(35, 35, 50)}, 10)
            springTween(textLabel, {TextColor3 = colors.text}, 10)
            springTween(iconLabel, {TextColor3 = colors.primary}, 10)
        end
    end)

    tabButton.MouseLeave:Connect(function()
        if currentTab ~= tab then
            springTween(tabButton, {BackgroundColor3 = colors.surface}, 10)
            springTween(textLabel, {TextColor3 = colors.textSecondary}, 10)
            springTween(iconLabel, {TextColor3 = colors.textSecondary}, 10)
        end
    end)

    tabButton.MouseButton1Click:Connect(function()
        self:SwitchTab(tab)
    end)

    if #self.Tabs == 1 then
        self:SwitchTab(tab)
    end

    return tab
end

function Library:SwitchTab(tab)
    for _, t in ipairs(self.Tabs) do
        t.Content.Visible = false
        t.Highlight.Visible = false
        
        springTween(t.Button, {BackgroundColor3 = colors.surface}, 8)
        springTween(t.Button.Text, {TextColor3 = colors.textSecondary}, 8)
        springTween(t.Button.Icon, {TextColor3 = colors.textSecondary}, 8)
    end

    tab.Content.Visible = true
    tab.Highlight.Visible = true
    
    springTween(tab.Button, {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}, 8)
    springTween(tab.Button.Text, {TextColor3 = colors.text}, 8)
    springTween(tab.Button.Icon, {TextColor3 = colors.primary}, 8)
    
    currentTab = tab
end

function Library:AddButton(tab, name, callback, config)
    config = config or {}
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, -20, 0, 45)
    button.BackgroundColor3 = colors.surface
    button.BorderSizePixel = 0
    button.Text = name
    button.TextColor3 = colors.text
    button.TextSize = 14
    button.Font = FONT_REGULAR
    button.Parent = tab.Content
    button.LayoutOrder = #tab.Elements + 1
    button.AutoButtonColor = false
    button.Visible = true
    button.ZIndex = 3
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = button
    
    local buttonHighlight = Instance.new("Frame")
    buttonHighlight.Name = "Highlight"
    buttonHighlight.Size = UDim2.new(1, 0, 1, 0)
    buttonHighlight.Position = UDim2.new(0, 0, 0, 0)
    buttonHighlight.BackgroundColor3 = colors.primary
    buttonHighlight.BackgroundTransparency = 1
    buttonHighlight.BorderSizePixel = 0
    buttonHighlight.ZIndex = -1
    buttonHighlight.Parent = button
    
    local highlightCorner = Instance.new("UICorner")
    highlightCorner.CornerRadius = UDim.new(0, 8)
    highlightCorner.Parent = buttonHighlight
    
    button.MouseEnter:Connect(function()
        createTween(button, {BackgroundColor3 = Color3.fromRGB(45, 45, 60)}, 0.2)
        createTween(buttonHighlight, {BackgroundTransparency = 0.9}, 0.2)
    end)
    
    button.MouseLeave:Connect(function()
        createTween(button, {BackgroundColor3 = colors.surface}, 0.2)
        createTween(buttonHighlight, {BackgroundTransparency = 1}, 0.2)
    end)
    
    button.MouseButton1Down:Connect(function()
        createTween(button, {Size = UDim2.new(1, -25, 0, 42)}, 0.1)
        createTween(button, {BackgroundColor3 = colors.primary}, 0.1)
    end)
    
    button.MouseButton1Up:Connect(function()
        createTween(button, {Size = UDim2.new(1, -20, 0, 45)}, 0.1)
        createTween(button, {BackgroundColor3 = Color3.fromRGB(45, 45, 60)}, 0.1)
    end)
    
    button.MouseButton1Click:Connect(function()
        createTween(buttonHighlight, {BackgroundTransparency = 0.7}, 0.1)
        wait(0.1)
        createTween(buttonHighlight, {BackgroundTransparency = 0.9}, 0.3)
        
        local ripple = Instance.new("Frame")
        ripple.Name = "Ripple"
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.8
        ripple.BorderSizePixel = 0
        ripple.ZIndex = 2
        ripple.Parent = button
        
        local rippleCorner = Instance.new("UICorner")
        rippleCorner.CornerRadius = UDim.new(1, 0)
        rippleCorner.Parent = ripple
        
        createTween(ripple, {
            Size = UDim2.new(2, 0, 2, 0),
            BackgroundTransparency = 1
        }, 0.6):Wait()
        
        ripple:Destroy()
        callback()
    end)
    
    table.insert(tab.Elements, button)
    return button
end

function Library:AddToggle(tab, name, callback, config)
    config = config or {}
    local defaultState = config.default or false
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = name
    toggleFrame.Size = UDim2.new(1, -20, 0, 40)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = tab.Content
    toggleFrame.LayoutOrder = #tab.Elements + 1
    toggleFrame.Visible = true
    toggleFrame.ZIndex = 3

    local toggleText = Instance.new("TextLabel")
    toggleText.Name = "Text"
    toggleText.Size = UDim2.new(0.7, 0, 1, 0)
    toggleText.Position = UDim2.new(0, 0, 0, 0)
    toggleText.BackgroundTransparency = 1
    toggleText.Text = name
    toggleText.TextColor3 = colors.text
    toggleText.TextSize = 14
    toggleText.Font = FONT_REGULAR
    toggleText.TextXAlignment = Enum.TextXAlignment.Left
    toggleText.Parent = toggleFrame
    toggleText.ZIndex = 4

    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "Toggle"
    toggleButton.Size = UDim2.new(0, 50, 0, 25)
    toggleButton.Position = UDim2.new(1, -50, 0.5, -12)
    toggleButton.BackgroundColor3 = colors.surface
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = ""
    toggleButton.Parent = toggleFrame
    toggleButton.AutoButtonColor = false
    toggleButton.ZIndex = 4

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 12)
    toggleCorner.Parent = toggleButton

    local toggleDot = Instance.new("Frame")
    toggleDot.Name = "Dot"
    toggleDot.Size = UDim2.new(0, 21, 0, 21)
    toggleDot.Position = UDim2.new(0, 2, 0, 2)
    toggleDot.BackgroundColor3 = colors.text
    toggleDot.BorderSizePixel = 0
    toggleDot.Parent = toggleButton
    toggleDot.ZIndex = 5

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(0, 10)
    dotCorner.Parent = toggleDot

    local isToggled = defaultState

    local function updateToggle()
        if isToggled then
            createTween(toggleButton, {BackgroundColor3 = colors.primary}, 0.3, Enum.EasingStyle.Quad)
            createTween(toggleDot, {
                Position = UDim2.new(0, 27, 0, 2),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        else
            createTween(toggleButton, {BackgroundColor3 = colors.surface}, 0.3, Enum.EasingStyle.Quad)
            createTween(toggleDot, {
                Position = UDim2.new(0, 2, 0, 2),
                BackgroundColor3 = colors.text
            }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end
        callback(isToggled)
    end

    toggleButton.MouseEnter:Connect(function()
        createTween(toggleButton, {
            BackgroundColor3 = isToggled and Color3.fromRGB(110, 80, 210) or Color3.fromRGB(50, 50, 65)
        }, 0.2)
    end)

    toggleButton.MouseLeave:Connect(function()
        createTween(toggleButton, {
            BackgroundColor3 = isToggled and colors.primary or colors.surface
        }, 0.2)
    end)

    toggleButton.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        updateToggle()
        
        local ripple = Instance.new("Frame")
        ripple.Name = "Ripple"
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.BackgroundColor3 = isToggled and colors.primary or colors.textSecondary
        ripple.BackgroundTransparency = 0.7
        ripple.BorderSizePixel = 0
        ripple.ZIndex = 6
        ripple.Parent = toggleButton
        
        local rippleCorner = Instance.new("UICorner")
        rippleCorner.CornerRadius = UDim.new(1, 0)
        rippleCorner.Parent = ripple
        
        createTween(ripple, {
            Size = UDim2.new(2, 0, 2, 0),
            BackgroundTransparency = 1
        }, 0.4):Wait()
        ripple:Destroy()
    end)

    updateToggle()

    table.insert(tab.Elements, toggleFrame)
    return {
        Frame = toggleFrame,
        SetState = function(state)
            isToggled = state
            updateToggle()
        end,
        GetState = function()
            return isToggled
        end
    }
end

function Library:AddSlider(tab, name, min, max, defaultValue, callback, config)
    config = config or {}
    local precision = config.precision or 0
    local suffix = config.suffix or ""
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = name
    sliderFrame.Size = UDim2.new(1, -20, 0, 60)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = tab.Content
    sliderFrame.LayoutOrder = #tab.Elements + 1
    sliderFrame.Visible = true
    sliderFrame.ZIndex = 3

    local sliderText = Instance.new("TextLabel")
    sliderText.Name = "Text"
    sliderText.Size = UDim2.new(1, 0, 0, 20)
    sliderText.Position = UDim2.new(0, 0, 0, 0)
    sliderText.BackgroundTransparency = 1
    sliderText.Text = name .. ": " .. defaultValue .. suffix
    sliderText.TextColor3 = colors.text
    sliderText.TextSize = 14
    sliderText.Font = FONT_REGULAR
    sliderText.TextXAlignment = Enum.TextXAlignment.Left
    sliderText.Parent = sliderFrame
    sliderText.ZIndex = 4

    local sliderTrack = Instance.new("Frame")
    sliderTrack.Name = "Track"
    sliderTrack.Size = UDim2.new(1, 0, 0, 6)
    sliderTrack.Position = UDim2.new(0, 0, 0, 35)
    sliderTrack.BackgroundColor3 = colors.surface
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Parent = sliderFrame
    sliderTrack.ZIndex = 4

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 3)
    trackCorner.Parent = sliderTrack

    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "Fill"
    sliderFill.Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = colors.primary
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderTrack
    sliderFill.ZIndex = 5

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = sliderFill

    local sliderButton = Instance.new("TextButton")
    sliderButton.Name = "SliderButton"
    sliderButton.Size = UDim2.new(0, 18, 0, 18)
    sliderButton.Position = UDim2.new((defaultValue - min) / (max - min), -9, 0.5, -9)
    sliderButton.BackgroundColor3 = colors.text
    sliderButton.BorderSizePixel = 0
    sliderButton.Text = ""
    sliderButton.Parent = sliderTrack
    sliderButton.AutoButtonColor = false
    sliderButton.ZIndex = 6

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 9)
    buttonCorner.Parent = sliderButton

    local isSliding = false
    local currentValue = defaultValue

    local function updateSlider(value)
        value = math.clamp(value, min, max)
        currentValue = precision > 0 and math.floor(value * 10^precision) / 10^precision or math.floor(value)
        
        sliderText.Text = name .. ": " .. currentValue .. suffix
        
        createTween(sliderFill, {
            Size = UDim2.new((currentValue - min) / (max - min), 0, 1, 0)
        }, 0.1, Enum.EasingStyle.Quad)
        
        createTween(sliderButton, {
            Position = UDim2.new((currentValue - min) / (max - min), -9, 0.5, -9)
        }, 0.1, Enum.EasingStyle.Quad)
        
        callback(currentValue)
    end

    sliderButton.MouseEnter:Connect(function()
        if not isSliding then
            createTween(sliderButton, {Size = UDim2.new(0, 20, 0, 20)}, 0.2)
            createTween(sliderButton, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
        end
    end)

    sliderButton.MouseLeave:Connect(function()
        if not isSliding then
            createTween(sliderButton, {Size = UDim2.new(0, 18, 0, 18)}, 0.2)
            createTween(sliderButton, {BackgroundColor3 = colors.text}, 0.2)
        end
    end)

    local function onInputChanged(input)
        if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local inputPosition = input.UserInputType == Enum.UserInputType.Touch and input.Position or UserInputService:GetMouseLocation()
            local trackPos = sliderTrack.AbsolutePosition
            local trackSize = sliderTrack.AbsoluteSize
            local relativeX = (inputPosition.X - trackPos.X) / trackSize.X
            local value = min + (max - min) * math.clamp(relativeX, 0, 1)
            updateSlider(value)
        end
    end

    sliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSliding = true
            createTween(sliderButton, {Size = UDim2.new(0, 22, 0, 22)}, 0.1)
            createTween(sliderFill, {BackgroundColor3 = Color3.fromRGB(120, 90, 220)}, 0.1)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if isSliding then
                isSliding = false
                createTween(sliderButton, {Size = UDim2.new(0, 18, 0, 18)}, 0.2)
                createTween(sliderFill, {BackgroundColor3 = colors.primary}, 0.2)
            end
        end
    end)

    UserInputService.InputChanged:Connect(onInputChanged)

    table.insert(tab.Elements, sliderFrame)
    
    return {
        Frame = sliderFrame,
        SetValue = function(value)
            updateSlider(value)
        end,
        GetValue = function()
            return currentValue
        end
    }
end

function Library:AddLabel(tab, text, icon, config)
    config = config or {}
    local textColor = config.color or colors.textSecondary
    
    local labelFrame = Instance.new("Frame")
    labelFrame.Name = "LabelFrame"
    labelFrame.Size = UDim2.new(1, -20, 0, 30)
    labelFrame.BackgroundTransparency = 1
    labelFrame.Parent = tab.Content
    labelFrame.LayoutOrder = #tab.Elements + 1
    labelFrame.Visible = true
    labelFrame.ZIndex = 3

    local labelText = Instance.new("TextLabel")
    labelText.Name = "LabelText"
    labelText.Size = UDim2.new(1, 0, 1, 0)
    labelText.Position = UDim2.new(0, 0, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = icon and (" " .. icon .. "  " .. text) or text
    labelText.TextColor3 = textColor
    labelText.TextSize = 14
    labelText.Font = FONT_REGULAR
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = labelFrame
    labelText.ZIndex = 4

    labelText.TextTransparency = 1
    createTween(labelText, {TextTransparency = 0}, 0.5)

    table.insert(tab.Elements, labelFrame)
    return labelFrame
end

function Library:AddParagraph(tab, text, icon, config)
    config = config or {}
    local textColor = config.color or colors.textSecondary
    
    local paragraphFrame = Instance.new("Frame")
    paragraphFrame.Name = "ParagraphFrame"
    paragraphFrame.BackgroundTransparency = 1
    paragraphFrame.LayoutOrder = #tab.Elements + 1
    paragraphFrame.Visible = true
    paragraphFrame.Size = UDim2.new(1, 0, 0, 0)
    paragraphFrame.Parent = tab.Content
    paragraphFrame.ZIndex = 3

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "ParagraphText"
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = textColor
    textLabel.TextSize = 13
    textLabel.Font = FONT_REGULAR
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.TextWrapped = true
    textLabel.Text = icon and (icon .. "  " .. text) or text
    textLabel.Size = UDim2.new(1, 0, 0, 0)
    textLabel.Position = UDim2.new(0, 0, 0, 0)
    textLabel.Parent = paragraphFrame
    textLabel.ZIndex = 4

    local padding = 20

    local function updateSize()
        if paragraphFrame.AbsoluteSize.X == 0 then return end
        
        local maxWidth = paragraphFrame.AbsoluteSize.X - padding
        
        local textSize = TextService:GetTextSize(
            textLabel.Text, 
            textLabel.TextSize, 
            textLabel.Font, 
            Vector2.new(maxWidth, math.huge)
        )
        
        textLabel.Size = UDim2.new(1, -padding, 0, textSize.Y)
        paragraphFrame.Size = UDim2.new(1, 0, 0, textSize.Y + 10)
    end

    paragraphFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSize)
    textLabel:GetPropertyChangedSignal("Text"):Connect(updateSize)
    
    if tab.Content then
        tab.Content:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSize)
    end
    
    task.defer(updateSize)

    textLabel.TextTransparency = 1
    createTween(textLabel, {TextTransparency = 0}, 0.5)

    table.insert(tab.Elements, paragraphFrame)
    return paragraphFrame
end

function Library:AddDropdown(tab, name, options, defaultOption, callback, config)
    config = config or {}
    local multiSelect = config.multiSelect or false
    local searchable = config.searchable or false
    local scrollable = config.scrollable or true
    local maxHeight = config.maxHeight or 200
    
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Name = name .. "DropdownFrame"
    dropdownFrame.Size = UDim2.new(1, -20, 0, 40)
    dropdownFrame.BackgroundTransparency = 1
    dropdownFrame.Parent = tab.Content
    dropdownFrame.LayoutOrder = #tab.Elements + 1
    dropdownFrame.Visible = true
    dropdownFrame.ZIndex = 3

    local dropdownText = Instance.new("TextLabel")
    dropdownText.Name = "Text"
    dropdownText.Size = UDim2.new(0.7, 0, 1, 0)
    dropdownText.Position = UDim2.new(0, 0, 0, 0)
    dropdownText.BackgroundTransparency = 1
    dropdownText.Text = name
    dropdownText.TextColor3 = colors.text
    dropdownText.TextSize = 14
    dropdownText.Font = FONT_BOLD
    dropdownText.TextXAlignment = Enum.TextXAlignment.Left
    dropdownText.Parent = dropdownFrame
    dropdownText.ZIndex = 4

    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Name = "DropdownButton"
    dropdownButton.Size = UDim2.new(0.3, 0, 1, 0)
    dropdownButton.Position = UDim2.new(0.7, 0, 0, 0)
    dropdownButton.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    dropdownButton.BorderSizePixel = 0
    dropdownButton.Text = defaultOption or "Select..."
    dropdownButton.TextColor3 = colors.text
    dropdownButton.TextSize = 13
    dropdownButton.Font = FONT_REGULAR
    dropdownButton.Parent = dropdownFrame
    dropdownButton.AutoButtonColor = false
    dropdownButton.ZIndex = 4

    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 8)
    dropdownCorner.Parent = dropdownButton

    local dropdownIcon = Instance.new("TextLabel")
    dropdownIcon.Name = "Icon"
    dropdownIcon.Size = UDim2.new(0, 20, 1, 0)
    dropdownIcon.Position = UDim2.new(1, -20, 0, 0)
    dropdownIcon.BackgroundTransparency = 1
    dropdownIcon.Text = "▼"
    dropdownIcon.TextColor3 = colors.textSecondary
    dropdownIcon.TextSize = 12
    dropdownIcon.Font = FONT_REGULAR
    dropdownIcon.Parent = dropdownButton
    dropdownIcon.ZIndex = 5

    local screenGui = self.ScreenGui
    local dropdownList = Instance.new("Frame")
    dropdownList.Name = "DropdownList"
    dropdownList.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    dropdownList.BorderSizePixel = 0
    dropdownList.Visible = false
    dropdownList.ZIndex = 100
    dropdownList.Parent = screenGui
    dropdownList.ClipsDescendants = true

    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 8)
    listCorner.Parent = dropdownList

    local listStroke = Instance.new("UIStroke")
    listStroke.Color = colors.primary
    listStroke.Thickness = 1
    listStroke.Transparency = 0.3
    listStroke.Parent = dropdownList

    local searchBox
    if searchable then
        searchBox = Instance.new("TextBox")
        searchBox.Name = "SearchBox"
        searchBox.Size = UDim2.new(1, -10, 0, 30)
        searchBox.Position = UDim2.new(0, 5, 0, 5)
        searchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        searchBox.BorderSizePixel = 0
        searchBox.PlaceholderText = "Search..."
        searchBox.Text = ""
        searchBox.TextColor3 = colors.text
        searchBox.TextSize = 13
        searchBox.Font = FONT_REGULAR
        searchBox.ZIndex = 101
        searchBox.Parent = dropdownList

        local searchCorner = Instance.new("UICorner")
        searchCorner.CornerRadius = UDim.new(0, 6)
        searchCorner.Parent = searchBox

        local searchPadding = Instance.new("UIPadding")
        searchPadding.PaddingLeft = UDim.new(0, 10)
        searchPadding.Parent = searchBox
    end

    local optionsFrame = Instance.new("ScrollingFrame")
    optionsFrame.Name = "OptionsFrame"
    optionsFrame.BackgroundTransparency = 1
    optionsFrame.BorderSizePixel = 0
    optionsFrame.ScrollBarThickness = 4
    optionsFrame.ScrollBarImageColor3 = colors.primary
    optionsFrame.ZIndex = 101
    optionsFrame.Parent = dropdownList

    local optionsLayout = Instance.new("UIListLayout")
    optionsLayout.Parent = optionsFrame
    optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optionsLayout.Padding = UDim.new(0, 5)

    local optionsPadding = Instance.new("UIPadding")
    optionsPadding.PaddingTop = UDim.new(0, 5)
    optionsPadding.PaddingLeft = UDim.new(0, 5)
    optionsPadding.PaddingRight = UDim.new(0, 5)
    optionsPadding.Parent = optionsFrame

    local isOpen = false
    local selectedOptions = multiSelect and {} or nil
    local selectedOption = not multiSelect and defaultOption
    local renderConnection

    local function updateDropdownPosition()
        if not isOpen then return end
        
        local buttonAbsolutePos = dropdownButton.AbsolutePosition
        local buttonAbsoluteSize = dropdownButton.AbsoluteSize
        local screenSize = screenGui.AbsoluteSize
        
        local listWidth = math.max(buttonAbsoluteSize.X, 200)
        local contentHeight = optionsLayout.AbsoluteContentSize.Y + (searchable and 40 or 10)
        local listHeight = math.min(contentHeight, maxHeight)
        
        local positionX = buttonAbsolutePos.X
        local positionY = buttonAbsolutePos.Y + buttonAbsoluteSize.Y + 2

        if positionX + listWidth > screenSize.X then
            positionX = screenSize.X - listWidth - 5
        end
        
        if positionY + listHeight > screenSize.Y then
            positionY = buttonAbsolutePos.Y - listHeight - 2
        end

        dropdownList.Position = UDim2.new(0, positionX, 0, positionY)
        dropdownList.Size = UDim2.new(0, listWidth, 0, listHeight)
        optionsFrame.Size = UDim2.new(1, -10, 1, searchable and -40 or -10)
        optionsFrame.Position = UDim2.new(0, 5, 0, searchable and 40 or 5)
    end

    local function updateListSize()
        if isOpen then
            updateDropdownPosition()
        end
    end

    optionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateListSize)

    local function createOptions(filterText)
        for _, child in ipairs(optionsFrame:GetChildren()) do
            if child:IsA("TextButton") or child:IsA("Frame") then
                child:Destroy()
            end
        end

        local filteredOptions = options
        if searchable and filterText and filterText ~= "" then
            filteredOptions = {}
            for _, option in ipairs(options) do
                if string.find(string.lower(tostring(option)), string.lower(filterText)) then
                    table.insert(filteredOptions, option)
                end
            end
        end

        for i, option in ipairs(filteredOptions) do
            local optionButton = Instance.new("TextButton")
            optionButton.Name = tostring(option) .. "Option"
            optionButton.Size = UDim2.new(1, -10, 0, 30)
            optionButton.BackgroundColor3 = colors.surface
            optionButton.BorderSizePixel = 0
            optionButton.Text = ""
            optionButton.ZIndex = 102
            optionButton.AutoButtonColor = false
            optionButton.LayoutOrder = i
            optionButton.Parent = optionsFrame

            local optionCorner = Instance.new("UICorner")
            optionCorner.CornerRadius = UDim.new(0, 6)
            optionCorner.Parent = optionButton

            local optionText = Instance.new("TextLabel")
            optionText.Name = "Text"
            optionText.Size = UDim2.new(1, -30, 1, 0)
            optionText.Position = UDim2.new(0, 10, 0, 0)
            optionText.BackgroundTransparency = 1
            optionText.Text = tostring(option)
            optionText.TextColor3 = colors.text
            optionText.TextSize = 13
            optionText.Font = FONT_REGULAR
            optionText.TextXAlignment = Enum.TextXAlignment.Left
            optionText.ZIndex = 103
            optionText.Parent = optionButton

            local checkbox
            if multiSelect then
                checkbox = Instance.new("Frame")
                checkbox.Name = "Checkbox"
                checkbox.Size = UDim2.new(0, 16, 0, 16)
                checkbox.Position = UDim2.new(1, -25, 0.5, -8)
                checkbox.BackgroundColor3 = colors.surface
                checkbox.BorderSizePixel = 0
                checkbox.ZIndex = 103
                checkbox.Parent = optionButton

                local checkboxCorner = Instance.new("UICorner")
                checkboxCorner.CornerRadius = UDim.new(0, 4)
                checkboxCorner.Parent = checkbox

                local checkIcon = Instance.new("TextLabel")
                checkIcon.Name = "CheckIcon"
                checkIcon.Size = UDim2.new(1, 0, 1, 0)
                checkIcon.BackgroundTransparency = 1
                checkIcon.Text = "✓"
                checkIcon.TextColor3 = colors.text
                checkIcon.TextSize = 12
                checkIcon.Font = FONT_BOLD
                checkIcon.Visible = false
                checkIcon.ZIndex = 104
                checkIcon.Parent = checkbox

                if table.find(selectedOptions, option) then
                    checkbox.BackgroundColor3 = colors.primary
                    checkIcon.Visible = true
                end
            else
                if option == selectedOption then
                    optionButton.BackgroundColor3 = colors.primary
                end
            end

            optionButton.MouseEnter:Connect(function()
                if (multiSelect and not table.find(selectedOptions, option)) or 
                   (not multiSelect and option ~= selectedOption) then
                    createTween(optionButton, {BackgroundColor3 = Color3.fromRGB(50, 50, 65)}, 0.2)
                end
            end)

            optionButton.MouseLeave:Connect(function()
                if (multiSelect and not table.find(selectedOptions, option)) or 
                   (not multiSelect and option ~= selectedOption) then
                    createTween(optionButton, {BackgroundColor3 = colors.surface}, 0.2)
                end
            end)
            
            optionButton.MouseButton1Click:Connect(function()
                if multiSelect then
                    if table.find(selectedOptions, option) then
                        table.remove(selectedOptions, table.find(selectedOptions, option))
                        createTween(checkbox, {BackgroundColor3 = colors.surface}, 0.2)
                        checkIcon.Visible = false
                    else
                        table.insert(selectedOptions, option)
                        createTween(checkbox, {BackgroundColor3 = colors.primary}, 0.2)
                        checkIcon.Visible = true
                    end
                    
                    if #selectedOptions > 0 then
                        if #selectedOptions > 2 then
                            dropdownButton.Text = #selectedOptions .. " selected"
                        else
                            dropdownButton.Text = table.concat(selectedOptions, ", ")
                        end
                    else
                        dropdownButton.Text = "Select..."
                    end
                else
                    selectedOption = option
                    dropdownButton.Text = tostring(option)
                    toggleDropdown()
                    
                    for _, btn in ipairs(optionsFrame:GetChildren()) do
                        if btn:IsA("TextButton") then
                            createTween(btn, {BackgroundColor3 = colors.surface}, 0.2)
                        end
                    end
                    createTween(optionButton, {BackgroundColor3 = colors.primary}, 0.2)
                end
                
                if callback then
                    callback(multiSelect and selectedOptions or selectedOption)
                end
            end)
        end

        updateListSize()
    end

    local function toggleDropdown()
        isOpen = not isOpen
        
        if isOpen then
            createOptions(searchable and searchBox.Text or nil)
            dropdownList.Visible = true
            dropdownIcon.Text = "▲"
            createTween(dropdownButton, {BackgroundColor3 = colors.primary}, 0.2)
            
            dropdownList.Size = UDim2.new(0, 0, 0, 0)
            createTween(dropdownList, {
                Size = UDim2.new(0, dropdownList.Size.X.Offset, 0, dropdownList.Size.Y.Offset)
            }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            
            if not renderConnection then
                renderConnection = RunService.RenderStepped:Connect(updateDropdownPosition)
            end
            
            if searchable then
                wait(0.1)
                searchBox:CaptureFocus()
            end
        else
            createTween(dropdownButton, {BackgroundColor3 = Color3.fromRGB(45, 45, 60)}, 0.2)
            createTween(dropdownList, {
                Size = UDim2.new(0, 0, 0, 0)
            }, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            
            wait(0.2)
            dropdownList.Visible = false
            dropdownIcon.Text = "▼"
            
            if renderConnection then
                renderConnection:Disconnect()
                renderConnection = nil
            end
        end
    end

    if searchable then
        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            createOptions(searchBox.Text)
        end)
        
        searchBox.FocusLost:Connect(function()
            if isOpen then
                updateDropdownPosition()
            end
        end)
    end

    dropdownButton.MouseButton1Click:Connect(toggleDropdown)

    local function closeDropdown(input)
        if isOpen and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            local buttonPos = dropdownButton.AbsolutePosition
            local buttonSize = dropdownButton.AbsoluteSize
            local listPos = dropdownList.AbsolutePosition
            local listSize = dropdownList.AbsoluteSize
            
            local isClickInButton = mousePos.X >= buttonPos.X and mousePos.X <= buttonPos.X + buttonSize.X and
                                  mousePos.Y >= buttonPos.Y and mousePos.Y <= buttonPos.Y + buttonSize.Y
            local isClickInList = mousePos.X >= listPos.X and mousePos.X <= listPos.X + listSize.X and
                                mousePos.Y >= listPos.Y and mousePos.Y <= listPos.Y + listSize.Y
            
            if not isClickInButton and not isClickInList then
                toggleDropdown()
            end
        end
    end

    UserInputService.InputBegan:Connect(closeDropdown)

    if UserInputService.TouchEnabled then
        dropdownButton.Size = UDim2.new(0.4, 0, 1, 0)
        dropdownButton.Position = UDim2.new(0.6, 0, 0, 0)
        dropdownText.Size = UDim2.new(0.6, 0, 1, 0)
        dropdownButton.TextSize = 12
    end

    table.insert(tab.Elements, dropdownFrame)
    
    return {
        Frame = dropdownFrame,
        SetOptions = function(newOptions)
            options = newOptions or {}
            if isOpen then
                createOptions(searchable and searchBox.Text or nil)
            end
        end,
        GetSelected = function()
            return multiSelect and selectedOptions or selectedOption
        end,
        SetSelected = function(selection)
            if multiSelect then
                selectedOptions = selection or {}
                if #selectedOptions > 0 then
                    if #selectedOptions > 2 then
                        dropdownButton.Text = #selectedOptions .. " selected"
                    else
                        dropdownButton.Text = table.concat(selectedOptions, ", ")
                    end
                else
                    dropdownButton.Text = "Select..."
                end
            else
                selectedOption = selection
                dropdownButton.Text = tostring(selection or "Select...")
            end
        end,
        IsOpen = function() return isOpen end,
        Open = toggleDropdown,
        Close = function() if isOpen then toggleDropdown() end end
    }
end

function Library:AddMultiDropdown(tab, name, options, defaultOptions, callback, config)
    config = config or {}
    config.multiSelect = true
    config.searchable = config.searchable or true
    
    return self:AddDropdown(tab, name, options, defaultOptions, callback, config)
end

function Library:AddModernDropdown(tab, name, options, defaultOption, callback, config)
    config = config or {}
    config.searchable = config.searchable or true
    config.maxHeight = config.maxHeight or 250
    
    local dropdown = self:AddDropdown(tab, name, options, defaultOption, callback, config)
    
    local originalSetOptions = dropdown.SetOptions
    dropdown.SetOptions = function(newOptions)
        originalSetOptions(newOptions)
    end
    
    return dropdown
end

function Library:AddColorPicker(tab, name, defaultColor, callback, config)
    config = config or {}
    defaultColor = defaultColor or Color3.fromRGB(255, 0, 0)
    
    local colorPickerFrame = Instance.new("Frame")
    colorPickerFrame.Name = name .. "ColorPicker"
    colorPickerFrame.Size = UDim2.new(1, -20, 0, 40)
    colorPickerFrame.BackgroundTransparency = 1
    colorPickerFrame.Parent = tab.Content
    colorPickerFrame.LayoutOrder = #tab.Elements + 1
    colorPickerFrame.Visible = true
    colorPickerFrame.ZIndex = 3

    local colorPickerText = Instance.new("TextLabel")
    colorPickerText.Name = "Text"
    colorPickerText.Size = UDim2.new(0.7, 0, 1, 0)
    colorPickerText.Position = UDim2.new(0, 0, 0, 0)
    colorPickerText.BackgroundTransparency = 1
    colorPickerText.Text = name
    colorPickerText.TextColor3 = colors.text
    colorPickerText.TextSize = 14
    colorPickerText.Font = FONT_REGULAR
    colorPickerText.TextXAlignment = Enum.TextXAlignment.Left
    colorPickerText.Parent = colorPickerFrame
    colorPickerText.ZIndex = 4

    local colorButton = Instance.new("TextButton")
    colorButton.Name = "ColorButton"
    colorButton.Size = UDim2.new(0.1, 0, 0.6, 0)
    colorButton.Position = UDim2.new(0.8, 0, 0.2, 0)
    colorButton.BackgroundColor3 = defaultColor
    colorButton.BorderSizePixel = 0
    colorButton.Text = ""
    colorButton.AutoButtonColor = false
    colorButton.Parent = colorPickerFrame
    colorButton.ZIndex = 4

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = colorButton

    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    buttonStroke.Color = colors.textSecondary
    buttonStroke.Thickness = 1
    buttonStroke.Transparency = 0.5
    buttonStroke.Parent = colorButton

    local screenGui = self.ScreenGui or game.Players.LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("CustomLib")
    local currentColor = defaultColor
    local colorPickerPopup

    local function createColorPickerPopup()
        if colorPickerPopup and colorPickerPopup.Parent then
            colorPickerPopup:Destroy()
        end

        colorPickerPopup = Instance.new("Frame")
        colorPickerPopup.Name = "ColorPickerPopup"
        colorPickerPopup.Size = UDim2.new(0, 300, 0, 250)
        colorPickerPopup.BackgroundColor3 = colors.surface
        colorPickerPopup.BorderSizePixel = 0
        colorPickerPopup.ZIndex = 100
        colorPickerPopup.Parent = screenGui
        colorPickerPopup.ClipsDescendants = true

        local popupCorner = Instance.new("UICorner")
        popupCorner.CornerRadius = UDim.new(0, 8)
        popupCorner.Parent = colorPickerPopup

        local popupStroke = Instance.new("UIStroke")
        popupStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        popupStroke.Color = colors.primary
        popupStroke.Thickness = 2
        popupStroke.Transparency = 0.7
        popupStroke.Parent = colorPickerPopup

        local buttonPos = colorButton.AbsolutePosition
        local buttonSize = colorButton.AbsoluteSize
        local screenSize = screenGui.AbsoluteSize
        
        local positionX = buttonPos.X - 150 + buttonSize.X / 2
        local positionY = buttonPos.Y + buttonSize.Y + 5
        
        if positionX + 300 > screenSize.X then
            positionX = screenSize.X - 300 - 5
        end
        
        if positionY + 250 > screenSize.Y then
            positionY = buttonPos.Y - 250 - 5
        end
        
        colorPickerPopup.Position = UDim2.new(0, positionX, 0, positionY)

        local hueCircle = Instance.new("ImageLabel")
        hueCircle.Name = "HueCircle"
        hueCircle.Size = UDim2.new(0, 150, 0, 150)
        hueCircle.Position = UDim2.new(0, 10, 0, 10)
        hueCircle.BackgroundTransparency = 1
        hueCircle.Image = "rbxassetid://2610032323"
        hueCircle.ZIndex = 101
        hueCircle.Parent = colorPickerPopup

        local brightnessSlider = Instance.new("Frame")
        brightnessSlider.Name = "BrightnessSlider"
        brightnessSlider.Size = UDim2.new(0, 20, 0, 150)
        brightnessSlider.Position = UDim2.new(0, 170, 0, 10)
        brightnessSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        brightnessSlider.BorderSizePixel = 0
        brightnessSlider.ZIndex = 101
        brightnessSlider.Parent = colorPickerPopup

        local brightnessGradient = Instance.new("UIGradient")
        brightnessGradient.Rotation = 90
        brightnessGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
        }
        brightnessGradient.Parent = brightnessSlider

        local brightnessCorner = Instance.new("UICorner")
        brightnessCorner.CornerRadius = UDim.new(0, 4)
        brightnessCorner.Parent = brightnessSlider

        local saturationSlider = Instance.new("Frame")
        saturationSlider.Name = "SaturationSlider"
        saturationSlider.Size = UDim2.new(0, 20, 0, 150)
        saturationSlider.Position = UDim2.new(0, 200, 0, 10)
        saturationSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        saturationSlider.BorderSizePixel = 0
        saturationSlider.ZIndex = 101
        saturationSlider.Parent = colorPickerPopup

        local saturationCorner = Instance.new("UICorner")
        saturationCorner.CornerRadius = UDim.new(0, 4)
        saturationCorner.Parent = saturationSlider

        local colorPreview = Instance.new("Frame")
        colorPreview.Name = "ColorPreview"
        colorPreview.Size = UDim2.new(0, 80, 0, 30)
        colorPreview.Position = UDim2.new(0, 10, 0, 170)
        colorPreview.BackgroundColor3 = currentColor
        colorPreview.BorderSizePixel = 0
        colorPreview.ZIndex = 101
        colorPreview.Parent = colorPickerPopup

        local previewCorner = Instance.new("UICorner")
        previewCorner.CornerRadius = UDim.new(0, 4)
        previewCorner.Parent = colorPreview

        local previewStroke = Instance.new("UIStroke")
        previewStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        previewStroke.Color = colors.textSecondary
        previewStroke.Thickness = 1
        previewStroke.Parent = colorPreview

        local rgbInputFrame = Instance.new("Frame")
        rgbInputFrame.Name = "RGBInputFrame"
        rgbInputFrame.Size = UDim2.new(0, 80, 0, 100)
        rgbInputFrame.Position = UDim2.new(0, 100, 0, 170)
        rgbInputFrame.BackgroundTransparency = 1
        rgbInputFrame.ZIndex = 101
        rgbInputFrame.Parent = colorPickerPopup

        local function createRGBInput(yPos, label, value, max)
            local inputFrame = Instance.new("Frame")
            inputFrame.Size = UDim2.new(1, 0, 0, 25)
            inputFrame.Position = UDim2.new(0, 0, 0, yPos)
            inputFrame.BackgroundTransparency = 1
            inputFrame.ZIndex = 102
            inputFrame.Parent = rgbInputFrame

            local labelText = Instance.new("TextLabel")
            labelText.Size = UDim2.new(0, 20, 1, 0)
            labelText.Position = UDim2.new(0, 0, 0, 0)
            labelText.BackgroundTransparency = 1
            labelText.Text = label
            labelText.TextColor3 = colors.text
            labelText.TextSize = 12
            labelText.Font = FONT_REGULAR
            labelText.ZIndex = 103
            labelText.Parent = inputFrame

            local textBox = Instance.new("TextBox")
            textBox.Size = UDim2.new(0, 50, 1, 0)
            textBox.Position = UDim2.new(1, -50, 0, 0)
            textBox.BackgroundColor3 = colors.surface
            textBox.Text = tostring(math.floor(value * max))
            textBox.TextColor3 = colors.text
            textBox.TextSize = 12
            textBox.Font = FONT_REGULAR
            textBox.ZIndex = 103
            textBox.Parent = inputFrame

            local textBoxCorner = Instance.new("UICorner")
            textBoxCorner.CornerRadius = UDim.new(0, 4)
            textBoxCorner.Parent = textBox

            textBox.FocusLost:Connect(function()
                local num = tonumber(textBox.Text)
                if num then
                    num = math.clamp(num, 0, max)
                    textBox.Text = tostring(num)
                end
            end)

            return textBox
        end

        local rInput = createRGBInput(0, "R", currentColor.R, 255)
        local gInput = createRGBInput(30, "G", currentColor.G, 255)
        local bInput = createRGBInput(60, "B", currentColor.B, 255)

        local confirmButton = Instance.new("TextButton")
        confirmButton.Name = "ConfirmButton"
        confirmButton.Size = UDim2.new(0, 80, 0, 30)
        confirmButton.Position = UDim2.new(0, 190, 0, 210)
        confirmButton.BackgroundColor3 = colors.primary
        confirmButton.BorderSizePixel = 0
        confirmButton.Text = "OK"
        confirmButton.TextColor3 = colors.text
        confirmButton.TextSize = 14
        confirmButton.Font = FONT_REGULAR
        confirmButton.ZIndex = 101
        confirmButton.Parent = colorPickerPopup

        local confirmCorner = Instance.new("UICorner")
        confirmCorner.CornerRadius = UDim.new(0, 4)
        confirmCorner.Parent = confirmButton

        colorPickerPopup.Size = UDim2.new(0, 10, 0, 10)
        colorPickerPopup.BackgroundTransparency = 1
        
        createTween(colorPickerPopup, {
            Size = UDim2.new(0, 300, 0, 250),
            BackgroundTransparency = 0
        }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

        local function updateColor(newColor)
            currentColor = newColor
            colorButton.BackgroundColor3 = newColor
            colorPreview.BackgroundColor3 = newColor
            callback(newColor)
        end

        confirmButton.MouseButton1Click:Connect(function()
            createTween(colorPickerPopup, {
                Size = UDim2.new(0, 10, 0, 10),
                BackgroundTransparency = 1
            }, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            wait(0.2)
            colorPickerPopup:Destroy()
        end)

        local function closeColorPicker(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mousePos = input.Position
                local popupPos = colorPickerPopup.AbsolutePosition
                local popupSize = colorPickerPopup.AbsoluteSize
                
                local isClickInPopup = mousePos.X >= popupPos.X and mousePos.X <= popupPos.X + popupSize.X and
                                     mousePos.Y >= popupPos.Y and mousePos.Y <= popupPos.Y + popupSize.Y
                                     
                local isClickInButton = mousePos.X >= colorButton.AbsolutePosition.X and 
                                      mousePos.X <= colorButton.AbsolutePosition.X + colorButton.AbsoluteSize.X and
                                      mousePos.Y >= colorButton.AbsolutePosition.Y and 
                                      mousePos.Y <= colorButton.AbsolutePosition.Y + colorButton.AbsoluteSize.Y
                
                if not isClickInPopup and not isClickInButton then
                    createTween(colorPickerPopup, {
                        Size = UDim2.new(0, 10, 0, 10),
                        BackgroundTransparency = 1
                    }, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                    wait(0.2)
                    colorPickerPopup:Destroy()
                end
            end
        end

        UserInputService.InputBegan:Connect(closeColorPicker)
    end

    colorButton.MouseButton1Click:Connect(createColorPickerPopup)

    colorButton.MouseEnter:Connect(function()
        createTween(buttonStroke, {Thickness = 2}, 0.2)
        createTween(colorButton, {Size = UDim2.new(0.11, 0, 0.66, 0)}, 0.2)
    end)

    colorButton.MouseLeave:Connect(function()
        createTween(buttonStroke, {Thickness = 1}, 0.2)
        createTween(colorButton, {Size = UDim2.new(0.1, 0, 0.6, 0)}, 0.2)
    end)

    if UserInputService.TouchEnabled then
        colorButton.Size = UDim2.new(0.15, 0, 0.7, 0)
        colorButton.Position = UDim2.new(0.75, 0, 0.15, 0)
        colorPickerText.Size = UDim2.new(0.75, 0, 1, 0)
    end

    table.insert(tab.Elements, colorPickerFrame)
    
    return {
        Frame = colorPickerFrame,
        SetColor = function(color)
            currentColor = color
            colorButton.BackgroundColor3 = color
            callback(color)
        end,
        GetColor = function()
            return currentColor
        end
    }
end

function Library:AddCheckbox(tab, name, callback, config)
    config = config or {}
    local defaultState = config.default or false
    
    local checkboxFrame = Instance.new("Frame")
    checkboxFrame.Name = name
    checkboxFrame.Size = UDim2.new(1, -20, 0, 40)
    checkboxFrame.BackgroundTransparency = 1
    checkboxFrame.Parent = tab.Content
    checkboxFrame.LayoutOrder = #tab.Elements + 1
    checkboxFrame.Visible = true
    checkboxFrame.ZIndex = 3

    local checkboxText = Instance.new("TextLabel")
    checkboxText.Name = "Text"
    checkboxText.Size = UDim2.new(0.7, 0, 1, 0)
    checkboxText.Position = UDim2.new(0, 0, 0, 0)
    checkboxText.BackgroundTransparency = 1
    checkboxText.Text = name
    checkboxText.TextColor3 = colors.text
    checkboxText.TextSize = 14
    checkboxText.Font = FONT_REGULAR
    checkboxText.TextXAlignment = Enum.TextXAlignment.Left
    checkboxText.Parent = checkboxFrame
    checkboxText.ZIndex = 4

    local checkboxButton = Instance.new("TextButton")
    checkboxButton.Name = "Checkbox"
    checkboxButton.Size = UDim2.new(0, 25, 0, 25)
    checkboxButton.Position = UDim2.new(1, -25, 0.5, -12)
    checkboxButton.BackgroundColor3 = colors.surface
    checkboxButton.BorderSizePixel = 0
    checkboxButton.Text = ""
    checkboxButton.Parent = checkboxFrame
    checkboxButton.AutoButtonColor = false
    checkboxButton.ZIndex = 4

    local checkboxCorner = Instance.new("UICorner")
    checkboxCorner.CornerRadius = UDim.new(0, 6)
    checkboxCorner.Parent = checkboxButton

    local checkIcon = Instance.new("TextLabel")
    checkIcon.Name = "CheckIcon"
    checkIcon.Size = UDim2.new(1, 0, 1, 0)
    checkIcon.Position = UDim2.new(0, 0, 0, 0)
    checkIcon.BackgroundTransparency = 1
    checkIcon.Text = "✓"
    checkIcon.TextColor3 = colors.text
    checkIcon.TextSize = 16
    checkIcon.Font = FONT_REGULAR
    checkIcon.Visible = false
    checkIcon.Parent = checkboxButton
    checkIcon.ZIndex = 5

    local isChecked = defaultState

    local function updateCheckbox()
        if isChecked then
            createTween(checkboxButton, {BackgroundColor3 = colors.primary}, 0.3)
            checkIcon.Visible = true
            checkIcon.TextTransparency = 1
            createTween(checkIcon, {TextTransparency = 0}, 0.3)
        else
            createTween(checkboxButton, {BackgroundColor3 = colors.surface}, 0.3)
            createTween(checkIcon, {TextTransparency = 1}, 0.2)
            wait(0.2)
            checkIcon.Visible = false
        end
        callback(isChecked)
    end

    checkboxButton.MouseEnter:Connect(function()
        createTween(checkboxButton, {
            BackgroundColor3 = isChecked and Color3.fromRGB(110, 80, 210) or Color3.fromRGB(50, 50, 65)
        }, 0.2)
    end)

    checkboxButton.MouseLeave:Connect(function()
        createTween(checkboxButton, {
            BackgroundColor3 = isChecked and colors.primary or colors.surface
        }, 0.2)
    end)

    checkboxButton.MouseButton1Click:Connect(function()
        isChecked = not isChecked
        
        local ripple = Instance.new("Frame")
        ripple.Name = "Ripple"
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.BackgroundColor3 = isChecked and colors.primary or colors.textSecondary
        ripple.BackgroundTransparency = 0.7
        ripple.BorderSizePixel = 0
        ripple.ZIndex = 6
        ripple.Parent = checkboxButton
        
        local rippleCorner = Instance.new("UICorner")
        rippleCorner.CornerRadius = UDim.new(1, 0)
        rippleCorner.Parent = ripple
        
        createTween(ripple, {
            Size = UDim2.new(2, 0, 2, 0),
            BackgroundTransparency = 1
        }, 0.4):Wait()
        ripple:Destroy()
        
        updateCheckbox()
    end)

    updateCheckbox()

    table.insert(tab.Elements, checkboxFrame)
    
    return {
        Frame = checkboxFrame,
        SetChecked = function(state)
            isChecked = state
            updateCheckbox()
        end,
        GetChecked = function()
            return isChecked
        end
    }
end

function Library:AddInputText(tab, name, placeholder, callback, config)
    config = config or {}
    local defaultValue = config.default or ""
    local numericOnly = config.numeric or false
    local maxLength = config.maxLength or 50
    local password = config.password or false
    
    local inputFrame = Instance.new("Frame")
    inputFrame.Name = name .. "Input"
    inputFrame.Size = UDim2.new(1, -20, 0, 50)
    inputFrame.BackgroundTransparency = 1
    inputFrame.Parent = tab.Content
    inputFrame.LayoutOrder = #tab.Elements + 1
    inputFrame.ZIndex = 3

    local inputLabel = Instance.new("TextLabel")
    inputLabel.Name = "Label"
    inputLabel.Size = UDim2.new(1, 0, 0, 20)
    inputLabel.Position = UDim2.new(0, 0, 0, 0)
    inputLabel.BackgroundTransparency = 1
    inputLabel.Text = name
    inputLabel.TextColor3 = colors.text
    inputLabel.TextSize = 14
    inputLabel.Font = FONT_BOLD
    inputLabel.TextXAlignment = Enum.TextXAlignment.Left
    inputLabel.Parent = inputFrame
    inputLabel.ZIndex = 4

    local textBox = Instance.new("TextBox")
    textBox.Name = "InputBox"
    textBox.Size = UDim2.new(1, 0, 0, 30)
    textBox.Position = UDim2.new(0, 0, 0, 20)
    textBox.BackgroundColor3 = colors.surface
    textBox.BorderSizePixel = 0
    textBox.Text = defaultValue
    textBox.PlaceholderText = placeholder
    textBox.TextColor3 = colors.text
    textBox.PlaceholderColor3 = colors.textSecondary
    textBox.TextSize = 14
    textBox.Font = FONT_REGULAR
    textBox.ClearTextOnFocus = false
    textBox.ZIndex = 4
    textBox.Parent = inputFrame

    if password then
        textBox.TextTransparency = 0.5
    end

    local textBoxCorner = Instance.new("UICorner")
    textBoxCorner.CornerRadius = UDim.new(0, 8)
    textBoxCorner.Parent = textBox

    local textBoxPadding = Instance.new("UIPadding")
    textBoxPadding.PaddingLeft = UDim.new(0, 10)
    textBoxPadding.PaddingRight = UDim.new(0, 10)
    textBoxPadding.Parent = textBox

    local textBoxStroke = Instance.new("UIStroke")
    textBoxStroke.Color = colors.primary
    textBoxStroke.Thickness = 1
    textBoxStroke.Transparency = 0.7
    textBoxStroke.Parent = textBox

    textBox:GetPropertyChangedSignal("Text"):Connect(function()
        if numericOnly then
            local text = textBox.Text:gsub("[^%d]", "")
            if text ~= textBox.Text then
                textBox.Text = text
            end
        end
        
        if #textBox.Text > maxLength then
            textBox.Text = textBox.Text:sub(1, maxLength)
        end
    end)

    textBox.Focused:Connect(function()
        createTween(textBoxStroke, {Thickness = 2, Transparency = 0.3}, 0.2)
        createTween(textBox, {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}, 0.2)
    end)

    textBox.FocusLost:Connect(function()
        createTween(textBoxStroke, {Thickness = 1, Transparency = 0.7}, 0.2)
        createTween(textBox, {BackgroundColor3 = colors.surface}, 0.2)
        if callback then
            callback(textBox.Text)
        end
    end)

    table.insert(tab.Elements, inputFrame)
    
    return {
        Frame = inputFrame,
        SetText = function(text)
            textBox.Text = text
        end,
        GetText = function()
            return textBox.Text
        end,
        Clear = function()
            textBox.Text = ""
        end
    }
end

function Library:EnableRainbowCorners(speed)
    if self.RainbowCorners then return end
    
    self.RainbowCorners = true
    speed = speed or 1
    
    local hue = 0
    local corners = {}
    
    table.insert(corners, self.MainFrame:FindFirstChildOfClass("UICorner"))
    
    for _, tab in ipairs(self.Tabs) do
        if tab.Button:FindFirstChildOfClass("UICorner") then
            table.insert(corners, tab.Button:FindFirstChildOfClass("UICorner"))
        end
        
        for _, element in ipairs(tab.Elements) do
            local corner = element:FindFirstChildOfClass("UICorner")
            if corner then
                table.insert(corners, corner)
            end
        end
    end
    
    local connection
    connection = RunService.RenderStepped:Connect(function(delta)
        if not self.RainbowCorners then
            connection:Disconnect()
            return
        end
        
        hue = (hue + delta * 0.2 * speed) % 1
        local color = HSVToRGB(hue, 1, 1)
        
        for _, corner in ipairs(corners) do
            if corner then
                corner.CornerRadius = UDim.new(0, 8 + math.sin(tick() * 2 * speed) * 2)
            end
        end
        
        local stroke = self.MainFrame:FindFirstChildOfClass("UIStroke")
        if stroke then
            stroke.Color = color
        end
        
        for _, tab in ipairs(self.Tabs) do
            if currentTab == tab then
                tab.Highlight.BackgroundColor3 = color
            end
        end
    end)
    
    return connection
end

function Library:DisableRainbowCorners()
    self.RainbowCorners = false
    
    local corners = {}
    local mainCorner = self.MainFrame:FindFirstChildOfClass("UICorner")
    if mainCorner then
        mainCorner.CornerRadius = UDim.new(0, 12)
    end
    
    for _, tab in ipairs(self.Tabs) do
        local tabCorner = tab.Button:FindFirstChildOfClass("UICorner")
        if tabCorner then
            tabCorner.CornerRadius = UDim.new(0, 8)
        end
        
        for _, element in ipairs(tab.Elements) do
            local corner = element:FindFirstChildOfClass("UICorner")
            if corner then
                corner.CornerRadius = UDim.new(0, 8)
            end
        end
    end
    
    local stroke = self.MainFrame:FindFirstChildOfClass("UIStroke")
    if stroke then
        stroke.Color = colors.primary
    end
    
    for _, tab in ipairs(self.Tabs) do
        if currentTab == tab then
            tab.Highlight.BackgroundColor3 = colors.primary
        end
    end
end

function Library:CreateContextMenu(options, position)
    local screenGui = self.ScreenGui
    local contextMenu = Instance.new("Frame")
    contextMenu.Name = "ContextMenu"
    contextMenu.Size = UDim2.new(0, 150, 0, 0)
    contextMenu.BackgroundColor3 = colors.surface
    contextMenu.BorderSizePixel = 0
    contextMenu.ZIndex = 100
    contextMenu.Parent = screenGui
    
    local contextCorner = Instance.new("UICorner")
    contextCorner.CornerRadius = UDim.new(0, 6)
    contextCorner.Parent = contextMenu
    
    local contextStroke = Instance.new("UIStroke")
    contextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    contextStroke.Color = colors.primary
    contextStroke.Thickness = 2
    contextStroke.Transparency = 0.7
    contextStroke.Parent = contextMenu
    
    local contextLayout = Instance.new("UIListLayout")
    contextLayout.Parent = contextMenu
    contextLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local contextPadding = Instance.new("UIPadding")
    contextPadding.PaddingTop = UDim.new(0, 5)
    contextPadding.PaddingBottom = UDim.new(0, 5)
    contextPadding.Parent = contextMenu
    
    if position then
        contextMenu.Position = position
    else
        local mousePos = UserInputService:GetMouseLocation()
        contextMenu.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y)
    end
    
    for i, option in ipairs(options) do
        local menuItem = Instance.new("TextButton")
        menuItem.Name = option.Text or "MenuItem" .. i
        menuItem.Size = UDim2.new(1, -10, 0, 30)
        menuItem.Position = UDim2.new(0, 5, 0, 5 + (i-1) * 35)
        menuItem.BackgroundColor3 = colors.surface
        menuItem.BorderSizePixel = 0
        menuItem.Text = option.Text or "Option " .. i
        menuItem.TextColor3 = colors.text
        menuItem.TextSize = 14
        menuItem.Font = FONT_REGULAR
        menuItem.ZIndex = 101
        menuItem.AutoButtonColor = false
        menuItem.Parent = contextMenu
        
        local menuItemCorner = Instance.new("UICorner")
        menuItemCorner.CornerRadius = UDim.new(0, 4)
        menuItemCorner.Parent = menuItem
        
        menuItem.MouseEnter:Connect(function()
            createTween(menuItem, {BackgroundColor3 = Color3.fromRGB(50, 50, 65)}, 0.2)
        end)
        
        menuItem.MouseLeave:Connect(function()
            createTween(menuItem, {BackgroundColor3 = colors.surface}, 0.2)
        end)
        
        menuItem.MouseButton1Click:Connect(function()
            if option.Callback then
                option.Callback()
            end
            contextMenu:Destroy()
        end)
    end
    
    contextLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        contextMenu.Size = UDim2.new(0, 150, 0, contextLayout.AbsoluteContentSize.Y + 10)
    end)
    
    local function closeContextMenu(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            local menuPos = contextMenu.AbsolutePosition
            local menuSize = contextMenu.AbsoluteSize
            
            local isClickInsideMenu = mousePos.X >= menuPos.X and mousePos.X <= menuPos.X + menuSize.X and
                                    mousePos.Y >= menuPos.Y and mousePos.Y <= menuPos.Y + menuSize.Y
                                    
            if not isClickInsideMenu then
                contextMenu:Destroy()
                UserInputService.InputBegan:Disconnect(closeContextMenu)
            end
        end
    end
    
    UserInputService.InputBegan:Connect(closeContextMenu)
    
    contextMenu.Size = UDim2.new(0, 10, 0, 10)
    contextMenu.BackgroundTransparency = 1
    
    createTween(contextMenu, {
        Size = UDim2.new(0, 150, 0, contextLayout.AbsoluteContentSize.Y + 10),
        BackgroundTransparency = 0
    }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    return contextMenu
end

function Library:CreateTooltip(text, position)
    local screenGui = self.ScreenGui
    local tooltip = Instance.new("Frame")
    tooltip.Name = "Tooltip"
    tooltip.Size = UDim2.new(0, 0, 0, 0)
    tooltip.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    tooltip.BorderSizePixel = 0
    tooltip.ZIndex = 100
    tooltip.Parent = screenGui
    
    local tooltipCorner = Instance.new("UICorner")
    tooltipCorner.CornerRadius = UDim.new(0, 4)
    tooltipCorner.Parent = tooltip
    
    local tooltipText = Instance.new("TextLabel")
    tooltipText.Name = "TooltipText"
    tooltipText.Size = UDim2.new(1, -10, 1, -10)
    tooltipText.Position = UDim2.new(0, 5, 0, 5)
    tooltipText.BackgroundTransparency = 1
    tooltipText.Text = text
    tooltipText.TextColor3 = colors.text
    tooltipText.TextSize = 12
    tooltipText.Font = FONT_REGULAR
    tooltipText.TextXAlignment = Enum.TextXAlignment.Left
    tooltipText.TextYAlignment = Enum.TextYAlignment.Top
    tooltipText.TextWrapped = true
    tooltipText.ZIndex = 101
    tooltipText.Parent = tooltip
    
    local tooltipPadding = Instance.new("UIPadding")
    tooltipPadding.PaddingLeft = UDim.new(0, 5)
    tooltipPadding.PaddingRight = UDim.new(0, 5)
    tooltipPadding.Parent = tooltipText
    
    if position then
        tooltip.Position = position
    else
        local mousePos = UserInputService:GetMouseLocation()
        tooltip.Position = UDim2.new(0, mousePos.X + 10, 0, mousePos.Y + 10)
    end
    
    local textSize = TextService:GetTextSize(
        tooltipText.Text, tooltipText.TextSize, tooltipText.Font, Vector2.new(200, math.huge)
    )
    
    tooltip.Size = UDim2.new(0, textSize.X + 20, 0, textSize.Y + 10)
   
    tooltip.BackgroundTransparency = 1
    tooltipText.TextTransparency = 1
    
    createTween(tooltip, {BackgroundTransparency = 0}, 0.2)
    createTween(tooltipText, {TextTransparency = 0}, 0.2)
    
    return {
        Frame = tooltip,
        Update = function(newText)
            tooltipText.Text = newText
            local newTextSize = TextService:GetTextSize(
                newText, tooltipText.TextSize, tooltipText.Font, Vector2.new(200, math.huge)
            )
            tooltip.Size = UDim2.new(0, newTextSize.X + 20, 0, newTextSize.Y + 10)
        end,
        Destroy = function()
            createTween(tooltip, {BackgroundTransparency = 1}, 0.2)
            createTween(tooltipText, {TextTransparency = 1}, 0.2)
            wait(0.2)
            tooltip:Destroy()
        end
    }
end

function Library:CreateModal(title, content, buttons)
    local screenGui = self.ScreenGui
    local modal = Instance.new("Frame")
    modal.Name = "Modal"
    modal.Size = UDim2.new(0, 400, 0, 200)
    modal.Position = UDim2.new(0.5, -200, 0.5, -100)
    modal.AnchorPoint = Vector2.new(0.5, 0.5)
    modal.BackgroundColor3 = colors.surface
    modal.BorderSizePixel = 0
    modal.ZIndex = 100
    modal.Parent = screenGui
    
    local modalCorner = Instance.new("UICorner")
    modalCorner.CornerRadius = UDim.new(0, 12)
    modalCorner.Parent = modal
    
    local modalStroke = Instance.new("UIStroke")
    modalStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    modalStroke.Color = colors.primary
    modalStroke.Thickness = 2
    modalStroke.Transparency = 0.7
    modalStroke.Parent = modal
    
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = colors.background
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = 101
    titleBar.Parent = modal
    
    local titleText = Instance.new("TextLabel")
    titleText.Name = "TitleText"
    titleText.Size = UDim2.new(1, -40, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = title
    titleText.TextColor3 = colors.text
    titleText.TextSize = 16
    titleText.Font = FONT_BOLD
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.ZIndex = 102
    titleText.Parent = titleBar
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 1, 0)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "×"
    closeButton.TextColor3 = colors.textSecondary
    closeButton.TextSize = 18
    closeButton.Font = FONT_REGULAR
    closeButton.ZIndex = 102
    closeButton.Parent = titleBar
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -20, 1, -70)
    contentFrame.Position = UDim2.new(0, 10, 0, 35)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ZIndex = 101
    contentFrame.Parent = modal
    
    if type(content) == "string" then
        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "ContentText"
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.Position = UDim2.new(0, 0, 0, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = content
        textLabel.TextColor3 = colors.text
        textLabel.TextSize = 14
        textLabel.Font = FONT_REGULAR
        textLabel.TextWrapped = true
        textLabel.ZIndex = 102
        textLabel.Parent = contentFrame
    elseif type(content) == "function" then
        content(contentFrame)
    end
    
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Name = "ButtonContainer"
    buttonContainer.Size = UDim2.new(1, -20, 0, 30)
    buttonContainer.Position = UDim2.new(0, 10, 1, -35)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.ZIndex = 101
    buttonContainer.Parent = modal
    
    local buttonLayout = Instance.new("UIListLayout")
    buttonLayout.Parent = buttonContainer
    buttonLayout.FillDirection = Enum.FillDirection.Horizontal
    buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    buttonLayout.SortOrder = Enum.SortOrder.LayoutOrder
    buttonLayout.Padding = UDim.new(0, 10)
    
    for i, buttonConfig in ipairs(buttons or {}) do
        local button = Instance.new("TextButton")
        button.Name = buttonConfig.Text or "Button" .. i
        button.Size = UDim2.new(0, 80, 1, 0)
        button.BackgroundColor3 = buttonConfig.Color or colors.primary
        button.BorderSizePixel = 0
        button.Text = buttonConfig.Text or "Button " .. i
        button.TextColor3 = colors.text
        button.TextSize = 14
        button.Font = FONT_REGULAR
        button.ZIndex = 102
        button.AutoButtonColor = false
        button.LayoutOrder = i
        button.Parent = buttonContainer
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = button
        
        button.MouseEnter:Connect(function()
            createTween(button, {BackgroundColor3 = Color3.fromRGB(
                math.min(buttonConfig.Color.R * 255 + 20, 255) / 255,
                math.min(buttonConfig.Color.G * 255 + 20, 255) / 255,
                math.min(buttonConfig.Color.B * 255 + 20, 255) / 255
            )}, 0.2)
        end)
        
        button.MouseLeave:Connect(function()
            createTween(button, {BackgroundColor3 = buttonConfig.Color or colors.primary}, 0.2)
        end)
        
        button.MouseButton1Click:Connect(function()
            if buttonConfig.Callback then
                buttonConfig.Callback()
            end
            modal:Destroy()
        end)
    end
    
    modal.Size = UDim2.new(0, 10, 0, 10)
    modal.BackgroundTransparency = 1
    modal.Visible = true
    
    createTween(modal, {
        Size = UDim2.new(0, 400, 0, 200),
        BackgroundTransparency = 0
    }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    closeButton.MouseButton1Click:Connect(function()
        modal:Destroy()
    end)
    
    return {
        Frame = modal,
        Destroy = function()
            createTween(modal, {
                Size = UDim2.new(0, 10, 0, 10),
                BackgroundTransparency = 1
            }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            wait(0.3)
            modal:Destroy()
        end
    }
end

function Library:AddCard(tab, title, content, config)
    config = config or {}
    
    local card = Instance.new("Frame")
    card.Name = "Card_" .. title
    card.Size = UDim2.new(1, -20, 0, config.height or 120)
    card.BackgroundColor3 = colors.surface
    card.BorderSizePixel = 0
    card.Parent = tab.Content
    card.LayoutOrder = #tab.Elements + 1

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Color = colors.primary
    stroke.Thickness = 1
    stroke.Transparency = 0.7
    stroke.Parent = card

    local titleContainer = Instance.new("Frame")
    titleContainer.Size = UDim2.new(1, -20, 0, 30)
    titleContainer.Position = UDim2.new(0, 10, 0, 10)
    titleContainer.BackgroundTransparency = 1
    titleContainer.Parent = card

    local avatarFrame = Instance.new("Frame")
    avatarFrame.Size = UDim2.new(0, 30, 0, 30)
    avatarFrame.BackgroundTransparency = 1
    avatarFrame.Parent = titleContainer

    local avatarImage = Instance.new("ImageLabel")
    avatarImage.Size = UDim2.new(1, 0, 1, 0)
    avatarImage.BackgroundColor3 = colors.surface
    avatarImage.BorderSizePixel = 0
    avatarImage.Parent = avatarFrame

    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(0, 6)
    avatarCorner.Parent = avatarImage

    spawn(function()
        local player = game:GetService("Players").LocalPlayer
        local success, result = pcall(function()
            return game:GetService("Players"):GetUserThumbnailAsync(
                player.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size100x100
            )
        end)
        
        if success and result then
            avatarImage.Image = result
        else
            avatarImage.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
        end
    end)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -40, 1, 0)
    titleLabel.Position = UDim2.new(0, 40, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = colors.text
    titleLabel.TextSize = 16
    titleLabel.Font = FONT_BOLD
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleContainer

    local contentLabel = Instance.new("TextLabel")
    contentLabel.Size = UDim2.new(1, -20, 1, -50)
    contentLabel.Position = UDim2.new(0, 10, 0, 40)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = content
    contentLabel.TextColor3 = colors.textSecondary
    contentLabel.TextSize = 14
    contentLabel.Font = FONT_REGULAR
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextYAlignment = Enum.TextYAlignment.Top
    contentLabel.TextWrapped = true
    contentLabel.Parent = card

    if config.iconPlayerId then
        spawn(function()
            local success, result = pcall(function()
                return game:GetService("Players"):GetUserThumbnailAsync(
                    config.iconPlayerId,
                    Enum.ThumbnailType.HeadShot,
                    Enum.ThumbnailSize.Size100x100
                )
            end)
            
            if success and result then
                avatarImage.Image = result
            end
        end)
    elseif config.iconImage then
        avatarImage.Image = config.iconImage
    end

    card.MouseEnter:Connect(function()
        createTween(card, {BackgroundColor3 = Color3.fromRGB(35, 35, 50)}, 0.3)
        createTween(stroke, {Thickness = 2, Transparency = 0.3}, 0.3)
    end)

    card.MouseLeave:Connect(function()
        createTween(card, {BackgroundColor3 = colors.surface}, 0.3)
        createTween(stroke, {Thickness = 1, Transparency = 0.7}, 0.3)
    end)

    table.insert(tab.Elements, card)
    
    return {
        Frame = card,
        UpdateAvatar = function(userId)
            spawn(function()
                local success, result = pcall(function()
                    return game:GetService("Players"):GetUserThumbnailAsync(
                        userId,
                        Enum.ThumbnailType.HeadShot,
                        Enum.ThumbnailSize.Size100x100
                    )
                end)
                
                if success and result then
                    avatarImage.Image = result
                end
            end)
        end,
        UpdateTitle = function(newTitle)
            titleLabel.Text = newTitle
        end,
        UpdateContent = function(newContent)
            contentLabel.Text = newContent
        end,
        SetIcon = function(imageUrl)
            avatarImage.Image = imageUrl
        end
    }
end

function Library:AddProgressBar(tab, name, min, max, defaultValue, callback, config)
    config = config or {}
    
    local progressFrame = Instance.new("Frame")
    progressFrame.Name = name .. "Progress"
    progressFrame.Size = UDim2.new(1, -20, 0, 60)
    progressFrame.BackgroundTransparency = 1
    progressFrame.Parent = tab.Content
    progressFrame.LayoutOrder = #tab.Elements + 1

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = colors.text
    label.TextSize = 14
    label.Font = FONT_BOLD
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = progressFrame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 8)
    track.Position = UDim2.new(0, 0, 0, 30)
    track.BackgroundColor3 = colors.surface
    track.BorderSizePixel = 0
    track.Parent = progressFrame

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = colors.primary
    fill.BorderSizePixel = 0
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 60, 0, 20)
    valueLabel.Position = UDim2.new(1, -60, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = defaultValue .. "/" .. max
    valueLabel.TextColor3 = colors.textSecondary
    valueLabel.TextSize = 12
    valueLabel.Font = FONT_REGULAR
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = progressFrame

    local progress = {
        Frame = progressFrame,
        SetValue = function(value)
            value = math.clamp(value, min, max)
            springTween(fill, {Size = UDim2.new((value - min) / (max - min), 0, 1, 0)}, 6)
            valueLabel.Text = value .. "/" .. max
            if callback then callback(value) end
        end
    }

    table.insert(tab.Elements, progressFrame)
    return progress
end

function Library:AddWheelSelector(tab, name, options, defaultOption, callback, config)
    config = config or {}
    
    local wheelFrame = Instance.new("Frame")
    wheelFrame.Name = name .. "Wheel"
    wheelFrame.Size = UDim2.new(1, -20, 0, 150)
    wheelFrame.BackgroundTransparency = 1
    wheelFrame.Parent = tab.Content
    wheelFrame.LayoutOrder = #tab.Elements + 1

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = colors.text
    label.TextSize = 14
    label.Font = FONT_BOLD
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = wheelFrame

    local wheel = Instance.new("Frame")
    wheel.Size = UDim2.new(1, 0, 0, 120)
    wheel.Position = UDim2.new(0, 0, 0, 25)
    wheel.BackgroundColor3 = colors.surface
    wheel.BorderSizePixel = 0
    wheel.Parent = wheelFrame

    local wheelCorner = Instance.new("UICorner")
    wheelCorner.CornerRadius = UDim.new(0, 12)
    wheelCorner.Parent = wheel

    local selectedOption = defaultOption or options[1]
    local optionButtons = {}

    for i, option in ipairs(options) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -20, 0, 30)
        button.Position = UDim2.new(0, 10, 0, 10 + (i-1) * 35)
        button.BackgroundColor3 = option == selectedOption and colors.primary or colors.surface
        button.BorderSizePixel = 0
        button.Text = option
        button.TextColor3 = colors.text
        button.TextSize = 13
        button.Font = FONT_REGULAR
        button.Parent = wheel

        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = button

        button.MouseButton1Click:Connect(function()
            selectedOption = option
            for _, btn in ipairs(optionButtons) do
                springTween(btn, {BackgroundColor3 = colors.surface}, 8)
            end
            springTween(button, {BackgroundColor3 = colors.primary}, 8)
            if callback then callback(option) end
        end)

        table.insert(optionButtons, button)
    end

    local wheelSelector = {
        Frame = wheelFrame,
        GetSelected = function() return selectedOption end,
        SetSelected = function(option)
            selectedOption = option
            for i, btn in ipairs(optionButtons) do
                if options[i] == option then
                    springTween(btn, {BackgroundColor3 = colors.primary}, 8)
                else
                    springTween(btn, {BackgroundColor3 = colors.surface}, 8)
                end
            end
        end
    }

    table.insert(tab.Elements, wheelFrame)
    return wheelSelector
end

function Library:AddDivider(tab, config)
    config = config or {}
    
    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.Size = UDim2.new(1, -20, 0, 2)
    divider.BackgroundColor3 = colors.primary
    divider.BackgroundTransparency = 0.3
    divider.BorderSizePixel = 0
    divider.Parent = tab.Content
    divider.LayoutOrder = #tab.Elements + 1

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, colors.primary),
        ColorSequenceKeypoint.new(0.5, colors.secondary),
        ColorSequenceKeypoint.new(1, colors.primary)
    })
    gradient.Rotation = 45
    gradient.Parent = divider

    table.insert(tab.Elements, divider)
    return divider
end

function Library:AddStatusWidget(tab, title, value, icon, config)
    config = config or {}
    
    local widget = Instance.new("Frame")
    widget.Name = "Status_" .. title
    widget.Size = UDim2.new(1, -20, 0, 80)
    widget.BackgroundColor3 = colors.surface
    widget.BorderSizePixel = 0
    widget.Parent = tab.Content
    widget.LayoutOrder = #tab.Elements + 1

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = widget

    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 40, 0, 40)
    iconLabel.Position = UDim2.new(0, 15, 0.5, -20)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon or icons.Info
    iconLabel.TextColor3 = colors.primary
    iconLabel.TextSize = 24
    iconLabel.Font = FONT_REGULAR
    iconLabel.Parent = widget

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -70, 0, 20)
    titleLabel.Position = UDim2.new(0, 60, 0, 20)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = colors.textSecondary
    titleLabel.TextSize = 12
    titleLabel.Font = FONT_REGULAR
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = widget

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(1, -70, 0, 30)
    valueLabel.Position = UDim2.new(0, 60, 0, 40)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(value)
    valueLabel.TextColor3 = colors.text
    valueLabel.TextSize = 18
    valueLabel.Font = FONT_BOLD
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left
    valueLabel.Parent = widget

    local statusWidget = {
        Frame = widget,
        Update = function(newValue, newIcon)
            valueLabel.Text = tostring(newValue)
            if newIcon then
                iconLabel.Text = newIcon
            end
        end
    }

    table.insert(tab.Elements, widget)
    return statusWidget
end

function Library:ShowNotification(title, message, duration, type)
    duration = duration or 5
    type = type or "info"
    
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 350, 0, 80)
    notification.Position = UDim2.new(1, 400, 0, 20)
    notification.BackgroundColor3 = colors.surface
    notification.BorderSizePixel = 0
    notification.ZIndex = 1000
    notification.Parent = self.ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = notification

    local stroke = Instance.new("UIStroke")
    stroke.Color = colors[type] or colors.primary
    stroke.Thickness = 2
    stroke.Parent = notification

    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 40, 1, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icons[type] or icons.Info
    iconLabel.TextColor3 = colors[type] or colors.primary
    iconLabel.TextSize = 20
    iconLabel.Font = FONT_REGULAR
    iconLabel.Parent = notification

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -50, 0, 25)
    titleLabel.Position = UDim2.new(0, 45, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = colors.text
    titleLabel.TextSize = 16
    titleLabel.Font = FONT_BOLD
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notification

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -50, 0, 35)
    messageLabel.Position = UDim2.new(0, 45, 0, 35)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = colors.textSecondary
    messageLabel.TextSize = 13
    messageLabel.Font = FONT_REGULAR
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.Parent = notification

    createTween(notification, {
        Position = UDim2.new(1, -370, 0, 20)
    }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    delay(duration, function()
        createTween(notification, {
            Position = UDim2.new(1, 400, 0, 20)
        }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        
        wait(0.5)
        notification:Destroy()
    end)

    return notification
end

return Library
