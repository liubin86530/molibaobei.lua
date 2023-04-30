# cgmsv lua

## ģ��ϵͳ

֧�ֶ�̬���ء�ж���Լ��汾����������Ǩ�ơ�����ͨ��Moduleע��Ļص�ж��ʱ�Զ�����

### ModuleBase��

#### ����

1. `name` ��ǰģ������, string����
2. `migrations` ����Ǩ���б� �������ͣ� ÿ��Ԫ����Ҫ��`version`��`name`��`value` ��������
    - `version` �汾�� number����
    - `name` ���� string����
    - `value` sql���߾��巽�� string��function����

#### ����

1. `ModuleBase:regCallback(eventNameOrCallbackKeyOrFn, fn)`  ע��ص�
    - ���� `eventNameOrCallbackKeyOrFn`
      - ���Դ���NL.Reg*��Ӧ���¼����ƣ���NL.RegLoginEvent ���� `LoginEvent`
      - �Զ�����������ڷ�ȫ�ֻص�����NPC�����ص���
      - �����ص�����NPC�����ص���

    - ���� `fn`
      - �ص����������eventNameOrCallbackKeyOrFn�������ص���fn���Դ�nil

    - ����ֵ `eventNameOrCallbackKeyOrFn`, `lastIx`, `fnIndex`
      - `eventNameOrCallbackKeyOrFn` ������ȫ��Key�����ڴ���NL.Reg*
      - `lastIx` ��ǰģ���µ�ע������
      - `fnIndex` ȫ��ע������

2. `ModuleBase:unRegCallback(eventNameOrCallbackKey, fnOrFnIndex)`  ��ע��ص�
    - ���� `eventNameOrCallbackKey`
      - ���Դ���NL.Reg*��Ӧ���¼����ƣ���NL.RegLoginEvent ���� `LoginEvent`
      - �Զ�����������ڷ�ȫ�ֻص�����NPC�����ص���

    - ���� `fnOrFnIndex`
      - ���봫��ע���õĻص�����
      - Ҳ����fnIndex ȫ��ע������
3. `ModuleBase:onLoad()`  ģ��ע�ṳ�ӣ��ɾ���ʵ��ģ��ʵ��
4. `ModuleBase:onUnload()`  ģ��ж�ع��ӣ��ɾ���ʵ��ģ��ʵ��
5. `ModuleBase:logInfo(msg, ...)`  ��ӡ��־
6. `ModuleBase:logDebug(msg, ...)`  ��ӡ��־
7. `ModuleBase:logWarn(msg, ...)`  ��ӡ��־
8. `ModuleBase:logError(msg, ...)`  ��ӡ��־
9. `ModuleBase:log(level, msg, ...)`  ��ӡ��־
10. `ModuleBase:addMigration(version, name, sqlOrFunction)` ����һ����Ǩ��

## ģ�����
����ģ�������ModuleConfig.lua
### loadModule 
����`Modules`�µ�Module��Module���������໥�����������ֶ�ָ��ȫ�ֱ��������򲻻�Ӱ������Module�������������Module��ͨ��getModule��ȡ
```
loadModule('admin') --����adminģ��
```
### useModule 
����`Module`Ŀ¼�µ���ͨlua, ��ͨlua������һ����������������ִ�С������ֶ�ָ��Ϊȫ�ֱ���������ֻ��Ӱ����ͨlua��module���ܷ�����ر���/����
```
useModule('Welcome') --����Welcome
```
### getModule
��ȡ��Ӧ��Module

### unloadModule
ж��Module

### reloadModule
���¼���Module

### Ŀǰ���õ�ģ��
1. admin ģ�鶯̬�����
2. ng �ڹ����
3. shop �����̵�NPC����
4. warp ���䴫��
5. warp2 �����㴫��
6. welcome ʾ��ģ��
7. itemPowerUp.lua װ��ǿ��
8. manaPool Ѫħ��
9. bag �����л�
10. autoRegister �Զ�ע��
11. petExt/charExt/itemExt ������չģ��
12. petLottery ����齱
13. petRebirth ����ת��
14. autoUnlock �Զ��������˵��µĿ���
   
### �����е�ģ��
- AI��չ

## GMSV ��չģ��
1. BattleEx.lua ս�������չ
2. Char.lua  ���������չ
3. DamageHook.lua �˺��޸Ĳ���
4. Data.lua Data���
5. Item.lua ��Ʒ���
6. LowCpuUsage.lua ����cpuʹ�ò���
7. Protocol.lua ����������
8. Recipe.lua �䷽���
9. DummyChar.lua �������
10. NL.lua ��չ�¼����
11. NLG_ShowWindowTalked_Patch.lua NLG.ShowWindowTalked ���Ȳ���
12. Addresses.lua ������ַ
13. Field.lua Field���

