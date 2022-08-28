--- ServicePrograms
--- Version: 2.1.3

local tFunctionLists = {} -- Таблица в которую будут добавлены функции, чтобы добавить напише TABLE_NAME.FUNC_NAME() возле имени функции.
local expect = require "cc.expect"
local defaultFolderName = "CCEnv/"

--TODO: сделать функцию, которая будет посылать данные в консоль, и отправлять на базу, и на КПК
--TODO: сделать функцию для ввода команд, которая запускается паралельно с основной программой И команды можна будет ввести как вручную, так и при помощи предложеных блоков, к примеру: на экране будет показыватся Список возможных ПК, далее при выборе будет показыватся команда, а дальше в зависимости от команды аргументы

--Функция драйвера настроек, которая последовательно будет исполнять команды
function tFunctionLists.fSettingsDriver() --> content(string) | nil, nil | errorMsg(string)
    local tSettingTable = {}
    local settingsList_Name = "settings.txt"

    -- Считывание предыдущих сохраненных настроек
    local fin, _ = fs.open(defaultFolderName .. settingsList_Name, "r") -- Пробуем открыть файл c настройками
    if fin ~= nil then -- если файл открылся
        local sContent = fin.readAll() -- Читаем таблицу с файла
        fin.close()
        if sContent ~= nil then -- если что-то есть в файле
            tSettingTable = textutils.unserialize(sContent) -- Пробуем десирилизировать вместимое файла
            if tSettingTable == nil then tSettingTable = {} end --если мы смогли десирилизировать данные с файла
        end
    end

    -- Последовательная обработка команд
    while true do
        local _, nRecvId, eventCommand, eventTableId, eventArgs = os.pullEvent("settings_driver_in")
        if ((eventCommand == "get")) then -- Если нужно считать данные
            if tSettingTable[eventTableId] ~= nil then -- Если есть такое поле и там есть значение
                os.queueEvent("settings_driver_out", nRecvId, tSettingTable[eventTableId], "")
            else
                os.queueEvent("settings_driver_out", nRecvId, nil, "no field")
            end
        elseif ((eventCommand == "set")) then -- Или нужно установить данные
            tSettingTable[eventTableId] = eventArgs
            local bErrorFlag = false
            local fout, _ = fs.open(defaultFolderName .. "temp" .. settingsList_Name, "w") -- Пробуем открыть файл c настройками
            if fout ~= nil then --Если файл открылся
                local seriObj = textutils.serialize(tSettingTable)
                if seriObj ~= nil then
                    fout.write(seriObj)
                    fout.close()
                    shell.run("delete", defaultFolderName .. settingsList_Name)
                    if shell.run("rename", defaultFolderName .. "temp" .. settingsList_Name, defaultFolderName .. settingsList_Name) then bErrorFlag = true end
                else
                    fout.close()
                end
            end
            os.queueEvent("settings_driver_out", nRecvId, bErrorFlag, "save error")
        elseif ((eventCommand == "stop")) then -- Или команда "стоп"
            return true, 'Command: "stop"'
        end
    end

    return false, 'Error: EoF'
end

--Функция получения указаной настройки за указаное время (по умолчанию 5 секунд)
function tFunctionLists.getSettings(sTableLabel, nDefaultTime) --> operResContent(string), errorMsg(string)
    expect.expect(1, sTableLabel, "string")
    expect.expect(2, nDefaultTime, "number", "nil")
    if nDefaultTime == nil then nDefaultTime = 5 end -- Если пользователь не указал максимальное время, то оно равно значению по умолчанию
    if nDefaultTime <= 0 then return nil, "not correct timer time" end -- Если значение для таймера неверное
    local nRequestId = os.startTimer(nDefaultTime) -- Запускаем таймер, который будет служить ID, и непосредственно таймером

    --Отдача команды и ожидание ответа
    os.queueEvent("settings_driver_in", nRequestId, "get", sTableLabel)
    while true do
        local sEventName, nEventID, sOperContent, sOperErr = os.pullEvent()
        if ((sEventName == "timer") and (nEventID == nRequestId)) then -- Если таймер уже вышел
            return nil, "Timer out (get)"
        elseif ((sEventName == "settings_driver_out") and (nEventID == nRequestId)) then -- Или мы получили ответ
            return sOperContent, sOperErr
        end
    end
    return nil, 'Error: EoF'
