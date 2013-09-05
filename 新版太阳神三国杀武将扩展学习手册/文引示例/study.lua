--[[
	扩展包名称：学习包（study）
	说明：这个扩展包用于学习武将扩展
	作者：DGAH
	武将数目：总共1名武将，已完成1名武将
	武将列表：
		孙悟空（sunwukong）：无双（wushuang）、美王（LuaMeihouWang）
	尚需完善的内容：
		好多好多……
	备注：
		百度三国杀lua吧欢迎您！
]]--
module("extensions.study", package.seeall)
extension = sgs.Package("study")
--我是单行注释^_^
sunwukong = sgs.General(extension, "sunwukong", "god", "5")
--[[我们区块注释可以跨越好多行呢！怕了吧？]]--
LuaMeihouWang = sgs.CreateTriggerSkill{
	name = "LuaMeihouWang", --我们单行注释也可以写在句子的后面=_=
	frequency = sgs.Skill_Frequent,
	events = {sgs.DrawNCards},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if room:askForSkillInvoke(player, "LuaMeihouWang", data) then
			--创建一条消息
			local msg = sgs.LogMessage()
			msg.type = "#hello" --消息结构类型
			msg.to:append(player) --行为接受对象
			room:sendLog(msg) --发送消息
			--全屏信息特效（还是注释掉吧，总发动也怪烦的）
		--	room:broadcastInvoke("animate", "lightbox:$tangseng:4000")
			
			local count = data:toInt() + 10
			data:setValue(count)
			--周期性获得技能“陷阵”：
			if player:hasSkill("xianzhen") then --如果有陷阵技能
				room:detachSkillFromPlayer(player, "xianzhen") --失去技能陷阵
			else --如果没有陷阵技能
				room:acquireSkill(player, "xianzhen") --获得技能陷阵
			end
		end
	end
}

LuaBianshen = sgs.CreateTriggerSkill{
	name = "LuaBianshen",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.GameStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if room:askForSkillInvoke(player, "LuaBianshen", data) then
			room:changeHero(player, "sunquan", true, true, false, true)
		end
	end
}

LuaTengyun = sgs.CreateDistanceSkill{
	name = "LuaTengyun",
	correct_func = function(self, from, to)
		if from:hasSkill("LuaTengyun") then
			return -5
		end
		if to:hasSkill("LuaTengyun") then
			return 5
		end
	end,
}

LuaShentong = sgs.CreateMaxCardsSkill{
	name = "LuaShentong",
	extra_func = function(self, target)
		if target:hasSkill("LuaShentong") then
			local hp = target:getHp()
			return hp
		end
	end
}

LuaZiman = sgs.CreateTriggerSkill{
	name = "LuaZiman",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TurnStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		--[[不让它流失体力了
		room:loseHp(player)--流失体力
		]]--
		--[[改成自己对自己的一点伤害]]--
		local theDamage = sgs.DamageStruct()
		theDamage.from = player
		theDamage.to = player
		theDamage.damage = 1
		theDamage.nature = sgs.DamageStruct_Normal
		room:damage(theDamage)--造成伤害
		--[[再恢复一点体力]]--
		local theRecover = sgs.RecoverStruct()
		theRecover.recover = 1
		theRecover.who = player
		room:recover(player, theRecover)--恢复体力
	end
}

LuaMieyao = sgs.CreateTriggerSkill{
	name = "LuaMieyao",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damage},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if room:askForSkillInvoke(player, "LuaMieyao", data) then
			local damage = data:toDamage()--取得伤害结构体
			local victim = damage.to--伤害对象
			--[[怜悯人家一下，不流失体力上限了
			room:loseMaxHp(victim)--流失体力上限
			]]--
			--[[增长体力上限]]--
			local mhp = sgs.QVariant()--用于保存体力上限的变量
			local count = victim:getMaxHp()--获取体力上限
			mhp:setValue(count+1)--新的体力上限
			room:setPlayerProperty(victim, "maxhp", mhp)--增长体力上限
			--[[显示提示信息]]--
			local msg = sgs.LogMessage()
			msg.type = "#upgrade"
			msg.from = victim
			msg.arg = 1
			room:sendLog(msg)--发送提示信息
		end
	end
}

LuaRuyi = sgs.CreateTriggerSkill{
	name = "LuaRuyi",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local change = data:toPhaseChange()--获得阶段交替结构体
		local phase = change.to--找到将要进入的回合阶段
		--[[跳过判定阶段]]--
		if phase == sgs.Player_Judge then--如果那是判定阶段
			if not player:isSkipped(sgs.Player_Judge) then--如果阶段存在
				player:skip(phase)--跳过判定阶段
			end
		end
		--[[弃牌阶段后插入一个判定阶段]]--
		local room = player:getRoom()
		local lastphase = change.from--刚结束的回合阶段
		if lastphase == sgs.Player_Discard then--如果那是弃牌阶段
			change.to = sgs.Player_Judge--把将进入的改成判定阶段
			data:setValue(change)--更新阶段交替结构体
			player:insertPhase(sgs.Player_Judge)--插入额外的判定阶段
		end
	end
}

