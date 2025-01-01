local message_window = require("message_window")
local spritesheet = require("spritesheet")

local items = require("data.items")

local building = class({
    name = "building"
})

function building:new(name)
    self.name = name or "Unnamed building"
    self.max_slots = 4
    self.stock_type = "weapon"
    self.slots = {}
    self.width = 170
    self.height = self.max_slots * 74 + 40
end

function building:setSlot(slot, item, quantity, price)
    assert(slot >= 1 and slot <= self.max_slots, "Invalid slot number")

    self.slots[slot] = {
        item = item,
        quantity = quantity,
        price = price
    }
end

function building:draw(x, y)
    message_window.draw_box(x, y, self.width, self.height)
    love.graphics.printf(self.name, x + 12, y + 12, self.width - 24, "center")

    y = y + 40

    local slot_height = 64

    for i = 1, self.max_slots do
        local slot = self.slots[i]

        message_window.draw_box(x + 12, y, self.width - 24, slot_height)

        if slot then
            local base_item = items[self.stock_type][slot.item]

            spritesheet:draw_sprite(base_item.icon, x + 24, y + 12, 0, 1, 1)

            love.graphics.print(("%s x %d"):format(base_item.name, slot.quantity), x + 12 + 36, y + 12)
            love.graphics.printf(("%d"):format(slot.price), x + 12, y + 36, self.width - 36, "right")
        end

        y = y + 74
    end
end

return building
