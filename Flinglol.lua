-- WindUI Example Script with Rewards, Strength, Wins, Rebirths and Eggs

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()


WindUI.TransparencyValue = 0.2
WindUI:SetTheme("Dark")

-- Create main window
local Window = WindUI:CreateWindow({
    Title = "Dinas Hub OP",
    Icon = "gift",
    Author = "Dinas",
    Folder = "FlingYourself",
    Size = UDim2.fromOffset(580, 490),
    Theme = "Dark",
    
    OpenButton = {
        Title = "Dinas Hub",
        Enabled = true,
        Color = ColorSequence.new(
            Color3.fromHex("#30FF6A"), 
            Color3.fromHex("#e7ff2f")
        ),
    },
})

-- Create tabs
local Tabs = {
    Rewards = Window:Tab({ Title = "Rewards", Icon = "gift", Desc = "Spin rewards system" }),
    Strength = Window:Tab({ Title = "Strength", Icon = "zap", Desc = "Strength management" }),
    Wins = Window:Tab({ Title = "Wins", Icon = "trophy", Desc = "Infinite wins system" }),
    Rebirths = Window:Tab({ Title = "Rebirths", Icon = "refresh-cw", Desc = "Infinite rebirths" }),
    Eggs = Window:Tab({ Title = "Eggs", Icon = "egg", Desc = "Egg hatching system" }),
    Appearance = Window:Tab({ Title = "Theme", Icon = "brush" }),
    Config = Window:Tab({ Title = "Config", Icon = "settings" }),
}

-- Rewards Tab
Tabs.Rewards:Paragraph({
    Title = "Spin Rewards System",
    Desc = "Select and claim your rewards",
    Image = "gift",
    ImageSize = 20,
    Color = Color3.fromHex("#30ff6a")
})

local rewardsSection = Tabs.Rewards:Section({
    Title = "Available Rewards",
    Opened = true,
    Box = true
})

-- Available rewards
local SpinRewards = {
    "Yeti Pet",
    "+2 Spins", 
    "Super Luck Gamepass",
    "x1.5 Rebirths",
    "x1.5 Wins",
    "+100 Wins",
    "+1k Strength",
    "x1.5 Strength"
}

local selectedReward = SpinRewards[1]
local rewardDropdown = rewardsSection:Dropdown({
    Title = "Select Reward",
    Values = SpinRewards,
    Value = selectedReward,
    Callback = function(reward)
        selectedReward = reward
        WindUI:Notify({
            Title = "Reward Selected",
            Content = reward,
            Icon = "gift",
            Duration = 2
        })
    end
})

rewardsSection:Button({
    Title = "Claim Selected Reward",
    Icon = "check",
    Color = Color3.fromHex("#30ff6a"),
    Callback = function()
        local Event = game:GetService("ReplicatedStorage").Remotes.Events.FinishSpinRoulette
        Event:FireServer(selectedReward)
        
        WindUI:Notify({
            Title = "Reward Claimed!",
            Content = "You received: " .. selectedReward,
            Icon = "party-popper",
            Duration = 5
        })
    end
})

rewardsSection:Divider()

rewardsSection:Button({
    Title = "Claim All Rewards",
    Icon = "sparkles",
    Color = Color3.fromHex("#ff6b35"),
    Callback = function()
        local Event = game:GetService("ReplicatedStorage").Remotes.Events.FinishSpinRoulette
        
        for _, rewardName in ipairs(SpinRewards) do
            Event:FireServer(rewardName)
        end
        
        WindUI:Notify({
            Title = "All Rewards Claimed!",
            Content = "All " .. #SpinRewards .. " rewards have been sent",
            Icon = "trophy",
            Duration = 5
        })
    end
})

-- Strength Tab
Tabs.Strength:Paragraph({
    Title = "Strength Management",
    Desc = "Manage your strength currency",
    Image = "zap",
    ImageSize = 20,
    Color = Color3.fromHex("#ffd700")
})

local strengthSection = Tabs.Strength:Section({
    Title = "Strength Controls",
    Opened = true,
    Box = true
})

local strengthAmount = 40
local strengthSlider = strengthSection:Slider({
    Title = "Strength Amount",
    Desc = "Set the amount of strength to collect",
    Value = { Min = 1, Max = 1000, Default = strengthAmount },
    Callback = function(value)
        strengthAmount = value
    end
})

strengthSection:Button({
    Title = "Collect Strength",
    Icon = "zap",
    Color = Color3.fromHex("#ffd700"),
    Callback = function()
        local Event = game:GetService("ReplicatedStorage").Remotes.Events.CurrencyCollected
        Event:FireServer(strengthAmount, "Strength")
        
        WindUI:Notify({
            Title = "Strength Collected!",
            Content = "Collected " .. strengthAmount .. " strength",
            Icon = "zap",
            Duration = 3
        })
    end
})

