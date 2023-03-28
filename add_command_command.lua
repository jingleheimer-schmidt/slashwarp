local function add_commands()
    commands.add_command("add_command","Usage: /add_command <name> <function>",function(command)
        if not command.parameter then return end
        local name, func_str = string.match(command.parameter, "^(%S+)%s+(.+)$")
        if not name or not func_str then
            game.print("Usage: /add_command <name> <function>")
            return
        end
        local func, err = load(func_str, name, "t")
        if not func then
            game.print("Error compiling function: " .. err)
            return
        end
        if not global.commands then global.commands = {} end
        if global.commands[name] or commands.commands[name] or commands.game_commands[name] then game.print("A script command already exists with the name: " .. name) return end
        commands.add_command(name, "", function(event)
            func(event)
        end)
        global.commands[name] = func_str
        game.print("Added command: " .. name)
    end)
    if global.commands then
        for name, func_str in pairs(global.commands) do
            local func, err = load(func_str, name, "t")
            if not func then
                break
            end
            commands.add_command(name, "", function(event)
                func(event)
            end)
        end
    end
end

script.on_init(function()
    add_commands()
end)

script.on_load(function()
    add_commands()
end)