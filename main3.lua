--$Name:Метель$
--$Author:Peter Kosyh$
require "mp-ru"
require "fmt"
fmt.dash = true
fmt.quotes = true
-- loadmod "fading"
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
	before_Exam = function(s)
		p [[Этот детский браслет мама подарила тебе на Рождество, когда тебе было ещё 9 лет.
Просто игрушка. Леска, на которую нанизаны бусинки и пластмассовое сердечко.]];
		if s:once() then
			p [[Странно, что он оказался в бардачке... Ты думала, что он давно потерялся.]]
		end
	end;
	after_Wear = [[Надев браслет на правое запястье, ты чувствуешь, что на душе у тебя потеплело.]];
}:attr'clothing'

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
				move('телефон', 'бардачок')
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
				if _'телефон'.seen and have 'телефон' then
					p [[-- Я не буду с тобой разговаривать, пока ты не отдашь мне телефон! Ну же!]]
					return
				end
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
		-"руль|дверь|радио|бардачок";
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
			if visited 'разговор1' and _'телефон'.seen then
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
							if have 'телефон' then
								DaemonStart 'телефон'
							end
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
function pl:before_LetGo(w, ww)
	if w ^ 'телефон' then
		local s = w
		if s.compass and ww ~= pl then
			p [[В телефоне есть компас, который тебе нужен.]]
			return
		end
		return false
	elseif w ^ 'осколки' then
		local s = w
		if not ww ^ 'ообрыв' then
			return false
		end
		p [[Ты бросаешь осколки кристалла по направлению пропасти. Большая часть осколков скрываются
в глубине. Но несколько светящихся огоньков подпрыгивают и замирают на другой стороне ущелья. По их слабому
свечению ты можешь примерно оценить размер пропасти.]];
		if here() ^ 'обрыв' then
			move(s, 'Другая сторона')
		else
			move(s, 'обрыв')
		end
	end;
	return false
end
obj {
	function(s)
		pr (-"мобильный телефон,телефон,мобильник,смартфон");
		if s.flash then
			pr "|фонарик,фонарь"
		end
	end;
	nam = "телефон";
	flash = false;
	compass = false;
	seen = false;
	each_turn = function(s)
		if here():has 'light' and s:has 'light' then
			p [[В целях экономии заряда ты выключила фонарик.]]
			s:attr '~light'
		end
	end;
	daemon = function(s)
		if rnd(10) > 3 then
			p [[Ты слышишь сигнал входящего сообщения на своём смартфоне.]]
		end
	end;
	["before_Burn,Light"] = function(s)
		s.flash = true
		if s:has 'light' then
			p [[Фонарик в телефоне и так включён.]]
			return
		end
		if not mp:thedark() then
			p [[Тут и так светло.]]
			return
		end
		p [[Ты включила в мобильнике фонарик.]]
		pl:need_scene(true)
		s:attr 'light'
	end;
	before_SwitchOn = function(s)
		if s:multi_alias() == 2 then
			s:before_Light()
			return
		end
		return false
	end;
	before_SwitchOff = function(s)
		if s:has 'light' then
			p [[Ты выключила фонарик в телефоне.]]
			s:attr '~light'
			pl:need_scene(true)
			return
		end
		if s:multi_alias() == 2 then
			p [[Фонарик и так выключен.]]
			return
		end
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
		if s:has 'light' then
			p [[В телефоне включён фонарик.]]
			return
		end
		if seen '#мама' then
			p [[Ты собираешься проверить новые сообщения, но
твоя мать замечает это в зеркале заднего вида.^
-- Ты круглые сутки сидишь с телефоном! Отдай его мне, сейчас же!]];
			s.seen = true
			s:daemonStop()
		else
			if not s.flash and mp:thedark() then
				p [[Тебе приходит в голову мысль, что можно посветить телефоном...]]
				s.flash = true
				return
			end
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
			else
				p [[Это твой старенький китайский смартфон. В основном, ты используешь его для социальных сетей.]]
				p [[А сейчас он служит тебе компасом.]]
				if s.flash then p [[И фонариком.]] end
			end
		end
	end;
	before_Give = function(s, w)
		if w ^ '#мама' then
			p [[Ты протягиваешь телефон матери, она молча забирает его и кладёт в бардачок.]]
			move(s, 'бардачок')
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
	'#Light';
	'[|по|под]свети/ть,[|по|свеч/у,освети/ть';
	'{noun}/тв,held : Light'
}

function mp:Light(w)
	if mp:check_held(w) then
		return
	end
	p "{#First} не {#if_hint/#second,plural,могут,может} светить."
end

