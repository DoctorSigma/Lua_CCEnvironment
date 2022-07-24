local fService = require("ServicePrograms")
local geoPeriphals = peripheral.wrap("right")
local tArgs = { ... }
if (#tArgs >= 2) and (geoPeriphals ~= nil) then -- Если в правой руке есть гео-сканер и было введено хотя бы один аргумент
    local tGeoScanRes = geoPeriphals.scan(tonumber(tArgs[1]))
    for _, v in pairs(tGeoScanRes) do
        if (v.name == tArgs[2]) then --если это второй аргумент, то
            textutils.pagedPrint("x: " .. v.x .. " y:" .. v.y .. " z:" .. v.z)
        end
    end
end