-- Create a frame to listen for events
local frame = CreateFrame("Frame")

-- Register the BAG_UPDATE event to detect changes in the player's inventory
frame:RegisterEvent("BAG_UPDATE")

-- Function to handle bag updates
local function OnBagUpdate(self, event, ...)
    -- Loop through all the player's bags (0 to 4)
    for bagID = 0, 4 do
        -- Get the number of slots in the current bag
        local numSlots = GetContainerNumSlots(bagID)

        -- Loop through each slot in the bag
        for slotID = 1, numSlots do
            -- Get the item link for the current slot
            local itemLink = GetContainerItemLink(bagID, slotID)

            -- Check if there's an item in the slot
            if itemLink then
                -- Get the cursor information (item is picked up)
                local isPickup = GetCursorInfo()

                -- Check if Alt key is pressed and if cursor is empty
                if IsAltKeyDown() and not isPickup then
                    -- Get item information
                    local itemName, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(itemLink)
                    
                    -- Pickup the item
                    PickupContainerItem(bagID, slotID)
                    
                    -- If the item is picked up, delete it
                    if GetCursorInfo() == "item" then
                        DeleteCursorItem()
                        
                        -- Print a confirmation message
                        print("|cffFF0000QuickDelete:|r Deleted item: " .. itemName .. " |T" .. itemTexture .. ":0|t")
                        
                        -- Stop further processing as the item is deleted
                        return
                    end
                end
            end
        end
    end
end


-- Set the script for handling events
frame:SetScript("OnEvent", OnBagUpdate)

-- Tooltip: Enhancing the item tooltip with instructions
GameTooltip:HookScript("OnTooltipSetItem", function(self)
    local name, link = self:GetItem()
    if link then
        self:AddLine("|cFF00FF00Hold Alt and Left Click to delete this item.|r")
    end
end)