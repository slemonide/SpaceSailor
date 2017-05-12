-- A player

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

-- FUNCTIONS
player.handleKeys = function(dt)
    if love.keyboard.isDown("left", "a") then
        player.rotation = (player.rotation - player.angularSpeed * dt) % (2*math.pi)
    elseif love.keyboard.isDown("right","d") then
        player.rotation = (player.rotation + player.angularSpeed * dt) % (2*math.pi)
    end
end

player.tick = function(dt)
    if player.active then
        ENGINE_NOISE:play()
        if player.landed then -- Give it a little push
            player.global_pos.x = player.global_pos.x + player.acceleration * math.sin(player.rotation)
            player.global_pos.y = player.global_pos.y + player.acceleration * math.cos(player.rotation)
        else
            player.velocity.x = player.velocity.x + player.acceleration * dt^2 * math.sin(player.rotation) / 2
            player.velocity.y = player.velocity.y + player.acceleration * dt^2 * math.cos(player.rotation) / 2
        end
    else
        ENGINE_NOISE:stop()
    end

    player.global_pos.x = player.global_pos.x + player.velocity.x * dt
    player.global_pos.y = player.global_pos.y + player.velocity.y * dt

    player.window_pos = { -- ALWAYS at the center of the screen
        x = love.graphics.getWidth() / 2,
        y = love.graphics.getHeight() / 2
    }
end