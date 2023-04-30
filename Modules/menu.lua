local Module = ModuleBase:createModule('menu')

local menutable={{"1.�س�","/hc"},{"2.Զ������","/bank"},{"3.���������ƶ�","/speedup on"},{"4.�رո����ƶ�","/speedup off"},{"5.�����������","/pi"},{"6.��ǰ����","/where"},
{"7.����","/i jd"},{"8.�㵵","/p bp"},{"9.����","/p md 0"},{"10.ϴ��","/p xd 0"},{"11.����","/c zl"},
{"12.�л�","/c zh"},{"13.����","/i xl"},{"14.ϴ��","/redoDp"}}

local function calcWarp()--����ҳ�������һҳ����
  local totalpage = math.modf(#menutable / 8) + 1
  local remainder = math.fmod(#menutable, 8)
  return totalpage, remainder
end

function Module:onLoad()
        self:logInfo('load')
        local menuNPC = self:NPC_createNormal('�ڹҲ˵�', 105502, { x = 6, y = 6, mapType = 0, map = 666, direction = 4 });
        self:NPC_regWindowTalkedEvent(menuNPC, function(npc, player, _seqno, _select, _data)
        local column = tonumber(_data)
    local page = tonumber(_seqno)
    local warpPage = page;
    local winMsg = "1\\n���´�ָ��\\n"
    local winButton = CONST.BUTTON_�ر�;
    local totalPage, remainder = calcWarp()
    --��ҳ16 ��ҳ32 �ر�/ȡ��2

        if _select > 0 then
                if _select == CONST.BUTTON_��һҳ then
                        warpPage = warpPage + 1
                        if (warpPage == totalPage) or ((warpPage == (totalPage - 1) and remainder == 0)) then
                                winButton = CONST.BUTTON_��ȡ��
                        else
                                winButton = CONST.BUTTON_����ȡ��
                        end
                elseif _select == CONST.BUTTON_��һҳ then
                        warpPage = warpPage - 1
                        if warpPage == 1 then
                                winButton = CONST.BUTTON_��ȡ��
                        else
                                winButton = CONST.BUTTON_����ȡ��
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
                NLG.ShowWindowTalked(player, npc, CONST.����_ѡ���, winButton, warpPage, winMsg);
        else
                local count = 8 * (warpPage - 1) + column
                getModule('ng'):handleTalkEvent(player,menutable[count][2]);
        end
        end)

        self:regCallback('CharActionEvent', function(player, actionID)
                if actionID == %����_����% then
                        local msg = "1\\n���´�ָ��\\n"
                        for i = 1, 8 do
                                msg = msg .. menutable[i][1] .. "\\n"
                        end
                        NLG.ShowWindowTalked(player, menuNPC, CONST.����_ѡ���, CONST.BUTTON_��ȡ��, 1, msg);
                end
        end)
end


function Module:onUnload()
        self:logInfo('unload');
end

return Module;