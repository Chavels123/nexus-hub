local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer

local WindUI
do
    local loaded, library = pcall(function()
        return require("./src/Init")
    end)

    if loaded then
        WindUI = library
    else
        WindUI = loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/Footagesus/WindUI/beta/dist/main.lua"
        ))()
    end
end

local LuarmorAPI = loadstring(game:HttpGet(
    "https://sdkapi-public.luarmor.net/library.lua"
))()

local Config = {
    Title = "Nexus Hub | Key System",
    Version = "V2.0",
    Folder = "NexusHub",
    KeyFile = "NexusHub/saved_key.txt",
    GetKeyURL = "https://ads.luarmor.net/get_key?for=Nexus_Hub-vrIKoBUaLTsp",
    DiscordInvite = "",

    Colors = {
        Purple = Color3.fromHex("#7C3AED"),
        Pink = Color3.fromHex("#EC4899"),
        Green = Color3.fromHex("#10C550"),
        Orange = Color3.fromHex("#EF4F1D"),
        Blue = Color3.fromHex("#257AF7"),
        Yellow = Color3.fromHex("#F59E0B"),
        Grey = Color3.fromHex("#83889E"),
        Red = Color3.fromHex("#FF4444"),
    },

    SupportedGames = {
        [18199615050] = {
            Name = "Demonology (Lobby)",
            ScriptId = "c1b36fb2505c5cfb10cd11a28c9355c0",
        },
        [18794863104] = {
            Name = "Demonology (Game)",
            ScriptId = "c1b36fb2505c5cfb10cd11a28c9355c0",
        },
        [1537690962] = {
            Name = "Blair",
            ScriptId = "d4f4e1f4b5e1e4c3a6f7b8c9d0e1f2a3",
        },
        [131623223084840] = {
            Name = "Escape Tsunami For Brainrot",
            ScriptId = "4a454737b486e773c71e51ed30a5dac6",
        },
        [119987266683883] = {
            Name = "Survive Lava For Brainrots",
            ScriptId = "edd7a397cc001d76c5417df7101a2303",
        },
        [134951244280326] = {
            Name = "Climb For Brainrots",
            ScriptId = "04e9d4476ad5dde4ec898e4cd254e0c9",
        },
        [134763881293027] = {
            Name = "Steal From Brainrots",
            ScriptId = "d117bc3f276322726c7210be6486900d",
        },
        [75992362647444] = {
            Name = "Tap It",
            ScriptId = "ee1527a9632a9200c40524c2edb0b24c",
        },
        [90695455422761] = {
            Name = "Jump To Steal A Brainrot",
            ScriptId = "9d7f7a0161bc3907b797d23d61b43e53",
        },
        [139299356663913] = {
            Name = "Jump For Brainrot",
            ScriptId = "4f3410154ab7fbf964c8c50724a6e87b",
        },
        [94702395375549] = {
            Name = "Run For Brainrot",
            ScriptId = "657c5af6a0605fbff773636b60b332d9",
        },
		[8267733039] = {
            Name = "Specter [Lobby]",
            ScriptId = "4f0cec16fca28b001654e6ed27872468",
        },
		[8417221956] = {
            Name = "Specter [Game]",
            ScriptId = "4f0cec16fca28b001654e6ed27872468",
        },
    },
}

local State = {
    EnteredKey = "",
    Busy = false,
    Loaded = false,
    Attempts = 0,
    SuccessfulAttempts = 0,
    LastStatus = "Waiting for a key",
    LastChecked = "Never",
    Authenticated = false,
    KeyExpiry = "Not authenticated",
    KeyNote = "Not authenticated",
    TotalExecutions = 0,
}

local CurrentGame = Config.SupportedGames[game.PlaceId]

if CurrentGame then
    LuarmorAPI.script_id = CurrentGame.ScriptId
end

local function trim(value)
    return tostring(value or ""):match("^%s*(.-)%s*$") or ""
end

local function notify(title, content, icon, duration)
    WindUI:Notify({
        Title = title,
        Content = content,
        Icon = icon,
        Duration = duration or 4,
    })
end

local function canReadFiles()
    return type(readfile) == "function" and type(isfile) == "function"
end

local function canWriteFiles()
    return canReadFiles() and type(writefile) == "function"
end

local function ensureFolder()
    if type(makefolder) ~= "function" then
        return
    end

    if type(isfolder) == "function" then
        local success, exists = pcall(isfolder, Config.Folder)
        if success and exists then
            return
        end
    end

    pcall(makefolder, Config.Folder)
end

