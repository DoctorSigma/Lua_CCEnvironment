if not turtle then
    printError("Error: requires a Turtle")
end

--local fService = require("ServicePrograms")
local geoPeriphals = peripheral.wrap("right")
local tArgs = { ... }

print("GeoSearch programm, version: 1.4 \n")

if (#tArgs >= 1) and (geoPeriphals ~= nil) then -- Если в правой руке есть гео-сканер и было введено хотя бы один аргумент
    local tGeoScanRes, errorMsg = geoPeriphals.scan(tonumber(tArgs[1]))
    if tGeoScanRes ~= nil then

        local vPos
        if true then -- Просто отделили блоком
            local xPos, yPos, zPos = gps.locate(1) --ищем координаты
            if(xPos == nil) then -- Если нету GPS
                print("GPS not found! Enter position manually:")
                write("x:")
                xPos = tonumber(read())
                write("y:")
                yPos = tonumber(read())
                write("z:")
                zPos = tonumber(read())
                print("")
            end
            vPos = vector.new(xPos, yPos, zPos)
        end

        if tArgs[2] == nil then tArgs[2] = "minecraft:ancient_debris" end
        for _, v in pairs(tGeoScanRes) do
            if (v.name == tArgs[2]) then --если это второй аргумент, то
                textutils.pagedPrint("x:" .. (v.x + vPos.x) .. " y:" .. (v.y + vPos.y) .. " z:" .. (v.z + vPos.z))
            end
        end
    else
        print(errorMsg)
    end
end