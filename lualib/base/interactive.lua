
local skynet = require "skynet"

local M = {}

local SEND_TYPE = 1
local REQUEST_TYPE = 2
local RESPONSE_TYPE = 3

local mNote = {}
local iSessionIdx = 0

function M.GetSession()
    iSessionIdx = iSessionIdx + 1
    if iSessionIdx >= 100000000 then
        iSessionIdx = 1
    end
    return iSessionIdx
end

function M.Send(iAddr, sModule, sCmd, mData)
    skynet.send(iAddr, "lua", {source = MY_ADDR, module = sModule, cmd = sCmd, session = 0, type =SEND_TYPE}, mData)
end

function M.Request(iAddr, sModule, sCmd, mData, fCallback)
    local iNo  = M.GetSession()
    mNote[iNo] = fCallback
    skynet.send(iAddr, "lua", {source = MY_ADDR, module = sModule, cmd = sCmd, session = iNo, type = REQUEST_TYPE}, mData)
end

function M.Response(iAddr, iNo, mData)
    skynet.send(iAddr, "lua", {source = MY_ADDR, session = iNo, type = RESPONSE_TYPE}, mData)
end

function M.Init(luacmd)
    skynet.dispatch("lua", function(session, address, mRecord, mData)
        local iType = mRecord.type
        if iType == RESPONSE_TYPE then
            local iNo = mRecord.session
            local f = mNote[iNo]
            if f then
                mNote[iNo] = nil
                f(mRecord, mData)
            end
        else
                local sModule = mRecord.module
                local sCmd = mRecord.cmd
                luacmd.Invoke(sModule, sCmd, mRecord, mData)
        end
    end)
end

return M
