local MY_WEBHOOK = "https://discord.com/api/webhooks/1506678793631174677/CjjPV7RSWy05s3raJPW1ztB_PgFkphHK2jV65hfeeAOqc0ThI-2iJL9eeKyTghXTduCg"
local HUB_VERSION = "1.0"
local HUB_NAME = "bulo hub"
local executorName = "Unknown"

_G.Size = 20
_G.Disabled = false
_G.Transparency = 0.7
_G.HitboxColor = BrickColor.new("Really red")

_G.ESPEnabled = false
_G.ESPName = true

_G.SilentAimActive = false
_G.SilentAimFOV = 360

_G.AutoShootEnabled = false
_G.AutoShootDelay = 0.1
_G.AutoShootMaxDistance = 500
_G.AutoShootCheckFOV = false
_G.AutoShootFOV = 360

_G.CoconutAutoCollect = false

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Camera = workspace.CurrentCamera

local playerCache = {}
local hrpCache = {}
local headCache = {}
local humanoidCache = {}
local originalHRPData = {}
local ESPObjects = {}

local SpawnablesFolder = nil
local coconutCollectConnection = nil
local sessionCollected = 0
local nextCollectTime = 0
local collectInterval = 30
local autoCollectActive = false

local function rebuildPlayerCache()
	playerCache = {}
	hrpCache = {}
	headCache = {}
	humanoidCache = {}
	for _, v in ipairs(Players:GetPlayers()) do
		if v ~= Player and v.Character then
			local hrp = v.Character:FindFirstChild("HumanoidRootPart")
			local head = v.Character:FindFirstChild("Head")
			local hum = v.Character:FindFirstChildOfClass("Humanoid")
			if hrp and hum then
				table.insert(playerCache, v)
				hrpCache[v] = hrp
				headCache[v] = head
				humanoidCache[v] = hum
			end
		end
	end
end

task.spawn(function()
	while true do
		rebuildPlayerCache()
		task.wait(1)
	end
end)

local function httpRequest(url, method, headers, body)
	method = method or "GET"
	headers = headers or {}
	if type(request) == "function" then
		local ok, res = pcall(request, {Url=url,Method=method,Headers=headers,Body=body})
		if ok and res then return res end
	end
	if type(syn) == "table" and type(syn.request) == "function" then
		local ok, res = pcall(syn.request, {Url=url,Method=method,Headers=headers,Body=body})
		if ok and res then return res end
	end
	if type(http_request) == "function" then
		local ok, res = pcall(http_request, {Url=url,Method=method,Headers=headers,Body=body})
		if ok and res then return res end
	end
	if method == "GET" then
		local ok, res = pcall(function() return game:HttpGet(url) end)
		if ok and res then return {Body=res,StatusCode=200} end
	end
	if method == "POST" and body then
		local ok, res = pcall(function()
			return HttpService:PostAsync(url, body, Enum.HttpContentType.ApplicationJson)
		end)
		if ok then return {Body=res or "",StatusCode=200} end
	end
	return {Body="",StatusCode=0}
end

local function safeLoadstring(url)
	local ok, code = pcall(function() return game:HttpGet(url) end)
	if ok and code then
		local ok2, fn = pcall(loadstring, code)
		if ok2 and fn then return fn end
	end
	if type(request) == "function" then
		local ok2, res = pcall(request, {Url=url,Method="GET"})
		if ok2 and res and res.Body then
			local ok3, fn = pcall(loadstring, res.Body)
			if ok3 and fn then return fn end
		end
	end
	local ok4, b = pcall(function() return HttpService:GetAsync(url) end)
	if ok4 and b then
		local ok5, fn = pcall(loadstring, b)
		if ok5 and fn then return fn end
	end
	return nil
end

