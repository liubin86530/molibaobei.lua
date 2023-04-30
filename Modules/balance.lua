local balanceModule = ModuleBase:createModule('balanceModule')



function balanceModule:MyDamageCalculateEvent(CharIndex, DefCharIndex, OriDamage, Damage, BattleIndex, Com1, Com2, Com3, DefCom1, DefCom2, DefCom3, Flg)

    if(Damage == 0)then
        return Damage
    end
    local type = Char.GetData(CharIndex,%对象_序%)
    local defType = Char.GetData(DefCharIndex,%对象_序%)
    -- 修正魔法伤害
    local magicModDamage=0;
    if Flg==5 then
      
      -- print("com1：",Com1,"com2:",Com2,"com3:",Com3)
      if type== %对象类型_宠% or type == %对象类型_人%  then
        local att = Char.GetData(CharIndex,%对象_精神%)
      
        local def = Char.GetData(DefCharIndex,%对象_精神%)
        local delta = att-def;
      
        local result =  getModule('magicMod'):calc(delta,Com2,Com3,type)
        -- print("delta com2 type Damage result",delta,Com2,type,Damage,"|"..result)
        Damage = result + Damage
      end
    end



    return Damage
end






--- 加载模块钩子
function balanceModule:onLoad()
  self:regCallback('DamageCalculateEvent', Func.bind(self.MyDamageCalculateEvent,self))


end

--- 卸载模块钩子
function balanceModule:onUnload()
  self:logInfo('unload')
end



return balanceModule
