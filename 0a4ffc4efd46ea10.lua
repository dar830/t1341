local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local GuiService = cloneref(game:GetService("GuiService"))
local LocalPlayer = Players.LocalPlayer

local url = "https://web-production-96fee.up.railway.app/latest"

local servers = {}
local knownJobIds = {}
local autoJoinEnabled = false
local minMS = 50
local currentSpamJobId = nil
local isSpamming = false
local guiOpen = false

local allBrainrots = {
    "Yeti Claus","Torrtugini Dragonfrutini","Tung Tung Tung Sahur","To to to Sahur","Pot Hotspot","Perrito Burrito","Noo my examine","Los Spyderinis","Los Tipi Tacos","Los Tralaleritos","Los 25","Los 67","Los Bombinitos","Las Sis","Chimnino","Swag Soda","Esok Sekolah","Los Burritos","Burrito Bandito","Mariachi Corazoni","Los Combinasionas","Chicleteira Noelteira","Los Noo My Hotspotsitos","Los Spooky Combinasionas","Mieteteira Bicicleteira","Los Mobilis","Los Candies","Spaghetti Tualetti","Swaggy Bros","Blackhole Goat","Bunnyman","Burguro And Fryuro","Capitano Moby","Chicleteira Bicicleteira","Chicleteirina Bicicleteirina","Chillin Chili","Chimpanzini Spiderini","Chipso and Queso","Cooki and Milki","Cuadramat and Pakrahmatmamat","Dragon Cannelloni","Dragon Gingerini","Elefanto Frigo","Eviledon","Festive 67","Fragola La La La","Fragrama and Chocrama","Frio Ninja","Garama and Madundung","Giftini Spyderini","Ginger Gerat","Ginger Globo","Graipuss Medussi","Gingerat Gerat","Headless Horseman","Ho Ho Ho Sahur","Horegini Boom","Ice Dragon","Jack Jack Jack","Job Job Job Sahur","Karkerkar Kurkur","Ketchuru and Musturu","Ketupat Kepat","La Casa Boo","La Cucaracha","La Extinct Grande","La Ginger Sekolah","La Grande Combinasion","La Jolly Grande","La Karkerkar Combinasion","La Sahur Combinasion","La Secret Combinasion","La Supreme Combinasion","La Taco Combinasion","La Vacca Prese Presente","La Vacca Saturno Saturnita","La Vacca Staturno Saturnita","Las Cappuchinas","Las Tralaleritas","Las Vaquitas Saturnitas","Lavadorito Spinito","Los Bros","Los Chicleteiras","Los Chihuaninis","Los Crocodillitos","Los Cucarachas","Los Gattitos","Los Hotspotsitos","Los Jobcitos","Los Krakeritos","Los Matteos","Los Nooo My Hotspotsitos","Los Orcalitos","Los Planitos","Los Puggies","Los Quesadillas","Los Spyderrinis","Money Money Puggy","Noo my Present","Nooo My Hotspot","Nuclearo Dinossauro","Please my Present","Pop pop Sahur","Pot Pumpkin","Quesadilla Crocodila","Quesadillo Vampiro","Rang Ring Bus","Reinito Sleighito","Sammyini Spyderini","Santa Hotspot","Tang Tang Kelentang","Tang Tang Keletang","Tictac Sahur","Tralaledon","Trickolino","Tuff Toucan","W or L"
}

local ignoredNames = {}

local settingsFile = "CatSettings.json"

if isfile and readfile and isfile(settingsFile) then
    pcall(function()
        local data = HttpService:JSONDecode(readfile(settingsFile))
        ignoredNames = data.ignoredNames or {}
        minMS = data.minMS or 50
    end)
end

local function saveSettings()
    if writefile then
        pcall(function()
            writefile(settingsFile, HttpService:JSONEncode({
                ignoredNames = ignoredNames,
                minMS = minMS
            }))
        end)
    end
end

