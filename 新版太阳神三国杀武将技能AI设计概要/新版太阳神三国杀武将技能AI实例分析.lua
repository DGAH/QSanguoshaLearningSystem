--[[
	新版太阳神三国杀武将技能AI实例分析
	编者：DGAH
	说明：本文为《新版太阳神三国杀武将技能AI设计概要》的扩展阅读部分。
	目录：
		一、触发技实例分析（技能发动）Line25～Line63
		二、触发技实例分析（卡牌使用）Line65～Line149
		三、触发技实例分析（卡牌打出）Line151～Line212
		四、触发技实例分析（询问选择）Line214～Line256
		五、触发技实例分析（角色选择）Line258～Line309
		六、触发技实例分析（卡牌选择）Line311～Line366
		七、触发技实例分析（五谷丰登选牌）Line368～Line411
		八、触发技实例分析（卡牌展示）Line413～Line464
		九、触发技实例分析（询问花色）Line466～Line520
		十、触发技实例分析（询问遗计）Line522～Line529
		十一、触发技实例分析（询问拼点）Line531～Line538
		十二、触发技实例分析（询问弃牌）Line540～Line547
		十三、视为技实例分析（卡牌使用）Line549～Line625
		十四、视为技实例分析（卡牌响应）Line627～Line681
		十五、视为技实例分析（锁定视为技）Line683～Line741
		十六、视为技实例分析（技能卡）Line743～Line858
		十七、技能实例综合分析 Line860～Line993
]]--

--[[************************************************************************************************
	一、触发技实例分析（技能发动）
	目标：Room:askForSkillInvoke()、ServerPlayer:askForSkillInvoke()
	方法：sgs.ai_skill_invoke[skill_name](self, data)
]]--************************************************************************************************

--	伤摸（技能）：当你受到一次伤害时，你可以摸两张牌。
--	技能代码如下：
LuaShangmo = sgs.CreateTriggerSkill{ 
	name = "LuaShangmo", 
	frequency = sgs.Skill_NotFrequent, 
	events = {sgs.Damaged}, 
	on_trigger = function(self, event, player, data) 
		if player:askForSkillInvoke(self:objectName(), data) then
			player:drawCards(2, true, self:objectName())
		end
	end
}

--	分析：这段技能代码中，出现了询问技能发动的部分askForSkillInvoke，即
player:askForSkillInvoke(self:objectName(), data)
--	考虑到self:objectName()的结果，也就是这个技能本身的名字，是"LuaShangmo"，所以这句话等价于：
player:askForSkillInvoke("LuaShangmo", data)

--	根据获得AI支持的方法，在AI文件中应该这样写：
sgs.ai_skill_invoke["LuaShangmo"] = function(self, data)
end
--	注意方括号中的"LuaShangmo"正是askForSkillInvoke中提供的参数"LuaShangmo"，这里一定要对应上。
--	而后面function(self, data)中的data参数，就是askForSkillInvoke中提供的参数data，也是对应的。

--	通常这个技能是一定发动的，那么这个function(self, data)可以简化为一个bool值：true，也就是：
sgs.ai_skill_invoke["LuaShangmo"] = true
--	表示始终发动技能"LuaShenmo"

--	如果我们要求只在伤害点数超过1时才发动技能，那么就需要获得伤害结构体中的信息，而这是通过data传递的：
sgs.ai_skill_invoke["LuaShangmo"] = function(self, data)
	local damage = data:toDamage() --伤害结构体，由askForSkillInvoke传递而来
	return damage.damage > 1
end

--[[************************************************************************************************
	二、触发技实例分析（卡牌使用）
	目标：Room:askForUseCard()
	方法：sgs.ai_skill_use[pattern](self, prompt, method)
]]--************************************************************************************************

--	闪卡（技能）：当你打出一张闪时，你可以立即对一名角色使用一张技能卡。
LuaShankaCard = sgs.CreateSkillCard{ 
	name = "LuaShankaCard", 
	target_fixed = false, 
	filter = function(self, targets, to_select) 
		return true
	end,
}
LuaShankaVS = sgs.CreateViewAsSkill{ 
	name = "LuaShanka", 
	n = 0, 
	view_as = function(self, cards) 
		return LuaShankaCard:clone()
	end, 
	enabled_at_play = function(self, player) 
		return false
	end, 
	enabled_at_response = function(self, player, pattern) 
		return pattern == "@@LuaShanka"
	end
}
LuaShanka = sgs.CreateTriggerSkill{ 
	name = "LuaShanka", 
	frequency = sgs.Skill_NotFrequent, 
	events = {sgs.CardResponsed}, 
	view_as_skill = LuaShankaVS, 
	on_trigger = function(self, event, player, data) 
		local resp = data:toResponsed()
		if resp.m_card:isKindOf("Jink") then
			if resp.m_who:objectName() == player:objectName() then
				local room = player:getRoom()
				room:askForUseCard(player, "@@LuaShanka", "@LuaShanka")
			end
		end
	end
}

--	分析：这段代码中，出现了询问卡牌使用的部分askForUseCard，即：
room:askForUseCard(player, "@@LuaShanka", "@LuaShanka")

--	根据获得AI支持的方法，在AI文件中应该这样写：
sgs.ai_skill_use["@@LuaShanka"] = function(self, prompt, method)
end
--	方括号中的"@@LuaShanka"表示对卡牌的要求，也就是askForUseCard中提供的pattern参数。
--	在function(self, prompt, method)中，参数prompt就是askForUseCard提供的prompt参数，本例中它的值应该是"@LuaShanka"。
--	参数method也是askForUseCard提供的同名参数，本例中此参数被忽略，太阳神三国杀自动将其填充为sgs.Card_MethodUse。
--	假定我们通过分析，找到了一个合适的使用目标target，那么结果应该这样产生：
sgs.ai_skill_use["@@LuaShanka"] = function(self, prompt, method)
	local target = nil
	--[[确定target的过程，此处略去]]--
	if target then
		local card_str = "#LuaShankaCard:.:->"..target:objectName()
		return card_str
	end
	return "."
