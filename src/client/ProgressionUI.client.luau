local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local action=ReplicatedStorage:WaitForChild("ProgressionAction")
local events=ReplicatedStorage:WaitForChild("ProgressionState")
local gui=Instance.new("ScreenGui")
gui.Name="EggProgressionGui"
gui.ResetOnSpawn=false
gui.Parent=player:WaitForChild("PlayerGui")

local function makeLabel(parent,name,position,size,text)
    local label=Instance.new("TextLabel")
    label.Name=name
    label.Position=position
    label.Size=size
    label.BackgroundColor3=Color3.fromRGB(22,53,73)
    label.BackgroundTransparency=.08
    label.TextColor3=Color3.fromRGB(255,255,255)
    label.Font=Enum.Font.GothamBold
    label.TextScaled=true
    label.Text=text
    label.Parent=parent
    Instance.new("UICorner",label).CornerRadius=UDim.new(0,10)
    return label
end
local function makeButton(parent,name,position,size,text)
    local button=Instance.new("TextButton")
    button.Name=name
    button.Position=position
    button.Size=size
    button.BackgroundColor3=Color3.fromRGB(44,153,195)
    button.TextColor3=Color3.new(1,1,1)
    button.Font=Enum.Font.GothamBold
    button.TextScaled=true
    button.Text=text
    button.Parent=parent
    Instance.new("UICorner",button).CornerRadius=UDim.new(0,10)
    return button
end
local function fmt(n)
    if n>=1e15 then return string.format("%.2f Qa",n/1e15) end
    if n>=1e12 then return string.format("%.2f T",n/1e12) end
    if n>=1e9 then return string.format("%.2f B",n/1e9) end
    if n>=1e6 then return string.format("%.2f M",n/1e6) end
    if n>=1e3 then return string.format("%.1f K",n/1e3) end
    return tostring(math.floor(n))
end
local cash=makeLabel(gui,"Cash",UDim2.fromOffset(12,12),UDim2.fromOffset(200,48),"💰 0 $")
local inventory=makeLabel(gui,"Inventory",UDim2.fromOffset(12,66),UDim2.fromOffset(200,44),"🥚 0 / 30")
local base=makeLabel(gui,"Base",UDim2.fromOffset(12,116),UDim2.fromOffset(200,44),"🏠 Base 1")
local toggle=makeButton(gui,"ShopToggle",UDim2.new(1,-176,0,12),UDim2.fromOffset(164,48),"🛒 BOUTIQUE")
local shop=Instance.new("Frame")
shop.Name="Shop"
shop.AnchorPoint=Vector2.new(1,0)
shop.Position=UDim2.new(1,-12,0,68)
shop.Size=UDim2.new(.85,0,0,270)
shop.BackgroundColor3=Color3.fromRGB(23,47,65)
shop.Visible=false
shop.Parent=gui
Instance.new("UICorner",shop).CornerRadius=UDim.new(0,12)
local sizeLimit=Instance.new("UISizeConstraint")
sizeLimit.MaxSize=Vector2.new(360,270)
sizeLimit.Parent=shop
local rodInfo=makeLabel(shop,"RodInfo",UDim2.new(.04,0,.04,0),UDim2.new(.92,0,0,70),"Canne actuelle : Bois")
local buyRod=makeButton(shop,"BuyRod",UDim2.new(.04,0,.33,0),UDim2.new(.92,0,0,52),"Acheter la prochaine canne")
local baseInfo=makeLabel(shop,"BaseInfo",UDim2.new(.04,0,.56,0),UDim2.new(.92,0,0,48),"Base niveau 1")
local buyBase=makeButton(shop,"BuyBase",UDim2.new(.04,0,.78,0),UDim2.new(.92,0,0,48),"Améliorer la base")
local notice=makeLabel(gui,"Notice",UDim2.new(.5,-170,0,12),UDim2.fromOffset(340,48),"")
notice.Visible=false

