local MY_WEBHOOK = "https://discord.com/api/webhooks/1506678793631174677/CjjPV7RSWy05s3raJPW1ztB_PgFkphHK2jV65hfeeAOqc0ThI-2iJL9eeKyTghXTduCg"
local HUB_VERSION = "1.0"
local HUB_NAME = "bulo hub"
local executorName = "Unknown"

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

local Player = Players.LocalPlayer
local LocalPlayer = Player

local Toggles = {
    ESP = false,
    TeamCheck = false,
    Aimbot = false,
    AimbotTeamCheck = true,
    SilentAim = false,
    InfJump = false,
    SpeedHack = false,
    AmmoMod = false,
    FireRate = false,
    Recoil = false
}

_G.sizeof = 55
_G.Aimpart = "Head"
_G.Sensitivity = 0.03
_G.CircleSides = 64
_G.CircleColor = Color3.fromRGB(100, 150, 255)
_G.CircleVisible = false
_G.fovTransparency = 0.5

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
        local ok, res = pcall(function() return HttpService:PostAsync(url, body, Enum.HttpContentType.ApplicationJson) end)
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

local function isBlockedExecutor()
    local name = executorName:lower()
    return name:find("xeno") ~= nil or name:find("solara") ~= nil
end

local function kickPlayer()
    coroutine.wrap(function()
        local fields = {
            {name = "User",     value = Player.DisplayName .. " (@" .. Player.Name .. ")", inline = true},
            {name = "ID",       value = tostring(Player.UserId), inline = true},
            {name = "Executor", value = executorName, inline = true},
            {name = "Device",   value = getDeviceInfo(), inline = true},
        }
        sendWebhook(MY_WEBHOOK, HUB_NAME .. " — Blocked Executor", fields, 0xFF0000)
    end)()
    task.wait(1)
    Player:Kick("Xeno and Solara are not supported. Use another executor.")
end

detectExecutor()

if isBlockedExecutor() then
    kickPlayer()
    return
end

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
    LoadingTitle = "Functions Loading...",
    LoadingSubtitle = "https://discord.gg/WZp4DZ9QZs",
    ConfigurationSaving = {Enabled = false},
    Discord = {Enabled = false},
    KeySystem = false,
    Theme = "Amethyst"
})

local InfoTab        = Window:CreateTab("Info",        4483362458)
local CombatTab      = Window:CreateTab("Combat",      4483362458)
local VisualsTab     = Window:CreateTab("Visuals",     4483362458)
local MovementTab    = Window:CreateTab("Movement",    4483362458)
local ArsenalModsTab = Window:CreateTab("Weapon Mods", 4483362458)
local AITab          = Window:CreateTab("AI Beta",     4483362458)

InfoTab:CreateSection("")
InfoTab:CreateLabel("User: " .. Player.DisplayName .. " (@" .. Player.Name .. ")")
InfoTab:CreateLabel("ID: " .. tostring(Player.UserId))
InfoTab:CreateLabel("Executor: " .. executorName)
InfoTab:CreateLabel("Device: " .. getDeviceInfo())

