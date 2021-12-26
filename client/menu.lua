



-- Base ESX 
ESX = nil

local isMenuOpened = false

local showname = false
local noclip = false
local godmode = false
local blipsActive = false

local targetVehList = {}

local noClipInfos = {
    speed = 1.0,
    Items = {
        {Name = "x0.10", Value = 0.10},
        {Name = "x0.25", Value = 0.25},
        {Name = "x0.5", Value = 0.5},
        {Name = "x0.75", Value = 0.75},
        {Name = "x1", Value = 1.0},
        {Name = "x2", Value = 2.0},
        {Name = "x3", Value = 3.0},
        {Name = "x4", Value = 4.0},
        {Name = "x5", Value = 5.0},
        {Name = "x10", Value = 10.0},
        {Name = "x25", Value = 25.0},
    },
    index = 5
}

local items = {}
local weaponsItems = {}

Citizen.CreateThread(function()
	while ESX == nil do
	  TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
	  Citizen.Wait(1)
    end

    while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
    end

    ESX.PlayerData = ESX.GetPlayerData()
end)

-----------------------------------------------------------------------------


-- Création du menu
local adminMenu = RageUI.CreateMenu("Aldalys", "Menu administratif")
adminMenu.Closed = function()
    isMenuOpened = false
    RageUI.Visible(adminMenu, false)
end
adminMenu:SetRectangleBanner(0, 0, 0, 100)
adminMenu:DisplayGlare(false)
adminMenu:SetStyleSize(60)

local selfMenu = RageUI.CreateSubMenu(adminMenu, "Actions personnelles", "Menu d'actions sur soi-meme")
selfMenu:SetRectangleBanner(0, 0, 0, 100)
selfMenu:DisplayGlare(false)

local vehicleMenu = RageUI.CreateSubMenu(adminMenu, "Actions véhicules", "Menu d'actions vehicules")
vehicleMenu:SetRectangleBanner(0, 0, 0, 100)
vehicleMenu:DisplayGlare(false)

local playerListMenu = RageUI.CreateSubMenu(adminMenu, "Administration", "Liste des joueurs")
playerListMenu:SetRectangleBanner(0, 0, 0, 100)
playerListMenu:DisplayGlare(false)


local playerActionMenu = RageUI.CreateSubMenu(playerListMenu, "Administration", "Action sur le joueur")
playerActionMenu:SetRectangleBanner(0, 0, 0, 100)
playerActionMenu:DisplayGlare(false)

local playerInventoryMenu = RageUI.CreateSubMenu(playerActionMenu, "Administration", "Inventaire du joueur")
playerInventoryMenu:SetRectangleBanner(0, 0, 0, 100)
playerInventoryMenu:DisplayGlare(false)

local weaponMenu = RageUI.CreateSubMenu(selfMenu, "Administration", "Liste des armes")
weaponMenu:SetRectangleBanner(0, 0, 0, 100)
weaponMenu:DisplayGlare(false)

local jobsMenu = RageUI.CreateSubMenu(selfMenu, "Administration", "Liste des metiers")
jobsMenu:SetRectangleBanner(0, 0, 0, 100)
jobsMenu:DisplayGlare(false)

local jobs2Menu = RageUI.CreateSubMenu(selfMenu, "Administration", "Liste des metiers")
jobs2Menu:SetRectangleBanner(0, 0, 0, 100)
jobs2Menu:DisplayGlare(false)

local playerJobsMenu = RageUI.CreateSubMenu(playerActionMenu, "Administration", "Liste des metiers")
playerJobsMenu:SetRectangleBanner(0, 0, 0, 100)
playerJobsMenu:DisplayGlare(false)

local playerJobs2Menu = RageUI.CreateSubMenu(playerActionMenu, "Administration", "Liste des metiers")
playerJobs2Menu:SetRectangleBanner(0, 0, 0, 100)
playerJobs2Menu:DisplayGlare(false)

local bansMenu = RageUI.CreateSubMenu(adminMenu, "Administration", "Actions")
bansMenu:SetRectangleBanner(0, 0, 0, 100)
bansMenu:DisplayGlare(false)

local pedsMenu = RageUI.CreateSubMenu(selfMenu, "Administration", "Selectionnez un ped")
pedsMenu:SetRectangleBanner(0, 0, 0, 100)
pedsMenu:DisplayGlare(false)

local selectList = RageUI.CreateSubMenu(selfMenu, "Administration", "~r~Cochez les vehicules a supprimer")
selectList:SetRectangleBanner(0, 0, 0, 100)
selectList:DisplayGlare(false)