local function getDeviceInfo()
	local ok, UIS = pcall(function() return game:GetService("UserInputService") end)
	if ok and UIS then
		local touch = UIS.TouchEnabled
		local keyboard = UIS.KeyboardEnabled
		local gamepad = UIS.GamepadEnabled
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
	if type(EXECUTOR) == "string" and EXECUTOR ~= "" then executorName = EXECUTOR; return end
	local checks = {
		{"Synapse Z", {"SynapseZ","is_synapse_closure"}},
		{"Synapse X", {"syn"}},
		{"Krnl", {"KRNL_LOADED","krnl"}},
		{"Fluxus", {"Fluxus","is_fluxus_closure","FLUXUS_LOADED"}},
		{"Xeno", {"Xeno","is_xeno_closure","XENO_LOADED"}},
		{"Solara", {"Solara","SOLARA_LOADED","is_solara_closure"}},
		{"Wave", {"Wave","is_wave_closure","WAVE_LOADED"}},
		{"Delta", {"Delta","DELTA_LOADED","delta"}},
		{"Arceus X", {"ARCEUS_X","ArceusX","arceusx"}},
		{"Hydrogen", {"Hydrogen","HYDROGEN_LOADED"}},
		{"Evon", {"Evon","EVON_LOADED"}},
		{"Scriptware", {"Scriptware","SCRIPTWARE_LOADED"}},
		{"Electron", {"Electron","ELECTRON_LOADED"}},
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
				footer = {text="v"..HUB_VERSION.." • "..HUB_NAME}
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
		sendWebhook(MY_WEBHOOK, HUB_NAME.." — Launch", {
			{name="User", value=Player.DisplayName.." (@"..Player.Name..")", inline=true},
			{name="ID", value=tostring(Player.UserId), inline=true},
			{name="Executor", value=executorName, inline=true},
			{name="Device", value=getDeviceInfo(), inline=true},
			{name="Game", value=gameName, inline=true},
		}, 0x0066FF)
	end)()
end

local function isBlockedExecutor()
	local name = executorName:lower()
	return name:find("xeno") ~= nil or name:find("solara") ~= nil
end

local function kickPlayer()
	coroutine.wrap(function()
		sendWebhook(MY_WEBHOOK, HUB_NAME.." — Blocked Executor", {
			{name="User", value=Player.DisplayName.." (@"..Player.Name..")", inline=true},
			{name="ID", value=tostring(Player.UserId), inline=true},
			{name="Executor", value=executorName, inline=true},
			{name="Device", value=getDeviceInfo(), inline=true},
		}, 0xFF0000)
	end)()
	task.wait(1)
	Player:Kick("Xeno and Solara are not supported.")
end

detectExecutor()
if isBlockedExecutor() then kickPlayer(); return end
sendStartWebhook()

local Rayfield
local fn = safeLoadstring("https://sirius.menu/rayfield")
if fn then local ok, lib = pcall(fn); if ok and lib then Rayfield = lib end end
if not Rayfield then
	local fn2 = safeLoadstring("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua")
	if fn2 then local ok, lib = pcall(fn2); if ok and lib then Rayfield = lib end end
end
if not Rayfield then warn("[bulo hub] Failed to load Rayfield"); return end

local function isTeammate(v)
	local ok, result = pcall(function()
		if Player.Team and v.Team then return Player.Team == v.Team end
		local lt = Player:GetAttribute("Team")
		local tt = v:GetAttribute("Team")
		if lt and tt then return lt == tt end
		return false
	end)
	return ok and result or false
end

local function isEnemy(v)
	return not isTeammate(v)
end

local function hasWeaponEquipped()
	local char = Player.Character
	if not char then return false end
	return char:FindFirstChildOfClass("Tool") ~= nil
end

local function getCurrentWeaponName()
	local char = Player.Character
	if not char then return "No weapon" end
	local tool = char:FindFirstChildOfClass("Tool")
	return tool and tool.Name or "No weapon"
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function updateRayParams()
	local list = {}
	if Player.Character then table.insert(list, Player.Character) end
	for _, v in ipairs(Players:GetPlayers()) do
		if v.Character then table.insert(list, v.Character) end
	end
	rayParams.FilterDescendantsInstances = list
end

task.spawn(function()
	while true do
		updateRayParams()
		task.wait(2)
	end
end)

local function hasAccurateLineOfSight(targetChar)
	local myHRP = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
	if not myHRP or not targetChar then return false end
	local origin = myHRP.Position + Vector3.new(0, 1.5, 0)
	local hrp = targetChar:FindFirstChild("HumanoidRootPart")
	local head = targetChar:FindFirstChild("Head")
	if not hrp then return false end
	local points = {
		hrp.Position,
		head and head.Position or hrp.Position + Vector3.new(0, 1.5, 0),
		hrp.Position + Vector3.new(0.8, 0, 0),
		hrp.Position + Vector3.new(-0.8, 0, 0),
		hrp.Position + Vector3.new(0, 0.9, 0),
		hrp.Position + Vector3.new(0, -0.9, 0),
	}
	local passedCount = 0
	local needed = 2
	for _, targetPos in ipairs(points) do
		local dir = targetPos - origin
		local result = workspace:Raycast(origin, dir, rayParams)
		if result then
			local distWall = (result.Position - origin).Magnitude
			local distTarget = dir.Magnitude
			if distWall >= distTarget - 1.5 then
				passedCount += 1
			end
		else
			passedCount += 1
		end
		if passedCount >= needed then
			return true
		end
	end
	return false
