local QBCore = exports['qb-core']:GetCoreObject()
local heroinTableOut = false
local processingProp1, processingProp2 = nil, nil

-- Function to show notifications using Ox Lib
function Notify(message, type)
    exports.ox_lib:notify({
        description = message,
        type = type
    })
end

-- Function to show a progress bar using Ox Lib
function progressbar(message, duration)
    exports.ox_lib:progress({
        label = message,
        duration = duration,
        type = 'progress',
        canCancel = false,  -- Disable the ability to cancel the progress bar
        onDone = function()
            -- Progress bar completed
        end,
        onCancel = function()
            -- This will never be called since the progress bar is uncancelable
        end
    })
end


-- Function to play an emote
function playEmote(animDict, animName, duration)
    local playerPed = PlayerPedId()
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(0)
    end
    TaskPlayAnim(playerPed, animDict, animName, 8.0, 8.0, duration, 49, 0, false, false, false)
end

-- Function to create and attach a prop to the player’s hand
function attachPropToHand(propName)
    local playerPed = PlayerPedId()
    RequestModel(propName)
    while not HasModelLoaded(propName) do
        Wait(0)
    end

    local prop = CreateObject(propName, 0, 0, 0, true, true, true)
    AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, 57005), 0.1, 0.05, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
    return prop
end

-- Function to remove the attached prop
function removeProp(prop)
    if prop then
        DetachEntity(prop, true, true)
        DeleteObject(prop)
        prop = nil
    end
end

-- Event for placing the heroin table
RegisterNetEvent("qs_heroin:client:setHeroinTable")
AddEventHandler("qs_heroin:client:setHeroinTable", function()
    if heroinTableOut then 
        Notify("You have already set up the table!", 'error')
        TriggerServerEvent('qs_heroin:server:getHeroinTableBack')
    else
        heroinTableOut = true
        local PedCoords = GetEntityCoords(PlayerPedId())
        playEmote("amb@medic@standing@tendtodead@idle_a", "idle_a", -1)
        progressbar("Placing heroin Table...", 10000)  -- Use Ox Lib's progress bar
        ClearPedTasks(PlayerPedId()) -- Clear emote when done
        
        local heroinTable = CreateObject("v_ret_ml_tableb", PedCoords.x+1, PedCoords.y+1, PedCoords.z-1, true, false)
        PlaceObjectOnGroundProperly(heroinTable)
        
        local options = {
            { event = "qs_heroin:client:processPoppy", icon = "fas fa-box-circle-check", label = "Process Poppy", data = heroinTable },
            { event = "qs_heroin:client:fillSyringe", icon = "fas fa-box-circle-check", label = "Fill Syrigne", data = heroinTable },
            { event = "qs_heroin:client:getHeroinTableBack", icon = "fas fa-box-circle-check", label = "Pick Up Table", data = heroinTable, canInteract = function() return heroinTableOut end },
        }
        if Config.oxtarget then
            exports.ox_target:addLocalEntity(heroinTable, options)
        else
            exports['qb-target']:AddTargetEntity(heroinTable, { options = options })
        end    
    end
end)

-- Event for picking up the heroin table
RegisterNetEvent("qs_heroin:client:getHeroinTableBack")
AddEventHandler("qs_heroin:client:getHeroinTableBack", function(data) 
    playEmote("amb@medic@standing@tendtodead@idle_a", "idle_a", -1)
    progressbar("Packing heroin Table...", 10000)  -- Use Ox Lib's progress bar
    ClearPedTasks(PlayerPedId()) -- Clear emote when done    
    DeleteObject(data.data)
    TriggerServerEvent('qs_heroin:server:getHeroinTableBack')
    heroinTableOut = false
end)

-- Event for processing poppy
RegisterNetEvent("qs_heroin:client:processPoppy")
AddEventHandler("qs_heroin:client:processPoppy", function(data) 
    if not ItemCheck('scissors') or not ItemCheck('poppy') or not ItemCheck('empty_bag') then return end
    processingProp1 = attachPropToHand('prop_cs_scissors')
    processingProp2 = attachPropToHand('bkr_prop_weed_bud_pruned_01a')

    playEmote("mini@repair", "fixing_a_ped", -1)
    progressbar("Processing poppy...", 20000)  -- Use Ox Lib's progress bar
    -- Remove the prop after processing
    removeProp(processingProp1)
    removeProp(processingProp2)
    ClearPedTasks(PlayerPedId()) -- Clear emote when done
    TriggerServerEvent("qs_heroin:server:processPoppy")
end)

-- Event for Fill Syringe
RegisterNetEvent("qs_heroin:client:fillSyringe")
AddEventHandler("qs_heroin:client:fillSyringe", function(data) 
    if not ItemCheck('syringe') or not ItemCheck('heroin_bag') then return end
    processingProp1 = attachPropToHand('p_syringe_01_s')
    processingProp2 = attachPropToHand('xm3_prop_xm3_bag_coke_01a')

    playEmote("anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", -1)
    progressbar("Fill Syringe...", 25000)  -- Use Ox Lib's progress bar
    -- Remove the prop after fill
    removeProp(processingProp1)
    removeProp(processingProp2)

    ClearPedTasks(PlayerPedId()) -- Clear emote when done
    TriggerServerEvent("qs_heroin:server:fillSyringe") -- Updated event name to match server code
end)
