local module = ModuleBase:createModule('heroes')
local JSON=require "lua/Modules/json"
local _ = require "lua/Modules/underscore"
local skillInfo = dofile("lua/Modules/autoBattleParams.lua")
local sgModule = getModule("setterGetter")
local heroesTpl = dofile("lua/Modules/heroesTpl.lua")
local heroesAI = getModule("heroesAI")
local resetCharBattleState = ffi.cast('int (__cdecl*)(uint32_t a1)', 0x0048C020);

-- Ӣ��ħ�� ���ʣ�����Ϊ0.5 ��Ϊ ԭ����һ�룩
local heroFpReduce=0.3

-- �ƹ�npc����ļ�б�
local heroesR=_.select(heroesTpl,function(heroes) return heroes[20]==1 end)


---Ǩ�ƶ���
module:addMigration(1, 'init des_heroes', function()
  SQL.querySQL([[
      CREATE TABLE if not exists `des_heroes` (
    `id` varchar(11) COLLATE gbk_bin NOT NULL,
    `cdKey` varchar(32) COLLATE gbk_bin NOT NULL,
    `regNo` int(11) NOT NULL,
    `value` mediumtext COLLATE gbk_bin,
    `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    KEY `is_deleted` (`is_deleted`) USING BTREE
  ) ENGINE=Innodb DEFAULT CHARSET=gbk COLLATE=gbk_bin
  ]])
end);



local heroesFn = getModule("heroesFn")
-- SECTION  ���� �����̿���
function module:recruitTalked(npc, charIndex, seqno, select, data) 
  -- print(npc, charIndex, seqno, select, data)
  data=tonumber(data)
  if select == CONST.BUTTON_�ر� then
    return ;
  end
  -- NOTE  1 �ƹ� ��ļ
  if seqno== 1 and data>0 then
    -- ��ļӢ��
    if data==1 then
      self:showRecruitWindow(charIndex);
    end
    -- ����
    if data==2 then
      sgModule:set(charIndex,"heroListPage",1)
      self:showHeroListWindow(charIndex,1);
    end
  end
  -- NOTE  2 ѡ�������ӵ�Ӣ��
  if seqno== 2 and data>0 then
    local heroesData = sgModule:get(charIndex,"heroes")
    if #heroesData>=16 then
      NLG.SystemMessage(charIndex,"��ʧ�ܡ�����Ӷ16��Ӣ��")
      return
    end
    -- ���ݳ�ʼ��
    -- local randomHeroes = sgModule:get(charIndex,"randomHeroes")
    local toGetHeroData = heroesR[data]
    local toGetId = toGetHeroData[1]
    local isOwned = _.any(heroesData,function(heroData) return heroData.tplId == toGetId  end)
    if isOwned then
      NLG.Say(charIndex,self.shortcutNpc,"��ʧ�ܡ�Ӣ��"..toGetHeroData[2].."�Ѿ���Ӷ",CONST.��ɫ_��ɫ,0)
      return
    end
    local isAbleHire = toGetHeroData[17]==nil and true or toGetHeroData[17](charIndex)
    if not isAbleHire then
      return;
    end 

    local heroData = heroesFn:initHeroData(toGetHeroData,charIndex)
    table.insert(heroesData,heroData)
    sgModule:set(charIndex,"heroes",heroesData)
   
    NLG.SystemMessage(charIndex,"��Ӣ�ۼ������£����ھƹݲ鿴Ӣ��")
  end
  --  NOTE  3 �����ʾӢ���б�
  if seqno == 3 then
    
    if data<0 then
      -- ѡ�������һҳ ��һҳ
      local page;
      if select == 32 then
        page =  sgModule:get(charIndex,"heroListPage")+1
        
      elseif select == 16 then
        page =  sgModule:get(charIndex,"heroListPage")-1
      end
      -- ������һ��
      if page ==0 then
        self:recruit(self.shortcutNpc,charIndex)
      end
      sgModule:set(charIndex,"heroListPage",page)
      self:showHeroListWindow(charIndex,page)
    else
      -- ѡ�����Ӣ��  �������Ӣ�۽���
      self:showHeroOperationWindow(charIndex,data)
    end
    
    
  end
  --  SECTION 4 ���ѡ�� Ӣ�۵Ĳ���
  if seqno==4  then

    if data<0 then
      -- NOTE ���� Ӣ�� �б�ҳ
      if select == 16 then
        local page =  sgModule:get(charIndex,"heroListPage")
        self:showHeroListWindow(charIndex,page)
      end
    else
      --NOTE ����/����
      if data == 1 then
        self:handleCampaign(charIndex)
      end
      --NOTE �鿴״̬
      if data == 2 then
        self:showHeroDataWindow(charIndex)
      end
      --NOTE ���
      if data == 3 then
        self:showFireConfirmWindow(charIndex)
      end
    end
    
  end
  -- !SECTION
  -- NOTE 5 �鿴Ӣ��״̬
  if seqno ==5  then

    -- NOTE ���� Ӣ�� ����ҳ
    if select == 16 then
      local heroData = sgModule:get(charIndex,"heroSelected")
      self:reShowHeroOperationWindow(charIndex,heroData)
    end

  end
  --  SECTION  6 ����������ҳ ѡ����
  if seqno ==6 and data>0 then
    -- NOTE �ټ�Ӣ��
    if data==1 then
      self:gatherHeroes(charIndex);
    end
     -- NOTE �򿪴�
    if data==2 then
      heroesFn:partyFeverControl(charIndex,1);
    end
    -- NOTE �رմ�
    if data==3 then
      heroesFn:partyFeverControl(charIndex,0);
    end
    -- NOTE Ӣ�۹���
    if data == 4 then
      self:showCampHeroesList(charIndex)
    end
    -- NOTE ����
    if data == 5 then
      self:heal(charIndex)
    end
    -- NOTE ����һ��
    if data == 6 then
      self:showPartyStatus(charIndex)
    end
    -- NOTE �������ˮ��
    if data == 7 then
      sgModule:set(charIndex,"heroSelected",nil)
      self:showCrystalSelection(charIndex)
    end
  end
  -- !SECTION
  --  NOTE  7 ����Ӣ�� ѡ���
  if seqno==7 and data>0 then
    self:showCampHeroOperationWindow(charIndex,data)
  end
  --  SECTION 8 ����Ӣ�� ����ѡ��
  if seqno==8  then
    if data<0 then
      -- if select == CONST.BUTTON_��һҳ then
      --   self:showHeroOperationSecWindow(charIndex)
      -- end
      if select == 16 then
        self:showCampHeroesList(charIndex)
      end
      
    else
      -- NOTE �鿴ʵʱ״̬
      if data == 1 then
        sgModule:set(charIndex,"statusPage",1)
        self:showCampHeroDataWindow(charIndex,1)
      end
      -- NOTE �鿴���� ����
      if data == 2 then
        sgModule:set(charIndex,"statusPage",1)
        -- 0 ��ʾ����
        sgModule:set(charIndex,"statusItemWindow",0)
        self:showCampHeroItemWindow(charIndex,1)
      end
      --NOTE �鿴���� ɾ��
      if data == 3 then
        sgModule:set(charIndex,"statusPage",1)
        -- 1 ��ʾɾ��
        sgModule:set(charIndex,"statusItemWindow",1)
        self:showCampHeroItemWindow(charIndex,1)
      end
      --NOTE  �������
      if data ==4 then
        self:showCampHeroPetWindow(charIndex)
      end
      -- NOTE �ӵ�
      if data ==5 then
        self:showHeroOperationSecWindow(charIndex)
      end
      -- NOTE ս��ӵ�
      -- if data ==6 then
      --   -- sgModule:set(charIndex,"statusPage",1)
      --   -- sgModule:set(charIndex,"pointSetting",{})
      --   -- self:showBattlePetSetPoint(charIndex,1)
      -- end
      -- NOTE ս��AI�趨
      if data ==6 then
        sgModule:set(charIndex,"statusPage",1)
        self:showCampHeroSkills(charIndex,1)
      end
      -- NOTE ����ս��AI�趨
      if data ==7 then
        sgModule:set(charIndex,"statusPage",1)
        self:showPetSkills(charIndex,1)
      end
      -- NOTE ����ˮ��
      if data ==8 then
        sgModule:set(charIndex,"statusPage",1)
        self:showCrystalSelection(charIndex,1)
      end
    end
  end
  -- !SECTION
  -- NOTE 9 ����Ӣ�� ״̬ ����Ϣ��
  if seqno ==9 then
    -- ѡ�������һҳ ��һҳ
    local page;
    if select == 32 then
      page =  sgModule:get(charIndex,"statusPage")+1
      
    elseif select == 16 then
      page =  sgModule:get(charIndex,"statusPage")-1
    end
    sgModule:set(charIndex,"statusPage",page)
    self:showCampHeroDataWindow(charIndex,page)

  end
  -- NOTE 10 ����Ӣ�� ���� 
  if seqno ==10  then
    -- ѡ�������һҳ ��һҳ
    if data<0 then
      local page;
      if select == 32 then
        page =  sgModule:get(charIndex,"statusPage")+1
        
      elseif select == 16 then
        page =  sgModule:get(charIndex,"statusPage")-1
      end
      if page ==0 then
        -- ������һ��
        self:showCampHeroOperationWindow(charIndex,nil,sgModule:get(charIndex,"heroSelected"))
        return
      end

      sgModule:set(charIndex,"statusPage",page)
      self:showCampHeroItemWindow(charIndex,page)
    else
      local statusItemWindow = sgModule:get(charIndex,"statusItemWindow")
      if statusItemWindow == 0 then
        self:toSwitchItemWithPlayer(charIndex,data)
      else
        self:delCampHeroItem(charIndex,data)
      end

    end

  end
  -- NOTE 11 ��� ���� ���
  if seqno ==11  then
    -- ѡ�������һҳ ��һҳ
    if data<0 then
      local page;
      if select == 32 then
        page =  sgModule:get(charIndex,"playerPage")+1
        
      elseif select == 16 then
        page =  sgModule:get(charIndex,"playerPage")-1
      end
      sgModule:set(charIndex,"playerPage",page)
      self:showPlayerItem(charIndex,page)
    else
      -- ѡ�� ��� ���� ��Ʒ����Ӣ��֮ǰѡ����Ʒ����
      self:switchItem(charIndex,data)
    end
    

  end
  -- NOTE 13 Ӣ�۳����б�
  if seqno== 13 then
    if data<0 then
    else
      self:showPetOperationWindow(charIndex,data)
    end
  end
  -- SECTION 14 Ӣ�۳���������
  if seqno== 14 then
    if data<0 then
    else
      if data == 1 then
        --NOTE ��������
        self:showPlayerPetWindow(charIndex,data)
      end
      if data == 2 then
        --NOTE ��ս/��Ϣ
        self:setPetDeparture(charIndex)
      end
      if data ==3 then
        --NOTE ����״̬
        sgModule:set(charIndex,"statusPage",1)
        self:showPetDataWindow(charIndex,1)
      end
      -- if data ==4 then
      --   -- ����ս������
      --   sgModule:set(charIndex,"statusPage",1)
      --   self:showPetSkills(charIndex,1)
      -- end
      
    end
  end
  -- !SECTION
  -- NOTE 15 ��ҳ����б�
  if seqno== 15 then
    if data<0 then
    else
      self:switchPet(charIndex,data)
    end
  end
  -- NOTE 16 Ӣ�۳���״̬ ��Ϣ��
  if seqno== 16 then
    -- ѡ�������һҳ ��һҳ
    local page;
    if select == 32 then
      page =  sgModule:get(charIndex,"statusPage")+1
      
    elseif select == 16 then
      page =  sgModule:get(charIndex,"statusPage")-1
    end
    sgModule:set(charIndex,"statusPage",page)
    self:showPetDataWindow(charIndex,page)
  end
  -- NOTE 17 Ӣ�ۼӵ� �����
  if seqno== 17 then
    
    -- ѡ�������һҳ ��һҳ
    local page=sgModule:get(charIndex,"statusPage");
    heroesFn:cachePointSetting(charIndex,page,data or 0)
    if select == 32 then
      page =  page+1
      
    elseif select == 16 then
      page =  page-1
    end
    sgModule:set(charIndex,"statusPage",page)
    if page>5 then
      self:setPoint(charIndex)
      return;
    end
    self:showCampHeroSetPoint(charIndex,page)
  end
  -- NOTE 18 Ӣ��ս��AIѡ���
  if seqno== 18 then
    if data<0 then

    else
      -- ����Ӣ��ս������
      self:setHeroBattleSkill(charIndex,data)
    end

  end
  -- NOTE 19 ����ս��AIѡ���
  if seqno== 19 then
    if data<0 then
      -- ѡ�������һҳ ��һҳ
      local page;
      if select == 32 then
        page =  sgModule:get(charIndex,"statusPage")+1
        
      elseif select == 16 then
        page =  sgModule:get(charIndex,"statusPage")-1
      end
      sgModule:set(charIndex,"statusPage",page)
      self:showPetSkills(charIndex,page)
    else
      -- ���ó���ս������
      self:setPetBattleSkill(charIndex,data)
    end

  end
  -- NOTE 20 ���Ӣ��ȷ�ϴ��� 
  if seqno== 20 then
    if select == CONST.BUTTON_ȷ�� then
      self:fireHero(charIndex)
    else
    end

  end
  -- NOTE 22 ս��ӵ� �����
  if seqno== 22 then
  
    -- ѡ�������һҳ ��һҳ
    local page=sgModule:get(charIndex,"statusPage");
    heroesFn:cachePointSetting(charIndex,page,data or 0)
    if select == 32 then
      page =  page+1
      
    elseif select == 16 then
      page =  page-1
    end
    sgModule:set(charIndex,"statusPage",page)
    if page>5 then
      self:setPetPoint(charIndex)
      return;
    end
    self:showBattlePetSetPoint(charIndex,page)
  end
  -- SECTION 23 Ӣ�ۼӵ���ҳ
  if seqno== 23 then
    if data<0 then
      -- ѡ�������һҳ ��һҳ
      if select == CONST.BUTTON_��һҳ then
        local heroData = sgModule:get(charIndex,"heroSelected")
        self:showCampHeroOperationWindow(charIndex,nil,heroData)
      end
    else
      -- NOTE Ӣ���ֶ��ӵ�
      if data == 1 then
        sgModule:set(charIndex,"statusPage",1)
        sgModule:set(charIndex,"pointSetting",{})
        self:showCampHeroSetPoint(charIndex,1)
      end
      -- NOTE �����ֶ��ӵ�
      if data == 2 then
        sgModule:set(charIndex,"statusPage",1)
        sgModule:set(charIndex,"pointSetting",{})
        self:showBattlePetSetPoint(charIndex,1)
      end
      -- NOTE Ӣ���Զ��ӵ�����
      if data == 3 then
        self:showAutoPointSelection(charIndex)
      end
      -- NOTE �����Զ��ӵ�����
      if data == 4 then
        self:showPetAutoPointSelection(charIndex)
      end
      -- NOTE ����/�ر�Ӣ���Զ��ӵ�
      if data ==5 then
        self:swtichAutoPointing(charIndex,0)
      end
      -- NOTE ����/�ر�ս���Զ��ӵ�
      if data ==6 then
        self:swtichAutoPointing(charIndex,1)
      end
    end
   
  end
  -- !SECTION
  -- NOTE 24 ѡ���˼ӵ�ģʽ
  if seqno== 24 then
    if data<0 then
      -- ѡ�������һҳ ��һҳ
      if select == CONST.BUTTON_��һҳ then
        self:showAutoPointSelection(charIndex)
      end
    else
      
      self:setAutoPionting(charIndex,data)
    end
    
  end
  -- NOTE 25 ѡ����ս��ӵ�ģʽ
  if seqno== 25 then
    if data<0 then
      -- ѡ�������һҳ ��һҳ
      if select == CONST.BUTTON_��һҳ then
        self:showAutoPointSelection(charIndex)
      end
    else
      
      self:setPetAutoPionting(charIndex,data)
    end
  end
  -- NOTE 26 ѡ����ˮ��
  if seqno== 26 then
    if data<0 then
      -- ѡ�������һҳ ��һҳ
      if select == CONST.BUTTON_��һҳ then
        -- ������һ��
        self:showCampHeroOperationWindow(charIndex,nil,sgModule:get(charIndex,"heroSelected"))
      end
    else
      if sgModule:get(charIndex,"heroSelected") == nil then
        self:changeCrystalForHeroes(charIndex,data)
      else
        self:changeCrystal(charIndex,data)
      end
      
    end
    
  end
end

-- !SECTION  ���� �����̿���

-- NOTE ��ʾ ��ļӢ�� �Ի��� seqno:2
function module:showRecruitWindow(charIndex) 
  local title="@cѡ��һ��Ӣ��"
  local items={}


  -- local randomHeroes={}
  -- heroesFn:deepcopy(randomHeroes,heroesTpl)
  -- heroesFn:shuffle(randomHeroes)
  -- local randomHeroes = {table.unpack(randomHeroes,1,5)}
  -- sgModule:set(charIndex,"randomHeroes",randomHeroes)
  for k,v in pairs(heroesR) do
    table.insert(items,v[2].." ��"..v[3].."�� "..v[15])
  end

  local windowStr = self:NPC_buildSelectionText(title,items);
  NLG.ShowWindowTalked(charIndex, self.shortcutNpc, CONST.����_ѡ���, CONST.BUTTON_�ر�, 2,windowStr);
end


-- NOTE �ƹ���ҳ �Ի��� seqno:1
function module:recruit(npc,charIndex)
  local windowStr = heroesFn:buildRecruitSelection()
  NLG.ShowWindowTalked(charIndex, self.shortcutNpc, CONST.����_ѡ���, CONST.BUTTON_�ر�, 1,windowStr);
end
--NOTE  ��ʾӢ���б� seqno:3
function module:showHeroListWindow(charIndex,page)
  local title = "    Ӣ���б�"
  -- Ӣ�� ���� ��ȡ
  local heroesData = sgModule:get(charIndex,"heroes")
 
  -- ��� Ӣ������Ϊ�б�
  local items = _.map(heroesData,function(data) return heroesFn:buildListForHero(data) end)
  -- ��ȡ ������ʾ��Ҫ������
  local buttonType,windowStr=self:dynamicListData(items,title,page)
  NLG.ShowWindowTalked(charIndex, self.shortcutNpc, CONST.����_ѡ���, buttonType, 3,windowStr);
end

-- NOTE ��̬�б���������
function module:dynamicListData(list,title,page)
 
  page = page or 1 ;
  
  local start_index = (page-1)*8+1
  local totalPage,rest = math.modf(#list/8)
  
  if rest>0 then
    totalPage=totalPage+1
  end
  
  local items = _.slice(list, start_index, 8)
  local windowStr = self:NPC_buildSelectionText(title,items);
  local buttonType;
  if  totalPage ==1 then
    buttonType=CONST.BUTTON_��ȡ��
  elseif page ==1 then
    buttonType=CONST.BUTTON_����ȡ��
  elseif page == totalPage then
    buttonType=CONST.BUTTON_��ȡ��
  else 
    buttonType = CONST.BUTTON_����ȡ��
  end
  return buttonType,windowStr
end
-- NOTE �״� ��ʾӢ�۲��� ��� seqno: 4
function module:showHeroOperationWindow(charIndex,data)
  
  local heroesData=sgModule:get(charIndex,"heroes")
  local page = sgModule:get(charIndex,"heroListPage")
 
  local index = (page-1)*8+data
  local heroData = heroesData[index]
  
  -- ���� ѡ�е�hero id
  sgModule:set(charIndex,"heroSelected",heroData)
  local windowStr = heroesFn:buildOperatorForHero(heroData)
  NLG.ShowWindowTalked(charIndex, self.shortcutNpc, CONST.����_ѡ���, CONST.BUTTON_��ȡ��, 4,windowStr);
end
-- NOTE ���� ��ʾӢ�۲��� ��� seqno: 4
function module:reShowHeroOperationWindow(charIndex,heroData)
  
  local heroData=  sgModule:get(charIndex,"heroSelected");
  -- local heroData = heroesFn:getHeroDataByid(charIndex,heroId)

  local windowStr = heroesFn:buildOperatorForHero(heroData)
  NLG.ShowWindowTalked(charIndex, self.shortcutNpc, CONST.����_ѡ���, CONST.BUTTON_��ȡ��, 4,windowStr);
end


-- NOTE ��ʾ Ӣ����ֵ seqno:5
function module:showHeroDataWindow(charIndex)
  local heroData=  sgModule:get(charIndex,"heroSelected");
  -- local heroData = heroesFn:getHeroDataByid(charIndex,heroId)
  local windowStr = heroesFn:buildAttrDescriptionForHero(heroData)
  NLG.ShowWindowTalked(charIndex, self.shortcutNpc, CONST.����_����Ϣ��, CONST.BUTTON_��ȡ��, 5,windowStr);
end

-- NOTE ���� ����/����  ����Ӣ�۲��� ��� 
function module:handleCampaign(charIndex)
  local heroData=  sgModule:get(charIndex,"heroSelected");
  -- local heroData = heroesFn:getHeroDataByid(charIndex,heroId)
  if heroData.status == 1 then
    heroData.status=2
    -- ɾ��Ӣ��
    local res,err =pcall( function() 
      heroesFn:cacheHeroAttrData(heroData)
      heroesFn:cacheHeroItemData(heroData)
      heroesFn:cacheHeroPetsData(heroData)
      heroesFn:delHeroDummy(charIndex,heroData)
    end)
    -- print(res,err)
  else
    local heroesData = sgModule:get(charIndex,"heroes");
    -- �ж��Ƿ���4��
    local count = _.reduce(heroesData, 0, 
      function(count, item) 
        if item.status == 1 then 
          return count+1
        end
        return count
      end)
    if count >=4 then
      NLG.Say(charIndex,self.shortcutNpc,"����Ӣ�۲��ܳ���4��",CONST.��ɫ_��ɫ,0)
    else
      heroData.status=1
      -- ���ɼ���
      heroesFn:generateHeroDummy(charIndex,heroData)
    end
    
  end
  local page =  sgModule:get(charIndex,"heroListPage")
  self:showHeroListWindow(charIndex,page)
  -- self:reShowHeroOperationWindow(charIndex,heroData)
end

-- NOTE ��½ʱ ����Ӣ�� ����
function module:onLoginEvent(charIndex)
  local heroesData = heroesFn:queryHeroesData(charIndex);
  heroesData= heroesData or {}  
  sgModule:set(charIndex,"heroes",heroesData)
  local campHeroesData=heroesFn:getCampHeroesData(charIndex)
  -- ��¼��ʼ  ���� ����Ӣ��
  _.each(campHeroesData,function(heroData) 
    -- if heroData.index~=nil then
    --   if Char.IsValidCharIndex(heroData.index) then
    --     Char.JoinParty(heroData.index, charIndex)
    --   else
    --     heroesFn:generateHeroDummy(charIndex,heroData)
    --   end
    -- else
    --   heroesFn:generateHeroDummy(charIndex,heroData)
    -- end
    heroesFn:generateHeroDummy(charIndex,heroData)
  end)
end
-- NOTE  �ǳ�ʱ �ұ���Ӣ�� ����
function module:onLogoutEvent(charIndex)
  print("�ǳ�ʱ ����",charIndex)
  local heroesData=sgModule:get(charIndex,"heroes")
  local campHeroesData=heroesFn:getCampHeroesData(charIndex)
  _.each(campHeroesData,function(heroData)
    print(heroData.index,Char.IsValidCharIndex(heroData.index))
    if not Char.IsValidCharIndex(heroData.index) then
      
      print("��Ч��Ӣ��",heroData.index)
      return
    end
    --��������  ɾ�� ����  
    heroesFn:cacheHeroAttrData(heroData)
    heroesFn:cacheHeroItemData(heroData)
    heroesFn:cacheHeroPetsData(heroData)
    heroesFn:delHeroDummy(charIndex,heroData)
  end)
  heroesFn:saveHeroesData(charIndex,heroesData)
end
-- NOTE ����Ӣ������
function module:saveHeroesOnTime(charIndex)
  local heroesData=sgModule:get(charIndex,"heroes")
  local campHeroesData=heroesFn:getCampHeroesData(charIndex)
  _.each(campHeroesData,function(heroData) 
    print("=====",heroData.index,Char.IsValidCharIndex(heroData.index))
    if not Char.IsValidCharIndex(heroData.index) then
      
      print("��Ч��Ӣ��",heroData.index)
      return
    end
    --��������  ɾ�� ����  
    heroesFn:cacheHeroAttrData(heroData)
    heroesFn:cacheHeroItemData(heroData)
    heroesFn:cacheHeroPetsData(heroData)
  end)
  heroesFn:saveHeroesData(charIndex,heroesData)
end

-- NOTE ��ݼ�ctrl+3 ���� �����˵� 
function module:shortcut(charIndex, actionID)
  
  if actionID == %����_��ͷ% then
    self:management(self.shortcutNpc,charIndex);
  end
end
-- NOTE  ���� ��ҳ seqno:6
function module:management(npc, charIndex)
  local windowStr= heroesFn:buildManagementForHero(charIndex)
  NLG.ShowWindowTalked(charIndex, self.shortcutNpc, CONST.����_ѡ���, CONST.BUTTON_�ر�, 6,windowStr);
end

-- NOTE Ӣ����� and �ۼ�
function module:gatherHeroes(charIndex)
  local heroesData = sgModule:get(charIndex,"heroes")
  local Target_FloorId=Char.GetData(charIndex, CONST.CHAR_��ͼ)
  local Target_MapId=Char.GetData(charIndex, CONST.CHAR_��ͼ����)
  local Target_X=Char.GetData(charIndex, CONST.CHAR_X)
  local Target_Y=Char.GetData(charIndex, CONST.CHAR_Y)
  local campHeroes = _.select(heroesData,function(item) return item.status==1 end)
  for _,heroData in pairs(campHeroes) do
    local heroIndex  = heroData.index
    -- �ȴ�����

   
    
    -- �жϱ��������Ƿ�����
    local partyNum = Char.PartyNum(charIndex)
    if(partyNum>=5) then 
      NLG.SystemMessage(charIndex, "��������5��");	
      
      return 
    end

    
    if(heroIndex>0) then
      -- �������ߵض�������
      local invitedPartyNum = Char.PartyNum(heroIndex)

      if(invitedPartyNum>0) then
        NLG.SystemMessage(charIndex, "Ӣ�ۡ�"..heroData.name.."�����ڶ�����");
      else
        -- ��һ������ ��Ա���ڶ��������ӳ�
        Char.Warp(heroIndex, Target_MapId, Target_FloorId, Target_X, Target_Y)
        Char.JoinParty(heroIndex, charIndex) 
      end

    end
  end
end
-- NOTE ��ʾ����Ӣ���б� seqno:7
function module:showCampHeroesList(charIndex)
  local windowStr = heroesFn:buildCampHeroesList(charIndex)
  NLG.ShowWindowTalked(charIndex, self.shortcutNpc, CONST.����_ѡ���, CONST.BUTTON_�ر�, 7,windowStr);
end

-- NOTE ��ʾӢ�۵Ĳ������ seqno:8
function module:showCampHeroOperationWindow(charIndex,data,heroData)
  if data~= nil and heroData == nil then
    local campHeroes = heroesFn:getCampHeroesData(charIndex)
    heroData = campHeroes[data]
    sgModule:set(charIndex,"heroSelected",heroData)
  elseif data== nil and heroData ~= nil then
    sgModule:set(charIndex,"heroSelected",heroData)
  end
 
  local windowStr = heroesFn:buildCampHeroOperator(charIndex,heroData)

  NLG.ShowWindowTalked(charIndex, self.shortcutNpc, CONST.����_ѡ���, CONST.BUTTON_��ȡ��, 8,windowStr);
end


-- NOTE ��ʾ  ����Ӣ��״̬ seqno:9
function module:showCampHeroDataWindow(charIndex,page)
  local heroData=  sgModule:get(charIndex,"heroSelected");
  local windowStr = heroesFn:buildDescriptionForCampHero(heroData,page)
  local buttonType
  if page==1 then
    buttonType=CONST.BUTTON_��ȡ��
  else
    buttonType=CONST.BUTTON_��ȡ��
  end
  NLG.ShowWindowTalked(charIndex, self.shortcutNpc, CONST.����_����Ϣ��, buttonType, 9,windowStr);
end

--  NOTE ��ʾ ����Ӣ�۵��� seqno:10
function module:showCampHeroItemWindow(charIndex,page)
  local heroData=  sgModule:get(charIndex,"heroSelected");
  local items=heroesFn:buildCampHeroItem(charIndex,heroData)
  local title=heroData.name.."����Ʒ"
  -- ��ȡ ������ʾ��Ҫ������
  local buttonType,windowStr=self:dynamicListData(items,title,page)
  NLG.ShowWindowTalked(charIndex, self.shortcutNpc, CONST.����_ѡ���, buttonType, 10,windowStr);
end

-- NOTE ѡ�� ����Ӣ�۵��� 
function module:toSwitchItemWithPlayer(charIndex,data)
  local heroData=  sgModule:get(charIndex,"heroSelected");
  local statusPage = sgModule:get(charIndex,"statusPage");
  local heroItemSlotSelected = (statusPage-1)*8+data-1
  -- ��¼ ѡ���Ӣ�� slot
  sgModule:set(charIndex,"heroItemSlotSelected",heroItemSlotSelected);
  sgModule:set(charIndex,"playerPage",1)
  self:showPlayerItem(charIndex,1)
end
-- NOTE ɾ�� ѡ�е�Ӣ�۵���
function module:delCampHeroItem(charIndex,data)
  local heroData=  sgModule:get(charIndex,"heroSelected");
  local statusPage = sgModule:get(charIndex,"statusPage");
  local heroItemSlotSelected = (statusPage-1)*8+data-1
  local r = Char.DelItemBySlot(heroData.index,heroItemSlotSelected)
  Item.UpItem(heroData.index,heroItemSlotSelected)
  self:showCampHeroItemWindow(charIndex,statusPage)
end


-- NOTE ��ʾ ��ұ������ߴ��� seqno:11
function module:showPlayerItem(charIndex,page)
  local items=heroesFn:buildPlayerItem(charIndex)
  local title=Char.GetData(charIndex,CONST.CHAR_����).."����Ʒ"
  -- ��ȡ ������ʾ��Ҫ������
  local buttonType,windowStr=self:dynamicListData(items,title,page)
  NLG.ShowWindowTalked(charIndex, self.shortcutNpc, CONST.����_ѡ���, buttonType, 11,windowStr);
end
-- NOTE �����Ʒ��Ӣ�۽���
function module:switchItem(charIndex,data)
  local heroData=  sgModule:get(charIndex,"heroSelected");
  local heroIndex=  heroData.index;
  local playerPage=  sgModule:get(charIndex,"playerPage")
  local playerSlot = (playerPage-1)*8+data+7
  local playerItemIndex =  Char.GetItemIndex(charIndex, playerSlot)
  
  local playerItemData= nil;
  -- ��ҵ���������ȡ
  if playerItemIndex>=0 then
    playerItemData= heroesFn:extractItemData(playerItemIndex);
    Char.DelItemBySlot(charIndex, playerSlot);

    local r = Char.GetEmptyItemSlot(heroIndex);
    if r<0 then
      NLG.SystemMessage(charIndex,"Ӣ�۵ı����������ˣ������ڳ�����")
      return
    end
  end
  
  -- Ӣ�� ���� ������ȡ
  local heroItemSlotSelected=sgModule:get(charIndex,"heroItemSlotSelected");
  local heroItemIndex =  Char.GetItemIndex(heroIndex, heroItemSlotSelected)
  local heroItemData= nil;
  if heroItemIndex>=0 then
    heroItemData= heroesFn:extractItemData(heroItemIndex);
    Char.DelItemBySlot(heroIndex, heroItemSlotSelected);
  end
  
  -- ��Ӣ�۵��� ������� 
  if heroItemData~=nil then
    local itemId = heroItemData[tostring(CONST.����_ID)]
    local itemIndex = Char.GiveItem(charIndex, itemId, 1, false);
    if itemIndex >= 0 then
      heroesFn:insertItemData(itemIndex,heroItemData)
      local slot = Char.GetItemSlot(charIndex, itemIndex)
      if slot ~= playerSlot then
        Char.MoveItem(charIndex, slot, playerSlot, -1)
      end
      Item.UpItem(charIndex,playerSlot)
    end
    
  end
  -- ����ҵ��߸�Ӣ��
  if playerItemData~= nil then
    
  
    local itemId = playerItemData[tostring(CONST.����_ID)]
    local itemIndex = Char.GiveItem(heroData.index, itemId, 1, false);
    if itemIndex >= 0 then
      heroesFn:insertItemData(itemIndex,playerItemData)
      local slot = Char.GetItemSlot(heroIndex, itemIndex)
      -- print("slot",slot,heroItemSlotSelected)
      if slot ~= heroItemSlotSelected then
        Char.MoveItem(heroIndex, slot, heroItemSlotSelected, -1)
      end
      Item.UpItem(heroIndex,heroItemSlotSelected)
      
    end
  end
  NLG.UpChar(heroIndex)
  -- ��ɺ� ��ʾӢ�۱���
  local page = sgModule:get(charIndex,"statusPage")
  self:showCampHeroItemWindow(charIndex,page)
end


-- NOTE ��ʾӢ�۳��� seqno:13
function module:showCampHeroPetWindow(charIndex)
  local heroData=  sgModule:get(charIndex,"heroSelected");
  local windowStr=heroesFn:buildCampHeroPets(heroData)
  NLG.ShowWindowTalked(charIndex, self.shortcutNpc, CONST.����_ѡ���, CONST.BUTTON_��ȡ��, 13,windowStr);
end



-- NOTE ��ʾ ���������� seqno:14
function module:showPetOperationWindow(charIndex,data)
  local heroPetSlotSelected = tonumber(data)-1
  -- ��¼ ѡ��ĳ��� slot
  sgModule:set(charIndex,"heroPetSlotSelected",heroPetSlotSelected);
  local heroData=  sgModule:get(charIndex,"heroSelected");
  local windowStr=  heroesFn:buildCampHeroPetOperator(charIndex,heroData)
  NLG.ShowWindowTalked(charIndex, self.shortcutNpc, CONST.����_ѡ���, CONST.BUTTON_��ȡ��, 14,windowStr);
end




-- NOTE  ��ʾ��ҳ��� seqno:15
function module:showPlayerPetWindow(charIndex)
  local windowStr=heroesFn:buildPlayerPets(charIndex)
  NLG.ShowWindowTalked(charIndex, self.shortcutNpc, CONST.����_ѡ���, CONST.BUTTON_��ȡ��, 15,windowStr);
end

-- NOTE �������� 
function module:switchPet(charIndex,data)
  local heroData=  sgModule:get(charIndex,"heroSelected");
  local heroIndex = heroData.index
  local heroPetSlot =sgModule:get(charIndex,"heroPetSlotSelected");
  local heroPetIndex = Char.GetPet(heroIndex,heroPetSlot)
  local playerPetSlot = tonumber(data)-1
  local playerPetIndex = Char.GetPet(charIndex,playerPetSlot)

  if heroPetIndex >=0 then
    if Char.GetEmptyPetSlot(charIndex) < 0 then
      NLG.SystemMessage(charIndex,"��ҵĳ���������,�����ڳ�һ������")
      return;
    end
    -- ��Ӣ�۳�������
    local r= Char.TradePet(heroIndex, heroPetSlot, charIndex)
    print(r,heroPetSlot)
    if r<0 then
      NLG.SystemMessage(charIndex,"1�����ˣ�")
      return;
    end
    Pet.UpPet(charIndex,heroPetIndex)
  end
  -- ����ҳ����Ӣ��

  if playerPetIndex>=0 then
    local r= Char.TradePet(charIndex, playerPetSlot, heroIndex)
    if r<0 then
      NLG.SystemMessage(charIndex,"2�����ˣ�")
      return;
    end
    Pet.UpPet(heroIndex,playerPetIndex)
  end

  --  ��ɺ󣬷��� Ӣ�۳����б�ҳ
  self:showCampHeroPetWindow(charIndex)
end

-- NOTE ��ʾ  ����״̬���� seqno:16
function module:showPetDataWindow(charIndex,page)
  local heroData=  sgModule:get(charIndex,"heroSelected");
  local heroIndex = heroData.index
  local heroPetSlot =sgModule:get(charIndex,"heroPetSlotSelected");
  local heroPetIndex = Char.GetPet(heroIndex,heroPetSlot)
  if heroPetIndex<0 then
    return;
  end
  local windowStr = heroesFn:buildDescriptionForPet(heroData,heroPetIndex,page)
  local buttonType
  if page==1 then
    buttonType=CONST.BUTTON_��ȡ��
  else
    buttonType=CONST.BUTTON_��ȡ��
  end
  NLG.ShowWindowTalked(charIndex, self.shortcutNpc, CONST.����_����Ϣ��, buttonType, 16,windowStr);
end

-- NOTE ���ó����ս״̬
function module:setPetDeparture(charIndex)
  local heroData=  sgModule:get(charIndex,"heroSelected");
  local heroIndex = heroData.index
  local heroPetSlot =sgModule:get(charIndex,"heroPetSlotSelected");
  local heroPetIndex = Char.GetPet(heroIndex,heroPetSlot)
  local status =  Char.GetData(heroPetIndex, CONST.PET_DepartureBattleStatus);
  if status == CONST.PET_STATE_ս�� then
    Char.SetPetDepartureState(heroIndex,heroPetSlot,CONST.PET_STATE_����)
  else
    Char.SetPetDepartureState(heroIndex,heroPetSlot,CONST.PET_STATE_ս��)
  end

end

-- NOTE ��ʾ ����Ӣ�� �ӵ� seqno:17
function module:showCampHeroSetPoint(charIndex,page)
  local heroData=  sgModule:get(charIndex,"heroSelected");
  local heroIndex = heroData.index

  local windowStr=heroesFn:buildSetPoint(charIndex,heroIndex,page)
  NLG.ShowWindowTalked(charIndex, self.shortcutNpc, CONST.����_�����, CONST.BUTTON_����ȡ��, 17,windowStr);
end
-- NOTE ���üӵ�
function module:setPoint(charIndex,heroIndex)
  local heroData=  sgModule:get(charIndex,"heroSelected");
  local heroIndex = heroData.index
  heroesFn:setPoint(charIndex,heroIndex)
end
-- NOTE ��ʾ���� ս��ӵ� seqno:22
function module:showBattlePetSetPoint(charIndex,page)
  local heroData=  sgModule:get(charIndex,"heroSelected");
  local heroIndex = heroData.index
  local petSlot = Char.GetData(heroIndex, CONST.CHAR_ս��);
  if petSlot<0 then
    NLG.Say(charIndex,self.shortcutNpc,"��������ս������",CONST.��ɫ_��ɫ,0)
    return
  end
  petIndex = Char.GetPet(heroIndex, petSlot);

  local windowStr=heroesFn:buildSetPoint(charIndex,petIndex,page)
  NLG.ShowWindowTalked(charIndex, self.shortcutNpc, CONST.����_�����, CONST.BUTTON_����ȡ��, 22,windowStr);
end

-- NOTE ���ó���ӵ�
function module:setPetPoint(charIndex)
  local heroData=  sgModule:get(charIndex,"heroSelected");
  local heroIndex = heroData.index
  local petSlot = Char.GetData(heroIndex, CONST.CHAR_ս��);
  if petSlot<0 then
    NLG.Say(charIndex,self.shortcutNpc,"��������ս������",CONST.��ɫ_��ɫ,0)
    return
  end
  petIndex = Char.GetPet(heroIndex, petSlot);

  heroesFn:setPoint(charIndex,petIndex)
end


-- NOTE ս����ʼ�¼�
function module:onBattleStart(battleIndex)
  for pos=0,19 do
		local charIndex = Battle.GetPlayer(battleIndex,pos);
		if charIndex<0 then
      return
    end
    if (Char.GetData(charIndex,%����_��%) == %��������_��%) and (not Char.IsDummy(charIndex)) then
      -- ��ȡ �������ڵ�ͼ 
      local Target_FloorId=Char.GetData(charIndex, CONST.CHAR_��ͼ)
      local Target_MapId=Char.GetData(charIndex, CONST.CHAR_��ͼ����)
      local Target_X=Char.GetData(charIndex, CONST.CHAR_X)
      local Target_Y=Char.GetData(charIndex, CONST.CHAR_Y)
      local campHeroesData = heroesFn:getCampHeroesData(charIndex) or {}
      _.each(campHeroesData,function(heroData) 
        local heroIndex = heroData.index
        local floor=Char.GetData(heroIndex, CONST.CHAR_��ͼ)
        local mapId=Char.GetData(heroIndex, CONST.CHAR_��ͼ����)
        if floor ~= Target_FloorId or mapId ~= Target_MapId then
          Char.Warp(heroIndex, Target_MapId, Target_FloorId, Target_X, Target_Y)
        end

      end)
    end
		
	end
end



-- NOTE ս�����غϿ�ʼ ս��ָ��
function module:handleDummyCommand(battleIndex)
  print("�غϿ�ʼǰ")
  local poss={}
  for i = 0, 19 do
    table.insert(poss,i)
  end
  _.each(poss,function(pos) 
    
    local dummyIndex = Battle.GetPlayer(battleIndex, pos);

    
    -- ��������ˣ��˳�
    if dummyIndex < 0 then
      return
    end


    -- ������Ǽ��ˣ��˳�
    if not Char.IsDummy(dummyIndex) then
      return
    end
    -- �������Ӣ�� ���˳�
    local heroesOnline=sgModule:getGlobal("heroesOnline")
    if not heroesOnline[dummyIndex] then
      return
    end
    local heroData = heroesOnline[dummyIndex]
    -- ��� owner���ڱ���ս�����˳�ս��
    local ownerIndex= heroData.owner
    local ownerSlot = Battle.GetSlot(battleIndex,ownerIndex)

    if ownerSlot<0  then
      Battle.ExitBattle(dummyIndex);
      return
    end
    -- ��������ڵȴ�����˳�
    local isWaiting =Battle.IsWaitingCommand(dummyIndex)
    if isWaiting ~=1 then
      return 
    end
    local side=0
    if pos>9 then
      side=1
    end 
    -- ��ȡ ai
    local heroesOnline = sgModule:getGlobal("heroesOnline")

    local aiId = heroData.heroBattleTech
    local aiData =  _.detect(heroesAI.aiData,function(data) return data.id==aiId end)
    local commands=aiData ==nil and {} or aiData.commands

    print("��ʼ����")
    local actionData = heroesAI:calcActionData(dummyIndex,side,battleIndex,pos,commands)
    print("actionData",JSON.stringify(actionData))
    
    -- ��һ������
    Battle.ActionSelect(dummyIndex, actionData[1],actionData[2] , actionData[3]);

    -- -- ��ȡ�����
    local petSLot = math.fmod(pos + 5, 10)+side*10;
    local petIndex = Battle.GetPlayer(battleIndex, petSLot);
    
    if petIndex<0 then
      -- �ڶ�����ͨ����Է�Ѫ���ٵ�
      Battle.ActionSelect(dummyIndex,CONST.BATTLE_COM.BATTLE_COM_ATTACK,heroesAI.target["6"]["fn"](dummyIndex,side,battleIndex,pos,0) ,-1);

    else
      local petAiId = heroData.petBattleTech
      local petAiData =  _.detect(heroesAI.aiData,function(data) return data.id==petAiId end)
      local petCommands=petAiData ==nil and {} or petAiData.commands
      
      local petActionData = heroesAI:calcActionData(petIndex,side,battleIndex,petSLot,petCommands)
      print("����",JSON.stringify(petActionData))
      Battle.ActionSelect(petIndex, petActionData[1],petActionData[2] , petActionData[3]);
    end
  end)
end
-- NOTE ��ȡ ��Ϊ����
-- function module:getActionInfo(techId)
--   if techId == nil then
--     return {CONST.BATTLE_COM.BATTLE_COM_P_PARAMETER,300,1,0}
--   end
--   local result = _.detect(skillInfo.params,function(item) 
--     local ids=item[2]
--     if type(ids) == 'number' then
--       return true 
--     elseif type(ids) == 'table' then
--       if techId >= ids[1] and techId<= ids[2] then
--         return true
--       end
--     end
--     return false
--   end)
--   if result ~=nil and next(result) ~=nil then
--     result[2] = techId
--     return result
--   end
--   return {CONST.BATTLE_COM.BATTLE_COM_P_PARAMETER,300,1,0}
-- end
-- NOTE �����¼�
function module:handleWarpEvent(charIndex,Ori_MapId, Ori_FloorId, Ori_X, Ori_Y, Target_MapId, Target_FloorId, Target_X, Target_Y)
  return 0
end
-- NOTE ���ͺ��¼�
function module:handleAfterWarpEvent(charIndex,Ori_MapId, Ori_FloorId, Ori_X, Ori_Y, Target_MapId, Target_FloorId, Target_X, Target_Y)
  print("���ͺ�battleIndex",Char.GetData(charIndex, CONST.CHAR_����))
  -- ����Ǽ��� �˳�
  if Char.IsDummy(charIndex) then
    return 0;
  end
  local campHeroesData = heroesFn:getCampHeroesData(charIndex) or {}
  
  _.each(campHeroesData,function(heroData) 
    local heroIndex = heroData.index;
    local battleIndex= Char.GetData(heroIndex, CONST.CHAR_BattleIndex)
    
    
    if battleIndex>=0 then
      -- print("winside",Battle.GetWinSide(battleIndex))
    
      if Char.GetData(heroIndex, CONST.CHAR_ս����) > 0 and Battle.GetWinSide(battleIndex)==-1 then
        -- print("��ս���˳�")
        Battle.ExitBattle(heroIndex);
      end
    end

    local partyNum = Char.PartyNum(charIndex)
    if(partyNum>=5) then 	
      return 0
    end

    local invitedPartyNum = Char.PartyNum(heroIndex)
    if invitedPartyNum<=0  then
      -- ��һ������ ��Ա���ڶ��������ӳ�
      Char.Warp(heroIndex, Target_MapId, Target_FloorId, Target_X, Target_Y)
      Char.JoinParty(heroIndex, charIndex) 
    end

  end)
  return 0;
end
-- NOTE ����
function module:heal(charIndex)
  local campHeroesData = heroesFn:getCampHeroesData(charIndex);
  
  _.each(campHeroesData,function(heroData) 
    heroesFn:heal(charIndex,heroData.index)
    -- ���� ����
    for heroPetSlot = 0,4 do
      local petIndex = Char.GetPet(heroData.index,heroPetSlot)
      if petIndex>=0 then
        heroesFn:heal(charIndex,petIndex)
      end
    end
    NLG.UpChar(heroData.index);
  end)
  heroesFn:heal(charIndex,charIndex)
  -- ���� ����
  for heroPetSlot = 0,4 do
    local petIndex = Char.GetPet(charIndex,heroPetSlot)
    if petIndex>=0 then
      heroesFn:heal(charIndex,petIndex)
    end
  end
  NLG.UpChar(charIndex);
end
-- NOTE Ӣ�ۼ������ seq:18
function module:showCampHeroSkills(charIndex,page)
  local heroData=  sgModule:get(charIndex,"heroSelected");
  local skills = heroData.skills;
  local windowStr=heroesFn:buildCampHeroSkills(charIndex,skills)
  NLG.ShowWindowTalked(charIndex, self.shortcutNpc, CONST.����_ѡ���, CONST.BUTTON_��ȡ��, 18,windowStr);
end
-- NOTE ����Ӣ��AI
function module:setHeroBattleSkill(charIndex,data)
  local heroData=  sgModule:get(charIndex,"heroSelected");
  local heroIndex = heroData.index
  local aiId = heroData.skills[data]
  if aiId==nil or  aiId<0 then
    NLG.SystemMessage(charIndex,"���ô�����ѡ����Ч��AI")
    return  
  end
  local aiData = _.detect(heroesAI.aiData,function(ai) return ai.id==aiId end)

  local name=aiData.name
  heroData.heroBattleTech = aiId;
  NLG.SystemMessage(charIndex,"���óɹ���Ӣ�۵�ս��AI��"..name)
end
-- NOTE ��ʾ���＼���б� seqno:19
function module:showPetSkills(charIndex,page)
  local heroData=  sgModule:get(charIndex,"heroSelected");
  local petSkills = heroData.petSkills;
  local windowStr=heroesFn:buildCampHeroSkills(charIndex,petSkills)
  NLG.ShowWindowTalked(charIndex, self.shortcutNpc, CONST.����_ѡ���, CONST.BUTTON_��ȡ��, 19,windowStr);
end
-- NOTE ���� ����AI
function module:setPetBattleSkill(charIndex,data)

  local heroData=  sgModule:get(charIndex,"heroSelected");
  local heroIndex = heroData.index
  local aiId = heroData.petSkills[data]
  if aiId==nil or  aiId<0 then
    NLG.SystemMessage(charIndex,"���ô�����ѡ����Ч�ļ���")
    return  
  end
  local aiData = _.detect(heroesAI.aiData,function(ai) return ai.id==aiId end)
  local name = aiData.name
  heroData.petBattleTech = aiId;
  NLG.SystemMessage(charIndex,"���óɹ��������ս��������"..name)
end
-- NOTE ���Ӣ��
function module:fireHero(charIndex)
  local heroData=  sgModule:get(charIndex,"heroSelected");
  heroesFn:deleteHeroData(charIndex,heroData)
  local page =  sgModule:get(charIndex,"heroListPage")
  self:showHeroListWindow(charIndex,page)
end
-- NOTE ���ȷ�ϴ��� seqno:20
function module:showFireConfirmWindow(charIndex)
  local heroData = sgModule:get(charIndex,"heroSelected");
  local windowStr="@cɾ��Ӣ�ۡ�$6"..heroData.name.."$0��"
  .."\n\n@c$6��ȷ��"
  NLG.ShowWindowTalked(charIndex, self.shortcutNpc, CONST.����_��Ϣ��, CONST.BUTTON_ȷ���ر�, 20, windowStr);

end

-- NOTE  Ӣ�������¼�
function module:onLevelUpEvent(charIndex)
  local name = Char.GetData(charIndex,CONST.CHAR_����)
  logInfo("herolevelup",name,Char.GetData(charIndex,CONST.����_��))

  -- ������Ǽ��ˣ��˳�
  if not Char.IsDummy(charIndex) then
    return
  end
  -- �������Ӣ�� ���˳�
  local heroesOnline=sgModule:getGlobal("heroesOnline")
  local heroData = heroesOnline[charIndex]
  if not heroesOnline[charIndex] then
    return
  end

  -- ��ȡ heroTpl ���� ִ�������ص�����
  local heroTplId = heroData.tplId
  local heroTplData = _.detect(heroesTpl,function(tpl) return tpl[1]==heroTplId end)
  if heroTplData== nil then
    NLG.SystemMessage(charIndex,"������һ�������Ӣ��")
  end
  if heroTplData and  heroTplData[16] ~= nil then
    -- �����charIndex
    heroTplData[16](charIndex)
  end

  -- �ر����Զ��ӵ㣬�˳�
  if heroData.isAutoPointing == 0 then
    return
  end
  local levelUpPoint = Char.GetData(charIndex,CONST.CHAR_������)
  local times,rest = math.modf(levelUpPoint/4)
  
  for i=1,times+1 do
    print("ִ�мӵ�",i)
    heroesFn:autoPoint(charIndex,heroData.autoPointing)
  end

  NLG.SystemMessage(heroData.owner,name.."�����ˣ��Զ��ӵ㣺"..(heroData.autoPointing))
end

-- NOTE ս�������¼�
function module:onPetLevelUpEvent(charIndex)
  local name = Char.GetData(charIndex,CONST.CHAR_����)
  logInfo("petlevelup",name,Char.GetData(charIndex,CONST.����_��))

  -- �������Ӣ�� ���˳�
  local heroesOnline=sgModule:getGlobal("heroesOnline")
  if not heroesOnline[charIndex] then
    return
  end
  local heroData = heroesOnline[charIndex]
  local heroIndex = heroData.index;

  -- �ر����Զ��ӵ㣬�˳�
  if heroData.isPetAutoPointing == 0 then
    return
  end

  local petSlot = Char.GetData(heroIndex, CONST.CHAR_ս��);
  if petSlot<0 then
    NLG.Say(charIndex,-1,"[����]�Ҳ���ս��",CONST.��ɫ_��ɫ,0)
    return
  end

  local petIndex = Char.GetPet(heroIndex, petSlot);
  -- Char.SetLoopEvent(nil, 'petlevelupLoop', petIndex, 0);
  local heroIndex=  Pet.GetOwner(petIndex)
  local name = Char.GetData(heroIndex,CONST.CHAR_����)
  local heroesOnline=sgModule:getGlobal("heroesOnline")
  local heroData = heroesOnline[heroIndex]
  local petSlot = Char.GetData(heroIndex, CONST.CHAR_ս��);
  
  local petName=Char.GetData(petIndex,CONST.CHAR_����)
  -- �����Զ��ӵ�
  local levelUpPoint = Char.GetData(petIndex,CONST.CHAR_������)
  
  for i=1,levelUpPoint+1 do
    getModule('heroesFn'):autoPoint(petIndex,heroData.petAutoPointing)
  end
  
  NLG.SystemMessage(heroData.owner,name.."�ġ�"..petName.."�������ˣ��Զ��ӵ㣺"..(heroData.petAutoPointing))
end

-- NOTE ս�������¼�
function module:onCalcFpConsumeEvent(charIndex,techId,fpConsume)
  -- local name = Char.GetData(charIndex,CONST.CHAR_����)
  -- logInfo("ս������",name,charIndex,techId,fpConsume)
  local heroesOnline=sgModule:getGlobal("heroesOnline")
  local heroData = heroesOnline[charIndex]
  -- �������Ӣ�� ���˳�
  if not heroesOnline[charIndex] then
    return fpConsume
  end
  local techIndex = Tech.GetTechIndex(techId)
  local originFP=Tech.GetData(techIndex, CONST.TECH_FORCEPOINT)
  if fpConsume<0 then
    return math.ceil(originFP*heroFpReduce)
  end
  return math.ceil(fpConsume*heroFpReduce)
end
-- NOTE �Ҽ�����¼�
function module:onRightClickEvent(charIndex, dummyIndex)
    -- ������Ǽ��ˣ��˳�
    if not Char.IsDummy(dummyIndex) then
      return
    end
    -- �������Ӣ�� ���˳�
    local heroesOnline=sgModule:getGlobal("heroesOnline")
    local heroData = heroesOnline[dummyIndex]
    if not heroesOnline[dummyIndex] then
      return
    end
    -- Ӣ�۵�owner
    if heroData.owner ~= charIndex then
      return
    end
    self:showCampHeroOperationWindow(charIndex,nil,heroData)

end
-- NOTE ��ʾ����һ�� seqno:21
function module:showPartyStatus(charIndex)
  
  local windowStr = heroesFn:buildDescriptionForParty(charIndex)
  NLG.ShowWindowTalked(charIndex, self.shortcutNpc, CONST.����_����Ϣ��, CONST.BUTTON_�ر�, 21,windowStr);
end

-- NOTE Ӣ�ۼӵ���ҳ seqno:23
function module:showHeroOperationSecWindow(charIndex)
  local heroData = sgModule:get(charIndex,"heroSelected")
  local windowStr = heroesFn:buildHeroOperationSecWindow(charIndex,heroData)
  NLG.ShowWindowTalked(charIndex, self.shortcutNpc, CONST.����_ѡ���, CONST.BUTTON_��ȡ��, 23,windowStr);
end

-- NOTE ��ʾ�ӵ�ģʽѡ�� seqno:24
function module:showAutoPointSelection(charIndex)
  local windowStr=heroesFn:buildAutoPointSelect(0);
  NLG.ShowWindowTalked(charIndex, self.shortcutNpc, CONST.����_ѡ���, CONST.BUTTON_��ȡ��, 24,windowStr);
end
-- NOTE ��ʾս��ӵ�ģʽѡ�� seqno:25
function module:showPetAutoPointSelection(charIndex)
  local windowStr=heroesFn:buildAutoPointSelect(1);
  NLG.ShowWindowTalked(charIndex, self.shortcutNpc, CONST.����_ѡ���, CONST.BUTTON_��ȡ��, 25,windowStr);
end

-- NOTE ����Ӣ���Զ��ӵ�ģʽ
function module:setAutoPionting(charIndex,data)

  local heroData = sgModule:get(charIndex,"heroSelected");

  heroesFn:setAutoPionting(charIndex,heroData,data)
  local name = Char.GetData(heroData.index,CONST.CHAR_����)
  NLG.SystemMessage(charIndex,name.."������Զ��ӵ�ģʽ��")
  self:showHeroOperationSecWindow(charIndex)
end
-- NOTE ����ս���Զ��ӵ�ģʽ
function module:setPetAutoPionting(charIndex,data)
  local heroData = sgModule:get(charIndex,"heroSelected");
  heroesFn:setPetAutoPionting(charIndex,heroData,data)
  local name = Char.GetData(heroData.index,CONST.CHAR_����)
  NLG.SystemMessage(charIndex,name.."�����ս����Զ��ӵ�ģʽ��")
  self:showHeroOperationSecWindow(charIndex)
end
-- NOTE ����/�ر� �Զ��ӵ�
-- params type: 0��Ӣ�ۣ�1������
function module:swtichAutoPointing(charIndex,type)
  local heroData = sgModule:get(charIndex,"heroSelected");
  if type==0 then
    if heroData.autoPointing==nil then
      NLG.SystemMessage(charIndex,"��������Ӣ�۵��Զ��ӵ�ģʽ")
      return;
    end
    heroData.isAutoPointing=heroData.isAutoPointing==0 and 1 or 0
  elseif type ==1 then
    if heroData.petAutoPointing==nil then
      NLG.SystemMessage(charIndex,"��������ս����Զ��ӵ�ģʽ")
      return;
    end
    heroData.isPetAutoPointing=heroData.isPetAutoPointing==0 and 1 or 0
  end
  self:showHeroOperationSecWindow(charIndex)
end
-- NOTE ��ʾˮ������ seqno:26
function module:showCrystalSelection(charIndex)
  local items={"�ص�ˮ��","ˮ��ˮ��","���ˮ��","���ˮ��"}
  local title="ѡ��һ��ˮ��"
  local windowStr = self:NPC_buildSelectionText(title,items);
  NLG.ShowWindowTalked(charIndex, self.shortcutNpc, CONST.����_ѡ���, CONST.BUTTON_��ȡ��, 26,windowStr);
end
-- NOTE ����ˮ��
function module:changeCrystal(charIndex,data)
  
  local crystalItemIdMpa={9201,9202,9203,9204};
  local crystalId = crystalItemIdMpa[data]
  local heroData = sgModule:get(charIndex,"heroSelected");
  heroesFn:changeCrystal(charIndex,heroData,crystalId)
  self:showCampHeroOperationWindow(charIndex,nil,sgModule:get(charIndex,"heroSelected"))
end
-- NOTE �������ˮ��
function module:changeCrystalForHeroes(charIndex,data)
  local crystalItemIdMpa={9201,9202,9203,9204};
  local crystalId = crystalItemIdMpa[data]
  local campHeroes = heroesFn:getCampHeroesData(charIndex)
  _.each(campHeroes,function(heroData) 
    
    heroesFn:changeCrystal(charIndex,heroData,crystalId)
  
  end)
 
  self:management(self.shortcutNpc,charIndex)
end
-- NOTE �����ȡ�¼�
function module:onGetExpEvent(charIndex,exp)
  --   ��Ӣ�� �˳�
  -- local heroesOnline=sgModule:getGlobal("heroesOnline")
  -- if heroesOnline[charIndex] then
  --   return 0
  -- end
  -- if Char.PartyNum(charIndex) <=0   then
  --   return exp
  -- end

  -- local partIndex = Char.GetPartyMember(charIndex, 0)

  -- local campHeroesData = heroesFn:getCampHeroesData(charIndex)
  -- _.each(campHeroesData,function(heroData) 
  --   local heroIndex =heroData.index
  --   Char.SetData(heroIndex,CONST.CHAR_����,Char.GetData(heroIndex,CONST.CHAR_����)+exp)
  -- end)

  -- local name = Char.GetData(charIndex,CONST.CHAR_����)
  -- print("����",name,exp)
  -- return exp
end
-- NOTE ͵Ϯ�¼�
-- function module:OnBattleSurpriseEvent(battleIndex, result)
--   print(battleIndex, result)
--   return CONST.BATTLE_SurpriseFlag.BeSurprise
-- end
-- SECTION Ӣ�ۼ���npc
-- NOTE �������̿���
function module:skillNpcTalked(npc, charIndex, seqno, select, data)
  data=tonumber(data)
  if select == CONST.BUTTON_�ر� then
    return ;
  end
  -- NOTE  1 Ӣ���б�
  if seqno== 1 and data>0 then
    self:showSkills(charIndex,data)
  end
  --  NOTE  2 ѡ����
  if seqno==2  then
    -- ѡ�������һҳ ��һҳ
    if data<0 then
      -- local page;
      -- if select == 32 then
      --   page =  sgModule:get(charIndex,"playerPage")+1
        
      -- elseif select == 16 then
      --   page =  sgModule:get(charIndex,"playerPage")-1
      -- end
      -- sgModule:set(charIndex,"playerPage",page)
      -- self:showPlayerItem(charIndex,page)
    else
      self:showCampHeroSkillSlot(charIndex,data)
    end
  end
  -- NOTE  3 ����ѡ����
  if seqno== 3 and data>0 then
    self:getSkill(charIndex,data)
  end
end
-- NOTE Ӣ��ѡ�� ��ҳ seqno:1
function module:showSkillNpcHome(npc,charIndex)
  local windowStr = heroesFn:buildCampHeroesList(charIndex)
  NLG.ShowWindowTalked(charIndex, self.skillNpc, CONST.����_ѡ���, CONST.BUTTON_�ر�, 1,windowStr);
end
-- NOTE ѡ���� seqno:2
function module:showSkills(charIndex,data,heroData)
  if data~= nil and heroData == nil then
    local campHeroes = heroesFn:getCampHeroesData(charIndex)
    heroData = campHeroes[data]
    sgModule:set(charIndex,"heroSelected4skill",heroData)
  end
  local heroIndex= heroData.index;
  local skillLv = math.ceil(Char.GetData(heroIndex,CONST.CHAR_�ȼ�)/10) 
  
  local items={}
  local techIdItems={}
  _.each(skillInfo.params,function(param) 
    local ids = param[2]
    if type(ids) == 'number' then
      local techIndex = Tech.GetTechIndex(ids)
      local lv=Tech.GetData(techIndex, CONST.TECH_NECESSARYLV)
      if lv ~= skillLv then
        return;
      end
      local name=Tech.GetData(techIndex, CONST.TECH_NAME)
      table.insert(items,name)
      table.insert(techIdItems,ids)
    else
      for techId = ids[1],ids[2] do
        local techIndex = Tech.GetTechIndex(techId)
        local lv=Tech.GetData(techIndex, CONST.TECH_NECESSARYLV)
        if lv ~= skillLv then
          return;
        end
        local name=Tech.GetData(techIndex, CONST.TECH_NAME)
        table.insert(items,name)
        table.insert(techIdItems,techId)
      end
    end
  end)
  sgModule:set(charIndex,"techIdsAbleToGet",techIdItems);
  local title="   ��ѡ����"
  local windowStr=  self:NPC_buildSelectionText(title,items);
  
  NLG.ShowWindowTalked(charIndex, self.skillNpc, CONST.����_ѡ���, CONST.BUTTON_��ȡ��,2,windowStr);
end
-- NOTE ��ʾӢ�ۼ����� seqno:3
function module:showCampHeroSkillSlot(charIndex,data)
  local techId = (sgModule:get(charIndex,"techIdsAbleToGet"))[data];
  sgModule:set(charIndex,"skillSelected",techId);
  local heroData=  sgModule:get(charIndex,"heroSelected4skill");
  local windowStr=heroesFn:buildCampHeroSkills(charIndex,heroData)
  NLG.ShowWindowTalked(charIndex, self.skillNpc, CONST.����_ѡ���, CONST.BUTTON_��ȡ��, 3,windowStr);

end
-- NOTE ִ�еǼǼ���
function module:getSkill(charIndex,data)
  local techId = sgModule:get(charIndex,"skillSelected");
  local heroData=  sgModule:get(charIndex,"heroSelected4skill");
  if heroData.skills == nil then
    heroData.skills={nil,nil,nil,nil,nil,nil,nil,nil} 
  end
  heroData.skills[data]=techId
  print(data,type(data),techId)
  local name = Char.GetData(heroData.index,CONST.CHAR_����)
  NLG.SystemMessage(charIndex,name.."���ܵǼǳɹ���")
end
-- !SECTION 
--- NOTE ����ģ�鹳��
function module:onLoad()
  self:logInfo('load')
  -- ��reload ������module
  
  reloadModule("autoBattleParams")
  reloadModule("heroesFn")
  
  self:regCallback('CharActionEvent', Func.bind(self.shortcut, self))
  -- npc �ƹ�
  self.shortcutNpc = self:NPC_createNormal('Ӣ�۾ƹ�', 105502, { x = 234, y = 83, mapType = 0, map = 1000, direction = 4 });
  self:NPC_regTalkedEvent(self.shortcutNpc, Func.bind(self.recruit, self));
  self:NPC_regWindowTalkedEvent(self.shortcutNpc, Func.bind(self.recruitTalked, self));

  self:regCallback('BeforeBattleTurnEvent', Func.bind(self.handleDummyCommand, self))
  self:regCallback('LoginEvent', Func.bind(self.onLoginEvent, self));
  self:regCallback('LogoutEvent', Func.bind(self.onLogoutEvent, self));
  self:regCallback('AfterWarpEvent', Func.bind(self.handleAfterWarpEvent, self))
  self:regCallback('BattleStartEvent', Func.bind(self.onBattleStart, self))
  self:regCallback("LevelUpEvent", Func.bind(self.onLevelUpEvent, self))
  self:regCallback("PetLevelUpEvent", Func.bind(self.onPetLevelUpEvent, self))
  self:regCallback("CalcFpConsumeEvent",Func.bind(self.onCalcFpConsumeEvent, self))
  self:regCallback("RightClickEvent",Func.bind(self.onRightClickEvent, self))
  -- self:regCallback("BattleSurpriseEvent", Func.bind(self.OnBattleSurpriseEvent, self))
  -- self:regCallback("GetExpEvent",Func.bind(self.onGetExpEvent, self))
  -- self:regCallback("BattleExitEvent",Func.bind(self.onBattleExitEvent, self))
  
  -- self.skillNpc = self:NPC_createNormal('Ӣ�ۼ���ѧϰ', 105502, { x = 235, y = 88, mapType = 0, map = 1000, direction = 4 });
  -- self:NPC_regTalkedEvent(self.skillNpc, Func.bind(self.showSkillNpcHome, self));
  -- self:NPC_regWindowTalkedEvent(self.skillNpc, Func.bind(self.skillNpcTalked, self));
end

--- NOTE ж��ģ�鹳��
function module:onUnload()
  self:logInfo('unload')
end

return module;