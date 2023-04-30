local module = ModuleBase:createModule('heroesFn')
local JSON=require "lua/Modules/json"
local _ = require "lua/Modules/underscore"
local sgModule = getModule("setterGetter")
local heroesTpl = dofile("lua/Modules/heroesTpl.lua")
-- local heroesAI = getModule("heroesAI")

-- NOTE ��Ӷʱ Ӣ��ͬ���ͬ�ȼ�
local syncWithPlayer=true;
--NOTE ����ӳ���ֵ�
local nameMap={
  status={
    ['1']='����',
    ['2']='����'
  },
  equipLocation={
    [tostring(CONST.EQUIP_ͷ)]="ͷ��",
    [tostring(CONST.EQUIP_��)]="����",
    [tostring(CONST.EQUIP_����)]="����",
    [tostring(CONST.EQUIP_����)]="����",
    [tostring(CONST.EQUIP_��)]="�Ȳ�",
    [tostring(CONST.EQUIP_����1)]="����1",
    [tostring(CONST.EQUIP_����2)]="����2",
    [tostring(CONST.EQUIP_ˮ��)]="ˮ��",
  }
}
-- NOTE ����ѡ��
local heroOpList=function(status) return {nameMap['status'][tostring(status)],"�鿴״̬","���"} end
-- NOTE ��Ʒ����������key
local itemFields = { }
for i = 0, 0x4b do
  table.insert(itemFields, i);
end
for i = 0, 0xd do
  table.insert(itemFields, i + 2000);
end
-- NOTE ���Ƽ۸� {min,max, �۸�}
local healPrice={
  {1,25,200},{26,50,600},{51,75,1000},{76,100,1400},
}
-- NOTE �������������key
local petFields={
CONST.CHAR_����,
CONST.CHAR_����,
CONST.CHAR_ԭ��,
CONST.CHAR_MAP,
CONST.CHAR_��ͼ,
CONST.CHAR_X,
CONST.CHAR_Y,
CONST.CHAR_����,
CONST.CHAR_�ȼ�,
CONST.CHAR_Ѫ,
CONST.CHAR_ħ,
CONST.CHAR_����,
CONST.CHAR_����,
CONST.CHAR_ǿ��,
CONST.CHAR_�ٶ�,
CONST.CHAR_ħ��,
CONST.CHAR_����,
CONST.CHAR_����,
CONST.CHAR_������,
CONST.CHAR_ˮ����,
CONST.CHAR_������,
CONST.CHAR_������,
CONST.CHAR_����,
CONST.CHAR_��˯,
CONST.CHAR_��ʯ,
CONST.CHAR_����,
CONST.CHAR_����,
CONST.CHAR_����,
CONST.CHAR_��ɱ,
CONST.CHAR_����,
CONST.CHAR_����,
CONST.CHAR_����,
CONST.CHAR_������,
CONST.CHAR_������,
CONST.CHAR_������,
CONST.CHAR_�˺���,
CONST.CHAR_ɱ����,
CONST.CHAR_ռ��ʱ��,
CONST.CHAR_����,
CONST.CHAR_�Ƽ�,
CONST.CHAR_ѭʱ,
CONST.CHAR_����,
CONST.CHAR_������,
CONST.CHAR_ͼ��,
CONST.CHAR_��ɫ,
CONST.CHAR_����,
CONST.CHAR_ԭʼͼ��,
CONST.CHAR_����,
CONST.CHAR_���Ѫ,
CONST.CHAR_���ħ,
CONST.CHAR_������,
CONST.CHAR_������,
CONST.CHAR_����,
CONST.CHAR_����,
CONST.CHAR_�ظ�,
CONST.CHAR_��þ���,
CONST.CHAR_ħ��,
CONST.CHAR_ħ��,
CONST.CHAR_EnemyBaseId,
CONST.PET_DepartureBattleStatus,
CONST.PET_PetID,
CONST.PET_������,
CONST.����_����,
CONST.����_����,
CONST.����_����,
CONST.����_����,
CONST.����_����,
CONST.����_����,
CONST.CHAR_ְҵ,
CONST.CHAR_ְ��,
CONST.CHAR_ְ��ID,
CONST.����_��ɫ,
}

-- NOTE ����ɳ�����key
local petRankFields={
CONST.PET_���,
CONST.PET_����,
CONST.PET_ǿ��,
CONST.PET_����,
CONST.PET_ħ��,
}
-- NOTE �ӵ㳣��
local pointAttrs = {
  {CONST.CHAR_����,"����"},
  {CONST.CHAR_����,"����"},
  {CONST.CHAR_ǿ��,"ǿ��"},
  {CONST.CHAR_�ٶ�,"�ٶ�"},
  {CONST.CHAR_ħ��,"ħ��"},
}
-- NOTE Ӣ���Զ��ӵ�ģʽ
local autoPointingPattern={'12010','21010','00022','10012','22000','10102','20011','20002'}
-- NOTE �����Զ��ӵ�ģʽ
local petAutoPointingPattern={'10000','01000','00100','00010','00001'}
-- NOTE ��ɫ����
local nameColorRareMap={
  ["R"]=5,
  ["SR"]=2,
  ["SSR"]=4,
  ["UR"]=6,
}

-- NOTE ����-��ʼ��Ӣ��
function module:initHeroData(toGetHeroData,charIndex)
    local tplId = toGetHeroData[1] or 1
    local name = toGetHeroData[2]
    local mainJob = toGetHeroData[4]
    local jobAncestry = toGetHeroData[5]
    local jobRank = toGetHeroData[6] 
    local image = toGetHeroData[7] or 100000
    local level = toGetHeroData[8] or 1
    local vital = toGetHeroData[9] or 0 
    local str = toGetHeroData[10] or 0 
    local tgh = toGetHeroData[11] or 0 
    local quick = toGetHeroData[12] or 0 
    local magic = toGetHeroData[13] or 0 
    local leveluppoint = toGetHeroData[14] or 0 
    local rare = toGetHeroData[15] or 'R' 
    local aiDatas = {} 
    self:deepcopy(aiDatas,toGetHeroData[18] or {})


    local petAiDatas = toGetHeroData[19] or {}
    local modValue = toGetHeroData[21] or {}
    
    if syncWithPlayer then
      local charLevel = Char.GetData(charIndex,CONST.CHAR_�ȼ�)
      local point=4*(charLevel-1);
      if rare =="SR" then
        point=30+5*(charLevel-1)
      elseif rare =="SSR" then
        point=60+6*(charLevel-1)
      elseif rare =="UR" then
        point=90+6*(charLevel-1)
      end
      leveluppoint=point
      level=charLevel
    end


    local charValue = {
      [tostring(CONST.CHAR_����)]=name,
      [tostring(CONST.CHAR_����)]=image,
      [tostring(CONST.CHAR_ԭ��)]=image,
      [tostring(CONST.CHAR_ԭʼͼ��)]=image,
      [tostring(CONST.CHAR_����)]=vital*100,
      [tostring(CONST.CHAR_����)]=str*100,
      [tostring(CONST.CHAR_ǿ��)]=tgh*100,
      [tostring(CONST.CHAR_�ٶ�)]=quick*100,
      [tostring(CONST.CHAR_ħ��)]=magic*100,
      [tostring(CONST.CHAR_�ȼ�)]=level,
      [tostring(CONST.CHAR_������)]=leveluppoint,
      [tostring(CONST.CHAR_ְҵ)]=mainJob,
      [tostring(CONST.CHAR_ְ��ID)]=jobAncestry,
      [tostring(CONST.CHAR_ְ��)]=jobRank,
      [tostring(CONST.����_��ɫ)]=nameColorRareMap[rare],
    }
    _.extend(charValue,modValue)
    
  return {
    id=string.formatNumber(os.time(), 36) .. string.formatNumber(math.random(1, 36 * 36 * 36), 36),
    tplId = tplId,
    name=name,
    trueName=name,
    attr=charValue,
    -- 1. ����, 2. ����
    status=2,
    index=nil,
    items={ },
    
    pets={

    },
    -- petIndex=nil,
    -- ai slot
    skills=aiDatas,
    heroBattleTech=aiDatas[1],
    petSkills=petAiDatas,
    petBattleTech=petAiDatas[1],
    -- �Ƿ����˰󶨳��� ���״�ʵ����Ӣ��ʱ������
    petGranted=false,
    -- �Ƿ����˳�ʼװ�����״�ʵ����Ӣ��ʱ������
    equipmentGranted=false,
    -- Ӣ���Զ��ӵ�ģʽ
    autoPointing=nil,
    -- �Ƿ���Ӣ���Զ��ӵ�
    isAutoPointing=0,
    -- ս���Զ��ӵ�ģʽ
    petAutoPointing=nil,
    -- �Ƿ���ս���Զ��ӵ�
    isPetAutoPointing=0,

  }
