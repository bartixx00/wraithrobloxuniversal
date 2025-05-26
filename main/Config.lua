local Config = {
    AimBot = {
        Enabled = false,
        TeamCheck = true,
        WallCheck = true,
        FOV = 100,
        Smoothness = 5,
        TargetPart = "Head",
        SilentAim = false,
        Prediction = false,
        PredictionFactor = 0.135,
        BoneSelection = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
        CurrentBone = "Head",
        FOVColor = Color3.fromRGB(255, 0, 0),
        FOVVisible = true
    },
    ESP = {
        Enabled = false,
        TeamCheck = true,
        AliveCheck = true,
        ShowNames = true,
        ShowDistance = true,
        ShowHealth = true,
        ShowTracers = true,
        Show3DBoxes = true,
        ShowChams = false,
        ShowHeadDots = false,
        BoxColor = Color3.fromRGB(255, 0, 0),
        TracerColor = Color3.fromRGB(255, 255, 0),
        ChamsColor = Color3.fromRGB(255, 255, 255),
        ChamsTransparency = 0.2,
        ChamsFilled = true,
        HeadDotColor = Color3.fromRGB(255, 255, 255),
        HeadDotTransparency = 0.5,
        TextColor = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextOutline = true,
        TextOutlineColor = Color3.fromRGB(0, 0, 0),
        TextTransparency = 0.7,
        TracerType = 1, -- 1: Bottom, 2: Center, 3: Mouse
        BoxType = 1 -- 1: 3D, 2: 2D
    },
    Crosshair = {
        Enabled = false,
        Type = 1, -- 1: Mouse, 2: Center
        Size = 12,
        Thickness = 1,
        Color = Color3.fromRGB(0, 255, 0),
        Transparency = 1,
        GapSize = 5,
        Rotation = 0,
        CenterDot = false,
        CenterDotColor = Color3.fromRGB(0, 255, 0),
        CenterDotSize = 1,
        CenterDotTransparency = 1,
        CenterDotFilled = true,
        CenterDotThickness = 1
    },
    TriggerBot = {
        Enabled = false,
        Delay = 0.05,
        FireKey = Enum.UserInputType.MouseButton1
    },
    AntiAim = {
        Enabled = false,
        Type = "Spin",
        Speed = 10
    }
}

local ESPObjects = {}
local CurrentTarget = nil
local AimConnection = nil
local TriggerConnection = nil
local FOVCircle = nil
local LastShot = 0
local AntiAimConnection = nil
local SilentAimTarget = nil
local CrosshairParts = {
    LeftLine = Drawing.new("Line"),
    RightLine = Drawing.new("Line"),
    TopLine = Drawing.new("Line"),
    BottomLine = Drawing.new("Line"),
    CenterDot = Drawing.new("Circle")
}
local ServiceConnections = {}

return {
    Config = Config,
    ESPObjects = ESPObjects,
    CurrentTarget = CurrentTarget,
    AimConnection = AimConnection,
    TriggerConnection = TriggerConnection,
    FOVCircle = FOVCircle,
    LastShot = LastShot,
    AntiAimConnection = AntiAimConnection,
    SilentAimTarget = SilentAimTarget,
    CrosshairParts = CrosshairParts,
    ServiceConnections = ServiceConnections
}
