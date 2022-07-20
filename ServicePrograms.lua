local tFunctionLists = {} -- Таблица в которую будут добавлены функции, чтобы добавить напише TATBLE_NAME.FUNC_NAME() возле имени функции.

function tFunctionLists.TestFunc()
    print('Test function!! Cucu')
end

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
    local vDirNormalize = vDir:normalize()
	return true, "", vDirNormalize
end

function tFunctionLists.goToGps_Recurse()
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