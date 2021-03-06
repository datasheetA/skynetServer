local global = require "global"
local skynet = require "skynet"
local interactive =  require "base.interactive"

local datactrl = import(lualib_path("public.datactrl"))
local timeop = import(lualib_path("base.timeop"))
local itemnet = import(service_path("netcmd.item"))
local itemdefines = import(service_path("item.itemdefines"))


local ITEMID = ITEMID  or 1

function NewItem(sid)
    local o = CItem:New(sid)
    return o
end

CItem = {}
CItem.__index = CItem
inherit(CItem,datactrl.CDataCtrl)

CItem.m_ItemType = "base"

function CItem:New(sid)
    local o = super(CItem).New(self)
    o:Init(sid)
    return o
end

function CItem:Init(sid)
    self.m_ID = self:DispitchItemID()
    self.m_SID = sid
    local mData = self:GetItemData()
    self.m_iAmount = 1
    self.m_iItemLevel = mData["quality"] or 1
    self.m_iCreateTime = timeop.get_time()
    self.m_mData = mData
end

function CItem:Release()
    self:DelTimeCb("timeout")
end

function CItem:Setup()
    if self:GetData("Time") then
        local iTime = self:GetData("Time",0) - timeop.get_time()
        if iTime > 0 then
            self:DelTimeCb("timeout")
            self:AddTimeCb("timeout",iTime*1000,function () self:TimeOut() end)
        else
            self:TimeOut()
        end
    end
end

function CItem:TimeOut()
    self:Dirty()
    local iAmount = self:GetAmount()
    self:AddAmount(-iAmount,"TimeOut")
end

function CItem:SetTimer(iSec)
    local iEndTime = timeop.get_time() + iSec
    self:SetData("Time",iEndTime)
    if iSec > 0 then
        self:DelTimeCb("timeout")
        self:AddTimeCb("timeout",iSec*1000,function () self:TimeOut() end)
    else
        self:TimeOut()
    end
end

function CItem:Validate()
    return true
end

function CItem:DispitchItemID()
    local itemid = ITEMID
    ITEMID = ITEMID + 1
    return itemid
end

function CItem:GetItemData()
    local res = require "base.res"
    local mData = res["daobiao"]["item"][self.m_ItemType]
    assert(mData,string.format("itembase GetItemData err:%d %s",self.m_SID,self.m_ItemType))
    return mData[self.m_SID]
end

function CItem:Load(mData)
    if not mData then
        return
    end
    self.m_Amount = mData["Amount"]
    self.m_SID = mData["SID"]
    self.m_Data = mData["Data"]
    self.m_iItemLevel = mData["ItemLevel"]
    self.m_iCreateTime = mData["CreateTime"]

    self:Dirty()
end

function CItem:Save()
    local mData = {}
    mData["Amount"] = self.m_Amount
    mData["SID"] = self.m_SID
    mData["Data"] = self.m_Data
    mData["ItemLevel"] = self.m_iItemLevel
    mData["CreateTime"] = self.m_iCreateTime
    return mData
end

function CItem:Create( ... )
    --
end

function CItem:SID()
    return self.m_SID
end

function CItem:TaskSID()
    local iTaskSID = self.m_mData["taskid"]
    if iTaskSID == 0 then
        return self.m_SID
    end
    return iTaskSID
end

function CItem:Shape()
    return self.m_SID
end

function CItem:Name()
    return self.m_mData["name"]
end

function CItem:GetMaxAmount()
    return self.m_mData["maxOverlay"]
end

function CItem:GetAmount()
    return self.m_Amount or 1
end

function CItem:GetTraceName()
    local iOwner,iTraceNo = table.unpack(self:GetData("TraceNo",{}))
   return string.format("%s %d:<%d,%d>",self:Name(),self:SID(),iOwner,iTraceNo)
end

function CItem:SetAmount(iAmount)
    self:Dirty()
    self.m_Amount = iAmount
    if self.m_Amount <= 0 then
        if self.m_Container then
            self.m_Container:RemoveItem(self)
        end
    end
end

function CItem:AddAmount(iAmount,sReason)
    self:Dirty()
    self.m_Amount = self.m_Amount + iAmount
    self:GS2CItemAmount()
    if self.m_Amount <= 0 then
        if self.m_Container then
            self.m_Container:RemoveItem(self)
        end
    else
        if iAmount > 0 and self:IsQuickUse() then
             local iOwner = self:GetOwner()
             self:GS2CItemQuickUse(self.m_ID)
        end
    end
