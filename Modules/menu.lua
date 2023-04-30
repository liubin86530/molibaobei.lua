local Module = ModuleBase:createModule('menu')

local menutable={{"1.回城","/hc"},{"2.远程银行","/bank"},{"3.开启高速移动","/speedup on"},{"4.关闭高速移动","/speedup off"},{"5.变更宠物形象","/pi"},{"6.当前坐标","/where"},
{"7.鉴定","/i jd"},{"8.算档","/p bp"},{"9.满档","/p md 0"},{"10.洗档","/p xd 0"},{"11.治疗","/c zl"},
{"12.招魂","/c zh"},{"13.修理","/i xl"},{"14.洗点","/redoDp"}}

local function calcWarp()--计算页数和最后一页数量
  local totalpage = math.modf(#menutable / 8) + 1
  local remainder = math.fmod(#menutable, 8)
  return totalpage, remainder
end

function Module:onLoad()
        self:logInfo('load')
        local menuNPC = self:NPC_createNormal('内挂菜单', 105502, { x = 6, y = 6, mapType = 0, map = 666, direction = 4 });
        self:NPC_regWindowTalkedEvent(menuNPC, function(npc, player, _seqno, _select, _data)
        local column = tonumber(_data)
    local page = tonumber(_seqno)
    local warpPage = page;
    local winMsg = "1\\n请下达指令\\n"
    local winButton = CONST.BUTTON_关闭;
    local totalPage, remainder = calcWarp()
    --上页16 下页32 关闭/取消2

        if _select > 0 then
                if _select == CONST.BUTTON_下一页 then
                        warpPage = warpPage + 1
                        if (warpPage == totalPage) or ((warpPage == (totalPage - 1) and remainder == 0)) then
                                winButton = CONST.BUTTON_上取消
                        else
                                winButton = CONST.BUTTON_上下取消
                        end
                elseif _select == CONST.BUTTON_上一页 then
                        warpPage = warpPage - 1
                        if warpPage == 1 then
                                winButton = CONST.BUTTON_下取消
                        else
                                winButton = CONST.BUTTON_上下取消
                        end
                elseif _select == 2 then
                        warpPage = 1
                        return
                end
                local count = 8 * (warpPage - 1)
                if warpPage == totalPage then
                        for i = 1 + count, remainder + count do
                                winMsg = winMsg .. menutable[i][1] .. "\\n"
                        end
                else
                        for i = 1 + count, 8 + count do
                                winMsg = winMsg .. menutable[i][1] .. "\\n"
                        end
                end
                NLG.ShowWindowTalked(player, npc, CONST.窗口_选择框, winButton, warpPage, winMsg);
        else
                local count = 8 * (warpPage - 1) + column
                getModule('ng'):handleTalkEvent(player,menutable[count][2]);
        end
        end)

        self:regCallback('CharActionEvent', function(player, actionID)
                if actionID == %动作_坐下% then
                        local msg = "1\\n请下达指令\\n"
                        for i = 1, 8 do
                                msg = msg .. menutable[i][1] .. "\\n"
                        end
                        NLG.ShowWindowTalked(player, menuNPC, CONST.窗口_选择框, CONST.BUTTON_下取消, 1, msg);
                end
        end)
end


function Module:onUnload()
        self:logInfo('unload');
end

return Module;