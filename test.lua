function botX()
    return math.floor(getBot().x/32)
end

function botY()
    return math.floor(getBot().y/32)
end

function join(world)
    sendPacket(3,"action|join_request\nname|"..world:upper())
end

function joinDoor(world, doorid)
    sendPacket(3,"action|join_request\nname|"..world:upper().."|"..doorid:upper())
end

function cekWD()
    while getTile(botX(), botY()).fg == 6 do
        if getBot().world == worldNow:upper() then
            joinDoor(worldNow, doorID)
            sleep(1000)
        end
    end
end

function checkTree()
    readyT = 0
    noreadyT = 0
    for _, tile in pairs(getTiles()) do
        if tile.fg == seedID then
            if tile.ready then
                if readyT == nil then
                    readyT = 0
                    readyT = readyT + 1
                else
                    readyT = readyT + 1
                end
            else
                if noreadyT == nil then
                    noreadyT = 0
                    noreadyT = noreadyT + 1
                else
                    noreadyT = noreadyT + 1
                end
            end
        end
    end
    return readyT, noreadyT
end

function checkReady()
    rt, nrt = checkTree()
    return rt
end

function checkNoReady()
    rt, nrt = checkTree()
    return nrt
end

function harvest()
    collectSet(true, 4)
    for _, tile in pairs(getTiles()) do
        if tile.fg == seedID and tile.ready then
            cekWD()
            if findItem(blockID) > 190 then
                collectSet(false, 4)
                break
            end
            findPath(tile.x, tile.y, 40)
            punch(0, 0)
            sleep(delayHarvest)
        end
    end
end

function plant()
    for _, tile in pairs(getTiles()) do
        if tile.fg == 0 and getTile(tile.x, tile.y+1).fg ~= 0 and getTile(tile.x, tile.y+1).fg ~= seedID then
            cekWD()
            if findItem(seedID) == 0 then
                break
            end
            findPath(tile.x, tile.y)
            place(seedID, 0, 0)
            sleep(delayPlant)
        end
    end
end

function breaks()
    collectSet(true, 2)
    while findItem(blockID) > 0 do
        if botX() == posX and botY() == posY then
            place(blockID, 0, -1)
            sleep(delayPlace)
            for i = 1, hitCount do
                punch(0, -1)
                sleep(delayBreak)
            end
        else
            findPath(posX, posY, 40)
            sleep(500)
        end
    end
    collectSet(false, 2)
end

function startFarm()
    cekWD()
    harvest()
    breaks()
    plant()
end

repeat
    for _, list in pairs(worldList) do
        worldNow = list:upper()
        while getBot().world ~= worldNow do
            join(worldNow)
            sleep(delayJoin)
        end
        while checkReady() > 0 do
            startFarm()
        end
    end
until (loopFarm == false)