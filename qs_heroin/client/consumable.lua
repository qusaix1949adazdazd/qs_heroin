local QBCore = exports['qb-core']:GetCoreObject()


-- Event for using the syringe
RegisterNetEvent('qs_heroin:client:UseSyringe', function()
    local playerPed = PlayerPedId()
    
    -- Attach the syringe prop to the player's hand
    local propName = 'prop_syringe_01'
    RequestModel(propName)
    while not HasModelLoaded(propName) do
        Wait(0)
    end
    
    local prop = CreateObject(propName, 0, 0, 0, true, true, true)
    AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, 57005), 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
    
    -- Use the syringe with progress bar and animation
    QBCore.Functions.Progressbar("use_syringe", "Using Syringe...", 20000, false, true, {
        disableMovement = false,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "rcmpaparazzo1ig_4",
        anim = "miranda_shooting_up",
        flags = 49,
    }, {}, {}, function()
        -- Task completed
        ClearPedTasks(playerPed)
        
        -- Apply effects
        SetPlayerMaxStamina(PlayerId(), 100.0)
        ResetPlayerStamina(PlayerId()) -- Reset stamina to full
        
        -- Apply armor effect
        local currentArmor = GetPedArmour(playerPed)
        local newArmor = math.min(currentArmor + 75, 100) -- Ensure armor does not exceed 100
        SetPedArmour(playerPed, newArmor) -- Increase armor
        
        -- Apply alcohol effect (Visual effect)
        StartScreenEffect("DrugsMichaelAliensFight", 0, true)
        Citizen.Wait(5000) -- Wait for 5 seconds (duration of effect)
        StopScreenEffect("DrugsMichaelAliensFight")
        
        -- Remove the prop after the task is completed
        DeleteObject(prop)
        -- Trigger server event to handle syringe usage and remove the item from inventory
        TriggerServerEvent('qs_heroin:server:UseSyringe')
    end, function()
        -- Task cancelled
        ClearPedTasks(playerPed)
        -- Remove the prop if the task is cancelled
        DeleteObject(prop)
    end)
end)
