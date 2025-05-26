-- ESP Module
local ESPModule = {}

-- Global Variables
local ESPObjects = {}
local CrosshairParts = {}
local ServiceConnections = {}

-- Initialize Module
function ESPModule.Init(Config, Camera, LocalPlayer, Players, RunService, ESPObjectsTable, CrosshairPartsTable, ServiceConnectionsTable)
    ESPModule.Config = Config
    ESPModule.Camera = Camera
    ESPModule.LocalPlayer = LocalPlayer
    ESPModule.Players = Players
    ESPModule.RunService = RunService
    ESPObjects = ESPObjectsTable
    CrosshairParts = CrosshairPartsTable
    ServiceConnections = ServiceConnectionsTable
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
    if select(2, ESPModule.Camera:WorldToViewportPoint(CorFrame * CFrame.new(PartSize.X / 2, PartSize.Y / 2, PartSize.Z / 2).Position)) and ESPModule.Config.ESP.ShowChams then
        for i = 1, 6 do
            local Quad = Cham["Quad"..tostring(i)]
            Quad.Transparency = ESPModule.Config.ESP.ChamsTransparency
            Quad.Color = ESPModule.Config.ESP.ChamsColor
            Quad.Thickness = 0
            Quad.Filled = ESPModule.Config.ESP.ChamsFilled
            Quad.Visible = ESPModule.Config.ESP.ShowChams
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
        Cham.Quad4.PointA = Vector2.new(PosTopLeft4.X, PosTopLeft4.Y)
        Cham.Quad4.PointB = Vector2.new(PosBottomLeft4.X, PosBottomLeft4.Y)
        Cham.Quad4.PointC = Vector2.new(PosBottomRight4.X, PosBottomRight4.Y)
        Cham.Quad4.PointD = Vector2.new(PosTopRight4.X, PosTopRight4.Y)

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

