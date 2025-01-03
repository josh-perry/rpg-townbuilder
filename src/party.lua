local Party = class({
    name = "party"
})

function Party:new(members)
    self.members = members or {}

    for _, member in ipairs(self.members) do
        member.party = self
    end

    self.loot = {}
end

function Party:enter_dungeon(dungeon)
    self.dungeon = dungeon
    self.room_index = 1
end

function Party:add_loot(item)
    table.insert(self.loot, item)
end

return Party
