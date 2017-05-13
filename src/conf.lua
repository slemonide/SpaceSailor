-- Configuration
VERSION = "0.1"

function love.conf(t)
	t.title = "Space Sailor " .. VERSION
	t.version = "0.10.1"
	t.window.resizable = true
end

MAX_RADIUS = 5 * 10^3
MIN_RADIUS = 20
GRAVITATIONAL_CONSTANT = 6.674 * 10^-11 * 10^6
PLANET_DENSITY_MIN = 0.1
PLANET_DENSITY_MAX = 0.3
PLANET_GEN_DISTANCE = 9 * 10^6
PLANET_MIN_DISTANCE = 6 * 10^4
MAX_SAFE_IMPACT_SPEED = 50
STAR_MIN_DISTANCE = 100