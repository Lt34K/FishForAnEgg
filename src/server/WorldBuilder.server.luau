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

-- Invisible coast barriers keep players on land; the pier has protective side rails.
local function barrier(name,size,position)
    local wall=part(name,size,CFrame.new(position),Color3.fromRGB(255,255,255),Enum.Material.SmoothPlastic)
    wall.Transparency=1
    wall.CanCollide=true
    wall.CanTouch=false
    wall.CastShadow=false
end
barrier("CoastWest",Vector3.new(3,22,154),Vector3.new(-122,10,0))
barrier("CoastEast",Vector3.new(3,22,154),Vector3.new(122,10,0))
barrier("CoastSouth",Vector3.new(244,22,3),Vector3.new(0,10,72))
barrier("CoastNorthLeft",Vector3.new(113,22,3),Vector3.new(-65,10,-72))
barrier("CoastNorthRight",Vector3.new(113,22,3),Vector3.new(65,10,-72))
for _,side in ipairs({-1,1}) do
    local rail=part("PierSafetyRail",Vector3.new(1,3,93),CFrame.new(side*9,6.8,-107),Color3.fromRGB(112,77,50),Enum.Material.Wood)
    rail.CanCollide=true
end
barrier("PierEnd",Vector3.new(19,4,1),Vector3.new(0,7,-155))
-- Falling or jumping into the ocean returns the player safely to the beach.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local elapsed=0
RunService.Heartbeat:Connect(function(dt)
    elapsed+=dt
    if elapsed<.5 then return end
    elapsed=0
    for _,player in ipairs(Players:GetPlayers()) do
        local character=player.Character
        local root=character and character:FindFirstChild("HumanoidRootPart")
        if root and root.Position.Y<0 then
            root.AssemblyLinearVelocity=Vector3.zero
            character:PivotTo(CFrame.new(0,9,-39))
        end
    end
end)

-- Soft coastal lighting, consistent across servers.
local Lighting=game:GetService("Lighting")
Lighting.ClockTime=15.3
Lighting.Brightness=2.2
Lighting.EnvironmentDiffuseScale=.55
Lighting.EnvironmentSpecularScale=.6
Lighting.Ambient=Color3.fromRGB(129,154,178)
Lighting.OutdoorAmbient=Color3.fromRGB(167,185,195)
local atmosphere=Lighting:FindFirstChild("FishCoastAtmosphere") or Instance.new("Atmosphere")
atmosphere.Name="FishCoastAtmosphere"
atmosphere.Density=.23
atmosphere.Offset=.15
atmosphere.Color=Color3.fromRGB(207,235,248)
atmosphere.Decay=Color3.fromRGB(116,157,191)
atmosphere.Haze=1.2
atmosphere.Parent=Lighting
-- Foam border and natural sand edge frame the island.
for _,side in ipairs({-1,1}) do
    local foam=part("ShoreFoam",Vector3.new(3,.2,148),CFrame.new(side*125,-4.4,0),Color3.fromRGB(197,245,248),Enum.Material.Neon)
    foam.Transparency=.45
    foam.CanCollide=false
end
for _,z in ipairs({-75,75}) do
    local foam=part("ShoreFoam",Vector3.new(248,.2,3),CFrame.new(0,-4.4,z),Color3.fromRGB(197,245,248),Enum.Material.Neon)
    foam.Transparency=.45
    foam.CanCollide=false
end

-- Remove the template baseplate only when its default name matches.
local baseplate = Workspace:FindFirstChild("Baseplate")
if baseplate and baseplate:IsA("BasePart") then
    baseplate:Destroy()
end

print("Fish for an Egg : ocean, island, pier and 6 base plots created")
