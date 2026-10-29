local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local remote = ReplicatedStorage:FindFirstChild("FishingEvent") or Instance.new("RemoteEvent")
remote.Name = "FishingEvent"
remote.Parent = ReplicatedStorage

local sessions = {}
local function nearPier(player)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    return root and root.Position.Z < -58 and root.Position.Z > -165 and math.abs(root.Position.X) < 35
end
remote.OnServerEvent:Connect(function(player, action)
    if action == "Cast" then
        if sessions[player] or not nearPier(player) then
            remote:FireClient(player, "Message", "Approche-toi du ponton pour pêcher !")
            return
        end
        local difficulty = math.random(8, 16)
        sessions[player] = {started = os.clock(), taps = 0, needed = difficulty, lastTap = 0}
        remote:FireClient(player, "Bite", difficulty)
    elseif action == "Tap" then
        local s = sessions[player]
        if not s then return end
        local now = os.clock()
        if now - s.started > 25 or not nearPier(player) then
            sessions[player] = nil
            remote:FireClient(player, "Message", "La prise s'est échappée !")
            return
        end
        if now - s.lastTap < 0.075 then return end
        s.lastTap = now
        s.taps += 1
        remote:FireClient(player, "Progress", s.taps, s.needed)
        if s.taps >= s.needed then
            sessions[player] = nil
            remote:FireClient(player, "Caught", "Œuf commun")
            print(player.Name .. " a pêché un œuf commun (prototype)")
        end
    end
end)
Players.PlayerRemoving:Connect(function(player) sessions[player] = nil end)
print("Fish for an Egg : système de pêche prototype actif")
