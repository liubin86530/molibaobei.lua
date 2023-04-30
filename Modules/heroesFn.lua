local module = ModuleBase:createModule('heroesFn')
local JSON=require "lua/Modules/json"
local _ = require "lua/Modules/underscore"
local sgModule = getModule("setterGetter")
local heroesTpl = dofile("lua/Modules/heroesTpl.lua")
-- local heroesAI = getModule("heroesAI")

-- NOTE 雇佣时 英雄同玩家同等级
local syncWithPlayer=true;
--NOTE 中文映射字典
local nameMap={
  status={
    ['1']='出征',
    ['2']='待命'
  },
  equipLocation={
    [tostring(CONST.EQUIP_头)]="头部",
    [tostring(CONST.EQUIP_身)]="身体",
    [tostring(CONST.EQUIP_左手)]="左手",
    [tostring(CONST.EQUIP_右手)]="右手",
    [tostring(CONST.EQUIP_腿)]="腿部",
    [tostring(CONST.EQUIP_首饰1)]="首饰1",
    [tostring(CONST.EQUIP_首饰2)]="首饰2",
    [tostring(CONST.EQUIP_水晶)]="水晶",
  }
}
-- NOTE 出征选项
local heroOpList=function(status) return {nameMap['status'][tostring(status)],"查看状态","解雇"} end
-- NOTE 物品的所有属性key
local itemFields = { }
for i = 0, 0x4b do
  table.insert(itemFields, i);
end
for i = 0, 0xd do
  table.insert(itemFields, i + 2000);
end
-- NOTE 治疗价格 {min,max, 价格}
local healPrice={
  {1,25,200},{26,50,600},{51,75,1000},{76,100,1400},
}
-- NOTE 宠物的所有属性key
local petFields={
CONST.CHAR_类型,
CONST.CHAR_形象,
CONST.CHAR_原形,
CONST.CHAR_MAP,
CONST.CHAR_地图,
CONST.CHAR_X,
CONST.CHAR_Y,
CONST.CHAR_方向,
CONST.CHAR_等级,
CONST.CHAR_血,
CONST.CHAR_魔,
CONST.CHAR_体力,
CONST.CHAR_力量,
CONST.CHAR_强度,
CONST.CHAR_速度,
CONST.CHAR_魔法,
CONST.CHAR_运气,
CONST.CHAR_种族,
CONST.CHAR_地属性,
CONST.CHAR_水属性,
CONST.CHAR_火属性,
CONST.CHAR_风属性,
CONST.CHAR_抗毒,
CONST.CHAR_抗睡,
CONST.CHAR_抗石,
CONST.CHAR_抗醉,
CONST.CHAR_抗乱,
CONST.CHAR_抗忘,
CONST.CHAR_必杀,
CONST.CHAR_反击,
CONST.CHAR_命中,
CONST.CHAR_闪躲,
CONST.CHAR_道具栏,
CONST.CHAR_技能栏,
CONST.CHAR_死亡数,
CONST.CHAR_伤害数,
CONST.CHAR_杀宠数,
CONST.CHAR_占卜时间,
CONST.CHAR_受伤,
CONST.CHAR_移间,
CONST.CHAR_循时,
CONST.CHAR_经验,
CONST.CHAR_升级点,
CONST.CHAR_图类,
CONST.CHAR_名色,
CONST.CHAR_掉魂,
CONST.CHAR_原始图档,
CONST.CHAR_名字,
CONST.CHAR_最大血,
CONST.CHAR_最大魔,
CONST.CHAR_攻击力,
CONST.CHAR_防御力,
CONST.CHAR_敏捷,
CONST.CHAR_精神,
CONST.CHAR_回复,
CONST.CHAR_获得经验,
CONST.CHAR_魔攻,
CONST.CHAR_魔抗,
CONST.CHAR_EnemyBaseId,
CONST.PET_DepartureBattleStatus,
CONST.PET_PetID,
CONST.PET_技能栏,
CONST.对象_魅力,
CONST.对象_耐力,
CONST.对象_灵巧,
CONST.对象_智力,
CONST.对象_魅力,
CONST.对象_声望,
CONST.CHAR_职业,
CONST.CHAR_职阶,
CONST.CHAR_职类ID,
CONST.对象_名色,
}

-- NOTE 宠物成长属性key
local petRankFields={
CONST.PET_体成,
CONST.PET_力成,
CONST.PET_强成,
CONST.PET_敏成,
CONST.PET_魔成,
}
-- NOTE 加点常量
local pointAttrs = {
  {CONST.CHAR_体力,"体力"},
  {CONST.CHAR_力量,"力量"},
  {CONST.CHAR_强度,"强度"},
  {CONST.CHAR_速度,"速度"},
  {CONST.CHAR_魔法,"魔法"},
}
-- NOTE 英雄自动加点模式
local autoPointingPattern={'12010','21010','00022','10012','22000','10102','20011','20002'}
-- NOTE 宠物自动加点模式
local petAutoPointingPattern={'10000','01000','00100','00010','00001'}
-- NOTE 名色常量
local nameColorRareMap={
  ["R"]=5,
  ["SR"]=2,
  ["SSR"]=4,
  ["UR"]=6,
}

-- NOTE 新增-初始化英雄
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
      local charLevel = Char.GetData(charIndex,CONST.CHAR_等级)
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
      [tostring(CONST.CHAR_名字)]=name,
      [tostring(CONST.CHAR_形象)]=image,
      [tostring(CONST.CHAR_原形)]=image,
      [tostring(CONST.CHAR_原始图档)]=image,
      [tostring(CONST.CHAR_体力)]=vital*100,
      [tostring(CONST.CHAR_力量)]=str*100,
      [tostring(CONST.CHAR_强度)]=tgh*100,
      [tostring(CONST.CHAR_速度)]=quick*100,
      [tostring(CONST.CHAR_魔法)]=magic*100,
      [tostring(CONST.CHAR_等级)]=level,
      [tostring(CONST.CHAR_升级点)]=leveluppoint,
      [tostring(CONST.CHAR_职业)]=mainJob,
      [tostring(CONST.CHAR_职类ID)]=jobAncestry,
      [tostring(CONST.CHAR_职阶)]=jobRank,
      [tostring(CONST.对象_名色)]=nameColorRareMap[rare],
    }
    _.extend(charValue,modValue)
    
  return {
    id=string.formatNumber(os.time(), 36) .. string.formatNumber(math.random(1, 36 * 36 * 36), 36),
    tplId = tplId,
    name=name,
    trueName=name,
    attr=charValue,
    -- 1. 出征, 2. 待命
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
    -- 是否获得了绑定宠物 （首次实例化英雄时触发）
    petGranted=false,
    -- 是否获得了初始装备（首次实例化英雄时触发）
    equipmentGranted=false,
    -- 英雄自动加点模式
    autoPointing=nil,
    -- 是否开启英雄自动加点
    isAutoPointing=0,
    -- 战宠自动加点模式
    petAutoPointing=nil,
    -- 是否开启战宠自动加点
    isPetAutoPointing=0,

  }
