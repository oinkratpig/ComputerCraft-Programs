
-- by oinky
--=======================================================================
-- INSTRUCTION MANUAL
-- 
-- Blueprint for the burger station:
-- ( 5x4, facing south )
--
-- 	C C B O O	|	C = Cabbage crop
-- 	T C   O W	|	T = Tomato crop
-- 	T   -   W	|	O = Onion crop
-- 	T       W	|	W = Wheat crop
--		P		|	B = Burger output barrel
--				|	P = Cooked beef patties barrel (place into floor)
--				|	- = Water source (waterlog to make solid)
--
-- (1)	Burger station must be facing south to make sure turtle is
-- 		properly calibrated.
-- (2)	Turtle will be placed in the middle where the water source is.
--		It's recommended to waterlog it so you can replace the turtle
--		easily (and to make it look nicer).
-- (3)	Make sure the turtle is properly fueled. It will stop cooking
--		if fuel runs out.
-- (4)	Crops and barrel should be on the same level as the turtle when
--		first placed. The only blocks that should be placed under are the
--		water source and beef patty barrel.
-- (5)	There should be one of each in each slot of the turtle's inventory,
--		in order:
--		-	bread, beef patty, cabbage, tomato, onion, wheat, wheat seeds,
--			cabbage seeds, tomato seeds
--		ALL OTHER SLOTS MUST BE OCCUPIED BY A FILLER ITEM, SUCH AS
--		STICKS OR DIRT.
-- (6)	Beef patties must be cooked and placed

--=======================================================================

-- All crops are max growth at age 7
-- Tomato is the exception is the only one that does not need replanting

-- All inventory slots must always have at least one item in the stack
-- so that the inventory order is always consistent

-- States
-- 0: Needs fuel - Terminates program
-- 1: Farming - Replanting fully-grown crops
-- 2: Check patties - Grabs beef patties from the barrel
-- 3: Output - Crafts a burger and places it in the output
state = 0

-- Inventory slot indexes
slots = {
	bread = 1,
	patty = 2,
	cabbage = 3,
	tomato = 4,
	onion = 5,
	wheat = 6,
	wheatSeeds = 7,
	cabbageSeeds = 8,
	tomatoSeeds = 9
}

-- Facing direction
directions = {
	north = 1,
	east = 2,
	south = 3,
	west = 4
}
facing = directions["south"]

-- Position relative to start
xPos = 0
yPos = 0
zPos = 0

tomatoMaxAge = 3 -- Harvestable age of tomato crops
maxAge = 7 -- Harvestable age of generic crops

minItemAmount = 5 -- Minimum of each item to carry

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
--	int (x) x position to Moves
--	int (z) z position to Moves
function Move(x, z)
	-- Move X axis
	if x ~= 0 then
		Face(directions["east"])
		while x > 0 do
			if not turtle.forward() then
				break
			end
			xPos = xPos - 1
			x = x - 1
		end
		while x < 0 do
			if not turtle.back() then
				break
			end
			xPos = xPos + 1
			x = x + 1
		end
	end
	-- Move Z axis
	if z ~= 0 then
		Face(directions["south"])
		while z > 0 do
			if not turtle.forward() then
				break
			end
			zPos = zPos - 1
			z = z - 1
		end
		while z < 0 do
			if not turtle.back() then
				break
			end
			zPos = zPos + 1
			z = z + 1
		end
	end
end

-- Returns home
function ReturnHome()
	print("Returning home.")
	Move(xPos, zPos)
	Face(directions["south"])
	turtle.down()
end

-- Returns max age of current crop
function CurrentCropMaxAge()
	_, blockData = turtle.inspectDown()
	blockName = blockData["name"]
	if blockName == "farmersdelight:tomatoes" then
		return tomatoMaxAge
	else
		return maxAge
	end
end

-- Gets the inventory index for the crop's seeds
function GetCropSeedsIndex()
	_, blockData = turtle.inspectDown()
	blockName = blockData["name"]
	if blockName == "farmersdelight:onions" then
		return slots["onion"]
	elseif blockName == "minecraft:wheat" then
		return slots["wheatSeeds"]
	elseif blockName == "farmersdelight:cabbages" then
		return slots["cabbageSeeds"]
	elseif blockName == "farmersdelight:tomatoes" then
		return slots["tomatoSeeds"]
	else
		print("A crop doesn't have a matching seed index.")
		return -1
	end
end

-- Harvests crop below if max age
function TryHarvest()
	print("Checking for crop...")
	blockExists, blockData = turtle.inspectDown()
	blockState = blockData["state"]
	if blockState ~= nil then
		cropAge = blockState["age"]
		if cropAge ~= nil then
			if cropAge == CurrentCropMaxAge() then
				print("Harvesting...")
				seedSlotIndex = GetCropSeedsIndex()
				turtle.digDown()
				print("Replanting...")
				turtle.select(seedSlotIndex)
				turtle.placeDown()
			else
				print("Crop's not ready to harvest.")
			end
		end
	end
end

-- Attempts to create bread if enough wheat is available
function TryCraftBread()
	turtle.select(slots["wheat"])
	itemDetails = turtle.getItemDetail()
	if itemDetails ~= nil then
		-- Needs more than 3 wheat so the slot is persistent
		if itemDetails["count"] > 3 then
			
		end
	end
end

-- Harvest all crops that are grown
-- INTENDED TO BE CALLED FROM RESTING POSITION FACING SOUTH
function HarvestAll()
	turtle.up()
	-- East crops
	print("Starting east crop harvest.")
	Move(2, -1)
	TryHarvest()
	for _ = 1, 3 do
		Move(0, 1)
		TryHarvest()
	end
	Move(-1, 0)
	TryHarvest()
	Move(0, -1)
	TryHarvest()
	-- West Crops
	print("Starting west crop harvest.")
	Move(-2, 0)
	TryHarvest()
	Move(0, 1)
	TryHarvest()
	Move(-1, 0)
	TryHarvest()
	for _ = 1, 3 do
		Move(0, -1)
		TryHarvest()
	end
	-- Return home
	ReturnHome()
end

-- Restock on cooked beef patties
-- INTENDED TO BE CALLED FROM RESTING POSITION FACING SOUTH
function RestockPatties()
	Move(0, -2)
	-- Count number of patties held currently
	pattyCount = 0
	turtle.select(slots["patty"])
	itemDetails = turtle.getItemDetail()
	if itemDetails ~= nil then
		pattyCount = itemDetails["count"]
	end
	-- Suck patties
	if pattyCount < 64 then
		turtle.suckDown(64 - pattyCount)
	end
	-- Done
	ReturnHome()
end

-- Deposit ingredients into crafters
-- INTENDED TO BE CALLED FROM RESTING POSITION FACING SOUTH
function DepositIngredients()
	print("Depositing ingredients...")
	turtle.up()
	-- Bread crafter
	Move(-1, -1)
	Face(directions["north"])
	print("Depositing wheat.")
	turtle.select(slots["wheat"])
	dropAmount = math.max(GetItemCount() - minItemAmount, 0)
	turtle.drop(dropAmount)
	-- Burger crafter
	Move(2, 0)
	Face(directions["north"])
	print("Depositing burger ingredients.")
	for i = 1, 5 do
		turtle.select(i)
		dropAmount = math.max(GetItemCount() - minItemAmount, 0)
		turtle.drop(dropAmount)
	end
	-- Return home
	ReturnHome()
end

DepositIngredients()