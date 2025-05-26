-- scripts/AimBot.lua
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

return function(Config, CurrentTarget, AimConnection, SilentAimTarget, FOVCircle, Utils)
    local function AimAt(Player)
        if not Player or not Utils.IsAlive(Player) then return end
        
        local TargetPart = Player.Character:FindFirstChild(Config.AimBot.CurrentBone)
        if not TargetPart then
            TargetPart = Player.Character:FindFirstChild("HumanoidRootPart")
        end
        if not TargetPart then return end

        local TargetPosition = TargetPart.Position
        
        if Config.AimBot.Prediction then
            local Velocity = Vector3.new(0, 0, 0)
            if TargetPart.AssemblyLinearVelocity then
                Velocity = TargetPart.AssemblyLinearVelocity
            elseif TargetPart.Velocity then
                Velocity = TargetPart.Velocity
            end
            TargetPosition = TargetPosition + (Velocity * Config.AimBot.PredictionFactor)
        end

        if Config.AimBot.SilentAim then
            SilentAimTarget = {
                Position = TargetPosition,
                Player = Player
            }
        else
            local CameraPosition = Camera.CFrame.Position
            local Direction = (TargetPosition - CameraPosition).Unit
            local NewCFrame = CFrame.lookAt(CameraPosition, TargetPosition)
            
            if Config.AimBot.Smoothness > 1 then
                local CurrentCFrame = Camera.CFrame
                local LerpedCFrame = CurrentCFrame:Lerp(NewCFrame, 1 / Config.AimBot.Smoothness)
                Camera.CFrame = LerpedCFrame
            else
                Camera.CFrame = NewCFrame
            end
        end
    end

    local function CreateFOVCircle()
        if FOVCircle then 
            pcall(function() FOVCircle:Remove() end)
            FOVCircle = nil
        end
        
        pcall(function()
            FOVCircle = Drawing.new("Circle")
            FOVCircle.Visible = Config.AimBot.FOVVisible
            FOVCircle.Radius = Config.AimBot.FOV
            FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            FOVCircle.Color = Config.AimBot.FOVColor
            FOVCircle.Thickness = 2
            FOVCircle.Filled = false
            FOVCircle.NumSides = 64
            FOVCircle.Transparency = 0.7
        end)
    end

    local function UpdateFOVCircle()
        if FOVCircle then
            pcall(function()
                FOVCircle.Visible = Config.AimBot.FOVVisible and Config.AimBot.Enabled
                FOVCircle.Radius = Config.AimBot.FOV
                FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                FOVCircle.Color = Config.AimBot.FOVColor
            end)
        end
    end

    local function StartAimBot()
        if AimConnection then 
            AimConnection:Disconnect() 
            AimConnection = nil
        end
        
        AimConnection = RunService.Heartbeat:Connect(function()
            if Config.AimBot.Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                CurrentTarget = Utils.GetClosestPlayer(Config)
                if CurrentTarget then
                    AimAt(CurrentTarget)
                end
            else
                CurrentTarget = nil
            end
            UpdateFOVCircle()
        end)
    end

    local AimBotTab = Window:CreateTab("🎯 AimBot", nil)

    AimBotTab:CreateToggle({
        Name = "Enable AimBot",
        CurrentValue = Config.AimBot.Enabled,
        Callback = function(Value)
            Config.AimBot.Enabled = Value
            if not Value then
                SilentAimTarget = nil
            end
            UpdateFOVCircle()
        end
    })

    -- ... (reszta opcji UI dla AimBot, jak w oryginalnym skrypcie)

    CreateFOVCircle()
    StartAimBot()

    return {
        AimConnection = AimConnection,
        FOVCircle = FOVCircle,
        SilentAimTarget = SilentAimTarget,
        CurrentTarget = CurrentTarget
    }
end
