local global = require "global"
local skynet = require "skynet"

local max = math.max
local min = math.min

--道具整理

local function SortFunc(oItem1,oItem2)
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

function Arrange(oContainer)
    local ItemList = {}
    --先叠加
    for _,srcobj in pairs(oContainer.m_Item) do
        local sid = srcobj:SID()
        local iLast = srcobj:GetAmount()
        for _,destobj in pairs(oContainer.m_Item) do
            if sid == destobj:SID() and srcobj.m_ID ~= destobj.m_ID then
                local iHave = destobj:GetAmount()
                local iMaxAmount = destobj:GetMaxAmount()
                local iAdd = max(iMaxAmount-iHave,0)
                iAdd = min(iAdd,iLast)
                if iAdd > 0 then
                     iLast = iLast - iAdd
                     srcobj:AddAmount(-iAdd,"arrange")
                     destobj:AddAmount(iAdd,"arrange")
                end
            end
            if iLast <= 0 then
                break
            end
        end
    end

    for _,itemobj in pairs(oContainer.m_Item) do
        table.insert(ItemList,itemobj)
    end
    
    table.sort(ItemList,SortFunc)

    for iPos,srcobj in ipairs(ItemList) do
        oContainer:ArrangeChange(srcobj,iPos)
    end
end