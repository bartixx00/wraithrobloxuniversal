return {
    Config = {
        AimBot = {
            Enabled = false,
            TeamCheck = true,
            WallCheck = true,
            SilentAim = false,
            Prediction = false,
            PredictionFactor = 0.1,
            FOV = 100,
            FOVVisible = true,
            FOVColor = Color3.fromRGB(255, 0, 0),
            Smoothness = 1,
            BoneSelection = {"Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso"},
            CurrentBone = "Head"
        },
        ESP = {
            Enabled = false,
            ShowBox = true,
            ShowName = true,
            ShowHealth = true,
            ShowDistance = true,
            ShowChams = false,
            TeamCheck = true,
            AliveCheck = true,
            BoxColor = Color3.fromRGB(255, 0, 0),
            NameColor = Color3.fromRGB(255, 255, 255),
            HealthColor = Color3.fromRGB(0, 255, 0),
            DistanceColor = Color3.fromRGB(255, 255, 255),
            ChamsColor = Color3.fromRGB(255, 0, 0),
            ChamsTransparency = 0.5,
            ChamsFilled = true
        },
        Crosshair = {
            Enabled = false,
            Size = 5,
            Thickness = 2,
            Color = Color3.fromRGB(255, 0, 0),
            GapSize = 3,
            Spin = false,
            SpinSpeed = 2
        },
        TriggerBot = {
            Enabled = false,
            TeamCheck = true,
            WallCheck = true,
            Delay = 0.1,
            TargetBone = "Head"
        },
        AntiAim = {
            Enabled = false,
            Pitch = 0,
            Yaw = 0,
            Roll = 0
        }
    },
    CurrentTarget = nil,
    AimConnection = nil,
    SilentAimTarget = nil,
    FOVCircle = nil,
    ESPObjects = {},
    CrosshairParts = {},
    ServiceConnections = {},
    TriggerConnection = nil,
    LastShot = 0,
    AntiAimConnection = nil
}
