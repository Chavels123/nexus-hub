
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local LuarmorAPI = loadstring(game:HttpGet("https://sdkapi-public.luarmor.net/library.lua"))()

local Config = {
    KeySystemVersion = "V1.0",
    HubName = "Nexus Hub",
    DiscordInvite = "Not availble yet",
    GetKeyURL = "https://ads.luarmor.net/get_key?for=Nexus_Hub-vrIKoBUaLTsp",
    
    Colors = {
        Background = Color3.fromRGB(20, 20, 25),
        Secondary = Color3.fromRGB(30, 30, 35),
        Accent = Color3.fromRGB(255, 170, 50),
        Success = Color3.fromRGB(70, 200, 100),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(150, 150, 160),
        Border = Color3.fromRGB(50, 50, 60),
    },
    
    SupportedGames = {
        [18199615050] = {Name = "Demonology (Lobby)", Icon = "rbxassetid://6137321701", ScriptId = "c1b36fb2505c5cfb10cd11a28c9355c0"},
        [18794863104] = {Name = "Demonology (Game)", Icon = "rbxassetid://18199615050", ScriptId = "c1b36fb2505c5cfb10cd11a28c9355c0"},
        [1537690962] = {Name = "Blair", Icon = "rbxassetid://1537690962", ScriptId = "d4f4e1f4b5e1e4c3a6f7b8c9d0e1f2a3"},
        [131623223084840] = {Name = "Escape Tsunami For Brainrot", Icon = "rbxassetid://1537690962", ScriptId = "4a454737b486e773c71e51ed30a5dac6"},
        [119987266683883] = {Name = "Survive Lava For Brainrots", Icon = "rbxassetid://1537690962", ScriptId = "edd7a397cc001d76c5417df7101a2303"},
        [134763881293027] = {Name = "Climb For Brainrots", Icon = "rbxassetid://1537690962", ScriptId = "04e9d4476ad5dde4ec898e4cd254e0c9"},
    }
}

local CurrentGameData = Config.SupportedGames[game.PlaceId]
local IsGameSupported = CurrentGameData ~= nil

if IsGameSupported then
    LuarmorAPI.script_id = CurrentGameData.ScriptId
end


local KeyStats = {
    TotalKeys = 0,
    SuccessRate = 0,
    LastUsed = "Never"
}

local KEY_SAVE_FILE = "NexusHub/saved_key.txt"

local function SaveKey(key)
    pcall(function()
        makefolder("NexusHub")
        writefile(KEY_SAVE_FILE, key)
    end)
end

local function LoadKey()
    local success, data = pcall(function()
        if isfile(KEY_SAVE_FILE) then
            return readfile(KEY_SAVE_FILE)
        end
        return nil
    end)
    if success and data and data ~= "" then
        return data
    end
    return nil
end

local function WipeKey()
    pcall(function()
        if isfile(KEY_SAVE_FILE) then
            delfile(KEY_SAVE_FILE)
        end
    end)
end


local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "nexuskeysystem"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui


local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 950, 0, 600)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Config.Colors.Background
MainFrame.BackgroundTransparency = 0.75
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Config.Colors.Border
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

local dragging, dragInput, dragStart, startPos
local resizing = false

local function updateDrag(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and not resizing then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging and not resizing then
        updateDrag(input)
    end
end)


local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundColor3 = Config.Colors.Secondary
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 12)
TopBarCorner.Parent = TopBar

local TopBarCover = Instance.new("Frame")
TopBarCover.Size = UDim2.new(1, 0, 0, 20)
TopBarCover.Position = UDim2.new(0, 0, 1, -20)
TopBarCover.BackgroundColor3 = Config.Colors.Secondary
TopBarCover.BorderSizePixel = 0
TopBarCover.Parent = TopBar


local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(0, 200, 1, 0)
TitleLabel.Position = UDim2.new(0, 20, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🔐 Key system"
TitleLabel.TextColor3 = Config.Colors.Text
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 18
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local VersionBadge = Instance.new("TextLabel")
VersionBadge.Name = "Version"
VersionBadge.Size = UDim2.new(0, 60, 0, 24)
VersionBadge.Position = UDim2.new(0, 140, 0.5, -12)
VersionBadge.BackgroundColor3 = Config.Colors.Border
VersionBadge.Text = Config.KeySystemVersion
VersionBadge.TextColor3 = Config.Colors.SubText
VersionBadge.Font = Enum.Font.GothamMedium
VersionBadge.TextSize = 13
VersionBadge.Parent = TopBar

local VersionCorner = Instance.new("UICorner")
VersionCorner.CornerRadius = UDim.new(0, 6)
VersionCorner.Parent = VersionBadge


local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -45, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
CloseButton.Text = "❌"
CloseButton.TextColor3 = Config.Colors.Text
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 20
CloseButton.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    local closeTween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    })
    
    closeTween:Play()
    closeTween.Completed:Connect(function()
        ScreenGui:Destroy()
    end)
end)


local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 40, 0, 40)
MinimizeButton.Position = UDim2.new(1, -90, 0, 5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
MinimizeButton.Text = "−"
MinimizeButton.TextColor3 = Config.Colors.Text
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 24
MinimizeButton.Parent = TopBar

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 8)
MinimizeCorner.Parent = MinimizeButton

local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    local targetSize = minimized and UDim2.new(0, 950, 0, 50) or UDim2.new(0, 950, 0, 600)
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = targetSize}):Play()
end)


local ResizeHandle = Instance.new("Frame")
ResizeHandle.Name = "ResizeHandle"
ResizeHandle.Size = UDim2.new(0, 30, 0, 30)
ResizeHandle.Position = UDim2.new(1, -30, 1, -30)
ResizeHandle.BackgroundColor3 = Config.Colors.Secondary
ResizeHandle.BackgroundTransparency = 0
ResizeHandle.BorderSizePixel = 0
ResizeHandle.ZIndex = 10
ResizeHandle.Parent = MainFrame

local ResizeCorner = Instance.new("UICorner")
ResizeCorner.CornerRadius = UDim.new(0, 12)
ResizeCorner.Parent = ResizeHandle