function OpenCloseMenu()
    if isMenuOpened then
        isMenuOpened = false
        RageUI.Visible(adminMenu, false)
    else
        isMenuOpened = true
        RageUI.Visible(adminMenu, true)
        local onlinePlayers = 0
        for i = 0, 255 do
            if NetworkIsPlayerActive(i) then
                onlinePlayers = onlinePlayers+1
            end
        end

        local basicWeaponsList= ESX.GetWeaponList()

        local jobsList = {}

        Citizen.CreateThread(function()
            while isMenuOpened do
                RageUI.IsVisible(adminMenu, function()
                    RageUI.Separator("                         ~r~↓ ~w~Informations serveur ~r~↓")
                    RageUI.Separator("                          Votre ID est le : ~r~" .. GetPlayerServerId(PlayerId()))
                    RageUI.Separator("                              Il y a actuellement ~r~" .. onlinePlayers .. " ~w~joueurs connectés.")

                    RageUI.Button("Actions sur soi", "Accèdez au menu des actions disponibles sur vous", {RightLabel = "→"}, true, {}, selfMenu) 
                    RageUI.Button("Actions véhicules", "Menu d'actions relatif aux véhicules", {RightLabel = "→"}, true, {}, vehicleMenu)
                    RageUI.Button("Liste des joueurs", "Afficher la liste des joueurs", {RightLabel = "→"}, true, {}, playerListMenu)

                end)

                RageUI.IsVisible(selfMenu, function()
                    RageUI.Checkbox("No-clip", "Activer ou désactiver le no-clip", noclip, {}, {
                        onChecked = function()
                            noclip = true
                            admin_no_clip()
                        end,

                        onUnChecked = function()
                            noclip = false
                            admin_no_clip()
                        end,
                    })
                    RageUI.List("Vitesse du no-clip", noClipInfos.Items, noClipInfos.index, "Modifier la vitesse du no-clip.", {}, true, {
                        onListChange = function(Index, Item)
                            noClipInfos.index = Index
                            noClipInfos.speed = Item.Value
                        end
                    })
                    RageUI.Checkbox("Mode invincible", "Activer ou désactiver le mode invincible", godmode, {}, {
                        onChecked = function()
                            godmode = true
                        end,

                        onUnChecked = function()
                            godmode = false
                        end,
                    })
                    RageUI.Checkbox("Mode invisible", "Activer ou désactiver le mode invisible", invisible, {}, {
                        onChecked = function()
                            AdminInvisibility()
                        end,

                        onUnChecked = function()
                            AdminInvisibility()
                        end,
                    })
                    RageUI.Checkbox('Nom des joueurs', "Afficher ou masquer les noms de joueurs", showname,  {}, {

                        onChecked = function()
                            showname = true
                            showNames(showname)
                            ESX.ShowNotification('~r~Administration                    ~w~Noms des joueurs affichés')
                        end,
                        onUnChecked = function()
                            showname = false
                            showNames(showname)
                            ESX.ShowNotification('~r~Administration                    ~w~Ouvrez puis fermez le menu pause pour désactiver les ID')
                        end,
                        onHovered = function()

                        end,
                    })
                    RageUI.Checkbox('Blips des joueurs', "Afficher ou masquer les blips de joueurs sur la carte", blipsActive,  {}, {

                        onChecked = function()
                            blipsActive = true
                            ESX.ShowNotification('~r~Administration                    ~w~Blips des joueurs affichés.')
                        end,
                        onUnChecked = function()
                            blipsActive = false
                            ESX.ShowNotification('~r~Administration                    ~w~Blips des joueurs masqués.')
                        end,
                    })
                    RageUI.Checkbox('Coordonnées', "Afficher ou masquer vos coordonnées", showcoord,  {}, {

                        onChecked = function()
                            showcoord = true
                            ESX.ShowNotification('~r~Administration                    ~w~Coordonnées affichées')
                        end,
                        onUnChecked = function()
                            showcoord = false
                            ESX.ShowNotification('~r~Administration                    ~w~Coordonnées masquées')
                        end,
                        onHovered = function()
        
                        end,
                    })
                    if playerGroup == 'superadmin' then
                        RageUI.Separator("                         ~r~↓ ~s~Give d'argent ~r~↓")
                        RageUI.Button("Argent ~g~liquide", "S'octroyer de l'argent liquide", {RightLabel = "💸"}, true, {
                            onSelected = function()
                                local cashAmount = tonumber(KeyboardInput("KIROW_ID", 'Montant (10 chiffres max)', "", 10))
                                if type(cashAmount) == 'number' then
                                    TriggerServerEvent('kirow:AdminGiveCash', cashAmount)
                                else
                                    ESX.ShowNotification('~r~Administration                    ~w~Montant invalide')
                                end
                            end
                        })
                        RageUI.Button("Argent ~r~sale", "S'octroyer de l'argent sale", {RightLabel = "💶"}, true, {
                            onSelected = function()
                                local cashAmount = tonumber(KeyboardInput("KIROW_ID", 'Montant (10 chiffres max)', "", 10))
                                if type(cashAmount) == 'number' then
                                    TriggerServerEvent('kirow:AdminGiveBlackMoney', cashAmount)
                                else
                                    ESX.ShowNotification('~r~Administration                    ~w~Montant invalide')
                                end
                            end
                        })
                        RageUI.Button("~b~Banque", "S'octroyer de l'argent sur son compte bancaire", {RightLabel = "💳"}, true, {
                            onSelected = function()
                                local cashAmount = tonumber(KeyboardInput("KIROW_ID", 'Montant (10 chiffres max)', "", 10))
                                if type(cashAmount) == 'number' then
                                    TriggerServerEvent('kirow:AdminGiveBank', cashAmount)
                                else
                                    ESX.ShowNotification('~r~Administration                    ~w~Montant invalide')
                                end
                            end
                        })
                        RageUI.Separator("                         ~r~↓ ~s~Items ~r~↓")
                        RageUI.Button("Items", "S'octroyer un item depuis la liste", {RightLabel = "→"}, true, {
                            onSelected = function()
                                TriggerServerEvent('kirow:getItemsList', GetPlayerServerId(PlayerId()))
                            end
                        })
                        RageUI.Separator("                         ~r~↓ ~s~Armes ~r~↓")
                        RageUI.Button("Armes", "S'octroyer une arme depuis la liste", {RightLabel = "→"}, true, {}, weaponMenu)
                    end
                        RageUI.Separator("                         ~r~↓ ~w~Jobs ~r~↓")
                        RageUI.Button("Métiers", "Définir son métier", {RightLabel = "→"}, true, {
                            onSelected = function() 
                                ESX.TriggerServerCallback('kirow:getJobsList', function(data) 
                                    jobsList = data
                                end) 
                            end
                        }, jobsMenu)

                        RageUI.Button("Métiers secondaires / Organisations", "Définir son métier", {RightLabel = "→"}, true, {
                            onSelected = function() 
                                ESX.TriggerServerCallback('kirow:getJobsList', function(data) 
                                    jobsList = data
                                end) 
                            end
                        }, jobs2Menu)


                        RageUI.Separator("                         ~r~↓ ~w~Autres ~r~↓")

                        RageUI.Button("Se mettre en PED", "Changer l'apparence de votre personnage par un personnage basique du jeu.", {RightLabel = "→"}, true, {}, pedsMenu)

                        RageUI.Button('Se réanimer', "Pour te revives si t'es mort wati bogoss", {}, true, {

                            onSelected = function()
                                TriggerEvent('esx_ambulancejob:revive', source)
                                ESX.ShowNotification('~r~Administration                    ~w~Vous avez été réanimé')
                            end,
                        })

                        RageUI.Button('Se soigner', "Pour te soigner si t'es blessé wati bogoss", {}, true, {

                            onSelected = function()
                                SetEntityHealth(GetPlayerPed(-1), 200)
                                ESX.ShowNotification('~r~Administration                    ~w~Vous avez été soigné')
                            end,
                        })

                        RageUI.Button('Se téléporter sur le marqueur', "Raccourcis : ALT + E", {}, true, {

                            onSelected = function()
                                AdminTPMarker()
                            end,
            
                        })

                
                end)

                RageUI.IsVisible(vehicleMenu, function()
                    RageUI.Button('Réparer le véhicule', "Répare le véhicule dans lequel vous êtes.", {}, true, {

                        onSelected = function()
                            AdminRepair()
                        end,
        
                    })

                    RageUI.Button('Faire apparaître un véhicule', "Fait apparaître le véhicule de votre choix.", {}, true, {
    
                        onSelected = function()
                            AdminSpawnVehicle()
                        end,
    
                    })

                    RageUI.Separator("                         ~r~↓ ~w~Suppression de véhicules ~r~↓")

                    RageUI.Button('~r~Supprimer le véhicule le plus proche', "Supprime le véhicule le plus proche. ~n~⛔ Attention à vos véhicules personnels.", {}, true, {

                        onSelected = function()
                            ESX.Game.DeleteVehicle(ESX.Game.GetClosestVehicle())
                        end,
        
                    })

                end)

                RageUI.IsVisible(playerListMenu, function()
                    RageUI.Separator("                         ~r~↓ ~w~Informations serveur ~r~↓")
                    RageUI.Separator("                          Votre ID est le : ~r~" .. GetPlayerServerId(PlayerId()))
                    RageUI.Separator("                              Il y a actuellement ~r~" .. onlinePlayers .. " ~w~joueurs connectés.")
                    RageUI.Button("", nil, {}, true, {})
                    for k,v in pairs(GetActivePlayers()) do 
                        RageUI.Button("[~r~" .. GetPlayerServerId(v) .. "~s~] - ~s~" .. GetPlayerName(v), "Appuyez sur ENTREE pour accèder aux actions relatives à ce joueur", {RightLabel = "→"}, true, {
        
                            onSelected = function()
                                selectedPlayer = {}
                                selectedPlayer.id = GetPlayerServerId(v)
                                selectedPlayer.name = GetPlayerName(v)
                                selectedPlayer.ped = GetPlayerPed(v)
                                RageUI.Visible(playerActionMenu, not RageUI.Visible(playerActionMenu))
                            end,
                        })
                    end
        
                end)

            

                RageUI.IsVisible(pedsMenu, function()
                    RageUI.Button("Choisir un PED", "Entrez le nom d'un ped disponible sur : ~n~https://wiki.rage.mp/index.php?title=Peds", {}, true, {
                        onSelected = function()
                            local pedModel = KeyboardInput("KIROW_MSG", "Entrez le modèle", "", 35)
                            local pedHash = GetHashKey(pedModel)
                            local playerID = PlayerId()
                            RequestModel(pedHash)
                            while not HasModelLoaded(pedHash) do
                                Wait(100)
                            end
                            SetPlayerModel(playerID, pedHash)
                            SetModelAsNoLongerNeeded(pedHash)
                            ESX.ShowNotification("~r~Administration~n~~s~L'apparence de votre personnage a été modifiée.")
                            ESX.ShowNotification("~r~Administration~n~~s~Une déconnexion sera nécessaire pour retrouver votre apparence.")
                        end
                    })

                end)
        
                RageUI.IsVisible(playerActionMenu, function()
                    RageUI.Button('Envoyer un message', "Envoyer un message (sous forme de notification) au joueur sélectionné.", {}, true, {
        
                        onSelected = function()
                            msg = KeyboardInput("KIROW_MSG", "Entrez votre message (max 144)", "", 144)
                            TriggerServerEvent('kirow:AdminMessage', selectedPlayer.id, msg)
                            ESX.ShowNotification("~r~Administration \n~s~Message envoyé à ~h~" .. selectedPlayer.name .. "~s~.")
                            TriggerServerEvent('kirow:MsgLog', msg, selectedPlayer.name, selectedPlayer.id)
                        end,
        
                    })
                    RageUI.Button('Se téléporter au joueur', nil, {}, true, {
        
                        onSelected = function()
                            ESX.TriggerServerCallback('kirow:getPlayerCoords', function(pCoords)
                                local x, y, z = table.unpack(pCoords)
                                SetEntityCoords(GetPlayerPed(-1), x, y, z, false, false, false, false)
                            end, selectedPlayer.id)
                            ESX.ShowNotification("~r~Administration \n~s~Vous vous êtes téléporté à ~h~" .. selectedPlayer.name .. " ~s~.")
                        end,
        
                    })
                    RageUI.Button('Téléporter le joueur sur vous', nil, {}, true, {
        
                        onSelected = function()
                            TriggerServerEvent("kirow:AdminBring", GetEntityCoords(GetPlayerPed(-1)), selectedPlayer.id)
                            ESX.ShowNotification("~r~Administration \n~s~Vous avez téléporté ~h~" .. selectedPlayer.name .. " ~s~sur vous.")
                        end,
        
                    })

                    RageUI.Button('Réanimer le joueur', nil, {}, true, {
        
                        onSelected = function()
                            TriggerServerEvent('kirow:AdminRevivePlayer', selectedPlayer.id)
                        end,
        
                    })

                    RageUI.Button('Soigner le joueur', nil, {}, true, {
        
                        onSelected = function()
                            TriggerServerEvent('kirow:AdminHealPlayer', selectedPlayer.id)
                        end,
        
                    })
        
        
                    RageUI.Checkbox('Freeze le joueur', "Permet d'immobiliser le joueur. Pensez à décocher la case quand vous avez terminé.", freeze,  {}, {
        
                        onChecked = function()
                            freeze = true
                            TriggerServerEvent('kirow:AdminFreezeS', selectedPlayer.id)
                        end,
                        onUnChecked = function()
                            freeze = false
                            TriggerServerEvent('kirow:AdminFreezeS', selectedPlayer.id)
                        end,
                        onHovered = function()
        
                        end,
        
        
                    })

                    RageUI.Button("Définir le job du joueur", "Modifiez le métier du joueur sélectionné", {RightLabel = "→"}, true, {
                        onSelected = function()
                            ESX.TriggerServerCallback('kirow:getJobsList', function(data) 
                                jobsList = data
                            end) 
                        end
                    }, playerJobsMenu)
                    RageUI.Button("Définir le job secondaire / organisation du joueur", "Modifiez le métier secondaire / l'organisation du joueur sélectionné", {RightLabel = "→"}, true, {
                        onSelected = function()
                            ESX.TriggerServerCallback('kirow:getJobsList', function(data) 
                                jobsList = data
                            end) 
                        end
                    }, playerJobs2Menu)

                    if playerGroup == "superadmin" then
                        RageUI.Button("Octroyer des items", "Donner des items au joueur sélectionné.", {RightLabel = "→"}, true, {
                            onSelected = function()
                                TriggerServerEvent('kirow:getItemsList', selectedPlayer.id)
                            end
                        })
                    end
        
                    RageUI.Checkbox('Spectate', "Permet d'observer le joueur.", spectating,  {}, {
        
                        onChecked = function()
                            spectating = true
                            spectate(selectedPlayer.id)
                        end,
                        onUnChecked = function()
                            spectating = false
                            resetNormalCamera()
                        end,
                        onHovered = function()
        
                        end,
        
        
                    })
        
                    RageUI.Button('Voir l\'inventaire', "Permet de voir l'inventaire du joueur sélectionné.", {RightLabel = "→"}, true, {
        
                        onSelected = function()
                            items = {}
                            weaponsItems = {}
                            ESX.TriggerServerCallback('kirowSpec:getPlayerData', function(data, inventory, weapons) 

        
                                plyName = data.pName
                                plyFirstName = data.pPrenom
                                plyLastName = data.pNom
                                plySex = data.pSex
                                plyBirthdate = data.pBirth
                                plyHeight = data.pTaille
                                plyJob = data.pJob
                                plyJob2 = data.pJob2
                                plyMoney = "~g~" .. data.pCash
                                plyBank = "~g~" .. data.pBanque
                                plyBlackMoney = "~r~" .. data.pBlack
        
        
        
        
                                if inventory ~= nil then
                                    for key, value in pairs(inventory) do
                                        if inventory[key].count <= 0 then
                                            inventory[key] = nil
                                        else
                                            inventory[key].type = "item_standard"
                                            table.insert(items, inventory[key])
                                            --print(inventory[key].label, inventory[key].count)
                                        end
                                    end
                                end
        
                                if weapons ~= nil then
                                    for key, value in pairs(weapons) do
                                        local weaponHash = GetHashKey(weapons[key].name)
                                        local playerPed = selectedPlayer.ped
                                        if weapons[key].name ~= "WEAPON_UNARMED" then
                                            local ammo = GetAmmoInPedWeapon(playerPed, weaponHash)
                                            table.insert(
                                                weaponsItems,
                                                {
                                                    label = weapons[key].label,
                                                    count = ammo,
                                                    weight = -1,
                                                    type = "item_weapon",
                                                    name = weapons[key].name,
                                                    usable = false,
                                                    rare = false,
                                                    canRemove = true
                                                }
                                            )
                                        end
                                    end
                                end

                                RageUI.Visible(playerInventoryMenu, not RageUI.Visible(playerInventoryMenu))

                            end, selectedPlayer.id)
                            
                        end,
        
                    })
        
                    RageUI.Button('~r~Kick', "Permet d'expulser le joueur du serveur.", {}, true, {
        
                        onSelected = function()
                            local reason = KeyboardInput("KIROW_REASON", "Raison (144 caractères)", "", 144)
                            TriggerServerEvent('kirow:kick', selectedPlayer.id, reason)
                        end,
        
                    })

                    RageUI.Separator("                         ~r~↓ ~w~Modifications du skin ~r~↓")

                    RageUI.Button("~o~Accorder une modification d'apparence", "Permet d'accorder une modification d'apparence (ouvre le menu /skin pour le joueur sélectionné).", {}, true, {
        
                        onSelected = function()
                            TriggerServerEvent("kirow:changePlayerSkin", selectedPlayer.id)
                            RageUI.CloseAll()
                        end,
        
                    })
                    
                    if playerGroup == "superadmin" then
                        RageUI.Separator("                         ~r~↓ ~w~Wipe & Identité ~r~↓")
                        RageUI.Button("~o~Modifier l'identité", "Modifier l'identité du joueur sélectionné", {}, true, {
                            onSelected = function()
                                local firstname = KeyboardInput("KIROW_ID", "Prénom", "", 16)
                                local lastname = KeyboardInput("KIROW_ID", "Nom de famille", "", 16)
                                if firstname ~= nil and lastname ~= nil and firstname ~= "" and lastname ~= "" then
                                    TriggerServerEvent("kirow:changePlayerIdentity", selectedPlayer.id, firstname, lastname)
                                else
                                    ESX.ShowNotification("~r~Il faut rentrer une valeur bg.")
                                end
                            end
                        })
                        RageUI.Button("~r~Wipe le joueur", "Permet de wipe le joueur.", {}, true, {
            
                            onSelected = function()
                                vehListState = {}
                                plateList = {}
                                TriggerServerEvent('kirow:getPlayerVehicles', selectedPlayer.id)
                                for k, v in pairs(targetVehList) do
                                    currentVehicle = json.decode(v.vehicle)
                                    vehListState[currentVehicle.plate] = false
                                end
                            end,
            
                        }, selectList)
                    end
                    
                end)

                RageUI.IsVisible(selectList, function()
                    RageUI.Separator("                          ~r~Cochez les cases des véhicule à supprimer")
                    RageUI.Separator("                        ~o~↓~s~ Liste des vehicules ~o~↓")
                    for k, v in pairs(targetVehList) do
                        currentVehicle = json.decode(v.vehicle)

                        RageUI.Checkbox(GetDisplayNameFromVehicleModel(currentVehicle.model) .. " " .. currentVehicle.plate, nil, vehListState[currentVehicle.plate], {}, {
                            onChecked = function()
                                vehListState[currentVehicle.plate] = true
                                table.insert(plateList, currentVehicle.plate)
                                print(json.encode(plateList))
                                print("check")
                            end,
                            onUnChecked = function()
                                vehListState[currentVehicle.plate] = false
                                table.remove(plateList, getTableIndex(plateList, currentVehicle.plate))
                                print(json.encode(plateList))
                                print("uncheck")
                            end
                        })

                    end  
                    RageUI.Button("~o~Supprimer les véhicules", "Appuyez sur ENTREE pour valider le supprimer les véhicules au joueur (Pas de wipe, simplement une suppression des véhicules sélectionnés).", {}, true, {
                        onSelected = function()
                            TriggerServerEvent("kirow:removePlayerSelectedVehicles", selectedPlayer.id, plateList)
                        end
                    })
                    RageUI.Button("~g~Valider le wipe", "Appuyez sur ENTREE pour valider le wipe du joueur.", {}, true, {
                        onSelected = function()
                            TriggerServerEvent("kirow:wipeSelectedPlayer", selectedPlayer.id, plateList)
                        end
                    })
                end)

                RageUI.IsVisible(playerInventoryMenu, function()
                    
                    RageUI.Button("", nil, {}, true, {})
                    RageUI.Button("Nom steam :", nil, {RightLabel = plyName}, true, {onSelected = function() end, })
                    RageUI.Separator("                         ~r~↓ ~w~Argent du joueur ~r~↓")
                    RageUI.Button("Liquide :", nil, {RightLabel = "~g~" .. ESX.Math.GroupDigits(plyMoney) .. "~s~$"}, true, {onSelected = function() end, })
                    RageUI.Button("Banque :", nil, {RightLabel = "~b~" .. ESX.Math.GroupDigits(plyBank) .. "~s~$"}, true, {onSelected = function() end, })
                    RageUI.Button("Argent sale :", nil, {RightLabel = "~r~" .. ESX.Math.GroupDigits(plyBlackMoney) .. "~s~$"}, true, {onSelected = function() end, })
        
                    RageUI.Separator("                         ~r~↓ ~w~Carte d'identité ~r~↓")

        
                    RageUI.Button("Prénom :", nil, {RightLabel = plyFirstName}, true, {onSelected = function() end, })
                    RageUI.Button("Nom :", nil, {RightLabel = plyLastName}, true, {onSelected = function() end, })
                    RageUI.Button("Métier :", nil, {RightLabel = plyJob}, true, {onSelected = function() end, })
                    RageUI.Button("Organisation :", nil, {RightLabel = plyJob2}, true, {onSelected = function() end, })
                    RageUI.Button("Sexe :", nil, {RightLabel = plySex}, true, {onSelected = function() end, })
                    RageUI.Button("Date de naissance :", nil, {RightLabel = plyBirthdate}, true, {onSelected = function() end, })
                    RageUI.Button("Taille :", nil, {RightLabel = plyHeight}, true, {onSelected = function() end, })
        
                    RageUI.Separator("                         ~r~↓ ~w~Inventaire ~r~↓")
        
        
                    for _, v in pairs(items) do
                        RageUI.Button(v.label, nil, {RightLabel = "~r~" .. v.count}, true, {onSelected = function() end, })
                    end
        
                    RageUI.Separator("                         ~r~↓ ~w~Armes ~r~↓")
        
                    for _, v in pairs(weaponsItems) do
                        RageUI.Button(v.label, nil, {}, true, {onSelected = function() end, })
                    end
                    
                end)

                RageUI.IsVisible(weaponMenu, function()
                    for k, v in pairs(basicWeaponsList) do
                        RageUI.Button(v.label, "S'octroyer un/une " .. v.label .. "~n~Nom de l'arme : " .. v.name, {RightBadge = RageUI.BadgeStyle.Gun}, true, {
                            onSelected = function()
                                TriggerServerEvent('kirow:giveAdminWeapon', v.name)
                            end
                        })
                    end
                    RageUI.Button("", nil, {}, true, {})
                    RageUI.Button("Clear ses armes", "⛔ Vous supprimez toutes vos armes de votre inventaire, cette action est irréversible", {}, true, {
                        onSelected = function()
                            for k, v in pairs(basicWeaponsList) do
                                TriggerServerEvent('kirow:removePlayerWeapon', v.name)
                            end
                        end
                    })
                
                end)

                RageUI.IsVisible(jobsMenu, function()
                    for k, v in pairs(jobsList) do
                        RageUI.Button(v.jobLabel .. " - " .. v.label .. " [~r~" .. v.grade .. "~s~]" , "Commande : setjob me" .. " " .. v.job_name .. " " .. v.grade , {}, true, {
                            onSelected = function()
                                TriggerServerEvent('kirow:AdminSetJob', v.job_name, v.grade, 'primary', GetPlayerServerId(PlayerId()))
                            end
                        })
                    end
                end)
                RageUI.IsVisible(jobs2Menu, function()
                    for k, v in pairs(jobsList) do
                        RageUI.Button(v.jobLabel .. " - " .. v.label .. " [~r~" .. v.grade .. "~s~]" , "Commande : setjob me" .. " " .. v.job_name .. " " .. v.grade , {}, true, {
                            onSelected = function()
                                TriggerServerEvent('kirow:AdminSetJob', v.job_name, v.grade, 'secondary', GetPlayerServerId(PlayerId()))
                            end
                        })
                    end
                end)

                RageUI.IsVisible(playerJobsMenu, function()
                    for k, v in pairs(jobsList) do
                        RageUI.Button(v.jobLabel .. " - " .. v.label .. " [~r~" .. v.grade .. "~s~]" , "Commande : setjob me" .. " " .. v.job_name .. " " .. v.grade , {}, true, {
                            onSelected = function()
                                TriggerServerEvent('kirow:AdminSetJob', v.job_name, v.grade, 'primary', selectedPlayer.id)
                            end
                        })
                    end
                end)

                RageUI.IsVisible(playerJobs2Menu, function()
                    for k, v in pairs(jobsList) do
                        RageUI.Button(v.jobLabel .. " - " .. v.label .. " [~r~" .. v.grade .. "~s~]" , "Commande : setjob me" .. " " .. v.job_name .. " " .. v.grade , {}, true, {
                            onSelected = function()
                                TriggerServerEvent('kirow:AdminSetJob', v.job_name, v.grade, 'secondary', selectedPlayer.id)
                            end
                        })
                    end
                end)

                RageUI.IsVisible(bansMenu, function()
                    RageUI.Button("~r~Avertir un joueur", "Warn", {}, true, {
                        onSelected = function()
                            ExecuteCommand('bwh warn')
                        end
                    })
                    RageUI.Button("Voir la liste des warns", "Afficher la liste des warns", {RightLabel = "→"}, true, {
                        onSelected = function()
                            ExecuteCommand('bwh warnlist')
                        end
                    })
                    RageUI.Button("~r~Bannir un joueur", "Ban", {}, true, {
                        onSelected = function()
                            ExecuteCommand('bwh ban')
                        end
                    })
                    RageUI.Button("Voir la liste des bans", "Afficher la liste des bans", {RightLabel = "→"}, true, {
                        onSelected = function()
                            ExecuteCommand('bwh banlist')
                        end
                    })
                end)

                Wait(1)
            end
        end)
    end
