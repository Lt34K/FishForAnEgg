-- Premium environment pass: modular, deterministic and decorative-only.
local Lighting=game:GetService("Lighting")
local TweenService=game:GetService("TweenService")
local world=workspace:WaitForChild("FishWorld",30)
if not world then return end
local folder=Instance.new("Folder")
folder.Name="PremiumCoastalDetails"
folder.Parent=world

local function detail(name,size,cf,color,material)
    local obj=Instance.new("Part")
    obj.Name=name
    obj.Size=size
    obj.CFrame=cf
    obj.Color=color
    obj.Material=material or Enum.Material.SmoothPlastic
    obj.Anchored=true
    obj.CanCollide=false
    obj.CanTouch=false
    obj.CastShadow=false
    obj.Parent=folder
    return obj
end
local function line(name,a,b,width,color,material)
    local midpoint=(a+b)/2
    return detail(name,Vector3.new(width,width,(b-a).Magnitude),CFrame.lookAt(midpoint,b),color,material)
end

-- Soft light and warm highlights without forcing expensive graphics settings.
local bloom=Lighting:FindFirstChild("FishCoastBloom") or Instance.new("BloomEffect")
bloom.Name="FishCoastBloom"
bloom.Intensity=.22
bloom.Size=18
bloom.Threshold=1.6
bloom.Parent=Lighting
local color=Lighting:FindFirstChild("FishCoastGrade") or Instance.new("ColorCorrectionEffect")
color.Name="FishCoastGrade"
color.Saturation=.12
color.Contrast=.04
color.Brightness=.01
color.TintColor=Color3.fromRGB(255,248,236)
color.Parent=Lighting
local clouds=workspace.Terrain:FindFirstChild("FishCoastClouds") or Instance.new("Clouds")
clouds.Name="FishCoastClouds"
clouds.Cover=.31
clouds.Density=.32
clouds.Color=Color3.fromRGB(255,250,240)
clouds.Parent=workspace.Terrain

local function palm(x,z,size,tilt)
    local wood=Color3.fromRGB(147,101,64)
    local top=Vector3.new(x+tilt*3*size,5+11*size,z)
    for segment=1,5 do
        local a=Vector3.new(x+tilt*(segment-1)*.6*size,5+(segment-1)*2.2*size,z)
        local b=Vector3.new(x+tilt*segment*.6*size,5+segment*2.2*size,z)
        local trunk=line("CurvedPalmTrunk",a,b,1.15*size,wood,Enum.Material.Wood)
        trunk.CastShadow=true
    end
    for i=1,7 do
        local angle=(i/7)*math.pi*2
        local reach=Vector3.new(math.cos(angle)*6.7*size,-2.1*size,math.sin(angle)*6.7*size)
        local leaf=line("PalmLeaf",top,top+reach,1.8*size,Color3.fromRGB(35+(i%3)*12,144+(i%3)*12,76),Enum.Material.Grass)
        leaf.CastShadow=true
        local tip=line("PalmLeafTip",top+reach*.66,top+reach*1.18+Vector3.new(0,-1.3*size,0),1.05*size,Color3.fromRGB(45,157,83),Enum.Material.Grass)
        tip.CastShadow=true
    end
    for i=1,3 do
        local a=i*math.pi*2/3
        local coconut=detail("PalmCoconut",Vector3.new(1.1,1.1,1.1)*size,CFrame.new(top+Vector3.new(math.cos(a),-.5,math.sin(a))*size),Color3.fromRGB(109,71,46),Enum.Material.Wood)
        coconut.Shape=Enum.PartType.Ball
    end
end
for _,data in ipairs({
    {-111,-57,1.1,-.35},{111,-57,1.05,.35},
    {-113,0,.85,.25},{113,0,.9,-.3},
    {-114,57,1.1,-.25},{114,57,1.15,.25},
    {-88,-59,.8,.45},{88,-59,.85,-.45},
    {-45,-60,.7,.15},{45,-60,.8,-.2},
}) do
    palm(data[1],data[2],data[3],data[4])
end

-- Festival lights run above the central promenade, away from player movement.
for _,z in ipairs({-48,-21,9,41}) do
    for _,side in ipairs({-1,1}) do
        local x=side*12
        detail("FestoonPole",Vector3.new(.65,11,.65),CFrame.new(x,10.5,z),Color3.fromRGB(107,77,54),Enum.Material.Wood)
        detail("FestoonPoleTop",Vector3.new(1.15,.35,1.15),CFrame.new(x,16.2,z),Color3.fromRGB(255,199,97),Enum.Material.Metal)
    end
    local last=Vector3.new(-12,16,z)
    for i=1,12 do
        local x=-12+i*2
        local y=16-1.7*math.sin(math.pi*i/12)
        local point=Vector3.new(x,y,z)
        line("FestivalString",last,point,.09,Color3.fromRGB(55,65,70),Enum.Material.Metal)
        if i%2==0 then
            local bulb=detail("FestivalLight",Vector3.new(.8,1,.8),CFrame.new(point+Vector3.new(0,-.55,0)),i%4==0 and Color3.fromRGB(255,193,104) or Color3.fromRGB(255,238,180),Enum.Material.Neon)
            bulb.Shape=Enum.PartType.Ball
            if i%4==0 then
                local glow=Instance.new("PointLight")
                glow.Brightness=.4
                glow.Range=11
                glow.Parent=bulb
            end
        end
        last=point
    end
end

-- Beach boulders sit outside the buildable base plots.
local rocks=Random.new(23844)
for _,side in ipairs({-1,1}) do
    for i=1,17 do
        local x=side*(107+rocks:NextNumber(0,12))
        local z=rocks:NextNumber(-65,63)
        local s=rocks:NextNumber(1.1,3.6)
        local rock=detail("CoastalRock",Vector3.new(s*1.5,s,s*1.2),CFrame.new(x,5+s*.28,z)*CFrame.Angles(rocks:NextNumber(-.18,.18),rocks:NextNumber(0,6.28),rocks:NextNumber(-.16,.16)),Color3.fromRGB(125+rocks:NextInteger(0,25),135+rocks:NextInteger(0,15),129),Enum.Material.Slate)
        rock.Shape=Enum.PartType.Block
    end
end

-- Small, slowly moving decorative fish beyond the pier.
for i=1,12 do
    local x=(i%6-2.5)*22
    local z=-174-math.floor((i-1)/6)*31
    local p=detail("OceanFish",Vector3.new(3,.8,1.2),CFrame.new(x,-4.7,z),i%3==0 and Color3.fromRGB(255,182,111) or Color3.fromRGB(88,219,223),Enum.Material.SmoothPlastic)
    p.Shape=Enum.PartType.Ball
    p.Transparency=.27
    local drift=7+(i%4)*2
    TweenService:Create(p,TweenInfo.new(3.5+i*.28,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{
        Position=p.Position+Vector3.new(drift,0,0)
    }):Play()
end

print("Fish for an Egg : premium coastal lighting, palms, decor and sea life ready")