local ResizeStroke = Instance.new("UIStroke")
ResizeStroke.Color = Config.Colors.Accent
ResizeStroke.Thickness = 2
ResizeStroke.Parent = ResizeHandle


local gripSpacing = 6
for i = 1, 3 do
    local GripLine = Instance.new("Frame")
    GripLine.Size = UDim2.new(0, 2, 0, 14)
    GripLine.Position = UDim2.new(0, 4 + (i-1) * gripSpacing, 0.5, -7)
    GripLine.BackgroundColor3 = Config.Colors.Accent
    GripLine.BorderSizePixel = 0
    GripLine.Rotation = 45
    GripLine.BackgroundTransparency = 0
    GripLine.Parent = ResizeHandle
end


local resizeStart, sizeStart
local minSize = Vector2.new(700, 450)
local maxSize = Vector2.new(1400, 900)

ResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = true
        dragging = false
        resizeStart = input.Position
        sizeStart = MainFrame.AbsoluteSize
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                resizing = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - resizeStart
        local newWidth = math.clamp(sizeStart.X + delta.X, minSize.X, maxSize.X)
        local newHeight = math.clamp(sizeStart.Y + delta.Y, minSize.Y, maxSize.Y)
        
        MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
    end
end)


local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "Content"
ContentFrame.Size = UDim2.new(1, -20, 1, -70)
ContentFrame.Position = UDim2.new(0, 10, 0, 60)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame


local LeftPanel = Instance.new("Frame")
LeftPanel.Name = "LeftPanel"
LeftPanel.Size = UDim2.new(0.47, 0, 1, 0)
LeftPanel.BackgroundTransparency = 1
LeftPanel.Parent = ContentFrame


local StatusFrame = Instance.new("Frame")
StatusFrame.Name = "StatusFrame"
StatusFrame.Size = UDim2.new(1, 0, 0.27, 0)
StatusFrame.BackgroundColor3 = Config.Colors.Secondary
StatusFrame.BorderSizePixel = 0
StatusFrame.Parent = LeftPanel

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 10)
StatusCorner.Parent = StatusFrame

local StatusStroke = Instance.new("UIStroke")
StatusStroke.Color = Config.Colors.Border
StatusStroke.Thickness = 1
StatusStroke.Transparency = 0.5
StatusStroke.Parent = StatusFrame


local StatusGradient = Instance.new("UIGradient")
StatusGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 30))
})
StatusGradient.Rotation = 45
StatusGradient.Parent = StatusFrame


local HubTitle = Instance.new("TextLabel")
HubTitle.Size = UDim2.new(1, -40, 0, 40)
HubTitle.Position = UDim2.new(0, 20, 0, 15)
HubTitle.BackgroundTransparency = 1
HubTitle.Text = Config.HubName
HubTitle.TextColor3 = Config.Colors.Text
HubTitle.Font = Enum.Font.GothamBold
HubTitle.TextSize = 32
HubTitle.TextXAlignment = Enum.TextXAlignment.Center
HubTitle.TextStrokeTransparency = 0.8
HubTitle.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
HubTitle.Parent = StatusFrame


local StatusBadge = Instance.new("Frame")
StatusBadge.Name = "StatusBadge"
StatusBadge.Size = UDim2.new(0, 130, 0, 36)
StatusBadge.Position = UDim2.new(0.5, -65, 0, 60)
StatusBadge.BackgroundColor3 = Color3.fromRGB(60, 50, 30)
StatusBadge.Parent = StatusFrame

local StatusBadgeCorner = Instance.new("UICorner")
StatusBadgeCorner.CornerRadius = UDim.new(0, 18)
StatusBadgeCorner.Parent = StatusBadge

local StatusBadgeStroke = Instance.new("UIStroke")
StatusBadgeStroke.Color = Config.Colors.Accent
StatusBadgeStroke.Thickness = 2
StatusBadgeStroke.Parent = StatusBadge


local StatusGlow = Instance.new("ImageLabel")
StatusGlow.Name = "Glow"
StatusGlow.Size = UDim2.new(1, 30, 1, 30)
StatusGlow.Position = UDim2.new(0.5, -15, 0.5, -15)
StatusGlow.AnchorPoint = Vector2.new(0.5, 0.5)
StatusGlow.BackgroundTransparency = 1
StatusGlow.Image = "rbxassetid://4996891970"
StatusGlow.ImageColor3 = Config.Colors.Accent
StatusGlow.ImageTransparency = 0.7
StatusGlow.ZIndex = 0
StatusGlow.Parent = StatusBadge

local StatusIcon = Instance.new("TextLabel")
StatusIcon.Size = UDim2.new(0, 20, 1, 0)
StatusIcon.Position = UDim2.new(0, 10, 0, 0)
StatusIcon.BackgroundTransparency = 1
StatusIcon.Text = "⏱"
StatusIcon.TextColor3 = Config.Colors.Accent
StatusIcon.Font = Enum.Font.GothamBold
StatusIcon.TextSize = 16
StatusIcon.Parent = StatusBadge

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -35, 1, 0)
StatusText.Position = UDim2.new(0, 35, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Pending"
StatusText.TextColor3 = Config.Colors.Accent
StatusText.Font = Enum.Font.GothamBold
StatusText.TextSize = 14
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = StatusBadge


local KeyHint = Instance.new("TextLabel")
KeyHint.Size = UDim2.new(1, -40, 0, 20)
KeyHint.Position = UDim2.new(0, 20, 1, -35)
KeyHint.BackgroundTransparency = 1
local currentGame = Config.SupportedGames[game.PlaceId]
KeyHint.Text = currentGame and ("🎮 Current games: " .. currentGame.Name) or "🎮 Current games: Unsupported Game"
KeyHint.TextColor3 = Config.Colors.SubText
KeyHint.Font = Enum.Font.GothamMedium
KeyHint.TextSize = 13
KeyHint.TextXAlignment = Enum.TextXAlignment.Right
KeyHint.Parent = StatusFrame


local UserPanel = Instance.new("Frame")
UserPanel.Name = "UserPanel"
UserPanel.Size = UDim2.new(1, 0, 0.19, 0)
UserPanel.Position = UDim2.new(0, 0, 0.29, 0)
UserPanel.BackgroundColor3 = Config.Colors.Secondary
UserPanel.BorderSizePixel = 0
UserPanel.Parent = LeftPanel

local UserPanelCorner = Instance.new("UICorner")
UserPanelCorner.CornerRadius = UDim.new(0, 10)
UserPanelCorner.Parent = UserPanel

local UserPanelStroke = Instance.new("UIStroke")
UserPanelStroke.Color = Config.Colors.Border
UserPanelStroke.Thickness = 1
UserPanelStroke.Transparency = 0.5
UserPanelStroke.Parent = UserPanel

local UserGradient = Instance.new("UIGradient")
UserGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 30))
})
UserGradient.Rotation = -45
UserGradient.Parent = UserPanel


