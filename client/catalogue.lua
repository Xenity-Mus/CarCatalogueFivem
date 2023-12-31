if catalogue.framework == "ESX" then 
    ESX = exports['es_extended']:getSharedObject()
elseif catalogue.framework == "ESXOLD" then
    ESX = nil
    Citizen.CreateThread(function()
        while ESX == nil do
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
            Citizen.Wait(100)
        end
    end)
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)


RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

local playerCars = {}

mus_conc = {
	catevehi = {},
	listecatevehi = {},
    List = 1,
    List2 = 1,
    List3 = 1,
    List4 = 1,
    List5 = 1,
    List6 = 1,
    List7 = 1,
    List8 = 1,
    List9 = 1,
    IndexColor = {1,1,1}
}



local derniervoituresorti = {}
local sortirvoitureacheter = {}
local CurrentAction, CurrentActionMsg, LastZone, currentDisplayVehicle, CurrentVehicleData
local CurrentActionData, Vehicles, Categories = {}, {}, {}

inview = false

function CatalogueMenu()
    local catalogueee = RageUI.CreateMenu("", "Véhicules")
    local vehiclemenu = RageUI.CreateSubMenu(catalogueee, "", "Catégorie véhicule")
    local vehiclemenuparam = RageUI.CreateSubMenu(vehiclemenu, "", "Options")
    local mangcat = RageUI.CreateSubMenu(catalogueee, "", "Selectionner le véhicule")
    local managecat = RageUI.CreateSubMenu(mangcat, "", "Que voulez vous faire ?")
    local gestion = RageUI.CreateSubMenu(managecat, "", "Que voulez vous faire ?")

    catalogueee.Closed = function()
        supprimervehiculecata()
    end
    vehiclemenu.Closed = function()
        supprimervehiculecata()
    end
    vehiclemenuparam.Closed = function()
        supprimervehiculecata()
    end

    RageUI.Visible(catalogueee, not RageUI.Visible(catalogueee))

    while catalogueee do
        Citizen.Wait(0)
        RageUI.IsVisible(catalogueee, true, true, true, function()

            RageUI.ButtonWithStyle("Appel Un Concessionaire a l'accueil", nil, { RightLabel = "→→" }, not codesCooldown455, function(_, _, s)
                if s then
                    codesCooldown455 = true 
                    TriggerServerEvent('Appel:concess')
                    ESX.ShowNotification('~r~Votre message a bien été envoyé aux concessionaires.')
                    TriggerServerEvent('Mus:webhook', 'Concessionaire Los Santos', 'Catalogue', 'Le Joueur : ' .. GetPlayerName(PlayerId()) .. ' a fait un appel afin de prendre contact avec un vendeur du concessionaire.', nil, Webhook.Link)
                    Citizen.SetTimeout(5000, function() codesCooldown455 = false end)
                end 
            end)

            if ESX.PlayerData.job and ESX.PlayerData.job.name == catalogue.job then
                -- Vérifie si le joueur a le rôle "cardealer"
                RageUI.Separator('↓ ~r~Action Concessionaire~s~ ↓')
                RageUI.ButtonWithStyle('Gérer le catalogue', nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                end, mangcat)
            end

			RageUI.Line()
		
            for i = 1, #mus_conc.catevehi, 1 do
            RageUI.ButtonWithStyle("Catégorie - "..mus_conc.catevehi[i].label, nil, {RightLabel = "→→"},true, function(Hovered, Active, Selected)
                if (Selected) then
                        nomcategorie = mus_conc.catevehi[i].label
                        categorievehi = mus_conc.catevehi[i].name
                        ESX.TriggerServerCallback('mus_catalogue:recupererlistevehicule', function(listevehi)
                                mus_conc.listecatevehi = listevehi
                        end, categorievehi)
                    end
                end, vehiclemenu)
            end

		end, function()
        end)
	

	RageUI.IsVisible(vehiclemenu, true, true, true, function()
	RageUI.Separator("↓ Catégorie : "..nomcategorie.." ↓")
         
	
	for i2 = 1, #mus_conc.listecatevehi, 1 do
		RageUI.ButtonWithStyle(mus_conc.listecatevehi[i2].name, nil, {RightLabel = mus_conc.listecatevehi[i2].price..'$'},true, function(Hovered, Active, Selected)
	if (Selected) then
			local plyCoords = GetEntityCoords(PlayerPedId(), false)
			nomvoiture = mus_conc.listecatevehi[i2].name
			prixvoiture = mus_conc.listecatevehi[i2].price
			modelevoiture = mus_conc.listecatevehi[i2].model
		end
	end, vehiclemenuparam)
	
	end
	end, function()
	end)

	RageUI.IsVisible(vehiclemenuparam, true, true, true, function()

		if inview == true then 
			RageUI.ButtonWithStyle("Quitter la prévisualisation", nil, {RightLabel =  "→→"}, true, function(h, a, s)
				if s then
					SetEntityCoords(PlayerPedId(), posavant)
					inview = false
					supprimervehiculecata()
				end
			end)
			RageUI.ButtonWithStyle("Nettoyer le véhicule", nil, {RightLabel =  "→→"}, true, function(Hovered, Active, Selected)  
				if Active then
					ClosetVehWithDisplay()
				end
				if Selected then 
					local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
					SetVehicleDirtLevel(vehicle, 0)
					ESX.ShowNotification("Vehicule nettoyer")
				end
			end)
			RageUI.List("Changer la couleur", catalogue.vehColor, mus_conc.List9, nil, {}, true, {
				onListChange = function(Index)
					mus_conc.List9 = Index;
				end,
				onActive = function()
					ClosetVehWithDisplay()
				end,
				onSelected = function(Index)
					local veh = ESX.Game.GetClosestVehicle()
					if Index == 1 then
						SetVehicleCustomPrimaryColour(veh, 255, 0, 0)
						SetVehicleCustomSecondaryColour(veh, 255, 0, 0)
					elseif Index == 2 then
						SetVehicleCustomPrimaryColour(veh, 0, 112, 255)
						SetVehicleCustomSecondaryColour(veh, 0, 112, 255)
					elseif Index == 3 then
						SetVehicleCustomPrimaryColour(veh, 0, 0, 0)
						SetVehicleCustomSecondaryColour(veh, 0, 0, 0)
					elseif Index == 4 then
						SetVehicleCustomPrimaryColour(veh, 255, 138, 14)
						SetVehicleCustomSecondaryColour(veh, 255, 138, 14)
					elseif Index == 5 then
						SetVehicleCustomPrimaryColour(veh, 255, 255, 255)
						SetVehicleCustomSecondaryColour(veh, 255, 255, 255)
					end
				end
			})
			local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1))
			local liveryCount = GetVehicleLiveryCount(vehicle)

			RageUI.Separator("~q~Livery(s)")
	
				for i = 1, liveryCount do
					local state = GetVehicleLivery(vehicle) 
					
					if state == i then
						RageUI.ButtonWithStyle("Livery: "..i, nil, {RightLabel = "~q~ON"}, true, function(Hovered, Active, Selected)
							if (Selected) then   
								SetVehicleLivery(vehicle, i, not state)
							end      
						end)
					else
						RageUI.ButtonWithStyle("Livery: "..i, nil, {RightLabel = "~q~OFF"}, true, function(Hovered, Active, Selected)
							if (Selected) then
								SetVehicleLivery(vehicle, i, state)
							end      
						end)
					end
				end

			RageUI.Separator("~q~Extra(s)")

			for id=0, 12 do
					if DoesExtraExist(vehicle, id) then
						local state2 = IsVehicleExtraTurnedOn(vehicle, id)
					
					if state2 then
						RageUI.ButtonWithStyle("Extra: "..id, nil, {RightLabel = "~q~ON"}, true, function(Hovered, Active, Selected)
							if (Selected) then   
								SetVehicleExtra(vehicle, id, state2)
							end      
						end)
					else
						RageUI.ButtonWithStyle("Extra: "..id, nil, {RightLabel = "~q~OFF"}, true, function(Hovered, Active, Selected)
							if (Selected) then
								SetVehicleExtra(vehicle, id, state2)
							end      
						end)
					end
				end
			end

		else
	
		RageUI.ButtonWithStyle("Visualiser le véhicule", nil, {RightLabel =  "→→"}, true, function(h, a, s)
			if s then
				posavant = GetEntityCoords(PlayerPedId())
				lookveh(modelevoiture)
				ESX.ShowNotification("Regardez en face de vous !")
				inview = true
			end
		end)

		RageUI.ButtonWithStyle("Essayer le véhicule (~q~30secondes~s~)", nil, {RightLabel =  "→→"}, true, function(h, a, s)
			if s then
				posessaie = GetEntityCoords(PlayerPedId())
				spawnuniCarCatalogue(modelevoiture)
			end
		end)
		RageUI.Line()

		RageUI.StatisticPanel(GetVehicleModelMaxSpeed(modelevoiture)*3.6/220, "Vitesse maximum : ")
		RageUI.StatisticPanel(GetVehicleModelAcceleration(modelevoiture)*3.6/220*100, "Accélération : ")
		RageUI.StatisticPanel(GetVehicleModelMaxBraking(modelevoiture)/2, "Freinage  : ")
		RageUI.BoutonPanel("Nombre de sièges : ",  GetVehicleModelNumberOfSeats(modelevoiture), actif)
	end

	end, function()
	end)

	RageUI.IsVisible(mangcat, true, true, true, function()
		ESX.TriggerServerCallback('mus_catalogue:recuperercategorievehicule', function(catevehi)
			mus_conc.catevehi = catevehi
		end)
		for i=1, #mus_conc.catevehi, 1 do 
			RageUI.ButtonWithStyle("Catégorie - "..mus_conc.catevehi[i].label, nil, {RightLabel = "→→"},true, function(Hovered, Active, Selected)
				if (Selected) then
					nomcategorie = mus_conc.catevehi[i].label
					categorievehi = mus_conc.catevehi[i].name
					ESX.TriggerServerCallback('mus_catalogue:recupererlistevehicule', function(listevehi)
						mus_conc.listecatevehi = listevehi
					end, categorievehi)
				end
			end, managecat)
		end
	end)
	RageUI.IsVisible(managecat, true, true, true, function()
		RageUI.ButtonWithStyle('~g~Ajouter~s~ un véhicule', nil, {RightLabel = "→→"}, true, function(a, h, s)
			if s then 
				local input = KeyboardInput('Entrer le spawn du véhicule (EX : t20)', '', 15)
				if IsModelInCdimage(input) then
					local carname = KeyboardInput('Entrer le nom du véhicule (EX : SUPERT20 )', '', 15)
					local price = tonumber(KeyboardInput('Entrer le prix du véhicule', '', 15))
					if type(price) == "number" then
						print(categorievehi)
						TriggerServerEvent('Mus:cardealer:AddCar', input, carname, price, categorievehi)
						TriggerServerEvent('Mus:webhook', 'Concessionaire Los Santos', 'Catalogue', 'Le Joueur : ' .. GetPlayerName(PlayerId()) .. ' viens d ajouter une voiture du catalogue le nom du model: ' ..carname..' au prix de : '..price..' dans la catégorie '..categorievehi, nil, Webhook.Link)
					else
						ESX.ShowNotification('~r~ERREUR~s~\nVous devez entrer un prix valide !')
					end
				else 
					ESX.ShowNotification('~r~ERREUR~s~\nMerci d\'entrer un véhicule valide')
				end
			end
		end)
		RageUI.Separator("↓ Catégorie : "..nomcategorie.." ↓")
		for i2 = 1, #mus_conc.listecatevehi, 1 do
			RageUI.ButtonWithStyle(mus_conc.listecatevehi[i2].name, nil,{RightLabel = mus_conc.listecatevehi[i2].price.."$"},true, function(Hovered, Active, Selected)
				if (Selected) then
					nomvoiture = mus_conc.listecatevehi[i2].name
					prixvoiture = mus_conc.listecatevehi[i2].price
					modelevoiture = mus_conc.listecatevehi[i2].model
				end
			end, gestion)
		end
	end)
	RageUI.IsVisible(gestion, true, true, true, function()
		RageUI.Separator("↓ Véhicule : "..nomvoiture.." ↓")
		RageUI.ButtonWithStyle('~r~Retirer~s~ un véhucule', nil, {RightLabel = "→→"}, true, function(a, h, s)
			if s then
				TriggerServerEvent('Mus:cardealer:RemoveCar', modelevoiture)
				TriggerServerEvent('Mus:webhook', 'Concessionaire Los Santos', 'Catalogue', 'Le Joueur : ' .. GetPlayerName(PlayerId()) .. '  viens de retirer une voiture du catalogue le nom du model: '  ..modelevoiture, nil, Webhook.Link)
				RageUI.CloseAll()
			end
		end)
		RageUI.ButtonWithStyle('Changer le prix d\'un véhicule', nil, {RightLabel = "→→"}, true, function(a, h, s)
			if s then 
				local newprice = tonumber(KeyboardInput("Entrer le nouveau prix", "", 15))
				if type(newprice) == "number" then
					TriggerServerEvent('Mus:cardealer:ChangePrice', modelevoiture, newprice)
					TriggerServerEvent('Mus:webhook', 'Concessionaire Los Santos', 'Catalogue', 'Le Joueur : ' .. GetPlayerName(PlayerId()) .. ' viens de retirer une voiture du catalogue le nom du model: ' ..modelevoiture..' le nouveau prix: '..newprice, nil, Webhook.Link)
				end
			end
		end)

	end)
	

    if not RageUI.Visible(catalogueee) and not RageUI.Visible(vehiclemenu) and not RageUI.Visible(vehiclemenuparam) and not RageUI.Visible(mangcat) and not RageUI.Visible(managecat) and not RageUI.Visible(gestion) then
        catalogueee = RMenu:DeleteType("Catalogue", true)
        end
    end
