local MY_WEBHOOK = "https://discord.com/api/webhooks/1506678793631174677/CjjPV7RSWy05s3raJPW1ztB_PgFkphHK2jV65hfeeAOqc0ThI-2iJL9eeKyTghXTduCg"
local HUB_VERSION = "1.0"
local HUB_NAME = "bulo hub"
local executorName = "Unknown"

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

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
        if ok and res then return {Body=res, StatusCode=200} end
    end
    if method == "GET" then
        local ok, res = pcall(function() return HttpService:GetAsync(url) end)
        if ok and res then return {Body=res, StatusCode=200} end
    end
    if method == "POST" and body then
        local ok, res = pcall(function()
            return HttpService:PostAsync(url, body, Enum.HttpContentType.ApplicationJson)
        end)
        if ok then return {Body=res or "", StatusCode=200} end
    end
    return {Body="", StatusCode=0}
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
    local ok4, body2 = pcall(function() return HttpService:GetAsync(url) end)
    if ok4 and body2 then
        local ok5, fn = pcall(loadstring, body2)
        if ok5 and fn then return fn end
    end
    return nil
end

local function getDeviceInfo()
    local ok, UIS2 = pcall(function() return game:GetService("UserInputService") end)
    if ok and UIS2 then
        local touch = pcall(function() return UIS2.TouchEnabled end) and UIS2.TouchEnabled or false
        local keyboard = pcall(function() return UIS2.KeyboardEnabled end) and UIS2.KeyboardEnabled or false
        local gamepad = pcall(function() return UIS2.GamepadEnabled end) and UIS2.GamepadEnabled or false
        if touch and not keyboard then return "Mobile" end
        if gamepad and not keyboard then return "Console" end
        if keyboard then return "PC" end
    end
    return "Unknown"
end

local function detectExecutor()
    if type(identifyexecutor) == "function" then
        local ok, name = pcall(identifyexecutor)
        if ok and name and name ~= "" then 
            executorName = tostring(name) 
            return 
        end
    end
    if type(getexecutorname) == "function" then
        local ok, name = pcall(getexecutorname)
        if ok and name and name ~= "" then 
            executorName = tostring(name) 
            return 
        end
    end
    local checks = {
        {"Potassium", {"Potassium", "potassium"}},
        {"Synapse Z", {"SynapseZ", "is_synapse_closure"}},
        {"Synapse X", {"syn"}},
        {"Krnl", {"KRNL_LOADED", "krnl"}},
        {"Fluxus", {"Fluxus", "is_fluxus_closure", "FLUXUS_LOADED"}},
        {"Xeno", {"Xeno", "is_xeno_closure", "XENO_LOADED"}},
        {"Solara", {"Solara", "SOLARA_LOADED", "is_solara_closure"}},
        {"Wave", {"Wave", "is_wave_closure", "WAVE_LOADED"}},
        {"Seliware", {"Seliware", "SELIWARE_LOADED"}},
        {"Velocity", {"Velocity", "VELOCITY_LOADED"}},
        {"Bunni", {"Bunni", "bunni", "BUNNI_LOADED"}},
        {"Madium", {"Madium", "is_madium_closure", "MADIUM_LOADED", "madium"}},
        {"Celery", {"Celery", "CELERY_LOADED"}},
        {"Coco Z", {"CocoZ", "COCOZ_LOADED"}},
        {"Delta", {"Delta", "DELTA_LOADED", "delta"}},
        {"Arceus X", {"ARCEUS_X", "ArceusX", "arceusx"}},
        {"Hydrogen", {"Hydrogen", "HYDROGEN_LOADED"}},
        {"Evon", {"Evon", "EVON_LOADED"}},
        {"Scriptware", {"Scriptware", "SCRIPTWARE_LOADED"}},
        {"ProtoSmasher", {"ProtoSmasher", "PROTO_SMASHER"}},
        {"Electron", {"Electron", "ELECTRON_LOADED"}},
    }
    for _, c in ipairs(checks) do
        for _, g in ipairs(c[2]) do
            if _G[g] ~= nil then 
                executorName = c[1] 
                return 
            end
        end
    end
    if type(syn) == "table" then 
        executorName = "Synapse" 
        return 
    end
    executorName = "Unknown"
end

