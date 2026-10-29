local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("FishingEvent")
local gui = Instance.new("ScreenGui")
gui.Name = "FishingGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local status = Instance.new("TextLabel")
status.Name = "FishingStatus"
status.AnchorPoint = Vector2.new(0.5, 1)
status.Position = UDim2.new(0.5, 0, 1, -115)
status.Size = UDim2.new(0.8, 0, 0, 52)
status.BackgroundColor3 = Color3.fromRGB(21, 47, 68)
status.BackgroundTransparency = 0.15
status.TextColor3 = Color3.new(1, 1, 1)
status.TextScaled = true
status.Font = Enum.Font.GothamBold
status.Text = "🎣 Équipe la canne pour pêcher"
status.Parent = gui
Instance.new("UICorner", status).CornerRadius = UDim.new(0, 12)
local constraint = Instance.new("UISizeConstraint")
constraint.MaxSize = Vector2.new(430, 52)
constraint.Parent = status

local progress = Instance.new("Frame")
progress.Name = "ProgressBackground"
progress.AnchorPoint = Vector2.new(0.5, 1)
progress.Position = UDim2.new(0.5, 0, 1, -65)
progress.Size = UDim2.new(0.7, 0, 0, 24)
progress.BackgroundColor3 = Color3.fromRGB(32, 52, 65)
progress.Visible = false
progress.Parent = gui
Instance.new("UICorner", progress).CornerRadius = UDim.new(0, 10)
local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MaxSize = Vector2.new(360, 24)
sizeConstraint.Parent = progress

local fill = Instance.new("Frame")
fill.Name = "Fill"
fill.Size = UDim2.fromScale(0, 1)
fill.BackgroundColor3 = Color3.fromRGB(68, 214, 133)
fill.Parent = progress
Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 10)

local state = "idle"
local function equipped()
    if not player.Character then return false end
    for _,child in ipairs(player.Character:GetChildren()) do
        if child:IsA("Tool") and child:GetAttribute("RodLevel") then return true end
    end
    return false
end
local function cast()
    if not equipped() then return end
    state = "waiting"
    status.Text = "🎣 Ligne lancée... attends une touche !"
    remote:FireServer("Cast")
end
local function tap()
    if state == "reeling" and equipped() then
        remote:FireServer("Tap")
    end
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed or not equipped() then return end
    if state == "idle" then
        if input.UserInputType == Enum.UserInputType.MouseButton2
            or input.UserInputType == Enum.UserInputType.Touch
            or input.KeyCode == Enum.KeyCode.ButtonR2 then
            cast()
        end
    elseif state == "reeling" then
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
            or input.KeyCode == Enum.KeyCode.ButtonR2 then
            tap()
        end
    end
end)

remote.OnClientEvent:Connect(function(action, a, b)
    if action == "CastStarted" then
        status.Text = "🌊 Bouchon à l'eau... attends !"
    elseif action == "Bite" then
        state = "reeling"
        status.Text = "🥚 Un œuf mord ! Clique / tapote / R2 !"
        progress.Visible = true
        fill.Size = UDim2.fromScale(0, 1)
    elseif action == "Progress" then
        fill.Size = UDim2.fromScale(math.clamp(a / b, 0, 1), 1)
    elseif action == "Caught" then
        state = "idle"
        status.Text = "🎉 Tu as pêché : " .. tostring(a)
        progress.Visible = false
    elseif action == "Message" then
        state = "idle"
        status.Text = tostring(a)
        progress.Visible = false
    end
end)

local function bindCharacter(character)
    character.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") and child:GetAttribute("RodLevel") then
            if state ~= "idle" then remote:FireServer("Cancel") end
            state = "idle"
            progress.Visible = false
            status.Text = "🎣 Équipe la canne pour pêcher"
        end
    end)
end
player.CharacterAdded:Connect(bindCharacter)
if player.Character then bindCharacter(player.Character) end
