local module = ModuleBase:createModule('heroesAI')
local _ = require "lua/Modules/underscore"
local JSON=require "lua/Modules/json"
local heroesFn = getModule("heroesFn")
local sgModule = getModule("setterGetter")
local skillInfo = dofile("lua/Modules/autoBattleParams.lua")
local function getHp(charIndex)
  return Char.GetData(charIndex,CONST.CHAR_血)
end
local function getMaxHp(charIndex)
  return Char.GetData(charIndex,CONST.CHAR_最大血)
end
local function getMp(charIndex)
  return Char.GetData(charIndex,CONST.CHAR_魔)
end
local function getMaxMp(charIndex)
  return Char.GetData(charIndex,CONST.CHAR_最大魔)
end



local function oppositeSide(side)
  if side==0 then
    return 1
  else
    return 0
  end
end

-- NOTE 循环己方 获得己方的所有单位Index
local function getAttackerSide(charIndex,side,battleIndex)
  local slotTable={}
  for slot = side*10+0,side*10+9 do
    --  print("slot",slot)
    local charIndex = Battle.GetPlayer(battleIndex, slot) 
    --  print("charIndex",charIndex)
    if(charIndex>=0) then
      table.insert(slotTable,charIndex)
    end

  end
  return slotTable
end



-- NOTE 循环对方 获得对方的所有单位Index
local function getDeffenderSide(charIndex,attSide,battleIndex)
  local side=oppositeSide(attSide)
  local slotTable={}
  for slot = side*10+0,side*10+9 do
    --  print("slot",slot)
    local charIndex = Battle.GetPlayer(battleIndex, slot) 
    --  print("charIndex",charIndex)
    if(charIndex>=0) then
      table.insert(slotTable,charIndex)
    end

  end
  return slotTable
end
-- NOTE 是否 中了某个状态 
--   return :true false
local function hasGotStatus(charIndex,side,battleIndex,statusKey)
  return function (charIndex,side,battleIndex) 
    local chars = getAttackerSide(charIndex,side,battleIndex)
    return _.any(chars,function(charIndex) 
      return Char.GetData(charIndex,statusKey)==1
    end)
  
  end

end

-- NOTE 中了异常的人数
--   return: num
local function gotAnyStatusNum(charIndex,side,battleIndex)
  local chars = getAttackerSide(charIndex,side,battleIndex)
  local statusChars=  _.select(chars,function(charIndex) 
   
    return Char.GetData(charIndex,CONST.CHAR_BattleModPoison)>1 or 
      Char.GetData(charIndex,CONST.CHAR_BattleModSleep)>1 or 
      Char.GetData(charIndex,CONST.CHAR_BattleModStone)>1 or 
      Char.GetData(charIndex,CONST.CHAR_BattleModDrunk)>1 or 
      Char.GetData(charIndex,CONST.CHAR_BattleModConfusion)>1 or 
      Char.GetData(charIndex,CONST.CHAR_BattleModAmnesia)>1 
  end) 

  return #statusChars;
end



-- NOTE 判断 人数 
--   return :true false
local function livesNumEq(charIndex,side,battleIndex,num)
  return function (charIndex,side,battleIndex) 
    local chars = getAttackerSide(charIndex,side,battleIndex)
    local liveChars = _.select(chars,function(charIndex) 
      return Char.GetData(charIndex,CONST.CHAR_战死)==0
    end)
    return #liveChars == num
  end
end
-- NOTE 获得己方存活人数
--  return  num
local function livesNum(charIndex,side,battleIndex)

  local chars = getAttackerSide(charIndex,side,battleIndex)
  local liveChars = _.select(chars,function(charIndex) 
    return Char.GetData(charIndex,CONST.CHAR_战死)==0
  end)
  return #liveChars
end

-- NOTE 获得己方战死人物数量
local function deadPlayerNum(charIndex,side,battleIndex)
  local chars = getAttackerSide(charIndex,side,battleIndex)
  local liveChars = _.select(chars,function(charIndex) 
    return Char.GetData(charIndex,CONST.CHAR_战死)==1 and Char.GetData(charIndex,CONST.CHAR_类型)==CONST.对象类型_人
  end)
  return #liveChars
end

-- NOTE 获得己方战死人数
local function deadNum(charIndex,side,battleIndex)
  local chars = getAttackerSide(charIndex,side,battleIndex)
  local liveChars = _.select(chars,function(charIndex) 
    return Char.GetData(charIndex,CONST.CHAR_战死)==1
  end)
  return #liveChars
end


-- NOTE 获得对方人数
--  return  num
local function livesDefNum(charIndex,side,battleIndex)

  local chars = getDeffenderSide(charIndex,side,battleIndex)
  local liveChars = _.select(chars,function(charIndex) 
    return Char.GetData(charIndex,CONST.CHAR_战死)==0
  end)
  return #liveChars

end


-- NOTE 获得 平均等级
--  return num
local function averageLevel(charIndexTable)
  local totalLevel = _.reduce(charIndexTable,0, function(count, charIndex) 
    local level = Char.GetData(charIndex,CONST.CHAR_等级)
    return count+level
  end)
  return totalLevel/#charIndexTable
end

-- NOTE 己方 hp < x 的超过  y人
local function partyLowerHPNum(charIndex,side,battleIndex,hpRatio,num)
  local chars = getAttackerSide(charIndex,side,battleIndex)
  local count=0;
  for i = 1,#chars do
    local cIndex = chars[i]
    if getHp(cIndex)/getMaxHp(cIndex) < hpRatio then
      count=count+1
    end
    if count>num then
      return true
    end
  end
  return false