local function addAnimatedStroke(frame)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 3
    stroke.Transparency = 0.4
    stroke.Color = Color3.fromRGB(255,255,255)
    stroke.Parent = frame

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
    }
    gradient.Rotation = 0
    gradient.Parent = stroke

    local anim = Instance.new("LocalScript")
    anim.Source = [[
local gradient = script.Parent
local tween = game:GetService("TweenService"):Create(gradient, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation = 360})
tween:Play()
]]
    anim.Parent = gradient
end

local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local sg = Instance.new("ScreenGui")
sg.Name = "CatVjoiner"
sg.ResetOnSpawn = false
sg.DisplayOrder = 9999
sg.Parent = LocalPlayer:WaitForChild("PlayerGui", 10)

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(0, 280, 0, 48)
topBar.Position = UDim2.new(0.5, -140, 0, 10)
topBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
topBar.Parent = sg
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)

addAnimatedStroke(topBar)

local topTitle = Instance.new("TextLabel")
topTitle.Size = UDim2.new(0.7,0,1,0)
topTitle.Position = UDim2.new(0,12,0,0)
topTitle.BackgroundTransparency = 1
topTitle.Text = "CatVjoiner"
topTitle.TextColor3 = Color3.new(1,1,1)
topTitle.Font = Enum.Font.GothamBlack
topTitle.TextSize = 18
topTitle.TextXAlignment = Enum.TextXAlignment.Left
topTitle.Parent = topBar

local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0,36,0,36)
openBtn.Position = UDim2.new(1,-48,0.5,-18)
openBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
openBtn.Text = "+"
openBtn.TextColor3 = Color3.new(1,1,1)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 24
openBtn.Parent = topBar
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0,10)

makeDraggable(topBar)

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 380, 0, 580)
main.Position = UDim2.new(0.5, -190, 0.5, -290)
main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
main.BackgroundTransparency = 0
main.Visible = false
main.Parent = sg
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 18)

addAnimatedStroke(main)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -120, 0, 60)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Cat Joiner"
title.TextColor3 = Color3.fromRGB(0, 255, 120)
title.Font = Enum.Font.GothamBlack
title.TextSize = 28
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local toggleFrame = Instance.new("Frame")
toggleFrame.Size = UDim2.new(0, 54, 0, 28)
toggleFrame.Position = UDim2.new(1, -170, 0, 15)
toggleFrame.BackgroundColor3 = Color3.fromRGB(70,70,70)
toggleFrame.Parent = main
Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(1,0)

local circle = Instance.new("Frame")
circle.Size = UDim2.new(0,24,0,24)
circle.Position = UDim2.new(0, 2, 0, 2)
circle.BackgroundColor3 = Color3.new(1,1,1)
circle.Parent = toggleFrame
Instance.new("UICorner", circle).CornerRadius = UDim.new(1,0)

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1,0,1,0)
toggleBtn.BackgroundTransparency = 1
toggleBtn.Text = ""
toggleBtn.Parent = toggleFrame

toggleBtn.MouseButton1Click:Connect(function()
    autoJoinEnabled = not autoJoinEnabled
    TweenService:Create(toggleFrame, TweenInfo.new(0.28), {BackgroundColor3 = autoJoinEnabled and Color3.fromRGB(0,190,80) or Color3.fromRGB(70,70,70)}):Play()
    TweenService:Create(circle, TweenInfo.new(0.28), {Position = UDim2.new(0, autoJoinEnabled and 28 or 2, 0, 2)}):Play()
    if autoJoinEnabled then startAutoSpam() else stopSpam() end
end)

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 50, 0, 50)
minimizeBtn.Position = UDim2.new(1, -70, 0, 5)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = Color3.new(1,1,1)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 32
minimizeBtn.Parent = main
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 12)

local settingsBtn = Instance.new("TextButton")
settingsBtn.Size = UDim2.new(0, 40, 0, 40)
settingsBtn.Position = UDim2.new(1, -110, 0, 10)
settingsBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
settingsBtn.Text = "⚙"
settingsBtn.TextColor3 = Color3.new(1,1,1)
settingsBtn.Font = Enum.Font.GothamBold
settingsBtn.TextSize = 24
settingsBtn.Parent = main
Instance.new("UICorner", settingsBtn).CornerRadius = UDim.new(0,10)

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -30, 1, -90)
scroll.Position = UDim2.new(0, 15, 0, 80)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 8
scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 120)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 14)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = scroll

