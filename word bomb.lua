--[[
    Word Bomb Helper - Final Context-Aware Edition
    - Suggestion Mode: Shows words containing the prompt when the typebox is empty.
    - Autocomplete Mode: Shows words STARTING WITH the user's text when they are typing.
    - Ignores the prompt while in Autocomplete Mode to prevent logical conflicts.
    - Bypasses anti-cheat, has a sort toggle, and auto-resizes. This is the complete package.
]]

-- Create the main GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game:GetService("CoreGui")
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Constants for resizing
local MIN_HEIGHT = 190
local MAX_HEIGHT = 600
local HEADER_HEIGHT = 140

-- Main container for the UI
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, MIN_HEIGHT)
mainFrame.Position = UDim2.new(0.05, 0, 0.5, -MIN_HEIGHT/2)
mainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui
mainFrame.ClipsDescendants = true

local cornerMain = Instance.new("UICorner") cornerMain.CornerRadius = UDim.new(0, 8) cornerMain.Parent = mainFrame
local strokeMain = Instance.new("UIStroke") strokeMain.Color = Color3.fromRGB(80, 80, 80) strokeMain.Thickness = 1.5 strokeMain.Parent = mainFrame
local paddingMain = Instance.new("UIPadding") paddingMain.PaddingTop = UDim.new(0, 10) paddingMain.PaddingBottom = UDim.new(0, 10) paddingMain.PaddingLeft = UDim.new(0, 10) paddingMain.PaddingRight = UDim.new(0, 10) paddingMain.Parent = mainFrame

-- UI Elements (Title, Close Button, etc.)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
titleBar.BackgroundTransparency = 0.4
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Word Bomb Helper"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansSemibold
titleLabel.TextSize = 18
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 24, 0, 24)
closeButton.Position = UDim2.new(1, -27, 0.5, -12)
closeButton.BackgroundColor3 = Color3.fromRGB(225, 80, 80)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 14
closeButton.Parent = titleBar
closeButton.MouseButton1Click:Connect(function() screenGui:Destroy() end)
local cornerClose = Instance.new("UICorner") cornerClose.CornerRadius = UDim.new(0, 6) cornerClose.Parent = closeButton
closeButton.MouseEnter:Connect(function() TweenService:Create(closeButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 100, 100)}):Play() end)
closeButton.MouseLeave:Connect(function() TweenService:Create(closeButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(225, 80, 80)}):Play() end)

-- Prompt display
local promptDisplay = Instance.new("TextLabel")
promptDisplay.Size = UDim2.new(1, 0, 0, 30)
promptDisplay.Position = UDim2.new(0, 0, 0, 50)
promptDisplay.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
promptDisplay.BorderSizePixel = 0
promptDisplay.Font = Enum.Font.SourceSans
promptDisplay.Text = "Loading Words..."
promptDisplay.TextColor3 = Color3.fromRGB(180, 180, 180)
promptDisplay.TextSize = 16
promptDisplay.TextXAlignment = Enum.TextXAlignment.Left
promptDisplay.Parent = mainFrame
local cornerPrompt = Instance.new("UICorner") cornerPrompt.CornerRadius = UDim.new(0, 6) cornerPrompt.Parent = promptDisplay
local paddingPrompt = Instance.new("UIPadding") paddingPrompt.PaddingLeft = UDim.new(0, 10) paddingPrompt.Parent = promptDisplay

-- Sort Button
local sortButton = Instance.new("TextButton")
sortButton.Size = UDim2.new(1, 0, 0, 25)
sortButton.Position = UDim2.new(0, 0, 0, 90)
sortButton.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
sortButton.Font = Enum.Font.SourceSansSemibold
sortButton.Text = "Sort: Shortest"
sortButton.TextColor3 = Color3.fromRGB(220, 220, 220)
sortButton.TextSize = 14
sortButton.Parent = mainFrame
local cornerSort = Instance.new("UICorner") cornerSort.CornerRadius = UDim.new(0, 6) cornerSort.Parent = sortButton

-- Scrolling frame for the word list
local wordListFrame = Instance.new("ScrollingFrame")
wordListFrame.Size = UDim2.new(1, 0, 1, -130)
wordListFrame.Position = UDim2.new(0, 0, 0, 125)
wordListFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 43)
wordListFrame.BackgroundTransparency = 0.3
wordListFrame.BorderSizePixel = 0
wordListFrame.ScrollBarImageColor3 = Color3.fromRGB(180, 180, 180)
wordListFrame.ScrollBarThickness = 6
wordListFrame.Parent = mainFrame
local cornerScroll = Instance.new("UICorner") cornerScroll.CornerRadius = UDim.new(0, 6) cornerScroll.Parent = wordListFrame
local listLayout = Instance.new("UIListLayout") listLayout.Padding = UDim.new(0, 5) listLayout.Parent = wordListFrame
local paddingScroll = Instance.new("UIPadding") paddingScroll.PaddingTop = UDim.new(0, 5) paddingScroll.PaddingLeft = UDim.new(0, 5) paddingScroll.PaddingRight = UDim.new(0, 5) paddingScroll.Parent = wordListFrame

