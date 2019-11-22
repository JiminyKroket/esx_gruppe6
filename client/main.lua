local PlayerData, CurrentActionData, blipsGruppe, currentTask, spawnedVehicles = {}, {}, {}, {}, {}
local HasAlreadyEnteredMarker, isDead, hasAlreadyJoined = false, false, false
local LastStation, LastPart, LastPartNum, LastEntity, CurrentAction, CurrentActionMsg
local intruderCuffed 	= false
local intruderGrabbed 	= false
local hasIntruder 		= false
local intruderInCar 	= false
local Intruder 			= {}
local randomPed 		= {}
local onJob 			= false
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	PlayerData = ESX.GetPlayerData()
end)

cleanPlayer = function(ped)
	SetPedArmour(ped, 0)
	ClearPedBloodDamage(ped)
	ResetPedVisibleDamage(ped)
	ClearPedLastWeaponDamage(ped)
	ResetPedMovementClipset(ped, 0)
end

setUniform = function(job, ped)
	TriggerEvent('skinchanger:getSkin', function(skin)
		if skin.sex == 0 then
			if Config.Uniforms[job].male then
				TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms[job].male)
			else
				ESX.ShowNotification('No outfit available')
			end

			if job == 'bullet_wear' then
				SetPedArmour(ped, 100)
			end
		else
			if Config.Uniforms[job].female then
				TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms[job].female)
			else
				ESX.ShowNotification('No outfit available')
			end

			if job == 'bullet_wear' then
				SetPedArmour(ped, 100)
			end
		end
	end)
end

OpenCloakroomMenu = function()

	local ped = PlayerPedId()
	local grade = PlayerData.job.grade

	local elements = {
		{ label = 'Personal Outfit', value = 'citizen_wear' },
		{ label = 'Patrol Uniform', value = 'patrol_wear' },
		{ label = 'Armored Vest', value = 'bullet_wear' },
		{ label = 'Reflective Vest', value = 'gilet_wear' },
		{ label = 'Heavy Patrol Uniform', value = 'heavy_wear' }
	}

	if grade == 4 then
		table.insert(elements, {label = 'Boss Suit', value = 'boss_wear'})
	end

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'cloakroom', {
		title    = 'Locker Room',
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
		cleanPlayer(ped)
		clothes = data.current.value

		if clothes == 'citizen_wear' then
			ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
				TriggerEvent('skinchanger:loadSkin', skin)
			end)	
		elseif clothes == 'patrol_wear' or clothes == 'boss_wear' or
		clothes == 'bullet_wear' or clothes == 'gilet_wear' or clothes == 'heavy_wear' then
			setUniform(clothes, ped)
		end
	end, function(data, menu)
		menu.close()

		CurrentAction     = 'menu_cloakroom'
		CurrentActionData = {}
	end)
end

OpenWeaponComponentShop = function(components, weaponName, parentShop)
	ESX.UI.Menu.CloseAll()
	
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'armory_buy_weapons_components', {
		title    = 'Weapon Components',
		align    = 'top-left',
		elements = components
	}, function(data, menu)
		local ped = PlayerPedId()
		if data.current.hasComponent then
			ESX.ShowNotification('Component already installed')
		else
			GiveWeaponComponentToPed(ped, GetHashKey(weaponName), data.current.componentNum)
			ESX.ShowNotification('You installed', data.current.componentLabel)

			menu.close()
		end
	end, function(data, menu)
		menu.close()
	end)
end

OpenArmoryMenu = function(station)
	local elements = {}
	local player = PlayerPedId()
	
	for k,v in ipairs(Config.AuthorizedWeapons[PlayerData.job.grade_name]) do
		local weaponNum, weapon = ESX.GetWeapon(v.weapon)
		local components, label = {}
		local hasWeapon = HasPedGotWeapon(player, GetHashKey(v.weapon), false)

		if v.components then
			for i=1, #v.components do
				if v.components[i] then
					local component = weapon.components[i]
					local hasComponent = HasPedGotWeaponComponent(player, GetHashKey(v.weapon), component.hash)

					if hasComponent then
						label = ('%s: <span style="color:green;">%s</span>'):format(component.label, 'Owned')
					else
						if v.components[i] > 0 then
							label = ('%s: <span style="color:green;">%s</span>'):format(component.label, '$%s'.. ESX.Math.GroupDigits(v.components[i]))
						else
							label = ('%s: <span style="color:green;">%s</span>'):format(component.label, 'free')
						end
					end

					table.insert(components, {
						label = label,
						componentLabel = component.label,
						hash = component.hash,
						name = component.name,
						price = v.components[i],
						hasComponent = hasComponent,
						componentNum = i
					})
				end
			end
		end

		if hasWeapon and v.components then
			label = ('%s: <span style="color:green;">></span>'):format(weapon.label)
		elseif hasWeapon and not v.components then
			label = ('%s: <span style="color:green;">%s</span>'):format(weapon.label, 'owned')
		else
			label = ('%s: <span style="color:green;">%s</span>'):format(weapon.label, 'free')
		end

		table.insert(elements, {
			label = label,
			weaponLabel = weapon.label,
			name = weapon.name,
			components = components,
			price = v.price,
			hasWeapon = hasWeapon
		})
	end
	
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'armory', {
		title    = 'Armory',
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
	
		if data.current.hasWeapon then
			if #data.current.components > 0 then
				OpenWeaponComponentShop(data.current.components, data.current.name, menu)
			end
		else
			GiveWeaponToPed(player, GetHashKey(data.current.name), 50)
			ESX.ShowNotification('You grabbed', data.current.name)
			
			menu.close()
			
		CurrentAction     = 'menu_armory'
		CurrentActionData = {station = station}
		end
	end, function(data, menu)
		menu.close()
		
		CurrentAction     = 'menu_armory'
		CurrentActionData = {station = station}
	end)
