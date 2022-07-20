local fService = require("ServicePrograms")
local ok, _, vDir = fService.getTurtleDirection()
print('['..tostring(ok)..'] Direction: '..vDir:tostring())