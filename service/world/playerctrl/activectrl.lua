--import module
local skynet = require "skynet"
local global = require "global"

local datactrl = import(lualib_path("public.datactrl"))

CPlayerActiveCtrl = {}
CPlayerActiveCtrl.__index = CPlayerActiveCtrl
inherit(CPlayerActiveCtrl, datactrl.CDataCtrl)

function CPlayerActiveCtrl:New(pid)
    local o = super(CPlayerActiveCtrl).New(self, {pid = pid})
    o.m_mNowSceneInfo = nil
    o.m_mNowWarInfo = nil
    return o
end

function CPlayerActiveCtrl:Load(mData)
    local mData = mData or {}

    self:SetData("scene_info", mData.scene_info)
    self:SetData("hp", mData.hp)
    self:SetData("mp", mData.mp)
    self:SetData("sp", mData.sp)
    self:SetData("gold",mData.gold or 0)
    self:SetData("silver",mData.silver or 0)
    self:SetData("exp",mData.exp or 0)
    self:SetData("chubeiexp",mData.chubeiexp or 0)
    self:SetData("enegy", mData.enegy or 0)
    self:SetData("disconnect_time", mData.disconnect_time or get_time())

    self:Dirty()
end

function CPlayerActiveCtrl:Save()
    local mData = {}

    mData.scene_info = self:GetData("scene_info")
    mData.hp = self:GetData("hp")
    mData.mp = self:GetData("mp")
    mData.sp = self:GetData("sp")
    mData.gold = self:GetData("gold")
    mData.silver = self:GetData("silver")
    mData.exp = self:GetData("exp")
    mData.chubeiexp = self:GetData("chubeiexp")
    mData.enegy = self:GetData("enegy")
    mData.disconnect_time = self:GetData("disconnect_time")
    return mData
end

function CPlayerActiveCtrl:GetDisconnectTime()
    return self:GetData("disconnect_time")
end

function CPlayerActiveCtrl:SetDisconnectTime(iTime)
    iTime = iTime or get_time()
    self:SetData("disconnect_time", iTime)
end

function CPlayerActiveCtrl:ValidGold(iVal,mArgs)
    mArgs = mArgs or {}
    local iGold = self:GetData("gold",0)
    assert(iGold>=0,string.format("%d gold err %d",self:GetInfo("pid"),iGold))
    assert(iVal>0,string.format("%d  validgold err %d",self:GetInfo("pid"),iVal))
    if iGold >= iVal then
        return true
    end
    local sTip = mArgs.tip
    if not sTip then
        sTip = "金币不足"
    end
    local oNotifyMgr = global.oNotifyMgr
    local pid = self:GetInfo("pid")
    oNotifyMgr:Notify(pid,sTip)
    local bShort = mArgs.short
    if not bShort then
        local oUIMgr = global.oUIMgr
        oUIMgr:GS2CShortWay(pid,2)
    end
    return false
end

function CPlayerActiveCtrl:RewardGold(iVal,sReason)
    local iGold = self:GetData("gold",0)
    
    iGold = iGold + iVal
    self:SetData("gold",iGold)
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(self:GetInfo("pid"))
    oPlayer:PropChange("gold")
end

function CPlayerActiveCtrl:ResumeGold(iVal,sReason,mArgs)
    local iGold = self:GetData("gold",0)
    assert(iGold>0,string.format("%d gold err %d",self:GetInfo("pid"),iGold))
    assert(iVal>0,string.format("%d gold cost err %d",self:GetInfo("pid"),iVal))
    iGold = iGold - iVal
    self:SetData("gold",iGold)
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(self:GetInfo("pid"))
    oPlayer:PropChange("gold")
end

function CPlayerActiveCtrl:ValidSilver(iVal,mArgs)
    mArgs = mArgs or {}
    local iSilver = self:GetData("silver",0)
    assert(iSilver>=0,string.format("%d silver err %d",self:GetInfo("pid"),iSilver))
    assert(iVal>0,string.format("%d cost silver err %d",self:GetInfo("pid"),iVal))
    if iSilver >= iVal then
        return true
    end
    local sTip = mArgs.tip
    if not sTip then
        sTip = "银币不足"
    end
    local pid = self:GetInfo("pid")
    local oNotifyMgr = global.oNotifyMgr
    oNotifyMgr:Notify(pid,sTip)
    local oUIMgr = global.oUIMgr
    oUIMgr:GS2CShortWay(pid,3)
    return false
end

function CPlayerActiveCtrl:RewardSilver(iVal,sReason,mArgs)
    assert(iVal>0,string.format("%d  rewardsilver err %d",self:GetInfo("pid"),iVal))
    local iSilver = self:GetData("silver",0)
    iSilver = iSilver + iVal
    self:SetData("silver",iSilver)
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(self:GetInfo("pid"))
    oPlayer:PropChange("silver")
end

