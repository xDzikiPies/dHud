fx_version 'adamant'

game 'gta5'

lua54 'yes'

version '1.0.0'

author 'DzikiPies'

description 'Simple HUD for fivem rp server'

shared_scripts {
'@es_extended/imports.lua',
'@ox_lib/init.lua',
'config.lua'}

client_scripts {
    'client/*.lua'
}

server_scripts {
'@oxmysql/lib/MySQL.lua',
'server/*.lua',
}

ui_page 'web/index.html'

files {
    'web/assets/*.js',
    'web/assets/*.css',
    'web/index.html'
}