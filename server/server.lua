RegisterNetEvent('crp_selldrugs:valgAfStof')
AddEventHandler('crp_selldrugs:valgAfStof', function (source)
    local src = source
    for k, v in pairs(Config.bander) do
        isInGang = CheckGangRole(src, v)
        
        if isInGang == false or isInGang == nil then
            TriggerClientEvent('crp_selldrugs:valgAfSalg:norm', src)
            return
        else
            TriggerClientEvent('crp_selldrugs:valgAfSalg:gang', src)
            return
        end
    end
end)

RegisterNetEvent('crp_selldrugs:startSalg100g')
AddEventHandler('crp_selldrugs:startSalg100g', function (source)
    stofSalg = {
        type = '',
        label = '',
        count = 0,
        i = 0,
        price = 0,
    }
    for k, v in pairs(Config.stofferbander) do
        local item = GetItemLabel(source, k)
        
        if item == nil then
            return
        end

        count = GetItemCount(source, k)
        stofSalg.i = stofSalg.i + 1
        stofSalg.type = k
        stofSalg.label = item

        if count >= 5 then
            stofSalg.count = 1
        elseif count > 0 then
            stofSalg.count = 1
        end

        if stofSalg.count ~= 0 then
            stofSalg.price = stofSalg.count * v + math.random(1, 300)
            TriggerClientEvent('crp_selldrugs:findClient', source, stofSalg)
            break
        end

        if TableSizeOf(Config.stofferbander) == stofSalg.i and stofSalg.count == 0 then
            TriggerClientEvent('ox_lib:notify', source, {title = 'Stof Salg', description = Config.notifikation.nulstof, duration = 6000, position = 'top-right', icon = {'fab', 'ups'}})
        end
    end
end)


RegisterNetEvent('crp_selldrugs:startSalg')
AddEventHandler('crp_selldrugs:startSalg', function (source)
    stofSalg = {
        type = '',
        label = '',
        count = 0,
        i = 0,
        price = 0,
    }
    for k, v in pairs(Config.stoffer) do
        local item = GetItemLabel(source, k)
        
        if item == nil then
            return
        end

        count = GetItemCount(source, k)
        stofSalg.i = stofSalg.i + 1
        stofSalg.type = k
        stofSalg.label = item

        if count >= 5 then
            stofSalg.count = math.random(1, 10)
        elseif count > 0 then
            stofSalg.count = math.random(1, count)
        end

        if stofSalg.count ~= 0 then
            stofSalg.price = stofSalg.count * v + math.random(1, 300)
            TriggerClientEvent('crp_selldrugs:findClient', source, stofSalg)
            break
        end

        if TableSizeOf(Config.stoffer) == stofSalg.i and stofSalg.count == 0 then
            TriggerClientEvent('ox_lib:notify', source, {title = 'Stof Salg', description = Config.notifikation.nulstof, duration = 6000, position = 'top-right', icon = {'fab', 'ups'}})
        end
    end
end)

--RegisterCommand('stofsalg', function(source, args, rawCommand)
--    stofSalg = {
--        type = '',
--        label = '',
--        count = 0,
--        i = 0,
--        price = 0,
--    }
--    for k, v in pairs(Config.stoffer) do
--        local item = GetItemLabel(source, k)
--        
--        if item == nil then
--            return
--        end
--
--        count = GetItemCount(source, k)
--        stofSalg.i = stofSalg.i + 1
--        stofSalg.type = k
--        stofSalg.label = item
--
--        if count >= 5 then
--            stofSalg.count = math.random(1, 10)
--        elseif count > 0 then
--            stofSalg.count = math.random(1, count)
--        end
--
--        if stofSalg.count ~= 0 then
--            stofSalg.price = stofSalg.count * v + math.random(1, 300)
--            TriggerClientEvent('crp_selldrugs:findClient', source, stofSalg)
--            break
--        end
--
--        if TableSizeOf(Config.stoffer) == stofSalg.i and stofSalg.count == 0 then
--            TriggerClientEvent('ox_lib:notify', source, {title = 'Stof Salg', description = Config.notifikation.nulstof, duration = 6000, position = 'top-right', icon = {'fab', 'ups'}})
--        end
--    end
--end, false)

RegisterServerEvent('crp_selldrugs:betal')
AddEventHandler('crp_selldrugs:betal', function(stofSalg)
    local src = source
    local count = GetItemCount(src, stofSalg.type)
    if count >= stofSalg.count then
        RemoveItem(src, stofSalg.type, stofSalg.count)
        if Config.penge == 'sortepenge' then
            AddCash(src, stofSalg.price)
        else
            AddAccountMoney(src, Config.penge, stofSalg.price)
        end
    else
        TriggerClientEvent('ox_lib:notify', src, {title = 'Stof Salg', description = Config.notifikation.nulstof, duration = 6000, position = 'top-right', icon = {'fab', 'ups'}})
    end
end)

RegisterServerEvent('crp_selldrugs:tilkaldPoliti')
AddEventHandler('crp_selldrugs:tilkaldPoliti', function(stofSalg)
    TriggerClientEvent('crp_selldrugs:tilkaldPoliti', -1, stofSalg.coords)
end)