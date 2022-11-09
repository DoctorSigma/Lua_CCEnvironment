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

print("#Version: 1.2.5# || #Name: TestTurtle.lua#\n")

print("Craft count at once: " .. tostring(nLimit))
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
                local outChestCount = 0
                outChestCount = 0
                for _, _ in pairs(outputChest.list()) do outChestCount = outChestCount + 1 end
                if (outputChest.size() - outChestCount >= 2 * nLimit) then -- Якщо є місце для крафту всіх компонентів, то ...
                    -- Беремо предмет з вхідного сундука
                    turtle.select(1)
                    local itemToCraft = 0
                    repeat
                        nLimit = 1 --TODO: Вирішити проблему збільшенням к-сті можливих одночасних крафтів
                        local isEmpty = 0
                        for _, _ in pairs(inputChest.list()) do isEmpty = isEmpty + 1 end -- Проходимось по таблиці з данними з вхідного сундука і рахуємо їх к-сть
                        if isEmpty == 0 then -- якщо предметів уже немає
                            if itemToCraft > 0 then nLimit = itemToCraft print("\nCraft count at now: " .. tostring(itemToCraft)) -- якщо ми взяли якісь предмети, то використаємо їх
                            else print("InputChest is empty") return "InputChest is empty" end -- інакше завершуємо програму
                        end
                        turtle.suck(1) -- Беремо вхідний матеріал з вхідного сундука
                        itemToCraft = itemToCraft + 1
                        local collectItem = turtle.getItemDetail().name
                        if collectItem ~= tArgs[2] then turtle.dropUp() itemToCraft = itemToCraft - 1 end -- Викидаємо непотрібний предмет
                    until collectItem == tArgs[2] and itemToCraft >= nLimit  -- Повторюємо поки не витягнемо потрібний предмет і ми не візьмемо необхідну к-сть матеріалу

                    -- Починаємо крафт
                    turtle.craft(nLimit) -- Крафтимо 4 * nLimit дошки
                    turtle.transferTo(2, 3 * nLimit) -- Переміщаємо до 2 слота 3 * nLimit отримані дошки
                    turtle.transferTo(6, 1 * nLimit) -- Переміщаємо до 6 слота 1* nLimit дошку
                    turtle.craft(nLimit) -- Крафтимо 4 * nLimit палки
                    turtle.transferTo(6, 2 * nLimit) -- Переміщаємо до 6 слота 2 * nLimit отримані палки
                    turtle.transferTo(10, 2 * nLimit) -- Переміщаємо до 10 слота решту 2 * nLimit отримані палки
                    turtle.craft(2 * nLimit) -- Крафтимо 2 * nLimit лопати

                    -- Викидаємо результат вниз
                    for i = 1, (2 * nLimit) do
                        turtle.select(i)
                        turtle.dropDown()
                    end
                    turtle.select(1)
                end
            end
        else printError("No output chest under the turtle") end
    else printError("No input chest on front of turtle") end
else print('Usage:\n - count to craft (0 < NUM <= 8)\n - [WoodTypeTOCraft](default:"minecraft:oak_log")') end