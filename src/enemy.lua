local enemy = class({
    name = "enemy"
})

function enemy:new()
    self.name = "Unnamed enemy"
    self.level = 1

    self.max_health = 10
    self.health = self.max_health

    self.agility = 10
    self.power = 10
    self.wisdom = 10
    self.atb_bar = 0
end

function enemy:is_alive()
    return self.health > 0
end

function enemy:damage(amount)
    self.health = math.max(0, self.health - amount)

    pubsub:publish("Enemy:Damage", self, amount)

    if not self:is_alive() then
        pubsub:publish("Enemy:Death", self)
        pubsub:publish("Dungeon:EnemyDeath", self.dungeon, self)
        self.atb_bar = 0
    end
end

return enemy
