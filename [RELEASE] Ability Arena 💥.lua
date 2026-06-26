local MY_WEBHOOK = "https://discord.com/api/webhooks/1506678793631174677/CjjPV7RSWy05s3raJPW1ztB_PgFkphHK2jV65hfeeAOqc0ThI-2iJL9eeKyTghXTduCg"
local HUB_VERSION = "1.0"
local HUB_NAME = "bulo hub"
local executorName = "Unknown"

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer

local AuraEnabled = false
local AURA_RADIUS = 50
local ATTACK_SPEED = 0.01

local MIN_Y = 6.0
local lastSafeCFrame = nil
local antiFallEnabled = false

local TELEPORT_DISTANCE = 5
local BLINK_DELAY = 0.05
local blinkEnabled = false

local speedEnabled = false
local SPEED_VALUE = 50
local defaultSpeed = 16

local autoFarmEnabled = false
local AUTO_FARM_SPEED = 50
local ORBIT_RADIUS = 5
local orbitAngle = 0
local noclipConn = nil

local WHITELIST = {
    ["kitkubkit"] = true,
    ["ll_ter"] = true,
}

local function httpRequest(url, method, headers, body)
    method = method or "GET"
    headers = headers or {}
    body = body or nil
    if type(request) == "function" then
        local ok, res = pcall(request, {Url=url, Method=method, Headers=headers, Body=body})
        if ok and res then return res end
    end
    if type(syn) == "table" and type(syn.request) == "function" then
        local ok, res = pcall(syn.request, {Url=url, Method=method, Headers=headers, Body=body})
        if ok and res then return res end
    end
    if type(http_request) == "function" then
        local ok, res = pcall(http_request, {Url=url, Method=method, Headers=headers, Body=body})
        if ok and res then return res end
    end
    if type(fluxus_request) == "function" then
        local ok, res = pcall(fluxus_request, {Url=url, Method=method, Headers=headers, Body=body})
        if ok and res then return res end
    end
    if type(krnl_request) == "function" then
        local ok, res = pcall(krnl_request, {Url=url, Method=method, Headers=headers, Body=body})
        if ok and res then return res end
    end
    if type(HttpRequest) == "function" then
        local ok, res = pcall(HttpRequest, {Url=url, Method=method, Headers=headers, Body=body})
        if ok and res then return res end
    end
    if method == "GET" then
        local ok, res = pcall(function() return game:HttpGet(url) end)
        if ok and res then return {Body = res, StatusCode = 200} end
    end
    if method == "GET" then
        local ok, res = pcall(function() return HttpService:GetAsync(url) end)
        if ok and res then return {Body = res, StatusCode = 200} end
    end
    if method == "POST" and body then
        local ok, res = pcall(function()
            return HttpService:PostAsync(url, body, Enum.HttpContentType.ApplicationJson)
        end)
        if ok then return {Body = res or "", StatusCode = 200} end
    end
    local globalFuncs = {"fetch", "http", "httpGet", "httpPost", "doRequest", "sendRequest"}
    for _, fname in ipairs(globalFuncs) do
        if type(_G[fname]) == "function" then
            local ok, res = pcall(_G[fname], {Url=url, Method=method, Headers=headers, Body=body})
            if ok and res then return res end
        end
    end
    return {Body = "", StatusCode = 0}
end

local function safeLoadstring(url)
    local ok, code = pcall(function() return game:HttpGet(url) end)
    if ok and code then
        local ok2, fn = pcall(loadstring, code)
        if ok2 and fn then return fn end
    end
    if type(syn) == "table" and type(syn.request) == "function" then
        local ok2, res = pcall(syn.request, {Url=url, Method="GET"})
        if ok2 and res and res.Body then
            local ok3, fn = pcall(loadstring, res.Body)
            if ok3 and fn then return fn end
        end
    end
    if type(request) == "function" then
        local ok2, res = pcall(request, {Url=url, Method="GET"})
        if ok2 and res and res.Body then
            local ok3, fn = pcall(loadstring, res.Body)
            if ok3 and fn then return fn end
        end
    end
    if type(http_request) == "function" then
        local ok2, res = pcall(http_request, {Url=url, Method="GET"})
        if ok2 and res and res.Body then
            local ok3, fn = pcall(loadstring, res.Body)
            if ok3 and fn then return fn end
        end
    end
    local ok4, body = pcall(function() return HttpService:GetAsync(url) end)
    if ok4 and body then
        local ok5, fn = pcall(loadstring, body)
        if ok5 and fn then return fn end
    end
    return nil
end

