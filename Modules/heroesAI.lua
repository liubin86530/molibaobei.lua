local module = ModuleBase:createModule('heroesAI')
local _ = require "lua/Modules/underscore"
local JSON=require "lua/Modules/json"
local heroesFn = getModule("heroesFn")
local sgModule = getModule("setterGetter")
local skillInfo = dofile("lua/Modules/autoBattleParams.lua")
local function getHp(charIndex)
  return Char.GetData(charIndex,CONST.CHAR_Ѫ)
end
local function getMaxHp(charIndex)
  return Char.GetData(charIndex,CONST.CHAR_���Ѫ)
end
local function getMp(charIndex)
  return Char.GetData(charIndex,CONST.CHAR_ħ)
end
local function getMaxMp(charIndex)
  return Char.GetData(charIndex,CONST.CHAR_���ħ)
end



local function oppositeSide(side)
  if side==0 then
    return 1
  else
    return 0
  end
end

-- NOTE ѭ������ ��ü��������е�λIndex
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



-- NOTE ѭ���Է� ��öԷ������е�λIndex
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
-- NOTE �Ƿ� ����ĳ��״̬ 
--   return :true false
local function hasGotStatus(charIndex,side,battleIndex,statusKey)
  return function (charIndex,side,battleIndex) 
    local chars = getAttackerSide(charIndex,side,battleIndex)
    return _.any(chars,function(charIndex) 
      return Char.GetData(charIndex,statusKey)==1
    end)
  
  end

end

-- NOTE �����쳣������
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



-- NOTE �ж� ���� 
--   return :true false
local function livesNumEq(charIndex,side,battleIndex,num)
  return function (charIndex,side,battleIndex) 
    local chars = getAttackerSide(charIndex,side,battleIndex)
    local liveChars = _.select(chars,function(charIndex) 
      return Char.GetData(charIndex,CONST.CHAR_ս��)==0
    end)
    return #liveChars == num
  end
end
-- NOTE ��ü����������
--  return  num
local function livesNum(charIndex,side,battleIndex)

  local chars = getAttackerSide(charIndex,side,battleIndex)
  local liveChars = _.select(chars,function(charIndex) 
    return Char.GetData(charIndex,CONST.CHAR_ս��)==0
  end)
  return #liveChars
end

-- NOTE ��ü���ս����������
local function deadPlayerNum(charIndex,side,battleIndex)
  local chars = getAttackerSide(charIndex,side,battleIndex)
  local liveChars = _.select(chars,function(charIndex) 
    return Char.GetData(charIndex,CONST.CHAR_ս��)==1 and Char.GetData(charIndex,CONST.CHAR_����)==CONST.��������_��
  end)
  return #liveChars
end

-- NOTE ��ü���ս������
local function deadNum(charIndex,side,battleIndex)
  local chars = getAttackerSide(charIndex,side,battleIndex)
  local liveChars = _.select(chars,function(charIndex) 
    return Char.GetData(charIndex,CONST.CHAR_ս��)==1
  end)
  return #liveChars
end


-- NOTE ��öԷ�����
--  return  num
local function livesDefNum(charIndex,side,battleIndex)

  local chars = getDeffenderSide(charIndex,side,battleIndex)
  local liveChars = _.select(chars,function(charIndex) 
    return Char.GetData(charIndex,CONST.CHAR_ս��)==0
  end)
  return #liveChars

end


-- NOTE ��� ƽ���ȼ�
--  return num
local function averageLevel(charIndexTable)
  local totalLevel = _.reduce(charIndexTable,0, function(count, charIndex) 
    local level = Char.GetData(charIndex,CONST.CHAR_�ȼ�)
    return count+level
  end)
  return totalLevel/#charIndexTable
end

