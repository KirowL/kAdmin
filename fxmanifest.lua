fx_version 'bodacious'

game 'gta5'

author 'Kirow'

description 'Menu admin par Kirow pour Aldalys'

client_scripts {
    "src/RMenu.lua",
    "src/menu/RageUI.lua",
    "src/menu/Menu.lua",
    "src/menu/MenuController.lua",
    "src/components/*.lua",
    "src/menu/elements/*.lua",
    "src/menu/items/*.lua",
    "src/menu/panels/*.lua",
    "src/menu/windows/*.lua",
    
    "client/menu.lua",
    "client/functions.lua",

}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/main.lua',
}

