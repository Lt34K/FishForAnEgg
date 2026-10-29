local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("FishingEvent")

local gui = Instance.new("ScreenGui")
gui.Name = "FishingGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function label(name, text, y, height)
    local obj = Instance.new("TextLabel")
    obj.Name = name
    obj.Size = UDim2.new(0, 340, 0, height)
    obj.Position = UDim2.new(0.5, -170, 1, y)
    obj.BackgroundColor3 = Color3.fromRGB(21, 47, 68)
    obj.BackgroundTransparency = 0.12
    obj.TextColor3 = Color3.new(1, 1, 1)
    obj.Font = Enum.Font.GothamBold
    obj.TextScaled = true
    obj.Parent = gui
    Instance.new("UICorner", obj).CornerRadius = UDim.new(0, 12)
    return obj
end

local status = label("Status", "🎣 Va sur le ponton pour pêcher !", -205, 48)
local progress = label("Progress", "", -151, 36)
progress.Visible = false

local button = Instance.new("TextButton")
button.Name = "FishButton"
button.Size = UDim2.new(0, 240, 0, 68)
button.Position = UDim2.new(0.5, -120, 1, -108)
button.BackgroundColor3 = Color3.fromRGB(41, 164, 222)
button.TextColor3 = Color3.new(1, 1, 1)
button.Font = Enum.Font.GothamBold
button.TextScaled = true
button.Text = "🎣 LANCER"
button.Parent = gui
Instance.new("UICorner", button).CornerRadius = UDim.new(0, 16)

local state = "idle"
button.Activated:Connect(function()
    if state == "idle" then
        state = "waiting"
        status.Text = "Attends une touche..."
        button.Text = "..."
        remote:FireServer("Cast")
    elseif state == "reeling" then
        remote:FireServer("Tap")
    end
end)

remote.OnClientEvent:Connect(function(action, a, b)
    if action == "Bite" then
        state = "reeling"
        status.Text = "🥚 Un œuf a mordu ! Tapote !"
        progress.Visible = true
        progress.Text = "0 / " .. tostring(a)
        button.Text = "REMONTЕ !"
    elseif action == "Progress" then
        progress.Text = tostring(a) .. " / " .. tostring(b)
    elseif action == "Caught" then
        state = "idle"
        status.Text = "🎉 Tu as pêché : " .. tostring(a)
        progress.Visible = false
        button.Text = "🎣 RELANCER"
    elseif action == "Message" then
        state = "idle"
        status.Text = tostring(a)
        progress.Visible = false
        button.Text = "🎣 LANCER"
    end
end)
