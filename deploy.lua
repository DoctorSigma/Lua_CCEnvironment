local instrList_Name = "Instructions.txt"
local settingsList_Name = "settings.txt"
local prefix = "https://raw.githubusercontent.com/"


-- Функция загрузки данных
function _GET(path) --> status(bool), errorMsg(string), content -- Читает данные с ГитХаба
    local handle = http.get(prefix .. path)
	
    if (handle == nil) or (handle.getResponseCode() ~= 200) then
        return false, '"' .. path .. '" not responding', ""
    end
	
    local content = handle.readAll()
    handle.close()
    return true, nil, content
end

-- Функция десерилизации данных
function unerelObj(pathToFile) --> status(bool), errorMsg(string), content -- Читает данные с файла и проводит десерилизацию
    if fs.exists(pathToFile) == true then -- Если есть старая папка, и файл с настройками открылся, то пробуем искать с настройками в ней
		local fin = fs.open(pathToFile, "r") -- Пробуем открыть локальный файл с инструкциями
		if fin ~= nil then -- Если файл старых локальных настроек открылся
			local unserializeObj = textutils.unserialize(fin.readAll()) -- Пробуем читать из файла с настройками
			if unserializeObj ~= nil then
				fin.close()			
				return true, "", unserializeObj 
			else 
				fin.close()
				return false, 'Cannot unserialize data into object.("'..pathToFile..'")', nil 
			end -- Ошибка: не смогли десерелизировать данные
		else return false, 'Cannot open a file("'..pathToFile..'").', nil end -- Ошибка: не смогли открыть файл
	else return false, 'Folder or file ("'..pathToFile..'") does not exists.', nil end -- Ошибка: не смогли найти файл или папку
end

-- Функция записи данных
function writeFileandObj(settingTable, curdir, repoPath, defaultFolderName) --> status(bool), errorMsg(string) -- Записывает файл настройки, файл с гибхаба, 
    if settingTable.S_pinPathGit == nil then return false, "usetProgError: cannot get file from repository." end
	print("\nReceiving user programm: ", settingTable.S_pinPathGit)
	local ok, _, userFile = _GET(repoPath .. settingTable.S_pinPathGit)
	if not ok then 
		print(" ..unexisted")
		return false, 'usetProgError: cannot get file ("'..settingTable.S_pinPathGit..'") from repository.'
	else
		if settingTable.S_pinLabel ~= os.getComputerLabel() then return false, "usetProgError: table error in key: S_pinLabel." end -- Если метка пк не совпадает
		local fout = fs.open(curdir .. defaultFolderName .. settingTable.S_pinProgramm .. ".lua", "w") -- Записываем файл программы
		if fout ~= nil then 
			fout.write(userFile)
			fout.close()
		else return false, "usetProgError: table error in key: S_pinProgramm." end

		local foutSett = fs.open(curdir .. defaultFolderName .. settingsList_Name, "w") -- Записываем в файл настроек настройки)
		foutSett.write(textutils.serialise(settingTable))
		foutSett.close()

		local foutStartup = fs.open("/startup.lua", "w") -- Записываем в файл стартапу настройки)
		foutStartup.write('shell.run("'..curdir..defaultFolderName..settingTable.S_pinProgramm..'.lua"'..settingTable.S_pinStartArgs..')')
		foutStartup.close()
	end
	
	return true, ""
end

-- Функция клонирования репозитория
function clone(repo, branch) --> status(bool), errorMsg(string) -- Клонирует данные с ГитХаба
    local curdir = shell.dir() .. "/"
	local compLabel = os.getComputerLabel()
	local userProgTable = {}
	local isUserProg = false
	local old_defaultFolderName = nil
	
    if branch == nil then -- Если в параметрах не была указана ветка, то устанавлвается значение по умолчанию, "master"
        branch = "master"
    end

-- Если в параметрах не был указан репозиторий
    if repo == nil then 
	    local fin = fs.open(curdir .. instrList_Name, "r") -- Пробуем открыть файл
        if fin ~= nil then -- Если в файлах на ПК есть файл инструкций, тоесть данная программа уже успешно выполнялась            
			_, _, r = string.find(fin.readLine(), '!Repository="(.-)"') -- Читаем первую строку, в которой должно находится имя репозитория
			_, _, b = string.find(fin.readLine(), '!Branch="(.-)"') -- Читаем следующую строку, в которой должна находится ветка
            fin.close()
            return clone(r, b)
        else -- Не удалось найти локальный файл предыдущего запуска
            print("Please specify repository in arguments")
            return false, "No repository name"
        end
    end