function ESPModule.CreateESP(Player)
    if ESPObjects[Player] or Player == ESPModule.LocalPlayer then return end

    local PlayerTable = {
        Name = Player.Name,
        Checks = {Alive = true, Team = true},
        Connections = {},
        ESP = Drawing.new("Text"),
        Tracer = Drawing.new("Line"),
        HeadDot = Drawing.new("Circle"),
        HealthBar = {Main = Drawing.new("Square"), Outline = Drawing.new("Square")},
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
            if ESPModule.Config.ESP.ShowNames or ESPModule.Config.ESP.ShowDistance or ESPModule.Config.ESP.ShowHealth then
                local Vector, OnScreen = ESPModule.Camera:WorldToViewportPoint(Head.Position)
                PlayerTable.ESP.Visible = ESPModule.Config.ESP.Enabled
                if OnScreen and ESPModule.Config.ESP.Enabled then
                    PlayerTable.ESP.Center = true
                    PlayerTable.ESP.Size = ESPModule.Config.ESP.TextSize
                    PlayerTable.ESP.Outline = ESPModule.Config.ESP.TextOutline
                    PlayerTable.ESP.OutlineColor = ESPModule.Config.ESP.TextOutlineColor
                    PlayerTable.ESP.Color = ESPModule.Config.ESP.TextColor
                    PlayerTable.ESP.Transparency = ESPModule.Config.ESP.TextTransparency
                    PlayerTable.ESP.Font = Drawing.Fonts.UI

                    local Parts, Content, Tool = {
                        Health = "("..tostring(math.floor(Humanoid.Health))..")",
                        Distance = "["..tostring(math.floor((HumanoidRootPart.Position - (ESPModule.LocalPlayer.Character and ESPModule.LocalPlayer.Character.HumanoidRootPart.Position or Vector3.new())).Magnitude)).."]",
                        Name = Player.DisplayName == Player.Name and Player.Name or Player.DisplayName.." {"..Player.Name.."}"
                    }, "", Character:FindFirstChildOfClass("Tool")

                    if ESPModule.Config.ESP.ShowNames then
                        Content = Parts.Name..Content
                    end
                    if ESPModule.Config.ESP.ShowHealth then
                        Content = Parts.Health..(ESPModule.Config.ESP.ShowNames and " " or "")..Content
                    end
                    if ESPModule.Config.ESP.ShowDistance then
                        Content = Content.." "..Parts.Distance
                    end
                    PlayerTable.ESP.Text = (Tool and "["..Tool.Name.."]\n" or "")..Content
                    PlayerTable.ESP.Position = Vector2.new(Vector.X, Vector.Y - 20 - (Tool and 10 or 0))
                else
                    PlayerTable.ESP.Visible = false
                end
            else
                PlayerTable.ESP.Visible = false
            end

            -- Tracers
            if ESPModule.Config.ESP.ShowTracers then
                local HRPCFrame, HRPSize = HumanoidRootPart.CFrame, HumanoidRootPart.Size
                local _3DVector, OnScreen = ESPModule.Camera:WorldToViewportPoint(HRPCFrame * CFrame.new(0, -HRPSize.Y - 0.5, 0).Position)
                local _2DVector = ESPModule.Camera:WorldToViewportPoint(HumanoidRootPart.Position)
                local HeadOffset = ESPModule.Camera:WorldToViewportPoint(Head.Position + Vector3.new(0, 0.5, 0))
                local LegsOffset = ESPModule.Camera:WorldToViewportPoint(HumanoidRootPart.Position - Vector3.new(0, 1.5, 0))
                if OnScreen then
                    PlayerTable.Tracer.Visible = true
                    PlayerTable.Tracer.Thickness = 1
                    PlayerTable.Tracer.Color = ESPModule.Config.ESP.TracerColor
                    PlayerTable.Tracer.Transparency = 0.7
                    PlayerTable.Tracer.To = ESPModule.Config.ESP.BoxType == 1 and Vector2.new(_3DVector.X, _3DVector.Y) or Vector2.new(_2DVector.X, _2DVector.Y - (HeadOffset.Y - LegsOffset.Y) * 0.75)
                    if ESPModule.Config.ESP.TracerType == 1 then
                        PlayerTable.Tracer.From = Vector2.new(ESPModule.Camera.ViewportSize.X / 2, ESPModule.Camera.ViewportSize.Y)
                    elseif ESPModule.Config.ESP.TracerType == 2 then
                        PlayerTable.Tracer.From = Vector2.new(ESPModule.Camera.ViewportSize.X / 2, ESPModule.Camera.ViewportSize.Y / 2)
                    elseif ESPModule.Config.ESP.TracerType == 3 then
                        PlayerTable.Tracer.From = Vector2.new(ESPModule.UserInputService:GetMouseLocation().X, ESPModule.UserInputService:GetMouseLocation().Y)
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
            if ESPModule.Config.ESP.Show3DBoxes then
                local Vector, OnScreen = ESPModule.Camera:WorldToViewportPoint(HumanoidRootPart.Position)
                local HRPCFrame, HRPSize = HumanoidRootPart.CFrame, HumanoidRootPart.Size
                local HeadOffset = ESPModule.Camera:WorldToViewportPoint(Head.Position + Vector3.new(0, 0.5, 0))
                local LegsOffset = ESPModule.Camera:WorldToViewportPoint(HumanoidRootPart.Position - Vector3.new(0, 3, 0))
                local TopLeftPosition = ESPModule.Camera:WorldToViewportPoint(HRPCFrame * CFrame.new(HRPSize.X, HRPSize.Y, 0).Position)
                local TopRightPosition = ESPModule.Camera:WorldToViewportPoint(HRPCFrame * CFrame.new(-HRPSize.X, HRPSize.Y, 0).Position)
                local BottomLeftPosition = ESPModule.Camera:WorldToViewportPoint(HRPCFrame * CFrame.new(HRPSize.X, -HRPSize.Y - 0.5, 0).Position)
                local BottomRightPosition = ESPModule.Camera:WorldToViewportPoint(HRPCFrame * CFrame.new(-HRPSize.X, -HRPSize.Y - 0.5, 0).Position)

                if ESPModule.Config.ESP.BoxType == 1 then
                    PlayerTable.Box.Square.Visible = false
                    PlayerTable.Box.TopLeftLine.Visible = true
                    PlayerTable.Box.TopRightLine.Visible = true
                    PlayerTable.Box.BottomLeftLine.Visible = true
                    PlayerTable.Box.BottomRightLine.Visible = true

                    for _, line in pairs({PlayerTable.Box.TopLeftLine, PlayerTable.Box.TopRightLine, PlayerTable.Box.BottomLeftLine, PlayerTable.Box.BottomRightLine}) do
                        line.Thickness = 1
                        line.Transparency = 0.7
                        line.Color = ESPModule.Config.ESP.BoxColor
                    end

                    PlayerTable.Box.TopLeftLine.From = Vector2.new(TopLeftPosition.X, TopLeftPosition.Y)
                    PlayerTable.Box.TopLeftLine.To = Vector2.new(TopRightPosition.X, TopRightPosition.Y)
                    PlayerTable.Box.TopRightLine.From = Vector2.new(TopRightPosition.X, TopRightPosition.Y)
                    PlayerTable.Box.TopRightLine.To = Vector2.new(BottomRightPosition.X, BottomRightPosition.Y)
                    PlayerTable.Box.BottomLeftLine.From = Vector2.new(BottomLeftPosition.X, BottomLeftPosition.Y)
                    PlayerTable.Box.BottomLeftLine.To = Vector2.new(TopLeftPosition.X, TopLeftPosition.Y)
                    PlayerTable.Box.BottomRightLine.From = Vector2.new(BottomRightPosition.X, BottomRightPosition.Y)
                    PlayerTable.Box.BottomRightLine.To = Vector2.new(BottomLeftPosition.X, BottomLeftPosition.Y)
                else
                    PlayerTable.Box.Square.Visible = true
                    PlayerTable.Box.TopLeftLine.Visible = false
                    PlayerTable.Box.TopRightLine.Visible = false
                    PlayerTable.Box.BottomLeftLine.Visible = false
                    PlayerTable.Box.BottomRightLine.Visible = false

                    PlayerTable.Box.Square.Thickness = 1
                    PlayerTable.Box.Square.Color = ESPModule.Config.ESP.BoxColor
                    PlayerTable.Box.Square.Transparency = 0.7
                    PlayerTable.Box.Square.Filled = false
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
            if ESPModule.Config.ESP.ShowHeadDots then
                local Vector, OnScreen = ESPModule.Camera:WorldToViewportPoint(Head.Position)
                PlayerTable.HeadDot.Visible = OnScreen and ESPModule.Config.ESP.Enabled
                if OnScreen then
                    PlayerTable.HeadDot.Thickness = 1
                    PlayerTable.HeadDot.Color = ESPModule.Config.ESP.HeadDotColor
                    PlayerTable.HeadDot.Transparency = ESPModule.Config.ESP.HeadDotTransparency
                    PlayerTable.HeadDot.NumSides = 30
                    PlayerTable.HeadDot.Filled = false
                    PlayerTable.HeadDot.Position = Vector2.new(Vector.X, Vector.Y)
                    local Top, Bottom = ESPModule.Camera:WorldToViewportPoint((Head.CFrame * CFrame.new(0, Head.Size.Y / 2, 0)).Position), ESPModule.Camera:WorldToViewportPoint((Head.CFrame * CFrame.new(0, -Head.Size.Y / 2, 0)).Position)
                    PlayerTable.HeadDot.Radius = math.abs((Top - Bottom).Y) - 3
                else
                    PlayerTable.HeadDot.Visible = false
                end
            else
                PlayerTable.HeadDot.Visible = false
            end

            -- HealthBar
            if ESPModule.Config.ESP.ShowHealth then
                local Vector, OnScreen = ESPModule.Camera:WorldToViewportPoint(HumanoidRootPart.Position)
                local LeftPosition = ESPModule.Camera:WorldToViewportPoint(HumanoidRootPart.CFrame * CFrame.new(HumanoidRootPart.Size.X, HumanoidRootPart.Size.Y / 2, 0).Position)
                local RightPosition = ESPModule.Camera:WorldToViewportPoint(HumanoidRootPart.CFrame * CFrame.new(-HumanoidRootPart.Size.X, HumanoidRootPart.Size.Y / 2, 0).Position)
                PlayerTable.HealthBar.Main.Visible = OnScreen and ESPModule.Config.ESP.Enabled
                PlayerTable.HealthBar.Outline.Visible = OnScreen and ESPModule.Config.ESP.Enabled
                if OnScreen then
                    PlayerTable.HealthBar.Main.Thickness = 1
                    PlayerTable.HealthBar.Main.Color = Color3.fromRGB(255 - math.floor(Humanoid.Health / 100 * 255), math.floor(Humanoid.Health / 100 * 255), 50)
                    PlayerTable.HealthBar.Main.Transparency = 0.8
                    PlayerTable.HealthBar.Main.Filled = true
                    PlayerTable.HealthBar.Main.ZIndex = 2
                    PlayerTable.HealthBar.Outline.Thickness = 3
                    PlayerTable.HealthBar.Outline.Color = Color3.fromRGB(0, 0, 0)
                    PlayerTable.HealthBar.Outline.Transparency = 0.8
                    PlayerTable.HealthBar.Outline.Filled = false
                    PlayerTable.HealthBar.Main.ZIndex = 1
                    PlayerTable.HealthBar.Outline.Size = Vector2.new(2, 2500 / Vector.Z)
                    PlayerTable.HealthBar.Main.Size = Vector2.new(2, PlayerTable.HealthBar.Outline.Size.Y * (Humanoid.Health / 100))
                    PlayerTable.HealthBar.Main.Position = Vector2.new(LeftPosition.X - 10, Vector.Y - PlayerTable.HealthBar.Outline.Size.Y / 2)
                    PlayerTable.HealthBar.Outline.Position = PlayerTable.HealthBar.Main.Position
                else
                    PlayerTable.HealthBar.Main.Visible = false
                    PlayerTable.HealthBar.Outline.Visible = false
                end
            else
                PlayerTable.HealthBar.Main.Visible = false
                PlayerTable.HealthBar.Outline.Visible = false
            end

            -- Chams
            if ESPModule.Config.ESP.ShowChams then
                for i, v in next, PlayerTable.Chams do
                    if Character:FindFirstChild(i) then
                        ESPModule.UpdateCham(Character[i], v)
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
        for _, Connection in pairs(PlayerTable.Connections) do
            if Connection then
                pcall(function() Connection:Disconnect() end)
            end
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
    local AxisX, AxisY = ESPModule.Camera.ViewportSize.X / 2, ESPModule.Camera.ViewportSize.Y / 2
    ServiceConnections.AxisConnection = ESPModule.RunService.RenderStepped:Connect(function()
        if ESPModule.Config.Crosshair.Enabled then
            if ESPModule.Config.Crosshair.Type == 1 then
                AxisX, AxisY = ESPModule.UserInputService:GetMouseLocation().X, ESPModule.UserInputService:GetMouseLocation().Y
            elseif ESPModule.Config.Crosshair.Type == 2 then
                AxisX, AxisY = ESPModule.Camera.ViewportSize.X / 2, ESPModule.Camera.ViewportSize.Y / 2
            end
        end
    end)
    ServiceConnections.CrosshairConnection = ESPModule.RunService.RenderStepped:Connect(function()
        if ESPModule.Config.Crosshair.Enabled then
            for _, line in pairs({CrosshairParts.LeftLine, CrosshairParts.RightLine, CrosshairParts.TopLine, CrosshairParts.BottomLine}) do
                line.Visible = true
                line.Color = ESPModule.Config.Crosshair.Color
                line.Thickness = ESPModule.Config.Crosshair.Thickness
                line.Transparency = ESPModule.Config.Crosshair.Transparency
            end
            CrosshairParts.LeftLine.From = Vector2.new(AxisX - (math.cos(math.rad(ESPModule.Config.Crosshair.Rotation)) * ESPModule.Config.Crosshair.GapSize), AxisY - (math.sin(math.rad(ESPModule.Config.Crosshair.Rotation)) * ESPModule.Config.Crosshair.GapSize))
            CrosshairParts.LeftLine.To = Vector2.new(AxisX - (math.cos(math.rad(ESPModule.Config.Crosshair.Rotation)) * (ESPModule.Config.Crosshair.Size + ESPModule.Config.Crosshair.GapSize)), AxisY - (math.sin(math.rad(ESPModule.Config.Crosshair.Rotation)) * (ESPModule.Config.Crosshair.Size + ESPModule.Config.Crosshair.GapSize)))
            CrosshairParts.RightLine.From = Vector2.new(AxisX + (math.cos(math.rad(ESPModule.Config.Crosshair.Rotation)) * ESPModule.Config.Crosshair.GapSize), AxisY + (math.sin(math.rad(ESPModule.Config.Crosshair.Rotation)) * ESPModule.Config.Crosshair.GapSize))
            CrosshairParts.RightLine.To = Vector2.new(AxisX + (math.cos(math.rad(ESPModule.Config.Crosshair.Rotation)) * (ESPModule.Config.Crosshair.Size + ESPModule.Config.Crosshair.GapSize)), AxisY + (math.sin(math.rad(ESPModule.Config.Crosshair.Rotation)) * (ESPModule.Config.Crosshair.Size + ESPModule.Config.Crosshair.GapSize)))
            CrosshairParts.TopLine.From = Vector2.new(AxisX - (math.sin(math.rad(-ESPModule.Config.Crosshair.Rotation)) * ESPModule.Config.Crosshair.GapSize), AxisY - (math.cos(math.rad(-ESPModule.Config.Crosshair.Rotation)) * ESPModule.Config.Crosshair.GapSize))
            CrosshairParts.TopLine.To = Vector2.new(AxisX - (math.sin(math.rad(-ESPModule.Config.Crosshair.Rotation)) * (ESPModule.Config.Crosshair.Size + ESPModule.Config.Crosshair.GapSize)), AxisY - (math.cos(math.rad(-ESPModule.Config.Crosshair.Rotation)) * (ESPModule.Config.Crosshair.Size + ESPModule.Config.Crosshair.GapSize)))
            CrosshairParts.BottomLine.From = Vector2.new(AxisX + (math.sin(math.rad(-ESPModule.Config.Crosshair.Rotation)) * ESPModule.Config.Crosshair.GapSize), AxisY + (math.cos(math.rad(-ESPModule.Config.Crosshair.Rotation)) * ESPModule.Config.Crosshair.GapSize))
            CrosshairParts.BottomLine.To = Vector2.new(AxisX + (math.sin(math.rad(-ESPModule.Config.Crosshair.Rotation)) * (ESPModule.Config.Crosshair.Size + ESPModule.Config.Crosshair.GapSize)), AxisY + (math.cos(math.rad(-ESPModule.Config.Crosshair.Rotation)) * (ESPModule.Config.Crosshair.Size + ESPModule.Config.Crosshair.GapSize)))
            CrosshairParts.CenterDot.Visible = ESPModule.Config.Crosshair.CenterDot
            CrosshairParts.CenterDot.Color = ESPModule.Config.Crosshair.CenterDotColor
            CrosshairParts.CenterDot.Radius = ESPModule.Config.Crosshair.CenterDotSize
            CrosshairParts.CenterDot.Transparency = ESPModule.Config.Crosshair.CenterDotTransparency
            CrosshairParts.CenterDot.Filled = ESPModule.Config.Crosshair.CenterDotFilled
            CrosshairParts.CenterDot.Thickness = ESPModule.Config.Crosshair.CenterDotThickness
            CrosshairParts.CenterDot.Position = Vector2.new(AxisX, AxisY)
        else
            for _, line in pairs({CrosshairParts.LeftLine, CrosshairParts.RightLine, CrosshairParts.TopLine, CrosshairParts.BottomLine, CrosshairParts.CenterDot}) do
                line.Visible = false
            end
        end
    end)
end

return ESPModule
