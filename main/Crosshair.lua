local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

return function(Config, CrosshairParts, ServiceConnections, Window)
    local function CreateCrosshairPart()
        local Part = Drawing.new("Line")
        Part.Thickness = Config.Crosshair.Thickness
        Part.Color = Config.Crosshair.Color
        return Part
    end

    local function UpdateCrosshair()
        local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local Size = Config.Crosshair.Size
        local Gap = Config.Crosshair.GapSize
        local Angle = Config.Crosshair.Spin and tick() * Config.Crosshair.SpinSpeed or 0

        CrosshairParts.Top.From = Center + Vector2.new(math.sin(Angle) * Gap, -math.cos(Angle) * Gap)
        CrosshairParts.Top.To = Center + Vector2.new(math.sin(Angle) * (Gap + Size), -math.cos(Angle) * (Gap + Size))
        CrosshairParts.Top.Thickness = Config.Crosshair.Thickness
        CrosshairParts.Top.Color = Config.Crosshair.Color
        CrosshairParts.Top.Visible = Config.Crosshair.Enabled

        CrosshairParts.Bottom.From = Center + Vector2.new(-math.sin(Angle) * Gap, math.cos(Angle) * Gap)
        CrosshairParts.Bottom.To = Center + Vector2.new(-math.sin(Angle) * (Gap + Size), math.cos(Angle) * (Gap + Size))
        CrosshairParts.Bottom.Thickness = Config.Crosshair.Thickness
        CrosshairParts.Bottom.Color = Config.Crosshair.Color
        CrosshairParts.Bottom.Visible = Config.Crosshair.Enabled

        CrosshairParts.Left.From = Center + Vector2.new(-math.cos(Angle) * Gap, -math.sin(Angle) * Gap)
        CrosshairParts.Left.To = Center + Vector2.new(-math.cos(Angle) * (Gap + Size), -math.sin(Angle) * (Gap + Size))
        CrosshairParts.Left.Thickness = Config.Crosshair.Thickness
        CrosshairParts.Left.Color = Config.Crosshair.Color
        CrosshairParts.Left.Visible = Config.Crosshair.Enabled

        CrosshairParts.Right.From = Center + Vector2.new(math.cos(Angle) * Gap, math.sin(Angle) * Gap)
        CrosshairParts.Right.To = Center + Vector2.new(math.cos(Angle) * (Gap + Size), math.sin(Angle) * (Gap + Size))
        CrosshairParts.Right.Thickness = Config.Crosshair.Thickness
        CrosshairParts.Right.Color = Config.Crosshair.Color
        CrosshairParts.Right.Visible = Config.Crosshair.Enabled
    end

    CrosshairParts.Top = CreateCrosshairPart()
    CrosshairParts.Bottom = CreateCrosshairPart()
    CrosshairParts.Left = CreateCrosshairPart()
    CrosshairParts.Right = CreateCrosshairPart()

    ServiceConnections.UpdateCrosshair = RunService.RenderStepped:Connect(UpdateCrosshair)

    local CrosshairTab = Window:CreateTab("🔫 Crosshair", nil)

    CrosshairTab:CreateToggle({
        Name = "Enable Crosshair",
        CurrentValue = Config.Crosshair.Enabled,
        Callback = function(Value)
            Config.Crosshair.Enabled = Value
            UpdateCrosshair()
        end
    })

    CrosshairTab:CreateSlider({
        Name = "Size",
        Range = {1, 20},
        Increment = 1,
        CurrentValue = Config.Crosshair.Size,
        Callback = function(Value)
            Config.Crosshair.Size = Value
            UpdateCrosshair()
        end
    })

    CrosshairTab:CreateSlider({
        Name = "Thickness",
        Range = {1, 5},
        Increment = 1,
        CurrentValue = Config.Crosshair.Thickness,
        Callback = function(Value)
            Config.Crosshair.Thickness = Value
            UpdateCrosshair()
        end
    })

    CrosshairTab:CreateSlider({
        Name = "Gap Size",
        Range = {0, 10},
        Increment = 1,
        CurrentValue = Config.Crosshair.GapSize,
        Callback = function(Value)
            Config.Crosshair.GapSize = Value
            UpdateCrosshair()
        end
    })

    CrosshairTab:CreateColorPicker({
        Name = "Crosshair Color",
        Color = Config.Crosshair.Color,
        Callback = function(Value)
            Config.Crosshair.Color = Value
            UpdateCrosshair()
        end
    })

    CrosshairTab:CreateToggle({
        Name = "Spin",
        CurrentValue = Config.Crosshair.Spin,
        Callback = function(Value)
            Config.Crosshair.Spin = Value
            UpdateCrosshair()
        end
    })

    CrosshairTab:CreateSlider({
        Name = "Spin Speed",
        Range = {1, 10},
        Increment = 1,
        CurrentValue = Config.Crosshair.SpinSpeed,
        Callback = function(Value)
            Config.Crosshair.SpinSpeed = Value
            UpdateCrosshair()
        end
    })

    UpdateCrosshair()

    return {
        CrosshairParts = CrosshairParts,
        ServiceConnections = ServiceConnections
    }
end
