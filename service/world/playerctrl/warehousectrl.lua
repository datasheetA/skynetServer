--import module
local skynet = require "skynet"
local global = require "global"

local tableop = import(lualib_path("base.tableop"))

local datactrl = import(lualib_path("public.datactrl"))
local loaditem = import(service_path("item.loaditem"))
local itemnet = import(service_path("netcmd.item"))

CWHContainer = {}
CWHContainer.__index = CWHContainer
inherit(CWHContainer, datactrl.CDataCtrl)

function CWHContainer:New(pid)
    local o = super(CWHContainer).New(self, {pid = pid})
    o.m_Owner = pid
    o.m_Item = {}
    o.m_ID = 0
    return o
end

function CWHContainer:Save()
    local mData = {}

    local itemdata = {}
    for iPos,itemobj in pairs(self.m_Item) do
        itemdata[iPos] = itemobj:Save()
    end
    mData["itemdata"] = itemdata
    mData["data"] = self.m_mData
    return mData
end

function CWHContainer:Load(mData)
    mData = mData or {}
    local itemdata = mData["itemdata"] or {}
    for iPos,data in pairs(itemdata) do
        local itemobj = loaditem.LoadItem(data["SID"],data)
        assert(itemobj,string.format("item sid error:%s,%s,%s",self.m_Owner,data["SID"],iPos))
        if itemobj:Validate() then
            self.m_Item[iPos] = itemobj
        end
    end
    self.m_mData = mData["data"] or {}
end

function CWHContainer:SetName(sName)
    self:SetData("name",sName)
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(self.m_Owner)
    if not oPlayer then
        return
    end
    local mNet = {}
    mNet["wid"] = self.m_ID
    mNet["name"] = sName
    oPlayer:Send("GS2CWareHouseName",mNet)
end

function CWHContainer:Refresh()
    local mNet = {}
    mNet["wid"] = self.m_ID
    mNet["name"] = self:Name()
    local itemdata = {}
    for iPos,itemobj in pairs(self.m_Item) do
        table.insert(itemdata,itemobj:PackItemInfo())
    end
    mNet["itemdata"] = itemdata
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(self.m_Owner)
    if oPlayer then
        oPlayer:Send("GS2CRefreshWareHouse",mNet)
    end
end

function CWHContainer:Name()
    return self:GetData("name") or string.format("仓库%s",self.m_ID)
end

function CWHContainer:LimitSize()
    return 25
end

function CWHContainer:GetValidPos()
    for iPos = 1,self:LimitSize() do
        if not self.m_Item[iPos] then
            return iPos
        end 
    end
end

function CWHContainer:ValidStore(srcobj)
    if tableop.table_count(self.m_Item) < self:LimitSize() then
        return true
    end
    local iLastAmount = srcobj:GetAmount()
    local iMaxAmount = srcobj:GetMaxAmount()
    local iCanStoreAmount = 0
    for _,itemobj in pairs(self.m_Item) do
        if srcobj:SID() == itemobj:SID() then
            local iHaveAmount = itemobj:GetAmount()
            iCanStoreAmount = iCanStoreAmount + max(iMaxAmount-iHaveAmount,0)
        end
    end
    if srcobj:GetAmount() <= iCanStoreAmount then
        return true
    end
    return false
end

function CWHContainer:AddItem(srcobj)
    local iLast = srcobj:GetAmount()
    local iMaxAmount = srcobj:GetMaxAmount()
    for _,itemobj in pairs(self.m_Item) do
        if srcobj:SID() == itemobj:SID() then
             local iHave = itemobj:GetAmount()
             local iCanAdd = max(iMaxAmount - iHave,0)
            if iLast > 0 and iCanAdd > 0 then
                iCanAdd = min(iCanAdd,iLast)
                iLast = iLast - iCanAdd
                srcobj:AddAmount(-iAdd,"combine")
                itemobj:AddAmount(iAdd,"combine")
            end
        end
        if iLast <=0 then
            break
        end
    end
    if iLast <= 0 then
        return nil
    end
    local iPos = self:GetValidPos()
    assert(iPos,"CWHContainer AddToPos:%s %s",self.m_Owner,srcobj:Name())
    self:AddToPos(srcobj,iPos)
end

function CWHContainer:GetItem(iPos)
    return self.m_Item[iPos]
end

--存入仓库
function CWHContainer:WithStore(oSrcContainer,itemid)
    local itemobj = oSrcContainer:HasItem(itemid)
    if not itemobj then
        return
    end
    if not self:ValidStore(itemobj) then
        return
    end
    oSrcContainer:RemoveItem(itemobj)
    self:AddItem(itemobj)
end

--从仓库取出
function CWHContainer:WithDraw(iPos,oDestContainer)
    local itemobj = self:GetItem(iPos)
    if not itemobj then
        return
    end
    if not oDestContainer:ValidStorePos(itemobj) then
        return
    end
    self:RemoveItem(itemobj)
    local ret = oDestContainer:AddItem(itemobj)
    assert(not ret,string.format("warehousectrl WithDraw err:%s %s",self.m_Owner,iPos))
end

function CWHContainer:ArrangeChange(srcobj,iPos)
    local srcpos = srcobj.m_Pos
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

