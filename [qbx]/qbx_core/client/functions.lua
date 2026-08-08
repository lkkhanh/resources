local positionConfig = require 'config.shared'.notifyPosition

---Text box popup for player which dissappears after a set time.
---@param text table|string text of the notification
---@param notifyType? NotificationType informs default styling. Defaults to 'inform'
---@param duration? integer milliseconds notification will remain on screen. Defaults to 5000
---@param subTitle? string extra text under the title
---@param notifyPosition? NotificationPosition
---@param notifyStyle? table Custom styling. Please refer too https://coxdocs.dev/ox_lib/Modules/Interface/Client/notify#libnotify
---@param notifyIcon? string Font Awesome 6 icon name
---@param notifyIconColor? string Custom color for the icon chosen before
function Notify(text, notifyType, duration, subTitle, notifyPosition, notifyStyle, notifyIcon, notifyIconColor)
    local title, description
    if type(text) == 'table' then
        title = text.text or 'Placeholder'
        description = text.caption or nil
    elseif subTitle then
        title = text
        description = subTitle
    else
        description = text
    end
    local position = notifyPosition or positionConfig

    lib.notify({
        id = 'qbx_global_notify',
        title = title,
        description = description,
        duration = duration,
        type = notifyType,
        position = position,
        style = notifyStyle or {
            background = 'linear-gradient(135deg, rgba(20, 90, 180, 0.25), rgba(20, 90, 180, 0.05))',
            border = '1px solid rgba(100, 200, 255, 0.25)',
            color = '#60a5fa', 
            borderRadius = '20px', -- Bo tròn viền
            zoom = '1.7', -- Nhỏ đi khoảng 1/3
            ['.title'] = {
                color = '#60a5fa',
                fontWeight = '900',
            },
            ['.description'] = {
                color = '#60a5fa',
                fontWeight = '900',
            }
        },
        icon = notifyIcon,
        iconColor = notifyIconColor
    })
end

exports('Notify', Notify)

---@return PlayerData? playerData
function GetPlayerData()
    return QBX.PlayerData
end

exports('GetPlayerData', GetPlayerData)

---@param filter string | string[] | table<string, number>
---@return boolean
function HasPrimaryGroup(filter)
    return HasPlayerGotGroup(filter, QBX.PlayerData, true)
end

exports('HasPrimaryGroup', HasPrimaryGroup)

---@param filter string | string[] | table<string, number>
---@return boolean
function HasGroup(filter)
    return HasPlayerGotGroup(filter, QBX.PlayerData)
end

exports('HasGroup', HasGroup)

---@return table<string, integer>
function GetGroups()
    local playerData = QBX.PlayerData
    return GetPlayerGroups(playerData)
end

exports('GetGroups', GetGroups)