end
-- NOTE ��ѯ���ݿ� heroes ����
function module:queryHeroesData(charIndex)
  local cdKey = Char.GetData(charIndex, CONST.CHAR_CDK)
  local regNo = Char.GetData(charIndex, CONST.CHAR_RegistNumber)
  local sql="select value from des_heroes where cdkey= "..SQL.sqlValue(cdKey).." and regNo = "..SQL.sqlValue(regNo).." and is_deleted <> 1"
  local res,x =  SQL.QueryEx(sql)

  print(sql)
  local heroesData={};
  if res.rows then
    for i, row in ipairs(res.rows) do
      
      local value,pos = JSON.parse(row.value)
      table.insert(heroesData,value)

    end
    
  end
  return heroesData
  
end
-- NOTE ����heroes����
function module:saveHeroesData(charIndex,heroesData)
  local cdKey = Char.GetData(charIndex, CONST.CHAR_CDK)
  local regNo = Char.GetData(charIndex, CONST.CHAR_RegistNumber)
  
  if #heroesData == 0 then
    return;
  end
  local sqlValuesStr = _(heroesData):chain()
    :map(function(item) 
        return "("..SQL.sqlValue(item.id)..","
        ..SQL.sqlValue(cdKey)..","
        ..SQL.sqlValue(regNo)..","
        ..SQL.sqlValue(JSON.stringify(item))..")"
      end)
    :join(",")
    :value();
  local sql="replace into  des_heroes ( id,cdkey,regNo,value) values "..sqlValuesStr
  -- print("����heroes����",sql)
  local r = SQL.querySQL(sql)
  print("����heroes����,sqlִ�н��",r)
end
-- NOTE ���浥��hero����
function module:saveHeroData(charIndex,heroData)
  local cdKey = Char.GetData(charIndex, CONST.CHAR_CDK)
  local regNo = Char.GetData(charIndex, CONST.CHAR_RegistNumber)
  

  local sql="replace into  des_heroes ( id,cdkey,regNo,value) values ("
  ..SQL.sqlValue(heroData.id)..","
  ..SQL.sqlValue(cdKey)..","
  ..SQL.sqlValue(regNo)..","
  ..SQL.sqlValue(JSON.stringify(heroData))..")"
  -- print("���浥��hero����",sql)
  local r = SQL.querySQL(sql)
  print("���浥��hero����,sqlִ�н��",r)
end

-- NOTE ���� heroId ��ѯ heroData
function module:getHeroDataByid(charIndex,id)
    local heroesData = sgModule:get(charIndex,"heroes")
    local heroData = _.detect(heroesData, function(i) return i.id==id end)
    return heroData
end
-- NOTE ���ֹ������ƹ���ҳ
function module:buildRecruitSelection()
  local title = "     Ӣ�۾ƹ�\\n"
  local items = {
    "��ļ",
    "����",
  }
  local windowStr = self:NPC_buildSelectionText(title,items);
  return windowStr
end
-- NOTE ���ֹ���:Ӣ��������ֵ���� 
function module:buildAttrDescriptionForHero(heroData)
  
  local title= "     "..heroData.name.."\n";
  local windowStr = "�ȼ�:"..heroData['attr'][tostring(CONST.CHAR_�ȼ�)].."   ������:"..heroData['attr'][tostring(CONST.CHAR_������)]
    .."\n����:"..(heroData['attr'][tostring(CONST.CHAR_����)]/100).."  ����:"..(heroData['attr'][tostring(CONST.CHAR_����)]/100)
    .." ǿ��:"..(heroData['attr'][tostring(CONST.CHAR_ǿ��)]/100).."  �ٶ�:"..(heroData['attr'][tostring(CONST.CHAR_�ٶ�)]/100)
    .." ħ��:"..(heroData['attr'][tostring(CONST.CHAR_ħ��)]/100)
    .."\nս��״̬:"..nameMap["status"][tostring(heroData.status)]
  return title..windowStr
end

