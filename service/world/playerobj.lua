--import module

local global = require "global"
local skynet = require "skynet"
local interactive = require "base.interactive"
local playernet = import(service_path("netcmd/player"))

local playerctrl = import(service_path("playerctrl.init"))

function NewPlayer(...)
    local o = CPlayer:New(...)
    return o
end

CPlayer = {}
CPlayer.__index = CPlayer
inherit(CPlayer, logic_base_cls())

function CPlayer:New(mConn, mRole)
    local o = super(CPlayer).New(self)

    o.m_iNetHandle = mConn.handle
    o.m_iPid = mRole.pid
    o.m_sAccount = mRole.account
    o.m_iDisconnectedTime = nil
    o.m_fHeartBeatTime = get_time()

    o.m_oBaseCtrl = playerctrl.NewBaseCtrl(o.m_iPid)
    o.m_oActiveCtrl = playerctrl.NewActiveCtrl(o.m_iPid)
    o.m_oItemCtrl = playerctrl.NewItemCtrl(o.m_iPid)
    o.m_oThisTemp = playerctrl.NewThisTempCtrl(o.m_iPid)
    o.m_oToday = playerctrl.NewTodayCtrl(o.m_iPid)
    o.m_oThisWeek = playerctrl.NewWeekCtrl(o.m_iPid)
    o.m_oSeveralDay = playerctrl.NewSeveralDayCtrl(o.m_iPid)
    o.m_oTimeCtrl = playerctrl.NewTimeCtrl(o.m_iPid,{
         ["Today"] = o.m_oToday,
        ["Week"] = o.m_oThisWeek,
        ["ThisTemp"] = o.m_oThisTemp,
        ["SeveralDay"] = o.m_oSeveralDay,
        })
    return o
end

function CPlayer:Release()
    self.m_oBaseCtrl:Release()
    self.m_oActiveCtrl:Release()
    super(CPlayer).Release(self)
end

function CPlayer:GetAccount()
    return self.m_sAccount
end

function CPlayer:GetPid()
    return self.m_iPid
end

function CPlayer:GetConn()
    local oWorldMgr = global.oWorldMgr
    return oWorldMgr:GetConnection(self.m_iNetHandle)
end

function CPlayer:SetNetHandle(iNetHandle)
    self.m_iNetHandle = iNetHandle
    if iNetHandle then
        self.m_iDisconnectedTime = nil
    else
        self.m_iDisconnectedTime = get_msecond()
        self:OnDisconnected()
    end
end

function CPlayer:Send(sMessage, mData)
    local oConn = self:GetConn()
    if oConn then
        oConn:Send(sMessage, mData)
    end
end

function CPlayer:MailAddr()
    local oConn = self:GetConn()
    if oConn then
        return oConn:MailAddr()
    end
end

function CPlayer:OnLogout()
    local oWarMgr = global.oWarMgr
    oWarMgr:OnLogout(self)
    local oSceneMgr = global.oSceneMgr
    oSceneMgr:OnLogout(self)
    --disconnect
    local oWorldMgr = global.oWorldMgr
    local oConn = self:GetConn()
    if oConn then
        oWorldMgr:KickConnection(oConn.m_iHandle)
    end
    --save db
    self:SaveDb()
end

function CPlayer:OnLogin(bReEnter)
    self:Send("GS2CLoginRole", {role = {account = self:GetAccount(), pid = self:GetPid()}})
    self.m_fHeartBeatTime = get_time()


    local oWar = self.m_oActiveCtrl:GetNowWar()
    if oWar then
        local oWarMgr = global.oWarMgr
        oWarMgr:OnLogin(self, bReEnter)
    else
        local oSceneMgr = global.oSceneMgr
        oSceneMgr:OnLogin(self, bReEnter)
    end
    
    self:GS2CPropLogin()
    self.m_oItemCtrl:OnLogin()

    if not bReEnter then
        self:Schedule()
    end
    local mArgs = {
        sName = self.m_oBaseCtrl:GetData("name"),
        iGrade = self.m_oBaseCtrl:GetData("grade")
    }
    local oWorldMgr = global.oWorldMgr
    oWorldMgr:LoadRO(self.m_iPid,function (oRO)
        oRO:OnLogin(mArgs)
    end)
    oWorldMgr:LoadRW(self.m_iPid,function(oRW)
        oRW:OnLogin()
    end)
