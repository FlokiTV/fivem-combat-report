local function sendCombatReport(payload)
    TriggerServerEvent("combat:report", payload)
end

-- detect damage
AddEventHandler("gameEventTriggered", function(name, args)
    if not name or not args then return end
    if name == "CEventNetworkEntityDamage" or name == "CEventDamage" then
        local victimNetId = args[1]
        local attackerNetId = args[2]
        local weaponHash = args[3]
        local damageAmount = 0
        -- find index for damage
        for i = 4, #args do
            if type(args[i]) == "number" then
                damageAmount = args[i]
                break
            end
        end

        local victim = NetworkGetEntityFromNetworkId(victimNetId)
        local attacker = NetworkGetEntityFromNetworkId(attackerNetId)

        local myselfPed = PlayerPedId()
        if victim and victim == myselfPed then
            sendCombatReport({
                attacker = GetPlayerServerId(attacker),
                amount = damageAmount,
                weaponHash = weaponHash,
                timestamp = os.time()
            })
        end
    end
end)

-- receive player round report
RegisterNetEvent("combat:playerReport")
AddEventHandler("combat:playerReport", function(playerReport)
    print("playerReport", playerReport)
end)