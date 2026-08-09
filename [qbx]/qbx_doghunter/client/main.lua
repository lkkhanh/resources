local spawnedPets = {}
local isMinigameActive = false
local currentTargetPet = nil
local consecutiveCatches = 0

-- Utils
local function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
    end
end

local function LoadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end
end

local function RemovePet(id)
    if spawnedPets[id] then
        if DoesEntityExist(spawnedPets[id].ped) then
            DeleteEntity(spawnedPets[id].ped)
        end
        if DoesBlipExist(spawnedPets[id].blip) then
            RemoveBlip(spawnedPets[id].blip)
        end
        spawnedPets[id] = nil
    end
end

local function IsPlayerCrouching(ped)
    -- 1. Check state bags from common crouch scripts
    if LocalPlayer.state.crouch or LocalPlayer.state.stance == 2 then return true end
    
    -- 2. Check native GTA stealth/ducking
    if GetPedStealthMovement(ped) == 1 or GetPedStealthMovement(ped) == true or IsPedDucking(ped) then return true end
    
    -- 3. Universal bone height check (foolproof)
    -- Standing height is ~1.65m - 1.8m, crouching is ~1.2m - 1.3m
    local headZ = GetPedBoneCoords(ped, 31086, 0.0, 0.0, 0.0).z
    local footZ = GetPedBoneCoords(ped, 14201, 0.0, 0.0, 0.0).z
    local height = headZ - footZ
    if height > 0.5 and height < 1.40 then
        return true
    end
    
    return false
end

