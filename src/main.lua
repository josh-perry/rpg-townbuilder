require("lib.batteries"):export()
pubsub:new()

local jobs = require("data.jobs")

local Dungeon = require("dungeon")
local party_member = require("party_member")
local Party = require("party")
local Town = require("town")

local spritesheet = require("spritesheet")
local message_window = require("message_window")

local town = Town()

local party = Party({
    party_member(jobs.fighter, "Josh", 1),
    party_member(jobs.fighter, "Bowser", 1),
    party_member(jobs.fighter, "Chester", 1)
})

local dungeon = Dungeon("Caverns of Chaos", 1)
party:enter_dungeon(dungeon)

local messages = {}

local dungeon_running_coroutine = require("dungeon_running")

love.graphics.setFont(love.graphics.newFont("assets/font/Empire 9p.ttf", 16))

local days = {
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
}
local day = 1
local day_time = 0

local function draw_time_ui()
    local clockX = love.graphics.getWidth() - 210
    local clockY = 52
    message_window.draw(days[day], (love.graphics.getWidth()) - 210, 10, 200, 40, "center")

    spritesheet:draw_sprite("TimeBar", clockX, clockY)

    love.graphics.setScissor(clockX, clockY, 210 * (day_time), 8)
    spritesheet:draw_sprite("TimeBarFull", clockX, clockY)
    love.graphics.setScissor()
end

local function draw_town_ui()
    message_window.draw(town.name, (love.graphics.getWidth() / 2) - 100, 10, 200, 40, "center")
    message_window.draw(("{{Money}} %d"):format(town.money), 10, 10, 100, 40, "center")

    town:draw()
end

local modes = {
    "town",
    "dungeon"
}

local mode = 1

function love.draw()
    love.graphics.setColor(1, 1, 1)

    if modes[mode] == "town" then
        draw_town_ui()
    end

    if modes[mode] == "dungeon" then
        for i, member in ipairs(party.members) do
            if member:is_alive() then
                love.graphics.setColor(1, 1, 1)
            else
                love.graphics.setColor(0.5, 0.5, 0.5)
            end

            love.graphics.print(member.name, 10, 14 * i)
            love.graphics.printf(("%d/%d"):format(member.health, member.max_health), 100, 14 * i, 50, "right")

            spritesheet:draw_sprite("AtbBar", 150, 14 * i)

            love.graphics.setScissor(150, 14 * i, 64 * (member.atb_bar / 100), 8)
            spritesheet:draw_sprite("AtbBarFull", 150, 14 * i)
            love.graphics.setScissor()
        end

        for i, room in ipairs(dungeon.rooms) do
            if party.room_index == i then
                local handW, handH = spritesheet:get_sprite_size("Hand")
                local handX = 100 - handW - 10
                local handY = 60 + (i * 70) - (handH / 2) + 30
                spritesheet:draw_sprite("Hand", handX, handY)
            end

            room:draw_preview(100, 60 + (i * 70))
        end

        if not messages[dungeon] then
            messages[dungeon] = {}
        end

        message_window.draw(messages[dungeon], 400, 10, 400, love.graphics.getHeight() - 20)
    end

    draw_time_ui()
end

local dungeon_update_timer_max = 0
local dungeon_update_timer = dungeon_update_timer_max

local paused = true

function love.update(dt)
    if paused then
        return
    end

    day_time = day_time + (dt / 30)

    if day_time >= 1 then
        day_time = 0
        day = day + 1

        if day > #days then
            day = 1
        end
    end

    dungeon_update_timer = dungeon_update_timer - dt

    if dungeon_update_timer <= 0 then
        dungeon_update_timer = dungeon_update_timer_max

        if coroutine.status(dungeon_running_coroutine) ~= "dead" then
            local ok, message = coroutine.resume(dungeon_running_coroutine, party)

            if not ok then
                print(message)
            end
        end
    end
end

function love.keypressed(key)
    if key == "space" then
        paused = not paused
    elseif key == "tab" then
        mode = mode + 1

        if mode > #modes then
            mode = 1
        end
    end
end

local function add_message(dungeon, message)
    assert(dungeon, "Dungeon is nil")

    if not messages[dungeon] then
        messages[dungeon] = {}
    end

    table.insert(messages[dungeon], message)
end

pubsub:subscribe("Dungeon:EntityTurnStart", function(dungeon, entity)
end)

pubsub:subscribe("Dungeon:EntityAttack", function(dungeon, entity, target)
end)

pubsub:subscribe("Dungeon:EntityDeath", function(dungeon, entity)
end)

pubsub:subscribe("Dungeon:Message", function(dungeon, message)
    add_message(dungeon, message)
end)

pubsub:subscribe("Dungeon:Complete", function(dungeon, party)
    add_message(dungeon, "Dungeon complete!")

    add_message(dungeon, "Escaped with: ")
    for _, v in ipairs(party.loot) do
        add_message(dungeon, v.name)
    end
end)

pubsub:subscribe("Dungeon:party_memberDeath", function(dungeon, party_member)
    add_message(dungeon, ("%s has died!"):format(party_member.name))
end)
