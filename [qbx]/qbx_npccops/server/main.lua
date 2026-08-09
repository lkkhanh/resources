local QBCore = exports['qbx_core']

local crimeToStars = {
    -- 1 Sao
    ['info.possible_drug_dealing'] = 1,

    -- 2 Sao
    ['general.store_robbery'] = 2, -- (I need to verify this locale string, but I'll use text matching)

    -- 3 Sao
    ['notify.police_alert'] = 3, -- House robbery
    ['notify.police'] = 3, -- Jewelry

    -- 5 Sao
    ['info.vehicle_theft'] = 5,
    ['carjack'] = 5,
    ['steal'] = 5,

    -- 4 Sao
    ['general.fleeca_robbery_alert'] = 4,

    -- 5 Sao
    ['general.pacific_robbery_alert'] = 5,
    ['general.paleto_robbery_alert'] = 5,
    ['info.officer_down'] = 5
}

RegisterNetEvent('police:server:policeAlert', function(text, camId, playerSource)
    local src = playerSource or source
    if not src then return end
    
    -- Tránh lỗi khi text bị nil (một số script như qbx_storerobbery gửi nil)
    text = text or "general.store_robbery"

    local stars = 0
    local timerType = 'evasion'
    local duration = 120

    local lowerText = string.lower(text)

    -- Phân loại tội phạm
    if string.find(lowerText, 'ngân hàng') or string.find(lowerText, 'bank') or string.find(lowerText, 'fleeca') or string.find(lowerText, 'pacific') or string.find(lowerText, 'paleto') then
        -- Cướp ngân hàng: 5 sao, sinh tồn 10 phút
        stars = 5
        timerType = 'survival'
        duration = 600
    elseif string.find(lowerText, 'xe') or string.find(lowerText, 'vehicle') or string.find(lowerText, 'carjack') or string.find(lowerText, 'steal') then
        -- Trộm xe, bẻ khóa: 2 sao, lẩn trốn 3 phút
        stars = 2
        timerType = 'evasion'
        duration = 180
    elseif string.find(lowerText, 'cửa hàng') or string.find(lowerText, 'store') then
        -- Cướp cửa hàng: 2 sao, lẩn trốn 3 phút
        stars = 2
        timerType = 'evasion'
        duration = 180
    elseif string.find(lowerText, 'drug') or string.find(lowerText, 'ma túy') or string.find(lowerText, 'weed') or string.find(lowerText, 'meth') then
        -- Bán ma túy: 1 sao, lẩn trốn 2 phút
        stars = 1
        timerType = 'evasion'
        duration = 120
    elseif string.find(lowerText, 'vàng') or string.find(lowerText, 'jewel') then
        -- Tiệm vàng: 3 sao, lẩn trốn 3 phút
        stars = 3
        timerType = 'evasion'
        duration = 180
    elseif string.find(lowerText, 'nhà') or string.find(lowerText, 'house') then
        -- Trộm nhà: 3 sao, lẩn trốn 3 phút
        stars = 3
        timerType = 'evasion'
        duration = 180
    else
        -- Các tội khác (như bắn cảnh sát, v.v) tra cứu trong bảng
        for key, val in pairs(crimeToStars) do
            if string.find(lowerText, string.lower(key)) then
                stars = val
                break
            end
        end
        if stars == 0 then 
            stars = 1 
            timerType = 'evasion'
            duration = 120
        else
            timerType = 'evasion'
            duration = 180
        end
    end

    TriggerClientEvent('qbx_npccops:client:setWanted', src, stars, timerType, duration)
end)

RegisterNetEvent('qbx_npccops:server:executePenalty', function(playerSource)
    local src = playerSource or source
    if type(src) == 'table' then src = src.source end -- Just in case called weirdly
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    -- Xóa đồ phạm pháp/vũ khí, giữ lại tiền mặt và giấy tờ
    exports.ox_inventory:ClearInventory(src, {'money', 'phone', 'id_card', 'driver_license'})
    
    -- Cho 1 chai nước, 1 bánh burger
    exports.ox_inventory:AddItem(src, 'water', 1)
    exports.ox_inventory:AddItem(src, 'burger', 1)

    -- Phạt 500$ (Kiểm tra ngân hàng -> tiền mặt -> ghi nợ)
    local fineAmount = 200
    local bankBalance = player.PlayerData.money['bank'] or 0
    local cashBalance = player.PlayerData.money['cash'] or 0

    if bankBalance >= fineAmount then
        player.Functions.RemoveMoney('bank', fineAmount, 'police-penalty')
    elseif cashBalance >= fineAmount then
        player.Functions.RemoveMoney('cash', fineAmount, 'police-penalty')
    else
        -- Cả 2 không đủ thì ghi nợ vào ngân hàng (trừ thẳng sẽ làm số dư âm)
        player.Functions.RemoveMoney('bank', fineAmount, 'police-penalty')
    end

    -- Gọi client xóa sao và tele
    TriggerClientEvent('qbx_npccops:client:penaltyTeleport', src)

    exports.qbx_core:Notify(src, 'Bạn đã bị cảnh sát tiêu diệt và bị tịch thu tài sản, phạt $200!', 'error', 10000)
end)

RegisterNetEvent('qbx_npccops:server:executePenaltyBusted', function()
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    -- Xóa đồ phạm pháp/vũ khí, giữ lại tiền mặt và giấy tờ
    exports.ox_inventory:ClearInventory(src, {'money', 'phone', 'id_card', 'driver_license'})
    
    -- Cho 1 chai nước, 1 bánh burger
    exports.ox_inventory:AddItem(src, 'water', 1)
    exports.ox_inventory:AddItem(src, 'burger', 1)

    -- Phạt 500$ (Kiểm tra ngân hàng -> tiền mặt -> ghi nợ)
    local fineAmount = 200
    local bankBalance = player.PlayerData.money['bank'] or 0
    local cashBalance = player.PlayerData.money['cash'] or 0

    if bankBalance >= fineAmount then
        player.Functions.RemoveMoney('bank', fineAmount, 'police-penalty')
    elseif cashBalance >= fineAmount then
        player.Functions.RemoveMoney('cash', fineAmount, 'police-penalty')
    else
        -- Cả 2 không đủ thì ghi nợ vào ngân hàng (trừ thẳng sẽ làm số dư âm)
        player.Functions.RemoveMoney('bank', fineAmount, 'police-penalty')
    end

    -- Gọi client xóa sao và tele (để sửa lỗi native busted làm hỏng ped)
    TriggerClientEvent('qbx_npccops:client:penaltyTeleport', src)

    exports.qbx_core:Notify(src, 'Bạn đã bị cảnh sát bắt giữ, tịch thu tài sản và phạt $200!', 'error', 10000)
end)
