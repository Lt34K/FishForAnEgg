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
