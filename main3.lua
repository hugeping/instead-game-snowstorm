--$name:Метель$
require "mp-ru"
require "fmt"
fmt.dash = true
fmt.quotes = true
loadmod "fading"
-- mp.errhints = false
game.dsc = [[Простая игра написанная специально для ЗОК-2019.]]

cutscene {
	nam = 'intro';
	text = {
		[[Старенький синий седан едет по заснеженной трассе. Внутри машины -- двое.]];
		[[Ведёт машину усталая женщина лет 35. На заднем месте справа сидит её дочь -- девочка-подросток.]];
		[[Девочка прислонилась лбом к холодному стеклу. Мать продолжает начатый разговор...]];
		[[-- Вот увидишь, тебе там понравится.]];
	};
	next_to = 'В машине';
}
global 'blizzard'(0)

obj {
	-"браслет";
	nam = 'браслет';
	before_Exam = [[Этот детский браслет мама подарила тебе на Рождество, когда тебе было 10 лет.
Просто игрушка. Леска, на которую нанизаны бусинки и пластмассовое сердечко.]];
	['before_Disrobe'] = [[Ты не хочешь расставаться с браслетом.]];
}:attr'clothes'

Title = Class ({
	title = false;
	OnError = function(s)
		mp:clear()
		std.pclr()
	end;
	before_Default = function(s, ev)
		if ev == 'Next' then
			return false
		end
		mp:clear()
		me():need_scene(true)
	end;
}, cutscene):attr 'noprompt'

Prop = Class {
	before_Default = function(s, ev)
		p ("Тебе нет дела до ", s:noun 'рд', ".")
	end;
}:attr 'scenery'

