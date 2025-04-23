repeat task.wait() until game:IsLoaded()
repeat task.wait() until game:GetService("Players").LocalPlayer

print("-- Main.lua")

local SakuraPremiumNotify = loadstring(game:HttpGet("https://pastebin.com/raw/WvMV0KS8"))()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then return end
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- สร้างระบบบันทึกการตั้งค่า
local Filename = "ZapZone_Configs/SaveSettings/" .. tostring(LocalPlayer.Name) ..".json"
local SaveSettings = {}

if not isfolder("ZapZone_Configs") then
    makefolder("ZapZone_Configs")
end
if not isfolder("ZapZone_Configs/SaveSettings") then
    makefolder("ZapZone_Configs/SaveSettings")
end

local loadconfigs = function()
    local Decode = HttpService:JSONDecode(readfile(Filename))
    return Decode
end

local saveconfig = function(SaveSettings)
    if not isfile(Filename) then
        writefile(Filename, HttpService:JSONEncode(SaveSettings))
    else
        local Decode = HttpService:JSONDecode(readfile(Filename))
        for i,v in pairs(Decode) do
            print(i)
            SaveSettings[i] = v
        end
    end
    return SaveSettings
end

-- โหลดการตั้งค่า
local toggle = {
    ['Store-Configs'] = "None" 
}

toggle = saveconfig(toggle)
print("Loaded setting:", toggle['Store-Configs'])

-- State variables
local currentSelection = toggle['Store-Configs'] or "None"
local isAnimating = false
local isHovered = false

-- // Configuration (easy to customize)
local config = {
    -- Size and positioning
    width = 240, -- เพิ่มขนาดให้ใหญ่ขึ้น
    height = 60, -- เพิ่มความสูงให้ใหญ่ขึ้น
    borderRadius = 25, -- เพิ่มความโค้งให้สอดคล้องกับขนาดที่ใหญ่ขึ้น
    padding = 6, -- เพิ่มขนาด padding เล็กน้อย
    
    -- Animation
    animDuration = 0.3,
    easeStyle = Enum.EasingStyle.Quint,
    easeDirection = Enum.EasingDirection.Out,
    
    -- Typography
    font = Enum.Font.GothamBold,
    fontSize = 18, -- เพิ่มขนาดตัวอักษรให้ใหญ่ขึ้น
    
    -- Colors
    bgColor = Color3.fromRGB(40, 40, 50),
    bgHoverColor = Color3.fromRGB(50, 50, 60),
    
    -- Indicator colors - gradient
    indicatorColor1 = Color3.fromRGB(90, 140, 240),  -- Lighter blue
    indicatorColor2 = Color3.fromRGB(60, 100, 200),  -- Darker blue
    
    -- Text colors
    activeTextColor = Color3.fromRGB(255, 255, 255),
    inactiveTextColor = Color3.fromRGB(170, 170, 190),
    
    -- Positioning (responsive) - อยู่ตรงกลางจอ
    anchorPoint = Vector2.new(0.5, 0.5),  -- Center
    position = UDim2.new(0.5, 0, 0.5, 0),  -- Center of screen
    
    -- Effects
    shadowSize = 6, -- เพิ่มขนาดเงาให้ใหญ่ขึ้น
    shadowColor = Color3.fromRGB(15, 15, 20),
    shadowTransparency = 0.7
}

-- // Create UI Elements
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ZapBubleSelector"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 10

-- Shadow for depth effect
local shadowFrame = Instance.new("Frame")
shadowFrame.Name = "Shadow"
shadowFrame.Size = UDim2.fromOffset(config.width + config.shadowSize, config.height + config.shadowSize)
shadowFrame.Position = UDim2.new(config.position.X.Scale, config.position.X.Offset + (config.shadowSize/2), 
                                config.position.Y.Scale, config.position.Y.Offset + (config.shadowSize/2))
shadowFrame.AnchorPoint = config.anchorPoint
shadowFrame.BackgroundColor3 = config.shadowColor
shadowFrame.BackgroundTransparency = config.shadowTransparency
shadowFrame.BorderSizePixel = 0
shadowFrame.Parent = screenGui

