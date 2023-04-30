---模块类
local module = ModuleBase:createModule('battleExtend')

function module:getEntryPositionBySlot(battleIndex,slot)
  if battleIndex < 0 or battleIndex >= Addresses.BattleMax then
    return -3
  end
  local battleAddr = Addresses.BattleTable + battleIndex * 0x1480
  if FFI.readMemoryDWORD(battleAddr) == 0 then
    return -2
  end
  local start;
  local posOffset;
  local slotDiff
  if slot>=0 and slot <=9 then
    start = 124
    posOffset=slot
    slotDiff=0
  else
    start=2532
    posOffset=slot-10
    slotDiff=10
  end
  
  local offset=start+208*posOffset
  return FFI.readMemoryDWORD(battleAddr+offset)+slotDiff
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
