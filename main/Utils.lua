local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local function IsAlive(player)
    return player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0
end

local function GetClosestPlayer(Config)
    local ClosestDistance = math.huge
    local ClosestPlayer = nil
    local ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and IsAlive(Player) then
            if Config.AimBot.TeamCheck and Player.Team and LocalPlayer.Team and Player.Team == LocalPlayer.Team then
                continue
            end

            local Character = Player.Character
            local TargetPart = Character:FindFirstChild(Config.AimBot.CurrentBone)
            if not TargetPart then
                TargetPart = Character:FindFirstChild("HumanoidRootPart")
            end

            if TargetPart then
                local Vector, OnScreen = Camera:WorldToViewportPoint(TargetPart.Position)
                if OnScreen then
                    local Distance = (Vector2.new(Vector.X, Vector.Y) - ScreenCenter).Magnitude
                    if Distance < Config.AimBot.FOV and Distance < ClosestDistance then
                        if Config.AimBot.WallCheck then
                            local RaycastParams = RaycastParams.new()
                            RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist 
                            RaycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
                            
                            local Direction = (TargetPart.Position - Camera.CFrame.Position).Unit
                            local Distance3D = (TargetPart.Position - Camera.CFrame.Position).Magnitude
                            
                            local RaycastResult = workspace:Raycast(Camera.CFrame.Position, Direction * Distance3D, RaycastParams)
                            
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

return {
    IsAlive = IsAlive,
    GetClosestPlayer = GetClosestPlayer
}
