fx_version 'cerulean'
games { 'gta5' }

author 'Relmyab + '
description 'Drug Selling - Danish Version (Inspiration and code from fsg_selldrugs)'
version '1.0.0'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

server_scripts {
    'server/server.lua',
    'bridge/server.lua',
    'server/functions.lua',
}

client_scripts {
    'bridge/client.lua',
    'client/client.lua',
    'client/functions.lua',
}