strengthSection:Divider()

strengthSection:Button({
    Title = "Collect Max Strength",
    Icon = "battery-full",
    Color = Color3.fromHex("#ff6b35"),
    Callback = function()
        local Event = game:GetService("ReplicatedStorage").Remotes.Events.CurrencyCollected
        Event:FireServer(1000, "Strength")
        
        WindUI:Notify({
            Title = "Max Strength Collected!",
            Content = "Collected 1000 strength",
            Icon = "battery-full",
            Duration = 3
        })
    end
})

-- Wins Tab
Tabs.Wins:Paragraph({
    Title = "Infinite Wins System",
    Desc = "Automated wins collection",
    Image = "trophy",
    ImageSize = 20,
    Color = Color3.fromHex("#4CAF50")
})

local winsSection = Tabs.Wins:Section({
    Title = "Wins Controls",
    Opened = true,
    Box = true
})

-- Переменные для побед
local winsMultiplier = 1.5
local isInfiniteWinsRunning = false
local winsConnection = nil

-- Функция для выполнения одной победы
local function performWin()
    local winEvent = game:GetService("ReplicatedStorage").Remotes.Events.FinishSpinRoulette
    winEvent:FireServer("x" .. winsMultiplier .. " Wins")
end

-- Функция для получения +100 побед
local function performPlus100Wins()
    local winEvent = game:GetService("ReplicatedStorage").Remotes.Events.FinishSpinRoulette
    winEvent:FireServer("+100 Wins")
end

-- Функция для запуска/остановки бесконечных побед
local function toggleInfiniteWins(state)
    if state then
        -- Запускаем бесконечные победы
        isInfiniteWinsRunning = true
        WindUI:Notify({
            Title = "Infinite Wins Started",
            Content = "Wins will be collected automatically every 0.5 seconds",
            Icon = "trophy",
            Duration = 3
        })
        
        -- Создаем цикл побед
        winsConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if isInfiniteWinsRunning then
                performWin()
                -- Добавляем небольшую задержку чтобы не лагало
                wait(0.5)
            end
        end)
        
    else
        -- Останавливаем бесконечные победы
        isInfiniteWinsRunning = false
        if winsConnection then
            winsConnection:Disconnect()
            winsConnection = nil
        end
        WindUI:Notify({
            Title = "Infinite Wins Stopped",
            Content = "Auto wins collection disabled",
            Icon = "square",
            Duration = 3
        })
    end
end

local winsToggle = winsSection:Toggle({
    Title = "Enable Infinite Wins",
    Desc = "Automatically collect wins every 0.5 seconds",
    Value = false,
    Callback = function(state)
        toggleInfiniteWins(state)
    end
})

local winsMultiplierSlider = winsSection:Slider({
    Title = "Wins Multiplier",
    Desc = "Set the wins multiplier amount",
    Value = { Min = 1.0, Max = 10.0, Default = winsMultiplier },
    Step = 0.1,
    Callback = function(value)
        winsMultiplier = value
    end
})

winsSection:Button({
    Title = "Single Win",
    Icon = "trophy",
    Color = Color3.fromHex("#4CAF50"),
    Callback = function()
        performWin()
        WindUI:Notify({
            Title = "Win Collected!",
            Content = "Collected x" .. winsMultiplier .. " wins",
            Icon = "trophy",
            Duration = 3
        })
    end
})

winsSection:Divider()

winsSection:Button({
    Title = "+100 Wins",
    Icon = "plus",
    Color = Color3.fromHex("#2196F3"),
    Callback = function()
        performPlus100Wins()
        WindUI:Notify({
            Title = "+100 Wins Added!",
            Content = "Added 100 wins to your account",
            Icon = "plus",
            Duration = 3
        })
    end
})

winsSection:Button({
    Title = "Mass Wins (10x)",
    Icon = "fast-forward",
    Color = Color3.fromHex("#FF9800"),
    Callback = function()
        for i = 1, 10 do
            performWin()
            wait(0.1)
        end
        
        WindUI:Notify({
            Title = "Mass Wins Complete!",
            Content = "Collected 10x wins with multiplier x" .. winsMultiplier,
            Icon = "fast-forward",
            Duration = 5
        })
    end
})

-- Rebirths Tab
Tabs.Rebirths:Paragraph({
    Title = "Infinite Rebirths System",
    Desc = "Automated rebirths collection",
    Image = "refresh-cw",
    ImageSize = 20,
    Color = Color3.fromHex("#FF6B9D")
})