-- NOTE ���ֹ���:����Ӣ��״̬���� 
function module:buildDescriptionForCampHero(heroData,page)
  local heroIndex = heroData.index;
  local name = Char.GetData(heroIndex,CONST.CHAR_����)
  local level = Char.GetData(heroIndex,CONST.CHAR_�ȼ�)
  local leveluppoint = Char.GetData(heroIndex,CONST.CHAR_������)
  local vital = Char.GetData(heroIndex,CONST.CHAR_����)/100
  local str = Char.GetData(heroIndex,CONST.CHAR_����)/100
  local tgh = Char.GetData(heroIndex,CONST.CHAR_ǿ��)/100
  local quick = Char.GetData(heroIndex,CONST.CHAR_�ٶ�)/100
  local magic = Char.GetData(heroIndex,CONST.CHAR_ħ��)/100

  local att = Char.GetData(heroIndex,CONST.CHAR_������)
  local def = Char.GetData(heroIndex,CONST.CHAR_������)
  local agl = Char.GetData(heroIndex,CONST.CHAR_����)
  local spr = Char.GetData(heroIndex,CONST.CHAR_����)
  local rec = Char.GetData(heroIndex,CONST.CHAR_�ظ�)
  local exp = Char.GetData(heroIndex,CONST.CHAR_����)
  local hp = Char.GetData(heroIndex,CONST.CHAR_Ѫ)
  local mp = Char.GetData(heroIndex,CONST.CHAR_ħ)
  local maxhp = Char.GetData(heroIndex,CONST.CHAR_���Ѫ)
  local maxmp = Char.GetData(heroIndex,CONST.CHAR_���ħ)
  local critical = Char.GetData(heroIndex,CONST.CHAR_��ɱ)
  local counter = Char.GetData(heroIndex,CONST.CHAR_����)
  local hitrate = Char.GetData(heroIndex,CONST.CHAR_����)
  local avoid = Char.GetData(heroIndex,CONST.CHAR_����)
  local poison = Char.GetData(heroIndex,CONST.CHAR_����)
  local sleep = Char.GetData(heroIndex,CONST.CHAR_��˯)
  local stone = Char.GetData(heroIndex,CONST.CHAR_��ʯ)
  local drunk = Char.GetData(heroIndex,CONST.CHAR_����)
  local confused = Char.GetData(heroIndex,CONST.CHAR_����)
  local insomnia = Char.GetData(heroIndex,CONST.CHAR_����)
  local injured = Char.GetData(heroIndex,CONST.CHAR_����)
  local soulLost = Char.GetData(heroIndex,CONST.CHAR_����)
  local charm = Char.GetData(heroIndex,CONST.����_����)
  -- ��������
  local bagItems = self:buildCampHeroItem(nil,heroData)
  
  local bagItemsStr = _(bagItems):chain():join("   "):value();
  local title= "     $4"..heroData.name.."\n";
  local windowStr="";

  local feverTime = Char.GetData(heroIndex, CONST.CHAR_��ʱ)
  -- ����������

  for slot=0,7 do
    local itemIndex = Char.GetItemIndex(heroIndex,slot)
    if itemIndex>=0 then
      critical = critical+ (Item.GetData(itemIndex,CONST.����_��ɱ) or 0)
      
      counter =counter+ (Item.GetData(itemIndex,CONST.����_����) or 0)
      hitrate =  hitrate +  (Item.GetData(itemIndex,CONST.����_����) or 0)
      avoid = avoid +  (Item.GetData(itemIndex,CONST.����_����) or 0)
      poison = poison +  (Item.GetData(itemIndex,CONST.����_����) or 0)
      sleep = sleep +  (Item.GetData(itemIndex,CONST.����_˯��) or 0)
      stone = stone +  (Item.GetData(itemIndex,CONST.����_ʯ��) or 0)
      drunk = drunk +  (Item.GetData(itemIndex,CONST.����_����) or 0)
      confused =confused +  (Item.GetData(itemIndex,CONST.����_�ҿ�) or 0)
      insomnia =insomnia +  (Item.GetData(itemIndex,CONST.����_����) or 0)
    end
  end

  if page == 1 then
    windowStr = "\n�ȼ�:$1"..level.."   $0δ�ӵ�:$1"..leveluppoint
    .."\n\n����:$1"..vital.."  $0����:$1"..str
    .." $0ǿ��:$1"..tgh.."  $0�ٶ�:$1"..quick
    .." $0ħ��:$1"..magic
    .."\n\n������$1"..att.." $0������$1"..def.." $0���ݣ�$1"..agl.." $0����$1"..spr.." $0�ظ���$1"..rec
    .."\n\n���飺$1"..exp.." $0HP: $1"..hp.."/"..maxhp.." $0MP��$1"..mp.."/"..maxmp
    ..'\n\n����:'..self:healthColor(injured)..'��'.." $0���꣺$1"..soulLost.." $0��ʱ��$1"..feverTime
    .."\n\n$4����"
    .."\n"..bagItemsStr
    
  else
    windowStr="\n��ɱ��$1"..critical.." $0������$1"..counter.." $0���У�$1"..hitrate.." $0���㣺$1"..avoid
    .."\n\n������$1"..poison.." $0��˯��$1"..sleep.." $0��ʯ��$1"..stone
    .."\n\n$0������$1"..drunk.." $0���ң�$1"..confused .." $0������$1"..insomnia
    -- .."\n\n"..skills
    .."\n\n����:$1"..charm
  end

  return title..windowStr
end

-- NOTE ���ֹ���������״̬����
function module:buildDescriptionForParty(charIndex)
  local campHeroes=self:getCampHeroesData(charIndex)
  return _(campHeroes):chain():map(function(heroData) 
    local len2=6
    local heroIndex = heroData.index;
    local name = Char.GetData(heroIndex,CONST.CHAR_����)
    local level = self:strFill(Char.GetData(heroIndex,CONST.CHAR_�ȼ�),len2,' ')
    local leveluppoint = Char.GetData(heroIndex,CONST.CHAR_������)
    
    local vital = self:strFill(Char.GetData(heroIndex,CONST.CHAR_����)/100,len2,' ')
    local str = self:strFill(Char.GetData(heroIndex,CONST.CHAR_����)/100,len2,' ')
    local tgh = self:strFill(Char.GetData(heroIndex,CONST.CHAR_ǿ��)/100,len2,' ')
    local quick = self:strFill(Char.GetData(heroIndex,CONST.CHAR_�ٶ�)/100,len2,' ')
    local magic = self:strFill(Char.GetData(heroIndex,CONST.CHAR_ħ��)/100,len2,' ')

    local att = self:strFill(Char.GetData(heroIndex,CONST.CHAR_������),len2,' ')
    local def = self:strFill(Char.GetData(heroIndex,CONST.CHAR_������),len2,' ')
    local agl = self:strFill(Char.GetData(heroIndex,CONST.CHAR_����),len2,' ')
    local spr = self:strFill(Char.GetData(heroIndex,CONST.CHAR_����),len2,' ')
    local rec = self:strFill(Char.GetData(heroIndex,CONST.CHAR_�ظ�),len2,' ')
    local exp = self:strFill(Char.GetData(heroIndex,CONST.CHAR_����),len2,' ')
    local hp = Char.GetData(heroIndex,CONST.CHAR_Ѫ)
    local mp = Char.GetData(heroIndex,CONST.CHAR_ħ)
    local maxhp = Char.GetData(heroIndex,CONST.CHAR_���Ѫ)
    local maxmp = Char.GetData(heroIndex,CONST.CHAR_���ħ)
    local injured = Char.GetData(heroIndex,CONST.CHAR_����)
    local soulLost = Char.GetData(heroIndex,CONST.CHAR_����)
    local jobId = Char.GetData(heroIndex,CONST.CHAR_ְҵ)
    local jobName = getModule("gmsvData").jobs[tostring(jobId)][1]
    local windowStr = "$4".. self:strFill(heroData.name,16,' ')..jobName.."    $4�ȼ�:$1"..level.."$4δ�ӵ�:$1"..leveluppoint
      .."\n����:$1"..vital.."$0����:$1"..str
      .."$0ǿ��:$1"..tgh.."$0�ٶ�:$1"..quick
      .."$0ħ��:$1"..magic
      .."\n����:$1"..att.."$0����:$1"..def.."$0����:$1"..agl.."$0����:$1"..spr.."$0�ظ�:$1"..rec
      .."\n$0HP:$1"..hp.."/"..maxhp.." $0MP:$1"..mp.."/"..maxmp.."     $0����:$1"..exp
      ..'\n����:'..self:healthColor(injured)..'��'.."  $0����:$1"..soulLost
    return windowStr
  end):join("\n\n"):value()

