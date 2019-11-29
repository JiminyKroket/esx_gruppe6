ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

TriggerEvent('esx_society:registerSociety', 'security', 'Gruppe6', 'society_security', 'society_security', 'society_security', {type = 'public'})

RegisterServerEvent('esx_gruppe6:startIntrusion')
AddEventHandler('esx_gruppe6:startIntrusion', function(level)
	TriggerClientEvent('esx_gruppe6:startIntruder', source, level)
end)

RegisterServerEvent('esx_gruppe6:runTask')
AddEventHandler('esx_gruppe6:runTask', function(coords, level, blip)
	TriggerClientEvent('esx_gruppe6:runTask', source, coords, level, blip)
end)

RegisterServerEvent('esx_gruppe6:jobPay')
AddEventHandler('esx_gruppe6:jobPay', function(level, extra)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	
	if xPlayer.job.name == 'security' then
		local low = Config.LowPayout
		local mid = Config.MidPayout
		local hi  = Config.HighPayout
		if level == 'low' then
			TriggerClientEvent('esx:showNotification', _source, 'You have satisfied this contract, please accept your payment of $ '.. (low + extra))
			xPlayer.addBank(low + extra)
			TriggerEvent('esx_addonaccount:getSharedAccount', 'society_security', function(account)
				account.addMoney(low * 2 + extra)
			end)
		elseif level == 'mid' then
			TriggerClientEvent('esx:showNotification', _source, 'You have satisfied this contract, please accept your payment of $ '.. (mid + extra))
			xPlayer.addBank(mid + extra)
			TriggerEvent('esx_addonaccount:getSharedAccount', 'society_security', function(account)
				account.addMoney(mid * 2 + extra)
			end)
		elseif level == 'high' then
			TriggerClientEvent('esx:showNotification', _source, 'You have satisfied this contract, please accept your payment of $ '.. (hi + extra))
			xPlayer.addBank(hi + extra)
			TriggerEvent('esx_addonaccount:getSharedAccount', 'society_security', function(account)
				account.addMoney(hi * 2 + extra)
			end)
		else
			print(('esx_gruppe6: %s attempted to perform an invalid payout (security)!'):format(xPlayer.identifier))
		end
	else
		print(('esx_gruppe6: %s attempted to perform an invalid payout (not security)!'):format(xPlayer.identifier))
	end
	local start = nil
end)

RegisterServerEvent('esx_gruppe6:triggercuff')
AddEventHandler('esx_gruppe6:triggercuff', function()
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'security' then
		TriggerClientEvent('esx_gruppe6:softcuff', source)
	else
		print(('esx_gruppe6: %s attempted to handcuff a player (not security)!'):format(xPlayer.identifier))
	end
end)

RegisterServerEvent('esx_gruppe6:triggerdrag')
AddEventHandler('esx_gruppe6:triggerdrag', function(player, target)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'security' then
		TriggerClientEvent('esx_gruppe6:drag', source, player, target)
	else
		print(('esx_gruppe6: %s attempted to drag (not security)!'):format(xPlayer.identifier))
	end
end)

RegisterServerEvent('esx_gruppe6:triggertransport')
AddEventHandler('esx_gruppe6:triggertransport', function()
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'security' then
		TriggerClientEvent('esx_gruppe6:transport', source)
	else
		print(('esx_gruppe6: %s attempted to put in vehicle (not security)!'):format(xPlayer.identifier))
	end
end)

RegisterServerEvent('esx_gruppe6:showBadge')
AddEventHandler('esx_gruppe6:showBadge', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(target)
	
	if xPlayer.job.name == 'security' then
		TriggerClientEvent('esx_gruppe6:showBadge', xTarget.source, source)
	else
		print(('esx_gruppe6: %s attempted to show badge (not security)!'):format(xPlayer.identifier))
	end
end)

ESX.RegisterServerCallback('esx_gruppe6:getOtherPlayerData', function(source, cb, target)
	if Config.EnableESXIdentity then
		local xPlayer = ESX.GetPlayerFromId(target)
		local result = MySQL.Sync.fetchAll('SELECT firstname, lastname, sex, dateofbirth, height FROM users WHERE identifier = @identifier', {
			['@identifier'] = xPlayer.identifier
		})

		local firstname = result[1].firstname
		local lastname  = result[1].lastname
		local sex       = result[1].sex
		local dob       = result[1].dateofbirth
		local height    = result[1].height

		local data = {
			name      = GetPlayerName(target),
			job       = xPlayer.job,
			firstname = firstname,
			lastname  = lastname,
			sex       = sex,
			dob       = dob,
			height    = height
		}
		cb(data)
	else
		local xPlayer = ESX.GetPlayerFromId(target)

		local data = {
			name       = GetPlayerName(target),
			job        = xPlayer.job,
		}

		cb(data)
	end
end)

ESX.RegisterServerCallback('esx_gruppe6:getVehicleInfos', function(source, cb, plate)

	MySQL.Async.fetchAll('SELECT owner FROM owned_vehicles WHERE plate = @plate', {
		['@plate'] = plate
	}, function(result)

		local retrivedInfo = {
			plate = plate
		}

		if result[1] then
			MySQL.Async.fetchAll('SELECT name, firstname, lastname FROM users WHERE identifier = @identifier',  {
				['@identifier'] = result[1].owner
			}, function(result2)

				if Config.EnableESXIdentity then
					retrivedInfo.owner = result2[1].firstname .. ' ' .. result2[1].lastname
				else
					retrivedInfo.owner = result2[1].name
				end

				cb(retrivedInfo)
			end)
		else
			cb(retrivedInfo)
		end
	end)
end)

AddEventHandler('playerDropped', function()
	-- Save the source in case we lose it (which happens a lot)
	local _source = source

	-- Did the player ever join?
	if _source ~= nil then
		local xPlayer = ESX.GetPlayerFromId(_source)

		-- Is it worth telling all clients to refresh?
		if xPlayer ~= nil and xPlayer.job ~= nil and xPlayer.job.name == 'security' then
			Citizen.Wait(5000)
			TriggerClientEvent('esx_gruppe6:updateBlip', -1)
		end
	end
end)

RegisterServerEvent('esx_gruppe6:spawned')
AddEventHandler('esx_gruppe6:spawned', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	if xPlayer ~= nil and xPlayer.job ~= nil and xPlayer.job.name == 'security' then
		Citizen.Wait(5000)
		TriggerClientEvent('esx_gruppe6:updateBlip', -1)
	end
end)

RegisterServerEvent('esx_gruppe6:forceBlip')
AddEventHandler('esx_gruppe6:forceBlip', function()
	TriggerClientEvent('esx_gruppe6:updateBlip', -1)
end)

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Citizen.Wait(5000)
		TriggerClientEvent('esx_gruppe6:updateBlip', -1)
	end
end)

RegisterServerEvent('esx_gruppe6:giveItem')
AddEventHandler('esx_gruppe6:giveItem', function(itemName)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name ~= 'security' then
		print(('esx_gruppe6: %s attempted to spawn in an item!'):format(xPlayer.identifier))
		return
	end

	local xItem = xPlayer.getInventoryItem(itemName)
	local count = 1

	if xItem.limit ~= -1 then
		count = xItem.limit - xItem.count
	end

	if xItem.count < xItem.limit then
		xPlayer.addInventoryItem(itemName, count)
	else
		TriggerClientEvent('esx:showNotification', source, 'You are already full')
	end
end)