LuaXiuxi = sgs.CreateTriggerSkill{
	name = "LuaXiuxi",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},--阶段触发技
	on_trigger = function(self, event, player, data)
		local phase = player:getPhase()--获取当前回合阶段
		if phase == sgs.Player_Finish then--如果是回合结束阶段
			local room = player:getRoom()--获取当前房间
			--询问是否发动休息
			if room:askForSkillInvoke(player, "LuaXiuxi", data) then--发动
				player:turnOver()--武将牌翻面
			else--不发动
				local msg = sgs.LogMessage()
				msg.type = "#newturn"
				msg.from = player
				room:sendLog(msg)--发送消息
				player:gainAnExtraTurn()--获得一个额外的回合
			end
		end
	end
}

sunwukong:addSkill("wushuang") 
sunwukong:addSkill(LuaMeihouWang)
sunwukong:addSkill(LuaBianshen)
sunwukong:addSkill(LuaTengyun)
sunwukong:addSkill(LuaShentong)
sunwukong:addSkill(LuaZiman)
sunwukong:addSkill(LuaMieyao)
sunwukong:addSkill(LuaRuyi)
sunwukong:addSkill(LuaXiuxi)
--佛孙悟空
fosunwukong = sgs.General(extension, "fosunwukong", "god", "5")

LuaDousheng = sgs.CreateTriggerSkill{
	name = "LuaDousheng",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart},
	on_trigger = function(self, event, player, data)
		player:gainMark("@fight", 3)--获得3枚“斗胜”标记
	end
}

LuaJile = sgs.CreateTriggerSkill{
	name = "LuaJile",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local phase = player:getPhase()--获取当前回合阶段
		if phase == sgs.Player_Judge then--如果是判定阶段
			local count = player:getMark("@fight")--获取斗胜标记数目
			if count > 0 then--如果有斗胜标记
				local room = player:getRoom()--获取房间对象
				--询问是否发动技能“极乐”
				if room:askForSkillInvoke(player, "LuaJile", data) then
					player:loseAllMarks("@fight")--失去所有斗胜标记
					--获得所有其他角色名单
					local playerlist = room:getOtherPlayers(player)
					--对名单中的所有角色进行扫描
					for _,dest in sgs.qlist(playerlist) do
						room:loseHp(dest, 1)--失去一点体力
					end
				end
			end
		end
	end
}

LuaDoufo = sgs.CreateViewAsSkill{
	name = "LuaDoufo", 
	n = 1, 
	view_filter = function(self, selected, to_selected)
		return true
	end, 
	view_as = function(self, cards) 
		if #cards == 0 then--一张卡牌也没选是不能发动技能的
			return nil--直接返回，nil表示无效
		elseif #cards == 1 then--选择了一张卡牌
			local card = cards[1]--获得发动技能的卡牌
			local suit = card:getSuit()--卡牌的花色
			local point = card:getNumber()--卡牌的点数
			local id = card:getId()--卡牌的编号
			--创建一张虚构的（被视作的）决斗卡牌
			local vs_card = sgs.Sanguosha:cloneCard("duel", suit, point)
			--描述虚构决斗卡牌的构成
			vs_card:addSubcard(id)--用被选择的卡牌填充虚构卡牌
			vs_card:setSkillName("LuaDoufo")--创建虚构卡牌的技能名称
			return vs_card--返回一张虚构的决斗卡牌
		end
	end, 
}

LuaFuyun = sgs.CreateViewAsSkill{
	name = "LuaFuyun",
	n = 1,
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		if #cards == 0 then
			return nil
		elseif #cards == 1 then
			local card = cards[1]
			local suit = card:getSuit()
			local point = card:getNumber()
			local id = card:getId()
			local vs_card = sgs.Sanguosha:cloneCard("jink", suit, point)
			vs_card:addSubcard(id)
			vs_card:setSkillName("LuaFuyun")
			return vs_card
		end
	end, 
	enabled_at_play = function(self, player)
		return false
	end, 
	enabled_at_response = function(self, player, pattern)
		return pattern == "jink"
	end
}

