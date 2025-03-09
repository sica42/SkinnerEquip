local SkinnerEquip = {};

-- List of skinning tools in order of preference
SkinnerEquip.EQUIPMENT = {
  "Finkle's Skinner",
  "Zulian Slicer",
  "Shadowforge Skinner",
}

-- Constants for inventory slots
local MAINHAND_SLOT = 16
local OFFHAND_SLOT = 17

function SkinnerEquip.FindItem(itemName)
  for bag = 0, 4 do
    local slots = GetContainerNumSlots(bag)
    if slots > 0 then
      for slot = 1, slots do
        local link = GetContainerItemLink(bag, slot)
        if link and string.match(link, "%[(.+)%]") == itemName then
          return bag, slot
        end
      end
    end
  end
  return nil
end

function SkinnerEquip.EquipTools()
  SkinnerEquip.skinning = true
  SkinnerEquip.mainHand = SkinnerEquip.GetItemNameFromLink(GetInventoryItemLink("player", MAINHAND_SLOT))
  SkinnerEquip.offHand = SkinnerEquip.GetItemNameFromLink(GetInventoryItemLink("player", OFFHAND_SLOT))

  local weaponslot = MAINHAND_SLOT
  for _, itemName in ipairs(SkinnerEquip.EQUIPMENT) do
    local bag, slot = SkinnerEquip.FindItem(itemName)
    if slot then
      if weaponslot == OFFHAND_SLOT and not SkinnerEquip.offHand then
        SkinnerEquip.offHandBag = bag
        SkinnerEquip.offHandSlot = slot
      end
      PickupContainerItem(bag, slot)
      PickupInventoryItem(weaponslot)
      weaponslot = weaponslot + 1
    end
    if weaponslot > OFFHAND_SLOT then break end
  end
end

function SkinnerEquip.UnequipTools()
  SkinnerEquip.skinning = false

  if SkinnerEquip.offHand then
    local bag, slot = SkinnerEquip.FindItem(SkinnerEquip.offHand)
    if bag and slot then
      PickupContainerItem(bag, slot)
      PickupInventoryItem(OFFHAND_SLOT)
    end
  elseif SkinnerEquip.offHandBag and SkinnerEquip.offHandSlot then
    PickupInventoryItem(OFFHAND_SLOT)
    PickupContainerItem(SkinnerEquip.offHandBag, SkinnerEquip.offHandSlot)
  end

  if SkinnerEquip.mainHand then
    local bag, slot = SkinnerEquip.FindItem(SkinnerEquip.mainHand)
    if bag and slot then
      PickupContainerItem(bag, slot)
      PickupInventoryItem(MAINHAND_SLOT)
    end
  end
end

function SkinnerEquip.OnLoad()
  DEFAULT_CHAT_FRAME:AddMessage("SkinnerEquip Loaded")
  SLASH_skinnerswap1 = "/skinnerswap"
  SlashCmdList["skinnerswap"] = function(args)
    if SkinnerEquip.skinning then
      SkinnerEquip.UnequipTools()
    else
      SkinnerEquip.EquipTools()
      SkinnerEquip.manualSwap = true
    end
  end
end

function SkinnerEquip.eventHandler()
  if not event then return end

  if event == "ADDON_LOADED" and arg1 == "SkinnerEquip" then
    SkinnerEquip.OnLoad()
  elseif event == "UI_ERROR_MESSAGE" and arg1 and string.find(arg1, "Requires Skinning") then
    SkinnerEquip.manualSwap = false
    SkinnerEquip.EquipTools()
  elseif event == "LOOT_CLOSED" and SkinnerEquip.skinning and not SkinnerEquip.manualSwap then
    SkinnerEquip.UnequipTools()
  end
end

function SkinnerEquip.GetItemNameFromLink(itemLink)
  if itemLink then
    return string.match(itemLink, "%[(.+)%]")
  end
  return nil
end

SkinnerEquip.Frame = CreateFrame("FRAME")
SkinnerEquip.Frame:RegisterEvent("ADDON_LOADED")
SkinnerEquip.Frame:RegisterEvent("LOOT_CLOSED")
SkinnerEquip.Frame:RegisterEvent("UI_ERROR_MESSAGE")
SkinnerEquip.Frame:SetScript("OnEvent", SkinnerEquip.eventHandler)
