--[[扩展包信息]]--
module("extensions.study2", package.seeall)
extension = sgs.Package("study2")
--[[猪八戒]]--
zhubajie = sgs.General(extension, "zhubajie", "god", "5") 
--[[技能暗将]]--
SkillAnjiang = sgs.General(extension, "SkillAnjiang", "god", "5", true, true, true) 

SpeakCard = sgs.CreateSkillCard{ 
	name = "SpeakCard", 
	target_fixed = true, 
	will_throw = true, 
	on_use = function(self, room, source, targets) 
		source:speak("吃我一钉耙！") --聊天
	end
}
LuaSpeak = sgs.CreateViewAsSkill{ 
	name = "LuaSpeak", 
	n = 0, 
	view_as = function(self, cards) 
		return SpeakCard:clone()
	end
}

TianbianCard = sgs.CreateSkillCard{ 
	name = "TianbianCard", 
	target_fixed = true, --不用指定使用目标
	will_throw = true, --使用后不再保留
	on_use = function(self, room, source, targets) 
		local ids = self:getSubcards() --获取子卡编号列表
		room:askForGuanxing(source, ids, false) --执行观星
	end
}
LuaTianbian = sgs.CreateViewAsSkill{ 
	name = "LuaTianbian", 
	n = 4, --最多四张
	view_filter = function(self, selected, to_select) 
		return true --无其它限制，手牌装备均可
	end, 
	view_as = function(self, cards) 
		if #cards > 0 then --最少选择了一张卡牌
			--创建一张“天变”技能卡
			local vs_card = TianbianCard:clone() 
			--将所有选牌添加到此技能卡
			for _,card in pairs(cards) do 
				vs_card:addSubcard(card) --添加子卡
			end
			return vs_card
		end
	end, 
	enabled_at_play = function(self, player) 
		return not player:isNude() --没牌时不能发动
	end
}

LuaXiyue = sgs.CreateTriggerSkill{ 
	name = "LuaXiyue", 
	frequency = sgs.Skill_NotFrequent, 
	events = {sgs.EventPhaseStart}, 
	on_trigger = function(self, event, player, data) 
		if player:getPhase() == sgs.Player_Start then --回合开始阶段
			--询问发动技能
			if player:askForSkillInvoke(self:objectName(), data) then
				local room = player:getRoom() --当前房间
				local alives = room:getAlivePlayers() --所有存活角色列表
				--选择一名角色
				local target = room:askForPlayerChosen(player, alives, self:objectName())
				room:doGongxin(player, target) --执行攻心
			end
		end
	end
}

LuaHanshui = sgs.CreateTriggerSkill{ 
	name = "LuaHanshui", --“酣睡一”
	frequency = sgs.Skill_NotFrequent, --不频繁发动
	events = {sgs.EventPhaseStart}, --阶段开始时
	on_trigger = function(self, event, player, data) 
		local phase = player:getPhase() --当前阶段
		if phase == sgs.Player_Finish then --回合结束阶段
			--询问技能发动
			if player:askForSkillInvoke(self:objectName(), data) then
				local room = player:getRoom()
				--摸四张牌
				room:drawCards(player, 4, self:objectName()) 
				player:turnOver() --翻面
				--进入酣睡状态
				player:gainMark("@sleeping", 1) --获得“酣睡”标记
			end
		elseif phase == sgs.Player_Start then --回合开始阶段
			--解除酣睡状态
			player:loseAllMarks("@sleeping") --失去“酣睡”标记
		end
	end
}
LuaHanshuiDist = sgs.CreateDistanceSkill{ 
	name = "#LuaHanshuiDist", --隐藏技能“酣睡二”
	correct_func = function(self, from, to) 
		--如果目标角色处于酣睡状态
		if to:getMark("@sleeping") > 0 then 
			return -1
		end
	end
}

LuaLiwei = sgs.CreateTriggerSkill{ 
	name = "LuaLiwei", 
	frequency = sgs.Skill_Compulsory, --锁定技
	events = {sgs.TargetConfirmed}, --卡牌指定目标后
	on_trigger = function(self, event, player, data) 
		--现在这个player参数就表示当前被检查的玩家角色了。
		local use = data:toCardUse() --卡牌使用结构体
		local slash = use.card --使用的卡牌
		if slash:isKindOf("Slash") then --使用的是杀
			local source = use.from --杀的来源
			--检查当前角色是否为杀的来源
			if player:objectName() == source:objectName() then
				--触发效果
				local room = player:getRoom() --当前房间
				--获得其他所有角色
				local others = room:getOtherPlayers(source)
				--依次检查其他所有角色，找出拥有技能的other
				for _,other in sgs.qlist(others) do
					if other:hasSkill(self:objectName()) then
						--如果技能拥有者在杀的来源攻击范围内
						if source:inMyAttackRange(other) then 
							--流失一点体力
							room:loseHp(source, 1)
						end
					end
				end
			end
		end
	end, 
	can_trigger = function(self, target) 
		if target then --某玩家
			--if target:hasSkill(self:objectName()) then --拥有本技能
				if target:isAlive() then --且存活
					return true --允许触发
				end
			--end
		end
		return false --不能触发
	end
}