room {
	-"машина";
	nam = 'В машине';
	dsc = [[Ты сидишь на заднем сидении машины и смотришь в окно.]];
	exit = function()
		if seen '#мама' then
			_'#мама':daemonStop()
		end
	end;
	out_to = function(s)
		if blizzard < 7 then
			p [[Лучше не делать этого, пока машина движется.]]
		elseif seen '#мама' then
			p [[Там холодно.]]
		else
			s:daemonStop()
			if not have 'скрипка' then
				move('скрипка', 'машина')
			end
			if not have 'телефон' then
				move('телефон', 'машина')
			end
			walk 'метель1'
		end
	end;
	daemon = function(s)
		local t = {
			"Машину потряхивает на снежных ухабах.";
			"По другую сторону окна кружатся снежинки.";
			"Вы проезжаете мимо занесённых снегом коттеджей.";
			"Машину слегка заносит на снежной дороге.";
		}
		if blizzard >= 2 then
			blizzard = blizzard + 1
			if blizzard > 5 then
				enable '#заправка'
				disable '#метель'
				if blizzard == 7 then
					p [[Мать заглушила двигатель.]]
					return
				end
				if blizzard == 8 then
					p [[-- Подожди меня, я скоро вернусь. -- говорит тебе мать и выходит из машины, захлопывая за собой дверь.]];
					remove '#мама'
					return
				end
				if blizzard == 11 then
					p [[Ты ждёшь мать, но её все нет. Может быть, выйти из машины?]]
					return
				end
				if blizzard > 8 then
					return
				end
				p [[Вы подъезжаете к заправке.]]
				return
			end
		end
		if here() == s and rnd(100) <= 25 then
			pn (t[rnd(#t)])
		end
	end;
	enter = function(s)
		s:daemonStart()
		_'#мама':daemonStart()
	end;
	before_Listen = function(s)
		if seen '#мама' then
			p [[Ты слышишь шум мотора и музыку, доносящуюся из радио.]];
		else
			p [[В машине играет радио.]]
		end
	end;
}: with {
	obj {
		-"мать,мама,женщина";
		nam = '#мама';
		time = 0;
		before_Exam = [[Твоя мать очень много работает и поэтому выглядит усталой.]];
		before_Kiss = [[Ты зла на свою мать и сейчас ваши отношения нельзя назвать близкими.]];
		init_dsc = [[Машину ведёт твоя мать.]];
		['before_Ask,Tell,Talk'] = function(s)
			if visited 'разговор1' then
				if blizzard > 0 then
					if blizzard >= 2 then
						p [[-- Мама! Это важно!^]]
						if not disabled '#заправка' then
							p [[-- Сейчас заправимся и поговорим.]]
						else
							p [[-- Скоро заправка, подожди пять минут и поговорим!]]
						end
						return
					end
					p [[-- Мама! Посмотри, там справа. Что то странное...^]]
					p [[-- Не отвлекай меня от дороги!]]
					blizzard = 2
					return
				end
				p [[Ты не решаешься поговорить с ней.]]
				return
			end
			walk 'разговор1'
		end;
		daemon = function(s)
			local t = {
				[[-- Ты не собираешься со мной поговорить?]];
				[[-- Почему ты молчишь?]];
				[[-- Давай поговорим?]];
				[[-- Ну, чего ты молчишь?]];
			}
			s.time = s.time + 1
			if s.time > 3 then
				if rnd(3) == 1 then
					p (t[rnd(#t)])
					p [[ -- обращается к тебе мать.]];
				end
			end
		end;
	}:attr 'animate';
	'скрипка';
	Prop {
		-"руль|дверь|радио";
	};
	obj {
		nam = '#метель';
		-"метель,буря|смерч";
		before_Default = [[Она пока ещё далеко.]];
		before_Exam = [[Буря, метель или ... смерч? Что бы это ни было, оно пугает тебя.]];
	}:attr'scenery':disable();
	obj {
		-"окно,стекло";
		nam = '#окно';
		before_Open = "Слишком холодно, чтобы опускать стекло.";
		['before_Search,Exam'] = function()
			if not disabled '#заправка' then
				p [[За стеклом ты видишь смутный силуэт заправки.]];
				return
			end
			if visited 'разговор1' then
				if blizzard == 0 then
					pn [[Разглядывая белоснежный пейзаж, ты замечаешь вдали нечто странное.]]
					enable '#метель'
					blizzard = 1
				end
				pn [[Ты видишь, как по земле ползут огромные клубы пара или снега.]]
				p [[Огромная снежная буря, накрывая деревья, движется к трассе!]]
				return
			end
			p [[Ты видишь, как за стеклом кружится метель.]];
		end;
	}:attr 'scenery,openable';
	Prop {
		nam = "#заправка";
		-"заправка";
		before_Exam = [[Сквозь метель ты едва различаешь темные очертания заправки.]]; 
	}:disable();
}

dlg {
	nam = 'разговор1';
	title = false;
	phr = {
		[[-- Я говорю, тебе там понравится. Там хорошая школа, я узнавала... И музыкальная школа совсем недалеко. -- ты слышишь в голосе матери настойчивость.]];
		{
			'Я устала терять друзей.',
			'-- Ты же знаешь, что это необходимо! Я должна работать, чтобы ты смогла учиться в хорошем вузе! И это не конец света! На новом месте заведёшь новых друзей.',
			next = '#дальше';
		};
		{
			'Хорошо, мама...',
			'-- Ну что ты вечно строишь из себя мученика? Ты всего-лишь меняешь школу. Я работаю на твоё будущее и никакой благодарности!',
			next = '#дальше';
		};
	}
}: with {
	{
		'#дальше';
		{
			'Я заранее знаю всё, что ты скажешь!';
			'-- Ну зачем ты так? Ты стала такой грубой!';
		};
		{
			'Ты меня не поймёшь.';
			'-- А тебе не приходило в голову, что мне тоже было 13 лет?';
		};
		{
			'Просто мне очень плохо.';
			'-- Ты ведёшь себя как эгоистичный ребёнок. Ты думаешь мне легко?';
			{
				'Я ненавижу твою работу!',
				'-- Ты неблагодарная! Вместо поддержки, ты снова треплешь мне нервы!';
				{
					'Я устала от твоих скандалов. Замолчи!';
					'-- Ты это матери говоришь? Таким тоном? Как ты... можешь!';
				};
				{
					'Давай просто закончим этот разговор.';
					'-- Ты жестокая! Я отдала тебе все! И это моя самая большая ошибка!';
					{
						'Мама, прекрати!';
						function()
							p '-- Да, не ожидала я... Что у меня такая дочь...';
							walkback()
						end;
						
					}
				};
			};
			{
				'Ты могла бы сменить работу...',
				'-- Да? И получать гроши. И кто оплатит твоё обучение?';
			};
		}
	}	
}

obj {
	-"мобильный телефон,телефон,мобильник,смартфон";
	nam = "телефон";
	compass = false;
	['before_Drop,Insert'] = function(s, w)
		if s.compass and w ~= pl then
			p [[В телефоне есть компас, который тебе нужен.]]
			return
		end
		return false
	end;
	before_SwitchOff = function(s)
		if s.compass then
			p [[Если ты выключишь телефон, ты лишишься компаса.]]
			return
		end
		return false
	end;
	before_Exam = function(s)
		if not s:has 'on' then
			p [[Телефон выключен.]]
			return
		end
		if seen '#мама' then
			p [[Ты собираешься проверить новые сообщения, но 
твоя мать замечает это в зеркале заднего вида.^
-- Ты круглые сутки сидишь с телефоном! Отдай его мне, сейчас же! Или выключи!]];
		else
			if not s.compass then
				p [[Странно, нет приёма...]]
			end
			if here()^'поле' then
				if not s.compass then
					p [[Но в твоём смартфоне есть компас. И, похоже, он работает! Теперь ты можешь ориентироваться по сторонам света.]]
					s.compass = true
				else
					p [[Здорово, что в твоём смарфоне есть компас! В целях экономии батареи ты включаешь режим "в полёте".]]
				end
			end
		end
	end;
	before_Give = function(s, w)
		if w ^ '#мама' then
			p [[Ты протягиваешь телефон матери и она молча забирает его.]]
			remove(s)
			return
		end
		return false
	end;
}:attr 'switchable,on';


obj {
	nam = -"скрипка";
	init_dsc = [[Рядом лежит скрипка.]];
	before_Exam = [[Твоя скрипка. Тебе остался год, чтобы закончить музыкальную школу. Если честно, благодаря музыкальной школе ты стала ненавидеть музыку.]];
	after_Play = [[У тебя сейчас нет настроения играть.]];
}

function mp:Play(w)
	if not w then
		mp:xaction("Play", _'скрипка')
		return
	end
	if w ~= _'скрипка' then
		p [[Ты умеешь играть только на скрипке.]]
		return
	end
	if not have 'скрипка' then
		p [[Сначала тебе нужно взять скрипку в руки.]]
		return
	end
	return false
end

Verb {
	'#Play';
	'играть,сыграть',
	'на {noun}/дт : Play',
	' : Play',
}

Verb {
	'#Tune';
	'настро/ить,настра/ивать',
	'{noun}/вн : Tune',
}

function start(load)
	if not load then
--		fading.set {'fadeblack', max = 64, delay = 25 };
		move(pl, 'intro')
	end
end
function init()
	pl.description = [[Тебя зовут Вера. Тебе почти 13 лет.]];
	pl.word = -'ты/жр,2л'
--	pl.room = 'intro'
	take 'телефон'
end

cutscene {
	nam = "метель1";
	title = false;
	text = {
		[[Ты открываешь дверь и толкаешь её наружу.]];
		[[Ты чувствуешь, как ветер давит на дверь с другой стороны, но ты сильней и вот -- дверь открыта.]];
		[[Холод, вместе с вихрем злых снежинок, быстро забирается внутрь салона.]];
		[[Ты выходишь из машины когда...]];
		[[На тебя обрушивается...]];
	};
	next_to = "метель2";
}

Title {
	nam = 'метель2';
	text = {
		[[{$fmt y,50%}{$fmt c|{$fmt b|МЕТЕЛЬ}}^^
{$fmt c|Игра на ЗОК-2019}]]
	};
	next_to = 'поле';
}

obj {
	-"машина";
	nam = 'машина';
	dsc = function(s)
		p [[В снегу стоит машина.]];
		if inside('перо', s) then
			_'перо':dsc()
		end
	end;
	before_Enter = [[Сначала нужно найти мою маму.]];
}:attr 'container,openable,open':with {
	obj {
		nam = 'радио';
		-"радио";
		after_SwitchOn = [[Ты включаешь радио. Шум помех нарушает тишину.]];
		['before_Turn,Tune'] = function(s)
			if s:hasnt 'on' then
				p [[Радио выключено.]]
				return
			end
			p [[Ты пытаешься поймать какую-нибудь волну, но на всех частотах только шум помех.]];
		end;
		when_on = 'Радио в машине издаёт помехи.';
		when_off = false;
	}:attr 'static,switchable,on';
};
local function have_compass()
	return  have'телефон' and _'телефон'.compass
end

local function check_compass(w)
	if w == 'u_to' or w == 'd_to' or w == 'in_to' or w == 'out_to' then
		return
	end
	if not have_compass() then
		p [[Чтобы ориентироваться в пространстве, тебе нужен компас.]]
		return true
	end
	return
end

Area = Class ({
	compass_look = function(s, w)
		if check_compass(w) then
			return
		end
		if w == 'u_to' then
			mp:xaction("Exam", _'#небо')
			return
		end
		if w == 'd_to' then
			mp:xaction("Exam", _'#снег')
			return
		end
		return false
	end;
	cant_go = function(s, w)
		if check_compass(w) then
			return
		end
		return false
	end;
}, room)

Snow = Class {
	-"снег";
	before_Take = function(s)
		p [[Тебе не хочется играть в снежки.]]
	end;
	['before_Enter,Walk'] = "Ты и так стоишь среди снега.";
	after_Receive = function(s, w)
		move(w, here())
		return false
	end;
}:attr 'scenery,supporter';

Sky = Class {
	-"небо|облака";
	before_Exam = function(s)
		p [[Бледное небо нависло над головой. Солнца не видно.]];
	end;
	before_Default = "Небо далеко...";
}:attr 'scenery';

Area {
	nam = 'поле';
	-"поле";
	onenter = function(s)
		if visited(s) then
			return
		end
		p [[Холод. Ты лежишь в снегу и медленно приходишь в себя.^
Некоторое время ты смотришь в небо. Затем поднимаешься на ноги и оглядываешься.^
Странно, но ты не видишь никакой заправки. Впрочем, и трассы тоже.]];
	end;
	dsc = function(s)
		p [[Ты стоишь в заснеженном поле.]]
		if have_compass() then
			p [[На западе начинается хвойный лес.]]
		else
			p [[Неподалёку начинается хвойный лес.]];
		end
	end;
	before_Listen = function(s)
		if _'радио':hasnt'on' then
			p [[Стоит звенящая тишина.]];
		else
			p [[Ты слышишь шум радиопомех из машины.]]
		end
	end;
	["n_to,ne_to,e_to,se_to,s_to"] = function(s, t)
		if check_compass('w_to') then
			return
		end
		p ("Ты идешь некоторое время на ", (_('@'..t).word), ".")
		p ("Ничего не меняется. Вокруг все-такой же пустынный пейзаж. Ты решаешь вернуться к машине.")
	end;
	["w_to,nw_to,sw_to"] = function(s)
		if check_compass('w_to') then
			return
		end
		return "#лес"
	end;
	out_to = function()
		p [[Сначала нужно решить, куда тебе идти.]];
	end;
}:with {
	'машина',
	Sky { nam = '#небо' };
	Snow {
		nam = '#снег';
		before_Exam = function(s)
			p [[Ты видишь запорошенные снегом следы, которые ведут в лес.]]
			enable '#следы'
		end;
	};
	obj {
		nam = '#лес';
		-"хвойный лес,лес|чаща|деревья";
		before_Default = [[Лес далеко.]];
		before_Exam = function()
			p "На деревьях лежит снег.";
		end;
		['before_Walk,Enter,Climb'] = function(s)
			walk 'В лесу';
		end;
		door_to = 'В лесу';
	}:attr 'scenery,door';
	obj {
		nam = '#следы';
		before_Exam = "Следы уже почти скрылись под свежим снегом.";
	}:attr 'scenery';
}

game:dict {
	["деревья/мн,вн"] = "деревья";
}

obj {
	-"олень";
	nam = 'олень';
	sit = false;
	['before_Touch,Talk,Ask,Tell,Kiss'] = function(s)
		s.step = 4
		p [[Олень посмотрел в твою сторону и громко задышал, жадно втягивая морозный воздух.]]
	end;
	['life_Give,Show'] = function(s)
		s.sit = true
		p [[Ты подносишь перо к носу оленя. Чувствуя прикосновение, он шумно втягивает в себя воздух. Затем он опускается перед тобой на колени.]];
		s:daemonStop()
	end;
	init_dsc = [[Ты видишь на поляне оленя.]];
	["before_Enter,Climb"] =  function(s)
		if not s.sit then
			s:before_Touch()
			return
		end
		s:daemonStop()
		walk 'к хребту'
	end;
	before_Exam = function(s)
		p [[Олень не видит тебя. На месте глаз у него зияют чёрные дырки.]];
		if s.sit then p [[Он стоит перед тобой на коленях.]] end
	end;
	step = 0;
	daemon = function(s)
		s.step = s.step + 1
		if s.step > 5 then
			p [[Олень скрылся в лесу.]]
			s:disable()
			s:daemonStop()
			s.step = 0;
		end
		return false;
	end;
}:disable():with {
	obj {
		-"глаза оленя,глаза,дыр*";
		before_Exam = [[На месте глаз зияют чёрные дырки.]];
		before_Default = [[Тебе не нравятся глаза оленя.]];
	}
}

local function forest_scenery(s)
	disable 'сова'
	disable 'олень'
	disable '#ручей'
	disable '#поляна'
	if s.depth == 0 then
		enable 'сова'
	elseif s.depth == 2 then
		enable '#ручей'
	elseif s.depth == 3 then
		enable '#поляна'
		enable 'олень'
		_'олень'.step = 0
		_'олень'.sit = false
		_'олень':daemonStart()
	end
end
Area {
	-"лес|чаща";
	depth = 0;
	nam = 'В лесу';
	title = 'Лес';
	enter = function(s)
		if seen 'сова' then
			_'сова':daemonStart()
		end
	end;
	dsc = function(s)
		p [[Ты находишься в хвойном лесу.]]
		if s.depth == 0 then
			if not have_compass() then
				p [[Между деревьями ты видишь снежное поле.]];
			else
				p [[Между деревьями на востоке ты видишь снежное поле.]];
			end
		elseif s.depth == 1 then
			p [[Тебя окружают деревья.]]
		elseif s.depth == 2 then
			p [[Ты видишь здесь замёрзший ручей.]]
		elseif s.depth == 3 then
			p [[Ты вышла на небольшую поляну.]]
		elseif (s.depth - 4) % 2 == 0 then
			p [[Лес становится всё гуще.]]
		elseif (s.depth - 4) % 2 == 1 then
			p [[Деревья окружают тебя со всех сторон.]]
		end
	end;
	['w_to,nw_to,sw_to'] = function(s, t)
		s.depth = s.depth + 1
		if s.depth > 8 then s.depth = 6 + rnd(3) end
		forest_scenery(s)
		pl:need_scene(true)
		p ("Ты идешь некоторое время на ", (_('@'..t).word), ".")
		if s.depth > 7 and rnd(100) < 30 then
			p [[^Ты можешь идти так целую вечность...]]
		end
	end;
	['s_to,n_to'] = function(s)
		p [[Ты решила, что идти вдоль границы леса не очень хорошая идея.]]
	end;
	['e_to,se_to,ne_to'] = function(s, t)
		if check_compass(t) then
			return
		end
		if s.depth == 0 then
			return '#поле'
		end
		pl:need_scene(true)
		s.depth = s.depth - 1
		p ("Ты идешь некоторое время на ", (_('@'..t).word), ".")
		if s.depth == 0 then
			p [[За деревьями на востоке ты видишь снежное поле.]]
		end
		forest_scenery(s)
	end;
	out_to = function(s)
		if s.depth == 0 then
			return '#поле';
		end
		return false
	end;
}: with {
	Sky { nam = '#небо' };
	Snow {
		nam = '#снег';
		before_Exam = [[Здесь едва заметный след теряется.]];
	};
	obj {
		nam = '#поле';
		before_Exam = "Снежное поле выглядит бескрайним.";
		before_Default = [[Поле далеко.]];
		['before_Walk,Enter,Climb'] = function(s)
			walk 'поле'
		end;
		door_to = 'поле';
	}:attr 'scenery,door';
	Prop {
		-"деревья|дерево|сосна,ветк*";
		nam = '#деревья';
		before_Exam = function(s)
			if s:hint'plural' then
				p "Деревья покрыты снегом.";
			else
				p "Ветви дерева покрыты снегом.";
			end
		end;
		["before_Enter,Climb"] = "Первые ветки находятся высоко. У тебя не получится забраться.";
	};
	obj {
		nam = 'сова';
		talked = false;
		seen = false;
		-"полярная сова,сова,птица";
		init_dsc = [[Ты замечаешь большую сову, сидящую на ветке сосны.]];
		before_Touch = function(s)
			if not s.seen then
				p [[Сначала хорошо бы рассмотреть, с чем имеешь дело.]]
				return
			end
			if where(s) ^ 'В лесу' then
				p [[Она слишком высоко.]]
			else
				if s.talked then
					p [[Тебе не очень хочется иметь с ней дело.]]
				else
					p [[Ты осторожно дотронулась до птицы.^]]
					p [[Сова вздрогнула и её глаза-дырки уставились на тебя.]]
				end
			end
		end;
		talk_to = function(s)
			if not s.seen then
				p [[Сначала хорошо бы рассмотреть, с чем имеешь дело.]]
				return
			end
			if where(s) ^ 'В лесу' then
				p [[Она слишком высоко.]]
				return
			end
			if s.talked then
				p [[-- Что всё это значит?^
-- Я сделала то, что мне повелела госпожа.]];
				p [[^Сова хлопнула крыльями и улетела.]]
				remove(s)
				s:daemonStop()
				return
			end
			return 'разговор с совой'
		end;
		dsc = function(s)
			if where(s) ^ 'поле' then
				p [[На машине сидит сова.]]
			else
				p [[На ветке сосны сидит сова.]]
			end
		end;
		before_Exam = function(s)
			p [[Тебе кажется, что это полярная сова. Только глаза у неё странные. Вернее, глаз нет. Вместо них -- две зияющие дырки.]];
			if not s.seen then
				p [[^Интересно, видит ли она тебя?]]
			end
			s.seen = true;
		end;
		daemon = function(s)
			if here() ^ 'В лесу' and where(s) ^ 'В лесу' and _'В лесу'.depth == 0
			and rnd(3) == 1 then
				p [[Хлопая крыльями сова улетела в сторону поля.]]
				move(s, 'поле')
			elseif here() ^ 'поле' and where(s) ^ 'поле' and s.talked and rnd(3) == 1 then
				p [[Хлопая крыльями сова улетела в сторону леса.]]
				move(s, 'В лесу')
			end
			return false
		end;
	} : with {
		obj {
			-"глаза совы,глаза,дыр*";
			before_Exam = [[На месте глаз у совы зияют чёрные дыры.]];
			before_Default = [[Тебе не нравятся эти глаза.]];
		}
	};
	Prop {
		-"поляна";
		nam = '#поляна';
	}:disable():attr'scenery';
	Prop {
		-"ручей";
		nam = '#ручей';
	}:disable():attr'scenery';
	'олень';
}
obj {
	-"перо";
	nam = 'перо';
	dsc = function(s)
		if where(s) ^'машина' then
			p [[На крыше машины лежит белое перо.]]
			return
		end
		return false
	end;
	before_Exam = function(s)
		p [[Белое перо.]]
		if have(s) then
			p [[Зачем оно тебе?]];
		else
			p [[Его оставила сова с дырками вместо глаз.]]
		end
	end;
}

dlg {
	nam = 'разговор с совой';
	title = false;
	phr = {
		[[-- О, я слышу тебя, дитя! -- ответ птицы напугал тебя.]],
		{
			"Ты меня не видишь?";
			"-- Теперь я могу различать тебя...";
		};
		{
			"Ты умеешь говорить?";
			"-- Я разговариваю с тобой.";
		};
		{
			"Что с твоими глазами?";
			"-- Такой меня сделала моя госпожа.";
			{
				"Кто твоя госпожа?";
				"-- Она вызвала меня. Она сказала, чтобы я передала тебе...";
				{
					
					"Что?";
					"-- Твоя мама ждёт тебя во дворце. Поспеши.";
					next = "#deep";
				};
				{
					"Ты видела мою маму?";
					"-- Твоя мама ждёт тебя во дворце. Поспеши.";
					next = "#deep";
					
				}
			}
		};
	}
}: with {
	{
		'#deep';
		{
			"Где этот дворец?";
			"-- Он за ледяным хребтом на западе.";
			{
				"Это далеко?";
				function(s)
					p "-- Расстояние -- это время. А времени здесь предостаточно. Возьми перо. По нему тебя узнают другие слуги госпожи.";
					move ('перо', 'машина')
					_'сова'.talked = true
					walkout()
				end;
			}
		};
		{
			"Что за бред ты несёшь.";
			"-- Моя госпожа сказала мне передать тебе...";
			{
				"Ладно, ладно...";
				"-- Поспеши же, дитя!";
			}
		}
	}
}

cutscene {
	nam = 'к хребту';
	title = false;
	text = {
		[[Ты садишься на оленя и он поднимается с колен.]];
		[[Вы мчитесь по лесу на запад. ]];
	}
}
