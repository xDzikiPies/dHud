local directions = {
    N = 360,
    0,
    NE = 315,
    E = 270,
    SE = 225,
    S = 180,
    SW = 135,
    W = 90,
    NW = 45,
}

local RPM = 0
local RPMTime = GetGameTimer()
local RPMScale = 0
local hudOpen = true
local phoneUp = false




local Ped = {
    Health = 0,
    Armor = 0,
    Underwater = 0,
    UnderwaterTime = 0,
    Stamina = 0,
    Vehicle = nil,
    Street1 = "",
    Street2 = "",
    Direction = "",
    VehicleData = {
        Speed = 0,
        Class = 0,
        RPMScale = 0,
        Gear = 1,
        engineHealth = 0.0,
        carLights = 0,
    },
    Job = '',
    RankLabel = '',
    Id = 0,
}

Citizen.CreateThread(function()
    local minimap = RequestScaleformMovie("minimap")
    SetRadarBigmapEnabled(true, false)
    SetRadarBigmapEnabled(false, false)
    local isPaused = false
    local isTalking = false
    while true do
        Citizen.Wait(500)
        BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
        ScaleformMovieMethodAddParamInt(3)
        EndScaleformMovieMethod()
        if NetworkIsPlayerTalking(PlayerId()) and not isTalking then
            isTalking = true
            SendNUIMessage({ app = 'dHud', method = 'toggle-voice', data = true })
        elseif not NetworkIsPlayerTalking(PlayerId()) and isTalking then
            isTalking = false
            SendNUIMessage({ app = 'dHud', method = 'toggle-voice', data = false })
        end

        Ped.Health = GetEntityHealth(ESX.PlayerData.ped)
        Ped.Armor = GetPedArmour(ESX.PlayerData.ped)
        Ped.Underwater = IsPedSwimmingUnderWater(ESX.PlayerData.ped)
        Ped.UnderwaterTime = GetPlayerUnderwaterTimeRemaining(PlayerId())
        if Ped.UnderwaterTime < 0.0 then
            Ped.UnderwaterTime = 0.0
        end
        Ped.Stamina = GetPlayerSprintStaminaRemaining(PlayerId())
        if IsPedInAnyVehicle(ESX.PlayerData.ped, false) then
            Ped.Vehicle = GetVehiclePedIsIn(ESX.PlayerData.ped, false)
            Ped.VehicleClass = GetVehicleClass(Ped.Vehicle)
            Ped.VehicleEngine = GetIsVehicleEngineRunning(Ped.Vehicle)
            RPMScale = 0
            if (Ped.VehicleClass >= 0 and Ped.VehicleClass <= 5) or (Ped.VehicleClass >= 9 and Ped.VehicleClass <= 12) or Ped.VehicleClass == 17 or Ped.VehicleClass == 18 or Ped.VehicleClass == 20 then
                RPMScale = 7000
            elseif Ped.VehicleClass == 6 then
                RPMScale = 7500
            elseif Ped.VehicleClass == 7 then
                RPMScale = 8000
            elseif Ped.VehicleClass == 8 then
                RPMScale = 11000
            elseif Ped.VehicleClass == 15 or Ped.VehicleClass == 16 then
                RPMScale = -1
            end
        else
            Ped.Vehicle = nil
        end

        local coords = GetEntityCoords(ESX.PlayerData.ped);
        local zone = GetNameOfZone(coords.x, coords.y, coords.z);
        local var1, var2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z, Citizen.ResultAsInteger(),
            Citizen.ResultAsInteger())
        Ped.Street1 = GetStreetNameFromHashKey(var1);
        if string.len(Ped.Street1) >= 15 then
            Ped.Street1 = string.sub(Ped.Street1, 1, 15) .. '.'
        end
        local hash2 = GetStreetNameFromHashKey(var2);
        local heading = GetEntityHeading(ESX.PlayerData.ped);

        for k, v in pairs(directions) do
            if (math.abs(heading - v) < 22.5) then
                heading = k;
                if (heading == 1) then
                    heading = 'N';
                    break;
                end
                break;
            end
        end
        Ped.Direction = heading

        if (hash2 == '') then
            Ped.Street2 = GetLabelText(zone);
        else
            Ped.Street2 = hash2 .. ', ' .. GetLabelText(zone);
        end
    end
end)

Citizen.CreateThread(function()
    local lights = 0
    while true do
        local sleep = 1000
        if Ped.Vehicle ~= nil then
            sleep = 200
            Ped.VehicleData.Speed = math.floor(GetEntitySpeed(Ped.Vehicle) * 2.22)

            if RPMTime <= GetGameTimer() then
                local r = GetVehicleCurrentRpm(Ped.Vehicle)
                if not Ped.VehicleEngine then
                    r = 0
                elseif r > 0.99 then
                    r = r * 100
                    r = r + math.random(-2, 2)

                    r = r / 100
                    if r < 0.12 then
                        r = 0.12
                    end
                else
                    r = r - 0.1
                end

                RPM = math.floor(RPMScale * r + 0.5)
                if RPM < 0 then
                    RPM = 0
                elseif Speed == 0.0 and r ~= 0 then
                    RPM = math.random(RPM, (RPM + 50))
                end

                RPM = math.floor(RPM / 10) * 10
                RPMTime = GetGameTimer() + 50
            end
            local percentRPM = ESX.Math.Round(((RPM - 0) * 100) / (RPMScale - 0))
            local scaledValue = percentRPM / 100 * 0.75
            local fuel
            if GetResourceState('ox_fuel') == "started" then
                fuel = Entity(Ped.Vehicle).state.fuel or GetVehicleFuelLevel(Ped.Vehicle)
            else
                fuel = 0
            end
            local off, normal, beams = GetVehicleLightsState(Ped.Vehicle)

            if off == 1 and normal ~= 1 and beams ~= 1 then
                lights = 0
            elseif off == 1 and normal == 1 and beams ~= 1 or off == 1 and normal == 0 and beams == 1 then
                lights = 2
            elseif off == 1 and normal == 1 and beams == 1 then
                lights = 1
            end
            SendNUIMessage({
                app = 'dHud',
                method = 'update-veh-data',
                data = {
                    inCar = Ped.Vehicle ~= nil and true or false,
                    speed = Ped.VehicleData.Speed,
                    rpm = scaledValue,
                    fuel = ESX.Math.Round(fuel),
                    engineHealth = (GetVehicleEngineHealth(Ped.Vehicle) / 10),
                    gear = GetVehicleCurrentGear(Ped.Vehicle),
                    carLights = lights,
                    engineOn = GetIsVehicleEngineRunning(Ped.Vehicle) and true or false
                }
            })
        else
            lights = 0
            SendNUIMessage({
                app = 'dHud',
                method = 'update-veh-data',
                data = {
                    inCar = nil,
                    speed = 0,
                    rpm = 0,
                    fuel = 0,
                    engineHealth = 0,
                    gear = 1,
                    carLights = 0,
                    engineOn = false,
                }
            })
        end
        Citizen.Wait(sleep)
    end
end)

