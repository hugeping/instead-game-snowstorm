require "autotheme"
require "timer"
require "theme"
require "decor"
require "snd"
--require "fading"

obj {
	nam = 'mplayer';
	pos = 0;
	{
		playlist = {
			'01.ogg';
--			'02.ogg';
		}
	};
	life = function(s)
		if snd.music_playing() then
			return
		end
		s.pos = s.pos + 1
		if s.pos > #s.playlist then
			s.pos = 1
		end
		snd.music('mus/'..s.playlist[s.pos], 1);
	end
}

declare 'flake' (function(v)
	local sp = v.speed + rnd(2)
	local sp2 = v.speed + rnd(4)
	v.x = v.x + sp;
	v.y = v.y + sp2 / 1.5;
	if v.x > theme.scr.w() then
		v.x = 0
		v.speed = rnd(5)
	end
	if v.y > theme.scr.h() then
		v.y = 0
		v.speed = rnd(5)
	end
end)

function blur(p, r, g, b)
	local w, h = p:size()
	local cell = function(x, y)
		if x < 0 or x >= w or y < 0 or y >= h then
			return 0
		end
		local r, g, b, a = p:val(x, y)
		return a
	end
	for y = 0, h  do
		for x = 0, w do
			local c1, c2, c3, c4, c5, c6, c7, c8, c9 =
				cell(x - 1, y - 1),
				cell(x, y - 1),
				cell(x + 1, y - 1),
				cell(x - 1, y),
				cell(x, y),
				cell(x + 1, y),
				cell(x - 1, y + 1),
				cell(x, y + 1),
				cell(x + 1, y + 1)
			local c = (c1 + c2 + c3 + c4 + c5 + c6 + c7 + c8 + c9) / 9
			p:val(x, y, r, g, b, math.floor(c))
		end
	end
end

declare 'flake_spr' (function(v)
	local p = pixels.new(7, 7)
	local x, y = 3, 3
	p:val(x, y, 255,255,255,255)
	for i = 1, rnd(5) do
		local w = rnd(3)
		p:fill(x, y, w, w, 255, 255, 255, 255)
		x = x + rnd(2) - 1
		y = y + rnd(2) - 1
	end
	blur(p, 192, 192, 192)
	return p:sprite()
end)


const 'FADE_LONG' (64)
global 'anim_fn' (false)
declare 'move_up' (function(v)
	if _'titles'.finish then return end
	v.y = v.y - 1
	if v.y + v.h < 0 then
		D {v.name} -- purge it
	end
end)

declare 'anim_titles' (function()
	decor.bgcol = '#ffffff'
	timer:set(40)
--	D {'logo', 'img', 'gfx/logo.png',
--		x = 0,
--		y = 0,
--		z = 1,
--	}
end)

function anim(name)
	anim_fn = name
	if not name then D(); timer:stop(); return; end
	_G['anim_'..name]()
end

std.mod_start(function(s)
--	autodetect_theme()
	decor.bgcol = '#ffffff'
	if anim_fn then
		anim(anim_fn)
	end
end)

local titles = {
	{"МЕТЕЛЬ", style = 1};
	{ };
	{"История и код:", style = 2};
	{"Пётр Косых"},
	{"Иллюстрации:", style = 2};
	{"Pakowacz"},
	{ };
	{"По мотивам:", style = 2},
	{"Коралина // Нил Гейман"},
	{ };
	{"Музыка:", style = 2},
	{"Autumn: Meditativo by Dee Yan-Key"},
--	{"Winter is coming: Adagio - First Snow by Dee Yan-Key"},
	{"Largo – from Concerto No 5 – J.S. Bach // Jon Sayles"},
	{"J.S. Bach: Partia No.2 - Allemande // Scott Slapin"},
	{ };
	{"Движок:", style = 2},
	{"INSTEAD3: МЕТАПАРСЕР3 // Пётр Косых"},
	{ };
	{"https://instead.hugeping.ru"},
	{ };
	{"Альфа тестирование:"},
	{"techniX"},
	{"Irremann"},
	{"spline"},
	{"Борис Тимофеев"},
	{ };
	{"Благодарности:", style = 2},
	{"Семье (за терпение)" },
	{"Работодателю (за зарплату)"},
	{"Вам (за прохождение нашей игры)"},
	{"Всем тем, кто не мешал"},
	{ };
	{"КОНЕЦ", style = 1};
	{ },
	{ "Февраль 2019", style = 2 },
}

room {
	nam = 'titles';
	title = false;
	dsc = false;
	noparser = true;
	{
		finish = false;
		offset = 0;
		pos = 1;
		line = titles[1];
		ww = 0;
		hh = 0;
		font = false;
		font_height = 0;
		w = 0;
		h = 0;
	};
	ini = function(s)
		if here() == s then
			s:enter()
		end
	end;
	enter = function(s)
		mp:clear()
		lifeoff 'mplayer'
		snd.music 'mus/largo.ogg'
		s.font_height = tonumber(theme.get 'win.fnt.size')
		s.w, s.h = std.tonum(theme.get 'scr.w'), std.tonum(theme.get 'scr.h')
		D()
		for i = 1, 200 do
			D {"flake"..tostring(i), 'img', flake_spr, process = flake, x = -rnd(theme.scr.w()), y = -rnd(theme.scr.h()), speed = rnd(5), z = -2 }
		end
		anim'titles'
--		fading.set {"crossfade", max = FADE_LONG }
	end;
	timer = function(s)
		local last ='text'..tostring(#titles)
		local first = 'text1'
		if D(last) then
			if D(first).y < 20 then
				_'titles'.finish = true
			end
			return false
		end
		s.offset = s.offset + 1
		s.pos = math.floor(s.offset / s.font_height)
		if s.pos > #titles or s.pos < 1 then
			return false
		end
		if (D('text'..tostring(s.pos)) or not titles[s.pos][1]) then
			return false
		end
		local x, y, w, h = theme.get 'win.x', theme.get 'win.y', theme.get 'win.w', theme.get 'win.h'
		x, y, w, h = tonumber(x), tonumber(y), tonumber(w), tonumber(h)
		D{ 'text'..tostring(s.pos), "txt", titles[s.pos][1], w = w, x = x, xc = false, y = theme.scr.h(), process = move_up, z = -1, style = titles[s.pos].style, size = s.font_height };
		return false
	end;
}
