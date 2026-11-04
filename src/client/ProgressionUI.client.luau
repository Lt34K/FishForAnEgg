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
shop.Size=UDim2.new(.85,0,0,340)
shop.BackgroundColor3=Color3.fromRGB(23,47,65)
shop.Visible=false
shop.Parent=gui
Instance.new("UICorner",shop).CornerRadius=UDim.new(0,12)
local sizeLimit=Instance.new("UISizeConstraint")
sizeLimit.MaxSize=Vector2.new(360,340)
sizeLimit.Parent=shop
local rodInfo=makeLabel(shop,"RodInfo",UDim2.new(.04,0,.04,0),UDim2.new(.92,0,0,70),"Canne actuelle : Bois")
local buyRod=makeButton(shop,"BuyRod",UDim2.new(.04,0,.33,0),UDim2.new(.92,0,0,52),"Acheter la prochaine canne")
local baseInfo=makeLabel(shop,"BaseInfo",UDim2.new(.04,0,.56,0),UDim2.new(.92,0,0,48),"Base niveau 1")
local buyBase=makeButton(shop,"BuyBase",UDim2.new(.04,0,.78,0),UDim2.new(.92,0,0,48),"Améliorer la base")
-- Premium stand preview. Actual Robux purchases require published product/pass IDs.
local premium=Instance.new("Frame")
premium.Name="RobuxShop"
premium.AnchorPoint=Vector2.new(.5,.5)
premium.Position=UDim2.fromScale(.5,.5)
premium.Size=UDim2.new(.88,0,.68,0)
premium.BackgroundColor3=Color3.fromRGB(39,32,79)
premium.Visible=false
premium.Parent=gui
Instance.new("UICorner",premium).CornerRadius=UDim.new(0,14)
local premiumLimit=Instance.new("UISizeConstraint")
premiumLimit.MaxSize=Vector2.new(420,430)
premiumLimit.Parent=premium
local premiumTitle=makeLabel(premium,"Title",UDim2.new(.04,0,.025,0),UDim2.new(.73,0,0,48),"💎 BOUTIQUE ROBUX")
premiumTitle.BackgroundColor3=Color3.fromRGB(76,61,146)
local closePremium=makeButton(premium,"Close",UDim2.new(.8,0,.025,0),UDim2.new(.16,0,0,48),"✕")
closePremium.Activated:Connect(function() premium.Visible=false end)
local state
local MarketplaceService=game:GetService("MarketplaceService")
local premiumButtons={}
local productNames={"🥚 Œuf cosmique divin","🎣 Canne stellaire exclusive","🍀 Chance VIP ×2 · 30 min","💰 Coffre de 100 000 $"}
for i,name in ipairs(productNames) do
    local button=makeButton(premium,"Premium"..i,UDim2.new(.05,0,.17+(i-1)*.17,0),UDim2.new(.9,0,.145,0),name)
    button.TextScaled=false
    button.TextSize=17
    button.TextWrapped=true
    button.BackgroundColor3=Color3.fromRGB(63,54,115)
    button.Activated:Connect(function()
        local item=state and state.premiumProducts and state.premiumProducts[i]
        if item and tonumber(item.productId) and item.productId>0 then
            MarketplaceService:PromptProductPurchase(player,item.productId)
        end
    end)
    premiumButtons[i]=button
end
local premiumFooter=makeLabel(premium,"Footer",UDim2.new(.05,0,.87,0),UDim2.new(.9,0,.1,0),"Produits désactivés tant que les IDs Roblox ne sont pas configurés")
premiumFooter.TextScaled=false
premiumFooter.TextSize=14
premiumFooter.TextWrapped=true

