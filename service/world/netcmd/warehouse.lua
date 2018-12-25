local global = require "global"
local skynet = require "skynet"
local extend = require "base/extend"
local tableop = require "base.tableop"

local timeop = import(lualib_path("base.timeop"))
local stringop = import(lualib_path("base.stringop"))

local max = math.max
local min = math.min

function C2GSSwitchWareHouse(oPlayer,mData)
    local wid = mData["wid"]
    local oWH = oPlayer.m_oWHCtrl:GetWareHouse(wid)
    if not oWH then
        return
    end
    oWH:Refresh()
end

function C2GSBuyWareHouse(oPlayer,mData)
    local iSilver = 100 * 10000
    if not oPlayer.m_oActiveCtrl:ValidSilver(iSilver,sReason) then
        return
    end
    local oWHCtrl = oPlayer.m_oWHCtrl
    if oWHCtrl:ValidBuyWareHouse() then
        return
    end
    oPlayer.m_oActiveCtrl:ResumeSilver(iSilver,"购买仓库")
    oPlayer.m_oWHCtrl:BuyWareHouse()
    local oNotifyMgr = global.oNotifyMgr
    oNotifyMgr:Notify(oPlayer.m_iPid,"仓库购买成功")
end

function C2GSRenameWareHouse(oPlayer,mData)
    local wid = mData["wid"]
    local sName = mData["name"]
    local oWHCtrl = oPlayer.m_oWHCtrl
    local oWareHouse = oPlayer.m_oWHCtrl:GetWareHouse(wid)
    if not oWareHouse then
        return
    end
    oWareHouse:SetName(sName)
    local oNotifyMgr = global.oNotifyMgr
    oNotifyMgr:Notify(oPlayer.m_iPid,"改名成功")
end

function C2GSWareHouseWithStore(oPlayer,mData)
    local wid = mData["wid"]
    local itemid = mData["itemid"]
    local oWareHouse = oPlayer.m_oWHCtrl:GetWareHouse(wid)
    if not oWareHouse then
        return
    end
    oWareHouse:WithStore(oPlayer.m_oItemCtrl,itemid)
end

function C2GSWareHouseWithDraw(oPlayer,mData)
    local wid = mData["wid"]
    local iPos = mData["pos"]
    local oWareHouse = oPlayer.m_oWHCtrl:GetWareHouse(wid)
    if not oWareHouse then
        return
    end
    oWareHouse:WithDraw(iPos,oPlayer.m_oItemCtrl)
end

function C2GSWareHouseArrange(oPlayer,mData)
    local wid = mData["wid"]
    local oWareHouse = oPlayer.m_oWHCtrl:GetWareHouse(wid)
    if not oWareHouse then
        return
    end
    local oPubMgr = global.oPubMgr
    oPubMgr:Arrange(oPlayer.m_iPid,oWareHouse)
end