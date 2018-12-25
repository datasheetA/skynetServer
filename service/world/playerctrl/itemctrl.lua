local skynet = require "skynet"
local global = require "global"

local tableop = require "base.tableop"

local datactrl = import(lualib_path("public.datactrl"))
local loaditem = import(service_path("item.loaditem"))
local itemnet = import(service_path("netcmd.item"))

local EQUIP_START = 1
local EQUIP_END = 100

local ITEM_START = 101
local ITEM_END = 400
local ITEM_SIZE = 25
local MAX_ITEM_SIZE = 250

local max = math.max
local min = math.min

CItemCtrl = {}
CItemCtrl.__index = CItemCtrl
inherit(CItemCtrl, datactrl.CDataCtrl)

function CItemCtrl:New(pid)
    local o = super(CItemCtrl).New(self, {pid = pid})
    o:Init(pid)
    return o
end

function CItemCtrl:Init(pid)
    self.m_Owner = pid
    self.m_Item = {}
    self.m_ItemID = {}
    self.m_TraceNo = 1
    self.m_ExtendSize = 0
    self.m_Size = ITEM_SIZE
end

function CItemCtrl:Save()
    local mData = {}

    local itemdata = {}
    for iPos,itemobj in pairs(self.m_Item) do
        itemdata[iPos] = itemobj:Save()
    end
    mData["itemdata"] = itemdata
    mData["trace_no"] = self.m_TraceNo
    mData["extendsize"] = self.m_ExtendSize
    return mData
end

function CItemCtrl:Load(mData)
    mData = mData or {}

    local itemdata = mData["itemdata"] or {}
    for iPos,data in pairs(itemdata) do
        local itemobj = loaditem.LoadItem(data["SID"],data)
        assert(itemobj,string.format("item sid error:%s,%s,%s",self.m_Owner,data["SID"],iPos))
        if itemobj:Validate() then
            self.m_Item[iPos] = itemobj
            self.m_ItemID[itemobj.m_ID] = itemobj
            itemobj.m_Pos = iPos
            itemobj.m_Container = self
        else
            --
        end
    end
    self.m_TraceNo = mData["traceno"] or self.m_TraceNo
    self.m_ExtendSize = mData["extendsize"] or self.m_ExtendSize

    self:Dirty()
end

function CItemCtrl:DispatchTraceNo()
    self:Dirty()
    local iTraceNo = self.m_TraceNo
    self.m_TraceNo = self.m_TraceNo + 1
    return iTraceNo
end

function CItemCtrl:UnDirty()
    super(CItemCtrl).UnDirty(self)
    for _,itemobj in pairs(self.m_Item) do
        if itemobj:IsDirty() then
            itemobj:UnDirty()
        end
    end
end

function CItemCtrl:IsDirty()
    local bDirty = super(CItemCtrl).IsDirty(self)
   if bDirty then
        return true
    end
    for _,itemobj in pairs(self.m_Item) do
        if itemobj:IsDirty() then
            return true
        end
    end
    return false
end

function CItemCtrl:GetSize()
    return self.m_Size + self.m_ExtendSize
end

function CItemCtrl:GetExtendSize()
    return self.m_ExtendSize
end

function CItemCtrl:GetEndPos()
    return ITEM_START + self:GetSize() - 1
end

function CItemCtrl:AddExtendSize(iSize)
    self:Dirty()
    iSize = iSize or 5
    self.m_ExtendSize = self.m_ExtendSize + iSize
    local mNet = {}
    mNet["extsize"] = self.m_ExtendSize
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(self.m_Owner)
    if oPlayer then
        oPlayer:Send("GS2CItemExtendSize",mNet)
    end
end

function CItemCtrl:CanAddExtendSize( )
    local iSize = self:GetSize()
    if iSize >= MAX_ITEM_SIZE then
        return false
    end
    return true
end

function CItemCtrl:GetValidPos()
    local endpos = self:GetEndPos()
    for iPos = ITEM_START,endpos do
        if not self.m_Item[iPos] then
            return iPos
        end
    end
end