function mp:Knock(w)
	if mp:check_live(w) then
		return
	end
	if mp.args[1].word == 'в' then
		p [[Ты постучала в]]
		p (w:noun'вн', ".")
	else
		p [[Ты постучала по]]
		p (w:noun'дт', ".")
	end
	p "Ничего не произошло."
end

function mp:Cry(w)
	p [[Это тебе не поможет.]]
end

Verb {
	"#cry",
	"[|по|за]крич/ать,крикн/уть,[|за|по]плак/ать,[|за|по]плач/ь",
	": Cry"
}

Verb {
	"#Knock",
	"[|по]стуч/ать",
	"в {noun}/вн : Knock",
	"по {noun}/дт : Knock"
}

Verb {
	'#Tune';
	'настро/ить,настра/ивать',
	'{noun}/вн : Tune',
}

function start(load)
	if not load then
----		fading.set {'fadeblack', max = 64, delay = 25 };
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
}:attr 'container,openable,open,static':with {
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
	obj {
		nam = 'бардачок';
		-"бардачок|перчаточный ящик";
		obj = { 'браслет' };
		when_open = "Бардачок открыт.";
		before_Exam = function(s)
			if s:hasnt'open' then
				p [[Бардачок закрыт.]]
				return
			end
			return false
		end;
		when_closed = "Твоё внимание привлекает бардачок.";
	}:attr 'static,openable,container';
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
	['before_Receive'] = function(s, w)
		if here() ^ 'В лесу' then
			p ([[Потом ]], w:noun'вн', [[ сложно будет найти.]])
		else
			return false
		end
	end;
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
	}:attr 'scenery';
	obj {
		nam = '#следы';
		before_Exam = "Следы уже почти скрылись под свежим снегом.";
	}:attr 'scenery';
}

game:dict {
	["деревья/мн,вн"] = "деревья";
	["голем"] = "голем";
	["голем/рд"] = "голема";
	["голем/дт"] = "голему";
	["голем/тв"] = "големом";
	["голем/вн"] = "голема";
	["голем/пр"] = "големе";
}

obj {
	-"олень";
	nam = 'олень';
	sit = false;
	['before_Touch,Talk,Ask,Tell,Kiss'] = function(s)
		s.step = 4
		p [[Олень попятился и шумно задышал, жадно втягивая морозный воздух.]]
	end;
	['life_Give,Show'] = function(s)
		if s.sit then
			p [[Олень никак не отреагировал.]]
			return
		end
		s.sit = true
		p [[Ты подносишь перо к носу оленя. Чувствуя прикосновение, он шумно втягивает в себя воздух. Затем он опускается перед тобой на колени.]];
		s:daemonStop()
	end;
	init_dsc = [[Ты видишь на поляне оленя.]];
	["before_Enter,Climb"] =  function(s)
		if where(pl) == s then
			p [[Но ты уже и так на олене.]]
			return
		end
		if not s.sit then
			s:before_Touch()
			return
		end
		if not have 'перо' then
			p [[Ты подумала, что тебе стоит сначала взять с собой перо странной совы. Кто знает, куда умчит тебя олень?]]
			return
		end
		s:daemonStop()
		s.sit = false
		if here() ^ 'В лесу' then
			walk 'к хребту'
		else
			walk 'к поляне'
		end
	end;
	before_Exam = function(s)
		if s.sit then
			p [[Олень стоит перед тобой на коленях.]]
		else
			if s:once() then
				p [[Ты замечаешь, что у оленя странные глаза.]]
			else
				p [[Чёрные дырки-глаза оленя пугают тебя.]]
			end
		end
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
		return
	end;
}:disable():with {
	obj {
		-"глаза оленя,глаза,дыр*";
		before_Exam = [[Вместо глаз у оленя чёрные дырки.]];
		before_Default = [[Тебе не нравятся глаза оленя.]];
	}:attr 'scenery';
	Prop { -"рога оленя,рога" };
}:attr 'supporter'

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
	before_Drop = function(s, w)
		p ("Зачем бросать ", w:noun'вн', " в лесу?")
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
		before_Exam = function(s)
			if here().depth == 0 then
				p [[Здесь едва заметный след теряется.]];
			else
				return false
			end
		end;
	};
	obj {
		nam = '#поле';
		before_Exam = "Снежное поле выглядит бескрайним.";
		before_Default = [[Поле далеко.]];
		['before_Walk,Enter,Climb'] = function(s)
			walk 'поле'
		end;
	}:attr 'scenery';
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
			p [[Тебе кажется, что это полярная сова. Только у неё странные глаза.]];
			if here() ^ 'поле'  then
				pn()
				_'#глаза совы':before_Exam()
			end
		end;
		daemon = function(s)
			if s.talked then
				return
			end
			if here() ^ 'В лесу' and where(s) ^ 'В лесу' and _'В лесу'.depth == 0
			and rnd(3) == 1 then
				p [[Хлопая крыльями сова улетела в сторону поля.]]
				move(s, 'поле')
			elseif here() ^ 'поле' and where(s) ^ 'поле' and s.talked and rnd(3) == 1 then
				p [[Хлопая крыльями сова улетела в сторону леса.]]
				move(s, 'В лесу')
			end
			return
		end;
	} : with {
		obj {
			-"глаза совы,глаза,дыр*";
			nam = '#глаза совы';
			before_Exam = function(s)
				p [[На месте глаз у совы зияют чёрные дырки.]];
				if not _'сова'.seen then
					p [[^Интересно, видит ли она тебя?]]
				end
				_'сова'.seen = true
			end;
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
			"-- Я тебя чувствую...";
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
					p "-- Расстояние -- всего лишь время. А время здесь замёрзло. Возьми перо. По нему тебя узнают другие слуги госпожи.";
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
		[[Вы мчитесь через лес на запад. Снова и снова олень ловко огибает встречные деревья и вы оставляете их позади.]];
		[[Постепенно лес начинает редеть и сквозь деревья ты видишь ледяные горы.]];
		[[Олень остановился перед ледяной стеной и опустился, чтобы ты могла слезть.]];
	};
	next_to = 'Ледяные горы';
	onexit = function(s, to)
		p[[Ты слезаешь с оленя.]]
		move('олень', to)
	end;
}