end

--Функция установки указаной настройки за указаное время (по умолчанию 5 секунд)
function tFunctionLists.setSettings(sTableLabel, sTableValue, nDefaultTime) --> operStatus(boolean), nil | errorMsg(string)
    expect.expect(1, sTableLabel, "string")
    expect.expect(2, sTableValue, "string")
    expect.expect(3, nDefaultTime, "number", "nil")
    if nDefaultTime == nil then nDefaultTime = 5 end -- Если пользователь не указал максимальное время, то оно равно значению по умолчанию
    if nDefaultTime <= 0 then return false, "not correct timer time" end -- Если значение для таймера неверное
    local nRequestId = os.startTimer(nDefaultTime) -- Запускаем таймер, который будет служить ID, и непосредственно таймером

    --Отдача команды и ожидание ответа
    os.queueEvent("settings_driver_in", nRequestId, "set", sTableLabel, sTableValue)
    while true do
        local sEventName, nEventID, sOperContent, sOperErr = os.pullEvent()
        if ((sEventName == "timer") and (nEventID == nRequestId)) then -- Если таймер уже вышел
            return false, "Timer out (set)"
        elseif ((sEventName == "settings_driver_out") and (nEventID == nRequestId)) then -- Или мы получили ответ
            return sOperContent, sOperErr
        end
    end
    return false, 'Error: EoF'
end

--Функция считывание данных с клавиатуры за n секунд, или возвращения значение по умолчанию
function tFunctionLists.fReadData(defaultValue) --> status(bool), errorMsg(string), content(string)
    expect.expect(1, defaultValue, "string", "nil")

    local nTimerId = os.startTimer(3)--запускаем таймер на 3 секунды и сохраняем его ИД
    while true do
        local sEventName, eventArgs = os.pullEvent()
        if ((sEventName == "timer") and (eventArgs == nTimerId) and (defaultValue ~= nil)) then -- Если таймер уже вышел и есть значение по умолчанию
            return true, "", defaultValue
        elseif ((sEventName == "char") and (eventArgs == ' ') and (defaultValue ~= nil)) then -- Или мы нажали на пробел и есть значение по умолчанию
            return true, "", defaultValue
        elseif ((sEventName == "char") and (eventArgs ~= ' ')) then -- Или ввели что-то другое
            write(">")
            return true, "", read(nil, nil, nil, eventArgs)
        end
    end
end

-- Функция получения напрвления для черепахи
function tFunctionLists.getTurtleDirection() --> status(bool), errorMsg(string), direction(vector) --No change position
	local i = 1 -- Счётчик цыкла
	local h = 0 -- Счётчик относительной высоты
	
    -- Определяем наши координаты
	local xPos, _, zPos = gps.locate(1)
	if xPos == nil then return false, "I can't find gps!!!(start)", nil end -- Если не смогли определить местоположение
    -- Пробуем двигатся вперёд
	while not turtle.forward() do -- Если черепах не смогла двинуться вперёд, то ...
		if math.fmod(i, 4) == 0 then -- Если мы пробовали пройти вперёд уже 4 раза, то ..
			i = 1 -- "обнуляем" счётчик
			if turtle.up() then -- Если мы сможем поднятся вверх, то..
				h = h + 1
			elseif turtle.down() then -- Если мы не смогли поднятся вверх, но можем вниз, то ..
				h = h - 1
			else -- Мы не смогли никуда повернутся, ошибка
				return false, "I can't move anywhere!!", nil 
			end
		else -- Если ещё не повернулись 4 раза, то ..		
			turtle.turnRight()
			i = i + 1
		end
	end
	
    -- Определям новое местоположение
	local xRel, _, zRel = gps.locate(1)
	if xRel == nil then return false, "I can't find gps!!!(final)", nil end -- Если не смогли определить местоположение
	
    -- "Обнуляем" набраную позицию
	if not turtle.back() then return false, "I can't move back!!", nil end -- Возвращаемся назад, так как двигались вперёд
	while h ~= 0 do -- Если мы двигались по вертикале, то пробуем обнулить набраную высоту
		if h < 0 then 
			if not turtle.up() then return false, "I can't move up!!", nil 
			else h = h + 1 end
		elseif h > 0 then
			if not turtle.down() then return false, "I can't move down!!", nil 
			else h = h - 1 end
		end
	end
	
    -- Возвращаем направление
	local vDir = vector.new(xRel, 0, zRel) - vector.new(xPos, 0, zPos)
	return true, "", vDir:normalize()
