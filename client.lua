local function sendCombatReport(payload)
    TriggerServerEvent("combat:report", payload)
end

local function integerBitsToFloat(integerValue)
    local bytes = string.pack('I4', integerValue)
    local floatValue, _ = string.unpack('f', bytes)
    return floatValue
end

-- detect damage - https://forum.cfx.re/t/some-game-events-and-how-to-use-them/4430331
AddEventHandler("gameEventTriggered", function(name, args)
    if not name or not args then return end
    if name == "CEventNetworkEntityDamage" then
        local victim = args[1]
        local damager = args[2]
        local damage = args[3]
        local damageConverted = integerBitsToFloat(damage) -- Some values have to be converted into proper floats.
        local enduranceDamage = args[4]
        local enduranceDamageConverted = integerBitsToFloat(enduranceDamage)
        local victimIncapacitated = args[5] == 1
        local victimKilled = args[6] == 1
        local weaponUsed = args[7]
        local victimSpeed = args[8]
        local victimSpeedConverted = integerBitsToFloat(victimSpeed)
        local damagerSpeed = args[9]
        local damagerSpeedConverted = integerBitsToFloat(damagerSpeed)
        local isResponsibleForCollision = args[10] == 1 -- Is vehicle responsible for the collision
        local isHeadshot = args[11] == 1
        local withMeleeWeapon = args[12] == 1
        local hitMaterial = args[13] -- returns indices from materials.dat

        local myselfPed = PlayerPedId()
        if victim and victim == myselfPed then
            -- pega o bone atingido
            local success, bone = GetPedLastDamageBone(myselfPed)
            local boneHit = success and bone or nil
            sendCombatReport({
                attacker   = GetPlayerServerId(damager),
                amount     = damageConverted,
                weaponHash = weaponUsed,
                hitBone    = boneHit,
                timestamp  = GetGameTimer(),
            })
        end
    end
end)

-- receive player round report
RegisterNetEvent("combat:playerReport")
AddEventHandler("combat:playerReport", function(playerReport)
    print("playerReport", playerReport)
end)
