-- Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Window
local Window = Rayfield:CreateWindow({
	Name = "Ringfall Hub",
    Icon = 131870309052244,
	LoadingTitle = "Loading",
	LoadingSubtitle = "by @aeroxol115 in youtube",
	ConfigurationSaving = {Enabled = false},
	KeySystem = false
})

-- Notify
Rayfield:Notify({
	Title = "Creator:",
	Content = "by @aeroxol115 in youtube",
	Duration = 3
})

-- Tabs
local HomeTab = Window:CreateTab("Home", "home")
local TeleportTab = Window:CreateTab("Teleport", "earth")

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- =========================
-- FLY (STACK SAFE VERSION)
-- =========================

HomeTab:CreateSection("Fly")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local speaker = Players.LocalPlayer

local speeds = 20
local nowe = false
local tpwalking = false
local flyThread = nil

local function stopFly()
	nowe = false
	tpwalking = false
	
	if flyThread then
		flyThread = nil
	end
	
	local char = speaker.Character
	if not char then return end
	
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		for _,state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
			hum:SetStateEnabled(state, true)
		end
		hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
		hum.PlatformStand = false
	end
	
	if char:FindFirstChild("Animate") then
		char.Animate.Disabled = false
	end
end

local function startFly()
	if flyThread then
		stopFly()
		task.wait()
	end
	
	nowe = true
	
	flyThread = task.spawn(function()

		for i = 1, speeds do
			task.spawn(function()
				local hb = RunService.Heartbeat
				tpwalking = true
				local chr = speaker.Character
				local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")

				while tpwalking and nowe and hb:Wait() and chr and hum and hum.Parent do
					if hum.MoveDirection.Magnitude > 0 then
						chr:TranslateBy(hum.MoveDirection * 0.15)
					end
				end
			end)
		end

		local char = speaker.Character
		if not char then return end
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hum then return end

		if char:FindFirstChild("Animate") then
			char.Animate.Disabled = true
		end

		for _,v in next, hum:GetPlayingAnimationTracks() do
			v:AdjustSpeed(0)
		end

		for _,state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
			hum:SetStateEnabled(state, false)
		end

		hum:ChangeState(Enum.HumanoidStateType.Swimming)
		hum.PlatformStand = true

		local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")

		local bg = Instance.new("BodyGyro", torso)
		bg.P = 9e4
		bg.maxTorque = Vector3.new(9e9,9e9,9e9)
		bg.cframe = torso.CFrame

		local bv = Instance.new("BodyVelocity", torso)
		bv.velocity = Vector3.new(0,0.1,0)
		bv.maxForce = Vector3.new(9e9,9e9,9e9)

		while nowe and hum.Health > 0 do
			RunService.RenderStepped:Wait()
			bg.cframe = workspace.CurrentCamera.CoordinateFrame
		end

		bg:Destroy()
		bv:Destroy()
	end)
end

HomeTab:CreateToggle({
	Name = "Fly",
	CurrentValue = false,
	Callback = function(state)
		if state then
			startFly()
		else
			stopFly()
		end
	end
})

HomeTab:CreateSlider({
	Name = "Fly Speed",
	Range = {1, 400},
	Increment = 10,
	CurrentValue = 100,
	Callback = function(val)
		speeds = val
		
		if nowe then
			-- HARD RESET LOOPS
			tpwalking = false
			task.wait() -- let old loops die
			
			startFly() -- restart with new speed
		end
	end
})

-- =========================
-- JUMP
-- =========================
HomeTab:CreateSection("jump")

local jumpEnabled = false
local jumpPower = 50 -- default Roblox jump

HomeTab:CreateToggle({
	Name = "Jump",
	CurrentValue = false,
	Callback = function(state)
		jumpEnabled = state

		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.UseJumpPower = true
			hum.JumpPower = state and jumpPower or 50
		end
	end,
})

HomeTab:CreateSlider({
	Name = "Jump Power",
	Range = {50, 400},
	Increment = 10,
	CurrentValue = 50,
	Callback = function(val)
		jumpPower = val

		if jumpEnabled then
			local char = player.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if hum then
				hum.JumpPower = val
			end
		end
	end,
})

-- =========================
-- WALK SPEED
-- =========================
HomeTab:CreateSection("walk")

local walkEnabled = false
local walkSpeed = 16

HomeTab:CreateToggle({
	Name = "Enable Walk Speed",
	CurrentValue = false,
	Callback = function(state)
		walkEnabled = state
		local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = state and walkSpeed or 16
		end
	end,
})

HomeTab:CreateSlider({
	Name = "Walk Speed",
	Range = {16, 400},
	Increment = 10,
	CurrentValue = 16,
	Callback = function(val)
		walkSpeed = val
		if walkEnabled then
			local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum.WalkSpeed = val end
		end
	end,
})

-- =========================
-- NOCLIP + INF JUMP + GOD MODE
-- =========================
HomeTab:CreateSection("others")

local noclip = false

HomeTab:CreateToggle({
	Name = "Noclip",
	CurrentValue = false,
	Callback = function(state)
		noclip = state

		if not state and player.Character then
			for _, v in pairs(player.Character:GetDescendants()) do
				if v:IsA("BasePart") then
					v.CanCollide = true
				end
			end
		end
	end,
})