local UserAvatar = Instance.new("ImageLabel")
UserAvatar.Name = "Avatar"
UserAvatar.Size = UDim2.new(0, 75, 0, 75)
UserAvatar.Position = UDim2.new(0, 15, 0.5, -37.5)
UserAvatar.BackgroundColor3 = Config.Colors.Border
UserAvatar.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
UserAvatar.Parent = UserPanel

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(0, 12)
AvatarCorner.Parent = UserAvatar

local AvatarStroke = Instance.new("UIStroke")
AvatarStroke.Color = Config.Colors.Accent
AvatarStroke.Thickness = 2
AvatarStroke.Parent = UserAvatar


local UsernameLabel = Instance.new("TextLabel")
UsernameLabel.Size = UDim2.new(0, 200, 0, 25)
UsernameLabel.Position = UDim2.new(0, 95, 0, 15)
UsernameLabel.BackgroundTransparency = 1
UsernameLabel.Text = LocalPlayer.Name
UsernameLabel.TextColor3 = Config.Colors.Text
UsernameLabel.Font = Enum.Font.GothamBold
UsernameLabel.TextSize = 16
UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
UsernameLabel.Parent = UserPanel


local LocationLabel = Instance.new("TextLabel")
LocationLabel.Size = UDim2.new(0, 200, 0, 20)
LocationLabel.Position = UDim2.new(0, 95, 0, 40)
LocationLabel.BackgroundTransparency = 1
LocationLabel.Text = "🌍 Region: " .. (game.LocalizationService.RobloxLocaleId or "Unknown")
LocationLabel.TextColor3 = Config.Colors.SubText
LocationLabel.Font = Enum.Font.Gotham
LocationLabel.TextSize = 13
LocationLabel.TextXAlignment = Enum.TextXAlignment.Left
LocationLabel.Parent = UserPanel


local PlayerCount = Instance.new("TextLabel")
PlayerCount.Size = UDim2.new(0, 200, 0, 20)
PlayerCount.Position = UDim2.new(0, 95, 0, 60)
PlayerCount.BackgroundTransparency = 1
PlayerCount.Text = "👥 " .. #Players:GetPlayers() .. " players"
PlayerCount.TextColor3 = Config.Colors.SubText
PlayerCount.Font = Enum.Font.Gotham
PlayerCount.TextSize = 13
PlayerCount.TextXAlignment = Enum.TextXAlignment.Left
PlayerCount.Parent = UserPanel


local MonthsBadge = Instance.new("Frame")
MonthsBadge.Size = UDim2.new(0, 85, 0, 30)
MonthsBadge.Position = UDim2.new(1, -180, 0.5, -15)
MonthsBadge.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
MonthsBadge.Parent = UserPanel

local MonthsBadgeCorner = Instance.new("UICorner")
MonthsBadgeCorner.CornerRadius = UDim.new(0, 8)
MonthsBadgeCorner.Parent = MonthsBadge

local MonthsBadgeStroke = Instance.new("UIStroke")
MonthsBadgeStroke.Color = Color3.fromRGB(255, 80, 80)
MonthsBadgeStroke.Thickness = 1
MonthsBadgeStroke.Transparency = 0.5
MonthsBadgeStroke.Parent = MonthsBadge

local MonthsText = Instance.new("TextLabel")
MonthsText.Size = UDim2.new(1, 0, 1, 0)
MonthsText.BackgroundTransparency = 1
MonthsText.Text = "📅 Unknow"
MonthsText.TextColor3 = Color3.fromRGB(255, 255, 255)
MonthsText.Font = Enum.Font.GothamBold
MonthsText.TextSize = 11
MonthsText.Parent = MonthsBadge

local RegularBadge = Instance.new("Frame")
RegularBadge.Size = UDim2.new(0, 85, 0, 30)
RegularBadge.Position = UDim2.new(1, -88, 0.5, -15)
RegularBadge.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
RegularBadge.Parent = UserPanel

local RegularBadgeCorner = Instance.new("UICorner")
RegularBadgeCorner.CornerRadius = UDim.new(0, 8)
RegularBadgeCorner.Parent = RegularBadge

local RegularBadgeStroke = Instance.new("UIStroke")
RegularBadgeStroke.Color = Color3.fromRGB(120, 170, 255)
RegularBadgeStroke.Thickness = 1
RegularBadgeStroke.Transparency = 0.5
RegularBadgeStroke.Parent = RegularBadge

local RegularText = Instance.new("TextLabel")
RegularText.Size = UDim2.new(1, 0, 1, 0)
RegularText.BackgroundTransparency = 1
RegularText.Text = "?"
RegularText.TextColor3 = Color3.fromRGB(255, 255, 255)
RegularText.Font = Enum.Font.GothamBold
RegularText.TextSize = 11
RegularText.Parent = RegularBadge


local StatsPanel = Instance.new("Frame")
StatsPanel.Name = "StatsPanel"
StatsPanel.Size = UDim2.new(1, 0, 0.14, 0)
StatsPanel.Position = UDim2.new(0, 0, 0.5, 0)
StatsPanel.BackgroundColor3 = Config.Colors.Secondary
StatsPanel.BorderSizePixel = 0
StatsPanel.Parent = LeftPanel

