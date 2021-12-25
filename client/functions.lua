function KeyboardInput(entryTitle, textEntry, inputText, maxLength)
    AddTextEntry(entryTitle, textEntry)
    DisplayOnscreenKeyboard(1, entryTitle, "", inputText, "", "", "", maxLength)
	blockinput = true

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end

    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Citizen.Wait(500)
		blockinput = false
        return result
    else
        Citizen.Wait(500)
		blockinput = false
        return nil
    end
end



-- Réparer vehicule
function AdminRepair()
	local car = GetVehiclePedIsIn(plyPed, false)
	ESX.ShowNotification('~r~Administration                                  ~w~Véhicule réparé')

	SetVehicleFixed(car)
	SetVehicleDirtLevel(car, 0.0)
end
-- FIN Réparer vehicule




-- INVISIBLE
function AdminInvisibility()
	invisible = not invisible

	if invisible then
		SetEntityVisible(plyPed, false, false)
		ESX.ShowNotification('~r~Administration                                  ~w~Vous avez ~g~activé l\'invisibilité')
	else
		SetEntityVisible(plyPed, true, false)
		ESX.ShowNotification('~r~Administration                                  ~w~Vous avez ~r~désactivé l\'invisibilité')
	end
end
-- FIN INVISIBLE

function AdminRevivePlayer(targetPlayer)
    TriggerServerEvent('esx_ambulancejob:revive', tonumber(targetPlayer))
end

function Text(text)
	SetTextColour(186, 186, 186, 255)
	SetTextFont(0)
	SetTextScale(0.378, 0.378)
	SetTextWrap(0.0, 1.0)
	SetTextCentre(false)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 205)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(0.300, 0.010)
end

function Text2(text)
	SetTextColour(0, 255, 0, 255)
	SetTextFont(0)
	SetTextScale(0.500, 0.500)
	SetTextWrap(0.0, 1.0)
	SetTextCentre(false)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 205)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(0.500, 0.960)
end





function AdminTPMarker()
	local WaypointHandle = GetFirstBlipInfoId(8)

	if DoesBlipExist(WaypointHandle) then
		local waypointCoords = GetBlipInfoIdCoord(WaypointHandle)

		for height = 1, 1000 do
			SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords["x"], waypointCoords["y"], height + 0.0)

			local foundGround, zPos = GetGroundZFor_3dCoord(waypointCoords["x"], waypointCoords["y"], height + 0.0)

			if foundGround then
				SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords["x"], waypointCoords["y"], height + 0.0)

				break
			end

			Citizen.Wait(0)
		end

		ESX.ShowNotification("~r~Administration                    ~w~Vous avez été téléporté sur le marqueur")
	else
		ESX.ShowNotification("~r~Administration                    ~w~Aucun marqueur")
	end
end

RegisterNetEvent("kirow:AdminTPPlayer")
AddEventHandler("kirow:AdminTPPlayer", function (coords) -- in vector3
    local Source = source
    
    last_pos = fixVector(GetEntityCoords(GetPlayerPed(-1)))

    if Source ~= "" then
        if tonumber(Source) > 64 then
            SetEntityCoords(GetPlayerPed(-1), coords)
            FreezeEntityPosition(GetPlayerPed(-1), true)
            Citizen.Wait(1000)
            FreezeEntityPosition(GetPlayerPed(-1), false)
        end
    end

end)

function AdminSpawnVehicle()
	local vehicleName = KeyboardInput("KIROW_VEH", "Modèle du véhicule", "", 20)

	if vehicleName ~= nil then
		vehicleName = tostring(vehicleName)
		
		if type(vehicleName) == 'string' then
			local car = GetHashKey(vehicleName)
				
			Citizen.CreateThread(function()
				RequestModel(car)

				while not HasModelLoaded(car) do
					Citizen.Wait(0)
				end

				local x, y, z = table.unpack(GetEntityCoords(plyPed, true))

				local veh = CreateVehicle(car, x, y, z, 0.0, true, false)
				local id = NetworkGetNetworkIdFromEntity(veh)

				SetEntityVelocity(veh, 2000)
				SetVehicleOnGroundProperly(veh)
				SetVehicleHasBeenOwnedByPlayer(veh, true)
				SetNetworkIdCanMigrate(id, true)
				SetPedIntoVehicle(plyPed, veh, -1)
				SetModelAsNoLongerNeeded(car)
			end)
		end
	else
		ESX.ShowNotification('~r~Administration~n~~w~Nom invalide')
	end

end

function fixVector(coords)
    local x = coords.x
    local y = coords.y
    local z = coords.z

    x = math.floor(x)
    y = math.floor(y)
    z = math.floor(z)

    local fixed_coords = vector3(x, y, z)

    return fixed_coords

end



RegisterNetEvent("kirow:AdminFreezeC")
AddEventHandler("kirow:AdminFreezeC", function (targetId) 
	TriggerServerEvent("kirown:Sfreeze", target_id)
end)

