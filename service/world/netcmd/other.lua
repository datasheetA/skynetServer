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

function C2GSCallback(oPlayer,mData)
    local iSessionIdx = mData["sessionidx"]
    local oCbMgr = global.oCbMgr
    oCbMgr:CallBack(oPlayer,iSessionIdx,mData)
end