end
-- SECTION 条件
module.conditions={
  -- NOTE 自身 无条件释放
  ['0']= {
    comment="(无条件释放)",
    fn=function(charIndex) return true end
  },
  -- NOTE 自身hp =100%
  ['4']={
    comment="自身hp=100%",
    fn=function(charIndex) return getHp(charIndex)==getMaxHp(charIndex) end
  } ,
  -- NOTE 自身hp > 75%
  ['5']= {
    comment="自身hp>75%",
    fn=function(charIndex) return getHp(charIndex)/getMaxHp(charIndex)>0.75 end
  },
  -- NOTE 自身hp > 50%
  ['6']= {
    comment="自身hp>50%",
    fn=function(charIndex) return getHp(charIndex)/getMaxHp(charIndex)>0.5 end
  },
  -- NOTE 自身hp < 50%
  ['7']= {
    comment="自身hp<50%",
    fn=function(charIndex) return getHp(charIndex)/getMaxHp(charIndex)<0.5 end
  },
  -- NOTE 自身hp < 25%
  ['8']={
    comment="自身hp<30%",
    fn=function(charIndex) return getHp(charIndex)/getMaxHp(charIndex)<0.3 end
  } ,
  -- NOTE 自身 mp>=0.5
  ['9']= {
    comment="自身mp>=50%",
    fn=function(charIndex) return getMp(charIndex)/getMaxMp(charIndex)>=0.5 end
  },
  -- NOTE 自身mp<50%
  ['10']={
    comment="自身mp<50%",
    fn=function(charIndex) return getMp(charIndex)/getMaxMp(charIndex)<0.5 end
  } ,

  -- NOTE 己方阵营中有中毒单位
  ["13"]={
    comment="己方有中毒单位",
    fn=hasGotStatus(CONST.CHAR_BattleModPoison )
  } ,
  -- NOTE 己方阵营中有混乱单位
  ["14"]= {
    comment="己方有混乱单位",
    fn=hasGotStatus(CONST.CHAR_BattleModConfusion )
  } ,
  -- NOTE 己方阵营中有石化单位
  ["15"]= {
    comment="己方有石化单位",
    fn=hasGotStatus(CONST.CHAR_BattleModStone )
  } ,
  -- NOTE 己方阵营中有睡眠单位
  ["16"]= {
    comment="己方有睡眠单位",
    fn=hasGotStatus(CONST.CHAR_BattleModSleep )
  },
  -- NOTE 己方阵营中有酒醉单位
  ["17"]= {
    comment="己方有酒醉单位",
    fn=hasGotStatus(CONST.CHAR_BattleModDrunk )
  },
  -- NOTE 己方阵营中有遗忘单位
  ["18"]={
    comment="己方有遗忘单位",
    fn=hasGotStatus(CONST.CHAR_BattleModAmnesia )
  } ,
  -- NOTE 己方阵营中存活数量0
  ["19"]={
    comment="己方存活为0",
    fn=livesNumEq(charIndex,side,battleIndex,0)
  } ,
  -- NOTE 己方阵营中存活数量1
  ["20"]= {
    comment="己方存活为1",
    fn=livesNumEq(charIndex,side,battleIndex,1)
  },
  -- NOTE 己方阵营中存活数量2
  ["21"]= {
    comment="己方存活为1",
    fn=livesNumEq(charIndex,side,battleIndex,2)
  },
  -- NOTE 己方阵营中存活数量 ==10
  ["22"]= {
    comment="己方存活为10",
    fn=livesNumEq(charIndex,side,battleIndex,10)
  },
  -- NOTE 己方阵营中存活数量>=8
  ["23"]={
    comment="己方存活>=8",
    fn=function(charIndex,side,battleIndex)  return livesNum(charIndex,side,battleIndex) >=8  end
  } ,
  -- NOTE 己方阵营中存活数量>=5
  ["24"]= {
    comment="己方存活>=5",
    fn=function(charIndex,side,battleIndex)  return livesNum(charIndex,side,battleIndex) >=5  end
  },
  -- NOTE 己方阵营中存活数量<5
  ["25"]={
    comment="己方存活<5",
    fn=function(charIndex,side,battleIndex)  return livesNum(charIndex,side,battleIndex) <5  end
  } ,
  -- NOTE 己方阵营中存活数量<4
  ["26"]= {
    comment="己方存活<4",
    fn=function(charIndex,side,battleIndex)  return livesNum(charIndex,side,battleIndex) <4  end
  } ,
  -- NOTE 己方阵营中存活数量<=1
  ["27"]= {
    comment="己方存活<=1",
    fn=function(charIndex,side,battleIndex)  return livesNum(charIndex,side,battleIndex) <=1  end
  },
  -- NOTE 己方平均等级 < 敌方
  ["29"]={
    comment="己方平均等级<敌方",
    fn=function(charIndex,side,battleIndex)  return averageLevel(getAttackerSide(charIndex,side,battleIndex))< averageLevel(getDeffenderSide(charIndex,side,battleIndex)) end
  } ,
  -- NOTE 己方平均等级 >= 敌方
  ["30"]={
    comment="己方平均等级>=敌方",
    fn=function(charIndex,side,battleIndex)  return averageLevel(getAttackerSide(charIndex,side,battleIndex)) >= averageLevel(getDeffenderSide(charIndex,side,battleIndex))  end
  } ,
  -- NOTE 对方某一单位hp ==100%
  ["31"]={
    comment="对方某单位hp=100%",
    fn= function(charIndex,side,battleIndex) 
          local defChars = getDeffenderSide(charIndex,side,battleIndex)
          return _.any(defChars,function(charIndex) 
            return Char.GetData(charIndex,CONST.CHAR_血)/Char.GetData(charIndex,CONST.CHAR_最大血) ==1
          end)
        end
  },
  -- NOTE 对方 某一单位hp >75%
  ["32"]={
    comment="对方某单位hp>75%",
    fn= function(charIndex,side,battleIndex) 
          local defChars = getDeffenderSide(charIndex,side,battleIndex)
          return _.any(defChars,function(charIndex) 
            return Char.GetData(charIndex,CONST.CHAR_血)/Char.GetData(charIndex,CONST.CHAR_最大血) > 0.75
          end)
        end
  },
  -- NOTE 对方 某一单位hp >50%
  ["33"]={
    comment="对方某单位hp>50%",
    fn= function(charIndex,side,battleIndex) 
          local defChars = getDeffenderSide(charIndex,side,battleIndex)
          return _.any(defChars,function(charIndex) 
            return Char.GetData(charIndex,CONST.CHAR_血)/Char.GetData(charIndex,CONST.CHAR_最大血) > 0.5
          end)
        end
  },
  -- NOTE 对方 某一单位hp <50%
  ["34"]={
    comment="对方某单位hp<50%",
    fn= function(charIndex,side,battleIndex) 
        local defChars = getDeffenderSide(charIndex,side,battleIndex)
        
        return _.any(defChars,function(charIndex) 
          return Char.GetData(charIndex,CONST.CHAR_血)/Char.GetData(charIndex,CONST.CHAR_最大血) < 0.5
        end)
      end
  },
  -- NOTE 对方 某一单位hp <25%
  ["35"]={
    comment="对方某单位hp<25%",
    fn= function(charIndex,side,battleIndex) 
          local defChars = getDeffenderSide(charIndex,side,battleIndex)
          return _.any(defChars,function(charIndex) 
            return Char.GetData(charIndex,CONST.CHAR_血)/Char.GetData(charIndex,CONST.CHAR_最大血) < 0.25
          end)
        end
  },
  -- NOTE 奇数回合
  ['55']={
    comment="奇数回合",
    fn=function(charIndex,side,battleIndex) return math.fmod(Battle.GetTurn(battleIndex)+1,2) == 1 end
  },
  -- NOTE 偶数回合
  ['56']={
    comment="偶数回合",
    fn=function(charIndex,side,battleIndex) return math.fmod(Battle.GetTurn(battleIndex)+1,2) == 0 end
  },
  -- NOTE 间隔2回合
  ['57']={
    comment="间隔了2回合",
    fn=function(charIndex,side,battleIndex) return math.fmod(Battle.GetTurn(battleIndex),2)  == 0 end
  },
  -- NOTE 间隔3回合
  ['58']={
    comment="间隔了3回合",
    fn=function(charIndex,side,battleIndex) return math.fmod(Battle.GetTurn(battleIndex),3)  == 0 end
  },
  -- NOTE 间隔4回合
  ['59']={
    comment="间隔了4回合",
    fn=function(charIndex,side,battleIndex) return math.fmod(Battle.GetTurn(battleIndex),4)  == 0 end
  },
  -- NOTE 间隔5回合
  ['60']={
    comment="间隔了5回合",
    fn=function(charIndex,side,battleIndex) return math.fmod(Battle.GetTurn(battleIndex),5)  == 0 end
  },
  -- NOTE 间隔6回合
  ['61']={
    comment="间隔了6回合",
    fn=function(charIndex,side,battleIndex) return math.fmod(Battle.GetTurn(battleIndex),6)  == 0 end
  },
  -- NOTE 间隔7回合
  ['62']={
    comment="间隔了7回合",
    fn=function(charIndex,side,battleIndex) return math.fmod(Battle.GetTurn(battleIndex),7)  == 0 end
  },
  -- NOTE 间隔8回合
  ['63']={
    comment="间隔了8回合",
    fn=function(charIndex,side,battleIndex) return math.fmod(Battle.GetTurn(battleIndex),8)  == 0 end
  },
  -- NOTE 对方只有一个存活
  ["82"]= {
    comment="对方只有一个存活",
    fn=function(charIndex,side,battleIndex)  return livesDefNum(charIndex,side,battleIndex) ==1  end
  } ,
  -- NOTE 对方存活 >1
  ["83"]={
    comment="对方存活数>1",
    fn=function(charIndex,side,battleIndex)  return livesDefNum(charIndex,side,battleIndex) >1  end
  } ,
  -- NOTE 对方存活 >2
  ["84"]={
    comment="对方存活数>2",
    fn=function(charIndex,side,battleIndex)  return livesDefNum(charIndex,side,battleIndex) >2  end
  } ,
  -- NOTE 对方存活 >3
  ["85"]={
    comment="对方存活数>3",
    fn=function(charIndex,side,battleIndex)  return livesDefNum(charIndex,side,battleIndex) >3  end
  } ,
  -- NOTE 对方存活 >5
  ["86"]={
    comment="对方存活数>5",
    fn=function(charIndex,side,battleIndex)  return livesDefNum(charIndex,side,battleIndex) >5  end
  } ,


  -- NOTE 第一回合
  ["89"]={
    comment="是第一回合",
    fn=function(charIndex,side,battleIndex) return Battle.GetTurn(battleIndex) == 0 end
  } ,


  -- --  己方 mp<0.25
  -- ['90']= function(charIndex) return getMp(charIndex)/getMaxMp(charIndex)<0.25 end,
  -- --  己方 mp<0.15
  -- ['91']= function(charIndex) return getMp(charIndex)/getMaxMp(charIndex)<0.15 end,
  -- --  己方 mp<0.05
  -- ['92']= function(charIndex) return getMp(charIndex)/getMaxMp(charIndex)<0.05 end,
  -- NOTE 己方HP<50%超过5人
  ["93"]={
    comment="己方HP<50%超过5人",
    fn=function(charIndex,side,battleIndex) return partyLowerHPNum(charIndex,side,battleIndex,0.5,5) end
  } ,
  -- NOTE 己方HP<50%超过4人
  ["94"]={
    comment="己方HP<50%超过4人",
    fn=function(charIndex,side,battleIndex) return partyLowerHPNum(charIndex,side,battleIndex,0.5,4) end
  } ,
  -- NOTE 己方HP<75%超过5人
  ["95"]={
    comment="己方HP<75%超过5人",
    fn=function(charIndex,side,battleIndex) return partyLowerHPNum(charIndex,side,battleIndex,0.75,5) end
  } ,
  -- NOTE 己方HP<75%超过4人
  ["96"]={
    comment="己方HP<75%超过4人",
    fn=function(charIndex,side,battleIndex) return partyLowerHPNum(charIndex,side,battleIndex,0.75,4) end
  } ,
  -- NOTE 己方有人物战死
  ["97"]={
    comment="己方有人物战死",
    fn=function(charIndex,side,battleIndex) return deadPlayerNum(charIndex,side,battleIndex)>=1 end
  } ,
  ["98"]={
    comment="己方有单位战死",
    fn=function(charIndex,side,battleIndex) return deadNum(charIndex,side,battleIndex)>=1 end
  } ,
  -- NOTE 对方存活 <=8
  ["99"]={
    comment="对方存活数<=8",
    fn=function(charIndex,side,battleIndex)  return livesDefNum(charIndex,side,battleIndex) <=8  end
  } ,
  -- NOTE 对方存活 <=5
  ["100"]={
    comment="对方存活数<=5",
    fn=function(charIndex,side,battleIndex)  return livesDefNum(charIndex,side,battleIndex) <=5  end
  } ,
  -- NOTE 对方存活 <=4
  ["101"]={
    comment="对方存活数<=4",
    fn=function(charIndex,side,battleIndex)  return livesDefNum(charIndex,side,battleIndex) <=4  end
  } ,
  -- NOTE 对方存活 <=3
  ["102"]={
    comment="对方存活数<=3",
    fn=function(charIndex,side,battleIndex)  return livesDefNum(charIndex,side,battleIndex) <=3  end
  } ,
  -- NOTE 对方存活 <=2
  ["103"]={
    comment="对方存活数<=2",
    fn=function(charIndex,side,battleIndex)  return livesDefNum(charIndex,side,battleIndex) <=2  end
  } ,
  -- NOTE 对方存活 <=1
  ["104"]={
    comment="对方存活数<=1",
    fn=function(charIndex,side,battleIndex)  return livesDefNum(charIndex,side,battleIndex) <=1  end
  } ,
  --NOTE 己方HP<30%超过0人
  ["105"]={
    comment="己方HP<30%>=1人",
    fn=function(charIndex,side,battleIndex) return partyLowerHPNum(charIndex,side,battleIndex,0.3,0) end
  } ,
  --NOTE 己方HP<40%超过0人
  ["106"]={
    comment="己方HP<40%>=1人",
    fn=function(charIndex,side,battleIndex) return partyLowerHPNum(charIndex,side,battleIndex,0.4,0) end
  } ,
  --NOTE 己方HP<40%超过3人
  ["107"]={
    comment="己方HP<40%>=2人",
    fn=function(charIndex,side,battleIndex) return partyLowerHPNum(charIndex,side,battleIndex,0.4,2) end
  } ,
  -- NOTE 己方中异常人数>=1
  ['201']={
    comment="己方中异常人数>=1",
    fn=function(charIndex,side,battleIndex)  return gotAnyStatusNum(charIndex,side,battleIndex) >=1  end
  } ,
  -- NOTE 己方中异常人数>=3
  ['202']={
    comment="己方中异常人数>=3",
    fn=function(charIndex,side,battleIndex)  return gotAnyStatusNum(charIndex,side,battleIndex) >=3  end
  } ,
  -- NOTE 己方中异常人数>=5
  ['203']={
    comment="己方中异常人数>=5",
    fn=function(charIndex,side,battleIndex)  return gotAnyStatusNum(charIndex,side,battleIndex) >=5  end
  } ,
}
-- !SECTION 