end
-- NOTE 查询数据库 heroes 数据
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
-- NOTE 保存heroes数据
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
  -- print("保存heroes数据",sql)
  local r = SQL.querySQL(sql)
  print("保存heroes数据,sql执行结果",r)
end
-- NOTE 保存单个hero数据
function module:saveHeroData(charIndex,heroData)
  local cdKey = Char.GetData(charIndex, CONST.CHAR_CDK)
  local regNo = Char.GetData(charIndex, CONST.CHAR_RegistNumber)
  

  local sql="replace into  des_heroes ( id,cdkey,regNo,value) values ("
  ..SQL.sqlValue(heroData.id)..","
  ..SQL.sqlValue(cdKey)..","
  ..SQL.sqlValue(regNo)..","
  ..SQL.sqlValue(JSON.stringify(heroData))..")"
  -- print("保存单个hero数据",sql)
  local r = SQL.querySQL(sql)
  print("保存单个hero数据,sql执行结果",r)
end

-- NOTE 根据 heroId 查询 heroData
function module:getHeroDataByid(charIndex,id)
    local heroesData = sgModule:get(charIndex,"heroes")
    local heroData = _.detect(heroesData, function(i) return i.id==id end)
    return heroData
end
-- NOTE 文字构建：酒馆首页
function module:buildRecruitSelection()
  local title = "     英雄酒馆\\n"
  local items = {
    "招募",
    "下令",
  }
  local windowStr = self:NPC_buildSelectionText(title,items);
  return windowStr
end
-- NOTE 文字构建:英雄能力数值描述 
function module:buildAttrDescriptionForHero(heroData)
  
  local title= "     "..heroData.name.."\n";
  local windowStr = "等级:"..heroData['attr'][tostring(CONST.CHAR_等级)].."   升级点:"..heroData['attr'][tostring(CONST.CHAR_升级点)]
    .."\n体力:"..(heroData['attr'][tostring(CONST.CHAR_体力)]/100).."  力量:"..(heroData['attr'][tostring(CONST.CHAR_力量)]/100)
    .." 强度:"..(heroData['attr'][tostring(CONST.CHAR_强度)]/100).."  速度:"..(heroData['attr'][tostring(CONST.CHAR_速度)]/100)
    .." 魔法:"..(heroData['attr'][tostring(CONST.CHAR_魔法)]/100)
    .."\n战斗状态:"..nameMap["status"][tostring(heroData.status)]
  return title..windowStr
end

-- NOTE 文字构建:出征英雄状态描述 
function module:buildDescriptionForCampHero(heroData,page)
  local heroIndex = heroData.index;
  local name = Char.GetData(heroIndex,CONST.CHAR_名字)
  local level = Char.GetData(heroIndex,CONST.CHAR_等级)
  local leveluppoint = Char.GetData(heroIndex,CONST.CHAR_升级点)
  local vital = Char.GetData(heroIndex,CONST.CHAR_体力)/100
  local str = Char.GetData(heroIndex,CONST.CHAR_力量)/100
  local tgh = Char.GetData(heroIndex,CONST.CHAR_强度)/100
  local quick = Char.GetData(heroIndex,CONST.CHAR_速度)/100
  local magic = Char.GetData(heroIndex,CONST.CHAR_魔法)/100

  local att = Char.GetData(heroIndex,CONST.CHAR_攻击力)
  local def = Char.GetData(heroIndex,CONST.CHAR_防御力)
  local agl = Char.GetData(heroIndex,CONST.CHAR_敏捷)
  local spr = Char.GetData(heroIndex,CONST.CHAR_精神)
  local rec = Char.GetData(heroIndex,CONST.CHAR_回复)
  local exp = Char.GetData(heroIndex,CONST.CHAR_经验)
  local hp = Char.GetData(heroIndex,CONST.CHAR_血)
  local mp = Char.GetData(heroIndex,CONST.CHAR_魔)
  local maxhp = Char.GetData(heroIndex,CONST.CHAR_最大血)
  local maxmp = Char.GetData(heroIndex,CONST.CHAR_最大魔)
  local critical = Char.GetData(heroIndex,CONST.CHAR_必杀)
  local counter = Char.GetData(heroIndex,CONST.CHAR_反击)
  local hitrate = Char.GetData(heroIndex,CONST.CHAR_命中)
  local avoid = Char.GetData(heroIndex,CONST.CHAR_闪躲)
  local poison = Char.GetData(heroIndex,CONST.CHAR_抗毒)
  local sleep = Char.GetData(heroIndex,CONST.CHAR_抗睡)
  local stone = Char.GetData(heroIndex,CONST.CHAR_抗石)
  local drunk = Char.GetData(heroIndex,CONST.CHAR_抗醉)
  local confused = Char.GetData(heroIndex,CONST.CHAR_抗乱)
  local insomnia = Char.GetData(heroIndex,CONST.CHAR_抗忘)
  local injured = Char.GetData(heroIndex,CONST.CHAR_受伤)
  local soulLost = Char.GetData(heroIndex,CONST.CHAR_掉魂)
  local charm = Char.GetData(heroIndex,CONST.对象_魅力)
  -- 背包内容
  local bagItems = self:buildCampHeroItem(nil,heroData)
  
  local bagItemsStr = _(bagItems):chain():join("   "):value();
  local title= "     $4"..heroData.name.."\n";
  local windowStr="";

  local feverTime = Char.GetData(heroIndex, CONST.CHAR_卡时)
  -- 总修正计算

  for slot=0,7 do
    local itemIndex = Char.GetItemIndex(heroIndex,slot)
    if itemIndex>=0 then
      critical = critical+ (Item.GetData(itemIndex,CONST.道具_必杀) or 0)
      
      counter =counter+ (Item.GetData(itemIndex,CONST.道具_反击) or 0)
      hitrate =  hitrate +  (Item.GetData(itemIndex,CONST.道具_命中) or 0)
      avoid = avoid +  (Item.GetData(itemIndex,CONST.道具_闪躲) or 0)
      poison = poison +  (Item.GetData(itemIndex,CONST.道具_毒抗) or 0)
      sleep = sleep +  (Item.GetData(itemIndex,CONST.道具_睡抗) or 0)
      stone = stone +  (Item.GetData(itemIndex,CONST.道具_石抗) or 0)
      drunk = drunk +  (Item.GetData(itemIndex,CONST.道具_醉抗) or 0)
      confused =confused +  (Item.GetData(itemIndex,CONST.道具_乱抗) or 0)
      insomnia =insomnia +  (Item.GetData(itemIndex,CONST.道具_忘抗) or 0)
    end
  end

  if page == 1 then
    windowStr = "\n等级:$1"..level.."   $0未加点:$1"..leveluppoint
    .."\n\n体力:$1"..vital.."  $0力量:$1"..str
    .." $0强度:$1"..tgh.."  $0速度:$1"..quick
    .." $0魔法:$1"..magic
    .."\n\n攻击：$1"..att.." $0防御：$1"..def.." $0敏捷：$1"..agl.." $0精神：$1"..spr.." $0回复：$1"..rec
    .."\n\n经验：$1"..exp.." $0HP: $1"..hp.."/"..maxhp.." $0MP：$1"..mp.."/"..maxmp
    ..'\n\n健康:'..self:healthColor(injured)..'■'.." $0掉魂：$1"..soulLost.." $0卡时：$1"..feverTime
    .."\n\n$4背包"
    .."\n"..bagItemsStr
    
  else
    windowStr="\n必杀：$1"..critical.." $0反击：$1"..counter.." $0命中：$1"..hitrate.." $0闪躲：$1"..avoid
    .."\n\n抗毒：$1"..poison.." $0抗睡：$1"..sleep.." $0抗石：$1"..stone
    .."\n\n$0抗醉：$1"..drunk.." $0抗乱：$1"..confused .." $0抗忘：$1"..insomnia
    -- .."\n\n"..skills
    .."\n\n魅力:$1"..charm
  end

  return title..windowStr