function CWHContainer:ChangeToPos(srcobj,iPos)
    self:Dirty()
    local srcpos = srcobj.m_Pos
    self.m_Item[iPos] = srcobj
    srcobj.m_Pos = iPos
    self:GS2CMoveItem(srcobj,iPos)
end

function CWHContainer:ItemChange(srcobj,destobj)
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

function CWHContainer:AddToPos(itemobj,iPos)
    self:Dirty()
    self.m_Item[iPos] = itemobj
    itemobj.m_Pos = iPos
    self:GS2CAddItem(itemobj)
end

function CWHContainer:RemoveItem(itemobj)
    self:Dirty()
    local iPos = itemobj.m_Pos
    self.m_Item[iPos] = nil
    itemobj.m_Pos = nil
    self:GS2CDelItem(itemobj)
end

function CWHContainer:GS2CAddItem(itemobj)
    local mNet = {}
    mNet["wid"] = self.m_ID
    mNet["itemdata"] = itemobj:PackItemInfo()
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(self.m_Owner)
    if oPlayer then
        oPlayer:Send("GS2CAddWareHouseItem",mNet)
    end
end

function CWHContainer:GS2CDelItem(itemobj)
    local mNet = {}
    mNet["wid"] = self.m_ID
    mNet["itemid"] = itemobj.m_ID
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(self.m_Owner)
    if oPlayer then
        oPlayer:Send("GS2CDelWareHouseItem",mNet)
    end
end

function CWHContainer:GS2CMoveItem(srcobj,destpos)
    local mNet = {}
    mNet["wid"] = self.m_ID
    mNet["id"] = itemobj.m_ID
    mNet["destpos"] = destpos
     local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(self.m_Owner)
    if oPlayer then
        oPlayer:Send("GS2CMoveItem",mNet)
    end
end

function CWHContainer:UnDirty()
    super(CWHContainer).UnDirty(self)
    for _,itemobj in pairs(self.m_Item) do
        if itemobj:IsDirty() then
            itemobj:UnDirty()
        end
    end
end

function CWHContainer:IsDirty()
    local bDirty = super(CWHContainer).IsDirty(self)
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

CWareHouseCtrl = {}
CWareHouseCtrl.__index = CWareHouseCtrl
inherit(CWareHouseCtrl,datactrl.CDataCtrl)

function CWareHouseCtrl:New(pid)
    local o = super(CWareHouseCtrl).New(self,pid)
    o.m_Owner = pid
    o.m_List = {}
    return o
end

function CWareHouseCtrl:Save()
    local mData = {}
    mWHData = {}
    for iNo,oWH in ipairs(self.m_List) do
        mWHData[iNo] = oWH:Save()
    end
    mData["warehouse"] = mWHData
    mData["data"] = self.m_mData
    return mData
end

function CWareHouseCtrl:Load(mData)
    mData = mData or {}
    for iNo,mWHData in pairs(mData) do
        local oWareHouse = CWHContainer:New(iNo)
        oWareHouse.m_ID = iNo
        oWareHouse:Load(mData)
        self.m_List[iNo] = oWareHouse
    end
    local iSize = self:DefaultSize()
    if tableop.table_count(self.m_List) < iSize then
        for iNo=1,iSize do
            local oWareHouse = CWHContainer:New(self.m_Owner)
            oWareHouse.m_ID = iNo
            self.m_List[#self.m_List+1] = oWareHouse
            if tableop.table_count(self.m_List) >= iSize then
                break
            end
        end
    end
    self.m_mData = mData["data"] or {}
end

function CWareHouseCtrl:DefaultSize()
    return 2
end

function CWareHouseCtrl:LimitSize()
    return 9
end

function CWareHouseCtrl:GetWareHouse(id)
    return self.m_List[id]
end

function CWareHouseCtrl:OnLogin()
    local mNet = {}
    mNet["size"] = #self.m_List
    local mName = {}
    for _,oWareHouse  in ipairs(self.m_List) do
        table.insert(mName,oWareHouse:Name())
    end
    mName["namelist"] = mName
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(self.m_Owner)
    if not oPlayer then
        return
    end
    oPlayer:Send("GS2CWareHouseLogin",mNet)
end

function CWareHouseCtrl:ValidBuyWareHouse()
    if #self.m_List >= self:LimitSize() then
        return false
    end
    return true
end

function CWareHouseCtrl:BuyWareHouse()
    if not self:ValidBuyWareHouse() then
        return
    end
    self:Dirty()
    local iNo = #self.m_List + 1
    local oWareHouse = CWHContainer:New()
    oWareHouse.m_ID = iNo
    self.m_List[iNo] = oWareHouse
    oWareHouse:Refresh()
end

function CWareHouseCtrl:UnDirty()
    super(CWareHouseCtrl).UnDirty(self)
    for _,oWareHouse in pairs(self.m_List) do
        if oWareHouse:IsDirty() then
            oWareHouse:UnDirty()
        end
    end
end

function CWareHouseCtrl:IsDirty()
    local bDirty = super(CWareHouseCtrl).IsDirty(self)
   if bDirty then
        return true
    end
    for _,oWareHouse in pairs(self.m_List) do
        if oWareHouse:IsDirty() then
            return true
        end
    end
    return false
end