--离线读写块rw
local skynet = require "skynet"
local global = require "global"
local interactive = require "base.interactive"
local extend = require "base.extend"

local datactrl = import(lualib_path("public.datactrl"))
local timeop = import(lualib_path("base.timeop"))
local defines = import(service_path("offline.defines"))

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
    self.m_GoldCoin = 0                                                                                             --金元宝
    self.m_RplGoldCoin = 0                                                                                        --代金

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
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(self.m_ID)
    if oPlayer then
        return true
    end
    return false
end

function CRWCtrl:Save()
    local data = {}
    data["GoldCoin"] = self.m_GoldCoin or 0
    data["RplGoldCoin"]  = self.m_RplGoldCoin or 0
    data["FuncList"] = self.m_FuncList or {}
    return data
end

function CRWCtrl:Load(data)
    if not data then
        return
    end
    self.m_GoldCoin = data["GoldCoin"] or 0
    self.m_RplGoldCoin = data["RplGoldCoin"] or 0
    self.m_FuncList = data["FuncList"] or {}

    self:Dirty()
end

function CRWCtrl:ChargeGold(iGold,sReason)
    self:Dirty()
    assert(self.m_GoldCoin>=0,string.format("%d ChargeGold err:%d %d",self:GetInfo("pid"),self.m_GoldCoin,iGold))
    assert(iGold>0,string.format("%d ChargeGold err:%d %d",self:GetInfo("pid"),self.m_Gold,iGold))
    self.m_GoldCoin = self.m_GoldCoin + iGold
end

function CRWCtrl:AddFunc(sFunc,...)
    local mArgs = {...}
    local iFuncNo = defines.GetFuncNo(sFunc)
    assert(iFuncNo>0,string.format("%d AddFuncList err:%s",self.m_ID,sFunc))
    table.insert(self.m_FuncList,{iFuncNo,mArgs})
end

function CRWCtrl:OnLogin()
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(self.m_ID)
    assert(oPlayer,string.format("CRWCtrl:OnLogin err:%d",self.m_ID))
    self:Dirty()
    local funclist = self.m_FuncList
    self.m_FuncList = {}
    for _,mFuncData in ipairs(funclist) do
        local iFuncNo,mArgs = table.unpack(mFuncData)
        local sFunc = defines.GetFuncByNo(iFuncNo)
        if iFuncNo < 10000 then
            oPlayer[sFunc](oPlayer,table.unpack(mArgs))
        end
    end
end

function CRWCtrl:AddGoldCoin(iGoldCoin,sReason)
    self:Dirty()
    local iOldGoldCoin = self.m_GoldCoin
    assert(iGoldCoin>0,string.format("%d AddGoldCoin err %d %d",self.m_ID,self.m_GoldCoin,iGoldCoin))
    self.m_GoldCoin  = self.m_GoldCoin + iGoldCoin
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(self.m_ID)
    if oPlayer then
        oPlayer:PropChange("goldcoin")
        oPlayer.m_oBaseCtrl:SetData("goldcoin",self:GoldCoin())
    end
end

function  CRWCtrl:AddRplGoldCoin(iRplGold,sReason)
    self:Dirty()
    local iOldRplGoldCoin = self.m_RplGoldCoin
    assert(iRplGold>0,string.format("%d AddRplGoldCoin err %d %d",self.m_ID,self.m_RplGoldCoin,iRplGold))
    self.m_RplGoldCoin = self.m_RplGoldCoin + iRplGold
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(self.m_ID)
    if oPlayer then
        oPlayer:PropChange("goldcoin")
        oPlayer.m_oBaseCtrl:SetData("goldcoin",self:GoldCoin())
    end
end

function CRWCtrl:GoldCoin()
    local iGold = self.m_GoldCoin + self.m_RplGoldCoin
    return iGold
end

function CRWCtrl:ValidGoldCoin(iGold)
    local iSumGold = self:GoldCoin()
    if iSumGold < iGold then
        return false
    end
    return true
end

-- 优先绑定
function CRWCtrl:PayGoldCoin(iVal)
    if not self:ValidGoldCoin(iVal) then
        return
    end
    self:Dirty()
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