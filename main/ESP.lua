-- ESP Module (AirHub V2 Replica)
local ESPModule = {}

-- Global Variables
local ESPObjects = {}
local CrosshairParts = {}
local ServiceConnections = {}

-- Initialize Module
function ESPModule.Init(Config, Camera, LocalPlayer, Players, RunService, UserInputService, ESPObjectsTable, CrosshairPartsTable, ServiceConnectionsTable)
    ESPModule.Config = Config
    ESPModule.Camera = Camera
    ESPModule.LocalPlayer = LocalPlayer
    ESPModule.Players = Players
    ESPModule.RunService = RunService
    ESPModule.UserInputService = UserInputService
    ESPObjects = ESPObjectsTable or ESPObjects
    CrosshairParts = CrosshairPartsTable or CrosshairParts
    ServiceConnections = ServiceConnectionsTable or ServiceConnections
end

-- Helper Functions
function ESPModule.GetPlayerTable(Player)
    for _, v in next, ESPObjects do
        if v.Name == Player.Name then
            return v
        end
    end
end

function ESPModule.AssignRigType(Player)
    local PlayerTable = ESPModule.GetPlayerTable(Player)
    repeat task.wait(0) until Player.Character
    if Player.Character:FindFirstChild("Torso") and not Player.Character:FindFirstChild("LowerTorso") then
        PlayerTable.RigType = "R6"
    elseif Player.Character:FindFirstChild("LowerTorso") and not Player.Character:FindFirstChild("Torso") then
        PlayerTable.RigType = "R15"
    else
        repeat ESPModule.AssignRigType(Player) until PlayerTable.RigType
    end
end

function ESPModule.InitChecks(Player)
    local PlayerTable = ESPModule.GetPlayerTable(Player)
    PlayerTable.Connections.UpdateChecks = ESPModule.RunService.RenderStepped:Connect(function()
        if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
            if ESPModule.Config.ESP.AliveCheck then
                PlayerTable.Checks.Alive = Player.Character:FindFirstChildOfClass("Humanoid").Health > 0
            else
                PlayerTable.Checks.Alive = true
            end
            if ESPModule.Config.ESP.TeamCheck then
                PlayerTable.Checks.Team = Player.TeamColor ~= ESPModule.LocalPlayer.TeamColor
            else
                PlayerTable.Checks.Team = true
            end
        else
            PlayerTable.Checks.Alive = false
            PlayerTable.Checks.Team = false
        end
    end)
end

function ESPModule.UpdateCham(Part, Cham)
    local CorFrame, PartSize = Part.CFrame, Part.Size / 2
    if select(2, ESPModule.Camera:WorldToViewportPoint(CorFrame * CFrame.new(PartSize.X / 2, PartSize.Y / 2, PartSize.Z / 2).Position)) and ESPModule.Config.ESP.Chams.Enabled then
        for i = 1, 6 do
            local Quad = Cham["Quad"..tostring(i)]
            Quad.Transparency = ESPModule.Config.ESP.Chams.Transparency
            Quad.Color = ESPModule.Config.ESP.Chams.RainbowColor and ESPModule.GetRainbowColor() or ESPModule.Config.ESP.Chams.Color
            Quad.Thickness = ESPModule.Config.ESP.Chams.Thickness
            Quad.Filled = ESPModule.Config.ESP.Chams.Filled
            Quad.Visible = ESPModule.Config.ESP.Chams.Enabled
        end

        -- Quad 1 - Front
        local PosTopLeft = ESPModule.Camera:WorldToViewportPoint(CorFrame * CFrame.new(PartSize.X, PartSize.Y, PartSize.Z).Position)
        local PosTopRight = ESPModule.Camera:WorldToViewportPoint(CorFrame * CFrame.new(-PartSize.X, PartSize.Y, PartSize.Z).Position)
        local PosBottomLeft = ESPModule.Camera:WorldToViewportPoint(CorFrame * CFrame.new(PartSize.X, -PartSize.Y, PartSize.Z).Position)
        local PosBottomRight = ESPModule.Camera:WorldToViewportPoint(CorFrame * CFrame.new(-PartSize.X, -PartSize.Y, PartSize.Z).Position)
        Cham.Quad1.PointA = Vector2.new(PosTopLeft.X, PosTopLeft.Y)
        Cham.Quad1.PointB = Vector2.new(PosBottomLeft.X, PosBottomLeft.Y)
        Cham.Quad1.PointC = Vector2.new(PosBottomRight.X, PosBottomRight.Y)
        Cham.Quad1.PointD = Vector2.new(PosTopRight.X, PosTopRight.Y)

        -- Quad 2 - Back
        local PosTopLeft2 = ESPModule.Camera:WorldToViewportPoint(CorFrame * CFrame.new(PartSize.X, PartSize.Y, -PartSize.Z).Position)
        local PosTopRight2 = ESPModule.Camera:WorldToViewportPoint(CorFrame * CFrame.new(-PartSize.X, PartSize.Y, -PartSize.Z).Position)
        local PosBottomLeft2 = ESPModule.Camera:WorldToViewportPoint(CorFrame * CFrame.new(PartSize.X, -PartSize.Y, -PartSize.Z).Position)
        local PosBottomRight2 = ESPModule.Camera:WorldToViewportPoint(CorFrame * CFrame.new(-PartSize.X, -PartSize.Y, -PartSize.Z).Position)
        Cham.Quad2.PointA = Vector2.new(PosTopLeft2.X, PosTopLeft2.Y)
        Cham.Quad2.PointB = Vector2.new(PosBottomLeft2.X, PosBottomLeft2.Y)
        Cham.Quad2.PointC = Vector2.new(PosBottomRight2.X, PosBottomRight2.Y)
        Cham.Quad2.PointD = Vector2.new(PosTopRight2.X, PosTopRight2.Y)

        -- Quad 3 - Top
        local PosTopLeft3 = ESPModule.Camera:WorldToViewportPoint(CorFrame * CFrame.new(PartSize.X, PartSize.Y, PartSize.Z).Position)
        local PosTopRight3 = ESPModule.Camera:WorldToViewportPoint(CorFrame * CFrame.new(-PartSize.X, PartSize.Y, PartSize.Z).Position)
        local PosBottomLeft3 = ESPModule.Camera:WorldToViewportPoint(CorFrame * CFrame.new(PartSize.X, PartSize.Y, -PartSize.Z).Position)
        local PosBottomRight3 = ESPModule.Camera:WorldToViewportPoint(CorFrame * CFrame.new(-PartSize.X, PartSize.Y, -PartSize.Z).Position)
        Cham.Quad3.PointA = Vector2.new(PosTopLeft3.X, PosTopLeft3.Y)
        Cham.Quad3.PointB = Vector2.new(PosBottomLeft3.X, PosBottomLeft3.Y)
        Cham.Quad3.PointC = Vector2.new(PosBottomRight3.X, PosBottomRight3.Y)
        Cham.Quad3.PointD = Vector2.new(PosTopRight3.X, PosTopRight3.Y)

