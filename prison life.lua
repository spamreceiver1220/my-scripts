--// Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

--// MacLib UI Library
local MacLib = loadstring(game:HttpGet("https://github.com/biggaboy212/Maclib/releases/latest/download/maclib.txt"))()

--// Player Variables
local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

--// --- Configuration Table ---
local Config = {
    clickTpEnabled = false,
    espEnabled = false,
    hitboxEnabled = false,
    hitboxSize = 5
}

--// --- STATE-DRIVEN ENGINE DATA ---
local playerData = {}

--// --- MacLib UI Setup ---
local Window = MacLib:Window({
    Title = "Prison Life Utility",
    Subtitle = "Final Edition",
    Size = UDim2.fromOffset(868, 650),
    DragStyle = 2, -- CHANGED: Use the entire UI to drag
    Keybind = Enum.KeyCode.RightControl,
    AcrylicBlur = true -- ADDED: Enables the clean transparency effect
})

local MainTabGroup = Window:TabGroup()
local CombatTab = MainTabGroup:Tab({ Name = "Combat" })
local VisualsTab = MainTabGroup:Tab({ Name = "Visuals" })
local MovementTab = MainTabGroup:Tab({ Name = "Movement" })
local TeleportsTab = MainTabGroup:Tab({ Name = "Teleports" })
local TrackerTab = MainTabGroup:Tab({ Name = "Tracker" })

--// -- Combat Tab --
local Combat_Left = CombatTab:Section({ Side = "Left" })
Combat_Left:Header({ Text = "Hitbox Expander" })
Combat_Left:Toggle({
    Name = "Enable Hitbox Expander",
    Default = Config.hitboxEnabled,
    Callback = function(value) Config.hitboxEnabled = value end
}, "hitboxEnabled")
Combat_Left:Slider({
    Name = "Hitbox Size",
    Default = Config.hitboxSize,
    Minimum = 4,
    Maximum = 25,
    DisplayMethod = "Round", -- FIXED: Display a clean, whole number
    Callback = function(value)
        Config.hitboxSize = math.floor(value) -- FIXED: Store a clean, whole number
    end
}, "hitboxSize")

--// -- Visuals Tab --
local Visuals_Left = VisualsTab:Section({ Side = "Left" })
Visuals_Left:Header({ Text = "Player ESP" })
Visuals_Left:Toggle({
    Name = "Enable ESP",
    Default = Config.espEnabled,
    Callback = function(value) Config.espEnabled = value end
}, "espEnabled")

--// -- Movement Tab --
local Movement_Left = MovementTab:Section({ Side = "Left" })
Movement_Left:Header({ Text = "Teleportation" })
Movement_Left:Toggle({
    Name = "Enable Click TP (Hold LCtrl)",
    Default = Config.clickTpEnabled,
    Callback = function(value) Config.clickTpEnabled = value end
}, "clickTpEnabled")

--// -- Teleports Tab --
local Teleports_Left = TeleportsTab:Section({ Side = "Left" })
Teleports_Left:Header({ Text = "Prison Locations" })


--// --- FEATURE LOGIC (Functions defined first for reliability) ---

local function teleportTo(positionVector)
    local character = localPlayer.Character; local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if rootPart then rootPart.CFrame = CFrame.new(positionVector) else Window:Notify({Title = "Teleport Failed", Description = "Your character could not be found."}) end
end

local function clicktpFunc()
    local character = localPlayer.Character; if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid"); local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not (humanoid and rootPart) then return end
    if humanoid.SeatPart then humanoid.Sit = false; task.wait(0.1) end
    local hipHeight = humanoid.HipHeight > 0 and (humanoid.HipHeight + 1) or 4
    rootPart.CFrame = CFrame.new(mouse.Hit.Position) + Vector3.new(0, hipHeight, 0)
end

--// -- Teleport Buttons --
local locations = {
    { Name = "Armory", Coords = Vector3.new(792.46, 100.98, 2238.39) },
    { Name = "Criminal Base", Coords = Vector3.new(-950.14, 103.53, 2033.44) },
    { Name = "Car", Coords = Vector3.new(-526.35, 54.78, 1774.25) },
    { Name = "Gate", Coords = Vector3.new(504.21, 102.04, 2253.28) },
    { Name = "Entrance", Coords = Vector3.new(702.76, 100.00, 2242.57) },
    { Name = "Sewer Exit", Coords = Vector3.new(917.17, 78.70, 2110.31) },
    { Name = "South Tower", Coords = Vector3.new(1056.00, 130.04, 2588.48) },
    { Name = "North Tower", Coords = Vector3.new(493.93, 130.04, 2591.09) },
    { Name = "Main Tower", Coords = Vector3.new(810.20, 125.04, 2591.51) },
    { Name = "Roof", Coords = Vector3.new(921.63, 131.99, 2233.51) },
    { Name = "Nexus", Coords = Vector3.new(887.87, 100.00, 2387.27) }
}
for _, loc in ipairs(locations) do
    Teleports_Left:Button({ Name = loc.Name, Callback = function() teleportTo(loc.Coords) end })
