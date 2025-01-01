local party = class({
    name = "party"
})

function party:new(members)
    self.members = members or {}

    for _, member in ipairs(self.members) do
        member.party = self
    end
end

function party:enter_dungeon(dungeon)
    self.dungeon = dungeon
    self.room_index = 1
end

return party
