-- Fish for an Egg: server-authoritative fishing with visible casting arcs,
-- responsive bobber, splash rings, safe cancellation and anti-spam validation.
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Players=game:GetService("Players")
local Debris=game:GetService("Debris")
local TweenService=game:GetService("TweenService")
local remote=ReplicatedStorage:FindFirstChild("FishingEvent") or Instance.new("RemoteEvent")
remote.Name="FishingEvent"
remote.Parent=ReplicatedStorage
local eggCaught=script.Parent:WaitForChild("EggCaught")
local sessions={}
local latestCast={}
local function rodOf(player)
    local character=player.Character
    if not character then return nil end
    for _,obj in ipairs(character:GetChildren()) do
        if obj:IsA("Tool") and type(obj:GetAttribute("RodLevel"))=="number" then
            return obj
        end
    end
    return nil
end
local function onPier(player)
    local character=player.Character
    local root=character and character:FindFirstChild("HumanoidRootPart")
    return root and root.Position.Y>=3 and root.Position.Z < -62
        and root.Position.Z > -156 and math.abs(root.Position.X+18)<12
end
local function stop(player)
    local s=sessions[player]
    sessions[player]=nil
    if not s then return end
    if s.lineStart then s.lineStart:Destroy() end
    if s.bobber then s.bobber:Destroy() end
end
local function splashAt(position,parent,burst)
    if parent then
        local drops=Instance.new("ParticleEmitter")
        drops.Name="WaterDrops"
        drops.Texture="rbxasset://textures/particles/sparkles_main.dds"
        drops.Rate=0
        drops.Lifetime=NumberRange.new(.28,.58)
        drops.Speed=NumberRange.new(4,11)
        drops.Acceleration=Vector3.new(0,-19,0)
        drops.SpreadAngle=Vector2.new(115,115)
        drops.Size=NumberSequence.new({
            NumberSequenceKeypoint.new(0,.45),
            NumberSequenceKeypoint.new(.75,.25),
            NumberSequenceKeypoint.new(1,0)
        })
        drops.Transparency=NumberSequence.new(.06,1)
        drops.Color=ColorSequence.new(Color3.fromRGB(223,252,255),Color3.fromRGB(91,207,245))
        drops.LightEmission=.35
        drops.Parent=parent
        drops:Emit(burst or 20)
        Debris:AddItem(drops,2)
    end
    local ring=Instance.new("Part")
    ring.Name="FishingWaterRipple"
    ring.Shape=Enum.PartType.Cylinder
    ring.Size=Vector3.new(.12,2.6,2.6)
    ring.CFrame=CFrame.new(position.X,-3.92,position.Z)*CFrame.Angles(0,0,math.rad(90))
    ring.Color=Color3.fromRGB(203,247,255)
    ring.Material=Enum.Material.Neon
    ring.Transparency=.3
    ring.Anchored=true
    ring.CanCollide=false
    ring.CanTouch=false
    ring.Parent=workspace
    TweenService:Create(ring,TweenInfo.new(.9,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
        Size=Vector3.new(.12,9,9),Transparency=1
    }):Play()
    Debris:AddItem(ring,1)
end
local function spawnFloat(player,rod,start,destination)
    local bobber=Instance.new("Part")
    bobber.Name="FishingBobber"
    bobber:SetAttribute("OwnerUserId",player.UserId)
    bobber.Shape=Enum.PartType.Ball
    bobber.Size=Vector3.new(1.15,1.15,1.15)
    bobber.CFrame=CFrame.new(start)
    bobber.Color=Color3.fromRGB(252,97,77)
    bobber.Material=Enum.Material.SmoothPlastic
    bobber.Anchored=true
    bobber.CanCollide=false
    bobber.CanTouch=false
    bobber.Parent=workspace
    local stripe=Instance.new("SpecialMesh")
    stripe.MeshType=Enum.MeshType.Sphere
    stripe.Scale=Vector3.new(1,1,1)
    stripe.Parent=bobber
    local glow=Instance.new("PointLight")
    glow.Name="BobberGlow"
    glow.Color=Color3.fromRGB(255,146,106)
    glow.Brightness=.7
    glow.Range=7
    glow.Parent=bobber
    local tip=rod:FindFirstChild("RodTip")
    local attachment
    if tip and tip:IsA("BasePart") then
        attachment=Instance.new("Attachment")
        attachment.Name="FishingLineStart"
        attachment.Position=Vector3.new(0,tip.Size.Y*.5,0)
        attachment.Parent=tip
        local endAtt=Instance.new("Attachment")
        endAtt.Parent=bobber
        local line=Instance.new("Beam")
        line.Name="FishingLine"
        line.Attachment0=attachment
        line.Attachment1=endAtt
        line.Width0=.035
        line.Width1=.035
        line.FaceCamera=true
        line.Color=ColorSequence.new(Color3.fromRGB(236,244,250))
        line.Transparency=NumberSequence.new(.1)
        line.Parent=bobber
    end
    return bobber,attachment
