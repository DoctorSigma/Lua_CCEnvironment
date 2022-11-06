local nbtStorage = peripheral.find("nbtStorage")
local variableStore = peripheral.find("variableStore")
local tInternData = { altarCoord = {x = -95, y = 70, z = -457}, starlightCoor = {
    {M = {x = -95, y = 69, z = -459}, L = {x = -94, y = 69, z = -459}, R = {x = -96, y = 69, z = -459}},
    {M = {x = -97, y = 69, z = -457}, L = {x = -97, y = 69, z = -458}, R = {x = -97, y = 69, z = -456}},
    {M = {x = -95, y = 69, z = -455}, L = {x = -94, y = 69, z = -455}, R = {x = -96, y = 69, z = -455}},
    {M = {x = -93, y = 69, z = -457}, L = {x = -93, y = 69, z = -458}, R = {x = -93, y = 69, z = -456}} }}
local tOutData = {targetCoordM = {x = 0, y = 0, z = 0}, targetCoordL = {x = 0, y = 0, z = 0}, targetCoordR = {x = 0, y = 0, z = 0}, isSuckLiquid = true, clickWithItemToCraft = true}
local idHasItem = 0
local fHasItemFlag = false
local tArgs = { ... }

print("#Name: PC_AstralInfuserCrafter_WithIntegrated.lua# || #Version: 1.2.2#\n")

if nbtStorage ~= nil then
    if variableStore ~= nil then
        if tArgs[1] == nil then tArgs[1] = "hasItem" end --TODO: забрати костиль, який виник через стару систему аргументів запуску
        if #tArgs >= 1 then
            -- Знаходимо айді змінної "Has item"
            for k, v in pairs(variableStore.list()) do
                if v.label == tArgs[1] then idHasItem = k break end
            end

            --Початкові налаштування
            tOutData.targetCoordM = tInternData.altarCoord
            tOutData.targetCoordL = tInternData.altarCoord
            tOutData.targetCoordR = tInternData.altarCoord
            tOutData.isSuckLiquid = true
            tOutData.clickWithItemToCraft = true -- Клікаємо предметом для крафту
            nbtStorage.writeTable(tOutData)
            sleep(0.5)
            tOutData.clickWithItemToCraft = false -- Вимикаємо клік
            nbtStorage.writeTable(tOutData)

            while(true) do
                --TODO: Опрацювати крафт предмету на алтарі, тобто якщо предмет був, а потім зник, то тоді запустити обхід
                local tVariableHasItem = variableStore.read(idHasItem) --Читаємо вміст variable card "Has item"
                if not fHasItemFlag and tVariableHasItem.value == 1 then fHasItemFlag = true end -- Якщо предмету не було і він появився, то позначаємо, що предмет є
                if fHasItemFlag and tVariableHasItem.value == 0 then -- Якщо предмет був. а потім зник
                    fHasItemFlag = false -- Позначаємо, що предмета нема
                    -- Робимо "обхід" точок з світлом
                    for _, v in pairs(tInternData.starlightCoor) do
                        tOutData.targetCoordM = v.M
                        tOutData.targetCoordL = v.L
                        tOutData.targetCoordR = v.R
                        tOutData.clickWithItemToCraft = false
                        tOutData.isSuckLiquid = true  --Спочатку пробуємо забрати звідти рідину
                        nbtStorage.writeTable(tOutData)
                        sleep(2.0)
                        tOutData.isSuckLiquid = false --Ставимо рідину на місце тепер точно пустого місця
                        nbtStorage.writeTable(tOutData)
                        sleep(0.5)
                    end
                    -- Робимо йдемо на точку алтаря
                    tOutData.targetCoordM = tInternData.altarCoord
                    tOutData.targetCoordL = tInternData.altarCoord
                    tOutData.targetCoordR = tInternData.altarCoord
                    tOutData.isSuckLiquid = true
                    tOutData.clickWithItemToCraft = true -- Клікаємо предметом для крафту
                    nbtStorage.writeTable(tOutData)
                    sleep(0.5)
                    tOutData.clickWithItemToCraft = false -- Вимикаємо клік
                    nbtStorage.writeTable(tOutData)
                end
            end
        else print('Usage:\n - "Has item" variable name') end
    else printError("No variableStore!!!") end
else printError("No nbtStorage!!!") end