local indexToggle=makeButton(gui,"IndexToggle",UDim2.new(1,-176,0,352),UDim2.fromOffset(164,46),"📖 INDEX")
local indexPanel=Instance.new("ScrollingFrame")
indexPanel.Name="CreatureIndex"
indexPanel.AnchorPoint=Vector2.new(1,0)
indexPanel.Position=UDim2.new(1,-12,0,405)
indexPanel.Size=UDim2.new(.85,0,0,310)
indexPanel.BackgroundColor3=Color3.fromRGB(23,47,65)
indexPanel.ScrollBarThickness=5
indexPanel.Visible=false
indexPanel.Parent=gui
local limit=Instance.new("UISizeConstraint")
limit.MaxSize=Vector2.new(360,310)
limit.Parent=indexPanel
Instance.new("UICorner",indexPanel).CornerRadius=UDim.new(0,12)
local layout=Instance.new("UIListLayout")
layout.Padding=UDim.new(0,5)
layout.Parent=indexPanel
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    indexPanel.CanvasSize=UDim2.fromOffset(0,layout.AbsoluteContentSize.Y+10)
end)
indexToggle.Activated:Connect(function()
    indexPanel.Visible=not indexPanel.Visible
    if indexPanel.Visible then shop.Visible=false end
end)
local function drawIndex(d)
    for _,child in ipairs(indexPanel:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then child:Destroy() end
    end
    local found=0
    for _,value in pairs(d.index or {}) do if value==true then found+=1 end end
    local header=makeLabel(indexPanel,"Header",UDim2.new(),UDim2.new(1,-12,0,42),"📖 INDEX : "..found.."/30")
    header.LayoutOrder=0
    for eggId,names in ipairs(d.creatures or {}) do
        for variant,name in ipairs(names) do
            local id=(eggId-1)*5+variant
            local seen=d.index and d.index[tostring(id)]
            local label=makeLabel(indexPanel,"Creature"..id,UDim2.new(),UDim2.new(1,-12,0,31),(seen and "✓ " or "🔒 ")..(seen and name or "???"))
            label.LayoutOrder=id
            if not seen then label.TextColor3=Color3.fromRGB(157,168,180) end
        end
    end
    for id,skin in ipairs(d.skins or {}) do
        local unlocked=found>=skin.required
        local selected=d.skin==id
        local button=makeButton(indexPanel,"Skin"..id,UDim2.new(),UDim2.new(1,-12,0,43),
            (selected and "✓ " or unlocked and "🎨 " or "🔒 ")..skin.name.." ("..skin.required.."/30)")
        button.LayoutOrder=100+id
        button.BackgroundColor3=selected and Color3.fromRGB(49,143,101) or unlocked and Color3.fromRGB(44,153,195) or Color3.fromRGB(73,79,87)
        button.Activated:Connect(function()
            if unlocked then action:FireServer("EquipSkin",id) end
        end)
    end
end

local state
local noticeId=0
toggle.Activated:Connect(function() shop.Visible=not shop.Visible end)
buyRod.Activated:Connect(function() action:FireServer("BuyRod") end)
buyBase.Activated:Connect(function() action:FireServer("UpgradeBase") end)
events.OnClientEvent:Connect(function(kind,payload)
    if kind=="State" then
        state=payload
        cash.Text="💰 "..fmt(state.cash).." $"
        drawIndex(state)
        inventory.Text="🥚 "..#state.inventory.." / 30"
        base.Text="🏠 Base "..state.plot.." | Niv. "..state.base
        local rod=state.rods[state.rod]
        rodInfo.Text="🎣 "..rod.name.." | "..rod.distance.." m / "..rod.depth.." m"
        local nextRod=state.rods[state.rod+1]
        buyRod.Text=nextRod and ("Canne "..nextRod.name.." : "..fmt(nextRod.price).." $") or "Cannes : MAX"
        local nextPrice=state.baseCosts[state.base+1]
        baseInfo.Text="🏠 Niveau "..state.base.." | "..state.baseSlots[state.base].." emplacements"
        buyBase.Text=nextPrice and ("Agrandir : "..fmt(nextPrice).." $") or "Base : MAX"
    elseif kind=="Notice" then
        noticeId+=1
        local id=noticeId
        notice.Text=tostring(payload)
        notice.Visible=true
        task.delay(4,function() if id==noticeId then notice.Visible=false end end)
    end
end)
action:FireServer("Sync")

task.spawn(function()
    local stats=player:WaitForChild("leaderstats")
    local cashValue=stats:WaitForChild("Cash")
    local function refresh()
        cash.Text="💰 "..fmt(cashValue.Value).." $"
    end
    cashValue:GetPropertyChangedSignal("Value"):Connect(refresh)
    refresh()
end)
