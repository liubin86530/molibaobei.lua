
local module = ModuleBase:createModule('onlineplayer')


local players={}
function module:onLoginEvent(player)
  players[player]=player
  print("登录",player)
end

function module:onLogoutEvent(player)
  players[player]=nil
  print("allout",player)
end

function module:makeAllOut(player)
  if tonumber(Char.GetData(player,%对象_GM%)) < 1 then
    return;
  end
  
  for k,v in pairs(players) do
  
      
    if v ~= nil and v ~= player then
      print("踢下",v)
      NLG.DropPlayer(v)
    end

  end
  NLG.SystemMessage(player, "[提示]已经踢掉全部玩家.")
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