local shadowCorner = Instance.new("UICorner")
shadowCorner.CornerRadius = UDim.new(0, config.borderRadius)
shadowCorner.Parent = shadowFrame

-- Main container
local mainFrame = Instance.new("Frame")
mainFrame.Name = "SelectorFrame"
mainFrame.Size = UDim2.fromOffset(config.width, config.height)
mainFrame.Position = config.position
mainFrame.AnchorPoint = config.anchorPoint
mainFrame.BackgroundColor3 = config.bgColor
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, config.borderRadius)
mainCorner.Parent = mainFrame

-- Indicator (sliding element)
local indicator = Instance.new("Frame")
indicator.Name = "Indicator"
indicator.BorderSizePixel = 0
indicator.ZIndex = 2
indicator.Parent = mainFrame

-- Gradient for indicator
local indicatorGradient = Instance.new("UIGradient")
indicatorGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, config.indicatorColor1),
    ColorSequenceKeypoint.new(1, config.indicatorColor2)
})
indicatorGradient.Rotation = 45  -- Diagonal gradient
indicatorGradient.Parent = indicator

local indicatorCorner = Instance.new("UICorner")
indicatorCorner.CornerRadius = UDim.new(0, config.borderRadius - config.padding)
indicatorCorner.Parent = indicator

-- Option labels (now three options)
local noneLabel = Instance.new("TextLabel")
noneLabel.Name = "NoneLabel"
noneLabel.Size = UDim2.new(1/3, 0, 1, 0)
noneLabel.Position = UDim2.fromScale(0, 0)
noneLabel.BackgroundTransparency = 1
noneLabel.Font = config.font
noneLabel.Text = "None"
noneLabel.TextColor3 = currentSelection == "None" and config.activeTextColor or config.inactiveTextColor
noneLabel.TextSize = config.fontSize
noneLabel.TextXAlignment = Enum.TextXAlignment.Center
noneLabel.ZIndex = 3
noneLabel.Parent = mainFrame

local zapZoneLabel = Instance.new("TextLabel")
zapZoneLabel.Name = "ZapZoneLabel"
zapZoneLabel.Size = UDim2.new(1/3, 0, 1, 0)
zapZoneLabel.Position = UDim2.fromScale(1/3, 0)
zapZoneLabel.BackgroundTransparency = 1
zapZoneLabel.Font = config.font
zapZoneLabel.Text = "ZapZone"
zapZoneLabel.TextColor3 = currentSelection == "ZapZone" and config.activeTextColor or config.inactiveTextColor
zapZoneLabel.TextSize = config.fontSize
zapZoneLabel.TextXAlignment = Enum.TextXAlignment.Center
zapZoneLabel.ZIndex = 3
zapZoneLabel.Parent = mainFrame

local bubleLabel = Instance.new("TextLabel")
bubleLabel.Name = "BubleLabel"
bubleLabel.Size = UDim2.new(1/3, 0, 1, 0)
bubleLabel.Position = UDim2.fromScale(2/3, 0)
bubleLabel.BackgroundTransparency = 1
bubleLabel.Font = config.font
bubleLabel.Text = "Buble"
bubleLabel.TextColor3 = currentSelection == "Buble" and config.activeTextColor or config.inactiveTextColor
bubleLabel.TextSize = config.fontSize
bubleLabel.TextXAlignment = Enum.TextXAlignment.Center
bubleLabel.ZIndex = 3
bubleLabel.Parent = mainFrame

-- Glow effect for active state
local glowEffect = Instance.new("ImageLabel")
glowEffect.Name = "GlowEffect"
glowEffect.Size = UDim2.new(1.5, 0, 1.5, 0)
glowEffect.Position = UDim2.fromScale(0.5, 0.5)
glowEffect.AnchorPoint = Vector2.new(0.5, 0.5)
glowEffect.BackgroundTransparency = 1
glowEffect.Image = "rbxassetid://131531064" -- Circular glow image
glowEffect.ImageColor3 = config.indicatorColor1
glowEffect.ImageTransparency = 0.8
glowEffect.ZIndex = 1
glowEffect.Parent = indicator

