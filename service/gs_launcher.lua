local skynet = require "skynet"
require "skynet.manager"

skynet.start(function()
    print("gs start")

    local iConsolePort = assert(skynet.getenv("GM_CONSOLE_PORT"))
    skynet.newservice("debug_console", iConsolePort)

    skynet.newservice("gamedb")
    skynet.newservice("login")
    skynet.newservice("world")

    print("gs all service booted")    
    skynet.exit()
end)
