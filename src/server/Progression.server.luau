-- Server-authoritative progression: eggs, hatching, passive income, rods, base upgrades and saves.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local Config = require(script.Parent:WaitForChild("GameConfig.module"))
local store = DataStoreService:GetDataStore(RunService:IsStudio() and "FishEgg_Studio_Prototype_V1" or "FishEgg_Live_V1")

local caught = Instance.new("BindableEvent")
caught.Name = "EggCaught"
caught.Parent = script.Parent
local action = Instance.new("RemoteEvent")
action.Name = "ProgressionAction"
action.Parent = ReplicatedStorage
local stateEvent = Instance.new("RemoteEvent")
stateEvent.Name = "ProgressionState"
stateEvent.Parent = ReplicatedStorage

local data = {}
local plotOwners = {}
local busySave = {}
local function fmt(n)
    if n >= 1e15 then return string.format("%.2f Qa",n/1e15) end
    if n >= 1e12 then return string.format("%.2f T",n/1e12) end
    if n >= 1e9 then return string.format("%.2f B",n/1e9) end
    if n >= 1e6 then return string.format("%.2f M",n/1e6) end
    if n >= 1e3 then return string.format("%.1f K",n/1e3) end
    return tostring(math.floor(n))
end
local function notify(player,msg)
    stateEvent:FireClient(player,"Notice",msg)
end
local function snapshot(player)
    local d = data[player]
    if not d then return end
    local slots = {}
    for i,entry in pairs(d.slots) do
        if entry then slots[i] = {egg=entry.egg,hatched=entry.hatched,readyAt=entry.readyAt} end
    end
    stateEvent:FireClient(player,"State",{cash=d.cash,rod=d.rod,base=d.base,plot=d.plot,inventory=d.inventory,slots=slots,rods=Config.Rods,baseCosts=Config.BaseCosts,baseSlots=Config.BaseSlots})
end
local function updateCash(player)
    local d=data[player]
    if not d then return end
    local stats=player:FindFirstChild("leaderstats")
    local cash=stats and stats:FindFirstChild("Cash")
    if cash then cash.Value=math.floor(d.cash) end
end
local function buildRod(index)
    local cfg=Config.Rods[index]
    local tool=Instance.new("Tool")
    tool.Name="Canne "..cfg.name
    tool.RequiresHandle=true
    tool.CanBeDropped=false
    tool.ToolTip="Distance "..cfg.distance.."m | Profondeur "..cfg.depth.."m"
    tool:SetAttribute("RodLevel",index)
    tool:SetAttribute("CastDistance",cfg.distance)
    tool:SetAttribute("FishingDepth",cfg.depth)
    local handle=Instance.new("Part")
    handle.Name="Handle"
    handle.Size=Vector3.new(.28,4.2,.28)
    handle.Material=Enum.Material.Wood
    handle.Color=cfg.color
    handle.CanCollide=false
    handle.Massless=true
    handle.Parent=tool
    local tip=Instance.new("Part")
    tip.Name="RodTip"
    tip.Size=Vector3.new(.13,1.8,.13)
    tip.Color=cfg.color
    tip.CanCollide=false
    tip.Massless=true
    tip.CFrame=handle.CFrame*CFrame.new(0,2.9,0)
    tip.Parent=tool
    local weld=Instance.new("WeldConstraint")
    weld.Part0=handle
    weld.Part1=tip
    weld.Parent=handle
    local reel=Instance.new("Part")
    reel.Name="Reel"
    reel.Shape=Enum.PartType.Cylinder
    reel.Size=Vector3.new(.65,.38,.65)
    reel.Color=Color3.fromRGB(67,75,82)
    reel.Material=Enum.Material.Metal
    reel.CanCollide=false
    reel.Massless=true
    reel.CFrame=handle.CFrame*CFrame.new(.3,-.6,0)
    reel.Parent=tool
    local reelWeld=Instance.new("WeldConstraint")
    reelWeld.Part0=handle
    reelWeld.Part1=reel
    reelWeld.Parent=handle
    tool.Grip=CFrame.new(0,-1.2,0)*CFrame.Angles(math.rad(-20),0,0)
    return tool
end
local function grantRod(player)
    local d=data[player]
    if not d then return end
    local backpack=player:FindFirstChild("Backpack")
    if not backpack then return end
    for _,container in ipairs({backpack,player.Character}) do
        if container then
            for _,item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") and (item:GetAttribute("RodLevel") or item.Name=="Canne en bois") then item:Destroy() end
            end
        end
    end
    buildRod(d.rod).Parent=backpack
end
local function getPlot(d)
    local world=workspace:FindFirstChild("FishWorld")
    local folder=world and world:FindFirstChild("BasePlots")
    return folder and folder:FindFirstChild("Base"..d.plot)
end
local function clearDecor(d)
    if d.decor then d.decor:Destroy() d.decor=nil end
