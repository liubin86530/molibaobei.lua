local Module = ModuleBase:createModule('encountEX')

local ��������ħˮ = true--���ĵ��߿���
local ��������ħˮ = true--���ĵ��߿���
local ymxs = 900498--��ħ��ˮ
local qmxs = 900497--��ħ��ˮ

function Module:onLoad()
	self:logInfo('load')
	self:regCallback('LoopEvent', Func.bind(self.ymloop,self))
	self:regCallback('ymloop',function(player)
	local playeryd = Char.GetData(player,%����_ս����%) == 0
	local ymxsnum = Char.ItemNum(player,ymxs)
	local ymbs = Char.GetData(player,%����_�㲽��%)
	if playeryd then
		if ��������ħˮ then
			Battle.Encount(player, player);
		else
			if ymbs > 979 then--�޸���ħˮ��������
				Char.SetData(player,%����_�㲽��%,ymbs-1);
				NLG.UpChar(player);
				Battle.Encount(player, player);
				NLG.SystemMessage(player,'�Զ�����ʣ��'..(ymbs-980)..'��')
			else
				if ymxsnum > 1 then
					Char.SetData(player,%����_�㲽��%,998);
					Char.DelItem(player,ymxs,1);
					Item.UpItem(player,-1);
					NLG.UpChar(player);
					NLG.SystemMessage(player,'����һ��������ɣ��Զ����м���������'..(ymxsnum-1)..'��������ɡ�');
					Battle.Encount(player, player);
				elseif ymxsnum == 1 then
					Char.SetData(player,%����_�㲽��%,998);
					Char.DelItem(player,ymxs,1);
					Item.UpItem(player,-1);
					NLG.UpChar(player);
					NLG.SystemMessage(player,'�Զ��������һ����Ч,�뼰ʱ���������ɣ�');
					Battle.Encount(player, player);
				else
					Char.SetData(player,%����_�㲽��%,0);
					Char.SetData(player,%����_������%,0);
					Char.SetLoopEvent(nil,'ymloop',player,0);
					NLG.SystemMessage(player,'����������Ĵ������Զ����йرգ�')
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
		NLG.SystemMessage(player,'����һƿ�����ͣ������м���������'..(qmxsnum-1)..'ƿ�����͡�');
	elseif qmxsnum == 1 then
		Char.DelItem(player,qmxs,1);
		Item.UpItem(player,-1);
		NLG.SystemMessage(player,'���������һ����Ч,�뼰ʱ��������ͣ�');
	else
		Char.SetData(player,%����_�����п���%,0);
		Char.SetLoopEvent(nil,'qmloop',player,0);
		NLG.UpChar(player);
		NLG.SystemMessage(player,'���������Ĵ����������йرգ�')
	end
	end)
	self:regCallback('TalkEvent', function(player, msg)
	local ymxsnum = Char.ItemNum(player,ymxs)
	local qmxsnum = Char.ItemNum(player,qmxs)
	if (msg == "/1" or msg == "��1") then
		if Char.GetData(player,%����_�����п���%) == 1 then
			NLG.SystemMessage(player,"������ʹ�ô����ͣ��޷�ʹ���Զ�����");
		elseif Char.GetData(player,%����_�㲽��%) > 0 then
			Char.SetData(player,%����_�㲽��%,0);
			Char.SetData(player,%����_������%,0);
			Char.SetLoopEvent(nil,'ymloop',player,0);
			NLG.UpChar(player);
			NLG.SystemMessage(player,"�Զ����йر��ˣ�");
		elseif ��������ħˮ then
			Char.SetData(player,%����_�㲽��%,999);
			Char.SetData(player,%����_������%,999);
			Char.SetLoopEvent(nil,'ymloop',player,5000);
			NLG.UpChar(player);
			NLG.SystemMessage(player,"�Զ����п�ʼ�ˣ�ÿ5�볢��һ�Ρ�");
		elseif not ��������ħˮ and ymxsnum > 0 then
			Char.SetData(player,%����_�㲽��%,999);
			Char.SetData(player,%����_������%,999);
			Char.SetLoopEvent(nil,'ymloop',player,5000);
			Char.DelItem(player,ymxs,1);
			Item.UpItem(player,-1);
			NLG.UpChar(player);
			NLG.SystemMessage(player,"�Զ����п�ʼ�ˣ�ÿ5�볢��һ�Ρ�");
		elseif not ��������ħˮ and ymxsnum == 0 then
			NLG.SystemMessage(player,'ȱ�ٹ�����ɣ��Զ������޷�������');
		end
	elseif (msg == "/2" or msg == "��2") then
		if Char.GetData(player,%����_�㲽��%)>0 then
			NLG.SystemMessage(player,"������ʹ�ò������У��޷�ʹ�ô����ͣ�");
		elseif Char.GetData(player,%����_�����п���%)==1 then
			Char.SetData(player,%����_�����п���%,0);
			Char.SetLoopEvent(nil,'qmloop',player,0);
			NLG.UpChar(player);
			NLG.SystemMessage(player,"�����й��ܹرգ�");
		elseif ��������ħˮ then
			Char.SetData(player,%����_�����п���%,1);
			NLG.UpChar(player);
			NLG.SystemMessage(player,"�������Ѿ�������");
		elseif not ��������ħˮ and qmxsnum > 0 then
			Char.SetData(player,%����_�����п���%,1);
			Char.SetLoopEvent(nil,'qmloop',player,360000);--�޸���ħˮ����ʱ�䣬��λ����
			NLG.UpChar(player);
			NLG.SystemMessage(player,"�������Ѿ�������");
		elseif not ��������ħˮ and qmxsnum == 0 then
			NLG.SystemMessage(player,'ȱ�ٴ����ͣ��������޷�������');
		end
	end
	end)
end

function Module:onUnload()
  self:logInfo('unload');
end

return Module;