-- --- CORE SCRIPT FUNCTIONALITY ---
local combinedWordList = {}
local isSortingShortest = true

local function shuffle(tbl) for i = #tbl, 2, -1 do local j = math.random(i); tbl[i], tbl[j] = tbl[j], tbl[i] end end

task.spawn(function()
    pcall(function() local list = loadstring(game:HttpGet("https://raw.githubusercontent.com/jjengu/scripts/refs/heads/main/wordbomb/words.lua"))() for _,w in pairs(list) do table.insert(combinedWordList, w) end end)
    pcall(function() local list = loadstring(game:HttpGet("https://raw.githubusercontent.com/jjengu/scripts/refs/heads/main/wordbomb/words_two.lua"))() for _,w in pairs(list) do table.insert(combinedWordList, w) end end)
    pcall(function() local list = loadstring(game:HttpGet("https://raw.githubusercontent.com/spamreceiver1220/my-scripts/refs/heads/main/impossible%20words.lua"))() for _,w in pairs(list) do table.insert(combinedWordList, w) end end)
    local list3 = {"pseudopseudohypoparathyroidism","floccinaucinihilipilification","antidisestablishmentarianism","supercalifragilisticexpialidocious","hexakosioihexekontahexaphobia","dichlorodiphenyltrichloroethane","sphenopalatineganglioneuralgia","radioimmunoelectrophoresis","electroencephalographically","ethylenediaminetetraacetates","xenotransplantations","unselfconsciousnesses","weatherproofnesses","zoogeographically","worthwhilenesses","overintellectualizations","untranslatabilities","phosphatidylethanolamines","unexceptionablenesses","reinstituionalizations","counterdemonstrations","characteristically","unconstitutionality","intercontinental","misinterpretations","phenomenological","oversimplification","representationalism","disenfranchisement","incompatibilities","institutionalizing","underrepresentation","thermodynamically","photosynthetically","magnetohydrodynamics","uncharacteristically","electroencephalogram","counterrevolutionary","microminiaturization","internationalization","conceptualizations","microarchitectures","counterproductive","environmentalists","differentiability","subcategorization","ultramicroscopic","disproportionately","industrialization","dematerialization","recommendations","overcompensations","misunderstanding","interrelationships","transcontinental","uncontrollability","administratively","photosensitizing","bioluminescence","counterarguments","telecommunications","immunohistochemistry","hypercholesterolemia","incomprehensibilities","multidimensionalities","semiautobiographical","uncompartmentalized","deinstitutionalization","electromagnetohydrodynamics","psychopharmacological","thyroparathyroidectomized","overcommercialization","overintellectualized","overspecialization","phytoplanktonically","photospectrophotometer","photolithographically","photolithographies","radiopharmaceutical","reconceptualization","reconceptualizations","reindustrialization","repoliticization","reproducibilities","reproportionations","resynchronization","restructurations","semiconductivities","spectroscopically","standardizations","subcompartmentalizing","substantivizations","supramolecularities","thermoregulations","transformationally","transliterations","transportationists","underprivilegedness","vulnerabilities","westernization","xenotransplantation"}
    for _,w in pairs(list3) do table.insert(combinedWordList, w) end
    shuffle(combinedWordList)
    promptDisplay.Text = "Waiting for a turn..."
end)

local function resizeUi()
    local listHeight = listLayout.AbsoluteContentSize.Y + 10
    local newHeight = math.clamp(listHeight + HEADER_HEIGHT, MIN_HEIGHT, MAX_HEIGHT)
    if mainFrame.AbsoluteSize.Y ~= newHeight then
        TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(mainFrame.Size.X.Offset, newHeight)}):Play()
    end
end

