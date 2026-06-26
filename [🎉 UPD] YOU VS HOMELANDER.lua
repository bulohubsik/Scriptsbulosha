local MY_WEBHOOK = "https://discord.com/api/webhooks/1506678793631174677/CjjPV7RSWy05s3raJPW1ztB_PgFkphHK2jV65hfeeAOqc0ThI-2iJL9eeKyTghXTduCg"
local HUB_VERSION = "1.0"
local HUB_NAME = "bulo hub"
local executorName = "Unknown"

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Terrain = workspace:FindFirstChildOfClass("Terrain")
local Camera = workspace.CurrentCamera
local Mouse = Player:GetMouse()

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
		if ok and name and name ~= "" then executorName = tostring(name); return end
	end
	if type(getexecutorname) == "function" then
		local ok, name = pcall(getexecutorname)
		if ok and name and name ~= "" then executorName = tostring(name); return end
	end
	if type(EXECUTOR) == "string" and EXECUTOR ~= "" then executorName = EXECUTOR; return end
	local checks = {
		{"Potassium",{"Potassium","potassium"}},
		{"Synapse Z",{"SynapseZ","is_synapse_closure"}},
		{"Synapse X",{"syn"}},
		{"Krnl",{"KRNL_LOADED","krnl"}},
		{"Fluxus",{"Fluxus","is_fluxus_closure","FLUXUS_LOADED"}},
		{"Xeno",{"Xeno","is_xeno_closure","XENO_LOADED"}},
		{"Solara",{"Solara","SOLARA_LOADED","is_solara_closure"}},
		{"Wave",{"Wave","is_wave_closure","WAVE_LOADED"}},
		{"Seliware",{"Seliware","SELIWARE_LOADED"}},
		{"Velocity",{"Velocity","VELOCITY_LOADED"}},
		{"Bunni",{"Bunni","bunni","BUNNI_LOADED"}},
		{"Madium",{"Madium","is_madium_closure","MADIUM_LOADED","madium"}},
		{"Celery",{"Celery","CELERY_LOADED"}},
		{"Coco Z",{"CocoZ","COCOZ_LOADED"}},
		{"Delta",{"Delta","DELTA_LOADED","delta"}},
		{"Arceus X",{"ARCEUS_X","ArceusX","arceusx"}},
		{"Hydrogen",{"Hydrogen","HYDROGEN_LOADED"}},
		{"Evon",{"Evon","EVON_LOADED"}},
		{"Scriptware",{"Scriptware","SCRIPTWARE_LOADED"}},
		{"ProtoSmasher",{"ProtoSmasher","PROTO_SMASHER"}},
		{"Electron",{"Electron","ELECTRON_LOADED"}},
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
			{name="User", value=Player.DisplayName.." (@"..Player.Name..")", inline=true},
			{name="ID", value=tostring(Player.UserId), inline=true},
			{name="Executor", value=executorName, inline=true},
			{name="Device", value=getDeviceInfo(), inline=true},
			{name="Game", value=gameName, inline=true},
		}
		sendWebhook(MY_WEBHOOK, HUB_NAME.." — Launch", fields, 0x0066FF)
	end)()
end

local fpsBoostEnabled = false
local fpsBoostOriginals = {}

local function applyFPSBoost()
	pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
	for _, effect in ipairs(Lighting:GetChildren()) do
		if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") or effect:IsA("ColorCorrectionEffect") then
			fpsBoostOriginals[effect] = effect.Enabled
			effect.Enabled = false
		end
	end
	if Terrain then
		fpsBoostOriginals["WaterWaveSize"] = Terrain.WaterWaveSize
		fpsBoostOriginals["WaterWaveSpeed"] = Terrain.WaterWaveSpeed
		fpsBoostOriginals["WaterReflectance"] = Terrain.WaterReflectance
		fpsBoostOriginals["WaterTransparency"] = Terrain.WaterTransparency
		Terrain.WaterWaveSize = 0
		Terrain.WaterWaveSpeed = 0
		Terrain.WaterReflectance = 0
		Terrain.WaterTransparency = 0
	end
	fpsBoostOriginals["GlobalShadows"] = Lighting.GlobalShadows
	Lighting.GlobalShadows = false
	for _, obj in ipairs(workspace:GetDescendants()) do
		pcall(function()
			if obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("CornerWedgePart") or obj:IsA("TrussPart") or obj:IsA("WedgePart") then
				fpsBoostOriginals[obj] = {Material=obj.Material, Reflectance=obj.Reflectance, CastShadow=obj.CastShadow}
				obj.Material = Enum.Material.SmoothPlastic
				obj.Reflectance = 0
				obj.CastShadow = false
			elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Fire") then
				fpsBoostOriginals[obj] = obj.Enabled
				obj.Enabled = false
			end
		end)
	end
	pcall(function()
		game.StarterGui:SetCore("SendNotification", {Title="FPS Boost", Text="Enabled", Duration=3})
	end)
end

local fpsBoostDescConn = nil