RegisterNetEvent('pma-voice:setTalkingMode')
AddEventHandler('pma-voice:setTalkingMode', function(mode)
    SendNUIMessage({ app = 'dHud', method = 'voice-range', data = mode })
end)

RegisterNetEvent('esx:onPlayerSpawn')
AddEventHandler('esx:onPlayerSpawn', function()
    SendNUIMessage({ app = 'dHud', method = 'state', data = true })
end)

Citizen.CreateThread(function()
    RegisterNetEvent("esx_status:onTick")
    AddEventHandler("esx_status:onTick", function(status)
        local hunger, thirst, energy, drunk
        if status ~= nil then
            for j, value in ipairs(status) do
                if value['name'] == 'hunger' then
                    hunger = value['percent']
                elseif value['name'] == 'thirst' then
                    thirst = value['percent']
                elseif value['name'] == 'energy' then
                    energy = value['percent']
                elseif value['name'] == 'drunk' then
                    drunk = value['percent']
                elseif value['name'] == 'drug' then
                    drug = value['percent']
                end
            end
        else
            hunger = 0
            thirst = 0
            energy = 0
            drunk = 0
        end
        local plyState = LocalPlayer.state
        local proximity = plyState.proximity
        SendNUIMessage({
            app = 'dHud',
            method = 'update-user-data',
            data = {
                name = ESX.PlayerData.firstName .. ' ' .. ESX.PlayerData.lastName,
                food = ESX.Math.Round(hunger),
                drink = ESX.Math.Round(thirst),
                energy = energy or 70,
                health = IsPlayerDead(PlayerId()) and 0 or ESX.Math.Round(Ped.Health - 100),
                armor = ESX.Math.Round(Ped.Armor),
                streetName = Ped.Street1,
                direction = Ped.Direction,
                underwater = Ped.Underwater,
                underwaterTime = ESX.Math.Round(Ped.UnderwaterTime, 2),
                id = GetPlayerServerId(PlayerId()),
                job = ESX.PlayerData.job.label,
                rankLabel = ESX.PlayerData.job.grade_name or 'undefined',
                talkingMode = proximity.index,
            }
        })
    end)
end)

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    if ESX and ESX.PlayerLoaded then
        SendNUIMessage({ app = 'dHud', method = 'state', data = true })
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        SetRadarBigmapEnabled(false, false)
    end
end)

local setPhoneUp = function (data)
    SendNUIMessage({ app = 'dHud', method = 'update-phone-up', data = data })
    phoneUp = data
end
exports('setPhoneUp', setPhoneUp)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5 * 60 * 1000)

        local statusName = 'energy'

        TriggerEvent('esx_status:getStatus', statusName, function(status)
            if status ~= nil and status:getPercent() < 30.0 then
                ESX.ShowNotification(Config.Lang['feel_tired'])
            end
        end)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5 * 60 * 1000)
        local statusName = 'hunger'
        TriggerEvent('esx_status:getStatus', statusName, function(status)
            if status ~= nil and status:getPercent() < 30.0 then
                ESX.ShowNotification(Config.Lang['feel_hungry'])
            elseif status ~= nil and status:getPercent() < 10.0 then
                ESX.ShowNotification(Config.Lang['feel_starving'])
            end
        end)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5 * 60 * 1000)
        local statusName = 'thirst'
        TriggerEvent('esx_status:getStatus', statusName, function(status)
            if status ~= nil and status:getPercent() < 30.0 then
                ESX.ShowNotification(Config.Lang['feel_thirsty'])
            elseif status ~= nil and status:getPercent() < 10.0 then
                ESX.ShowNotification(Config.Lang['feel_ultra_thirsty'])
            end
        end)
    end
end)

RegisterCommand('showhud', function()
    SendNUIMessage({ app = 'dHud', method = 'state', data = not hudOpen })
    hudOpen = not hudOpen
end, false)

RegisterKeyMapping('showhud', Config.Lang['show_hud_cmd'], 'mouse_button', 'MOUSE_MIDDLE')

local Display = function(data)
    SendNUIMessage({ app = 'dHud', method = 'state', data = data })
    hudOpen = data
end

exports('Display', Display)

---@param mode boolean
local function setSeatbeltStatus(mode)
    SendNUIMessage({ app = 'dHud', method = 'update-seatbelt', data = mode })
end

exports('setSeatbeltStatus', setSeatbeltStatus)