LuaZixiu = sgs.CreateTriggerSkill{
	name = "LuaZixiu",
	frequency = sgs.Skill_Frequent,
	events = {sgs.DrawNCards},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if room:askForSkillInvoke(player, "LuaZixiu", data) then
			local count = player:getHandcardNum()
			local drawcount = data:toInt() + count
			data:setValue(drawcount)
		end
	end
}
--[[
LuaJushou = sgs.CreateTriggerSkill{
	name = "LuaJushou",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local phase = player:getPhase()
		if phase == sgs.Player_Finish then
			local room = player:getRoom()
			if room:askForSkillInvoke(player, self:objectName(), data) then
				room:drawCards(player, 3, self:objectName())
				player:turnOver()
			end
		end
	end
}
]]--
LuaYindu = sgs.CreateTriggerSkill{
	name = "LuaYindu",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damage},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local dest = damage.to--伤害目标
		if not dest:isNude() then--判断目标是否有牌
			local room = player:getRoom()
			if room:askForSkillInvoke(player, "LuaYindu", data) then
				--询问选择目标的1张牌，得到的是选中的卡牌的编号
				local id = room:askForCardChosen(player, dest, "he", "LuaYindu")
				--[[不弃牌了
				room:throwCard(id, dest, player)--弃置目标1张牌
					改成正面朝上获得牌]]--
				room:obtainCard(player, id, true)--获得1张牌
				room:drawCards(dest, 2, "LuaYindu")--目标摸2张牌
			end
		end
	end
}

LuaWajiao = sgs.CreateTriggerSkill{
	name = "LuaWajiao",
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
		local phase = player:getPhase()
		if phase == sgs.Player_Discard then
			local self_armor = player:getArmor()--获得自己的防具
			if not self_armor then--如果自己没有防具
				local room = player:getRoom()
				if player:askForSkillInvoke("LuaWajiao", data) then--询问发动技能
					--获得全场其它角色列表
					local targets = room:getOtherPlayers(player)
					--选择一个目标角色
					local victim = room:askForPlayerChosen(player, targets, "LuaWajiao")
					local armor = victim:getArmor()--获得目标的防具
					if armor then--如果目标有防具
						--移动卡牌
						room:moveCardTo(armor, player, sgs.Player_PlaceEquip)
					end
				end
			end
		end
	end
}

ShifanCard = sgs.CreateSkillCard{
	name = "ShifanCard", 
	target_fixed = false, 
	will_throw = true, 
	filter = function(self, targets, to_select) 
		return #targets == 0
	end,
	on_effect = function(self, effect) 
		local source = effect.from--使用者
		local dest = effect.to--使用目标
		local room = source:getRoom()--房间对象
		room:drawCards(source, 2)--使用者摸牌
		room:drawCards(dest, 2)--使用目标摸牌
		--设置标志：示范技能卡已使用
		room:setPlayerFlag(source, "shifan_used")
		--清除标志
		room:setPlayerFlag(source, "-shifan_used")
	end
}

LuaShifan = sgs.CreateViewAsSkill{
	name = "LuaShifan",
	n = 1,
	view_filter = function(self, selected, to_select)
		return to_select:getSuit() == sgs.Card_Spade
	end,
	view_as = function(self, cards)
		if #cards == 0 then
			return
		end
		local vs_card = ShifanCard:clone()
		vs_card:addSubcard(cards[1])
		return vs_card
	end,
	enabled_at_play = function(self, player)
		--检查标志：仅当没有此标志时才能发动技能
		return not player:hasFlag("shifan_used")
	end
}

DoufaCard = sgs.CreateSkillCard{
	name = "DoufaCard",
	target_fixed = true, 
	will_throw = true, 
	on_use = function(self, room, source, targets)
		room:drawCards(source, 1)--摸一张牌
		local judge = sgs.JudgeStruct()--判定结构体
		judge.who = source--判定对象
		judge.pattern = sgs.QRegExp("(.*):(spade):(.*)")--判定规则
		judge.good = true--判定结果：符合判断规则会更有利
		judge.reason = self:objectName()--判定原因
		room:judge(judge)--进行判定
		if judge:isGood() then--判定结果
			source:turnOver()--翻面
			local recover = sgs.RecoverStruct()--恢复结构体
			recover.recover = 1
			recover.who = source
			room:recover(source, recover)--恢复一点体力
		else
			--询问弃牌
			room:askForDiscard(source, "Doufa", 1, 1, false, true)
		end
	end
}

LuaDoufa = sgs.CreateViewAsSkill{
	name = "LuaDoufa",
	n = 0,--不用任何卡牌就可发动
	view_as = function(self, cards)
		local card = DoufaCard:clone()
		return card
	end
}

