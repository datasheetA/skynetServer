--import module

local global = require "global"
local skynet = require "skynet"

function C2GSHeartBeat(oPlayer, mData)
    oPlayer:ClientHeartBeat()
end

function C2GSGMCmd(oPlayer, mData)
    local oGMMgr = global.oGMMgr
    oGMMgr:ReceiveCmd(oPlayer, mData.cmd)
end