RunService.Stepped:Connect(function()
	if noclip and player.Character then
		for _, v in pairs(player.Character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
	end
end)

-- Infinite Jump
local InfiniteJump = false

HomeTab:CreateToggle({
	Name = "Infinite Jump",
	CurrentValue = false,
	Callback = function(state)
		InfiniteJump = state
	end,
})

UIS.JumpRequest:Connect(function()
	if InfiniteJump then
		local Char = player.Character
		if Char then
			local Humanoid = Char:FindFirstChildOfClass("Humanoid")
			if Humanoid then
				Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end
	end
end)

local Lighting = game:GetService("Lighting")

-- Save original values
local Original = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

HomeTab:CreateToggle({
    Name = "Night Vision",
    CurrentValue = false,
    Flag = "UltimateFullBright",
    Callback = function(Value)
        if Value then
            -- Max visibility settings
            Lighting.Brightness = 5
            Lighting.ClockTime = 14 -- Daytime
            Lighting.FogEnd = 1000000
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(255,255,255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)

            -- Remove darkness effects
            for _,v in pairs(Lighting:GetChildren()) do
                if v:IsA("ColorCorrectionEffect") 
                or v:IsA("BloomEffect") 
                or v:IsA("BlurEffect") 
                or v:IsA("SunRaysEffect") then
                    v.Enabled = false
                end
            end

        else
            -- Restore original
            Lighting.Brightness = Original.Brightness
            Lighting.ClockTime = Original.ClockTime
            Lighting.FogEnd = Original.FogEnd
            Lighting.GlobalShadows = Original.GlobalShadows
            Lighting.Ambient = Original.Ambient
            Lighting.OutdoorAmbient = Original.OutdoorAmbient
        end
    end,
})

-- =========================
-- GOD MODE (V3)
-- =========================

local godEnabled = false
local deathPos
local charConnection
local godConnections = {}

HomeTab:CreateToggle({
	Name = "God Mode",
	CurrentValue = false,
	Callback = function(state)
		godEnabled = state

		-- CLEAN OLD CONNECTIONS
		if charConnection then
			charConnection:Disconnect()
			charConnection = nil
		end

		for _, c in pairs(godConnections) do
			c:Disconnect()
		end
		godConnections = {}

		if not state then return end

		local function setupGod(character)
			local humanoid = character:WaitForChild("Humanoid")

			-- Prevent death
			table.insert(godConnections,
				humanoid.HealthChanged:Connect(function(health)
					if godEnabled and health <= 0 then
						humanoid.Health = humanoid.MaxHealth
					end
				end)
			)

			-- Respawn at same position
			table.insert(godConnections,
				humanoid.Died:Connect(function()
					if godEnabled then
						local hrp = character:FindFirstChild("HumanoidRootPart")
						if hrp then
							deathPos = hrp.Position
						end
						task.wait(0.05)
						player:LoadCharacter()
					end
				end)
			)

			humanoid.Health = humanoid.MaxHealth
		end

		-- Character added listener
		charConnection = player.CharacterAdded:Connect(function(char)
			if deathPos then
				repeat task.wait() until char:FindFirstChild("HumanoidRootPart")
				char.HumanoidRootPart.CFrame = CFrame.new(deathPos)
			end
			setupGod(char)
		end)

		-- If already spawned
		if player.Character then
			setupGod(player.Character)
		end
	end,
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local AntiFlingEnabled = false
local trackedParts = {}
local connections = {}

local RenderConnection
local PlayerAddedConnection

-- Save original state and disable collision
local function disableCanCollide(part)
	if part:IsA("BasePart") then
		if trackedParts[part] == nil then
			trackedParts[part] = part.CanCollide -- save original
		end
		part.CanCollide = false
	end
end

-- Restore original CanCollide
local function restoreCanCollide()
	for part, originalState in pairs(trackedParts) do
		if part and part.Parent then
			part.CanCollide = originalState
		end
	end
	trackedParts = {}
end

local function handleCharacter(character)
	for _, part in ipairs(character:GetDescendants()) do
		disableCanCollide(part)
	end
end

local function handlePlayer(player)
	if player == LocalPlayer then return end
	
	if player.Character then
		handleCharacter(player.Character)
	end
	
	local charConn = player.CharacterAdded:Connect(function(character)
		if AntiFlingEnabled then
			handleCharacter(character)
		end
	end)
	
	table.insert(connections, charConn)
end

local function enableAntiFling()
	AntiFlingEnabled = true
	
	for _, player in ipairs(Players:GetPlayers()) do
		handlePlayer(player)
	end
	
	PlayerAddedConnection = Players.PlayerAdded:Connect(function(player)
		if AntiFlingEnabled then
			handlePlayer(player)
		end
	end)
	
	RenderConnection = RunService.RenderStepped:Connect(function()
		if not AntiFlingEnabled then return end
		
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				for _, part in ipairs(player.Character:GetDescendants()) do
					disableCanCollide(part)
				end
			end
		end
	end)
end

local function disableAntiFling()
	AntiFlingEnabled = false
	
	if RenderConnection then
		RenderConnection:Disconnect()
		RenderConnection = nil
	end
	
	if PlayerAddedConnection then
		PlayerAddedConnection:Disconnect()
		PlayerAddedConnection = nil
	end
	
	for _, conn in ipairs(connections) do
		conn:Disconnect()
	end
	
	connections = {}
	
	-- 🔥 THIS IS THE IMPORTANT FIX
	restoreCanCollide()
end

-- Rayfield Toggle (Correct format)
HomeTab:CreateToggle({
	Name = "Anti-Fling",
	CurrentValue = false, -- DEFAULT OFF
	Flag = "AntiFling",
	Callback = function(Value)
		if Value then
			enableAntiFling()
		else
			disableAntiFling()
		end
	end,
})

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

--// State
local EgorRunEnabled = false

--// Create Section (inside Home tab)
local EgorSection = HomeTab:CreateSection("Roblox egor")

--// Toggle
HomeTab:CreateToggle({
    Name = "Roblox Egor",
    CurrentValue = false,
    Flag = "EgorRunFix",
    Callback = function(Value)
        EgorRunEnabled = Value
        
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")

        if not Value and hum then
            hum.WalkSpeed = 16 -- Reset when turned off
        end
    end,
})

--// Main Loop
RunService.RenderStepped:Connect(function()
    if not EgorRunEnabled then return end

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if not hum then return end

    -- Slow actual movement
    hum.WalkSpeed = 5

    -- Speed up run/walk animations
    if hum.MoveDirection.Magnitude > 0 then
        for _, track in pairs(hum:GetPlayingAnimationTracks()) do
            local name = track.Name:lower()
            if name:find("run") or name:find("walk") then
                track:AdjustSpeed(6)
            end
        end
    end
end)

--// Fix on respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if EgorRunEnabled then
        local hum = char:WaitForChild("Humanoid")
        hum.WalkSpeed = 5
    end
end)


-- =========================
-- TELEPORT POSITIONS (FIXED)
-- =========================
TeleportTab:CreateSection("Teleport to Position")

local teleports = {}
local selectedIndex = nil

local Dropdown = TeleportTab:CreateDropdown({
	Name = "Places",
	Options = {},
	CurrentOption = nil,
	Callback = function(option)
		option = typeof(option) == "table" and option[1] or option
		for i = 1, #teleports do
			if option == "Place "..i then
				selectedIndex = i
				break
			end
		end
	end,
})

local function refreshDropdown()
	local options = {}
	for i = 1, #teleports do
		table.insert(options, "Place "..i)
	end
	Dropdown:Refresh(options)
end

TeleportTab:CreateButton({
	Name = "Add Position",
	Callback = function()
		local char = player.Character
		if not char or not char:FindFirstChild("HumanoidRootPart") then return end

		table.insert(teleports, char.HumanoidRootPart.Position)
		refreshDropdown()
	end,
})

TeleportTab:CreateButton({
	Name = "Teleport",
	Callback = function()
		local char = player.Character
		if not char then return end

		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		if selectedIndex and teleports[selectedIndex] then
			hrp.CFrame = CFrame.new(teleports[selectedIndex] + Vector3.new(0,3,0))
		else
			Rayfield:Notify({
				Title = "Error",
				Content = "No place selected!",
				Duration = 3
			})
		end
	end,
})

TeleportTab:CreateButton({
	Name = "Remove Selected",
	Callback = function()
		if selectedIndex and teleports[selectedIndex] then
			table.remove(teleports, selectedIndex)

			if #teleports == 0 then
				selectedIndex = nil
				Dropdown:Refresh({})
			else
				selectedIndex = nil
				refreshDropdown()
			end
		end
	end,
})

-- =========================
-- TELEPORT TO PLAYER
-- =========================
TeleportTab:CreateSection("Teleport to Player")

local selectedPlayer = nil

local playerDropdown = TeleportTab:CreateDropdown({
	Name = "Select Player",
	Options = {},
	CurrentOption = nil,
	Callback = function(option)
		selectedPlayer = typeof(option) == "table" and option[1] or option
	end,
})

local function refreshPlayers()
	local list = {}
	for _, p in pairs(game.Players:GetPlayers()) do
		if p ~= player then
			table.insert(list, p.Name)
		end
	end
	playerDropdown:Refresh(list)
end

refreshPlayers()
game.Players.PlayerAdded:Connect(refreshPlayers)
game.Players.PlayerRemoving:Connect(refreshPlayers)

TeleportTab:CreateButton({
	Name = "Teleport to Selected Player",
	Callback = function()
		if not selectedPlayer then
			Rayfield:Notify({
				Title = "Error",
				Content = "No player selected!",
				Duration = 3
			})
			return
		end

		local target = game.Players:FindFirstChild(selectedPlayer)
		local char = player.Character
		if not char then return end

		local myHRP = char:FindFirstChild("HumanoidRootPart")
		if not myHRP then return end

		if target and target.Character then
			local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
			if targetHRP then
				myHRP.CFrame = targetHRP.CFrame + Vector3.new(0,3,0)
			end
		end
	end,
})

-- =========================
-- ESP TAB (FULL CLEAN VERSION)
-- =========================

local ESPTab = Window:CreateTab("ESP", "eye")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- =========================
-- COLOR OPTIONS (Dropdown Selection)
-- =========================

local colorOptions = {
	["White"] = Color3.new(1,1,1),
	["Red"] = Color3.new(1,0,0),
	["Green"] = Color3.new(0,1,0),
	["Blue"] = Color3.new(0,0,1),
	["Yellow"] = Color3.new(1,1,0),
	["Purple"] = Color3.new(1,0,1),
	["Cyan"] = Color3.new(0,1,1),
	["Orange"] = Color3.fromRGB(255,165,0)
}

-- =========================
-- GLOBAL SETTINGS
-- =========================

local globalESPEnabled = false
local globalStudsEnabled = false
local globalESPColor = Color3.new(1,0,0)
local globalStudsColor = Color3.new(1,1,1)
local globalESPDistance = 600
local globalESPIntensity = 8
local globalStudsDistance = 600
local globalStudsSize = 30

-- =========================
-- SPECIFIC SETTINGS
-- =========================

local specificPlayer = nil
local specificESPEnabled = false
local specificStudsEnabled = false
local specificESPColor = Color3.new(1,0,0)
local specificStudsColor = Color3.new(1,1,1)
local specificESPDistance = 600
local specificESPIntensity = 8
local specificStudsDistance = 600
local specificStudsSize = 30

local espObjects = {}

-- =========================
-- CREATE ESP OBJECTS
-- =========================

local function createESP(player)
	if player == LocalPlayer then return end
	
	local function onChar(char)
		local hrp = char:WaitForChild("HumanoidRootPart",5)
		local head = char:WaitForChild("Head",5)
		if not hrp or not head then return end
		
		-- Highlight
		local box = Instance.new("Highlight")
		box.FillTransparency = 0.7
		box.OutlineTransparency = 1
		box.Enabled = false
		box.Parent = char
		
		-- Studs GUI
		local bill = Instance.new("BillboardGui")
		bill.Size = UDim2.new(0,200,0,50)
		bill.StudsOffset = Vector3.new(0,2,0)
		bill.AlwaysOnTop = true
		bill.Enabled = false
		bill.Parent = head
		
		local txt = Instance.new("TextLabel")
		txt.Size = UDim2.new(1,0,1,0)
		txt.BackgroundTransparency = 1
		txt.Font = Enum.Font.GothamBold
		txt.TextColor3 = Color3.new(1,1,1)
		txt.TextSize = 30
		txt.Text = ""
		txt.Parent = bill
		
		espObjects[player] = {
			box = box,
			gui = bill,
			label = txt,
			char = char
		}
	end
	
	if player.Character then
		onChar(player.Character)
	end
	
	player.CharacterAdded:Connect(onChar)
end

for _,p in pairs(Players:GetPlayers()) do
	createESP(p)
end
Players.PlayerAdded:Connect(createESP)

-- =========================
-- UPDATE LOOP
-- =========================

RunService.RenderStepped:Connect(function()
	for player,data in pairs(espObjects) do
		
		local char = data.char
		if not char or not char.Parent then continue end
		
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not hrp or not myHRP then continue end
		
		local dist = (hrp.Position - myHRP.Position).Magnitude
		local isSpecific = specificPlayer and player.Name == specificPlayer
		
		-- ================= GLOBAL =================
		
		if not isSpecific then
			
			-- ESP
			data.box.Enabled = globalESPEnabled and dist <= globalESPDistance
			data.box.FillColor = globalESPColor
			data.box.FillTransparency = 1 - (globalESPIntensity / 10)
			
			-- Studs
			data.gui.Enabled = globalStudsEnabled and dist <= globalStudsDistance
			data.label.Text = math.floor(dist).." studs"
			data.label.TextColor3 = globalStudsColor
			data.label.TextSize = globalStudsSize
		end
		
		-- ================= SPECIFIC =================
		
		if isSpecific then
			
			-- ESP
			data.box.Enabled = specificESPEnabled and dist <= specificESPDistance
			data.box.FillColor = specificESPColor
			data.box.FillTransparency = 1 - (specificESPIntensity / 10)
			
			-- Studs
			data.gui.Enabled = specificStudsEnabled and dist <= specificStudsDistance
			data.label.Text = math.floor(dist).." studs"
			data.label.TextColor3 = specificStudsColor
			data.label.TextSize = specificStudsSize
		end
	end
end)

-- =========================
-- UI SECTION 1: GLOBAL
-- =========================

ESPTab:CreateSection("Global")

ESPTab:CreateToggle({
	Name = "Global ESP",
	CurrentValue = false,
	Callback = function(val)
		globalESPEnabled = val
	end
})

ESPTab:CreateToggle({
	Name = "Global Studs",
	CurrentValue = false,
	Callback = function(val)
		globalStudsEnabled = val
	end
})

ESPTab:CreateDropdown({
	Name = "Global ESP Color",
	Options = {"White","Red","Green","Blue","Yellow","Purple","Cyan","Orange"},
	CurrentOption = "Red",
	Callback = function(opt)
		globalESPColor = colorOptions[typeof(opt)=="table" and opt[1] or opt]
	end
})

ESPTab:CreateDropdown({
	Name = "Global Studs Color",
	Options = {"White","Red","Green","Blue","Yellow","Purple","Cyan","Orange"},
	CurrentOption = "White",
	Callback = function(opt)
		globalStudsColor = colorOptions[typeof(opt)=="table" and opt[1] or opt]
	end
})

ESPTab:CreateSlider({
	Name = "Global ESP Distance",
	Range = {100,3000},
	Increment = 50,
	CurrentValue = 600,
	Callback = function(val)
		globalESPDistance = val
	end
})

ESPTab:CreateSlider({
	Name = "Global ESP Intensity",
	Range = {1,10},
	Increment = 1,
	CurrentValue = 8,
	Callback = function(val)
		globalESPIntensity = val
	end
})

ESPTab:CreateSlider({
	Name = "Global Studs Distance",
	Range = {100,3000},
	Increment = 50,
	CurrentValue = 600,
	Callback = function(val)
		globalStudsDistance = val
	end
})

ESPTab:CreateSlider({
	Name = "Global Studs Size",
	Range = {10,100},
	Increment = 5,
	CurrentValue = 30,
	Callback = function(val)
		globalStudsSize = val
	end
})

-- =========================
-- UI SECTION 2: SPECIFIC
-- =========================

ESPTab:CreateSection("Specific Player ESP")

ESPTab:CreateDropdown({
	Name = "Select Player",
	Options = (function()
		local t = {}
		for _,p in pairs(Players:GetPlayers()) do
			if p ~= LocalPlayer then
				table.insert(t,p.Name)
			end
		end
		return t
	end)(),
	CurrentOption = nil,
	Callback = function(opt)
		specificPlayer = typeof(opt)=="table" and opt[1] or opt
	end
})

ESPTab:CreateToggle({
	Name = "Specific ESP",
	CurrentValue = false,
	Callback = function(val)
		specificESPEnabled = val
	end
})

ESPTab:CreateToggle({
	Name = "Specific Studs",
	CurrentValue = false,
	Callback = function(val)
		specificStudsEnabled = val
	end
})

ESPTab:CreateDropdown({
	Name = "Specific ESP Color",
	Options = {"White","Red","Green","Blue","Yellow","Purple","Cyan","Orange"},
	CurrentOption = "Red",
	Callback = function(opt)
		specificESPColor = colorOptions[typeof(opt)=="table" and opt[1] or opt]
	end
})

ESPTab:CreateDropdown({
	Name = "Specific Studs Color",
	Options = {"White","Red","Green","Blue","Yellow","Purple","Cyan","Orange"},
	CurrentOption = "White",
	Callback = function(opt)
		specificStudsColor = colorOptions[typeof(opt)=="table" and opt[1] or opt]
	end
})

ESPTab:CreateSlider({
	Name = "Specific ESP Distance",
	Range = {100,3000},
	Increment = 50,
	CurrentValue = 600,
	Callback = function(val)
		specificESPDistance = val
	end
})

ESPTab:CreateSlider({
	Name = "Specific ESP Intensity",
	Range = {1,10},
	Increment = 1,
	CurrentValue = 8,
	Callback = function(val)
		specificESPIntensity = val
	end
})

ESPTab:CreateSlider({
	Name = "Specific Studs Distance",
	Range = {100,3000},
	Increment = 50,
	CurrentValue = 600,
	Callback = function(val)
		specificStudsDistance = val
	end
})

ESPTab:CreateSlider({
	Name = "Specific Studs Size",
	Range = {10,100},
	Increment = 5,
	CurrentValue = 30,
	Callback = function(val)
		specificStudsSize = val
	end
})

-- =========================
-- TAB: Utility
-- =========================

local UtilityTab = Window:CreateTab("Utility", "wrench")

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

UtilityTab:CreateSection("Server Tools")

-- =========================
-- REJOIN (Same Server)
-- =========================

UtilityTab:CreateButton({
	Name = "Rejoin (Same Server)",
	Callback = function()

		local placeId = game.PlaceId
		local jobId = game.JobId

		TeleportService:TeleportToPlaceInstance(placeId, jobId, LocalPlayer)

	end
})

-- =========================
-- SERVER HOP (Random Server)
-- =========================

UtilityTab:CreateButton({
	Name = "Server Hop",
	Callback = function()

		local placeId = game.PlaceId
		local servers = {}

		local success, result = pcall(function()
			return game:HttpGet(
				"https://games.roblox.com/v1/games/" ..
				placeId ..
				"/servers/Public?sortOrder=Asc&limit=100"
			)
		end)

		if not success then
			warn("Failed to fetch servers")
			return
		end

		local data = HttpService:JSONDecode(result)

		for _,server in pairs(data.data) do
			if server.playing < server.maxPlayers and server.id ~= game.JobId then
				table.insert(servers, server.id)
			end
		end

		if #servers > 0 then
			local randomServer = servers[math.random(1, #servers)]
			TeleportService:TeleportToPlaceInstance(placeId, randomServer, LocalPlayer)
		else
			warn("No available servers found")
		end

	end
})

--============================--
-- Variables
--============================--

local ServerIDInput = ""
local serverInputBox

--============================--
-- Exit Game
--============================--

UtilityTab:CreateButton({
	Name = "Exit Game",
	Callback = function()
		LocalPlayer:Kick("Exited via Utility Panel")
	end,
})

--============================--
-- Copy Server ID
--============================--

UtilityTab:CreateButton({
	Name = "Copy Server ID",
	Callback = function()
		if setclipboard then
			setclipboard(game.JobId)
		elseif toclipboard then
			toclipboard(game.JobId)
		end

		Rayfield:Notify({
			Title = "Copied!",
			Content = "Server ID copied to clipboard.",
			Duration = 3
		})
	end,
})

--============================--
-- Server ID Input
--============================--

serverInputBox = UtilityTab:CreateInput({
	Name = "Enter Server ID",
	PlaceholderText = "Paste Server JobId here",
	RemoveTextAfterFocusLost = false,
	Callback = function(text)
		ServerIDInput = text
	end,
})

--============================--
-- Join Server
--============================--

UtilityTab:CreateButton({
	Name = "Join Server",
	Callback = function()

		if ServerIDInput == "" then
			Rayfield:Notify({
				Title = "Error",
				Content = "Please enter a Server ID first.",
				Duration = 3
			})
			return
		end

		TeleportService:TeleportToPlaceInstance(
			game.PlaceId,
			ServerIDInput,
			LocalPlayer
		)
	end,
})

--============================--
-- Reset Input (FIXED)
--============================--

UtilityTab:CreateButton({
	Name = "Reset Input",
	Callback = function()

		ServerIDInput = ""

		-- Properly clear Rayfield input
		if serverInputBox and serverInputBox.Set then
			serverInputBox:Set("")
		end

		Rayfield:Notify({
			Title = "Reset",
			Content = "Server ID input cleared.",
			Duration = 2
		})
	end,
})

--============================--
-- Copy Game ID
--============================--

UtilityTab:CreateButton({
	Name = "Copy Game ID",
	Callback = function()

		if setclipboard then
			setclipboard(tostring(game.PlaceId))
		elseif toclipboard then
			toclipboard(tostring(game.PlaceId))
		end

		Rayfield:Notify({
			Title = "Copied!",
			Content = "Game ID copied to clipboard.",
			Duration = 3
		})
	end,
})

UtilityTab:CreateSection("Cframe tools")

UtilityTab:CreateButton({
	Name = "Copy CFrame Numbers",
	Callback = function()

		local player = game:GetService("Players").LocalPlayer
		local char = player.Character
		if not char then return end
		
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		
		local cf = hrp.CFrame
		local components = {cf:GetComponents()}
		
		local numberString = table.concat(components, ", ")

		if setclipboard then
			setclipboard(numberString)
		elseif toclipboard then
			toclipboard(numberString)
		end

		Rayfield:Notify({
			Title = "Copied!",
			Content = "CFrame numbers copied.",
			Duration = 3
		})

	end
})

local customCFrameInput = ""
local cframeInputBox -- reference holder

cframeInputBox = UtilityTab:CreateInput({
	Name = "Paste CFrame Numbers",
	PlaceholderText = "x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22",
	RemoveTextAfterFocusLost = false,
	Callback = function(text)
		customCFrameInput = text
	end,
})

UtilityTab:CreateButton({
	Name = "Teleport To CFrame",
	Callback = function()

		if customCFrameInput == "" then
			Rayfield:Notify({
				Title = "Error",
				Content = "Please paste CFrame numbers first.",
				Duration = 3
			})
			return
		end

		local numbers = {}

		for num in string.gmatch(customCFrameInput, "[-%d%.eE]+") do
			table.insert(numbers, tonumber(num))
		end

		if #numbers ~= 12 then
			Rayfield:Notify({
				Title = "Invalid Input",
				Content = "CFrame needs exactly 12 numbers.",
				Duration = 4
			})
			return
		end

		local newCFrame = CFrame.new(
			numbers[1], numbers[2], numbers[3],
			numbers[4], numbers[5], numbers[6],
			numbers[7], numbers[8], numbers[9],
			numbers[10], numbers[11], numbers[12]
		)

		local player = game:GetService("Players").LocalPlayer
		local char = player.Character
		if not char then return end
		
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		
		hrp.CFrame = newCFrame

		Rayfield:Notify({
			Title = "Teleported!",
			Content = "Player CFrame updated.",
			Duration = 3
		})

	end
})

-- 🔄 RESET BUTTON
UtilityTab:CreateButton({
	Name = "Reset Input",
	Callback = function()

		customCFrameInput = ""

		-- Clear the visible text
		if cframeInputBox and cframeInputBox.Set then
			cframeInputBox:Set("")
		end
	end
})

--// Advanced Lock-On + Smart Switching + Wall Check

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--==================================================
-- SETTINGS
--==================================================

local LockOnEnabled = false
local LockOnRange = 400
local Target = nil
local ESPObjects = {}
local SavedCameraCFrame = nil

local Tab = Window:CreateTab("Aimbot", "crosshair")

Tab:CreateToggle({
	Name = "Aimbot",
	CurrentValue = false,
	Callback = function(Value)
		LockOnEnabled = Value
		
		if Value then
			SavedCameraCFrame = Camera.CFrame
		else
			Target = nil
			clearESP()
		end
	end
})

--==================================================
-- CHARACTER
--==================================================

local function getCharacter()
	return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

--==================================================
-- WALL CHECK (Proper Raycast)
--==================================================

local function isVisible(part, character)
	if not part then return false end

	local origin = Camera.CFrame.Position
	local direction = part.Position - origin

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	rayParams.FilterDescendantsInstances = {
		getCharacter(),
		character
	}

	local result = workspace:Raycast(origin, direction, rayParams)

	if result then
		return false -- wall detected
	end

	return true
end

--==================================================
-- GET NEAREST TARGET (Smart Switch)
--==================================================

local function getBestTarget()

	local myChar = getCharacter()
	local myRoot = myChar:FindFirstChild("HumanoidRootPart")
	if not myRoot then return nil end

	local closest = nil
	local closestDist = LockOnRange

	for _,player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then

			local char = player.Character
			local hum = char:FindFirstChildOfClass("Humanoid")
			local head = char:FindFirstChild("Head")
			local hrp = char:FindFirstChild("HumanoidRootPart")

			if hum and hum.Health > 0 and hrp then

				local dist = (hrp.Position - myRoot.Position).Magnitude

				if dist < closestDist then

					-- HEAD priority
					if head and isVisible(head, char) then
						closestDist = dist
						closest = char
					elseif isVisible(hrp, char) then
						closestDist = dist
						closest = char
					end
				end
			end
		end
	end

	return closest
end

--==================================================
-- ESP
--==================================================

function clearESP()
	for _, obj in pairs(ESPObjects) do
		if obj then obj:Destroy() end
	end
	table.clear(ESPObjects)
end

local function createESP(model, isTarget)

	if not model:FindFirstChild("HumanoidRootPart") then return end

	local highlight = Instance.new("Highlight")
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillTransparency = 0.15
	highlight.OutlineTransparency = 0

	if isTarget then
		highlight.FillColor = Color3.fromRGB(255,0,0)
		highlight.OutlineColor = Color3.fromRGB(255,0,0)
	else
		highlight.FillColor = Color3.fromRGB(0,170,255)
		highlight.OutlineColor = Color3.fromRGB(0,0,255)
	end

	highlight.Parent = model
	table.insert(ESPObjects, highlight)
end

local function refreshESP()

	clearESP()

	if not LockOnEnabled then return end

	for _,player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			createESP(player.Character, false)
		end
	end

	if Target then
		createESP(Target, true)
	end
end

--==================================================
-- MAIN LOOP
--==================================================

RunService.RenderStepped:Connect(function()

	if not LockOnEnabled then
		return
	end

	-- ALWAYS check nearest (Smart Switching)
	local newTarget = getBestTarget()

	-- If closer player found → switch
	if newTarget ~= Target then
		Target = newTarget
		refreshESP()
	end

	if not Target then return end

	local hum = Target:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then
		
		if SavedCameraCFrame then
			Camera.CFrame = SavedCameraCFrame
		end
		
		Target = nil
		refreshESP()
		return
	end

	local head = Target:FindFirstChild("Head")
	local hrp = Target:FindFirstChild("HumanoidRootPart")

	local aimPart = nil

	if head and isVisible(head, Target) then
		aimPart = head
	elseif hrp and isVisible(hrp, Target) then
		aimPart = hrp
	else
		Target = nil
		refreshESP()
		return
	end

	-- VERY SHARP LOCK
	local camPos = Camera.CFrame.Position
	local goal = CFrame.new(camPos, aimPart.Position)

	Camera.CFrame = Camera.CFrame:Lerp(goal, 0.9)

end)

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

--FE Fling People Script

local function Message(_Title, _Text, Time)

    game:GetService("StarterGui"):SetCore("SendNotification", {Title = _Title, Text = _Text, Duration = Time})

end

local function SkidFling(TargetName)

    local Character = Player.Character

    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

    local RootPart = Humanoid and Humanoid.RootPart

    local TCharacter = TargetName and TargetName.Character

    local THumanoid = TCharacter and TCharacter:FindFirstChildOfClass("Humanoid")

    local TRootPart = THumanoid and THumanoid.RootPart

    local THead = TCharacter and TCharacter:FindFirstChild("Head")

    local Accessory = TCharacter and TCharacter:FindFirstChildOfClass("Accessory")

    local Handle = Accessory and Accessory:FindFirstChild("Handle")

    if Character and Humanoid and RootPart then

        if RootPart.Velocity.Magnitude < 50 then

            getgenv().OldPos = RootPart.CFrame

        end

        if THumanoid and THumanoid.Sit then

            return Message("Error Occurred", "Target is sitting", 5)

        end

        if THead then

            workspace.CurrentCamera.CameraSubject = THead

        elseif Handle then

            workspace.CurrentCamera.CameraSubject = Handle

        else

            workspace.CurrentCamera.CameraSubject = THumanoid

        end

        if not TCharacter:FindFirstChildWhichIsA("BasePart") then

            return

        end

        

        local function FPos(BasePart, Pos, Ang)

            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang

            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)

            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)

            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)

        end

        

        local function SFBasePart(BasePart)

            local TimeToWait = 2

            local Time = tick()

            local Angle = 0

            repeat

                if RootPart and THumanoid then

                    if BasePart.Velocity.Magnitude < 50 then

                        Angle = Angle + 100

                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))

                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))

                        task.wait()

                        FPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))

                        task.wait()

                        FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))

                        task.wait()

                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle), 0, 0))

                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle), 0, 0))

                        task.wait()

                    else

                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))

                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))

                        task.wait()

                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))

                        task.wait()

                        

                        FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))

                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, -TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))

                        task.wait()

                        FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))

                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))

                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))

                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5 ,0), CFrame.Angles(math.rad(-90), 0, 0))

                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))

                        task.wait()

                    end

                else

                    break

                end

            until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= TargetName.Character or TargetName.Parent ~= Players or not TargetName.Character == TCharacter or THumanoid.Sit or Humanoid.Health <= 0 or tick() > Time + TimeToWait

        end

        

        workspace.FallenPartsDestroyHeight = 0/0

        

        local BV = Instance.new("BodyVelocity")

        BV.Name = "EpixVel"

        BV.Parent = RootPart

        BV.Velocity = Vector3.new(9e8, 9e8, 9e8)

        BV.MaxForce = Vector3.new(1/0, 1/0, 1/0)

        

        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

        

        if TRootPart and THead then

            if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then

                SFBasePart(THead)

            else

                SFBasePart(TRootPart)

            end

        elseif TRootPart and not THead then

            SFBasePart(TRootPart)

        elseif not TRootPart and THead then

            SFBasePart(THead)

        elseif not TRootPart and not THead and Accessory and Handle then

            SFBasePart(Handle)

        else

            return Message("Error Occurred", "Target is missing everything", 5)

        end

        

        BV:Destroy()

        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)

        workspace.CurrentCamera.CameraSubject = Humanoid

        

        repeat

            RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)

            Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))

            Humanoid:ChangeState("GettingUp")

            table.foreach(Character:GetChildren(), function(_, x)

                if x:IsA("BasePart") then

                    x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new()

                end

            end)

            task.wait()

        until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25

        workspace.FallenPartsDestroyHeight = getgenv().FPDH

    else

        return Message("Error Occurred", "Random error", 5)

    end

