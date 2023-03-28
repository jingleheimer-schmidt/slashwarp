
---begin the warping process
---@param command CustomCommandData
local function initiate_warp(command)
    local player_index = command.player_index
    if not player_index then
        game.print("/warp can only be used by players with the character controller type")
        return
    end
    local player = game.get_player(player_index)
    if not player then
        game.print("/warp can only be used by players with the character controller type")
        return
    end
    if not (player.controller_type == defines.controllers.character) then
        player.print("warp failed: /warp can only be used by players with the character controller. create or return to your character and try again")
        return
    end
    local warp_location_name = command.parameter
    if not warp_location_name then
        player.print("missing warp location name. usage: \"/warp <location name>\"")
        return
    end
    if not (global.warp_locations and global.warp_locations[warp_location_name]) then
        player.print("warp location [ " .. warp_location_name .. " ] does not exist. create a warp location using: \"/setwarp <location name>\"")
        return
    end
    local warp_location = global.warp_locations[warp_location_name]
    if not (player.surface.name == warp_location.surface) then
        player.print("warp failed: character must be on the same surface as the warp location")
        return
    end
    local validated_position = player.surface.find_non_colliding_position("character", {warp_location.x, warp_location.y}, 2, 0.125)
    if not validated_position then
        player.print("warp failed: obstruction detected at [ " .. warp_location_name .. " ] [gps=" .. warp_location.x .. "," .. warp_location.y .. "," .. warp_location.surface .. "]")
        return
    end
    local player_rocket = player.surface.create_entity{
        name = "player_rocket",
        position = player.position,
        target = validated_position,
        speed = 0.005,
        max_range = 9000000,
        direction = defines.direction.east,
    }
    if not player_rocket then
        player.print("warp failed: unable to transform player into rocket. please make a mod portal discussion post including a list of your active mods")
        return
    end
    global.entity_destroyed_registrations = global.entity_destroyed_registrations or {}
    global.entity_destroyed_registrations[script.register_on_entity_destroyed(player_rocket)] = player_index
    for i = 1, 10 do
        player.surface.create_trivial_smoke({name = "train-smoke", position = player.position}) 
    end
    player.teleport(validated_position, player.surface)
    for i = 1, 10 do
        player.surface.create_trivial_smoke({name = "train-smoke", position = player.position}) 
    end
    local transfer_alt_mode = player.game_view_settings.show_entity_info
    player.set_controller{
        type = defines.controllers.cutscene,
        waypoints = {
            {
                target = player_rocket,
                transition_time = 0,
                time_to_wait = 60 * 60 * 60,
            }
        },
    }
    player.game_view_settings.show_entity_info = transfer_alt_mode
end

---save a new warp location to global
---@param command CustomCommandData
local function create_warp_location(command)
    local player_index = command.player_index
    local warp_location_name = command.parameter
    if not player_index then
        game.print("/setwarp can only be used by players with the character controller type")
        return
    end
    local player = game.get_player(player_index)
    if not player then
        game.print("/setwarp can only be used by players with the character controller type")
        return
    end
    if not (player.controller_type == defines.controllers.character) then
        player.print("creation failed: /setwarp can only be used by players with the character controller. create or return to your character and try again")
        return
    end
    if not warp_location_name then
        player.print("missing warp location name. usage: \"/setwarp <location name>\"")
        return
    end
    global.warp_locations = global.warp_locations or {}
    local chat_color = player.chat_color.r .. "," .. player.chat_color.g .. "," .. player.chat_color.b .. "," .. player.chat_color.a
    local x = math.floor(player.position.x)
    local y = math.floor(player.position.y)
    local surface = player.surface.name
    local warp_location = {
        x = x,
        y = y,
        surface = surface
    }
    if not global.warp_locations[warp_location_name] then
        global.warp_locations[warp_location_name] = warp_location
        game.print("[color=" .. chat_color .. "]" .. player.name .. " [/color] created warp [ " .. warp_location_name .. " ] [gps=" .. x .. "," .. y .. "," .. surface .. "]")
    else
        global.warp_locations[warp_location_name] = warp_location
        game.print("[color=" .. chat_color .. "]" .. player.name .. " [/color] modified warp [ " .. warp_location_name .. " ] [gps=" .. x .. "," .. y .. "," .. surface .. "]")
    end
end

---print a list of warp locations to chat
---@param command CustomCommandData
local function list_warps(command)
    if not command.player_index then
        game.print("/listwarps can only be used by a player")
        return
    end
    local player = game.get_player(command.player_index)
    if not player then
        game.print("/listwarps can only be used by a player")
        return
    end
    if not global.warp_locations then
        player.print("no warp locations saved. created a warp location using \"/setwarp <location name>\"")
        return
    end
    player.print("~~~~~~ [ saved warp locations ] ~~~~~~")
    for warp_location_name, warp_location in pairs(global.warp_locations) do
        player.print("[ " .. warp_location_name .. " ] [gps=" .. warp_location.x .. "," .. warp_location.y .. "," .. warp_location.surface .. "]")
    end
end

---remove a given warp location from the saved locations
---@param command CustomCommandData
local function remove_warp(command)
    if not command.player_index then
        game.print("/removewarp can only be used by a player")
        return
    end
    local player = game.get_player(command.player_index)
    if not player then
        game.print("/removewarp can only be used by a player")
        return
    end
    local warp_location_name = command.parameter
    if not warp_location_name then
        player.print("removal failed: missing location name. usage: /removewarp <location name>")
        return
    end
    if not (global.warp_locations and global.warp_locations[warp_location_name]) then
        game.print("removal failed: no saved warp locations with name [ " .. warp_location_name .. " ]. see all warp locations with \"/listwarps\"")
        return
    end
    local warp_location = global.warp_locations[warp_location_name]
    local chat_color = player.chat_color.r .. "," .. player.chat_color.g .. "," .. player.chat_color.b .. "," .. player.chat_color.a
    game.print("[color=" .. chat_color .. "]" .. player.name .. " [/color] removed warp [ " .. warp_location_name .. " ] [gps=" .. warp_location.x .. "," .. warp_location.y .. "," .. warp_location.surface .. "]")
    global.warp_locations[warp_location_name] = nil
end

local function add_commands()
    commands.add_command("warp", "- transform into a rocket and launch yourself towards a saved waypoint. usage: /warp <location name>", initiate_warp)
    commands.add_command("setwarp","- save the player's current location as a waypoint. usage: /setwarp <location name>", create_warp_location)
    commands.add_command("listwarps","- prints a list of saved waypoints in chat. usage: /listwarps", list_warps)
    commands.add_command("removewarp", "- removed a saved warp location. usage: /removewarp <location name>", remove_warp)
end

script.on_init(function()
    add_commands()
end)

script.on_load(function()
    add_commands()
end)

script.on_event(defines.events.on_entity_destroyed, function(event)
    if not global.entity_destroyed_registrations then return end
    if global.entity_destroyed_registrations[event.registration_number] then
        local player = game.get_player(global.entity_destroyed_registrations[event.registration_number])
        if not player then return end
        if not (player.controller_type == defines.controllers.cutscene) then return end
        player.exit_cutscene()
    end
    global.entity_destroyed_registrations[event.registration_number] = nil
end)
