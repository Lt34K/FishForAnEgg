local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

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
status.Size = UDim2.fromOffset(390, 52)
status.BackgroundColor3 = Color3.fromRGB(21, 47, 68)
status.BackgroundTransparency = 0.15
status.TextColor3 = Color3.new(1, 1, 1)
status.TextScaled = false
status.TextSize = 19
status.TextWrapped = true
status.Font = Enum.Font.GothamBold
status.Text = "🎣 Équipe la canne pour pêcher"
status.Parent = gui
Instance.new("UICorner", status).CornerRadius = UDim.new(0, 12)
local constraint = Instance.new("UISizeConstraint")
constraint.MaxSize = Vector2.new(390, 52)
constraint.Parent = status
local widthScale = Instance.new("UIScale")
widthScale.Parent = status
local camera = workspace.CurrentCamera
local function updateScale()
    camera = workspace.CurrentCamera or camera
    if camera then widthScale.Scale = math.min(1, math.max(.62, (camera.ViewportSize.X - 24) / 390)) end
end
updateScale()
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale) end

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
local noticeUntil = 0
local actionButton=Instance.new("TextButton")
actionButton.Name="FishAction"
actionButton.AnchorPoint=Vector2.new(.5,1)
actionButton.Position=UDim2.new(.5,0,1,-20)
actionButton.Size=UDim2.fromOffset(210,54)
actionButton.BackgroundColor3=Color3.fromRGB(24,129,218)
actionButton.TextColor3=Color3.new(1,1,1)
actionButton.Font=Enum.Font.GothamBold
actionButton.TextSize=19
actionButton.Text="🎣 LANCER"
actionButton.Visible=false
actionButton.Parent=gui
Instance.new("UICorner",actionButton).CornerRadius=UDim.new(0,14)
local stroke=Instance.new("UIStroke")
stroke.Color=Color3.fromRGB(135,225,255)
stroke.Thickness=2
stroke.Parent=actionButton
local function atFishingZone()
    local character=player.Character
    local root=character and character:FindFirstChild("HumanoidRootPart")
    return root ~= nil and root.Position.Y>=3 and root.Position.Z < -62 and root.Position.Z > -156 and math.abs(root.Position.X)<12
end
local function equipped()
    if not player.Character then return false end
    for _,child in ipairs(player.Character:GetChildren()) do
        if child:IsA("Tool") and child:GetAttribute("RodLevel") then return true end
    end
    return false
end
-- Keep the fishing hint out of the way until a rod is equipped.
task.spawn(function()
    while gui.Parent do
        local hasRod=equipped()
        status.Visible=hasRod
        actionButton.Visible=hasRod
        local atPier=atFishingZone()
        actionButton.Text=state=="reeling" and "🥚 REMONTER !" or state=="waiting" and "⏳ ATTENDRE..." or atPier and "🎣 LANCER" or "📍 PONTON"
        actionButton.Active=state=="reeling" or (state=="idle" and atPier)
        if hasRod and state=="idle" and os.clock()>noticeUntil then
            status.Text=atPier and "🎣 Prêt à pêcher ! Lance ta ligne." or "📍 Avance sur le ponton pour pêcher."
        end
        if not hasRod then progress.Visible=false end
        task.wait(.35)
    end
end)
local function cast()
    if not equipped() then return end
    if not atFishingZone() then
        status.Text="📍 Rejoins le ponton, puis lance ta ligne !"
        noticeUntil=os.clock()+2
        return
    end
    state = "waiting"
    status.Text = "🎣 Ligne lancée... attends une touche !"
    remote:FireServer("Cast")
end
actionButton.Activated:Connect(function()
    if state=="idle" then cast()
    elseif state=="reeling" then remote:FireServer("Tap") end
end)
local function tap()
    if state == "reeling" and equipped() then
        remote:FireServer("Tap")
    end
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed or not equipped() then return end
    if state == "idle" then
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.MouseButton2
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
    elseif action == "Splash" then
        status.Text = "💦 Plouf ! Observe le bouchon..."
    elseif action == "Bite" then
        state = "reeling"
        status.Text = "🥚 Un œuf mord ! Clique / tapote / R2 !"
        progress.Visible = true
        fill.Size = UDim2.fromScale(0, 1)
    elseif action == "Progress" then
        TweenService:Create(fill,TweenInfo.new(.11,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.fromScale(math.clamp(a / b, 0, 1), 1)}):Play()
    elseif action == "Caught" then
        state = "idle"
        status.Text = "🎉 Tu as pêché : " .. tostring(a)
        noticeUntil=os.clock()+3
        progress.Visible = false
    elseif action == "Message" then
        state = "idle"
        status.Text = tostring(a)
        noticeUntil=os.clock()+3
        progress.Visible = false
    end
end)

local function bindCharacter(character)
    local function bindTool(tool)
        if not tool:IsA("Tool") or not tool:GetAttribute("RodLevel") then return end
        tool.Activated:Connect(function()
            if state=="idle" then cast()
            elseif state=="reeling" then tap() end
        end)
    end
    for _,child in ipairs(character:GetChildren()) do bindTool(child) end
    character.ChildAdded:Connect(bindTool)

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