end

--// State
local PlayerDropdown
    local targetName = nil

--// ================= TAB =================

local FlingTab = Window:CreateTab("Fling", "rocket")

--// ================= SECTION =================

FlingTab:CreateSection("Fling others")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local enabled = false -- start OFF
local power = 1000

-- 🔘 Rayfield Toggle
FlingTab:CreateToggle({
    Name = "Touch fling",
    CurrentValue = false,
    Flag = "VelocityToggle",
    Callback = function(Value)
        enabled = Value
    end,
})

-- 💥 Your Original Logic
RunService.Heartbeat:Connect(function()
	if not enabled then return end
	
	local character = Player.Character
	if not character then return end
	
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	
	local oldVelocity = root.Velocity
	
	root.Velocity = oldVelocity * power + Vector3.new(0, power, 0)
	RunService.RenderStepped:Wait()
	root.Velocity = oldVelocity
end)

--// ================= PLAYER LIST FUNCTION =================

local function GetPlayerNames()
    local list = {}

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player then
            local display = plr.DisplayName
            local username = plr.Name
            
            table.insert(list, display .. " (" .. username .. ")")
        end
    end

    if #list == 0 then
        table.insert(list, "No players found")
    end

    return list
end


--// ================= DROPDOWN =================

PlayerDropdown = FlingTab:CreateDropdown({
    Name = "Select Player",
    Options = GetPlayerNames(),
    CurrentOption = nil,
    MultipleOptions = false,
    Callback = function(option)

    if typeof(option) == "table" then
        option = option[1]
    end

    -- Extract username from "DisplayName (Username)"
    local username = option:match("%((.-)%)")

    if username then
        local player = Players:FindFirstChild(username)

        if player then
            targetName = player

            Rayfield:Notify({
                Title = "Player Selected",
                Content = player.DisplayName .. " (" .. player.Name .. ")",
                Duration = 3
            })
        end
    end
end
})