local StatsPanelCorner = Instance.new("UICorner")
StatsPanelCorner.CornerRadius = UDim.new(0, 10)
StatsPanelCorner.Parent = StatsPanel

local StatsPanelStroke = Instance.new("UIStroke")
StatsPanelStroke.Color = Config.Colors.Border
StatsPanelStroke.Thickness = 1
StatsPanelStroke.Transparency = 0.5
StatsPanelStroke.Parent = StatsPanel

local StatsGradient = Instance.new("UIGradient")
StatsGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 30))
})
StatsGradient.Rotation = 90
StatsGradient.Parent = StatsPanel


local StatsTitle = Instance.new("TextLabel")
StatsTitle.Size = UDim2.new(0, 150, 0, 25)
StatsTitle.Position = UDim2.new(0, 15, 0, 10)
StatsTitle.BackgroundTransparency = 1
StatsTitle.Text = "📊 Statistics"
StatsTitle.TextColor3 = Config.Colors.Text
StatsTitle.Font = Enum.Font.GothamBold
StatsTitle.TextSize = 14
StatsTitle.TextXAlignment = Enum.TextXAlignment.Left
StatsTitle.Parent = StatsPanel


local RefreshButton = Instance.new("TextButton")
RefreshButton.Size = UDim2.new(0, 30, 0, 30)
RefreshButton.Position = UDim2.new(1, -40, 0, 8)
RefreshButton.BackgroundColor3 = Config.Colors.Border
RefreshButton.Text = "🔄"
RefreshButton.TextSize = 16
RefreshButton.Font = Enum.Font.GothamBold
RefreshButton.TextColor3 = Config.Colors.Text
RefreshButton.Parent = StatsPanel

local RefreshCorner = Instance.new("UICorner")
RefreshCorner.CornerRadius = UDim.new(0, 8)
RefreshCorner.Parent = RefreshButton


local StatsText = Instance.new("TextLabel")
StatsText.Size = UDim2.new(1, -30, 0, 30)
StatsText.Position = UDim2.new(0, 15, 0, 35)
StatsText.BackgroundTransparency = 1
StatsText.Text = string.format("Keys: %d | Success: %d%% | Last: %s", KeyStats.TotalKeys, KeyStats.SuccessRate, KeyStats.LastUsed)
StatsText.TextColor3 = Config.Colors.SubText
StatsText.Font = Enum.Font.Gotham
StatsText.TextSize = 13
StatsText.TextXAlignment = Enum.TextXAlignment.Left
StatsText.Parent = StatsPanel


local GamesPanel = Instance.new("Frame")
GamesPanel.Name = "GamesPanel"
GamesPanel.Size = UDim2.new(1, 0, 0.32, 0)
GamesPanel.Position = UDim2.new(0, 0, 0.67, 0)
GamesPanel.BackgroundColor3 = Config.Colors.Secondary
GamesPanel.BorderSizePixel = 0
GamesPanel.Parent = LeftPanel

local GamesPanelCorner = Instance.new("UICorner")
GamesPanelCorner.CornerRadius = UDim.new(0, 10)
GamesPanelCorner.Parent = GamesPanel

local GamesPanelStroke = Instance.new("UIStroke")
GamesPanelStroke.Color = Config.Colors.Border
GamesPanelStroke.Thickness = 1
GamesPanelStroke.Transparency = 0.5
GamesPanelStroke.Parent = GamesPanel

local GamesGradient = Instance.new("UIGradient")
GamesGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 30))
})
GamesGradient.Rotation = -90
GamesGradient.Parent = GamesPanel


local GamesTitle = Instance.new("TextLabel")
GamesTitle.Size = UDim2.new(1, -30, 0, 35)
GamesTitle.Position = UDim2.new(0, 15, 0, 5)
GamesTitle.BackgroundTransparency = 1
GamesTitle.Text = "Supported Games"
GamesTitle.TextColor3 = Config.Colors.Text
GamesTitle.Font = Enum.Font.GothamBold
GamesTitle.TextSize = 15
GamesTitle.TextXAlignment = Enum.TextXAlignment.Left
GamesTitle.Parent = GamesPanel


local SearchBox = Instance.new("TextBox")
SearchBox.Name = "SearchBox"
SearchBox.Size = UDim2.new(1, -30, 0, 35)
SearchBox.Position = UDim2.new(0, 15, 0, 45)
SearchBox.BackgroundColor3 = Config.Colors.Background
SearchBox.PlaceholderText = "🔍 Search games..."
SearchBox.PlaceholderColor3 = Config.Colors.SubText
SearchBox.Text = ""
SearchBox.TextColor3 = Config.Colors.Text
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 13
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.Parent = GamesPanel

local SearchPadding = Instance.new("UIPadding")
SearchPadding.PaddingLeft = UDim.new(0, 10)
SearchPadding.Parent = SearchBox

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 8)
SearchCorner.Parent = SearchBox


local GamesScroll = Instance.new("ScrollingFrame")
GamesScroll.Name = "GamesScroll"
GamesScroll.Size = UDim2.new(1, -30, 1, -95)
GamesScroll.Position = UDim2.new(0, 15, 0, 85)
GamesScroll.BackgroundTransparency = 1
GamesScroll.ScrollBarThickness = 4
GamesScroll.ScrollBarImageColor3 = Config.Colors.Border
GamesScroll.BorderSizePixel = 0
GamesScroll.Parent = GamesPanel

local GamesListLayout = Instance.new("UIListLayout")
GamesListLayout.SortOrder = Enum.SortOrder.LayoutOrder
GamesListLayout.Padding = UDim.new(0, 8)
GamesListLayout.Parent = GamesScroll


