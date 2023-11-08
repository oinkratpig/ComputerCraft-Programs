
cooldown = 30 -- How many seconds before checking bamboo again
inventorySize = 16 -- Size of turtle inventory

print("Started refueling.")
while true do
	-- Growth detected
	if turtle.detect() then
		print("Harvested bamboo.")
		turtle.dig()
	end

	-- Refuel
	print("Refueling.")
	for i = 1, inventorySize, 1 do
        turtle.select(i)
        turtle.refuel(64)
	end
    turtle.select(1)
	print("Current fuel level: " .. turtle.getFuelLevel())

	-- Stop
	if turtle.getFuelLevel() >= turtle.getFuelLimit() then
		print("Max fuel. Stopping.")
		break
	end

	-- Cooldown
	print("Waiting cooldown (" .. cooldown .. "s)...")
	os.sleep(cooldown)
end