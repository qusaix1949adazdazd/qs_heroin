-- consumable.lua

local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateUseableItem('heroin', function(source)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    TriggerClientEvent('qs_heroin:client:UseSyringe', source)
end)

RegisterNetEvent('qs_heroin:server:UseSyringe', function()
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    -- Add your server-side effects here, e.g., health restoration
end)


-- Server-side event to handle syringe usage
RegisterNetEvent('qs_heroin:server:UseSyringe', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player then
        -- Remove one syringe item from the player's inventory
        Player.Functions.RemoveItem('heroin', 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['heroin'], 'remove')
        -- You can add any additional server-side logic here, such as applying effects to the player
    end
end)
