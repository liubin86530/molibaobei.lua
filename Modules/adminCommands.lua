---@class AdminCommands:ModuleBase|NPCPart|AssetsPart
local AdminCommands = ModuleBase:createModule('adminCommands')
local JSON=require "lua/Modules/json"
-- gm����
local commands = {}
--GM�˺��б�
local gmList = { '123456' };
local gmDict = {};
table.forEach(gmList, function(e)
  gmDict[e] = true
end)
-- ���ĳ�˵Ľ���ʱ��
function commands.cleanCloneBattle(charIndex, args)
  -- args[1] �� Ŀ�� charIndex
  Char.SetExtData(tonumber(args[1]),"lastCloneBattle",nil)
end
-- ��� cloneBattle�ļ���
function commands.cleancbdummy(charIndex, args)
  local value= getModule("cloneBattle").cloneBattleDummys
  for personIndex,v in pairs(value) do
    print("personIndex,v",personIndex,v)
    for no,dummyIndex in pairs(v) do
      print("no,dummyIndex",no,dummyIndex)
    end
    getModule("cloneBattle"):cleanDummy(personIndex)
    
  end
end
function commands.where(charIndex, args)
  local target = args[1];
  if #args == 1 then
    target = tonumber(args[1])
  end
  NLG.TalkToCli(charIndex, -1, target ..
    ' ��ͼ:' .. tostring(Char.GetData(target, CONST.CHAR_��ͼ)) .. '/' .. tostring(Char.GetData(target, CONST.CHAR_��ͼ����)) ..
    ', X:' .. tostring(Char.GetData(target, CONST.CHAR_X)) ..
    ', Y:' .. tostring(Char.GetData(target, CONST.CHAR_Y)) ..
    ', ����:' .. tostring(Char.GetData(target, CONST.CHAR_����))
  )
end
function commands.printAllPlayer(charIndex, args)
  local players = getModule("onlineplayer"):getPlayers()
  file = io.open("lua/player.log" ,"a")
  local timeStr =os.date("%Y-%m-%d% H:%M:%S",os.time())
  for k,target in pairs(players) do
    file:write(timeStr.."\n")
    file:write("���:\n")
    -- print(k,target)
    local str = target ..
    ' ��ͼ:' .. tostring(Char.GetData(target, CONST.CHAR_��ͼ)) .. '/' .. tostring(Char.GetData(target, CONST.CHAR_��ͼ����)) ..
    ', X:' .. tostring(Char.GetData(target, CONST.CHAR_X)) ..
    ', Y:' .. tostring(Char.GetData(target, CONST.CHAR_Y)) ..
    ', ����:' .. tostring(Char.GetData(target, CONST.CHAR_����))
    file:write(str)
    file:write("\n")

    -- Ӣ��
    file:write("Ӣ��:\n")
    local campHeroesData=getModule('heroesFn'):getCampHeroesData(target)
    for _,heroData in ipairs(campHeroesData) do
      local heroIndex = heroData.index
      local str = heroIndex ..
      ' ��ͼ:' .. tostring(Char.GetData(heroIndex, CONST.CHAR_��ͼ)) .. '/' .. tostring(Char.GetData(heroIndex, CONST.CHAR_��ͼ����)) ..
      ', X:' .. tostring(Char.GetData(heroIndex, CONST.CHAR_X)) ..
      ', Y:' .. tostring(Char.GetData(heroIndex, CONST.CHAR_Y)) ..
      ', ����:' .. tostring(Char.GetData(heroIndex, CONST.CHAR_����))
      file:write(str)
      file:write("\n")


    end
    file:write("==========================\n")
  end
  file:close()
end
function commands.heroExp(charIndex,args)
  local cdkey = args[1]
  local exp = tonumber(args[2])
  local target  = NLG.FindUser(cdkey)
  
  if target <0 then
    return;
  end
  local campHeroesData=getModule('heroesFn'):getCampHeroesData(target)
  for _,heroData in ipairs(campHeroesData) do
    local heroIndex = heroData.index
    Char.SetData(heroIndex,CONST.CHAR_����,exp)
    NLG.UpChar(heroIndex)
  end
  NLG.UpChar(target)
end
function commands.heroPoint(charIndex,args)
  local cdkey = args[1]
  local point = tonumber(args[2])
  local target  = NLG.FindUser(cdkey)
 
  if target <0 then
    return;
  end
  local campHeroesData=getModule('heroesFn'):getCampHeroesData(target)
  for _,heroData in ipairs(campHeroesData) do
    local heroIndex = heroData.index
    Char.SetData(heroIndex,CONST.CHAR_������,point)
    NLG.UpChar(heroIndex)
  end
  NLG.UpChar(target)