-- NOTE target 获取—— 判断 range 为 2，3 的情况
local function getTargetWithRange23(side,range)
  local allTable={
    [1]=40,[2]=41,['all']=42
  }
  if range==3 then
    return 42
  end
  if range==2 then
    return  allTable[side+1]
  end
  return nil
end



-- NOTE 随机目标
-- side 0 是下方， 1 是上方
-- range: 0:single,1: range ,2: sideAll 3. whole
local randomTarget=_.wrap(getTargetWithRange23,function (func,side,battleIndex,range)
  local isRange23 = func(side,range)
  if isRange23~=nil then
    return isRange23
  end

  local slotTable = {}
  
  for slot = side*10+0,side*10+9 do
    local charIndex = Battle.GetPlayer(battleIndex, slot) 
    if(charIndex>=0) then
      table.insert(slotTable,slot)
    end

  end
 
  local randomSlot = slotTable[NLG.Rand(1,#slotTable)]
  -- 获得真实位置
  local result=getModule("battleExtend"):getEntryPositionBySlot(battleIndex,randomSlot)
  if range==0 then
  return result
  end
  if range==1 then
  return result+20
  end
  return result
end)



-- NOTE 血最多的
local findMostHp =_.wrap(getTargetWithRange23,function (func,side,battleIndex,range)
  local isRange23 = func(side,range)
  if isRange23~=nil then
    return isRange23
  end

  local tagHp=nil;
  local returnSlot;
  for slot = side*10+0,side*10+9 do
    local charIndex = Battle.GetPlayer(battleIndex, slot) 
    if(charIndex>=0) then
      local hp = Char.GetData(charIndex,CONST.CHAR_血)
      if tagHp==nil then
        tagHp=hp
        returnSlot= slot
      elseif hp>tagHp then
        tagHp=hp;
        returnSlot= slot
      end
    end

  end
  -- 获得真实位置
  local result=getModule("battleExtend"):getEntryPositionBySlot(battleIndex,returnSlot)
  if range==0 then
    return result
  end
  if range==1 then
    return result+20
  end
  return result
end)
-- NOTE 血最少的
local findLeastHp =_.wrap(getTargetWithRange23,function (func,side,battleIndex,range)
  local isRange23 = func(side,range)
  if isRange23~=nil then
    return isRange23
  end

  local tagHp=nil;
  local returnSlot;
  for slot = side*10+0,side*10+9 do
    local charIndex = Battle.GetPlayer(battleIndex, slot) 
    if(charIndex>=0) then
      local hp = Char.GetData(charIndex,CONST.CHAR_血)
      if tagHp==nil then
        tagHp=hp
        returnSlot= slot
      elseif hp<tagHp then
        tagHp=hp;
        returnSlot= slot
      end
    end

  end
  -- 获得真实位置
  local result=getModule("battleExtend"):getEntryPositionBySlot(battleIndex,returnSlot)
  if range==0 then
    return result
   end
   if range==1 then
    return result+20
   end
   return result
end)
-- NOTE 血量占比最低的
local findLeastHpRatio = _.wrap(getTargetWithRange23,function (func,side,battleIndex,range)
  local isRange23 = func(side,range)
  if isRange23~=nil then
    return isRange23
  end

  local tagHp=nil;
  local returnSlot;
  for slot = side*10+0,side*10+9 do
    local charIndex = Battle.GetPlayer(battleIndex, slot) 
    if(charIndex>=0) then
      local hpRatio = getHp(charIndex)/getMaxHp(charIndex)
      if tagHp==nil then
        tagHp=hpRatio
        returnSlot= slot
      elseif hpRatio<tagHp then
        tagHp=hpRatio;
        returnSlot= slot
      end
    end

  end
  -- 获得真实位置
  local result=getModule("battleExtend"):getEntryPositionBySlot(battleIndex,returnSlot)
  if range==0 then
    return result
   end
   if range==1 then
    return result+20
   end
   return result
end)

-- NOTE 随机玩家单位（含英雄）
local findRandomPlayer =_.wrap(getTargetWithRange23,function (func,side,battleIndex,range)
  local isRange23 = func(side,range)
  if isRange23~=nil then
    return isRange23
  end
  local slotTable = {}
  
  for slot = side*10+0,side*10+9 do
    local charIndex = Battle.GetPlayer(battleIndex, slot) 
    if(charIndex>=0 and Char.GetData(charIndex,CONST.CHAR_类型)== CONST.对象类型_人) then
      table.insert(slotTable,slot)
    end
  end
  local returnSlot = slotTable[NLG.Rand(1,#slotTable)]
  -- 获得真实位置
  local result=getModule("battleExtend"):getEntryPositionBySlot(battleIndex,returnSlot)
  if range==0 then
  return result
  end
  if range==1 then
  return result+20
  end
  return result
end)

-- NOTE 随机宠物单位
local findRandomPet= _.wrap(getTargetWithRange23,function (func,side,battleIndex,range)
  local isRange23 = func(side,range)
  if isRange23~=nil then
    return isRange23
  end

  local slotTable = {}
  
  for slot = side*10+0,side*10+9 do
    local charIndex = Battle.GetPlayer(battleIndex, slot) 
    if(charIndex>=0 and Char.GetData(charIndex,CONST.CHAR_类型)== CONST.对象类型_宠) then
      table.insert(slotTable,slot)
    end
  end
   local returnSlot = slotTable[NLG.Rand(1,#slotTable)]
  -- 获得真实位置
  local result=getModule("battleExtend"):getEntryPositionBySlot(battleIndex,returnSlot)
   if range==0 then
    return result
   end
   if range==1 then
    return result+20
   end
   return result
end)
-- NOTE 获取死亡人物
local findDeadPlayer=_.wrap(getTargetWithRange23,function(func,side,battleIndex,range) 
  local isRange23 = func(side,range)
  if isRange23~=nil then
    return isRange23
  end
  local returnSlot;
  
  for slot = side*10+0,side*10+9 do
    local charIndex = Battle.GetPlayer(battleIndex, slot) 

    if charIndex>=0 and Char.GetData(charIndex,CONST.CHAR_战死)==1 and Char.GetData(charIndex,CONST.CHAR_类型)== CONST.对象类型_人 then
      
      returnSlot =slot
    end
  end
  -- 获得真实位置
  local result=getModule("battleExtend"):getEntryPositionBySlot(battleIndex,returnSlot)
  if range==0 then
  return result
  end
  if range==1 then
  return result+20
  end
  return result
end)

-- NOTE 获取战死单位
local findDeadUnit = _.wrap(getTargetWithRange23,function(func,side,battleIndex,range) 
  local isRange23 = func(side,range)
  if isRange23~=nil then
    return isRange23
  end
 
  local slotTable = {}
  for slot = side*10+0,side*10+9 do
    local charIndex = Battle.GetPlayer(battleIndex, slot) 
    if charIndex>=0 and Char.GetData(charIndex,CONST.CHAR_战死)==1 then
      table.insert(slotTable,slot)
    end
  end
  local returnSlot = slotTable[NLG.Rand(1,#slotTable)]
  -- 获得真实位置
  local result=getModule("battleExtend"):getEntryPositionBySlot(battleIndex,returnSlot)
  if range==0 then
  return result
  end
  if range==1 then
  return result+20
  end
  return result
end)

-- NOTE 随机异常单位
local randStatusUnit = _.wrap(getTargetWithRange23,function(func,side,battleIndex,range)
  local isRange23 = func(side,range)
  if isRange23~=nil then
    return isRange23
  end

  local slotTable = {}
  
  for slot = side*10+0,side*10+9 do
    local charIndex = Battle.GetPlayer(battleIndex, slot) 
    if charIndex>=0 then
      if (Char.GetData(charIndex,CONST.CHAR_BattleModPoison)>1 or 
      Char.GetData(charIndex,CONST.CHAR_BattleModSleep)>1 or 
      Char.GetData(charIndex,CONST.CHAR_BattleModStone)>1 or 
      Char.GetData(charIndex,CONST.CHAR_BattleModDrunk)>1 or 
      Char.GetData(charIndex,CONST.CHAR_BattleModConfusion)>1 or 
      Char.GetData(charIndex,CONST.CHAR_BattleModAmnesia)>1 )  then
        table.insert(slotTable,slot)
      end
    end
   
  end
  local returnSlot = slotTable[NLG.Rand(1,#slotTable)]
  -- 获得真实位置
  local result=getModule("battleExtend"):getEntryPositionBySlot(battleIndex,returnSlot)
  if range==0 then
    return result
  end
  if range==1 then
    return result+20
  end
  return result

end)


-- SECTION 目标
module.target={
  -- NOTE 0  己方自身
  ["0"]={
    comment="自身",
    fn=function(charIndex,side,battleIndex,slot,range)  return slot end
  },
  -- NOTE 1 己方阵营 随机
  ["1"]={
    comment="己方随机单位",
    fn=function(charIndex,side,battleIndex,slot,range)  return randomTarget(side,battleIndex,range) end
  },
  -- NOTE 2 对方阵营 随机
  ["2"]={
    comment="对方随机单位",
    fn=function(charIndex,side,battleIndex,slot,range)  return randomTarget(oppositeSide(side),battleIndex,range) end
  },
  -- NOTE 3 己方血最多的
  ["3"]={
    comment="己方血最多的",
    fn=function(charIndex,side,battleIndex,slot,range)  return findMostHp(side,battleIndex,range) end
  },
  -- NOTE 对方血最多的
  ["4"]={
    comment="对方血最多的",
    fn=function(charIndex,side,battleIndex,slot,range)  return findMostHp(oppositeSide(side),battleIndex,range) end
  },
  -- NOTE 己方血最少的
  ["5"]={
    comment="己方血最少的",
    fn=function(charIndex,side,battleIndex,slot,range)  return findLeastHp(side,battleIndex,range) end
  },
  -- NOTE 对方血最少的
  ["6"]={
    comment="对方血最少的",
    fn=function(charIndex,side,battleIndex,slot,range)  return findLeastHp(oppositeSide(side),battleIndex,range) end
  },
  -- NOTE 己方血量占比最低
  ["7"]={
    comment="己方血量占比最低",
    fn=function(charIndex,side,battleIndex,slot,range)  return findLeastHpRatio(side,battleIndex,range) end
  },
  -- NOTE 对方血量占比最低
  ["8"]={
    comment="对方血量占比最低",
    fn=function(charIndex,side,battleIndex,slot,range)  return findLeastHpRatio(oppositeSide(side),battleIndex,range) end
  },
  -- NOTE 己方随机玩家单位
  ["44"]={
    comment="己方随机人物",
    fn=function(charIndex,side,battleIndex,slot,range)  return findRandomPlayer(side,battleIndex,range) end
  },
  -- NOTE 己方随机宠物单位
  ["45"]={
    comment="己方随机宠物",
    fn=function(charIndex,side,battleIndex,slot,range)  return findRandomPet(side,battleIndex,range) end
  },
  -- NOTE 己方随机战死人物
  ["46"]={
    comment="己方战死人物",
    fn=function(charIndex,side,battleIndex,slot,range)  return findDeadPlayer(side,battleIndex,range) end
  },
  -- NOTE 己方随机战死单位
  ["47"]={
    comment="己方随机战死单位",
    fn=function(charIndex,side,battleIndex,slot,range)  return findDeadUnit(side,battleIndex,range) end
  },
  -- NOTE 己方随机异常单位
  ["48"]={
    comment="己方随机异常单位",
    fn=function(charIndex,side,battleIndex,slot,range)  return randStatusUnit(side,battleIndex,range) end
  },
}
-- !SECTION 

-- NOTE 计算出行为数据
-- params: charIndex：自己的index, side：自己的side， battleIndex, slot：自己的slot， 
-- commands：ai指令数组
-- return: {com1, targetSlot, techId}
function module:calcActionData(charIndex,side,battleIndex,slot,commands)
  -- print("开始",JSON.stringify(commands),charIndex)
  -- print("参数：",charIndex,side,battleIndex,slot,commands)
  for i = 1,#commands do
    local command = commands[i]
    local conditionId = command[1]
    local targetId=command[2]
    local techId = tonumber(command[3])
    
    -- 是否满足 condition
    local conditionFn = self.conditions[tostring(conditionId)]["fn"]
    -- print("开始计算条件", techId)
    if conditionFn(charIndex,side,battleIndex) then

      local fp=0
      if techId == -100 or techId ==-200 then
        fp=0
      else
        local techIndex = Tech.GetTechIndex(techId)
        fp=Tech.GetData(techIndex, CONST.TECH_FORCEPOINT) 
      end
      
      local mp = Char.GetData(charIndex,CONST.CHAR_魔)
      -- print("魔fp,mp:",charIndex,fp,mp)
      if fp>mp then
        print("command:","条件满足，但魔不足，转普攻")
        return {CONST.BATTLE_COM.BATTLE_COM_ATTACK, self.target["6"]["fn"](charIndex,side,battleIndex,slot,0), -1}
      end
      -- 获取 range
      -- 使用了 Underscore 中的 detect 函数来寻找一个符合条件的元素。
      -- 它传入了一个列表 skillInfo.params 和一个匿名函数作为条件判断。
      -- 函数通过判断当前元素是否符合查找条件，如果符合，则返回该元素。
      -- 在这个例子中，函数会根据技能 ID 来查找相应的技能信息。
      local techInfo = _.detect(skillInfo.params,function(item) 
        local ids=item[2]
        if type(ids) == 'number' and ids==techId then
          return true 
        elseif type(ids) == 'table' then
          if techId >= ids[1] and techId<= ids[2] then
            return true
          end
        end
        return false
      end)
      
      if techInfo ~=nil then
        print("command:",JSON.stringify(command),"满足！")
        local range=techInfo[4]
        local com1 = techInfo[1]
        local target=self.target[tostring(targetId)]["fn"](charIndex,side,battleIndex,slot,range)
        if techId == -100 or techId == -200 then
          techId=-1
        end
        
        return {com1,target,techId}
      end
      print("command:",JSON.stringify(command),"condition满足，技能未找到")
    end
    print("command:",JSON.stringify(command),"condition未满足")
  end
  local target = randomTarget(oppositeSide(side),battleIndex,0)
  -- 条件不满足 释放默认技能，目标随机
  print("ai 所有条件未满足")
  return {CONST.BATTLE_COM.BATTLE_COM_ATTACK, randomTarget(oppositeSide(side),battleIndex,0), -1}
end

-- ANCHOR 加载数据 heresAI.txt
function module:loadData()
  count = 0;
  aiData={}
  file = io.open('lua/Modules/heroesAI.txt')
  for line in file:lines() do
    if line then
      --%s 表示空白字符（空格、制表符、换行符等）。
      --^ 表示字符串的开头。
      --$ 表示字符串的结尾。
      --表示前面的字符可以重复任意次（包括0次）。
      --表示前面的字符可以重复至少一次。
      --. 表示任意一个字符。
      --% 用于转义其他元字符或特殊字符。
      if string.match(line, '^%s*#') then
        goto continue;
      end
      -- 对当前行的数据进行处理，将其按照制表符分隔并存储在一个table中
      --\t* 表示匹配行首的制表符，可能会有多个。
      --\r[^\n]*$表示匹配一个\r后面跟着0个或多个非\n字符（即不是换行符），
      --然后是行尾的位置$。这个模式是用来匹配Windows格式的行尾\r\n中的\r的。
      --如果是Unix和Linux格式的行尾\n，则只需要匹配\n即可
      local data = string.split(string.gsub(line, "\t*\r[^\n]*$", ""), '\t');
      --数组存在且元素数量大于等于4
      if data and #data >=4 then
        local id = tonumber(data[1])
        local name = data[2]
        local npcNo = data[3]
        
        local level = tonumber(data[4])
        local type = tonumber(data[5])
        local jobAncestry = tonumber(data[6])
        -- if npcNo~='1' then
        --   goto continue;
        -- end
        local commands = _(data):chain():rest(7):map(function(c) return string.split(c, ',')  end):value()
        table.insert(aiData,{id=id,name=name,commands=commands,type=type,level=level,npcNo=npcNo,jobAncestry=jobAncestry})
        count = count + 1;
      end
    end
    ::continue::
  end
  self:logInfo('loaded heroesAI', count);
  file:close();
  --[[
  for i, v in ipairs(aiData) do
    self:logInfo(string.format('AI数据：[id=%s, name=%s, level=%s, type=%s, npcNo=%s, jobAncestry=%s]',
      v.id, v.name, v.level, v.type, v.npcNo, v.jobAncestry))
  end
  ]]

  return aiData;
end



-- SECTION 英雄AInpc
-- NOTE 窗口流程控制
function module:AINpcTalked(npc, charIndex, seqno, select, data)
  -- print(npc, charIndex, seqno, select, data)
  data=tonumber(data)
  if select == CONST.BUTTON_关闭 then
    self:logInfo('选择了 关闭', select);
    return ;
  end
  -- NOTE  1 英雄列表
  if seqno== 1 and data>0 then
    self:logInfo('data value', data);
    self:logInfo('执行本模块函数 showChooseType 1089');
    self:showChooseType(charIndex,data)
  end
  --  NOTE  2 选择Ai
  if seqno==2  then
    -- 选择的是上一页 下一页
    if data<0 then
      local page;
      if select == 32 then
        self:logInfo('选择了 下一步 值为：', select);
        page =  sgModule:get(charIndex,"statusPage")+1
        self:logInfo('当前页面+1后，值为：', page);
      elseif select == 16 then
        self:logInfo('选择了上一步 值为：', select);
        page =  sgModule:get(charIndex,"statusPage")-1
        self:logInfo('当前页面-1，值为', page);
      end
      if page ==0 then
        -- 返回上一级
        self:logInfo('回到第一页', page);
        self:showChooseType(charIndex,nil,sgModule:get(charIndex,"heroSelected4AI"))
        return
      end
      sgModule:set(charIndex,"statusPage",page)
      self:showAIList(charIndex,page)
    else
      self:showAIComment(charIndex,data)
    end
  end
  -- NOTE 3 AI说明
  if seqno==3 then
    if select == CONST.BUTTON_确定 then
      self:showCampHeroSkillSlot(charIndex,data)
    end
  end
  -- NOTE  4 技能选择完
  if seqno== 4 and data>0 then
    self:getAI(charIndex,data)
  end
  -- NOTE 5 选择类型
  if seqno==5 then
    if data<0 then
    else
      self:toShowAiList(charIndex,data)
    end
  end
end
-- NOTE 英雄选择 首页 seqno:1
function module:showAINpcHome(npc,charIndex)

  local windowStr = heroesFn:buildCampHeroesList(charIndex)
  NLG.ShowWindowTalked(charIndex, self.AINpc, CONST.窗口_选择框, CONST.BUTTON_关闭, 1,windowStr);
end

-- NOTE 选择宠物还是英雄 seqno:5
function module:showChooseType(charIndex,data,heroData)
  if data~= nil and heroData == nil then
    self:logInfo('data不为空 执行herosfn.getcampheroesdata charindex 737');
    local campHeroes = heroesFn:getCampHeroesData(charIndex)
    heroData = campHeroes[data]
    sgModule:set(charIndex,"heroSelected4AI",heroData)
  elseif data== nil and heroData ~= nil then
    sgModule:set(charIndex,"heroSelected4AI",heroData)
  end

  local items={"我要选英雄AI","我要选宠物AI",}
 
  local title="   请选择一个AI类型"
  local windowStr=  self:NPC_buildSelectionText(title,items);
  NLG.ShowWindowTalked(charIndex, self.AINpc, CONST.窗口_选择框, CONST.BUTTON_上取消,5,windowStr);

end

-- NOTE 显示AI列表
function module:toShowAiList(charIndex,data)
  sgModule:set(charIndex,"chartypeSelected4AI",data-1)
  local heroData = sgModule:get(charIndex,"heroSelected4AI")
  local heroLevel =Char.GetData(heroData.index,CONST.CHAR_等级)
  --这个回调函数会返回一个布尔值，表示这个 AI 是否符合筛选条件。
  --具体来说，返回值为 true 当且仅当以下三个条件都满足：
  --
  --ai.type 等于 data-1，也就是等于当前选择的 AI 类型。
  --isLevelQualified 为 true，也就是等级限制满足。
  --isJobQualified 为 true，也就是职业限制满足。
  local itemsData=_.select(self.aiData,function(ai) 
    local levelRequired= ai.level
    
    local isLevelQualified=true;
    local isJobQualified =true;
    local heroJobAncestry = Char.GetData(heroData.index,CONST.CHAR_职类ID)
    --对 heroLevel 进行整除10的运算，再向下取整得到商（去除小数部分），然后再加1。
    if (math.floor(heroLevel/10)+1) < levelRequired then
      isLevelQualified=false
    end
    if heroJobAncestry~= ai.jobAncestry and ai.jobAncestry >=0 then
      isJobQualified = false
    end

    return ai.type==(data-1) and isLevelQualified and isJobQualified
    
  end)
  local items=_.map(itemsData,function(ai) return ai.name end)
  
  sgModule:set(charIndex,"aiDataList4AI",itemsData)
  sgModule:set(charIndex,"statusPage",1)
  self:showAIList(charIndex,1)

end
-- NOTE 显示AI列表 seqno:2
--首先，获取之前通过 toShowAiList 函数保存在 sgModule 模块中的 aiDataList4AI 数据，
--这个数据包含了可以使用的AI列表。然后，将这个列表转换成一个只包含AI名称的新列表 items。
--接着，使用 dynamicListData 函数生成一个游戏界面上的列表窗口，
--窗口中包含了 items 列表中的所有AI名称。列表窗口的标题是 "请选择一个AI，查看说明"。--
--dynamicListData 函数返回两个值：buttonType 和 windowStr，它们用于显示游戏界面上的窗口。
--最后，使用 NLG.ShowWindowTalked 函数显示列表窗口。
--其中，NLG.ShowWindowTalked 函数是游戏开发框架中的一个函数，用于在游戏界面上显示各种窗口和对话框。
function module:showAIList(charIndex,page)
  local itemsData=sgModule:get(charIndex,"aiDataList4AI")
  local items=_.map(itemsData,function(ai) return ai.name end)
  local title="   请选择一个AI，查看说明"
  local buttonType,windowStr=self:dynamicListData(items,title,page)
 
  NLG.ShowWindowTalked(charIndex, self.AINpc, CONST.窗口_选择框, buttonType,2,windowStr);
end
-- NOTE 动态列表数据生成
function module:dynamicListData(list,title,page)
 
  page = page or 1 ;
  --start_index 表示动态列表中当前页码对应的起始索引位置，
  --其中 (page-1)*8 计算的是前面所有页码所占用的索引位置，再加上 1 就是当前页码的起始索引位置。
  --
  --假设一页显示8个列表项，那么第1页的起始索引位置就是 1，
  --第2页的起始索引位置就是 9，第3页的起始索引位置就是 17，以此类推。
  local start_index = (page-1)*8+1
  --这行代码是用来计算列表可以分成多少页的，其中 #list 是列表的长度，
  --除以 8 是因为我们规定每页显示8个选项。
  --math.modf() 函数会返回两个值，第一个值是整除后的结果，第二个值是余数。
  --因为如果 #list 不能整除8，那么最后一页可能只显示少于8个选项，
  --所以需要根据余数判断是否需要增加一页。最终，totalPage 变量就是列表可以分成的总页数。
  local totalPage,rest = math.modf(#list/8)
  
  if rest>0 then
    totalPage=totalPage+1
  end
  --这行代码的作用是从 list 列表中提取出从 start_index 开始的 8 个元素，返回一个新的列表。
  --也就是说，items 列表中包含 list 列表中从 start_index 开始的 8 个元素。
  local items = _.slice(list, start_index, 8)
  local windowStr = self:NPC_buildSelectionText(title,items);
  local buttonType;
  if  totalPage ==1 then
    buttonType=CONST.BUTTON_上取消
  elseif page ==1 then
    buttonType=CONST.BUTTON_上下取消
  elseif page == totalPage then
    buttonType=CONST.BUTTON_上取消
  else 
    buttonType = CONST.BUTTON_上下取消
  end
  return buttonType,windowStr
end
-- NOTE AI说明 seno:3
function module:showAIComment(charIndex,data)
  local heroData = sgModule:get(charIndex,"heroSelected4AI")
  local page = sgModule:get(charIndex,"statusPage")
  NLG.SystemMessage(charIndex, tostring(page).."页")
  local index = (page-1)*8+data

  NLG.SystemMessage(charIndex, "计算得到的index为："..tostring(index));
  local aiData=sgModule:get(charIndex,"aiDataList4AI")
  local aiDataSelected = aiData[index]

  local aiId=aiDataSelected.id
  NLG.SystemMessage(charIndex, tostring(aiId).."当前AI ID")
  sgModule:set(charIndex,"aiSelected",aiId);
  local commands =aiDataSelected.commands

  -- 判断 是否满足等级和 职业要求
  local levelRequired= aiDataSelected.level
  NLG.SystemMessage(charIndex, tostring(levelRequired).."当前AI要求等级")
  local heroLevel =Char.GetData(heroData.index,CONST.CHAR_等级)
  NLG.SystemMessage(charIndex, tostring(heroLevel).."英雄当前等级")
  NLG.SystemMessage(charIndex, tostring(heroData.index).."英雄data.index")
  local heroJobAncestry = Char.GetData(heroData.index,CONST.CHAR_职类ID)
  NLG.SystemMessage(charIndex, tostring(heroJobAncestry).."英雄职业ancestryID")
  local isLevelQualified=true;
  local isJobQualified =true;
  local warning=""
  if (math.floor(heroLevel/10)+1) < levelRequired then
    isLevelQualified=false;
    warning=warning.."英雄等级不足；"
  end
  if heroJobAncestry~= aiDataSelected.jobAncestry and aiDataSelected.jobAncestry >=0 then
    isJobQualified = false
    warning=warning.."英雄职业不符；"
  end

  local title="      AI说明\\n\\n"

  local windowStr =title.. _(commands):chain():map(function(command)
      local conditionId = command[1]
    NLG.SystemMessage(charIndex, tostring(conditionId).."conditionID")
      local targetId = command[2]
    NLG.SystemMessage(charIndex, tostring(targetId).."targetID")
      local techId = tonumber(command[3])
    NLG.SystemMessage(charIndex, tostring(techId).."技能ID")
      local techName=""
      if techId == -100 or techId == -200 then
        techName = techId ==-100 and "攻击" or "防御"
      else

        local techIndex = Tech.GetTechIndex(techId)
        NLG.SystemMessage(charIndex, tostring(techIndex).."技能Index")
        techName=Tech.GetData(techIndex, CONST.TECH_NAME)
      end
    --[[
    for k,v in pairs(self.conditions) do
      NLG.SystemMessage(charIndex, "条件ID："..k.."，条件描述："..v.comment)
    end

    for k,v in pairs(self.target) do
      NLG.SystemMessage(charIndex, "对象ID："..k.."，对象描述："..v.comment)
    end
    ]]
    str =  "如果$1"..self.conditions[tostring(conditionId)]["comment"]
      .."$0则对$1"..self.target[tostring(targetId)]["comment"].."$0释放 $1"..techName..""
      return str;
    end):join("\\n\\n"):value()
  .."\\n\\n条件判断优先级是从上至下，如果要登记，请点击确定。\n\n$6"..warning
  local buttonType = (isLevelQualified and isJobQualified) and CONST.BUTTON_确定关闭 or CONST.BUTTON_关闭
  NLG.ShowWindowTalked(charIndex, self.AINpc, CONST.窗口_巨信息框, buttonType, 3,windowStr);
end 

-- NOTE 显示英雄技能栏 seqno:3
function module:showCampHeroSkillSlot(charIndex,data)
  
  
  local heroData=  sgModule:get(charIndex,"heroSelected4AI");
  local chartype =  sgModule:get(charIndex,"chartypeSelected4AI")
  local skills 
  if chartype ==0 then
    if heroData.skills == nil then
      heroData.skills={nil,nil,nil,nil,nil,nil,nil,nil} 
    end
    skills=heroData.skills
  else
    if heroData.petSkills == nil then
      heroData.petSkills={nil,nil,nil,nil,nil,nil,nil,nil} 
    end
    skills=heroData.petSkills
  end
  
  local windowStr=heroesFn:buildCampHeroSkills(charIndex,skills)
  NLG.ShowWindowTalked(charIndex, self.AINpc, CONST.窗口_选择框, CONST.BUTTON_上取消, 4,windowStr);

end
-- NOTE 登记AI
function module:getAI(charIndex,data)
  local chartype =  sgModule:get(charIndex,"chartypeSelected4AI")
  local aiId = sgModule:get(charIndex,"aiSelected");
  local heroData=  sgModule:get(charIndex,"heroSelected4AI");
  local skills
  if chartype ==0 then
    
    skills=heroData.skills
  else
    
    skills=heroData.petSkills
  end

  
  skills[data]=aiId
  
  local name = Char.GetData(heroData.index,CONST.CHAR_名字)
  NLG.SystemMessage(charIndex,name.." AI登记成功。")
end
-- !SECTION 


--- 加载模块钩子
function module:onLoad()
  self:logInfo('load')
  self.aiData=self:loadData();
  -- print(JSON.stringify(self.aiData))
  -- 秋兔的
  --self.AINpc = self:NPC_createNormal('英雄AI', 105502, { x = 22, y = 50, mapType = 0, map = 7000, direction = 4 });
  self.AINpc = self:NPC_createNormal('英雄AI', 105502, { x = 233, y = 83, mapType = 0, map = 1000, direction = 4 });
  self:NPC_regTalkedEvent(self.AINpc, Func.bind(self.showAINpcHome, self));
  self:NPC_regWindowTalkedEvent(self.AINpc, Func.bind(self.AINpcTalked, self));

  

end

--- 卸载模块钩子
function module:onUnload()
  self:logInfo('unload')
end

return module;