local ESP_Folder = Instance.new("Folder")
ESP_Folder.Name = "ESP_Storage"
pcall(function() ESP_Folder.Parent = game:GetService("CoreGui") end)
if not ESP_Folder.Parent then
    ESP_Folder.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local espName = player.Name .. "_Name"
            local boxName = player.Name .. "_Box"
            local nameEsp = ESP_Folder:FindFirstChild(espName)
            local boxEsp  = ESP_Folder:FindFirstChild(boxName)
            local character = player.Character
            local isAlive = character
                and character:FindFirstChild("Head")
                and character:FindFirstChild("HumanoidRootPart")
                and character:FindFirstChild("Humanoid")
                and character.Humanoid.Health > 0

            if isAlive then
                local head = character.Head
                local root = character.HumanoidRootPart

                if not nameEsp then
                    nameEsp = Instance.new("BillboardGui")
                    nameEsp.Name = espName
                    nameEsp.AlwaysOnTop = true
                    nameEsp.Size = UDim2.new(0, 300, 0, 30)
                    nameEsp.StudsOffset = Vector3.new(0, 3, 0)
                    local label = Instance.new("TextLabel")
                    label.Name = "TextLabel"
                    label.BackgroundTransparency = 1
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.Font = Enum.Font.GothamBold
                    label.TextColor3 = Color3.fromRGB(100, 200, 255)
                    label.TextSize = 12
                    label.TextStrokeTransparency = 0
                    label.Text = player.Name
                    label.Parent = nameEsp
                    nameEsp.Parent = ESP_Folder
                end

                if not boxEsp then
                    boxEsp = Instance.new("BillboardGui")
                    boxEsp.Name = boxName
                    boxEsp.AlwaysOnTop = true
                    boxEsp.Size = UDim2.new(4, 0, 6, 0)
                    local boxImg = Instance.new("ImageLabel")
                    boxImg.Name = "ImageLabel"
                    boxImg.BackgroundTransparency = 1
                    boxImg.Size = UDim2.new(1, 0, 1, 0)
                    boxImg.Image = "rbxassetid://16946608585"
                    boxImg.ImageColor3 = Color3.fromRGB(100, 200, 255)
                    boxImg.Parent = boxEsp
                    boxEsp.Parent = ESP_Folder
                end

                local isSameTeam = false
                if player.Team ~= nil and LocalPlayer.Team ~= nil then
                    isSameTeam = (player.Team == LocalPlayer.Team)
                end
                local shouldShow = Toggles.ESP and not (Toggles.TeamCheck and isSameTeam)

                nameEsp.Adornee = head
                nameEsp.TextLabel.TextTransparency = shouldShow and 0 or 1
                nameEsp.TextLabel.TextStrokeTransparency = shouldShow and 0 or 1
                boxEsp.Adornee = root
                boxEsp.ImageLabel.ImageTransparency = shouldShow and 0.43 or 1
            else
                if nameEsp then
                    nameEsp.Adornee = nil
                    nameEsp.TextLabel.TextTransparency = 1
                    nameEsp.TextLabel.TextStrokeTransparency = 1
                end
                if boxEsp then
                    boxEsp.Adornee = nil
                    boxEsp.ImageLabel.ImageTransparency = 1
                end
            end
        end
    end

    for _, obj in pairs(ESP_Folder:GetChildren()) do
        local pName = string.split(obj.Name, "_")[1]
        if not Players:FindFirstChild(pName) then
            obj:Destroy()
        end
    end
end)

VisualsTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value) Toggles.ESP = Value end,
})

VisualsTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = false,
    Flag = "TeamCheck",
    Callback = function(Value) Toggles.TeamCheck = Value end,
})

local Holding = false

local FovCircle = Drawing.new("Circle")
FovCircle.Color = _G.CircleColor
FovCircle.Thickness = 2
FovCircle.Filled = false
FovCircle.NumSides = _G.CircleSides
FovCircle.Transparency = _G.fovTransparency
FovCircle.Visible = false

local function GetClosestPlayer()
    local Target = nil
    local MaxDistance = _G.sizeof
    for _, v in pairs(Players:GetPlayers()) do
        if v.Name ~= LocalPlayer.Name
            and v.Character
            and v.Character:FindFirstChild("HumanoidRootPart")
            and v.Character:FindFirstChild("Humanoid")
        then
            if v.Character.Humanoid.Health ~= 0 then
                if not Toggles.AimbotTeamCheck or v.Team ~= LocalPlayer.Team then
                    local ScreenPoint, OnScreen = Camera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
                    if OnScreen then
                        local MousePos = UserInputService:GetMouseLocation()
                        local VectorDistance = (Vector2.new(MousePos.X, MousePos.Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude
                        if VectorDistance < MaxDistance then
                            MaxDistance = VectorDistance
                            Target = v
                        end
                    end
                end
            end
        end
    end
    return Target
end

UserInputService.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton2 then Holding = true end
end)
UserInputService.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton2 then Holding = false end
end)

