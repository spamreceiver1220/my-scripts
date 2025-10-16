-- tried to fix this shitty script
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")


local LocalPlayer = Players.LocalPlayer
pcall(sethiddenproperty, LocalPlayer, "SimulationRadius", math.huge)
LocalPlayer.ReplicationFocus = Workspace


local Config = {
	Enabled = false,
	Radius = 50,
	Height = 100,
	RotationSpeed = 0.5,
	AttractionStrength = 1000,
	ClickSound = "rbxassetid://12221967"
}


local function playSound(soundId)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Parent = SoundService
	sound:Play()
	game.Debris:AddItem(sound, 2)
end


local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SuperRingPartsGUI"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.fromOffset(220, 190)
MainFrame.Position = UDim2.fromScale(0.5, 0.5)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 102, 51)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = MainFrame

local HeaderFrame = Instance.new("Frame")
HeaderFrame.Size = UDim2.new(1, 0, 0, 40)
HeaderFrame.BackgroundColor3 = Color3.fromRGB(0, 153, 76)
HeaderFrame.BorderSizePixel = 0
HeaderFrame.LayoutOrder = 1
HeaderFrame.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = HeaderFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Text = "Super Ring Parts"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.BackgroundTransparency = 1
Title.Parent = HeaderFrame

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.fromOffset(30, 30)
MinimizeButton.Position = UDim2.new(1, -35, 0.5, 0)
MinimizeButton.AnchorPoint = Vector2.new(0.5, 0.5)
MinimizeButton.Text = "–"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(0, 120, 60)
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.TextSize = 24
MinimizeButton.Parent = HeaderFrame

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 8)
MinimizeCorner.Parent = MinimizeButton

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.8, 0, 0, 35)
ToggleButton.Text = "Off"
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 16
ToggleButton.LayoutOrder = 2
ToggleButton.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleButton

local RadiusFrame = Instance.new("Frame")
RadiusFrame.Size = UDim2.new(0.8, 0, 0, 35)
RadiusFrame.BackgroundTransparency = 1
RadiusFrame.LayoutOrder = 3
RadiusFrame.Parent = MainFrame

local DecreaseRadius = Instance.new("TextButton")
DecreaseRadius.Size = UDim2.new(0.25, 0, 1, 0)
DecreaseRadius.Position = UDim2.fromScale(0, 0)
DecreaseRadius.Text = "<"
DecreaseRadius.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
DecreaseRadius.TextColor3 = Color3.fromRGB(0, 0, 0)
DecreaseRadius.Font = Enum.Font.SourceSansBold
DecreaseRadius.TextSize = 18
DecreaseRadius.Parent = RadiusFrame

local IncreaseRadius = Instance.new("TextButton")
IncreaseRadius.Size = UDim2.new(0.25, 0, 1, 0)
IncreaseRadius.Position = UDim2.fromScale(0.75, 0)
IncreaseRadius.Text = ">"
IncreaseRadius.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
IncreaseRadius.TextColor3 = Color3.fromRGB(0, 0, 0)
IncreaseRadius.Font = Enum.Font.SourceSansBold
IncreaseRadius.TextSize = 18
IncreaseRadius.Parent = RadiusFrame

local RadiusDisplay = Instance.new("TextLabel")
RadiusDisplay.Size = UDim2.new(0.5, -10, 1, 0)
RadiusDisplay.Position = UDim2.new(0.5, -5, 0, 0)
RadiusDisplay.AnchorPoint = Vector2.new(0.5, 0)
RadiusDisplay.Text = "Radius: 50"
RadiusDisplay.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
RadiusDisplay.TextColor3 = Color3.fromRGB(0, 0, 0)
RadiusDisplay.Font = Enum.Font.SourceSans
RadiusDisplay.TextSize = 15
RadiusDisplay.Parent = RadiusFrame

pcall(function()
	DecreaseRadius.UICorner.CornerRadius = UDim.new(0, 8)
	IncreaseRadius.UICorner.CornerRadius = UDim.new(0, 8)
	RadiusDisplay.UICorner.CornerRadius = UDim.new(0, 8)
end)

MainFrame.Parent = ScreenGui
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")


