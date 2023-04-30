
local sgModule = ModuleBase:createModule('setterGetter')

local data={}
sgModule.global={}
sgModule.battleData={}
function sgModule:set(CharIndex,key,value)
  if not data[CharIndex] then
    data[CharIndex]={}
  end
  data[CharIndex][key]=value
end
function sgModule:get(CharIndex,key)
  if not data[CharIndex] then
    return nil;
  end
  return data[CharIndex][key]
end
function sgModule:append(CharIndex,key,value)
  if not data[CharIndex] then
    print(CharIndex,data[CharIndex])
    data[CharIndex]={}
  end
  if not data[CharIndex][key] then
    data[CharIndex][key]={}
  end
  table.insert(data[CharIndex][key],value)
  
end

function sgModule:appendGlobal(key,value)

  if not self.global[key] then
    self.global[key]={}
  end
  table.insert(self.global[key],value)
  
end

function sgModule:setGlobal(key,value)

  if not self.global[key] then
    self.global[key]={}
  end
  self.global[key]=value
  
end
function sgModule:getGlobal(key)

  if not self.global[key] then
    return nil
  end
  return self.global[key]
  
end


function sgModule:setBattleData(battleIndex,key,value)
  -- print("µÇ¼Ç cloneBattle£¬battleIndex:",battleIndex,key,value)
  if not self.battleData[battleIndex] then
    self.battleData[battleIndex]={}
  end
  self.battleData[battleIndex][key]=value
end
function sgModule:getBattleData(battleIndex,key)
  if not self.battleData[battleIndex] then
    return nil;
  end
  return self.battleData[battleIndex][key]
end
function sgModule:clearBattleData(battleIndex,key)
  if  self.battleData[battleIndex] then
    self.battleData[battleIndex][key]=nil;
  end
  return true;
end

function sgModule:onLoad()
  self:logInfo('load')
  self.global['heroesOnline']={}
end

function sgModule:onUnload()
  self:logInfo('unload')

end

return sgModule;