cutscene {
	nam = 'к поляне';
	title = false;
	text = {
		[[Ты садишься на оленя и он поднимается с колен.]];
		[[Вы мчитесь через лес на восток. Снова и снова олень ловко огибает встречные деревья и вы оставляете их позади.]];
		[[Постепенно лес начинает редеть.]];
		[[Олень остановился и опустился на колени, чтобы ты могла слезть.]];
	};
	next_to = 'В лесу';
	onexit = function(s, to)
		p[[Ты слезаешь с оленя.]]
		move('олень', to)
	end;
}

Area {
	nam = 'Ледяные горы';
	title = 'У ледяных гор';
	dsc = [[Ты стоишь перед ледяной стеной, которая продолжается на север и юг. На востоке начинается лес.]];
	['e_to,ne_to,se_to'] = '#лес';
	w_to = '#стена';
	in_to = '#стена';
	['nw_to,sw_to,n_to,s_to'] = function(s)
		p [[По этому направлению нет ничего интересного. Такая же ледяная стена.]];
	end;
}: with {
	obj {
		nam = '#лес';
		-"хвойный лес,лес|чаща|деревья";
		before_Default = [[Лес далеко.]];
		before_Exam = function()
			p "На деревьях лежит снег.";
		end;
		['before_Walk,Enter,Climb'] = function(s)
			p "В этом лесу можно ходит вечность.";
		end;
	}:attr 'scenery';
	Snow { nam = '#снег' };
	Sky { nam = '#небо' };
	obj {
		function(s)
			pr (-"ледяная стена,стена|лёд|лед|скала|гора|горы/жр");
			if s.light > 0 then
				pr (-"|свечение/ср|свет")
			end
		end;
		nam = '#стена';
		light = 0;
		before_Climb = [[У тебя вряд ли это получится. Стена отвесная.]];
		["before_Enter,Walk"] = function(s)
			if s.light == 0 then
				p [[Как ты это сделаешь? Стена твёрдая, гладкая и скользкая.]]
				return
			end
			walk 'пещера'
		end;
		before_Exam = function(s)
			if s.light > 0 then
				p [[Сквозь лёд ты видишь фиолетовое свечение.]]
			else
				p [[Ледяная стена отвесно уходит вверх.]]
			end
		end;
		daemon = function(s)
			if player_moved() then
				s.light = 0
				s:daemonStop()
				return
			end
			if s.light == 1 then
				p [[Ты замечаешь, что под поверхностью льда разливается фиолетовое свечение.]]
			elseif s.light == 2 then
				p [[Фиолетовое свечение под поверхностью льда усиливается!]]
			elseif s.light == 3 then
				p [[Фиолетовое свечение ослабевает.]]
			else
				s:daemonStop()
				s.light = 0
				return
			end
			s.light = s.light + 1
		end;
		before_Attack = function(s)
			p [[Скала {$fmt em|выглядит} твёрдой. Ты решила не рисковать.]];
		end;
		before_Knock = function(s)
			if s.light == 0 then
				return false
			end
			p [[Ты попыталась постучать по стене, но у тебя это не вышло! Рука прошла сквозь лёд!]]
		end;
		['before_Touch,Push'] = function(s)
			p [[Ты касаешься ладонью гладкой ледяной поверхности.]];
			if s.light > 0 then
				p [[Как странно, твоя рука проходит сквозь лёд!]]
				s.light = 2
			else
				s.light = 1
			end
			s:daemonStart();
		end;
	}:attr 'scenery';
}