local function disableFPSBoost()
	pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end)
	for _, effect in ipairs(Lighting:GetChildren()) do
		if fpsBoostOriginals[effect] ~= nil then
			effect.Enabled = fpsBoostOriginals[effect]
			fpsBoostOriginals[effect] = nil
		end
	end
	if Terrain then
		if fpsBoostOriginals["WaterWaveSize"] ~= nil then Terrain.WaterWaveSize = fpsBoostOriginals["WaterWaveSize"] end
		if fpsBoostOriginals["WaterWaveSpeed"] ~= nil then Terrain.WaterWaveSpeed = fpsBoostOriginals["WaterWaveSpeed"] end
		if fpsBoostOriginals["WaterReflectance"] ~= nil then Terrain.WaterReflectance = fpsBoostOriginals["WaterReflectance"] end
		if fpsBoostOriginals["WaterTransparency"] ~= nil then Terrain.WaterTransparency = fpsBoostOriginals["WaterTransparency"] end
		fpsBoostOriginals["WaterWaveSize"] = nil
		fpsBoostOriginals["WaterWaveSpeed"] = nil
		fpsBoostOriginals["WaterReflectance"] = nil
		fpsBoostOriginals["WaterTransparency"] = nil
	end
	if fpsBoostOriginals["GlobalShadows"] ~= nil then
		Lighting.GlobalShadows = fpsBoostOriginals["GlobalShadows"]
		fpsBoostOriginals["GlobalShadows"] = nil
	end
	for obj, state in pairs(fpsBoostOriginals) do
		pcall(function()
			if typeof(obj) == "Instance" then
				if obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("CornerWedgePart") or obj:IsA("TrussPart") or obj:IsA("WedgePart") then
					obj.Material = state.Material
					obj.Reflectance = state.Reflectance
					obj.CastShadow = state.CastShadow
				elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Fire") then
					obj.Enabled = state
				end
			end
		end)
		fpsBoostOriginals[obj] = nil
	end
	if fpsBoostDescConn then fpsBoostDescConn:Disconnect(); fpsBoostDescConn = nil end
	pcall(function()
		game.StarterGui:SetCore("SendNotification", {Title="FPS Boost", Text="Disabled", Duration=3})
	end)
end

local function toggleFPSBoost(v)
	fpsBoostEnabled = v
	if v then
		applyFPSBoost()
		fpsBoostDescConn = workspace.DescendantAdded:Connect(function(obj)
			if not fpsBoostEnabled then return end
			task.wait(0.1)
			pcall(function()
				if obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("CornerWedgePart") or obj:IsA("TrussPart") or obj:IsA("WedgePart") then
					obj.Material = Enum.Material.SmoothPlastic
					obj.Reflectance = 0
					obj.CastShadow = false
				elseif obj:IsA("Decal") or obj:IsA("Texture") then
					obj:Destroy()
				elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Fire") then
					obj.Enabled = false
				end
			end)
		end)
		Lighting.ChildAdded:Connect(function(child)
			if not fpsBoostEnabled then return end
			task.wait(0.1)
			if child:IsA("PostEffect") or child:IsA("BloomEffect") or child:IsA("BlurEffect") or child:IsA("SunRaysEffect") or child:IsA("ColorCorrectionEffect") then
				child.Enabled = false
			end
		end)
	else
		disableFPSBoost()
	end
end

local fallReducerEnabled = false
local fallChar = Player.Character or Player.CharacterAdded:Wait()
local fallRoot = fallChar:WaitForChild("HumanoidRootPart", 10)
local fallParams = RaycastParams.new()
fallParams.FilterType = Enum.RaycastFilterType.Exclude

local function updateFallCharRefs(char)
	fallChar = char
	fallRoot = char:WaitForChild("HumanoidRootPart", 10)
	pcall(function() fallParams.FilterDescendantsInstances = {char} end)
end

pcall(function() fallParams.FilterDescendantsInstances = {fallChar} end)

Player.CharacterAdded:Connect(function(char)
	updateFallCharRefs(char)
end)

RS.Heartbeat:Connect(function()
	if not fallReducerEnabled then return end
	if not fallRoot or not fallRoot.Parent then return end
	if fallRoot.AssemblyLinearVelocity.Y < -25 then
		local raycastResult = workspace:Raycast(fallRoot.Position, Vector3.new(0,-5,0), fallParams)
		if raycastResult then
			local vel = fallRoot.AssemblyLinearVelocity
			fallRoot.AssemblyLinearVelocity = Vector3.new(vel.X, 0, vel.Z)
		end
	end
end)

local DrawingAvailable = false
pcall(function()
	local t = Drawing.new("Square"); t:Remove(); DrawingAvailable = true
end)

local FakeDrawingMeta = {
	__index = function(t, k) return rawget(t, k) end,
	__newindex = function(t, k, v) rawset(t, k, v) end,
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

local function SafeClick()
	if mouse1click then pcall(mouse1click); return end
	if syn and syn.click then pcall(syn.click); return end
	pcall(function()
		local vim2 = game:GetService("VirtualInputManager")
		vim2:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 0)
		task.wait(0.05)
		vim2:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 0)
	end)
end

local Cfg = {
	TargetPart = "Head",
	IgnoreTeam = true,
	WorldFOV = 70,
	InfJumpEnabled = false, InfJumpForce = 50,
	SpeedhackEnabled = false, SpeedMultiplier = 15,
	AntiSlowdown = false, NoclipEnabled = false,
	AutoGrilleEnabled = false, ClickDelay = 100,
	FlySpeed = 35,
	OrigSizes = {}, HiddenHeads = {},
}

