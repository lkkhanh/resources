fx_version 'cerulean'
game 'gta5'

description 'Dog/Cat Hunter Job - Created by AI'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua',
    'shared/config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

ui_page 'html/index.html'
files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

lua54 'yes'
