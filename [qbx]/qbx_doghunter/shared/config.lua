Config = {}

-- Items
Config.Items = {
    Rope = 'day_bat_cho',
    NormalPet = 'cho_meo_thuong'
}

-- Prices & Weight
Config.PricePerKg = 100 -- 100$ cho mỗi 1 kg
Config.WeightRange = { min = 5.0, max = 30.0 } -- Khoảng cân nặng ngẫu nhiên khi bắt thú
-- Spawn Settings
Config.SpawnRadius = 200.0
Config.MaxPetsAroundPlayer = 2 -- Tối đa 2 con xuất hiện cùng lúc để chống lag
Config.CooldownSpawn = 30000 -- 30 giây hồi để tìm điểm spawn mới
Config.BlipRadius = 2000.0 -- Bán kính radar dò tìm giả lập (để thỏa mãn yêu cầu 2km)

-- Models
Config.AnimalModels = {
    `a_c_pug`,
    `a_c_retriever`,
    `a_c_husky`,
    `a_c_cat_01`,
    `a_c_chop`
}

-- Selling Configuration
Config.DefaultSellPed = `a_m_m_tramp_01`
Config.DefaultSellBlip = {
    enable = true,
    sprite = 280,
    color = 1,
    scale = 0.8
}

-- Mảng tọa độ đã được lọc sạch (Loại bỏ các điểm gần Đồn Cảnh Sát, Bệnh Viện)
Config.SellLocations = {
    vector4(-73.56, 497.25, 143.37, 340.45),
    vector4(-743.9, 603.56, 141.0, 297.61),
    vector4(-904.76, -2056.84, 8.3, 139.38),
    vector4(432.92, -2029.0, 22.33, 325.88),
    vector4(856.08, -1643.19, 29.21, 81.96),
    vector4(-1136.17, -828.81, 14.25, 71.29),
    vector4(129.48, -45.66, 66.57, 297.99),
    vector4(-950.17, 578.62, 99.68, 38.68),
    vector4(-1325.15, 452.09, 98.83, 16.94),
    vector4(-1166.61, 269.07, 66.27, 186.69),
    vector4(-1957.12, 375.81, 92.33, 148.69),
    vector4(434.08, 302.3, 101.97, 71.39),
    vector4(1714.26, 3721.26, 33.02, 38.65),
    vector4(1862.06, 3885.62, 31.99, 58.3),
    vector4(-258.04, 6262.8, 30.42, 192.93),
    vector4(-2040.97, -435.64, 10.48, 31.52),
    vector4(896.17, -2092.16, 29.79, 11.21),
    vector4(1371.69, -2059.83, 51.0, 134.45),
    vector4(1318.19, -1614.49, 51.37, 53.48),
    vector4(1254.55, -533.94, 67.93, 245.74),
    vector4(459.94, -1671.73, 28.3, 86.53),
    vector4(182.81, -1934.7, 20.14, 231.57),
    vector4(-5.66, 177.1, 97.66, 231.57)
}

-- Penalty
Config.PenaltyFine = 100
Config.CatchLimitForWanted = 3 -- Bắt 3 con bị 1 sao
