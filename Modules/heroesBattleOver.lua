local Module = ModuleBase:createModule('manaPool')
local _ = require "lua/Modules/underscore"
local itemList = {
  { name = '血池补充（1000LP）', image = 27243, price = 1500, desc = '补充血池使用量1000点', count = 1, maxCount = 999, value = 1000, type = 'lp' },
  { name = '血池补充（10000LP）', image = 27243, price = 14500, desc = '补充血池使用量10000点', count = 1, maxCount = 999, value = 10000, type = 'lp' },
  { name = '血池补充（100000LP）', image = 27243, price = 140000, desc = '补充血池使用量100000点', count = 1, maxCount = 999, value = 100000, type = 'lp' },
  { name = '魔池补充（1000FP）', image = 26206, price = 1500, desc = '补充魔池使用量1000点', count = 1, maxCount = 999, value = 1000, type = 'fp' },
  { name = '魔池补充（10000FP）', image = 26206, price = 14500, desc = '补充魔池使用量10000点', count = 1, maxCount = 999, value = 10000, type = 'fp' },
  { name = '魔池补充（100000FP）', image = 26206, price = 140000, desc = '补充魔池使用量100000点', count = 1, maxCount = 999, value = 100000, type = 'fp' },
}
local 自动卖魔石=true
local soldrate=10
local maxMoney=10000000

-- 全局掉落
local itemSetting={
  -- {道具id，随机数最小值，随机数最大值，随机100~1000}
  {20210023,100,700},
  {60056,701,950},
}


--- 加载模块钩子
function Module:onLoad()
  self:logInfo('load')
  local npc = self:NPC_createNormal('血魔加油站', 99261, { map = 1000, x = 232, y = 83, direction = 4, mapType = 0 })
  self:NPC_regTalkedEvent(npc, Func.bind(self.onSellerTalked, self))
  self:NPC_regWindowTalkedEvent(npc, Func.bind(self.onSellerSelected, self));
  -- self:regCallback('BattleStartEvent', Func.bind(self.onBattleStart, self))
  self:regCallback('BattleOverEvent', Func.bind(self.onBattleOver, self))
end



function Module:onBattleOver(battleIndex)
  local poss={}
  for i = 0, 9 do
    table.insert(poss,i)
  end
  _.each(poss,function(pos) 
    local charIndex = Battle.GetPlayer(battleIndex, pos);

    if Char.GetData(charIndex,CONST.CHAR_类型)~=CONST.对象类型_人 then
      return
    end
 
    NLG.SortItem(charIndex);
    
    if Char.IsDummy(charIndex) then
      return
    end

  

    -- 获取英雄
    local campHeroesData = getModule('heroesFn'):getCampHeroesData(charIndex)
    -- 玩家自己补血魔
    self:heal(charIndex,charIndex)

    -- 玩家的英雄补血魔
    for k,v in pairs(campHeroesData) do
      
      self:heal(charIndex,v.index)
      if Char.GetData(charIndex,%对象_交易开关%) == 1 then
        self:clearBag(charIndex,v.index)
      end
      NLG.UpChar(v.index);
      Item.UpItem(v.index, -1);
    end
    if Char.GetData(charIndex,%对象_交易开关%) == 1 then
      self:clearBag(charIndex,charIndex)
      NLG.Say(charIndex,-1,"检测到你开启了交易，战斗后包包自动清理完毕。",1,3);
    end


      --开始分配 道具
    local randValue = NLG.Rand(1,1000);
    for i = 1,#itemSetting do
      local min= itemSetting[i][2]
      local max = itemSetting[i][3]
      local itemId = itemSetting[i][1]
      if randValue>=min and randValue<=max then
        itemIndex = Char.GiveItem(charIndex,itemId,1);
        if itemIndex<0 then
          NLG.Say(charIndex,-1,"背包满了" ,CONST.颜色_红色,0)
          return
        end
        Item.SetData( itemIndex , CONST.道具_已鉴定 ,1)
        goto continue;
      end
      ::continue::
    end


    NLG.UpChar(charIndex);
    Item.UpItem(charIndex, -1);
  end)



  
end


function Module:clearBag(charIndex,targetIndex)
  
  for laji = 14801,15055 do--3.0图鉴
    Char.DelItem(targetIndex,laji,99);
  end
  for laji2 = 606600,606691 do--7.0图鉴
    Char.DelItem(targetIndex,laji2,99);
  end
  for laji3 = 18310,18313 do--水晶碎片
    Char.DelItem(targetIndex,laji3,99);
  end
  Char.DelItem(targetIndex,18194,99)--红头盔
  Char.DelItem(targetIndex,18195,99)--绿头盔
  local price = 0
  local money = Char.GetData(charIndex, CONST.CHAR_金币)
  for laji4 = 18005,18088 do--魔石
    if Char.HaveItem(targetIndex,laji4) > -1 then
      local msprice = Item.GetData(Char.HaveItem(targetIndex,laji4),%道具_价格%)
      price = price + msprice
      Char.DelItem(targetIndex,laji4,1)
    end
  end
  if 自动卖魔石 then
    local targetName = Char.GetData(targetIndex,CONST.CHAR_名字)
    -- local soldrate = 20;  --20倍
    local money1 = money+price*soldrate;
    if money1 <= maxMoney and price > 0 then
      Char.SetData(charIndex, CONST.CHAR_金币, money1);
      NLG.SystemMessage(charIndex, targetName.."魔石已售出，获得【" .. price*soldrate .. "】魔币。");
    elseif money1 > maxMoney then
      Char.SetData(charIndex, CONST.CHAR_金币, maxMoney);
      NLG.SystemMessage(charIndex, "钱包满了！");
    end
  end
  --NLG.SortItem(player);
  -- Item.UpItem(player, -1);
  -- NLG.UpChar(player);
  
  
