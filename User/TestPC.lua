if not computer then
    printError("Error: requires a PC")
end

local fService = require("ServicePrograms")
print("TestPC test 1.3.5:")

local function test()
    fService.getSettings("value1")
    fService.setSettings("pole1", "14")
    print(fService.getSettings("pole1"))
    fService.setSettings("pole3", "2fg4")
    print(fService.getSettings("pole3"))
    --os.queueEvent("settings_driver_in", nil, "stop")
    sleep(1000)
end

parallel.waitForAny(test, fService.fSettingsDriver)
print("END")