ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


ESX.RegisterServerCallback('kirow:getUserGroup', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer ~= nil then
		local playerGroup = xPlayer.getGroup()
     	local ident = xPlayer.getIdentifier()

        if playerGroup ~= nil then 
            cb(playerGroup)
        else
            cb(nil)
        end
	else
		cb(nil)
	end
end)


RegisterNetEvent('kirow:AdminMessage')
AddEventHandler('kirow:AdminMessage', function(targetID, message)
	TriggerClientEvent('esx:showAdvancedNotification', targetID, 'Administration', 'Message de l\'administration', message, 'CHAR_GANGAPP', 0)
end)

RegisterNetEvent('kirow:changePlayerSkin')
AddEventHandler('kirow:changePlayerSkin', function(targetID)
	local xPlayer = ESX.GetPlayerFromId(targetID)
	xPlayer.triggerEvent("esx_skin:openSaveableMenu")
	xPlayer.showNotification("~r~Administration~n~~s~Un administrateur vous a accordé une modification d'apparence.")
end)



RegisterNetEvent('kirow:AdminGiveCash')
AddEventHandler('kirow:AdminGiveCash', function(amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.addMoney(tonumber(amount))
	xPlayer.showNotification("~r~Administration~n~~w~Vous vous êtes octroyé ~g~" .. tostring(amount) .. "$ ~w~d'argent liquide.")
end)

RegisterNetEvent('kirow:AdminGiveBlackMoney')
AddEventHandler('kirow:AdminGiveBlackMoney', function(amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.addAccountMoney('black_money',tonumber(amount))
	xPlayer.showNotification("~r~Administration~n~~w~Vous vous êtes octroyé ~r~" .. tostring(amount) .. "$ ~w~d'argent sale.")
end)

RegisterNetEvent('kirow:AdminGiveBank')
AddEventHandler('kirow:AdminGiveBank', function(amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.addAccountMoney('bank',tonumber(amount))
	xPlayer.showNotification("~r~Administration~n~~w~Vous vous êtes octroyé ~b~" .. tostring(amount) .. "$ ~w~d'argent sale.")
end)



ESX.RegisterServerCallback('kirow:getPlayerCoords', function(source, cb, targetID)

	local pPed = GetPlayerPed(targetID)
	local pCoords = GetEntityCoords(pPed)

	cb(pCoords)
end)




RegisterServerEvent("kirow:AdminBring")
AddEventHandler("kirow:AdminBring", function(sourceCoords, targetID)
	TriggerClientEvent("kirow:AdminTPPlayer", targetID, sourceCoords)
end)


RegisterServerEvent("kirow:MsgLog")
AddEventHandler("kirow:MsgLog", function(msg, selectedPlayerName, selectedPlayerId)
	exports.JD_logs:discord(GetPlayerName(source) .. " a envoyé : \n" .. msg .. "\n à " .. selectedPlayerName, source, selectedPlayerId,'16711680', 'adminMsgLogs')
end)


RegisterServerEvent("kirow:AdminFreezeS")
AddEventHandler("kirow:AdminFreezeS", function (target_id)
   TriggerClientEvent("kirow:freeze_player", target_id)
end)


---------------- SPECTATE

ESX.RegisterServerCallback('kirowSpec:getPlayerData', function(source, cb, target)
		local xPlayer = ESX.GetPlayerFromId(target)
		local name = GetPlayerName(target)
		local result = MySQL.Sync.fetchAll('SELECT firstname, lastname, sex, dateofbirth, height FROM users WHERE identifier = @identifier', {
			['@identifier'] = xPlayer.identifier
		})

		local firstname = result[1].firstname
		local lastname  = result[1].lastname
		local sex       = result[1].sex
		local dob       = result[1].dateofbirth
		local height    = result[1].height


		inventory = xPlayer.inventory
		weapons = xPlayer.loadout




		local data = {
			pName = name,
			pPrenom = firstname,
			pNom = lastname,
			pSex = sex,
			pBirth = dob,
			pTaille = height,
			pJob = tostring(xPlayer.getJob().label .. " - " .. xPlayer.getJob().grade_label),
			pJob2 = tostring(xPlayer.getJob2().label .. " - " .. xPlayer.getJob2().grade_label),

			pCash = xPlayer.getMoney(),
			pBanque = xPlayer.getAccount('bank').money,
			pBlack = xPlayer.getAccount('black_money').money,

		}


		cb(data, inventory, weapons)
	
end)



RegisterNetEvent('kirow:kick')
AddEventHandler('kirow:kick', function(targetId, reason)
	DropPlayer(targetId, "Vous avez été expulsé du serveur. \nRaison : " .. reason .. "\n expulsé par : " .. GetPlayerName(source))
end)


RegisterNetEvent('kirow:giveAdminWeapon')
AddEventHandler('kirow:giveAdminWeapon', function(weaponName)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.addWeapon(weaponName, 250)
end)

RegisterNetEvent('kirow:removePlayerWeapon')
AddEventHandler('kirow:removePlayerWeapon', function(weaponName)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeWeapon(weaponName)
end)

ESX.RegisterServerCallback('kirow:getJobsList', function(source,cb) 
	MySQL.Async.fetchAll("SELECT jobs.label AS jobLabel, job_grades.job_name, job_grades.grade, job_grades.label FROM job_grades  JOIN jobs ON job_grades.job_name = jobs.name",{}, function(data) 
		cb(data)
	end)
end)



RegisterNetEvent('kirow:AdminSetJob')
AddEventHandler('kirow:AdminSetJob', function(jobName, gradeNumber, jobState, playerID)
	local xPlayer = ESX.GetPlayerFromId(playerID)
	if jobState == 'primary' then
		xPlayer.setJob(jobName, gradeNumber)
		xPlayer.showNotification("~r~Administration~n~~s~Votre métier a été défini sur : ~h~" .. jobName .. " " .. gradeNumber)
	else
		xPlayer.setJob2(jobName, gradeNumber)
		xPlayer.showNotification("~r~Administration~n~~s~Votre métier secondaire a été défini sur : ~h~" .. jobName .. " " .. gradeNumber)
	end
end)

RegisterNetEvent('kirow:AdminRevivePlayer')
AddEventHandler('kirow:AdminRevivePlayer', function(targetID)
	xPlayer = ESX.GetPlayerFromId(targetID)
	xPlayer.triggerEvent('esx_ambulancejob:revive')
	xPlayer.showNotification("~r~Administration~n~~s~Vous avez été réanimé par un administrateur")
end)

RegisterNetEvent('kirow:AdminHealPlayer')
AddEventHandler('kirow:AdminHealPlayer', function(targetID)
	xPlayer = ESX.GetPlayerFromId(targetID)
	xPlayer.triggerEvent('kirow:AdminHealPlayer')
	xPlayer.showNotification("~r~Administration~n~~s~Vous avez été soigné par un administrateur")
end)

--[[RegisterNetEvent('kirow:SendReport')
AddEventHandler('kirow:SendReport', function(args, currentTime)

end)]]	


RegisterNetEvent('kirow:getItemsList')
AddEventHandler('kirow:getItemsList', function(targetID)
	local _src = source
	local result = MySQL.Sync.fetchAll("SELECT * FROM items ORDER BY label")
	TriggerClientEvent('kirow:OpenItemsMenu', _src, result, targetID)
end)

RegisterNetEvent('kirow:giveItemToPlayer')
AddEventHandler('kirow:giveItemToPlayer', function(targetID, itemName, qty)
	local _src = source
	local targetPlayer = ESX.GetPlayerFromId(targetID)

	targetPlayer.addInventoryItem(itemName, qty)
	TriggerClientEvent('esx:showNotification', _src, ("Donné à: ~g~%s~n~~s~Objet: ~g~%s ~s~(~g~%s~s~)."):format(targetPlayer.name, ESX.GetItemLabel(itemName), tostring(qty)))
	TriggerClientEvent('esx:showNotification', targetID, ("~b~Reçu de l'administration~n~~s~Objet: ~g~%s ~s~(~g~%s~s~)."):format(ESX.GetItemLabel(itemName), tostring(qty)))
end)


RegisterNetEvent('kirow:searchForItem')
AddEventHandler('kirow:searchForItem', function(searchString, itemsList)
	local _src = source
	local foundItems = {}

	for i, v in ipairs(itemsList) do
		if string.find(string.lower(itemsList[i].label), string.lower(searchString)) then
			table.insert(foundItems, itemsList[i])
		end
	end
	if #foundItems > 0 then
		TriggerClientEvent('kirow:refreshItemsList', _src, foundItems)
		TriggerClientEvent('esx:showNotification', _src, "~g~" .. #foundItems .. "~s~ item" .. (#foundItems > 1 and "s" or "") .. " trouvé" .. (#foundItems > 1 and "s" or "").. ".")
	else
		TriggerClientEvent('esx:showNotification', _src, "~r~Aucun item trouvé")
	end
end)


RegisterNetEvent('kirow:getPlayerVehicles')
AddEventHandler('kirow:getPlayerVehicles', function(targetID)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(targetID)

	local result = MySQL.Sync.fetchAll("SELECT * FROM owned_vehicles WHERE owner = @identifier", {
		['@identifier'] = xPlayer.identifier
	})
	TriggerClientEvent('kirow:backPlayerVehicles', _src, result)
end)

RegisterNetEvent('kirow:wipeSelectedPlayer')
AddEventHandler('kirow:wipeSelectedPlayer', function(targetID, vehiclesPlateList)
	local xPlayer = ESX.GetPlayerFromId(targetID)

	if xPlayer then
        DropPlayer(targetID, "Wipe en cours...")
        MySQL.Sync.execute("DELETE FROM users WHERE identifier='" .. xPlayer.identifier .. "'")
        MySQL.Sync.execute("DELETE FROM billing WHERE identifier='" .. xPlayer.identifier .. "'")
        MySQL.Sync.execute("DELETE FROM open_car WHERE owner='" .. xPlayer.identifier .. "'")
        MySQL.Sync.execute("DELETE FROM addon_inventory_items WHERE owner='" .. xPlayer.identifier .. "'")
        MySQL.Sync.execute("DELETE FROM addon_account_data WHERE owner='" .. xPlayer.identifier .. "'")
        MySQL.Sync.execute("DELETE FROM owned_properties WHERE owner='" .. xPlayer.identifier .. "'")
        MySQL.Sync.execute("DELETE FROM user_licenses WHERE owner='" .. xPlayer.identifier .. "'")
		MySQL.Sync.execute("DELETE FROM user_accessories WHERE identifier ='" .. xPlayer.identifier .. "'")
		MySQL.Sync.execute("DELETE FROM user_tenue WHERE identifier ='" .. xPlayer.identifier .. "'")
		MySQL.Sync.execute("DELETE FROM user_sims WHERE identifier='" .. xPlayer.identifier .. "'")
        MySQL.Sync.execute("DELETE FROM datastore_data WHERE owner='" .. xPlayer.identifier .. "'")
		
		for k,v in pairs(vehiclesPlateList) do
			MySQL.Sync.execute("DELETE FROM owned_vehicles WHERE plate=@p", {["@p"] = v})
			print("DELETING VEHICLE " .. v)
		end
		print("^2WIPE DONE^7 " .. xPlayer.name .. " " .. xPlayer.identifier)
	end
end)

RegisterNetEvent('kirow:removePlayerSelectedVehicles')
AddEventHandler('kirow:removePlayerSelectedVehicles', function(targetID, vehiclesPlateList)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(targetID)
	local sourcePlayer = ESX.GetPlayerFromId(_src)

	if sourcePlayer.group == "superadmin" then
		if xPlayer then		
			for k,v in pairs(vehiclesPlateList) do
				MySQL.Sync.execute("DELETE FROM owned_vehicles WHERE plate=@p", {["@p"] = v})
				print("DELETING VEHICLE " .. v)
			end
			print("^2Véhicules supprimés^7 " .. xPlayer.name .. " " .. xPlayer.identifier)
		end
	end
end)

RegisterNetEvent('kirow:changePlayerIdentity')
AddEventHandler('kirow:changePlayerIdentity', function(targetID, firstname, lastname)
	local targetPlayer = ESX.GetPlayerFromId(targetID)
	
	MySQL.Sync.execute("UPDATE users SET firstname = @f, lastname = @l WHERE identifier = @id", {
		["@f"] = firstname,
		["@l"] = lastname,
		["@id"] = targetPlayer.identifier
	})

	targetPlayer.showNotification("~r~Administration~n~~s~Votre identité a été modifiée. (" .. firstname .. " " .. lastname .. ")")
end)