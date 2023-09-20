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
		if thePlayer.job.name == 'carshop' then
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