end

-- NOTE 文字构建：队伍状态描述
function module:buildDescriptionForParty(charIndex)
  local campHeroes=self:getCampHeroesData(charIndex)
  return _(campHeroes):chain():map(function(heroData) 
    local len2=6
    local heroIndex = heroData.index;
    local name = Char.GetData(heroIndex,CONST.CHAR_名字)
    local level = self:strFill(Char.GetData(heroIndex,CONST.CHAR_等级),len2,' ')
    local leveluppoint = Char.GetData(heroIndex,CONST.CHAR_升级点)
    
    local vital = self:strFill(Char.GetData(heroIndex,CONST.CHAR_体力)/100,len2,' ')
    local str = self:strFill(Char.GetData(heroIndex,CONST.CHAR_力量)/100,len2,' ')
    local tgh = self:strFill(Char.GetData(heroIndex,CONST.CHAR_强度)/100,len2,' ')
    local quick = self:strFill(Char.GetData(heroIndex,CONST.CHAR_速度)/100,len2,' ')
    local magic = self:strFill(Char.GetData(heroIndex,CONST.CHAR_魔法)/100,len2,' ')

    local att = self:strFill(Char.GetData(heroIndex,CONST.CHAR_攻击力),len2,' ')
    local def = self:strFill(Char.GetData(heroIndex,CONST.CHAR_防御力),len2,' ')
    local agl = self:strFill(Char.GetData(heroIndex,CONST.CHAR_敏捷),len2,' ')
    local spr = self:strFill(Char.GetData(heroIndex,CONST.CHAR_精神),len2,' ')
    local rec = self:strFill(Char.GetData(heroIndex,CONST.CHAR_回复),len2,' ')
    local exp = self:strFill(Char.GetData(heroIndex,CONST.CHAR_经验),len2,' ')
    local hp = Char.GetData(heroIndex,CONST.CHAR_血)
    local mp = Char.GetData(heroIndex,CONST.CHAR_魔)
    local maxhp = Char.GetData(heroIndex,CONST.CHAR_最大血)
    local maxmp = Char.GetData(heroIndex,CONST.CHAR_最大魔)
    local injured = Char.GetData(heroIndex,CONST.CHAR_受伤)
    local soulLost = Char.GetData(heroIndex,CONST.CHAR_掉魂)
    local jobId = Char.GetData(heroIndex,CONST.CHAR_职业)
    local jobName = getModule("gmsvData").jobs[tostring(jobId)][1]
    local windowStr = "$4".. self:strFill(heroData.name,16,' ')..jobName.."    $4等级:$1"..level.."$4未加点:$1"..leveluppoint
      .."\n体力:$1"..vital.."$0力量:$1"..str
      .."$0强度:$1"..tgh.."$0速度:$1"..quick
      .."$0魔法:$1"..magic
      .."\n攻击:$1"..att.."$0防御:$1"..def.."$0敏捷:$1"..agl.."$0精神:$1"..spr.."$0回复:$1"..rec
      .."\n$0HP:$1"..hp.."/"..maxhp.." $0MP:$1"..mp.."/"..maxmp.."     $0经验:$1"..exp
      ..'\n健康:'..self:healthColor(injured)..'■'.."  $0掉魂:$1"..soulLost
    return windowStr
  end):join("\n\n"):value()