local function CreateGameEntry(gameName, icon, isSupported)
    local GameEntry = Instance.new("Frame")
    GameEntry.Name = gameName
    GameEntry.Size = UDim2.new(1, -10, 0, 55)
    GameEntry.BackgroundColor3 = Config.Colors.Background
    GameEntry.BorderSizePixel = 0
    GameEntry.Parent = GamesScroll
    
    local GameCorner = Instance.new("UICorner")
    GameCorner.CornerRadius = UDim.new(0, 8)
    GameCorner.Parent = GameEntry
    
    local GameIcon = Instance.new("ImageLabel")
    GameIcon.Size = UDim2.new(0, 40, 0, 40)
    GameIcon.Position = UDim2.new(0, 10, 0.5, -20)
    GameIcon.BackgroundColor3 = Config.Colors.Border
    GameIcon.Image = icon
    GameIcon.Parent = GameEntry
    
    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(0, 8)
    IconCorner.Parent = GameIcon
    
    local GameNameLabel = Instance.new("TextLabel")
    GameNameLabel.Size = UDim2.new(1, -120, 1, 0)
    GameNameLabel.Position = UDim2.new(0, 60, 0, 0)
    GameNameLabel.BackgroundTransparency = 1
    GameNameLabel.Text = gameName
    GameNameLabel.TextColor3 = Config.Colors.Text
    GameNameLabel.Font = Enum.Font.GothamMedium
    GameNameLabel.TextSize = 14
    GameNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    GameNameLabel.Parent = GameEntry
    
    if isSupported then
        local CheckMark = Instance.new("TextLabel")
        CheckMark.Size = UDim2.new(0, 30, 0, 30)
        CheckMark.Position = UDim2.new(1, -40, 0.5, -15)
        CheckMark.BackgroundTransparency = 1
        CheckMark.Text = "✓"
        CheckMark.TextColor3 = Config.Colors.Success
        CheckMark.Font = Enum.Font.GothamBold
        CheckMark.TextSize = 20
        CheckMark.Parent = GameEntry
    end
    
    return GameEntry
end


CreateGameEntry("Blair", "https://tr.rbxcdn.com/180DAY-eb975ef400242026d8b0ed28808c3ec6/768/432/Image/Webp/noFilter", true)
CreateGameEntry("Demonology", "https://tr.rbxcdn.com/180DAY-73d277df7a233a3aaf2afb060b5f7452/768/432/Image/Webp/noFilter", true)

GamesScroll.CanvasSize = UDim2.new(0, 0, 0, GamesListLayout.AbsoluteContentSize.Y + 10)
GamesListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    GamesScroll.CanvasSize = UDim2.new(0, 0, 0, GamesListLayout.AbsoluteContentSize.Y + 10)
end)


local RightPanel = Instance.new("Frame")
RightPanel.Name = "RightPanel"
RightPanel.Size = UDim2.new(0.5, 0, 1, 0)
RightPanel.Position = UDim2.new(0.5, 0, 0, 0)
RightPanel.BackgroundTransparency = 1
RightPanel.Parent = ContentFrame


local EnterKeyPanel = Instance.new("Frame")
EnterKeyPanel.Name = "EnterKeyPanel"
EnterKeyPanel.Size = UDim2.new(1, 0, 0.38, 0)
EnterKeyPanel.BackgroundColor3 = Config.Colors.Secondary
EnterKeyPanel.BorderSizePixel = 0
EnterKeyPanel.Parent = RightPanel

local EnterKeyCorner = Instance.new("UICorner")
EnterKeyCorner.CornerRadius = UDim.new(0, 10)
EnterKeyCorner.Parent = EnterKeyPanel

local EnterKeyStroke = Instance.new("UIStroke")
EnterKeyStroke.Color = Config.Colors.Border
EnterKeyStroke.Thickness = 1
EnterKeyStroke.Transparency = 0.5
EnterKeyStroke.Parent = EnterKeyPanel

local EnterKeyGradient = Instance.new("UIGradient")
EnterKeyGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 30))
})
EnterKeyGradient.Rotation = 135
EnterKeyGradient.Parent = EnterKeyPanel


local EnterKeyTitle = Instance.new("TextLabel")
EnterKeyTitle.Size = UDim2.new(1, -100, 0, 35)
EnterKeyTitle.Position = UDim2.new(0, 20, 0, 15)
EnterKeyTitle.BackgroundTransparency = 1
EnterKeyTitle.Text = "Enter your key"
EnterKeyTitle.TextColor3 = Config.Colors.Text
EnterKeyTitle.Font = Enum.Font.GothamBold
EnterKeyTitle.TextSize = 18
EnterKeyTitle.TextXAlignment = Enum.TextXAlignment.Left
EnterKeyTitle.Parent = EnterKeyPanel


local HistoryButton = Instance.new("TextButton")
HistoryButton.Size = UDim2.new(0, 100, 0, 32)
HistoryButton.Position = UDim2.new(1, -120, 0, 17)
HistoryButton.BackgroundColor3 = Config.Colors.Background
HistoryButton.Text = "📋 History"
HistoryButton.TextColor3 = Config.Colors.Text
HistoryButton.Font = Enum.Font.GothamMedium
HistoryButton.TextSize = 13
HistoryButton.Parent = EnterKeyPanel

local HistoryCorner = Instance.new("UICorner")
HistoryCorner.CornerRadius = UDim.new(0, 8)
HistoryCorner.Parent = HistoryButton


local KeyInput = Instance.new("TextBox")
KeyInput.Name = "KeyInput"
KeyInput.Size = UDim2.new(1, -160, 0, 45)
KeyInput.Position = UDim2.new(0, 20, 0, 60)
KeyInput.BackgroundColor3 = Config.Colors.Background
KeyInput.PlaceholderText = "Enter your Key..."
KeyInput.PlaceholderColor3 = Config.Colors.SubText
KeyInput.Text = ""
KeyInput.TextColor3 = Config.Colors.Text
KeyInput.Font = Enum.Font.Gotham
KeyInput.TextSize = 14
KeyInput.TextXAlignment = Enum.TextXAlignment.Left
KeyInput.ClearTextOnFocus = false
KeyInput.Parent = EnterKeyPanel

local KeyInputPadding = Instance.new("UIPadding")
KeyInputPadding.PaddingLeft = UDim.new(0, 15)
KeyInputPadding.Parent = KeyInput

