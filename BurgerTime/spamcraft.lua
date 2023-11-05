
print("Enter number of slots used by crafting")
slots = read()

print("Running spam craft...")

-- Returns amount of item in inventory slot index
function GetItemCount(index)
	-- Optional argument
	if not index then
		index = turtle.getSelectedSlot()
	end
	-- Return amount of item
	itemDetails = turtle.getItemDetail(index)
	if itemDetails ~= nil then
		return itemDetails["count"]
	end
	return -1
end

-- Spam craft
while true do

	-- Check if all slots are larger than one
	uncraftable = false
	for i = 1, slots, 1 do
		if GetItemCount(i) < 2 then
			uncraftable = true
		end
	end

	-- Craft if craftable
	if not uncraftable then
		turtle.craft(1)
	end
	
	-- Dump crafted item
	turtle.select(slots + 1)
	if GetItemCount() >= 1 then
		turtle.dropDown()
	end

	-- Count ingredients
	totals = {}
	slotsTaken = {}
	averages = {}
	for i = 1, slots, 1 do
		itemDetails = turtle.getItemDetail(i)
		if itemDetails ~= nil then
			itemName = itemDetails["name"]
			itemCount = itemDetails["count"]
			if totals[itemName] == nil then
				totals[itemName] = itemCount
				slotsTaken[itemName] = 1
				averages[itemName] = itemCount
			else
				totals[itemName] = totals[itemName] + itemCount
				slotsTaken[itemName] = slotsTaken[itemName] + 1
				averages[itemName] = totals[itemName] / slotsTaken[itemName]
			end
		end
	end
	
	-- If a slot has a higher count than average, add half of the difference to the lowest other count
	-- Each item
	for i = 1, slots, 1 do
		itemDetails = turtle.getItemDetail(i)
		if itemDetails ~= nil then
			itemName = itemDetails["name"]
			itemCount = itemDetails["count"]
			-- Count is above average
			if itemCount > averages[itemName] then
				-- Find lowest count of matching item
				lowestCount = 64
				lowestSlot = -1
				for j = 1, slots, 1 do
					count = GetItemCount(j)
					if count < lowestCount then
						lowestCount = count
						lowestSlot = j
					end
				end
				-- Add half of amount over average to lowest item
				amountToTransfer = math.floor((itemCount - averages[itemName]) / 2)
				turtle.select(i)
				turtle.transferTo(lowestSlot, amountToTransfer)
			end
		end
	end

	-- Wait before crafting again
	os.sleep(1)

end