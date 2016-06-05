-- Asteroids game. Player travels on the field & collects coins. OK?
require("player")

function love.load()
	player = {}
--		player.linearSpeed = 100
		player.acceleration = 300
		player.angularSpeed = math.pi / 192
		player.rotation = 0; -- Down the x axis (i.e. to the top of the screen)
		player.img = love.graphics.newImage('assets/player.png')
		player.imgWidth = player.img:getWidth()
		player.imgHeight = player.img:getHeight()
		player.global_pos = {
			x = 0,
			y = 0
		}
		player.velocity = {
			x = 0,
			y = 0
		}

	path = {} -- Contains path particles
	pathImg = love.graphics.newImage('assets/particle.png')
	pathImgSize = 64
	pathIntervalMax = 2 -- Controls how much time should pass between particle creation
	pathInterval = 0
end

function love.update(dt)
	if love.keyboard.isDown('escape', 'q') then
		love.event.push('quit')
	end

	-- Player stuff
	if love.keyboard.isDown('left','a') then
		player.rotation = (player.rotation - player.angularSpeed) % (2*math.pi)
	elseif love.keyboard.isDown('right','d') then
		player.rotation = (player.rotation + player.angularSpeed) % (2*math.pi)
	elseif love.keyboard.isDown('up','w') then
		player.velocity.x = player.velocity.x + player.acceleration * dt^2 * math.sin(player.rotation) / 2
		player.velocity.y = player.velocity.y + player.acceleration * dt^2 * math.cos(player.rotation) / 2
	elseif love.keyboard.isDown('down','s') then
		player.velocity.x = player.velocity.x - player.acceleration * dt^2 * math.sin(player.rotation) / 2
		player.velocity.y = player.velocity.y - player.acceleration * dt^2 * math.cos(player.rotation) / 2
	end

	if pathInterval > pathIntervalMax then
		table.insert(path, {
			x = player.global_pos.x - player.imgHeight / 2 * math.sin(player.rotation),
			y = player.global_pos.y - player.imgHeight / 2 * math.cos(player.rotation),})
		pathInterval = 0
	else
		pathInterval = pathInterval + dt
	end

	player.global_pos.x = player.global_pos.x + player.velocity.x * dt
	player.global_pos.y = player.global_pos.y + player.velocity.y * dt

	player.window_pos = { -- ALWAYS at the center of the screen
		x = love.graphics.getWidth() / 2,
		y = love.graphics.getHeight() / 2
	}
end

function love.draw()
	love.graphics.print("Position: x = " .. player.global_pos.x
		.. ", y = " .. player.global_pos.y .. "\nRotation is "
		.. math.floor(math.abs(player.rotation / math.pi * 180 % 360)) .. "°\n"
		.. "Distance traveled: " .. #path .. " m\n"
		.. "Velocity: x = " .. player.velocity.x
		.. ", y = " .. player.velocity.y .. "\nSpeed: "
		.. math.sqrt(player.velocity.y^2 + player.velocity.x^2), 0, 0)
	love.graphics.draw(player.img, player.window_pos.x, player.window_pos.y, player.rotation, 1, 1, player.imgWidth / 2, player.imgHeight / 2)

	for i, particle in ipairs(path) do
		local x, y = global_to_local(particle.x, particle.y, player.global_pos.x, player.global_pos.y)
		x = x + player.window_pos.x
		y = y + player.window_pos.y
		love.graphics.draw(pathImg, x, y, 0, 1, 1, pathImgSize / 2, pathImgSize / 2)
	end
end