end

--// -- Position Tracker Tab --
local Tracker_Left = TrackerTab:Section({ Side = "Left" })
Tracker_Left:Header({ Text = "Live Position" })
local CoordsLabel = Tracker_Left:Label({ Text = "Waiting for character..." })
Tracker_Left:Button({ Name = "Copy Coordinates", Callback = function()
    local localRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if setclipboard and localRoot then
        local pos = localRoot.Position; local formattedCoords = string.format("Vector3.new(%.2f, %.2f, %.2f)", pos.X, pos.Y, pos.Z)
        setclipboard(formattedCoords); Window:Notify({Title = "Coordinates Copied!", Description = formattedCoords, Lifetime = 5})
    end
end})

--// -- Connect Click TP Event --
mouse.Button1Down:Connect(function()
    if Config.clickTpEnabled and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then clicktpFunc() end
end)


--// --- Core Logic ---
local function cleanupPlayerData(player)
    if not playerData[player] then return end
    local data = playerData[player]
    if data.espFolder then data.espFolder:Destroy() end
    if data.hrp and data.originalHRPSize then data.hrp.Size = data.originalHRPSize end
    playerData[player] = nil
end
Players.PlayerRemoving:Connect(cleanupPlayerData)

RunService.RenderStepped:Connect(function()
    local localCharacter = localPlayer.Character
    local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    if localRoot then
        local pos = localRoot.Position; CoordsLabel:UpdateName(string.format("X: %.2f | Y: %.2f | Z: %.2f", pos.X, pos.Y, pos.Z))
    else
        CoordsLabel:UpdateName("Character not found."); return
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player == localPlayer then continue end
        local character = player.Character; local data = playerData[player]
        if (not character and data) or (character and data and data.character ~= character) then cleanupPlayerData(player) end
        if not character then continue end
        if not playerData[player] then
            local hrp = character:FindFirstChild("HumanoidRootPart"); local humanoid = character:FindFirstChildOfClass("Humanoid")
            if hrp and humanoid then playerData[player] = {character = character, hrp = hrp, humanoid = humanoid, originalHRPSize = hrp.Size} end
        end
        data = playerData[player]
        if not data or not data.humanoid then continue end
        local isSeated = data.humanoid.Sit == true
        if Config.hitboxEnabled and not isSeated then data.hrp.Size = Vector3.new(Config.hitboxSize, Config.hitboxSize, Config.hitboxSize) else data.hrp.Size = data.originalHRPSize end
        if Config.espEnabled then
            local espFolder = data.espFolder
            if not espFolder or not espFolder.Parent then
                espFolder = Instance.new("Folder", CoreGui); espFolder.Name = player.Name .. "_ESP"; data.espFolder = espFolder
                for _, part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") then local box = Instance.new("BoxHandleAdornment", espFolder); box.Name = part.Name; box.Adornee = part; box.AlwaysOnTop = true; box.ZIndex = 10; box.Transparency = 0.6 end
                end
                local head = character:FindFirstChild("Head")
                if head then
                    local billboard = Instance.new("BillboardGui", espFolder); billboard.Name = "Nametag"; billboard.Adornee = head; billboard.Size = UDim2.new(0, 100, 0, 50); billboard.StudsOffset = Vector3.new(0, 2.5, 0); billboard.AlwaysOnTop = true
                    local textLabel = Instance.new("TextLabel", billboard); textLabel.BackgroundTransparency = 1; textLabel.Size = UDim2.new(1, 0, 1, 0); textLabel.Font = Enum.Font.SourceSansSemibold; textLabel.TextSize = 18; textLabel.TextColor3 = Color3.new(1, 1, 1); textLabel.TextStrokeTransparency = 0; data.espTextLabel = textLabel
                end
            end
            local teamColor = (player.Team and player.Team.TeamColor.Color) or Color3.new(1, 1, 1)
            for _, adornment in ipairs(espFolder:GetChildren()) do
                if adornment:IsA("BoxHandleAdornment") then adornment.Color = BrickColor.new(teamColor); adornment.Size = adornment.Adornee.Size end
            end
            if data.espTextLabel then
                local dist = (localRoot.Position - data.hrp.Position).Magnitude
                data.espTextLabel.Text = string.format("%s\nHP: %d | Dist: %d", player.Name, math.floor(data.humanoid.Health), math.floor(dist))
            end
        elseif data and data.espFolder then cleanupPlayerData(player) end
    end
end)

print("Prison Life Utility (MacLib Edition) Loaded.")