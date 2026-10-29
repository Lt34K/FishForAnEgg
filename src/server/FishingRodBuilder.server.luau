-- Prototype wooden fishing rod. The rod is a real Roblox Tool, not a UI button.
local StarterPack = game:GetService("StarterPack")
local Players = game:GetService("Players")

local function buildRod()
    local tool = Instance.new("Tool")
    tool.Name = "Canne en bois"
    tool.ToolTip = "Équipe ta canne pour pêcher"
    tool.CanBeDropped = false
    tool.RequiresHandle = true

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(0.28, 4.2, 0.28)
    handle.Color = Color3.fromRGB(133, 83, 44)
    handle.Material = Enum.Material.Wood
    handle.CanCollide = false
    handle.Massless = true
    handle.Parent = tool

    local tip = Instance.new("Part")
    tip.Name = "RodTip"
    tip.Size = Vector3.new(0.13, 1.8, 0.13)
    tip.Color = Color3.fromRGB(180, 126, 70)
    tip.Material = Enum.Material.Wood
    tip.CanCollide = false
    tip.Massless = true
    tip.CFrame = handle.CFrame * CFrame.new(0, 2.9, 0)
    tip.Parent = tool

    local joint = Instance.new("WeldConstraint")
    joint.Part0 = handle
    joint.Part1 = tip
    joint.Parent = handle

    local reel = Instance.new("Part")
    reel.Name = "Reel"
    reel.Shape = Enum.PartType.Cylinder
    reel.Size = Vector3.new(0.65, 0.38, 0.65)
    reel.Color = Color3.fromRGB(67, 75, 82)
    reel.Material = Enum.Material.Metal
    reel.CanCollide = false
    reel.Massless = true
    reel.CFrame = handle.CFrame * CFrame.new(0.3, -0.6, 0)
    reel.Parent = tool

    local reelJoint = Instance.new("WeldConstraint")
    reelJoint.Part0 = handle
    reelJoint.Part1 = reel
    reelJoint.Parent = handle

    tool.Grip = CFrame.new(0, -1.2, 0) * CFrame.Angles(math.rad(-20), 0, 0)
    return tool
end

local rod = StarterPack:FindFirstChild("Canne en bois")
if not rod then
    rod = buildRod()
    rod.Parent = StarterPack
end

-- Also grant it to players already present when this script starts.
local function giveRod(player)
    local backpack = player:WaitForChild("Backpack")
    if not backpack:FindFirstChild(rod.Name) and not (player.Character and player.Character:FindFirstChild(rod.Name)) then
        rod:Clone().Parent = backpack
    end
end
Players.PlayerAdded:Connect(giveRod)
for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(giveRod, player)
end

print("Fish for an Egg : canne en bois 3D prête")
