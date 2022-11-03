if not turtle then
    printError("Error: requires a Turtle")
end

local fService = require("ServicePrograms")
local geoPeriphals = peripheral.wrap("right")
local tArgs = { ... }

print("#Name: Turtle_GeoFinder.lua# || #Version: 2.2.3#\n")

if (#tArgs >= 1) and (geoPeriphals ~= nil) then -- Если в правой руке есть гео-сканер и было введено хотя бы один аргумент
    local tGeoScanRes, errMsg = geoPeriphals.scan(tonumber(tArgs[1]))

    if tGeoScanRes ~= nil then --Якщо скан пройшов успішно, то
        turtle.select(16) -- Вибираємо слот 16, де повинна лежати кирка
        if turtle.getItemDetail(16)["name"] == "minecraft:diamond_pickaxe" and turtle.equipRight() then -- Якщо в 16 слоті лежить кірка і ми змогли її "одіти", то ...
            local vPos
            local vDir

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

            vDir = fService.getTurtleDirection(true) -- Дізнаємось, куди ми повернуті
            local vInitDire = vDir -- Зберігаємо, куди ми були повернуті минулого разу

            if tArgs[2] == nil then tArgs[2] = "minecraft:ancient_debris" end
            for _, v in pairs(tGeoScanRes) do
                if (v.name == tArgs[2]) then --если это второй аргумент, то
                    local dest = vector.new(v.x, v.y, v.z)
                    print("x:" .. (v.x + vPos.x) .. " y:" .. (v.y + vPos.y) .. " z:" .. (v.z + vPos.z) .. "[GOTO: " .. dest:tostring() .."]")
                    vDir = fService.goToGPS(dest, vDir, true, function(vTDir) turtle.digUp() return vTDir end)
                end
            end

            vDir = fService.goToGPS(vPos - vInitDire, vDir, true, function(vTDir) turtle.digUp() return vTDir end) -- Повертаємось перед початковою позицією, щоб зберегти минулий напрямок руху. Також вказуємо функцію, яка після приходу на будь-яку точку, зкопає верхній блок, щоб ми могли пройти
            vDir = fService.goToGPS(vPos, vDir, true) -- Повертаємось на початкову позицію
            turtle.select(16)
            turtle.equipRight()
        else
            printError("ERROR: No diamond pickaxe on 16 slot!!!")
        end
    else
        printError(errMsg)
    end
elseif (tArgs[1] == nil) then printError("Enter scan radius (0<R<=16)!!!")
elseif (geoPeriphals == nil) then printError("No GeoScanner in right hand")
end