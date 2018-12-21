
local eio = require("base.extend").Io

local M = {}

local sDaobiaoPath = "daobiao/gamedata/server/data.lua"

local function Require(sPath)
    local sFile = eio.readfile(sPath)
    local f, s = load(sFile)
    assert(f, s)
    return f()
end

M.daobiao = Require(sDaobiaoPath)

return M

