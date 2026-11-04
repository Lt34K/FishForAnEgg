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
        local p=block(name,size,Vector3.new(x,0,kind=="Luck" and 28 or -37)+offset,color,material)
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
createShop("Rods",-23,"CANNES","Acheter avec des $",Color3.fromRGB(119,76,42),Color3.fromRGB(245,199,87))
createShop("Robux",23,"BOUTIQUE ROBUX","Bonus et exclusivités",Color3.fromRGB(63,53,122),Color3.fromRGB(112,244,213))
createShop("Luck",0,"BOOSTS CHANCE","Potions et améliorations",Color3.fromRGB(37,116,68),Color3.fromRGB(139,255,112))
print("Fish for an Egg : stands Cannes et Robux créés")
