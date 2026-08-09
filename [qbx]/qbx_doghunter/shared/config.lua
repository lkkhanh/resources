Config = {}

-- Items
Config.Items = {
    Rope = 'day_bat_cho',
    NormalPet = 'cho_meo_thuong',
    FatPet = 'cho_meo_beo'
}

-- Prices
Config.Prices = {
    NormalPet = 500,
    FatPet = 1000
}

Config.FatPetChance = 20 -- 20% chance to catch a fat pet

-- Spawn Settings
Config.SpawnRadius = 200.0
Config.MaxPetsAroundPlayer = 2 -- Tối đa 2 con xuất hiện cùng lúc để chống lag
Config.CooldownSpawn = 30000 -- 30 giây hồi để tìm điểm spawn mới
Config.BlipRadius = 1000.0 -- Bán kính radar dò tìm giả lập (để thỏa mãn yêu cầu 1km)

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
    vector4(-48.58, -790.12, 44.22, 340.5),
    vector4(826.0, -1885.26, 29.32, 81.5),
    vector4(350.84, -1974.13, 24.52, 318.5),
    vector4(-229.11, -2043.16, 27.75, 233.5),
    vector4(-1053.23, -2716.2, 13.75, 329.5),
    vector4(-774.04, -1277.25, 5.15, 171.5),
    vector4(-1184.3, -1304.16, 5.24, 293.5),
    vector4(-1613.99, -1015.82, 13.12, 342.5),
    vector4(-1392.74, -584.91, 30.24, 32.5),
    vector4(-515.19, -260.29, 35.53, 201.5),
    vector4(-760.84, -34.35, 37.83, 208.5),
    vector4(-1284.06, 297.52, 64.93, 148.5),
    vector4(-808.29, 828.88, 202.89, 200.5),
    vector4(-1074.39, -266.64, 37.75, 117.5),
    vector4(-1412.07, -591.75, 30.38, 298.5),
    vector4(-679.9, -845.01, 23.98, 269.5),
    vector4(-158.05, -1565.3, 35.06, 139.5),
    vector4(442.09, -1684.33, 29.25, 320.5),
    vector4(1120.73, -957.31, 47.43, 289.5),
    vector4(1238.85, -377.73, 69.03, 70.5),
    vector4(922.24, -2224.03, 30.39, 354.5),
    vector4(1662.55, 4876.71, 42.05, 185.5),
    vector4(-9.51, 6529.67, 31.37, 136.5),
    vector4(-3232.7, 1013.16, 12.09, 177.5),
    vector4(-1604.09, -401.66, 42.35, 321.5),
    vector4(-586.48, -255.96, 35.91, 210.5),
    vector4(23.66, -60.23, 63.62, 341.5),
    vector4(550.3, 172.55, 100.11, 339.5),
    vector4(-1048.55, -2540.58, 13.69, 148.5),
    vector4(-9.55, -544.0, 38.63, 87.5),
    vector4(-7.86, -258.22, 46.9, 68.5),
    vector4(-743.34, 817.81, 213.6, 219.5),
    vector4(218.34, 677.47, 189.26, 359.5),
    vector4(263.2, 1138.81, 221.75, 203.5)
}

-- Penalty
Config.PenaltyFine = 100
Config.CatchLimitForWanted = 3 -- Bắt 3 con bị 1 sao
