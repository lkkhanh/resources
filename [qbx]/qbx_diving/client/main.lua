local config = require 'config.client'
local sharedConfig = require 'config.shared'
local isLoggedIn = LocalPlayer.state.isLoggedIn

---@diagnostic disable-next-line: undefined-doc-name
---@type table<integer, CZone> coralIndex to ox_lib zone
local coralZones = {}

---@type table<integer, number> coralIndex to zoneId
local coralTargetZones = {}

local blips = {}

local function takeCoral(coralIndex)
    local times = math.random(2, 5)
    if lib.progressBar({
        duration = times * 1000,
        label = locale('info.collecting_coral'),
        canCancel = true,
        useWhileDead = false,
        allowSwimming = true,
        disable = {
            move = true,
            car = true,
            mouse = false,
            combat = true
        },
        anim = {
            dict = 'weapons@first_person@aim_rng@generic@projectile@thermal_charge@',
            clip = 'plant_floor',
            flag = 16
        }
    }) then
        TriggerEvent('qbx_diving:client:coralTaken', coralIndex)
        TriggerServerEvent('qbx_diving:server:takeCoral', coralIndex)
    end
end

local function clearCoralZones()
    for _, zoneId in pairs(coralTargetZones) do
        exports.ox_target:removeZone(zoneId)
    end
    coralTargetZones = {}
    for _, zone in pairs(coralZones) do
        ---@diagnostic disable-next-line: undefined-field
        zone:remove()
    end
    coralZones = {}
end

local function clearAreaBlips()
    for i = 1, #blips do
        local blip = blips[i]
        if blip and DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    blips = {}
end