local function getDeviceInfo()
    local ok, UIS = pcall(function() return game:GetService("UserInputService") end)
    if ok and UIS then
        local touch = pcall(function() return UIS.TouchEnabled end) and UIS.TouchEnabled or false
        local keyboard = pcall(function() return UIS.KeyboardEnabled end) and UIS.KeyboardEnabled or false
        local gamepad = pcall(function() return UIS.GamepadEnabled end) and UIS.GamepadEnabled or false
        if touch and not keyboard then return "Mobile" end
        if gamepad and not keyboard then return "Console" end
        if keyboard then return "PC" end
    end
    return "Unknown"
end

local function detectExecutor()
    if type(identifyexecutor) == "function" then
        local ok, name = pcall(identifyexecutor)
        if ok and name and name ~= "" then executorName = tostring(name); return end
    end
    if type(getexecutorname) == "function" then
        local ok, name = pcall(getexecutorname)
        if ok and name and name ~= "" then executorName = tostring(name); return end
    end
    if type(EXECUTOR) == "string" and EXECUTOR ~= "" then
        executorName = EXECUTOR; return
    end
    local checks = {
        {"Potassium",    {"Potassium", "potassium"}},
        {"Synapse Z",    {"SynapseZ", "is_synapse_closure"}},
        {"Synapse X",    {"syn"}},
        {"Krnl",         {"KRNL_LOADED", "krnl"}},
        {"Fluxus",       {"Fluxus", "is_fluxus_closure", "FLUXUS_LOADED"}},
        {"Xeno",         {"Xeno", "is_xeno_closure", "XENO_LOADED"}},
        {"Solara",       {"Solara", "SOLARA_LOADED", "is_solara_closure"}},
        {"Wave",         {"Wave", "is_wave_closure", "WAVE_LOADED"}},
        {"Seliware",     {"Seliware", "SELIWARE_LOADED"}},
        {"Velocity",     {"Velocity", "VELOCITY_LOADED"}},
        {"Bunni",        {"Bunni", "bunni", "BUNNI_LOADED"}},
        {"Madium",       {"Madium", "is_madium_closure", "MADIUM_LOADED", "madium"}},
        {"Celery",       {"Celery", "CELERY_LOADED"}},
        {"Coco Z",       {"CocoZ", "COCOZ_LOADED"}},
        {"Delta",        {"Delta", "DELTA_LOADED", "delta"}},
        {"Arceus X",     {"ARCEUS_X", "ArceusX", "arceusx"}},
        {"Hydrogen",     {"Hydrogen", "HYDROGEN_LOADED"}},
        {"Evon",         {"Evon", "EVON_LOADED"}},
        {"Scriptware",   {"Scriptware", "SCRIPTWARE_LOADED"}},
        {"ProtoSmasher", {"ProtoSmasher", "PROTO_SMASHER"}},
        {"Electron",     {"Electron", "ELECTRON_LOADED"}},
    }
    for _, c in ipairs(checks) do
        for _, g in ipairs(c[2]) do
            if _G[g] ~= nil then executorName = c[1]; return end
        end
    end
    if type(syn) == "table" then executorName = "Synapse"; return end
    executorName = "Unknown"
end

local function sendWebhook(url, title, fields, color)
    pcall(function()
        local payload = HttpService:JSONEncode({
            embeds = {{
                title = title,
                color = color or 0x0066FF,
                fields = fields,
                footer = {text = "v" .. HUB_VERSION .. " • " .. HUB_NAME}
            }},
            username = HUB_NAME,
        })
        httpRequest(url, "POST", {["Content-Type"] = "application/json"}, payload)
    end)
end

local function sendStartWebhook()
    coroutine.wrap(function()
        local gameName = "Unknown"
        pcall(function()
            gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
        end)
        local fields = {
            {name = "User",     value = Player.DisplayName .. " (@" .. Player.Name .. ")", inline = true},
            {name = "ID",       value = tostring(Player.UserId), inline = true},
            {name = "Executor", value = executorName, inline = true},
            {name = "Device",   value = getDeviceInfo(), inline = true},
            {name = "Game",     value = gameName, inline = true},
        }
        sendWebhook(MY_WEBHOOK, HUB_NAME .. " — Launch", fields, 0x0066FF)
    end)()
end

local JoltModule = require(ReplicatedStorage:WaitForChild("Files"):WaitForChild("Shared"):WaitForChild("Components"):WaitForChild("Jolt"))
local UseM1Remote = JoltModule.Client("UseM1")
local SendM1UpdateRemote = JoltModule.Client("SendM1Update")

