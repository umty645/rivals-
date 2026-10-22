local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local repS = cloneref(game:GetService("ReplicatedStorage"))
local plrs = cloneref(game:GetService("Players"))
local runS = cloneref(game:GetService("RunService"))
local ws = cloneref(game:GetService("Workspace"))

local lplr = plrs.LocalPlayer
local util = require(repS.Modules.Utility)
local enum = require(repS.Modules.EnumLibrary)
local FighterController = require(lplr.PlayerScripts.Controllers.FighterController)

getgenv().Config = {
    Enabled = true,
    FireRate = 0.05,
    WeaponSlot = "Primary",
    MaxDistance = 500
}

local slots = { Primary = 1, Secondary = 2, Melee = 3 }
local function getSlotNumber()
    return slots[getgenv().Config.WeaponSlot] or 1
end

task.spawn(function()
    while true do
        task.wait(1)
        if not getgenv().Config.Enabled then continue end
        local localFighter = FighterController.LocalFighter
        if localFighter and localFighter.EquippedItem == nil then
            pcall(function() localFighter:EquipItem(getSlotNumber()) end)
        end
    end
end)

local lastFire = 0
local cachedTarget = nil
local lastCacheTime = 0
local CACHE_INTERVAL = 0.15
local function getClosestTarget()
    local now = tick()
    if now - lastCacheTime < CACHE_INTERVAL and cachedTarget then
        local hum = cachedTarget:FindFirstChildWhichIsA("Humanoid")
        if hum and hum.Health > 0 and cachedTarget:FindFirstChild("HumanoidRootPart") then
            return cachedTarget, cachedTarget:FindFirstChild("HumanoidRootPart"), cachedTarget:FindFirstChild("Head")
        end
        cachedTarget = nil
    end

    lastCacheTime = now

    local char = lplr.Character
    local myRoot = char and char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil, nil, nil end

    local closestModel, closestRoot, closestHead = nil, nil, nil
    local closestDist = getgenv().Config.MaxDistance
    local function scanFolder(folder)
        for _, obj in ipairs(folder:GetChildren()) do
            if obj:IsA("Model") and obj ~= char then
                local pRoot = obj:FindFirstChild("HumanoidRootPart")
                local pHead = obj:FindFirstChild("Head")
                local pHum = obj:FindFirstChildWhichIsA("Humanoid")

                if pRoot and pHead and pHum and pHum.Health > 0 then
                    if not plrs:GetPlayerFromCharacter(obj) then
                        local dist = (myRoot.Position - pRoot.Position).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closestModel = obj
                            closestRoot = pRoot
                            closestHead = pHead
                        end
                    end
                end
            end
        end
    end

    scanFolder(ws)
    local npcFolder = ws:FindFirstChild("NPCs") or ws:FindFirstChild("Enemies") or ws:FindFirstChild("Mobs")
    if npcFolder then scanFolder(npcFolder) end

    cachedTarget = closestModel
    return closestModel, closestRoot, closestHead
end

runS.Heartbeat:Connect(function()
    if not getgenv().Config.Enabled then return end

    local targetModel, targetRoot, targetHead = getClosestTarget()
    if not targetModel or not targetHead or not targetRoot then return end

    local char = lplr.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local localFighter = FighterController.LocalFighter
    if not localFighter or not localFighter.EquippedItem then return end

    if tick() - lastFire < getgenv().Config.FireRate then return end
    lastFire = tick()

    local originPos = targetHead.Position + Vector3.new(0, 1, 0)
    local targetPos = targetHead.Position
    local aimCF = CFrame.lookAt(originPos, targetPos)
    local targetCF = targetHead.CFrame

    local randomOffset = Vector3.new(
        (math.random() - 0.5) * 0.02,
        (math.random() - 0.5) * 0.02,
        (math.random() - 0.5) * 0.02
    )
    local aimedPos = targetPos + randomOffset
    local objSpaceHeadOffset = targetHead.CFrame:ToObjectSpace(CFrame.new(aimedPos))

    local cameradata = {}
    cameradata[utf8.char(1)] = {
        [utf8.char(0)] = util:EncodeCFrame(aimCF),
        [utf8.char(1)] = util:EncodeCFrame(targetCF),
        [utf8.char(2)] = targetHead,
        [utf8.char(3)] = util:EncodeCFrame(objSpaceHeadOffset)
    }

    pcall(function()
        repS.Remotes.Replication.Fighter.UseItem:FireServer(
            localFighter.EquippedItem:Get("ObjectID"),
            enum:ToEnum("StartShooting"),
            cameradata,
            nil
        )
    end)
end)

local Window = Library:CreateWindow({
    Title = 'daddy mani',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Main = Window:AddTab('main'),
    ['ui settings'] = Window:AddTab('ui settings'),
}

local LeftGroupBox = Tabs.Main:AddLeftGroupbox('combat settings')

LeftGroupBox:AddToggle('EnabledToggle', {
    Text = 'enable auto-shoot',
    Default = getgenv().Config.Enabled,
    Tooltip = 'toggles the replication attack loop',
    Callback = function(Value)
        getgenv().Config.Enabled = Value
    end
})

LeftGroupBox:AddDropdown('WeaponSlotDropdown', {
    Values = { 'Primary', 'Secondary', 'Melee' },
    Default = 1,
    Multi = false,
    Text = 'weapon slot',
    Tooltip = 'select which slot to auto-equip',
    Callback = function(Value)
        getgenv().Config.WeaponSlot = Value
    end
})

LeftGroupBox:AddSlider('FireRateSlider', {
    Text = 'fire rate (seconds)',
    Default = getgenv().Config.FireRate,
    Min = 0.01,
    Max = 0.5,
    Rounding = 2,
    Compact = false,
    Callback = function(Value)
        getgenv().Config.FireRate = Value
    end
})

LeftGroupBox:AddSlider('MaxDistSlider', {
    Text = 'max distance',
    Default = getgenv().Config.MaxDistance,
    Min = 50,
    Max = 2000,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        getgenv().Config.MaxDistance = Value
    end
})

local MenuGroup = Tabs['ui settings']:AddLeftGroupbox('menu')

MenuGroup:AddButton('unload', function() Library:Unload() end)
MenuGroup:AddLabel('menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'menu keybind' })

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:ApplyToTab(Tabs['ui settings'])
SaveManager:BuildConfigSection(Tabs['ui settings'])
SaveManager:LoadAutoloadConfig()
