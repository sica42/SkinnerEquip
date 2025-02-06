local SkinnerEquip = {};

SkinnerEquip.EQUIPMENT = {
	"Finkle's Skinner",
	"Zulian Slicer",
    "Shadowforge Skinner",
}

function SkinnerEquip.EquipTools()
    SkinnerEquip.skinning = true
    SkinnerEquip.mainHand = SkinnerEquip.GetItemNameFromLink( GetInventoryItemLink("player", 16) )
    SkinnerEquip.offHand = SkinnerEquip.GetItemNameFromLink( GetInventoryItemLink("player", 17) )

    local weaponslot = 16
    for i = 1, getn(SkinnerEquip.EQUIPMENT) do
        local bag, slot = Roids.FindItem(SkinnerEquip.EQUIPMENT[i])
        if slot then
            if weaponslot == 17 and not SkinnerEquip.offHand then
                SkinnerEquip.offHandBag = bag
                SkinnerEquip.offHandSlot = slot
            end
            PickupContainerItem(bag, slot)
            PickupInventoryItem(weaponslot)
            weaponslot = weaponslot + 1
        end
        if weaponslot == 18 then break end
    end
end

function SkinnerEquip.UnequipTools()
    SkinnerEquip.skinning = false

    if SkinnerEquip.offHand then
        local bag, slot = Roids.FindItem(SkinnerEquip.offHand);
        PickupContainerItem(bag, slot)
        PickupInventoryItem(17)
    elseif SkinnerEquip.offHandBag and SkinnerEquip.offHandSlot then      
        PickupInventoryItem(17)
        PickupContainerItem(SkinnerEquip.offHandBag, SkinnerEquip.offHandSlot)
    end

    if SkinnerEquip.mainHand then
        local bag, slot = Roids.FindItem(SkinnerEquip.mainHand);
        PickupContainerItem(bag, slot)
        PickupInventoryItem(16)
    end
end

function SkinnerEquip.OnLoad()    
    ChatFrame1:AddMessage("SkinnerEquip Loaded")
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
    if event == "ADDON_LOADED" then
        if arg1 == "SkinnerEquip" then
            SkinnerEquip.OnLoad()
        end
    elseif event == "UI_ERROR_MESSAGE" then
        if arg1 and string.find(arg1, "Requires Skinning") then
            SkinnerEquip.manualSwap = false
            SkinnerEquip.EquipTools()            
        end
    elseif event == "LOOT_CLOSED" then
        if SkinnerEquip.skinning and not SkinnerEquip.manualSwap then
            SkinnerEquip.UnequipTools()
        end
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