end

--	如果使用目标有多个，那么可以先将它们的对象名置于一个名单table中，然后通过table.concat()函数连接成字符串。
--	比如，将技能改为，“你可以立即对三名角色使用一张技能卡”，那么我们可以这样写：
sgs.ai_skill_use["@@LuaShanka"] = function(self, prompt, method)
	local targets = {}
	--[[确定targets的过程，注意targets中应该是所有目标的objectName()]]--
	if #targets == 3 then
		local card_str = "#LuaShankaCard:.:->"..table.concat(targets, "+")
		return card_str
	end
	return "."
end

--	没有使用目标的情形，card_str部分简化为：
local card_str = "#LuaShankaCard:.:"

--	如果是有子卡的情形，只是结果card_str在两个冒号间的部分有些变化，而基本要求还是一样的。
--	比如，用卡牌mycard作为技能卡的子卡，对target使用，那么card_str将改为：
local card_str = "#LuaShankaCard:"..mycard:getId()..":->"..target:objectName()

--	而多张子卡的情形，也是可以想到的：
local card_str = "#LuaShankaCard:"..table.concat(card_ids, "+")..":->"..target:objectName()
--	只是事先应把所有选出的子卡的编号依次记录在一个table中（这里的card_ids）。

--[[************************************************************************************************
	三、触发技实例分析（卡牌打出）
	目标：Room:askForCard()
	方法：sgs.ai_skill_cardask[ prompt:split(":")[1] ](self, data, pattern, target, target2)
]]--************************************************************************************************

--	指弃（技能）：当你被指定为【杀】的目标时，你可以弃一张武器牌，然后摸三张牌。
LuaZhiqi = sgs.CreateTriggerSkill{ 
	name = "LuaZhiqi", 
	frequency = sgs.Skill_NotFrequent, 
	events = {sgs.TargetConfirmed}, 
	on_trigger = function(self, event, player, data) 
		local use = data:toCardUse()
		local slash = use.card
		if slash and slash:isKindOf("Slash") then
			if use.to:contains(player) then
				local room = player:getRoom()
				if room:askForCard(player, "Weapon|.|.|.", "@LuaZhiqi", data, self:objectName()) then
					room:drawCards(player, 3, self:objectName())
				end
			end
		end
	end
}

--	分析：在这段代码中，askForCard部分是需要AI支持的：
room:askForCard(player, "Weapon|.|.|.", "@LuaZhiqi", data, self:objectName())

--	而获得AI支持的方法是：
sgs.ai_skill_cardask["@LuaZhiqi"] = function(self, data, pattern, target, target2)
end
--	这个方括号中的"@LuaZhiqi"是询问打出卡牌时的提示信息，对应的是askForCard中的prompt参数。
--	后面function(self, data, pattern, target, target2)中，data是通过askForCard中的同名参数传递过来的环境数据，
--	在本例中，它是on_trigger = function(self, event, player, data)中的第四个参数data，内含一个卡牌使用结构体。
--	参数pattern表示卡牌的样式，也是从askForCard中传递过来的。在本例中，它的值是"Weapon|.|.|."，
--	表示需要打出一张武器类型的卡牌。如果要求打出一张实际存在的卡牌，
--	那么这个参数pattern的格式是这样的："T|S|P|A"，其中：
--	T表示卡牌的类型，像本例中的Weapon就代表武器类的卡牌。不同类型之间用逗号“,”分隔。
--	S表示卡牌的花色，包括spade（黑桃）、heart（红心）、club（草花）和diamond（方块）。不同花色间也用逗号分隔。
--	P表示卡牌的点数，用1、2、……、10、11、12、13分别代表A、2、……、10、J、Q、K。如果涉及不止一种点数，
--	可以采用“,”或“~”分隔连接。这里，逗号“,”用于分隔不同的点数，比如
".|.|2,11|."
--	表示需要打出一张点数为2或J的卡牌，而波浪号“~”用于省略相邻的若干种点数，比如
".|.|5~10|."
--	则表示需要打出的卡牌，点数范围在5至10之间，也就是5、6、7、8、9、10点均可。
--	A表示卡牌的位置，目前已知的有两个取值：hand（手牌区）和equipped（装备区），而且这两类区域只能单独出现。
--	如果不关心T、S、P、A中的某些项目，那么可以用点号“.”表示忽略。
--	因此，像
"Slash|heart,diamond|2~9|hand"
--	这样的pattern值，就表示需要在手牌区范围内，打出一张点数在2～9之间的红色【杀】。
--	接下来的两个参数target和target2，跟只知道可能提示信息有关，不过一般来说似乎也不怎么常用。

--	当我们找到一张可以响应的卡牌时，就可以将它对应的卡牌构成字符串作为函数的最终结果了：
sgs.ai_skill_cardask["@LuaZhiqi"] = function(self, data, pattern, target, target2)
	local cards = self.player:getCards("he")
	for _,card in sgs.qlist(cards) do
		if card:isKindOf("Weapon") then
			return card:toString()
		end
	end
	return "."
end

--[[************************************************************************************************
	四、触发技实例分析（询问选择）
	目标：Room:askForChoice()
	方法：sgs.ai_skill_choice[skill_name](self, choices, data)
]]--************************************************************************************************