local function sendWebhook(url, title, fields, color)
    pcall(function()
        local payload = HttpService:JSONEncode({
            embeds = {{
                title = title,
                color = color or 0x0066FF,
                fields = fields,
                footer = {text = "v"..HUB_VERSION.." - "..HUB_NAME}
            }},
            username = HUB_NAME,
        })
        httpRequest(url, "POST", {["Content-Type"]="application/json"}, payload)
    end)
end

local function sendStartWebhook()
    coroutine.wrap(function()
        local gameName = "Unknown"
        pcall(function()
            gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
        end)
        local fields = {
            {name="User", value=Player.DisplayName.." (@"..Player.Name..")", inline=true},
            {name="ID", value=tostring(Player.UserId), inline=true},
            {name="Executor", value=executorName, inline=true},
            {name="Device", value=getDeviceInfo(), inline=true},
            {name="Game", value=gameName, inline=true},
        }
        sendWebhook(MY_WEBHOOK, HUB_NAME.." - Launch", fields, 0x0066FF)
    end)()
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

local DrawingAvailable = false
pcall(function()
    local t = Drawing.new("Square") 
    t:Remove() 
    DrawingAvailable = true
end)

local FakeDrawingMeta = {
    __index = function(t,k) return rawget(t,k) end,
    __newindex = function(t,k,v) rawset(t,k,v) end,
}
local function MakeDrawingStub()
    local obj = setmetatable({
        Visible=false, Color=Color3.new(1,1,1), Transparency=1,
        Thickness=1, Text="", Size=14, Position=Vector2.new(0,0),
        Radius=100, NumSides=64, Filled=false, Center=false, Outline=false,
    }, FakeDrawingMeta)
    obj.Remove = function() end
    return obj
end
local function SafeDrawing(drawType)
    if DrawingAvailable then
        local ok, obj = pcall(function() return Drawing.new(drawType) end)
        if ok then return obj end
    end
    return MakeDrawingStub()
end

local Cfg = {
    SpeedhackEnabled = false,
    SpeedMultiplier = 15,
    AntiSlowdown = false,
    NoclipEnabled = false,
    InfJumpEnabled = false,
    InfJumpForce = 50,
    HitboxEnabled = false,
    HitboxSize = 20,
}

local ESPConfig = {
    Enabled = false,
    ShowBoxes = true,
    ShowNames = true,
    ShowHealthBar = true,
    ShowTeamColor = true,
    TextSize = 14,
    BoxThickness = 2,
    BoxTransparency = 0.5,
}
local ESPObjects = {}

local originalHRPData = {}

local function GetTeamStr(p)
    if p and p.Team then return string.lower(p.Team.Name) else return "" end
end

local function IsTeammate(p)
    if not Player.Team then return false end
    local mt = GetTeamStr(Player)
    local tt = GetTeamStr(p)
    if mt == tt and mt ~= "" then return true end
    local function isCD(t)
        return (string.find(t,"class") and string.find(t,"d")) or string.find(t,"chaos") or string.find(t,"insurgency")
    end
    if isCD(mt) and isCD(tt) then return true end
    local function isFoundation(t)
        return not isCD(t) and t~="choosing" and t~="lobby" and t~="spectator" and t~=""
    end
    if isFoundation(mt) and isFoundation(tt) then return true end
    return false
end

local function isAlly(p)
    if p == Player then return true end
    if not p.Team then return false end
    return IsTeammate(p)
end

local function saveOriginalHRP(player)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local id = tostring(player.UserId)
    if not originalHRPData[id] then
        originalHRPData[id] = {
            Size = hrp.Size,
            Transparency = hrp.Transparency,
            BrickColor = hrp.BrickColor,
            Material = hrp.Material,
            CanCollide = hrp.CanCollide,
        }
    end
end

local function restoreHRP(player)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local id = tostring(player.UserId)
    local data = originalHRPData[id]
    if data then
        pcall(function()
            hrp.Size = data.Size
            hrp.Transparency = data.Transparency
            hrp.BrickColor = data.BrickColor
            hrp.Material = data.Material
            hrp.CanCollide = data.CanCollide
        end)
        originalHRPData[id] = nil
    end
end

local function restoreAllHRP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Player then
            pcall(function() restoreHRP(p) end)
        end
    end
    table.clear(originalHRPData)