LuaYoucai = sgs.CreateTriggerSkill{ 
	name = "LuaYoucai", 
	frequency = sgs.Skill_NotFrequent, 
	events = {sgs.EventPhaseChanging}, 
	on_trigger = function(self, event, player, data) 
		local change = data:toPhaseChange() --阶段变更结构体
		local nextphase = change.to --将要进入的阶段
		if nextphase == sgs.Player_Play then --将进入出牌阶段
			--询问发动技能
			if player:askForSkillInvoke(self:objectName(), data) then
				local room = player:getRoom()
				--获取所有存活角色
				local alives = room:getAlivePlayers()
				--选择一名角色（作为技能发动的目标）
				local target = room:askForPlayerChosen(player, alives, "LuaYoucai") 
				--回复体力
				local lost = target:getLostHp() --已损失的体力
				local recover = sgs.RecoverStruct() --回复结构体
				recover.who = player --引起体力回复的角色
				recover.recover = lost --回复体力的数目
				room:recover(target, recover) --目标角色回复体力
				--跳过阶段
				if not player:isSkipped(nextphase) then
					player:skip(nextphase) 
				end
			end
		end
	end
}
--技能暗将添加技能
SkillAnjiang:addSkill(LuaYoucai) --有才

LuaXiucai = sgs.CreateTriggerSkill{ 
	name = "LuaXiucai", 
	frequency = sgs.Skill_Compulsory, 
	events = {sgs.GameStart}, 
	on_trigger = function(self, event, player, data) 
		local room = player:getRoom()
		--获得技能“有才”
		room:acquireSkill(player, "LuaYoucai", true) 
	end
}

LuaZhumieStart = sgs.CreateTriggerSkill{ 
	name = "#LuaZhumie", --隐藏技能
	frequency = sgs.Skill_NotFrequent, 
	events = {sgs.GameStart}, --游戏开始时
	on_trigger = function(self, event, player, data) 
		player:gainMark("@settle", 1) --获得标记
	end
}
LuaZhumie = sgs.CreateTriggerSkill{ 
	name = "LuaZhumie", 
	frequency = sgs.Skill_Limited, --限定技
	events = {sgs.Dying}, 
	on_trigger = function(self, event, player, data) 
		local room = player:getRoom()
		local dying = data:toDying() --濒死结构体
		local victim = dying.who --濒死中的角色
		if victim:objectName() == player:objectName() then
			if player:askForSkillInvoke(self:objectName(), data) then
				--回复所有体力
				local lost = player:getLostHp()
				local recover = sgs.RecoverStruct()
				recover.who = player
				recover.recover = lost
				room:recover(player, recover)
				--武将牌翻面
				player:turnOver()
				--令一名角色流失体力上限
				local alives = room:getAlivePlayers()
				local target = room:askForPlayerChosen(player, alives, "LuaZhumie")
				room:loseMaxHp(target, 1)
				--弃置“诛杀”标记
				player:loseMark("@settle", 1) 
			end
		end
	end, 
	can_trigger = function(self, target) 
		if target then --某玩家
			if target:hasSkill(self:objectName()) then --拥有本技能
				if target:isAlive() then --且存活
					return target:getMark("@settle") > 0 --有标记时允许触发
				end
			end
		end
		return false --不能触发
	end
}

LuaLingshengCard = sgs.CreateSkillCard{ 
	name = "LuaLingshengCard", 
	target_fixed = false, 
	will_throw = true, 
	filter = function(self, targets, to_select) 
		return #targets < 4
	end,
	on_use = function(self, room, source, targets) 
		--对所有目标角色逐一处理
		for _,target in ipairs(targets) do
			--弃置所有手牌和装备
			target:throwAllHandCardsAndEquips() 
			--摸四张牌
			room:drawCards(target, 4, self:objectName())
		end
		--失去一枚“圣首”标记
		source:loseMark("@leader", 1) 
	end
}
LuaLingsheng = sgs.CreateViewAsSkill{ 
	name = "LuaLingsheng", --与辅助触发技名相同
	n = 0, 
	view_as = function(self, cards) 
		local vs_card = LuaLingshengCard:clone() 
		return vs_card
	end, 
	enabled_at_play = function(self, player) 
		local count = player:getMark("@leader") 
		return count > 0
	end
}
LuaLingshengStart = sgs.CreateTriggerSkill{ 
	name = "LuaLingsheng", --没有“#”号，不再隐藏技能
	frequency = sgs.Skill_Limited, --限定技 
	events = {sgs.GameStart}, --游戏开始时机
	view_as_skill = LuaLingsheng, --相关的视为技
	on_trigger = function(self, event, player, data) 
		player:gainMark("@leader", 1) 
	end
}

