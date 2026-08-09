lib.versionCheck('Qbox-project/npwd_qbx_garages')
assert(GetResourceState('qbx_garages') == 'started', 'qbx_garages is not started')

local garageConfig = exports.qbx_garages:GetGarages()
local VEHICLES = exports.qbx_core:GetVehiclesByName()

lib.callback.register('npwd_qbx_garages:server:getPlayerVehicles', function(source)
	local player = exports.qbx_core:GetPlayer(source)
	if not player then return {} end

	local result = MySQL.query.await('SELECT * FROM player_vehicles WHERE citizenid = ?', { player.PlayerData.citizenid })
	for i = 1, #result do
		local vehicleData = result[i]
		local model = vehicleData.vehicle

		vehicleData.model = model
		vehicleData.vehicle = 'Unknown'
		vehicleData.brand = 'Vehicle'

		if vehicleData.state == 0 then
			vehicleData.state = 'out'
		elseif vehicleData.state == 1 then
			vehicleData.state = 'garaged'
		elseif vehicleData.state == 2 then
			vehicleData.state = 'impounded'
		else
			vehicleData.state = 'unknown'
		end

		if VEHICLES[model] then
			vehicleData.vehicle = VEHICLES[model].name
			vehicleData.brand = VEHICLES[model].brand
		end

		if vehicleData.state == 'out' then
			vehicleData.garage = 'Out on map'
		elseif vehicleData.state == 'impounded' then
			vehicleData.garage = 'Impound Lot'
		else
			vehicleData.garage = garageConfig[vehicleData.garage]?.label or locale('states.garage_unknown')
		end
	end

	return result
end)

lib.callback.register('npwd_qbx_garages:server:locateVehicle', function(source, plate)
	local vehicles = GetAllVehicles()
	for i = 1, #vehicles do
		local vehicle = vehicles[i]
		local vehPlate = GetVehicleNumberPlateText(vehicle)
		if vehPlate and string.match(vehPlate, "^%s*(.-)%s*$") == string.match(plate, "^%s*(.-)%s*$") then
			return GetEntityCoords(vehicle)
		end
	end
	return nil
end)


AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == 'qbx_garages' then
        CreateThread(function()
            Wait(100)
            garageConfig = exports.qbx_garages:GetGarages()
        end)
    end
end)

AddEventHandler('qbx_garages:server:garageRegistered', function(garageName, newGarageConfig)
    garageConfig[garageName] = newGarageConfig
end)