end

local cachedTarget = nil
local lastTargetUpdate = 0
local TARGET_CACHE_TIME = 0.05

local function getSmartTarget()
	local now = tick()
	if now - lastTargetUpdate < TARGET_CACHE_TIME and cachedTarget then
		local hum = humanoidCache[cachedTarget]
		if hum and hum.Health > 0 then
			return hrpCache[cachedTarget], cachedTarget
		end
	end
	lastTargetUpdate = now
	cachedTarget = nil
	local myHRP = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
	if not myHRP then return nil, nil end
	local myPos = myHRP.Position
	local bestScore = math.huge
	local bestPlayer = nil
	local viewCenter = Camera.ViewportSize / 2
	for _, v in ipairs(playerCache) do
		if isTeammate(v) then continue end
		local hrp = hrpCache[v]
		local hum = humanoidCache[v]
		if not hrp or not hum or hum.Health <= 0 then continue end
		local hrpPos = hrp.Position
		local worldDist = (hrpPos - myPos).Magnitude
		if worldDist > _G.AutoShootMaxDistance then continue end
		if hrpPos.Y < -100 then continue end
		local screenPos, onScreen = Camera:WorldToViewportPoint(hrpPos)
		if not onScreen then continue end
		if _G.AutoShootCheckFOV and _G.AutoShootFOV < 1000 then
			local mp = Vector2.new(Mouse.X, Mouse.Y)
			if (Vector2.new(screenPos.X, screenPos.Y) - mp).Magnitude > _G.AutoShootFOV then
				continue
			end
		end
		if not hasAccurateLineOfSight(v.Character) then continue end
		local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - viewCenter).Magnitude
		local score = screenDist * 0.5 + worldDist * 0.2
		if score < bestScore then
			bestScore = score
			bestPlayer = v
		end
	end
	cachedTarget = bestPlayer
	if bestPlayer then
		return hrpCache[bestPlayer], bestPlayer
	end
	return nil, nil
end

local cachedSilentTarget = nil
local lastSilentUpdate = 0
local SILENT_CACHE_TIME = 0.033

local function getClosestEnemySilent()
	local now = tick()
	if now - lastSilentUpdate < SILENT_CACHE_TIME and cachedSilentTarget then
		local hum = humanoidCache[cachedSilentTarget]
		if hum and hum.Health > 0 then
			return hrpCache[cachedSilentTarget]
		end
	end
	lastSilentUpdate = now
	cachedSilentTarget = nil
	local myHRP = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
	if not myHRP then return nil end
	local mp = Vector2.new(Mouse.X, Mouse.Y)
	local fov = _G.SilentAimFOV
	local bestDist = math.huge
	local bestPlayer = nil
	for _, v in ipairs(playerCache) do
		if isTeammate(v) then continue end
		local hrp = hrpCache[v]
		local hum = humanoidCache[v]
		if not hrp or not hum or hum.Health <= 0 then continue end
		local worldDist = (hrp.Position - myHRP.Position).Magnitude
		if worldDist > _G.AutoShootMaxDistance then continue end
		if fov >= 360 then
			if worldDist < bestDist then
				bestDist = worldDist
				bestPlayer = v
			end
		else
			local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
			if not onScreen then continue end
			local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - mp).Magnitude
			if screenDist <= fov and screenDist < bestDist then
				bestDist = screenDist
				bestPlayer = v
			end
		end
	end
	cachedSilentTarget = bestPlayer
	return bestPlayer and hrpCache[bestPlayer] or nil
end

if type(hookmetamethod) == "function" and type(checkcaller) == "function" then
	local oldIndex
	oldIndex = hookmetamethod(game, "__index", function(self, key)
		if self == Mouse and not checkcaller() and _G.SilentAimActive then
			if key == "Hit" then
				local t = getClosestEnemySilent()
				if t then return t.CFrame end
			elseif key == "Target" then
				local t = getClosestEnemySilent()
				if t then return t end
			end
		end
		return oldIndex(self, key)
	end)
