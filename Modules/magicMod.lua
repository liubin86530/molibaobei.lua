
local magicModule = ModuleBase:createModule('magicMod')

--�� 2000*x/(x+550)
-- ǿ 2500*x/(x+550)
-- ��3000*x/(x+400)

local maxChao= 1800
local maxQiang = 1800
local maxDan = 1800


function magicModule:calc(delta,targets,techId,type) 
  local result=0;
  if(delta <=0) then
    return 0
  end
  
  if targets == 41  then
    -- ��
   
    result= math.ceil(maxChao*delta/(delta+300))
  elseif targets>=20 and targets<=39 then
  -- ǿ��
    result= math.ceil(maxQiang*delta/(delta+300))
  else
    result= math.ceil(maxDan*delta/(delta+300))
  end

  -- ��ȡ tech lv
  local techIndex = Tech.GetTechIndex(techId)
  local lv=Tech.GetData(techIndex, CONST.TECH_NECESSARYLV)
 
  if(lv == nil) then
    return result
  end
  if(lv >10) then
    lv =10;
  end
  
  -- if(type == )
  return result*lv/10
end




function magicModule:onLoad()
  self:logInfo('load')
  
end

function magicModule:onUnload()
  self:logInfo('unload')
end

return magicModule;