local ESPConfig = {
	Enabled=false, ShowBoxes=true, ShowNames=true,
	ShowHealthBar=true, ShowTeamColor=true, TextSize=14,
	BoxThickness=2, BoxTransparency=0.5, MaxDistance=5000,
}

local OriginalStates = {}
local connections = {}
local lastClick = 0
local fbOriginals = nil
local espColor = Color3.fromRGB(255,255,255)
local ESPObjects = {}
local isFlying = false
local flyTarget = nil
local flyActive = false
local flyCurrentVel = Vector3.zero
local flyHeartbeatConn = nil
local flyCharacter, flyRootPart, flyHumanoid = nil, nil, nil
local flyInputState = {forward=false, backward=false, left=false, right=false}
local Clip = true
local Noclipping = nil
local flinging = false
local flingDied = nil
local FLYING = false
local QEfly = true
local iyflyspeed = 0.7
local flyKeyDown, flyKeyUp
local tpClickEnabled = false
local tpClickConn = nil

local function isAlly(p)
	if p == Player then return true end
	if not Cfg.IgnoreTeam then return false end
	if not Player.Team or not p.Team then return false end
	return Player.Team == p.Team
end

local function isEnemy(p) return not isAlly(p) end

local function RestoreAllHitboxes()
	for plr, state in pairs(OriginalStates) do
		if plr and plr.Character then
			local part = plr.Character:FindFirstChild(Cfg.TargetPart)
			if part then
				part.Size=state.Size; part.Transparency=state.Transparency
				part.CanCollide=state.CanCollide; part.Massless=state.Massless
			end
		end
	end
	table.clear(OriginalStates)
end

local function setFullbright(state)
	if state then
		if not fbOriginals then
			fbOriginals = {
				ClockTime=Lighting.ClockTime, FogEnd=Lighting.FogEnd,
				FogStart=Lighting.FogStart, Ambient=Lighting.Ambient,
				OutdoorAmbient=Lighting.OutdoorAmbient, Brightness=Lighting.Brightness,
			}
		end
		Lighting.Ambient = Color3.fromRGB(255,255,255)
		Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
		Lighting.Brightness = 2
		Lighting.FogEnd = 1e10
		Lighting.FogStart = 0
		Lighting.ClockTime = 14
	else
		if fbOriginals then
			Lighting.ClockTime = fbOriginals.ClockTime
			Lighting.FogEnd = fbOriginals.FogEnd
			Lighting.FogStart = fbOriginals.FogStart
			Lighting.Ambient = fbOriginals.Ambient
			Lighting.OutdoorAmbient = fbOriginals.OutdoorAmbient
			Lighting.Brightness = fbOriginals.Brightness
			fbOriginals = nil
		end
	end
end

local function stopFly()
	if not isFlying then return end
	isFlying = false; flyTarget = nil
	local char = Player.Character
	if char then
		local root = char:FindFirstChild("HumanoidRootPart")
		if root then
			pcall(function() root.Velocity = Vector3.new(0,0,0) end)
			pcall(function() root.AssemblyLinearVelocity = Vector3.new(0,0,0) end)
		end
		if not Cfg.NoclipEnabled then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then pcall(function() part.CanCollide = true end) end
			end
		end
	end
end

local function fetchFlyCharParts(char)
	flyCharacter = char
	flyRootPart = char:WaitForChild("HumanoidRootPart", 10)
	flyHumanoid = char:WaitForChild("Humanoid", 10)
end

local function setFlyPhysicsLock(locked)
	if not flyRootPart then return end
	flyRootPart.CustomPhysicalProperties = PhysicalProperties.new(locked and 0.01 or 0.7, locked and 0.001 or 0.3, 0, 0, 0)
	flyRootPart.AssemblyLinearVelocity = Vector3.zero
	flyRootPart.AssemblyAngularVelocity = Vector3.zero
end

local function getFlyInputDirection()
	local camDir = Camera.CFrame.LookVector
	local camRight = Camera.CFrame.RightVector
	local horRight = Vector3.new(camRight.X, 0, camRight.Z)
	if horRight.Magnitude > 0 then horRight = horRight.Unit else horRight = Vector3.new(1,0,0) end
	local moveDir = Vector3.zero
	if flyInputState.forward  then moveDir = moveDir + camDir   end
	if flyInputState.backward then moveDir = moveDir - camDir   end
	if flyInputState.right    then moveDir = moveDir + horRight end
	if flyInputState.left     then moveDir = moveDir - horRight end
	if moveDir.Magnitude > 0  then moveDir = moveDir.Unit       end
	return moveDir
end

