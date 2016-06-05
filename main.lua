-- Asteroids game. Player travels on the field & collects coins. OK?
require("player")

MAX_RADIUS = 500
MIN_RADIUS = 20
GRAVITATIONAL_CONSTANT = 6.674 * 10^-11
PLANET_MASS_MIN = 10^17
PLANET_MASS_MAX = 10^20
PLANET_GEN_DISTANCE = 10^4

function love.load()
	math.randomseed(os.time())
	player = {}
		player.acceleration = 300
		player.angularSpeed = math.pi / 192
		player.rotation = 0; -- Down the x axis (i.e. to the top of the screen)
		player.activeImg = love.graphics.newImage('assets/rocket_active.png')
		player.inactiveImg = love.graphics.newImage('assets/rocket_inactive.png')
		player.active = false
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

	planets = {} -- To store planets and planetoids
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
		player.active = true
	elseif love.keyboard.isDown('down','s') then
		player.active = false
	end

	if player.active then
		player.velocity.x = player.velocity.x + player.acceleration * dt^2 * math.sin(player.rotation) / 2
		player.velocity.y = player.velocity.y + player.acceleration * dt^2 * math.cos(player.rotation) / 2
		if pathInterval > pathIntervalMax then
			table.insert(path, {
				pos = {
					x = player.global_pos.x - player.activeImg:getHeight() / 2 * math.sin(player.rotation),
					y = player.global_pos.y - player.activeImg:getHeight() / 2 * math.cos(player.rotation)
				},
				velocity = {
					x = - player.acceleration * pathIntervalMax^2 * math.sin(player.rotation) / 2,
					y = - player.acceleration * pathIntervalMax^2 * math.cos(player.rotation) / 2
				}
			})
			pathInterval = 0
		else
			pathInterval = pathInterval + dt
		end
	end

	for i, particle in ipairs(path) do
		particle.pos.x = particle.pos.x + particle.velocity.x * dt
		particle.pos.y = particle.pos.y + particle.velocity.y * dt
	end

	player.global_pos.x = player.global_pos.x + player.velocity.x * dt
	player.global_pos.y = player.global_pos.y + player.velocity.y * dt

	player.window_pos = { -- ALWAYS at the center of the screen
		x = love.graphics.getWidth() / 2,
		y = love.graphics.getHeight() / 2
	}

	-- Create planets
	local planet = {}
	local createPlanet = true
		planet.pos = {
			x = player.global_pos.x + math.random(PLANET_GEN_DISTANCE) - PLANET_GEN_DISTANCE / 2,
			y = player.global_pos.y + math.random(PLANET_GEN_DISTANCE) - PLANET_GEN_DISTANCE / 2
		}
		for i, otherPlanet in ipairs(planets) do
			if math.sqrt((otherPlanet.pos.x - planet.pos.x)^2 + (otherPlanet.pos.y - planet.pos.y)^2) < love.graphics.getWidth() then
				createPlanet = false
			end
		end
		if createPlanet then
			planet.color = {math.random(100) + 100, math.random(100) + 100, math.random(100) + 100}
			planet.radius = math.random(MAX_RADIUS - MIN_RADIUS) + MIN_RADIUS
			planet.mass = math.random(PLANET_MASS_MAX - PLANET_MASS_MIN) + PLANET_MASS_MIN
			table.insert(planets, planet)
		end

	local acceleration = {x = 0, y = 0}
	for i, planet in ipairs(planets) do
		local dx = planet.pos.x - player.global_pos.x
		local dy = planet.pos.y - player.global_pos.y
		local distance = math.sqrt(dx^2 + dy^2)

		acceleration.x = acceleration.x + GRAVITATIONAL_CONSTANT * planet.mass * dx / distance^3
		acceleration.y = acceleration.y + GRAVITATIONAL_CONSTANT * planet.mass * dy / distance^3
	end

	player.velocity.x = player.velocity.x + acceleration.x * dt^2 / 2
	player.velocity.y = player.velocity.y + acceleration.y * dt^2 / 2
end

function love.draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.print("Position: x = " .. player.global_pos.x
		.. ", y = " .. player.global_pos.y .. "\nRotation is "
		.. math.floor(math.abs(player.rotation / math.pi * 180 % 360)) .. "°\n"
		.. "Fuel spent: " .. #path .. " kg\n"
		.. "Velocity: x = " .. player.velocity.x
		.. ", y = " .. player.velocity.y .. "\nSpeed: "
		.. math.sqrt(player.velocity.y^2 + player.velocity.x^2)
		.. "\nNumber of discovered planets: " .. #planets, 0, 0)
	if player.active then
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(player.activeImg, player.window_pos.x, player.window_pos.y,
			player.rotation, 1, 1, player.activeImg:getWidth() / 2,
			player.activeImg:getHeight() / 2)
	else
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(player.inactiveImg, player.window_pos.x, player.window_pos.y,
			player.rotation, 1, 1, player.inactiveImg:getWidth() / 2,
			player.inactiveImg:getHeight() / 2)
	end

	for i, particle in ipairs(path) do
		local x, y = global_to_local(particle.pos.x, particle.pos.y, player.global_pos.x, player.global_pos.y)
		x = x + player.window_pos.x
		y = y + player.window_pos.y
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(pathImg, x, y, 0, 1, 1, pathImgSize / 2, pathImgSize / 2)
	end

	for i, planet in ipairs(planets) do
		local x, y = global_to_local(planet.pos.x, planet.pos.y, player.global_pos.x, player.global_pos.y)
		x = x + player.window_pos.x
		y = y + player.window_pos.y
		love.graphics.setColor(planet.color)
		love.graphics.circle("fill", x, y, planet.radius)
	end
end