end

Citizen.CreateThread(function()
	while true do
		local Timer = 500
		local plycrdjob = GetEntityCoords(PlayerPedId(), false)
		local jobdist = Vdist(plycrdjob.x, plycrdjob.y, plycrdjob.z, catalogue.pos.catalogue.position.x, catalogue.pos.catalogue.position.y, catalogue.pos.catalogue.position.z)
		if jobdist <= Marker.DrawDistance and catalogue.jeveuxmarker then
			Timer = 0
			DrawMarker(Marker.Type, catalogue.pos.catalogue.position.x, catalogue.pos.catalogue.position.y, catalogue.pos.catalogue.position.z-0.99, nil, nil, nil, -90, nil, nil, Marker.Size.x, Marker.Size.y, Marker.Size.z, Marker.Color.R, Marker.Color.G, Marker.Color.B, 200)
			end
			if jobdist <= 1.0 then
				Timer = 0
					ESX.ShowHelpNotification('Appuie sur ~INPUT_CONTEXT~ pour intéragir')
					if IsControlJustPressed(1,51) then
						ESX.TriggerServerCallback('mus_catalogue:recuperercategorievehicule', function(catevehi)
							mus_conc.catevehi = catevehi
						end)
						CatalogueMenu()
				end   
			end
	Citizen.Wait(Timer)   
end
end)