local function startFlyLoop()
	if flyHeartbeatConn then flyHeartbeatConn:Disconnect() end
	flyHeartbeatConn = RS.Heartbeat:Connect(function(dt)
		if not flyActive then return end
		if not flyCharacter or not flyRootPart or not flyHumanoid then return end
		if flyHumanoid.Health <= 0 then flyActive = false; return end
		flyHumanoid:ChangeState(Enum.HumanoidStateType.Freefall)
		local inputDir = getFlyInputDirection()
		local targetVel = inputDir * Cfg.FlySpeed
		flyCurrentVel = flyCurrentVel:Lerp(targetVel, math.min(1, dt*8))
		local newPos = flyRootPart.Position + flyCurrentVel * dt
		flyRootPart.CFrame = CFrame.new(newPos) * (flyRootPart.CFrame - flyRootPart.CFrame.Position)
		flyRootPart.AssemblyLinearVelocity = Vector3.zero
		flyRootPart.AssemblyAngularVelocity = Vector3.zero
	end)
end

local function enableFly()
	if flyActive then return end
	fetchFlyCharParts(Player.Character or Player.CharacterAdded:Wait())
	flyActive = true; flyCurrentVel = Vector3.zero
	setFlyPhysicsLock(true); startFlyLoop()
end

local function disableFly()
	if not flyActive then return end
	flyActive = false; setFlyPhysicsLock(false)
	if flyHeartbeatConn then flyHeartbeatConn:Disconnect(); flyHeartbeatConn = nil end
	if flyHumanoid then flyHumanoid:ChangeState(Enum.HumanoidStateType.Freefall) end
	for k in pairs(flyInputState) do flyInputState[k] = false end
end

local function createFlyMobileControls()
	if not UIS.TouchEnabled then return end
	local existing = Player:FindFirstChild("PlayerGui") and Player.PlayerGui:FindFirstChild("FlyMobileControls")
	if existing then existing:Destroy() end
	local gui2 = Instance.new("ScreenGui")
	gui2.Name = "FlyMobileControls"; gui2.ResetOnSpawn = false
	gui2.Parent = Player:WaitForChild("PlayerGui")
	local sz = UDim2.new(0,90,0,90)
	local function makeBtn(name, text, pos)
		local btn = Instance.new("TextButton")
		btn.Name = name; btn.Text = text
		btn.Font = Enum.Font.GothamBold; btn.TextSize = 22
		btn.TextColor3 = Color3.new(1,1,1)
		btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
		btn.BackgroundTransparency = 0.3; btn.BorderSizePixel = 0
		btn.Position = pos; btn.Size = sz; btn.AutoButtonColor = false
		btn.Parent = gui2; return btn
	end
	local fwd = makeBtn("Forward","^",UDim2.new(0.14,-45,0.82,-105))
	local bwd = makeBtn("Backward","v",UDim2.new(0.14,-45,0.82,15))
	local lft = makeBtn("Left","<",UDim2.new(0.06,-45,0.82,-45))
	local rgt = makeBtn("Right",">",UDim2.new(0.22,-45,0.82,-45))
	local function conn(btn, key)
		btn.MouseButton1Down:Connect(function() flyInputState[key] = true  end)
		btn.MouseButton1Up:Connect(function()   flyInputState[key] = false end)
		btn.MouseLeave:Connect(function()       flyInputState[key] = false end)
	end
	conn(fwd,"forward"); conn(bwd,"backward"); conn(lft,"left"); conn(rgt,"right")
end

UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	local k = input.KeyCode
	if     k == Enum.KeyCode.W then flyInputState.forward  = true
	elseif k == Enum.KeyCode.S then flyInputState.backward = true
	elseif k == Enum.KeyCode.A then flyInputState.left     = true
	elseif k == Enum.KeyCode.D then flyInputState.right    = true
	end
end)

UIS.InputEnded:Connect(function(input)
	local k = input.KeyCode
	if     k == Enum.KeyCode.W then flyInputState.forward  = false
	elseif k == Enum.KeyCode.S then flyInputState.backward = false
	elseif k == Enum.KeyCode.A then flyInputState.left     = false
	elseif k == Enum.KeyCode.D then flyInputState.right    = false
	end
end)

local function CreateESPForPlayer(plr)
	if plr == Player or ESPObjects[plr] then return end
	local obj = {
		Box=SafeDrawing("Square"), Text=SafeDrawing("Text"),
		HealthBG=SafeDrawing("Square"), HealthBar=SafeDrawing("Square"),
	}
	obj.Box.Visible=false; obj.Box.Thickness=ESPConfig.BoxThickness
	obj.Box.Transparency=ESPConfig.BoxTransparency; obj.Box.Filled=false
	obj.Text.Visible=false; obj.Text.Size=ESPConfig.TextSize
	obj.Text.Center=true; obj.Text.Outline=true; obj.Text.Transparency=1
	obj.HealthBG.Visible=false; obj.HealthBG.Filled=true
	obj.HealthBG.Color=Color3.fromRGB(35,35,35); obj.HealthBG.Transparency=0.5
	obj.HealthBar.Visible=false; obj.HealthBar.Filled=true; obj.HealthBar.Transparency=1
	ESPObjects[plr] = obj
end

local function HideESP(obj)
	obj.Box.Visible=false; obj.Text.Visible=false
	obj.HealthBG.Visible=false; obj.HealthBar.Visible=false
end

local function GetHpColor(pct)
	return Color3.new(math.clamp(2*(1-pct),0,1), math.clamp(2*pct,0,1), 0)
end

