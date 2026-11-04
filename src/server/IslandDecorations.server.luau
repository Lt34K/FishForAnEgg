-- Decorative map details; no expensive loops or physics.
local world=workspace:WaitForChild("FishWorld",20)
if not world then return end
local decorations=Instance.new("Folder")
decorations.Name="IslandDecorations"
decorations.Parent=world
local function block(name,size,pos,color,material)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size
    p.Position=pos
    p.Color=color
    p.Material=material or Enum.Material.SmoothPlastic
    p.Anchored=true
    p.Parent=decorations
    return p
end
-- Walkway links the center of the rear plots to the fishing pier.
block("CentralPath",Vector3.new(12,.18,83),Vector3.new(0,5.1,-5),Color3.fromRGB(210,190,152),Enum.Material.Cobblestone)
block("PierEntrance",Vector3.new(12,.18,13),Vector3.new(0,5.15,-53),Color3.fromRGB(210,190,152),Enum.Material.Cobblestone)
-- Lamps beside the walkway and pier.
for _,z in ipairs({-45,-18,12,42}) do
    for _,x in ipairs({-9,9}) do
        block("LampPost",Vector3.new(.55,8,.55),Vector3.new(x,9,z),Color3.fromRGB(78,68,59),Enum.Material.Metal)
        local light=block("Lamp",Vector3.new(1.8,1.8,1.8),Vector3.new(x,13.3,z),Color3.fromRGB(255,226,144),Enum.Material.Neon)
        local point=Instance.new("PointLight")
        point.Range=16
        point.Brightness=.65
        point.Parent=light
    end
end
-- Trees on the perimeter, leaving the base pads clear.
for _,x in ipairs({-111,-104,104,111}) do
    for _,z in ipairs({-42,0,48}) do
        block("TreeTrunk",Vector3.new(2.2,9,2.2),Vector3.new(x,9.5,z),Color3.fromRGB(117,77,49),Enum.Material.Wood)
        local leaves=block("TreeCrown",Vector3.new(11,11,11),Vector3.new(x,17,z),Color3.fromRGB(60,153,75),Enum.Material.Grass)
        leaves.Shape=Enum.PartType.Ball
    end
end
-- Signs and fishing markers.
local sign=block("FishingSign",Vector3.new(10,4,.6),Vector3.new(0,9,-60),Color3.fromRGB(123,83,54),Enum.Material.Wood)
local surface=Instance.new("SurfaceGui")
surface.Face=Enum.NormalId.Front
surface.Parent=sign
local text=Instance.new("TextLabel")
text.Size=UDim2.fromScale(1,1)
text.BackgroundTransparency=1
text.TextColor3=Color3.new(1,1,1)
text.Font=Enum.Font.GothamBold
text.TextScaled=true
text.Text="FISH FOR AN EGG"
text.Parent=surface
print("Fish for an Egg : island scenery created")

-- Two permanent shops beside the central route, clear of the six player bases.
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local shopOpen=ReplicatedStorage:FindFirstChild("OpenWorldShop") or Instance.new("RemoteEvent")
shopOpen.Name="OpenWorldShop"
shopOpen.Parent=ReplicatedStorage

