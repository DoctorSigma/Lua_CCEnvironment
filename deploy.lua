local listname = "/Instructions.txt"
local prefix = "https://raw.githubusercontent.com/"


function _GET(path) --> status(bool), errorMsg(string), content -- Читает данные с ГитХаба
    local handle = http.get(prefix .. path)
	
    if (handle == nil) or (handle.getResponseCode() ~= 200) then
        return '"' .. path .. '" not responding', ""
    end
	
    local content = handle.readAll()
    handle.close()
    return nil, content
end

function clone(repo, branch) --> status(bool), errorMsg(string) -- Клонирует данные с ГитХаба
    local curdir = shell.dir() .. "/"
    if branch == nil then -- Если в параметрах не была указана ветка, то устанавлвается значение по умолчанию, "master"
        branch = "master"
    end

    if repo == nil then -- Если в параметрах не был указан репозиторий
        if (fin = fs.open(curdir .. listname, "r")) ~= nil then -- Если в файлах на ПК есть файл инструкций, тоесть данная програма уже успешно выполнялась            
			_, _, r = string.find(fin.readLine(), '!Repository="(+)"') -- Читаем первую строку, в которой должно находится имя репозитория
			_, _, b = string.find(fin.readLine(), '!Branch="(+)"') -- Читаем следующую строку, в которой должна находится ветка
            fin.close()
            return clone(r, b)
        else
            print("Please specify repository in arguments")
            return false, "No repository name"
        end
    end

    local repopath = repo .. "/" .. branch .. "/"
    local ok, errorMsg, errorMsg, fileNameList = _GET(repopath .. listname)

    if not ok then 
        return (print("repository have no "..listname.." in the repo ".. repo) and false)
    end

    local first = true
    for fname in string.gmatch(fileNameList, "([^\n]+)") do
        if first then 
			first = false 
        else
            print("Retrieving: ", fname)
            local ok, errorMsg, content = _GET(repopath .. fname)
            if not ok then 
                print("  ..unexisted")
            else
                local fout = fs.open(curdir .. fname, "w")
                fout.write(content)
                fout.close()
            end
        end
    end
end

if false then
local ok, errorMsg, s = _GET("Vany/gh4lua/master/README.md")
print(s, ok)
end

local args = {...}
clone(args[1])



-- TODO Make it module
-- TODO make separate executive script
-- TODO make installation script that install path in autorun