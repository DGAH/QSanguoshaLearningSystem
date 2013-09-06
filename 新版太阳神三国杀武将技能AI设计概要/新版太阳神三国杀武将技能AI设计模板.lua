--********************************--
--**************使用**************--
--********************************--
--[[
	所属类型：视为技
]]--
local _skill = {}
_skill.name = ""
table.insert(sgs.ai_skills, _skill)
_skill.getTurnUseCard = function(self, inclusive)
	
end
--[[
	所属类型：视为卡牌
]]--
sgs.ai_view_as[""] = function(card, player, card_place, class_name)
	
end
--[[
	所属类型：使用技能卡
]]--
sgs.ai_skill_use_func[""] = function(card, use, self)
	
end
--[[
	所属类型：锁定视为技
	接口设计：sgs.ai_filterskill_filter[askill](card, card_place, player)
]]--
sgs.ai_filterskill_filter[""] = function(card, card_place, player)
	
end
--********************************--
--**************响应**************--
--********************************--
--[[
	所属类型：响应花色询问
	对应代码：Room:askForSuit()
	处理函数：SmartAI:askForSuit(reason)
	接口设计：sgs.ai_skill_suit[reason](self)
]]--
sgs.ai_skill_suit[""] = function(self)
	
end
--[[
	所属类型：响应势力询问
	对应代码：Room:askForKingdom()
	处理函数：无
	接口设计：无
]]--
--[[
	所属类型：响应技能发动询问
	对应代码：Room:askForSkillInvoke()、ServerPlayer:askForSkillInvoke()
	处理函数：SmartAI:askForSkillInvoke(skill_name, data)
	接口设计：sgs.ai_skill_invoke[skill_name](self, data)
]]--
sgs.ai_skill_invoke[""] = function(self, data)
	
end
--[[
	所属类型：响应选择询问
	对应代码：Room:askForChoice()
	处理函数：SmartAI:askForChoice(skill_name, choices, data)
	接口设计：sgs.ai_skill_choice[skill_name](self, choices, data)
]]--
sgs.ai_skill_choice[""] = function(self, choices, data)
	
end
--[[
	所属类型：响应弃牌询问
	对应代码：Room:askForDiscard()
	处理函数：SmartAI:askForDiscard(reason, discard_num, min_num, optional, include_equip)
	接口设计：sgs.ai_skill_discard[reason](self, discard_num, min_num, optional, include_equip)
]]--
sgs.ai_skill_discard[""] = function(self, discard_num, min_num, optional, include_equip)
	
end
--[[
	所属类型：响应卡牌交换询问
	对应代码：Room:askForExchange()
	处理函数：无
	接口设计：无
]]--
--[[
	所属类型：响应无懈可击询问
	对应代码：Room:askForNullification()
	处理函数；SmartAI:askForNullification(trick, from, to, positive)
	接口设计：无
]]--
--[[
	所属类型：响应卡牌选择询问
	对应代码：Room:askForCardChosen()
	处理函数：SmartAI:askForCardChosen(who, flags, reason)
	接口设计：sgs.ai_skill_cardchosen[string.gsub(reason,"%-","_")](self, who, flags)
]]--
sgs.ai_skill_cardchosen[""] = function(self, who, flags)
	
end
--[[
	所属类型：响应卡牌打出询问
	对应代码：Room:askForCard()
	处理函数：SmartAI:askForCard(pattern, prompt, data)
	接口设计：sgs.ai_skill_cardask[ prompt:split(":")[1] ](self, data, pattern, target, target2)
]]--
sgs.ai_skill_cardask[""] = function(self, data, pattern, target, target2)
	
end
--[[
	所属类型：响应卡牌使用询问
	对应代码：Room:askForUseCard()
	处理函数：SmartAI:askForUseCard(pattern, prompt, method)
	接口设计：sgs.ai_skill_use[pattern](self, prompt, method)
]]--
sgs.ai_skill_use[""] = function(self, prompt)
	
end
--[[
	所属类型：响应使用杀询问
	对应代码：Room:askForUseSlashTo()
	处理函数：无
	接口设计：无
]]--
--[[
	所属类型：响应五谷丰登界面选牌询问
	对应代码：Room:askForAG()
	处理函数：SmartAI:askForAG(card_ids, refusable, reason)
	接口设计：sgs.ai_skill_askforag[string.gsub(reason, "%-", "_")](self, card_ids)
]]--
sgs.ai_skill_askforag[""] = function(self, card_ids)
	
end
--[[
	所属类型：响应卡牌展示询问
	对应代码：Room:askForCardShow()
	处理函数：SmartAI:askForCardShow(requestor, reason)
	接口设计：sgs.ai_cardshow[reason](self, requestor)
]]--
sgs.ai_cardshow[""] = function(self, requestor)
	
end
--[[
	所属类型：响应遗计询问
	对应代码：Room:askForYiji()
	处理函数：SmartAI:askForYiji(card_ids, reason)
	接口设计：sgs.ai_skill_askforyiji[string.gsub(reason,"%-","_")](self, card_ids)
]]--
sgs.ai_skill_askforyiji[""] = function(self, card_ids)
	
end
--[[
	所属类型：响应拼点询问
	对应代码：Room:askForPindian()
	处理函数：SmartAI:askForPindian(requestor, reason)
	接口设计：sgs.ai_skill_pindian[reason](minusecard, self, requestor, maxcard, mincard)
]]--
sgs.ai_skill_pindian[""] = function(minusecard, self, requestor, maxcard, mincard)
	
end
--[[
	所属类型：响应玩家选择询问
	对应代码：Room:askForPlayerChosen()
	处理函数：SmartAI:askForPlayerChosen(targets, reason)
	接口设计：sgs.ai_skill_playerchosen[string.gsub(reason,"%-","_")](self, targets)
]]--
sgs.ai_skill_playerchosen[""] = function(self, targets)
	
end
--[[
	所属类型：响应武将询问
	对应代码：Room:askForGeneral()
	处理函数：无
	接口设计：无
]]--
--[[
	所属类型：响应求桃
	对应代码：Room:askForSinglePeach()
	处理函数：SmartAI:askForSinglePeach(dying)
	接口设计：无
]]--
--[[
	所属类型：响应？
	对应代码：Room:askForOrder()
	处理函数：无
	接口设计：无
]]--
--[[
	所属类型：响应？
	对应代码：Room:askForRole()
	处理函数：无
	接口设计：无
]]--
--********************************--
--**************特征**************--
--********************************--
--[[
	所属类型：卡牌使用仇恨值
]]--
sgs.ai_card_intention[""] = 
--[[
	所属类型：目标选择仇恨值
]]--
sgs.ai_playerchosen_intention[""] = 
--[[
	所属类型：卡牌选择仇恨值
]]--
sgs.ai_cardChosen_intention[""] = 
--[[
	所属类型：卡牌使用价值
]]--
sgs.ai_use_value[""] = 
--[[
	所属类型：卡牌使用优先级
]]--
sgs.ai_use_priority[""] = 
--[[
	所属类型：武将嘲讽值
]]--
sgs.ai_chaofeng[""] = 
--[[
	所属类型：技能相合花色
]]--
sgs._suit_value = {
	spade = ,
	heart = ,
	club = ,
	diamond = ,
}
--[[
	所属类型：技能相合卡牌
]]--
sgs._keep_value = {
	
}