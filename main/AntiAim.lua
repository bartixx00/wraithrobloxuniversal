local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

return function(Config, AntiAimConnection)
    local function StartAntiAim()
        if AntiAimConnection then
            AntiAimConnection:Disconnect()
            AntiAimConnection = nil
        end
        
        if Config.AntiAim.Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            AntiAimConnection = RunService.Heartbeat:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local RootPart = LocalPlayer.Character.HumanoidRootPart
                    if Config.AntiAim.Type == "Spin" then
                        RootPart.CFrame = RootPart.CFrame * CFrame.Angles(0, math.rad(Config.AntiAim.Speed), 0)
                    elseif Config.AntiAim.Type == "Jitter" then
                        local RandomAngle = math.random(-Config.AntiAim.Speed, Config.AntiAim.Speed)
                        RootPart.CFrame = RootPart.CFrame * CFrame.Angles(0, math.rad(RandomAngle), 0)
                    elseif Config.AntiAim.Type == "Random" then
                        RootPart.CFrame = RootPart.CFrame * CFrame.Angles(0, math.rad(math.random(-180, 180)), 0)
                    end
                end
            end)
        end
    end

    local AntiAimTab = Window:CreateTab("🛡️ Anti-Aim", nil)

    AntiAimTab:CreateToggle({
        Name = "Enable Anti-Aim",
        CurrentValue = Config.AntiAim.Enabled,
        Callback = function(Value)
            Config.AntiAim.Enabled = Value
            StartAntiAim()
        end
    })

    AntiAimTab:CreateDropdown({
        Name = "Anti-Aim Type",
        Options = {"Spin", "Jitter"},
        CurrentOption = Config.AntiAim.Type,
        Callback = function(Option)
            Config.AntiAim.Type = Option
        end
    })

    AntiAimTab:CreateSlider({
        Name = "Anti-Aim Speed",
        Range = {1, 50},
        Increment = 1,
        CurrentValue = Config.AntiAim.Speed,
        Callback = function(Value)
            Config.AntiAim.Speed = Value
        end
    })

    StartAntiAim()

    return {
        AntiAimConnection = AntiAimConnection
    }
end