end



RegisterNetEvent('kirow:OpenItemsMenu')
RegisterNetEvent('kirow:refreshItemsList')
AddEventHandler('kirow:OpenItemsMenu', function(itemsList, targetID)
    isItemsMenuOpened = true
    AddEventHandler('kirow:refreshItemsList', function(newItemsList)
        itemsList = newItemsList
    end)
    local itemsMenu = RageUI.CreateMenu("Liste des objets", "Selectionnez un objet")
    itemsMenu.Closed = function()
        isItemsMenuOpened = false
      RageUI.Visible(itemsMenu, false)
    end
    itemsMenu:SetRectangleBanner(0, 0, 0, 100)
    itemsMenu:DisplayGlare(false)
    itemsMenu:SetStyleSize(60)


    RageUI.Visible(itemsMenu, true)
    while isItemsMenuOpened do
        Citizen.Wait(1)
        RageUI.IsVisible(itemsMenu, function()
            RageUI.Button("Rechercher par nom", "Effectuer une recherche par nom de l'item", {}, true, {
                onSelected = function()
                    local searchString = KeyboardInput("KIROW_SEARCH", "Mot clé", "", 20)
                    if searchString ~= nil then 
                        TriggerServerEvent('kirow:searchForItem', searchString, itemsList)
                    else
                        ESX.ShowNotification("~r~Faut écrire un truc bg.")
                    end
                end
            })

            RageUI.Separator("                         ~r~↓ ~s~Liste des objets ~r~↓")

            for _, v in pairs(itemsList) do
                RageUI.Button(v.label, "giveitem me ~g~" .. v.name, {}, true, {
                    onSelected = function()
                        local qty = tonumber(KeyboardInput("KIROW_AMOUNT", "Quantité", "", 10))
                        if qty ~= nil and qty > 0 then
                            print(targetID)
                            TriggerServerEvent('kirow:giveItemToPlayer', targetID, v.name, qty)
                        else
                            ESX.ShowNotification("~r~Quantité invalide bg.")
                        end
                    end
                })
            end
        end)
    end
end)