end
local renderBase
renderBase = function(player)
    local d=data[player]
    if not d or not d.plot then return end
    local plot=getPlot(d)
    if not plot then return end
    clearDecor(d)
    if d.sign then d.sign:Destroy() d.sign=nil end
    local folder=Instance.new("Folder")
    folder.Name="PlayerBase_"..player.UserId
    folder.Parent=workspace
    d.decor=folder
    local sign=Instance.new("BillboardGui")
    sign.Name="OwnerSign"
    sign.Size=UDim2.fromOffset(240,50)
    sign.StudsOffset=Vector3.new(0,5,0)
    sign.AlwaysOnTop=true
    sign.Parent=plot
    local signText=Instance.new("TextLabel")
    signText.Size=UDim2.fromScale(1,1)
    signText.BackgroundColor3=Color3.fromRGB(28,53,77)
    signText.BackgroundTransparency=.15
    signText.TextColor3=Color3.new(1,1,1)
    signText.TextScaled=true
    signText.Font=Enum.Font.GothamBold
    signText.Text=player.DisplayName.." | Base niv. "..d.base
    signText.Parent=sign
    d.sign=sign
    local limit=Config.BaseSlots[d.base]
    for i=1,limit do
        local col=(i-1)%5
        local row=math.floor((i-1)/5)
        local pos=plot.Position+Vector3.new(-15+col*7,1.15,-10+row*7)
        local stand=Instance.new("Part")
        stand.Name="Slot"..i
        stand.Size=Vector3.new(5,1,5)
        stand.Position=pos
        stand.Anchored=true
        stand.Color=Color3.fromRGB(55,121,168)
        stand.Material=Enum.Material.SmoothPlastic
        stand.Parent=folder
        local prompt=Instance.new("ProximityPrompt")
        prompt.ActionText=d.slots[i] and "Voir l'œuf" or "Placer un œuf"
        prompt.ObjectText="Emplacement "..i
        prompt.HoldDuration=.25
        prompt.MaxActivationDistance=10
        prompt.Parent=stand
        prompt.Triggered:Connect(function(who)
            if who~=player then return end
            local current=data[player]
            if not current or current.plot~=d.plot then return end
            if current.slots[i] then
                local e=current.slots[i]
                local cfg=Config.Eggs[e.egg]
                notify(player,cfg.name..(e.hatched and (" | +"..fmt(cfg.income).." $/s") or " | incubation"))
            elseif #current.inventory>0 then
                local eggIndex=table.remove(current.inventory,1)
                current.slots[i]={egg=eggIndex,hatched=false,readyAt=os.time()+Config.Eggs[eggIndex].hatch}
                renderBase(player)
                snapshot(player)
            else
                notify(player,"Ton inventaire d'œufs est vide !")
            end
        end)
        local entry=d.slots[i]
        if entry then
            local egg=Config.Eggs[entry.egg]
            local model=Instance.new("Part")
            model.Name=entry.hatched and "Créature_"..egg.name or egg.name
            model.Shape=entry.hatched and Enum.PartType.Ball or Enum.PartType.Ball
            model.Size=entry.hatched and Vector3.new(3.4,3.4,3.4) or Vector3.new(2.5,3.1,2.5)
            model.Position=pos+Vector3.new(0,2.5,0)
            model.Anchored=true
            model.CanCollide=false
            model.Material=Enum.Material.Neon
            model.Color=egg.color
            model.Parent=folder
            local board=Instance.new("BillboardGui")
            board.Size=UDim2.fromOffset(160,46)
            board.StudsOffset=Vector3.new(0,2.5,0)
            board.AlwaysOnTop=true
            board.Parent=model
            local text=Instance.new("TextLabel")
            text.Size=UDim2.fromScale(1,1)
            text.BackgroundTransparency=1
            text.TextColor3=Color3.new(1,1,1)
            text.TextStrokeTransparency=.2
            text.TextScaled=true
            text.Font=Enum.Font.GothamBold
            text.Text=egg.name..(entry.hatched and ("\n+"..fmt(egg.income).." $/s") or "\nÉclosion en cours")
            text.Parent=board
        end
    end
end

local function save(player)
    local d=data[player]
    if not d or not d.loaded then return end
    while busySave[player] do task.wait(.1) end
    busySave[player]=true
    local slots={}
    for i,e in pairs(d.slots) do if e then slots[i]={egg=e.egg,hatched=e.hatched,readyAt=e.readyAt} end end
    local payload={cash=d.cash,rod=d.rod,base=d.base,inventory=table.clone(d.inventory),slots=slots}
    local ok,err=pcall(function()
        store:UpdateAsync("P_"..player.UserId,function() return payload end)
    end)
    if not ok then warn("Fish for an Egg: sauvegarde impossible pour "..player.Name..": "..tostring(err)) end
    busySave[player]=nil
end