end
local function beginCast(player)
    if sessions[player] then return end
    if os.clock()-(latestCast[player] or -100)<.35 then return end
    latestCast[player]=os.clock()
    local rod=rodOf(player)
    if not rod then
        remote:FireClient(player,"Message","Équipe ta canne pour pêcher.")
        return
    end
    if not onPier(player) then
        remote:FireClient(player,"Message","Avance sur le ponton pour lancer ta ligne !")
        return
    end
    local root=player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local tip=rod:FindFirstChild("RodTip")
    local start=(tip and tip:IsA("BasePart")) and tip.Position or root.Position+Vector3.new(0,2,0)
    local range=math.clamp(tonumber(rod:GetAttribute("CastDistance")) or 10,10,330)
    -- Always cast beside the pier, never through its wooden deck.
    local direction=root.Position.X>=-18 and 1 or -1
    local destination=Vector3.new(-18+direction*(21+range*.66),-3.15,math.clamp(root.Position.Z-10-range*.38,-340,-90))
    local bobber,attachment=spawnFloat(player,rod,start,destination)
    local s={bobber=bobber,lineStart=attachment,ready=false,taps=0,needed=math.random(8,15),lastTap=0,rodLevel=rod:GetAttribute("RodLevel") or 1}
    sessions[player]=s
    remote:FireClient(player,"CastStarted")
    local midpoint=start:Lerp(destination,.55)+Vector3.new(0,math.clamp(range*.14,7,21),0)
    local duration=math.clamp(.45+range*.003,.45,1.2)
    local rise=TweenService:Create(bobber,TweenInfo.new(duration*.48,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=midpoint})
    local fall=TweenService:Create(bobber,TweenInfo.new(duration*.52,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=destination})
    rise:Play()
    rise.Completed:Wait()
    if sessions[player]~=s or not bobber.Parent then return end
    fall:Play()
    fall.Completed:Wait()
    if sessions[player]~=s or not bobber.Parent then return end
    splashAt(destination,bobber,25)
    remote:FireClient(player,"Splash")
    local floatTween=TweenService:Create(bobber,TweenInfo.new(.85,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Position=destination+Vector3.new(0,.44,0)})
    floatTween:Play()
    task.delay(math.random(2,4),function()
        if sessions[player]~=s then return end
        if not rodOf(player) or not onPier(player) then
            stop(player)
            remote:FireClient(player,"Message","Pêche interrompue. Reste sur le ponton.")
            return
        end
        s.ready=true
        splashAt(bobber.Position,bobber,15)
        local highlight=Instance.new("Highlight")
        highlight.Name="FishBite"
        highlight.FillColor=Color3.fromRGB(255,237,109)
        highlight.FillTransparency=.3
        highlight.OutlineColor=Color3.new(1,1,1)
        highlight.Parent=bobber
        Debris:AddItem(highlight,2)
        remote:FireClient(player,"Bite",s.needed)
    end)
    task.delay(22,function()
        if sessions[player]~=s then return end
        stop(player)
        remote:FireClient(player,"Message","L'œuf s'est échappé ! Relance.")
    end)
end
remote.OnServerEvent:Connect(function(player,action)
    if action=="Cast" then
        task.spawn(beginCast,player)
    elseif action=="Tap" then
        local s=sessions[player]
        if not s or not s.ready then return end
        if not rodOf(player) or not onPier(player) then
            stop(player)
            remote:FireClient(player,"Message","Pêche interrompue.")
            return
        end
        local now=os.clock()
        if now-s.lastTap<.085 then return end
        s.lastTap=now
        s.taps+=1
        remote:FireClient(player,"Progress",s.taps,s.needed)
        if s.taps>=s.needed then
            splashAt(s.bobber.Position,s.bobber,35)
            stop(player)
            eggCaught:Fire(player,s.rodLevel)
            remote:FireClient(player,"Caught","œuf mystérieux")
        end
    elseif action=="Cancel" then
        stop(player)
        remote:FireClient(player,"Message","Pêche annulée.")
    end
end)
Players.PlayerRemoving:Connect(function(player)
    stop(player)
    latestCast[player]=nil
end)
print("Fish for an Egg : lancer en arc, flotteur animé, touches, récompenses et anti-spam prêts")