RegisterNetEvent("kirow:AdminHealPlayer")
AddEventHandler("kirow:AdminHealPlayer", function (targetId) 
	SetEntityHealth(GetPlayerPed(-1), 200)
end)


RegisterNetEvent("kirow:freeze_player")
AddEventHandler("kirow:freeze_player", function ()
    local Source = source

    if Source ~= "" then
        if tonumber(Source) > 64 then
            freeze = not freeze

            local local_ped = GetPlayerPed(-1)
        
            FreezeEntityPosition(local_ped, freeze)
        
            if freeze then
                ESX.ShowNotification("~r~Administration \n~s~~h~Vous avez été ~r~freeze~s~.")
            else
                ESX.ShowNotification("~r~Administration \n~s~~h~Vous avez été ~g~unfreeze~s~.")
            end
        end
    end

end)



--------------------------------------------------------------- SPECTATE
local InSpectatorMode, ShowInfos = false, false
local TargetSpectate, LastPosition, cam

local polarAngleDeg = 0
local azimuthAngleDeg = 90
local radius = -3.5
local PlayerDate = {}


function spectate(target)

	ESX.TriggerServerCallback('esx:getPlayerData', function(player)
		if not InSpectatorMode then
			LastPosition = GetEntityCoords(PlayerPedId())
		end

		local playerPed = PlayerPedId()

		SetEntityCollision(playerPed, false, false)
		SetEntityVisible(playerPed, false)

		PlayerData = player

		Citizen.CreateThread(function()
			if not DoesCamExist(cam) then
				cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
			end

			SetCamActive(cam, true)
			RenderScriptCams(true, false, 0, true, true)

			InSpectatorMode = true
			TargetSpectate  = target
		end)
	end, target)

end


Citizen.CreateThread(function()

	while true do

	  Wait(1)

	  if InSpectatorMode then

		  local targetPlayerId = GetPlayerFromServerId(TargetSpectate)
		  local playerPed	  = PlayerPedId()
		  local targetPed	  = GetPlayerPed(targetPlayerId)
		  local coords	 = GetEntityCoords(targetPed)

		  for i=0, 255, 1 do
			  if i ~= PlayerId() then
				  local otherPlayerPed = GetPlayerPed(i)
				  SetEntityNoCollisionEntity(playerPed,  otherPlayerPed,  true)
			  end
		  end

		  if IsControlPressed(2, 241) then
			  radius = radius + 2.0
		  end

		  if IsControlPressed(2, 242) then
			  radius = radius - 2.0
		  end

		  if radius > -1 then
			  radius = -1
		  end

		  local xMagnitude = GetDisabledControlNormal(0, 1)
		  local yMagnitude = GetDisabledControlNormal(0, 2)

		  polarAngleDeg = polarAngleDeg + xMagnitude * 10

		  if polarAngleDeg >= 360 then
			  polarAngleDeg = 0
		  end

		  azimuthAngleDeg = azimuthAngleDeg + yMagnitude * 10

		  if azimuthAngleDeg >= 360 then
			  azimuthAngleDeg = 0
		  end

		  local nextCamLocation = polar3DToWorld3D(coords, radius, polarAngleDeg, azimuthAngleDeg)

		  SetCamCoord(cam,  nextCamLocation.x,  nextCamLocation.y,  nextCamLocation.z)
		  PointCamAtEntity(cam,  targetPed)
		  SetEntityCoords(playerPed,  coords.x, coords.y, coords.z + 10)

	  end
  end
end)


function resetNormalCamera()
	InSpectatorMode = false
	TargetSpectate  = nil
	local playerPed = PlayerPedId()

	SetCamActive(cam, false)
	RenderScriptCams(false, false, 0, true, true)

	SetEntityCollision(playerPed, true, true)
	SetEntityVisible(playerPed, true)
	SetEntityCoords(playerPed, LastPosition.x, LastPosition.y, LastPosition.z)
end


function polar3DToWorld3D(entityPosition, radius, polarAngleDeg, azimuthAngleDeg)
	-- convert degrees to radians
	local polarAngleRad   = polarAngleDeg   * math.pi / 180.0
	local azimuthAngleRad = azimuthAngleDeg * math.pi / 180.0

	local pos = {
		x = entityPosition.x + radius * (math.sin(azimuthAngleRad) * math.cos(polarAngleRad)),
		y = entityPosition.y - radius * (math.sin(azimuthAngleRad) * math.sin(polarAngleRad)),
		z = entityPosition.z - radius * math.cos(azimuthAngleRad)
	}

	return pos
end







--[[RegisterCommand('report', function(source, args, rawCommand)
	local currentTime = {}
	currentTime.year, currentTime.month, currentTime.day, currentTime.hour, currentTime.minute, currentTime.second = GetLocalTime()
	TriggerServerEvent('kirow:SendReport', args, currentTime)
end, false)]]