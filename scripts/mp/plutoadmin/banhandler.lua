local banhandler = {  }

local bansFile = utils.read_file("bans.json")

if bansFile == nil or string.len( bansFile ) == 0 then
    util.print("Error: bans.json is empty!")
else
    -- expose bans
    banhandler.bans = json.decode(bansFile)
end

function banhandler.flushFile()
    -- create json file
    banJson = json.encode(banhandler.bans)
    
    -- save contents to disk
    utils.write_file("bans.json", banJson)
end

function banhandler.banPlayer(admin, player, reason, time)

    if adminhandler.getAdminRank(admin) <= adminhandler.getAdminRank(player) then
        utils.tell(admin, "You cannot ban players with the same or higher admin level than you.")
        return
    end

    banEntry = {}
    banEntry["name"] = player.name
    banEntry["reason"] = reason
    banEntry["xuid"] = player:getguid()
    banEntry["admin"] = admin:getguid()

    if time ~= nil then
        banEntry["expires"] = os.time(os.date("!*t")) + time
    end

    -- init bans table if it does not exist yet
    if banhandler.bans.bans == nil then
        banhandler.bans.bans = {}
    end

    table.insert(banhandler.bans.bans, banEntry)

    -- flush file
    banhandler.flushFile()

    -- kick player
    utils.kickPlayer(player, reason)

end

function banhandler.isBanExpired(ban, index)

    local curTime = os.time(os.date("!*t"))

    if ban.expires == nil then
        return false
    end

    if ban.expires - curTime > 0 then
        return false
    end

    -- remove ban entry
    table.remove(banhandler.bans.bans, index)

    -- flush bans file
    banhandler.flushFile()

    return true

end

function banhandler.isPlayerBanned(player)

    for ban in ipairs(banhandler.bans.bans) do
        if player:getguid() == banhandler.bans.bans[ban].xuid then
            if banhandler.isBanExpired(banhandler.bans.bans[ban], ban) then
                return false
            end

            return true
        end

        if player.name == banhandler.bans.bans[ban].name then
            if banhandler.isBanExpired(banhandler.bans.bans[ban], ban) then
                return false
            end

            return true
        end
    end

    return false

end

return banhandler
