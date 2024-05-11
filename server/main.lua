ESX.RegisterServerCallback('dHud:getServerData', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end 

    local policeCount = 0
    local mechanicCount = 0 
    local ambulanceCount = 0 
    local taxiCount = 0 

    local xPlayers = ESX.GetPlayers()

    for i=1, #xPlayers, 1 do
        local player = ESX.GetPlayerFromId(xPlayers[i])
        if player then
            if player.job.name == 'police' then 
                policeCount = policeCount + 1 
            elseif player.job.name == 'mechanic' then 
                mechanicCount = mechanicCount + 1 
            elseif player.job.name == 'ambulance' then 
                ambulanceCount = ambulanceCount + 1 
            elseif player.job.name == 'taxi' then 
                taxiCount = taxiCount + 1
            end
        end
    end

    cb({
        policeCount = policeCount,
        ambulanceCount = ambulanceCount, 
        mechanicCount = mechanicCount,
        taxiCount = taxiCount,
        onlinePlayers = #xPlayers
    })

end)