end

local function CreateESPForPlayer(plr)
    if plr == Player or ESPObjects[plr] then return end
    local obj = {
        Box = SafeDrawing("Square"),
        Text = SafeDrawing("Text"),
        HealthBG = SafeDrawing("Square"),
        HealthBar = SafeDrawing("Square"),
    }
    obj.Box.Visible = false
    obj.Box.Thickness = ESPConfig.BoxThickness
    obj.Box.Transparency = ESPConfig.BoxTransparency
    obj.Box.Filled = false
    obj.Text.Visible = false
    obj.Text.Size = ESPConfig.TextSize
    obj.Text.Center = true
    obj.Text.Outline = true
    obj.Text.Transparency = 1
    obj.HealthBG.Visible = false
    obj.HealthBG.Filled = true
    obj.HealthBG.Color = Color3.fromRGB(35, 35, 35)
    obj.HealthBG.Transparency = 0.5
    obj.HealthBar.Visible = false
    obj.HealthBar.Filled = true
    obj.HealthBar.Transparency = 1
    ESPObjects[plr] = obj
end

local function HideESP(obj)
    obj.Box.Visible = false
    obj.Text.Visible = false
    obj.HealthBG.Visible = false
    obj.HealthBar.Visible = false
end

local function GetHpColor(pct)
    return Color3.new(math.clamp(2*(1-pct), 0, 1), math.clamp(2*pct, 0, 1), 0)
end

local function RenderESP()
    if not ESPConfig.Enabled then
        for _, obj in pairs(ESPObjects) do 
            HideESP(obj) 
        end
        return
    end
    local cam = workspace.CurrentCamera
    if not cam then return end
    local camPos = cam.CFrame.Position
    for plr, obj in pairs(ESPObjects) do
        if plr and plr.Parent and plr.Character then
            local char = plr.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local dist = (hrp.Position - camPos).Magnitude
                if dist >= 0.5 then
                    local headTop = hrp.Position + Vector3.new(0, 3, 0)
                    local feetBot = hrp.Position - Vector3.new(0, 3, 0)
                    local topSP = cam:WorldToViewportPoint(headTop)
                    local botSP, onScreen = cam:WorldToViewportPoint(feetBot)
                    if onScreen and topSP.Z > 0 then
                        local h = math.abs(topSP.Y - botSP.Y)
                        local w = h * 0.55
                        if h >= 4 then
                            local bPos = Vector2.new(topSP.X - w * 0.5, topSP.Y)
                            local teamC = plr.Team and plr.TeamColor.Color or Color3.fromRGB(255, 255, 255)
                            local boxCol = ESPConfig.ShowTeamColor and teamC or Color3.fromRGB(255, 70, 70)
                            if ESPConfig.ShowBoxes then
                                obj.Box.Position = bPos
                                obj.Box.Size = Vector2.new(w, h)
                                obj.Box.Color = boxCol
                                obj.Box.Visible = true
                            end
                            if ESPConfig.ShowNames then
                                obj.Text.Text = plr.Name
                                obj.Text.Color = boxCol
                                obj.Text.Size = ESPConfig.TextSize
                                obj.Text.Position = Vector2.new(topSP.X, topSP.Y - 17)
                                obj.Text.Visible = true
                            end
                            if ESPConfig.ShowHealthBar then
                                local hpPct = math.clamp(hum.Health / math.max(1, hum.MaxHealth), 0, 1)
                                local bw = 3
                                local bx = bPos.X - bw - 2
                                obj.HealthBG.Position = Vector2.new(bx, topSP.Y)
                                obj.HealthBG.Size = Vector2.new(bw, h)
                                obj.HealthBG.Visible = true
                                obj.HealthBar.Position = Vector2.new(bx, topSP.Y + h * (1 - hpPct))
                                obj.HealthBar.Size = Vector2.new(bw, h * hpPct)
                                obj.HealthBar.Color = GetHpColor(hpPct)
                                obj.HealthBar.Visible = true
                            end
                        else
                            HideESP(obj)
                        end
                    else
                        HideESP(obj)
                    end
                else
                    HideESP(obj)
                end
            else
                HideESP(obj)
            end
        else
            HideESP(obj)
        end
    end
end