end

GetAvailableVehicleSpawnPoint = function(station, part, partNum)
	local spawnPoints = Config.SecurityStations[station][part][partNum].SpawnPoints
	local found, foundSpawnPoint = false, nil

	for i=1, #spawnPoints, 1 do
		if ESX.Game.IsSpawnPointClear(spawnPoints[i].coords, spawnPoints[i].radius) then
			found, foundSpawnPoint = true, spawnPoints[i]
			break
		end
	end

	if found then
		return true, foundSpawnPoint
	else
		ESX.ShowNotification('Location blocked')
		return false
	end
end

DeleteSpawnedVehicles = function()
	while #spawnedVehicles > 0 do
		local vehicle = spawnedVehicles[1]
		ESX.Game.DeleteVehicle(vehicle)
		table.remove(spawnedVehicles, 1)
	end
end

SetVehicleMaxMods = function(vehicle)

  local props = {
	plate 			= 'GRUPPE6',
    modEngine       = 4,
    modBrakes       = 3,
    modTransmission = 3,
    modSuspension   = 3,
    modTurbo        = true,
  }

  ESX.Game.SetVehicleProperties(vehicle, props)
  SetVehicleEngineTorqueMultiplier(vehicle, 2.0)
  ModifyVehicleTopSpeed(vehicle, 50)

end

OpenVehicleSpawnerMenu = function(type, station, part, partNum)
	local playerCoords = GetEntityCoords(PlayerPedId())
	local elements = {}
	if Config.UseCarPack then
		elements = {
			{label = 'Patrol Car', action = 'gruppe1'},
			{label = 'Patrol SUV', action = 'gruppe3'},
			{label = 'Patrol Van', action = 'rumpo3'},
			{label = 'Armor Car', action = 'schafter5'},
			{label = 'Armor SUV', action = 'xls2'},
			{label = 'Speed Patrol', action = 'gruppe2'},
			{label = 'High Class Patrol', action = 'insurgent'},
			{label = 'Classified Patrol', action = 'stockade'},
			{label = 'Valet Used Cars', action = 'delete'}
		}
	else
		elements = {
			{label = 'Patrol Car', action = 'dilettante2'},
			{label = 'Patrol SUV', action = 'contender'},
			{label = 'Patrol Van', action = 'rumpo3'},
			{label = 'Armor Car', action = 'schafter5'},
			{label = 'Armor SUV', action = 'xls2'},
			{label = 'Buggy', action = 'bifta'},
			{label = 'High Class Patrol', action = 'insurgent'},
			{label = 'Classified Patrol', action = 'stockade'},
			{label = 'Valet Used Cars', action = 'delete'}
		}
	end
	
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle', {
		title    = 'Valet',
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
		local foundSpawn, spawnPoint = GetAvailableVehicleSpawnPoint(station, part, partNum)
		
		if data.current.action == 'delete' then
			DeleteSpawnedVehicles()
		else
			local model = GetHashKey(data.current.action)
			if foundSpawn then
				
				ESX.Game.SpawnVehicle(model, spawnPoint.coords, spawnPoint.heading, function(vehicle)
					SetVehicleMaxMods(vehicle)
					ESX.ShowNotification('Vehicle ready')
					table.insert(spawnedVehicles, vehicle)
				end)
			end
		end
	end, function(data, menu)
		menu.close()
	end)
end

OpenVehicleInfoMenu = function(vehicleData)
	ESX.TriggerServerCallback('esx_gruppe6:getVehicleInfos', function(retrivedInfo)
		local elements = {{label = 'plate: %s'.. retrivedInfo.plate}}

		if retrivedInfo.owner == nil then
			table.insert(elements, {label = 'Owner non return'})
		else
			table.insert(elements, {label = 'owner: %s'.. retrivedInfo.owner})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_info', {
			title    = 'Vehicle Information',
			align    = 'top-left',
			elements = elements
		}, nil, function(data, menu)
			menu.close()
		end)
	end, vehicleData.plate)
end

OpenJobSelectionMenu = function()

	local ped = PlayerPedId()

	local elements = {
		{label = 'Low Class Patrol', action = 'low'},
		{label = 'Mid Class Patrol', action = 'mid'},
		{label = 'High Class Patrol', action = 'high'}
	}

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'patrol', {
		title    = 'Check for Patrols',
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
		
		if data.current.action == 'low' then
			if onJob == false then
				TriggerServerEvent('esx_gruppe6:startIntrusion', 'low')
			else
				ESX.ShowNotification('You already have a current job')
			end
		elseif data.current.action == 'mid' then
			if onJob == false then
				TriggerServerEvent('esx_gruppe6:startIntrusion', 'mid')
			else
				ESX.ShowNotification('You already have a current job')
			end
		elseif data.current.action == 'high' then
			if onJob == false then
				TriggerServerEvent('esx_gruppe6:startIntrusion', 'high')
			else
				ESX.ShowNotification('You already have a current job')
			end
		end
	end, function(data, menu)
		menu.close()

		CurrentAction     = 'listing'
		CurrentActionData = {}
	end)