caught.Event:Connect(function(player,rodLevel)
    local d=data[player]
    if not d or not d.loaded then return end
    if #d.inventory>=30 then
        notify(player,"Inventaire plein (30 œufs). Place tes œufs dans ta base.")
        return
    end
    local maxEgg=math.min(#Config.Eggs,2+math.floor((rodLevel-1)/2))
    local total=0
    for i=1,maxEgg do total+=Config.Eggs[i].weight end
    local choice=math.random(1,total)
    local picked=1
    for i=1,maxEgg do
        choice-=Config.Eggs[i].weight
        if choice<=0 then picked=i break end
    end
    table.insert(d.inventory,picked)
    notify(player,"🥚 "..Config.Eggs[picked].name.." pêché ! Va le placer dans ta base.")
    snapshot(player)
end)

action.OnServerEvent:Connect(function(player,command)
    local d=data[player]
    if not d or not d.loaded then return end
    if command=="BuyRod" then
        local nextLevel=d.rod+1
        local cfg=Config.Rods[nextLevel]
        if not cfg then notify(player,"Tu possèdes déjà la meilleure canne !") return end
        if d.cash<cfg.price then notify(player,"Il te faut "..fmt(cfg.price).." $ !") return end
        d.cash-=cfg.price
        d.rod=nextLevel
        grantRod(player)
        updateCash(player)
        notify(player,"Nouvelle canne : "..cfg.name.." !")
        snapshot(player)
    elseif command=="UpgradeBase" then
        local nextLevel=d.base+1
        local price=Config.BaseCosts[nextLevel]
        if not price then notify(player,"Base au niveau maximum !") return end
        if d.cash<price then notify(player,"Il te faut "..fmt(price).." $ !") return end
        d.cash-=price
        d.base=nextLevel
        updateCash(player)
        renderBase(player)
        notify(player,"Base améliorée ! "..Config.BaseSlots[nextLevel].." emplacements.")
        snapshot(player)
    elseif command=="Sync" then snapshot(player) end
end)

Players.PlayerAdded:Connect(function(player)
    local ok,saved=pcall(function() return store:GetAsync("P_"..player.UserId) end)
    if not ok then
        warn("Fish for an Egg: chargement impossible: "..tostring(saved))
        player:Kick("Sauvegarde indisponible. Réessaie dans quelques instants.")
        return
    end
    saved=type(saved)=="table" and saved or {}
    local plot
    for i=1,6 do if not plotOwners[i] then plot=i break end end
    if not plot then player:Kick("Toutes les bases sont occupées. Rejoins un autre serveur.") return end
    plotOwners[plot]=player
    local d={
        cash=math.max(0,tonumber(saved.cash) or 0),
        rod=math.clamp(math.floor(tonumber(saved.rod) or 1),1,#Config.Rods),
        base=math.clamp(math.floor(tonumber(saved.base) or 1),1,#Config.BaseSlots),
        plot=plot,inventory={},slots={},loaded=true
    }
    if type(saved.inventory)=="table" then
        for _,v in ipairs(saved.inventory) do
            if type(v)=="number" and Config.Eggs[v] and #d.inventory<30 then table.insert(d.inventory,v) end
        end
    end
    if type(saved.slots)=="table" then
        for i,e in pairs(saved.slots) do
            if type(i)=="number" and i>=1 and i<=Config.BaseSlots[d.base] and type(e)=="table" and Config.Eggs[e.egg] then
                d.slots[i]={egg=e.egg,hatched=e.hatched==true,readyAt=tonumber(e.readyAt) or os.time()}
            end
        end
    end
    data[player]=d
    local stats=Instance.new("Folder")
    stats.Name="leaderstats"
    stats.Parent=player
    local cash=Instance.new("NumberValue")
    cash.Name="Cash"
    cash.Value=math.floor(d.cash)
    cash.Parent=stats
    player.CharacterAdded:Connect(function()
        task.wait(.5)
        grantRod(player)
    end)
    task.defer(function()
        player:WaitForChild("Backpack")
        grantRod(player)
        local world=workspace:WaitForChild("FishWorld",15)
        if world then renderBase(player) end
        snapshot(player)
        notify(player,"Ta base est la base "..plot.." !")
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    save(player)
    local d=data[player]
    if d then
        clearDecor(d)
        if d.sign then d.sign:Destroy() end
        plotOwners[d.plot]=nil
    end
    data[player]=nil
end)

task.spawn(function()
    while task.wait(1) do
        for player,d in pairs(data) do
            local income=0
            local changed=false
            for _,entry in pairs(d.slots) do
                if entry then
                    if not entry.hatched and os.time()>=entry.readyAt then
                        entry.hatched=true
                        changed=true
                    end
                    if entry.hatched then income+=Config.Eggs[entry.egg].income end
                end
            end
            if income>0 then d.cash+=income updateCash(player) end
            if changed then renderBase(player) notify(player,"🥚 Un œuf vient d'éclore !") end
            if changed then snapshot(player) end
        end
    end
end)

task.spawn(function()
    while task.wait(120) do
        for player in pairs(data) do task.spawn(save,player) end
    end
end)
game:BindToClose(function()
    for player in pairs(data) do task.spawn(save,player) end
    task.wait(3)
end)
print("Fish for an Egg : progression, bases, éclosions, revenus et sauvegardes prêts")