local credit = Instance.new("TextLabel")
credit.Size = UDim2.new(1, -30, 0, 30)
credit.Position = UDim2.new(0, 15, 1, -40)
credit.BackgroundTransparency = 1
credit.Text = "Cat/mahoraga941 on discord"
credit.TextColor3 = Color3.fromRGB(180, 180, 180)
credit.TextTransparency = 0.55
credit.Font = Enum.Font.Gotham
credit.TextSize = 14
credit.TextXAlignment = Enum.TextXAlignment.Center
credit.Parent = main

makeDraggable(main)

-- Settings panel (parented to ScreenGui)
local settingsPanel = Instance.new("Frame")
settingsPanel.Size = UDim2.new(0, 340, 0, 580)
settingsPanel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
settingsPanel.BackgroundTransparency = 0.1
settingsPanel.Visible = false
settingsPanel.ZIndex = 12
settingsPanel.Parent = sg
Instance.new("UICorner", settingsPanel).CornerRadius = UDim.new(0, 18)

addAnimatedStroke(settingsPanel)

local setTitle = Instance.new("TextLabel")
setTitle.Size = UDim2.new(1, -20, 0, 60)
setTitle.Position = UDim2.new(0, 10, 0, 0)
setTitle.BackgroundTransparency = 1
setTitle.Text = "Settings"
setTitle.TextColor3 = Color3.new(1,1,1)
setTitle.Font = Enum.Font.GothamBlack
setTitle.TextSize = 26
setTitle.TextXAlignment = Enum.TextXAlignment.Left
setTitle.ZIndex = 15
setTitle.Parent = settingsPanel

local closeSet = Instance.new("TextButton")
closeSet.Size = UDim2.new(0, 50, 0, 50)
closeSet.Position = UDim2.new(1, -70, 0, 5)
closeSet.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
closeSet.Text = "X"
closeSet.TextColor3 = Color3.fromRGB(255, 85, 85)
closeSet.Font = Enum.Font.GothamBold
closeSet.TextSize = 28
closeSet.ZIndex = 15
closeSet.Parent = settingsPanel
Instance.new("UICorner", closeSet).CornerRadius = UDim.new(0, 12)

closeSet.MouseButton1Click:Connect(function()
    TweenService:Create(settingsPanel, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Position = UDim2.new(main.Position.X.Scale, main.Position.X.Offset + main.Size.X.Offset, main.Position.Y.Scale, main.Position.Y.Offset)}):Play()
    task.wait(0.4)
    settingsPanel.Visible = false
end)

-- Minimum $/s
local minLabel = Instance.new("TextLabel")
minLabel.Size = UDim2.new(1, -40, 0, 30)
minLabel.Position = UDim2.new(0, 20, 0, 70)
minLabel.BackgroundTransparency = 1
minLabel.Text = "Minimum $/s (e.g. 175m)"
minLabel.TextColor3 = Color3.new(1,1,1)
minLabel.Font = Enum.Font.Gotham
minLabel.TextSize = 16
minLabel.TextXAlignment = Enum.TextXAlignment.Left
minLabel.ZIndex = 15
minLabel.Parent = settingsPanel

local minBox = Instance.new("TextBox")
minBox.Size = UDim2.new(1, -40, 0, 40)
minBox.Position = UDim2.new(0, 20, 0, 100)
minBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
minBox.Text = tostring(minMS) .. "m"
minBox.PlaceholderText = "e.g. 175m"
minBox.PlaceholderColor3 = Color3.new(1,1,1)
minBox.TextColor3 = Color3.new(1,1,1)
minBox.Font = Enum.Font.Gotham
minBox.TextSize = 16
minBox.ZIndex = 15
minBox.Parent = settingsPanel
Instance.new("UICorner", minBox).CornerRadius = UDim.new(0, 10)