-- Clickable area
local clickArea = Instance.new("TextButton")
clickArea.Name = "ClickArea"
clickArea.Size = UDim2.fromScale(1, 1)
clickArea.Position = UDim2.fromScale(0, 0)
clickArea.BackgroundTransparency = 1
clickArea.Text = ""
clickArea.AutoButtonColor = false
clickArea.ZIndex = 5
clickArea.Parent = mainFrame

-- // Logic
local indicatorWidth = (config.width / 3) - (config.padding * 2)
local indicatorHeight = config.height - (config.padding * 2)
indicator.Size = UDim2.fromOffset(indicatorWidth, indicatorHeight)

local nonePosition = UDim2.fromOffset(config.padding, config.padding)
local zapZonePosition = UDim2.fromOffset(config.width/3 + config.padding, config.padding)
local bublePosition = UDim2.fromOffset(2 * config.width/3 + config.padding, config.padding)

-- Update visuals based on selection
local function updateToggleVisuals(isInitial)
    if not indicator or not indicator.Parent then return end
    
    isAnimating = true
    local targetPosition
    local activeLabel
    
    -- Reset all labels to inactive
    noneLabel.TextColor3 = config.inactiveTextColor
    zapZoneLabel.TextColor3 = config.inactiveTextColor
    bubleLabel.TextColor3 = config.inactiveTextColor
    
    -- Set the active label and position
    if currentSelection == "None" then
        targetPosition = nonePosition
        activeLabel = noneLabel
    elseif currentSelection == "ZapZone" then
        targetPosition = zapZonePosition
        activeLabel = zapZoneLabel
    else -- "Buble"
        targetPosition = bublePosition
        activeLabel = bubleLabel
    end
    
    -- Text color animation
    local textTween = TweenInfo.new(config.animDuration / 2)
    TweenService:Create(activeLabel, textTween, {TextColor3 = config.activeTextColor}):Play()
    
    -- Indicator position animation
    local posTween = TweenInfo.new(
        isInitial and 0 or config.animDuration,
        config.easeStyle,
        config.easeDirection
    )
    
    local tween = TweenService:Create(indicator, posTween, {Position = targetPosition})
    
    -- Glow effect
    local glowTween = TweenService:Create(glowEffect, TweenInfo.new(config.animDuration * 1.5), 
        {ImageTransparency = 0.7, Size = UDim2.new(1.5, 0, 1.5, 0)})
    glowEffect.Size = UDim2.new(1.2, 0, 1.2, 0)
    glowEffect.ImageTransparency = 0.4
    glowTween:Play()
    
    tween.Completed:Connect(function()
        isAnimating = false
    end)
    
    tween:Play()
end

-- Initial setup
task.wait() -- Wait for the next frame
if not indicator or not indicator.Parent then return end
updateToggleVisuals(true)

-- Click handler
clickArea.MouseButton1Click:Connect(function()
    if isAnimating then return end
    
    -- Play click sound effect
    local clickSound = Instance.new("Sound")
    clickSound.SoundId = "rbxassetid://6895079853" -- Soft click sound
    clickSound.Volume = 0.5
    clickSound.Parent = mainFrame
    clickSound:Play()
    
    game.Debris:AddItem(clickSound, 1)
    
    -- Rotate through the three options
    if currentSelection == "None" then
        currentSelection = "ZapZone"
    elseif currentSelection == "ZapZone" then
        currentSelection = "Buble"
    else
        currentSelection = "None"
    end
    
    updateToggleVisuals(false)
    
    -- Add subtle bounce effect
    local originalSize = mainFrame.Size
    local growTween = TweenService:Create(mainFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
        {Size = UDim2.new(0, originalSize.X.Offset * 1.05, 0, originalSize.Y.Offset * 1.05)})
    local shrinkTween = TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), 
        {Size = originalSize})
    
    growTween:Play()
    growTween.Completed:Connect(function()
        shrinkTween:Play()
    end)
    
    -- บันทึกค่าที่เลือก
    SaveSettings['Store-Configs'] = currentSelection

    writefile(Filename, HttpService:JSONEncode(SaveSettings))
    
    print("Selection changed to:", currentSelection)
    print("Saved setting:", SaveSettings['Store-Configs'])