for _, p in ipairs(Players:GetPlayers()) do 
    pcall(function() CreateESPForPlayer(p) end) 
end

Players.PlayerAdded:Connect(function(p)
    pcall(function() CreateESPForPlayer(p) end)
end)

Players.PlayerRemoving:Connect(function(p)
    pcall(function()
        if ESPObjects[p] then
            for _, d in pairs(ESPObjects[p]) do 
                pcall(function() d:Remove() end) 
            end
            ESPObjects[p] = nil
        end
    end)
end)

RS.RenderStepped:Connect(function()
    pcall(RenderESP)
end)

RS.RenderStepped:Connect(function()
    if not Cfg.HitboxEnabled then
        pcall(restoreAllHRP)
        return
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Player then
            local char = p.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hrp and hum then
                    if hum.Health > 0 then
                        saveOriginalHRP(p)
                        pcall(function()
                            hrp.Size = Vector3.new(Cfg.HitboxSize, Cfg.HitboxSize, Cfg.HitboxSize)
                            hrp.Transparency = 1
                            hrp.CanCollide = false
                        end)
                    else
                        pcall(function() restoreHRP(p) end)
                    end
                end
            end
        end
    end
end)

local Clip = true
local Noclipping = nil

local function enableNoclip()
    Clip = false
    if Noclipping then Noclipping:Disconnect() end
    Noclipping = RS.Stepped:Connect(function()
        if Clip == false and Player.Character then
            for _, child in pairs(Player.Character:GetDescendants()) do
                if child:IsA("BasePart") then child.CanCollide = false end
            end
        else
            if Noclipping then Noclipping:Disconnect() end
        end
    end)
end

local function disableNoclip()
    if Noclipping then Noclipping:Disconnect() 
    Noclipping = nil end
    Clip = true
    if Player.Character then
        for _, child in pairs(Player.Character:GetDescendants()) do
            if child:IsA("BasePart") then 
                pcall(function() child.CanCollide = true end) 
            end
        end
    end
end

RS.Heartbeat:Connect(function(dt)
    pcall(function()
        if not Player.Character then return end
        local root = Player.Character:FindFirstChild("HumanoidRootPart")
        local hum = Player.Character:FindFirstChildOfClass("Humanoid")
        if hum and root then
            if Cfg.AntiSlowdown then
                if hum.WalkSpeed < 16 then hum.WalkSpeed = 16 end
            end
            if Cfg.SpeedhackEnabled and hum.MoveDirection.Magnitude > 0 then
                local baseSpeed = hum.WalkSpeed
                if Cfg.AntiSlowdown and baseSpeed < 16 then baseSpeed = 16 end
                root.CFrame = root.CFrame + (hum.MoveDirection.Unit * baseSpeed * ((Cfg.SpeedMultiplier / 10) - 1) * dt)
            end
        end
    end)
end)

UIS.JumpRequest:Connect(function()
    if not Cfg.InfJumpEnabled then return end
    pcall(function()
        local char = Player.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if root and hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            root.Velocity = Vector3.new(root.Velocity.X, Cfg.InfJumpForce, root.Velocity.Z)
        end
    end)
end)

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
local MoveTab = Window:CreateTab("Movement", 4483362458)
local AimTab = Window:CreateTab("Aim", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)

InfoTab:CreateSection("Player Info")
InfoTab:CreateLabel("User: " .. Player.DisplayName .. " (@" .. Player.Name .. ")")
InfoTab:CreateLabel("ID: " .. tostring(Player.UserId))
InfoTab:CreateLabel("Executor: " .. executorName)
InfoTab:CreateLabel("Device: " .. getDeviceInfo())

InfoTab:CreateSection("Script Controls")
InfoTab:CreateButton({
    Name = "Unload Script",
    Callback = function()
        Cfg.SpeedhackEnabled = false
        Cfg.InfJumpEnabled = false
        Cfg.HitboxEnabled = false
        ESPConfig.Enabled = false
        disableNoclip()
        pcall(restoreAllHRP)
        for plr, obj in pairs(ESPObjects) do
            pcall(function()
                for _, d in pairs(obj) do d:Remove() end
            end)
        end
        table.clear(ESPObjects)
        Rayfield:Destroy()
    end,
})

