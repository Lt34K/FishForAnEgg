-- Premium, optimized cosmetic layer for the coastal simulator.
-- Every new prop is anchored and non-collidable; the six base plots stay playable.
local world=workspace:WaitForChild("FishWorld",30)
if not world then return end
local islandDecor=world:WaitForChild("IslandDecorations",30)
if not islandDecor then return end
local existing=world:FindFirstChild("PremiumWorld")
if existing then existing:Destroy() end
local folder=Instance.new("Folder")
folder.Name="PremiumWorld"
folder.Parent=world
local TweenService=game:GetService("TweenService")
local function part(name,sz,cf,color,mat,shape)
    local p=Instance.new(shape=="Wedge" and "WedgePart" or "Part")
    p.Name=name
    p.Size=sz
    p.CFrame=cf
    p.Color=color
    p.Material=mat or Enum.Material.SmoothPlastic
    p.Anchored=true
    p.CanCollide=false
    p.CanTouch=false
    p.CanQuery=false
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    if shape=="Ball" or shape=="Cylinder" then p.Shape=Enum.PartType[shape] end
    p.Parent=folder
    return p
end
local function at(x,y,z) return CFrame.new(x,y,z) end
local wood=Color3.fromRGB(126,82,53)
local cream=Color3.fromRGB(249,236,200)
local gold=Color3.fromRGB(252,195,93)
local sea=Color3.fromRGB(72,206,229)
local navy=Color3.fromRGB(27,57,92)
local function light(parent,color,range,brightness)
    local l=Instance.new("PointLight")
    l.Color=color
    l.Range=range
    l.Brightness=brightness
    l.Shadows=false
    l.Parent=parent
end
local function labelOnFace(surface,text,foreground)
    local gui=Instance.new("SurfaceGui")
    gui.Face=Enum.NormalId.Front
    gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud=36
    gui.LightInfluence=0
    gui.Parent=surface
    local outer=Instance.new("Frame")
    outer.Size=UDim2.fromScale(1,1)
    outer.BackgroundTransparency=1
    outer.Parent=gui
    local writing=Instance.new("TextLabel")
    writing.Size=UDim2.fromScale(1,1)
    writing.BackgroundTransparency=1
    writing.Text=text
    writing.TextColor3=foreground
    writing.TextStrokeColor3=Color3.fromRGB(34,38,58)
    writing.TextStrokeTransparency=.3
    writing.Font=Enum.Font.GothamBlack
    writing.TextScaled=true
    writing.Parent=outer
end
-- A recognisable central identity: nested stone plaza, fish-and-egg sculpture,
-- short wooden benches and soft accent lighting.
local plaza=part("MainPlaza",Vector3.new(29,.35,22),at(0,5.42,8),Color3.fromRGB(216,195,158),Enum.Material.Cobblestone)
for _,v in ipairs({-1,1}) do
    part("PlazaStoneEdge",Vector3.new(31,.6,1),at(0,5.65,8+v*11),Color3.fromRGB(157,145,129),Enum.Material.Slate)
    part("PlazaStoneEdge",Vector3.new(1,.6,22),at(v*15,5.65,8),Color3.fromRGB(157,145,129),Enum.Material.Slate)
end
local pedestal=part("EggMonumentPlinth",Vector3.new(5,1.2,5),at(12,6.1,2),Color3.fromRGB(83,123,142),Enum.Material.Slate)
local egg=part("GoldenEggMonument",Vector3.new(3.9,5,3.9),at(12,9.3,2),Color3.fromRGB(255,216,93),Enum.Material.Neon,"Ball")
local accent=part("EggHalo",Vector3.new(.35,6.2,6.2),at(12,7.1,2)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(129,239,255),Enum.Material.Neon,"Cylinder")
accent.Transparency=.45
light(egg,Color3.fromRGB(255,206,103),24,1)
-- The decorative ring is non-colliding, and paths remain open on both sides.
for _,side in ipairs({-1,1}) do
    local x=side*11.4
    part("VillageBenchSeat",Vector3.new(5,.45,1.8),at(x,6.2,15),wood,Enum.Material.WoodPlanks)
    part("VillageBenchBack",Vector3.new(5,2,.4),at(x,7,16),Color3.fromRGB(147,97,65),Enum.Material.Wood)
    for _,dx in ipairs({-2.1,2.1}) do
        part("VillageBenchLeg",Vector3.new(.5,1.4,.5),at(x+dx,5.7,15),navy,Enum.Material.Metal)
    end
