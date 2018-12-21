
local skynet = require "skynet"

function get_time()
    return skynet.time()
end

function get_current()
    return skynet.now()
end

function get_second()
    return math.floor(get_current()/100)
end

function get_ssecond()
    return get_current()/100
end

function get_msecond()
    return get_current()*10
end
