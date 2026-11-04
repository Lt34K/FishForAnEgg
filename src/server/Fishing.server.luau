local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local remote = ReplicatedStorage:FindFirstChild("FishingEvent") or Instance.new("RemoteEvent")
remote.Name = "FishingEvent"
remote.Parent = ReplicatedStorage
local sessions = {}
local eggCaught = script.Parent:WaitForChild("EggCaught")

local function getRod(player)
    local character = player.Character
    if not character then return nil end
    for _,child in ipairs(character:GetChildren()) do
        if child:IsA("Tool") and child:GetAttribute("RodLevel") then return child end
    end
    return nil
end

local function nearPier(player)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    return root and root.Position.Z < -58 and root.Position.Z > -165 and math.abs(root.Position.X) < 35
end

local function clearSession(player)
    local s = sessions[player]
    if not s then return end
    if s.bobber then s.bobber:Destroy() end
    sessions[player] = nil
end

remote.OnServerEvent:Connect(function(player, action)
    if action == "Cast" then
        if sessions[player] then return end
        if not getRod(player) then
            remote:FireClient(player, "Message", "Équipe ta canne à pêche !")
            return
        end
        if not nearPier(player) then
            remote:FireClient(player, "Message", "Va sur le ponton pour pêcher !")
            return
        end

        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local start = root.Position + Vector3.new(0, 2, 0)
        local rod = getRod(player)
        local level = rod:GetAttribute("RodLevel") or 1
        local range = math.clamp(rod:GetAttribute("CastDistance") or 10, 10, 120)
        local destination = Vector3.new(math.clamp(start.X, -30, 30), -3.5, math.clamp(start.Z - range, -350, -90))
        local bobber = Instance.new("Part")
        bobber.Name = "FishingBobber"
        bobber.Shape = Enum.PartType.Ball
        bobber.Size = Vector3.new(1.3, 1.3, 1.3)
        bobber.Anchored = true
        bobber.CanCollide = false
        bobber.Color = Color3.fromRGB(250, 75, 63)
        bobber.Material = Enum.Material.SmoothPlastic
        bobber.Position = destination
        bobber.Parent = workspace

        -- Impact ripple, droplets and a brief water splash when the float lands.
        local splash=Instance.new("ParticleEmitter")
        splash.Name="WaterSplash"
        splash.Texture="rbxasset://textures/particles/sparkles_main.dds"
        splash.Color=ColorSequence.new(Color3.fromRGB(207,247,255),Color3.fromRGB(91,196,238))
        splash.Transparency=NumberSequence.new(0.15,1)
        splash.Size=NumberSequence.new({
            NumberSequenceKeypoint.new(0,.35),
            NumberSequenceKeypoint.new(.6,.65),
            NumberSequenceKeypoint.new(1,0)
        })
        splash.Speed=NumberRange.new(4,10)
        splash.SpreadAngle=Vector2.new(110,110)
        splash.Lifetime=NumberRange.new(.3,.65)
        splash.Rate=0
        splash.Parent=bobber
        splash:Emit(24)
        local ripple=Instance.new("Part")
        ripple.Name="FishingRipple"
        ripple.Shape=Enum.PartType.Cylinder
        ripple.Size=Vector3.new(.08,2,2)
        ripple.CFrame=CFrame.new(destination+Vector3.new(0,-.45,0))*CFrame.Angles(0,0,math.rad(90))
        ripple.Color=Color3.fromRGB(208,250,255)
        ripple.Material=Enum.Material.Neon
        ripple.Transparency=.35
        ripple.Anchored=true
        ripple.CanCollide=false
        ripple.Parent=workspace
        local TweenService=game:GetService("TweenService")
        TweenService:Create(ripple,TweenInfo.new(.8,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
            Size=Vector3.new(.08,8,8),
            Transparency=1
        }):Play()
        Debris:AddItem(ripple,1)
        local tip = rod and rod:FindFirstChild("RodTip")
        if tip then
            local a = Instance.new("Attachment")
            a.Name = "FishingLineStart"
            a.Position = Vector3.new(0, tip.Size.Y / 2, 0)
            a.Parent = tip
            local b = Instance.new("Attachment")
            b.Parent = bobber
            local beam = Instance.new("Beam")
            beam.Name = "FishingLine"
            beam.Attachment0 = a
            beam.Attachment1 = b
            beam.Width0 = 0.045
            beam.Width1 = 0.045
            beam.FaceCamera = true
            beam.Color = ColorSequence.new(Color3.fromRGB(230, 234, 236))
            beam.Parent = bobber
            Debris:AddItem(a, 30)
        end

        local glow=Instance.new("PointLight")
        glow.Name="FishingFloatGlow"
        glow.Color=Color3.fromRGB(255,121,83)
        glow.Range=7
        glow.Brightness=.8
        glow.Parent=bobber
        local bobTween=TweenService:Create(bobber,TweenInfo.new(.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{
            Position=destination+Vector3.new(0,.4,0)
        })
        bobTween:Play()
        local function makeBiteSplash()
            if not bobber.Parent then return end
            splash:Emit(12)
            local pulse=Instance.new("Highlight")
            pulse.Name="BiteHighlight"
            pulse.FillColor=Color3.fromRGB(255,219,73)
            pulse.FillTransparency=.45
            pulse.OutlineColor=Color3.fromRGB(255,255,255)
            pulse.Parent=bobber
            Debris:AddItem(pulse,1)
        end
        local s = {started = os.clock(), taps = 0, needed = math.random(8, 16), lastTap = 0, bobber = bobber, ready = false, rodLevel = level}
        sessions[player] = s
        remote:FireClient(player, "CastStarted")
        task.delay(math.random(2, 4), function()
            if sessions[player] ~= s then return end
            if not getRod(player) or not nearPier(player) then
                clearSession(player)
                remote:FireClient(player, "Message", "Pêche interrompue.")
                return
            end
            s.ready = true
            makeBiteSplash()
            remote:FireClient(player, "Bite", s.needed)
        end)
        task.delay(25, function()
            if sessions[player] == s then
                clearSession(player)
                remote:FireClient(player, "Message", "L'œuf s'est échappé !")
            end
        end)
    elseif action == "Tap" then
        local s = sessions[player]
        if not s or not s.ready then return end
        if not getRod(player) or not nearPier(player) then
            clearSession(player)
            remote:FireClient(player, "Message", "Pêche interrompue.")
            return
        end
        local now = os.clock()
        if now - s.lastTap < 0.075 then return end
        s.lastTap = now
        s.taps += 1
        remote:FireClient(player, "Progress", s.taps, s.needed)
        if s.taps >= s.needed then
            clearSession(player)
            eggCaught:Fire(player, s.rodLevel)
            remote:FireClient(player, "Caught", "œuf mystérieux")
        end
    elseif action == "Cancel" then
        clearSession(player)
        remote:FireClient(player, "Message", "Pêche annulée.")
    end
end)

Players.PlayerRemoving:Connect(clearSession)
print("Fish for an Egg : pêche avec canne équipée et bouchon actif")
