-- Compact, premium simulator HUD inspired by the reference composition.
-- This layer only restyles live controls: it never replaces game logic.
local Players=game:GetService("Players")
local player=Players.LocalPlayer
local gui=player:WaitForChild("PlayerGui"):WaitForChild("EggProgressionGui",30)
if not gui then return end
local cash=gui:WaitForChild("Cash",25)
local inventory=gui:WaitForChild("Inventory",25)
local base=gui:WaitForChild("Base",25)
local shop=gui:WaitForChild("Shop",25)
local luck=gui:WaitForChild("LuckShop",25)
local premium=gui:WaitForChild("RobuxShop",25)
local nav={
    {gui:WaitForChild("ShopToggle",25),"🎣","CANNES"},
    {gui:WaitForChild("IndexToggle",25),"📖","INDEX"},
    {gui:WaitForChild("PremiumToggle",25),"💎","ROBUX"},
    {gui:WaitForChild("LuckToggle",25),"🍀","CHANCE"},
}
if not cash or not inventory or not base then return end
for _,v in ipairs(nav) do if not v[1] then return end end
gui:WaitForChild("FishingHelp",20)
task.wait(.2)
for _,item in ipairs(gui:GetChildren()) do
    if item:IsA("TextLabel") and item.Name=="IllustratedIcon" then item.Visible=false end
end
-- Keep cash, egg capacity and base level as three genuine state-backed top chips.
for _,item in ipairs({cash,inventory,base}) do
    item.TextScaled=false
    item.Font=Enum.Font.GothamBlack
    item.TextColor3=Color3.fromRGB(255,247,222)
    item.BackgroundTransparency=.02
    local border=item:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
    border.Thickness=2
    border.Color=Color3.fromRGB(116,193,227)
    border.Transparency=.22
    border.Parent=item
end
cash.TextSize=20
inventory.TextSize=17
base.TextSize=16
for index,entry in ipairs(nav) do
    local button,emoji,title=entry[1],entry[2],entry[3]
    button.Name=button.Name
    button.Text=title
    button.TextScaled=false
    button.TextSize=14
    button.TextWrapped=true
    button.Font=Enum.Font.GothamBlack
    button.TextYAlignment=Enum.TextYAlignment.Bottom
    button.BackgroundTransparency=.02
    local icon=button:FindFirstChild("TopIcon") or Instance.new("TextLabel")
    icon.Name="TopIcon"
    icon.BackgroundTransparency=1
    icon.Size=UDim2.new(1,0,0,39)
    icon.Position=UDim2.fromOffset(0,7)
    icon.Font=Enum.Font.GothamBlack
    icon.Text=emoji
    icon.TextSize=29
    icon.TextColor3=Color3.new(1,1,1)
    icon.ZIndex=button.ZIndex+2
    icon.Parent=button
    button.LayoutOrder=index
end
-- Move illustration chips inside the actual product buttons so they are readable
-- and clickable as part of the whole offer.
for _,oldIcon in ipairs(premium:GetChildren()) do
    if oldIcon:IsA("TextLabel") and oldIcon.Name=="IllustratedIcon" then oldIcon.Visible=false end
end
local offers={"🥚","🎣","🍀","💰"}
for i=1,4 do
    local button=premium:FindFirstChild("Premium"..i)
    if button then
        local icon=Instance.new("TextLabel")
        icon.Name="OfferIcon"
        icon.Size=UDim2.fromOffset(42,42)
        icon.AnchorPoint=Vector2.new(0,.5)
        icon.Position=UDim2.new(0,11,.5,0)
        icon.BackgroundColor3=Color3.fromRGB(30,30,78)
        icon.Text=offers[i]
        icon.TextSize=25
        icon.TextColor3=Color3.new(1,1,1)
        icon.ZIndex=button.ZIndex+2
        icon.Parent=button
        Instance.new("UICorner",icon).CornerRadius=UDim.new(0,11)
        local edge=Instance.new("UIStroke")
        edge.Color=({Color3.fromRGB(253,207,85),Color3.fromRGB(100,208,254),Color3.fromRGB(117,238,143),Color3.fromRGB(251,182,93)})[i]
        edge.Thickness=2
        edge.Parent=icon
        button.TextXAlignment=Enum.TextXAlignment.Left
        local spacing=button:FindFirstChildOfClass("UIPadding") or Instance.new("UIPadding")
        spacing.PaddingLeft=UDim.new(0,62)
        spacing.PaddingRight=UDim.new(0,9)
        spacing.Parent=button
    end
end
local camera=workspace.CurrentCamera
local function positionHud()
    camera=workspace.CurrentCamera or camera
    if not camera then return end
    local width=camera.ViewportSize.X
    if width>=850 then
        cash.AnchorPoint=Vector2.new(.5,0)
        cash.Position=UDim2.new(.42,0,0,12)
        cash.Size=UDim2.fromOffset(222,49)
        inventory.AnchorPoint=Vector2.new(.5,0)
        inventory.Position=UDim2.new(.6,0,0,12)
        inventory.Size=UDim2.fromOffset(161,49)
        base.AnchorPoint=Vector2.new(.5,0)
        base.Position=UDim2.new(.76,0,0,12)
        base.Size=UDim2.fromOffset(178,49)
        for i,entry in ipairs(nav) do
            local b=entry[1]
            b.Position=UDim2.fromOffset(12,153+(i-1)*83)
            b.Size=UDim2.fromOffset(104,74)
        end
    else
        cash.AnchorPoint=Vector2.new(.5,0)
        cash.Position=UDim2.new(.5,0,0,65)
        cash.Size=UDim2.fromOffset(200,42)
        inventory.AnchorPoint=Vector2.new(.5,0)
        inventory.Position=UDim2.new(.27,0,0,113)
        inventory.Size=UDim2.fromOffset(136,36)
        base.AnchorPoint=Vector2.new(.5,0)
        base.Position=UDim2.new(.73,0,0,113)
        base.Size=UDim2.fromOffset(141,36)
        for i,entry in ipairs(nav) do
            local b=entry[1]
            b.Position=UDim2.fromOffset(7,172+(i-1)*71)
            b.Size=UDim2.fromOffset(77,62)
        end
    end
end
positionHud()
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(positionHud) end
local help=gui:FindFirstChild("FishingHelp")
if help then help.Position=UDim2.new(.5,-175,1,-194) end
print("Fish for an Egg: compact icon navigation, currency chips and premium offer cards ready")