## ��չ�¼�/�ӿ�
- `NL.RegEnemyCommandEvent` �����ж��¼�
- `NL.RegCharaDeletedEvent` ��ɫɾ���¼�
- `NL.RegResetCharaBattleStateEvent` ��ɫս�������¼�
- `NL.RegBattleDamageEvent` ԭ����RegDamageCalculateEvent
- `NL.RegDamageCalculateEvent` �������ս���˺��¼�
- `NL.RegBattleHealCalculateEvent` ս�������¼�
- `NL.RegDeleteDummyEvent` ����ɾ���¼�
- `NL.RegItemExpansionEvent` ������Ʒ˵������
- `NLG.FindUser` ���������û�
- `Map.GetDungeonExpireTime` ��ȡ�Թ�ʣ��ʱ��
- `Map.GetDungeonExpireAt` ��ȡ�Թ�����ʱ��
- `Char.GetCharPointer` ��ȡ��ɫPtr
- `Char.GetWeapon` ��ȡ����
- `Char.GiveItem` �����Ʒ��֧�־�Ĭģʽ
- `Char.DelItem` ɾ����Ʒ��֧�־�Ĭģʽ
- `Char.DelItemBySlot` ɾ��ָ��λ�õ���Ʒ
- `Char.UnsetWalkPostEvent` �Ƴ��¼�
- `Char.UnsetWalkPreEvent` �Ƴ��¼�
- `Char.UnsetPostOverEvent` �Ƴ��¼�
- `Char.UnsetLoopEvent` �Ƴ��¼�
- `Char.UnsetTalkedEvent` �Ƴ��¼�
- `Char.UnsetWindowTalkedEvent` �Ƴ��¼�
- `Char.UnsetItemPutEvent` �Ƴ��¼�
- `Char.UnsetWatchEvent` �Ƴ��¼�
- `Char.MoveArray` ��ɫ�����ƶ�
- `Char.JoinParty` �������
- `Char.LeaveParty` �뿪����
- `Char.MoveItem` �ƶ���Ʒ
- `Char.IsValidCharPtr` 
- `Char.IsValidCharIndex` 
- `Char.GetDataByPtr` ����Ptr��ȡ����
- `Char.IsDummy` �Ƿ��Ǽ���
- `Char.CreateDummy` ��������
- `Char.DelDummy` ɾ������
- `Char.CalcConsumeFp` ���ڻ�ȡ��������Ҫ��fp
- `Char.SetPetDepartureState` ���ó���ս��״̬
- `Char.SetPetDepartureStateAll` ���ó���ս��״̬
- `Char.TradeItem` ֱ�ӽ�����Ʒ
- `Char.TradePet` ֱ�ӽ��׳���
- `Char.GetEmptyItemSlot` ��ȡ����Ʒ��
- `Char.GetEmptyPetSlot` ��ȡ�ճ�����
- `Battle.UnsetWinEvent` �Ƴ��¼�
- `Battle.UnsetPVPWinEvent` �Ƴ��¼�
- `Battle.GetNextBattle` ��ȡ��һ����սId
- `Battle.SetNextBattle` ������һ����սId
- `Battle.GetTurn` ��ȡ��ǰ�غ�
- `Battle.ActionSelect` ѡ��ս��ָ��
- `Battle.IsWaitingCommand` �ж��Ƿ�ȴ�ָ��
- `Data.ItemsetGetIndex` ��ȡItemsetIndex
- `Data.ItemsetGetData` ��ȡItemset����
- `Data.GetEncountData` ��ȡEncount����
- `Data.SetMessage` ��ȡMsg
- `Data.GetMessage` �޸�/����Msg����̬������Ʒʱ��Ż�����
- `Data.EnemyGetDataIndex` ��ȡEnemyDataIndex
- `Data.EnemyGetData` ��ȡEnemy����
- `Data.EnemyBaseGetDataIndex` ��ȡEnemyBaseDataIndex
- `Data.EnemyBaseGetData` ��ȡEnemyBase����
- `Item.GetSlot` ��ȡItemIndex��Ӧλ��
- `Protocol.makeEscapeString` �����ַ���
- `Protocol.makeStringFromEscaped` �����ַ���
- `Protocol.nrprotoEscapeString` ��������ַ���
- `Protocol.nrprotoUnescapeString` ��������ַ���
- `Protocol.Send` �����Զ�����
- `Protocol.GetCharIndexFromFd` ͨ��fd��ȡcharIndex
- `Protocol.OnRecv` ���ط��
- `Recipe.GiveRecipe` ����䷽
- `Recipe.RemoveRecipe` ɾ���䷽
- `regGlobalEvent` ע��ȫ���¼�������Delegate��DelegateҲ�ǰ�װ�������
- `removeGlobalEvent` �Ƴ�ע���¼�
