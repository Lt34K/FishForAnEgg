-- Server-authoritative progression: eggs, hatching, passive income, rods, base upgrades and saves.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local Config = require(script.Parent:WaitForChild("GameConfig"))
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
        if entry then slots[i] = {egg=entry.egg,hatched=entry.hatched,readyAt=entry.readyAt,creature=entry.creature} end
    end
    stateEvent:FireClient(player,"State",{cash=d.cash,rod=d.rod,base=d.base,plot=d.plot,inventory=d.inventory,slots=slots,rods=Config.Rods,baseCosts=Config.BaseCosts,baseSlots=Config.BaseSlots,index=d.index,skin=d.skin,skins=Config.Skins,creatures=Config.Creatures,rarities=Config.CreatureRarities,totalCreatures=Config.TotalCreatures,habitats=Config.Habitats})
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
local function ornament(parent,name,size,position,color,shape,material)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size
    p.Position=position
    p.Anchored=true
    p.CanCollide=false
    p.Color=color
    p.Material=material or Enum.Material.SmoothPlastic
    if shape then p.Shape=shape end
    p.Parent=parent
    return p
end

local function createEggOrCreature(parent,entry,config,position)
    local holder=Instance.new("Model")
    holder.Name=(entry.hatched and "Creature_" or "Egg_")..config.name
    holder.Parent=parent
    local center=position+Vector3.new(0,2.25,0)
    local creatureName=Config.Creatures[entry.egg] and Config.Creatures[entry.egg][entry.creature or 1] or config.name
    local variant=entry.creature or 1
    local color=(Config.AnimalColors[entry.egg] or {})[variant] or config.color
    local isOcean=entry.egg==5
    local isBird=(entry.egg==2 and variant==5) or (entry.egg==6 and variant==1)
    local isReptile=(entry.egg==4 or (entry.egg==3 and (variant==3 or variant==5)))
    local longBody=(entry.egg==3 and variant==4) or (entry.egg==5 and variant>=3)
    local body=ornament(holder,"Body",entry.hatched and (longBody and Vector3.new(3.7,1.65,2.2) or Vector3.new(2.8,2.25,2.15)) or Vector3.new(2.3,3,2.3),center,color,Enum.PartType.Ball,Enum.Material.SmoothPlastic)
    if entry.hatched then
        if variant>=7 then
            body.Material=Enum.Material.Neon
            local light=Instance.new("PointLight")
            light.Color=color
            light.Brightness=variant==8 and 2.5 or 1.3
            light.Range=variant==8 and 15 or 10
            light.Parent=body
            local sparkle=Instance.new("ParticleEmitter")
            sparkle.Name="RarityAura"
            sparkle.Rate=variant==8 and 12 or 5
            sparkle.Lifetime=NumberRange.new(.7,1.3)
            sparkle.Speed=NumberRange.new(.4,1.3)
            sparkle.SpreadAngle=Vector2.new(180,180)
            sparkle.Color=ColorSequence.new(color,Color3.new(1,1,1))
            sparkle.LightEmission=.7
            sparkle.Size=NumberSequence.new(.22)
            sparkle.Parent=body
        end
        local head=center+Vector3.new(0,.55,-.95)
        ornament(holder,"Head",Vector3.new(1.6,1.45,1.35),head,color,Enum.PartType.Ball)
        for _,side in ipairs({-1,1}) do
            local eye=head+Vector3.new(side*.43,.23,-.61)
            ornament(holder,"Eye",Vector3.new(.32,.37,.22),eye,Color3.new(1,1,1),Enum.PartType.Ball)
            ornament(holder,"Pupil",Vector3.new(.16,.2,.12),eye+Vector3.new(0,0,-.13),Color3.fromRGB(22,28,39),Enum.PartType.Ball)
            if isOcean then
                local fin=ornament(holder,"Flipper",Vector3.new(1.2,.24,.65),center+Vector3.new(side*1.45,-.35,.2),color)
                fin.Orientation=Vector3.new(0,0,side*18)
            elseif isBird then
                ornament(holder,"Wing",Vector3.new(.55,1.3,.95),center+Vector3.new(side*1.25,0,.1),color,Enum.PartType.Ball)
            else
                ornament(holder,"Leg",Vector3.new(.65,.85,.8),center+Vector3.new(side*.85,-1.05,-.35),color,Enum.PartType.Ball)
            end
        end
        if isReptile then
            local tail=ornament(holder,"Tail",Vector3.new(.65,.7,2.2),center+Vector3.new(0,-.45,1.6),color)
            tail.Orientation=Vector3.new(-15,0,0)
        elseif isOcean then
            ornament(holder,"TailFin",Vector3.new(1.55,.35,.8),center+Vector3.new(0,0,1.7),color)
            if variant>=3 then
                ornament(holder,"DorsalFin",Vector3.new(.35,.9,.7),center+Vector3.new(0,1.1,.25),color)
            end
        elseif isBird then
            ornament(holder,"Beak",Vector3.new(.48,.3,.65),head+Vector3.new(0,-.15,-.8),Color3.fromRGB(245,171,61))
        else
            local ears=(entry.egg==1 and (variant==1 or variant==2 or variant==5)) or (entry.egg==3 and variant==1) or (entry.egg==6 and (variant==3 or variant==5))
            if ears then
                for _,side in ipairs({-1,1}) do
                    ornament(holder,"Ear",Vector3.new(.48,.95,.42),head+Vector3.new(side*.55,.88,.15),color,Enum.PartType.Ball)
                end
            end
            ornament(holder,"Nose",Vector3.new(.35,.25,.22),head+Vector3.new(0,-.17,-.75),Color3.fromRGB(50,48,50),Enum.PartType.Ball)
        end
        if entry.egg==3 and variant==3 then
            for _,side in ipairs({-1,1}) do
                ornament(holder,"Claw",Vector3.new(.8,.25,.65),center+Vector3.new(side*1.5,-.7,-.7),color)
            end
        end
    else
        for _,offset in ipairs({Vector3.new(.8,.5,-.8),Vector3.new(-.7,-.35,-.85),Vector3.new(0,.95,-.8)}) do
            ornament(holder,"EggPattern",Vector3.new(.45,.55,.16),center+offset,Color3.fromRGB(255,255,255),Enum.PartType.Ball,Enum.Material.Neon)
        end
    end
    local board=Instance.new("BillboardGui")
    board.Size=UDim2.fromOffset(170,48)
    board.StudsOffset=Vector3.new(0,2.6,0)
    board.AlwaysOnTop=true
    board.Adornee=body
    board.Parent=holder
    local label=Instance.new("TextLabel")
    label.Size=UDim2.fromScale(1,1)
    label.BackgroundTransparency=1
    label.TextColor3=Color3.new(1,1,1)
    label.TextStrokeTransparency=.15
    label.TextScaled=true
    label.Font=Enum.Font.GothamBold
    label.Text=(entry.hatched and ((Config.CreatureRarities[variant] or "").." | "..creatureName) or config.name)..(entry.hatched and ("\\n+"..fmt(config.income).." $/s") or "\\nEn incubation")
    label.Parent=board
