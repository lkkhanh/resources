local ox_inventory = exports.ox_inventory

lib.callback.register('qbx_doghunter:server:canCatch', function(source, netId)
    local ped = NetworkGetEntityFromNetworkId(netId)
    if not ped or ped == 0 then return false, "Lỗi hệ thống" end
    
    -- Check if someone else is already catching this ped
    if Entity(ped).state.isBeingCaught then
        return false, "Có người đang bắt con này!"
    end
    
    -- Check if player already carries a pet
    local normalCount = ox_inventory:Search(source, 'count', Config.Items.NormalPet)
    local fatCount = ox_inventory:Search(source, 'count', Config.Items.FatPet)
    if normalCount > 0 or fatCount > 0 then
        return false, "Bạn đã vác 1 con vật trên vai! Hãy đem đi bán trước!"
    end
    
    -- Check if player has the rope
    local hasRope = ox_inventory:Search(source, 'count', Config.Items.Rope)
    if hasRope > 0 then
        return true, ""
    end
    return false, "Bạn không có dây bắt chó!"
end)

RegisterNetEvent('qbx_doghunter:server:setCaughtState', function(netId, state)
    local ped = NetworkGetEntityFromNetworkId(netId)
    if ped and ped ~= 0 then
        Entity(ped).state.isBeingCaught = state
    end
end)

RegisterNetEvent('qbx_doghunter:server:catchSuccess', function()
    local src = source
    local ropeItem = ox_inventory:GetItem(src, Config.Items.Rope, nil, true)
    
    if ropeItem and ropeItem > 0 then
        -- Manage durability (we'll just remove 1 item for simplicity if it breaks, or use metadata)
        -- Since the config says "5 uses", we can either add a metadata tracker or just let ox_inventory handle it 
        -- if it's set as a weapon/tool. For now, to ensure it breaks after 5 uses, we can use metadata:
        -- Get the first slot containing the rope
        local slots = ox_inventory:GetInventory(src).items
        local ropeSlot = nil
        for k, v in pairs(slots) do
            if v.name == Config.Items.Rope then
                ropeSlot = v
                break
            end
        end
        
        if ropeSlot then
            local currentUses = (ropeSlot.metadata and ropeSlot.metadata.uses) or 5
            currentUses = currentUses - 1
            
            if currentUses <= 0 then
                ox_inventory:RemoveItem(src, Config.Items.Rope, 1, nil, ropeSlot.slot)
                exports.qbx_core:Notify(src, "Dây bắt chó của bạn đã bị đứt!", "error")
            else
                ox_inventory:SetMetadata(src, ropeSlot.slot, {uses = currentUses})
            end
            
            -- Give reward
            local chance = math.random(1, 100)
            if chance <= Config.FatPetChance then
                ox_inventory:AddItem(src, Config.Items.FatPet, 1)
                exports.qbx_core:Notify(src, "Tuyệt vời! Bạn vừa bắt được một con vật rất béo!", "success")
            else
                ox_inventory:AddItem(src, Config.Items.NormalPet, 1)
                exports.qbx_core:Notify(src, "Bắt thành công một con vật thường.", "success")
            end
        end
    end
end)

local sellCooldowns = {}
RegisterNetEvent('qbx_doghunter:server:sellPets', function()
    local src = source
    
    -- Anti Spam
    if sellCooldowns[src] and (os.time() - sellCooldowns[src]) < 2 then
        return
    end
    sellCooldowns[src] = os.time()
    
    local normalCount = ox_inventory:Search(src, 'count', Config.Items.NormalPet)
    local fatCount = ox_inventory:Search(src, 'count', Config.Items.FatPet)
    
    local totalMoney = 0
    if normalCount > 0 then
        if ox_inventory:RemoveItem(src, Config.Items.NormalPet, normalCount) then
            totalMoney = totalMoney + (normalCount * Config.Prices.NormalPet)
        end
    end
    
    if fatCount > 0 then
        if ox_inventory:RemoveItem(src, Config.Items.FatPet, fatCount) then
            totalMoney = totalMoney + (fatCount * Config.Prices.FatPet)
        end
    end
    
    if totalMoney > 0 then
        exports.qbx_core:AddMoney(src, 'cash', totalMoney, "Sold caught pets")
        exports.qbx_core:Notify(src, "Bạn đã bán thú và nhận được $" .. totalMoney, "success")
    else
        exports.qbx_core:Notify(src, "Bạn không có con vật nào để bán!", "error")
    end
end)

-- Penalty Event
local function HandlePenalty(src)
    local normalCount = ox_inventory:Search(src, 'count', Config.Items.NormalPet)
    local fatCount = ox_inventory:Search(src, 'count', Config.Items.FatPet)
    local ropeCount = ox_inventory:Search(src, 'count', Config.Items.Rope)
    
    if normalCount > 0 then ox_inventory:RemoveItem(src, Config.Items.NormalPet, normalCount) end
    if fatCount > 0 then ox_inventory:RemoveItem(src, Config.Items.FatPet, fatCount) end
    if ropeCount > 0 then ox_inventory:RemoveItem(src, Config.Items.Rope, ropeCount) end
    
    local Player = exports.qbx_core:GetPlayer(src)
    if Player then
        Player.Functions.RemoveMoney('cash', Config.PenaltyFine, "Penalty for animal hunting")
        Player.Functions.RemoveMoney('bank', Config.PenaltyFine, "Penalty for animal hunting")
    end
    
    if normalCount > 0 or fatCount > 0 or ropeCount > 0 then
        exports.qbx_core:Notify(src, "Bạn đã bị tịch thu toàn bộ tang vật và dây bắt thú, đồng thời bị phạt tiền!", "error")
    end
end

-- Hook into death or jail events (Standard Qbox events)
RegisterNetEvent('qbx_medical:server:playerDied', function()
    local src = source
    if GetPlayerWantedLevel(src) > 0 then
        HandlePenalty(src)
    end
end)

RegisterNetEvent('police:server:JailPlayer', function(playerId, time)
    -- Assuming a standard police jail event
    HandlePenalty(playerId)
end)