function CItemCtrl:GetCanUseSpaceSize()
    local endpos = self:GetEndPos()
    local iSize = 0
    for iPos = ITEM_START,endpos do
        if not self.m_Item[iPos] then
            iSize = iSize + 1
        end
    end
    return iSize
end

function CItemCtrl:ItemList()
    return self.m_Item
end

function CItemCtrl:GetShapeItem(sid)
    local ItemList = {}
    for _,itemobj in pairs(self.m_Item) do
        if itemobj:SID() == sid then
            table.insert(ItemList,itemobj)
        end
    end
    return ItemList
end

function CItemCtrl:GetItemObj(sid)
    for _,itemobj in pairs(self.m_Item) do
        if itemobj.m_SID == sid then
            return itemobj
        end
    end
end

function CItemCtrl:HasItem(itemid)
    return self.m_ItemID[itemid]
end

function CItemCtrl:GetItem(iPos)
    return self.m_Item[iPos]
end

function CItemCtrl:AddItem(srcobj)
    self:Dirty()
    local iLast = srcobj:GetAmount()
    local iMaxAmount = srcobj:GetMaxAmount()
    for _,itemobj in pairs(self.m_Item) do
        if srcobj:SID() == itemobj:SID() then
             local iHave = itemobj:GetAmount()
             local iAdd = max(iMaxAmount - iHave,0)
            if iLast > 0 and iAdd > 0 then
                iAdd = min(iAdd,iLast)
                iLast = iLast - iAdd
                srcobj:AddAmount(-iAdd,"combine")
                itemobj:AddAmount(iAdd,"combine")
            end
        end
    end
    if iLast <= 0 then
        return nil
    end
    local iPos = self:GetValidPos()
    if not iPos then
        return srcobj
    end
    self:AddToPos(srcobj,iPos)
end

--能否移入
function CItemCtrl:ValidStorePos(srcobj)
    local iPos = self:GetValidPos()
    if iPos then
        return true
    end
    local iMaxAmount = srcobj:GetMaxAmount()
    local iCanAddAmount = 0
    for _,itemobj in pairs(self.m_Item) do
        if srcobj:SID() == itemobj:SID() then
            local iHaveAmount = itemobj:GetAmount()
            iCanAddAmount = iCanAddAmount + max(iMaxAmount-iHaveAmount,0)
        end
    end
    if srcobj:GetAmount() <= iCanAddAmount then
        return true
    end
    return false
end

function CItemCtrl:AddToPos(itemobj,iPos)
    self.m_Item[iPos] = itemobj
    self.m_ItemID[itemobj.m_ID] = itemobj
    itemobj.m_Pos = iPos
    itemobj.m_Container = self
    if not itemobj:GetData("TraceNo") then
        local iTraceNo = self:DispatchTraceNo()
        itemobj:SetData("TraceNo",{self.m_Owner,iTraceNo})
    end
    self:GS2CAddItem(itemobj)
    itemobj:OnAddToPos(iPos)
end

function CItemCtrl:RemoveItem(itemobj)
    self:Dirty()
    local iPos = itemobj.m_Pos
    self.m_Item[iPos] = nil
    self.m_Item[itemobj.m_ID] = nil
    self:GS2CDelItem(itemobj)
    itemobj.m_Pos = nil
    itemobj.m_Container = nil
end

function CItemCtrl:ItemChange(srcobj,destobj)
    self:Dirty()
    self:GS2CDelItem(destobj)
    local srcpos = srcobj.m_Pos
    local destpos = destobj.m_Pos
    self.m_Item[srcpos] = destobj
    self.m_Item[destpos] = srcobj
    srcobj.m_Pos = destpos
    destobj.m_Pos = srcpos
    self:GS2CMoveItem(srcobj,destpos)
    self:GS2CAddItem(destobj)
end

function CItemCtrl:ChangeToPos(srcobj,iPos)
    self:Dirty()
    local srcpos = srcobj.m_Pos
    self.m_Item[srcpos] = nil
    self.m_Item[iPos] = srcobj
    srcobj.m_Pos = iPos
    self:GS2CMoveItem(srcobj,iPos)
end

