local spritesheet = require("spritesheet")

local Enemy = require("enemy")

local dungeon_room = class({
    name = "dungeon_room"
})

function dungeon_room:new(dungeon, enemies, loot)
    self.dungeon = dungeon
    self.enemies = enemies or { Enemy() }
    self.loot = loot or {}
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