--引导技能卡
YindaoCard = sgs.CreateSkillCard{
	name = "YindaoCard",
	target_fixed = true,
	will_throw = false,
	on_effect = function(self, effect)
	end
}
--引导视为技
LuaYindaoVS = sgs.CreateViewAsSkill{
	name = "LuaYindaoVS",
	n = 1,
	view_filter = function(self, selected, to_select)
		return true
	end,
	view_as = function(self, cards)
		if #cards == 0 then
			return nil
		end
		local card = YindaoCard:clone()
		card:addSubcard(cards[1])
		return card
	end,
	enabled_at_play = function(self, player)
		return false--改判时才能用，不能主动使用
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@LuaYindao"--技能响应时
	end
}
--引导触发技（主技能）
LuaYindao = sgs.CreateTriggerSkill{
	name = "LuaYindao",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.AskForRetrial},
	view_as_skill = LuaYindaoVS,--视为触发了引导视为技
	on_trigger = function(self, event, player, data)
		if player:askForSkillInvoke("LuaYindao", data) then
			local judge = data:toJudge()
			local room = player:getRoom()
			local card = room:askForCard(player, "@LuaYindao", nil, data, sgs.AskForRetrial)
			room:retrial(card, player, judge, "LuaYindao")--进行改判
			return false
		end
	end
}

LuaFoguang = sgs.CreateTriggerSkill{
	name = "LuaFoguang",
	frequency = sgs.Skill_Frequent,
	events = {sgs.Damage, sgs.Damaged},--两个触发时机
	on_trigger = function(self, event, player, data)
		local light = player:getPile("light")--获得牌堆
		local n = light:length()--获得牌堆中卡牌的数目
		if n < 5 then--检查卡牌数目
			local room = player:getRoom()
			if room:askForSkillInvoke(player, "LuaFoguang", data) then
				local damage = data:toDamage()
				local count = damage.damage--伤害点数
				local ids = room:getNCards(count)--从牌堆摸牌
				player:addToPile("light", ids)--添加到"光"牌堆
			end
		end
	end
}

PuzhaoCard = sgs.CreateSkillCard{
	name = "PuzhaoCard",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		--技能效果
		local light = source:getPile("light")
		room:fillAG(light, source)--填充AG窗口
		--选择一张卡牌
		local id = room:askForAG(source, light, false, "LuaPuzhao")
		room:throwCard(id, source)--弃置被选择的卡牌
		source:invoke("clearAG")--清空并关闭AG窗口
		local card = sgs.Sanguosha:getCard(id)--获得被弃掉的卡牌
		local number = card:getNumber()--得到卡牌点数
		local list = room:getAlivePlayers()--得到存活武将列表
		--选择一名场上武将
		local dest = room:askForPlayerChosen(source, list, "LuaPuzhao")
		local count = (number+1) / 2--计算摸牌数目
		room:drawCards(dest, count, "LuaPuzhao")--武将摸牌
	end
}

LuaPuzhao = sgs.CreateViewAsSkill{
	name = "LuaPuzhao",
	n = 0,
	view_as = function(self, cards)
		local card = PuzhaoCard:clone()
		return card
	end,
	enabled_at_play = function(self, player)
		--发动条件
		local light = player:getPile("light")
		return light:length() > 0
	end
}

fosunwukong:addSkill(LuaDousheng)
fosunwukong:addSkill(LuaJile)
fosunwukong:addSkill(LuaDoufo)
fosunwukong:addSkill(LuaFuyun)
fosunwukong:addSkill(LuaZixiu)
--fosunwukong:addSkill(LuaJushou)
fosunwukong:addSkill(LuaYindu)
--这个添加技能一定要在技能创建之后进行
--要是在之前就添加，会打不开游戏的。
sunwukong:addSkill(LuaWajiao)--技能“挖角”
fosunwukong:addSkill(LuaShifan)
fosunwukong:addSkill(LuaDoufa)
fosunwukong:addSkill(LuaYindao)
fosunwukong:addSkill(LuaFoguang)
fosunwukong:addSkill(LuaPuzhao)
--小孙悟空
xiaosunwukong = sgs.General(extension, "xiaosunwukong$", "qun", "5")

LuaTanzui = sgs.CreateFilterSkill{
	name = "LuaTanzui",
	view_filter = function(self, to_select)
		local suit = to_select:getSuit()--花色
		return suit == sgs.Card_Heart--检查是否为红心牌
	end,
	view_as = function(self, card)
		local id = card:getId()
		local suit = card:getSuit()
		local point = card:getNumber()
		--创建一张卡牌：桃
		local peach = sgs.Sanguosha:cloneCard("peach", suit, point)
		peach:setSkillName("LuaTanzui")
		--返回锁定视为的卡牌
		local vs_card = sgs.Sanguosha:getWrappedCard(id)
		vs_card:takeOver(peach)--赋予卡牌新的内涵：桃
		return vs_card
	end
}