-- Quad 4 - Bottom
local PosTopLeft4 = ESPModule.Camera:WorldToViewportPoint(CorFrame * CFrame.new(PartSize.X, -PartSize.Y, PartSize.Z).Position)
local PosTopRight4 = ESPModule.Camera:WorldToViewportPoint(CorFrame * CFrame.new(-PartSize.X, -PartSize.Y, PartSize.Z).Position)
local PosBottomLeft4 = ESPModule.Camera:WorldToViewportPoint(CorFrame * CFrame.new(PartSize.X, -PartSize.Y, -PartSize.Z).Position)
local PosBottomRight4 = ESPModule.Camera:WorldToViewportPoint(CorFrame * CFrame.new(-PartSize.X, -PartSize.Y, -PartSize.Z).Position)

if PosTopLeft4 and PosTopRight4 and PosBottomLeft4 and PosBottomRight4 then
    Cham.Quad4.PointA = Vector2.new(PosTopLeft4.X, PosTopLeft4.Y)
    Cham.Quad4.PointB = Vector2.new(PosBottomLeft4.X, PosBottomLeft4.Y)
    Cham.Quad4.PointC = Vector2.new(PosBottomRight4.X, PosBottomRight4.Y)
    Cham.Quad4.PointD = Vector2.new(PosTopRight4.X, PosTopRight4.Y)
else
    for i = 1, 6 do
        Cham["Quad"..tostring(i)].Visible = false
    end
end

        -- Quad 5 - Right
        local PosTopLeft5 = ESPModule.Camera:WorldToViewportPoint(CorFrame * CFrame.new(PartSize.X, PartSize.Y, PartSize.Z).Position)
        local PosTopRight5 = ESPModule.Camera:WorldToViewportPoint(CorFrame * CFrame.new(PartSize.X, PartSize.Y, -PartSize.Z).Position)
        local PosBottomLeft5 = ESPModule.Camera:WorldToViewportPoint(CorFrame * CFrame.new(PartSize.X, -PartSize.Y, PartSize.Z).Position)
        local PosBottomRight5 = ESPModule.Camera:WorldToViewportPoint(CorFrame * CFrame.new(PartSize.X, -PartSize.Y, -PartSize.Z).Position)
        Cham.Quad5.PointA = Vector2.new(PosTopLeft5.X, PosTopLeft5.Y)
        Cham.Quad5.PointB = Vector2.new(PosBottomLeft5.X, PosBottomLeft5.Y)
        Cham.Quad5.PointC = Vector2.new(PosBottomRight5.X, PosBottomRight5.Y)
        Cham.Quad5.PointD = Vector2.new(PosTopRight5.X, PosTopRight5.Y)

        -- Quad 6 - Left
        local PosTopLeft6 = ESPModule.Camera:WorldToViewportPoint(CorFrame * CFrame.new(-PartSize.X, PartSize.Y, PartSize.Z).Position)
        local PosTopRight6 = ESPModule.Camera:WorldToViewportPoint(CorFrame * CFrame.new(-PartSize.X, PartSize.Y, -PartSize.Z).Position)
        local PosBottomLeft6 = ESPModule.Camera:WorldToViewportPoint(CorFrame * CFrame.new(-PartSize.X, -PartSize.Y, PartSize.Z).Position)
        local PosBottomRight6 = ESPModule.Camera:WorldToViewportPoint(CorFrame * CFrame.new(-PartSize.X, -PartSize.Y, -PartSize.Z).Position)
        Cham.Quad6.PointA = Vector2.new(PosTopLeft6.X, PosTopLeft6.Y)
        Cham.Quad6.PointB = Vector2.new(PosBottomLeft6.X, PosBottomLeft6.Y)
        Cham.Quad6.PointC = Vector2.new(PosBottomRight6.X, PosBottomRight6.Y)
        Cham.Quad6.PointD = Vector2.new(PosTopRight6.X, PosTopRight6.Y)
    else
        for i = 1, 6 do
            Cham["Quad"..tostring(i)].Visible = false
        end
    end