--	回选（技能）：回合开始前，你可以选择一项：1、流失一点体力；2、摸两张牌。
LuaHuixuan = sgs.CreateTriggerSkill{ 
	name = "LuaHuixuan", 
	frequency = sgs.Skill_NotFrequent, 
	events = {sgs.TurnStart}, 
	on_trigger = function(self, event, player, data) 
		local room = player:getRoom()
		local choice = room:askForChoice(player, self:objectName(), "lose+draw")
		if choice == "lose" then
			room:loseHp(player, 1)
		elseif choice == "draw" then
			room:drawCards(player, 2, self:objectName())
		end
	end
}

--	分析：这段代码中，出现了询问选择的部分askForChoice，即：
room:askForChoice(player, self:objectName(), "lose+draw")
--	由于self:objectName()在这里表示技能名"LuaHuixuan"，所以这句话等价于：
room:askForChoice(player, "LuaHuixuan", "lose+draw", data)

--	根据获得AI支持的方法，在AI文件中应该这样写：
sgs.ai_skill_choice["LuaHuixuan"] = function(self, choices, data)
end
--	方括号中的"LuaHuixuan"表示选择的原因，也就是askForChoice中提供的skill_name参数。
--	之后function(self, choices, data)中的参数也和askForChoice有密切的关系，比如
--	参数choices就是askForChoice中给出的选项，是由"+"分隔的一个字符串。在这个例子中，它的值是"lose+draw"。
--	参数data则是askForChoice中提供的那个data，表示可参考的环境数据。本例中，此参数被忽略，值就是sgs.QVariant()。

--	虽然choices中有备选的选项，不过通常我们是不依赖它的，只需要在合适的场景中给出我们设定的选择结果即可。比如：
sgs.ai_skill_choice["LuaHuixuan"] = function(self, choices, data)
	return "draw"
end

--	如果像上文这样，不论合适都产生固定的结果，那么可以直接写成：
sgs.ai_skill_choice["LuaHuixuan"] = "draw"
--	也就是把函数function(self, choices, data)简化成一个具体的选项。

--[[************************************************************************************************
	五、触发技实例分析（角色选择）
	目标：Room:askForPlayerChosen()
	方法：sgs.ai_skill_playerchosen[ string.gsub(reason,"%-","_") ](self, targets)
]]--************************************************************************************************

--	伤翻（技能）：当你造成一次伤害时，你可以指定一名角色翻面。
LuaShangfan = sgs.CreateTriggerSkill{ 
	name = "LuaShangfan", 
	frequency = sgs.Skill_Frequent, 
	events = {sgs.Damage}, 
	on_trigger = function(self, event, player, data) 
		local room = player:getRoom()
		if room:askForSkillInvoke(player, self:objectName(), data) then
			local alives = room:getAlivePlayers()
			local target = room:askForPlayerChosen(player, alives, self:objectName())
			if target then
				target:turnOver()
			end
		end
	end
}

--	分析：这个技能中涉及了两个需要AI支持的代码askForSkillInvoke和askForPlayerChosen，
--	而askForSkillInvoke获得支持的方法我们是知道的，那么现在再看看askForPlayerChosen。
room:askForPlayerChosen(player, alives, self:objectName())
--	由于self:objectName()在这里表示技能的名字"LuaShangfan"，所以这句话等价于：
room:askForPlayerChosen(player, alives, "LuaShangfan")

--	根据askForPlayerChosen获得AI支持的方法，在AI文件写成这个样子：
sgs.ai_skill_playerchosen["LuaShangfan"] = function(self, targets)
end
--	这里方括号中的"LuaShangfan"其实就是askForPlayerChosen中的reason参数，直接抄过来即可。
--	function(self, targets)中的参数targets表示待选目标角色列表，QList<ServerPlayer*>类型，
--	也是从askForPlayerChosen中原样传递过来的targets参数，在本例中，它的值是alives。

--	当我们找到了期望选择的目标，直接返回即可：
sgs.ai_skill_playerchosen["LuaShangfan"] = function(self, targets)
	for _,p in sgs.qlist(targets) do
		if p:faceUp() then
			if self:isEnemy(p) then
				return p
			end
		else
			if self:isFriend(p) then
				return p
			end
		end
	end
	return targets:first()
end
--	最后给出一个默认的结果targets:first()，表示没有期望目标时，随意地把备选目标中的第一个作为选择结果。

--[[************************************************************************************************
	六、触发技实例分析（卡牌选择）
	目标：Room:askForCardChosen()
	方法：sgs.ai_skill_cardchosen[ string.gsub(reason,"%-","_") ](self, who, flags)
]]--************************************************************************************************

--	闪获（技能）：当你的【杀】被闪避后，你可以获得目标角色的一张牌。
LuaShanhuo = sgs.CreateTriggerSkill{ 
	name = "LuaShanhuo", 
	frequency = sgs.Skill_Frequent, 
	events = {sgs.SlashMissed}, 
	on_trigger = function(self, event, player, data) 
		local effect = data:toSlashEffect()
		local target = effect.to
		if not target:isNude() then
			if effect.from:objectName() == player:objectName() then
				if player:askForSkillInvoke(self:objectName(), data) then
					local room = player:getRoom()
					local id = room:askForCardChosen(player, target, "he", self:objectName())
					room:obtainCard(player, id, true)
				end
			end
		end
	end
}

--	分析：显然，这段代码中，askForSkillInvoke和askForCardChosen部分都是需要AI支持的，
--	当然这里我们只看askForCardChosen：
room:askForCardChosen(player, target, "he", self:objectName())
--	考虑到self:objectName()的值是"LuaShanhuo"，于是它等价于：
room:askForCardChosen(player, target, "he", "LuaShanhuo")

