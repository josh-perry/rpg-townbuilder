local party_member = class({
    name = "party_member"
})

function party_member:new(job, name, level)
    self.job = job
    self.name = name or "Unnamed hero"
    self.level = level or 1

    self.max_health = 10
    self.health = self.max_health

    self.agility = love.math.random(7, 15)
    self.power = love.math.random(5, 10)
    self.wisdom = 10
    self.atb_bar = 0
end

function party_member:is_alive()
    return self.health > 0
end

function party_member:damage(amount)
    self.health = math.max(0, self.health - amount)

    pubsub:publish("party_member:Damage", self, amount)

    if not self:is_alive() then
        pubsub:publish("party_member:Death", self)
        pubsub:publish("Dungeon:party_memberDeath", self.party.dungeon, self)
        self.atb_bar = 0
    end
end

return party_member
