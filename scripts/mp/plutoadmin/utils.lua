local utils = {}

local open = io.open

-- read the contents of a file
function utils.read_file(path)
    local file = open(path, "rb")
    if not file then return nil end
    local content = file:read "*a"
    file:close()
    return content
end

-- writes a buffer to disk
function utils.write_file(path, data)
    local file = open(path, "wb")
    if not file then return end
    file:write(data)
    file:close()
end

function utils.kickPlayer(player, reason)
    util.executeCommand(string.format("kickclient %i \"%s\"", player:getentitynumber(), reason))    
end

function utils.getTableSize(table)
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end

function utils.doTellInternal(player, message, showPrefix)
    if showPrefix == true then
        player:tell(
            string.format(
                "^0[^2PM^0][^7%s^0]^7: %s", settingshandler.settings.sayName, message
            )
        )
    else
        player:tell(message)
    end
end

function utils.tellInternal(player, message, showPrefix)
    if string.len(message) <= 100 then
        utils.doTellInternal(player, message, showPrefix)
    else
        -- get string from pos 100
        local splitMsg = string.sub( message, 85 )

        -- find the nearest space character
        local pos = string.find( message, " " )

        -- use apropiate split method
        if pos > 15 then
            utils.tellInternal(player, string.sub( message, 1, 85 ) .. "-", showPrefix)
            callbacks.afterDelay.add(1000, function()
                utils.tellInternal(player, string.sub( message, 86 ), false)
            end)
        else
            utils.tellInternal(player, string.sub( message, 1, 85 + pos ), showPrefix)
            callbacks.afterDelay.add(1000, function()
                utils.tellInternal(player, string.sub( message, 86 + pos ), false)                        
            end)
        end
    end
end

function utils.chatPrint(message)
    util.chatPrint(
        string.format(
            "^0[^7%s^0]^7: %s", settingshandler.settings.sayName, message
        )
    )
end

function utils.tell(player, message)
    utils.tellInternal(player, message, true)    
end

function utils.toNumber(value)
    local num = tonumber(value)

    if num == nil then
        return 0
    end

    return num
end

function utils.loadDSPLFile(dspl)

    local dsplFile = dspl
    if string.match( dspl, ".dspl" ) == false then
        dsplFile = dsplFile .. ".dspl"
    end

    -- rotate to dspl file
    gsc.setdvar("sv_mapRotation", dsplFile)
    util.executeCommand("map_rotate")

end

function utils.createDSPLFile(map, dsr)

    -- save dspl
    local dspl = string.format("%s,%s,1\n", map, dsr)
    utils.write_file("admins\\plutoadmin.dspl", dspl)

    -- load new dspl file
    utils.loadDSPLFile("plutoadmin.dspl")

end

return utils
