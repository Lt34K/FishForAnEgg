-- Local-only ambient motion. Cosmetic changes never replicate physics or hurt performance.
local RunService=game:GetService("RunService")
local world=workspace:WaitForChild("FishWorld",35)
if not world then return end
local premium=world:WaitForChild("PremiumWorld",35)
if not premium then return end
local deadline=os.clock()+35
while not premium:GetAttribute("Ready") and os.clock()<deadline do task.wait(.15) end
if not premium:GetAttribute("Ready") then return end
local boats={{center=Vector3.new(-35,-2.2,-136),parts={}}, {center=Vector3.new(40,-2.2,-183),parts={}}}
local buoys={}
local shimmers={}
local birds={}
local lamps={}
for _,obj in ipairs(premium:GetDescendants()) do
    if obj:IsA("BasePart") then
        if obj.Name=="FloatingBuoy" or obj.Name=="BuoyBand" then
            table.insert(buoys,{p=obj,base=obj.CFrame})
        elseif obj.Name=="CoastalWaterShimmer" or (obj.Name=="SeaWaveGlint" and #shimmers%3==0) then
            table.insert(shimmers,{p=obj,index=#shimmers+1,base=obj.Transparency})
        elseif obj.Name=="SeabirdWing" then
            table.insert(birds,{p=obj,base=obj.CFrame,index=#birds+1})
        elseif string.sub(obj.Name,1,4)=="Boat" and obj.Name~="BoatWake" then
            local group=obj.Position.X<0 and boats[1] or boats[2]
            table.insert(group.parts,{p=obj,relative=CFrame.new(group.center):ToObjectSpace(obj.CFrame)})
        end
    elseif obj:IsA("PointLight") and (obj.Parent and (obj.Parent.Name=="BaseCrystalCap" or obj.Parent.Name=="FrontLightbar" or obj.Parent.Name=="AmberLantern")) then
        table.insert(lamps,{light=obj,base=obj.Brightness,index=#lamps+1})
    end
end
local accumulated=0
local t0=os.clock()
local connection
connection=RunService.Heartbeat:Connect(function(dt)
    if not premium.Parent then connection:Disconnect() return end
    accumulated+=dt
    if accumulated<1/25 then return end
    accumulated=0
    local t=os.clock()-t0
    for i,group in ipairs(boats) do
        local sway=math.sin(t*.75+i)*math.rad(1.65)
        local rise=math.sin(t*1.3+i)*.19
        local frame=CFrame.new(group.center)*CFrame.new(0,rise,0)*CFrame.Angles(0,0,sway)
        for _,item in ipairs(group.parts) do
            item.p.CFrame=frame*item.relative
        end
    end
    for index,item in ipairs(buoys) do
        item.p.CFrame=item.base+CFrame.new(0,math.sin(t*1.65+math.floor((index-1)/2))*.28,0).Position
    end
    for _,item in ipairs(shimmers) do
        item.p.Transparency=math.clamp(item.base+math.sin(t*1.5+item.index*.8)*.09,0,1)
    end
    for _,item in ipairs(birds) do
        item.p.CFrame=item.base*CFrame.new(math.sin(t*.36+item.index)*1.2,math.sin(t*1.1+item.index)*.35,0)
    end
    for _,item in ipairs(lamps) do
        item.light.Brightness=item.base*(.93+math.sin(t*1.7+item.index)*.07)
    end
end)
