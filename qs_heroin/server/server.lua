local QBCore = exports['qb-core']:GetCoreObject()

local playerLastHeroinProcessTime = {}

-- Function to send notifications to a specific player using Ox Lib
function Notifys(playerId, message, type)
    TriggerClientEvent('ox_lib:notify', playerId, {description = message, type = type})
end

-- Function to check and add an item
function AddItem(src, itemName, amount)
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.AddItem(itemName, amount)
        print("Added item:", itemName, amount)
        return true
    else
        print("Failed to get player in AddItem")
    end
    return false
end

-- Function to remove an item
function RemoveItem(src, itemName, amount)
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.RemoveItem(itemName, amount)
        print("Removed item:", itemName, amount)
        return true
    else
        print("Failed to get player in RemoveItem")
    end
    return false
end

-- Function to check item availability
function ItemCheck(Player, itemName, amount, showNotification)
    local item = Player.Functions.GetItemByName(itemName)
    if item == nil or item.amount < amount then
        if showNotification then
            Notifys(Player.PlayerData.source, "You don't have enough " .. itemName, 'error')
        end
        return false
    end
    return true
end

-- Event for getting the heroin table back
RegisterServerEvent('qs_heroin:server:getHeroinTableBack')
AddEventHandler('qs_heroin:server:getHeroinTableBack', function()
    local src = source
    if AddItem(src, "heroin_table", 1) then
        Notifys(src, 'You got your Heroin Table back', 'success')
    end
end)

-- Event for processing poppy with progress bar handling
RegisterServerEvent('qs_heroin:server:processPoppy')
AddEventHandler('qs_heroin:server:processPoppy', function(isCompleted)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local currentTime = os.time()

    print("Process Poppy triggered. isCompleted:", isCompleted)

    if playerLastHeroinProcessTime[src] and currentTime - playerLastHeroinProcessTime[src] < 0 then
        Notifys(src, "You need to wait before processing poppy again!", "error")
        return
    end

    playerLastHeroinProcessTime[src] = currentTime



    if not ItemCheck(Player, 'scissors', 1, true) then return end
    if not ItemCheck(Player, 'poppy', 1, true) then return end
    if not ItemCheck(Player, 'empty_bag', 1, true) then return end
    
    -- Only remove items and give rewards if progress is completed
    if RemoveItem(src, "empty_bag", 1) and RemoveItem(src, "poppy", 1) then
        local chance = math.random(1, 100)
        if chance <= 100 then  
            AddItem(src, 'heroin_bag', 1)
            Notifys(src, "Successfully processed Poppy!", "success")
        else
            print("Chance failed, no item given.")
        end
    else
        print("Failed to remove items.")
    end
end)

-- Event for filling syringe with progress bar handling
RegisterServerEvent('qs_heroin:server:fillSyringe')
AddEventHandler('qs_heroin:server:fillSyringe', function(isCompleted)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    print("Fill Syringe triggered. isCompleted:", isCompleted)



    if not ItemCheck(Player, 'heroin_bag', 1, true) then 
        print("Player does not have enough heroin bag")
        return 
    end
    if not ItemCheck(Player, 'syringe', 1, true) then 
        print("Player does not have enough syringe")
        return 
    end
    
    -- Only remove items and give rewards if progress is completed
    if RemoveItem(src, "heroin_bag", 1) and RemoveItem(src, "syringe", 1) then
        if AddItem(src, "heroin", 1) then
            Notifys(src, "Successfully filled syringe!", "success")
        else
            print("Failed to add heroin item")
        end
    else
        print("Failed to remove required items")
    end
end)

-- Function to create a usable item for heroin table
QBCore.Functions.CreateUseableItem('heroin_table', function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if TriggerClientEvent("qs_heroin:client:setHeroinTable", src) then
        Player.Functions.RemoveItem("heroin_table", 1)
    end
end)
