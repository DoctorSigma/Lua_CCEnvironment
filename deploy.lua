local instrList_Name = "Instructions.txt"
local defaultFolderName = "CCEnvrm/"
local prefix = "https://raw.githubusercontent.com/"


function _GET(path) --> status(bool), errorMsg(string), content -- Читает данные с ГитХаба
    local handle = http.get(prefix .. path)
	
    if (handle == nil) or (handle.getResponseCode() ~= 200) then
        return false, '"' .. path .. '" not responding', ""
    end
	
    local content = handle.readAll()
    handle.close()
    return true, nil, content
end

function clone(repo, branch) --> status(bool), errorMsg(string) -- Клонирует данные с ГитХаба
    local curdir = shell.dir() .. "/"
    if branch == nil then -- Если в параметрах не была указана ветка, то устанавлвается значение по умолчанию, "master"
        branch = "master"
    end

    if repo == nil then -- Если в параметрах не был указан репозиторий
	    fin = fs.open(curdir .. instrList_Name, "r") -- Пробуем открыть файл
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

    local repoPath = repo .. "/" .. branch .. "/" -- Путь в репозитории
    local ok, _, instrList_File = _GET(repoPath .. instrList_Name) -- Попытка загрузить файл с инструкциями

    if not ok then -- Если не удалось загрузить инструкции
        return (print(' Repository "' .. repo .. '" does not contain the following file: ' .. instrList_Name) and false), (' Repository "' .. repo .. '" does not contain the following file: ' .. instrList_Name)
    end
	
    for fTag, fName in string.gmatch(instrList_File, '#(.-)="(.-)"') do -- Читай с файла инструкций тэг а также название программы с её относительным путём
		if (fTag == "!") or (fTag == "Service") then -- Если после ключевого символа "#" есть ("!" или "Service") то это служебные прогаммы и должны быть установлены везде
            print("Receiving: ", fName)
            local ok, _, content = _GET(repoPath .. fName)
            if not ok then print(" ..unexisted") else
				local instalDir = ((fTag == "!") and ("") or (defaultFolderName .. fTag .. "/")) -- "Тернарный оператор", конструктция:(s = condition ? "true" : "false"), пояснение: оператор "and" возвращает первое ложное значение среди сових операндов; если оба операнда истинны, возвращается последний из них, а оператор "or" возвращает первое истинное значение среди своих операндов; если оба операнда ложны, возвращается последний из них
																								 -- Если "!", то не нужно перемещать файл в подпапку, но если "Service", то нужно переместить в папку по умолчанию, в подкаталог fTag = "Service"
				local fout = fs.open(curdir .. instalDir .. fName, "w")
                fout.write(content)
                fout.close()
			end
		elseif fTag == "User" then -- Если после ключевого символа "#" есть ("User") то это пользовательские программы, должна быть только одна такая программа на ПК
			
		else -- Не верно составленый или неизвестный Тэг
			
		end
    end
	return true, ""
end

if false then
local ok, errorMsg, s = _GET("Vany/gh4lua/master/README.md")
print(s, ok)
end

local args = {...}
clone(args[1])