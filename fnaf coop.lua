--// Services & Rayfield Library
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

--// Player Variables
local localPlayer = Players.LocalPlayer

--// --- Configuration Table ---
local Config = {
    espEnabled = false,
    nametagsEnabled = false,
    distanceEnabled = true,
    highlightColor = Color3.fromRGB(255, 40, 40),
    nametagColor = Color3.fromRGB(255, 255, 255),
    textSize = 18,
}

-- Table to keep track of all active NPCs and their visual components
local trackedNPCs = {}
-- A table to keep track of our connections so we can disconnect them later
local connections = {}

--// --- Rayfield UI Setup (Unchanged) ---
local Window = Rayfield:CreateWindow({
    Name = "Universal Animatronic ESP",
    LoadingTitle = "Loading Interface...",
    ConfigurationSaving = { Enabled = true, FolderName = "ESPConfig", FileName = "Universal_Animatronic_ESP_V2" }
})
local MainTab = Window:CreateTab("Visuals", "eye")
MainTab:CreateSection("Main Features")
MainTab:CreateToggle({Name = "Enable ESP Highlight", CurrentValue = Config.espEnabled, Flag = "espEnabled", Callback = function(val) Config.espEnabled = val end})
MainTab:CreateToggle({Name = "Enable Nametags", CurrentValue = Config.nametagsEnabled, Flag = "nametagsEnabled", Callback = function(val) Config.nametagsEnabled = val end})
MainTab:CreateSection("Nametag Settings")
MainTab:CreateToggle({Name = "Show Distance", CurrentValue = Config.distanceEnabled, Flag = "distanceEnabled", Callback = function(val) Config.distanceEnabled = val end})
MainTab:CreateSlider({Name = "Text Size", Range = {14, 30}, Increment = 1, CurrentValue = Config.textSize, Flag = "textSize", Callback = function(val) Config.textSize = math.floor(val) end})
MainTab:CreateSection("Color Customization")
MainTab:CreateColorPicker({Name = "Highlight Color", Color = Config.highlightColor, Flag = "highlightColor", Callback = function(val) Config.highlightColor = val end})
MainTab:CreateColorPicker({Name = "Nametag Color", Color = Config.nametagColor, Flag = "nametagColor", Callback = function(val) Config.nametagColor = val end})


--// --- Core ESP Logic (Unchanged) ---

local function cleanup(model)
    if not trackedNPCs[model] then return end
    if trackedNPCs[model].highlight then trackedNPCs[model].highlight:Destroy() end
    if trackedNPCs[model].billboardGui then trackedNPCs[model].billboardGui:Destroy() end
    trackedNPCs[model] = nil
end

local function processModel(model)
    if not model:IsA("Model") or trackedNPCs[model] then return end
    local hasHumanoid = model:FindFirstChildOfClass("Humanoid")
    local isFreddle = string.find(model.Name:lower(), "freddle")
    if not (hasHumanoid or isFreddle) then return end
    if not model.PrimaryPart then model.PrimaryPart = model:FindFirstChildWhichIsA("BasePart") end
    if not model.PrimaryPart then return end
    local highlight = Instance.new("Highlight")
    highlight.Adornee = model
    highlight.Parent = model
    highlight.FillTransparency = 0.5
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Adornee = model.PrimaryPart
    billboardGui.AlwaysOnTop = true
    billboardGui.Size = UDim2.new(0, 175, 0, 50)
    local _, modelSize = model:GetBoundingBox()
    local verticalOffset = (modelSize.Y / 2) + 2
    billboardGui.StudsOffset = Vector3.new(0, verticalOffset, 0)
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextStrokeTransparency = 0 
    nameLabel.Parent = billboardGui
    billboardGui.Parent = model.PrimaryPart
    trackedNPCs[model] = {primaryPart = model.PrimaryPart, highlight = highlight, billboardGui = billboardGui, nameLabel = nameLabel}
    model.Destroying:Connect(function() cleanup(model) end)
end

RunService.RenderStepped:Connect(function()
    local playerCharacter = localPlayer.Character
    if not playerCharacter then return end
    local playerRoot = playerCharacter:FindFirstChild("HumanoidRootPart")
    if not playerRoot then return end
    for model, data in pairs(trackedNPCs) do
        if not model.Parent or not data.primaryPart.Parent then
            cleanup(model)
            continue
        end
        data.highlight.Enabled = Config.espEnabled
        data.billboardGui.Enabled = Config.nametagsEnabled
        if Config.espEnabled then
            data.highlight.FillColor = Config.highlightColor
        end
        if Config.nametagsEnabled then
            data.nameLabel.TextColor3 = Config.nametagColor
            data.nameLabel.TextSize = Config.textSize
            local text = model.Name
            if Config.distanceEnabled then
                local distance = (playerRoot.Position - data.primaryPart.Position).Magnitude
                text = string.format("%s\n[%dm]", text, math.floor(distance))
            end
            data.nameLabel.Text = text
        end
    end
end)


--// --- Universal Name-Based NPC Detector ---

-- THE ONLY CHANGE: This list is now the ultimate master list.
local animatronicNames = {
    -- FNAF 1 & 4 Core
    "bonnie", "chica", "foxy", "freddy", "fredbear", "nightmare",
    "plushtrap", "freddle", "blackout",
    
    -- FNAF 2 Additions
    "mangle", "puppet", "balloon", "toy", "shadow", "golden", "paper",

    -- FNAF 3 Additions
    "springtrap", "phantom",

    -- Sister Location Additions
    "baby", "ballora", "funtime", "ennard", "bidybab", "minireena", "lolbit"
}

local function isAnimatronic(name)
    local lowerName = name:lower()
    for _, animatronicName in ipairs(animatronicNames) do
        if string.find(lowerName, animatronicName) then return true end
    end
    return false
end

local function setupListenersRecursive(parent)
    table.insert(connections, parent.ChildAdded:Connect(function(child)
        if child:IsA("Model") and isAnimatronic(child.Name) then
            processModel(child)
        end
        setupListenersRecursive(child)
    end))
    for _, child in ipairs(parent:GetChildren()) do
        if child:IsA("Model") and isAnimatronic(child.Name) then
            processModel(child)
        end
        setupListenersRecursive(child)
    end
end

-- This is the new master function that runs on every spawn.
local function Initialize()
    for model, _ in pairs(trackedNPCs) do
        cleanup(model)
    end
    for _, connection in ipairs(connections) do
        connection:Disconnect()
    end
    connections = {}
    print("ESP System: Player has spawned. Re-initializing listeners for new environment...")
    setupListenersRecursive(workspace)
end

Initialize()

localPlayer.CharacterAdded:Connect(function(character)
    task.wait(1)
    Initialize()
end)

print("ESP System: Universal, persistent script is now active.")