-- Открываем репозиторий
    local repoPath = repo .. "/" .. branch .. "/" -- Путь в репозитории
    local ok, _, instrList_File = _GET(repoPath .. instrList_Name) -- Попытка загрузить файл с инструкциями

    if not ok then -- Если не удалось загрузить инструкции
        return (print(' Repository "' .. repo .. '" does not contain the following file: ' .. instrList_Name) and false), (' Repository "' .. repo .. '" does not contain the following file: ' .. instrList_Name)
    end                               
									  
-- Подготовка к удалению старой папки с файлами
	local _, _, defaultFolderName = string.find(instrList_File, '!defaultFolderName="(.-)"') -- Чтение нового названия папки с репозитория
	if defaultFolderName == nil then -- Если файл на репозитории не содержит "default Folder Name", то завершаем
		return (print(' File "' .. instrList_Name .. '" does not contain "defaultFolderName"') and false), (' File "' .. instrList_File .. '" does not contain "defaultFolderName"')
	end
	
	defaultFolderName = (defaultFolderName .. "/") -- Добавления слеша в конец названия	
	
	local fin = fs.open(curdir .. instrList_Name, "r") -- Пробуем открыть локальный файл с инструкциями
	if fin ~= nil then -- Если файл открылся
		_, _, old_defaultFolderName = string.find(fin.readAll(), '!defaultFolderName="(.-)"') -- Чтение старого названия папки с ПК
		fin.close()
		if ((old_defaultFolderName ~= nil) and (fs.exists(old_defaultFolderName .. "/"))) then -- Если в файле есть старое название и папка существует, то ...
			old_defaultFolderName = (old_defaultFolderName .. "/")
			shell.run("rename", old_defaultFolderName, "deleteFolder_" .. old_defaultFolderName) -- Переименовываем старую папку, для последующего удаления
			old_defaultFolderName = "deleteFolder_" .. old_defaultFolderName -- Присваиваем переменной название старой переименованой папки
		else
			old_defaultFolderName = nil -- Для того чтобы когда в файле есть название папка, а самой папки не было, то чтобы программа не пыталась удалить не существующую папку
		end
	end	

-- Клонирование нужных файлов с репозитория на ПК
	for fTag, fName in string.gmatch(instrList_File, '#(.-)="(.-)"') do -- Читай с файла инструкций тэг а также название программы с её относительным путём
		if (fTag == "!") or (fTag == "Service") or (fTag == "File") then -- Если после ключевого символа "#" есть ("!" или "Service" или "File") то это служебные прогаммы и должны быть установлены везде
            print("Receiving: ", fName)
            local ok, _, content = _GET(repoPath .. fName)
            if not ok then print(" ..unexisted") else
				local instalDir = ((fTag == "!") and ("") or (defaultFolderName)) -- "Тернарный оператор", конструктция:(s = condition ? "true" : "false"), пояснение: оператор "and" возвращает первое ложное значение среди сових операндов; если оба операнда истинны, возвращается последний из них, а оператор "or" возвращает первое истинное значение среди своих операндов; если оба операнда ложны, возвращается последний из них
																				  -- Если "!", то не нужно перемещать файл в подпапку, но если "Service", то нужно переместить в папку по умолчанию
				local fout = fs.open(curdir .. instalDir .. fName, "w")
                fout.write(content)
                fout.close()
			end
		elseif fTag == "User" then -- Если после ключевого символа "#" есть ("User") то это пользовательские программы, должна быть только одна такая программа на ПК
			if not isUserProg then -- Нет установленой пользовательской программы
				local _, _, fPath = string.find(fName, "path='(.-)'") -- Узнаем путь куда устанавливать программу
				local _, _, fstartupArgs = string.find(fName, "startupArgs='(.-)'") -- Узнаем какие аргументы нужно вказывать в файлике с тартапом
				local _, _, progName = string.find(fPath, '/(.-).lua') -- Извлекаем название программы
				table.insert(userProgTable, {kProgName = progName, kPath = fPath, kStartupArgs = fstartupArgs})
				if progName == compLabel then -- Если есть приложение с таким же названием как и пк, то ..
					print("\nReceiving user programm: ", fPath)
					local ok, _, content = _GET(repoPath .. fPath)
					if not ok then print(" ..unexisted") else
						local fout = fs.open(curdir .. defaultFolderName .. progName .. ".lua", "w")
						fout.write(content)
						fout.close()
					end
					isUserProg = true -- Делаем пометку, что программу найдено
					userProgTable = {} -- Удаляем ненужную уже таблицу
				end
			end
		else -- Не верно составленый или неизвестный Тэг
			
		end
    end	
	
