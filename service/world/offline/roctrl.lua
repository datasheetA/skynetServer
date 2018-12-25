--离线只读块ro
local skynet = require "skynet"
local global = require "global"
local interactive = require "base.interactive"
local extend = require "base/extend"

local datactrl = import(lualib_path("public.datactrl"))
local timeop = import(lualib_path("base.timeop"))

CROCtrl = {}
CROCtrl.__index = CROCtrl
inherit(CROCtrl, datactrl.CDataCtrl)

function CROCtrl:New(pid)
    local o = super(CROCtrl).New(self, {pid = pid})
    o:Init(pid)
    return o
end

function CROCtrl:Init(pid)
    self.m_ID = pid
    self.m_Grade = 0
    self.m_Name = ""
    self.m_Shape = 0
    self.m_LastTime = timeop.get_time()
    self.m_WaitFuncList = {}
    self.m_bLoading = true
    self:Schedule()
end

function CROCtrl:AddWaitFunc(func)
    table.insert(self.m_WaitFuncList,func)
end

function CROCtrl:WakeUpFunc()
    for _,func in ipairs(self.m_WaitFuncList) do
        func(self)
    end
    self.m_LastTime = timeop.get_time()
end

function CROCtrl:IsLoading()
    return self.m_bLoading
end

function CROCtrl:IsActive()
    local iNowTime = timeop.get_time()
    if iNowTime - self.m_LastTime < 10 * 60 then
        return true
    end
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(self.m_ID)
    if oPlayer then
        return true
    end
    return false
end

function CROCtrl:Save()
    local data = {}
    data["iGrade"] = self.m_Grade
    data["sName"] = self.m_Name
    data["iShape"] = self.m_Shape
    return data
end

function CROCtrl:Load(data)
    if not data then
        return
    end
    self.m_Grade = data["iGrade"]
    self.m_Name = data["sName"]
    self.m_Shape = data["iShape"]

    self:Dirty()
end

function CROCtrl:OnLogin(mArgs)
    self:Dirty()
    mArgs = mArgs or {}
    self.m_Grade = mArgs["iGrade"] or self.m_Grade
    self.m_Name = mArgs["sName"] or self.m_Names
    self.m_Shape = mArgs["iShape"] or self.m_Shape
end

function CROCtrl:Schedule()
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

function CROCtrl:_CheckSaveDb()
    if self:IsDirty() and not self.m_bLoading then
        local mData = self:Save()
        interactive.Send(".gamedb", "offlinedb", "SaveOfflineRO", {pid = self.m_ID, data = mData})
        self:UnDirty()
    end
end

function CROCtrl:_CheckClean()
    if not self:IsActive() then
        local oWorldMgr = global.oWorldMgr
        oWorldMgr:CleanRO(self.m_ID)
    end
end