--	根据askForCardChosen获得AI支持的方法，AI文件中应该写成这样：
sgs.ai_skill_cardchosen["LuaShanhuo"] = function(self, who, flags)
end
--	这里，方括号中的"LuaShanhuo"是选择卡牌的原因，就是askForCardChosen中的reason参数。
--	而function(self, who, flags)中，参数who表示被选择卡牌的目标角色，就是askForCardChosen中的who参数，
--	在这个例子中，它的值是target。
--	参数flags表示卡牌的选择范围，由"h"（手牌区）、"e"（装备区）、"j"（判定区）组合而成，
--	其实就是askForCardChosen中的flag参数。在本例中，它的值是"he"，表示手牌和装备区。

--	如果我们通过分析，找到了应当选择的那张卡牌，只需要将它的编号作为选择的结果即可：
sgs.ai_skill_cardchosen["LuaShanhuo"] = function(self, who, flags)
	local cards = who:getCards(flags)
	local length = cards:length()
	local index = math.random(0, length)
	local card = cards:at(index)
	return card:getId()
end
--	上面这段代码就是随机选择一张卡牌的过程了。

--	这个函数也可以退化成一个固定的数值，表示不论什么时候，选出的都是以这个数值为编号的卡牌：
sgs.ai_skill_cardchosen["LuaShanhuo"] = 100
--	不过这种写法似乎并不常用，毕竟目标角色不一定总是拥有这张特定的卡牌。

--	其实，除去一些刻意的要求，askForCardChosen函数并不太需要特别的AI支持，因为smart-ai.lua中已经替我们统一处理了。

--[[************************************************************************************************
	七、触发技实例分析（五谷丰登选牌）
	目标：Room:askForAG()
	方法：sgs.ai_skill_askforag[ string.gsub(reason, "%-", "_") ](self, card_ids)
]]--************************************************************************************************

--	变亮（技能）：每当你的体力变化时，你可以从牌堆顶亮出三张牌，获得其中的的任意一张。
LuaBianliang = sgs.CreateTriggerSkill{ 
	name = "LuaBianliang", 
	frequency = sgs.Skill_Frequent, 
	events = {sgs.HpChanged}, 
	on_trigger = function(self, event, player, data) 
		if player:askForSkillInvoke(self:objectName()) then
			local room = player:getRoom()
			local card_ids = room:getNCards(3)
			room:fillAG(card_ids)
			local id = room:askForAG(player, card_ids, false, self:objectName())
			room:takeAG(player, card_id)
			room:broadcastInvoke("clearAG")
		end
	end
}

--	分析：这个技能依然有两个需要AI支持的部分——askForSkillInvoke和askForAG，而目前我们更关心的是后者：
room:askForAG(player, card_ids, false, self:objectName())
--	它等价于：
room:askForAG(player, card_ids, false, "LuaBianliang")
--	只是因为self:objectName()的值此时是"LuaBianliang"

--	获得AI支持的写法是：
sgs.ai_skill_askforag["LuaBianliang"] = function(self, card_ids)
end
--	方框中的"LuaBianliang"表示选牌的原因，对应的是askForAG中的reason参数。
--	接下来，function(self, card_ids)中的参数card_ids表示五谷丰登界面中所有展示的卡牌的编号表，table类型。
--	它对应的是askForAG中QList<int>类型的参数card_ids。

--	当我们找到了要选择的卡牌时，只需要将它的编号作为选牌结果即可：
sgs.ai_skill_askforag["LuaBianliang"] = function(self, card_ids)
	self:sortByUseValue(card_ids)
	return card_ids[1]
end
--	上述代码表示，将最有使用价值的卡牌的编号作为选择的结果。

--	其实，smart-ai.lua也已经为我们处理了这个场景，所以除去一些刻意的要求，askForAG函数是并不太需要特别的AI支持的。

--[[************************************************************************************************
	八、触发技实例分析（卡牌展示）
	目标：Room:askForCardShow()
	方法：sgs.ai_cardshow[reason](self, requestor)
]]--************************************************************************************************

--	展流（技能）：回合结束阶段开始时，你可以令其他所有有手牌的角色各展示一张卡牌，若其不为红心牌，该角色流失一点体力。
LuaZhanliu = sgs.CreateTriggerSkill{ 
	name = "LuaZhanliu", 
	frequency = sgs.Skill_Frequent, 
	events = {sgs.EventPhaseStart}, 
	on_trigger = function(self, event, player, data) 
		if player:getPhase() == sgs.Player_Finish then
			if player:askForSkillInvoke(self:objectName(), data) then
				local room = player:getRoom()
				local others = room:getOtherPlayers(player)
				for _,p in sgs.qlist(others) do
					if not p:isKongcheng() then
						local card = room:askForCardShow(p, player, self:objectName())
						if not card or card:getSuit() ~= sgs.Card_Heart then
							room:loseHp(p, 1)
						end
					end
				end
			end
		end
	end
}

--	分析：需要AI支持的地方依然是两个，askForSkillInvoke和askForCardShow。而后者是我们更关注的：
room:askForCardShow(p, player, self:objectName())
--	也就是：
room:askForCardShow(p, player, "LuaZhanliu")
--	因为self:objectName()的值是"LuaZhanliu"。

--	AI文件方面，为了获得AI支持，应该写成：
sgs.ai_cardshow["LuaZhanliu"] = function(self, requestor)
end
--	这里，方框中的"LuaZhanliu"表示展示卡牌的原因，它和askForCardShow的reason参数是相同的。
--	function(self, requestor)中，参数requestor表示要求展示卡牌的源角色，具体到本例中，它的值是player。

--	如果我们找到了一张可以展示的卡牌，那么直接将这张卡牌作为最终的结果即可，比如下面的代码：
sgs.ai_cardshow["LuaZhanliu"] = function(self, requestor)
	local cards = self.player:getCards("h")
	for _,card in sgs.qlist(cards) do
		if card:getSuit() == sgs.Card_Heart then
			return card
		end
	end
	return cards:first()
end
--	就可以实现优先展示红心牌的效果了。