end
-- A genuinely readable portal that announces the fishing area.
for _,side in ipairs({-1,1}) do
    local x=-18+side*11
    part("FishingGatePillar",Vector3.new(2.2,10,2.2),at(x,10,-58),wood,Enum.Material.WoodPlanks)
    local cap=part("FishingGateCap",Vector3.new(3.1,1.1,3.1),at(x,15.1,-58),gold,Enum.Material.SmoothPlastic)
    light(cap,gold,12,.7)
end
local entrySign=part("FishingGateSign",Vector3.new(19,3,.8),at(-18,15.1,-58)*CFrame.Angles(0,math.rad(180),0),navy,Enum.Material.SmoothPlastic)
part("FishingGateSignTrim",Vector3.new(20,3.8,.2),at(0,15.1,-57.45),gold,Enum.Material.Neon)
labelOnFace(entrySign,"PONTON DE PECHE",cream)
-- Striping, roof contours, display objects and beautifully lit signs on each stand.
local shops={
    {kind="Rods",x=-36,z=-12,tint=Color3.fromRGB(56,165,221),icon="FISHING RODS"},
    {kind="Robux",x=0,z=-12,tint=Color3.fromRGB(172,108,255),icon="VIP SHOP"},
    {kind="Luck",x=36,z=-12,tint=Color3.fromRGB(72,218,126),icon="LUCK BOOSTS"},
}
for _,shop in ipairs(shops) do
    local m=islandDecor:WaitForChild(shop.kind.."Stand",20)
    if m then
        local x,z=shop.x,shop.z
        local col=shop.tint
        part(shop.kind.."RoofCrown",Vector3.new(17,.65,14),at(x,14,z),navy,Enum.Material.Slate)
        for _,side in ipairs({-1,1}) do
            local roof=part(shop.kind.."PitchRoof",Vector3.new(8.5,2,14),at(x+side*4.2,14.9,z)*CFrame.Angles(0,0,math.rad(side*12)),col,Enum.Material.SmoothPlastic)
            part(shop.kind.."MarketFinial",Vector3.new(.8,1.2,.8),at(x+side*7.4,16.3,z+5.9),gold,Enum.Material.Neon,"Ball")
            for _,level in ipairs({7.6,9.4}) do
                part(shop.kind.."WindowShutter",Vector3.new(.35,1.2,4.3),at(x+side*7.2,level,z-1),wood,Enum.Material.Wood)
            end
        end
        part(shop.kind.."Ridge",Vector3.new(2,1.1,14),at(x,16.1,z),cream,Enum.Material.SmoothPlastic)
        local lightbar=part(shop.kind.."FrontLightbar",Vector3.new(15,.3,.5),at(x,10.2,z+7.55),col,Enum.Material.Neon)
        light(lightbar,col,17,.65)
        for stripe=1,9 do
            local xx=x-7.2+stripe*1.44
            part(shop.kind.."ScallopedAwning",Vector3.new(1.15,.65,.7),at(xx,10.0,z+7.4),stripe%2==0 and cream or col,Enum.Material.SmoothPlastic,"Ball")
        end
        local frontSign=part(shop.kind.."PremiumSign",Vector3.new(13.3,2,.4),at(x,17.6,z+3.2)*CFrame.Angles(0,math.rad(180),0),navy,Enum.Material.SmoothPlastic)
        labelOnFace(frontSign,shop.icon,cream)
        part(shop.kind.."SignLightUnderline",Vector3.new(13.8,.2,.5),at(x,16.45,z+3.5),col,Enum.Material.Neon)
        for k=1,3 do
            local xx=x+(k-2)*3.5
            local zz=z+3.9
            if shop.kind=="Rods" then
                local rod=part("ShowcaseFishingRod",Vector3.new(.25,4.7,.25),at(xx,9.5,zz)*CFrame.Angles(0,0,math.rad(-16)),Color3.fromRGB(237,193,114),Enum.Material.Wood)
                part("RodReel",Vector3.new(.85,.85,.85),at(xx+.4,8,zz),col,Enum.Material.Metal,"Cylinder")
            elseif shop.kind=="Luck" then
                part("PotionBottle",Vector3.new(1.3,2.1,1.3),at(xx,8.6,zz),Color3.fromRGB(182,251,219),Enum.Material.Glass)
                local liquid=part("PotionLiquid",Vector3.new(1,1.1,1),at(xx,8.2,zz),col,Enum.Material.Neon)
                liquid.Transparency=.18
                part("BottleCork",Vector3.new(.8,.5,.8),at(xx,9.9,zz),wood,Enum.Material.Wood)
                light(liquid,col,7,.35)
            else
                local gem=part("VIPGem",Vector3.new(1.8,1.8,1.8),at(xx,9,zz)*CFrame.Angles(0,math.rad(45),math.rad(45)),col,Enum.Material.Neon)
                light(gem,col,8,.4)
            end
        end
        -- Rounded colored pavements draw the eye toward the storefront.
        local entrance=part(shop.kind.."WelcomeMat",Vector3.new(13,.15,4),at(x,5.6,z+8.5),col,Enum.Material.SmoothPlastic)
        entrance.Transparency=.2
    end
