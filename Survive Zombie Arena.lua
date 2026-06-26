local MY_WEBHOOK = "https://discord.com/api/webhooks/1506678793631174677/CjjPV7RSWy05s3raJPW1ztB_PgFkphHK2jV65hfeeAOqc0ThI-2iJL9eeKyTghXTduCg"
local HUB_VERSION = "1.0"
local HUB_NAME = "bulo hub"
local executorName = "Unknown"

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local R = game:GetService("ReplicatedStorage")

-- // State variables
local KillEnabled = false
local FlyEnabled = false
local AutoHPEnabled = false
local AUTO_HP_DELAY = 1.0

-- // Find zombie table
local Z = nil
pcall(function()
    Z = require(Player.PlayerScripts.Controllers.ZombieClient).Zombies
end)

if type(Z) ~= "table" then
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "Zombies") and rawget(v, "ZombieModels") then
            Z = v.Zombies
            break
        end
    end
end

if type(Z) == "table" then
    print("[ZOMBIE KILLER]: OK")
else
    warn("[ZOMBIE KILLER]: Not found")
end

local D = R:WaitForChild("ZombieRemotes"):WaitForChild("ZombieDamage")

-- // Update character hip height
local function UpdateHeight()
    local M = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if M then
        M.HipHeight = FlyEnabled and 25 or 0
    end
end

Player.CharacterAdded:Connect(function()
    task.wait(1)
    UpdateHeight()
end)

-- // Get HP button
local function getHealthButton()
    local PlayerGui = Player:FindFirstChild("PlayerGui")
    if not PlayerGui then return nil end
    local MainGui = PlayerGui:FindFirstChild("MainGui")
    if not MainGui then return nil end
    local ControlPanel2 = MainGui:FindFirstChild("ControlPanel2")
    if not ControlPanel2 then return nil end
    local HealthButton = ControlPanel2:FindFirstChild("HealthUpgrade")
    if not HealthButton then return nil end
    return HealthButton, ControlPanel2
end

-- // Main background loop
task.spawn(function()
    while task.wait(.2) do
        if FlyEnabled then
            UpdateHeight()
        end
        if KillEnabled and type(Z) == "table" then
            for id, data in pairs(Z) do
                if data and not data.IsDying and data.Health and data.Health > 0 then
                    D:FireServer(id, 99999)
                end
            end
        end
    end
end)

-- // Auto HP loop
task.spawn(function()
    while true do
        task.wait(AUTO_HP_DELAY)
        if AutoHPEnabled then
            local HealthButton, ControlPanel2 = getHealthButton()
            if HealthButton and ControlPanel2 then
                if HealthButton.Visible and ControlPanel2.Visible then
                    pcall(function()
                        if type(getconnections) == "function" then
                            for _, connection in pairs(getconnections(HealthButton.MouseButton1Click)) do
                                connection:Fire()
                            end
                            for _, connection in pairs(getconnections(HealthButton.MouseButton1Up)) do
                                connection:Fire()
                            end
                        else
                            HealthButton.MouseButton1Click:Fire()
                        end
                    end)
                end
            end
        end
    end
end)

-- =====================================
-- HTTP / WEBHOOK UTILITIES
-- =====================================

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
    local ok4, body2 = pcall(function() return HttpService:GetAsync(url) end)
    if ok4 and body2 then
        local ok5, fn = pcall(loadstring, body2)
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

-- =====================================
-- STARTUP
-- =====================================

detectExecutor()

if isBlockedExecutor() then
    kickPlayer()
    return
end

sendStartWebhook()

-- Load Rayfield
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

-- =====================================
-- RAYFIELD WINDOW
-- =====================================

local Window = Rayfield:CreateWindow({
    Name = "bulo hub",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "https://discord.gg/WZp4DZ9QZs",
    ConfigurationSaving = {Enabled = false},
    Discord = {Enabled = false},
    KeySystem = false,
    Theme = "Amethyst"
})

-- =====================================
-- TAB: INFO
-- =====================================

local InfoTab = Window:CreateTab("Info", 4483362458)

InfoTab:CreateSection("Player Info")
InfoTab:CreateLabel("User: " .. Player.DisplayName .. " (@" .. Player.Name .. ")")
InfoTab:CreateLabel("ID: " .. tostring(Player.UserId))
InfoTab:CreateLabel("Executor: " .. executorName)
InfoTab:CreateLabel("Device: " .. getDeviceInfo())

-- =====================================
-- TAB: ZOMBIE KILLER
-- =====================================

local ZombieTab = Window:CreateTab("Zombie Killer", 4483362458)

ZombieTab:CreateSection("Zombie Controls")

ZombieTab:CreateToggle({
    Name = "Auto Kill Zombies",
    CurrentValue = false,
    Flag = "KillToggle",
    Callback = function(value)
        KillEnabled = value
    end,
})

-- =====================================
-- TAB: PLAYER
-- =====================================

local PlayerTab = Window:CreateTab("Player", 4483362458)

PlayerTab:CreateSection("Movement")

PlayerTab:CreateToggle({
    Name = "Fly (HipHeight)",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(value)
        FlyEnabled = value
        UpdateHeight()
    end,
})

-- =====================================
-- TAB: AUTO HP
-- =====================================

local HPTab = Window:CreateTab("Auto HP", 4483362458)

HPTab:CreateSection("Health Upgrade")

HPTab:CreateToggle({
    Name = "Auto Buy HP",
    CurrentValue = false,
    Flag = "AutoHPToggle",
    Callback = function(value)
        AutoHPEnabled = value
        if value then
            print("[AUTO-HP]: Enabled")
        else
            print("[AUTO-HP]: Disabled")
        end
    end,
})

HPTab:CreateSlider({
    Name = "Click Delay (seconds)",
    Range = {0.1, 5},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = AUTO_HP_DELAY,
    Flag = "HPDelaySlider",
    Callback = function(value)
        AUTO_HP_DELAY = value
    end,
})