local luckPanel=Instance.new("Frame")
luckPanel.Name="LuckShop"
luckPanel.AnchorPoint=Vector2.new(.5,.5)
luckPanel.Position=UDim2.fromScale(.5,.5)
luckPanel.Size=UDim2.new(.88,0,.76,0)
luckPanel.BackgroundColor3=Color3.fromRGB(31,79,55)
luckPanel.Visible=false
luckPanel.Parent=gui
Instance.new("UICorner",luckPanel).CornerRadius=UDim.new(0,12)
local luckLimit=Instance.new("UISizeConstraint")
luckLimit.MaxSize=Vector2.new(420,480)
luckLimit.Parent=luckPanel
makeLabel(luckPanel,"Title",UDim2.new(.04,0,.02,0),UDim2.new(.73,0,0,45),"🍀 BOOSTS DE CHANCE")
local luckClose=makeButton(luckPanel,"Close",UDim2.new(.8,0,.02,0),UDim2.new(.16,0,0,45),"✕")
luckClose.Activated:Connect(function() luckPanel.Visible=false end)
local luckStatus=makeLabel(luckPanel,"Status",UDim2.new(.04,0,.15,0),UDim2.new(.92,0,0,55),"Chance normale")
luckStatus.TextScaled=false
luckStatus.TextSize=16
local luckButtons={}
for i=1,3 do
    local b=makeButton(luckPanel,"Potion"..i,UDim2.new(.04,0,.3+(i-1)*.14,0),UDim2.new(.92,0,.115,0),"Potion "..i)
    b.TextScaled=false
    b.TextSize=16
    b.TextWrapped=true
    b.Activated:Connect(function() action:FireServer("BuyLuckPotion",i) end)
    luckButtons[i]=b
end
local luckUpgrade=makeButton(luckPanel,"Upgrade",UDim2.new(.04,0,.75,0),UDim2.new(.92,0,.14,0),"Améliorer la chance permanente")
luckUpgrade.TextScaled=false
luckUpgrade.TextSize=16
luckUpgrade.TextWrapped=true
luckUpgrade.Activated:Connect(function() action:FireServer("BuyLuckUpgrade") end)

local decorButton=makeButton(shop,"BuyDecoration",UDim2.new(.04,0,0,275),UDim2.new(.92,0,0,48),"Décorations de base")
decorButton.Activated:Connect(function() action:FireServer("BuyDecoration") end)
local notice=makeLabel(gui,"Notice",UDim2.new(.5,-170,0,12),UDim2.fromOffset(340,48),"")
notice.Visible=false

local indexToggle=makeButton(gui,"IndexToggle",UDim2.new(1,-176,0,68),UDim2.fromOffset(164,46),"📖 INDEX")
local indexPanel=Instance.new("ScrollingFrame")
indexPanel.Name="CreatureIndex"
indexPanel.AnchorPoint=Vector2.new(1,0)
indexPanel.Position=UDim2.new(1,-12,0,122)
indexPanel.Size=UDim2.new(.85,0,.65,0)
indexPanel.BackgroundColor3=Color3.fromRGB(23,47,65)
indexPanel.ScrollBarThickness=5
indexPanel.Visible=false
indexPanel.Parent=gui
local limit=Instance.new("UISizeConstraint")
limit.MaxSize=Vector2.new(400,480)
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
    local header=makeLabel(indexPanel,"Header",UDim2.new(),UDim2.new(1,-12,0,42),"📖 INDEX : "..found.."/"..(d.totalCreatures or 48))
    header.LayoutOrder=0
    for eggId,names in ipairs(d.creatures or {}) do
        local discovered=0
        for variant=1,#names do
            if d.index and d.index[tostring((eggId-1)*8+variant)] then discovered+=1 end
        end
        local habitat=(d.habitats or {})[eggId]
        local unlocked=habitat and d.rod>=habitat.minRod
        local section=makeLabel(indexPanel,"Habitat"..eggId,UDim2.new(),UDim2.new(1,-12,0,38),(unlocked and "🌿 " or "🔒 ")..(habitat and habitat.name or "Habitat").." ("..discovered.."/8)"..(unlocked and "" or (" | Canne "..tostring(habitat and habitat.minRod or "?"))))
        section.LayoutOrder=eggId*10-9
        for variant,name in ipairs(names) do
            local id=(eggId-1)*8+variant
            local seen=d.index and d.index[tostring(id)]
            local rarity=(d.rarities or {})[variant] or ""
            local label=makeLabel(indexPanel,"Creature"..id,UDim2.new(),UDim2.new(1,-12,0,31),(seen and "✓ " or "🔒 ")..(seen and name or "???").." · "..rarity)
            label.LayoutOrder=eggId*10-9+variant
            if not seen then
                label.TextColor3=Color3.fromRGB(157,168,180)
            elseif variant==8 then
                label.BackgroundColor3=Color3.fromRGB(133,86,195)
            elseif variant==7 then
                label.BackgroundColor3=Color3.fromRGB(196,137,43)
            elseif variant==6 then
                label.BackgroundColor3=Color3.fromRGB(80,114,198)
            end
        end
    end
    local skinsHeader=makeLabel(indexPanel,"SkinsHeader",UDim2.new(),UDim2.new(1,-12,0,38),"🎨 SKINS DE BASE")
    skinsHeader.LayoutOrder=99
    for id,skin in ipairs(d.skins or {}) do
        local unlocked=found>=skin.required
        local selected=d.skin==id
        local button=makeButton(indexPanel,"Skin"..id,UDim2.new(),UDim2.new(1,-12,0,43),
            (selected and "✓ " or unlocked and "🎨 " or "🔒 ")..skin.name.." ("..skin.required.."/"..(d.totalCreatures or 48)..")")
        button.LayoutOrder=100+id
        button.BackgroundColor3=selected and Color3.fromRGB(49,143,101) or unlocked and Color3.fromRGB(44,153,195) or Color3.fromRGB(73,79,87)
        button.Activated:Connect(function()
            if unlocked then action:FireServer("EquipSkin",id) end
        end)
    end