end
-- NOTE 文字构建:宠物状态描述 
function module:buildDescriptionForPet(heroData,petIndex,page)
  local name = Char.GetData(petIndex,CONST.CHAR_名字)
  local level = Char.GetData(petIndex,CONST.CHAR_等级)
  local leveluppoint = Char.GetData(petIndex,CONST.CHAR_升级点)
  local vital =math.floor(Char.GetData(petIndex,CONST.CHAR_体力)/100) 
  local str = math.floor(Char.GetData(petIndex,CONST.CHAR_力量)/100)
  local tgh = math.floor(Char.GetData(petIndex,CONST.CHAR_强度)/100)
  local quick = math.floor(Char.GetData(petIndex,CONST.CHAR_速度)/100)
  local magic = math.floor(Char.GetData(petIndex,CONST.CHAR_魔法)/100)


  local att = Char.GetData(petIndex,CONST.CHAR_攻击力)
  local def = Char.GetData(petIndex,CONST.CHAR_防御力)
  local agl = Char.GetData(petIndex,CONST.CHAR_敏捷)
  local spr = Char.GetData(petIndex,CONST.CHAR_精神)
  local rec = Char.GetData(petIndex,CONST.CHAR_回复)
  local exp = Char.GetData(petIndex,CONST.CHAR_经验)
  local hp = Char.GetData(petIndex,CONST.CHAR_血)
  local mp = Char.GetData(petIndex,CONST.CHAR_魔)
  local maxhp = Char.GetData(petIndex,CONST.CHAR_最大血)
  local maxmp = Char.GetData(petIndex,CONST.CHAR_最大魔)
  local critical = Char.GetData(petIndex,CONST.CHAR_必杀)
  local counter = Char.GetData(petIndex,CONST.CHAR_反击)
  local hitrate = Char.GetData(petIndex,CONST.CHAR_命中)
  local avoid = Char.GetData(petIndex,CONST.CHAR_闪躲)
  local poison = Char.GetData(petIndex,CONST.CHAR_抗毒)
  local sleep = Char.GetData(petIndex,CONST.CHAR_抗睡)
  local stone = Char.GetData(petIndex,CONST.CHAR_抗石)
  local drunk = Char.GetData(petIndex,CONST.CHAR_抗醉)
  local confused = Char.GetData(petIndex,CONST.CHAR_抗乱)
  local insomnia = Char.GetData(petIndex,CONST.CHAR_抗忘)
  local injured = Char.GetData(petIndex,CONST.CHAR_受伤)
  local soulLost = Char.GetData(petIndex,CONST.CHAR_掉魂)
  local loyalty = Char.GetData(petIndex,495)
  local title= "     $4"..name.."\n";
  local windowStr="";
  if page == 1 then
    windowStr = "\n等级:$1"..level.."   $0未加点:$1"..leveluppoint
    .."\n\n体力:$1"..vital.."  $0力量:$1"..str
    .." $0强度:$1"..tgh.."  $0速度:$1"..quick
    .." $0魔法:$1"..magic
    .."\n\n攻击：$1"..att.." $0防御：$1"..def.." $0敏捷：$1"..agl.." $0精神：$1"..spr.." $0回复：$1"..rec
    .."\n\n经验：$1"..exp.." $0HP: $1"..hp.."/"..maxhp.." $0MP：$1"..mp.."/"..maxmp
    ..'\n\n健康:'..self:healthColor(injured)..'■'.." $0掉魂：$1"..soulLost
    
  else
    windowStr="\n\n必杀：$1"..critical.." $0反击：$1"..counter.." $0命中：$1"..hitrate.." $0闪躲：$1"..avoid
    .."\n\n抗毒：$1"..poison.." $0抗睡：$1"..sleep.." $0抗石：$1"..stone
    .."\n$0抗醉：$1"..drunk.." $0抗乱：$1"..confused .." $0抗忘：$1"..insomnia
    .."\n\n忠诚：$1"..loyalty
  end

  return title..windowStr
end

-- NOTE 文字构建 : 英雄列表
function module:buildListForHero(heroData)
  local heroTplId = heroData.tplId
  local heroTplData = _.detect(heroesTpl,function(tpl) return tpl[1]==heroTplId end)
  local heroIndex = heroData.index;
  -- 获取 job 
  local jobId = heroData.attr[tostring(CONST.CHAR_职业)]
  local jobName = getModule("gmsvData").jobs[tostring(jobId)][1]
  -- 获取等级
  local level = heroData.attr[tostring(CONST.CHAR_等级)]

  -- local title="    【"..heroTplData[15].."】  "..heroData.name.."  职业:"..jobName
  return "【"..heroTplData[15].."】  "..heroData.name.."  "..jobName.." Lv"..level.." "..nameMap["status"][tostring(heroData.status)]
end
-- NOTE 文字构建: 英雄操作 面板
function module:buildOperatorForHero(heroData)
  local name ="     "..heroData.name.."\\n";
  local toBeActStatus = heroData.status == 1 and 2 or 1
  local items = heroOpList(toBeActStatus)
  return self:NPC_buildSelectionText(name,items);