function CItemCtrl:ArrangeChange(srcobj,iPos)
    local srcpos = srcobj.m_Pos
    if iPos < ITEM_START then
        iPos = iPos + ITEM_START - 1
    end
    if srcpos == iPos then
        return
    end
    local destobj = self:GetItem(iPos)
    if not destobj then
        self:ChangeToPos(srcobj,iPos)
    else
        self:ItemChange(srcobj,destobj)
    end
end

function CItemCtrl:RemoveItemAmount(sid,iAmount)
    local iHaveAmount = self:GetItemAmount(sid)
    if iHaveAmount < iAmount then
        return false
    end
    local ItemList = self:GetShapeItem(sid)
    for _,itemobj in pairs(ItemList) do
        local iSubAmount = itemobj:GetAmount()
        iSubAmount = min(iSubAmount,iAmount)
        iAmount = iAmount - iSubAmount
        itemobj:AddAmount(-iSubAmount)
        if iAmount <= 0 then
            break
        end
    end
    if iAmount > 0 then
        return false
    end
    return true
end

function CItemCtrl:GetItemAmount(sid)
    local iAmount = 0
    for _,itemobj in pairs(self.m_Item) do
        if itemobj:SID() == sid then
            iAmount = iAmount + itemobj:GetAmount()
        end
    end
    return iAmount
end

--ItemList:{sid:amount}
function CItemCtrl:ValidGive(ItemList)
    local iNeedSpace = 0
    for sid,iAmount in pairs(ItemList) do
        local ItemList = self:GetShapeItem(sid)
        local iCanAddAmount = 0
        local itemobj = loaditem.GetItem(sid)
        local iMaxAmount = itemobj:GetMaxAmount()
        for _,itemobj in pairs(ItemList) do
            local iAddAmount = max(iMaxAmount-itemobj:GetAmount(),0)
            if iAddAmount > 0 then
                iCanAddAmount = iCanAddAmount + iAddAmount
            end
        end
        iItemAmount = max(iAmount - iCanAddAmount,0)
        if iItemAmount > 0 then
            local iSize = iItemAmount // iMaxAmount + 1
            if iItemAmount // iMaxAmount == 0 then
                iSize = iItemAmount // iMaxAmount
            end
            iNeedSpace = iNeedSpace + iSize
        end
    end
    local iHaveSpace = self:GetCanUseSpaceSize()
    if iHaveSpace < iNeedSpace then
        return false
    end
    return true
end

function CItemCtrl:GiveItem(ItemList,sReason)
    for sid,iAmount in pairs(ItemList) do
        while(iAmount > 0) do
            local itemobj = loaditem.Create(sid)
            local iAddAmount = min(itemobj:GetMaxAmount(),iAmount)
            iAmount = iAmount - iAddAmount
            itemobj:SetAmount(iAddAmount)
            self:AddItem(itemobj)
            if iAmount <= 0 then
                break
            end
        end
    end
end

function CItemCtrl:OnLogin()
    local mNet = {}
    local itemdata = {}
    for iPos,itemobj in pairs(self.m_Item) do
        table.insert(itemdata,itemobj:PackItemInfo())
    end
    mNet["itemdata"] = itemdata
    mNet["extsize"] = self:GetExtendSize()
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(self.m_Owner)
    if oPlayer then
        oPlayer:Send("GS2CLoginItem",mNet)
    end
end

function CItemCtrl:GS2CAddItem(itemobj)
    local mNet = {}
    local itemdata = itemobj:PackItemInfo()
    mNet["itemdata"] = itemdata
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(self.m_Owner)
    if oPlayer then
        oPlayer:Send("GS2CAddItem",mNet)
    end
end

function CItemCtrl:GS2CDelItem(itemobj)
    local mNet = {}
    mNet["id"] = itemobj.m_ID
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(self.m_Owner)
    if oPlayer then
        oPlayer:Send("GS2CDelItem",mNet)
    end
end

function CItemCtrl:GS2CMoveItem(itemobj,destpos)
    local mNet = {}
    mNet["id"] = itemobj.m_ID
    mNet["destpos"] = destpos
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(self.m_Owner)
    if oPlayer then
        oPlayer:Send("GS2CMoveItem",mNet)
    end
end