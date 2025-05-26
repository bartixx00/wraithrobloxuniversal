local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

return function(Config, CrosshairParts, ServiceConnections)
    local function AddCrosshair()
        local AxisX, AxisY = Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2
        ServiceConnections.AxisConnection = RunService.RenderStepped:Connect(function()
            if Config.Crosshair.Enabled then
                if Config.Crosshair.Type == 1 then
                    AxisX, AxisY = UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y
                elseif Config.Crosshair.Type == 2 then
                    AxisX, AxisY = Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2
                end
            end
        end)
        ServiceConnections.CrosshairConnection = RunService.RenderStepped:Connect(function()
            if Config.Crosshair.Enabled then
                for _, line in pairs({CrosshairParts.LeftLine, CrosshairParts.RightLine, CrosshairParts.TopLine, CrosshairParts.BottomLine}) do
                    line.Visible = true
                    line.Color = Config.Crosshair.Color
                    line.Thickness = Config.Crosshair.Thickness
                    line.Transparency = Config.Crosshair.Transparency
                end
                CrosshairParts.LeftLine.From = Vector2.new(AxisX - (math.cos(math.rad(Config.Crosshair.Rotation)) * Config.Crosshair.GapSize), AxisY - (math.sin(math.rad(Config.Crosshair.Rotation)) * Config.Crosshair.GapSize))
                CrosshairParts.LeftLine.To = Vector2.new(AxisX - (math.cos(math.rad(Config.Crosshair.Rotation)) * (Config.Crosshair.Size + Config.Crosshair.GapSize)), AxisY - (math.sin(math.rad(Config.Crosshair.Rotation)) * (Config.Crosshair.Size + Config.Crosshair.GapSize)))
                CrosshairParts.RightLine.From = Vector2.new(AxisX + (math.cos(math.rad(Config.Crosshair.Rotation)) * Config.Crosshair.GapSize), AxisY + (math.sin(math.rad(Config.Crosshair.Rotation)) * Config.Crosshair.GapSize))
                CrosshairParts.RightLine.To = Vector2.new(AxisX + (math.cos(math.rad(Config.Crosshair.Rotation)) * (Config.Crosshair.Size + Config.Crosshair.GapSize)), AxisY + (math.sin(math.rad(Config.Crosshair.Rotation)) * (Config.Crosshair.Size + Config.Crosshair.GapSize)))
                CrosshairParts.TopLine.From = Vector2.new(AxisX - (math.sin(math.rad(-Config.Crosshair.Rotation)) * Config.Crosshair.GapSize), AxisY - (math.cos(math.rad(-Config.Crosshair.Rotation)) * Config.Crosshair.GapSize))
                CrosshairParts.TopLine.To = Vector2.new(AxisX - (math.sin(math.rad(-Config.Crosshair.Rotation)) * (Config.Crosshair.Size + Config.Crosshair.GapSize)), AxisY - (math.cos(math.rad(-Config.Crosshair.Rotation)) * (Config.Crosshair.Size + Config.Crosshair.GapSize)))
                CrosshairParts.BottomLine.From = Vector2.new(AxisX + (math.sin(math.rad(-Config.Crosshair.Rotation)) * Config.Crosshair.GapSize), AxisY + (math.cos(math.rad(-Config.Crosshair.Rotation)) * Config.Crosshair.GapSize))
                CrosshairParts.BottomLine.To = Vector2.new(AxisX + (math.sin(math.rad(-Config.Crosshair.Rotation)) * (Config.Crosshair.Size + Config.Crosshair.GapSize)), AxisY + (math.cos(math.rad(-Config.Crosshair.Rotation)) * (Config.Crosshair.Size + Config.Crosshair.GapSize)))
                CrosshairParts.CenterDot.Visible = Config.Crosshair.CenterDot
                CrosshairParts.CenterDot.Color = Config.Crosshair.CenterDotColor
                CrosshairParts.CenterDot.Radius = Config.Crosshair.CenterDotSize
                CrosshairParts.CenterDot.Transparency = Config.Crosshair.CenterDotTransparency
                CrosshairParts.CenterDot.Filled = Config.Crosshair.CenterDotFilled
                CrosshairParts.CenterDot.Thickness = Config.Crosshair.CenterDotThickness
                CrosshairParts.CenterDot.Position = Vector2.new(AxisX, AxisY)
            else
                for _, line in pairs({CrosshairParts.LeftLine, CrosshairParts.RightLine, CrosshairParts.TopLine, CrosshairParts.BottomLine, CrosshairParts.CenterDot}) do
                    line.Visible = false
                end
            end
        end)
    end

    local CrosshairTab = Window:CreateTab("🔫 Crosshair", nil)

    CrosshairTab:CreateToggle({
        Name = "Enable Crosshair",
        CurrentValue = Config.Crosshair.Enabled,
        Callback = function(Value)
            Config.Crosshair.Enabled = Value
        end
    })

    CrosshairTab:CreateDropdown({
        Name = "Crosshair Type",
        Options = {"Mouse", "Center"},
        CurrentOption = Config.Crosshair.Type == 1 and "Mouse" or "Center",
        Callback = function(Option)
            Config.Crosshair.Type = Option == "Mouse" and 1 or 2
        end
    })

    CrosshairTab:CreateSlider({
        Name = "Crosshair Size",
        Range = {5, 20},
        Increment = 1,
        CurrentValue = Config.Crosshair.Size,
        Callback = function(Value)
            Config.Crosshair.Size = Value
        end
    })

    CrosshairTab:CreateSlider({
        Name = "Crosshair Thickness",
        Range = {1, 5},
        Increment = 1,
        CurrentValue = Config.Crosshair.Thickness,
        Callback = function(Value)
            Config.Crosshair.Thickness = Value
        end
    })

    CrosshairTab:CreateColorPicker({
        Name = "Crosshair Color",
        Color = Config.Crosshair.Color,
        Callback = function(Value)
            Config.Crosshair.Color = Value
        end
    })

    CrosshairTab:CreateSlider({
        Name = "Crosshair Transparency",
        Range = {0, 1},
        Increment = 0.1,
        CurrentValue = Config.Crosshair.Transparency,
        Callback = function(Value)
            Config.Crosshair.Transparency = Value
        end
    })

    CrosshairTab:CreateSlider({
        Name = "Crosshair Gap Size",
        Range = {0, 10},
        Increment = 1,
        CurrentValue = Config.Crosshair.GapSize,
        Callback = function(Value)
            Config.Crosshair.GapSize = Value
        end
    })

    CrosshairTab:CreateSlider({
        Name = "Crosshair Rotation",
        Range = {0, 360},
        Increment = 1,
        CurrentValue = Config.Crosshair.Rotation,
        Callback = function(Value)
            Config.Crosshair.Rotation = Value
        end
    })

    CrosshairTab:CreateToggle({
        Name = "Center Dot",
        CurrentValue = Config.Crosshair.CenterDot,
        Callback = function(Value)
            Config.Crosshair.CenterDot = Value
        end
    })

    CrosshairTab:CreateColorPicker({
        Name = "Center Dot Color",
        Color = Config.Crosshair.CenterDotColor,
        Callback = function(Value)
            Config.Crosshair.CenterDotColor = Value
        end
    })

    CrosshairTab:CreateSlider({
        Name = "Center Dot Size",
        Range = {1, 5},
        Increment = 1,
        CurrentValue = Config.Crosshair.CenterDotSize,
        Callback = function(Value)
            Config.Crosshair.CenterDotSize = Value
        end
    })

    CrosshairTab:CreateSlider({
        Name = "Center Dot Transparency",
        Range = {0, 1},
        Increment = 0.1,
        CurrentValue = Config.Crosshair.CenterDotTransparency,
        Callback = function(Value)
            Config.Crosshair.CenterDotTransparency = Value
        end
    })

    CrosshairTab:CreateToggle({
        Name = "Center Dot Filled",
        CurrentValue = Config.Crosshair.CenterDotFilled,
        Callback = function(Value)
            Config.Crosshair.CenterDotFilled = Value
        end
    })

    AddCrosshair()

    return {
        CrosshairParts = CrosshairParts,
        ServiceConnections = ServiceConnections
    }
end