local function RenderESP()
	if not ESPConfig.Enabled then
		for _, obj in pairs(ESPObjects) do HideESP(obj) end
		return
	end
	local camPos = Camera.CFrame.Position
	for plr, obj in pairs(ESPObjects) do
		if not plr or not plr.Parent or not plr.Character then HideESP(obj); continue end
		local char = plr.Character
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum or hum.Health <= 0 then HideESP(obj); continue end
		local dist = (hrp.Position - camPos).Magnitude
		if dist < 0.5 or dist > ESPConfig.MaxDistance then HideESP(obj); continue end
		if Cfg.IgnoreTeam and isAlly(plr) then HideESP(obj); continue end
		local headTop = hrp.Position + Vector3.new(0,3,0)
		local feetBot = hrp.Position - Vector3.new(0,3,0)
		local topSP = Camera:WorldToViewportPoint(headTop)
		local botSP, onScreen = Camera:WorldToViewportPoint(feetBot)
		if not onScreen or topSP.Z <= 0 then HideESP(obj); continue end
		local h = math.abs(topSP.Y - botSP.Y); local w = h * 0.55
		if h < 4 then HideESP(obj); continue end
		local bPos = Vector2.new(topSP.X - w*0.5, topSP.Y)
		local enemy2 = isEnemy(plr)
		local teamC = plr.Team and plr.TeamColor.Color or espColor
		local boxCol = ESPConfig.ShowTeamColor and teamC or (enemy2 and Color3.fromRGB(255,70,70) or Color3.fromRGB(70,255,70))
		if ESPConfig.ShowBoxes then
			obj.Box.Position=bPos; obj.Box.Size=Vector2.new(w,h)
			obj.Box.Color=boxCol; obj.Box.Visible=true
		end
		if ESPConfig.ShowNames then
			obj.Text.Text=plr.Name; obj.Text.Color=boxCol
			obj.Text.Size=ESPConfig.TextSize
			obj.Text.Position=Vector2.new(topSP.X, topSP.Y-17)
			obj.Text.Visible=true
		end
		if ESPConfig.ShowHealthBar then
			local hpPct = math.clamp(hum.Health/math.max(1,hum.MaxHealth), 0, 1)
			local bw = 3; local bx = bPos.X - bw - 2
			obj.HealthBG.Position=Vector2.new(bx,topSP.Y)
			obj.HealthBG.Size=Vector2.new(bw,h)
			obj.HealthBG.Visible=true
			obj.HealthBar.Position=Vector2.new(bx, topSP.Y+h*(1-hpPct))
			obj.HealthBar.Size=Vector2.new(bw, h*hpPct)
			obj.HealthBar.Color=GetHpColor(hpPct)
			obj.HealthBar.Visible=true
		end
	end
end

local function isGrille(obj)
	if not obj then return false end
	local n = obj.Name:lower()
	return n:find("grille") or n:find("vent") or n:find("lattice")
end

local function randomString()
	local length = math.random(10,20); local array = {}
	for i = 1, length do array[i] = string.char(math.random(32,126)) end
	return table.concat(array)
end

local function getRoot(char)
	if char and char:FindFirstChildOfClass("Humanoid") then
		return char:FindFirstChildOfClass("Humanoid").RootPart
	end
	return nil
end

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
	if Noclipping then Noclipping:Disconnect(); Noclipping = nil end
	Clip = true
end

local function NOFLY()
	FLYING = false
	if flyKeyDown then flyKeyDown:Disconnect() end
	if flyKeyUp   then flyKeyUp:Disconnect()   end
	local char = Player.Character
	if char and char:FindFirstChildOfClass("Humanoid") then
		char:FindFirstChildOfClass("Humanoid").PlatformStand = false
	end
	pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
end