end
-- NOTE ���ֹ���:����״̬���� 
function module:buildDescriptionForPet(heroData,petIndex,page)
  local name = Char.GetData(petIndex,CONST.CHAR_����)
  local level = Char.GetData(petIndex,CONST.CHAR_�ȼ�)
  local leveluppoint = Char.GetData(petIndex,CONST.CHAR_������)
  local vital =math.floor(Char.GetData(petIndex,CONST.CHAR_����)/100) 
  local str = math.floor(Char.GetData(petIndex,CONST.CHAR_����)/100)
  local tgh = math.floor(Char.GetData(petIndex,CONST.CHAR_ǿ��)/100)
  local quick = math.floor(Char.GetData(petIndex,CONST.CHAR_�ٶ�)/100)
  local magic = math.floor(Char.GetData(petIndex,CONST.CHAR_ħ��)/100)


  local att = Char.GetData(petIndex,CONST.CHAR_������)
  local def = Char.GetData(petIndex,CONST.CHAR_������)
  local agl = Char.GetData(petIndex,CONST.CHAR_����)
  local spr = Char.GetData(petIndex,CONST.CHAR_����)
  local rec = Char.GetData(petIndex,CONST.CHAR_�ظ�)
  local exp = Char.GetData(petIndex,CONST.CHAR_����)
  local hp = Char.GetData(petIndex,CONST.CHAR_Ѫ)
  local mp = Char.GetData(petIndex,CONST.CHAR_ħ)
  local maxhp = Char.GetData(petIndex,CONST.CHAR_���Ѫ)
  local maxmp = Char.GetData(petIndex,CONST.CHAR_���ħ)
  local critical = Char.GetData(petIndex,CONST.CHAR_��ɱ)
  local counter = Char.GetData(petIndex,CONST.CHAR_����)
  local hitrate = Char.GetData(petIndex,CONST.CHAR_����)
  local avoid = Char.GetData(petIndex,CONST.CHAR_����)
  local poison = Char.GetData(petIndex,CONST.CHAR_����)
  local sleep = Char.GetData(petIndex,CONST.CHAR_��˯)
  local stone = Char.GetData(petIndex,CONST.CHAR_��ʯ)
  local drunk = Char.GetData(petIndex,CONST.CHAR_����)
  local confused = Char.GetData(petIndex,CONST.CHAR_����)
  local insomnia = Char.GetData(petIndex,CONST.CHAR_����)
  local injured = Char.GetData(petIndex,CONST.CHAR_����)
  local soulLost = Char.GetData(petIndex,CONST.CHAR_����)
  local loyalty = Char.GetData(petIndex,495)
  local title= "     $4"..name.."\n";
  local windowStr="";
  if page == 1 then
    windowStr = "\n�ȼ�:$1"..level.."   $0δ�ӵ�:$1"..leveluppoint
    .."\n\n����:$1"..vital.."  $0����:$1"..str
    .." $0ǿ��:$1"..tgh.."  $0�ٶ�:$1"..quick
    .." $0ħ��:$1"..magic
    .."\n\n������$1"..att.." $0������$1"..def.." $0���ݣ�$1"..agl.." $0����$1"..spr.." $0�ظ���$1"..rec
    .."\n\n���飺$1"..exp.." $0HP: $1"..hp.."/"..maxhp.." $0MP��$1"..mp.."/"..maxmp
    ..'\n\n����:'..self:healthColor(injured)..'��'.." $0���꣺$1"..soulLost
    
  else
    windowStr="\n\n��ɱ��$1"..critical.." $0������$1"..counter.." $0���У�$1"..hitrate.." $0���㣺$1"..avoid
    .."\n\n������$1"..poison.." $0��˯��$1"..sleep.." $0��ʯ��$1"..stone
    .."\n$0������$1"..drunk.." $0���ң�$1"..confused .." $0������$1"..insomnia
    .."\n\n�ҳϣ�$1"..loyalty
  end

  return title..windowStr
end

-- NOTE ���ֹ��� : Ӣ���б�
function module:buildListForHero(heroData)
  local heroTplId = heroData.tplId
  local heroTplData = _.detect(heroesTpl,function(tpl) return tpl[1]==heroTplId end)
  local heroIndex = heroData.index;
  -- ��ȡ job 
  local jobId = heroData.attr[tostring(CONST.CHAR_ְҵ)]
  local jobName = getModule("gmsvData").jobs[tostring(jobId)][1]
  -- ��ȡ�ȼ�
  local level = heroData.attr[tostring(CONST.CHAR_�ȼ�)]

  -- local title="    ��"..heroTplData[15].."��  "..heroData.name.."  ְҵ:"..jobName
  return "��"..heroTplData[15].."��  "..heroData.name.."  "..jobName.." Lv"..level.." "..nameMap["status"][tostring(heroData.status)]
end
-- NOTE ���ֹ���: Ӣ�۲��� ���
function module:buildOperatorForHero(heroData)
  local name ="     "..heroData.name.."\\n";
  local toBeActStatus = heroData.status == 1 and 2 or 1
  local items = heroOpList(toBeActStatus)
  return self:NPC_buildSelectionText(name,items);
