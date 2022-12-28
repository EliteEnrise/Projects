local Meter = script.Parent
local Reset = false
local ranPrev = false

local function Fix(Number)
    return tostring(math.floor(Number * 100) / 100)
end

local function UpdateValue(Current)
    local Multiplier = Current / 6
    Meter["1"].Text = Fix(Multiplier)
    Meter["6"].Text = Current
    for i = 2, 5 do
        Meter[tostring(i)].Text = Fix(Multiplier + tonumber(Meter[tostring(i - 1)].Text))
    end
end

local function onCharacter()
    if ranPrev then
        Reset = true
        repeat task.wait() until not Reset
    end
    local Character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
    Character:WaitForChild("Humanoid", math.huge):GetPropertyChangedSignal("WalkSpeed"):Connect(function(...)
        UpdateValue(Character.Humanoid.WalkSpeed)
    end)
    UpdateValue(Character.Humanoid.WalkSpeed)

    Character.Humanoid.WalkSpeed = math.random(1, 200)
    ranPrev = true
    task.spawn(function()
        while task.wait(.1) do
            if Reset then
                Reset = false
                break
            end
            local Velo = Character.HumanoidRootPart.Velocity.Magnitude
            local MaxValue = Character.Humanoid.WalkSpeed
            if Velo > MaxValue then continue end
            local Degree = (180 / MaxValue) * Velo
            game:GetService("TweenService"):Create(Meter.Indicator, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0), {Rotation = Degree - 90}):Play()
        end
    end)
end
onCharacter()
game.Players.LocalPlayer.CharacterAdded:Connect(onCharacter)
