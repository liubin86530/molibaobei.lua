---宠物转生，全bp+3，技能栏+1
local moduleName = 'petRebirth'
local PetRebirth = ModuleBase:createModule(moduleName)
local amount = 10  --转生扣除物品数量
local transNeedItemId = 60056 --转生需要物品id
local transNeedLv = 150 --转生需要等级

function PetRebirth:onTalked(npc, player)
  if NLG.CanTalk(npc, player) then
    NLG.ShowWindowTalked(player, npc, CONST.窗口_信息框, CONST.BUTTON_下取消, 1, '\\n\\n   大于150级的宠物可以转生\\n   转生后bp+5,技能栏+1,全属性+1,抗性+5,暴击/闪避/反击/命中+5\\n   每次需要扣除5个代币')
  end
end

function PetRebirth:firstPage(npc, player, seqNo, select, data)
  if select == CONST.BUTTON_下一页 then
	local gold_coin = Char.ItemNum(player,transNeedItemId)
	
	--print("超级金币:",gold_coin)
	--每次转生扣除10个硬币
    if gold_coin < amount then
      NLG.ShowWindowTalked(player, npc, CONST.窗口_信息框, CONST.BUTTON_关闭, 3, '\\n\\n   商城金币不足')
      return
    end
    local list = { }
    for i = 0, 4 do
      local pIndex = Char.GetPet(player, i);
	
      if pIndex >= 0 then
        local data2 = self:getPetData(pIndex);
        -- data2 = data2.rebirthTime or 0;
		
		 -- print("名字颜色:",data2)
        local lv = Char.GetData(pIndex, CONST.CHAR_等级)
        local trans = Char.GetData(pIndex,%对象_名色%)
		if lv > transNeedLv and trans < 9 then
          table.insert(list, Char.GetData(pIndex, CONST.CHAR_名字) .. ' lv.' .. lv ..'   '..data2.. '转');
        elseif lv < transNeedLv then
          table.insert(list, Char.GetData(pIndex, CONST.CHAR_名字) .. ' lv.' .. lv .. '   '..data2..'转' .. '（等级不足）');
        elseif  lv > transNeedLv and trans >= 9 then 
			table.insert(list, Char.GetData(pIndex, CONST.CHAR_名字) .. ' lv.' .. lv .. '   '..data2..'转' .. '（转生极限）');
		else
		
		end
      else
        table.insert(list, '[空]');
      end
    end
    if table.isEmpty(list) then
      NLG.ShowWindowTalked(player, npc, CONST.窗口_信息框, CONST.BUTTON_关闭, 3, '\\n\\n   没有合适的宠物')
      return
    end
    NLG.ShowWindowTalked(player, npc, CONST.窗口_选择框, CONST.BUTTON_关闭, 2, self:NPC_buildSelectionText('选择转生的宠物', list));
  else
    return
  end
end

function PetRebirth:selectPage(npc, player, seqNo, select, data)
  if select == CONST.BUTTON_关闭 then
    return
  end
  local pIndex = Char.GetPet(player, tonumber(data) - 1);
  if pIndex < 0 then
    NLG.ShowWindowTalked(player, npc, CONST.窗口_信息框, CONST.BUTTON_确定, 3, '\\n\\n   该位置没有宠物')
    return
  end
  
  if Char.GetData(pIndex,%对象_名色%) == 9 then
	NLG.ShowWindowTalked(player, npc, CONST.窗口_信息框, CONST.BUTTON_确定, 3,
     '\\n\\n   ' .. Char.GetData(pIndex, CONST.CHAR_名字) .. ' lv.' .. Char.GetData(pIndex, CONST.CHAR_等级) .. ' 宠物已经转生到极限')
  end
  
  if Char.GetData(pIndex, CONST.CHAR_等级) < transNeedLv then
    NLG.ShowWindowTalked(player, npc, CONST.窗口_信息框, CONST.BUTTON_确定, 3,
      '\\n\\n   ' .. Char.GetData(pIndex, CONST.CHAR_名字) .. ' lv.' .. Char.GetData(pIndex, CONST.CHAR_等级) .. ' 等级不足150!!!!')
    return
  end
  Char.SetData(player, CONST.CHAR_WindowBuffer2, pIndex + 1);
  NLG.ShowWindowTalked(player, npc, CONST.窗口_信息框, CONST.BUTTON_是否, 4,
    '\\n\\n   ' .. Char.GetData(pIndex, CONST.CHAR_名字) .. ' lv.' .. Char.GetData(pIndex, CONST.CHAR_等级) .. '\\n\\n   确定转生？')
end