end

-- Функция поиска пути к определенным координатам
function tFunctionLists.goToGps()
    h=0 --набраная высота
    
    axisX,axisY=0,0                             --поворот по осям х,у
    target=string.sub(com,2,#com)               --получение точки назначения
    targetPos=textutils.unserialize(target)     --точка назначения
    print("Call to "..targetPos[1]..", "..targetPos[2]..", "..targetPos[3])
    
    x,y,z=gps.locate(1)                 --выясняем местоположение
    oldX=x oldZ=z                       --сохраняем положение
 
    while not turtle.forward() do turtle.dig() end      --двигаемся для выяснения ориентации
    os.sleep(1)
    
    x,y,z=gps.locate(1)                 --выясняем местоположение
    
    if x>oldX then axisX=1 elseif x<oldX then axisX=-1 end  --по изменении координат выясняем ориентацию
    if z>oldZ then axisZ=1 elseif z<oldZ then axisZ=-1 end
        
    startX=x startY=y startZ=z          --стартовая точка движения
    
    dx=targetPos[1]-startX      --разница в кордах
    dy=targetPos[2]-startY      --разница в кордах
    dz=targetPos[3]-startZ      --разница в кордах
    
    dx=math.floor(dx)   --округляем
    dy=math.floor(dy)   --округляем
    dz=math.floor(dz)   --округляем
    
    if dy>0 then                            --если точка выше черепахи, то
        for _ = 1, math.abs(dy) do
            while not turtle.up() do turtle.digUp() end         --двигатся вверх
        end
    elseif dy<0 then                        --иначе если точка ниже, то
        for _ = 1, math.abs(dy) do
            while not turtle.down() do turtle.digDown() end     --двигатся вниз
        end
    end
    
    if ((axisX<0) and (dx>0)) or ((axisX>0) and (dx<0)) then turtle.turnLeft() turtle.turnLeft() axisX=1 elseif         --поворачиваем в нужную сторону
            (axisZ>0) and (dx>0) then turtle.turnLeft() axisZ=0 axisX=1 elseif
                (axisZ>0) and (dx<0) then turtle.turnRight() axisZ=0 axisX=-1 elseif
                    (axisZ<0) and (dx<0) then turtle.turnLeft() axisZ=0 axisX=-1 elseif
                        (axisZ<0) and (dx>0) then turtle.turnRight() axisZ=0 axisX=1 
            
    end
 
    
    for _ =1, math.abs(dx) do                --двигаемся по оси х
        if (turtle.detect()) and not (turtle.detectUp()) and (h<10) then turtle.up() h=h+1 else     --если спереди препятсвие, сверху нет препятсвия и набранная высота<10 то поднятся вверх и h+1
        while not turtle.forward() do turtle.dig()  end end
        
    end
    
    if (axisX>0) and (dz<0) then turtle.turnLeft()  elseif  --поворачиваем в нужную сторону
            (axisX>0) and (dz>0) then turtle.turnRight() elseif
                (axisX<0) and (dz>0) then turtle.turnLeft()  elseif
                    (axisX<0) and (dz<0) then turtle.turnRight() end
    
    for _ =1,  math.abs(dz) do
        if (turtle.detect()) and not (turtle.detectUp()) and (h<10) then turtle.up() h=h+1 else
        while not turtle.forward() do turtle.dig() end end
    end 
    
    for _ =1,h do
        while not turtle.down() do turtle.digDown() end
    end
    
end


return(tFunctionLists) -- Возвращает таблицу, в которой находятся функции.