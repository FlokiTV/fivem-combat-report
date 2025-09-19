local Games = {}

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

local function startRound(roundId)
    local game = Games.data['matchmaking-01']
    if not game then return end
    game.rounds.current = roundId
    game.rounds.data[roundId] = {}
end

local function endRound(roundId)
    local game = Games.data['matchmaking-01']
    if not game then return end
    game.rounds.current = 0
    game.rounds.data[roundId] = nil
end

local function insertCombatReport(victim, report)
    local game = Games.data['matchmaking-01']
    if not game then return end
    local roundId = game.rounds.current
    if roundId == 0 then return end
    report.victim = victim
    table.insert(game.rounds.data[roundId], report)
end

local function getPlayerRoundReport(player)
    local game = Games.data['matchmaking-01']
    if not game then return end
    local roundId = game.rounds.current
    if roundId == 0 then return end
    local reports = game.rounds.data[roundId]
    if not reports then return end
    local playerReport = {}
    for _, report in ipairs(reports) do
        -- map all damage taken on round
        if report.victim == player then
            -- ensure attacker report
            if not playerReport[report.attacker] then
                playerReport[report.attacker] = {
                    damageTaken = 0,
                    damageDone = 0,
                    weaponHash = report.weaponHash,
                    -- weaponModel = report.weaponModel, TODO: Get from weapons hash map
                }
            end

            playerReport[report.attacker].damageTaken = playerReport[report.attacker].damageTaken + report.amount
            playerReport[report.attacker].weaponHash = report.weaponHash
        end
        -- map all damage done on round
        if report.attacker == player then
            -- ensure victim report
            if not playerReport[report.victim] then
                playerReport[report.victim] = {
                    damageTaken = 0,
                    damageDone = 0,
                    weaponHash = 0,
                    -- weaponModel = report.weaponModel, TODO: Get from weapons hash map
                }
            end
            playerReport[report.victim].damageDone = playerReport[report.victim].damageDone + report.amount
            playerReport[report.attacker].weaponHash = report.weaponHash
        end
    end
    return playerReport
end

RegisterNetEvent("combat:report")
AddEventHandler("combat:report", function(payload)
    local src = source
    insertCombatReport(src, payload)
end)
