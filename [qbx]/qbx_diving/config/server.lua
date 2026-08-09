return {
    discordWebhook = nil, -- Replace nil with your webhook if you chose to use discord logging over ox_lib logging
    coralTypes = {
        {item = 'dendrogyra_coral', maxAmount = math.random(1, 5), price = math.random(100, 150)},
        {item = 'antipatharia_coral', maxAmount = math.random(2, 7), price = math.random(80, 120)},
    },
    priceModifiers = {
        {minAmount = 5,  maxAmount = 10, minPercentage = 100, maxPercentage = 110},
        {minAmount = 11, maxAmount = 15, minPercentage = 110,  maxPercentage = 115},
        {minAmount = 16, minPercentage = 115, maxPercentage = 125},
    },
}