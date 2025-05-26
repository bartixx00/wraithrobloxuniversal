-- AimBot Module
local AimBotModule = {}

-- Global Variables
local CurrentTarget = nil
local AimConnection = nil
local TriggerConnection = nil
local FOVCircle = nil
local LastShot = 0
local AntiAimConnection = nil
local SilentAimTarget = nil

-- Initialize Module
function AimBotModule.Init(Config, Camera, LocalPlayer, Players, UserInputService, RunService, TweenService)
    AimBotModule.Config = Config
    AimBotModule.Camera = Camera
    AimBotModule.LocalPlayer = LocalPlayer
    AimBotModule.Players = Players
    AimBotModule.UserInputService = UserInputService
    AimBotModule.RunService = RunService
    AimBotModule.TweenService = TweenService
end

-- Helper Functions
function AimBotModule.IsAlive(player)
    return player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0
end

function AimBotModule.GetClosestPlayer()
    local ClosestDistance = math.huge
    local ClosestPlayer = nil
    local ScreenCenter = Vector2.new(AimBotModule.Camera.ViewportSize.X / 2, AimBotModule.Camera.ViewportSize.Y / 2)

    for _, Player in pairs(AimBotModule.Players:GetPlayers()) do
        if Player ~= AimBotModule.LocalPlayer and AimBotModule.IsAlive(Player) then
            if AimBotModule.Config.AimBot.TeamCheck and Player.Team and AimBotModule.LocalPlayer.Team and Player.Team == AimBotModule.LocalPlayer.Team then
                continue
            end

            local Character = Player.Character
            local TargetPart = Character:FindFirstChild(AimBotModule.Config.AimBot.CurrentBone)
            if not TargetPart then
                TargetPart = Character:FindFirstChild("HumanoidRootPart")
            end

            if TargetPart then
                local Vector, OnScreen = AimBotModule.Camera:WorldToViewportPoint(TargetPart.Position)
                if OnScreen then
                    local Distance = (Vector2.new(Vector.X, Vector.Y) - ScreenCenter).Magnitude
                    if Distance < AimBotModule.Config.AimBot.FOV and Distance < ClosestDistance then
                        if AimBotModule.Config.AimBot.WallCheck then
                            local RaycastParams = RaycastParams.new()
                            RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist 
                            RaycastParams.FilterDescendantsInstances = {AimBotModule.LocalPlayer.Character}
                            
                            local Direction = (TargetPart.Position - AimBotModule.Camera.CFrame.Position).Unit
                            local Distance3D = (TargetPart.Position - AimBotModule.Camera.CFrame.Position).Magnitude
                            
                            local RaycastResult = workspace:Raycast(AimBotModule.Camera.CFrame.Position, Direction * Distance3D, RaycastParams)
                            
                            if not RaycastResult or RaycastResult.Instance:IsDescendantOf(Character) then
                                ClosestDistance = Distance
                                ClosestPlayer = Player
                            end
                        else
                            ClosestDistance = Distance
                            ClosestPlayer = Player
                        end
                    end
                end
            end
        end
    end
    return ClosestPlayer
end

function AimBotModule.AimAt(Player)
    if not Player or not AimBotModule.IsAlive(Player) then return end
    
    local TargetPart = Player.Character:FindFirstChild(AimBotModule.Config.AimBot.CurrentBone)
    if not TargetPart then
        TargetPart = Player.Character:FindFirstChild("HumanoidRootPart")
    end
    if not TargetPart then return end

    local TargetPosition = TargetPart.Position
    
    if AimBotModule.Config.AimBot.Prediction then
        local Velocity = Vector3.new(0, 0, 0)
        if TargetPart.AssemblyLinearVelocity then
            Velocity = TargetPart.AssemblyLinearVelocity
        elseif TargetPart.Velocity then
            Velocity = TargetPart.Velocity
        end
        TargetPosition = TargetPosition + (Velocity * AimBotModule.Config.AimBot.PredictionFactor)
    end

    if AimBotModule.Config.AimBot.SilentAim then
        SilentAimTarget = {
            Position = TargetPosition,
            Player = Player
        }
    else
        local CameraPosition = AimBotModule.Camera.CFrame.Position
        local Direction = (TargetPosition - CameraPosition).Unit
        local NewCFrame = CFrame.lookAt(CameraPosition, TargetPosition)
        
        if AimBotModule.Config.AimBot.Smoothness > 1 then
            local CurrentCFrame = AimBotModule.Camera.CFrame
            local LerpedCFrame = CurrentCFrame:Lerp(NewCFrame, 1 / AimBotModule.Config.AimBot.Smoothness)
            AimBotModule.Camera.CFrame = LerpedCFrame
        else
            AimBotModule.Camera.CFrame = NewCFrame
        end
    end
end

