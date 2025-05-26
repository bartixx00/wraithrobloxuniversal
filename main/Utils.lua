local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

return {
    IsAlive = function(Player)
        return Player and Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") and Player.Character:FindFirstChildOfClass("Humanoid").Health > 0
    end,
    
    CanSeePlayer = function(Player, Config)
        if not Player or not Player.Character then return false end
        local TargetPart = Player.Character:FindFirstChild(Config.AimBot.CurrentBone)
        if not TargetPart then
            TargetPart = Player.Character:FindFirstChild("HumanoidRootPart")
        end
        if not TargetPart then return false end

        local RayOrigin = Camera.CFrame.Position
        local RayDirection = (TargetPart.Position - RayOrigin).Unit * 1000
        local RaycastParams = RaycastParams.new()
        RaycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Player.Character}
        RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        local Result = workspace:Raycast(RayOrigin, RayDirection, RaycastParams)

        if Result and Result.Instance then
            local HitPart = Result.Instance
            if HitPart:IsDescendantOf(Player.Character) then
                return true
            end
        end
        return false
    end,
    
    GetClosestPlayer = function(Config)
        local ClosestPlayer = nil
        local ClosestDistance = Config.AimBot.FOV
        local MousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

        for _, Player in pairs(Players:GetPlayers()) do
            if Player == LocalPlayer then continue end
            if not Player.Character then continue end
            if not Utils.IsAlive(Player) then continue end

            if Config.AimBot.TeamCheck and Player.TeamColor == LocalPlayer.TeamColor then continue end

            local TargetPart = Player.Character:FindFirstChild(Config.AimBot.CurrentBone)
            if not TargetPart then
                TargetPart = Player.Character:FindFirstChild("HumanoidRootPart")
            end
            if not TargetPart then continue end

            local ScreenPos, OnScreen = Camera:WorldToViewportPoint(TargetPart.Position)
            if not OnScreen then continue end

            local Distance = (MousePos - Vector2.new(ScreenPos.X, ScreenPos.Y)).Magnitude
            if Distance < ClosestDistance then
                if Config.AimBot.WallCheck then
                    if Utils.CanSeePlayer(Player, Config) then
                        ClosestDistance = Distance
                        ClosestPlayer = Player
                    end
                else
                    ClosestDistance = Distance
                    ClosestPlayer = Player
                end
            end
        end

        return ClosestPlayer
    end
}