local function sFLY(vfly)
	local char = Player.Character or Player.CharacterAdded:Wait()
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		repeat task.wait() until char:FindFirstChildOfClass("Humanoid")
		humanoid = char:FindFirstChildOfClass("Humanoid")
	end
	if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect(); flyKeyUp:Disconnect() end
	local T = getRoot(char)
	local CONTROL = {F=0,B=0,L=0,R=0,Q=0,E=0}
	local lCONTROL = {F=0,B=0,L=0,R=0,Q=0,E=0}
	local SPEED = 0
	local function FLY()
		FLYING = true
		local BG = Instance.new("BodyGyro"); local BV = Instance.new("BodyVelocity")
		BG.P = 9e4; BG.Parent = T; BV.Parent = T
		BG.MaxTorque = Vector3.new(9e9,9e9,9e9); BG.CFrame = T.CFrame
		BV.Velocity = Vector3.new(0,0,0); BV.MaxForce = Vector3.new(9e9,9e9,9e9)
		task.spawn(function()
			repeat task.wait()
				local camera = workspace.CurrentCamera
				if not vfly and humanoid then humanoid.PlatformStand = true end
				if CONTROL.L+CONTROL.R~=0 or CONTROL.F+CONTROL.B~=0 or CONTROL.Q+CONTROL.E~=0 then
					SPEED = 50
				elseif SPEED ~= 0 then SPEED = 0 end
				if (CONTROL.L+CONTROL.R)~=0 or (CONTROL.F+CONTROL.B)~=0 or (CONTROL.Q+CONTROL.E)~=0 then
					BV.Velocity = ((camera.CFrame.LookVector*(CONTROL.F+CONTROL.B))+((camera.CFrame*CFrame.new(CONTROL.L+CONTROL.R,(CONTROL.F+CONTROL.B+CONTROL.Q+CONTROL.E)*0.2,0).p)-camera.CFrame.p))*SPEED
					lCONTROL = {F=CONTROL.F,B=CONTROL.B,L=CONTROL.L,R=CONTROL.R}
				elseif (CONTROL.L+CONTROL.R)==0 and (CONTROL.F+CONTROL.B)==0 and (CONTROL.Q+CONTROL.E)==0 and SPEED~=0 then
					BV.Velocity = ((camera.CFrame.LookVector*(lCONTROL.F+lCONTROL.B))+((camera.CFrame*CFrame.new(lCONTROL.L+lCONTROL.R,(lCONTROL.F+lCONTROL.B+CONTROL.Q+CONTROL.E)*0.2,0).p)-camera.CFrame.p))*SPEED
				else BV.Velocity = Vector3.new(0,0,0) end
				BG.CFrame = camera.CFrame
			until not FLYING
			CONTROL={F=0,B=0,L=0,R=0,Q=0,E=0}
			lCONTROL={F=0,B=0,L=0,R=0,Q=0,E=0}
			SPEED=0
			BG:Destroy(); BV:Destroy()
			if humanoid then humanoid.PlatformStand = false end
		end)
	end
	flyKeyDown = UIS.InputBegan:Connect(function(input, processed)
		if processed then return end
		local spd = iyflyspeed
		if     input.KeyCode==Enum.KeyCode.W then CONTROL.F=spd
		elseif input.KeyCode==Enum.KeyCode.S then CONTROL.B=-spd
		elseif input.KeyCode==Enum.KeyCode.A then CONTROL.L=-spd
		elseif input.KeyCode==Enum.KeyCode.D then CONTROL.R=spd
		elseif input.KeyCode==Enum.KeyCode.E and QEfly then CONTROL.Q=spd*2
		elseif input.KeyCode==Enum.KeyCode.Q and QEfly then CONTROL.E=-spd*2 end
		pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Track end)
	end)
	flyKeyUp = UIS.InputEnded:Connect(function(input, processed)
		if processed then return end
		if     input.KeyCode==Enum.KeyCode.W then CONTROL.F=0
		elseif input.KeyCode==Enum.KeyCode.S then CONTROL.B=0
		elseif input.KeyCode==Enum.KeyCode.A then CONTROL.L=0
		elseif input.KeyCode==Enum.KeyCode.D then CONTROL.R=0
		elseif input.KeyCode==Enum.KeyCode.E then CONTROL.Q=0
		elseif input.KeyCode==Enum.KeyCode.Q then CONTROL.E=0 end
	end)
	FLY()
end

local function unfling()
	disableNoclip(); NOFLY()
	if flingDied then flingDied:Disconnect() end
	flinging = false
	local char = Player.Character
	if not char or not getRoot(char) then return end
	for _, v in pairs(getRoot(char):GetChildren()) do
		if v:IsA("AngularVelocity") or v:IsA("BodyAngularVelocity") or v.Name=="FlingAttachment" then
			v:Destroy()
		end
	end
	for _, child in pairs(char:GetDescendants()) do
		if child:IsA("BasePart") then child.CustomPhysicalProperties = nil end
	end
end

local function fling()
	unfling()
	local char = Player.Character; if not char then return end
	local root = getRoot(char); if not root then return end
	flinging = true
	for _, child in pairs(char:GetDescendants()) do
		if child:IsA("BasePart") then
			child.CustomPhysicalProperties = PhysicalProperties.new(100,0.3,0.5)
			child.CanCollide = false; child.Massless = true
			child.Velocity = Vector3.new(0,0,0)
		end
	end
	enableNoclip(); task.wait(0.1)
	local bambam = Instance.new("BodyAngularVelocity")
	bambam.Name = randomString(); bambam.Parent = root
	bambam.AngularVelocity = Vector3.new(0,99999,0)
	bambam.MaxTorque = Vector3.new(0,math.huge,0); bambam.P = math.huge
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if humanoid then flingDied = humanoid.Died:Connect(unfling) end
	task.spawn(sFLY)
	task.spawn(function()
		while flinging and char and root and bambam do
			bambam.AngularVelocity = Vector3.new(0,99999,0); task.wait(0.2)
			if not flinging then break end
			bambam.AngularVelocity = Vector3.new(0,0,0); task.wait(0.1)
		end
	end)
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
	pcall(function()
		game.StarterGui:SetCore("SendNotification", {Title="bulo hub", Text="UI load failed!", Duration=10})
	end)
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

local InfoTab    = Window:CreateTab("Info",     4483362458)
local CombatTab  = Window:CreateTab("Combat",   4483345998)
local VisualsTab = Window:CreateTab("Visuals",  4483345998)
local MoveTab    = Window:CreateTab("Movement", 4483345998)

InfoTab:CreateSection("")
InfoTab:CreateLabel("User: " .. Player.DisplayName .. " (@" .. Player.Name .. ")")
InfoTab:CreateLabel("ID: " .. tostring(Player.UserId))
InfoTab:CreateLabel("Executor: " .. executorName)
InfoTab:CreateLabel("Device: " .. getDeviceInfo())