end

local worldShop=ReplicatedStorage:WaitForChild("OpenWorldShop")
worldShop.OnClientEvent:Connect(function(kind)
    if kind=="Rods" then
        luckPanel.Visible=false
        premium.Visible=false
        indexPanel.Visible=false
        shop.Visible=true
    elseif kind=="Robux" then
        luckPanel.Visible=false
        premium.Visible=true
        shop.Visible=false
        indexPanel.Visible=false
    elseif kind=="Luck" then
        luckPanel.Visible=true
        premium.Visible=false
        shop.Visible=false
        indexPanel.Visible=false
    end
end)

local noticeId=0
toggle.Activated:Connect(function()
    shop.Visible=not shop.Visible
    if shop.Visible then indexPanel.Visible=false end
end)
buyRod.Activated:Connect(function() action:FireServer("BuyRod") end)
buyBase.Activated:Connect(function() action:FireServer("UpgradeBase") end)
events.OnClientEvent:Connect(function(kind,payload)
    if kind=="State" then
        state=payload
        for i,button in ipairs(premiumButtons) do
            local product=state.premiumProducts and state.premiumProducts[i]
            local enabled=product and tonumber(product.productId) and product.productId>0
            button.Text=productNames[i]..(enabled and "" or " · À VENIR")
            button.BackgroundColor3=enabled and Color3.fromRGB(100,70,171) or Color3.fromRGB(63,54,115)
            button.Active=enabled and true or false
        end
        for i,potion in ipairs(state.luckPotions or {}) do
            if luckButtons[i] then luckButtons[i].Text=potion.name.." | +"..math.floor(potion.bonus*100).."% | "..math.floor(potion.duration/60).." min | "..fmt(potion.price).." $" end
        end
        local nextLuck=(state.luckUpgrades or {})[(state.luckLevel or 0)+1]
        luckUpgrade.Text=nextLuck and ("🍀 Chance permanente +"..math.floor(nextLuck.bonus*100).."% : "..fmt(nextLuck.price).." $") or "🍀 Chance permanente : MAX"
        local seconds=math.max(0,(state.luckExpires or 0)-os.time())
        luckStatus.Text="🍀 Niveau "..(state.luckLevel or 0).." | "..(seconds>0 and (math.ceil(seconds/60).." min de boost") or "Boost inactif")
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
        local nextDecoration=(state.decorations or {})[(state.decorationLevel or 0)+1]
        decorButton.Text=nextDecoration and ("🎨 "..nextDecoration.name.." : "..fmt(nextDecoration.price).." $") or "🎨 Décorations : MAX"
        buyBase.Text=nextPrice and ("Agrandir : "..fmt(nextPrice).." $") or "Base : MAX"
    elseif kind=="Notice" then
        noticeId+=1
        local id=noticeId
        notice.Text=tostring(payload)
        notice.Visible=true
        task.delay(4,function() if id==noticeId then notice.Visible=false end end)
    end
end)
task.spawn(function()
    while gui.Parent do
        if state then
            local remaining=math.max(0,(state.luckExpires or 0)-os.time())
            local permanent=(state.luckUpgrades or {})[state.luckLevel or 0]
            local bonus=permanent and permanent.bonus or 0
            if remaining>0 then
                luckStatus.Text=string.format("🍀 Permanent +%d%% | Potion +%d%% | %02d:%02d restantes",math.floor(bonus*100),math.floor((state.luckBonus or 0)*100),math.floor(remaining/60),remaining%60)
            else
                luckStatus.Text="🍀 Chance permanente +"..math.floor(bonus*100).."% | Aucune potion active"
            end
        end
        task.wait(1)
    end
end)
-- Coastal deluxe UI: reusable visual language for every existing functional menu.
local TweenService=game:GetService("TweenService")
local palette={
    navy=Color3.fromRGB(15,35,62),
    panel=Color3.fromRGB(24,43,77),
    blue=Color3.fromRGB(36,134,220),
    purple=Color3.fromRGB(118,65,207),
    green=Color3.fromRGB(38,165,99),
    gold=Color3.fromRGB(244,184,65),
}
local function polish(element,accent)
    element.BorderSizePixel=0
    element.BackgroundColor3=accent or palette.panel
    local corner=element:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
    corner.CornerRadius=UDim.new(0,14)
    corner.Parent=element
    local stroke=element:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
    stroke.Color=accent or palette.blue
    stroke.Thickness=2
    stroke.Transparency=.3
    stroke.Parent=element
    local gradient=element:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient")
    gradient.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(167,187,218))
    })
    gradient.Rotation=90
    gradient.Parent=element
    if element:IsA("TextButton") then
        element.AutoButtonColor=false
        element.MouseEnter:Connect(function()
            TweenService:Create(element,TweenInfo.new(.13),{BackgroundTransparency=.05}):Play()
            TweenService:Create(stroke,TweenInfo.new(.13),{Transparency=0,Thickness=3}):Play()
        end)
        element.MouseLeave:Connect(function()
            TweenService:Create(element,TweenInfo.new(.13),{BackgroundTransparency=0}):Play()
            TweenService:Create(stroke,TweenInfo.new(.13),{Transparency=.3,Thickness=2}):Play()
        end)
    end
