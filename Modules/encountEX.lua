local Module = ModuleBase:createModule('encountEX')

local 不消耗诱魔水 = true--消耗道具开关
local 不消耗驱魔水 = true--消耗道具开关
local ymxs = 900498--诱魔香水
local qmxs = 900497--驱魔香水

function Module:onLoad()
	self:logInfo('load')
	self:regCallback('LoopEvent', Func.bind(self.ymloop,self))
	self:regCallback('ymloop',function(player)
	local playeryd = Char.GetData(player,%对象_战斗中%) == 0
	local ymxsnum = Char.ItemNum(player,ymxs)
	local ymbs = Char.GetData(player,%对象_香步数%)
	if playeryd then
		if 不消耗诱魔水 then
			Battle.Encount(player, player);
		else
			if ymbs > 979 then--修改诱魔水持续步数
				Char.SetData(player,%对象_香步数%,ymbs-1);
				NLG.UpChar(player);
				Battle.Encount(player, player);
				NLG.SystemMessage(player,'自动遇敌剩余'..(ymbs-980)..'步')
			else
				if ymxsnum > 1 then
					Char.SetData(player,%对象_香步数%,998);
					Char.DelItem(player,ymxs,1);
					Item.UpItem(player,-1);
					NLG.UpChar(player);
					NLG.SystemMessage(player,'消耗一个怪物饼干，自动遇敌继续，还有'..(ymxsnum-1)..'个怪物饼干。');
					Battle.Encount(player, player);
				elseif ymxsnum == 1 then
					Char.SetData(player,%对象_香步数%,998);
					Char.DelItem(player,ymxs,1);
					Item.UpItem(player,-1);
					NLG.UpChar(player);
					NLG.SystemMessage(player,'自动遇敌最后一次生效,请及时补充怪物饼干！');
					Battle.Encount(player, player);
				else
					Char.SetData(player,%对象_香步数%,0);
					Char.SetData(player,%对象_香上限%,0);
					Char.SetLoopEvent(nil,'ymloop',player,0);
					NLG.SystemMessage(player,'怪物饼干消耗殆尽，自动遇敌关闭！')
				end
			end
		end
	end
	end)
	self:regCallback('LoopEvent', Func.bind(self.qmloop,self))
	self:regCallback('qmloop', function(player)
	local qmxsnum = Char.ItemNum(player,qmxs)
	if qmxsnum > 1 then
		Char.DelItem(player,qmxs,1);
		Item.UpItem(player, -1);
		NLG.SystemMessage(player,'消耗一瓶大蒜油，不遇敌继续，还有'..(qmxsnum-1)..'瓶大蒜油。');
	elseif qmxsnum == 1 then
		Char.DelItem(player,qmxs,1);
		Item.UpItem(player,-1);
		NLG.SystemMessage(player,'不遇敌最后一次生效,请及时补充大蒜油！');
	else
		Char.SetData(player,%对象_不遇敌开关%,0);
		Char.SetLoopEvent(nil,'qmloop',player,0);
		NLG.UpChar(player);
		NLG.SystemMessage(player,'大蒜油消耗殆尽，不遇敌关闭！')
	end
	end)
	self:regCallback('TalkEvent', function(player, msg)
	local ymxsnum = Char.ItemNum(player,ymxs)
	local qmxsnum = Char.ItemNum(player,qmxs)
	if (msg == "/1" or msg == "、1") then
		if Char.GetData(player,%对象_不遇敌开关%) == 1 then
			NLG.SystemMessage(player,"你正在使用大蒜油，无法使用自动遇敌");
		elseif Char.GetData(player,%对象_香步数%) > 0 then
			Char.SetData(player,%对象_香步数%,0);
			Char.SetData(player,%对象_香上限%,0);
			Char.SetLoopEvent(nil,'ymloop',player,0);
			NLG.UpChar(player);
			NLG.SystemMessage(player,"自动遇敌关闭了！");
		elseif 不消耗诱魔水 then
			Char.SetData(player,%对象_香步数%,999);
			Char.SetData(player,%对象_香上限%,999);
			Char.SetLoopEvent(nil,'ymloop',player,5000);
			NLG.UpChar(player);
			NLG.SystemMessage(player,"自动遇敌开始了，每5秒尝试一次。");
		elseif not 不消耗诱魔水 and ymxsnum > 0 then
			Char.SetData(player,%对象_香步数%,999);
			Char.SetData(player,%对象_香上限%,999);
			Char.SetLoopEvent(nil,'ymloop',player,5000);
			Char.DelItem(player,ymxs,1);
			Item.UpItem(player,-1);
			NLG.UpChar(player);
			NLG.SystemMessage(player,"自动遇敌开始了，每5秒尝试一次。");
		elseif not 不消耗诱魔水 and ymxsnum == 0 then
			NLG.SystemMessage(player,'缺少怪物饼干，自动遇敌无法开启！');
		end
	elseif (msg == "/2" or msg == "、2") then
		if Char.GetData(player,%对象_香步数%)>0 then
			NLG.SystemMessage(player,"你正在使用步步遇敌，无法使用大蒜油！");
		elseif Char.GetData(player,%对象_不遇敌开关%)==1 then
			Char.SetData(player,%对象_不遇敌开关%,0);
			Char.SetLoopEvent(nil,'qmloop',player,0);
			NLG.UpChar(player);
			NLG.SystemMessage(player,"不遇敌功能关闭！");
		elseif 不消耗驱魔水 then
			Char.SetData(player,%对象_不遇敌开关%,1);
			NLG.UpChar(player);
			NLG.SystemMessage(player,"不遇敌已经开启！");
		elseif not 不消耗驱魔水 and qmxsnum > 0 then
			Char.SetData(player,%对象_不遇敌开关%,1);
			Char.SetLoopEvent(nil,'qmloop',player,360000);--修改驱魔水持续时间，单位毫秒
			NLG.UpChar(player);
			NLG.SystemMessage(player,"不遇敌已经开启！");
		elseif not 不消耗驱魔水 and qmxsnum == 0 then
			NLG.SystemMessage(player,'缺少大蒜油，不遇敌无法开启！');
		end
	end
	end)
end

function Module:onUnload()
  self:logInfo('unload');
end

return Module;