local function getMapBounds()
    local map = workspace:FindFirstChild("Map")
    if not map then return nil end
    local minX, minY, minZ = math.huge, math.huge, math.huge
    local maxX, maxY, maxZ = -math.huge, -math.huge, -math.huge
    for _, part in ipairs(map:GetDescendants()) do
        if part:IsA("BasePart") then
            local pos = part.Position
            local size = part.Size
            minX = math.min(minX, pos.X - size.X / 2)
            minY = math.min(minY, pos.Y - size.Y / 2)
            minZ = math.min(minZ, pos.Z - size.Z / 2)
            maxX = math.max(maxX, pos.X + size.X / 2)
            maxY = math.max(maxY, pos.Y + size.Y / 2)
            maxZ = math.max(maxZ, pos.Z + size.Z / 2)
        end
    end
    if minX == math.huge then return nil end
    return {
        min = Vector3.new(minX, minY, minZ),
        max = Vector3.new(maxX, maxY, maxZ),
    }
end

local function clampToMap(pos)
    local bounds = getMapBounds()
    if not bounds then return pos end
    return Vector3.new(
        math.clamp(pos.X, bounds.min.X, bounds.max.X),
        math.clamp(pos.Y, bounds.min.Y, bounds.max.Y),
        math.clamp(pos.Z, bounds.min.Z, bounds.max.Z)
    )
end

local function getClosestTarget()
    local closestTarget = nil
    local shortestDistance = AURA_RADIUS
    local character = Player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    local myHrp = character.HumanoidRootPart
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Player and not WHITELIST[player.Name] and not WHITELIST[player.DisplayName] then
            local pChar = player.Character
            if pChar and pChar:FindFirstChild("Humanoid") and pChar:FindFirstChild("HumanoidRootPart") then
                if pChar.Humanoid.Health > 0 and not pChar:GetAttribute("M1Immunity") then
                    local distance = (myHrp.Position - pChar.HumanoidRootPart.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestTarget = pChar
                    end
                end
            end
        end
    end
    return closestTarget
end

local function getClosestPlayerForFarm()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local character = Player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    local myHrp = character.HumanoidRootPart
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Player and not WHITELIST[player.Name] and not WHITELIST[player.DisplayName] then
            local pChar = player.Character
            if pChar and pChar:FindFirstChild("Humanoid") and pChar:FindFirstChild("HumanoidRootPart") then
                if pChar.Humanoid.Health > 0 then
                    local distance = (myHrp.Position - pChar.HumanoidRootPart.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

local function enableNoclip()
    if noclipConn then return end
    noclipConn = RunService.Stepped:Connect(function()
        local character = Player.Character
        if not character then return end
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

local function disableNoclip()
    if noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end
    local character = Player.Character
    if not character then return end
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
end

local m1Index = 0
local function getM1Index()
    m1Index = m1Index + 1
    return m1Index
end

detectExecutor()
sendStartWebhook()

local Rayfield
local fn = safeLoadstring("https://sirius.menu/rayfield")
if fn then
    local ok, lib = pcall(fn)
    if ok and lib then Rayfield = lib end
end

if not Rayfield then
    local fn2 = safeLoadstring("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua")
    if fn2 then
        local ok, lib = pcall(fn2)
        if ok and lib then Rayfield = lib end
    end
end

if not Rayfield then
    warn("[bulo hub] Failed to load Rayfield UI.")
    return
end

local Window = Rayfield:CreateWindow({
    Name = "bulo hub",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "https://discord.gg/WZp4DZ9QZs",
    ConfigurationSaving = {Enabled = false},
    Discord = {Enabled = false},
    KeySystem = false,
    Theme = "Amethyst"
})

local InfoTab = Window:CreateTab("Info", 4483362458)
InfoTab:CreateSection("Player Info")
InfoTab:CreateLabel("User: " .. Player.DisplayName .. " (@" .. Player.Name .. ")")
InfoTab:CreateLabel("ID: " .. tostring(Player.UserId))
InfoTab:CreateLabel("Executor: " .. executorName)
InfoTab:CreateLabel("Device: " .. getDeviceInfo())

local AntiFallTab = Window:CreateTab("Anti Fall", 4483362458)
AntiFallTab:CreateSection("Anti Fall")

AntiFallTab:CreateToggle({
    Name = "Enable Anti Fall",
    CurrentValue = false,
    Flag = "AntiFallToggle",
    Callback = function(val)
        antiFallEnabled = val
        if val then lastSafeCFrame = nil end
        Rayfield:Notify({
            Title = "Anti Fall",
            Content = val and "Anti Fall enabled" or "Anti Fall disabled",
            Duration = 2,
        })
    end
})

local MovementTab = Window:CreateTab("Movement", 4483362458)
MovementTab:CreateSection("Speed Hack")

MovementTab:CreateToggle({
    Name = "Enable Speed Hack",
    CurrentValue = false,
    Flag = "SpeedToggle",
    Callback = function(val)
        speedEnabled = val
        local character = Player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = val and SPEED_VALUE or defaultSpeed
            end
        end
        Rayfield:Notify({
            Title = "Speed Hack",
            Content = val and "Speed Hack enabled" or "Speed Hack disabled",
            Duration = 2,
        })
    end
})

MovementTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 500},
    Increment = 1,
    Suffix = "sp",
    CurrentValue = 50,
    Flag = "SpeedSlider",
    Callback = function(val)
        SPEED_VALUE = val
        if speedEnabled then
            local character = Player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid.WalkSpeed = SPEED_VALUE end
            end
        end
    end
})