-- Обработка таблицы с пользовательскими программами, если нужна
	if not isUserProg then -- Если мы не нашли нужной программы	
		local unserTempPath = ((old_defaultFolderName == nil) and ("") or (old_defaultFolderName)) -- Предпологаемый путь к файлу с настройками
		local status, errMsg, tSettings = unerelObj(curdir .. unserTempPath .. settingsList_Name) -- Пробуем десерилизировать данные с файла настройки
		if status then -- Если данные серилизировались, то ...		
			local writeStatus, errMsgWrite = writeFileandObj(tSettings, curdir, repoPath, defaultFolderName) -- Запись в файлы
			if not writeStatus then -- Если при записи возникли ошибки
				print("\n  " .. errMsgWrite .. " So select the program from the list below (enter number of programm):\n")
				for k, v in pairs(userProgTable) do textutils.pagedPrint(" ["..k.."] ".."Name: "..v.kProgName) end -- Подобно "print()", но если нету места на дисплее, то оно позволит вам увидеть весь список
				
				local inputValue = -1
				repeat -- Цыкли с после-условием для проверки введеного значения
					write("\n> ")
					inputValue = tonumber(read())
					if inputValue > #userProgTable then print("Too big value, please enter again: ") end
				until inputValue <= #userProgTable
				
				tSettings.S_pinProgramm = userProgTable[inputValue].kProgName
				tSettings.S_pinPathGit = userProgTable[inputValue].kPath
				tSettings.S_pinStartArgs = userProgTable[inputValue].kStartupArgs
				tSettings.S_pinLabel = compLabel				
				
				writeStatus, errMsgWrite = writeFileandObj(tSettings, curdir, repoPath, defaultFolderName) -- Запись в файлы
				if not writeStatus then print(errMsgWrite)
				else 
					print('\nProgramm "'..tSettings.S_pinProgramm..'" was connected to "'..tSettings.S_pinLabel..'" label.')
				end
			end
		else -- Если нет, то делаем новый настроечный файл
			print("\n--" .. errMsg .. " So select the program you'd like to pin to this PC from the list below (enter number of programm):\n")
			for k, v in pairs(userProgTable) do textutils.pagedPrint(" ["..k.."] ".."Name: "..v.kProgName) end -- Подобно "print()", но если нету места на дисплее, то оно позволит вам увидеть весь список
			
			local inputValue = -1
			repeat -- Цыкли с после-условием для проверки введеного значения
				write("\n> ")
				inputValue = tonumber(read())
				if inputValue > #userProgTable then print("Too big value, please enter again: ") end
			until inputValue <= #userProgTable
			
			local content = {S_pinProgramm = userProgTable[inputValue].kProgName, S_pinPathGit = userProgTable[inputValue].kPath, S_pinStartArgs = userProgTable[inputValue].kStartupArgs, S_pinLabel = compLabel} -- Новая таблица с данными, S - значить сервисные данные

			local writeStatus, errMsgWrite = writeFileandObj(content, curdir, repoPath, defaultFolderName) -- Запись в файлы
			if not writeStatus then print(errMsgWrite)
			else 
				print('\nProgramm "'..content.S_pinProgramm..'" was connected to "'..content.S_pinLabel..'" label.')
			end
		end
	end	
	
-- Удаление старой папки
	if old_defaultFolderName ~= nil then shell.run("delete", old_defaultFolderName) end -- Удаляем старую папку, если она существовала
	return true, ""
end


-- Непосредственный запуск "распаковки" среды с ГитХаба
local args = {...}
clone(args[1])