local KeyInputCorner = Instance.new("UICorner")
KeyInputCorner.CornerRadius = UDim.new(0, 8)
KeyInputCorner.Parent = KeyInput


local HelpButton = Instance.new("TextButton")
HelpButton.Size = UDim2.new(0, 45, 0, 45)
HelpButton.Position = UDim2.new(1, -145, 0, 60)
HelpButton.BackgroundColor3 = Config.Colors.Background
HelpButton.Text = "?"
HelpButton.TextColor3 = Config.Colors.Text
HelpButton.Font = Enum.Font.GothamBold
HelpButton.TextSize = 20
HelpButton.Parent = EnterKeyPanel

local HelpCorner = Instance.new("UICorner")
HelpCorner.CornerRadius = UDim.new(0, 8)
HelpCorner.Parent = HelpButton


local ClearButton = Instance.new("TextButton")
ClearButton.Size = UDim2.new(0, 45, 0, 45)
ClearButton.Position = UDim2.new(1, -90, 0, 60)
ClearButton.BackgroundColor3 = Config.Colors.Background
ClearButton.Text = "✕"
ClearButton.TextColor3 = Config.Colors.Text
ClearButton.Font = Enum.Font.GothamBold
ClearButton.TextSize = 18
ClearButton.Parent = EnterKeyPanel

local ClearCorner = Instance.new("UICorner")
ClearCorner.CornerRadius = UDim.new(0, 8)
ClearCorner.Parent = ClearButton

ClearButton.MouseButton1Click:Connect(function()
    KeyInput.Text = ""
end)


local VerifyButton = Instance.new("TextButton")
VerifyButton.Name = "VerifyButton"
VerifyButton.Size = UDim2.new(0.48, -15, 0, 45)
VerifyButton.Position = UDim2.new(0, 20, 0, 120)
VerifyButton.BackgroundColor3 = Config.Colors.Success
VerifyButton.Text = "✓ Verify Key"
VerifyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyButton.Font = Enum.Font.GothamBold
VerifyButton.TextSize = 15
VerifyButton.AutoButtonColor = false
VerifyButton.Parent = EnterKeyPanel

local VerifyCorner = Instance.new("UICorner")
VerifyCorner.CornerRadius = UDim.new(0, 8)
VerifyCorner.Parent = VerifyButton


local GetKeyButton = Instance.new("TextButton")
GetKeyButton.Name = "GetKeyButton"
GetKeyButton.Size = UDim2.new(0.48, -15, 0, 45)
GetKeyButton.Position = UDim2.new(0.52, 5, 0, 120)
GetKeyButton.BackgroundColor3 = Color3.fromRGB(230, 100, 60)
GetKeyButton.Text = "🔑 Get Key"
GetKeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
GetKeyButton.Font = Enum.Font.GothamBold
GetKeyButton.TextSize = 15
GetKeyButton.AutoButtonColor = false
GetKeyButton.Parent = EnterKeyPanel

local GetKeyCorner = Instance.new("UICorner")
GetKeyCorner.CornerRadius = UDim.new(0, 8)
GetKeyCorner.Parent = GetKeyButton


local GuidePanel = Instance.new("Frame")
GuidePanel.Name = "GuidePanel"
GuidePanel.Size = UDim2.new(1, 0, 0.27, 0)
GuidePanel.Position = UDim2.new(0, 0, 0.4, 0)
GuidePanel.BackgroundColor3 = Config.Colors.Secondary
GuidePanel.BorderSizePixel = 0
GuidePanel.Parent = RightPanel

local GuideCorner = Instance.new("UICorner")
GuideCorner.CornerRadius = UDim.new(0, 10)
GuideCorner.Parent = GuidePanel

local GuideStroke = Instance.new("UIStroke")
GuideStroke.Color = Config.Colors.Border
GuideStroke.Thickness = 1
GuideStroke.Transparency = 0.5
GuideStroke.Parent = GuidePanel

local GuideGradient = Instance.new("UIGradient")
GuideGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 30))
})
GuideGradient.Rotation = -135
GuideGradient.Parent = GuidePanel


local GuideTitle = Instance.new("TextLabel")
GuideTitle.Size = UDim2.new(1, -40, 0, 30)
GuideTitle.Position = UDim2.new(0, 20, 0, 10)
GuideTitle.BackgroundTransparency = 1
GuideTitle.Text = "📘 Quick Guide"
GuideTitle.TextColor3 = Config.Colors.Text
GuideTitle.Font = Enum.Font.GothamBold
GuideTitle.TextSize = 16
GuideTitle.TextXAlignment = Enum.TextXAlignment.Left
GuideTitle.Parent = GuidePanel


local steps = {
    "1️⃣ Click Get Key",
    "2️⃣ Complete checkpoint",
    "3️⃣ Copy the key",
    "4️⃣ Paste & verify"
}

for i, step in ipairs(steps) do
    local StepLabel = Instance.new("TextLabel")
    StepLabel.Size = UDim2.new(0.48, -20, 0, 20)
    StepLabel.Position = UDim2.new((i-1)%2 * 0.52, 20, 0, 45 + math.floor((i-1)/2) * 25)
    StepLabel.BackgroundTransparency = 1
    StepLabel.Text = step
    StepLabel.TextColor3 = Config.Colors.SubText
    StepLabel.Font = Enum.Font.Gotham
    StepLabel.TextSize = 12
    StepLabel.TextXAlignment = Enum.TextXAlignment.Left
    StepLabel.Parent = GuidePanel
end


local DiscordPanel = Instance.new("Frame")
DiscordPanel.Name = "DiscordPanel"
DiscordPanel.Size = UDim2.new(1, 0, 0.31, 0)
DiscordPanel.Position = UDim2.new(0, 0, 0.69, 0)
DiscordPanel.BackgroundColor3 = Config.Colors.Secondary
DiscordPanel.BorderSizePixel = 0
DiscordPanel.Parent = RightPanel

local DiscordCorner = Instance.new("UICorner")
DiscordCorner.CornerRadius = UDim.new(0, 10)
DiscordCorner.Parent = DiscordPanel

