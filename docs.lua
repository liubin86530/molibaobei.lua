Char = {}

---@param charIndex number
---@param dataIndex number
---@return string | number
function Char.GetData(charIndex, dataIndex) end

---@param charIndex number
---@param dataIndex number
---@param value string|number
---@return number
function Char.SetData(charIndex, dataIndex, value) end

---�����Զ������ݣ����浽���ݿ⣩
---@param charIndex number
---@param dataIndex string
---@return string | number
function Char.GetExtData(charIndex, dataIndex) end

---��ȡ�Զ������ݣ����浽���ݿ⣩
---@param charIndex number
---@param dataIndex string
---@param value string|number
---@return number
function Char.SetExtData(charIndex, dataIndex, value) end

---������ʱ���ݣ������浽���ݿ⣩
---@param charIndex number
---@param dataIndex string
---@return string | number
function Char.GetTempData(charIndex, dataIndex) end

---��ȡ��ʱ���ݣ������浽���ݿ⣩
---@param charIndex number
---@param dataIndex string
---@param value string|number
---@return number
function Char.SetTempData(charIndex, dataIndex, value) end

---��ȡһ��ΨһID
---@param charIndex number
---@return string
function Char.GetUUID(charIndex) end

---��valueΪ0ʱ�������
---@param charIndex number
---@param flag number
---@param value number '0' | '1'
---@return void
function Char.NowEvent(charIndex, flag, value) end

---��ȡ��ǰ����
---@param charIndex number
---@param flag number
---@return number
function Char.NowEvent(charIndex, flag) end

---��valueΪ0ʱ�������
---@param charIndex number
---@param flag number
---@param value number '0' | '1'
---@return void
function Char.EndEvent(charIndex, flag, value) end

---��ȡ��ǰ����
---@param charIndex number
---@param flag number
---@return number
function Char.EndEvent(charIndex, flag) end

---@param charIndex number
---@param itemID number
---@return number ������򷵻ص�һ������ĵ�����λ�ã����û���򷵻�-1��
function Char.FindItemId(charIndex, itemID) end

---@param charIndex number
---@param amount number
function Char.AddGold(charIndex, amount) end

---@param charIndex number
---@param slot number
---@return number ���Ŀ����λ�е��ߣ��򷵻ص���index�����򷵻� -1: ����ָ����� -2: �������޵��� -3: ������Χ��
function Char.GetItemIndex(charIndex, slot) end

---@param CharIndex number
---@param ItemID number
---@param Amount number
---@param ShowMsg boolean
---@return number �ɹ�����1��ʧ���򷵻�0��
function Char.DelItem(CharIndex, ItemID, Amount, ShowMsg) end

---@param CharIndex number
---@param ItemID number
---@param Amount number
---@param ShowMsg boolean
---@return number Ŀ�����index��ʧ���򷵻ظ�����
function Char.GiveItem(CharIndex, ItemID, Amount, ShowMsg) end

---@param CharIndex number
---@param ItemID number
---@return number ���Ŀ���иõ��ߣ��򷵻ظõ���index�����򷵻�-1��
function Char.HaveItem(CharIndex, ItemID) end

---@param CharIndex number
---@param Slot number
---@return number ���Ŀ���У��򷵻�index�����򷵻�-1��
function Char.GetPet(CharIndex, Slot) end

function Char.GivePet(CharIndex, PetID, FullBP) end

---@return number ������ʹ������
function Char.ItemSlot(charIndex) end

function Char.AddPet(CharIndex, PetID) end

---@return number ����е��������������ӷ���-1�����򷵻������������ȡʧ�ܷ���0�������������Ͳ��Է���-2������index��Ч����-3��
function Char.PartyNum(CharIndex) end

---@param Slot number ȡֵ0-4
---@return number ����ָ��λ�õ���ҵĶ���index�����û������򷵻�-1����ȡʧ�ܷ���0�������������Ͳ��Է���-2������index��Ч����-3������Ŷ��е�λ�ó�����Χ(0-4)����-4��
function Char.GetPartyMember(CharIndex, Slot) end

---@return number ����1����ɹ�������0ʧ�ܣ������������Ͳ��Է���-2������index��Ч����-3��
function Char.DischargeParty(CharIndex) end

---@return number �ɹ����ص�ǰս��index������-1����û��ս���������������Ͳ��Է���-2������index��Ч����-3��
function Char.GetBattleIndex(CharIndex) end