MovementTab:CreateSection("Acceleration (Auto Dash)")

MovementTab:CreateToggle({
    Name = "Enable Acceleration",
    CurrentValue = false,
    Flag = "BlinkToggle",
    Callback = function(val)
        blinkEnabled = val
        Rayfield:Notify({
            Title = "Acceleration",
            Content = val and "Auto dash enabled" or "Acceleration disabled",
            Duration = 2,
        })
    end
})

MovementTab:CreateSlider({
    Name = "Dash Distance",
    Range = {1, 20},
    Increment = 1,
    Suffix = "st",
    CurrentValue = 5,
    Flag = "BlinkDistance",
    Callback = function(val)
        TELEPORT_DISTANCE = val
    end
})

MovementTab:CreateSlider({
    Name = "Dash Delay",
    Range = {1, 20},
    Increment = 1,
    Suffix = "ms",
    CurrentValue = 5,
    Flag = "BlinkDelay",
    Callback = function(val)
        BLINK_DELAY = val / 100
    end
})

local AutoFarmTab = Window:CreateTab("Auto Farm", 4483362458)
AutoFarmTab:CreateSection("Auto Farm")

AutoFarmTab:CreateToggle({
    Name = "Enable Auto Farm",
    CurrentValue = false,
    Flag = "AutoFarmToggle",
    Callback = function(val)
        autoFarmEnabled = val
        orbitAngle = 0
        if val then
            enableNoclip()
        else
            disableNoclip()
        end
        Rayfield:Notify({
            Title = "Auto Farm",
            Content = val and "Auto Farm enabled" or "Auto Farm disabled",
            Duration = 2,
        })
    end
})

AutoFarmTab:CreateSlider({
    Name = "Orbit Speed",
    Range = {10, 500},
    Increment = 1,
    Suffix = "sp",
    CurrentValue = 50,
    Flag = "AutoFarmSpeed",
    Callback = function(val)
        AUTO_FARM_SPEED = val
    end
})

AutoFarmTab:CreateSlider({
    Name = "Orbit Radius",
    Range = {2, 20},
    Increment = 1,
    Suffix = "st",
    CurrentValue = 5,
    Flag = "OrbitRadius",
    Callback = function(val)
        ORBIT_RADIUS = val
    end
})

local AuraTab = Window:CreateTab("Kill Aura", 4483362458)
AuraTab:CreateSection("Kill Aura")

AuraTab:CreateToggle({
    Name = "Enable Kill Aura",
    CurrentValue = false,
    Flag = "AuraToggle",
    Callback = function(val)
        AuraEnabled = val
    end
})

AuraTab:CreateSlider({
    Name = "Aura Radius",
    Range = {10, 200},
    Increment = 1,
    Suffix = "st",
    CurrentValue = 50,
    Flag = "AuraRadius",
    Callback = function(val)
        AURA_RADIUS = val
    end
})

AuraTab:CreateSection("Whitelist")

AuraTab:CreateInput({
    Name = "Add to Whitelist",
    PlaceholderText = "Player username...",
    RemoveTextAfterFocusLost = true,
    Flag = "WhitelistInput",
    Callback = function(text)
        local name = text:match("^%s*(.-)%s*$")
        if name and name ~= "" then
            WHITELIST[name] = true
            Rayfield:Notify({
                Title = "Whitelist",
                Content = name .. " added to whitelist.",
                Duration = 3,
            })
        end
    end
})

AuraTab:CreateButton({
    Name = "Add All Online Players",
    Callback = function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Player then
                WHITELIST[player.Name] = true
            end
        end
        Rayfield:Notify({
            Title = "Whitelist",
            Content = "All online players added to whitelist.",
            Duration = 3,
        })
    end
})

