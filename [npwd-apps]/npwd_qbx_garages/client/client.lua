local function findVehFromPlateAndLocate(plate)
	local coords = lib.callback.await('npwd_qbx_garages:server:locateVehicle', false, plate)
	if coords then
		SetNewWaypoint(coords.x, coords.y)
		
		local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
		SetBlipSprite(blip, 225)
		SetBlipColour(blip, 1)
		SetBlipRoute(blip, true)
		SetBlipRouteColour(blip, 1)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Your Vehicle")
		EndTextCommandSetBlipName(blip)
		
		SetTimeout(60000, function()
			if DoesBlipExist(blip) then RemoveBlip(blip) end
		end)
		
		return true
	end
	return false
end

RegisterNUICallback("npwd:qbx_garage:getVehicles", function(_, cb)
	local vehicles = lib.callback.await('npwd_qbx_garages:server:getPlayerVehicles', false)
	for _, v in pairs(vehicles) do
		local type = GetVehicleClassFromName(v.model)
		if type == 15 or type == 16 then
			v.type = "aircraft"
		elseif type == 14 then
			v.type = "boat"
		elseif type == 13 or type == 8 then
			v.type = "bike"
		else
			v.type = "car"
		end
	end

	cb({ status = "ok", data = vehicles })
end)

RegisterNUICallback("npwd:qbx_garage:requestWaypoint", function(data, cb)
    cb({})
    CreateThread(function()
        local isLocated = findVehFromPlateAndLocate(data.plate)
        local msg = isLocated and "Đã định vị thành công, kiểm tra chấm đỏ trên bản đồ!" or "Xe không có trên bản đồ. Bạn có thể lấy xe ở các bãi đỗ xe!"
        exports.qbx_core:Notify(msg, isLocated and 'success' or 'error')
    end)
end)