room {
	nam = 'пещера';
	-"пещера";
	onenter = function(s)
		if not visited(s) then
			p [[Доверившись интуиции, ты входишь в фиолетовое свечение, которое вдруг заполняет всё вокруг. Шаг. Еще один. И вдруг ты оказываешься в полной темноте. Если не считать слабого свечения позади.]]
		end
	end;
	title = function(s)
		if mp:thedark() then
			p [[В темноте]]
		else
			p [[Ледяная пещера]]
		end
	end;
	dark_dsc = [[Ты видишь слабое свечение в темноте.]];
	dsc = [[Ты находишься внутри небольшой ледяной пещеры. У восточной стены ты видишь странное свечение.^
Пещера продолжается на северо-запад.]];
	out_to = 'Ледяные горы';
	nw_to = function(s)
		if mp:thedark() then
			p [[Ты же не видишь куда идти.]]
			return
		end
		return 'обрыв'
	end;
	Play = function(s, w)
		if not w or not have 'скрипка' then
			return false
		end
		if not w then w = _'скрипка' end
		if not w ^ 'скрипка' then
			return false
		end
		if _'#кристаллы'.try == 0 or _'#кристаллы'.broken then
			return false
		end
		_'#кристаллы'.broken = true
		p [[Интересно... А что если? Не успев додумать мысль, ты уже берёшь скрипку в руки.^^
Ты извлекаешь "ми" второй октавы. Сначала ничего не происходит, но затем ты слышишь, как странный кристалл отзывается
на звук твоей скрипки.^^
Звуки скрипки и кристалла усиливают друг друга в резонансе. Ты почти физически ощущаешь, как
напряжение кристалла достигает своего пика. И, наконец, он шумно взрывается на мелкие осколки.]]
		enable 'осколки'
	end;
	e_to = '#свечение';
}:attr '~light': with {
	obj {
		nam = '#свечение';
		-"свечение";
		['before_Touch,Push,Knock'] = 'Твоя рука проходит сквозь свечение.';
		before_Exam = function(s)
			p [[Этим путём ты попала сюда. Вероятно, с помощью него можно выйти наружу.]];
			p [[^Ты обращаешь внимание, что источником странного свечения служат фиолетовые кристаллы, растущие из стены.]]
			enable '#кристаллы'
		end;
		['before_Walk,Climb,Enter'] = function(s)
			walk 'Ледяные горы';
		end;
	}:attr 'scenery,luminous';
	Prop {
		nam = '#стены';
		-"стены|стена|пол|потолок";
		['before_Touch,Push,Knock'] = [[Похоже, ты находишься в ледяной пещере.]];
		before_Exam = function(s)
			if mp:thedark() then
				p [[В полной темноте это будет сложно.]]
			else
				return false
			end
		end;
	}:attr 'luminous';
	obj {
		-"кристаллы|кристалл";
		nam = '#кристаллы';
		try = 0;
		broken = false;
		before_Exam = [[Полупрозрачные кристаллы растут прямо из льда.]];
		before_Touch = function(s)
			if s.try == 0 or s.broken then
				return false
			else
				p [[Ты чувствуешь как кристалл вибрирует.]]
			end
		end;
		['before_Attack,Knock'] = function(s)
			if s.broken then
				p [[Ты уже разрушила один кристалл.]]
				return
			end
			if s.try == 2 then
				p [[Ты постучала по звонкому кристаллу.]]
			else
				p [[Ты постучала по одному из кристаллов.]]
			end
			if s.try == 0 then
				s.try = 1
				p [[Ответом был глухой звук.]]
			elseif s.try == 1 then
				p [[На этот раз звук оказался звонким. Твой музыкальный слух определил {$fmt em|"ми"} второй октавы.]]
				p [[^Ты решила запомнить этот кристалл.]]
				s.try = 2
			else
				p [[Звенящий звук кристалла долго отражается от ледяных стен. Ты чувствуешь вибрацию.]]
			end
		end;
	}:attr 'luminous,scenery':disable();
	obj {
		-"осколки кристалла|осколки|кусочки|куски|осколок*";
		nam = 'осколки';
		before_Exam = [[Осколки кристалла пульсируют слабым фиолетовым свечением.]];
	}:attr 'luminous':disable();
}

