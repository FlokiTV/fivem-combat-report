local Games = {}

Games.weapons = {}
Games.weapons[-842959696] = 'Fall'
Games.weapons[GetHashKey('WEAPON_PISTOL')] = 'Pistol'
Games.weapons[GetHashKey('weapon_assaultrifle')] = 'Rifle'

Games.bones = {}
Games.bones[57005] = {
    name = 'SKEL_R_HAND',
    group = "chest"
}
Games.bones[18905] = {
    name = 'SKEL_L_HAND',
    group = "chest"
}
Games.bones[52301] = {
    name = 'SKEL_R_FOOT',
    group = "foot"
}
Games.bones[14201] = {
    name = 'SKEL_L_FOOT',
    group = "foot"
}
Games.bones[31086] = {
    name = 'SKEL_HEAD',
    group = "head"
}

Games.data = {
    ['matchmaking-01'] = {
        players = {
            data = {
                attackers = {
                    [10] = {
                        nick = 'MidnightWolf',
                        group = 'group:10',
                        leader = true
                    },
                    [2] = {
                        nick = 'BlazeGamer',
                        group = 'group:4',
                        leader = false
                    },
                    [3] = {
                        nick = 'SpeedRacer',
                        group = 'group:4',
                        leader = false
                    },
                    [4] = {
                        nick = 'ShadowNinja',
                        group = 'group:4',
                        leader = true
                    },
                    [5] = {
                        nick = 'PhoenixFire',
                        group = 'group:4',
                        leader = false
                    }
                },
                defenders = {
                    [6] = {
                        nick = 'ThunderBolt',
                        group = 'group:6',
                        leader = true
                    },
                    [7] = {
                        nick = 'GhostRider',
                        group = 'group:6',
                        leader = false
                    },
                    [8] = {
                        nick = 'NeonSpectre',
                        group = 'group:9',
                        leader = false
                    },
                    [9] = {
                        nick = 'DriftKing',
                        group = 'group:9',
                        leader = true
                    },
                    [1] = {
                        nick = 'ViperGT',
                        group = 'group:1',
                        leader = true
                    }
                }
            }
        },
        rounds = {
            current = 1,
            data = {
                [1] = {
                    -- Insira os dados da rodada aqui.
                }
            }
        }
    }
}

--
local roomName = 'matchmaking-01'

local function nextRound()
    local game = Games.data[roomName]
    if not game then return end
    game.rounds.current = game.rounds.current + 1
    game.rounds.data[game.rounds.current] = {}
end

local function getWeaponName(weaponHash)
    return Games.weapons[weaponHash] or 'Unknown'
end

local function getPlayerName(player)
    local game = Games.data[roomName]
    if not game then return end
    local playerData = game.players.data
    if not playerData then return end
    local player = playerData.attackers[player] or playerData.defenders[player]
    if not player then return end
    return player.nick
end

local function insertCombatReport(victim, report)
    local game = Games.data[roomName]
    if not game then return end
    local roundId = game.rounds.current
    if roundId == 0 then return end
    report.victim = victim
    table.insert(game.rounds.data[roundId], report)
end

local function initPlayerReport(player)
    return {
        name = getPlayerName(player),
        damageTaken = 0,
        damageDone = 0,
        weaponHash = nil,
        weaponModel = nil,
        damageBonesTaken = {
            head = {
                damage = 0,
                hits = 0,
            },
            chest = {
                damage = 0,
                hits = 0,
            },
            foot = {
                damage = 0,
                hits = 0,
            },
        },
        damageBonesDone = {
            head = {
                damage = 0,
                hits = 0,
            },
            chest = {
                damage = 0,
                hits = 0,
            },
            foot = {
                damage = 0,
                hits = 0,
            },
        },
    }
end

local function getPlayerRoundReport(player, roundId)
    local game = Games.data[roomName]
    if not game then return end
    if not roundId then return end
    local reports = game.rounds.data[roundId]
    if not reports then return end
    local playerReport = {}
    for _, report in ipairs(reports) do
        -- map all damage taken on round
        if report.victim == player then
            -- ensure attacker report
            if not playerReport[report.attacker] then
                playerReport[report.attacker] = initPlayerReport(report.attacker)
            end

            playerReport[report.attacker].damageTaken = playerReport[report.attacker].damageTaken + report.amount
            playerReport[report.attacker].weaponHash = report.weaponHash
            playerReport[report.attacker].weaponModel = getWeaponName(report.weaponHash)
            -- map damage by bone
            if report.hitBone and Games.bones[report.hitBone] then
                local boneGroup = Games.bones[report.hitBone].group
                if boneGroup then
                    playerReport[report.attacker].damageBonesTaken[boneGroup].damage = playerReport[report.attacker]
                        .damageBonesTaken[boneGroup].damage + report.amount
                    playerReport[report.attacker].damageBonesTaken[boneGroup].hits = playerReport[report.attacker]
                        .damageBonesTaken[boneGroup].hits + 1
                end
            end
        end
        -- map all damage done on round
        if report.attacker == player then
            -- ensure victim report
            if not playerReport[report.victim] then
                playerReport[report.victim] = initPlayerReport(report.victim)
            end

            playerReport[report.victim].damageDone = playerReport[report.victim].damageDone + report.amount
            playerReport[report.victim].weaponHash = report.weaponHash
            playerReport[report.victim].weaponModel = getWeaponName(report.weaponHash)
            -- map damage by bone
            if report.hitBone and Games.bones[report.hitBone] then
                local boneGroup = Games.bones[report.hitBone].group
                if boneGroup then
                    playerReport[report.victim].damageBonesDone[boneGroup].damage = playerReport[report.victim]
                        .damageBonesDone[boneGroup].damage + report.amount
                    playerReport[report.victim].damageBonesDone[boneGroup].hits = playerReport[report.victim]
                        .damageBonesDone[boneGroup].hits + 1
                end
            end
        end
    end
    return playerReport
end

RegisterNetEvent("combat:report")
AddEventHandler("combat:report", function(payload)
    local src = source
    insertCombatReport(src, payload)
    -- dumpTable(payload)
end)

RegisterNetEvent("combat:requestPlayerReport")
AddEventHandler("combat:requestPlayerReport", function()
    local src = source
    local round = Games.data[roomName].rounds.current
    local playerReport = getPlayerRoundReport(src, round)
    -- dumpTable(Games.data[roomName].rounds.data[round])
    TriggerClientEvent("combat:playerReport", src, playerReport)
end)

RegisterNetEvent("combat:nextRound")
AddEventHandler("combat:nextRound", function()
    nextRound()
end)