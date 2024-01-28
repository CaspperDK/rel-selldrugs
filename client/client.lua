npc = {}
cooldown = false
blips = {}
isInGang = nil

RegisterNetEvent('crp_selldrugs:valgAfSalg:norm')
AddEventHandler('crp_selldrugs:valgAfSalg:norm', function (source)
    lib.registerContext({
        id = 'normmenu',
        title = 'Stof Salg',
        options = {
            {
                title = 'Salg af poser (1g)',
                description = 'Start salg af 1g poser',
                icon = 'pills',
                event = 'crp_selldrugs:client:startSalg',
            },
        }
    })
    lib.showContext('normmenu')
end)

RegisterNetEvent('crp_selldrugs:valgAfSalg:gang')
AddEventHandler('crp_selldrugs:valgAfSalg:gang', function(source)
    lib.registerContext({
        id = 'bandemenu',
        title = 'Stof Salg (Bande)',
        options = {
            {
                title = 'Salg af poser (1g)',
                description = 'Start salg af 1g poser',
                icon = 'pills',
                event = 'crp_selldrugs:client:startSalg',
            },
            {
                title = 'Salg af 100g',
                description = 'Start salg af 100g',
                icon = 'box',
                event = 'crp_selldrugs:client:startSalg100g',
            },
        }
    })
    lib.showContext('bandemenu')
end)

RegisterNetEvent('crp_selldrugs:client:startSalg')
AddEventHandler('crp_selldrugs:client:startSalg', function()
    local src = GetPlayerServerId(PlayerId())
    TriggerServerEvent('crp_selldrugs:startSalg', src)
end)

RegisterNetEvent('crp_selldrugs:client:startSalg100g')
AddEventHandler('crp_selldrugs:client:startSalg100g', function()
    local src = GetPlayerServerId(PlayerId())
    TriggerServerEvent('crp_selldrugs:startSalg100g', src)
end)

