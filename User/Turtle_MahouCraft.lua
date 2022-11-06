if not turtle then
    printError("Requires a Turtle")
    return
end

if not turtle.craft then
    print("Requires a Crafty Turtle")
    return
end


local inputChest = peripheral.wrap("front")
local outputChest = peripheral.wrap("bottom")
local tArgs = { ... }
if tArgs[1] == nil then tArgs[1] = "1" end  --TODO: забрати костиль, який виник через стару систему аргументів запуску
local nLimit = tonumber(tArgs[1])

print("#Name: TestTurtle.lua# || #Version: 1.1.2#\n")

if nLimit > 0 and nLimit <= 8 then
    if tArgs[2] == nil then tArgs[2] = "minecraft:oak_log" end --TODO: забрати костиль, який виник через стару систему аргументів запуску
    if inputChest ~= nil then
        if outputChest ~= nil then
            -- Чистимо інвентар черепашки
            for i = 1, 16 do
                turtle.select(i)
                turtle.dropUp()
            end

            while true do
                if outputChest.size() - #outputChest.list > 2 * nLimit  then -- Якщо є місце для крафту всіх компоненітв, то ...
                    -- Беремо предмет з вхідного сундука
                    turtle.select(1)
                    repeat
                        if #inputChest.list() == 0 then return "InputChest is empty" end
                        turtle.suck(1) -- Беремо вхідний матеріал з вхідного сундука
                        local collectItem = turtle.getItemDetail().name
                        if collectItem ~= tArgs[2] then turtle.dropUp() end -- Викидаємо непотрібний предмет
                    until collectItem == tArgs[2] -- Повторюємо поки не витягнемо потрібний предмет

                    -- Починаємо крафт
                    turtle.craft(nLimit) -- Крафтимо 4 * nLimit дошки
                    turtle.transferTo(2, 3 * nLimit) -- Переміщаємо до 2 слота 3 * nLimit отримані дошки
                    turtle.transferTo(6, 1 * nLimit) -- Переміщаємо до 6 слота 1* nLimit дошку
                    turtle.craft(nLimit) -- Крафтимо 4 * nLimit палки
                    turtle.transferTo(6, 2 * nLimit) -- Переміщаємо до 6 слота 2 * nLimit отримані палки
                    turtle.transferTo(10, 2 * nLimit) -- Переміщаємо до 10 слота решту 2 * nLimit отримані палки
                    turtle.craft(nLimit) -- Крафтимо 2 * nLimit лопати

                    -- Викидаємо результат вниз
                    for i = 1, (2 * nLimit) do
                        turtle.select(i)
                        turtle.dropDown()
                    end
                end
            end
        else printError("No output chest under the turtle") end
    else printError("No input chest on front of turtle") end
else print('Usage:\n - count to craft (0 < NUM <= 8)\n - [WoodTypeTOCraft](default:"minecraft:oak_log")') end