---������ӣ�������ӿ��ؼ�����
---@param sourceIndex number ��Աindex
---@param targetIndex number �ӳ�index
function Char.JoinParty(sourceIndex, targetIndex) end

---@return number �ɹ�������Ҷ��󼤻�ĳƺ�ID������-1����ʧ�ܣ������������Ͳ��Է���-2������index��Ч����-3��
function Char.GetTitle(CharIndex) end

function Char.Warp(CharIndex, MapType, FloorID, X, Y) end

function Char.HaveSkill(CharIndex, SkillID) end

function Char.GetSkillID(CharIndex, Slot) end

function Char.GetSkillLv(CharIndex, Slot) end

function Char.SetWalkPostEvent(Dofile, FuncName, CharIndex) end

function Char.SetWalkPreEvent(Dofile, FuncName, CharIndex) end

function Char.SetPostOverEvent(Dofile, FuncName, CharIndex) end

function Char.SetItemPutEvent(Dofile, FuncName, CharIndex) end

function Char.SetWatchEvent(Dofile, FuncName, CharIndex) end

function Char.SetLoopEvent(Dofile, FuncName, CharIndex, Interval) end

function Char.DelPet(CharIndex, PetID, Level, LevelSetting) end

function Char.DelSlotPet(CharIndex, Slot) end

---�ƶ���Ʒ
---@param charIndex number
---@param fromSlot number �ƶ��Ǹ���Ʒ��ȡֵ0-27
---@param toSlot number �ƶ����Ǹ�λ��, ȡֵ0-27
---@param amount number �����������ƶ�ȡֵ��Ϊ-1
function Char.MoveItem(charIndex, fromSlot, toSlot, amount) end

---@param charIndex number
---@return number
function Char.IsDummy(charIndex) end

---@param charIndex number
---@return number
function Char.SetDummy(charIndex) end

NLG = NLG or {}
function NLG.ShowWindowTalked(ToIndex, WinTalkIndex, WindowType, ButtonType, SeqNo, Data) end

function NLG.SystemMessage(CharIndex, Message) end

function NLG.TalkToCli(ToIndex, TalkerIndex, Msg, FontColor, FontSize) end

function NLG.CanTalk(npc, player) end

function NLG.UpChar(CharIndex) end

function NLG.c(str) end

function NLG.TalkToMap(Map, Floor, TalkerIndex, Msg, FontColor, FontSize) end

---����cpuʹ��
---@param ms number ��0ʱ�رգ����ڻ����0ʱΪSleepʱ�䣬���������2
function NLG.LowCpuUsage(ms) end

---@overload fun(cdkey: string):number
---@param cdkey string
---@param regId number
---@return number charIndex
function NLG.FindUser(cdkey, regId) end

---@param min number
---@param max number
---@return number
function NLG.Rand(min, max) end

---@param npcOrPlayer number npc�������index
---@param player number ���index
function NLG.OpenBank(npcOrPlayer, player) end

---��������(ȫ�ֿ���)
---@param enable boolean ����:1 ������:0
---@overload
function NLG.SetPetRandomShot(enable) end

---��������(ĳ�ֳ��￪��)
---@param enable boolean ����:1 ������:0
---@param petId number ����id��EnemyBaseId��
---@overload
function NLG.SetPetRandomShot(petId, enable) end

---�޸ı���ʱ�˺�����
-----@param mode number|boolean ȡֵ�� 0 = ��ͨģʽ 1 = ����ģʽ 2 = �� true = ��ͨģʽ false = ��
-----@param val number ���ʣ�Ĭ��1.5��
function NLG.SetCriticalDamageAddition(mode, val) end

Pet = {}

function Pet.ReBirth(PlayerIndex, PetIndex) end

function Pet.SetArtRank(PetIndex, ArtType, Value) end

function Pet.GetArtRank(PetIndex, ArtType) end

function Pet.ArtRank(PetIndex, ArtType) end

function Pet.FullArtRank(PetIndex, ArtType) end

function Pet.UpPet(PlayerIndex, PetIndex) end

function Pet.GetSkill(PetIndex, SkillSlot) end

function Pet.AddSkill(PetIndex, SkillID) end

---���ó���ͻ��63bp����
function Pet.AllowBpOverflow() end

---��ȡΨһid
---@return string
function Pet.GetUUID() end

Item = {}

function Item.GetData(ItemIndex, Dataline) end

function Item.SetData(ItemIndex, Dataline, value) end

function Item.UpItem(CharIndex, Slot) end

function Item.Kill(CharIndex, ItemIndex, Slot) end

Battle = {}

