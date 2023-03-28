
local player_rocket = util.table.deepcopy(data.raw.projectile["rocket"])
player_rocket.name = "player_rocket"
player_rocket.acceleration = 0.025
player_rocket.height = 0.75
player_rocket.smoke = {
    {
        name = "smoke-fast",
        deviation = {1, 1},
        frequency = 2,
        position = {0, 1},
        slow_down_factor = 1,
        starting_frame = 3,
        starting_frame_deviation = 5,
        starting_frame_speed = 0,
        starting_frame_speed_deviation = 5
    },
}
data:extend{player_rocket}