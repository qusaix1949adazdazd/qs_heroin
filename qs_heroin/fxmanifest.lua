name "Qs Heroin "
author "QusaiX1949 "
description " Heroin Table by Qusai"
fx_version "cerulean"
game "gta5"
version  '3.5.6'
client_scripts {
	'client/**.lua',
}

server_scripts {
    'server/**.lua',
	
}

shared_scripts {
	'@ox_lib/init.lua',
	'shared/**.lua',

}

escrow_ignore {
    'shared/config.lua',
    'server/consumable.lua',
	'server/server.lua',
    'client/consumable.lua',


}

lua54 'yes'

dependencies {
    'ox_lib'
}