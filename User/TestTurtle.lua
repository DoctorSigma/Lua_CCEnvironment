--local fService = require("ServicePrograms")
local geoPeriphals = peripheral.wrap("right")
local tArgs = { ... }

print("GeoSearch programm, version: 1.3.1 \n")

if (#tArgs >= 1) and (geoPeriphals ~= nil) then -- Если в правой руке есть гео-сканер и было введено хотя бы один аргумент
    local tGeoScanRes, errorMsg = geoPeriphals.scan(tonumber(tArgs[1]))
    if tGeoScanRes ~= nil then
        local vPos = vector.new(gps.locate(1)) --ищем координаты
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