end

function ESPModule.GetRainbowColor()
    local RainbowSpeed = ESPModule.Config.ESP.RainbowSpeed or 1
    return Color3.fromHSV(tick() % RainbowSpeed / RainbowSpeed, 1, 1)
end

function ESPModule.CreateESP(Player)
    if ESPObjects[Player] or Player == ESPModule.LocalPlayer then return end

    local PlayerTable = {
        Name = Player.Name,
        Checks = {Alive = true, Team = true},
        Connections = {},
        ESP = Drawing.new("Text"),
        Tracer = Drawing.new("Line"),
        HeadDot = Drawing.new("Circle"),
        HealthBar = {Main = Drawing.new("Line"), Outline = Drawing.new("Line")},
        Box = {
            Square = Drawing.new("Square"),
            TopLeftLine = Drawing.new("Line"),
            TopRightLine = Drawing.new("Line"),
            BottomLeftLine = Drawing.new("Line"),
            BottomRightLine = Drawing.new("Line")
        },
        Chams = {}
    }
    ESPObjects[Player] = PlayerTable

    local function UpdateRig()
        for _, v in next, PlayerTable.Chams do
            for i = 1, 6 do
                local Quad = v["Quad"..tostring(i)]
                if Quad and Quad.Remove then
                    Quad:Remove()
                end
            end
        end
        if Player.Character and Player.Character:FindFirstChild("LowerTorso") then
            PlayerTable.RigType = "R15"
            PlayerTable.Chams = {
                Head = {}, UpperTorso = {}, LowerTorso = {},
                LeftLowerArm = {}, LeftUpperArm = {}, LeftHand = {},
                RightLowerArm = {}, RightUpperArm = {}, RightHand = {},
                LeftLowerLeg = {}, LeftUpperLeg = {}, LeftFoot = {},
                RightLowerLeg = {}, RightUpperLeg = {}, RightFoot = {}
            }
        elseif Player.Character and Player.Character:FindFirstChild("Torso") then
            PlayerTable.RigType = "R6"
            PlayerTable.Chams = {
                Head = {}, Torso = {},
                ["Left Arm"] = {}, ["Right Arm"] = {},
                ["Left Leg"] = {}, ["Right Leg"] = {}
            }
        end
        for _, v in next, PlayerTable.Chams do
            for i = 1, 6 do
                v["Quad"..tostring(i)] = Drawing.new("Quad")
            end
        end
    end

    ESPModule.AssignRigType(Player)
    ESPModule.InitChecks(Player)
    UpdateRig()

    if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
        local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
        PlayerTable.Connections.Died = Humanoid.Died:Connect(function()
            ESPModule.RemoveESP(Player)
        end)
    end

    local function UpdateESP()
        if not ESPObjects[Player] then return end
        if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") or not Player.Character:FindFirstChildOfClass("Humanoid") or Player.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
            ESPModule.RemoveESP(Player)
            return
        end

        if PlayerTable.Checks.Alive and PlayerTable.Checks.Team and ESPModule.Config.ESP.Enabled then
            local Character = Player.Character
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            local HumanoidRootPart = Character.HumanoidRootPart
            local Head = Character:FindFirstChild("Head")

            -- ESP Text
            if ESPModule.Config.ESP.DisplayName or ESPModule.Config.ESP.DisplayDistance or ESPModule.Config.ESP.DisplayHealth or ESPModule.Config.ESP.DisplayTool then
                local Vector, OnScreen = ESPModule.Camera:WorldToViewportPoint(Head.Position)
                PlayerTable.ESP.Visible = ESPModule.Config.ESP.Enabled and OnScreen
                if OnScreen then
                    PlayerTable.ESP.Center = true
                    PlayerTable.ESP.Size = ESPModule.Config.ESP.Size
                    PlayerTable.ESP.Outline = ESPModule.Config.ESP.Outline
                    PlayerTable.ESP.OutlineColor = ESPModule.Config.ESP.OutlineColor
                    PlayerTable.ESP.Color = ESPModule.Config.ESP.RainbowColor and ESPModule.GetRainbowColor()
                    PlayerTable.ESP.Transparency = ESPModule.Config.ESP.Transparency
                    PlayerTable.ESP.Font = Drawing.Fonts[ESPModule.Config.ESP.Font]

                    local Parts, Content, Tool = {
                        Health = "["..tostring(math.floor(Humanoid.Health)).."/"..tostring(math.floor(Humanoid.MaxHealth)).."]",
                        Distance = "["..tostring(math.floor((HumanoidRootPart.Position - (ESPModule.LocalPlayer.Character and ESPModule.LocalPlayer.Character.HumanoidRootPart.Position or Vector3.new())).Magnitude)).."]",
                        Name = ESPModule.Config.ESP.DisplayName and Player.DisplayName == Player.Name and Player.Name or Player.DisplayName.." ("..Player.Name..")"
                    }, "", Character:FindFirstChildOfClass("Tool")

                    if ESPModule.Config.ESP.DisplayName then
                        Content = Parts.Name..Content
                    end
                    if ESPModule.Config.ESP.DisplayHealth then
                        Content = Parts.Health..(Content and " " or "")..Content
                    end
                    if ESPModule.Config.ESP.DisplayDistance then
                        Content = Content..(Content and " " or "")..Parts.Distance
                    end
                    PlayerTable.ESP.Text = (Tool and "["..Tool.Name.."]\n" or "")..Content
                    PlayerTable.ESP.Position = Vector2.new(Vector.X, Vector.Y - ESPModule.Config.ESP.Size - (Tool and 10 or 0))
                else
                    PlayerTable.ESP.Visible = false
                end
            else
                PlayerTable.ESP.Visible = false
            end

            -- Tracers
            if ESPModule.Config.ESP.Tracer.Enabled then
                local HRPCFrame, HRPSize = HumanoidRootPart.Position, HumanoidRootPart.Size
                local _3DVector, OnScreen = ESPModule.Camera:WorldToViewportPoint(HRPCFrame * CFrame.new(0, -HRPSize.Y - 0.5, 0).Position)
                local _2DVector = ESPModule.Camera:WorldToViewportPoint(HumanoidRootPart.Position)
                local HeadOffset = ESPModule.Camera:WorldToViewportPoint(Head.Position + Vector3.new(0, 0.5, 0))
                local LegsOffset = ESPModule.Camera:WorldToViewportPoint(HumanoidRootPart.Position - Vector3.new(0, 1.5, 0))
                if OnScreen then
                    PlayerTable.Tracer.Visible = true
                    PlayerTable.Tracer.Thickness = ESPModule.Config.ESP.Tracer.Thickness
                    PlayerTable.Tracer.Color = ESPModule.Config.ESP.Tracer.RainbowColor and ESPModule.GetRainbowColor() or ESPModule.Config.ESP.Tracer.Color
                    PlayerTable.Tracer.Transparency = ESPModule.Config.ESP.Tracer.Transparency
                    PlayerTable.Tracer.To = ESPModule.Config.ESP.BoxType == 1 and Vector2.new(_3DVector.X, _3DVector.Y) or Vector2.new(_2DVector.X, _2DVector.Y - (HeadOffset.Y - LegsOffset.Y) * 0.5)
                    if ESPModule.Config.ESP.Tracer.Position == 1 then
                        PlayerTable.Tracer.From = Vector2.new(ESPModule.Camera.ViewportSize.X / 2, ESPModule.Camera.ViewportSize.Y)
                    elseif ESPModule.Config.ESP.Tracer.Position == 2 then
                        PlayerTable.Tracer.From = Vector2.new(ESPModule.Camera.ViewportSize.X / 2, ESPModule.Camera.ViewportSize.Y / 2)
                    elseif ESPModule.Config.ESP.Tracer.Position == 3 then
                        PlayerTable.Tracer.From = ESPModule.UserInputService:GetMouseLocation()
                    else
                        PlayerTable.Tracer.From = Vector2.new(ESPModule.Camera.ViewportSize.X / 2, ESPModule.Camera.ViewportSize.Y)
                    end
                else
                    PlayerTable.Tracer.Visible = false
                end
            else
                PlayerTable.Tracer.Visible = false
            end

            -- 3D/2D Boxes
            if ESPModule.Config.ESP.Box.Enabled then
                local Vector, OnScreen = ESPModule.Camera:WorldToViewportPoint(HumanoidRootPart.Position)
                local HRPCFrame, HRPSize = HumanoidRootPart.Position, HumanoidRootPart.Size
                local HeadOffset = ESPModule.Camera:WorldToViewportPoint(Head.Position + Vector3.new(0, 0.5, 0))
                local LegsOffset = ESPModule.Camera.WorldToViewportPoint(HumanoidRootPart.Position - Vector3.new(0, 3, 0))
                local TopLeftPosition = ESPModule.Camera.WorldToViewportPoint(HRPCFrame * CFrame.new(HRPSize.X, HRPSize.Y, 0).Position)
                local TopRightPosition = ESPModule.Camera.WorldToViewportPoint(HRPCFrame * CFrame.new(-HRPSize.X, HRPSize.Y, 0)).Position)
                local BottomLeftPosition = ESPModule.Camera.WorldToViewportPoint(HRPCFrame * CFrame.new(HRPSize.X, -HRPSize.Y - 0.5, 0)).Position
                local BottomRightPosition = ESPModule.Camera.WorldToViewportPoint(HRPCFrame * CFrame.new(-HRPSize.X, -HRPSize.Y - 0.5, 0)).Position)

                if ESPModule.Config.ESP.Box.Type == 1 then
                    -- 3D Box
                    PlayerTable.Box.Square.Visible = false
                    PlayerTable.Box.TopLeftLine.Visible = true
                    PlayerTable.Box.TopRightLine.Visible = true
                    PlayerTable.Box.BottomLeftLine.Visible = true
                    PlayerTable.Box.BottomRightLine.Visible = true

                    for _, line in ipairs({PlayerTable.Box.TopLeftLine, PlayerTable.Box.TopRightLine, PlayerTable.Box.BottomLeftLine})
                        line.Thickness = ESPModule.Config.ESP.Box.Thickness
                        line.Transparency = ESPModule.Config.ESP.Box.Transparency
                        line.Color = ESPModule.Config.ESP.Box.RainbowColor and ESPModule.GetRainbowColor() or ESPModule.Config.ESP.Box.Color
                    end

                    PlayerTable.Box.TopLeftLine.From = Vector2.new(TopLeftPosition.X, TopLeftPosition.Y)
                    PlayerTable.Box.TopLeftLine.To = Vector2.new(TopRightPosition.X, TopRightPosition.Y)
                    PlayerTable.Box.TopRightLine.From = Vector2.new(TopRightPosition.X, TopRightPosition.Y)
                    PlayerTable.Box.TopRightLine.To = Vector2.new(BottomRightPosition.X, BottomRightPosition.Y)
                    PlayerTable.Box.BottomLeftLine.From = Vector2.new(BottomLeftPosition.X, BottomLeftPosition.Y)
                    PlayerTable.Box.BottomLeftLine.To = Vector2.new(TopLeftPosition.X, TopLeftPosition.Y)
                    PlayerTable.Box.BottomRightLine.From = Vector2.new(BottomRightPosition.X, BottomRightPosition.Y)
                    To = Vector2.new(BottomLeftPosition.X, BottomLeftPosition.Y)
                else
                    -- 2D Box
                    PlayerTable.Box.Square.Visible = true
                    PlayerTable.Box.TopLeftLine.Visible = false
                    PlayerTable.Box.TopRightLine.Visible = false
                    PlayerTable.Box.BottomLeftLine.Visible = false
                    PlayerTable.Box.BottomRightLine.Visible = false

                    PlayerTable.Box.Square.Thickness = ESPModule.Config.ESP.Box.Thickness
                    PlayerTable.Box.Square.Color = ESPModule.Config.ESP.Box.RainbowColor
                    PlayerTable.Box.Square.Transparency = ESPModule.Config.ESP.Box.Transparency
                    PlayerTable.Box.Square.Filled = ESPModule.Config.ESP.Box.Filled
                    PlayerTable.Box.Square.Size = Vector2.new(2000 / Vector.Z, HeadOffset.Y - LegsOffset.Y)
                    PlayerTable.Box.Square.Position = Vector2.new(Vector.X - PlayerTable.Box.Square.Size.X / 2, Vector.Y - PlayerTable.Box.Square.Size.Y / 2)
                end
            else
                PlayerTable.Box.Square.Visible = false
                PlayerTable.Box.TopLeftLine.Visible = false
                PlayerTable.Box.TopRightLine.Visible = false
                PlayerTable.Box.BottomLeftLine.Visible = false
                PlayerTable.Box.BottomRightLine.Visible = false
            end

            -- HeadDot
            if ESPModule.Config.ESP.HeadDot.Enabled then
                local Vector, OnScreen = ESPModule.Camera:WorldToViewportPoint(Head.Position)
                PlayerTable.HeadDot.Visible = OnScreen and ESPModule.Config.ESP.Enabled
                if OnScreen then
                    PlayerTable.HeadDot.Thickness = ESPModule.Config.ESP.HeadDot.Thickness
                    PlayerTable.HeadDot.Color = ESPModule.Config.ESP.HeadDot.RainbowColor and ESPModule.GetRainbowColor() or ESPModule.Config.ESP.HeHeadDot.Color
                    PlayerTable.HeadDot.Transparency = ESPModule.Config.ESP.HeadDot.Transparency
                    PlayerTable.HeadDot.NumSides = ESPModule.Config.ESP.HeadDot.NumSides
                    PlayerTable.HeadDot.Filled = ESPModule.Config.ESP.HeadDot.Filled
                    PlayerTable.HeadDot.Position = Vector2.new(Vector.X, Vector.Y)
                    local Top, Bottom = ESPModule.Camera:WorldToViewportPoint((Head.CFrame * CFrame.new(0, Head.Size.Y / 2, 0)).Position), ESPModule.Camera.WorldToViewportPoint((Head.CFrame * CFrame.new(0, -Head.Size.Y / 2, 0)).Position)
                    PlayerTable.HeadDot.Radius = math.abs((Top - Bottom).Y) - 2
                end
            else
                PlayerTable.HeadDot.Visible = false
            end