LuaYuanshuai = sgs.CreateTriggerSkill{ 
	name = "LuaYuanshuai", 
	frequency = sgs.Skill_Wake, 
	events = {sgs.EventPhaseStart}, 
	on_trigger = function(self, event, player, data) 
		local phase = player:getPhase()
		if phase == sgs.Player_Start then
			local num = player:getHandcardNum()
			local hp = player:getHp()
			if num >= hp then
				local room = player:getRoom()
				room:setPlayerMark(player, "YuanshuaiWaked", 1)
				room:acquireSkill("xueyi")
				player:gainMark("@waked", 1)
			end
		end
	end, 
	can_trigger = function(self, target) 
		if target then
			if target:isAlive() then
				if target:hasSkill(self:objectName()) then
					return target:getMark("YuanshuaiWaked") == 0
				end
			end
		end
		return false
	end
}

LuaTianbing = sgs.CreateMaxCardsSkill{ 
	name = "LuaTianbing", 
	extra_func = function(self, target) 
		if target:hasSkill(self:objectName()) then
			--计算并产生额外的手牌上限数目
			local others = target:getSiblings() --所有其他人
			local count = 0 --计数变量
			for _,player in sgs.qlist(others) do --逐一扫描
				if player:isAlive() then --存活
					count = count + 1 --计数
				end
			end
			return count --得到额外的手牌上限数目
		end
	end
}
--技能暗将添加技能
SkillAnjiang:addSkill(LuaTianbing) --天兵

LuaYuanshuai = sgs.CreateTriggerSkill{ 
	name = "LuaYuanshuai", --技能名
	frequency = sgs.Skill_Wake, --触发频率：觉醒技
	events = {sgs.EventPhaseStart}, --触发时机
	on_trigger = function(self, event, player, data) 
		--触发效果
		local phase = player:getPhase() --当前阶段
		if phase == sgs.Player_Start then --回合开始阶段
			local room = player:getRoom()
			--觉醒过程
			local count = player:getHandcardNum() --当前手牌数目
			local hp = player:getHp() --当前体力值
			if count >= hp then
				--启用动画效果
				room:broadcastInvoke("animate", "lightbox:$YuanshuaiAnimate:5000") 
				--状态改变：流失一点体力上限
				room:loseMaxHp(player, 1)
				--获得新技能：天兵
				room:acquireSkill(player, "LuaTianbing") 
				--更新标记
				player:gainMark("@waked") --获得觉醒标记
				room:setPlayerMark(player, "YuanshuaiWaked", 1) --获得专属标记
			end
		end
	end, 
	can_trigger = function(self, target) 
		--触发条件
		if target then
			if target:hasSkill(self:objectName()) then --具有本技能
				if target:isAlive() then --且存活
					--同时没有已觉醒的专属标记“YuanshuaiWaked”
					local mark = target:getMark("YuanshuaiWaked") 
					return mark == 0
				end
			end
		end
		return false
	end, 
}
--[[添加技能]]--
zhubajie:addSkill(LuaSpeak)
zhubajie:addSkill(LuaTianbian)
zhubajie:addSkill(LuaXiyue)
zhubajie:addSkill(LuaHanshui) --酣睡一
zhubajie:addSkill(LuaHanshuiDist) --酣睡二
zhubajie:addSkill(LuaLiwei)
zhubajie:addSkill(LuaXiucai)
--诛灭
zhubajie:addSkill(LuaZhumieStart) --获得标记
zhubajie:addSkill(LuaZhumie) --主技能
--领圣
zhubajie:addSkill(LuaLingshengStart) --获得标记（含主技能）
zhubajie:addSkill(LuaYuanshuai)
--[[二师兄·猪八戒]]--
zhubajie2 = sgs.General(extension, "zhubajie2", "god", "5")

