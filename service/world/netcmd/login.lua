--import module

local global = require "global"
local skynet = require "skynet"

function C2GSTestDo(oPlayer, mData)
    oPlayer:Send("GS2CTestDo", {})
end