-- NOTE ���� hp < x �ĳ���  y��
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
-- SECTION ����
module.conditions={
  -- NOTE ���� �������ͷ�
  ['0']= {
    comment="(�������ͷ�)",
    fn=function(charIndex) return true end
  },
  -- NOTE ����hp =100%
  ['4']={
    comment="����hp=100%",
    fn=function(charIndex) return getHp(charIndex)==getMaxHp(charIndex) end
  } ,
  -- NOTE ����hp > 75%
  ['5']= {
    comment="����hp>75%",
    fn=function(charIndex) return getHp(charIndex)/getMaxHp(charIndex)>0.75 end
  },
  -- NOTE ����hp > 50%
  ['6']= {
    comment="����hp>50%",
    fn=function(charIndex) return getHp(charIndex)/getMaxHp(charIndex)>0.5 end
  },
  -- NOTE ����hp < 50%
  ['7']= {
    comment="����hp<50%",
    fn=function(charIndex) return getHp(charIndex)/getMaxHp(charIndex)<0.5 end
  },
  -- NOTE ����hp < 25%
  ['8']={
    comment="����hp<30%",
    fn=function(charIndex) return getHp(charIndex)/getMaxHp(charIndex)<0.3 end
  } ,
  -- NOTE ���� mp>=0.5
  ['9']= {
    comment="����mp>=50%",
    fn=function(charIndex) return getMp(charIndex)/getMaxMp(charIndex)>=0.5 end
  },
  -- NOTE ����mp<50%
  ['10']={
    comment="����mp<50%",
    fn=function(charIndex) return getMp(charIndex)/getMaxMp(charIndex)<0.5 end
  } ,

  -- NOTE ������Ӫ�����ж���λ
  ["13"]={
    comment="�������ж���λ",
    fn=hasGotStatus(CONST.CHAR_BattleModPoison )
  } ,
  -- NOTE ������Ӫ���л��ҵ�λ
  ["14"]= {
    comment="�����л��ҵ�λ",
    fn=hasGotStatus(CONST.CHAR_BattleModConfusion )
  } ,
  -- NOTE ������Ӫ����ʯ����λ
  ["15"]= {
    comment="������ʯ����λ",
    fn=hasGotStatus(CONST.CHAR_BattleModStone )
  } ,
  -- NOTE ������Ӫ����˯�ߵ�λ
  ["16"]= {
    comment="������˯�ߵ�λ",
    fn=hasGotStatus(CONST.CHAR_BattleModSleep )
  },
  -- NOTE ������Ӫ���о���λ
  ["17"]= {
    comment="�����о���λ",
    fn=hasGotStatus(CONST.CHAR_BattleModDrunk )
  },
  -- NOTE ������Ӫ����������λ
  ["18"]={
    comment="������������λ",
    fn=hasGotStatus(CONST.CHAR_BattleModAmnesia )
  } ,
  -- NOTE ������Ӫ�д������0
  ["19"]={
    comment="�������Ϊ0",
    fn=livesNumEq(charIndex,side,battleIndex,0)
  } ,
  -- NOTE ������Ӫ�д������1
  ["20"]= {
    comment="�������Ϊ1",
    fn=livesNumEq(charIndex,side,battleIndex,1)
  },
  -- NOTE ������Ӫ�д������2
  ["21"]= {
    comment="�������Ϊ1",
    fn=livesNumEq(charIndex,side,battleIndex,2)
  },
  -- NOTE ������Ӫ�д������ ==10
  ["22"]= {
    comment="�������Ϊ10",
    fn=livesNumEq(charIndex,side,battleIndex,10)
  },
  -- NOTE ������Ӫ�д������>=8
  ["23"]={
    comment="�������>=8",
    fn=function(charIndex,side,battleIndex)  return livesNum(charIndex,side,battleIndex) >=8  end
  } ,
  -- NOTE ������Ӫ�д������>=5
  ["24"]= {
    comment="�������>=5",
    fn=function(charIndex,side,battleIndex)  return livesNum(charIndex,side,battleIndex) >=5  end
  },
  -- NOTE ������Ӫ�д������<5
  ["25"]={
    comment="�������<5",
    fn=function(charIndex,side,battleIndex)  return livesNum(charIndex,side,battleIndex) <5  end
  } ,
  -- NOTE ������Ӫ�д������<4
  ["26"]= {
    comment="�������<4",
    fn=function(charIndex,side,battleIndex)  return livesNum(charIndex,side,battleIndex) <4  end
  } ,
  -- NOTE ������Ӫ�д������<=1
  ["27"]= {
    comment="�������<=1",
    fn=function(charIndex,side,battleIndex)  return livesNum(charIndex,side,battleIndex) <=1  end
  },
  -- NOTE ����ƽ���ȼ� < �з�
  ["29"]={
    comment="����ƽ���ȼ�<�з�",
    fn=function(charIndex,side,battleIndex)  return averageLevel(getAttackerSide(charIndex,side,battleIndex))< averageLevel(getDeffenderSide(charIndex,side,battleIndex)) end
  } ,
  -- NOTE ����ƽ���ȼ� >= �з�
  ["30"]={
    comment="����ƽ���ȼ�>=�з�",
    fn=function(charIndex,side,battleIndex)  return averageLevel(getAttackerSide(charIndex,side,battleIndex)) >= averageLevel(getDeffenderSide(charIndex,side,battleIndex))  end
  } ,
  -- NOTE �Է�ĳһ��λhp ==100%
  ["31"]={
    comment="�Է�ĳ��λhp=100%",
    fn= function(charIndex,side,battleIndex) 
          local defChars = getDeffenderSide(charIndex,side,battleIndex)
          return _.any(defChars,function(charIndex) 
            return Char.GetData(charIndex,CONST.CHAR_Ѫ)/Char.GetData(charIndex,CONST.CHAR_���Ѫ) ==1
          end)
        end
  },
  -- NOTE �Է� ĳһ��λhp >75%
  ["32"]={
    comment="�Է�ĳ��λhp>75%",
    fn= function(charIndex,side,battleIndex) 
          local defChars = getDeffenderSide(charIndex,side,battleIndex)
          return _.any(defChars,function(charIndex) 
            return Char.GetData(charIndex,CONST.CHAR_Ѫ)/Char.GetData(charIndex,CONST.CHAR_���Ѫ) > 0.75
          end)
        end
  },
  -- NOTE �Է� ĳһ��λhp >50%
  ["33"]={
    comment="�Է�ĳ��λhp>50%",
    fn= function(charIndex,side,battleIndex) 
          local defChars = getDeffenderSide(charIndex,side,battleIndex)
          return _.any(defChars,function(charIndex) 
            return Char.GetData(charIndex,CONST.CHAR_Ѫ)/Char.GetData(charIndex,CONST.CHAR_���Ѫ) > 0.5
          end)
        end
  },
  -- NOTE �Է� ĳһ��λhp <50%
  ["34"]={
    comment="�Է�ĳ��λhp<50%",
    fn= function(charIndex,side,battleIndex) 
        local defChars = getDeffenderSide(charIndex,side,battleIndex)
        
        return _.any(defChars,function(charIndex) 
          return Char.GetData(charIndex,CONST.CHAR_Ѫ)/Char.GetData(charIndex,CONST.CHAR_���Ѫ) < 0.5
        end)
      end
  },
  -- NOTE �Է� ĳһ��λhp <25%
  ["35"]={
    comment="�Է�ĳ��λhp<25%",
    fn= function(charIndex,side,battleIndex) 
          local defChars = getDeffenderSide(charIndex,side,battleIndex)
          return _.any(defChars,function(charIndex) 
            return Char.GetData(charIndex,CONST.CHAR_Ѫ)/Char.GetData(charIndex,CONST.CHAR_���Ѫ) < 0.25
          end)
        end
  },
  -- NOTE �����غ�
  ['55']={
    comment="�����غ�",
    fn=function(charIndex,side,battleIndex) return math.fmod(Battle.GetTurn(battleIndex)+1,2) == 1 end
  },
  -- NOTE ż���غ�
  ['56']={
    comment="ż���غ�",
    fn=function(charIndex,side,battleIndex) return math.fmod(Battle.GetTurn(battleIndex)+1,2) == 0 end
  },
  -- NOTE ���2�غ�
  ['57']={
    comment="�����2�غ�",
    fn=function(charIndex,side,battleIndex) return math.fmod(Battle.GetTurn(battleIndex),2)  == 0 end
  },
  -- NOTE ���3�غ�
  ['58']={
    comment="�����3�غ�",
    fn=function(charIndex,side,battleIndex) return math.fmod(Battle.GetTurn(battleIndex),3)  == 0 end
  },
  -- NOTE ���4�غ�
  ['59']={
    comment="�����4�غ�",
    fn=function(charIndex,side,battleIndex) return math.fmod(Battle.GetTurn(battleIndex),4)  == 0 end
  },
  -- NOTE ���5�غ�
  ['60']={
    comment="�����5�غ�",
    fn=function(charIndex,side,battleIndex) return math.fmod(Battle.GetTurn(battleIndex),5)  == 0 end
  },
  -- NOTE ���6�غ�
  ['61']={
    comment="�����6�غ�",
    fn=function(charIndex,side,battleIndex) return math.fmod(Battle.GetTurn(battleIndex),6)  == 0 end
  },
  -- NOTE ���7�غ�
  ['62']={
    comment="�����7�غ�",
    fn=function(charIndex,side,battleIndex) return math.fmod(Battle.GetTurn(battleIndex),7)  == 0 end
  },
  -- NOTE ���8�غ�
  ['63']={
    comment="�����8�غ�",
    fn=function(charIndex,side,battleIndex) return math.fmod(Battle.GetTurn(battleIndex),8)  == 0 end
  },
  -- NOTE �Է�ֻ��һ�����
  ["82"]= {
    comment="�Է�ֻ��һ�����",
    fn=function(charIndex,side,battleIndex)  return livesDefNum(charIndex,side,battleIndex) ==1  end
  } ,
  -- NOTE �Է���� >1
  ["83"]={
    comment="�Է������>1",
    fn=function(charIndex,side,battleIndex)  return livesDefNum(charIndex,side,battleIndex) >1  end
  } ,
  -- NOTE �Է���� >2
  ["84"]={
    comment="�Է������>2",
    fn=function(charIndex,side,battleIndex)  return livesDefNum(charIndex,side,battleIndex) >2  end
  } ,
  -- NOTE �Է���� >3
  ["85"]={
    comment="�Է������>3",
    fn=function(charIndex,side,battleIndex)  return livesDefNum(charIndex,side,battleIndex) >3  end
  } ,
  -- NOTE �Է���� >5
  ["86"]={
    comment="�Է������>5",
    fn=function(charIndex,side,battleIndex)  return livesDefNum(charIndex,side,battleIndex) >5  end
  } ,


  -- NOTE ��һ�غ�
  ["89"]={
    comment="�ǵ�һ�غ�",
    fn=function(charIndex,side,battleIndex) return Battle.GetTurn(battleIndex) == 0 end
  } ,


  -- --  ���� mp<0.25
  -- ['90']= function(charIndex) return getMp(charIndex)/getMaxMp(charIndex)<0.25 end,
  -- --  ���� mp<0.15
  -- ['91']= function(charIndex) return getMp(charIndex)/getMaxMp(charIndex)<0.15 end,
  -- --  ���� mp<0.05
  -- ['92']= function(charIndex) return getMp(charIndex)/getMaxMp(charIndex)<0.05 end,
  -- NOTE ����HP<50%����5��
  ["93"]={
    comment="����HP<50%����5��",
    fn=function(charIndex,side,battleIndex) return partyLowerHPNum(charIndex,side,battleIndex,0.5,5) end
  } ,
  -- NOTE ����HP<50%����4��
  ["94"]={
    comment="����HP<50%����4��",
    fn=function(charIndex,side,battleIndex) return partyLowerHPNum(charIndex,side,battleIndex,0.5,4) end
  } ,
  -- NOTE ����HP<75%����5��
  ["95"]={
    comment="����HP<75%����5��",
    fn=function(charIndex,side,battleIndex) return partyLowerHPNum(charIndex,side,battleIndex,0.75,5) end
  } ,
  -- NOTE ����HP<75%����4��
  ["96"]={
    comment="����HP<75%����4��",
    fn=function(charIndex,side,battleIndex) return partyLowerHPNum(charIndex,side,battleIndex,0.75,4) end
  } ,
  -- NOTE ����������ս��
  ["97"]={
    comment="����������ս��",
    fn=function(charIndex,side,battleIndex) return deadPlayerNum(charIndex,side,battleIndex)>=1 end
  } ,
  ["98"]={
    comment="�����е�λս��",
    fn=function(charIndex,side,battleIndex) return deadNum(charIndex,side,battleIndex)>=1 end
  } ,
  -- NOTE �Է���� <=8
  ["99"]={
    comment="�Է������<=8",
    fn=function(charIndex,side,battleIndex)  return livesDefNum(charIndex,side,battleIndex) <=8  end
  } ,
  -- NOTE �Է���� <=5
  ["100"]={
    comment="�Է������<=5",
    fn=function(charIndex,side,battleIndex)  return livesDefNum(charIndex,side,battleIndex) <=5  end
  } ,
  -- NOTE �Է���� <=4
  ["101"]={
    comment="�Է������<=4",
    fn=function(charIndex,side,battleIndex)  return livesDefNum(charIndex,side,battleIndex) <=4  end
  } ,
  -- NOTE �Է���� <=3
  ["102"]={
    comment="�Է������<=3",
    fn=function(charIndex,side,battleIndex)  return livesDefNum(charIndex,side,battleIndex) <=3  end
  } ,
  -- NOTE �Է���� <=2
  ["103"]={
    comment="�Է������<=2",
    fn=function(charIndex,side,battleIndex)  return livesDefNum(charIndex,side,battleIndex) <=2  end
  } ,
  -- NOTE �Է���� <=1
  ["104"]={
    comment="�Է������<=1",
    fn=function(charIndex,side,battleIndex)  return livesDefNum(charIndex,side,battleIndex) <=1  end
  } ,
  --NOTE ����HP<30%����0��
  ["105"]={
    comment="����HP<30%>=1��",
    fn=function(charIndex,side,battleIndex) return partyLowerHPNum(charIndex,side,battleIndex,0.3,0) end
  } ,
  --NOTE ����HP<40%����0��
  ["106"]={
    comment="����HP<40%>=1��",
    fn=function(charIndex,side,battleIndex) return partyLowerHPNum(charIndex,side,battleIndex,0.4,0) end
  } ,
  --NOTE ����HP<40%����3��
  ["107"]={
    comment="����HP<40%>=2��",
    fn=function(charIndex,side,battleIndex) return partyLowerHPNum(charIndex,side,battleIndex,0.4,2) end
  } ,
  -- NOTE �������쳣����>=1
  ['201']={
    comment="�������쳣����>=1",
    fn=function(charIndex,side,battleIndex)  return gotAnyStatusNum(charIndex,side,battleIndex) >=1  end
  } ,
  -- NOTE �������쳣����>=3
  ['202']={
    comment="�������쳣����>=3",
    fn=function(charIndex,side,battleIndex)  return gotAnyStatusNum(charIndex,side,battleIndex) >=3  end
  } ,
  -- NOTE �������쳣����>=5
  ['203']={
    comment="�������쳣����>=5",
    fn=function(charIndex,side,battleIndex)  return gotAnyStatusNum(charIndex,side,battleIndex) >=5  end
  } ,
}
-- !SECTION 