end

GiveUp = function()
	local player = PlayerPedId()
	local plypos = GetEntityCoords(player)
	local offset = GetOffsetFromEntityInWorldCoords(player, 0.0, 1.5, 0.0)
	local handle = StartShapeTestCapsule(plypos.x, plypos.y, plypos.z, offset.x, offset.y, offset.z, 1.0, 12, player, 7)
	local _, _, _, _, intruder = GetShapeTestResult(handle)
	local dict = 'random@mugging3'
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Wait(0)
	end
	if IsEntityAPed(intruder) then
		if IsPedHuman(intruder) then
			if IsPedAPlayer(intruder) == false then
				local ipos = GetEntityCoords(intruder)
				if #(plypos - ipos) < 3 then
					if IsPedInAnyVehicle(intruder) == false then
						if Intruder[1] == nil then
							ClearPedTasksImmediately(intruder)
							SetBlockingOfNonTemporaryEvents(intruder, true)
							SetPedCanRagdoll(intruder, true)
							TaskPlayAnim(intruder, dict, 'handsup_standing_base', 8.0, -8.0, -1, 2, 0.0, 0, 0, 0 )
							RemoveAllPedWeapons(intruder)
							SetPedCanBeDraggedOut(intruder, false)
							hasIntruder = true
							table.insert(Intruder, intruder)
						else
							ESX.ShowNotification('You should deal with one ~r~Intruder~s~ at a time')
						end
					else
						ESX.ShowNotification('The target will not exit the car')
					end
				else
					ESX.ShowNotification('The target is too far')
				end
			else
				ESX.ShowNotification('The target refuses to listen')
			end
		else
			ESX.ShowNotification('Animals are not scared of you')
		end
	end
end

Softcuff = function()
	local player = PlayerPedId()
	local group = GetPedGroupIndex(player)
	local intruder = Intruder[1]
	local plypos = GetEntityCoords(player)
	local intpos = GetEntityCoords(intruder)
	if #(plypos - intpos) < 3 then
		if intruderCuffed == false then
			RequestAnimDict('mp_arresting')
			while not HasAnimDictLoaded('mp_arresting') do
				Citizen.Wait(0)
			end
			TaskPlayAnim(intruder, 'mp_arresting', 'idle', 8.0, -8.0, -1, 2, 0, 0, 0, 0)

			SetEnableHandcuffs(intruder, true)
			DisablePlayerFiring(intruder, true)
			SetPedCanPlayGestureAnims(intruder, false)
			SetPedAsGroupMember(intruder, group)
			intruderCuffed = true
		else
			ClearPedTasks(intruder)
			ClearPedSecondaryTask(intruder)
			SetEnableHandcuffs(intruder, false)
			DisablePlayerFiring(intruder, false)
			SetPedCanPlayGestureAnims(intruder, true)
			intruderCuffed = false
		end
	else
		ESX.ShowNotification('The target is too far from you')
	end
end

