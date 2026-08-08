local isWanted = false
local wantedTimer = 0
local wantedTimerType = 'evasion'
local wantedDefaultTimer = 120
local currentStars = 0
local lastKnownCoords = nil

local function IsPlayerVisibleToCops(playerPed)
    local peds = GetGamePool('CPed')
    local playerCoords = GetEntityCoords(playerPed)
    
    for i = 1, #peds do
        local ped = peds[i]
        if ped ~= playerPed and not IsEntityDead(ped) then
            local pedType = GetPedType(ped)
            -- 6: Cảnh sát, 27: SWAT, 29: Quân đội
            if pedType == 6 or pedType == 27 or pedType == 29 then 
                local dist = #(playerCoords - GetEntityCoords(ped))
                if dist < 80.0 then -- Khoảng cách tầm nhìn 80 mét
                    -- 17: Cờ trace kiểm tra vật thể và công trình
                    if HasEntityClearLosToEntity(ped, playerPed, 17) then
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function DrawText2D(text, x, y)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextScale(0.5, 0.5)
    SetTextColour(255, 50, 50, 255)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

CreateThread(function()
    while true do
        Wait(1000)
        local playerId = PlayerId()
        local currentWantedLevel = GetPlayerWantedLevel(playerId)

        if currentWantedLevel > 0 then
            if not isWanted then
                -- Vừa mới bị truy nã
                isWanted = true
                if wantedTimer <= 0 then
                    wantedTimer = wantedDefaultTimer
                end
                currentStars = currentWantedLevel
                lastKnownCoords = GetEntityCoords(PlayerPedId())
                LocalPlayer.state:set('isWantedByNPC', true, true)
            end
            
            -- Ép cops spawn và đuổi theo vị trí hiện tại liên tục
            SetDispatchCopsForPlayer(playerId, true)
            EnableDispatchService(1, true)
            EnableDispatchService(2, true)
            EnableDispatchService(4, true)
            EnableDispatchService(6, true)
        end

        if isWanted then
            if currentWantedLevel == 0 and wantedTimer > 0 then
                SetPlayerWantedLevel(playerId, currentStars, false)
                SetPlayerWantedLevelNow(playerId, false)
                if lastKnownCoords then
                    SetPlayerWantedCentrePosition(playerId, lastKnownCoords.x, lastKnownCoords.y, lastKnownCoords.z)
                end
            end

            if IsPedBeingArrested(PlayerPedId()) then
                -- Nếu bị bắt sống
                ClearPlayerWantedLevel(playerId)
                SetPoliceRadarBlips(false)
                isWanted = false
                LocalPlayer.state:set('isWantedByNPC', false, true)
                TriggerServerEvent('qbx_npccops:server:executePenaltyBusted')
            elseif LocalPlayer.state.isDead or IsEntityDead(PlayerPedId()) then
                -- Nếu bị chết (thêm check từ state để tương thích chuẩn Qbox)
                ClearPlayerWantedLevel(playerId)
                SetPoliceRadarBlips(false)
                isWanted = false
                LocalPlayer.state:set('isWantedByNPC', false, true)
                TriggerServerEvent('qbx_npccops:server:executePenalty')
            else
                local ped = PlayerPedId()
                
                if wantedTimerType == 'survival' then
                    -- Kiểu sinh tồn (ví dụ: cướp ngân hàng) - Không reset thời gian khi bị nhìn thấy
                    if wantedTimer > 0 then
                        wantedTimer = wantedTimer - 1
                    else
                        ClearPlayerWantedLevel(playerId)
                        SetPoliceRadarBlips(false)
                        isWanted = false
                        LocalPlayer.state:set('isWantedByNPC', false, true)
                        lib.notify({
                            title = 'Sống sót thành công',
                            description = 'Bạn đã sống sót qua đợt truy nã gắt gao!',
                            type = 'success'
                        })
                        
                        CreateThread(function()
                            SetPoliceIgnorePlayer(playerId, true)
                            Wait(5000)
                            SetPoliceIgnorePlayer(playerId, false)
                        end)
                    end
                    
                    -- Vẫn cập nhật tâm tìm kiếm để cảnh sát bám theo nếu nhìn thấy
                    if IsPlayerVisibleToCops(ped) then
                        local coords = GetEntityCoords(ped)
                        lastKnownCoords = coords
                        SetPlayerWantedCentrePosition(playerId, coords.x, coords.y, coords.z)
                    end
                else
                    -- Kiểu lẩn trốn (trộm xe, ma túy, v.v)
                    if IsPlayerVisibleToCops(ped) then
                        wantedTimer = wantedDefaultTimer -- Reset lại thời gian lẩn trốn
                        local coords = GetEntityCoords(ped)
                        lastKnownCoords = coords
                        -- Báo vị trí cho cảnh sát
                        SetPlayerWantedCentrePosition(playerId, coords.x, coords.y, coords.z)
                    else
                        -- Đang lẩn trốn thành công (khuất tầm nhìn)
                        if wantedTimer > 0 then
                            wantedTimer = wantedTimer - 1
                        else
                            -- Đã hết thời gian lẩn trốn
                            ClearPlayerWantedLevel(playerId)
                            SetPoliceRadarBlips(false)
                            isWanted = false
                            LocalPlayer.state:set('isWantedByNPC', false, true)
                            lib.notify({
                                title = 'Thoát khỏi truy nã',
                                description = 'Bạn đã cắt đuôi được cảnh sát!',
                                type = 'success'
                            })
                            
                            -- Ngăn chặn cảnh sát xung quanh lập tức gán lại sao (bằng cách phớt lờ người chơi trong 5s)
                            CreateThread(function()
                                SetPoliceIgnorePlayer(playerId, true)
                                Wait(5000)
                                SetPoliceIgnorePlayer(playerId, false)
                            end)
                        end
                    end
                end
            end
        else
            -- Đảm bảo an toàn nếu mất sao bằng cách nào đó khác
            if currentWantedLevel == 0 and LocalPlayer.state.isWantedByNPC then
                if not IsEntityDead(PlayerPedId()) then
                    SetPoliceRadarBlips(false)
                    isWanted = false
                    LocalPlayer.state:set('isWantedByNPC', false, true)
                end
            end
        end
    end
end)

