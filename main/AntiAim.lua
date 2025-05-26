local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

return function(Config, AntiAimConnection, Window)
    print("Tworzenie zakładki Anti-Aim...")
    local AntiAimTab = Window:CreateTab("🛡️ Anti-Aim", nil)
    print("Zakładka Anti-Aim utworzona: ", AntiAimTab)

    local function StartAntiAim()
        if AntiAimConnection then
            AntiAimConnection:Disconnect()
            AntiAimConnection = nil
        end

        AntiAimConnection = RunService.Heartbeat:Connect(function()
            if Config.AntiAim.Enabled and LocalPlayer.Character then
                local Char = LocalPlayer.Character
                local Root = Char:FindFirstChild("HumanoidRootPart")
                if Root then
                    Root.CFrame = Root.CFrame * CFrame.Angles(
                        math.rad(Config.AntiAim.Pitch),
                        math.rad(Config.AntiAim.Yaw), -- Poprawione z Config.AniAim.Yaw
                        math.rad(Config.AntiAim.Roll)
                    )
                end
            end
        end)
    end

    AntiAimTab:CreateToggle({
        Name = "Enable Anti-Aim",
        CurrentValue = Config.AntiAim.Enabled,
        Callback = function(Value)
            Config.AntiAim.Enabled = Value
        end
    })

    AntiAimTab:CreateSlider({
        Name = "Pitch",
        Range = {-90, 90},
        Increment = 1,
        CurrentValue = Config.AntiAim.Pitch,
        Callback = function(Value)
            Config.AntiAim.Pitch = Value
        end
    })

    AntiAimTab:CreateSlider({
        Name = "Yaw",
        Range = {-180, 180},
        Increment = 1,
        CurrentValue = Config.AntiAim.Yaw,
        Callback = function(Value)
            Config.AntiAim.Yaw = Value
        end
    })

    AntiAimTab:CreateSlider({
        Name = "Roll",
        Range = {-180, 180},
        Increment = 1,
        CurrentValue = Config.AntiAim.Roll,
        Callback = function(Value)
            Config.AntiAim.Roll = Value
        end
    })

    StartAntiAim()

    return {
        AntiAimConnection = AntiAimConnection
    }
end
