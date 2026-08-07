local config = lib.load('qbx_disableservices.config')

CreateThread(function()
    while true do
        SetMaxWantedLevel(config.maxWantedLevel)
        for key, value in ipairs(config.enabledServices) do
            EnableDispatchService(key, value)
        end
        Wait(5000)
    end
end)