end
-- NOTE  ��������-Ӣ��
function module:generateHeroDummy(charIndex,heroData)
  
  local heroIndex = Char.CreateDummy()
  self:logInfo("����Ӣ��index:",heroIndex,heroData.id)
  local heroesOnline = sgModule:getGlobal("heroesOnline")
  if heroesOnline == nil then
    heroesOnline={}
    sgModule:setGlobal("heroesOnline",heroesOnline)
  end
  heroesOnline[heroIndex]=heroData;
  heroData.index = heroIndex
  heroData.owner = charIndex
  -- ���ֶ� ���ݣ�����Ĭ��ֵ
  heroData.isAutoPointing=heroData.isAutoPointing or 0 
  heroData.isPetAutoPointing=heroData.isPetAutoPointing or 0 

  -- -- ��������ֵ

  -- Char.SetData(heroIndex, CONST.CHAR_����,  heroData.attr[tostring(CONST.CHAR_����)]);
  -- Char.SetData(heroIndex, CONST.CHAR_����,  heroData.attr[tostring(CONST.CHAR_����)]);
  -- Char.SetData(heroIndex, CONST.CHAR_ǿ��,  heroData.attr[tostring(CONST.CHAR_ǿ��)]);
  -- Char.SetData(heroIndex, CONST.CHAR_�ٶ�,  heroData.attr[tostring(CONST.CHAR_�ٶ�)]);
  -- Char.SetData(heroIndex, CONST.CHAR_ħ��,  heroData.attr[tostring(CONST.CHAR_ħ��)]);
  -- Char.SetData(heroIndex, CONST.CHAR_�ȼ�,  heroData.attr[tostring(CONST.CHAR_�ȼ�)]);
  -- Char.SetData(heroIndex, CONST.CHAR_������,  heroData.attr[tostring(CONST.CHAR_������)]);

  -- Char.SetData(heroIndex, CONST.CHAR_ְҵ, heroData.attr[tostring(CONST.CHAR_ְҵ)]);
  -- Char.SetData(heroIndex, CONST.CHAR_ְ��ID, heroData.attr[tostring(CONST.CHAR_ְ��ID)]);
  -- Char.SetData(heroIndex, CONST.CHAR_ְ��, heroData.attr[tostring(CONST.CHAR_ְ��)]);

  -- local exception = {CONST.CHAR_X,CONST.CHAR_Y,CONST.CHAR_��ͼ,CONST.CHAR_��ͼ����}
  for key, v in pairs(petFields) do

    if heroData.attr[tostring(v)] ~=nil then
      
      Char.SetData(heroIndex, v,heroData.attr[tostring(v)]);
    end
  end
  Char.SetData(heroIndex, CONST.CHAR_X, Char.GetData(charIndex,CONST.CHAR_X));
  Char.SetData(heroIndex, CONST.CHAR_Y, Char.GetData(charIndex,CONST.CHAR_Y));
  Char.SetData(heroIndex, CONST.CHAR_��ͼ, Char.GetData(charIndex,CONST.CHAR_��ͼ));
  Char.SetData(heroIndex, CONST.CHAR_��ͼ����, 0);
  
  -- �״δ���������ʼֵ
  local c= Char.SetData(heroIndex, CONST.CHAR_Ѫ, Char.GetData(heroIndex, CONST.CHAR_���Ѫ))
   
  c= Char.SetData(heroIndex, CONST.CHAR_ħ, Char.GetData(heroIndex, CONST.CHAR_���ħ))
 
  c = heroData.attr[tostring(CONST.����_����)] == nil and  Char.SetData(heroIndex, CONST.����_����, 100) or Char.SetData(heroIndex, CONST.����_����, heroData.attr[tostring(CONST.����_����)])

  -- ����
  Char.AddSkill(heroIndex, 71); 
  Char.SetSkillLevel(heroIndex,0,10);
  NLG.UpChar(heroIndex);

  local heroTplId = heroData.tplId
  local heroTplData = _.detect(heroesTpl,function(tpl) return tpl[1]==heroTplId end)
  if heroTplData== nil then
    NLG.SystemMessage(dummyIndex,"������һ�������Ӣ��")
  end

  -- ���߸���
  if not heroData.equipmentGranted then
    -- ��ʼ��װ������
    if heroTplData[23]~=nil and type(heroTplData[23])=='table' then
      local itemTable = heroTplData[23]
      for i = 1,8 do
        local slot = i-1
        local itemId = itemTable[i]
        if itemId ==nil then
          goto continue
        end
        local itemIndex = Char.GiveItem(heroIndex, itemId, 1, false);
       
        if itemIndex >= 0 then
          Item.SetData( itemIndex , CONST.����_�Ѽ��� ,1)
          local addSlot = Char.GetItemSlot(heroIndex, itemIndex)
          
          if addSlot ~= slot then
            
            Char.MoveItem(heroIndex, addSlot, slot, -1)
          end
          
        end
        ::continue::
      end
      
    end
    heroData.equipmentGranted=true
  else
    for i,ItemData in pairs(heroData.items or {}) do
    
      local slot = tonumber(i)
      
      local itemId = ItemData[tostring(CONST.����_ID)]
      
      local itemIndex = Char.GiveItem(heroIndex, itemId, 1, false);
      
      if itemIndex >= 0 then
        self:insertItemData(itemIndex,ItemData)
        local addSlot = Char.GetItemSlot(heroIndex, itemIndex)
        
        if addSlot ~= slot then
          
          Char.MoveItem(heroIndex, addSlot, slot, -1)

        end
        
      end
  
    end
  end

  Item.UpItem(heroIndex,-1)
  -- ���� ����
  
  if not heroData.petGranted then
    -- ���г�ʼ�����︳��

    if heroTplData[22]~=nil and type(heroTplData[22])=='table' then
      local enemyId = heroTplData[22][1]

      _.each(heroTplData[22],function(enemyId) 
        if enemyId ~=nil then
          petIndex = Char.AddPet(heroIndex, enemyId);

          if syncWithPlayer then
            local charLevel = Char.GetData(charIndex,CONST.CHAR_�ȼ�)
            
            Char.SetData(petIndex,CONST.CHAR_����,charLevel^4)

          end

          Pet.UpPet(heroIndex,petIndex);
        end
      end)
    end
    Char.SetPetDepartureState(heroIndex, 0,CONST.PET_STATE_ս��)
    heroData.petGranted=true
  else
    local petsData=heroData.pets or {}
    local tempSlot = {}
    for slot = 0,4 do
      local petData = petsData[tostring(slot)]
      local petIndex;
      if petData ~= nil then
            -- ����petid ��ȡ enemyId
        local petId = petData.attr[tostring(CONST.PET_PetID)]
        local enemyId = getModule("gmsvData").enmeyBase2enemy[tostring(petId)]
        if enemyId ~=nil then
          enemyId = tonumber(enemyId)
          petIndex = Char.AddPet(heroIndex, enemyId);
          
          self:insertPetData(petIndex,petData)
          -- �����ս״̬����
          if petData.attr[tostring(CONST.PET_DepartureBattleStatus)] ~=nil then
            
            Char.SetPetDepartureState(heroIndex, slot,petData.attr[tostring(CONST.PET_DepartureBattleStatus)])
          end
  
        end
      else
        petIndex =Char.AddPet(heroIndex, 1);
        table.insert(tempSlot,slot)
      end
      Pet.UpPet(heroIndex,petIndex);
    end
    -- ɾ�� ռλ�ĳ���
    _.each(tempSlot,function(slot) 
      Char.DelSlotPet(heroIndex, slot)
    end)
  end


  


  Char.JoinParty(heroIndex, charIndex)
  
end
-- NOTE ɾ������ -Ӣ��
function module:delHeroDummy(charIndex,heroData)
  if not heroData.index then
    return;
  end

  -- print(JSON.stringify(heroData.pets))
  -- self:saveHeroData(charIndex,heroData)
  local heroesOnline = sgModule:getGlobal("heroesOnline")
  heroesOnline[heroData.index]=nil;
  Char.DelDummy(heroData.index)
  heroData.index=nil;
end
-- NOTE ���ֹ�����Ӣ�۹�����ҳ
function module:buildManagementForHero(charIndex)
  local title="              ��������"
  local items={
    "Ӣ�۹��",
    "�����",
    "ֹͣ��",
    "Ӣ�۹���",
    "���ƻָ�",
    "����һ��",
    "�������ˮ��"
  }

  return self:NPC_buildSelectionText(title,items);
end

-- NOTE ��ȡ����Ӣ�� ����
function module:getCampHeroesData(charIndex)
  local heroesData = sgModule:get(charIndex,"heroes") or {}
  
  return _.select(heroesData,function(item) return item.status==1 end)
end


--  NOTE ���ֹ����� ����Ӣ���б�
function module:buildCampHeroesList(charIndex)
  
  local campHeroes = self:getCampHeroesData(charIndex)
  local title = "     ����Ӣ��"
  local items=_.map(campHeroes,function(item) return item.name end)
  return self:NPC_buildSelectionText(title,items);
end
-- NOTE ���ֹ����� ����Ӣ�۲���
function module:buildCampHeroOperator(charIndex,heroData)
  local heroIndex = heroData.index;
  -- ��ȡ job 
  local jobId = Char.GetData(heroIndex,CONST.CHAR_ְҵ)
  local jobName = getModule("gmsvData").jobs[tostring(jobId)][1]
  -- ��ȡ˵��
  local heroTplId = heroData.tplId
  local heroTplData = _.detect(heroesTpl,function(tpl) return tpl[1]==heroTplId end)

  local title="    ��"..heroTplData[15].."��  "..heroData.name.."  ְҵ:"..jobName

  local aiId1 = heroData.heroBattleTech or -1
  
  local aiData1 = _.detect(getModule("heroesAI").aiData,function(data) return data.id==aiId1 end)
  local name1=aiData1~=nil and aiData1.name or "δ�趨"
  local aiId2 = heroData.petBattleTech or -1
  local aiData2 = _.detect(getModule("heroesAI").aiData,function(data) return data.id==aiId2 end)
  local name2=aiData2~=nil and aiData2.name or "δ�趨"

  local items={
    "�鿴״̬",
  "��Ʒ����",
  "��Ʒɾ��",
  "�������",
  "Ӣ�ۼӵ�",
  -- "ս��ӵ�",
  "Ӣ��AI".."��"..name1.."��",
  "����AI".."��"..name2.."��",
  "����ˮ��"
}
  return self:NPC_buildSelectionText(title,items);
end

-- NOTE ���ֹ���������Ӣ�۵������ 
function module:buildCampHeroItem(charIndex,heroData)
  local heroIndex = heroData.index
  local items={}
  for i = 0, 27 do
    local itemIndex = Char.GetItemIndex(heroIndex, i)
    local pre=""
    if i<=7 then
      pre="��"..nameMap['equipLocation'][tostring(i)]..":"
    else
      pre="��"
    end
    if itemIndex >= 0 then
      table.insert(items,pre..Item.GetData(itemIndex, CONST.����_����))

    else
      table.insert(items,pre..'��')
    end
  end
  
  return items