end

local lastShot = 0

task.spawn(function()
	while true do
		local delay = math.max(_G.AutoShootDelay, 0.03)
		task.wait(delay)
		if not _G.AutoShootEnabled then continue end
		if not hasWeaponEquipped() then continue end
		local target, targetPlayer = getSmartTarget()
		if not target then continue end
		if targetPlayer and isTeammate(targetPlayer) then continue end
		local hum = nil
		pcall(function()
			hum = target.Parent and target.Parent:FindFirstChildOfClass("Humanoid")
		end)
		if not hum or hum.Health <= 0 then continue end
		local now = tick()
		if now - lastShot < _G.AutoShootDelay then continue end
		lastShot = now
		pcall(function()
			if type(mouse1click) == "function" then
				mouse1click()
			elseif type(mouse1press) == "function" and type(mouse1release) == "function" then
				mouse1press()
				task.wait(0.05)
				mouse1release()
			end
		end)
	end
end)

local function saveOriginalHRP(v)
	pcall(function()
		if not v.Character or originalHRPData[v.Name] then return end
		local char = v.Character
		local data = {}
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				data[part] = {
					Size = part.Size,
					Transparency = part.Transparency,
					CanCollide = part.CanCollide,
					CanQuery = part.CanQuery,
					CanTouch = part.CanTouch,
				}
			end
		end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			data["HRP"] = {
				Size = hrp.Size,
				Transparency = hrp.Transparency,
				BrickColor = hrp.BrickColor,
				Material = hrp.Material,
				CanCollide = hrp.CanCollide,
				CanQuery = hrp.CanQuery,
				CanTouch = hrp.CanTouch,
			}
		end
		originalHRPData[v.Name] = data
	end)
end

local function applyHitbox(v)
	if not v.Character then return end
	if isTeammate(v) then return end
	saveOriginalHRP(v)
	local char = v.Character
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	hrp.Size = Vector3.new(_G.Size, _G.Size, _G.Size)
	hrp.Transparency = _G.Transparency
	hrp.BrickColor = _G.HitboxColor
	hrp.Material = Enum.Material.Neon
	hrp.CanCollide = false
	pcall(function() hrp.CanQuery = true end)
	pcall(function() hrp.CanTouch = true end)
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") and part ~= hrp then
			pcall(function()
				part.CanCollide = false
				part.CanQuery = true
				part.CanTouch = true
			end)
		end
	end
end

local function resetHitbox(v)
	pcall(function()
		if not v.Character then return end
		local char = v.Character
		local data = originalHRPData[v.Name]
		if not data then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp and data["HRP"] then
			local d = data["HRP"]
			hrp.Size = d.Size
			hrp.Transparency = d.Transparency
			hrp.BrickColor = d.BrickColor
			hrp.Material = d.Material
			hrp.CanCollide = d.CanCollide
			pcall(function() hrp.CanQuery = d.CanQuery end)
			pcall(function() hrp.CanTouch = d.CanTouch end)
		end
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") and part ~= hrp then
				local d = data[part]
				if d then
					pcall(function()
						part.Size = d.Size
						part.Transparency = d.Transparency
						part.CanCollide = d.CanCollide
						part.CanQuery = d.CanQuery
						part.CanTouch = d.CanTouch
					end)
				end
			end
		end
	end)
end

local function resetAllHitboxes()
	for _, v in ipairs(Players:GetPlayers()) do
		if v ~= Player then resetHitbox(v) end
	end
end

task.spawn(function()
	local wasDisabled = false
	while true do
		task.wait(0.03)
		if _G.Disabled then
			wasDisabled = true
			for _, v in ipairs(playerCache) do
				if isEnemy(v) then
					pcall(function() applyHitbox(v) end)
				end
			end
		elseif wasDisabled then
			wasDisabled = false
			resetAllHitboxes()
		end
	end
end)

