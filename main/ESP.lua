local ESPModule = {}

-- Global Variables
local ESPObjects = {}
local CrosshairParts = {}
local ServiceConnections = {}
local QuadSupported = pcall(function() return Drawing.new("Quad") end) -- Check if Quad is supported

-- Initialize Module
function ESPModule.Init(Config, Camera, LocalPlayer, Players, RunService, UserInputService, ESPObjectsTable, CrosshairPartsTable, ServiceConnectionsTable)
    print("Initializing ESPModule...")
    print("Config:", Config)
    print("Camera:", Camera)
    print("LocalPlayer:", LocalPlayer)
    print("Players:", Players)
    print("RunService:", RunService)
    print("UserInputService:", UserInputService)
    print("ESPObjectsTable:", ESPObjectsTable)
    print("CrosshairPartsTable:", CrosshairPartsTable)
    print("ServiceConnectionsTable:", ServiceConnectionsTable)

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
    return ESPObjects[Player]
end

function ESPModule.AssignRigType(Player)
    local PlayerTable = ESPModule.GetPlayerTable(Player)
    if not PlayerTable then return end
    
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
    if not PlayerTable then return end
    
    PlayerTable.Connections.UpdateChecks = ESPModule.RunService.RenderStepped:Connect(function()
        local success, err = pcall(function()
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
        if not success then
            warn("Error in UpdateChecks for player " .. Player.Name .. ": " .. tostring(err))
        end
    end)
end

function ESPModule.UpdateCham(Part, Cham)
    if not QuadSupported then
        warn("Executor does not support Quad. Skipping chams.")
        return
    end
    if not Part or not ESPModule.Camera then
        warn("Part or Camera is nil in UpdateCham!")
        for i = 1, 6 do
            if Cham["Quad"..tostring(i)] then
                Cham["Quad"..tostring(i)].Visible = false
            end
        end
        return
    end

    local CorFrame, PartSize = Part.CFrame, Part.Size / 2
    local success, onScreen = pcall(function()
        return ESPModule.Camera:WorldToViewportPoint(CorFrame * CFrame.new(PartSize.X / 2, PartSize.Y / 2, PartSize.Z / 2).Position)
    end)
    
    if success and select(2, onScreen) and ESPModule.Config.ESP.ShowChams then
        for i = 1, 6 do
            local Quad = Cham["Quad"..tostring(i)]
            if Quad then
                Quad.Transparency = ESPModule.Config.ESP.ChamsTransparency
                Quad.Color = ESPModule.Config.ESP.ChamsColor
                Quad.Thickness = 1
                Quad.Filled = ESPModule.Config.ESP.ChamsFilled
                Quad.Visible = true
            end
        end

        -- Quad 1 - Front
        local success1, PosTopLeft = pcall(function() return ESPModule.Camera:WorldToViewportPoint(CorFrame * CFrame.new(PartSize.X, PartSize.Y, PartSize.Z).Position) end)
        local success2, PosTopRight = pcall(function() return ESPModule.Camera:WorldToViewportPoint(CorFrame * CFrame.new(-PartSize.X, PartSize.Y, PartSize.Z).Position) end)
        local success3, PosBottomLeft = pcall(function() return ESPModule.Camera:WorldToViewportPoint(CorFrame * CFrame.new(PartSize.X, -PartSize.Y, PartSize.Z).Position) end)
        local success4, PosBottomRight = pcall(function() return ESPModule.Camera:WorldToViewportPoint(CorFrame * CFrame.new(-PartSize.X, -PartSize.Y, PartSize.Z).Position) end)
        
        if success1 and success2 and success3 and success4 and Cham.Quad1 then
            Cham.Quad1.PointA = Vector2.new(PosTopLeft.X, PosTopLeft.Y)
            Cham.Quad1.PointB = Vector2.new(PosBottomLeft.X, PosBottomLeft.Y)
            Cham.Quad1.PointC = Vector2.new(PosBottomRight.X, PosBottomRight.Y)
            Cham.Quad1.PointD = Vector2.new(PosTopRight.X, PosTopRight.Y)
        end

        -- Quad 2 - Back
        local success5, PosTopLeft2 = pcall(function() return ESPModule.Camera:WorldToViewportPoint(CorFrame * CFrame.new(PartSize.X, PartSize.Y, -PartSize.Z).Position) end)
        local success6, PosTopRight2 = pcall(function() return ESPModule.Camera:WorldToViewportPoint(CorFrame * CFrame.new(-PartSize.X, PartSize.Y, -PartSize.Z).Position) end)
        local success7, PosBottomLeft2 = pcall(function() return ESPModule.Camera:WorldToViewportPoint(CorFrame * CFrame.new(PartSize.X, -PartSize.Y, -PartSize.Z).Position) end)
        local success8, PosBottomRight2 = pcall(function() return ESPModule.Camera:WorldToViewportPoint(CorFrame * CFrame.new(-PartSize.X, -PartSize.Y, -PartSize.Z).Position) end)
        
        if success5 and success6 and success7 and success8 and Cham.Quad2 then
            Cham.Quad2.PointA = Vector2.new(PosTopLeft2.X, PosTopLeft2.Y)
            Cham.Quad2.PointB = Vector2.new(PosBottomLeft2.X, PosBottomLeft2.Y)
            Cham.Quad2.PointC = Vector2.new(PosBottomRight2.X, PosBottomRight2.Y)
            Cham.Quad2.PointD = Vector2.new(PosTopRight2.X, PosTopRight2.Y)
        end
    else
        for i = 1, 6 do
            if Cham["Quad"..tostring(i)] then
                Cham["Quad"..tostring(i)].Visible = false
            end
        end
    end
end

function ESPModule.GetRainbowColor()
    return Color3.fromHSV(tick() % 5 / 5, 1, 1)
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
        local success, err = pcall(function()
            -- Clean up existing quads
            for _, v in next, PlayerTable.Chams do
                for i = 1, 6 do
                    local Quad = v["Quad"..tostring(i)]
                    if Quad and Quad.Remove then
                        pcall(function() Quad:Remove() end)
                    end
                end
            end
            
            -- Set up new rig type
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
            
            -- Create new quads with error handling
            if QuadSupported then
                for _, v in next, PlayerTable.Chams do
                    for i = 1, 6 do
                        local success, quad = pcall(function()
                            return Drawing.new("Quad")
                        end)
                        if success then
                            v["Quad"..tostring(i)] = quad
                        else
                            warn("Failed to create Quad for " .. Player.Name)
                        end
                    end
                end
            end
        end)
        if not success then
            warn("Error in UpdateRig for player " .. Player.Name .. ": " .. tostring(err))
        end
    end

    local success, err = pcall(function()
        ESPModule.AssignRigType(Player)
        ESPModule.InitChecks(Player)
        UpdateRig()
    end)
    if not success then
        warn("Error initializing ESP for player " .. Player.Name .. ": " .. tostring(err))
        return
    end

    if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
        local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
        PlayerTable.Connections.Died = Humanoid.Died:Connect(function()
            ESPModule.RemoveESP(Player)
        end)
    end

    local function UpdateESP()
        local success, err = pcall(function()
            if not ESPObjects[Player] then return end
            if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") or not Player.Character:FindFirstChild("Head") or not Player.Character:FindFirstChildOfClass("Humanoid") or Player.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
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
                    local success, Vector, OnScreen = pcall(function()
                        return ESPModule.Camera:WorldToViewportPoint(Head.Position)
                    end)
                    
                    if success and OnScreen then
                        PlayerTable.ESP.Visible = true
                        PlayerTable.ESP.Size = ESPModule.Config.ESP.TextSize
                        PlayerTable.ESP.Outline = ESPModule.Config.ESP.TextOutline
                        PlayerTable.ESP.OutlineColor = ESPModule.Config.ESP.TextOutlineColor
                        PlayerTable.ESP.Color = ESPModule.Config.ESP.TextColor
                        PlayerTable.ESP.Transparency = ESPModule.Config.ESP.TextTransparency
                        PlayerTable.ESP.Font = Drawing.Fonts.Plex
                        PlayerTable.ESP.Center = true

                        local Parts, Content, Tool = {
                            Health = "["..tostring(math.floor(Humanoid.Health)).."/"..tostring(math.floor(Humanoid.MaxHealth)).."]",
                            Distance = "["..tostring(math.floor((HumanoidRootPart.Position - (ESPModule.LocalPlayer.Character and ESPModule.LocalPlayer.Character.HumanoidRootPart.Position or Vector3.new())).Magnitude)).."]",
                            Name = ESPModule.Config.ESP.ShowNames and (Player.DisplayName == Player.Name and Player.Name or Player.DisplayName.." ("..Player.Name..")")
                        }, "", Character:FindFirstChildOfClass("Tool")

                        if ESPModule.Config.ESP.ShowNames then
                            Content = Parts.Name..Content
                        end
                        if ESPModule.Config.ESP.ShowHealth then
                            Content = Parts.Health..(Content and " " or "")..Content
                        end
                        if ESPModule.Config.ESP.ShowDistance then
                            Content = Content..(Content and " " or "")..Parts.Distance
                        end
                        PlayerTable.ESP.Text = (Tool and "["..Tool.Name.."]\n" or "")..Content
                        PlayerTable.ESP.Position = Vector2.new(Vector.X, Vector.Y - ESPModule.Config.ESP.TextSize - (Tool and 10 or 0))
                    else
                        PlayerTable.ESP.Visible = false
                    end
                else
                    PlayerTable.ESP.Visible = false
                end

                -- Tracers
                if ESPModule.Config.ESP.ShowTracers then
                    local HRPCFrame, HRPSize = HumanoidRootPart.CFrame, HumanoidRootPart.Size
                    local success1, _3DVector, OnScreen = pcall(function()
                        return ESPModule.Camera:WorldToViewportPoint((HRPCFrame * CFrame.new(0, -HRPSize.Y - 0.5, 0)).Position)
                    end)
                    local success2, _2DVector = pcall(function()
                        return ESPModule.Camera:WorldToViewportPoint(HumanoidRootPart.Position)
                    end)
                    local success3, HeadOffset = pcall(function()
                        return ESPModule.Camera:WorldToViewportPoint(Head.Position + Vector3.new(0, 0.5, 0))
                    end)
                    local success4, LegsOffset = pcall(function()
                        return ESPModule.Camera:WorldToViewportPoint(HumanoidRootPart.Position - Vector3.new(0, 1.5, 0))
                    end)
                    
                    if success1 and success2 and success3 and success4 and OnScreen then
                        PlayerTable.Tracer.Visible = true
                        PlayerTable.Tracer.Thickness = 1
                        PlayerTable.Tracer.Color = ESPModule.Config.ESP.TracerColor
                        PlayerTable.Tracer.Transparency = ESPModule.Config.ESP.TextTransparency
                        PlayerTable.Tracer.To = ESPModule.Config.ESP.BoxType == 1 and Vector2.new(_3DVector.X, _3DVector.Y) or Vector2.new(_2DVector.X, _2DVector.Y - (HeadOffset.Y - LegsOffset.Y) * 0.5)
                        
                        if ESPModule.Config.ESP.TracerType == 1 then
                            PlayerTable.Tracer.From = Vector2.new(ESPModule.Camera.ViewportSize.X / 2, ESPModule.Camera.ViewportSize.Y)
                        elseif ESPModule.Config.ESP.TracerType == 2 then
                            PlayerTable.Tracer.From = Vector2.new(ESPModule.Camera.ViewportSize.X / 2, ESPModule.Camera.ViewportSize.Y / 2)
                        elseif ESPModule.Config.ESP.TracerType == 3 then
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

                -- Box ESP
                if ESPModule.Config.ESP.Show3DBoxes or ESPModule.Config.ESP.BoxType == 2 then
                    local success, Vector, OnScreen = pcall(function()
                        return ESPModule.Camera:WorldToViewportPoint(HumanoidRootPart.Position)
                    end)
                    
                    if success and OnScreen then
                        local HRPCFrame, HRPSize = HumanoidRootPart.CFrame, HumanoidRootPart.Size
                        local success2, HeadOffset = pcall(function()
                            return ESPModule.Camera:WorldToViewportPoint(Head.Position + Vector3.new(0, 0.5, 0))
                        end)
                        local success3, LegsOffset = pcall(function()
                            return ESPModule.Camera:WorldToViewportPoint(HumanoidRootPart.Position - Vector3.new(0, 3, 0))
                        end)
                        
                        if success2 and success3 then
                            if ESPModule.Config.ESP.BoxType == 1 then
                                PlayerTable.Box.Square.Visible = false
                                for _, line in pairs(PlayerTable.Box) do
                                    if line ~= PlayerTable.Box.Square then
                                        if line.Visible ~= nil then
                                            line.Visible = false
                                        end
                                    end
                                end
                            else
                                PlayerTable.Box.Square.Visible = true
                                for _, line in pairs(PlayerTable.Box) do
                                    if line ~= PlayerTable.Box.Square then
                                        if line.Visible ~= nil then
                                            line.Visible = false
                                        end
                                    end
                                end
                                PlayerTable.Box.Square.Thickness = 1
                                PlayerTable.Box.Square.Color = ESPModule.Config.ESP.BoxColor
                                PlayerTable.Box.Square.Transparency = ESPModule.Config.ESP.TextTransparency
                                PlayerTable.Box.Square.Filled = false
                                PlayerTable.Box.Square.Size = Vector2.new(2000 / Vector.Z, HeadOffset.Y - LegsOffset.Y)
                                PlayerTable.Box.Square.Position = Vector2.new(Vector.X - PlayerTable.Box.Square.Size.X / 2, Vector.Y - PlayerTable.Box.Square.Size.Y / 2)
                            end
                        else
                            for _, line in pairs(PlayerTable.Box) do
                                if line.Visible ~= nil then
                                    line.Visible = false
                                end
                            end
                        end
                    else
                        for _, line in pairs(PlayerTable.Box) do
                            if line.Visible ~= nil then
                                line.Visible = false
                            end
                        end
                    end
                else
                    for _, line in pairs(PlayerTable.Box) do
                        if line.Visible ~= nil then
                            line.Visible = false
                        end
                    end
                end

                -- HeadDot
                if ESPModule.Config.ESP.ShowHeadDots then
                    local success, Vector, OnScreen = pcall(function()
                        return ESPModule.Camera:WorldToViewportPoint(Head.Position)
                    end)
                    
                    if success and OnScreen then
                        PlayerTable.HeadDot.Visible = true
                        PlayerTable.HeadDot.Thickness = 1
                        PlayerTable.HeadDot.Color = ESPModule.Config.ESP.HeadDotColor
                        PlayerTable.HeadDot.Transparency = ESPModule.Config.ESP.HeadDotTransparency
                        PlayerTable.HeadDot.NumSides = 32
                        PlayerTable.HeadDot.Filled = true
                        PlayerTable.HeadDot.Position = Vector2.new(Vector.X, Vector.Y)
                        
                        local success2, Top = pcall(function()
                            return ESPModule.Camera:WorldToViewportPoint((Head.CFrame * CFrame.new(0, Head.Size.Y / 2, 0)).Position)
                        end)
                        local success3, Bottom = pcall(function()
                            return ESPModule.Camera:WorldToViewportPoint((Head.CFrame * CFrame.new(0, -Head.Size.Y / 2, 0)).Position)
                        end)
                        
                        if success2 and success3 then
                            PlayerTable.HeadDot.Radius = math.abs((Top.Y - Bottom.Y)) / 2
                        else
                            PlayerTable.HeadDot.Radius = 5
                        end
                    else
                        PlayerTable.HeadDot.Visible = false
                    end
                else
                    PlayerTable.HeadDot.Visible = false
                end

                -- HealthBar
                if ESPModule.Config.ESP.ShowHealth then
                    local success, Vector, OnScreen = pcall(function()
                        return ESPModule.Camera:WorldToViewportPoint(HumanoidRootPart.Position)
                    end)
                    
                    if success and OnScreen and PlayerTable.HealthBar.Main and PlayerTable.HealthBar.Outline then
                        PlayerTable.HealthBar.Main.Visible = true
                        PlayerTable.HealthBar.Outline.Visible = true
                        
                        PlayerTable.HealthBar.Main.Thickness = 1
                        PlayerTable.HealthBar.Main.Color = ESPModule.GetColorFromHealth(Humanoid.Health, Humanoid.MaxHealth)
                        PlayerTable.HealthBar.Main.Transparency = ESPModule.Config.ESP.TextTransparency
                        PlayerTable.HealthBar.Outline.Thickness = 2
                        PlayerTable.HealthBar.Outline.Color = Color3.fromRGB(0, 0, 0)
                        PlayerTable.HealthBar.Outline.Transparency = ESPModule.Config.ESP.TextTransparency
                        
                        local HealthPercentage = Humanoid.Health / Humanoid.MaxHealth
                        PlayerTable.HealthBar.Main.From = Vector2.new(Vector.X - 50, Vector.Y - 8)
                        PlayerTable.HealthBar.Main.To = Vector2.new(Vector.X - 50 + (HealthPercentage * 100), Vector.Y - 8)
                        PlayerTable.HealthBar.Outline.From = Vector2.new(Vector.X - 51, Vector.Y - 8)
                        PlayerTable.HealthBar.Outline.To = Vector2.new(Vector.X + 51, Vector.Y - 8)
                    else
                        if PlayerTable.HealthBar.Main then PlayerTable.HealthBar.Main.Visible = false end
                        if PlayerTable.HealthBar.Outline then PlayerTable.HealthBar.Outline.Visible = false end
                    end
                else
                    if PlayerTable.HealthBar.Main then PlayerTable.HealthBar.Main.Visible = false end
                    if PlayerTable.HealthBar.Outline then PlayerTable.HealthBar.Outline.Visible = false end
                end

                -- Chams
                if ESPModule.Config.ESP.ShowChams and QuadSupported then
                    for partName, v in next, PlayerTable.Chams do
                        if Character:FindFirstChild(partName) then
                            pcall(function()
                                ESPModule.UpdateCham(Character[partName], v)
                            end)
                        end
                    end
                else
                    for _, v in next, PlayerTable.Chams do
                        for i = 1, 6 do
                            if v["Quad"..tostring(i)] then
                                v["Quad"..tostring(i)].Visible = false
                            end
                        end
                    end
                end
            else
                PlayerTable.ESP.Visible = false
                PlayerTable.Tracer.Visible = false
                PlayerTable.HeadDot.Visible = false
                if PlayerTable.HealthBar.Main then PlayerTable.HealthBar.Main.Visible = false end
                if PlayerTable.HealthBar.Outline then PlayerTable.HealthBar.Outline.Visible = false end
                for _, line in pairs(PlayerTable.Box) do
                    if line.Visible ~= nil then
                        line.Visible = false
                    end
                end
                for _, v in next, PlayerTable.Chams do
                    for i = 1, 6 do
                        if v["Quad"..tostring(i)] then
                            v["Quad"..tostring(i)].Visible = false
                        end
                    end
                end
            end
        end)
        if not success then
            warn("Error in UpdateESP for player " .. Player.Name .. ": " .. tostring(err))
        end
    end

    PlayerTable.Connections.Update = ESPModule.RunService.Heartbeat:Connect(UpdateESP)
end

function ESPModule.RemoveESP(Player)
    local PlayerTable = ESPObjects[Player]
    if PlayerTable then
        local success, err = pcall(function()
            for _, Connection in next, PlayerTable.Connections do
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
        end)
        if not success then
            warn("Error removing ESP for player " .. Player.Name .. ": " .. tostring(err))
        end
    end
end

function ESPModule.AddCrosshair()
    local success, err = pcall(function()
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
                if ESPModule.Config.Crosshair.Type == 1 then
                    Axis = ESPModule.UserInputService:GetMouseLocation()
                elseif ESPModule.Config.Crosshair.Type == 2 then
                    Axis = ESPModule.Camera.ViewportSize / 2
                end
                GapSize = ESPModule.Config.Crosshair.GapSize
                Rotation = ESPModule.Config.Crosshair.Rotation
            end
        end)

        ServiceConnections.UpdateCrosshair = ESPModule.RunService.RenderStepped:Connect(function()
            if ESPModule.Config.Crosshair.Enabled then
                local AxisX, AxisY = Axis.X, Axis.Y
                for _, line in ipairs({"LeftLine", "RightLine", "TopLine", "BottomLine"}) do
                    CrosshairParts[line].Visible = true
                    CrosshairParts[line].Color = ESPModule.Config.Crosshair.Color
                    CrosshairParts[line].Thickness = ESPModule.Config.Crosshair.Thickness
                    CrosshairParts[line].Transparency = ESPModule.Config.Crosshair.Transparency
                    CrosshairParts["Outline"..line].Visible = ESPModule.Config.Crosshair.TextOutline
                    CrosshairParts["Outline"..line].Color = ESPModule.Config.Crosshair.TextOutlineColor
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
                CrosshairParts.BottomInfo = Vector2.new(AxisX + (math.sin(math.rad(-Rotation)) * (ESPModule.Config.Crosshair.Size + GapSize)), AxisY + (math.cos(math.rad(-Rotation)) * (ESPModule.Config.Crosshair.Size + GapSize)))

                CrosshairParts["OutlineLeftLine"].From = CrosshairParts.LeftLine.From
                CrosshairParts["OutlineLeftLine"].To = CrosshairParts.LeftLine.To
                CrosshairParts["OutlineRightLine"].From = CrosshairParts.RightLine.From
                CrosshairParts["OutlineRightLine"].To = CrosshairParts.RightLine.To
                CrosshairParts["OutlineTopLine"].From = CrosshairParts.TopLine.From
                CrosshairParts["OutlineTopLine"].To = CrosshairParts.TopLine.To
                CrosshairParts["OutlineBottomLine"].From = CrosshairParts.BottomLine.From
                CrosshairParts["OutlineBottomLine"].To = CrosshairParts.BottomLine.To

                CrosshairParts.CenterDot.Visible = ESPModule.Config.Crosshair.CenterDot
                CrosshairParts.CenterDot.Color = ESPModule.Config.Crosshair.CenterDotColor
                CrosshairParts.CenterDot.Radius = ESPModule.Config.Crosshair.CenterDotSize
                CrosshairParts.CenterDot.Transparency = ESPModule.Config.Crosshair.CenterDotTransparency
                CrosshairParts.CenterDot.Filled = ESPModule.Config.Crosshair.CenterDotFilled
                CrosshairParts.CenterDot.Thickness = ESPModule.Config.Crosshair.CenterDotThickness
                CrosshairParts.CenterDot.Position = Vector2.new(AxisX, AxisY)
                CrosshairParts.OutlineCenterDot.Visible = ESPModule.Config.Crosshair.CenterDot and ESPModule.Config.Crosshair.TextOutline
                CrosshairParts.OutlineCenterDot.Color = ESPModule.Config.Crosshair.TextOutlineColor
                CrosshairParts.OutlineCenterDot.Radius = ESPModule.Config.Crosshair.CenterDotSize
                CrosshairParts.OutlineCenterDot.Transparency = ESPModule.Config.Crosshair.CenterDotTransparency
                CrosshairParts.OutlineCenterDot.Filled = ESPModule.Config.Crosshair.CenterDotFilled
                CrosshairParts.OutlineCenterDot.Thickness = ESPModule.Config.Crosshair.CenterDotThickness + 1
                CrosshairParts.OutlineCenterDot.Position = Vector2.new(AxisX, AxisY)
            else
                for _, line in pairs(CrosshairParts) do
                    line.Visible = false
                end
            end
        end)
    end)
    if not success then
        warn("Error in AddCrosshair: " .. tostring(err))
    end
end

function ESPModule.GetColorFromHealth(Health, MaxHealth)
    return Color3.fromRGB(255 - math.floor(Health / MaxHealth * 255), math.floor(Health / MaxHealth * 255), 50)
end

return ESPModule