next_ped = function(stofSalg)
    if cooldown then
        lib.notify({
            title = Config.notifikation.titel,
            description = Config.notifikation.cooldown,
            position = 'top-right',
            duration = 6000,
            icon = {'fab', 'ups'}
        })
        return
    end

    cooldown = true

    if Config.cityPoint ~= false and GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Config.cityPoint, true) > 1500.0 then
        lib.notify({
            title = Config.notifikation.titel,
            description = Config.notifikation.forlangt,
            position = 'top-right',
            duration = 6000,
            icon = {'fab', 'ups'}
        })
        return
    end

    if npc ~= nil and npc.ped ~= nil then
        SetPedAsNoLongerNeeded(npc.ped)
    end

    cops = 0
    lib.callback('crp_selldrugs:getPoliceCount', false, function(_betjente)
        cops = _betjente
    end)

    Wait(500)

    if cops < Config.betjentKrav then
        lib.notify({
            title = Config.notifikation.titel,
            description = Config.notifikation.ikkeNokBetjente,
            position = 'top-right',
            duration = 6000,
            icon = {'fab', 'ups'}
        })
        return
    end

    if cops == 3 then
        stofSalg.price = MathRound(stofSalg.price * 1.03)
    elseif cops == 4 then
        stofSalg.price = MathRound(stofSalg.price * 1.05)
    elseif cops == 5 then
        stofSalg.price = MathRound(stofSalg.price * 1.07)
    elseif cops == 6 then
        stofSalg.price = MathRound(stofSalg.price * 1.09)
    elseif cops == 7 then
        stofSalg.price = MathRound(stofSalg.price * 1.11)
    elseif cops >= 8 then
        stofSalg.price = MathRound(stofSalg.price * 1.15)
    end

    TaskStartScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_STAND_MOBILE', 0, true)
    setInvBusy(true)
    lib.notify({
        title = Config.notifikation.titel,
        description = Config.notifikation.afventer .. stofSalg.label,
        position = 'top-right',
        duration = 6000,
        icon = {'fab', 'ups'}
    })

    Wait(math.random(5000, 10000))
    ClearPedTasks(PlayerPedId())
    npc.hash = GetHashKey(Config.pedlist[math.random(1, #Config.pedlist)])
    lib.requestModel(npc.hash)
    npc.coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 50.0, 5.0)
    retval, npc.z = GetGroundZFor_3dCoord(npc.coords.x, npc.coords.y, npc.coords.z, 0)

    if retval == false then
        cooldown = false
        lib.notify({
            title = Config.notifikation.titel,
            description = Config.notifikation.abort,
            position = 'top-right',
            duration = 6000,
            icon = {'fab', 'ups'}
        })
        setInvBusy(false)
        ClearPedTasks(PlayerPedId())
        return
    end

    npc.zone = GetLabelText(GetNameOfZone(npc.coords))
    stofSalg.zone = npc.zone
    npc.ped = CreatePed(5, npc.hash, npc.coords.x, npc.coords.y, npc.z, 0.0, true, true)
    PlaceObjectOnGroundProperly(npc.ped)
    SetEntityAsMissionEntity(npc.ped)

    if IsEntityDead(npc.ped) or GetEntityCoords(npc.ped) == vector3(0.0, 0.0, 0.0) then
        lib.notify({
            title = Config.notifikation.titel,
            description = Config.notifikation.ikkefundet,
            position = 'top-right',
            duration = 6000,
            icon = {'fab', 'ups'}
        })
        setInvBusy(false)
        return
    end

    lib.notify({
        title = Config.notifikation.titel,
        description = Config.notifikation.kommer, Config.notifikation.fundet .. npc.zone,
        position = 'top-right',
        duration = 6000,
        icon = {'fab', 'ups'}
    })
    TaskGoToEntity(npc.ped, PlayerPedId(), 60000, 4.0, 2.0, 0, 0)

    Wait(10)

    lib.notify({
        title = Config.notifikation.titel,
        description = 'En kunde vil gerne købe x' .. stofSalg.count .. ' ' .. stofSalg.label .. ' for ' .. stofSalg.price .. ' DKK.',
        position = 'top-right',
        duration = 6000,
        icon = {'fab', 'ups'}
    })

    CreateThread(function()
        canSell = true
        while npc.ped ~= nil and npc.ped ~= 0 and not IsEntityDead(npc.ped) do
            Wait(0)
            npc.coords = GetEntityCoords(npc.ped)
            distance = Vdist2(GetEntityCoords(PlayerPedId()), npc.coords)

            if distance >= 2.5 then
                if IsControlJustPressed(0, 49) or IsControlJustPressed(0, 73) and canSell then
                    canSell = false
                    lib.hideTextUI()
                    lib.notify({
                        title = Config.notifikation.titel,
                        description = Config.notifikation.stoppetsalg,
                        position = 'top-right',
                        duration = 6000,
                        style = {
                            backgroundColor = '#141517',
                            color = '#cf1508',
                            ['.description'] = {
                                color = '#FFFFFF'
                            }
                        },
                        icon = {'fab', 'ups'},
                        iconColor = '#cf1508'
                    })
                    setInvBusy(false)
                    SetPedAsNoLongerNeeded(npc.ped)
                    npc = {}
                end
            end

            if distance < 2.0 then
                lib.showTextUI('Tryk E for at sælge!', {
                    position = 'right-top',
                    icon = {'fab', 'ups'},
                })
                if IsControlJustPressed(0, 49) or IsControlJustPressed(0, 73) and canSell then
					canSell = false
					lib.hideTextUI()
					lib.notify({
						title = Config.notifikation.title,
						description = Config.notifikation.stoppetsalg,
						position = 'top-right',
						duration = 6000,
						style = {
							backgroundColor = '#141517',
							color = '#cf1508',
							['.description'] = {
							  color = '#cf1508'
							}
						},
						icon = {'fab', 'ups'},
						iconColor = '#cf1508'
					})
					setInvBusy(false)
					SetPedAsNoLongerNeeded(npc.ped)
					npc = {}
				elseif IsControlJustPressed(0, 38) and canSell then
					canSell = false
					reject = math.random(1, 10)
					lib.hideTextUI()
					setInvBusy(false)
					if reject <= 3 then
						lib.notify({
							title = Config.notifikation.title,
							description = Config.notifikation.afvist,
							position = 'top-right',
							duration = 6000,
							style = {
								backgroundColor = '#141517',
								color = '#cf1508',
								['.description'] = {
								  color = '#FFFFFF'
								}
							},
							icon = {'fab', 'ups'},
							iconColor = '#cf1508'
						})
						setInvBusy(false)
						PlayAmbientSpeech1(npc.ped, 'GENERIC_HI', 'SPEECH_PARAMS_STANDARD')
						stofSalg.coords = GetEntityCoords(PlayerPedId())
						TriggerServerEvent('crp_selldrugs:tilkaldPoliti', stofSalg)
						SetPedAsNoLongerNeeded(npc.ped)
						if Config.npcFightOnReject then
							TaskCombatPed(npc.ped, PlayerPedId(), 0, 16)
						end
						npc = {}
						return
					end

					if IsPedInAnyVehicle(PlayerPedId(), false) then
						lib.notify({
							title = Config.notifikation.title,
							description = Config.notifikation.ibil,
							duration = 6000,
							icon = {'fab', 'ups'},
							type = 'success'
						})
						setInvBusy(false)
						return
					end

					MakeEntityFaceEntity(PlayerPedId(), npc.ped)
					MakeEntityFaceEntity(npc.ped, PlayerPedId())
					SetPedTalk(npc.ped)
					PlayAmbientSpeech1(npc.ped, 'GENERIC_HI', 'SPEECH_PARAMS_STANDARD')
					obj = CreateObject(GetHashKey('prop_weed_bottle'), 0, 0, 0, true)
					AttachEntityToEntity(obj, PlayerPedId(), GetPedBoneIndex(PlayerPedId(),  57005), 0.13, 0.02, 0.0, -90.0, 0, 0, 1, 1, 0, 1, 0, 1)
					obj2 = CreateObject(GetHashKey('hei_prop_heist_cash_pile'), 0, 0, 0, true)
					AttachEntityToEntity(obj2, npc.ped, GetPedBoneIndex(npc.ped,  57005), 0.13, 0.02, 0.0, -90.0, 0, 0, 1, 1, 0, 1, 0, 1)
					PlayAnim('mp_common', 'givetake1_a', 8.0, -1, 0)
					PlayAnimOnPed(npc.ped, 'mp_common', 'givetake1_a', 8.0, -1, 0)
					Wait(1000)
					AttachEntityToEntity(obj2, PlayerPedId(), GetPedBoneIndex(PlayerPedId(),  57005), 0.13, 0.02, 0.0, -90.0, 0, 0, 1, 1, 0, 1, 0, 1)
					AttachEntityToEntity(obj, npc.ped, GetPedBoneIndex(npc.ped,  57005), 0.13, 0.02, 0.0, -90.0, 0, 0, 1, 1, 0, 1, 0, 1)
					Wait(1000)
					DeleteEntity(obj)
					DeleteEntity(obj2)
					PlayAmbientSpeech1(npc.ped, 'GENERIC_THANKS', 'SPEECH_PARAMS_STANDARD')
					SetPedAsNoLongerNeeded(npc.ped)
					TriggerServerEvent('crp_selldrugs:betal', stofSalg)
					setInvBusy(false)
					lib.notify({
						title = Config.notifikation.title,
						description = (Config.notifikation.sold):format(stofSalg.count, stofSalg.label, stofSalg.price),
						position = 'top-right',
						duration = 6000,
						icon = {'fab', 'ups'},
					})
					npc = {}
				end
			end
		end
	end)
end

CreateThread(function()
	while true do
		Wait(20000)
		if cooldown then
			cooldown = false
		end
	end
end)

RegisterNetEvent('crp_selldrugs:findClient')
AddEventHandler('crp_selldrugs:findClient', next_ped)

RegisterNetEvent('crp_selldrugs:tilkaldPoliti')
AddEventHandler('crp_selldrugs:tilkaldPoliti', function(coords)	
	if GetPlayerData().job ~= nil and GetPlayerData().job.name == 'police' then
		street = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
		street2 = GetStreetNameFromHashKey(street)
		lib.notify({
			title = Config.notifikation.politi_notifikation_titel,
			description = Config.notifikation.politi_notifikation_subtitel..' ved '..street2,
			duration = 6000,
			icon = {'fab', 'ups'},
		})
		PlaySoundFrontend(-1, "Bomb_Disarmed", "GTAO_Speed_Convoy_Soundset", 0)

		blip = AddBlipForCoord(coords)
		SetBlipSprite(blip,  403)
		SetBlipColour(blip,  1)
		SetBlipAlpha(blip, 250)
		SetBlipScale(blip, 1.2)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString('# Stof Salg')
		EndTextCommandSetBlipName(blip)
		table.insert(blips, blip)
		Wait(50000)
		for i in pairs(blips) do
			RemoveBlip(blips[i])
			blips[i] = nil
		end
	end
end)