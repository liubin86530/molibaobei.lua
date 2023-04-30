local module = ModuleBase:createModule('heroCall')
local heroesTpl = dofile("lua/Modules/heroesTpl.lua")
local _ = require "lua/Modules/underscore"
function module:heroCallInit(charIndex,targetIndex,itemSlot)
  -- 获取 itemIndex
  local itemIndex = Char.GetItemIndex(charIndex, itemSlot);
  if itemIndex < 0 then
    NLG.Say(charIndex,-1,"【错误】未找到道具",CONST.颜色_红色,0)
    return 
  end
  local itemSepType = Item.GetData(itemIndex,CONST.道具_特殊类型)
  if tonumber(itemSepType) ~=  50 then
    NLG.Say(charIndex,-1,"【错误】道具的特殊功能类型设置错误",CONST.颜色_红色,0)
    return 
  end

  local heroTplId = Item.GetData(itemIndex,CONST.道具_子参一)
  -- print(heroTplId,type(heroTplId),itemSepType)
  local toGetHeroData = _.detect(heroesTpl,function(tpl)  return tpl[1] ==heroTplId  end)

  local heroesData = getModule('setterGetter'):get(charIndex,"heroes")

  if #heroesData>=16 then
    NLG.Say(charIndex,-1,"【失败】最多雇佣16名英雄",CONST.颜色_红色,0)
    return
  end

  local toGetId = toGetHeroData[1]
  local isOwned = _.any(heroesData,function(heroData) return heroData.tplId == toGetId  end)
  if isOwned then
    NLG.Say(charIndex,-1,"【失败】英雄"..toGetHeroData[2].."已经雇佣",CONST.颜色_红色,0)
    return
  end
  local isAbleHire = toGetHeroData[17]==nil and true or toGetHeroData[17](charIndex)
  if not isAbleHire then
    return;
  end 
  local itemId = Item.GetData(itemIndex,%道具_序%);
  
  if(Char.DelItem(charIndex,itemId,1) < 0) then
    NLG.Say(charIndex,-1,"【系统】未知原因导致物品删除失败!",CONST.颜色_红色,0)
    return;
  end
  local heroData = getModule('heroesFn'):initHeroData(toGetHeroData,charIndex)
  table.insert(heroesData,heroData)
  getModule('setterGetter'):set(charIndex,"heroes",heroesData)
  NLG.SystemMessage(charIndex,"新英雄加入麾下，请于酒馆查看英雄")


end


--- 加载模块钩子
function module:onLoad()
  self:logInfo('load')
  self:regCallback('ItemString', Func.bind(self.heroCallInit, self),"LUA_useHeroCall");

end

--- 卸载模块钩子
function module:onUnload()
  self:logInfo('unload')
end

return module
