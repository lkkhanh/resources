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
    if normalCount > 0 then
        return false, "Bạn đã có 1 con vật trong hành trang! Hãy đem đi bán trước!"
    end
    
    -- Check if player has the rope
    local hasRope = ox_inventory:Search(source, 'count', Config.Items.Rope)
    if hasRope > 0 then
        -- Atomically set the state here to prevent dual-catching race conditions
        Entity(ped).state:set('isBeingCaught', true, true)
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

RegisterNetEvent('qbx_doghunter:server:catchSuccess', function(netId)
    local src = source
    local ped = NetworkGetEntityFromNetworkId(netId)
    if ped and ped ~= 0 then
        DeleteEntity(ped)
    end
    
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
            local minWeight = Config.WeightRange.min * 10
            local maxWeight = Config.WeightRange.max * 10
            local randomWeight = math.random(minWeight, maxWeight) / 10.0
            
            local itemData = ox_inventory:Items(Config.Items.NormalPet)
            local baseWeight = itemData and itemData.weight or 0
            local extraWeightGrams = math.floor(randomWeight * 1000) - baseWeight
            
            ox_inventory:AddItem(src, Config.Items.NormalPet, 1, { 
                petWeight = randomWeight, 
                weight = extraWeightGrams,
                description = string.format("Cân nặng: %.1f kg", randomWeight) 
            })
            exports.qbx_core:Notify(src, string.format("Bắt thành công! Con vật nặng %.1f kg.", randomWeight), "success")
        end
    end
end)

RegisterNetEvent('qbx_doghunter:server:deletePet', function(netId)
    local ped = NetworkGetEntityFromNetworkId(netId)
    if ped and ped ~= 0 then
        DeleteEntity(ped)
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
    
    local inventory = ox_inventory:GetInventory(src)
    local foundSlot = nil
    local foundWeight = 5.0 -- default fallback weight

    if inventory and inventory.items then
        for k, v in pairs(inventory.items) do
            if v.name == Config.Items.NormalPet then
                foundSlot = v.slot
                if v.metadata and v.metadata.petWeight then
                    foundWeight = tonumber(v.metadata.petWeight) or 5.0
                elseif v.metadata and v.metadata.weight then
                    -- Hỗ trợ tương thích ngược với thú cũ
                    foundWeight = tonumber(v.metadata.weight) or 5.0
                    if foundWeight > 100 then foundWeight = 5.0 end -- Chống lỗi nếu weight cũ là số gram
                end
                break
            end
        end
    end
    
    if foundSlot then
        local totalMoney = math.floor(foundWeight * Config.PricePerKg)
        if ox_inventory:RemoveItem(src, Config.Items.NormalPet, 1, nil, foundSlot) then
            exports.qbx_core:AddMoney(src, 'cash', totalMoney, "Sold caught pet")
            exports.qbx_core:Notify(src, "Bạn đã bán thú (" .. foundWeight .. "kg) và nhận được $" .. totalMoney, "success")
        end
    else
        exports.qbx_core:Notify(src, "Bạn không có con vật nào để bán!", "error")
    end
end)

-- Penalty Event
local function HandlePenalty(src)
    local normalCount = ox_inventory:Search(src, 'count', Config.Items.NormalPet)
    local ropeCount = ox_inventory:Search(src, 'count', Config.Items.Rope)
    
    if normalCount > 0 then 
        local inv = ox_inventory:GetInventory(src)
        if inv and inv.items then
            for _, v in pairs(inv.items) do
                if v.name == Config.Items.NormalPet then
                    ox_inventory:RemoveItem(src, Config.Items.NormalPet, 1, nil, v.slot)
                end
            end
        end
    end
    
    if ropeCount > 0 then ox_inventory:RemoveItem(src, Config.Items.Rope, ropeCount) end
    
    local Player = exports.qbx_core:GetPlayer(src)
    if Player then
        Player.Functions.RemoveMoney('cash', Config.PenaltyFine, "Penalty for animal hunting")
        Player.Functions.RemoveMoney('bank', Config.PenaltyFine, "Penalty for animal hunting")
    end
    
    if normalCount > 0 or ropeCount > 0 then
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

-- Chặn cất cốp xe hoặc tủ đồ
CreateThread(function()
    exports.ox_inventory:registerHook('swapItem', function(payload)
        -- Trong ox_inventory, túi đồ của người chơi là số (ID), còn cốp xe/tủ đồ/quăng ra đất là chuỗi (string)
        if type(payload.toInventory) == 'string' and payload.fromInventory == payload.source then
            -- Cho phép thả thú cưng (khi vứt ra đất)
            if string.find(payload.toInventory, 'drop') then
                local playerSrc = payload.source
                local slot = payload.fromSlot
                
                -- Tạo một tiểu trình chạy ngầm để xóa vật phẩm một cách an toàn mà không làm lỗi hook
                CreateThread(function()
                    Wait(0)
                    exports.ox_inventory:RemoveItem(playerSrc, Config.Items.NormalPet, 1, nil, slot)
                    TriggerClientEvent('ox_lib:notify', playerSrc, { type = 'success', description = 'Bạn đã thả thú cưng đi!' })
                end)
                
                return false -- Chặn hành động vứt đồ mặc định (để item không rớt thành bọc ngoài đường)
            end
            
            TriggerClientEvent('ox_lib:notify', payload.source, { type = 'error', description = 'Không thể cất thú cưng vào cốp/tủ đồ!' })
            return false
        end
        return true
    end, {
        itemFilter = {
            [Config.Items.NormalPet] = true
        }
    })
end)
