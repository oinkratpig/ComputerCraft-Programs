
-- Place bot on a corner of the farm, facing into the farm.
-- Below the starting position should be a barrel containing fuel. It will automatically grab from it when out of fuel.

-- Farm details
farmWidth = 14
farmHeight = 9
-- Position of output barrel relative to the home position
-- For example, 1 block would be 1 block AWAY from the home position
barrelOffsetX = 5
barrelOffsetY = 4
-- Seconds between harvesting
cooldown = 90

x = 0 -- Left/right offset relative to home position (Higher = right)
y = 0 -- Forward/back offset (Higher = forward)
tomatoMaxAge = 3 -- Harvestable age of tomato crops
netherWartMaxAxe = 3 -- Harvestable age of nether wart
maxAge = 7 -- Harvestable age of generic crops
lowFuelAmount = 50 -- Amount of fuel to stop harvesting when reached
inventorySize = 16 -- Inventory size of turtle
flip = false -- Whether x movement direction is flipped
facingForward = true -- Whether turtle is facing forward
facingRight = true -- Whether turtle is facing right (only relevant if facingForward = false)

-- Returns true if the turtle is at the home position
function IsHome()
    return x == 0 and y == 0 and z == 0
end

-- Returns sign of number
function Sign(number)
    if number > 0 then
        return 1
    elseif number < 0 then
        return -1
    else
        return 0
    end
end

-- Returns max age of current crop
function CurrentCropMaxAge()
	_, blockData = turtle.inspectDown()
	blockName = blockData["name"]
	if blockName == "farmersdelight:tomatoes" then
		return tomatoMaxAge
	elseif blockName == "minecraft:nether_wart" then
		return netherWartMaxAge
	else
		return maxAge
	end
end

-- Refuels the turtle
function Refuel()
    for i = 1, inventorySize, 1 do
        turtle.select(i)
        turtle.refuel(64)
	end
    turtle.select(1)
end

-- Faces correct position for move distance
function FaceVector(xAmount, yAmount)
    -- Face forward
    if yAmount ~= 0 and not facingForward then
        if facingRight then
            turtle.turnLeft()
        else
            turtle.turnRight()
        end
        facingForward = true
    -- Face left/right
    elseif xAmount ~= 0 then
        -- Right
        if xAmount > 0 then
            if facingForward then
                turtle.turnRight()
            elseif not facingRight then
                turtle.turnRight()
                turtle.turnRight()
            end
            facingRight = true
        -- Left
        else
            if facingForward then
                turtle.turnLeft()
            elseif facingRight then
                turtle.turnLeft()
                turtle.turnLeft()
            end
            facingRight = false
        end
        facingForward = false
    end
end

-- Move
function Move(xAmount, yAmount)
    xAmount = math.floor(xAmount)
    yAmount = math.floor(yAmount)
    while xAmount ~= 0 or yAmount ~= 0 do
        -- X
        if xAmount ~= 0 then
            -- Face direction
            FaceVector(xAmount, 0)
            -- Invert x if facing left
            if not facingRight then
                xAmount = -xAmount
            end
            -- Dig if there's a block in the way
            while turtle.detect() do
                turtle.dig()
            end
            -- Move
            while xAmount > 0 do
                if turtle.forward() then
                    if facingRight then
                        x = x + 1
                    else
                        x = x - 1
                    end
                end
                xAmount = xAmount - 1
            end
        -- Y
        elseif yAmount ~= 0 then
            -- Face direction
            FaceVector(0, yAmount)
            -- Dig if there's a block in the way
            while turtle.detect() do
                turtle.dig()
            end
            -- Move
            while yAmount > 0 do
                if turtle.forward() then
                    y = y + 1
                end
                yAmount = yAmount - 1
            end
            while yAmount < 0 do
                if turtle.back() then
                    y = y - 1
                end
                yAmount = yAmount + 1
            end
        end
        -- This turtle sucks
        if x ~= barrelOffsetX and y ~= barrelOffsetY then
            turtle.suckDown()
        end
    end
end

-- Returns home
function ReturnHome()
	Move(-x, -y)
	turtle.down()
end

-- Harvest crop
function HarvestCrop()
    _, blockData = turtle.inspectDown()
	if blockData["name"] == "minecraft:pumpkin" or blockData["name"] == "minecraft:melon" then
		turtle.digDown()
    elseif blockData["name"] ~= "minecraft:sugar_cane" then
        blockState = blockData["state"]
        if blockState ~= nil then
            cropAge = blockState["age"]
            if cropAge ~= nil then
                if cropAge == CurrentCropMaxAge() then
                    turtle.digDown()
                end
            end
        end
    end
end

-- Main loop
while true do

    -- Attempt to refuel
    print("Attempting to refuel.")
    turtle.suckDown()
    Refuel()

    -- Harvesting
    flip = false
    if turtle.getFuelLevel() > lowFuelAmount then
        
        turtle.up()

        -- Harvest crops
        for fy = 1, farmHeight, 1 do
            print("Harvesting row " .. fy .. ".")
            for fx = 1, farmWidth - 1, 1 do
                HarvestCrop()
                if not flip then
                    Move(1, 0)
                else
                    Move(-1, 0)
                end
            end
			HarvestCrop()
            flip = not flip
            if fy ~= farmHeight then
                Move(0, 1)
            end
        end
        
        -- Deposit items into output barrel
        print("Depositing items.")
        Move(barrelOffsetX - x, barrelOffsetY - y)
        for i = 1, inventorySize, 1 do
            turtle.select(i)
            turtle.dropDown()
        end
        turtle.select(1)

    end

    -- Return home
    if not IsHome() then
        print("Returning home.")
        ReturnHome()
    end

    -- Wait before restarting
    print("Waiting cooldown (" .. cooldown .. "s)...")
    os.sleep(cooldown)

end