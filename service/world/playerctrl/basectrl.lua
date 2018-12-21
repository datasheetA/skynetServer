--import module
local skynet = require "skynet"
local global = require "global"

local datactrl = import(lualib_path("public.datactrl"))

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
end

function CPlayerBaseCtrl:Save()
    local mData = {}
    mData.grade = self:GetData("grade", 0)
    mData.name = self:GetData("name")
    mData.gold = self:GetData("gold",0)
    mData.silver = self:GetData("silver",0)
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
end
