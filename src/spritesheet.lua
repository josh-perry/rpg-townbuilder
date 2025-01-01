local SpriteSheet = class({
	name = "spritesheet",
})

local json = require("lib.json")

function SpriteSheet:new(imageName)
	self.json_path = ("%s.json"):format(imageName)
	self.image_path = ("%s.png"):format(imageName)
	self.image = love.graphics.newImage(self.image_path)

	self.sprite_quads = {}

	local data = json.decode(love.filesystem.read(self.json_path))
	local w, h = data.meta.size.w, data.meta.size.h

	for _, slice in ipairs(data.meta.slices) do
		local frame = slice.keys[1]

		self.sprite_quads[slice.name] =
			love.graphics.newQuad(frame.bounds.x, frame.bounds.y, frame.bounds.w, frame.bounds.h, w, h)
	end
end

function SpriteSheet:draw_sprite(spriteName, x, y, rot, sx, sy, ox, oy)
	love.graphics.draw(self.image, self.sprite_quads[spriteName], x, y, rot or 0, sx or 1, sy or 1, ox or 0, oy or 0)
end

function SpriteSheet:get_sprite_size(spriteName)
    local quad = self.sprite_quads[spriteName]
    local _, _, w, h = quad:getViewport()

    return w, h
end

return SpriteSheet("assets/spritesheet")
