local fService = require("ServicePrograms")
local geoPeriphals = peripheral.wrap("right")
local tArgs = { ... }
if (#tArgs > 0) and (geoPeriphals ~= nil) then -- Если в правой руке есть гео-сканер и было введено хотя бы один аргумент
    local tGeoScanRes = geoPeriphals.scan(tArgs[1])
    for _, v in pairs(tGeoScanRes) do
        textutils.pagedPrint(" ["..k.."] ".."Name: "..textutils.serialize(v, {}))
    end
end