end
-- NOTE ���ֹ�������ұ������
function module:buildPlayerItem(charIndex)
  
  local items={}
  for i = 8, 27 do
    local itemIndex = Char.GetItemIndex(charIndex, i)
    local pre=""
    if i<=7 then
      pre=nameMap['equipLocation'][tostring(i)]..":"
    end
    if itemIndex >= 0 then
      table.insert(items,pre..Item.GetData(itemIndex, CONST.����_����))

    else
      table.insert(items,pre..'��')
    end
  end
  return items
end

-- NOTE ��ȡ ��Ʒ����
function module:extractItemData(itemIndex)
  local item = {};
  for _, v in pairs(itemFields) do
    item[tostring(v)] = Item.GetData(itemIndex, v);
  end
  return item;
end
--  NOTE ���� ��Ʒ����
function  module:insertItemData(itemIndex,itemData)
  for _, field in pairs(itemFields) do
    local r = 0;
    if type(itemData[tostring(field)]) ~= 'nil' then
      r = Item.SetData(itemIndex, field, itemData[tostring(field)]);
    end
  end
end

-- NOTE ������Ʒ����
function module:cacheHeroItemData(heroData)
  local heroIndex = heroData.index
  heroData.items={}
  for slot =0,27 do
    local itemIndex = Char.GetItemIndex(heroIndex,slot);
    if itemIndex>=0 then
      local data = self:extractItemData(itemIndex)
      heroData.items[tostring(slot)]=data;
    end
  end
end
-- NOTE �����������
function module:cacheHeroPetsData(heroData)
  local heroIndex = heroData.index
  heroData.pets={}
  for slot = 0,4 do
    local petIndex = Char.GetPet(heroIndex,slot)
    
    if petIndex>=0 then
      local data = self:extractPetData(petIndex)
      heroData.pets[tostring(slot)]=data;
    end
  end
end
-- NOTE ����Ӣ������
function module:cacheHeroAttrData(heroData)
  local heroIndex= heroData.index;
  local item={}
  -- �ó����key�� ��ǿ��һ��
  for _, v in pairs(petFields) do
    item[tostring(v)] = Char.GetData(heroIndex, v);
    
  end
  heroData.attr=item
end

-- NOTE ��ȡ��������
function module:extractPetData(petIndex)
  local item = {
    attr={},
    rank={},
    skills={}
  };
  for _, v in pairs(petFields) do
    item.attr[tostring(v)] = Char.GetData(petIndex, v);
    
  end
  for _, v in pairs(petRankFields) do
    item.rank[tostring(v)] = Pet.GetArtRank(petIndex,v);
    
  end
  -- ���＼��
  local skillTable={}
  for i=0,9 do
    local tech_id = Pet.GetSkill(petIndex, i)
    if tech_id<0 then
      table.insert(skillTable,nil)
    else
      table.insert(skillTable,tech_id)
    end
  end
  item.skills=skillTable
  return item;
end
-- NOTE �����������
function module:insertPetData(petIndex,petData)
  -- ��������
  for key, v in pairs(petFields) do
    if petData.attr[tostring(v)] ~=nil  then
      Char.SetData(petIndex, v,petData.attr[tostring(v)]);
    end
  end
  -- �ҳ�
  -- Char.SetData(petIndex, 495,100);
  -- ����ɳ�
  for key, v in pairs(petRankFields) do
    if petData.rank[tostring(v)] ~=nil then
      Pet.SetArtRank(petIndex, v,petData.rank[tostring(v)]);
    end
  end
  -- ���＼��
  
  for i=0,9 do
    local tech_id = petData.skills[i+1]
    Pet.DelSkill(petIndex,i)
    if tech_id ~=nil then
      
      Pet.AddSkill(petIndex,tech_id)
    
    end
  end


end

-- NOTE ���ֹ�����Ӣ�۳������
function module:buildCampHeroPets(heroData)
  local heroIndex = heroData.index;
  local items={}
  for i=0,4 do
    local petIndex = Char.GetPet(heroIndex, i)
    if petIndex>=0 then
      local status =  Char.GetData(petIndex, CONST.PET_DepartureBattleStatus);
      local suffix=""
      if status ==  CONST.PET_STATE_ս�� then
        suffix=" ս��"
      end
      table.insert(items,Char.GetData(petIndex,CONST.CHAR_����)..suffix)
    else
      table.insert(items,"��")
    end
  end
  local title="   ��ѡ�����"
  return self:NPC_buildSelectionText(title,items);
end
-- NOTE ���ֹ�����Ӣ�۳�������
function module:buildCampHeroPetOperator(charIndex,heroData)
  local heroIndex = heroData.index;
  local petSlot = sgModule:get(charIndex,"heroPetSlotSelected");
  local petIndex= Char.GetPet(heroIndex,petSlot)
  local items={}
  table.insert(items,"����")
  if petIndex>=0 then
    
    if (Char.GetData(petIndex, CONST.PET_DepartureBattleStatus) == CONST.PET_STATE_ս��) then
      table.insert(items,"����")
      
    else
      table.insert(items,"��ս")
      
    end
    table.insert(items,"״̬")
    -- table.insert(items,"����ս������")
  else
    table.insert(items,"")
    table.insert(items,"")
  end
  
  
  local title="   ������"
  return self:NPC_buildSelectionText(title,items);
end

-- NOTE ���ֹ�������ҳ������
function module:buildPlayerPets(charIndex)
  local items={}
  for i=0,4 do
    local petIndex = Char.GetPet(charIndex, i)
    if petIndex>=0 then
      table.insert(items,Char.GetData(petIndex,CONST.CHAR_����))
    else
      table.insert(items,"��")
    end
  end
  local title="   ��ѡ�����Ӣ�۵ĳ���"
  return self:NPC_buildSelectionText(title,items);
end