end
-- NOTE  创建假人-英雄
function module:generateHeroDummy(charIndex,heroData)
  
  local heroIndex = Char.CreateDummy()
  self:logInfo("创建英雄index:",heroIndex,heroData.id)
  local heroesOnline = sgModule:getGlobal("heroesOnline")
  if heroesOnline == nil then
    heroesOnline={}
    sgModule:setGlobal("heroesOnline",heroesOnline)
  end
  heroesOnline[heroIndex]=heroData;
  heroData.index = heroIndex
  heroData.owner = charIndex
  -- 新字段 兼容，赋予默认值
  heroData.isAutoPointing=heroData.isAutoPointing or 0 
  heroData.isPetAutoPointing=heroData.isPetAutoPointing or 0 

  -- -- 定义能力值

  -- Char.SetData(heroIndex, CONST.CHAR_体力,  heroData.attr[tostring(CONST.CHAR_体力)]);
  -- Char.SetData(heroIndex, CONST.CHAR_力量,  heroData.attr[tostring(CONST.CHAR_力量)]);
  -- Char.SetData(heroIndex, CONST.CHAR_强度,  heroData.attr[tostring(CONST.CHAR_强度)]);
  -- Char.SetData(heroIndex, CONST.CHAR_速度,  heroData.attr[tostring(CONST.CHAR_速度)]);
  -- Char.SetData(heroIndex, CONST.CHAR_魔法,  heroData.attr[tostring(CONST.CHAR_魔法)]);
  -- Char.SetData(heroIndex, CONST.CHAR_等级,  heroData.attr[tostring(CONST.CHAR_等级)]);
  -- Char.SetData(heroIndex, CONST.CHAR_升级点,  heroData.attr[tostring(CONST.CHAR_升级点)]);

  -- Char.SetData(heroIndex, CONST.CHAR_职业, heroData.attr[tostring(CONST.CHAR_职业)]);
  -- Char.SetData(heroIndex, CONST.CHAR_职类ID, heroData.attr[tostring(CONST.CHAR_职类ID)]);
  -- Char.SetData(heroIndex, CONST.CHAR_职阶, heroData.attr[tostring(CONST.CHAR_职阶)]);

  -- local exception = {CONST.CHAR_X,CONST.CHAR_Y,CONST.CHAR_地图,CONST.CHAR_地图类型}
  for key, v in pairs(petFields) do

    if heroData.attr[tostring(v)] ~=nil then
      
      Char.SetData(heroIndex, v,heroData.attr[tostring(v)]);
    end
  end
  Char.SetData(heroIndex, CONST.CHAR_X, Char.GetData(charIndex,CONST.CHAR_X));
  Char.SetData(heroIndex, CONST.CHAR_Y, Char.GetData(charIndex,CONST.CHAR_Y));
  Char.SetData(heroIndex, CONST.CHAR_地图, Char.GetData(charIndex,CONST.CHAR_地图));
  Char.SetData(heroIndex, CONST.CHAR_地图类型, 0);
  
  -- 首次创建，给初始值
  local c= Char.SetData(heroIndex, CONST.CHAR_血, Char.GetData(heroIndex, CONST.CHAR_最大血))
   
  c= Char.SetData(heroIndex, CONST.CHAR_魔, Char.GetData(heroIndex, CONST.CHAR_最大魔))
 
  c = heroData.attr[tostring(CONST.对象_魅力)] == nil and  Char.SetData(heroIndex, CONST.对象_魅力, 100) or Char.SetData(heroIndex, CONST.对象_魅力, heroData.attr[tostring(CONST.对象_魅力)])

  -- 调教
  Char.AddSkill(heroIndex, 71); 
  Char.SetSkillLevel(heroIndex,0,10);
  NLG.UpChar(heroIndex);

  local heroTplId = heroData.tplId
  local heroTplData = _.detect(heroesTpl,function(tpl) return tpl[1]==heroTplId end)
  if heroTplData== nil then
    NLG.SystemMessage(dummyIndex,"汗，有一个编外的英雄")
  end

  -- 道具赋予
  if not heroData.equipmentGranted then
    -- 初始化装备给予
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
          Item.SetData( itemIndex , CONST.道具_已鉴定 ,1)
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
      
      local itemId = ItemData[tostring(CONST.道具_ID)]
      
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
  -- 创建 宠物
  
  if not heroData.petGranted then
    -- 进行初始化宠物赋予

    if heroTplData[22]~=nil and type(heroTplData[22])=='table' then
      local enemyId = heroTplData[22][1]

      _.each(heroTplData[22],function(enemyId) 
        if enemyId ~=nil then
          petIndex = Char.AddPet(heroIndex, enemyId);

          if syncWithPlayer then
            local charLevel = Char.GetData(charIndex,CONST.CHAR_等级)
            
            Char.SetData(petIndex,CONST.CHAR_经验,charLevel^4)

          end

          Pet.UpPet(heroIndex,petIndex);
        end
      end)
    end
    Char.SetPetDepartureState(heroIndex, 0,CONST.PET_STATE_战斗)
    heroData.petGranted=true
  else
    local petsData=heroData.pets or {}
    local tempSlot = {}
    for slot = 0,4 do
      local petData = petsData[tostring(slot)]
      local petIndex;
      if petData ~= nil then
            -- 根据petid 获取 enemyId
        local petId = petData.attr[tostring(CONST.PET_PetID)]
        local enemyId = getModule("gmsvData").enmeyBase2enemy[tostring(petId)]
        if enemyId ~=nil then
          enemyId = tonumber(enemyId)
          petIndex = Char.AddPet(heroIndex, enemyId);
          
          self:insertPetData(petIndex,petData)
          -- 宠物出战状态设置
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
    -- 删除 占位的宠物
    _.each(tempSlot,function(slot) 
      Char.DelSlotPet(heroIndex, slot)
    end)
  end


  


  Char.JoinParty(heroIndex, charIndex)
  
end
-- NOTE 删除假人 -英雄
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
-- NOTE 文字构建：英雄管理首页
function module:buildManagementForHero(charIndex)
  local title="              队伍治理"
  local items={
    "英雄归队",
    "队伍打卡",
    "停止打卡",
    "英雄管理",
    "治疗恢复",
    "队伍一览",
    "整体更换水晶"
  }

  return self:NPC_buildSelectionText(title,items);
end

-- NOTE 获取出征英雄 数据
function module:getCampHeroesData(charIndex)
  local heroesData = sgModule:get(charIndex,"heroes") or {}
  
  return _.select(heroesData,function(item) return item.status==1 end)
end


--  NOTE 文字构建： 出征英雄列表
function module:buildCampHeroesList(charIndex)
  
  local campHeroes = self:getCampHeroesData(charIndex)
  local title = "     出征英雄"
  local items=_.map(campHeroes,function(item) return item.name end)
  return self:NPC_buildSelectionText(title,items);
end
-- NOTE 文字构建： 出征英雄操作
function module:buildCampHeroOperator(charIndex,heroData)
  local heroIndex = heroData.index;
  -- 获取 job 
  local jobId = Char.GetData(heroIndex,CONST.CHAR_职业)
  local jobName = getModule("gmsvData").jobs[tostring(jobId)][1]
  -- 获取说明
  local heroTplId = heroData.tplId
  local heroTplData = _.detect(heroesTpl,function(tpl) return tpl[1]==heroTplId end)

  local title="    【"..heroTplData[15].."】  "..heroData.name.."  职业:"..jobName

  local aiId1 = heroData.heroBattleTech or -1
  
  local aiData1 = _.detect(getModule("heroesAI").aiData,function(data) return data.id==aiId1 end)
  local name1=aiData1~=nil and aiData1.name or "未设定"
  local aiId2 = heroData.petBattleTech or -1
  local aiData2 = _.detect(getModule("heroesAI").aiData,function(data) return data.id==aiId2 end)
  local name2=aiData2~=nil and aiData2.name or "未设定"

  local items={
    "查看状态",
  "物品交换",
  "物品删除",
  "宠物管理",
  "英雄加点",
  -- "战宠加点",
  "英雄AI".."【"..name1.."】",
  "宠物AI".."【"..name2.."】",
  "更换水晶"
}
  return self:NPC_buildSelectionText(title,items);
end

-- NOTE 文字构建：出征英雄道具浏览 
function module:buildCampHeroItem(charIndex,heroData)
  local heroIndex = heroData.index
  local items={}
  for i = 0, 27 do
    local itemIndex = Char.GetItemIndex(heroIndex, i)
    local pre=""
    if i<=7 then
      pre="▲"..nameMap['equipLocation'][tostring(i)]..":"
    else
      pre="◆"
    end
    if itemIndex >= 0 then
      table.insert(items,pre..Item.GetData(itemIndex, CONST.道具_名字))

    else
      table.insert(items,pre..'空')
    end
  end
  
  return items
