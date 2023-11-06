
-- Quarry
quarrySize = 0 -- Amount of blocks on both sides of the center
quarryLength = 0 -- Length of the quarry (deepness)

-- Digging
diggingRight = true
diggingReversed = false

-- Facing direction
directions = {
	forward = 1,
	right = 2,
	back = 3,
	left = 4
}
facing = directions["forward"]

-- Turn to face direction
-- Params:
--	int (newDirection) New direction to face
function Face(newDirection)
	difference = newDirection - facing
	-- Turn right
	while difference > 0 do
		turtle.turnRight()
		difference = difference - 1
	end
	-- Turn left
	while difference < 0 do
		turtle.turnLeft()
		difference = difference + 1
	end
	facing = newDirection
end

-- Moves by the given amount
-- Params:
--	int (x) x position to move
--	int (z) z position to move
function Move(x, z)
	-- Move left and right
	if x ~= 0 then
		Face(directions["right"])
		while x > 0 do
			if not turtle.forward() then
				break
			end
			x = x - 1
		end
		while x < 0 do
			if not turtle.back() then
				break
			end
			x = x + 1
		end
	end
	-- Move backwards and forwards
	if z ~= 0 then
		Face(directions["forward"])
		while z > 0 do
			if not turtle.forward() then
				break
			end
			z = z - 1
		end
		while z < 0 do
			if not turtle.back() then
				break
			end
			z = z + 1
		end
	end
end

-- Prepare to dig the next square
function PrepareDig()
	turtle.digDown()
	turtle.down()
end

-- Dig quarry size downwards one block
function DigSquare()
	-- Dig lines
	for i = 1, quarrySize * 2 + 1, 1 do
		-- Alternate turning left and right when digging lines
		if diggingRight then
			Face(directions["right"])
		else
			Face(directions["left"])
		end
		diggingRight = not diggingRight
		
		-- Dig line
		DigLine()
		-- Prepare to dig next line
		if i <= quarrySize * 2 then
			if not diggingReversed then
				Face(directions["forward"])
			else
				Face(directions["back"])
			end
			turtle.dig()
			turtle.forward()
		end
	end
	diggingReversed = not diggingReversed
end

-- Dig single line of quarry
function DigLine()
	for i = 1, quarrySize * 2, 1 do
		turtle.dig()
		turtle.forward()
	end
end


-- Get length and size of quarry from user
write("Quarry side length: ")
quarrySize = tonumber(read())
write("Quarry distance: ")
quarryLength = tonumber(read())
length = quarrySize * 2 + 1
print("Digging " .. length .. "x" .. length .. " quarry " .. quarryLength .. " blocks down.")
-- Position for digging
Move(-quarrySize, -quarrySize)
-- Dig
for i = 1, quarryLength, 1 do
	PrepareDig()
	DigSquare()
	print("Dug square. " .. quarryLength - i .. " left.")
end
