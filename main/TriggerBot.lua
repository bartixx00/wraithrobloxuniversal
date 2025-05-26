local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

return function(Config, TriggerConnection, LastShot, Utils)
    local function StartTriggerBot()
        if TriggerConnection then 
            TriggerConnection:Disconnect() 
            TriggerConnection = nil
        end
        
        if Config.TriggerBot.Enabled then
            TriggerConnection = RunService.Heartbeat:Connect(function()
                if tick() - LastShot >= Config.TriggerBot.Delay then
                    local Target = Utils.GetClosestPlayer(Config)
                    if Target and Utils.IsAlive(Target) then
                        local TargetPart = Target.Character:FindFirstChild(Config.AimBot.CurrentBone) or Target.Character.HumanoidRootPart
                        local ScreenPos, OnScreen = Camera:WorldToViewportPoint(TargetPart.Position)
                        local ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        
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
    end

    local TriggerTab = Window:CreateTab("🔫 TriggerBot", nil)

    TriggerTab:CreateToggle({
        Name = "Enable TriggerBot",
        CurrentValue = Config.TriggerBot.Enabled,
        Callback = function(Value)
            Config.TriggerBot.Enabled = Value
            StartTriggerBot()
        end
    })

    TriggerTab:CreateSlider({
        Name = "Trigger Delay",
        Range = {0, 0.5},
        Increment = 0.01,
        CurrentValue = Config.TriggerBot.Delay,
        Callback = function(Value)
            Config.TriggerBot.Delay = Value
        end
    })

    StartTriggerBot()

    return {
        TriggerConnection = TriggerConnection,
        LastShot = LastShot
    }
end