-- HealthBar
if ESPModule.Config.ESP.HealthBar.Enabled then
    local Vector, OnScreen = ESPModule.Camera:WorldToViewportPoint(HumanoidRootPart.Position)
    local LeftPosition = ESPModule.Camera:WorldToViewportPoint(HumanoidRootPart.CFrame * CFrame.new(HumanoidRootPart.Size.X, HumanoidRootPart.Size.Y / 2, 0).Position)
    local RightPosition = ESPModule.Camera:WorldToViewportPoint(HumanoidRootPart.CFrame * CFrame.new(-HumanoidRootPart.Size.X, HumanoidRootPart.Size.Y / 2, 0).Position)
    if PlayerTable.HealthBar.Main and PlayerTable.HealthBar.Outline then
        PlayerTable.HealthBar.Main.Visible = OnScreen and ESPModule.Config.ESP.Enabled
        PlayerTable.HealthBar.Outline.Visible = OnScreen and ESPModule.Config.ESP.HealthBar.Outline
        if OnScreen then
            PlayerTable.HealthBar.Main.Thickness = ESPModule.Config.ESP.HealthBar.Thickness or 1
            PlayerTable.HealthBar.Main.Color = ESPModule.GetColorFromHealth(Humanoid.Health, Humanoid.MaxHealth)
            PlayerTable.HealthBar.Main.Transparency = ESPModule.Config.ESP.HealthBar.Transparency or 1
            PlayerTable.HealthBar.Main.Filled = true
            PlayerTable.HealthBar.Outline.Thickness = ESPModule.Config.ESP.HealthBar.OutlineThickness or 2
            PlayerTable.HealthBar.Outline.Color = ESPModule.Config.ESP.HealthBar.OutlineColor or Color3.fromRGB(0, 0, 0)
            PlayerTable.HealthBar.Outline.Transparency = ESPModule.Config.ESP.HealthBar.Transparency or 1
            local Offset = ESPModule.Config.ESP.HealthBar.Offset or 8
            if ESPModule.Config.ESP.HealthBar.Position == 1 then -- Top
                PlayerTable.HealthBar.Main.From = Vector2.new(Vector.X, Vector.Y - Offset)
                PlayerTable.HealthBar.Main.To = Vector2.new(Vector.X + (Humanoid.Health / Humanoid.MaxHealth) * 100, Vector.Y - Offset)
                PlayerTable.HealthBar.Outline.From = Vector2.new(Vector.X - 1, Vector.Y - Offset)
                PlayerTable.HealthBar.Outline.To = Vector2.new(Vector.X + 101, Vector.Y - Offset)
            elseif ESPModule.Config.ESP.HealthBar.Position == 2 then -- Bottom
                PlayerTable.HealthBar.Main.From = Vector2.new(Vector.X, Vector.Y + Size.Y + Offset)
                PlayerTable.HealthBar.Main.To = Vector2.new(Vector.X + (Humanoid.Health / Humanoid.MaxHealth) * 100, Vector.Y + Size.Y + Offset)
                PlayerTable.HealthBar.Outline.From = Vector2.new(Vector.X - 1, Vector.Y + Size.Y + Offset)
                PlayerTable.HealthBar.Outline.To = Vector2.new(Vector.X + 101, Vector.Y + Size.Y + Offset)
            elseif ESPModule.Config.ESP.HealthBar.Position == 3 then -- Left
                PlayerTable.HealthBar.Main.From = Vector2.new(LeftPosition.X - Offset, Vector.Y + Size.Y)
                PlayerTable.HealthBar.Main.To = Vector2.new(LeftPosition.X - Offset, Vector.Y - (Humanoid.Health / Humanoid.MaxHealth) * Size.Y)
                PlayerTable.HealthBar.Outline.From = Vector2.new(LeftPosition.X - Offset, Vector.Y + Size.Y + 1)
                PlayerTable.HealthBar.Outline.To = Vector2.new(LeftPosition.X - Offset, Vector.Y - Size.Y - 1)
            elseif ESPModule.Config.ESP.HealthBar.Position == 4 then -- Right
                PlayerTable.HealthBar.Main.From = Vector2.new(RightPosition.X + Offset, Vector.Y + Size.Y)
                PlayerTable.HealthBar.Main.To = Vector2.new(RightPosition.X + Offset, Vector.Y - (Humanoid.Health / Humanoid.MaxHealth) * Size.Y)
                PlayerTable.HealthBar.Outline.From = Vector2.new(RightPosition.X + Offset, Vector.Y + Size.Y + 1)
                PlayerTable.HealthBar.Outline.To = Vector2.new(RightPosition.X + Offset, Vector.Y - Size.Y - 1)
            end
        end
    end