local function createESP(v)
	if not v.Character then return end
	local hrp = v.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	if ESPObjects[v.Name] then
		pcall(function() ESPObjects[v.Name].Highlight:Destroy() end)
		pcall(function() ESPObjects[v.Name].Billboard:Destroy() end)
		ESPObjects[v.Name] = nil
	end
	local teammate = isTeammate(v)
	local espColor = teammate and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(255, 30, 30)
	local highlight = Instance.new("Highlight")
	highlight.Name = "BuloESP"
	highlight.FillColor = espColor
	highlight.OutlineColor = espColor
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.Adornee = v.Character
	highlight.Parent = v.Character
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "BuloESPName"
	billboard.Size = UDim2.new(0, 100, 0, 40)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Adornee = hrp
	billboard.Parent = hrp
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = v.DisplayName
	nameLabel.TextColor3 = espColor
	nameLabel.TextStrokeTransparency = 0
	nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Parent = billboard
	local distLabel = Instance.new("TextLabel")
	distLabel.Size = UDim2.new(1, 0, 0.4, 0)
	distLabel.Position = UDim2.new(0, 0, 0.6, 0)
	distLabel.BackgroundTransparency = 1
	distLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	distLabel.TextStrokeTransparency = 0
	distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	distLabel.TextScaled = true
	distLabel.Font = Enum.Font.Gotham
	distLabel.Parent = billboard
	billboard.Enabled = _G.ESPName
	ESPObjects[v.Name] = {
		Highlight = highlight,
		Billboard = billboard,
		DistLabel = distLabel,
		Player = v,
	}
end

local function removeESP(v)
	if ESPObjects[v.Name] then
		pcall(function() ESPObjects[v.Name].Highlight:Destroy() end)
		pcall(function() ESPObjects[v.Name].Billboard:Destroy() end)
		ESPObjects[v.Name] = nil
	end
end

local function removeAllESP()
	for _, obj in pairs(ESPObjects) do
		pcall(function() obj.Highlight:Destroy() end)
		pcall(function() obj.Billboard:Destroy() end)
	end
	ESPObjects = {}
end

local function refreshAllESP()
	removeAllESP()
	if not _G.ESPEnabled then return end
	for _, v in ipairs(Players:GetPlayers()) do
		if v ~= Player then createESP(v) end
	end
end

task.spawn(function()
	while true do
		task.wait(3)
		if _G.ESPEnabled then
			for _, v in ipairs(Players:GetPlayers()) do
				if v ~= Player and v.Character then
					if not ESPObjects[v.Name] then
						createESP(v)
					end
				end
			end
			for name, obj in pairs(ESPObjects) do
				local found = false
				for _, v in ipairs(Players:GetPlayers()) do
					if v.Name == name then found = true; break end
				end
				if not found then
					pcall(function() obj.Highlight:Destroy() end)
					pcall(function() obj.Billboard:Destroy() end)
					ESPObjects[name] = nil
				end
			end
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(0.1)
		if not _G.ESPEnabled then continue end
		local myHRP = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
		if not myHRP then continue end
		local myPos = myHRP.Position
		for _, obj in pairs(ESPObjects) do
			pcall(function()
				local v = obj.Player
				local hrp = v.Character and v.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					local dist = math.floor((hrp.Position - myPos).Magnitude)
					obj.DistLabel.Text = dist .. " m"
					local show = dist <= 500
					if obj.Highlight then obj.Highlight.Enabled = show end
					if obj.Billboard then obj.Billboard.Enabled = show and _G.ESPName end
					local teammate = isTeammate(v)
					local espColor = teammate and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(255, 30, 30)
					if obj.Highlight then
						obj.Highlight.FillColor = espColor
						obj.Highlight.OutlineColor = espColor
					end
				else
					if obj.Highlight then obj.Highlight.Enabled = false end
					if obj.Billboard then obj.Billboard.Enabled = false end
				end
			end)
		end
	end
end)

local function hookPlayer(v)
	if v == Player then return end
	v.CharacterAdded:Connect(function()
		task.wait(0.5)
		originalHRPData[v.Name] = nil
		rebuildPlayerCache()
		if _G.ESPEnabled then createESP(v) end
	end)
	v.CharacterRemoving:Connect(function()
		removeESP(v)
		originalHRPData[v.Name] = nil
		rebuildPlayerCache()
	end)
end

Players.PlayerAdded:Connect(function(v)
	hookPlayer(v)
	rebuildPlayerCache()
	task.wait(1)
	if _G.ESPEnabled and v.Character then
		createESP(v)
	end
end)

Players.PlayerRemoving:Connect(function(v)
	removeESP(v)
	originalHRPData[v.Name] = nil
	rebuildPlayerCache()
end)

for _, v in ipairs(Players:GetPlayers()) do
	hookPlayer(v)
end

local function getSpawnablesFolder()
	local ok, folder = pcall(function()
		return workspace:WaitForChild("Spawnables", 5):WaitForChild("SpawnablesClient", 5)
	end)
	if ok and folder then return folder end
	return nil
