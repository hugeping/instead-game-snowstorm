require "sprite"
require "theme"
require "snd"
if not theme.name() or theme.name():find(".", 1, true) ~= 1 then
	dprint "Disabling pictures"
local titles = [[
{$fmt c|{$fmt b|МЕТЕЛЬ}^^

{$fmt em|История и код:}^
Пётр Косых^
{$fmt em|Иллюстрации:}^
Pakowacz^^

{$fmt em|По мотивам:}^
Коралина // Нил Гейман^^

{$fmt em|Музыка:}^
Largo – from Concerto No 5 – J.S. Bach // Jon Sayles^^

{$fmt em|Движок:}^
INSTEAD3: МЕТАПАРСЕР3 // Пётр Косых^^

http://instead.syscall.ru^^

{$fmt em|Альфа тестирование:}^
spline^^

{$fmt em|Благодарности:}^
Семье (за терпение)^
Работодателю (за зарплату)^
Вам (за прохождение нашей игры)^
Всем тем, кто не мешал^^

{$fmt b|КОНЕЦ}^^

{$fmt em|Февраль 2019}}]];

room {
	nam = 'titles';
	title = false;
	dsc = titles;
	noparser = true;
	enter = function(s)
		snd.music 'mus/largo.ogg'
	end;
}

else
require "titles"
global 'pictures' ({})

local spr
local spr_blank
local spr_pos = 0

function game:timer()
	if not spr then
		return false
	end
	local w, h = spr:size()
	local ww, hh = spr_blank:size()
	if spr_pos >= w - ww then
		timer:stop()
		return false
	end
	spr_blank:fill('#ffffff')
	spr:copy(spr_pos, 0, ww, hh, spr_blank)
	if spr_pos < w - ww then
		spr_pos = spr_pos + 1
	end
	return false
end

game.pic = function(s)
	local mobile = theme.name():find("^%.mobile")
	local top = #pictures
	if top == 0 then
		return false
	end
	local p = pictures[top]
	if p:find("%-pan") and not mobile then
		if not spr then
			instead.fading(true)
			spr = sprite.new(p)
			local w, h = spr:size()
			local hh = tonumber(theme.get'scr.gfx.h')
			spr = spr:scale(hh/h)
			spr_pos = 0
			timer:set(50)
			if not spr_blank then
				spr_blank = sprite.new(theme.get'scr.gfx.w', theme.get'scr.gfx.h')
			end
			local ww, hh = spr_blank:size()
			spr:copy(0, 0, ww, hh, spr_blank)
		end
		return spr_blank
	else
		return p
	end
end

function pic_push(name)
	spr = false
	timer:stop()
	instead.need_fading(true)
	if theme.name():find("^%.mobile") then
		mp:clear()
	end
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
	if theme.name():find("^%.mobile") then
		mp:clear()
	end
	spr = false
	timer:stop()
end
end