-- NOTE target ��ȡ���� �ж� range Ϊ 2��3 �����
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



-- NOTE ���Ŀ��
-- side 0 ���·��� 1 ���Ϸ�
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
  -- �����ʵλ��
  local result=getModule("battleExtend"):getEntryPositionBySlot(battleIndex,randomSlot)
  if range==0 then
  return result
  end
  if range==1 then
  return result+20
  end
  return result
end)



-- NOTE Ѫ����
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
      local hp = Char.GetData(charIndex,CONST.CHAR_Ѫ)
      if tagHp==nil then
        tagHp=hp
        returnSlot= slot
      elseif hp>tagHp then
        tagHp=hp;
        returnSlot= slot
      end
    end

  end
  -- �����ʵλ��
  local result=getModule("battleExtend"):getEntryPositionBySlot(battleIndex,returnSlot)
  if range==0 then
    return result
  end
  if range==1 then
    return result+20
  end
  return result
end)
-- NOTE Ѫ���ٵ�
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
      local hp = Char.GetData(charIndex,CONST.CHAR_Ѫ)
      if tagHp==nil then
        tagHp=hp
        returnSlot= slot
      elseif hp<tagHp then
        tagHp=hp;
        returnSlot= slot
      end
    end

  end
  -- �����ʵλ��
  local result=getModule("battleExtend"):getEntryPositionBySlot(battleIndex,returnSlot)
  if range==0 then
    return result
   end
   if range==1 then
    return result+20
   end
   return result