local DiscordStroke = Instance.new("UIStroke")
DiscordStroke.Color = Color3.fromRGB(88, 101, 242)
DiscordStroke.Thickness = 1
DiscordStroke.Transparency = 0.5
DiscordStroke.Parent = DiscordPanel

local DiscordGradient = Instance.new("UIGradient")
DiscordGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 32, 45))
})
DiscordGradient.Rotation = 180
DiscordGradient.Parent = DiscordPanel


local DiscordTitle = Instance.new("TextLabel")
DiscordTitle.Size = UDim2.new(1, -40, 0, 35)
DiscordTitle.Position = UDim2.new(0, 20, 0, 15)
DiscordTitle.BackgroundTransparency = 1
DiscordTitle.Text = "Discord Server"
DiscordTitle.TextColor3 = Config.Colors.Text
DiscordTitle.Font = Enum.Font.GothamBold
DiscordTitle.TextSize = 18
DiscordTitle.TextXAlignment = Enum.TextXAlignment.Left
DiscordTitle.Parent = DiscordPanel


local DiscordDesc = Instance.new("TextLabel")
DiscordDesc.Size = UDim2.new(1, -40, 0, 80)
DiscordDesc.Position = UDim2.new(0, 20, 0, 55)
DiscordDesc.BackgroundTransparency = 1
DiscordDesc.Text = "Pulse Hub is a community focused on providing quality scripts and support. Join our Discord server to stay updated, get help, and connect with other members!"
DiscordDesc.TextColor3 = Config.Colors.SubText
DiscordDesc.Font = Enum.Font.Gotham
DiscordDesc.TextSize = 13
DiscordDesc.TextWrapped = true
DiscordDesc.TextXAlignment = Enum.TextXAlignment.Left
DiscordDesc.TextYAlignment = Enum.TextYAlignment.Top
DiscordDesc.Parent = DiscordPanel


local JoinDiscordButton = Instance.new("TextButton")
JoinDiscordButton.Name = "JoinDiscordButton"
JoinDiscordButton.Size = UDim2.new(1, -40, 0, 45)
JoinDiscordButton.Position = UDim2.new(0, 20, 1, -60)
JoinDiscordButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
JoinDiscordButton.Text = "💬 Join Server"
JoinDiscordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
JoinDiscordButton.Font = Enum.Font.GothamBold
JoinDiscordButton.TextSize = 15
JoinDiscordButton.AutoButtonColor = false
JoinDiscordButton.Parent = DiscordPanel

local JoinDiscordCorner = Instance.new("UICorner")
JoinDiscordCorner.CornerRadius = UDim.new(0, 8)
JoinDiscordCorner.Parent = JoinDiscordButton


local function AddHoverEffect(button, normalColor, hoverColor)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = normalColor}):Play()
    end)
end

AddHoverEffect(VerifyButton, Config.Colors.Success, Color3.fromRGB(80, 220, 120))
AddHoverEffect(GetKeyButton, Color3.fromRGB(230, 100, 60), Color3.fromRGB(250, 120, 80))
AddHoverEffect(JoinDiscordButton, Color3.fromRGB(88, 101, 242), Color3.fromRGB(108, 121, 255))
AddHoverEffect(CloseButton, Color3.fromRGB(40, 40, 45), Color3.fromRGB(220, 50, 50))

local function SetStatusError(message)
    StatusText.Text = message
    StatusBadge.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
    StatusBadgeStroke.Color = Color3.fromRGB(220, 50, 50)
    StatusIcon.Text = "❌"
    StatusIcon.TextColor3 = Color3.fromRGB(220, 50, 50)
    StatusText.TextColor3 = Color3.fromRGB(220, 50, 50)
end

local function SetStatusSuccess(message)
    StatusText.Text = message
    StatusBadge.BackgroundColor3 = Color3.fromRGB(30, 60, 40)
    StatusBadgeStroke.Color = Config.Colors.Success
    StatusIcon.Text = "✓"
    StatusIcon.TextColor3 = Config.Colors.Success
    StatusText.TextColor3 = Config.Colors.Success
end

local function SetStatusWarning(message)
    StatusText.Text = message
    StatusBadge.BackgroundColor3 = Color3.fromRGB(60, 50, 30)
    StatusBadgeStroke.Color = Config.Colors.Accent
    StatusIcon.Text = "⚠"
    StatusIcon.TextColor3 = Config.Colors.Accent
    StatusText.TextColor3 = Config.Colors.Accent
end

local function SetStatusLoading(message)
    StatusText.Text = message
    StatusBadge.BackgroundColor3 = Color3.fromRGB(60, 50, 30)
    StatusBadgeStroke.Color = Config.Colors.Accent
    StatusIcon.Text = "⏱"
    StatusIcon.TextColor3 = Config.Colors.Accent
    StatusText.TextColor3 = Config.Colors.Accent
end


