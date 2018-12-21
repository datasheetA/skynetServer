
require "base.reload"
require "base.timeop"
require "base.stringop"

local skynet = require "skynet"

MY_ADDR = skynet.self()
MY_NODE = skynet.getenv("cluster_name")
MY_SERVICE_NAME = ...

print = function ( ... )
    skynet.error(...)
end

service_path = function (sPath)
    return string.format("service.%s.%s", MY_SERVICE_NAME, sPath)
end

lualib_path = function (sPath)
    return string.format("lualib.%s", sPath)
end

table_print = function (t)
    local p = require("base/extend").Table.print
    p(t)
end

inherit = function (child, parent)
    setmetatable(child, parent)
end

super = function (child)
    return getmetatable(child)
end
