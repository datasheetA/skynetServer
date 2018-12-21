local skynet = require "skynet"

local REG = skynet.register_protocol

REG {
    name = "text",
    id = skynet.PTYPE_TEXT,
    pack = function (...)
        local n = select ("#" , ...)
        if n == 0 then
            return ""
        elseif n == 1 then
            return tostring(...)
        else
            return table.concat({...}," ")
        end
    end,
    unpack = skynet.tostring
}