local rebirthsSection = Tabs.Rebirths:Section({
    Title = "Rebirths Controls",
    Opened = true,
    Box = true
})

-- Переменные для ребитхов
local rebirthsMultiplier = 1.5
local isInfiniteRebirthsRunning = false
local rebirthsConnection = nil

-- Функция для выполнения одного ребитха
local function performRebirth()
    local rebirthEvent = game:GetService("ReplicatedStorage").Remotes.Events.FinishSpinRoulette
    rebirthEvent:FireServer("x" .. rebirthsMultiplier .. " Rebirths")
end

-- Функция для запуска/остановки бесконечных ребитхов
local function toggleInfiniteRebirths(state)
    if state then
        -- Запускаем бесконечные ребитхи
        isInfiniteRebirthsRunning = true
        WindUI:Notify({
            Title = "Infinite Rebirths Started",
            Content = "Rebirths will be collected automatically every 0.5 seconds",
            Icon = "refresh-cw",
            Duration = 3
        })
        
        -- Создаем цикл ребитхов
        rebirthsConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if isInfiniteRebirthsRunning then
                performRebirth()
                wait(0.5)
            end
        end)
        
    else
        -- Останавливаем бесконечные ребитхи
        isInfiniteRebirthsRunning = false
        if rebirthsConnection then
            rebirthsConnection:Disconnect()
            rebirthsConnection = nil
        end
        WindUI:Notify({
            Title = "Infinite Rebirths Stopped",
            Content = "Auto rebirths collection disabled",
            Icon = "square",
            Duration = 3
        })
    end
end

local rebirthsToggle = rebirthsSection:Toggle({
    Title = "Enable Infinite Rebirths",
    Desc = "Automatically collect rebirths every 0.5 seconds",
    Value = false,
    Callback = function(state)
        toggleInfiniteRebirths(state)
    end
})

local rebirthsMultiplierSlider = rebirthsSection:Slider({
    Title = "Rebirths Multiplier",
    Desc = "Set the rebirths multiplier amount",
    Value = { Min = 1.0, Max = 10.0, Default = rebirthsMultiplier },
    Step = 0.1,
    Callback = function(value)
        rebirthsMultiplier = value
    end
})

rebirthsSection:Button({
    Title = "Single Rebirth",
    Icon = "refresh-cw",
    Color = Color3.fromHex("#FF6B9D"),
    Callback = function()
        performRebirth()
        WindUI:Notify({
            Title = "Rebirth Collected!",
            Content = "Collected x" .. rebirthsMultiplier .. " rebirths",
            Icon = "refresh-cw",
            Duration = 3
        })
    end
})

rebirthsSection:Divider()

rebirthsSection:Button({
    Title = "Mass Rebirths (10x)",
    Icon = "fast-forward",
    Color = Color3.fromHex("#FF9800"),
    Callback = function()
        for i = 1, 10 do
            performRebirth()
            wait(0.1)
        end
        
        WindUI:Notify({
            Title = "Mass Rebirths Complete!",
            Content = "Collected 10x rebirths with multiplier x" .. rebirthsMultiplier,
            Icon = "fast-forward",
            Duration = 5
        })
    end
})

-- Eggs Tab
Tabs.Eggs:Paragraph({
    Title = "Egg Hatching System",
    Desc = "Hatch eggs and get rewards",
    Image = "egg",
    ImageSize = 20,
    Color = Color3.fromHex("#FFD166")
})

local eggsSection = Tabs.Eggs:Section({
    Title = "Egg Controls",
    Opened = true,
    Box = true
})

-- Список доступных яиц
local AvailableEggs = {
    "Basic",
    "Beach",
    "Blue Dragon",
    "Cactus",
    "Candy",
    "Candy Dragon",
    "Dust",
    "Gradient",
    "Heat",
    "Hot",
    "Ice",
    "Magma",
    "Pink Dragon",
    "Snow"
}

local selectedEgg = AvailableEggs[1]
local eggAmount = 1

local eggDropdown = eggsSection:Dropdown({
    Title = "Select Egg",
    Values = AvailableEggs,
    Value = selectedEgg,
    Callback = function(egg)
        selectedEgg = egg
        WindUI:Notify({
            Title = "Egg Selected",
            Content = egg,
            Icon = "egg",
            Duration = 2
        })
    end
})

local eggAmountSlider = eggsSection:Slider({
    Title = "Egg Amount",
    Desc = "Number of eggs to hatch (Max: 3)",
    Value = { Min = 1, Max = 3, Default = eggAmount },
    Callback = function(value)
        eggAmount = value
    end
})

