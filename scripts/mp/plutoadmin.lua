json = require "json"
commands = require "scripts.mp.plutoadmin.commands"

-- reading files
local open = io.open
local function read_file(path)
    local file = open(path, "rb")
    if not file then return nil end
    local content = file:read "*a"
    file:close()
    return content
end

util.print("Starting up plutoadmin by RektInator...")

-- read bans / settings files
local bansFile =        read_file("bans.json")
local settingsFile =    read_file("settings.json")

if bansFile ~= nil and settingsFile ~= nil then

    -- parse bans and settings
    bans = json.decode(bansFile)
    settings = json.decode(settingsFile)

    -- obtains the admin rank for the current player
    function getAdminRank(player)
    
        for admin in ipairs(settings.admins) do
            if settings.admins[admin].xuid == player:getguid() then
                return settings.admins[admin].level
            end
        end

        return 0

    end

    -- onPlayerSay function
    function onPlayerSay(args)

        local message = args.message:lower()
        local arguments = message:split(" ")

        -- check if we're handling a command
        if string.sub(arguments[1], 1, 1) == "!" then
            
            -- extract command from message
            local command = string.sub( arguments[1], 2 )

            -- check if command exists
            commandFound = false
            for cmd in ipairs(settings.commands) do
                if settings.commands[cmd].command == command then
                    commandFound = true

                    -- check if the rank for the current player is high enough to execute the command
                    if settings.commands[cmd].level <= getAdminRank(args.sender) then
                        -- execute command callback
                        commands[settings.commands[cmd].func](args.sender, arguments)
                    else
                        -- print error
                        util.print(string.format("player with guid %s tried to execute command %s.", args.sender:getguid(), command))
                        args.sender:tell("^0[^2Plutonium Admin^0]^7: Insufficient permissions.")
                    end

                end
            end

            if commandFound ~= true then
                -- print error
                args.sender:tell("^0[^2Plutonium Admin^0]^7: Invalid command \"" .. command .. "\".")
            end
    
        end
    
    end

    -- install callbacks
    callbacks.playerSay.add(onPlayerSay)

    util.print("Successfully loaded plutoadmin.")    

else

    util.print("Could not load plutoadmin, bans.json or settings.json is missing!")

end
