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
if tArgs[1] == nil then tArgs[1] = "1" end  --TODO: ������� �������, ���� ����� ����� ����� ������� ��������� �������
local nLimit = tonumber(tArgs[1])

print("#Name: TestTurtle.lua# || #Version: 1.1.2#\n")

if nLimit > 0 and nLimit <= 8 then
    if tArgs[2] == nil then tArgs[2] = "minecraft:oak_log" end --TODO: ������� �������, ���� ����� ����� ����� ������� ��������� �������
    if inputChest ~= nil then
        if outputChest ~= nil then
            -- ������� �������� ���������
            for i = 1, 16 do
                turtle.select(i)
                turtle.dropUp()
            end

            while true do
                if outputChest.size() - #outputChest.list > 2 * nLimit  then -- ���� � ���� ��� ������ ��� ����������, �� ...
                    -- ������ ������� � �������� �������
                    turtle.select(1)
                    repeat
                        if #inputChest.list() == 0 then return "InputChest is empty" end
                        turtle.suck(1) -- ������ ������� ������� � �������� �������
                        local collectItem = turtle.getItemDetail().name
                        if collectItem ~= tArgs[2] then turtle.dropUp() end -- �������� ���������� �������
                    until collectItem == tArgs[2] -- ���������� ���� �� ��������� �������� �������

                    -- �������� �����
                    turtle.craft(nLimit) -- �������� 4 * nLimit �����
                    turtle.transferTo(2, 3 * nLimit) -- ��������� �� 2 ����� 3 * nLimit ������� �����
                    turtle.transferTo(6, 1 * nLimit) -- ��������� �� 6 ����� 1* nLimit �����
                    turtle.craft(nLimit) -- �������� 4 * nLimit �����
                    turtle.transferTo(6, 2 * nLimit) -- ��������� �� 6 ����� 2 * nLimit ������� �����
                    turtle.transferTo(10, 2 * nLimit) -- ��������� �� 10 ����� ����� 2 * nLimit ������� �����
                    turtle.craft(nLimit) -- �������� 2 * nLimit ������

                    -- �������� ��������� ����
                    for i = 1, (2 * nLimit) do
                        turtle.select(i)
                        turtle.dropDown()
                    end
                end
            end
        else printError("No output chest under the turtle") end
    else printError("No input chest on front of turtle") end
else print('Usage:\n - count to craft (0 < NUM <= 8)\n - [WoodTypeTOCraft](default:"minecraft:oak_log")') end