-- Spawn Logic
CreateThread(function()
    while true do
        Wait(Config.CooldownSpawn)
        
        local ped = PlayerPedId()
        if IsPedOnAnyBike(ped) then
            local count = 0
            for _ in pairs(spawnedPets) do count = count + 1 end
            
            if count < Config.MaxPetsAroundPlayer then
                local coords = GetEntityCoords(ped)
                
                -- Random angle and distance (min 50m, max SpawnRadius)
                local angle = math.random() * math.pi * 2
                local dist = 50.0 + math.random() * (Config.SpawnRadius - 50.0)
                local randX = coords.x + math.cos(angle) * dist
                local randY = coords.y + math.sin(angle) * dist
                
                -- Yêu cầu game load vùng map đó trước khi tìm điểm an toàn
                RequestCollisionAtCoord(randX, randY, coords.z)
                Wait(250)
                
                local found, safeCoords = GetSafeCoordForPed(randX, randY, coords.z, false, 16)
                
                -- Nếu game tìm được điểm, PHẢI kiểm tra xem điểm đó có bị kéo ngược về người chơi không (lỗi chưa load map)
                if found and #(safeCoords - coords) > 40.0 then
                    local model = Config.AnimalModels[math.random(#Config.AnimalModels)]
                    LoadModel(model)
                    
                    local animal = CreatePed(28, model, safeCoords.x, safeCoords.y, safeCoords.z, 0.0, true, true)
                    SetEntityAsMissionEntity(animal, true, true)
                    TaskStandStill(animal, -1)
                    SetEntityInvincible(animal, true)
                    SetBlockingOfNonTemporaryEvents(animal, true)

                    local blip = AddBlipForEntity(animal)
                    SetBlipSprite(blip, 442)
                    SetBlipColour(blip, 5)
                    SetBlipScale(blip, 0.8)
                    SetBlipAsShortRange(blip, true)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString("Thú Hoang")
                    EndTextCommandSetBlipName(blip)

                    local petId = tostring(animal)
                    spawnedPets[petId] = {
                        ped = animal,
                        blip = blip,
                        coords = safeCoords
                    }
                    SetModelAsNoLongerNeeded(model)
                end
            end
        end
    end
end)

-- Interaction Logic
CreateThread(function()
    while true do
        local wait = 1000
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        
        if not isMinigameActive then
            for id, petData in pairs(spawnedPets) do
                if DoesEntityExist(petData.ped) then
                    local petCoords = GetEntityCoords(petData.ped)
                    local dist = #(coords - petCoords)
                    
                    if dist < 50.0 then
                        wait = 0
                        
                        if dist < 6.0 and not petData.fleeing then
                            -- Check stealth using our new foolproof function
                            local isStealth = IsPlayerCrouching(playerPed)
                            
                            -- Nếu đi thẳng (không lén lút) thì hoảng sợ (Bỏ check tốc độ vì nhả W bị giật lag speed)
                            if not isStealth then
                                petData.fleeing = true
                                exports.qbx_core:Notify("Con vật đã hoảng sợ và chạy mất!", "error")
                                
                                CreateThread(function()
                                    SetBlockingOfNonTemporaryEvents(petData.ped, false)
                                    ClearPedTasks(petData.ped)
                                    TaskSmartFleePed(petData.ped, playerPed, 100.0, -1, false, false)
                                    Wait(3000)
                                    RemovePet(id)
                                end)
                            else
                                -- Tăng khoảng cách hiện E lên 3.5 để dễ nhìn thấy khi bò
                                if dist < 3.5 and not Entity(petData.ped).state.isBeingCaught then
                                    DrawText3D(petCoords.x, petCoords.y, petCoords.z + 0.6, "[E] Bat thu")
                                     if IsControlJustPressed(0, 38) then -- E
                                        lib.callback('qbx_doghunter:server:canCatch', false, function(canCatch, msg)
                                            if canCatch then
                                                TriggerServerEvent('qbx_doghunter:server:setCaughtState', NetworkGetNetworkIdFromEntity(petData.ped), true)
                                                currentTargetPet = id
                                                isMinigameActive = true
                                                SetNuiFocus(true, true)
                                                SendNUIMessage({ action = "startMinigame" })
                                            else
                                                exports.qbx_core:Notify(msg or "Không thể bắt!", "error")
                                            end
                                        end, NetworkGetNetworkIdFromEntity(petData.ped))
                                    end
                                end
                            end
                        end
                    end
                    
                    -- Despawn if too far (>350m) to allow pets spawning at 200-280m to persist
                    if dist > 350.0 then
                        RemovePet(id)
                    end
                else
                    RemovePet(id)
                end
            end
        end
        Wait(wait)
    end
end)

-- Minigame Result Callback
RegisterNUICallback('minigameResult', function(data, cb)
    SetNuiFocus(false, false)
    isMinigameActive = false
    
    if data.success then
        consecutiveCatches = consecutiveCatches + 1
        TriggerServerEvent('qbx_doghunter:server:catchSuccess')
        RemovePet(currentTargetPet)
        
        -- Wanted Level Check
        if consecutiveCatches >= Config.CatchLimitForWanted then
            SetPlayerWantedLevel(PlayerId(), 1, false)
            SetPlayerWantedLevelNow(PlayerId(), false)
            exports.qbx_core:Notify("Cảnh sát đã phát hiện hành vi trộm chó của bạn!", "error")
            consecutiveCatches = 0 -- Reset after getting wanted
        end
    else
        consecutiveCatches = 0
        exports.qbx_core:Notify("Bắt thất bại, bạn bị chó cắn!", "error")
        -- Bleeding effect using qbx_medical (if available) or apply damage
        ApplyDamageToPed(PlayerPedId(), 20, false)
        
        -- Try to create bleeding
        pcall(function()
            exports.qbx_medical:CreateBleeding()
        end)
        
        -- Pet flees
        if currentTargetPet and spawnedPets[currentTargetPet] then
            local p = spawnedPets[currentTargetPet].ped
            TriggerServerEvent('qbx_doghunter:server:setCaughtState', NetworkGetNetworkIdFromEntity(p), false)
            ClearPedTasks(p)
            TaskSmartFleePed(p, PlayerPedId(), 100.0, -1, false, false)
            SetTimeout(2000, function() RemovePet(currentTargetPet) end)
        end
    end
    currentTargetPet = nil
    cb('ok')
end)

-- Anti NUI Stuck on Death
RegisterNetEvent('qbx_medical:client:playerDead', function()
    if isMinigameActive then
        SetNuiFocus(false, false)
        SendNUIMessage({ action = "closeMinigame" })
        isMinigameActive = false
        if currentTargetPet and spawnedPets[currentTargetPet] then
            local p = spawnedPets[currentTargetPet].ped
            TriggerServerEvent('qbx_doghunter:server:setCaughtState', NetworkGetNetworkIdFromEntity(p), false)
            currentTargetPet = nil
        end
    end
end)

-- Dynamic Sell Location Manager
local currentSellLoc = nil
local currentSellBlip = nil
local currentSellPed = nil

local function GenerateRandomSellLocation(playerCoords)
    local validLocations = {}
    
    -- Lọc ra các điểm có khoảng cách < 3000m
    for _, coords in ipairs(Config.SellLocations) do
        local dist = #(playerCoords - vector3(coords.x, coords.y, coords.z))
        if dist < 3000.0 then
            table.insert(validLocations, coords)
        end
    end
    
    local chosenCoords
    if #validLocations > 0 then
        chosenCoords = validLocations[math.random(#validLocations)]
    else
        -- Fallback: Nếu không có điểm nào < 3000m, bốc đại 1 điểm trong toàn bộ danh sách
        chosenCoords = Config.SellLocations[math.random(#Config.SellLocations)]
    end
    
    return {
        coords = chosenCoords,
        pedModel = Config.DefaultSellPed,
        blip = Config.DefaultSellBlip
    }
end

CreateThread(function()
    while true do
        Wait(2000)
        
        local normalCount = exports.ox_inventory:Search('count', Config.Items.NormalPet)
        local fatCount = exports.ox_inventory:Search('count', Config.Items.FatPet)
        local totalPets = normalCount + fatCount
        
        if totalPets > 0 then
            if not currentSellLoc then
                -- Pick COMPLETELY random dynamic location
                currentSellLoc = GenerateRandomSellLocation(GetEntityCoords(PlayerPedId()))
                
                -- Create Blip
                if currentSellLoc.blip and currentSellLoc.blip.enable then
                    currentSellBlip = AddBlipForCoord(currentSellLoc.coords.x, currentSellLoc.coords.y, currentSellLoc.coords.z)
                    SetBlipSprite(currentSellBlip, currentSellLoc.blip.sprite)
                    SetBlipColour(currentSellBlip, currentSellLoc.blip.color)
                    SetBlipScale(currentSellBlip, currentSellLoc.blip.scale)
                    SetBlipAsShortRange(currentSellBlip, true)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString("Diem Thu Mua Thu Cung")
                    EndTextCommandSetBlipName(currentSellBlip)
                    
                    -- Set GPS Route (Taxi style)
                    SetBlipRoute(currentSellBlip, true)
                    SetBlipRouteColour(currentSellBlip, currentSellLoc.blip.color)
                end
                
                exports.qbx_core:Notify("Bạn đã bắt được thú! Hãy đến Điểm Giao Thú trên bản đồ (theo định vị GPS) để bán.", "success", 7500)
            else
                -- Location is active, manage NPC streaming
                local playerCoords = GetEntityCoords(PlayerPedId())
                local dist = #(playerCoords - vector3(currentSellLoc.coords.x, currentSellLoc.coords.y, currentSellLoc.coords.z))
                
                if dist < 100.0 and not currentSellPed then
                    -- Spawn NPC
                    LoadModel(currentSellLoc.pedModel)
                    currentSellPed = CreatePed(0, currentSellLoc.pedModel, currentSellLoc.coords.x, currentSellLoc.coords.y, currentSellLoc.coords.z - 1.0, currentSellLoc.coords.w, false, false)
                    SetEntityInvincible(currentSellPed, true)
                    SetBlockingOfNonTemporaryEvents(currentSellPed, true)
                    FreezeEntityPosition(currentSellPed, true)
                    
                    -- Add Target to NPC
                    exports.ox_target:addLocalEntity(currentSellPed, {
                        {
                            name = 'sell_pets',
                            icon = 'fas fa-paw',
                            label = 'Ban thu cung',
                            onSelect = function()
                                TriggerServerEvent('qbx_doghunter:server:sellPets')
                            end
                        }
                    })
                elseif dist > 150.0 and currentSellPed then
                    -- Delete NPC
                    exports.ox_target:removeLocalEntity(currentSellPed, 'sell_pets')
                    DeleteEntity(currentSellPed)
                    currentSellPed = nil
                end
            end
        else
            -- No pets in inventory, clean up everything
            if currentSellLoc then
                if currentSellPed then
                    exports.ox_target:removeLocalEntity(currentSellPed, 'sell_pets')
                    DeleteEntity(currentSellPed)
                    currentSellPed = nil
                end
                if currentSellBlip then
                    RemoveBlip(currentSellBlip)
                    currentSellBlip = nil
                end
                currentSellLoc = nil
            end
        end
    end
end)
