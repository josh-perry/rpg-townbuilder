local atb_multiplier = 5

local function wait(t)
    local start = love.timer.getTime()

    while love.timer.getTime() - start < t do
        coroutine.yield()
    end
end

local function basic_ai(entity, other_team, dungeon)
    local valid_targets = functional.filter(other_team, function(e)
        return e:is_alive()
    end)

    local target = table.pick_random(valid_targets)
    local damage = love.math.random(0, entity.power)

    target:damage(damage)
    pubsub:publish("Dungeon:Message", dungeon, ("%s hits %s with {{Sword}}IRON for %d damage!"):format(entity.name, target.name, damage))
    pubsub:publish("Dungeon:EntityAttack", entity, target)
end

local function fight_enemies(party, enemies)
    local dungeon = party.dungeon
    local turn_order = {}

    for _, member in ipairs(party.members) do
        table.insert(turn_order, member)
        member.atb_bar = 0 + love.math.random(0, member.agility)
    end

    for _, enemy in ipairs(enemies) do
        table.insert(turn_order, enemy)
        enemy.atb_bar = 0 + love.math.random(0, enemy.agility)
    end

    while true do
        local atbMultiplier = atb_multiplier * love.timer.getDelta()

        if #enemies == 0 or functional.all(enemies, function(e) return not e:is_alive() end) then
            pubsub:publish("Dungeon:Message", dungeon, "The room is clear of enemies!")
            break
        end

        if functional.all(party.members, function(e) return not e:is_alive() end) then
            pubsub:publish("Dungeon:Message", dungeon, "The party has been defeated!")
            break
        end

        table.sort(turn_order, function(a, b)
            return a.atb_bar > b.atb_bar
        end)

        for _, entity in ipairs(turn_order) do
            if entity:is_alive() then
                entity.atb_bar = entity.atb_bar + entity.agility * atbMultiplier
            end
        end

        local entity = turn_order[1]
        if entity.atb_bar >= 100 then
            pubsub:publish("Dungeon:EntityTurnStart", dungeon, entity)

            local is_player = functional.contains(party.members, entity)
            basic_ai(entity, is_player and enemies or party.members, dungeon)

            entity.atb_bar = 0
        end

        coroutine.yield("FightingEnemies")
    end

    functional.foreach(party.members, function(member)
        member.atb_bar = 0
    end)
end

local dungeon_runningCoroutine = coroutine.create(function(party)
    while true do
        local room = party.dungeon.rooms[party.room_index]

        if room then
            pubsub:publish("Dungeon:Message", party.dungeon, ("Entering room %i..."):format(party.room_index))

            while true do
                local enemies = room.enemies

                if not enemies or #enemies == 0 then
                    break
                end

                fight_enemies(party, enemies)

                if functional.all(party.members, function(e) return not e:is_alive() end) then
                    return
                end

                -- Move to next room
                party.room_index = party.room_index + 1
                wait(2)
                break
            end
        end

        if not room then
            break
        end

        coroutine.yield("RoomComplete")
    end

    pubsub:publish("Dungeon:Complete", party.dungeon)
end)

return dungeon_runningCoroutine