end
function commands.heroLv(charIndex,args)
  local cdkey = args[1]
  local lv = tonumber(args[2])
  local target  = NLG.FindUser(cdkey)
 
  if target <0 then
    return;
  end
  local campHeroesData=getModule('heroesFn'):getCampHeroesData(target)
  for _,heroData in ipairs(campHeroesData) do
    local heroIndex = heroData.index
    Char.SetData(heroIndex,CONST.CHAR_�ȼ�,lv)
    NLG.UpChar(heroIndex)
  end
  NLG.UpChar(target)
end
function commands.heroLv(charIndex,args)
  local cdkey = args[1]
  local lv = tonumber(args[2])
  local target  = NLG.FindUser(cdkey)
 
  if target <0 then
    return;
  end
  local campHeroesData=getModule('heroesFn'):getCampHeroesData(target)
  for _,heroData in ipairs(campHeroesData) do
    local heroIndex = heroData.index
    Char.SetData(heroIndex,CONST.CHAR_�ȼ�,lv)
    NLG.UpChar(heroIndex)
  end
  NLG.UpChar(target)
end
function commands.heroPetExp(charIndex,args)
  local cdkey = args[1]
  local exp = tonumber(args[2])
  local target  = NLG.FindUser(cdkey)
 
  if target <0 then
    return;
  end
  local campHeroesData=getModule('heroesFn'):getCampHeroesData(target)
  for _,heroData in ipairs(campHeroesData) do
    local heroIndex = heroData.index
    local petIndex = Char.GetPet(heroIndex,0);
    Char.SetData(petIndex,CONST.CHAR_����,exp)
    -- NLG.UpChar(petIndex)
    Pet.UpPet(heroIndex, petIndex);
  end
  NLG.UpChar(target)
end
-- test
function commands.test(charIndex, args)

  local petIndex = Char.GetPet(charIndex,0);
  -- Pet.DelSkill(petIndex,0)
  -- Pet.AddSkill(petIndex, 9509)
 
  -- Pet.UpPet(playerIndex, petIndex);
  

  -- local petIndex = Char.GetPet(charIndex,0);
  -- local originPoint = Char.GetData(petIndex,CONST.CHAR_������)
  -- Char.SetData(petIndex,CONST.CHAR_������,originPoint+119);

  -- Pet.UpPet(charIndex, petIndex);


  local a= 1
  local b=10
  print(math.floor(a/b))
  local feverTime = Char.GetData(charIndex, CONST.CHAR_��ʱ)
  print(feverTime)
end

function commands.kickall(charIndex, args)

  getModule("onlineplayer"):makeAllOut(charIndex)

end
function commands.getnpc(charIndex, args)
  local map=tonumber(args[1])
  local x = tonumber(args[2])
  local y = tonumber(args[3])

  local num,table = Obj.GetObject(0, map, x, y)
  print(num,table)
  local objIndex=table[1]
  local index = Obj.GetCharIndex(objIndex)
  print(index)
  -- ��ȡ 
end
function commands.setpetpoints(charIndex, args)
  local arg= tonumber(args[1])
  local petIndex = Char.GetPet(charIndex,0);
  Char.SetData(petIndex,45,arg);
  Pet.UpPet(charIndex,petIndex)
  
end

function commands.addGold(charIndex, args)
  Char.AddGold(charIndex, tonumber(args[1]))
end

function commands.giveItem(charIndex, args)
  Char.GiveItem(charIndex, tonumber(args[1]), tonumber(args[2]), args[3] ~= '0')
end

function commands.delItem(charIndex, args)
  Char.DelItem(charIndex, tonumber(args[1]), tonumber(args[2]), args[3] ~= '0')
end

function commands.delItemBySlot(charIndex, args)
  Char.DelItemBySlot(charIndex, tonumber(args[1]), tonumber(args[2]));
end

function commands.warp(charIndex, args)
  Char.Warp(charIndex, tonumber(args[2]), tonumber(args[1]), tonumber(args[3]), tonumber(args[4]));
end

function commands.getPet(charIndex, args)
  Char.GivePet(charIndex, tonumber(args[1]))
end