local function createShop(kind,x,title,subtitle,primary,trim)
    local folder=Instance.new("Model")
    folder.Name=kind.."Stand"
    folder.Parent=decorations
    local function piece(name,size,offset,color,material)
        local p=block(name,size,Vector3.new(x,0,kind=="Luck" and 6 or -37)+offset,color,material)
        p.Parent=folder
        return p
    end
    piece("Floor",Vector3.new(15,.6,12),Vector3.new(0,5.3,0),trim,Enum.Material.WoodPlanks)
    for _,dx in ipairs({-6.5,6.5}) do
        for _,dz in ipairs({-4.8,4.8}) do
            piece("Post",Vector3.new(.8,7,.8),Vector3.new(dx,9,dz),primary,Enum.Material.Wood)
        end
    end
    piece("Roof",Vector3.new(16,1,13),Vector3.new(0,12.8,0),primary,Enum.Material.SmoothPlastic)
    piece("RoofStripe",Vector3.new(16,.35,1.2),Vector3.new(0,13.4,-5.7),trim,Enum.Material.Neon)
    local counter=piece("Counter",Vector3.new(11,2,2),Vector3.new(0,6.8,-3.6),primary,Enum.Material.Wood)
    piece("CounterTop",Vector3.new(12,.3,2.7),Vector3.new(0,7.95,-3.6),trim,Enum.Material.SmoothPlastic)
    local sign=piece("ShopSign",Vector3.new(12,2.7,.5),Vector3.new(0,11.2,-5.1),primary,Enum.Material.SmoothPlastic)
    local surface=Instance.new("SurfaceGui")
    surface.Face=Enum.NormalId.Front
    surface.Parent=sign
    local label=Instance.new("TextLabel")
    label.Size=UDim2.fromScale(1,1)
    label.BackgroundTransparency=1
    label.TextColor3=Color3.new(1,1,1)
    label.TextStrokeTransparency=.4
    label.Font=Enum.Font.GothamBold
    label.TextScaled=true
    label.Text=title
    label.Parent=surface
    local floating=Instance.new("BillboardGui")
    floating.Size=UDim2.fromOffset(210,45)
    floating.StudsOffset=Vector3.new(0,3,0)
    floating.AlwaysOnTop=true
    floating.Parent=sign
    local floatingLabel=Instance.new("TextLabel")
    floatingLabel.Size=UDim2.fromScale(1,1)
    floatingLabel.BackgroundTransparency=1
    floatingLabel.TextColor3=trim
    floatingLabel.TextStrokeTransparency=.2
    floatingLabel.Font=Enum.Font.GothamBold
    floatingLabel.TextScaled=true
    floatingLabel.Text=subtitle
    floatingLabel.Parent=floating
    local prompt=Instance.new("ProximityPrompt")
    prompt.Name="OpenShop"
    prompt.ActionText="Ouvrir la boutique"
    prompt.ObjectText=title
    prompt.HoldDuration=.15
    prompt.MaxActivationDistance=12
    prompt.RequiresLineOfSight=false
    prompt.Parent=counter
    prompt.Triggered:Connect(function(player)
        shopOpen:FireClient(player,kind)
    end)
    -- Small themed items make the stands recognizable from the path.
    if kind=="Rods" then
        for i=1,3 do
            local rod=piece("DisplayRod"..i,Vector3.new(.22,4,.22),Vector3.new((i-2)*2.5,9,-2.5),Color3.fromRGB(201,155,81),Enum.Material.Wood)
            rod.Orientation=Vector3.new(0,0,18)
        end
    else
        for i=1,3 do
            local gem=piece("RobuxCrystal"..i,Vector3.new(1.3,1.3,1.3),Vector3.new((i-2)*2.8,9,-2.6),Color3.fromRGB(103,239,220),Enum.Material.Neon)
            gem.Shape=Enum.PartType.Ball
            local light=Instance.new("PointLight")
            light.Brightness=.7
            light.Range=7
            light.Parent=gem
        end
    end
end
createShop("Rods",-36,"CANNES","Acheter avec des $",Color3.fromRGB(119,76,42),Color3.fromRGB(245,199,87))
createShop("Robux",36,"BOUTIQUE ROBUX","Bonus et exclusivités",Color3.fromRGB(63,53,122),Color3.fromRGB(112,244,213))
createShop("Luck",34,"BOOSTS CHANCE","Potions et améliorations",Color3.fromRGB(37,116,68),Color3.fromRGB(139,255,112))

-- Coastal scenery: deterministic, lightweight, and outside the six build plots.
local scenery=Instance.new("Folder")
scenery.Name="CoastalScenery"
scenery.Parent=world
local function scenicPart(name,size,pos,color,material,shape)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size
    p.Position=pos
    p.Color=color
    p.Material=material or Enum.Material.SmoothPlastic
    p.Anchored=true
    p.CanCollide=false
    if shape then p.Shape=shape end
    p.Parent=scenery
    return p
end
local function tree(x,z,scale,palm)
    local trunk=scenicPart("TreeTrunk",Vector3.new(1.5*scale,8*scale,1.5*scale),Vector3.new(x,5+4*scale,z),Color3.fromRGB(116,77,48),Enum.Material.Wood)
    if palm then
        for i=1,5 do
            local angle=i*math.pi*2/5
            local leaf=scenicPart("PalmFrond",Vector3.new(1.8*scale,.6*scale,8*scale),Vector3.new(x+math.sin(angle)*2.7*scale,5+8.2*scale,z+math.cos(angle)*2.7*scale),Color3.fromRGB(46,156,82),Enum.Material.Grass)
            leaf.Orientation=Vector3.new(0,math.deg(angle),12)
        end
    else
        for _,offset in ipairs({Vector3.new(0,7,0),Vector3.new(2,5,0),Vector3.new(-2,5,0)}) do
            scenicPart("TreeCanopy",Vector3.new(6*scale,6*scale,6*scale),Vector3.new(x,5+4*scale,z)+offset*scale,Color3.fromRGB(48,143+math.floor(scale*8),77),Enum.Material.Grass,Enum.PartType.Ball)
        end
    end
end
for _,z in ipairs({-52,-26,4,30,55}) do
    tree(-115,z,.8,z<-30)
    tree(115,z,.8,z<-30)
end
for _,x in ipairs({-103,-88,88,103}) do
    tree(x,60,.7,false)
