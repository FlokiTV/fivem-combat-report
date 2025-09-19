# FiveM Combat Report

A comprehensive combat tracking and reporting system for FiveM servers that provides detailed damage statistics and combat analytics for players.

## Features

- **Real-time Combat Tracking**: Automatically detects and logs all damage events between players
- **Detailed Damage Reports**: Tracks damage by weapon type, body part hit, and amount
- **Round-based System**: Organizes combat data into rounds for structured gameplay
- **Player Statistics**: Provides comprehensive damage taken/dealt statistics per player
- **Body Part Analysis**: Categorizes hits by head, chest, and foot regions
- **Weapon Recognition**: Identifies and logs weapon types used in combat

## How It Works

### Client-Side
The client script automatically detects damage events using the `CEventNetworkEntityDamage` game event. When a player takes damage, it:
- Captures the attacker information
- Records the damage amount and weapon used
- Identifies the body part that was hit
- Sends this data to the server for processing

### Server-Side
The server maintains a comprehensive database of combat events, including:
- Player information (nicknames, groups, leadership roles)
- Round management system
- Damage tracking by weapon and body part
- Statistical analysis and reporting


## For Developers
You can integrate with the combat report system using the following events:

#### Client Events
```lua
-- Request player's combat report
TriggerServerEvent("combat:requestPlayerReport", payload)

-- Receive combat report data
RegisterNetEvent("combat:playerReport")
AddEventHandler("combat:playerReport", function(playerReport)
    -- Handle the received report data
end)
```

#### Server Events
```lua
-- Receive combat damage report
RegisterNetEvent("combat:report")
AddEventHandler("combat:report", function(payload)
    -- payload contains: attacker, amount, weaponHash, hitBone, timestamp
end)
```

## Data Structure
example: [https://onecompiler.com/lua/43x7zty26](https://onecompiler.com/lua/43x7zty26)

### Combat Report Payload
```lua
{
    attacker = playerId,      -- Server ID of the attacking player
    amount = damageAmount,    -- Amount of damage dealt
    weaponHash = weaponHash,  -- Hash of the weapon used
    hitBone = boneId,        -- ID of the bone/body part hit
    timestamp = os.time()     -- Timestamp of the event
}
```

### Player Report Structure
```lua
{
    [playerId] = {
        name = "PlayerName",
        damageTaken = 150,
        damageDone = 200,
        weaponHash = 0x123,
        weaponModel = "Pistol",
        damageBonesTaken = {
            head = { damage = 50, hits = 2 },
            chest = { damage = 75, hits = 3 },
            foot = { damage = 25, hits = 1 }
        },
        damageBonesDone = {
            head = { damage = 100, hits = 4 },
            chest = { damage = 75, hits = 3 },
            foot = { damage = 25, hits = 1 }
        }
    }
}
```

## Body Parts Tracking

The system categorizes damage by three main body regions:
- **Head**: Critical hits to the head area
- **Chest**: Torso and upper body hits
- **Foot**: Lower body and leg hits

## Configuration

### Adding New Weapons
To add support for additional weapons, modify the `Games.weapons` table in `server.lua`:
```lua
Games.weapons[GetHashKey('WEAPON_NAME')] = 'Display Name'
```

### Modifying Body Parts
Body part mappings can be customized in the `Games.bones` table:
```lua
Games.bones[boneId] = {
    name = 'BONE_NAME',
    group = "body_region"
}
```