end
-- NOTE 文字构建：玩家背包浏览
function module:buildPlayerItem(charIndex)
  
  local items={}
  for i = 8, 27 do
    local itemIndex = Char.GetItemIndex(charIndex, i)
    local pre=""
    if i<=7 then
      pre=nameMap['equipLocation'][tostring(i)]..":"
    end
    if itemIndex >= 0 then
      table.insert(items,pre..Item.GetData(itemIndex, CONST.道具_名字))

    else
      table.insert(items,pre..'空')
    end
  end
  return items
end

-- NOTE 抽取 物品数据
function module:extractItemData(itemIndex)
  local item = {};
  for _, v in pairs(itemFields) do
    item[tostring(v)] = Item.GetData(itemIndex, v);
  end
  return item;
end
--  NOTE 赋予 物品属性
function  module:insertItemData(itemIndex,itemData)
  for _, field in pairs(itemFields) do
    local r = 0;
    if type(itemData[tostring(field)]) ~= 'nil' then
      r = Item.SetData(itemIndex, field, itemData[tostring(field)]);
    end
  end
end

-- NOTE 缓存物品数据
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
-- NOTE 缓存宠物数据
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
-- NOTE 缓存英雄数据
function module:cacheHeroAttrData(heroData)
  local heroIndex= heroData.index;
  local item={}
  -- 用宠物的key？ 勉强用一下
  for _, v in pairs(petFields) do
    item[tostring(v)] = Char.GetData(heroIndex, v);
    
  end
  heroData.attr=item
end

-- NOTE 抽取宠物数据
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
  -- 宠物技能
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
-- NOTE 赋予宠物数据
function module:insertPetData(petIndex,petData)
  -- 宠物属性
  for key, v in pairs(petFields) do
    if petData.attr[tostring(v)] ~=nil  then
      Char.SetData(petIndex, v,petData.attr[tostring(v)]);
    end
  end
  -- 忠诚
  -- Char.SetData(petIndex, 495,100);
  -- 宠物成长
  for key, v in pairs(petRankFields) do
    if petData.rank[tostring(v)] ~=nil then
      Pet.SetArtRank(petIndex, v,petData.rank[tostring(v)]);
    end
  end
  -- 宠物技能
  
  for i=0,9 do
    local tech_id = petData.skills[i+1]
    Pet.DelSkill(petIndex,i)
    if tech_id ~=nil then
      
      Pet.AddSkill(petIndex,tech_id)
    
    end
  end


end

-- NOTE 文字构建：英雄宠物浏览
function module:buildCampHeroPets(heroData)
  local heroIndex = heroData.index;
  local items={}
  for i=0,4 do
    local petIndex = Char.GetPet(heroIndex, i)
    if petIndex>=0 then
      local status =  Char.GetData(petIndex, CONST.PET_DepartureBattleStatus);
      local suffix=""
      if status ==  CONST.PET_STATE_战斗 then
        suffix=" 战斗"
      end
      table.insert(items,Char.GetData(petIndex,CONST.CHAR_名字)..suffix)
    else
      table.insert(items,"空")
    end
  end
  local title="   请选择宠物"
  return self:NPC_buildSelectionText(title,items);
end
-- NOTE 文字构建：英雄宠物命令
function module:buildCampHeroPetOperator(charIndex,heroData)
  local heroIndex = heroData.index;
  local petSlot = sgModule:get(charIndex,"heroPetSlotSelected");
  local petIndex= Char.GetPet(heroIndex,petSlot)
  local items={}
  table.insert(items,"交换")
  if petIndex>=0 then
    
    if (Char.GetData(petIndex, CONST.PET_DepartureBattleStatus) == CONST.PET_STATE_战斗) then
      table.insert(items,"待命")
      
    else
      table.insert(items,"出战")
      
    end
    table.insert(items,"状态")
    -- table.insert(items,"设置战斗技能")
  else
    table.insert(items,"")
    table.insert(items,"")
  end
  
  
  local title="   请下令"
  return self:NPC_buildSelectionText(title,items);
end

-- NOTE 文字构建：玩家宠物浏览
function module:buildPlayerPets(charIndex)
  local items={}
  for i=0,4 do
    local petIndex = Char.GetPet(charIndex, i)
    if petIndex>=0 then
      table.insert(items,Char.GetData(petIndex,CONST.CHAR_名字))
    else
      table.insert(items,"空")
    end
  end
  local title="   请选择给予英雄的宠物"
  return self:NPC_buildSelectionText(title,items);
end

