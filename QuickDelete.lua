-- Create a frame to listen for events
local frame = CreateFrame("Frame")

-- Function to show a confirmation dialog for rare items
local function ConfirmDelete(itemName, bagID, slotID)
    StaticPopupDialogs["CONFIRM_DELETE_ITEM"] = {
        text = "Are you sure you want to delete |cFF00FFFF" .. itemName .. "|r?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            PickupContainerItem(bagID, slotID)
            DeleteCursorItem()
            print("|cffFF0000QuickDelete:|r Deleted item: " .. itemName)
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }
    StaticPopup_Show("CONFIRM_DELETE_ITEM")
end

-- Function to handle item clicks
local function OnItemClick(self, button)
    -- Check if the Alt key is pressed and the left mouse button is clicked
    if IsAltKeyDown() and button == "LeftButton" then
        -- Get the bagID and slotID of the clicked item
        local bagID = self:GetParent():GetID()
        local slotID = self:GetID()

        -- Get the item link for the clicked slot
        local itemLink = GetContainerItemLink(bagID, slotID)

        -- Check if there's an item in the slot
        if itemLink then
            -- Get item information
            local itemName, _, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(itemLink)
            -- Only confirm for rare (blue) and above items
            if itemRarity >= 2 then
                ConfirmDelete(itemName, bagID, slotID)
            else
                -- Pickup the item from the specified bag and slot
                PickupContainerItem(bagID, slotID)

                -- Check if the item is picked up
                if GetCursorInfo() == "item" then
                -- Delete the item
                    DeleteCursorItem()

                    -- Print a confirmation message
                    print("|cffFF0000QuickDelete:|r Deleted item: " .. itemName .. " |T" .. itemTexture .. ":0|t")
                    return
                end
            end
        end
    end
end

-- Hook the click event for all bag slots
local function HookBagSlots()
    -- Loop through all the player's bags (0 to 4)
    for bagID = 0, NUM_BAG_FRAMES do
        -- Get the number of slots in the current bag
        local numSlots = GetContainerNumSlots(bagID)

        -- Loop through each slot in the bag
        for slotID = 1, numSlots do
            -- Get the button for the slot
            local button = _G["ContainerFrame"..(bagID + 1).."Item"..slotID]
            if button then
                -- Hook the OnClick event for the slot button
                button:HookScript("OnClick", OnItemClick)
            end
        end
    end
end

-- Call the function to hook all bag slots when the player logs in
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", HookBagSlots)

-- Tooltip: Enhancing the item tooltip with instructions
GameTooltip:HookScript("OnTooltipSetItem", function(self)
    local name, link = self:GetItem()
    if link then
        self:AddLine("|cFF00FF00Hold Alt and Left Click to delete this item.|r")
    end
end)