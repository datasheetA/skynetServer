--import module
local global = require "global"
local skynet = require "skynet"

function LoginResult(mRecord, mData)
    local oGateMgr = global.oGateMgr
    local oConnection = oGateMgr:GetConnection(mData.handle)
    if oConnection then
        oConnection:LoginResult(mData)
    end
end