function getTableIndex(table, value)
    for k, v in pairs(table) do
        if v == value then
            return k
        end
    end
end

-- NOCLIP 
function admin_no_clip()
	if noclip then
		FreezeEntityPosition(plyPed, true)
		SetEntityInvincible(plyPed, true)
		SetEntityCollision(plyPed, false, false)

		SetEntityVisible(plyPed, false, false)

		SetEveryoneIgnorePlayer(PlayerId(), true)
		SetPoliceIgnorePlayer(PlayerId(), true)
		ESX.ShowNotification("~r~Administration~n~~w~Vous avez ~g~activé~w~ le noclip.")
	else
		FreezeEntityPosition(plyPed, false)
		SetEntityInvincible(plyPed, false)
		SetEntityCollision(plyPed, true, true)

		SetEntityVisible(plyPed, true, false)

		SetEveryoneIgnorePlayer(PlayerId(), false)
		SetPoliceIgnorePlayer(PlayerId(), false)
		ESX.ShowNotification("~r~Administration~n~~w~Vous avez ~r~désactivé~w~ le noclip.")
	end
end

function getCamDirection()
	local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(plyPed)
	local pitch = GetGameplayCamRelativePitch()
	local coords = vector3(-math.sin(heading * math.pi / 180.0), math.cos(heading * math.pi / 180.0), math.sin(pitch * math.pi / 180.0))
	local len = math.sqrt((coords.x * coords.x) + (coords.y * coords.y) + (coords.z * coords.z))

	if len ~= 0 then
		coords = coords / len
	end

	return coords
