function Item.GetSlot(charIndex, itemIndex)
  for i = 0, 27 do
    if Char.GetItemIndex(charIndex, i) == itemIndex then
      return i;
    end
  end
  return -1;
end

Item.Types = {}

Item.Types.WeaponType = {
  CONST.ITEM_TYPE_��,
  CONST.ITEM_TYPE_��,
  CONST.ITEM_TYPE_ǹ,
  CONST.ITEM_TYPE_��,
  CONST.ITEM_TYPE_��,
  CONST.ITEM_TYPE_С��,
  CONST.ITEM_TYPE_������,
};

Item.Types.RangerWeaponType = {
  CONST.ITEM_TYPE_��,
  CONST.ITEM_TYPE_С��,
  CONST.ITEM_TYPE_������,
};

Item.Types.ArmourType = {
  CONST.ITEM_TYPE_��,
  CONST.ITEM_TYPE_��,
  CONST.ITEM_TYPE_ñ,
  CONST.ITEM_TYPE_��,
  CONST.ITEM_TYPE_��,
  CONST.ITEM_TYPE_��,
  CONST.ITEM_TYPE_ѥ,
  CONST.ITEM_TYPE_Ь,
};

Item.Types.AccessoryType = {
  CONST.ITEM_TYPE_�ֻ�,
  CONST.ITEM_TYPE_����,
  CONST.ITEM_TYPE_����,
  CONST.ITEM_TYPE_��ָ,
  CONST.ITEM_TYPE_ͷ��,
  CONST.ITEM_TYPE_����,
  CONST.ITEM_TYPE_�����,
};

Item.Types.CrystalType = CONST.ITEM_TYPE_ˮ��;

function Item.Types.isWeapon(type)
  return table.indexOf(Item.Types.WeaponType, type) > 0
end

function Item.Types.isArmour(type)
  return table.indexOf(Item.Types.ArmourType, type) > 0
end

function Item.Types.isAccessory(type)
  return table.indexOf(Item.Types.AccessoryType, type) > 0
end

function Item.Types.isCrystal(type)
  return Item.Types.CrystalType == type
end

function Item.isWeapon(itemIndex)
  return table.indexOf(Item.Types.WeaponType, Item.GetData(itemIndex, CONST.����_����)) > 0
end

function Item.isArmour(itemIndex)
  return table.indexOf(Item.Types.ArmourType, Item.GetData(itemIndex, CONST.����_����)) > 0
end

function Item.isAccessory(itemIndex)
  return table.indexOf(Item.Types.AccessoryType, Item.GetData(itemIndex, CONST.����_����)) > 0
end

function Item.isCrystal(itemIndex)
  return Item.Types.CrystalType == Item.GetData(itemIndex, CONST.����_����)
end