-- NOTE  随机目标 
-- side 0 是下方， 1 是上方
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
  -- 遍历side阵营中所有角色的槽位号
  for slot = side*10+0,side*10+9 do
    -- print("slot",slot)
    local charIndex = Battle.GetPlayer(battle, slot) 
    -- print("charIndex",charIndex)
    -- 如果该槽位中有角色，则将该槽位号添加到slotTable数组中
    if(charIndex>=0) then
      table.insert(slotTable,slot)
    end

  end
  -- 从slotTable数组中随机一个槽位号返回
  return slotTable[NLG.Rand(1,#slotTable)]
end
-- NOTE 战斗时 对面的side值
function module:oppositeSide(side)
  if side==0 then
    return 1
  else
    return 0
  end
end
-- NOTE 受伤值对应的颜色
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

-- NOTE 治疗及招魂
function module:heal(charIndex,treatTarget)
  
  local money = Char.GetData(charIndex, CONST.CHAR_金币);
  local treatTargetName =  Char.GetData(treatTarget, CONST.CHAR_名字);
  local injured = Char.GetData(treatTarget, CONST.CHAR_受伤)

  -- 补血魔
  local lp = Char.GetData(treatTarget, CONST.CHAR_血)
  local maxLp = Char.GetData(treatTarget, CONST.CHAR_最大血)
  local fp = Char.GetData(treatTarget, CONST.CHAR_魔)
  local maxFp = Char.GetData(treatTarget, CONST.CHAR_最大魔)

  local lpCost = maxLp - lp
  local fpCost = maxFp-fp
  local totalCost = lpCost+fpCost
  if totalCost>0 then
    if money>totalCost then
      Char.SetData(charIndex, CONST.CHAR_金币, money - totalCost);
      Char.SetData(treatTarget, CONST.CHAR_血, maxLp)
      Char.SetData(treatTarget, CONST.CHAR_魔, maxFp)
      NLG.SystemMessage(charIndex, treatTargetName.."补血魔。扣除"..totalCost.."魔币");
    else
      NLG.SystemMessage(charIndex, "对不起！您的魔币不足，"..treatTargetName.."补血魔需要"..totalCost.."魔币");
    end

  end


  
  -- 治疗
  money = Char.GetData(charIndex, CONST.CHAR_金币);
  if (injured < 1) then
    NLG.SystemMessage(charIndex, treatTargetName.."未受伤。");
  else
    for k,v in pairs(healPrice) do
      if injured>= v[1] and injured<=v[2] then
        if money>= v[3] then
          Char.SetData(treatTarget, CONST.CHAR_受伤, 0);
          Char.SetData(charIndex, CONST.CHAR_金币, money - v[3]);
          NLG.UpdateParty(charIndex);
          NLG.UpdateParty(treatTarget);
          -- NLG.UpChar(charIndex);
          -- NLG.UpChar(treatTarget);
          NLG.SystemMessage(charIndex, treatTargetName.."治疗完毕。扣除"..v[3].."魔币");
        else
          NLG.SystemMessage(charIndex, "对不起！您的魔币不足，"..treatTargetName.."的治疗需要"..v[3].."魔币");
          return 
        end
      end
    end
  end
 

  money = Char.GetData(charIndex, CONST.CHAR_金币);
  -- 招魂
  local soulLost = Char.GetData(treatTarget,CONST.对象_掉魂);
  local treatTargetLv = Char.GetData(treatTarget,CONST.CHAR_等级);
  local cost = soulLost*200*treatTargetLv;
  if money >= cost and soulLost > 0 then
    print(money-cost)
    Char.SetData(charIndex,CONST.CHAR_金币,money-cost);
    Char.SetData(treatTarget,CONST.对象_掉魂,0);
    -- NLG.UpChar(treatTarget);
    NLG.SystemMessage(charIndex,"招魂完成。扣除"..cost.."魔币。");	
  
  end
  if money < cost then
    NLG.SystemMessage(charIndex,"缺少魔币"..cost);	
  end
  -- NLG.UpChar(charIndex);
  -- NLG.UpChar(treatTarget);
end

-- NOTE 全队 打卡

function module:partyFeverControl(charIndex,command)
  for slot = 0,4 do
    local p =Char.GetPartyMember(charIndex,slot)
    if(p>=0) then
      Char.SetData(p, CONST.CHAR_卡时, 24 * 3600);
      local name = Char.GetData(p,CONST.CHAR_名字);
      if(command ==1) then
        Char.FeverStart(p);
        NLG.UpChar(p);
        NLG.SystemMessage(charIndex, name.."打卡成功。");	
      elseif(command ==0) then
        Char.FeverStop(p);
        NLG.UpChar(p);
        NLG.SystemMessage(charIndex, name.."关闭打卡成功。");	
      end
      
    end
  end
end
-- NOTE 文字构建：加点
function module:buildSetPoint(charIndex,heroIndex,page)
  
  local restPoint= Char.GetData(heroIndex,CONST.CHAR_升级点)
  local pointSetting =sgModule:get(charIndex,"pointSetting") or {}
  local pointsBeSetted = _(pointSetting):chain():values():reduce(0, 
  function(count, item) 
    return count+item
  end):value()
  local warningMsg=""
  if restPoint<pointsBeSetted then
    warningMsg="  剩余点数不够，请返回修改"
  end
  local windowStr="剩余点数:"..(restPoint-pointsBeSetted).."$2"..warningMsg
  .."\n已分配点数：".._(pointAttrs):chain():map(function(attrArray) return "\n  "..attrArray[2].."："..(pointSetting[attrArray[1]] or "") end):join(""):value()
  .."\n$4当前分配"..pointAttrs[page][2]..":"
  .."\n(输入需要加的点数，如果不加可以直接点击下一页)"
  return windowStr

end
-- NOTE 缓存 加点数据
function module:cachePointSetting(charIndex,page,data)
  
  local pointSetting =sgModule:get(charIndex,"pointSetting")
  if pointSetting ==nil then
    pointSetting={}
  end
  pointSetting[pointAttrs[page][1]]=data
  sgModule:set(charIndex,"pointSetting",pointSetting)
end
-- NOTE 给英雄加点
function module:setPoint(charIndex,heroIndex)
  -- 判断 点数是否够
  local name = Char.GetData(heroIndex,CONST.CHAR_名字)
  local restPoint= Char.GetData(heroIndex,CONST.CHAR_升级点)
  local pointSetting =sgModule:get(charIndex,"pointSetting")
  local pointsBeSetted = _(pointSetting):chain():values():reduce(0, 
  function(count, item) 
    return count+item
  end):value()
  if restPoint<pointsBeSetted then
    NLG.SystemMessage(charIndex, "点数分配错误！");
    return
  end
  -- 判断 分配点数是否超过总点数的一半
  local vital = Char.GetData(heroIndex,CONST.CHAR_体力)/100
  local str = Char.GetData(heroIndex,CONST.CHAR_力量)/100
  local tgh = Char.GetData(heroIndex,CONST.CHAR_强度)/100
  local quick = Char.GetData(heroIndex,CONST.CHAR_速度)/100
  local magic = Char.GetData(heroIndex,CONST.CHAR_魔法)/100

  local addedPoint =vital+str+tgh+quick+magic

  local totalPoint = addedPoint + Char.GetData(heroIndex,CONST.CHAR_升级点)
  for key,arr in pairs(pointAttrs) do
    local data = (pointSetting[arr[1]] or 0 )
    if data== 0 then
      goto continue
    end
   
    local originData = Char.GetData(heroIndex,arr[1])/100
    
    if data+originData>totalPoint/2 then
      
      NLG.Say(charIndex,-1,"点数分配错误！单项bp点数超过了总点数的一半",CONST.颜色_红色,0)
      return 
    end
    ::continue::
  end



  Char.SetData(heroIndex,CONST.CHAR_升级点, restPoint-pointsBeSetted);
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

-- NOTE 文字构建：技能浏览
function module:buildCampHeroSkills(charIndex,skills)
  
  local items={}
  for i =1,8 do
    if skills[i]==nil then
      table.insert(items,"空")
    else
      local aiId= skills[i]
      local aiData = _.detect(getModule("heroesAI").aiData,function(data) return data.id==aiId end)

      local name=aiData.name
      table.insert(items,name)
    end
   
  end
  local title="    AI栏"
  return self:NPC_buildSelectionText(title,items);
end
-- NOTE 文字构建：英雄加点主页
function module:buildHeroOperationSecWindow(charIndex,heroData)
  local heroIndex = heroData.index;
  -- 获取 job 
  local jobId = Char.GetData(heroIndex,CONST.CHAR_职业)
  local jobName = getModule("gmsvData").jobs[tostring(jobId)][1]
  -- 获取说明
  local heroTplId = heroData.tplId
  local heroTplData = _.detect(heroesTpl,function(tpl) return tpl[1]==heroTplId end)

  local labelAutoPointing=  heroData.isAutoPointing==0 and "未开启" or "已开启"
  local labelPetAUtoPointing = heroData.isPetAutoPointing==0 and "未开启" or "已开启"

  local title="    【"..heroTplData[15].."】  "..heroData.name.."  职业:"..jobName

  local items = {"英雄手动加点","宠物手动加点","自动加点设置("..(heroData.autoPointing or '未设置')..")","宠物自动加点设置("..(heroData.petAutoPointing  or '未设置')..")","开关英雄自动加点【"..labelAutoPointing.."】","开关宠物自动加点【"..labelPetAUtoPointing.."】"}
  return self:NPC_buildSelectionText(title,items);

end
-- NOTE 文字构建：自动加点模式选择
-- params: 0 :英雄，1：宠物
function module:buildAutoPointSelect(type)
  local pattern;
  if type==0 then
    pattern=autoPointingPattern
  elseif type == 1 then
    pattern = petAutoPointingPattern
  end
  local title="请选择加点模式(体力,力量,强度,敏捷,魔法)"
  return self:NPC_buildSelectionText(title,pattern);
  
end
-- NOTE 设置自动加点模式
function module:setAutoPionting(charIndex,heroData,patternIndex)
  heroData.autoPointing = autoPointingPattern[patternIndex]
end
-- NOTE 设置宠物自动加点模式
function module:setPetAutoPionting(charIndex,heroData,patternIndex)
  heroData.petAutoPointing = petAutoPointingPattern[patternIndex]
end
-- NOTE  执行对象自动加点
function module:autoPoint(charIndex,setting)
  local name=Char.GetData(charIndex,CONST.CHAR_名字)
  -- logInfo(name,setting)
  local levelUpPoint = Char.GetData(charIndex,CONST.CHAR_升级点)
  if setting== nil then
    return false,"未找到自动加点模式"
  end
  for i=1,5 do
    local c = string.sub(setting,i,i)
    local point = tonumber(c)
    if point==nil then
      return false,"自动加点模式错误"
    end
    if point ==0 then
      goto continue
    end
    
    local type =pointAttrs[i][1]
    -- print("type",type,Char.GetData(charIndex,type),point)
    Char.SetData(charIndex,type,point*100+Char.GetData(charIndex,type))
    levelUpPoint=levelUpPoint-point
    -- if levelUpPoint ==0 then
    --   Char.SetData(charIndex,CONST.CHAR_升级点, levelUpPoint)
    --   return true,""
    -- end
    ::continue::
  end
  Char.SetData(charIndex,CONST.CHAR_升级点, levelUpPoint)
  return true,""
end
-- NOTE 更换水晶
function module:changeCrystal(charIndex,heroData,crystalId)
  local heroIndex = heroData.index
  local heroName = Char.GetData(heroIndex,CONST.CHAR_名字)
  -- 删除水晶
  Char.DelItemBySlot(heroIndex,CONST.EQUIP_水晶)
  local emptySlot = Char.GetEmptyItemSlot(heroIndex)
  local itemData=nil
  if emptySlot<0 then
    -- 先缓存最后一个物品然后删了
    local itemIndex = Char.GetItemIndex(heroIndex,27)
    itemData= self:extractItemData(itemIndex)
    Char.DelItemBySlot(heroIndex,27)
  end

  -- 给水晶，然后装上
  local newCrystalIndex =Char.GiveItem(heroIndex, crystalId, 1);
  local addSlot = Char.GetItemSlot(heroIndex, newCrystalIndex)
	Char.MoveItem(heroIndex, addSlot, CONST.EQUIP_水晶, -1);
  -- 还原物品
  if itemData ~=nil then
    local itemId = itemData[tostring(CONST.道具_ID)]
    local originItemIndex = Char.GiveItem(heroIndex, itemId, 1, false);
      
    if originItemIndex >= 0 then
      self:insertItemData(originItemIndex,itemData)

    end
    Item.UpItem(heroIndex,27)
  end
  
  Item.UpItem(heroIndex,CONST.EQUIP_水晶)
  NLG.SystemMessage(charIndex, heroName.."更换了新的水晶");
end

-- NOTE 删除 hero
function module:deleteHeroData(charIndex,heroData)

  if heroData.status == 1 then
    heroData.status=2
    -- 删除英雄
    local res,err =pcall( function() 
      self:delHeroDummy(charIndex,heroData)
    end)
    print(res,err)
  end

  local sql = "update des_heroes set is_deleted = 1 where id = ? "
  local res,ttt =  SQL.QueryEx(sql,heroData.id)
  
  if res.status ~= 0 then
    NLG.SystemMessage(charIndex, "数据库错误，请重试");
    print("heroData.id",heroData.id)
    return
  end
  local heroesData = sgModule:get(charIndex,"heroes")
  local newHeroesData = _.reject(heroesData,function(hero) return hero.id== heroData.id end)
  sgModule:set(charIndex,"heroes",newHeroesData)
  NLG.SystemMessage(charIndex, heroData.name.."已解雇");
end
-- NOTE function 深拷贝
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
-- NOTE functions 随机排列表
function module:shuffle(tbl) -- suffles numeric indices
  local len, random = #tbl, math.random ;
  for i = len, 2, -1 do
      local j = random( 1, i );
      tbl[i], tbl[j] = tbl[j], tbl[i];
  end
  return tbl;
end
-- NOTE 填完整 string.fill
function module:strFill(str,len,filler)
  str=tostring(str)
  local strLen =string.len(str)
  -- print(str,strLen,str..string.rep(filler, len-strLen).."|")
  return str..string.rep(filler, len-strLen)
end
--- 加载模块钩子
function module:onLoad()
  self:logInfo('load')

end

--- 卸载模块钩子
function module:onUnload()
  self:logInfo('unload')
end

return module;