---@param BattleIndex number ս��index��ΪEncount��PVE��PVP�����ķ���ֵ��
---@param Slot number ս�����������λ��,��Χ0-19������0-9Ϊ�·�ʵ�����У�10-19Ϊ�Ϸ�ʵ�����С�
---@return number ����-1ʧ�ܣ��ɹ����ض���ʵ���� ����index�������������Ͳ��Է���-2��ս��index��Ч����-3��ս�����������λ�÷�Χ���󷵻�-4��
function Battle.GetPlayer(BattleIndex, Slot) end

---@param BattleIndex number ս��index��ΪEncount��PVE��PVP�����ķ���ֵ��
---@param Slot number ս�����������λ��,��Χ0-19������0-9Ϊ�·�ʵ�����У�10-19Ϊ�Ϸ�ʵ�����С�
---@return number ����-1ʧ�ܣ��ɹ����ض���ʵ���� ����index�������������Ͳ��Է���-2��ս��index��Ч����-3��ս�����������λ�÷�Χ���󷵻�-4��
function Battle.GetPlayIndex(BattleIndex, Slot) end

function Battle.Encount(UpIndex, DownIndex) end

---@param CharIndex number
---@param CreatePtr number
---@param DoFunc string
---@param EnemyIdAr number[]
---@param BaseLevelAr number[]
---@param RandLv number[]
function Battle.PVE(CharIndex, CreatePtr, DoFunc, EnemyIdAr, BaseLevelAr, RandLv) end

function Battle.PVP(UpIndex, DownIndex) end

function Battle.SetType(BattleIndex, Type) end

---@return number
function Battle.GetType(BattleIndex) end

function Battle.SetGainMode(BattleIndex, Mod) end

function Battle.GetGainMode(BattleIndex) end

---@return number ȡֵ0����1�� 0��ʾս���·�����0-9λ�õ���ң�1��ʾ�Ϸ�����10-19λ�õ���ҡ�
function Battle.GetWinSide(BattleIndex) end

function Battle.SetWinEvent(DoFile, FuncName, BattleIndex) end

function Battle.ExitBattle(CharIndex) end

function Battle.SetPVPWinEvent(DoFile, FuncName, BattleIndex) end

_G.Field = {}

function Field.Get(CharIndex, Field) end

function Field.Set(CharIndex, Field, Value) end

_G.NL = {}

function NL.CreateNPC(Dofile, InitFuncName) end

function NL.DelNpc(NpcIndex) end

function NL.CreateArgNpc(Type, Arg, Name, Image, Map, Floor, Xpos, Ypos, Dir, ShowTime) end

function NL.SetArgNpc(NpcIndex, NewArg) end

function NL.RegCallback(event, callbackStr) end

function NL.RemoveCallback(event) end

---����˵���޸��¼�
---@param callback string callback�ص����� 
---@see NL.RegItemExpansionEventCallback
function NL.RegItemExpansionEvent(dofile, callback) end

---����˵���޸��¼��ص�
---@param itemIndex number
---@param type number
---@param msg string
---@param charIndex number
---@param slot number
---@return string
function NL.RegItemExpansionEventCallback(itemIndex, type, msg, charIndex, slot) end

---���������¼�
---@param callback string callback�ص����� fun(charaIndex:number,mapId:number,floor:number,X:number,Y:number,boxType:number):number[]|nil
function NL.RegItemBoxEncountEvent(dofile, callback) end

---���������¼��ص�
---@param charaIndex number
---@param mapId number
---@param floor number
---@param X number
---@param Y number
---@param boxType number
---@return number[]|nil �������� ÿ������3���������ֱ�Ϊ id���ȼ�������ȼ��� ����nil�����أ� ���ӣ� {0, 100, 5, 1, 1, 0} ����0�Ź���100-105����1�Ź���1��
function NL.ItemBoxEncountRateEventCallback(charaIndex, mapId, floor, X, Y, boxType) end

---�������и����¼�
---@param callback string callback�ص����� 
---@see NL.ItemBoxEncountRateEventCallback
function NL.RegItemBoxEncountRateEvent(dofile, callback) end

---�������и����¼��ص�
---@param charaIndex number
---@param mapId number
---@param floor number
---@param X number
---@param Y number
---@param boxType number
---@param rate number ������
---@return number ������
function NL.ItemBoxEncountRateEventCallback(charaIndex, mapId, floor, X, Y, boxType, rate) end

---�����ȡ��Ʒ�¼�
---@param callback string callback�ص����� 
---@see NL.ItemBoxLootEventCallback
function NL.RegItemBoxLootEvent(dofile, callback) end