--// Auto Refresh Dropdown
local function RefreshDropdown()
    if PlayerDropdown then
        PlayerDropdown:Refresh(GetPlayerNames(), true)
    end
end

Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    RefreshDropdown()
end)

Players.PlayerRemoving:Connect(function()
    task.wait(0.5)
   targetName = nil
    RefreshDropdown()
end)

--// ================= BUTTON =================

FlingTab:CreateButton({
    Name = "Fling Selected Player",
    Callback = function()
        if targetName then
            SkidFling(targetName)

            Rayfield:Notify({
                Title = "Action",
                Content = "Flinging "..targetName.Name,
                Duration = 3
            })
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "No player selected!",
                Duration = 3
            })
        end
    end
})

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local function SkidFling2(TargetName)

    local Character = Player.Character

    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

    local RootPart = Humanoid and Humanoid.RootPart

    local TCharacter = TargetName and TargetName.Character

    local THumanoid = TCharacter and TCharacter:FindFirstChildOfClass("Humanoid")

    local TRootPart = THumanoid and THumanoid.RootPart

    local THead = TCharacter and TCharacter:FindFirstChild("Head")

    local Accessory = TCharacter and TCharacter:FindFirstChildOfClass("Accessory")

    local Handle = Accessory and Accessory:FindFirstChild("Handle")

    if Character and Humanoid and RootPart then

        if RootPart.Velocity.Magnitude < 50 then

            getgenv().OldPos = RootPart.CFrame

        end

        if THumanoid and THumanoid.Sit then

            return Message("Error Occurred", "Target is sitting", 5)

        end

        if THead then

            workspace.CurrentCamera.CameraSubject = THead

        elseif Handle then

            workspace.CurrentCamera.CameraSubject = Handle

        else

            workspace.CurrentCamera.CameraSubject = THumanoid

        end

        if not TCharacter:FindFirstChildWhichIsA("BasePart") then

            return

        end

        

        local function FPos(BasePart, Pos, Ang)

            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang

            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)

            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)

            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)

        end

        

        local function SFBasePart(BasePart)

            local TimeToWait = 2

            local Time = tick()

            local Angle = 0

            repeat

                if RootPart and THumanoid then

                    if BasePart.Velocity.Magnitude < 50 then

                        Angle = Angle + 100

                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))

                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))

                        task.wait()

                        FPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))

                        task.wait()

                        FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))

                        task.wait()

                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle), 0, 0))

                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle), 0, 0))

                        task.wait()

                    else

                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))

                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))

                        task.wait()

                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))

                        task.wait()

                        

                        FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))

                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, -TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))

                        task.wait()

                        FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))

                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))

                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))

                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5 ,0), CFrame.Angles(math.rad(-90), 0, 0))

                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))

                        task.wait()

                    end

                else

                    break

                end

            until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= TargetName.Character or TargetName.Parent ~= Players or not TargetName.Character == TCharacter or THumanoid.Sit or Humanoid.Health <= 0 or tick() > Time + TimeToWait

        end

        

        workspace.FallenPartsDestroyHeight = 0/0

        

        local BV = Instance.new("BodyVelocity")

        BV.Name = "EpixVel"

        BV.Parent = RootPart

        BV.Velocity = Vector3.new(9e8, 9e8, 9e8)

        BV.MaxForce = Vector3.new(1/0, 1/0, 1/0)

        

        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

        

        if TRootPart and THead then

            if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then

                SFBasePart(THead)

            else

                SFBasePart(TRootPart)

            end

        elseif TRootPart and not THead then

            SFBasePart(TRootPart)

        elseif not TRootPart and THead then

            SFBasePart(THead)

        elseif not TRootPart and not THead and Accessory and Handle then

            SFBasePart(Handle)

        else

            return Message("Error Occurred", "Target is missing everything", 5)

        end

        

        BV:Destroy()

        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)

        workspace.CurrentCamera.CameraSubject = Humanoid

        

        repeat

            RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)

            Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))

            Humanoid:ChangeState("GettingUp")

            table.foreach(Character:GetChildren(), function(_, x)

                if x:IsA("BasePart") then

                    x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new()

                end

            end)

            task.wait()

        until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25

        workspace.FallenPartsDestroyHeight = getgenv().FPDH

    else

        return Message("Error Occurred", "Random error", 5)

    end

