-- Clean, mobile-friendly fishing interface with contextual controls and animated feedback.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local UserInputService=game:GetService("UserInputService")
local TweenService=game:GetService("TweenService")
local player=Players.LocalPlayer
local remote=ReplicatedStorage:WaitForChild("FishingEvent")
local gui=Instance.new("ScreenGui")
gui.Name="FishingGui"
gui.ResetOnSpawn=false
gui.DisplayOrder=5
gui.Parent=player:WaitForChild("PlayerGui")
local function round(element,r)
    local corner=Instance.new("UICorner")
    corner.CornerRadius=UDim.new(0,r)
    corner.Parent=element
end
local function stroke(element,color,thickness)
    local s=Instance.new("UIStroke")
    s.Color=color
    s.Thickness=thickness
    s.Transparency=.18
    s.Parent=element
    return s
end
local function gradient(element,top,bottom)
    local g=Instance.new("UIGradient")
    g.Color=ColorSequence.new(top,bottom)
    g.Rotation=90
    g.Parent=element
end
local panel=Instance.new("Frame")
panel.Name="FishingHUD"
panel.AnchorPoint=Vector2.new(.5,1)
panel.Position=UDim2.new(.5,0,1,-16)
panel.Size=UDim2.fromOffset(380,164)
panel.BackgroundColor3=Color3.fromRGB(17,39,72)
panel.BorderSizePixel=0
panel.Visible=false
panel.Parent=gui
round(panel,18)
gradient(panel,Color3.fromRGB(27,67,105),Color3.fromRGB(12,29,62))
stroke(panel,Color3.fromRGB(100,203,247),2)
local panelScale=Instance.new("UIScale")
panelScale.Parent=panel
local camera=workspace.CurrentCamera
local function fit()
    camera=workspace.CurrentCamera or camera
    if camera then panelScale.Scale=math.clamp((camera.ViewportSize.X-22)/390,.66,1) end
end
fit()
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(fit) end
local heading=Instance.new("TextLabel")
heading.Name="Heading"
heading.Size=UDim2.new(1,-34,0,24)
heading.Position=UDim2.fromOffset(17,9)
heading.BackgroundTransparency=1
heading.Text="🎣  FISH FOR AN EGG"
heading.Font=Enum.Font.GothamBlack
heading.TextSize=16
heading.TextColor3=Color3.fromRGB(255,217,132)
heading.TextXAlignment=Enum.TextXAlignment.Left
heading.Parent=panel
local status=Instance.new("TextLabel")
status.Name="FishingStatus"
status.Size=UDim2.new(1,-30,0,42)
status.Position=UDim2.fromOffset(15,34)
status.BackgroundTransparency=1
status.TextColor3=Color3.fromRGB(240,249,255)
status.TextWrapped=true
status.Font=Enum.Font.GothamBold
status.TextSize=16
status.Text="Avance sur le ponton pour pêcher."
status.Parent=panel
local progress=Instance.new("Frame")
progress.Name="ProgressBackground"
progress.Position=UDim2.fromOffset(19,80)
progress.Size=UDim2.new(1,-38,0,13)
progress.BackgroundColor3=Color3.fromRGB(11,27,53)
progress.BorderSizePixel=0
progress.Visible=false
progress.ClipsDescendants=true
progress.Parent=panel
round(progress,9)
local fill=Instance.new("Frame")
fill.Name="Fill"
fill.Size=UDim2.fromScale(0,1)
fill.BackgroundColor3=Color3.fromRGB(97,236,142)
fill.BorderSizePixel=0
fill.Parent=progress
round(fill,9)
gradient(fill,Color3.fromRGB(171,255,144),Color3.fromRGB(47,196,166))
local actionButton=Instance.new("TextButton")
actionButton.Name="FishAction"
actionButton.Position=UDim2.new(0,17,1,-64)
actionButton.Size=UDim2.new(1,-34,0,51)
actionButton.BackgroundColor3=Color3.fromRGB(25,149,220)
actionButton.BorderSizePixel=0
actionButton.TextColor3=Color3.fromRGB(255,255,255)
actionButton.Font=Enum.Font.GothamBlack
actionButton.TextSize=19
actionButton.Text="🎣 LANCER LA LIGNE"
actionButton.AutoButtonColor=false
actionButton.Parent=panel
round(actionButton,13)
gradient(actionButton,Color3.fromRGB(57,186,245),Color3.fromRGB(19,106,204))
local actionStroke=stroke(actionButton,Color3.fromRGB(155,234,255),2)
local state="idle"
local currentTarget=0
local lastInput=0
local lastMessage=0
local function rodEquipped()
    local character=player.Character
    if not character then return false end
    for _,v in ipairs(character:GetChildren()) do
        if v:IsA("Tool") and type(v:GetAttribute("RodLevel"))=="number" then return true end
    end
    return false
end
local function nearPier()
    local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    return root and root.Position.Y>=3 and root.Position.Z< -62
        and root.Position.Z> -156 and math.abs(root.Position.X)<12
end
local function changeMessage(message)
    status.Text=message
    lastMessage=os.clock()
end
local function pressEffect()
    TweenService:Create(actionButton,TweenInfo.new(.09,Enum.EasingStyle.Quad),{Size=UDim2.new(1,-43,0,47),Position=UDim2.new(0,21,1,-62)}):Play()
    task.delay(.09,function()
        if not actionButton.Parent then return end
        TweenService:Create(actionButton,TweenInfo.new(.15,Enum.EasingStyle.Back),{Size=UDim2.new(1,-34,0,51),Position=UDim2.new(0,17,1,-64)}):Play()
    end)
