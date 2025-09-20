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

local function drawCombatReport(y, color, report)
    DrawTextCustom(0.80, y, "out: " .. round(report.damageTaken), 0.45, color, 4, false)
    DrawTextCustom(0.80, y + 0.02, "head: " .. round(report.damageBonesTaken.head.damage), 0.45, color, 4, false)
    DrawTextCustom(0.80, y + 0.04, "chest: " .. round(report.damageBonesTaken.chest.damage), 0.45, color, 4, false)
    DrawTextCustom(0.80, y + 0.06, "legs: " .. round(report.damageBonesTaken.foot.damage), 0.45, color, 4, false)
    DrawTextCustom(0.84, y, report.name, 0.45, color, 4, false)
    DrawTextCustom(0.84, y + 0.02, report.weaponModel, 0.45, color, 4, false)
    DrawTextCustom(0.90, y, "in: " .. round(report.damageDone), 0.45, color, 4, false)
    DrawTextCustom(0.90, y + 0.02, "head: " .. round(report.damageBonesDone.head.damage), 0.45, color, 4, false)
    DrawTextCustom(0.90, y + 0.04, "chest: " .. round(report.damageBonesDone.chest.damage), 0.45, color, 4, false)
    DrawTextCustom(0.90, y + 0.06, "legs: " .. round(report.damageBonesDone.foot.damage), 0.45, color, 4, false)
end

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
        local damagerId = damager == -1 and NetworkGetNetworkIdFromEntity(myselfPed) or
        NetworkGetNetworkIdFromEntity(damager)
        if victim and victim == myselfPed then
            -- pega o bone atingido
            local success, bone = GetPedLastDamageBone(myselfPed)
            local boneHit = success and bone or nil
            sendCombatReport({
                attacker   = damagerId,
                amount     = damageConverted,
                weaponHash = weaponUsed,
                hitBone    = boneHit,
                timestamp  = GetGameTimer(),
            })
        end
    end
end)



local color = { r = 255, g = 255, b = 255, a = 255 }
local threadRunning = false
-- receive player round report
RegisterNetEvent("combat:playerReport")
AddEventHandler("combat:playerReport", function(playerReport)
    dumpTable(playerReport)
    Citizen.CreateThread(function()
        while threadRunning do
            Citizen.Wait(5)
            local y = 0.45
            for _, report in pairs(playerReport) do
                drawCombatReport(y, color, report)
                y = y + 0.1
            end
        end
    end)
end)
-- test commands

-- give pistol
RegisterCommand("givepistol", function(source, args, rawCommand)
    local myselfPed = PlayerPedId()
    GiveWeaponToPed(myselfPed, GetHashKey('WEAPON_PISTOL'), 100, false, true)
end, false)

-- request report
RegisterCommand("report", function(source, args, rawCommand)
    if threadRunning then
        threadRunning = false
        print("Thread parada!")
        return
    end
    threadRunning = true
    print("Thread iniciada!")
    TriggerServerEvent("combat:requestPlayerReport")
end, false)