end
-- Six upgraded base exteriors: every island plot reads as a collectible zone.
local plots=world:WaitForChild("BasePlots",20)
if plots then
    local colors={
        Color3.fromRGB(92,218,245),Color3.fromRGB(255,195,99),
        Color3.fromRGB(184,126,248),Color3.fromRGB(107,236,151),
        Color3.fromRGB(255,146,173),Color3.fromRGB(121,201,255)
    }
    for i=1,6 do
        local pad=plots:FindFirstChild("Base"..i)
        if pad then
            local x,z=pad.Position.X,pad.Position.Z
            local tint=colors[i]
            for _,sx in ipairs({-1,1}) do
                for _,sz in ipairs({-1,1}) do
                    local px,pz=x+sx*21.5,z+sz*17.2
                    part("BaseCornerStone",Vector3.new(2.5,2.6,2.5),at(px,6.55,pz),Color3.fromRGB(90,113,127),Enum.Material.Slate)
                    local cap=part("BaseCrystalCap",Vector3.new(1.8,.7,1.8),at(px,8.2,pz),tint,Enum.Material.Neon)
                    light(cap,tint,10,.36)
                end
                local rail=part("BaseSideLight",Vector3.new(.36,.27,28),at(x+sx*21.7,5.9,z),tint,Enum.Material.Neon)
                rail.Transparency=.25
            end
            for _,sz in ipairs({-1,1}) do
                local front=part("BaseEdgeLight",Vector3.new(39,.26,.36),at(x,5.9,z+sz*17.1),tint,Enum.Material.Neon)
                front.Transparency=.27
            end
            -- Side-set totems leave all current animal slots unobstructed.
            for _,sx in ipairs({-1,1}) do
                local cx=x+sx*20
                part("PlotTotemBody",Vector3.new(1.4,3.4,1.4),at(cx,7.7,z),Color3.fromRGB(76,102,119),Enum.Material.Slate)
                local jewel=part("PlotTotemJewel",Vector3.new(1.7,1.7,1.7),at(cx,10,z),tint,Enum.Material.Neon,"Ball")
                light(jewel,tint,12,.32)
            end
        end
    end
end
-- Teal shallow-water ribbons make a visual transition from island to ocean.
for _,side in ipairs({-1,1}) do
    for _,z in ipairs({-54,-33,-12,9,30,51}) do
        local x=side*127
        local wave=part("CoastalWaterShimmer",Vector3.new(2.8,.12,11),at(x,-3.86,z),Color3.fromRGB(166,241,241),Enum.Material.Neon)
        wave.Transparency=.56
    end
