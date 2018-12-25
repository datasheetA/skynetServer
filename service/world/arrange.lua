local global = require "global"
local skynet = require "skynet"

local tableop = import(lualib_path("base.tableop"))

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

    for _,itemobj in pairs(oContainer.m_Item) do
        table.insert(ItemList,itemobj)
    end
    
    table.sort(ItemList,SortFunc)

    for iPos,srcobj in ipairs(ItemList) do
        oContainer:ArrangeChange(srcobj,iPos)
    end
end