end

function CPlayer:OnDisconnected()
    local oWarMgr = global.oWarMgr
    oWarMgr:OnDisconnected(self)
    local oSceneMgr = global.oSceneMgr
    oSceneMgr:OnDisconnected(self)
end

function CPlayer:Schedule()
    local f1
    f1 = function ()
        self:DelTimeCb("_CheckSaveDb")
        self:AddTimeCb("_CheckSaveDb", 5*60*1000, f1)
        self:_CheckSaveDb()
    end
    f1()

    local f2
    f2 = function ()
        self:DelTimeCb("_CheckHeartBeat")
        self:AddTimeCb("_CheckHeartBeat", 10*1000, f2)
        self:_CheckHeartBeat()
    end
    f2()
end

function CPlayer:SaveDb()
    if self.m_oBaseCtrl:IsDirty() then
        local mData = self.m_oBaseCtrl:Save()
        interactive.Send(".gamedb", "playerdb", "SavePlayerBase", {pid = self:GetPid(), data = mData})
        self.m_oBaseCtrl:UnDirty()
    end
    if self.m_oActiveCtrl:IsDirty() then
        local mData = self.m_oActiveCtrl:Save()
        interactive.Send(".gamedb", "playerdb", "SavePlayerActive", {pid = self:GetPid(), data = mData})
        self.m_oActiveCtrl:UnDirty()
    end
    if self.m_oItemCtrl:IsDirty() then
        local mData = self.m_oItemCtrl:Save()
        interactive.Send(".gamedb","playerdb","SavePlayerItem",{pid=self:GetPid(),data=mData})
        self.m_oItemCtrl:UnDirty()
    end
   
    if self.m_oTimeCtrl:IsDirty() then
        local mData = self.m_oTimeCtrl:Save()
        interactive.Send(".gamedb","playerdb","SavePlayerTimeInfo",{pid=self:GetPid(),data=mData})
        self.m_oTimeCtrl:UnDirty()
    end
end

function CPlayer:ClientHeartBeat()
    self.m_fHeartBeatTime = get_time()
    self:Send("GS2CHeartBeat", {time = math.floor(self.m_fHeartBeatTime)})
end

function CPlayer:_CheckSaveDb()
    assert(not self:IsRelease(), "_CheckSaveDb fail")
    self:SaveDb()
end

function CPlayer:_CheckHeartBeat()
    assert(not self:IsRelease(), "_CheckHeartBeat fail")
    local fTime = get_time()
    if fTime - self.m_fHeartBeatTime >= 3*60 then
        local oWorldMgr = global.oWorldMgr
        oWorldMgr:Logout(self:GetPid())
    end
end

--道具相关
function CPlayer:RewardItem(itemobj,sReason,iKey,mArgs)
    if itemobj:SID() < 10000 then
        local oRealObj = itemobj:RealObj()
        if oRealObj then
            --
        else
            itemobj:Reward(self)
            return
        end
    end
    local retobj = self.m_oItemCtrl:AddItem(itemobj,sReason)
    --添加失败，放入邮件，功能稍后增加
    if retobj then
        return
    end
end

function CPlayer:GiveItem(ItemList,sReason)
    self.m_oItemCtrl:GiveItem(ItemList)
end

--ItemList:{sid:amount}
function CPlayer:ValidGive(ItemList)
    local bSuc = self.m_oItemCtrl:ValidGive(ItemList)
    return bSuc
end

function CPlayer:RemoveItemAmount(sid,iAmount)
    local bSuc = self.m_oItemCtrl:RemoveItemAmount(sid,iAmount)
    return bSuc
end

function CPlayer:GetItemAmount(sid)
    local iAmount = self.m_oItemCtrl:GetItemAmount(sid)
    return iAmount
end

function CPlayer:RewardGold(iVal,sReason,mArgs)
    self.m_oBaseCtrl:RewardGold(iVal,sReason,mArgs)
end

function CPlayer:RewardSilver(iVal,sReason,mArgs)
    self.m_oBaseCtrl:RewardSilver(iVal,sReason,mArgs)
end

function CPlayer:GS2CPropLogin()
    playernet.GS2CPropLogin(self)
end

function CPlayer:GS2CPropChange(key,value)
    playernet.GS2CPropChange(self,key,value)
end