local Module = ModuleBase:createModule('Bless')
local �Զ���ħʯ = true--�Զ���ħʯ����

function Module:onLoad()
	self:logInfo('load')
	self:regCallback('BattleOverEvent', Func.bind(Module.battleOverEventCallback, self))
end

function Module:battleOverEventCallback(battleIndex)
	for i=0,9 do--�Զ�������+���+��ħʯ(ÿ�˿���)
		local player = Battle.GetPlayer(battleIndex,i)
    self:logInfo('ɨ�赽��ǰ���',player);
		if player>-1 then
      
			if Char.GetData(player,%����_���׿���%) == 1 then
				for laji = 14801,15055 do--3.0ͼ��
					Char.DelItem(player,laji,99);
				end
				for laji2 = 606600,606691 do--7.0ͼ��
					Char.DelItem(player,laji2,99);
				end
				for laji3 = 18310,18313 do--ˮ����Ƭ
					Char.DelItem(player,laji3,99);
				end
				Char.DelItem(player,18194,99)--��ͷ��
				Char.DelItem(player,18195,99)--��ͷ��
				local price = 0
				local money = Char.GetData(player, CONST.CHAR_���)
				for laji4 = 18005,18088 do--ħʯ
					if Char.HaveItem(player,laji4) > -1 then
						local msprice = Item.GetData(Char.HaveItem(player,laji4),%����_�۸�%)
						price = price + msprice
						Char.DelItem(player,laji4,1)
					end
				end
				if �Զ���ħʯ then
					local soldrate = 20;  --20��
					local money1 = money+price*soldrate;
					if money1 <= 10000000 and price > 0 then
						Char.SetData(player, CONST.CHAR_���, money1);
						NLG.SystemMessage(player, "ħʯ���۳�����á�" .. price*20 .. "��ħ�ҡ�");
					elseif money1 > 10000000 then
						Char.SetData(player, CONST.CHAR_���, 10000000);
						NLG.SystemMessage(player, "Ǯ�����ˣ��뼰ʱ�һ�����Ʊ��");
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
