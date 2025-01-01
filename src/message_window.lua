local spritesheet = require("spritesheet")

local topColour = { 0.05, 0.05, 0.4 }
local bottomColour = { 0.0, 0.0, 0.06 }

local mwinMesh = love.graphics.newMesh({
    { 0, 0, 0, 0, unpack(topColour) },
    { 1, 0, 1, 0, unpack(topColour) },
    { 1, 1, 1, 1, unpack(bottomColour) },
    { 0, 1, 0, 1, unpack(bottomColour) }
}, "fan")

local function draw_text(text, x, y, limit, align)
    local font = love.graphics.getFont()

    local lineIcons = {}
    for p in text:gmatch("{{(.-)}}") do
        table.insert(lineIcons, p)
    end

    local text = text:gsub("{{(.-)}}", "$")
    local parts = text:split("$")

    local x = x
    for j, part in ipairs(parts) do
        love.graphics.printf(part, x, y, limit, align)
        x = x + font:getWidth(part)

        if lineIcons[j] then
            spritesheet:draw_sprite(lineIcons[j], x, y)

            local _, _, w, _ = spritesheet.sprite_quads[lineIcons[j]]:getViewport()
            x = x + w
        end
    end
end

local function draw_box(x, y, w, h)
    love.graphics.draw(mwinMesh, x, y, 0, w, h)

	local s = 5

    local mid_height_remainder = h - (s * 2)
	local mid_width_remainder = w - (s * 2)

    local stretch_h = mid_height_remainder / s
	local stretch_w = mid_width_remainder / s

	-- Top
    spritesheet:draw_sprite("MwinTopLeft", x, y)
    spritesheet:draw_sprite("MwinTopRight", x + w - s, y)
    spritesheet:draw_sprite("MwinTopMiddle", x + s, y, 0, stretch_w, 1)

	-- Middle
    spritesheet:draw_sprite("MwinMiddleLeft", x, y + s, 0, 1, stretch_h)
    spritesheet:draw_sprite("MwinMiddleRight", x + w - s, y + s, 0, 1, stretch_h)

	-- Bottom
    spritesheet:draw_sprite("MwinBottomLeft", x, y + h - s)
    spritesheet:draw_sprite("MwinBottomRight", x + w - s, y + h - s)
    spritesheet:draw_sprite("MwinBottomMiddle", x + s, y + h - s, 0, stretch_w, 1)
end

local function draw(text, x, y, w, h, align)
    local s = 5
    draw_box(x, y, w, h)

    if not text then
        return
    end

    local font = love.graphics.getFont()
    if type(text) == "string" then
        draw_text(text, x + s * 2, (y + s * 2), w - s * 4, align)
        return
    end

    local y_offset = 0
    for _, t in ipairs(text) do
        draw_text(t, x + s * 2, (y + s * 2) + y_offset, w - s, align)
        y_offset = y_offset + font:getHeight(t) + 5
    end
end

return {
    draw = draw,
    draw_box = draw_box
}
