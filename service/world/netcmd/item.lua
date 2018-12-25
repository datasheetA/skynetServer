local global = require "global"
local skynet = require "skynet"
local extend = require "base/extend"

local timeop = import(lualib_path("base.timeop"))
local arrange = import(service_path("arrange"))
local stringop = import(lualib_path("base.stringop"))
local loaditem = import(service_path("item.loaditem"))

local max = math.max
local min = math.min

-----------------------------------------------C2GS--------------------------------------------
function C2GSItemUse(oPlayer, mData)
    local itemid = mData["itemid"]
    local target = mData["target"]
    local itemobj = oPlayer.m_oItemCtrl:HasItem(itemid)
    if not itemobj then
        return
    end
    itemobj:Use(oPlayer,target)
end

function C2GSItemInfo(oPlayer,mData)
    local itemid = mData["itemid"]
    local itemobj = oPlayer.m_oItemCtrl:HasItem(itemid)
    if not itemobj then
        return
    end
    itemobj:Refresh()
end

function C2GSItemMove(oPlayer,mData)
    local itemid = mData["itemid"]
    local iPos = mData["iPos"]
    local srcobj = oPlayer.m_oItemCtrl:HasItem(itemid)
    if not srcobj then
        return
    end
    local destobj = oPlayer.m_oItemCtrl:GetItem(iPos)
    if not destobj then
        oPlayer.m_oItemCtrl:ChangeToPos(srcobj,iPos)
    else
        oPlayer.m_oItemCtrl:ItemChange(srcobj,destobj)
    end
end

function C2GSItemArrage(oPlayer,mData)
    arrange.Arrange(oPlayer.m_oItemCtrl)
end

function C2GSAddItemExtendSize(oPlayer,mData)
    local iSize = mData["size"]
    if not extend.Table.find({5,10},iSize) then
        return
    end
    local oContainer = oPlayer.m_oItemCtrl
    if not oContainer then
        return
    end
    if not oContainer:CanAddExtendSize() then
        return
    end
    oPlayer.m_oItemCtrl:AddExtendSize(iSize)
end

function C2GSDeComposeItem(oPlayer,mData)
    local itemid = mData["id"]
    local iAmount = mData["iAmount"]
    local itemobj = oPlayer.m_oItemCtrl:HasItem(itemid)
    if not itemobj then
        return
    end
    local iSrcSID = itemobj:SID()
    if oPlayer:GetItemAmount(iSrcSID) < iAmount then
        return
    end
   
    local ItemList = {}
    local sDeComPosInfo = itemobj:DeComposeInfo()
    local iDestSID,sArg = string.match(sDeComPosInfo,"(%d+)(.+)")
    iDestSID = tonumber(iDestSID)
    assert(iDestSID,string.format("DeCompose err:%d %s",itemobj:SID(),sDeComPosInfo))
    local iSumAmount = iAmount
    local mArg
    if sArg then
        sArg = string.sub(sArg,2,#sArg-1)
        mArg = stringop.split_string(sArg,",")
        for _,sArg in pairs(mArg) do
            local key,value = string.match(sArg,"(.+)=(.+)")
            if key == "Amount" then
                iSumAmount = tonumber(value) * iAmount
            end
        end
    end

    ItemList[iDestSID] = iSumAmount
    if not oPlayer:ValidGive(ItemList) then
        return
    end
    if not oPlayer:RemoveItemAmount(iSrcSID,iAmount) then
        return
    end

    while(iSumAmount > 0) do
        local itemobj = loaditem.Create(iDestSID)
        local iMaxAmount = itemobj:GetMaxAmount()
        local iAddAmount = min(iMaxAmount,iSumAmount)
        iSumAmount = iSumAmount - iMaxAmount
        itemobj:SetAmount(iAddAmount)
        oPlayer:RewardItem(itemobj,"DeComposeItem")
        for _,sArg in pairs(mArg) do
            local key,value = string.match(sArg,"(.+)=(.+)")
            if key ~= "Amount" then
                local sKey = string.format("m_",key)
                if itemobj[sKey] then
                    itemobj[sKey] = value
                else
                    itemobj:SetData(key,value)
                end
            end
        end
         if iSumAmount <= 0 then
            break
        end
    end
end

function C2GSComposeItem(oPlayer,mData)
    local itemid = mData["id"]
    local iAmount = mData["iAmount"]
    local itemobj = oPlayer.m_oItemCtrl:HasItem(itemid)
    if not itemobj then
        return
    end
    local iSrcSID = itemobj:SID()
    if oPlayer:GetItemAmount(iSrcSID) < iAmount then
        return
    end
    local iCostAmount = itemobj:ComposeAmount()
    if iAmount == 0 then
        return
    end
    if  iAmount % iCostAmount ~= 0 then
        return
    end

    local iSize = math.floor(iAmount // iCostAmount)

    local ItemList = {}
    local sComPosInfo = itemobj:ComposeItemInfo()
    local iDestSID,sArg = string.match(sComPosInfo,"(%d+)(.+)")
    iDestSID = tonumber(iDestSID)
    assert(iDestSID,string.format("DeCompose err:%d %s",itemobj:SID(),sComPosInfo))
    local iSumAmount = iSize
    local mArg
    if sArg then
        sArg = string.sub(sArg,2,#sArg-1)
        mArg = stringop.split_string(sArg,",")
        for _,sArg in pairs(mArg) do
            local key,value = string.match(sArg,"(.+)=(.+)")
            if key == "Amount" then
                iSumAmount = tonumber(value) * iSize
            end
        end
    end

    ItemList[iDestSID] = iSumAmount
    if not oPlayer:ValidGive(ItemList) then
        return
    end
    if not oPlayer:RemoveItemAmount(iSrcSID,iAmount) then
        return
    end

     while(iSumAmount > 0) do
        local itemobj = loaditem.Create(iDestSID)
        local iMaxAmount = itemobj:GetMaxAmount()
        local iAddAmount = min(iMaxAmount,iSumAmount)
        iSumAmount = iSumAmount - iMaxAmount
        itemobj:SetAmount(iAddAmount)
        oPlayer:RewardItem(itemobj,"DeComposeItem")
        for key,value in pairs(mArg) do
            if key ~= "Amount" then
                local sKey = string.format("m_",key)
                if itemobj[sKey] then
                    itemobj[sKey] = value
                else
                    itemobj:SetData(key,value)
                end
            end
        end
         if iSumAmount <= 0 then
            break
        end
    end
end