end






if playerGroup ~= 'user' then
    Citizen.CreateThread(function()
        while true do
            plyPed = PlayerPedId()
            if noclip then
                local coords = GetEntityCoords(plyPed)
                local camCoords = getCamDirection()
    
                SetEntityVelocity(plyPed, 0.01, 0.01, 0.01)
    
                if IsControlPressed(0, 32) then
                    coords = coords + (noClipInfos.speed * camCoords)
                end
    
                if IsControlPressed(0, 269) then
                    coords = coords - (noClipInfos.speed * camCoords)
                end
    
                SetEntityCoordsNoOffset(plyPed, coords, true, true, true)
            end

            if showcoord then
                local playerPos = GetEntityCoords(plyPed)
                local playerHeading = GetEntityHeading(plyPed)
                Text("~r~X~s~: " .. playerPos.x .. " ~b~Y~s~: " .. playerPos.y .. " ~g~Z~s~: " .. playerPos.z .. " ~y~Angle~s~: " .. playerHeading)
            end


            if godmode then
                Text2("Invincible")
                SetEntityInvincible(GetPlayerPed(-1), true)
                SetPlayerInvincible(PlayerId(), true)
                SetPedCanRagdoll(GetPlayerPed(-1), false)
                ClearPedBloodDamage(GetPlayerPed(-1))
                ResetPedVisibleDamage(GetPlayerPed(-1))
                ClearPedLastWeaponDamage(GetPlayerPed(-1))
                SetEntityProofs(GetPlayerPed(-1), true, true, true, true, true, true, true, true)
                SetEntityCanBeDamaged(GetPlayerPed(-1), false)
            elseif not godmode then
                SetEntityInvincible(GetPlayerPed(-1), false)
                SetPlayerInvincible(PlayerId(), false)
                SetPedCanRagdoll(GetPlayerPed(-1), true)
                ClearPedLastWeaponDamage(GetPlayerPed(-1))
                SetEntityProofs(GetPlayerPed(-1), false, false, false, false, false, false, false, false)
                SetEntityCanBeDamaged(GetPlayerPed(-1), true)
            end

            if IsControlPressed(1, 19) and IsControlJustReleased(1, 38) and GetLastInputMethod(2) and not isDead then
                ESX.TriggerServerCallback('kirow:getUserGroup', function(group)
                    if group ~= nil and group ~= 'user' then
                        AdminTPMarker()
                    end
                end)
            end
            
            if blipsActive then
                for _, player in pairs(GetActivePlayers()) do
                    local found = false
                    if player ~= PlayerId() then
                        local ped = GetPlayerPed(player)
                        local blip = GetBlipFromEntity( ped )
                        if not DoesBlipExist( blip ) then
                            blip = AddBlipForEntity(ped)
                            SetBlipCategory(blip, 7)
                            SetBlipScale( blip,  0.85 )
                            ShowHeadingIndicatorOnBlip(blip, true)
                            SetBlipSprite(blip, 1)
                            SetBlipColour(blip, 0)
                        end
    
                        SetBlipNameToPlayerName(blip, player)
    
                        local veh = GetVehiclePedIsIn(ped, false)
                        local blipSprite = GetBlipSprite(blip)
    
                        if IsEntityDead(ped) then
                            if blipSprite ~= 303 then
                                SetBlipSprite( blip, 303 )
                                SetBlipColour(blip, 1)
                                ShowHeadingIndicatorOnBlip( blip, false )
                            end
                        elseif veh ~= nil then
                            if IsPedInAnyBoat( ped ) then
                                if blipSprite ~= 427 then
                                    SetBlipSprite( blip, 427 )
                                    SetBlipColour(blip, 0)
                                    ShowHeadingIndicatorOnBlip( blip, false )
                                end
                            elseif IsPedInAnyHeli( ped ) then
                                if blipSprite ~= 43 then
                                    SetBlipSprite( blip, 43 )
                                    SetBlipColour(blip, 0)
                                    ShowHeadingIndicatorOnBlip( blip, false )
                                end
                            elseif IsPedInAnyPlane( ped ) then
                                if blipSprite ~= 423 then
                                    SetBlipSprite( blip, 423 )
                                    SetBlipColour(blip, 0)
                                    ShowHeadingIndicatorOnBlip( blip, false )
                                end
                            elseif IsPedInAnyPoliceVehicle( ped ) then
                                if blipSprite ~= 137 then
                                    SetBlipSprite( blip, 137 )
                                    SetBlipColour(blip, 0)
                                    ShowHeadingIndicatorOnBlip( blip, false )
                                end
                            elseif IsPedInAnySub( ped ) then
                                if blipSprite ~= 308 then
                                    SetBlipSprite( blip, 308 )
                                    SetBlipColour(blip, 0)
                                    ShowHeadingIndicatorOnBlip( blip, false )
                                end
                            elseif IsPedInAnyVehicle( ped ) then
                                if blipSprite ~= 225 then
                                    SetBlipSprite( blip, 225 )
                                    SetBlipColour(blip, 0)
                                    ShowHeadingIndicatorOnBlip( blip, false )
                                end
                            else
                                if blipSprite ~= 1 then
                                    SetBlipSprite(blip, 1)
                                    SetBlipColour(blip, 0)
                                    ShowHeadingIndicatorOnBlip( blip, true )
                                end
                            end
                        else
                            if blipSprite ~= 1 then
                                SetBlipSprite( blip, 1 )
                                SetBlipColour(blip, 0)
                                ShowHeadingIndicatorOnBlip( blip, true )
                            end
                        end
                        if veh then
                            SetBlipRotation( blip, math.ceil( GetEntityHeading( veh ) ) )
                        else
                            SetBlipRotation( blip, math.ceil( GetEntityHeading( ped ) ) )
                        end
                    end
                end
            else
                for _, player in pairs(GetActivePlayers()) do
                    local blip = GetBlipFromEntity( GetPlayerPed(player) )
                    if blip ~= nil then
                        RemoveBlip(blip)
                    end
                end
            end
            
            Citizen.Wait(1)
        end
    end)