end
local function addHeader(panel,title,accent)
    local header=Instance.new("TextLabel")
    header.Name="DeluxeHeader"
    header.Size=UDim2.new(1,-24,0,42)
    header.Position=UDim2.fromOffset(12,12)
    header.BackgroundTransparency=1
    header.Text=title
    header.TextColor3=Color3.fromRGB(255,240,200)
    header.TextXAlignment=Enum.TextXAlignment.Left
    header.Font=Enum.Font.GothamBlack
    header.TextSize=22
    header.Parent=panel
    local line=Instance.new("Frame")
    line.Name="AccentDivider"
    line.Size=UDim2.new(1,-24,0,3)
    line.Position=UDim2.fromOffset(12,57)
    line.BackgroundColor3=accent
    line.BorderSizePixel=0
    line.Parent=panel
    Instance.new("UICorner",line).CornerRadius=UDim.new(1,0)
end
local function iconTile(parent,emoji,position,accent)
    local tile=Instance.new("TextLabel")
    tile.Name="IllustratedIcon"
    tile.Size=UDim2.fromOffset(48,48)
    tile.Position=position
    tile.Text=emoji
    tile.TextScaled=true
    tile.BackgroundColor3=accent
    tile.TextColor3=Color3.new(1,1,1)
    tile.Parent=parent
    polish(tile,accent)
    return tile
end
gui.IgnoreGuiInset=false
cash.AnchorPoint=Vector2.new(.5,0)
cash.Position=UDim2.new(.5,0,0,12)
cash.Size=UDim2.fromOffset(246,48)
cash.TextSize=23
cash.TextScaled=false
polish(cash,palette.navy)
inventory.Position=UDim2.fromOffset(12,12)
inventory.Size=UDim2.fromOffset(158,46)
inventory.TextScaled=false
inventory.TextSize=17
polish(inventory,palette.navy)
base.Position=UDim2.fromOffset(12,64)
base.Size=UDim2.fromOffset(158,44)
base.TextScaled=false
base.TextSize=15
polish(base,palette.navy)
toggle.Position=UDim2.fromOffset(12,136)
toggle.Size=UDim2.fromOffset(158,49)
toggle.Text="🛒  CANNES"
indexToggle.Position=UDim2.fromOffset(12,195)
indexToggle.Size=UDim2.fromOffset(158,49)
indexToggle.Text="📖  INDEX"
polish(toggle,palette.blue)
polish(indexToggle,palette.purple)
local premiumToggle=makeButton(gui,"PremiumToggle",UDim2.fromOffset(12,254),UDim2.fromOffset(158,49),"💎  ROBUX")
local luckToggle=makeButton(gui,"LuckToggle",UDim2.fromOffset(12,313),UDim2.fromOffset(158,49),"🍀  CHANCE")
polish(premiumToggle,palette.purple)
polish(luckToggle,palette.green)
local function hideAll()
    shop.Visible=false
    indexPanel.Visible=false
    premium.Visible=false
    luckPanel.Visible=false