function commands.upPet(charIndex, args)
  Char.SetData(Char.GetPet(charIndex, tonumber(args[1])), CONST.CHAR_�ȼ�, tonumber(args[2]));
  Pet.UpPet(charIndex, Char.GetPet(charIndex, tonumber(args[1])));
end

function commands.recipe(charIndex, args)
  if args[1] == 'del' then
    if Recipe.RemoveRecipe(charIndex, tonumber(args[2])) == 1 then
      NLG.SystemMessage(charIndex, 'ɾ��' .. args[2] .. '���䷽')
    end
  elseif args[1] == 'add' then
    if Recipe.GiveRecipe(charIndex, tonumber(args[2])) == 1 then
      NLG.SystemMessage(charIndex, '���' .. args[2] .. '���䷽')
    end
  elseif args[1] == 'get' then
    for i = 0, 15 do
      local recipeId = tonumber(args[2]);
      if Recipe.GetData(recipeId, CONST.ITEM_RECIPE_ID) == 1 then
        NLG.SystemMessage(charIndex, i .. ' ' .. recipeId .. '���䷽: ' .. Recipe.GetData(recipeId, i))
      end
    end
  end
end

function commands.joinParty(charIndex, args)
  if #args == 2 then
    Char.JoinParty(tonumber(args[1]), tonumber(args[2]))
  else
    Char.JoinParty(charIndex, tonumber(args[1]))
  end
end
function commands.setImage(charIndex, args)
  local charIndex1 = tonumber(args[1])
  local imageID = tonumber(args[2])
  Char.SetData(charIndex1, CONST.����_ԭʼͼ��, imageID)
  Char.SetData(charIndex1, CONST.����_ԭ��, imageID)
  NLG.UpChar(charIndex1)
end
function commands.setAction(charIndex, args)
  local charIndex1 = tonumber(args[1])
  local com1 = tonumber(args[2])
  local com2 = tonumber(args[3])
  local com3 = tonumber(args[4])
  Char.SetData(charIndex1, CONST.CHAR_BattleCom1, com1)
  Char.SetData(charIndex1, CONST.CHAR_BattleCom2, com2)
  Char.SetData(charIndex1, CONST.CHAR_BattleCom3, com3)
  if #args == 7 then
    Char.SetData(charIndex1, CONST.CHAR_Battle2Com1, tonumber(args[5]))
    Char.SetData(charIndex1, CONST.CHAR_Battle2Com2, tonumber(args[6]))
    Char.SetData(charIndex1, CONST.CHAR_Battle2Com3, tonumber(args[7]))
  end
  Char.SetData(charIndex1, CONST.CHAR_BattleMode, 3)
end

function commands.createDummy(charIndex, args)
  local charIndex1 = Char.CreateDummy()
  Char.SetData(charIndex1, CONST.CHAR_X, Char.GetData(charIndex, CONST.CHAR_X));
  Char.SetData(charIndex1, CONST.CHAR_Y, Char.GetData(charIndex, CONST.CHAR_Y));
  Char.SetData(charIndex1, CONST.CHAR_��ͼ, Char.GetData(charIndex, CONST.CHAR_��ͼ));
  Char.SetData(charIndex1, CONST.CHAR_����, Char.GetData(charIndex, CONST.CHAR_����) .. ' ����');
  Char.SetData(charIndex1, CONST.CHAR_��ͼ����, Char.GetData(charIndex, CONST.CHAR_��ͼ����));
  Char.SetData(charIndex1, CONST.CHAR_����, Char.GetData(charIndex, CONST.CHAR_����));
  Char.SetData(charIndex1, CONST.CHAR_ԭ��, Char.GetData(charIndex, CONST.CHAR_ԭ��));
  Char.SetData(charIndex1, CONST.CHAR_ԭʼͼ��, Char.GetData(charIndex, CONST.CHAR_ԭʼͼ��));
  print('charIndex1', charIndex1)
  Char.SetData(charIndex1, CONST.CHAR_����, 999999);
  NLG.UpChar(charIndex1);
  Char.SetData(charIndex1, CONST.CHAR_Ѫ, Char.GetData(charIndex1, CONST.CHAR_���Ѫ));
  Char.SetData(charIndex1, CONST.CHAR_ħ, Char.GetData(charIndex1, CONST.CHAR_���ħ));
  Char.GiveItem(charIndex1, 2100, 1, false);
  Char.MoveItem(charIndex1, 8, CONST.EQUIP_����, -1);
  Char.SetData(charIndex1, CONST.CHAR_ְҵ, 41);
  Char.SetData(charIndex1, CONST.CHAR_ְ��ID, 40);
  Char.SetData(charIndex1, CONST.CHAR_ְ��, 1);
  Char.AddSkill(charIndex1, 95);
  Char.GivePet(charIndex1, 3004);
  Char.SetPetDepartureState(charIndex1, 0, CONST.PET_STATE_ս��);
  --Char.SetData(charIndex1, CONST.CHAR_ս��, 0);
  --local petIndex = Char.GetPet(charIndex1, 0);
  --Char.SetData(petIndex, CONST.PET_DepartureBattleStatus, CONST.PET_STATE_ս��);
  NLG.SystemMessage(charIndex, 'dummy: ' .. charIndex1)
  Char.JoinParty(charIndex1, charIndex);