minBox.FocusLost:Connect(function()
    local txt = minBox.Text:lower()
    local numStr = txt:gsub("m", ""):gsub("%s+", "")
    local num = tonumber(numStr)
    if num and num > 0 then
        minMS = num
        saveSettings()
    else
        minBox.Text = tostring(minMS) .. "m"
    end
end)

-- Ignore Brainrots title
local ignoreTitle = Instance.new("TextLabel")
ignoreTitle.Size = UDim2.new(1, -40, 0, 30)
ignoreTitle.Position = UDim2.new(0, 20, 0, 150)
ignoreTitle.BackgroundTransparency = 1
ignoreTitle.Text = "Ignore Brainrots (click to toggle)"
ignoreTitle.TextColor3 = Color3.new(1,1,1)
ignoreTitle.Font = Enum.Font.Gotham
ignoreTitle.TextSize = 16
ignoreTitle.TextXAlignment = Enum.TextXAlignment.Left
ignoreTitle.ZIndex = 15
ignoreTitle.Parent = settingsPanel

-- Search box (right below the title)
local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -40, 0, 40)
searchBox.Position = UDim2.new(0, 20, 0, 185)
searchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
searchBox.PlaceholderText = "Search"
searchBox.PlaceholderColor3 = Color3.new(1,1,1)
searchBox.Text = ""
searchBox.TextColor3 = Color3.new(1,1,1)
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 16
searchBox.ClearTextOnFocus = false
searchBox.ZIndex = 15
searchBox.Parent = settingsPanel
Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 10)

-- Ignore scroll (starts below search)
local ignoreScroll = Instance.new("ScrollingFrame")
ignoreScroll.Size = UDim2.new(1, -40, 1, -270)
ignoreScroll.Position = UDim2.new(0, 20, 0, 235)
ignoreScroll.BackgroundTransparency = 1
ignoreScroll.ScrollBarThickness = 6
ignoreScroll.ScrollBarImageColor3 = Color3.fromRGB(0,255,130)
ignoreScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
ignoreScroll.ZIndex = 15
ignoreScroll.Parent = settingsPanel

local ignoreListLayout = Instance.new("UIListLayout")
ignoreListLayout.Padding = UDim.new(0, 6)
ignoreListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
ignoreListLayout.Parent = ignoreScroll

local currentSearch = ""

local function refreshIgnoreList()
    for _, child in ipairs(ignoreScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    local searchLower = currentSearch:lower()

    for _, name in ipairs(allBrainrots) do
        if searchLower == "" or name:lower():find(searchLower, 1, true) then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 36)
            btn.BackgroundColor3 = table.find(ignoredNames, name:lower()) and Color3.fromRGB(255, 140, 140) or Color3.fromRGB(35, 35, 35)
            btn.Text = name
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 15
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.ZIndex = 16
            btn.Parent = ignoreScroll
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

            btn.MouseButton1Click:Connect(function()
                local lower = name:lower()
                local idx = table.find(ignoredNames, lower)
                if idx then
                    table.remove(ignoredNames, idx)
                else
                    table.insert(ignoredNames, lower)
                end
                saveSettings()
                refreshIgnoreList()
            end)
        end
    end
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    currentSearch = searchBox.Text
    refreshIgnoreList()
end)

-- Toggle settings panel
local settingsOpen = false
settingsBtn.MouseButton1Click:Connect(function()
    if settingsOpen then
        TweenService:Create(settingsPanel, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Position = UDim2.new(main.Position.X.Scale, main.Position.X.Offset + main.Size.X.Offset, main.Position.Y.Scale, main.Position.Y.Offset)}):Play()
        task.wait(0.4)
        settingsPanel.Visible = false
        settingsOpen = false
    else
        refreshIgnoreList()
        settingsPanel.Position = UDim2.new(main.Position.X.Scale, main.Position.X.Offset + main.Size.X.Offset, main.Position.Y.Scale, main.Position.Y.Offset)
        settingsPanel.Visible = true
        TweenService:Create(settingsPanel, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(main.Position.X.Scale, main.Position.X.Offset + main.Size.X.Offset, main.Position.Y.Scale, main.Position.Y.Offset)}):Play()
        settingsOpen = true
    end