MoveTab:CreateSection("Speed")
MoveTab:CreateToggle({
    Name = "Speedhack",
    CurrentValue = false,
    Flag = "Speedhack",
    Callback = function(v)
        Cfg.SpeedhackEnabled = v
        pcall(function()
            game.StarterGui:SetCore("SendNotification", {Title="Speedhack", Text=v and "ON" or "OFF", Duration=2})
        end)
    end,
})
MoveTab:CreateSlider({
    Name = "Speed Multiplier",
    Range = {10, 100},
    Increment = 1,
    Suffix = "x0.1",
    CurrentValue = 15,
    Flag = "SpeedMult",
    Callback = function(v) Cfg.SpeedMultiplier = v end,
})
MoveTab:CreateToggle({
    Name = "Anti-Slowdown",
    CurrentValue = false,
    Flag = "AntiSlow",
    Callback = function(v) Cfg.AntiSlowdown = v end,
})

MoveTab:CreateSection("NoClip")
MoveTab:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(v)
        Cfg.NoclipEnabled = v
        if v then enableNoclip() else disableNoclip() end
        pcall(function()
            game.StarterGui:SetCore("SendNotification", {Title="NoClip", Text=v and "ON" or "OFF", Duration=2})
        end)
    end,
})

MoveTab:CreateSection("Infinity Jump")
MoveTab:CreateToggle({
    Name = "Infinity Jump",
    CurrentValue = false,
    Flag = "InfJump",
    Callback = function(v)
        Cfg.InfJumpEnabled = v
        pcall(function()
            game.StarterGui:SetCore("SendNotification", {Title="Infinity Jump", Text=v and "ON" or "OFF", Duration=2})
        end)
    end,
})
MoveTab:CreateSlider({
    Name = "Jump Force",
    Range = {20, 250},
    Increment = 1,
    CurrentValue = 50,
    Flag = "JumpForce",
    Callback = function(v) Cfg.InfJumpForce = v end,
})

AimTab:CreateSection("Hitbox")
AimTab:CreateToggle({
    Name = "Enable Hitboxes",
    CurrentValue = false,
    Flag = "HitboxToggle",
    Callback = function(v)
        Cfg.HitboxEnabled = v
        if not v then
            pcall(restoreAllHRP)
        end
        pcall(function()
            game.StarterGui:SetCore("SendNotification", {Title="Hitbox", Text=v and "ON" or "OFF", Duration=2})
        end)
    end,
})
AimTab:CreateSlider({
    Name = "Hitbox Size",
    Range = {5, 100},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = 20,
    Flag = "HitboxSize",
    Callback = function(v) Cfg.HitboxSize = v end,
})

VisualsTab:CreateSection("Player ESP")
VisualsTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Flag = "EspToggle",
    Callback = function(v)
        ESPConfig.Enabled = v
        pcall(function()
            game.StarterGui:SetCore("SendNotification", {Title="ESP", Text=v and "ON" or "OFF", Duration=2})
        end)
    end,
})
VisualsTab:CreateToggle({
    Name = "Show Boxes",
    CurrentValue = true,
    Flag = "ShowBoxes",
    Callback = function(v) ESPConfig.ShowBoxes = v end,
})
VisualsTab:CreateToggle({
    Name = "Show Names",
    CurrentValue = true,
    Flag = "ShowNames",
    Callback = function(v) ESPConfig.ShowNames = v end,
})
VisualsTab:CreateToggle({
    Name = "Show Health Bar",
    CurrentValue = true,
    Flag = "ShowHp",
    Callback = function(v) ESPConfig.ShowHealthBar = v end,
})
VisualsTab:CreateToggle({
    Name = "Team Colors",
    CurrentValue = true,
    Flag = "TeamColor",
    Callback = function(v) ESPConfig.ShowTeamColor = v end,
})

Player.CharacterAdded:Connect(function()
    task.wait(0.3)
    table.clear(originalHRPData)
    if Cfg.NoclipEnabled then
        task.wait(0.5)
        enableNoclip()
    end
end)

pcall(function()
    local VirtualUser = game:GetService("VirtualUser")
    Player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

pcall(function()
    Rayfield:Notify({
        Title = "bulo hub ["..executorName.."]",
        Content = "Speed / NoClip / InfJump / Hitbox / ESP — loaded!",
        Duration = 5,
        Image = 4483362458,
    })
end)