function PetRebirth:confirmPage(npc, player, seqNo, select, data)
  if select == CONST.BUTTON_否 then
    return
  end
  local pIndex = Char.GetData(player, CONST.CHAR_WindowBuffer2) - 1;
  Char.SetData(player, CONST.CHAR_WindowBuffer2, 0);
  if not Char.IsValidCharIndex(pIndex) then
    return
  end
  local res = Char.DelItem(player,transNeedItemId,amount)
  
  if res == 0 then
    NLG.ShowWindowTalked(player, npc, CONST.窗口_信息框, CONST.BUTTON_确定, 3, '\\n\\n   转生物品不足')
    return
  end
  for i = 0, 4 do
    local pIndex2 = Char.GetPet(player, i);
    if pIndex2 == pIndex then
	  if Char.GetData(pIndex,%对象_名色%) == 9 then
		NLG.ShowWindowTalked(player, npc, CONST.窗口_信息框, CONST.BUTTON_确定, 3,
          '\\n\\n   ' .. Char.GetData(pIndex, CONST.CHAR_名字) .. ' lv.' .. Char.GetData(pIndex, CONST.CHAR_等级) .. ' 宠物已经转生到极限')
	  end
      if Char.GetData(pIndex, CONST.CHAR_等级) < transNeedLv then
        NLG.ShowWindowTalked(player, npc, CONST.窗口_信息框, CONST.BUTTON_确定, 3,
          '\\n\\n   ' .. Char.GetData(pIndex, CONST.CHAR_名字) .. ' lv.' .. Char.GetData(pIndex, CONST.CHAR_等级) .. ' 等级不足150')
        return
      end
      
      local arts = { CONST.PET_体成, CONST.PET_力成, CONST.PET_强成, CONST.PET_敏成, CONST.PET_魔成 };
      arts = table.map(arts, function(v)
        return { v, math.min(62, Pet.GetArtRank(pIndex, v) + 5) };
      end)
      table.forEach(arts, function(v)
        Pet.SetArtRank(pIndex, v[1], v[2]);
      end);
      Pet.ReBirth(player, pIndex);
      table.forEach(arts, function(v)
        Pet.SetArtRank(pIndex, v[1], v[2]);
      end);
      Char.SetData(pIndex, CONST.CHAR_地属性, math.min(100, Char.GetData(pIndex, CONST.CHAR_地属性) + 10));
      Char.SetData(pIndex, CONST.CHAR_水属性, math.min(100, Char.GetData(pIndex, CONST.CHAR_水属性) + 10));
      Char.SetData(pIndex, CONST.CHAR_火属性, math.min(100, Char.GetData(pIndex, CONST.CHAR_火属性) + 10));
      Char.SetData(pIndex, CONST.CHAR_风属性, math.min(100, Char.GetData(pIndex, CONST.CHAR_风属性) + 10));
      Char.SetData(pIndex, CONST.PET_技能栏, math.min(10, Char.GetData(pIndex, CONST.PET_技能栏) + 1));
      arts = { CONST.CHAR_抗毒, CONST.CHAR_抗睡, CONST.CHAR_抗石, CONST.CHAR_抗醉,
               CONST.CHAR_抗乱, CONST.CHAR_抗忘, CONST.CHAR_必杀, CONST.CHAR_反击,
               CONST.CHAR_命中, CONST.CHAR_闪躲, }
      table.forEach(arts, function(e)
        Char.SetData(pIndex, e, math.min(100, Char.GetData(pIndex, e) + 5));
      end)
      local petExtData = self:getPetData(pIndex)
      petExtData = (petExtData) + 1;
      self:setPetData(pIndex, petExtData);
      -- --self:logDebug('rebirthTime=', petExtData.rebirthTime);
       if (petExtData) > 5 then
         Char.SetData(pIndex, CONST.CHAR_种族, CONST.种族_邪魔);
       end
      Pet.UpPet(player, pIndex);
      NLG.UpChar(pIndex);
      NLG.UpChar(player);
      NLG.ShowWindowTalked(player, npc, CONST.窗口_信息框, CONST.BUTTON_确定, 3, '\\n\\n   已成功转生');
      return
    end
  end
  NLG.ShowWindowTalked(player, npc, CONST.窗口_信息框, CONST.BUTTON_确定, 3, '\\n\\n   该位置没有宠物')
  return
end

function PetRebirth:onSelected(npc, player, seqNo, select, data)
  if seqNo == 1 then
    self:firstPage(npc, player, seqNo, select, data)
  elseif seqNo == 2 then
    self:selectPage(npc, player, seqNo, select, data)
  elseif seqNo == 4 then
    self:confirmPage(npc, player, seqNo, select, data)
  end
end

function PetRebirth:getPetData(charIndex)
	--Char.SetData(charIndex,%对象_名色%,%颜色_青色%);
	return Char.GetData(charIndex,%对象_名色%);
end

function PetRebirth:setPetData(charIndex,trans)
	Char.SetData(charIndex,%对象_名色%,trans);
end

--- 加载模块钩子
function PetRebirth:onLoad()
  self:logInfo('load')
  local npc = self:NPC_createNormal('宠物转生', 101024, { map = 1000, x = 227, y = 83, direction = 4, mapType = 0 });
  self:NPC_regTalkedEvent(npc, Func.bind(self.onTalked, self));
  self:NPC_regWindowTalkedEvent(npc, Func.bind(self.onSelected, self));
end

--- 卸载模块钩子
function PetRebirth:onUnload()
  self:logInfo('unload')
end

return PetRebirth;