end

local function countIndex(index)
    local count=0
    for _,value in pairs(index) do if value==true then count+=1 end end
    return count
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
    local skinConfig=Config.Skins[d.skin] or Config.Skins[1]
    plot.Color=skinConfig.color
    local border=plot.Parent and plot.Parent:FindFirstChild("BaseBorder"..d.plot)
    if border then border.Color=skinConfig.color:Lerp(Color3.new(0,0,0),.35) end
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
        stand.Color=skinConfig.color:Lerp(Color3.new(0,0,0),.3)
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
                current.slots[i]={egg=eggIndex,hatched=false,readyAt=os.time()+Config.Eggs[eggIndex].hatch,creature=(function()
                    local roll=math.random(1,100)
                    for rarity,weight in ipairs(Config.CreatureWeights) do
                        roll-=weight
                        if roll<=0 then return rarity end
                    end
                    return 1
                end)()}
                renderBase(player)
                snapshot(player)
            else
                notify(player,"Ton inventaire d'œufs est vide !")
            end
        end)
        local entry=d.slots[i]
        if entry then
            local egg=Config.Eggs[entry.egg]
            createEggOrCreature(folder,entry,egg,pos)
        end
    end
end

local function save(player)
    local d=data[player]
    if not d or not d.loaded then return end
    while busySave[player] do task.wait(.1) end
    busySave[player]=true
    local slots={}
    for i,e in pairs(d.slots) do if e then slots[i]={egg=e.egg,hatched=e.hatched,readyAt=e.readyAt,creature=e.creature} end end
    local payload={cash=d.cash,rod=d.rod,base=d.base,inventory=table.clone(d.inventory),slots=slots,index=d.index,indexVersion=2,skin=d.skin}
    local ok,err=pcall(function()
        store:UpdateAsync("P_"..player.UserId,function() return payload end)
    end)
    if not ok then warn("Fish for an Egg: sauvegarde impossible pour "..player.Name..": "..tostring(err)) end
    busySave[player]=nil