local isMinimized = false
HeaderFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local dragStart = input.Position
		local frameStartPos = MainFrame.Position
		local connection
		connection = UserInputService.InputChanged:Connect(function(changedInput)
			if changedInput.UserInputType == Enum.UserInputType.MouseMovement or changedInput.UserInputType == Enum.UserInputType.Touch then
				local delta = changedInput.Position - dragStart
				MainFrame.Position = UDim2.new(frameStartPos.X.Scale, frameStartPos.X.Offset + delta.X, frameStartPos.Y.Scale, frameStartPos.Y.Offset + delta.Y)
			end
		end)
		UserInputService.InputEnded:Connect(function(endInput)
			if endInput == input then
				connection:Disconnect()
			end
		end)
	end
end)

MinimizeButton.MouseButton1Click:Connect(function()
	playSound(Config.ClickSound)
	isMinimized = not isMinimized
	
	local contentVisibility = not isMinimized
	ToggleButton.Visible = contentVisibility
	RadiusFrame.Visible = contentVisibility
	
	if isMinimized then
		MinimizeButton.Text = "+"
		MainFrame:TweenSize(UDim2.fromOffset(220, 40), "Out", "Quad", 0.3, true)
	else
		MinimizeButton.Text = "–"
		MainFrame:TweenSize(UDim2.fromOffset(220, 190), "Out", "Quad", 0.3, true)
	end
end)


local parts = {}

local function retainPart(part)
	if part:IsA("BasePart") and not part.Anchored and not part:IsDescendantOf(LocalPlayer.Character) then
		part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
		part.CanCollide = false
		if not table.find(parts, part) then
			table.insert(parts, part)
		end
	end
end

local function releasePart(part)
	local index = table.find(parts, part)
	if index then
		table.remove(parts, index)
	end
end

for _, descendant in ipairs(Workspace:GetDescendants()) do
	task.defer(retainPart, descendant)
end

Workspace.DescendantAdded:Connect(retainPart)
Workspace.DescendantRemoving:Connect(releasePart)

RunService.Heartbeat:Connect(function()
	if not Config.Enabled then return end
	
	local playerCharacter = LocalPlayer.Character
	if not (playerCharacter and playerCharacter.PrimaryPart) then return end
	
	local tornadoCenter = playerCharacter.PrimaryPart.Position
	
	for i = #parts, 1, -1 do
		local part = parts[i]
		if not (part and part.Parent and not part.Anchored) then
			table.remove(parts, i)
		else
			local pos = part.Position
			local horizontalOffset = Vector3.new(pos.X, tornadoCenter.Y, pos.Z)
			local distance = (horizontalOffset - tornadoCenter).Magnitude
			local angle = math.atan2(pos.Z - tornadoCenter.Z, pos.X - tornadoCenter.X)
			
			local newAngle = angle + math.rad(Config.RotationSpeed)
			local targetRadius = math.min(Config.Radius, distance)
			
			local targetPos = Vector3.new(
				tornadoCenter.X + math.cos(newAngle) * targetRadius,
				tornadoCenter.Y + (Config.Height * (math.abs(math.sin((pos.Y - tornadoCenter.Y) / Config.Height)))),
				tornadoCenter.Z + math.sin(newAngle) * targetRadius
			)
			
			local directionToTarget = (targetPos - pos).Unit
			part.Velocity = directionToTarget * Config.AttractionStrength
		end
	end
end)


ToggleButton.MouseButton1Click:Connect(function()
	Config.Enabled = not Config.Enabled
	if Config.Enabled then
		ToggleButton.Text = "On"
		ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
	else
		ToggleButton.Text = "Off"
		ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	end
	playSound(Config.ClickSound)
end)

DecreaseRadius.MouseButton1Click:Connect(function()
	Config.Radius = math.max(0, Config.Radius - 5)
	RadiusDisplay.Text = "Radius: " .. Config.Radius
	playSound(Config.ClickSound)
end)

IncreaseRadius.MouseButton1Click:Connect(function()
	Config.Radius = math.min(10000, Config.Radius + 5)
	RadiusDisplay.Text = "Radius: " .. Config.Radius
	playSound(Config.ClickSound)
end)