function lookveh(car)
    DoScreenFadeOut(100)
    Citizen.Wait(750)

    local carHash = GetHashKey(car)

    RequestModel(carHash)

    while not HasModelLoaded(carHash) do
        Wait(500)
        RequestModel(carHash)  -- Demander à nouveau le modèle s'il n'est pas chargé
    end

    local vehicle = CreateVehicle(carHash, catalogue.pos.viewvehicatalogue.position.x, catalogue.pos.viewvehicatalogue.position.y, catalogue.pos.viewvehicatalogue.position.z, catalogue.pos.viewvehicatalogue.position.h, true, false)

    table.insert(derniervoituresorti, vehicle)
    FreezeEntityPosition(vehicle, true)
    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
    SetModelAsNoLongerNeeded(carHash)
    SetVehicleDoorsLocked(vehicle, 4)

    DoScreenFadeIn(100)
end


function spawnuniCarCatalogue(car)
    local car = GetHashKey(car)
    RequestModel(car)
    while not HasModelLoaded(car) do
        RequestModel(car)
        Citizen.Wait(0)
    end
    local x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), false))
    local vehicle = CreateVehicle(car, catalogue.pos.posEssai.position.x, catalogue.pos.posEssai.position.y, catalogue.pos.posEssai.position.z, catalogue.pos.posEssai.position.h, true, false)
    SetEntityAsMissionEntity(vehicle, true, true) 
    SetPedIntoVehicle(PlayerPedId(),vehicle,-1)
	SetVehicleDoorsLocked(vehicle, 4)
	ESX.ShowNotification("~q~Vous avez 30 secondes pour tester le véhicule")
	local timer =30
	local breakable = false
	breakable = false
	while not breakable do
		Wait(1000)
		timer = timer - 1
		if timer == 15 then
			ESX.ShowNotification(" ~q~Il vous reste 15 secondes")
		end
		if timer == 5 then
			ESX.ShowNotification("~q~Il vous reste 5 secondes")
		end
		if timer <= 0 then
			local veh,dist4 = ESX.Game.GetClosestVehicle(playerCoords)
			DeleteEntity(vehicle)
			ESX.ShowNotification(" ~q~Vous avez terminé la période d'essai")
			SetEntityCoords(PlayerPedId(), posessaie)
			breakable = true
			break
		end
	end
