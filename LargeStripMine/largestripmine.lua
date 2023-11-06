
-- Returns true if all slots in inventory are taken
function inventoryFull()
	full = true
	for i = 1, 16 do -- 16 is inventory size
		if turtle.getItemCount(i) == 0 then
			full = false
			break
		end
	end
	return full
end

-- Digs until forward movement is allowed
-- Necessary for mining gravel/sand
function digThenForward()
	while turtle.detect() do
		turtle.dig()
	end
	turtle.forward()
end

-- Dig tunnel height
function digHeight()
	turtle.digUp()
	-- Dig above
	for i = 1, tunnelHeight - 2, 1 do
		turtle.up()
		turtle.digUp()
	end
	-- Return down
	for j = 1, tunnelHeight - 2, 1 do
		turtle.down()
	end
	-- If non-air block above (like gravel) dig it before moving on
	while turtle.detectUp() do
		turtle.digUp()
	end
	return 1
end

-- Dig side of tunnel
function digSide(isLeft)
	-- Rotate
	if isLeft then
		turtle.turnLeft()
	else
		turtle.turnRight()
	end
	-- Dig vertically for length of side
	for i = 1, tunnelSide, 1 do
		digThenForward()
		digHeight()
	end
	-- Return to starting position
	for j = 1, tunnelSide, 1 do
		turtle.back()
	end
	-- Reset rotation
	if isLeft then
		turtle.turnRight()
	else
		turtle.turnLeft()
	end
	return 1
end

-- Dig parameters
tunnelHeight = 0 -- Total height of tunnel
tunnelSide = 0 -- Side length next to middle of tunnel (2 = total width of 5)
distance = 0 -- Distance to dig out

currentDistance = 0 -- Current distance to dig
fuelMinimumExtra = 10 -- Extra fuel count to keep for emergencies

-- User input
write("Tunnel height: ")
tunnelHeight = tonumber(read())
write("Tunnel side length: ")
tunnelSide = tonumber(read())
write("Tunnel distance: ")
distance = tonumber(read())

-- Dig out
while currentDistance < distance do
	-- Dig middle
	print("Digging middle.")
	digThenForward()
	digHeight()
	-- Dig sides
	print("Digging right.")
	digSide(false)
	print("Digging left.")
	digSide(true)
	-- Increase distance
	currentDistance = currentDistance + 1
	-- If inventory full, return home
	if inventoryFull() then
		print("Inventory full. Returning.")
		break
	-- If fuel under threshold, return home
	elseif turtle.getFuelLevel() < currentDistance  + fuelMinimumExtra then
		print("Low fuel. Returning.")
		break
	-- If ran into lava lake, return home
	else
		blockExists, blockData = turtle.inspect()
		if(blockExists and blockData["name"] == "minecraft:lava") then
			print("Ran into lava lake. Returning.")
			break
		end
	end
	-- Report distance
	print("Finished dig " .. currentDistance .. "/" .. distance)
end

-- Return home
while currentDistance > 0 do
	turtle.back()
	currentDistance = currentDistance - 1
end