else
    if PlayerTable.HealthBar.Main then PlayerTable.HealthBar.Main.Visible = false end
    if PlayerTable.HealthBar.Outline then PlayerTable.HealthBar.Outline.Visible = false end
end

            -- Chams
            if ESPModule.Config.ESP.Chams.Enabled then
                for _, v in next, PlayerTable.Chams do
                    if Character:FindFirstChild(_) then
                        ESPModule.UpdateCham(Character[_], v)
                    end
                end
            else
                for _, v in next, PlayerTable.Chams do
                    for i = 1, 6 do
                        v["Quad"..tostring(i)].Visible = false
                    end
                end
            end
        else
            PlayerTable.ESP.Visible = false
            PlayerTable.Tracer.Visible = false
            PlayerTable.HeadDot.Visible = false
            PlayerTable.HealthBar.Main.Visible = false
            PlayerTable.HealthBar.Outline.Visible = false
            PlayerTable.Box.Square.Visible = false
            PlayerTable.Box.TopLeftLine.Visible = false
            PlayerTable.Box.TopRightLine.Visible = false
            PlayerTable.Box.BottomLeftLine.Visible = false
            PlayerTable.Box.BottomRightLine.Visible = false
            for _, v in next, PlayerTable.Chams do
                for i = 1, 6 do
                    v["Quad"..tostring(i)].Visible = false
                end
            end
        end
    end

    PlayerTable.Connections.Update = ESPModule.RunService.Heartbeat:Connect(UpdateESP)
