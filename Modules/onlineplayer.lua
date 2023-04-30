
local module = ModuleBase:createModule('onlineplayer')


local players={}
function module:onLoginEvent(player)
  players[player]=player
  print("��¼",player)
end

function module:onLogoutEvent(player)
  players[player]=nil
  print("allout",player)
end

function module:makeAllOut(player)
  if tonumber(Char.GetData(player,%����_GM%)) < 1 then
    return;
  end
  
  for k,v in pairs(players) do
  
      
    if v ~= nil and v ~= player then
      print("����",v)
      NLG.DropPlayer(v)
    end

  end
  NLG.SystemMessage(player, "[��ʾ]�Ѿ��ߵ�ȫ�����.")
end
function module:getPlayers()
  return players;
end

function module:onLoad()
  self:logInfo('load')
  self:regCallback('LoginEvent', Func.bind(self.onLoginEvent, self));
  self:regCallback('LogoutEvent', Func.bind(self.onLogoutEvent, self));
  -- self:regCallback('DropEvent', Func.bind(self.onAllOutEvent, self));
end

function module:onUnload()
  self:logInfo('unload')
end

return module;
