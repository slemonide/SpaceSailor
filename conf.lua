-- Configuration
VERSION = "0.1"

function love.conf(t)
	t.title = "Space Sailor " .. VERSION
	t.version = "0.10.1"
	t.window.resizable = true
end

MAX_RADIUS = 3 * 10^2
MIN_RADIUS = 20
GRAVITATIONAL_CONSTANT = 6.674 * 10^-11 * 10^9
PLANET_DENSITY_MIN = 0.8
PLANET_DENSITY_MAX = 3
PLANET_GEN_DISTANCE = 2 * 10^4
PLANET_MIN_DISTANCE = 4 * 10^3
MAX_SAFE_IMPACT_SPEED = 50
STAR_MIN_DISTANCE = 50