-- First playable map for Fish for an Egg. Generated at server start.
local Workspace = game:GetService("Workspace")
local existing = Workspace:FindFirstChild("FishWorld")
if existing then existing:Destroy() end
local world = Instance.new("Folder")
world.Name = "FishWorld"
world.Parent = Workspace

local function part(name, size, cf, color, material, parent)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Anchored = true
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent or world
    return p
end

-- Ocean is visual for now; actual fishing mechanics come next.
local ocean = part("Ocean", Vector3.new(850, 2, 850), CFrame.new(0, -5, 0), Color3.fromRGB(35, 155, 220), Enum.Material.Glass)
ocean.Transparency = 0.22
ocean.CanCollide = false

local island = part("MainIsland", Vector3.new(240, 10, 140), CFrame.new(0, 0, 0), Color3.fromRGB(91, 191, 93), Enum.Material.Grass)
part("Beach", Vector3.new(250, 2, 150), CFrame.new(0, -5.7, 0), Color3.fromRGB(239, 213, 145), Enum.Material.Sand)

local spawn = Instance.new("SpawnLocation")
spawn.Name = "FishSpawn"
spawn.Size = Vector3.new(12, 1, 12)
spawn.CFrame = CFrame.new(0, 5.6, -39)
spawn.Anchored = true
spawn.Neutral = true
spawn.Material = Enum.Material.Neon
spawn.Color = Color3.fromRGB(87, 229, 185)
spawn.Parent = world

-- A pier heading toward the sea on the north side.
part("FishingPier", Vector3.new(18, 2, 95), CFrame.new(0, 4.5, -107), Color3.fromRGB(143, 97, 59), Enum.Material.WoodPlanks)
for _, z in ipairs({-75, -105, -135}) do
    for _, x in ipairs({-7, 7}) do
        part("PierSupport", Vector3.new(2, 13, 2), CFrame.new(x, -1.5, z), Color3.fromRGB(99, 65, 42), Enum.Material.Wood)
    end
end

local bases = Instance.new("Folder")
bases.Name = "BasePlots"
bases.Parent = world
-- Four bases at the back, two at the front on either side of the central path.
local positions = {
    Vector3.new(-81, 5.5, 37),
    Vector3.new(-27, 5.5, 37),
    Vector3.new(27, 5.5, 37),
    Vector3.new(81, 5.5, 37),
    Vector3.new(-70, 5.5, -16),
    Vector3.new(70, 5.5, -16),
}
for i, position in ipairs(positions) do
    local pad = part("Base"..i, Vector3.new(42, 1, 33), CFrame.new(position), Color3.fromRGB(204, 222, 235), Enum.Material.SmoothPlastic, bases)
    pad:SetAttribute("BaseIndex", i)
    part("BaseBorder"..i, Vector3.new(44, 0.4, 35), CFrame.new(position - Vector3.new(0, 0.45, 0)), Color3.fromRGB(49, 107, 150), Enum.Material.SmoothPlastic, bases)
end

-- Remove the template baseplate only when its default name matches.
local baseplate = Workspace:FindFirstChild("Baseplate")
if baseplate and baseplate:IsA("BasePart") then
    baseplate:Destroy()
end

print("Fish for an Egg : ocean, island, pier and 6 base plots created")
