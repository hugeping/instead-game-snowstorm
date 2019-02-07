require "sprite"
require "theme"

if theme.name():find(".", 1, true) ~= 1 then
	dprint "Disabling pictures"
else

global 'pictures' ({})

local spr
local spr_blank
local spr_pos = 0

function game:timer()
	if spr then
		local w, h = spr:size()
		local ww, hh = spr_blank:size()
		spr_blank:fill('#ffffff')
		spr:copy(spr_pos, 0, ww, hh, spr_blank)
		if spr_pos < w - ww then
			spr_pos = spr_pos + 1
		end
	end
	return false
end

game.pic = function(s)
	local top = #pictures
	if top == 0 then
		return false
	end
	local p = pictures[top]
	if p:find("%-pan") then
		if not spr then
			spr = sprite.new(p)
			local w, h = spr:size()
			local hh = tonumber(theme.get'scr.gfx.h')
			spr = spr:scale(hh/h)
			spr_pos = 0
			timer:set(50)
			if not spr_blank then
				spr_blank = sprite.new(theme.get'scr.gfx.w', theme.get'scr.gfx.h')
				spr:copy(spr_blank)
			end
		end
		return spr_blank
	else
		return p
	end
end

function pic_push(name)
	instead.need_fading(true)
	table.insert(pictures, name)
end

function pic_pop()
	local top = #pictures
	if top == 0 then
		return
	end
	table.remove(pictures, top)
	spr = false
	timer:stop()
end

function pic_set(name)
	local top = #pictures
	if top == 0 then
		return pic_push(name)
	end
	if pictures[top] == name then
		return
	end
	pictures[top] = name
	instead.need_fading(true)
	spr = false
	timer:stop()
end
end
