--import module

local global = require "global"
local skynet = require "skynet"
local interactive = require "base.interactive"
local extend = require "base/extend"

local loaditem = import(service_path("item/loaditem"))
local itemnet = import(service_path("netcmd/item"))
local timeop = import(lualib_path("base/timeop"))


function NewGMMgr(...)
    local o = CGMMgr:New(...)
    return o
end

Commands = {}

function Commands.setgrade(oMaster, i)
    oMaster.m_oBaseCtrl:SetData("grade", i)
end

function Commands.testwar(oMaster, lTargets)
    local oWarMgr = global.oWarMgr
    local oWorldMgr = global.oWorldMgr
    local oWar = oWarMgr:CreateWar({})

    if #lTargets <= 0 then
        return
    end

    local lRes = {}
    for _, v in ipairs(lTargets) do
        local o = oWorldMgr:GetOnlinePlayerByPid(v)
        if o then
            table.insert(lRes, o)
        end
    end
    local iMiddle = math.floor(#lRes/2 + 1)

    oWarMgr:EnterWar(oMaster, oWar:GetWarId(), {camp_id = 1}, true)
    for i = 1, iMiddle do
        local o = lRes[i]
        oWarMgr:EnterWar(o, oWar:GetWarId(), {camp_id = 2}, true)
    end
    for i = iMiddle + 1, #lRes do
        local o = lRes[i]
        oWarMgr:EnterWar(o, oWar:GetWarId(), {camp_id = 1}, true)
    end

    oWarMgr:StartWar(oWar:GetWarId())
end

function Commands.wartimeover(oMaster)
    local oWar = oMaster.m_oActiveCtrl:GetNowWar()
    if oWar then
        oWar:TestCmd("wartimeover", oMaster:GetPid(), {})
    end
end

function Commands.clone(oMaster,sid,iAmount)
    local itemobj = loaditem.GetItem(sid)
    if not itemobj then
        return
    end
   
    while(iAmount>0) do
        local itemobj = loaditem.Create(sid)
        local iMaxAmount = itemobj:GetMaxAmount()
        local iAddAmount = math.min(iAmount,iMaxAmount)
        iAmount = iAmount - iAddAmount
        itemobj:SetAmount(iAddAmount)
        oMaster:RewardItem(itemobj,"clone")
    end
end

function Commands.rewardgold(oMaster,iVal)
    oMaster:RewardGold(iVal,"gm")
end

function Commands.rewardsilver(oMaster,iVal)
    oMaster:RewardSilver(iVal,"gm")
end

function Commands.clearall(oMaster)
    for _,itemobj in pairs(oMaster.m_oItemCtrl.m_Item) do
        oMaster.m_oItemCtrl:RemoveItem(itemobj)
    end
end

CGMMgr = {}
CGMMgr.__index = CGMMgr
inherit(CGMMgr, logic_base_cls())

function CGMMgr:New()
    local o = super(CGMMgr).New(self)
    return o
end

function CGMMgr:ReceiveCmd(oMaster, sCmd)
    local mMatch = {}
    mMatch["{"] = "}"

    local iState = 1
    local iBegin = 1
    local iEnd = 0

    local sMatch = nil
    local iMatch = 0

    local lArgs = {}
    for i = 1, #sCmd do
        local c = index_string(sCmd, i)

        if iState == 1 then
            if c == " " then
                iEnd = i-1
                iState = 3
                if iEnd>=iBegin then
                    table.insert(lArgs, string.sub(sCmd, iBegin, iEnd))
                end
            elseif mMatch[c] then
                assert(false, string.format("ReceiveCmd fail %d %s %s", iState, c, mMatch[c]))
            end
        elseif iState == 2 then
            if iMatch <= 0 then
                if c == " " then
                    iEnd = i-1
                    iState = 3
                    if iEnd>=iBegin then
                        table.insert(lArgs, string.sub(sCmd, iBegin, iEnd))
                    end
                else
                    assert(false, string.format("ReceiveCmd fail %d %s %s", iState, c, mMatch[c]))
                end
            else
                if c == mMatch[sMatch] then
                    iMatch = iMatch - 1
                elseif mMatch[c] then
                    assert(false, string.format("ReceiveCmd fail %d %s %s", iState, c, mMatch[c]))
                end
            end
        else
            if mMatch[c] then
                iState = 2
                iBegin = i
                sMatch = c
                iMatch = 1
            elseif c ~= " " then
                iBegin = i
                iState = 1
            end
        end
    end

    if iState == 1 then
        iEnd = #sCmd
        if iEnd>=iBegin then
            table.insert(lArgs, string.sub(sCmd, iBegin, iEnd))
        end
    elseif iState == 2 then
        if iMatch <= 0 then
            iEnd = #sCmd
            if iEnd>=iBegin then
                table.insert(lArgs, string.sub(sCmd, iBegin, iEnd))
            end
        end
    end

    local sCommand = lArgs[1]
    local lCommandArgs = {}
    for k = 2, #lArgs do
        local v = lArgs[k]
        local r = assert(load(string.format("return %s", v), "", "bt")(), string.format("ReceiveCmd fail index:%d value:%s", k, v))
        table.insert(lCommandArgs, r)
    end

    local func = Commands[sCommand]
    if func then
        func(oMaster, table.unpack(lCommandArgs))
    else
        assert(false, string.format("ReceiveCmd fail cmd:%s", sCommand))
    end

end
