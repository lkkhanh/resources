local isHudVisible = false
local onlinePlayers = 1
local loopCount = 0

CreateThread(function()
    while true do
        Wait(500)
        -- Kiểm tra người chơi đã load xong chưa
        local PlayerData = exports.qbx_core:GetPlayerData()
        if PlayerData and PlayerData.citizenid then
            if not isHudVisible then
                SendNUIMessage({ action = 'show' })
                isHudVisible = true
            end

            -- Lấy số tiền
            local cash = PlayerData.money['cash'] or 0
            local bank = PlayerData.money['bank'] or 0

            -- Lấy vị trí
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local streetHash, crossingHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
            local streetName = GetStreetNameFromHashKey(streetHash)
            if crossingHash ~= 0 then
                streetName = streetName .. " / " .. GetStreetNameFromHashKey(crossingHash)
            end

            -- Lấy ID người chơi
            local playerId = GetPlayerServerId(PlayerId())

            -- Lấy số người online (tối ưu hóa: gọi mỗi 15 giây)
            if loopCount % 5 == 0 then
                onlinePlayers = lib.callback.await('qbx_infohud:server:getOnlinePlayers', false) or 1
            end
            loopCount = loopCount + 1

            -- Gửi dữ liệu lên UI
            SendNUIMessage({
                action = 'update',
                players = onlinePlayers,
                id = playerId,
                street = streetName,
                cash = cash,
                bank = bank
            })
            
            Wait(3000) -- Cập nhật mỗi 3 giây để không bị giật lag
        else
            if isHudVisible then
                SendNUIMessage({ action = 'hide' })
                isHudVisible = false
            end
            Wait(2000)
        end
    end
end)

RegisterNetEvent('hud:client:OnMoneyChange', function(type, amount, isMinus)
    SendNUIMessage({
        action = 'updatemoney',
        type = type,
        amount = amount,
        minus = isMinus
    })
end)