-- FOV Circle
function AimBotModule.CreateFOVCircle()
    if FOVCircle then 
        pcall(function() FOVCircle:Remove() end)
        FOVCircle = nil
    end
    
    pcall(function()
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Visible = AimBotModule.Config.AimBot.FOVVisible
        FOVCircle.Radius = AimBotModule.Config.AimBot.FOV
        FOVCircle.Position = Vector2.new(AimBotModule.Camera.ViewportSize.X / 2, AimBotModule.Camera.ViewportSize.Y / 2)
        FOVCircle.Color = AimBotModule.Config.AimBot.FOVColor
        FOVCircle.Thickness = 2
        FOVCircle.Filled = false
        FOVCircle.NumSides = 64
        FOVCircle.Transparency = 0.7
    end)
    AimBotModule.FOVCircle = FOVCircle
end

function AimBotModule.UpdateFOVCircle()
    if FOVCircle then
        pcall(function()
            FOVCircle.Visible = AimBotModule.Config.AimBot.FOVVisible and AimBotModule.Config.AimBot.Enabled
            FOVCircle.Radius = AimBotModule.Config.AimBot.FOV
            FOVCircle.Position = Vector2.new(AimBotModule.Camera.ViewportSize.X / 2, AimBotModule.Camera.ViewportSize.Y / 2)
            FOVCircle.Color = AimBotModule.Config.AimBot.FOVColor
        end)
    end
end

-- Silent Aim Hook
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
    local Method = getnamecallmethod()
    local Args = {...}
    
    if Method == "FireServer" or Method == "InvokeServer" then
        if SilentAimTarget and AimBotModule.Config.AimBot.SilentAim and AimBotModule.Config.AimBot.Enabled then
            if string.find(tostring(Self), "Remot") and string.find(string.lower(tostring(Self)), "fire") or string.find(string.lower(tostring(Self)), "shoot") then
                for i, v in pairs(Args) do
                    if typeof(v) == "Vector3" then
                        Args[i] = SilentAimTarget.Position
                        break
                    end
                end
            end
        end
    elseif Method == "Raycast" then
        if SilentAimTarget and AimBotModule.Config.AimBot.SilentAim and AimBotModule.Config.AimBot.Enabled then
            if Args[2] and typeof(Args[2]) == "Vector3" then
                local Direction = (SilentAimTarget.Position - Args[1]).Unit
                Args[2] = Direction * Args[2].Magnitude
            end
        end
    end
    
    return OldNamecall(Self, unpack(Args))
end)

-- TriggerBot Logic
function AimBotModule.StartTriggerBot()
    if TriggerConnection then 
        TriggerConnection:Disconnect() 
        TriggerConnection = nil
    end
    
    if AimBotModule.Config.TriggerBot.Enabled then
        TriggerConnection = AimBotModule.RunService.Heartbeat:Connect(function()
            if tick() - LastShot >= AimBotModule.Config.TriggerBot.Delay then
                local Target = AimBotModule.GetClosestPlayer()
                if Target and AimBotModule.IsAlive(Target) then
                    local TargetPart = Target.Character:FindFirstChild(AimBotModule.Config.AimBot.CurrentBone) or Target.Character.HumanoidRootPart
                    local ScreenPos, OnScreen = AimBotModule.Camera:WorldToViewportPoint(TargetPart.Position)
                    local ScreenCenter = Vector2.new(AimBotModule.Camera.ViewportSize.X / 2, AimBotModule.Camera.ViewportSize.Y / 2)
                    
                    if OnScreen and (Vector2.new(ScreenPos.X, ScreenPos.Y) - ScreenCenter).Magnitude < 30 then
                        pcall(function()
                            if mouse1press then
                                mouse1press()
                                task.wait(0.01)
                                mouse1release()
                            end
                        end)
                        LastShot = tick()
                    end
                end
            end
        end)
    end
    AimBotModule.TriggerConnection = TriggerConnection
end

-- Anti-Aim Logic
function AimBotModule.StartAntiAim()
    if AntiAimConnection then
        AntiAimConnection:Disconnect()
        AntiAimConnection = nil
    end
    
    if AimBotModule.Config.AntiAim.Enabled and AimBotModule.LocalPlayer.Character and AimBotModule.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        AntiAimConnection = AimBotModule.RunService.Heartbeat:Connect(function()
            if AimBotModule.LocalPlayer.Character and AimBotModule.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local RootPart = AimBotModule.LocalPlayer.Character.HumanoidRootPart
                if AimBotModule.Config.AntiAim.Type == "Spin" then
                    RootPart.CFrame = RootPart.CFrame * CFrame.Angles(0, math.rad(AimBotModule.Config.AntiAim.Speed), 0)
                elseif AimBotModule.Config.AntiAim.Type == "Jitter" then
                    local RandomAngle = math.random(-AimBotModule.Config.AntiAim.Speed, AimBotModule.Config.AntiAim.Speed)
                    RootPart.CFrame = RootPart.CFrame * CFrame.Angles(0, math.rad(RandomAngle), 0)
                elseif AimBotModule.Config.AntiAim.Type == "Random" then
                    RootPart.CFrame = RootPart.CFrame * CFrame.Angles(0, math.rad(math.random(-180, 180)), 0)
                end
            end
        end)
    end
    AimBotModule.AntiAimConnection = AntiAimConnection
end

return AimBotModule