end)

-- Open / Minimize main GUI
openBtn.MouseButton1Click:Connect(function()
    guiOpen = true
    topBar.Visible = false
    task.wait(0.1)
    main.Visible = true
    task.wait(0.05)
    main.Visible = false
    task.wait(0.05)
    main.Visible = true
    sg.DisplayOrder = 10000
end)

minimizeBtn.MouseButton1Click:Connect(function()
    guiOpen = false
    main.Visible = false
    task.wait(0.1)
    topBar.Visible = true
end)

-- Server logic
local function fetchServer()
    local success, response = pcall(function()
        local req = request or http_request or (syn and syn.request) or http
        if not req then return nil end
        local res = req({Url = url, Method = "GET"})
        if res.StatusCode ~= 200 then return nil end
        return res.Body
    end)

    if not success or not response then return nil end

    local data
    success, data = pcall(function()
        return HttpService:JSONDecode(response)
    end)

    if not success or not data then return nil end

    local jobId = data.job:gsub("`", "")
    local ms = tonumber(data.ms) or 0
    local name = data.name or "Unknown"

    if not jobId or #jobId < 30 or ms < minMS then return nil end

    local lowerName = name:lower()
    for _, ignored in ipairs(ignoredNames) do
        if lowerName:find(ignored, 1, true) then
            return nil
        end
    end

    return {
        name = name,
        money = tostring(ms) .. "m/s",
        parsedMoney = ms,
        jobId = jobId
    }
end

local function findJobIdTextBox()
    local guis = {game:GetService("CoreGui"), LocalPlayer:WaitForChild("PlayerGui")}
    -- Method 1: Search for TextBox with PlaceholderText == "..."
    for _, gui in ipairs(guis) do
        for _, desc in ipairs(gui:GetDescendants()) do
            if desc:IsA("TextBox") and desc.PlaceholderText == "..." then
                print("[CatVjoiner] Found Job-ID TextBox (Method 1): " .. desc:GetFullName())
                return desc
            end
        end
    end

    -- Method 2: Search for any TextBox in ContentHolder path if it exists
    for _, gui in ipairs(guis) do
        local contentHolder = gui:FindFirstChild("Folder", true):FindFirstChild("ChilliLibUI", true):FindFirstChild("MainBase", true):FindFirstChild("Frame", true):FindFirstChild("Frame", true):FindFirstChild("ScrollingFrame", true):FindFirstChild("Frame", true):FindFirstChild("ContentHolder", true)
        if contentHolder then
            for _, desc in ipairs(contentHolder:GetDescendants()) do
                if desc:IsA("TextBox") then
                    print("[CatVjoiner] Found Job-ID TextBox (Method 2): " .. desc:GetFullName())
                    return desc
                end
            end
        end
    end

    print("[CatVjoiner] No Job-ID TextBox found")
    return nil
end

local function findJoinButton()
    local guis = {game:GetService("CoreGui"), LocalPlayer:WaitForChild("PlayerGui")}
    -- Method 1: Search for TextButton with Text == "Join Job-ID"
    for _, gui in ipairs(guis) do
        for _, desc in ipairs(gui:GetDescendants()) do
            if desc:IsA("TextButton") and desc.Text == "Join Job-ID" then
                print("[CatVjoiner] Found Join button (Method 1): " .. desc:GetFullName())
                return desc
            end
        end
    end

    -- Method 2: Search for any TextButton in ContentHolder with "Join" in text
    for _, gui in ipairs(guis) do
        local contentHolder = gui:FindFirstChild("Folder", true):FindFirstChild("ChilliLibUI", true):FindFirstChild("MainBase", true):FindFirstChild("Frame", true):FindFirstChild("Frame", true):FindFirstChild("ScrollingFrame", true):FindFirstChild("Frame", true):FindFirstChild("ContentHolder", true)
        if contentHolder then
            for _, desc in ipairs(contentHolder:GetDescendants()) do
                if desc:IsA("TextButton") and string.find(string.lower(desc.Text), "join", 1, true) then
                    print("[CatVjoiner] Found Join button (Method 2): " .. desc:GetFullName())
                    return desc
                end
            end
        end
    end

    print("[CatVjoiner] No Join button found")
    return nil
