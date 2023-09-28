ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


ESX.RegisterServerCallback('mus_catalogue:recuperercategorievehicule', function(source, cb)
    local catevehi = {}

    MySQL.Async.fetchAll('SELECT * FROM vehicle_categories', {}, function(result)
        for i = 1, #result, 1 do
            table.insert(catevehi, {
                name = result[i].name,
                label = result[i].label
            })
        end

        cb(catevehi)
    end)
end)

ESX.RegisterServerCallback('mus_catalogue:recupererlistevehicule', function(source, cb, categorievehi)
    local catevehi = categorievehi
    local listevehi = {}

    MySQL.Async.fetchAll('SELECT * FROM vehicles WHERE category = @category', {
        ['@category'] = catevehi
    }, function(result)
        for i = 1, #result, 1 do
            table.insert(listevehi, {
                name = result[i].name,
                model = result[i].model,
                price = result[i].price
            })
        end

        cb(listevehi)
    end)
end)

RegisterServerEvent('Appel:concess')
AddEventHandler('Appel:concess', function()
    
	local xPlayers = ESX.GetPlayers()
	for i = 1, #xPlayers, 1 do
		local thePlayer = ESX.GetPlayerFromId(xPlayers[i])
		if thePlayer.job.name == catalogue.job then
		TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], 'Concessionaire', '~r~Accueil', 'Un concessionaire est appelé à l\'accueil !', 'CHAR_CARDEALER', 8)
        end
    end
end)

DiscordWebHook = function(Name, Title, Description, Image, Webhook)
    if Image == nil then
        Image = Webhook.Image
    end
	local Content = {
	        {
	            ["color"] = 3447003,
	            ["title"] = Title,
	            ["description"] = Description,
                ["image"] = {
                    ["url"] = Image,
                },
		        ["footer"] = {
	            ["text"] = "Catalogue | By XenityDev",
	            ["icon_url"] = "",
	            },
	        }
	    }
	PerformHttpRequest(Webhook, function(err, text, headers) end, 'POST', json.encode({username = Name, embeds = Content}), { ['Content-Type'] = 'application/json' })
end

RegisterNetEvent('Mus:webhook')
AddEventHandler('Mus:webhook', function(Name, Title, Description, Image, Webhook)
    DiscordWebHook(Name, Title, Description, Image, Webhook)
end)

RegisterNetEvent('Mus:cardealer:AddCar')
AddEventHandler('Mus:cardealer:AddCar', function(hash, name, price, category)
    local xPlayer = ESX.GetPlayerFromId(source)

    -- Vérifier si le modèle existe déjà dans la base de données
    MySQL.Async.fetchScalar('SELECT COUNT(*) FROM vehicles WHERE model = @model', {
        ['@model'] = hash
    }, function(result)
        local count = tonumber(result)

        -- Si le modèle existe déjà, renvoyer une notification au client
        if count > 0 then
            TriggerClientEvent('esx:showNotification', xPlayer.source, 'Cette voiture existe déjà dans le catalogue.')
        else
            -- Si le modèle n'existe pas encore, l'ajouter à la base de données
            MySQL.Async.execute('INSERT INTO vehicles (name, model, price, category) VALUES (@name, @model, @price, @category)', {
                ['@name'] = name,
                ['@model'] = hash,
                ['@price'] = price,
                ['@category'] = category
            }, function(rowsChange)
                TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, 'PDM', 'Ajout', 'Vous venez d\'ajouter ~o~' .. name .. ' dans le catalogue', 'CHAR_CONCESSIONNAIRE', 0)
            end)
        end
    end)
end)

RegisterNetEvent('Mus:cardealer:RemoveCar')
AddEventHandler('Mus:cardealer:RemoveCar', function(model)
    local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.Async.execute('DELETE FROM vehicles WHERE model = @model', {
        ['@model'] = model
    }, function(rowsDeleted)
        TriggerClientEvent('esx:showNotification', xPlayer.source, 'Vous venez de supprimer : ' .. model)
    end)
end)

RegisterNetEvent('Mus:cardealer:ChangePrice')
AddEventHandler('Mus:cardealer:ChangePrice', function(model, price)
    local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.Async.execute('UPDATE vehicles SET price = @price WHERE model = @model', {
        ['@price'] = price,
        ['@model'] = model
    }, function(rowsChanged)
        TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, "PDM", 'Changement Prix', "Vous venez de changer le prix de ~o~" .. model .. "~s~ pour ~g~" .. price .. "$", "CHAR_CONCESSIONNAIRE", 0)
    end)
end)