end

--// NOTIFY FUNCTION
local function Notify(title, text, time)

    local lowerTitle = string.lower(title)

    -- Default icon = X
    local icon = "x" -- Lucide icon

    if lowerTitle:find("process started") then
        icon = "play"
    end

    if lowerTitle:find("flinging") then
        icon = "rocket"
    end

    -- Success icon
    if lowerTitle:find("success") or lowerTitle:find("completed") then
        icon = "check" -- Lucide icon
    end

    Rayfield:Notify({
        Title = title,
        Content = text,
        Duration = time or 3,
        Image = icon
    })
end
 
--// VARIABLES
local isRunning = false
 
--// FLING EVERYONE BUTTON
FlingTab:CreateButton({
	Name = "Fling Everyone",
	Callback = function()
 
		if isRunning then
			Notify("Busy", "Already processing players...", 3)
			return
		end
 
		local character = Player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
 
		if not character or not root then
			Notify("Error", "Character not ready", 3)
			return
		end
 
		isRunning = true
		Notify("Process Started", "Beginning fling sequence...", 3)
 
		local savedCFrame = root.CFrame
		local playerList = {}
		local successCount = 0
		local totalTargets = 0
 
		-- Collect players except yourself
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= Player then
				table.insert(playerList, plr)
			end
		end
 
		-- Sort A-Z
		table.sort(playerList, function(a, b)
			return string.lower(a.Name) < string.lower(b.Name)
		end)
 
		totalTargets = #playerList
 
		for _, plr in ipairs(playerList) do
 
			local targetChar = plr.Character
			local humanoid = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
			local hrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
 
			if not targetChar or not humanoid then
				Notify("Failed", plr.Name .. " has no character", 3)
				continue
			end
 
			if humanoid.Health <= 0 then
				Notify("Failed", plr.Name .. " is dead", 3)
				continue
			end
 
			if not hrp then
				Notify("Failed", plr.Name .. " missing HRP", 3)
				continue
			end
 
			Notify("Flinging...", "Flinging " .. plr.Name, 2)
 
			-- YOUR SkidFling FUNCTION IS CALLED HERE
			SkidFling2(plr)
 
			task.wait(1.5)
 
			local velocity = hrp.AssemblyLinearVelocity.Magnitude
 
			if velocity > 250 then
				successCount += 1
				Notify("Success", "Successfully flung " .. plr.Name, 3)
			else
				Notify("Failed", "Failed to fling " .. plr.Name, 3)
			end
 
			task.wait(0.8)
		end
 
		-- Restore position AFTER ALL PLAYERS
		if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
			Player.Character.HumanoidRootPart.CFrame = savedCFrame
		end
 
		if successCount == totalTargets and totalTargets > 0 then
			Notify("Completed", "Successfully flung everyone!", 4)
		else
			Notify("Completed", 
				"Finished. " .. successCount .. "/" .. totalTargets .. " players flung.", 
			4)
		end
 
		isRunning = false
	end,
})
-- =========================
-- FULL SMART CLICK TO WALK
-- =========================

--// Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local PathfindingService = game:GetService("PathfindingService")
local TweenService = game:GetService("TweenService")

--// Player
local player = Players.LocalPlayer
local mouse = player:GetMouse()

--// Rayfield Tab
local ClickTab = Window:CreateTab("Click To", "hand")
ClickTab:CreateSection("Smart Movement")

--// Settings
local MAX_DISTANCE = 500
local MIN_Y_OFFSET = -50

local walkEnabled = false
local marker = nil
local cancelConnection = nil

-- =========================
-- GLOWING ESP MARKER
-- =========================

local function createMarker(position)

	if marker then
		marker:Destroy()
	end

	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Ball
	part.Size = Vector3.new(4,4,4)
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(0,170,255)
	part.Anchored = true
	part.CanCollide = false
	part.Position = position + Vector3.new(0,3,0)
	part.Parent = workspace

	local highlight = Instance.new("Highlight")
	highlight.FillColor = part.Color
	highlight.FillTransparency = 0.3
	highlight.OutlineTransparency = 1
	highlight.Parent = part

	TweenService:Create(
		part,
		TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{Size = Vector3.new(5.5,5.5,5.5)}
	):Play()

	marker = part
end

-- =========================
-- SAFE GROUND CHECK
-- =========================

local function isGroundSafe(position)

	local rayOrigin = position + Vector3.new(0,5,0)
	local rayDirection = Vector3.new(0,-25,0)

	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {player.Character}
	params.FilterType = Enum.RaycastFilterType.Blacklist

	local result = workspace:Raycast(rayOrigin, rayDirection, params)

	if not result then
		return false
	end

	-- Prevent steep slopes
	if result.Normal.Y < 0.5 then
		return false
	end

	return true
