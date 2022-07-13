local instrList_Name = "Instructions.txt"
local settingsList_Name = "settings.txt"
local prefix = "https://raw.githubusercontent.com/"
local userProgTable = {}


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

-- Функция клонирования репозитория
function clone(repo, branch) --> status(bool), errorMsg(string) -- Клонирует данные с ГитХаба
    local curdir = shell.dir() .. "/"
	local compLabel = os.getComputerLabel()
	local old_defaultFolderName = nil
	local defaultFolderName = nil
	
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
	_, _, defaultFolderName = string.find(instrList_File, '!defaultFolderName="(.-)"') -- Чтение нового названия папки с репозитория
	print(defaultFolderName)
	if defaultFolderName == nil then -- Если файл на репозитории не содержит "default Folder Name", то завершаем
		return (print(' File "' .. instrList_Name .. '" does not contain "defaultFolderName"') and false), (' File "' .. instrList_File .. '" does not contain "defaultFolderName"')
	end
	
	defaultFolderName = (defaultFolderName .. "/") -- Добавления слеша в конец названия	
	
	local fin = fs.open(curdir .. instrList_Name, "r") -- Пробуем открыть локальный файл с инструкциями
	if fin ~= nil then -- Если файл открылся
		_, _, old_defaultFolderName = string.find(fin.readAll(), '!defaultFolderName="(.-)"') -- Чтение старого названия папки с ПК
		fin.close()
		if old_defaultFolderName ~= nil then -- Если в файле есть старое название, то ...
			old_defaultFolderName = (old_defaultFolderName .. "/")
			shell.run("rename", old_defaultFolderName, "deleteFolder_" .. defaultFolderName) -- Переименовываем старую папку, для последующего удаления
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
			local _, _, fPath = string.find(fName, "path='(.-)'") -- Узнаем путь куда устанавливать программу
			local _, _, fstartupArgs = string.find(fName, "startupArgs='(.-)'") -- Узнаем какие аргументы нужно вказывать в файлике с тартапом
			table.insert(userProgTable, {kPath = fPath, kStartupArgs = fstartupArgs})
		else -- Не верно составленый или неизвестный Тэг
			
		end
    end	
	
-- Обработка таблицы с пользовательскими программами
	local temp_k = 1 -- Временная переменная для создания списка, если к-ство програм не поволяет их вывести на экран ПК
	for k, v in pairs(userProgTable) do -- Вывод списка программ по 10 штук за раз 
		temp_k = k
		textutils.pagedPrint("["..k.."] ".."Name: "..v.kPath) -- Подобно "print()", но если нету места на дисплее, то оно позволит вам увидеть весь список
	end
	
	
-- Удаление старой папки
	if old_defaultFolderName ~= nil then shell.run("delete", "deleteFolder_" .. defaultFolderName) end -- Удаляем старую папку, если она существовала
	return true, ""
end


-- Непосредственный запуск "распаковки" среды с ГитХаба
local args = {...}
clone(args[1])