end

function ESPModule.RemoveESP(Player)
    local PlayerTable = ESPObjects[Player]
    if PlayerTable then
        for _, Connection in next, PlayerTable.Connections do
            if Connection then
                pcall(function() Connection:Disconnect() end)
            end
        pcall(function()
            if PlayerTable.ESP then PlayerTable.ESP:Remove() end
            if PlayerTable.Tracer then PlayerTable.Tracer:Remove() end
            if PlayerTable.HeadDot then PlayerTable.HeadDot:Remove() end
            if PlayerTable.HealthBar.Main then PlayerTable.HealthBar.Main:Remove() end
            if PlayerTable.HealthBar.Outline then PlayerTable.HealthBar.Outline:Remove() end
            for _, v in pairs(PlayerTable.Box) do
                if v and v.Remove then v:Remove() end
            end
            for _, v in pairs(PlayerTable.Chams) do
                for i = 1, 6 do
                    if v["Quad"..tostring(i)] and v["Quad"..tostring(i)].Remove then
                        v["Quad"..tostring(i)]:Remove()
                    end
                end
            end
        end)
        ESPObjects[Player] = nil
    end
end

-- Crosshair
function ESPModule.AddCrosshair()
    CrosshairParts = {
        OutlineLeftLine = Drawing.new("Line"),
        OutlineRightLine = Drawing.new("Line"),
        OutlineTopLine = Drawing.new("Line"),
        OutlineBottomLine = Drawing.new("Line"),
        OutlineCenterDot = Drawing.new("Circle"),
        LeftLine = Drawing.new("Line"),
        RightLine = Drawing.new("Line"),
        TopLine = Drawing.new("Line"),
        BottomLine = Drawing.new("Line"),
        CenterDot = Drawing.new("Circle")
    }

    local Axis, Rotation, GapSize = Vector2.new(0, 0), 0, ESPModule.Config.Crosshair.GapSize
    ServiceConnections.UpdateCrosshairAxis = ESPModule.RunService.RenderStepped:Connect(function()
        if ESPModule.Config.Crosshair.Enabled then
            if ESPModule.Config.Crosshair.Position == 1 then
                Axis = ESPModule.UserInputService:GetMouseLocation()
            elseif ESPModule.Config.Crosshair.Position == 2 then
                Axis = ESPModule.Camera.ViewportSize / 2
            end
            if ESPModule.Config.Crosshair.PulseGap then
                GapSize = math.abs(math.sin(tick() * ESPModule.Config.Crosshair.PulsingSpeed) * ESPModule.Config.Crosshair.PulsingStep)
                GapSize = math.clamp(GapSize, ESPModule.Config.Crosshair.PulsingBounds[1], ESPModule.Config.Crosshair.PulsingBounds[2])
            else
                GapSize = ESPModule.Config.Crosshair.GapSize
            end
            if ESPModule.Config.Crosshair.Rotate then
                Rotation = math.deg(tick() * ESPModule.Config.Crosshair.RotationSpeed)
                Rotation = ESPModule.Config.Crosshair.RotateClockwise and Rotation or -Rotation
            else
                Rotation = ESPModule.Config.Crosshair.Rotation
            end
        end
    end)

    ServiceConnections.UpdateCrosshair = ESPModule.RunService.RenderStepped:Connect(function()
        if ESPModule.Config.Crosshair.Enabled then
            local AxisX, AxisY = Axis.X, Axis.Y
            for _, line in ipairs({"LeftLine", "RightLine", "TopLine", "BottomLine"}) do
                CrosshairParts[line].Visible = (line ~= "TopLine" or not ESPModule.Config.Crosshair.TStyled)
                CrosshairParts[line].Color = ESPModule.Config.Crosshair.RainbowColor and ESPModule.GetRainbowColor() or ESPModule.Config.Crosshair.Color
                CrosshairParts[line].Thickness = ESPModule.Config.Crosshair.Thickness
                CrosshairParts[line].Transparency = ESPModule.Config.Crosshair.Transparency
                CrosshairParts["Outline"..line].Visible = ESPModule.Config.Crosshair.Outline and CrosshairParts[line].Visible
                CrosshairParts["Outline"..line].Color = ESPModule.Config.Crosshair.RainbowOutlineColor and ESPModule.GetRainbowColor() or ESPModule.Config.Crosshair.OutlineColor
                CrosshairParts["Outline"..line].Thickness = ESPModule.Config.Crosshair.Thickness + 1
                CrosshairParts["Outline"..line].Transparency = ESPModule.Config.Crosshair.Transparency
            end

            CrosshairParts.LeftLine.From = Vector2.new(AxisX - (math.cos(math.rad(Rotation)) * GapSize), AxisY - (math.sin(math.rad(Rotation)) * GapSize))
            CrosshairParts.LeftLine.To = Vector2.new(AxisX - (math.cos(math.rad(Rotation)) * (ESPModule.Config.Crosshair.Size + GapSize)), AxisY - (math.sin(math.rad(Rotation)) * (ESPModule.Config.Crosshair.Size + GapSize)))
            CrosshairParts.RightLine.From = Vector2.new(AxisX + (math.cos(math.rad(Rotation)) * GapSize), AxisY + (math.sin(math.rad(Rotation)) * GapSize))
            CrosshairParts.RightLine.To = Vector2.new(AxisX + (math.cos(math.rad(Rotation)) * (ESPModule.Config.Crosshair.Size + GapSize)), AxisY + (math.sin(math.rad(Rotation)) * (ESPModule.Config.Crosshair.Size + GapSize)))
            CrosshairParts.TopLine.From = Vector2.new(AxisX - (math.sin(math.rad(-Rotation)) * GapSize), AxisY - (math.cos(math.rad(-Rotation)) * GapSize))
            CrosshairParts.TopLine.To = Vector2.new(AxisX - (math.sin(math.rad(-Rotation)) * (ESPModule.Config.Crosshair.Size + GapSize)), AxisY - (math.cos(math.rad(-Rotation)) * (ESPModule.Config.Crosshair.Size + GapSize)))
            CrosshairParts.BottomLine.From = Vector2.new(AxisX + (math.sin(math.rad(-Rotation)) * GapSize), AxisY + (math.cos(math.rad(-Rotation)) * GapSize))
            CrosshairParts.BottomLine.To = Vector2.new(AxisX + (math.sin(math.rad(-Rotation)) * (ESPModule.Config.Crosshair.Size + GapSize)), AxisY + (math.cos(math.rad(-Rotation)) * (ESPModule.Config.Crosshair.Size + GapSize)))

            CrosshairParts["OutlineLeftLine"].From = CrosshairParts.LeftLine.From
            CrosshairParts["OutlineLeftLine"].To = CrosshairParts.LeftLine.To
            CrosshairParts["OutlineRightLine"].From = CrosshairParts.RightLine.From
            CrosshairParts["OutlineRightLine"].To = CrosshairParts.RightLine.To
            CrosshairParts["OutlineTopLine"].From = CrosshairParts.TopLine.From
            CrosshairParts["OutlineTopLine"].To = CrosshairParts.TopLine.To
            CrosshairParts["OutlineBottomLine"].From = CrosshairParts.BottomLine.From
            CrosshairParts["OutlineBottomLine"].To = CrosshairParts.BottomLine.To

            CrosshairParts.CenterDot.Visible = ESPModule.Config.Crosshair.CenterDot.Enabled
            CrosshairParts.CenterDot.Color = ESPModule.Config.Crosshair.CenterDot.RainbowColor and ESPModule.GetRainbowColor() or ESPModule.Config.Crosshair.CenterDot.Color
            CrosshairParts.CenterDot.Radius = ESPModule.Config.Crosshair.CenterDot.Radius
            CrosshairParts.CenterDot.Transparency = ESPModule.Config.Crosshair.CenterDot.Transparency
            CrosshairParts.CenterDot.Filled = ESPModule.Config.Crosshair.CenterDot.Filled
            CrosshairParts.CenterDot.Thickness = ESPModule.Config.Crosshair.CenterDot.Thickness
            CrosshairParts.CenterDot.Position = Vector2.new(AxisX, AxisY)
            CrosshairParts.OutlineCenterDot.Visible = ESPModule.Config.Crosshair.CenterDot.Enabled and ESPModule.Config.Crosshair.CenterDot.Outline
            CrosshairParts.OutlineCenterDot.Color = ESPModule.Config.Crosshair.CenterDot.RainbowOutlineColor and ESPModule.GetRainbowColor() or ESPModule.Config.Crosshair.CenterDot.OutlineColor
            CrosshairParts.OutlineCenterDot.Radius = ESPModule.Config.Crosshair.CenterDot.Radius
            CrosshairParts.OutlineCenterDot.Transparency = ESPModule.Config.Crosshair.CenterDot.Transparency
            CrosshairParts.OutlineCenterDot.Filled = ESPModule.Config.Crosshair.CenterDot.Filled
            CrosshairParts.OutlineCenterDot.Thickness = ESPModule.Config.Crosshair.CenterDot.Thickness + 1
            CrosshairParts.OutlineCenterDot.Position = Vector2.new(AxisX, AxisY)
        else
            for _, line in pairs(CrosshairParts) do
                line.Visible = false
            end
        end
    end)
end

function ESPModule.GetColorFromHealth(Health, MaxHealth)
    local Blue = ESPModule.Config.ESP.HealthBar.Blue or 50
    return Color3.fromRGB(255 - math.floor(Health / MaxHealth * 255), math.floor(Health / MaxHealth * 255), Blue)
end

return ESPModule
