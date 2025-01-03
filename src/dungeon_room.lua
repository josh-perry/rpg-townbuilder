local spritesheet = require("spritesheet")
local items = require("data.items")

local Enemy = require("enemy")

local dungeon_room = class({
    name = "dungeon_room"
})

local function pick_item(danger_level)
    local eligible_items = functional.filter(items, function(item)
        return item.min_danger_level <= danger_level
    end)

    local eligible_item_weightings = functional.map(eligible_items, function(item)
        return item.rarity
    end)

    return table.pick_weighted_random(eligible_items, eligible_item_weightings)
end

function dungeon_room:new(dungeon, enemies, loot)
    self.dungeon = dungeon
    self.enemies = enemies or { Enemy() }
    self.loot = loot or {
        pick_item(dungeon.danger_level),
        pick_item(dungeon.danger_level)
    }
end

function dungeon_room:draw_preview(x, y)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, y, 100, 60)

    if #self.enemies > 0 then
        local sprite_w, sprite_h = spritesheet:get_sprite_size("Skull")

        local sprite_x = x + 50 - sprite_w / 2
        local sprite_y = y + 30 - sprite_h / 2

        spritesheet:draw_sprite("Skull", sprite_x, sprite_y)
    elseif #self.loot > 0 then
        local sprite_w, sprite_h = spritesheet:get_sprite_size("Chest")

        local sprite_x = x + 50 - sprite_w / 2
        local sprite_y = y + 30 - sprite_h / 2

        spritesheet:draw_sprite("Chest", sprite_x, sprite_y)
    end
end

return dungeon_room
