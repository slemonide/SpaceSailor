-- A tracer
-- Used for tracing paths

tracer = {}
tracerRadius = 2
tracerColor = {255, 0, 0}
tracerShow = true

-- FUNCTIONS

tracer.tick = function(player)
    table.insert(tracer, {
        pos = {
            x = player.global_pos.x,
            y = player.global_pos.y
        }
    })
end