LuaWangyou = sgs.CreateProhibitSkill{
	name = "LuaWangyou", 
	is_prohibited = function(self, from, to, card) 
		if to:hasSkill("LuaWangyou") then
			return card:isKindOf("SavageAssault") or card:isKindOf("Duel")
		end
	end
}

HaolingCard = sgs.CreateSkillCard{
	name = "HaolingCard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		if #targets == 0 then--还没选择目标时
			local player = sgs.Self--技能卡使用者，也就是自己
			--如果可以杀目标
			if player:canSlash(to_select, nil, false) then
				return true
			end
		end
		--已经选过了目标，就不能再选择了
		return false
	end,
	on_use = function(self, room, source, targets)
		--创建一张杀，sgs.Card_NoSuit表示无花色，0表示无点数
		local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		slash:setSkillName("LuaHaoling")--设置技能名字
		--填充卡牌使用结构体
		local use = sgs.CardUseStruct()--创建结构体
		use.card = slash--添加使用卡牌：杀
		use.from = source--添加使用者
		local dest = targets[1]
		use.to:append(dest)--添加使用目标
		--视为使用一张杀
		room:useCard(use)
		room:setPlayerFlag(source, "haoling_used")--设置标志
	end
}

LuaHaoling = sgs.CreateViewAsSkill{
	name = "LuaHaoling",
	n = 0,
	view_as = function(self, cards)
		local card = HaolingCard:clone()
		return card
	end,
	enabled_at_play = function(self, player)
		return not player:hasFlag("haoling_used")
	end
}

LuaBingding = sgs.CreateTriggerSkill{
	name = "LuaBingding",
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardAsked},
	on_trigger = function(self, event, player, data)
		local pattern = data:toString()--获得需要的卡牌类型
		if pattern == "jink" then--如果需要出闪
			local room = player:getRoom()
			if room:askForSkillInvoke(player, "LuaBingding", data) then
				--创建一张闪
				local jink = sgs.Sanguosha:cloneCard("jink", sgs.Card_NoSuit, 0)
				jink:setSkillName("LuaBingding")
				room:provide(jink)--提供了一张闪
			end
		end
	end
}

LuaJixu = sgs.CreateTriggerSkill{
	name = "LuaJixu",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DrawNCards, sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.DrawNCards then--摸牌阶段 
			local count = data:toInt()--原有摸牌数目
			if count > 0 then
				if room:askForSkillInvoke(player, "LuaJixu", data) then
					data:setValue(count-1)--少摸一张牌
					local judge = sgs.JudgeStruct()
					judge.who = player
					judge.pattern = sgs.QRegExp("(.*):(.*):(.*)")
					judge.reason = "LuaJixu",
					room:judge(judge)
					local card = judge.card--判定牌
					if card:isKindOf("BasicCard") then--如果属于基本牌
						local point = card:getNumber()--得到点数
						--设置标签
						room:setTag("Jixu_count", sgs.QVariant(point))
					end
				end
			end
		elseif event == sgs.EventPhaseStart then
			local phase = player:getPhase()
			if phase == sgs.Player_Finish then--回合结束阶段
				--多摸X张牌
				local tag = room:getTag("Jixu_count")--获取标签
				local x = tag:toInt()--得到多摸的数目X
				room:drawCards(player, x, "LuaJixu")--摸牌
				room:removeTag("Jixu_count")--清除标签
			end
		end
	end
}

LuaHuwei = sgs.CreateTriggerSkill{
	name = "LuaHuwei", 
	frequency = sgs.Skill_NotFrequent, 
	events = {sgs.Dying},--时机：进入濒死状态时   
	on_trigger = function(self, event, player, data) 
		local dying = data:toDying()--濒死结构体
		local dest = dying.who--濒死中的武将
		local room = dest:getRoom()
		--查找具有“护卫”技能的武将
		local source = room:findPlayerBySkillName("LuaHuwei")
		--不能对自己发动技能，要“其他角色”
		if source:objectName() ~= dest:objectName() then
			if room:askForSkillInvoke(source, "LuaHuwei", data) then
				room:loseHp(source, 1)--流失一点体力
				room:drawCards(source, 1, "LuaHuwei")--摸一张牌
				local recover = sgs.RecoverStruct()
				recover.who = source--恢复来源
				recover.recover = 1
				room:recover(dest, recover)--恢复一点体力
			end
		end
	end, 
	can_trigger = function(self, target)
		return (target ~= nil)--修改触发条件：有处于濒死的目标存在
	end, 
}