---�����ȡ��Ʒ�¼��ص�
---@param charaIndex number
---@param mapId number
---@param floor number
---@param X number
---@param Y number
---@param boxType number
---@param adm number
---@return number ����1����Ĭ����Ʒ
function NL.ItemBoxLootEventCallback(charaIndex, mapId, floor, X, Y, boxType, adm) end

---���������¼�
---@param callback string callback�ص����� 
---@see NL.ItemBoxGenerateEventCallback
function NL.RegItemBoxGenerateEvent(dofile, callback) end

---���������¼��ص�
---@param mapId number
---@param floor number
---@param itemBoxType number ������
---@param adm number Ӱ�������Ʒ������δ֪
---@return number[] ���ر������ {itemBoxType, adm}
function NL.ItemBoxGenerateEventCallback(mapId, floor, itemBoxType, adm) end

---@param sql string sql
---@vararg string|number �󶨲��������40��
---@return {status:number, effectRows:number, rows: table} ���ز�ѯ����
function SQL.QueryEx(sql, ...) end

---@overload fun(battleIndex: number, encountIndex: number):number
---@param battleIndex number
---@param encountIndex number encount��ţ� -1=ȡ����ս�� -2=lua������ս
---@param flg number lua��ս����
---@return number �ɹ�����0
function Battle.SetNextBattle(battleIndex, encountIndex, flg) end

---��ȡ��սid
---@param battleIndex number
---@return number encountIndex
function Battle.GetNextBattle(battleIndex) end

---��ȡlua��սflg
---@param battleIndex number
---@return number flg
function Battle.GetNextBattleFlg(battleIndex) end

---���������˺�����
---@param ap number[] 4���ԣ��ء�ˮ���𡢷�
---@param dp number[] 4���ԣ��ء�ˮ���𡢷�
---@return number
function Battle.CalcPropScore(ap, dp) end

---��ָ����Ҷ��������һ����Ҷ����ս���У�Ҳ������CharIndex2����CharIndex1��ս��
---@param a number Ŀ��Ķ���index����ս���е����
---@param b number Ŀ��Ķ���index������ս���е����
---@return number ����0Ϊ�ɹ�������ʧ�ܡ�
function Battle.JoinBattle(a, b) end

---�ö���ִ��ָ����ս�������������ڶ���Battle.IsWaitingCommand(index)����ֵΪ1ʱ�ſ�����Чʹ�á�
---@param charIndex number
---@param com1 number @see CONST.BATTLE_COM
---@param com2 number @see CONST.BATTLE_COM_TARGET
---@param com3 number techId
---@return number
function Battle.ActionSelect(charIndex, com1, com2, com3) end

---�жϵ�ǰ�����Ƿ���ս�����Ҵ��ڵȴ�����ս��ָ���״̬��
---@return number ����1Ϊ�ȴ�ָ��
function Battle.IsWaitingCommand(charIndex) end

---��ȡ��ǰ���ܲ���
---@param charIndex number
---@param type string ȡֵ DD: AR: ��
---@return number|nil
function Battle.GetTechOption(charIndex, type) end

---��ȡ���Կ��ƹ�ϵ
---@param attackerIndex number
---@param defenceIndex number
---@return number ���Ʊ���
function Battle.CalcAttributeDmgRate(attackerIndex, defenceIndex) end

---���������˺�
---@param a number ����������
---@param b number ����������
---@return number
function Battle.CalcTribeRate(a, b) end

---���㵱ǰս�������˺�
---@param aIndex number ������index
---@param bIndex number ������index
---@return number
function Battle.CalcTribeDmgRate(aIndex, bIndex) end

---����Msg
---@param msgId number
---@param val string
function Data.SetMessage(msgId, val) end

---��ȡMsg
---@param msgId number
---@return string
function Data.GetMessage(msgId) end

---����ħ������
---@param techId number
---@param earth number ÿ10����1������
---@param water number ÿ10����1������
---@param fire number ÿ10����1������
---@param wind number ÿ10����1������
function Tech.SetTechMagicAttribute(techId, earth, water, fire, wind) end

---���ͷ�����ͻ���
---@param charIndex number
---@param header string ���ͷ
---@vararg number|string data�����ݷ�����ݶ��������ּ��ַ���������з�����룬��Ĭ�ϴ���
---@return number ��������0Ϊʧ�ܣ���������Ϊ�ɹ�
function Protocol.Send(charIndex, header, ...) end