end
premiumToggle.Activated:Connect(function()
    local show=not premium.Visible
    hideAll()
    premium.Visible=show
end)
luckToggle.Activated:Connect(function()
    local show=not luckPanel.Visible
    hideAll()
    luckPanel.Visible=show
end)
shop.AnchorPoint=Vector2.new(.5,.5)
shop.Position=UDim2.fromScale(.5,.54)
shop.Size=UDim2.new(.9,0,.75,0)
sizeLimit.MaxSize=Vector2.new(460,480)
shop.BackgroundTransparency=0
polish(shop,palette.panel)
addHeader(shop,"🎣  ATELIER DES CANNES",palette.blue)
rodInfo.Position=UDim2.new(.05,0,.17,0)
rodInfo.Size=UDim2.new(.9,0,0,62)
buyRod.Position=UDim2.new(.05,0,.35,0)
buyRod.Size=UDim2.new(.9,0,0,55)
baseInfo.Position=UDim2.new(.05,0,.53,0)
baseInfo.Size=UDim2.new(.9,0,0,54)
buyBase.Position=UDim2.new(.05,0,.68,0)
buyBase.Size=UDim2.new(.9,0,0,53)
decorButton.Position=UDim2.new(.05,0,.83,0)
decorButton.Size=UDim2.new(.9,0,0,53)
for _,element in ipairs({rodInfo,baseInfo}) do
    element.TextScaled=false
    element.TextSize=18
    element.TextWrapped=true
    polish(element,palette.navy)
end
for _,element in ipairs({buyRod,buyBase,decorButton}) do
    element.TextScaled=false
    element.TextSize=18
    element.TextWrapped=true
    polish(element,palette.blue)
end
premium.Position=UDim2.fromScale(.5,.52)
premium.Size=UDim2.new(.94,0,.79,0)
premiumLimit.MaxSize=Vector2.new(510,540)
polish(premium,palette.panel)
premiumTitle.Text="💎  TRÉSORS EXCLUSIFS"
premiumTitle.TextScaled=false
premiumTitle.TextSize=21
premiumTitle.Size=UDim2.new(.7,0,0,48)
polish(premiumTitle,palette.purple)
polish(closePremium,palette.purple)
for i,button in ipairs(premiumButtons) do
    button.TextXAlignment=Enum.TextXAlignment.Center
    button.TextSize=17
    polish(button,palette.purple)
    iconTile(premium,({"🥚","🎣","🍀","💰"})[i],UDim2.new(.065,0,.17+(i-1)*.17,6),palette.navy)
    button.ZIndex=2
end
premiumFooter.Text="🔒 Achats disponibles après configuration des produits Roblox"
premiumFooter.TextSize=13
premiumFooter.TextWrapped=true
premiumFooter.BackgroundTransparency=1
luckPanel.Position=UDim2.fromScale(.5,.52)
luckPanel.Size=UDim2.new(.94,0,.8,0)
luckLimit.MaxSize=Vector2.new(510,540)
polish(luckPanel,palette.panel)
local luckTitle=luckPanel:FindFirstChild("Title")
if luckTitle then
    luckTitle.Text="🍀  LABORATOIRE DE CHANCE"
    luckTitle.TextSize=20
    luckTitle.TextScaled=false
    polish(luckTitle,palette.green)
end
polish(luckClose,palette.green)
luckStatus.TextWrapped=true
polish(luckStatus,palette.navy)
for _,button in ipairs(luckButtons) do polish(button,palette.green) end
polish(luckUpgrade,palette.gold)
indexPanel.AnchorPoint=Vector2.new(.5,.5)
indexPanel.Position=UDim2.fromScale(.5,.52)
indexPanel.Size=UDim2.new(.9,0,.78,0)
limit.MaxSize=Vector2.new(490,550)
polish(indexPanel,palette.panel)
notice.AnchorPoint=Vector2.new(.5,0)
notice.Position=UDim2.new(.5,0,0,67)
notice.Size=UDim2.fromOffset(330,46)
polish(notice,palette.gold)
-- Small icon-like visual accents without external asset IDs or broken images.
iconTile(gui,"🐟",UDim2.new(.5,-154,0,12),palette.blue)

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