JindouCard = sgs.CreateSkillCard{
	name = "JindouCard",
	target_fixed = false,--手动选择目标
	will_throw = true,
	filter = function(self, targets, to_select)
		return #targets < 2
	end,
	feasible = function(self, targets)
		return #targets == 2--选择2名角色才能使用
	end,
	on_use = function(self, room, source, targets)
		local playerA = targets[1]
		local playerB = targets[2]
		room:swapSeat(playerA, playerB)--交换座位
	end
}

LuaJindou = sgs.CreateViewAsSkill{
	name = "LuaJindou",
	n = 0,
	view_as = function(self, cards)
		local card = JindouCard:clone()
		card:setSkillName("LuaJindou")
		return card
	end
}

LuaHouwang = sgs.CreateTriggerSkill{
	name = "LuaHouwang$",--主公技，添加“$”符号
	frequency = sgs.Skill_NotFrequent,
	--人为添加了触发时机：sgs.TurnStart
	events = {sgs.TurnStart, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.TurnStart then--回合开始阶段
			--设置标志
			room:setPlayerFlag(player, "ExtraPermission")
		elseif event == sgs.EventPhaseChanging then--阶段之间的时间点
			local change = data:toPhaseChange()
			local phase = change.from
			if phase == sgs.Player_Play then--之前如果是出牌阶段
				--拥有标志则说明之前是原有的出牌阶段
				if player:hasFlag("ExtraPermission") then
					--立即清除标志
					room:setPlayerFlag(player, "-ExtraPermission")
					local list = room:getOtherPlayers(player)--获得其他角色列表
					local count = 0
					for _,p in sgs.qlist(list) do
						if p:getKingdom() == "qun" then--查找到群雄武将
							count = count + 1--统计群雄武将数目
						end
					end
					if count > 0 then--若存在群雄武将，询问是否发动技能
						if room:askForSkillInvoke(player, "LuaHouwang", data) then
							--设置标签，保存群雄武将（额外出牌阶段）的数目
							room:setTag("ExtraCount", sgs.QVariant(count))
							local msg = sgs.LogMessage()
							msg.type = "#KingStart"
							msg.from = player
							msg.arg = count
							room:sendLog(msg)--发送信息
						end
					end
				end
				local tag = room:getTag("ExtraCount")--获取标签
				local count = tag:toInt()--得到剩余额外出牌阶段的数目
				if count > 0 then--如果还有额外的出牌阶段
					--更新标签中的额外出牌阶段数目
					count = count - 1
					room:setTag("ExtraCount", sgs.QVariant(count))
					local msg = sgs.LogMessage()
					msg.type = "#KingPlay"
					msg.from = player
					msg.arg = count
					room:sendLog(msg)--发送信息
					--插入额外出牌阶段
					change.to = sgs.Player_Play
					data:setValue(change)
					player:insertPhase(sgs.Player_Play)
				end
			end
		end
	end
}

LuaYangming = sgs.CreateTriggerSkill{
	name = "LuaYangming$",--主公技，以“$”结尾
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.HpRecover},--恢复体力时
	on_trigger = function(self, event, player, data)
		local recover = data:toRecover()
		local count = recover.recover--摸牌的数目
		--让主公（孙悟空）摸牌
		local room = player:getRoom()
		local list = room:getOtherPlayers(player)--获得其他所有角色列表
		for _,lord in sgs.qlist(list) do
			if lord:hasLordSkill("LuaYangming") then--判断是否拥有此技能
				if room:askForSkillInvoke(player, "LuaYangming", data) then
					room:drawCards(lord, count, "LuaYangming")--摸牌
				end
			end
		end
	end,
	can_trigger = function(self, target)
		if not target then--判断恢复体力的目标是否存在
			return false
		end
		local kingdom = target:getKingdom()
		return kingdom == "qun"--群雄势力可以发动
	end
}

LuaBTSkill_Mozhou = sgs.CreateTriggerSkill{
	name = "LuaMozhou",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damaged},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local victim = damage.from
		local room = player:getRoom()
		local killer = sgs.DamageStruct()
		killer.from = player--凶手
		room:killPlayer(victim, killer)--直接死亡
	end
}

LuaBTSkill_Zhongxin = sgs.CreateTriggerSkill{
	name = "LuaZhongxin",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart},
	on_trigger = function(self, event, player, data)
		local role = player:getRole()--获取身份
		if role ~= "lord" then--若不为主公
			local room = player:getRoom()
			--改换身份为忠臣
			room:setPlayerProperty(player, "role", sgs.QVariant("loyalist"))
		end
	end
}

