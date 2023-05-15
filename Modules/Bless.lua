local Module = ModuleBase:createModule('Bless')
local 自动卖魔石 = true--自动卖魔石开关

function Module:onLoad()
	self:logInfo('load')
	self:regCallback('BattleOverEvent', Func.bind(Module.battleOverEventCallback, self))
end

function Module:battleOverEventCallback(battleIndex)
	for i=0,9 do--自动丢垃圾+理包+卖魔石(每人开启)
		local player = Battle.GetPlayer(battleIndex,i)
    self:logInfo('扫描到当前玩家',player);
		if player>-1 then
      
			if Char.GetData(player,%对象_交易开关%) == 1 then
				for laji = 14801,15055 do--3.0图鉴
					Char.DelItem(player,laji,99);
				end
				for laji2 = 606600,606691 do--7.0图鉴
					Char.DelItem(player,laji2,99);
				end
				for laji3 = 18310,18313 do--水晶碎片
					Char.DelItem(player,laji3,99);
				end
				Char.DelItem(player,18194,99)--红头盔
				Char.DelItem(player,18195,99)--绿头盔
				local price = 0
				local money = Char.GetData(player, CONST.CHAR_金币)
				for laji4 = 18005,18088 do--魔石
					if Char.HaveItem(player,laji4) > -1 then
						local msprice = Item.GetData(Char.HaveItem(player,laji4),%道具_价格%)
						price = price + msprice
						Char.DelItem(player,laji4,1)
					end
				end
				if 自动卖魔石 then
					local soldrate = 20;  --20倍
					local money1 = money+price*soldrate;
					if money1 <= 10000000 and price > 0 then
						Char.SetData(player, CONST.CHAR_金币, money1);
						NLG.SystemMessage(player, "魔石已售出，获得【" .. price*20 .. "】魔币。");
					elseif money1 > 10000000 then
						Char.SetData(player, CONST.CHAR_金币, 10000000);
						NLG.SystemMessage(player, "钱包满了，请及时兑换成银票！");
					end
				end
				Item.UpItem(player, -1);
				NLG.UpChar(player);
			end
		end
	end
	return 0;
end

function Module:onUnload()
  self:logInfo('unload');
end

return Module;
