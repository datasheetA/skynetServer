--离线读写块rw
local skynet = require "skynet"
local global = require "global"
local interactive = require "base.interactive"

local datactrl = import(lualib_path("public.datactrl"))
local timeop = import(lualib_path("base.timeop"))

CRWCtrl = {}
CRWCtrl.__index = CRWCtrl
inherit(CRWCtrl, datactrl.CDataCtrl)

function CRWCtrl:New(pid)
    local o = super(CRWCtrl).New(self, {pid = pid})
    o:Init(pid)
    return o
end

function CRWCtrl:Init(pid)
    self.m_ID = pid
    self.m_FuncList = {}
    self.m_Gold = 0
    self.m_LastTime = timeop.get_time()
    self.m_bLoading = true
    self.m_WaitFuncList = {}
    self:Schedule()
end

function CRWCtrl:AddWaitFunc(func)
    table.insert(self.m_WaitFuncList,func)
end

function CRWCtrl:WakeUpFunc()
    for _,func in pairs(self.m_WaitFuncList) do
        func(self)
    end
    self.m_LastTime = timeop.get_time()
end

function CRWCtrl:IsLoading()
    return self.m_bLoading
end

function CRWCtrl:IsActive()
    local iNowTime = timeop.get_time()
    if iNowTime - self.m_LastTime >= 10 * 60 then
        return true
    end
    return false
end

function CRWCtrl:Save()
    local data = {}
    data["Gold"] = self.m_Gold
    data["FuncList"] = self.m_FuncList
    return data
end

function CRWCtrl:Load(data)
    if not data then
        return
    end
    self.m_Gold = data["Gold"]
    self.m_FuncList = data["FuncList"]
end

function CRWCtrl:ChargeGold(iGold,sReason)
    self:Dirty()
    assert(self.m_Gold>=0,string.format("%d ChargeGold err:%d %d",self:GetInfo("pid"),self.m_Gold,iGold))
    assert(iGold>0,string.format("%d ChargeGold err:%d %d",self:GetInfo("pid"),self.m_Gold,iGold))
    self.m_Gold = self.m_Gold + iGold
end

function CRWCtrl:OnLogin()
    -- body
end

function CRWCtrl:Schedule()
    local f1
    f1 = function ()
        self:DelTimeCb("_CheckSaveDb")
        self:AddTimeCb("_CheckSaveDb", 5*60*1000, f1)
        self:_CheckSaveDb()
    end
    f1()

    local f2
    f2 = function ()
        self:DelTimeCb("_CheckClean")
        self:AddTimeCb("_CheckClean", 10*60*1000, f2)
        self:_CheckClean()
    end
    f2()
end

function CRWCtrl:_CheckSaveDb()
    if self:IsDirty() then
        local mData = self:Save()
        interactive.Send(".gamedb", "offlinedb", "SaveOfflineRW", {pid =self.m_ID, data = mData})
        self:UnDirty()
    end
end

function CRWCtrl:_CheckClean()
    if not self:IsActive() then
        local oWorldMgr = global.oWorldMgr
        oWorldMgr:CleanRW(self.m_ID)
    end
end