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

print("#Version: 1.2.5# || #Name: TestTurtle.lua#\n")

print("Craft count at once: " .. tostring(nLimit))
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
                local outChestCount = 0
                outChestCount = 0
                for _, _ in pairs(outputChest.list()) do outChestCount = outChestCount + 1 end
                if (outputChest.size() - outChestCount >= 2 * nLimit) then -- ���� � ���� ��� ������ ��� ����������, �� ...
                    -- ������ ������� � �������� �������
                    turtle.select(1)
                    local itemToCraft = 0
                    repeat
                        nLimit = 1 --TODO: ������� �������� ���������� �-�� �������� ���������� ������
                        local isEmpty = 0
                        for _, _ in pairs(inputChest.list()) do isEmpty = isEmpty + 1 end -- ����������� �� ������� � ������� � �������� ������� � ������ �� �-���
                        if isEmpty == 0 then -- ���� �������� ��� ����
                            if itemToCraft > 0 then nLimit = itemToCraft print("\nCraft count at now: " .. tostring(itemToCraft)) -- ���� �� ����� ���� ��������, �� ����������� ��
                            else print("InputChest is empty") return "InputChest is empty" end -- ������ ��������� ��������
                        end
                        turtle.suck(1) -- ������ ������� ������� � �������� �������
                        itemToCraft = itemToCraft + 1
                        local collectItem = turtle.getItemDetail().name
                        if collectItem ~= tArgs[2] then turtle.dropUp() itemToCraft = itemToCraft - 1 end -- �������� ���������� �������
                    until collectItem == tArgs[2] and itemToCraft >= nLimit  -- ���������� ���� �� ��������� �������� ������� � �� �� ������� ��������� �-��� ��������

                    -- �������� �����
                    turtle.craft(nLimit) -- �������� 4 * nLimit �����
                    turtle.transferTo(2, 3 * nLimit) -- ��������� �� 2 ����� 3 * nLimit ������� �����
                    turtle.transferTo(6, 1 * nLimit) -- ��������� �� 6 ����� 1* nLimit �����
                    turtle.craft(nLimit) -- �������� 4 * nLimit �����
                    turtle.transferTo(6, 2 * nLimit) -- ��������� �� 6 ����� 2 * nLimit ������� �����
                    turtle.transferTo(10, 2 * nLimit) -- ��������� �� 10 ����� ����� 2 * nLimit ������� �����
                    turtle.craft(2 * nLimit) -- �������� 2 * nLimit ������

                    -- �������� ��������� ����
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