-- NEW CONTEXT-AWARE UPDATE FUNCTION
local function updateWordList(prompt, searchText)
    for _, child in ipairs(wordListFrame:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
    
    local results = {}
    local lowerSearch = searchText and searchText:lower() or ""

    if #lowerSearch > 0 then
        -- AUTOCOMPLETE MODE: If the user is typing, ignore the prompt.
        -- Find words that START WITH the user's text.
        for _, word in ipairs(combinedWordList) do
            if word:lower():find(lowerSearch, 1, true) == 1 then
                table.insert(results, word)
            end
        end
    else
        -- SUGGESTION MODE: If the user is not typing, use the prompt.
        local lowerPrompt = prompt and prompt:lower() or ""
        if #lowerPrompt > 0 then
            for _, word in ipairs(combinedWordList) do
                if word:find(lowerPrompt, 1, true) then
                    table.insert(results, word)
                end
            end
        end
    end

    -- Sort the final results based on the toggle
    if isSortingShortest then
        table.sort(results, function(a, b) return #a < #b end)
    else
        table.sort(results, function(a, b) return #a > #b end)
    end
    
    -- Display the top 100 results
    for i = 1, math.min(#results, 100) do
        local word = results[i]
        local wordFrame = Instance.new("Frame") wordFrame.Size = UDim2.new(1, 0, 0, 24) wordFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 48) wordFrame.BorderSizePixel = 0 wordFrame.Parent = wordListFrame
        local cornerWord = Instance.new("UICorner") cornerWord.CornerRadius = UDim.new(0, 4) cornerWord.Parent = wordFrame
        local wordLabel = Instance.new("TextLabel") wordLabel.Size = UDim2.new(1, -10, 1, 0) wordLabel.Position = UDim2.new(0, 5, 0, 0) wordLabel.BackgroundTransparency = 1 wordLabel.Text = word wordLabel.TextColor3 = Color3.fromRGB(235, 235, 255) wordLabel.Font = Enum.Font.SourceSans wordLabel.TextSize = 16 wordLabel.TextXAlignment = Enum.TextXAlignment.Left wordLabel.Parent = wordFrame
    end
    
    task.wait()
    resizeUi()
end

function GetCurrentPattern()
    local deScrambledPattern, cleanPattern = "", ""
    pcall(function()
        local TextFrame = PlayerGui.GameUI.Container.GameSpace.DefaultUI.GameContainer.DesktopContainer.InfoFrameContainer.InfoFrame.TextFrame
        local letters = {}
        for _, LetterFrame in ipairs(TextFrame:GetChildren()) do
            if LetterFrame:IsA("Frame") and LetterFrame:FindFirstChild("Letter") then
                table.insert(letters, {PositionX = LetterFrame.AbsolutePosition.X, Text = LetterFrame.Letter.TextLabel.Text})
            end
        end
        table.sort(letters, function(a, b) return a.PositionX < b.PositionX end)
        for _, letterData in ipairs(letters) do deScrambledPattern = deScrambledPattern .. letterData.Text end
        if #deScrambledPattern > 2 then cleanPattern = string.sub(deScrambledPattern, 3) else cleanPattern = deScrambledPattern end
    end)
    return cleanPattern
end

function GetCurrentTypebox()
    local GameUI = PlayerGui:FindFirstChild("GameUI")
    if not GameUI then return nil end
    local desktopPath = GameUI:FindFirstChild("Container.GameSpace.DefaultUI.GameContainer.DesktopContainer.Typebar.Typebox", true)
    if desktopPath and desktopPath.Visible then return desktopPath end
    local mobilePath = GameUI:FindFirstChild("Container.GameSpace.DefaultUI.GameContainer.Typebar.Typebox", true)
    if mobilePath and mobilePath.Visible then return mobilePath end
    return nil
end

local lastPrompt, lastSearchText = "", ""

sortButton.MouseButton1Click:Connect(function()
    isSortingShortest = not isSortingShortest
    sortButton.Text = isSortingShortest and "Sort: Shortest" or "Sort: Longest"
    updateWordList(lastPrompt, lastSearchText)
end)

-- MAIN LOOP TO SYNC EVERYTHING
task.spawn(function()
    local activeTypebox = nil
    local textChangedConnection = nil

    while screenGui.Parent do
        local currentPrompt = GetCurrentPattern()
        local foundTypebox = GetCurrentTypebox()
        local currentSearchText = ""

        if foundTypebox then
            currentSearchText = foundTypebox.Text
            if foundTypebox ~= activeTypebox then
                if textChangedConnection then textChangedConnection:Disconnect() end
                activeTypebox = foundTypebox
                textChangedConnection = activeTypebox:GetPropertyChangedSignal("Text"):Connect(function()
                    lastSearchText = activeTypebox.Text
                    updateWordList(lastPrompt, lastSearchText)
                end)
            end
        else
            if textChangedConnection then textChangedConnection:Disconnect() end
            activeTypebox = nil
        end

        if currentPrompt ~= lastPrompt or currentSearchText ~= lastSearchText then
            lastPrompt = currentPrompt
            lastSearchText = currentSearchText
            updateWordList(currentPrompt, currentSearchText)
        end
        
        -- Update UI Display Text
        if #currentPrompt > 0 then
            if #currentSearchText > 0 then
                promptDisplay.Text = "Completing: " .. currentSearchText:upper()
            else
                promptDisplay.Text = "Prompt: " .. currentPrompt:upper()
            end
        else
            if #combinedWordList > 0 then promptDisplay.Text = "Waiting for a turn..." end
        end
        
        task.wait(0.1)
    end
end)