end

function commands.setCharData(charIndex, args)
  local cix = tonumber(args[1])
  local dl = tonumber(args[2])
  local v = args[3]
  if dl >= 2000 then
  else
    v = tonumber(v)
  end
  NLG.SystemMessage(charIndex, 'Char.SetData: ' .. Char.SetData(cix, dl, v));
end

function commands.getCharData(charIndex, args)
  local cix = tonumber(args[1])
  local dl = tonumber(args[2])

  local function ifNil(a, b)
    if a == nil then
      return b
    end
    return a;
  end
  NLG.SystemMessage(charIndex, 'Char.GetData: ' .. args[1] .. '-' .. args[2] .. '=' .. ifNil(Char.GetData(cix, dl), 'nil'));
end

function commands.autoBattle(charIndex, args)
  if args[1] == 'on' then
    Protocol.Send(charIndex, "SkipBtCmd");
    Battle.ActionSelect(charIndex, CONST.BATTLE_COM.BATTLE_COM_ATTACK, 11, -1);
    Battle.ActionSelect(charIndex, CONST.BATTLE_COM.BATTLE_COM_ATTACK, 11, -1);
  end
end

function commands.delDummy(charIndex, args)
  Char.DelDummy(tonumber(args[1]))
end

function commands.moveChar(charIndex, args)
  Char.MoveArray(tonumber(args[1]), table.slice(args, 2))
end

function commands.calcFp(charIndex, args)
  NLG.SystemMessage(charIndex, string.format("%d => fp: %d %d", tonumber(args[1]), Char.CalcConsumeFp(charIndex, tonumber(args[1])), 999));
end

function commands.dolua(charIndex, args)
  local r, fn = pcall(dofile, args[1]);
  logDebug(AdminCommands.name, 'dofile', r, fn);
  if r then
    r, fn = pcall(fn, charIndex, table.slice(args, 2));
    logDebug(AdminCommands.name, 'execute', r, fn);
  end
end
--
--function commands.rift(charIndex, args)
--  local rift = getModule('rift')
--  rift:loadConfig()
--end

--function commands.testNextBattle(charIndex)
--  local battleIndex = Battle.PVE(charIndex, charIndex, nil, { 1 }, { 1 });
--  Battle.SetNextBattle(battleIndex, -2, 0xeeff);
--end

function AdminCommands:regCommand(key, fn)
  commands[key] = fn;
end

function AdminCommands:unloadCommand(key)
  commands[key] = nil;
end

function AdminCommands:onLoad()
  self:logInfo('load')
  if getModule('admin') == nil then
    error('adminģ��δ����')
  end
  local fnName, ix = self:regCallback(self.name .. '_WalkPostEvent', function(charIndex)
    self:logDebug('WalkPostEvent', charIndex)
    self:logDebug(Char.GetData(charIndex, CONST.CHAR_����));
  end)

  local function handleChat(charIndex, msg, color, range, size)
    if not getModule('admin'):isAdmin(charIndex) then
      return 1
    end
    local command = msg:match('^/([%w]+)')
    if commands[command] then
      local arg = msg:match('^/[%w]+ +(.+)$')
      arg = arg and string.split(arg, ' ') or {}
      commands[command](charIndex, arg);
      return 0
    end
    if command == 'walkTest' then
      Char.SetWalkPostEvent(nil, fnName, charIndex)
    end
    if command == 'walkTestOff' then
      Char.UnsetWalkPostEvent(charIndex)
    end
    return 1
  end
  self:regCallback('TalkEvent', handleChat)
end

function AdminCommands:onUnload()
  self:logInfo('unload')
end

return AdminCommands;