OpenSecurityActionsMenu = function()
	ESX.UI.Menu.CloseAll()
	
	local player = PlayerPedId()
	
	ESX.UI.Menu.Open(
	'default', GetCurrentResourceName(), 'security_actions',
	{
		title    = 'Gruppe6',
		align    = 'left',
		elements = {
			{label = 'Security Badge',			value = 'badge'},
			{label = 'Intruder Interaction',	value = 'intruder_interaction'},
			{label = 'Vehicle Interaction',		value = 'vehicle_interaction'},
			{label = 'Object Interaction',		value = 'object_spawner'}
		}
	}, function(data, menu)
		
		if data.current.value == 'badge' then
			local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
			if closestPlayer == -1 or closestDistance > 1.5 then
				ESX.ShowNotification('There is no target')
			else
				local ID = GetPlayerServerId(closestPlayer)
				local dict = 'anim@heists@keycard@'
				RequestAnimDict(dict)
				while not HasAnimDictLoaded(dict) do
					Citizen.Wait(1)
				end
				TaskPlayAnim(player, dict, 'enter', 8.0, 8.0, 1500, 1, 0.0, false, false, false)
				TriggerServerEvent('esx_gruppe6:showBadge', ID)
				Citizen.Wait(1500)
				TaskPlayAnim(player, dict, 'idle_a', 8.0, 8.0, 300, 1, 0.0, false, false, false)
				Citizen.Wait(300)
				TaskPlayAnim(player, dict, 'exit', 8.0, 8.0, 1500, 1, 0.0, false, false, false)
			end
		elseif data.current.value == 'intruder_interaction' then
			
			for i = 1,#Intruder do
				if Intruder[i] ~= nil then
					local elements = {
						{label = 'Softcuff',		action = 'softcuff'},
						{label = 'Escort',			action = 'drag'},
						{label = 'Transport',		action = 'transport'}
					}

					ESX.UI.Menu.Open(
					'default', GetCurrentResourceName(), 'citizen_interaction',
					{
						title    = 'Citizen Interaction',
						align    = 'left',
						elements = elements
					}, function(data2, menu2)
						local action = data2.current.action
						
						if action == 'softcuff' then
							Softcuff()
						elseif action == 'drag' then
							TriggerServerEvent('esx_gruppe6:triggerdrag', player, Intruder[1])
						elseif action == 'transport' then
							TriggerServerEvent('esx_gruppe6:triggertransport')
						end
					end, function(data2, menu2)
						menu2.close()
					end)
				else
					ESX.ShowNotification('There is no intruder')
				end
			end
		elseif data.current.value == 'vehicle_interaction' then
			local player = PlayerPedId()
			local vehicle = ESX.Game.GetVehicleInDirection()

			if DoesEntityExist(vehicle) then

				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_interaction', {
					title    = 'Vehicle Interaction',
					align    = 'top-left',
					elements = {
						{label = 'Check for info', action = 'vehicle_info'},
						{label = 'Call for impound', action = 'impound'}
					}
				}, function(data2, menu2)
					local coords  = GetEntityCoords(player)
					vehicle = ESX.Game.GetVehicleInDirection()
					local action  = data2.current.action

					if DoesEntityExist(vehicle) then
						if action == 'vehicle_infos' then
							local vehicleData = ESX.Game.GetVehicleProperties(vehicle)
							OpenVehicleInfoMenu(vehicleData)
						elseif action == 'impound' then				
							ESX.ShowHelpNotification('Calling for impound')
							TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_STAND_MOBILE_UPRIGHT', 0, true)
							Citizen.Wait(10000)
							ClearPedTasks(player)
							Citizen.Wait(20000) -- sleep the entire script to let stuff sink back to reality
							ImpoundVehicle(vehicle)
						end
					end
				end, function(data2, menu2)
					menu2.close()
				end)
			else
				ESX.ShowNotification('No vehicle nearby')
			end
		elseif data.current.value == 'object_spawner' then
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'object_spawner', {
				title    = 'Object Placement',
				align    = 'top-left',
				elements = {
					{label = 'cone', model = 'prop_roadcone02a'},
					{label = 'barrier', model = 'prop_barrier_work05'}
			}}, function(data2, menu2)
				local player = PlayerPedId()
				local coords    = GetEntityCoords(playerPed)
				local forward   = GetEntityForwardVector(playerPed)
				local x, y, z   = table.unpack(coords + forward * 1.0)

				if data2.current.model == 'prop_roadcone02a' then
					z = z - 2.0
				end

				ESX.Game.SpawnObject(data2.current.model, {x = x, y = y, z = z}, function(obj)
					SetEntityHeading(obj, GetEntityHeading(player))
					PlaceObjectOnGroundProperly(obj)
				end)
			end, function(data2, menu2)
				menu2.close()
			end)
		end
	end, function(data, menu)
		menu.close()
	end)
end

Release = function()
	for i = 1,#Intruder do
		intruder = Intruder[1]
		ClearPedTasks(intruder)
		ClearPedSecondaryTask(intruder)
		SetEnableHandcuffs(intruder, false)
		DisablePlayerFiring(intruder, false)
		SetPedCanPlayGestureAnims(intruder, true)
		DetachEntity(intruder, true, false)
		TaskLeaveAnyVehicle(intruder, 0, 0)
		SetPedConfigFlag(intruder, 292, false)
		RemovePedFromGroup(intruder)
		ResetPedLastVehicle(intruder)
		SetEntityAsNoLongerNeeded(intruder)
		Intruder = {}
		intruderCuffed = false
		intruderGrabbed = false
		intruderInCar = false
	end
end

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job

	Citizen.Wait(5000)
	TriggerServerEvent('esx_gruppe6:forceBlip')
end)

AddEventHandler('esx_gruppe6:hasEnteredMarker', function(station, part, partNum)
	if part == 'Enter' then
		CurrentAction     = 'enter'
		CurrentActionMsg  = 'press ~INPUT_CONTEXT~ to access the ~g~Office~s~.'
		CurrentActionData = {}
	elseif part == 'Leave' then
		CurrentAction     = 'leave'
		CurrentActionMsg  = 'press ~INPUT_CONTEXT~ to exit the ~g~Office~s~.'
		CurrentActionData = {}
	elseif part == 'Listing' then
		CurrentAction     = 'listing'
		CurrentActionMsg  = 'press ~INPUT_CONTEXT~ to check for ~g~Listing~s~.'
		CurrentActionData = {}
	elseif part == 'Cloakroom' then
		CurrentAction     = 'menu_cloakroom'
		CurrentActionMsg  = 'press ~INPUT_CONTEXT~ to access the ~g~Cloakroom~s~.'
		CurrentActionData = {}
	elseif part == 'Armory' then
		CurrentAction     = 'menu_armory'
		CurrentActionMsg  = 'press ~INPUT_CONTEXT~ to access the ~r~Armory~s~.'
		CurrentActionData = {station = station}
	elseif part == 'Vehicles' then
		CurrentAction     = 'menu_vehicle_spawner'
		CurrentActionMsg  = 'press ~INPUT_CONTEXT~ to access the ~y~Vehicle Actions~s~.'
		CurrentActionData = {station = station, part = part, partNum = partNum}
	elseif part == 'BossActions' then
		CurrentAction     = 'menu_boss_actions'
		CurrentActionMsg  = 'press ~INPUT_CONTEXT~ to access the ~b~Boss Actions~s~.'
		CurrentActionData = {}
	end
end)

