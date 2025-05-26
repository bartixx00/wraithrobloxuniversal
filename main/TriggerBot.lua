local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

return function(Config, TriggerConnection, LastShot, Utils, Window)
    local function ShootAt(Player)
        if not Player or not Utils.IsAlive(Player) then return end
        local TargetPart = Player.Character:FindFirstChild(Config.TriggerBot.TargetBone)
        if not TargetPart then
            TargetPart = Player.Character:FindFirstChild("HumanoidRootPart")
        end
        if not TargetPart then return end

        mouse1press()
        LastShot = tick()
        task.wait(0.01)
        mouse1release()
    end

    local function StartTriggerBot()
        if TriggerConnection then
            TriggerConnection:Disconnect()
            TriggerConnection = nil
        end

        TriggerConnection = RunService.Heartbeat:Connect(function()
            if Config.TriggerBot.Enabled and tick() - LastShot >= Config.TriggerBot.Delay then
                local ClosestPlayer = Utils.GetClosestPlayer(Config)
                if ClosestPlayer then
                    ShootAt(ClosestPlayer)
                end
            end
        end)
    end

    local TriggerBotTab = Window:CreateTab("🔫 TriggerBot", nil)

    TriggerBotTab:CreateToggle({
        Name = "Enable TriggerBot",
        CurrentValue = Config.TriggerBot.Enabled,
        Callback = function(Value)
            Config.TriggerBot.Enabled = Value
        end
    })

    TriggerBotTab:CreateToggle({
        Name = "Team Check",
        CurrentValue = Config.TriggerBot.TeamCheck,
        Callback = function(Value)
            Config.TriggerBot.TeamCheck = Value
        end
    })

    TriggerBotTab:CreateToggle({
        Name = "Wall Check",
        CurrentValue = Config.TriggerBot.WallCheck,
        Callback = function(Value)
            Config.TriggerBot.WallCheck = Value
        end
    })

    TriggerBotTab:CreateSlider({
        Name = "Delay",
        Range = {0, 1},
        Increment = 0.01,
        CurrentValue = Config.TriggerBot.Delay,
        Callback = function(Value)
            Config.TriggerBot.Delay = Value
        end
    })

    TriggerBotTab:CreateDropdown({
        Name = "Target Bone",
        Options = {"Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso"},
        CurrentOption = Config.TriggerBot.TargetBone,
        Callback = function(Option)
            Config.TriggerBot.TargetBone = Option
        end
    })

    StartTriggerBot()

    return {
        TriggerConnection = TriggerConnection,
        LastShot = LastShot
    }
end