end

function Module:heal(charIndex,targetIndex)
  local name = Char.GetData(targetIndex,CONST.CHAR_名字)
  local lpPool = tonumber(Field.Get(charIndex, 'LpPool')) or 0;
  local fpPool = tonumber(Field.Get(charIndex, 'FpPool')) or 0;
  if lpPool <= 0 and fpPool <= 0 then
    NLG.SystemMessage(charIndex, '[血魔池] 不够');
    return
  end
  
  local lp = Char.GetData(targetIndex, CONST.CHAR_血)
  local maxLp = Char.GetData(targetIndex, CONST.CHAR_最大血)
  local fp = Char.GetData(targetIndex, CONST.CHAR_魔)
  local maxFp = Char.GetData(targetIndex, CONST.CHAR_最大魔)
  if lpPool > 0 and lp < maxLp then
    lpPool = lpPool - maxLp + lp;
    if lpPool < 0 then
      maxLp = maxLp + lpPool;
      lpPool = 0;
    end
    NLG.SystemMessage(charIndex, '[血魔池] 已为'..name..'恢复: ' .. (maxLp - lp) .. 'LP, 血池剩余: ' .. lpPool);
  else
    maxLp = lp;
  end
  if fpPool > 0 and fp < maxFp then
    fpPool = fpPool - maxFp + fp;
    if fpPool < 0 then
      maxFp = maxFp + fpPool;
      fpPool = 0;
    end
    NLG.SystemMessage(charIndex, '[血魔池] 已为'..name..'恢复: ' .. (maxFp - fp) .. 'FP, 魔池剩余: ' .. fpPool);
  else
    maxFp = fp;
  end
  
  Char.SetData(targetIndex, CONST.CHAR_血, maxLp)
  Char.SetData(targetIndex, CONST.CHAR_魔, maxFp)
  
  local petSlot = Char.GetData(targetIndex, CONST.CHAR_战宠);
  if petSlot >= 0 then
    petIndex = Char.GetPet(targetIndex, petSlot);
    lp = Char.GetData(petIndex, CONST.CHAR_血)
    maxLp = Char.GetData(petIndex, CONST.CHAR_最大血)
    fp = Char.GetData(petIndex, CONST.CHAR_魔)
    maxFp = Char.GetData(petIndex, CONST.CHAR_最大魔)
    
    if lpPool > 0 and lp < maxLp then
      lpPool = lpPool - maxLp + lp;
      if lpPool < 0 then
        maxLp = maxLp + lpPool;
        lpPool = 0;
      end
      NLG.SystemMessage(charIndex, '[血魔池] 已恢复宠物: ' .. (maxLp - lp) .. 'LP, 血池剩余: ' .. lpPool);
    else
      maxLp = lp;
    end
    if fpPool > 0 and fp < maxFp then
      fpPool = fpPool - maxFp + fp;
      if fpPool < 0 then
        maxFp = maxFp + fpPool;
        fpPool = 0;
      end
      NLG.SystemMessage(charIndex, '[血魔池] 已恢复宠物: ' .. (maxFp - fp) .. 'FP, 魔池剩余: ' .. fpPool);
    else
      maxFp = fp;
    end
    Char.SetData(petIndex, CONST.CHAR_血, maxLp)
    Char.SetData(petIndex, CONST.CHAR_魔, maxFp)
    NLG.UpChar(petIndex);
  end
  Field.Set(charIndex, 'LpPool', tostring(lpPool));
  Field.Set(charIndex, 'FpPool', tostring(fpPool));
end



function Module:onSellerTalked(npc, player)
  if NLG.CanTalk(npc, player) then
    NLG.ShowWindowTalked(player, npc, CONST.窗口_商店买, CONST.BUTTON_是, 0,
      self:NPC_buildBuyWindowData(101024, '血魔加油站', '充值血魔池', '金钱不足', '背包已满', itemList))
  end
end

function Module:onSellerSelected(npc, player, seqNo, select, data)
  local items = string.split(data, '|');
  local lpPool = tonumber(Field.Get(player, 'LpPool')) or 0;
  local fpPool = tonumber(Field.Get(player, 'FpPool')) or 0;
  local gold = Char.GetData(player, CONST.CHAR_金币)
  local totalGold = 0;
  local totalLp = 0;
  local totalFp = 0;
  for i = 1, #items / 2 do
    local c = itemList[items[(i - 1) * 2 + 1] + 1]
    if c then
      local count = (tonumber(items[(i - 1) * 2 + 2]) or 0);
      if c.type == 'lp' then
        totalLp = totalLp + c.value * count;
      else
        totalFp = totalFp + c.value * count;
      end
      totalGold = totalGold + c.price * count;
    end
  end
  if gold < totalGold then
    NLG.SystemMessage(player, '金币不足');
    return
  end
  Char.AddGold(player, -totalGold);
  Field.Set(player, 'LpPool', tostring(lpPool + totalLp));
  Field.Set(player, 'FpPool', tostring(fpPool + totalFp));
  NLG.UpChar(player);
  if totalLp > 0 then
    NLG.SystemMessage(player, '[血魔池] 补充血池: ' .. totalLp .. ', 共: ' .. (lpPool + totalLp));
  end
  if totalFp > 0 then
    NLG.SystemMessage(player, '[血魔池] 补充魔池: ' .. totalFp .. ', 共: ' .. (fpPool + totalFp));
  end
end

--- 卸载模块钩子
function Module:onUnload()
  self:logInfo('unload')
end

return Module;