local function createAreaBlips(areaIndex)
    local coords = sharedConfig.coralLocations[areaIndex].blip
    local radiusBlip = AddBlipForRadius(coords.x, coords.y, coords.z, 100.0)
    SetBlipRotation(radiusBlip, 0)
    SetBlipColour(radiusBlip, 47)
    SetBlipAlpha(radiusBlip, 100)

    local labelBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(labelBlip, 729)
    SetBlipDisplay(labelBlip, 4)
    SetBlipScale(labelBlip, 0.7)
    SetBlipColour(labelBlip, 0)
    SetBlipAsShortRange(labelBlip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(locale('info.diving_area'))
    EndTextCommandSetBlipName(labelBlip)

    return {radiusBlip, labelBlip}
end

local function createCoralZone(coralIndex, coral)
    if config.useTarget then
        coralTargetZones[coralIndex] = exports.ox_target:addBoxZone({
            coords = coral.coords,
            rotation = coral.boxDimensions.w,
            size = coral.boxDimensions.xyz,
            debug = config.debugPoly,
            options = {
                {
                    label = locale('info.collect_coral'),
                    icon = 'fa-solid fa-water',
                    onSelect = function()
                        takeCoral(coralIndex)
                    end
                }
            },
        })
    else
        coralZones[coralIndex] = lib.zones.box({
            coords = coral.coords,
            rotation = coral.boxDimensions.w,
            size = coral.boxDimensions.xyz,
            debug = config.debugPoly,
            onEnter = function()
                lib.showTextUI(locale('info.collect_coral_dt'))
            end,
            onExit = function()
                lib.hideTextUI()
            end,
            inside = function()
                if IsControlJustPressed(0, 51) then -- E
                    takeCoral(coralIndex)
                    lib.hideTextUI()
                end
            end
        })
    end
end

local function createCoralZones(areaIndex, ignoredCoralIndexes)
    for coralIndex, coral in pairs(sharedConfig.coralLocations[areaIndex].corals) do
        if not ignoredCoralIndexes[coralIndex] then
            createCoralZone(coralIndex, coral)
        end
    end
end

local function setDivingLocation(areaIndex, pickedUpCoralIndexes)
    clearCoralZones()
    createCoralZones(areaIndex, pickedUpCoralIndexes)

    clearAreaBlips()
    blips = createAreaBlips(areaIndex)
end

local function sellCoral()
    if lib.progressBar({
        duration = math.random(2000, 4000),
        label = locale('info.checking_pockets'),
        useWhileDead = false,
        canCancel = true,
        anim = {
            scenario = 'WORLD_HUMAN_STAND_IMPATIENT'
        }
    }) then
        TriggerServerEvent('qbx_diving:server:sellCoral')
    else
        exports.qbx_core:Notify(locale('error.canceled'), 'error')
    end
    ClearPedTasksImmediately(cache.ped)
end

local function rentBoat()
    local spawnCoords = vec4(-1663.0, -1053.0, 1.5, 230.0) -- Tọa độ dưới nước gần NPC Salton Sea
    local closestVeh = lib.getClosestVehicle(spawnCoords.xyz, 5.0, false)
    if closestVeh then
        exports.qbx_core:Notify('Khu vực lấy thuyền đang bị chặn bởi phương tiện khác!', 'error')
        return
    end

    if lib.progressBar({
        duration = 3000,
        label = 'Đang làm thủ tục thuê thuyền...',
        useWhileDead = false,
        canCancel = true,
        anim = {
            scenario = 'WORLD_HUMAN_CLIPBOARD'
        }
    }) then
        lib.callback.await('qbx_diving:server:rentBoat', false, spawnCoords)
    end
end

local function openDivingMenu()
    lib.registerContext({
        id = 'diving_service_menu',
        title = 'Dịch Vụ Lặn Biển',
        options = {
            {
                title = 'Cửa hàng Đồ lặn',
                description = 'Mua mặt nạ lặn và bình oxy dưỡng khí (Như shop 24/7)',
                icon = 'shopping-cart',
                iconColor = '#4287f5',
                onSelect = function()
                    exports.ox_inventory:openInventory('shop', { type = 'DivingShop' })
                end,
            },
            {
                title = 'Thuê thuyền lặn (Dinghy)',
                description = 'Giá: $500. Thuyền sẽ được đưa ra vùng nước an toàn gần nhất.',
                icon = 'ship',
                iconColor = '#f5b042',
                onSelect = rentBoat,
            },
            {
                title = 'Bán San Hô',
                description = 'Thu mua các loại san hô bạn hái được với giá cực kỳ ưu đãi.',
                icon = 'hand-holding-dollar',
                iconColor = '#42f56f',
                onSelect = sellCoral,
            }
        }
    })
    lib.showContext('diving_service_menu')
end

local function createSeller()
    for _, current in pairs(config.sellLocations) do
        current.model = type(current.model) == 'string' and joaat(current.model) or current.model
        lib.requestModel(current.model)
        local ped = CreatePed(0, current.model, current.coords.x, current.coords.y, current.coords.z - 1, current.coords.w, false, false)
        SetModelAsNoLongerNeeded(current.model)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        
        -- Tạo Blip trên bản đồ
        local blip = AddBlipForCoord(current.coords.x, current.coords.y, current.coords.z)
        SetBlipSprite(blip, 371) -- Icon mặt nạ lặn
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.7)
        SetBlipColour(blip, 3) -- Màu xanh dương
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Dịch vụ lặn biển")
        EndTextCommandSetBlipName(blip)

        if config.useTarget then
            exports.ox_target:addLocalEntity(ped, {
                {
                    label = 'Mở Dịch Vụ Lặn Biển',
                    icon = 'fa-solid fa-water',
                    onSelect = openDivingMenu,
                }
            })
        else
            lib.zones.box({
                coords = current.coords.xyz,
                rotation = current.coords.w,
                size = current.zoneDimensions,
                debug = config.debugPoly,
                onEnter = function()
                    lib.showTextUI('[E] Bán san hô  |  [G] Thuê thuyền ($500)')
                end,
                onExit = function()
                    lib.hideTextUI()
                end,
                inside = function()
                    if IsControlJustPressed(0, 51) then -- E
                        sellCoral()
                        lib.hideTextUI()
                    end
                    if IsControlJustPressed(0, 47) then -- G
                        rentBoat()
                        lib.hideTextUI()
                    end
                end
            })
        end
    end
end

local function init()
    local areaIndex, pickedUpCoralIndexes = lib.callback.await('qbx_diving:server:getCurrentDivingArea', false)
    setDivingLocation(areaIndex, pickedUpCoralIndexes)
    createSeller()
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
    init()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
end)

RegisterNetEvent('qbx_diving:client:newLocationSet', function(areaIndex)
    setDivingLocation(areaIndex, {})
end)

RegisterNetEvent('qbx_diving:client:coralTaken', function(coralIndex)
    if coralZones[coralIndex] then
        ---@diagnostic disable-next-line: undefined-field
        coralZones[coralIndex]:remove()
        coralZones[coralIndex] = nil
    end
    if coralTargetZones[coralIndex] then
        exports.ox_target:removeZone(coralTargetZones[coralIndex])
        coralTargetZones[coralIndex] = nil
    end
end)

CreateThread(function()
    if not isLoggedIn then return end
    init()
end)