eggsSection:Button({
    Title = "Hatch Selected Egg",
    Icon = "egg",
    Color = Color3.fromHex("#FFD166"),
    Callback = function()
        local Event = game:GetService("ReplicatedStorage").Remotes.Functions.TryHatchEgg
        Event:InvokeServer(selectedEgg, eggAmount)
        
        WindUI:Notify({
            Title = "Egg Hatching Started!",
            Content = "Hatching " .. eggAmount .. " " .. selectedEgg .. " egg(s)",
            Icon = "egg",
            Duration = 5
        })
    end
})

eggsSection:Divider()

-- Быстрое открытие яиц
local quickEggsSection = Tabs.Eggs:Section({
    Title = "Quick Egg Actions",
    Opened = true,
    Box = true
})

quickEggsSection:Button({
    Title = "Hatch All Eggs Once",
    Icon = "zap",
    Color = Color3.fromHex("#9d4edd"),
    Callback = function()
        local Event = game:GetService("ReplicatedStorage").Remotes.Functions.TryHatchEgg
        local hatchedCount = 0
        
        for _, eggName in ipairs(AvailableEggs) do
            Event:InvokeServer(eggName, 1)
            hatchedCount = hatchedCount + 1
            wait(0.1)
        end
        
        WindUI:Notify({
            Title = "All Eggs Hatched!",
            Content = "Hatched " .. hatchedCount .. " different eggs once",
            Icon = "zap",
            Duration = 5
        })
    end
})

quickEggsSection:Button({
    Title = "Hatch Max All Eggs",
    Icon = "rocket",
    Color = Color3.fromHex("#ff6b35"),
    Callback = function()
        local Event = game:GetService("ReplicatedStorage").Remotes.Functions.TryHatchEgg
        local hatchedCount = 0
        
        for _, eggName in ipairs(AvailableEggs) do
            Event:InvokeServer(eggName, 3)
            hatchedCount = hatchedCount + 3
            wait(0.1)
        end
        
        WindUI:Notify({
            Title = "Max Eggs Hatched!",
            Content = "Hatched " .. hatchedCount .. " eggs total (3x each type)",
            Icon = "rocket",
            Duration = 5
        })
    end
})

-- Appearance Tab
Tabs.Appearance:Paragraph({
    Title = "Customize Interface",
    Desc = "Personalize your experience",
    Image = "palette",
    ImageSize = 20,
    Color = "White"
})

local themes = {}
for themeName, _ in pairs(WindUI:GetThemes()) do
    table.insert(themes, themeName)
end
table.sort(themes)

local themeDropdown = Tabs.Appearance:Dropdown({
    Title = "Theme",
    Values = themes,
    SearchBarEnabled = true,
    MenuWidth = 280,
    Value = "Dark",
    Callback = function(theme)
        WindUI:SetTheme(theme)
        WindUI:Notify({
            Title = "Theme Applied",
            Content = theme,
            Icon = "palette",
            Duration = 2
        })
    end
})

local transparencySlider = Tabs.Appearance:Slider({
    Title = "Menu Transparency",
    Value = { 
        Min = 0,
        Max = 1,
        Default = 0,
    },
    Step = 0.1,
    Callback = function(value)
        Window:SetBackgroundTransparency(value)
        Window:SetBackgroundImageTransparency(value)
    end
})

-- Configuration Tab
Tabs.Config:Paragraph({
    Title = "Configuration Manager",
    Desc = "Save and load your settings",
    Image = "save",
    ImageSize = 20,
    Color = "White"
})

local configName = "reward_config"
local configFile = nil
local ConfigManager = Window.ConfigManager

-- Player data to save
local PlayerData = {
    lastReward = selectedReward,
    strengthAmount = strengthAmount,
    winsMultiplier = winsMultiplier,
    infiniteWins = false,
    rebirthsMultiplier = rebirthsMultiplier,
    infiniteRebirths = false,
    selectedEgg = selectedEgg,
    eggAmount = eggAmount,
    lastUsed = os.date("%Y-%m-%d %H:%M:%S")
}

local configInput = Tabs.Config:Input({
    Title = "Config Name",
    Value = configName,
    Callback = function(value)
        configName = value or "reward_config"
    end
})

