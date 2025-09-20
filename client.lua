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


function DrawTextCustom(x, y, text, scale, color, font, center)
    -- Defaults
    scale  = scale or 0.35
    font   = font or 0
    color  = color or { r = 255, g = 255, b = 255, a = 255 }
    center = center or false

    SetTextFont(font)
    SetTextProportional(false)
    SetTextScale(scale, scale)
    SetTextColour(color.r, color.g, color.b, color.a)
    SetTextCentre(center)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

local function drawCombatReport(y, color)
    DrawTextCustom(0.80, y, "out: 80", 0.45, color, 4, false)
    DrawTextCustom(0.80, y + 0.02, "head: 0", 0.45, color, 4, false)
    DrawTextCustom(0.80, y + 0.04, "chest: 0", 0.45, color, 4, false)
    DrawTextCustom(0.80, y + 0.06, "legs: 0", 0.45, color, 4, false)
    DrawTextCustom(0.84, y, "Floki", 0.45, color, 4, false)
    DrawTextCustom(0.84, y + 0.02, "Pistol", 0.45, color, 4, false)
    DrawTextCustom(0.88, y, "in: 145", 0.45, color, 4, false)
    DrawTextCustom(0.88, y + 0.02, "head: 0", 0.45, color, 4, false)
    DrawTextCustom(0.88, y + 0.04, "chest: 0", 0.45, color, 4, false)
    DrawTextCustom(0.88, y + 0.06, "legs: 0", 0.45, color, 4, false)
end

local color = { r = 255, g = 255, b = 255, a = 255 }

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5)
        local y = 0.45
        drawCombatReport(y, color)
        drawCombatReport(y + 0.1, color)
    end
end)

-- test commands

-- give pistol
RegisterCommand("givepistol", function(source, args, rawCommand)
    local myselfPed = PlayerPedId()
    GiveWeaponToPed(myselfPed, GetHashKey('WEAPON_PISTOL'), 100, false, true)
end, false)
