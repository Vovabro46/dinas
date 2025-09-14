-- Modern Menu Library with InputText, ColorPicker and DropDown
local ModernMenu = {}

function ModernMenu:CreateMenu()
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer

    -- Root GUI
    local gui = Instance.new("ScreenGui")
    gui.Name = "ModernCustomMenu"
    gui.ResetOnSpawn = false
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- ---------- Reopen floating button (iOS style) ----------
    local reopenBtn = Instance.new("ImageButton")
    reopenBtn.Name = "ReopenButton"
    reopenBtn.Size = UDim2.new(0, 56, 0, 56)
    reopenBtn.AnchorPoint = Vector2.new(1, 1)
    reopenBtn.Position = UDim2.new(1, -28, 1, -28)
    reopenBtn.BackgroundTransparency = 0
    reopenBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    reopenBtn.BackgroundTransparency = 0.9
    reopenBtn.Image = ""
    reopenBtn.Visible = false
    reopenBtn.Parent = gui
    local reopenCorner = Instance.new("UICorner", reopenBtn)
    reopenCorner.CornerRadius = UDim.new(1, 0)

    local reopenShadow = Instance.new("ImageLabel")
    reopenShadow.Name = "Shadow"
    reopenShadow.Size = UDim2.new(1, 20, 1, 20)
    reopenShadow.Position = UDim2.new(0, -10, 0, -10)
    reopenShadow.BackgroundTransparency = 1
    reopenShadow.Image = "rbxassetid://5028857084"
    reopenShadow.ImageColor3 = Color3.new(0,0,0)
    reopenShadow.ImageTransparency = 0.65
    reopenShadow.ScaleType = Enum.ScaleType.Slice
    reopenShadow.SliceCenter = Rect.new(24,24,276,276)
    reopenShadow.ZIndex = 0
    reopenShadow.Parent = reopenBtn

    local reopenIcon = Instance.new("TextLabel")
    reopenIcon.Size = UDim2.new(1,0,1,0)
    reopenIcon.BackgroundTransparency = 1
    reopenIcon.Text = "≡"
    reopenIcon.Font = Enum.Font.GothamBold
    reopenIcon.TextSize = 24
    reopenIcon.TextColor3 = Color3.fromRGB(30,30,40)
    reopenIcon.Parent = reopenBtn

    -- ---------- Main menu container ----------
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 360, 0, 520)
    mainFrame.Position = UDim2.new(0.5, -180, 0.5, -260)
    mainFrame.AnchorPoint = Vector2.new(0,0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(28,30,38)
    mainFrame.BackgroundTransparency = 0
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = gui
    local mainCorner = Instance.new("UICorner", mainFrame)
    mainCorner.CornerRadius = UDim.new(0, 16)

    local mainShadow = Instance.new("ImageLabel", mainFrame)
    mainShadow.Name = "Shadow"
    mainShadow.Size = UDim2.new(1, 40, 1, 40)
    mainShadow.Position = UDim2.new(0, -20, 0, -20)
    mainShadow.BackgroundTransparency = 1
    mainShadow.Image = "rbxassetid://5028857084"
    mainShadow.ImageColor3 = Color3.new(0,0,0)
    mainShadow.ImageTransparency = 0.45
    mainShadow.ScaleType = Enum.ScaleType.Slice
    mainShadow.SliceCenter = Rect.new(24,24,276,276)
    mainShadow.ZIndex = 0

    local titleBar = Instance.new("Frame", mainFrame)
    titleBar.Size = UDim2.new(1, 0, 0, 56)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundTransparency = 1

    local titleLabel = Instance.new("TextLabel", titleBar)
    titleLabel.Size = UDim2.new(1, -72, 1, 0)
    titleLabel.Position = UDim2.new(0, 16, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 20
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextColor3 = Color3.fromRGB(230,235,255)
    titleLabel.Text = "Settings"

    local closeBtn = Instance.new("ImageButton", titleBar)
    closeBtn.Size = UDim2.new(0, 44, 0, 44)
    closeBtn.Position = UDim2.new(1, -56, 0.5, -22)
    closeBtn.BackgroundTransparency = 0
    closeBtn.Image = ""
    closeBtn.BackgroundColor3 = Color3.fromRGB(255,80,80)
    closeBtn.AutoButtonColor = false
    local closeCorner = Instance.new("UICorner", closeBtn)
    closeCorner.CornerRadius = UDim.new(1, 0)
    local closeX = Instance.new("TextLabel", closeBtn)
    closeX.Size = UDim2.new(1,0,1,0)
    closeX.BackgroundTransparency = 1
    closeX.Text = "✕"
    closeX.Font = Enum.Font.GothamBold
    closeX.TextSize = 22
    closeX.TextColor3 = Color3.fromRGB(255,255,255)

    local scrollFrame = Instance.new("ScrollingFrame", mainFrame)
    scrollFrame.Name = "ScrollArea"
    scrollFrame.Size = UDim2.new(1, -32, 1, -96)
    scrollFrame.Position = UDim2.new(0,16,0,72)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.CanvasSize = UDim2.new(0,0,0,0)
    local uiList = Instance.new("UIListLayout", scrollFrame)
    uiList.Padding = UDim.new(0, 12)
    uiList.HorizontalAlignment = Enum.HorizontalAlignment.Left
    uiList.SortOrder = Enum.SortOrder.LayoutOrder

    uiList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, uiList.AbsoluteContentSize.Y + 12)
    end)

    -- UI factory functions
    local function createSection(titleText)
        local container = Instance.new("Frame", scrollFrame)
        container.Size = UDim2.new(1, 0, 0, 28)
        container.BackgroundTransparency = 1
        container.LayoutOrder = #scrollFrame:GetChildren()
        
        local lbl = Instance.new("TextLabel", container)
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 18
        lbl.Text = titleText
        lbl.TextColor3 = Color3.fromRGB(170,190,255)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Position = UDim2.new(0, 6, 0, 0)
        
        return container
    end

    local function createDivider()
        local d = Instance.new("Frame", scrollFrame)
        d.Size = UDim2.new(1, 0, 0, 8)
        d.BackgroundTransparency = 1
        d.LayoutOrder = #scrollFrame:GetChildren()
        
        local line = Instance.new("Frame", d)
        line.Size = UDim2.new(1, -40, 0, 2)
        line.Position = UDim2.new(0, 20, 0.5, -1)
        line.AnchorPoint = Vector2.new(0,0.5)
        line.BackgroundColor3 = Color3.fromRGB(55,60,80)
        line.BorderSizePixel = 0
        local lineCorner = Instance.new("UICorner", line)
        lineCorner.CornerRadius = UDim.new(1,0)
        
        return d
    end

    local function createCheckbox(text, initial)
        initial = initial or false
        local row = Instance.new("Frame", scrollFrame)
        row.Size = UDim2.new(1, 0, 0, 44)
        row.BackgroundTransparency = 1
        row.LayoutOrder = #scrollFrame:GetChildren()

        local label = Instance.new("TextLabel", row)
        label.Size = UDim2.new(0.74, 0, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.TextSize = 16
        label.Text = text
        label.TextColor3 = Color3.fromRGB(235,235,240)
        label.TextXAlignment = Enum.TextXAlignment.Left

        local box = Instance.new("ImageButton", row)
        box.Size = UDim2.new(0, 34, 0, 34)
        box.Position = UDim2.new(1, -46, 0.5, -17)
        box.BackgroundTransparency = 0
        box.AutoButtonColor = false
        box.BackgroundColor3 = Color3.fromRGB(60,64,80)
        box.Image = ""
        local boxCorner = Instance.new("UICorner", box)
        boxCorner.CornerRadius = UDim.new(0,8)

        local mark = Instance.new("TextLabel", box)
        mark.Size = UDim2.new(1,0,1,0)
        mark.BackgroundTransparency = 1
        mark.Font = Enum.Font.GothamBold
        mark.TextSize = 18
        mark.TextColor3 = Color3.fromRGB(255,255,255)
        mark.Text = initial and "✔" or ""
        mark.TextTransparency = initial and 0 or 1

        local state = initial
        local changedEvent = Instance.new("BindableEvent")
        
        local function setState(v)
            state = v
            if state then
                TweenService:Create(box, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(0,180,140)}):Play()
                mark.Text = "✔"
                TweenService:Create(mark, TweenInfo.new(0.18), {TextTransparency = 0}):Play()
            else
                TweenService:Create(box, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(60,64,80)}):Play()
                TweenService:Create(mark, TweenInfo.new(0.18), {TextTransparency = 1}):Play()
            end
            changedEvent:Fire(state)
        end

        box.MouseButton1Click:Connect(function()
            setState(not state)
        end)

        box.MouseEnter:Connect(function()
            TweenService:Create(box, TweenInfo.new(0.12), {BackgroundColor3 = state and Color3.fromRGB(0,200,150) or Color3.fromRGB(80,85,100)}):Play()
        end)
        
        box.MouseLeave:Connect(function()
            TweenService:Create(box, TweenInfo.new(0.12), {BackgroundColor3 = state and Color3.fromRGB(0,180,140) or Color3.fromRGB(60,64,80)}):Play()
        end)

        return {
            get = function() return state end,
            set = setState,
            Changed = changedEvent.Event
        }
    end

    local function createToggle(text, initial)
        initial = initial or false
        local row = Instance.new("Frame", scrollFrame)
        row.Size = UDim2.new(1, 0, 0, 44)
        row.BackgroundTransparency = 1
        row.LayoutOrder = #scrollFrame:GetChildren()

        local label = Instance.new("TextLabel", row)
        label.Size = UDim2.new(0.66, 0, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.TextSize = 16
        label.Text = text
        label.TextColor3 = Color3.fromRGB(235,235,240)
        label.TextXAlignment = Enum.TextXAlignment.Left

        local togg = Instance.new("Frame", row)
        togg.Size = UDim2.new(0, 58, 0, 30)
        togg.Position = UDim2.new(1, -76, 0.5, -15)
        togg.BackgroundColor3 = initial and Color3.fromRGB(0,180,140) or Color3.fromRGB(70,75,90)
        togg.BorderSizePixel = 0
        local toggCorner = Instance.new("UICorner", togg)
        toggCorner.CornerRadius = UDim.new(1,0)

        local knob = Instance.new("Frame", togg)
        knob.Size = UDim2.new(0, 26, 0, 26)
        knob.Position = initial and UDim2.new(1, -28, 0.5, -13) or UDim2.new(0, 2, 0.5, -13)
        knob.BackgroundColor3 = Color3.fromRGB(250,250,250)
        local knobCorner = Instance.new("UICorner", knob)
        knobCorner.CornerRadius = UDim.new(1,0)

        local state = initial
        local changedEvent = Instance.new("BindableEvent")

        local function setState(s, instant)
            state = s
            if instant then
                knob.Position = state and UDim2.new(1, -28, 0.5, -13) or UDim2.new(0, 2, 0.5, -13)
                togg.BackgroundColor3 = state and Color3.fromRGB(0,180,140) or Color3.fromRGB(70,75,90)
            else
                TweenService:Create(knob, TweenInfo.new(0.18), {Position = state and UDim2.new(1, -28, 0.5, -13) or UDim2.new(0, 2, 0.5, -13)}):Play()
                TweenService:Create(togg, TweenInfo.new(0.18), {BackgroundColor3 = state and Color3.fromRGB(0,180,140) or Color3.fromRGB(70,75,90)}):Play()
            end
            changedEvent:Fire(state)
        end

        togg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                setState(not state)
            end
        end)

        return {
            get = function() return state end,
            set = setState,
            Changed = changedEvent.Event
        }
    end

    local function createSlider(text, minVal, maxVal, defaultVal)
        minVal = minVal or 0
        maxVal = maxVal or 100
        defaultVal = defaultVal or minVal

        local row = Instance.new("Frame", scrollFrame)
        row.Size = UDim2.new(1, 0, 0, 56)
        row.BackgroundTransparency = 1
        row.LayoutOrder = #scrollFrame:GetChildren()

        local label = Instance.new("TextLabel", row)
        label.Size = UDim2.new(1, 0, 0, 20)
        label.Position = UDim2.new(0,12,0,0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.TextSize = 15
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextColor3 = Color3.fromRGB(230,230,235)
        label.Text = text .. ": " .. tostring(defaultVal)

        local bar = Instance.new("Frame", row)
        bar.Size = UDim2.new(1, -24, 0, 8)
        bar.Position = UDim2.new(0,12,0,32)
        bar.BackgroundColor3 = Color3.fromRGB(60,64,80)
        bar.BorderSizePixel = 0
        local barCorner = Instance.new("UICorner", bar)
        barCorner.CornerRadius = UDim.new(1,0)

        local fill = Instance.new("Frame", bar)
        local startScale = (defaultVal - minVal) / (maxVal - minVal)
        fill.Size = UDim2.new(startScale, 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0,170,255)
        local fillCorner = Instance.new("UICorner", fill)
        fillCorner.CornerRadius = UDim.new(1,0)

        local knob = Instance.new("Frame", bar)
        knob.Size = UDim2.new(0, 20, 0, 20)
        knob.Position = UDim2.new(startScale, -10, 0.5, -10)
        knob.BackgroundColor3 = Color3.fromRGB(250,250,250)
        knob.BorderSizePixel = 0
        local knobCorner = Instance.new("UICorner", knob)
        knobCorner.CornerRadius = UDim.new(1,0)

        local dragging = false
        local currentValue = defaultVal
        local changedEvent = Instance.new("BindableEvent")

        local function updateFromInput(inputPosX)
            local barX = bar.AbsolutePosition.X
            local barW = bar.AbsoluteSize.X
            local t = math.clamp((inputPosX - barX) / barW, 0, 1)
            fill.Size = UDim2.new(t, 0, 1, 0)
            knob.Position = UDim2.new(t, -10, 0.5, -10)
            local value = math.floor(minVal + (maxVal - minVal) * t + 0.5)
            currentValue = value
            label.Text = text .. ": " .. tostring(value)
            changedEvent:Fire(value)
        end

        knob.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
            end
        end)
        
        knob.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                updateFromInput(input.Position.X)
                dragging = true
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateFromInput(input.Position.X)
            end
        end)

        return {
            get = function() return currentValue end,
            set = function(v)
                local t = math.clamp((v - minVal) / (maxVal - minVal), 0, 1)
                fill.Size = UDim2.new(t, 0, 1, 0)
                knob.Position = UDim2.new(t, -10, 0.5, -10)
                currentValue = math.floor(v + 0.5)
                label.Text = text .. ": " .. tostring(currentValue)
                changedEvent:Fire(currentValue)
            end,
            Changed = changedEvent.Event
        }
    end

    -- NEW: InputText element
    local function createInputText(text, placeholder, defaultText)
        defaultText = defaultText or ""
        placeholder = placeholder or ""

        local row = Instance.new("Frame", scrollFrame)
        row.Size = UDim2.new(1, 0, 0, 60)
        row.BackgroundTransparency = 1
        row.LayoutOrder = #scrollFrame:GetChildren()

        local label = Instance.new("TextLabel", row)
        label.Size = UDim2.new(1, -24, 0, 20)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.TextSize = 16
        label.Text = text
        label.TextColor3 = Color3.fromRGB(235,235,240)
        label.TextXAlignment = Enum.TextXAlignment.Left

        local inputFrame = Instance.new("Frame", row)
        inputFrame.Size = UDim2.new(1, -24, 0, 36)
        inputFrame.Position = UDim2.new(0, 12, 0, 24)
        inputFrame.BackgroundColor3 = Color3.fromRGB(60,64,80)
        inputFrame.BorderSizePixel = 0
        local inputCorner = Instance.new("UICorner", inputFrame)
        inputCorner.CornerRadius = UDim.new(0, 8)

        local textBox = Instance.new("TextBox", inputFrame)
        textBox.Size = UDim2.new(1, -16, 1, -8)
        textBox.Position = UDim2.new(0, 8, 0, 4)
        textBox.BackgroundTransparency = 1
        textBox.Font = Enum.Font.Gotham
        textBox.TextSize = 16
        textBox.TextColor3 = Color3.fromRGB(235,235,240)
        textBox.Text = defaultText
        textBox.PlaceholderText = placeholder
        textBox.PlaceholderColor3 = Color3.fromRGB(140,140,150)
        textBox.TextXAlignment = Enum.TextXAlignment.Left
        textBox.ClearTextOnFocus = false

        local changedEvent = Instance.new("BindableEvent")

        textBox.FocusLost:Connect(function(enterPressed)
            changedEvent:Fire(textBox.Text, enterPressed)
        end)

        return {
            get = function() return textBox.Text end,
            set = function(text) 
                textBox.Text = text
                changedEvent:Fire(text, false)
            end,
            Changed = changedEvent.Event
        }
    end

    -- NEW: ColorPicker element
    local function createColorPicker(text, defaultColor)
        defaultColor = defaultColor or Color3.fromRGB(255, 0, 0)
        
        local row = Instance.new("Frame", scrollFrame)
        row.Size = UDim2.new(1, 0, 0, 44)
        row.BackgroundTransparency = 1
        row.LayoutOrder = #scrollFrame:GetChildren()

        local label = Instance.new("TextLabel", row)
        label.Size = UDim2.new(0.66, 0, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.TextSize = 16
        label.Text = text
        label.TextColor3 = Color3.fromRGB(235,235,240)
        label.TextXAlignment = Enum.TextXAlignment.Left

        local colorButton = Instance.new("ImageButton", row)
        colorButton.Size = UDim2.new(0, 44, 0, 44)
        colorButton.Position = UDim2.new(1, -56, 0, 0)
        colorButton.BackgroundColor3 = defaultColor
        colorButton.AutoButtonColor = false
        local colorCorner = Instance.new("UICorner", colorButton)
        colorCorner.CornerRadius = UDim.new(0, 8)
        
        -- Color palette popup
        local paletteFrame = Instance.new("Frame", gui)
        paletteFrame.Size = UDim2.new(0, 200, 0, 140)
        paletteFrame.Position = UDim2.new(0.5, -100, 0.5, -70)
        paletteFrame.BackgroundColor3 = Color3.fromRGB(40,42,50)
        paletteFrame.BorderSizePixel = 0
        paletteFrame.Visible = false
        paletteFrame.ZIndex = 10
        local paletteCorner = Instance.new("UICorner", paletteFrame)
        paletteCorner.CornerRadius = UDim.new(0, 8)
        
        local paletteShadow = Instance.new("ImageLabel", paletteFrame)
        paletteShadow.Size = UDim2.new(1, 20, 1, 20)
        paletteShadow.Position = UDim2.new(0, -10, 0, -10)
        paletteShadow.BackgroundTransparency = 1
        paletteShadow.Image = "rbxassetid://5028857084"
        paletteShadow.ImageColor3 = Color3.new(0,0,0)
        paletteShadow.ImageTransparency = 0.4
        paletteShadow.ScaleType = Enum.ScaleType.Slice
        paletteShadow.SliceCenter = Rect.new(24,24,276,276)
        paletteShadow.ZIndex = 9
        
        local paletteTitle = Instance.new("TextLabel", paletteFrame)
        paletteTitle.Size = UDim2.new(1, -20, 0, 30)
        paletteTitle.Position = UDim2.new(0, 10, 0, 5)
        paletteTitle.BackgroundTransparency = 1
        paletteTitle.Font = Enum.Font.GothamBold
        paletteTitle.TextSize = 16
        paletteTitle.Text = "Choose Color"
        paletteTitle.TextColor3 = Color3.fromRGB(230,230,240)
        paletteTitle.TextXAlignment = Enum.TextXAlignment.Left
        paletteTitle.ZIndex = 11
        
        local colorGrid = Instance.new("UIGridLayout", paletteFrame)
        colorGrid.CellPadding = UDim2.new(0, 5, 0, 5)
        colorGrid.CellSize = UDim2.new(0, 30, 0, 30)
        colorGrid.StartCorner = Enum.StartCorner.TopLeft
        colorGrid.SortOrder = Enum.SortOrder.LayoutOrder
        colorGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
        colorGrid.VerticalAlignment = Enum.VerticalAlignment.Center
        colorGrid.Position = UDim2.new(0, 10, 0, 40)
        colorGrid.ZIndex = 11
        
        local colors = {
            Color3.fromRGB(255, 0, 0),     -- Red
            Color3.fromRGB(0, 255, 0),     -- Green
            Color3.fromRGB(0, 0, 255),     -- Blue
            Color3.fromRGB(255, 255, 0),   -- Yellow
            Color3.fromRGB(255, 0, 255),   -- Magenta
            Color3.fromRGB(0, 255, 255),   -- Cyan
            Color3.fromRGB(255, 165, 0),   -- Orange
            Color3.fromRGB(128, 0, 128),   -- Purple
            Color3.fromRGB(255, 255, 255), -- White
            Color3.fromRGB(0, 0, 0)        -- Black
        }
        
        for i, color in ipairs(colors) do
            local colorBtn = Instance.new("ImageButton", paletteFrame)
            colorBtn.BackgroundColor3 = color
            colorBtn.AutoButtonColor = false
            colorBtn.LayoutOrder = i
            colorBtn.ZIndex = 11
            
            local colorBtnCorner = Instance.new("UICorner", colorBtn)
            colorBtnCorner.CornerRadius = UDim.new(0, 6)
            
            colorBtn.MouseButton1Click:Connect(function()
                colorButton.BackgroundColor3 = color
                paletteFrame.Visible = false
                changedEvent:Fire(color)
            end)
        end
        
        colorButton.MouseButton1Click:Connect(function()
            paletteFrame.Visible = not paletteFrame.Visible
            if paletteFrame.Visible then
                paletteFrame.Position = UDim2.new(0, colorButton.AbsolutePosition.X - 80, 0, colorButton.AbsolutePosition.Y - 150)
            end
        end)
        
        -- Close palette when clicking outside
        local function closePalette(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and paletteFrame.Visible then
                local mousePos = input.Position
                local palettePos = paletteFrame.AbsolutePosition
                local paletteSize = paletteFrame.AbsoluteSize
                
                if mousePos.X < palettePos.X or mousePos.X > palettePos.X + paletteSize.X or
                   mousePos.Y < palettePos.Y or mousePos.Y > palettePos.Y + paletteSize.Y then
                    paletteFrame.Visible = false
                end
            end
        end
        
        UserInputService.InputBegan:Connect(closePalette)

        local changedEvent = Instance.new("BindableEvent")

        return {
            get = function() return colorButton.BackgroundColor3 end,
            set = function(color) 
                colorButton.BackgroundColor3 = color
                changedEvent:Fire(color)
            end,
            Changed = changedEvent.Event
        }
    end

    -- NEW: DropDown element
    local function createDropdown(text, options, defaultOption)
        options = options or {"Option 1", "Option 2", "Option 3"}
        defaultOption = defaultOption or options[1]
        
        local row = Instance.new("Frame", scrollFrame)
        row.Size = UDim2.new(1, 0, 0, 44)
        row.BackgroundTransparency = 1
        row.LayoutOrder = #scrollFrame:GetChildren()

        local label = Instance.new("TextLabel", row)
        label.Size = UDim2.new(0.66, 0, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.TextSize = 16
        label.Text = text
        label.TextColor3 = Color3.fromRGB(235,235,240)
        label.TextXAlignment = Enum.TextXAlignment.Left

        local dropdownButton = Instance.new("TextButton", row)
        dropdownButton.Size = UDim2.new(0, 120, 0, 36)
        dropdownButton.Position = UDim2.new(1, -132, 0.5, -18)
        dropdownButton.Text = defaultOption
        dropdownButton.Font = Enum.Font.Gotham
        dropdownButton.TextSize = 14
        dropdownButton.TextColor3 = Color3.fromRGB(235,235,240)
        dropdownButton.BackgroundColor3 = Color3.fromRGB(60,64,80)
        dropdownButton.AutoButtonColor = false
        local dropdownCorner = Instance.new("UICorner", dropdownButton)
        dropdownCorner.CornerRadius = UDim.new(0, 8)
        
        local dropdownIcon = Instance.new("TextLabel", dropdownButton)
        dropdownIcon.Size = UDim2.new(0, 20, 1, 0)
        dropdownIcon.Position = UDim2.new(1, -20, 0, 0)
        dropdownIcon.BackgroundTransparency = 1
        dropdownIcon.Text = "▼"
        dropdownIcon.Font = Enum.Font.Gotham
        dropdownIcon.TextSize = 12
        dropdownIcon.TextColor3 = Color3.fromRGB(200,200,210)
        dropdownIcon.TextXAlignment = Enum.TextXAlignment.Center
        
        -- Dropdown list
        local dropdownFrame = Instance.new("ScrollingFrame", gui)
        dropdownFrame.Size = UDim2.new(0, 120, 0, 120)
        dropdownFrame.BackgroundColor3 = Color3.fromRGB(40,42,50)
        dropdownFrame.BorderSizePixel = 0
        dropdownFrame.Visible = false
        dropdownFrame.ZIndex = 10
        dropdownFrame.CanvasSize = UDim2.new(0, 0, 0, #options * 30)
        dropdownFrame.ScrollBarThickness = 5
        local dropdownFrameCorner = Instance.new("UICorner", dropdownFrame)
        dropdownFrameCorner.CornerRadius = UDim.new(0, 8)
        
        local dropdownShadow = Instance.new("ImageLabel", dropdownFrame)
        dropdownShadow.Size = UDim2.new(1, 20, 1, 20)
        dropdownShadow.Position = UDim2.new(0, -10, 0, -10)
        dropdownShadow.BackgroundTransparency = 1
        dropdownShadow.Image = "rbxassetid://5028857084"
        dropdownShadow.ImageColor3 = Color3.new(0,0,0)
        dropdownShadow.ImageTransparency = 0.4
        dropdownShadow.ScaleType = Enum.ScaleType.Slice
        dropdownShadow.SliceCenter = Rect.new(24,24,276,276)
        dropdownShadow.ZIndex = 9
        
        local optionList = Instance.new("UIListLayout", dropdownFrame)
        optionList.Padding = UDim.new(0, 2)
        optionList.SortOrder = Enum.SortOrder.LayoutOrder
        
        for i, option in ipairs(options) do
            local optionButton = Instance.new("TextButton", dropdownFrame)
            optionButton.Size = UDim2.new(1, -10, 0, 28)
            optionButton.Position = UDim2.new(0, 5, 0, (i-1)*30)
            optionButton.Text = option
            optionButton.Font = Enum.Font.Gotham
            optionButton.TextSize = 14
            optionButton.TextColor3 = Color3.fromRGB(235,235,240)
            optionButton.BackgroundColor3 = Color3.fromRGB(60,64,80)
            optionButton.AutoButtonColor = false
            optionButton.ZIndex = 11
            local optionCorner = Instance.new("UICorner", optionButton)
            optionCorner.CornerRadius = UDim.new(0, 6)
            
            optionButton.MouseButton1Click:Connect(function()
                dropdownButton.Text = option
                dropdownFrame.Visible = false
                changedEvent:Fire(option)
            end)
        end
        
        dropdownButton.MouseButton1Click:Connect(function()
            dropdownFrame.Visible = not dropdownFrame.Visible
            if dropdownFrame.Visible then
                dropdownFrame.Position = UDim2.new(0, dropdownButton.AbsolutePosition.X, 0, dropdownButton.AbsolutePosition.Y + dropdownButton.AbsoluteSize.Y + 5)
            end
        end)
        
        -- Close dropdown when clicking outside
        local function closeDropdown(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and dropdownFrame.Visible then
                local mousePos = input.Position
                local dropdownPos = dropdownFrame.AbsolutePosition
                local dropdownSize = dropdownFrame.AbsoluteSize
                
                if mousePos.X < dropdownPos.X or mousePos.X > dropdownPos.X + dropdownSize.X or
                   mousePos.Y < dropdownPos.Y or mousePos.Y > dropdownPos.Y + dropdownSize.Y then
                    dropdownFrame.Visible = false
                end
            end
        end
        
        UserInputService.InputBegan:Connect(closeDropdown)

        local changedEvent = Instance.new("BindableEvent")

        return {
            get = function() return dropdownButton.Text end,
            set = function(option) 
                if table.find(options, option) then
                    dropdownButton.Text = option
                    changedEvent:Fire(option)
                end
            end,
            Changed = changedEvent.Event
        }
    end

    -- Dragging functionality
    local dragging = false
    local dragInput, dragStart, startPos

    local function updateDrag(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

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
        if dragging and input == dragInput then
            updateDrag(input)
        end
    end)

    -- Close / Reopen logic
    closeBtn.MouseButton1Click:Connect(function()
        TweenService:Create(mainFrame, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        wait(0.22)
        mainFrame.Visible = false
        reopenBtn.Visible = true
        reopenBtn.Size = UDim2.new(0, 0, 0, 0)
        reopenBtn.Visible = true
        TweenService:Create(reopenBtn, TweenInfo.new(0.18, Enum.EasingStyle.Back), {Size = UDim2.new(0,56,0,56)}):Play()
    end)

    reopenBtn.MouseButton1Click:Connect(function()
        reopenBtn.Visible = false
        mainFrame.Visible = true
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(mainFrame, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 360, 0, 520)}):Play()
    end)

    -- Initial open animation
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(mainFrame, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 360, 0, 520)}):Play()

    -- Menu object with methods
    local menu = {
        gui = gui,
        mainFrame = mainFrame,
        reopenBtn = reopenBtn,
        scrollFrame = scrollFrame
    }

    function menu:Show()
        self.reopenBtn.Visible = false
        self.mainFrame.Visible = true
        self.mainFrame.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(self.mainFrame, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 360, 0, 520)}):Play()
    end

    function menu:Hide()
        TweenService:Create(self.mainFrame, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        wait(0.22)
        self.mainFrame.Visible = false
        self.reopenBtn.Visible = true
        self.reopenBtn.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(self.reopenBtn, TweenInfo.new(0.18, Enum.EasingStyle.Back), {Size = UDim2.new(0,56,0,56)}):Play()
    end

    function menu:AddSection(title)
        local section = createSection(title)
        wait(0.01)
        self.scrollFrame.CanvasSize = UDim2.new(0, 0, 0, uiList.AbsoluteContentSize.Y + 12)
        return section
    end

    function menu:AddCheckbox(text, initial)
        local checkbox = createCheckbox(text, initial)
        wait(0.01)
        self.scrollFrame.CanvasSize = UDim2.new(0, 0, 0, uiList.AbsoluteContentSize.Y + 12)
        return checkbox
    end

    function menu:AddToggle(text, initial)
        local toggle = createToggle(text, initial)
        wait(0.01)
        self.scrollFrame.CanvasSize = UDim2.new(0, 0, 0, uiList.AbsoluteContentSize.Y + 12)
        return toggle
    end

    function menu:AddSlider(text, minVal, maxVal, defaultVal)
        local slider = createSlider(text, minVal, maxVal, defaultVal)
        wait(0.01)
        self.scrollFrame.CanvasSize = UDim2.new(0, 0, 0, uiList.AbsoluteContentSize.Y + 12)
        return slider
    end

    function menu:AddInputText(text, placeholder, defaultText)
        local input = createInputText(text, placeholder, defaultText)
        wait(0.01)
        self.scrollFrame.CanvasSize = UDim2.new(0, 0, 0, uiList.AbsoluteContentSize.Y + 12)
        return input
    end

    function menu:AddColorPicker(text, defaultColor)
        local colorPicker = createColorPicker(text, defaultColor)
        wait(0.01)
        self.scrollFrame.CanvasSize = UDim2.new(0, 0, 0, uiList.AbsoluteContentSize.Y + 12)
        return colorPicker
    end

    function menu:AddDropdown(text, options, defaultOption)
        local dropdown = createDropdown(text, options, defaultOption)
        wait(0.01)
        self.scrollFrame.CanvasSize = UDim2.new(0, 0, 0, uiList.AbsoluteContentSize.Y + 12)
        return dropdown
    end

    function menu:AddDivider()
        local divider = createDivider()
        wait(0.01)
        self.scrollFrame.CanvasSize = UDim2.new(0, 0, 0, uiList.AbsoluteContentSize.Y + 12)
        return divider
    end

    function menu:Destroy()
        self.gui:Destroy()
    end

    return menu
end

return ModernMenu
