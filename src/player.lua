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