end
local function cast()
    if not rodEquipped() then return end
    if not nearPier() then
        changeMessage("🌊 Avance sur le ponton pour pêcher !")
        return
    end
    if state~="idle" then return end
    state="waiting"
    changeMessage("Lancer en cours… suis le bouchon !")
    pressEffect()
    remote:FireServer("Cast")
end
local function tap()
    if state~="reeling" or not rodEquipped() then return end
    if os.clock()-lastInput<.087 then return end
    lastInput=os.clock()
    pressEffect()
    remote:FireServer("Tap")
end
actionButton.Activated:Connect(function()
    if state=="idle" then cast()
    elseif state=="reeling" then tap() end
end)
UserInputService.InputBegan:Connect(function(input,processed)
    if processed or not rodEquipped() then return end
    local click=input.UserInputType==Enum.UserInputType.MouseButton1
        or input.UserInputType==Enum.UserInputType.MouseButton2
        or input.UserInputType==Enum.UserInputType.Touch
        or input.KeyCode==Enum.KeyCode.ButtonR2
    if not click then return end
    if state=="idle" then cast()
    elseif state=="reeling" then tap() end
end)
local function celebrate()
    local banner=Instance.new("TextLabel")
    banner.Name="CatchCelebration"
    banner.AnchorPoint=Vector2.new(.5,.5)
    banner.Position=UDim2.new(.5,0,.37,25)
    banner.Size=UDim2.fromOffset(370,72)
    banner.BackgroundColor3=Color3.fromRGB(49,160,119)
    banner.BackgroundTransparency=.1
    banner.TextColor3=Color3.fromRGB(255,245,179)
    banner.Font=Enum.Font.GothamBlack
    banner.TextSize=24
    banner.Text="✨ 🥚  OEUF CAPTURÉ !  ✨"
    banner.Parent=gui
    round(banner,17)
    stroke(banner,Color3.fromRGB(255,228,123),3)
    banner.TextTransparency=1
    local tween=TweenService:Create(banner,TweenInfo.new(.34,Enum.EasingStyle.Back),{Position=UDim2.new(.5,0,.37,0),TextTransparency=0})
    tween:Play()
    task.delay(1.65,function()
        if banner.Parent then
            TweenService:Create(banner,TweenInfo.new(.35),{BackgroundTransparency=1,TextTransparency=1,Position=UDim2.new(.5,0,.37,-24)}):Play()
            task.delay(.4,function() if banner.Parent then banner:Destroy() end end)
        end
    end)
end
remote.OnClientEvent:Connect(function(action,a,b)
    if action=="CastStarted" then
        state="waiting"
        changeMessage("🎣 La ligne s'envole vers l'océan…")
    elseif action=="Splash" then
        changeMessage("🌊 Splash ! Attends une touche…")
    elseif action=="Bite" then
        state="reeling"
        currentTarget=tonumber(a) or 10
        progress.Visible=true
        fill.Size=UDim2.fromScale(0,1)
        changeMessage("⚡ ÇA MORD ! Clique / tapote pour remonter !")
    elseif action=="Progress" then
        local ratio=math.clamp((tonumber(a) or 0)/math.max(1,tonumber(b) or currentTarget),0,1)
        TweenService:Create(fill,TweenInfo.new(.14,Enum.EasingStyle.Quad),{Size=UDim2.fromScale(ratio,1)}):Play()
        status.Text=string.format("🥚 Remontée : %d / %d",a,b)
    elseif action=="Caught" then
        state="idle"
        progress.Visible=false
        changeMessage("🎉 Un œuf dans ton inventaire !")
        celebrate()
    elseif action=="Message" then
        state="idle"
        progress.Visible=false
        changeMessage(tostring(a))
    end
end)
local function bindCharacter(character)
    local function bindRod(tool)
        if not tool:IsA("Tool") or type(tool:GetAttribute("RodLevel"))~="number" then return end
        tool.Activated:Connect(function()
            if state=="idle" then cast()
            elseif state=="reeling" then tap() end
        end)
    end
    for _,child in ipairs(character:GetChildren()) do bindRod(child) end
    character.ChildAdded:Connect(bindRod)
    character.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") and child:GetAttribute("RodLevel") then
            if state~="idle" then remote:FireServer("Cancel") end
            state="idle"
            progress.Visible=false
        end
    end)
end
player.CharacterAdded:Connect(bindCharacter)
if player.Character then bindCharacter(player.Character) end
task.spawn(function()
    while gui.Parent do
        local equipped=rodEquipped()
        panel.Visible=equipped
        if equipped then
            if state=="reeling" then
                actionButton.Text="🥚 REMONTER L'ŒUF !"
                actionButton.BackgroundColor3=Color3.fromRGB(36,176,117)
            elseif state=="waiting" then
                actionButton.Text="⏳ ATTENDS LA TOUCHE…"
                actionButton.BackgroundColor3=Color3.fromRGB(55,118,163)
            elseif nearPier() then
                actionButton.Text="🎣 LANCER LA LIGNE"
                actionButton.BackgroundColor3=Color3.fromRGB(25,149,220)
                if os.clock()-lastMessage>4 then status.Text="Prêt à lancer ! Clique ou appuie sur R2." end
            else
                actionButton.Text="🌊 REJOINS LE PONTON"
                actionButton.BackgroundColor3=Color3.fromRGB(79,111,140)
                if os.clock()-lastMessage>4 then status.Text="Rejoins le ponton en bois pour pêcher." end
            end
        else
            if state~="idle" then
                state="idle"
                progress.Visible=false
            end
        end
        task.wait(.25)
    end
end)
