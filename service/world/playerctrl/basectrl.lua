--import module
local skynet = require "skynet"
local global = require "global"

local datactrl = import(lualib_path("public.datactrl"))
local playernet = import(service_path("netcmd/player"))

CPlayerBaseCtrl = {}
CPlayerBaseCtrl.__index = CPlayerBaseCtrl
inherit(CPlayerBaseCtrl, datactrl.CDataCtrl)

function CPlayerBaseCtrl:New(pid)
    local o = super(CPlayerBaseCtrl).New(self, {pid = pid})
    return o
end

function CPlayerBaseCtrl:Load(mData)
    local mData = mData or {}
    self:SetData("grade", mData.grade or 0)
    self:SetData("name", mData.name or string.format("DEBUG%d", self:GetInfo("pid")))
    self:SetData("gold",mData.gold or 0)
    self:SetData("silver",mData.silver or 0)
    self:SetData("exp",mData.exp or 0)
    self:SetData("chubeiexp",mData.chubeiexp or 0)
end

function CPlayerBaseCtrl:Save()
    local mData = {}
    mData.grade = self:GetData("grade", 0)
    mData.name = self:GetData("name")
    mData.gold = self:GetData("gold",0)
    mData.silver = self:GetData("silver",0)
    mData.exp = self:GetData("exp",0)
    mData.chubeiexp = self:GetData("chubeiexp",0)
    return mData
end

function CPlayerBaseCtrl:ValidGold(iVal,mArgs)
    local iGold = self:GetData("gold",0)
    assert(iGold>0,string.format("%d gold err %d",self:GetInfo("pid"),iGold))
    assert(iVal>0)
    if iGold< iVal then
        local sTip = mArgs.tip
        if not sTip then
            sTip = ""
        end
        return false
    end
    return true
end

function CPlayerBaseCtrl:RewardGold(iVal,sReason)
    local iGold = self:GetData("gold",0)
    
    iGold = iGold + iVal
    self:SetData("gold",iGold)
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(self:GetInfo("pid"))
    if oPlayer then
        oPlayer:GS2CPropChange({gold=iGold})
    end
end

function CPlayerBaseCtrl:ResumeGold(iVal,sReason,mArgs)
    local iGold = self:GetData("gold",0)
    assert(iGold>0,string.format("%d gold err %d",self:GetInfo("pid"),iGold))
    assert(iVal>0)
    if not self:ValidGold(iVal,mArgs) then
        return
    end
    iGold = iGold - iVal
    self:SetData("gold",iGold)
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(self:GetInfo("pid"))
    if oPlayer then
        oPlayer:GS2CPropChange({gold=iGold})
    end
end

function CPlayerBaseCtrl:ValidSilver(iVal,mArgs)
    local iSilver = self:GetData("silver",0)
    assert(iSilver>0,string.format("%d gold err %d",self:GetInfo("pid"),iSilver))
    assert(iVal>0)
    if iSilver < iVal then
        local sTip = mArgs.tip
        if not sTip then
            sTip = ""
        end
        return false
    end
    return true
end

function CPlayerBaseCtrl:RewardSilver(iVal,sReason,mArgs)
    local iSilver = self:GetData("silver",0)
    
    iSilver = iSilver + iVal
    self:SetData("silver",iSilver)
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(self:GetInfo("pid"))
    if oPlayer then
        oPlayer:GS2CPropChange({silver=iSilver})
    end
end

function CPlayerBaseCtrl:ResumeSilver(iVal,sReason,mArgs)
    local iSilver = self:GetData("silver",0)
    assert(iSilver>0,string.format("%d gold err %d",self:GetInfo("pid"),iSilver))
    assert(iVal>0)
    if not self:ValidSilver(iVal,mArgs) then
        return
    end
    iSilver = iSilver - iVal
    self:SetData("silver",iSilver)
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(self:GetInfo("pid"))
    if oPlayer then
        oPlayer:GS2CPropChange({silver=iSilver})
    end
end

function CPlayerBaseCtrl:RewardExp(iVal,sReason,mArgs)
    local iExp = self:GetData("exp",0)
    assert(iExp>0,string.format("%d exp err %d %d",self:GetInfo("pid"),iExp,iVal))

    iExp = iExp + iVal
    self:SetData("exp",iExp)
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(self:GetInfo("pid"))
    if oPlayer then
        oPlayer:GS2CPropChange({exp=iExp})
    end
end

function CPlayerBaseCtrl:AddChubeiExp(iVal,sReason)
    local iChubeiExp = self:GetData("chubeiexp",0)
    assert(iChubeiExp,string.format("%d exp err %d %d",self:GetInfo("pid"),iChubeiExp,iVal))

    local iChubeiExp = iChubeiExp + iVal
    self:SetData("chubeiexp",iChubeiExp)
end
