lib.versionCheck('Qbox-project/qbx_diving')
assert(lib.checkDependency('ox_lib', '3.20.0', true))

local logger = require '@qbx_core.modules.logger'
require '@qbx_core.modules.lib'
local config = require 'config.server'
local sharedConfig = require 'config.shared'
local currentAreaIndex = math.random(1, #sharedConfig.coralLocations)

---@type table<integer, true> Set of coralIndex
local pickedUpCoralIndexes = {}
local rotationTimer = nil
local rentedBoats = {}

local function getNewLocation()
    local newLocation
    repeat
        newLocation = math.random(1, #sharedConfig.coralLocations)
    until newLocation ~= currentAreaIndex or #sharedConfig.coralLocations == 1
    return newLocation
end

local function resetRotationTimer()
    if rotationTimer then
        ClearTimeout(rotationTimer)
    end
    rotationTimer = SetTimeout(45 * 60 * 1000, function()
        pickedUpCoralIndexes = {}
        currentAreaIndex = getNewLocation()
        TriggerClientEvent('qbx_diving:client:newLocationSet', -1, currentAreaIndex)
        logger.log({
            source = 'System',
            event = 'qbx_diving:server:autoRotateArea',
            message = locale('logs.new_location', currentAreaIndex),
            webhook = config.discordWebhook,
        })
        resetRotationTimer()
    end)
end

resetRotationTimer()

local function getItemPrice(amount, price)
    for i = 1, #config.priceModifiers do
        local modifier = config.priceModifiers[i]
        local shouldModify = i == #config.priceModifiers and amount >= modifier.minAmount or
        amount >= modifier.minAmount and amount <= modifier.maxAmount
        if shouldModify then
            price = price / 100 * math.random(modifier.minPercentage, modifier.maxPercentage)
            break
        end
    end
    return price
end

RegisterNetEvent('qbx_diving:server:sellCoral', function()
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end
    local payout = 0

    for i = 1, #config.coralTypes do
        local coral = config.coralTypes[i]
        local count = exports.ox_inventory:GetItemCount(src, coral.item)

        if count and count > 0 then
            if exports.ox_inventory:RemoveItem(src, coral.item, count) then
                local price = count * coral.price
                local reward = getItemPrice(count, price)
                payout += math.ceil(reward)
            end
        end
    end

    if payout == 0 then
        logger.log({
            source = src,
            event = 'qbx_diving:server:sellCoral',
            message = locale('logs.tried_sell'),
            webhook = config.discordWebhook,
        })
        return exports.qbx_core:Notify(src, locale('error.no_coral'), 'error')
    end

    logger.log({
        source = src,
        event = 'qbx_diving:server:sellCoral',
        message = locale('logs.sell_coral', payout),
        webhook = config.discordWebhook,
    })
    player.Functions.AddMoney('cash', payout, 'sold-coral')
end)

RegisterNetEvent('qbx_diving:server:takeCoral', function(coralIndex)
    if pickedUpCoralIndexes[coralIndex] then return end
    local src = source
    local coralType = config.coralTypes[math.random(1, #config.coralTypes)]
    local amount = math.random(1, coralType.maxAmount)

    exports.ox_inventory:AddItem(src, coralType.item, amount)
    
    -- Rớt đồ hiếm 10%
    if math.random(1, 100) <= 10 then
        local rareItem = math.random(1, 2) == 1 and 'goldchain' or 'diamond_ring'
        exports.ox_inventory:AddItem(src, rareItem, 1)
        exports.qbx_core:Notify(src, 'Bạn tìm thấy một vật phẩm lấp lánh trong rạn san hô!', 'success')
    end

    pickedUpCoralIndexes[coralIndex] = true
    TriggerClientEvent('qbx_diving:client:coralTaken', -1, coralIndex)
    TriggerEvent('qbx_diving:server:coralTaken', sharedConfig.coralLocations[currentAreaIndex].corals[coralIndex].coords)

    logger.log({
        source = src,
        event = 'qbx_diving:server:takeCoral',
        message = locale('logs.collect_coral', coralIndex),
        webhook = config.discordWebhook,
    })

    if qbx.table.size(pickedUpCoralIndexes) >= sharedConfig.coralLocations[currentAreaIndex].maxHarvestAmount then
        pickedUpCoralIndexes = {}
        currentAreaIndex = getNewLocation()
        TriggerClientEvent('qbx_diving:client:newLocationSet', -1, currentAreaIndex)
        logger.log({
            source = src,
            event = 'qbx_diving:server:takeCoral',
            message = locale('logs.new_location', currentAreaIndex),
            webhook = config.discordWebhook,
        })
        resetRotationTimer()
    end
end)

---@return integer areaIndex
---@return table<integer, true> pickedUpCoralIndexes
lib.callback.register('qbx_diving:server:getCurrentDivingArea', function()
    return currentAreaIndex, pickedUpCoralIndexes
end)

lib.callback.register('qbx_diving:server:rentBoat', function(source, coords)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return false end
    
    local price = 500
    if player.Functions.RemoveMoney('cash', price, 'boat-rental') or player.Functions.RemoveMoney('bank', price, 'boat-rental') then
        if rentedBoats[src] and DoesEntityExist(rentedBoats[src]) then
            DeleteEntity(rentedBoats[src])
        end

        local netId, veh = qbx.spawnVehicle({
            model = 'dinghy',
            spawnSource = coords,
            warp = src,
        })

        if veh then
            rentedBoats[src] = veh
            exports.qbx_core:Notify(src, 'Bạn đã thuê một chiếc thuyền với giá $500', 'success')
            return netId
        end
        return false
    else
        exports.qbx_core:Notify(src, 'Không đủ tiền ($500)', 'error')
        return false
    end
end)