end

-- =========================
-- SMART PATH WALK
-- =========================

local function smartWalk(targetPosition)

	local char = player.Character
	if not char then return end

	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root then return end

	local distance = (root.Position - targetPosition).Magnitude
	if distance > MAX_DISTANCE then
		Rayfield:Notify({
			Title = "Safe Walk",
			Content = "Target too far.",
			Duration = 3
		})
		return
	end

	if targetPosition.Y - root.Position.Y < MIN_Y_OFFSET then
		Rayfield:Notify({
			Title = "Safe Walk",
			Content = "Target too low.",
			Duration = 3
		})
		return
	end

	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 6,
		AgentCanJump = true,
		AgentJumpHeight = 10,
		AgentMaxSlope = 45
	})

	path:ComputeAsync(root.Position, targetPosition)

	if path.Status ~= Enum.PathStatus.Success then
		
		Rayfield:Notify({
			Title = "Safe Walk",
			Content = "Unable to reach target position.",
			Duration = 3
		})

		if marker then
			marker:Destroy()
			marker = nil
		end

		return
	end

	local waypoints = path:GetWaypoints()

	for _, waypoint in ipairs(waypoints) do

		if not walkEnabled then return end

		if not isGroundSafe(waypoint.Position) then
			
			Rayfield:Notify({
				Title = "Safe Walk",
				Content = "Unsafe terrain detected.",
				Duration = 3
			})

			if marker then
				marker:Destroy()
				marker = nil
			end

			return
		end

		humanoid:MoveTo(waypoint.Position)

		if waypoint.Action == Enum.PathWaypointAction.Jump then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end

		local reached = humanoid.MoveToFinished:Wait()

		if not reached then
			
			Rayfield:Notify({
				Title = "Safe Walk",
				Content = "Movement interrupted.",
				Duration = 3
			})

			if marker then
				marker:Destroy()
				marker = nil
			end

			return
		end

		-- Anti void protection
		if root.Position.Y < -100 then
			Rayfield:Notify({
				Title = "Safe Walk",
				Content = "Void detected. Movement stopped.",
				Duration = 3
			})
			humanoid:MoveTo(root.Position)
			return
		end
	end

	if marker then
		marker:Destroy()
		marker = nil
	end
end

-- =========================
-- CLICK DETECTION
-- =========================

mouse.Button1Down:Connect(function()

	if not walkEnabled then return end

	local hit = mouse.Hit
	if not hit then return end

	local position = hit.Position

	createMarker(position)
	smartWalk(position)

	-- Cancel on manual movement
	if cancelConnection then
		cancelConnection:Disconnect()
	end

	cancelConnection = UIS.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Keyboard then
			local char = player.Character
			if char then
				local humanoid = char:FindFirstChildOfClass("Humanoid")
				if humanoid then
					humanoid:MoveTo(char.HumanoidRootPart.Position)
				end
			end
		end
	end)

end)

-- =========================
-- RAYFIELD TOGGLE
-- =========================

ClickTab:CreateToggle({
	Name = "Smart Click To Walk",
	CurrentValue = false,
	Flag = "SmartClickWalk",
	Callback = function(Value)

		walkEnabled = Value

		if not Value then
			if marker then
				marker:Destroy()
				marker = nil
			end
		end
	end,
})

--------------------------------------------------
-- RAYFIELD TOGGLE
--------------------------------------------------

ClickTab:CreateToggle({
	Name = "Enable Click To TP",
	CurrentValue = false,
	Flag = "ClickTP_MainToggle",
	Callback = function(Value)

		rayfieldToggleEnabled = Value

		if Value then

			Rayfield:Notify({
				Title = "Click To TP",
				Content = "Click To TP may not work in every game.",
				Duration = 3,
				Image = 4483362458
			})

			createFloatingButton()

		else
			if gui then
				gui:Destroy()
				gui = nil
			end
			if clickConnection then
				clickConnection:Disconnect()
				clickConnection = nil
			end
		end
	end,
})

-- =========================
-- TAB: Auto Keys
-- =========================

local KeyTab = Window:CreateTab("Auto Keys", "mouse-pointer")

local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local spamSpeed = 0.2
local activeMacro = nil

-- =========================
-- FUNCTION: PRESS KEY
-- =========================

local function pressKey(key)
	VirtualInputManager:SendKeyEvent(true, key, false, game)
	task.wait(0.05)
	VirtualInputManager:SendKeyEvent(false, key, false, game)
end

local keyList = {
	Enum.KeyCode.One,
	Enum.KeyCode.Two,
	Enum.KeyCode.Three,
	Enum.KeyCode.Four,
	Enum.KeyCode.Five,
	Enum.KeyCode.Six,
	Enum.KeyCode.Seven,
	Enum.KeyCode.Eight,
	Enum.KeyCode.Nine,
	Enum.KeyCode.Zero
}

-- =========================
-- SECTION
-- =========================

KeyTab:CreateSection("Key Spam Macros")

KeyTab:CreateSlider({
	Name = "Spam Speed",
	Range = {1, 20},
	Increment = 1,
	CurrentValue = 5,
	Callback = function(val)
		spamSpeed = val * 0.05
	end
})

-- Create 10 Macro Toggles

for i = 1,10 do
	KeyTab:CreateToggle({
		Name = "Spam 1 → " .. (i == 10 and "0" or i),
		CurrentValue = false,
		Callback = function(state)

			if state then
				activeMacro = i
				
				task.spawn(function()
					while activeMacro == i do
						for k = 1,i do
							if activeMacro ~= i then break end
							pressKey(keyList[k])
							task.wait(spamSpeed)
						end
					end
				end)
			else
				if activeMacro == i then
					activeMacro = nil
				end
			end

		end
	})