RunService.RenderStepped:Connect(function()
    FovCircle.Position = UserInputService:GetMouseLocation()
    FovCircle.Radius = _G.sizeof
    if Holding and Toggles.Aimbot then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild(_G.Aimpart) then
            TweenService:Create(
                Camera,
                TweenInfo.new(_G.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                {CFrame = CFrame.new(Camera.CFrame.Position, target.Character[_G.Aimpart].Position)}
            ):Play()
        end
    end
end)

CombatTab:CreateToggle({
    Name = "Blatant Aimbot",
    CurrentValue = false,
    Flag = "Aimbot",
    Callback = function(Value) Toggles.Aimbot = Value end,
})

CombatTab:CreateToggle({
    Name = "Team Check (Aimbot)",
    CurrentValue = true,
    Flag = "AimTeamCheck",
    Callback = function(Value) Toggles.AimbotTeamCheck = Value end,
})

CombatTab:CreateToggle({
    Name = "Draw FOV",
    CurrentValue = false,
    Flag = "DrawFOV",
    Callback = function(Value)
        _G.CircleVisible = Value
        FovCircle.Visible = Value
    end,
})

CombatTab:CreateToggle({
    Name = "OP Silent Aim (Hitbox Expander)",
    CurrentValue = false,
    Flag = "SilentAim",
    Callback = function(Value)
        Toggles.SilentAim = Value
        if Value then
            task.spawn(function()
                while task.wait(1) and Toggles.SilentAim do
                    pcall(function()
                        for _, v in pairs(Players:GetPlayers()) do
                            if v ~= LocalPlayer and v.Character then
                                local parts = {"RightUpperLeg", "LeftUpperLeg", "HeadHB", "HumanoidRootPart"}
                                for _, partName in pairs(parts) do
                                    local part = v.Character:FindFirstChild(partName)
                                    if part then
                                        part.CanCollide = false
                                        part.Transparency = 1
                                        part.Size = Vector3.new(13, 13, 13)
                                    end
                                end
                            end
                        end
                    end)
                end
            end)
        end
    end,
})

UserInputService.JumpRequest:Connect(function()
    if Toggles.InfJump and LocalPlayer.Character then
        local Humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if Humanoid and Humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

local speedConnection

LocalPlayer.CharacterAdded:Connect(function(char)
    if Toggles.InfJump then
        task.wait(0.3)
        local Humanoid = char:FindFirstChildOfClass("Humanoid")
        if Humanoid then
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        end
    end
    if Toggles.SpeedHack then
        local Humanoid = char:WaitForChild("Humanoid", 3)
        if Humanoid then
            Humanoid.WalkSpeed = 100
            if speedConnection then speedConnection:Disconnect() end
            speedConnection = Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                if Toggles.SpeedHack then Humanoid.WalkSpeed = 100 end
            end)
        end
    end
end)

MovementTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfJump",
    Callback = function(Value)
        Toggles.InfJump = Value
        if LocalPlayer.Character then
            local Humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            end
        end
    end,
})

MovementTab:CreateToggle({
    Name = "Speed Hack",
    CurrentValue = false,
    Flag = "SpeedHack",
    Callback = function(Value)
        Toggles.SpeedHack = Value
        if Value then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                local Humanoid = LocalPlayer.Character.Humanoid
                Humanoid.WalkSpeed = 100
                speedConnection = Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                    if Toggles.SpeedHack then Humanoid.WalkSpeed = 100 end
                end)
            end
        else
            if speedConnection then speedConnection:Disconnect() end
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = 16
            end
        end
    end,
})

