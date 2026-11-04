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
spawn.CFrame = CFrame.new(0, 5.6, 23)
spawn.Anchored = true
spawn.Neutral = true
spawn.Material = Enum.Material.Neon
spawn.Color = Color3.fromRGB(87, 229, 185)
spawn.Parent = world

-- The default Roblox neon spawn pad is hidden under a designed arrival plaza.
spawn.Transparency=1
spawn.CanCollide=false
local arrival=part("ArrivalCircle",Vector3.new(.18,15,15),
    CFrame.new(0,5.15,23)*CFrame.Angles(0,0,math.rad(90)),
    Color3.fromRGB(217,193,148),Enum.Material.Cobblestone)
arrival.CanCollide=false
local arrivalCenter=part("ArrivalCenter",Vector3.new(.2,9,9),
    CFrame.new(0,5.28,23)*CFrame.Angles(0,0,math.rad(90)),
    Color3.fromRGB(240,220,175),Enum.Material.Sand)
arrivalCenter.CanCollide=false
-- A readable sand perimeter softens the rectangular lawn into a beach boardwalk.
for _,z in ipairs({-67,67}) do
    local strip=part("UpperBeach",Vector3.new(233,.18,8),
        CFrame.new(0,5.09,z),Color3.fromRGB(239,214,151),Enum.Material.Sand)
    strip.CanCollide=false
end
for _,x in ipairs({-116,116}) do
    local strip=part("UpperBeach",Vector3.new(8,.18,135),
        CFrame.new(x,5.09,0),Color3.fromRGB(239,214,151),Enum.Material.Sand)
    strip.CanCollide=false
end

-- A pier heading toward the sea on the north side.
part("FishingPier", Vector3.new(18, 2, 95), CFrame.new(-18, 4.5, -107), Color3.fromRGB(143, 97, 59), Enum.Material.WoodPlanks)
for _, z in ipairs({-75, -105, -135}) do
    for _, x in ipairs({-7, 7}) do
        part("PierSupport", Vector3.new(2, 13, 2), CFrame.new(-18+x, -1.5, z), Color3.fromRGB(99, 65, 42), Enum.Material.Wood)
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
barrier("CoastNorthLeft",Vector3.new(92,22,3),Vector3.new(-75,10,-72))
barrier("CoastNorthRight",Vector3.new(130,22,3),Vector3.new(57,10,-72))
-- The physical safety wall is invisible; players see an open timber railing.
for _,side in ipairs({-1,1}) do
    local safety=part("PierSafetyWall",Vector3.new(.9,4,95),CFrame.new(-18+side*9.1,7.4,-107),Color3.fromRGB(112,77,50),Enum.Material.Wood)
    safety.Transparency=1
    safety.CastShadow=false
    safety.CanTouch=false
    for _,height in ipairs({7,9}) do
        part("PierHandrail",Vector3.new(.36,.32,95),CFrame.new(-18+side*9.1,height,-107),Color3.fromRGB(145,101,66),Enum.Material.WoodPlanks)
    end
    for z=-152,-62,10 do
        part("PierRailingPost",Vector3.new(.9,4,.9),CFrame.new(-18+side*9.1,7.2,z),Color3.fromRGB(106,73,48),Enum.Material.Wood)
        local cap=part("PierPostCap",Vector3.new(1.25,.3,1.25),CFrame.new(-18+side*9.1,9.3,z),Color3.fromRGB(222,177,109),Enum.Material.WoodPlanks)
        cap.CanCollide=false
    end
end
for z=-152,-62,4 do
    local seam=part("PierPlankSeam",Vector3.new(17.7,.08,.13),CFrame.new(-18,5.53,z),Color3.fromRGB(93,63,43),Enum.Material.Wood)
    seam.CanCollide=false
end
barrier("PierEnd",Vector3.new(19,4,1),Vector3.new(-18,7,-155))
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
            character:PivotTo(CFrame.new(0,9,23))
        end
    end
end)

-- Orient new arrivals toward the seaside market, not the bases behind them.
local function faceMarket(character)
    task.delay(.25,function()
        local root=character and character:FindFirstChild("HumanoidRootPart")
        if root and math.abs(root.Position.X)<9 and math.abs(root.Position.Z-23)<10 then
            local pos=root.Position
            character:PivotTo(CFrame.lookAt(pos,pos+Vector3.new(0,0,-12)))
        end
    end)
end
local function hookPlayer(player)
    player.CharacterAdded:Connect(faceMarket)
    if player.Character then faceMarket(player.Character) end
end
Players.PlayerAdded:Connect(hookPlayer)
for _,plr in ipairs(Players:GetPlayers()) do hookPlayer(plr) end

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
