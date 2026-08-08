local vehicles = {}
local blocklist = {}
local VEHICLES = exports.qbx_core:GetVehiclesByName()
local sharedConfig = require 'config.shared'.vehicles
local count = 0

-- LINK ẢNH LOCAL NUI
-- %s đầu là category (phân khúc), %s thứ hai là model (mã xe)
local IMAGE_LOCAL = 'nui://qbx_vehicleshop/html/images/%s/%s.png'

local function insertVehicle(vehicleData, shopType)
    count += 1
    
    -- Chống bug: Gán giá trị mặc định nếu database bị thiếu
    local price = vehicleData.price or 0
    local brand = vehicleData.brand or 'Unknown'
    local name = vehicleData.name or 'Unknown'
    local category = (vehicleData.category or 'unknown'):lower()
    
    vehicles[count] = {
        shopType = shopType,
        category = category,
        title = ('%s %s'):format(brand, name),
        description = ('💵 Giá: $%s'):format(lib.math.groupdigits(price)),
        icon = shopType == 'boat' and 'ship' or 'car-side',
        image = IMAGE_LOCAL:format(category, (vehicleData.model):lower()),
        metadata = {
            {label = 'Hãng xe', value = brand},
            {label = 'Phân khúc', value = category}
        },
        serverEvent = 'qbx_vehicleshop:server:swapVehicle',
        args = {
            toVehicle = vehicleData.model,
        }
    }
end

for i = 1, #sharedConfig.blocklist do
    local blockveh = sharedConfig.blocklist[i]
    blocklist[blockveh] = true
end

for k, vehicle in pairs(VEHICLES) do
    local vehicleShop = sharedConfig.models[k] or sharedConfig.categories[vehicle.category] or sharedConfig.default

    if blocklist[k] then
        lib.print.debug('Vehicle is blocked. Skipping: ' .. k)
    elseif not vehicleShop then
        lib.print.debug('Vehicle not found in config. Skipping: ' .. k)
    else
        if type(vehicleShop) == 'table' then
            for i = 1, #vehicleShop do
                insertVehicle(vehicle, vehicleShop[i])
            end
        else
            insertVehicle(vehicle, vehicleShop)
        end
    end
end

table.sort(vehicles, function(a, b)
    local _, aName = a.title:upper():strsplit(' ', 2)
    local _, bName = b.title:upper():strsplit(' ', 2)

    return aName < bName
end)

return {
    vehicles = vehicles,
    count = count,
}