-- Vòng lặp vẽ UI (chạy mỗi frame)
CreateThread(function()
    while true do
        Wait(0)
        if isWanted and wantedTimer > 0 then
            DrawText2D('~r~THOI GIAN TRUY NA: ~w~' .. wantedTimer .. 's', 0.05, 0.3)
        end
    end
end)

-- Removed CEventNetworkEntityDamage check as penalty is handled in respawn

RegisterNetEvent('qbx_npccops:client:setWanted', function(stars, timerType, duration)
    local playerId = PlayerId()
    local current = GetPlayerWantedLevel(playerId)
    
    if stars >= current then
        currentStars = stars
        SetPlayerWantedLevel(playerId, stars, false)
        SetPlayerWantedLevelNow(playerId, false)
        SetDispatchCopsForPlayer(playerId, true)
        SetPoliceIgnorePlayer(playerId, false)
        
        wantedTimerType = timerType or 'evasion'
        wantedDefaultTimer = duration or 120
        wantedTimer = wantedDefaultTimer

        
        -- Kích hoạt AI cảnh sát đuổi theo vị trí hiện tại
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        ReportCrime(playerId, 37, stars)
        SetPoliceRadarBlips(true)
    end
end)

RegisterNetEvent('qbx_npccops:client:penaltyTeleport', function()
    local ped = PlayerPedId()
    DoScreenFadeOut(500)
    Wait(1000)
    -- Xóa sao an toàn
    ClearPlayerWantedLevel(PlayerId())
    isWanted = false
    LocalPlayer.state:set('isWantedByNPC', false, true)
    
    -- Nếu đang chết thì hồi sinh (dùng qbx_medical) TRƯỚC KHI teleport để tránh lỗi mất skin/kẹt animation
    if IsEntityDead(ped) or LocalPlayer.state.isDead then
        TriggerEvent('qbx_medical:client:playerRevived')
        Wait(500)
    end
    
    -- Phục hồi lại skin/quần áo nếu bị game gốc làm lỗi thành ped trọc đầu
    TriggerEvent('illenium-appearance:client:reloadSkin', true)
    Wait(500)
    
    -- Lấy lại ped sau khi revive (phòng hờ ped bị đổi)
    ped = PlayerPedId()
    
    -- Teleport ra trước đồn Mission Row
    SetEntityCoords(ped, 428.23, -984.28, 30.71, false, false, false, false)
    SetEntityHeading(ped, 90.0)
    
    Wait(1000)
    DoScreenFadeIn(500)
end)