--[[************************************************************************************************
	九、触发技实例分析（询问花色）
	目标：Room:askForSuit()
	方法：sgs.ai_skill_suit[reason](self)
]]--************************************************************************************************

--	判猜（技能）：在你的判定开始时，你可以猜判定牌的花色，如果猜对，判定结束后你摸一张牌。
LuaPancai = sgs.CreateTriggerSkill{ 
	name = "LuaPancai", 
	frequency = sgs.Skill_Frequent, 
	events = {sgs.StartJudge, sgs.FinishJudge}, 
	on_trigger = function(self, event, player, data) 
		local room = player:getRoom()
		local judge = data:toJudge()
		if judge.who:objectName() == player:objectName() then
			if event == sgs.StartJudge then
				if player:askForSkillInvoke(self:objectName(), data) then
					local suit = room:askForSuit(player, self:objectName())
					local value = sgs.Card_Suit2String(suit)
					room:setTag("PancaiSuit", sgs.QVariant(value))
				end
			elseif event == sgs.FinishJudge then
				local suit = judge.card:getSuitString()
				local tag = room:getTag("PancaiSuit")
				if tag then
					if tag:toString() == suit then
						room:drawCards(player, 1, self:objectName())
					end
					room:removeTag("PancaiSuit")
				end
			end
		end
	end
}

--	分析：这里需要AI支持的地方是askForSkillInvoke和askForSuit，当然我们这次只关心askForSuit了。
room:askForSuit(player, self:objectName())
--	由于self:objectName()表示"LuaPancai"，所以这条代码等价于：
room:askForSuit(player, "LuaPancai")

--	对应的AI文件中，具体的写法是：
sgs.ai_skill_suit["LuaPancai"] = function(self)
end
--	方框内的"LuaPancai"，就是询问花色的原因了，来自askForSuit中的参数reason。

--	当我们分析出要选的花色时，需要按照下面的对应方式设定最后的结果：
--	黑桃（sgs.Card_Spade）：0
--	红心（sgs.Card_Heart）：1
--	草花（sgs.Card_Club）：2
--	方块（sgs.Card_Diamond）：3
--	比如：
sgs.ai_skill_suit["LuaPancai"] = function(self)
	return math.random(0, 3)
end
--	这就表示，遇到"LuaPancai"询问花色选择时，随机选择一个花色作为结果。

--[[************************************************************************************************
	十、触发技实例分析（询问遗计）
	目标：Room:askForYiji()
	方法：sgs.ai_skill_askforyiji[ string.gsub(reason,"%-","_") ](self, card_ids)
]]--************************************************************************************************

--	这部分内容有待完善。
--	一般来说，用smart-ai.lua中提供的决策已经足够，不需要额外写针对遗计的内容了。

--[[************************************************************************************************
	十一、触发技实例分析（询问拼点）
	目标：Room:askForPindian()
	方法：sgs.ai_skill_pindian[reason](minusecard, self, requestor, maxcard, mincard)
]]--************************************************************************************************

--	这部分内容有待完善。
--	一般来说，用smart-ai.lua中提供的决策已经足够，不需要额外写针对拼点的内容了。

--[[************************************************************************************************
	十二、触发技实例分析（询问弃牌）
	目标：Room:askForDiscard()
	方法：sgs.ai_skill_discard[reason](self, discard_num, min_num, optional, include_equip)
]]--************************************************************************************************

--	这部分内容有待完善。
--	一般来说，用smart-ai.lua中提供的决策已经足够，不需要额外写针对弃牌的内容了。

--[[************************************************************************************************
	十三、视为技实例分析（卡牌使用）
	方法：SKILL.getTurnUseCard = function(self, inclusive)
]]--************************************************************************************************

--	草决（技能）：出牌阶段，你可以将一张草花牌当作【决斗】使用。
LuaCaojue = sgs.CreateViewAsSkill{ 
	name = "LuaCaojue", 
	n = 1, 
	view_filter = function(self, selected, to_select) 
		return to_select:getSuit() == sgs.Card_Club
	end, 
	view_as = function(self, cards) 
		if #cards == 1 then
			local card = cards[1]
			local suit = card:getSuit()
			local point = card:getNumber()
			local duel = sgs.Sanguosha:cloneCard("duel", suit, point)
			duel:addSubcard(card)
			duel:setSkillName(self:objectName())
			return duel
		end
	end
}

--	分析：视为技AI设计有着较为固定的流程，首先是创建信息表对象，然后指明信息表的名字，
--	再将其插入到sgs.ai_skills中，最后就是通过getTurnUseCard考虑技能的发动了。
--	这个技能的名字是"LuaCaojue"，所以我们可以将信息表的创建过程写成这样：
local LuaCaojue_skill = {}
--	然后指明信息表的名字：
LuaCaojue_skill.name = "LuaCaojue"
--	接下来将信息表插入到sgs.ai_skills中：
table.insert(sgs.ai_skills, LuaCaojue_skill)
--	最后给出关键的getTurnUseCard函数：
LuaCaojue_skill.getTurnUseCard = function(self, inclusive)
end
--	在getTurnUseCard函数中，我们的任务是用sgs.Card_Parse(str)产生一张虚拟的卡牌（决斗），
--	而参数str的格式是"N:K[S:P]=C"，所以先要找出用于发动技能的草花牌：
LuaCaojue_skill.getTurnUseCard = function(self, inclusive)
	local club = nil
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	for _,card in ipairs(cards) do
		if card:getSuit() == sgs.Card_Club then
			club = card
			break
		end
	end
