--import module

local global = require "global"
local skynet = require "skynet"
local interactive = require "base.interactive"

function C2GSLoginAccount(oConn, mData)
    oConn:LoginAccount(mData)
end

function C2GSLoginRole(oConn, mData)
    oConn:LoginRole(mData)
end