function CPlayerActiveCtrl:ResumeSilver(iVal,sReason,mArgs)
    local iSilver = self:GetData("silver",0)
    assert(iSilver>0,string.format("%d silver err %d",self:GetInfo("pid"),iSilver))
    assert(iVal>0,string.format("%d cost silver err %d",self:GetInfo("pid"),iVal))
    iSilver = iSilver - iVal
    self:SetData("silver",iSilver)
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(self:GetInfo("pid"))
    oPlayer:PropChange("silver")
end

function CPlayerActiveCtrl:RewardExp(iVal,sReason,mArgs)
    local iExp = self:GetData("exp",0)
    assert(iVal>0,string.format("%d exp err %d %d",self:GetInfo("pid"),iExp,iVal))

    local oNotifyMgr = global.oNotifyMgr
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(self:GetInfo("pid"))
    local iPlayerGrade = oPlayer:GetGrade()
    local iServerGrade = oWorldMgr:GetServerGrade()

    local iSilver = 0
    if iPlayerGrade >= iServerGrade then
        local iDiff = iPlayerGrade - iServerGrade
        if iDiff >= 8 then
            iSilver = math.ceil(iVal/3)
            iVal = 0
        elseif iDiff >=5 then
            iVal = math.ceil(iVal*2/3)
        else
            iVal = math.ceil(iVal*4/5)
        end
    else
        if iServerGrade >= 60 then
            iVal = math.ceil(iVal * (1 + (iServerGrade - iPlayerGrade)*2/100))
        end
    end

    local lMsgs = {}
    if iVal > 0 then
        local sMsg = string.format("你获得了%dEXP", iVal)
        local iSubChuBei = math.min(self:GetData("chubeiexp"), iVal)
        if iSubChuBei > 0 then
            sMsg = sMsg .. string.format("储备经验加成%dEXP", iSubChuBei)
            self:SetData("chubeiexp", self:GetData("chubeiexp") - iSubChuBei)
            oPlayer:PropChange("chubeiexp")
        end
        self:SetData("exp", iExp + iVal + iSubChuBei)
        oPlayer:PropChange("exp")
        table.insert(lMsgs, sMsg)
    end
    if iSilver > 0 then
        local sMsg = string.format("%d银币", iSilver)
        self:SetData("silver", self:GetData("silver") + iSilver)
        oPlayer:PropChange("silver")
        table.insert(lMsgs, sMsg)
    end

    local sMsg = table.concat(lMsgs, "，")
    if #sMsg > 0 then
        oNotifyMgr:Notify(oPlayer:GetPid(), sMsg)
    end

    oPlayer:CheckUpGrade()
end

function CPlayerActiveCtrl:AddChubeiExp(iVal,sReason)
    local iChubeiExp = self:GetData("chubeiexp",0)
    assert(iVal,string.format("%d exp err %d %d",self:GetInfo("pid"),iChubeiExp,iVal))

    local iChubeiExp = iChubeiExp + iVal
    self:SetData("chubeiexp",iChubeiExp)
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(self:GetInfo("pid"))
    oPlayer:PropChange("chubeiexp")
end


function CPlayerActiveCtrl:SetDurableSceneInfo(iMapId, mPos)
    local m = {
        map_id = iMapId,
        pos = mPos,
    }
    self:SetData("scene_info", m)
end

function CPlayerActiveCtrl:GetDurableSceneInfo()
    return self:GetData("scene_info")
end

function CPlayerActiveCtrl:GetNowWar()
    local m = self.m_mNowWarInfo
    if not m then
        return
    end
    local oWarMgr = global.oWarMgr
    return oWarMgr:GetWar(m.now_war)
end

function CPlayerActiveCtrl:GetNowScene()
    local m = self.m_mNowSceneInfo
    if not m then
        return
    end
    local oSceneMgr = global.oSceneMgr
    return oSceneMgr:GetScene(m.now_scene)
end

function CPlayerActiveCtrl:GetNowPos()
    local m = self.m_mNowSceneInfo
    if not m then
        return m
    end
    return m.now_pos
end

function CPlayerActiveCtrl:SetNowSceneInfo(mInfo)
    local m = self.m_mNowSceneInfo
    if not m then
        self.m_mNowSceneInfo = {}
        m = self.m_mNowSceneInfo
    end
    if mInfo.now_scene then
        m.now_scene = mInfo.now_scene
    end
    if mInfo.now_pos then
        m.now_pos = mInfo.now_pos
    end
end

function CPlayerActiveCtrl:ClearNowSceneInfo()
    self.m_mNowSceneInfo = {}
end

function CPlayerActiveCtrl:SetNowWarInfo(mInfo)
    local m = self.m_mNowWarInfo
    if not m then
        self.m_mNowWarInfo = {}
        m = self.m_mNowWarInfo
    end
    if mInfo.now_war then
        m.now_war = mInfo.now_war
    end
end

function CPlayerActiveCtrl:ClearNowWarInfo()
    self.m_mNowWarInfo = {}
end
