lib.callback.register('qbx_fasttravel:server:PayTicket', function(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return false end

    local cost = Config.TicketPrice

    -- Check cash first
    if player.Functions.RemoveMoney('cash', cost, "bus-ticket") then
        return true
    end

    -- Check bank second
    if player.Functions.RemoveMoney('bank', cost, "bus-ticket") then
        return true
    end

    -- If neither has enough
    return false
end)