end

local function findServerToolsButton()
    local guis = {game:GetService("CoreGui"), LocalPlayer:WaitForChild("PlayerGui")}
    for _, gui in ipairs(guis) do
        for _, desc in ipairs(gui:GetDescendants()) do
            if desc:IsA("TextButton") then
                for _, child in ipairs(desc:GetChildren()) do
                    if child:IsA("TextLabel") and string.lower(child.Text) == "servertools" then
                        print("[CatVjoiner] Found ServerTools button at: " .. desc:GetFullName())
                        return desc
                    end
                end
            end
        end
    end
    return nil
end

local function ensureServerToolsOpen()
    local tb = findJobIdTextBox()
    if tb then return true end

    local stBtn = findServerToolsButton()
    if stBtn then
        pcall(function() stBtn.MouseButton1Down:Fire() end)
        task.wait(0.015)
        pcall(function() stBtn.MouseButton1Up:Fire() end)
        pcall(function() stBtn.MouseButton1Click:Fire() end)
        pcall(function() stBtn.Activated:Fire() end)
        if firesignal then
            pcall(firesignal, stBtn.MouseButton1Click)
            pcall(firesignal, stBtn.Activated)
        end
        task.wait(0.5)
    end
    return findJobIdTextBox() ~= nil
end

local function performJoin(jobId)
    ensureServerToolsOpen()
    task.wait(0.1)
    local input = findJobIdTextBox()
    if not input then return false end

    pcall(function() input:CaptureFocus() end)
    task.wait(0.04)
    input.Text = jobId
    task.wait(0.06)
    pcall(function() input:ReleaseFocus() end)
    task.wait(0.08)

    local btn = findJoinButton()
    if not btn then return false end

    pcall(function() btn.MouseButton1Down:Fire() end)
    task.wait(0.015)
    pcall(function() btn.MouseButton1Up:Fire() end)
    pcall(function() btn.MouseButton1Click:Fire() end)
    pcall(function() btn.Activated:Fire() end)

    if firesignal then
        pcall(firesignal, btn.MouseButton1Click)
        pcall(firesignal, btn.Activated)
    end

    return true
end

local function spamJoin(jobId)
    if isSpamming then return end
    isSpamming = true
    currentSpamJobId = jobId

    ensureServerToolsOpen()
    task.wait(0.1)
    local input = findJobIdTextBox()
    if not input then isSpamming = false return end

    pcall(function() input:CaptureFocus() end)
    task.wait(0.04)
    input.Text = jobId
    task.wait(0.06)
    pcall(function() input:ReleaseFocus() end)
    task.wait(0.08)

    local endTime = tick() + 10

    task.spawn(function()
        while tick() < endTime and isSpamming and currentSpamJobId == jobId do
            local btn = findJoinButton()
            if btn then
                pcall(function() btn.MouseButton1Down:Fire() end)
                task.wait(0.015)
                pcall(function() btn.MouseButton1Up:Fire() end)
                pcall(function() btn.MouseButton1Click:Fire() end)
                pcall(function() btn.Activated:Fire() end)

                if firesignal then
                    pcall(firesignal, btn.MouseButton1Click)
                    pcall(firesignal, btn.Activated)
                end
            end
            task.wait(0.025)
        end
        isSpamming = false
        currentSpamJobId = nil
    end)
end

local function startAutoSpam()
    for _, srv in ipairs(servers) do
        if srv.parsedMoney >= minMS then
            spamJoin(srv.jobId)
            break
        end
    end
end

local function stopSpam()
    isSpamming = false
    currentSpamJobId = nil
end

