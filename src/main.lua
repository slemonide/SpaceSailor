require("conf")
require("util")
require("player")
require("tracer")

function love.load()
	math.randomseed(os.time())
    ENGINE_NOISE = love.audio.newSource("assets/engine_noise.ogg", "static")

	pause = false
	scale = 1
	playerScale = 1
	planetScele = 1

	time = 0 -- Time counter
	planets = {} -- To store planets and planetoids
	stars = {} -- Stores stars
end

function love.update(dt)
	if pause then
		return
	end

	player.handleKeys(dt)
    player.tick(dt)

    tracer.tick(player)

	time = time + dt

	-- Create stars
	local star = {}
	local createStar = true
	star.pos = {
		x = math.random(love.graphics.getWidth()),
		y = math.random(love.graphics.getHeight())
	}
	for _, otherStar in ipairs(stars) do
		if math.sqrt((otherStar.pos.x - star.pos.x)^2 + (otherStar.pos.y - star.pos.y)^2) < STAR_MIN_DISTANCE then
			createStar = false
		end
	end
	if createStar then
		star.color = {math.random(155) + 100, math.random(155) + 100, math.random(155) + 100}
		table.insert(stars, star)
	end
	-- Also delete some of the old stars
	if math.random(100) == 1 then
		table.remove(stars, math.random(#stars))
	end

	-- Create planets
	local planet = {}
	local createPlanet = true
	planet.pos = {
		x = player.global_pos.x + math.random(PLANET_GEN_DISTANCE) - PLANET_GEN_DISTANCE / 2,
		y = player.global_pos.y + math.random(PLANET_GEN_DISTANCE) - PLANET_GEN_DISTANCE / 2
	}
	for _, otherPlanet in ipairs(planets) do
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
    for _, planet in ipairs(planets) do
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
end

function love.draw()
	for _, star in ipairs(stars) do
		love.graphics.setColor(star.color)
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

	for _, planet in ipairs(planets) do
		local x, y = global_to_local(planet.pos.x, planet.pos.y, player.global_pos.x, player.global_pos.y)
		x = x * scale + player.window_pos.x
		y = y * scale + player.window_pos.y

		if x > -planet.radius and x < love.graphics.getWidth() + planet.radius
		and y > -planet.radius and y < love.graphics.getHeight() + planet.radius then
			love.graphics.setColor(planet.color)
			love.graphics.circle("fill", x, y, planet.radius * planetScele)
		end
	end

	if tracerShow then
		for _, trace in ipairs(tracer) do
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
	love.graphics.print("Position: x = " .. math.floor(player.global_pos.x)
		.. ", y = " .. math.floor(player.global_pos.y) .. "\nRotation is "
		.. math.floor(player.rotation / math.pi * 180) .. "°\n"
		.. "Velocity: x = " .. math.floor(player.velocity.x)
		.. ", y = " .. math.floor(player.velocity.y) .. "\nSpeed: "
		.. math.floor(math.sqrt(player.velocity.y^2 + player.velocity.x^2)) .. " m/s"
		.. "\nThe nearest planet is in " .. math.floor(nearestPlanetDistance)
		.. " m\nIt's radius is " .. nearestPlanet.radius .. " m"
		.."\nTime passed: " .. math.floor(time) .. " seconds", 0, 0)
	love.graphics.setColor(0, 255, 255)
	if pause then
		love.graphics.print("PAUSED", love.graphics.getWidth() - 60, love.graphics.getHeight() - 20)
	end

	love.graphics.print("ZOOM: " .. scale .. "x", love.graphics.getWidth()/2, love.graphics.getHeight() - 40)
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
	elseif key == "0" then
		scale = 1
		planetScele = 1
		playerScale = 1
	elseif key == "-" then
		scale = scale / 2
        planetScele = planetScele / 2
		playerScale = playerScale / 2
	elseif key == "=" then
		scale = scale * 2
        planetScele = planetScele * 2
		playerScale = playerScale * 2
	end
end