if ConfigManager then
    ConfigManager:Init(Window)
    
    Tabs.Config:Space({ Columns = 0 })
    
    Tabs.Config:Button({
        Title = "Save Config",
        Icon = "save",
        IconAlign = "Left",
        Justify = "Center",
        Color = Color3.fromHex("315dff"),
        Callback = function()
            configFile = ConfigManager:CreateConfig(configName)
            
            -- Update player data
            PlayerData.lastReward = selectedReward
            PlayerData.strengthAmount = strengthAmount
            PlayerData.winsMultiplier = winsMultiplier
            PlayerData.infiniteWins = winsToggle:Get()
            PlayerData.rebirthsMultiplier = rebirthsMultiplier
            PlayerData.infiniteRebirths = rebirthsToggle:Get()
            PlayerData.selectedEgg = selectedEgg
            PlayerData.eggAmount = eggAmount
            PlayerData.lastUsed = os.date("%Y-%m-%d %H:%M:%S")
            
            configFile:Set("playerData", PlayerData)
            
            if configFile:Save() then
                WindUI:Notify({ 
                    Title = "Save Config", 
                    Content = "Saved as: "..configName,
                    Icon = "check",
                    Duration = 3
                })
            else
                WindUI:Notify({ 
                    Title = "Error", 
                    Content = "Failed to save config",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })

    Tabs.Config:Space({ Columns = -1 })

    Tabs.Config:Button({
        Title = "Load Config",
        IconAlign = "Left",
        Justify = "Center",
        Color = Color3.fromHex("315dff"),
        Icon = "folder",
        Callback = function()
            configFile = ConfigManager:CreateConfig(configName)
            local loadedData = configFile:Load()
            
            if loadedData and loadedData.playerData then
                PlayerData = loadedData.playerData
                
                -- Apply loaded settings
                if PlayerData.lastReward then
                    selectedReward = PlayerData.lastReward
                    rewardDropdown:Select(selectedReward)
                end
                
                if PlayerData.strengthAmount then
                    strengthAmount = PlayerData.strengthAmount
                    strengthSlider:Set(strengthAmount)
                end
                
                if PlayerData.winsMultiplier then
                    winsMultiplier = PlayerData.winsMultiplier
                    winsMultiplierSlider:Set(winsMultiplier)
                end
                
                if PlayerData.infiniteWins ~= nil then
                    winsToggle:Set(PlayerData.infiniteWins)
                    toggleInfiniteWins(PlayerData.infiniteWins)
                end
                
                if PlayerData.rebirthsMultiplier then
                    rebirthsMultiplier = PlayerData.rebirthsMultiplier
                    rebirthsMultiplierSlider:Set(rebirthsMultiplier)
                end
                
                if PlayerData.infiniteRebirths ~= nil then
                    rebirthsToggle:Set(PlayerData.infiniteRebirths)
                    toggleInfiniteRebirths(PlayerData.infiniteRebirths)
                end
                
                if PlayerData.selectedEgg then
                    selectedEgg = PlayerData.selectedEgg
                    eggDropdown:Select(selectedEgg)
                end
                
                if PlayerData.eggAmount then
                    eggAmount = PlayerData.eggAmount
                    eggAmountSlider:Set(eggAmount)
                end
                
                local lastUsed = PlayerData.lastUsed or "Unknown"
                WindUI:Notify({ 
                    Title = "Load Config", 
                    Content = "Loaded: "..configName.."\nLast used: "..lastUsed,
                    Icon = "refresh-cw",
                    Duration = 5
                })
            else
                WindUI:Notify({ 
                    Title = "Error", 
                    Content = "Failed to load config",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })
    
    Tabs.Config:Space({ Columns = 0 })

else
    Tabs.Config:Paragraph({
        Title = "Config Manager Not Available",
        Desc = "This feature requires ConfigManager",
        Image = "alert-triangle",
        ImageSize = 20,
        Color = "White"
    })
end

-- Auto-save on close and stop all loops
Window:OnClose(function()
    -- Останавливаем бесконечные победы
    if isInfiniteWinsRunning then
        toggleInfiniteWins(false)
    end
    
    -- Останавливаем бесконечные ребитхи
    if isInfiniteRebirthsRunning then
        toggleInfiniteRebirths(false)
    end
    
    -- Сохраняем конфиг
    if ConfigManager and configFile then
        PlayerData.lastReward = selectedReward
        PlayerData.strengthAmount = strengthAmount
        PlayerData.winsMultiplier = winsMultiplier
        PlayerData.infiniteWins = winsToggle:Get()
        PlayerData.rebirthsMultiplier = rebirthsMultiplier
        PlayerData.infiniteRebirths = rebirthsToggle:Get()
        PlayerData.selectedEgg = selectedEgg
        PlayerData.eggAmount = eggAmount
        PlayerData.lastUsed = os.date("%Y-%m-%d %H:%M:%S")
        
        configFile:Set("playerData", PlayerData)
        configFile:Save()
        print("Config auto-saved on close")
    end
end)
