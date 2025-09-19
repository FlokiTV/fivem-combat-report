local function sendCombatReport(payload)
    TriggerServerEvent("combat:report", payload)
end

-- detect damage - https://forum.cfx.re/t/some-game-events-and-how-to-use-them/4430331
AddEventHandler("gameEventTriggered", function(name, args)
    if not name or not args then return end
    if name == "CEventNetworkEntityDamage" then
        local victimNetId = args[1]
        local attackerNetId = args[2]
        local damageAmount = args[6]
        local weaponHash = args[7]

        local victim = NetworkGetEntityFromNetworkId(victimNetId)
        local attacker = NetworkGetEntityFromNetworkId(attackerNetId)

        local myselfPed = PlayerPedId()
        if victim and victim == myselfPed then
            -- pega o bone atingido
            local success, bone = GetPedLastDamageBone(myselfPed)
            local boneHit = success and bone or nil
            sendCombatReport({
                attacker   = GetPlayerServerId(attacker),
                amount     = damageAmount,
                weaponHash = weaponHash,
                hitBone    = boneHit,
                timestamp  = os.time()
            })
        end
    end
end)

-- receive player round report
RegisterNetEvent("combat:playerReport")
AddEventHandler("combat:playerReport", function(playerReport)
    print("playerReport", playerReport)
end)