LuaBTSkill_Chongsheng = sgs.CreateTriggerSkill{
	name = "LuaChongsheng",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Death},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local mygod = room:findPlayerBySkillName("LuaChongsheng")
		if mygod then
			if mygod:isAlive() then
				if room:askForSkillInvoke(mygod, "LuaChongsheng", data) then
					room:revivePlayer(player)
				end
			end
		end
	end,
	can_trigger = function(self, target)
		return target
	end
}

VictoryCard = sgs.CreateSkillCard{
	name = "VictoryCard",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		local winner = source:objectName()
		room:gameOver(winner)
	end
}

LuaBTSkill_Victory = sgs.CreateViewAsSkill{
	name = "LuaVictory",
	n = 0,
	view_as = function(self, cards)
		local card = VictoryCard:clone()
		card:setSkillName("LuaVictory")
		return card
	end,
}
--[[封杀所有技能:
xiaosunwukong:addSkill(LuaTanzui)
xiaosunwukong:addSkill(LuaWangyou)
xiaosunwukong:addSkill(LuaHaoling)
xiaosunwukong:addSkill(LuaBingding)
xiaosunwukong:addSkill(LuaJixu)
xiaosunwukong:addSkill(LuaHuwei)
xiaosunwukong:addSkill(LuaJindou)
xiaosunwukong:addSkill(LuaHouwang)
xiaosunwukong:addSkill(LuaYangming)
]]--
--添加强力技能：魔咒
xiaosunwukong:addSkill(LuaBTSkill_Mozhou)
xiaosunwukong:addSkill(LuaBTSkill_Zhongxin)
xiaosunwukong:addSkill(LuaBTSkill_Chongsheng)
xiaosunwukong:addSkill(LuaBTSkill_Victory)

