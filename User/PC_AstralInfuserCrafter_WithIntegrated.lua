if not computer then
    printError("Error: requires a PC")
end

local nbtStorage = peripheral.find("nbtStorage")
local variableStore = peripheral.find("variableStore")
local tInternData = { altarCoord = { x = 0, y = 0, z = 0}, starlightCoor = {}}
local tOutData = {targetCoord = {x = 0, y = 0, z = 0}, clickWithEmpty = true, clickOnAltar = true}
local idHasItem = 0
local fHasItemFlag = false
local tArgs = { ... }

print("#Name: PC_AstralInfuserCrafter_WithIntegrated.lua# || #Version: 1.1.1#\n")

if nbtStorage ~= nil then
    if variableStore ~= nil then
        if #tArgs >= 1 then
            -- ��������� ��� ����� "Has item"
            for k, v in pairs(variableStore.list()) do
                if v.label == tArgs[1] then idHasItem = k break end
            end

            --�������� ������������
            tOutData.targetCoord = tInternData.altarCoord
            tOutData.clickWithEmpty = true
            tOutData.clickOnAltar = true
            nbtStorage.writeTable(tOutData)

            while(true) do
                --TODO: ���������� ����� �������� �� �����, ����� ���� ������� ���, � ���� ����, �� ��� ��������� �����
                local tVariableHasItem = variableStore.read(idHasItem) --������ ���� variable card "Has item"
                if not fHasItemFlag and tVariableHasItem.value == 1 then fHasItemFlag = true end -- ���� �������� �� ���� � �� ��������, �� ���������, �� ������� �
                if fHasItemFlag and tVariableHasItem.value == 0 then -- ���� ������� ���. � ���� ����
                    fHasItemFlag = false -- ���������, �� �������� ����
                    -- ������ "�����" ����� � ������
                    for _, v in pairs(tInternData.starlightCoor) do
                        tOutData.targetCoord = v
                        tOutData.clickOnAltar = false
                        tOutData.clickWithEmpty = true  --�������� ������� ������� ������ ����� ����� �����
                        nbtStorage.writeTable(tOutData)
                        sleep(0.5)
                        tOutData.clickWithEmpty = false --������� ����� �� ���� ����� ����� ������� ����
                        nbtStorage.writeTable(tOutData)
                        sleep(0.5)
                    end
                    -- ������ ����� �� ����� ������
                    tOutData.targetCoord = tInternData.altarCoord
                    tOutData.clickWithEmpty = true
                    tOutData.clickOnAltar = true
                    nbtStorage.writeTable(tOutData)
                    sleep(0.5)
                end
            end
        else print('Usage:\n - "Has item" variable name') end
    else printError("No variableStore!!!") end
else printError("No nbtStorage!!!") end
