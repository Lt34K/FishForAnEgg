local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local remote = ReplicatedStorage:FindFirstChild("FishingEvent") or Instance.new("RemoteEvent")
remote.Name = "FishingEvent"
remote.Parent = ReplicatedStorage
local sessions = {}

local function getRod(player)
    local character = player.Character
    return character and character:FindFirstChild("Canne en bois")
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
            remote:FireClient(player, "Message", "Équipe ta canne en bois !")
            return
        end
        if not nearPier(player) then
            remote:FireClient(player, "Message", "Va sur le ponton pour pêcher !")
            return
        end

        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local start = root.Position + Vector3.new(0, 2, 0)
        local destination = Vector3.new(math.clamp(start.X, -30, 30), -3.5, math.clamp(start.Z - 40, -200, -90))
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

        local rod = getRod(player)
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

        local s = {started = os.clock(), taps = 0, needed = math.random(8, 16), lastTap = 0, bobber = bobber, ready = false}
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
            remote:FireClient(player, "Caught", "Œuf commun")
            print(player.Name .. " a pêché un œuf commun (prototype)")
        end
    elseif action == "Cancel" then
        clearSession(player)
        remote:FireClient(player, "Message", "Pêche annulée.")
    end
end)

Players.PlayerRemoving:Connect(clearSession)
print("Fish for an Egg : pêche avec canne équipée et bouchon actif")