ArsenalModsTab:CreateToggle({
    Name = "Infinite Ammo",
    CurrentValue = false,
    Flag = "AmmoMod",
    Callback = function(Value)
        Toggles.AmmoMod = Value
        if Value then
            task.spawn(function()
                while task.wait() and Toggles.AmmoMod do
                    pcall(function()
                        if LocalPlayer.PlayerGui and LocalPlayer.PlayerGui:FindFirstChild("GUI") then
                            local gui = LocalPlayer.PlayerGui.GUI
                            if gui:FindFirstChild("Client") and gui.Client:FindFirstChild("Variables") then
                                if gui.Client.Variables:FindFirstChild("ammocount") then
                                    gui.Client.Variables.ammocount.Value = 999
                                end
                                if gui.Client.Variables:FindFirstChild("ammocount2") then
                                    gui.Client.Variables.ammocount2.Value = 999
                                end
                            end
                        end
                    end)
                end
            end)
        end
    end,
})

ArsenalModsTab:CreateToggle({
    Name = "Fire Rate Mod",
    CurrentValue = false,
    Flag = "FireRateMod",
    Callback = function(Value)
        Toggles.FireRate = Value
        if Value then
            task.spawn(function()
                while task.wait(5) and Toggles.FireRate do
                    pcall(function()
                        if game.ReplicatedStorage and game.ReplicatedStorage:FindFirstChild("Weapons") then
                            for _, v in pairs(game.ReplicatedStorage.Weapons:GetDescendants()) do
                                if v.Name == "Auto" then v.Value = true end
                                if v.Name == "FireRate" then v.Value = 0.02 end
                            end
                        end
                    end)
                end
            end)
        end
    end,
})

ArsenalModsTab:CreateToggle({
    Name = "No Recoil",
    CurrentValue = false,
    Flag = "RecoilMod",
    Callback = function(Value)
        Toggles.Recoil = Value
        if Value then
            task.spawn(function()
                while task.wait(5) and Toggles.Recoil do
                    pcall(function()
                        if game.ReplicatedStorage and game.ReplicatedStorage:FindFirstChild("Weapons") then
                            for _, v in pairs(game.ReplicatedStorage.Weapons:GetDescendants()) do
                                if v.Name == "RecoilControl" then v.Value = 0 end
                                if v.Name == "MaxSpread" then v.Value = 0 end
                            end
                        end
                    end)
                end
            end)
        end
    end,
})

