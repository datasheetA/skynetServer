--import module
local global = require "global"

local function SortItemFunc(oItem1,oItem2)
    if oItem1:SortNo() ~= oItem2:SortNo() then
        return oItem1:SortNo() < oItem2:SortNo()
    else
        if oItem1:SID() ~= oItem2:SID() then
            return oItem1:SID() < oItem2:SID()
        else
            if oItem1:GetAmount() ~= oItem2:GetAmount() then
                return oItem1:GetAmount() > oItem2:GetAmount()
            else
                return oItem1.m_ID < oItem2.m_ID
            end
        end
    end
    return false
end

function NewPubMgr()
    local o = CPublicMgr:New()
    return o
end

CPublicMgr = {}
CPublicMgr.__index = CPublicMgr
inherit(CPublicMgr, logic_base_cls())

function CPublicMgr:New()
    local o = super(CPublicMgr).New(self)
    return o
end

function CPublicMgr:OnlineExecute(pid,sFunc,mArgs)
    local oWorldMgr = global.oWorldMgr
    oWorldMgr:LoadRW(pid,function (oRW)
        oRW:AddFunc(sFunc,mArgs)
    end)
end

function CPublicMgr:Arrange(pid,oContainer)
    local ItemList = {}

    for _,itemobj in pairs(oContainer.m_Item) do
        table.insert(ItemList,itemobj)
    end
    
    table.sort(ItemList,SortItemFunc)

    for iPos,srcobj in ipairs(ItemList) do
        oContainer:ArrangeChange(srcobj,iPos)
    end
end