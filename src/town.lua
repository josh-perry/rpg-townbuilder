local Building = require("building")

local town = class({
    name = "town"
})

function town:new(name)
    self.name = name or "Cornelia"
    self.money = 1000

    local weapons_shop = Building("Weapons")
    weapons_shop:set_slot(1, "iron_sword", 1, 50)

    self.buildings = {
        Building("Inn"),
        Building("White Magic"),
        Building("Black Magic"),
        Building("Accessories"),
        weapons_shop,
        Building("Armour"),
    }
end

function town:draw()
    local x, y = 100, 100

    for _, building in ipairs(self.buildings) do
        building:draw(x, y)

        x = x + building.width + 10
    end
end

return town
