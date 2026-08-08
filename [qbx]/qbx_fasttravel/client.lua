local stations = Config.Stations

-- Function declarations
local OpenBusMenu
local TravelTo

-- Menu Logic
OpenBusMenu = function(currentStationId)
    local options = {}

    -- Sắp xếp danh sách trạm theo tên (Alphabetical Sort)
    local sortedIds = {}
    for id in pairs(stations) do table.insert(sortedIds, id) end
    table.sort(sortedIds, function(a, b) return stations[a].label < stations[b].label end)

    for _, id in ipairs(sortedIds) do
        local data = stations[id]
        
        if id == currentStationId then
            -- Điểm hiện tại: Không cho chọn, làm nổi bật bằng màu đỏ
            table.insert(options, {
                title = data.label .. ' (Vị trí hiện tại)',
                description = 'Bạn đang đứng ở trạm này',
                icon = 'location-crosshairs',
                iconColor = '#f03e3e', -- Màu đỏ nổi bật
                disabled = true
            })
        else
            -- Các điểm đến khác: Hiển thị bình thường
            table.insert(options, {
                title = data.label,
                description = 'Di chuyển đến ' .. data.label .. ' với giá $' .. Config.TicketPrice,
                icon = 'location-dot',
                iconColor = '#74c0fc', -- Màu xanh biển mượt mà
                onSelect = function()
                    TravelTo(id)
                end
            })
        end
    end

    lib.registerContext({
        id = 'bus_travel_menu',
        title = 'Trạm Xe Buýt',
        options = options
    })

    lib.showContext('bus_travel_menu')
end

-- Travel Logic
TravelTo = function(destinationId)
    local dest = stations[destinationId]
    if not dest then return end

    -- Attempt Payment
    local success = lib.callback.await('qbx_fasttravel:server:PayTicket', false)
    
    if success then
        local ped = PlayerPedId()
        DoScreenFadeOut(1000)
        Wait(1500)
        SetEntityCoords(ped, dest.coords.x, dest.coords.y, dest.coords.z)
        SetEntityHeading(ped, dest.heading)
        Wait(1000)
        DoScreenFadeIn(1000)
        exports.qbx_core:Notify('Thành Công', 'success', 5000, 'Bạn đã đến ' .. dest.label)
    else
        exports.qbx_core:Notify('Thất Bại', 'error', 5000, 'Bạn không đủ $' .. Config.TicketPrice .. ' (Tiền mặt hoặc Ngân hàng) để mua vé xe buýt!')
    end
end

-- Create Blips and Target Zones
CreateThread(function()
    for id, data in pairs(stations) do
        -- Create Blip
        if data.blip then
            local blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
            SetBlipSprite(blip, data.blip.id)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, data.blip.scale)
            SetBlipColour(blip, data.blip.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(data.label)
            EndTextCommandSetBlipName(blip)
        end

        -- Create Target Zone
        exports.ox_target:addBoxZone({
            coords = data.coords,
            size = data.size,
            rotation = data.heading,
            debug = false,
            options = {
                {
                    name = 'bus_station_' .. id,
                    icon = 'fas fa-bus',
                    label = 'Xem Lịch Trình Xe Buýt ($' .. Config.TicketPrice .. ')',
                    onSelect = function()
                        OpenBusMenu(id)
                    end
                }
            }
        })
    end
end)

-- Draw Markers
CreateThread(function()
    while true do
        local sleep = 1500
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        for id, data in pairs(stations) do
            local dist = #(pos - data.coords)
            if dist < 10.0 then
                sleep = 0
                -- Vẽ vòng sáng dưới đất
                DrawMarker(27, data.coords.x, data.coords.y, data.coords.z - 0.95, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.0, 0, 150, 255, 100, false, false, 2, false, nil, nil, false)
                
                -- Tính toán độ cao mũi tên (MRPD giữ nguyên, các trạm khác cao hơn)
                local arrowZ = data.coords.z + 1.2
                if id == 'mrpd' then
                    arrowZ = data.coords.z + 0.5
                end

                -- Vẽ mũi tên trỏ xuống nảy lên xuống (bouncing) ở trên cao
                DrawMarker(2, data.coords.x, data.coords.y, arrowZ, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.4, 0.4, 0.4, 255, 215, 0, 180, true, true, 2, false, nil, nil, false)
            end
        end
        Wait(sleep)
    end
end)