AuraTab:CreateButton({
    Name = "Clear Whitelist",
    Callback = function()
        WHITELIST = {}
        Rayfield:Notify({
            Title = "Whitelist",
            Content = "Whitelist cleared.",
            Duration = 3,
        })
    end
})

AuraTab:CreateButton({
    Name = "Show Whitelist",
    Callback = function()
        local names = {}
        for name, _ in pairs(WHITELIST) do
            table.insert(names, name)
        end
        local text = #names > 0 and table.concat(names, ", ") or "Empty"
        Rayfield:Notify({
            Title = "Whitelist (" .. #names .. ")",
            Content = text,
            Duration = 6,
        })
    end
})

RunService.Heartbeat:Connect(function()
    if not antiFallEnabled then return end
    local character = Player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not rootPart or not humanoid then return end
    if humanoid.FloorMaterial ~= Enum.Material.Air and rootPart.Position.Y >= MIN_Y then
        lastSafeCFrame = rootPart.CFrame
    end
    if rootPart.Position.Y < MIN_Y then
        rootPart.AssemblyLinearVelocity  = Vector3.new(0, 0, 0)
        rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        if lastSafeCFrame then
            rootPart.CFrame = lastSafeCFrame
        else
            rootPart.CFrame = CFrame.new(rootPart.Position.X, MIN_Y + 4, rootPart.Position.Z)
        end
    end
end)

Player.CharacterAdded:Connect(function(character)
    if speedEnabled then
        local humanoid = character:WaitForChild("Humanoid")
        if humanoid then humanoid.WalkSpeed = SPEED_VALUE end
    end
    if autoFarmEnabled then enableNoclip() end
end)

RunService.Heartbeat:Connect(function()
    if not speedEnabled then return end
    local character = Player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.WalkSpeed ~= SPEED_VALUE then
        humanoid.WalkSpeed = SPEED_VALUE
    end
end)

task.spawn(function()
    while true do
        task.wait(BLINK_DELAY)
        if blinkEnabled then
            local character = Player.Character
            if character then
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if rootPart and humanoid and humanoid.MoveDirection.Magnitude > 0 then
                    local moveDirection = humanoid.MoveDirection
                    rootPart.CFrame = rootPart.CFrame + (moveDirection * TELEPORT_DISTANCE)
                end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function(dt)
    if not autoFarmEnabled then return end
    local character = Player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    local target = getClosestPlayerForFarm()
    if not target then return end
    local targetChar = target.Character
    if not targetChar then return end
    local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
    local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
    if not targetHrp or not targetHumanoid then return end
    if targetHumanoid.Health <= 0 then return end
    orbitAngle = orbitAngle + (AUTO_FARM_SPEED * dt)
    if orbitAngle >= math.pi * 2 then
        orbitAngle = orbitAngle - math.pi * 2
    end
    local centerPos = targetHrp.Position
    local offsetX = math.cos(orbitAngle) * ORBIT_RADIUS
    local offsetZ = math.sin(orbitAngle) * ORBIT_RADIUS
    local orbitPos = Vector3.new(
        centerPos.X + offsetX,
        centerPos.Y,
        centerPos.Z + offsetZ
    )
    orbitPos = clampToMap(orbitPos)
    local lookDir = (centerPos - orbitPos)
    if lookDir.Magnitude > 0 then
        rootPart.CFrame = CFrame.new(orbitPos, orbitPos + lookDir.Unit)
    else
        rootPart.CFrame = CFrame.new(orbitPos)
    end
    rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
end)

task.spawn(function()
    while task.wait(ATTACK_SPEED) do
        if autoFarmEnabled then
            local target = getClosestPlayerForFarm()
            if target then
                local targetChar = target.Character
                if targetChar then
                    local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
                    if targetHumanoid and targetHumanoid.Health > 0 then
                        local currentIndex = getM1Index()
                        local timestamp = workspace:GetServerTimeNow()
                        UseM1Remote:Fire({
                            Timestamp = timestamp,
                            Hits = {targetHumanoid},
                            Index = currentIndex
                        })
                        SendM1UpdateRemote:Fire(currentIndex, targetHumanoid)
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(ATTACK_SPEED) do
        if AuraEnabled then
            local target = getClosestTarget()
            if target then
                local targetHumanoid = target:FindFirstChild("Humanoid")
                if targetHumanoid then
                    local currentIndex = getM1Index()
                    local timestamp = workspace:GetServerTimeNow()
                    UseM1Remote:Fire({
                        Timestamp = timestamp,
                        Hits = {targetHumanoid},
                        Index = currentIndex
                    })
                    SendM1UpdateRemote:Fire(currentIndex, targetHumanoid)
                end
            end
        end
    end
end)