return {
    ['testburger'] = {
        label = 'Burger Thử Nghiệm',
        weight = 220,
        degrade = 60,
        client = {
            image = 'burger_chicken.png',
            status = { hunger = 200000 },
            anim = 'eating',
            prop = 'burger',
            usetime = 2500,
            export = 'ox_inventory_examples.testburger'
        },
        server = {
            export = 'ox_inventory_examples.testburger',
            test = 'what an amazingly delicious burger, amirite?'
        },
        buttons = {
            {
                label = 'Liếm thử',
                action = function(slot)
                    print('You licked the burger')
                end
            },
            {
                label = 'Bóp thử',
                action = function(slot)
                    print('You squeezed the burger :(')
                end
            },
            {
                label = 'What do you call a vegan burger?',
                group = 'Hamburger Puns',
                action = function(slot)
                    print('A misteak.')
                end
            },
            {
                label = 'What do frogs like to eat with their hamburgers?',
                group = 'Hamburger Puns',
                action = function(slot)
                    print('French flies.')
                end
            },
            {
                label = 'Why were the burger and fries running?',
                group = 'Hamburger Puns',
                action = function(slot)
                    print('Because they\'re fast food.')
                end
            }
        },
        consume = 0.3
    },

    ['bandage'] = {
        label = 'Băng gạc',
        weight = 115,
    },

    ['burger'] = {
        label = 'Bánh Mì Kẹp',
        weight = 220,
        client = {
            status = { hunger = 200000 },
            anim = 'eating',
            prop = 'burger',
            usetime = 2500,
            notification = 'You ate a delicious burger'
        },
    },

    ['sprunk'] = {
        label = 'Nước Sprunk',
        weight = 350,
        client = {
            status = { thirst = 200000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_ld_can_01`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
            usetime = 2500,
            notification = 'You quenched your thirst with a sprunk'
        }
    },

    ['parachute'] = {
        label = 'Dù',
        weight = 8000,
        stack = false,
        client = {
            anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
            usetime = 1500
        }
    },

    ['garbage'] = {
        label = 'Rác',
    },

    ['paperbag'] = {
        label = 'Túi giấy',
        weight = 1,
        stack = false,
        close = false,
        consume = 0
    },

    ['panties'] = {
        label = 'Quần lót',
        weight = 10,
        consume = 0,
        client = {
            status = { thirst = -100000, stress = -25000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_cs_panties_02`, pos = vec3(0.03, 0.0, 0.02), rot = vec3(0.0, -13.5, -1.5) },
            usetime = 2500,
        }
    },

    ['lockpick'] = {
        label = 'Dụng cụ phá khóa',
        weight = 160,
    },

    ['phone'] = {
        label = 'Điện thoại',
        weight = 190,
        stack = false,
        consume = 0,
        client = {
            add = function(total)
                if total > 0 then
                    pcall(function() return exports.npwd:setPhoneDisabled(false) end)
                end
            end,

            remove = function(total)
                if total < 1 then
                    pcall(function() return exports.npwd:setPhoneDisabled(true) end)
                end
            end
        }
    },

    ['mustard'] = {
        label = 'Mù tạt',
        weight = 500,
        client = {
            status = { hunger = 25000, thirst = 25000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_food_mustard`, pos = vec3(0.01, 0.0, -0.07), rot = vec3(1.0, 1.0, -1.5) },
            usetime = 2500,
            notification = 'You... drank mustard'
        }
    },

    ['water'] = {
        label = 'Nước lọc',
        weight = 500,
        client = {
            status = { thirst = 200000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_ld_flow_bottle`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5) },
            usetime = 2500,
            cancel = true,
            notification = 'You drank some refreshing water'
        }
    },

    ['armour'] = {
        label = 'Áo chống đạn',
        weight = 3000,
        stack = false,
        client = {
            anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
            usetime = 3500
        }
    },

    ['clothing'] = {
        label = 'Quần áo',
        consume = 0,
    },

    ['money'] = {
        label = 'Tiền mặt',
    },

    ['black_money'] = {
        label = 'Tiền bẩn',
    },

    ['id_card'] = {
        label = 'Chứng minh nhân dân',
    },

    ['driver_license'] = {
        label = 'Bằng lái xe',
    },

    ['weaponlicense'] = {
        label = 'Giấy phép sử dụng vũ khí',
    },

    ['lawyerpass'] = {
        label = 'Thẻ luật sư',
    },

    ['radio'] = {
        label = 'Bộ đàm',
        weight = 1000,
        allowArmed = true,
        consume = 0,
        client = {
            event = 'mm_radio:client:use'
        }
    },

    ['jammer'] = {
        label = 'Máy phá sóng',
        weight = 10000,
        allowArmed = true,
        client = {
            event = 'mm_radio:client:usejammer'
        }
    },

    ['radiocell'] = {
        label = 'Pin AAA',
        weight = 1000,
        stack = true,
        allowArmed = true,
        client = {
            event = 'mm_radio:client:recharge'
        }
    },

    ['advancedlockpick'] = {
        label = 'Dụng cụ phá khóa cao cấp',
        weight = 500,
    },

    ['screwdriverset'] = {
        label = 'Bộ tua vít',
        weight = 500,
    },

    ['electronickit'] = {
        label = 'Bộ linh kiện điện tử',
        weight = 500,
    },

    ['cleaningkit'] = {
        label = 'Bộ vệ sinh vũ khí',
        weight = 500,
    },

    ['repairkit'] = {
        label = 'Bộ sửa chữa',
        weight = 2500,
    },

    ['advancedrepairkit'] = {
        label = 'Bộ sửa chữa cao cấp',
        weight = 4000,
    },

    ['diamond_ring'] = {
        label = 'Kim cương',
        weight = 1500,
    },

    ['rolex'] = {
        label = 'Đồng hồ vàng',
        weight = 1500,
    },

    ['goldbar'] = {
        label = 'Thỏi vàng',
        weight = 1500,
    },

    ['goldchain'] = {
        label = 'Dây chuyền vàng',
        weight = 1500,
    },

    ['crack_baggy'] = {
        label = 'Túi Crack',
        weight = 100,
    },

    ['cokebaggy'] = {
        label = 'Túi Cocaine',
        weight = 100,
    },

    ['coke_brick'] = {
        label = 'Bánh Cocaine',
        weight = 2000,
    },

    ['coke_small_brick'] = {
        label = 'Gói Cocaine',
        weight = 1000,
    },

    ['xtcbaggy'] = {
        label = 'Túi thuốc lắc',
        weight = 100,
    },

    ['meth'] = {
        label = 'Ma túy đá (Meth)',
        weight = 100,
    },

    ['oxy'] = {
        label = 'Thuốc Oxycodone',
        weight = 100,
    },

    ['weed_ak47'] = {
        label = 'Cỏ AK47 2g',
        weight = 200,
    },

    ['weed_ak47_seed'] = {
        label = 'Hạt giống cỏ AK47',
        weight = 1,
    },

    ['weed_skunk'] = {
        label = 'Cỏ Skunk 2g',
        weight = 200,
    },

    ['weed_skunk_seed'] = {
        label = 'Hạt giống cỏ Skunk',
        weight = 1,
    },

    ['weed_amnesia'] = {
        label = 'Cỏ Amnesia 2g',
        weight = 200,
    },

    ['weed_amnesia_seed'] = {
        label = 'Hạt giống cỏ Amnesia',
        weight = 1,
    },

    ['weed_og-kush'] = {
        label = 'Cỏ OG Kush 2g',
        weight = 200,
    },

    ['weed_og-kush_seed'] = {
        label = 'Hạt giống cỏ OG Kush',
        weight = 1,
    },

    ['weed_white-widow'] = {
        label = 'Cỏ OG Kush 2g',
        weight = 200,
    },

    ['weed_white-widow_seed'] = {
        label = 'Hạt giống White Widow',
        weight = 1,
    },

    ['weed_purple-haze'] = {
        label = 'Cỏ Purple Haze 2g',
        weight = 200,
    },

    ['weed_purple-haze_seed'] = {
        label = 'Hạt giống Purple Haze',
        weight = 1,
    },

    ['weed_brick'] = {
        label = 'Bánh cỏ',
        weight = 2000,
    },

    ['weed_nutrition'] = {
        label = 'Phân bón cây',
        weight = 2000,
    },

    ['joint'] = {
        label = 'Điếu cỏ',
        weight = 200,
    },

    ['rolling_paper'] = {
        label = 'Giấy cuốn',
        weight = 0,
    },

    ['empty_weed_bag'] = {
        label = 'Túi đựng cỏ trống',
        weight = 0,
    },

    ['firstaid'] = {
        label = 'Hộp sơ cứu',
        weight = 2500,
    },

    ['ifaks'] = {
        label = 'Túi sơ cứu cá nhân',
        weight = 2500,
    },

    ['painkillers'] = {
        label = 'Thuốc giảm đau',
        weight = 400,
    },

    ['firework1'] = {
        label = 'Rượu 2Brothers',
        weight = 1000,
    },

    ['firework2'] = {
        label = 'Thuốc Poppelers',
        weight = 1000,
    },

    ['firework3'] = {
        label = 'Thuốc WipeOut',
        weight = 1000,
    },

    ['firework4'] = {
        label = 'Thuốc Weeping Willow',
        weight = 1000,
    },

    ['steel'] = {
        label = 'Thép',
        weight = 100,
    },

    ['rubber'] = {
        label = 'Cao su',
        weight = 100,
    },

    ['metalscrap'] = {
        label = 'Phế liệu kim loại',
        weight = 100,
    },

    ['iron'] = {
        label = 'Sắt',
        weight = 100,
    },

    ['copper'] = {
        label = 'Đồng',
        weight = 100,
    },

    ['aluminum'] = {
        label = 'Nhôm',
        weight = 100,
    },

    ['plastic'] = {
        label = 'Nhựa',
        weight = 100,
    },

    ['glass'] = {
        label = 'Thủy tinh',
        weight = 100,
    },

    ['gatecrack'] = {
        label = 'Dụng cụ phá cổng',
        weight = 1000,
    },

    ['cryptostick'] = {
        label = 'USB Crypto',
        weight = 100,
    },

    ['trojan_usb'] = {
        label = 'USB Trojan',
        weight = 100,
    },

    ['toaster'] = {
        label = 'Máy nướng bánh mì',
        weight = 5000,
    },

    ['small_tv'] = {
        label = 'Tivi nhỏ',
        weight = 100,
    },

    ['security_card_01'] = {
        label = 'Thẻ an ninh A',
        weight = 100,
    },

    ['security_card_02'] = {
        label = 'Thẻ an ninh B',
        weight = 100,
    },

    ['drill'] = {
        label = 'Máy khoan',
        weight = 5000,
    },

    ['thermite'] = {
        label = 'Thuốc nổ Thermite',
        weight = 1000,
    },

    ['diving_gear'] = {
        label = 'Đồ lặn',
        weight = 30000,
    },

    ['diving_fill'] = {
        label = 'Bình lặn',
        weight = 3000,
    },

    ['antipatharia_coral'] = {
        label = 'San hô đen',
        weight = 1000,
    },

    ['dendrogyra_coral'] = {
        label = 'San hô Dendrogyra',
        weight = 1000,
    },

    ['jerry_can'] = {
        label = 'Can xăng',
        weight = 3000,
    },

    ['nitrous'] = {
        label = 'Bình Nitrous (NOS)',
        weight = 1000,
    },

    ['wine'] = {
        label = 'Rượu vang',
        weight = 500,
    },

    ['grape'] = {
        label = 'Nho',
        weight = 10,
    },

    ['grapejuice'] = {
        label = 'Nước ép nho',
        weight = 200,
    },

    ['coffee'] = {
        label = 'Cà phê',
        weight = 200,
    },

    ['vodka'] = {
        label = 'Rượu Vodka',
        weight = 500,
    },

    ['whiskey'] = {
        label = 'Rượu Whiskey',
        weight = 200,
    },

    ['beer'] = {
        label = 'Bia',
        weight = 200,
    },

    ['sandwich'] = {
        label = 'Bánh mì Sandwich',
        weight = 200,
    },

    ['walking_stick'] = {
        label = 'Gậy đi bộ',
        weight = 1000,
    },

    ['lighter'] = {
        label = 'Bật lửa',
        weight = 200,
    },

    ['binoculars'] = {
        label = 'Ống nhòm',
        weight = 800,
    },

    ['stickynote'] = {
        label = 'Giấy nhớ',
        weight = 0,
    },

    ['empty_evidence_bag'] = {
        label = 'Túi bằng chứng trống',
        weight = 200,
    },

    ['filled_evidence_bag'] = {
        label = 'Túi bằng chứng',
        weight = 200,
    },

    ['harness'] = {
        label = 'Dây an toàn',
        weight = 200,
    },

    ['handcuffs'] = {
        label = 'Còng số 8',
        weight = 200,
    },
}
