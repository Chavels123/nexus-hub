local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Config = {
	Title     = "Nexus Hub  |  Key System",
	Folder    = "NexusHub",
	LoaderUrl = "https://auth.syscure.vip/loader/4b59a71440cc4caaf9e33fc8.lua",
	Colors    = {
		Purple = Color3.fromHex("#7775F2"),
		Green  = Color3.fromHex("#30FF6A"),
		Yellow = Color3.fromHex("#ECA201"),
		Blue   = Color3.fromHex("#257AF7"),
	},
}

local enteredKey = ""

local function Notify(title, content, icon, duration)
	WindUI:Notify({
		Title    = title,
		Content  = content,
		Icon     = icon,
		Duration = duration or 4,
	})
end

local Window = WindUI:CreateWindow({
	Title         = Config.Title,
	Folder        = Config.Folder,
	Icon          = "key",
	NewElements   = true,
	HideSearchBar = true,
	OpenButton = {
		Title           = "Nexus Hub",
		CornerRadius    = UDim.new(1, 0),
		StrokeThickness = 2,
		Enabled         = true,
		Draggable       = true,
		OnlyMobile      = false,
		Scale           = 0.5,
		Color           = ColorSequence.new(Config.Colors.Purple, Config.Colors.Green),
	},
	Topbar = {
		Height      = 44,
		ButtonsType = "Mac",
	},
})

local AuthSection = Window:Section({ Title = "Authentication" })

local KeyTab = AuthSection:Tab({
	Title     = "Enter Key",
	Icon      = "solar:password-minimalistic-input-bold",
	IconColor = Config.Colors.Purple,
	IconShape = "Square",
	Border    = true,
})

local InfoTab = AuthSection:Tab({
	Title     = "Information",
	Icon      = "solar:info-square-bold",
	IconColor = Config.Colors.Blue,
	IconShape = "Square",
	Border    = true,
})

local InputSection = KeyTab:Section({
	Title = "Enter Your Key",
	Desc  = "Paste your Nexus key below to authenticate.",
})

InputSection:Space()

InputSection:Input({
	Title    = "Nexus Key",
	Desc     = "Enter your valid key here",
	Icon     = "key",
	Callback = function(value)
		enteredKey = value
	end,
})

InputSection:Space()

InputSection:Button({
	Title    = "Submit Key & Load",
	Icon     = "check",
	Justify  = "Center",
	Color    = Config.Colors.Green,
	Callback = function()
		if enteredKey == "" then
			Notify("No Key Found", "Please enter your Nexus key above first.", "solar:danger-bold", 5)
			return
		end

		Notify("Loading...", "Authenticating and loading Nexus Hub...", "solar:check-square-bold", 3)

		_G.ScriptKey = enteredKey
		loadstring(game:HttpGet(Config.LoaderUrl))()
	end,
})

InputSection:Space()

InputSection:Button({
	Title    = "Get Key",
	Icon     = "external-link",
	Justify  = "Center",
	Color    = Config.Colors.Yellow,
	Callback = function()
		setclipboard("")
		Notify("Key Copied", "The key link has been copied to your clipboard.", "solar:check-square-bold", 5)
	end,
})

local InfoSection = InfoTab:Section({
	Title = "Information",
	Desc  = "Information about Nexus Hub.",
})

InfoSection:Space()

InfoSection:Button({
	Title    = "Join our Discord Server",
	Icon     = "external-link",
	Justify  = "Center",
	Color    = Config.Colors.Yellow,
	Callback = function()
		setclipboard("")
		Notify("Discord Link Copied", "The discord link has been copied to your clipboard.", "solar:check-square-bold", 5)
	end,
})