end
local rng=Random.new(82716)
for i=1,48 do
    local x=rng:NextNumber(-116,116)
    local z=rng:NextNumber(-65,65)
    if math.abs(x)>100 or math.abs(z)>54 then
        scenicPart("Wildflower",Vector3.new(.5,.7,.5),Vector3.new(x,5.6,z),({Color3.fromRGB(255,219,78),Color3.fromRGB(249,139,181),Color3.fromRGB(211,225,255)})[i%3+1],Enum.Material.Neon,Enum.PartType.Ball)
    end
end
-- Layered angular cliffs, not spherical blobs. All scenery is non-collidable.
local function wedge(name,size,cf,color,material)
    local p=Instance.new("WedgePart")
    p.Name=name
    p.Size=size
    p.CFrame=cf
    p.Anchored=true
    p.CanCollide=false
    p.Color=color
    p.Material=material or Enum.Material.Slate
    p.Parent=scenery
    return p
end
local distant={
    {x=-275,z=-285,w=105,d=92,h=31},
    {x=268,z=-320,w=130,d=105,h=43},
    {x=-320,z=180,w=90,d=85,h=27},
    {x=330,z=175,w=115,d=95,h=34},
    {x=0,z=-345,w=130,d=110,h=47},
}
for i,land in ipairs(distant) do
    local baseY=-3
    scenicPart("CliffPlateau"..i,Vector3.new(land.w,9,land.d),Vector3.new(land.x,baseY+7,land.z),Color3.fromRGB(110,113,107),Enum.Material.Slate)
    scenicPart("GrassyTop"..i,Vector3.new(land.w-8,3,land.d-8),Vector3.new(land.x,baseY+13,land.z),Color3.fromRGB(75,161,83),Enum.Material.Grass)
    for side=-1,1,2 do
        wedge("AngledCliff",Vector3.new(land.w*.48,land.h,land.d*.65),
            CFrame.new(land.x+side*land.w*.28,baseY+land.h*.5,land.z)*CFrame.Angles(0,side*math.rad(25),0),
            Color3.fromRGB(119,127,126),Enum.Material.Rock)
    end
    for j=1,5 do
        local px=land.x+((j*31)%math.floor(land.w-20))-(land.w-20)/2
        local pz=land.z+((j*17)%math.floor(land.d-20))-(land.d-20)/2
        scenicPart("IslandPineTrunk",Vector3.new(2,9,2),Vector3.new(px,baseY+20,pz),Color3.fromRGB(101,72,52),Enum.Material.Wood)
        for tier=1,3 do
            wedge("PineNeedles",Vector3.new(11-tier*2,6,11-tier*2),
                CFrame.new(px,baseY+22+tier*3,pz)*CFrame.Angles(0,math.rad(45),0),
                Color3.fromRGB(36,113+tier*8,70),Enum.Material.Grass)
        end
    end
end
-- Jagged mountain ridges: intersecting angled rock faces with separate snow ridges.
for i=1,7 do
    local x=(i-4)*64
    local h=70+((i*19)%55)
    local z=-445-((i*13)%38)
    wedge("MountainFace"..i,Vector3.new(88,h,90),CFrame.new(x,-4+h*.5,z)*CFrame.Angles(0,math.rad(25),0),
        Color3.fromRGB(94,112,130),Enum.Material.Rock)
    wedge("MountainShadow"..i,Vector3.new(68,h*.82,75),CFrame.new(x+20,-4+h*.43,z+8)*CFrame.Angles(0,math.rad(145),0),
        Color3.fromRGB(69,91,115),Enum.Material.Slate)
    wedge("SnowRidge"..i,Vector3.new(32,h*.26,40),CFrame.new(x-4,-4+h*.84,z-8)*CFrame.Angles(0,math.rad(25),0),
        Color3.fromRGB(234,242,250),Enum.Material.Snow)
end
-- A little dockside detail and a lighthouse at the far end of the main island.
for i=1,6 do
    scenicPart("PierBollard",Vector3.new(1.2,2,1.2),Vector3.new((i%2==0 and 1 or -1)*8.8,6.4,-76-math.floor((i-1)/2)*26),Color3.fromRGB(90,62,46),Enum.Material.Wood)
end
scenicPart("LighthouseBase",Vector3.new(6,18,6),Vector3.new(-104,14,48),Color3.fromRGB(238,234,221),Enum.Material.Concrete,Enum.PartType.Cylinder)
local beacon=scenicPart("LighthouseBeacon",Vector3.new(7,3,7),Vector3.new(-104,24.5,48),Color3.fromRGB(255,233,133),Enum.Material.Neon,Enum.PartType.Ball)
local beaconLight=Instance.new("PointLight")
beaconLight.Range=38
beaconLight.Brightness=2
beaconLight.Parent=beacon

print("Fish for an Egg : boutiques et paysages côtiers créés")