local function loadSavedKey()
    if not canReadFiles() then
        return ""
    end

    local success, exists = pcall(isfile, Config.KeyFile)
    if not success or not exists then
        return ""
    end

    local readSuccess, value = pcall(readfile, Config.KeyFile)
    return readSuccess and trim(value) or ""
end

local function saveKey(key)
    if not canWriteFiles() then
        return false, "Your executor does not support local key saving."
    end

    ensureFolder()

    local success, result = pcall(writefile, Config.KeyFile, trim(key))
    return success, success and nil or tostring(result)
end

local function deleteSavedKey()
    State.EnteredKey = ""

    if type(delfile) ~= "function" or type(isfile) ~= "function" then
        return false, "Your executor does not support deleting saved files."
    end

    local success, result = pcall(function()
        if isfile(Config.KeyFile) then
            delfile(Config.KeyFile)
        end
    end)

    return success, success and nil or tostring(result)
end

local function copyText(value)
    if type(setclipboard) ~= "function" then
        notify(
            "Clipboard Unavailable",
            "Your executor does not support copying links.",
            "clipboard-x",
            5
        )
        return false
    end

    setclipboard(value)
    return true
end

local function setRuntimeKey(key)
    local cleanKey = trim(key)

    if type(getgenv) == "function" then
        getgenv().script_key = cleanKey
    else
        _G.script_key = cleanKey
    end
end

local function formatExpiry(status)
    local expiry = status
        and status.data
        and status.data.auth_expire

    if type(expiry) ~= "number" then
        return "Not provided"
    end

    if expiry == -1 or expiry == 0 then
        return "Lifetime"
    end

    local remaining = expiry - os.time()
    if remaining <= 0 then
        return "Expired"
    end

    local days = math.floor(remaining / 86400)
    local hours = math.floor((remaining % 86400) / 3600)
    local minutes = math.floor((remaining % 3600) / 60)

    if days > 0 then
        return string.format("%d day(s), %d hour(s)", days, hours)
    end

    if hours > 0 then
        return string.format("%d hour(s), %d minute(s)", hours, minutes)
    end

    return string.format("%d minute(s)", math.max(minutes, 1))
end