CombatTab:CreateSection("Fling")
CombatTab:CreateToggle({
	Name="Enable Fling", CurrentValue=false, Flag="FlingToggle",
	Callback=function(v) if v then fling() else unfling() end end
})

VisualsTab:CreateSection("Player ESP")
VisualsTab:CreateToggle({
	Name="Enable ESP", CurrentValue=false, Flag="EspToggle",
	Callback=function(v) ESPConfig.Enabled=v end
})
VisualsTab:CreateToggle({
	Name="Show Boxes", CurrentValue=true, Flag="ShowBoxes",
	Callback=function(v) ESPConfig.ShowBoxes=v end
})
VisualsTab:CreateToggle({
	Name="Show Names", CurrentValue=true, Flag="ShowNames",
	Callback=function(v) ESPConfig.ShowNames=v end
})
VisualsTab:CreateToggle({
	Name="Show Health Bar", CurrentValue=true, Flag="ShowHp",
	Callback=function(v) ESPConfig.ShowHealthBar=v end
})
VisualsTab:CreateToggle({
	Name="Team Colors", CurrentValue=true, Flag="TeamColor",
	Callback=function(v) ESPConfig.ShowTeamColor=v end
})
VisualsTab:CreateSlider({
	Name="Max Distance", Range={100,10000}, Increment=100,
	Suffix="m", CurrentValue=5000, Flag="EspMaxDist",
	Callback=function(v) ESPConfig.MaxDistance=v end
})

VisualsTab:CreateSection("World")
VisualsTab:CreateToggle({
	Name="Full Bright", CurrentValue=false, Flag="FullBright",
	Callback=function(v) setFullbright(v) end
})
VisualsTab:CreateSlider({
	Name="Camera FOV", Range={70,120}, Increment=1,
	Suffix="deg", CurrentValue=70, Flag="WorldFovSlider",
	Callback=function(v)
		Cfg.WorldFOV=v
		pcall(function()
			if Camera then
				Camera.FieldOfView=v
				Camera.FieldOfViewMode=Enum.FieldOfViewMode.Vertical
			end
		end)
	end
})

MoveTab:CreateSection("Speed")
MoveTab:CreateToggle({
	Name="Speedhack", CurrentValue=false, Flag="Speedhack",
	Callback=function(v) Cfg.SpeedhackEnabled=v end
})
MoveTab:CreateSlider({
	Name="Speed Multiplier", Range={10,100}, Increment=1,
	Suffix="x0.1", CurrentValue=15, Flag="SpeedMult",
	Callback=function(v) Cfg.SpeedMultiplier=v end
})
MoveTab:CreateToggle({
	Name="Anti-Slowdown", CurrentValue=false, Flag="AntiSlow",
	Callback=function(v) Cfg.AntiSlowdown=v end
})
MoveTab:CreateToggle({
	Name="NoClip", CurrentValue=false, Flag="Noclip",
	Callback=function(v) Cfg.NoclipEnabled=v end
})

MoveTab:CreateSection("Jump")
MoveTab:CreateToggle({
	Name="Infinity Jump", CurrentValue=false, Flag="InfJump",
	Callback=function(v) Cfg.InfJumpEnabled=v end
})
MoveTab:CreateSlider({
	Name="Jump Force", Range={20,150}, Increment=1,
	CurrentValue=50, Flag="JumpForce",
	Callback=function(v) Cfg.InfJumpForce=v end
})

MoveTab:CreateSection("Fly")
MoveTab:CreateToggle({
	Name="Enable Fly", CurrentValue=false, Flag="FlyToggle",
	Callback=function(v)
		if v then
			enableFly()
			if UIS.TouchEnabled then createFlyMobileControls() end
		else
			disableFly()
			pcall(function()
				local g = Player.PlayerGui:FindFirstChild("FlyMobileControls")
				if g then g:Destroy() end
			end)
		end
	end
})
MoveTab:CreateSlider({
	Name="Fly Speed", Range={5,100}, Increment=1,
	CurrentValue=35, Flag="FlySpeedSlider",
	Callback=function(v) Cfg.FlySpeed=v end
})

MoveTab:CreateSection("Teleport Click")
MoveTab:CreateToggle({
	Name="Teleport Click (E)", CurrentValue=false, Flag="TpClick",
	Callback=function(v)
		tpClickEnabled=v
		if v then
			tpClickConn=UIS.InputBegan:Connect(function(input,gp)
				if gp then return end
				if not tpClickEnabled then return end
				if input.KeyCode==Enum.KeyCode.E then
					local char=Player.Character; if not char then return end
					local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
					local unitRay=Camera:ScreenPointToRay(Mouse.X,Mouse.Y)
					local rayParams=RaycastParams.new()
					rayParams.FilterType=Enum.RaycastFilterType.Exclude
					rayParams.FilterDescendantsInstances={char}
					local result=workspace:Raycast(unitRay.Origin,unitRay.Direction*1000,rayParams)
					if result then
						hrp.CFrame=CFrame.new(result.Position+Vector3.new(0,3,0))
					end
				end
			end)
			pcall(function()
				game.StarterGui:SetCore("SendNotification",{Title="Teleport Click",Text="ON - Press E",Duration=2})
			end)
		else
			if tpClickConn then tpClickConn:Disconnect(); tpClickConn=nil end
			pcall(function()
				game.StarterGui:SetCore("SendNotification",{Title="Teleport Click",Text="OFF",Duration=2})
			end)
		end
	end
})

