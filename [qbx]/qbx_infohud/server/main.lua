lib.callback.register('qbx_infohud:server:getOnlinePlayers', function(source)
    -- Lấy tổng số lượng người chơi đang online trên máy chủ
    return GetNumPlayerIndices()
end)
