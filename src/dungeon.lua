local dungeon_room = require("dungeon_room")

local dungeon = class({
    name = "dungeon"
})

function dungeon:new(name, danger_level)
    self.name = name or "Unnamed dungeon"
    self.danger_level = danger_level or 1
    self.rooms = {
        dungeon_room(self),
        dungeon_room(self),
        dungeon_room(self)
    }
end

return dungeon
