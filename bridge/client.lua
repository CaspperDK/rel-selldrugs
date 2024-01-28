if GetResourceState('qb-core') ~= 'started' then return end

QBCore = exports['qb-core']:GetCoreObject()

function GetPlayerData()
    return QBCore.Functions.GetPlayerData()
end

function setInvBusy(bool)
    LocalPlayer.state:set('inv_busy', bool, true)
end