end)

-- Hover effects
clickArea.MouseEnter:Connect(function()
    isHovered = true
    -- Background color change
    TweenService:Create(mainFrame, TweenInfo.new(0.2), {BackgroundColor3 = config.bgHoverColor}):Play()
    
    -- Subtle scale effect
    TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), 
        {Size = UDim2.new(0, config.width * 1.02, 0, config.height * 1.02)}):Play()
end)

clickArea.MouseLeave:Connect(function()
    isHovered = false
    -- Revert color change
    TweenService:Create(mainFrame, TweenInfo.new(0.2), {BackgroundColor3 = config.bgColor}):Play()
    
    -- Revert scale effect
    TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), 
        {Size = UDim2.new(0, config.width, 0, config.height)}):Play()
end)

local function pulseEffect()
    while task.wait(3) do 
        if not isHovered and not isAnimating then
            local originalTransparency = glowEffect.ImageTransparency
            local pulseTween = TweenService:Create(glowEffect, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), 
                {ImageTransparency = 0.6})
            local revertTween = TweenService:Create(glowEffect, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), 
                {ImageTransparency = originalTransparency})
            
            pulseTween:Play()
            task.wait(1.5)
            revertTween:Play()
        end
    end
end

task.spawn(pulseEffect)

screenGui.Parent = game.CoreGui

print("ZapZone UI Loaded")

task.wait(5)

if loadconfigs()['Store-Configs'] == 'ZapZone' or loadconfigs()['Store-Configs'] == 'Buble' then
    print("Passed Load!")
else
    repeat task.wait(5) until loadconfigs()['Store-Configs'] ~= "None"
end

if loadconfigs()['Store-Configs'] == "ZapZone" then
    _G.avatarName = "ZapZone - AFK [Test]"
    _G.colorEmbed = 16755219
    _G.webhookUrl = 'https://discord.com/api/webhooks/1364217417454063658/kuIJXo7PNFkKBbGUoL2LpzRFvfcf5ypFutpyr-7rghjrbBHYHMRVrgJdyUAw-AdcY-EJ'
    _G.banerUrl = 'https://media.discordapp.net/attachments/1142448438529765389/1355464540376141914/face.png'
    _G.avatarUrl = 'https://media.discordapp.net/attachments/1142448438529765389/1355464540002975774/ZAPPPP.png'
elseif loadconfigs()['Store-Configs'] == "Buble" then
    _G.avatarName = "Buble - AFK [Test]"
    _G.colorEmbed = 13133055
    _G.webhookUrl = 'https://discord.com/api/webhooks/1364217417454063658/kuIJXo7PNFkKBbGUoL2LpzRFvfcf5ypFutpyr-7rghjrbBHYHMRVrgJdyUAw-AdcY-EJ'
    _G.banerUrl = 'https://images-ext-1.discordapp.net/external/eSd5CCWnNTdF05iDMSqm_9cqWVKVxW6xjF7P6FNFaiM/https/m.openlink.co/images/bubbleshop/cover_1733316312.png'
    _G.avatarUrl = 'https://media.discordapp.net/attachments/1142448438529765389/1356275092404830299/newlogo.png'
end
local x, p = pcall(function()loadstring(game:HttpGet("https://raw.githubusercontent.com/monqil/ZapZoneXMasterp/main/Library/" .. game.PlaceId .. ".lua"))()end)

if not x then
    warn('error: '.. tostring(p))
end
game:GetService("StarterGui"):SetCore("SendNotification",{
    Title = "Success Continue", -- Required
    Text = "", -- Required
})
