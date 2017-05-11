require("player")

MAX_RADIUS = 3 * 10^2
MIN_RADIUS = 20
GRAVITATIONAL_CONSTANT = 6.674 * 10^-11 * 10^9
PLANET_DENSITY_MIN = 0.8
PLANET_DENSITY_MAX = 3
PLANET_GEN_DISTANCE = 2 * 10^4
PLANET_MIN_DISTANCE = 4 * 10^3
MAX_SAFE_IMPACT_SPEED = 50
STAR_MIN_DISTANCE = 50

function love.load()
	math.randomseed(os.time())
	engine_noise = love.audio.newSource("assets/engine_noise.ogg", "static")

	player = {}
		player.acceleration = 10^4
		player.angularSpeed = math.pi / 2
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
		player.landed = false
		player.alive = true
		player.speed = 0

	tracer = {} -- Contains tracing points
	tracerRadius = 2
	tracerColor = {255, 0, 0}
	tracerShow = true

	pause = false
	scale = 1
	playerScale = 1
	planetScele = 1

	timeScale = 1

	time = 0

	planets = {} -- To store planets and planetoids

	stars = {} -- Stores stars
end

function love.update(dt)
	if pause then
		return
	end

	if love.keyboard.isDown("left", "a") then
		player.rotation = (player.rotation - player.angularSpeed * dt) % (2*math.pi)
	elseif love.keyboard.isDown("right","d") then
		player.rotation = (player.rotation + player.angularSpeed * dt) % (2*math.pi)
	end

	count = 0
	while count < timeScale do
		time = time + dt
		if player.active then
			engine_noise:play()
			if player.landed then -- Give it a little push
				player.global_pos.x = player.global_pos.x + player.acceleration * math.sin(player.rotation)
				player.global_pos.y = player.global_pos.y + player.acceleration * math.cos(player.rotation)
			else
				player.velocity.x = player.velocity.x + player.acceleration * dt^2 * math.sin(player.rotation) / 2
				player.velocity.y = player.velocity.y + player.acceleration * dt^2 * math.cos(player.rotation) / 2
			end
		else
			engine_noise:stop()
		end

		player.global_pos.x = player.global_pos.x + player.velocity.x * dt
		player.global_pos.y = player.global_pos.y + player.velocity.y * dt

		table.insert(tracer, {
			pos = {
				x = player.global_pos.x,
				y = player.global_pos.y
			}
		})

		player.window_pos = { -- ALWAYS at the center of the screen
			x = love.graphics.getWidth() / 2,
			y = love.graphics.getHeight() / 2
		}

		-- Create stars
		local star = {}
			local createStar = true
			star.pos = {
				x = math.random(love.graphics.getWidth()),
				y = math.random(love.graphics.getHeight())
			}
			for i, otherStar in ipairs(stars) do
				if math.sqrt((otherStar.pos.x - star.pos.x)^2 + (otherStar.pos.y - star.pos.y)^2) < STAR_MIN_DISTANCE then
					createStar = false
				end
			end
			if createStar then
				star.color = {math.random(155) + 100, math.random(155) + 100, math.random(155) + 100}
				table.insert(stars, star)
			end
			-- Also delete some of the old stars