obj {
	nam = 'ообрыв';
	-"обрыв,разлом|пропасть";
	before_Exam = function(s)
		p [[Глубокий разлом во льду. Света фонарика недостаточно, чтобы оценить его глубину. К счастью, ширина разлома не превышает двух метров.]];
	end;
	before_JumpOver = function(s)
		p [[Ты разбегаешься и прыгаешь через пропасть...]]
		if here() ^ 'обрыв' then
			walk 'Другая сторона'
		else
			walk 'обрыв'
		end
	end;
	before_Receive = function(s, w)
		if w ^ 'скрипка' then
			p ("Тебе жаль расставаться с ", w:noun 'тв', ".")
			return
		end
		return false
	end;
	after_Receive = function(s, w)
		remove(w)
		p ("Ты бросаешь ", w:noun'вн', " в обрыв.")
	end;
	before_Enter = [[Прыгнуть в пропасть? Тебе нужно найти маму, а не сбегать от проблем...]];
}:attr 'scenery,container,open';

room {
	nam = 'обрыв';
	dsc = [[На западе гладкий пол пещеры заканчивается обрывом. Выход находится на юго-востоке.]];
	out_to = 'пещера';
	w_to = "ообрыв";
	['se_to,e_to'] = 'пещера';
}:attr '~light': with {
	Prop {
		-"стены|стена|пол|потолок";
	};
	'ообрыв';
}

obj {
	function()
		pr (-"отверстие|выход|дырка|дыра");
		if here() ^ 'За ледяной стеной' then
			pr (-"|пещера")
		end
	end;
	nam = "отверстие";
	before_Exam = [[Отверстие достаточно широкое для того, чтобы пролезть в него.]];
	["before_Enter,Walk,Climb"] = function(s)
		if here() ^ 'Другая сторона' then
			walk 'За ледяной стеной';
		else
			walk 'Другая сторона'
		end
	end;
}:attr 'scenery';

room {
	nam = 'Другая сторона';
	title = "Пещера";
	-"пещера";
	dsc = [[Здесь светло. Свет поступает в пещеру через широкое отверстие на западе.
Пропасть находится на востоке.]];
	out_to = "отверстие";
	w_to = "отверстие";
	e_to = "ообрыв";
}: with {
	"ообрыв",
	'отверстие',
	Prop {
		-"стены|стена|пол|потолок";
	};
}

room {
	nam = 'За ледяной стеной';
	title = 'Плато';
	-"плато/ср";
	dsc = function()
		p [[Ты находишься на снежном плато, рядом со входом в пещеру. Ледяные горы окружают плато со всех сторон. Может быть поэтому, стоит мёртвая тишина.]]
		p [[На западе, в центре плато возвышается ледяная скала.]];
	end;
	in_to = 'отверстие';
	e_to = 'отверстие';
	w_to = '#замок';
	cant_go = function(s)
		p [[На плато не видно ничего интересного, кроме скалы.]]
	end;
}: with {
	'отверстие';
	Prop {
		-"горы|стена|стены";
	};
	Snow { nam = '#снег' };
	Sky { nam = '#небо' };
	obj {
		nam = '#замок';
		-"скала|замок|дворец|вершины";
		before_Exam = [[Остроконечные вершины ледяной громады высоко возвышаются над плато.]];
		before_Default = [[Сначала к скале нужно подойти.]];
		['before_Enter,Walk,Climb'] = function(s)
			walk 'У замка'
		end;
	}:attr 'scenery'
}

obj {
	-"разлом|проход|отверстие|щель|вход";
	nam = 'ворота';
	description = [[Высота разлома с неровными краями достигает трёх метров, а ширина -- двух. Верх отверстия имеет форму арки.]];
	['before_Walk,Enter,Climb'] = function(s)
		if here() ^ 'У замка' then
			mp:xaction("Enter", _'#замок')
		else
			walk 'У замка'
		end
	end;
}:attr 'scenery':disable()