end

caught.Event:Connect(function(player,rodLevel)
    local d=data[player]
    if not d then return end
    if #d.inventory>=30 then
        notify(player,"Inventaire plein (30 œufs). Place tes œufs dans ta base.")
        return
    end
    local maxEgg=1
    for i,habitat in ipairs(Config.Habitats) do
        if rodLevel>=habitat.minRod then maxEgg=i end
    end
    local total=0
    for i=1,maxEgg do total+=Config.Eggs[i].weight end
    local choice=math.random(1,total)
    local picked=1
    for i=1,maxEgg do
        choice-=Config.Eggs[i].weight
        if choice<=0 then picked=i break end
    end
    table.insert(d.inventory,picked)
    notify(player,"🥚 "..Config.Eggs[picked].name.." ("..Config.Habitats[picked].name..") pêché !")
    snapshot(player)
end)

action.OnServerEvent:Connect(function(player,command,requested)
    local d=data[player]
    if not d then return end
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
    elseif command=="EquipSkin" then
        local skinId=tonumber(requested)
        local skin=skinId and Config.Skins[skinId]
        if not skin or countIndex(d.index)<skin.required then
            notify(player,"Skin non débloqué dans ton Index !")
            return
        end
        d.skin=skinId
        renderBase(player)
        snapshot(player)
        notify(player,"Skin "..skin.name.." équipé !")
    elseif command=="Sync" then snapshot(player) end
end)

Players.PlayerAdded:Connect(function(player)
    local ok,saved=pcall(function() return store:GetAsync("P_"..player.UserId) end)
    if not ok then
        warn("Fish for an Egg: chargement impossible: "..tostring(saved))
        if RunService:IsStudio() then
            warn("Mode test Studio : progression temporaire sans sauvegarde.")
            saved = {}
        else
            player:Kick("Sauvegarde indisponible. Réessaie dans quelques instants.")
            return
        end
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
        plot=plot,inventory={},slots={},index={},skin=1,loaded=ok
    }
    if type(saved.index)=="table" then
        for key,value in pairs(saved.index) do
            local id=tonumber(key)
            if id and value==true then
                local mapped=id
                if saved.indexVersion~=2 then
                    local oldHabitat=math.floor((id-1)/5)
                    local oldVariant=(id-1)%5+1
                    mapped=oldHabitat*Config.CreaturesPerHabitat+oldVariant
                end
                if mapped>=1 and mapped<=Config.TotalCreatures then d.index[tostring(mapped)]=true end
            end
        end
    end
    local savedSkin=math.floor(tonumber(saved.skin) or 1)
    if Config.Skins[savedSkin] and countIndex(d.index)>=Config.Skins[savedSkin].required then d.skin=savedSkin end
    if type(saved.inventory)=="table" then
        for _,v in ipairs(saved.inventory) do
            if type(v)=="number" and Config.Eggs[v] and #d.inventory<30 then table.insert(d.inventory,v) end
        end
    end
    if type(saved.slots)=="table" then
        for i,e in pairs(saved.slots) do
            i=tonumber(i)
            if i and i>=1 and i<=Config.BaseSlots[d.base] and type(e)=="table" and Config.Eggs[e.egg] then
                d.slots[i]={egg=e.egg,hatched=e.hatched==true,readyAt=tonumber(e.readyAt) or os.time(),creature=math.clamp(math.floor(tonumber(e.creature) or 1),1,Config.CreaturesPerHabitat)}
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
                        local creatureId=(entry.egg-1)*Config.CreaturesPerHabitat+(entry.creature or 1)
                        local key=tostring(creatureId)
                        if not d.index[key] then
                            local before=countIndex(d.index)
                            d.index[key]=true
                            local after=before+1
                            notify(player,"📖 Nouvelle créature ! Index : "..after.."/"..Config.TotalCreatures)
                            for _,skin in ipairs(Config.Skins) do
                                if skin.required==after and after>0 then notify(player,"🎨 Skin "..skin.name.." débloqué !") end
                            end
                        end
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