AddEventHandler('esx_gruppe6:hasExitedMarker', function(station, part, partNum)
	if not isInShopMenu then
		ESX.UI.Menu.CloseAll()
	end

	CurrentAction = nil
end)

AddEventHandler('esx_gruppe6:hasEnteredEntityZone', function(entity)
	local playerPed = PlayerPedId()

	if PlayerData.job and PlayerData.job.name == 'security' and IsPedOnFoot(playerPed) then
		CurrentAction     = 'remove_entity'
		CurrentActionMsg  = 'press ~INPUT_CONTEXT~ to delete the object'
		CurrentActionData = {entity = entity}
	end
end)

AddEventHandler('esx_gruppe6:hasExitedEntityZone', function(entity)
	if CurrentAction == 'remove_entity' then
		CurrentAction = nil
	end
end)

RegisterNetEvent('esx_gruppe6:drag')
AddEventHandler('esx_gruppe6:drag', function(source, intruder)
	local player = PlayerPedId()
	local group = GetPedGroupIndex(player)
	local plypos = GetEntityCoords(player)
	local ipos = GetEntityCoords(intruder)
	
	if #(plypos - ipos) < 3 then
		if intruderCuffed == false then
			ESX.ShowNotification('You should ~r~Cuff~s~ the ~r~Intruder~s~ before attempting to grab them')
		elseif intruderInCar == false then
			if intruderGrabbed == false then
				AttachEntityToEntity(intruder, player, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
				intruderGrabbed = true
			else
				Release()
			end
		else
			SetPedConfigFlag(intruder, 292, false)
			Citizen.Wait(2000)
			TaskLeaveAnyVehicle(intruder, 0, 0)
			intruderInCar = false
			Citizen.Wait(2000)
			SetPedAsGroupMember(intruder, group)
			AttachEntityToEntity(intruder, player, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
			intruderGrabbed = true
		end
	else
		ESX.ShowNotification('You are too far from the target')
	end
end)

RegisterNetEvent('esx_gruppe6:transport')
AddEventHandler('esx_gruppe6:transport', function()
	local player = PlayerPedId()
	local coords = GetEntityCoords(player)
	local intruder = Intruder[1]
	if intruderInCar == false then
		if intruderGrabbed == false then
			ESX.ShowNotification('The civilian refuses to walk to the car themself')
		else
			if IsAnyVehicleNearPoint(coords, 3.0) then
				local vehicle = GetClosestVehicle(coords, 3.0, 0, 70)

				if DoesEntityExist(vehicle) then
					RemovePedFromGroup(intruder)
					if IsVehicleSeatFree(vehicle, -1) == false then
						local driver = GetPedInVehicleSeat(vehicle, -1)
						local group = GetPedGroupIndex(driver)
						SetPedAsGroupMember(intruder, group)
					end
					DetachEntity(intruder, true, false)
					TaskEnterVehicle(intruder, vehicle, 5000, 2, 1.0, 1, 0)
					intruderGrabbed = false
					intruderInCar = true
					Citizen.Wait(5000)
					SetPedConfigFlag(intruder, 292, true)
				end
			else
				ESX.ShowNotification('You must be closer to the car')
			end
		end
	else
		ESX.ShowNotification('You should probably ~g~Grab~s~ the ~r~Intruder~s~ from the vehicle')
	end
end)

RegisterNetEvent('esx_gruppe6:tele')
AddEventHandler('esx_gruppe6:tele', function(door)
	local ped = PlayerPedId()
	for k,v in pairs(Config.SecurityStations) do
			
		if door == 'enter' then
			for i=1, #v.Elevator, 1 do
				SetEntityCoords(ped, v.Elevator[i], 0.0, 0.0, 0.0, 1)
				SetEntityHeading(ped, 70.33)
			end
		elseif door == 'leave' then
			for i=1, #v.FrontDoor, 1 do
				SetEntityCoords(ped, v.FrontDoor[i], 0.0, 0.0, 0.0, 1)
				SetEntityHeading(ped, 291.33)
			end
		end
	end
end)

-- Create blips
Citizen.CreateThread(function()

	for k,v in pairs(Config.SecurityStations) do
		local blip = AddBlipForCoord(v.Blip.Coords)

		SetBlipSprite (blip, v.Blip.Sprite)
		SetBlipDisplay(blip, v.Blip.Display)
		SetBlipScale  (blip, v.Blip.Scale)
		SetBlipColour (blip, v.Blip.Colour)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName('STRING')
		AddTextComponentString('Gruppe6')
		EndTextCommandSetBlipName(blip)
	end
end)

-- Display markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if PlayerData.job and PlayerData.job.name == 'security' then

			local player = PlayerPedId()
			local coords    = GetEntityCoords(player)
			local isInMarker, hasExited, letSleep = false, false, true
			local currentStation, currentPart, currentPartNum

			for k,v in pairs(Config.SecurityStations) do
			
				for i=1, #v.FrontDoor, 1 do
					local distance = GetDistanceBetweenCoords(coords, v.FrontDoor[i], true)
					
					if distance < Config.DrawDistance then
						DrawMarker(20, v.FrontDoor[i], 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
						letSleep = false
					end

					if distance < Config.MarkerSize.x then
						isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Enter', i
					end
				end
				
				for i=1, #v.Elevator, 1 do
					local distance = GetDistanceBetweenCoords(coords, v.Elevator[i], true)
					
					if distance < Config.DrawDistance then
						DrawMarker(20, v.Elevator[i], 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
						letSleep = false
					end

					if distance < Config.MarkerSize.x then
						isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Leave', i
					end
				end
				
				for i=1, #v.Listing, 1 do
					local distance = GetDistanceBetweenCoords(coords, v.Listing[i], true)
					
					if distance < Config.DrawDistance then
						DrawMarker(20, v.Listing[i], 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
						letSleep = false
					end

					if distance < Config.MarkerSize.x then
						isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Listing', i
					end
				end
				
				for i=1, #v.Cloakrooms, 1 do
					local distance = GetDistanceBetweenCoords(coords, v.Cloakrooms[i], true)

					if distance < Config.DrawDistance then
						DrawMarker(20, v.Cloakrooms[i], 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
						letSleep = false
					end

					if distance < Config.MarkerSize.x then
						isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Cloakroom', i
					end
				end

				for i=1, #v.Armories, 1 do
					local distance = GetDistanceBetweenCoords(coords, v.Armories[i], true)

					if distance < Config.DrawDistance then
						DrawMarker(21, v.Armories[i], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
						letSleep = false
					end

					if distance < Config.MarkerSize.x then
						isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Armory', i
					end
				end

				for i=1, #v.Vehicles, 1 do
					local distance = GetDistanceBetweenCoords(coords, v.Vehicles[i].Spawner, true)

					if distance < Config.DrawDistance then
						DrawMarker(36, v.Vehicles[i].Spawner, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
						letSleep = false
					end

					if distance < Config.MarkerSize.x then
						isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Vehicles', i
					end
				end

				if Config.EnablePlayerManagement and PlayerData.job.grade_name == 'boss' then
					for i=1, #v.BossActions, 1 do
						local distance = GetDistanceBetweenCoords(coords, v.BossActions[i], true)

						if distance < Config.DrawDistance then
							DrawMarker(22, v.BossActions[i], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
							letSleep = false
						end

						if distance < Config.MarkerSize.x then
							isInMarker, currentStation, currentPart, currentPartNum = true, k, 'BossActions', i
						end
					end
				end
			end

			if isInMarker and not HasAlreadyEnteredMarker or (isInMarker and (LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum)) then
				if
					(LastStation and LastPart and LastPartNum) and
					(LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum)
				then
					TriggerEvent('esx_gruppe6:hasExitedMarker', LastStation, LastPart, LastPartNum)
					hasExited = true
				end

				HasAlreadyEnteredMarker = true
				LastStation             = currentStation
				LastPart                = currentPart
				LastPartNum             = currentPartNum

				TriggerEvent('esx_gruppe6:hasEnteredMarker', currentStation, currentPart, currentPartNum)
			end

			if not hasExited and not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('esx_gruppe6:hasExitedMarker', LastStation, LastPart, LastPartNum)
			end

			if letSleep then
				Citizen.Wait(500)
			end
			
		else
			Citizen.Wait(500)
		end
	end
end)

-- Enter / Exit entity zone events
Citizen.CreateThread(function()
	local trackedEntities = {
		'prop_roadcone02a',
		'prop_barrier_work05',
		'p_ld_stinger_s',
		'prop_boxpile_07d',
		'hei_prop_cash_crate_half_full'
	}

	while true do
		Citizen.Wait(500)

		local player	 = PlayerPedId()
		local coords     = GetEntityCoords(player)

		local closestDistance = -1
		local closestEntity   = nil

		for i=1, #trackedEntities, 1 do
			local object = GetClosestObjectOfType(coords, 3.0, GetHashKey(trackedEntities[i]), false, false, false)

			if DoesEntityExist(object) then
				local objCoords = GetEntityCoords(object)
				local distance  = GetDistanceBetweenCoords(coords, objCoords, true)

				if closestDistance == -1 or closestDistance > distance then
					closestDistance = distance
					closestEntity   = object
				end
			end
		end

		if closestDistance ~= -1 and closestDistance <= 3.0 then
			if LastEntity ~= closestEntity then
				TriggerEvent('esx_gruppe6:hasEnteredEntityZone', closestEntity)
				LastEntity = closestEntity
			end
		else
			if LastEntity then
				TriggerEvent('esx_gruppe6:hasExitedEntityZone', LastEntity)
				LastEntity = nil
			end
		end
	end
end)

-- Key Controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		
		if CurrentAction then
			ESX.ShowHelpNotification(CurrentActionMsg)

			if IsControlJustReleased(0, 38) and PlayerData.job and PlayerData.job.name == 'security' then
				
				if CurrentAction == 'enter' then
					TriggerEvent('esx_gruppe6:tele', 'enter')
				elseif CurrentAction == 'leave' then
					TriggerEvent('esx_gruppe6:tele', 'leave')
				elseif CurrentAction == 'listing' then
					OpenJobSelectionMenu()
				elseif CurrentAction == 'menu_cloakroom' then
					OpenCloakroomMenu()
				elseif CurrentAction == 'menu_armory' then
					OpenArmoryMenu(CurrentActionData.station)
				elseif CurrentAction == 'menu_vehicle_spawner' then
					OpenVehicleSpawnerMenu('car', CurrentActionData.station, CurrentActionData.part, CurrentActionData.partNum)
				elseif CurrentAction == 'delete_vehicle' then
					ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
				elseif CurrentAction == 'menu_boss_actions' then
					ESX.UI.Menu.CloseAll()
					TriggerEvent('esx_society:openBossMenu', 'security', function(data, menu)
						menu.close()

						CurrentAction     = 'menu_boss_actions'
						CurrentActionData = {}
					end, { wash = false }) -- disable washing money
				elseif CurrentAction == 'remove_entity' then
					DeleteEntity(CurrentActionData.entity)
				end

				CurrentAction = nil
			end
		end -- CurrentAction end

		if IsControlJustReleased(0, 167) and not isDead and PlayerData.job and PlayerData.job.name == 'security' and not ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), 'security_actions') then
			OpenSecurityActionsMenu()
		end
		
		if IsControlPressed(0, 32) and IsControlJustReleased(0, 46) and not isDead and PlayerData.job and PlayerData.job.name == 'security' then
			GiveUp()
		end
		
		if IsControlPressed(0, 33) and IsControlJustReleased(0, 46) and not isDead and PlayerData.job and PlayerData.job.name == 'security' then
			Release()
		end
	end
end)

CheckTime = function(ped, x, y, z, level, blip)
	local JobTimer = 300000
	while true do
		Citizen.Wait(1000)
		JobTimer = JobTimer - 1000
		local pos = GetEntityCoords(ped)
		local dis = GetDistanceBetweenCoords(pos, x, y, z, true)
		if dis > 50 then
			local ply = PlayerPedId()
			local loc = GetEntityCoords(ply)
			local ran = GetDistanceBetweenCoords(loc, pos, true)
			if ran < 5 then
				Citizen.Wait(20000) -- 20 second wait to decrease chance of deleting ped in hands(can still happen js)
				TriggerServerEvent('esx_gruppe6:jobPay', level, (JobTimer / 1000))
				onJob = false
				DeleteEntity(ped)
				Intruder = {}
				RemoveBlip(blip)
				break
			end
		end
		if JobTimer < 1 then
			ESX.ShowNotification('You have not satisfied the customer')
			onJob = false
			DeleteEntity(ped)
			Intruder = {}
			RemoveBlip(blip)
			break
		end
	end
end
		

RegisterNetEvent('esx_gruppe6:runTask')
AddEventHandler('esx_gruppe6:runTask', function(location, level, blip)
	onJob = true
	local ped = PlayerPedId()
	local x,y,z = table.unpack(location)
	local xMod = math.random(-20, 20)
	local yMod = math.random(-20, 20)
	local randomPed = {}
	local randomScenario = {}
	table.insert(randomPed, Config.Peds[math.random(1,#Config.Peds)])
	table.insert(randomScenario, Config.Scenarios[math.random(1,#Config.Scenarios)])
	local dict = 'mp_safehousevagos@boss'
	local prop = 'prop_off_chair_01'
	RequestModel(randomPed[1])
	RequestAnimDict(dict)
	RequestModel(prop)
	while (not HasModelLoaded(randomPed[1])) or (not HasModelLoaded(prop)) or (not HasAnimDictLoaded(dict)) do
		Citizen.Wait(1)
	end
	for k,v in pairs(Config.SecurityStations) do
		for i = 1,#v.Listing do
			SetEntityCoords(ped, v.Listing[i].x, v.Listing[i].y, v.Listing[i].z - 0.5, 0.0, 0.0, 0.0, true)
			SetEntityHeading(ped, 155.88)
			local chair = CreateObject(GetHashKey(prop), v.Listing[i].x, v.Listing[i].y, v.Listing[i].z - 0.5, true, true, true)
			AttachEntityToEntity(chair, ped, GetPedBoneIndex(ped, 'SKEL_Pelvis'), 0.0, 0.0, -1.0, 0.0, 0.0, 180.0, false, false, false, false, 2, true)
			TaskPlayAnim(ped, dict, 'vagos_boss_keyboard_a', 8.0, -8.0, -1, 2, 0.0, 0, 0, 0 )
			Citizen.Wait(10000)
			DeleteEntity(chair)
			ClearPedTasks(ped)
		end
	end
	SetNewWaypoint(x, y)
	ESX.ShowNotification('A waypoint has been sent to your gps')
	if level == 'low' then
		local chance = math.random(1, 5)
		if chance > 2 then
			local AIintruder = CreatePed(1, randomPed[1], x + xMod, y + yMod, z - 1, 0.0, true, true)
			SetEntityAsMissionEntity(AIintruder, true, true)
			SetBlockingOfNonTemporaryEvents(AIintruder, true)
			SetPedCanRagdoll(AIintruder, true)
			TaskStartScenarioInPlace(AIintruder, randomScenario[i], 0, true)
			CheckTime(AIintruder, x, y, z, 'low', blip)
		else
			Citizen.Wait(300000)
			TriggerServerEvent('esx_gruppe6:jobPay', 'low')
			RemoveBlip(blip)
		end
	elseif level == 'mid' then
		local AIintruder = CreatePed(1, randomPed[1], x + xMod, y + yMod, z - 1, 0.0, true, true)
		SetEntityAsMissionEntity(AIintruder, true, true)
		SetBlockingOfNonTemporaryEvents(AIintruder, true)
		SetPedCanRagdoll(AIintruder, true)
		TaskStartScenarioInPlace(AIintruder, randomScenario[1], 0, true)
		CheckTime(AIintruder, x, y, z, 'mid', blip)
	elseif level == 'high' then
		local AIintruder = CreatePed(1, randomPed[1], x + xMod, y + yMod, z - 1, 0.0, true, true)
		SetEntityAsMissionEntity(AIintruder, true, true)
		SetBlockingOfNonTemporaryEvents(AIintruder, true)
		SetPedCanRagdoll(AIintruder, true)
		TaskStartScenarioInPlace(AIintruder, randomScenario[1], 0, true)
		local chance = math.random(1, 10)
		if chance >= 7 then
			SetEntityInvincible(AIintruder, true)
			SetPedCanRagdoll(intruder, false)
			TaskCombatPed(AIintruder, ped, 0, 16)
		end
		CheckTime(AIintruder, x, y, z, 'high', blip)
	end
end)

RegisterNetEvent('esx_gruppe6:startIntruder')
AddEventHandler('esx_gruppe6:startIntruder', function(level)
	local randomZone = {}
	table.insert(randomZone, Config.PatrolZones[math.random(1, #Config.PatrolZones)])
	local coords = randomZone[1]
	local blip = AddBlipForRadius(coords, 50.0)
	SetBlipColour(blip, 1)
	SetBlipAlpha(blip, 128)

	BeginTextCommandSetBlipName('STRING')
	AddTextComponentString('Intruder Call')
	EndTextCommandSetBlipName(blip)
	TriggerServerEvent('esx_gruppe6:runTask', coords, level, blip)
end)

OpenBadgeMenu = function(target)

	ESX.TriggerServerCallback('esx_gruppe6:getOtherPlayerData', function(data)
		local elements = {}
		local nameLabel = 'Name'.. ' '.. data.firstname .. ' ' .. data.lastname
		local jobLabel, sexLabel, dobLabel, heightLabel, idLabel

		if data.job.grade_label and  data.job.grade_label ~= '' then
			jobLabel = 'Job'.. ' '.. data.job.label .. ' - ' .. data.job.grade_label
		else
			jobLabel = 'Job'.. ' '.. data.job.label
		end

		

		if data.sex then
			if string.lower(data.sex) == 'm' then
				sexLabel = 'Sex'.. ' male'
			else
				sexLabel = 'Sex'.. ' female'
			end
		else
			sexLabel = 'Sex'.. ' unknown'
		end

		if data.dob then
			dobLabel = 'DOB'.. ' '.. data.dob
		else
			dobLabel = 'DOB'.. ' unknown'
		end

		if data.height then
			heightLabel = 'Height'.. ' '.. data.height
		else
			heightLabel = 'Height'.. 'unknown'
		end

		local elements = {
			{label = nameLabel},
			{label = jobLabel},
			{label = sexLabel},
			{label = dobLabel},
			{label = heightLabel}
		}

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'badge', {
			title    = 'Badge',
			align    = 'top-left',
			elements = elements
		}, nil, function(data, menu)
			menu.close()
		end)
	end, target)
end

RegisterNetEvent('esx_gruppe6:showBadge')
AddEventHandler('esx_gruppe6:showBadge', function(target)
	OpenBadgeMenu(target)
end)

-- Create blip for colleagues
createBlip = function(id)
	local ped = GetPlayerPed(id)
	local blip = GetBlipFromEntity(ped)

	if not DoesBlipExist(blip) then -- Add blip and create head display on player
		blip = AddBlipForEntity(ped)
		SetBlipSprite(blip, 1)
		ShowHeadingIndicatorOnBlip(blip, true) -- Player Blip indicator
		SetBlipRotation(blip, math.ceil(GetEntityHeading(ped))) -- update rotation
		SetBlipNameToPlayerName(blip, id) -- update blip name
		SetBlipScale(blip, 0.85) -- set scale
		SetBlipAsShortRange(blip, true)

		table.insert(blipsGruppe, blip) -- add blip to array so we can remove it later
	end
end

RegisterNetEvent('esx_gruppe6:updateBlip')
AddEventHandler('esx_gruppe6:updateBlip', function()

	-- Refresh all blips
	for k, existingBlip in pairs(blipsGruppe) do
		RemoveBlip(existingBlip)
	end

	-- Clean the blip table
	blipsGruppe = {}

	if not Config.EnableJobBlip then
		return
	end

	-- Is the player a gruppe6? In that case show all the blips for other gruppe6s
	if PlayerData.job and PlayerData.job.name == 'security' then
		ESX.TriggerServerCallback('esx_society:getOnlinePlayers', function(players)
			for i=1, #players, 1 do
				if players[i].job.name == 'security' then
					local id = GetPlayerFromServerId(players[i].source)
					if NetworkIsPlayerActive(id) and GetPlayerPed(id) ~= PlayerPedId() then
						createBlip(id)
					end
				end
			end
		end)
	end

end)

AddEventHandler('playerSpawned', function(spawn)
	isDead = false
	
	if not hasAlreadyJoined then
		TriggerServerEvent('esx_gruppe6:spawned')
	end
	hasAlreadyJoined = true
end)

AddEventHandler('esx:onPlayerDeath', function(data)
	isDead = true
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		ESX.UI.Menu.CloseAll()
		Release()
	end
end)
