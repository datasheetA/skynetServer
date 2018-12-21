--import module

local global = require "global"
local skynet = require "skynet"
local interactive = require "base.interactive"


function NewGMMgr(...)
    local o = CGMMgr:New(...)
    return o
end

Commands = {}

function Commands.setgrade(oMaster, i)
    oMaster.m_oBaseCtrl:SetData("grade", i)
end


CGMMgr = {}
CGMMgr.__index = CGMMgr
inherit(CGMMgr, logic_base_cls())

function CGMMgr:New()
    local o = super(CGMMgr).New(self)
    return o
end

function CGMMgr:ReceiveCmd(oMaster, sCmd)
    local mMatch = {}
    mMatch["{"] = "}"

    local iState = 1
    local iBegin = 1
    local iEnd = 0

    local sMatch = nil
    local iMatch = 0

    local lArgs = {}
    for i = 1, #sCmd do
        local c = index_string(sCmd, i)

        if iState == 1 then
            if c == " " then
                iEnd = i-1
                iState = 3
                if iEnd>=iBegin then
                    table.insert(lArgs, string.sub(sCmd, iBegin, iEnd))
                end
            elseif mMatch[c] then
                assert(false, string.format("ReceiveCmd fail %d %s %s", iState, c, mMatch[c]))
            end
        elseif iState == 2 then
            if iMatch <= 0 then
                if c == " " then
                    iEnd = i-1
                    iState = 3
                    if iEnd>=iBegin then
                        table.insert(lArgs, string.sub(sCmd, iBegin, iEnd))
                    end
                else
                    assert(false, string.format("ReceiveCmd fail %d %s %s", iState, c, mMatch[c]))
                end
            else
                if c == mMatch[sMatch] then
                    iMatch = iMatch - 1
                elseif mMatch[c] then
                    assert(false, string.format("ReceiveCmd fail %d %s %s", iState, c, mMatch[c]))
                end
            end
        else
            if mMatch[c] then
                iState = 2
                iBegin = i
                sMatch = c
                iMatch = 1
            elseif c ~= " " then
                iBegin = i
                iState = 1
            end
        end
    end

    if iState == 1 then
        iEnd = #sCmd
        if iEnd>=iBegin then
            table.insert(lArgs, string.sub(sCmd, iBegin, iEnd))
        end
    elseif iState == 2 then
        if iMatch <= 0 then
            iEnd = #sCmd
            if iEnd>=iBegin then
                table.insert(lArgs, string.sub(sCmd, iBegin, iEnd))
            end
        end
    end

    local sCommand = lArgs[1]
    local lCommandArgs = {}
    for k = 2, #lArgs do
        local v = lArgs[k]
        local r = assert(load(string.format("return %s", v), "", "bt")(), string.format("ReceiveCmd fail index:%d value:%s", k, v))
        table.insert(lCommandArgs, r)
    end

    local func = Commands[sCommand]
    if func then
        func(oMaster, table.unpack(lCommandArgs))
    else
        assert(false, string.format("ReceiveCmd fail cmd:%s", sCommand))
    end

end