obj {
	function(s)
		if s:has'animate' then
			p (-"ледяной человек|человек|статуя|голем/ед,мр,од");
		else
			p (-"статуя|ледяной человек|человек");
		end
	end;
	nam = 'голем';
	init_dsc = function(s)
		if s:has'animate' then
			p [[У стены стоит ледяной человек.]]
		else
			p [[Твоё внимание привлекает огромная ледяная статуя.]]
		end
	end;
	description = function(s)
		if s:has'animate' then
			p [[Высота ледяного человека около двух метров. У него есть руки и ноги, но вместо головы лишь небольшой выступ.]]
			if visited 'королева-диалог' and disabled 'дверь' then
				p [[Сейчас голем стоит у северной части зала и ждет тебя.]]
			end
		else
			p [[Статуя сделана из льда и изображает двухметрового человека с массивным телосложением.]]
		end
	end;
	before_Climb = [[Это не так просто сделать.]];
	['before_Walk,Enter,Climb'] = function(s)
		if visited 'королева-диалог' and disabled 'дверь' then
			p [[Ты последовала за големом. Обогнув колонну и подойдя к северной стене, ты заметила небольшую деревянную дверь.]]
			enable 'дверь'
			return
		end
		return false
	end;
	['before_Take,Push,Pull'] = function(s)
		p (s:Noun(), " весит не меньше сотни килограмм. Как ты это сделаешь?");
	end;
	['life_Give,Show,ThrowAt'] = function(s, w)
		if w ^ 'перо' then
			if disabled 'ворота' then
				p [[Едва ты достала перо, как статуя сдвинулась с места. Сделав два шага по направлению к тебе,
страшный ледяной человек остановился.^]]
				enable 'ворота'
				p [[-- Госпожа ждёт тебя! -- прогремел голос с двух метровой высоты.^]]
				p [[После этих слов голем размахнулся и ударил своим кулаком в стену.]]
				p [[Стена с треском раскололась и в ней образовался проход.]]
				s:attr'animate'
			else
				if not visited 'Тронный зал' then
					p [[-- Госпожа ждёт тебя! -- прогремел голос с двух метровой высоты.]]
				else
					p [[-- Я узнал тебя.]]
				end
			end
			return
		end
		return false
	end;
}: attr '~animate':with {
	Prop {
		-"ноги|руки|голова|выступ"
	};
}

room {
	nam = 'У замка';
	title = 'У подножия скалы';
	e_to = 'За ледяной стеной';
	w_to = '#замок';
	in_to = '#замок';
	dsc = function(s)
		p [[Ты стоишь у подножия ледяной скалы. Отвесная стена уходит высоко вверх.]];
		if not disabled 'ворота' then
			p [[В стене зияет разлом.]]
		end
		p [[Пещера, с помощью которой ты прошла сквозь горы, находится на востоке.]]
	end;
}: with {
	'голем';
	obj {
		nam = '#замок';
		-"скала|гора|замок|дворец|стена";
		description = [[Острые вершины скалы устремлены в небо.]];
		obj = { 'ворота' };
		['before_Enter,Walk,Climb'] = function(s)
			if disabled 'ворота' then
				return false
			end
			if _'голем':hasnt'moved' then
				move('голем', 'Тронный зал')
			end
			walk 'Тронный зал';
		end;
	}:attr 'scenery';
	Snow { nam = '#снег' };
	Sky { nam = '#небо' };
}