end
--	这样如果不出意外的话，变量club中就是找到的草花牌了。在str格式中的各个成份，也就顺理成章地浮出了水面：
--	N：视为卡牌的对象名，本例中这个名字是"duel"（决斗）。
--	K：视为技名字，本例中，这个名字是"LuaCaojue"。
--	S：视为卡牌的花色字符串，本例中可以用club:getSuitString()得到，当然也可以直接写"club"，因为这个已经很明确了。
--	P：视为卡牌的点数字符串，本例中可以用club:getNumberString()得到。
--	C：卡牌的具体构成，本例中，这张决斗只是由一张卡牌club构成的，所以这部分内容应该是club:getId()
--	所以最终getTurnUseCard的内容应该是：
LuaCaojue_skill.getTurnUseCard = function(self, inclusive)
	local club = nil
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	for _,card in ipairs(cards) do
		if card:getSuit() == sgs.Card_Club then
			club = card
			break
		end
	end
	if club then
		local suit = club:getSuitString()
		local point = club:getNumberString()
		local id = club:getId()
		local str = string.format("duel:LuaCaojue[%s:%s]=%d", suit, point, id)
		return sgs.Card_Parse(str)
	end
end
--	这个技能的AI部分就设计完成了。

--[[************************************************************************************************
	十四、视为技实例分析（卡牌响应）
	方法：sgs.ai_view_as[] = function(card, player, card_place, class_name)
]]--************************************************************************************************

--	锦闪（技能）：你可以将一张锦囊牌当作【闪】使用或打出。
LuaJinshan = sgs.CreateViewAsSkill{ 
	name = "LuaJinshan", 
	n = 1, 
	view_filter = function(self, selected, to_select) 
		return to_select:isKindOf("TrickCard")
	end, 
	view_as = function(self, cards) 
		if #cards == 1 then
			local card = cards[1]
			local suit = card:getSuit()
			local point = card:getNumber()
			local jink = sgs.Sanguosha:cloneCard("jink", suit, point)
			jink:addSubcard(card)
			jink:setSkillName(self:objectName())
			return jink
		end
	end, 
	enabled_at_play = function(self, player) 
		return false
	end, 
	enabled_at_response = function(self, player, pattern) 
		return pattern == "jink"
	end
}

--	分析：这是一个不能主动使用的视为技，名字是"LuaJinshan"，而AI系统要做的事情也很简单，
--	判断一下哪些卡牌可以用于发动这个技能以进行响应就可以了。
--	根据AI系统提供的方法，在AI文件中应该这样写：
sgs.ai_view_as["LuaJinshan"] = function(card, player, card_place, class_name)
end
--	函数function(card, player, card_place, class_name)用来判断卡牌是否可用并给出具体的构成方式。
--	其中的参数card就是当前被判断的卡牌，在本例中，如果这个card是锦囊牌，那么就可以用于发动技能。代码如下：
sgs.ai_view_as["LuaJinshan"] = function(card, player, card_place, class_name)
	if card:isKindOf("TrickCard") then
	end
end
--	而卡牌的构成方式与主动使用时的类似，都是"N:K[S:P]=C"，所以按照之前的思路，可以写成这样：
sgs.ai_view_as["LuaJinshan"] = function(card, player, card_place, class_name)
	if card:isKindOf("TrickCard") then
		local suit = card:getSuitString()
		local point = card:getNumberString()
		local id = card:getId()
		return string.format("jink:LuaJinshan[%s:%s]=%d", suit, point, id)
	end
end
--	至此，这个技能的AI设计就完成了。

--	如果是像龙胆那样，既有主动使用部分，又有响应部分的视为技，
--	那么在AI设计时，也要分别对这两个部分进行设计，不要遗漏才是。

--[[************************************************************************************************
	十五、视为技实例分析（锁定视为技）
	方法：sgs.ai_filterskill_filter[askill](card, card_place, player)
]]--************************************************************************************************

--	黑拆（技能）：锁定技，你的黑桃牌均视为【过河拆桥】。
LuaHeichai = sgs.CreateFilterSkill{ 
	name = "LuaHeichai", 
	view_filter = function(self, to_select) 
		return to_select:getSuit() == sgs.Card_Spade
	end, 
	view_as = function(self, card) 
		local suit = card:getSuit()
		local point = card:getNumber()
		local dismantlement = sgs.Sanguosha:cloneCard("dismantlement", suit, point)
		dismantlement:setSkillName(self:objectName())
		local id = card:getId()
		local vs_card = sgs.Sanguosha:getWrappedCard(id)
		vs_card:takeOver(dismantlement)
		return vs_card
	end 
}

--	分析：首先，这是一个可以主动使用的视为技，所以为了能让电脑玩家使用，需要按照一般视为技的情形，写出如下代码：
local LuaHeichai_skill = {}
LuaHeichai_skill.name = "LuaHeichai"
table.insert(sgs.ai_skills, LuaHeichai_skill)
LuaHeichai_skill.getTurnUseCard = function(self, inclusive)
	local spade = nil
	local cards = self.player:getCards("he")
	for _,card in sgs.qlist(cards) do
		if card:getSuit() == sgs.Card_Spade then
			spade = card
			break
		end
	end
	if spade then
		local suit = spade:getSuitString()
		local point = spade:getNumberString()
		local id = spade:getId()
		local str = string.format("dismantlement:LuaHeichai[%s:%s]=%d", suit, point, id)
		return sgs.Card_Parse(str)
	end
end
--	接下来就是作为锁定视为技，自身需要添加的内容了。

--	为了判断哪些卡牌会受到技能的影响而改变，代码方面是这样的：
sgs.ai_filterskill_filter["LuaHeichai"] = function(card, card_place, player)
end
--	这里，card就是待判断的卡牌了，如果它是黑桃牌，那么我们就需要给出锁定视为的具体方式：
sgs.ai_filterskill_filter["LuaHeichai"] = function(card, card_place, player)
	if card:getSuit() == sgs.Card_Heart then
		local suit = spade:getSuitString()
		local point = spade:getNumberString()
		local id = spade:getId()
		return string.format("dismantlement:LuaHeichai[%s:%s]=%d", suit, point, id)
	end