end

Keys.Register('F9', 'F9', 'Ouvrir le menu administratif', function()
    ESX.TriggerServerCallback('kirow:getUserGroup', function(group)
        playerGroup = group
        if group ~= nil and group ~= 'user' then
            OpenCloseMenu()
        end
    end)
end)

Keys.Register('N', 'N', 'Raccourcis Noclip', function()
    ESX.TriggerServerCallback('kirow:getUserGroup', function(group)
        playerGroup = group
        if group ~= nil and group ~= 'user' then
            noclip = not noclip
            admin_no_clip()
        end
    end)
end)

local gamerTags = {}
function showNames(bool)
    isNameShown = bool
    if isNameShown then
        Citizen.CreateThread(function()
            while isNameShown do
                local plyPed = PlayerPedId()
                for _, player in pairs(GetActivePlayers()) do
                    local ped = GetPlayerPed(player)
                    if ped ~= plyPed then
                        if #(GetEntityCoords(plyPed, false) - GetEntityCoords(ped, false)) < 5000.0 then
                            gamerTags[player] = CreateFakeMpGamerTag(ped, ('[%s] %s'):format(GetPlayerServerId(player), GetPlayerName(player)), false, false, '', 0)
                            SetMpGamerTagAlpha(gamerTags[player], 0, 255)
                            SetMpGamerTagAlpha(gamerTags[player], 2, 255)
                            SetMpGamerTagAlpha(gamerTags[player], 4, 255)
                            SetMpGamerTagAlpha(gamerTags[player], 7, 255)
                            SetMpGamerTagVisibility(gamerTags[player], 0, true)
                            SetMpGamerTagVisibility(gamerTags[player], 2, true)
                            SetMpGamerTagVisibility(gamerTags[player], 4, NetworkIsPlayerTalking(player))
                            --SetMpGamerTagVisibility(gamerTags[player], 7, DecorExistOn(ped, "staffl") and DecorGetInt(ped, "staffl") > 0)
                            SetMpGamerTagColour(gamerTags[player], 7, 55)
                            if NetworkIsPlayerTalking(player) then
                                SetMpGamerTagHealthBarColour(gamerTags[player], 211)
                                SetMpGamerTagColour(gamerTags[player], 4, 211)
                                SetMpGamerTagColour(gamerTags[player], 0, 211)
                            else
                                SetMpGamerTagHealthBarColour(gamerTags[player], 0)
                                SetMpGamerTagColour(gamerTags[player], 4, 0)
                                SetMpGamerTagColour(gamerTags[player], 0, 0)
                            end

                        else
                            RemoveMpGamerTag(gamerTags[player])
                            gamerTags[player] = nil
                        end
                    end
                end

                Citizen.Wait(100)
            end
            for k,v in pairs(gamerTags) do
                RemoveMpGamerTag(v)
            end
            gamerTags = {}
        end)
    end
end


RegisterNetEvent('kirow:backPlayerVehicles')
AddEventHandler('kirow:backPlayerVehicles', function(vehList)
    targetVehList = vehList
end)