end
-- Charming boats, fishing buoys and gentle wake lines around the pier.
local function boat(x,z,paint)
    part("BoatHull",Vector3.new(11,2.5,22),at(x,-2.2,z),paint,Enum.Material.SmoothPlastic)
    part("BoatDeck",Vector3.new(9,.5,18),at(x,-.8,z),Color3.fromRGB(210,166,107),Enum.Material.WoodPlanks)
    part("BoatBow",Vector3.new(7,2,5),at(x,-1.8,z-10),cream,Enum.Material.SmoothPlastic,"Wedge")
    part("BoatMast",Vector3.new(.65,21,.65),at(x,9,z+1),wood,Enum.Material.Wood)
    part("BoatSail",Vector3.new(.3,14,9),at(x,10,z-4)*CFrame.Angles(0,math.rad(15),0),cream,Enum.Material.Fabric,"Wedge")
    for _,v in ipairs({-1,1}) do
        local wake=part("BoatWake",Vector3.new(1.4,.13,19),at(x+v*7,-3.8,z),Color3.fromRGB(203,254,255),Enum.Material.Neon)
        wake.Transparency=.55
    end
end
boat(-35,-136,Color3.fromRGB(73,172,200))
boat(40,-183,Color3.fromRGB(243,141,105))
for _,position in ipairs({Vector3.new(-25,-3,-93),Vector3.new(27,-3,-118),Vector3.new(-22,-3,-192),Vector3.new(26,-3,-220)}) do
    local buoy=part("FloatingBuoy",Vector3.new(2.6,2.6,2.6),CFrame.new(position),Color3.fromRGB(253,133,92),Enum.Material.Neon,"Ball")
    part("BuoyBand",Vector3.new(2.8,.6,2.8),CFrame.new(position),cream,Enum.Material.SmoothPlastic)
    light(buoy,Color3.fromRGB(255,162,117),10,.45)
end
-- Composed natural grouping rather than randomly covering player bases.
local garden=Random.new(4732)
for i=1,48 do
    local side=i%2==0 and 1 or -1
    local x=side*garden:NextNumber(107,116)
    local z=garden:NextNumber(-60,54)
    local rock=part("CoastBoulder",Vector3.new(garden:NextNumber(1.5,4),garden:NextNumber(.8,2.1),garden:NextNumber(1.5,4)),at(x,5.6,z),Color3.fromRGB(111,140,135),Enum.Material.Slate,"Ball")
    rock.Orientation=Vector3.new(garden:NextNumber(-20,20),garden:NextNumber(0,180),0)
    if i%3==0 then
        for k=1,3 do
            local bloom=part("CoastFlower",Vector3.new(.5,.6,.5),at(x+(k-2),7,z+.7),({Color3.fromRGB(255,174,174),Color3.fromRGB(255,229,116),Color3.fromRGB(166,187,255)})[k],Enum.Material.Neon,"Ball")
            bloom.Transparency=.1
        end
    end
end
-- Gentle post-processing: stronger color separation without overexposing UI.
local Lighting=game:GetService("Lighting")
local bloom=Lighting:FindFirstChild("FishPremiumBloom") or Instance.new("BloomEffect")
bloom.Name="FishPremiumBloom"
bloom.Intensity=.16
bloom.Size=23
bloom.Threshold=1.55
bloom.Parent=Lighting
local grade=Lighting:FindFirstChild("FishPremiumGrade") or Instance.new("ColorCorrectionEffect")
grade.Name="FishPremiumGrade"
grade.Saturation=.07
grade.Contrast=.045
grade.Brightness=.005
grade.Parent=Lighting
-- Distant seabirds frame the horizon and can be softly animated client-side.
for i=1,6 do
    local x=(i-3.5)*35
    local y=35+(i%3)*8
    local z=-215-(i%2)*28
    for _,side in ipairs({-1,1}) do
        part("SeabirdWing",Vector3.new(3.5,.2,.75),at(x+side*1.8,y,z)*CFrame.Angles(0,0,math.rad(side*15)),Color3.fromRGB(243,249,252),Enum.Material.SmoothPlastic)
    end
end
folder:SetAttribute("Ready",true)
print("Fish for an Egg: premium plaza, detailed shops, boats and waterfront cosmetics ready")