end
--	就是这样。

--[[************************************************************************************************
	十六、视为技实例分析（技能卡）
	方法：sgs.ai_skill_use_func[] = function(card, use, self)
]]--************************************************************************************************

--	令摸（技能）：出牌阶段，你可以令一名角色摸两张牌，每阶段限一次。
LuaLingmoCard = sgs.CreateSkillCard{ 
	name = "LuaLingmoCard", 
	target_fixed = false, 
	will_throw = true, 
	filter = function(self, targets, to_select) 
		return #targets == 0
	end,
	on_use = function(self, room, source, targets) 
		room:drawCards(targets[1], 2, self:objectName())
	end
}
LuaLingmo = sgs.CreateViewAsSkill{ 
	name = "LuaLingmo", 
	n = 0, 
	view_as = function(self, cards) 
		return LuaLingmoCard:clone()
	end, 
	enabled_at_play = function(self, player) 
		return not player:hasUsed("#LuaLingmoCard")
	end
}

--	分析：为了能让电脑玩家主动使用这个视为技，依然要对信息表和getTurnUseCard函数进行相应的处理：
local LuaLingmo_skill = {}
LuaLingmo_skill.name = "LuaLingmo"
table.insert(sgs.ai_skills, LuaLingmo_skill)
LuaLingmo_skill.getTurnUseCard = function(self, inclusive)
end
--	在这个getTurnUseCard函数中让AI系统考虑使用这张技能卡（LuaLingmoCard），当然了，首先要满足技能发动的条件。

--	在视为技中，发动条件是由enabled_at_play部分约定的。这个例子中，条件是没有使用过此技能卡：
not player:hasUsed("#LuaLingmoCard")
--	而满足这个条件后，就可以让AI系统考虑一下使用这张技能卡的可能了。
LuaLingmo_skill.getTurnUseCard = function(self, inclusive)
	if not self.player:hasUsed("#LuaLingmoCard") then
	end
end
--	而只要getTurnUseCard函数产生一个Card类型的结果，AI系统就认为可以使用这张技能卡了。

--	由于这个函数中只关心使用的可能，而对技能卡的具体使用方式没有要求，
--	所以一般我们可以将此时产生的虚拟卡牌简单地写成：
sgs.Card_Parse("#LuaLingmoCard:.:")
--	也就是产生这样的代码：
LuaLingmo_skill.getTurnUseCard = function(self, inclusive)
	if not self.player:hasUsed("#LuaLingmoCard") then
		return sgs.Card_Parse("#LuaLingmoCard:.:")
	end
end
--	这样，getTurnUseCard部分就写好了。

--	现在，只要电脑玩家没有使用过此技能卡，那么它就会考虑使用这个技能卡了。
--	但是，也仅仅是考虑使用而已，距离真正在游戏中使用还有一段距离。
--	这就是技能卡的具体的使用方式了。只有当AI系统明确了技能卡的使用方式，电脑玩家才会真正地使用这张技能卡发动技能。
--	而技能卡的使用方式是由函数function(card, use, self)给出，记录在表sgs.ai_skill_use_func中。
--	再次注意一下技能卡的名字："LuaLingmoCard"，对于Lua技能卡，引用名字时还要在前面加上一个"#"号，也就是：
"#LuaLingmoCard"
--	所以接下来需要在AI文件中写的内容就是：
sgs.ai_skill_use_func["#LuaLingmoCard"] = function(card, use, self)
end
--	这个函数中，我们要做的就是将具体的使用方式填充到use参数中去。

--	参数use是一个卡牌使用结构体（sgs.CardUseStruct），主要需要两个参数：use.card（使用的卡牌）和use.to（卡牌使用目标）
--	使用的卡牌自然就是这张技能卡了，不过现在function(card, use, self)中提供的技能卡参数card，
--	里面的内容是我们从getTurnUseCard中简单设定的：
sgs.Card_Parse("#LuaLingmoCard:.:")
--	从它的构成方式
"#LuaLingmoCard:.:"
--	（没有子卡，没有使用目标）可以看出，这个card并不是我们需要的，
--	而我们需要的技能卡是有使用目标的，当然这个使用目标也是use.to所期望的。
--	所以先找到一个合适的使用目标：
sgs.ai_skill_use_func["#LuaLingmoCard"] = function(card, use, self)
	local target = nil
	self:sort(self.friends, "defense")
	target = self.friends[1]
	if target then
	end
end
--	在这里，变量target就是我们找到的技能卡的使用目标了，于是我们可以由此产生一张真正可以使用的技能卡：
sgs.ai_skill_use_func["#LuaLingmoCard"] = function(card, use, self)
	local target = nil
	self:sort(self.friends, "defense")
	target = self.friends[1]
	if target then
		local card_str = "#LuaLingmoCard:.:->"..target:objectName()
		local acard = sgs.Card_Parse(card_str)
		assert(acard)
	end
end
--	产生技能卡的方法，还是sgs.Card_Parse()。这样，变量acard就是我们要电脑玩家使用的技能卡了。

--	接下来就可以填充卡牌使用结构体use参数了，方法是：
sgs.ai_skill_use_func["#LuaLingmoCard"] = function(card, use, self)
	local target = nil
	self:sort(self.friends, "defense")
	target = self.friends[1]
	if target then
		local card_str = "#LuaLingmoCard:.:->"..target:objectName()
		local acard = sgs.Card_Parse(card_str)
		assert(acard)
		use.card = acard
		if use.to then
			use.to:append(target)
		end
	end
end
--	至此，电脑玩家就可以正确使用技能卡发动技能了。