local function maskKey(key)
    local cleanKey = trim(key)

    if #cleanKey < 12 then
        return cleanKey ~= "" and "••••••••" or "Not authenticated"
    end

    return cleanKey:sub(1, 4)
        .. string.rep("•", math.max(#cleanKey - 8, 4))
        .. cleanKey:sub(-4)
end

local function getGameName()
    if CurrentGame then
        return CurrentGame.Name
    end

    local success, info = pcall(
        MarketplaceService.GetProductInfo,
        MarketplaceService,
        game.PlaceId
    )

    return success and info.Name or "Unsupported Game"
end

local function buildSupportedGameList()
    local games = {}

    for placeId, gameData in pairs(Config.SupportedGames) do
        table.insert(games, string.format("%s  •  %s", gameData.Name, placeId))
    end

    table.sort(games)
    return table.concat(games, "\n")
end

local Window = WindUI:CreateWindow({
    Title = Config.Title,
    Icon = "key-round",
    Author = "by Nexus Hub Team",
    Folder = Config.Folder,
    NewElements = true,
    HideSearchBar = true,
    Size = UDim2.fromOffset(620, 480),
    MinSize = Vector2.new(560, 420),
    MaxSize = Vector2.new(850, 620),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    ToggleKey = Enum.KeyCode.RightShift,

    OpenButton = {
        Title = "Nexus Hub",
        CornerRadius = UDim.new(0, 12),
        StrokeThickness = 2,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 0.5,
        Color = ColorSequence.new(
            Color3.fromHex("#6366F1"),
            Color3.fromHex("#8B5CF6")
        ),
    },

    Topbar = {
        Height = 44,
        ButtonsType = "Mac",
    },
})

Window:Tag({
    Title = Config.Version,
    Icon = "shield-check",
    Color = Config.Colors.Purple,
    Border = true,
})

Window:Tag({
    Title = CurrentGame and "Supported" or "Unsupported",
    Icon = CurrentGame and "circle-check" or "circle-x",
    Color = CurrentGame and Config.Colors.Green or Config.Colors.Red,
    Border = true,
})

local AuthenticationSection = Window:Section({
    Title = "Authentication",
    Icon = "shield-check",
    Opened = true,
})

local SupportSection = Window:Section({
    Title = "Support",
    Icon = "life-buoy",
    Opened = true,
})

local KeyTab = AuthenticationSection:Tab({
    Title = "Key",
    Icon = "key-round",
    IconColor = Config.Colors.Purple,
    IconShape = "Square",
    Border = true,
})

local SessionTab = AuthenticationSection:Tab({
    Title = "Session",
    Icon = "user-round-check",
    IconColor = Config.Colors.Green,
    IconShape = "Square",
    Border = true,
})

local GamesTab = SupportSection:Tab({
    Title = "Supported Games",
    Icon = "gamepad-2",
    IconColor = Config.Colors.Blue,
    IconShape = "Square",
    Border = true,
})

local HelpTab = SupportSection:Tab({
    Title = "Help",
    Icon = "circle-help",
    IconColor = Config.Colors.Yellow,
    IconShape = "Square",
    Border = true,
})

KeyTab:Section({
    Title = "Nexus Hub Access",
    TextSize = 20,
    FontWeight = Enum.FontWeight.Bold,
})

KeyTab:Space()

local CurrentGameParagraph = KeyTab:Paragraph({
    Title = getGameName(),
    Desc = CurrentGame
        and "This game is supported and ready for Luarmor authentication."
        or "This game is not currently supported by Nexus Hub.",
    Image = CurrentGame and "badge-check" or "badge-x",
    ImageSize = 44,
})

KeyTab:Space({ Columns = 2 })

local KeyCard = KeyTab:Section({
    Title = "Enter Your Key",
    Box = true,
    BoxBorder = true,
    Opened = true,
})

local KeyInput = KeyCard:Input({
    Title = "Luarmor Key",
    Desc = "Paste your Nexus Hub key to continue",
    Value = "",
    Placeholder = "Enter your key...",
    InputIcon = "key-round",
    Type = "Input",
    Callback = function(value)
        State.EnteredKey = trim(value)
    end,
})

KeyCard:Space()

local StatusParagraph = KeyCard:Paragraph({
    Title = "Ready",
    Desc = "Enter your key, then select Validate Key & Load.",
    Image = "shield",
})

local StatsParagraph
local SessionParagraph
local ValidateButton

local function updateStats()
    if not StatsParagraph then
        return
    end

    local successRate = State.Attempts > 0
        and math.floor((State.SuccessfulAttempts / State.Attempts) * 100)
        or 0

    StatsParagraph:SetDesc(table.concat({
        "Attempts: " .. State.Attempts,
        "Success Rate: " .. successRate .. "%",
        "Last Checked: " .. State.LastChecked,
        "Last Result: " .. State.LastStatus,
    }, "\n"))
end

local function updateSession()
    if not SessionParagraph then
        return
    end

    SessionParagraph:SetTitle(
        State.Authenticated and "Authenticated Session" or "No Active Session"
    )
    SessionParagraph:SetDesc(table.concat({
        "Status: " .. (State.Authenticated and "Authenticated" or "Waiting"),
        "Key: " .. maskKey(State.EnteredKey),
        "Access: " .. State.KeyExpiry,
        "Note: " .. State.KeyNote,
        "Total Executions: " .. tostring(State.TotalExecutions),
    }, "\n"))
    SessionParagraph:SetImage(
        State.Authenticated and "badge-check" or "badge-minus"
    )
end

local function setStatus(title, description, image)
    State.LastStatus = title
    StatusParagraph:SetTitle(title)
    StatusParagraph:SetDesc(description)
    StatusParagraph:SetImage(image)
    updateStats()
    updateSession()
end

local StatusMessages = {
    KEY_EXPIRED = {
        Title = "Key Expired",
        Desc = "This key has expired. Generate a new key and try again.",
        Icon = "clock-alert",
        Wipe = true,
    },
    KEY_BANNED = {
        Title = "Key Blacklisted",
        Desc = "This key has been disabled and cannot be used.",
        Icon = "ban",
        Wipe = true,
    },
    KEY_HWID_LOCKED = {
        Title = "HWID Mismatch",
        Desc = "This key is linked to another device. Reset its HWID before retrying.",
        Icon = "monitor-x",
        Wipe = true,
    },
    KEY_INCORRECT = {
        Title = "Key Not Found",
        Desc = "The entered key could not be found.",
        Icon = "key-square",
        Wipe = true,
    },
    KEY_INVALID = {
        Title = "Invalid Key",
        Desc = "The key format is invalid. Check the key and try again.",
        Icon = "circle-x",
        Wipe = true,
    },
    INVALID_EXECUTOR = {
        Title = "Unsupported Executor",
        Desc = "Your executor is not supported by Luarmor.",
        Icon = "shield-alert",
    },
    SCRIPT_ID_INCORRECT = {
        Title = "Configuration Error",
        Desc = "The Luarmor script configuration is incorrect.",
        Icon = "file-warning",
    },
    SCRIPT_ID_INVALID = {
        Title = "Configuration Error",
        Desc = "The Luarmor script configuration is invalid.",
        Icon = "file-warning",
    },
    SECURITY_ERROR = {
        Title = "Security Error",
        Desc = "Luarmor blocked this request for security reasons.",
        Icon = "shield-x",
    },
    TIME_ERROR = {
        Title = "Time Synchronization Error",
        Desc = "Your system time could not be verified. Correct it and try again.",
        Icon = "clock-alert",
    },
}

local function finishValidation()
    State.Busy = false

    if ValidateButton and ValidateButton.Unlock then
        ValidateButton:Unlock()
    end
end

local function loadAuthenticatedScript(key)
    if State.Loaded then
        return
    end

    State.Loaded = true
    setRuntimeKey(key)

    notify(
        "Access Granted",
        "Your key is valid. Nexus Hub is loading now.",
        "shield-check",
        4
    )

    task.delay(0.6, function()
        pcall(function()
            Window:Destroy()
        end)

        local success, result = pcall(function()
            return LuarmorAPI.load_script()
        end)

        if not success then
            State.Loaded = false
            notify(
                "Script Load Failed",
                tostring(result),
                "triangle-alert",
                7
            )
        end
    end)
end

local function handleValidationResult(key, status, autoValidation)
    local code = status and status.code or "UNKNOWN"

    if code == "KEY_VALID" then
        State.SuccessfulAttempts = State.SuccessfulAttempts + 1

        local expiry = formatExpiry(status)
        local data = status.data or {}

        State.Authenticated = true
        State.KeyExpiry = expiry
        State.KeyNote = type(data.note) == "string" and data.note ~= ""
            and data.note
            or "No note"
        State.TotalExecutions = tonumber(data.total_executions) or 0

        setStatus(
            autoValidation and "Saved Key Verified" or "Key Verified",
            "Authentication succeeded.\nAccess: " .. expiry,
            "shield-check"
        )

        local saved, saveError = saveKey(key)
        if not saved then
            notify(
                "Key Verified",
                "Authentication succeeded, but the key could not be saved: "
                    .. tostring(saveError),
                "save-off",
                6
            )
        end

        updateStats()
        loadAuthenticatedScript(key)
        return
    end

    local message = StatusMessages[code]
    State.Authenticated = false
    State.KeyExpiry = "Not authenticated"
    State.KeyNote = "Not authenticated"
    State.TotalExecutions = 0

    if message then
        if message.Wipe then
            deleteSavedKey()
        end

        setStatus(message.Title, message.Desc, message.Icon)
        notify(message.Title, message.Desc, message.Icon, 6)
    else
        local description = status and status.message
            or "Luarmor returned an unknown response."

        setStatus("Authentication Failed", description, "triangle-alert")
        notify("Authentication Failed", description, "triangle-alert", 6)
    end

    finishValidation()
end

local function validateKey(key, autoValidation)
    if State.Busy or State.Loaded then
        return
    end

    if not CurrentGame then
        setStatus(
            "Unsupported Game",
            "Nexus Hub does not have a script configured for this game.",
            "gamepad-2"
        )
        notify(
            "Unsupported Game",
            "This game is not currently supported by Nexus Hub.",
            "gamepad-2",
            6
        )
        return
    end

    local cleanKey = trim(key)
    if cleanKey == "" then
        setStatus(
            "Key Required",
            "Enter your Luarmor key before validating.",
            "key-round"
        )
        notify("Key Required", "Please enter your key first.", "key-round")
        return
    end

    State.Busy = true
    State.Attempts = State.Attempts + 1
    State.LastChecked = os.date("%H:%M:%S")
    State.EnteredKey = cleanKey

    if ValidateButton and ValidateButton.Lock then
        ValidateButton:Lock()
    end

    setStatus(
        autoValidation and "Checking Saved Key" or "Validating Key",
        "Connecting securely to Luarmor...",
        "loader-circle"
    )

    task.spawn(function()
        local success, status = pcall(function()
            return LuarmorAPI.check_key(cleanKey)
        end)

        if not success then
            setStatus(
                "Connection Failed",
                "Luarmor could not be reached. Check your connection and try again.",
                "wifi-off"
            )
            notify(
                "Connection Failed",
                tostring(status),
                "wifi-off",
                6
            )
            finishValidation()
            return
        end

        handleValidationResult(cleanKey, status, autoValidation)
    end)
end

ValidateButton = KeyCard:Button({
    Title = "Validate Key & Load",
    Desc = "Authenticate securely with Luarmor",
    Icon = "shield-check",
    Justify = "Center",
    Color = Config.Colors.Green,
    Callback = function()
        validateKey(State.EnteredKey, false)
    end,
})

KeyCard:Button({
    Title = "Get Key",
    Desc = "Copy the official Nexus Hub key link",
    Icon = "external-link",
    Justify = "Center",
    Color = Config.Colors.Yellow,
    Callback = function()
        if copyText(Config.GetKeyURL) then
            notify(
                "Key Link Copied",
                "Open the copied link to generate your key.",
                "clipboard-check"
            )
        end
    end,
})

KeyCard:Button({
    Title = "Clear Saved Key",
    Desc = "Remove the locally saved key from this executor",
    Icon = "trash-2",
    Justify = "Center",
    Color = Config.Colors.Red,
    Callback = function()
        local success, errorMessage = deleteSavedKey()

        if success then
            KeyInput:Set("")
            setStatus(
                "Saved Key Cleared",
                "The saved key has been removed from this executor.",
                "trash-2"
            )
            notify(
                "Saved Key Cleared",
                "Your saved key was removed.",
                "trash-2"
            )
        else
            notify(
                "Unable to Clear Key",
                tostring(errorMessage),
                "triangle-alert",
                6
            )
        end
    end,
})

SessionTab:Section({
    Title = "Session Information",
    TextSize = 20,
    FontWeight = Enum.FontWeight.Bold,
})

SessionTab:Space()

local OverviewCard = SessionTab:Section({
    Title = "Current Session",
    Box = true,
    BoxBorder = true,
    Opened = true,
})

OverviewCard:Paragraph({
    Title = "Current Game",
    Desc = table.concat({
        "Game: " .. getGameName(),
        "Place ID: " .. game.PlaceId,
        "Support: " .. (CurrentGame and "Available" or "Unavailable"),
        "Validation: Luarmor",
    }, "\n"),
    Image = "gamepad-2",
})

SessionParagraph = OverviewCard:Paragraph({
    Title = "No Active Session",
    Desc = "",
    Image = "badge-minus",
})

StatsParagraph = OverviewCard:Paragraph({
    Title = "Session Statistics",
    Desc = "",
    Image = "chart-no-axes-column-increasing",
})

updateStats()
updateSession()

GamesTab:Section({
    Title = "Supported Experiences",
    TextSize = 20,
    FontWeight = Enum.FontWeight.Bold,
})

GamesTab:Space()

local GamesCard = GamesTab:Section({
    Title = "Available Games",
    Box = true,
    BoxBorder = true,
    Opened = true,
})

GamesCard:Paragraph({
    Title = "Nexus Hub Compatibility",
    Desc = buildSupportedGameList(),
    Image = "library",
})

HelpTab:Section({
    Title = "Help & Support",
    TextSize = 20,
    FontWeight = Enum.FontWeight.Bold,
})

HelpTab:Space()

local HelpCard = HelpTab:Section({
    Title = "Having Trouble?",
    Box = true,
    BoxBorder = true,
    Opened = true,
})

HelpCard:Paragraph({
    Title = "Key Troubleshooting",
    Desc = "Generate a fresh key if yours has expired. If Luarmor reports an HWID mismatch, reset your HWID before trying again. Make sure your executor and system time are supported.",
    Image = "life-buoy",
})

HelpCard:Button({
    Title = "Copy Key Link",
    Icon = "clipboard-copy",
    Justify = "Center",
    Color = Config.Colors.Yellow,
    Callback = function()
        if copyText(Config.GetKeyURL) then
            notify("Link Copied", "The key link is ready to open.", "check")
        end
    end,
})

HelpCard:Button({
    Title = "Copy Discord Invite",
    Icon = "message-circle",
    Justify = "Center",
    Color = Config.Colors.Blue,
    Callback = function()
        if Config.DiscordInvite == "" then
            notify(
                "Discord Unavailable",
                "The Discord invite has not been configured yet.",
                "message-circle-x",
                5
            )
            return
        end

        if copyText(Config.DiscordInvite) then
            notify("Invite Copied", "The Discord invite was copied.", "check")
        end
    end,
})

KeyTab:Select()

task.defer(function()
    local savedKey = loadSavedKey()
    if savedKey == "" then
        return
    end

    State.EnteredKey = savedKey
    KeyInput:Set(savedKey)

    task.wait(0.2)
    validateKey(savedKey, true)
end)