end)
-- NOTE Ѫ��ռ����͵�
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
  -- �����ʵλ��
  local result=getModule("battleExtend"):getEntryPositionBySlot(battleIndex,returnSlot)
  if range==0 then
    return result
   end
   if range==1 then
    return result+20
   end
   return result
end)

-- NOTE �����ҵ�λ����Ӣ�ۣ�
local findRandomPlayer =_.wrap(getTargetWithRange23,function (func,side,battleIndex,range)
  local isRange23 = func(side,range)
  if isRange23~=nil then
    return isRange23
  end
  local slotTable = {}
  
  for slot = side*10+0,side*10+9 do
    local charIndex = Battle.GetPlayer(battleIndex, slot) 
    if(charIndex>=0 and Char.GetData(charIndex,CONST.CHAR_����)== CONST.��������_��) then
      table.insert(slotTable,slot)
    end
  end
  local returnSlot = slotTable[NLG.Rand(1,#slotTable)]
  -- �����ʵλ��
  local result=getModule("battleExtend"):getEntryPositionBySlot(battleIndex,returnSlot)
  if range==0 then
  return result
  end
  if range==1 then
  return result+20
  end
  return result
end)

-- NOTE ������ﵥλ
local findRandomPet= _.wrap(getTargetWithRange23,function (func,side,battleIndex,range)
  local isRange23 = func(side,range)
  if isRange23~=nil then
    return isRange23
  end

  local slotTable = {}
  
  for slot = side*10+0,side*10+9 do
    local charIndex = Battle.GetPlayer(battleIndex, slot) 
    if(charIndex>=0 and Char.GetData(charIndex,CONST.CHAR_����)== CONST.��������_��) then
      table.insert(slotTable,slot)
    end
  end
   local returnSlot = slotTable[NLG.Rand(1,#slotTable)]
  -- �����ʵλ��
  local result=getModule("battleExtend"):getEntryPositionBySlot(battleIndex,returnSlot)
   if range==0 then
    return result
   end
   if range==1 then
    return result+20
   end
   return result
end)
-- NOTE ��ȡ��������
local findDeadPlayer=_.wrap(getTargetWithRange23,function(func,side,battleIndex,range) 
  local isRange23 = func(side,range)
  if isRange23~=nil then
    return isRange23
  end
  local returnSlot;
  
  for slot = side*10+0,side*10+9 do
    local charIndex = Battle.GetPlayer(battleIndex, slot) 

    if charIndex>=0 and Char.GetData(charIndex,CONST.CHAR_ս��)==1 and Char.GetData(charIndex,CONST.CHAR_����)== CONST.��������_�� then
      
      returnSlot =slot
    end
  end
  -- �����ʵλ��
  local result=getModule("battleExtend"):getEntryPositionBySlot(battleIndex,returnSlot)
  if range==0 then
  return result
  end
  if range==1 then
  return result+20
  end
  return result
end)

-- NOTE ��ȡս����λ
local findDeadUnit = _.wrap(getTargetWithRange23,function(func,side,battleIndex,range) 
  local isRange23 = func(side,range)
  if isRange23~=nil then
    return isRange23
  end
 
  local slotTable = {}
  for slot = side*10+0,side*10+9 do
    local charIndex = Battle.GetPlayer(battleIndex, slot) 
    if charIndex>=0 and Char.GetData(charIndex,CONST.CHAR_ս��)==1 then
      table.insert(slotTable,slot)
    end
  end
  local returnSlot = slotTable[NLG.Rand(1,#slotTable)]
  -- �����ʵλ��
  local result=getModule("battleExtend"):getEntryPositionBySlot(battleIndex,returnSlot)
  if range==0 then
  return result
  end
  if range==1 then
  return result+20
  end
  return result
end)

-- NOTE ����쳣��λ
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
  -- �����ʵλ��
  local result=getModule("battleExtend"):getEntryPositionBySlot(battleIndex,returnSlot)
  if range==0 then
    return result
  end
  if range==1 then
    return result+20
  end
  return result

end)


-- SECTION Ŀ��
module.target={
  -- NOTE 0  ��������
  ["0"]={
    comment="����",
    fn=function(charIndex,side,battleIndex,slot,range)  return slot end
  },
  -- NOTE 1 ������Ӫ ���
  ["1"]={
    comment="���������λ",
    fn=function(charIndex,side,battleIndex,slot,range)  return randomTarget(side,battleIndex,range) end
  },
  -- NOTE 2 �Է���Ӫ ���
  ["2"]={
    comment="�Է������λ",
    fn=function(charIndex,side,battleIndex,slot,range)  return randomTarget(oppositeSide(side),battleIndex,range) end
  },
  -- NOTE 3 ����Ѫ����
  ["3"]={
    comment="����Ѫ����",
    fn=function(charIndex,side,battleIndex,slot,range)  return findMostHp(side,battleIndex,range) end
  },
  -- NOTE �Է�Ѫ����
  ["4"]={
    comment="�Է�Ѫ����",
    fn=function(charIndex,side,battleIndex,slot,range)  return findMostHp(oppositeSide(side),battleIndex,range) end
  },
  -- NOTE ����Ѫ���ٵ�
  ["5"]={
    comment="����Ѫ���ٵ�",
    fn=function(charIndex,side,battleIndex,slot,range)  return findLeastHp(side,battleIndex,range) end
  },
  -- NOTE �Է�Ѫ���ٵ�
  ["6"]={
    comment="�Է�Ѫ���ٵ�",
    fn=function(charIndex,side,battleIndex,slot,range)  return findLeastHp(oppositeSide(side),battleIndex,range) end
  },
  -- NOTE ����Ѫ��ռ�����
  ["7"]={
    comment="����Ѫ��ռ�����",
    fn=function(charIndex,side,battleIndex,slot,range)  return findLeastHpRatio(side,battleIndex,range) end
  },
  -- NOTE �Է�Ѫ��ռ�����
  ["8"]={
    comment="�Է�Ѫ��ռ�����",
    fn=function(charIndex,side,battleIndex,slot,range)  return findLeastHpRatio(oppositeSide(side),battleIndex,range) end
  },
  -- NOTE ���������ҵ�λ
  ["44"]={
    comment="�����������",
    fn=function(charIndex,side,battleIndex,slot,range)  return findRandomPlayer(side,battleIndex,range) end
  },
  -- NOTE ����������ﵥλ
  ["45"]={
    comment="�����������",
    fn=function(charIndex,side,battleIndex,slot,range)  return findRandomPet(side,battleIndex,range) end
  },
  -- NOTE �������ս������
  ["46"]={
    comment="����ս������",
    fn=function(charIndex,side,battleIndex,slot,range)  return findDeadPlayer(side,battleIndex,range) end
  },
  -- NOTE �������ս����λ
  ["47"]={
    comment="�������ս����λ",
    fn=function(charIndex,side,battleIndex,slot,range)  return findDeadUnit(side,battleIndex,range) end
  },
  -- NOTE ��������쳣��λ
  ["48"]={
    comment="��������쳣��λ",
    fn=function(charIndex,side,battleIndex,slot,range)  return randStatusUnit(side,battleIndex,range) end
  },
}
-- !SECTION 

-- NOTE �������Ϊ����
-- params: charIndex���Լ���index, side���Լ���side�� battleIndex, slot���Լ���slot�� 
-- commands��aiָ������
-- return: {com1, targetSlot, techId}
function module:calcActionData(charIndex,side,battleIndex,slot,commands)
  -- print("��ʼ",JSON.stringify(commands),charIndex)
  -- print("������",charIndex,side,battleIndex,slot,commands)
  for i = 1,#commands do
    local command = commands[i]
    local conditionId = command[1]
    local targetId=command[2]
    local techId = tonumber(command[3])
    
    -- �Ƿ����� condition
    local conditionFn = self.conditions[tostring(conditionId)]["fn"]
    -- print("��ʼ��������", techId)
    if conditionFn(charIndex,side,battleIndex) then

      local fp=0
      if techId == -100 or techId ==-200 then
        fp=0
      else
        local techIndex = Tech.GetTechIndex(techId)
        fp=Tech.GetData(techIndex, CONST.TECH_FORCEPOINT) 
      end
      
      local mp = Char.GetData(charIndex,CONST.CHAR_ħ)
      -- print("ħfp,mp:",charIndex,fp,mp)
      if fp>mp then
        print("command:","�������㣬��ħ���㣬ת�չ�")
        return {CONST.BATTLE_COM.BATTLE_COM_ATTACK, self.target["6"]["fn"](charIndex,side,battleIndex,slot,0), -1}
      end
      -- ��ȡ range
      -- ʹ���� Underscore �е� detect ������Ѱ��һ������������Ԫ�ء�
      -- ��������һ���б� skillInfo.params ��һ������������Ϊ�����жϡ�
      -- ����ͨ���жϵ�ǰԪ���Ƿ���ϲ���������������ϣ��򷵻ظ�Ԫ�ء�
      -- ����������У���������ݼ��� ID ��������Ӧ�ļ�����Ϣ��
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
        print("command:",JSON.stringify(command),"���㣡")
        local range=techInfo[4]
        local com1 = techInfo[1]
        local target=self.target[tostring(targetId)]["fn"](charIndex,side,battleIndex,slot,range)
        if techId == -100 or techId == -200 then
          techId=-1
        end
        
        return {com1,target,techId}
      end
      print("command:",JSON.stringify(command),"condition���㣬����δ�ҵ�")
    end
    print("command:",JSON.stringify(command),"conditionδ����")
  end
  local target = randomTarget(oppositeSide(side),battleIndex,0)
  -- ���������� �ͷ�Ĭ�ϼ��ܣ�Ŀ�����
  print("ai ��������δ����")
  return {CONST.BATTLE_COM.BATTLE_COM_ATTACK, randomTarget(oppositeSide(side),battleIndex,0), -1}
end

-- ANCHOR �������� heresAI.txt
function module:loadData()
  count = 0;
  aiData={}
  file = io.open('lua/Modules/heroesAI.txt')
  for line in file:lines() do
    if line then
      --%s ��ʾ�հ��ַ����ո��Ʊ�������з��ȣ���
      --^ ��ʾ�ַ����Ŀ�ͷ��
      --$ ��ʾ�ַ����Ľ�β��
      --��ʾǰ����ַ������ظ�����Σ�����0�Σ���
      --��ʾǰ����ַ������ظ�����һ�Ρ�
      --. ��ʾ����һ���ַ���
      --% ����ת������Ԫ�ַ��������ַ���
      if string.match(line, '^%s*#') then
        goto continue;
      end
      -- �Ե�ǰ�е����ݽ��д������䰴���Ʊ���ָ����洢��һ��table��
      --\t* ��ʾƥ�����׵��Ʊ�������ܻ��ж����
      --\r[^\n]*$��ʾƥ��һ��\r�������0��������\n�ַ��������ǻ��з�����
      --Ȼ������β��λ��$�����ģʽ������ƥ��Windows��ʽ����β\r\n�е�\r�ġ�
      --�����Unix��Linux��ʽ����β\n����ֻ��Ҫƥ��\n����
      local data = string.split(string.gsub(line, "\t*\r[^\n]*$", ""), '\t');
      --���������Ԫ���������ڵ���4
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
    self:logInfo(string.format('AI���ݣ�[id=%s, name=%s, level=%s, type=%s, npcNo=%s, jobAncestry=%s]',
      v.id, v.name, v.level, v.type, v.npcNo, v.jobAncestry))
  end
  ]]

  return aiData;
end



-- SECTION Ӣ��AInpc
-- NOTE �������̿���
function module:AINpcTalked(npc, charIndex, seqno, select, data)
  -- print(npc, charIndex, seqno, select, data)
  data=tonumber(data)
  if select == CONST.BUTTON_�ر� then
    self:logInfo('ѡ���� �ر�', select);
    return ;
  end
  -- NOTE  1 Ӣ���б�
  if seqno== 1 and data>0 then
    self:logInfo('data value', data);
    self:logInfo('ִ�б�ģ�麯�� showChooseType 1089');
    self:showChooseType(charIndex,data)
  end
  --  NOTE  2 ѡ��Ai
  if seqno==2  then
    -- ѡ�������һҳ ��һҳ
    if data<0 then
      local page;
      if select == 32 then
        self:logInfo('ѡ���� ��һ�� ֵΪ��', select);
        page =  sgModule:get(charIndex,"statusPage")+1
        self:logInfo('��ǰҳ��+1��ֵΪ��', page);
      elseif select == 16 then
        self:logInfo('ѡ������һ�� ֵΪ��', select);
        page =  sgModule:get(charIndex,"statusPage")-1
        self:logInfo('��ǰҳ��-1��ֵΪ', page);
      end
      if page ==0 then
        -- ������һ��
        self:logInfo('�ص���һҳ', page);
        self:showChooseType(charIndex,nil,sgModule:get(charIndex,"heroSelected4AI"))
        return
      end
      sgModule:set(charIndex,"statusPage",page)
      self:showAIList(charIndex,page)
    else
      self:showAIComment(charIndex,data)
    end
  end
  -- NOTE 3 AI˵��
  if seqno==3 then
    if select == CONST.BUTTON_ȷ�� then
      self:showCampHeroSkillSlot(charIndex,data)
    end
  end
  -- NOTE  4 ����ѡ����
  if seqno== 4 and data>0 then
    self:getAI(charIndex,data)
  end
  -- NOTE 5 ѡ������
  if seqno==5 then
    if data<0 then
    else
      self:toShowAiList(charIndex,data)
    end
  end
end
-- NOTE Ӣ��ѡ�� ��ҳ seqno:1
function module:showAINpcHome(npc,charIndex)

  local windowStr = heroesFn:buildCampHeroesList(charIndex)
  NLG.ShowWindowTalked(charIndex, self.AINpc, CONST.����_ѡ���, CONST.BUTTON_�ر�, 1,windowStr);
end

-- NOTE ѡ����ﻹ��Ӣ�� seqno:5
function module:showChooseType(charIndex,data,heroData)
  if data~= nil and heroData == nil then
    self:logInfo('data��Ϊ�� ִ��herosfn.getcampheroesdata charindex 737');
    local campHeroes = heroesFn:getCampHeroesData(charIndex)
    heroData = campHeroes[data]
    sgModule:set(charIndex,"heroSelected4AI",heroData)
  elseif data== nil and heroData ~= nil then
    sgModule:set(charIndex,"heroSelected4AI",heroData)
  end

  local items={"��ҪѡӢ��AI","��Ҫѡ����AI",}
 
  local title="   ��ѡ��һ��AI����"
  local windowStr=  self:NPC_buildSelectionText(title,items);
  NLG.ShowWindowTalked(charIndex, self.AINpc, CONST.����_ѡ���, CONST.BUTTON_��ȡ��,5,windowStr);

end

-- NOTE ��ʾAI�б�
function module:toShowAiList(charIndex,data)
  sgModule:set(charIndex,"chartypeSelected4AI",data-1)
  local heroData = sgModule:get(charIndex,"heroSelected4AI")
  local heroLevel =Char.GetData(heroData.index,CONST.CHAR_�ȼ�)
  --����ص������᷵��һ������ֵ����ʾ��� AI �Ƿ����ɸѡ������
  --������˵������ֵΪ true ���ҽ��������������������㣺
  --
  --ai.type ���� data-1��Ҳ���ǵ��ڵ�ǰѡ��� AI ���͡�
  --isLevelQualified Ϊ true��Ҳ���ǵȼ��������㡣
  --isJobQualified Ϊ true��Ҳ����ְҵ�������㡣
  local itemsData=_.select(self.aiData,function(ai) 
    local levelRequired= ai.level
    
    local isLevelQualified=true;
    local isJobQualified =true;
    local heroJobAncestry = Char.GetData(heroData.index,CONST.CHAR_ְ��ID)
    --�� heroLevel ��������10�����㣬������ȡ���õ��̣�ȥ��С�����֣���Ȼ���ټ�1��
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
-- NOTE ��ʾAI�б� seqno:2
--���ȣ���ȡ֮ǰͨ�� toShowAiList ���������� sgModule ģ���е� aiDataList4AI ���ݣ�
--������ݰ����˿���ʹ�õ�AI�б�Ȼ�󣬽�����б�ת����һ��ֻ����AI���Ƶ����б� items��
--���ţ�ʹ�� dynamicListData ��������һ����Ϸ�����ϵ��б��ڣ�
--�����а����� items �б��е�����AI���ơ��б��ڵı����� "��ѡ��һ��AI���鿴˵��"��--
--dynamicListData ������������ֵ��buttonType �� windowStr������������ʾ��Ϸ�����ϵĴ��ڡ�
--���ʹ�� NLG.ShowWindowTalked ������ʾ�б��ڡ�
--���У�NLG.ShowWindowTalked ��������Ϸ��������е�һ����������������Ϸ��������ʾ���ִ��ںͶԻ���
function module:showAIList(charIndex,page)
  local itemsData=sgModule:get(charIndex,"aiDataList4AI")
  local items=_.map(itemsData,function(ai) return ai.name end)
  local title="   ��ѡ��һ��AI���鿴˵��"
  local buttonType,windowStr=self:dynamicListData(items,title,page)
 
  NLG.ShowWindowTalked(charIndex, self.AINpc, CONST.����_ѡ���, buttonType,2,windowStr);
end
-- NOTE ��̬�б���������
function module:dynamicListData(list,title,page)
 
  page = page or 1 ;
  --start_index ��ʾ��̬�б��е�ǰҳ���Ӧ����ʼ����λ�ã�
  --���� (page-1)*8 �������ǰ������ҳ����ռ�õ�����λ�ã��ټ��� 1 ���ǵ�ǰҳ�����ʼ����λ�á�
  --
  --����һҳ��ʾ8���б����ô��1ҳ����ʼ����λ�þ��� 1��
  --��2ҳ����ʼ����λ�þ��� 9����3ҳ����ʼ����λ�þ��� 17���Դ����ơ�
  local start_index = (page-1)*8+1
  --���д��������������б���Էֳɶ���ҳ�ģ����� #list ���б�ĳ��ȣ�
  --���� 8 ����Ϊ���ǹ涨ÿҳ��ʾ8��ѡ�
  --math.modf() �����᷵������ֵ����һ��ֵ��������Ľ�����ڶ���ֵ��������
  --��Ϊ��� #list ��������8����ô���һҳ����ֻ��ʾ����8��ѡ�
  --������Ҫ���������ж��Ƿ���Ҫ����һҳ�����գ�totalPage ���������б���Էֳɵ���ҳ����
  local totalPage,rest = math.modf(#list/8)
  
  if rest>0 then
    totalPage=totalPage+1
  end
  --���д���������Ǵ� list �б�����ȡ���� start_index ��ʼ�� 8 ��Ԫ�أ�����һ���µ��б�
  --Ҳ����˵��items �б��а��� list �б��д� start_index ��ʼ�� 8 ��Ԫ�ء�
  local items = _.slice(list, start_index, 8)
  local windowStr = self:NPC_buildSelectionText(title,items);
  local buttonType;
  if  totalPage ==1 then
    buttonType=CONST.BUTTON_��ȡ��
  elseif page ==1 then
    buttonType=CONST.BUTTON_����ȡ��
  elseif page == totalPage then
    buttonType=CONST.BUTTON_��ȡ��
  else 
    buttonType = CONST.BUTTON_����ȡ��
  end
  return buttonType,windowStr
end
-- NOTE AI˵�� seno:3
function module:showAIComment(charIndex,data)
  local heroData = sgModule:get(charIndex,"heroSelected4AI")
  local page = sgModule:get(charIndex,"statusPage")
  NLG.SystemMessage(charIndex, tostring(page).."ҳ")
  local index = (page-1)*8+data

  NLG.SystemMessage(charIndex, "����õ���indexΪ��"..tostring(index));
  local aiData=sgModule:get(charIndex,"aiDataList4AI")
  local aiDataSelected = aiData[index]

  local aiId=aiDataSelected.id
  NLG.SystemMessage(charIndex, tostring(aiId).."��ǰAI ID")
  sgModule:set(charIndex,"aiSelected",aiId);
  local commands =aiDataSelected.commands

  -- �ж� �Ƿ�����ȼ��� ְҵҪ��
  local levelRequired= aiDataSelected.level
  NLG.SystemMessage(charIndex, tostring(levelRequired).."��ǰAIҪ��ȼ�")
  local heroLevel =Char.GetData(heroData.index,CONST.CHAR_�ȼ�)
  NLG.SystemMessage(charIndex, tostring(heroLevel).."Ӣ�۵�ǰ�ȼ�")
  NLG.SystemMessage(charIndex, tostring(heroData.index).."Ӣ��data.index")
  local heroJobAncestry = Char.GetData(heroData.index,CONST.CHAR_ְ��ID)
  NLG.SystemMessage(charIndex, tostring(heroJobAncestry).."Ӣ��ְҵancestryID")
  local isLevelQualified=true;
  local isJobQualified =true;
  local warning=""
  if (math.floor(heroLevel/10)+1) < levelRequired then
    isLevelQualified=false;
    warning=warning.."Ӣ�۵ȼ����㣻"
  end
  if heroJobAncestry~= aiDataSelected.jobAncestry and aiDataSelected.jobAncestry >=0 then
    isJobQualified = false
    warning=warning.."Ӣ��ְҵ������"
  end

  local title="      AI˵��\\n\\n"

  local windowStr =title.. _(commands):chain():map(function(command)
      local conditionId = command[1]
    NLG.SystemMessage(charIndex, tostring(conditionId).."conditionID")
      local targetId = command[2]
    NLG.SystemMessage(charIndex, tostring(targetId).."targetID")
      local techId = tonumber(command[3])
    NLG.SystemMessage(charIndex, tostring(techId).."����ID")
      local techName=""
      if techId == -100 or techId == -200 then
        techName = techId ==-100 and "����" or "����"
      else

        local techIndex = Tech.GetTechIndex(techId)
        NLG.SystemMessage(charIndex, tostring(techIndex).."����Index")
        techName=Tech.GetData(techIndex, CONST.TECH_NAME)
      end
    --[[
    for k,v in pairs(self.conditions) do
      NLG.SystemMessage(charIndex, "����ID��"..k.."������������"..v.comment)
    end

    for k,v in pairs(self.target) do
      NLG.SystemMessage(charIndex, "����ID��"..k.."������������"..v.comment)
    end
    ]]
    str =  "���$1"..self.conditions[tostring(conditionId)]["comment"]
      .."$0���$1"..self.target[tostring(targetId)]["comment"].."$0�ͷ� $1"..techName..""
      return str;
    end):join("\\n\\n"):value()
  .."\\n\\n�����ж����ȼ��Ǵ������£����Ҫ�Ǽǣ�����ȷ����\n\n$6"..warning
  local buttonType = (isLevelQualified and isJobQualified) and CONST.BUTTON_ȷ���ر� or CONST.BUTTON_�ر�
  NLG.ShowWindowTalked(charIndex, self.AINpc, CONST.����_����Ϣ��, buttonType, 3,windowStr);
end 

-- NOTE ��ʾӢ�ۼ����� seqno:3
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
  NLG.ShowWindowTalked(charIndex, self.AINpc, CONST.����_ѡ���, CONST.BUTTON_��ȡ��, 4,windowStr);

end
-- NOTE �Ǽ�AI
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
  
  local name = Char.GetData(heroData.index,CONST.CHAR_����)
  NLG.SystemMessage(charIndex,name.." AI�Ǽǳɹ���")
end
-- !SECTION 


--- ����ģ�鹳��
function module:onLoad()
  self:logInfo('load')
  self.aiData=self:loadData();
  -- print(JSON.stringify(self.aiData))
  -- ���õ�
  --self.AINpc = self:NPC_createNormal('Ӣ��AI', 105502, { x = 22, y = 50, mapType = 0, map = 7000, direction = 4 });
  self.AINpc = self:NPC_createNormal('Ӣ��AI', 105502, { x = 233, y = 83, mapType = 0, map = 1000, direction = 4 });
  self:NPC_regTalkedEvent(self.AINpc, Func.bind(self.showAINpcHome, self));
  self:NPC_regWindowTalkedEvent(self.AINpc, Func.bind(self.AINpcTalked, self));

  

end

--- ж��ģ�鹳��
function module:onUnload()
  self:logInfo('unload')
end

return module;