--	至于为什么在添加卡牌使用目标时，先要判断use.to是否存在，那涉及到了更多AI系统处理机制的问题，
--	简单地说就是，这个表sgs.ai_skill_use_func在AI系统的其他部分也会用到，
--	而use.to只是在具体使用技能卡的这部分内容中存在，为了区别和避免出错，才要有如此写法。

--[[************************************************************************************************
	十七、技能实例综合分析
]]--************************************************************************************************

--	每令（技能）：每当你受到一次伤害，你可以弃一张手牌，令一名角色选择一项：摸两张牌，或者回复一点体力。
LuaMeilingCard = sgs.CreateSkillCard{ 
	name = "LuaMeilingCard", 
	target_fixed = false, 
	will_throw = true, 
	filter = function(self, targets, to_select) 
		return #targets == 0
	end,
	on_use = function(self, room, source, targets) 
		local target = targets[1]
		local choice = room:askForChoice(target, self:objectName(), "draw+recover")
		if choice == "draw" then
			room:drawCards(target, 2, self:objectName())
		elseif choice == "recover" then
			local recover = sgs.RecoverStruct()
			recover.who = source
			recover.recover = 1
			room:recover(target, recover)
		end
	end
}
LuaMeilingVS = sgs.CreateViewAsSkill{ 
	name = "LuaMeiling", 
	n = 1, 
	view_filter = function(self, selected, to_select) 
		return not to_select:isEquipped()
	end, 
	view_as = function(self, cards) 
		if #cards == 1 then
			local card = LuaMeilingCard:clone()
			card:addSubcard(cards[1])
			return card
		end
	end, 
	enabled_at_play = function(self, player) 
		return false
	end, 
	enabled_at_response = function(self, player, pattern) 
		return pattern == "@@LuaMeiling"
	end
}
LuaMeiling = sgs.CreateTriggerSkill{ 
	name = "LuaMeiling", 
	frequency = sgs.Skill_NotFrequent, 
	events = {sgs.Damaged}, 
	view_as_skill = LuaMeilingVS, 
	on_trigger = function(self, event, player, data) 
		local damage = data:toDamage()
		if damage.to:objectName() == player:objectName() then
			if not player:isKongcheng() then
				local room = player:getRoom()
				room:askForUseCard(player, "@@LuaMeiling", "@LuaMeiling")
			end
		end
	end
}

--	分析：在这个技能中，触发技LuaMeiling是技能主体，从它可以引出视为技LuaMeilingVS以使用技能卡LuaMeilingCard。
--	所以先看这触发技部分：
--	触发技LuaMeiling只有一处需要AI支持：
room:askForUseCard(player, "@@LuaMeiling", "@LuaMeiling")
--	这是一个以"@@LuaMeiling"为pattern，以"@LuaMeiling"为prompt的卡牌使用请求，所以对应的AI部分写法是：
sgs.ai_skill_use["@@LuaMeiling"] = function(self, prompt, method)
end
--	在这个function(self, prompt, method)函数中，我们要提供string类型的卡牌使用方式。
--	而技能卡的这个使用方式是"#N:C:->U"格式的，显然N的内容就是技能卡的名字"LuaMeilingCard"了，
--	所以只需要分别确定C、U的内容即可：
sgs.ai_skill_use["@@LuaMeiling"] = function(self, prompt, method)
	local handcards = self.player:getCards("h")
	handcards = sgs.QList2Table(handcards)
	self:sortByKeepValue(handcards)
	local card = handcards[1] 
	self:sort(self.friends, "defense")
	local target = self.friends[1]
	local card_str = string.format("#LuaMeilingCard:%d:->%s", card:getId(), target:objectName())
	return card_str
end
--	这样电脑玩家就会在遇到askForUseCard时，使用技能卡LuaMeilingCard了。

--	然后看视为技部分：
--	由于enabled_at_player约定了发动的条件始终为false，所以这个视为技是不能主动发动的，
--	而enabled_at_response部分，其实已经暗含在触发技中了，所以这个视为技就不需要AI支持了。

--	真正需要AI支持的内容在技能卡部分：
room:askForChoice(target, self:objectName(), "draw+recover")
--	注意到此时self表示这张技能卡，所以self:objectName()的值是"LuaMeilingCard"而不是"LuaMeiling"或"LuaMeilingVS"
--	这样这句代码就等价于：
room:askForChoice(target, "LuaMeilingCard", "draw+recover")
--	在AI文件中，对应的内容应该是：
sgs.ai_skill_choice["LuaMeilingCard"] = function(self, choices, data)
end
--	根据当前手牌数目和体力值的情况，分析出应当选择哪一个选项：
sgs.ai_skill_choice["LuaMeilingCard"] = function(self, choices, data)
	if self.player:isWounded() then
		local hp = self.player:getHp()
		local count = self.player:getHandcardNum()
		if hp >= count + 2 then
			return "draw"
		else
			return "recover"
		end
	end
	return "draw"
end
--	就可以了。

--	至此，这个技能在AI方面就完整了，最后的代码是：
sgs.ai_skill_use["@@LuaMeiling"] = function(self, prompt, method)
	local handcards = self.player:getCards("h")
	handcards = sgs.QList2Table(handcards)
	self:sortByKeepValue(handcards)
	local card = handcards[1] 
	self:sort(self.friends, "defense")
	local target = self.friends[1]
	local card_str = string.format("#LuaMeilingCard:%d:->%s", card:getId(), target:objectName())
	return card_str
end
sgs.ai_skill_choice["LuaMeilingCard"] = function(self, choices, data)
	if self.player:isWounded() then
		local hp = self.player:getHp()
		local count = self.player:getHandcardNum()
		if hp >= count + 2 then
			return "draw"
		else
			return "recover"
		end
	end
	return "draw"
end
--	任务完成。