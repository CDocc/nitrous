-- Config
local nitrousChargeTime = 10 -- Time in seconds it takes to fully charge the nitrous tank
local nitrousBoostTime = 5 -- Time in seconds the nitrous boost lasts
local nitrousPowerMultiplier = 2.0 -- Multiplier for vehicle speed during nitrous boost


function chargeNitrousTank(vehicle)
    Citizen.CreateThread(function()
        SetVehicleEngineOn(vehicle, false, true, false)
        local nitrousChargeSound = GetSoundId()
        PlaySoundFromEntity(nitrousChargeSound, "NITRO_BUTTON_PRESS", vehicle, "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", true, 0)
        local startTime = GetGameTimer()
        local endTime = startTime + (nitrousChargeTime * 1000)
        while GetGameTimer() < endTime do Citizen.Wait(0) end
        StopSound(nitrousChargeSound)
        SetVehicleEngineOn(vehicle, true, true, false)
    end)
end

function activateNitrousBoost(vehicle)
    Citizen.CreateThread(function()
        local nitrousBoostSound = GetSoundId()
        PlaySoundFromEntity(nitrousBoostSound, "NITRO_BOOST_ON", vehicle, "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", true, 0)
        SetVehicleBoostActive(vehicle, true)
        SetVehicleForwardSpeed(vehicle,
        GetEntitySpeed(vehicle) * nitrousPowerMultiplier)
        local startTime = GetGameTimer()
        local endTime = startTime + (nitrousBoostTime * 1000)
        while GetGameTimer() < endTime do Citizen.Wait(0) end
        StopSound(nitrousBoostSound)
        SetVehicleBoostActive(vehicle, false)
    end)
end

function handleNitrousKeyPress(vehicle, nitrousKey)
    Citizen.CreateThread(function()
        if DoesVehicleHaveNitrous(vehicle) then
            if IsVehicleNitroActive(vehicle, 0) then
                activateNitrousBoost(vehicle)
            else
                chargeNitrousTank(vehicle)
            end
        end
    end)
end

AddEventHandler("playerEnteredVehicle", function(vehicle, seat)
    if seat == -1 then
        local nitrousKey = 38 -- Change this to the key you wish to use https://docs.fivem.net/docs/game-references/controls/
        RegisterKeyMapping("nitrous", "Nitrous Boost", "keyboard", nitrousKey)
        RegisterCommand("nitrous", function()
            handleNitrousKeyPress(vehicle, nitrousKey)
        end, false)
    end
end)