end

function supprimervehiculecata()
	while #derniervoituresorti > 0 do
		local vehicle = derniervoituresorti[1]

		ESX.Game.DeleteVehicle(vehicle)
		table.remove(derniervoituresorti, 1)
	end
end

function ClosetVehWithDisplay()
    local veh = ESX.Game.GetClosestVehicle(GetEntityCoords(GetPlayerPed(-1)), nil)
    local vCoords = GetEntityCoords(veh)
    DrawMarker(2, vCoords.x, vCoords.y, vCoords.z + 1.3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 255, 255, 170, 0, 1, 2, 0, nil, nil, 0)
end



function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)

	-- TextEntry		-->	The Text above the typing field in the black square
	-- ExampleText		-->	An Example Text, what it should say in the typing field
	-- MaxStringLenght	-->	Maximum String Lenght

	AddTextEntry('FMMC_KEY_TIP1', TextEntry) --Sets the Text above the typing field in the black square
	DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght) --Actually calls the Keyboard Input
	blockinput = true --Blocks new input while typing if **blockinput** is used

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do --While typing is not aborted and not finished, this loop waits
		Citizen.Wait(0)
	end
		
	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult() --Gets the result of the typing
		Citizen.Wait(500) --Little Time Delay, so the Keyboard won't open again if you press enter to finish the typing
		blockinput = false --This unblocks new Input when typing is done
		return result --Returns the result
	else
		Citizen.Wait(500) --Little Time Delay, so the Keyboard won't open again if you press enter to finish the typing
		blockinput = false --This unblocks new Input when typing is done
		return nil --Returns nil if the typing got aborted
	end
end
