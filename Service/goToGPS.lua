function goToGps_Recurse()
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
        for i=1,math.abs(dy) do 
            while not turtle.up() do turtle.digUp() end         --двигатся вверх
        end
    elseif dy<0 then                        --иначе если точка ниже, то
        for i=1,math.abs(dy) do
            while not turtle.down() do turtle.digDown() end     --двигатся вниз
        end
    end
    
    if ((axisX<0) and (dx>0)) or ((axisX>0) and (dx<0)) then turtle.turnLeft() turtle.turnLeft() axisX=1 elseif         --поворачиваем в нужную сторону
            (axisZ>0) and (dx>0) then turtle.turnLeft() axisZ=0 axisX=1 elseif
                (axisZ>0) and (dx<0) then turtle.turnRight() axisZ=0 axisX=-1 elseif
                    (axisZ<0) and (dx<0) then turtle.turnLeft() axisZ=0 axisX=-1 elseif
                        (axisZ<0) and (dx>0) then turtle.turnRight() axisZ=0 axisX=1 
            
    end
 
    
    for n=1, math.abs(dx) do                --двигаемся по оси х
        if (turtle.detect()) and not (turtle.detectUp()) and (h<10) then turtle.up() h=h+1 else     --если спереди препятсвие, сверху нет препятсвия и набранная высота<10 то поднятся вверх и h+1
        while not turtle.forward() do turtle.dig()  end end
        
    end
    
    if (axisX>0) and (dz<0) then turtle.turnLeft()  elseif  --поворачиваем в нужную сторону
            (axisX>0) and (dz>0) then turtle.turnRight() elseif
                (axisX<0) and (dz>0) then turtle.turnLeft()  elseif
                    (axisX<0) and (dz<0) then turtle.turnRight() end
    
    for n=1,  math.abs(dz) do
        if (turtle.detect()) and not (turtle.detectUp()) and (h<10) then turtle.up() h=h+1 else
        while not turtle.forward() do turtle.dig() end end
    end 
    
    for n=1,h do
        while not turtle.down() do turtle.digDown() end
    end
    
end