LuaQiangbao = sgs.CreateTriggerSkill{
	name = "LuaQiangbao",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart}, --阶段开始时机
	on_trigger = function(self, event, player, data)
		local phase = player:getPhase() --当前阶段
		if phase == sgs.Player_Draw then --摸牌阶段开始时
			--询问技能发动
			if player:askForSkillInvoke(self:objectName(), data) then
				--技能效果
				local room = player:getRoom() --当前房间
				local others = room:getOtherPlayers(player) --所有其他角色
				local target = room:askForPlayerChosen(player, others, self:objectName()) 
				--现在target就是我们找到的那位目标角色了
				local cards = target:getCards("ej") --装备区和判定区的所有牌的列表
				for _,card in sgs.qlist(cards) do --cards作为列表，要用sgs.qlist把门哦！
					room:obtainCard(player, card, true) --获得列表中的一张卡牌
				end
				--结束摸牌阶段
				return true
			end
		end
	end
}
--[[添加技能]]--
zhubajie2:addSkill(LuaQiangbao)
zhubajie2:addSkill(LuaPaji)
--[[翻译表]]--
sgs.LoadTranslationTable{
    ["study2"] = "学习II包",
	
	["zhubajie"] = "猪八戒",
	["&zhubajie"] = "猪八戒",
	["#zhubajie"] = "天蓬元帅",
	["designer:zhubajie"] = "设计者",
	["cv:zhubajie"] = "配音人员",
	["illustrator:zhubajie"] = "画师",
	
	["LuaSpeak"] = "聊天",
	[":LuaSpeak"] = "出牌阶段，你可以大吼一声：“吃我一钉耙！”令全场晕眩三秒钟。",
	["SpeakCard"] = "聊天",
	
	["LuaTianbian"] = "天变",
	[":LuaTianbian"] = "出牌阶段，你可以将至多四张手牌以任意顺序置于牌堆顶或牌堆底。",
	["TianbianCard"] = "天变",
	
	["LuaXiyue"] = "戏月",
	[":LuaXiyue"] = "回合开始阶段开始时，你可以观看一名角色的所有手牌，选择其中一张红心牌弃置或将其置于牌堆顶。",
	
	["LuaHanshui"] = "酣睡",
	[":LuaHanshui"] = "回合结束阶段开始时，你可以摸四张牌并将武将牌翻面，若如此做，其它角色与你计算距离时始终-1，直到你的下个回合开始。",
	["@sleeping"] = "酣睡",
	
	["LuaLiwei"] = "立威",
	[":LuaLiwei"] = "<b>锁定技</b>, 其他角色使用【杀】指定目标后，若你在其攻击范围内，该角色流失一点体力。",
	
	["LuaYoucai"] = "有才",
	[":LuaYoucai"] = "你可以跳过出牌阶段，令一名角色回复所有体力。",
	
	["LuaXiucai"] = "秀才",
	[":LuaXiucai"] = "<b>锁定技</b>, 游戏开始时，你获得技能“有才”（你可以跳过出牌阶段，令一名角色回复所有体力）。",
	
	["LuaZhumie"] = "诛灭",
	[":LuaZhumie"] = "<b>限定技</b>, 在你濒死时，你可以回复所有体力并将武将牌翻面，令一名角色流失一点体力上限。",
	["@settle"] = "诛杀",
	
	["LuaLingsheng"] = "领圣",
	[":LuaLingsheng"] = "<b>限定技</b>, 出牌阶段，你可以指定至多四名角色，每名角色分别弃置所有手牌和装备，并摸四张牌。",
	["@leader"] = "圣首",
	["LuaLingshengCard"] = "领圣",
	
	["LuaTianbing"] = "天兵",
	[":LuaTianbing"] = "<b>锁定技</b>, 你的手牌上限始终+X，其中X为当前场上存活的其他角色数目。",
	
	["LuaYuanshuai"] = "元帅",
	[":LuaYuanshuai"] = "<b>觉醒技</b>, 回合开始阶段开始时，若你的手牌数不少于你的体力值，你须减少一点体力上限，获得技能“天兵”（锁定技，你的手牌上限始终+X，其中X为当前场上存活的其他角色数目）。",
	["$YuanshuaiAnimate"] = "anim=skill/LuaYuanshuai", 
	
	["zhubajie2"] = "猪八戒",
	["&zhubajie2"] = "猪八戒",
	["#zhubajie2"] = "二师兄",
	["designer:zhubajie2"] = "设计者",
	["cv:zhubajie2"] = "配音人员",
	["illustrator:zhubajie2"] = "画师",
	
	["LuaQiangbao"] = "襁褓",
	[":LuaQiangbao"] = "摸牌阶段，你可以放弃摸牌，改为获得一名其他角色装备区和判定区的所有牌。",
	
	["LuaPaji"] = "耙击",
	[":LuaPaji"] = "<b>锁定技</b>，你使用的红色【杀】不可被闪避；你使用的黑色非延时性锦囊牌不能被【无懈可击】抵消。",
}