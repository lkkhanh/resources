return {
    callCopsTimeout = 240000,

    registerReward = {
        min = 3000,          -- tiền mặt tối thiểu từ két thu ngân
        max = 6000,          -- tiền mặt tối đa từ két thu ngân
        chanceAtSticky = 30, -- 30% cơ hội nhận thêm sticky bomb
    },

    registerRefresh = {
        min = 90000,
        max = 420000,
    },

    safeReward = {
        markedBillsAmount = {
            min = 2,   -- số tờ tiền có dấu tối thiểu
            max = 5,   -- số tờ tiền có dấu tối đa
        },
        markedBillsWorth = {
            min = 3000,  -- giá trị mỗi tờ tiền tối thiểu
            max = 8000,  -- giá trị mỗi tờ tiền tối đa
        },
        chanceAtSpecial = 40,
        rolexAmount = {
            min = 2,
            max = 7,
        },
        goldbarAmount = 2,
    },

    safeRefresh = {
        min = 1200000,
        max = 2400000,
    },
}