local function createEntry(srv)
    local entry = Instance.new("Frame")
    entry.Size = UDim2.new(1, -20, 0, 74)
    entry.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    entry.BackgroundTransparency = 0.4
    entry.ZIndex = 3
    entry.Parent = scroll
    Instance.new("UICorner", entry).CornerRadius = UDim.new(0, 14)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 6, 1, 0)
    bar.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    bar.ZIndex = 4
    bar.Parent = entry
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 14)

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -190, 0.5, 0)
    nameLbl.Position = UDim2.new(0, 18, 0, 4)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = srv.name
    nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 19
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.ZIndex = 4
    nameLbl.Parent = entry

    local moneyLbl = Instance.new("TextLabel")
    moneyLbl.Size = UDim2.new(1, -190, 0.5, 0)
    moneyLbl.Position = UDim2.new(0, 18, 0.5, -4)
    moneyLbl.BackgroundTransparency = 1
    moneyLbl.Text = "$" .. srv.money .. "/s"
    moneyLbl.Font = Enum.Font.GothamSemibold
    moneyLbl.TextSize = 18
    moneyLbl.TextXAlignment = Enum.TextXAlignment.Left
    moneyLbl.ZIndex = 4
    moneyLbl.Parent = entry

    local color = srv.parsedMoney >= 200 and Color3.fromRGB(255, 85, 85)
        or srv.parsedMoney >= 100 and Color3.fromRGB(255, 120, 120)
        or Color3.fromRGB(80, 255, 255)
    moneyLbl.TextColor3 = color

    local loopBtn = Instance.new("TextButton")
    loopBtn.Size = UDim2.new(0, 80, 0, 36)
    loopBtn.Position = UDim2.new(1, -170, 0.5, -18)
    loopBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    loopBtn.BackgroundTransparency = 0.3
    loopBtn.Text = "LOOP"
    loopBtn.TextColor3 = Color3.new(1,1,1)
    loopBtn.Font = Enum.Font.GothamBold
    loopBtn.TextSize = 14
    loopBtn.ZIndex = 5
    loopBtn.Parent = entry
    Instance.new("UICorner", loopBtn).CornerRadius = UDim.new(0, 8)
    loopBtn.MouseButton1Click:Connect(function()
        spamJoin(srv.jobId)
    end)

    local joinBtn = Instance.new("TextButton")
    joinBtn.Size = UDim2.new(0, 80, 0, 36)
    joinBtn.Position = UDim2.new(1, -90, 0.5, -18)
    joinBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    joinBtn.BackgroundTransparency = 0.2
    joinBtn.Text = "JOIN"
    joinBtn.TextColor3 = Color3.new(1,1,1)
    joinBtn.Font = Enum.Font.GothamBold
    joinBtn.TextSize = 14
    joinBtn.ZIndex = 5
    joinBtn.Parent = entry
    Instance.new("UICorner", joinBtn).CornerRadius = UDim.new(0, 8)
    joinBtn.MouseButton1Click:Connect(function()
        performJoin(srv.jobId)
    end)

    task.delay(0.3, function()
        layout:ApplyLayout()
        scroll.CanvasPosition = Vector2.new(0, scroll.AbsoluteCanvasSize.Y + 400)
        task.wait(0.2)
        scroll.CanvasPosition = Vector2.new(0, 0)
    end)

    return entry
end

local function addServer(srv)
    if not srv or knownJobIds[srv.jobId] then return end
    knownJobIds[srv.jobId] = true

    createEntry(srv)
    table.insert(servers, 1, srv)

    if autoJoinEnabled then
        startAutoSpam()
    end

    if #servers >= 10 then
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        servers = {}
        knownJobIds = {}
    end
end

spawn(function()
    while true do
        task.wait(1.2)
        local s = fetchServer()
        if s then addServer(s) end
    end
end)

task.delay(3, function()
    for _ = 1, 40 do
        local s = fetchServer()
        if s then addServer(s) end
        task.wait(0.6)
    end
end)

-- Clear GUI errors loop (added at the end)
while true do
    GuiService:ClearError()
    wait(0.01)
end