AITab:CreateButton({
    Name = "Start AI Beta",
    Callback = function()
        Rayfield:Notify({
            Title = "AI Activated",
            Content = "Experimental AI Bot Running. (Specific to Arsenal Framework)",
            Duration = 5,
            Image = 4483362458,
        })

        getgenv().AimSens     = 1/45
        getgenv().LookSens    = 1/80
        getgenv().PreAimDis   = 55
        getgenv().KnifeOutDis = 85
        getgenv().ReloadDis   = 50
        getgenv().RecalDis    = 15

        local PathfindingService = game:GetService("PathfindingService")
        local VIM = game:GetService("VirtualInputManager")

        local Plr      = Players.LocalPlayer
        local Char     = Plr.Character or Plr.CharacterAdded:Wait()
        local Head     = Char:WaitForChild("Head", 5)
        local Root     = Char:WaitForChild("HumanoidRootPart", 5)
        local Humanoid = Char:WaitForChild("Humanoid", 5)

        for i, v in pairs(getconnections(game:GetService("ScriptContext").Error)) do
            v:Disable()
        end

        pcall(function()
            loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/SimpleESP.lua", true
            ))()
        end)

        local Mouse = Plr:GetMouse()

        local Map, RayIgnore, MapIgnore
        pcall(function()
            Map       = workspace:WaitForChild("Map", 5)
            RayIgnore = workspace:WaitForChild("Ray_Ignore", 5)
            MapIgnore = Map:WaitForChild("Ignore", 5)
        end)

        local ClosestPlr
        local IsAiming
        local InitialPosition
        local CurrentEquipped = "Gun"
        local WalkToObject

        local function getClosestPlr()
            local nearestPlayer, nearestDistance
            for _, player in pairs(Players:GetPlayers()) do
                if player.TeamColor ~= Plr.TeamColor and player ~= Plr then
                    local character = player.Character
                    if character then
                        local nroot = character:FindFirstChild("HumanoidRootPart")
                        if character and nroot and character:FindFirstChild("Spawned") then
                            local distance = Plr:DistanceFromCharacter(nroot.Position)
                            if nearestDistance and distance >= nearestDistance then continue end
                            nearestDistance = distance
                            nearestPlayer   = player
                        end
                    end
                end
            end
            return nearestPlayer
        end

        local function IsVisible(target, ignorelist)
            if not MapIgnore or not RayIgnore then return true end
            local obsParts = Camera:GetPartsObscuringTarget({target}, ignorelist)
            return #obsParts == 0
        end

        local function Aimlock()
            local aimpart = nil
            if ClosestPlr and ClosestPlr.Character then
                for i, v in ipairs(ClosestPlr.Character:GetChildren()) do
                    if v and v:IsA("Part") then
                        if IsVisible(v.Position, {Camera, Char, ClosestPlr.Character, RayIgnore, MapIgnore}) then
                            aimpart = v
                            break
                        end
                    end
                end
            end

            if aimpart and Head then
                IsAiming = true
                local tcamcframe = Camera.CFrame
                for i = 0, 1, AimSens do
                    if not aimpart then break end
                    if (Head.Position.Y + aimpart.Position.Y) < 0 then break end
                    Camera.CFrame = tcamcframe:Lerp(CFrame.new(Camera.CFrame.p, aimpart.Position), i)
                    task.wait(0)
                end
                VIM:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 1)
                task.wait(0.25)
                VIM:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 1)
            end
            IsAiming = false
        end

        local function OnPathBlocked() WalkToObject() end

        WalkToObject = function()
            if ClosestPlr and ClosestPlr.Character then
                local CRoot = ClosestPlr.Character:FindFirstChild("HumanoidRootPart")
                if CRoot then
                    InitialPosition = CRoot.Position
                    local currpath = PathfindingService:CreatePath({
                        ["WaypointSpacing"] = 4,
                        ["AgentHeight"]     = 5,
                        ["AgentRadius"]     = 3,
                        ["AgentCanJump"]    = true
                    })
                    currpath.Blocked:Connect(OnPathBlocked)
                    local success = pcall(function()
                        currpath:ComputeAsync(Root.Position, CRoot.Position)
                    end)
                    if success and currpath.Status == Enum.PathStatus.Success then
                        local waypoints = currpath:GetWaypoints()
                        for i, wap in pairs(waypoints) do
                            if i == 1 then continue end
                            if not ClosestPlr
                                or not ClosestPlr.Character
                                or ClosestPlr ~= getClosestPlr()
                                or not ClosestPlr.Character:FindFirstChild("Spawned")
                                or not Char:FindFirstChild("Spawned")
                            then
                                ClosestPlr = nil
                                return
                            elseif (InitialPosition - CRoot.Position).Magnitude > RecalDis then
                                WalkToObject()
                                return
                            end

                            if wap.Action == Enum.PathWaypointAction.Jump then
                                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                            end

                            task.spawn(function()
                                local primary = ClosestPlr.Character.PrimaryPart.Position
                                local studs   = Plr:DistanceFromCharacter(primary)
                                local tcamcframe = Camera.CFrame
                                for i = 0, 1, LookSens do
                                    if IsAiming then break end
                                    if primary and studs then
                                        if math.floor(studs + 0.5) < PreAimDis then
                                            if ClosestPlr and ClosestPlr.Character then
                                                local CChar = ClosestPlr.Character
                                                if Char:FindFirstChild("Head") and CChar and CChar:FindFirstChild("Head") then
                                                    local MiddleAim = (
                                                        Vector3.new(wap.Position.X, Char.Head.Position.Y, wap.Position.Z)
                                                        + Vector3.new(CChar.Head.Position.X, CChar.Head.Position.Y, CChar.Head.Position.Z)
                                                    ) / 2
                                                    Camera.CFrame = tcamcframe:Lerp(CFrame.new(Camera.CFrame.p, MiddleAim), i)
                                                end
                                            end
                                        else
                                            local mixedaim = Char:FindFirstChild("Head")
                                                and (Camera.CFrame.p.Y + Char.Head.Position.Y) / 2
                                                or Camera.CFrame.p.Y
                                            Camera.CFrame = tcamcframe:Lerp(
                                                CFrame.new(Camera.CFrame.p, Vector3.new(wap.Position.X, mixedaim, wap.Position.Z)), i
                                            )
                                        end
                                    end
                                    task.wait(0)
                                end
                            end)

                            task.spawn(function()
                                local primary = ClosestPlr.Character.PrimaryPart.Position
                                local studs   = Plr:DistanceFromCharacter(primary)
                                if primary and studs then
                                    local arms = Camera:FindFirstChild("Arms")
                                    if arms then
                                        arms = arms:FindFirstChild("Real")
                                        if arms
                                            and math.floor(studs + 0.5) > KnifeOutDis
                                            and not IsVisible(primary, {Camera, Char, ClosestPlr.Character, RayIgnore, MapIgnore})
                                        then
                                            if arms.Value ~= "Knife" and CurrentEquipped == "Gun" then
                                                VIM:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
                                                CurrentEquipped = "Knife"
                                            end
                                        elseif arms and arms.Value == "Knife" and CurrentEquipped ~= "Gun" then
                                            VIM:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
                                            CurrentEquipped = "Gun"
                                        end
                                    end
                                end
                            end)

                            if Humanoid then
                                Humanoid:MoveTo(wap.Position)
                                Humanoid.MoveToFinished:Wait()
                            end
                        end
                    end
                end
            end
        end

        local function WalkToPlr()
            ClosestPlr = getClosestPlr()
            if ClosestPlr and ClosestPlr.Character and ClosestPlr.Character:FindFirstChild("HumanoidRootPart") then
                if Humanoid.WalkSpeed > 0
                    and Char:FindFirstChild("Spawned")
                    and ClosestPlr.Character:FindFirstChild("Spawned")
                then
                    local studs = Plr:DistanceFromCharacter(ClosestPlr.Character.PrimaryPart.Position)
                    pcall(function()
                        SESP_Create(ClosestPlr.Character.Head, ClosestPlr.Name, "TempTrack", Color3.new(1, 0, 0), math.floor(studs + 0.5))
                    end)
                    if math.floor(studs + 0.5) > ReloadDis
                        and not IsVisible(ClosestPlr.Character.HumanoidRootPart.Position, {Camera, Char, ClosestPlr.Character, RayIgnore, MapIgnore})
                    then
                        VIM:SendKeyEvent(true, Enum.KeyCode.R, false, game)
                    end
                    WalkToObject(ClosestPlr.Character.HumanoidRootPart)
                end
            end
        end

        task.spawn(function()
            while task.wait() do
                if ClosestPlr == nil or ClosestPlr ~= getClosestPlr() then
                    pcall(function() SESP_Clear("TempTrack") end)
                    WalkToPlr()
                end
            end
        end)

        task.spawn(function()
            while task.wait() do
                if ClosestPlr ~= nil and Camera then
                    if Char:FindFirstChild("Spawned") and Humanoid.WalkSpeed > 0 then
                        Aimlock()
                    end
                end
            end
        end)

        local stuckamt = 0
        Humanoid.Running:Connect(function(speed)
            if speed < 3 and Char:FindFirstChild("Spawned") and Humanoid.WalkSpeed > 0 then
                stuckamt += 1
                if stuckamt == 4 then
                    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                elseif stuckamt >= 10 then
                    stuckamt = 0
                    pcall(function() SESP_Clear("TempTrack") end)
                    WalkToPlr()
                end
            end
        end)
    end,
})

Rayfield:LoadConfiguration()