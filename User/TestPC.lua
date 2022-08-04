local fService = require("ServicePrograms")
print("TestPC test 1.3.1:")

local function test()
    fService.getSettings("value1")
    fService.setSettings("pole1", "14")
    print(fService.getSettings("pole1"))
end

parallel.waitForAny(test, fService.fSettingsDriver)