sgs.LoadTranslationTable{
	["study"] = "学习包",
	
	["sunwukong"] = "孙悟空",
	["&sunwukong"] = "孙悟空",
	["#sunwukong"] = "齐天大圣",
	["designer:sunwukong"] = "创建者",
	["cv:sunwukong"] = "配音人员",
	["illustrator:sunwukong"] = "画师",
	["LuaMeihouWang"] = "美王",
	[":LuaMeihouWang"] = "摸牌阶段，你可以额外摸十张牌。",
	["$LuaMeihouWang"] = "技能 美王 的台词。",
	["~sunwukong"] = "孙悟空 的阵亡台词。",
	["#hello"] = "Hello！太阳神三国杀向你%to问好！",
	["$tangseng"] = "悟空，你还是跟为师西天取经吧……",
	["LuaBianshen"] = "变身",
	[":LuaBianshen"] = "游戏开始时，你可以变身成孙权。",
	["LuaTengyun"] = "腾云",
	[":LuaTengyun"] = "<b>锁定技</b>,你计算的与其他角色的距离-5；其他角色计算的与你的距离+5。",
	["LuaShentong"] = "神通",
	[":LuaShentong"] = "<b>锁定技</b>,你的手牌上限为当前体力值的2倍。",
	["LuaZiman"] = "自满",
	[":LuaZiman"] = "<b>锁定技</b>,回合开始阶段开始时，你须流失1点体力。",
	["LuaMieyao"] = "灭妖",
	[":LuaMieyao"] = "每当你对一名角色造成一次伤害后，你可以令该角色增加1点体力上限。",
	["#upgrade"] = "%from 增加了 %arg 点体力上限。",
	["LuaRuyi"] = "如意",
	[":LuaRuyi"] = "<b>锁定技</b>,你跳过判定阶段。",
	["LuaXiuxi"] = "休息",
	[":LuaXiuxi"] = "<b>锁定技</b>,回合结束阶段开始时，你需将武将牌翻面，否则你进行一个额外的回合。",
	["#newturn"] = "%from 获得了一个额外的回合。",
	["LuaWajiao"] = "挖角",
	[":LuaWajiao"] = "弃牌阶段开始时，你可以将一名角色装备区内的防具牌置入你的装备区。",
	
	["fosunwukong"] = "孙悟空",
	["&fosunwukong"] = "孙悟空",
	["#fosunwukong"] = "斗战胜佛",
	["designer:fosunwukong"] = "创建者",
	["cv:fosunwukong"] = "配音人员",
	["illustrator:fosunwukong"] = "画师",
	["@fight"] = "斗胜",
	["LuaDousheng"] = "斗胜",
	[":LuaDousheng"] = "<b>锁定技</b>,游戏开始时，你获得3枚“斗胜”标记。",
	["LuaJile"] = "极乐",
	[":LuaJile"] = "判定阶段开始时，你可以弃置所有的“斗胜”标记（至少1枚），令所有其他角色各失去1点体力。",
	["LuaDoufo"] = "斗佛",
	[":LuaDoufo"] = "你可以将一张牌当作【决斗】使用。",
	["LuaFuyun"] = "浮云",
	[":LuaFuyun"] = "你可以将一张手牌当作【闪】使用或打出。",
	["LuaZixiu"] = "自修",
	[":LuaZixiu"] = "摸牌阶段，你可以额外摸等同于你当前手牌数的牌。",
	["LuaYindu"] = "引渡",
	[":LuaYindu"] = "每当你对一名角色造成一次伤害后，你可以获得其一张牌，然后该角色摸两张牌。",
	["ShifanCard"] = "示范",
	["LuaShifan"] = "示范",
	[":LuaShifan"] = "出牌阶段，你可以弃置一张黑桃牌并选择一名角色，你和该角色各摸两张牌。",
	["DoufaCard"] = "斗法",
	["LuaDoufa"] = "斗法",
	[":LuaDoufa"] = "出牌阶段，你可以摸一张牌并进行一次判定，若结果为黑桃，你将武将牌翻面并恢复1点体力，否则你弃置一张牌。",
	["LuaYindao"] = "引导",
	[":LuaYindao"] = "一名角色的判定牌生效前，你可以打出一张牌代替之。",
	["LuaYindaoVS"] = "引导视为技",
	["YindaoCard"] = "引导技能卡",
	["light"] = "光",
	["LuaFoguang"] = "佛光",
	[":LuaFoguang"] = "每当你造成或受到1点伤害后，你可以摸一张牌并将其置于你的武将牌上，称为“光”（最多5张）。",
	["PuzhaoCard"] = "普照",
	["LuaPuzhao"] = "普照",
	[":LuaPuzhao"] = "出牌阶段，你可以弃一张“光”并选择场上一名角色，该角色摸X张牌。X为这张“光”的点数的一半（向上取整）。",
	
	["xiaosunwukong"] = "孙悟空",
	["&xiaosunwukong"] = "孙悟空",
	["#xiaosunwukong"] = "美猴王",
	["designer:xiaosunwukong"] = "创建者",
	["cv:xiaosunwukong"] = "配音人员",
	["illustrator:xiaosunwukong"] = "画师",
	["LuaTanzui"] = "贪嘴",
	[":LuaTanzui"] = "<b>锁定技</b>,你的红桃牌均视为桃。",
	["LuaWangyou"] = "忘忧",
	[":LuaWangyou"] = "<b>锁定技</b>,你不能被选择为【南蛮入侵】或【决斗】的目标。",
	["HaolingCard"] = "号令",
	["LuaHaoling"] = "号令",
	[":LuaHaoling"] = "出牌阶段，你可以选择一名其他角色，视为对其使用一张【杀】。每阶段限一次。",
	["LuaBingding"] = "兵丁",
	[":LuaBingding"] = "每当你需要使用一张【闪】时，可以视为你使用了一张【闪】。",
	["LuaJixu"] = "积蓄",
	[":LuaJixu"] = "摸牌阶段，你可以少摸一张牌并进行一次判定，若结果为基本牌,则回合结束阶段开始时,你可以摸X张牌，其中X为此基本牌的点数。",
	["LuaHuwei"] = "护卫",
	[":LuaHuwei"] = "一名其他角色进入濒死状态时，你可以失去1点体力并摸一张牌，令其恢复1点体力。",
	["JindouCard"] = "筋斗",
	["LuaJindou"] = "筋斗",
	[":LuaJindou"] = "出牌阶段，你可以交换两名角色的位置。",
	["LuaHouwang"] = "猴王",
	[":LuaHouwang"] = "<b>主公技</b>,出牌阶段结束后执行额外的X个出牌阶段。X为当时场上存活的其他群雄角色的数目。",
	["#KingStart"] = "当前场上共有%arg名群雄武将存活，%from将获得%arg个额外的出牌阶段。",
	["#KingPlay"] = "%from进入了一个额外的出牌阶段，当前还剩下%arg个额外的出牌阶段。",
	["LuaYangming"] = "扬名",
	[":LuaYangming"] = "<b>主公技</b>,其他群雄角色每回复1点体力，可以让你摸一张牌。",
	["LuaMozhou"] = "魔咒",
	[":LuaMozhou"] = "<b>锁定技</b>,对你造成伤害的角色在伤害结算后死亡。",
	["LuaZhongxin"] = "忠心",
	[":LuaZhongxin"] = "<b>锁定技</b>,游戏开始时，若你的身份不为主公，你须将身份改为忠臣。",
	["LuaChongsheng"] = "重生",
	[":LuaChongsheng"] = "每当有其他角色死亡时，你可以令其复活。",
	["VictoryCard"] = "至尊",
	["LuaVictory"] = "至尊",
	[":LuaVictory"] = "你赢了。",
}