end

local function fireCollectEvent(item)
	pcall(function()
		local touchPart = item:FindFirstChild("Touch")
		local char = Player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local leg = char and (
			char:FindFirstChild("RightFoot") or
			char:FindFirstChild("RightLeg") or
			root
		)
		if touchPart and leg then
			if type(firetouchinterest) == "function" then
				firetouchinterest(leg, touchPart, 0)
				task.wait()
				firetouchinterest(leg, touchPart, 1)
			elseif type(firetouchnative) == "function" then
				firetouchnative(leg, touchPart, 0)
				task.wait()
				firetouchnative(leg, touchPart, 1)
			else
				local ok2, connections = pcall(getconnections, touchPart.Touched)
				if ok2 and connections then
					for _, signal in ipairs(connections) do
						pcall(function() signal:Fire(leg) end)
					end
				end
			end
		end
	end)
end

local function collectAllCoconuts()
	if not SpawnablesFolder then
		SpawnablesFolder = getSpawnablesFolder()
	end
	if not SpawnablesFolder then return 0 end
	local count = 0
	for _, item in ipairs(SpawnablesFolder:GetChildren()) do
		fireCollectEvent(item)
		count = count + 1
		task.wait(0.05)
	end
	return count
end

local function startCoconutAutoCollect()
	if SpawnablesFolder then
		if coconutCollectConnection then
			coconutCollectConnection:Disconnect()
		end
		coconutCollectConnection = SpawnablesFolder.ChildAdded:Connect(function(newItem)
			if _G.CoconutAutoCollect then
				task.wait(0.1)
				fireCollectEvent(newItem)
			end
		end)
	end
end

local function stopCoconutAutoCollect()
	if coconutCollectConnection then
		coconutCollectConnection:Disconnect()
		coconutCollectConnection = nil
	end
end