--[[
			if math.random(100) == 1 then
				table.remove(stars, math.random(#stars))
			end
--]]

		-- Create planets
		local planet = {}
			local createPlanet = true
			planet.pos = {
				x = player.global_pos.x + math.random(PLANET_GEN_DISTANCE) - PLANET_GEN_DISTANCE / 2,
				y = player.global_pos.y + math.random(PLANET_GEN_DISTANCE) - PLANET_GEN_DISTANCE / 2
			}
			for i, otherPlanet in ipairs(planets) do
				if math.sqrt((player.global_pos.x - planet.pos.x)^2 + (player.global_pos.y - planet.pos.y)^2) < PLANET_MIN_DISTANCE * 1.5
				or math.sqrt((otherPlanet.pos.x - planet.pos.x)^2 + (otherPlanet.pos.y - planet.pos.y)^2) < PLANET_MIN_DISTANCE then
					createPlanet = false
				end
			end
			if createPlanet then
				planet.color = {math.random(100) + 100, math.random(100) + 100, math.random(100) + 100}
				planet.radius = math.random(MAX_RADIUS - MIN_RADIUS) + MIN_RADIUS
				planet.density = math.random(PLANET_DENSITY_MAX - PLANET_DENSITY_MIN) + PLANET_DENSITY_MIN
				-- We assume that planets are spheres
				planet.mass = planet.density * planet.radius * (4 / 3) * math.pi * planet.radius^3
				table.insert(planets, planet)
			end

		local acceleration = {x = 0, y = 0}
		for i, planet in ipairs(planets) do
			local dx = planet.pos.x - player.global_pos.x
			local dy = planet.pos.y - player.global_pos.y
			local distance = hypot(dx, dy)
			
			if player_on_planet(player, planet, distance) then
				player.landed = true
				if player.alive then
					if player.speed > MAX_SAFE_IMPACT_SPEED then
						player.alive = false
					end
				end

				acceleration = {x = 0, y = 0}
				player.velocity.x = 0
				player.velocity.y = 0
			elseif not player_on_planet(player, planet, distance - 10) then
				player.landed = false

				acceleration.x = acceleration.x + GRAVITATIONAL_CONSTANT * planet.mass * dx / distance^3
				acceleration.y = acceleration.y + GRAVITATIONAL_CONSTANT * planet.mass * dy / distance^3
			end
		end

		player.velocity.x = player.velocity.x + acceleration.x * dt^2 / 2
		player.velocity.y = player.velocity.y + acceleration.y * dt^2 / 2
	count = count + 1
	end
end

function love.draw()
	for i, star in ipairs(stars) do
		love.graphics.setColor(star.color)
--		love.graphics.points(star.pos.x, star.pos.y)
		love.graphics.circle("fill", star.pos.x, star.pos.y, 1)
	end

	if player.active then
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(player.activeImg, player.window_pos.x, player.window_pos.y,
			player.rotation, playerScale, playerScale, player.activeImg:getWidth() / 2,
			player.activeImg:getHeight() / 2)
	else
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(player.inactiveImg, player.window_pos.x, player.window_pos.y,
			player.rotation, playerScale, playerScale, player.inactiveImg:getWidth() / 2,
			player.inactiveImg:getHeight() / 2)
	end

	for i, planet in ipairs(planets) do
		local x, y = global_to_local(planet.pos.x, planet.pos.y, player.global_pos.x, player.global_pos.y)
		x = x * scale + player.window_pos.x
		y = y * scale + player.window_pos.y

		if x > -planet.radius and x < love.graphics.getWidth() + planet.radius
		and y > -planet.radius and y < love.graphics.getHeight() + planet.radius then
			love.graphics.setColor(planet.color)
			love.graphics.circle("fill", x, y, planet.radius * planetScele)
			--love.graphics.setColor(255, 255, 255)
			--love.graphics.circle("line", x, y, planet.orbit * planetScele)
		end
	end

	if tracerShow then
		for i, trace in ipairs(tracer) do
			local x, y = global_to_local(trace.pos.x, trace.pos.y, player.global_pos.x, player.global_pos.y)
			x = x * scale + player.window_pos.x
			y = y * scale + player.window_pos.y

			if x > 0 and x < love.graphics.getWidth()
			and y > 0 and y < love.graphics.getHeight() then
				love.graphics.setColor(tracerColor)
				love.graphics.circle("fill", x, y, tracerRadius * playerScale)
			end
		end
	end

	love.graphics.setColor(255, 255, 255)
	local nearestPlanetDistance, nearestPlanet = nearest_planet(player.global_pos.x, player.global_pos.y, planets)
	local planetSurfaceGravity = GRAVITATIONAL_CONSTANT * nearestPlanet.mass / nearestPlanet.radius^2
	local planetEscapeVelocity = math.sqrt(planetSurfaceGravity * nearestPlanet.radius)
	love.graphics.print("Position: x = " .. math.floor(player.global_pos.x)
		.. ", y = " .. math.floor(player.global_pos.y) .. "\nRotation is "
		.. math.floor(player.rotation / math.pi * 180) .. "°\n"
		.. "Velocity: x = " .. math.floor(player.velocity.x)
		.. ", y = " .. math.floor(player.velocity.y) .. "\nSpeed: "
		.. math.floor(math.sqrt(player.velocity.y^2 + player.velocity.x^2)) .. " m/s"
--		.. "\nTotal number of planets: " .. #planets
		.. "\nThe nearest planet is in " .. math.floor(nearestPlanetDistance)
		.. " m\nIt's radius is " .. nearestPlanet.radius .. " m"
--		.. "\nGravity on its surface is " .. math.floor(planetSurfaceGravity) .. " m/s^2"
--		.. "\nIts escape velocity is " .. math.floor(planetEscapeVelocity) .. " m/s"
--		.. "\nNumber of stars: " .. #stars
		.."\nTime passed: " .. math.floor(time) .. " seconds", 0, 0)
	love.graphics.setColor(0, 255, 255)
	if pause then
		love.graphics.print("PAUSED", love.graphics.getWidth() - 60, love.graphics.getHeight() - 20)
	end

	love.graphics.print("ZOOM: " .. 1/scale .. "x", love.graphics.getWidth()/2, love.graphics.getHeight() - 40)
	love.graphics.print("TIME SPEED: " .. timeScale .. "x", love.graphics.getWidth()/2, love.graphics.getHeight() - 20)
end

function love.keypressed(key)
	if key == "escape" or key == "q" then
		love.event.quit()
	elseif key == "up" or key == "w" then
		if not player.active then
			player.active = true
		else
			player.active = false
		end
	elseif key == "down" or key == "s" then
		if not tracerShow then
			tracerShow = true
		else
			tracerShow = false
		end
	elseif key == "p" or key == "space" then
		if not pause then
			pause = true
		else
			pause = false
		end
	elseif key == "f" then
		local fullscreen = love.window.getFullscreen()
		if not fullscreen then
			love.window.setFullscreen(true)
		else
			love.window.setFullscreen(false)
		end
	elseif key == "z" then
		scale = 1
		planetScele = 1
		playerScale = 1
	elseif key == "x" then
		scale = 0.5
		planetScele = 0.5
		playerScale = 0.5
	elseif key == "c" then
		scale = 0.25
		planetScele = 0.25
		playerScale = 0.25
	elseif key == "v" then
		scale = 0.1
		planetScele = 0.1
		playerScale = 0.1

	elseif key == "b" then
		timeScale = 1
	elseif key == "n" then
		timeScale = 10
	elseif key == "m" then
		timeScale = 100
	elseif key == "t" then
		timeScale = 100
	end
end