MoveTab:CreateSection("Teleport")
MoveTab:CreateButton({
	Name = "TP above the map",
	Callback = function()
		local char = Player.Character
		if char then
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if hrp then hrp.CFrame = CFrame.new(1016.28, 571.60, 1402.03) end
		end
	end
})

table.insert(connections, RS.RenderStepped:Connect(function()
	pcall(function()
		if Cfg.AutoGrilleEnabled then
			if Mouse.Target and isGrille(Mouse.Target) then
				local now=tick()*1000
				if now-lastClick>=Cfg.ClickDelay then SafeClick(); lastClick=now end
			end
		end
	end)
	pcall(RenderESP)
end))

table.insert(connections, RS.Heartbeat:Connect(function(dt)
	pcall(function()
		if Player.Character then
			local root=Player.Character:FindFirstChild("HumanoidRootPart")
			local hum=Player.Character:FindFirstChildOfClass("Humanoid")
			if hum and Cfg.AntiSlowdown then
				if hum.WalkSpeed<16 then hum.WalkSpeed=16 end
			end
			if not isFlying and not flyActive and Cfg.SpeedhackEnabled and root and hum and hum.MoveDirection.Magnitude>0 then
				local baseSpeed=hum.WalkSpeed
				if Cfg.AntiSlowdown and baseSpeed<16 then baseSpeed=16 end
				root.CFrame=root.CFrame+(hum.MoveDirection.Unit*baseSpeed*((Cfg.SpeedMultiplier/10)-1)*dt)
			end
		end
	end)
	pcall(function()
		if isFlying and flyTarget then
			local char=Player.Character; if not char then stopFly(); return end
			local root=char:FindFirstChild("HumanoidRootPart"); if not root then stopFly(); return end
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then pcall(function() part.CanCollide=false end) end
			end
			local dir=flyTarget-root.Position; local dist=dir.Magnitude
			if dist<=5 then
				root.CFrame=CFrame.new(flyTarget)
				pcall(function() root.Velocity=Vector3.new(0,0,0) end)
				stopFly(); return
			end
			local step=dir.Unit*math.min(Cfg.FlySpeed,dist)*dt
			pcall(function() root.Velocity=Vector3.new(0,0,0) end)
			pcall(function() root.AssemblyLinearVelocity=Vector3.new(0,0,0) end)
			local ld=Vector3.new(dir.X,0,dir.Z)
			if ld.Magnitude>0.1 then
				root.CFrame=CFrame.lookAt(root.Position+step,root.Position+step+ld.Unit)
			else
				root.CFrame=root.CFrame+step
			end
		end
	end)
end))

table.insert(connections, RS.Stepped:Connect(function()
	pcall(function()
		if (Cfg.NoclipEnabled or isFlying or flyActive) and Player.Character then
			for _, part in ipairs(Player.Character:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide=false end
			end
		end
	end)
end))

table.insert(connections, UIS.JumpRequest:Connect(function()
	if not Cfg.InfJumpEnabled then return end
	pcall(function()
		local char=Player.Character; if not char then return end
		local root=char:FindFirstChild("HumanoidRootPart")
		local hum=char:FindFirstChildOfClass("Humanoid")
		if root and hum then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
			root.Velocity=Vector3.new(root.Velocity.X,Cfg.InfJumpForce,root.Velocity.Z)
		end
	end)
end))

Player.CharacterAdded:Connect(function(newChar)
	task.wait(0.3)
	if isFlying then stopFly() end
	if flyActive then
		flyActive=false; flyCurrentVel=Vector3.zero
		if flyHeartbeatConn then flyHeartbeatConn:Disconnect(); flyHeartbeatConn=nil end
	end
	fetchFlyCharParts(newChar)
	RestoreAllHitboxes()
	pcall(function()
		if Camera then
			Camera.FieldOfView=Cfg.WorldFOV
			Camera.FieldOfViewMode=Enum.FieldOfViewMode.Vertical
		end
	end)
end)

pcall(function()
	local VirtualUser=game:GetService("VirtualUser")
	Players.LocalPlayer.Idled:Connect(function()
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new())
	end)
end)

for _, p in ipairs(Players:GetPlayers()) do pcall(function() CreateESPForPlayer(p) end) end
Players.PlayerAdded:Connect(function(p) pcall(function() CreateESPForPlayer(p) end) end)
Players.PlayerRemoving:Connect(function(p)
	pcall(function()
		if ESPObjects[p] then
			for _, d in pairs(ESPObjects[p]) do pcall(function() d:Remove() end) end
			ESPObjects[p]=nil
		end
	end)
end)

fetchFlyCharParts(Player.Character or Player.CharacterAdded:Wait())

pcall(function()
	Rayfield:Notify({
		Title = "bulo hub ["..executorName.."]",
		Content = "All functions loaded!",
		Duration = 5,
		Image = 4483362458,
	})
end)