end

function CItem:GetOwner()
    if self.m_Container then
        return self.m_Container.m_Owner
   end
end

function CItem:IsTimeItem()
    if self:GetData("Time",0) ~= 0 then
        return true
    end
    return false
end

function CItem:Bind(iOwner)
    self:SetData("Bind",iOwner)
end

function CItem:IsBind()
    if self:GetData("Bind",0) ~= 0 then
        return true
    end
    return false
end

function CItem:ValidUse()
    local iAmount = self:GetAmount()
    local iNeedAmount = self:GetUseCostAmount()
    if iAmount < iNeedAmount then
        return false
    end
    return true
end

function CItem:Use(who,target)
    if not self:ValidUse() then
        return
    end
    self:TrueUse(who,target)
end

function CItem:TrueUse(who,target)
    --
end

--
function CItem:GetUseCostAmount()
    local mData = self:GetItemData()
    local iAmount = mData["usecost"] or 1
    return iAmount
end

--同种类型道具数目
function CItem:GetItemAmount()
    if self.m_Container then
        return self.m_Container:GetItemAmount(self:Shape())
    end
end

--品质
function CItem:ItemLevel()
    return self.m_iItemLevel or 1
end

--是否回收
function CItem:ValidRecycle()
    return false
end

function CItem:SortNo()
    local iNo = self.m_mData["sort"] or 100
    return iNo
end

--key值
function CItem:Key()
    local iKey = 0
    if self:IsBind() then
        iKey = iKey | itemdefines.ITEM_KEY_BIND
    end
    if self:IsTimeItem() then
        iKey = iKey | itemdefines.ITEM_KEY_TIME
    end
    return iKey
end

function CItem:ApplyInfo()
    local mData = {}
    return mData
end

function CItem:Desc()
    return ""
end

function CItem:Refresh()
    local iOwner = self:GetOwner()
    itemnet.GS2CAddItem(iOwner,self)
end

--快捷使用
function CItem:IsQuickUse( ... )
    local iQuickUse = self.m_mData["quickable"] or 0
    if iQuickUse == 1 then
        return true
    end
    return false
end

--能否给予
function CItem:IsGive()
    local iGive = self.m_mData["giftable"] or 0
    if iGive == 1 then
        return true
    end
    return false
end

--能否摆摊
function CItem:IsStore()
    local iStore = self.m_mData["stallable"] or 0
    if iStore == 1 then
        return true
    end
    return false
end

function CItem:ValidMoveWH()
    local iCanStore = self.m_mData["canStore"] or 1
    if iCanStore == 1 then
        return true
    end
    return false
end

--合成分解信息
function CItem:DeComposeInfo()
    local mData = self:GetItemData()
    return mData["deCompose"]
end

function CItem:ComposeAmount()
    local mData = self:GetItemData()
    return mData["ComposeAmount"]
end

function CItem:ComposeItemInfo()
    local mData = self:GetItemData()
    return mData["ComposeItem"]
end

function CItem:PackItemInfo()
     local mNet = {}
    mNet["id"] = self.m_ID
    mNet["sid"] = self:SID()
    mNet["pos"] = self.m_Pos
    mNet["name"] = self:Name()
    mNet["itemlevel"] = self:ItemLevel()
    mNet["amount"] = self:GetAmount()
    mNet["key"] = self:Key()
    if self:IsTimeItem() then
        mNet["time"] = self:Query("Time") - timeop.get_time()
    end
    mNet["apply_info"] = self:ApplyInfo()
    mNet["desc"] = self:Desc()
    return mNet
end

function CItem:GS2CItemAmount()
    local mNet = {}
    mNet["id"] = self.m_ID
    mNet["amount"] = self:GetAmount()
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(self:GetOwner())
    if oPlayer then
        oPlayer:Send("GS2CItemAmount",mNet)
    end
end

function CItem:OnAddToPos(iPos)
    if self:IsQuickUse() then
        self:GS2CItemQuickUse()
    end
end

function CItem:GS2CItemQuickUse()
    local mNet = {}
    mNet["id"] = self.m_ID
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(self:GetOwner())
    if oPlayer then
        oPlayer:Send("GS2CItemQuickUse",mNet)
    end
end