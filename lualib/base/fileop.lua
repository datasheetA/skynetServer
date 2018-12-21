
local skynet = require "skynet"

function read_file(path, pre)
    assert(path)
    local env = pre or {}
    local f = assert(loadfile(path,"t",env))
    f()
    return env
end