obj {
	-"мама,мать,королева,женщина";
	nam = 'королева';
	queen = false;
	init_dsc = function(s)
		p [[На троне сидит твоя мама.]]
		if s.queen then
			p [[Или это не мама?]]
		end
	end;
	before_Walk = function(s)
		return _'#трон':before_Walk()
	end;
	daemon = function(s)
		local tt = {
			"-- Иди ко мне скорее, моё дитя!",
			"-- Что же ты медлишь? Обними и поцелуй свою мать!",
			"-- Я так долго тебя ждала!",
			"-- Теперь всё будет хорошо, я буду любить тебя всегда!",
			"-- Мы будем вместе!",
		}
		p (tt[rnd(#tt)], " -- произносит твоя мать с трона.")
	end;
	['before_Talk,Say,Ask,Tell'] = function(s)
		if not s.queen then
			p [[Сначала ты хочешь рассмотреть её внимательней.]]
		else
			s:daemonStop()
			if visited'королева-диалог' then
				p [[-- Ты уже готова стать моей дочерью?^
-- Нет!^
-- Ну что же, я подожду.]]
			else
				if _'браслет':has 'worn' then
					walk 'королева-диалог'
				else
					walk 'badend2'
				end
			end
		end
	end;
	['before_Kiss,Touch'] = function(s)
		p [[Тебе кажется, что это не твоя мама. Тебе становится страшно.]]
	end;
	description = function(s)
		s.queen = true
		if _'Тронный зал'.near then
			p [[Женщина похожа на твою маму, но в чертах её лица ты видишь что-то незнакомое, чужое и, поэтому, неприятное.
Но больше всего тебя пугают её глаза. Ты не видишь их, потому что они закрыты. Ты растерянно вглядываешься в её лицо, снова и снова пытаясь отыскать родные черты.]];
		else
			p [[Это твоя мама! Не может быть! Что это за место? Что она тут делает? Столько вопросов!]]
		end
	end;
}:attr 'animate':with {
	obj {
		-"лицо";
		description = function(s)
			if _'Тронный зал'.near then
				_'королева':description()
			else
				p [[Отсюда плохо видно её лицо.]]
			end
		end;
	};
	obj {
		-"глаза";
		description = function(s)
			if _'Тронный зал'.near then
				if not visited 'королева-диалог' then
					p [[Её глаза закрыты. Как будто она спит. Тебе становится страшно.]]
				else
					p [[Ты стараешься не думать о глазах твоей {$fmt em|новой} мамы.]]
				end
			else
				p [[Отсюда плохо видны её глаза.]]
			end
		end;
	};
};

room {
	-"зал";
	nam = 'Тронный зал';
	near = false;
	in_to = function(s)
		if not disabled 'дверь' then
			return 'дверь'
		end
		return false
	end;
	n_to = function(s)
		if disabled 'дверь' and visited 'королева-диалог' then
			return 'голем'
		end
		if not disabled 'дверь' then
			return 'дверь'
		end
		return false
	end;
	before_Default = function(s, e, w)
		if not w then
			return false
		end
		if not w ^ 'королева' and not w ^ '#трон' then
			return false
		end
		if e == 'Exam' or s.near then
			return false
		end
		if e == 'Walk' then
			return false
		end
		p [[Сначала нужно подойти к трону.]]
	end;
	onexit = function(s, to)
		if to ^ 'королева-диалог' or to ^ 'badend2' then
			return
		end
		if not s.near then
			if _'браслет':hasnt'worn' then
				p [[Поддавшись смутному интуитивному чувству, ты покидаешь тронный зал.]]
				DaemonStop 'королева'
				return
			end
			p [[Ты нашла свою маму! Не время уходить!]]
			return false
		end
		if seen 'голем' then
			if not visited 'королева-диалог' then
				p [[Ты пытаешься уйти из зала, но ледяной голем преграждает тебе путь.]]
				return false
			end
		end
	end;
	enter = function(s)
		if s:once() then
			pn [[Набравшись мужества ты вошла внутрь и оказалась в длинном коридоре.]]
			p [[Голем последовал за тобой. Его шаги гулко отражались от изломанных стен и сводчатого потолка.]]
			pn [[Через некоторое время коридор кончился и вы вошли в большой зал.]]
			pn [[Зал был огромен! В его центре ты увидела трон, на котором сидела женщина... Твоя... мама?]]
			pn [[-- Я ждала тебя! Подойди же и поцелуй меня! -- голос матери, отраженный от ледяных стен зала показался тебе чужим.]]
			DaemonStart 'королева'
		end
	end;
	dsc = function(s)
		p [[Ты находишься в огромном зале. В центре зала установлен трон. Все пространство зала залито светом, который отражается
от ледяных стен, пола, потолка и массивных колонн. Выход находится на востоке.]];
		if not disabled'дверь' then
			p [[Дверь, ведущая в твою комнату, находится в северной стене.]]
		end
	end;
	['out_to,e_to'] = 'ворота';
}:with {
	obj {
		-"трон|кресло";
		nam = "#трон";
		['before_Enter,Climb'] = "Трон занят.";
		description = [[Великолепный трон сделан, как и всё вокруг, из льда. Высокая прямая спинка украшена причудливыми узорами.]];
		before_Walk = function(s)
			if _'Тронный зал'.near then
				return false
			end
			p [[Ты бежишь к трону. Твоё сердце от радости выпрыгивает из груди. Но что-то странное ты замечаешь в облике матери.
В нерешительности ты останавливаешься в нескольких шагах от неё.]]
			if _'браслет':hasnt 'worn' then
				DaemonStop'королева'
				walk 'badend2'
				return
			end
			_'Тронный зал'.near = true
		end;
	}:attr 'scenery,supporter';
	'королева';
	Prop { -"узоры|спинка|колонны" };
	door {
		-"деревянная дверь|дверь";
		nam = 'дверь';
		description = function(s) p [[Небольшая деревянная дверь. Странно, что она сделана не из льда.]]; return false; end;
		door_to = 'комната';
	}:disable():attr 'scenery';
	'ворота';
	obj {
		-"свет";
		before_Default = 'Как ты сделаешь это с светом?';
		before_Exam = 'Свет кажется тебе каким то бледным. Он не приносит радости.';
	}:attr 'scenery';
}

dlg {
	nam = 'королева-диалог';
	title = false;
	phr = {
		[[-- Иди же и обними меня! -- глаза матери по прежнему закрыты и это пугает тебя.]];
		{
			'Почему твои глаза закрыты?',
			'-- Поцелуй меня и я открою их.',
			next = '#дальше';
		};
		{
			'Ты точно моя мама?',
			'-- Да, а ты моя дочь. Я так ждала тебя, иди и обними меня.',
			next = '#дальше';
		};
	};
	exit = function()
		p [[^Твоя мама махнула рукой голему и тот, с грохотом, направился к северной стене зала. Дойдя до неё он остановился.]];
	end;
}: with {
	{
		'#дальше';
		{

			'Я не верю тебе! Ты не моя мама!';
			'-- Ну зачем ты так? Ты стала такой грубой!';
			{
				'Хватит претворяться!';
				'-- Я твоя {$fmt em|другая} мама. Я буду любить тебя вечно. Поцелуй меня, дитя.';
			};
			{
				'Куда ты дела мою настоящую маму?';
				'-- Здесь нет другой мамы, кроме меня. Зачем ты упрямишься? У нас есть целая вечность, чтобы полюбить друг-друга.';
			};
			{
				'Открой свои... чёртовы глаза!';
				'-- Хорошо, как скажешь... -- женщина открыла глаза. На месте глаз ты видишь чёрные отверстия. Тебе кажется, что ты сходишь с ума.';
			};
			onempty = function(s)
				push '#дальше2'
			end;

		};
		{
			'Хорошо, сейчас.';
			function(s)
				walk 'badend'
			end;
		};
	};
	{
		'#дальше2';
		{
			'Я знаю, ты забрала мою маму! Сейчас же верни её!';
			[[-- Хорошо, дитя. Жаль, что тебе нужно время, чтобы привыкнуть ко мне. Но я подожду. Мой слуга проводит тебя в твою комнату.]];
			{
				[[Я всё равно сбегу и найду свою настоящую маму! Я знаю -- она где-то здесь!]];
				[[-- Глупышка, ты думаешь я тебя обманываю? Знай, ты свободна ходить туда, куда хочешь. И делать то, что хочешь. Можешь искать свою... {$fmt em|другую} маму. Но не отказывай мне, посмотри свою комнату. Отдохни. И приходи ко мне, когда забудешь о своих фантазиях.]];
				{
					[[А если я найду маму, ты нас отпустишь?]];
					[[-- Ты никогда не найдёшь её. Но хорошо, я обещаю. Но и ты пообещай мне, что если не найдёшь её до рассвета, то станешь моей дочерью.]];
					{
						[[Хорошо, обещаю.]];
						function(s)
							p [[-- Ну что же, чувствуй себя как дома.]];
							walkout()
						end;
					};
					{
						[[Похоже, у меня нет выбора. Я в твоей власти? Мне не выбраться отсюда?]];
						function(s)
							p [[-- Хорошо, что мы поняли друг-друга.]];
							walkout()
						end
					}
				};
			}
		}
	}
}


cutscene {
	nam = 'badend';
	title = 'Конец';
	text = {
		[[Ты поднимаешься по ступенькам пьедестала и обнимаешь свою мать.]];
		[[От неё веет холодом, который сковывает тебя, но ты уже ничего не можешь изменить.]];
		[[Глаза Снежной Королевы открываются и ты смотришь в чёрную бездну...]];
		[[{$fmt b|{$fmt c|КОНЕЦ}}]];
		[[{$fmt r|{$fmt em|Но всё могло закончиться по другому...}}]];
	};
	next_to = 'королева-диалог';
}

cutscene {
	nam = 'badend2';
	title = false;
	text = {
		[[-- Не бойся меня, беззащитное дитя. Я вижу, что на тебе нет {$fmt em|её} талисмана. Это луче для нас обеих, всё закончится быстро...]];
		[[И все сомнения вдруг уходят. Чувствуя в глубине ужас, ты поднимаешься по ступенькам пьедестала и обнимаешь свою мать.]];
		[[От неё веет холодом, который сковывает тебя, и ты уже ничего не можешь изменить.]];
		[[Ты смотришь внутрь черных дыр-глаз Снежной Королевы...]];
		[[{$fmt b|{$fmt c|КОНЕЦ}}]];
		[[{$fmt r|{$fmt em|Но всё могло закончиться по другому...}}]];
	};
	next_to = 'Тронный зал';
}

room {
	nam = 'комната';
	enter = function(s)
		if s:once() then
			p [[За дверью оказалась лестница, которая вела вверх. Ты поднялась по ней и оказалась в ... своей комнате.]];
		end
	end;
	dsc = [[Это действительно твоя комната. Комната, в которой ты находилась ещё совсем недавно. Перед тем... как вы уехали...
Ты видишь тот же стол, шкаф, кровать... И даже окно! Правда, мебель стоит неправильно и на стене нет зеркала. Интересно, куда оно подевалось?]];
	out_to = 'Тронный зал';
}