end
--// SERVICES
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local StatsService = game:GetService("Stats")
local LocalizationService = game:GetService("LocalizationService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local JoinTime = tick()

--// CACHE (FOR COPY SYSTEM)
local StatsCache = {}

--// GAME NAME
local GameName = "Unknown"
pcall(function()
	local info = MarketplaceService:GetProductInfo(game.PlaceId)
	GameName = info.Name
end)

--// REGION
local Region = "🌍 Unknown"
pcall(function()
	local code = LocalizationService:GetCountryRegionForPlayerAsync(LocalPlayer)
	local countries = {
		BD = "Bangladesh",
		US = "United States",
		IN = "India",
		GB = "United Kingdom",
		CA = "Canada",
		AU = "Australia"
	}
	Region = "🌍 " .. (countries[code] or code)
end)

--// DEVICE
local function GetDevice()
	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		return "Mobile 📱"
	elseif UserInputService.GamepadEnabled then
		return "Console 🎮"
	else
		return "PC 💻"
	end
end

local DeviceType = GetDevice()

--// EXECUTOR
local function GetExecutor()
	local name = "Undetected"
	pcall(function()
		if identifyexecutor then
			name = identifyexecutor()
		elseif getexecutorname then
			name = getexecutorname()
		end
	end)
	return name
end

local ExecutorName = GetExecutor()

--// TIME FORMAT
local function FormatTime(seconds)
	local s = math.floor(seconds % 60)
	local m = math.floor((seconds / 60) % 60)
	local h = math.floor((seconds / 3600) % 24)
	local d = math.floor(seconds / 86400)
	return string.format("%dd %02dh %02dm %02ds", d, h, m, s)
end

--// STATIC ACCOUNT CREATION DATE (FIXED)
local AccountCreationDate
do
	local accountAgeDays = LocalPlayer.AccountAge
	local currentTime = os.time()
	local creationTimestamp = currentTime - (accountAgeDays * 86400)
	AccountCreationDate = os.date("%d %B %Y", creationTimestamp)
end

--// CREATE TAB
local StatsTab = Window:CreateTab("Stats", 4483362458)

--========================
-- USER SECTION
--========================
StatsTab:CreateSection("User Information")

local UserLabel = StatsTab:CreateLabel("")
local UserIdLabel = StatsTab:CreateLabel("")
local AccountAgeLabel = StatsTab:CreateLabel("")
local JoinDateLabel = StatsTab:CreateLabel("")

--========================
-- GAME SECTION
--========================
StatsTab:CreateSection("Game Information")

local GameLabel = StatsTab:CreateLabel("")
local GameIdLabel = StatsTab:CreateLabel("")
local ServerLabel = StatsTab:CreateLabel("")
local PlayerCountLabel = StatsTab:CreateLabel("")
local ServerTimeLabel = StatsTab:CreateLabel("")
local JobIdLengthLabel = StatsTab:CreateLabel("")

--========================
-- OTHERS SECTION
--========================
StatsTab:CreateSection("Others")

local FPSLabel = StatsTab:CreateLabel("")
local PingLabel = StatsTab:CreateLabel("")
local MemoryLabel = StatsTab:CreateLabel("")
local VelocityLabel = StatsTab:CreateLabel("")
local DeviceLabel = StatsTab:CreateLabel("")
local RegionLabel = StatsTab:CreateLabel("")
local PerformanceLabel = StatsTab:CreateLabel("")
local PlaytimeLabel = StatsTab:CreateLabel("")
local GravityLabel = StatsTab:CreateLabel("")
local DateTimeLabel = StatsTab:CreateLabel("")
local ExecutorLabel = StatsTab:CreateLabel("")

--// FPS SYSTEM
local Frames = 0
local LastTime = tick()
local CurrentFPS = 0

RunService.RenderStepped:Connect(function()
	Frames += 1
	if tick() - LastTime >= 1 then
		CurrentFPS = Frames
		Frames = 0
		LastTime = tick()
	end
end)

--// PERFORMANCE
local function GetPerformance(fps, ping)
	if fps < 30 or ping > 200 then
		return "Awful 🔴"
	elseif fps < 60 or ping > 120 then
		return "Good 🟡"
	else
		return "Excellent 🟢"
	end
end

--// REFRESH FUNCTION
local function RefreshStats()

	local Ping = 0
	pcall(function()
		Ping = math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue())
	end)

	local Memory = math.floor(StatsService:GetTotalMemoryUsageMb())

	local velocity = 0
	local char = LocalPlayer.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		velocity = math.floor(char.HumanoidRootPart.Velocity.Magnitude)
	end

	-- USER
	StatsCache.User = "User: "..LocalPlayer.DisplayName.." (@"..LocalPlayer.Name..")"
	UserLabel:Set(StatsCache.User)

	StatsCache.UserId = "User ID: "..LocalPlayer.UserId
	UserIdLabel:Set(StatsCache.UserId)

	StatsCache.AccountAge = "Account Age: "..LocalPlayer.AccountAge.." days"
	AccountAgeLabel:Set(StatsCache.AccountAge)

	StatsCache.Creation = "Account Creation Date: "..AccountCreationDate
	JoinDateLabel:Set(StatsCache.Creation)

	-- GAME
	StatsCache.Game = "Game: "..GameName
	GameLabel:Set(StatsCache.Game)

	StatsCache.GameId = "Game ID: "..game.PlaceId
	GameIdLabel:Set(StatsCache.GameId)

	StatsCache.Server = "Server ID: "..game.JobId
	ServerLabel:Set(StatsCache.Server)

	StatsCache.Players = "Players: "..#Players:GetPlayers()
	PlayerCountLabel:Set(StatsCache.Players)

	StatsCache.ServerTime = "Server Time: "..math.floor(workspace.DistributedGameTime)
	ServerTimeLabel:Set(StatsCache.ServerTime)

	StatsCache.JobLength = "Job ID Length: "..string.len(game.JobId)
	JobIdLengthLabel:Set(StatsCache.JobLength)

	-- OTHERS
	StatsCache.FPS = "FPS: "..CurrentFPS
	FPSLabel:Set(StatsCache.FPS)

	StatsCache.Ping = "Ping: "..Ping.." ms"
	PingLabel:Set(StatsCache.Ping)

	StatsCache.Memory = "Memory: "..Memory.." MB"
	MemoryLabel:Set(StatsCache.Memory)

	StatsCache.Velocity = "Velocity: "..velocity
	VelocityLabel:Set(StatsCache.Velocity)

	StatsCache.Device = "Device: "..DeviceType
	DeviceLabel:Set(StatsCache.Device)

	StatsCache.Region = "Region: "..Region
	RegionLabel:Set(StatsCache.Region)

	StatsCache.Performance = "Performance: "..GetPerformance(CurrentFPS, Ping)
	PerformanceLabel:Set(StatsCache.Performance)

	StatsCache.Playtime = "Playtime: "..FormatTime(tick() - JoinTime)
	PlaytimeLabel:Set(StatsCache.Playtime)

	StatsCache.Gravity = "Gravity: "..workspace.Gravity
	GravityLabel:Set(StatsCache.Gravity)

	StatsCache.DateTime = "Date & Time: "..os.date("%d %B %Y | %H:%M:%S")
	DateTimeLabel:Set(StatsCache.DateTime)

	StatsCache.Executor = "Executor: "..ExecutorName
	ExecutorLabel:Set(StatsCache.Executor)
end

--// REFRESH BUTTON
StatsTab:CreateButton({
	Name = "Refresh",
	Callback = RefreshStats
})

--// AUTO UPDATE (1 SECOND LOOP)
task.spawn(function()
	while task.wait(1) do
		RefreshStats()
	end
end)

--// COPY ALL (FULLY FIXED)
StatsTab:CreateButton({
	Name = "Copy All",
	Callback = function()

		local text = "=== PLAYER STATS ===\n\n"

		for _, value in pairs(StatsCache) do
			text ..= value .. "\n"
		end

		if setclipboard then
			setclipboard(text)
		elseif toclipboard then
			toclipboard(text)
		elseif clipboard_set then
			clipboard_set(text)
		else
			warn("Clipboard not supported.")
		end
	end
})
