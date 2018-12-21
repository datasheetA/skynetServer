
local skynet = require "skynet"
local ltimer = require "ltimer"

local M = {}

local oTimerMgr

local function GetTime()
    return math.floor(get_time()*100)
end

local function Trace(sMsg)
    print(debug.traceback(sMsg))
end


local CTimer = {}
CTimer.__index = CTimer

function CTimer:New(id)
    local o = setmetatable({}, self)
    o.m_iTimerId = id
    o.m_mName2Id = {}
    return o
end

function CTimer:GetTimerId()
    return self.m_iTimerId
end

function CTimer:Release()
    for _, v in pairs(self.m_mName2Id) do
        oTimerMgr:DelCallback(v)
    end
    self.m_mName2Id = {}
end

function CTimer:AddCallback(sKey, iDelay, func)
    assert(iDelay>=1, string.format("CTimer AddCallback delay error %s", sKey))
    iDelay = math.floor(iDelay/10)
    local iOldId = self.m_mName2Id[sKey]

    local f
    f = function ()
        self.m_mName2Id[sKey] = nil
        func()
    end

    local iNewId = oTimerMgr:AddCallback(iDelay, f)
    self.m_mName2Id[sKey] = iNewId
    if iOldId then
        print(string.format("CTimer%d AddCallback repeated %s %d %d", self.m_iTimerId, sKey, iOldId, iNewId))
    end
end

function CTimer:DelCallback(sKey)
    local id = self.m_mName2Id[sKey]
    if id then
        self.m_mName2Id[sKey] = nil
        oTimerMgr:DelCallback(id)
    end
end


local CTimerMgr = {}
CTimerMgr.__index = CTimerMgr

function CTimerMgr:New()
    local o = setmetatable({}, self)
    o.m_oCobj = ltimer.ltimer_create(GetTime())
    o.m_iTimerDispatchId = 0
    o.m_mTimer = {}

    o.m_iCbDispatchId = 0
    o.m_mCbUsedId = {}
    o.m_lCbReUseId = {}
    return o
end

function CTimerMgr:Release()
    for _, v in pairs(self.m_mTimer) do
        v:Release()
    end
    self.m_mTimer = {}
end

function CTimerMgr:Init()
    local f
    f = function ()
        self.m_oCobj:ltimer_update(GetTime())
        skynet.timeout(1, f)
    end
    skynet.timeout(1, f)
end

function CTimerMgr:GetTimerDispatchId()
    self.m_iTimerDispatchId = self.m_iTimerDispatchId + 1
    return self.m_iTimerDispatchId
end

function CTimerMgr:NewTimer()
    local id = self:GetTimerDispatchId()
    local o = CTimer:New(id)
    self.m_mTimer[id] = o
    return o
end

function CTimerMgr:DelTimer(id)
    local o = self.m_mTimer[id]
    if o then
        o:Release()
        self.m_mTimer[id] = nil
    end
end

function CTimerMgr:GetCbDispatchId()
    local l = self.m_lCbReUseId
    local id = table.remove(l, #l)
    if id then
        return id
    end
    self.m_iCbDispatchId = self.m_iCbDispatchId + 1
    return self.m_iCbDispatchId
end

function CTimerMgr:AddCallback(iDelay, func)
    local iCbId = self:GetCbDispatchId()
    self.m_mCbUsedId[iCbId] = true
    local f = self:ProxyFunc(func, iCbId)
    self.m_oCobj:ltimer_add_time(iCbId, iDelay, f)
    return iCbId
end

function CTimerMgr:DelCallback(iCbId)
    self.m_mCbUsedId[iCbId] = nil
end

function CTimerMgr:ProxyFunc(func, id)
    local f
    f = function ()
        table.insert(self.m_lCbReUseId, id)
        if self.m_mCbUsedId[id] then
            self.m_mCbUsedId[id] = nil
            xpcall(func, Trace)
        end
    end
    return f
end


function M.Init()
    if not oTimerMgr then
        oTimerMgr = CTimerMgr:New()
        oTimerMgr:Init()
    end
end

function M.NewTimer()
    return oTimerMgr:NewTimer()
end

return M
