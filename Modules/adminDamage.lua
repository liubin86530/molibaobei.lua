---ģ����
local Module = ModuleBase:createModule('adminDamage')
--- ����ģ�鹳��
function Module:onLoad()
  self:logInfo('load')
  if getModule('admin') == nil then
    error('adminģ��δ����')
  end
  if getModule('adminCommands') == nil then
    error('adminCommandsģ��δ����')
  end
  self.dmg = nil;
  self.dmg2 = nil;
  getModule('adminCommands'):regCommand('dmg', function(c, args)
    if args[1] == 'off' then
      NLG.SystemMessage(c, '�رչ����˺��޸�')
      self.dmg = nil;
    else
      NLG.SystemMessage(c, '�����˺��޸�Ϊ: ' .. args[1])
      self.dmg = tonumber(args[1])
    end
    return 1
  end)
  getModule('adminCommands'):regCommand('dmg2', function(c, args)
    if args[1] == 'off' then
      NLG.SystemMessage(c, '�رշ����˺��޸�')
      self.dmg2 = nil;
    else
      NLG.SystemMessage(c, '�����˺��޸�Ϊ: ' .. args[1])
      self.dmg2 = tonumber(args[1])
    end
    return 1
  end)
  getModule('adminCommands'):regCommand('hp', function(c, args)
    if args[1] then
      NLG.SystemMessage(c, 'hp����Ϊ: ' .. args[1])
      Char.SetData(c, CONST.CHAR_Ѫ, tonumber(args[1]))
      NLG.UpChar(c)
    end
    return 1
  end)
  getModule('adminCommands'):regCommand('hp2', function(c, args)
    if args[1] then
      NLG.SystemMessage(c, 'hp����Ϊ: ' .. args[1] .. '%')
      Char.SetData(c, CONST.CHAR_Ѫ, tonumber(args[1]) / 100 * Char.GetData(c, CONST.CHAR_���Ѫ));
      NLG.UpChar(c)
    end
    return 1
  end)
  self:regCallback('DamageCalculateEvent', function(charIndex, defCharIndex, oriDamage, damage, battleIndex, com1, com2, com3, defCom1, defCom2, defCom3, flg)
    local admin = getModule('admin')
    if admin:isAdmin(charIndex) and self.dmg ~= nil then
      return self.dmg
    end
    if admin:isAdmin(defCharIndex) then
      self:logDebug('DMG', oriDamage, damage)
      if self.dmg2 ~= nil then
        return self.dmg2
      end
    end
    return damage
  end)
end

--- ж��ģ�鹳��
function Module:onUnload()
  self:logInfo('unload')
end

return Module;