-- NOTE  ���Ŀ�� 
-- side 0 ���·��� 1 ���Ϸ�
-- range: 0:single,1: range ,2: all
function module:randomTarget(side,battle,range)
  
  local allTable={
    [1]=40,[2]=41,['all']=42
  }
  local start = 0
  if range==2 then
     return allTable[side+1]
  end
  if range == 1 then
    start = 20
  end

  if side == 1 then
    start = start +10
  end

  local slotTable = {}
  -- ����side��Ӫ�����н�ɫ�Ĳ�λ��
  for slot = side*10+0,side*10+9 do
    -- print("slot",slot)
    local charIndex = Battle.GetPlayer(battle, slot) 
    -- print("charIndex",charIndex)
    -- ����ò�λ���н�ɫ���򽫸ò�λ�����ӵ�slotTable������
    if(charIndex>=0) then
      table.insert(slotTable,slot)
    end

  end
  -- ��slotTable���������һ����λ�ŷ���
  return slotTable[NLG.Rand(1,#slotTable)]
end
-- NOTE ս��ʱ �����sideֵ
function module:oppositeSide(side)
  if side==0 then
    return 1
  else
    return 0
  end
end
-- NOTE ����ֵ��Ӧ����ɫ
function module:healthColor(injured)
  if injured==0 then
    return "$5"
  elseif injured>0 and injured<=25 then
    return "$0"
  elseif injured>25 and injured<=50 then
    return "$4"
  elseif injured>50 and injured<=75 then
    return "$2"
  elseif injured>75 and injured<=100 then
    return "$6"
  end
end

-- NOTE ���Ƽ��л�
function module:heal(charIndex,treatTarget)
  
  local money = Char.GetData(charIndex, CONST.CHAR_���);
  local treatTargetName =  Char.GetData(treatTarget, CONST.CHAR_����);
  local injured = Char.GetData(treatTarget, CONST.CHAR_����)

  -- ��Ѫħ
  local lp = Char.GetData(treatTarget, CONST.CHAR_Ѫ)
  local maxLp = Char.GetData(treatTarget, CONST.CHAR_���Ѫ)
  local fp = Char.GetData(treatTarget, CONST.CHAR_ħ)
  local maxFp = Char.GetData(treatTarget, CONST.CHAR_���ħ)

  local lpCost = maxLp - lp
  local fpCost = maxFp-fp
  local totalCost = lpCost+fpCost
  if totalCost>0 then
    if money>totalCost then
      Char.SetData(charIndex, CONST.CHAR_���, money - totalCost);
      Char.SetData(treatTarget, CONST.CHAR_Ѫ, maxLp)
      Char.SetData(treatTarget, CONST.CHAR_ħ, maxFp)
      NLG.SystemMessage(charIndex, treatTargetName.."��Ѫħ���۳�"..totalCost.."ħ��");
    else
      NLG.SystemMessage(charIndex, "�Բ�������ħ�Ҳ��㣬"..treatTargetName.."��Ѫħ��Ҫ"..totalCost.."ħ��");
    end

  end


  
  -- ����
  money = Char.GetData(charIndex, CONST.CHAR_���);
  if (injured < 1) then
    NLG.SystemMessage(charIndex, treatTargetName.."δ���ˡ�");
  else
    for k,v in pairs(healPrice) do
      if injured>= v[1] and injured<=v[2] then
        if money>= v[3] then
          Char.SetData(treatTarget, CONST.CHAR_����, 0);
          Char.SetData(charIndex, CONST.CHAR_���, money - v[3]);
          NLG.UpdateParty(charIndex);
          NLG.UpdateParty(treatTarget);
          -- NLG.UpChar(charIndex);
          -- NLG.UpChar(treatTarget);
          NLG.SystemMessage(charIndex, treatTargetName.."������ϡ��۳�"..v[3].."ħ��");
        else
          NLG.SystemMessage(charIndex, "�Բ�������ħ�Ҳ��㣬"..treatTargetName.."��������Ҫ"..v[3].."ħ��");
          return 
        end
      end
    end
  end
 

  money = Char.GetData(charIndex, CONST.CHAR_���);
  -- �л�
  local soulLost = Char.GetData(treatTarget,CONST.����_����);
  local treatTargetLv = Char.GetData(treatTarget,CONST.CHAR_�ȼ�);
  local cost = soulLost*200*treatTargetLv;
  if money >= cost and soulLost > 0 then
    print(money-cost)
    Char.SetData(charIndex,CONST.CHAR_���,money-cost);
    Char.SetData(treatTarget,CONST.����_����,0);
    -- NLG.UpChar(treatTarget);
    NLG.SystemMessage(charIndex,"�л���ɡ��۳�"..cost.."ħ�ҡ�");	
  
  end
  if money < cost then
    NLG.SystemMessage(charIndex,"ȱ��ħ��"..cost);	
  end
  -- NLG.UpChar(charIndex);
  -- NLG.UpChar(treatTarget);
end

-- NOTE ȫ�� ��

function module:partyFeverControl(charIndex,command)
  for slot = 0,4 do
    local p =Char.GetPartyMember(charIndex,slot)
    if(p>=0) then
      Char.SetData(p, CONST.CHAR_��ʱ, 24 * 3600);
      local name = Char.GetData(p,CONST.CHAR_����);
      if(command ==1) then
        Char.FeverStart(p);
        NLG.UpChar(p);
        NLG.SystemMessage(charIndex, name.."�򿨳ɹ���");	
      elseif(command ==0) then
        Char.FeverStop(p);
        NLG.UpChar(p);
        NLG.SystemMessage(charIndex, name.."�رմ򿨳ɹ���");	
      end
      
    end
  end
end
-- NOTE ���ֹ������ӵ�
function module:buildSetPoint(charIndex,heroIndex,page)
  
  local restPoint= Char.GetData(heroIndex,CONST.CHAR_������)
  local pointSetting =sgModule:get(charIndex,"pointSetting") or {}
  local pointsBeSetted = _(pointSetting):chain():values():reduce(0, 
  function(count, item) 
    return count+item
  end):value()
  local warningMsg=""
  if restPoint<pointsBeSetted then
    warningMsg="  ʣ������������뷵���޸�"
  end
  local windowStr="ʣ�����:"..(restPoint-pointsBeSetted).."$2"..warningMsg
  .."\n�ѷ��������".._(pointAttrs):chain():map(function(attrArray) return "\n  "..attrArray[2].."��"..(pointSetting[attrArray[1]] or "") end):join(""):value()
  .."\n$4��ǰ����"..pointAttrs[page][2]..":"
  .."\n(������Ҫ�ӵĵ�����������ӿ���ֱ�ӵ����һҳ)"
  return windowStr

end
-- NOTE ���� �ӵ�����
function module:cachePointSetting(charIndex,page,data)
  
  local pointSetting =sgModule:get(charIndex,"pointSetting")
  if pointSetting ==nil then
    pointSetting={}
  end
  pointSetting[pointAttrs[page][1]]=data
  sgModule:set(charIndex,"pointSetting",pointSetting)
end
-- NOTE ��Ӣ�ۼӵ�
function module:setPoint(charIndex,heroIndex)
  -- �ж� �����Ƿ�
  local name = Char.GetData(heroIndex,CONST.CHAR_����)
  local restPoint= Char.GetData(heroIndex,CONST.CHAR_������)
  local pointSetting =sgModule:get(charIndex,"pointSetting")
  local pointsBeSetted = _(pointSetting):chain():values():reduce(0, 
  function(count, item) 
    return count+item
  end):value()
  if restPoint<pointsBeSetted then
    NLG.SystemMessage(charIndex, "�����������");
    return
  end
  -- �ж� ��������Ƿ񳬹��ܵ�����һ��
  local vital = Char.GetData(heroIndex,CONST.CHAR_����)/100
  local str = Char.GetData(heroIndex,CONST.CHAR_����)/100
  local tgh = Char.GetData(heroIndex,CONST.CHAR_ǿ��)/100
  local quick = Char.GetData(heroIndex,CONST.CHAR_�ٶ�)/100
  local magic = Char.GetData(heroIndex,CONST.CHAR_ħ��)/100

  local addedPoint =vital+str+tgh+quick+magic

  local totalPoint = addedPoint + Char.GetData(heroIndex,CONST.CHAR_������)
  for key,arr in pairs(pointAttrs) do
    local data = (pointSetting[arr[1]] or 0 )
    if data== 0 then
      goto continue
    end
   
    local originData = Char.GetData(heroIndex,arr[1])/100
    
    if data+originData>totalPoint/2 then
      
      NLG.Say(charIndex,-1,"����������󣡵���bp�����������ܵ�����һ��",CONST.��ɫ_��ɫ,0)
      return 
    end
    ::continue::
  end



  Char.SetData(heroIndex,CONST.CHAR_������, restPoint-pointsBeSetted);
  _.each(pointAttrs,function(arr) 
    local data = (pointSetting[arr[1]] or 0 )*100
    if data== 0 then
      return
    end
   
    local originData = Char.GetData(heroIndex,arr[1])
    Char.SetData(heroIndex,arr[1], data+originData);
  end)
  NLG.UpChar(heroIndex);
  local msg = _(pointAttrs):chain():map(function(arr) return arr[2].."+"..pointSetting[arr[1]] end):join(","):value()
  NLG.SystemMessage(charIndex, name..msg);
end

-- NOTE ���ֹ������������
function module:buildCampHeroSkills(charIndex,skills)
  
  local items={}
  for i =1,8 do
    if skills[i]==nil then
      table.insert(items,"��")
    else
      local aiId= skills[i]
      local aiData = _.detect(getModule("heroesAI").aiData,function(data) return data.id==aiId end)

      local name=aiData.name
      table.insert(items,name)
    end
   
  end
  local title="    AI��"
  return self:NPC_buildSelectionText(title,items);
end
-- NOTE ���ֹ�����Ӣ�ۼӵ���ҳ
function module:buildHeroOperationSecWindow(charIndex,heroData)
  local heroIndex = heroData.index;
  -- ��ȡ job 
  local jobId = Char.GetData(heroIndex,CONST.CHAR_ְҵ)
  local jobName = getModule("gmsvData").jobs[tostring(jobId)][1]
  -- ��ȡ˵��
  local heroTplId = heroData.tplId
  local heroTplData = _.detect(heroesTpl,function(tpl) return tpl[1]==heroTplId end)

  local labelAutoPointing=  heroData.isAutoPointing==0 and "δ����" or "�ѿ���"
  local labelPetAUtoPointing = heroData.isPetAutoPointing==0 and "δ����" or "�ѿ���"

  local title="    ��"..heroTplData[15].."��  "..heroData.name.."  ְҵ:"..jobName

  local items = {"Ӣ���ֶ��ӵ�","�����ֶ��ӵ�","�Զ��ӵ�����("..(heroData.autoPointing or 'δ����')..")","�����Զ��ӵ�����("..(heroData.petAutoPointing  or 'δ����')..")","����Ӣ���Զ��ӵ㡾"..labelAutoPointing.."��","���س����Զ��ӵ㡾"..labelPetAUtoPointing.."��"}
  return self:NPC_buildSelectionText(title,items);

end
-- NOTE ���ֹ������Զ��ӵ�ģʽѡ��
-- params: 0 :Ӣ�ۣ�1������
function module:buildAutoPointSelect(type)
  local pattern;
  if type==0 then
    pattern=autoPointingPattern
  elseif type == 1 then
    pattern = petAutoPointingPattern
  end
  local title="��ѡ��ӵ�ģʽ(����,����,ǿ��,����,ħ��)"
  return self:NPC_buildSelectionText(title,pattern);
  
end
-- NOTE �����Զ��ӵ�ģʽ
function module:setAutoPionting(charIndex,heroData,patternIndex)
  heroData.autoPointing = autoPointingPattern[patternIndex]
end
-- NOTE ���ó����Զ��ӵ�ģʽ
function module:setPetAutoPionting(charIndex,heroData,patternIndex)
  heroData.petAutoPointing = petAutoPointingPattern[patternIndex]
end
-- NOTE  ִ�ж����Զ��ӵ�
function module:autoPoint(charIndex,setting)
  local name=Char.GetData(charIndex,CONST.CHAR_����)
  -- logInfo(name,setting)
  local levelUpPoint = Char.GetData(charIndex,CONST.CHAR_������)
  if setting== nil then
    return false,"δ�ҵ��Զ��ӵ�ģʽ"
  end
  for i=1,5 do
    local c = string.sub(setting,i,i)
    local point = tonumber(c)
    if point==nil then
      return false,"�Զ��ӵ�ģʽ����"
    end
    if point ==0 then
      goto continue
    end
    
    local type =pointAttrs[i][1]
    -- print("type",type,Char.GetData(charIndex,type),point)
    Char.SetData(charIndex,type,point*100+Char.GetData(charIndex,type))
    levelUpPoint=levelUpPoint-point
    -- if levelUpPoint ==0 then
    --   Char.SetData(charIndex,CONST.CHAR_������, levelUpPoint)
    --   return true,""
    -- end
    ::continue::
  end
  Char.SetData(charIndex,CONST.CHAR_������, levelUpPoint)
  return true,""
end
-- NOTE ����ˮ��
function module:changeCrystal(charIndex,heroData,crystalId)
  local heroIndex = heroData.index
  local heroName = Char.GetData(heroIndex,CONST.CHAR_����)
  -- ɾ��ˮ��
  Char.DelItemBySlot(heroIndex,CONST.EQUIP_ˮ��)
  local emptySlot = Char.GetEmptyItemSlot(heroIndex)
  local itemData=nil
  if emptySlot<0 then
    -- �Ȼ������һ����ƷȻ��ɾ��
    local itemIndex = Char.GetItemIndex(heroIndex,27)
    itemData= self:extractItemData(itemIndex)
    Char.DelItemBySlot(heroIndex,27)
  end

  -- ��ˮ����Ȼ��װ��
  local newCrystalIndex =Char.GiveItem(heroIndex, crystalId, 1);
  local addSlot = Char.GetItemSlot(heroIndex, newCrystalIndex)
	Char.MoveItem(heroIndex, addSlot, CONST.EQUIP_ˮ��, -1);
  -- ��ԭ��Ʒ
  if itemData ~=nil then
    local itemId = itemData[tostring(CONST.����_ID)]
    local originItemIndex = Char.GiveItem(heroIndex, itemId, 1, false);
      
    if originItemIndex >= 0 then
      self:insertItemData(originItemIndex,itemData)

    end
    Item.UpItem(heroIndex,27)
  end
  
  Item.UpItem(heroIndex,CONST.EQUIP_ˮ��)
  NLG.SystemMessage(charIndex, heroName.."�������µ�ˮ��");
end

-- NOTE ɾ�� hero
function module:deleteHeroData(charIndex,heroData)

  if heroData.status == 1 then
    heroData.status=2
    -- ɾ��Ӣ��
    local res,err =pcall( function() 
      self:delHeroDummy(charIndex,heroData)
    end)
    print(res,err)
  end

  local sql = "update des_heroes set is_deleted = 1 where id = ? "
  local res,ttt =  SQL.QueryEx(sql,heroData.id)
  
  if res.status ~= 0 then
    NLG.SystemMessage(charIndex, "���ݿ����������");
    print("heroData.id",heroData.id)
    return
  end
  local heroesData = sgModule:get(charIndex,"heroes")
  local newHeroesData = _.reject(heroesData,function(hero) return hero.id== heroData.id end)
  sgModule:set(charIndex,"heroes",newHeroesData)
  NLG.SystemMessage(charIndex, heroData.name.."�ѽ��");
end
-- NOTE function ���
function module:deepcopy(tDest, tSrc)
  for key,value in pairs(tSrc) do
      if type(value)=='table' and value["spuer"]==nil then
          tDest[key] = {}
          self:deepcopy(tDest[key],value)
      else
          tDest[key]=value
      end
  end
end
-- NOTE functions ������б�
function module:shuffle(tbl) -- suffles numeric indices
  local len, random = #tbl, math.random ;
  for i = len, 2, -1 do
      local j = random( 1, i );
      tbl[i], tbl[j] = tbl[j], tbl[i];
  end
  return tbl;
end
-- NOTE ������ string.fill
function module:strFill(str,len,filler)
  str=tostring(str)
  local strLen =string.len(str)
  -- print(str,strLen,str..string.rep(filler, len-strLen).."|")
  return str..string.rep(filler, len-strLen)
end
--- ����ģ�鹳��
function module:onLoad()
  self:logInfo('load')

end

--- ж��ģ�鹳��
function module:onUnload()
  self:logInfo('unload')
end

return module;