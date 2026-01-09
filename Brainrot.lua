local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Vovabro46/trash/refs/heads/main/Aurora.lua"))()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local TeleportRequest = Remotes:WaitForChild("TeleportRequest")
local CollectRequest = Remotes:WaitForChild("CollectRequest")
local BlockBreakingRequest = Remotes:WaitForChild("BlockBreakingRequest")
local MineRequest = Remotes:WaitForChild("MineRequest")
local FinishMine = Remotes:WaitForChild("FinishMine")

local BrainrotList = {
    "Agarrini la Palini", "Ballerina Cappuccina", "Boneca Ambalabu", "Cappuccino Assasino",
    "Chicleteira Bicicleteira", "Chicleteira Noelteira", "Chicleteira Rocketera", "Chimpanzini Bananini",
    "Craccini Fractini", "Dragon Cannelloni", "Esok Sekolah", "Gangster Footera",
    "Garama", "Gingerat Gerat", "Job Job Sahur", "Karkerkar Kurkur", "Ketupat Kepat",
    "La Ginger Sekolah", "La Grande Combination", "La Vaca Saturno Saturnita", "Lirali larila",
    "Madundung", "Matteo", "Odin Din Din Dun", "Orcalero Ocala", "Pakrahmatmamat",
    "Pot Hotspot", "Presenti Boxalini", "Six Seven", "Strawberry Elephant",
    "Tigroligre Frutonni", "Tim Cheese", "Tralaledon", "Tralalero Tralala", "Tung Tung Sahur"
}

local PickaxeList = {
    "Celestial Pickaxe", "Diamond Pickaxe", "Drill Pickaxe", "Fairy Pickaxe",
    "Golden Pickaxe", "Iron Pickaxe", "Lava Pickaxe", "Mythril Pickaxe", "Royal Pickaxe"
}

local SelectedBrainrot = BrainrotList[1]
local SelectedPickaxe = PickaxeList[5]
local AutoCollectBool = false
local AutoBreakBool = false
local AutoMineBool = false

local Win = Library:Window("Dinas Hub Best", "crown", "Mine a Brainrot | Dinas Hub", false)

local MainTab = Win:Tab("Farming", "pickaxe")
local TeleportTab = Win:Tab("Teleports", "map")

local FarmPage = MainTab:Page("Features", "sword")
local TPPage = TeleportTab:Page("Locations", "globe")

FarmPage:Paragraph("Instructions: Collect", "1. Select a character name from the list.\n2. The script will send this NAME (as text) to the server.\n3. Use auto-collection or collect all at once.", "Left")

FarmPage:Dropdown("Select Character", "CharDrop", BrainrotList, "Left", function(val)
SelectedBrainrot = val
end, "Sends Brainrot to server")

FarmPage:Toggle("Auto Collect Selected", "AutoColSel", false, "Spam selected name", "Left", function(state)
AutoCollectBool = state
task.spawn(function()
while AutoCollectBool do
CollectRequest:FireServer(SelectedBrainrot)
task.wait(0.1)
end
end)
end)

FarmPage:Button("Collect ALL Once", "Send name of every char once",  "Left", function()
for _, name in pairs(BrainrotList) do
CollectRequest:FireServer(name)
end
Library:Notification("Sent", "Sent for all chars!", 3)
end)

FarmPage:Toggle("Auto Collect ALL", "AutoColAll", false, "Spam all names loop", "Left", function(state)
getgenv().AutoCollectAll = state
task.spawn(function()
while getgenv().AutoCollectAll do
for _, name in pairs(BrainrotList) do
CollectRequest:FireServer(name)
end
task.wait(0.001)
end
end)
end)

FarmPage:Paragraph("Instructions: Blocks", "Select a pickaxe in your INVENTORY. The script will find the tool and use it to break it.",  "Right")

 FarmPage:Dropdown("Select Pickaxe", "PickDrop", PickaxeList, "Right", function(val)
     SelectedPickaxe = val
 end, "Matches pickaxe name")

 FarmPage:Toggle("Auto Block Break", "AutoBreak", false, "Breaks blocks", "Right", function(state)
     AutoBreakBool = state
     task.spawn(function()
         while AutoBreakBool do
             pcall(function()
                 local Char = LocalPlayer.Character
                 if Char then
                     local Tool = Char:FindFirstChild(SelectedPickaxe) or LocalPlayer.Backpack:FindFirstChild(SelectedPickaxe)
                    
                     if Tool then
                         if Tool.Parent ~= Char then Tool.Parent = Char end
                         BlockBreakingRequest:FireServer(Tool)
                     end
                 end
             end)
 task.wait(0.1)
end
end)
end)

FarmPage:Paragraph("Instruction: Lucky Block", "Digs Lucky Block automatically (Mine -> Finish).", "Right")

FarmPage:Toggle("Auto Mine LuckyBlock", "AutoMine", false, "Farms lucky block", "Right", function(state)
AutoMineBool = state
task.spawn(function()
while AutoMineBool do
MineRequest:InvokeServer()
FinishMine:FireServer()
task.wait(0.2)
end
end)
end)

TPPage:Paragraph("Teleporters", "Press the button to move.", "Left")

TPPage:Button("Teleport to Base", "Go Home", "Left", function()
    TeleportRequest:FireServer("Base")
end)

TPPage:Button("Teleport to Mine", "Go Mining", "Left", function()
    TeleportRequest:FireServer("Mine")
end)

TPPage:Button("Teleport to Shop", "Go Shopping", "Left", function()
    TeleportRequest:FireServer("Shop")
end)

Library:ConfigSystem(Win)