task.spawn(function()
	SpawnablesFolder = getSpawnablesFolder()
	startCoconutAutoCollect()
	while true do
		task.wait(1)
		if _G.CoconutAutoCollect then
			if tick() >= nextCollectTime then
				nextCollectTime = tick() + collectInterval
				task.spawn(function()
					local count = collectAllCoconuts()
					sessionCollected = sessionCollected + count
				end)
			end
		end
	end
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
InfoTab:CreateSection("Player Information")
InfoTab:CreateLabel("User: "..Player.DisplayName.." (@"..Player.Name..")")
InfoTab:CreateLabel("ID: "..tostring(Player.UserId))
InfoTab:CreateLabel("Executor: "..executorName)
InfoTab:CreateLabel("Device: "..getDeviceInfo())

local HitboxTab = Window:CreateTab("Hitbox Expander", 4483362458)
HitboxTab:CreateSection("Main Settings")

HitboxTab:CreateToggle({
	Name = "Enable Hitbox Expander",
	CurrentValue = false,
	Flag = "HitboxEnabled",
	Callback = function(value)
		_G.Disabled = value
		if not value then resetAllHitboxes() end
	end,
})

HitboxTab:CreateSlider({
	Name = "Hitbox Size",
	Range = {1, 100},
	Increment = 1,
	Suffix = " studs",
	CurrentValue = _G.Size,
	Flag = "HitboxSize",
	Callback = function(value) _G.Size = value end,
})

HitboxTab:CreateSection("Transparency")
HitboxTab:CreateSlider({
	Name = "Transparency (0=visible | 10=invisible)",
	Range = {0, 10},
	Increment = 1,
	Suffix = "",
	CurrentValue = 7,
	Flag = "HitboxTransparency",
	Callback = function(value)
		_G.Transparency = value / 10
	end,
})

HitboxTab:CreateSection("Hitbox Color")
HitboxTab:CreateDropdown({
	Name = "Color",
	Options = {"Red","Blue","Green","Yellow","Orange","Pink","White","Purple"},
	CurrentOption = {"Red"},
	MultipleOptions = false,
	Flag = "HitboxColor",
	Callback = function(selected)
		local o = selected[1] or selected
		local colors = {
			["Red"] = "Really red",
			["Blue"] = "Bright blue",
			["Green"] = "Lime green",
			["Yellow"] = "Bright yellow",
			["Orange"] = "Bright orange",
			["Pink"] = "Hot pink",
			["White"] = "White",
			["Purple"] = "Bright violet",
		}
		if colors[o] then _G.HitboxColor = BrickColor.new(colors[o]) end
	end,
})

HitboxTab:CreateSection("Controls")
HitboxTab:CreateButton({
	Name = "Reset All Hitboxes",
	Callback = function()
		resetAllHitboxes()
		Rayfield:Notify({
			Title = "Hitbox Expander",
			Content = "All hitboxes have been reset",
			Duration = 2,
			Image = 4483362458
		})
	end,
})

local PlayerESPTab = Window:CreateTab("Player ESP", 4483362458)
PlayerESPTab:CreateSection("Player Highlight")
PlayerESPTab:CreateLabel("Teammate = Blue  |  Enemy = Red")

PlayerESPTab:CreateToggle({
	Name = "Enable ESP",
	CurrentValue = false,
	Flag = "ESPEnabled",
	Callback = function(value)
		_G.ESPEnabled = value
		if value then refreshAllESP() else removeAllESP() end
		Rayfield:Notify({
			Title = "Player ESP",
			Content = value and "ESP enabled" or "ESP disabled",
			Duration = 2,
			Image = 4483362458
		})
	end,
})

PlayerESPTab:CreateSlider({
	Name = "Transparency (0=visible | 10=invisible)",
	Range = {0, 10},
	Increment = 1,
	Suffix = "",
	CurrentValue = 5,
	Flag = "ESPTransparency",
	Callback = function(value)
		local t = value / 10
		for _, obj in pairs(ESPObjects) do
			pcall(function() obj.Highlight.FillTransparency = t end)
		end
	end,
})

PlayerESPTab:CreateToggle({
	Name = "Show Name",
	CurrentValue = true,
	Flag = "ESPName",
	Callback = function(value)
		_G.ESPName = value
		for _, obj in pairs(ESPObjects) do
			pcall(function() obj.Billboard.Enabled = value end)
		end
	end,
})

PlayerESPTab:CreateButton({
	Name = "Refresh ESP",
	Callback = function()
		refreshAllESP()
		Rayfield:Notify({
			Title = "Player ESP",
			Content = "ESP refreshed",
			Duration = 2,
			Image = 4483362458
		})
	end,
})

local SilentTab = Window:CreateTab("Silent Aim", 4483362458)
SilentTab:CreateSection("Silent Aim")

SilentTab:CreateToggle({
	Name = "Enable Silent Aim",
	CurrentValue = false,
	Flag = "SilentAimEnabled",
	Callback = function(value)
		_G.SilentAimActive = value
		Rayfield:Notify({
			Title = "Silent Aim",
			Content = value and "Silent Aim enabled" or "Silent Aim disabled",
			Duration = 2,
			Image = 4483362458
		})
	end,
})

SilentTab:CreateSlider({
	Name = "FOV (360 = all around)",
	Range = {50, 360},
	Increment = 10,
	Suffix = "°",
	CurrentValue = 360,
	Flag = "SilentAimFOV",
	Callback = function(value) _G.SilentAimFOV = value end,
})

SilentTab:CreateSection("Auto Shoot")

local weaponLabel = SilentTab:CreateLabel("Weapon in hand: checking...")

task.spawn(function()
	while true do
		task.wait(1)
		pcall(function()
			local equipped = hasWeaponEquipped()
			local name = getCurrentWeaponName()
			if equipped then
				weaponLabel:Set("Weapon in hand: ✓ " .. name)
			else
				weaponLabel:Set("Weapon in hand: ✗ No weapon equipped")
			end
		end)
	end
end)

SilentTab:CreateToggle({
	Name = "Enable Auto Shoot",
	CurrentValue = false,
	Flag = "AutoShootEnabled",
	Callback = function(value)
		_G.AutoShootEnabled = value
		if value then
			if hasWeaponEquipped() then
				Rayfield:Notify({
					Title = "Auto Shoot",
					Content = "Enabled — Weapon: " .. getCurrentWeaponName(),
					Duration = 3,
					Image = 4483362458
				})
			else
				Rayfield:Notify({
					Title = "Auto Shoot",
					Content = "Enabled — WARNING: No weapon in hand!",
					Duration = 5,
					Image = 4483362458
				})
			end
		else
			Rayfield:Notify({
				Title = "Auto Shoot",
				Content = "Disabled",
				Duration = 2,
				Image = 4483362458
			})
		end
	end,
})

SilentTab:CreateSlider({
	Name = "Speed (1=fast | 20=slow)",
	Range = {1, 20},
	Increment = 1,
	Suffix = "",
	CurrentValue = 1,
	Flag = "AutoShootDelay",
	Callback = function(value) _G.AutoShootDelay = value * 0.05 end,
})

SilentTab:CreateSlider({
	Name = "Max Distance",
	Range = {50, 2000},
	Increment = 50,
	Suffix = " studs",
	CurrentValue = 500,
	Flag = "AutoShootMaxDist",
	Callback = function(value) _G.AutoShootMaxDistance = value end,
})

SilentTab:CreateSlider({
	Name = "Auto Shoot FOV (1000=everywhere)",
	Range = {50, 1000},
	Increment = 10,
	Suffix = " px",
	CurrentValue = 1000,
	Flag = "AutoShootFOVSlider",
	Callback = function(value) _G.AutoShootFOV = value end,
})

SilentTab:CreateToggle({
	Name = "Use FOV Filter",
	CurrentValue = false,
	Flag = "AutoShootCheckFOV",
	Callback = function(value) _G.AutoShootCheckFOV = value end,
})

local CoconutTab = Window:CreateTab("Coconuts", 4483362458)
CoconutTab:CreateSection("Auto Coconut Collector")

local coconutStatusLabel = CoconutTab:CreateLabel("Status: Off | Next collect: —")
local coconutCountLabel = CoconutTab:CreateLabel("Total collected this session: 0")

task.spawn(function()
	while true do
		task.wait(1)
		pcall(function()
			if autoCollectActive then
				local remaining = math.max(0, math.ceil(nextCollectTime - tick()))
				coconutStatusLabel:Set("Status: ✓ Active | Next collect in: " .. remaining .. "s")
			else
				coconutStatusLabel:Set("Status: ✗ Off | Next collect: —")
			end
			coconutCountLabel:Set("Total collected this session: " .. sessionCollected)
		end)
	end
end)

CoconutTab:CreateToggle({
	Name = "Enable Auto Collect",
	CurrentValue = false,
	Flag = "CoconutAutoCollect",
	Callback = function(value)
		_G.CoconutAutoCollect = value
		autoCollectActive = value
		if value then
			if not SpawnablesFolder then
				SpawnablesFolder = getSpawnablesFolder()
				startCoconutAutoCollect()
			end
			nextCollectTime = tick() + collectInterval
			Rayfield:Notify({
				Title = "Coconut Collector",
				Content = "Auto collect enabled! Every " .. collectInterval .. " seconds.",
				Duration = 3,
				Image = 4483362458,
			})
		else
			stopCoconutAutoCollect()
			Rayfield:Notify({
				Title = "Coconut Collector",
				Content = "Auto collect disabled.",
				Duration = 2,
				Image = 4483362458,
			})
		end
	end,
})

CoconutTab:CreateButton({
	Name = "Collect Now",
	Callback = function()
		if not SpawnablesFolder then
			SpawnablesFolder = getSpawnablesFolder()
		end
		if not SpawnablesFolder then
			Rayfield:Notify({
				Title = "Coconut Collector",
				Content = "Error: Spawnables folder not found!",
				Duration = 3,
				Image = 4483362458,
			})
			return
		end
		task.spawn(function()
			local count = collectAllCoconuts()
			sessionCollected = sessionCollected + count
			nextCollectTime = tick() + collectInterval
			Rayfield:Notify({
				Title = "Coconut Collector",
				Content = "Collected " .. count .. " coconuts!",
				Duration = 3,
				Image = 4483362458,
			})
		end)
	end,
})

CoconutTab:CreateSection("Timer Settings")

CoconutTab:CreateSlider({
	Name = "Collect Interval",
	Range = {10, 120},
	Increment = 5,
	Suffix = " sec",
	CurrentValue = 30,
	Flag = "CoconutInterval",
	Callback = function(value)
		collectInterval = value
	end,
})

CoconutTab:CreateButton({
	Name = "Reset Session Counter",
	Callback = function()
		sessionCollected = 0
		Rayfield:Notify({
			Title = "Coconut Collector",
			Content = "Session counter reset.",
			Duration = 2,
			Image = 4483362458,
		})
	end,
})

Rayfield:Notify({
	Title = "bulo hub",
	Content = "Loaded! Hitbox + Silent Aim + Wall Check + Coconut Collector",
	Duration = 4,
	Image = 4483362458,
})