VerifyButton.MouseButton1Click:Connect(function()
    local key = KeyInput.Text
    
    if not IsGameSupported then
        SetStatusError("❌ Game Not Supported!")
        return
    end
    
    if key == "" then
        SetStatusError("❌ Please enter a key!")
        return
    end
    
    SetStatusLoading("⏱ Verifying...")
    
    task.spawn(function()
        local success, status = pcall(function()
            return LuarmorAPI.check_key(key)
        end)
        
        if not success then
            SetStatusError("❌ Connection Error!")
            return
        end
        
        if status.code == "KEY_VALID" then
            SetStatusSuccess("✓ Verified!")
            SaveKey(key)
            
            KeyStats.TotalKeys = KeyStats.TotalKeys + 1
            KeyStats.SuccessRate = 100
            KeyStats.LastUsed = os.date("%H:%M")
            
            StatsText.Text = string.format("Keys: %d | Success: %d%% | Last: %s", KeyStats.TotalKeys, KeyStats.SuccessRate, KeyStats.LastUsed)
            
            local originalSize = StatusBadge.Size
            TweenService:Create(StatusBadge, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 140, 0, 36)
            }):Play()
            task.wait(0.2)
            TweenService:Create(StatusBadge, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = originalSize
            }):Play()
            
            local successFlash = Instance.new("Frame")
            successFlash.Size = UDim2.new(1, 0, 1, 0)
            successFlash.BackgroundColor3 = Config.Colors.Success
            successFlash.BackgroundTransparency = 1
            successFlash.BorderSizePixel = 0
            successFlash.ZIndex = 100
            successFlash.Parent = MainFrame
            
            TweenService:Create(successFlash, TweenInfo.new(0.3), {BackgroundTransparency = 0.7}):Play()
            task.wait(0.3)
            TweenService:Create(successFlash, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
            
            task.wait(0.5)
            
            local expiryText = ""
            if status.data and status.data.auth_expire then
                if status.data.auth_expire == -1 or status.data.auth_expire == 0 then
                    expiryText = "Lifetime"
                else
                    local timeLeft = status.data.auth_expire - os.time()
                    if timeLeft > 86400 then
                        expiryText = math.floor(timeLeft / 86400) .. " days left"
                    elseif timeLeft > 3600 then
                        expiryText = math.floor(timeLeft / 3600) .. " hours left"
                    else
                        expiryText = math.floor(timeLeft / 60) .. " minutes left"
                    end
                end
            end
            
            print("✓ Key verified! " .. expiryText .. " Loading script...")
            
            getgenv().script_key = key
            
            local exitTween = TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1
            })
            exitTween:Play()
            exitTween.Completed:Connect(function()
                ScreenGui:Destroy()
                LuarmorAPI.load_script()
            end)
            
        elseif status.code == "KEY_EXPIRED" then
            WipeKey()
            SetStatusWarning("⚠ Key Expired!")
            KeyStats.TotalKeys = KeyStats.TotalKeys + 1
            StatsText.Text = string.format("Keys: %d | Last: Expired", KeyStats.TotalKeys)
            
        elseif status.code == "KEY_BANNED" then
            WipeKey()
            SetStatusError("❌ Key Blacklisted!")
            KeyStats.TotalKeys = KeyStats.TotalKeys + 1
            StatsText.Text = string.format("Keys: %d | Last: Banned", KeyStats.TotalKeys)
            
        elseif status.code == "KEY_HWID_LOCKED" then
            WipeKey()
            SetStatusWarning("⚠ HWID Mismatch!")
            KeyHint.Text = "🔄 Reset HWID via Discord bot"
            KeyStats.TotalKeys = KeyStats.TotalKeys + 1
            StatsText.Text = string.format("Keys: %d | Last: HWID Lock", KeyStats.TotalKeys)
            
        elseif status.code == "KEY_INCORRECT" then
            WipeKey()
            SetStatusError("❌ Key Not Found!")
            KeyStats.TotalKeys = KeyStats.TotalKeys + 1
            KeyStats.SuccessRate = math.floor((KeyStats.SuccessRate * (KeyStats.TotalKeys - 1)) / KeyStats.TotalKeys)
            StatsText.Text = string.format("Keys: %d | Success: %d%% | Last: Failed", KeyStats.TotalKeys, KeyStats.SuccessRate)
            
        elseif status.code == "KEY_INVALID" then
            WipeKey()
            SetStatusError("❌ Invalid Format!")
            
        elseif status.code == "INVALID_EXECUTOR" then
            SetStatusError("❌ Unsupported Executor!")
            
        elseif status.code == "SCRIPT_ID_INCORRECT" or status.code == "SCRIPT_ID_INVALID" then
            SetStatusError("❌ Script Error!")
            print("Luarmor Error: " .. status.message)
            
        elseif status.code == "SECURITY_ERROR" then
            SetStatusError("❌ Security Error!")
            
        elseif status.code == "TIME_ERROR" then
            SetStatusError("❌ Time Sync Error!")
            
        else
            SetStatusError("❌ " .. (status.message or "Unknown Error"))
            print("Luarmor: " .. status.code .. " - " .. status.message)
        end
    end)
end)

GetKeyButton.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(Config.GetKeyURL)
        GetKeyButton.Text = "✓ Link Copied!"
        task.wait(2)
        GetKeyButton.Text = "🔑 Get Key"
    end
end)

JoinDiscordButton.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(Config.DiscordInvite)
        JoinDiscordButton.Text = "✓ Invite Copied!"
        task.wait(2)
        JoinDiscordButton.Text = "💬 Join Server"
    end
end)

HistoryButton.MouseButton1Click:Connect(function()
    print("History feature - Coming soon!")
end)

HelpButton.MouseButton1Click:Connect(function()
    print("Help: Follow the Quick Guide steps to get and verify your key!")
end)


SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local searchText = SearchBox.Text:lower()
    
    for _, child in pairs(GamesScroll:GetChildren()) do
        if child:IsA("Frame") and child.Name ~= "UIListLayout" then
            if searchText == "" or child.Name:lower():find(searchText) then
                child.Visible = true
            else
                child.Visible = false
            end
        end
    end
end)

task.spawn(function()
    local savedKey = LoadKey()
    if savedKey then
        KeyInput.Text = savedKey
        SetStatusLoading("Auto-verifying...")
        
        if not IsGameSupported then
            SetStatusError("Game Not Supported!")
            return
        end
        
        local success, status = pcall(function()
            return LuarmorAPI.check_key(savedKey)
        end)
        
        if not success then
            SetStatusError("Connection Error!")
            return
        end
        
        if status.code == "KEY_VALID" then
            SetStatusSuccess("Auto-verified!")
            
            getgenv().script_key = savedKey
            
            task.wait(1)
            
            local exitTween = TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1
            })
            exitTween:Play()
            exitTween.Completed:Connect(function()
                ScreenGui:Destroy()
                LuarmorAPI.load_script()
            end)
        else
            WipeKey()
            KeyInput.Text = ""
            SetStatusWarning("Saved key expired")
        end
    end
end)

MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.BackgroundTransparency = 1

task.wait(0.1)

TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 950, 0, 600),
    BackgroundTransparency = 0.75
}):Play()

